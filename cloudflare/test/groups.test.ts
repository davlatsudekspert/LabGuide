import { describe, expect, it } from 'vitest';
import { makeServer, uniqueEmail } from './helpers';

async function classroom() {
  const s = makeServer();
  const tA = await s.signIn(uniqueEmail('ta'), { role: 'teacher' });
  const tB = await s.signIn(uniqueEmail('tb'), { role: 'teacher' });
  const gA = (await s.call('POST', '/v1/groups', { token: tA.token, body: { name: 'Gematologiya 1' } })).data;
  const gB = (await s.call('POST', '/v1/groups', { token: tB.token, body: { name: 'Biokimyo 2' } })).data;
  const s1 = await s.signIn(uniqueEmail('s1'));
  const s2 = await s.signIn(uniqueEmail('s2'));
  const s3 = await s.signIn(uniqueEmail('s3'));
  const outsider = await s.signIn(uniqueEmail('out'));
  expect((await s.call('POST', '/v1/groups/join', { token: s1.token, body: { code: gA.join_code } })).status).toBe(201);
  expect((await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: gA.join_code.toLowerCase(), display_name: 'Lola' } })).status).toBe(201);
  expect((await s.call('POST', '/v1/groups/join', { token: s3.token, body: { code: gB.join_code } })).status).toBe(201);
  const asg = await s.call('POST', `/v1/groups/${gA.id}/assignments`, {
    token: tA.token,
    body: { title: 'Kun 3 testi', day_id: 'day-03', question_ids: ['q1', 'q2', 'q3'], correct_indexes: [1, 0, 2], time_limit_minutes: 10 },
  });
  expect(asg.status).toBe(201);
  return { s, tA, tB, gA, gB, s1, s2, s3, outsider, aid: asg.data.id as string };
}

describe('guruh va a\'zolik', () => {
  it("kod 8 belgi, adashtiradigan belgilarsiz; ro'yxatda kod faqat ustozga", async () => {
    const { s, tA, s1, gA } = await classroom();
    expect(gA.join_code).toMatch(/^[A-HJ-NP-Z2-9]{8}$/);
    const tg = (await s.call('GET', '/v1/groups', { token: tA.token })).data;
    expect(tg[0]).toMatchObject({ id: gA.id, is_teacher: true, join_code: gA.join_code, member_count: 3 });
    const sg = (await s.call('GET', '/v1/groups', { token: s1.token })).data;
    expect(sg[0]).toMatchObject({ id: gA.id, is_teacher: false, join_code: null, my_display_name: 'Talaba 01' });
  });

  it("a'zo ismi: taxallus yoki 'Talaba NN'; email/havola taxallus bo'lolmaydi", async () => {
    const { s, tA, gA, outsider } = await classroom();
    const m = (await s.call('GET', `/v1/groups/${gA.id}/members`, { token: tA.token })).data;
    expect(m.map((x: any) => x.display_name)).toEqual(['Ustoz', 'Talaba 01', 'Lola']);
    expect(JSON.stringify(m)).not.toContain('@');
    for (const bad of ['a@b.uz', 'http://x.uz', '<script>', 'x', 'a'.repeat(31)]) {
      const r = await s.call('POST', '/v1/groups/join', { token: outsider.token, body: { code: gA.join_code, display_name: bad } });
      expect(r.status, bad).toBe(400);
    }
  });

  it("talaba a'zolar ro'yxatida faqat ustozni va o'zini ko'radi", async () => {
    const { s, gA, s1, s2 } = await classroom();
    const m = (await s.call('GET', `/v1/groups/${gA.id}/members`, { token: s1.token })).data;
    expect(m.map((x: any) => x.user_id)).not.toContain(s2.userId);
    expect(m).toHaveLength(2);
  });

  it("noto'g'ri kod — 404; kodni taxmin qilish limiti — 429", async () => {
    const { s, outsider } = await classroom();
    let last = 0;
    for (let i = 0; i < 11; i++) {
      last = (await s.call('POST', '/v1/groups/join', { token: outsider.token, body: { code: 'ZZZZZZZZ' } })).status;
      if (i < 10) expect(last).toBe(404);
    }
    expect(last).toBe(429);
  });

  it('ustoz guruhdan chiqa olmaydi; talaba chiqsa kirish yopiladi', async () => {
    const { s, tA, gA, s1 } = await classroom();
    expect((await s.call('POST', `/v1/groups/${gA.id}/leave`, { token: tA.token })).status).toBe(400);
    expect((await s.call('POST', `/v1/groups/${gA.id}/leave`, { token: s1.token })).status).toBe(204);
    expect((await s.call('GET', `/v1/groups/${gA.id}/assignments`, { token: s1.token })).status).toBe(404);
  });

  it('ustoz kodni yangilaydi — eski kod ishlamaydi', async () => {
    const { s, tA, gA, outsider } = await classroom();
    const r = await s.call('POST', `/v1/groups/${gA.id}/code`, { token: tA.token });
    expect(r.data.join_code).not.toBe(gA.join_code);
    expect((await s.call('POST', '/v1/groups/join', { token: outsider.token, body: { code: gA.join_code } })).status).toBe(404);
    expect((await s.call('POST', '/v1/groups/join', { token: outsider.token, body: { code: r.data.join_code } })).status).toBe(201);
  });
});

