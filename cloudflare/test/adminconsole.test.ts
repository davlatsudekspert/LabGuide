import { describe, expect, it } from 'vitest';
import { DEFAULT_ADMIN_EMAILS } from '../src/auth';
import { makeServer, uniqueEmail } from './helpers';

type Server = ReturnType<typeof makeServer>;
const DAY = 86400_000;
const HASH_RE = /\b[0-9a-f]{64}\b/;

/** Har test o'z egasi bilan (ADMIN_EMAILS); egasi oddiy email kodi bilan kiradi (TOTP siz). */
async function setup() {
  const owner = uniqueEmail('owner');
  const s = makeServer({ ADMIN_EMAILS: owner, LG_ADMIN_EMAILS: '' } as never);
  const boss = await s.signIn(owner);
  return { s, owner, boss };
}

const READS: ((id: string) => string)[] = [
  () => '/v1/admin/stats',
  () => '/v1/admin/users',
  (id) => `/v1/admin/users/${id}`,
  () => '/v1/admin/complaints',
  () => '/v1/admin/reports',
  () => '/v1/admin/audit',
  () => '/v1/admin/support/threads',
];

describe('admin panel: vakolat (ADMIN_EMAILS, har so‘rovda qayta tekshiriladi)', () => {
  it('mehmon 401, oddiy foydalanuvchi 403, admin (email kodi, TOTP siz) 200', async () => {
    const { s, boss } = await setup();
    const user = await s.signIn(uniqueEmail('plain'));
    for (const p of READS) {
      const path = p(user.userId);
      expect((await s.call('GET', path)).status, `anon ${path}`).toBe(401);
      expect((await s.call('GET', path, { token: user.token })).status, `user ${path}`).toBe(403);
      expect((await s.call('GET', path, { token: boss.token })).status, `admin ${path}`).toBe(200);
    }
    expect((await s.call('GET', '/v1/me', { token: boss.token })).data.panel_admin).toBe(true);
    expect((await s.call('GET', '/v1/me', { token: user.token })).data.panel_admin).toBe(false);
    for (const p of [`/v1/admin/users/${user.userId}/suspend`, `/v1/admin/users/${user.userId}/reactivate`]) {
      expect((await s.call('POST', p)).status).toBe(401);
      expect((await s.call('POST', p, { token: user.token })).status).toBe(403);
    }
    expect((await s.call('POST', `/v1/admin/users/${user.userId}/role`, { token: user.token, body: { role: 'lab' } })).status).toBe(403);
  });

  it("ADMIN_EMAILS dan olib tashlangan — mavjud sessiyada ham darhol 403; LG_ADMIN_EMAILS — zaxira; standart egasi", async () => {
    const owner = uniqueEmail('owner');
    const s = makeServer({ ADMIN_EMAILS: owner } as never);
    const boss = await s.signIn(owner);
    expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).status).toBe(200);
    (s.env as unknown as Record<string, string>).ADMIN_EMAILS = uniqueEmail('new-owner');
    expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).status).toBe(403);
    expect((await s.call('GET', '/v1/me', { token: boss.token })).data).toMatchObject({ panel_admin: false, super_admin: false });

    const legacyOwner = uniqueEmail('legacy');
    const s2 = makeServer({ ADMIN_EMAILS: '', LG_ADMIN_EMAILS: legacyOwner } as never);
    const l = await s2.signIn(legacyOwner);
    expect((await s2.call('GET', '/v1/admin/stats', { token: l.token })).status).toBe(200);

    // Ikkalasi ham bo'sh — egasining standart emaili (egasi qarori).
    const s3 = makeServer({ ADMIN_EMAILS: '', LG_ADMIN_EMAILS: '' } as never);
    const d = await s3.signIn(DEFAULT_ADMIN_EMAILS);
    expect((await s3.call('GET', '/v1/admin/stats', { token: d.token })).status).toBe(200);
    const other = await s3.signIn(uniqueEmail('other'));
    expect((await s3.call('GET', '/v1/admin/stats', { token: other.token })).status).toBe(403);
  });

  it('Google/Apple bilan ochilgan sessiya admin panelni ochmaydi (faqat email kodi)', async () => {
    const { s, boss } = await setup();
    await s.env.DB.prepare(`UPDATE sessions SET via = 'google' WHERE user_id = ?1`).bind(boss.userId).run();
    expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).status).toBe(403);
  });
});

