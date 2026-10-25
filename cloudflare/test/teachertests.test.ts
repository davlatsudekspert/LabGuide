// Ustoz Pro (D-78, src/teachertests.ts, 0030_teacher_tests.sql): vakolat
// (sessiya, reja, ustoz hisobi), egalik, tekshiruv, topshiriq hayot sikli
// (assigned → started → submitted → expired), muddat va vaqt, maxfiylik
// (ustoz faqat rozilik bergan a'zolarni ko'radi), taklifnoma, natijalar va
// CSV, o'chirish kaskadi. Bepul guruhlar (groups.ts) o'zgarmaganini ham
// tekshiradi.
import { describe, expect, it } from 'vitest';
import { csvCell, TT_GRACE_MS, TT_LIMITS } from '../src/teachertests';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
const MIN = 60_000;
const makeServer = () => baseServer({ LG_BILLING_ENABLED: 'true' } as never);
type Srv = ReturnType<typeof makeServer>;

const PRODUCTS = {
  student: 'uz.labguide.student.monthly',
  teacher: 'uz.labguide.teacher.monthly',
  specialist: 'uz.labguide.specialist.monthly',
  premium: 'uz.labguide.premium.monthly',
} as const;

async function buy(s: Srv, userId: string, plan: keyof typeof PRODUCTS, days = 30) {
  await s.env.DB.prepare(
    `INSERT INTO entitlements (platform, original_transaction_id, user_id, product_id, status, started_at, expires_at,
       latest_token, event_at, updated_at) VALUES ('play_store', ?1, ?2, ?3, 'active', ?4, ?5, 't', ?4, ?4)`,
  )
    .bind(`tx-${crypto.randomUUID()}`, userId, PRODUCTS[plan], s.clock.now, s.clock.now + days * DAY)
    .run();
}

async function trial(s: Srv, userId: string, tier: 'student' | 'teacher', days = 7) {
  const k = () => crypto.randomUUID().replace(/-/g, '').padEnd(64, '0').slice(0, 64);
  await s.env.DB.prepare(
    `INSERT INTO pro_trials (id, user_id, tier, platform, email_key, device_key, started_at, expires_at, retain_until)
     VALUES (?1, ?2, ?3, 'android', ?4, ?5, ?6, ?7, ?8)`,
  )
    .bind(crypto.randomUUID(), userId, tier, k(), k(), s.clock.now, s.clock.now + days * DAY, s.clock.now + 730 * DAY)
    .run();
}

const q = (text: string, correct = 0, n = 3) => ({
  text,
  options: Array.from({ length: n }, (_, i) => `${text} — variant ${i + 1}`),
  correct,
  explanation: `${text}: izoh`,
});

const testBody = (over: Record<string, unknown> = {}) => ({
  title: 'Gematologiya: nazorat',
  description: 'Uchinchi hafta',
  questions: [q('Eritrotsit', 0), q('Leykotsit', 1), q('Trombotsit', 2)],
  time_limit_minutes: 10,
  pass_percent: 60,
  status: 'published',
  ...over,
});

/** Ustoz Pro'li ustoz + guruh (bepul guruh oqimi). */
async function proTeacher(s: Srv, plan: keyof typeof PRODUCTS = 'teacher') {
  const t = await s.signInTeacher(uniqueEmail('tp'));
  await buy(s, t.userId, plan);
  const g = await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Lab-21 guruhi' } });
  expect(g.status).toBe(201);
  return { ...t, groupId: g.data.id as string, code: g.data.join_code as string };
}

async function student(s: Srv, code: string, plan: keyof typeof PRODUCTS | null = 'student', alias?: string) {
  const u = await s.signIn(uniqueEmail('st'));
  if (plan) await buy(s, u.userId, plan);
  const j = await s.call('POST', '/v1/groups/join', { token: u.token, body: { code, display_name: alias } });
  expect(j.status).toBe(201);
  return u;
}

async function createTest(s: Srv, token: string, over: Record<string, unknown> = {}) {
  const r = await s.call('POST', '/v1/teacher/tests', { token, body: testBody(over) });
  expect(r.status, r.text).toBe(201);
  return r.data;
}

async function assign(s: Srv, token: string, testId: string, body: Record<string, unknown>) {
  return s.call('POST', `/v1/teacher/tests/${testId}/assignments`, { token, body });
}

const due = (s: Srv, days = 3) => new Date(s.clock.now + days * DAY).toISOString();

async function setup(over: Record<string, unknown> = {}, assignOver: Record<string, unknown> = {}) {
  const s = makeServer();
  const t = await proTeacher(s);
  const st = await student(s, t.code);
  const test = await createTest(s, t.token, over);
  const a = await assign(s, t.token, test.id, { group_id: t.groupId, due_at: due(s), ...assignOver });
  expect(a.status, a.text).toBe(201);
  return { s, t, st, test, a: a.data };
}

describe('Ustoz Pro: bayroq o‘chiq — yo‘llar yo‘q (404)', () => {
  it('teacher/*, teacher-invites/*, me/teacher-tests — tokenli ham 404', async () => {
    const s = baseServer();
    const u = await s.signInTeacher(uniqueEmail('off'));
    for (const [m, p] of [
      ['GET', '/v1/teacher/tests'],
      ['POST', '/v1/teacher/tests'],
      ['GET', '/v1/teacher/assignments'],
      ['GET', '/v1/me/teacher-tests'],
      ['GET', '/v1/teacher-invites/ABCDEFGHJKLM'],
      ['POST', '/v1/teacher-invites/ABCDEFGHJKLM/accept'],
    ]) {
      for (const token of [undefined, u.token]) {
        const r = await s.call(m, p, { token, body: m === 'POST' ? {} : undefined });
        expect(r.status, `${m} ${p}`).toBe(404);
      }
    }
  });
});

