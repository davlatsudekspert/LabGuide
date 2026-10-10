import { afterEach, describe, expect, it, vi } from 'vitest';
import { brevoSender } from '../src/email';
import type { Env } from '../src/http';
import { makeServer, uniqueEmail } from './helpers';

describe('SQL injection — faqat parametrli so\'rovlar', () => {
  it("zararli qiymatlar matn sifatida saqlanadi yoki rad etiladi, jadvallar butun", async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('sqli'));
    const evil = "Robert'); DROP TABLE users;--";
    const g = await s.call('POST', '/v1/groups', { token: t.token, body: { name: evil } });
    expect(g.status).toBe(201);
    const list = (await s.call('GET', '/v1/groups', { token: t.token })).data;
    expect(list[0].name).toBe(evil);
    for (const code of ["' OR '1'='1", "ABCD' --", '%', '*']) {
      expect((await s.call('POST', '/v1/groups/join', { token: t.token, body: { code } })).status).toBe(404);
    }
    expect(
      (await s.call('POST', '/v1/auth/otp/request', { body: { email: "x'@x.uz; DELETE FROM users" } })).status,
    ).toBe(400);
    expect((await s.call('GET', `/v1/groups/${encodeURIComponent("1' OR 1=1--")}/members`, { token: t.token })).status).toBe(404);
    expect((await s.call('GET', `/v1/groups/${g.data.id}/marks?day_id=${encodeURIComponent("x' OR 1=1--")}`, { token: t.token })).status).toBe(400);
    expect((await s.call('PUT', `/v1/groups/${g.data.id}/topics/${encodeURIComponent("d'; DROP TABLE group_topics;--")}`, { token: t.token })).status).toBe(400);
    expect((await s.call('PUT', `/v1/groups/${g.data.id}/topics/%E0%A4%A`, { token: t.token })).status).toBe(400);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM users').first<{ n: number }>();
    expect(n!.n).toBeGreaterThan(0);
    expect((await s.call('GET', '/v1/me', { token: t.token })).status).toBe(200);
  });

  it('manba kodida SQL ga qiymat satr birlashtirish bilan qo\'shilmaydi', async () => {
    // Statik tekshiruv: SQL shablonlarida `${` faqat ichki doimiy SQL bo'laklari uchun.
    const files = import.meta.glob('../src/*.ts', { query: '?raw', import: 'default', eager: true }) as Record<string, string>;
    expect(Object.keys(files).length).toBeGreaterThanOrEqual(5);
    for (const [name, src] of Object.entries(files)) {
      const sqlTemplates = [...src.matchAll(/`([^`]*\b(?:SELECT|DELETE|INSERT|UPDATE)\b[^`]*)`/g)];
      const interpolated = sqlTemplates.flatMap((m) => [...m[1].matchAll(/\$\{([^}]+)\}/g)].map((x) => x[1]));
      for (const expr of interpolated) {
        // Ruxsat: faqat modul ichidagi doimiy SQL bo'laklari.
        expect(['owned', 'ownedAssignments', 'a'], `${name}: ${expr}`).toContain(expr.trim());
      }
    }
  });
});

