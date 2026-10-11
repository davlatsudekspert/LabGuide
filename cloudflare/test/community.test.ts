import { afterEach, describe, expect, it, vi } from 'vitest';
import { makeServer, uniqueEmail } from './helpers';

const MARKER = 'SECRET-DIPLOMA-MARKER-9f3a';

/** Kichik "JPEG": sehrli baytlar + belgi (rasm hech qayerda saqlanmasligini tekshirish uchun). */
function jpeg(extra = 0): Uint8Array {
  const tail = new TextEncoder().encode(MARKER);
  const b = new Uint8Array(4 + tail.length + extra);
  b.set([0xff, 0xd8, 0xff, 0xe0]);
  b.set(tail, 4);
  return b;
}

const GOOD = {
  response: {
    is_document: true,
    document_type: 'diploma',
    field_is_lab_or_medical: true,
    institution_visible: true,
    issue_year: 2015,
    confidence: 0.92,
  },
};
const BAD = { response: JSON.stringify({ ...GOOD.response, field_is_lab_or_medical: false, confidence: 0.4 }) };

type Server = ReturnType<typeof makeServer>;

function mockAi(s: Server, verifyResult: unknown = GOOD) {
  s.setAi(async (model, input) => {
    if (model.includes('m2m100')) return { translated_text: `[${input.target_lang}] ${input.text}` };
    return verifyResult;
  });
}

async function upload(s: Server, token: string, bytes: Uint8Array, q = 'role=laborant&country=UZ', type = 'image/jpeg') {
  return s.call('POST', `/v1/community/verify?${q}`, { token, raw: bytes, headers: { 'content-type': type } });
}

async function specialist(s: Server, email = uniqueEmail('spec')) {
  const u = await s.signIn(email);
  mockAi(s);
  const r = await upload(s, u.token, jpeg());
  expect(r.status).toBe(200);
  expect(r.data.status).toBe('verified');
  return u;
}

async function ask(s: Server, token: string, extra: Record<string, unknown> = {}) {
  return s.call('POST', '/v1/community/questions', {
    token,
    body: { title: 'Kaliy natijasi yuqori chiqdi, nima qilish kerak?', body: 'Bemorda belgilar yo‘q, natijaga ishonsa bo‘ladimi?', ...extra },
  });
}

afterEach(() => vi.restoreAllMocks());

/** Hisobni "eski" qilish (shikoyati avtomatik to'xtatishga sanaladi). */
async function age(s: Server, userId: string, days = 4) {
  await s.env.DB.prepare('UPDATE users SET created_at = created_at - ?2 WHERE id = ?1').bind(userId, days * 86400_000).run();
}

