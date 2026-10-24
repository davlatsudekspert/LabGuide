import { beforeEach, describe, expect, it } from 'vitest';
import { ADMIN_IDLE_SEC, ADMIN_SESSION_MAX_SEC, SESSION_TTL_DAYS } from '../src/auth';
import {
  STEP_UP_CODE_TTL_SEC,
  STEP_UP_MAX_ATTEMPTS,
  STEP_UP_REQUESTS_PER_HOUR,
  STEP_UP_WINDOW_SEC,
} from '../src/stepup';
import { makeServer, setAutoStepUp, uniqueEmail } from './helpers';

// Bu fayl step-up ni o'zi tekshiradi — avtomatik tasdiq o'chiq.
beforeEach(() => setAutoStepUp(false));

const MIN = 60_000;
const HOUR = 3600_000;
const DAY = 86400_000;

async function setup() {
  const owner = uniqueEmail('owner');
  const s = makeServer({ ADMIN_EMAILS: owner, LG_ADMIN_EMAILS: '' } as never);
  const boss = await s.signIn(owner);
  const user = await s.signIn(uniqueEmail('plain'));
  return { s, owner, boss, user };
}

async function auditRows(s: ReturnType<typeof makeServer>, actor: string) {
  const r = await s.env.DB.prepare('SELECT action, target, details FROM audit_log WHERE actor = ?1 ORDER BY id')
    .bind(actor)
    .all<{ action: string; target: string | null; details: string }>();
  return r.results.map((x) => ({ ...x, details: JSON.parse(x.details) as Record<string, unknown> }));
}

const lastCode = (s: ReturnType<typeof makeServer>, email: string) =>
  s.outbox.filter((m) => m.to === email.toLowerCase()).at(-1)!.code;

