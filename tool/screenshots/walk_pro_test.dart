// Pro rejalari foydalanuvchi sifatida (D-76, D-78): bepul / Talaba /
// Mutaxassis / Premium. Pro yoqilgan SINOV buildi va butun pullik katalog
// yopilgan (`ProGatePolicy.catalog`, faqat override). D-78: Lab bo'limi
// bepul — bepul hisobda ham sanash va QC ochiq.
//
//   flutter test tool/screenshots/walk_pro_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/billing_fakes.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<AppServices> _pro(
  WidgetTester tester, {
  String? product,
  AppLanguage language = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
}) async {
  final server = FakeEntitlementSource();
  if (product != null) {
    server.snapshot = EntitlementSnapshot(
      serverTime: DateTime.now().toUtc(),
      items: [
        ServerEntitlement(
          productId: product,
          platform: 'app_store',
          status: EntitlementStatus.active,
          startedAt: DateTime.now().toUtc(),
          expiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
        ),
      ],
    );
  }
  final s = await makeServices(
    tester,
    language: language,
    themeMode: theme,
    proEnabled: true,
    allFeaturesOpen: false,
    purchases: FakePurchaseAdapter(),
    entitlementSource: server,
    gatedFeatures: ProGatePolicy.catalog,
  );
  await s.entitlements.refresh(reprobe: false);
  return s;
}

Future<void> _warm(WidgetTester tester) async {
  PaintingBinding.instance.imageCache
    ..maximumSizeBytes = 2 << 30
    ..maximumSize = 5000;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('bepul hisob: Lab ochiq (D-78)', (tester) async {
    await _warm(tester);
    final s = await _pro(tester);
    await pumpApp(tester, s, size: const Size(390, 844));
    final w = Walk(tester, 'pro_free');
    await goTo(tester, '/lab');
    await w.snap('lab');
    await goTo(tester, '/lab/differential/count');
    await w.snap('leykoformula_ochiq');
    await w.tap(find.byKey(ValueKey('diff-count-${DiffCell.segmented.name}')));
    await w.snap('sanash_ishlaydi');
    await goTo(tester, '/lab/qc/new');
    await w.snap('qc_ochiq');
    await goTo(tester, '/profile/subscription');
    await w.snap('obuna');
    await w.scroll(600);
    await w.snap('obuna_past');
  });

  testWidgets('Talaba: Lab ochiq (bepul)', (tester) async {
    await _warm(tester);
    final student = await _pro(tester, product: BillingCatalog.studentMonthly);
    await pumpApp(tester, student, size: const Size(390, 844));
    final w = Walk(tester, 'pro_student');
    await goTo(tester, '/lab/qc/new');
    await w.snap('talaba_qc_ochiq');
    await goTo(tester, '/profile/subscription');
    await w.snap('talaba_obuna');
  });

  testWidgets('Mutaxassis: Lab ochiq', (tester) async {
    await _warm(tester);
    final s = await _pro(tester, product: BillingCatalog.specialistMonthly);
    await pumpApp(tester, s, size: const Size(390, 844));
    final w = Walk(tester, 'pro_specialist');
    await goTo(tester, '/lab/differential/count');
    await w.tap(find.byKey(ValueKey('diff-count-${DiffCell.segmented.name}')));
    await w.snap('sanash_ishlaydi');
    await goTo(tester, '/lab/qc/new');
    await w.snap('qc_ochiq');
    await goTo(tester, '/profile/subscription');
    await w.snap('obuna');
  });

  testWidgets('Premium: hammasi ochiq (ru, tungi)', (tester) async {
    await _warm(tester);
    final s = await _pro(
      tester,
      product: BillingCatalog.premiumYearly,
      language: AppLanguage.ru,
      theme: ThemeMode.dark,
    );
    await pumpApp(tester, s, size: const Size(360, 780));
    final w = Walk(tester, 'pro_premium_ru_dark');
    await goTo(tester, '/lab/qc/new');
    await w.snap('qc_ochiq');
    await goTo(tester, '/profile/subscription');
    await w.snap('obuna');
    await goTo(tester, '/profile/purchase');
    await w.snap('rejalar');
    await w.scroll(700);
    await w.snap('rejalar_past');
  });
}
