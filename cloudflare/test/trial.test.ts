// Bepul sinov — bir telefonga bir marta (D-74, src/trial.ts). Hamma yo'l
// LG_BILLING_ENABLED=true bo'lmasa 404; attestatsiya sozlanmagan — 503.
// Qurilma attestatsiyasi soxta (test/fake_attestation.ts).
import { describe, expect, it } from 'vitest';
import { canonicalEmail, TRIAL_DAYS, TRIAL_RETENTION_DAYS } from '../src/trial';
import { FakeDeviceAttestationVerifier, RejectingVerifier } from './fake_attestation';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
type Srv = ReturnType<typeof baseServer>;

function makeServer(verifier: FakeDeviceAttestationVerifier | typeof RejectingVerifier | null = new FakeDeviceAttestationVerifier()) {
  const s = baseServer({ LG_BILLING_ENABLED: 'true' } as never);
  if (verifier) s.setAttestation(verifier);
  return s;
}

const challenge = (s: Srv, token: string) => s.call('POST', '/v1/billing/trial/challenge', { token });

async function startTrial(
  s: Srv,
  token: string,
  email: string,
  device: string,
  opts: { tier?: string; platform?: string; ip?: string } = {},
) {
  const ch = await challenge(s, token);
  if (ch.status !== 200) return ch;
  const nonce = ch.data.nonce as string;
  return s.call('POST', '/v1/billing/trial/start', {
    token,
    ip: opts.ip,
    body: {
      tier: opts.tier ?? 'student',
      email,
      attestation: { platform: opts.platform ?? 'android', token: `fake:${device}:${nonce}`, nonce },
    },
  });
}

const ents = (s: Srv, token: string) => s.call('GET', '/v1/billing/entitlements', { token });
const dev = () => `device-${crypto.randomUUID()}`;

describe('trial: kanonik email (D-74 (a))', () => {
  it('Gmail: nuqta va +teg e’tiborsiz, googlemail → gmail; boshqalar faqat trim+kichik harf', () => {
    expect(canonicalEmail(' Ali.Valiyev+trial@GMAIL.com ')).toBe('alivaliyev@gmail.com');
    expect(canonicalEmail('a.l.i.valiyev@googlemail.com')).toBe('alivaliyev@gmail.com');
    expect(canonicalEmail('ali+x@outlook.com')).toBe('ali@outlook.com');
    expect(canonicalEmail('a.li+x@hotmail.com')).toBe('a.li@hotmail.com'); // nuqta muhim
    expect(canonicalEmail('ali+x@ya.ru')).toBe('ali@yandex.ru');
    expect(canonicalEmail('Ali.V+tag@Example.uz')).toBe('ali.v+tag@example.uz');
    expect(canonicalEmail('+tag@gmail.com')).toBe('+tag@gmail.com'); // bo'sh lokal qism qolmasin
    expect(canonicalEmail('...@gmail.com')).toBeNull();
    expect(canonicalEmail('not-an-email')).toBeNull();
  });
});

describe('trial: bayroq va sozlama', () => {
  it('LG_BILLING_ENABLED yo‘q: challenge/start 404 (tokenli ham)', async () => {
    const s = baseServer();
    s.setAttestation(new FakeDeviceAttestationVerifier());
    const email = uniqueEmail('off');
    const u = await s.signIn(email);
    for (const p of ['/v1/billing/trial/challenge', '/v1/billing/trial/start']) {
      for (const token of [undefined, u.token]) {
        expect((await s.call('POST', p, { token, body: {} })).status, p).toBe(404);
      }
    }
  });

  it('attestatsiya sozlanmagan: 503 device_attestation_not_configured', async () => {
    const s = makeServer(null);
    const email = uniqueEmail('nocfg');
    const u = await s.signIn(email);
    const ch = await challenge(s, u.token);
    expect(ch.status).toBe(503);
    expect(ch.data.error).toBe('device_attestation_not_configured');
    const st = await s.call('POST', '/v1/billing/trial/start', {
      token: u.token,
      body: { tier: 'student', email, attestation: { platform: 'ios', token: 'x', nonce: 'a'.repeat(43) } },
    });
    expect(st.status).toBe(503);
    expect(st.data.error).toBe('device_attestation_not_configured');
  });

  it('mehmon (sessiyasiz) — 401', async () => {
    const s = makeServer();
    expect((await s.call('POST', '/v1/billing/trial/challenge', {})).status).toBe(401);
    expect((await s.call('POST', '/v1/billing/trial/start', { body: { tier: 'student' } })).status).toBe(401);
  });
});

