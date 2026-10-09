// Umumklinik tekshiruvlar (najas va parazitologiya, biologik suyuqliklar,
// sutkalik siydik va ekma, sitologiya) — foydalanuvchi sifatida.
//
//   flutter test tool/screenshots/walk_general_clinical_test.dart --update-goldens
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

  testWidgets('najas va likvor — laborant (uz, yorug‘)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester);
    String name(String id) => s.content.pack!.analyte(id)!.names.of('uz');
    final w = Walk(tester, 'genclin_uz');
    await goTo(tester, '/tests');
    await w.tap(find.text('Najas va parazitologiya'));
    await w.snap('guruh_najas');
    await w.tapText(name('stool-analysis'));
    await w.snap('koprogramma_tepa');
    await scrollTo(tester, find.text(l.sectionResults));
    await w.scroll(250);
    await w.snap('koprogramma_natija');
    await w.scroll(700);
    await w.snap('koprogramma_natija_davomi');
    await scrollTo(tester, find.text(l.sectionInterference));
    await w.scroll(250);
    await w.snap('koprogramma_xalaqit');
    await scrollTo(tester, find.text(name('fecal-occult-blood')));
    await w.snap('koprogramma_boglik');
    await w.tapText(name('fecal-occult-blood'));
    await w.snap('yashirin_qon_tepa');
    await back(tester, l.actionBack);
    await w.snap('orqaga_koprogramma');
    await back(tester, l.actionBack);
    await w.tapText(name('stool-ova-parasites'));
    await w.snap('gijja_tepa');
    await scrollTo(tester, find.text(l.sectionPreanalytics));
    await w.scroll(250);
    await w.snap('gijja_namuna');
    await back(tester, l.actionBack);
    await w.tap(find.text('Biologik suyuqliklar va balg‘am'));
    await w.snap('guruh_suyuqliklar');
    await w.tapText(name('csf-analysis'));
    await w.snap('likvor_tepa');
    await scrollTo(tester, find.text(l.sectionResults));
    await w.scroll(250);
    await w.snap('likvor_meyorlar');
    await scrollTo(tester, find.text(l.analyteSources));
    await w.scroll(300);
    await w.snap('likvor_manbalar');
  });

  testWidgets('qidiruv va sil — shifokor (ru, qorong‘i, katta shrift)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
      role: AppRole.doctor,
    );
    String name(String id) => s.content.pack!.analyte(id)!.names.of('ru');
    final w = Walk(tester, 'genclin_ru_dark_large');
    await goTo(tester, '/tests');
    await tester.enterText(find.byType(TextField).first, 'мокрота');
    await w.snap('qidiruv_mokrota');
    await tester.enterText(find.byType(TextField).first, 'ликвор');
    await w.snap('qidiruv_likvor');
    await tester.enterText(find.byType(TextField).first, 'КУБ');
    await w.snap('qidiruv_kub');
    await w.tapText(name('sputum-afb'));
    await w.snap('sil_tepa');
    await scrollTo(tester, find.text(l.sectionPositiveResult));
    await w.scroll(250);
    await w.snap('sil_musbat');
    await scrollTo(tester, find.text(l.sectionPreanalytics));
    await w.scroll(250);
    await w.snap('sil_namuna');
    await back(tester, l.actionBack);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    await w.tap(find.text('Цитология и мазки'));
    await w.snap('guruh_sitologiya');
    await w.tapText(name('pap-test'));
    await w.snap('pap_tepa');
    await scrollTo(tester, find.text(l.sectionResults));
    await w.scroll(250);
    await w.snap('pap_bethesda');
    await w.scroll(600);
    await w.snap('pap_bethesda_davomi');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/pleural-fluid-analysis');
    await w.snap('plevra_tepa');
    await scrollTo(tester, find.text(l.sectionLimitations));
    await w.scroll(250);
    await w.snap('plevra_light');
  });

  testWidgets('kartalar va mashq — talaba (en)', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await start(tester, lang: AppLanguage.en, role: AppRole.student);
    final w = Walk(tester, 'genclin_en');
    await goTo(tester, '/tests/analyte/vaginal-wet-mount');
    await w.snap('wet_mount_top');
    await scrollTo(tester, find.text(l.sectionPositiveResult));
    await w.scroll(250);
    await w.snap('wet_mount_amsel');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/urine-24h');
    await w.snap('urine24_top');
    await scrollTo(tester, find.text(l.sectionPreanalytics));
    await w.scroll(250);
    await w.snap('urine24_collection');
    await goTo(tester, '/tests');
    await goTo(tester, '/tests/analyte/pinworm-test');
    await w.snap('pinworm_top');
    await scrollTo(tester, find.text(l.analytePractice));
    await w.snap('pinworm_practice_row');
    await w.tapText(l.analytePractice);
    await w.snap('pinworm_practice');
    await goTo(tester, '/learn/quiz');
    await scrollTo(tester, find.text('Cytology and smears'));
    await w.snap('quiz_topics_new_groups');
    await w.tapText('Body fluids and sputum');
    await w.snap('quiz_body_fluids');
  });
}
