// Haqiqiy decklar (ilova asset'lari) bilan ustoz–talaba testi: HAR BIR tayyor
// mavzu testi uchun ilova yuboradigan savol id lari, kalit, sarlavha va
// mavzular server tomonidan qabul qilinadi; server balli ilova kalitiga mos;
// variant tanlovi Dart bilan bir xil (umumiy vektor juftlari, real hovuzlar).
//
// Fixture'ni Dart qorovuli yozadi va tekshiradi:
//   test/guards/classroom_real_assets_guard_test.dart
// (LG_WRITE_FIXTURES=1 flutter test ... — asset o'zgarganda).
import { describe, expect, it } from 'vitest';
import { drawVariant } from '../src/variants';
import { makeServer, uniqueEmail } from './helpers';
import fixture from './real_deck_assignments.json';

interface Deck {
  deck_id: string;
  day_id: string;
  title: string;
  question_ids: string[];
  correct_indexes: number[];
  option_counts: number[];
  pool_topics: (string | null)[];
  per_student: number;
  draws: { assignment_id: string; user_id: string; expected: string[] }[];
}

const decks = fixture.decks as Deck[];

describe('haqiqiy decklar: fixture', () => {
  it("142+ tayyor deck; kalit variantlar oralig'ida", () => {
    expect(decks.length).toBeGreaterThanOrEqual(142);
    for (const d of decks) {
      expect(d.question_ids.length, d.deck_id).toBe(d.correct_indexes.length);
      d.correct_indexes.forEach((k, i) => {
        expect(k, `${d.deck_id}/${d.question_ids[i]}`).toBeGreaterThanOrEqual(0);
        expect(k, `${d.deck_id}/${d.question_ids[i]}`).toBeLessThan(d.option_counts[i]);
      });
    }
  });

  it('variant tanlovi: Worker = Dart (real hovuzlar, umumiy vektor juftlari)', async () => {
    for (const d of decks) {
      for (const v of d.draws) {
        const got = await drawVariant(v.assignment_id, v.user_id, d.question_ids, d.pool_topics, d.per_student);
        expect(got, `${d.deck_id} ${v.user_id}`).toEqual(v.expected);
      }
    }
  });
});

describe('haqiqiy decklar: server orqali', () => {
  it('har deck: oddiy va variantli topshiriq qabul qilinadi; to‘g‘ri javob — to‘liq ball, xato — 0', async () => {
    const s = makeServer();
    const t = await s.signInTeacher(uniqueEmail('real-t'));
    const g = (await s.call('POST', '/v1/groups', { token: t.token, body: { name: 'Haqiqiy decklar' } })).data;
    const good = await s.signIn(uniqueEmail('real-a'));
    const bad = await s.signIn(uniqueEmail('real-b'));
    for (const u of [good, bad]) {
      expect((await s.call('POST', '/v1/groups/join', { token: u.token, body: { code: g.join_code } })).status).toBe(201);
    }
    const keyOf = (d: Deck, q: string) => d.correct_indexes[d.question_ids.indexOf(q)];
    const wrongOf = (d: Deck, q: string) => {
      const i = d.question_ids.indexOf(q);
      return (d.correct_indexes[i] + 1) % d.option_counts[i];
    };
    for (const d of decks) {
      for (const variant of [false, true]) {
        // Oddiy: ilova ≤ 50 savol yuboradi (hovuzlar undan kichik).
        const ids = variant ? d.question_ids : d.question_ids.slice(0, 50);
        const r = await s.call('POST', `/v1/groups/${g.id}/assignments`, {
          token: t.token,
          body: {
            title: d.title,
            question_ids: ids,
            correct_indexes: ids.map((q) => keyOf(d, q)),
            day_id: d.day_id,
            deck_id: d.deck_id,
            reveal: 'now',
            ...(variant ? { per_student: d.per_student, pool_topics: d.pool_topics } : {}),
          },
        });
        expect(r.status, `${d.deck_id} ${variant} ${JSON.stringify(r.data)}`).toBe(201);
        const aid = r.data.id as string;
        for (const [u, right] of [
          [good, true],
          [bad, false],
        ] as const) {
          const st = await s.call('POST', `/v1/assignments/${aid}/start`, { token: u.token });
          expect(st.status, d.deck_id).toBe(200);
          const mine: string[] = variant ? st.data.question_ids : ids;
          if (variant) {
            expect(mine).toEqual(await drawVariant(aid, u.userId, d.question_ids, d.pool_topics, d.per_student));
            expect(mine.length).toBe(d.per_student);
          } else {
            expect(st.data.question_ids).toBeNull();
          }
          // Ilova javoblarni teskari tartibda yuborsa ham (variantda id bilan) ball to'g'ri.
          const order = variant ? [...mine].reverse() : mine;
          const sub = await s.call('POST', `/v1/assignments/${aid}/submit`, {
            token: u.token,
            body: {
              answers: order.map((q) => (right ? keyOf(d, q) : wrongOf(d, q))),
              ...(variant ? { question_ids: order } : {}),
            },
          });
          expect(sub.status, `${d.deck_id} ${JSON.stringify(sub.data)}`).toBe(201);
          expect(sub.data.total, d.deck_id).toBe(mine.length);
          expect(sub.data.score, `${d.deck_id} ${variant} ${right}`).toBe(right ? mine.length : 0);
        }
        // Ustoz kaliti — ilova yuborganining o'zi.
        const key = await s.call('GET', `/v1/assignments/${aid}/key`, { token: t.token });
        expect(key.data.correct_indexes).toEqual(ids.map((q) => keyOf(d, q)));
      }
    }
  }, 120_000);
});
