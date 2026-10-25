// Ustoz Pro (D-78, egasi qarori 2026-10-25): o'z testlari, talabalarni
// biriktirish (taklifnoma + rozilik), topshiriq muddati va urinishlar,
// natijalar jamlanmasi va CSV; talaba tomoni (Talaba Pro `learner`).
//
// INERT: yo'llar faqat LG_BILLING_ENABLED=true da (app.ts `billingRoutes`),
// aks holda 404 — bepul reliz bilan bir xil. Jadvallar: 0030_teacher_tests.sql.
//
// Vakolat (har so'rovda serverda; ilovadagi gate faqat UX):
// * YANGI pullik amal (test yaratish/tahrirlash, topshirish, taklifnoma, CSV)
//   — `requireTier('teacher_panel')` + `teacher_accounts` (403
//   `tier_insufficient` / `plan_required` / `teacher_role_required`);
// * o'z ma'lumotini KO'RISH, yopish va o'chirish — obuna tugagan bo'lsa ham
//   (D-78 §7: ma'lumot o'chirilmaydi va yashirilmaydi) — sessiya + ustoz;
// * talaba YANGI urinishni boshlashi — `requireTier('learner')`; boshlangan
//   urinish qayta ochiladi va topshiriladi (obuna o'rtada tugasa ham);
// * egalik: ustoz faqat o'z testi/topshirig'i/guruhi (begona — 404);
//   talaba faqat a'zo bo'lgan guruhdagi va o'ziga tegishli topshiriq.
//
// Bugungi BEPUL guruhlar va topshiriqlar (groups.ts) bunga tegmaydi.

import { audit, requireSession } from './auth';
import type { Ctx, Session } from './context';
import { iso } from './context';
import { decrypt, encrypt, hex, hmac, randomFrom } from './crypto';
import { addStudent, displayName, isTeacherAccount, nickname, requireFreeNickname, uuidParam } from './groups';
import { ApiError, badRequest, conflict, forbidden, json, noContent, notFound, readJson } from './http';
import { guardAbuse } from './moderation';
import { hit } from './ratelimit';
import { requireTier } from './tiers';

/** Cheklovlar (ilova `TeacherTestLimits` bilan bir xil). */
export const TT_LIMITS = {
  testsPerTeacher: 200,
  questions: 100,
  titleMin: 3,
  titleMax: 120,
  description: 1000,
  text: 1000,
  option: 300,
  optionsMin: 2,
  optionsMax: 6,
  explanation: 1000,
  maxAttempts: 5,
  activeAssignments: 300,
  invitesPerGroup: 20,
  inviteUses: 200,
  inviteDays: 30,
} as const;

/** Savollar bilan test tanasi (100 × uzun savol) — oddiy 32 KB dan katta. */
const MAX_TEST_BODY = 512 * 1024;
/** Vaqt / muddat tugagach topshirish uchun tarmoq vaqti (bepul topshiriqlar bilan bir xil). */
export const TT_GRACE_MS = 2 * 60_000;
const DAY = 86400_000;
/** Ilovadagi banklar (savol nusxasi manbai): mashq, toifa, taqdimot testi. */
const BANKS = new Set(['quiz', 'toifa', 'deck']);
const SOURCE_ID_RE = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,79}$/;
const INVITE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const INVITE_RE = /^[A-HJ-NP-Z2-9]{12}$/;

interface Question {
  text: string;
  options: string[];
  correct: number;
  explanation: string | null;
  source: { bank: string; id: string } | null;
}

interface TestRow {
  id: string;
  owner_id: string;
  title: string;
  description: string | null;
  questions: string;
  question_count: number;
  time_limit_minutes: number | null;
  pass_percent: number | null;
  status: 'unpublished' | 'published';
  version: number;
  created_at: number;
  updated_at: number;
  published_at: number | null;
}

interface AssignmentRow {
  id: string;
  test_id: string;
  owner_id: string;
  group_id: string;
  user_id: string | null;
  title: string;
  questions: string;
  question_count: number;
  time_limit_minutes: number | null;
  pass_percent: number | null;
  max_attempts: number;
  due_at: number;
  late_policy: 'reject' | 'accept';
  status: 'active' | 'closed';
  created_at: number;
  closed_at: number | null;
}

interface AttemptRow {
  id: string;
  assignment_id: string;
  user_id: string;
  attempt_no: number;
  started_at: number;
  time_up_at: number | null;
  submitted_at: number | null;
  answers: string | null;
  correct: string | null;
  score: number | null;
  total: number;
  late: number;
  status: 'started' | 'submitted' | 'expired';
}

// ------------------------------------------------------------- vakolat
/** YANGI Ustoz Pro amali: serverdagi reja + ro'yxatdan o'tgan ustoz. */
async function requireTeacherPro(ctx: Ctx): Promise<Session> {
  const { session } = await requireTier(ctx, 'teacher_panel');
  if (!(await isTeacherAccount(ctx, session.userId))) throw forbidden('teacher_role_required');
  return session;
}

/** O'z ma'lumotini ko'rish/yopish/o'chirish (obunasiz ham): sessiya + ustoz. */
async function requireTeacherAccount(ctx: Ctx): Promise<Session> {
  const s = await requireSession(ctx);
  if (!(await isTeacherAccount(ctx, s.userId))) throw forbidden('teacher_role_required');
  return s;
}

async function writeLimit(ctx: Ctx, s: Session): Promise<void> {
  await hit(ctx.db, `tt-write:${s.userId}`, 120, 3600, ctx.now);
}

// ----------------------------------------------------------- tekshiruv
function text(v: unknown, min: number, max: number, code: string): string {
  if (typeof v !== 'string') throw badRequest(code);
  const t = v.trim();
  if (t.length < min || t.length > max) throw badRequest(code);
  return t;
}

function optionalText(v: unknown, max: number, code: string): string | null {
  if (v == null) return null;
  if (typeof v !== 'string') throw badRequest(code);
  const t = v.trim();
  if (t === '') return null;
  if (t.length > max) throw badRequest(code);
  return t;
}

function optionalInt(v: unknown, min: number, max: number, code: string): number | null {
  if (v == null) return null;
  if (!Number.isInteger(v) || (v as number) < min || (v as number) > max) throw badRequest(code);
  return v as number;
}

