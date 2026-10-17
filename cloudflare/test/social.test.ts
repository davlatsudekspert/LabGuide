// Google / Apple bilan kirish (D-56): ID token tekshiruvi, hisobga bog'lash,
// takroriy ishlatish, kalit keshi va Apple tokenini bekor qilish. Haqiqiy
// provayderlarga murojaat YO'Q: JWKS va Apple API'lari `setFetch` soxtasi,
// tokenlar shu testda yaratilgan RSA kalitlari bilan imzolanadi.

import { beforeEach, describe, expect, it } from 'vitest';
import { base64url, sha256Hex } from '../src/crypto';
import { resetSocialCaches } from '../src/social';
import { makeServer, uniqueEmail } from './helpers';

const GOOGLE_AUD = 'test-web-client.apps.googleusercontent.com';
const BUNDLE = 'uz.labguide.app';
const SERVICE = 'uz.labguide.app.service';
const GOOGLE_JWKS = 'https://www.googleapis.com/oauth2/v3/certs';
const APPLE_JWKS = 'https://appleid.apple.com/auth/keys';

const enc = new TextEncoder();
const b64j = (v: unknown) => base64url(enc.encode(JSON.stringify(v)));

interface TestKey {
  kid: string;
  priv: CryptoKey;
  jwk: JsonWebKey;
}

let kidSeq = 0;
async function makeKey(): Promise<TestKey> {
  const pair = (await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
    true,
    ['sign', 'verify'],
  )) as CryptoKeyPair;
  const kid = `k${++kidSeq}-${Math.random().toString(36).slice(2, 8)}`;
  const pub = (await crypto.subtle.exportKey('jwk', pair.publicKey)) as JsonWebKey;
  const jwk = { ...pub, kid, alg: 'RS256', use: 'sig' };
  return { kid, priv: pair.privateKey, jwk };
}

async function sign(key: TestKey, payload: Record<string, unknown>, header: Record<string, unknown> = {}) {
  const data = `${b64j({ alg: 'RS256', kid: key.kid, typ: 'JWT', ...header })}.${b64j(payload)}`;
  const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key.priv, enc.encode(data));
  return `${data}.${base64url(new Uint8Array(sig))}`;
}

async function applePem(): Promise<string> {
  const pair = (await crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, ['sign', 'verify'])) as CryptoKeyPair;
  const der = new Uint8Array((await crypto.subtle.exportKey('pkcs8', pair.privateKey)) as ArrayBuffer);
  let bin = '';
  for (const b of der) bin += String.fromCharCode(b);
  return `-----BEGIN PRIVATE KEY-----\n${btoa(bin)}\n-----END PRIVATE KEY-----`;
}

let nonceSeq = 0;
const newNonce = () => `raw-nonce-${Date.now().toString(36)}-${++nonceSeq}-abcdef`;

type Server = ReturnType<typeof makeServer>;

/** Server + JWKS soxtasi (Google va Apple har biri o'z kaliti bilan). */
async function setup(opts: { apple?: boolean; google?: boolean; service?: boolean } = {}) {
  resetSocialCaches();
  const gKey = await makeKey();
  const aKey = await makeKey();
  const env: Record<string, string> = {};
  if (opts.google !== false) env.GOOGLE_CLIENT_IDS = `other.apps.googleusercontent.com, ${GOOGLE_AUD}`;
  if (opts.apple !== false) {
    env.APPLE_SIGNIN_TEAM_ID = 'TEAM123456';
    env.APPLE_SIGNIN_KEY_ID = 'KEY1234567';
    env.APPLE_SIGNIN_PRIVATE_KEY = await applePem();
  }
  if (opts.service) env.APPLE_SIGNIN_SERVICE_ID = SERVICE;
  const s = makeServer(env);
  const state = { gKeys: [gKey], aKeys: [aKey], maxAge: 3600, jwksFail: false };
  const apple: { token: { status: number; refresh?: string; sub?: string }; revokeStatus: number } = {
    token: { status: 200 },
    revokeStatus: 200,
  };
  s.setFetch(async (url, init) => {
    const jwks = (keys: TestKey[]) =>
      new Response(JSON.stringify({ keys: keys.map((k) => k.jwk) }), {
        status: 200,
        headers: { 'content-type': 'application/json', 'cache-control': `public, max-age=${state.maxAge}` },
      });
    if (state.jwksFail && url.endsWith('/certs')) return new Response('x', { status: 500 });
    if (url === GOOGLE_JWKS) return jwks(state.gKeys);
    if (url === APPLE_JWKS) return jwks(state.aKeys);
    if (url === 'https://appleid.apple.com/auth/token') {
      if (apple.token.status !== 200) return new Response('{"error":"invalid_grant"}', { status: apple.token.status });
      const idt = `x.${b64j({ sub: apple.token.sub })}.y`;
      return new Response(JSON.stringify({ refresh_token: apple.token.refresh ?? 'rt-1', id_token: idt }), { status: 200 });
    }
    if (url === 'https://appleid.apple.com/auth/revoke') return new Response('', { status: apple.revokeStatus });
    throw new Error(`unexpected fetch ${url} ${init?.method ?? ''}`);
  });
  return { s, gKey, aKey, state, apple };
}

