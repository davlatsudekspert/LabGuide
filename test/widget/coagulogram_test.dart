import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/lecture_screens.dart';
import 'package:labguide/features/coagulogram/coag_content.dart';
import 'package:labguide/features/coagulogram/coag_screens.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/home/global_search.dart';
import 'package:labguide/features/home/search_sections.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _langs = ['uz', 'ru', 'en'];
final _cyrillic = RegExp('[Ѐ-ӿ]');

void _full(LocalizedText t, String reason) {
  for (final lang in _langs) {
    expect(t.values[lang]?.trim(), isNotEmpty, reason: '$reason $lang');
  }
  // O'zbekcha (lotin) va inglizcha matnda kirill harfi bo'lmasin.
  for (final lang in ['uz', 'en']) {
    expect(
      _cyrillic.hasMatch(t.values[lang]!),
      false,
      reason: '$reason $lang: ${t.values[lang]}',
    );
  }
  expect(_cyrillic.hasMatch(t.values['ru']!), true, reason: '$reason ru');
}

void _fact(CgFact f, String reason) {
  _full(f.text, reason);
  expect(f.refs, isNotEmpty, reason: reason);
  for (final r in f.refs) {
    expect(r.locator.trim(), isNotEmpty, reason: reason);
    expect(CgSources.all, contains(r.source), reason: reason);
  }
}

