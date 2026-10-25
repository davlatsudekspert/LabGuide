// Haqiqiy qurilma attestatsiyasi tekshiruvchilari (src/attestation.ts):
// Google Play Integrity (classic, nonce) va Apple DeviceCheck (ikki bit).
// Tarmoq — FAQAT soxta fetch: Google/Apple serverlariga hech qanday so'rov yo'q.
// Kalitlar test ichida yaratiladi (WebCrypto), tokenlar sintetik.
import { beforeEach, describe, expect, it } from 'vitest';
import {
  checkIntegrityVerdict,
  DeviceCheckVerifier,
  INTEGRITY_MAX_AGE_MS,
  integrityNonce,
  normalizeDigest,
  platformVerifier,
  PlayIntegrityVerifier,
} from '../src/attestation';
import { clearGoogleTokenCache } from '../src/jwtsign';
import { makeServer as baseServer, uniqueEmail } from './helpers';

type Srv = ReturnType<typeof baseServer>;
const PKG = 'uz.labguide.app';
const CERT_HEX = 'ab'.repeat(32);
const CERT_B64URL = btoa(String.fromCharCode(...new Uint8Array(32).fill(0xab))).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

const toPem = (der: ArrayBuffer, label: string) =>
  `-----BEGIN ${label}-----\n${btoa(String.fromCharCode(...new Uint8Array(der))).replace(/(.{64})/g, '$1\n')}\n-----END ${label}-----\n`;

function b64urlJson(part: string): any {
  const pad = part.replace(/-/g, '+').replace(/_/g, '/');
  return JSON.parse(atob(pad + '='.repeat((4 - (pad.length % 4)) % 4)));
}
function b64urlBytes(part: string): Uint8Array {
  const pad = part.replace(/-/g, '+').replace(/_/g, '/');
  const bin = atob(pad + '='.repeat((4 - (pad.length % 4)) % 4));
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
}

let rsa: CryptoKeyPair;
let ec: CryptoKeyPair;
let saJson: string;
let dcPem: string;

beforeEach(async () => {
  clearGoogleTokenCache();
  rsa ??= (await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
    true,
    ['sign', 'verify'],
  )) as CryptoKeyPair;
  ec ??= (await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, ['sign', 'verify'])) as CryptoKeyPair;
  saJson ??= JSON.stringify({
    client_email: 'integrity@test-project.iam.gserviceaccount.test',
    private_key: toPem((await crypto.subtle.exportKey('pkcs8', rsa.privateKey)) as ArrayBuffer, 'PRIVATE KEY'),
  });
  dcPem ??= toPem((await crypto.subtle.exportKey('pkcs8', ec.privateKey)) as ArrayBuffer, 'PRIVATE KEY');
});

async function verifyJwt(jwt: string, alg: 'RS256' | 'ES256') {
  const [h, p, sig] = jwt.split('.');
  const data = new TextEncoder().encode(`${h}.${p}`);
  const ok =
    alg === 'RS256'
      ? await crypto.subtle.verify('RSASSA-PKCS1-v1_5', rsa.publicKey, b64urlBytes(sig), data)
      : await crypto.subtle.verify({ name: 'ECDSA', hash: 'SHA-256' }, ec.publicKey, b64urlBytes(sig), data);
  return { ok, header: b64urlJson(h), payload: b64urlJson(p) };
}

