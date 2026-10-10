// HTTP yordamchilari: JSON javoblar, xatolar (ichki ma'lumotsiz), CORS,
// so'rov tanasini cheklangan o'lchamda o'qish.

export interface Env {
  DB: D1Database;
  /** >= 32 belgi. Email/IP/OTP HMAC va TOTP shifrlash kalitlari shundan. */
  LG_SERVER_SECRET?: string;
  BREVO_API_KEY?: string;
  LG_SENDER_EMAIL?: string;
  LG_SENDER_NAME?: string;
  /** Maxfiy: vergul bilan admin emaillari (faqat OTP tasdig'idan keyin). */
  LG_ADMIN_EMAILS?: string;
  /** Web build uchun ruxsat etilgan originlar (vergul bilan). Bo'sh — CORS yo'q. */
  LG_ALLOWED_ORIGINS?: string;
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
export async function readJson(req: Request): Promise<Record<string, unknown>> {
  const type = req.headers.get('content-type') ?? '';
  if (!type.toLowerCase().startsWith('application/json')) {
    throw new ApiError(415, 'unsupported_media_type');
  }
  const declared = Number(req.headers.get('content-length') ?? '0');
  if (declared > MAX_BODY) throw new ApiError(413, 'too_large');
  const buf = await req.arrayBuffer();
  if (buf.byteLength > MAX_BODY) throw new ApiError(413, 'too_large');
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
