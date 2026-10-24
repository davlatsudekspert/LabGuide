// Obuna hayot sikli (D-75): bekor qilish, muddat tugashi, grace, hold/pause,
// refund/revoke, yangilanish, tiklashda qayta sinxronlash, sandbox qoidasi,
// RTDN OIDC autentifikatsiyasi, bildirishnomalar idempotentligi va jurnali,
// muddat tugagach bepul imkoniyatlar ishlashda davom etishi.
// Do'kon tekshiruvchilari — soxta (test/fake_store.ts): haqiqiy do'konga
// murojaat yo'q; Apple bildirishnoma imzosi — test zanjiri (apple_jws_fixture.ts).
import { describe, expect, it } from 'vitest';
import { offlineUntil, OFFLINE_MAX_MS } from '../src/billing';
import { appleChain } from './apple_jws_fixture';
import { FakeStoreVerifier } from './fake_store';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
type Srv = ReturnType<typeof baseServer>;

async function setup(extra: Record<string, string> = {}) {
  const s = baseServer({
    LG_BILLING_ENABLED: 'true',
    APPLE_ROOT_CA_SHA256: (await appleChain()).rootSha256,
    PLAY_RTDN_TOKEN: 'rtdn-test-token',
    ...extra,
  } as never);
  const apple = new FakeStoreVerifier('app_store');
  const play = new FakeStoreVerifier('play_store');
  apple.now = () => s.clock.now;
  play.now = () => s.clock.now;
  s.setStoreVerifier('app_store', apple);
  s.setStoreVerifier('play_store', play);
  return { s, apple, play };
}

const buy = (s: Srv, token: string, platform: string, product: string, purchase: string) =>
  s.call('POST', '/v1/billing/verify', { token, body: { platform, product_id: product, token: purchase } });
const ents = async (s: Srv, token: string) => (await s.call('GET', '/v1/billing/entitlements', { token })).data;

let uuidSeq = 0;
async function assn(s: Srv, type: string, txId: string, subtype?: string) {
  const chain = await appleChain();
  const signedPayload = await chain.sign({
    notificationType: type,
    subtype,
    notificationUUID: `00000000-0000-4000-8000-${String(++uuidSeq).padStart(12, '0')}`,
    data: { bundleId: 'uz.labguide.app', environment: 'Production', signedTransactionInfo: await chain.sign({ transactionId: txId }) },
  });
  return s.call('POST', '/v1/billing/apple/notifications', { body: { signedPayload } });
}

let msgSeq = 0;
const rtdn = (s: Srv, n: Record<string, unknown>) =>
  s.call('POST', '/v1/billing/google/rtdn?token=rtdn-test-token', {
    body: { message: { messageId: `m-${++msgSeq}`, data: btoa(JSON.stringify({ packageName: 'uz.labguide.app', ...n })) } },
  });

