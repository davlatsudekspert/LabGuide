// Obuna davrlari (D-77 addendum): do'kon bepul sinovi / kirish narxi, bekor
// qilish (davr oxirigacha), grace (Apple gracePeriodExpiresDate), yangilash,
// yuqoriga / pastga o'tish (upgrade / downgrade). Haqiqiy tekshiruvchilar
// (verifyApple / verifyGoogle) — soxta fetch bilan; Apple JWS test zanjiri bilan.
import { describe, expect, it } from 'vitest';
import { applePeriodType, playPeriodType } from '../src/billing';
import { clearGoogleTokenCache } from '../src/jwtsign';
import { appleChain } from './apple_jws_fixture';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
const APPLE_SANDBOX = 'https://api.storekit-sandbox.itunes.apple.com';
const PLAY = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/uz.labguide.app/purchases';
const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });
const jws = async (p: unknown) => (await appleChain()).sign(p);

function pem(der: ArrayBuffer): string {
  return `-----BEGIN PRIVATE KEY-----\n${btoa(String.fromCharCode(...new Uint8Array(der))).match(/.{1,64}/g)!.join('\n')}\n-----END PRIVATE KEY-----\n`;
}

interface Tx {
  transactionId: string;
  originalTransactionId: string;
  productId: string;
  expiresDate: number;
  status?: number;
  offerType?: number;
  offerDiscountType?: string;
  renewal?: Record<string, unknown>;
  signedDate?: number;
}

async function appleServer() {
  const pair = (await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, ['sign', 'verify'])) as CryptoKeyPair;
  const s = baseServer({
    LG_BILLING_ENABLED: 'true',
    LG_BILLING_SANDBOX: 'true',
    APPLE_ROOT_CA_SHA256: (await appleChain()).rootSha256,
    APPLE_IAP_KEY_ID: 'KEY123ABCD',
    APPLE_IAP_ISSUER_ID: '57246542-96fe-1a63-e053-0824d011072a',
    APPLE_IAP_PRIVATE_KEY: pem((await crypto.subtle.exportKey('pkcs8', pair.privateKey)) as ArrayBuffer),
  } as never);
  const txs = new Map<string, Tx>();
  s.setFetch(async (url) => {
    if (!url.startsWith(APPLE_SANDBOX)) return reply({ errorCode: 4040010 }, 404);
    const m = /\/inApps\/v1\/(transactions|subscriptions)\/(\d+)$/.exec(url);
    const tx = m && txs.get(m[2]);
    if (!tx) return reply({ errorCode: 4040010 }, 404);
    const info = {
      transactionId: tx.transactionId,
      originalTransactionId: tx.originalTransactionId,
      bundleId: 'uz.labguide.app',
      productId: tx.productId,
      purchaseDate: tx.expiresDate - 30 * DAY,
      originalPurchaseDate: tx.expiresDate - 30 * DAY,
      expiresDate: tx.expiresDate,
      inAppOwnershipType: 'PURCHASED',
      environment: 'Sandbox',
      signedDate: tx.signedDate ?? s.clock.now,
      offerType: tx.offerType,
      offerDiscountType: tx.offerDiscountType,
    };
    if (m![1] === 'transactions') return reply({ signedTransactionInfo: await jws(info) });
    return reply({
      data: [
        {
          subscriptionGroupIdentifier: '21000000',
          lastTransactions: [
            {
              originalTransactionId: tx.originalTransactionId,
              status: tx.status ?? 1,
              signedTransactionInfo: await jws(info),
              signedRenewalInfo: await jws({ originalTransactionId: tx.originalTransactionId, productId: tx.productId, ...(tx.renewal ?? {}) }),
            },
          ],
        },
      ],
    });
  });
  const verify = (token: string, txId: string) =>
    s.call('POST', '/v1/billing/verify', { token, body: { platform: 'app_store', token: txId } });
  return { s, txs, verify };
}

