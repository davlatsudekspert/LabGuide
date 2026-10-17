// “Taklif va yordam”: foydalanuvchi ↔ admin yozishmasi (Supabase
// `20261009000200_support.sql` qoidalari bilan bir xil ma'noda).
//
// * Foydalanuvchi faqat o'z murojaatlarini ko'radi; boshqasiniki — 404
//   (borligi ham bildirilmaydi). Admin panel egasi (ADMIN_EMAILS) — hammasini.
// * Javobni faqat inson (admin) yozadi: avtomatik/AI javob yo'q.
// * Spamga qarshi: kuniga 5 ta yangi murojaat, soatiga 30 ta xabar (hisob
//   bo'yicha), IP bo'yicha soatiga 60; mavzu 3–120, xabar 1–4000 belgi.
// * Skrinshot (R2) hali ulanmagan — biriktirma qabul qilinmaydi.
// * Har admin amali (javob, holat) audit_log ga yoziladi.

import { audit, isPanelAdmin, requirePanelAdmin, requireSession } from './auth';
import type { Ctx } from './context';
import { iso } from './context';
import { sha256Hex } from './crypto';
import { badRequest, json, notFound, readJson } from './http';
import { hit } from './ratelimit';

export const THREADS_PER_DAY = 5;
export const MESSAGES_PER_HOUR = 30;

const KINDS = new Set(['suggestion', 'bug', 'question']);
const STATUSES = new Set(['new', 'in_review', 'answered', 'closed']);
const ID_RE = /^[0-9a-f-]{36}$/;

interface ThreadRow {
  id: string;
  user_id: string;
  kind: string;
  subject: string;
  status: string;
  created_at: number;
  updated_at: number;
  last_user_message_at: number;
  last_admin_message_at: number | null;
  user_read_at: number;
  admin_read_at: number | null;
  email_masked?: string | null;
}

interface MessageRow {
  id: string;
  thread_id: string;
  from_admin: number;
  body: string;
  created_at: number;
}

export function threadJson(t: ThreadRow, withEmail = false) {
  return {
    id: t.id,
    user_id: t.user_id,
    kind: t.kind,
    subject: t.subject,
    status: t.status,
    created_at: iso(t.created_at),
    updated_at: iso(t.updated_at),
    last_user_message_at: iso(t.last_user_message_at),
    last_admin_message_at: iso(t.last_admin_message_at),
    user_read_at: iso(t.user_read_at),
    admin_read_at: iso(t.admin_read_at),
    ...(withEmail ? { email_masked: t.email_masked ?? null } : {}),
  };
}

const messageJson = (m: MessageRow) => ({
  id: m.id,
  thread_id: m.thread_id,
  from_admin: m.from_admin === 1,
  body: m.body,
  attachment_path: null,
  created_at: iso(m.created_at),
});

function text(v: unknown, code: string, min: number, max: number): string {
  if (typeof v !== 'string') throw badRequest(code);
  const t = v.trim();
  if (t.length < min || t.length > max) throw badRequest(code);
  return t;
}

/** Biriktirma (skrinshot) bu serverda hali yo'q — jim tashlab yuborilmaydi. */
function rejectAttachment(body: Record<string, unknown>) {
  if (body.attachment != null || body.attachment_path != null) throw badRequest('attachments_unavailable');
}

/** Limit kaliti: user_id ning SHA-256 bo'lagi (id ochiq holda yozilmaydi). */
const userTag = async (userId: string) => (await sha256Hex(userId)).slice(0, 32);

async function messageLimits(ctx: Ctx, userId: string) {
  await hit(ctx.db, `support-msg:${await userTag(userId)}`, MESSAGES_PER_HOUR, 3600, ctx.now);
  await hit(ctx.db, `support-ip:${ctx.ipTag}`, 60, 3600, ctx.now);
}

// ---------------------------------------------------------- foydalanuvchi
/** GET /v1/support/threads — faqat o'z murojaatlari. */
export async function myThreads(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const rows = await ctx.db
    .prepare(
      `SELECT t.id, t.user_id, t.kind, t.subject, t.status, t.created_at, t.updated_at, t.last_user_message_at,
         t.last_admin_message_at, t.user_read_at, t.admin_read_at
       FROM support_threads t WHERE t.user_id = ?1 ORDER BY t.updated_at DESC LIMIT 100`,
    )
    .bind(s.userId)
    .all<ThreadRow>();
  return json(rows.results.map((t) => threadJson(t)));
}

