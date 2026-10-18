// Qorovul: toifa testi va og'zaki bilet — HAQIQIY asset'lar
// (assets/toifa/kdl_tests.json, kdl_oral.json), HAR BIR savol bo'yicha.
//
// Kalitlar o'zgartirilmaydi (rasmiy ro'yxat); bu yerda faqat ilova ularni
// to'g'ri o'qishi va ko'rsatishi tekshiriladi: kalit oralig'i, takror id,
// bo'sh variant, uch til, 50 savollik test (imtihon va mashq rejimi), bilet
// (5 savol, yozuvsiz) va ilova qayta ochilgach davom etish.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/features/toifa/toifa_controller.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

String _norm(String s) => normalizeForSearch(s);

/// Rasmiy ro'yxatning o'zida bir xil matnli savollar (ro'yxatda ikki marta
/// berilgan). Kalit o'zgartirilmaydi; yangi takror paydo bo'lsa — test
/// yiqiladi (ko'rib chiqing va bu yerga sababi bilan yozing).
const _officialDuplicates = {
  // Variantlar bir xil (“IX omil”/“IX faktor”), kalit ikkalasida “Prostasiklin”.
  'kdl-t-139': 'kdl-t-190',
  // Variantlar boshqa; 401 — kalit bahsli (disputed), izohi bor.
  'kdl-t-380': 'kdl-t-401',
};

class _FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

