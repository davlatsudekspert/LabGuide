// Shifokor qo'llanmasi “Kasallik bo'yicha tahlillar” — foydalanuvchi
// sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_conditions_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('shifokor (uz, yorug‘): bosh sahifa → diabet → HbA1c', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    await start(tester, role: AppRole.doctor);
    final w = Walk(tester, 'conditions_doctor_uz');
    await w.snap('bosh_sahifa');
    await w.scroll(450);
    await w.snap('bosh_sahifa_karta_pasti');
    await w.tapText(l.condGuideAll);
    await w.snap('royxat');
    await w.scroll(700);
    await w.snap('royxat_pastroq');
    await w.scroll(-5000);
    await w.tapText('2-tip qandli diabet');
    await w.snap('diabet_tepa');
    await w.scroll(600);
    await w.snap('diabet_birinchi_navbat');
    await w.scroll(700);
    await w.snap('diabet_kuzatuv');
    await w.scroll(700);
    await w.snap('diabet_naqshlar');
    await w.scroll(800);
    await w.snap('diabet_ehtiyot_nusxa');
    await w.tapText(l.condCopyList);
    await w.snap('nusxalandi');
    await w.scroll(900);
    await w.snap('diabet_manbalar');
    await w.scroll(-8000);
    await w.tap(find.text('HbA1c (glikirlangan gemoglobin)').first);
    await w.snap('hba1c_karta');
    await tester.scrollUntilVisible(
      find.text(l.condAnalyteSection),
      300,
      scrollable: find
          .byWidgetPredicate(
            (x) => x is Scrollable && x.axisDirection == AxisDirection.down,
          )
          .hitTestable()
          .first,
    );
    await w.snap('hba1c_qaysi_holatlarda');
    await w.tap(find.byTooltip(l.actionBack).hitTestable().first);
    await w.snap('orqaga_diabet');
    await w.tap(find.byTooltip(l.actionBack).hitTestable().first);
    await w.tap(find.byTooltip(l.actionBack).hitTestable().first);
    await w.tap(find.text('Gipotireoz (qalqonsimon bez faoliyati pasayishi)').first);
    await w.snap('gipotireoz');
    await w.scroll(900);
    await w.snap('gipotireoz_pastroq');
  });

  testWidgets('talaba (ru, qorong‘i, katta shrift): Tahlillar → qidiruv', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
      role: AppRole.student,
    );
    final w = Walk(tester, 'conditions_student_ru_dark_large');
    await goTo(tester, '/tests');
    await w.snap('tahlillar_kirish');
    await tester.enterText(find.byType(TextField).first, 'диабет');
    await w.snap('qidiruv_diabet');
    await w.tapText(l.condGuideTitle);
    await w.snap('royxat');
    await tester.enterText(find.byType(TextField).first, 'щитовид');
    await w.snap('qidiruv_shchitovid');
    await w.tapText('Гипертиреоз (повышенная функция щитовидной железы)');
    await w.snap('gipertireoz');
    await w.scroll(900);
    await w.snap('gipertireoz_pastroq');
    await w.scroll(900);
    await w.snap('gipertireoz_naqshlar');
    await goTo(tester, '/tests/conditions/iron-deficiency-anemia');
    await w.snap('anemiya');
    await w.scroll(1200);
    await w.snap('anemiya_pastroq');
  });

  testWidgets('en: system filter, hepatitis B, PSA', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(tester, lang: AppLanguage.en, role: AppRole.doctor);
    final w = Walk(tester, 'conditions_en');
    await goTo(tester, '/tests/conditions');
    await w.tap(find.text(l.condSysLiver).first);
    await w.snap('filter_liver');
    await w.tap(find.text('Viral hepatitis B').first);
    await w.snap('hepatitis_b');
    await w.scroll(1200);
    await w.snap('hepatitis_b_patterns');
    await goTo(tester, '/tests/conditions/prostate-psa');
    await w.snap('psa');
    await w.scroll(1000);
    await w.snap('psa_cautions');
  });
}