describe('admin oynasi: qisqa muddat (12 soat) va harakatsizlik (30 daqiqa)', () => {
  it('email kodi bilan kirgan egasi: oyna ichida panel 200; 30 daqiqa harakatsiz — step_up_required', async () => {
    const { s, boss } = await setup();
    expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).status).toBe(200);
    s.clock.now += ADMIN_IDLE_SEC * 1000 - MIN;
    expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).status).toBe(200);
    s.clock.now += ADMIN_IDLE_SEC * 1000 + MIN;
    const r = await s.call('GET', '/v1/admin/stats', { token: boss.token });
    expect(r.status).toBe(403);
    expect(r.data).toMatchObject({ error: 'step_up_required', reason: 'admin_session_expired' });
    expect((await s.call('GET', '/v1/me', { token: boss.token })).data).toMatchObject({ panel_admin: true, admin_fresh: false });
  });

  it('faol bo‘lsa ham 12 soatdan keyin (mutlaq) — step_up_required; step-up oynani yangilaydi', async () => {
    const { s, owner, boss } = await setup();
    // Har 20 daqiqada so'rov — harakatsizlik oshmaydi.
    for (let t = 0; t < ADMIN_SESSION_MAX_SEC * 1000 - 20 * MIN; t += 20 * MIN) {
      s.clock.now += 20 * MIN;
      expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).status, `t=${t}`).toBe(200);
    }
    s.clock.now += 40 * MIN;
    expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).data.error).toBe('step_up_required');
    expect(await s.stepUp(boss.token, owner)).toBe('email');
    expect((await s.call('GET', '/v1/admin/stats', { token: boss.token })).status).toBe(200);
    expect((await s.call('GET', '/v1/me', { token: boss.token })).data.admin_fresh).toBe(true);
  });

  it('oddiy foydalanuvchi ta’sirlanmaydi: sessiya 60 kun, oddiy amallar step-up so‘ramaydi', async () => {
    const { s, user } = await setup();
    s.clock.now += (SESSION_TTL_DAYS - 1) * DAY;
    const me = await s.call('GET', '/v1/me', { token: user.token });
    expect(me.status).toBe(200);
    expect(me.data).toMatchObject({ panel_admin: false, admin: false, admin_fresh: false });
    expect((await s.call('PUT', '/v1/me/profile', { token: user.token, body: { role: 'lab' } })).status).toBe(200);
    // Admin bo'lmagan step-up so'ray olmaydi.
    expect((await s.call('POST', '/v1/auth/step-up', { token: user.token })).status).toBe(403);
    expect((await s.call('POST', '/v1/auth/step-up/verify', { token: user.token, body: { code: '123456' } })).status).toBe(403);
    s.clock.now += 2 * DAY;
    expect((await s.call('GET', '/v1/me', { token: user.token })).status).toBe(401);
  });

  it('migratsiyadan oldingi sessiya (admin_auth_at NULL) — panel darhol yangi tasdiq so‘raydi', async () => {
    const { s, owner, boss } = await setup();
    await s.env.DB.prepare('UPDATE sessions SET admin_auth_at = NULL, admin_seen_at = NULL WHERE user_id = ?1').bind(boss.userId).run();
    expect((await s.call('GET', '/v1/admin/users', { token: boss.token })).data.error).toBe('step_up_required');
    // Oddiy yo'llar ishlaydi.
    expect((await s.call('GET', '/v1/me', { token: boss.token })).status).toBe(200);
    await s.stepUp(boss.token, owner);
    expect((await s.call('GET', '/v1/admin/users', { token: boss.token })).status).toBe(200);
  });

  it('TOTP (aal2) ham oynaga bog‘liq: 30 daqiqadan keyin aal1, admin yo‘li step_up_required; TOTP step-up tiklaydi', async () => {
    const s = makeServer({ LG_ADMIN_EMAILS: 'boss@example.test' });
    const a = await s.signInAdmin();
    expect((await s.call('GET', '/v1/admin/community/members', { token: a.token })).status).toBe(200);
    s.clock.now += ADMIN_IDLE_SEC * 1000 + MIN;
    expect((await s.call('GET', '/v1/me', { token: a.token })).data).toMatchObject({ aal: 'aal1', admin: false });
    expect((await s.call('GET', '/v1/auth/mfa', { token: a.token })).data.aal).toBe('aal1');
    expect((await s.call('GET', '/v1/admin/community/members', { token: a.token })).data.error).toBe('step_up_required');
    expect(await s.stepUp(a.token, 'boss@example.test')).toBe('totp');
    expect((await s.call('GET', '/v1/me', { token: a.token })).data).toMatchObject({ aal: 'aal2', admin: true });
  });
});

