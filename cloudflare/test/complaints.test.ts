import { describe, expect, it } from 'vitest';
import { COMPLAINTS_PER_HOUR } from '../src/complaints';
import { makeServer, uniqueEmail } from './helpers';

async function setup() {
  const owner = uniqueEmail('owner');
  const s = makeServer({ ADMIN_EMAILS: owner } as never);
  const boss = await s.signIn(owner);
  return { s, boss };
}

describe('ilova ichidagi shikoyatlar (Apple 1.2)', () => {
  it('hisobli va mehmon yuboradi; admin ko‘radi, izoh yozadi, hal qiladi, qayta ochadi — audit', async () => {
    const { s, boss } = await setup();
    const u = await s.signIn(uniqueEmail('user'));
    const a = await s.call('POST', '/v1/complaints', {
      token: u.token,
      body: { kind: 'inappropriate', body: 'Bu savolda haqoratli so‘zlar bor', target_ref: 'community:question:abc123', lang: 'uz' },
    });
    expect(a.status).toBe(201);
    expect(a.data.status).toBe('open');
    const g = await s.call('POST', '/v1/complaints', { body: { kind: 'bug', body: 'Kalkulyator noto‘g‘ri hisobladi' }, ip: '198.18.0.1' });
    expect(g.status).toBe(201);
    // Yaroqsiz token — mehmon deb hisoblanmaydi.
    expect((await s.call('POST', '/v1/complaints', { token: 'x'.repeat(43), body: { kind: 'bug', body: 'Salom dunyo' } })).status).toBe(401);
    // Validatsiya.
    for (const body of [
      { kind: 'spam', body: 'Salom dunyo' },
      { kind: 'bug', body: 'abc' },
      { kind: 'bug', body: 'x'.repeat(2001) },
      { kind: 'bug', body: 'Salom dunyo', target_ref: 'https://evil.example/?a=b c' },
    ]) {
      expect((await s.call('POST', '/v1/complaints', { body, ip: '198.18.0.2' })).status, JSON.stringify(body).slice(0, 40)).toBe(400);
    }
    // Oddiy foydalanuvchi ro'yxatni ko'rmaydi.
    expect((await s.call('GET', '/v1/admin/complaints', { token: u.token })).status).toBe(403);
    expect((await s.call('GET', '/v1/admin/complaints')).status).toBe(401);

    const list = await s.call('GET', '/v1/admin/complaints?status=open', { token: boss.token });
    const mine = list.data.find((c: any) => c.id === a.data.id);
    expect(mine).toMatchObject({
      kind: 'inappropriate',
      target_ref: 'community:question:abc123',
      anonymous: false,
      email_masked: expect.stringMatching(/^us\*\*\*@example\.test$/),
    });
    expect(list.data.find((c: any) => c.id === g.data.id)).toMatchObject({ anonymous: true, email_masked: null, user_id: null });
    expect(list.text).not.toMatch(/\b[0-9a-f]{64}\b/);
    expect((await s.call('GET', '/v1/admin/complaints?kind=bug', { token: boss.token })).data.every((c: any) => c.kind === 'bug')).toBe(true);
    expect((await s.call('GET', '/v1/admin/complaints?status=bogus', { token: boss.token })).status).toBe(400);

    const note = await s.call('POST', `/v1/admin/complaints/${a.data.id}/note`, { token: boss.token, body: { note: 'Post o‘chirildi' } });
    expect(note.data.admin_note).toBe('Post o‘chirildi');
    const res = await s.call('POST', `/v1/admin/complaints/${a.data.id}/status`, { token: boss.token, body: { status: 'resolved' } });
    expect(res.data).toMatchObject({ status: 'resolved', resolved_at: expect.any(String) });
    expect((await s.call('GET', '/v1/admin/complaints?status=open', { token: boss.token })).data.find((c: any) => c.id === a.data.id)).toBeUndefined();
    const re = await s.call('POST', `/v1/admin/complaints/${a.data.id}/status`, { token: boss.token, body: { status: 'open' } });
    expect(re.data).toMatchObject({ status: 'open', resolved_at: null });
    expect((await s.call('GET', `/v1/admin/complaints/${a.data.id}`, { token: boss.token })).data.admin_note).toBe('Post o‘chirildi');
    expect((await s.call('GET', '/v1/admin/complaints/not-a-uuid', { token: boss.token })).status).toBe(404);
    const log = (await s.call('GET', '/v1/admin/audit', { token: boss.token })).data.map((e: any) => e.action);
    expect(log).toEqual(expect.arrayContaining(['complaint_note', 'complaint_resolved', 'complaint_reopened']));

    // Hisob o'chirilsa — shikoyat qoladi, lekin hisobga bog'lanmaydi.
    expect((await s.call('DELETE', '/v1/me', { token: u.token })).status).toBe(204);
    const after = await s.call('GET', `/v1/admin/complaints/${a.data.id}`, { token: boss.token });
    expect(after.data).toMatchObject({ anonymous: true, user_id: null });
  });

  it('soatiga 5 ta: 6-chisi 429 + Retry-After (hisob va mehmon IP bo‘yicha)', async () => {
    const { s } = await setup();
    const u = await s.signIn(uniqueEmail('spam'));
    const send = (opts: { token?: string; ip?: string }) =>
      s.call('POST', '/v1/complaints', { ...opts, body: { kind: 'other', body: 'Takroriy xabar matni' } });
    for (let i = 0; i < COMPLAINTS_PER_HOUR; i++) expect((await send({ token: u.token, ip: `198.18.1.${i}` })).status).toBe(201);
    const sixth = await send({ token: u.token, ip: '198.18.1.99' });
    expect(sixth.status).toBe(429);
    expect(Number(sixth.headers.get('retry-after'))).toBeGreaterThan(0);

    for (let i = 0; i < COMPLAINTS_PER_HOUR; i++) expect((await send({ ip: '198.18.2.1' })).status).toBe(201);
    expect((await send({ ip: '198.18.2.1' })).status).toBe(429);
    // Boshqa IP dagi mehmon — alohida.
    expect((await send({ ip: '198.18.2.2' })).status).toBe(201);
    // Bir soatdan keyin — yana.
    s.clock.now += 3601_000;
    expect((await send({ ip: '198.18.2.1' })).status).toBe(201);
  });
});
