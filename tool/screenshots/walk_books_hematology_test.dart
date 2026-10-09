// Domla kitoblari bilimi: gematologiya, anemiya, parazitologiya, jigar —
// foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_books_hematology_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/reference/reference_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

/// Ro'yxatda [text] ko'ringuncha pastga aylantirib, bosadi.
Future<void> scrollAndTap(Walk w, String text, {double step = 400}) async {
  await w.tester.pumpAndSettle();
  for (var i = 0; i < 60 && find.text(text).evaluate().isEmpty; i++) {
    await w.scroll(step);
  }
  await w.tap(find.text(text).last);
}

String title(String id, String lang) => refTopic(id)!.title.of(lang);

void main() {
  setUpAll(loadAppFonts);

  testWidgets('uz, 320 px, laborant: O‘rganish → jadvallar; karta → jadval', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester, size: const Size(320, 700));
    final pack = s.content.pack!;
    final w = Walk(tester, 'books_uz_320');

    await w.tapText(l.navLearn);
    await scrollAndTap(w, l.refTitle);
    await w.snap('jadvallar_royxati');
    await w.tapText(title('anemia', 'uz'));
    await w.snap('anemiya_tepa');
    await w.scroll(600);
    await w.snap('anemiya_mcv');
    await w.scroll(700);
    await w.snap('anemiya_retikulotsit');
    await w.scroll(900);
    await w.snap('anemiya_temir');
    await w.scroll(1400);
    await w.snap('anemiya_manbalar');
    routerOf(tester).pop();
    await w.snap('orqaga_royxat');
    await w.tapText(title('jaundice', 'uz'));
    await w.snap('sariqlik_tepa');
    await w.scroll(900);
    await w.snap('sariqlik_jigar');
    await w.scroll(900);
    await w.snap('sariqlik_jigar_osti');
    routerOf(tester).pop();
    await scrollAndTap(w, title('obsolete-methods', 'uz'));
    await w.snap('eskirgan_tepa');
    await w.scroll(1000);
    await w.snap('eskirgan_benzidin');
    await w.scroll(1000);
    await w.snap('eskirgan_sulema');

    // Tahlillar → qidiruv (sinonim) → karta → jadvalga havola.
    await w.tapText(l.navTests);
    await tester.enterText(find.byType(TextField).first, 'IRF');
    await w.snap('qidiruv_irf');
    await w.tapText(pack.analyte('reticulocytes')!.names.of('uz'));
    await w.snap('retikulotsit_tepa');
    await w.scroll(900);
    await w.snap('retikulotsit_fiziologiya');
    await w.scroll(1000);
    await w.snap('retikulotsit_natijalar');
    await w.scroll(1200);
    await w.snap('retikulotsit_cheklovlar');
    await scrollAndTap(w, title('anemia', 'uz'));
    await w.snap('kartadan_jadvalga');
  });

  testWidgets('ru, qorong‘i, katta shrift, shifokor: anemiya va sariqlik', (
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
    final pack = s.content.pack!;
    final w = Walk(tester, 'books_ru_dark_large');

    await goTo(tester, '/tests/conditions');
    await tester.enterText(find.byType(TextField).first, 'алгоритм анемии');
    await w.snap('poisk_anemiya');
    await w.tapText(pack.condition('anemia-workup')!.names.of('ru'));
    await w.snap('anemiya_tepa');
    await w.scroll(900);
    await w.snap('anemiya_panel');
    await w.scroll(1200);
    await w.snap('anemiya_naqshlar');
    await w.scroll(1200);
    await w.snap('anemiya_naqshlar_2');
    await goTo(tester, '/tests/conditions/jaundice-cholestasis');
    await w.scroll(2200);
    await w.snap('sariqlik_naqshlar');
    await w.scroll(1200);
    await w.snap('sariqlik_naqshlar_2');
    await goTo(tester, '/tests/analyte/mchc');
    await w.scroll(1400);
    await w.snap('mchc_xalaqit');
    await goTo(tester, '/learn/reference/spurious-cbc');
    await w.snap('soxta_natijalar');
    await w.scroll(1200);
    await w.snap('soxta_natijalar_2');
    await goTo(tester, '/lab/differential/technique');
    await scrollAndTap(w, 'Движение по мазку: края и середина');
    await w.snap('texnika_200');
    await w.scroll(700);
    await w.snap('texnika_jadval');
    await goTo(tester, '/lab/differential/interpret');
    await scrollAndTap(w, l.diffRangesTitle);
    await w.snap('oraliqlar');
    await w.scroll(600);
    await w.snap('oraliqlar_izoh');
  });

  testWidgets('en, student: parasites and liver tables', (tester) async {
    final s = await start(tester, lang: AppLanguage.en, role: AppRole.student);
    final pack = s.content.pack!;
    final w = Walk(tester, 'books_en');
    await goTo(tester, '/tests/analyte/stool-ova-parasites');
    await w.scroll(1000);
    await w.snap('ova_physiology');
    await w.scroll(1200);
    await w.snap('ova_preanalytics');
    await scrollAndTap(w, title('stool-parasites', 'en'));
    await w.snap('methods_top');
    await w.scroll(1000);
    await w.snap('methods_kato');
    await w.scroll(1000);
    await w.snap('methods_flotation');
    await w.scroll(1200);
    await w.snap('methods_tape');
    await goTo(tester, '/tests/analyte/ast');
    await w.scroll(1600);
    await w.snap('ast_de_ritis');
    await w.scroll(-9000);
    await scrollAndTap(w, title('liver-syndromes', 'en'));
    await w.snap('liver_top');
    await w.scroll(1100);
    await w.snap('liver_failure_deritis');
    expect(pack.condition('hemolytic-anemia'), isNotNull);
  });
}
