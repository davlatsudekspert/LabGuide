// Adminlar boshqaruvi (D-44): super admin (LG_ADMIN_EMAILS) boshqa emailni
// admin qiladi va olib tashlaydi. Email ochiq holda saqlanmaydi va javobda
// faqat niqoblangan ko'rinishda qaytadi.

import type { Ctx, Session } from './context';
import { iso } from './context';
import {
  adminAllowlist,
  audit,
  emailHash,
  isSuperAdmin,
  maskEmail,
  normalizeEmail,
  requireAdmin,
} from './auth';
import { userHash } from './community';
import { badRequest, conflict, forbidden, json, noContent, notFound, readJson } from './http';
import { hit } from './ratelimit';
import { requireStepUp } from './stepup';

/** Bir vaqtda faol qo'shilgan adminlar chegarasi (super adminlardan tashqari). */
export const MAX_ACTIVE_GRANTS = 20;
export const GRANT_ADD_PER_HOUR = 10;
export const GRANT_REMOVE_PER_HOUR = 20;
export const ADMIN_LIST_PER_10_MIN = 60;

const ID_RE = /^[0-9a-f-]{36}$/;

interface GrantRow {
  id: string;
  email_hmac: string;
  email_masked: string;
  created_at: number;
  user_id: string | null;
}

/** Faqat super admin (LG_ADMIN_EMAILS) + TOTP (aal2). */
async function requireSuperAdmin(ctx: Ctx): Promise<Session> {
  const s = await requireAdmin(ctx);
  if (!(await isSuperAdmin(ctx, s.userId))) throw forbidden('not_super_admin');
  return s;
}

/** GET /v1/admin/admins — har admin (aal2) ko'radi; o'zgartirish — faqat super admin. */
export async function listAdmins(ctx: Ctx): Promise<Response> {
  const s = await requireAdmin(ctx);
  await hit(ctx.db, `admins-list:${s.userId}`, ADMIN_LIST_PER_10_MIN, 600, ctx.now);
  const me = await ctx.db
    .prepare('SELECT email_hash FROM users WHERE id = ?1')
    .bind(s.userId)
    .first<{ email_hash: string }>();
  const supers = [];
  for (const email of adminAllowlist(ctx)) {
    const eh = await emailHash(ctx, email);
    const u = await ctx.db
      .prepare('SELECT id FROM users WHERE email_hash = ?1')
      .bind(eh)
      .first<{ id: string }>();
    supers.push({
      id: null,
      email_masked: maskEmail(email),
      kind: 'super',
      active: !!u,
      you: me?.email_hash === eh,
      created_at: null,
    });
  }
  const grants = await ctx.db
    .prepare(
      `SELECT g.id, g.email_hmac, g.email_masked, g.created_at, u.id AS user_id
       FROM admin_grants g LEFT JOIN users u ON u.email_hash = g.email_hmac
       WHERE g.revoked_at IS NULL ORDER BY g.created_at DESC`,
    )
    .all<GrantRow>();
  return json({
    can_manage: await isSuperAdmin(ctx, s.userId),
    max_granted: MAX_ACTIVE_GRANTS,
    admins: [
      ...supers,
      ...grants.results.map((g) => ({
        id: g.id,
        email_masked: g.email_masked,
        kind: 'granted',
        // Hisob bor — vakolat kuchda (2FA dan keyin); yo'q — birinchi kirishda.
        active: g.user_id != null,
        you: me?.email_hash === g.email_hmac,
        created_at: iso(g.created_at),
      })),
    ],
  });
}

