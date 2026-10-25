// 7 kunlik sinov: holat mashinasi, server soati, takror, poyga, qayta
// ro'yxatdan o'tish, IP tarmog'i limitlari (D-77 addendum). Qurilma
// attestatsiyasi soxta (test/fake_attestation.ts), Google/Apple chaqirilmaydi.
import { describe, expect, it } from 'vitest';
import { canonicalEmail, NEW_ACCOUNT_TRIALS_PER_PREFIX_DAY, TRIAL_DAYS } from '../src/trial';
import { FakeDeviceAttestationVerifier } from './fake_attestation';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
type Srv = ReturnType<typeof baseServer>;

function makeServer(extra: Record<string, string> = {}) {
  const s = baseServer({ LG_BILLING_ENABLED: 'true', ...extra } as never);
  s.setAttestation(new FakeDeviceAttestationVerifier());
  return s;
}

let net = 0;
/** Har chaqiruvda yangi /24 tarmoq. */
const freshNet = () => `172.${16 + ((++net >> 8) & 15)}.${net & 255}`;
const dev = () => `device-${crypto.randomUUID()}`;

async function start(
  s: Srv,
  token: string,
  email: string,
  device: string,
  opts: { ip?: string; tier?: string; extraBody?: Record<string, unknown>; headers?: Record<string, string>; tokenOverride?: string } = {},
) {
  const ch = await s.call('POST', '/v1/billing/trial/challenge', { token });
  if (ch.status !== 200) return ch;
  const nonce = ch.data.nonce as string;
  return s.call('POST', '/v1/billing/trial/start', {
    token,
    ip: opts.ip ?? `${freshNet()}.9`,
    headers: opts.headers,
    body: {
      tier: opts.tier ?? 'student',
      email,
      attestation: { platform: 'android', token: opts.tokenOverride ?? `fake:${device}:${nonce}`, nonce, device_id: 'androidid0001' },
      ...(opts.extraBody ?? {}),
    },
  });
}

const trialState = async (s: Srv, token: string) => (await s.call('GET', '/v1/billing/trial', { token })).data;

describe('holat mashinasi: not_started → active → expired (server soati)', () => {
  it('har o‘tish va qayta boshlanmasligi', async () => {
    const s = makeServer();
    const email = uniqueEmail('sm');
    const u = await s.signIn(email);
    const t0 = await trialState(s, u.token);
    expect(t0).toMatchObject({ state: 'not_started', plan: null, started_at: null, expires_at: null, remaining_ms: 0, days: 7 });
    expect(t0.server_time).toBe(new Date(s.clock.now).toISOString());

    const startedAt = s.clock.now;
    expect((await start(s, u.token, email, dev())).status).toBe(201);
    const t1 = await trialState(s, u.token);
    expect(t1).toMatchObject({
      state: 'active',
      plan: 'student',
      started_at: new Date(startedAt).toISOString(),
      expires_at: new Date(startedAt + TRIAL_DAYS * DAY).toISOString(),
      remaining_ms: TRIAL_DAYS * DAY,
    });

    // Chegaradan 1 ms oldin — active; aynan expires_at da — expired.
    s.clock.now = startedAt + TRIAL_DAYS * DAY - 1;
    expect((await trialState(s, u.token)).state).toBe('active');
    expect((await s.call('GET', '/v1/pro/check/learner', { token: u.token })).status).toBe(200);
    s.clock.now = startedAt + TRIAL_DAYS * DAY;
    const t2 = await trialState(s, u.token);
    expect(t2).toMatchObject({ state: 'expired', remaining_ms: 0 });
    expect((await s.call('GET', '/v1/pro/check/learner', { token: u.token })).status).toBe(403);
    // Free qism ishlaydi, ma'lumot o'chmaydi.
    expect((await s.call('GET', '/v1/me', { token: u.token })).status).toBe(200);

    // expired → hech qachon qayta boshlanmaydi (boshqa reja, boshqa qurilma ham).
    const again = await start(s, u.token, email, dev(), { tier: 'student' });
    expect(again.status).toBe(409);
    expect(again.data.error).toBe('trial_already_used');
    s.clock.now += 400 * DAY;
    const later = await s.signIn(email); // sessiya muddati o'tgan — qayta kirish (o'sha hisob)
    expect(later.userId).toBe(u.userId);
    expect((await trialState(s, later.token)).state).toBe('expired');
    expect((await start(s, later.token, email, dev())).data.error).toBe('trial_already_used');
  });

  it('mehmon — 401; bayroq o‘chiq — 404', async () => {
    const s = makeServer();
    expect((await s.call('GET', '/v1/billing/trial')).status).toBe(401);
    const off = baseServer();
    const u = await off.signIn(uniqueEmail('sm-off'));
    expect((await off.call('GET', '/v1/billing/trial', { token: u.token })).status).toBe(404);
  });

  it('bitta sinov = tanlangan BITTA reja: Talaba sinovi ustoz paneli / Lab ochmaydi; keyin boshqa reja sinovi yo‘q', async () => {
    const s = makeServer();
    const email = uniqueEmail('one-plan');
    const u = await s.signInTeacher(email);
    expect((await start(s, u.token, email, dev(), { tier: 'student' })).status).toBe(201);
    expect((await s.call('GET', '/v1/pro/check/learner', { token: u.token })).status).toBe(200);
    expect((await s.call('GET', '/v1/pro/check/teacher_panel', { token: u.token })).data.error).toBe('tier_insufficient');
    expect((await s.call('GET', '/v1/pro/check/lab', { token: u.token })).data.error).toBe('tier_insufficient');
    const other = await start(s, u.token, email, dev(), { tier: 'teacher' });
    expect(other.status).toBe(409);
    expect(other.data.error).toBe('trial_already_used');
  });
});

