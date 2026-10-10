// Email OTP, sessiyalar, profil, admin TOTP va hisobni o'chirish.

import type { Ctx, Session } from './context';
import { iso } from './context';
import {
  base32,
  base64url,
  decrypt,
  encrypt,
  hex,
  hmac,
  randomBytes,
  randomDigits,
  safeEqual,
  sha256Hex,
  totpAt,
} from './crypto';
import {
  ApiError,
  badRequest,
  forbidden,
  json,
  noContent,
  readJson,
  unauthorized,
} from './http';
import { hit } from './ratelimit';

export const OTP_TTL_SEC = 600;
export const OTP_MAX_ATTEMPTS = 5;
export const OTP_RESEND_SEC = 60;
export const SESSION_TTL_DAYS = 60;

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
const ROLES = new Set(['doctor', 'lab', 'student', 'teacher']);
const LANGS = new Set(['uz', 'ru', 'en']);

export function normalizeEmail(raw: unknown): string | null {
  if (typeof raw !== 'string') return null;
  const e = raw.trim().toLowerCase();
  return e.length <= 254 && EMAIL_RE.test(e) ? e : null;
}

export function maskEmail(email: string): string {
  const [local, domain] = email.split('@');
  return `${local.slice(0, 2)}***@${domain}`;
}

async function emailHash(ctx: Ctx, email: string): Promise<string> {
  return hex(await hmac(ctx.keys.email, email));
}

async function codeHash(ctx: Ctx, eh: string, code: string): Promise<string> {
  return hex(await hmac(ctx.keys.otp, `${eh}:${code}`));
}

const tag = (h: string) => h.slice(0, 32);

// ------------------------------------------------------------------ OTP
export async function requestCode(ctx: Ctx): Promise<Response> {
  const body = await readJson(ctx.req);
  const email = normalizeEmail(body.email);
  if (!email) throw badRequest('invalid_email');
  const lang = typeof body.language === 'string' && LANGS.has(body.language) ? body.language : 'uz';
  const eh = await emailHash(ctx, email);

  const prev = await ctx.db
    .prepare('SELECT created_at FROM otp_challenges WHERE email_hash = ?1')
    .bind(eh)
    .first<{ created_at: number }>();
  if (prev && ctx.now < prev.created_at + OTP_RESEND_SEC * 1000) {
    throw new ApiError(429, 'rate_limited', {
      retry_after: Math.ceil((prev.created_at + OTP_RESEND_SEC * 1000 - ctx.now) / 1000),
    });
  }
  // Sinf bitta NAT ortida bo'lishi mumkin — IP limiti yumshoqroq.
  await hit(ctx.db, `otp-ip:${ctx.ipTag}`, 60, 3600, ctx.now);
  await hit(ctx.db, `otp-email:${tag(eh)}`, 5, 3600, ctx.now);

  const code = randomDigits(6);
  await ctx.db
    .prepare(
      `INSERT INTO otp_challenges (email_hash, code_hash, created_at, expires_at, attempts)
       VALUES (?1, ?2, ?3, ?4, 0)
       ON CONFLICT (email_hash) DO UPDATE SET code_hash = ?2, created_at = ?3, expires_at = ?4, attempts = 0`,
    )
    .bind(eh, await codeHash(ctx, eh, code), ctx.now, ctx.now + OTP_TTL_SEC * 1000)
    .run();

  const sent = await ctx.deps.sendCode(ctx.env, email, code, lang);
  if (sent !== 'sent') {
    await ctx.db.prepare('DELETE FROM otp_challenges WHERE email_hash = ?1').bind(eh).run();
    throw sent === 'not_configured'
      ? new ApiError(503, 'not_configured')
      : new ApiError(502, 'email_failed');
  }
  return json({ status: 'sent', retry_after: OTP_RESEND_SEC, valid_for: OTP_TTL_SEC });
}

