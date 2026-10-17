// Dizayn ko'rigi (docs/DESIGN_REVIEW_2026-10-17.md): ilovadagi deyarli har
// bir ekran — ikki ko'rinishda: uz · kunduzgi · 390 px va ru · tungi ·
// 320 px. Har ekran tepasi va bir surilgandan keyingi holati.
// Rasmlar: tool/screenshots/out/walk/all_<variant>/NN_<marshrut>.png
//
//   flutter test tool/screenshots/walk_all_screens_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const routes = [
  '/home',
  '/home/search',
  '/tests',
  '/tests/analyte/glucose-plasma-fasting',
  '/tests/conditions',
  '/home/conditions/type-2-diabetes',
  '/lab',
  '/lab/qc',
  '/lab/qc/new',
  '/lab/qc/eqa',
  '/lab/calibration',
  '/lab/calibration/log',
  '/lab/calculators',
  '/lab/calculators/egfr',
  '/lab/calculators/dilution',
  '/lab/calculators/chamber',
  '/lab/preanalytics',
  '/lab/instruments',
  '/lab/instruments/c/hematology',
  '/lab/instruments/m/mindray-bs-240',
  '/lab/microscopy',
  '/lab/microscopy/s/urine',
  '/lab/microscopy/i/u-rbc-1',
  '/lab/differential',
  '/lab/differential/cells',
  '/lab/differential/cells/neutrophil_band',
  '/lab/differential/count',
  '/lab/differential/history',
  '/lab/differential/interpret',
  '/lab/cytology',
  '/lab/cytology/cells',
  '/lab/cytology/bethesda',
  '/lab/spermogram',
  '/lab/spermogram/limits',
  '/lab/spermogram/count',
  '/lab/bloodgroup',
  '/lab/bloodgroup/compat',
  '/lab/histology',
  '/lab/histology/items',
  '/lab/bloodmorph',
  '/lab/bloodmorph/rbc',
  '/lab/urinalysis',
  '/lab/urinalysis/strip',
  '/lab/urinalysis/sediment',
  '/library',
  '/library/saved',
  '/library/packs',
  '/library/books',
  '/library/sources',
  '/library/research',
  '/library/intake',
  '/learn',
  '/learn/quiz',
  '/learn/reference',
  '/learn/daily',
  '/learn/exam',
  '/profile',
  '/profile/role',
  '/profile/privacy',
  '/profile/contact',
  '/profile/support',
  '/terms',
];

Future<void> _tour(
  WidgetTester tester,
  String name, {
  required AppLanguage lang,
  required ThemeMode theme,
  required Size size,
}) async {
  await start(tester, lang: lang, theme: theme, size: size);
  final w = Walk(tester, name);
  for (final r in routes) {
    await goTo(tester, r);
    final slug = r.substring(1).replaceAll('/', '_');
    await w.snap(slug);
    final scrollables = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable();
    if (scrollables.evaluate().isNotEmpty) {
      await tester.drag(scrollables.first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await w.snap('${slug}_past');
    }
  }
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('hamma ekran: uz · kunduzgi · 390', (tester) async {
    await _tour(
      tester,
      'all_uz_light_390',
      lang: AppLanguage.uz,
      theme: ThemeMode.light,
      size: const Size(390, 844),
    );
  });

  testWidgets('hamma ekran: ru · tungi · 320', (tester) async {
    await _tour(
      tester,
      'all_ru_dark_320',
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      size: const Size(320, 640),
    );
  });
}