describe('vakolat: sessiya, reja (requireTier), ustoz hisobi', () => {
  it('tokensiz 401; rejasiz 403 plan_required; Talaba/Mutaxassis — tier_insufficient; rejali, ustoz emas — teacher_role_required', async () => {
    const s = makeServer();
    expect((await s.call('POST', '/v1/teacher/tests', { body: testBody() })).status).toBe(401);
    expect((await s.call('GET', '/v1/teacher/tests')).status).toBe(401);

    const free = await s.signInTeacher(uniqueEmail('free'));
    const r1 = await s.call('POST', '/v1/teacher/tests', { token: free.token, body: testBody() });
    expect(r1.status).toBe(403);
    expect(r1.data).toMatchObject({ error: 'plan_required', capability: 'teacher_panel' });

    for (const plan of ['student', 'specialist'] as const) {
      const u = await s.signInTeacher(uniqueEmail(plan));
      await buy(s, u.userId, plan);
      const r = await s.call('POST', '/v1/teacher/tests', { token: u.token, body: testBody() });
      expect(r.status, plan).toBe(403);
      expect(r.data).toMatchObject({ error: 'tier_insufficient', capability: 'teacher_panel', plan });
    }

    // Ustoz rejasi, lekin serverda ustoz sifatida ro'yxatdan o'tmagan (profil roli yetmaydi).
    const noRole = await s.signIn(uniqueEmail('norole'), { role: 'teacher' });
    await buy(s, noRole.userId, 'teacher');
    const r2 = await s.call('POST', '/v1/teacher/tests', { token: noRole.token, body: testBody() });
    expect(r2.status).toBe(403);
    expect(r2.data.error).toBe('teacher_role_required');
    expect((await s.call('GET', '/v1/teacher/tests', { token: noRole.token })).data.error).toBe('teacher_role_required');
  });

  it('Ustoz Pro obunasi, Premium va 7 kunlik Ustoz sinovi — ochiq; sinov tugagach — yopiq, lekin ma’lumot ko‘rinadi', async () => {
    const s = makeServer();
    for (const plan of ['teacher', 'premium'] as const) {
      const u = await s.signInTeacher(uniqueEmail(plan));
      await buy(s, u.userId, plan);
      expect((await s.call('POST', '/v1/teacher/tests', { token: u.token, body: testBody() })).status, plan).toBe(201);
    }
    const tr = await s.signInTeacher(uniqueEmail('trial'));
    await trial(s, tr.userId, 'teacher');
    const created = await s.call('POST', '/v1/teacher/tests', { token: tr.token, body: testBody() });
    expect(created.status).toBe(201);
    // Talaba sinovi ustoz panelini ochmaydi.
    const st = await s.signInTeacher(uniqueEmail('trial-st'));
    await trial(s, st.userId, 'student');
    expect((await s.call('POST', '/v1/teacher/tests', { token: st.token, body: testBody() })).data.error).toBe(
      'tier_insufficient',
    );

    s.clock.now += 8 * DAY; // sinov tugadi
    const after = await s.call('POST', '/v1/teacher/tests', { token: tr.token, body: testBody() });
    expect(after.status).toBe(403);
    expect(after.data.error).toBe('plan_required');
    // D-78 §7: o'z ma'lumoti o'chirilmaydi va yashirilmaydi.
    const list = await s.call('GET', '/v1/teacher/tests', { token: tr.token });
    expect(list.status).toBe(200);
    expect(list.data.map((t: { id: string }) => t.id)).toEqual([created.data.id]);
    expect((await s.call('GET', `/v1/teacher/tests/${created.data.id}`, { token: tr.token })).status).toBe(200);
    // Tahrirlash — yangi pullik amal.
    expect(
      (await s.call('PUT', `/v1/teacher/tests/${created.data.id}`, { token: tr.token, body: testBody() })).status,
    ).toBe(403);
    // O'chirish — o'z ma'lumotini boshqarish, obunasiz ham.
    expect((await s.call('DELETE', `/v1/teacher/tests/${created.data.id}`, { token: tr.token })).status).toBe(204);
  });
});

