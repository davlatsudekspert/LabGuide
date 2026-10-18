// Google / Apple bilan kirish (D-56): ID token serverda to'liq tekshiriladi.
//
// Tamoyillar:
// * Ilovaga ishonilmaydi: ilova faqat provayder bergan ID token va o'zining
//   xom `nonce` ini yuboradi. Imzo (provayder JWKS, RS256), `iss`, `aud`,
//   `exp`/`iat`/`nbf`, `email_verified` va nonce shu yerda tekshiriladi.
// * Bitta email = bitta hisob: tasdiqlangan email mavjud hisob emailiga teng
//   bo'lsa — o'sha hisobga kirish (bog'lash), dublikat yaratilmaydi. Keyingi
//   kirishlar provayderning `sub` i bo'yicha (Apple relay email o'zgarsa ham).
// * Hech qanday token saqlanmaydi. Qayta ishlatishga qarshi faqat token
//   belgisining hashi (`auth_replay`) amal qilish muddatigacha turadi.
// * Admin vakolati bu yo'l bilan BERILMAYDI (faqat email kodi bilan).
// * Apple: hisob o'chirilganda token bekor qilinadi (revoke). Buning uchun
//   ilova o'chirish paytida yangi `authorizationCode` yuboradi; server uni
//   almashtirib, olingan refresh tokenni darhol bekor qiladi — saqlanmaydi.
// * Sozlama yo'q (GOOGLE_CLIENT_IDS / APPLE_SIGNIN_*) — `503 not_configured`.

import {
  audit,
  createSession,
  emailHash,
  findOrCreateUser,
  normalizeEmail,
  syncAdmin,
} from './auth';
import { b64urlDecode, signJwt } from './jwt';
import type { Ctx } from './context';
import { safeEqual, sha256Hex } from './crypto';
import { ApiError, badRequest, type Env, json, readJson } from './http';
import { hit } from './ratelimit';

export type Provider = 'google' | 'apple';

const GOOGLE_JWKS = 'https://www.googleapis.com/oauth2/v3/certs';
const APPLE_JWKS = 'https://appleid.apple.com/auth/keys';
const GOOGLE_ISSUERS = ['https://accounts.google.com', 'accounts.google.com'];
const APPLE_ISSUER = 'https://appleid.apple.com';
const APPLE_TOKEN_URL = 'https://appleid.apple.com/auth/token';
const APPLE_REVOKE_URL = 'https://appleid.apple.com/auth/revoke';
const DEFAULT_BUNDLE = 'uz.labguide.app';

const MAX_TOKEN_LEN = 8192;
/** Soat farqi uchun yumshoqlik. */
const LEEWAY_SEC = 60;
const JWKS_MIN_TTL_SEC = 300;
const JWKS_MAX_TTL_SEC = 86400;
const JWKS_DEFAULT_TTL_SEC = 3600;
/** Noma'lum `kid` uchun kalitlarni majburan yangilash oralig'i (suiiste'molga qarshi). */
const JWKS_REFRESH_COOLDOWN_SEC = 300;

// -------------------------------------------------------------- sozlama
export const googleClientIds = (env: Env): string[] =>
  (env.GOOGLE_CLIENT_IDS ?? '')
    .split(/[\s,]+/)
    .map((s) => s.trim())
    .filter(Boolean);

export const googleLoginConfigured = (env: Env) => googleClientIds(env).length > 0;

export const appleSignInConfigured = (env: Env) =>
  Boolean(env.APPLE_SIGNIN_TEAM_ID && env.APPLE_SIGNIN_KEY_ID && env.APPLE_SIGNIN_PRIVATE_KEY);

const appleClientId = (env: Env) => env.APPLE_SIGNIN_CLIENT_ID || DEFAULT_BUNDLE;

const appleAudiences = (env: Env): string[] =>
  [appleClientId(env), env.APPLE_SIGNIN_SERVICE_ID].filter((x): x is string => Boolean(x));

const notConfigured = () => new ApiError(503, 'not_configured');
const invalidToken = (code = 'invalid_token') => new ApiError(401, code);

/** Ilova qaysi tugmani ko'rsatishini shu javobdan biladi. */
export async function providers(ctx: Ctx): Promise<Response> {
  const apple = appleSignInConfigured(ctx.env);
  return json({
    google: googleLoginConfigured(ctx.env),
    apple,
    // Android uchun Apple (veb-oqim) faqat Services ID sozlangan bo'lsa.
    apple_web: apple && Boolean(ctx.env.APPLE_SIGNIN_SERVICE_ID),
  });
}

