import { describe, expect, it } from 'vitest';
import { THREADS_PER_DAY } from '../src/support';
import { makeServer, uniqueEmail } from './helpers';

async function setup() {
  const owner = uniqueEmail('owner');
  const s = makeServer({ LG_ADMIN_EMAILS: owner });
  const boss = await s.signInAdmin(owner);
  return { s, boss };
}

const newThread = (s: ReturnType<typeof makeServer>, token: string, subject = 'QC grafigi') =>
  s.call('POST', '/v1/support/threads', { token, body: { kind: 'bug', subject, body: 'Levey-Jennings ekranida nuqta yo‘q' } });

describe('Taklif va yordam', () => {
  it('A murojaat yozadi → admin javob beradi (audit) → A o‘qiydi va qayta yozadi; B ko‘rmaydi', async () => {
    const { s, boss } = await setup();
    const a = await s.signIn(uniqueEmail('a'));
    const b = await s.signIn(uniqueEmail('b'));

    expect((await s.call('GET', '/v1/support/threads')).status).toBe(401);
    const c = await newThread(s, a.token);
    expect(c.status).toBe(201);
    const id = c.data.id as string;
    const mine = await s.call('GET', '/v1/support/threads', { token: a.token });
    expect(mine.data).toHaveLength(1);
    expect(mine.data[0]).toMatchObject({ id, kind: 'bug', status: 'new', subject: 'QC grafigi', user_id: a.userId });

    // B: ro'yxat bo'sh, xabarlar va yozish — 404 (borligi bildirilmaydi).
    expect((await s.call('GET', '/v1/support/threads', { token: b.token })).data).toEqual([]);
    expect((await s.call('GET', `/v1/support/threads/${id}/messages`, { token: b.token })).status).toBe(404);
    expect((await s.call('POST', `/v1/support/threads/${id}/messages`, { token: b.token, body: { body: 'salom' } })).status).toBe(404);
    expect((await s.call('POST', `/v1/support/threads/${id}/read`, { token: b.token })).status).toBe(404);
    // Oddiy foydalanuvchi admin yo'llariga kira olmaydi.
    expect((await s.call('POST', `/v1/admin/support/threads/${id}/reply`, { token: b.token, body: { body: 'x' } })).status).toBe(403);

    const list = await s.call('GET', '/v1/admin/support/threads?status=new', { token: boss.token });
    const t = list.data.find((x: any) => x.id === id);
    expect(t.email_masked).toMatch(/^a\.\*\*\*@example\.test$/);
    expect(list.text).not.toMatch(/\b[0-9a-f]{64}\b/);
    expect((await s.call('GET', `/v1/support/threads/${id}/messages`, { token: boss.token })).data).toHaveLength(1);

    const rep = await s.call('POST', `/v1/admin/support/threads/${id}/reply`, { token: boss.token, body: { body: 'Rahmat, tuzatamiz.' } });
    expect(rep.status).toBe(201);
    const mine2 = (await s.call('GET', '/v1/support/threads', { token: a.token })).data[0];
    expect(mine2.status).toBe('answered');
    expect(Date.parse(mine2.last_admin_message_at)).toBeGreaterThanOrEqual(Date.parse(mine2.user_read_at));
    const msgs = (await s.call('GET', `/v1/support/threads/${id}/messages`, { token: a.token })).data;
    expect(msgs.map((m: any) => [m.from_admin, m.body])).toEqual([
      [false, 'Levey-Jennings ekranida nuqta yo‘q'],
      [true, 'Rahmat, tuzatamiz.'],
    ]);

    s.clock.now += 1000;
    expect((await s.call('POST', `/v1/support/threads/${id}/read`, { token: a.token })).status).toBe(200);
    expect((await s.call('POST', `/v1/support/threads/${id}/messages`, { token: a.token, body: { body: 'Kutaman' } })).status).toBe(201);
    expect((await s.call('GET', '/v1/support/threads', { token: a.token })).data[0].status).toBe('new');

    expect((await s.call('POST', `/v1/admin/support/threads/${id}/status`, { token: boss.token, body: { status: 'closed' } })).data).toEqual({
      status: 'closed',
    });
    expect((await s.call('POST', `/v1/admin/support/threads/${id}/status`, { token: boss.token, body: { status: 'deleted' } })).status).toBe(400);
    expect((await s.call('POST', `/v1/admin/support/threads/${id}/read`, { token: boss.token })).status).toBe(200);
    const log = (await s.call('GET', '/v1/admin/audit', { token: boss.token })).data.map((e: any) => e.action);
    expect(log).toEqual(expect.arrayContaining(['support_reply', 'support_status']));

    // Hisob o'chirilsa — murojaatlari ham o'chadi.
    expect((await s.call('DELETE', '/v1/me', { token: a.token })).status).toBe(204);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM support_threads WHERE id = ?1').bind(id).first<{ n: number }>();
    expect(n!.n).toBe(0);
  });

  it('validatsiya, biriktirma yo‘q, kunlik limit', async () => {
    const { s } = await setup();
    const a = await s.signIn(uniqueEmail('lim'));
    const bad = [
      { kind: 'spam', subject: 'Mavzu', body: 'x' },
      { kind: 'bug', subject: 'ab', body: 'x' },
      { kind: 'bug', subject: 'x'.repeat(121), body: 'x' },
      { kind: 'bug', subject: 'Mavzu', body: '   ' },
      { kind: 'bug', subject: 'Mavzu', body: 'x'.repeat(4001) },
    ];
    for (const body of bad) expect((await s.call('POST', '/v1/support/threads', { token: a.token, body })).status).toBe(400);
    const att = await s.call('POST', '/v1/support/threads', {
      token: a.token,
      body: { kind: 'bug', subject: 'Mavzu', body: 'x', attachment: 'a/b.png' },
    });
    expect(att.data.error).toBe('attachments_unavailable');
    for (let i = 0; i < THREADS_PER_DAY; i++) expect((await newThread(s, a.token, `Mavzu ${i}`)).status).toBe(201);
    expect((await newThread(s, a.token, 'Oshiqcha')).status).toBe(429);
    expect((await s.call('GET', '/v1/support/threads/not-a-uuid/messages', { token: a.token })).status).toBe(404);
  });
});
