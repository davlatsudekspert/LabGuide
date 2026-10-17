// Ma'ruza: 16:9 taqdimot (D-59) — tik telefon (karta + panel), manbalar
// oynasi, to'liq ekran (yotiq), keng ekran (planshet), taqdimotchi, tungi.
// Vizual shablonlar (D-60): raqam kartalari, chegaralar diagrammasi,
// qadamlar, ikki ustun, tasnif daraxti, misol kartasi, yon rasm, sarlavha
// rasmi, litsenziyali atlas fotolari — telefon (uz) va keng ekran (en, tungi).
//
//   flutter test tool/screenshots/walk_lecture_16x9_test.dart --update-goldens
// Rasmlar: tool/screenshots/out/walk/lecture16x9_*/
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<LectureDeck> _deck(WidgetTester tester, String id, String lang) async {
  final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
  final e = c.byId(id)!;
  return (await tester.runAsync(
    () => DeckCatalog.loadDeck(rootBundle, e, e.resolveLang(lang)),
  ))!;
}

Future<void> _precache(WidgetTester tester, LectureDeck d) =>
    tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold).first);
      for (final s in d.slides) {
        if (s.figure != null) await precacheImage(AssetImage(s.figure!), ctx);
      }
    });

/// Har vizual shablon uchun namuna: (deck, shablon tanlovi). Birinchi mos
/// slayd olinadi.
final _visualPicks = <(String, String, bool Function(DeckSlide))>[
  ('d009', 'title_image', (s) => s.template == 'title'),
  ('d009', 'stats', (s) => s.template == 'stats'),
  ('d045', 'range', (s) => s.template == 'range'),
  ('d014', 'split', (s) => s.template == 'split'),
  ('d014', 'tree', (s) => s.template == 'tree'),
  ('siydik-chokmasi-mikroskopiya', 'steps', (s) => s.template == 'steps'),
  ('d011', 'example', (s) => s.template == 'example'),
  (
    'leykotsitlarni-sanash-kamera',
    'example_protocol',
    (s) => s.template == 'example',
  ),
  ('d087', 'side_image', (s) => s.figure != null && s.template == 'bullets'),
  (
    'd016',
    'photo_bloodmorph',
    (s) => (s.figure ?? '').contains('bloodmorph/img'),
  ),
  (
    'd005',
    'photo_histology',
    (s) => (s.figure ?? '').contains('histology/img'),
  ),
  ('d013', 'range_hb', (s) => s.template == 'range'),
];