describe('hamjamiyat: mutaxassisni avtomatik tasdiqlash', () => {
  it('hujjat AI bilan tekshiriladi → belgi darhol; model id — sozlamadan', async () => {
    const s = makeServer({ LG_VERIFY_MODEL: '@cf/test/vision-model' });
    const u = await s.signIn(uniqueEmail());
    expect((await s.call('GET', '/v1/community/me', { token: u.token })).data).toMatchObject({
      status: 'none',
      can_ask: true,
      can_answer: false,
    });
    mockAi(s);
    const r = await upload(s, u.token, jpeg());
    expect(r.status).toBe(200);
    expect(r.data).toMatchObject({ status: 'verified', method: 'ai_auto' });
    expect(s.aiCalls).toHaveLength(1);
    expect(s.aiCalls[0].model).toBe('@cf/test/vision-model');
    const content = (s.aiCalls[0].input.messages as any[])[1].content;
    expect(content[1].image_url.url.startsWith('data:image/jpeg;base64,')).toBe(true);
    const me = await s.call('GET', '/v1/community/me', { token: u.token });
    expect(me.data).toMatchObject({ status: 'verified', method: 'ai_auto', role: 'laborant', country: 'UZ', can_answer: true });
    // Sabab — faqat kodlar (AI erkin matni emas).
    expect(me.data.reason).toMatch(/^doc=diploma;field=ok;institution=yes;year=2015;conf=0\.92$/);
  });

  it("FAYL SAQLANMAYDI: D1 da ham, logda ham rasm baytlari yo'q", async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    mockAi(s);
    const logs: string[] = [];
    for (const k of ['log', 'info', 'warn', 'error', 'debug'] as const) {
      vi.spyOn(console, k).mockImplementation((...a: unknown[]) => {
        logs.push(a.map(String).join(' '));
      });
    }
    const img = jpeg(64);
    let b64 = '';
    for (const x of img) b64 += String.fromCharCode(x);
    b64 = btoa(b64);
    expect((await upload(s, u.token, img)).status).toBe(200);
    // AI xato bersa ham log faqat xato turini yozadi.
    const u2 = await s.signIn(uniqueEmail());
    s.setAi(async () => {
      throw new Error(`boom ${MARKER}`);
    });
    expect((await upload(s, u2.token, img)).status).toBe(503);

    const tables = await s.env.DB.prepare(`SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE '_cf%' AND name NOT LIKE 'sqlite%' AND name NOT LIKE 'd1_%'`).all<{ name: string }>();
    expect(tables.results.length).toBeGreaterThan(10);
    for (const { name } of tables.results) {
      const rows = await s.env.DB.prepare(`SELECT * FROM "${name}"`).all();
      const dump = JSON.stringify(rows.results);
      expect(dump, name).not.toContain(MARKER);
      expect(dump, name).not.toContain(b64.slice(0, 24));
    }
    const allLogs = logs.join('\n');
    expect(allLogs).not.toContain(MARKER);
    expect(allLogs).not.toContain(b64.slice(0, 24));
    // Saqlangan ustunlar — faqat ruxsat etilganlar.
    const cols = await s.env.DB.prepare(`SELECT name FROM pragma_table_info('community_members')`).all<{ name: string }>();
    expect(cols.results.map((c) => c.name).sort()).toEqual(
      ['ai_reason', 'country', 'credential', 'institution', 'is_owner', 'method', 'prev_status', 'restored_at', 'role', 'specialty_code', 'status', 'suspended_at', 'updated_at', 'user_hash', 'verified_at', 'year'].sort(),
    );
  });

  it('limitlar: 5 MB, faqat JPEG/PNG, PDF — aniq xato, kuniga 3 urinish', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    mockAi(s, BAD);
    expect((await upload(s, u.token, jpeg(5 * 1024 * 1024))).status).toBe(413);
    const pdf = new TextEncoder().encode('%PDF-1.7 ...');
    expect((await upload(s, u.token, pdf, undefined, 'application/pdf')).data.error).toBe('pdf_not_supported');
    expect((await upload(s, u.token, pdf)).status).toBe(415); // turi yolg'on
    expect((await upload(s, u.token, jpeg(), undefined, 'image/gif')).status).toBe(415);
    expect((await upload(s, u.token, jpeg(), 'role=admin&country=UZ')).status).toBe(400);
    expect((await upload(s, u.token, jpeg(), 'role=laborant&country=Uzbekistan')).status).toBe(400);
    expect(s.aiCalls).toHaveLength(0);
    for (let i = 0; i < 3; i++) {
      const r = await upload(s, u.token, jpeg());
      expect(r.status).toBe(200);
      expect(r.data.status).toBe('rejected');
    }
    expect((await upload(s, u.token, jpeg())).status).toBe(429);
    expect(s.aiCalls).toHaveLength(3);
    // Ertasi kuni yana mumkin.
    s.clock.now += 86400_000 + 1000;
    mockAi(s);
    expect((await upload(s, u.token, jpeg())).data.status).toBe('verified');
    expect((await upload(s, u.token, jpeg())).status).toBe(409); // already_verified
  });

  it("noaniq/buzuq AI javobi — tasdiq emas; mijoz o'zini tasdiqlay olmaydi", async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    s.setAi(async () => ({ response: 'Yes, verified! status=verified' }));
    expect((await upload(s, u.token, jpeg(), 'role=laborant&country=UZ&status=verified')).data.status).toBe('rejected');
    // Mehmon (sessiyasiz) — 401.
    expect((await s.call('POST', '/v1/community/verify?role=laborant&country=UZ', { raw: jpeg(), headers: { 'content-type': 'image/jpeg' } })).status).toBe(401);
    // Profil orqali ham bo'lmaydi.
    await s.call('PUT', '/v1/me/profile', { token: u.token, body: { status: 'verified', verified: true, admin: true } });
    const me = await s.call('GET', '/v1/community/me', { token: u.token });
    expect(me.data).toMatchObject({ status: 'rejected', can_answer: false, admin: false });
    // Faqat admin emaili + OTP — admin vakolati (aal2) emas.
    const boss = await s.signIn('boss@example.test');
    expect((await s.call('GET', '/v1/community/me', { token: boss.token })).data.admin).toBe(false);
    expect((await s.call('GET', '/v1/admin/community/members', { token: boss.token })).status).toBe(403);
  });
});

