// Ustoz–talaba: guruhlar, a'zolik, mavzular, savol-javob belgilari,
// test sessiyalari va natijalar. Har amal serverda vakolat tekshiradi:
// ustoz — faqat o'zi yaratgan guruh; talaba — faqat o'z javoblari.

import { audit, requireSession } from './auth';
import type { Ctx, Session } from './context';
import { iso } from './context';
import { randomFrom } from './crypto';
import {
  ApiError,
  badRequest,
  conflict,
  forbidden,
  json,
  noContent,
  notFound,
  readJson,
} from './http';
import { hit } from './ratelimit';

// Adashtiradigan 0/O/1/I siz — QR va qo'lda yozish uchun.
const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const CODE_RE = /^[A-HJ-NP-Z2-9]{8}$/;
/** Savol va belgi id lari (qa_marks CHECK: 1–64). */
const ID_RE = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,63}$/;
/** O'quv dasturi mavzusi id si — ilova kontrakti bilan bir xil (1–80). */
export const TOPIC_RE = /^[A-Za-z0-9][A-Za-z0-9_.:-]{0,79}$/;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
/** Taxallus: 2–24 belgi (ilova kontrakti), faqat harf/raqam/bo'shliq/._'- */
const NICK_RE = /^[\p{L}\p{N}][\p{L}\p{N} ._'-]{0,22}[\p{L}\p{N}.]$/u;

const MAX_GROUPS_PER_TEACHER = 10;
const MAX_MEMBERS = 200;
const MAX_TOPICS = 300;
const GRACE_MS = 2 * 60_000;
const STAGES = new Set(['lecture', 'oral']);

type Role = 'teacher' | 'student';

function str(v: unknown, min: number, max: number, code = 'invalid'): string {
  if (typeof v !== 'string') throw badRequest(code);
  const t = v.trim();
  if (t.length < min || t.length > max) throw badRequest(code);
  return t;
}

function id(v: unknown, code = 'invalid_id'): string {
  if (typeof v !== 'string' || !ID_RE.test(v)) throw badRequest(code);
  return v;
}

function topicId(v: unknown): string {
  if (typeof v !== 'string' || !TOPIC_RE.test(v)) throw badRequest('invalid_topic');
  return v;
}

/** Yo'l bo'lagi; buzuq `%` kodlash — 400 (500 emas). */
function decodeSeg(v: string): string {
  try {
    return decodeURIComponent(v);
  } catch {
    throw badRequest('invalid_id');
  }
}

export function uuidParam(v: string): string {
  if (!UUID_RE.test(v)) throw new ApiError(404, 'not_found');
  return v;
}

function nickname(v: unknown): string | null {
  if (v == null || v === '') return null;
  if (typeof v !== 'string') throw badRequest('invalid_nickname');
  const t = v.trim().replace(/\s+/g, ' ');
  if (t === '') return null;
  // Email yoki havola emas: faqat harf, raqam, bo'sh joy va . _ ' -
  if (!NICK_RE.test(t)) throw badRequest('invalid_nickname');
  return t;
}

export function displayName(role: Role, no: number, nick: string | null): string {
  if (nick) return nick;
  return role === 'teacher' ? 'Ustoz' : `Talaba ${String(no).padStart(2, '0')}`;
}

interface Membership {
  role: Role;
  owner: boolean;
}

async function membership(ctx: Ctx, gid: string, uid: string): Promise<Membership | null> {
  const r = await ctx.db
    .prepare(
      `SELECT m.member_role, g.owner_id FROM group_members m
       JOIN study_groups g ON g.id = m.group_id
       WHERE m.group_id = ?1 AND m.user_id = ?2`,
    )
    .bind(gid, uid)
    .first<{ member_role: Role; owner_id: string }>();
  return r ? { role: r.member_role, owner: r.owner_id === uid } : null;
}

/** A'zo bo'lmaganga guruh borligi ham bildirilmaydi (404). */
async function requireMember(ctx: Ctx, s: Session, gid: string): Promise<Membership> {
  const m = await membership(ctx, uuidParam(gid), s.userId);
  if (!m) throw notFound();
  return m;
}

/**
 * Guruh egasi va ro'yxatdan o'tgan ustoz (Supabase `_owns_group`).
 * A'zo bo'lmagan — 404 (guruh borligi bildirilmaydi), a'zo-talaba — 403.
 */
async function requireTeacher(ctx: Ctx, s: Session, gid: string): Promise<void> {
  const m = await requireMember(ctx, s, gid);
  if (!(m.role === 'teacher' && m.owner) || !(await isTeacherAccount(ctx, s.userId))) throw forbidden();
}

export async function isTeacherAccount(ctx: Ctx, uid: string): Promise<boolean> {
  const r = await ctx.db.prepare('SELECT 1 AS x FROM teacher_accounts WHERE user_id = ?1').bind(uid).first();
  return r != null;
}

/**
 * O'zini ustoz sifatida ro'yxatdan o'tkazish. Hisob faqat email kodi
 * tasdiqlangandan keyin paydo bo'ladi (users qatori OTP verify da yaratiladi),
 * shuning uchun yaroqli sessiya = tasdiqlangan email. Admin vakolatiga ta'sir
 * qilmaydi. Qayta chaqirish — xato emas.
 */
export async function registerTeacher(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const r = await ctx.db
    .prepare(
      `INSERT INTO teacher_accounts (user_id, registered_at)
       SELECT id, ?2 FROM users WHERE id = ?1
       ON CONFLICT (user_id) DO NOTHING`,
    )
    .bind(s.userId, ctx.now)
    .run();
  if (r.meta.changes) await audit(ctx, s.userId, 'teacher_registered', s.userId);
  return json({ teacher: true });
}

async function uniqueCode(ctx: Ctx): Promise<string> {
  for (let i = 0; i < 10; i++) {
    const code = randomFrom(CODE_ALPHABET, 8);
    const taken = await ctx.db
      .prepare('SELECT 1 FROM study_groups WHERE join_code = ?1')
      .bind(code)
      .first();
    if (!taken) return code;
  }
  throw new Error('join code space exhausted');
}

// ---------------------------------------------------------------- groups
export async function listGroups(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const rows = await ctx.db
    .prepare(
      `SELECT g.id, g.name, g.join_code, g.owner_id, g.created_at, m.member_role, m.member_no, m.nickname,
              (SELECT COUNT(*) FROM group_members x WHERE x.group_id = g.id) AS member_count
       FROM group_members m JOIN study_groups g ON g.id = m.group_id
       WHERE m.user_id = ?1 ORDER BY g.created_at DESC`,
    )
    .bind(s.userId)
    .all<{
      id: string;
      name: string;
      join_code: string;
      owner_id: string;
      created_at: number;
      member_role: Role;
      member_no: number;
      nickname: string | null;
      member_count: number;
    }>();
  return json(
    rows.results.map((g) => {
      const teacher = g.member_role === 'teacher' && g.owner_id === s.userId;
      return {
        id: g.id,
        name: g.name,
        join_code: teacher ? g.join_code : null,
        is_teacher: teacher,
        member_count: g.member_count,
        my_display_name: displayName(g.member_role, g.member_no, g.nickname),
        created_at: iso(g.created_at),
      };
    }),
  );
}

export async function createGroup(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  // Profil roli emas — ro'yxatdan o'tgan ustoz hisobi (POST /v1/me/teacher).
  if (!(await isTeacherAccount(ctx, s.userId))) throw forbidden('teacher_role_required');
  const body = await readJson(ctx.req);
  const name = str(body.name, 3, 80, 'invalid_name');
  const nick = nickname(body.display_name);
  const count = await ctx.db
    .prepare('SELECT COUNT(*) AS n FROM study_groups WHERE owner_id = ?1')
    .bind(s.userId)
    .first<{ n: number }>();
  if ((count?.n ?? 0) >= MAX_GROUPS_PER_TEACHER) throw new ApiError(429, 'limit_groups');
  const gid = crypto.randomUUID();
  const code = await uniqueCode(ctx);
  await ctx.db.batch([
    ctx.db
      .prepare(
        'INSERT INTO study_groups (id, owner_id, name, join_code, next_member_no, created_at) VALUES (?1, ?2, ?3, ?4, 1, ?5)',
      )
      .bind(gid, s.userId, name, code, ctx.now),
    ctx.db
      .prepare(
        `INSERT INTO group_members (group_id, user_id, member_role, member_no, nickname, joined_at)
         VALUES (?1, ?2, 'teacher', 0, ?3, ?4)`,
      )
      .bind(gid, s.userId, nick, ctx.now),
  ]);
  return json({ id: gid, name, join_code: code, is_teacher: true, member_count: 1 }, 201);
}

/** Taklif kodi bilan qo'shilish; kodni taxmin qilishga qarshi limit. */
export async function joinGroup(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  await hit(ctx.db, `join-user:${s.userId}`, 10, 900, ctx.now);
  await hit(ctx.db, `join-ip:${ctx.ipTag}`, 100, 3600, ctx.now);
  const body = await readJson(ctx.req);
  const code = typeof body.code === 'string' ? body.code.toUpperCase().replace(/[\s-]/g, '') : '';
  if (!CODE_RE.test(code)) throw notFound();
  const g = await ctx.db
    .prepare('SELECT id FROM study_groups WHERE join_code = ?1')
    .bind(code)
    .first<{ id: string }>();
  if (!g) throw notFound();
  // Qayta qo'shilish hech narsani o'zgartirmaydi (taxallus ham tekshirilmaydi).
  if (await membership(ctx, g.id, s.userId)) return json({ group_id: g.id });
  const nick = nickname(body.display_name);
  const n = await ctx.db
    .prepare('SELECT COUNT(*) AS n FROM group_members WHERE group_id = ?1')
    .bind(g.id)
    .first<{ n: number }>();
  if ((n?.n ?? 0) >= MAX_MEMBERS) throw new ApiError(429, 'group_full');
  // Tartib raqami atomar oshiriladi ("Talaba NN").
  const no = await ctx.db
    .prepare(
      'UPDATE study_groups SET next_member_no = next_member_no + 1 WHERE id = ?1 RETURNING next_member_no - 1 AS no',
    )
    .bind(g.id)
    .first<{ no: number }>();
  await ctx.db
    .prepare(
      `INSERT INTO group_members (group_id, user_id, member_role, member_no, nickname, joined_at)
       VALUES (?1, ?2, 'student', ?3, ?4, ?5) ON CONFLICT DO NOTHING`,
    )
    .bind(g.id, s.userId, no?.no ?? 0, nick, ctx.now)
    .run();
  return json({ group_id: g.id }, 201);
}

export async function leaveGroup(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const m = await requireMember(ctx, s, gid);
  if (m.role === 'teacher') throw badRequest('teacher_cannot_leave');
  await ctx.db
    .prepare(`DELETE FROM group_members WHERE group_id = ?1 AND user_id = ?2 AND member_role = 'student'`)
    .bind(gid, s.userId)
    .run();
  return noContent();
}

/** O'z taxallusi (bo'sh/null — tartib raqami ko'rinadi). Har a'zo uchun. */
export async function setAlias(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireMember(ctx, s, gid);
  const body = await readJson(ctx.req);
  const nick = nickname(body.alias);
  await ctx.db
    .prepare('UPDATE group_members SET nickname = ?3 WHERE group_id = ?1 AND user_id = ?2')
    .bind(gid, s.userId, nick)
    .run();
  return json({ alias: nick });
}

export async function deleteGroup(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const a = 'SELECT id FROM assignments WHERE group_id = ?1';
  await ctx.db.batch(
    [
      `DELETE FROM submissions WHERE assignment_id IN (${a})`,
      `DELETE FROM assignment_attempts WHERE assignment_id IN (${a})`,
      `DELETE FROM assignment_keys WHERE assignment_id IN (${a})`,
      'DELETE FROM assignments WHERE group_id = ?1',
      'DELETE FROM qa_marks WHERE group_id = ?1',
      'DELETE FROM group_topics WHERE group_id = ?1',
      'DELETE FROM group_members WHERE group_id = ?1',
      'DELETE FROM study_groups WHERE id = ?1',
    ].map((q) => ctx.db.prepare(q).bind(gid)),
  );
  await audit(ctx, s.userId, 'group_deleted', gid);
  return noContent();
}

/** Kod tarqalib ketsa — ustoz yangisini oladi (eski QR ishlamay qoladi). */
export async function rotateCode(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const code = await uniqueCode(ctx);
  await ctx.db.prepare('UPDATE study_groups SET join_code = ?1 WHERE id = ?2').bind(code, gid).run();
  return json({ join_code: code });
}

/** Ustoz — hammani; talaba — faqat ustozni va o'zini ko'radi. */
export async function listMembers(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const m = await requireMember(ctx, s, gid);
  const teacher = m.role === 'teacher' && m.owner;
  const rows = await ctx.db
    .prepare(
      `SELECT user_id, member_role, member_no, nickname, joined_at FROM group_members
       WHERE group_id = ?1 AND (?2 = 1 OR member_role = 'teacher' OR user_id = ?3)
       ORDER BY member_no`,
    )
    .bind(gid, teacher ? 1 : 0, s.userId)
    .all<{ user_id: string; member_role: Role; member_no: number; nickname: string | null; joined_at: number }>();
  // Kontrakt (GroupMember.fromJson): display_name — faqat taxallus (yo'q
  // bo'lsa null), seat_no — talabaning tartib raqami (ustozda null).
  return json(
    rows.results.map((r) => ({
      user_id: r.user_id,
      member_role: r.member_role,
      display_name: r.nickname,
      seat_no: r.member_role === 'student' ? r.member_no : null,
      label: displayName(r.member_role, r.member_no, r.nickname),
      joined_at: iso(r.joined_at),
    })),
  );
}

export async function removeMember(ctx: Ctx, gid: string, uid: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const r = await ctx.db
    .prepare(`DELETE FROM group_members WHERE group_id = ?1 AND user_id = ?2 AND member_role = 'student'`)
    .bind(gid, uuidParam(uid))
    .run();
  // Alohida kod: ilova buni "allaqachon chiqarilgan" deb tushunadi.
  if (!r.meta.changes) throw new ApiError(404, 'member_not_found');
  return noContent();
}

// ---------------------------------------------------------------- topics
interface TopicRow {
  group_id: string;
  topic_id: string;
  opened_at: number;
  closed_at: number | null;
  lecture_done_at: number | null;
  oral_done_at: number | null;
  test_assignment_id: string | null;
}

const topicJson = (t: TopicRow) => ({
  group_id: t.group_id,
  topic_id: t.topic_id,
  /** Eski mijozlar uchun (topic_id bilan bir xil). */
  day_id: t.topic_id,
  opened_at: iso(t.opened_at),
  lecture_done_at: iso(t.lecture_done_at),
  oral_done_at: iso(t.oral_done_at),
  test_assignment_id: t.test_assignment_id,
  closed_at: iso(t.closed_at),
  open: t.closed_at == null,
});

/** A'zo ochilgan mavzularni ko'radi (begona — 404). */
export async function listTopics(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireMember(ctx, s, gid);
  const rows = await ctx.db
    .prepare('SELECT * FROM group_topics WHERE group_id = ?1 ORDER BY opened_at, topic_id')
    .bind(gid)
    .all<TopicRow>();
  return json(rows.results.map(topicJson));
}

async function topicRow(ctx: Ctx, gid: string, topic: string): Promise<TopicRow | null> {
  return ctx.db
    .prepare('SELECT * FROM group_topics WHERE group_id = ?1 AND topic_id = ?2')
    .bind(gid, topic)
    .first<TopicRow>();
}

/** Mavzuni ochadi: qayta chaqirilsa o'zgarmaydi (yopilgan bo'lsa qayta ochiladi). */
async function ensureTopic(ctx: Ctx, gid: string, topic: string): Promise<void> {
  const existing = await topicRow(ctx, gid, topic);
  if (existing) {
    if (existing.closed_at != null) {
      await ctx.db
        .prepare('UPDATE group_topics SET closed_at = NULL WHERE group_id = ?1 AND topic_id = ?2')
        .bind(gid, topic)
        .run();
    }
    return;
  }
  const n = await ctx.db
    .prepare('SELECT COUNT(*) AS n FROM group_topics WHERE group_id = ?1')
    .bind(gid)
    .first<{ n: number }>();
  if ((n?.n ?? 0) >= MAX_TOPICS) throw new ApiError(429, 'limit_topics');
  await ctx.db
    .prepare(
      `INSERT INTO group_topics (group_id, topic_id, opened_at, closed_at) VALUES (?1, ?2, ?3, NULL)
       ON CONFLICT (group_id, topic_id) DO UPDATE SET closed_at = NULL`,
    )
    .bind(gid, topic, ctx.now)
    .run();
}

export async function openTopic(ctx: Ctx, gid: string, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const topic = topicId(decodeSeg(raw));
  await ensureTopic(ctx, gid, topic);
  return json(topicJson((await topicRow(ctx, gid, topic))!));
}

export async function closeTopic(ctx: Ctx, gid: string, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const topic = topicId(decodeSeg(raw));
  const r = await ctx.db
    .prepare('UPDATE group_topics SET closed_at = ?3 WHERE group_id = ?1 AND topic_id = ?2 AND closed_at IS NULL')
    .bind(gid, topic, ctx.now)
    .run();
  if (!r.meta.changes) throw notFound();
  return noContent();
}

/** Dars bosqichi o'tildi: `lecture` (ma'ruza) yoki `oral` (savol-javob). Mavzu ochiladi. */
export async function markTopicStage(ctx: Ctx, gid: string, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const topic = topicId(decodeSeg(raw));
  const body = await readJson(ctx.req);
  if (typeof body.stage !== 'string' || !STAGES.has(body.stage)) throw badRequest('invalid_stage');
  await ensureTopic(ctx, gid, topic);
  await ctx.db
    .prepare(
      body.stage === 'lecture'
        ? 'UPDATE group_topics SET lecture_done_at = COALESCE(lecture_done_at, ?3) WHERE group_id = ?1 AND topic_id = ?2'
        : 'UPDATE group_topics SET oral_done_at = COALESCE(oral_done_at, ?3) WHERE group_id = ?1 AND topic_id = ?2',
    )
    .bind(gid, topic, ctx.now)
    .run();
  return json(topicJson((await topicRow(ctx, gid, topic))!));
}

/**
 * "Testni boshlash": mavzu bo'yicha topshiriq yaratiladi va darhol ochiladi.
 * Mavzuga bitta test — tekshiruv va yozish bitta tranzaksiyada (parallel
 * so'rov ikkinchi test yarata olmaydi).
 */
export async function startTopicTest(ctx: Ctx, gid: string, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const topic = topicId(decodeSeg(raw));
  const body = await readJson(ctx.req);
  const p = parseAssignment(ctx, body);
  await ensureTopic(ctx, gid, topic);
  const aid = crypto.randomUUID();
  const [ins] = await ctx.db.batch([
    ctx.db
      .prepare(
        `INSERT INTO assignments (id, group_id, title, day_id, question_ids, time_limit_minutes, due_at, status, opened_at, created_at)
         SELECT ?1, ?2, ?3, ?4, ?5, ?6, ?7, 'open', ?8, ?8
         WHERE NOT EXISTS (SELECT 1 FROM group_topics
                           WHERE group_id = ?2 AND topic_id = ?4 AND test_assignment_id IS NOT NULL)`,
      )
      .bind(aid, gid, p.title, topic, JSON.stringify(p.questionIds), p.limit, p.due, ctx.now),
    ctx.db
      .prepare(
        `INSERT INTO assignment_keys (assignment_id, correct_indexes)
         SELECT ?1, ?2 WHERE EXISTS (SELECT 1 FROM assignments WHERE id = ?1)`,
      )
      .bind(aid, JSON.stringify(p.key)),
    ctx.db
      .prepare(
        `UPDATE group_topics SET test_assignment_id = ?3
         WHERE group_id = ?1 AND topic_id = ?2 AND test_assignment_id IS NULL
           AND EXISTS (SELECT 1 FROM assignments WHERE id = ?3)`,
      )
      .bind(gid, topic, aid),
  ]);
  if (!ins.meta.changes) throw conflict('test_exists');
  return json({ id: aid, topic_id: topic, status: 'open' }, 201);
}

/**
 * Testni yakunlash: shu daqiqadan yangi urinish yo'q; yakunlanishdan oldin
 * boshlaganlarga topshirish uchun qisqa (2 daqiqa) tarmoq vaqti qoladi.
 */
export async function finishTopicTest(ctx: Ctx, gid: string, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const topic = topicId(decodeSeg(raw));
  const t = await topicRow(ctx, gid, topic);
  if (!t?.test_assignment_id) throw new ApiError(404, 'no_test');
  await ctx.db
    .prepare(
      `UPDATE assignments SET
         status = 'closed',
         closed_at = COALESCE(closed_at, ?2),
         due_at = CASE WHEN due_at IS NULL OR due_at > ?2 THEN ?2 ELSE due_at END
       WHERE id = ?1 AND group_id = ?3`,
    )
    .bind(t.test_assignment_id, ctx.now, gid)
    .run();
  return noContent();
}

// ----------------------------------------------------------------- marks
const RESULTS = new Set(['correct', 'partial', 'incorrect', 'skipped']);

async function requireStudentMember(ctx: Ctx, gid: string, uid: string): Promise<void> {
  const m = await membership(ctx, gid, uuidParam(uid));
  if (!m || m.role !== 'student') throw notFound();
}

export async function putMark(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const body = await readJson(ctx.req);
  if (typeof body.user_id !== 'string') throw badRequest('invalid_user');
  await requireStudentMember(ctx, gid, body.user_id);
  const day = id(body.day_id, 'invalid_day');
  const q = id(body.question_id, 'invalid_question');
  if (typeof body.result !== 'string' || !RESULTS.has(body.result)) throw badRequest('invalid_result');
  let grade: number | null = null;
  if (body.grade != null) {
    if (!Number.isInteger(body.grade) || (body.grade as number) < 1 || (body.grade as number) > 5) {
      throw badRequest('invalid_grade');
    }
    grade = body.grade as number;
  }
  const row = await ctx.db
    .prepare(
      `INSERT INTO qa_marks (id, group_id, user_id, day_id, question_id, result, grade, marked_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)
       ON CONFLICT (group_id, user_id, day_id, question_id)
       DO UPDATE SET result = ?6, grade = ?7, marked_at = ?8
       RETURNING id`,
    )
    .bind(crypto.randomUUID(), gid, body.user_id, day, q, body.result, grade, ctx.now)
    .first<{ id: string }>();
  return json({ id: row?.id, user_id: body.user_id, day_id: day, question_id: q, result: body.result, grade });
}

/** Ustoz — guruhdagi hamma belgilar; talaba — faqat o'ziniki. */
export async function listMarks(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const m = await requireMember(ctx, s, gid);
  const teacher = m.role === 'teacher' && m.owner;
  const dayRaw = new URL(ctx.req.url).searchParams.get('day_id');
  const day = dayRaw == null ? null : id(dayRaw, 'invalid_day');
  const rows = await ctx.db
    .prepare(
      `SELECT id, user_id, day_id, question_id, result, grade, marked_at FROM qa_marks
       WHERE group_id = ?1 AND (?2 = 1 OR user_id = ?3) AND (?4 IS NULL OR day_id = ?4)
       ORDER BY marked_at`,
    )
    .bind(gid, teacher ? 1 : 0, s.userId, day)
    .all<{ id: string; user_id: string; day_id: string; question_id: string; result: string; grade: number | null; marked_at: number }>();
  return json(rows.results.map((r) => ({ ...r, marked_at: iso(r.marked_at) })));
}

export async function deleteMark(ctx: Ctx, gid: string, markId: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const r = await ctx.db
    .prepare('DELETE FROM qa_marks WHERE id = ?1 AND group_id = ?2')
    .bind(uuidParam(markId), gid)
    .run();
  if (!r.meta.changes) throw notFound();
  return noContent();
}

// ----------------------------------------------------------- assignments
interface AssignmentRow {
  id: string;
  group_id: string;
  title: string;
  day_id: string | null;
  question_ids: string;
  time_limit_minutes: number | null;
  due_at: number | null;
  status: 'draft' | 'open' | 'closed';
  opened_at: number | null;
  closed_at: number | null;
  created_at: number;
}

function assignmentJson(a: AssignmentRow) {
  return {
    id: a.id,
    group_id: a.group_id,
    title: a.title,
    day_id: a.day_id,
    topic_id: a.day_id,
    question_ids: JSON.parse(a.question_ids) as string[],
    time_limit_minutes: a.time_limit_minutes,
    due_at: iso(a.due_at),
    status: a.status,
    opened_at: iso(a.opened_at),
    closed_at: iso(a.closed_at),
    created_at: iso(a.created_at),
  };
}

async function loadAssignment(ctx: Ctx, s: Session, aid: string) {
  const a = await ctx.db
    .prepare('SELECT * FROM assignments WHERE id = ?1')
    .bind(uuidParam(aid))
    .first<AssignmentRow>();
  if (!a) throw notFound();
  const m = await membership(ctx, a.group_id, s.userId);
  if (!m) throw notFound();
  const teacher = m.role === 'teacher' && m.owner;
  if (!teacher && a.status === 'draft') throw notFound();
  return { a, teacher };
}

export async function listAssignments(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const m = await requireMember(ctx, s, gid);
  const teacher = m.role === 'teacher' && m.owner;
  const rows = await ctx.db
    .prepare(
      `SELECT * FROM assignments WHERE group_id = ?1 AND (?2 = 1 OR status <> 'draft') ORDER BY created_at DESC`,
    )
    .bind(gid, teacher ? 1 : 0)
    .all<AssignmentRow>();
  return json(rows.results.map(assignmentJson));
}

/** Topshiriq maydonlari (kontrakt: sarlavha 3–120, savol 1–50, vaqt 1–180). */
function parseAssignment(ctx: Ctx, body: Record<string, unknown>) {
  const title = str(body.title, 3, 120, 'invalid_title');
  const qs = body.question_ids;
  const key = body.correct_indexes;
  if (!Array.isArray(qs) || qs.length < 1 || qs.length > 50) throw badRequest('invalid_questions');
  const questionIds = qs.map((q) => id(q, 'invalid_questions'));
  if (
    !Array.isArray(key) ||
    key.length !== qs.length ||
    !key.every((k) => Number.isInteger(k) && k >= 0 && k <= 20)
  ) {
    throw badRequest('invalid_key');
  }
  let limit: number | null = null;
  if (body.time_limit_minutes != null) {
    const t = body.time_limit_minutes;
    if (!Number.isInteger(t) || (t as number) < 1 || (t as number) > 180) throw badRequest('invalid_time_limit');
    limit = t as number;
  }
  let due: number | null = null;
  if (body.due_at != null) {
    due = typeof body.due_at === 'string' ? Date.parse(body.due_at) : NaN;
    if (!Number.isFinite(due) || due <= ctx.now || due > ctx.now + 366 * 86400_000) {
      throw badRequest('invalid_due');
    }
  }
  return { title, questionIds, key: key as number[], limit, due };
}

export async function createAssignment(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  await requireTeacher(ctx, s, gid);
  const body = await readJson(ctx.req);
  const { title, questionIds, key, limit, due } = parseAssignment(ctx, body);
  const day = body.day_id == null ? null : topicId(body.day_id);
  // Standart: darhol ochiladi (eski oqim); `start: false` — qoralama.
  const open = body.start !== false;
  const aid = crypto.randomUUID();
  await ctx.db.batch([
    ctx.db
      .prepare(
        `INSERT INTO assignments (id, group_id, title, day_id, question_ids, time_limit_minutes, due_at, status, opened_at, created_at)
         VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)`,
      )
      .bind(aid, gid, title, day, JSON.stringify(questionIds), limit, due, open ? 'open' : 'draft', open ? ctx.now : null, ctx.now),
    ctx.db
      .prepare('INSERT INTO assignment_keys (assignment_id, correct_indexes) VALUES (?1, ?2)')
      .bind(aid, JSON.stringify(key)),
  ]);
  return json({ id: aid, status: open ? 'open' : 'draft' }, 201);
}

/** Ustoz test sessiyasini boshlaydi yoki yakunlaydi. */
export async function setAssignmentStatus(ctx: Ctx, aid: string, to: 'open' | 'closed'): Promise<Response> {
  const s = await requireSession(ctx);
  const { a, teacher } = await loadAssignment(ctx, s, aid);
  if (!teacher) throw forbidden();
  if (a.status === to) return json(assignmentJson(a));
  const r = await ctx.db
    .prepare(
      to === 'open'
        ? `UPDATE assignments SET status = 'open', opened_at = ?2, closed_at = NULL WHERE id = ?1 RETURNING *`
        : `UPDATE assignments SET status = 'closed', closed_at = ?2 WHERE id = ?1 RETURNING *`,
    )
    .bind(a.id, ctx.now)
    .first<AssignmentRow>();
  return json(assignmentJson(r!));
}

async function requireStudentFor(ctx: Ctx, s: Session, aid: string) {
  const { a, teacher } = await loadAssignment(ctx, s, aid);
  if (teacher) throw forbidden();
  const m = await membership(ctx, a.group_id, s.userId);
  if (m?.role !== 'student') throw forbidden();
  return a;
}

export async function startAssignment(ctx: Ctx, aid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const a = await requireStudentFor(ctx, s, aid);
  const existing = await ctx.db
    .prepare('SELECT started_at FROM assignment_attempts WHERE assignment_id = ?1 AND user_id = ?2')
    .bind(a.id, s.userId)
    .first<{ started_at: number }>();
  let started = existing?.started_at;
  if (started == null) {
    if (a.status !== 'open') throw conflict('not_open');
    if (a.due_at != null && ctx.now > a.due_at) throw conflict('past_due');
    await ctx.db
      .prepare('INSERT INTO assignment_attempts (assignment_id, user_id, started_at) VALUES (?1, ?2, ?3) ON CONFLICT DO NOTHING')
      .bind(a.id, s.userId, ctx.now)
      .run();
    started = ctx.now;
  }
  return json({
    started_at: iso(started),
    server_now: iso(ctx.now),
    time_limit_minutes: a.time_limit_minutes,
    due_at: iso(a.due_at),
    status: a.status,
  });
}

export async function submitAssignment(ctx: Ctx, aid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const a = await requireStudentFor(ctx, s, aid);
  const body = await readJson(ctx.req);
  const att = await ctx.db
    .prepare('SELECT started_at FROM assignment_attempts WHERE assignment_id = ?1 AND user_id = ?2')
    .bind(a.id, s.userId)
    .first<{ started_at: number }>();
  const st = att?.started_at ?? null;
  // Yakunlangan sessiya: yakunlanishdan oldin boshlaganlarga qisqa tarmoq vaqti.
  if (a.status === 'draft') throw conflict('not_open');
  if (a.status === 'closed') {
    if (st == null || a.closed_at == null || st > a.closed_at || ctx.now > a.closed_at + GRACE_MS) {
      throw conflict('closed');
    }
  }
  if (a.due_at != null && ctx.now > a.due_at + (st != null && st <= a.due_at ? GRACE_MS : 0)) {
    throw conflict('past_due');
  }
  if (a.time_limit_minutes != null && (st == null || ctx.now > st + a.time_limit_minutes * 60_000 + GRACE_MS)) {
    throw conflict('time_over');
  }
  const key = JSON.parse(
    (await ctx.db
      .prepare('SELECT correct_indexes FROM assignment_keys WHERE assignment_id = ?1')
      .bind(a.id)
      .first<{ correct_indexes: string }>())!.correct_indexes,
  ) as number[];
  const answers = body.answers;
  if (
    !Array.isArray(answers) ||
    answers.length !== key.length ||
    !answers.every((x) => Number.isInteger(x) && x >= -1 && x <= 20)
  ) {
    throw badRequest('invalid_answers');
  }
  const correct = key.map((k, i) => answers[i] === k);
  const score = correct.filter(Boolean).length;
  const r = await ctx.db
    .prepare(
      `INSERT INTO submissions (assignment_id, user_id, answers, correct, score, total, submitted_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7) ON CONFLICT DO NOTHING`,
    )
    .bind(a.id, s.userId, JSON.stringify(answers), JSON.stringify(correct), score, key.length, ctx.now)
    .run();
  if (!r.meta.changes) throw conflict('already_submitted');
  return json(
    {
      assignment_id: a.id,
      user_id: s.userId,
      score,
      total: key.length,
      answers,
      correct,
      submitted_at: iso(ctx.now),
    },
    201,
  );
}

interface SubmissionRow {
  assignment_id: string;
  user_id: string;
  answers: string;
  correct: string;
  score: number;
  total: number;
  submitted_at: number;
}

const submissionJson = (r: SubmissionRow) => ({
  assignment_id: r.assignment_id,
  user_id: r.user_id,
  score: r.score,
  total: r.total,
  answers: JSON.parse(r.answers) as number[],
  correct: JSON.parse(r.correct) as boolean[],
  submitted_at: iso(r.submitted_at),
});

/** Ustoz — topshiriq bo'yicha hamma; talaba — faqat o'zi. */
export async function listSubmissions(ctx: Ctx, aid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const { a, teacher } = await loadAssignment(ctx, s, aid);
  const rows = await ctx.db
    .prepare(
      `SELECT * FROM submissions WHERE assignment_id = ?1 AND (?2 = 1 OR user_id = ?3) ORDER BY submitted_at`,
    )
    .bind(a.id, teacher ? 1 : 0, s.userId)
    .all<SubmissionRow>();
  return json(rows.results.map(submissionJson));
}

export async function groupSubmissions(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const m = await requireMember(ctx, s, gid);
  const teacher = m.role === 'teacher' && m.owner;
  const rows = await ctx.db
    .prepare(
      `SELECT s.* FROM submissions s JOIN assignments a ON a.id = s.assignment_id
       WHERE a.group_id = ?1 AND (?2 = 1 OR s.user_id = ?3) ORDER BY s.submitted_at`,
    )
    .bind(gid, teacher ? 1 : 0, s.userId)
    .all<SubmissionRow>();
  return json(rows.results.map(submissionJson));
}

export async function assignmentKey(ctx: Ctx, aid: string): Promise<Response> {
  const s = await requireSession(ctx);
  const { a, teacher } = await loadAssignment(ctx, s, aid);
  if (!teacher) throw forbidden();
  const k = await ctx.db
    .prepare('SELECT correct_indexes FROM assignment_keys WHERE assignment_id = ?1')
    .bind(a.id)
    .first<{ correct_indexes: string }>();
  return json({ correct_indexes: JSON.parse(k!.correct_indexes) as number[] });
}
