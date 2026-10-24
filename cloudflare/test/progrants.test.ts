// Admin tomonidan Pro berish (D-73, src/progrants.ts). Hamma yo'l
// LG_BILLING_ENABLED=true bo'lmasa 404; vakolat — admin roli + TOTP (aal2).
import { describe, expect, it } from 'vitest';
import { GRANT_PER_HOUR } from '../src/progrants';
import { BILLING_PRODUCTS, resolveAccess } from '../src/billing';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
const makeServer = (o: Parameters<typeof baseServer>[0] = {}) =>
  baseServer({ LG_BILLING_ENABLED: 'true', ...o } as never);

async function setup() {
  const owner = uniqueEmail('owner');
  const s = makeServer({ LG_ADMIN_EMAILS: owner });
  const boss = await s.signInAdmin(owner);
  return { s, owner, boss };
}

type Srv = ReturnType<typeof makeServer>;
const grant = (s: Srv, token: string, body: Record<string, unknown>) =>
  s.call('POST', '/v1/admin/pro-grants', { token, body });
const list = (s: Srv, token: string) => s.call('GET', '/v1/admin/pro-grants', { token });
const ents = (s: Srv, token: string) => s.call('GET', '/v1/billing/entitlements', { token });
/** Umumiy D1: faqat shu testning grantlari (id bo'yicha). */
const mine = async (s: Srv, token: string, ...ids: string[]) =>
  ((await list(s, token)).data.grants as { id: string }[]).filter((g) => ids.includes(g.id));
const audits = async (s: Srv, action: string, ...targets: string[]) =>
  (
    await s.env.DB.prepare('SELECT actor, target, details FROM audit_log WHERE action = ?1 ORDER BY id')
      .bind(action)
      .all<{ actor: string | null; target: string; details: string }>()
  ).results
    .filter((r) => targets.includes(r.target))
    .map((r) => ({ ...r, details: JSON.parse(r.details) }));

describe('admin grant: bayroq o‘chiq — hamma yo‘l 404 (D-73)', () => {
  it('LG_BILLING_ENABLED yo‘q: admin tokeni bilan ham, tokensiz ham 404', async () => {
    const owner = uniqueEmail('owner');
    const s = baseServer({ LG_ADMIN_EMAILS: owner });
    const boss = await s.signInAdmin(owner);
    const id = '00000000-0000-4000-8000-000000000000';
    for (const [m, p] of [
      ['GET', '/v1/admin/pro-grants'],
      ['POST', '/v1/admin/pro-grants'],
      ['DELETE', `/v1/admin/pro-grants/${id}`],
    ] as const) {
      for (const token of [undefined, boss.token]) {
        const r = await s.call(m, p, { token, body: m === 'POST' ? { email: 'a@b.co', tier: 'student' } : undefined });
        expect(r.status, `${m} ${p} ${token ? 'admin' : 'anon'}`).toBe(404);
      }
    }
    // Bayroq o'chiq bo'lsa kirish va /v1/admin ning boshqa yo'llari o'zgarmaydi.
    expect((await s.call('GET', '/v1/admin/admins', { token: boss.token })).status).toBe(200);
  });
});

describe('admin grant: vakolat', () => {
  it('tokensiz 401; oddiy foydalanuvchi 403; TOTP siz admin 403', async () => {
    const { s, owner } = await setup();
    const body = { email: uniqueEmail('t'), tier: 'student' };
    expect((await grant(s, '', body)).status).toBe(401);
    const user = await s.signIn(uniqueEmail('plain'));
    expect((await grant(s, user.token, body)).status).toBe(403);
    expect((await list(s, user.token)).status).toBe(403);
    expect((await s.call('DELETE', '/v1/admin/pro-grants/00000000-0000-4000-8000-000000000000', { token: user.token })).status).toBe(403);
    // Allowlistdagi egasi, lekin faqat email kodi (aal1) — MFA yo'q.
    const noMfa = await s.signIn(owner);
    expect((await grant(s, noMfa.token, body)).status).toBe(403);
    expect((await list(s, noMfa.token)).status).toBe(403);
    expect((await ents(s, user.token)).data.items).toEqual([]);
  });
});

