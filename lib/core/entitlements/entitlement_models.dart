import 'package:flutter/foundation.dart';

import 'billing_catalog.dart';
import 'feature.dart';
import 'pro_catalog.dart';

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
    this.token,
    this.source = storeSource,
    this.plan,
  });

  /// Manba: do'kon obunasi.
  static const storeSource = 'store';

  /// Manba: admin bergan Pro (D-73; `platform == 'admin_grant'`).
  static const adminGrantSource = 'admin_grant';

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
      source:
          (j['source'] as String?) ??
          (j['platform'] == adminGrantSource ? adminGrantSource : storeSource),
      plan: ProPlan.parse(j['plan']),
    );
  }

  final String productId;
  final String platform;
  final EntitlementStatus status;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final String ownership;
  final String environment;

  /// `store` yoki `admin_grant` (server `source`).
  final String source;

  /// Admin grant darajasi (do'kon xaridida `null` — mahsulotdan olinadi).
  final ProPlan? plan;

  bool get isAdminGrant => source == adminGrantSource;

  /// Pullik daraja: grantda — serverdan, xaridda — mahsulot id'sidan.
  ProPlan? get effectivePlan => plan ?? BillingCatalog.planOf(productId);

  /// Ilova darajasi (katalogda yo'q mahsulot — Pro).
  ProTier get tier => effectivePlan?.tier ?? ProTier.pro;

  /// Faqat qurilmadagi (mehmon) xarid uchun: do'kon tokeni — hisobga
  /// kirilganda serverga yuboriladi. Keshga yozilmaydi.
  final String? token;

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
    'source': source,
    if (plan != null) 'plan': plan!.wire,
  };
}

/// `GET /v1/billing/entitlements` / `POST /v1/billing/verify` javobi.
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
  /// Server yoki to'lov sozlanmagan (do'kon kalitlari yo'q).
  notConfigured,

  /// Do'konda to'lov hali kutilmoqda (Play: naqd to'lov va h.k.).
  pending,
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