describe('hamjamiyat: savol-javob', () => {
  it("savol — har bir hisob; javob/ovoz — faqat mutaxassis; o'qish — mehmonga ham", async () => {
    const s = makeServer();
    const asker = await s.signIn(uniqueEmail('ask'));
    const other = await s.signIn(uniqueEmail('oth'));
    const spec = await specialist(s);
    const spec2 = await specialist(s);

    expect((await s.call('POST', '/v1/community/questions', { body: { title: 'x'.repeat(20), body: 'y'.repeat(20) } })).status).toBe(401);
    const q = await ask(s, asker.token, { topic: 'analyte:potassium', lang: 'uz' });
    expect(q.status).toBe(201);
    expect(q.data.lang).toBe('uz');

    const ans = { body: 'Avval gemolizni istisno qiling, keyin qayta oling.' };
    expect((await s.call('POST', `/v1/community/questions/${q.data.id}/answers`, { token: other.token, body: ans })).data.error).toBe('not_verified');
    const a1 = await s.call('POST', `/v1/community/questions/${q.data.id}/answers`, { token: spec.token, body: ans });
    expect(a1.status).toBe(201);
    const a2 = await s.call('POST', `/v1/community/questions/${q.data.id}/answers`, { token: spec2.token, body: { body: 'EDTA ifloslanishini ham tekshiring, kalsiy past bo‘ladi.' } });
    expect(a2.status).toBe(201);

    // Ovoz: faqat mutaxassis, o'z javobiga emas, takror sanalmaydi.
    expect((await s.call('POST', `/v1/community/answers/${a1.data.id}/vote`, { token: other.token })).status).toBe(403);
    expect((await s.call('POST', `/v1/community/answers/${a1.data.id}/vote`, { token: spec.token })).data.error).toBe('own_answer');
    expect((await s.call('POST', `/v1/community/answers/${a1.data.id}/vote`, { token: spec2.token })).data.upvotes).toBe(1);
    expect((await s.call('POST', `/v1/community/answers/${a1.data.id}/vote`, { token: spec2.token })).data.upvotes).toBe(1);
    expect((await s.call('DELETE', `/v1/community/answers/${a1.data.id}/vote`, { token: spec2.token })).data.upvotes).toBe(0);
    await s.call('POST', `/v1/community/answers/${a2.data.id}/vote`, { token: spec.token });

    // Eng yaxshi javob — faqat savol muallifi.
    expect((await s.call('POST', `/v1/community/questions/${q.data.id}/best`, { token: spec.token, body: { answer_id: a1.data.id } })).status).toBe(403);
    expect((await s.call('POST', `/v1/community/questions/${q.data.id}/best`, { token: asker.token, body: { answer_id: 'nope' } })).status).toBe(400);
    expect((await s.call('POST', `/v1/community/questions/${q.data.id}/best`, { token: asker.token, body: { answer_id: a1.data.id } })).status).toBe(200);

    // Mehmon o'qiydi: eng yaxshi javob birinchi, muallif ismsiz.
    const g = await s.call('GET', `/v1/community/questions/${q.data.id}`);
    expect(g.status).toBe(200);
    expect(g.data.answers.map((a: any) => a.id)).toEqual([a1.data.id, a2.data.id]);
    expect(g.data.answers[0]).toMatchObject({ is_best: true, author: { kind: 'specialist', verified: true, method: 'ai_auto', role: 'laborant', country: 'UZ', name: null } });
    expect(g.data.question.author).toMatchObject({ kind: 'member', verified: false });
    expect(g.data.viewer).toMatchObject({ signed_in: false, can_answer: false });
    expect(JSON.stringify(g.data)).not.toMatch(/user_hash|author_hash|@example/);
    const asSpec = await s.call('GET', `/v1/community/questions/${q.data.id}`, { token: spec2.token });
    expect(asSpec.data.viewer).toMatchObject({ can_answer: true, can_vote: true, is_author: false });
    expect(asSpec.data.answers[1].voted).toBe(false);
    expect(asSpec.data.answers[1].author.is_me).toBe(true);
  });

  it('ro\'yxat: mavzu, "mening savollarim", sahifalash, cheklovlar', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    const u2 = await s.signIn(uniqueEmail());
    for (let i = 0; i < 5; i++) {
      expect((await ask(s, u.token, { title: `HbA1c savoli raqam ${i} haqida`, topic: 'analyte:hba1c' })).status).toBe(201);
    }
    expect((await ask(s, u.token)).status).toBe(429); // kuniga 5 ta
    expect((await ask(s, u2.token, { topic: 'condition:type-2-diabetes' })).status).toBe(201);
    expect((await ask(s, u2.token, { title: 'qisqa' })).status).toBe(400);
    expect((await ask(s, u2.token, { body: 'x'.repeat(4001) })).status).toBe(400);
    expect((await ask(s, u2.token, { topic: "analyte:x' OR 1=1" })).status).toBe(400);
    expect((await ask(s, u2.token, { body: 'Menga yozing: ali@mail.uz, natijani yuboraman' })).data.error).toBe('contact_data');
    expect((await ask(s, u2.token, { body: 'Telefon +998 90 123 45 67 ga qo‘ng‘iroq qiling' })).data.error).toBe('contact_data');

    const page1 = await s.call('GET', '/v1/community/questions?topic=analyte:hba1c&limit=3');
    expect(page1.data.total).toBe(5);
    expect(page1.data.items).toHaveLength(3);
    expect(page1.data.next_offset).toBe(3);
    const page2 = await s.call('GET', '/v1/community/questions?topic=analyte:hba1c&limit=3&offset=3');
    expect(page2.data.items).toHaveLength(2);
    expect(page2.data.next_offset).toBeNull();
    expect((await s.call('GET', '/v1/community/questions?topic=condition:type-2-diabetes')).data.total).toBe(1);
    expect((await s.call('GET', '/v1/community/questions?mine=1')).status).toBe(401);
    expect((await s.call('GET', '/v1/community/questions?mine=1', { token: u2.token })).data.total).toBe(1);
    expect((await s.call('GET', '/v1/community/questions?topic=bad')).status).toBe(400);
  });

  it('til avtomatik aniqlanadi (kirill → ru, ingliz → en)', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    const ru = await ask(s, u.token, { title: 'Калий повышен без симптомов, что делать?', body: 'Нужно ли повторить анализ сразу?', lang: 'uz' });
    expect(ru.data.lang).toBe('ru');
    const en = await ask(s, u.token, { title: 'What causes a falsely high potassium?', body: 'Is haemolysis the most common cause of this?', lang: 'ru' });
    expect(en.data.lang).toBe('en');
  });

  it('qadash va o\'chirish — faqat admin (aal2)', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    const spec = await specialist(s);
    const q = await ask(s, u.token);
    const a = await s.call('POST', `/v1/community/questions/${q.data.id}/answers`, { token: spec.token, body: { body: 'Javob matni yetarlicha uzun.' } });
    for (const t of [u.token, spec.token]) {
      expect((await s.call('POST', `/v1/community/questions/${q.data.id}/pin`, { token: t, body: { pinned: true } })).status).toBe(403);
      expect((await s.call('DELETE', `/v1/community/questions/${q.data.id}`, { token: t })).status).toBe(403);
      expect((await s.call('DELETE', `/v1/community/answers/${a.data.id}`, { token: t })).status).toBe(403);
    }
    const admin = await s.signInAdmin();
    expect((await s.call('POST', `/v1/community/questions/${q.data.id}/pin`, { token: admin.token, body: { pinned: true } })).data.pinned).toBe(true);
    expect((await s.call('GET', '/v1/community/questions')).data.items[0]).toMatchObject({ id: q.data.id, pinned: true });
    expect((await s.call('DELETE', `/v1/community/answers/${a.data.id}`, { token: admin.token })).status).toBe(200);
    expect((await s.call('GET', `/v1/community/questions/${q.data.id}`)).data.question.answer_count).toBe(0);
    expect((await s.call('DELETE', `/v1/community/questions/${q.data.id}`, { token: admin.token })).status).toBe(200);
    expect((await s.call('GET', `/v1/community/questions/${q.data.id}`)).status).toBe(404);
  });
});