// ----------------------------------------------------------------- JWKS
interface JwksEntry {
  keys: Map<string, CryptoKey>;
  expires: number;
  fetchedAt: number;
}

const jwksCache = new Map<string, JwksEntry>();

/** Testlar uchun: kalit keshini tozalash. */
export function resetSocialCaches(): void {
  jwksCache.clear();
}

const doFetch = (ctx: Ctx): typeof fetch => ctx.deps.fetch ?? fetch;

function maxAgeSec(res: Response): number {
  const m = /max-age=(\d+)/.exec(res.headers.get('cache-control') ?? '');
  const n = m ? Number(m[1]) : JWKS_DEFAULT_TTL_SEC;
  return Math.min(JWKS_MAX_TTL_SEC, Math.max(JWKS_MIN_TTL_SEC, n));
}

async function fetchJwks(ctx: Ctx, url: string): Promise<JwksEntry> {
  let res: Response;
  try {
    res = await doFetch(ctx)(url, { headers: { accept: 'application/json' } });
  } catch {
    throw new ApiError(502, 'provider_unavailable');
  }
  if (!res.ok) throw new ApiError(502, 'provider_unavailable');
  let body: { keys?: unknown };
  try {
    body = (await res.json()) as { keys?: unknown };
  } catch {
    throw new ApiError(502, 'provider_unavailable');
  }
  if (!Array.isArray(body.keys)) throw new ApiError(502, 'provider_unavailable');
  const keys = new Map<string, CryptoKey>();
  for (const k of body.keys as Array<Record<string, unknown>>) {
    if (k?.kty !== 'RSA' || typeof k.kid !== 'string' || (k.alg && k.alg !== 'RS256')) continue;
    if (k.use && k.use !== 'sig') continue;
    try {
      keys.set(
        k.kid,
        await crypto.subtle.importKey(
          'jwk',
          { kty: 'RSA', n: k.n as string, e: k.e as string, alg: 'RS256', ext: true },
          { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
          false,
          ['verify'],
        ),
      );
    } catch {
      // Buzuq kalit boshqalarini to'sib qo'ymaydi.
    }
  }
  const entry = { keys, expires: ctx.now + maxAgeSec(res) * 1000, fetchedAt: ctx.now };
  jwksCache.set(url, entry);
  return entry;
}

/**
 * `kid` bo'yicha kalit. Kesh muddati `cache-control` dan; noma'lum `kid`
 * (provayder kalitni almashtirgan) uchun — cheklangan tezlikda qayta yuklash.
 * Yuklab bo'lmasa va eski kesh bo'lsa — eski kalitlar bilan davom etadi.
 */
async function signingKey(ctx: Ctx, url: string, kid: string): Promise<CryptoKey | null> {
  let entry = jwksCache.get(url);
  const fresh = entry !== undefined && ctx.now < entry.expires;
  if (fresh && entry!.keys.has(kid)) return entry!.keys.get(kid)!;
  const mayRefetch = !entry || !fresh || ctx.now - entry.fetchedAt >= JWKS_REFRESH_COOLDOWN_SEC * 1000;
  if (mayRefetch) {
    try {
      entry = await fetchJwks(ctx, url);
    } catch (e) {
      if (!entry) throw e;
      console.warn('jwks refresh failed, using cached keys');
    }
  }
  return entry?.keys.get(kid) ?? null;
}

// ------------------------------------------------------------ ID token
export interface Claims {
  iss: string;
  sub: string;
  aud: string | string[];
  exp: number;
  iat?: number;
  nbf?: number;
  nonce?: string;
  email?: string;
  email_verified?: boolean | string;
}

function decodePart(part: string): Record<string, unknown> {
  try {
    const v = JSON.parse(b64urlDecode(part));
    if (v === null || typeof v !== 'object' || Array.isArray(v)) throw new Error('shape');
    return v as Record<string, unknown>;
  } catch {
    throw invalidToken();
  }
}

function b64urlBytes(s: string): Uint8Array {
  if (!/^[A-Za-z0-9_-]+$/.test(s)) throw invalidToken();
  const pad = s.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(pad + '='.repeat((4 - (pad.length % 4)) % 4));
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

/**
 * ID tokenni to'liq tekshiradi (imzo, iss, aud, muddat, nonce). `email_verified`
 * va hisobga bog'lash chaqiruvchida.
 */
export async function verifyIdToken(
  ctx: Ctx,
  provider: Provider,
  idToken: string,
  rawNonce: string,
): Promise<Claims> {
  const parts = idToken.split('.');
  if (parts.length !== 3) throw invalidToken();
  const header = decodePart(parts[0]);
  const payload = decodePart(parts[1]);
  // Faqat RS256 (alg=none / HS256 aralashtirish hujumlariga qarshi).
  if (header.alg !== 'RS256' || typeof header.kid !== 'string' || !header.kid) throw invalidToken();

  const key = await signingKey(ctx, provider === 'google' ? GOOGLE_JWKS : APPLE_JWKS, header.kid);
  if (!key) throw invalidToken();
  const ok = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    key,
    b64urlBytes(parts[2]),
    new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
  );
  if (!ok) throw invalidToken();

  const c = payload as unknown as Claims;
  const issuers = provider === 'google' ? GOOGLE_ISSUERS : [APPLE_ISSUER];
  if (typeof c.iss !== 'string' || !issuers.includes(c.iss)) throw invalidToken();
  const allowed = provider === 'google' ? googleClientIds(ctx.env) : appleAudiences(ctx.env);
  const auds = typeof c.aud === 'string' ? [c.aud] : Array.isArray(c.aud) ? c.aud : [];
  if (!auds.some((a) => typeof a === 'string' && allowed.includes(a))) throw invalidToken();
  if (typeof c.sub !== 'string' || c.sub.length === 0 || c.sub.length > 255) throw invalidToken();

  const nowSec = Math.floor(ctx.now / 1000);
  if (typeof c.exp !== 'number' || c.exp + LEEWAY_SEC <= nowSec) throw invalidToken('token_expired');
  if (c.iat !== undefined && (typeof c.iat !== 'number' || c.iat > nowSec + LEEWAY_SEC)) throw invalidToken();
  if (c.nbf !== undefined && (typeof c.nbf !== 'number' || c.nbf > nowSec + LEEWAY_SEC)) throw invalidToken();

  // Ilova provayderga sha256(xom nonce) (hex) berdi; token shuni qaytaradi.
  const expected = await sha256Hex(rawNonce);
  if (typeof c.nonce !== 'string' || !safeEqual(c.nonce.toLowerCase(), expected)) {
    throw invalidToken('nonce_mismatch');
  }
  return c;
}

const emailVerified = (c: Claims) => c.email_verified === true || c.email_verified === 'true';

// ---------------------------------------------------------------- login
async function socialLogin(ctx: Ctx, provider: Provider): Promise<Response> {
  const configured = provider === 'google' ? googleLoginConfigured(ctx.env) : appleSignInConfigured(ctx.env);
  if (!configured) throw notConfigured();
  const body = await readJson(ctx.req, 16 * 1024);
  const idToken = typeof body.id_token === 'string' ? body.id_token : '';
  const nonce = typeof body.nonce === 'string' ? body.nonce : '';
  if (!idToken || idToken.length > MAX_TOKEN_LEN) throw badRequest('invalid_token');
  if (nonce.length < 16 || nonce.length > 256) throw badRequest('invalid_nonce');
  // Kod kirishi bilan bir xil turdagi limit (IP bo'yicha; sinf bitta NAT ortida bo'lishi mumkin).
  await hit(ctx.db, `social-ip:${ctx.ipTag}`, 60, 600, ctx.now);

  const claims = await verifyIdToken(ctx, provider, idToken, nonce);

  // Bir martalik: bir xil token+nonce ikkinchi marta qabul qilinmaydi. Imzo
  // tekshirilgandan KEYIN yoziladi (soxta tokenlar jadvalni to'ldirmasin).
  const replayKey = await sha256Hex(
    `${provider}|${claims.sub}|${claims.iat ?? 0}|${claims.exp}|${claims.nonce}`,
  );
  const ins = await ctx.db
    .prepare('INSERT INTO auth_replay (key_hash, expires_at) VALUES (?1, ?2) ON CONFLICT (key_hash) DO NOTHING')
    .bind(replayKey, claims.exp * 1000 + LEEWAY_SEC * 1000)
    .run();
  if (!ins.meta.changes) throw invalidToken('replayed_token');

  const email = emailVerified(claims) ? normalizeEmail(claims.email) : null;
  const sub = claims.sub;

  let userId: string;
  let created = false;
  let linked = false;
  const known = await ctx.db
    .prepare('SELECT user_id FROM auth_identities WHERE provider = ?1 AND provider_sub = ?2')
    .bind(provider, sub)
    .first<{ user_id: string }>();
  if (known) {
    userId = known.user_id;
  } else {
    // Birinchi kirish: tasdiqlangan email shart (bitta email = bitta hisob).
    if (!email) {
      if (typeof claims.email === 'string' && !emailVerified(claims)) throw new ApiError(403, 'email_not_verified');
      throw badRequest('email_required');
    }
    const eh = await emailHash(ctx, email);
    const found = await findOrCreateUser(ctx, eh, email);
    created = found.created;
    linked = !found.created;
    await ctx.db
      .prepare(
        `INSERT INTO auth_identities (provider, provider_sub, user_id, created_at) VALUES (?1, ?2, ?3, ?4)
         ON CONFLICT (provider, provider_sub) DO NOTHING`,
      )
      .bind(provider, sub, found.id, ctx.now)
      .run();
    // Parallel birinchi kirishda g'olib bitta; yutqazgan yangi hisob yetim qolmasin.
    const winner = await ctx.db
      .prepare('SELECT user_id FROM auth_identities WHERE provider = ?1 AND provider_sub = ?2')
      .bind(provider, sub)
      .first<{ user_id: string }>();
    if (!winner) throw new Error('identity insert failed');
    if (winner.user_id !== found.id) {
      if (created) await ctx.db.prepare('DELETE FROM users WHERE id = ?1').bind(found.id).run();
      created = false;
      linked = false;
    }
    userId = winner.user_id;
    if (linked) await audit(ctx, userId, 'identity_linked', userId, { provider });
  }

  const u = await ctx.db
    .prepare('SELECT email_hash, email_masked FROM users WHERE id = ?1')
    .bind(userId)
    .first<{ email_hash: string; email_masked: string }>();
  if (!u) throw new ApiError(401, 'unauthorized');
  // Admin: faqat OLIB TASHLASH (ro'yxatdan chiqqan bo'lsa) — berish emas.
  if (email && safeEqual(await emailHash(ctx, email), u.email_hash)) {
    await syncAdmin(ctx, userId, email, { grant: false });
  }

  const session = await createSession(ctx, userId, provider);
  return json({
    ...session,
    new_user: created,
    linked,
    provider,
    email,
    email_masked: u.email_masked,
  });
}

export const googleLogin = (ctx: Ctx) => socialLogin(ctx, 'google');
export const appleLogin = (ctx: Ctx) => socialLogin(ctx, 'apple');

/**
 * Android uchun Apple veb-oqimi: Apple natijani shu manzilga POST qiladi,
 * biz uni ilovaga `intent://` orqali qaytaramiz (sign_in_with_apple plagini
 * hujjatidagi usul). Faqat `code`, `id_token`, `state`, `error` uzatiladi;
 * Apple bergan `user` (ism) uzatilmaydi va hech qayerda saqlanmaydi.
 */
export async function appleCallback(ctx: Ctx): Promise<Response> {
  if (!appleSignInConfigured(ctx.env) || !ctx.env.APPLE_SIGNIN_SERVICE_ID) throw notConfigured();
  const type = (ctx.req.headers.get('content-type') ?? '').toLowerCase();
  if (!type.startsWith('application/x-www-form-urlencoded')) throw new ApiError(415, 'unsupported_media_type');
  const buf = await ctx.req.arrayBuffer();
  if (buf.byteLength > 16 * 1024) throw new ApiError(413, 'too_large');
  const form = new URLSearchParams(new TextDecoder().decode(buf));
  const out = new URLSearchParams();
  for (const k of ['code', 'id_token', 'state', 'error']) {
    const v = form.get(k);
    if (v) out.set(k, v);
  }
  const pkg = DEFAULT_BUNDLE;
  return new Response(null, {
    status: 307,
    headers: {
      location: `intent://callback?${out.toString()}#Intent;package=${pkg};scheme=signinwithapple;end`,
      'cache-control': 'no-store',
      'referrer-policy': 'no-referrer',
    },
  });
}

// ---------------------------------------------------------- Apple revoke
async function appleClientSecret(ctx: Ctx, clientId: string): Promise<string> {
  const now = Math.floor(ctx.now / 1000);
  return signJwt(
    'ES256',
    ctx.env.APPLE_SIGNIN_PRIVATE_KEY!,
    { kid: ctx.env.APPLE_SIGNIN_KEY_ID },
    { iss: ctx.env.APPLE_SIGNIN_TEAM_ID, iat: now, exp: now + 300, aud: APPLE_ISSUER, sub: clientId },
  );
}

async function appleForm(ctx: Ctx, url: string, params: Record<string, string>): Promise<Response> {
  return doFetch(ctx)(url, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded', accept: 'application/json' },
    body: new URLSearchParams(params).toString(),
  });
}

