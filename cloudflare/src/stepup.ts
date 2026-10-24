// Admin STEP-UP: xavfli admin amalidan oldin yangi tasdiq (2026-10-24 auth
// auditi, P1-6). Yangi omil o'ylab topilmaydi:
// * admin TOTP faktori tasdiqlangan bo'lsa — FAQAT TOTP (auth.ts checkTotp;
//   email kodi bilan pasaytirib bo'lmaydi);
// * aks holda (egasi, ADMIN_EMAILS) — email kodi: shu sessiyaga va hisobga
//   bog'langan, 10 daqiqa, 5 urinish, bir martalik, qayta yuborish 60 soniya,
//   soatiga 5 ta kod va 20 ta tasdiq urinishi.
// Tasdiq 10 daqiqa amal qiladi (`step_up_at`) va admin oynasini (12 soat /
// 30 daqiqa) ham yangilaydi. "Bir martalik" amal turlari (hisobni o'chirish,
// sessiyalarni bekor qilish) har tasdiqqa bittadan.
// Har so'rov, tasdiq, xato va rad etilgan amal audit_log ga yoziladi.

import {
  adminAllowlist,
  audit,
  checkTotp,
  emailHash,
  hasVerifiedTotp,
  isAdminAccount,
  isPanelAdmin,
  maskEmail,
  requireSession,
} from './auth';
import type { Ctx, Session } from './context';
import { hex, hmac, randomDigits, safeEqual, sha256Hex } from './crypto';
import { ApiError, badRequest, forbidden, json, readJson } from './http';
import { hit } from './ratelimit';

export const STEP_UP_CODE_TTL_SEC = 600;
export const STEP_UP_WINDOW_SEC = 600;
export const STEP_UP_MAX_ATTEMPTS = 5;
export const STEP_UP_RESEND_SEC = 60;
export const STEP_UP_REQUESTS_PER_HOUR = 5;
export const STEP_UP_VERIFIES_PER_HOUR = 20;

/** Amal turlari. `once` — har step-up ga bittadan. */
export const STEP_UP_ACTIONS = {
  account_delete: { once: true },
  sessions_revoke: { once: true },
  admins: { once: false },
  account_status: { once: false },
  role: { once: false },
  community_status: { once: false },
  moderation: { once: false },
  content: { once: false },
} as const;
export type StepUpAction = keyof typeof STEP_UP_ACTIONS;

const tagOf = async (userId: string) => (await sha256Hex(userId)).slice(0, 32);

async function codeHash(ctx: Ctx, tokenHash: string, code: string): Promise<string> {
  return hex(await hmac(ctx.keys.otp, `step-up:${tokenHash}:${code}`));
}

/** Egasi (ADMIN_EMAILS) emaili — kod yuborish uchun; server emailni saqlamaydi. */
async function allowlistedEmail(ctx: Ctx, userId: string): Promise<string | null> {
  const row = await ctx.db
    .prepare('SELECT email_hash FROM users WHERE id = ?1')
    .bind(userId)
    .first<{ email_hash: string }>();
  if (!row) return null;
  for (const e of adminAllowlist(ctx)) {
    if (safeEqual(await emailHash(ctx, e), row.email_hash)) return e;
  }
  return null;
}

/**
 * Kim step-up qila oladi va qaysi usul bilan: TOTP tasdiqlangan admin
 * hisobi — 'totp'; panel admini (email kodi sessiyasi + ADMIN_EMAILS) —
 * 'email'; boshqalar — `403 forbidden`.
 */
async function stepUpMethod(ctx: Ctx, s: Session): Promise<'totp' | 'email'> {
  const panel = await isPanelAdmin(ctx, s);
  const account = panel || (await isAdminAccount(ctx, s.userId));
  if (!account) throw forbidden();
  if (await hasVerifiedTotp(ctx, s.userId)) return 'totp';
  if (panel) return 'email';
  throw forbidden('step_up_unavailable');
}