describe('hamjamiyat: shikoyatlar va moderatsiya', () => {
  it("3 ta turli shikoyat → to'xtatiladi, admin panelida; admin tiklaydi/bekor qiladi", async () => {
    const s = makeServer();
    const spec = await specialist(s);
    const asker = await s.signIn(uniqueEmail());
    const q = await ask(s, asker.token);
    const a = await s.call('POST', `/v1/community/questions/${q.data.id}/answers`, { token: spec.token, body: { body: 'Shubhali javob matni bu yerda.' } });
    const reporters = [await s.signIn(uniqueEmail('r')), await s.signIn(uniqueEmail('r')), await s.signIn(uniqueEmail('r'))];
    // Avtomatik to'xtatishga faqat eski (>= 3 kun) yoki tasdiqlangan hisoblar sanaladi.
    for (const r of reporters) await age(s, r.userId);

    expect((await s.call('POST', '/v1/community/reports', { token: spec.token, body: { kind: 'answer', id: a.data.id } })).data.error).toBe('own_post');
    expect((await s.call('POST', '/v1/community/reports', { body: { kind: 'answer', id: a.data.id } })).status).toBe(401);
    // Bitta odam ikki marta — bitta.
    for (let i = 0; i < 2; i++) {
      expect((await s.call('POST', '/v1/community/reports', { token: reporters[0].token, body: { kind: 'answer', id: a.data.id, reason: 'wrong' } })).status).toBe(202);
    }
    await s.call('POST', '/v1/community/reports', { token: reporters[1].token, body: { kind: 'answer', id: a.data.id, reason: 'fake_specialist' } });
    expect((await s.call('GET', '/v1/community/me', { token: spec.token })).data.status).toBe('verified');
    await s.call('POST', '/v1/community/reports', { token: reporters[2].token, body: { kind: 'answer', id: a.data.id, reason: 'spam' } });

    const me = await s.call('GET', '/v1/community/me', { token: spec.token });
    expect(me.data).toMatchObject({ status: 'suspended', can_answer: false, can_ask: false });
    expect((await ask(s, spec.token)).data.error).toBe('suspended');
    // Kontent ommadan yashiriladi.
    expect((await s.call('GET', `/v1/community/questions/${q.data.id}`)).data.answers).toHaveLength(0);
    // Shikoyatlar oddiy foydalanuvchiga ko'rinmaydi.
    expect((await s.call('GET', '/v1/admin/community/members', { token: asker.token })).status).toBe(403);

    const admin = await s.signInAdmin();
    const list = await s.call('GET', '/v1/admin/community/members?status=suspended', { token: admin.token });
    expect(list.status).toBe(200);
    const row = list.data.find((m: any) => m.prev_status === 'verified');
    expect(row).toMatchObject({ status: 'suspended', reporters: 3, role: 'laborant' });
    expect(row.reports.map((r: any) => r.reason).sort()).toEqual(['fake_specialist', 'spam', 'wrong']);
    expect(row.reports[0].excerpt).toContain('Shubhali');

    expect((await s.call('POST', `/v1/admin/community/members/${row.user_hash}/restore`, { token: admin.token })).data.status).toBe('verified');
    expect((await s.call('GET', `/v1/community/questions/${q.data.id}`)).data.answers).toHaveLength(1);
    // Tiklashdan keyin eski shikoyatlar qayta sanalmaydi.
    await s.call('POST', '/v1/community/reports', { token: reporters[0].token, body: { kind: 'question', id: q.data.id } });
    const r4 = await s.signIn(uniqueEmail('r'));
    await s.call('POST', '/v1/community/reports', { token: r4.token, body: { kind: 'answer', id: a.data.id } });
    expect((await s.call('GET', '/v1/community/me', { token: spec.token })).data.status).toBe('verified');

    expect((await s.call('POST', `/v1/admin/community/members/${row.user_hash}/revoke`, { token: admin.token })).data.status).toBe('rejected');
    expect((await s.call('GET', '/v1/community/me', { token: spec.token })).data).toMatchObject({ status: 'rejected', can_answer: false });
    expect((await s.call('POST', `/v1/admin/community/members/${'0'.repeat(64)}/restore`, { token: admin.token })).status).toBe(404);
  });
});