export type RevokeOutcome =
  | 'revoked'
  | 'not_configured'
  | 'no_code'
  | 'sub_mismatch'
  | 'exchange_failed'
  | 'revoke_failed';

/**
 * Apple tokenini bekor qiladi: yangi `authorizationCode` → refresh token
 * (saqlanmaydi) → `/auth/revoke`. Hech qachon istisno tashlamaydi.
 */
export async function revokeAppleToken(ctx: Ctx, expectedSub: string, code: string | null): Promise<RevokeOutcome> {
  if (!appleSignInConfigured(ctx.env)) return 'not_configured';
  if (!code) return 'no_code';
  try {
    // iOS/macOS kodi bundle ID uchun, Android veb-oqimi kodi Services ID uchun beriladi.
    for (const clientId of appleAudiences(ctx.env)) {
      const secret = await appleClientSecret(ctx, clientId);
      const res = await appleForm(ctx, APPLE_TOKEN_URL, {
        client_id: clientId,
        client_secret: secret,
        code,
        grant_type: 'authorization_code',
      });
      if (!res.ok) continue;
      const tok = (await res.json()) as { refresh_token?: string; id_token?: string };
      if (!tok.refresh_token) return 'exchange_failed';
      // Apple'dan TLS orqali to'g'ridan-to'g'ri kelgan javob: faqat `sub` solishtiriladi.
      const sub = tok.id_token ? decodePart(tok.id_token.split('.')[1] ?? '').sub : null;
      if (sub !== expectedSub) return 'sub_mismatch';
      const rev = await appleForm(ctx, APPLE_REVOKE_URL, {
        client_id: clientId,
        client_secret: secret,
        token: tok.refresh_token,
        token_type_hint: 'refresh_token',
      });
      return rev.ok ? 'revoked' : 'revoke_failed';
    }
    return 'exchange_failed';
  } catch {
    return 'exchange_failed';
  }
}

