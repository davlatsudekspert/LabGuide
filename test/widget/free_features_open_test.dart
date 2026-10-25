// D-78 regressiya (egasi qarori, 2026-10-25): bugun `main` (4b0f057, do'kon
// tekshiruvidagi bepul versiya) da bor HAR BIR yo'l — Lab bo'limi, atlas,
// toifa, testlar, guruhlar, kalkulyatorlar, QC, kalibrlash va h.k. — Pro
// yoqilgan buildda, BUTUN pullik katalog yopilganda (`ProGatePolicy.catalog`)
// va obunasiz (to'lov ishlayapti, `gatingActive`) hisobda ham to'lov oynasiga
// yo'naltirmaydi va yopiq belgi ko'rsatmaydi. Bu `test/widget/lab_gate_test.dart`
// (D-76 "Lab — Pro" rejasi, BEKOR) o'rnini bosadi.
//
// Yo'llar ro'yxati: test/fixtures/main_routes_4b0f057.txt (main router'idagi
// literal `path:` lar) + main'da sikl bilan quriladigan QC qo'llanma va
// kalkulyator yo'llari. `:param` — namuna qiymat bilan (sahifa "topilmadi"
// holatini ko'rsatishi mumkin — muhimi: to'lov oynasi yo'q).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/qc/qc_guides_info.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/features/tools/clinical_calc_screens.dart';
import 'package:labguide/features/tools/manual_calc_info.dart';
import 'package:labguide/features/tools/manual_calc_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/harness.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 2400);

final _locked = find.byKey(const ValueKey('pay-locked'));

/// main router'idagi yo'llar (fixture) + sikl bilan qurilganlari.
List<String> mainRoutes() {
  final lines = File('test/fixtures/main_routes_4b0f057.txt')
      .readAsLinesSync()
      .where((l) => l.trim().isNotEmpty && !l.startsWith('#'));
  return [
    ...lines,
    for (final g in QcGuide.values) '/lab/qc/${qcGuideRoute(g)}',
    for (final c in ClinicalCalc.values) '/lab/calculators/${calcRoute(c)}',
    for (final c in ManualCalc.values) '/lab/calculators/${manualCalcRoute(c)}',
  ];
}

/// `:param` → namuna qiymat.
String concrete(String route) =>
    route.replaceAllMapped(RegExp(r':(\w+)'), (m) => 'sample-${m[1]}');

/// Pro yoqilgan build + BUTUN katalog yopilgan + to'lov ishlayapti.
/// [product] — serverdagi obuna (`null` — obunasiz), [expired] — muddati
/// o'tgan obuna, [guest] — hisobsiz.
Future<AppServices> gatedApp(
  WidgetTester tester, {
  String? product,
  bool expired = false,
  bool guest = false,
}) async {
  final server = FakeEntitlementSource(user: guest ? null : 'user-a');
  if (product != null) {
    final now = DateTime.now().toUtc();
    server.snapshot = EntitlementSnapshot(
      serverTime: now,
      items: [
        ServerEntitlement(
          productId: product,
          platform: 'app_store',
          status: expired
              ? EntitlementStatus.expired
              : EntitlementStatus.active,
          startedAt: now.subtract(const Duration(days: 40)),
          expiresAt: expired
              ? now.subtract(const Duration(days: 2))
              : now.add(const Duration(days: 30)),
        ),
      ],
    );
  }
  final s = await makeServices(
    tester,
    proEnabled: true,
    allFeaturesOpen: false,
    purchases: FakePurchaseAdapter(),
    entitlementSource: server,
    gatedFeatures: ProGatePolicy.catalog,
  );
  await s.entitlements.refresh(reprobe: false);
  expect(s.entitlements.gatingActive, isTrue);
  expect(s.entitlements.isPro, isFalse);
  return s;
}

void main() {
  setUpAll(loadAppFonts);

  test('fixture: main yo‘llari o‘qildi', () {
    final routes = mainRoutes();
    expect(routes.length, greaterThan(200));
    for (final r in ['/lab', '/lab/differential/count', '/lab/qc/new',
        '/lab/calibration/log', '/lab/microscopy/quiz', '/learn/toifa/test',
        '/learn/exam', '/learn/classes/new', '/learn/lecture/auto']) {
      expect(routes, contains(r));
    }
  });

  testWidgets('D-78: main’dagi har bir yo‘l — katalog to‘liq yopilgan, '
      'obunasiz: to‘lov oynasi yo‘q', (tester) async {
    final s = await gatedApp(tester);
    await pumpApp(tester, s, size: _tall);
    final router = routerOf(tester);
    final failures = <String>[];
    for (final route in mainRoutes()) {
      final path = concrete(route);
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final at = router.routerDelegate.currentConfiguration.uri.path;
      if (at.startsWith('/profile/purchase') ||
          _locked.evaluate().isNotEmpty ||
          find.text(uz.proPurchaseTitle).evaluate().isNotEmpty) {
        failures.add('$path → $at');
      }
      // Sahifa xatosi ham bu yerda ushlanadi (masalan, yo'qolgan yo'l).
      final error = tester.takeException();
      if (error != null) failures.add('$path: $error');
    }
    expect(failures, isEmpty);
    // Hech bir amal boshlanmadi va hech narsa o'chirilmadi.
    expect(s.exams.history, isEmpty);
  });

  testWidgets('D-78: Lab amallari obunasiz ishlaydi — leykoformula sanash, '
      'QC yangi to‘plam, kalibrlash jurnali', (tester) async {
    final s = await gatedApp(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/lab/differential/count');
    final cell = find.byKey(ValueKey('diff-count-${DiffCell.segmented.name}'));
    await tester.ensureVisible(cell);
    await tester.pumpAndSettle();
    await tester.tap(cell);
    await tester.pumpAndSettle();
    expect(s.differential.count(DiffCell.segmented), 1);
    expect(_locked, findsNothing);
    for (final path in [
      '/lab/differential/interpret',
      '/lab/coagulogram/tests',
      '/lab/qc/new',
      '/lab/calculators/dilution',
      '/lab/calibration/log',
      '/lab/cytology/cells',
      '/lab/microscopy/quiz',
      '/learn/toifa/test',
    ]) {
      await goTo(tester, path);
      expect(_locked, findsNothing, reason: path);
      expect(find.text(uz.proPurchaseTitle), findsNothing, reason: path);
    }
    await goTo(tester, '/lab');
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  for (final (name, guest, expired) in [
    ('mehmon', true, false),
    ('obuna muddati o‘tgan', false, true),
  ]) {
    testWidgets('D-78: $name — bugungi Lab va o‘qish yo‘llari ochiq', (
      tester,
    ) async {
      final s = await gatedApp(
        tester,
        guest: guest,
        expired: expired,
        product: expired ? BillingCatalog.specialistMonthly : null,
      );
      await pumpApp(tester, s, size: _tall);
      for (final path in [
        '/lab/differential/count',
        '/lab/qc/new',
        '/lab/calibration/log',
        '/learn/exam',
        '/learn/classes',
        '/lab/microscopy/quiz',
      ]) {
        await goTo(tester, path);
        expect(_locked, findsNothing, reason: path);
        expect(find.text(uz.proPurchaseTitle), findsNothing, reason: path);
      }
    });
  }
}
