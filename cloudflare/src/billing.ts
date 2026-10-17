// Ilova ichidagi obunalar (D-46…D-53): App Store va Google Play xaridini
// serverda tekshirish, Pro huquqini hisobga bog'lash, do'kon bildirishnomalari.
//
// Tamoyillar:
// * Ilovadan faqat identifikator olinadi (App Store — transactionId,
//   Play — purchaseToken). Holat, mahsulot va muddat do'kon API'sidan
//   o'qiladi (TLS + bizning kalit bilan imzolangan so'rov).
// * Bildirishnomalar (ASSN v2 / RTDN) tanasiga ishonilmaydi: undan faqat
//   identifikator olinadi va holat do'kon API'sidan qayta o'qiladi.
// * Bitta xarid faqat bitta hisobga bog'lanadi (`owned_by_other`).
// * Kalitlar (secret) bo'lmasa — aniq `503 not_configured`; ilova to'lovni
//   "yoqilmagan" deb hisoblaydi va to'lov oynasini ko'rsatmaydi.

import { requireSession } from './auth';
import type { Ctx } from './context';
import { iso } from './context';
import { base64url, safeEqual, sha256Hex } from './crypto';
import { ApiError, badRequest, type Env, json, readJson } from './http';
import { hit } from './ratelimit';

export type Platform = 'app_store' | 'play_store';
export type Status = 'active' | 'grace_period' | 'billing_retry' | 'paused' | 'expired' | 'revoked';

/**
 * Do'kon mahsulotlari — ilovadagi `BillingCatalog` bilan bir xil
 * (lib/core/entitlements/billing_catalog.dart). `teacher` — Ustoz Pro.
 */
export const BILLING_PRODUCTS: Record<string, { tier: 'pro' | 'teacher'; student: boolean }> = {
  'uz.labguide.pro.monthly': { tier: 'pro', student: false },
  'uz.labguide.pro.yearly': { tier: 'pro', student: false },
  'uz.labguide.pro.student.monthly': { tier: 'pro', student: true },
  'uz.labguide.pro.student.yearly': { tier: 'pro', student: true },
  'uz.labguide.teacherpro.monthly': { tier: 'teacher', student: false },
  'uz.labguide.teacherpro.yearly': { tier: 'teacher', student: false },
};

const DEFAULT_BUNDLE = 'uz.labguide.app';
const MAX_RESTORE = 10;

/** Do'kondan tekshirilgan xarid (bitta obuna zanjiri). */
export interface Verified {
  platform: Platform;
  originalId: string;
  productId: string;
  status: Status;
  startedAt: number | null;
  expiresAt: number | null;
  ownership: 'purchased' | 'family_shared';
  environment: 'production' | 'sandbox';
  /** Do'kon hodisasi vaqti (eskiroq hodisa yangisini bosmaydi). */
  eventAt: number;
  latestToken: string;
  /** Xarid paytida ilova bergan hisob belgisi (appAccountToken / obfuscatedAccountId). */
  accountHint: string | null;
  /** Play: yangilash/almashtirishda oldingi token. */
  linkedToken?: string | null;
  /** Play: hali tasdiqlanmagan (acknowledge kerak). */
  needsAck?: boolean;
}

const doFetch = (ctx: Ctx): typeof fetch => ctx.deps.fetch ?? fetch;

export const appleConfigured = (env: Env) =>
  Boolean(env.APPLE_IAP_KEY_ID && env.APPLE_IAP_ISSUER_ID && env.APPLE_IAP_PRIVATE_KEY);
export const googleConfigured = (env: Env) => Boolean(env.GOOGLE_PLAY_SERVICE_ACCOUNT);

function configured(env: Env, platform: Platform): boolean {
  return platform === 'app_store' ? appleConfigured(env) : googleConfigured(env);
}

const notConfigured = () => new ApiError(503, 'not_configured');
const storeUnavailable = () => new ApiError(502, 'store_unavailable');