describe('trial: berish va suiiste’mol cheklovlari', () => {
  it('birinchi sinov: 201, 30 kun, source=trial; resolver va jurnal', async () => {
    const s = makeServer();
    const email = uniqueEmail('first');
    const u = await s.signIn(email);
    const r = await startTrial(s, u.token, email, dev());
    expect(r.status).toBe(201);
    expect(r.data.resolved).toEqual({
      source: 'trial',
      plan: 'student',
      expires_at: new Date(s.clock.now + TRIAL_DAYS * DAY).toISOString(),
    });
    expect(r.data.trial_used).toBe(true);
    const item = (r.data.items as any[]).find((i) => i.source === 'trial');
    expect(item).toMatchObject({ platform: 'trial', plan: 'student', status: 'active', product_id: 'trial.student' });
    // Bazada xom email yoki qurilma yo'q.
    const row = await s.env.DB.prepare('SELECT * FROM pro_trials WHERE user_id = ?1').bind(u.userId).first<any>();
    expect(JSON.stringify(row)).not.toContain(email.split('@')[0]);
    expect(JSON.stringify(row)).not.toContain('device-');
    expect(row.retain_until - row.started_at).toBe(TRIAL_RETENTION_DAYS * DAY);
    const log = await s.env.DB.prepare(`SELECT details FROM audit_log WHERE action = 'pro_trial_started' AND actor = ?1`)
      .bind(u.userId)
      .first<{ details: string }>();
    expect(JSON.parse(log!.details)).toMatchObject({ tier: 'student', platform: 'android' });
    expect(log!.details).not.toContain('@');
  });

  it('o‘sha hisob ikkinchi marta (boshqa qurilma ham) — 409', async () => {
    const s = makeServer();
    const email = uniqueEmail('twice');
    const u = await s.signIn(email);
    expect((await startTrial(s, u.token, email, dev())).status).toBe(201);
    const again = await startTrial(s, u.token, email, dev());
    expect(again.status).toBe(409);
    expect(again.data.error).toBe('trial_already_used');
  });

  it('o‘sha telefonda ikkinchi hisob — rad etiladi; boshqa telefonda — ruxsat', async () => {
    const s = makeServer();
    const phone = dev();
    const a = uniqueEmail('a');
    const b = uniqueEmail('b');
    const c = uniqueEmail('c');
    const ua = await s.signIn(a);
    const ub = await s.signIn(b);
    const uc = await s.signIn(c);
    expect((await startTrial(s, ua.token, a, phone)).status).toBe(201);
    const second = await startTrial(s, ub.token, b, phone);
    expect(second.status).toBe(409);
    expect(second.data.error).toBe('trial_already_used');
    // Platforma bir xil bo'lishi muhim (iOS va Android subyektlari aralashmaydi).
    expect((await startTrial(s, uc.token, c, dev())).status).toBe(201);
  });

  it('Gmail nuqta/+teg aliasi — o‘sha email deb hisoblanadi', async () => {
    const s = makeServer();
    const local = `alias${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`;
    const orig = `${local}@gmail.com`;
    const alias = `${local.slice(0, 3)}.${local.slice(3)}+promo@googlemail.com`;
    const u1 = await s.signIn(orig);
    const u2 = await s.signIn(alias);
    expect(u1.userId).not.toBe(u2.userId); // kirish uchun alohida hisob (identifikator o'zgarmaydi)
    expect((await startTrial(s, u1.token, orig, dev())).status).toBe(201);
    const r = await startTrial(s, u2.token, alias, dev());
    expect(r.status).toBe(409);
    expect(r.data.error).toBe('trial_already_used');
  });

  it('tasdiqlanmagan email (hisob emaili emas) — 403 email_not_verified', async () => {
    const s = makeServer();
    const email = uniqueEmail('real');
    const u = await s.signIn(email);
    const r = await startTrial(s, u.token, uniqueEmail('someone-else'), dev());
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('email_not_verified');
    // Noto'g'ri formatdagi email — 400.
    const bad = await startTrial(s, u.token, 'not-an-email', dev());
    expect(bad.status).toBe(400);
  });

  it('hisobni o‘chirib qayta ro‘yxatdan o‘tish sinovni qaytarmaydi (yangi qurilmada ham)', async () => {
    const s = makeServer();
    const email = uniqueEmail('again');
    const u = await s.signIn(email);
    expect((await startTrial(s, u.token, email, dev())).status).toBe(201);
    expect((await s.call('DELETE', '/v1/me', { token: u.token })).status).toBe(204);
    // Yozuv qoldi, hisobdan uzildi.
    const kept = await s.env.DB.prepare('SELECT user_id, account_deleted_at FROM pro_trials WHERE account_deleted_at = ?1')
      .bind(s.clock.now)
      .all<{ user_id: string | null }>();
    expect(kept.results.length).toBeGreaterThan(0);
    expect(kept.results.every((r) => r.user_id === null)).toBe(true);

    const again = await s.signIn(email);
    expect(again.userId).not.toBe(u.userId);
    const r = await startTrial(s, again.token, email, dev());
    expect(r.status).toBe(409);
    expect(r.data.error).toBe('trial_already_used');
    expect((await ents(s, again.token)).data.resolved).toBeNull();
  });

  it('hisob o‘chirilib boshqa email bilan o‘sha telefonda — rad', async () => {
    const s = makeServer();
    const phone = dev();
    const a = uniqueEmail('del-a');
    const ua = await s.signIn(a);
    expect((await startTrial(s, ua.token, a, phone)).status).toBe(201);
    await s.call('DELETE', '/v1/me', { token: ua.token });
    const b = uniqueEmail('del-b');
    const ub = await s.signIn(b);
    expect((await startTrial(s, ub.token, b, phone)).status).toBe(409);
  });

  it('attestatsiya rad etsa — 403 device_attestation_failed (nonce mos emas ham)', async () => {
    const s = makeServer(RejectingVerifier);
    const email = uniqueEmail('rej');
    const u = await s.signIn(email);
    const r = await startTrial(s, u.token, email, dev());
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('device_attestation_failed');

    const s2 = makeServer();
    const e2 = uniqueEmail('nonce');
    const u2 = await s2.signIn(e2);
    const ch = await challenge(s2, u2.token);
    const wrong = await s2.call('POST', '/v1/billing/trial/start', {
      token: u2.token,
      body: { tier: 'student', email: e2, attestation: { platform: 'ios', token: `fake:${dev()}:other`, nonce: ch.data.nonce } },
    });
    expect(wrong.status).toBe(403);
    expect(wrong.data.error).toBe('device_attestation_failed');
    // Nonce bir martalik: qayta ishlatib bo'lmaydi.
    const reuse = await s2.call('POST', '/v1/billing/trial/start', {
      token: u2.token,
      body: { tier: 'student', email: e2, attestation: { platform: 'ios', token: `fake:x:${ch.data.nonce}`, nonce: ch.data.nonce } },
    });
    expect(reuse.status).toBe(400);
    expect(reuse.data.error).toBe('invalid_nonce');
  });

  it('boshqa hisobning nonce’i va muddati o‘tgan nonce — 400 invalid_nonce', async () => {
    const s = makeServer();
    const a = uniqueEmail('na');
    const b = uniqueEmail('nb');
    const ua = await s.signIn(a);
    const ub = await s.signIn(b);
    const ch = await challenge(s, ua.token);
    const r = await s.call('POST', '/v1/billing/trial/start', {
      token: ub.token,
      body: { tier: 'student', email: b, attestation: { platform: 'android', token: `fake:d:${ch.data.nonce}`, nonce: ch.data.nonce } },
    });
    expect(r.data.error).toBe('invalid_nonce');
    const ch2 = await challenge(s, ub.token);
    s.clock.now += 301_000;
    const late = await s.call('POST', '/v1/billing/trial/start', {
      token: ub.token,
      body: { tier: 'student', email: b, attestation: { platform: 'android', token: `fake:d:${ch2.data.nonce}`, nonce: ch2.data.nonce } },
    });
    expect(late.data.error).toBe('invalid_nonce');
  });

  it('platforma bayrog‘i (DeviceCheck/device recall) “ishlatilgan” desa — rad', async () => {
    const v = new FakeDeviceAttestationVerifier(true);
    const s = makeServer(v);
    const phone = dev();
    const a = uniqueEmail('flag');
    const ua = await s.signIn(a);
    expect((await startTrial(s, ua.token, a, phone, { platform: 'ios' })).status).toBe(201);
    expect(v.flagged.has(`ios:${phone}`)).toBe(true);
    // Bizning yozuv o'chgan taqdirda ham (masalan saqlash muddati o'tgan) bayroq to'xtatadi.
    await s.env.DB.prepare('DELETE FROM pro_trials WHERE user_id = ?1').bind(ua.userId).run();
    const b = uniqueEmail('flag-b');
    const ub = await s.signIn(b);
    expect((await startTrial(s, ub.token, b, phone, { platform: 'ios' })).data.error).toBe('trial_already_used');
  });

  it('limit: hisobga soatiga 5 urinish', async () => {
    const s = makeServer(RejectingVerifier);
    const email = uniqueEmail('rl');
    const u = await s.signIn(email);
    const statuses: number[] = [];
    for (let i = 0; i < 6; i++) statuses.push((await startTrial(s, u.token, email, dev())).status);
    expect(statuses.slice(0, 5).every((x) => x === 403)).toBe(true);
    expect(statuses[5]).toBe(429);
  });
});

