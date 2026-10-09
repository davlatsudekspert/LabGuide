import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import '../backend/supabase_backend.dart';
import 'entitlement_models.dart';
import 'purchase_adapter.dart';

/// Server tasdiqlagan obuna holati manbai. Ilova faqat O'QIYDI; yozish
/// `verify-purchase` Edge Function (service role) ichida.
abstract interface class EntitlementSource {
  bool get isConfigured;
  bool get hasSession;
  String? get userId;

  /// Joriy foydalanuvchining huquqlari (`my_entitlements()`).
  Future<EntitlementSnapshot> fetch();

  /// Do'kon dalillarini serverda tekshirtirish (xarid yoki tiklash).
  Future<EntitlementSnapshot> verify(
    List<PurchaseProof> proofs, {
    required bool restore,
  });
}

/// Server ulanmagan build (yoki testdagi soxta backend).
class UnavailableEntitlementSource implements EntitlementSource {
  const UnavailableEntitlementSource();

  @override
  bool get isConfigured => false;
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
class SupabaseEntitlementSource implements EntitlementSource {
  SupabaseEntitlementSource(this.backend);

  final SupabaseLabBackend backend;

  @override
  bool get isConfigured => true;
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