// ------------------------------------------------------------ JWT/JWS
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

export function b64urlDecode(s: string): string {
  const pad = s.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(pad + '='.repeat((4 - (pad.length % 4)) % 4));
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return new TextDecoder().decode(bytes);
}

/**
 * JWS (do'kon imzolagan) yuklamasini o'qiydi. Imzo zanjiri bu yerda
 * tekshirilmaydi: yuklama do'kon API'sidan TLS orqali, bizning kalit bilan
 * so'ralgan javobdan olinadi (bildirishnomalar esa qayta so'raladi).
 */
export function decodeJws<T = Record<string, unknown>>(jws: unknown): T {
  if (typeof jws !== 'string') throw badRequest('invalid_jws');
  const parts = jws.split('.');
  if (parts.length !== 3) throw badRequest('invalid_jws');
  try {
    return JSON.parse(b64urlDecode(parts[1])) as T;
  } catch {
    throw badRequest('invalid_jws');
  }
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
    throw new ApiError(503, 'store_key_invalid');
  }
  return `${data}.${base64url(new Uint8Array(sig))}`;
}

// ------------------------------------------------------------ App Store
const APPLE_HOSTS = {
  production: 'https://api.storekit.itunes.apple.com',
  sandbox: 'https://api.storekit-sandbox.itunes.apple.com',
} as const;

interface AppleTransaction {
  transactionId?: string;
  originalTransactionId?: string;
  bundleId?: string;
  productId?: string;
  type?: string;
  purchaseDate?: number;
  originalPurchaseDate?: number;
  expiresDate?: number;
  revocationDate?: number;
  inAppOwnershipType?: string;
  environment?: string;
  appAccountToken?: string;
  signedDate?: number;
}

async function appleJwt(ctx: Ctx): Promise<string> {
  const now = Math.floor(ctx.now / 1000);
  return signJwt(
    'ES256',
    ctx.env.APPLE_IAP_PRIVATE_KEY!,
    { kid: ctx.env.APPLE_IAP_KEY_ID },
    {
      iss: ctx.env.APPLE_IAP_ISSUER_ID,
      iat: now,
      exp: now + 15 * 60,
      aud: 'appstoreconnect-v1',
      bid: ctx.env.APPLE_BUNDLE_ID || DEFAULT_BUNDLE,
    },
  );
}

/** Avval production, topilmasa (4040010) — sandbox (Apple tavsiyasi). */
async function appleGet(ctx: Ctx, path: string, jwt: string): Promise<{ env: 'production' | 'sandbox'; body: any }> {
  for (const env of ['production', 'sandbox'] as const) {
    let res: Response;
    try {
      res = await doFetch(ctx)(`${APPLE_HOSTS[env]}${path}`, {
        headers: { authorization: `Bearer ${jwt}`, accept: 'application/json' },
      });
    } catch {
      throw storeUnavailable();
    }
    if (res.ok) return { env, body: await res.json() };
    if (res.status === 404 && env === 'production') continue;
    if (res.status === 404 || res.status === 400) throw badRequest('purchase_not_found');
    if (res.status === 401) throw new ApiError(503, 'store_auth_failed');
    throw storeUnavailable();
  }
  throw badRequest('purchase_not_found');
}

const APPLE_STATUS: Record<number, Status> = {
  1: 'active',
  2: 'expired',
  3: 'billing_retry',
  4: 'grace_period',
  5: 'revoked',
};

