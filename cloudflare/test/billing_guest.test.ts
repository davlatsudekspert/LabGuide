// Mehmon (hisobsiz) do'kon huquqlari — Apple 5.1.1(v) (src/guest.ts, D-77 addendum).
// Do'kon tekshiruvchilari soxta (test/fake_store.ts); haqiqiy do'konga murojaat yo'q.
import { describe, expect, it } from 'vitest';
import { GUEST_MAX_DEVICES, GUEST_RESYNC_MS } from '../src/guest';
import { FakeStoreVerifier } from './fake_store';
import { makeServer as baseServer, uniqueEmail } from './helpers';

const DAY = 86400_000;
type Srv = ReturnType<typeof baseServer>;

function setup(extra: Record<string, string> = {}) {
  const s = baseServer({ LG_BILLING_ENABLED: 'true', PLAY_RTDN_TOKEN: 'rtdn-guest', ...extra } as never);
  const apple = new FakeStoreVerifier('app_store');
  const play = new FakeStoreVerifier('play_store');
  apple.now = () => s.clock.now;
  play.now = () => s.clock.now;
  s.setStoreVerifier('app_store', apple);
  s.setStoreVerifier('play_store', play);
  return { s, apple, play };
}

let seq = 0;
const deviceId = () => `dev-${crypto.randomUUID()}`;
const ip = () => `192.0.2.${(++seq % 250) + 1}`;
const guestVerify = (s: Srv, body: Record<string, unknown>) => s.call('POST', '/v1/billing/guest/verify', { ip: ip(), body });
const guestRefresh = (s: Srv, device: string, tokens: string[]) =>
  s.call('POST', '/v1/billing/guest/entitlements', { ip: ip(), body: { device_id: device, guest_tokens: tokens } });
const tx = () => `${1000000000 + ++seq}`;

describe('mehmon: siyosat va inert holat', () => {
  it('status.guest: Talaba va Mutaxassis mehmonga; teacher_panel — faqat hisob (TIER_CAPABILITIES dan)', async () => {
    const { s } = setup();
    expect((await s.call('GET', '/v1/billing/status')).data.guest).toEqual({
      purchase_plans: ['student', 'specialist'],
      account_only_capabilities: ['teacher_panel'],
      max_devices: GUEST_MAX_DEVICES,
    });
  });

  it('bayroq o‘chiq — 404; tekshiruvchi sozlanmagan — 503; noto‘g‘ri device_id — 400', async () => {
    const off = baseServer();
    expect((await off.call('POST', '/v1/billing/guest/verify', { body: {} })).status).toBe(404);
    const { s, apple } = setup();
    apple.isConfigured = false;
    expect((await guestVerify(s, { platform: 'app_store', device_id: deviceId(), token: tx() })).data.error).toBe('store_verifier_not_configured');
    expect((await guestVerify(s, { platform: 'play_store', device_id: 'x', token: 'tok-aaaaaaaaaa' })).data.error).toBe('invalid_device_id');
  });
});