describe('mijoz soatini o‘zgartirish (clock tampering) — e’tiborsiz', () => {
  it('so‘rovdagi started_at / expires_at / now / days va soat sarlavhalari muddatga ta’sir qilmaydi', async () => {
    const s = makeServer();
    const email = uniqueEmail('tamper');
    const u = await s.signIn(email);
    const r = await start(s, u.token, email, dev(), {
      extraBody: {
        started_at: '2030-01-01T00:00:00Z',
        expires_at: '2099-01-01T00:00:00Z',
        now: 0,
        days: 365,
        server_time: '2099-01-01T00:00:00Z',
      },
      headers: { date: 'Mon, 01 Jan 2035 00:00:00 GMT', 'x-client-time': '2035-01-01T00:00:00Z' },
    });
    expect(r.status).toBe(201);
    expect(r.data.resolved.expires_at).toBe(new Date(s.clock.now + 7 * DAY).toISOString());
    expect(r.data.server_time).toBe(new Date(s.clock.now).toISOString());
    // Oflayn chegarasi ham server soatidan (≤ 7 kun).
    expect(Date.parse(r.data.offline_until)).toBeLessThanOrEqual(s.clock.now + 7 * DAY);
  });
});

describe('takror (replay)', () => {
  it('o‘sha nonce ikkinchi marta — 400; o‘sha attestatsiya tokeni boshqa hisobda — 403', async () => {
    const s = makeServer();
    const [a, b] = [uniqueEmail('rp-a'), uniqueEmail('rp-b')];
    const ua = await s.signIn(a);
    const ub = await s.signIn(b);
    const ch = await s.call('POST', '/v1/billing/trial/challenge', { token: ua.token });
    const body = (email: string) => ({
      tier: 'student',
      email,
      attestation: { platform: 'android', token: `fake:replay-phone:${ch.data.nonce}`, nonce: ch.data.nonce },
    });
    expect((await s.call('POST', '/v1/billing/trial/start', { token: ua.token, ip: `${freshNet()}.1`, body: body(a) })).status).toBe(201);
    const again = await s.call('POST', '/v1/billing/trial/start', { token: ua.token, ip: `${freshNet()}.1`, body: body(a) });
    expect([again.status, again.data.error]).toEqual([409, 'trial_already_used']);
    // B o'z nonce'ini oladi, lekin A ning tokenini yuboradi.
    const chB = await s.call('POST', '/v1/billing/trial/challenge', { token: ub.token });
    const stolen = await s.call('POST', '/v1/billing/trial/start', {
      token: ub.token,
      ip: `${freshNet()}.1`,
      body: { tier: 'student', email: b, attestation: { platform: 'android', token: `fake:replay-phone:${ch.data.nonce}`, nonce: chB.data.nonce } },
    });
    expect([stolen.status, stolen.data.error]).toEqual([403, 'device_attestation_failed']);
  });
});