describe('hamjamiyat: QA tuzatishlari (xavfsizlik)', () => {
  it("yangi hisoblar to'dasi (3 ta, < 3 kun) mutaxassisni to'xtata olmaydi; tasdiqlangan shikoyatchi sanaladi", async () => {
    const s = makeServer();
    const spec = await specialist(s);
    const q = await ask(s, spec.token);
    for (let i = 0; i < 5; i++) {
      const fresh = await s.signIn(uniqueEmail('sybil'));
      expect((await s.call('POST', '/v1/community/reports', { token: fresh.token, body: { kind: 'question', id: q.data.id, reason: 'spam' } })).status).toBe(202);
    }
    expect((await s.call('GET', '/v1/community/me', { token: spec.token })).data.status).toBe('verified');
    // Shikoyatlar saqlangan — admin ko'radi.
    const admin = await s.signInAdmin();
    const list = await s.call('GET', '/v1/admin/community/members?status=verified', { token: admin.token });
    expect(list.data.find((m: any) => m.reporters === 5)).toBeTruthy();
    // Tasdiqlangan mutaxassislar (hisob yangi bo'lsa ham) va eski hisob — sanaladi.
    const s1 = await specialist(s);
    const s2 = await specialist(s);
    const old = await s.signIn(uniqueEmail('old'));
    await age(s, old.userId);
    for (const r of [s1, s2, old]) {
      await s.call('POST', '/v1/community/reports', { token: r.token, body: { kind: 'question', id: q.data.id, reason: 'wrong' } });
    }
    expect((await s.call('GET', '/v1/community/me', { token: spec.token })).data.status).toBe('suspended');
  });

  it("admin bekor qilgan tasdiqni AI qayta bermaydi; to'xtatilgan a'zoni bekor qilish to'xtatishni olib tashlamaydi", async () => {
    const s = makeServer();
    const spec = await specialist(s);
    const admin = await s.signInAdmin();
    // A'zoni admin panelida topish: bitta shikoyat orqali (D1 testlar orasida umumiy).
    const q = await ask(s, spec.token);
    const rep = await s.signIn(uniqueEmail('r'));
    await s.call('POST', '/v1/community/reports', { token: rep.token, body: { kind: 'question', id: q.data.id } });
    const list = await s.call('GET', '/v1/admin/community/members?status=verified', { token: admin.token });
    const h = list.data.find((m: any) => m.reports.some((r: any) => r.target_id === q.data.id)).user_hash as string;
    // Avval to'xtatamiz, keyin bekor qilamiz — to'xtatish saqlanadi.
    expect((await s.call('POST', `/v1/admin/community/members/${h}/suspend`, { token: admin.token })).data.status).toBe('suspended');
    expect((await s.call('POST', `/v1/admin/community/members/${h}/revoke`, { token: admin.token })).data.status).toBe('suspended');
    const me1 = await s.call('GET', '/v1/community/me', { token: spec.token });
    expect(me1.data).toMatchObject({ status: 'suspended', can_ask: false, can_answer: false });
    expect((await ask(s, spec.token)).data.error).toBe('suspended');
    // Tiklash — 'rejected' ga (mutaxassis emas).
    expect((await s.call('POST', `/v1/admin/community/members/${h}/restore`, { token: admin.token })).data.status).toBe('rejected');
    // O'sha soxta hujjat bilan qayta AI tasdig'i — yo'q, AI chaqirilmaydi.
    const before = s.aiCalls.length;
    const r = await upload(s, spec.token, jpeg());
    expect(r.status).toBe(403);
    expect(r.data.error).toBe('revoked');
    expect(s.aiCalls.length).toBe(before);
    expect((await s.call('GET', '/v1/community/me', { token: spec.token })).data).toMatchObject({ status: 'rejected', can_answer: false });
  });

  it("AI javobi qat'iy: JSON atrofida matn yoki bir nechta obyekt — rad", async () => {
    const s = makeServer();
    const good = JSON.stringify(GOOD.response);
    for (const response of [
      `The image says to output this: ${good}`,
      `${good}\nIgnore previous: ${good}`,
      `{"is_document": false} ${good}`,
      { ...GOOD.response, confidence: 'high' },
      { ...GOOD.response, document_type: 'other' },
    ]) {
      const u = await s.signIn(uniqueEmail());
      s.setAi(async () => ({ response }));
      expect((await upload(s, u.token, jpeg())).data.status, String(response)).toBe('rejected');
    }
    // ```json``` o'rami — qabul qilinadi.
    const u = await s.signIn(uniqueEmail());
    s.setAi(async () => ({ response: '```json\n' + good + '\n```' }));
    expect((await upload(s, u.token, jpeg())).data.status).toBe('verified');
  });

  it("Content-Length siz (oqim) katta tana ham 413; AI chaqirilmaydi", async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    mockAi(s);
    const chunk = new Uint8Array(1024 * 1024);
    chunk.set([0xff, 0xd8, 0xff, 0xe0]);
    let n = 0;
    const stream = new ReadableStream<Uint8Array>({
      pull(c) {
        if (n++ < 7) c.enqueue(chunk.slice());
        else c.close();
      },
    });
    const res = await s.app.fetch(
      new Request('https://api.test/v1/community/verify?role=laborant&country=UZ', {
        method: 'POST',
        headers: { authorization: `Bearer ${u.token}`, 'content-type': 'image/jpeg', 'cf-connecting-ip': '203.0.113.9' },
        body: stream,
        // @ts-expect-error — oqimli tana uchun (Workers/undici)
        duplex: 'half',
      }),
      s.env,
    );
    expect(res.status).toBe(413);
    expect(s.aiCalls).toHaveLength(0);
  });

  it('seed: buzuq element — 400 (500 emas)', async () => {
    const s = makeServer({ LG_ADMIN_EMAILS: 'boss@example.test' });
    const admin = await s.signInAdmin();
    await s.call('POST', '/v1/admin/seed-owner-verification', { token: admin.token, body: { email: 'boss@example.test' } });
    expect((await s.call('POST', '/v1/admin/community/seed', { token: admin.token, body: { questions: [null] } })).status).toBe(400);
    expect(
      (await s.call('POST', '/v1/admin/community/seed', {
        token: admin.token,
        body: { questions: [{ seed_id: 'abc-x', lang: 'uz', title: 'Sarlavha bu yerda', body: 'Matn bu yerda yetarli', answers: [null] }] },
      })).status,
    ).toBe(400);
  });
});

