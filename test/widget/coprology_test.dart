import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/classroom/lecture_screens.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/coprology/copro_content.dart';
import 'package:labguide/features/coprology/copro_scheme.dart';
import 'package:labguide/features/coprology/copro_screens.dart';
import 'package:labguide/features/home/global_search.dart';
import 'package:labguide/features/home/search_sections.dart';
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
  for (final lang in ['uz', 'en']) {
    expect(
      _cyrillic.hasMatch(t.values[lang]!),
      false,
      reason: '$reason $lang: ${t.values[lang]}',
    );
  }
  expect(_cyrillic.hasMatch(t.values['ru']!), true, reason: '$reason ru');
}

void _fact(CpFact f, String reason) {
  _full(f.text, reason);
  expect(f.refs, isNotEmpty, reason: reason);
  for (final r in f.refs) {
    expect(r.locator.trim(), isNotEmpty, reason: reason);
    expect(CpSources.all, contains(r.source), reason: reason);
  }
  // "Darslik" deb belgilangan da'vo darslikka tayanadi va aksincha.
  final textbook = f.refs.any((r) => r.source == CpSources.kurbonova2023);
  final marked =
      f.text.of('uz').contains('Darslik') ||
      f.text.of('uz').contains('darslik');
  if (marked) expect(textbook, true, reason: '$reason: Darslik → manba');
  if (textbook && f.refs.length == 1) {
    expect(marked, true, reason: '$reason: faqat darslik → "Darslik" belgisi');
    expect(f.text.of('ru').toLowerCase(), contains('учебник'), reason: reason);
    expect(f.text.of('en').toLowerCase(), contains('textbook'), reason: reason);
  }
}