describe('hayot sikli: App Store (soxta tekshiruvchi + imzolangan ASSN v2)', () => {
  it('bekor qilish: davr oxirigacha huquq bor, EXPIRED dan keyin yo‘q; DID_RENEW qaytaradi', async () => {
    const { s, apple } = await setup();
    const u = await s.signIn(uniqueEmail('cancel'));
    const end = s.clock.now + 10 * DAY;
    apple.set('3000000001', { productId: 'uz.labguide.teacher.monthly', status: 'active', expiresAt: end });
    expect((await buy(s, u.token, 'app_store', 'uz.labguide.teacher.monthly', '3000000001')).status).toBe(200);
    // Foydalanuvchi avtomatik yangilashni o'chirdi: Apple holati baribir 1 (active) — muddat oxirigacha.
    s.clock.now += DAY;
    expect((await assn(s, 'DID_CHANGE_RENEWAL_STATUS', '3000000001', 'AUTO_RENEW_DISABLED')).status).toBe(200);
    expect((await ents(s, u.token)).resolved).toMatchObject({ plan: 'teacher', source: 'store' });
    // Muddat tugadi.
    s.clock.now = end + 1000;
    apple.update('3000000001', { status: 'expired' });
    expect((await assn(s, 'EXPIRED', '3000000001', 'VOLUNTARY')).data.updated).toBe(true);
    const after = await ents(s, u.token);
    expect(after.resolved).toBeNull();
    expect(after.items[0].status).toBe('expired');
    // Qayta obuna / yangilanish.
    apple.update('3000000001', { status: 'active', expiresAt: s.clock.now + 30 * DAY });
    s.clock.now += 1000;
    await assn(s, 'DID_RENEW', '3000000001');
    expect((await ents(s, u.token)).resolved.plan).toBe('teacher');
  });

  it('DID_FAIL_TO_RENEW: GRACE_PERIOD — huquq qoladi; subtype bo‘sh (billing retry) — yo‘q', async () => {
    const { s, apple } = await setup();
    const u = await s.signIn(uniqueEmail('grace'));
    apple.set('3000000011', { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + DAY });
    await buy(s, u.token, 'app_store', 'uz.labguide.student.monthly', '3000000011');
    s.clock.now += 2 * DAY;
    apple.update('3000000011', { status: 'grace_period', expiresAt: s.clock.now + 6 * DAY });
    await assn(s, 'DID_FAIL_TO_RENEW', '3000000011', 'GRACE_PERIOD');
    expect((await ents(s, u.token)).resolved?.plan).toBe('student');
    s.clock.now += 7 * DAY;
    apple.update('3000000011', { status: 'billing_retry' });
    await assn(s, 'GRACE_PERIOD_EXPIRED', '3000000011');
    expect((await ents(s, u.token)).resolved).toBeNull();
  });

  it('REVOKE (masalan, oila ulashuvi olindi) — darhol huquq yo‘q', async () => {
    const { s, apple } = await setup();
    const u = await s.signIn(uniqueEmail('revoke'));
    apple.set('3000000021', { productId: 'uz.labguide.specialist.yearly', status: 'active', expiresAt: s.clock.now + 300 * DAY });
    await buy(s, u.token, 'app_store', 'uz.labguide.specialist.yearly', '3000000021');
    await assn(s, 'REVOKE', '3000000021');
    const e = await ents(s, u.token);
    expect(e.items[0].status).toBe('revoked');
    expect(e.resolved).toBeNull();
  });
});

describe('hayot sikli: Google Play (soxta tekshiruvchi + RTDN)', () => {
  it('ON_HOLD va PAUSED — huquq yo‘q; IN_GRACE_PERIOD — bor; RECOVERED — qaytadi; REVOKED — darhol yo‘q', async () => {
    const { s, play } = await setup();
    const u = await s.signIn(uniqueEmail('hold'));
    const t = 'play-lifecycle-token-0001';
    play.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 20 * DAY, needsAck: true });
    await buy(s, u.token, 'play_store', 'uz.labguide.student.monthly', t);
    expect(play.acks).toEqual([t]);
    const plan = async () => (await ents(s, u.token)).resolved?.plan ?? null;

    play.update(t, { status: 'grace_period' });
    await rtdn(s, { subscriptionNotification: { purchaseToken: t, notificationType: 6 } });
    expect(await plan()).toBe('student');

    play.update(t, { status: 'billing_retry' }); // SUBSCRIPTION_STATE_ON_HOLD
    await rtdn(s, { subscriptionNotification: { purchaseToken: t, notificationType: 5 } });
    expect(await plan()).toBeNull();

    play.update(t, { status: 'active' });
    await rtdn(s, { subscriptionNotification: { purchaseToken: t, notificationType: 1 } });
    expect(await plan()).toBe('student');

    play.update(t, { status: 'paused' });
    await rtdn(s, { subscriptionNotification: { purchaseToken: t, notificationType: 10 } });
    expect(await plan()).toBeNull();

    play.update(t, { status: 'active' });
    await rtdn(s, { subscriptionNotification: { purchaseToken: t, notificationType: 7 } });
    expect(await plan()).toBe('student');

    // REVOKED: API hali faol desa ham — darhol.
    const r = await rtdn(s, { subscriptionNotification: { purchaseToken: t, notificationType: 12 } });
    expect(r.data.updated).toBe(true);
    expect(await plan()).toBeNull();
    const rows = await s.env.DB.prepare(`SELECT COUNT(*) AS n FROM audit_log WHERE action = 'billing_notification' AND target LIKE 'play_store:%'`).first<{ n: number }>();
    expect(rows!.n).toBeGreaterThanOrEqual(6);
  });

  it('sandbox (test) bildirishnomasi production rejimida e’tiborsiz; LG_BILLING_SANDBOX=true bo‘lsa qabul, muhit yoziladi', async () => {
    const prod = await setup();
    const u = await prod.s.signIn(uniqueEmail('sbx'));
    prod.play.set('play-sandbox-token-0001', { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: prod.s.clock.now + DAY, environment: 'sandbox' });
    const r = await buy(prod.s, u.token, 'play_store', 'uz.labguide.student.monthly', 'play-sandbox-token-0001');
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('sandbox_not_allowed');

    const test = await setup({ LG_BILLING_SANDBOX: 'true' });
    const v = await test.s.signIn(uniqueEmail('sbx2'));
    test.play.set('play-sandbox-token-0002', { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: test.s.clock.now + DAY, environment: 'sandbox' });
    const ok = await buy(test.s, v.token, 'play_store', 'uz.labguide.student.monthly', 'play-sandbox-token-0002');
    expect(ok.status).toBe(200);
    expect(ok.data.items[0].environment).toBe('sandbox');
    expect((await test.s.call('GET', '/v1/billing/status')).data.sandbox).toBe(true);
  });
});