describe('umumiy ko‘rsatkichlar', () => {
  it("seed ma'lumotda: jami, 7/30 kun, onlayn, rollar, 14 kunlik grafik, obyektlar — hash/email yo'q", async () => {
    const { s, boss } = await setup();
    const before = (await s.call('GET', '/v1/admin/stats', { token: boss.token })).data;
    const now = s.clock.now;
    const a = await s.signIn(uniqueEmail('a'), { role: 'doctor', language: 'ru' });
    const t = await s.signInTeacher(uniqueEmail('t'));
    const old10 = await s.signIn(uniqueEmail('old10'));
    const old40 = await s.signIn(uniqueEmail('old40'));
    for (const [u, days] of [[old10, 10], [old40, 40]] as const) {
      await s.env.DB.prepare('UPDATE users SET created_at = ?2, last_seen_at = ?2 WHERE id = ?1').bind(u.userId, now - days * DAY).run();
    }
    expect((await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Biokimyo 3-kurs' } })).status).toBe(201);
    expect((await s.call('POST', '/v1/complaints', { token: a.token, body: { kind: 'bug', body: 'Ekran ochilmayapti' } })).status).toBe(201);

    const r = await s.call('GET', '/v1/admin/stats', { token: boss.token });
    expect(r.status).toBe(200);
    const d = r.data;
    expect(d.registered - before.registered).toBe(4);
    expect(d.new_7d - before.new_7d).toBe(2);
    expect(d.new_30d - before.new_30d).toBe(3);
    // Onlayn — so'nggi 5 daqiqada so'rov yuborganlar (a va t; admin avval ham bor edi).
    expect(d.online_now - before.online_now).toBe(2);
    expect(d.by_role.doctor - (before.by_role.doctor ?? 0)).toBe(1);
    expect(d.by_role.teacher - (before.by_role.teacher ?? 0)).toBe(1);
    expect(d.groups.groups - before.groups.groups).toBe(1);
    expect(d.groups.teachers - before.groups.teachers).toBe(1);
    expect(d.complaints.open - before.complaints.open).toBe(1);
    expect(d.new_by_day).toHaveLength(14);
    expect(d.new_by_day[13].n - before.new_by_day[13].n).toBe(2);
    expect(d.new_by_day[3].n - before.new_by_day[3].n).toBe(1); // 10 kun oldin
    expect(d).toHaveProperty('community.questions');
    expect(d).toHaveProperty('groups.assignments');
    expect(d).toHaveProperty('groups.results');
    expect(r.text).not.toMatch(HASH_RE);
    expect(r.text).not.toContain('@');
    expect(r.text).not.toMatch(/billing|plan|pro_until|entitlement/);
  });
});

describe('foydalanuvchilar', () => {
  it("email (HMAC, aniq) va taxallus bo'yicha qidiruv; % va _ ekranlanadi", async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('findme');
    const u = await s.signIn(email, { role: 'lab', language: 'en' });
    const r = await s.call('GET', `/v1/admin/users?email=${encodeURIComponent(`  ${email.toUpperCase()} `)}`, { token: boss.token });
    expect(r.data.total).toBe(1);
    expect(r.data.items[0]).toMatchObject({
      user_id: u.userId,
      email_masked: `${email.slice(0, 2)}***@example.test`,
      role: 'lab',
      status: 'active',
      admin: false,
    });
    expect(r.text).not.toContain(email);
    expect(r.text).not.toMatch(HASH_RE);
    expect((await s.call('GET', `/v1/admin/users?email=${encodeURIComponent(`x${email}`)}`, { token: boss.token })).data.total).toBe(0);
    expect((await s.call('GET', '/v1/admin/users?email=nope', { token: boss.token })).status).toBe(400);

    const t = await s.signInTeacher(uniqueEmail('teacher'));
    const g = await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Gematologiya' } });
    const st = await s.signIn(uniqueEmail('st'));
    const st2 = await s.signIn(uniqueEmail('st2'));
    expect((await s.call('POST', '/v1/groups/join', { token: st.token, body: { code: g.data.join_code, display_name: 'Zarina50' } })).status).toBe(201);
    expect((await s.call('POST', '/v1/groups/join', { token: st2.token, body: { code: g.data.join_code, display_name: 'Bobur' } })).status).toBe(201);
    const byName = await s.call('GET', '/v1/admin/users?name=arin', { token: boss.token });
    expect(byName.data.items.map((x: any) => x.user_id)).toEqual([st.userId]);
    // '%' / '_' — oddiy belgi: hammani sanab chiqib bo'lmaydi.
    for (const q of ['%%', '__', '%_', '\\%']) {
      const all = await s.call('GET', `/v1/admin/users?name=${encodeURIComponent(q)}`, { token: boss.token });
      expect(all.status, q).toBe(200);
      expect(all.data.total, q).toBe(0);
    }
    expect((await s.call('GET', '/v1/admin/users?name=a', { token: boss.token })).status).toBe(400);
    expect((await s.call('GET', '/v1/admin/users?role=admin', { token: boss.token })).status).toBe(400);
  });

  it("rolni o'zgartirish (audit); o'z rolini o'zgartira olmaydi", async () => {
    const { s, boss } = await setup();
    const u = await s.signIn(uniqueEmail('r'), { role: 'student' });
    const r = await s.call('POST', `/v1/admin/users/${u.userId}/role`, { token: boss.token, body: { role: 'teacher' } });
    expect(r.status).toBe(200);
    expect(r.data.role).toBe('teacher');
    expect((await s.call('GET', '/v1/me', { token: u.token })).data.role).toBe('teacher');
    expect((await s.call('POST', `/v1/admin/users/${u.userId}/role`, { token: boss.token, body: { role: 'admin' } })).status).toBe(400);
    const self = await s.call('POST', `/v1/admin/users/${boss.userId}/role`, { token: boss.token, body: { role: 'student' } });
    expect(self.status).toBe(403);
    expect(self.data.error).toBe('self');
    const log = await s.call('GET', '/v1/admin/audit', { token: boss.token });
    expect(log.data.find((e: any) => e.action === 'role_changed')).toMatchObject({ target: u.userId, details: { from: 'student', to: 'teacher' } });
    expect(log.text).not.toMatch(HASH_RE);
  });

  it("to'xtatish: sessiyalar o'chadi, email kodi bilan kirish rad; qayta faollashtirish; adminni to'xtatib bo'lmaydi", async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('bad');
    const u = await s.signIn(email);
    const r = await s.call('POST', `/v1/admin/users/${u.userId}/suspend`, { token: boss.token });
    expect(r.data).toMatchObject({ status: 'suspended' });
    expect((await s.call('GET', '/v1/me', { token: u.token })).status).toBe(401);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM sessions WHERE user_id = ?1').bind(u.userId).first<{ n: number }>();
    expect(n!.n).toBe(0);
    s.clock.now += 61_000;
    await s.call('POST', '/v1/auth/otp/request', { body: { email } });
    const code = s.outbox.filter((m) => m.to === email).at(-1)!.code;
    const v = await s.call('POST', '/v1/auth/otp/verify', { body: { email, code } });
    expect(v.status).toBe(403);
    expect(v.data.error).toBe('account_suspended');
    const list = await s.call('GET', '/v1/admin/users?status=suspended', { token: boss.token });
    expect(list.data.items.map((x: any) => x.user_id)).toContain(u.userId);

    expect((await s.call('POST', `/v1/admin/users/${u.userId}/reactivate`, { token: boss.token })).data.status).toBe('active');
    s.clock.now += 61_000;
    const again = await s.signIn(email);
    expect((await s.call('GET', '/v1/me', { token: again.token })).status).toBe(200);

    const self = await s.call('POST', `/v1/admin/users/${boss.userId}/suspend`, { token: boss.token });
    expect(self.status).toBe(403);
    const log = (await s.call('GET', '/v1/admin/audit', { token: boss.token })).data.map((e: any) => e.action);
    expect(log).toEqual(expect.arrayContaining(['account_suspended', 'account_reactivated']));

    // Boshqa admin (ADMIN_EMAILS) ham to'xtatilmaydi.
    const o1 = uniqueEmail('o1');
    const o2 = uniqueEmail('o2');
    const s2 = makeServer({ ADMIN_EMAILS: `${o1},${o2}`, LG_ADMIN_EMAILS: '' } as never);
    const a2 = await s2.signIn(o2);
    const a1 = await s2.signIn(o1);
    const other = await s2.call('POST', `/v1/admin/users/${a1.userId}/suspend`, { token: a2.token });
    expect(other.status).toBe(403);
    expect(other.data.error).toBe('admin');
  });

  it("hamjamiyatda to'xtatish va tiklash (foydalanuvchi bo'yicha) — audit bilan", async () => {
    const { s, boss } = await setup();
    const t = await s.signIn(uniqueEmail('noisy'));
    expect((await s.call('POST', `/v1/admin/users/${t.userId}/community/suspend`, { token: boss.token })).data.status).toBe('suspended');
    expect((await s.call('GET', '/v1/community/me', { token: t.token })).data.status).toBe('suspended');
    expect((await s.call('POST', `/v1/admin/users/${t.userId}/community/restore`, { token: boss.token })).data.status).toBe('none');
    expect((await s.call('POST', `/v1/admin/users/${t.userId}/community/restore`, { token: boss.token })).status).toBe(409);
    const detail = await s.call('GET', `/v1/admin/users/${t.userId}`, { token: boss.token });
    expect(detail.data).toMatchObject({ user_id: t.userId, community: { status: 'none' }, admin: false, you: false });
    expect(detail.text).not.toMatch(HASH_RE);
    expect(detail.text).not.toMatch(/plan|pro_until/);
  });
});

