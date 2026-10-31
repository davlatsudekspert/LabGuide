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
    this.periodType = StorePeriodType.normal,
    this.autoRenew,
    this.pendingProductId,
  });

  /// Manba: do'kon obunasi.
  static const storeSource = 'store';

  /// Manba: admin bergan Pro (D-73; `platform == 'admin_grant'`).
  static const adminGrantSource = 'admin_grant';

  /// Manba: 30 kunlik bepul sinov (D-74/D-80; `platform == 'trial'`).
  static const trialSource = 'trial';

  /// Manba: mehmon (hisobsiz) do'kon xaridi (D-77 addendum, Apple 5.1.1(v)).
  /// Faqat hisobga bog'liq bo'lmagan imkoniyatlar ochiladi (`teacher_panel` yo'q).
  static const guestStoreSource = 'store_guest';

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
          switch (j['platform']) {
            adminGrantSource => adminGrantSource,
            trialSource => trialSource,
            _ => storeSource,
          },
      plan: ProPlan.parse(j['plan']),
      periodType: StorePeriodType.parse(j['period_type']),
      autoRenew: j['auto_renew'] is bool ? j['auto_renew']! as bool : null,
      pendingProductId: j['pending_product_id'] as String?,
    );
  }

  final String productId;
  final String platform;
  final EntitlementStatus status;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final String ownership;
  final String environment;

  /// `store`, `admin_grant` yoki `trial` (server `source`).
  final String source;

  /// Admin grant darajasi (do'kon xaridida `null` — mahsulotdan olinadi).
  final ProPlan? plan;

  bool get isAdminGrant => source == adminGrantSource;

  /// Do'kon davri: do'kon bepul sinovi / kirish narxi (huquq to'liq).
  final StorePeriodType periodType;

  /// Avtomatik yangilanadimi (`false` — bekor qilingan, davr oxirigacha
  /// amal qiladi; `null` — noma'lum).
  final bool? autoRenew;

  /// Keyingi yangilanishda o'tadigan mahsulot (pastga tushirish).
  final String? pendingProductId;

  /// Mehmon (hisobsiz) xarid — `teacher_panel` ochilmaydi (faqat hisob bilan).
  bool get isGuest => source == guestStoreSource;

  /// Bepul sinov qatori (pullik obunani hech qachon bosib o'tmaydi).
  bool get isTrial => source == trialSource;

  /// Do'kon xaridi (pullik obuna).
  bool get isStore => !isAdminGrant && !isTrial;

  /// Pullik daraja: grantda — serverdan, xaridda — mahsulot id'sidan.
  ProPlan? get effectivePlan => plan ?? BillingCatalog.planOf(productId);

  /// Ochadigan imkoniyatlar (katalogda yo'q mahsulot — faqat Talaba
  /// to'plami, server bilan bir xil). Mehmon xaridida faqat-hisob
  /// imkoniyatlari ([accountOnlyCapabilities]) olib tashlanadi.
  ProTier get tier {
    final t = (effectivePlan ?? ProPlan.student).tier;
    if (!isGuest) return t;
    return ProTier({
      for (final c in t.capabilities)
        if (!accountOnlyCapabilities.contains(c)) c,
    });
  }

  /// Faqat hisob bilan ochiladigan imkoniyatlar (server `ACCOUNT_ONLY_CAPABILITIES`).
  static const accountOnlyCapabilities = {ProCapability.teacherPanel};

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
    'period_type': periodType.wire,
    if (autoRenew != null) 'auto_renew': autoRenew,
    if (pendingProductId != null) 'pending_product_id': pendingProductId,
  };
}

/// Do'kon obuna davri turi (server `period_type`).
enum StorePeriodType {
  normal,

  /// Do'kon bepul sinovi (Apple intro FREE_TRIAL / Play free trial bosqichi).
  trial,

  /// Chegirmali kirish narxi.
  intro;

  static StorePeriodType parse(Object? raw) => switch (raw) {
    'trial' => trial,
    'intro' => intro,
    _ => normal,
  };

  String get wire => name;
}

/// `GET /v1/billing/entitlements` / `POST /v1/billing/verify` javobi.
@immutable
class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.serverTime,
    required this.items,
    this.ownedByOther = false,
    this.trialUsed = false,
    this.offlineUntil,
    this.guestTokens = const [],
    this.signInRequired = false,
  });

  factory EntitlementSnapshot.fromJson(Map<String, Object?> j) =>
      EntitlementSnapshot(
        serverTime: DateTime.parse(j['server_time']! as String).toUtc(),
        items: [
          for (final e in (j['items'] as List?) ?? const [])
            ServerEntitlement.fromJson((e as Map).cast<String, Object?>()),
        ],
        ownedByOther: j['owned_by_other'] == true,
        trialUsed: j['trial_used'] == true,
        offlineUntil: j['offline_until'] is String
            ? DateTime.tryParse(j['offline_until']! as String)?.toUtc()
            : null,
        guestTokens: [
          for (final t in (j['guest_tokens'] as List?) ?? const [])
            if (t is String) t,
        ],
        signInRequired: j['sign_in_required'] == true,
      );

  final DateTime serverTime;
  final List<ServerEntitlement> items;

  /// Tiklashda topilgan xarid boshqa hisobga bog'langan.
  final bool ownedByOther;

  /// Shu hisob bepul sinovdan foydalangan (D-74).
  final bool trialUsed;

  /// Server bergan oflayn chegarasi (D-75, server soati bilan):
  /// min(javob vaqti + 7 kun, amaldagi huquq tugashi). Ilova keshni bundan
  /// keyin huquq sifatida ishlatmaydi. `null` — eski server (faqat lokal 7 kun).
  final DateTime? offlineUntil;

  /// Mehmon javobi (`/v1/billing/guest/*`): do'kon tranzaksiyasi + qurilmaga
  /// bog'langan imzolangan tokenlar (hisobga kirilganda bog'lash uchun).
  final List<String> guestTokens;

  /// Mehmon: xarid hisobga bog'langan — huquq uchun hisobga kirish kerak.
  final bool signInRequired;
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