describe('tiklash (restore): serverda qayta sinxronlash', () => {
  it('restore: true — boshqa qurilmada bekor qilingan / tugagan obuna serverda yangilanadi; huquq qo‘shilmaydi', async () => {
    const { s, apple } = await setup();
    const u = await s.signIn(uniqueEmail('resync'));
    apple.set('3000000101', { productId: 'uz.labguide.teacher.yearly', status: 'active', expiresAt: s.clock.now + 100 * DAY });
    apple.set('3000000102', { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 20 * DAY });
    await buy(s, u.token, 'app_store', 'uz.labguide.teacher.yearly', '3000000101');
    expect((await ents(s, u.token)).resolved.plan).toBe('teacher');
    // Ustoz obunasi qaytarildi (bildirishnoma kelmadi); boshqa qurilmada tiklash faqat Talaba xaridini yubordi.
    s.clock.now += 1000;
    apple.update('3000000101', { status: 'revoked' });
    const r = await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'app_store', restore: true, purchases: [{ product_id: 'uz.labguide.student.monthly', token: '3000000102' }] },
    });
    expect(r.status).toBe(200);
    expect(r.data.resolved.plan).toBe('student');
    expect(r.data.items.find((i: any) => i.product_id === 'uz.labguide.teacher.yearly').status).toBe('revoked');
    expect(apple.calls).toContain('3000000101');
  });
});