describe('testlar: yaratish, tekshiruv, tahrir, o‘chirish, egalik', () => {
  it('yaratish: kalit va izoh egasiga; manba (bank nusxasi) saqlanadi; audit', async () => {
    const s = makeServer();
    const t = await proTeacher(s);
    const body = testBody({
      questions: [{ ...q('Gemoglobin'), source: { bank: 'quiz', id: 'q.hb.01' } }, q('Gematokrit', 2, 4)],
    });
    const r = await s.call('POST', '/v1/teacher/tests', { token: t.token, body });
    expect(r.status).toBe(201);
    expect(r.data).toMatchObject({ title: body.title, question_count: 2, status: 'published', version: 1 });
    expect(r.data.questions[0]).toEqual({
      text: 'Gemoglobin',
      options: body.questions[0].options,
      correct: 0,
      explanation: 'Gemoglobin: izoh',
      source: { bank: 'quiz', id: 'q.hb.01' },
    });
    expect(r.data.questions[1].source).toBeNull();
    const audit = await s.env.DB.prepare(`SELECT action FROM audit_log WHERE actor = ?1 AND target = ?2`)
      .bind(t.userId, r.data.id)
      .all<{ action: string }>();
    expect(audit.results.map((x) => x.action)).toContain('teacher_test_created');
  });

  it('tekshiruv: sarlavha, variantlar 2–6, kalit, uzunliklar, soni, manba, vaqt, o‘tish chegarasi, nashr', async () => {
    const s = makeServer();
    const t = await proTeacher(s);
    const bad = async (over: Record<string, unknown>, code: string) => {
      const r = await s.call('POST', '/v1/teacher/tests', { token: t.token, body: testBody(over) });
      expect(r.status, code).toBe(400);
      expect(r.data.error, JSON.stringify(over).slice(0, 80)).toBe(code);
    };
    await bad({ title: 'ab' }, 'invalid_title');
    await bad({ title: 'x'.repeat(121) }, 'invalid_title');
    await bad({ description: 'd'.repeat(1001) }, 'invalid_description');
    await bad({ questions: [q('A', 0, 1)] }, 'invalid_options');
    await bad({ questions: [q('A', 0, 7)] }, 'invalid_options');
    await bad({ questions: [{ ...q('A'), options: ['bir', 'Bir'] }] }, 'duplicate_options');
    await bad({ questions: [q('A', 3)] }, 'invalid_correct');
    await bad({ questions: [{ ...q('A'), correct: 0.5 }] }, 'invalid_correct');
    await bad({ questions: [{ ...q('A'), text: ' ' }] }, 'invalid_question_text');
    await bad({ questions: [{ ...q('A'), text: 't'.repeat(1001) }] }, 'invalid_question_text');
    await bad({ questions: [{ ...q('A'), options: ['o'.repeat(301), 'b'] }] }, 'invalid_options');
    await bad({ questions: [{ ...q('A'), explanation: 'e'.repeat(1001) }] }, 'invalid_explanation');
    await bad({ questions: [{ ...q('A'), source: { bank: 'internet', id: 'x' } }] }, 'invalid_source');
    await bad({ questions: [{ ...q('A'), source: { bank: 'quiz', id: '../x' } }] }, 'invalid_source');
    await bad({ questions: Array.from({ length: TT_LIMITS.questions + 1 }, (_, i) => q(`Q${i}`)) }, 'invalid_questions');
    await bad({ time_limit_minutes: 0 }, 'invalid_time_limit');
    await bad({ time_limit_minutes: 181 }, 'invalid_time_limit');
    await bad({ pass_percent: 0 }, 'invalid_pass_percent');
    await bad({ pass_percent: 101 }, 'invalid_pass_percent');
    await bad({ status: 'draft' }, 'invalid_status');
    await bad({ questions: [], status: 'published' }, 'no_questions');
    await bad({ title: 'Bullshit test' }, 'abusive_language');
    // Nashr etilmagan bo'sh test — ruxsat (keyin to'ldiriladi).
    const ok = await s.call('POST', '/v1/teacher/tests', {
      token: t.token,
      body: testBody({ questions: [], status: 'unpublished', time_limit_minutes: null, pass_percent: null }),
    });
    expect(ok.status).toBe(201);
    expect(ok.data).toMatchObject({ question_count: 0, status: 'unpublished', time_limit_minutes: null });
    // 100 ta savol (chegara) — o'tadi (tana 32 KB dan katta).
    const big = await s.call('POST', '/v1/teacher/tests', {
      token: t.token,
      body: testBody({
        questions: Array.from({ length: 100 }, (_, i) => ({ ...q(`S${i}`), text: `Savol ${i} ${'m'.repeat(400)}` })),
      }),
    });
    expect(big.status, big.text).toBe(201);
    expect(big.data.question_count).toBe(100);
  });

  it('tahrir: versiya oshadi, eski versiya bilan yozish — 409; berilgan topshiriq nusxasi o‘zgarmaydi', async () => {
    const { s, t, st, test, a } = await setup();
    const put = await s.call('PUT', `/v1/teacher/tests/${test.id}`, {
      token: t.token,
      body: testBody({ title: 'Yangi nom', questions: [q('Bitta savol')], version: 1 }),
    });
    expect(put.status).toBe(200);
    expect(put.data).toMatchObject({ title: 'Yangi nom', version: 2, question_count: 1, assignment_count: 1 });
    const stale = await s.call('PUT', `/v1/teacher/tests/${test.id}`, {
      token: t.token,
      body: testBody({ version: 1 }),
    });
    expect(stale.status).toBe(409);
    expect(stale.data.error).toBe('version_conflict');
    // Talabadagi topshiriq — eski nusxa (3 savol, eski nom).
    const mine = await s.call('GET', `/v1/me/teacher-tests/${a.id}`, { token: st.token });
    expect(mine.data).toMatchObject({ title: 'Gematologiya: nazorat', question_count: 3 });
  });

  it('egalik: begona ustoz testni ko‘rmaydi, tahrirlamaydi, o‘chirmaydi, topshirmaydi (404); begona guruhga topshirib bo‘lmaydi', async () => {
    const s = makeServer();
    const a = await proTeacher(s);
    const b = await proTeacher(s);
    const test = await createTest(s, a.token);
    for (const [m, p] of [
      ['GET', `/v1/teacher/tests/${test.id}`],
      ['PUT', `/v1/teacher/tests/${test.id}`],
      ['DELETE', `/v1/teacher/tests/${test.id}`],
      ['POST', `/v1/teacher/tests/${test.id}/assignments`],
    ]) {
      const r = await s.call(m, p, { token: b.token, body: m === 'GET' || m === 'DELETE' ? undefined : testBody() });
      expect(r.status, `${m} ${p}`).toBe(404);
    }
    expect((await s.call('GET', '/v1/teacher/tests', { token: b.token })).data).toEqual([]);
    // A o'z testini B ning guruhiga topshira olmaydi.
    const r = await assign(s, a.token, test.id, { group_id: b.groupId, due_at: due(s) });
    expect(r.status).toBe(404);
    // Talaba (guruh a'zosi) ham ustoz yo'llariga kira olmaydi.
    const st = await student(s, a.code, 'premium');
    expect((await s.call('GET', `/v1/teacher/tests/${test.id}`, { token: st.token })).data.error).toBe(
      'teacher_role_required',
    );
    expect((await s.call('GET', '/v1/teacher/tests/not-a-uuid', { token: a.token })).status).toBe(404);
    // Test o'chirilsa — topshiriq va urinishlar ham.
    const asg = await assign(s, a.token, test.id, { group_id: a.groupId, due_at: due(s) });
    await s.call('POST', `/v1/me/teacher-tests/${asg.data.id}/start`, { token: st.token });
    expect((await s.call('DELETE', `/v1/teacher/tests/${test.id}`, { token: a.token })).status).toBe(204);
    const left = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM teacher_test_attempts WHERE assignment_id = ?1')
      .bind(asg.data.id)
      .first<{ n: number }>();
    expect(left!.n).toBe(0);
    expect((await s.call('GET', `/v1/me/teacher-tests/${asg.data.id}`, { token: st.token })).status).toBe(404);
  });

  it('limit: ustozga 200 test (429 limit_tests)', async () => {
    const s = makeServer();
    const t = await proTeacher(s);
    const now = s.clock.now;
    await s.env.DB.batch(
      Array.from({ length: TT_LIMITS.testsPerTeacher }, (_, i) =>
        s.env.DB.prepare(
          `INSERT INTO teacher_tests (id, owner_id, title, questions, question_count, status, created_at, updated_at)
           VALUES (?1, ?2, ?3, '[]', 0, 'unpublished', ?4, ?4)`,
        ).bind(crypto.randomUUID(), t.userId, `Test ${i}`, now),
      ),
    );
    const r = await s.call('POST', '/v1/teacher/tests', { token: t.token, body: testBody() });
    expect(r.status).toBe(429);
    expect(r.data.error).toBe('limit_tests');
  });
});

