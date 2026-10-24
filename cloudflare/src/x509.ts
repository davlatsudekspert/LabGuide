// App Store imzolagan JWS (signedPayload / signedTransactionInfo /
// signedRenewalInfo) ni tekshirish — x5c sertifikat zanjiri Apple Root CA - G3
// gacha, keyin JWS imzosi zanjirdagi barg (leaf) kalit bilan (ES256).
//
// Rasmiy manbalar (2026-10-24 da o'qilgan):
// * https://developer.apple.com/documentation/appstoreservernotifications/responsebodyv2
//   — "signedPayload ... signed by the App Store"; har JWS imzosini serverda
//   tekshirish mumkin, algoritm — sarlavhadagi `alg` (RFC 7515).
// * https://developer.apple.com/documentation/appstoreserverapi/jwstransaction
// * Apple Root CA - G3: https://www.apple.com/certificateauthority/AppleRootCA-G3.cer
//   SHA-256 = 63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179
//   (2026-10-24 da yuklab olinib `sha256sum` bilan hisoblangan; amal qilish
//   2014-04-30 … 2039-04-30).
// * Apple'ning rasmiy App Store Server Library tekshiruvi bilan bir xil
//   qoidalar: zanjir 3 ta sertifikat (leaf, WWDR intermediate, root), root
//   aynan pin qilingan sertifikat, leaf'da 1.2.840.113635.100.6.11.1 va
//   intermediate'da 1.2.840.113635.100.6.2.1 kengaytmasi bo'lishi shart,
//   har sertifikat amal qilish muddatida.
//
// Bu fayl faqat ECDSA (P-256 / P-384, SHA-256 / SHA-384) ni qo'llaydi — Apple
// zanjiri shu algoritmlardan foydalanadi; boshqasi rad etiladi.

import { hex } from './crypto';

/** Apple Root CA - G3 sertifikatining SHA-256 barmoq izi (DER). */
export const APPLE_ROOT_CA_G3_SHA256 = '63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179';

const OID_ECDSA_SHA256 = [0x2a, 0x86, 0x48, 0xce, 0x3d, 0x04, 0x03, 0x02];
const OID_ECDSA_SHA384 = [0x2a, 0x86, 0x48, 0xce, 0x3d, 0x04, 0x03, 0x03];
const OID_P256 = [0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07];
const OID_P384 = [0x2b, 0x81, 0x04, 0x00, 0x22];
/** 1.2.840.113635.100.6.11.1 — App Store (Mac App Store receipt signing) leaf belgisi. */
export const OID_APPLE_LEAF = [0x2a, 0x86, 0x48, 0x86, 0xf7, 0x63, 0x64, 0x06, 0x0b, 0x01];
/** 1.2.840.113635.100.6.2.1 — Apple WWDR intermediate belgisi. */
export const OID_APPLE_INTERMEDIATE = [0x2a, 0x86, 0x48, 0x86, 0xf7, 0x63, 0x64, 0x06, 0x02, 0x01];

export class JwsError extends Error {}

interface Tlv {
  tag: number;
  /** TLV boshi (tag bayti). */
  start: number;
  /** Qiymat boshi. */
  body: number;
  end: number;
}

function tlv(buf: Uint8Array, off: number): Tlv {
  if (off + 2 > buf.length) throw new JwsError('der');
  const tag = buf[off];
  let len = buf[off + 1];
  let body = off + 2;
  if (len & 0x80) {
    const n = len & 0x7f;
    if (n < 1 || n > 4 || body + n > buf.length) throw new JwsError('der');
    len = 0;
    for (let i = 0; i < n; i++) len = len * 256 + buf[body + i];
    body += n;
  }
  const end = body + len;
  if (end > buf.length) throw new JwsError('der');
  return { tag, start: off, body, end };
}

function kids(buf: Uint8Array, t: Tlv): Tlv[] {
  const out: Tlv[] = [];
  for (let off = t.body; off < t.end; ) {
    const c = tlv(buf, off);
    out.push(c);
    off = c.end;
  }
  return out;
}