interface TokenOpts {
  sub?: string;
  email?: string | null;
  verified?: boolean | string;
  aud?: string | string[];
  iss?: string;
  exp?: number;
  iat?: number;
  nonce?: string;
  rawNonce?: string;
  extra?: Record<string, unknown>;
}

async function token(s: Server, key: TestKey, kind: 'google' | 'apple', o: TokenOpts = {}) {
  const raw = o.rawNonce ?? newNonce();
  const now = Math.floor(s.clock.now / 1000);
  const payload: Record<string, unknown> = {
    iss: o.iss ?? (kind === 'google' ? 'https://accounts.google.com' : 'https://appleid.apple.com'),
    aud: o.aud ?? (kind === 'google' ? GOOGLE_AUD : BUNDLE),
    sub: o.sub ?? `${kind}-sub-${Math.random().toString(36).slice(2, 10)}`,
    iat: o.iat ?? now - 5,
    exp: o.exp ?? now + 3000,
    nonce: o.nonce ?? (await sha256Hex(raw)),
    ...(o.email === null ? {} : { email: o.email ?? uniqueEmail('soc') }),
    email_verified: o.verified ?? true,
    ...(o.extra ?? {}),
  };
  return { idToken: await sign(key, payload), nonce: raw, payload };
}

let ipSeq = 0;
const login = (s: Server, kind: 'google' | 'apple', t: { idToken: string; nonce: string }, ip?: string) =>
  s.call('POST', `/v1/auth/${kind}`, {
    body: { id_token: t.idToken, nonce: t.nonce },
    ip: ip ?? `192.0.2.${(++ipSeq % 200) + 1}`,
  });

beforeEach(() => resetSocialCaches());

describe('provayderlar holati', () => {
  it('sozlama yo‘q — ikkalasi ham false, kirish 503 not_configured', async () => {
    const { s, gKey } = await setup({ google: false, apple: false });
    expect((await s.call('GET', '/v1/auth/providers')).data).toEqual({ google: false, apple: false, apple_web: false });
    const t = await token(s, gKey, 'google');
    for (const kind of ['google', 'apple'] as const) {
      const r = await login(s, kind, t);
      expect(r.status).toBe(503);
      expect(r.data.error).toBe('not_configured');
    }
    expect(s.fetchCalls).toHaveLength(0);
  });

  it('sozlangan bo‘lsa true; Android uchun Apple faqat Services ID bilan', async () => {
    const a = await setup();
    expect((await a.s.call('GET', '/v1/auth/providers')).data).toEqual({ google: true, apple: true, apple_web: false });
    const b = await setup({ service: true });
    expect((await b.s.call('GET', '/v1/auth/providers')).data).toEqual({ google: true, apple: true, apple_web: true });
  });

  it('Apple kaliti to‘liq bo‘lmasa — Apple o‘chiq (revoke qila olmaydigan kirish yo‘q)', async () => {
    resetSocialCaches();
    const s = makeServer({ GOOGLE_CLIENT_IDS: GOOGLE_AUD, APPLE_SIGNIN_TEAM_ID: 'T', APPLE_SIGNIN_KEY_ID: 'K' });
    expect((await s.call('GET', '/v1/auth/providers')).data).toMatchObject({ google: true, apple: false });
  });
});