describe('mehmon: xarid, tiklash, yangilash', () => {
  it('Talaba xaridi (sessiyasiz): learner ochiladi, imzolangan token; bazada xom qurilma id si yo‘q, hisob qatori yo‘q', async () => {
    const { s, apple } = setup();
    const t = tx();
    apple.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 30 * DAY });
    const dev = deviceId();
    const r = await guestVerify(s, { platform: 'app_store', device_id: dev, product_id: 'uz.labguide.student.monthly', token: t });
    expect(r.status, r.text).toBe(200);
    expect(r.data).toMatchObject({ guest: true, capabilities: ['learner'], sign_in_required: false, account_only_capabilities: ['teacher_panel'] });
    expect(r.data.items[0]).toMatchObject({ source: 'store_guest', guest_state: 'active', status: 'active', plan: 'student' });
    expect(r.data.guest_tokens).toHaveLength(1);
    expect(r.data.guest_tokens[0]).toMatch(/^g1\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/);
    expect(Date.parse(r.data.offline_until)).toBe(s.clock.now + 7 * DAY);
    const devRows = await s.env.DB.prepare('SELECT device_key FROM store_guest_devices WHERE original_transaction_id = ?1').bind(t).all<{ device_key: string }>();
    expect(devRows.results).toHaveLength(1);
    expect(devRows.results[0].device_key).not.toContain(dev);
    expect((await s.env.DB.prepare('SELECT COUNT(*) AS n FROM entitlements WHERE original_transaction_id = ?1').bind(t).first<{ n: number }>())!.n).toBe(0);

    // Yangilash: o'sha qurilma — faol; boshqa qurilma yoki buzilgan token — e'tiborsiz.
    const tok = r.data.guest_tokens[0] as string;
    expect((await guestRefresh(s, dev, [tok])).data.capabilities).toEqual(['learner']);
    const other = await guestRefresh(s, deviceId(), [tok]);
    expect(other.data).toMatchObject({ capabilities: [], items: [] });
    const [a, b, c] = tok.split('.');
    const forged = `${a}.${btoa(JSON.stringify({ p: 'app_store', o: '999', d: 'x', iat: 0 })).replace(/=+$/, '')}.${c}`;
    expect((await guestRefresh(s, dev, [forged, `${a}.${b}.AAAA`])).data.items).toEqual([]);
  });

  it('Premium xaridini mehmon tiklasa: learner + lab, teacher_panel YO‘Q (faqat hisob bilan)', async () => {
    const { s, play } = setup();
    const t = `play-guest-${crypto.randomUUID()}`;
    play.set(t, { productId: 'uz.labguide.premium.yearly', status: 'active', expiresAt: s.clock.now + 300 * DAY });
    const r = await guestVerify(s, { platform: 'play_store', device_id: deviceId(), purchases: [{ token: t }], restore: true });
    expect(r.data.capabilities).toEqual(['learner', 'lab']);
    expect(r.data.capabilities).not.toContain('teacher_panel');
    expect(r.data.items[0].plan).toBe('premium');
  });

  it('do‘kon sinovi (period_type=trial) mehmonga ham huquq beradi; tiklashda topilmagan — 400; muddati o‘tgan — huquq yo‘q', async () => {
    const { s, apple } = setup();
    const t = tx();
    apple.set(t, { productId: 'uz.labguide.specialist.monthly', status: 'active', expiresAt: s.clock.now + 7 * DAY, periodType: 'trial', autoRenew: true });
    const dev = deviceId();
    const r = await guestVerify(s, { platform: 'app_store', device_id: dev, token: t });
    expect(r.data.items[0]).toMatchObject({ period_type: 'trial', auto_renew: true });
    expect(r.data.capabilities).toEqual(['learner', 'lab']);
    expect((await guestVerify(s, { platform: 'app_store', device_id: dev, token: '42' })).data.error).toBe('purchase_not_found');
    s.clock.now += 8 * DAY;
    expect((await guestRefresh(s, dev, r.data.guest_tokens)).data.capabilities).toEqual([]);
  });

  it('hisobda sotib olingan (appAccountToken) yoki hisobga bog‘langan xarid — mehmonga yo‘q, sign_in_required', async () => {
    const { s, apple } = setup();
    const u = await s.signIn(uniqueEmail('owner'));
    const hinted = tx();
    apple.set(hinted, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 30 * DAY, accountHint: u.userId.toLowerCase() });
    const r1 = await guestVerify(s, { platform: 'app_store', device_id: deviceId(), token: hinted });
    expect(r1.data).toMatchObject({ capabilities: [], guest_tokens: [], sign_in_required: true });
    expect(r1.data.items[0].guest_state).toBe('sign_in_required');

    const bound = tx();
    apple.set(bound, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 30 * DAY });
    expect((await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'app_store', token: bound } })).status).toBe(200);
    const r2 = await guestVerify(s, { platform: 'app_store', device_id: deviceId(), token: bound });
    expect(r2.data.items[0].guest_state).toBe('account_linked');
    expect(r2.data.capabilities).toEqual([]);
  });

  it(`bitta xarid ko‘pi bilan ${GUEST_MAX_DEVICES} qurilmada; keyingisi device_limit; ma’lum qurilma — davom etadi`, async () => {
    const { s, apple } = setup();
    const t = tx();
    apple.set(t, { productId: 'uz.labguide.student.yearly', status: 'active', expiresAt: s.clock.now + 300 * DAY });
    const devices = Array.from({ length: GUEST_MAX_DEVICES }, deviceId);
    for (const d of devices) expect((await guestVerify(s, { platform: 'app_store', device_id: d, token: t })).data.capabilities).toEqual(['learner']);
    const extra = await guestVerify(s, { platform: 'app_store', device_id: deviceId(), token: t });
    expect(extra.data.items[0].guest_state).toBe('device_limit');
    expect(extra.data.items[0].status).toBe('device_limit'); // huquq bermaydigan status
    expect(extra.data.capabilities).toEqual([]);
    expect((await guestVerify(s, { platform: 'app_store', device_id: devices[0], token: t })).data.capabilities).toEqual(['learner']);
  });

  it('sandbox xaridi production rejimida — 403; LG_BILLING_SANDBOX=true — qabul', async () => {
    const prod = setup();
    const t = tx();
    prod.apple.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: prod.s.clock.now + DAY, environment: 'sandbox' });
    expect((await guestVerify(prod.s, { platform: 'app_store', device_id: deviceId(), token: t })).data.error).toBe('sandbox_not_allowed');
    const sb = setup({ LG_BILLING_SANDBOX: 'true' });
    sb.apple.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: sb.s.clock.now + DAY, environment: 'sandbox' });
    expect((await guestVerify(sb.s, { platform: 'app_store', device_id: deviceId(), token: t })).data.items[0].environment).toBe('sandbox');
  });
});

