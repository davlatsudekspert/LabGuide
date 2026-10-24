// HTTP yordamchilari: JSON javoblar, xatolar (ichki ma'lumotsiz), CORS,
// so'rov tanasini cheklangan o'lchamda o'qish.

export interface Env {
  DB: D1Database;
  /** >= 32 belgi. Email/IP/OTP HMAC va TOTP shifrlash kalitlari shundan. */
  LG_SERVER_SECRET?: string;
  /** "resend" (standart) | "brevo". */
  EMAIL_PROVIDER?: string;
  RESEND_API_KEY?: string;
  BREVO_API_KEY?: string;
  LG_SENDER_EMAIL?: string;
  LG_SENDER_NAME?: string;
  /** Maxfiy: admin panel emaillari (vergul bilan). Bo'sh bo'lsa — LG_ADMIN_EMAILS. */
  ADMIN_EMAILS?: string;
  /** Maxfiy: vergul bilan admin emaillari (faqat OTP tasdig'idan keyin). */
  LG_ADMIN_EMAILS?: string;
  /** Web build uchun ruxsat etilgan originlar (vergul bilan). Bo'sh — CORS yo'q. */
  LG_ALLOWED_ORIGINS?: string;
  /** Workers AI (hujjatni tekshirish va tarjima). Bo'lmasa — 503. */
  AI?: Ai;
  /** Rasm+matn modeli (mutaxassis hujjatini tekshirish). */
  LG_VERIFY_MODEL?: string;
  /** Tarjima modeli. */
  LG_TRANSLATE_MODEL?: string;
  /** Hamjamiyatda egasi hisobining ko'rinadigan nomi. */
  LG_OWNER_DISPLAY_NAME?: string;
  /**
   * Pro obunalari (src/billing.ts) asosiy o'chirgich. Faqat `'true'` bo'lsa
   * `/v1/billing/*` va `/v1/entitlements` yo'llari mavjud; aks holda 404.
   */
  LG_BILLING_ENABLED?: string;
  /**
   * Maxfiy: App Store Server API kaliti (App Store Connect → Users and
   * Access → Integrations → In-App Purchase). Uchalasi bo'lmasa — App Store
   * tekshiruvi `503 not_configured`.
   */
  APPLE_IAP_KEY_ID?: string;
  APPLE_IAP_ISSUER_ID?: string;
  /** `.p8` fayl matni (PEM). */
  APPLE_IAP_PRIVATE_KEY?: string;
  /** Standart: uz.labguide.app. */
  APPLE_BUNDLE_ID?: string;
  /** Maxfiy: Play Developer API uchun service account JSON. */
  GOOGLE_PLAY_SERVICE_ACCOUNT?: string;
  /** Standart: uz.labguide.app. */
  GOOGLE_PLAY_PACKAGE?: string;
  /** Maxfiy (ixtiyoriy): RTDN push URL'idagi `?token=` qiymati. */
  PLAY_RTDN_TOKEN?: string;
  /**
   * RTDN (Pub/Sub push) OIDC tekshiruvi (D-75, tavsiya etiladi): push
   * subscription'dagi "audience" qiymati. Berilsa `Authorization: Bearer`
   * JWT (Google imzosi, iss accounts.google.com, aud, email_verified) majburiy.
   * Na shu, na `PLAY_RTDN_TOKEN` bo'lsa — RTDN `503 rtdn_auth_not_configured`.
   */
  PLAY_RTDN_AUDIENCE?: string;
  /** Push subscription'ning service account emaili (JWT `email` bilan solishtiriladi). */
  PLAY_RTDN_SERVICE_ACCOUNT?: string;
  /**
   * Sandbox / test xaridlari (D-75): faqat `'true'` bo'lsa Apple Sandbox va
   * Play litsenziya testeri xaridlari qabul qilinadi (muhit `sandbox` deb
   * yoziladi). Aks holda (production) sandbox xaridi `403 sandbox_not_allowed`,
   * sandbox bildirishnomasi e'tiborsiz.
   */
  LG_BILLING_SANDBOX?: string;
  /**
   * Apple Root CA barmoq izi (SHA-256, hex) — JWS zanjiri shu root'ga pin
   * qilinadi. Standart: Apple Root CA - G3 (src/x509.ts). Maxfiy emas;
   * faqat testlar va Apple root almashtirsa o'zgartiriladi.
   */
  APPLE_ROOT_CA_SHA256?: string;
  /** Ixtiyoriy: App Store obuna guruhi id si — berilsa tranzaksiya guruhi tekshiriladi. */
  APPLE_SUBSCRIPTION_GROUP_ID?: string;
  /**
   * Bepul sinov ruxsat etilgan platformalar (D-75), vergul bilan: `android`,
   * `ios`. Standart — faqat `android`. iOS faqat Apple yozma javobidan keyin
   * egasi tomonidan qo'shiladi (docs/APPLE_REVIEW_QUESTION_DRAFT.md).
   */
  TRIAL_PLATFORMS?: string;
  /**
   * Google bilan kirish (src/social.ts): ruxsat etilgan OAuth client ID lar
   * (ID tokendagi `aud`), vergul/bo'shliq bilan. Bo'sh — Google kirishi
   * `503 not_configured`, ilova tugmani ko'rsatmaydi.
   */
  GOOGLE_CLIENT_IDS?: string;
  /**
   * Apple bilan kirish: Developer → Keys → "Sign in with Apple" kaliti.
   * Uchalasi (TEAM_ID, KEY_ID, PRIVATE_KEY = `.p8` matni) bo'lsa yoqiladi —
   * hisobni o'chirishda Apple tokenini bekor qilish (revoke) shularga bog'liq.
   */
  APPLE_SIGNIN_TEAM_ID?: string;
  APPLE_SIGNIN_KEY_ID?: string;
  APPLE_SIGNIN_PRIVATE_KEY?: string;
  /** Standart: uz.labguide.app (iOS/macOS ilova). */
  APPLE_SIGNIN_CLIENT_ID?: string;
  /** Ixtiyoriy: Android veb-oqimi uchun Apple Services ID (qo'shimcha `aud`). */
  APPLE_SIGNIN_SERVICE_ID?: string;
}

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    readonly extra: Record<string, unknown> = {},
  ) {
    super(code);
  }
}

