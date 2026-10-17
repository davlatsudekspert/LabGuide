// Pro obunalari (src/billing.ts): App Store / Google Play tekshiruvi,
// hisobga bog'lash, "boshqa hisobda", bildirishnomalar. Do'kon API'lari —
// soxta `fetch` (haqiqiy tarmoqqa murojaat yo'q); kalitlar test ichida yaratiladi.

import { describe, expect, it } from 'vitest';
import { makeServer, uniqueEmail } from './helpers';

const APPLE_PROD = 'https://api.storekit.itunes.apple.com';
const APPLE_SANDBOX = 'https://api.storekit-sandbox.itunes.apple.com';
const PLAY = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/uz.labguide.app/purchases';
const DAY = 86400_000;

const b64 = (v: unknown) =>
  btoa(JSON.stringify(v)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
/** Do'kon imzolagan JWS ko'rinishi (server faqat yuklamani o'qiydi). */
const jws = (payload: unknown) => `${b64({ alg: 'ES256', x5c: [] })}.${b64(payload)}.c2ln`;

function pem(der: ArrayBuffer): string {
  const s = btoa(String.fromCharCode(...new Uint8Array(der)));
  return `-----BEGIN PRIVATE KEY-----\n${s.match(/.{1,64}/g)!.join('\n')}\n-----END PRIVATE KEY-----\n`;
}

async function appleKey() {
  const pair = (await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, [
    'sign',
    'verify',
  ])) as CryptoKeyPair;
  return { pem: pem((await crypto.subtle.exportKey('pkcs8', pair.privateKey)) as ArrayBuffer), pub: pair.publicKey };
}

async function googleKey() {
  const pair = (await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
    true,
    ['sign', 'verify'],
  )) as CryptoKeyPair;
  return JSON.stringify({
    client_email: 'billing@labguide-test.iam.gserviceaccount.com',
    private_key: pem((await crypto.subtle.exportKey('pkcs8', pair.privateKey)) as ArrayBuffer),
    token_uri: 'https://oauth2.googleapis.com/token',
  });
}

const reply = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });

interface AppleTx {
  transactionId: string;
  originalTransactionId: string;
  productId?: string;
  bundleId?: string;
  expiresDate: number;
  status?: number;
  revocationDate?: number;
  appAccountToken?: string;
  signedDate?: number;
}

/** Soxta App Store Server API: tranzaksiya faqat sandbox'da (production 404). */
function appleStore(txs: AppleTx[]) {
  return async (url: string) => {
    if (url.startsWith(APPLE_PROD)) return reply({ errorCode: 4040010, errorMessage: 'Transaction id not found.' }, 404);
    const m = /\/inApps\/v1\/(transactions|subscriptions)\/(\d+)$/.exec(url);
    const tx = m && txs.find((t) => t.transactionId === m[2]);
    if (!url.startsWith(APPLE_SANDBOX) || !tx) return reply({ errorCode: 4040010 }, 404);
    const info = {
      transactionId: tx.transactionId,
      originalTransactionId: tx.originalTransactionId,
      bundleId: tx.bundleId ?? 'uz.labguide.app',
      productId: tx.productId ?? 'uz.labguide.pro.monthly',
      type: 'Auto-Renewable Subscription',
      purchaseDate: tx.expiresDate - 30 * DAY,
      originalPurchaseDate: tx.expiresDate - 30 * DAY,
      expiresDate: tx.expiresDate,
      revocationDate: tx.revocationDate,
      inAppOwnershipType: 'PURCHASED',
      environment: 'Sandbox',
      appAccountToken: tx.appAccountToken,
      signedDate: tx.signedDate ?? tx.expiresDate - 30 * DAY,
    };
    if (m![1] === 'transactions') return reply({ signedTransactionInfo: jws(info) });
    return reply({
      environment: 'Sandbox',
      bundleId: info.bundleId,
      data: [
        {
          subscriptionGroupIdentifier: '21000000',
          lastTransactions: [
            {
              originalTransactionId: tx.originalTransactionId,
              status: tx.status ?? 1,
              signedTransactionInfo: jws(info),
              signedRenewalInfo: jws({}),
            },
          ],
        },
      ],
    });
  };
}

async function appleServer() {
  const key = await appleKey();
  const s = makeServer({
    APPLE_IAP_KEY_ID: 'KEY123ABCD',
    APPLE_IAP_ISSUER_ID: '57246542-96fe-1a63-e053-0824d011072a',
    APPLE_IAP_PRIVATE_KEY: key.pem,
  } as never);
  return { s, key };
}