describe('App Store: davr turi va yangilash ma’lumoti', () => {
  it('kirish taklifi FREE_TRIAL — huquq bor (to‘liq), period_type=trial; yangilanadi', async () => {
    const { s, txs, verify } = await appleServer();
    txs.set('3000000001', {
      transactionId: '3000000001',
      originalTransactionId: '3000000001',
      productId: 'uz.labguide.student.monthly',
      expiresDate: s.clock.now + 7 * DAY,
      offerType: 1,
      offerDiscountType: 'FREE_TRIAL',
      renewal: { autoRenewStatus: 1, autoRenewProductId: 'uz.labguide.student.monthly' },
    });
    const u = await s.signIn(uniqueEmail('ios-trial'));
    const r = await verify(u.token, '3000000001');
    expect(r.status, r.text).toBe(200);
    expect(r.data.items[0]).toMatchObject({ status: 'active', period_type: 'trial', auto_renew: true, pending_product_id: null, plan: 'student' });
    expect(r.data.resolved).toMatchObject({ source: 'store', plan: 'student' });
    expect((await s.call('GET', '/v1/pro/check/learner', { token: u.token })).status).toBe(200);
  });

  it('kirish narxi (PAY_AS_YOU_GO) — intro; oddiy davr — normal', () => {
    expect(applePeriodType({ offerType: 1, offerDiscountType: 'PAY_AS_YOU_GO' })).toBe('intro');
    expect(applePeriodType({ offerType: 2, offerDiscountType: 'FREE_TRIAL' })).toBe('normal'); // promo — sinov emas
    expect(applePeriodType({})).toBe('normal');
    expect(applePeriodType({ isTrialPeriod: 'true' })).toBe('trial'); // eski maydon
  });

  it('bekor qilish (autoRenewStatus=0): davr oxirigacha huquq, auto_renew=false; muddat o‘tgach yo‘q', async () => {
    const { s, txs, verify } = await appleServer();
    const exp = s.clock.now + 10 * DAY;
    txs.set('3000000002', {
      transactionId: '3000000002',
      originalTransactionId: '3000000002',
      productId: 'uz.labguide.specialist.monthly',
      expiresDate: exp,
      renewal: { autoRenewStatus: 0, autoRenewProductId: 'uz.labguide.specialist.monthly' },
    });
    const u = await s.signIn(uniqueEmail('ios-cancel'));
    const r = await verify(u.token, '3000000002');
    expect(r.data.items[0]).toMatchObject({ status: 'active', auto_renew: false });
    expect((await s.call('GET', '/v1/pro/check/lab', { token: u.token })).status).toBe(200);
    s.clock.now = exp + 1;
    expect((await s.call('GET', '/v1/pro/check/lab', { token: u.token })).status).toBe(403);
  });

  it('grace (status 4): tranzaksiya muddati o‘tgan, huquq gracePeriodExpiresDate gacha', async () => {
    const { s, txs, verify } = await appleServer();
    const graceEnd = s.clock.now + 6 * DAY;
    txs.set('3000000003', {
      transactionId: '3000000003',
      originalTransactionId: '3000000003',
      productId: 'uz.labguide.student.monthly',
      expiresDate: s.clock.now - DAY,
      status: 4,
      renewal: { autoRenewStatus: 1, gracePeriodExpiresDate: graceEnd, isInBillingRetryPeriod: true },
    });
    const u = await s.signIn(uniqueEmail('ios-grace'));
    const r = await verify(u.token, '3000000003');
    expect(r.data.items[0]).toMatchObject({ status: 'grace_period', expires_at: new Date(graceEnd).toISOString() });
    expect(r.data.resolved).toMatchObject({ source: 'store', plan: 'student' });
    s.clock.now = graceEnd + 1;
    expect((await s.call('GET', '/v1/billing/entitlements', { token: u.token })).data.resolved).toBeNull();
  });

  it('billing retry (status 3) — huquq yo‘q; keyin DID_RENEW (status 1) — qaytadi', async () => {
    const { s, txs, verify } = await appleServer();
    const tx: Tx = {
      transactionId: '3000000004',
      originalTransactionId: '3000000004',
      productId: 'uz.labguide.student.monthly',
      expiresDate: s.clock.now - DAY,
      status: 3,
      renewal: { autoRenewStatus: 1, isInBillingRetryPeriod: true },
    };
    txs.set(tx.transactionId, tx);
    const u = await s.signIn(uniqueEmail('ios-retry'));
    expect((await verify(u.token, tx.transactionId)).data.resolved).toBeNull();
    s.clock.now += 1000;
    txs.set(tx.transactionId, { ...tx, status: 1, expiresDate: s.clock.now + 30 * DAY, signedDate: s.clock.now });
    const r = await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'app_store', token: tx.transactionId, restore: true } });
    expect(r.data.resolved).toMatchObject({ source: 'store', plan: 'student' });
  });

  it('pastga o‘tish (Premium → Talaba, keyingi yangilanishda): hozir Premium, pending_product_id = Talaba', async () => {
    const { s, txs, verify } = await appleServer();
    txs.set('3000000005', {
      transactionId: '3000000005',
      originalTransactionId: '3000000005',
      productId: 'uz.labguide.premium.yearly',
      expiresDate: s.clock.now + 100 * DAY,
      renewal: { autoRenewStatus: 1, autoRenewProductId: 'uz.labguide.student.yearly' },
    });
    const u = await s.signIn(uniqueEmail('ios-down'));
    const r = await verify(u.token, '3000000005');
    expect(r.data.items[0]).toMatchObject({ product_id: 'uz.labguide.premium.yearly', pending_product_id: 'uz.labguide.student.yearly', plan: 'premium' });
    expect(r.data.resolved.plan).toBe('premium');
  });

  it('yuqoriga o‘tish (Talaba → Mutaxassis, darhol): o‘sha original id — bitta qator, yangi mahsulot', async () => {
    const { s, txs, verify } = await appleServer();
    txs.set('3000000006', { transactionId: '3000000006', originalTransactionId: '3000000006', productId: 'uz.labguide.student.monthly', expiresDate: s.clock.now + 20 * DAY });
    const u = await s.signIn(uniqueEmail('ios-up'));
    expect((await verify(u.token, '3000000006')).data.resolved.plan).toBe('student');
    s.clock.now += 1000;
    txs.set('3000000007', {
      transactionId: '3000000007',
      originalTransactionId: '3000000006',
      productId: 'uz.labguide.specialist.monthly',
      expiresDate: s.clock.now + 30 * DAY,
      signedDate: s.clock.now,
    });
    const r = await verify(u.token, '3000000007');
    expect(r.data.items.filter((i: any) => i.source === 'store')).toHaveLength(1);
    expect(r.data.items[0]).toMatchObject({ product_id: 'uz.labguide.specialist.monthly' });
    expect(r.data.resolved.plan).toBe('specialist');
  });
});

