// Qorovul (guard) testlari: o'quv imkoniyatlari.
//
// Toifa formatlari (D-60), ma'ruza taqdimotlari (D-59, D-65), mavzu testi
// qamrovi (har dekali mavzuda ≥ 10 tekshirilgan savol). Jadval: docs/GUARDS.md.
//
// Taqdimotlar yoki o'quv dasturi o'zgarsa (masalan, yangi modul decklari),
// bu testlar faqat "kamaymasin / buzilmasin" deb tekshiradi: son ko'paysa
// o'tadi; yangi dekali mavzuda 10 tadan kam savol bo'lsa — yiqiladi
// (yoki savollar qo'shiladi, yoki istisno sababi bilan shu yerga yoziladi).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_canvas.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/features/toifa/toifa_daily.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

/// 2026-10-18 holati (kamaymasligi kerak).
const _minDayDecks = 98;
const _minProtocolDecks = 27;
const _minDeckFiles = 372;

/// Mavzu testi 10 savoldan kam bo'lishi mumkin bo'lgan decklar — sababi bilan
/// (docs/TOPIC_TEST_COVERAGE.md).
const _topicTestExceptions = {
  // 1-mavzu: muallif (domla) decki; mavzular `test_gap: true`, rasmiy
  // toifa bankida shu mavzuga tekshirilgan savol yo'q — "savollar
  // tayyorlanmoqda" ko'rsatiladi.
  'd001',
};

