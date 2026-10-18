// Variantli test (D-66): "Har bir talabaga boshqa savollar".
import { describe, expect, it } from 'vitest';
import { drawVariant, sha256hex } from '../src/variants';
import { makeServer, uniqueEmail } from './helpers';
import vectors from './variant_vectors.json';

describe('variant tanlovi (ilova bilan umumiy vektorlar)', () => {
  it('SHA-256 hex', async () => {
    for (const v of vectors.sha256) expect(await sha256hex(v.input)).toBe(v.hex);
  });

  it("har vektor — kutilgan to'plam (Dart ham aynan shuni beradi)", async () => {
    for (const c of vectors.cases) {
      const got = await drawVariant(c.assignment_id, c.user_id, c.pool, c.pool_topics as (string | null)[] | null, c.count);
      expect(got, c.name).toEqual(c.expected);
    }
  });

  it("qattiq kodlangan nazorat (vektor fayli o'zgartirilsa ham)", async () => {
    const aid = '3f2b8c1e-5d4a-4e6f-9a7b-1c2d3e4f5a6b';
    const pool = Array.from({ length: 10 }, (_, i) => `q${String(i + 1).padStart(2, '0')}`);
    expect(await drawVariant(aid, 'u-alpha', pool, null, 3)).toEqual(['q10', 'q03', 'q08']);
    expect(await sha256hex('abc')).toBe('ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  });

  it('deterministik, takrorsiz, hovuzdan; talabalar orasida farq qiladi', async () => {
    const pool = Array.from({ length: 40 }, (_, i) => `p${i}`);
    const sets = new Set<string>();
    for (let u = 0; u < 20; u++) {
      const a = await drawVariant('A', `user-${u}`, pool, null, 10);
      expect(await drawVariant('A', `user-${u}`, pool, null, 10)).toEqual(a);
      expect(new Set(a).size).toBe(10);
      expect(a.every((q) => pool.includes(q))).toBe(true);
      sets.add([...a].sort().join(','));
    }
    expect(sets.size).toBeGreaterThan(15);
  });

  it("mavzular bo'yicha muvozanat: har mavzudan ±1", async () => {
    const pool = Array.from({ length: 30 }, (_, i) => `p${i}`);
    const topics = pool.map((_, i) => (i < 18 ? 'big' : i < 26 ? 'mid' : 'small'));
    for (let u = 0; u < 10; u++) {
      const got = await drawVariant('B', `u${u}`, pool, topics, 9);
      const n = (t: string) => got.filter((q) => topics[pool.indexOf(q)] === t).length;
      expect([n('big'), n('mid'), n('small')]).toEqual([3, 3, 3]);
    }
    // 4 savol 3 mavzuga: bittasi 2 ta oladi, qolganlari 1 tadan.
    const got = await drawVariant('B', 'x', pool, topics, 4);
    const counts = ['big', 'mid', 'small'].map((t) => got.filter((q) => topics[pool.indexOf(q)] === t).length).sort();
    expect(counts).toEqual([1, 1, 2]);
  });
});

const POOL = Array.from({ length: 12 }, (_, i) => `vq${String(i + 1).padStart(2, '0')}`);
const KEY = POOL.map((_, i) => i % 4);
const TOPICS = POOL.map((_, i) => (i < 6 ? 'hem-1' : i < 10 ? 'hem-2' : 'hem-3'));
const keyOf = (q: string) => KEY[POOL.indexOf(q)];

async function variantClass(extra: Record<string, unknown> = {}) {
  const s = makeServer();
  const t = await s.signInTeacher(uniqueEmail('vt'));
  const g = (await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Variant guruh' } })).data;
  const st = [];
  for (const n of ['v1', 'v2', 'v3']) {
    const u = await s.signIn(uniqueEmail(n));
    expect((await s.call('POST', '/v1/groups/join', { token: u.token, body: { code: g.join_code } })).status).toBe(201);
    st.push(u);
  }
  const r = await s.call('POST', `/v1/groups/${g.id}/assignments`, {
    token: t.token,
    body: { title: 'Variantli test', question_ids: POOL, correct_indexes: KEY, per_student: 5, pool_topics: TOPICS, ...extra },
  });
  expect(r.status).toBe(201);
  return { s, t, g, st, aid: r.data.id as string };
}

describe('variantli topshiriq (0012: per_student, pool_topics)', () => {
  it("saqlanadi va ro'yxatda qaytadi; oddiy topshiriqda null", async () => {
    const { s, t, g, st } = await variantClass();
    const list = (await s.call('GET', `/v1/groups/${g.id}/assignments`, { token: st[0].token })).data;
    expect(list[0]).toMatchObject({ per_student: 5, question_ids: POOL, pool_topics: TOPICS });
    const plain = await s.call('POST', `/v1/groups/${g.id}/assignments`, {
      token: t.token,
      body: { title: 'Oddiy', question_ids: ['a1', 'a2'], correct_indexes: [0, 1] },
    });
    const all = (await s.call('GET', `/v1/groups/${g.id}/assignments`, { token: t.token })).data;
    expect(all.find((a: any) => a.id === plain.data.id)).toMatchObject({ per_student: null, pool_topics: null });
  });

  it("noto'g'ri per_student / hovuz / pool_topics — 400", async () => {
    const { s, t, g } = await variantClass();
    const base = { title: 'Variantli', question_ids: POOL, correct_indexes: KEY };
    const bad: [Record<string, unknown>, string][] = [
      [{ per_student: 0 }, 'invalid_per_student'],
      [{ per_student: 51 }, 'invalid_per_student'],
      [{ per_student: 2.5 }, 'invalid_per_student'],
      [{ per_student: 7 }, 'invalid_per_student'], // hovuz 12 < 2 × 7
      [{ per_student: 3, pool_topics: ['a'] }, 'invalid_pool_topics'],
      [{ per_student: 3, pool_topics: POOL.map(() => 'bad topic') }, 'invalid_pool_topics'],
      [{ per_student: 3, question_ids: [...POOL.slice(0, 11), 'vq01'] }, 'invalid_questions'],
      [
        {
          per_student: 3,
          question_ids: Array.from({ length: 61 }, (_, i) => `x${i}`),
          correct_indexes: Array.from({ length: 61 }, () => 0),
        },
        'invalid_questions',
      ],
    ];
    for (const [patch, code] of bad) {
      const r = await s.call('POST', `/v1/groups/${g.id}/assignments`, { token: t.token, body: { ...base, ...patch } });
      expect(r.status, JSON.stringify(patch)).toBe(400);
      expect(r.data.error, JSON.stringify(patch)).toBe(code);
    }
    // 60 talik hovuz — ruxsat (oddiy testda 50 dan ortiq emas).
    const big = Array.from({ length: 60 }, (_, i) => `x${i}`);
    const ok = await s.call('POST', `/v1/groups/${g.id}/assignments`, {
      token: t.token,
      body: { ...base, question_ids: big, correct_indexes: big.map(() => 1), per_student: 30 },
    });
    expect(ok.status).toBe(201);
    const plain = await s.call('POST', `/v1/groups/${g.id}/assignments`, {
      token: t.token,
      body: { ...base, question_ids: big, correct_indexes: big.map(() => 1) },
    });
    expect(plain.status).toBe(400);
  });

  it("start har talabaga o'z to'plamini beradi (server = drawVariant)", async () => {
    const { s, st, aid } = await variantClass();
    const sets: string[][] = [];
    for (const u of st) {
      const r = await s.call('POST', `/v1/assignments/${aid}/start`, { token: u.token });
      expect(r.status).toBe(200);
      expect(r.data.question_ids).toEqual(await drawVariant(aid, u.userId, POOL, TOPICS, 5));
      sets.push(r.data.question_ids);
    }
    expect(new Set(sets.map((x) => [...x].sort().join())).size).toBeGreaterThan(1);
  });

  it("topshirish: begona/takror/yetishmagan id rad etiladi; o'z to'plami (istalgan tartibda) qabul", async () => {
    const { s, st, aid } = await variantClass();
    const u = st[0];
    const mine = await drawVariant(aid, u.userId, POOL, TOPICS, 5);
    const foreign = POOL.find((q) => !mine.includes(q))!;
    await s.call('POST', `/v1/assignments/${aid}/start`, { token: u.token });
    const tries: unknown[] = [
      undefined,
      [...mine.slice(0, 4), foreign],
      [...mine.slice(0, 4), mine[0]],
      mine.slice(0, 4),
      [...mine, foreign],
      [1, 2, 3, 4, 5],
    ];
    for (const ids of tries) {
      const r = await s.call('POST', `/v1/assignments/${aid}/submit`, {
        token: u.token,
        body: { answers: [0, 0, 0, 0, 0].slice(0, Array.isArray(ids) ? Math.min(ids.length, 5) : 5), question_ids: ids },
      });
      expect(r.status, JSON.stringify(ids)).toBe(400);
    }
    // Hovuz uzunligidagi javoblar (oddiy test kabi) — rad.
    expect(
      (await s.call('POST', `/v1/assignments/${aid}/submit`, { token: u.token, body: { answers: KEY, question_ids: POOL } })).status,
    ).toBe(400);
    // Teskari tartibda: 1-chi (teskari) savoldan boshqa hammasi to'g'ri.
    const rev = [...mine].reverse();
    const answers = rev.map((q, i) => (i === 0 ? (keyOf(q) + 1) % 4 : keyOf(q)));
    const ok = await s.call('POST', `/v1/assignments/${aid}/submit`, { token: u.token, body: { answers, question_ids: rev } });
    expect(ok.status).toBe(201);
    expect(ok.data).toMatchObject({ score: 4, total: 5, question_ids: mine });
    // Saqlangan tartib — tanlov tartibi (javoblar shunga moslab qayta tartiblangan).
    expect(ok.data.answers).toEqual([...answers].reverse());
    expect(ok.data.correct).toEqual([true, true, true, true, false]);
  });

  it("ustoz natijalari: har talaba o'z to'plami bilan; savol bo'yicha — kimga tushgan bo'lsa", async () => {
    const { s, t, g, st, aid } = await variantClass();
    const sets: Record<string, string[]> = {};
    for (const [i, u] of st.entries()) {
      const mine = await drawVariant(aid, u.userId, POOL, TOPICS, 5);
      sets[u.userId] = mine;
      await s.call('POST', `/v1/assignments/${aid}/start`, { token: u.token });
      // 1-talaba — hammasi to'g'ri, 2-chi — hammasi xato, 3-chi — boshlagan, topshirmagan.
      if (i === 2) continue;
      const answers = mine.map((q) => (i === 0 ? keyOf(q) : (keyOf(q) + 1) % 4));
      expect((await s.call('POST', `/v1/assignments/${aid}/submit`, { token: u.token, body: { answers, question_ids: mine } })).status).toBe(201);
    }
    const subs = (await s.call('GET', `/v1/assignments/${aid}/submissions`, { token: t.token })).data;
    expect(subs).toHaveLength(2);
    for (const x of subs) {
      expect(x.question_ids).toEqual(sets[x.user_id]);
      expect(x.total).toBe(5);
    }
    expect(subs.map((x: any) => x.score).sort()).toEqual([0, 5]);
    const gsubs = (await s.call('GET', `/v1/groups/${g.id}/submissions`, { token: t.token })).data;
    expect(gsubs.map((x: any) => x.question_ids)).toEqual(subs.map((x: any) => x.question_ids));
    // Jonli holat (katta ekran): uchalasi ham boshlagan.
    expect((await s.call('GET', `/v1/assignments/${aid}/progress`, { token: t.token })).data).toHaveLength(3);
    // Kalit — butun hovuz bo'yicha (ilova har savolga hovuz indeksidan oladi).
    expect((await s.call('GET', `/v1/assignments/${aid}/key`, { token: t.token })).data.correct_indexes).toEqual(KEY);
    // Savol bo'yicha yig'ma (ilovadagi kabi): tushganlar va xatolar.
    const tally = new Map<string, { got: number; wrong: number }>();
    for (const x of subs) {
      x.question_ids.forEach((q: string, j: number) => {
        const e = tally.get(q) ?? { got: 0, wrong: 0 };
        e.got++;
        if (!x.correct[j]) e.wrong++;
        tally.set(q, e);
      });
    }
    expect([...tally.values()].reduce((n, e) => n + e.got, 0)).toBe(10);
    for (const [q, e] of tally) {
      const holders = subs.filter((x: any) => x.question_ids.includes(q));
      expect(e.got).toBe(holders.length);
      expect(e.wrong).toBe(holders.filter((x: any) => x.score === 0).length);
    }
  });

  it("after_due: talaba muddatgacha natijani ko'rmaydi, to'plami esa ko'rinadi", async () => {
    // Server soati har makeServer da 2 soat oldinga siljiydi — uzoq muddat.
    const due = new Date(Date.UTC(2026, 9, 10) + 120 * 86400_000).toISOString();
    const { s, st, aid } = await variantClass({ reveal: 'after_due', due_at: due });
    const u = st[1];
    const mine = (await s.call('POST', `/v1/assignments/${aid}/start`, { token: u.token })).data.question_ids;
    const r = await s.call('POST', `/v1/assignments/${aid}/submit`, {
      token: u.token,
      body: { answers: mine.map(keyOf), question_ids: mine },
    });
    expect(r.data).toMatchObject({ score: 5, correct: null, question_ids: mine });
    const own = (await s.call('GET', `/v1/assignments/${aid}/submissions`, { token: u.token })).data;
    expect(own[0]).toMatchObject({ correct: null, question_ids: mine });
  });

  it('jadvaldagi mavzu testi variantli bo\'la olmaydi', async () => {
    const { s, t, g } = await variantClass();
    const r = await s.call('POST', `/v1/groups/${g.id}/topics/hem-1/test`, {
      token: t.token,
      body: { title: 'Mavzu testi', question_ids: POOL, correct_indexes: KEY, per_student: 5 },
    });
    expect(r.status).toBe(400);
    expect(r.data.error).toBe('invalid_per_student');
  });

  it('oddiy test: question_ids yuborilsa ham e\'tiborsiz (eski oqim)', async () => {
    const { s, t, g, st } = await variantClass();
    const r = await s.call('POST', `/v1/groups/${g.id}/assignments`, {
      token: t.token,
      body: { title: 'Oddiy', question_ids: ['a1', 'a2'], correct_indexes: [0, 1] },
    });
    await s.call('POST', `/v1/assignments/${r.data.id}/start`, { token: st[0].token });
    const sub = await s.call('POST', `/v1/assignments/${r.data.id}/submit`, {
      token: st[0].token,
      body: { answers: [0, 1], question_ids: ['a1', 'a2'] },
    });
    expect(sub.data).toMatchObject({ score: 2, total: 2, question_ids: null });
  });
});
