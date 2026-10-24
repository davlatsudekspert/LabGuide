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
// * Kalitlar (secret) bo'lmasa — aniq `503 store_verifier_not_configured`;
//   ilova to'lovni "yoqilmagan" deb hisoblaydi va to'lov oynasini ko'rsatmaydi.
// * Tekshiruvchilar INJEKSIYA qilinadi (`deps.storeVerifiers`, D-75): testlarda
//   soxta, production'da quyidagi haqiqiy App Store Server API / Play Developer
//   API tekshiruvchilari.
// * Sandbox (Apple Sandbox, Play litsenziya testeri) faqat
//   `LG_BILLING_SANDBOX=true` bo'lsa qabul qilinadi (D-75).
//
// Rasmiy hujjatlar (2026-10-24):
// * App Store Server API — Get Transaction Info / Get All Subscription Statuses:
//   https://developer.apple.com/documentation/appstoreserverapi
// * App Store Server Notifications V2 (notificationType, subtype, notificationUUID):
//   https://developer.apple.com/documentation/appstoreservernotifications
// * Play Developer API purchases.subscriptionsv2.get va acknowledge:
//   https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2
//   https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions/acknowledge
// * RTDN: https://developer.android.com/google/play/billing/rtdn-reference
//   (messageId bo'yicha takrorni tashlash, holatni doim subscriptionsv2.get dan o'qish).

import { audit, requireSession } from './auth';
import type { Ctx } from './context';
import { iso } from './context';
import { base64url, safeEqual, sha256Hex } from './crypto';
import { ApiError, badRequest, type Env, json, readJson } from './http';
import { hit } from './ratelimit';
import { verifyGooglePushJwt } from './social';
import { trialStatus } from './trial';
import { JwsError, verifyAppleJws } from './x509';

export type Platform = 'app_store' | 'play_store';
export type Status = 'active' | 'grace_period' | 'billing_retry' | 'paused' | 'expired' | 'revoked';

/** Pullik daraja (D-73): Talaba, Ustoz, Mutaxassis. Tartib = narx tartibi. */
export type Plan = 'student' | 'teacher' | 'specialist';
export const PLAN_RANK: Record<Plan, number> = { student: 1, teacher: 2, specialist: 3 };
export const PLANS = Object.keys(PLAN_RANK) as Plan[];

/**
 * Do'kon mahsulotlari — ilovadagi `BillingCatalog` bilan bir xil
 * (lib/core/entitlements/billing_catalog.dart). Do'konda hali HECH QANDAY
 * mahsulot yaratilmagan (D-73); eski (D-46) id'lar mos yangi darajaga
 * ALIAS sifatida qoldi: pro → specialist, pro.student → student,
 * teacherpro → teacher.
 */
export const BILLING_PRODUCTS: Record<string, { plan: Plan }> = {
  'uz.labguide.student.monthly': { plan: 'student' },
  'uz.labguide.student.yearly': { plan: 'student' },
  'uz.labguide.teacher.monthly': { plan: 'teacher' },
  'uz.labguide.teacher.yearly': { plan: 'teacher' },
  'uz.labguide.specialist.monthly': { plan: 'specialist' },
  'uz.labguide.specialist.yearly': { plan: 'specialist' },
  // Eski id'lar (D-46…D-72) — alias.
  'uz.labguide.pro.monthly': { plan: 'specialist' },
  'uz.labguide.pro.yearly': { plan: 'specialist' },
  'uz.labguide.pro.student.monthly': { plan: 'student' },
  'uz.labguide.pro.student.yearly': { plan: 'student' },
  'uz.labguide.teacherpro.monthly': { plan: 'teacher' },
  'uz.labguide.teacherpro.yearly': { plan: 'teacher' },
};

/**
 * Google Play: bitta obuna (masalan `uz.labguide.student`) ichida ikkita base
 * plan — `monthly` (P1M) va `yearly` (P1Y) (docs/PRO_BILLING_PLAN.md §2,
 * STORE_SETUP_STEPS B.2–B.3). Ilova va server ichida KANONIK id ishlatiladi:
 * `<obuna>.<base plan>` = `uz.labguide.student.monthly` — App Store mahsulot
 * id si bilan bir xil. Play'da 6 ta alohida obuna yaratilsa ham (har birida
 * bitta base plan) o'sha id'lar mos keladi.
 */
export const PLAY_SUBSCRIPTIONS: Record<string, Plan> = {
  'uz.labguide.student': 'student',
  'uz.labguide.teacher': 'teacher',
  'uz.labguide.specialist': 'specialist',
};
export const PLAY_BASE_PLANS = ['monthly', 'yearly'] as const;

