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

describe('rollar', () => {
  it("profil: rol va til; 'admin' yoki noma'lum rol qabul qilinmaydi", async () => {
    const s = makeServer();
    const { token } = await s.signIn(uniqueEmail());
    expect((await s.call('PUT', '/v1/me/profile', { token, body: { role: 'teacher', language: 'ru' } })).status).toBe(200);
    expect((await s.call('GET', '/v1/me', { token })).data).toMatchObject({ role: 'teacher', language: 'ru' });
    for (const role of ['admin', 'ADMIN', 'superuser', '', 1, { admin: true }]) {
      const r = await s.call('PUT', '/v1/me/profile', { token, body: { role } });
      expect(r.status).toBe(400);
    }
    expect((await s.call('PUT', '/v1/me/profile', { token, body: { language: 'de' } })).status).toBe(400);
  });

  it("o'zini admin qila olmaydi: qo'shimcha maydonlar e'tiborsiz, admin yo'llari 403", async () => {
    const s = makeServer();
    const { token, userId } = await s.signIn(uniqueEmail());
    await s.call('PUT', '/v1/me/profile', {
      token,
      body: { role: 'student', admin: true, admin_account: true, is_admin: 1, aal: 'aal2' },
    });
    const me = await s.call('GET', '/v1/me', { token });
    expect(me.data).toMatchObject({ admin_account: false, admin: false, aal: 'aal1' });
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM admins WHERE user_id = ?1').bind(userId).first<{ n: number }>();
    expect(n?.n).toBe(0);
    for (const path of ['/v1/admin/stats', '/v1/admin/users', '/v1/admin/audit']) {
      expect((await s.call('GET', path, { token })).status).toBe(403);
    }
    expect((await s.call('POST', '/v1/auth/mfa/enroll', { token })).status).toBe(403);
    expect((await s.call('GET', '/v1/auth/mfa', { token })).status).toBe(403);
    expect((await s.call('GET', '/v1/admin/stats')).status).toBe(401);
  });

  it("admin emailni 'egallash' mumkin emas: ro'yxat faqat OTP tasdig'idan keyin", async () => {
    const s = makeServer();
    // Kod boshqa emailga keladi — admin emailini bilish yetmaydi.
    await s.call('POST', '/v1/auth/otp/request', { body: { email: 'boss@example.test' } });
    const r = await s.call('POST', '/v1/auth/otp/verify', { body: { email: 'boss@example.test', code: '000000' } });
    expect([400, 429]).toContain(r.status);
    expect((await s.env.DB.prepare('SELECT COUNT(*) AS n FROM admins').first<{ n: number }>())?.n).toBe(0);
  });

  it('admin: allowlist + OTP → admin_account; TOTP (aal2) siz admin yo\'llari yopiq', async () => {
    const s = makeServer();
    const { token, userId } = await s.signIn('Boss@Example.test');
    const me = await s.call('GET', '/v1/me', { token });
    expect(me.data).toMatchObject({ admin_account: true, admin: false, aal: 'aal1' });
    expect((await s.call('GET', '/v1/admin/stats', { token })).status).toBe(403);
    const audit = await s.env.DB.prepare(`SELECT action FROM audit_log WHERE target = ?1`).bind(userId).all();
    expect(audit.results.map((r) => r.action)).toContain('admin_granted');

    const en = await s.call('POST', '/v1/auth/mfa/enroll', { token });
    expect(en.status).toBe(200);
    expect(en.data.uri).toContain('otpauth://totp/');
    const secret = unbase32(en.data.secret);
    const step = Math.floor(s.clock.now / 30_000);
    // Noto'g'ri kod
    expect((await s.call('POST', '/v1/auth/mfa/verify', { token, body: { code: '000000' === (await totpAt(secret, step)) ? '111111' : '000000' } })).status).toBe(400);
    const ok = await s.call('POST', '/v1/auth/mfa/verify', { token, body: { code: await totpAt(secret, step) } });
    expect(ok.status).toBe(200);
    expect((await s.call('GET', '/v1/me', { token })).data).toMatchObject({ admin: true, aal: 'aal2' });
    // Admin yo'llari vakolatdan o'tadi, lekin hali ko'chirilmagan — 501 (ishlayotgandek emas).
    const st = await s.call('GET', '/v1/admin/stats', { token });
    expect(st.status).toBe(501);
    expect(st.data.error).toBe('not_implemented');

    // Kodni qayta ishlatish (replay) — rad.
    s.clock.now += 61_000;
    const t2 = await s.signIn('boss@example.test');
    expect((await s.call('POST', '/v1/auth/mfa/verify', { token: t2.token, body: { code: await totpAt(secret, step) } })).status).toBe(400);
    // Tasdiqlangan faktor bor — yangi faktor qo'shib bo'lmaydi (o'g'irlangan aal1 sessiyaga qarshi).
    expect((await s.call('POST', '/v1/auth/mfa/enroll', { token: t2.token })).status).toBe(403);
    expect((await s.call('GET', '/v1/admin/stats', { token: t2.token })).status).toBe(403);
    const now2 = Math.floor(s.clock.now / 30_000);
    expect((await s.call('POST', '/v1/auth/mfa/verify', { token: t2.token, body: { code: await totpAt(secret, now2) } })).status).toBe(200);
    expect((await s.call('GET', '/v1/admin/stats', { token: t2.token })).status).toBe(501);
  });

  it("allowlist'dan chiqarilgan email keyingi kirishda vakolatini yo'qotadi", async () => {
    const email = uniqueEmail('exadmin');
    const s1 = makeServer({ LG_ADMIN_EMAILS: email });
    const a = await s1.signIn(email);
    expect((await s1.call('GET', '/v1/me', { token: a.token })).data.admin_account).toBe(true);
    const s2 = makeServer({ LG_ADMIN_EMAILS: '' });
    const b = await s2.signIn(email);
    expect((await s2.call('GET', '/v1/me', { token: b.token })).data.admin_account).toBe(false);
  });

  it('teacher — huquq faqat yaratish uchun rol; student guruh yarata olmaydi', async () => {
    const s = makeServer();
    for (const role of ['student', 'doctor', 'lab']) {
      const u = await s.signIn(uniqueEmail(role), { role });
      const r = await s.call('POST', '/v1/groups', { token: u.token, body: { name: 'Guruh A' } });
      expect(r.status).toBe(403);
      expect(r.data.error).toBe('teacher_role_required');
    }
  });
});