function parseQuestion(raw: unknown, i: number): Question {
  if (raw === null || typeof raw !== 'object' || Array.isArray(raw)) throw badRequest('invalid_question', { index: i });
  const q = raw as Record<string, unknown>;
  const bad = (code: string) => badRequest(code, { index: i });
  if (typeof q.text !== 'string') throw bad('invalid_question_text');
  const qt = q.text.trim();
  if (qt.length < 1 || qt.length > TT_LIMITS.text) throw bad('invalid_question_text');
  const opts = q.options;
  if (!Array.isArray(opts) || opts.length < TT_LIMITS.optionsMin || opts.length > TT_LIMITS.optionsMax) {
    throw bad('invalid_options');
  }
  const options = opts.map((o) => {
    if (typeof o !== 'string') throw bad('invalid_options');
    const t = o.trim();
    if (t.length < 1 || t.length > TT_LIMITS.option) throw bad('invalid_options');
    return t;
  });
  // Bir xil variant ikki marta — talaba uchun ma'nosiz (katta-kichik harf farqsiz).
  if (new Set(options.map((o) => o.toLocaleLowerCase())).size !== options.length) throw bad('duplicate_options');
  if (!Number.isInteger(q.correct) || (q.correct as number) < 0 || (q.correct as number) >= options.length) {
    throw bad('invalid_correct');
  }
  const explanation = optionalText(q.explanation, TT_LIMITS.explanation, 'invalid_explanation');
  let source: Question['source'] = null;
  if (q.source != null) {
    const s = q.source as Record<string, unknown>;
    if (
      typeof s !== 'object' ||
      typeof s.bank !== 'string' ||
      !BANKS.has(s.bank) ||
      typeof s.id !== 'string' ||
      !SOURCE_ID_RE.test(s.id)
    ) {
      throw bad('invalid_source');
    }
    source = { bank: s.bank, id: s.id };
  }
  return { text: qt, options, correct: q.correct as number, explanation, source };
}

function parseTestBody(body: Record<string, unknown>) {
  const title = text(body.title, TT_LIMITS.titleMin, TT_LIMITS.titleMax, 'invalid_title');
  guardAbuse(title);
  const description = optionalText(body.description, TT_LIMITS.description, 'invalid_description');
  if (description) guardAbuse(description);
  const qs = body.questions ?? [];
  if (!Array.isArray(qs) || qs.length > TT_LIMITS.questions) throw badRequest('invalid_questions');
  const questions = qs.map(parseQuestion);
  const limit = optionalInt(body.time_limit_minutes, 1, 180, 'invalid_time_limit');
  const pass = optionalInt(body.pass_percent, 1, 100, 'invalid_pass_percent');
  const status = body.status ?? 'unpublished';
  if (status !== 'unpublished' && status !== 'published') throw badRequest('invalid_status');
  if (status === 'published' && questions.length === 0) throw badRequest('no_questions');
  return { title, description, questions, limit, pass, status: status as TestRow['status'] };
}

// ------------------------------------------------------------- JSON
const questionsOf = (raw: string) => JSON.parse(raw) as Question[];

function testSummary(t: TestRow & { assignment_count?: number }) {
  return {
    id: t.id,
    title: t.title,
    description: t.description,
    question_count: t.question_count,
    time_limit_minutes: t.time_limit_minutes,
    pass_percent: t.pass_percent,
    status: t.status,
    version: t.version,
    created_at: iso(t.created_at),
    updated_at: iso(t.updated_at),
    published_at: iso(t.published_at),
    assignment_count: t.assignment_count ?? 0,
  };
}

/** Egasiga: savollar kalit va izohi bilan. */
const testFull = (t: TestRow & { assignment_count?: number }) => ({
  ...testSummary(t),
  questions: questionsOf(t.questions),
});

async function ownTest(ctx: Ctx, s: Session, raw: string): Promise<TestRow> {
  const t = await ctx.db
    .prepare('SELECT * FROM teacher_tests WHERE id = ?1 AND owner_id = ?2')
    .bind(uuidParam(raw), s.userId)
    .first<TestRow>();
  // Begona test borligi ham bildirilmaydi.
  if (!t) throw notFound();
  return t;
}

async function assignmentCount(ctx: Ctx, testId: string): Promise<number> {
  const r = await ctx.db
    .prepare('SELECT COUNT(*) AS n FROM teacher_test_assignments WHERE test_id = ?1')
    .bind(testId)
    .first<{ n: number }>();
  return r?.n ?? 0;
}

// ---------------------------------------------------------- testlar
/** GET /v1/teacher/tests — o'z testlari (obunasiz ham ko'rinadi). */
export async function listTests(ctx: Ctx): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const rows = await ctx.db
    .prepare(
      `SELECT t.*, (SELECT COUNT(*) FROM teacher_test_assignments a WHERE a.test_id = t.id) AS assignment_count
       FROM teacher_tests t WHERE t.owner_id = ?1 ORDER BY t.updated_at DESC`,
    )
    .bind(s.userId)
    .all<TestRow & { assignment_count: number }>();
  return json(rows.results.map(testSummary));
}

/** POST /v1/teacher/tests — yangi test (Ustoz Pro). */
export async function createTest(ctx: Ctx): Promise<Response> {
  const s = await requireTeacherPro(ctx);
  await writeLimit(ctx, s);
  const p = parseTestBody(await readJson(ctx.req, MAX_TEST_BODY));
  const n = await ctx.db
    .prepare('SELECT COUNT(*) AS n FROM teacher_tests WHERE owner_id = ?1')
    .bind(s.userId)
    .first<{ n: number }>();
  if ((n?.n ?? 0) >= TT_LIMITS.testsPerTeacher) throw new ApiError(429, 'limit_tests');
  const id = crypto.randomUUID();
  const row: TestRow = {
    id,
    owner_id: s.userId,
    title: p.title,
    description: p.description,
    questions: JSON.stringify(p.questions),
    question_count: p.questions.length,
    time_limit_minutes: p.limit,
    pass_percent: p.pass,
    status: p.status,
    version: 1,
    created_at: ctx.now,
    updated_at: ctx.now,
    published_at: p.status === 'published' ? ctx.now : null,
  };
  await ctx.db
    .prepare(
      `INSERT INTO teacher_tests (id, owner_id, title, description, questions, question_count, time_limit_minutes,
         pass_percent, status, version, created_at, updated_at, published_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, 1, ?10, ?10, ?11)`,
    )
    .bind(
      id,
      s.userId,
      row.title,
      row.description,
      row.questions,
      row.question_count,
      row.time_limit_minutes,
      row.pass_percent,
      row.status,
      ctx.now,
      row.published_at,
    )
    .run();
  await audit(ctx, s.userId, 'teacher_test_created', id, { questions: row.question_count, status: row.status });
  return json(testFull(row), 201);
}

/** GET /v1/teacher/tests/:t — to'liq test (kalit bilan), faqat egasiga. */
export async function getTest(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const t = await ownTest(ctx, s, raw);
  return json(testFull({ ...t, assignment_count: await assignmentCount(ctx, t.id) }));
}