/** POST /v1/auth/step-up — kod so'rash (TOTP bo'lsa — faqat usulni aytadi). */
export async function requestStepUp(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const method = await stepUpMethod(ctx, s);
  const tag = await tagOf(s.userId);
  if (method === 'totp') {
    await audit(ctx, s.userId, 'step_up_requested', s.userId, { method });
    return json({ method, valid_for: STEP_UP_WINDOW_SEC });
  }
  const prev = await ctx.db
    .prepare('SELECT created_at FROM step_up_challenges WHERE token_hash = ?1')
    .bind(s.tokenHash)
    .first<{ created_at: number }>();
  if (prev && ctx.now < prev.created_at + STEP_UP_RESEND_SEC * 1000) {
    throw new ApiError(429, 'rate_limited', {
      retry_after: Math.ceil((prev.created_at + STEP_UP_RESEND_SEC * 1000 - ctx.now) / 1000),
    });
  }
  try {
    await hit(ctx.db, `stepup-req:${tag}`, STEP_UP_REQUESTS_PER_HOUR, 3600, ctx.now);
  } catch (e) {
    await audit(ctx, s.userId, 'step_up_failed', s.userId, { method, reason: 'rate_limited' });
    throw e;
  }
  const email = await allowlistedEmail(ctx, s.userId);
  if (!email) throw forbidden();
  const code = randomDigits(6);
  await ctx.db
    .prepare(
      `INSERT INTO step_up_challenges (token_hash, user_id, code_hash, created_at, expires_at, attempts)
       VALUES (?1, ?2, ?3, ?4, ?5, 0)
       ON CONFLICT (token_hash) DO UPDATE SET code_hash = ?3, created_at = ?4, expires_at = ?5, attempts = 0`,
    )
    .bind(s.tokenHash, s.userId, await codeHash(ctx, s.tokenHash, code), ctx.now, ctx.now + STEP_UP_CODE_TTL_SEC * 1000)
    .run();
  const lang = s.language === 'ru' || s.language === 'en' ? s.language : 'uz';
  const sent = await ctx.deps.sendCode(ctx.env, email, code, lang);
  if (sent !== 'sent') {
    await ctx.db.prepare('DELETE FROM step_up_challenges WHERE token_hash = ?1').bind(s.tokenHash).run();
    await audit(ctx, s.userId, 'step_up_failed', s.userId, { method, reason: 'email_' + sent });
    throw sent === 'not_configured' ? new ApiError(503, 'not_configured') : new ApiError(502, 'email_failed');
  }
  await audit(ctx, s.userId, 'step_up_requested', s.userId, { method });
  return json({
    method,
    email_masked: maskEmail(email),
    retry_after: STEP_UP_RESEND_SEC,
    valid_for: STEP_UP_CODE_TTL_SEC,
  });
}