// ------------------------------------------------------------ Play Integrity
function integrityServer(extra: Record<string, string> = {}) {
  const s = baseServer({
    LG_BILLING_ENABLED: 'true',
    PLAY_INTEGRITY_SERVICE_ACCOUNT: saJson,
    PLAY_INTEGRITY_CERT_SHA256: `${CERT_HEX.match(/../g)!.join(':').toUpperCase()}`,
    ...extra,
  } as never);
  s.setAttestation(platformVerifier());
  /** Sintetik Integrity tokenlari: token → Google qaytaradigan yuklama. */
  const tokens = new Map<string, unknown>();
  const seen = { oauth: 0, decode: 0, assertions: [] as any[] };
  let decodeMode: 'ok' | '400' | '500' | 'throw' | 'oauth401' = 'ok';
  s.setFetch(async (url, init) => {
    if (url === 'https://oauth2.googleapis.com/token') {
      seen.oauth++;
      if (decodeMode === 'oauth401') return new Response('{}', { status: 401 });
      const assertion = new URLSearchParams(String(init?.body)).get('assertion')!;
      const v = await verifyJwt(assertion, 'RS256');
      seen.assertions.push(v);
      expect(v.ok).toBe(true);
      return Response.json({ access_token: 'ya29.test-token', expires_in: 3600 });
    }
    if (url === `https://playintegrity.googleapis.com/v1/${PKG}:decodeIntegrityToken`) {
      seen.decode++;
      if (decodeMode === 'throw') throw new Error('network down');
      if (decodeMode === '400') return new Response('{"error":{"code":400}}', { status: 400 });
      if (decodeMode === '500') return new Response('{}', { status: 500 });
      expect((init?.headers as Record<string, string>).authorization).toBe('Bearer ya29.test-token');
      const { integrity_token } = JSON.parse(String(init?.body));
      const payload = tokens.get(integrity_token);
      if (!payload) return new Response('{"error":{"code":400}}', { status: 400 });
      return Response.json({ tokenPayloadExternal: payload });
    }
    throw new Error(`unexpected fetch ${url}`);
  });
  return { s, tokens, seen, setMode: (m: typeof decodeMode) => (decodeMode = m) };
}

const goodPayload = async (nonce: string, deviceId: string, now: number, patch: (p: any) => void = () => {}) => {
  const p: any = {
    requestDetails: { requestPackageName: PKG, nonce: await integrityNonce(nonce, deviceId), timestampMillis: String(now - 2000) },
    appIntegrity: { appRecognitionVerdict: 'PLAY_RECOGNIZED', packageName: PKG, certificateSha256Digest: [CERT_B64URL], versionCode: '42' },
    deviceIntegrity: { deviceRecognitionVerdict: ['MEETS_DEVICE_INTEGRITY'] },
    accountDetails: { appLicensingVerdict: 'LICENSED' },
  };
  patch(p);
  return p;
};

let ipSeq = 0;
const ip = () => `10.77.${++ipSeq & 255}.${1 + (ipSeq % 200)}`;

/** Ilova oqimi: challenge → (Play Integrity tokeni) → start. */
async function androidTrial(
  t: ReturnType<typeof integrityServer>,
  user: { token: string },
  email: string,
  deviceId: string | null,
  patch?: (p: any) => void,
  opts: { claimedDeviceId?: string | null; reuseToken?: string } = {},
) {
  const ch = await t.s.call('POST', '/v1/billing/trial/challenge', { token: user.token, body: { platform: 'android' } });
  if (ch.status !== 200) return { ...ch, integrityToken: '' };
  const nonce = ch.data.nonce as string;
  const integrityToken = opts.reuseToken ?? `pi.${crypto.randomUUID()}.${'x'.repeat(40)}`;
  if (!opts.reuseToken) t.tokens.set(integrityToken, await goodPayload(nonce, deviceId ?? 'none', t.s.clock.now, patch));
  const claimed = opts.claimedDeviceId === undefined ? deviceId : opts.claimedDeviceId;
  const r = await t.s.call('POST', '/v1/billing/trial/start', {
    token: user.token,
    ip: ip(),
    body: {
      tier: 'student',
      email,
      attestation: { platform: 'android', token: integrityToken, nonce, ...(claimed ? { device_id: claimed } : {}) },
    },
  });
  return { ...r, integrityToken };
}

const androidId = () => crypto.randomUUID().replace(/-/g, '').slice(0, 16);