export async function verifyApple(ctx: Ctx, transactionId: string, expectedProduct?: string): Promise<Verified> {
  if (!appleConfigured(ctx.env)) throw notConfigured();
  if (!/^\d{1,32}$/.test(transactionId)) throw badRequest('invalid_token');
  const jwt = await appleJwt(ctx);
  const bundle = ctx.env.APPLE_BUNDLE_ID || DEFAULT_BUNDLE;

  const tx = await appleGet(ctx, `/inApps/v1/transactions/${transactionId}`, jwt);
  const info = decodeJws<AppleTransaction>(tx.body?.signedTransactionInfo);
  if (info.bundleId !== bundle) throw badRequest('wrong_bundle');
  if (!info.productId || !BILLING_PRODUCTS[info.productId]) throw badRequest('unknown_product');
  if (expectedProduct && expectedProduct !== info.productId) throw badRequest('product_mismatch');
  const originalId = String(info.originalTransactionId ?? '');
  if (!originalId) throw badRequest('purchase_not_found');

  // Obuna holati (faol / grace / billing retry / tugagan / qaytarilgan).
  const subs = await appleGet(ctx, `/inApps/v1/subscriptions/${transactionId}`, jwt);
  let status: Status | null = null;
  let latest = info;
  for (const group of (subs.body?.data as any[]) ?? []) {
    for (const last of (group?.lastTransactions as any[]) ?? []) {
      if (String(last?.originalTransactionId) !== originalId) continue;
      status = APPLE_STATUS[Number(last.status)] ?? null;
      const t = decodeJws<AppleTransaction>(last.signedTransactionInfo);
      if (t.bundleId === bundle && t.productId && BILLING_PRODUCTS[t.productId]) latest = t;
    }
  }
  if (!status) {
    // Holat ro'yxatda yo'q — muddatdan hisoblanadi (hech qachon ko'proq bermaydi).
    status = latest.expiresDate && latest.expiresDate > ctx.now ? 'active' : 'expired';
  }
  if (latest.revocationDate) status = 'revoked';
  return {
    platform: 'app_store',
    originalId,
    productId: latest.productId!,
    status,
    startedAt: latest.originalPurchaseDate ?? info.originalPurchaseDate ?? latest.purchaseDate ?? null,
    expiresAt: latest.expiresDate ?? null,
    ownership: latest.inAppOwnershipType === 'FAMILY_SHARED' ? 'family_shared' : 'purchased',
    environment: (latest.environment ?? tx.env).toLowerCase() === 'sandbox' ? 'sandbox' : 'production',
    eventAt: latest.signedDate ?? ctx.now,
    latestToken: String(latest.transactionId ?? transactionId),
    accountHint: latest.appAccountToken?.toLowerCase() ?? info.appAccountToken?.toLowerCase() ?? null,
  };
}

// ------------------------------------------------------------ Google Play
interface ServiceAccount {
  client_email: string;
  private_key: string;
  token_uri?: string;
}

let googleToken: { key: string; token: string; exp: number } | null = null;

function serviceAccount(env: Env): ServiceAccount {
  try {
    const sa = JSON.parse(env.GOOGLE_PLAY_SERVICE_ACCOUNT!) as ServiceAccount;
    if (!sa.client_email || !sa.private_key) throw new Error('fields');
    return sa;
  } catch {
    throw new ApiError(503, 'store_key_invalid');
  }
}

async function googleAccessToken(ctx: Ctx): Promise<string> {
  const sa = serviceAccount(ctx.env);
  if (googleToken && googleToken.key === sa.client_email && googleToken.exp > ctx.now + 60_000) {
    return googleToken.token;
  }
  const aud = sa.token_uri || 'https://oauth2.googleapis.com/token';
  const now = Math.floor(ctx.now / 1000);
  const assertion = await signJwt('RS256', sa.private_key, {}, {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/androidpublisher',
    aud,
    iat: now,
    exp: now + 3600,
  });
  let res: Response;
  try {
    res = await doFetch(ctx)(aud, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: `grant_type=${encodeURIComponent('urn:ietf:params:oauth:grant-type:jwt-bearer')}&assertion=${assertion}`,
    });
  } catch {
    throw storeUnavailable();
  }
  if (!res.ok) throw new ApiError(503, 'store_auth_failed');
  const body = (await res.json()) as { access_token?: string; expires_in?: number };
  if (!body.access_token) throw new ApiError(503, 'store_auth_failed');
  googleToken = { key: sa.client_email, token: body.access_token, exp: ctx.now + (body.expires_in ?? 3600) * 1000 };
  return body.access_token;
}

