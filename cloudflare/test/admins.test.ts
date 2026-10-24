import { beforeEach, describe, expect, it } from 'vitest';
import { GRANT_ADD_PER_HOUR, MAX_ACTIVE_GRANTS } from '../src/admins';
import { makeServer, uniqueEmail, setAutoStepUp } from './helpers';

// Eski testlar: step-up so'ralsa ilovadagidek bir marta tasdiqlab qaytaradi (stepup.test.ts — alohida).
beforeEach(() => setAutoStepUp(true));

/** Har test o'z super admini bilan (umumiy D1 da bir-biriga ta'sir qilmaydi). */
async function setup() {
  const owner = uniqueEmail('owner');
  const s = makeServer({ LG_ADMIN_EMAILS: owner });
  const boss = await s.signInAdmin(owner);
  // Adminlarni o'zgartirish — step-up (10 daqiqa); bir marta oldindan.
  await s.stepUp(boss.token, owner);
  return { s, owner, boss };
}

const add = (s: ReturnType<typeof makeServer>, token: string, email: unknown) =>
  s.call('POST', '/v1/admin/admins', { token, body: { email } });

describe('adminlar boshqaruvi (D-44)', () => {
  it("super admin emailni qo'shadi: javobda faqat niqoblangan email; kirgach + TOTP → to'liq admin", async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('helper');
    const r = await add(s, boss.token, `  ${email.toUpperCase()} `);
    expect(r.status).toBe(201);
    expect(r.data).toMatchObject({ kind: 'granted', active: false, email_masked: `${email.slice(0, 2)}***@example.test` });
    expect(r.text).not.toContain(email);
    expect(r.text.toLowerCase()).not.toContain(email.split('@')[0]);

    const list = await s.call('GET', '/v1/admin/admins', { token: boss.token });
    expect(list.status).toBe(200);
    expect(list.data.can_manage).toBe(true);
    expect(list.text).not.toContain(email);
    const supers = list.data.admins.filter((a: any) => a.kind === 'super');
    expect(supers).toHaveLength(1);
    expect(supers[0]).toMatchObject({ id: null, you: true, active: true });
    expect(list.data.admins.find((a: any) => a.id === r.data.id)).toMatchObject({ active: false, you: false });

    // Email kod bilan tasdiqlanganda — admin hisobi, lekin TOTP siz hech narsa.
    const h = await s.signIn(email);
    expect((await s.call('GET', '/v1/me', { token: h.token })).data).toMatchObject({
      admin_account: true,
      admin: false,
      super_admin: false,
      aal: 'aal1',
    });
    expect((await s.call('GET', '/v1/admin/community/members', { token: h.token })).status).toBe(403);
    expect((await s.call('GET', '/v1/admin/admins', { token: h.token })).status).toBe(403);

    const h2 = await s.signInAdmin(email);
    expect((await s.call('GET', '/v1/me', { token: h2.token })).data).toMatchObject({ admin: true, super_admin: false });
    expect((await s.call('GET', '/v1/admin/community/members', { token: h2.token })).status).toBe(200);
    // Egasi admin paneli (statistika va h.k.) — faqat ADMIN_EMAILS; qo'shilgan admin emas.
    expect((await s.call('GET', '/v1/admin/stats', { token: h2.token })).status).toBe(403);
    // Hali ko'chirilmagan admin yo'llari vakolatdan o'tadi (501, 403 emas).
    expect((await s.call('GET', '/v1/admin/teachers', { token: h2.token })).status).toBe(501);
    const l2 = await s.call('GET', '/v1/admin/admins', { token: h2.token });
    expect(l2.data.can_manage).toBe(false);
    expect(l2.data.admins.find((a: any) => a.id === r.data.id)).toMatchObject({ active: true, you: true });
  });

  it("hisob mavjud bo'lsa — darhol (mavjud sessiyada admin_account); baribir aal2 kerak", async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('existing');
    const u = await s.signIn(email);
    expect((await s.call('GET', '/v1/me', { token: u.token })).data.admin_account).toBe(false);
    const r = await add(s, boss.token, email);
    expect(r.status).toBe(201);
    expect(r.data.active).toBe(true);
    expect((await s.call('GET', '/v1/me', { token: u.token })).data).toMatchObject({ admin_account: true, admin: false });
    expect((await s.call('POST', '/v1/admin/community/members/x/restore', { token: u.token })).status).toBe(403);
  });

  it("oddiy admin qo'sha/olib tashlay olmaydi; foydalanuvchi o'zini admin qila olmaydi", async () => {
    const { s, boss } = await setup();
    const helper = uniqueEmail('helper');
    const g = await add(s, boss.token, helper);
    const h = await s.signInAdmin(helper);
    const other = uniqueEmail('other');
    const r1 = await add(s, h.token, other);
    expect(r1.status).toBe(403);
    expect(r1.data.error).toBe('not_super_admin');
    expect((await s.call('DELETE', `/v1/admin/admins/${g.data.id}`, { token: h.token })).status).toBe(403);

    const u = await s.signIn(uniqueEmail('user'));
    const self = await s.call('GET', '/v1/me', { token: u.token });
    // O'zini qo'shish: oddiy foydalanuvchi uchun admin yo'li yopiq.
    expect((await add(s, u.token, 'anything@example.test')).status).toBe(403);
    expect((await s.call('GET', '/v1/admin/admins', { token: u.token })).status).toBe(403);
    expect((await s.call('DELETE', `/v1/admin/admins/${g.data.id}`, { token: u.token })).status).toBe(403);
    expect((await s.call('GET', '/v1/me', { token: u.token })).data).toEqual(self.data);
    expect((await s.call('GET', '/v1/admin/admins')).status).toBe(401);
  });

  it('super admin aal1 (TOTP siz) — rad', async () => {
    const owner = uniqueEmail('owner');
    const s = makeServer({ LG_ADMIN_EMAILS: owner });
    const b = await s.signIn(owner);
    expect((await s.call('GET', '/v1/me', { token: b.token })).data).toMatchObject({ super_admin: true, admin: false });
    expect((await add(s, b.token, uniqueEmail())).status).toBe(403);
    expect((await s.call('GET', '/v1/admin/admins', { token: b.token })).status).toBe(403);
  });

  it("olib tashlash: mavjud sessiyalarda darhol vakolat yo'qoladi, qayta kirishda ham", async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('removed');
    const g = await add(s, boss.token, email);
    const h = await s.signInAdmin(email);
    expect((await s.call('GET', '/v1/admin/community/members', { token: h.token })).status).toBe(200);

    const d = await s.call('DELETE', `/v1/admin/admins/${g.data.id}`, { token: boss.token });
    expect(d.status).toBe(204);
    expect((await s.call('GET', '/v1/me', { token: h.token })).data).toMatchObject({
      admin_account: false,
      admin: false,
      aal: 'aal1',
    });
    expect((await s.call('GET', '/v1/admin/community/members', { token: h.token })).status).toBe(403);
    expect((await s.call('GET', '/v1/auth/mfa', { token: h.token })).status).toBe(403);
    const again = await s.signIn(email);
    expect((await s.call('GET', '/v1/me', { token: again.token })).data.admin_account).toBe(false);
    // Ikkinchi marta — topilmaydi; ro'yxatda yo'q.
    expect((await s.call('DELETE', `/v1/admin/admins/${g.data.id}`, { token: boss.token })).status).toBe(404);
    const list = await s.call('GET', '/v1/admin/admins', { token: boss.token });
    expect(list.data.admins.some((a: any) => a.id === g.data.id)).toBe(false);
    // Qayta qo'shish mumkin (yangi grant).
    expect((await add(s, boss.token, email)).status).toBe(201);
    expect((await s.call('GET', '/v1/me', { token: again.token })).data.admin_account).toBe(true);

    const audit = await s.env.DB.prepare('SELECT action, target, details FROM audit_log WHERE target = ?1 OR target = ?2')
      .bind(g.data.id, h.userId)
      .all<{ action: string; target: string; details: string }>();
    const actions = audit.results.map((a) => a.action);
    expect(actions).toEqual(expect.arrayContaining(['admin_grant_added', 'admin_grant_removed', 'admin_revoked']));
    expect(JSON.stringify(audit.results)).not.toContain(email);
  });

  it("validatsiya: noto'g'ri email, takror, super admin emaili; super adminni API orqali o'chirib bo'lmaydi", async () => {
    const { s, owner, boss } = await setup();
    for (const bad of ['', 'not-an-email', 'a@b', 'x@y.z', 42, null, `${'a'.repeat(250)}@example.test`]) {
      const r = await add(s, boss.token, bad);
      expect(r.status, String(bad)).toBe(400);
      expect(r.data.error).toBe('invalid_email');
    }
    const e = uniqueEmail('dup');
    expect((await add(s, boss.token, e)).status).toBe(201);
    const dup = await add(s, boss.token, e.toUpperCase());
    expect(dup.status).toBe(409);
    expect(dup.data.error).toBe('already_admin');
    const sup = await add(s, boss.token, owner.toUpperCase());
    expect(sup.status).toBe(409);
    expect(sup.data.error).toBe('already_super_admin');

    for (const id of ['super', 'null', '00000000-0000-0000-0000-000000000000', boss.userId, '..%2F']) {
      expect((await s.call('DELETE', `/v1/admin/admins/${id}`, { token: boss.token })).status, id).toBe(404);
    }
    expect((await s.call('GET', '/v1/me', { token: boss.token })).data).toMatchObject({ admin: true, super_admin: true });
  });

  it("email ochiq holda saqlanmaydi (faqat HMAC + niqob)", async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('privacy');
    const r = await add(s, boss.token, email);
    const row = await s.env.DB.prepare('SELECT * FROM admin_grants WHERE id = ?1').bind(r.data.id).first<Record<string, unknown>>();
    expect(row).not.toBeNull();
    const dump = JSON.stringify(row);
    expect(dump).not.toContain(email);
    expect(dump).not.toContain(email.split('@')[0]);
    expect(row!.email_hmac).toMatch(/^[0-9a-f]{64}$/);
    expect(row!.granted_by_hash).toMatch(/^[0-9a-f]{64}$/);
    expect(row!.granted_by_hash).not.toBe(boss.userId);
  });

  it("limitlar: soatiga qo'shish soni va faol adminlar chegarasi", async () => {
    const { s, boss } = await setup();
    for (let i = 0; i < GRANT_ADD_PER_HOUR; i++) {
      // Ba'zilari validatsiyadan o'tmaydi — baribir sanaladi (taxmin qilishga qarshi).
      const r = await add(s, boss.token, i % 2 ? uniqueEmail('rl') : 'bad');
      expect([201, 400]).toContain(r.status);
    }
    expect((await add(s, boss.token, uniqueEmail('rl'))).status).toBe(429);

    s.clock.now += 3601_000;
    const active = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM admin_grants WHERE revoked_at IS NULL').first<{ n: number }>();
    const fill: string[] = [];
    for (let i = active!.n; i < MAX_ACTIVE_GRANTS; i++) {
      const id = crypto.randomUUID();
      fill.push(id);
      await s.env.DB.prepare(
        `INSERT INTO admin_grants (id, email_hmac, email_masked, granted_by_hash, created_at) VALUES (?1, ?2, 'fi***@x.test', ?3, ?4)`,
      )
        .bind(id, id.replace(/-/g, '').padEnd(64, '0'), 'f'.repeat(64), s.clock.now)
        .run();
    }
    const full = await add(s, boss.token, uniqueEmail('cap'));
    expect(full.status).toBe(409);
    expect(full.data.error).toBe('too_many_admins');
    for (const id of fill) {
      await s.env.DB.prepare('UPDATE admin_grants SET revoked_at = ?2 WHERE id = ?1').bind(id, s.clock.now).run();
    }
  });
});
