import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/bloodgroup/bloodgroup_content.dart';
import 'package:labguide/features/bloodgroup/bloodgroup_logic.dart';
import 'package:labguide/features/bloodgroup/bloodgroup_screens.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _langs = ['uz', 'ru', 'en'];

void _full(LocalizedText t, String reason) {
  for (final lang in _langs) {
    expect(t.values[lang]?.trim(), isNotEmpty, reason: '$reason $lang');
  }
}

const _routes = [
  'basics',
  'methods',
  'compat',
  'errors',
  'quality',
  'reader',
  'quiz',
];

BgResult _read({
  BgReaction? antiA,
  BgReaction? antiB,
  BgReaction? antiD,
  bool? a1,
  bool? b,
  bool? control,
}) => readPattern(
  BgInput(
    antiA: antiA,
    antiB: antiB,
    antiD: antiD,
    a1Cells: a1,
    bCells: b,
    control: control,
  ),
);

const _p = BgReaction.pos;
const _n = BgReaction.neg;
const _w = BgReaction.weak;

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('hamma matn 3 tilda to‘liq, har da’voda manba bor', () {
      expect(File(bloodGroupCardImage).existsSync(), true);
      final items = [
        ...bgBasics,
        ...bgMethods,
        ...bgCompat,
        ...bgCauses,
        ...bgErrors,
        ...bgActions,
        ...bgQuality,
      ];
      expect({for (final i in items) i.id}.length, items.length);
      for (final i in items) {
        _full(i.title, i.id);
        _full(i.body, i.id);
        expect(i.refs, isNotEmpty, reason: i.id);
        for (final r in i.refs) {
          expect(r.locator.trim(), isNotEmpty, reason: i.id);
        }
      }
      for (final g in AboGroup.values) {
        _full(aboGroupNames[g]!, g.name);
      }
      for (final (_, t) in bgGrades) {
        _full(t, 'grade');
      }
      expect(
        [for (final (g, _) in bgGrades) g],
        ['4+', '3+', '2+', '1+', '−', 'L'],
      );
      for (final s in bgTubeReading) {
        _full(s, 'reading');
      }
      for (final (reagent, pos, neg) in bgControlTable) {
        _full(reagent, 'ctrl');
        _full(pos, 'ctrl');
        _full(neg, 'ctrl');
      }
      for (final f in BgFlag.values) {
        final info = bgFlagInfo[f];
        expect(info, isNotNull, reason: f.name);
        _full(info!.text, f.name);
        expect(info.refs, isNotEmpty, reason: f.name);
      }
      for (final t in [
        BgL.subtitle,
        BgL.draftNote,
        BgL.sopNote,
        BgL.noIssueNote,
        BgL.readerTrainingOnly,
        BgL.basicsIntro,
        BgL.methodsIntro,
        BgL.compatIntro,
        BgL.errorsIntro,
        BgL.qualityIntro,
        BgL.selectNote,
        BgL.quizIntro,
      ]) {
        _full(t, 'BgL');
      }
      for (final s in BgSources.all) {
        expect(s.url, startsWith('https://'), reason: s.id);
        expect(s.citation, isNotEmpty);
      }
      expect(
        {for (final s in BgSources.all) s.id}.length,
        BgSources.all.length,
      );
    });

    test('mashq: 8–10 savol, 4 xil variant, to‘g‘ri javob birinchi', () {
      expect(bgQuiz.length, inInclusiveRange(8, 10));
      expect({for (final q in bgQuiz) q.id}.length, bgQuiz.length);
      for (final q in bgQuiz) {
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
      for (var seed = 0; seed < 10; seed++) {
        final qs = buildBgQuiz(Random(seed));
        expect(qs, hasLength(bgQuiz.length));
        for (final q in qs) {
          final item = bgQuiz.firstWhere((i) => i.id == q.id);
          expect(
            q.options[q.correctIndex].text.of('en'),
            item.options.first.of('en'),
          );
        }
      }
    });

    test('naqsh savollari mantiq bilan mos', () {
      // Savoldagi naqsh → mantiq javobi to'g'ri variant bilan bir xil.
      final cases = {
        'bg-q-pattern-a': _read(antiA: _p, antiB: _n, a1: false, b: true),
        'bg-q-pattern-o': _read(antiA: _n, antiB: _n, a1: true, b: true),
        'bg-q-pattern-ab': _read(antiA: _p, antiB: _p, a1: false, b: false),
      };
      for (final MapEntry(key: id, value: r) in cases.entries) {
        final item = bgQuiz.firstWhere((q) => q.id == id);
        expect(item.options.first, same(aboGroupNames[r.group]), reason: id);
      }
      final d = _read(antiA: _n, antiB: _p, a1: false, b: false);
      expect(d.discrepancy, true);
      expect(d.group, isNull);
    });

    test('jadval: kutilgan naqsh Landshteyner qoidasiga mos', () {
      for (final g in AboGroup.values) {
        final e = expectedPattern(g);
        // Antigen bor ↔ unga qarshi antitela yo'q.
        expect(e.antiA, !e.a1Cells, reason: g.name);
        expect(e.antiB, !e.bCells, reason: g.name);
      }
      // JSST Fig. 14–15: O plazma faqat O ga; AB plazma hammaga.
      expect(bgSelectTable[AboGroup.o]!.$1, [AboGroup.o]);
      expect(bgSelectTable[AboGroup.ab]!.$2, [AboGroup.ab]);
      expect(bgSelectTable[AboGroup.ab]!.$1.toSet(), AboGroup.values.toSet());
      for (final g in AboGroup.values) {
        expect(bgSelectTable[g]!.$1, contains(g));
        expect(bgSelectTable[g]!.$2, contains(g));
      }
    });
  });

  group('naqsh mantig‘i', () {
    test('4 guruh: to‘g‘ri va teskari mos', () {
      final expected = {
        AboGroup.a: _read(antiA: _p, antiB: _n, a1: false, b: true),
        AboGroup.b: _read(antiA: _n, antiB: _p, a1: true, b: false),
        AboGroup.ab: _read(antiA: _p, antiB: _p, a1: false, b: false),
        AboGroup.o: _read(antiA: _n, antiB: _n, a1: true, b: true),
      };
      for (final MapEntry(key: g, value: r) in expected.entries) {
        expect(r.forward, g, reason: g.name);
        expect(r.reverse, g, reason: g.name);
        expect(r.group, g, reason: g.name);
        expect(r.discrepancy, false, reason: g.name);
        expect(r.flags, isEmpty, reason: g.name);
      }
    });

    test('RhD musbat / manfiy / kuchsiz', () {
      final pos = _read(antiA: _p, antiB: _n, antiD: _p, a1: false, b: true);
      expect(pos.rh, RhResult.positive);
      expect(pos.group, AboGroup.a);
      expect(pos.flags, isEmpty);
      final neg = _read(antiA: _n, antiB: _n, antiD: _n, a1: true, b: true);
      expect(neg.rh, RhResult.negative);
      expect(neg.group, AboGroup.o);
      final weak = _read(antiD: _w);
      expect(weak.rh, RhResult.weak);
      expect(weak.flags, contains(BgFlag.weakD));
      expect(_read(antiA: _p).rh, isNull);
    });

    test('nomuvofiqlik: guruh aytilmaydi, ustun toifasi belgilanadi', () {
      // B antigeni bor, lekin anti-A yo'q (kutilgan agglyutinin yo'q).
      final missing = _read(antiA: _n, antiB: _p, a1: false, b: false);
      expect(missing.forward, AboGroup.b);
      expect(missing.reverse, AboGroup.ab);
      expect(missing.group, isNull);
      expect(
        missing.flags,
        containsAll([BgFlag.discrepancy, BgFlag.aBothNegative]),
      );
      expect(missing.flags, isNot(contains(BgFlag.bBothPositive)));

      // A antigeni bor va A1 hujayralar bilan ham reaksiya (anti-A1?).
      final extra = _read(antiA: _p, antiB: _n, a1: true, b: true);
      expect(extra.discrepancy, true);
      expect(extra.flags, contains(BgFlag.aBothPositive));
      expect(extra.group, isNull);

      // O guruh to'g'ri usulda, lekin teskari usulda anti-B yo'q.
      final o = _read(antiA: _n, antiB: _n, a1: true, b: false);
      expect(o.flags, containsAll([BgFlag.discrepancy, BgFlag.bBothNegative]));

      // AB to'g'ri usulda, B hujayralar bilan reaksiya.
      final ab = _read(antiA: _p, antiB: _p, a1: false, b: true);
      expect(ab.flags, containsAll([BgFlag.discrepancy, BgFlag.bBothPositive]));

      // Ikkala ustun bo'yicha ham teskari.
      final both = _read(antiA: _p, antiB: _p, a1: true, b: true);
      expect(
        both.flags,
        containsAll([BgFlag.aBothPositive, BgFlag.bBothPositive]),
      );
    });

    test('to‘liqsiz natija: guruh yo‘q, nima yetishmasligi aytiladi', () {
      final fwd = _read(antiA: _p, antiB: _n);
      expect(fwd.forward, AboGroup.a);
      expect(fwd.group, isNull);
      expect(fwd.flags, {BgFlag.reverseMissing});
      final rev = _read(a1: true, b: false);
      expect(rev.reverse, AboGroup.b);
      expect(rev.group, isNull);
      expect(rev.flags, {BgFlag.forwardMissing});
      final half = _read(antiA: _p, a1: false);
      expect(half.forward, isNull);
      expect(half.reverse, isNull);
      expect(const BgInput().isEmpty, true);
    });

    test('nazorat musbat — yaroqsiz; AB D+ nazoratsiz — ogohlantirish', () {
      final ctrl = _read(
        antiA: _p,
        antiB: _n,
        a1: false,
        b: true,
        control: true,
      );
      expect(ctrl.invalid, true);
      expect(ctrl.group, isNull);
      final allPos = _read(
        antiA: _p,
        antiB: _p,
        antiD: _p,
        a1: false,
        b: false,
      );
      expect(allPos.group, AboGroup.ab);
      expect(allPos.flags, {BgFlag.allPositiveNoControl});
      final withCtrl = _read(
        antiA: _p,
        antiB: _p,
        antiD: _p,
        a1: false,
        b: false,
        control: false,
      );
      expect(withCtrl.flags, isEmpty);
    });

    test('kuchsiz anti-A/anti-B — anomaliya, guruh aytilmaydi (audit #5)', () {
      // Teskari usul mos (AB) bo'lsa ham guruh tasdiqlanmaydi: BSH §4.7.1.
      final r = _read(antiA: _w, antiB: _p, a1: false, b: false);
      expect(r.forward, AboGroup.ab);
      expect(r.discrepancy, isFalse);
      expect(r.anomaly, isTrue);
      expect(r.group, isNull);
      expect(r.flags, {BgFlag.weakForward});
      final a = _read(antiA: _w, antiB: _n, a1: false, b: true);
      expect(a.group, isNull);
      final b = _read(antiA: _n, antiB: _w, a1: true, b: false);
      expect(b.group, isNull);
    });

    test('aralash maydon — anomaliya, guruh aytilmaydi (audit #5)', () {
      const m = BgReaction.mixed;
      final a = _read(antiA: m, antiB: _n, a1: false, b: true);
      expect(a.flags, {BgFlag.mixedField});
      expect(a.anomaly, isTrue);
      expect(a.group, isNull);
      final o = _read(antiA: _n, antiB: m, a1: true, b: false);
      expect(o.group, isNull);
      // Anti-D bilan aralash maydon: Rh "aralash maydon", ABO ham anomaliya.
      final d = _read(antiA: _p, antiB: _n, antiD: m, a1: false, b: true);
      expect(d.rh, RhResult.mixedField);
      expect(d.flags, contains(BgFlag.mixedField));
      expect(d.group, isNull);
      // Har bir belgi uchun manbali izoh bor.
      for (final f in BgFlag.values) {
        expect(bgFlagInfo[f], isNotNull, reason: f.name);
        expect(bgFlagInfo[f]!.refs, isNotEmpty, reason: f.name);
      }
      // Kuchsiz reaksiya izohi endi aralash maydonni o'zi da'vo qilmaydi.
      expect(
        bgFlagInfo[BgFlag.weakForward]!.text.of('en'),
        isNot(contains('mixed field')),
      );
    });

    test('16 ta oddiy kombinatsiya o‘zgarmagan: 4 ta mos naqsh', () {
      var concordant = 0;
      for (final aa in [_n, _p]) {
        for (final bb in [_n, _p]) {
          for (final a1 in [false, true]) {
            for (final b in [false, true]) {
              final r = _read(antiA: aa, antiB: bb, a1: a1, b: b);
              if (r.group != null) concordant++;
            }
          }
        }
      }
      expect(concordant, 4);
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('barcha ekranlar ochiladi (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(390, 1600));
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      final card = find.text(l.bloodGroupLabCardBody);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(BloodGroupScreen), findsOne);
      expect(find.text(BgL.basicsTitle.of(lang.name)), findsOne);
      expect(find.text(BgL.sopNote.of(lang.name)), findsOne);
      for (final r in _routes) {
        await goTo(tester, '$bloodGroupBase/$r');
        expect(tester.takeException(), isNull, reason: r);
      }
      await goTo(tester, '$bloodGroupBase/errors');
      expect(find.byKey(const ValueKey('bg-no-issue')), findsOne);
    });
  }

  testWidgets('tor ekran (320 px, ru): toshib ketish yo‘q', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(320, 4000));
    for (final r in ['', for (final r in _routes) '/$r']) {
      await goTo(tester, '$bloodGroupBase$r');
      expect(tester.takeException(), isNull, reason: r);
    }
    // Hamma tanlovlar bosilgan holat ham sig'adi.
    await goTo(tester, '$bloodGroupBase/reader');
    for (final k in [
      'bg-in-antiA-weak',
      'bg-in-antiB-pos',
      'bg-in-antiD-weak',
      'bg-in-a1-pos',
      'bg-in-b-pos',
    ]) {
      await tester.tap(find.byKey(ValueKey(k)));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const ValueKey('bg-res-discrepancy')), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('naqsh o‘qish: guruh, nomuvofiqlik, tozalash', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '$bloodGroupBase/reader');
    expect(find.text(BgL.readerEmpty.of('uz')), findsOne);
    expect(find.byKey(const ValueKey('bg-reader-training')), findsOne);
    Future<void> tap(String k) async {
      await tester.tap(find.byKey(ValueKey('bg-in-$k')));
      await tester.pumpAndSettle();
    }

    // B guruh, RhD musbat.
    await tap('antiA-neg');
    await tap('antiB-pos');
    await tap('antiD-pos');
    expect(find.byKey(const ValueKey('bg-flag-reverseMissing')), findsOne);
    expect(find.byKey(const ValueKey('bg-res-group')), findsNothing);
    await tap('a1-pos');
    await tap('b-neg');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('bg-res-group'))).data,
      aboGroupNames[AboGroup.b]!.of('uz'),
    );
    expect(find.text(BgL.rhPositive.of('uz')), findsOne);

    // A1 hujayralar manfiy → anti-A yo'q → nomuvofiqlik.
    await tap('a1-neg');
    expect(find.byKey(const ValueKey('bg-res-discrepancy')), findsOne);
    expect(find.byKey(const ValueKey('bg-res-group')), findsNothing);
    expect(find.byKey(const ValueKey('bg-flag-aBothNegative')), findsOne);

    // A guruh naqshi, lekin anti-A kuchsiz → anomaliya, guruh yo'q.
    await tap('antiA-weak');
    await tap('antiB-neg');
    await tap('a1-neg');
    await tap('b-pos');
    expect(find.byKey(const ValueKey('bg-res-anomaly')), findsOne);
    expect(find.byKey(const ValueKey('bg-res-group')), findsNothing);
    expect(find.byKey(const ValueKey('bg-res-forward')), findsNothing);
    expect(find.byKey(const ValueKey('bg-flag-weakForward')), findsOne);
    // Aralash maydon.
    await tap('antiA-mixed');
    expect(find.byKey(const ValueKey('bg-res-anomaly')), findsOne);
    expect(find.byKey(const ValueKey('bg-flag-mixedField')), findsOne);
    expect(find.byKey(const ValueKey('bg-res-group')), findsNothing);
    // Aniq musbat — A guruh.
    await tap('antiA-pos');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('bg-res-group'))).data,
      aboGroupNames[AboGroup.a]!.of('uz'),
    );

    // Nazorat musbat → yaroqsiz.
    await tap('a1-pos');
    await tap('control-pos');
    expect(find.byKey(const ValueKey('bg-res-invalid')), findsOne);

    final reset = find.text(BgL.reset.of('uz'));
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.text(BgL.readerEmpty.of('uz')), findsOne);
  });

  testWidgets('mashq: javob berib, natijagacha', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '$bloodGroupBase/quiz');
    final l = lookupAppLocalizations(const Locale('uz'));
    await tester.tap(find.text(BgL.quizStart.of('uz')));
    await tester.pumpAndSettle();
    for (var i = 0; i < bgQuiz.length; i++) {
      await tester.tap(find.byKey(const ValueKey('bg-opt-0')));
      await tester.pumpAndSettle();
      final next = find.text(
        i == bgQuiz.length - 1 ? l.quizFinish : l.quizNext,
      );
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text(l.quizDoneTitle), findsOne);
  });

  testWidgets('Lab: qon guruhi kartasi ko‘rinadi va ochiladi', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 1600));
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/lab');
    expect(find.text(l.bloodGroupTitle), findsOne);
    expect(find.text(l.bloodGroupLabCardBody), findsOne);
    expect(find.text(l.spermLabCardBody), findsOne);
    await tester.tap(find.text(l.bloodGroupTitle));
    await tester.pumpAndSettle();
    expect(find.byType(BloodGroupScreen), findsOne);
    expect(tester.takeException(), isNull);
  });
}
