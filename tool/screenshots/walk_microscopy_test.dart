// Mikroskopiya atlasi — foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_microscopy_test.dart --update-goldens
//
// Talaba (uz, yorug'): atlas → bo'lim → rasm → kattalashtirish → litsenziya/
// manba → mashq → natija. Laboratoriya mutaxassisi (ru, qorong'i, katta
// shrift) va en — qidiruv, CDC kartasi, mualliflar, mashq.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/microscopy/microscopy_atlas.dart';
import 'package:labguide/features/microscopy/microscopy_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

/// Atlas rasmlarini ekranlarda ishlatiladigan o'lchamlarda oldindan dekod
/// qilish (widget testda rasm faqat real async'da yuklanadi).
Future<void> _precache(WidgetTester tester, AppServices s) async {
  final atlas = s.microscopy.atlas!;
  // Hamma o'lchamlar keshda qolsin (standart 100 MB yetmaydi).
  PaintingBinding.instance.imageCache
    ..maximumSize = 4000
    ..maximumSizeBytes = 1 << 30;
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold).first);
    for (final i in atlas.images) {
      await precacheImage(AssetImage(i.asset), ctx);
      for (final w in [MicroThumb.small, MicroThumb.card, MicroThumb.large]) {
        await precacheImage(microThumb(i, width: w), ctx);
      }
    }
  });
}

/// Mashqdagi rasmning to'g'ri javobi (ekrandagi rasmdan topiladi).
MicroEntity _currentAnswer(WidgetTester tester, MicroAtlas atlas) {
  final img = tester
      .widgetList<Image>(find.byType(Image))
      .map((w) => w.image)
      .whereType<ResizeImage>()
      .firstWhere((r) => r.width == MicroThumb.large);
  final asset = (img.imageProvider as AssetImage).assetName;
  final image = atlas.images.firstWhere((i) => i.asset == asset);
  return atlas.entity(image.entityId)!;
}

Future<void> _answer(
  WidgetTester tester,
  Walk w,
  MicroAtlas atlas,
  String lang, {
  required bool correct,
}) async {
  final answer = _currentAnswer(tester, atlas);
  final names = [
    for (final e in atlas.entities)
      if (e.quiz) e.name.of(lang),
  ];
  final target = correct
      ? answer.name.of(lang)
      : names.firstWhere(
          (n) =>
              n != answer.name.of(lang) &&
              find.text(n).hitTestable().evaluate().isNotEmpty,
          orElse: () => names.firstWhere(
            (n) =>
                n != answer.name.of(lang) && find.text(n).evaluate().isNotEmpty,
          ),
        );
  await w.tap(find.text(target).last);
}

