import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import '../backend/backend_models.dart';
import '../backend/cloudflare_backend.dart';
import '../backend/supabase_backend.dart';
import 'billing_catalog.dart';
import 'device_attestor.dart';
import 'entitlement_models.dart';
import 'guest_entitlements.dart';
import 'pro_catalog.dart';
import 'purchase_adapter.dart';

/// Shu qurilmaning do'koni: `app_store` (iOS) yoki `play_store` (Android).
String storePlatform() =>
    defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS
    ? 'app_store'
    : 'play_store';

/// Server tasdiqlagan obuna holati manbai. Ilova faqat O'QIYDI; yozishni
/// server do'kon API'si bilan tekshirgandan keyin o'zi qiladi.
abstract interface class EntitlementSource {
  /// Server ulangan (huquqlarni o'qish mumkin).
  bool get isConfigured;

  /// Shu qurilma do'koni uchun serverda xarid tekshiruvi sozlangan
  /// ([probe] dan keyin ma'lum). `false` bo'lsa ilova to'lovni yoqmaydi.
  bool get billingReady;

  /// `app_store` yoki `play_store`.
  String get platform;
  bool get hasSession;
  String? get userId;

  /// Serverda to'lov sozlanganmi — bir marta (ilova ochilganda) so'raladi.
  Future<void> probe();

  /// Joriy foydalanuvchining huquqlari (`my_entitlements()`).
  Future<EntitlementSnapshot> fetch();

  /// Do'kon dalillarini serverda tekshirtirish (xarid yoki tiklash).
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  });
}

/// Bepul sinov (D-74): server bilan ishlaydigan manba. Server faqat
/// `LG_BILLING_ENABLED=true` va qurilma attestatsiyasi sozlanganda javob
/// beradi (aks holda 404/503 → [EntitlementFailure.notConfigured]).
abstract interface class TrialSource {
  /// Server imkoniyat so'rovi (D-75, `GET /v1/billing/status` → `trial`):
  /// shu qurilma platformasida sinov HOZIR boshlanishi mumkinmi (platforma
  /// `TRIAL_PLATFORMS` da VA server attestatsiyasi sozlangan). [probe] dan
  /// keyin ma'lum; standart `false` (iOS — Apple yozma javobigacha `false`).
  bool get trialOffered;

  /// `POST /v1/billing/trial/challenge` — bir martalik nonce.
  Future<String> trialChallenge();

  /// `POST /v1/billing/trial/start`. Xatoda [EntitlementException]
  /// (`detail` — server kodi, masalan `trial_already_used`).
  Future<EntitlementSnapshot> startTrial({
    required ProPlan plan,
    required String email,
    required String nonce,
    required DeviceAttestation attestation,
  });
}

/// Server ulanmagan build (yoki testdagi soxta backend).
class UnavailableEntitlementSource implements EntitlementSource {
  const UnavailableEntitlementSource();

  @override
  bool get isConfigured => false;
  @override
  bool get billingReady => false;
  @override
  String get platform => storePlatform();
  @override
  Future<void> probe() async {}
  @override
  bool get hasSession => false;
  @override
  String? get userId => null;

  @override
  Future<EntitlementSnapshot> fetch() async =>
      throw const EntitlementException(EntitlementFailure.notConfigured);

  @override
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  }) async =>
      throw const EntitlementException(EntitlementFailure.notConfigured);
}

/// Supabase: o'qish RLS ostida (`my_entitlements`), tekshiruv Edge Function.
///
/// `verify-purchase` Edge Function hali yozilmagan (doim 503) — shuning
/// uchun [billingReady] `false`: Supabase buildda to'lov oynasi yo'q.
/// Ishlaydigan tekshiruv — Cloudflare Worker ([CloudflareEntitlementSource]).
class SupabaseEntitlementSource implements EntitlementSource {
  SupabaseEntitlementSource(this.backend);

  final SupabaseLabBackend backend;

  @override
  bool get isConfigured => true;
  @override
  bool get billingReady => false;
  @override
  String get platform => storePlatform();
  @override
  Future<void> probe() async {}
  @override
  bool get hasSession => backend.hasSession;
  @override
  String? get userId => backend.userId;