/**
 * Hisobni o'chirishdan oldin: Apple identiteti bo'lsa tokenni bekor qiladi.
 * Natija `audit_log` ga (faqat ichki id va natija nomi) yoziladi; sozlama
 * yoki kod yo'q bo'lsa — hisob baribir o'chiriladi.
 *
 * [adminActor] — egasi admin panelidan o'chirganda (D-63): foydalanuvchining
 * yangi Apple `authorizationCode` i yo'q (Apple refresh tokeni serverda
 * saqlanmaydi), shuning uchun natija odatda `no_code`; tana o'qilmaydi.
 */
export async function revokeAppleOnDelete(ctx: Ctx, userId: string, adminActor?: string): Promise<void> {
  const apple = await ctx.db
    .prepare(`SELECT provider_sub FROM auth_identities WHERE user_id = ?1 AND provider = 'apple'`)
    .bind(userId)
    .all<{ provider_sub: string }>();
  if (apple.results.length === 0) return;

  let code: string | null = null;
  if (!adminActor && (ctx.req.headers.get('content-type') ?? '').toLowerCase().startsWith('application/json')) {
    try {
      const b = await readJson(ctx.req, 4096);
      if (typeof b.apple_authorization_code === 'string' && b.apple_authorization_code.length <= 2048) {
        code = b.apple_authorization_code;
      }
    } catch {
      code = null;
    }
  }
  let outcome: RevokeOutcome = 'no_code';
  for (const row of apple.results) {
    outcome = await revokeAppleToken(ctx, row.provider_sub, code);
    if (outcome === 'revoked') break;
  }
  if (outcome !== 'revoked') console.warn(`apple revoke skipped: ${outcome}`);
  await audit(ctx, adminActor ?? userId, 'apple_revoke', userId, adminActor ? { outcome, via: 'admin' } : { outcome });
}
