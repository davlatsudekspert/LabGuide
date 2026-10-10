// Ilova kontrakti (lib/core/backend/lab_backend.dart): har bir qoida
// test/unit/classroom_rules_test.dart (FakeLabBackend) va
// supabase/tests/30_teacher_topics.sql dagi tekshiruvlarga mos.
//
// Status → BackendFailure (CloudflareLabBackend): 400/409 → invalid,
// 401 → unauthorized, 403 → forbidden, 404 → notFound (ro'yxat o'qishda
// "a'zo emas" — bo'sh ro'yxat, ustoz amalida — forbidden), 429 → rateLimited.

import { describe, expect, it } from 'vitest';
import { totpAt } from '../src/crypto';
import { makeServer, uniqueEmail } from './helpers';

function unbase32(s: string): Uint8Array {
  const A = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  let bits = 0;
  let value = 0;
  const out: number[] = [];
  for (const c of s) {
    value = (value << 5) | A.indexOf(c);
    bits += 5;
    if (bits >= 8) {
      out.push((value >>> (bits - 8)) & 255);
      bits -= 8;
    }
  }
  return new Uint8Array(out);
}

type Server = ReturnType<typeof makeServer>;

/** Admin hisobi (allowlist + OTP + TOTP → aal2). */
async function adminAal2(s: Server, email: string) {
  const a = await s.signIn(email);
  const en = await s.call('POST', '/v1/auth/mfa/enroll', { token: a.token });
  expect(en.status).toBe(200);
  const code = await totpAt(unbase32(en.data.secret), Math.floor(s.clock.now / 30_000));
  expect((await s.call('POST', '/v1/auth/mfa/verify', { token: a.token, body: { code } })).status).toBe(200);
  expect((await s.call('GET', '/v1/me', { token: a.token })).data).toMatchObject({ admin: true, aal: 'aal2' });
  return a;
}

const enc = encodeURIComponent;

describe("ustoz sifatida ro'yxat (registerTeacher)", () => {
  it("faqat kod bilan tasdiqlangan hisob; mehmon va tasdiqlanmagan email — 401", async () => {
    const s = makeServer();
    expect((await s.call('POST', '/v1/me/teacher')).status).toBe(401);
    expect((await s.call('POST', '/v1/me/teacher', { token: 'x'.repeat(43) })).status).toBe(401);
    // Kod so'ralgan, lekin tasdiqlanmagan — sessiya yo'q, hisob ham yo'q.
    const email = uniqueEmail('unconfirmed');
    expect((await s.call('POST', '/v1/auth/otp/request', { body: { email } })).status).toBe(200);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM teacher_accounts').first<{ n: number }>();
    const before = n!.n;
    expect((await s.call('POST', '/v1/me/teacher', { token: 'A'.repeat(43) })).status).toBe(401);
    const after = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM teacher_accounts').first<{ n: number }>();
    expect(after!.n).toBe(before);
  });

  it("ro'yxatsiz guruh ochib bo'lmaydi (profil roli 'teacher' ham yetmaydi); qayta chaqirish xato emas", async () => {
    const s = makeServer();
    const t = await s.signIn(uniqueEmail('t'), { role: 'teacher' });
    expect((await s.call('GET', '/v1/me', { token: t.token })).data.teacher).toBe(false);
    const no = await s.call('POST', '/v1/groups', { token: t.token, body: { name: "Ro'yxatsiz" } });
    expect(no.status).toBe(403);
    expect((await s.call('POST', '/v1/me/teacher', { token: t.token })).status).toBe(200);
    expect((await s.call('POST', '/v1/me/teacher', { token: t.token })).status).toBe(200);
    const me = (await s.call('GET', '/v1/me', { token: t.token })).data;
    expect(me).toMatchObject({ teacher: true, admin_account: false, admin: false });
    expect((await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'KLD' } })).status).toBe(201);
  });

  it("ustoz admin emas: admin vakolati o'zgarmaydi, admin yo'llari yopiq", async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('t'));
    const a = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM admins WHERE user_id = ?1').bind(t.userId).first<{ n: number }>();
    expect(a!.n).toBe(0);
    expect((await s.call('GET', '/v1/admin/stats', { token: t.token })).status).toBe(403);
    const audit = await s.env.DB.prepare('SELECT action FROM audit_log WHERE target = ?1').bind(t.userId).all();
    expect(audit.results.map((r) => r.action)).toEqual(['teacher_registered']);
  });

  it("hisob o'chirilsa ustoz yozuvi ham o'chadi", async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('t'));
    expect((await s.call('DELETE', '/v1/me', { token: t.token })).status).toBe(204);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM teacher_accounts WHERE user_id = ?1').bind(t.userId).first<{ n: number }>();
    expect(n!.n).toBe(0);
  });
});