/** POST /v1/auth/step-up/verify {code} — tasdiq: 10 daqiqalik step-up + admin oynasi. */
export async function verifyStepUp(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const method = await stepUpMethod(ctx, s);
  const body = await readJson(ctx.req);
  const tag = await tagOf(s.userId);
  const fail = async (reason: string, e: ApiError): Promise<never> => {
    await audit(ctx, s.userId, 'step_up_failed', s.userId, { method, reason });
    throw e;
  };
  try {
    await hit(ctx.db, `stepup-verify:${tag}`, STEP_UP_VERIFIES_PER_HOUR, 3600, ctx.now);
  } catch (e) {
    return fail('rate_limited', e as ApiError);
  }
  if (method === 'totp') {
    try {
      await checkTotp(ctx, s.userId, body.code);
    } catch (e) {
      return fail(e instanceof ApiError ? e.code : 'invalid_code', e as ApiError);
    }
  } else {
    const code = typeof body.code === 'string' ? body.code.trim() : '';
    const ch = await ctx.db
      .prepare('SELECT user_id, expires_at FROM step_up_challenges WHERE token_hash = ?1')
      .bind(s.tokenHash)
      .first<{ user_id: string; expires_at: number }>();
    if (!ch || ch.user_id !== s.userId) return fail('no_active_code', badRequest('no_active_code'));
    if (ctx.now >= ch.expires_at) {
      await ctx.db.prepare('DELETE FROM step_up_challenges WHERE token_hash = ?1').bind(s.tokenHash).run();
      return fail('expired', badRequest('expired'));
    }
    const row = await ctx.db
      .prepare(
        `UPDATE step_up_challenges SET attempts = attempts + 1
         WHERE token_hash = ?1 AND attempts < ?2 RETURNING attempts, code_hash`,
      )
      .bind(s.tokenHash, STEP_UP_MAX_ATTEMPTS)
      .first<{ attempts: number; code_hash: string }>();
    if (!row) {
      await ctx.db.prepare('DELETE FROM step_up_challenges WHERE token_hash = ?1').bind(s.tokenHash).run();
      return fail('too_many_attempts', new ApiError(429, 'too_many_attempts'));
    }
    const ok = /^\d{6}$/.test(code) && safeEqual(await codeHash(ctx, s.tokenHash, code), row.code_hash);
    if (!ok) {
      const left = STEP_UP_MAX_ATTEMPTS - row.attempts;
      if (left <= 0) {
        await ctx.db.prepare('DELETE FROM step_up_challenges WHERE token_hash = ?1').bind(s.tokenHash).run();
        return fail('too_many_attempts', new ApiError(429, 'too_many_attempts'));
      }
      return fail('invalid_code', badRequest('invalid_code', { attempts_left: left }));
    }
    // Bir martalik: parallel ikkinchi muvaffaqiyat rad etiladi.
    const del = await ctx.db
      .prepare('DELETE FROM step_up_challenges WHERE token_hash = ?1 AND code_hash = ?2')
      .bind(s.tokenHash, row.code_hash)
      .run();
    if (!del.meta.changes) return fail('no_active_code', badRequest('no_active_code'));
  }
  await ctx.db
    .prepare(
      `UPDATE sessions SET step_up_at = ?2, step_up_used = '', admin_auth_at = ?2, admin_seen_at = ?2,
         aal = CASE WHEN ?3 = 'totp' THEN 'aal2' ELSE aal END
       WHERE token_hash = ?1`,
    )
    .bind(s.tokenHash, ctx.now, method)
    .run();
  await audit(ctx, s.userId, 'step_up_verified', s.userId, { method });
  return json({ ok: true, method, valid_for: STEP_UP_WINDOW_SEC });
}

/**
 * Xavfli admin amalidan oldin: shu sessiyada so'nggi [STEP_UP_WINDOW_SEC]
 * ichida step-up bo'lgan, `once` turida esa shu tasdiq bilan bu tur hali
 * bajarilmagan bo'lishi shart. Aks holda `403 step_up_required`
 * ({action, reason: missing|expired|used}) va jurnalda `step_up_required`.
 * Tekshiruvlar (vakolat, kirish ma'lumoti) dan KEYIN, o'zgartirishdan OLDIN chaqiriladi.
 */
export async function requireStepUp(ctx: Ctx, s: Session, action: StepUpAction): Promise<void> {
  let reason: string | null = null;
  if (s.stepUpAt == null) reason = 'missing';
  else if (ctx.now - s.stepUpAt > STEP_UP_WINDOW_SEC * 1000) reason = 'expired';
  else if (STEP_UP_ACTIONS[action].once) {
    const mark = `${action},`;
    const r = await ctx.db
      .prepare(
        `UPDATE sessions SET step_up_used = step_up_used || ?2
         WHERE token_hash = ?1 AND step_up_at = ?3 AND instr(step_up_used, ?2) = 0`,
      )
      .bind(s.tokenHash, mark, s.stepUpAt)
      .run();
    if (!r.meta.changes) reason = 'used';
    else s.stepUpUsed += mark;
  }
  if (reason) {
    await audit(ctx, s.userId, 'step_up_required', null, { action, reason });
    throw new ApiError(403, 'step_up_required', { action, reason });
  }
}

type Handler = (ctx: Ctx, ...params: string[]) => Promise<Response>;

export const ROUTES: [string, string, Handler][] = [
  ['POST', '/v1/auth/step-up', requestStepUp],
  ['POST', '/v1/auth/step-up/verify', verifyStepUp],
];