describe('topshirish: guruh yoki bitta talaba, muddat, urinishlar', () => {
  it('tekshiruv: nashr etilmagan — 409; muddat, urinish, siyosat; a’zo bo‘lmagan talaba — 404', async () => {
    const s = makeServer();
    const t = await proTeacher(s);
    const st = await student(s, t.code);
    const hidden = await createTest(s, t.token, { status: 'unpublished' });
    expect((await assign(s, t.token, hidden.id, { group_id: t.groupId, due_at: due(s) })).data.error).toBe(
      'not_published',
    );
    const test = await createTest(s, t.token);
    const bad = async (body: Record<string, unknown>, code: string, status = 400) => {
      const r = await assign(s, t.token, test.id, { group_id: t.groupId, due_at: due(s), ...body });
      expect(r.status, code).toBe(status);
      expect(r.data.error).toBe(code);
    };
    await bad({ due_at: null }, 'invalid_due');
    await bad({ due_at: new Date(s.clock.now - MIN).toISOString() }, 'invalid_due');
    await bad({ due_at: new Date(s.clock.now + 400 * DAY).toISOString() }, 'invalid_due');
    await bad({ max_attempts: 0 }, 'invalid_attempts');
    await bad({ max_attempts: 6 }, 'invalid_attempts');
    await bad({ late_policy: 'maybe' }, 'invalid_late_policy');
    await bad({ group_id: 42 }, 'invalid_group');
    const outsider = await s.signIn(uniqueEmail('out'));
    await bad({ user_id: outsider.userId }, 'member_not_found', 404);
    await bad({ user_id: t.userId }, 'member_not_found', 404); // ustozning o'zi talaba emas
    const ok = await assign(s, t.token, test.id, { group_id: t.groupId, user_id: st.userId, due_at: due(s), max_attempts: 2 });
    expect(ok.status).toBe(201);
    expect(ok.data).toMatchObject({ user_id: st.userId, max_attempts: 2, late_policy: 'reject', status: 'active' });
    const list = await s.call('GET', `/v1/teacher/assignments?test_id=${test.id}`, { token: t.token });
    expect(list.data).toHaveLength(1);
    expect(list.data[0]).toMatchObject({ target_count: 1, submitted_count: 0, group_name: 'Lab-21 guruhi' });
  });

  it('hayot sikli: assigned → started (qayta ochiladi) → submitted; kalit talabaga berilmaydi; bitta urinish', async () => {
    const { s, t, st, a } = await setup();
    const list = await s.call('GET', '/v1/me/teacher-tests', { token: st.token });
    expect(list.status).toBe(200);
    expect(list.data).toHaveLength(1);
    expect(list.data[0]).toMatchObject({
      id: a.id,
      state: 'assigned',
      can_start: true,
      attempts_used: 0,
      group_name: 'Lab-21 guruhi',
      visible_to_teacher: true,
    });
    const start = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    expect(start.status).toBe(201);
    expect(start.data.resumed).toBe(false);
    expect(start.data.questions).toHaveLength(3);
    expect(start.text).not.toContain('"correct"');
    expect(start.text).not.toContain('izoh');
    expect(start.data.time_up_at).toBe(new Date(s.clock.now + 10 * MIN).toISOString());
    s.clock.now += MIN;
    const again = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    expect(again.status).toBe(200);
    expect(again.data).toMatchObject({ attempt_id: start.data.attempt_id, resumed: true });
    expect((await s.call('GET', '/v1/me/teacher-tests', { token: st.token })).data[0].state).toBe('started');

    const bad = await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: st.token,
      body: { attempt_id: start.data.attempt_id, answers: [0, 1] },
    });
    expect(bad.data.error).toBe('invalid_answers');
    expect(
      (
        await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
          token: st.token,
          body: { attempt_id: start.data.attempt_id, answers: [0, 1, 3] },
        })
      ).data.error,
    ).toBe('invalid_answers');
    const sub = await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: st.token,
      body: { attempt_id: start.data.attempt_id, answers: [0, 1, -1] },
    });
    expect(sub.status).toBe(201);
    expect(sub.data).toMatchObject({ score: 2, total: 3, percent: 67, passed: true, late: false, seconds: 60 });
    // Urinish qolmadi — to'g'ri javob va izoh ochiladi.
    expect(sub.data.review[2]).toMatchObject({ answer: -1, correct: 2, explanation: 'Trombotsit: izoh' });
    const twice = await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: st.token,
      body: { attempt_id: start.data.attempt_id, answers: [0, 1, 2] },
    });
    expect(twice.data.error).toBe('already_submitted');
    const more = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    expect(more.status).toBe(409);
    expect(more.data.error).toBe('no_attempts_left');
    const mine = await s.call('GET', `/v1/me/teacher-tests/${a.id}`, { token: st.token });
    expect(mine.data).toMatchObject({ state: 'submitted', can_start: false, best_percent: 67, passed: true });
    expect(mine.data.attempts).toHaveLength(1);
    // Ustoz natijani ko'radi.
    const res = await s.call('GET', `/v1/teacher/assignments/${a.id}/results`, { token: t.token });
    expect(res.data.summary).toMatchObject({ targets: 1, started: 1, submitted: 1, average_percent: 67, pass_rate: 100 });
    expect(res.data.students[0]).toMatchObject({ user_id: st.userId, state: 'submitted', best_score: 2, label: 'Talaba 01' });
  });

  it('bir nechta urinish: kalit urinish qolguncha yopiq; eng yaxshi ball hisoblanadi', async () => {
    const { s, t, st, a } = await setup({}, { max_attempts: 2 });
    const run = async (answers: number[]) => {
      const st1 = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
      expect(st1.status).toBe(201);
      return s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
        token: st.token,
        body: { attempt_id: st1.data.attempt_id, answers },
      });
    };
    const first = await run([0, 1, 2]);
    expect(first.data.score).toBe(3);
    expect(first.data.review).toBeNull(); // yana urinish bor
    const second = await run([1, 1, 1]);
    expect(second.data.score).toBe(1);
    expect(second.data.attempt_no).toBe(2);
    expect(second.data.review).toHaveLength(3);
    const res = await s.call('GET', `/v1/teacher/assignments/${a.id}/results`, { token: t.token });
    expect(res.data.students[0]).toMatchObject({ attempts: 2, best_score: 3, last_score: 1, best_percent: 100 });
    // Savol kesimi — oxirgi urinish bo'yicha; eng ko'p xato qilingani birinchi.
    expect(res.data.questions.map((x: { right: number }) => x.right)).toEqual([0, 1, 0]);
    expect(res.data.most_missed.slice(0, 2)).toEqual([0, 2]);
    expect(res.data.questions[0].chosen).toEqual([0, 1, 0]);
  });

  it('Talaba Pro: obunasiz ro‘yxat ko‘rinadi, YANGI urinish — 403; boshlangan urinish obuna tugasa ham davom etadi va topshiriladi', async () => {
    const s = makeServer();
    const t = await proTeacher(s);
    const free = await student(s, t.code, null);
    const test = await createTest(s, t.token, { time_limit_minutes: null });
    const a = (await assign(s, t.token, test.id, { group_id: t.groupId, due_at: due(s, 10) })).data;
    expect((await s.call('GET', '/v1/me/teacher-tests', { token: free.token })).data[0].state).toBe('assigned');
    const r = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: free.token });
    expect(r.status).toBe(403);
    expect(r.data).toMatchObject({ error: 'plan_required', capability: 'learner' });
    // Talaba sinovi (7 kun) — ochiq; o'rtada tugaydi.
    await trial(s, free.userId, 'student', 1);
    const st = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: free.token });
    expect(st.status).toBe(201);
    s.clock.now += 2 * DAY;
    const resumed = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: free.token });
    expect(resumed.status).toBe(200);
    expect(resumed.data.resumed).toBe(true);
    const sub = await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: free.token,
      body: { attempt_id: st.data.attempt_id, answers: [0, 0, 0] },
    });
    expect(sub.status).toBe(201);
    expect(sub.data.score).toBe(1);
    // Natija keyin ham ko'rinadi.
    expect((await s.call('GET', `/v1/me/teacher-tests/${a.id}`, { token: free.token })).data.attempts[0].score).toBe(1);
  });

  it('muddat: reject — muddatdan keyin boshlash yo‘q (past_due, expired); accept — qabul, “kechikkan”', async () => {
    const s = makeServer();
    const t = await proTeacher(s);
    const st = await student(s, t.code);
    const test = await createTest(s, t.token, { time_limit_minutes: null });
    const strict = (await assign(s, t.token, test.id, { group_id: t.groupId, due_at: due(s, 1) })).data;
    const lenient = (
      await assign(s, t.token, test.id, { group_id: t.groupId, due_at: due(s, 1), late_policy: 'accept' })
    ).data;
    // Muddatdan oldin boshlangan (reject) — muddat bilan cheklangan.
    const early = await s.call('POST', `/v1/me/teacher-tests/${strict.id}/start`, { token: st.token });
    expect(early.data.time_up_at).toBe(strict.due_at);
    s.clock.now += DAY + MIN; // muddat o'tdi, tarmoq vaqti ichida
    const inGrace = await s.call('POST', `/v1/me/teacher-tests/${strict.id}/submit`, {
      token: st.token,
      body: { attempt_id: early.data.attempt_id, answers: [0, 1, 2] },
    });
    expect(inGrace.status).toBe(201);
    expect(inGrace.data.late).toBe(false);
    s.clock.now += 10 * MIN;
    const list = await s.call('GET', '/v1/me/teacher-tests', { token: st.token });
    const byId = Object.fromEntries(list.data.map((x: { id: string }) => [x.id, x]));
    expect(byId[strict.id].state).toBe('submitted');
    expect(byId[lenient.id]).toMatchObject({ state: 'assigned', can_start: true });
    const late = await s.call('POST', `/v1/me/teacher-tests/${lenient.id}/start`, { token: st.token });
    expect(late.status).toBe(201);
    expect(late.data.time_up_at).toBeNull();
    const sub = await s.call('POST', `/v1/me/teacher-tests/${lenient.id}/submit`, {
      token: st.token,
      body: { attempt_id: late.data.attempt_id, answers: [0, 0, 0] },
    });
    expect(sub.data.late).toBe(true);
    const res = await s.call('GET', `/v1/teacher/assignments/${lenient.id}/results`, { token: t.token });
    expect(res.data.students[0].late).toBe(true);

    // Boshlanmagan reject topshiriq muddatdan keyin — expired.
    const other = await student(s, t.code);
    const exp = await s.call('POST', `/v1/me/teacher-tests/${strict.id}/start`, { token: other.token });
    expect(exp.status).toBe(409);
    expect(exp.data.error).toBe('past_due');
    expect((await s.call('GET', `/v1/me/teacher-tests/${strict.id}`, { token: other.token })).data.state).toBe('expired');
  });

  it('vaqt chegarasi: 2 daqiqa tarmoq vaqti ichida qabul; keyin time_over va urinish expired; kunlik tozalash', async () => {
    const { s, st, a } = await setup({ time_limit_minutes: 5 }, { max_attempts: 3 });
    const one = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    s.clock.now += 5 * MIN + TT_GRACE_MS - 1000;
    const ok = await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: st.token,
      body: { attempt_id: one.data.attempt_id, answers: [0, 1, 2] },
    });
    expect(ok.status).toBe(201);
    const two = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    s.clock.now += 5 * MIN + TT_GRACE_MS + 1000;
    const over = await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: st.token,
      body: { attempt_id: two.data.attempt_id, answers: [0, 1, 2] },
    });
    expect(over.status).toBe(409);
    expect(over.data.error).toBe('time_over');
    const row = await s.env.DB.prepare('SELECT status FROM teacher_test_attempts WHERE id = ?1')
      .bind(two.data.attempt_id)
      .first<{ status: string }>();
    expect(row!.status).toBe('expired');
    // Uchinchi urinish boshlanib, tashlab ketildi — kunlik tozalash `expired` qiladi.
    const three = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    expect(three.data.attempt_no).toBe(3);
    s.clock.now += 10 * MIN;
    await s.app.scheduled(s.env);
    const row3 = await s.env.DB.prepare('SELECT status FROM teacher_test_attempts WHERE id = ?1')
      .bind(three.data.attempt_id)
      .first<{ status: string }>();
    expect(row3!.status).toBe('expired');
    const mine = await s.call('GET', `/v1/me/teacher-tests/${a.id}`, { token: st.token });
    expect(mine.data).toMatchObject({ state: 'submitted', attempts_used: 3, can_start: false });
  });

  it('ustoz yopdi: yangi boshlash yo‘q; yopilishdan oldin boshlaganga 2 daqiqa', async () => {
    const { s, t, st, a } = await setup({ time_limit_minutes: null });
    const other = await student(s, t.code);
    const started = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    const closed = await s.call('POST', `/v1/teacher/assignments/${a.id}/close`, { token: t.token });
    expect(closed.data.status).toBe('closed');
    const r = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: other.token });
    expect(r.data.error).toBe('closed');
    s.clock.now += MIN;
    const sub = await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: st.token,
      body: { attempt_id: started.data.attempt_id, answers: [0, 1, 2] },
    });
    expect(sub.status).toBe(201);
    expect((await s.call('GET', `/v1/me/teacher-tests/${a.id}`, { token: other.token })).data.state).toBe('expired');
    // O'chirish — natijalar bilan.
    expect((await s.call('DELETE', `/v1/teacher/assignments/${a.id}`, { token: t.token })).status).toBe(204);
    expect((await s.call('GET', `/v1/me/teacher-tests/${a.id}`, { token: st.token })).status).toBe(404);
  });
});