describe('Play Integrity: sozlama (fail closed)', () => {
  it('service account yoki sertifikat barmoq izi yo‘q — sozlanmagan, sinov 503 trial_unavailable, status false', async () => {
    for (const env of [{}, { PLAY_INTEGRITY_SERVICE_ACCOUNT: '{"client_email":"a","private_key":"b"}' }, { PLAY_INTEGRITY_CERT_SHA256: CERT_HEX }]) {
      expect(PlayIntegrityVerifier.configured(env as never)).toBe(false);
      const s = baseServer({ LG_BILLING_ENABLED: 'true', ...env } as never);
      s.setAttestation(platformVerifier());
      const email = uniqueEmail('pi-off');
      const u = await s.signIn(email);
      expect((await s.call('GET', '/v1/billing/status')).data.trial).toMatchObject({ android: false, ios: false });
      const ch = await s.call('POST', '/v1/billing/trial/challenge', { token: u.token });
      expect(ch.status).toBe(503);
      expect(ch.data.error).toBe('trial_unavailable');
      expect(s.fetchCalls).toEqual([]);
    }
    // GOOGLE_PLAY_SERVICE_ACCOUNT ham yaroqli manba (alohida secret berilmasa).
    expect(PlayIntegrityVerifier.configured({ GOOGLE_PLAY_SERVICE_ACCOUNT: '{}', PLAY_INTEGRITY_CERT_SHA256: CERT_HEX } as never)).toBe(true);
  });

  it('barmoq izi: Play Console hex (AB:CD:…) va base64url bir xil normallashadi; yaroqsiz — null', () => {
    expect(normalizeDigest(CERT_HEX.match(/../g)!.join(':').toUpperCase())).toBe(CERT_HEX);
    expect(normalizeDigest(CERT_B64URL)).toBe(CERT_HEX);
    expect(normalizeDigest(`${CERT_B64URL}=`)).toBe(CERT_HEX);
    expect(normalizeDigest('abc')).toBeNull();
    expect(normalizeDigest('')).toBeNull();
  });
});

describe('Play Integrity: server oqimi (soxta Google API)', () => {
  it('to‘g‘ri verdikt — 201; OAuth JWT (RS256, scope playintegrity) imzosi to‘g‘ri; nonce qurilmaga bog‘langan', async () => {
    const t = integrityServer();
    const email = uniqueEmail('pi-ok');
    const u = await t.s.signIn(email);
    const r = await androidTrial(t, u, email, androidId());
    expect(r.status, r.text).toBe(201);
    expect(r.data.resolved).toMatchObject({ source: 'trial', plan: 'student' });
    const a = t.seen.assertions[0];
    expect(a.header).toMatchObject({ alg: 'RS256', typ: 'JWT' });
    expect(a.payload).toMatchObject({
      iss: 'integrity@test-project.iam.gserviceaccount.test',
      scope: 'https://www.googleapis.com/auth/playintegrity',
      aud: 'https://oauth2.googleapis.com/token',
    });
    expect(a.payload.exp - a.payload.iat).toBe(3600);
    // Token va ANDROID_ID bazada xom holda yo'q.
    const row = await t.s.env.DB.prepare('SELECT * FROM pro_trials WHERE user_id = ?1').bind(u.userId).first<any>();
    expect(JSON.stringify(row)).not.toContain(r.integrityToken);
  });

  it('o‘sha qurilma (ANDROID_ID — qayta o‘rnatishda o‘zgarmaydi), boshqa hisob — 409; boshqa qurilma — 201', async () => {
    const t = integrityServer();
    const phone = androidId();
    const [a, b, c] = [uniqueEmail('pi-a'), uniqueEmail('pi-b'), uniqueEmail('pi-c')];
    const ua = await t.s.signIn(a);
    const ub = await t.s.signIn(b);
    const uc = await t.s.signIn(c);
    expect((await androidTrial(t, ua, a, phone)).status).toBe(201);
    const again = await androidTrial(t, ub, b, phone);
    expect(again.status).toBe(409);
    expect(again.data.error).toBe('trial_already_used');
    expect((await androidTrial(t, uc, c, androidId())).status).toBe(201);
  });

  it('device_id ni almashtirish (nonce boshqa qurilma uchun olingan) — 403; device_id yo‘q — 403', async () => {
    const t = integrityServer();
    const email = uniqueEmail('pi-swap');
    const u = await t.s.signIn(email);
    const swapped = await androidTrial(t, u, email, androidId(), undefined, { claimedDeviceId: androidId() });
    expect(swapped.status).toBe(403);
    expect(swapped.data.error).toBe('device_attestation_failed');
    const none = await androidTrial(t, u, email, androidId(), undefined, { claimedDeviceId: null });
    expect(none.status).toBe(403);
  });

  it('bir Integrity tokenini qayta yuborish (yangi nonce bilan) — 403, ikkinchi hisob ham ololmaydi', async () => {
    const t = integrityServer();
    const phone = androidId();
    const [a, b] = [uniqueEmail('pi-rp-a'), uniqueEmail('pi-rp-b')];
    const ua = await t.s.signIn(a);
    const ub = await t.s.signIn(b);
    const first = await androidTrial(t, ua, a, phone);
    expect(first.status).toBe(201);
    const replay = await androidTrial(t, ub, b, phone, undefined, { reuseToken: first.integrityToken });
    expect(replay.status).toBe(403);
    expect(replay.data.error).toBe('device_attestation_failed');
  });

  it('Google xatolari: 400 — 403 (rad); 500 / tarmoq — 502 device_attestation_unavailable; OAuth 401 — 502', async () => {
    for (const [mode, status, code] of [
      ['400', 403, 'device_attestation_failed'],
      ['500', 502, 'device_attestation_unavailable'],
      ['throw', 502, 'device_attestation_unavailable'],
      ['oauth401', 502, 'device_attestation_unavailable'],
    ] as const) {
      clearGoogleTokenCache();
      const t = integrityServer();
      t.setMode(mode);
      const email = uniqueEmail(`pi-${mode}`);
      const u = await t.s.signIn(email);
      const r = await androidTrial(t, u, email, androidId());
      expect([mode, r.status, r.data.error]).toEqual([mode, status, code]);
      // Hech narsa yozilmadi; keyingi urinish mumkin (sinov "ishlatilgan" emas).
      expect((await t.s.call('GET', '/v1/billing/trial', { token: u.token })).data.state).toBe('not_started');
    }
  });

  for (const [name, patch] of [
    ['boshqa paket (requestPackageName)', (p: any) => (p.requestDetails.requestPackageName = 'com.evil.app')],
    ['UNRECOGNIZED_VERSION (o‘zgartirilgan ilova)', (p: any) => (p.appIntegrity.appRecognitionVerdict = 'UNRECOGNIZED_VERSION')],
    ['sertifikat mos emas (qayta imzolangan APK)', (p: any) => (p.appIntegrity.certificateSha256Digest = ['cd'.repeat(32)])],
    ['faqat MEETS_BASIC_INTEGRITY (root / emulyator)', (p: any) => (p.deviceIntegrity.deviceRecognitionVerdict = ['MEETS_BASIC_INTEGRITY'])],
    ['qurilma verdikti bo‘sh', (p: any) => (p.deviceIntegrity = {})],
    ['UNLICENSED (Play’dan o‘rnatilmagan)', (p: any) => (p.accountDetails.appLicensingVerdict = 'UNLICENSED')],
    ['eski token (> 10 daqiqa)', (p: any) => (p.requestDetails.timestampMillis = '0')],
  ] as const) {
    it(`verdikt rad: ${name} — 403 device_attestation_failed`, async () => {
      const t = integrityServer();
      const email = uniqueEmail('pi-bad');
      const u = await t.s.signIn(email);
      const r = await androidTrial(t, u, email, androidId(), patch);
      expect(r.status).toBe(403);
      expect(r.data.error).toBe('device_attestation_failed');
    });
  }

  it('MEETS_STRONG_INTEGRITY ham qabul qilinadi', async () => {
    const t = integrityServer();
    const email = uniqueEmail('pi-strong');
    const u = await t.s.signIn(email);
    const r = await androidTrial(t, u, email, androidId(), (p) => (p.deviceIntegrity.deviceRecognitionVerdict = ['MEETS_STRONG_INTEGRITY']));
    expect(r.status).toBe(201);
  });
});

