import 'package:flutter/foundation.dart';

/// Server (do'kon tekshirgan) obuna holati — `entitlements.status`.
enum EntitlementStatus {
  active,
  gracePeriod,
  billingRetry,
  paused,
  expired,
  revoked,
  unknown;

  static EntitlementStatus parse(Object? raw) => switch (raw) {
    'active' => active,
    'grace_period' => gracePeriod,
    'billing_retry' => billingRetry,
    'paused' => paused,
    'expired' => expired,
    'revoked' => revoked,
    _ => unknown,
  };

  String get wire => switch (this) {
    active => 'active',
    gracePeriod => 'grace_period',
    billingRetry => 'billing_retry',
    paused => 'paused',
    expired => 'expired',
    revoked => 'revoked',
    unknown => 'unknown',
  };

  /// Huquq beradigan holatlar (imtiyoz davri — do'kon qoidasi bo'yicha ha).
  bool get grants => this == active || this == gracePeriod;
}

/// Pro amalda bo'lgan oraliq: shu oraliqda saqlangan natijalar obuna
/// tugagandan keyin ham ko'rinadi.
@immutable
class ProPeriod {
  const ProPeriod(this.start, this.end);

  final DateTime start;

  /// `null` — muddatsiz.
  final DateTime? end;

  bool contains(DateTime t) =>
      !t.isBefore(start) && (end == null || !t.isAfter(end!));
}

/// Bitta do'kon xaridi (obuna) — server qatori.
@immutable
class ServerEntitlement {
  const ServerEntitlement({
    required this.productId,
    required this.platform,
    required this.status,
    this.startedAt,
    this.expiresAt,
    this.ownership = 'purchased',
    this.environment = 'production',
  });

  factory ServerEntitlement.fromJson(Map<String, Object?> j) {
    DateTime? date(String k) =>
        j[k] == null ? null : DateTime.parse(j[k]! as String).toUtc();
    return ServerEntitlement(
      productId: j['product_id']! as String,
      platform: j['platform']! as String,
      status: EntitlementStatus.parse(j['status']),
      startedAt: date('started_at'),
      expiresAt: date('expires_at'),
      ownership: (j['ownership'] as String?) ?? 'purchased',
      environment: (j['environment'] as String?) ?? 'production',
    );
  }

  final String productId;
  final String platform;
  final EntitlementStatus status;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final String ownership;
  final String environment;

  /// [t] paytida Pro beradimi.
  bool grantsAt(DateTime t) =>
      status.grants && (expiresAt == null || expiresAt!.isAfter(t));

  /// Pro davri. Qaytarilgan (refund) xarid davr hisoblanmaydi.
  ProPeriod? get period =>
      status == EntitlementStatus.revoked ||
          status == EntitlementStatus.unknown ||
          startedAt == null
      ? null
      : ProPeriod(startedAt!, expiresAt);

  Map<String, Object?> toJson() => {
    'product_id': productId,
    'platform': platform,
    'status': status.wire,
    'started_at': startedAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'ownership': ownership,
    'environment': environment,
  };
}

/// `my_entitlements()` / `verify-purchase` javobi.
@immutable
class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.serverTime,
    required this.items,
    this.ownedByOther = false,
  });

  factory EntitlementSnapshot.fromJson(Map<String, Object?> j) =>
      EntitlementSnapshot(
        serverTime: DateTime.parse(j['server_time']! as String).toUtc(),
        items: [
          for (final e in (j['items'] as List?) ?? const [])
            ServerEntitlement.fromJson((e as Map).cast<String, Object?>()),
        ],
        ownedByOther: j['owned_by_other'] == true,
      );

  final DateTime serverTime;
  final List<ServerEntitlement> items;

  /// Tiklashda topilgan xarid boshqa hisobga bog'langan.
  final bool ownedByOther;
}

enum EntitlementFailure {
  /// Server yoki to'lov sozlanmagan (narx tasdiqlanmagan).
  notConfigured,
  network,
  unauthorized,
  unknown,
}

class EntitlementException implements Exception {
  const EntitlementException(this.failure, [this.detail]);

  final EntitlementFailure failure;
  final String? detail;

  @override
  String toString() =>
      'EntitlementException($failure${detail == null ? '' : ': $detail'})';
}