describe('maxfiylik: kim nimani ko‘radi', () => {
  it('a’zo bo‘lmagan — 404; shaxsiy topshiriq faqat egasiga; boshqa talabaning urinishi ko‘rinmaydi', async () => {
    const s = makeServer();
    const t = await proTeacher(s);
    const st1 = await student(s, t.code);
    const st2 = await student(s, t.code);
    const outsider = await s.signIn(uniqueEmail('outsider'));
    await buy(s, outsider.userId, 'premium');
    const test = await createTest(s, t.token);
    const solo = (await assign(s, t.token, test.id, { group_id: t.groupId, user_id: st1.userId, due_at: due(s) })).data;
    expect((await s.call('GET', '/v1/me/teacher-tests', { token: st2.token })).data).toEqual([]);
    for (const u of [st2, outsider]) {
      expect((await s.call('GET', `/v1/me/teacher-tests/${solo.id}`, { token: u.token })).status).toBe(404);
      expect((await s.call('POST', `/v1/me/teacher-tests/${solo.id}/start`, { token: u.token })).status).toBe(404);
    }
    const start = await s.call('POST', `/v1/me/teacher-tests/${solo.id}/start`, { token: st1.token });
    // Boshqa talaba birovning urinishini topshira olmaydi.
    const steal = await s.call('POST', `/v1/me/teacher-tests/${solo.id}/submit`, {
      token: st2.token,
      body: { attempt_id: start.data.attempt_id, answers: [0, 0, 0] },
    });
    expect(steal.status).toBe(404);
    // Talaba natijalar yo'liga kira olmaydi.
    expect((await s.call('GET', `/v1/teacher/assignments/${solo.id}/results`, { token: st1.token })).status).toBe(403);
    const otherTeacher = await proTeacher(s);
    expect((await s.call('GET', `/v1/teacher/assignments/${solo.id}/results`, { token: otherTeacher.token })).status).toBe(
      404,
    );
  });

  it('talaba guruhdan chiqsa yoki chiqarilsa — urinishlari o‘chadi va ustozga ko‘rinmaydi', async () => {
    const { s, t, st, a } = await setup();
    const st2 = await student(s, t.code, 'student', 'Malika');
    for (const u of [st, st2]) {
      const r = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: u.token });
      await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
        token: u.token,
        body: { attempt_id: r.data.attempt_id, answers: [0, 1, 2] },
      });
    }
    let res = await s.call('GET', `/v1/teacher/assignments/${a.id}/results`, { token: t.token });
    expect(res.data.summary.submitted).toBe(2);
    expect(res.data.students.map((x: { label: string }) => x.label)).toEqual(['Talaba 01', 'Malika']);
    expect((await s.call('POST', `/v1/groups/${t.groupId}/leave`, { token: st.token })).status).toBe(204);
    expect((await s.call('DELETE', `/v1/groups/${t.groupId}/members/${st2.userId}`, { token: t.token })).status).toBe(204);
    res = await s.call('GET', `/v1/teacher/assignments/${a.id}/results`, { token: t.token });
    expect(res.data.summary).toMatchObject({ targets: 0, submitted: 0 });
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM teacher_test_attempts WHERE assignment_id = ?1')
      .bind(a.id)
      .first<{ n: number }>();
    expect(n!.n).toBe(0);
    expect((await s.call('GET', '/v1/me/teacher-tests', { token: st.token })).data).toEqual([]);
    // Qayta qo'shilsa — toza holat (eski natija qaytmaydi).
    await s.call('POST', '/v1/groups/join', { token: st.token, body: { code: t.code } });
    expect((await s.call('GET', `/v1/me/teacher-tests/${a.id}`, { token: st.token })).data).toMatchObject({
      state: 'assigned',
      attempts_used: 0,
    });
  });
});

