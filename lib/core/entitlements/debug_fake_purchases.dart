import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'billing_catalog.dart';
import 'device_attestor.dart';
import 'entitlement_models.dart';
import 'entitlement_source.dart';
import 'pro_catalog.dart';
import 'purchase_adapter.dart';

/// FAQAT DEBUG: emulyatorda butun obuna oqimini do'kon va serversiz sinash
/// uchun soxta do'kon, soxta server va soxta attestatsiya (D-75).
///
/// Yoqish: `flutter run --dart-define=LG_PRO_ENABLED=true
/// --dart-define=LG_FAKE_PURCHASES=true` (debug/profile). Release buildda
/// IMKONSIZ: `BuildFlags.fakePurchases` = `!kReleaseMode && ...` — release'da
/// doimiy `false`, kompilyator bu kodni olib tashlaydi; konstruktorlar ham
/// release'da [StateError] tashlaydi. Qorovul:
/// `test/guards/pro_flag_default_guard_test.dart` (D-75 guruhi).
///
/// Hech qanday pul, haqiqiy do'kon yoki server ishtirok etmaydi; huquq faqat
/// xotirada (ilova qayta ochilsa yo'qoladi) va `environment: sandbox`.
void _debugOnly() {
  if (kReleaseMode) {
    throw StateError('debug fake purchases are not available in release');
  }
}

class DebugFakePurchaseAdapter extends ChangeNotifier
    implements PurchaseAdapter {
  DebugFakePurchaseAdapter({String? platform})
    : platform = platform ?? storePlatform() {
    _debugOnly();
  }

  final String platform;
  final _bought = <PurchaseProof>[];
  final _updates = StreamController<PurchaseProof>.broadcast();
  bool _ready = false;

  @override
  bool get isAvailable => _ready;

  @override
  List<StoreProduct> get loaded => [
    if (_ready)
      for (final spec in ProPricing.plans) ...[
        StoreProduct(
          id: spec.monthlyProductId,
          title: spec.plan.name,
          displayPrice: '\$${spec.monthlyUsd.toStringAsFixed(2)}',
          period: const StorePeriod(1, StorePeriodUnit.month),
        ),
        if (spec.yearlyUsd case final y?)
          StoreProduct(
            id: spec.yearlyProductId,
            title: spec.plan.name,
            displayPrice: '\$${y.toStringAsFixed(2)}',
            period: const StorePeriod(1, StorePeriodUnit.year),
          ),
      ],
  ];

  @override
  Future<void> init() async {
    _ready = true;
    notifyListeners();
  }

  @override
  Future<PurchaseProof?> buy(String productId, {String? accountToken}) async {
    if (BillingCatalog.byId(productId) == null) {
      throw const PurchaseUnavailableException();
    }
    final rnd = Random();
    final proof = PurchaseProof(
      platform: platform,
      productId: productId,
      token: 'debugfake${List.generate(16, (_) => rnd.nextInt(10)).join()}',
      purchasedAt: DateTime.now().toUtc(),
    );
    _bought
      ..removeWhere((p) => p.productId != productId)
      ..add(proof);
    return proof;
  }

  @override
  Future<List<PurchaseProof>> restore({bool userInitiated = true}) async =>
      List.of(_bought);

  @override
  Future<void> finish(PurchaseProof proof) async {}

  @override
  Stream<PurchaseProof> get updates => _updates.stream;

  @override
  void dispose() {
    unawaited(_updates.close());
    super.dispose();
  }
}

/// Soxta "server": sessiya ma'lumoti haqiqiy manbadan ([delegate]), xarid
/// va sinov esa xotirada tasdiqlanadi (sandbox).
class DebugFakeEntitlementSource implements EntitlementSource, TrialSource {
  DebugFakeEntitlementSource(this.delegate) {
    _debugOnly();
  }

  final EntitlementSource delegate;
  final _items = <ServerEntitlement>[];
  bool _trialUsed = false;

  @override
  bool get isConfigured => true;
  @override
  bool get billingReady => true;
  @override
  bool get trialOffered => true;
  @override
  String get platform => delegate.platform;
  @override
  bool get hasSession => delegate.hasSession;
  @override
  String? get userId => delegate.userId;

  @override
  Future<void> probe() async {}

  EntitlementSnapshot _snap() => EntitlementSnapshot(
    serverTime: DateTime.now().toUtc(),
    items: List.unmodifiable(_items),
    trialUsed: _trialUsed,
  );

  @override
  Future<EntitlementSnapshot> fetch() async => _snap();

  @override
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  }) async {
    final now = DateTime.now().toUtc();
    for (final p in proofs) {
      final product = BillingCatalog.byId(p.productId);
      if (product == null) continue;
      _items
        ..removeWhere((e) => e.isStore)
        ..add(
          ServerEntitlement(
            productId: product.id,
            platform: p.platform,
            status: EntitlementStatus.active,
            startedAt: now,
            expiresAt: now.add(
              Duration(days: product.period == BillingPeriod.year ? 365 : 30),
            ),
            environment: 'sandbox',
          ),
        );
    }
    return _snap();
  }

  @override
  Future<String> trialChallenge() async => 'debug' * 8;

  @override
  Future<EntitlementSnapshot> startTrial({
    required ProPlan plan,
    required String email,
    required String nonce,
    required DeviceAttestation attestation,
  }) async {
    if (_trialUsed) {
      throw const EntitlementException(
        EntitlementFailure.unknown,
        'trial_already_used',
      );
    }
    final now = DateTime.now().toUtc();
    _trialUsed = true;
    _items.add(
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
    );
    return _snap();
  }
}

/// Soxta attestatsiya (debug): har doim "mavjud".
class DebugFakeDeviceAttestor implements DeviceAttestor {
  DebugFakeDeviceAttestor() {
    _debugOnly();
  }

  @override
  bool get available => true;

  @override
  Future<DeviceAttestation> attest(String nonce) async => DeviceAttestation(
    platform: storePlatform() == 'app_store' ? 'ios' : 'android',
    token: 'debugfake:$nonce',
  );
}