describe('Play Integrity: verdikt funksiyasi (sof)', () => {
  const base = { packageName: PKG, digests: [CERT_HEX], serverNonce: 'n'.repeat(43), deviceId: 'abcdef0123456789', now: Date.UTC(2026, 9, 25) };
  it('integrityNonce: ilova (Dart) bilan bir xil test vektori', async () => {
    // test/unit/platform_device_attestor_test.dart da xuddi shu qiymat.
    expect(await integrityNonce('n'.repeat(43), 'abcdef0123456789')).toBe('61MO6Z5mYqT12cPPFzBUdWbBo8x-1wBxyZZ0L6HKnkI');
  });
  it('to‘g‘ri yuklama — subject = aid:<device_id>', async () => {
    const p = await goodPayload(base.serverNonce, base.deviceId, base.now);
    expect(await checkIntegrityVerdict(p, base)).toEqual({ ok: true, subject: `aid:${base.deviceId}` });
  });
  it('vaqt: kelajakdan (> 1 daqiqa) yoki 10 daqiqadan eski — stale_token; chegarada — ok', async () => {
    const at = async (ts: number) => checkIntegrityVerdict(await goodPayload(base.serverNonce, base.deviceId, base.now, (p) => (p.requestDetails.timestampMillis = String(ts))), base);
    expect(await at(base.now + 120_000)).toEqual({ ok: false, reason: 'stale_token' });
    expect(await at(base.now - INTEGRITY_MAX_AGE_MS - 1)).toEqual({ ok: false, reason: 'stale_token' });
    expect((await at(base.now - INTEGRITY_MAX_AGE_MS + 1000)).ok).toBe(true);
    expect(await at(Number.NaN)).toEqual({ ok: false, reason: 'stale_token' });
  });
  it('nonce: boshqa server nonce yoki boshqa device_id — nonce_mismatch', async () => {
    const p = await goodPayload('m'.repeat(43), base.deviceId, base.now);
    expect(await checkIntegrityVerdict(p, base)).toEqual({ ok: false, reason: 'nonce_mismatch' });
    const q = await goodPayload(base.serverNonce, 'ffffffffffffffff', base.now);
    expect(await checkIntegrityVerdict(q, base)).toEqual({ ok: false, reason: 'nonce_mismatch' });
  });
});