describe('RTDN OIDC (Pub/Sub push JWT)', () => {
  it('PLAY_RTDN_AUDIENCE berilsa: Google imzosi, aud, email, email_verified tekshiriladi', async () => {
    const { s, play } = await setup({ PLAY_RTDN_TOKEN: '', PLAY_RTDN_AUDIENCE: 'https://api.test/rtdn', PLAY_RTDN_SERVICE_ACCOUNT: 'push@proj.iam.gserviceaccount.com' });
    const pair = (await crypto.subtle.generateKey(
      { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
      true,
      ['sign', 'verify'],
    )) as CryptoKeyPair;
    const jwk = (await crypto.subtle.exportKey('jwk', pair.publicKey)) as JsonWebKey;
    const kid = `kid-${crypto.randomUUID()}`;
    s.setFetch(async (url) => {
      if (url === 'https://www.googleapis.com/oauth2/v3/certs') {
        return new Response(JSON.stringify({ keys: [{ kty: 'RSA', kid, alg: 'RS256', use: 'sig', n: jwk.n, e: jwk.e }] }), {
          headers: { 'content-type': 'application/json', 'cache-control': 'max-age=3600' },
        });
      }
      throw new Error(url);
    });
    const b64u = (u: Uint8Array) => btoa(String.fromCharCode(...u)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
    const enc = new TextEncoder();
    const sign = async (claims: Record<string, unknown>) => {
      const h = b64u(enc.encode(JSON.stringify({ alg: 'RS256', kid, typ: 'JWT' })));
      const p = b64u(enc.encode(JSON.stringify(claims)));
      const sig = new Uint8Array(await crypto.subtle.sign('RSASSA-PKCS1-v1_5', pair.privateKey, enc.encode(`${h}.${p}`)));
      return `${h}.${p}.${b64u(sig)}`;
    };
    const now = Math.floor(s.clock.now / 1000);
    const good = {
      iss: 'https://accounts.google.com',
      aud: 'https://api.test/rtdn',
      email: 'push@proj.iam.gserviceaccount.com',
      email_verified: true,
      iat: now - 10,
      exp: now + 3000,
    };
    const u = await s.signIn(uniqueEmail('oidc'));
    play.set('play-oidc-token-000001', { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 9 * DAY });
    await buy(s, u.token, 'play_store', 'uz.labguide.student.monthly', 'play-oidc-token-000001');
    let id = 0;
    const post = (auth?: string) =>
      s.call('POST', '/v1/billing/google/rtdn', {
        headers: auth ? { authorization: `Bearer ${auth}` } : {},
        body: {
          message: {
            messageId: `oidc-${++id}`,
            data: btoa(JSON.stringify({ packageName: 'uz.labguide.app', subscriptionNotification: { purchaseToken: 'play-oidc-token-000001', notificationType: 12 } })),
          },
        },
      });
    expect((await post()).status).toBe(401);
    expect((await post(await sign({ ...good, aud: 'https://evil.test' }))).status).toBe(401);
    expect((await post(await sign({ ...good, email: 'other@x.iam.gserviceaccount.com' }))).status).toBe(401);
    expect((await post(await sign({ ...good, email_verified: false }))).status).toBe(401);
    expect((await post(await sign({ ...good, exp: now - 3600 }))).status).toBe(401);
    expect((await post(await sign({ ...good, iss: 'https://evil.test' }))).status).toBe(401);
    expect((await ents(s, u.token)).resolved?.plan).toBe('student');
    const ok = await post(await sign(good));
    expect(ok.status, ok.text).toBe(200);
    expect((await ents(s, u.token)).resolved).toBeNull();
  });
});

describe('muddat tugagach bepul imkoniyatlar ishlaydi (server)', () => {
  it('Pro tugadi — bepul ustoz paneli, profil va hamjamiyat yo‘llari avvalgidek', async () => {
    const { s, apple } = await setup();
    const t = await s.signInTeacher(uniqueEmail('freeafter'));
    apple.set('3000000201', { productId: 'uz.labguide.teacher.monthly', status: 'active', expiresAt: s.clock.now + DAY });
    await buy(s, t.token, 'app_store', 'uz.labguide.teacher.monthly', '3000000201');
    s.clock.now += 2 * DAY;
    apple.update('3000000201', { status: 'expired' });
    await assn(s, 'EXPIRED', '3000000201');
    expect((await ents(s, t.token)).resolved).toBeNull();
    // Pro-only namunaviy yo'l — yopiq.
    expect((await s.call('GET', '/v1/pro/check/teacher_panel', { token: t.token })).status).toBe(403);
    // Bepul yo'llar — ochiq.
    expect((await s.call('GET', '/v1/me', { token: t.token })).status).toBe(200);
    const g = await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Guruh A' } });
    expect(g.status, g.text).toBeLessThan(300);
    expect((await s.call('GET', '/v1/groups', { token: t.token })).status).toBe(200);
  });
});

describe('oflayn chegarasi (server bergan offline_until)', () => {
  it('min(hozir + 7 kun, huquq tugashi); huquq yo‘q — hozir', async () => {
    const now = Date.UTC(2026, 9, 24);
    expect(offlineUntil(now, null)).toBe(now);
    expect(offlineUntil(now, { source: 'store', plan: 'student', expiresAt: now + 2 * DAY })).toBe(now + 2 * DAY);
    expect(offlineUntil(now, { source: 'store', plan: 'student', expiresAt: now + 30 * DAY })).toBe(now + OFFLINE_MAX_MS);
    expect(offlineUntil(now, { source: 'admin_grant', plan: 'teacher', expiresAt: null })).toBe(now + 7 * DAY);
    const { s, apple } = await setup();
    const u = await s.signIn(uniqueEmail('offline'));
    apple.set('3000000301', { productId: 'uz.labguide.student.yearly', status: 'active', expiresAt: s.clock.now + 2 * DAY });
    const r = await buy(s, u.token, 'app_store', 'uz.labguide.student.yearly', '3000000301');
    expect(r.data.offline_until).toBe(new Date(s.clock.now + 2 * DAY).toISOString());
  });
});

describe('inert: bayroq o‘chiq', () => {
  it('LG_BILLING_ENABLED yo‘q — bildirishnoma yo‘llari 404, soxta tekshiruvchi ulangan bo‘lsa ham', async () => {
    const s = baseServer();
    const fake = new FakeStoreVerifier('app_store');
    s.setStoreVerifier('app_store', fake);
    s.setStoreVerifier('play_store', new FakeStoreVerifier('play_store'));
    expect((await s.call('POST', '/v1/billing/apple/notifications', { body: { signedPayload: 'a.b.c' } })).status).toBe(404);
    expect((await s.call('POST', '/v1/billing/google/rtdn', { body: {} })).status).toBe(404);
    expect((await s.call('GET', '/v1/billing/status')).status).toBe(404);
    expect(fake.calls).toEqual([]);
  });
});