describe('trial: daraja hisobga ruxsat etilgan bo‘lishi kerak (D-74 (f))', () => {
  it('ustoz sifatida ro‘yxatdan o‘tmagan hisob (rolini “teacher” qilgan bo‘lsa ham) — Ustoz sinovi 403', async () => {
    const s = makeServer();
    const email = uniqueEmail('fake-teacher');
    const u = await s.signIn(email, { role: 'teacher' }); // faqat profil roli
    const r = await startTrial(s, u.token, email, dev(), { tier: 'teacher' });
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('plan_not_allowed');
  });

  it('serverda ustoz — Ustoz sinovi beriladi', async () => {
    const s = makeServer();
    const email = uniqueEmail('teacher');
    const u = await s.signInTeacher(email);
    const r = await startTrial(s, u.token, email, dev(), { tier: 'teacher' });
    expect(r.status).toBe(201);
    expect(r.data.resolved.plan).toBe('teacher');
  });

  it('Mutaxassis sinovi faqat tasdiqlangan mutaxassisga; noma’lum daraja 400', async () => {
    const s = makeServer();
    const email = uniqueEmail('lab');
    const u = await s.signIn(email, { role: 'lab' });
    const r = await startTrial(s, u.token, email, dev(), { tier: 'specialist' });
    expect(r.data.error).toBe('plan_not_allowed');
    const bad = await startTrial(s, u.token, email, dev(), { tier: 'gold' });
    expect(bad.status).toBe(400);
  });
});