const playBase = (env: Env) =>
  `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(
    env.GOOGLE_PLAY_PACKAGE || DEFAULT_BUNDLE,
  )}/purchases`;

const PLAY_STATUS: Record<string, Status> = {
  SUBSCRIPTION_STATE_ACTIVE: 'active',
  // Avtomatik yangilash bekor qilingan, lekin to'langan muddat tugamagan.
  SUBSCRIPTION_STATE_CANCELED: 'active',
  SUBSCRIPTION_STATE_IN_GRACE_PERIOD: 'grace_period',
  SUBSCRIPTION_STATE_ON_HOLD: 'billing_retry',
  SUBSCRIPTION_STATE_PAUSED: 'paused',
  SUBSCRIPTION_STATE_EXPIRED: 'expired',
};

export async function verifyGoogle(ctx: Ctx, token: string, expectedProduct?: string): Promise<Verified> {
  if (!googleConfigured(ctx.env)) throw notConfigured();
  if (!/^[A-Za-z0-9._:-]{10,1024}$/.test(token)) throw badRequest('invalid_token');
  const access = await googleAccessToken(ctx);
  let res: Response;
  try {
    res = await doFetch(ctx)(`${playBase(ctx.env)}/subscriptionsv2/tokens/${encodeURIComponent(token)}`, {
      headers: { authorization: `Bearer ${access}`, accept: 'application/json' },
    });
  } catch {
    throw storeUnavailable();
  }
  if (res.status === 404 || res.status === 400 || res.status === 410) throw badRequest('purchase_not_found');
  if (res.status === 401 || res.status === 403) throw new ApiError(503, 'store_auth_failed');
  if (!res.ok) throw storeUnavailable();
  const sub = (await res.json()) as any;

  const items = ((sub.lineItems as any[]) ?? []).filter((i) => i?.productId && BILLING_PRODUCTS[i.productId]);
  if (items.length === 0) throw badRequest('unknown_product');
  const item = (expectedProduct ? items.find((i) => i.productId === expectedProduct) : null) ?? items[0];
  if (expectedProduct && item.productId !== expectedProduct) throw badRequest('product_mismatch');

  const state = String(sub.subscriptionState ?? '');
  if (state === 'SUBSCRIPTION_STATE_PENDING') throw new ApiError(409, 'purchase_pending');
  const status = PLAY_STATUS[state];
  if (!status) throw badRequest('purchase_not_found');
  const expiresAt = item.expiryTime ? Date.parse(item.expiryTime) : null;
  const startedAt = sub.startTime ? Date.parse(sub.startTime) : null;
  return {
    platform: 'play_store',
    originalId: token,
    productId: item.productId,
    status,
    startedAt: Number.isFinite(startedAt) ? startedAt : null,
    expiresAt: Number.isFinite(expiresAt) ? expiresAt : null,
    ownership: 'purchased',
    environment: sub.testPurchase ? 'sandbox' : 'production',
    // Play javobida hodisa vaqti yo'q — tekshiruv vaqti (har doim yangi holat).
    eventAt: ctx.now,
    latestToken: token,
    accountHint: sub.externalAccountIdentifiers?.obfuscatedExternalAccountId ?? null,
    linkedToken: sub.linkedPurchaseToken ?? null,
    needsAck: sub.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING',
  };
}

