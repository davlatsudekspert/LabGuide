// Apparat kartalaridagi rasm bloki — foydalanuvchi sifatida (walk_helper.dart).
// Har model kartasi ochiladi: nom ↔ ishlab chiqaruvchi ↔ rasm (yoki neytral
// belgi) mosligi ko'zdan kechiriladi.
//
//   flutter test tool/screenshots/walk_instrument_images_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('har model kartasi — uz, yorug‘', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester);
    final w = Walk(tester, 'instrument_images_uz');
    await goTo(tester, '/lab/instruments/c/chemistry');
    await w.snap('yonalish_tepa');
    await w.scroll(900);
    // Sxematik chizma faqat yo'nalish sahifasida, izohi bilan.
    expect(find.text(l.instIllustration), findsOneWidget);
    await w.snap('yonalish_sxematik_bezak');
    final catalog = s.instruments.catalog!;
    for (final m in catalog.models) {
      await goTo(tester, '/lab/instruments/m/${m.id}');
      expect(find.text(m.model), findsWidgets);
      expect(
        find.textContaining(
          RegExp(
            RegExp.escape(catalog.maker(m.makerId).name),
            caseSensitive: false,
          ),
        ),
        findsWidgets,
        reason: m.id,
      );
      // Rasmi yo'q modelda — neytral belgi; chizma yo'q.
      if (m.image == null) {
        expect(find.text(l.instImageMissing), findsOneWidget, reason: m.id);
      }
      expect(find.text(l.instIllustration), findsNothing, reason: m.id);
      await w.snap(m.id);
    }
    // Havola qatori to'liq ko'rinadi.
    await goTo(tester, '/lab/instruments/m/roche-cobas-u-411');
    await w.scroll(250);
    await w.snap('u411_manba_havolasi');
  });

  testWidgets('bir nechta karta — ru, qorong‘i, shrift 1.35', (tester) async {
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    final w = Walk(tester, 'instrument_images_ru_dark');
    for (final id in [
      'mindray-bc-5390',
      'human-humalyzer-4000',
      'roche-cobas-e-411',
      'abbott-cell-dyn-emerald',
    ]) {
      await goTo(tester, '/lab/instruments/m/$id');
      expect(find.text('Изображение модели пока недоступно'), findsOneWidget);
      await w.snap(id);
    }
    await goTo(tester, '/lab/instruments/c/hematology');
    await w.scroll(900);
    await w.snap('yonalish_sxematik_bezak');
    expect(s.instruments.catalog, isNotNull);
  });

  testWidgets('en, yorug‘ va 320 px katta shrift', (tester) async {
    await start(tester, lang: AppLanguage.en);
    final w = Walk(tester, 'instrument_images_en');
    await goTo(tester, '/lab/instruments/m/abbott-architect-i1000sr');
    expect(find.text('Model image not available yet'), findsOneWidget);
    await w.snap('architect_i1000sr');
    await goTo(tester, '/lab/instruments/m/mindray-eu-5600-pro');
    await w.snap('eu5600_pro');
  });

  testWidgets('320 px, shrift 2.0 — uz, qorong‘i', (tester) async {
    await start(
      tester,
      theme: ThemeMode.dark,
      textScale: 2,
      size: const Size(320, 640),
    );
    final w = Walk(tester, 'instrument_images_320');
    await goTo(tester, '/lab/instruments/m/human-humacount-30ts');
    await w.snap('humacount30ts_tepa');
    await w.scroll(400);
    await w.snap('humacount30ts_havola');
  });
}