export const badRequest = (code = 'invalid', extra?: Record<string, unknown>) =>
  new ApiError(400, code, extra);
export const unauthorized = () => new ApiError(401, 'unauthorized');
export const forbidden = (code = 'forbidden') => new ApiError(403, code);
export const notFound = () => new ApiError(404, 'not_found');
export const conflict = (code = 'conflict') => new ApiError(409, code);
export const rateLimited = (retryAfterSec: number) =>
  new ApiError(429, 'rate_limited', { retry_after: Math.max(1, Math.ceil(retryAfterSec)) });

const BASE_HEADERS: Record<string, string> = {
  'content-type': 'application/json; charset=utf-8',
  'cache-control': 'no-store',
  'x-content-type-options': 'nosniff',
  'referrer-policy': 'no-referrer',
};

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: BASE_HEADERS });
}

export function noContent(): Response {
  return new Response(null, { status: 204, headers: { 'cache-control': 'no-store' } });
}

export function errorResponse(e: ApiError): Response {
  const res = json({ error: e.code, ...e.extra }, e.status);
  if (e.status === 429 && typeof e.extra.retry_after === 'number') {
    res.headers.set('retry-after', String(e.extra.retry_after));
  }
  return res;
}

const MAX_BODY = 32 * 1024;

/** JSON obyekt tanasi; o'lcham, turi va sintaksisi tekshiriladi. */
export async function readJson(req: Request, maxBody = MAX_BODY): Promise<Record<string, unknown>> {
  const type = req.headers.get('content-type') ?? '';
  if (!type.toLowerCase().startsWith('application/json')) {
    throw new ApiError(415, 'unsupported_media_type');
  }
  const declared = Number(req.headers.get('content-length') ?? '0');
  if (declared > maxBody) throw new ApiError(413, 'too_large');
  const buf = await req.arrayBuffer();
  if (buf.byteLength > maxBody) throw new ApiError(413, 'too_large');
  let parsed: unknown;
  try {
    parsed = JSON.parse(new TextDecoder().decode(buf));
  } catch {
    throw badRequest('invalid_json');
  }
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw badRequest('invalid_json');
  }
  return parsed as Record<string, unknown>;
}

function allowedOrigins(env: Env): string[] {
  return (env.LG_ALLOWED_ORIGINS ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.startsWith('https://') || s.startsWith('http://localhost'));
}

/**
 * CORS faqat sozlangan originlarga. Mobil ilova Origin yubormaydi va CORS'ga
 * muhtoj emas; standart holatda hech qanday CORS sarlavhasi qo'yilmaydi.
 */
export function corsHeaders(req: Request, env: Env): Record<string, string> | null {
  const origin = req.headers.get('origin');
  if (!origin || !allowedOrigins(env).includes(origin)) return null;
  return {
    'access-control-allow-origin': origin,
    'access-control-allow-methods': 'GET, POST, PUT, PATCH, DELETE',
    'access-control-allow-headers': 'authorization, content-type',
    'access-control-max-age': '600',
    vary: 'Origin',
  };
}

export function withCors(res: Response, cors: Record<string, string> | null): Response {
  if (!cors) return res;
  const out = new Response(res.body, res);
  for (const [k, v] of Object.entries(cors)) out.headers.set(k, v);
  return out;
}

/**
 * Pro (obuna va admin grant) asosiy o'chirgich: faqat `LG_BILLING_ENABLED=true`
 * bo'lsa `/v1/billing/*`, `/v1/entitlements` va `/v1/admin/pro-grants*` mavjud.
 */
export const billingEnabled = (env: Env) => env.LG_BILLING_ENABLED === 'true';