export async function verifyCode(ctx: Ctx): Promise<Response> {
  const body = await readJson(ctx.req);
  const email = normalizeEmail(body.email);
  if (!email) throw badRequest('invalid_email');
  const code = typeof body.code === 'string' ? body.code.trim() : '';
  const eh = await emailHash(ctx, email);
  await hit(ctx.db, `verify-ip:${ctx.ipTag}`, 100, 600, ctx.now);
  await hit(ctx.db, `verify-email:${tag(eh)}`, 15, 3600, ctx.now);

  const ch = await ctx.db
    .prepare('SELECT expires_at, attempts FROM otp_challenges WHERE email_hash = ?1')
    .bind(eh)
    .first<{ expires_at: number; attempts: number }>();
  if (!ch) throw badRequest('no_active_code');
  if (ctx.now >= ch.expires_at) {
    await ctx.db.prepare('DELETE FROM otp_challenges WHERE email_hash = ?1').bind(eh).run();
    throw badRequest('expired');
  }
  // Urinish atomar hisoblanadi (parallel so'rovlar limitni chetlab o'tolmaydi).
  const row = await ctx.db
    .prepare(
      `UPDATE otp_challenges SET attempts = attempts + 1
       WHERE email_hash = ?1 AND attempts < ?2
       RETURNING attempts, code_hash`,
    )
    .bind(eh, OTP_MAX_ATTEMPTS)
    .first<{ attempts: number; code_hash: string }>();
  if (!row) {
    await ctx.db.prepare('DELETE FROM otp_challenges WHERE email_hash = ?1').bind(eh).run();
    throw new ApiError(429, 'too_many_attempts');
  }
  const ok = /^\d{6}$/.test(code) && safeEqual(await codeHash(ctx, eh, code), row.code_hash);
  if (!ok) {
    const left = OTP_MAX_ATTEMPTS - row.attempts;
    if (left <= 0) {
      await ctx.db.prepare('DELETE FROM otp_challenges WHERE email_hash = ?1').bind(eh).run();
      throw new ApiError(429, 'too_many_attempts');
    }
    throw badRequest('invalid_code', { attempts_left: left });
  }
  // Kod bir martalik: o'chirilmagan bo'lsa (parallel muvaffaqiyat) — rad.
  const del = await ctx.db
    .prepare('DELETE FROM otp_challenges WHERE email_hash = ?1 AND code_hash = ?2')
    .bind(eh, row.code_hash)
    .run();
  if (!del.meta.changes) throw badRequest('no_active_code');

  let user = await ctx.db
    .prepare('SELECT id FROM users WHERE email_hash = ?1')
    .bind(eh)
    .first<{ id: string }>();
  const created = !user;
  if (!user) {
    const id = crypto.randomUUID();
    await ctx.db
      .prepare(
        `INSERT INTO users (id, email_hash, email_masked, created_at) VALUES (?1, ?2, ?3, ?4)
         ON CONFLICT (email_hash) DO NOTHING`,
      )
      .bind(id, eh, maskEmail(email), ctx.now)
      .run();
    user = await ctx.db
      .prepare('SELECT id FROM users WHERE email_hash = ?1')
      .bind(eh)
      .first<{ id: string }>();
    if (!user) throw new Error('user insert failed');
  }
  await syncAdmin(ctx, user.id, email);

  const token = base64url(randomBytes(32));
  const expires = ctx.now + SESSION_TTL_DAYS * 86400_000;
  await ctx.db
    .prepare(
      'INSERT INTO sessions (token_hash, user_id, created_at, expires_at, aal) VALUES (?1, ?2, ?3, ?4, ?5)',
    )
    .bind(await sha256Hex(token), user.id, ctx.now, expires, 'aal1')
    .run();
  return json({ token, user_id: user.id, expires_at: iso(expires), new_user: created });
}

/**
 * Admin vakolati faqat serverda: maxfiy LG_ADMIN_EMAILS ro'yxatidagi email
 * kod bilan tasdiqlanganda beriladi; ro'yxatdan chiqsa — olinadi. Qo'lda
 * (`wrangler d1 execute`) berilgan vakolat (`granted_reason = 'manual'`) saqlanadi.
 */
async function syncAdmin(ctx: Ctx, userId: string, email: string): Promise<void> {
  const list = (ctx.env.LG_ADMIN_EMAILS ?? '')
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);
  if (list.includes(email)) {
    const r = await ctx.db
      .prepare(
        `INSERT INTO admins (user_id, granted_at, granted_reason) VALUES (?1, ?2, 'verified allowlisted email')
         ON CONFLICT (user_id) DO NOTHING`,
      )
      .bind(userId, ctx.now)
      .run();
    if (r.meta.changes) await audit(ctx, userId, 'admin_granted', userId, { reason: 'allowlist' });
  } else {
    const r = await ctx.db
      .prepare(`DELETE FROM admins WHERE user_id = ?1 AND granted_reason <> 'manual'`)
      .bind(userId)
      .run();
    if (r.meta.changes) await audit(ctx, userId, 'admin_revoked', userId, { reason: 'not allowlisted' });
  }
}

export async function audit(
  ctx: Ctx,
  actor: string | null,
  action: string,
  target: string | null,
  details: Record<string, unknown> = {},
): Promise<void> {
  await ctx.db
    .prepare('INSERT INTO audit_log (at, actor, action, target, details) VALUES (?1, ?2, ?3, ?4, ?5)')
    .bind(ctx.now, actor, action, target, JSON.stringify(details))
    .run();
}

// -------------------------------------------------------------- sessions
const TOKEN_RE = /^[A-Za-z0-9_-]{43}$/;

