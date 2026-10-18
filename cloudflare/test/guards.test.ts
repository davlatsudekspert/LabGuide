// Qorovul (guard) testlari: server tomonidagi egasi qarorlari qaytib
// buzilmasin. Batafsil xatti-harakat boshqa fayllarda (auth, community,
// moderation, adminconsole, groups, variants); bu yerda — "yo'l bor / yo'q"
// va standart qiymatlar. Jadval: docs/GUARDS.md.
import { describe, expect, it } from 'vitest';
import WORDS from '../data/abuse_words.json';
import { adminAllowlist, DEFAULT_ADMIN_EMAILS } from '../src/auth';
import type { Ctx } from '../src/context';
import { findAbuse } from '../src/moderation';
import { makeServer, uniqueEmail } from './helpers';

const ctxWith = (env: Record<string, string | undefined>) => ({ env }) as unknown as Ctx;

describe('qorovul: admin (ADMIN_EMAILS)', () => {
  it('ikkala secret bo‘sh — egasi emaili (standart)', () => {
    expect(DEFAULT_ADMIN_EMAILS).toBe('davlatsudekspert@gmail.com');
    expect(adminAllowlist(ctxWith({}))).toEqual(['davlatsudekspert@gmail.com']);
    expect(adminAllowlist(ctxWith({ ADMIN_EMAILS: ' ', LG_ADMIN_EMAILS: '' }))).toEqual([
      'davlatsudekspert@gmail.com',
    ]);
  });

  it('ADMIN_EMAILS ustun, keyin LG_ADMIN_EMAILS (kichik harf)', () => {
    expect(adminAllowlist(ctxWith({ ADMIN_EMAILS: 'A@x.uz, b@x.uz', LG_ADMIN_EMAILS: 'c@x.uz' }))).toEqual([
      'a@x.uz',
      'b@x.uz',
    ]);
    expect(adminAllowlist(ctxWith({ LG_ADMIN_EMAILS: 'C@x.uz' }))).toEqual(['c@x.uz']);
  });
});

describe('qorovul: marshrutlar', () => {
  // Kirishsiz so'rov: mavjud yo'l — 401/403/400 (yoki 503 sozlanmagan), yo'q yo'l — 404.
  const KEPT: [string, string][] = [
    ['DELETE', '/v1/me'], // Apple 5.1.1(v): hisobni o'zi o'chirish
    ['POST', '/v1/admin/accounts/delete'], // D-63: egasi email bo'yicha o'chiradi
    ['GET', '/v1/community/blocks'], // D-62: server bloklari
    ['POST', '/v1/community/blocks'],
    ['DELETE', '/v1/community/blocks'],
    ['POST', '/v1/community/reports'], // shikoyat
    ['GET', '/v1/auth/providers'], // D-56: Google / Apple
    ['POST', '/v1/auth/google'],
    ['POST', '/v1/auth/apple'],
    ['POST', '/v1/groups/join'], // QR / kod bilan qo'shilish
    ['POST', '/v1/assignments/x/start'], // variantli test to'plami (D-66)
    ['POST', '/v1/assignments/x/submit'],
  ];

  it('egasi qarorlari bilan qo‘shilgan yo‘llar mavjud', async () => {
    const s = makeServer();
    for (const [m, p] of KEPT) {
      const r = await s.call(m, p, m === 'GET' ? {} : { body: {} });
      expect(r.status, `${m} ${p}`).not.toBe(404);
      expect(r.status, `${m} ${p}`).not.toBe(405);
      // 503 — sozlanmagan provayder (D-56: secret yo'q bo'lsa endpoint 503).
      expect(r.status === 503 || r.status < 500, `${m} ${p}: ${r.status}`).toBe(true);
    }
  });

  it('D-58: Pro / to‘lov / obuna yo‘llari yo‘q', async () => {
    const s = makeServer();
    for (const p of [
      '/v1/billing',
      '/v1/billing/verify',
      '/v1/purchases',
      '/v1/subscriptions',
      '/v1/entitlements',
      '/v1/me/entitlements',
      '/v1/me/plan',
      '/v1/pro',
      '/v1/iap/apple',
      '/v1/iap/google',
    ]) {
      for (const m of ['GET', 'POST']) {
        expect((await s.call(m, p, m === 'GET' ? {} : { body: {} })).status, `${m} ${p}`).toBe(404);
      }
    }
  });

  it('D-58: /v1/me tarifni (`plan`) bermaydi', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail('guard'));
    const me = await s.call('GET', '/v1/me', { token: u.token });
    expect(me.status).toBe(200);
    expect(Object.keys(me.data)).not.toContain('plan');
    expect(me.text).not.toMatch(/"(plan|pro|subscription|entitlements?)"\s*:/);
  });
});

describe('qorovul: hamjamiyat so‘z filtri (D-62)', () => {
  it('ro‘yxat bo‘sh emas va filtr ishlaydi; tibbiy so‘zlar o‘tadi', () => {
    expect(WORDS.cyrillic.words.length).toBeGreaterThanOrEqual(50);
    expect(WORDS.latin.words.length).toBeGreaterThanOrEqual(40);
    for (const t of ['сука', 'fuck', 'jalab', 'қанжиқ']) expect(findAbuse(t), t).not.toBeNull();
    for (const t of ['анализ мочи', 'siydik tahlili', 'spermogramma', 'pH']) expect(findAbuse(t), t).toBeNull();
  });

  it('haqoratli savol — 400 abusive_language (so‘z oshkor qilinmaydi)', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail('guard-cm'));
    const r = await s.call('POST', '/v1/community/questions', {
      token: u.token,
      body: { title: 'Natija nima degani, сука?', body: 'Siydik tahlili natijasi noto‘g‘ri chiqdi.' },
    });
    expect(r.status).toBe(400);
    expect(r.data).toEqual({ error: 'abusive_language' });
    expect(r.text).not.toContain('сука');
  });
});