describe('poyga (parallel start)', () => {
  it('bitta hisob, ikki parallel so‘rov (ikki qurilma) — aynan bittasi 201', async () => {
    const s = makeServer();
    const email = uniqueEmail('race-user');
    const u = await s.signIn(email);
    const [c1, c2] = await Promise.all([
      s.call('POST', '/v1/billing/trial/challenge', { token: u.token }),
      s.call('POST', '/v1/billing/trial/challenge', { token: u.token }),
    ]);
    const go = (nonce: string, device: string) =>
      s.call('POST', '/v1/billing/trial/start', {
        token: u.token,
        ip: `${freshNet()}.2`,
        body: { tier: 'student', email, attestation: { platform: 'android', token: `fake:${device}:${nonce}`, nonce } },
      });
    const res = await Promise.all([go(c1.data.nonce, dev()), go(c2.data.nonce, dev())]);
    expect(res.map((r) => r.status).sort()).toEqual([201, 409]);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM pro_trials WHERE user_id = ?1').bind(u.userId).first<{ n: number }>();
    expect(n!.n).toBe(1);
  });

  it('bitta telefon, ikki hisob parallel — aynan bittasi 201', async () => {
    const s = makeServer();
    const phone = dev();
    const [a, b] = [uniqueEmail('race-a'), uniqueEmail('race-b')];
    const ua = await s.signIn(a);
    const ub = await s.signIn(b);
    const res = await Promise.all([start(s, ua.token, a, phone), start(s, ub.token, b, phone)]);
    expect(res.map((r) => r.status).sort()).toEqual([201, 409]);
  });
});

describe('qayta ro‘yxatdan o‘tish: email variantlari va o‘sha qurilma', () => {
  const variants: ((l: string) => [string, string])[] = [
    (l) => [`${l}@gmail.com`, `${l.slice(0, 2)}.${l.slice(2)}@gmail.com`],
    (l) => [`${l}@gmail.com`, `${l}+trial2@googlemail.com`],
    (l) => [`${l}@gmail.com`, `${l.toUpperCase()}@GMAIL.COM`],
    (l) => [`${l}@outlook.com`, `${l}+x@outlook.com`],
    (l) => [`${l}@yandex.ru`, `${l}+x@ya.ru`],
    (l) => [`${l}@yandex.com`, `${l}@yandex.ru`],
  ];

  it('har variant — o‘sha kanonik email: ikkinchi hisob (yangi qurilmada ham) — 409', async () => {
    const s = makeServer();
    for (const v of variants) {
      const [orig, alias] = v(`re${Date.now().toString(36)}${Math.random().toString(36).slice(2, 8)}`);
      expect(canonicalEmail(orig)).toBe(canonicalEmail(alias));
      const u1 = await s.signIn(orig);
      const u2 = await s.signIn(alias);
      expect((await start(s, u1.token, orig, dev())).status).toBe(201);
      const r = await start(s, u2.token, alias, dev());
      expect([alias, r.status, r.data.error]).toEqual([alias, 409, 'trial_already_used']);
    }
  });

  it('hisob o‘chirilib, boshqa email + o‘sha qurilma — 409; boshqa email + boshqa qurilma — 201 (qolgan xavf: yangi email + yangi qurilma)', async () => {
    const s = makeServer();
    const phone = dev();
    const a = uniqueEmail('rr-a');
    const ua = await s.signIn(a);
    expect((await start(s, ua.token, a, phone)).status).toBe(201);
    expect((await s.call('DELETE', '/v1/me', { token: ua.token })).status).toBe(204);
    const b = uniqueEmail('rr-b');
    const ub = await s.signIn(b);
    expect((await start(s, ub.token, b, phone)).status).toBe(409);
    expect((await start(s, ub.token, b, dev())).status).toBe(201);
  });
});