/** Do'kon (product, basePlan) → kanonik id; noma'lum bo'lsa `null`. */
export function canonicalProduct(productId: string, basePlanId?: string | null): string | null {
  if (BILLING_PRODUCTS[productId]) return productId;
  if (PLAY_SUBSCRIPTIONS[productId] && basePlanId && (PLAY_BASE_PLANS as readonly string[]).includes(basePlanId)) {
    return `${productId}.${basePlanId}`;
  }
  return null;
}

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
  /** Play: do'kondagi obuna id si (acknowledge yo'li uchun; kanonik id emas). */
  storeProductId?: string;
}

/**
 * Do'kon xaridini tekshiruvchi (D-75) — injeksiya qilinadi
 * (`ctx.deps.storeVerifiers`). Haqiqiy: [AppStoreServerApiVerifier],
 * [PlayDeveloperApiVerifier]; testlarda soxta (test/fake_store.ts).
 */
export interface StoreVerifier {
  /** Kalitlar sozlanganmi. `false` → `503 store_verifier_not_configured`. */
  configured(env: Env): boolean;
  /** Identifikator (App Store transactionId / Play purchaseToken) bo'yicha holat. */
  verify(ctx: Ctx, token: string, expectedProduct?: string): Promise<Verified>;
  /** Play: serverda tasdiqlash (ixtiyoriy). */
  acknowledge?(ctx: Ctx, v: Verified): Promise<void>;
}

const doFetch = (ctx: Ctx): typeof fetch => ctx.deps.fetch ?? fetch;

export const appleConfigured = (env: Env) =>
  Boolean(env.APPLE_IAP_KEY_ID && env.APPLE_IAP_ISSUER_ID && env.APPLE_IAP_PRIVATE_KEY);
export const googleConfigured = (env: Env) => Boolean(env.GOOGLE_PLAY_SERVICE_ACCOUNT);

/** Sandbox / test xaridlari qabul qilinadimi (faqat `LG_BILLING_SANDBOX=true`). */
export const sandboxAllowed = (env: Env) => env.LG_BILLING_SANDBOX === 'true';

export function verifierFor(ctx: Ctx, platform: Platform): StoreVerifier {
  return (
    ctx.deps.storeVerifiers?.[platform] ??
    (platform === 'app_store' ? AppStoreServerApiVerifier : PlayDeveloperApiVerifier)
  );
}

function configured(ctx: Ctx, platform: Platform): boolean {
  return verifierFor(ctx, platform).configured(ctx.env);
}

const notConfigured = () => new ApiError(503, 'store_verifier_not_configured');
const sandboxRejected = () => new ApiError(403, 'sandbox_not_allowed');

/** Tekshiruvdan keyingi umumiy qoida: production'da sandbox xaridi rad. */
function acceptEnvironment(ctx: Ctx, v: Verified): Verified {
  if (v.environment === 'sandbox' && !sandboxAllowed(ctx.env)) throw sandboxRejected();
  return v;
}
const storeUnavailable = () => new ApiError(502, 'store_unavailable');

// ------------------------------------------------------------ JWT/JWS
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

