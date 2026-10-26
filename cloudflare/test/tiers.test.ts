// Reja ↔ panel ajratish (D-74, src/tiers.ts): qaror FAQAT serverdagi huquqdan
// (do'kon / admin grant / sinov), ilovadagi roldan emas. Bayroq o'chiq — 404.
import { describe, expect, it } from 'vitest';
import { type Plan, PLANS } from '../src/billing';
import { accessCapabilities, CAPABILITIES, type Capability, TIER_CAPABILITIES, tierAllows } from '../src/tiers';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
const makeServer = (o: Record<string, string> = {}) => baseServer({ LG_BILLING_ENABLED: 'true', ...o } as never);
type Srv = ReturnType<typeof makeServer>;

const check = (s: Srv, token: string | undefined, cap: string) => s.call('GET', `/v1/pro/check/${cap}`, { token });

async function buy(s: Srv, userId: string, product: string, days = 30) {
  await s.env.DB.prepare(
    `INSERT INTO entitlements (platform, original_transaction_id, user_id, product_id, status, started_at, expires_at,
       latest_token, event_at, updated_at) VALUES ('play_store', ?1, ?2, ?3, 'active', ?4, ?5, 't', ?4, ?4)`,
  )
    .bind(`tx-${crypto.randomUUID()}`, userId, product, s.clock.now, s.clock.now + days * DAY)
    .run();
}

describe('matritsa (MA’LUMOT, D-76)', () => {
  it('to‘rt reja: Ustoz = Talaba + panel; Mutaxassis = Talaba + Lab (panelsiz); Premium = hammasi', () => {
    expect(TIER_CAPABILITIES).toEqual({
      student: ['learner'],
      teacher: ['learner', 'teacher_panel'],
      specialist: ['learner', 'lab'],
      premium: ['learner', 'teacher_panel', 'lab'],
    });
    expect(CAPABILITIES).toEqual(['learner', 'teacher_panel', 'lab']);
    expect(PLANS).toEqual(['student', 'teacher', 'specialist', 'premium']);
    for (const p of PLANS) for (const c of TIER_CAPABILITIES[p]) expect(CAPABILITIES).toContain(c);
  });

  it('har reja × imkoniyat: ruxsat / rad (jadval)', () => {
    const want: Record<Plan, Record<Capability, boolean>> = {
      student: { learner: true, teacher_panel: false, lab: false },
      teacher: { learner: true, teacher_panel: true, lab: false },
      specialist: { learner: true, teacher_panel: false, lab: true },
      premium: { learner: true, teacher_panel: true, lab: true },
    };
    for (const p of PLANS) for (const c of CAPABILITIES) expect(tierAllows(p, c), `${p} × ${c}`).toBe(want[p][c]);
    for (const c of CAPABILITIES) expect(tierAllows(null, c)).toBe(false);
  });

  it('birlashma: bir nechta amaldagi qator imkoniyatlari qo‘shiladi; muddati o‘tgani va obuna yonidagi sinov sanalmaydi', () => {
    const now = 1_000_000;
    const item = (source: 'store' | 'admin_grant' | 'trial', plan: Plan, expiresAt: number | null, granting = true) => ({
      source,
      plan,
      granting,
      expiresAt,
    });
    expect(accessCapabilities([item('store', 'teacher', now + 5), item('admin_grant', 'specialist', null)], now)).toEqual([
      'learner',
      'teacher_panel',
      'lab',
    ]);
    expect(accessCapabilities([item('store', 'teacher', now + 5), item('admin_grant', 'specialist', now - 1)], now)).toEqual([
      'learner',
      'teacher_panel',
    ]);
    // Do'kon obunasi bor — sinov qatori hisobga olinmaydi.
    expect(accessCapabilities([item('store', 'student', now + 5), item('trial', 'premium', now + 5)], now)).toEqual(['learner']);
    expect(accessCapabilities([item('store', 'premium', now + 5, false)], now)).toEqual([]);
  });
});

describe('requireTier: bayroq o‘chiq', () => {
  it('/v1/pro/* — 404 (tokenli ham)', async () => {
    const s = baseServer();
    const u = await s.signIn(uniqueEmail('off'));
    for (const p of ['/v1/pro/access', '/v1/pro/check/learner', '/v1/pro/check/teacher_panel', '/v1/pro/check/lab']) {
      for (const token of [undefined, u.token]) expect((await s.call('GET', p, { token })).status, p).toBe(404);
    }
  });
});