describe('admin grant: tekshiruv', () => {
  it('noto‘g‘ri email / daraja / muddat / izoh / rejim — 400, hech narsa yozilmaydi', async () => {
    const { s, boss } = await setup();
    const ok = { email: uniqueEmail('v'), tier: 'teacher' };
    const bad: Record<string, unknown>[] = [
      { ...ok, email: 'not-an-email' },
      { ...ok, email: 42 },
      { ...ok, email: undefined },
      { ...ok, tier: 'pro' },
      { ...ok, tier: undefined },
      { ...ok, durationDays: 7 },
      { ...ok, durationDays: '30' },
      { ...ok, durationDays: 0 },
      { ...ok, note: 'x'.repeat(201) },
      { ...ok, note: 'a\u0000b' },
      { ...ok, note: 5 },
      { ...ok, mode: 'merge' },
    ];
    for (const b of bad) {
      const r = await grant(s, boss.token, b);
      expect(r.status, JSON.stringify(b)).toBe(400);
    }
    for (const days of [30, 90, 365, null]) {
      expect((await grant(s, boss.token, { email: uniqueEmail('d'), tier: 'student', durationDays: days })).status).toBe(201);
    }
  });

  it('email normallashtiriladi (trim + kichik harf); javobda faqat niqob', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('Case');
    const r = await grant(s, boss.token, { email: `  ${email.toUpperCase()} `, tier: 'student', note: ' izoh ' });
    expect(r.status).toBe(201);
    expect(r.data).toMatchObject({ email_masked: `${email.slice(0, 2).toLowerCase()}***@example.test`, status: 'pending', note: 'izoh' });
    expect(r.text.toLowerCase()).not.toContain(email.toLowerCase());
    // Boshqa registrda qayta berish — o'sha grant (bitta faol).
    const again = await grant(s, boss.token, { email, tier: 'student' });
    expect(again.status).toBe(200);
    expect(again.data.replaced).toBe(true);
    expect(again.data.id).toBe(r.data.id);
    expect(await mine(s, boss.token, r.data.id)).toHaveLength(1);
  });
});

describe('admin grant: kutilayotgan (hisob yo‘q) → hisob ochilganda qo‘llanadi', () => {
  it('pending → kirishda faol, muddat kirish paytidan', async () => {
    const { s, owner, boss } = await setup();
    const email = uniqueEmail('later');
    const g = await grant(s, boss.token, { email, tier: 'specialist', durationDays: 30 });
    expect(g.status).toBe(201);
    expect(g.data).toMatchObject({ status: 'pending', starts_at: null, expires_at: null, duration_days: 30 });
    expect((await mine(s, boss.token, g.data.id))[0]).toMatchObject({ status: 'pending' });

    s.clock.now += 10 * DAY;
    const u = await s.signIn(email);
    const e = await ents(s, u.token);
    expect(e.status).toBe(200);
    expect(e.data.items).toHaveLength(1);
    expect(e.data.items[0]).toMatchObject({ source: 'admin_grant', platform: 'admin_grant', plan: 'specialist', status: 'active', ownership: 'granted' });
    expect(Date.parse(e.data.items[0].expires_at)).toBe(s.clock.now + 30 * DAY);
    expect(e.data.resolved).toMatchObject({ source: 'admin_grant', plan: 'specialist' });
    // Admin oynasi (12 soat / 30 daqiqa, 0013_admin_step_up) yopildi — egasi qayta kiradi.
    boss.token = (await s.signInAdmin(owner)).token;
    expect((await mine(s, boss.token, g.data.id))[0]).toMatchObject({ status: 'active' });
    const applied = await audits(s, 'pro_grant_applied', g.data.id);
    expect(applied).toHaveLength(1);
    expect(applied[0]).toMatchObject({ actor: null, target: g.data.id });
    expect(applied[0].details).toMatchObject({ tier: 'specialist', target_user: u.userId });
  });

  it('hisob bor bo‘lsa — darhol faol; eski sessiya ham ko‘radi', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('now');
    const u = await s.signIn(email);
    expect((await ents(s, u.token)).data.resolved).toBeNull();
    const g = await grant(s, boss.token, { email, tier: 'teacher', durationDays: 90 });
    expect(g.data).toMatchObject({ status: 'active' });
    expect(Date.parse(g.data.expires_at)).toBe(s.clock.now + 90 * DAY);
    expect((await ents(s, u.token)).data.resolved).toMatchObject({ source: 'admin_grant', plan: 'teacher' });
  });

  it('muddatsiz (bekor qilinguncha) grant: expires_at yo‘q, hech qachon tugamaydi', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('forever');
    await s.signIn(email);
    await grant(s, boss.token, { email, tier: 'student' });
    s.clock.now += 3000 * DAY;
    const e = await ents(s, (await s.signIn(email)).token);
    expect(e.data.items[0]).toMatchObject({ status: 'active', expires_at: null });
    expect(e.data.resolved).toMatchObject({ source: 'admin_grant', plan: 'student', expires_at: null });
  });
});

