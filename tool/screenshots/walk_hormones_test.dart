// Gormon tahlillari — shifokor va talaba sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_hormones_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

String name(AppServices s, String id, String lang) =>
    s.content.pack!.analyte(id)!.names.of(lang);

String group(AppServices s, String lang) =>
    s.content.pack!.group('endocrine')!.names.of(lang);

/// Yuqori paneldagi "orqaga" tugmasi.
Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded).hitTestable().last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('shifokor: Tahlillar → Gormonlar → TSH → FT4 → kortizol (uz)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester, role: AppRole.doctor);
    final w = Walk(tester, 'hormones_doctor_uz');
    await w.tapText(l.navTests);
    await w.snap('tahlillar');
    await w.tap(find.text(group(s, 'uz')).last);
    await w.scroll(-800);
    await w.snap('gormonlar_guruhi');
    await w.tap(find.text(name(s, 'tsh', 'uz')).last);
    await w.snap('tsh_tepa');
    await w.scroll(650);
    await w.snap('tsh_maqsad_fiziologiya');
    await w.scroll(900);
    await w.snap('tsh_natijalar');
    await w.scroll(900);
    await w.snap('tsh_preanalitika_interferensiya');
    await w.scroll(900);
    await w.snap('tsh_boglik');
    // Bog'liq karta: erkin T4.
    await w.tap(find.text(name(s, 'ft4', 'uz')).last);
    await w.snap('ft4_tepa');
    await w.scroll(1400);
    await w.snap('ft4_natijalar');
    await back(tester);
    await w.snap('tsh_ga_qaytish');
    await w.tap(find.text(l.analytePractice).last);
    await w.snap('tsh_mashq');
    await back(tester);
    await w.scroll(900);
    await w.snap('tsh_manbalar');
    await back(tester);
    await w.snap('gormonlar_royxatiga_qaytish');
    await w.tap(find.text(name(s, 'cortisol', 'uz')).last);
    await w.snap('kortizol_tepa');
    await w.scroll(1500);
    await w.snap('kortizol_namuna');
    await w.scroll(1500);
    await w.snap('kortizol_natijalar');
    await w.scroll(3000);
    await w.snap('kortizol_manbalar');
  });

  testWidgets('talaba: qidiruv “ТТГ” — ru, qorong‘i, katta shrift', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
      role: AppRole.student,
    );
    final w = Walk(tester, 'hormones_student_ru_dark_large');
    await w.tapText(l.navTests);
    await tester.enterText(find.byType(TextField).first, 'ТТГ');
    await w.snap('qidiruv_ttg');
    await w.tap(find.text(name(s, 'tsh', 'ru')).last);
    await w.snap('tsh_tepa');
    await w.scroll(900);
    await w.snap('tsh_davomi');
    await back(tester);
    await tester.enterText(find.byType(TextField).first, 'щитовидная');
    await w.snap('qidiruv_shchitovidnaya');
    await tester.enterText(find.byType(TextField).first, 'ХГЧ');
    await w.snap('qidiruv_hgch');
    await w.tap(find.text(name(s, 'hcg', 'ru')).last);
    await w.snap('hcg_tepa');
    await w.scroll(1200);
    await w.snap('hcg_natijalar');
    await goTo(tester, '/learn/quiz');
    await w.snap('mashq_mavzular');
    await w.tap(find.text(group(s, 'ru')).last);
    await w.snap('mashq_gormonlar');
  });

  testWidgets('hormones — en', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    final s = await start(tester, lang: AppLanguage.en, role: AppRole.lab);
    final w = Walk(tester, 'hormones_en');
    await w.tapText(l.navTests);
    await w.tap(find.text(group(s, 'en')).last);
    await w.scroll(-800);
    await w.snap('hormones_group');
    await w.scroll(900);
    await w.snap('hormones_group_more');
    await w.scroll(-3000);
    await tester.enterText(find.byType(TextField).first, 'prolactin');
    await w.snap('search_prolactin');
    await w.tap(find.text(name(s, 'prolactin', 'en')).last);
    await w.snap('prolactin_top');
    await w.scroll(1100);
    await w.snap('prolactin_preanalytics');
    await goTo(tester, '/tests/analyte/vitamin-d');
    await w.snap('vitamin_d_top');
    await w.scroll(2200);
    await w.snap('vitamin_d_results');
  });
}