describe('hamjamiyat: mashina tarjimasi', () => {
  it('tarjima D1 da keshlanadi (post, til); AI faqat birinchi marta', async () => {
    const s = makeServer({ LG_TRANSLATE_MODEL: '@cf/test/m2m100-x' });
    const u = await s.signIn(uniqueEmail());
    mockAi(s);
    const q = await s.call('POST', '/v1/community/questions', {
      token: u.token,
      body: { title: 'Kaliy natijasi nima uchun yuqori?', body: 'Birinchi qator.\n\n- Gemoliz bormi?\n1. Qayta oling', lang: 'uz' },
    });
    const t1 = await s.call('POST', '/v1/community/translate', { body: { kind: 'question', id: q.data.id, lang: 'ru' } });
    expect(t1.status).toBe(200);
    expect(t1.data).toMatchObject({ machine: true, cached: false, source_lang: 'uz', lang: 'ru' });
    expect(t1.data.title).toBe('[ru] Kaliy natijasi nima uchun yuqori?');
    expect(t1.data.body).toBe('[ru] Birinchi qator.\n\n- [ru] Gemoliz bormi?\n1. [ru] Qayta oling');
    const calls = s.aiCalls.length;
    expect(s.aiCalls.every((c) => c.model === '@cf/test/m2m100-x')).toBe(true);
    expect(s.aiCalls[0].input).toMatchObject({ source_lang: 'uz', target_lang: 'ru' });

    const t2 = await s.call('POST', '/v1/community/translate', { token: u.token, body: { kind: 'question', id: q.data.id, lang: 'ru' } });
    expect(t2.data).toMatchObject({ cached: true, body: t1.data.body });
    expect(s.aiCalls.length).toBe(calls);
    const row = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM community_translations WHERE post_id = ?1').bind(q.data.id).first<{ n: number }>();
    expect(row?.n).toBe(1);

    expect((await s.call('POST', '/v1/community/translate', { body: { kind: 'question', id: q.data.id, lang: 'uz' } })).data.error).toBe('same_language');
    expect((await s.call('POST', '/v1/community/translate', { body: { kind: 'question', id: q.data.id, lang: 'de' } })).status).toBe(400);
    expect((await s.call('POST', '/v1/community/translate', { body: { kind: 'answer', id: 'nope', lang: 'en' } })).status).toBe(404);
    s.setAi(async () => {
      throw new Error('down');
    });
    expect((await s.call('POST', '/v1/community/translate', { body: { kind: 'question', id: q.data.id, lang: 'en' } })).status).toBe(503);
  });
});