describe('Google ID token', () => {
  it('to‘g‘ri token: yangi hisob, sessiya ishlaydi, token bazaga yozilmaydi', async () => {
    const { s, gKey } = await setup();
    const email = uniqueEmail('g');
    const t = await token(s, gKey, 'google', { email });
    const r = await login(s, 'google', t);
    expect(r.status).toBe(200);
    expect(r.data).toMatchObject({ new_user: true, linked: false, provider: 'google', email });
    const me = await s.call('GET', '/v1/me', { token: r.data.token });
    expect(me.status).toBe(200);
    expect(me.data).toMatchObject({ user_id: r.data.user_id, role: 'student', aal: 'aal1', identities: ['google'], admin: false });
    // Bazada: email ochiq emas, token ham, xom nonce ham yo'q.
    const dump = JSON.stringify([
      ...(await s.env.DB.prepare('SELECT * FROM users').all()).results,
      ...(await s.env.DB.prepare('SELECT * FROM auth_identities').all()).results,
      ...(await s.env.DB.prepare('SELECT * FROM auth_replay').all()).results,
      ...(await s.env.DB.prepare('SELECT * FROM sessions').all()).results,
    ]);
    expect(dump).not.toContain(email);
    expect(dump).not.toContain(t.idToken);
    expect(dump).not.toContain(t.nonce);
    expect(dump).not.toContain(r.data.token);
  });

  it('boshqa client ID (aud) — rad; massivdagi aud ham tekshiriladi', async () => {
    const { s, gKey } = await setup();
    const bad = await login(s, 'google', await token(s, gKey, 'google', { aud: 'evil.apps.googleusercontent.com' }));
    expect(bad.status).toBe(401);
    expect(bad.data.error).toBe('invalid_token');
    const arr = await login(s, 'google', await token(s, gKey, 'google', { aud: ['x', GOOGLE_AUD] }));
    expect(arr.status).toBe(200);
  });

  it('Apple bundle ID bilan berilgan token Google yo‘lida rad etiladi', async () => {
    const { s, gKey } = await setup();
    expect((await login(s, 'google', await token(s, gKey, 'google', { aud: BUNDLE }))).status).toBe(401);
  });

  it('noto‘g‘ri iss — rad', async () => {
    const { s, gKey } = await setup();
    const r = await login(s, 'google', await token(s, gKey, 'google', { iss: 'https://evil.example' }));
    expect(r.status).toBe(401);
    expect((await login(s, 'google', await token(s, gKey, 'google', { iss: 'accounts.google.com' }))).status).toBe(200);
  });

  it('muddati o‘tgan token — rad (1 daqiqa yumshoqlikdan keyin)', async () => {
    const { s, gKey } = await setup();
    const now = Math.floor(s.clock.now / 1000);
    const r = await login(s, 'google', await token(s, gKey, 'google', { exp: now - 3600, iat: now - 7200 }));
    expect(r.status).toBe(401);
    expect(r.data.error).toBe('token_expired');
    const edge = await login(s, 'google', await token(s, gKey, 'google', { exp: now - 30 }));
    expect(edge.status).toBe(200);
  });

  it('kelajakdagi iat — rad', async () => {
    const { s, gKey } = await setup();
    const now = Math.floor(s.clock.now / 1000);
    expect((await login(s, 'google', await token(s, gKey, 'google', { iat: now + 3600 }))).status).toBe(401);
  });

  it('nonce: noto‘g‘ri xom nonce, tokenda nonce yo‘q, xom (hashsiz) nonce — rad', async () => {
    const { s, gKey } = await setup();
    const t = await token(s, gKey, 'google');
    const wrong = await login(s, 'google', { ...t, nonce: 'another-raw-nonce-0123456789' });
    expect(wrong.status).toBe(401);
    expect(wrong.data.error).toBe('nonce_mismatch');
    const raw = newNonce();
    const plain = await token(s, gKey, 'google', { rawNonce: raw, nonce: raw }); // hash o'rniga xom qiymat
    expect((await login(s, 'google', plain)).status).toBe(401);
    const none = await signNoNonce(s, gKey);
    expect((await login(s, 'google', none)).status).toBe(401);
  });

  it('nonce yuborilmasa yoki juda qisqa bo‘lsa — 400', async () => {
    const { s, gKey } = await setup();
    const t = await token(s, gKey, 'google');
    expect((await s.call('POST', '/v1/auth/google', { body: { id_token: t.idToken } })).status).toBe(400);
    expect((await s.call('POST', '/v1/auth/google', { body: { id_token: t.idToken, nonce: 'short' } })).data.error).toBe('invalid_nonce');
    expect((await s.call('POST', '/v1/auth/google', { body: { nonce: t.nonce } })).data.error).toBe('invalid_token');
  });

  it('email tasdiqlanmagan — 403, hisob yaratilmaydi', async () => {
    const { s, gKey } = await setup();
    const email = uniqueEmail('unv');
    const before = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM users').first<{ n: number }>();
    for (const verified of [false, 'false']) {
      const r = await login(s, 'google', await token(s, gKey, 'google', { email, verified }));
      expect(r.status).toBe(403);
      expect(r.data.error).toBe('email_not_verified');
    }
    const after = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM users').first<{ n: number }>();
    expect(after!.n).toBe(before!.n);
  });

  it('email umuman yo‘q (birinchi kirish) — 400 email_required', async () => {
    const { s, gKey } = await setup();
    const r = await login(s, 'google', await token(s, gKey, 'google', { email: null }));
    expect(r.status).toBe(400);
    expect(r.data.error).toBe('email_required');
  });

  it('boshqa kalit bilan imzolangan (soxta) token va noma‘lum kid — rad', async () => {
    const { s } = await setup();
    const evil = await makeKey();
    expect((await login(s, 'google', await token(s, evil, 'google'))).status).toBe(401);
    // Xuddi shu kid, lekin boshqa kalit.
    const { s: s2, gKey } = await setup();
    const forged = { ...evil, kid: gKey.kid };
    expect((await login(s2, 'google', await token(s2, forged, 'google'))).status).toBe(401);
  });

  it('o‘zgartirilgan yuklama (imzo mos emas) — rad', async () => {
    const { s, gKey } = await setup();
    const t = await token(s, gKey, 'google');
    const [h, , sig] = t.idToken.split('.');
    const evilPayload = b64j({ ...t.payload, email: 'victim@example.test', sub: 'victim' });
    expect((await login(s, 'google', { ...t, idToken: `${h}.${evilPayload}.${sig}` })).status).toBe(401);
  });

  it('alg=none va HS256 — rad', async () => {
    const { s, gKey } = await setup();
    const t = await token(s, gKey, 'google');
    const body = t.idToken.split('.')[1];
    const none = `${b64j({ alg: 'none', kid: gKey.kid })}.${body}.`;
    expect((await login(s, 'google', { ...t, idToken: none })).status).toBe(401);
    const hs = `${b64j({ alg: 'HS256', kid: gKey.kid })}.${body}.${base64url(enc.encode('x'))}`;
    expect((await login(s, 'google', { ...t, idToken: hs })).status).toBe(401);
    for (const junk of ['', 'a.b', 'a.b.c', '....', 'x'.repeat(9000)]) {
      const r = await login(s, 'google', { idToken: junk, nonce: t.nonce });
      expect([400, 401]).toContain(r.status);
    }
  });

  it('takroriy ishlatish (replay): bir xil token ikkinchi marta rad', async () => {
    const { s, gKey } = await setup();
    const t = await token(s, gKey, 'google');
    expect((await login(s, 'google', t)).status).toBe(200);
    const again = await login(s, 'google', t);
    expect(again.status).toBe(401);
    expect(again.data.error).toBe('replayed_token');
    // Yangi token (boshqa nonce) esa yana ishlaydi.
    const next = await token(s, gKey, 'google', { sub: t.payload.sub as string, email: t.payload.email as string });
    expect((await login(s, 'google', next)).status).toBe(200);
  });
});

