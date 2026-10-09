import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/qc/qc_guides_info.dart';
import 'package:labguide/features/qc/qc_model.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/manual_calc_info.dart';
import 'package:labguide/features/tools/manual_calc_screens.dart';
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

/// Har kalkulyator uchun to'g'ri namunaviy kirish (o'nlik — nuqta, 3 tilda
/// ham o'qiladi).
const _samples = <ManualCalc, List<String>>{
  ManualCalc.chamber: ['188', '4', '20'],
  ManualCalc.differential: ['16', '56', '0', '12', '1', '25', '6', '', '50'],
  ManualCalc.reticulocytes: ['60', '1000', '25', '2.8'],
  ManualCalc.light: ['40', '70', '100', '300', '250'],
};

void main() {
  setUpAll(loadAppFonts);

  testWidgets('calculators list opens every manual-method screen', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    // Zimnitskiy sahifasi uzun (17 maydon) — manbalar ham qurilsin.
    await pumpApp(tester, s, size: const Size(390, 7000));
    await goTo(tester, '/lab/calculators');
    expect(find.text(en.calcSectionManual), findsOneWidget);
    for (final c in ManualCalc.values) {
      await _tap(tester, find.text(manualCalcTitle(c, en)));
      expect(find.text(manualCalcSubtitle(c, en)), findsWidgets);
      for (final r in manualCalcInfo[c]!.refs) {
        expect(find.textContaining(r.source.citation), findsOneWidget);
      }
      await goTo(tester, '/lab/calculators');
    }
  });

  testWidgets('chamber: WHO example gives 9.4 ×10⁹/L; bad input explained', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '/lab/calculators/chamber');
    await _fill(tester, ['188', '4', '20']);
    await _calculate(tester);
    expect(find.text('9,400 ${en.mrCellsPerUl}'), findsOneWidget);
    expect(find.text('9.4'), findsOneWidget);

    // Kasr hujayra soni — butun son talab qilinadi.
    await _fill(tester, ['18.5', '4', '20']);
    await _calculate(tester);
    expect(find.text(en.mErrWhole(en.mfCells, '0', '100,000')), findsOneWidget);

    // Kichik kvadrat va 0,2 mm chuqurlik tanlanadi.
    await _fill(tester, ['50', '80', '200']);
    await _tap(tester, find.textContaining('1/400 mm²'));
    await _calculate(tester);
    // 50 ÷ (80 × 0,0025 × 0,1) × 200 = 500 000 / µL.
    expect(find.text('500,000 ${en.mrCellsPerUl}'), findsOneWidget);
    // Tanlov o'zgarsa eski natija yo'qoladi.
    await _tap(tester, find.text('0.2 mm'));
    expect(find.byType(LgPanel), findsNothing);
  });

  testWidgets('differential: sum check and NRBC correction', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/lab/calculators/differential');
    await _fill(tester, ['16', '56', '0', '12', '1', '30', '6']);
    await _calculate(tester);
    expect(find.text(en.mErrSum('105')), findsOneWidget);

    await _fill(tester, ['16', '56', '0', '12', '1', '25', '6', '', '50']);
    await _calculate(tester);
    expect(find.text(en.mrWbcUsed), findsOneWidget);
    expect(find.text('10.67 ×10⁹/L'), findsOneWidget);
    expect(find.text('5.33 ×10⁹/L'), findsOneWidget);
    // Limfotsitlar: 25 % × 10,67.
    expect(find.text('2.67 ×10⁹/L'), findsOneWidget);
  });

  testWidgets('reticulocytes: auto factor is labelled, manual choice wins', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3600));
    await goTo(tester, '/lab/calculators/reticulocytes');
    await _fill(tester, ['60', '1000', '25', '2.8']);
    await _calculate(tester);
    expect(find.text('6 %'), findsOneWidget);
    expect(find.text('3.33 %'), findsOneWidget);
    expect(find.text('1.67'), findsOneWidget);
    expect(find.text('168 ×10⁹/L'), findsOneWidget);
    expect(find.text(en.mrMaturationAuto('2.0', '25')), findsOneWidget);

    await _tap(tester, find.text('2.5 · Ht 20 %'));
    await _calculate(tester);
    expect(find.text('1.33'), findsOneWidget);
    expect(find.text(en.mrMaturationChosen('2.5')), findsOneWidget);

    await _fill(tester, ['600', '500', '25', '']);
    await _calculate(tester);
    expect(find.text(en.mErrReticGtExamined), findsOneWidget);
  });

  testWidgets('Light: exudate, and incomplete without the LDH limit', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '/lab/calculators/light');
    await _fill(tester, ['40', '70', '100', '300', '']);
    await _calculate(tester);
    expect(find.text(en.mrExudate), findsOneWidget);
    expect(find.text('0.57 · ${en.mrMet}'), findsOneWidget);
    expect(find.text(en.mrNotAssessed), findsOneWidget);

    await _fill(tester, ['20', '70', '100', '300', '']);
    await _calculate(tester);
    expect(find.text(en.mrIncomplete), findsOneWidget);

    await _fill(tester, ['20', '70', '100', '300', '250']);
    await _calculate(tester);
    expect(find.text(en.mrTransudate), findsOneWidget);
  });

  testWidgets('colour index: explained, not calculated', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/lab/calculators/colour-index');
    expect(find.text(en.ciWhy), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('QC guides open from the QC screen and from a rejected run', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s, size: const Size(390, 3600));
    await goTo(tester, '/lab/qc');
    expect(find.text(en.qcGuidesTitle), findsOneWidget);
    for (final g in QcGuide.values) {
      await goTo(tester, '/lab/qc');
      await _tap(
        tester,
        find.text(switch (g) {
          QcGuide.rejected => en.qgRejected,
          QcGuide.eqa => en.qgEqa,
          QcGuide.critical => en.qgCritical,
        }),
      );
      final c = qcGuides[g]!;
      expect(find.text(c.intro.of('en')), findsOneWidget);
      expect(find.text(c.notice.of('en')), findsOneWidget);
      for (final r in c.refs) {
        expect(find.textContaining(r.source.citation), findsOneWidget);
      }
    }

    // Rad etilgan seriyadan “Nima qilish kerak?” tugmasi.
    final set = await s.qc.addSet(
      name: 'Glucose',
      unit: 'mmol/L',
      targetSource: QcTargetSource.laboratory,
      levels: [(label: '1', lot: '', mean: 5, sd: 0.2)],
    );
    await s.qc.addRun(set.id, {'L1': 5.8});
    await goTo(tester, '/lab/qc/set/${set.id}');
    expect(find.text(en.qcReject), findsWidgets);
    await _tap(tester, find.text(en.qgWhatToDo));
    expect(
      find.text(qcGuides[QcGuide.rejected]!.intro.of('en')),
      findsOneWidget,
    );
  });

  for (final lang in AppLanguage.values) {
    testWidgets('manual calculators lay out at 320 px ×2.0 (${lang.name})', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      await pumpApp(tester, s, size: const Size(320, 6000), textScale: 2);
      for (final c in _samples.keys) {
        await goTo(tester, '/lab/calculators/${manualCalcRoute(c)}');
        await _fill(tester, _samples[c]!);
        await _calculate(tester);
        expect(tester.takeException(), isNull, reason: c.name);
        expect(find.byType(LgPanel), findsOneWidget, reason: c.name);
      }
      for (final g in QcGuide.values) {
        await goTo(tester, '/lab/qc/${qcGuideRoute(g)}');
        expect(tester.takeException(), isNull, reason: g.name);
      }
      await goTo(tester, '/lab/calculators/colour-index');
      expect(tester.takeException(), isNull);
      expect(
        find.text(lookupAppLocalizations(Locale(lang.name)).mcColour),
        findsWidgets,
      );
    });
  }
}