describe('billing: sozlanmagan server', () => {
  it("status — ikkalasi false; verify — 503 not_configured; snapshot bo'sh", async () => {
    const s = makeServer();
    const st = await s.call('GET', '/v1/billing/status');
    expect(st.status).toBe(200);
    expect(st.data).toEqual({ app_store: false, play_store: false });

    expect((await s.call('GET', '/v1/billing/entitlements')).status).toBe(401);
    const { token } = await s.signIn(uniqueEmail('bill'));
    const v = await s.call('POST', '/v1/billing/verify', {
      token,
      body: { platform: 'app_store', product_id: 'uz.labguide.pro.monthly', token: '2000000001' },
    });
    expect(v.status).toBe(503);
    expect(v.data.error).toBe('not_configured');
    const e = await s.call('GET', '/v1/billing/entitlements', { token });
    expect(e.status).toBe(200);
    expect(e.data.items).toEqual([]);
    expect(e.data.owned_by_other).toBe(false);
    expect(typeof e.data.server_time).toBe('string');
    // Eski yo'l ham shu javobni beradi (ilova kontrakti).
    expect((await s.call('GET', '/v1/entitlements', { token })).data.items).toEqual([]);
    expect(s.fetchCalls).toHaveLength(0);
  });

  it('bildirishnomalar ham 503 (do‘kon qayta yuboradi)', async () => {
    const s = makeServer();
    expect((await s.call('POST', '/v1/billing/apple/notifications', { body: { signedPayload: 'a.b.c' } })).status).toBe(503);
    expect((await s.call('POST', '/v1/billing/google/rtdn', { body: { message: {} } })).status).toBe(503);
  });
});