/** POST /v1/admin/admins {email} — faqat super admin. */
export async function addAdmin(ctx: Ctx): Promise<Response> {
  const s = await requireSuperAdmin(ctx);
  await hit(ctx.db, `admins-add:${s.userId}`, GRANT_ADD_PER_HOUR, 3600, ctx.now);
  const body = await readJson(ctx.req);
  const email = normalizeEmail(body.email);
  if (!email) throw badRequest('invalid_email');
  if (adminAllowlist(ctx).includes(email)) throw conflict('already_super_admin');
  const eh = await emailHash(ctx, email);
  const active = await ctx.db
    .prepare('SELECT COUNT(*) AS n, SUM(email_hmac = ?1) AS mine FROM admin_grants WHERE revoked_at IS NULL')
    .bind(eh)
    .first<{ n: number; mine: number | null }>();
  if ((active?.mine ?? 0) > 0) throw conflict('already_admin');
  if ((active?.n ?? 0) >= MAX_ACTIVE_GRANTS) throw conflict('too_many_admins');
  await requireStepUp(ctx, s, 'admins');

  const id = crypto.randomUUID();
  const masked = maskEmail(email);
  const r = await ctx.db
    .prepare(
      `INSERT INTO admin_grants (id, email_hmac, email_masked, granted_by_hash, created_at)
       VALUES (?1, ?2, ?3, ?4, ?5) ON CONFLICT DO NOTHING`,
    )
    .bind(id, eh, masked, await userHash(ctx, s.userId), ctx.now)
    .run();
  if (!r.meta.changes) throw conflict('already_admin');
  await audit(ctx, s.userId, 'admin_grant_added', id);

  // Hisob mavjud bo'lsa — darhol (keyingi so'rovidan; admin amali baribir aal2).
  const user = await ctx.db
    .prepare('SELECT id FROM users WHERE email_hash = ?1')
    .bind(eh)
    .first<{ id: string }>();
  if (user) {
    const g = await ctx.db
      .prepare(
        `INSERT INTO admins (user_id, granted_at, granted_reason) VALUES (?1, ?2, 'admin_grant')
         ON CONFLICT (user_id) DO NOTHING`,
      )
      .bind(user.id, ctx.now)
      .run();
    if (g.meta.changes) await audit(ctx, s.userId, 'admin_granted', user.id, { reason: 'grant', grant: id });
  }
  return json(
    {
      id,
      email_masked: masked,
      kind: 'granted',
      active: !!user,
      you: false,
      created_at: iso(ctx.now),
    },
    201,
  );
}

/**
 * DELETE /v1/admin/admins/:id — faqat super admin. Super adminlarning id si
 * yo'q (ular maxfiy ro'yxatda) — API orqali olib tashlanmaydi.
 */
export async function removeAdmin(ctx: Ctx, id: string): Promise<Response> {
  const s = await requireSuperAdmin(ctx);
  await hit(ctx.db, `admins-remove:${s.userId}`, GRANT_REMOVE_PER_HOUR, 3600, ctx.now);
  if (!ID_RE.test(id)) throw notFound();
  const g = await ctx.db
    .prepare('SELECT email_hmac FROM admin_grants WHERE id = ?1 AND revoked_at IS NULL')
    .bind(id)
    .first<{ email_hmac: string }>();
  if (!g) throw notFound();
  await requireStepUp(ctx, s, 'admins');
  const user = await ctx.db
    .prepare('SELECT id FROM users WHERE email_hash = ?1')
    .bind(g.email_hmac)
    .first<{ id: string }>();
  const by = await userHash(ctx, s.userId);
  const stmts = [
    ctx.db
      .prepare('UPDATE admin_grants SET revoked_at = ?2, revoked_by_hash = ?3 WHERE id = ?1 AND revoked_at IS NULL')
      .bind(id, ctx.now, by),
  ];
  if (user) {
    stmts.push(
      // Faqat shu grant bergan vakolat ('manual' va super admin tegilmaydi).
      ctx.db
        .prepare(`DELETE FROM admins WHERE user_id = ?1 AND granted_reason = 'admin_grant'`)
        .bind(user.id),
      // Mavjud sessiyalar darhol: admin_account false; aal2 ham tushiriladi.
      ctx.db.prepare(`UPDATE sessions SET aal = 'aal1' WHERE user_id = ?1`).bind(user.id),
    );
  }
  await ctx.db.batch(stmts);
  await audit(ctx, s.userId, 'admin_grant_removed', id);
  if (user) await audit(ctx, s.userId, 'admin_revoked', user.id, { reason: 'grant_removed', grant: id });
  return noContent();
}
