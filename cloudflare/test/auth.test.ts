import { describe, expect, it } from 'vitest';
import { makeServer, uniqueEmail } from './helpers';

describe('email OTP', () => {
  it('kod 6 raqam, email-sender orqali; javob kodni qaytarmaydi', async () => {
    const s = makeServer();
    const email = uniqueEmail();
    const r = await s.call('POST', '/v1/auth/otp/request', { body: { email: `  ${email.toUpperCase()} ` } });
    expect(r.status).toBe(200);
    expect(r.data).toEqual({ status: 'sent', retry_after: 60, valid_for: 600 });
    expect(s.outbox).toHaveLength(1);
    expect(s.outbox[0].to).toBe(email);
    expect(s.outbox[0].code).toMatch(/^\d{6}$/);
    expect(r.text).not.toContain(s.outbox[0].code);
  });

  it('kod va email bazada ochiq holda saqlanmaydi (faqat HMAC)', async () => {
    const s = makeServer();
    const email = uniqueEmail('privacy');
    await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    const code = s.outbox[0].code;
    const ch = await s.env.DB.prepare('SELECT * FROM otp_challenges').all();
    const dump = JSON.stringify(ch.results);
    expect(dump).not.toContain(code);
    expect(dump).not.toContain(email);
    const v = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code } });
    expect(v.status).toBe(200);
    const users = JSON.stringify((await s.env.DB.prepare('SELECT * FROM users').all()).results);
    expect(users).not.toContain(email);
    expect(users).toContain('pr***@example.test');
    const sessions = JSON.stringify((await s.env.DB.prepare('SELECT * FROM sessions').all()).results);
    expect(sessions).not.toContain(v.data.token);
  });

  it("noto'g'ri email — 400, xat yuborilmaydi", async () => {
    const s = makeServer();
    for (const email of ['not-an-email', '', 'a@b', 42, null, `${'a'.repeat(250)}@x.com`]) {
      const r = await s.call('POST', '/v1/auth/otp/request', { body: { email } });
      expect(r.status).toBe(400);
      expect(r.data.error).toBe('invalid_email');
    }
    expect(s.outbox).toHaveLength(0);
  });

  it('muvaffaqiyatli kirish: sessiya, /me, yangi foydalanuvchi — student', async () => {
    const s = makeServer();
    const { token, userId } = await s.signIn(uniqueEmail());
    const me = await s.call('GET', '/v1/me', { token });
    expect(me.status).toBe(200);
    expect(me.data).toMatchObject({ user_id: userId, role: 'student', admin_account: false, admin: false, aal: 'aal1' });
  });

  it('kod bir martalik', async () => {
    const s = makeServer();
    const email = uniqueEmail();
    await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    const code = s.outbox[0].code;
    expect((await s.call('POST', '/v1/auth/otp/verify', { body: { email, code } })).status).toBe(200);
    const again = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code } });
    expect(again.status).toBe(400);
    expect(again.data.error).toBe('no_active_code');
  });

  it("10 daqiqadan keyin kod eskiradi", async () => {
    const s = makeServer();
    const email = uniqueEmail();
    await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    s.clock.now += 600_000;
    const r = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code: s.outbox[0].code } });
    expect(r.status).toBe(400);
    expect(r.data.error).toBe('expired');
  });

  it("5 noto'g'ri urinishdan keyin to'g'ri kod ham qabul qilinmaydi", async () => {
    const s = makeServer();
    const email = uniqueEmail();
    await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    const good = s.outbox[0].code;
    const bad = good === '000000' ? '111111' : '000000';
    const left: number[] = [];
    for (let i = 0; i < 4; i++) {
      const r = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code: bad } });
      expect(r.status).toBe(400);
      left.push(r.data.attempts_left);
    }
    expect(left).toEqual([4, 3, 2, 1]);
    const fifth = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code: bad } });
    expect(fifth.status).toBe(429);
    expect(fifth.data.error).toBe('too_many_attempts');
    const good6 = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code: good } });
    expect(good6.status).toBe(400);
    expect(good6.data.error).toBe('no_active_code');
  });

  it('qayta yuborish 60 s ichida — 429 va retry_after', async () => {
    const s = makeServer();
    const email = uniqueEmail();
    await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    s.clock.now += 20_000;
    const r = await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    expect(r.status).toBe(429);
    expect(r.data.retry_after).toBe(40);
    expect(r.headers.get('retry-after')).toBe('40');
    expect(s.outbox).toHaveLength(1);
    s.clock.now += 41_000;
    expect((await s.call('POST', '/v1/auth/otp/request', { body: { email } })).status).toBe(200);
  });

  it('email bo\'yicha limit: soatiga 5 ta kod', async () => {
    const s = makeServer();
    const email = uniqueEmail();
    for (let i = 0; i < 5; i++) {
      expect((await s.call('POST', '/v1/auth/otp/request', { body: { email }, ip: `192.0.2.${i}` })).status).toBe(200);
      s.clock.now += 61_000;
    }
    const r = await s.call('POST', '/v1/auth/otp/request', { body: { email }, ip: '192.0.2.99' });
    expect(r.status).toBe(429);
    expect(r.data.error).toBe('rate_limited');
    expect(s.outbox).toHaveLength(5);
  });

  it("IP bo'yicha limit: soatiga 60 ta so'rov", async () => {
    const s = makeServer();
    const ip = '192.0.2.200';
    for (let i = 0; i < 60; i++) {
      expect((await s.call('POST', '/v1/auth/otp/request', { body: { email: uniqueEmail('ip') }, ip })).status).toBe(200);
    }
    const r = await s.call('POST', '/v1/auth/otp/request', { body: { email: uniqueEmail('ip') }, ip });
    expect(r.status).toBe(429);
    // Boshqa IP ishlayveradi.
    expect((await s.call('POST', '/v1/auth/otp/request', { body: { email: uniqueEmail('ip') }, ip: '192.0.2.201' })).status).toBe(200);
  });

  it('pochta sozlanmagan — 503, yuborilmagan kod saqlanmaydi', async () => {
    const s = makeServer();
    s.setMail('not_configured');
    const email = uniqueEmail();
    const r = await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    expect(r.status).toBe(503);
    expect(r.data).toEqual({ error: 'not_configured' });
    s.setMail('failed');
    const f = await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    expect(f.status).toBe(502);
    const v = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code: '123456' } });
    expect(v.data.error).toBe('no_active_code');
  });

  it('server secreti yo\'q — 503 not_configured', async () => {
    const s = makeServer({ LG_SERVER_SECRET: '' });
    const r = await s.call('POST', '/v1/auth/otp/request', { body: { email: uniqueEmail() } });
    expect(r.status).toBe(503);
    expect(r.data.error).toBe('not_configured');
  });
});