describe('Google Play: davr turi, bekor qilish, almashtirish', () => {
  async function playServer() {
    clearGoogleTokenCache();
    const pair = (await crypto.subtle.generateKey(
      { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
      true,
      ['sign', 'verify'],
    )) as CryptoKeyPair;
    const s = baseServer({
      LG_BILLING_ENABLED: 'true',
      LG_BILLING_SANDBOX: 'true',
      GOOGLE_PLAY_SERVICE_ACCOUNT: JSON.stringify({
        client_email: 'billing@labguide-test.iam.gserviceaccount.test',
        private_key: pem((await crypto.subtle.exportKey('pkcs8', pair.privateKey)) as ArrayBuffer),
      }),
    } as never);
    const subs: Record<string, any> = {};
    s.setFetch(async (url) => {
      if (url === 'https://oauth2.googleapis.com/token') return reply({ access_token: 'ya29.t', expires_in: 3600 });
      if (url.includes(':acknowledge')) return new Response(null, { status: 204 });
      const m = /\/subscriptionsv2\/tokens\/([^/]+)$/.exec(url);
      const sub = m && url.startsWith(PLAY) && subs[decodeURIComponent(m[1])];
      return sub ? reply(sub) : reply({ error: { code: 400 } }, 400);
    });
    return { s, subs };
  }
  const sub = (s: ReturnType<typeof baseServer>, product: string, basePlan: string, extra: Record<string, unknown> = {}, item: Record<string, unknown> = {}) => ({
    subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
    acknowledgementState: 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',
    startTime: new Date(s.clock.now - DAY).toISOString(),
    testPurchase: {},
    lineItems: [
      {
        productId: product,
        expiryTime: new Date(s.clock.now + 7 * DAY).toISOString(),
        offerDetails: { basePlanId: basePlan },
        autoRenewingPlan: { autoRenewEnabled: true },
        ...item,
      },
    ],
    ...extra,
  });

  it('free trial bosqichi (offerPhase.freeTrial) — huquq bor, period_type=trial', async () => {
    const { s, subs } = await playServer();
    subs['ptok-trial-0000001'] = sub(s, 'uz.labguide.student', 'monthly', {}, { offerDetails: { basePlanId: 'monthly', offerId: 'free-week' }, offerPhase: { freeTrial: {} } });
    const u = await s.signIn(uniqueEmail('play-trial'));
    const r = await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'play_store', token: 'ptok-trial-0000001' } });
    expect(r.status, r.text).toBe(200);
    expect(r.data.items[0]).toMatchObject({ product_id: 'uz.labguide.student.monthly', status: 'active', period_type: 'trial', auto_renew: true });
    expect(playPeriodType({ offerPhase: { introductoryPrice: {} } }, {})).toBe('intro');
    expect(playPeriodType({}, { paymentState: 2 })).toBe('trial');
    expect(playPeriodType({ offerPhase: { basePrice: {} } }, {})).toBe('normal');
  });

  it('CANCELED (yangilanmaydi) — davr oxirigacha huquq, auto_renew=false', async () => {
    const { s, subs } = await playServer();
    subs['ptok-cancel-000001'] = sub(s, 'uz.labguide.specialist', 'yearly', { subscriptionState: 'SUBSCRIPTION_STATE_CANCELED' }, { autoRenewingPlan: { autoRenewEnabled: false } });
    const u = await s.signIn(uniqueEmail('play-cancel'));
    const r = await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'play_store', token: 'ptok-cancel-000001' } });
    expect(r.data.items[0]).toMatchObject({ status: 'active', auto_renew: false });
    expect(r.data.resolved.plan).toBe('specialist');
  });

  it('yuqoriga o‘tish: yangi token linkedPurchaseToken bilan — o‘sha qator yangilanadi (ikki obuna emas)', async () => {
    const { s, subs } = await playServer();
    subs['ptok-old-00000001'] = sub(s, 'uz.labguide.student', 'monthly');
    const u = await s.signIn(uniqueEmail('play-up'));
    await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'play_store', token: 'ptok-old-00000001' } });
    subs['ptok-old-00000001'] = sub(s, 'uz.labguide.student', 'monthly', { subscriptionState: 'SUBSCRIPTION_STATE_EXPIRED' });
    subs['ptok-new-00000002'] = sub(s, 'uz.labguide.premium', 'monthly', { linkedPurchaseToken: 'ptok-old-00000001' });
    const r = await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'play_store', token: 'ptok-new-00000002' } });
    const store = r.data.items.filter((i: any) => i.source === 'store');
    expect(store).toHaveLength(1);
    expect(store[0]).toMatchObject({ product_id: 'uz.labguide.premium.monthly', status: 'active' });
    expect(r.data.resolved.plan).toBe('premium');
  });

  it('pastga o‘tish keyingi davrda (deferredItemReplacement) — hozirgi reja qoladi, pending_product_id', async () => {
    const { s, subs } = await playServer();
    subs['ptok-defer-000001'] = sub(s, 'uz.labguide.premium', 'yearly', {}, { deferredItemReplacement: { productId: 'uz.labguide.student' } });
    const u = await s.signIn(uniqueEmail('play-down'));
    const r = await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'play_store', token: 'ptok-defer-000001' } });
    expect(r.data.items[0]).toMatchObject({ product_id: 'uz.labguide.premium.yearly', pending_product_id: 'uz.labguide.student.yearly' });
    expect(r.data.resolved.plan).toBe('premium');
  });
});
