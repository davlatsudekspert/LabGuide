// Reja ↔ panel ajratish (D-74, src/tiers.ts): qaror FAQAT serverdagi huquqdan
// (do'kon / admin grant / sinov), ilovadagi roldan emas. Bayroq o'chiq — 404.
import { describe, expect, it } from 'vitest';
import { PLANS } from '../src/billing';
import { CAPABILITIES, TIER_CAPABILITIES, tierAllows } from '../src/tiers';
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

describe('matritsa (MA’LUMOT)', () => {
  it('Talaba ⊂ Ustoz ⊂ Mutaxassis; Talaba ustoz panelini ochmaydi', () => {
    expect(TIER_CAPABILITIES).toEqual({
      student: ['learner'],
      teacher: ['learner', 'teacher_panel'],
      specialist: ['learner', 'teacher_panel', 'specialist'],
    });
    expect(tierAllows('student', 'teacher_panel')).toBe(false);
    expect(tierAllows('student', 'specialist')).toBe(false);
    expect(tierAllows('teacher', 'specialist')).toBe(false);
    expect(tierAllows(null, 'learner')).toBe(false);
    for (const p of PLANS) for (const c of TIER_CAPABILITIES[p]) expect(CAPABILITIES).toContain(c);
  });
});

describe('requireTier: bayroq o‘chiq', () => {
  it('/v1/pro/* — 404 (tokenli ham)', async () => {
    const s = baseServer();
    const u = await s.signIn(uniqueEmail('off'));
    for (const p of ['/v1/pro/access', '/v1/pro/check/learner', '/v1/pro/check/teacher_panel']) {
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
    expect((await check(s, u.token, 'specialist')).data.error).toBe('tier_insufficient');
    // Rolni ilovada almashtirish hech narsa bermaydi.
    for (const role of ['teacher', 'doctor', 'lab']) {
      await s.call('PUT', '/v1/me/profile', { token: u.token, body: { role } });
      expect((await check(s, u.token, 'teacher_panel')).status, role).toBe(403);
    }
    expect((await s.call('GET', '/v1/pro/access', { token: u.token })).data).toMatchObject({
      plan: 'student',
      source: 'store',
      capabilities: ['learner'],
    });
  });

  it('Ustoz rejasi: teacher_panel — ha (serverda ustoz bo‘lsa); ustoz ro‘yxatisiz — 403 teacher_role_required; specialist — yo‘q', async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('teach'));
    await buy(s, t.userId, 'uz.labguide.teacher.yearly', 365);
    const ok = await check(s, t.token, 'teacher_panel');
    expect(ok.status).toBe(200);
    expect(ok.data).toEqual({ allowed: true, capability: 'teacher_panel', plan: 'teacher', source: 'store' });
    expect((await check(s, t.token, 'learner')).status).toBe(200);
    expect((await check(s, t.token, 'specialist')).status).toBe(403);

    const n = await s.signIn(uniqueEmail('teach-noreg'));
    await buy(s, n.userId, 'uz.labguide.teacher.monthly');
    const r = await check(s, n.token, 'teacher_panel');
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('teacher_role_required');
  });

  it('Mutaxassis rejasi: matritsa bo‘yicha hammasi (D-73: ustoz imkoniyatlari ham)', async () => {
    const s = makeServer();
    const u = await s.signInTeacher(uniqueEmail('spec'));
    await buy(s, u.userId, 'uz.labguide.specialist.monthly');
    for (const c of ['learner', 'teacher_panel', 'specialist']) expect((await check(s, u.token, c)).status, c).toBe(200);
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
    expect((await check(s, u.token, 'specialist')).status).toBe(403);
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
