// Admin tomonidan Pro berish (D-73). INERT: LG_BILLING_ENABLED=true bo'lmasa
// bu yo'llar umuman yo'q (app.ts → 404).
//
// Xavfsizlik:
// * Faqat serverda berilgan admin roli + TOTP (aal2): `requireAdmin` (oddiy
//   foydalanuvchi va 2FA siz admin — 403). Ilova hech narsani o'zi hal qilmaydi.
// * Email ochiq saqlanmaydi (HMAC + niqob); javoblarda faqat niqob.
// * Har bir berish / almashtirish / uzaytirish / bekor qilish audit_log ga:
//   kim (actor), kimga (niqoblangan email + hisob id si), daraja, muddat.
// * Limitlar: yozish soatiga 30 (berish) / 60 (bekor), o'qish 10 daqiqada 60.
// * Do'kon obunasini bosib o'tmaydi (billing.ts `resolveAccess`).

import { audit, emailHash, maskEmail, normalizeEmail, requireAdmin } from './auth';
import { PLAN_RANK, PLANS, type Plan } from './billing';
import { userHash } from './community';
import type { Ctx } from './context';
import { iso } from './context';
import { badRequest, conflict, json, noContent, notFound, readJson } from './http';
import { hit } from './ratelimit';

export const GRANT_PER_HOUR = 30;
export const REVOKE_PER_HOUR = 60;
export const LIST_PER_10_MIN = 60;
export const MAX_ACTIVE_PRO_GRANTS = 2000;
export const DURATIONS = [30, 90, 365] as const;
export const MAX_NOTE = 200;
const DAY = 86400_000;
const ID_RE = /^[0-9a-f-]{36}$/;

interface Row {
  id: string;
  email_masked: string;
  tier: Plan;
  duration_days: number | null;
  starts_at: number | null;
  expires_at: number | null;
  note: string | null;
  created_at: number;
  updated_at: number;
}

const view = (g: Row, now: number) => ({
  id: g.id,
  email_masked: g.email_masked,
  tier: g.tier,
  // Hisob yo'q — kutilmoqda; muddat o'tgan — tugagan.
  status: g.starts_at == null ? 'pending' : g.expires_at != null && g.expires_at <= now ? 'expired' : 'active',
  duration_days: g.duration_days,
  starts_at: iso(g.starts_at),
  expires_at: iso(g.expires_at),
  note: g.note,
  created_at: iso(g.created_at),
});

const NOTE_BAD = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/;

function parseTier(raw: unknown): Plan {
  if (typeof raw !== 'string' || !(PLANS as string[]).includes(raw)) throw badRequest('invalid_tier');
  return raw as Plan;
}

function parseDuration(raw: unknown): number | null {
  if (raw === undefined || raw === null) return null; // bekor qilinguncha
  if (typeof raw !== 'number' || !(DURATIONS as readonly number[]).includes(raw)) throw badRequest('invalid_duration');
  return raw;
}

function parseNote(raw: unknown): string | null {
  if (raw === undefined || raw === null) return null;
  if (typeof raw !== 'string') throw badRequest('invalid_note');
  const n = raw.trim();
  if (n.length > MAX_NOTE || NOTE_BAD.test(n)) throw badRequest('invalid_note');
  return n === '' ? null : n;
}

/** Admin vakolati + limit; yozishda `write` — soatlik, aks holda o'qish limiti. */
async function admin(ctx: Ctx, bucket: 'grant' | 'revoke' | 'list') {
  const s = await requireAdmin(ctx);
  const [key, limit, sec] =
    bucket === 'grant'
      ? ['pro-grant', GRANT_PER_HOUR, 3600]
      : bucket === 'revoke'
        ? ['pro-revoke', REVOKE_PER_HOUR, 3600]
        : ['pro-list', LIST_PER_10_MIN, 600];
  await hit(ctx.db, `${key}:${s.userId}`, limit as number, sec as number, ctx.now);
  return s;
}

/** GET /v1/admin/pro-grants — faol va kutilayotgan grantlar. */
export async function listGrants(ctx: Ctx): Promise<Response> {
  await admin(ctx, 'list');
  const rows = await ctx.db
    .prepare(
      `SELECT id, email_masked, tier, duration_days, starts_at, expires_at, note, created_at, updated_at FROM pro_grants
       WHERE revoked_at IS NULL AND (starts_at IS NULL OR expires_at IS NULL OR expires_at > ?1)
       ORDER BY created_at DESC LIMIT 500`,
    )
    .bind(ctx.now)
    .all<Row>();
  return json({
    max_active: MAX_ACTIVE_PRO_GRANTS,
    grants: rows.results.map((g) => view(g, ctx.now)),
  });
}