describe('admin grant: muddat va bekor qilish', () => {
  it('muddat tugasa huquq yo‘qoladi (resolved null), ro‘yxatdan tushadi', async () => {
    const { s, owner, boss } = await setup();
    const email = uniqueEmail('exp');
    const u = await s.signIn(email);
    const g = await grant(s, boss.token, { email, tier: 'student', durationDays: 30 });
    s.clock.now += 29 * DAY;
    expect((await ents(s, u.token)).data.resolved).toMatchObject({ plan: 'student' });
    s.clock.now += 2 * DAY;
    const e = await ents(s, u.token);
    expect(e.data.items[0].status).toBe('expired');
    expect(e.data.resolved).toBeNull();
    // Admin oynasi (12 soat / 30 daqiqa, 0013_admin_step_up) yopildi — egasi qayta kiradi.
    boss.token = (await s.signInAdmin(owner)).token;
    expect(await mine(s, boss.token, g.data.id)).toEqual([]);
  });

  it('bekor qilish: huquq darhol yo‘qoladi; qayta bekor — 404; audit', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('rev');
    const u = await s.signIn(email);
    const g = await grant(s, boss.token, { email, tier: 'teacher', durationDays: 365 });
    expect((await ents(s, u.token)).data.resolved).not.toBeNull();
    const del = await s.call('DELETE', `/v1/admin/pro-grants/${g.data.id}`, { token: boss.token });
    expect(del.status).toBe(204);
    const e = await ents(s, u.token);
    expect(e.data.items).toEqual([]);
    expect(e.data.resolved).toBeNull();
    expect(await mine(s, boss.token, g.data.id)).toEqual([]);
    expect((await s.call('DELETE', `/v1/admin/pro-grants/${g.data.id}`, { token: boss.token })).status).toBe(404);
    expect((await s.call('DELETE', '/v1/admin/pro-grants/not-a-uuid', { token: boss.token })).status).toBe(404);
    const rev = await audits(s, 'pro_grant_revoked', g.data.id);
    expect(rev).toHaveLength(1);
    expect(rev[0]).toMatchObject({ actor: boss.userId, target: g.data.id });
    expect(rev[0].details).toMatchObject({ tier: 'teacher', target_user: u.userId });
    // Bekor qilingach yangi grant berish mumkin.
    expect((await grant(s, boss.token, { email, tier: 'student' })).status).toBe(201);
  });

  it('kutilayotgan grantni bekor qilish — hisob ochilganda hech narsa qo‘llanmaydi', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('pendrev');
    const g = await grant(s, boss.token, { email, tier: 'student', durationDays: 30 });
    expect((await s.call('DELETE', `/v1/admin/pro-grants/${g.data.id}`, { token: boss.token })).status).toBe(204);
    const u = await s.signIn(email);
    expect((await ents(s, u.token)).data.items).toEqual([]);
    expect(await audits(s, 'pro_grant_applied', g.data.id)).toHaveLength(0);
  });
});