/** POST /v1/support/threads {kind, subject, body} → 201 {id}. */
export async function createThread(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const body = await readJson(ctx.req);
  rejectAttachment(body);
  const kind = typeof body.kind === 'string' && KINDS.has(body.kind) ? body.kind : null;
  if (!kind) throw badRequest('invalid_kind');
  const subject = text(body.subject, 'invalid_subject', 3, 120);
  const message = text(body.body, 'invalid_body', 1, 4000);
  await hit(ctx.db, `support-thread:${await userTag(s.userId)}`, THREADS_PER_DAY, 86400, ctx.now);
  await messageLimits(ctx, s.userId);
  const id = crypto.randomUUID();
  await ctx.db.batch([
    ctx.db
      .prepare(
        `INSERT INTO support_threads (id, user_id, kind, subject, status, created_at, updated_at,
           last_user_message_at, user_read_at) VALUES (?1, ?2, ?3, ?4, 'new', ?5, ?5, ?5, ?5)`,
      )
      .bind(id, s.userId, kind, subject, ctx.now),
    ctx.db
      .prepare('INSERT INTO support_messages (id, thread_id, from_admin, body, created_at) VALUES (?1, ?2, 0, ?3, ?4)')
      .bind(crypto.randomUUID(), id, message, ctx.now),
  ]);
  return json({ id }, 201);
}

async function ownThread(ctx: Ctx, userId: string, id: string): Promise<void> {
  if (!ID_RE.test(id)) throw notFound();
  const t = await ctx.db
    .prepare('SELECT 1 AS ok FROM support_threads WHERE id = ?1 AND user_id = ?2')
    .bind(id, userId)
    .first<{ ok: number }>();
  if (!t) throw notFound();
}

/** GET /v1/support/threads/:t/messages — murojaat egasi yoki admin panel egasi. */
export async function threadMessages(ctx: Ctx, id: string): Promise<Response> {
  const s = await requireSession(ctx);
  if (!ID_RE.test(id)) throw notFound();
  if (!(await isPanelAdmin(ctx, s))) await ownThread(ctx, s.userId, id);
  const rows = await ctx.db
    .prepare(
      `SELECT m.id, m.thread_id, m.from_admin, m.body, m.created_at FROM support_messages m
       JOIN support_threads t ON t.id = m.thread_id
       WHERE m.thread_id = ?1 ORDER BY m.created_at, m.rowid LIMIT 500`,
    )
    .bind(id)
    .all<MessageRow>();
  return json(rows.results.map(messageJson));
}

/**
 * POST /v1/support/threads/:t/messages {body} — faqat egasi. Javob berilgan
 * yoki yopilgan murojaat yana “Yangi” bo'ladi (admin navbatida ko'rinadi).
 */
export async function postMessage(ctx: Ctx, id: string): Promise<Response> {
  const s = await requireSession(ctx);
  await ownThread(ctx, s.userId, id);
  const body = await readJson(ctx.req);
  rejectAttachment(body);
  const message = text(body.body, 'invalid_body', 1, 4000);
  await messageLimits(ctx, s.userId);
  const mid = crypto.randomUUID();
  await ctx.db.batch([
    ctx.db
      .prepare('INSERT INTO support_messages (id, thread_id, from_admin, body, created_at) VALUES (?1, ?2, 0, ?3, ?4)')
      .bind(mid, id, message, ctx.now),
    ctx.db
      .prepare(
        `UPDATE support_threads SET last_user_message_at = ?2, updated_at = ?2, user_read_at = ?2,
           status = CASE WHEN status IN ('answered', 'closed') THEN 'new' ELSE status END
         WHERE id = ?1`,
      )
      .bind(id, ctx.now),
  ]);
  return json({ id: mid }, 201);
}

/** POST /v1/support/threads/:t/read — foydalanuvchi javobni ko'rdi. */
export async function markRead(ctx: Ctx, id: string): Promise<Response> {
  const s = await requireSession(ctx);
  await ownThread(ctx, s.userId, id);
  await ctx.db.prepare('UPDATE support_threads SET user_read_at = ?2 WHERE id = ?1').bind(id, ctx.now).run();
  return json({ ok: true });
}

// ------------------------------------------------------------------ admin
async function adminLimit(ctx: Ctx, userId: string, write: boolean) {
  await hit(ctx.db, `${write ? 'adm-w' : 'adm-r'}:${await userTag(userId)}`, write ? 120 : 300, write ? 3600 : 600, ctx.now);
}