describe('taklifnoma: aniq rozilik bilan biriktirish', () => {
  async function inviteSetup() {
    const s = makeServer();
    const t = await proTeacher(s);
    const inv = await s.call('POST', `/v1/teacher/groups/${t.groupId}/invites`, {
      token: t.token,
      body: { max_uses: 2, days: 3 },
    });
    expect(inv.status).toBe(201);
    return { s, t, inv: inv.data };
  }

  it('yaratish faqat Ustoz Pro va o‘z guruhi; kod 12 belgi, ro‘yxatda qayta ko‘rinadi; bekor qilish', async () => {
    const { s, t, inv } = await inviteSetup();
    expect(inv.token).toMatch(/^[A-HJ-NP-Z2-9]{12}$/);
    expect(inv).toMatchObject({ max_uses: 2, uses: 0, active: true });
    const raw = await s.env.DB.prepare('SELECT token_hash, token_enc FROM teacher_invites WHERE id = ?1')
      .bind(inv.id)
      .first<{ token_hash: string; token_enc: string }>();
    expect(raw!.token_hash).not.toContain(inv.token);
    expect(raw!.token_enc).not.toContain(inv.token);
    const list = await s.call('GET', `/v1/teacher/groups/${t.groupId}/invites`, { token: t.token });
    expect(list.data.map((x: { token: string }) => x.token)).toEqual([inv.token]);
    const free = await s.signInTeacher(uniqueEmail('free-inv'));
    const g = await s.call('POST', '/v1/groups', { token: free.token, body: { name: 'Bepul guruh' } });
    expect(
      (await s.call('POST', `/v1/teacher/groups/${g.data.id}/invites`, { token: free.token, body: {} })).data.error,
    ).toBe('plan_required');
    const other = await proTeacher(s);
    expect((await s.call('POST', `/v1/teacher/groups/${t.groupId}/invites`, { token: other.token, body: {} })).status).toBe(
      404,
    );
    expect((await s.call('DELETE', `/v1/teacher/invites/${inv.id}`, { token: other.token })).status).toBe(404);
    expect(
      (await s.call('POST', `/v1/teacher/groups/${t.groupId}/invites`, { token: t.token, body: { max_uses: 0 } })).data
        .error,
    ).toBe('invalid_max_uses');
    expect(
      (await s.call('POST', `/v1/teacher/groups/${t.groupId}/invites`, { token: t.token, body: { days: 31 } })).data.error,
    ).toBe('invalid_days');
    expect((await s.call('DELETE', `/v1/teacher/invites/${inv.id}`, { token: t.token })).status).toBe(204);
    const u = await s.signIn(uniqueEmail('late'));
    expect((await s.call('GET', `/v1/teacher-invites/${inv.token}`, { token: u.token })).status).toBe(410);
  });

  it('talaba: oldin ko‘radi (hech narsa yozilmaydi), roziliksiz qo‘shilmaydi, rozilik bilan — a’zo; foydalanish soni cheklangan', async () => {
    const { s, t, inv } = await inviteSetup();
    const u = await s.signIn(uniqueEmail('inv-st'));
    expect((await s.call('GET', `/v1/teacher-invites/${inv.token}`)).status).toBe(401);
    const pre = await s.call('GET', `/v1/teacher-invites/${inv.token.slice(0, 4)}-${inv.token.slice(4, 8)}-${inv.token.slice(8)}`, {
      token: u.token,
    });
    expect(pre.status).toBe(200);
    expect(pre.data).toMatchObject({ group_name: 'Lab-21 guruhi', already_member: false, own_group: false });
    expect(pre.data.shares).toContain('teacher_test_results');
    expect((await s.call('GET', `/v1/teacher-invites/${inv.token}`, { token: t.token })).data.own_group).toBe(true);
    expect((await s.call('GET', '/v1/groups', { token: u.token })).data).toEqual([]);
    const no = await s.call('POST', `/v1/teacher-invites/${inv.token}/accept`, { token: u.token, body: {} });
    expect(no.status).toBe(400);
    expect(no.data.error).toBe('consent_required');
    const yes = await s.call('POST', `/v1/teacher-invites/${inv.token}/accept`, {
      token: u.token,
      body: { consent: true, display_name: 'Aziz' },
    });
    expect(yes.status).toBe(201);
    expect(yes.data.group_id).toBe(t.groupId);
    const members = await s.call('GET', `/v1/groups/${t.groupId}/members`, { token: t.token });
    expect(members.data.map((m: { display_name: string | null }) => m.display_name)).toContain('Aziz');
    // Qayta — foydalanish sanalmaydi.
    const again = await s.call('POST', `/v1/teacher-invites/${inv.token}/accept`, { token: u.token, body: { consent: true } });
    expect(again.data.already_member).toBe(true);
    const u2 = await s.signIn(uniqueEmail('inv-2'));
    expect(
      (await s.call('POST', `/v1/teacher-invites/${inv.token}/accept`, { token: u2.token, body: { consent: true } })).status,
    ).toBe(201);
    const u3 = await s.signIn(uniqueEmail('inv-3'));
    const full = await s.call('POST', `/v1/teacher-invites/${inv.token}/accept`, { token: u3.token, body: { consent: true } });
    expect(full.status).toBe(410);
    expect(full.data.error).toBe('invite_expired');
    // Noto'g'ri kod — 404.
    expect((await s.call('GET', '/v1/teacher-invites/ABCDEFGHJKL0', { token: u3.token })).status).toBe(404);
    expect((await s.call('GET', '/v1/teacher-invites/AAAAAAAAAAAA', { token: u3.token })).status).toBe(404);
  });

  it('muddati o‘tgan — 410; ustoz o‘zi — 409; taxallus band — 409 (foydalanish qaytariladi); limit (429)', async () => {
    const { s, t, inv } = await inviteSetup();
    expect(
      (await s.call('POST', `/v1/teacher-invites/${inv.token}/accept`, { token: t.token, body: { consent: true } })).data
        .error,
    ).toBe('own_group');
    await student(s, t.code, null, 'Sardor');
    const u = await s.signIn(uniqueEmail('dup'));
    const dup = await s.call('POST', `/v1/teacher-invites/${inv.token}/accept`, {
      token: u.token,
      body: { consent: true, display_name: 'sardor' },
    });
    expect(dup.data.error).toBe('nickname_taken');
    const uses = await s.env.DB.prepare('SELECT uses FROM teacher_invites WHERE id = ?1').bind(inv.id).first<{ uses: number }>();
    expect(uses!.uses).toBe(0);
    s.clock.now += 3 * DAY + MIN;
    expect((await s.call('GET', `/v1/teacher-invites/${inv.token}`, { token: u.token })).status).toBe(410);
    const spam = await s.signIn(uniqueEmail('spam'));
    let last = 0;
    for (let i = 0; i < 21; i++) last = (await s.call('GET', '/v1/teacher-invites/ABCDEFGHJKLM', { token: spam.token })).status;
    expect(last).toBe(429);
  });
});

