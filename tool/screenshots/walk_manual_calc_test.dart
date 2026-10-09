// Qo'lda usul kalkulyatorlari va QC yo'riqnomalari — laborant sifatida
// (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_manual_calc_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/qc/qc_model.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/tools/manual_calc_screens.dart';
import 'package:labguide/features/tools/manual_calculators.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded).hitTestable().last);
  await tester.pumpAndSettle();
}

Finder _scrollable() => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

/// Maydonlarni yorliq bo'yicha to'ldiradi (ro'yxat dangasa quriladi —
/// indeks bo'yicha emas). Bo'sh qiymat — maydon tozalanadi.
Future<void> fill(
  WidgetTester tester,
  AppLocalizations l,
  List<(ManualField, String)> values,
) async {
  await tester.drag(_scrollable(), const Offset(0, 6000));
  await tester.pumpAndSettle();
  for (final (field, v) in values) {
    final name = manualFieldName(field, l);
    final f = find.byWidgetPredicate(
      (w) => w is LgField && w.label.startsWith(name),
    );
    await tester.scrollUntilVisible(f, 150, scrollable: _scrollable());
    await tester.enterText(
      find.descendant(of: f, matching: find.byType(TextField)),
      v,
    );
  }
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

/// Ro'yxat qatorini (dangasa quriladi) topib bosadi.
Future<void> open(Walk w, String text) async {
  final f = find.text(text);
  for (var i = 0; i < 30 && f.evaluate().isEmpty; i++) {
    await w.scroll(250);
  }
  await w.tap(f.last);
}

/// “Hisoblash” bosiladi va natija ko'rinadigan joyga suriladi.
Future<void> calculate(Walk w, AppLocalizations l) async {
  await open(w, l.dilCalculate);
  await w.tester.pumpAndSettle();
}

Future<void> walkAll(
  WidgetTester tester,
  Walk w,
  AppLocalizations l,
  String dec,
) async {
  await w.tapText(l.navLab);
  await open(w, l.featureCalculators);
  await w.scroll(700);
  await w.snap('kalkulyatorlar_royxati');

  // Hisob kamerasi.
  await open(w, l.mcChamber);
  await w.snap('kamera_bosh');
  await fill(tester, l, [
    (ManualField.cells, '188'),
    (ManualField.squares, '4'),
    (ManualField.dilution, '20'),
  ]);
  await calculate(w, l);
  await w.snap('kamera_natija');
  await w.scroll(900);
  await w.snap('kamera_formula_manba');
  await back(tester);

  // Leykoformula.
  await open(w, l.mcDiff);
  await fill(tester, l, [
    (ManualField.wbc, '16'),
    (ManualField.neutrophilsSeg, '56'),
    (ManualField.neutrophilsBand, '0'),
    (ManualField.eosinophils, '12'),
    (ManualField.basophils, '1'),
    (ManualField.lymphocytes, '30'),
    (ManualField.monocytes, '6'),
  ]);
  await calculate(w, l);
  await w.snap('leykoformula_yigindi_xato');
  await fill(tester, l, [
    (ManualField.lymphocytes, '25'),
    (ManualField.nrbc, '50'),
  ]);
  await calculate(w, l);
  await w.snap('leykoformula_natija');
  await back(tester);

  // Retikulotsitlar.
  await open(w, l.mcRetic);
  await fill(tester, l, [
    (ManualField.reticCounted, '60'),
    (ManualField.rbcExamined, '1000'),
    (ManualField.hematocrit, '25'),
    (ManualField.rbcCount, '2${dec}8'),
  ]);
  await calculate(w, l);
  await w.snap('retikulotsit_natija');
  await w.scroll(700);
  await w.snap('retikulotsit_cheklov');
  await back(tester);

  // Light.
  await open(w, l.mcLight);
  await fill(tester, l, [
    (ManualField.pfProtein, '40'),
    (ManualField.serumProtein, '70'),
    (ManualField.pfLdh, '100'),
    (ManualField.serumLdh, '300'),
  ]);
  await calculate(w, l);
  await w.snap('light_natija');
  await back(tester);

  // Rang ko'rsatkichi.
  await open(w, l.mcColour);
  await w.snap('rang_korsatkichi');
  await back(tester);
  await back(tester);

  // QC → yo'riqnomalar.
  await open(w, l.featureQc);
  await w.scroll(900);
  await w.snap('qc_yoriqnomalar');
  await open(w, l.qgRejected);
  await w.snap('qc_rad_bosh');
  await w.scroll(900);
  await w.snap('qc_rad_sabablar');
  await back(tester);
  await open(w, l.qgEqa);
  await w.snap('eqa_bosh');
  await w.scroll(1200);
  await w.snap('eqa_davomi');
  await back(tester);
  await open(w, l.qgCritical);
  await w.snap('kritik_bosh');
  await w.scroll(1200);
  await w.snap('kritik_davomi');
  await back(tester);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('laborant: qo‘lda usullar va QC yo‘riqnomalari (uz)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    await start(tester);
    await walkAll(tester, Walk(tester, 'manual_calc_uz'), l, ',');
  });

  testWidgets('laborant: ru, qorong‘i, katta shrift', (tester) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    await walkAll(tester, Walk(tester, 'manual_calc_ru_dark_large'), l, ',');
  });

  testWidgets('laborant: en + rad etilgan seriyadan yo‘riqnoma', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('en'));
    final s = await start(tester, lang: AppLanguage.en);
    final w = Walk(tester, 'manual_calc_en');
    await walkAll(tester, w, l, '.');
    final set = await s.qc.addSet(
      name: 'Glucose',
      unit: 'mmol/L',
      targetSource: QcTargetSource.laboratory,
      levels: [(label: '1', lot: '', mean: 5, sd: 0.2)],
    );
    await s.qc.addRun(set.id, {'L1': 5.8});
    await goTo(tester, '/lab/qc/set/${set.id}');
    await w.snap('qc_rad_etilgan_seriya');
    await open(w, l.qgWhatToDo);
    await w.snap('qc_rad_yoriqnoma');
  });
}