describe('requireTier: serverdagi daraja', () => {
  it('tokensiz 401; rejasiz 403 plan_required; noma’lum imkoniyat 404', async () => {
    const s = makeServer();
    expect((await check(s, undefined, 'learner')).status).toBe(401);
    const u = await s.signIn(uniqueEmail('free'));
    const r = await check(s, u.token, 'learner');
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('plan_required');
    expect((await check(s, u.token, 'gold')).status).toBe(404);
    // Eski (D-74) `specialist` imkoniyati endi yo'q (D-76: `lab`).
    expect((await check(s, u.token, 'specialist')).status).toBe(404);
    for (const c of ['teacher_panel', 'lab']) expect((await check(s, u.token, c)).data.error, c).toBe('plan_required');
    expect((await s.call('GET', '/v1/pro/access', { token: u.token })).data).toEqual({
      plan: null,
      source: null,
      expires_at: null,
      capabilities: [],
    });
  });

  it('Talaba rejasi: learner — ha; ustoz paneli — 403 tier_insufficient, hatto profil roli “teacher” va teacher_accounts bo‘lsa ham', async () => {
    const s = makeServer();
    const u = await s.signInTeacher(uniqueEmail('stud')); // rol teacher + serverda ustoz
    await buy(s, u.userId, 'uz.labguide.student.monthly');
    expect((await check(s, u.token, 'learner')).status).toBe(200);
    const t = await check(s, u.token, 'teacher_panel');
    expect(t.status).toBe(403);
    expect(t.data).toMatchObject({ error: 'tier_insufficient', capability: 'teacher_panel', plan: 'student' });
    const lab = await check(s, u.token, 'lab');
    expect(lab.status).toBe(403);
    expect(lab.data).toMatchObject({ error: 'tier_insufficient', capability: 'lab', plan: 'student' });
    // Rolni ilovada almashtirish hech narsa bermaydi.
    for (const role of ['teacher', 'doctor', 'lab']) {
      await s.call('PUT', '/v1/me/profile', { token: u.token, body: { role } });
      expect((await check(s, u.token, 'teacher_panel')).status, role).toBe(403);
      expect((await check(s, u.token, 'lab')).status, role).toBe(403);
    }
    expect((await s.call('GET', '/v1/pro/access', { token: u.token })).data).toMatchObject({
      plan: 'student',
      source: 'store',
      capabilities: ['learner'],
    });
  });

  it('Ustoz rejasi: teacher_panel — ha (serverda ustoz bo‘lsa); ustoz ro‘yxatisiz — 403 teacher_role_required; lab — 403 tier_insufficient', async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('teach'));
    await buy(s, t.userId, 'uz.labguide.teacher.yearly', 365);
    const ok = await check(s, t.token, 'teacher_panel');
    expect(ok.status).toBe(200);
    expect(ok.data).toEqual({ allowed: true, capability: 'teacher_panel', plan: 'teacher', source: 'store' });
    expect((await check(s, t.token, 'learner')).status).toBe(200);
    const lab = await check(s, t.token, 'lab');
    expect(lab.status).toBe(403);
    expect(lab.data).toMatchObject({ error: 'tier_insufficient', capability: 'lab', plan: 'teacher' });

    const n = await s.signIn(uniqueEmail('teach-noreg'));
    await buy(s, n.userId, 'uz.labguide.teacher.monthly');
    const r = await check(s, n.token, 'teacher_panel');
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('teacher_role_required');
  });

  it('Mutaxassis rejasi: learner + lab; ustoz paneli — 403 tier_insufficient (serverda ustoz va rol “teacher” bo‘lsa ham)', async () => {
    const s = makeServer();
    const u = await s.signInTeacher(uniqueEmail('spec'));
    await buy(s, u.userId, 'uz.labguide.specialist.monthly');
    for (const c of ['learner', 'lab']) expect((await check(s, u.token, c)).status, c).toBe(200);
    const t = await check(s, u.token, 'teacher_panel');
    expect(t.status).toBe(403);
    expect(t.data).toMatchObject({ error: 'tier_insufficient', capability: 'teacher_panel', plan: 'specialist' });
    expect((await s.call('GET', '/v1/pro/access', { token: u.token })).data).toMatchObject({
      plan: 'specialist',
      capabilities: ['learner', 'lab'],
    });
  });

  it('Premium rejasi: hammasi (ustoz paneli — serverda ustoz bo‘lsa)', async () => {
    const s = makeServer();
    const u = await s.signInTeacher(uniqueEmail('prem'));
    await buy(s, u.userId, 'uz.labguide.premium.yearly', 365);
    for (const c of ['learner', 'teacher_panel', 'lab']) {
      const r = await check(s, u.token, c);
      expect(r.status, c).toBe(200);
      expect(r.data).toMatchObject({ allowed: true, capability: c, plan: 'premium', source: 'store' });
    }
    expect((await s.call('GET', '/v1/pro/access', { token: u.token })).data).toMatchObject({
      plan: 'premium',
      capabilities: ['learner', 'teacher_panel', 'lab'],
    });
    const n = await s.signIn(uniqueEmail('prem-noreg'));
    await buy(s, n.userId, 'uz.labguide.premium.monthly');
    expect((await check(s, n.token, 'lab')).status).toBe(200);
    expect((await check(s, n.token, 'teacher_panel')).data.error).toBe('teacher_role_required');
  });

  it('Ustoz obunasi + Mutaxassis admin granti: ikkala to‘plam ham (eng qimmati boshqasini yo‘qotmaydi)', async () => {
    const owner = uniqueEmail('owner-mix');
    const s = makeServer({ LG_ADMIN_EMAILS: owner });
    const boss = await s.signInAdmin(owner);
    const email = uniqueEmail('mix');
    const u = await s.signInTeacher(email);
    await buy(s, u.userId, 'uz.labguide.teacher.monthly');
    const g = await s.call('POST', '/v1/admin/pro-grants', { token: boss.token, body: { email, tier: 'specialist', durationDays: 30 } });
    expect(g.status).toBe(201);
    for (const c of ['learner', 'teacher_panel', 'lab']) expect((await check(s, u.token, c)).status, c).toBe(200);
    expect((await s.call('GET', '/v1/pro/access', { token: u.token })).data.capabilities).toEqual(['learner', 'teacher_panel', 'lab']);
  });

  it('muddati o‘tgan obuna — 403 plan_required', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail('exp'));
    await buy(s, u.userId, 'uz.labguide.specialist.monthly', 1);
    expect((await check(s, u.token, 'learner')).status).toBe(200);
    s.clock.now += 2 * DAY;
    expect((await check(s, u.token, 'learner')).data.error).toBe('plan_required');
  });
});