describe('guruh: cheklovlar', () => {
  it('nom 3–80 belgi; kod 8 belgi ABCDEFGHJKLMNPQRSTUVWXYZ23456789; ustoz nomi shart emas', async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('t'));
    for (const name of ['ab', '  ab  ', 'x'.repeat(81), '', 5, null]) {
      expect((await s.call('POST', '/v1/groups', { token: t.token, body: { name } })).status, String(name)).toBe(400);
    }
    const g = await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'x'.repeat(80) } });
    expect(g.status).toBe(201);
    expect(g.data.join_code).toHaveLength(8);
    for (const c of g.data.join_code) expect('ABCDEFGHJKLMNPQRSTUVWXYZ23456789').toContain(c);
    const m = (await s.call('GET', `/v1/groups/${g.data.id}/members`, { token: t.token })).data;
    expect(m).toEqual([expect.objectContaining({ user_id: t.userId, member_role: 'teacher', display_name: null, seat_no: null })]);
  });

  it("begona ustoz boshqa guruhni ro'yxatida ko'rmaydi", async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('t'));
    const t2 = await s.signInTeacher(uniqueEmail('t2'));
    await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'KLD' } });
    expect((await s.call('GET', '/v1/groups', { token: t2.token })).data).toEqual([]);
  });

  it("guruhda ≤ 200 a'zo: 201-chi — 429 (rateLimited)", async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('t'));
    const g = (await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Katta guruh' } })).data;
    // 199 talaba to'g'ridan-to'g'ri (tezlik uchun): ustoz + 199 = 200.
    const stmts = [];
    for (let i = 1; i <= 199; i++) {
      const uid = crypto.randomUUID();
      stmts.push(
        s.env.DB.prepare('INSERT INTO users (id, email_hash, email_masked, created_at) VALUES (?1, ?2, ?3, 0)').bind(uid, `h-${uid}`, 'x***@y.z'),
        s.env.DB.prepare(
          `INSERT INTO group_members (group_id, user_id, member_role, member_no, nickname, joined_at) VALUES (?1, ?2, 'student', ?3, NULL, 0)`,
        ).bind(g.id, uid, i),
      );
    }
    await s.env.DB.batch(stmts);
    const late = await s.signIn(uniqueEmail('late'));
    const r = await s.call('POST', '/v1/groups/join', { token: late.token, body: { code: g.join_code } });
    expect(r.status).toBe(429);
    expect(r.data.error).toBe('group_full');
  });
});