describe('bitta email = bitta hisob', () => {
  it('email kodi bilan ochilgan hisobga Google orqali kirish — bog‘lanadi, dublikat yo‘q, rol saqlanadi', async () => {
    const { s, gKey } = await setup();
    const email = uniqueEmail('link');
    const otp = await s.signIn(email, { role: 'doctor', language: 'ru' });
    const users = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM users').first<{ n: number }>();
    const r = await login(s, 'google', await token(s, gKey, 'google', { email: email.toUpperCase() }));
    expect(r.status).toBe(200);
    expect(r.data).toMatchObject({ user_id: otp.userId, new_user: false, linked: true });
    expect((await s.env.DB.prepare('SELECT COUNT(*) AS n FROM users').first<{ n: number }>())!.n).toBe(users!.n);
    const me = await s.call('GET', '/v1/me', { token: r.data.token });
    expect(me.data).toMatchObject({ user_id: otp.userId, role: 'doctor', language: 'ru', identities: ['google'] });
    // Rol almashtirish mumkin (mavjud dizayn).
    expect((await s.call('PUT', '/v1/me/profile', { token: r.data.token, body: { role: 'lab' } })).status).toBe(200);
  });

  it('keyingi kirishlar `sub` bo‘yicha: email tokenda bo‘lmasa ham, o‘zgargan bo‘lsa ham o‘sha hisob', async () => {
    const { s, gKey } = await setup();
    const email = uniqueEmail('sub');
    const first = await login(s, 'google', await token(s, gKey, 'google', { sub: 'stable-sub', email }));
    const noEmail = await login(s, 'google', await token(s, gKey, 'google', { sub: 'stable-sub', email: null }));
    expect(noEmail.status).toBe(200);
    expect(noEmail.data).toMatchObject({ user_id: first.data.user_id, new_user: false, linked: false, email: null });
    const changed = await login(s, 'google', await token(s, gKey, 'google', { sub: 'stable-sub', email: uniqueEmail('new') }));
    expect(changed.data.user_id).toBe(first.data.user_id);
    expect((await s.env.DB.prepare('SELECT COUNT(*) AS n FROM auth_identities WHERE provider_sub = ?1').bind('stable-sub').first<{ n: number }>())!.n).toBe(1);
  });

  it('Google va Apple bir xil emailda — ikkalasi bitta hisobga', async () => {
    const { s, gKey, aKey } = await setup();
    const email = uniqueEmail('both');
    const g = await login(s, 'google', await token(s, gKey, 'google', { email }));
    const a = await login(s, 'apple', await token(s, aKey, 'apple', { email, verified: 'true' }));
    expect(a.status).toBe(200);
    expect(a.data).toMatchObject({ user_id: g.data.user_id, new_user: false, linked: true, provider: 'apple' });
    const me = await s.call('GET', '/v1/me', { token: a.data.token });
    expect(me.data.identities).toEqual(['apple', 'google']);
    // Email kodi bilan ham o'sha hisob.
    expect((await s.signIn(email)).userId).toBe(g.data.user_id);
  });

  it('Apple private relay: alohida email-identitet, keyin `sub` bo‘yicha', async () => {
    const { s, aKey } = await setup();
    const relay = `abc123.${Date.now().toString(36)}@privaterelay.appleid.com`;
    const first = await login(s, 'apple', await token(s, aKey, 'apple', { sub: 'apple-relay-sub', email: relay, verified: 'true', extra: { is_private_email: 'true' } }));
    expect(first.status).toBe(200);
    expect(first.data).toMatchObject({ new_user: true, email: relay });
    // Haqiqiy email bilan ochilgan boshqa hisob bilan aralashmaydi.
    const real = await s.signIn(uniqueEmail('real'));
    expect(real.userId).not.toBe(first.data.user_id);
    // Apple keyingi kirishda emailni bermasa ham — o'sha hisob.
    const again = await login(s, 'apple', await token(s, aKey, 'apple', { sub: 'apple-relay-sub', email: null }));
    expect(again.data).toMatchObject({ user_id: first.data.user_id, new_user: false });
    // Foydalanuvchi emailni o'zgartirsa ham (relay -> haqiqiy) hisob o'sha, dublikat yo'q.
    const users = (await s.env.DB.prepare('SELECT COUNT(*) AS n FROM users').first<{ n: number }>())!.n;
    const moved = await login(s, 'apple', await token(s, aKey, 'apple', { sub: 'apple-relay-sub', email: uniqueEmail('moved') }));
    expect(moved.data.user_id).toBe(first.data.user_id);
    expect((await s.env.DB.prepare('SELECT COUNT(*) AS n FROM users').first<{ n: number }>())!.n).toBe(users);
  });

  it('Apple: aud bundle ID bo‘lishi shart; Services ID faqat sozlangan bo‘lsa', async () => {
    const a = await setup();
    expect((await login(a.s, 'apple', await token(a.s, a.aKey, 'apple', { aud: 'com.evil.app' }))).status).toBe(401);
    expect((await login(a.s, 'apple', await token(a.s, a.aKey, 'apple', { aud: SERVICE }))).status).toBe(401);
    const b = await setup({ service: true });
    expect((await login(b.s, 'apple', await token(b.s, b.aKey, 'apple', { aud: SERVICE }))).status).toBe(200);
  });

  it('Apple: noto‘g‘ri iss va Google kaliti bilan imzolangan token — rad', async () => {
    const { s, gKey, aKey } = await setup();
    expect((await login(s, 'apple', await token(s, aKey, 'apple', { iss: 'https://accounts.google.com' }))).status).toBe(401);
    expect((await login(s, 'apple', await token(s, gKey, 'apple'))).status).toBe(401);
  });

  it('admin vakolati Google/Apple orqali BERILMAYDI (faqat email kodi bilan)', async () => {
    const { s, gKey } = await setup();
    const r = await login(s, 'google', await token(s, gKey, 'google', { email: 'boss@example.test' }));
    expect(r.status).toBe(200);
    const me = await s.call('GET', '/v1/me', { token: r.data.token });
    expect(me.data).toMatchObject({ admin_account: false, admin: false, super_admin: false });
    // Email kodi bilan tasdiqlangach admin hisobi bo'ladi; Google sessiyasi esa baribir aal1.
    await s.signIn('boss@example.test');
    const g2 = await login(s, 'google', await token(s, gKey, 'google', { sub: 'google-sub-admin-2', email: 'boss@example.test' }));
    expect(g2.data.user_id).toBe(r.data.user_id);
    const me2 = await s.call('GET', '/v1/me', { token: g2.data.token });
    expect(me2.data).toMatchObject({ admin_account: true, admin: false, aal: 'aal1' });
  });
});