Finder field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextField),
);

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('har da’vo 3 tilda, manbasi va joyi bor', () {
      for (final t in CgL.all) {
        _full(t, 'CgL');
      }
      for (final f in cgAllFacts) {
        _fact(f, f.text.of('en'));
      }
      expect(
        {for (final t in cgTests) t.id},
        {'pt', 'aptt', 'tt', 'fibrinogen', 'ddimer'},
      );
      for (final t in cgTests) {
        _full(t.name, t.id);
        expect(t.measures, isNotEmpty, reason: t.id);
        expect(t.notes, isNotEmpty, reason: t.id);
        expect(cgTest(t.id), same(t));
        if (t.analyteId case final id?) {
          expect(coagAnalyteIds, contains(id), reason: t.id);
        }
      }
      for (final s in [...cgSampleSections, ...cgMonitoringSections]) {
        _full(s.title, 'section');
        expect(s.facts, isNotEmpty);
      }
      expect(cgPatternInfo.keys.toSet(), CgPattern.values.toSet());
      for (final MapEntry(key: k, value: v) in cgPatternInfo.entries) {
        _full(v.label, k.name);
        expect(v.causes, isNotEmpty, reason: k.name);
        expect(v.next, isNotEmpty, reason: k.name);
      }
      for (final s in CgSources.all) {
        expect(s.url, startsWith('https://'), reason: s.id);
        expect(s.citation.trim(), isNotEmpty, reason: s.id);
      }
      expect(
        {for (final s in CgSources.all) s.id}.length,
        CgSources.all.length,
      );
      // Har bir manba kamida bitta da'voda ishlatilgan.
      final used = {for (final r in cgRefsOf(cgAllFacts)) r.source.id};
      for (final s in CgSources.all) {
        expect(used, contains(s.id), reason: s.id);
      }
    });

    test('WFH lokatorlari bet bilan; DIC jadvali ikki manbada', () {
      for (final r in cgRefsOf(cgAllFacts)) {
        if (r.source == CgSources.wfhPart3 || r.source == CgSources.wfhPart5) {
          expect(r.locator, matches(RegExp(r'p\. \d')), reason: r.locator);
        }
      }
      for (final f in [cgDicPlatelets, cgDicFrm, cgDicPt, cgDicFib]) {
        final ids = {for (final r in f.refs) r.source.id};
        expect(ids, containsAll([CgSources.toh2016.id, CgSources.iba2019.id]));
      }
      // Ochiq DIC chegarasi matnda "≥ 5".
      for (final lang in _langs) {
        expect(cgDicOvert.text.of(lang), startsWith('≥ 5'));
        expect(cgDicNonOvert.text.of(lang), startsWith('< 5'));
      }
    });

    test('karta rasmi va bog‘liq taqdimot fayllari bor', () {
      final png = File(coagCardImage).readAsBytesSync();
      expect(png.sublist(1, 4), 'PNG'.codeUnits);
      for (final lang in _langs) {
        expect(
          File('assets/lectures/decks/$cgDeckId.$lang.json').existsSync(),
          true,
        );
      }
      final pack = File('assets/content/core/pack.json').readAsStringSync();
      for (final id in coagAnalyteIds) {
        expect(pack, contains('"id": "$id"'), reason: id);
      }
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('Lab kartasidan ochiladi, barcha ekranlar (${lang.name})', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(390, 2400));
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      final card = find.text(l.coagLabCardBody);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(CoagulogramScreen), findsOne);
      for (final id in coagAnalyteIds) {
        expect(find.byKey(ValueKey('coag-card-$id')), findsOne, reason: id);
      }
      expect(find.byKey(const ValueKey('coag-deck')), findsOne);
      for (final r in coagRoutes) {
        await goTo(tester, '$coagBase/$r');
        expect(tester.takeException(), isNull, reason: r);
        expect(find.text(CgL.draftNote.of(lang.name)), findsOne, reason: r);
      }
    });

    testWidgets('tor ekran 320 px × 1,3 matn (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(320, 8000), textScale: 1.3);
      for (final r in ['', for (final r in coagRoutes) '/$r']) {
        await goTo(tester, '$coagBase$r');
        expect(tester.takeException(), isNull, reason: r);
      }
      // Eng uzun holat: PT va APTT uzaygan, trombotsit kam.
      await goTo(tester, '$coagBase/reader');
      for (final k in ['coag-pt-long', 'coag-aptt-long', 'coag-plt-low']) {
        await tester.ensureVisible(find.byKey(ValueKey(k)));
        await tester.tap(find.byKey(ValueKey(k)));
        await tester.pumpAndSettle();
      }
      expect(find.byKey(const ValueKey('coag-pattern-both')), findsOne);
      expect(tester.takeException(), isNull);
      // DIC: to'liq natija.
      await goTo(tester, '$coagBase/dic');
      await tester.tap(find.byKey(const ValueKey('coag-dic-under-yes')));
      await tester.pumpAndSettle();
      await tester.enterText(field('coag-dic-plt'), '40');
      await tester.tap(find.byKey(const ValueKey('coag-dic-frm-strong')));
      await tester.enterText(field('coag-dic-pt'), '7');
      await tester.enterText(field('coag-dic-fib'), '0.8');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('coag-dic-result')), findsOne);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('DIC: asosiy kasallik yo‘q → hisoblanmaydi; 5 → ochiq DIC', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 3000));
    await goTo(tester, '$coagBase/dic');
    await tester.tap(find.byKey(const ValueKey('coag-dic-under-no')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coag-dic-na')), findsOne);
    expect(find.byKey(const ValueKey('coag-dic-plt')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('coag-dic-under-yes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coag-dic-empty')), findsOne);
    await tester.enterText(field('coag-dic-plt'), '80');
    await tester.tap(find.byKey(const ValueKey('coag-dic-frm-moderate')));
    await tester.enterText(field('coag-dic-pt'), '3');
    await tester.enterText(field('coag-dic-fib'), '0,9');
    await tester.pumpAndSettle();
    expect(find.text('${CgL.dicTotal.of('uz')}: 5'), findsOne);
    expect(find.byKey(const ValueKey('coag-dic-overt')), findsOne);
    await tester.enterText(field('coag-dic-fib'), '1');
    await tester.pumpAndSettle();
    expect(find.text('${CgL.dicTotal.of('uz')}: 4'), findsOne);
    expect(find.byKey(const ValueKey('coag-dic-nonovert')), findsOne);
    // Noto'g'ri son — natija yo'q, xato matni.
    await tester.enterText(field('coag-dic-pt'), 'abc');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coag-dic-result')), findsNothing);
    expect(find.text(CgL.invalidNumber.of('uz')), findsOne);
  });

  testWidgets('o‘qish yordamchisi: birikmalar va trombotsit izohi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 3000));
    await goTo(tester, '$coagBase/reader');
    expect(find.byKey(const ValueKey('coag-reader-empty')), findsOne);
    Future<void> tap(String k) async {
      await tester.tap(find.byKey(ValueKey(k)));
      await tester.pumpAndSettle();
    }

    await tap('coag-pt-long');
    expect(find.byKey(const ValueKey('coag-reader-empty')), findsOne);
    await tap('coag-aptt-normal');
    expect(find.byKey(const ValueKey('coag-pattern-ptOnly')), findsOne);
    await tap('coag-pt-normal');
    await tap('coag-aptt-long');
    expect(find.byKey(const ValueKey('coag-pattern-apttOnly')), findsOne);
    await tap('coag-aptt-normal');
    expect(find.byKey(const ValueKey('coag-pattern-normal')), findsOne);
    expect(find.byKey(const ValueKey('coag-plt-note-low')), findsNothing);
    await tap('coag-plt-low');
    expect(find.byKey(const ValueKey('coag-plt-note-low')), findsOne);
    expect(find.byKey(const ValueKey('coag-plt-note-pt')), findsNothing);
    await tap('coag-pt-long');
    expect(find.byKey(const ValueKey('coag-plt-note-pt')), findsOne);
    expect(find.byKey(const ValueKey('coag-reader-referral')), findsOne);
    await tester.ensureVisible(find.byKey(const ValueKey('coag-reader-dic')));
    await tap('coag-reader-dic');
    expect(find.byType(CgDicScreen), findsOne);
  });

  testWidgets('sitrat hisoblagichi: Ht 70 %, 4,5 ml → 0,25 ml', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '$coagBase/sample');
    await tester.enterText(field('coag-citrate-hct'), '70');
    await tester.pumpAndSettle();
    expect(find.text('${CgL.citrateResult.of('uz')}: 0,25'), findsOne);
    await tester.enterText(field('coag-citrate-hct'), '45');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coag-citrate-not-needed')), findsOne);
    await tester.enterText(field('coag-citrate-hct'), '120');
    await tester.pumpAndSettle();
    expect(find.text(CgL.invalidNumber.of('uz')), findsOne);
  });

  testWidgets('qidiruv: "koagulogramma" va "коагулограмма" → bo‘lim', (
    tester,
  ) async {
    for (final (q, lang) in [
      ('koagulogramma', AppLanguage.uz),
      ('коагулограмма', AppLanguage.ru),
      ('coagulogram', AppLanguage.en),
    ]) {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(390, 3200));
      await goTo(tester, '/home');
      await tester.tap(find.byType(HomeSearchField));
      await tester.pumpAndSettle();
      expect(find.byType(GlobalSearchScreen), findsOne);
      await tester.enterText(find.byType(TextField).first, q);
      await tester.pumpAndSettle();
      final l = lookupAppLocalizations(lang.locale);
      final section = kSearchSections.firstWhere((x) => x.id == 'coagulogram');
      expect(section.route, coagBase);
      final row = find.widgetWithText(LgRow, l.coagTitle);
      expect(row, findsWidgets, reason: q);
      await tester.tap(row.first);
      await tester.pumpAndSettle();
      expect(
        routerOf(tester).state.matchedLocation,
        startsWith(coagBase),
        reason: q,
      );
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('taqdimot havolasi deck pleyerini ochadi', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, coagBase);
    final deck = find.byKey(const ValueKey('coag-deck'));
    await tester.ensureVisible(deck);
    await tester.pumpAndSettle();
    await tester.tap(deck);
    // Pleyerda animatsiya bor — pumpAndSettle o'rniga bir necha kadr.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    final player = tester.widget<LectureScreen>(find.byType(LectureScreen));
    expect(player.deckId, cgDeckId);
    expect(tester.takeException(), isNull);
    await goTo(tester, coagBase);
  });

  test('manba lokatorlari sahifa formatini interfeys tiliga o‘giradi', () {
    for (final r in cgRefsOf(cgAllFacts)) {
      expect(localizePages(r.locator, (p) => '$p-bet'), isNotEmpty);
    }
  });
}