describe('admin grant: qayta berish (idempotent) va uzaytirish', () => {
  it('replace: bitta faol qator, yangi daraja/muddat hozirdan; audit pro_grant_replaced', async () => {
    const { s, owner, boss } = await setup();
    const email = uniqueEmail('re');
    const u = await s.signIn(email);
    const a = await grant(s, boss.token, { email, tier: 'student', durationDays: 30 });
    expect(a.status).toBe(201);
    s.clock.now += 5 * DAY;
    // Admin oynasi (12 soat / 30 daqiqa, 0013_admin_step_up) yopildi — egasi qayta kiradi.
    boss.token = (await s.signInAdmin(owner)).token;
    const b = await grant(s, boss.token, { email, tier: 'teacher', durationDays: 90 });
    expect(b.status).toBe(200);
    expect(b.data).toMatchObject({ id: a.data.id, tier: 'teacher', replaced: true, extended: false });
    expect(Date.parse(b.data.expires_at)).toBe(s.clock.now + 90 * DAY);
    // Bir xil so'rovni takrorlash holatni buzmaydi.
    const c = await grant(s, boss.token, { email, tier: 'teacher', durationDays: 90 });
    expect(c.data).toMatchObject({ id: a.data.id, tier: 'teacher', status: 'active' });
    expect(await mine(s, boss.token, a.data.id)).toHaveLength(1);
    expect((await ents(s, u.token)).data.items).toHaveLength(1);
    const rep = await audits(s, 'pro_grant_replaced', a.data.id);
    expect(rep).toHaveLength(2);
    expect(rep[0].details).toMatchObject({ previous_tier: 'student', tier: 'teacher' });
  });

  it('extend: muddat mavjud tugashidan uzayadi, daraja yuqorisi qoladi; pending/muddatsiz qoidalari', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('ext');
    await s.signIn(email);
    const a = await grant(s, boss.token, { email, tier: 'specialist', durationDays: 30 });
    const end = Date.parse(a.data.expires_at);
    const b = await grant(s, boss.token, { email, tier: 'student', durationDays: 90, mode: 'extend' });
    expect(b.status).toBe(200);
    expect(b.data).toMatchObject({ tier: 'specialist', extended: true, replaced: false });
    expect(Date.parse(b.data.expires_at)).toBe(end + 90 * DAY);
    expect((await grant(s, boss.token, { email, tier: 'student', mode: 'extend' })).data.error).toBe('duration_required');
    expect((await audits(s, 'pro_grant_extended', a.data.id))[0].details).toMatchObject({ added_days: 90, tier: 'specialist' });

    const p = uniqueEmail('extpend');
    await grant(s, boss.token, { email: p, tier: 'student', durationDays: 30 });
    const r = await grant(s, boss.token, { email: p, tier: 'student', durationDays: 30, mode: 'extend' });
    expect(r.status).toBe(409);
    expect(r.data.error).toBe('pending_cannot_extend');

    const f = uniqueEmail('extfor');
    await s.signIn(f);
    await grant(s, boss.token, { email: f, tier: 'student' });
    const fe = await grant(s, boss.token, { email: f, tier: 'teacher', durationDays: 30, mode: 'extend' });
    expect(fe.data).toMatchObject({ tier: 'teacher', expires_at: null });
  });
});

describe('admin grant: audit va chegaralar', () => {
  it('berish audit_log ga yoziladi: kim, kimga (niqob), daraja, muddat', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('aud');
    const u = await s.signIn(email);
    const g = await grant(s, boss.token, { email, tier: 'teacher', durationDays: 30, note: 'konferensiya' });
    const rows = await audits(s, 'pro_grant_created', g.data.id);
    expect(rows).toHaveLength(1);
    expect(rows[0]).toMatchObject({ actor: boss.userId, target: g.data.id });
    expect(rows[0].details).toMatchObject({
      email: g.data.email_masked,
      tier: 'teacher',
      until: g.data.expires_at,
      pending: false,
      target_user: u.userId,
    });
    expect(JSON.stringify(rows[0])).not.toContain(email);
    expect(JSON.stringify(rows[0])).not.toContain('konferensiya'); // izoh jurnalga ochiq yozilmaydi
  });

  it(`berish limiti: soatiga ${GRANT_PER_HOUR} ta, keyin 429`, async () => {
    const { s, boss } = await setup();
    let last = 0;
    for (let i = 0; i < GRANT_PER_HOUR + 1; i++) {
      last = (await grant(s, boss.token, { email: uniqueEmail('rl'), tier: 'student', durationDays: 30 })).status;
    }
    expect(last).toBe(429);
  });

  it('o‘chirilgan hisob: grant ham o‘chadi', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('gone');
    const u = await s.signIn(email);
    const g = await grant(s, boss.token, { email, tier: 'student', durationDays: 30 });
    expect((await s.call('DELETE', '/v1/me', { token: u.token })).status).toBe(204);
    expect(await mine(s, boss.token, g.data.id)).toEqual([]);
  });
});

