import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/spermogram/spermogram_content.dart';
import 'package:labguide/features/spermogram/spermogram_logic.dart';
import 'package:labguide/features/spermogram/spermogram_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

const _langs = ['uz', 'ru', 'en'];

void _full(LocalizedText t, String reason) {
  for (final lang in _langs) {
    expect(t.values[lang]?.trim(), isNotEmpty, reason: '$reason $lang');
  }
}

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('JSST 2021 Table 8.3 qiymatlari', () {
      final m = {
        for (final l in spermLimits)
          l.param: (l.lower, l.ciLow, l.ciHigh, l.median),
      };
      expect(m[SpermParam.volume], (1.4, 1.3, 1.5, 3.0));
      expect(m[SpermParam.concentration], (16.0, 15.0, 18.0, 66.0));
      expect(m[SpermParam.totalNumber], (39.0, 35.0, 40.0, 210.0));
      expect(m[SpermParam.totalMotility], (42.0, 40.0, 43.0, 64.0));
      expect(m[SpermParam.progressive], (30.0, 29.0, 31.0, 55.0));
      expect(m[SpermParam.vitality], (54.0, 50.0, 56.0, 78.0));
      expect(m[SpermParam.normalForms], (4.0, 3.9, 4.0, 14.0));
      expect(m.keys.toSet(), SpermParam.values.toSet());
      expect(spermPhLow, 7.2);
      for (final l in spermLimits) {
        expect(l.ciLow, lessThanOrEqualTo(l.lower), reason: l.param.name);
        expect(l.ciHigh, greaterThanOrEqualTo(l.lower), reason: l.param.name);
      }
    });

    test('hamma matn 3 tilda to‘liq, manbalar bor', () {
      expect(File(spermCardImage).existsSync(), true);
      for (final p in SpermParam.values) {
        _full(spermParamNames[p]!, p.name);
        _full(spermParamUnits[p]!, p.name);
      }
      for (final g in MotilityGrade.values) {
        _full(motilityGrades[g]!.name, g.name);
        _full(motilityGrades[g]!.definition, g.name);
      }
      expect(
        [for (final g in MotilityGrade.values) motilityGrades[g]!.letter],
        ['a', 'b', 'c', 'd'],
      );
      for (final d in MorphDefect.values) {
        _full(morphDefectNames[d]!, d.name);
      }
      for (final t in SpermTerm.values) {
        _full(spermTerms[t]!.name, t.name);
        _full(spermTerms[t]!.definition, t.name);
      }
      for (final t in spermExtraTerms) {
        _full(t.name, 'extra');
        _full(t.definition, 'extra');
      }
      for (final s in spermPreSteps) {
        _full(s.title, 'pre');
        _full(s.body, 'pre');
        expect(s.ref.locator, isNotEmpty);
      }
      expect(spermQuiz.length, inInclusiveRange(8, 10));
      expect({for (final q in spermQuiz) q.id}.length, spermQuiz.length);
      for (final q in spermQuiz) {
        _full(q.prompt, q.id);
        _full(q.basis, q.id);
        expect(q.options, hasLength(4), reason: q.id);
        for (final o in q.options) {
          _full(o, q.id);
        }
        for (final lang in _langs) {
          expect(
            {for (final o in q.options) o.of(lang)}.length,
            4,
            reason: '${q.id} $lang',
          );
        }
      }
      for (final s in SpermSources.all) {
        expect(s.url, startsWith('https://'));
      }
      _full(cytoplasmNote, 'cyto');
    });

    test('mashq: to‘g‘ri javob har doim birinchi variant', () {
      for (var seed = 0; seed < 10; seed++) {
        final qs = buildSpermQuiz(Random(seed));
        expect(qs, hasLength(spermQuiz.length));
        for (final q in qs) {
          final item = spermQuiz.firstWhere((i) => i.id == q.id);
          expect(
            q.options[q.correctIndex].text.of('en'),
            item.options.first.of('en'),
          );
        }
      }
    });
  });

  group('hisoblagich', () {
    test('foizlar: yig‘indi 100, eng katta guruh tuzatiladi', () {
      expect(roundedPercents([0, 0, 0, 0]), [0, 0, 0, 0]);
      expect(roundedPercents([50, 50, 50, 50]), [25, 25, 25, 25]);
      // 1/3 → 33+33+33 = 99 → eng katta (birinchi) 34.
      expect(roundedPercents([1, 1, 1]), [34, 33, 33]);
      // 1/6, 5/6: 17 + 83 = 100.
      expect(roundedPercents([1, 5]), [17, 83]);
      for (final c in [
        [1, 2, 3, 4],
        [66, 67, 67, 0],
      ]) {
        expect(roundedPercents(c).reduce((a, b) => a + b), 100, reason: '$c');
      }
      // 101 → ustun guruh (67, birinchisi) 1 ga kamaytiriladi.
      expect(roundedPercents([66, 67, 67, 0]), [33, 33, 34, 0]);
    });

    test('foizlar: faqat 99/101 tuzatiladi, x,5 lardan 102 — tuzatilmaydi '
        '(audit #17, JSST §2.4.6.2)', () {
      // 0,5 + 0,5 + 0,5 + 98,5 → 1 + 1 + 1 + 99 = 102.
      expect(roundedPercents([1, 1, 1, 197]), [1, 1, 1, 99]);
      // 1,5 + 3,5 + 5,5 + 89,5 → 2 + 4 + 6 + 90 = 102.
      expect(roundedPercents([3, 7, 11, 179]), [2, 4, 6, 90]);
      final m = MotilityCount();
      for (final (g, n) in [
        (MotilityGrade.rapid, 1),
        (MotilityGrade.slow, 1),
        (MotilityGrade.nonProgressive, 1),
        (MotilityGrade.immotile, 197),
      ]) {
        for (var i = 0; i < n; i++) {
          m.add(g);
        }
      }
      expect(m.roundingUnresolved, true);
      expect(m.exactPercents, [0.5, 0.5, 0.5, 98.5]);
      final ok = MotilityCount()
        ..add(MotilityGrade.rapid)
        ..add(MotilityGrade.immotile);
      expect(ok.roundingUnresolved, false);
    });

    test('uz: “ko‘pi bilan 60 daqiqa” (audit #16)', () {
      final step = spermPreSteps.firstWhere(
        (s) => s.title.of('en') == 'Time to analysis',
      );
      expect(step.body.of('uz'), contains('ko‘pi bilan 60 daqiqa'));
      expect(step.body.of('uz'), isNot(contains('kamida 60')));
      expect(step.body.of('ru'), contains('не позднее 60 минут'));
      expect(step.body.of('en'), contains('no later than 60 minutes'));
    });

    test('harakatchanlik: PR = a + b, umumiy = a + b + c', () {
      final m = MotilityCount();
      expect(m.progressive, isNull);
      for (var i = 0; i < 40; i++) {
        m.add(MotilityGrade.rapid);
      }
      for (var i = 0; i < 30; i++) {
        m.add(MotilityGrade.slow);
      }
      for (var i = 0; i < 10; i++) {
        m.add(MotilityGrade.nonProgressive);
      }
      for (var i = 0; i < 120; i++) {
        m.add(MotilityGrade.immotile);
      }
      expect(m.total, 200);
      expect(m.progressive, 35);
      expect(m.totalMotility, 40);
      expect(m.percents, [20, 15, 5, 60]);
      // Maqsaddan keyin ham sanash davom etadi.
      m.add(MotilityGrade.slow);
      expect(m.total, 201);
      m.undo();
      expect(m.total, 200);
      expect(m.count(MotilityGrade.slow), 30);
      m.reset();
      expect(m.isEmpty, true);
      expect(m.canUndo, false);
    });

    test('morfologiya: JSST misoli (§2.5.17.2) — 6%, TZI 1,91', () {
      final m = MorphologyCount();
      expect(m.addAbnormal({}), false);
      for (var i = 0; i < 12; i++) {
        m.addNormal();
      }
      // 188 anormal: H 184, NM 102, T 30, C 44.
      for (var i = 0; i < 188; i++) {
        m.addAbnormal({
          if (i < 184) MorphDefect.head,
          if (i < 102) MorphDefect.neckMidpiece,
          if (i >= 158) MorphDefect.tail,
          if (i % 4 == 0 && i < 176) MorphDefect.cytoplasm,
        });
      }
      expect(m.total, 200);
      expect(m.normal, 12);
      expect(m.normalPercent, 6);
      expect(m.defect(MorphDefect.head), 184);
      expect(m.defect(MorphDefect.neckMidpiece), 102);
      expect(m.defect(MorphDefect.tail), 30);
      expect(m.defect(MorphDefect.cytoplasm), 44);
      expect(m.defectPercent(MorphDefect.head), 92);
      expect(m.tzi!.toStringAsFixed(2), '1.91');
      m.undo();
      expect(m.total, 199);
    });
  });

  group('baholash', () {
    test('normozoospermiya — barcha chegaradan past emas', () {
      final a = assessSperm(
        const SpermInput(
          volume: 3,
          concentration: 50,
          progressive: 45,
          totalMotility: 60,
          vitality: 70,
          normalForms: 6,
          ph: 7.8,
        ),
      );
      expect(a.below, isEmpty);
      expect(a.terms, [SpermTerm.normozoospermia]);
      expect(a.countBasis, SpermParam.totalNumber);
      expect(a.lowPh, false);
    });

    test('chegaraga teng qiymat — past emas', () {
      final a = assessSperm(
        const SpermInput(
          volume: 1.4,
          concentration: 16,
          progressive: 30,
          totalMotility: 42,
          vitality: 54,
          normalForms: 4,
        ),
      );
      // 1,4 × 16 = 22,4 < 39 — umumiy son past.
      expect(a.below, {SpermParam.totalNumber});
      expect(a.terms, [SpermTerm.oligozoospermia]);
    });

    test('umumiy son afzal: konsentratsiya past, umumiy son normal', () {
      final a = assessSperm(
        const SpermInput(
          volume: 5,
          concentration: 10,
          progressive: 40,
          normalForms: 5,
        ),
      );
      expect(a.below, {SpermParam.concentration});
      expect(a.countBasis, SpermParam.totalNumber);
      expect(a.terms, [SpermTerm.normozoospermia]);
    });

    test('hajmsiz — konsentratsiya bo‘yicha', () {
      final a = assessSperm(const SpermInput(concentration: 10));
      expect(a.countBasis, SpermParam.concentration);
      expect(a.terms, [SpermTerm.oligozoospermia]);
    });

    test('birlashgan atamalar', () {
      SpermTerm? only(SpermInput i) => assessSperm(i).terms.single;
      expect(
        only(
          const SpermInput(
            volume: 2,
            concentration: 10,
            progressive: 20,
            normalForms: 2,
          ),
        ),
        SpermTerm.oligoasthenoteratozoospermia,
      );
      expect(
        only(const SpermInput(concentration: 10, progressive: 20)),
        SpermTerm.oligoasthenozoospermia,
      );
      expect(
        only(const SpermInput(concentration: 10, normalForms: 3)),
        SpermTerm.oligoteratozoospermia,
      );
      expect(
        only(const SpermInput(progressive: 20, normalForms: 3)),
        SpermTerm.asthenoteratozoospermia,
      );
      expect(
        only(const SpermInput(progressive: 29)),
        SpermTerm.asthenozoospermia,
      );
      expect(
        only(const SpermInput(normalForms: 3.9)),
        SpermTerm.teratozoospermia,
      );
    });

    test('azoospermiya, nekrozoospermiya, pH, xato', () {
      // Konsentratsiya 0: atama emas, faqat shubha (audit #10, §2.4.8.8).
      final z = assessSperm(const SpermInput(volume: 2, concentration: 0));
      expect(z.terms, isEmpty);
      expect(z.terms, isNot(contains(SpermTerm.azoospermia)));
      expect(z.azoospermiaSuspected, true);
      expect(z.hasFindings, true);
      // Nekrozoospermiya: tiriklik past VA harakatsizlar ko'p (audit #18).
      final n = assessSperm(const SpermInput(vitality: 40, totalMotility: 20));
      expect(n.terms, contains(SpermTerm.necrozoospermia));
      expect(n.vitalityLowOnly, false);
      expect(n.below, {SpermParam.vitality, SpermParam.totalMotility});
      final vOnly = assessSperm(const SpermInput(vitality: 40));
      expect(vOnly.terms, isNot(contains(SpermTerm.necrozoospermia)));
      expect(vOnly.vitalityLowOnly, true);
      final motile = assessSperm(
        const SpermInput(vitality: 40, totalMotility: 50),
      );
      expect(motile.terms, isNot(contains(SpermTerm.necrozoospermia)));
      expect(motile.vitalityLowOnly, true);
      expect(assessSperm(const SpermInput(ph: 7.0)).lowPh, true);
      expect(assessSperm(const SpermInput(ph: 7.2)).lowPh, false);
      final e = assessSperm(
        const SpermInput(progressive: 50, totalMotility: 40),
      );
      expect(e.errors, {SpermInputError.progressiveAboveTotal});
      expect(const SpermInput().isEmpty, true);
      expect(assessSperm(const SpermInput()).hasFindings, false);
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('barcha ekranlar ochiladi (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s);
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      // Lab tabida bo'limlar ish vositalaridan keyin (D-68 Q2) — surib.
      await tapScroll(tester, l.spermTitle);
      expect(find.byType(SpermogramScreen), findsOne);
      expect(find.text(SpermL.limitsTitle.of(lang.name)), findsOne);
      for (final r in [
        'limits',
        'count',
        'assess',
        'terms',
        'preanalytics',
        'quiz',
      ]) {
        await goTo(tester, '$spermBase/$r');
        expect(tester.takeException(), isNull, reason: r);
      }
    });
  }

  testWidgets('tor ekran (320 px, ru): toshib ketish yo‘q', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(320, 2400));
    for (final r in [
      '',
      '/limits',
      '/count',
      '/assess',
      '/terms',
      '/preanalytics',
      '/quiz',
    ]) {
      await goTo(tester, '$spermBase$r');
      expect(tester.takeException(), isNull, reason: r);
    }
    await goTo(tester, '$spermBase/count');
    await tester.tap(find.byKey(const ValueKey('sperm-tab-morph')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sperm-morph-normal')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('hisoblagich: bosish, foiz, bekor qilish', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$spermBase/count');
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const ValueKey('sperm-mot-rapid')));
    }
    await tester.tap(find.byKey(const ValueKey('sperm-mot-immotile')));
    await tester.pumpAndSettle();
    // PR = 3/4 = 75%.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('sperm-res-pr')),
        matching: find.text('75%'),
      ),
      findsOne,
    );
    await tester.tap(find.text(SpermL.undo.of('uz')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('sperm-res-pr')),
        matching: find.text('100%'),
      ),
      findsOne,
    );

    // Morfologiya: nuqsonsiz "anormal" qabul qilinmaydi.
    await tester.tap(find.byKey(const ValueKey('sperm-tab-morph')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sperm-morph-abnormal')));
    await tester.pumpAndSettle();
    expect(find.text(SpermL.pickDefect.of('uz')), findsOne);
    await tester.tap(find.byKey(const ValueKey('sperm-def-head')));
    await tester.tap(find.byKey(const ValueKey('sperm-morph-abnormal')));
    await tester.tap(find.byKey(const ValueKey('sperm-morph-normal')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('sperm-res-normal')),
        matching: find.text('50%'),
      ),
      findsOne,
    );
  });

  testWidgets('baholash: past qiymat belgilanadi, atama chiqadi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '$spermBase/assess');
    expect(find.text(SpermL.emptyHint.of('uz')), findsOne);
    Future<void> enter(String f, String v) async {
      await tester.enterText(
        find.descendant(
          of: find.byKey(ValueKey('sperm-in-$f')),
          matching: find.byType(TextField),
        ),
        v,
      );
      await tester.pumpAndSettle();
    }

    await enter('volume', '2');
    await enter('concentration', '10');
    await enter('progressive', '45');
    await enter('normalForms', '6');
    // 2 × 10 = 20 < 39.
    expect(find.byKey(const ValueKey('sperm-assess-totalNumber')), findsOne);
    expect(find.byKey(const ValueKey('sperm-term-oligozoospermia')), findsOne);
    expect(find.text(SpermL.mayPoint.of('uz')), findsOne);

    await enter('progressive', '150');
    expect(find.text(SpermL.invalidPercent.of('uz')), findsOne);
    await enter('progressive', '20');
    await enter('totalMotility', '10');
    expect(find.text(SpermL.errProgressive.of('uz')), findsOne);
    expect(
      find.byKey(const ValueKey('sperm-term-oligoasthenozoospermia')),
      findsOne,
    );
    await enter('concentration', '0');
    expect(
      find.byKey(const ValueKey('sperm-term-azoospermia-suspected')),
      findsOne,
    );
    expect(find.byKey(const ValueKey('sperm-term-azoospermia')), findsNothing);
    expect(find.text(SpermL.azooSuspected.of('uz')), findsOne);
  });

  testWidgets('mashq: javob berib, natijagacha', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$spermBase/quiz');
    final l = lookupAppLocalizations(const Locale('uz'));
    await tester.tap(find.text(SpermL.quizStart.of('uz')));
    await tester.pumpAndSettle();
    for (var i = 0; i < spermQuiz.length; i++) {
      await tester.tap(find.byKey(const ValueKey('sperm-opt-0')));
      await tester.pumpAndSettle();
      final next = find.text(
        i == spermQuiz.length - 1 ? l.quizFinish : l.quizNext,
      );
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text(l.quizDoneTitle), findsOne);
  });
}