export async function requireSession(ctx: Ctx): Promise<Session> {
  const h = ctx.req.headers.get('authorization') ?? '';
  const m = /^Bearer (\S+)$/.exec(h);
  if (!m || !TOKEN_RE.test(m[1])) throw unauthorized();
  const th = await sha256Hex(m[1]);
  const row = await ctx.db
    .prepare(
      `SELECT s.user_id, s.aal, u.role, u.language FROM sessions s
       JOIN users u ON u.id = s.user_id
       WHERE s.token_hash = ?1 AND s.expires_at > ?2`,
    )
    .bind(th, ctx.now)
    .first<{ user_id: string; aal: 'aal1' | 'aal2'; role: string; language: string }>();
  if (!row) throw unauthorized();
  return { userId: row.user_id, tokenHash: th, aal: row.aal, role: row.role, language: row.language };
}

export async function logout(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  await ctx.db.prepare('DELETE FROM sessions WHERE token_hash = ?1').bind(s.tokenHash).run();
  return noContent();
}

export async function logoutAll(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  await ctx.db.prepare('DELETE FROM sessions WHERE user_id = ?1').bind(s.userId).run();
  return noContent();
}

async function flags(ctx: Ctx, userId: string) {
  const r = await ctx.db
    .prepare(
      `SELECT EXISTS (SELECT 1 FROM admins WHERE user_id = ?1) AS admin,
              EXISTS (SELECT 1 FROM reviewers WHERE user_id = ?1) AS reviewer,
              EXISTS (SELECT 1 FROM teacher_accounts WHERE user_id = ?1) AS teacher`,
    )
    .bind(userId)
    .first<{ admin: number; reviewer: number; teacher: number }>();
  return { admin: r?.admin === 1, reviewer: r?.reviewer === 1, teacher: r?.teacher === 1 };
}

export async function requireAdmin(ctx: Ctx): Promise<Session> {
  const s = await requireSession(ctx);
  const f = await flags(ctx, s.userId);
  if (!f.admin || s.aal !== 'aal2') throw forbidden();
  return s;
}

export async function me(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const f = await flags(ctx, s.userId);
  return json({
    user_id: s.userId,
    role: s.role,
    language: s.language,
    admin_account: f.admin,
    aal: s.aal,
    admin: f.admin && s.aal === 'aal2',
    reviewer: f.reviewer,
    // Ustoz — faqat o'z guruhlari; admin vakolati emas.
    teacher: f.teacher,
  });
}

/** Rol va til (rol — foydalanuvchi tanlovi; 'admin' kabi qiymat qabul qilinmaydi). */
export async function updateProfile(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const body = await readJson(ctx.req);
  const role = body.role ?? s.role;
  const language = body.language ?? s.language;
  if (typeof role !== 'string' || !ROLES.has(role)) throw badRequest('invalid_role');
  if (typeof language !== 'string' || !LANGS.has(language)) throw badRequest('invalid_language');
  const today = new Date(ctx.now + 5 * 3600_000).toISOString().slice(0, 10); // Asia/Tashkent (UTC+5)
  await ctx.db
    .prepare('UPDATE users SET role = ?1, language = ?2, last_seen_on = ?3 WHERE id = ?4')
    .bind(role, language, today, s.userId)
    .run();
  return json({ role, language });
}

/** Hisob va unga bog'liq hamma narsa o'chiriladi (audit jurnalida faqat id). */
export async function deleteAccount(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const u = s.userId;
  const owned = `SELECT id FROM study_groups WHERE owner_id = ?1`;
  const ownedAssignments = `SELECT id FROM assignments WHERE group_id IN (${owned})`;
  const stmts = [
    `DELETE FROM submissions WHERE user_id = ?1 OR assignment_id IN (${ownedAssignments})`,
    `DELETE FROM assignment_attempts WHERE user_id = ?1 OR assignment_id IN (${ownedAssignments})`,
    `DELETE FROM assignment_keys WHERE assignment_id IN (${ownedAssignments})`,
    `DELETE FROM assignments WHERE group_id IN (${owned})`,
    `DELETE FROM qa_marks WHERE user_id = ?1 OR group_id IN (${owned})`,
    `DELETE FROM group_topics WHERE group_id IN (${owned})`,
    `DELETE FROM group_members WHERE user_id = ?1 OR group_id IN (${owned})`,
    `DELETE FROM study_groups WHERE owner_id = ?1`,
    `DELETE FROM support_messages WHERE thread_id IN (SELECT id FROM support_threads WHERE user_id = ?1)`,
    `DELETE FROM support_threads WHERE user_id = ?1`,
    `UPDATE partner_requests SET user_id = NULL WHERE user_id = ?1`,
    `UPDATE content_reviews SET reviewer_id = NULL WHERE reviewer_id = ?1`,
    `DELETE FROM entitlements WHERE user_id = ?1`,
    `DELETE FROM totp_factors WHERE user_id = ?1`,
    `DELETE FROM reviewers WHERE user_id = ?1`,
    `DELETE FROM teacher_accounts WHERE user_id = ?1`,
    `DELETE FROM admins WHERE user_id = ?1`,
    `DELETE FROM sessions WHERE user_id = ?1`,
    `DELETE FROM users WHERE id = ?1`,
    `INSERT INTO audit_log (at, actor, action, target, details) VALUES (?2, ?1, 'account_deleted', ?1, '{}')`,
  ];
  await ctx.db.batch(
    stmts.map((q) => (q.includes('?2') ? ctx.db.prepare(q).bind(u, ctx.now) : ctx.db.prepare(q).bind(u))),
  );
  return noContent();
}