describe('huquqni hal qilish: do‘kon obunasini bosib o‘tmaydi', () => {
  const store = (plan: 'student' | 'teacher' | 'specialist', exp: number | null, granting = true) => ({
    source: 'store' as const, plan, granting, expiresAt: exp,
  });
  const adm = (plan: 'student' | 'teacher' | 'specialist', exp: number | null) => ({
    source: 'admin_grant' as const, plan, granting: true, expiresAt: exp,
  });
  const now = 1_000_000;

  it('yuqori daraja yutadi; teng darajada uzoqroq muddat; to‘liq tenglikda do‘kon', () => {
    expect(resolveAccess([store('student', now + 10), adm('teacher', now + 5)], now)).toMatchObject({ source: 'admin_grant', plan: 'teacher' });
    expect(resolveAccess([store('specialist', now + 10), adm('teacher', null)], now)).toMatchObject({ source: 'store', plan: 'specialist' });
    expect(resolveAccess([store('teacher', now + 10), adm('teacher', now + 99)], now)).toMatchObject({ source: 'admin_grant' });
    expect(resolveAccess([store('teacher', now + 99), adm('teacher', now + 10)], now)).toMatchObject({ source: 'store' });
    expect(resolveAccess([store('teacher', now + 10), adm('teacher', now + 10)], now)).toMatchObject({ source: 'store' });
    expect(resolveAccess([store('teacher', now + 10), adm('teacher', null)], now)).toMatchObject({ source: 'admin_grant', expiresAt: null });
  });

  it('muddati o‘tgan yoki huquq bermaydigan qator hisobga olinmaydi', () => {
    expect(resolveAccess([store('specialist', now - 1), adm('student', now + 5)], now)).toMatchObject({ source: 'admin_grant', plan: 'student' });
    expect(resolveAccess([store('specialist', now + 5, false)], now)).toBeNull();
    expect(resolveAccess([], now)).toBeNull();
  });

  it('server javobi: do‘kon va grant ikkalasi qator sifatida, resolved — yuqorisi', async () => {
    const { s, boss } = await setup();
    const email = uniqueEmail('both');
    const u = await s.signIn(email);
    await s.env.DB.prepare(
      `INSERT INTO entitlements (platform, original_transaction_id, user_id, product_id, status, started_at, expires_at,
         latest_token, event_at, updated_at) VALUES ('app_store', ?1, ?2, 'uz.labguide.specialist.monthly', 'active', ?3, ?4, 't', ?3, ?3)`,
    ).bind(`tx-${u.userId}`, u.userId, s.clock.now - DAY, s.clock.now + 20 * DAY).run();
    const g = await grant(s, boss.token, { email, tier: 'student', durationDays: 365 });
    const e = await ents(s, u.token);
    expect(e.data.items.map((i: any) => i.source).sort()).toEqual(['admin_grant', 'store']);
    expect(e.data.resolved).toMatchObject({ source: 'store', plan: 'specialist' });
    // Grant bekor qilinsa do'kon obunasi saqlanadi.
    const id = g.data.id;
    await s.call('DELETE', `/v1/admin/pro-grants/${id}`, { token: boss.token });
    const e2 = await ents(s, u.token);
    expect(e2.data.items).toHaveLength(1);
    expect(e2.data.resolved).toMatchObject({ source: 'store' });
  });
});

describe('mahsulot id lari (D-73)', () => {
  it('uch daraja x oy/yil; eski id lar mos darajaga alias', () => {
    for (const plan of ['student', 'teacher', 'specialist']) {
      for (const period of ['monthly', 'yearly']) {
        expect(BILLING_PRODUCTS[`uz.labguide.${plan}.${period}`]?.plan, `${plan} ${period}`).toBe(plan);
      }
    }
    expect(BILLING_PRODUCTS['uz.labguide.pro.monthly'].plan).toBe('specialist');
    expect(BILLING_PRODUCTS['uz.labguide.pro.student.yearly'].plan).toBe('student');
    expect(BILLING_PRODUCTS['uz.labguide.teacherpro.monthly'].plan).toBe('teacher');
  });
});