describe('avtorizatsiya: boshqa ustoz guruhi', () => {
  it("boshqa ustoz guruhini o'qiy olmaydi (404 — borligi ham bilinmaydi)", async () => {
    const { s, tB, gA, aid } = await classroom();
    for (const path of [
      `/v1/groups/${gA.id}/members`,
      `/v1/groups/${gA.id}/assignments`,
      `/v1/groups/${gA.id}/submissions`,
      `/v1/groups/${gA.id}/topics`,
      `/v1/groups/${gA.id}/marks`,
      `/v1/assignments/${aid}/submissions`,
      `/v1/assignments/${aid}/key`,
    ]) {
      expect((await s.call('GET', path, { token: tB.token })).status, path).toBe(404);
    }
  });

  it("boshqa ustoz guruhini o'zgartira olmaydi", async () => {
    const { s, tB, gA, s1, aid } = await classroom();
    const calls: [string, string, unknown?][] = [
      ['DELETE', `/v1/groups/${gA.id}`],
      ['POST', `/v1/groups/${gA.id}/code`],
      ['DELETE', `/v1/groups/${gA.id}/members/${s1.userId}`],
      ['PUT', `/v1/groups/${gA.id}/topics/day-01`],
      ['PUT', `/v1/groups/${gA.id}/marks`, { user_id: s1.userId, day_id: 'day-01', question_id: 'q1', result: 'correct' }],
      ['POST', `/v1/groups/${gA.id}/assignments`, { title: 'Hack', question_ids: ['q1'], correct_indexes: [0] }],
      ['POST', `/v1/assignments/${aid}/close`],
      ['POST', `/v1/assignments/${aid}/open`],
    ];
    for (const [m, p, body] of calls) {
      expect((await s.call(m, p, { token: tB.token, body })).status, `${m} ${p}`).toBe(404);
    }
  });

  it("boshqa guruh talabasiga belgi qo'yib bo'lmaydi", async () => {
    const { s, tA, gA, s3 } = await classroom();
    const r = await s.call('PUT', `/v1/groups/${gA.id}/marks`, {
      token: tA.token,
      body: { user_id: s3.userId, day_id: 'day-01', question_id: 'q1', result: 'correct' },
    });
    expect(r.status).toBe(404);
  });
});