/**
 * PUT /v1/teacher/tests/:t — to'liq almashtirish (Ustoz Pro). `version`
 * berilsa va serverdagi bilan mos kelmasa — 409 `version_conflict` (boshqa
 * qurilmadagi tahrir ustidan yozilmaydi). Berilgan topshiriqlar — nusxa,
 * o'zgarmaydi.
 */
export async function updateTest(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherPro(ctx);
  await writeLimit(ctx, s);
  const t = await ownTest(ctx, s, raw);
  const body = await readJson(ctx.req, MAX_TEST_BODY);
  if (body.version != null && body.version !== t.version) {
    throw conflict('version_conflict');
  }
  const p = parseTestBody(body);
  const publishedAt = p.status === 'published' ? (t.published_at ?? ctx.now) : null;
  const r = await ctx.db
    .prepare(
      `UPDATE teacher_tests SET title = ?3, description = ?4, questions = ?5, question_count = ?6,
         time_limit_minutes = ?7, pass_percent = ?8, status = ?9, version = version + 1, updated_at = ?10,
         published_at = ?11
       WHERE id = ?1 AND owner_id = ?2 AND version = ?12 RETURNING *`,
    )
    .bind(
      t.id,
      s.userId,
      p.title,
      p.description,
      JSON.stringify(p.questions),
      p.questions.length,
      p.limit,
      p.pass,
      p.status,
      ctx.now,
      publishedAt,
      t.version,
    )
    .first<TestRow>();
  if (!r) throw conflict('version_conflict');
  await audit(ctx, s.userId, 'teacher_test_updated', t.id, { version: r.version, status: r.status });
  return json(testFull({ ...r, assignment_count: await assignmentCount(ctx, t.id) }));
}

/**
 * DELETE /v1/teacher/tests/:t — test, uning topshiriqlari va natijalari.
 * O'z ma'lumotini o'chirish obunasiz ham mumkin.
 */
export async function deleteTest(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const t = await ownTest(ctx, s, raw);
  const a = 'SELECT id FROM teacher_test_assignments WHERE test_id = ?1';
  await ctx.db.batch(
    [
      `DELETE FROM teacher_test_attempts WHERE assignment_id IN (${a})`,
      'DELETE FROM teacher_test_assignments WHERE test_id = ?1',
      'DELETE FROM teacher_tests WHERE id = ?1',
    ].map((q) => ctx.db.prepare(q).bind(t.id)),
  );
  await audit(ctx, s.userId, 'teacher_test_deleted', t.id);
  return noContent();
}

// --------------------------------------------------------- guruhlar
interface OwnGroup {
  id: string;
  name: string;
}

/** Ustozning o'z guruhi (egasi va ustoz a'zo); begona — 404. */
async function ownGroup(ctx: Ctx, s: Session, raw: unknown): Promise<OwnGroup> {
  if (typeof raw !== 'string') throw badRequest('invalid_group');
  const g = await ctx.db
    .prepare(
      `SELECT g.id, g.name FROM study_groups g
       JOIN group_members m ON m.group_id = g.id AND m.user_id = g.owner_id AND m.member_role = 'teacher'
       WHERE g.id = ?1 AND g.owner_id = ?2`,
    )
    .bind(uuidParam(raw), s.userId)
    .first<OwnGroup>();
  if (!g) throw notFound();
  return g;
}

async function isStudentMember(ctx: Ctx, gid: string, uid: string): Promise<boolean> {
  const r = await ctx.db
    .prepare(`SELECT 1 AS x FROM group_members WHERE group_id = ?1 AND user_id = ?2 AND member_role = 'student'`)
    .bind(gid, uid)
    .first();
  return r != null;
}

// ------------------------------------------------------ topshiriqlar
function assignmentJson(a: AssignmentRow, extra: Record<string, unknown> = {}) {
  return {
    id: a.id,
    test_id: a.test_id,
    group_id: a.group_id,
    user_id: a.user_id,
    title: a.title,
    question_count: a.question_count,
    time_limit_minutes: a.time_limit_minutes,
    pass_percent: a.pass_percent,
    max_attempts: a.max_attempts,
    due_at: iso(a.due_at),
    late_policy: a.late_policy,
    status: a.status,
    created_at: iso(a.created_at),
    closed_at: iso(a.closed_at),
    ...extra,
  };
}

async function ownAssignment(ctx: Ctx, s: Session, raw: string): Promise<AssignmentRow> {
  const a = await ctx.db
    .prepare('SELECT * FROM teacher_test_assignments WHERE id = ?1 AND owner_id = ?2')
    .bind(uuidParam(raw), s.userId)
    .first<AssignmentRow>();
  if (!a) throw notFound();
  return a;
}

/**
 * POST /v1/teacher/tests/:t/assignments — nashr etilgan o'z testini o'z
 * guruhiga (yoki guruhning bitta talabasiga) muddat bilan topshirish.
 */
export async function createAssignment(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherPro(ctx);
  await writeLimit(ctx, s);
  const t = await ownTest(ctx, s, raw);
  const body = await readJson(ctx.req);
  if (t.status !== 'published' || t.question_count < 1) throw conflict('not_published');
  const g = await ownGroup(ctx, s, body.group_id);
  let target: string | null = null;
  if (body.user_id != null) {
    if (typeof body.user_id !== 'string') throw badRequest('invalid_user');
    target = uuidParam(body.user_id);
    // Faqat guruhga o'zi qo'shilgan (rozilik bergan) talaba.
    if (!(await isStudentMember(ctx, g.id, target))) throw new ApiError(404, 'member_not_found');
  }
  const due = typeof body.due_at === 'string' ? Date.parse(body.due_at) : NaN;
  if (!Number.isFinite(due) || due <= ctx.now + 60_000 || due > ctx.now + 366 * DAY) throw badRequest('invalid_due');
  const attempts = optionalInt(body.max_attempts, 1, TT_LIMITS.maxAttempts, 'invalid_attempts') ?? 1;
  const late = body.late_policy ?? 'reject';
  if (late !== 'reject' && late !== 'accept') throw badRequest('invalid_late_policy');
  const n = await ctx.db
    .prepare(`SELECT COUNT(*) AS n FROM teacher_test_assignments WHERE owner_id = ?1 AND status = 'active'`)
    .bind(s.userId)
    .first<{ n: number }>();
  if ((n?.n ?? 0) >= TT_LIMITS.activeAssignments) throw new ApiError(429, 'limit_assignments');
  const row: AssignmentRow = {
    id: crypto.randomUUID(),
    test_id: t.id,
    owner_id: s.userId,
    group_id: g.id,
    user_id: target,
    title: t.title,
    questions: t.questions,
    question_count: t.question_count,
    time_limit_minutes: t.time_limit_minutes,
    pass_percent: t.pass_percent,
    max_attempts: attempts,
    due_at: due,
    late_policy: late,
    status: 'active',
    created_at: ctx.now,
    closed_at: null,
  };
  await ctx.db
    .prepare(
      `INSERT INTO teacher_test_assignments (id, test_id, owner_id, group_id, user_id, title, questions, question_count,
         time_limit_minutes, pass_percent, max_attempts, due_at, late_policy, status, created_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, 'active', ?14)`,
    )
    .bind(
      row.id,
      row.test_id,
      row.owner_id,
      row.group_id,
      row.user_id,
      row.title,
      row.questions,
      row.question_count,
      row.time_limit_minutes,
      row.pass_percent,
      row.max_attempts,
      row.due_at,
      row.late_policy,
      ctx.now,
    )
    .run();
  await audit(ctx, s.userId, 'teacher_test_assigned', row.id, { test: t.id, group: g.id, individual: target != null });
  return json(assignmentJson(row, { group_name: g.name }), 201);
}