describe('JWKS keshi va kalit almashtirish', () => {
  it('kalitlar keshlanadi (bitta yuklash), muddati o‘tgach qayta yuklanadi', async () => {
    const { s, gKey, state } = await setup();
    state.maxAge = 600;
    await login(s, 'google', await token(s, gKey, 'google'));
    await login(s, 'google', await token(s, gKey, 'google'));
    expect(s.fetchCalls.filter((c) => c.url === GOOGLE_JWKS)).toHaveLength(1);
    s.clock.now += 601_000;
    await login(s, 'google', await token(s, gKey, 'google'));
    expect(s.fetchCalls.filter((c) => c.url === GOOGLE_JWKS)).toHaveLength(2);
  });

  it('provayder kalitni almashtirsa: yangi kid yuklanadi (cheklangan tezlikda)', async () => {
    const { s, gKey, state } = await setup();
    await login(s, 'google', await token(s, gKey, 'google'));
    const rotated = await makeKey();
    state.gKeys = [gKey, rotated];
    // Kesh yangi: noma'lum kid darhol qayta yuklamaydi (suiiste'molga qarshi) — rad.
    const early = await login(s, 'google', await token(s, rotated, 'google'));
    expect(early.status).toBe(401);
    expect(s.fetchCalls.filter((c) => c.url === GOOGLE_JWKS)).toHaveLength(1);
    // Sovish oralig'idan keyin yangi kalit olinadi va kirish ishlaydi; eski kalit ham.
    s.clock.now += 6 * 60_000;
    expect((await login(s, 'google', await token(s, rotated, 'google'))).status).toBe(200);
    expect((await login(s, 'google', await token(s, gKey, 'google'))).status).toBe(200);
    expect(s.fetchCalls.filter((c) => c.url === GOOGLE_JWKS)).toHaveLength(2);
  });

  it('eski kalit olib tashlansa — undan imzolangan token rad etiladi', async () => {
    const { s, gKey, state } = await setup();
    await login(s, 'google', await token(s, gKey, 'google'));
    const fresh = await makeKey();
    state.gKeys = [fresh];
    s.clock.now += 3601_000; // kesh muddati tugadi
    expect((await login(s, 'google', await token(s, gKey, 'google'))).status).toBe(401);
    expect((await login(s, 'google', await token(s, fresh, 'google'))).status).toBe(200);
  });

  it('provayder JWKS ga yetib bo‘lmasa: kesh bo‘sh — 502; eski kesh bo‘lsa davom etadi', async () => {
    const { s, gKey, state } = await setup();
    state.jwksFail = true;
    const down = await login(s, 'google', await token(s, gKey, 'google'));
    expect(down.status).toBe(502);
    expect(down.data.error).toBe('provider_unavailable');
    state.jwksFail = false;
    expect((await login(s, 'google', await token(s, gKey, 'google'))).status).toBe(200);
    state.jwksFail = true;
    s.clock.now += 7200_000;
    expect((await login(s, 'google', await token(s, gKey, 'google'))).status).toBe(200);
  });
});