const eq = (buf: Uint8Array, t: Tlv, bytes: number[]) =>
  t.end - t.body === bytes.length && bytes.every((b, i) => buf[t.body + i] === b);

function contains(hay: Uint8Array, needle: number[]): boolean {
  outer: for (let i = 0; i + needle.length <= hay.length; i++) {
    for (let j = 0; j < needle.length; j++) if (hay[i + j] !== needle[j]) continue outer;
    return true;
  }
  return false;
}

function parseTime(buf: Uint8Array, t: Tlv): number {
  const s = new TextDecoder().decode(buf.subarray(t.body, t.end));
  let m: RegExpExecArray | null;
  if (t.tag === 0x17 && (m = /^(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})Z$/.exec(s))) {
    const yy = Number(m[1]);
    return Date.UTC(yy < 50 ? 2000 + yy : 1900 + yy, Number(m[2]) - 1, +m[3], +m[4], +m[5], +m[6]);
  }
  if (t.tag === 0x18 && (m = /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})Z$/.exec(s))) {
    return Date.UTC(+m[1], Number(m[2]) - 1, +m[3], +m[4], +m[5], +m[6]);
  }
  throw new JwsError('time');
}

type Curve = 'P-256' | 'P-384';

export interface Cert {
  der: Uint8Array;
  tbs: Uint8Array;
  sigHash: 'SHA-256' | 'SHA-384';
  /** DER (SEQUENCE r, s) imzo. */
  sig: Uint8Array;
  notBefore: number;
  notAfter: number;
  spki: Uint8Array;
  curve: Curve;
  extensions: Uint8Array;
}

export function parseCert(der: Uint8Array): Cert {
  const root = tlv(der, 0);
  if (root.tag !== 0x30 || root.end !== der.length) throw new JwsError('cert');
  const [tbsT, algT, sigT] = kids(der, root);
  if (!tbsT || !algT || !sigT || sigT.tag !== 0x03) throw new JwsError('cert');
  const algOid = kids(der, algT)[0];
  const sigHash = eq(der, algOid, OID_ECDSA_SHA256)
    ? 'SHA-256'
    : eq(der, algOid, OID_ECDSA_SHA384)
      ? 'SHA-384'
      : null;
  if (!sigHash) throw new JwsError('alg');
  if (der[sigT.body] !== 0) throw new JwsError('cert');
  const f = kids(der, tbsT);
  let i = f[0]?.tag === 0xa0 ? 1 : 0; // [0] version
  i += 2; // serialNumber, signature
  i += 1; // issuer
  const validity = f[i++];
  i += 1; // subject
  const spkiT = f[i++];
  if (!validity || !spkiT) throw new JwsError('cert');
  const [nb, na] = kids(der, validity);
  const spkiAlg = kids(der, kids(der, spkiT)[0]);
  const curve: Curve | null = eq(der, spkiAlg[1], OID_P256) ? 'P-256' : eq(der, spkiAlg[1], OID_P384) ? 'P-384' : null;
  if (!curve) throw new JwsError('curve');
  const ext = f.find((x) => x.tag === 0xa3);
  return {
    der,
    tbs: der.subarray(tbsT.start, tbsT.end),
    sigHash,
    sig: der.subarray(sigT.body + 1, sigT.end),
    notBefore: parseTime(der, nb),
    notAfter: parseTime(der, na),
    spki: der.subarray(spkiT.start, spkiT.end),
    curve,
    extensions: ext ? der.subarray(ext.start, ext.end) : new Uint8Array(),
  };
}

/** DER ECDSA imzo (SEQUENCE{r,s}) → IEEE P1363 (r||s), WebCrypto shuni kutadi. */
export function derSigToP1363(sig: Uint8Array, size: number): Uint8Array {
  const seq = tlv(sig, 0);
  const [r, s] = kids(sig, seq);
  if (!r || !s || r.tag !== 0x02 || s.tag !== 0x02) throw new JwsError('sig');
  const out = new Uint8Array(size * 2);
  const put = (t: Tlv, at: number) => {
    let v = sig.subarray(t.body, t.end);
    while (v.length > 0 && v[0] === 0) v = v.subarray(1);
    if (v.length > size) throw new JwsError('sig');
    out.set(v, at + size - v.length);
  };
  put(r, 0);
  put(s, size);
  return out;
}

