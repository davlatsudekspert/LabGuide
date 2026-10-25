import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_service.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'billing_fakes.dart';
import 'export_fakes.dart';
import 'harness.dart';

/// Pro eshigi holatlari (D-78 testlari).
enum GateState {
  /// Hisob bor, obuna yo'q, to'lov ishlayapti — pullik amal yopiq.
  closed,

  /// 7 kunlik server sinovi faol.
  trial,

  /// Do'kon obunasi faol.
  subscribed,

  /// Obuna muddati o'tgan (7 kundan keyin) — pullik amal yopiq, ma'lumot qoladi.
  expired,

  /// Imzolangan kesh, internet yo'q (ilova qayta ochilgan).
  offline,

  /// Hisobsiz (mehmon) — pullik amal yopiq, to'lov oynasida "Hisobga kirish".
  guest,
}

/// Pro yoqilgan build, standart `ProGatePolicy.gated`, soxta do'kon/server.
/// [plan] — obuna/sinov rejasi (standart — Premium: hamma toifa).
Future<(AppServices, FakeFileSharer, FakeEntitlementSource)> proApp(
  WidgetTester tester,
  GateState state, {
  ProPlan plan = ProPlan.premium,
  AppLanguage language = AppLanguage.uz,
  ThemeMode themeMode = ThemeMode.light,
  MemoryKeyValueStore? store,
}) async {
  final server = FakeEntitlementSource(
    user: state == GateState.guest ? null : 'user-a',
  );
  final now = DateTime.now().toUtc();
  final spec = ProPricing.plans.firstWhere((p) => p.plan == plan);
  ServerEntitlement store0(EntitlementStatus status, DateTime end) =>
      ServerEntitlement(
        productId: spec.monthlyProductId,
        platform: 'app_store',
        status: status,
        startedAt: now.subtract(const Duration(days: 40)),
        expiresAt: end,
      );
  server.snapshot = EntitlementSnapshot(
    serverTime: now,
    trialUsed: state == GateState.trial,
    items: switch (state) {
      GateState.closed || GateState.guest => const [],
      GateState.subscribed || GateState.offline => [
        store0(EntitlementStatus.active, now.add(const Duration(days: 20))),
      ],
      GateState.expired => [
        store0(EntitlementStatus.expired, now.subtract(const Duration(days: 1))),
      ],
      GateState.trial => [
        ServerEntitlement(
          productId: 'trial.${plan.wire}',
          platform: 'trial',
          source: ServerEntitlement.trialSource,
          plan: plan,
          status: EntitlementStatus.active,
          startedAt: now.subtract(const Duration(days: 2)),
          expiresAt: now.add(const Duration(days: 5)),
          ownership: 'trial',
        ),
      ],
    },
  );
  final files = FakeFileSharer();
  final s = await makeServices(
    tester,
    store: store,
    language: language,
    themeMode: themeMode,
    proEnabled: true,
    allFeaturesOpen: false,
    purchases: FakePurchaseAdapter(),
    entitlementSource: server,
    fileSharer: files,
  );
  final ent = s.entitlements;
  await ent.refresh(reprobe: false);
  if (state == GateState.offline) {
    // Ilova qayta ochildi, internet yo'q: faqat imzolangan kesh.
    server.error = const EntitlementException(EntitlementFailure.network);
    await ent.load();
    await ent.refresh(reprobe: false);
    expect(ent.proSource, ProSource.offlineCache);
  }
  expect(ent.gatingActive, isTrue);
  expect(
    ent.isPro,
    switch (state) {
      GateState.trial || GateState.subscribed || GateState.offline => true,
      _ => false,
    },
    reason: state.name,
  );
  return (s, files, server);
}

/// Shu holatda pullik amal ochiqmi.
bool opens(GateState state) => switch (state) {
  GateState.trial || GateState.subscribed || GateState.offline => true,
  GateState.closed || GateState.expired || GateState.guest => false,
};