/** Play: xarid 3 kun ichida tasdiqlanmasa Google pulni qaytaradi — serverda. */
async function acknowledgeGoogle(ctx: Ctx, v: Verified): Promise<void> {
  try {
    const access = await googleAccessToken(ctx);
    const res = await doFetch(ctx)(
      `${playBase(ctx.env)}/subscriptions/${encodeURIComponent(v.productId)}/tokens/${encodeURIComponent(v.latestToken)}:acknowledge`,
      {
        method: 'POST',
        headers: { authorization: `Bearer ${access}`, 'content-type': 'application/json' },
        body: '{}',
      },
    );
    if (!res.ok) console.error('play acknowledge failed', res.status);
  } catch (e) {
    // Ilova ham `completePurchase` bilan tasdiqlaydi — bu yerda xato fatal emas.
    console.error('play acknowledge error', e instanceof Error ? e.name : typeof e);
  }
}

// ------------------------------------------------------------ saqlash
/** Ilova xaridda bergan hisob belgisi (Play `obfuscatedAccountId`). */
export const accountHintFor = async (platform: Platform, userId: string) =>
  platform === 'app_store' ? userId.toLowerCase() : await sha256Hex(userId);

/**
 * Xaridni hisobga yozadi. Boshqa hisobga bog'langan bo'lsa — o'zgartirmaydi
 * va `false` qaytaradi (`owned_by_other`).
 */
async function claim(ctx: Ctx, userId: string, v: Verified): Promise<boolean> {
  // Xarid paytida boshqa hisob belgisi qo'yilgan — bu hisob uni ololmaydi.
  if (v.accountHint && v.accountHint !== (await accountHintFor(v.platform, userId))) return false;
  // Play: yangilash/almashtirish — zanjir boshi (asl qator) saqlanadi.
  let originalId = v.originalId;
  if (v.linkedToken) {
    const prev = await ctx.db
      .prepare('SELECT original_transaction_id FROM entitlements WHERE platform = ?1 AND latest_token = ?2')
      .bind(v.platform, v.linkedToken)
      .first<{ original_transaction_id: string }>();
    if (prev) originalId = prev.original_transaction_id;
  }
  await ctx.db
    .prepare(
      `INSERT INTO entitlements (platform, original_transaction_id, user_id, product_id, status, started_at,
         expires_at, ownership, environment, latest_token, event_at, updated_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12)
       ON CONFLICT (platform, original_transaction_id) DO UPDATE SET
         product_id = excluded.product_id, status = excluded.status, started_at = excluded.started_at,
         expires_at = excluded.expires_at, ownership = excluded.ownership, environment = excluded.environment,
         latest_token = excluded.latest_token, event_at = excluded.event_at, updated_at = excluded.updated_at
       WHERE entitlements.user_id = excluded.user_id AND entitlements.event_at <= excluded.event_at`,
    )
    .bind(
      v.platform,
      originalId,
      userId,
      v.productId,
      v.status,
      v.startedAt,
      v.expiresAt,
      v.ownership,
      v.environment,
      v.latestToken,
      v.eventAt,
      ctx.now,
    )
    .run();
  const row = await ctx.db
    .prepare('SELECT user_id FROM entitlements WHERE platform = ?1 AND original_transaction_id = ?2')
    .bind(v.platform, originalId)
    .first<{ user_id: string }>();
  return row?.user_id === userId;
}

/** Bildirishnoma: faqat mavjud qatorni (egasi o'zgarmaydi) yangilaydi. */
async function applyUpdate(ctx: Ctx, v: Verified): Promise<boolean> {
  const r = await ctx.db
    .prepare(
      `UPDATE entitlements SET product_id = ?3, status = ?4, started_at = ?5, expires_at = ?6, ownership = ?7,
         environment = ?8, latest_token = ?9, event_at = ?10, updated_at = ?11
       WHERE platform = ?1 AND (original_transaction_id = ?2 OR latest_token = ?12) AND event_at <= ?10`,
    )
    .bind(
      v.platform,
      v.originalId,
      v.productId,
      v.status,
      v.startedAt,
      v.expiresAt,
      v.ownership,
      v.environment,
      v.latestToken,
      v.eventAt,
      ctx.now,
      v.linkedToken ?? v.latestToken,
    )
    .run();
  return (r.meta.changes ?? 0) > 0;
}