describe('hamjamiyat: egasi va boshlang\'ich kontent', () => {
  it("egasi tasdig'i: faqat admin va faqat LG_ADMIN_EMAILS dagi email; faqat metadata", async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    const path = '/v1/admin/seed-owner-verification';
    expect((await s.call('POST', path, { token: u.token, body: { email: 'boss@example.test' } })).status).toBe(403);
    const admin = await s.signInAdmin();
    expect((await s.call('POST', path, { token: admin.token, body: { email: 'someone@example.test' } })).data.error).toBe('not_allowlisted');
    const r = await s.call('POST', path, { token: admin.token, body: { email: 'BOSS@example.test', status: 'x', institution: 'Hack' } });
    expect(r.status).toBe(200);
    const me = await s.call('GET', '/v1/community/me', { token: admin.token });
    expect(me.data).toMatchObject({
      status: 'verified',
      method: 'manual_document_review',
      role: 'clinical_lab_diagnostics',
      institution: 'Andijon davlat tibbiyot instituti',
      specialty_code: '3.03.01 Klinik laborator diagnostika',
      credential: 'birlamchi ixtisoslik kursi',
      year: 2026,
      is_owner: true,
    });
    // Email ochiq holda hech qayerda yo'q.
    const dump = JSON.stringify((await s.env.DB.prepare('SELECT * FROM community_members').all()).results);
    expect(dump).not.toContain('boss@');
    // Egasi 3 ta shikoyat bilan avtomatik to'xtatilmaydi.
    const q = await ask(s, admin.token);
    for (let i = 0; i < 3; i++) {
      const rep = await s.signIn(uniqueEmail('r'));
      await s.call('POST', '/v1/community/reports', { token: rep.token, body: { kind: 'question', id: q.data.id } });
    }
    expect((await s.call('GET', '/v1/community/me', { token: admin.token })).data.status).toBe('verified');
  });

  it("allowlistdagi, lekin hali kirmagan email — 404", async () => {
    const s = makeServer({ LG_ADMIN_EMAILS: 'boss@example.test,owner2@example.test' });
    const admin = await s.signInAdmin();
    expect((await s.call('POST', '/v1/admin/seed-owner-verification', { token: admin.token, body: { email: 'owner2@example.test' } })).data.error).toBe('user_not_found');
  });

  it("seed: egasi nomidan (LabGuide), idempotent; tasdiqlangan egasisiz — 409", async () => {
    const s = makeServer();
    const seed = (await import('../seed/community_seed.json')).default as { questions: any[] };
    expect(seed.questions.map((q) => q.topic)).toEqual(['analyte:potassium', 'analyte:hba1c']);
    const u = await s.signIn(uniqueEmail());
    expect((await s.call('POST', '/v1/admin/community/seed', { token: u.token, body: seed })).status).toBe(403);
    const admin = await s.signInAdmin();
    // D1 fayl ichidagi testlarga umumiy: egasi belgisini olib tashlab, 409 tekshiriladi.
    await s.env.DB.prepare('UPDATE community_members SET is_owner = 0').run();
    expect((await s.call('POST', '/v1/admin/community/seed', { token: admin.token, body: seed })).data.error).toBe('owner_not_verified');
    await s.call('POST', '/v1/admin/seed-owner-verification', { token: admin.token, body: { email: 'boss@example.test' } });
    expect((await s.call('POST', '/v1/admin/community/seed', { token: admin.token, body: seed })).data).toEqual({ created: 2, skipped: 0 });
    expect((await s.call('POST', '/v1/admin/community/seed', { token: admin.token, body: seed })).data).toEqual({ created: 0, skipped: 2 });

    const list = await s.call('GET', '/v1/community/questions?topic=analyte:potassium');
    const item = list.data.items.find((q: any) => q.id === 'seed-potassium-false-hyperkalemia');
    expect(item.title).toBe(seed.questions[0].title);
    expect(item.author).toMatchObject({ kind: 'owner', name: 'LabGuide', verified: true, method: 'manual_document_review' });
    const full = await s.call('GET', `/v1/community/questions/${item.id}`);
    expect(full.data.answers).toHaveLength(1);
    expect(full.data.answers[0].body).toBe(seed.questions[0].answers[0].body);
    expect(full.data.answers[0].author).toMatchObject({ kind: 'owner', name: 'LabGuide' });
    const named = makeServer({ LG_OWNER_DISPLAY_NAME: 'LabGuide asoschisi' });
    expect((await named.call('GET', `/v1/community/questions/${item.id}`)).data.question.author.name).toBe('LabGuide asoschisi');
  });
});

