// Mavzu testi: savollar tanlovi (faqat tekshirilgan, takrorlanmaydigan
// variantlar, urug' bilan deterministik), natija hisobi, qoralama va tarix,
// savol → slayd moslash.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

ToifaTestQuestion _toifa(
  String id, {
  KeyVerdict verdict = KeyVerdict.ok,
  bool unverified = false,
  List<String> options = const ['alfa', 'beta', 'gamma', 'delta'],
  Set<int> key = const {1},
  String? held,
  List<String> analytes = const [],
  String text = 'Savol matni',
}) => ToifaTestQuestion(
  id: id,
  number: 1,
  text: text,
  options: options,
  key: key,
  topic: 'anemias',
  keyCheck: KeyCheck(verdict: verdict, unverified: unverified),
  held: held,
  analytes: analytes,
);

PackExamQuestion _pack(
  String id, {
  bool refs = true,
  List<String> options = const ['bir', 'ikki', 'uch'],
  List<String> topics = const [],
  String prompt = 'Paket savoli',
}) {
  Map<String, String> t(String s) => {'uz': s, 'ru': '$s ru', 'en': '$s en'};
  return PackExamQuestion(
    QuizQuestion.fromJson({
      'id': id,
      'prompt': t(prompt),
      'options': [
        for (final o in options) {'text': t(o), 'explanation': t('izoh $o')},
      ],
      'correct_index': 0,
      'basis': t('asos'),
      'review_state': 'pending',
      'topic_ids': topics,
      'source_ids': refs ? ['who-2011'] : <String>[],
    }),
    topics,
  );
}

DeckEntry _deck({
  String id = 'dx',
  List<String> topics = const ['t1'],
  List<(String, int)> runs = const [],
}) => DeckEntry(
  id: id,
  kind: DeckKind.day,
  titles: const {'uz': 'Deck'},
  slideCounts: {'uz': runs.length + 1},
  languages: const ['uz'],
  runs: {
    'uz': [for (final (t, i) in runs) SlideRun(t, i, 1)],
  },
  keywords: '',
  topics: topics,
);

