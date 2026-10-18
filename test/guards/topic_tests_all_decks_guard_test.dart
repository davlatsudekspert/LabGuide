// Qorovul: mavzu testi (mustaqil mashq) — HAQIQIY asset'lar bilan, HAR BIR
// tayyor deck va HAR BIR savol bo'yicha (namuna emas).
//
// 2026-10-18 saboq: soxta paketli widget testlar deck matnidan olingan
// (derived) savollar indeksga kirmay qolganini ushlamagan — iPhone'da
// “Bu savol joriy kontent to'plamida yo'q” chiqqan. Shuning uchun bu yerda
// faqat ilova bilan birga keladigan fayllar o'qiladi:
//   assets/content/core/pack.json, assets/curriculum/curriculum.json,
//   assets/toifa/kdl_tests.json + kdl_oral.json, assets/lectures/index_v2.json.
//
// Ilova qiladigan yo'l aynan takrorlanadi: deckQuestionPool → drawTopicTest
// → buildTopicTestSession; savol ekranda topicQuestion() orqali topiladi —
// toifa banki yuklangan bo'lsa ClassQuestionSource, yuklanmagan bo'lsa
// PackQuestionSource (ikkalasi ham tekshiriladi).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

/// Mavzuga bog'langan, lekin hali tayyor bo'lmagan decklar (sababi bilan).
/// Ro'yxat faqat qisqaradi: deck tayyor bo'lsa — test o'zi aytadi.
const _preparingAllowed = {
  // Muallif decki (kirish darsi): mavzusida tekshirilgan savol yo'q —
  // docs/TOPIC_TEST_COVERAGE.md.
  'd001',
};

/// Tayyor testli decklar soni kamaymaydi (2026-10-18: 142).
const _minReady = 142;