describe('hamjamiyat shikoyatlari navbati', () => {
  async function reported(s: Server) {
    const author = await s.signIn(uniqueEmail('author'));
    const q = await s.call('POST', '/v1/community/questions', {
      token: author.token,
      body: { title: 'Trombotsitlar soni haqida savol', body: 'Trombotsitlar soni pasayishi nimani bildiradi?' },
    });
    expect(q.status).toBe(201);
    const id = q.data.id as string;
    for (let i = 0; i < 2; i++) {
      const r = await s.signIn(uniqueEmail('reporter'));
      expect((await s.call('POST', '/v1/community/reports', { token: r.token, body: { kind: 'question', id, reason: i ? 'spam' : 'wrong' } })).status).toBe(202);
    }
    return { author, id };
  }

  it("post bo'yicha guruhlangan; rad etish — audit, sanalmaydi; muallifni to'xtatish — hal qilindi", async () => {
    const { s, boss } = await setup();
    const { id } = await reported(s);
    const r = await s.call('GET', '/v1/admin/reports', { token: boss.token });
    expect(r.data.find((x: any) => x.id === id)).toMatchObject({
      kind: 'question',
      status: 'open',
      reports: 2,
      reporters: 2,
      reasons: ['spam', 'wrong'],
      post_deleted: false,
    });
    expect(r.text).not.toMatch(HASH_RE);
    expect((await s.call('POST', `/v1/admin/reports/question/${id}/dismiss`, { token: boss.token })).data).toEqual({ status: 'dismissed', reports: 2 });
    const counted = await s.env.DB.prepare('SELECT SUM(counted) AS n FROM community_reports WHERE target_id = ?1').bind(id).first<{ n: number }>();
    expect(counted!.n).toBe(0);
    expect((await s.call('POST', `/v1/admin/reports/question/${id}/dismiss`, { token: boss.token })).status).toBe(404);
    expect((await s.call('POST', `/v1/admin/reports/question/${encodeURIComponent("x' OR 1=1--")}/resolve`, { token: boss.token })).status).toBe(404);

    const second = await reported(s);
    const sa = await s.call('POST', `/v1/admin/reports/question/${second.id}/suspend-author`, { token: boss.token });
    expect(sa.data).toMatchObject({ status: 'resolved', author_status: 'suspended', reports: 2 });
    expect((await s.call('GET', '/v1/community/me', { token: second.author.token })).data.status).toBe('suspended');
    const log = (await s.call('GET', '/v1/admin/audit', { token: boss.token })).data.map((e: any) => e.action);
    expect(log).toEqual(expect.arrayContaining(['report_dismissed', 'report_resolved', 'community_suspended']));
  });
});