async function snapshot(ctx: Ctx, userId: string, ownedByOther = false): Promise<Response> {
  const rows = await ctx.db
    .prepare(
      `SELECT product_id, platform, status, started_at, expires_at, ownership, environment, updated_at
       FROM entitlements WHERE user_id = ?1 ORDER BY COALESCE(expires_at, 0) DESC`,
    )
    .bind(userId)
    .all<{
      product_id: string;
      platform: string;
      status: string;
      started_at: number | null;
      expires_at: number | null;
      ownership: string;
      environment: string;
      updated_at: number;
    }>();
  return json({
    server_time: iso(ctx.now),
    items: rows.results.map((r) => ({
      product_id: r.product_id,
      platform: r.platform,
      status: r.status,
      started_at: iso(r.started_at),
      expires_at: iso(r.expires_at),
      ownership: r.ownership,
      environment: r.environment,
      updated_at: iso(r.updated_at),
    })),
    owned_by_other: ownedByOther,
  });
}

// ------------------------------------------------------------ endpointlar
/** Ochiq: to'lov serverda sozlanganmi (ilova to'lov oynasini shunga qarab ko'rsatadi). */
export async function status(ctx: Ctx): Promise<Response> {
  return json({ app_store: appleConfigured(ctx.env), play_store: googleConfigured(ctx.env) });
}

export async function entitlements(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  return snapshot(ctx, s.userId);
}

function parsePlatform(raw: unknown): Platform {
  if (raw === 'app_store' || raw === 'play_store') return raw;
  throw badRequest('invalid_platform');
}

function parseToken(raw: unknown): string {
  if (typeof raw !== 'string' || raw.length < 1 || raw.length > 1024) throw badRequest('invalid_token');
  return raw;
}

function parseProduct(raw: unknown): string | undefined {
  if (raw == null) return undefined;
  if (typeof raw !== 'string' || !BILLING_PRODUCTS[raw]) throw badRequest('unknown_product');
  return raw;
}

/**
 * POST /v1/billing/verify — xarid yoki tiklash.
 * `{platform, product_id, token}` yoki `{platform, purchases: [{product_id, token}]}`.
 */
export async function verify(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const body = await readJson(ctx.req);
  const platform = parsePlatform(body.platform);
  if (!configured(ctx.env, platform)) throw notConfigured();
  await hit(ctx.db, `billing-user:${(await sha256Hex(s.userId)).slice(0, 32)}`, 30, 3600, ctx.now);
  await hit(ctx.db, `billing-ip:${ctx.ipTag}`, 120, 3600, ctx.now);

  const list = Array.isArray(body.purchases)
    ? (body.purchases as unknown[]).map((p) => {
        const o = (p ?? {}) as Record<string, unknown>;
        return { productId: parseProduct(o.product_id), token: parseToken(o.token) };
      })
    : [{ productId: parseProduct(body.product_id), token: parseToken(body.token) }];
  if (list.length === 0 || list.length > MAX_RESTORE) throw badRequest('invalid_purchases');

  let ownedByOther = false;
  let verified = 0;
  let lastError: ApiError | null = null;
  for (const p of list) {
    let v: Verified;
    try {
      v = platform === 'app_store' ? await verifyApple(ctx, p.token, p.productId) : await verifyGoogle(ctx, p.token, p.productId);
    } catch (e) {
      // Tiklashda bitta yaroqsiz xarid qolganlarini to'xtatmaydi.
      if (e instanceof ApiError && list.length > 1 && e.status < 500) {
        lastError = e;
        continue;
      }
      throw e;
    }
    verified++;
    if (await claim(ctx, s.userId, v)) {
      if (v.platform === 'play_store' && v.needsAck && (v.status === 'active' || v.status === 'grace_period')) {
        await acknowledgeGoogle(ctx, v);
      }
    } else {
      ownedByOther = true;
    }
  }
  if (verified === 0 && lastError) throw lastError;
  return snapshot(ctx, s.userId, ownedByOther);
}

