/**
 * Kichik JWT yordamchilari (WebCrypto): base64url o'qish va JWT imzolash.
 * Apple bilan kirishda client_secret (ES256) shu yerda imzolanadi.
 */
import { base64url } from './crypto';
import { ApiError } from './http';

const enc = new TextEncoder();
const b64json = (v: unknown) => base64url(enc.encode(JSON.stringify(v)));

function pemToDer(pem: string): ArrayBuffer {
  // Secret'da `\n` ketma-ketligi bilan saqlangan bo'lishi ham mumkin.
  const body = pem
    .replace(/\\n/g, '\n')
    .replace(/-----(BEGIN|END)[^-]+-----/g, '')
    .replace(/\s+/g, '');
  const bin = atob(body);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out.buffer;
}

export function b64urlDecode(s: string): string {
  const pad = s.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(pad + '='.repeat((4 - (pad.length % 4)) % 4));
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return new TextDecoder().decode(bytes);
}

export async function signJwt(
  alg: 'ES256' | 'RS256',
  pem: string,
  header: Record<string, unknown>,
  payload: Record<string, unknown>,
): Promise<string> {
  const data = `${b64json({ ...header, alg, typ: 'JWT' })}.${b64json(payload)}`;
  let sig: ArrayBuffer;
  try {
    if (alg === 'ES256') {
      const key = await crypto.subtle.importKey('pkcs8', pemToDer(pem), { name: 'ECDSA', namedCurve: 'P-256' }, false, ['sign']);
      // WebCrypto ECDSA imzosi — IEEE P1363 (r||s), JWS ham shuni talab qiladi.
      sig = await crypto.subtle.sign({ name: 'ECDSA', hash: 'SHA-256' }, key, enc.encode(data));
    } else {
      const key = await crypto.subtle.importKey('pkcs8', pemToDer(pem), { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign']);
      sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, enc.encode(data));
    }
  } catch {
    // Kalit noto'g'ri formatda — tafsilot javobga chiqmaydi.
    throw new ApiError(503, 'key_invalid');
  }
  return `${data}.${base64url(new Uint8Array(sig))}`;
}