describe('avtorizatsiya: talaba', () => {
  it("talaba ustoz amallarini bajara olmaydi (403)", async () => {
    const { s, gA, s1, s2, aid } = await classroom();
    const calls: [string, string, unknown?][] = [
      ['DELETE', `/v1/groups/${gA.id}`],
      ['POST', `/v1/groups/${gA.id}/code`],
      ['DELETE', `/v1/groups/${gA.id}/members/${s2.userId}`],
      ['PUT', `/v1/groups/${gA.id}/topics/day-01`],
      ['DELETE', `/v1/groups/${gA.id}/topics/day-01`],
      ['PUT', `/v1/groups/${gA.id}/marks`, { user_id: s1.userId, day_id: 'day-01', question_id: 'q1', result: 'correct', grade: 5 }],
      ['POST', `/v1/groups/${gA.id}/assignments`, { title: 'Hack', question_ids: ['q1'], correct_indexes: [0] }],
      ['POST', `/v1/assignments/${aid}/close`],
      ['GET', `/v1/assignments/${aid}/key`],
    ];
    for (const [m, p, body] of calls) {
      expect((await s.call(m, p, { token: s1.token, body })).status, `${m} ${p}`).toBe(403);
    }
  });

  it("talaba boshqa talaba javobini va belgisini ko'rmaydi", async () => {
    const { s, tA, gA, s1, s2, aid } = await classroom();
    for (const st of [s1, s2]) {
      await s.call('POST', `/v1/assignments/${aid}/start`, { token: st.token });
      expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: st.token, body: { answers: [1, 1, 2] } })).status).toBe(201);
      await s.call('PUT', `/v1/groups/${gA.id}/marks`, {
        token: tA.token,
        body: { user_id: st.userId, day_id: 'day-03', question_id: 'q9', result: 'partial', grade: 4 },
      });
    }
    const own = (await s.call('GET', `/v1/assignments/${aid}/submissions`, { token: s1.token })).data;
    expect(own).toHaveLength(1);
    expect(own[0]).toMatchObject({ user_id: s1.userId, score: 2, total: 3, correct: [true, false, true] });
    const ownG = (await s.call('GET', `/v1/groups/${gA.id}/submissions`, { token: s1.token })).data;
    expect(ownG.map((x: any) => x.user_id)).toEqual([s1.userId]);
    const marks = (await s.call('GET', `/v1/groups/${gA.id}/marks`, { token: s1.token })).data;
    expect(marks.map((x: any) => x.user_id)).toEqual([s1.userId]);
    // Ustoz hammasini ko'radi.
    expect((await s.call('GET', `/v1/assignments/${aid}/submissions`, { token: tA.token })).data).toHaveLength(2);
    expect((await s.call('GET', `/v1/groups/${gA.id}/marks?day_id=day-03`, { token: tA.token })).data).toHaveLength(2);
    expect((await s.call('GET', `/v1/assignments/${aid}/key`, { token: tA.token })).data.correct_indexes).toEqual([1, 0, 2]);
  });

  it("ro'yxatda topshiriq kaliti talabaga chiqmaydi", async () => {
    const { s, gA, s1 } = await classroom();
    const list = await s.call('GET', `/v1/groups/${gA.id}/assignments`, { token: s1.token });
    expect(list.text).not.toContain('correct_indexes');
  });

  it("chiqarilgan talaba guruh ma'lumotini ko'rmaydi; ustoz ustozni chiqara olmaydi", async () => {
    const { s, tA, gA, s1, aid } = await classroom();
    expect((await s.call('DELETE', `/v1/groups/${gA.id}/members/${tA.userId}`, { token: tA.token })).status).toBe(404);
    expect((await s.call('DELETE', `/v1/groups/${gA.id}/members/${s1.userId}`, { token: tA.token })).status).toBe(204);
    expect((await s.call('GET', `/v1/assignments/${aid}/submissions`, { token: s1.token })).status).toBe(404);
    expect((await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token })).status).toBe(404);
  });

  it("begona foydalanuvchi guruhni ko'rmaydi va topshira olmaydi", async () => {
    const { s, gA, outsider, aid } = await classroom();
    expect((await s.call('GET', `/v1/groups/${gA.id}/topics`, { token: outsider.token })).status).toBe(404);
    expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: outsider.token, body: { answers: [1, 0, 2] } })).status).toBe(404);
  });
});