/**
 * POST /v1/admin/pro-grants {email, tier, durationDays?, note?, mode?}.
 * `mode`: `replace` (standart — mavjud faol grantni almashtiradi, muddat
 * hozirdan qayta boshlanadi) yoki `extend` (muddatni uzaytiradi; daraja
 * yuqorisi saqlanadi; faqat qo'llangan va muddatli grantga).
 * Javob: 201 (yangi) yoki 200 (`replaced`/`extended`).
 */
export async function createGrant(ctx: Ctx): Promise<Response> {
  const s = await admin(ctx, 'grant');
  const body = await readJson(ctx.req);
  const email = normalizeEmail(body.email);
  if (!email) throw badRequest('invalid_email');
  const tier = parseTier(body.tier ?? body.plan);
  const days = parseDuration(body.durationDays ?? body.duration_days);
  const note = parseNote(body.note);
  const mode = body.mode ?? 'replace';
  if (mode !== 'replace' && mode !== 'extend') throw badRequest('invalid_mode');

  const eh = await emailHash(ctx, email);
  const by = await userHash(ctx, s.userId);
  const user = await ctx.db.prepare('SELECT id FROM users WHERE email_hash = ?1').bind(eh).first<{ id: string }>();
  const now = ctx.now;
  const untilOf = (from: number) => (days == null ? null : from + days * DAY);

  const cur = await ctx.db
    .prepare(`SELECT id, email_masked, tier, duration_days, starts_at, expires_at, note, created_at, updated_at FROM pro_grants WHERE email_hmac = ?1 AND revoked_at IS NULL`)
    .bind(eh)
    .first<Row>();

  const detail = (g: { tier: string; starts_at: number | null; expires_at: number | null }) => ({
    email: maskEmail(email),
    tier: g.tier,
    until: iso(g.expires_at),
    pending: g.starts_at == null,
    target_user: user?.id ?? null,
  });

  if (!cur) {
    const n = await ctx.db
      .prepare('SELECT COUNT(*) AS n FROM pro_grants WHERE revoked_at IS NULL')
      .first<{ n: number }>();
    if ((n?.n ?? 0) >= MAX_ACTIVE_PRO_GRANTS) throw conflict('too_many_grants');
    const id = crypto.randomUUID();
    const starts = user ? now : null;
    const expires = user ? untilOf(now) : null;
    const r = await ctx.db
      .prepare(
        `INSERT INTO pro_grants (id, email_hmac, email_masked, tier, duration_days, starts_at, expires_at, note,
           granted_by_hash, created_at, updated_at)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?10) ON CONFLICT DO NOTHING`,
      )
      .bind(id, eh, maskEmail(email), tier, days, starts, expires, note, by, now)
      .run();
    if (!r.meta.changes) throw conflict('grant_conflict'); // parallel so'rov
    await audit(ctx, s.userId, 'pro_grant_created', id, detail({ tier, starts_at: starts, expires_at: expires }));
    const g = await ctx.db.prepare(`SELECT id, email_masked, tier, duration_days, starts_at, expires_at, note, created_at, updated_at FROM pro_grants WHERE id = ?1`).bind(id).first<Row>();
    return json({ ...view(g!, now), replaced: false, extended: false }, 201);
  }

  if (mode === 'extend') {
    if (cur.starts_at == null) throw conflict('pending_cannot_extend');
    if (days == null) throw badRequest('duration_required');
    const base = cur.expires_at == null ? null : Math.max(cur.expires_at, now);
    // Muddatsiz grant uzaytirishda o'zgarmaydi (faqat daraja ko'tarilishi mumkin).
    const expires = base == null ? null : base + days * DAY;
    const higher = PLAN_RANK[tier] >= PLAN_RANK[cur.tier] ? tier : cur.tier;
    await ctx.db
      .prepare(
        `UPDATE pro_grants SET tier = ?2, expires_at = ?3, note = COALESCE(?4, note), updated_at = ?5
         WHERE id = ?1 AND revoked_at IS NULL`,
      )
      .bind(cur.id, higher, expires, note, now)
      .run();
    await audit(ctx, s.userId, 'pro_grant_extended', cur.id, {
      ...detail({ tier: higher, starts_at: cur.starts_at, expires_at: expires }),
      added_days: days,
    });
    const g = await ctx.db.prepare(`SELECT id, email_masked, tier, duration_days, starts_at, expires_at, note, created_at, updated_at FROM pro_grants WHERE id = ?1`).bind(cur.id).first<Row>();
    return json({ ...view(g!, now), replaced: false, extended: true });
  }

  // replace: daraja, muddat va izoh YANGI qiymatlar (hisob bor bo'lsa hozirdan).
  const starts = user ? now : null;
  const expires = user ? untilOf(now) : null;
  await ctx.db
    .prepare(
      `UPDATE pro_grants SET tier = ?2, duration_days = ?3, starts_at = ?4, expires_at = ?5, note = ?6,
         granted_by_hash = ?7, updated_at = ?8 WHERE id = ?1 AND revoked_at IS NULL`,
    )
    .bind(cur.id, tier, days, starts, expires, note, by, now)
    .run();
  await audit(ctx, s.userId, 'pro_grant_replaced', cur.id, {
    ...detail({ tier, starts_at: starts, expires_at: expires }),
    previous_tier: cur.tier,
    previous_until: iso(cur.expires_at),
  });
  const g = await ctx.db.prepare(`SELECT id, email_masked, tier, duration_days, starts_at, expires_at, note, created_at, updated_at FROM pro_grants WHERE id = ?1`).bind(cur.id).first<Row>();
  return json({ ...view(g!, now), replaced: true, extended: false });
}