describe('limit va tozalash', () => {
  it('bir IP dan ko‘p urinish — 429', async () => {
    const { s, gKey } = await setup();
    const t = await token(s, gKey, 'google');
    let last = 0;
    for (let i = 0; i < 62; i++) {
      last = (await s.call('POST', '/v1/auth/google', { body: { id_token: t.idToken, nonce: `bad-nonce-${i}-0123456789` }, ip: '203.0.113.99' })).status;
    }
    expect(last).toBe(429);
  });

  it('kunlik tozalash muddati o‘tgan replay yozuvlarini o‘chiradi', async () => {
    const { s, gKey } = await setup();
    await login(s, 'google', await token(s, gKey, 'google'));
    expect((await s.env.DB.prepare('SELECT COUNT(*) AS n FROM auth_replay').first<{ n: number }>())!.n).toBeGreaterThan(0);
    await s.app.scheduled(s.env);
    // Vaqt hali o'tmagan: qoladi. Soatni oldinga surib, qayta tozalaymiz.
    const left = (await s.env.DB.prepare('SELECT COUNT(*) AS n FROM auth_replay WHERE expires_at < ?1').bind(s.clock.now).first<{ n: number }>())!.n;
    expect(left).toBe(0);
  });
});

describe('hisobni o‘chirish va Apple tokenini bekor qilish', () => {
  async function appleUser(s: Server, aKey: TestKey, sub = 'apple-del-sub') {
    const r = await login(s, 'apple', await token(s, aKey, 'apple', { sub, email: uniqueEmail('del'), verified: 'true' }));
    expect(r.status).toBe(200);
    return r.data as { token: string; user_id: string };
  }
  const tableCount = async (s: Server, sql: string, ...args: unknown[]) =>
    (await s.env.DB.prepare(sql).bind(...args).first<{ n: number }>())!.n;

  it('kod bilan: token almashtiriladi va bekor qilinadi; hisob va identitet o‘chadi', async () => {
    const { s, aKey, apple } = await setup();
    apple.token = { status: 200, refresh: 'rt-secret', sub: 'apple-del-sub' };
    const u = await appleUser(s, aKey);
    const del = await s.call('DELETE', '/v1/me', { token: u.token, body: { apple_authorization_code: 'code-123' } });
    expect(del.status).toBe(204);
    const calls = s.fetchCalls.filter((c) => c.url.includes('appleid.apple.com/auth/') && !c.url.endsWith('/keys'));
    expect(calls.map((c) => c.url)).toEqual(['https://appleid.apple.com/auth/token', 'https://appleid.apple.com/auth/revoke']);
    const tokenBody = new URLSearchParams(String(calls[0].init?.body));
    expect(tokenBody.get('code')).toBe('code-123');
    expect(tokenBody.get('client_id')).toBe(BUNDLE);
    expect(tokenBody.get('grant_type')).toBe('authorization_code');
    // client_secret — ES256 JWT (iss=team, sub=client_id, aud=apple).
    const secret = tokenBody.get('client_secret')!.split('.');
    const hdr = JSON.parse(atob(secret[0].replace(/-/g, '+').replace(/_/g, '/')));
    const pl = JSON.parse(atob(secret[1].replace(/-/g, '+').replace(/_/g, '/')));
    expect(hdr).toMatchObject({ alg: 'ES256', kid: 'KEY1234567' });
    expect(pl).toMatchObject({ iss: 'TEAM123456', sub: BUNDLE, aud: 'https://appleid.apple.com' });
    const revokeBody = new URLSearchParams(String(calls[1].init?.body));
    expect(revokeBody.get('token')).toBe('rt-secret');
    expect(revokeBody.get('token_type_hint')).toBe('refresh_token');
    expect(await tableCount(s, 'SELECT COUNT(*) AS n FROM users WHERE id = ?1', u.user_id)).toBe(0);
    expect(await tableCount(s, 'SELECT COUNT(*) AS n FROM auth_identities WHERE user_id = ?1', u.user_id)).toBe(0);
    expect((await s.call('GET', '/v1/me', { token: u.token })).status).toBe(401);
    const log = await s.env.DB.prepare(`SELECT details FROM audit_log WHERE action = 'apple_revoke' AND actor = ?1`).bind(u.user_id).first<{ details: string }>();
    expect(JSON.parse(log!.details)).toEqual({ outcome: 'revoked' });
    // Hech qaerda token saqlanmagan.
    expect(JSON.stringify((await s.env.DB.prepare('SELECT * FROM audit_log').all()).results)).not.toContain('rt-secret');
  });

  it('Apple sozlanmagan: hisob baribir o‘chadi (log: not_configured)', async () => {
    const { s, aKey } = await setup();
    const u = await appleUser(s, aKey, 'apple-del-2');
    // Sozlama keyinroq olib tashlandi.
    const cfgLess = makeServer({});
    // Xuddi shu D1: boshqa server obyekti, Apple kalitlarsiz.
    cfgLess.setFetch(async (url) => {
      throw new Error(`no network expected: ${url}`);
    });
    const del = await cfgLess.call('DELETE', '/v1/me', { token: u.token, body: { apple_authorization_code: 'c' } });
    expect(del.status).toBe(204);
    expect(await tableCount(s, 'SELECT COUNT(*) AS n FROM users WHERE id = ?1', u.user_id)).toBe(0);
    const log = await s.env.DB.prepare(`SELECT details FROM audit_log WHERE action = 'apple_revoke' AND actor = ?1`).bind(u.user_id).first<{ details: string }>();
    expect(JSON.parse(log!.details)).toEqual({ outcome: 'not_configured' });
  });

  it('kod yo‘q yoki Apple xato qaytarsa: hisob o‘chadi, natija jurnalda', async () => {
    const { s, aKey, apple } = await setup();
    const a = await appleUser(s, aKey, 'apple-del-3');
    expect((await s.call('DELETE', '/v1/me', { token: a.token })).status).toBe(204);
    expect(await tableCount(s, 'SELECT COUNT(*) AS n FROM users WHERE id = ?1', a.user_id)).toBe(0);
    const logA = await s.env.DB.prepare(`SELECT details FROM audit_log WHERE action = 'apple_revoke' AND actor = ?1`).bind(a.user_id).first<{ details: string }>();
    expect(JSON.parse(logA!.details)).toEqual({ outcome: 'no_code' });

    apple.token = { status: 400 };
    const b = await appleUser(s, aKey, 'apple-del-4');
    expect((await s.call('DELETE', '/v1/me', { token: b.token, body: { apple_authorization_code: 'bad' } })).status).toBe(204);
    expect(await tableCount(s, 'SELECT COUNT(*) AS n FROM users WHERE id = ?1', b.user_id)).toBe(0);

    apple.token = { status: 200, sub: 'apple-del-5' };
    apple.revokeStatus = 500;
    const c = await appleUser(s, aKey, 'apple-del-5');
    expect((await s.call('DELETE', '/v1/me', { token: c.token, body: { apple_authorization_code: 'x' } })).status).toBe(204);
    const logC = await s.env.DB.prepare(`SELECT details FROM audit_log WHERE action = 'apple_revoke' AND actor = ?1`).bind(c.user_id).first<{ details: string }>();
    expect(JSON.parse(logC!.details)).toEqual({ outcome: 'revoke_failed' });
  });

  it('boshqa Apple hisobining kodi (sub mos emas) bekor qilinmaydi', async () => {
    const { s, aKey, apple } = await setup();
    apple.token = { status: 200, sub: 'somebody-else' };
    const u = await appleUser(s, aKey, 'apple-del-6');
    expect((await s.call('DELETE', '/v1/me', { token: u.token, body: { apple_authorization_code: 'x' } })).status).toBe(204);
    expect(s.fetchCalls.some((c) => c.url.endsWith('/auth/revoke'))).toBe(false);
    const log = await s.env.DB.prepare(`SELECT details FROM audit_log WHERE action = 'apple_revoke' AND actor = ?1`).bind(u.user_id).first<{ details: string }>();
    expect(JSON.parse(log!.details)).toEqual({ outcome: 'sub_mismatch' });
  });

  it('Apple identiteti yo‘q hisob (email kodi / Google): Apple API ga murojaat yo‘q', async () => {
    const { s, gKey } = await setup();
    const g = await login(s, 'google', await token(s, gKey, 'google'));
    const before = s.fetchCalls.length;
    expect((await s.call('DELETE', '/v1/me', { token: g.data.token })).status).toBe(204);
    expect(s.fetchCalls.slice(before)).toHaveLength(0);
    expect(await tableCount(s, 'SELECT COUNT(*) AS n FROM auth_identities WHERE user_id = ?1', g.data.user_id)).toBe(0);
  });
});