/** GET /v1/admin/support/threads?status= — hamma murojaatlar (niqoblangan email bilan). */
export async function adminThreads(ctx: Ctx): Promise<Response> {
  const s = await requirePanelAdmin(ctx);
  await adminLimit(ctx, s.userId, false);
  const raw = new URL(ctx.req.url).searchParams.get('status');
  if (raw != null && !STATUSES.has(raw)) throw badRequest('invalid_status');
  const rows = await ctx.db
    .prepare(
      `SELECT t.id, t.user_id, t.kind, t.subject, t.status, t.created_at, t.updated_at, t.last_user_message_at,
         t.last_admin_message_at, t.user_read_at, t.admin_read_at, u.email_masked FROM support_threads t
       LEFT JOIN users u ON u.id = t.user_id
       WHERE (?1 IS NULL OR t.status = ?1) ORDER BY t.updated_at DESC LIMIT 200`,
    )
    .bind(raw)
    .all<ThreadRow>();
  return json(rows.results.map((t) => threadJson(t, true)));
}

async function existingThread(ctx: Ctx, id: string): Promise<void> {
  if (!ID_RE.test(id)) throw notFound();
  const t = await ctx.db.prepare('SELECT 1 AS ok FROM support_threads WHERE id = ?1').bind(id).first();
  if (!t) throw notFound();
}

/** POST /v1/admin/support/threads/:t/reply {body} — javobni admin o'zi yozadi. */
export async function adminReply(ctx: Ctx, id: string): Promise<Response> {
  const s = await requirePanelAdmin(ctx);
  await adminLimit(ctx, s.userId, true);
  await existingThread(ctx, id);
  const body = await readJson(ctx.req);
  const message = text(body.body, 'invalid_body', 1, 4000);
  const mid = crypto.randomUUID();
  await ctx.db.batch([
    ctx.db
      .prepare('INSERT INTO support_messages (id, thread_id, from_admin, body, created_at) VALUES (?1, ?2, 1, ?3, ?4)')
      .bind(mid, id, message, ctx.now),
    ctx.db
      .prepare(
        `UPDATE support_threads SET status = 'answered', last_admin_message_at = ?2, admin_read_at = ?2,
           updated_at = ?2 WHERE id = ?1`,
      )
      .bind(id, ctx.now),
  ]);
  await audit(ctx, s.userId, 'support_reply', id);
  return json({ id: mid }, 201);
}

/** POST /v1/admin/support/threads/:t/status {status}. */
export async function adminSetStatus(ctx: Ctx, id: string): Promise<Response> {
  const s = await requirePanelAdmin(ctx);
  await adminLimit(ctx, s.userId, true);
  await existingThread(ctx, id);
  const body = await readJson(ctx.req);
  const status = typeof body.status === 'string' && STATUSES.has(body.status) ? body.status : null;
  if (!status) throw badRequest('invalid_status');
  await ctx.db
    .prepare('UPDATE support_threads SET status = ?2, updated_at = ?3 WHERE id = ?1')
    .bind(id, status, ctx.now)
    .run();
  await audit(ctx, s.userId, 'support_status', id, { status });
  return json({ status });
}

/** POST /v1/admin/support/threads/:t/read — admin o'qidi (audit shart emas: holat emas). */
export async function adminMarkRead(ctx: Ctx, id: string): Promise<Response> {
  const s = await requirePanelAdmin(ctx);
  await adminLimit(ctx, s.userId, false);
  await existingThread(ctx, id);
  await ctx.db.prepare('UPDATE support_threads SET admin_read_at = ?2 WHERE id = ?1').bind(id, ctx.now).run();
  return json({ ok: true });
}

type Handler = (ctx: Ctx, ...params: string[]) => Promise<Response>;

/** app.ts da `/v1/support` va `/v1/admin` umumiy (501) yo'llaridan OLDIN ro'yxatga olinadi. */
export const ROUTES: [string, string, Handler][] = [
  ['GET', '/v1/support/threads', myThreads],
  ['POST', '/v1/support/threads', createThread],
  ['GET', '/v1/support/threads/:t/messages', threadMessages],
  ['POST', '/v1/support/threads/:t/messages', postMessage],
  ['POST', '/v1/support/threads/:t/read', markRead],
  ['GET', '/v1/admin/support/threads', adminThreads],
  ['POST', '/v1/admin/support/threads/:t/reply', adminReply],
  ['POST', '/v1/admin/support/threads/:t/status', adminSetStatus],
  ['POST', '/v1/admin/support/threads/:t/read', adminMarkRead],
];