/** DELETE /v1/admin/pro-grants/:id — huquq darhol yo'qoladi (keyingi so'rovdan). */
export async function revokeGrant(ctx: Ctx, id: string): Promise<Response> {
  const s = await admin(ctx, 'revoke');
  if (!ID_RE.test(id)) throw notFound();
  const g = await ctx.db
    .prepare(`SELECT id, email_masked, tier, duration_days, starts_at, expires_at, note, created_at, updated_at, email_hmac FROM pro_grants WHERE id = ?1 AND revoked_at IS NULL`)
    .bind(id)
    .first<Row & { email_hmac: string }>();
  if (!g) throw notFound();
  const user = await ctx.db
    .prepare('SELECT id FROM users WHERE email_hash = ?1')
    .bind(g.email_hmac)
    .first<{ id: string }>();
  const r = await ctx.db
    .prepare('UPDATE pro_grants SET revoked_at = ?2, revoked_by_hash = ?3, updated_at = ?2 WHERE id = ?1 AND revoked_at IS NULL')
    .bind(id, ctx.now, await userHash(ctx, s.userId))
    .run();
  if (!r.meta.changes) throw notFound();
  await audit(ctx, s.userId, 'pro_grant_revoked', id, {
    email: g.email_masked,
    tier: g.tier,
    until: iso(g.expires_at),
    pending: g.starts_at == null,
    target_user: user?.id ?? null,
  });
  return noContent();
}

/**
 * Hisob ochilganda / kirganda: shu emailning KUTILAYOTGAN grantini qo'llaydi
 * (muddat shu paytdan). Kirishni hech qachon to'xtatmaydi.
 */
export async function applyPendingGrants(ctx: Ctx, eh: string, userId: string): Promise<void> {
  try {
    const rows = await ctx.db
      .prepare(
        `SELECT id, tier, duration_days, email_masked FROM pro_grants
         WHERE email_hmac = ?1 AND revoked_at IS NULL AND starts_at IS NULL`,
      )
      .bind(eh)
      .all<{ id: string; tier: string; duration_days: number | null; email_masked: string }>();
    for (const g of rows.results) {
      const until = g.duration_days == null ? null : ctx.now + g.duration_days * DAY;
      const r = await ctx.db
        .prepare(
          `UPDATE pro_grants SET starts_at = ?2, expires_at = ?3, updated_at = ?2
           WHERE id = ?1 AND revoked_at IS NULL AND starts_at IS NULL`,
        )
        .bind(g.id, ctx.now, until)
        .run();
      if (r.meta.changes) {
        await audit(ctx, null, 'pro_grant_applied', g.id, {
          email: g.email_masked,
          tier: g.tier,
          until: iso(until),
          target_user: userId,
        });
      }
    }
  } catch (e) {
    console.error('pro grant apply failed', e instanceof Error ? e.name : typeof e);
  }
}