describe('mehmon: bildirishnomalar va qayta o‘qish', () => {
  it('RTDN refund (voided) mehmon qatorini ham revoked qiladi — huquq darhol yo‘q', async () => {
    const { s, play } = setup();
    const t = `play-guest-refund-${crypto.randomUUID()}`;
    play.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 30 * DAY });
    const dev = deviceId();
    const r = await guestVerify(s, { platform: 'play_store', device_id: dev, token: t });
    expect(r.data.capabilities).toEqual(['learner']);
    const n = await s.call('POST', '/v1/billing/google/rtdn?token=rtdn-guest', {
      body: { message: { messageId: `g-${crypto.randomUUID()}`, data: btoa(JSON.stringify({ packageName: 'uz.labguide.app', voidedPurchaseNotification: { purchaseToken: t } })) } },
    });
    expect(n.data.updated).toBe(true);
    const after = await guestRefresh(s, dev, r.data.guest_tokens);
    expect(after.data.capabilities).toEqual([]);
    expect(after.data.items[0].status).toBe('revoked');
  });

  it(`qator ${GUEST_RESYNC_MS / 3600_000} soatdan eski — do‘kondan qayta o‘qiladi (bekor/tugagan holat ko‘rinadi)`, async () => {
    const { s, apple } = setup();
    const t = tx();
    apple.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 30 * DAY });
    const dev = deviceId();
    const r = await guestVerify(s, { platform: 'app_store', device_id: dev, token: t });
    apple.update(t, { status: 'expired', expiresAt: s.clock.now + 1000 });
    s.clock.now += GUEST_RESYNC_MS - 60_000;
    expect((await guestRefresh(s, dev, r.data.guest_tokens)).data.capabilities).toEqual(['learner']); // hali keshdan
    s.clock.now += 120_000;
    const after = await guestRefresh(s, dev, r.data.guest_tokens);
    expect(after.data.items[0].status).toBe('expired');
    expect(after.data.capabilities).toEqual([]);
  });
});