const importSpki = (c: Cert) =>
  crypto.subtle.importKey('spki', c.spki, { name: 'ECDSA', namedCurve: c.curve }, false, ['verify']);

async function signedBy(child: Cert, issuer: Cert): Promise<boolean> {
  const key = await importSpki(issuer);
  const size = issuer.curve === 'P-256' ? 32 : 48;
  return crypto.subtle.verify({ name: 'ECDSA', hash: child.sigHash }, key, derSigToP1363(child.sig, size), child.tbs);
}

function b64(s: string): Uint8Array {
  const bin = atob(s);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

function b64url(s: string): Uint8Array {
  if (!/^[A-Za-z0-9_-]*$/.test(s)) throw new JwsError('b64');
  const pad = s.replace(/-/g, '+').replace(/_/g, '/');
  return b64(pad + '='.repeat((4 - (pad.length % 4)) % 4));
}

/**
 * Apple JWS ni to'liq tekshiradi va yuklamani qaytaradi. Xato — [JwsError]
 * (chaqiruvchi 401/400 ga aylantiradi). [rootSha256] — pin qilingan root
 * barmoq izi (standart: Apple Root CA - G3); [at] — sertifikat muddati
 * tekshiriladigan vaqt (ms).
 */
export async function verifyAppleJws<T = Record<string, unknown>>(
  jws: unknown,
  opts: { rootSha256?: string; at: number },
): Promise<T> {
  if (typeof jws !== 'string') throw new JwsError('jws');
  const parts = jws.split('.');
  if (parts.length !== 3) throw new JwsError('jws');
  let header: { alg?: string; x5c?: unknown };
  let payload: T;
  try {
    header = JSON.parse(new TextDecoder().decode(b64url(parts[0])));
    payload = JSON.parse(new TextDecoder().decode(b64url(parts[1])));
  } catch {
    throw new JwsError('jws');
  }
  if (header.alg !== 'ES256') throw new JwsError('alg');
  const x5c = header.x5c;
  if (!Array.isArray(x5c) || x5c.length !== 3 || !x5c.every((c) => typeof c === 'string')) throw new JwsError('x5c');
  let chain: Cert[];
  try {
    chain = (x5c as string[]).map((c) => parseCert(b64(c)));
  } catch {
    throw new JwsError('x5c');
  }
  const [leaf, intermediate, root] = chain;
  const pin = (opts.rootSha256 ?? APPLE_ROOT_CA_G3_SHA256).toLowerCase().replace(/[^0-9a-f]/g, '');
  const rootHash = hex(await crypto.subtle.digest('SHA-256', root.der));
  if (rootHash !== pin) throw new JwsError('root');
  for (const c of chain) {
    if (opts.at < c.notBefore || opts.at > c.notAfter) throw new JwsError('expired');
  }
  if (!contains(leaf.extensions, OID_APPLE_LEAF)) throw new JwsError('leaf_oid');
  if (!contains(intermediate.extensions, OID_APPLE_INTERMEDIATE)) throw new JwsError('intermediate_oid');
  if (leaf.curve !== 'P-256') throw new JwsError('curve');
  try {
    if (!(await signedBy(intermediate, root))) throw new JwsError('chain');
    if (!(await signedBy(leaf, intermediate))) throw new JwsError('chain');
    const ok = await crypto.subtle.verify(
      { name: 'ECDSA', hash: 'SHA-256' },
      await importSpki(leaf),
      b64url(parts[2]),
      new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
    );
    if (!ok) throw new JwsError('signature');
  } catch (e) {
    if (e instanceof JwsError) throw e;
    throw new JwsError('signature');
  }
  return payload;
}