// ------------------------------------------------------------ DeviceCheck
function deviceCheckServer(extra: Record<string, string> = {}) {
  const s = baseServer({
    LG_BILLING_ENABLED: 'true',
    TRIAL_PLATFORMS: 'android,ios',
    APPLE_DEVICECHECK_KEY_ID: 'DCKEY12345',
    APPLE_DEVICECHECK_TEAM_ID: 'TEAM123456',
    APPLE_DEVICECHECK_PRIVATE_KEY: dcPem,
    ...extra,
  } as never);
  s.setAttestation(platformVerifier());
  /** Soxta Apple: qurilma (token → qurilma) bo'yicha ikki bit. */
  const bits = new Map<string, { bit0: boolean; bit1: boolean }>();
  const tokenDevice = new Map<string, string>();
  const calls: { path: string; host: string; body: any; jwt: any }[] = [];
  let mode: 'ok' | '400' | '401' | '500' | 'throw' | 'garbage' = 'ok';
  s.setFetch(async (url, init) => {
    const u = new URL(url);
    const jwt = await verifyJwt(String((init?.headers as Record<string, string>).authorization).slice(7), 'ES256');
    const body = JSON.parse(String(init?.body));
    calls.push({ path: u.pathname, host: u.host, body, jwt });
    if (mode === 'throw') throw new Error('down');
    if (mode === '400') return new Response('Missing or incorrectly formatted device token payload', { status: 400 });
    if (mode === '401') return new Response('Unable to verify authorization token', { status: 401 });
    if (mode === '500') return new Response('', { status: 500 });
    if (mode === 'garbage' && u.pathname === '/v1/query_two_bits') return new Response('<html>', { status: 200 });
    const device = tokenDevice.get(body.device_token);
    if (!device) return new Response('Missing or incorrectly formatted device token payload', { status: 400 });
    if (u.pathname === '/v1/query_two_bits') {
      const b = bits.get(device);
      return b ? Response.json({ ...b, last_update_time: '2026-10' }) : new Response('Failed to find bit state', { status: 200 });
    }
    if (u.pathname === '/v1/update_two_bits') {
      bits.set(device, { bit0: body.bit0, bit1: body.bit1 });
      return new Response('', { status: 200 });
    }
    throw new Error(`unexpected ${url}`);
  });
  return { s, bits, tokenDevice, calls, setMode: (m: typeof mode) => (mode = m) };
}

async function iosTrial(t: ReturnType<typeof deviceCheckServer>, user: { token: string }, email: string, device: string, keychainId: string, token?: string) {
  const ch = await t.s.call('POST', '/v1/billing/trial/challenge', { token: user.token, body: { platform: 'ios' } });
  if (ch.status !== 200) return ch;
  // DCDevice.generateToken — har chaqiruvda yangi token (bir qurilma uchun).
  const dc = token ?? btoa(`dc-token-${crypto.randomUUID()}-${device}`);
  t.tokenDevice.set(dc, device);
  return t.s.call('POST', '/v1/billing/trial/start', {
    token: user.token,
    ip: ip(),
    body: { tier: 'student', email, attestation: { platform: 'ios', token: dc, nonce: ch.data.nonce, device_id: keychainId } },
  });
}

