// Lab tabi auditi (2026-10-18): "orqaga" foydalanuvchini kelgan joyiga
// qaytaradi (D-03).
//
// Topilgan xato: Lab bo'limlaridagi "Bog'liq kartalar" (leykoformula, qon
// morfologiyasi, siydik, koagulogramma, koprologiya, mikroskopiya atlasi)
// analit kartasini Tahlillar tabida (`/tests/analyte/<id>`) ochardi —
// "orqaga" bosilganda foydalanuvchi bo'limga emas, Tahlillar ro'yxatiga
// tushardi. D-03: analit kartasi har tab ichida ochiladi.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_screens.dart';
import 'package:labguide/features/content/ui/analyte_screen.dart';
import 'package:labguide/features/content/ui/content_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

String _loc(WidgetTester tester) => routerOf(tester).state.uri.toString();

/// Bo'lim sahifasidagi analit kartasi qatori (AnalyteRow/havola tugmasi).
const _sections = [
  '/lab/differential',
  '/lab/bloodmorph/retic',
  '/lab/urinalysis',
  '/lab/coagulogram',
  '/lab/coprology',
  '/lab/microscopy',
];

void main() {
  setUpAll(loadAppFonts);

  for (final lang in [AppLanguage.uz, AppLanguage.ru]) {
    for (final section in _sections) {
      testWidgets('${lang.name} $section: bog‘liq karta Lab ichida, '
          'orqaga — bo‘limga', (tester) async {
        final s = await makeServices(tester, language: lang);
        await pumpApp(tester, s, size: const Size(390, 4000));
        final l = lookupAppLocalizations(lang.locale);
        await goTo(tester, section);
        // Sahifadagi birinchi "Bog'liq karta" qatori.
        final link = find.byType(AnalyteRow);
        expect(link, findsWidgets, reason: section);
        await tester.ensureVisible(link.first);
        await tester.pumpAndSettle();
        await tester.tap(link.first);
        await tester.pumpAndSettle();
        expect(find.byType(AnalyteScreen), findsOneWidget);
        expect(_loc(tester), startsWith('/lab/analyte/'));
        await tester.tap(find.byTooltip(l.actionBack).hitTestable().first);
        await tester.pumpAndSettle();
        expect(_loc(tester), section);
      });
    }
  }

  testWidgets('protokol taqdimoti yopilganda — Lab bo‘limiga qaytadi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 2400));
    final l = lookupAppLocalizations(const Locale('uz'));
    final catalog = DeckCatalog.peek(rootBundle)!;
    for (final e in catalog.protocols) {
      await tester.runAsync(() => DeckCatalog.loadDeck(rootBundle, e, 'uz'));
    }
    for (final (section, key) in [
      ('/lab/coagulogram', 'coag-deck'),
      ('/lab/coprology', 'copro-deck-koprogramma-najas-tahlili'),
      ('/lab/coprology/collect', 'copro-deck-najas-parazitologik-tekshiruv'),
    ]) {
      await goTo(tester, section);
      final deck = find.byKey(ValueKey(key));
      await tester.ensureVisible(deck);
      await tester.pumpAndSettle();
      await tester.tap(deck);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LectureScreen), findsOneWidget);
      await tester.tap(find.byTooltip(l.lectureClose));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(_loc(tester), section);
    }
  });
}