describe('billing: App Store', () => {
  it('xarid tekshiriladi (production → sandbox), ES256 JWT, Pro hisobga yoziladi', async () => {
    const { s, key } = await appleServer();
    const exp = s.clock.now + 20 * DAY;
    s.setFetch(appleStore([{ transactionId: '2000000101', originalTransactionId: '2000000100', expiresDate: exp }]));
    expect((await s.call('GET', '/v1/billing/status')).data).toEqual({ app_store: true, play_store: false });
    const u = await s.signIn(uniqueEmail('ios'));
    const r = await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'app_store', product_id: 'uz.labguide.pro.monthly', token: '2000000101' },
    });
    expect(r.status, r.text).toBe(200);
    expect(r.data.owned_by_other).toBe(false);
    expect(r.data.items).toHaveLength(1);
    expect(r.data.items[0]).toMatchObject({
      product_id: 'uz.labguide.pro.monthly',
      platform: 'app_store',
      status: 'active',
      environment: 'sandbox',
      ownership: 'purchased',
      expires_at: new Date(exp).toISOString(),
    });
    // Avval production, keyin sandbox.
    expect(s.fetchCalls[0].url).toBe(`${APPLE_PROD}/inApps/v1/transactions/2000000101`);
    expect(s.fetchCalls[1].url).toBe(`${APPLE_SANDBOX}/inApps/v1/transactions/2000000101`);

    // JWT: ES256, kid, aud, bid — imzo ochiq kalit bilan tekshiriladi.
    const auth = new Headers(s.fetchCalls[0].init!.headers).get('authorization')!;
    const [h, p, sig] = auth.replace('Bearer ', '').split('.');
    const dec = (x: string) => JSON.parse(atob(x.replace(/-/g, '+').replace(/_/g, '/')));
    expect(dec(h)).toMatchObject({ alg: 'ES256', kid: 'KEY123ABCD', typ: 'JWT' });
    expect(dec(p)).toMatchObject({ aud: 'appstoreconnect-v1', bid: 'uz.labguide.app', iss: '57246542-96fe-1a63-e053-0824d011072a' });
    const raw = Uint8Array.from(atob(sig.replace(/-/g, '+').replace(/_/g, '/') + '=='.slice(0, (4 - (sig.length % 4)) % 4)), (c) =>
      c.charCodeAt(0),
    );
    const ok = await crypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' }, key.pub, raw, new TextEncoder().encode(`${h}.${p}`));
    expect(ok).toBe(true);

    const snap = await s.call('GET', '/v1/billing/entitlements', { token: u.token });
    expect(snap.data.items[0].status).toBe('active');
  });

  it("bitta xarid ikkinchi hisobga o'tmaydi (owned_by_other)", async () => {
    const { s } = await appleServer();
    s.setFetch(appleStore([{ transactionId: '2000000201', originalTransactionId: '2000000200', expiresDate: s.clock.now + 9 * DAY }]));
    const a = await s.signIn(uniqueEmail('a'));
    const b = await s.signIn(uniqueEmail('b'));
    const body = { platform: 'app_store', product_id: 'uz.labguide.pro.monthly', token: '2000000201' };
    expect((await s.call('POST', '/v1/billing/verify', { token: a.token, body })).data.items).toHaveLength(1);
    const rb = await s.call('POST', '/v1/billing/verify', { token: b.token, body: { ...body, restore: true } });
    expect(rb.status).toBe(200);
    expect(rb.data.owned_by_other).toBe(true);
    expect(rb.data.items).toEqual([]);
    // A ning qatori o'zgarmadi.
    const row = await s.env.DB.prepare('SELECT user_id FROM entitlements WHERE original_transaction_id = ?1')
      .bind('2000000200')
      .first<{ user_id: string }>();
    expect(row!.user_id).toBe(a.userId);
  });

  it('appAccountToken boshqa hisobniki — bog‘lanmaydi', async () => {
    const { s } = await appleServer();
    s.setFetch(
      appleStore([
        {
          transactionId: '2000000301',
          originalTransactionId: '2000000300',
          expiresDate: s.clock.now + 9 * DAY,
          appAccountToken: '11111111-2222-4333-8444-555555555555',
        },
      ]),
    );
    const u = await s.signIn(uniqueEmail('hint'));
    const r = await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'app_store', product_id: 'uz.labguide.pro.monthly', token: '2000000301' },
    });
    expect(r.data.owned_by_other).toBe(true);
    expect(r.data.items).toEqual([]);
  });

  it('boshqa ilova (bundle), noma’lum mahsulot va mos kelmagan mahsulot — 400', async () => {
    const { s } = await appleServer();
    s.setFetch(
      appleStore([
        { transactionId: '2000000401', originalTransactionId: '2000000400', expiresDate: s.clock.now + DAY, bundleId: 'com.other.app' },
        { transactionId: '2000000402', originalTransactionId: '2000000402', expiresDate: s.clock.now + DAY, productId: 'com.other.pro' },
        { transactionId: '2000000403', originalTransactionId: '2000000403', expiresDate: s.clock.now + DAY },
      ]),
    );
    const u = await s.signIn(uniqueEmail('bad'));
    const post = (token: string, product_id = 'uz.labguide.pro.monthly') =>
      s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'app_store', product_id, token } });
    expect((await post('2000000401')).data.error).toBe('wrong_bundle');
    expect((await post('2000000402')).data.error).toBe('unknown_product');
    expect((await post('2000000403', 'uz.labguide.teacherpro.yearly')).data.error).toBe('product_mismatch');
    expect((await post('2000000499')).data.error).toBe('purchase_not_found');
    expect((await post('abc')).data.error).toBe('invalid_token');
    expect((await post('2000000403', 'labguide.pro.monthly')).data.error).toBe('unknown_product');
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM entitlements WHERE user_id = ?1').bind(u.userId).first<{ n: number }>();
    expect(n!.n).toBe(0);
  });

  it('ASSN v2: refund — holat API dan qayta o‘qiladi va revoked bo‘ladi; soxta tana ishonilmaydi', async () => {
    const { s } = await appleServer();
    const tx: AppleTx = { transactionId: '2000000501', originalTransactionId: '2000000500', expiresDate: s.clock.now + 9 * DAY };
    s.setFetch(appleStore([tx]));
    const u = await s.signIn(uniqueEmail('refund'));
    await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'app_store', product_id: 'uz.labguide.pro.monthly', token: '2000000501' },
    });
    // Bildirishnomada "faol" deyilgan, lekin API qaytarilgan deydi — API ustun.
    tx.status = 5;
    tx.revocationDate = s.clock.now;
    tx.signedDate = s.clock.now;
    const payload = jws({
      notificationType: 'REFUND',
      data: { bundleId: 'uz.labguide.app', signedTransactionInfo: jws({ transactionId: '2000000501', status: 1 }) },
    });
    const n = await s.call('POST', '/v1/billing/apple/notifications', { body: { signedPayload: payload } });
    expect(n.status, n.text).toBe(200);
    expect(n.data.updated).toBe(true);
    const snap = await s.call('GET', '/v1/billing/entitlements', { token: u.token });
    expect(snap.data.items[0].status).toBe('revoked');

    // Boshqa ilovaning bildirishnomasi — e'tiborsiz (do'kon qayta yubormasin: 200).
    const other = await s.call('POST', '/v1/billing/apple/notifications', {
      body: { signedPayload: jws({ data: { bundleId: 'com.other', signedTransactionInfo: jws({ transactionId: '1' }) } }) },
    });
    expect(other.status).toBe(200);
    expect(other.data.ignored).toBe(true);
  });

  it('eski hodisa yangisining ustidan yozilmaydi', async () => {
    const { s } = await appleServer();
    const tx: AppleTx = {
      transactionId: '2000000601',
      originalTransactionId: '2000000600',
      expiresDate: s.clock.now + 9 * DAY,
      signedDate: s.clock.now,
    };
    s.setFetch(appleStore([tx]));
    const u = await s.signIn(uniqueEmail('stale'));
    const body = { platform: 'app_store', product_id: 'uz.labguide.pro.monthly', token: '2000000601' };
    await s.call('POST', '/v1/billing/verify', { token: u.token, body });
    tx.status = 2;
    tx.signedDate = s.clock.now - DAY;
    const r = await s.call('POST', '/v1/billing/verify', { token: u.token, body });
    expect(r.data.items[0].status).toBe('active');
  });

  it("hisob o'chirilsa obuna qatorlari ham o'chadi", async () => {
    const { s } = await appleServer();
    s.setFetch(appleStore([{ transactionId: '2000000701', originalTransactionId: '2000000700', expiresDate: s.clock.now + DAY }]));
    const u = await s.signIn(uniqueEmail('del'));
    await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'app_store', product_id: 'uz.labguide.pro.monthly', token: '2000000701' },
    });
    expect((await s.call('DELETE', '/v1/me', { token: u.token })).status).toBe(204);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM entitlements WHERE user_id = ?1').bind(u.userId).first<{ n: number }>();
    expect(n!.n).toBe(0);
  });
});

