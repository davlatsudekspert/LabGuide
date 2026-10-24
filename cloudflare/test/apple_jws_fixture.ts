// SINOV uchun Apple-ga o'xshash JWS zanjiri (root P-384 → WWDR intermediate
// P-384 → leaf P-256), Apple OID kengaytmalari bilan. Haqiqiy Apple kaliti YO'Q:
// hammasi test ichida yaratiladi; server `APPLE_ROOT_CA_SHA256` orqali shu test
// root'ga pin qilinadi. Production'da pin — Apple Root CA - G3 (src/x509.ts).
import { OID_APPLE_INTERMEDIATE, OID_APPLE_LEAF } from '../src/x509';

const OID_ECDSA_SHA384 = [0x2a, 0x86, 0x48, 0xce, 0x3d, 0x04, 0x03, 0x03];
const OID_CN = [0x55, 0x04, 0x03];
const enc = new TextEncoder();

function len(n: number): number[] {
  if (n < 128) return [n];
  if (n < 256) return [0x81, n];
  return [0x82, n >> 8, n & 255];
}
function tlv(tag: number, ...parts: (Uint8Array | number[])[]): Uint8Array {
  const body = parts.flatMap((p) => Array.from(p));
  return new Uint8Array([tag, ...len(body.length), ...body]);
}
const seq = (...p: (Uint8Array | number[])[]) => tlv(0x30, ...p);
const oid = (b: number[]) => tlv(0x06, b);
function utc(ms: number): Uint8Array {
  const d = new Date(ms);
  const p = (n: number) => String(n).padStart(2, '0');
  const s = `${p(d.getUTCFullYear() % 100)}${p(d.getUTCMonth() + 1)}${p(d.getUTCDate())}${p(d.getUTCHours())}${p(d.getUTCMinutes())}${p(d.getUTCSeconds())}Z`;
  return tlv(0x17, enc.encode(s));
}
const name = (cn: string) => seq(tlv(0x31, seq(oid(OID_CN), tlv(0x0c, enc.encode(cn)))));
function derInt(b: Uint8Array): Uint8Array {
  let i = 0;
  while (i < b.length - 1 && b[i] === 0) i++;
  const v = Array.from(b.subarray(i));
  return tlv(0x02, v[0] & 0x80 ? [0, ...v] : v);
}
function p1363ToDer(sig: Uint8Array): Uint8Array {
  const h = sig.length / 2;
  return seq(derInt(sig.subarray(0, h)), derInt(sig.subarray(h)));
}
const b64 = (u: Uint8Array) => btoa(String.fromCharCode(...u));
const b64url = (u: Uint8Array) => b64(u).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

async function keyPair(curve: 'P-256' | 'P-384') {
  return (await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: curve }, true, ['sign', 'verify'])) as CryptoKeyPair;
}

async function cert(o: {
  subject: string;
  issuer: string;
  pub: CryptoKey;
  signer: CryptoKey;
  extOids: number[][];
  notBefore: number;
  notAfter: number;
  serial: number;
}): Promise<Uint8Array> {
  const spki = new Uint8Array((await crypto.subtle.exportKey('spki', o.pub)) as ArrayBuffer);
  const exts = o.extOids.map((x) => seq(oid(x), tlv(0x04, [0x05, 0x00])));
  const tbs = seq(
    tlv(0xa0, tlv(0x02, [2])),
    tlv(0x02, [o.serial]),
    seq(oid(OID_ECDSA_SHA384)),
    name(o.issuer),
    seq(utc(o.notBefore), utc(o.notAfter)),
    name(o.subject),
    spki,
    tlv(0xa3, seq(...exts)),
  );
  const sig = new Uint8Array(await crypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-384' }, o.signer, tbs));
  return seq(tbs, seq(oid(OID_ECDSA_SHA384)), tlv(0x03, [0, ...p1363ToDer(sig)]));
}

export interface AppleChain {
  rootSha256: string;
  /** To'g'ri imzolangan JWS (x5c = leaf, intermediate, root). */
  sign(payload: unknown): Promise<string>;
  /** Boshqa (pin qilinmagan) root bilan imzolangan JWS — rad etilishi kerak. */
  signForeign(payload: unknown): Promise<string>;
}

async function build(validFrom: number, validTo: number) {
  const root = await keyPair('P-384');
  const inter = await keyPair('P-384');
  const leaf = await keyPair('P-256');
  const rootDer = await cert({
    subject: 'Test Root CA', issuer: 'Test Root CA', pub: root.publicKey, signer: root.privateKey,
    extOids: [], notBefore: validFrom, notAfter: validTo, serial: 1,
  });
  const interDer = await cert({
    subject: 'Test WWDR', issuer: 'Test Root CA', pub: inter.publicKey, signer: root.privateKey,
    extOids: [OID_APPLE_INTERMEDIATE], notBefore: validFrom, notAfter: validTo, serial: 2,
  });
  const leafDer = await cert({
    subject: 'Test App Store Signing', issuer: 'Test WWDR', pub: leaf.publicKey, signer: inter.privateKey,
    extOids: [OID_APPLE_LEAF], notBefore: validFrom, notAfter: validTo, serial: 3,
  });
  const x5c = [b64(leafDer), b64(interDer), b64(rootDer)];
  const sign = async (payload: unknown) => {
    const h = b64url(enc.encode(JSON.stringify({ alg: 'ES256', x5c })));
    const p = b64url(enc.encode(JSON.stringify(payload)));
    const sig = new Uint8Array(await crypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, leaf.privateKey, enc.encode(`${h}.${p}`)));
    return `${h}.${p}.${b64url(sig)}`;
  };
  const digest = new Uint8Array(await crypto.subtle.digest('SHA-256', rootDer));
  const rootSha256 = Array.from(digest, (b) => b.toString(16).padStart(2, '0')).join('');
  return { sign, rootSha256 };
}

let cached: Promise<AppleChain> | null = null;

/** Bitta test zanjiri (2020…2035 amal qiladi). */
export function appleChain(): Promise<AppleChain> {
  cached ??= (async () => {
    const from = Date.UTC(2020, 0, 1);
    const to = Date.UTC(2035, 0, 1);
    const good = await build(from, to);
    const foreign = await build(from, to);
    return { rootSha256: good.rootSha256, sign: good.sign, signForeign: foreign.sign };
  })();
  return cached;
}

/** Muddati o'tgan zanjir (2015…2019) — `expired`. */
export async function expiredChain(): Promise<AppleChain> {
  const c = await build(Date.UTC(2015, 0, 1), Date.UTC(2019, 0, 1));
  return { rootSha256: c.rootSha256, sign: c.sign, signForeign: c.sign };
}

/** Imzoni buzadi (oxirgi belgi). */
export const tamper = (jws: string) => {
  const parts = jws.split('.');
  const p = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
  p.tampered = true;
  return `${parts[0]}.${b64url(enc.encode(JSON.stringify(p)))}.${parts[2]}`;
};