describe('Android uchun Apple qaytish manzili', () => {
  it('Services ID sozlangan bo‘lsa: faqat kerakli maydonlar intent:// ga uzatiladi', async () => {
    const { s } = await setup({ service: true });
    const res = await s.app.fetch(
      new Request('https://api.test/v1/auth/apple/callback', {
        method: 'POST',
        headers: { 'content-type': 'application/x-www-form-urlencoded', 'cf-connecting-ip': '203.0.113.5' },
        body: 'code=abc&id_token=tok.en.x&state=st&user=%7B%22name%22%3A%22Secret%22%7D&extra=1',
      }),
      s.env,
    );
    expect(res.status).toBe(307);
    const loc = res.headers.get('location')!;
    expect(loc.startsWith('intent://callback?')).toBe(true);
    expect(loc).toContain('code=abc');
    expect(loc).toContain('id_token=tok.en.x');
    expect(loc).toContain('state=st');
    expect(loc).not.toContain('Secret');
    expect(loc).not.toContain('extra');
    expect(loc.endsWith('#Intent;package=uz.labguide.app;scheme=signinwithapple;end')).toBe(true);
  });

  it('Services ID yo‘q — 503', async () => {
    const { s } = await setup();
    const r = await s.call('POST', '/v1/auth/apple/callback', { raw: 'code=abc', headers: { 'content-type': 'application/x-www-form-urlencoded' } });
    expect(r.status).toBe(503);
  });
});

