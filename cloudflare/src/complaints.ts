// Ilova ichidagi shikoyat / xabar (Profil → Aloqa va shikoyat; Apple 1.2:
// nomaqbul kontent haqida xabar berish va o'z vaqtida ko'rib chiqish).
//
// * Hisobli foydalanuvchi ham, mehmon ham yuboradi. Mehmonda hech qanday
//   identifikator saqlanmaydi; limit kaliti — IP ning HMAC qismi (saqlanmaydi,
//   faqat limit oynasi uchun).
// * Limit: soatiga 5 ta (hisob bo'yicha; mehmon — IP bo'yicha), oshsa
//   `429 rate_limited` + `Retry-After`.
// * Admin panel egasi ro'yxatni ko'radi (holat/tur filtri), izoh yozadi,
//   “hal qilindi” deb belgilaydi yoki qayta ochadi — har amal audit_log da.
// * Javobda faqat niqoblangan email (hisobli bo'lsa); hash yo'q.

import { audit, requirePanelAdmin, requireSession } from './auth';
import type { Ctx, Session } from './context';
import { iso } from './context';
import { sha256Hex } from './crypto';
import { badRequest, json, notFound, readJson } from './http';
import { hit } from './ratelimit';

export const COMPLAINTS_PER_HOUR = 5;
export const KINDS = ['complaint', 'inappropriate', 'bug', 'ad', 'other'] as const;
const KIND_SET = new Set<string>(KINDS);
const LANGS = new Set(['uz', 'ru', 'en']);
const UUID_RE = /^[0-9a-f-]{36}$/;
// Ishora: ekran/karta/post id — oddiy belgilar (havola yoki matn emas).
const REF_RE = /^[A-Za-z0-9_.:/-]{1,200}$/;

const tagOf = async (v: string) => (await sha256Hex(v)).slice(0, 32);

/** Sarlavha bo'lsa — sessiya tekshiriladi (yaroqsiz — 401); bo'lmasa mehmon. */
async function optionalSession(ctx: Ctx): Promise<Session | null> {
  if (!ctx.req.headers.get('authorization')) return null;
  return requireSession(ctx);
}

/** POST /v1/complaints {kind, body, target_ref?, lang?} → 201 {id, status}. */
export async function submit(ctx: Ctx): Promise<Response> {
  const s = await optionalSession(ctx);
  const body = await readJson(ctx.req, 8 * 1024);
  const kind = typeof body.kind === 'string' && KIND_SET.has(body.kind) ? body.kind : null;
  if (!kind) throw badRequest('invalid_kind');
  const text = typeof body.body === 'string' ? body.body.trim() : '';
  if (text.length < 5 || text.length > 2000) throw badRequest('invalid_body');
  let ref: string | null = null;
  if (body.target_ref != null && body.target_ref !== '') {
    if (typeof body.target_ref !== 'string' || !REF_RE.test(body.target_ref)) throw badRequest('invalid_target');
    ref = body.target_ref;
  }
  const lang = typeof body.lang === 'string' && LANGS.has(body.lang) ? body.lang : null;
  if (s) {
    await hit(ctx.db, `complaint-user:${await tagOf(s.userId)}`, COMPLAINTS_PER_HOUR, 3600, ctx.now);
    // Bitta NAT ortida ko'p hisob bo'lishi mumkin — IP limiti kengroq.
    await hit(ctx.db, `complaint-ip-auth:${ctx.ipTag}`, 30, 3600, ctx.now);
  } else {
    await hit(ctx.db, `complaint-ip:${ctx.ipTag}`, COMPLAINTS_PER_HOUR, 3600, ctx.now);
  }
  const id = crypto.randomUUID();
  await ctx.db
    .prepare(
      `INSERT INTO complaints (id, kind, body, target_ref, user_id, lang, status, created_at, updated_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, 'open', ?7, ?7)`,
    )
    .bind(id, kind, text, ref, s?.userId ?? null, lang, ctx.now)
    .run();
  return json({ id, status: 'open' }, 201);
}

interface Row {
  id: string;
  kind: string;
  body: string;
  target_ref: string | null;
  lang: string | null;
  status: string;
  admin_note: string | null;
  created_at: number;
  updated_at: number;
  resolved_at: number | null;
  user_id: string | null;
  email_masked: string | null;
}

const rowJson = (r: Row) => ({
  id: r.id,
  kind: r.kind,
  body: r.body,
  target_ref: r.target_ref,
  lang: r.lang,
  status: r.status,
  admin_note: r.admin_note,
  anonymous: r.user_id == null,
  user_id: r.user_id,
  email_masked: r.email_masked,
  created_at: iso(r.created_at),
  updated_at: iso(r.updated_at),
  resolved_at: iso(r.resolved_at),
});