void main() {
  setUpAll(loadAppFonts);

  for (final lang in [AppLanguage.uz, AppLanguage.ru]) {
    testWidgets('telefon (${lang.name})', (tester) async {
      installDiffFakes();
      final d = await _deck(tester, 'd012', lang.name);
      final w = Walk(tester, 'lecture16x9_phone_${lang.name}');
      await start(tester, lang: lang, role: AppRole.teacher);
      await _precache(tester, d);
      final sl = d.slides;
      final picks = [
        0,
        1,
        sl.indexWhere((s) => s.template == 'bullets' && s.source != null),
        sl.indexWhere((s) => s.template == 'table'),
        sl.indexWhere((s) => s.template == 'figure'),
        sl.indexWhere((s) => s.template == 'qa'),
        sl.length - 1,
      ];
      for (final k in picks) {
        routerOf(tester).go('/learn/lecture');
        await tester.pumpAndSettle();
        routerOf(tester).go('/learn/lecture/deck/d012?s=$k');
        await tester.pumpAndSettle();
        await w.snap('slide_${k}_${sl[k].template}');
        if (sl[k].template == 'qa') {
          await w.tap(find.byKey(const ValueKey('lecture-answer')));
          await w.snap('slide_${k}_answer');
        }
      }
      // Manbalar oynasi.
      final src = sl.indexWhere((s) => s.refs.length > 1);
      routerOf(tester).go('/learn/lecture');
      await tester.pumpAndSettle();
      routerOf(tester).go('/learn/lecture/deck/d012?s=$src');
      await tester.pumpAndSettle();
      await w.tap(find.byKey(const ValueKey('lecture-source')));
      await w.snap('sources_sheet');
      await tester.tapAt(const Offset(200, 60));
      await tester.pumpAndSettle();
      await w.tap(find.byKey(const ValueKey('lecture-fullscreen')));
      await w.snap('rotate_dialog');
    });
  }

  for (final (lang, theme, size, tag) in [
    (AppLanguage.uz, ThemeMode.light, const Size(390, 844), 'phone_uz'),
    (AppLanguage.ru, ThemeMode.light, const Size(320, 640), 'phone320_ru'),
    (AppLanguage.en, ThemeMode.dark, const Size(1280, 800), 'wide_en_dark'),
  ]) {
    testWidgets('vizual shablonlar ($tag)', (tester) async {
      installDiffFakes();
      final w = Walk(tester, 'lecture16x9_visual_$tag');
      await start(
        tester,
        lang: lang,
        role: AppRole.teacher,
        size: size,
        theme: theme,
      );
      for (final (id, name, pick) in _visualPicks) {
        final d = await _deck(tester, id, lang.name);
        final k = d.slides.indexWhere(pick);
        if (k < 0) continue;
        await _precache(tester, d);
        routerOf(tester).go('/learn/lecture');
        await tester.pumpAndSettle();
        routerOf(tester).go('/learn/lecture/deck/$id?s=$k');
        await tester.pumpAndSettle();
        await w.snap('${name}_$k');
      }
    });
  }

  testWidgets('to‘liq ekran: vizual shablonlar (uz)', (tester) async {
    installDiffFakes();
    final w = Walk(tester, 'lecture16x9_visual_fullscreen');
    await start(tester, role: AppRole.teacher, size: const Size(844, 390));
    for (final (id, name, pick) in _visualPicks.take(7)) {
      final d = await _deck(tester, id, 'uz');
      final k = d.slides.indexWhere(pick);
      if (k < 0) continue;
      await _precache(tester, d);
      routerOf(tester).go('/learn/lecture');
      await tester.pumpAndSettle();
      routerOf(tester).go('/learn/lecture/deck/$id?s=$k');
      await tester.pumpAndSettle();
      await w.tap(find.byKey(const ValueKey('lecture-fullscreen')));
      await w.snap('${name}_$k');
      await w.tap(find.byKey(const ValueKey('lecture-fullscreen-exit')));
    }
  });

  testWidgets('eGFR (uzun band bo‘lingan)', (tester) async {
    installDiffFakes();
    final d = await _deck(tester, 'd057', 'uz');
    final w = Walk(tester, 'lecture16x9_egfr');
    await start(tester, role: AppRole.teacher, size: const Size(844, 390));
    final k = d.slides.indexWhere(
      (s) => s.bullets.any((b) => b.contains('sistatin C bo‘yicha')),
    );
    for (final i in [k - 1, k, k + 1]) {
      routerOf(tester).go('/learn/lecture');
      await tester.pumpAndSettle();
      routerOf(tester).go('/learn/lecture/deck/d057?s=$i');
      await tester.pumpAndSettle();
      await w.tap(find.byKey(const ValueKey('lecture-fullscreen')));
      await w.snap('fullscreen_$i');
      await w.tap(find.byKey(const ValueKey('lecture-fullscreen-exit')));
    }
  });

  testWidgets('keng ekran, taqdimotchi, tungi', (tester) async {
    installDiffFakes();
    final d = await _deck(tester, 'd012', 'en');
    final w = Walk(tester, 'lecture16x9_wide');
    await start(
      tester,
      lang: AppLanguage.en,
      role: AppRole.teacher,
      size: const Size(1280, 800),
      theme: ThemeMode.dark,
    );
    await _precache(tester, d);
    final fig = d.slides.indexWhere((s) => s.template == 'figure');
    final tab = d.slides.indexWhere((s) => s.template == 'table');
    for (final k in [0, tab, fig]) {
      routerOf(tester).go('/learn/lecture');
      await tester.pumpAndSettle();
      routerOf(tester).go('/learn/lecture/deck/d012?s=$k');
      await tester.pumpAndSettle();
      await w.snap('wide_dark_$k');
    }
    await w.tap(find.byKey(const ValueKey('lecture-more')));
    await w.snap('menu');
    await w.tap(find.byKey(const ValueKey('lecture-menu-presenter')));
    await w.snap('presenter');
  });
}