  @override
  Future<EntitlementSnapshot> fetch() => _guard(() async {
    final data = await backend.client.rpc<Object?>('my_entitlements');
    return EntitlementSnapshot.fromJson((data! as Map).cast<String, Object?>());
  });

  @override
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  }) => _guard(() async {
    if (proofs.isEmpty) return fetch();
    final platform = proofs.first.platform;
    final body = <String, Object?>{
      'action': restore ? 'restore' : 'verify',
      'platform': platform,
    };
    if (platform == 'app_store') {
      if (restore) {
        body['transaction_ids'] = [for (final p in proofs) p.token];
      } else {
        body['transaction_id'] = proofs.first.token;
      }
    } else if (restore) {
      body['purchases'] = [
        for (final p in proofs)
          {'product_id': p.productId, 'purchase_token': p.token},
      ];
    } else {
      body['product_id'] = proofs.first.productId;
      body['purchase_token'] = proofs.first.token;
    }
    final res = await backend.client.functions.invoke(
      'verify-purchase',
      body: body,
    );
    return EntitlementSnapshot.fromJson(
      (res.data as Map).cast<String, Object?>(),
    );
  });

  static Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FunctionException catch (e) {
      throw EntitlementException(switch (e.status) {
        503 => EntitlementFailure.notConfigured,
        401 => EntitlementFailure.unauthorized,
        _ => EntitlementFailure.unknown,
      }, 'function ${e.status}');
    } on PostgrestException catch (e) {
      throw EntitlementException(EntitlementFailure.unknown, '${e.code}');
    } on SocketException catch (e) {
      throw EntitlementException(EntitlementFailure.network, '$e');
    } on http.ClientException catch (e) {
      throw EntitlementException(EntitlementFailure.network, '$e');
    } on TimeoutException catch (e) {
      throw EntitlementException(EntitlementFailure.network, '$e');
    } on AuthException catch (e) {
      throw EntitlementException(EntitlementFailure.unauthorized, e.code);
    }
  }
}