void main() {
  late Curriculum cur;
  late ContentPack pack;
  late ToifaBank bank;
  late DeckCatalog catalog;

  setUpAll(() {
    cur = Curriculum.parse(
      File('assets/curriculum/curriculum.json').readAsStringSync(),
    );
    pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
    bank = ToifaBank.fromJson(
      _json('assets/toifa/kdl_tests.json'),
      _json('assets/toifa/kdl_oral.json'),
    );
    catalog = DeckCatalog.parse(
      File('assets/lectures/index_v2.json').readAsStringSync(),
    );
  });

  group('tekshirilgan savol', () {
    test('toifa: faqat kaliti ok, tasdiqlangan, chiqarilmagan', () {
      expect(isVerifiedTopicQuestion(_toifa('a')), isTrue);
      expect(
        isVerifiedTopicQuestion(_toifa('b', verdict: KeyVerdict.disputed)),
        isFalse,
      );
      expect(
        isVerifiedTopicQuestion(_toifa('c', verdict: KeyVerdict.ambiguous)),
        isFalse,
      );
      expect(isVerifiedTopicQuestion(_toifa('d', unverified: true)), isFalse);
      expect(
        isVerifiedTopicQuestion(_toifa('e', held: 'tekshirilmoqda')),
        isFalse,
      );
      expect(isVerifiedTopicQuestion(_toifa('f', key: const {})), isFalse);
    });

    test('paket: manbasi bor savol; manbasiz — yo‘q', () {
      expect(isVerifiedTopicQuestion(_pack('p1')), isTrue);
      expect(isVerifiedTopicQuestion(_pack('p2', refs: false)), isFalse);
    });

    test('takrorlanadigan variantli savol testga qo‘yilmaydi', () {
      final dup = _toifa('g', options: const ['alfa', 'Alfa', 'beta', 'gamma']);
      expect(hasUniqueOptions(dup), isFalse);
      expect(isVerifiedTopicQuestion(dup), isFalse);
      expect(
        isVerifiedTopicQuestion(_pack('p3', options: const ['x', 'y', 'x'])),
        isFalse,
      );
    });

    test('haqiqiy bank: hovuzdagi har savol tekshirilgan va noyob', () {
      var total = 0;
      for (final t in cur.topics) {
        final pool = verifiedTopicQuestions(t, pack, bank);
        expect(pool.map((q) => q.id).toSet().length, pool.length, reason: t.id);
        for (final q in pool) {
          expect(isVerifiedTopicQuestion(q), isTrue, reason: q.id);
          expect(q.correct.length, 1);
          if (q case final ToifaTestQuestion tq) {
            expect(tq.keyCheck.verdict, KeyVerdict.ok, reason: q.id);
            expect(t.testCandidates, contains(q.id));
          } else {
            expect(q.refs, isNotEmpty, reason: q.id);
            expect(t.packQuizCandidates, contains(q.id));
          }
        }
        total += pool.length;
      }
      expect(total, greaterThan(500));
    });
  });

  group('deck hovuzi', () {
    test('deck — o‘z mavzulari (P va L) bo‘yicha takrorsiz birlashma', () {
      final d = catalog.byId('d013')!;
      final pool = deckQuestionPool(d, cur, pack, bank);
      final byTopic = {
        for (final t in d.topics)
          ...verifiedTopicQuestions(cur.topic(t)!, pack, bank).map((q) => q.id),
      };
      expect(pool.map((q) => q.id).toSet(), byTopic);
      expect(pool.length, byTopic.length);
      expect(deckTestState(d, pool), DeckTestState.ready);
    });

    test('savoli yo‘q mavzu — “tayyorlanmoqda”; protokol — yashirin', () {
      final d1 = catalog.byId('d001')!;
      expect(
        deckTestState(d1, deckQuestionPool(d1, cur, pack, bank)),
        DeckTestState.preparing,
      );
      for (final p in catalog.protocols) {
        expect(
          deckTestState(p, deckQuestionPool(p, cur, pack, bank)),
          DeckTestState.hidden,
          reason: p.id,
        );
      }
    });

    test('3 tadan kam savol — “tayyorlanmoqda”', () {
      final d = _deck();
      expect(
        deckTestState(d, [_pack('a'), _pack('b')]),
        DeckTestState.preparing,
      );
      expect(
        deckTestState(d, [_pack('a'), _pack('b'), _pack('c')]),
        DeckTestState.ready,
      );
    });
  });

  group('tanlov', () {
    final pool = [
      for (var i = 0; i < 25; i++) _pack('q${i.toString().padLeft(2, '0')}'),
    ];

    test('bir xil urug‘ — bir xil test (kirish tartibidan qat‘i nazar)', () {
      final a = drawTopicTest(pool, seed: 42).map((q) => q.id).toList();
      final b = drawTopicTest(
        pool.reversed.toList(),
        seed: 42,
      ).map((q) => q.id).toList();
      expect(a, b);
      expect(a.length, kTopicTestSize);
      expect(a.toSet().length, a.length);
      final c = drawTopicTest(pool, seed: 43).map((q) => q.id).toList();
      expect(c, isNot(a));
    });

    test('savol kam bo‘lsa — boricha', () {
      expect(drawTopicTest(pool.take(4).toList(), seed: 1).length, 4);
      expect(drawTopicTest(pool, seed: 1, count: 30).length, 25);
    });

    test('sessiya: rasmiy savolda variant tartibi saqlanadi, paketda — urug‘ bilan', () {
      final qs = [
        _toifa('t1'),
        _pack('p1'),
        _pack('p2', options: const ['a', 'b', 'c', 'd']),
      ];
      ExamSession build(int seed) => buildTopicTestSession(
        id: 's',
        questions: qs,
        seed: seed,
        startedAt: DateTime(2026, 10, 17),
        title: 'T',
      );
      final s = build(7);
      expect(s.items.map((i) => i.questionId), ['t1', 'p1', 'p2']);
      expect(s.items[0].order, [0, 1, 2, 3]);
      expect(s.items[0].correct, [1]);
      expect(build(7).items[2].order, s.items[2].order);
      expect(s.sourceId, TopicTestController.sourceId);
    });
  });

  group('natija', () {
    ExamSession session() => buildTopicTestSession(
      id: 'x',
      questions: [_toifa('t1'), _pack('p1'), _pack('p2'), _pack('p3')],
      seed: 3,
      startedAt: DateTime(2026, 10, 17, 9),
      title: 'T',
    );

    void answer(ExamSession s, int i, {required bool correct}) {
      s.goTo(i);
      final item = s.current;
      final want = correct
          ? item.correct.single
          : item.order.firstWhere((o) => !item.correct.contains(o));
      s.choose(item.order.indexOf(want));
    }

    test('ball, xatolar va foiz', () {
      final s = session();
      answer(s, 0, correct: true);
      answer(s, 1, correct: false);
      answer(s, 2, correct: true);
      expect(s.correctCount, 2);
      expect(s.wrongCount, 1);
      expect(s.unansweredCount, 1);
      expect(s.mistakeIndexes, [1, 3]);
      expect(s.percent, 50);
    });

    test(
      'eng yaxshi natija — foiz bo‘yicha, xatolar ustida ishlash kirmaydi',
      () {
        final at = DateTime(2026);
        expect(bestResult(const []), isNull);
        final best = bestResult([
          TopicTestResult(correct: 6, total: 10, at: at),
          TopicTestResult(correct: 8, total: 10, at: at),
          TopicTestResult(correct: 3, total: 3, at: at, rework: true),
          TopicTestResult(correct: 4, total: 5, at: at),
        ]);
        expect((best!.correct, best.total), (8, 10));
      },
    );

    test(
      'qoralama saqlanadi va qayta ochilganda davom etadi; yakun — tarixga',
      () async {
        final store = MemoryKeyValueStore();
        var now = DateTime(2026, 10, 17, 10);
        final c = TopicTestController(store, clock: () => now);
        final s = session();
        await c.start('d013', s);
        answer(s, 0, correct: true);
        s.goTo(1);
        await c.save('d013', s);
        // Ilova qayta ochildi.
        final c2 = TopicTestController(store, clock: () => now);
        final d = c2.draft('d013')!;
        expect(d.index, 1);
        expect(d.isAnswered(0), isTrue);
        expect(d.isCorrect(0), isTrue);
        // Boshqa deck testi bu qoralamaga tegmaydi.
        await c2.start('d014', session());
        expect(c2.draft('d013'), isNotNull);
        answer(d, 1, correct: false);
        answer(d, 2, correct: true);
        answer(d, 3, correct: true);
        now = now.add(const Duration(minutes: 5));
        final r = await c2.finish('d013');
        expect((r!.correct, r.total), (3, 4));
        expect(c2.draft('d013'), isNull);
        final c3 = TopicTestController(store, clock: () => now);
        expect(c3.last('d013')!.mistakeIndexes, [1]);
        expect(c3.history('d013').single.correct, 3);
        expect(c3.best('d013')!.total, 4);
        expect(c3.draft('d014'), isNotNull);
        expect(StoreKeys.all, contains(StoreKeys.topicTests));
      },
    );

    test('buzilgan yozuv ilovani yiqitmaydi', () {
      final store = MemoryKeyValueStore()
        ..setString(StoreKeys.topicTests, '{"drafts": {"a": 5}, "history": 3');
      final c = TopicTestController(store);
      expect(c.draft('a'), isNull);
    });
  });

  group('savol → slayd', () {
    final deck = _deck(
      runs: const [
        ('Dars maqsadi va rejasi', 1),
        ('Ferritin', 2),
        ('Ferritin', 3),
        ('Gemoglobin va eritrotsitlar', 4),
        ('Temir almashinuvi', 5),
        ('Manbalar', 6),
      ],
    );
    List<String> names(String id, String lang) => switch (id) {
      'ferritin' => ['Ferritin'],
      'hb' => ['Gemoglobin'],
      _ => const [],
    };

    test('analit nomi slayd sarlavhasida — o‘sha slayd', () {
      final q = _pack(
        'p',
        topics: const ['ferritin'],
        prompt: 'Zaxira ko‘rsatkichi',
      );
      expect(matchSlide(q, deck, 'uz', analyteNames: names), 2);
    });

    test('so‘zlar bo‘yicha (qo‘shimchalar bilan) moslik', () {
      final q = _toifa(
        't',
        text: 'Eritrotsitlarda gemoglobinning asosiy vazifasi:',
        options: const ['kislorod tashish', 'b', 'c', 'd'],
        key: const {0},
      );
      expect(matchSlide(q, deck, 'uz'), 4);
    });

    test('ishonchli moslik yo‘q yoki teng — null (deck boshi)', () {
      expect(
        matchSlide(_pack('n', prompt: 'Sterilizatsiya rejimi'), deck, 'uz'),
        isNull,
      );
      final tie = _toifa(
        'tie',
        text: 'Ferritin va temir',
        options: const ['x1', 'x2', 'x3', 'x4'],
      );
      expect(matchSlide(tie, deck, 'uz'), isNull);
      // Umumiy slaydlar (reja, manbalar) hech qachon tanlanmaydi.
      expect(
        matchSlide(_pack('m', prompt: 'Manbalar va dars rejasi'), deck, 'uz'),
        isNull,
      );
    });

    test('haqiqiy decklar: topilgan slayd indeksi deck ichida', () {
      var matched = 0;
      var total = 0;
      for (final d in catalog.decks) {
        for (final q in deckQuestionPool(d, cur, pack, bank)) {
          final i = matchSlide(
            q,
            d,
            'uz',
            analyteNames: packAnalyteNames(pack),
          );
          total++;
          if (i == null) continue;
          matched++;
          expect(
            i,
            inInclusiveRange(1, d.slides('uz') - 1),
            reason: '${d.id} ${q.id}',
          );
        }
      }
      expect(total, greaterThan(0));
      // Ko'pchilik savol biror slaydga bog'lanadi (qolgani — deck boshi).
      expect(matched / total, greaterThan(0.4));
    });
  });
}