/** GET /v1/teacher/assignments[?test_id=] — o'z topshiriqlari (sanoqlar bilan). */
export async function listAssignments(ctx: Ctx): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const testRaw = new URL(ctx.req.url).searchParams.get('test_id');
  const testId = testRaw == null ? null : uuidParam(testRaw);
  const rows = await ctx.db
    .prepare(
      `SELECT a.*, g.name AS group_name,
         (SELECT COUNT(DISTINCT t.user_id) FROM teacher_test_attempts t
            JOIN group_members m ON m.group_id = a.group_id AND m.user_id = t.user_id AND m.member_role = 'student'
            WHERE t.assignment_id = a.id AND t.status = 'submitted') AS submitted_count,
         CASE WHEN a.user_id IS NULL
           THEN (SELECT COUNT(*) FROM group_members m WHERE m.group_id = a.group_id AND m.member_role = 'student')
           ELSE 1 END AS target_count
       FROM teacher_test_assignments a JOIN study_groups g ON g.id = a.group_id
       WHERE a.owner_id = ?1 AND (?2 IS NULL OR a.test_id = ?2)
       ORDER BY a.created_at DESC`,
    )
    .bind(s.userId, testId)
    .all<AssignmentRow & { group_name: string; submitted_count: number; target_count: number }>();
  return json(
    rows.results.map((a) =>
      assignmentJson(a, {
        group_name: a.group_name,
        submitted_count: a.submitted_count,
        target_count: a.target_count,
      }),
    ),
  );
}

/** POST /v1/teacher/assignments/:a/close — yangi urinish yo'q (boshlaganlarga 2 daqiqa). */
export async function closeAssignment(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const a = await ownAssignment(ctx, s, raw);
  if (a.status !== 'closed') {
    await ctx.db
      .prepare(`UPDATE teacher_test_assignments SET status = 'closed', closed_at = ?2 WHERE id = ?1`)
      .bind(a.id, ctx.now)
      .run();
    await audit(ctx, s.userId, 'teacher_assignment_closed', a.id);
  }
  return json(assignmentJson({ ...a, status: 'closed', closed_at: a.closed_at ?? ctx.now }));
}

/** DELETE /v1/teacher/assignments/:a — topshiriq va uning natijalari. */
export async function deleteAssignment(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const a = await ownAssignment(ctx, s, raw);
  await ctx.db.batch([
    ctx.db.prepare('DELETE FROM teacher_test_attempts WHERE assignment_id = ?1').bind(a.id),
    ctx.db.prepare('DELETE FROM teacher_test_assignments WHERE id = ?1').bind(a.id),
  ]);
  await audit(ctx, s.userId, 'teacher_assignment_deleted', a.id);
  return noContent();
}

// ----------------------------------------------------------- holat
export type StudentState = 'assigned' | 'started' | 'submitted' | 'expired';

/** Urinish vaqti tugaganmi (2 daqiqa tarmoq vaqti bilan). */
const timedOut = (t: AttemptRow, now: number) => t.time_up_at != null && now > t.time_up_at + TT_GRACE_MS;

/** Talaba yangi urinish boshlay oladimi (muddat, yopilgan, urinishlar soni). */
function canStartNew(a: AssignmentRow, used: number, now: number): string | null {
  if (a.status !== 'active') return 'closed';
  if (now > a.due_at && a.late_policy === 'reject') return 'past_due';
  if (used >= a.max_attempts) return 'no_attempts_left';
  return null;
}

/** Topshiriq holati: assigned → started → submitted; muddat o'tsa — expired. */
function stateOf(a: AssignmentRow, attempts: AttemptRow[], now: number): StudentState {
  if (attempts.some((t) => t.status === 'started' && !timedOut(t, now))) return 'started';
  if (attempts.some((t) => t.status === 'submitted')) return 'submitted';
  if (a.status !== 'active' || (now > a.due_at && a.late_policy === 'reject')) return 'expired';
  if (attempts.length >= a.max_attempts) return 'expired';
  return 'assigned';
}

const percent = (score: number, total: number) => (total === 0 ? 0 : Math.round((score * 100) / total));

// ---------------------------------------------------------- natijalar
interface MemberRow {
  user_id: string;
  member_no: number;
  nickname: string | null;
}

/** Ustoz ko'radigan talabalar: faqat HOZIR guruh a'zosi (rozilik bergan). */
async function targetsOf(ctx: Ctx, a: AssignmentRow): Promise<MemberRow[]> {
  const rows = await ctx.db
    .prepare(
      `SELECT user_id, member_no, nickname FROM group_members
       WHERE group_id = ?1 AND member_role = 'student' AND (?2 IS NULL OR user_id = ?2) ORDER BY member_no`,
    )
    .bind(a.group_id, a.user_id)
    .all<MemberRow>();
  return rows.results;
}

async function visibleAttempts(ctx: Ctx, a: AssignmentRow): Promise<AttemptRow[]> {
  const rows = await ctx.db
    .prepare(
      `SELECT t.* FROM teacher_test_attempts t
       JOIN group_members m ON m.group_id = ?2 AND m.user_id = t.user_id AND m.member_role = 'student'
       WHERE t.assignment_id = ?1 ORDER BY t.started_at`,
    )
    .bind(a.id, a.group_id)
    .all<AttemptRow>();
  return rows.results;
}

