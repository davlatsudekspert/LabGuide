// Kitoblardan kelgan bloklar: preanalitika ekrani va siydik bo'yicha qo'lda
// usul kalkulyatorlari (Nechiporenko, Kakovskiy–Addis, Zimnitskiy).
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final en = AppLocalizationsEn();

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.hitTestable().first);
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, List<String> values) async {
  final fields = find.byType(TextField);
  for (var i = 0; i < values.length; i++) {
    await tester.enterText(fields.at(i), values[i]);
  }
  await tester.pump();
}

Future<void> _calculate(WidgetTester tester) =>
    _tap(tester, find.byType(LgButton).last);

const _zim = [
  '265', '1014', '230', '1012', '150', '1015', '115', '1018', //
  '115', '1023', '35', '1021', '60', '1018', '40', '1020', '1400',
];

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Nechiporenko: Aripova example, classic tag and textbook '
      'intervals panel', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3600));
    await goTo(tester, '/lab/calculators/nechiporenko');
    expect(find.text(en.mcClassicTag), findsOneWidget);
    expect(find.text(en.mcClassicTitle), findsOneWidget);
    expect(find.text(en.mcClassicNote), findsOneWidget);
    // Urine volume is prefilled with 10 ml.
    expect(find.text('10'), findsOneWidget);
    await _fill(tester, ['8', '2']);
    await _tap(tester, find.text(en.mfGoryaev100));
    await _tap(tester, find.text('1 ml'));
    await _calculate(tester);
    expect(find.text(en.mrPerMlUrine), findsOneWidget);
    expect(find.text('2,000'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    // Natija rang bilan baholanmaydi: ogohlantirish/xato bloki yo'q.
    expect(
      find.byWidgetPredicate((w) => w is LgNotice && w.kind != NoticeKind.info),
      findsNothing,
    );

    // Cho'kma ≥ siydik — tushunarli xato.
    await _fill(tester, ['8', '2', '', '1']);
    await _calculate(tester);
    expect(find.text(en.mErrSediment), findsOneWidget);
  });

  testWidgets('Kakovsky–Addis: 12-minute volume and daily count', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3600));
    await goTo(tester, '/lab/calculators/addis-kakovsky');
    await _fill(tester, ['600', '10', '9']);
    await _calculate(tester);
    expect(find.text('12 ml'), findsOneWidget);
    expect(find.text('600,000'), findsOneWidget);
  });

  testWidgets('Zimnitsky: Lyubina example 1', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 5200));
    await goTo(tester, '/lab/calculators/zimnitsky');
    await _fill(tester, _zim);
    await _calculate(tester);
    expect(find.text('1,010 ml'), findsOneWidget);
    expect(find.text('760 ml'), findsOneWidget);
    expect(find.text('250 ml'), findsOneWidget);
    expect(find.text('3.04 : 1'), findsOneWidget);
    expect(find.text('72 %'), findsOneWidget);
    expect(find.text('1.012 – 1.023'), findsOneWidget);
    expect(find.text('0.011'), findsOneWidget);
  });

  testWidgets('preanalytics: new blocks with sources', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 12000));
    await goTo(tester, '/lab/preanalytics');
    for (final t in [
      en.prePatientTitle,
      en.preMixTitle,
      en.preTubeForTestTitle,
      en.preStabilityTitle,
      en.preStorageTitle,
      en.preUrgentTitle,
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(
      find.textContaining('does not give a number of inversions'),
      findsOneWidget,
    );
    expect(find.textContaining('WHO/DIL/LAB/99.1 Rev.2'), findsOneWidget);
    expect(find.textContaining('Селиванов'), findsOneWidget);
    expect(find.text('ALT'), findsOneWidget);
    expect(find.text('20–25 °C (room) · 3 d'), findsOneWidget);
  });

  // Tor ekran, katta shrift, qorong'i mavzu — uch tilda.
  for (final lang in AppLanguage.values) {
    testWidgets('new screens lay out (${lang.name})', (tester) async {
      for (final (width, scale, theme) in [
        (320.0, 1.0, ThemeMode.light),
        (320.0, 2.0, ThemeMode.light),
        (390.0, 1.35, ThemeMode.dark),
      ]) {
        final s = await makeServices(tester, language: lang, themeMode: theme);
        await pumpApp(tester, s, size: Size(width, 6000), textScale: scale);
        for (final route in [
          '/lab/preanalytics',
          '/lab/calculators',
          '/lab/calculators/nechiporenko',
          '/lab/calculators/addis-kakovsky',
          '/lab/calculators/zimnitsky',
          '/tests/analyte/urine-chemistry',
          '/tests/analyte/urine-microscopy',
          '/tests/analyte/fecal-occult-blood',
          '/library/books',
          '/library/books/item/lib-book-aripova-2007',
          '/library/books/item/lib-book-sobirova-2006',
          '/library/sources',
        ]) {
          await goTo(tester, route);
          expect(
            tester.takeException(),
            isNull,
            reason: '$route $width ×$scale',
          );
        }
        // Natija bilan ham (uzun raqamlar).
        await goTo(tester, '/lab/calculators/zimnitsky');
        await _fill(tester, _zim);
        await _calculate(tester);
        expect(tester.takeException(), isNull);
        expect(
          find.text(lookupAppLocalizations(Locale(lang.name)).mrDiuresisTotal),
          findsWidgets,
        );
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
