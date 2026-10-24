import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/device_attestor.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';

/// Server o'rnida: javob yoki xato (internet yo'q). [billing] — serverda
/// do'kon kalitlari sozlanganmi (`GET /v1/billing/status`).
class FakeEntitlementSource implements EntitlementSource, TrialSource {
  FakeEntitlementSource({
    this.user = 'user-a',
    this.billing = true,
    this.platform = 'app_store',
    this.trialOffered = false,
  });

  /// Server imkoniyat so'rovi (D-75): shu platformada sinov bormi.
  @override
  bool trialOffered;

  /// Sinov so'rovlari (kuzatish uchun).
  final trialStarts = <ProPlan>[];
  String? trialError;

  @override
  Future<String> trialChallenge() async => 'n' * 43;

  @override
  Future<EntitlementSnapshot> startTrial({
    required ProPlan plan,
    required String email,
    required String nonce,
    required DeviceAttestation attestation,
  }) async {
    trialStarts.add(plan);
    if (trialError != null) {
      throw EntitlementException(EntitlementFailure.unknown, trialError);
    }
    final now = DateTime.now().toUtc();
    snapshot = EntitlementSnapshot(
      serverTime: now,
      trialUsed: true,
      items: [
        ServerEntitlement(
          productId: 'trial.${plan.wire}',
          platform: 'trial',
          source: ServerEntitlement.trialSource,
          plan: plan,
          status: EntitlementStatus.active,
          startedAt: now,
          expiresAt: now.add(
            const Duration(days: ProTrialConfig.serverTrialDays),
          ),
          ownership: 'trial',
        ),
      ],
    );
    return snapshot!;
  }

  String? user;
  bool billing;
  EntitlementSnapshot? snapshot;
  Object? error;
  List<PurchaseProof>? verified;
  bool? verifiedRestore;
  int probes = 0;

  @override
  final String platform;

  @override
  bool get isConfigured => true;
  @override
  bool get billingReady => billing;
  @override
  bool get hasSession => user != null;
  @override
  String? get userId => user;

  @override
  Future<void> probe() async => probes++;

  @override
  Future<EntitlementSnapshot> fetch() async {
    if (error != null) throw error!;
    return snapshot ??
        EntitlementSnapshot(
          serverTime: DateTime.now().toUtc(),
          items: const [],
        );
  }

  @override
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  }) async {
    verified = proofs;
    verifiedRestore = restore;
    return fetch();
  }
}

/// Do'kon o'rnida (StoreKit / Play yo'q). [available] — mahsulotlar
/// yuklanganmi; [products] — do'kon narxlari.
class FakePurchaseAdapter extends ChangeNotifier implements PurchaseAdapter {
  FakePurchaseAdapter({
    this.available = true,
    List<StoreProduct>? products,
    this.proofs = const [],
  }) : products = products ?? storeProducts();

  bool available;
  List<StoreProduct> products;

  /// `buy` / `restore` natijasi.
  List<PurchaseProof> proofs;

  /// `buy` shu xatoni tashlaydi (masalan, [PurchasePendingException]).
  Object? buyError;
  bool cancel = false;
  final finished = <PurchaseProof>[];
  final bought = <(String, String?)>[];
  int inits = 0;
  final _updates = StreamController<PurchaseProof>.broadcast();

  void setAvailable(bool v) {
    available = v;
    notifyListeners();
  }

  /// Do'kon o'zi yuborgan tranzaksiya (yangilanish, Ask to Buy).
  void emit(PurchaseProof p) => _updates.add(p);

  @override
  bool get isAvailable => available && products.isNotEmpty;
  @override
  List<StoreProduct> get loaded => available ? products : const [];
  @override
  Future<void> init() async => inits++;

  @override
  Future<PurchaseProof?> buy(String productId, {String? accountToken}) async {
    bought.add((productId, accountToken));
    if (buyError != null) throw buyError!;
    if (cancel) return null;
    return proofs.where((p) => p.productId == productId).firstOrNull ??
        proofs.firstOrNull;
  }

  @override
  Future<List<PurchaseProof>> restore({bool userInitiated = true}) async =>
      proofs;

  @override
  Future<void> finish(PurchaseProof proof) async => finished.add(proof);

  @override
  Stream<PurchaseProof> get updates => _updates.stream;
}

/// Soxta attestatsiya (testlar): har doim "mavjud".
class FakeDeviceAttestor implements DeviceAttestor {
  @override
  bool get available => true;
  @override
  Future<DeviceAttestation> attest(String nonce) async =>
      DeviceAttestation(platform: 'android', token: 'fake:phone:$nonce');
}

/// Do'kondagi kabi mahsulotlar (narx — do'kon formatida, ilovada qotirilmagan).
/// Narxlar YAGONA manbadan — `ProPricing.plans` (D-73, egasi narxlari); bu
/// yerda qotirilmaydi (D-75: UI, server va testlarda zid narx bo'lmasin).
/// `freeTrial` — "do'kon kirish taklifi qaytardi" holati: ilova uni
/// ko'rsatmasligini sinash uchun (D-75, `storeIntroOffersAllowed = false`).
List<StoreProduct> storeProducts() {
  final out = <StoreProduct>[];
  for (final id in [
    BillingCatalog.specialistMonthly,
    BillingCatalog.specialistYearly,
    BillingCatalog.studentMonthly,
    BillingCatalog.studentYearly,
    BillingCatalog.teacherMonthly,
    BillingCatalog.teacherYearly,
  ]) {
    final spec = ProPricing.plans.firstWhere(
      (p) => p.monthlyProductId == id || p.yearlyProductId == id,
    );
    final yearly = spec.yearlyProductId == id;
    out.add(
      StoreProduct(
        id: id,
        title: 'LabGuide ${spec.plan.name}',
        displayPrice:
            '\$${(yearly ? spec.yearlyUsd! : spec.monthlyUsd).toStringAsFixed(2)}',
        period: StorePeriod(
          1,
          yearly ? StorePeriodUnit.year : StorePeriodUnit.month,
        ),
        freeTrial: id == BillingCatalog.specialistMonthly
            ? const StorePeriod(30, StorePeriodUnit.day)
            : null,
      ),
    );
  }
  return out;
}