function summarize(a: AssignmentRow, members: MemberRow[], attempts: AttemptRow[], now: number) {
  const qs = questionsOf(a.questions);
  const byUser = new Map<string, AttemptRow[]>();
  for (const t of attempts) {
    const list = byUser.get(t.user_id) ?? [];
    list.push(t);
    byUser.set(t.user_id, list);
  }
  const students = members.map((m) => {
    const mine = byUser.get(m.user_id) ?? [];
    const done = mine.filter((t) => t.status === 'submitted');
    const best = done.reduce<AttemptRow | null>((b, t) => (b == null || (t.score ?? 0) > (b.score ?? 0) ? t : b), null);
    const last = done.at(-1) ?? null;
    return {
      user_id: m.user_id,
      seat_no: m.member_no,
      alias: m.nickname,
      label: displayName('student', m.member_no, m.nickname),
      state: stateOf(a, mine, now),
      attempts: mine.length,
      submitted: done.length,
      best_score: best?.score ?? null,
      last_score: last?.score ?? null,
      total: a.question_count,
      best_percent: best == null ? null : percent(best.score ?? 0, best.total),
      passed: best == null || a.pass_percent == null ? null : percent(best.score ?? 0, best.total) >= a.pass_percent,
      best_seconds: best?.submitted_at == null ? null : Math.round((best.submitted_at - best.started_at) / 1000),
      late: done.some((t) => t.late === 1),
      last_submitted_at: iso(last?.submitted_at ?? null),
    };
  });
  // Savol kesimi: har talabaning OXIRGI topshirilgan urinishi bo'yicha.
  const lastByUser = students
    .map((s) => (byUser.get(s.user_id) ?? []).filter((t) => t.status === 'submitted').at(-1))
    .filter((t): t is AttemptRow => t != null);
  const questions = qs.map((q, i) => {
    const chosen = new Array<number>(q.options.length).fill(0);
    let answered = 0;
    let right = 0;
    for (const t of lastByUser) {
      const ans = (JSON.parse(t.answers ?? '[]') as number[])[i];
      if (ans != null && ans >= 0) {
        answered++;
        if (ans < chosen.length) chosen[ans]++;
      }
      if (ans === q.correct) right++;
    }
    return {
      index: i,
      text: q.text,
      options: q.options,
      correct: q.correct,
      answered,
      right,
      attempts: lastByUser.length,
      correct_percent: lastByUser.length === 0 ? null : percent(right, lastByUser.length),
      chosen,
    };
  });
  const finished = students.filter((s) => s.best_percent != null);
  const avg = finished.length === 0 ? null : Math.round(finished.reduce((x, s) => x + s.best_percent!, 0) / finished.length);
  const times = finished.map((s) => s.best_seconds).filter((x): x is number => x != null);
  return {
    assignment: assignmentJson(a),
    summary: {
      targets: members.length,
      started: students.filter((s) => s.attempts > 0).length,
      submitted: finished.length,
      attempts: attempts.length,
      average_percent: avg,
      pass_rate: a.pass_percent == null || finished.length === 0
        ? null
        : percent(finished.filter((s) => s.passed).length, finished.length),
      average_seconds: times.length === 0 ? null : Math.round(times.reduce((x, y) => x + y, 0) / times.length),
    },
    students,
    // Eng ko'p xato qilingan savollar birinchi (javob bergani bor savollar).
    most_missed: questions
      .filter((q) => q.attempts > 0)
      .sort((x, y) => (x.correct_percent ?? 0) - (y.correct_percent ?? 0) || x.index - y.index)
      .slice(0, 5)
      .map((q) => q.index),
    questions,
  };
}

/**
 * GET /v1/teacher/assignments/:a/results — talaba va savol kesimidagi
 * jamlanma. Faqat guruhga rozilik bilan qo'shilgan, HOZIR a'zo talabalar.
 * O'z natijalari obunasiz ham ko'rinadi (D-78 §7).
 */
export async function results(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const a = await ownAssignment(ctx, s, raw);
  return json(summarize(a, await targetsOf(ctx, a), await visibleAttempts(ctx, a), ctx.now));
}