void main() {
  setUpAll(loadAppFonts);

  group('kontent', () {
    test('har da’vo 3 tilda, manbasi va joyi bor', () {
      for (final t in CpL.all) {
        _full(t, 'CpL');
      }
      for (final f in cpAllFacts) {
        _fact(f, f.text.of('en'));
      }
      for (final s in [
        ...cpCollectSections,
        ...cpMacroSections,
        ...cpOccultSections,
      ]) {
        _full(s.title, 'section');
        expect(s.facts, isNotEmpty);
      }
      // Talab qilingan koprogramma elementlari.
      expect(
        {for (final e in cpElements) e.id},
        {
          'muscle',
          'connective',
          'fat',
          'starch',
          'leukocytes',
          'erythrocytes',
          'mucus',
        },
      );
      for (final e in cpElements) {
        _full(e.name, e.id);
        expect(e.look, isNotEmpty, reason: e.id);
        expect(e.meaning, isNotEmpty, reason: e.id);
        expect(cpElement(e.id), same(e));
      }
      // Talab qilingan parazitlar va DPDx + JSST manbalari.
      expect(
        {for (final p in cpParasites) p.id},
        {
          'ascaris',
          'enterobius',
          'hymenolepis',
          'giardia',
          'entamoeba',
          'trichuris',
          'taenia',
        },
      );
      for (final p in cpParasites) {
        _full(p.common, p.id);
        _full(p.stage, p.id);
        expect(cpParasite(p.id), same(p));
        final ids = {for (final r in p.refs) r.source.id};
        expect(ids, contains(CpSources.who2003.id), reason: p.id);
        expect(
          ids.where((id) => id.startsWith('dpdx-')),
          isNotEmpty,
          reason: p.id,
        );
        expect(p.size.ref.source.id, startsWith('dpdx-'), reason: p.id);
        expect(p.size.min, lessThan(p.size.max), reason: p.id);
        expect(p.size.max, lessThanOrEqualTo(80), reason: p.id);
        // Morfologiya matnida diagrammadagi oraliq bor.
        final look = p.look.map((f) => f.text.of('en')).join(' ');
        String n(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';
        expect(
          look,
          contains('${n(p.size.min)}–${n(p.size.max)}'),
          reason: p.id,
        );
        expect(coproAnalyteIds, contains(p.analyteId), reason: p.id);
      }
      expect(
        {for (final p in cpParasites) p.shape}.length,
        CpShape.values.length,
      );
      for (final s in CpSources.all) {
        if (s.url case final url?) {
          expect(url, startsWith('https://'), reason: s.id);
        }
        expect(s.citation.trim(), isNotEmpty, reason: s.id);
      }
      expect(
        {for (final s in CpSources.all) s.id}.length,
        CpSources.all.length,
      );
      final used = {for (final r in cpRefsOf(cpAllFacts)) r.source.id};
      for (final s in CpSources.all) {
        expect(used, contains(s.id), reason: s.id);
      }
    });

    test('JSST va darslik lokatorlari bet bilan', () {
      for (final r in cpRefsOf(cpAllFacts)) {
        if (r.source == CpSources.who2003) {
          expect(r.locator, matches(RegExp(r'p\. \d')), reason: r.locator);
          expect(localizePages(r.locator, (p) => '$p-bet'), contains('-bet'));
        }
        if (r.source == CpSources.kurbonova2023) {
          // Bet raqami interfeys tiliga o'giriladigan shaklda (Lab auditi
          // 2026-10-18: ru/en da o'zbekcha "46-b." qolardi).
          expect(
            r.locator,
            matches(RegExp(r'p\. \d+(–\d+)?$')),
            reason: r.locator,
          );
          expect(localizePages(r.locator, (p) => '$p-bet'), contains('-bet'));
          expect(localizePages(r.locator, (p) => 'с. $p'), contains('с. '));
        }
      }
    });

    test('karta rasmi, taqdimotlar va pack kartalari bor', () {
      final png = File(coproCardImage).readAsBytesSync();
      expect(png.sublist(1, 4), 'PNG'.codeUnits);
      for (final d in cpDecks) {
        _full(d.title, d.id);
        for (final lang in _langs) {
          expect(
            File('assets/lectures/decks/${d.id}.$lang.json').existsSync(),
            true,
            reason: d.id,
          );
        }
      }
      final pack = File('assets/content/core/pack.json').readAsStringSync();
      for (final id in coproAnalyteIds) {
        expect(pack, contains('"id": "$id"'), reason: id);
      }
    });
  });

  for (final lang in AppLanguage.values) {
    testWidgets('Lab kartasidan ochiladi, barcha ekranlar (${lang.name})', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(390, 2600));
      final l = lookupAppLocalizations(Locale(lang.name));
      await goTo(tester, '/lab');
      final card = find.text(l.coproLabCardBody);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byType(CoprologyScreen), findsOne);
      for (final id in coproAnalyteIds) {
        expect(find.byKey(ValueKey('copro-card-$id')), findsOne, reason: id);
      }
      for (final d in cpDecks) {
        expect(find.byKey(ValueKey('copro-deck-${d.id}')), findsOne);
      }
      for (final r in coproRoutes) {
        await goTo(tester, '$coproBase/$r');
        expect(tester.takeException(), isNull, reason: r);
        expect(find.text(CpL.textbookNote.of(lang.name)), findsOne, reason: r);
      }
      for (final e in cpElements) {
        await goTo(tester, cpElementRoute(e.id));
        expect(find.text(e.name.of(lang.name)), findsWidgets, reason: e.id);
        expect(tester.takeException(), isNull, reason: e.id);
      }
      for (final p in cpParasites) {
        await goTo(tester, cpParasiteRoute(p.id));
        expect(find.byKey(ValueKey('copro-scheme-${p.id}')), findsOne);
        expect(find.text(CpL.schemeLabel.of(lang.name)), findsOne);
        expect(tester.takeException(), isNull, reason: p.id);
      }
      await goTo(tester, '$coproBase/micro/unknown');
      await goTo(tester, '$coproBase/parasites/unknown');
      expect(tester.takeException(), isNull);
    });

    testWidgets('tor ekran 320 px × 1,3 matn (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(320, 9000), textScale: 1.3);
      for (final r in [
        '',
        for (final r in coproRoutes) '/$r',
        for (final e in cpElements) '/micro/${e.id}',
        for (final p in cpParasites) '/parasites/${p.id}',
      ]) {
        await goTo(tester, '$coproBase$r');
        expect(tester.takeException(), isNull, reason: r);
      }
      // Lab: rasmli karta tor ekranda ham sig'adi.
      await goTo(tester, '/lab');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('parazitlar ro‘yxati: sxema, o‘lcham diagrammasi, karta', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '$coproBase/parasites');
    expect(find.byType(CpSchematic), findsNWidgets(cpParasites.length));
    expect(find.byKey(const ValueKey('copro-size-chart')), findsOne);
    await tester.tap(find.byKey(const ValueKey('copro-par-giardia')));
    await tester.pumpAndSettle();
    expect(find.byType(CpParasiteScreen), findsOne);
    expect(find.text('Giardia duodenalis (G. intestinalis)'), findsWidgets);
    await goTo(tester, cpParasiteRoute('enterobius'));
    final deck = find.byKey(
      const ValueKey('copro-deck-perianal-namuna-ostritsa'),
    );
    await tester.ensureVisible(deck);
    await tester.pumpAndSettle();
    await tester.tap(deck);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    final player = tester.widget<LectureScreen>(find.byType(LectureScreen));
    expect(player.deckId, 'perianal-namuna-ostritsa');
    await goTo(tester, coproBase);
    expect(tester.takeException(), isNull);
  });

  testWidgets('qidiruv: koprogramma / анализ кала / stool analysis', (
    tester,
  ) async {
    for (final (q, lang) in [
      ('koprogramma', AppLanguage.uz),
      ('анализ кала', AppLanguage.ru),
      ('stool analysis', AppLanguage.en),
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
      final section = kSearchSections.firstWhere((x) => x.id == 'coprology');
      expect(section.route, coproBase);
      final row = find.widgetWithText(LgRow, l.coproTitle);
      expect(row, findsWidgets, reason: q);
      await tester.tap(row.first);
      await tester.pumpAndSettle();
      expect(
        routerOf(tester).state.matchedLocation,
        startsWith(coproBase),
        reason: q,
      );
      await tester.pumpWidget(const SizedBox());
    }
  });
}
