// Tashqi API'larga imzolangan so'rovlar uchun umumiy yordamchilar (faqat
// WebCrypto): ES256 / RS256 JWT, PEM → DER, Google service account OAuth
// tokeni (JWT bearer grant, RFC 7523). Kalitlar FAQAT Worker secretlaridan
// (env) keladi — repoda hech qanday kalit yo'q.
//
// Foydalanuvchilar: billing.ts (App Store Server API, Play Developer API),
// attestation.ts (Play Integrity decodeIntegrityToken, Apple DeviceCheck).

import type { Ctx } from './context';
import { base64url } from './crypto';
import { ApiError } from './http';

const enc = new TextEncoder();
const b64json = (v: unknown) => base64url(enc.encode(JSON.stringify(v)));

export function pemToDer(pem: string): ArrayBuffer {
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

export function b64urlBytes(s: string): Uint8Array {
  const pad = s.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(pad + '='.repeat((4 - (pad.length % 4)) % 4));
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

export const b64urlDecode = (s: string): string => new TextDecoder().decode(b64urlBytes(s));

/**
 * JWT imzolash. Kalit noto'g'ri formatda bo'lsa — `503 <keyInvalid>`
 * (tafsilot javobga chiqmaydi).
 */
export async function signJwt(
  alg: 'ES256' | 'RS256',
  pem: string,
  header: Record<string, unknown>,
  payload: Record<string, unknown>,
  keyInvalid = 'store_key_invalid',
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
    throw new ApiError(503, keyInvalid);
  }
  return `${data}.${base64url(new Uint8Array(sig))}`;
}

export interface ServiceAccount {
  client_email: string;
  private_key: string;
  token_uri?: string;
}

/** Service account JSON (secret). Yo'q yoki buzilgan — `503 <keyInvalid>`. */
export function parseServiceAccount(raw: string | undefined, keyInvalid: string): ServiceAccount {
  try {
    const sa = JSON.parse(raw ?? '') as ServiceAccount;
    if (!sa || typeof sa.client_email !== 'string' || typeof sa.private_key !== 'string') throw new Error('fields');
    return sa;
  } catch {
    throw new ApiError(503, keyInvalid);
  }
}

/** Token keshi (isolate xotirasida): (service account, scope) → token. */
const tokenCache = new Map<string, { token: string; exp: number }>();

/** Faqat testlar uchun: kesh tozalanadi (har test o'z soxta fetch'i bilan). */
export const clearGoogleTokenCache = () => tokenCache.clear();

/**
 * Google OAuth 2.0 access token (service account, JWT bearer grant).
 * Hujjat: https://developers.google.com/identity/protocols/oauth2/service-account#httprest
 */
export async function googleServiceToken(
  ctx: Ctx,
  sa: ServiceAccount,
  scope: string,
  codes: { keyInvalid: string; authFailed: string; unavailable: string },
): Promise<string> {
  const cacheKey = `${sa.client_email}|${scope}`;
  const hit = tokenCache.get(cacheKey);
  if (hit && hit.exp > ctx.now + 60_000) return hit.token;
  const aud = sa.token_uri || 'https://oauth2.googleapis.com/token';
  const now = Math.floor(ctx.now / 1000);
  const assertion = await signJwt('RS256', sa.private_key, {}, { iss: sa.client_email, scope, aud, iat: now, exp: now + 3600 }, codes.keyInvalid);
  let res: Response;
  try {
    res = await (ctx.deps.fetch ?? fetch)(aud, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: `grant_type=${encodeURIComponent('urn:ietf:params:oauth:grant-type:jwt-bearer')}&assertion=${assertion}`,
    });
  } catch {
    throw new ApiError(502, codes.unavailable);
  }
  if (!res.ok) throw new ApiError(503, codes.authFailed);
  const body = (await res.json().catch(() => ({}))) as { access_token?: string; expires_in?: number };
  if (!body.access_token) throw new ApiError(503, codes.authFailed);
  tokenCache.set(cacheKey, { token: body.access_token, exp: ctx.now + (body.expires_in ?? 3600) * 1000 });
  return body.access_token;
}