describe('mehmon → hisob (ikki marta berilmaydi)', () => {
  it('link: xarid hisobga o‘tadi; keyin mehmon tokeni huquq bermaydi; ikkinchi hisob ololmaydi', async () => {
    const { s, apple } = setup();
    const t = tx();
    apple.set(t, { productId: 'uz.labguide.specialist.yearly', status: 'active', expiresAt: s.clock.now + 300 * DAY });
    const dev = deviceId();
    const g = await guestVerify(s, { platform: 'app_store', device_id: dev, token: t });
    const tokens = g.data.guest_tokens as string[];
    expect((await s.call('POST', '/v1/billing/guest/link', { body: { device_id: dev, guest_tokens: tokens } })).status).toBe(401);

    const a = await s.signIn(uniqueEmail('link-a'));
    const l = await s.call('POST', '/v1/billing/guest/link', { token: a.token, body: { device_id: dev, guest_tokens: tokens } });
    expect(l.status, l.text).toBe(200);
    expect(l.data.resolved).toMatchObject({ source: 'store', plan: 'specialist' });
    expect(l.data.owned_by_other).toBe(false);
    expect((await s.call('GET', '/v1/pro/check/lab', { token: a.token })).status).toBe(200);

    // Mehmon tokeni endi huquq bermaydi (bir xarid — bir joyda).
    const after = await guestRefresh(s, dev, tokens);
    expect(after.data).toMatchObject({ capabilities: [], sign_in_required: true });
    expect(after.data.items[0].guest_state).toBe('account_linked');
    expect((await guestVerify(s, { platform: 'app_store', device_id: deviceId(), token: t })).data.items[0].guest_state).toBe('account_linked');

    // Boshqa hisob o'sha tokenni bog'lay olmaydi.
    const b = await s.signIn(uniqueEmail('link-b'));
    const lb = await s.call('POST', '/v1/billing/guest/link', { token: b.token, body: { device_id: dev, guest_tokens: tokens } });
    expect(lb.data).toMatchObject({ owned_by_other: true, resolved: null });
    // Takroriy link (o'sha hisob) — idempotent.
    const again = await s.call('POST', '/v1/billing/guest/link', { token: a.token, body: { device_id: dev, guest_tokens: tokens } });
    expect(again.data.resolved.plan).toBe('specialist');
    expect(again.data.items.filter((i: any) => i.source === 'store')).toHaveLength(1);
  });

  it('hisobga kirgan holda oddiy /v1/billing/verify ham mehmon qatorini “bog‘langan” qiladi', async () => {
    const { s, apple } = setup();
    const t = tx();
    apple.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 30 * DAY });
    const dev = deviceId();
    const g = await guestVerify(s, { platform: 'app_store', device_id: dev, token: t });
    const u = await s.signIn(uniqueEmail('verify-link'));
    expect((await s.call('POST', '/v1/billing/verify', { token: u.token, body: { platform: 'app_store', token: t } })).data.resolved.plan).toBe('student');
    expect((await guestRefresh(s, dev, g.data.guest_tokens)).data.capabilities).toEqual([]);
  });

  it('link: boshqa qurilmaning tokeni — e’tiborsiz (hech narsa o‘tmaydi); bo‘sh ro‘yxat — 400', async () => {
    const { s, apple } = setup();
    const t = tx();
    apple.set(t, { productId: 'uz.labguide.student.monthly', status: 'active', expiresAt: s.clock.now + 30 * DAY });
    const g = await guestVerify(s, { platform: 'app_store', device_id: deviceId(), token: t });
    const u = await s.signIn(uniqueEmail('link-wrongdev'));
    const l = await s.call('POST', '/v1/billing/guest/link', { token: u.token, body: { device_id: deviceId(), guest_tokens: g.data.guest_tokens } });
    expect(l.data.resolved).toBeNull();
    expect((await s.call('POST', '/v1/billing/guest/link', { token: u.token, body: { device_id: deviceId(), guest_tokens: [] } })).status).toBe(400);
  });
});
