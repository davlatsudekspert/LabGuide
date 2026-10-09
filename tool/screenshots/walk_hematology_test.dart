// Gematologiya va koagulyatsiya kartalari — foydalanuvchi sifatida
// (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_hematology_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

/// Dangasa ro'yxatda [text] paydo bo'lguncha pastga aylantirib, bosadi.
Future<void> scrollAndTap(Walk w, String text, {double step = 400}) async {
  for (var i = 0; i < 60 && find.text(text).evaluate().isEmpty; i++) {
    await w.scroll(step);
  }
  await w.tap(find.text(text).last);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Tahlillar → gematologiya → karta → bog‘liq karta (uz, lab)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester);
    final pack = s.content.pack!;
    String name(String id) => pack.analyte(id)!.names.of('uz');
    final w = Walk(tester, 'hematology_uz');

    await w.tapText(l.navTests);
    await w.snap('tahlillar');
    await w.tap(find.text(pack.group('hematology')!.names.of('uz')).last);
    await w.snap('gematologiya_guruhi');
    await w.scroll(900);
    await w.snap('gematologiya_pasti');
    await w.scroll(-3000);
    await w.tapText(name('hemoglobin'));
    await w.snap('gemoglobin_tepa');
    await w.scroll(700);
    await w.snap('gemoglobin_nima_uchun');
    await w.scroll(800);
    await w.snap('gemoglobin_natijalar');
    await w.scroll(900);
    await w.snap('gemoglobin_preanalitika');
    await w.scroll(900);
    await w.snap('gemoglobin_cheklovlar');
    await w.scroll(900);
    await w.snap('gemoglobin_chegaralar');
    await w.scroll(1200);
    await w.snap('gemoglobin_bogliq');
    await w.scroll(-5000);
    await scrollAndTap(w, name('hematocrit'));
    await w.snap('gematokrit');
    routerOf(tester).pop();
    await w.snap('orqaga_gemoglobin');
    await scrollAndTap(w, l.analytePractice);
    await w.snap('mashq');
    await w.tapText('< 130 g/L');
    await w.snap('mashq_javob');
    await goTo(tester, '/tests');
    await w.scroll(-9000);

    // Qidiruv: umumiy qon tahlili sinonimi.
    await tester.enterText(find.byType(TextField).first, 'OAK');
    await w.snap('qidiruv_oak');
    await tester.enterText(find.byType(TextField).first, 'EChT');
    await w.snap('qidiruv_echt');
    await w.tapText(name('esr'));
    await w.snap('echt_karta');
    await w.scroll(1400);
    await w.snap('echt_pasti');
  });

  testWidgets('koagulyatsiya — ru, qorong‘i, katta shrift (talaba)', (
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
    final pack = s.content.pack!;
    String name(String id) => pack.analyte(id)!.names.of('ru');
    final w = Walk(tester, 'coagulation_ru_dark_large');

    await w.tapText(l.navTests);
    await tester.enterText(find.byType(TextField).first, 'АЧТВ');
    await w.snap('qidiruv_achtv');
    await tester.enterText(find.byType(TextField).first, '');
    await w.tap(find.text(pack.group('coagulation')!.names.of('ru')).last);
    await w.snap('koagulyatsiya_guruhi');
    await w.tapText(name('pt-inr'));
    await w.snap('pt_inr_tepa');
    await w.scroll(800);
    await w.snap('pt_inr_nima_uchun');
    await w.scroll(1000);
    await w.snap('pt_inr_natija');
    await w.scroll(1000);
    await w.snap('pt_inr_preanalitika');
    await w.scroll(1000);
    await w.snap('pt_inr_cheklov');
    await w.scroll(1000);
    await w.snap('pt_inr_bogliq');
    await w.scroll(-9000);
    await scrollAndTap(w, name('aptt'));
    await w.snap('achtv');
    await goTo(tester, '/tests/analyte/platelets');
    await w.scroll(4200);
    await w.snap('trombotsitlar_chegaralar');
    await w.scroll(900);
    await w.snap('trombotsitlar_chegaralar_2');
    await goTo(tester, '/tests/analyte/coagulation-factors');
    await w.scroll(3200);
    await w.snap('omillar_chegaralar');
  });

  testWidgets('en — doctor: D-dimer and blood smear', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    final s = await start(tester, lang: AppLanguage.en, role: AppRole.doctor);
    final pack = s.content.pack!;
    final w = Walk(tester, 'hematology_en');
    await w.tapText(l.navTests);
    await tester.enterText(find.byType(TextField).first, 'D-dimer');
    await w.snap('search_ddimer');
    await w.tapText(pack.analyte('d-dimer')!.names.of('en'));
    await w.snap('ddimer_top');
    await w.scroll(900);
    await w.snap('ddimer_purpose');
    await w.scroll(1000);
    await w.snap('ddimer_results');
    await w.scroll(1000);
    await w.snap('ddimer_limits');
    await goTo(tester, '/tests/analyte/blood-smear');
    await w.snap('smear_top');
    await goTo(tester, '/tests/analyte/neutrophils');
    await w.scroll(600);
    await w.snap('neutrophils');
  });
}
