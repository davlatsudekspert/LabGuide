// Lab Pro yopilishi (D-76, egasi qarori) — FAQAT REJA. Standart buildda
// (`ProGatePolicy.gated` bo'sh, Pro o'chiq) hech narsa yopilmaydi va yopiq
// belgi ko'rinmaydi. Yopish yoqilsa (`gatedFeatures: plannedLabGate` —
// faqat test/override): leykoformula ekrani OCHILADI va ko'rinadi, sanashni
// BOSHLASH esa to'lov oynasini ochadi; boshlangan sanash to'xtatilmaydi;
// Lab vositalari (koagulogramma, QC, kalkulyatorlar, apparatlar) har qanday
// kirish nuqtasidan yo'l darajasida yopiladi; Mutaxassis va Premium ochadi,
// Talaba va Ustoz — yo'q.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/billing_fakes.dart';
import '../helpers/harness.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 2400);

Finder _cell(DiffCell c) => find.byKey(ValueKey('diff-count-${c.name}'));
final _locked = find.byKey(const ValueKey('pay-locked'));

Future<void> _tapCell(WidgetTester tester, DiffCell c) async {
  await tester.ensureVisible(_cell(c));
  await tester.pumpAndSettle();
  await tester.tap(_cell(c));
  await tester.pumpAndSettle();
}

/// Pro yoqilgan sinov buildi + REJALASHTIRILGAN Lab yopilishi (override).
/// [product] — serverdagi faol obuna (`null` — bepul hisob).
Future<AppServices> _gated(WidgetTester tester, {String? product}) async {
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
    proEnabled: true,
    allFeaturesOpen: false,
    purchases: FakePurchaseAdapter(),
    entitlementSource: server,
    gatedFeatures: ProGatePolicy.plannedLabGate,
  );
  await s.entitlements.refresh(reprobe: false);
  expect(s.entitlements.gatingActive, isTrue);
  return s;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('standart build: Lab hech narsani yopmaydi, yopiq belgi yo‘q', (
    tester,
  ) async {
    expect(ProGatePolicy.gated, isEmpty);
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/lab/differential/count');
    await _tapCell(tester, DiffCell.segmented);
    expect(s.differential.count(DiffCell.segmented), 1);
    expect(_locked, findsNothing);
    for (final path in [
      '/lab/differential/interpret',
      '/lab/coagulogram/tests',
      '/lab/qc/new',
      '/lab/calculators/dilution',
      '/lab/calibration/log',
      '/lab/cytology/cells',
    ]) {
      await goTo(tester, path);
      expect(_locked, findsNothing, reason: path);
      expect(find.text(uz.proPurchaseTitle), findsNothing, reason: path);
    }
    // "Tez orada" / yopiq yozuvlar yo'q.
    await goTo(tester, '/lab');
    expect(find.textContaining(uz.notAvailableYet), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  testWidgets('yopish yoqilsa: leykoformula ochiladi, sanashni boshlash — '
      'to‘lov oynasi, hech narsa sanalmaydi', (tester) async {
    final s = await _gated(tester);
    await pumpApp(tester, s, size: _tall);
    // Kirish sahifasi va hisoblagich ekrani ochiladi va ko'rinadi.
    await goTo(tester, '/lab/differential');
    expect(find.text(uz.diffTitle), findsWidgets);
    expect(_locked, findsNothing);
    await goTo(tester, '/lab/differential/count');
    expect(find.text(uz.diffCounterTitle), findsWidgets);
    expect(_locked, findsNothing);
    // Birinchi bosish (sanashni boshlash) — to'lov oynasi.
    await _tapCell(tester, DiffCell.segmented);
    expect(s.differential.total, 0, reason: 'bosish sanalmadi');
    expect(_locked, findsOneWidget);
    expect(find.text(uz.proPayLockedLab), findsOneWidget);
  });

  testWidgets('yopish yoqilsa: boshlangan sanash to‘xtatilmaydi', (
    tester,
  ) async {
    final s = await _gated(tester);
    // Sanash obuna bor paytda boshlangan (masalan, obuna o'rtada tugadi).
    s.differential.tap(DiffCell.lymphocyte);
    expect(s.differential.total, 1);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/lab/differential/count');
    await _tapCell(tester, DiffCell.segmented);
    await _tapCell(tester, DiffCell.segmented);
    expect(s.differential.total, 3);
    expect(_locked, findsNothing);
  });

  testWidgets('yopish yoqilsa: Lab vositalari yo‘l darajasida yopiladi, '
      'kirish sahifalari ochiq', (tester) async {
    final s = await _gated(tester);
    await pumpApp(tester, s, size: _tall);
    for (final entry in [
      '/lab',
      '/lab/coagulogram',
      '/lab/qc',
      '/lab/calculators',
    ]) {
      await goTo(tester, entry);
      expect(_locked, findsNothing, reason: entry);
    }
    for (final tool in [
      '/lab/differential/interpret',
      '/lab/coagulogram/tests',
      '/lab/qc/new',
      '/lab/calculators/dilution',
      '/lab/calibration/log',
      '/lab/cytology/cells',
    ]) {
      await goTo(tester, tool);
      expect(find.text(uz.proPayLockedLab), findsOneWidget, reason: tool);
    }
    // Rasm mualliflari (litsenziya) yopilmaydi.
    await goTo(tester, '/lab/histology/credits');
    expect(_locked, findsNothing);
  });

  for (final (product, opens) in [
    (BillingCatalog.studentMonthly, false),
    (BillingCatalog.teacherYearly, false),
    (BillingCatalog.specialistMonthly, true),
    (BillingCatalog.premiumMonthly, true),
  ]) {
    testWidgets('yopish yoqilsa: ${BillingCatalog.planOf(product)!.name} '
        'rejasi — Lab ${opens ? 'ochiq' : 'yopiq'}', (tester) async {
      final s = await _gated(tester, product: product);
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/lab/differential/count');
      await _tapCell(tester, DiffCell.segmented);
      expect(s.differential.total, opens ? 1 : 0);
      expect(_locked, opens ? findsNothing : findsOneWidget);
      await goTo(tester, '/lab/qc/new');
      expect(_locked, opens ? findsNothing : findsOneWidget);
    });
  }
}