/** CSV katak: qo'shtirnoq va formula in'ektsiyasidan (= + - @) himoya. */
export function csvCell(v: unknown): string {
  let s = v == null ? '' : String(v);
  if (/^[=+\-@\t\r]/.test(s)) s = `'${s}`;
  return /[",\n\r;]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

/**
 * GET /v1/teacher/assignments/:a/export — natijalar CSV (Ustoz Pro: YANGI
 * eksport amali). Emailsiz: taxallus yoki "Talaba NN".
 */
export async function exportResults(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherPro(ctx);
  const a = await ownAssignment(ctx, s, raw);
  const r = summarize(a, await targetsOf(ctx, a), await visibleAttempts(ctx, a), ctx.now);
  const rows: unknown[][] = [
    ['student', 'state', 'attempts', 'best_score', 'total', 'best_percent', 'passed', 'seconds', 'late', 'submitted_at'],
    ...r.students.map((x) => [
      x.label,
      x.state,
      x.attempts,
      x.best_score,
      x.total,
      x.best_percent,
      x.passed == null ? '' : x.passed ? 'yes' : 'no',
      x.best_seconds,
      x.late ? 'yes' : 'no',
      x.last_submitted_at,
    ]),
    [],
    ['question', 'text', 'answered', 'correct', 'correct_percent'],
    ...r.questions.map((q) => [q.index + 1, q.text, q.answered, q.right, q.correct_percent]),
  ];
  const csv = rows.map((row) => row.map(csvCell).join(',')).join('\r\n');
  await audit(ctx, s.userId, 'teacher_results_exported', a.id, { rows: r.students.length });
  return json({ filename: `labguide-results-${a.id.slice(0, 8)}.csv`, csv });
}

// --------------------------------------------------------- taklifnoma
async function inviteHash(ctx: Ctx, token: string): Promise<string> {
  return hex(await hmac(ctx.keys.otp, `teacher-invite:${token}`));
}

function normalizeToken(raw: string): string {
  let t: string;
  try {
    t = decodeURIComponent(raw);
  } catch {
    throw notFound();
  }
  t = t.toUpperCase().replace(/[\s-]/g, '');
  if (!INVITE_RE.test(t)) throw notFound();
  return t;
}

interface InviteRow {
  id: string;
  group_id: string;
  owner_id: string;
  token_enc: string;
  max_uses: number;
  uses: number;
  created_at: number;
  expires_at: number;
  revoked_at: number | null;
}

const inviteActive = (i: InviteRow, now: number) => i.revoked_at == null && now < i.expires_at && i.uses < i.max_uses;

async function inviteJson(ctx: Ctx, i: InviteRow) {
  const token = new TextDecoder().decode(await decrypt(ctx.keys.totp, i.token_enc));
  return {
    id: i.id,
    group_id: i.group_id,
    token,
    max_uses: i.max_uses,
    uses: i.uses,
    created_at: iso(i.created_at),
    expires_at: iso(i.expires_at),
    active: inviteActive(i, ctx.now),
  };
}

/**
 * POST /v1/teacher/groups/:g/invites — o'z guruhiga taklifnoma kodi
 * (muddati va foydalanish soni cheklangan). Talaba kodni kiritib, nima
 * ulashilishini ko'radi va o'zi rozilik beradi (accept).
 */
export async function createInvite(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireTeacherPro(ctx);
  await writeLimit(ctx, s);
  const g = await ownGroup(ctx, s, gid);
  const body = await readJson(ctx.req);
  const uses = optionalInt(body.max_uses, 1, TT_LIMITS.inviteUses, 'invalid_max_uses') ?? 50;
  const days = optionalInt(body.days, 1, TT_LIMITS.inviteDays, 'invalid_days') ?? 7;
  const n = await ctx.db
    .prepare(
      `SELECT COUNT(*) AS n FROM teacher_invites
       WHERE group_id = ?1 AND revoked_at IS NULL AND expires_at > ?2 AND uses < max_uses`,
    )
    .bind(g.id, ctx.now)
    .first<{ n: number }>();
  if ((n?.n ?? 0) >= TT_LIMITS.invitesPerGroup) throw new ApiError(429, 'limit_invites');
  const token = randomFrom(INVITE_ALPHABET, 12);
  const row: InviteRow = {
    id: crypto.randomUUID(),
    group_id: g.id,
    owner_id: s.userId,
    token_enc: await encrypt(ctx.keys.totp, new TextEncoder().encode(token)),
    max_uses: uses,
    uses: 0,
    created_at: ctx.now,
    expires_at: ctx.now + days * DAY,
    revoked_at: null,
  };
  await ctx.db
    .prepare(
      `INSERT INTO teacher_invites (id, group_id, owner_id, token_hash, token_enc, max_uses, uses, created_at, expires_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, 0, ?7, ?8)`,
    )
    .bind(row.id, g.id, s.userId, await inviteHash(ctx, token), row.token_enc, uses, ctx.now, row.expires_at)
    .run();
  await audit(ctx, s.userId, 'teacher_invite_created', g.id, { invite: row.id, max_uses: uses, days });
  return json(await inviteJson(ctx, row), 201);
}

/** GET /v1/teacher/groups/:g/invites — o'z guruhining taklifnomalari (oxirgi 30 kun). */
export async function listInvites(ctx: Ctx, gid: string): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const g = await ownGroup(ctx, s, gid);
  const rows = await ctx.db
    .prepare(
      `SELECT * FROM teacher_invites WHERE group_id = ?1 AND revoked_at IS NULL AND expires_at > ?2
       ORDER BY created_at DESC LIMIT 50`,
    )
    .bind(g.id, ctx.now - 30 * DAY)
    .all<InviteRow>();
  return json(await Promise.all(rows.results.map((i) => inviteJson(ctx, i))));
}

/** DELETE /v1/teacher/invites/:id — taklifnomani bekor qilish (darhol ishlamaydi). */
export async function revokeInvite(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireTeacherAccount(ctx);
  const r = await ctx.db
    .prepare('UPDATE teacher_invites SET revoked_at = ?3 WHERE id = ?1 AND owner_id = ?2 AND revoked_at IS NULL')
    .bind(uuidParam(raw), s.userId, ctx.now)
    .run();
  if (!r.meta.changes) throw notFound();
  await audit(ctx, s.userId, 'teacher_invite_revoked', raw);
  return noContent();
}

async function inviteLimits(ctx: Ctx, s: Session): Promise<void> {
  await hit(ctx.db, `tinv-user:${s.userId}`, 20, 900, ctx.now);
  await hit(ctx.db, `tinv-ip:${ctx.ipTag}`, 100, 3600, ctx.now);
}

async function findInvite(ctx: Ctx, raw: string): Promise<InviteRow & { group_name: string; teacher_alias: string | null }> {
  const token = normalizeToken(raw);
  const i = await ctx.db
    .prepare(
      `SELECT i.*, g.name AS group_name, m.nickname AS teacher_alias FROM teacher_invites i
       JOIN study_groups g ON g.id = i.group_id
       LEFT JOIN group_members m ON m.group_id = g.id AND m.user_id = g.owner_id
       WHERE i.token_hash = ?1`,
    )
    .bind(await inviteHash(ctx, token))
    .first<InviteRow & { group_name: string; teacher_alias: string | null }>();
  if (!i) throw notFound();
  if (!inviteActive(i, ctx.now)) throw new ApiError(410, 'invite_expired');
  return i;
}

/**
 * GET /v1/teacher-invites/:token — talaba rozilikdan OLDIN ko'radi: guruh,
 * ustoz va ustozga nima ko'rinishi. Hech narsa yozilmaydi.
 */
export async function previewInvite(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  await inviteLimits(ctx, s);
  const i = await findInvite(ctx, raw);
  const m = await ctx.db
    .prepare('SELECT member_role FROM group_members WHERE group_id = ?1 AND user_id = ?2')
    .bind(i.group_id, s.userId)
    .first<{ member_role: string }>();
  return json({
    group_id: i.group_id,
    group_name: i.group_name,
    teacher_alias: i.teacher_alias,
    already_member: m != null,
    own_group: i.owner_id === s.userId,
    expires_at: iso(i.expires_at),
    // Rozilik matni uchun: ustoz ko'radigan ma'lumotlar.
    shares: ['alias_or_seat', 'teacher_test_results'],
  });
}

/**
 * POST /v1/teacher-invites/:token/accept — talabaning ANIQ roziligi: guruhga
 * qo'shiladi (taxallus ixtiyoriy). Rad etish — hech narsa yozilmaydi.
 */
export async function acceptInvite(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  await inviteLimits(ctx, s);
  const i = await findInvite(ctx, raw);
  if (i.owner_id === s.userId) throw conflict('own_group');
  const m = await ctx.db
    .prepare('SELECT member_role FROM group_members WHERE group_id = ?1 AND user_id = ?2')
    .bind(i.group_id, s.userId)
    .first<{ member_role: string }>();
  if (m) return json({ group_id: i.group_id, already_member: true });
  const body = await readJson(ctx.req);
  if (body.consent !== true) throw badRequest('consent_required');
  const nick = nickname(body.display_name);
  await requireFreeNickname(ctx, i.group_id, nick);
  // Foydalanish soni atomar (parallel qabul limitdan oshmaydi).
  const used = await ctx.db
    .prepare(
      `UPDATE teacher_invites SET uses = uses + 1
       WHERE id = ?1 AND revoked_at IS NULL AND expires_at > ?2 AND uses < max_uses RETURNING uses`,
    )
    .bind(i.id, ctx.now)
    .first<{ uses: number }>();
  if (!used) throw new ApiError(410, 'invite_expired');
  try {
    await addStudent(ctx, i.group_id, s.userId, nick);
  } catch (e) {
    await ctx.db.prepare('UPDATE teacher_invites SET uses = uses - 1 WHERE id = ?1').bind(i.id).run();
    throw e;
  }
  await audit(ctx, s.userId, 'teacher_invite_accepted', i.group_id, { invite: i.id });
  return json({ group_id: i.group_id, already_member: false }, 201);
}

// ------------------------------------------------------ talaba tomoni
/** Talabaga ko'rinadigan topshiriq: a'zo bo'lgan guruhda, butun guruhga yoki o'ziga. */
async function myAssignment(ctx: Ctx, s: Session, raw: string): Promise<AssignmentRow & { group_name: string; teacher_alias: string | null }> {
  const a = await ctx.db
    .prepare(
      `SELECT a.*, g.name AS group_name, tm.nickname AS teacher_alias FROM teacher_test_assignments a
       JOIN study_groups g ON g.id = a.group_id
       JOIN group_members m ON m.group_id = a.group_id AND m.user_id = ?2 AND m.member_role = 'student'
       LEFT JOIN group_members tm ON tm.group_id = g.id AND tm.user_id = g.owner_id
       WHERE a.id = ?1 AND (a.user_id IS NULL OR a.user_id = ?2)`,
    )
    .bind(uuidParam(raw), s.userId)
    .first<AssignmentRow & { group_name: string; teacher_alias: string | null }>();
  if (!a) throw notFound();
  return a;
}

async function myAttempts(ctx: Ctx, aid: string, uid: string): Promise<AttemptRow[]> {
  const rows = await ctx.db
    .prepare('SELECT * FROM teacher_test_attempts WHERE assignment_id = ?1 AND user_id = ?2 ORDER BY attempt_no')
    .bind(aid, uid)
    .all<AttemptRow>();
  return rows.results;
}

/** Javoblar talabaga qachon ochiladi: urinish qolmagach, yopilgach yoki muddat o'tgach. */
function revealed(a: AssignmentRow, attempts: AttemptRow[], now: number): boolean {
  return a.status === 'closed' || now > a.due_at || attempts.length >= a.max_attempts;
}

function studentJson(
  a: AssignmentRow & { group_name: string; teacher_alias: string | null },
  attempts: AttemptRow[],
  now: number,
) {
  const done = attempts.filter((t) => t.status === 'submitted');
  const best = done.reduce<AttemptRow | null>((b, t) => (b == null || (t.score ?? 0) > (b.score ?? 0) ? t : b), null);
  const open = attempts.find((t) => t.status === 'started' && !timedOut(t, now));
  const used = attempts.length;
  return {
    id: a.id,
    title: a.title,
    group_id: a.group_id,
    group_name: a.group_name,
    teacher_alias: a.teacher_alias,
    question_count: a.question_count,
    time_limit_minutes: a.time_limit_minutes,
    pass_percent: a.pass_percent,
    max_attempts: a.max_attempts,
    attempts_used: used,
    due_at: iso(a.due_at),
    late_policy: a.late_policy,
    status: a.status,
    state: stateOf(a, attempts, now),
    can_start: open == null && canStartNew(a, used, now) == null,
    open_attempt_id: open?.id ?? null,
    best_score: best?.score ?? null,
    best_percent: best == null ? null : percent(best.score ?? 0, best.total),
    passed: best == null || a.pass_percent == null ? null : percent(best.score ?? 0, best.total) >= a.pass_percent,
    late: done.some((t) => t.late === 1),
    // Ustozga ko'rinadi: ilova birinchi topshirishdan oldin ogohlantiradi.
    visible_to_teacher: true,
  };
}

/** GET /v1/me/teacher-tests — menga berilgan Ustoz testlari (obunasiz ham ko'rinadi). */
export async function listMine(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const rows = await ctx.db
    .prepare(
      `SELECT a.*, g.name AS group_name, tm.nickname AS teacher_alias FROM teacher_test_assignments a
       JOIN study_groups g ON g.id = a.group_id
       JOIN group_members m ON m.group_id = a.group_id AND m.user_id = ?1 AND m.member_role = 'student'
       LEFT JOIN group_members tm ON tm.group_id = g.id AND tm.user_id = g.owner_id
       WHERE a.user_id IS NULL OR a.user_id = ?1
       ORDER BY a.due_at DESC LIMIT 200`,
    )
    .bind(s.userId)
    .all<AssignmentRow & { group_name: string; teacher_alias: string | null }>();
  const attempts = await ctx.db
    .prepare('SELECT * FROM teacher_test_attempts WHERE user_id = ?1 ORDER BY attempt_no')
    .bind(s.userId)
    .all<AttemptRow>();
  const by = new Map<string, AttemptRow[]>();
  for (const t of attempts.results) {
    const l = by.get(t.assignment_id) ?? [];
    l.push(t);
    by.set(t.assignment_id, l);
  }
  return json(rows.results.map((a) => studentJson(a, by.get(a.id) ?? [], ctx.now)));
}

function attemptJson(t: AttemptRow, a: AssignmentRow, reveal: boolean) {
  const qs = questionsOf(a.questions);
  const answers = t.answers == null ? null : (JSON.parse(t.answers) as number[]);
  return {
    id: t.id,
    attempt_no: t.attempt_no,
    status: t.status,
    started_at: iso(t.started_at),
    submitted_at: iso(t.submitted_at),
    score: t.score,
    total: t.total,
    percent: t.score == null ? null : percent(t.score, t.total),
    passed: t.score == null || a.pass_percent == null ? null : percent(t.score, t.total) >= a.pass_percent,
    late: t.late === 1,
    seconds: t.submitted_at == null ? null : Math.round((t.submitted_at - t.started_at) / 1000),
    // To'g'ri javob va izoh faqat ochilganda (aks holda keyingi urinishda ko'chirilardi).
    review:
      reveal && answers != null
        ? qs.map((q, i) => ({
            text: q.text,
            options: q.options,
            answer: answers[i] ?? -1,
            correct: q.correct,
            explanation: q.explanation,
          }))
        : null,
  };
}

/** GET /v1/me/teacher-tests/:a — topshiriq va o'z urinishlari (natija har doim ko'rinadi). */
export async function getMine(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  const a = await myAssignment(ctx, s, raw);
  const attempts = await myAttempts(ctx, a.id, s.userId);
  const reveal = revealed(a, attempts, ctx.now);
  return json({
    ...studentJson(a, attempts, ctx.now),
    attempts: attempts.map((t) => attemptJson(t, a, reveal)),
  });
}

function runJson(t: AttemptRow, a: AssignmentRow, resumed: boolean, now: number) {
  return {
    attempt_id: t.id,
    attempt_no: t.attempt_no,
    started_at: iso(t.started_at),
    time_up_at: iso(t.time_up_at),
    server_now: iso(now),
    resumed,
    // Kalitsiz: matn va variantlar.
    questions: questionsOf(a.questions).map((q) => ({ text: q.text, options: q.options })),
  };
}

/**
 * POST /v1/me/teacher-tests/:a/start — boshlangan urinish qayta ochiladi
 * (tekshiruvsiz: boshlangan test hech qachon to'xtatilmaydi); YANGI urinish
 * — Talaba Pro (`learner`), muddat, yopilgan va urinishlar soni serverda.
 */
export async function startMine(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  const a = await myAssignment(ctx, s, raw);
  const attempts = await myAttempts(ctx, a.id, s.userId);
  const open = attempts.find((t) => t.status === 'started');
  if (open && !timedOut(open, ctx.now)) return json(runJson(open, a, true, ctx.now));
  if (open) {
    // Vaqti tugagan, topshirilmagan urinish — `expired` (urinish sanaladi).
    await ctx.db.prepare(`UPDATE teacher_test_attempts SET status = 'expired' WHERE id = ?1`).bind(open.id).run();
    open.status = 'expired';
  }
  await requireTier(ctx, 'learner');
  const blocked = canStartNew(a, attempts.length, ctx.now);
  if (blocked) throw conflict(blocked);
  await hit(ctx.db, `tt-start:${s.userId}`, 30, 3600, ctx.now);
  // Vaqt chegarasi; "kechikkanni qabul qilmaslik" bo'lsa — muddat bilan ham cheklanadi.
  const ends = [
    ...(a.time_limit_minutes == null ? [] : [ctx.now + a.time_limit_minutes * 60_000]),
    ...(a.late_policy === 'reject' ? [a.due_at] : []),
  ];
  const t: AttemptRow = {
    id: crypto.randomUUID(),
    assignment_id: a.id,
    user_id: s.userId,
    attempt_no: attempts.length + 1,
    started_at: ctx.now,
    time_up_at: ends.length === 0 ? null : Math.min(...ends),
    submitted_at: null,
    answers: null,
    correct: null,
    score: null,
    total: a.question_count,
    late: 0,
    status: 'started',
  };
  const r = await ctx.db
    .prepare(
      `INSERT INTO teacher_test_attempts (id, assignment_id, user_id, attempt_no, started_at, time_up_at, total, status)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, 'started') ON CONFLICT DO NOTHING`,
    )
    .bind(t.id, a.id, s.userId, t.attempt_no, t.started_at, t.time_up_at, t.total)
    .run();
  if (!r.meta.changes) {
    // Parallel "Boshlash": ikkinchisi birinchisining urinishini oladi.
    const again = (await myAttempts(ctx, a.id, s.userId)).find((x) => x.status === 'started');
    if (again) return json(runJson(again, a, true, ctx.now));
    throw conflict('start_conflict');
  }
  return json(runJson(t, a, false, ctx.now), 201);
}

/**
 * POST /v1/me/teacher-tests/:a/submit — javoblar (-1 — javobsiz); ball
 * serverda. Obuna tekshirilmaydi: boshlangan urinish doim topshiriladi.
 * Vaqt (2 daqiqa tarmoq vaqti bilan), yopilish va muddat serverda.
 */
export async function submitMine(ctx: Ctx, raw: string): Promise<Response> {
  const s = await requireSession(ctx);
  const a = await myAssignment(ctx, s, raw);
  const body = await readJson(ctx.req);
  if (typeof body.attempt_id !== 'string') throw badRequest('invalid_attempt');
  const t = await ctx.db
    .prepare('SELECT * FROM teacher_test_attempts WHERE id = ?1 AND assignment_id = ?2 AND user_id = ?3')
    .bind(uuidParam(body.attempt_id), a.id, s.userId)
    .first<AttemptRow>();
  if (!t) throw notFound();
  if (t.status === 'submitted') throw conflict('already_submitted');
  if (t.status === 'expired') throw conflict('time_over');
  if (timedOut(t, ctx.now)) {
    await ctx.db.prepare(`UPDATE teacher_test_attempts SET status = 'expired' WHERE id = ?1`).bind(t.id).run();
    throw conflict('time_over');
  }
  // Ustoz yopdi: yopilishdan oldin boshlaganlarga qisqa tarmoq vaqti.
  if (a.status === 'closed' && (a.closed_at == null || t.started_at > a.closed_at || ctx.now > a.closed_at + TT_GRACE_MS)) {
    throw conflict('closed');
  }
  const qs = questionsOf(a.questions);
  const ans = body.answers;
  if (
    !Array.isArray(ans) ||
    ans.length !== qs.length ||
    !ans.every((x, i) => Number.isInteger(x) && x >= -1 && x < qs[i].options.length)
  ) {
    throw badRequest('invalid_answers');
  }
  const answers = ans as number[];
  const correct = qs.map((q, i) => answers[i] === q.correct);
  const score = correct.filter(Boolean).length;
  // Kechikkan — faqat "qabul qilinadi" siyosatida (aks holda muddatdan keyin
  // faqat 2 daqiqalik tarmoq vaqti bor va u kechikish sanalmaydi).
  const late = a.late_policy === 'accept' && ctx.now > a.due_at ? 1 : 0;
  const r = await ctx.db
    .prepare(
      `UPDATE teacher_test_attempts SET answers = ?2, correct = ?3, score = ?4, submitted_at = ?5, late = ?6,
         status = 'submitted' WHERE id = ?1 AND status = 'started'`,
    )
    .bind(t.id, JSON.stringify(answers), JSON.stringify(correct), score, ctx.now, late)
    .run();
  if (!r.meta.changes) throw conflict('already_submitted');
  const done: AttemptRow = {
    ...t,
    answers: JSON.stringify(answers),
    correct: JSON.stringify(correct),
    score,
    submitted_at: ctx.now,
    late,
    status: 'submitted',
  };
  const attempts = await myAttempts(ctx, a.id, s.userId);
  return json(attemptJson(done, a, revealed(a, attempts, ctx.now)), 201);
}