void main() {
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
  final pools = DeckPools.of(cur, pack, bank);
  final ready = [
    for (final d in catalog.decks)
      if (pools.state(d) == DeckTestState.ready) d,
  ];
  // Ekrandagi qidiruv: bank yuklangan / hali yuklanmagan.
  final withBank = ClassQuestionSource.of(pack, bank);
  final packOnly = PackQuestionSource.of(pack);

  test('decklar holati: tayyorlar kamaymaydi, “tayyorlanmoqda” — faqat '
      'ro‘yxatdagilar, mavzusiz deck — tugmasiz', () {
    expect(ready.length, greaterThanOrEqualTo(_minReady));
    final preparing = {
      for (final d in catalog.decks)
        if (pools.state(d) == DeckTestState.preparing) d.id,
    };
    expect(preparing.difference(_preparingAllowed), isEmpty);
    // Istisno eskirsa (deck tayyor bo'lib qolsa) — ro'yxatdan o'chiring.
    expect(_preparingAllowed.difference(preparing), isEmpty);
    for (final d in catalog.decks) {
      if (d.topics.isEmpty) {
        expect(pools.state(d), DeckTestState.hidden, reason: d.id);
      }
    }
  });

  test('har tayyor deck, har savol: ekranda topiladi, uch tilda matn, '
      'bitta to‘g‘ri javob oralig‘ida, variantlar takrorlanmaydi', () {
    final problems = <String>[];
    var checked = 0;
    for (final d in ready) {
      final pool = pools.pool(d);
      if (pool.length < kTopicTestMin) problems.add('${d.id}: hovuz kichik');
      final ids = <String>{};
      for (final q in pool) {
        checked++;
        final where = '${d.id}/${q.id}';
        if (!ids.add(q.id)) problems.add('$where: hovuzda takror');
        if (!isVerifiedTopicQuestion(q)) problems.add('$where: tekshirilmagan');
        // topicQuestion(): bank yuklangan holat.
        final viaBank = withBank.question(q.id);
        if (viaBank == null) {
          problems.add('$where: ClassQuestionSource da yo‘q');
        }
        if (viaBank != null && !identical(viaBank, q)) {
          // Bir xil savol obyekti bo'lishi shart emas, lekin kalit bir xil.
          if (viaBank.correct.toString() != q.correct.toString()) {
            problems.add('$where: kalit farq qiladi');
          }
        }
        // topicQuestion(): bank hali yuklanmagan holat — paket savollari
        // (derived ham) baribir topilishi kerak.
        if (q is! ToifaTestQuestion && packOnly.question(q.id) == null) {
          problems.add('$where: PackQuestionSource da yo‘q');
        }
        if (q.correct.length != 1) problems.add('$where: kalit soni');
        final k = q.correct.first;
        if (k < 0 || k >= q.optionCount) problems.add('$where: kalit oralig‘i');
        if (q.optionCount < 2) problems.add('$where: variantlar < 2');
        for (final lang in kDeckLangs) {
          if (q.prompt(lang).trim().isEmpty) {
            problems.add('$where: savol matni yo‘q ($lang)');
          }
          for (var i = 0; i < q.optionCount; i++) {
            if (q.option(i, lang).trim().isEmpty) {
              problems.add('$where: $i-variant yo‘q ($lang)');
            }
          }
          if (q is ToifaTestQuestion &&
              lang != 'uz' &&
              !q.hasTranslation(lang)) {
            problems.add('$where: $lang tarjimasi yo‘q');
          }
        }
      }
    }
    expect(problems, isEmpty);
    expect(checked, greaterThan(2000));
  });

  test('sessiya ilovadagidek quriladi: hovuzning HAR savoli kamida bitta '
      'urug‘da chiqadi; tartib, kalit, ball, xatolarni takrorlash', () {
    final problems = <String>[];
    for (final d in ready) {
      final pool = pools.pool(d);
      final byId = {for (final q in pool) q.id: q};
      final seen = <String>{};
      // Har urug' boshqa 10 ta; hovuz to'liq qoplanguncha (chegara bilan).
      for (var seed = 0; seed < 400 && seen.length < pool.length; seed++) {
        final drawn = drawTopicTest(pool, seed: seed);
        final want = pool.length < kTopicTestSize
            ? pool.length
            : kTopicTestSize;
        if (drawn.length != want) problems.add('${d.id}: $seed soni');
        // Deterministik: bir xil urug' — bir xil test.
        if (seed < 3 &&
            drawTopicTest(pool, seed: seed).map((q) => q.id).join() !=
                drawn.map((q) => q.id).join()) {
          problems.add('${d.id}: urug‘ deterministik emas');
        }
        final s = buildTopicTestSession(
          id: '${d.id}-$seed',
          questions: drawn,
          seed: seed,
          startedAt: DateTime.utc(2026, 10, 18),
          title: d.title('uz'),
        );
        for (final (i, item) in s.items.indexed) {
          final q = byId[item.questionId];
          seen.add(item.questionId);
          if (q == null) {
            problems.add('${d.id}: ${item.questionId} hovuzda yo‘q');
            continue;
          }
          final sorted = [...item.order]..sort();
          if (sorted.join(',') !=
              List.generate(q.optionCount, (k) => k).join(',')) {
            problems.add('${d.id}/${q.id}: tartib almashtirish emas');
          }
          if (q is OfficialKeyQuestion &&
              item.order.join(',') !=
                  List.generate(q.optionCount, (k) => k).join(',')) {
            problems.add(
              '${d.id}/${q.id}: rasmiy savol variantlari aralashgan',
            );
          }
          if (item.correct.join(',') != q.correct.join(',')) {
            problems.add('${d.id}/${q.id}: sessiya kaliti');
          }
          if (item.position != i) problems.add('${d.id}: position');
        }
        // Hammasi to'g'ri → to'liq ball; hammasi xato → hammasi xatolar.
        final right = ExamSession.fromJson(s.toJson());
        final wrong = ExamSession.fromJson(s.toJson());
        for (var i = 0; i < s.length; i++) {
          final it = s.items[i];
          right.choose(it.order.indexOf(it.correct.single));
          wrong.choose(it.order.indexWhere((o) => o != it.correct.single));
          right.next();
          wrong.next();
        }
        if (right.correctCount != s.length) {
          problems.add('${d.id}: $seed to‘g‘ri javoblar sanalmadi');
        }
        if (wrong.mistakeIndexes.length != s.length) {
          problems.add('${d.id}: $seed xatolar sanalmadi');
        }
        // “Xatolarni takrorlash”: xatolar hovuzdan topiladi.
        final rework = drawTopicTest([
          for (final i in wrong.mistakeIndexes) ?byId[s.items[i].questionId],
        ], seed: seed + 1);
        if (rework.length != s.length) {
          problems.add('${d.id}: $seed xatolarni takrorlash');
        }
      }
      if (seen.length != pool.length) {
        problems.add(
          '${d.id}: ${pool.length - seen.length} savol hech '
          'qachon chiqmadi',
        );
      }
    }
    expect(problems, isEmpty);
  });

  test('“Slaydni ko‘rish”: har savol, har til — slayd deck ichida yoki '
      'deck boshi (null)', () {
    final problems = <String>[];
    final names = packAnalyteNames(pack);
    var linked = 0;
    for (final d in ready) {
      for (final q in pools.pool(d)) {
        for (final lang in kDeckLangs) {
          final s = matchSlide(q, d, lang, analyteNames: names);
          if (s == null) continue;
          linked++;
          if (s < 0 || s >= d.slides(lang)) {
            problems.add('${d.id}/${q.id}/$lang: slayd $s');
          }
        }
      }
    }
    expect(problems, isEmpty);
    // Havolalar umuman ishlayapti (hammasi “deck boshi” bo'lib qolmagan).
    expect(linked, greaterThan(1000));
  });

  test(
    'natija qayta ishga tushirishdan keyin saqlanadi (har tayyor deck)',
    () async {
      final store = MemoryKeyValueStore();
      var t = DateTime.utc(2026, 10, 18, 9);
      final c = TopicTestController(store, clock: () => t);
      final expected = <String, (int, int)>{};
      for (final (n, d) in ready.indexed) {
        final pool = pools.pool(d);
        final s = buildTopicTestSession(
          id: c.newId(),
          questions: drawTopicTest(pool, seed: n),
          seed: n,
          startedAt: c.now(),
          title: d.title('uz'),
        );
        await c.start(d.id, s);
        // Har deckda boshqacha ball: birinchi n % (len+1) tasi to'g'ri.
        final good = n % (s.length + 1);
        for (var i = 0; i < s.length; i++) {
          final it = s.items[i];
          s.choose(
            i < good
                ? it.order.indexOf(it.correct.single)
                : it.order.indexWhere((o) => o != it.correct.single),
          );
          await c.save(d.id, s);
          s.next();
        }
        t = t.add(const Duration(minutes: 1));
        final r = (await c.finish(d.id))!;
        expect(r.correct, good, reason: d.id);
        expect(r.total, s.length, reason: d.id);
        expected[d.id] = (good, s.length);
      }
      // “Ilova qayta ochildi”: yangi controller shu ombordan o'qiydi.
      final again = TopicTestController(store, clock: () => t);
      for (final d in ready) {
        final best = again.best(d.id);
        expect(best, isNotNull, reason: d.id);
        expect((best!.correct, best.total), expected[d.id], reason: d.id);
        final last = again.last(d.id)!;
        expect(last.finished, isTrue, reason: d.id);
        // Xatolar tahlili: oxirgi sessiya savollari yana topiladi.
        for (final it in last.items) {
          expect(withBank.question(it.questionId), isNotNull, reason: d.id);
        }
      }
    },
  );
}
