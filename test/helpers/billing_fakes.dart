import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';
import 'package:labguide/core/entitlements/entitlement_models.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';

/// Server o'rnida: javob yoki xato (internet yo'q). [billing] — serverda
/// do'kon kalitlari sozlanganmi (`GET /v1/billing/status`).
class FakeEntitlementSource implements EntitlementSource {
  FakeEntitlementSource({
    this.user = 'user-a',
    this.billing = true,
    this.platform = 'app_store',
  });

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

/// Do'kondagi kabi mahsulotlar (narx — do'kon formatida, ilovada qotirilmagan).
/// Qiymatlar — egasi narxlari (D-73, 2026-10-24; Pro hali YOQILMAGAN);
/// `freeTrial` esa faqat "do'kon kirish taklifi qaytardi" holatini sinash
/// uchun fixture (30 kun — ilova uni do'kondan o'qiydi, o'zi hech narsa
/// belgilamaydi).
List<StoreProduct> storeProducts() => const [
  StoreProduct(
    id: BillingCatalog.specialistMonthly,
    title: 'LabGuide Mutaxassis',
    displayPrice: r'$3.49',
    period: StorePeriod(1, StorePeriodUnit.month),
    freeTrial: StorePeriod(30, StorePeriodUnit.day),
  ),
  StoreProduct(
    id: BillingCatalog.specialistYearly,
    title: 'LabGuide Mutaxassis',
    displayPrice: r'$34.99',
    period: StorePeriod(1, StorePeriodUnit.year),
  ),
  StoreProduct(
    id: BillingCatalog.studentMonthly,
    title: 'LabGuide Talaba',
    displayPrice: r'$1.49',
    period: StorePeriod(1, StorePeriodUnit.month),
  ),
  StoreProduct(
    id: BillingCatalog.studentYearly,
    title: 'LabGuide Talaba',
    displayPrice: r'$9.99',
    period: StorePeriod(1, StorePeriodUnit.year),
  ),
  StoreProduct(
    id: BillingCatalog.teacherMonthly,
    title: 'LabGuide Ustoz',
    displayPrice: r'$2.49',
    period: StorePeriod(1, StorePeriodUnit.month),
  ),
  StoreProduct(
    id: BillingCatalog.teacherYearly,
    title: 'LabGuide Ustoz',
    displayPrice: r'$24.99',
    period: StorePeriod(1, StorePeriodUnit.year),
  ),
];