/// Cloudflare Worker (`cloudflare/src/billing.ts`): `GET /v1/billing/status`,
/// `GET /v1/billing/entitlements`, `POST /v1/billing/verify`.
class CloudflareEntitlementSource
    implements EntitlementSource, TrialSource, GuestBillingSource {
  CloudflareEntitlementSource(this.backend, {String? platform})
    : platform = platform ?? storePlatform();

  final CloudflareLabBackend backend;

  @override
  final String platform;

  bool _billing = false;
  bool _trial = false;
  GuestPolicy? _guest;

  @override
  GuestPolicy? get guestPolicy => _guest;

  @override
  bool get trialOffered => _trial;

  /// `ios` / `android` — server `trial` xaritasidagi kalit.
  String get _trialKey => platform == 'app_store' ? 'ios' : 'android';

  @override
  bool get isConfigured => true;
  @override
  bool get billingReady => _billing;
  @override
  bool get hasSession => backend.hasSession;
  @override
  String? get userId => backend.userId;

  @override
  Future<void> probe() async {
    try {
      final r = await backend.billing('GET', '/v1/billing/status', auth: false);
      _billing = r.status == 200 && r.data[platform] == true;
      final trial = r.data['trial'];
      _trial = r.status == 200 && trial is Map && trial[_trialKey] == true;
      _guest = r.status == 200 ? GuestPolicy.parse(r.data['guest']) : null;
    } on Object catch (e) {
      // Internet yo'q — to'lov yoqilmaydi (hamma imkoniyat ochiq qoladi).
      debugPrint('billing status: $e');
      _billing = false;
      _trial = false;
      _guest = null;
    }
  }

  @override
  Future<EntitlementSnapshot> fetch() =>
      _snapshot(() => backend.billing('GET', '/v1/billing/entitlements'));

  @override
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  }) {
    if (proofs.isEmpty) return fetch();
    final body = <String, Object?>{
      'platform': proofs.first.platform,
      'restore': restore,
      // Play tiklashda base plan noma'lum bo'lishi mumkin (obuna id si) —
      // `product_id` yuborilmaydi, server do'kondan aniqlaydi.
      if (proofs.length == 1) ...{
        'product_id': ?_canonical(proofs.first.productId),
        'token': proofs.first.token,
      } else
        'purchases': [
          for (final p in proofs)
            {'product_id': ?_canonical(p.productId), 'token': p.token},
        ],
    };
    return _snapshot(
      () => backend.billing('POST', '/v1/billing/verify', body: body),
    );
  }

  static List<Map<String, Object?>> _purchases(List<PurchaseProof> proofs) => [
    for (final p in proofs)
      {'product_id': ?_canonical(p.productId), 'token': p.token},
  ];

  @override
  Future<EntitlementSnapshot> guestVerify(
    List<PurchaseProof> proofs, {
    required String deviceId,
    required bool restore,
  }) => _snapshot(
    () => backend.billing(
      'POST',
      '/v1/billing/guest/verify',
      auth: false,
      body: {
        'platform': proofs.first.platform,
        'device_id': deviceId,
        'restore': restore,
        'purchases': _purchases(proofs),
      },
    ),
  );

  @override
  Future<EntitlementSnapshot> guestRefresh({
    required String deviceId,
    required List<String> tokens,
  }) => _snapshot(
    () => backend.billing(
      'POST',
      '/v1/billing/guest/entitlements',
      auth: false,
      body: {'device_id': deviceId, 'guest_tokens': tokens},
    ),
  );

  @override
  Future<EntitlementSnapshot> guestLink({
    required String deviceId,
    required List<String> tokens,
  }) => _snapshot(
    () => backend.billing(
      'POST',
      '/v1/billing/guest/link',
      body: {'device_id': deviceId, 'guest_tokens': tokens},
    ),
  );

  @override
  Future<String> trialChallenge() async {
    final ({int status, Map<String, Object?> data}) r;
    try {
      r = await backend.billing('POST', '/v1/billing/trial/challenge');
    } on BackendException catch (e) {
      throw EntitlementException(_failure(e), e.detail);
    }
    final nonce = r.data['nonce'];
    if (r.status == 200 && nonce is String) return nonce;
    throw EntitlementException(
      r.status == 503 || r.status == 404
          ? EntitlementFailure.notConfigured
          : EntitlementFailure.unknown,
      r.data['error'] as String? ?? '${r.status}',
    );
  }

  @override
  Future<EntitlementSnapshot> startTrial({
    required ProPlan plan,
    required String email,
    required String nonce,
    required DeviceAttestation attestation,
  }) => _snapshot(
    () => backend.billing(
      'POST',
      '/v1/billing/trial/start',
      body: {
        'tier': plan.wire,
        'email': email,
        'attestation': attestation.toJson(nonce),
      },
    ),
  );

  static String? _canonical(String id) =>
      BillingCatalog.ids.contains(id) ? id : null;

  static EntitlementFailure _failure(BackendException e) => switch (e.failure) {
    BackendFailure.network => EntitlementFailure.network,
    BackendFailure.unauthorized => EntitlementFailure.unauthorized,
    BackendFailure.unavailable => EntitlementFailure.notConfigured,
    _ => EntitlementFailure.unknown,
  };

  static Future<EntitlementSnapshot> _snapshot(
    Future<({int status, Map<String, Object?> data})> Function() run,
  ) async {
    final ({int status, Map<String, Object?> data}) r;
    try {
      r = await run();
    } on BackendException catch (e) {
      throw EntitlementException(_failure(e), e.detail);
    }
    if (r.status >= 200 && r.status < 300) {
      try {
        return EntitlementSnapshot.fromJson(r.data);
      } on Object catch (e) {
        throw EntitlementException(EntitlementFailure.unknown, 'parse $e');
      }
    }
    final code = r.data['error'] as String?;
    throw EntitlementException(switch (r.status) {
      503 || 501 => EntitlementFailure.notConfigured,
      401 => EntitlementFailure.unauthorized,
      409 when code == 'purchase_pending' => EntitlementFailure.pending,
      502 || 504 => EntitlementFailure.network,
      _ => EntitlementFailure.unknown,
    }, code ?? '${r.status}');
  }
}