describe('mavzular, belgilar, test sessiyasi', () => {
  it('ustoz mavzu ochadi/yopadi; talaba ochilganlarni ko\'radi', async () => {
    const { s, tA, gA, s1 } = await classroom();
    expect((await s.call('PUT', `/v1/groups/${gA.id}/topics/day-05`, { token: tA.token })).status).toBe(200);
    expect((await s.call('PUT', `/v1/groups/${gA.id}/topics/bad%20id!`, { token: tA.token })).status).toBe(400);
    let t = (await s.call('GET', `/v1/groups/${gA.id}/topics`, { token: s1.token })).data;
    expect(t).toMatchObject([{ day_id: 'day-05', open: true }]);
    expect((await s.call('DELETE', `/v1/groups/${gA.id}/topics/day-05`, { token: tA.token })).status).toBe(204);
    t = (await s.call('GET', `/v1/groups/${gA.id}/topics`, { token: s1.token })).data;
    expect(t[0].open).toBe(false);
  });

  it('belgi: baho ixtiyoriy (1–5), qayta qo\'yilsa yangilanadi', async () => {
    const { s, tA, gA, s1 } = await classroom();
    const body = { user_id: s1.userId, day_id: 'day-02', question_id: 'q1', result: 'correct' };
    const a = await s.call('PUT', `/v1/groups/${gA.id}/marks`, { token: tA.token, body });
    expect(a.status).toBe(200);
    expect(a.data.grade).toBeNull();
    const b = await s.call('PUT', `/v1/groups/${gA.id}/marks`, { token: tA.token, body: { ...body, result: 'partial', grade: 3 } });
    expect(b.data.id).toBe(a.data.id);
    expect((await s.call('PUT', `/v1/groups/${gA.id}/marks`, { token: tA.token, body: { ...body, grade: 6 } })).status).toBe(400);
    expect((await s.call('PUT', `/v1/groups/${gA.id}/marks`, { token: tA.token, body: { ...body, result: 'great' } })).status).toBe(400);
    expect((await s.call('DELETE', `/v1/groups/${gA.id}/marks/${a.data.id}`, { token: tA.token })).status).toBe(204);
  });

  it('qoralama sessiya talabaga ko\'rinmaydi; ustoz boshlaydi va yakunlaydi', async () => {
    const { s, tA, gA, s1 } = await classroom();
    const d = await s.call('POST', `/v1/groups/${gA.id}/assignments`, {
      token: tA.token,
      body: { title: 'Nazorat', question_ids: ['q1', 'q2'], correct_indexes: [0, 1], start: false },
    });
    expect(d.data.status).toBe('draft');
    const ids = (await s.call('GET', `/v1/groups/${gA.id}/assignments`, { token: s1.token })).data.map((x: any) => x.id);
    expect(ids).not.toContain(d.data.id);
    expect((await s.call('POST', `/v1/assignments/${d.data.id}/start`, { token: s1.token })).status).toBe(404);
    expect((await s.call('POST', `/v1/assignments/${d.data.id}/open`, { token: tA.token })).data.status).toBe('open');
    const st = await s.call('POST', `/v1/assignments/${d.data.id}/start`, { token: s1.token });
    expect(st.status).toBe(200);
    expect(st.data.server_now).toBeTruthy();
    expect((await s.call('POST', `/v1/assignments/${d.data.id}/close`, { token: tA.token })).data.status).toBe('closed');
    // Yakunlashdan oldin boshlagan talaba 2 daqiqa ichida topshira oladi.
    s.clock.now += 60_000;
    expect((await s.call('POST', `/v1/assignments/${d.data.id}/submit`, { token: s1.token, body: { answers: [0, 1] } })).status).toBe(201);
    // Yakunlangandan keyin yangi boshlash yo'q.
    const s2late = await s.signIn(uniqueEmail('late'));
    const code = (await s.call('GET', '/v1/groups', { token: tA.token })).data[0].join_code;
    await s.call('POST', '/v1/groups/join', { token: s2late.token, body: { code } });
    const late = await s.call('POST', `/v1/assignments/${d.data.id}/start`, { token: s2late.token });
    expect(late.status).toBe(409);
    expect(late.data.error).toBe('not_open');
  });

  it('vaqt chegarasi serverda; ikkinchi topshirish — 409', async () => {
    const { s, s1, s2, aid } = await classroom();
    // Boshlamasdan topshirish (vaqt chegarali) — rad.
    expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s1.token, body: { answers: [1, 0, 2] } })).data.error).toBe('time_over');
    const a = await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token });
    s.clock.now += 5 * 60_000;
    const again = await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token });
    expect(again.data.started_at).toBe(a.data.started_at);
    expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s1.token, body: { answers: [1, 0, 2] } })).data.score).toBe(3);
    expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s1.token, body: { answers: [1, 0, 2] } })).status).toBe(409);
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: s2.token });
    s.clock.now += 13 * 60_000; // 10 daq + 2 daq imtiyozdan oshdi
    const over = await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s2.token, body: { answers: [1, 0, 2] } });
    expect(over.status).toBe(409);
    expect(over.data.error).toBe('time_over');
  });

  it("javoblar soni va qiymati tekshiriladi", async () => {
    const { s, s1, aid } = await classroom();
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token });
    for (const answers of [[1, 0], [1, 0, 2, 3], [1, 0, 'x'], [1, 0, 99], 'abc', null]) {
      expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s1.token, body: { answers } })).status).toBe(400);
    }
  });

  it("topshiriq: o'tmishdagi muddat va noto'g'ri kalit qabul qilinmaydi", async () => {
    const { s, tA, gA } = await classroom();
    const bad = [
      { title: 'Test', question_ids: ['q1'], correct_indexes: [0], due_at: '2020-01-01T00:00:00Z' },
      { title: 'Test', question_ids: ['q1', 'q2'], correct_indexes: [0] },
      { title: 'Test', question_ids: ['q1'], correct_indexes: [-1] },
      { title: 'Te', question_ids: ['q1'], correct_indexes: [0] },
      { title: 'Test', question_ids: [], correct_indexes: [] },
      { title: 'Test', question_ids: ['q1'], correct_indexes: [0], time_limit_minutes: 0 },
    ];
    for (const body of bad) {
      expect((await s.call('POST', `/v1/groups/${gA.id}/assignments`, { token: tA.token, body })).status).toBe(400);
    }
  });

  it("ustoz faqat 10 ta guruh ochadi", async () => {
    const s = makeServer();
    const t = await s.signIn(uniqueEmail('many'), { role: 'teacher' });
    for (let i = 0; i < 10; i++) {
      expect((await s.call('POST', '/v1/groups', { token: t.token, body: { name: `Guruh ${i}` } })).status).toBe(201);
    }
    expect((await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Guruh 11' } })).status).toBe(429);
  });
});