describe('step-up: xavfli amallar', () => {
  it('talab qilinadi → email kodi → qabul qilinadi; jurnalda kim, nima, natija', async () => {
    const { s, owner, boss, user } = await setup();
    const path = `/v1/admin/users/${user.userId}/suspend`;
    const r = await s.call('POST', path, { token: boss.token });
    expect(r.status).toBe(403);
    expect(r.data).toMatchObject({ error: 'step_up_required', action: 'account_status', reason: 'missing' });
    // Rad etilgan amal hech narsani o'zgartirmagan.
    expect((await s.call('GET', '/v1/me', { token: user.token })).status).toBe(200);

    const req = await s.call('POST', '/v1/auth/step-up', { token: boss.token });
    expect(req.status).toBe(200);
    expect(req.data).toMatchObject({ method: 'email', valid_for: STEP_UP_CODE_TTL_SEC });
    expect(req.data.email_masked).toMatch(/^ow\*\*\*@/);
    expect(JSON.stringify(req.data)).not.toContain(owner);
    const v = await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code: lastCode(s, owner) } });
    expect(v.status).toBe(200);
    expect(v.data).toMatchObject({ ok: true, method: 'email', valid_for: STEP_UP_WINDOW_SEC });
    expect((await s.call('POST', path, { token: boss.token })).status).toBe(200);
    expect((await s.call('GET', '/v1/me', { token: user.token })).status).toBe(401);

    const log = await auditRows(s, boss.userId);
    const actions = log.map((l) => l.action);
    expect(actions).toEqual(
      expect.arrayContaining(['step_up_required', 'step_up_requested', 'step_up_verified', 'account_suspended']),
    );
    expect(log.find((l) => l.action === 'step_up_required')!.details).toMatchObject({ action: 'account_status', reason: 'missing' });
    expect(log.find((l) => l.action === 'step_up_verified')!.details).toMatchObject({ method: 'email' });
    expect(JSON.stringify(log)).not.toContain(owner);
    // Panel jurnalida ham ko'rinadi.
    const panel = await s.call('GET', '/v1/admin/audit', { token: boss.token });
    expect(panel.data.map((e: { action: string }) => e.action)).toEqual(expect.arrayContaining(['step_up_verified']));
  });

  it('tasdiq 10 daqiqa: undan keyin yana step_up_required (expired)', async () => {
    const { s, owner, boss, user } = await setup();
    await s.stepUp(boss.token, owner);
    expect((await s.call('POST', `/v1/admin/users/${user.userId}/role`, { token: boss.token, body: { role: 'lab' } })).status).toBe(200);
    s.clock.now += STEP_UP_WINDOW_SEC * 1000 + 1000;
    // Oynani faol tutish uchun o'qish (harakatsizlik emas, step-up eskirgan).
    const r = await s.call('POST', `/v1/admin/users/${user.userId}/role`, { token: boss.token, body: { role: 'doctor' } });
    expect(r.data).toMatchObject({ error: 'step_up_required', action: 'role', reason: 'expired' });
  });

  it('noto‘g‘ri kod: attempts_left; 5 urinishdan keyin kod o‘chadi; muddati o‘tgan kod — expired', async () => {
    const { s, owner, boss } = await setup();
    await s.call('POST', '/v1/auth/step-up', { token: boss.token });
    const good = lastCode(s, owner);
    const bad = good === '000000' ? '111111' : '000000';
    const w = await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code: bad } });
    expect(w.status).toBe(400);
    expect(w.data).toMatchObject({ error: 'invalid_code', attempts_left: STEP_UP_MAX_ATTEMPTS - 1 });
    for (let i = 2; i < STEP_UP_MAX_ATTEMPTS; i++) {
      expect((await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code: bad } })).status).toBe(400);
    }
    const last = await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code: bad } });
    expect(last.status).toBe(429);
    expect(last.data.error).toBe('too_many_attempts');
    // To'g'ri kod ham endi o'tmaydi.
    expect((await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code: good } })).data.error).toBe('no_active_code');

    s.clock.now += 61_000;
    await s.call('POST', '/v1/auth/step-up', { token: boss.token });
    const c2 = lastCode(s, owner);
    s.clock.now += STEP_UP_CODE_TTL_SEC * 1000;
    const exp = await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code: c2 } });
    expect(exp.status).toBe(400);
    expect(exp.data.error).toBe('expired');
    const fails = (await auditRows(s, boss.userId)).filter((l) => l.action === 'step_up_failed').map((l) => l.details.reason);
    expect(fails).toEqual(expect.arrayContaining(['invalid_code', 'too_many_attempts', 'no_active_code', 'expired']));
  });

  it('qayta ishlatish (replay): kod bir martalik; o‘chirish — har tasdiqqa bitta', async () => {
    const { s, owner, boss } = await setup();
    const victims = [uniqueEmail('v1'), uniqueEmail('v2')];
    const ids: string[] = [];
    for (const e of victims) ids.push((await s.signIn(e)).userId);
    await s.call('POST', '/v1/auth/step-up', { token: boss.token });
    const code = lastCode(s, owner);
    expect((await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code } })).status).toBe(200);
    const again = await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code } });
    expect(again.status).toBe(400);
    expect(again.data.error).toBe('no_active_code');

    const del = (i: number) =>
      s.call('POST', '/v1/admin/accounts/delete', { token: boss.token, body: { email: victims[i], confirm_user_id: ids[i] } });
    expect((await del(0)).status).toBe(200);
    const second = await del(1);
    expect(second.status).toBe(403);
    expect(second.data).toMatchObject({ error: 'step_up_required', action: 'account_delete', reason: 'used' });
    await s.stepUp(boss.token, owner);
    expect((await del(1)).status).toBe(200);
  });

  it('boshqa sessiyaning kodi bu sessiyada o‘tmaydi (sessiyaga bog‘langan)', async () => {
    const { s, owner, boss } = await setup();
    const other = await s.signIn(owner); // ikkinchi qurilma
    await s.call('POST', '/v1/auth/step-up', { token: boss.token });
    const code = lastCode(s, owner);
    const r = await s.call('POST', '/v1/auth/step-up/verify', { token: other.token, body: { code } });
    expect(r.status).toBe(400);
    expect(r.data.error).toBe('no_active_code');
    expect((await s.call('POST', '/v1/auth/step-up/verify', { token: boss.token, body: { code } })).status).toBe(200);
  });

  it('limitlar: qayta yuborish 60 soniya; soatiga 5 ta kod', async () => {
    const { s, boss } = await setup();
    expect((await s.call('POST', '/v1/auth/step-up', { token: boss.token })).status).toBe(200);
    const quick = await s.call('POST', '/v1/auth/step-up', { token: boss.token });
    expect(quick.status).toBe(429);
    expect(quick.data.retry_after).toBeGreaterThan(0);
    for (let i = 1; i < STEP_UP_REQUESTS_PER_HOUR; i++) {
      s.clock.now += 61_000;
      expect((await s.call('POST', '/v1/auth/step-up', { token: boss.token })).status, `req ${i}`).toBe(200);
    }
    s.clock.now += 61_000;
    const over = await s.call('POST', '/v1/auth/step-up', { token: boss.token });
    expect(over.status).toBe(429);
    expect(over.data.error).toBe('rate_limited');
    s.clock.now += HOUR;
    expect((await s.call('POST', '/v1/auth/step-up', { token: boss.token })).status).toBe(200);
  });

  it('email yuborilmasa — 503/502, kod saqlanmaydi', async () => {
    const { s, boss } = await setup();
    s.setMail('not_configured');
    expect((await s.call('POST', '/v1/auth/step-up', { token: boss.token })).status).toBe(503);
    s.setMail('failed');
    s.clock.now += 61_000;
    expect((await s.call('POST', '/v1/auth/step-up', { token: boss.token })).status).toBe(502);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM step_up_challenges WHERE user_id = ?1').bind(boss.userId).first<{ n: number }>();
    expect(n!.n).toBe(0);
  });

  it('TOTP faktori bor admin: step-up faqat TOTP (email kodi yuborilmaydi), TOTP qadami qayta qabul qilinmaydi', async () => {
    const s = makeServer({ LG_ADMIN_EMAILS: 'boss@example.test', ADMIN_EMAILS: 'boss@example.test' } as never);
    const a = await s.signInAdmin();
    const before = s.outbox.length;
    const r = await s.call('POST', '/v1/auth/step-up', { token: a.token });
    expect(r.data.method).toBe('totp');
    expect(s.outbox.length).toBe(before);
    // Email kodi bilan pasaytirib bo'lmaydi.
    expect((await s.call('POST', '/v1/auth/step-up/verify', { token: a.token, body: { code: '123456' } })).status).toBe(400);
    expect(await s.stepUp(a.token, 'boss@example.test')).toBe('totp');
    const target = await s.signIn(uniqueEmail('t'));
    expect((await s.call('POST', `/v1/admin/users/${target.userId}/suspend`, { token: a.token })).status).toBe(200);
  });

  it('adminlar va hamjamiyat moderatsiyasi ham step-up so‘raydi (TOTP yo‘llari)', async () => {
    const s = makeServer({ LG_ADMIN_EMAILS: 'boss@example.test' });
    const a = await s.signInAdmin();
    const add = await s.call('POST', '/v1/admin/admins', { token: a.token, body: { email: uniqueEmail('new') } });
    expect(add.data).toMatchObject({ error: 'step_up_required', action: 'admins' });
    const launch = await s.call('POST', '/v1/admin/community/launch', { token: a.token });
    expect(launch.data).toMatchObject({ error: 'step_up_required', action: 'content' });
    await s.stepUp(a.token, 'boss@example.test');
    expect((await s.call('POST', '/v1/admin/admins', { token: a.token, body: { email: uniqueEmail('new') } })).status).toBe(201);
    expect((await s.call('POST', '/v1/admin/community/launch', { token: a.token })).status).toBe(200);
  });
});