describe('HTTP qoidalari', () => {
  it("CORS standart holatda yo'q; preflight begona originga — 403", async () => {
    const s = makeServer();
    const r = await s.call('GET', '/v1/health', { headers: { origin: 'https://evil.example' } });
    expect(r.status).toBe(200);
    expect(r.headers.get('access-control-allow-origin')).toBeNull();
    const pre = await s.call('OPTIONS', '/v1/me', { headers: { origin: 'https://evil.example' } });
    expect(pre.status).toBe(403);
    expect(pre.headers.get('access-control-allow-origin')).toBeNull();
  });

  it('CORS faqat sozlangan originga', async () => {
    const s = makeServer({ LG_ALLOWED_ORIGINS: 'https://app.labguide.uz' });
    const ok = await s.call('OPTIONS', '/v1/me', { headers: { origin: 'https://app.labguide.uz' } });
    expect(ok.status).toBe(204);
    expect(ok.headers.get('access-control-allow-origin')).toBe('https://app.labguide.uz');
    expect(ok.headers.get('access-control-allow-credentials')).toBeNull();
    const bad = await s.call('GET', '/v1/health', { headers: { origin: 'https://app.labguide.uz.evil.example' } });
    expect(bad.headers.get('access-control-allow-origin')).toBeNull();
  });

  it("xavfsizlik sarlavhalari, 404/405, noto'g'ri tana", async () => {
    const s = makeServer();
    const h = await s.call('GET', '/v1/health');
    expect(h.headers.get('cache-control')).toBe('no-store');
    expect(h.headers.get('x-content-type-options')).toBe('nosniff');
    expect((await s.call('GET', '/v1/nope')).data).toEqual({ error: 'not_found' });
    expect((await s.call('GET', '/v1/auth/otp/request')).status).toBe(405);
    expect((await s.call('POST', '/v1/auth/otp/request', { raw: '{bad', headers: { 'content-type': 'application/json' } })).data.error).toBe('invalid_json');
    expect((await s.call('POST', '/v1/auth/otp/request', { raw: '[]', headers: { 'content-type': 'application/json' } })).data.error).toBe('invalid_json');
    expect((await s.call('POST', '/v1/auth/otp/request', { raw: 'email=a', headers: { 'content-type': 'text/plain' } })).status).toBe(415);
    const big = JSON.stringify({ email: 'a@b.uz', pad: 'x'.repeat(40_000) });
    expect((await s.call('POST', '/v1/auth/otp/request', { raw: big, headers: { 'content-type': 'application/json' } })).status).toBe(413);
  });

  it("ichki xato tafsiloti javobga chiqmaydi", async () => {
    const s = makeServer();
    const broken = {
      prepare() {
        throw new Error('D1_ERROR: no such table: users_secret_internal');
      },
      batch() {
        throw new Error('D1_ERROR: internal');
      },
    } as unknown as D1Database;
    const s2 = makeServer({ DB: broken } as Partial<Env>);
    const r = await s2.call('POST', '/v1/auth/otp/request', { body: { email: uniqueEmail() } });
    expect(r.status).toBe(500);
    expect(r.data).toEqual({ error: 'internal' });
    expect(r.text).not.toContain('D1_ERROR');
    expect(r.text).not.toContain('users_secret_internal');
    void s;
  });

  it("ko'chirilmagan funksiyalar — 501 (ishlayotgandek ko'rsatilmaydi)", async () => {
    const s = makeServer();
    const { token } = await s.signIn(uniqueEmail());
    for (const p of ['/v1/support/threads', '/v1/entitlements', '/v1/reviews']) {
      const r = await s.call('GET', p, { token });
      expect(r.status, p).toBe(501);
      expect(r.data.error).toBe('not_implemented');
    }
    expect((await s.call('GET', '/v1/support/threads')).status).toBe(401);
    expect((await s.call('GET', '/v1/partners')).status).toBe(501);
  });

  it('kunlik tozalash eskirgan kod, sessiya va hisoblagichlarni o\'chiradi', async () => {
    const s = makeServer();
    const { token } = await s.signIn(uniqueEmail('cron'));
    await s.call('POST', '/v1/auth/otp/request', { body: { email: uniqueEmail('cron2') } });
    s.clock.now += 61 * 86400_000;
    await s.app.scheduled(s.env);
    expect((await s.call('GET', '/v1/me', { token })).status).toBe(401);
    const left = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM otp_challenges WHERE expires_at < ?1').bind(s.clock.now).first<{ n: number }>();
    expect(left!.n).toBe(0);
  });
});

describe('Brevo', () => {
  afterEach(() => vi.restoreAllMocks());

  it("to'g'ri so'rov: api-key sarlavhada, kod matnda, kuzatuvsiz", async () => {
    const spy = vi.spyOn(globalThis, 'fetch').mockResolvedValue(new Response('{"messageId":"x"}', { status: 201 }));
    const env = { BREVO_API_KEY: 'k-123', LG_SENDER_EMAIL: 'noreply@labguide.uz' } as Env;
    expect(await brevoSender(env, 'a@b.uz', '123456', 'ru')).toBe('sent');
    const [url, init] = spy.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://api.brevo.com/v3/smtp/email');
    expect((init.headers as Record<string, string>)['api-key']).toBe('k-123');
    const body = JSON.parse(init.body as string);
    expect(body.to).toEqual([{ email: 'a@b.uz' }]);
    expect(body.sender.email).toBe('noreply@labguide.uz');
    expect(body.textContent).toContain('123456');
    expect(body.subject).toContain('LabGuide');
  });

  it("xato yoki sozlanmagan holat — kalit/email logga chiqmaydi", async () => {
    const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    vi.spyOn(globalThis, 'fetch').mockResolvedValue(new Response('{"message":"bad a@b.uz"}', { status: 401 }));
    expect(await brevoSender({ BREVO_API_KEY: 'k-secret', LG_SENDER_EMAIL: 's@x.uz' } as Env, 'a@b.uz', '111111', 'uz')).toBe('failed');
    const logged = JSON.stringify(warn.mock.calls);
    expect(logged).not.toContain('k-secret');
    expect(logged).not.toContain('a@b.uz');
    expect(await brevoSender({} as Env, 'a@b.uz', '111111', 'uz')).toBe('not_configured');
  });
});