void main() {
  group('Toifa (D-60)', () {
    test('rasmiy formatlar: test 50 savol, bilet 5 savol', () {
      expect(ToifaFormat.testSize, 50);
      expect(ToifaFormat.ticketSize, 5);
      expect(ToifaGoal.defaultQuestions, 50);
      expect(ToifaGoal.tickets, 1);
      expect(ToifaGoal.options, [20, 50, 100]);
    });

    test('mashq rejimi bor: har javobdan keyin darhol to‘g‘ri/xato', () {
      expect(ToifaTestMode.values.map((m) => m.name), ['exam', 'practice']);
      expect(ToifaTestMode.tryParse('practice'), ToifaTestMode.practice);
      expect(ToifaTestMode.tryParse(null), ToifaTestMode.exam);
      final d = ToifaDrill(
        id: 'g',
        ids: const ['a', 'b'],
        keys: const [1, 2],
        startedAt: DateTime(2026, 10, 18),
      );
      d.answers[0] = 0; // xato javob — darhol aniqlanadi
      expect(d.isAnswered(0), isTrue);
      expect(d.isCorrect(0), isFalse);
      d.answers[1] = 2;
      expect(d.isCorrect(1), isTrue);
      expect(d.wrongIndexes, [0]);
    });
  });

  group('Ma’ruza taqdimotlari (D-59, D-65)', () {
    final catalog = DeckCatalog.parse(
      File('assets/lectures/index_v2.json').readAsStringSync(),
    );

    test('16:9 kanvas — 1280×720', () {
      expect(SlideCanvasMetrics.width, 1280);
      expect(SlideCanvasMetrics.height, 720);
      expect(SlideCanvasMetrics.width / SlideCanvasMetrics.height, 16 / 9);
    });

    test('decklar soni kamaymaydi (98 kun + 27 protokol)', () {
      expect(
        catalog.decks.where((d) => d.kind == DeckKind.day).length,
        greaterThanOrEqualTo(_minDayDecks),
      );
      expect(
        catalog.decks.where((d) => d.kind == DeckKind.protocol).length,
        greaterThanOrEqualTo(_minProtocolDecks),
      );
      final ids = [for (final d in catalog.decks) d.id];
      expect(ids.toSet().length, ids.length);
    });

    test('har deck fayli status: sourced (qoralama emas)', () {
      final files = Directory('assets/lectures/decks')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();
      expect(files.length, greaterThanOrEqualTo(_minDeckFiles));
      for (final f in files) {
        final j = _json(f.path);
        expect(j['status'], 'sourced', reason: f.path);
        expect(LectureDeck.fromJson(j).draft, isFalse, reason: f.path);
      }
      // Katalogdagi har deck/til fayli mavjud.
      for (final d in catalog.decks) {
        for (final lang in d.languages) {
          expect(File(d.path(lang)).existsSync(), isTrue, reason: d.path(lang));
        }
      }
    });

    test(
      'to‘liq ekran: gorizontal holat so‘rovi (uch tilda) va eslab qolish',
      () {
        for (final lang in ['uz', 'ru', 'en']) {
          final arb = _json('lib/l10n/app_$lang.arb');
          for (final k in [
            'lectureRotateTitle',
            'lectureRotateBody',
            'lectureOrientationAsk',
            'lectureOrientationLandscape',
            'lectureOrientationKeep',
          ]) {
            expect(arb[k], isA<String>(), reason: '$lang $k');
          }
        }
        final present = File('lib/features/classroom/lecture_present.dart')
            .readAsStringSync();
        expect(present, contains("ValueKey('lecture-rotate-dialog')"));
        expect(present, contains('l.lectureRotateTitle'));
        expect(
          File('lib/core/storage/kv_store.dart').readAsStringSync(),
          contains("lectureOrientation = 'lecture.orientation'"),
        );
      },
    );
  });

  group('mavzu testi qamrovi', () {
    final cur = Curriculum.parse(
      File('assets/curriculum/curriculum.json').readAsStringSync(),
    );
    final pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
    final bank = ToifaBank.fromJson(
      _json('assets/toifa/kdl_tests.json'),
      _json('assets/toifa/kdl_oral.json'),
    );
    final catalog = DeckCatalog.parse(
      File('assets/lectures/index_v2.json').readAsStringSync(),
    );

    test('har dekali mavzu: ≥ $kTopicTestSize ta tekshirilgan savol '
        '(hujjatlangan istisnolardan tashqari)', () {
      expect(kTopicTestSize, 10);
      final low = <String>[];
      for (final t in cur.topics) {
        final deck = catalog.byTopic(t.id);
        if (deck == null || _topicTestExceptions.contains(deck.id)) continue;
        final n = verifiedTopicQuestions(t, pack, bank).length;
        if (n < kTopicTestSize) low.add('${t.id} (${deck.id}): $n');
      }
      expect(low, isEmpty);
    });

    test('kunlik decklarning test hovuzi ≥ 10; protokollar mavzusiz '
        '(test tugmasi yo‘q)', () {
      for (final d in catalog.decks) {
        if (d.kind == DeckKind.protocol) {
          expect(d.topics, isEmpty, reason: d.id);
          expect(
            deckTestState(d, deckQuestionPool(d, cur, pack, bank)),
            DeckTestState.hidden,
            reason: d.id,
          );
          continue;
        }
        if (_topicTestExceptions.contains(d.id)) continue;
        expect(
          deckQuestionPool(d, cur, pack, bank).length,
          greaterThanOrEqualTo(kTopicTestSize),
          reason: d.id,
        );
      }
    });

    test('istisnolar hali haqiqiy (eskirgan istisno qolmasin)', () {
      for (final id in _topicTestExceptions) {
        final d = catalog.byId(id);
        expect(d, isNotNull, reason: id);
        expect(
          deckQuestionPool(d!, cur, pack, bank).length,
          lessThan(kTopicTestSize),
          reason: '$id endi to‘liq — istisnoni olib tashlang',
        );
      }
    });

    test('deck matnidan olingan savollar kuzatiladi (derived_from)', () {
      final derivedIds = {
        for (final t in cur.topics) ...t.derivedQuizCandidates,
      };
      expect(derivedIds.length, greaterThanOrEqualTo(235));
      final raw = _json('assets/content/core/pack.json');
      final quiz = [
        for (final q in (raw['quiz']! as List).cast<Map<String, Object?>>())
          if (derivedIds.contains(q['id'])) q,
      ];
      expect(quiz.length, derivedIds.length);
      for (final q in quiz) {
        expect(q['id'], startsWith('drv-'));
        expect(q['provenance'], 'derived', reason: '${q['id']}');
        final from = q['derived_from'];
        expect(from, isA<Map<String, Object?>>(), reason: '${q['id']}');
        expect((from! as Map)['deck'], isA<String>(), reason: '${q['id']}');
      }
    });
  });
}