async function panel(ctx: Ctx, write = false): Promise<Session> {
  const s = await requirePanelAdmin(ctx);
  const t = await tagOf(s.userId);
  if (write) await hit(ctx.db, `adm-w:${t}`, 120, 3600, ctx.now);
  else await hit(ctx.db, `adm-r:${t}`, 300, 600, ctx.now);
  return s;
}

/** GET /v1/admin/complaints?status=open|resolved&kind= — eng yangisi birinchi. */
export async function adminList(ctx: Ctx): Promise<Response> {
  await panel(ctx);
  const q = new URL(ctx.req.url).searchParams;
  const status = q.get('status');
  const kind = q.get('kind');
  if (status != null && status !== 'open' && status !== 'resolved') throw badRequest('invalid_status');
  if (kind != null && !KIND_SET.has(kind)) throw badRequest('invalid_kind');
  const rows = await ctx.db
    .prepare(
      `SELECT c.id, c.kind, c.body, c.target_ref, c.lang, c.status, c.admin_note, c.created_at,
         c.updated_at, c.resolved_at, c.user_id, u.email_masked
       FROM complaints c LEFT JOIN users u ON u.id = c.user_id
       WHERE (?1 IS NULL OR c.status = ?1) AND (?2 IS NULL OR c.kind = ?2)
       ORDER BY c.created_at DESC LIMIT 200`,
    )
    .bind(status, kind)
    .all<Row>();
  return json(rows.results.map(rowJson));
}

async function load(ctx: Ctx, id: string): Promise<Row> {
  if (!UUID_RE.test(id)) throw notFound();
  const r = await ctx.db
    .prepare(
      `SELECT c.id, c.kind, c.body, c.target_ref, c.lang, c.status, c.admin_note, c.created_at,
         c.updated_at, c.resolved_at, c.user_id, u.email_masked
       FROM complaints c LEFT JOIN users u ON u.id = c.user_id WHERE c.id = ?1`,
    )
    .bind(id)
    .first<Row>();
  if (!r) throw notFound();
  return r;
}

/** GET /v1/admin/complaints/:id. */
export async function adminGet(ctx: Ctx, id: string): Promise<Response> {
  await panel(ctx);
  return json(rowJson(await load(ctx, id)));
}

/** POST /v1/admin/complaints/:id/note {note} — admin izohi (bo'sh — o'chiradi). */
export async function adminNote(ctx: Ctx, id: string): Promise<Response> {
  const s = await panel(ctx, true);
  await load(ctx, id);
  const body = await readJson(ctx.req);
  if (body.note != null && typeof body.note !== 'string') throw badRequest('invalid_note');
  const note = typeof body.note === 'string' ? body.note.trim() : '';
  if (note.length > 2000) throw badRequest('invalid_note');
  await ctx.db
    .prepare('UPDATE complaints SET admin_note = ?2, updated_at = ?3 WHERE id = ?1')
    .bind(id, note || null, ctx.now)
    .run();
  await audit(ctx, s.userId, 'complaint_note', id, { length: note.length });
  return json(rowJson(await load(ctx, id)));
}

/** POST /v1/admin/complaints/:id/status {status: open|resolved}. */
export async function adminStatus(ctx: Ctx, id: string): Promise<Response> {
  const s = await panel(ctx, true);
  const cur = await load(ctx, id);
  const body = await readJson(ctx.req);
  const status = body.status === 'open' || body.status === 'resolved' ? body.status : null;
  if (!status) throw badRequest('invalid_status');
  if (cur.status !== status) {
    await ctx.db
      .prepare('UPDATE complaints SET status = ?2, resolved_at = ?3, updated_at = ?4 WHERE id = ?1')
      .bind(id, status, status === 'resolved' ? ctx.now : null, ctx.now)
      .run();
    await audit(ctx, s.userId, status === 'resolved' ? 'complaint_resolved' : 'complaint_reopened', id);
  }
  return json(rowJson(await load(ctx, id)));
}

type Handler = (ctx: Ctx, ...params: string[]) => Promise<Response>;

/** app.ts da `/v1/admin` umumiy (501) yo'lidan OLDIN ro'yxatga olinadi. */
export const ROUTES: [string, string, Handler][] = [
  ['POST', '/v1/complaints', submit],
  ['GET', '/v1/admin/complaints', adminList],
  ['GET', '/v1/admin/complaints/:c', adminGet],
  ['POST', '/v1/admin/complaints/:c/note', adminNote],
  ['POST', '/v1/admin/complaints/:c/status', adminStatus],
];
