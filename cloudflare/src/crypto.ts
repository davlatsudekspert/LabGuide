// Kriptografik yordamchilar (faqat WebCrypto).

const enc = new TextEncoder();

export function hex(buf: ArrayBuffer | Uint8Array): string {
  const b = buf instanceof Uint8Array ? buf : new Uint8Array(buf);
  let s = '';
  for (const x of b) s += x.toString(16).padStart(2, '0');
  return s;
}

export function base64url(bytes: Uint8Array): string {
  let s = '';
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function b64encode(bytes: Uint8Array): string {
  let s = '';
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s);
}

function b64decode(s: string): Uint8Array {
  const bin = atob(s);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

export function randomBytes(n: number): Uint8Array {
  const b = new Uint8Array(n);
  crypto.getRandomValues(b);
  return b;
}

/** Bir tekis taqsimlangan tasodifiy belgilar (rejection sampling). */
export function randomFrom(alphabet: string, length: number): string {
  const limit = 256 - (256 % alphabet.length);
  let out = '';
  while (out.length < length) {
    for (const b of randomBytes(length * 2)) {
      if (b < limit && out.length < length) out += alphabet[b % alphabet.length];
    }
  }
  return out;
}

export const randomDigits = (n: number) => randomFrom('0123456789', n);

export async function sha256Hex(s: string): Promise<string> {
  return hex(await crypto.subtle.digest('SHA-256', enc.encode(s)));
}

async function hmacKey(raw: Uint8Array | string, hash = 'SHA-256'): Promise<CryptoKey> {
  const bytes = typeof raw === 'string' ? enc.encode(raw) : raw;
  return crypto.subtle.importKey('raw', bytes, { name: 'HMAC', hash }, false, ['sign']);
}

export async function hmac(key: CryptoKey, msg: string | Uint8Array): Promise<Uint8Array> {
  const data = typeof msg === 'string' ? enc.encode(msg) : msg;
  return new Uint8Array(await crypto.subtle.sign('HMAC', key, data));
}

/** Uzunligi teng satrlarni vaqtga bog'liq bo'lmagan holda solishtiradi. */
export function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

export interface Keys {
  email: CryptoKey;
  ip: CryptoKey;
  otp: CryptoKey;
  totp: CryptoKey; // AES-GCM
}

const keyCache = new Map<string, Promise<Keys>>();

/** Bitta server secretidan maqsadga ko'ra alohida kalitlar. */
export function deriveKeys(secret: string): Promise<Keys> {
  let p = keyCache.get(secret);
  if (!p) {
    p = (async () => {
      const root = await hmacKey(secret);
      const sub = async (label: string) => hmac(root, `labguide/${label}/v1`);
      return {
        email: await hmacKey(await sub('email')),
        ip: await hmacKey(await sub('ip')),
        otp: await hmacKey(await sub('otp')),
        totp: await crypto.subtle.importKey('raw', await sub('totp'), 'AES-GCM', false, [
          'encrypt',
          'decrypt',
        ]),
      };
    })();
    keyCache.set(secret, p);
  }
  return p;
}

export async function encrypt(key: CryptoKey, plain: Uint8Array): Promise<string> {
  const iv = randomBytes(12);
  const ct = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, plain));
  return `${b64encode(iv)}.${b64encode(ct)}`;
}

export async function decrypt(key: CryptoKey, packed: string): Promise<Uint8Array> {
  const [iv, ct] = packed.split('.');
  return new Uint8Array(
    await crypto.subtle.decrypt({ name: 'AES-GCM', iv: b64decode(iv) }, key, b64decode(ct)),
  );
}

// ------------------------------------------------------------------ TOTP
const B32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

export function base32(bytes: Uint8Array): string {
  let bits = 0;
  let value = 0;
  let out = '';
  for (const b of bytes) {
    value = (value << 8) | b;
    bits += 8;
    while (bits >= 5) {
      out += B32[(value >>> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0) out += B32[(value << (5 - bits)) & 31];
  return out;
}

/** RFC 6238: SHA-1, 30 s, 6 raqam. */
export async function totpAt(secret: Uint8Array, step: number): Promise<string> {
  const key = await hmacKey(secret, 'SHA-1');
  const msg = new Uint8Array(8);
  new DataView(msg.buffer).setBigUint64(0, BigInt(step));
  const h = await hmac(key, msg);
  const o = h[h.length - 1] & 0xf;
  const n =
    ((h[o] & 0x7f) << 24) | ((h[o + 1] & 0xff) << 16) | ((h[o + 2] & 0xff) << 8) | (h[o + 3] & 0xff);
  return String(n % 1_000_000).padStart(6, '0');
}