describe("a'zolar: taxallus yoki tartib raqami (setMyAlias, groupMembers)", () => {
  async function setup() {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('t'));
    const t2 = await s.signInTeacher(uniqueEmail('t2'));
    const g = (await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'KLD ixtisoslashtirish' } })).data;
    const s1 = await s.signIn(uniqueEmail('s1'));
    const s2 = await s.signIn(uniqueEmail('s2'));
    return { s, t, t2, g, s1, s2 };
  }

  it("qayta qo'shilish o'zgartirmaydi; taxallus kesiladi; talaba boshqa talabani ko'rmaydi", async () => {
    const { s, t, g, s1, s2 } = await setup();
    expect((await s.call('POST', '/v1/groups/join', { token: s1.token, body: { code: g.join_code } })).data.group_id).toBe(g.id);
    // Qayta: 200 va o'sha guruh; noto'g'ri taxallus ham e'tiborsiz.
    const again = await s.call('POST', '/v1/groups/join', { token: s1.token, body: { code: g.join_code, display_name: 'X' } });
    expect(again.status).toBe(200);
    expect(again.data.group_id).toBe(g.id);
    await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: g.join_code, display_name: '  Yulduz  ' } });
    const seen = (await s.call('GET', `/v1/groups/${g.id}/members`, { token: s2.token })).data;
    expect(seen).toHaveLength(2);
    expect(seen.map((m: any) => m.user_id)).not.toContain(s1.userId);
    const me = seen.find((m: any) => m.member_role === 'student');
    expect(me).toMatchObject({ user_id: s2.userId, display_name: 'Yulduz', seat_no: 2 });

    expect((await s.call('PUT', `/v1/groups/${g.id}/alias`, { token: s2.token, body: { alias: '' } })).status).toBe(200);
    const cleared = (await s.call('GET', `/v1/groups/${g.id}/members`, { token: s2.token })).data;
    expect(cleared.find((m: any) => m.member_role === 'student').display_name).toBeNull();
    expect((await s.call('PUT', `/v1/groups/${g.id}/alias`, { token: s2.token, body: { alias: null } })).status).toBe(200);
    expect((await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: g.join_code, display_name: 'Y' } })).status).toBe(200);

    const all = (await s.call('GET', `/v1/groups/${g.id}/members`, { token: t.token })).data;
    expect(all).toHaveLength(3);
    expect(all.filter((m: any) => m.member_role === 'student').map((m: any) => m.seat_no)).toEqual([1, 2]);
    expect(all.find((m: any) => m.user_id === s1.userId).display_name).toBeNull();
    expect(all.find((m: any) => m.user_id === t.userId).seat_no).toBeNull();
  });

  it('taxallus 2–24 belgi; email/havola emas', async () => {
    const { s, g, s1 } = await setup();
    await s.call('POST', '/v1/groups/join', { token: s1.token, body: { code: g.join_code } });
    for (const alias of ['Y', 'a'.repeat(25), 'a@b.uz', 'http://x.uz', 7]) {
      expect((await s.call('PUT', `/v1/groups/${g.id}/alias`, { token: s1.token, body: { alias } })).status, String(alias)).toBe(400);
    }
    for (const alias of ['Yo', 'a'.repeat(24)]) {
      const r = await s.call('PUT', `/v1/groups/${g.id}/alias`, { token: s1.token, body: { alias } });
      expect(r.status).toBe(200);
      expect(r.data.alias).toBe(alias);
    }
    const s3 = await s.signIn(uniqueEmail('s3'));
    expect((await s.call('POST', '/v1/groups/join', { token: s3.token, body: { code: g.join_code, display_name: 'b'.repeat(25) } })).status).toBe(400);
    expect((await s.call('POST', '/v1/groups/join', { token: s3.token, body: { code: g.join_code, display_name: 'b'.repeat(24) } })).status).toBe(201);
  });

  it('chiqib qayta qo\'shilgan talaba yangi raqam oladi (raqam qayta ishlatilmaydi)', async () => {
    const { s, t, g, s1, s2 } = await setup();
    await s.call('POST', '/v1/groups/join', { token: s1.token, body: { code: g.join_code } });
    await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: g.join_code } });
    expect((await s.call('POST', `/v1/groups/${g.id}/leave`, { token: s2.token })).status).toBe(204);
    await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: g.join_code } });
    const all = (await s.call('GET', `/v1/groups/${g.id}/members`, { token: t.token })).data;
    expect(all.find((m: any) => m.user_id === s2.userId).seat_no).toBe(3);
  });

  it("begona guruhda taxallus o'zgartirib bo'lmaydi; begona a'zolarni ko'rmaydi", async () => {
    const { s, t2, g, s1 } = await setup();
    await s.call('POST', '/v1/groups/join', { token: s1.token, body: { code: g.join_code } });
    expect((await s.call('PUT', `/v1/groups/${g.id}/alias`, { token: t2.token, body: { alias: 'Xa' } })).status).toBe(404);
    expect((await s.call('GET', `/v1/groups/${g.id}/members`, { token: t2.token })).status).toBe(404);
    expect((await s.call('PUT', `/v1/groups/${g.id}/alias`, { body: { alias: 'Xa' } })).status).toBe(401);
  });
});