describe('DeviceCheck: ikki bit (soxta Apple API)', () => {
  it('sozlanmagan (Key ID / Team ID / .p8 yo‘q) — iOS sinovi 503; faqat DeviceCheck sozlansa Android false', async () => {
    expect(DeviceCheckVerifier.configured({ APPLE_DEVICECHECK_KEY_ID: 'a', APPLE_DEVICECHECK_TEAM_ID: 'b' } as never)).toBe(false);
    const t = deviceCheckServer();
    expect((await t.s.call('GET', '/v1/billing/status')).data.trial).toMatchObject({ android: false, ios: true });
    const email = uniqueEmail('dc-android');
    const u = await t.s.signIn(email);
    const ch = await t.s.call('POST', '/v1/billing/trial/challenge', { token: u.token, body: { platform: 'android' } });
    expect(ch.status).toBe(503);
    expect(ch.data.error).toBe('trial_unavailable');
  });

  it('yangi qurilma: query (bit yo‘q) → 201 → update bit0=1; ES256 JWT (kid, iss, iat); production host', async () => {
    const t = deviceCheckServer();
    const email = uniqueEmail('dc-ok');
    const u = await t.s.signIn(email);
    const r = await iosTrial(t, u, email, 'iphone-1', crypto.randomUUID());
    expect(r.status, r.text).toBe(201);
    expect(t.calls.map((c) => c.path)).toEqual(['/v1/query_two_bits', '/v1/update_two_bits']);
    expect(t.calls.every((c) => c.host === 'api.devicecheck.apple.com')).toBe(true);
    const { jwt, body } = t.calls[1];
    expect(jwt.ok).toBe(true);
    expect(jwt.header).toMatchObject({ alg: 'ES256', kid: 'DCKEY12345' });
    expect(jwt.payload).toMatchObject({ iss: 'TEAM123456', iat: Math.floor(t.s.clock.now / 1000) });
    expect(body).toMatchObject({ bit0: true, bit1: false, timestamp: t.s.clock.now });
    expect(body.transaction_id).toMatch(/^[0-9a-f-]{36}$/);
    expect(t.bits.get('iphone-1')).toEqual({ bit0: true, bit1: false });
  });

  it('ilova qayta o‘rnatildi (yangi Keychain id, yangi hisob) — Apple bit0=1 → 409; boshqa iPhone — 201', async () => {
    const t = deviceCheckServer();
    const [a, b, c] = [uniqueEmail('dc-a'), uniqueEmail('dc-b'), uniqueEmail('dc-c')];
    const ua = await t.s.signIn(a);
    const ub = await t.s.signIn(b);
    const uc = await t.s.signIn(c);
    expect((await iosTrial(t, ua, a, 'iphone-x', crypto.randomUUID())).status).toBe(201);
    const re = await iosTrial(t, ub, b, 'iphone-x', crypto.randomUUID());
    expect(re.status).toBe(409);
    expect(re.data.error).toBe('trial_already_used');
    expect((await iosTrial(t, uc, c, 'iphone-y', crypto.randomUUID())).status).toBe(201);
  });

  it('bizning yozuv bor, Apple biti tozalangan bo‘lsa ham — o‘sha Keychain id → 409', async () => {
    const t = deviceCheckServer();
    const kc = crypto.randomUUID();
    const [a, b] = [uniqueEmail('dc-kc-a'), uniqueEmail('dc-kc-b')];
    const ua = await t.s.signIn(a);
    const ub = await t.s.signIn(b);
    expect((await iosTrial(t, ua, a, 'iphone-k', kc)).status).toBe(201);
    t.bits.clear();
    expect((await iosTrial(t, ub, b, 'iphone-k2', kc)).status).toBe(409);
  });

  it('o‘sha DeviceCheck tokenini qayta ishlatish — 403', async () => {
    const t = deviceCheckServer();
    const tok = btoa('dc-token-fixed-0000000000');
    const [a, b] = [uniqueEmail('dc-r-a'), uniqueEmail('dc-r-b')];
    const ua = await t.s.signIn(a);
    const ub = await t.s.signIn(b);
    t.setMode('400'); // birinchi urinish Apple'da rad bo'lsin — token baribir "ishlatilgan"
    expect((await iosTrial(t, ua, a, 'iphone-r', crypto.randomUUID(), tok)).status).toBe(403);
    t.setMode('ok');
    const r = await iosTrial(t, ub, b, 'iphone-r', crypto.randomUUID(), tok);
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('device_attestation_failed');
  });

  it('Apple xatolari: 400 — 403; 401 / 500 / tarmoq / buzuq javob — 502; hech narsa yozilmaydi', async () => {
    for (const [mode, status] of [
      ['400', 403],
      ['401', 502],
      ['500', 502],
      ['throw', 502],
      ['garbage', 502],
    ] as const) {
      const t = deviceCheckServer();
      t.setMode(mode);
      const email = uniqueEmail(`dc-${mode}`);
      const u = await t.s.signIn(email);
      const r = await iosTrial(t, u, email, `iphone-${mode}`, crypto.randomUUID());
      expect([mode, r.status]).toEqual([mode, status]);
      expect((await t.s.call('GET', '/v1/billing/trial', { token: u.token })).data.state).toBe('not_started');
    }
  });

  it('update_two_bits xatosi sinovni bekor qilmaydi (yozuv bizda bor) — 201', async () => {
    const t = deviceCheckServer();
    const email = uniqueEmail('dc-upd');
    const u = await t.s.signIn(email);
    const orig = t.calls;
    t.s.setFetch(async (url, init) => {
      const path = new URL(url).pathname;
      orig.push({ path, host: '', body: JSON.parse(String(init?.body)), jwt: null });
      if (path === '/v1/query_two_bits') return new Response('Failed to find bit state', { status: 200 });
      return new Response('', { status: 500 });
    });
    const r = await iosTrial(t, u, email, 'iphone-u', crypto.randomUUID());
    expect(r.status).toBe(201);
  });

  it('APPLE_DEVICECHECK_ENV=development — development host', async () => {
    const t = deviceCheckServer({ APPLE_DEVICECHECK_ENV: 'development' });
    const email = uniqueEmail('dc-dev');
    const u = await t.s.signIn(email);
    expect((await iosTrial(t, u, email, 'iphone-d', crypto.randomUUID())).status).toBe(201);
    expect(t.calls.every((c) => c.host === 'api.development.devicecheck.apple.com')).toBe(true);
  });

  it('device_id (Keychain) yo‘q yoki noto‘g‘ri token formati — 403, Apple so‘ralmaydi', async () => {
    const t = deviceCheckServer();
    const email = uniqueEmail('dc-noid');
    const u = await t.s.signIn(email);
    const ch = await t.s.call('POST', '/v1/billing/trial/challenge', { token: u.token, body: { platform: 'ios' } });
    const r = await t.s.call('POST', '/v1/billing/trial/start', {
      token: u.token,
      ip: ip(),
      body: { tier: 'student', email, attestation: { platform: 'ios', token: btoa('dc-token-abcdefghijk'), nonce: ch.data.nonce } },
    });
    expect(r.status).toBe(403);
    expect(t.calls).toEqual([]);
  });
});

