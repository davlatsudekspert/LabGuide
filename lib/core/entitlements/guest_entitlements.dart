import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/kv_store.dart';
import 'entitlement_models.dart';
import 'pro_catalog.dart';
import 'purchase_adapter.dart';

/// Mehmon (hisobsiz) xarid siyosati — server `GET /v1/billing/status` →
/// `guest` (D-77 addendum; Apple 5.1.1(v)): hisobga bog'liq bo'lmagan
/// imkoniyatlar (learner, lab) uchun hisob majburiy emas. Ilova o'zi qaror
/// qilmaydi — server bermasa mehmon xaridi yo'q (D-76 xatti-harakati).
@immutable
class GuestPolicy {
  const GuestPolicy({required this.purchasePlans, this.maxDevices = 5});

  /// `null` — server mehmon xaridini qo'llamaydi.
  static GuestPolicy? parse(Object? raw) {
    if (raw is! Map) return null;
    final plans = <ProPlan>{
      for (final p in (raw['purchase_plans'] as List?) ?? const [])
        ?ProPlan.parse(p),
    };
    if (plans.isEmpty) return null;
    return GuestPolicy(
      purchasePlans: plans,
      maxDevices: (raw['max_devices'] as num?)?.toInt() ?? 5,
    );
  }

  /// Mehmon sotib olishi mumkin bo'lgan rejalar (faqat-hisob imkoniyatisiz).
  final Set<ProPlan> purchasePlans;
  final int maxDevices;

  bool allows(ProPlan? plan) => plan != null && purchasePlans.contains(plan);
}

/// Mehmon do'kon huquqlari bilan ishlaydigan server manbai (Cloudflare).
abstract interface class GuestBillingSource {
  /// [EntitlementSource.probe] dan keyin; `null` — mehmon xaridi yo'q.
  GuestPolicy? get guestPolicy;

  /// `POST /v1/billing/guest/verify` — mehmon xaridi yoki tiklashi.
  Future<EntitlementSnapshot> guestVerify(
    List<PurchaseProof> proofs, {
    required String deviceId,
    required bool restore,
  });

  /// `POST /v1/billing/guest/entitlements` — saqlangan tokenlar bo'yicha holat.
  Future<EntitlementSnapshot> guestRefresh({
    required String deviceId,
    required List<String> tokens,
  });

  /// `POST /v1/billing/guest/link` (sessiya bilan) — mehmon xaridlarini
  /// hisobga o'tkazadi; javob — hisob surati.
  Future<EntitlementSnapshot> guestLink({
    required String deviceId,
    required List<String> tokens,
  });
}

/// Mehmon qurilma belgisi (tasodifiy, ilova darajasida; Keychain/Keystore)
/// va server bergan mehmon tokenlari.
abstract interface class GuestDeviceStore {
  Future<String> deviceId();
  Future<List<String>> tokens();
  Future<void> saveTokens(List<String> tokens);
}

class SecureGuestDeviceStore implements GuestDeviceStore {
  SecureGuestDeviceStore(this._kv);

  final KeyValueStore _kv;
  static const _name = 'labguide.guest.device';
  static const _storage = FlutterSecureStorage();

  @override
  Future<String> deviceId() async {
    final stored = await _storage.read(key: _name);
    if (stored != null) return stored;
    final id = _randomId();
    await _storage.write(key: _name, value: id);
    return id;
  }

  @override
  Future<List<String>> tokens() async => _decode(_kv.getString(_key));

  @override
  Future<void> saveTokens(List<String> tokens) => tokens.isEmpty
      ? _kv.remove(_key)
      : _kv.setString(_key, jsonEncode(tokens));

  static const _key = StoreKeys.guestEntitlements;
}

/// Testlar uchun.
class MemoryGuestDeviceStore implements GuestDeviceStore {
  MemoryGuestDeviceStore([this.id = 'guest-device-0001']);

  final String id;
  var saved = <String>[];

  @override
  Future<String> deviceId() async => id;
  @override
  Future<List<String>> tokens() async => List.of(saved);
  @override
  Future<void> saveTokens(List<String> tokens) async => saved = List.of(tokens);
}

String _randomId() {
  final rnd = Random.secure();
  return 'g-${List.generate(16, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
}

List<String> _decode(String? raw) {
  if (raw == null) return const [];
  try {
    return [
      for (final t in jsonDecode(raw) as List)
        if (t is String) t,
    ];
  } on Object {
    return const [];
  }
}
