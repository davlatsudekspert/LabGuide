// Ilova xaritasi (docs/APP_MAP_2026-10-18.md): har rol uchun tab ildizlari
// (to'liq, bir necha surish bilan) va asosiy hub ekranlar — ikki ko'rinishda:
// uz · kunduzgi · 390 va ru · tungi · 320.
// Rasmlar: tool/screenshots/out/walk/map_<rol>_<variant>/NN_<qadam>.png
//
//   flutter test tool/screenshots/walk_app_map_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _hubs = [
  '/home',
  '/lab',
  '/learn',
  '/library',
  '/profile',
  '/learn/lecture',
  '/learn/classes',
  '/learn/toifa',
  '/lab/calculators',
  '/lab/qc',
  '/lab/microscopy',
];

Future<void> _snapAll(Walk w, WidgetTester tester, String slug) async {
  await w.snap(slug);
  for (var i = 1; i <= 4; i++) {
    final s = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable();
    if (s.evaluate().isEmpty) return;
    final before = tester.widget<Scrollable>(s.first).controller?.offset;
    await tester.drag(s.first, const Offset(0, -500));
    await tester.pumpAndSettle();
    final after = tester.widget<Scrollable>(s.first).controller?.offset;
    if (before != null && after != null && after == before) return;
    await w.snap('${slug}_$i');
  }
}

Future<void> _tour(
  WidgetTester tester,
  AppRole role,
  String variant, {
  required AppLanguage lang,
  required ThemeMode theme,
  required Size size,
}) async {
  await start(tester, role: role, lang: lang, theme: theme, size: size);
  final w = Walk(tester, 'map_${role.name}_$variant');
  for (final r in _hubs) {
    await goTo(tester, r);
    await _snapAll(w, tester, r.substring(1).replaceAll('/', '_'));
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final role in AppRole.values) {
    testWidgets('xarita: ${role.name} · uz · kunduzgi · 390', (tester) async {
      await _tour(
        tester,
        role,
        'uz_light_390',
        lang: AppLanguage.uz,
        theme: ThemeMode.light,
        size: const Size(390, 844),
      );
    });
    testWidgets('xarita: ${role.name} · ru · tungi · 320', (tester) async {
      await _tour(
        tester,
        role,
        'ru_dark_320',
        lang: AppLanguage.ru,
        theme: ThemeMode.dark,
        size: const Size(320, 640),
      );
    });
  }
}