describe('billing: Google Play', () => {
  async function playServer(extra: Record<string, string> = {}) {
    const sa = await googleKey();
    return makeServer({ GOOGLE_PLAY_SERVICE_ACCOUNT: sa, ...extra } as never);
  }

  function playStore(s: ReturnType<typeof makeServer>, subs: Record<string, any>) {
    const acks: string[] = [];
    s.setFetch(async (url, init) => {
      if (url === 'https://oauth2.googleapis.com/token') {
        expect(String(init?.body)).toContain('grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer');
        return reply({ access_token: 'ya29.test', expires_in: 3600 });
      }
      const ack = /\/subscriptions\/([^/]+)\/tokens\/([^/]+):acknowledge$/.exec(url);
      if (ack) {
        acks.push(`${decodeURIComponent(ack[1])}:${decodeURIComponent(ack[2])}`);
        return new Response(null, { status: 204 });
      }
      const m = /\/subscriptionsv2\/tokens\/([^/]+)$/.exec(url);
      const sub = m && subs[decodeURIComponent(m[1])];
      if (!url.startsWith(PLAY) || !sub) return reply({ error: { code: 400 } }, 400);
      expect(new Headers(init?.headers).get('authorization')).toBe('Bearer ya29.test');
      return reply(sub);
    });
    return acks;
  }

  const active = (s: ReturnType<typeof makeServer>, productId = 'uz.labguide.teacherpro.yearly', extra = {}) => ({
    kind: 'androidpublisher#subscriptionPurchaseV2',
    subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
    acknowledgementState: 'ACKNOWLEDGEMENT_STATE_PENDING',
    startTime: new Date(s.clock.now - DAY).toISOString(),
    lineItems: [{ productId, expiryTime: new Date(s.clock.now + 13 * DAY).toISOString() }],
    testPurchase: {},
    ...extra,
  });

  it('subscriptionsv2: faol obuna yoziladi va server tasdiqlaydi (acknowledge)', async () => {
    const s = await playServer();
    const token = 'play-token-aaaaaaaaaaaa.1';
    const acks = playStore(s, { [token]: active(s) });
    const u = await s.signIn(uniqueEmail('android'));
    const r = await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'play_store', product_id: 'uz.labguide.teacherpro.yearly', token },
    });
    expect(r.status, r.text).toBe(200);
    expect(r.data.items[0]).toMatchObject({
      product_id: 'uz.labguide.teacherpro.yearly',
      platform: 'play_store',
      status: 'active',
      environment: 'sandbox',
    });
    expect(acks).toEqual([`uz.labguide.teacherpro.yearly:${token}`]);
  });

  it('kutilayotgan (pending) xarid — 409, hech narsa yozilmaydi; bekor qilingan lekin muddati bor — faol', async () => {
    const s = await playServer();
    const pending = 'play-token-pending-000001';
    const canceled = 'play-token-canceled-00001';
    playStore(s, {
      [pending]: active(s, 'uz.labguide.pro.monthly', { subscriptionState: 'SUBSCRIPTION_STATE_PENDING' }),
      [canceled]: active(s, 'uz.labguide.pro.monthly', {
        subscriptionState: 'SUBSCRIPTION_STATE_CANCELED',
        acknowledgementState: 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',
      }),
    });
    const u = await s.signIn(uniqueEmail('pend'));
    const p = await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'play_store', product_id: 'uz.labguide.pro.monthly', token: pending },
    });
    expect(p.status).toBe(409);
    expect(p.data.error).toBe('purchase_pending');
    const c = await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'play_store', purchases: [{ product_id: 'uz.labguide.pro.monthly', token: canceled }] },
    });
    expect(c.data.items[0].status).toBe('active');
  });

  it("obfuscatedAccountId boshqa hisobniki — bog'lanmaydi", async () => {
    const s = await playServer();
    const token = 'play-token-other-account';
    playStore(s, {
      [token]: active(s, 'uz.labguide.pro.monthly', {
        externalAccountIdentifiers: { obfuscatedExternalAccountId: 'f'.repeat(64) },
      }),
    });
    const u = await s.signIn(uniqueEmail('obf'));
    const r = await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'play_store', product_id: 'uz.labguide.pro.monthly', token },
    });
    expect(r.data.owned_by_other).toBe(true);
  });

  it('RTDN: token talab qilinadi; holat API dan qayta o‘qiladi (refund → revoked)', async () => {
    const s = await playServer({ PLAY_RTDN_TOKEN: 'rtdn-secret-token' });
    const token = 'play-token-rtdn-00000001';
    const subs: Record<string, any> = { [token]: active(s, 'uz.labguide.pro.yearly') };
    playStore(s, subs);
    const u = await s.signIn(uniqueEmail('rtdn'));
    await s.call('POST', '/v1/billing/verify', {
      token: u.token,
      body: { platform: 'play_store', product_id: 'uz.labguide.pro.yearly', token },
    });
    const msg = (n: unknown) => ({ message: { data: btoa(JSON.stringify(n)), messageId: '1' }, subscription: 'x' });
    const voided = msg({ packageName: 'uz.labguide.app', voidedPurchaseNotification: { purchaseToken: token } });
    expect((await s.call('POST', '/v1/billing/google/rtdn', { body: voided })).status).toBe(403);
    expect((await s.call('POST', '/v1/billing/google/rtdn?token=wrong', { body: voided })).status).toBe(403);

    // API hali faol desa — refund xabariga ishonilmaydi.
    const keep = await s.call('POST', '/v1/billing/google/rtdn?token=rtdn-secret-token', { body: voided });
    expect(keep.status).toBe(200);
    expect((await s.call('GET', '/v1/billing/entitlements', { token: u.token })).data.items[0].status).toBe('active');

    subs[token] = { ...subs[token], subscriptionState: 'SUBSCRIPTION_STATE_EXPIRED' };
    s.clock.now += 1000;
    const r = await s.call('POST', '/v1/billing/google/rtdn?token=rtdn-secret-token', { body: voided });
    expect(r.data.updated).toBe(true);
    expect((await s.call('GET', '/v1/billing/entitlements', { token: u.token })).data.items[0].status).toBe('revoked');

    // Boshqa paket — e'tiborsiz.
    const other = await s.call('POST', '/v1/billing/google/rtdn?token=rtdn-secret-token', {
      body: msg({ packageName: 'com.other', subscriptionNotification: { purchaseToken: token } }),
    });
    expect(other.data.ignored).toBe(true);
  });
});
