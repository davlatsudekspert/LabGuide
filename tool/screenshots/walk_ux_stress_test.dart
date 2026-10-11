// UX: tor ekran (320), katta shrift (1.6), qorong'i rejim — asosiy ekranlar.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _routes = [
  '/home',
  '/tests',
  '/tests/analyte/glucose-plasma-fasting',
  '/tests/conditions',
  '/lab',
  '/lab/qc',
  '/lab/qc/new',
  '/lab/calculators/egfr',
  '/lab/instruments',
  '/lab/preanalytics',
  '/profile',
  '/library',
];

void main() {
  setUpAll(loadAppFonts);
  final cases = {
    'w320': (const Size(320, 640), 1.0, ThemeMode.light),
    'big': (const Size(390, 844), 1.6, ThemeMode.light),
    'dark': (const Size(390, 844), 1.0, ThemeMode.dark),
  };
  for (final e in cases.entries) {
    for (final lang in [AppLanguage.ru, AppLanguage.uz]) {
      testWidgets('${e.key} ${lang.name}', (tester) async {
        await start(
          tester,
          role: AppRole.doctor,
          lang: lang,
          size: e.value.$1,
          textScale: e.value.$2,
          theme: e.value.$3,
        );
        final w = Walk(tester, 'ux_${e.key}_${lang.name}');
        for (final r in _routes) {
          await goTo(tester, r);
          await w.snap(r.substring(1).replaceAll('/', '_'));
        }
        final ex = tester.takeException();
        expect(ex, isNull);
      });
    }
  }
}