describe('IP tarmog‘i: “yangi hisob → sinov” cheklovi', () => {
  it(`bitta /24 dan sutkasiga ${NEW_ACCOUNT_TRIALS_PER_PREFIX_DAY} ta yangi hisob sinovi; keyingisi 429; ertasi kuni yana`, async () => {
    const s = makeServer();
    const netA = freshNet();
    const ok: number[] = [];
    for (let i = 0; i < NEW_ACCOUNT_TRIALS_PER_PREFIX_DAY; i++) {
      const e = uniqueEmail(`pfx${i}`);
      const u = await s.signIn(e);
      ok.push((await start(s, u.token, e, dev(), { ip: `${netA}.${10 + i}` })).status);
    }
    expect(ok).toEqual(Array(NEW_ACCOUNT_TRIALS_PER_PREFIX_DAY).fill(201));
    const e = uniqueEmail('pfx-over');
    const u = await s.signIn(e);
    const over = await start(s, u.token, e, dev(), { ip: `${netA}.200` });
    expect(over.status).toBe(429);
    expect(over.data.retry_after).toBeGreaterThan(0);
    // Rad etilgan urinish sinovni "ishlatmaydi": boshqa tarmoqdan — 201.
    expect((await start(s, u.token, e, dev(), { ip: `${freshNet()}.1` })).status).toBe(201);
    // Eski hisob (24 soatdan oldin yaratilgan) o'sha tarmoqdan — ruxsat.
    const oldE = uniqueEmail('pfx-old');
    const old = await s.signIn(oldE);
    s.clock.now += 25 * 3600_000;
    expect((await start(s, old.token, oldE, dev(), { ip: `${netA}.201` })).status).toBe(201);
    // Ertasi kuni (oyna o'tdi) — yangi hisob yana.
    const nE = uniqueEmail('pfx-next');
    const n = await s.signIn(nE);
    expect((await start(s, n.token, nE, dev(), { ip: `${netA}.202` })).status).toBe(201);
  });

  it('IPv6: bitta /48 ichidagi manzillar bitta tarmoq sanaladi', async () => {
    const s = makeServer();
    const p = `2001:db8:${(++net).toString(16)}`;
    for (let i = 0; i < NEW_ACCOUNT_TRIALS_PER_PREFIX_DAY; i++) {
      const e = uniqueEmail(`v6-${i}`);
      const u = await s.signIn(e);
      expect((await start(s, u.token, e, dev(), { ip: `${p}:${i + 1}::${i + 5}` })).status).toBe(201);
    }
    const e = uniqueEmail('v6-over');
    const u = await s.signIn(e);
    expect((await start(s, u.token, e, dev(), { ip: `${p}:ffff:0:0:0:0:1` })).status).toBe(429);
    expect((await start(s, u.token, e, dev(), { ip: `2001:db8:${(++net).toString(16)}::1` })).status).toBe(201);
  });
});

describe('email domenlari (ixtiyoriy ro‘yxat, standart bo‘sh)', () => {
  it('TRIAL_BLOCKED_EMAIL_DOMAINS dagi domen va uning subdomeni — 403; standart — ruxsat', async () => {
    const s = makeServer({ TRIAL_BLOCKED_EMAIL_DOMAINS: 'blocked.test, Throwaway.Test' });
    for (const email of [`x${Date.now()}@blocked.test`, `y${Date.now()}@mail.throwaway.test`]) {
      const u = await s.signIn(email);
      const r = await start(s, u.token, email, dev());
      expect([r.status, r.data.error]).toEqual([403, 'email_domain_not_allowed']);
    }
    const plain = makeServer();
    const email = `z${Date.now()}@blocked.test`;
    const u = await plain.signIn(email);
    expect((await start(plain, u.token, email, dev())).status).toBe(201);
  });
});