describe('platformVerifier (production marshruti)', () => {
  it('ikkala platforma sozlangan bo‘lsa — status ikkalasi true (TRIAL_PLATFORMS ruxsat bersa)', async () => {
    const s: Srv = baseServer({
      LG_BILLING_ENABLED: 'true',
      TRIAL_PLATFORMS: 'android,ios',
      PLAY_INTEGRITY_SERVICE_ACCOUNT: saJson,
      PLAY_INTEGRITY_CERT_SHA256: CERT_HEX,
      APPLE_DEVICECHECK_KEY_ID: 'k',
      APPLE_DEVICECHECK_TEAM_ID: 't',
      APPLE_DEVICECHECK_PRIVATE_KEY: dcPem,
    } as never);
    s.setAttestation(platformVerifier());
    expect((await s.call('GET', '/v1/billing/status')).data.trial).toEqual({ android: true, ios: true, platforms: ['android', 'ios'], days: 7 });
  });

  it('standart TRIAL_PLATFORMS (faqat android): DeviceCheck sozlangan bo‘lsa ham iOS — false', async () => {
    const s = baseServer({ LG_BILLING_ENABLED: 'true', APPLE_DEVICECHECK_KEY_ID: 'k', APPLE_DEVICECHECK_TEAM_ID: 't', APPLE_DEVICECHECK_PRIVATE_KEY: dcPem } as never);
    s.setAttestation(platformVerifier());
    expect((await s.call('GET', '/v1/billing/status')).data.trial).toMatchObject({ android: false, ios: false });
  });
});