describe('natijalar: jamlanma va CSV', () => {
  it('CSV: Ustoz Pro; emailsiz; formula in’ektsiyasidan himoya; obuna tugasa — eksport 403, ko‘rish 200', async () => {
    const { s, t, st, a } = await setup();
    const r = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    await s.call('POST', `/v1/me/teacher-tests/${a.id}/submit`, {
      token: st.token,
      body: { attempt_id: r.data.attempt_id, answers: [0, 1, 2] },
    });
    const ex = await s.call('GET', `/v1/teacher/assignments/${a.id}/export`, { token: t.token });
    expect(ex.status).toBe(200);
    expect(ex.data.filename).toMatch(/^labguide-results-[0-9a-f]{8}\.csv$/);
    const lines = (ex.data.csv as string).split('\r\n');
    expect(lines[0]).toBe('student,state,attempts,best_score,total,best_percent,passed,seconds,late,submitted_at');
    expect(lines[1]).toMatch(/^Talaba 01,submitted,1,3,3,100,yes,0,no,/);
    expect(ex.data.csv).not.toContain('@example.test');
    expect(ex.data.csv).toContain('question,text,answered,correct,correct_percent');
    expect(csvCell('=HYPERLINK("x")')).toBe(`"'=HYPERLINK(""x"")"`);
    expect(csvCell('+1')).toBe("'+1");
    expect(csvCell('a,b')).toBe('"a,b"');
    expect(csvCell(null)).toBe('');
    const audit = await s.env.DB.prepare(`SELECT COUNT(*) AS n FROM audit_log WHERE action = 'teacher_results_exported' AND target = ?1`)
      .bind(a.id)
      .first<{ n: number }>();
    expect(audit!.n).toBe(1);
    s.clock.now += 31 * DAY; // obuna tugadi
    expect((await s.call('GET', `/v1/teacher/assignments/${a.id}/export`, { token: t.token })).status).toBe(403);
    const view = await s.call('GET', `/v1/teacher/assignments/${a.id}/results`, { token: t.token });
    expect(view.status).toBe(200);
    expect(view.data.students[0].best_score).toBe(3);
  });
});

