// Apparatlar va kalibrlash — foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walkthrough_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('apparatlar va kalibrlash — laboratoriya mutaxassisi (uz)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester);
    final w = Walk(tester, 'lab_uz');
    await goTo(tester, '/lab');
    await w.snap('lab');
    await w.tapText(l.labInstruments);
    await w.snap('apparatlar');
    await w.tapText('Biokimyo');
    await w.snap('biokimyo_ishlab_chiqaruvchi');
    await w.tapText('HUMAN');
    await w.snap('human_modellar');
    await w.tapText('HumaLyzer 4000');
    await w.snap('karta_tepa');
    await w.scroll(600);
    await w.snap('karta_vazifa');
    await w.scroll(700);
    await w.snap('karta_faktlar');
    await w.scroll(900);
    await w.snap('karta_parvarish');
    await w.scroll(900);
    await w.snap('karta_manbalar');
    await w.scroll(-5000);
    await w.tapText(l.instSaveMine);
    await w.snap('saqlash_oynasi');
    await w.enter(l.instLabel, '1-xona');
    await w.enter(l.instManualVersion, 'v2.1');
    await w.tapText(l.instSave);
    await w.snap('saqlandi');
    await w.tapText(l.instCalibrate);
    await w.snap('kalibrlash_boshi');
    await tester.enterText(find.byType(TextField).first, 'glyu');
    await w.snap('analit_qidiruv');
    final glucose = s.content.pack!
        .analyte('glucose-plasma-fasting')!
        .names
        .of('uz');
    await w.tapText(glucose);
    await w.snap('analit_tanlandi');
    await w.enter(l.calReagentRef, '10121');
    await w.enter(l.calIfuRevision, '2024-01');
    await w.snap('reagent_kiritildi');
    await w.tapText(l.calShowGuide);
    await w.snap('yoriqnoma');
    await w.scroll(500);
    await w.snap('yoriqnoma_hujjatlar');
    await w.tapText(l.calRecordCreate);
    await w.snap('yozuv_formasi');
    await w.enter(l.calCalibratorLot, 'L-77');
    await w.enter(l.calLevelValue, '5,55');
    await w.enter(l.calLevelUnit, 'mmol/L');
    await w.snap('yozuv_toldirildi');
    await w.tapText(l.calRecordSave);
    await w.snap('yozuv_saqlandi');
    await w.tap(find.widgetWithText(SnackBarAction, l.calLog));
    await w.snap('jurnal');
    await w.tap(find.textContaining('L-77'));
    await w.snap('yozuv_tafsiloti');
    await goTo(tester, '/lab/instruments');
    await w.snap('apparatlar_saqlangan_bilan');
  });

  testWidgets('apparat kartasi va kalibrlash — ru, qorong‘i, katta shrift', (
    tester,
  ) async {
    await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    final w = Walk(tester, 'lab_ru_dark_large');
    await goTo(tester, '/lab/instruments');
    await w.snap('apparatlar');
    await tester.enterText(find.byType(TextField).first, 'моча');
    await w.snap('qidiruv_mocha');
    await goTo(tester, '/lab/instruments/m/roche-cobas-u-411');
    await w.snap('karta');
    await goTo(
      tester,
      '/lab/calibration?model=roche-cobas-c-311&analyte=creatinine',
    );
    await w.snap('kalibrlash');
  });

  testWidgets('apparatlar — en', (tester) async {
    await start(tester, lang: AppLanguage.en);
    final w = Walk(tester, 'lab_en');
    await goTo(tester, '/lab/instruments/c/hematology');
    await w.snap('hematology_makers');
    await goTo(tester, '/lab/instruments/m/abbott-alinity-hq');
    await w.snap('alinity_hq');
  });
}