// ------------------------------------------------------------ admin TOTP
async function requireAdminAccount(ctx: Ctx): Promise<Session> {
  const s = await requireSession(ctx);
  if (!(await flags(ctx, s.userId)).admin) throw forbidden();
  return s;
}

export async function mfaStatus(ctx: Ctx): Promise<Response> {
  const s = await requireAdminAccount(ctx);
  const f = await ctx.db
    .prepare('SELECT verified FROM totp_factors WHERE user_id = ?1')
    .bind(s.userId)
    .first<{ verified: number }>();
  return json({ verified_factor_id: f?.verified === 1 ? s.userId : null, aal: s.aal });
}

/**
 * Faqat tasdiqlangan faktor YO'Q bo'lsa: aks holda o'g'irlangan aal1 sessiya
 * yangi faktor qo'shib admin bo'lib olardi. Tiklash — egasi qo'lda (hujjat).
 */
export async function mfaEnroll(ctx: Ctx): Promise<Response> {
  const s = await requireAdminAccount(ctx);
  const existing = await ctx.db
    .prepare('SELECT verified FROM totp_factors WHERE user_id = ?1')
    .bind(s.userId)
    .first<{ verified: number }>();
  if (existing?.verified === 1) throw forbidden('factor_exists');
  const secret = randomBytes(20);
  await ctx.db
    .prepare(
      `INSERT INTO totp_factors (user_id, secret_enc, verified, last_step, created_at) VALUES (?1, ?2, 0, 0, ?3)
       ON CONFLICT (user_id) DO UPDATE SET secret_enc = ?2, verified = 0, last_step = 0, created_at = ?3`,
    )
    .bind(s.userId, await encrypt(ctx.keys.totp, secret), ctx.now)
    .run();
  const b32 = base32(secret);
  return json({
    factor_id: s.userId,
    secret: b32,
    uri: `otpauth://totp/LabGuide:admin?secret=${b32}&issuer=LabGuide&algorithm=SHA1&digits=6&period=30`,
  });
}

export async function mfaVerify(ctx: Ctx): Promise<Response> {
  const s = await requireAdminAccount(ctx);
  const body = await readJson(ctx.req);
  const code = typeof body.code === 'string' ? body.code.trim() : '';
  await hit(ctx.db, `mfa:${s.userId}`, 5, 600, ctx.now);
  const f = await ctx.db
    .prepare('SELECT secret_enc, verified, last_step FROM totp_factors WHERE user_id = ?1')
    .bind(s.userId)
    .first<{ secret_enc: string; verified: number; last_step: number }>();
  if (!f) throw badRequest('no_factor');
  if (!/^\d{6}$/.test(code)) throw badRequest('invalid_code');
  const secret = await decrypt(ctx.keys.totp, f.secret_enc);
  const step = Math.floor(ctx.now / 30_000);
  let matched = 0;
  for (const st of [step - 1, step, step + 1]) {
    if (st > f.last_step && safeEqual(await totpAt(secret, st), code)) matched = st;
  }
  if (!matched) throw badRequest('invalid_code');
  // Qayta ishlatishga qarshi: shu yoki oldingi qadam boshqa qabul qilinmaydi.
  const upd = await ctx.db
    .prepare('UPDATE totp_factors SET verified = 1, last_step = ?2 WHERE user_id = ?1 AND last_step < ?2')
    .bind(s.userId, matched)
    .run();
  if (!upd.meta.changes) throw badRequest('invalid_code');
  await ctx.db.prepare(`UPDATE sessions SET aal = 'aal2' WHERE token_hash = ?1`).bind(s.tokenHash).run();
  if (f.verified !== 1) await audit(ctx, s.userId, 'mfa_enrolled', s.userId);
  return json({ aal: 'aal2' });
}