describe('o‘chirish kaskadi va bepul guruhlar regressiyasi', () => {
  it('talaba hisobini o‘chirsa — urinishlari; ustoz o‘chirsa — testlar, topshiriqlar, taklifnomalar', async () => {
    const { s, t, st, test, a } = await setup();
    const r = await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    expect(r.status).toBe(201);
    await s.call('POST', `/v1/teacher/groups/${t.groupId}/invites`, { token: t.token, body: {} });
    expect((await s.call('DELETE', '/v1/me', { token: st.token })).status).toBe(204);
    const count = async (table: string, col: string, v: string) =>
      (await s.env.DB.prepare(`SELECT COUNT(*) AS n FROM ${table} WHERE ${col} = ?1`).bind(v).first<{ n: number }>())!.n;
    expect(await count('teacher_test_attempts', 'user_id', st.userId)).toBe(0);
    expect(await count('teacher_test_assignments', 'id', a.id)).toBe(1);
    expect((await s.call('DELETE', '/v1/me', { token: t.token })).status).toBe(204);
    expect(await count('teacher_tests', 'owner_id', t.userId)).toBe(0);
    expect(await count('teacher_test_assignments', 'test_id', test.id)).toBe(0);
    expect(await count('teacher_invites', 'owner_id', t.userId)).toBe(0);
  });

  it('bepul guruhni o‘chirish — uning Ustoz testi topshiriqlari va urinishlari ham o‘chadi', async () => {
    const { s, t, st, a } = await setup();
    await s.call('POST', `/v1/me/teacher-tests/${a.id}/start`, { token: st.token });
    expect((await s.call('DELETE', `/v1/groups/${t.groupId}`, { token: t.token })).status).toBe(204);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM teacher_test_assignments WHERE id = ?1')
      .bind(a.id)
      .first<{ n: number }>();
    expect(n!.n).toBe(0);
    const m = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM teacher_test_attempts WHERE assignment_id = ?1')
      .bind(a.id)
      .first<{ n: number }>();
    expect(m!.n).toBe(0);
  });

  it('bayroq yoqilgan, obunasiz: bepul guruh, kod bilan qo‘shilish, bepul topshiriq va natija avvalgidek ishlaydi', async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('free-t'));
    const g = await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Bepul guruh' } });
    expect(g.status).toBe(201);
    const u = await s.signIn(uniqueEmail('free-s'));
    expect((await s.call('POST', '/v1/groups/join', { token: u.token, body: { code: g.data.join_code } })).status).toBe(201);
    const a = await s.call('POST', `/v1/groups/${g.data.id}/assignments`, {
      token: t.token,
      body: { title: 'Mavzu testi', question_ids: ['q1', 'q2'], correct_indexes: [0, 1] },
    });
    expect(a.status).toBe(201);
    expect((await s.call('POST', `/v1/assignments/${a.data.id}/start`, { token: u.token })).status).toBe(200);
    const sub = await s.call('POST', `/v1/assignments/${a.data.id}/submit`, { token: u.token, body: { answers: [0, 0] } });
    expect(sub.status).toBe(201);
    expect(sub.data.score).toBe(1);
    expect((await s.call('POST', `/v1/groups/${g.data.id}/leave`, { token: u.token })).status).toBe(204);
    expect((await s.call('GET', '/v1/groups', { token: u.token })).data).toEqual([]);
  });
});