describe('sessiyalarni bekor qilish', () => {
  it('admin: foydalanuvchining hamma sessiyalari (step-up, bir martalik); hisob to‘xtatilmaydi; jurnal', async () => {
    const { s, owner, boss } = await setup();
    const email = uniqueEmail('many');
    const d1 = await s.signIn(email);
    const d2 = await s.signIn(email);
    const path = `/v1/admin/users/${d1.userId}/sessions/revoke`;
    expect((await s.call('POST', path, { token: d1.token })).status).toBe(403);
    expect((await s.call('POST', path, { token: boss.token })).data).toMatchObject({ error: 'step_up_required', action: 'sessions_revoke' });
    expect((await s.call('GET', '/v1/me', { token: d1.token })).status).toBe(200);
    await s.stepUp(boss.token, owner);
    const r = await s.call('POST', path, { token: boss.token });
    expect(r.status).toBe(200);
    expect(r.data.revoked).toBe(2);
    expect((await s.call('GET', '/v1/me', { token: d1.token })).status).toBe(401);
    expect((await s.call('GET', '/v1/me', { token: d2.token })).status).toBe(401);
    // Qayta kira oladi (to'xtatilmagan).
    expect((await s.signIn(email)).userId).toBe(d1.userId);
    expect((await s.call('POST', path, { token: boss.token })).data.reason).toBe('used');
    expect((await s.call('POST', `/v1/admin/users/${boss.userId}/sessions/revoke`, { token: boss.token })).status).toBe(403);
    const log = await auditRows(s, boss.userId);
    expect(log.find((l) => l.action === 'sessions_revoked')).toMatchObject({ target: d1.userId, details: { sessions: 2 } });
  });

  it('o‘zi: hamma qurilmalardan chiqish (logout-all) — jurnalda; boshqa foydalanuvchiga ta’sir yo‘q', async () => {
    const { s, user } = await setup();
    const other = await s.signIn(uniqueEmail('other'));
    const email = uniqueEmail('self');
    const a = await s.signIn(email);
    const b = await s.signIn(email);
    expect((await s.call('POST', '/v1/auth/logout-all', { token: a.token })).status).toBe(204);
    expect((await s.call('GET', '/v1/me', { token: a.token })).status).toBe(401);
    expect((await s.call('GET', '/v1/me', { token: b.token })).status).toBe(401);
    expect((await s.call('GET', '/v1/me', { token: other.token })).status).toBe(200);
    expect((await s.call('GET', '/v1/me', { token: user.token })).status).toBe(200);
    expect((await auditRows(s, a.userId)).map((l) => l.action)).toContain('sessions_revoked_self');
  });
});

describe('hisobni o‘chirgandan keyin qayta kirish (auth oqimlari auditi)', () => {
  it('o‘chirilgan email bilan qayta kirish — yangi id; sessiya va step-up kodlari ham o‘chgan', async () => {
    const { s } = await setup();
    const email = uniqueEmail('again');
    const first = await s.signIn(email);
    await s.env.DB.prepare(
      `INSERT INTO step_up_challenges (token_hash, user_id, code_hash, created_at, expires_at) VALUES ('t', ?1, 'h', 0, ?2)`,
    )
      .bind(first.userId, s.clock.now + 600_000)
      .run();
    expect((await s.call('DELETE', '/v1/me', { token: first.token })).status).toBe(204);
    expect((await s.call('GET', '/v1/me', { token: first.token })).status).toBe(401);
    const left = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM step_up_challenges WHERE user_id = ?1')
      .bind(first.userId)
      .first<{ n: number }>();
    expect(left!.n).toBe(0);
    const second = await s.signIn(email);
    expect(second.userId).not.toBe(first.userId);
    expect((await s.call('GET', '/v1/me', { token: second.token })).data).toMatchObject({ role: 'student', admin: false });
  });
});
