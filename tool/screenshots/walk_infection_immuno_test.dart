// Infeksiya serologiyasi, autoimmun testlar va o'sma markerlari —
// foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_infection_immuno_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

final _vertical = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

/// Ro'yxatda pastdagi (hali chizilmagan) elementgacha aylantirish.
Future<void> scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 300, scrollable: _vertical.first);
  await tester.pumpAndSettle();
}

/// Sahifa tepasidagi “Orqaga” tugmasini bosish (foydalanuvchi kabi).
Future<void> back(WidgetTester tester, String tooltip) async {
  await tester.tap(find.byTooltip(tooltip).hitTestable().first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('serologiya va o‘sma markerlari — shifokor (uz, yorug‘)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester, role: AppRole.doctor);
    String name(String id) => s.content.pack!.analyte(id)!.names.of('uz');
    final w = Walk(tester, 'infimm_uz');
    await goTo(tester, '/tests');
    await w.snap('tahlillar');
    await w.tap(find.text('Infeksiyalar (serologiya)'));
    await w.snap('guruh_infeksiyalar');
    await w.tapText(name('hbsag'));
    await w.snap('hbsag_tepa');
    await w.scroll(650);
    await w.snap('hbsag_maqsad');
    await scrollTo(tester, find.text(l.sectionPositiveResult));
    await w.scroll(250);
    await w.snap('hbsag_musbat');
    await scrollTo(tester, find.text(l.sectionNegativeResult));
    await w.scroll(250);
    await w.snap('hbsag_manfiy');
    await scrollTo(tester, find.text(l.sectionLimitations));
    await w.scroll(500);
    await w.snap('hbsag_cheklovlar_maxfiylik');
    await scrollTo(tester, find.text(name('anti-hcv')));
    await w.snap('hbsag_boglik');
    await w.tapText(name('anti-hcv'));
    await w.snap('anti_hcv_tepa');
    await scrollTo(tester, find.text(l.analyteSources));
    await w.scroll(200);
    await w.snap('anti_hcv_manbalar');
    await back(tester, l.actionBack);
    await w.snap('orqaga_hbsag');
    await back(tester, l.actionBack);
    await w.snap('orqaga_royxat');
    // O'sma markerlari guruhi (chiplar gorizontal aylanadi).
    await w.tap(find.text('O‘sma markerlari'));
    await w.snap('guruh_osma');
    await w.tapText(name('psa'));
    await w.snap('psa_tepa');
    await scrollTo(tester, find.text(l.sectionLimitations));
    await w.scroll(300);
    await w.snap('psa_cheklovlar');
    await w.scroll(700);
    await w.snap('psa_cheklovlar_davomi');
    await scrollTo(tester, find.text(l.analytePractice));
    await w.snap('psa_mashq_qatori');
    await w.tapText(l.analytePractice);
    await w.snap('psa_mashq');
  });

  testWidgets('qidiruv va autoimmun — laborant (ru, qorong‘i, katta shrift)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    String name(String id) => s.content.pack!.analyte(id)!.names.of('ru');
    final w = Walk(tester, 'infimm_ru_dark_large');
    await goTo(tester, '/tests');
    await tester.enterText(find.byType(TextField).first, 'онкомаркер');
    await w.snap('qidiruv_onkomarker');
    await tester.enterText(find.byType(TextField).first, 'АСЛО');
    await w.snap('qidiruv_aslo');
    await w.tapText(name('aso'));
    await w.snap('aso_tepa');
    await w.scroll(700);
    await w.snap('aso_maqsad');
    await scrollTo(tester, find.text(l.sectionLimitations));
    await w.scroll(400);
    await w.snap('aso_cheklovlar');
    await scrollTo(tester, find.text(l.analyteSources));
    await w.scroll(300);
    await w.snap('aso_manbalar_voz');
    await back(tester, l.actionBack);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    await w.tap(find.text('Аутоиммунные и ревмотесты'));
    await w.snap('guruh_autoimmun');
    await scrollTo(tester, find.text(name('anti-ccp')));
    await w.tapText(name('anti-ccp'));
    await w.snap('accp_tepa');
    await scrollTo(tester, find.text(l.sectionPositiveResult));
    await w.scroll(200);
    await w.snap('accp_natijalar');
    await goTo(tester, '/tests/analyte/hiv-test');
    await w.snap('oiv_tepa');
    await scrollTo(tester, find.text(l.sectionNegativeResult));
    await w.scroll(250);
    await w.snap('oiv_oyna_davri');
  });

  testWidgets('kartalar — talaba (en)', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(tester, lang: AppLanguage.en, role: AppRole.student);
    final w = Walk(tester, 'infimm_en');
    await goTo(tester, '/tests/analyte/syphilis-tests');
    await w.snap('syphilis_top');
    await scrollTo(tester, find.text(l.sectionPositiveResult));
    await w.scroll(250);
    await w.snap('syphilis_positive');
    await goTo(tester, '/tests/analyte/procalcitonin');
    await w.snap('procalcitonin_top');
    await scrollTo(tester, find.text(l.sectionLimitations));
    await w.scroll(200);
    await w.snap('procalcitonin_limits_note');
    await goTo(tester, '/tests/analyte/ca-19-9');
    await w.snap('ca199_top');
    await goTo(tester, '/learn/quiz');
    await scrollTo(tester, find.text('Tumor markers'));
    await w.snap('quiz_topics_new_groups');
    await w.tapText('Infections (serology)');
    await w.snap('quiz_infections');
  });
}