describe('trial: muddat va pullik obuna (D-74 (g))', () => {
  it('30 kundan keyin huquq yo‘q (expired), qayta sinov yo‘q', async () => {
    const s = makeServer();
    const email = uniqueEmail('exp');
    const u = await s.signIn(email);
    expect((await startTrial(s, u.token, email, dev())).status).toBe(201);
    s.clock.now += (TRIAL_DAYS - 1) * DAY;
    expect((await ents(s, u.token)).data.resolved?.source).toBe('trial');
    s.clock.now += 2 * DAY;
    const after = await ents(s, u.token);
    expect(after.data.resolved).toBeNull();
    expect((after.data.items as any[]).find((i) => i.source === 'trial').status).toBe('expired');
    expect((await s.call('GET', '/v1/pro/check/learner', { token: u.token })).status).toBe(403);
    expect((await startTrial(s, u.token, email, dev())).data.error).toBe('trial_already_used');
  });

  it('amaldagi do‘kon obunasi bo‘lsa sinov boshlanmaydi (409); sinov obunani bosib o‘tmaydi', async () => {
    const s = makeServer();
    const email = uniqueEmail('paid');
    const u = await s.signIn(email);
    // Teacher sinovi bor, keyin Talaba obunasi sotib olindi.
    await s.env.DB.prepare('INSERT INTO teacher_accounts (user_id, registered_at) VALUES (?1, ?2)').bind(u.userId, s.clock.now).run();
    expect((await startTrial(s, u.token, email, dev(), { tier: 'teacher' })).status).toBe(201);
    await s.env.DB.prepare(
      `INSERT INTO entitlements (platform, original_transaction_id, user_id, product_id, status, started_at, expires_at,
         latest_token, event_at, updated_at) VALUES ('play_store', ?1, ?2, 'uz.labguide.student.monthly', 'active', ?3, ?4, 't', ?3, ?3)`,
    )
      .bind(`tx-${crypto.randomUUID()}`, u.userId, s.clock.now, s.clock.now + 30 * DAY)
      .run();
    const r = await ents(s, u.token);
    expect(r.data.resolved).toMatchObject({ source: 'store', plan: 'student' });

    const other = uniqueEmail('paid2');
    const u2 = await s.signIn(other);
    await s.env.DB.prepare(
      `INSERT INTO entitlements (platform, original_transaction_id, user_id, product_id, status, started_at, expires_at,
         latest_token, event_at, updated_at) VALUES ('app_store', ?1, ?2, 'uz.labguide.student.yearly', 'active', ?3, ?4, 't', ?3, ?3)`,
    )
      .bind(`tx-${crypto.randomUUID()}`, u2.userId, s.clock.now, s.clock.now + 365 * DAY)
      .run();
    const st = await startTrial(s, u2.token, other, dev());
    expect(st.status).toBe(409);
    expect(st.data.error).toBe('already_subscribed');
  });
});

describe('trial: saqlash muddati', () => {
  it(`kunlik tozalash ${TRIAL_RETENTION_DAYS} kundan keyin yozuvni o‘chiradi (undan oldin emas)`, async () => {
    const s = makeServer();
    const email = uniqueEmail('ret');
    const u = await s.signIn(email);
    expect((await startTrial(s, u.token, email, dev())).status).toBe(201);
    const count = async () =>
      (await s.env.DB.prepare('SELECT COUNT(*) AS n FROM pro_trials WHERE user_id = ?1').bind(u.userId).first<{ n: number }>())!.n;
    const base = s.clock.now;
    s.clock.now = base + (TRIAL_RETENTION_DAYS - 1) * DAY;
    await s.app.scheduled(s.env);
    expect(await count()).toBe(1);
    s.clock.now = base + (TRIAL_RETENTION_DAYS + 1) * DAY;
    await s.app.scheduled(s.env);
    expect(await count()).toBe(0);
  });
});