/**
 * App Store Server Notifications v2. Tanadagi `signedPayload` dan faqat
 * transactionId olinadi; holat App Store Server API'dan qayta o'qiladi.
 */
export async function appleNotification(ctx: Ctx): Promise<Response> {
  if (!appleConfigured(ctx.env)) throw notConfigured();
  await hit(ctx.db, `billing-assn:${ctx.ipTag}`, 600, 3600, ctx.now);
  const body = await readJson(ctx.req);
  const payload = decodeJws<{ data?: { bundleId?: string; signedTransactionInfo?: string } }>(body.signedPayload);
  const bundle = ctx.env.APPLE_BUNDLE_ID || DEFAULT_BUNDLE;
  if (!payload.data?.signedTransactionInfo || payload.data.bundleId !== bundle) {
    // Bizga tegishli emas yoki tranzaksiyasiz (masalan, TEST) — qayta yuborilmasin.
    return json({ ok: true, ignored: true });
  }
  const hinted = decodeJws<AppleTransaction>(payload.data.signedTransactionInfo);
  const id = String(hinted.transactionId ?? '');
  if (!/^\d{1,32}$/.test(id)) return json({ ok: true, ignored: true });
  let v: Verified;
  try {
    v = await verifyApple(ctx, id);
  } catch (e) {
    if (e instanceof ApiError && e.status < 500) return json({ ok: true, ignored: true });
    throw e;
  }
  let updated = await applyUpdate(ctx, v);
  if (!updated && v.accountHint) {
    // Ilova hali tekshirtirmagan xarid: appAccountToken — mavjud hisob id si.
    const user = await ctx.db.prepare('SELECT id FROM users WHERE id = ?1').bind(v.accountHint).first<{ id: string }>();
    if (user) updated = await claim(ctx, user.id, v);
  }
  return json({ ok: true, updated });
}

/**
 * Google Play RTDN (Pub/Sub push). Sozlangan bo'lsa `?token=` tekshiriladi;
 * holat baribir Play Developer API'dan qayta o'qiladi.
 */
export async function googleNotification(ctx: Ctx): Promise<Response> {
  if (!googleConfigured(ctx.env)) throw notConfigured();
  const expected = ctx.env.PLAY_RTDN_TOKEN ?? '';
  if (expected) {
    const got = new URL(ctx.req.url).searchParams.get('token') ?? '';
    if (!safeEqual(got, expected)) throw new ApiError(403, 'forbidden');
  }
  await hit(ctx.db, `billing-rtdn:${ctx.ipTag}`, 600, 3600, ctx.now);
  const body = await readJson(ctx.req);
  const message = (body.message ?? {}) as { data?: string };
  let n: any;
  try {
    n = JSON.parse(b64urlDecode(String(message.data ?? '')));
  } catch {
    return json({ ok: true, ignored: true });
  }
  if (n?.packageName !== (ctx.env.GOOGLE_PLAY_PACKAGE || DEFAULT_BUNDLE)) return json({ ok: true, ignored: true });
  const token: unknown = n.subscriptionNotification?.purchaseToken ?? n.voidedPurchaseNotification?.purchaseToken;
  if (typeof token !== 'string') return json({ ok: true, ignored: true });
  let v: Verified;
  try {
    v = await verifyGoogle(ctx, token);
  } catch (e) {
    if (e instanceof ApiError && e.status < 500) return json({ ok: true, ignored: true });
    throw e;
  }
  // Qaytarilgan xarid: Play holati ham huquq bermasa — `revoked` (davr hisoblanmaydi).
  if (n.voidedPurchaseNotification && v.status !== 'active' && v.status !== 'grace_period') {
    v = { ...v, status: 'revoked' };
  }
  const updated = await applyUpdate(ctx, v);
  return json({ ok: true, updated });
}