describe('requireTier: admin grant darajalarni hurmat qiladi', () => {
  it('admin Talaba bergan — ustoz paneli yo‘q; Ustoz bergan — bor', async () => {
    const owner = uniqueEmail('owner');
    const s = makeServer({ LG_ADMIN_EMAILS: owner });
    const boss = await s.signInAdmin(owner);
    const email = uniqueEmail('granted');
    const u = await s.signInTeacher(email);
    const g = await s.call('POST', '/v1/admin/pro-grants', { token: boss.token, body: { email, tier: 'student', durationDays: 30 } });
    expect(g.status).toBe(201);
    expect((await check(s, u.token, 'learner')).data).toMatchObject({ allowed: true, source: 'admin_grant' });
    expect((await check(s, u.token, 'teacher_panel')).data.error).toBe('tier_insufficient');

    const up = await s.call('POST', '/v1/admin/pro-grants', { token: boss.token, body: { email, tier: 'teacher', durationDays: 30 } });
    expect(up.status).toBe(200);
    expect((await check(s, u.token, 'teacher_panel')).status).toBe(200);
    expect((await check(s, u.token, 'lab')).data.error).toBe('tier_insufficient');

    // Mutaxassis granti (almashtirish) — Lab bor, ustoz paneli yo'q.
    const sp = await s.call('POST', '/v1/admin/pro-grants', {
      token: boss.token,
      body: { email, tier: 'specialist', durationDays: 30, mode: 'replace' },
    });
    expect(sp.status).toBe(200);
    expect((await check(s, u.token, 'lab')).status).toBe(200);
    expect((await check(s, u.token, 'teacher_panel')).data.error).toBe('tier_insufficient');

    // Premium granti — hammasi.
    const pr = await s.call('POST', '/v1/admin/pro-grants', {
      token: boss.token,
      body: { email, tier: 'premium', durationDays: 30, mode: 'replace' },
    });
    expect(pr.status).toBe(200);
    for (const c of ['learner', 'teacher_panel', 'lab']) expect((await check(s, u.token, c)).status, c).toBe(200);
  });
});

describe('bepul ustoz paneli o‘zgarmadi', () => {
  it('bayroq yoqilgan, rejasiz ustoz guruh ocha oladi (bepul qoladi)', async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('free-teacher'));
    const g = await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Guruh A1' } });
    expect(g.status).toBe(201);
  });
});

describe('egasi (super admin): muddatsiz Premium (D-78 qo‘shimcha)', () => {
  it('ADMIN_EMAILS dagi hisob — Premium (admin_grant, muddatsiz); boshqa hisob — yo‘q; ro‘yxatdan chiqsa darhol yo‘qoladi', async () => {
    const s = makeServer({ ADMIN_EMAILS: 'boss@example.test' } as never);
    const boss = await s.signIn('boss@example.test');
    const acc = await s.call('GET', '/v1/pro/access', { token: boss.token });
    expect(acc.data).toMatchObject({
      plan: 'premium',
      source: 'admin_grant',
      expires_at: null,
      capabilities: ['learner', 'teacher_panel', 'lab'],
    });
    expect((await check(s, boss.token, 'lab')).status).toBe(200);
    const snap = await s.call('GET', '/v1/billing/entitlements', { token: boss.token });
    expect(snap.data.items).toContainEqual(
      expect.objectContaining({ source: 'admin_grant', plan: 'premium', status: 'active', expires_at: null }),
    );
    const other = await s.signIn(uniqueEmail('plain'));
    expect((await check(s, other.token, 'learner')).data.error).toBe('plan_required');
    // Ro'yxatdan chiqarilgan email — Premium yo'q.
    s.env.ADMIN_EMAILS = 'someone.else@example.test';
    expect((await check(s, boss.token, 'learner')).data.error).toBe('plan_required');
  });
});