describe('mavzular: ochish, bosqich, mavzu testi', () => {
  async function setup() {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('t'));
    const t2 = await s.signInTeacher(uniqueEmail('t2'));
    const g = (await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'KLD' } })).data;
    const s1 = await s.signIn(uniqueEmail('s1'));
    const s2 = await s.signIn(uniqueEmail('s2'));
    await s.call('POST', '/v1/groups/join', { token: s1.token, body: { code: g.join_code } });
    const base = `/v1/groups/${g.id}/topics`;
    return { s, t, t2, g, s1, s2, base };
  }
  const testBody = {
    title: '1-kun testi',
    question_ids: ['kdl-t-004', 'kdl-t-011', 'urea-1'],
    correct_indexes: [1, 0, 2],
    time_limit_minutes: 15,
  };

  it("talaba ham, begona ustoz ham mavzu ocha / bosqich belgilay / test boshlay olmaydi", async () => {
    const { s, t2, s1, base } = await setup();
    const ops: [string, string, unknown?][] = [
      ['PUT', `${base}/d001-P`],
      ['POST', `${base}/d001-P/stage`, { stage: 'lecture' }],
      ['POST', `${base}/d001-P/test`, testBody],
      ['POST', `${base}/d001-P/finish`],
    ];
    for (const [m, p, body] of ops) {
      // Talaba (a'zo) — 403; begona ustoz (a'zo emas) — 404, ilovada ikkalasi ham forbidden.
      expect((await s.call(m, p, { token: s1.token, body })).status, `student ${p}`).toBe(403);
      expect((await s.call(m, p, { token: t2.token, body })).status, `foreign ${p}`).toBe(404);
      expect((await s.call(m, p, { body })).status, `anon ${p}`).toBe(401);
    }
    expect((await s.call('GET', base, { token: s1.token })).data).toEqual([]);
    expect((await s.call('GET', base, { token: t2.token })).status).toBe(404);
  });

  it("noto'g'ri mavzu id si va bosqich — 400; id regex ^[A-Za-z0-9][A-Za-z0-9_.:-]{0,79}$", async () => {
    const { s, t, base } = await setup();
    for (const bad of ['bad topic; drop', 'bad id', '-lead', '_x', 'a/b', 'x'.repeat(81), "d'1"]) {
      expect((await s.call('PUT', `${base}/${enc(bad)}`, { token: t.token })).status, bad).toBe(400);
    }
    for (const ok of ['x'.repeat(80), 'd001-P', 'A.b_c:d-1', '9']) {
      expect((await s.call('PUT', `${base}/${enc(ok)}`, { token: t.token })).status, ok).toBe(200);
    }
    for (const stage of ['test', '', null, 'LECTURE']) {
      expect((await s.call('POST', `${base}/d001-P/stage`, { token: t.token, body: { stage } })).status).toBe(400);
    }
  });

  it("guruhga ≤ 300 mavzu: 301-chi — 429 (rateLimited)", async () => {
    const { s, t, g, base } = await setup();
    const stmts = [];
    for (let i = 0; i < 300; i++) {
      stmts.push(
        s.env.DB.prepare('INSERT INTO group_topics (group_id, topic_id, opened_at) VALUES (?1, ?2, ?3)').bind(g.id, `seed-${i}`, i),
      );
    }
    await s.env.DB.batch(stmts);
    // Mavjud mavzu — o'zgarmaydi (limitga urilmaydi); yangisi — 429.
    expect((await s.call('PUT', `${base}/seed-5`, { token: t.token })).status).toBe(200);
    const r = await s.call('PUT', `${base}/new-one`, { token: t.token });
    expect(r.status).toBe(429);
    expect(r.data.error).toBe('limit_topics');
  });

  it("to'liq oqim: ochish (qayta — o'zgarmaydi), bosqichlar, bitta test, natija faqat o'ziga va ustozga", async () => {
    const { s, t, t2, g, s1, s2, base } = await setup();
    const o1 = await s.call('PUT', `${base}/d001-P`, { token: t.token });
    expect(o1.status).toBe(200);
    s.clock.now += 1000;
    const o2 = await s.call('PUT', `${base}/d001-P`, { token: t.token });
    expect(o2.data.opened_at).toBe(o1.data.opened_at);
    const lec = await s.call('POST', `${base}/d001-P/stage`, { token: t.token, body: { stage: 'lecture' } });
    expect(lec.status).toBe(200);
    s.clock.now += 1000;
    // Qayta belgilash vaqtni o'zgartirmaydi.
    const lec2 = await s.call('POST', `${base}/d001-P/stage`, { token: t.token, body: { stage: 'lecture' } });
    expect(lec2.data.lecture_done_at).toBe(lec.data.lecture_done_at);
    await s.call('POST', `${base}/d001-P/stage`, { token: t.token, body: { stage: 'oral' } });
    const st = await s.call('POST', `${base}/d001-P/test`, { token: t.token, body: testBody });
    expect(st.status).toBe(201);
    const aid = st.data.id as string;

    const second = await s.call('POST', `${base}/d001-P/test`, {
      token: t.token,
      body: { title: 'Ikkinchi', question_ids: ['q1'], correct_indexes: [0], time_limit_minutes: 5 },
    });
    expect(second.status).toBe(409);
    expect(second.data.error).toBe('test_exists');

    const topics = (await s.call('GET', base, { token: t.token })).data;
    expect(topics).toHaveLength(1);
    expect(topics[0]).toMatchObject({ group_id: g.id, topic_id: 'd001-P', test_assignment_id: aid, open: true });
    expect(topics[0].lecture_done_at).toBeTruthy();
    expect(topics[0].oral_done_at).toBeTruthy();
    const asg = (await s.call('GET', `/v1/groups/${g.id}/assignments`, { token: t.token })).data;
    expect(asg).toHaveLength(1);
    expect(asg[0]).toMatchObject({ id: aid, topic_id: 'd001-P', time_limit_minutes: 15, status: 'open', due_at: null });

    // Talaba: mavzuni ko'radi, kalitni ko'rmaydi, yechadi.
    expect((await s.call('GET', base, { token: s1.token })).data.map((x: any) => x.topic_id)).toEqual(['d001-P']);
    expect((await s.call('GET', `/v1/assignments/${aid}/key`, { token: s1.token })).status).toBe(403);
    expect((await s.call('GET', `/v1/groups/${g.id}/assignments`, { token: s1.token })).text).not.toContain('correct_indexes');
    expect((await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token })).status).toBe(200);
    const sub = await s.call('POST', `/v1/assignments/${aid}/submit`, {
      token: s1.token,
      // user_id ni almashtirib bo'lmaydi — server sessiyadan oladi.
      body: { answers: [1, 1, 2], user_id: s2.userId, score: 3 },
    });
    expect(sub.status).toBe(201);
    expect(sub.data).toMatchObject({ user_id: s1.userId, score: 2, total: 3, correct: [true, false, true] });

    // Boshqa talaba S1 javobini ko'rmaydi.
    await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: g.join_code } });
    expect((await s.call('GET', `/v1/assignments/${aid}/submissions`, { token: s2.token })).data).toEqual([]);
    expect((await s.call('GET', `/v1/groups/${g.id}/submissions`, { token: s2.token })).data).toEqual([]);

    // Begona ustoz: natija, mavzu, a'zolar — yo'q (ilovada bo'sh ro'yxat).
    for (const p of [
      `/v1/assignments/${aid}/submissions`,
      `/v1/groups/${g.id}/submissions`,
      base,
      `/v1/groups/${g.id}/members`,
      `/v1/groups/${g.id}/assignments`,
    ]) {
      expect((await s.call('GET', p, { token: t2.token })).status, p).toBe(404);
    }

    // Ustoz: har savol bo'yicha natija.
    const res = (await s.call('GET', `/v1/assignments/${aid}/submissions`, { token: t.token })).data;
    expect(res).toHaveLength(1);
    expect(res[0].correct).toEqual([true, false, true]);
  });

  it("admin (aal2) ham guruh mavzusi, natijasi va a'zolarini ko'rmaydi", async () => {
    const adminEmail = uniqueEmail('admin');
    const s = makeServer({ LG_ADMIN_EMAILS: adminEmail });
    const t = await s.signInTeacher(uniqueEmail('t'));
    const g = (await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'KLD' } })).data;
    const st = await s.signIn(uniqueEmail('s'));
    await s.call('POST', '/v1/groups/join', { token: st.token, body: { code: g.join_code } });
    const aid = (await s.call('POST', `/v1/groups/${g.id}/topics/d001-P/test`, { token: t.token, body: testBody })).data.id;
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: st.token });
    await s.call('POST', `/v1/assignments/${aid}/submit`, { token: st.token, body: { answers: [1, 0, 2] } });

    const admin = await adminAal2(s, adminEmail);
    for (const p of [
      `/v1/assignments/${aid}/submissions`,
      `/v1/assignments/${aid}/key`,
      `/v1/groups/${g.id}/submissions`,
      `/v1/groups/${g.id}/topics`,
      `/v1/groups/${g.id}/members`,
      `/v1/groups/${g.id}/assignments`,
    ]) {
      expect((await s.call('GET', p, { token: admin.token })).status, p).toBe(404);
    }
    expect((await s.call('GET', '/v1/groups', { token: admin.token })).data).toEqual([]);
    expect((await s.call('PUT', `/v1/groups/${g.id}/topics/d002-P`, { token: admin.token })).status).toBe(404);
    expect((await s.call('POST', `/v1/groups/${g.id}/topics/d001-P/finish`, { token: admin.token })).status).toBe(404);
    // Ustoz ro'yxati ham API orqali ochilmaydi.
    expect((await s.call('GET', '/v1/admin/teachers', { token: admin.token })).status).toBe(501);
  });

  it("testni yakunlash: due_at = hozir; yangi talaba boshlay olmaydi; boshlagan — 2 daqiqa ichida topshiradi; mavzusiz — 404", async () => {
    const { s, t, g, s1, s2, base } = await setup();
    const aid = (await s.call('POST', `${base}/d008-L/test`, { token: t.token, body: { ...testBody, time_limit_minutes: 30 } })).data.id;
    // Topic test topshiriq — mavzu avtomatik ochiladi.
    expect((await s.call('GET', base, { token: s1.token })).data[0].topic_id).toBe('d008-L');
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token });
    s.clock.now += 60_000;
    expect((await s.call('POST', `${base}/d008-L/finish`, { token: t.token })).status).toBe(204);
    const finishedAt = s.clock.now;
    const a = (await s.call('GET', `/v1/groups/${g.id}/assignments`, { token: t.token })).data[0];
    expect(Date.parse(a.due_at)).toBe(finishedAt);
    expect(a.status).toBe('closed');
    // Qayta yakunlash — xato emas, vaqt o'zgarmaydi.
    s.clock.now += 1000;
    expect((await s.call('POST', `${base}/d008-L/finish`, { token: t.token })).status).toBe(204);
    expect(Date.parse((await s.call('GET', `/v1/groups/${g.id}/assignments`, { token: t.token })).data[0].due_at)).toBe(finishedAt);

    const missing = await s.call('POST', `${base}/d009-L/finish`, { token: t.token });
    expect(missing.status).toBe(404);
    expect(missing.data.error).toBe('no_test');
    // Ochilgan, lekin testsiz mavzu ham — 404.
    await s.call('PUT', `${base}/d010-L`, { token: t.token });
    expect((await s.call('POST', `${base}/d010-L/finish`, { token: t.token })).status).toBe(404);

    s.clock.now += 60_000;
    await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: g.join_code } });
    const late = await s.call('POST', `/v1/assignments/${aid}/start`, { token: s2.token });
    expect(late.status).toBe(409);
    // Yakunlashdan oldin boshlagan S1 — 2 daqiqa ichida qabul qilinadi.
    expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s1.token, body: { answers: [1, 0, 2] } })).status).toBe(201);
  });

  it("yakunlangandan 2 daqiqa o'tib topshirish — 409", async () => {
    const { s, t, s1, base } = await setup();
    const aid = (await s.call('POST', `${base}/d001-P/test`, { token: t.token, body: testBody })).data.id;
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token });
    await s.call('POST', `${base}/d001-P/finish`, { token: t.token });
    s.clock.now += 2 * 60_000 + 1;
    expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s1.token, body: { answers: [1, 0, 2] } })).status).toBe(409);
  });

  it('vaqt chegarasi: limit + 2 daqiqa ichida qabul, keyin — 409 time_over', async () => {
    const { s, t, s1, s2, g, base } = await setup();
    await s.call('POST', '/v1/groups/join', { token: s2.token, body: { code: g.join_code } });
    const aid = (await s.call('POST', `${base}/d001-P/test`, { token: t.token, body: { ...testBody, time_limit_minutes: 10 } })).data.id;
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: s1.token });
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: s2.token });
    s.clock.now += 12 * 60_000; // aynan limit + 2 daqiqa
    expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s1.token, body: { answers: [1, 0, 2] } })).status).toBe(201);
    s.clock.now += 1;
    const over = await s.call('POST', `/v1/assignments/${aid}/submit`, { token: s2.token, body: { answers: [1, 0, 2] } });
    expect(over.status).toBe(409);
    expect(over.data.error).toBe('time_over');
  });

  it("mavzu testi cheklovlari: sarlavha 3–120, savollar 1–50, vaqt 1–180, kalit soni", async () => {
    const { s, t, base } = await setup();
    const q = (n: number) => Array.from({ length: n }, (_, i) => `q${i}`);
    const z = (n: number) => Array.from({ length: n }, () => 0);
    const bad = [
      { title: 'Te', question_ids: ['q1'], correct_indexes: [0] },
      { title: 'x'.repeat(121), question_ids: ['q1'], correct_indexes: [0] },
      { title: 'Test', question_ids: [], correct_indexes: [] },
      { title: 'Test', question_ids: q(51), correct_indexes: z(51) },
      { title: 'Test', question_ids: ['q1'], correct_indexes: [0], time_limit_minutes: 0 },
      { title: 'Test', question_ids: ['q1'], correct_indexes: [0], time_limit_minutes: 181 },
      { title: 'Test', question_ids: ['q1', 'q2'], correct_indexes: [0] },
      { title: 'Test', question_ids: ['q1'], correct_indexes: [-1] },
    ];
    for (const [i, body] of bad.entries()) {
      expect((await s.call('POST', `${base}/t-${i}/test`, { token: t.token, body })).status, JSON.stringify(body).slice(0, 60)).toBe(400);
    }
    // Rad etilgan test mavzuni band qilmaydi.
    const ok = await s.call('POST', `${base}/t-0/test`, {
      token: t.token,
      body: { title: 'x'.repeat(120), question_ids: q(50), correct_indexes: z(50), time_limit_minutes: 180 },
    });
    expect(ok.status).toBe(201);
    expect((await s.call('POST', `${base}/t-1/test`, { token: t.token, body: { title: 'Abc', question_ids: ['q1'], correct_indexes: [0], time_limit_minutes: 1 } })).status).toBe(201);
  });

  it("topshiriq sarlavhasi va vaqti (oddiy topshiriq ham): 3–120, 1–180", async () => {
    const { s, t, g } = await setup();
    for (const body of [
      { title: 'x'.repeat(121), question_ids: ['q1'], correct_indexes: [0] },
      { title: 'Test', question_ids: ['q1'], correct_indexes: [0], time_limit_minutes: 181 },
    ]) {
      expect((await s.call('POST', `/v1/groups/${g.id}/assignments`, { token: t.token, body })).status).toBe(400);
    }
  });

  it("parallel 'Testni boshlash' — faqat bittasi o'tadi", async () => {
    const { s, t, g, base } = await setup();
    const rs = await Promise.all(
      [1, 2, 3].map(() => s.call('POST', `${base}/d001-P/test`, { token: t.token, body: testBody })),
    );
    expect(rs.map((r) => r.status).sort()).toEqual([201, 409, 409]);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM assignments WHERE group_id = ?1').bind(g.id).first<{ n: number }>();
    expect(n!.n).toBe(1);
    const keys = await s.env.DB.prepare(
      'SELECT COUNT(*) AS n FROM assignment_keys k JOIN assignments a ON a.id = k.assignment_id WHERE a.group_id = ?1',
    )
      .bind(g.id)
      .first<{ n: number }>();
    expect(keys!.n).toBe(1);
  });
});