describe('sessiya', () => {
  it('tokensiz, soxta va eskirgan token — 401', async () => {
    const s = makeServer();
    expect((await s.call('GET', '/v1/me')).status).toBe(401);
    expect((await s.call('GET', '/v1/me', { token: 'x'.repeat(43) })).status).toBe(401);
    expect((await s.call('GET', '/v1/me', { headers: { authorization: "Bearer ' OR 1=1 --" } })).status).toBe(401);
    const { token } = await s.signIn(uniqueEmail());
    s.clock.now += 61 * 86400_000;
    expect((await s.call('GET', '/v1/me', { token })).status).toBe(401);
  });

  it('chiqish tokenni bekor qiladi; logout-all — hamma qurilmalar', async () => {
    const s = makeServer();
    const email = uniqueEmail();
    const a = await s.signIn(email);
    s.clock.now += 61_000;
    const b = await s.signIn(email);
    expect(a.userId).toBe(b.userId);
    expect((await s.call('POST', '/v1/auth/logout', { token: a.token })).status).toBe(204);
    expect((await s.call('GET', '/v1/me', { token: a.token })).status).toBe(401);
    expect((await s.call('GET', '/v1/me', { token: b.token })).status).toBe(200);
    s.clock.now += 61_000;
    const c = await s.signIn(email);
    expect((await s.call('POST', '/v1/auth/logout-all', { token: c.token })).status).toBe(204);
    expect((await s.call('GET', '/v1/me', { token: b.token })).status).toBe(401);
  });

  it("hisobni o'chirish: sessiya, profil, a'zolik va natijalar o'chadi", async () => {
    const s = makeServer();
    const teacher = await s.signInTeacher(uniqueEmail('t'));
    const g = await s.call('POST', '/v1/groups', { token: teacher.token, body: { name: 'Gematologiya' } });
    const student = await s.signIn(uniqueEmail('st'));
    await s.call('POST', '/v1/groups/join', { token: student.token, body: { code: g.data.join_code } });
    const a = await s.call('POST', `/v1/groups/${g.data.id}/assignments`, {
      token: teacher.token,
      body: { title: 'Test 1', question_ids: ['q1'], correct_indexes: [0] },
    });
    await s.call('POST', `/v1/assignments/${a.data.id}/start`, { token: student.token });
    await s.call('POST', `/v1/assignments/${a.data.id}/submit`, { token: student.token, body: { answers: [0] } });

    expect((await s.call('DELETE', '/v1/me', { token: student.token })).status).toBe(204);
    expect((await s.call('GET', '/v1/me', { token: student.token })).status).toBe(401);
    for (const t of ['users', 'sessions', 'group_members', 'submissions', 'assignment_attempts']) {
      const n = await s.env.DB.prepare(`SELECT COUNT(*) AS n FROM ${t} WHERE ${t === 'users' ? 'id' : 'user_id'} = ?1`)
        .bind(student.userId)
        .first<{ n: number }>();
      expect(n?.n, t).toBe(0);
    }
    // Ustoz o'chsa — uning guruhlari ham.
    expect((await s.call('DELETE', '/v1/me', { token: teacher.token })).status).toBe(204);
    const gs = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM study_groups WHERE id = ?1').bind(g.data.id).first<{ n: number }>();
    expect(gs?.n).toBe(0);
  });
});