void main() {
  final testsJson = _json('assets/toifa/kdl_tests.json');
  final oralJson = _json('assets/toifa/kdl_oral.json');
  final bank = ToifaBank.fromJson(testsJson, oralJson);
  final raw = (testsJson['questions']! as List).cast<Map<String, Object?>>();

  test('har test savoli: id va raqam takrorsiz, kalit oralig‘ida, bo‘sh '
      'variant yo‘q, ru/en tarjima to‘liq', () {
    final problems = <String>[];
    final ids = <String>{};
    final numbers = <int>{};
    for (final j in raw) {
      final id = j['id']! as String;
      if (!ids.add(id)) problems.add('$id: id takror');
      if (!numbers.add(j['n']! as int)) problems.add('$id: raqam takror');
    }
    for (final q in bank.tests) {
      final where = q.id;
      if (q.optionCount < 3 || q.optionCount > 4) {
        problems.add('$where: variantlar ${q.optionCount}');
      }
      if (q.key.length > 1) problems.add('$where: bir nechta kalit');
      for (final k in q.key) {
        if (k < 0 || k >= q.optionCount) problems.add('$where: kalit $k');
      }
      if (q.text.trim().isEmpty) problems.add('$where: matn bo‘sh');
      for (final lang in ['uz', 'ru', 'en']) {
        if (lang != 'uz' && !q.hasTranslation(lang)) {
          problems.add('$where: $lang yo‘q');
        }
        if (q.prompt(lang).trim().isEmpty) {
          problems.add('$where: $lang savol bo‘sh');
        }
        final seen = <String>{};
        for (var i = 0; i < q.optionCount; i++) {
          final o = q.option(i, lang);
          if (o.trim().isEmpty) problems.add('$where: $lang $i bo‘sh');
          if (!seen.add(_norm(o))) problems.add('$where: $lang variant takror');
        }
      }
      // Ball hisoblanadiganlar: kalit bor va chiqarilmagan.
      if (q.scorable != (q.key.isNotEmpty && q.held == null)) {
        problems.add('$where: scorable');
      }
    }
    expect(problems, isEmpty);
    expect(bank.tests.length, greaterThanOrEqualTo(488));
    expect(bank.scorable.length, greaterThanOrEqualTo(470));
  });

  test('takror savol matni faqat rasmiy ro‘yxatdagi ma’lum juftlar', () {
    final byText = <String, List<String>>{};
    for (final q in bank.tests) {
      (byText[_norm(q.text)] ??= []).add(q.id);
    }
    final groups = [
      for (final g in byText.values)
        if (g.length > 1) (g..sort()).join('+'),
    ]..sort();
    expect(
      groups,
      [for (final e in _officialDuplicates.entries) '${e.key}+${e.value}']
        ..sort(),
    );
    // Bir xil variantli juftda kalit ham bir xil.
    final a = bank.test('kdl-t-139')!;
    final b = bank.test('kdl-t-190')!;
    expect(a.key, b.key);
  });

  test('50 savollik test (imtihon rejimi): ilovadagidek tuziladi — '
      'variantlar asl tartibda, kalit = rasmiy, to‘liq/nol ball', () {
    // Ko'p urug' bilan: hovuzning har savoli kamida bir marta chiqadi.
    final pool = toifaTestPool(bank);
    final seen = <String>{};
    for (var seed = 0; seed < 200 && seen.length < pool.length; seed++) {
      final r = Random(seed);
      final s = ExamSession.build(
        id: 't$seed',
        mode: ExamMode.exam,
        questions: drawQuestions(pool, ToifaFormat.testSize, r),
        random: r,
        startedAt: DateTime.utc(2026, 10, 18),
        sourceId: ToifaQuestionSource.sourceId,
        limit: const Duration(minutes: 60),
        shuffleOptions: false,
      );
      expect(s.length, ToifaFormat.testSize);
      final again = ExamSession.fromJson(s.toJson()); // qayta ochish
      for (var i = 0; i < s.length; i++) {
        final it = s.items[i];
        seen.add(it.questionId);
        final q = bank.test(it.questionId)!;
        expect(bank.source.question(it.questionId), same(q));
        expect(it.order, List.generate(q.optionCount, (k) => k));
        expect(it.correct, q.key.toList());
        s.choose(it.correct.single);
        s.next();
      }
      expect(s.correctCount, ToifaFormat.testSize);
      expect(again.correctCount, 0);
      expect(again.unansweredCount, ToifaFormat.testSize);
    }
    expect(seen.length, pool.length);
  });

  test('mashq rejimi (darhol natija): 50 savol, javob darhol hisobga, '
      'qayta ochilgach davom, xatolarni qayta ishlash', () async {
    final store = MemoryKeyValueStore();
    var now = DateTime(2026, 10, 18, 10);
    final c = ToifaController(
      store,
      bundle: _FileBundle(),
      clock: () => now,
      random: Random(3),
    );
    await c.ensureLoaded();
    expect(c.bank, isNotNull);
    final d = (await c.startDrill(
      drawQuestions(toifaTestPool(c.bank!), ToifaFormat.testSize, Random(1)),
    ))!;
    expect(d.length, ToifaFormat.testSize);
    for (var i = 0; i < 20; i++) {
      final q = c.bank!.test(d.ids[d.index])!;
      expect(d.keys[d.index], q.key.single);
      final ok = await c.answerDrill(
        i.isEven ? q.key.single : (q.key.single + 1) % q.optionCount,
      );
      expect(ok, i.isEven);
      await c.drillNext();
    }
    expect(c.todayStats.answered, 20);
    expect(c.todayStats.correct, 10);
    // “Ilova qayta ochildi”.
    final c2 = ToifaController(store, bundle: _FileBundle(), clock: () => now);
    await c2.ensureLoaded();
    final d2 = c2.activeDrill!;
    expect(d2.answeredCount, 20);
    expect(d2.index, 20);
    expect(c2.todayStats.answered, 20);
    for (var i = 20; i < d2.length; i++) {
      final q = c2.bank!.test(d2.ids[d2.index])!;
      await c2.answerDrill(q.key.single);
      await c2.drillNext();
    }
    expect(c2.activeDrill, isNull);
    expect(c2.drill!.finished, isTrue);
    expect(c2.drill!.correctCount, 40);
    expect(c2.drill!.wrongIndexes.length, 10);
    expect(c2.todayStats.answered, 50);
    // Kunlik maqsad (50) bajarildi → “ertaga davom” taklifi sharti.
    expect(c2.todayGoalMet, isTrue);
    expect(c2.streak, 1);
    // Xatolarni qayta ishlash — faqat xatolar.
    final rework = await c2.startDrill([
      for (final i in c2.drill!.wrongIndexes) c2.bank!.test(c2.drill!.ids[i])!,
    ], rework: true);
    expect(rework!.length, 10);
    expect(rework.rework, isTrue);
    // Ertasi kun: bugungi hisob nol, seriya kechagi bilan 1; maqsad hali yo'q.
    now = now.add(const Duration(days: 1));
    expect(c2.todayStats.answered, 0);
    expect(c2.todayGoalMet, isFalse);
    expect(c2.streak, 1);
    // Ikki kun o'tkazib yuborilsa — seriya uziladi.
    now = now.add(const Duration(days: 1));
    expect(c2.streak, 0);
  });

  test('og‘zaki savollar: reja bor, ru/en reja qadamlari soni bir xil va '
      'bo‘sh emas; har toifa biletiga ≥ 5 savol', () {
    final problems = <String>[];
    for (final q in bank.oral) {
      if (q.text.trim().isEmpty) problems.add('${q.id}: matn');
      if (q.plan.isEmpty) problems.add('${q.id}: reja yo‘q');
      if (q.categories.isEmpty) problems.add('${q.id}: toifa yo‘q');
      for (final lang in ['ru', 'en']) {
        final t = q.translations[lang];
        if (t == null) {
          problems.add('${q.id}: $lang yo‘q');
          continue;
        }
        final loc = q.localized(lang);
        if (loc.text.trim().isEmpty) problems.add('${q.id}: $lang matn');
        if (loc.plan.length != q.plan.length) {
          problems.add('${q.id}: $lang reja');
        }
        if (loc.plan.any((p) => p.trim().isEmpty)) {
          problems.add('${q.id}: $lang bo‘sh qadam');
        }
      }
    }
    expect(problems, isEmpty);
    for (final c in ToifaCategory.values) {
      expect(
        bank.ticketPool(c).length,
        greaterThanOrEqualTo(ToifaFormat.ticketSize),
        reason: c.id,
      );
    }
  });

  test(
    'bilet: 5 savol (yozuvsiz — faqat baho), hammasi bankda, qayta '
    'ochilgach davom etadi, bilet kunlik hisobga bir marta yoziladi',
    () async {
      for (final cat in ToifaCategory.values) {
        final store = MemoryKeyValueStore();
        final now = DateTime(2026, 10, 18, 11);
        final c = ToifaController(
          store,
          bundle: _FileBundle(),
          clock: () => now,
          random: Random(cat.index),
        );
        await c.ensureLoaded();
        // Toifa havzasini bir necha bilet bilan aylanib chiqish.
        final pool = {for (final q in c.bank!.ticketPool(cat)) q.id};
        final seen = <String>{};
        for (var n = 0; n < 200 && seen.length < pool.length; n++) {
          final t = (await c.drawTicket(cat))!;
          expect(t.ids.length, ToifaFormat.ticketSize);
          expect(t.ids.toSet().length, ToifaFormat.ticketSize);
          expect(pool.containsAll(t.ids), isTrue, reason: cat.id);
          seen.addAll(t.ids);
          await c.startReview();
          for (var i = 0; i < t.ids.length; i++) {
            final q = c.bank!.oralQuestion(t.currentId)!;
            expect(q.plan, isNotEmpty);
            await c.reveal();
            if (n == 0 && i == 2) {
              // Bilet o'rtasida ilova yopildi va qayta ochildi.
              final c2 = ToifaController(
                store,
                bundle: _FileBundle(),
                clock: () => now,
              );
              await c2.ensureLoaded();
              final t2 = c2.ticket!;
              expect(t2.ids, t.ids);
              expect(t2.reviewing, isTrue);
              expect(t2.revealed, isTrue);
              expect(t2.index, t.index);
              expect(t2.ratings.length, 2);
            }
            await c.rateCurrent(OralRating.values[(n + i) % 3]);
          }
          expect(c.ticket!.done, isTrue);
        }
        expect(seen, pool, reason: '${cat.id}: biletga chiqmagan savollar');
        // Har yakunlangan bilet bir marta sanaladi; 1 bilet — kunlik maqsad.
        expect(c.todayStats.tickets, greaterThan(0));
        expect(c.todayGoalMet, isTrue);
      }
    },
  );
}
