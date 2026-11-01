// Yangi illyustratsiyalar (assets/images/illus, docs/ILLUSTRATIONS.md) —
// bo'lim bannerlari, apparat muqovalari va Pro reja rasmlari qanday
// ko'rinishini egasiga ko'rsatish uchun ekran rasmlari.
//
//   flutter test tool/screenshots/walk_illus_test.dart --update-goldens
//   -> tool/screenshots/out/walk/illus_*/NN_*.png
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/billing_fakes.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

/// Ko'rsatilgan kalitli vidjet ko'ringuncha pastga suradi.
Future<void> _scrollTo(WidgetTester tester, Walk w, Finder f) async {
  for (var i = 0; i < 30 && f.evaluate().isEmpty; i++) {
    await w.scroll(300);
  }
  if (f.evaluate().isNotEmpty) {
    await tester.ensureVisible(f.first);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    final tag = theme == ThemeMode.light ? 'light' : 'dark';
    testWidgets('bo\'lim bannerlari ($tag)', (tester) async {
      await start(tester, theme: theme);
      final w = Walk(tester, 'illus_sections_$tag');
      for (final (route, name) in [
        ('/lab/preanalytics', 'preanalitika'),
        ('/lab/instruments', 'apparatlar'),
        ('/lab/qc', 'sifat_nazorati'),
        ('/lab/calculators', 'kalkulyatorlar'),
        ('/lab/microscopy', 'mikroskopiya'),
      ]) {
        await goTo(tester, '/lab');
        await goTo(tester, route);
        await w.snap(name);
        expect(tester.takeException(), isNull, reason: route);
      }
    });
  }

  testWidgets('apparat muqovalari', (tester) async {
    await start(tester);
    final w = Walk(tester, 'illus_instruments');
    for (final (route, name, figure) in [
      ('/lab/instruments/m/mindray-bs-240', 'biokimyo_model', 'instrument-schematic'),
      ('/lab/instruments/lc/a3-tox-gc-ms', 'gcms_karta', 'lab-card-schematic'),
      ('/lab/instruments/lc/a1-realtime-pcr-method', 'pcr_karta', 'lab-card-schematic'),
    ]) {
      await goTo(tester, '/lab/instruments');
      await goTo(tester, route);
      await _scrollTo(tester, w, find.byKey(ValueKey(figure)));
      await w.scroll(-160);
      await w.snap(name);
      expect(tester.takeException(), isNull, reason: route);
    }
  });

  testWidgets('Pro sotib olish ekrani', (tester) async {
    final s = await makeServices(
      tester,
      language: AppLanguage.uz,
      proEnabled: true,
      allFeaturesOpen: false,
      purchases: FakePurchaseAdapter(),
      entitlementSource: FakeEntitlementSource(),
      gatedFeatures: ProGatePolicy.catalog,
    );
    await s.entitlements.refresh(reprobe: false);
    await pumpApp(tester, s, size: const Size(390, 844));
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold).first);
      for (final n in [
        'pro_student',
        'pro_teacher',
        'pro_specialist',
        'pro_premium',
      ]) {
        await precacheImage(AssetImage('assets/images/illus/$n.webp'), ctx);
      }
    });
    final w = Walk(tester, 'illus_pro');
    await goTo(tester, '/profile/purchase');
    await w.snap('tepa');
    for (var i = 1; i <= 4; i++) {
      await w.scroll(600);
      await w.snap('pastga_$i');
    }
    expect(tester.takeException(), isNull);
  });
}