/// Ko'rinmagan (hali qurilmagan) elementgacha surish.
Future<void> _seek(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('mikroskopiya — talaba (uz, yorug‘)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await start(tester, role: AppRole.student);
    await _precache(tester, s);
    final atlas = s.microscopy.atlas!;
    final w = Walk(tester, 'microscopy_uz');
    await goTo(tester, '/lab');
    await _seek(tester, find.text(l.micTitle));
    await w.tap(find.text(l.micTitle).last);
    await w.snap('atlas');
    await w.scroll(500);
    await w.snap('atlas_bolimlar');
    await w.scroll(700);
    await w.snap('atlas_pasti');
    await w.scroll(-3000);
    await w.tap(find.textContaining('Siydik cho‘kmasi').first);
    await w.snap('siydik_bolimi');
    await w.scroll(900);
    await w.snap('siydik_epiteliy');
    await w.scroll(900);
    await w.snap('siydik_silindrlar');
    await w.scroll(-3000);
    await w.tap(find.text('Epiteliy').first);
    await w.snap('epiteliy_filtr');
    await w.tap(find.text(l.micGapWhy).last);
    await w.snap('rasm_yoq_sababi');
    // Varaqni yopish (to'q fonga bosish).
    await tester.tapAt(const Offset(195, 420));
    await tester.pumpAndSettle();
    await w.scroll(-3000);
    await w.tap(find.text('Kristallar').first);
    await w.tap(find.text('Kalsiy oksalat kristallari').first);
    await w.snap('rasm_karta');
    await w.scroll(550);
    await w.snap('rasm_izoh_tarjima');
    await w.scroll(650);
    await w.snap('rasm_preparat_draft');
    await w.scroll(700);
    await w.snap('rasm_muallif_litsenziya');
    await w.scroll(-5000);
    await w.tap(find.text(l.micZoom).first);
    await w.snap('toliq_ekran');
    await w.tap(find.byTooltip(l.micZoomIn));
    await w.tap(find.byTooltip(l.micZoomIn));
    await w.snap('kattalashtirilgan');
    await w.tap(find.byTooltip(l.micClose));
    await goTo(tester, '/lab/microscopy');
    await w.tap(find.text(l.micQuizCta).first);
    await w.snap('mashq_boshi');
    await w.tap(find.textContaining('Siydik cho‘kmasi').first);
    await w.tap(find.textContaining('Boshlash').first);
    await w.snap('savol_1');
    await _answer(tester, w, atlas, 'uz', correct: true);
    await w.snap('savol_1_togri');
    await w.tapText(l.quizNext);
    await _answer(tester, w, atlas, 'uz', correct: false);
    await w.snap('savol_2_xato');
    await w.tapText(l.quizNext);
    var n = 2;
    while (find.text(l.quizFinish).evaluate().isEmpty) {
      await _answer(tester, w, atlas, 'uz', correct: n.isEven);
      n++;
      if (n == 4) await w.snap('savol_seriya');
      if (find.text(l.quizFinish).evaluate().isNotEmpty) break;
      await w.tapText(l.quizNext);
    }
    await w.tapText(l.quizFinish);
    await w.snap('natija');
    await w.scroll(600);
    await w.snap('natija_xatolar');
    await w.tap(find.textContaining('Xatolarni qayta').first);
    await w.snap('xatolar_raundi');
    await goTo(tester, '/lab/microscopy');
    await w.snap('atlas_eng_yaxshi_natija');
  });

  testWidgets('mikroskopiya — lab mutaxassisi (ru, qorong‘i, katta shrift)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    await _precache(tester, s);
    final atlas = s.microscopy.atlas!;
    final w = Walk(tester, 'microscopy_ru_dark_large');
    await goTo(tester, '/lab/microscopy');
    await w.snap('atlas');
    await w.scroll(600);
    await w.snap('atlas_razdely');
    await goTo(tester, '/lab/microscopy/s/blood');
    await w.snap('krov');
    await w.scroll(800);
    await w.snap('krov_niz');
    await goTo(tester, '/lab/microscopy/i/b-baso-1');
    await w.snap('bazofil');
    await w.scroll(700);
    await w.snap('bazofil_podpis');
    await w.scroll(1400);
    await w.snap('bazofil_cdc_usloviya');
    await w.scroll(900);
    await w.snap('bazofil_niz');
    await goTo(tester, '/lab/microscopy/i/u-cryst-cystine-1');
    await w.scroll(600);
    await w.snap('cistin_ispanskaya_podpis');
    await goTo(tester, '/lab/microscopy/quiz?section=blood');
    await w.snap('test_nastroika');
    await w.tap(find.textContaining('Начать').first);
    await w.snap('test_vopros');
    await _answer(tester, w, atlas, 'ru', correct: false);
    await w.snap('test_oshibka');
    expect(find.text(l.micQuizOpenCard), findsOneWidget);
  });

  testWidgets('mikroskopiya — en', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    final s = await start(tester, lang: AppLanguage.en, role: AppRole.lab);
    await _precache(tester, s);
    final w = Walk(tester, 'microscopy_en');
    await goTo(tester, '/lab/microscopy');
    await tester.enterText(find.byType(TextField).first, 'оксалат');
    await w.snap('search_cyrillic');
    await tester.enterText(find.byType(TextField).first, 'squamous');
    await w.snap('search_gap');
    await tester.enterText(find.byType(TextField).first, 'zzzz');
    await w.snap('search_empty');
    await goTo(tester, '/lab/microscopy/s/parasites');
    await w.snap('parasites');
    await goTo(tester, '/lab/microscopy/i/p-mal-thick-1');
    await w.snap('thick_film');
    await goTo(tester, '/lab/microscopy/credits');
    await w.snap('credits');
    await w.scroll(1600);
    await w.snap('credits_cdc');
    await w.scroll(2000);
    await w.snap('credits_licences');
    expect(find.text(l.micLicenseTexts), findsOneWidget);
  });
}