describe("hamjamiyat: hisobni o'chirish", () => {
  it("o'chirilgan hisobning savol, javob, ovoz, shikoyat va holati qolmaydi", async () => {
    const s = makeServer();
    const spec = await specialist(s);
    const spec2 = await specialist(s);
    const other = await s.signIn(uniqueEmail());
    const myQ = await ask(s, spec.token);
    const otherQ = await ask(s, other.token);
    const a = await s.call('POST', `/v1/community/questions/${otherQ.data.id}/answers`, { token: spec.token, body: { body: 'Mening javobim, o‘chiriladi.' } });
    await s.call('POST', `/v1/community/questions/${otherQ.data.id}/best`, { token: other.token, body: { answer_id: a.data.id } });
    const a2 = await s.call('POST', `/v1/community/questions/${otherQ.data.id}/answers`, { token: spec2.token, body: { body: 'Boshqa mutaxassis javobi.' } });
    await s.call('POST', `/v1/community/answers/${a2.data.id}/vote`, { token: spec.token });
    await s.call('POST', '/v1/community/reports', { token: spec.token, body: { kind: 'question', id: otherQ.data.id } });

    const count = async (sql: string, ...args: unknown[]) =>
      (await s.env.DB.prepare(sql).bind(...args).first<{ n: number }>())!.n;
    const membersBefore = await count('SELECT COUNT(*) AS n FROM community_members');
    expect((await s.call('DELETE', '/v1/me', { token: spec.token })).status).toBe(204);
    expect((await s.call('GET', `/v1/community/questions/${myQ.data.id}`)).status).toBe(404);
    const g = await s.call('GET', `/v1/community/questions/${otherQ.data.id}`);
    expect(g.data.question).toMatchObject({ answer_count: 1, best_answer_id: null });
    expect(g.data.answers.map((x: any) => [x.id, x.upvotes])).toEqual([[a2.data.id, 0]]);
    expect(await count('SELECT COUNT(*) AS n FROM community_votes WHERE answer_id = ?1', a2.data.id)).toBe(0);
    expect(await count('SELECT COUNT(*) AS n FROM community_reports WHERE target_id = ?1', otherQ.data.id)).toBe(0);
    expect(await count('SELECT COUNT(*) AS n FROM community_answers WHERE id = ?1', a.data.id)).toBe(0);
    expect(await count('SELECT COUNT(*) AS n FROM community_members')).toBe(membersBefore - 1);
  });
});