function b64urlDecode(s: string): string {
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

/** Apple JWS: x5c zanjiri (Apple Root CA - G3 pin) + ES256 imzo (src/x509.ts). */
async function appleJws<T>(ctx: Ctx, jws: unknown): Promise<T> {
  try {
    return await verifyAppleJws<T>(jws, { rootSha256: ctx.env.APPLE_ROOT_CA_SHA256, at: ctx.now });
  } catch (e) {
    if (e instanceof JwsError) throw new ApiError(401, 'invalid_signature');
    throw e;
  }
}

async function signJwt(
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

/**
 * Avval production, topilmasa (4040010) — sandbox (Apple tavsiyasi), LEKIN
 * sandbox faqat `LG_BILLING_SANDBOX=true` bo'lsa so'raladi (D-75).
 */
async function appleGet(ctx: Ctx, path: string, jwt: string): Promise<{ env: 'production' | 'sandbox'; body: any }> {
  const envs = sandboxAllowed(ctx.env) ? (['production', 'sandbox'] as const) : (['production'] as const);
  for (const env of envs) {
    let res: Response;
    try {
      res = await doFetch(ctx)(`${APPLE_HOSTS[env]}${path}`, {
        headers: { authorization: `Bearer ${jwt}`, accept: 'application/json' },
      });
    } catch {
      throw storeUnavailable();
    }
    if (res.ok) return { env, body: await res.json() };
    if (res.status === 404 && env === 'production' && envs.length > 1) continue;
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
  // Javob TLS orqali kelgan bo'lsa ham imzo tekshiriladi (Apple tavsiyasi).
  const info = await appleJws<AppleTransaction>(ctx, tx.body?.signedTransactionInfo);
  if (info.bundleId !== bundle) throw badRequest('wrong_bundle');
  if (!info.productId || !BILLING_PRODUCTS[info.productId]) throw badRequest('unknown_product');
  if (expectedProduct && expectedProduct !== info.productId) throw badRequest('product_mismatch');
  checkEnvironment(info.environment, tx.env);
  const group = ctx.env.APPLE_SUBSCRIPTION_GROUP_ID;
  const originalId = String(info.originalTransactionId ?? '');
  if (!originalId) throw badRequest('purchase_not_found');

  // Obuna holati (faol / grace / billing retry / tugagan / qaytarilgan).
  const subs = await appleGet(ctx, `/inApps/v1/subscriptions/${transactionId}`, jwt);
  let status: Status | null = null;
  let latest = info;
  for (const g of (subs.body?.data as any[]) ?? []) {
    if (group && String(g?.subscriptionGroupIdentifier) !== group) continue;
    for (const last of (g?.lastTransactions as any[]) ?? []) {
      if (String(last?.originalTransactionId) !== originalId) continue;
      status = APPLE_STATUS[Number(last.status)] ?? null;
      const t = await appleJws<AppleTransaction>(ctx, last.signedTransactionInfo);
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
    environment: (latest.environment ?? tx.env).toLowerCase() === 'production' ? 'production' : 'sandbox',
    eventAt: latest.signedDate ?? ctx.now,
    latestToken: String(latest.transactionId ?? transactionId),
    accountHint: latest.appAccountToken?.toLowerCase() ?? info.appAccountToken?.toLowerCase() ?? null,
  };
}

/**
 * Tranzaksiya `environment` (`Production` / `Sandbox` / `Xcode` /
 * `LocalTesting`) so'ralgan host bilan mos bo'lishi shart; production host
 * javobidagi sandbox tranzaksiya — rad.
 */
function checkEnvironment(txEnv: string | undefined, host: 'production' | 'sandbox'): void {
  const e = (txEnv ?? '').toLowerCase();
  if (host === 'production' && e !== 'production') throw badRequest('environment_mismatch');
  if (host === 'sandbox' && e !== 'sandbox') throw badRequest('environment_mismatch');
}

/** App Store Server API tekshiruvchisi (haqiqiy). Kalitsiz — 503. */
export const AppStoreServerApiVerifier: StoreVerifier = {
  configured: appleConfigured,
  verify: verifyApple,
};

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

  const items = ((sub.lineItems as any[]) ?? [])
    .map((i) => ({ ...i, canonical: i?.productId ? canonicalProduct(String(i.productId), i.offerDetails?.basePlanId) : null }))
    .filter((i) => i.canonical);
  if (items.length === 0) throw badRequest('unknown_product');
  const item = (expectedProduct ? items.find((i) => i.canonical === expectedProduct) : null) ?? items[0];
  if (expectedProduct && item.canonical !== expectedProduct) throw badRequest('product_mismatch');

  const state = String(sub.subscriptionState ?? '');
  if (state === 'SUBSCRIPTION_STATE_PENDING') throw new ApiError(409, 'purchase_pending');
  const status = PLAY_STATUS[state];
  if (!status) throw badRequest('purchase_not_found');
  const expiresAt = item.expiryTime ? Date.parse(item.expiryTime) : null;
  const startedAt = sub.startTime ? Date.parse(sub.startTime) : null;
  return {
    platform: 'play_store',
    originalId: token,
    productId: item.canonical,
    storeProductId: String(item.productId),
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
      `${playBase(ctx.env)}/subscriptions/${encodeURIComponent(v.storeProductId ?? v.productId)}/tokens/${encodeURIComponent(v.latestToken)}:acknowledge`,
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

/** Play Developer API tekshiruvchisi (haqiqiy). Kalitsiz — 503. */
export const PlayDeveloperApiVerifier: StoreVerifier = {
  configured: googleConfigured,
  verify: verifyGoogle,
  acknowledge: acknowledgeGoogle,
};

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

/** Huquq manbai: do'kon obunasi, admin grant (D-73) yoki bepul sinov (D-74). */
export type AccessSource = 'store' | 'admin_grant' | 'trial';

export interface AccessItem {
  source: AccessSource;
  plan: Plan;
  /** Huquq beradigan holatdami (do'kon: active/grace_period; grant/sinov: bekor qilinmagan). */
  granting: boolean;
  expiresAt: number | null;
}

export interface ResolvedAccess {
  source: AccessSource;
  plan: Plan;
  expiresAt: number | null;
}

/**
 * Huquqni hal qilish: faqat HOZIR amal qilayotganlar orasidan eng yuqori
 * daraja, tenglikda eng uzoq muddat (`null` = muddatsiz eng uzoq), to'liq
 * tenglikda DO'KON. Admin grant do'kon obunasini hech qachon bosib o'tmaydi
 * va uning o'rnini egallamaydi (obuna alohida qator bo'lib qoladi).
 *
 * Bepul sinov (D-74, `trial`) PULLIK obunani hech qachon bosib o'tmaydi:
 * amaldagi do'kon obunasi bo'lsa sinov qatori hisobga olinmaydi; tenglikda
 * ham sinov yutqazadi. Muddati o'tgan sinov hech narsa bermaydi.
 */
export function resolveAccess(items: AccessItem[], now: number): ResolvedAccess | null {
  let live = items.filter((i) => i.granting && (i.expiresAt == null || i.expiresAt > now));
  if (live.some((i) => i.source === 'store')) live = live.filter((i) => i.source !== 'trial');
  const end = (i: AccessItem) => i.expiresAt ?? Number.POSITIVE_INFINITY;
  // Tenglikda ustunlik: do'kon > admin grant > sinov.
  const prio = (i: AccessItem) => (i.source === 'store' ? 2 : i.source === 'admin_grant' ? 1 : 0);
  let best: AccessItem | null = null;
  for (const i of live) {
    if (
      !best ||
      PLAN_RANK[i.plan] > PLAN_RANK[best.plan] ||
      (PLAN_RANK[i.plan] === PLAN_RANK[best.plan] &&
        (end(i) > end(best) || (end(i) === end(best) && prio(i) > prio(best))))
    ) {
      best = i;
    }
  }
  return best && { source: best.source, plan: best.plan, expiresAt: best.expiresAt };
}

interface StoreRow {
  product_id: string;
  platform: string;
  status: string;
  started_at: number | null;
  expires_at: number | null;
  ownership: string;
  environment: string;
  updated_at: number;
}
interface GrantRow {
  tier: Plan;
  starts_at: number;
  expires_at: number | null;
  updated_at: number;
}
interface TrialRow {
  tier: Plan;
  started_at: number;
  expires_at: number;
}

/**
 * Hisobning SERVERDAGI huquq manbalari (do'kon, admin grant, sinov). Qaror
 * faqat shu yerdan olinadi — ilovadagi rol yoki lokal sozlamadan EMAS.
 */
export async function loadAccess(
  ctx: Ctx,
  userId: string,
): Promise<{ rows: StoreRow[]; grants: GrantRow[]; trials: TrialRow[]; access: AccessItem[]; resolved: ResolvedAccess | null }> {
  const rows = (
    await ctx.db
      .prepare(
        `SELECT product_id, platform, status, started_at, expires_at, ownership, environment, updated_at
         FROM entitlements WHERE user_id = ?1 ORDER BY COALESCE(expires_at, 0) DESC`,
      )
      .bind(userId)
      .all<StoreRow>()
  ).results;
  // Admin grant (D-73): faqat qo'llangan (hisob bor), bekor qilinmagan qatorlar.
  const grants = (
    await ctx.db
      .prepare(
        `SELECT g.tier, g.starts_at, g.expires_at, g.updated_at
         FROM pro_grants g JOIN users u ON u.email_hash = g.email_hmac
         WHERE u.id = ?1 AND g.revoked_at IS NULL AND g.starts_at IS NOT NULL
         ORDER BY COALESCE(g.expires_at, 9007199254740991) DESC`,
      )
      .bind(userId)
      .all<GrantRow>()
  ).results;
  // Bepul sinov (D-74): hisobga bitta; muddati o'tgani ham tarix sifatida qaytadi.
  const trials = (
    await ctx.db
      .prepare('SELECT tier, started_at, expires_at FROM pro_trials WHERE user_id = ?1 ORDER BY started_at DESC')
      .bind(userId)
      .all<TrialRow>()
  ).results;
  const access: AccessItem[] = [
    ...rows.map((r) => ({
      source: 'store' as const,
      plan: BILLING_PRODUCTS[r.product_id]?.plan ?? ('specialist' as Plan),
      granting: r.status === 'active' || r.status === 'grace_period',
      expiresAt: r.expires_at,
    })),
    ...grants.map((g) => ({ source: 'admin_grant' as const, plan: g.tier, granting: true, expiresAt: g.expires_at })),
    ...trials.map((t) => ({ source: 'trial' as const, plan: t.tier, granting: true, expiresAt: t.expires_at })),
  ];
  return { rows, grants, trials, access, resolved: resolveAccess(access, ctx.now) };
}

export async function snapshot(ctx: Ctx, userId: string, ownedByOther = false, status = 200): Promise<Response> {
  const { rows, grants, trials, resolved } = await loadAccess(ctx, userId);
  return json(
    {
      server_time: iso(ctx.now),
      items: [
        ...rows.map((r) => ({
          product_id: r.product_id,
          platform: r.platform,
          source: 'store',
          status: r.status,
          started_at: iso(r.started_at),
          expires_at: iso(r.expires_at),
          ownership: r.ownership,
          environment: r.environment,
          updated_at: iso(r.updated_at),
        })),
        ...grants.map((g) => ({
          product_id: `admin_grant.${g.tier}`,
          platform: 'admin_grant',
          source: 'admin_grant',
          plan: g.tier,
          status: g.expires_at != null && g.expires_at <= ctx.now ? 'expired' : 'active',
          started_at: iso(g.starts_at),
          expires_at: iso(g.expires_at),
          ownership: 'granted',
          environment: 'production',
          updated_at: iso(g.updated_at),
        })),
        ...trials.map((t) => ({
          product_id: `trial.${t.tier}`,
          platform: 'trial',
          source: 'trial',
          plan: t.tier,
          status: t.expires_at <= ctx.now ? 'expired' : 'active',
          started_at: iso(t.started_at),
          expires_at: iso(t.expires_at),
          ownership: 'trial',
          environment: 'production',
          updated_at: iso(t.started_at),
        })),
      ],
      resolved: resolved && { source: resolved.source, plan: resolved.plan, expires_at: iso(resolved.expiresAt) },
      // Shu hisob bepul sinovdan foydalanganmi (D-74; qurilma bo'yicha holat bu yerda ko'rinmaydi).
      trial_used: trials.length > 0,
      owned_by_other: ownedByOther,
      // Oflayn kesh chegarasi (D-75): ilova keshni shu vaqtdan keyin huquq
      // sifatida ISHLATMAYDI — min(hozir + 7 kun, amaldagi huquq tugashi).
      offline_until: iso(offlineUntil(ctx.now, resolved)),
    },
    status,
  );
}

/** Oflayn huquq uchun maksimal muddat (D-75). */
export const OFFLINE_MAX_MS = 7 * 86400_000;

export function offlineUntil(now: number, resolved: ResolvedAccess | null): number {
  const cap = now + OFFLINE_MAX_MS;
  if (!resolved) return now;
  return resolved.expiresAt == null ? cap : Math.min(cap, resolved.expiresAt);
}

// ------------------------------------------------------------ endpointlar
/**
 * Ochiq: to'lov serverda sozlanganmi (ilova to'lov oynasini shunga qarab
 * ko'rsatadi) va bepul sinov qaysi platformada mavjud (D-75 imkoniyat
 * so'rovi: platforma `TRIAL_PLATFORMS` da VA qurilma attestatsiyasi sozlangan).
 */
export async function status(ctx: Ctx): Promise<Response> {
  return json({
    app_store: configured(ctx, 'app_store'),
    play_store: configured(ctx, 'play_store'),
    sandbox: sandboxAllowed(ctx.env),
    trial: trialStatus(ctx),
  });
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

async function verifyOne(ctx: Ctx, platform: Platform, token: string, productId?: string): Promise<Verified> {
  return acceptEnvironment(ctx, await verifierFor(ctx, platform).verify(ctx, token, productId));
}

/**
 * POST /v1/billing/verify — xarid yoki tiklash.
 * `{platform, product_id, token}` yoki `{platform, purchases: [{product_id, token}]}`.
 * `restore: true` (D-75) — qo'shimcha ravishda hisobning shu platformadagi
 * mavjud obuna qatorlari ham do'kondan QAYTA o'qiladi (boshqa qurilmada
 * bekor/yangilangan holat shu yerda sinxronlanadi).
 */
export async function verify(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const body = await readJson(ctx.req);
  const platform = parsePlatform(body.platform);
  if (!configured(ctx, platform)) throw notConfigured();
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
      v = await verifyOne(ctx, platform, p.token, p.productId);
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
      if (v.needsAck && (v.status === 'active' || v.status === 'grace_period')) {
        await verifierFor(ctx, platform).acknowledge?.(ctx, v);
      }
    } else {
      ownedByOther = true;
    }
  }
  if (body.restore === true) await resync(ctx, s.userId, platform, new Set(list.map((p) => p.token)));
  if (verified === 0 && lastError) throw lastError;
  return snapshot(ctx, s.userId, ownedByOther);
}

/**
 * Tiklash: hisobning shu platformadagi qatorlarini do'kondan qayta o'qish
 * (eng ko'pi [MAX_RESTORE]). Xato bo'lsa qator o'zgarmaydi (hech qachon
 * huquq QO'SHILMAYDI — faqat do'kon aytgan holat yoziladi).
 */
async function resync(ctx: Ctx, userId: string, platform: Platform, skip: Set<string>): Promise<void> {
  const rows = (
    await ctx.db
      .prepare('SELECT latest_token FROM entitlements WHERE user_id = ?1 AND platform = ?2 ORDER BY updated_at DESC LIMIT ?3')
      .bind(userId, platform, MAX_RESTORE)
      .all<{ latest_token: string }>()
  ).results;
  for (const r of rows) {
    if (skip.has(r.latest_token)) continue;
    try {
      await applyUpdate(ctx, acceptEnvironment(ctx, await verifierFor(ctx, platform).verify(ctx, r.latest_token)));
    } catch (e) {
      console.error('billing resync', e instanceof ApiError ? e.code : e instanceof Error ? e.name : typeof e);
    }
  }
}

// ------------------------------------------------------- bildirishnomalar
/** Bildirishnoma jurnali saqlanish muddati (takrorni tashlash uchun). */
export const NOTIFICATION_RETENTION_DAYS = 90;

/** Takror (o'sha id) — `true`. Id `source:id` ko'rinishida saqlanadi. */
async function seen(ctx: Ctx, id: string): Promise<boolean> {
  return (await ctx.db.prepare('SELECT 1 AS x FROM billing_notifications WHERE id = ?1').bind(id).first()) != null;
}

async function record(
  ctx: Ctx,
  id: string,
  n: { source: 'app_store' | 'play_store'; type: string; subtype?: string | null; environment?: string | null; outcome: string },
  details: Record<string, unknown> = {},
): Promise<void> {
  await ctx.db
    .prepare(
      `INSERT INTO billing_notifications (id, source, type, subtype, environment, outcome, received_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7) ON CONFLICT (id) DO NOTHING`,
    )
    .bind(id, n.source, n.type.slice(0, 64), n.subtype?.slice(0, 64) ?? null, n.environment ?? null, n.outcome, ctx.now)
    .run();
  // Jurnal: tur, natija, holat. Token / tranzaksiya id / foydalanuvchi emaili yozilmaydi.
  await audit(ctx, null, 'billing_notification', id, { source: n.source, type: n.type, subtype: n.subtype ?? null, outcome: n.outcome, ...details });
}

/** Apple bildirishnoma turi → majburiy holat (faqat cheklovchi tomonga). */
const APPLE_FORCED: Record<string, Status> = { REFUND: 'revoked', REVOKE: 'revoked' };

/**
 * App Store Server Notifications V2. `signedPayload` imzosi (x5c → Apple Root
 * CA - G3) tekshiriladi, `notificationUUID` bo'yicha takror tashlanadi,
 * tranzaksiya holati App Store Server API'dan QAYTA o'qiladi; REFUND / REVOKE —
 * huquq darhol olinadi (`revoked`). DID_RENEW, EXPIRED, DID_FAIL_TO_RENEW
 * (subtype GRACE_PERIOD → grace, bo'sh → billing_retry), GRACE_PERIOD_EXPIRED
 * — holat API'dan (grace davrida huquq bor; billing retry / expired — yo'q).
 */
export async function appleNotification(ctx: Ctx): Promise<Response> {
  if (!configured(ctx, 'app_store')) throw notConfigured();
  await hit(ctx.db, `billing-assn:${ctx.ipTag}`, 600, 3600, ctx.now);
  const body = await readJson(ctx.req);
  const payload = await appleJws<{
    notificationType?: string;
    subtype?: string;
    notificationUUID?: string;
    data?: { bundleId?: string; environment?: string; signedTransactionInfo?: string };
  }>(ctx, body.signedPayload);
  const uuid = String(payload.notificationUUID ?? '');
  if (!/^[0-9A-Fa-f-]{8,64}$/.test(uuid)) throw badRequest('invalid_notification');
  const id = `app_store:${uuid.toLowerCase()}`;
  if (await seen(ctx, id)) return json({ ok: true, duplicate: true });
  const type = String(payload.notificationType ?? 'UNKNOWN');
  const subtype = payload.subtype ?? null;
  const bundle = ctx.env.APPLE_BUNDLE_ID || DEFAULT_BUNDLE;
  const envRaw = String(payload.data?.environment ?? '').toLowerCase();
  const environment = envRaw === 'production' ? 'production' : 'sandbox';
  const base = { source: 'app_store' as const, type, subtype, environment };
  if (payload.data?.bundleId !== bundle || !payload.data?.signedTransactionInfo || type === 'TEST') {
    // Bizga tegishli emas yoki tranzaksiyasiz (masalan, TEST) — qayta yuborilmasin.
    await record(ctx, id, { ...base, outcome: 'ignored' });
    return json({ ok: true, ignored: true });
  }
  if (environment === 'sandbox' && !sandboxAllowed(ctx.env)) {
    await record(ctx, id, { ...base, outcome: 'sandbox_ignored' });
    return json({ ok: true, ignored: true });
  }
  const hinted = await appleJws<AppleTransaction>(ctx, payload.data.signedTransactionInfo);
  const txId = String(hinted.transactionId ?? '');
  if (!/^\d{1,32}$/.test(txId)) {
    await record(ctx, id, { ...base, outcome: 'ignored' });
    return json({ ok: true, ignored: true });
  }
  let v: Verified;
  try {
    v = acceptEnvironment(ctx, await verifierFor(ctx, 'app_store').verify(ctx, txId));
  } catch (e) {
    if (e instanceof ApiError && e.status < 500) {
      await record(ctx, id, { ...base, outcome: 'ignored' }, { reason: e.code });
      return json({ ok: true, ignored: true });
    }
    throw e;
  }
  if (APPLE_FORCED[type]) v = { ...v, status: APPLE_FORCED[type], eventAt: Math.max(v.eventAt, ctx.now) };
  let updated = await applyUpdate(ctx, v);
  if (!updated && v.accountHint) {
    // Ilova hali tekshirtirmagan xarid: appAccountToken — mavjud hisob id si.
    const user = await ctx.db.prepare('SELECT id FROM users WHERE id = ?1').bind(v.accountHint).first<{ id: string }>();
    if (user) updated = await claim(ctx, user.id, v);
  }
  await record(ctx, id, { ...base, outcome: updated ? 'updated' : 'no_row' }, { status: v.status });
  return json({ ok: true, updated });
}

/** RTDN `subscriptionNotification.notificationType` → majburiy holat. 12 = SUBSCRIPTION_REVOKED. */
const PLAY_FORCED: Record<number, Status> = { 12: 'revoked' };
/** Hujjatdagi nomlar (jurnal uchun), https://developer.android.com/google/play/billing/rtdn-reference */
const PLAY_TYPES: Record<number, string> = {
  1: 'SUBSCRIPTION_RECOVERED',
  2: 'SUBSCRIPTION_RENEWED',
  3: 'SUBSCRIPTION_CANCELED',
  4: 'SUBSCRIPTION_PURCHASED',
  5: 'SUBSCRIPTION_ON_HOLD',
  6: 'SUBSCRIPTION_IN_GRACE_PERIOD',
  7: 'SUBSCRIPTION_RESTARTED',
  9: 'SUBSCRIPTION_DEFERRED',
  10: 'SUBSCRIPTION_PAUSED',
  11: 'SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED',
  12: 'SUBSCRIPTION_REVOKED',
  13: 'SUBSCRIPTION_EXPIRED',
  17: 'SUBSCRIPTION_ITEMS_CHANGED',
  18: 'SUBSCRIPTION_CANCELLATION_SCHEDULED',
  19: 'SUBSCRIPTION_PRICE_CHANGE_UPDATED',
  20: 'SUBSCRIPTION_PENDING_PURCHASE_CANCELED',
  22: 'SUBSCRIPTION_PRICE_STEP_UP_CONSENT_UPDATED',
};

/** RTDN push autentifikatsiyasi: OIDC (tavsiya) yoki URL token. Hech biri sozlanmagan — 503. */
async function rtdnAuthorized(ctx: Ctx): Promise<void> {
  const audience = ctx.env.PLAY_RTDN_AUDIENCE ?? '';
  const token = ctx.env.PLAY_RTDN_TOKEN ?? '';
  if (!audience && !token) throw new ApiError(503, 'rtdn_auth_not_configured');
  if (audience) {
    const auth = ctx.req.headers.get('authorization') ?? '';
    const jwt = auth.startsWith('Bearer ') ? auth.slice(7) : '';
    if (!jwt || !(await verifyGooglePushJwt(ctx, jwt, audience, ctx.env.PLAY_RTDN_SERVICE_ACCOUNT ?? null))) {
      throw new ApiError(401, 'invalid_push_token');
    }
  }
  if (token) {
    const got = new URL(ctx.req.url).searchParams.get('token') ?? '';
    if (!safeEqual(got, token)) throw new ApiError(403, 'forbidden');
  }
}

/**
 * Google Play RTDN (Pub/Sub push). Autentifikatsiya (OIDC va/yoki token),
 * `message.messageId` bo'yicha takror tashlanadi, holat Play Developer
 * API'dan (`subscriptionsv2.get`) QAYTA o'qiladi. SUBSCRIPTION_REVOKED va
 * `voidedPurchaseNotification` (refund / chargeback) — huquq darhol olinadi;
 * ON_HOLD / PAUSED / EXPIRED — API holati huquq bermaydi; IN_GRACE_PERIOD — beradi.
 */
export async function googleNotification(ctx: Ctx): Promise<Response> {
  if (!configured(ctx, 'play_store')) throw notConfigured();
  await rtdnAuthorized(ctx);
  await hit(ctx.db, `billing-rtdn:${ctx.ipTag}`, 600, 3600, ctx.now);
  const body = await readJson(ctx.req);
  const message = (body.message ?? {}) as { data?: string; messageId?: string; message_id?: string };
  const messageId = String(message.messageId ?? message.message_id ?? '');
  if (!/^[A-Za-z0-9._:-]{1,128}$/.test(messageId)) throw badRequest('invalid_notification');
  const id = `play_store:${messageId}`;
  if (await seen(ctx, id)) return json({ ok: true, duplicate: true });
  let n: any;
  try {
    n = JSON.parse(b64urlDecode(String(message.data ?? '')));
  } catch {
    await record(ctx, id, { source: 'play_store', type: 'UNPARSEABLE', outcome: 'ignored' });
    return json({ ok: true, ignored: true });
  }
  const code = Number(n?.subscriptionNotification?.notificationType);
  const type = n?.voidedPurchaseNotification
    ? 'VOIDED_PURCHASE'
    : n?.testNotification
      ? 'TEST'
      : n?.subscriptionNotification
        ? (PLAY_TYPES[code] ?? `SUBSCRIPTION_${code}`)
        : 'OTHER';
  const base = { source: 'play_store' as const, type };
  if (n?.packageName !== (ctx.env.GOOGLE_PLAY_PACKAGE || DEFAULT_BUNDLE)) {
    await record(ctx, id, { ...base, outcome: 'ignored' });
    return json({ ok: true, ignored: true });
  }
  const token: unknown = n.subscriptionNotification?.purchaseToken ?? n.voidedPurchaseNotification?.purchaseToken;
  if (typeof token !== 'string') {
    await record(ctx, id, { ...base, outcome: 'ignored' });
    return json({ ok: true, ignored: true });
  }
  let v: Verified;
  try {
    v = await verifierFor(ctx, 'play_store').verify(ctx, token);
  } catch (e) {
    if (e instanceof ApiError && e.status < 500) {
      await record(ctx, id, { ...base, outcome: 'ignored' }, { reason: e.code });
      return json({ ok: true, ignored: true });
    }
    throw e;
  }
  if (v.environment === 'sandbox' && !sandboxAllowed(ctx.env)) {
    await record(ctx, id, { ...base, environment: 'sandbox', outcome: 'sandbox_ignored' });
    return json({ ok: true, ignored: true });
  }
  // Refund / chargeback (voided) va REVOKED — huquq darhol olinadi (D-75).
  const forced = n.voidedPurchaseNotification ? 'revoked' : PLAY_FORCED[code];
  if (forced) v = { ...v, status: forced };
  const updated = await applyUpdate(ctx, v);
  await record(ctx, id, { ...base, environment: v.environment, outcome: updated ? 'updated' : 'no_row' }, { status: v.status });
  return json({ ok: true, updated });
}

/** Kunlik tozalash: eski bildirishnoma id lari (faqat bayroq yoqilganda). */
export const notificationCleanupStatements = (db: D1Database, now: number): D1PreparedStatement[] => [
  db.prepare('DELETE FROM billing_notifications WHERE received_at < ?1').bind(now - NOTIFICATION_RETENTION_DAYS * 86400_000),
];