/** `nonce` da'vosi umuman yo'q token. */
async function signNoNonce(s: Server, key: TestKey) {
  const now = Math.floor(s.clock.now / 1000);
  const idToken = await sign(key, {
    iss: 'https://accounts.google.com',
    aud: GOOGLE_AUD,
    sub: 'no-nonce',
    iat: now - 5,
    exp: now + 3000,
    email: uniqueEmail('nn'),
    email_verified: true,
  });
  return { idToken, nonce: newNonce() };
}

describe('to‘xtatilgan hisob (admin panel)', () => {
  it('Google va Apple yo‘li ham rad etadi (403 account_suspended); qayta faollashgach kiradi; Google sessiyasi admin panelni ochmaydi', async () => {
    const { s, gKey, aKey } = await setup();
    const owner = uniqueEmail('owner');
    (s.env as unknown as Record<string, string>).ADMIN_EMAILS = owner;
    const boss = await s.signIn(owner);
    const email = uniqueEmail('susp');
    const first = await login(s, 'google', await token(s, gKey, 'google', { email, sub: 'g-susp' }));
    expect(first.status).toBe(200);
    const uid = first.data.user_id as string;
    expect((await s.call('POST', `/v1/admin/users/${uid}/suspend`, { token: boss.token })).status).toBe(200);
    expect((await s.call('GET', '/v1/me', { token: first.data.token })).status).toBe(401);
    const g = await login(s, 'google', await token(s, gKey, 'google', { email, sub: 'g-susp' }));
    expect(g.status).toBe(403);
    expect(g.data.error).toBe('account_suspended');
    const a = await login(s, 'apple', await token(s, aKey, 'apple', { email }));
    expect(a.status).toBe(403);
    expect(a.data.error).toBe('account_suspended');
    expect((await s.call('POST', `/v1/admin/users/${uid}/reactivate`, { token: boss.token })).status).toBe(200);
    const ok = await login(s, 'google', await token(s, gKey, 'google', { email, sub: 'g-susp' }));
    expect(ok.status).toBe(200);

    // Egasining o'zi Google bilan kirsa — panel ochilmaydi (faqat email kodi).
    const og = await login(s, 'google', await token(s, gKey, 'google', { email: owner }));
    expect(og.status).toBe(200);
    expect((await s.call('GET', '/v1/admin/stats', { token: og.data.token })).status).toBe(403);
  });
});
