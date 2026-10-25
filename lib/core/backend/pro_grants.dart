import 'package:flutter/foundation.dart';

import '../entitlements/pro_catalog.dart';
import 'backend_models.dart';

/// Admin tomonidan Pro berish (D-73). Faqat Cloudflare serveri; server
/// `LG_BILLING_ENABLED=true` bo'lmasa bu yo'llarni umuman bermaydi (404).
/// Ilova bo'limni faqat `BuildFlags.proEnabled` VA admin bo'lganda ko'rsatadi;
/// vakolatni har so'rovda server (admin roli + TOTP) tekshiradi.
abstract interface class ProGrantBackend {
  /// Faol va kutilayotgan grantlar.
  Future<List<ProGrant>> proGrants();

  /// Email bo'yicha berish. Mavjud faol grant bo'lsa: [extend] `false` —
  /// almashtiradi (muddat hozirdan), `true` — uzaytiradi.
  Future<ProGrantResult> grantPro({
    required String email,
    required ProPlan plan,
    int? durationDays,
    String? note,
    bool extend = false,
  });

  /// Grantni bekor qilish (huquq darhol yo'qoladi).
  Future<void> revokePro(String id);
}

/// Tez tanlash muddatlari (kun); `null` — bekor qilinguncha. Admin shu bilan
/// birga o'zi kun yoki oy kiritadi (server: butun kun, 1…[proGrantMaxDays]).
const proGrantDurations = <int?>[7, 30, 90, 365, null];

/// Eng uzun muddat (kun) — server bilan bir xil. 1 oy = 30 kun.
const proGrantMaxDays = 3650;
const proGrantDaysPerMonth = 30;

/// Izohning eng uzun hajmi (server bilan bir xil).
const proGrantNoteMax = 200;

enum ProGrantStatus {
  active,
  pending,
  expired;

  static ProGrantStatus parse(Object? raw) => switch (raw) {
    'pending' => pending,
    'expired' => expired,
    _ => active,
  };
}

@immutable
class ProGrant {
  const ProGrant({
    required this.id,
    required this.emailMasked,
    required this.plan,
    required this.status,
    this.durationDays,
    this.startsAt,
    this.expiresAt,
    this.note,
    this.createdAt,
  });

  factory ProGrant.fromJson(Map<String, Object?> j) => ProGrant(
    id: j['id']! as String,
    emailMasked: j['email_masked'] as String? ?? '—',
    plan: ProPlan.parse(j['tier']) ?? ProPlan.student,
    status: ProGrantStatus.parse(j['status']),
    durationDays: (j['duration_days'] as num?)?.toInt(),
    startsAt: DateTime.tryParse(j['starts_at'] as String? ?? ''),
    expiresAt: DateTime.tryParse(j['expires_at'] as String? ?? ''),
    note: j['note'] as String?,
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
  );

  final String id;
  final String emailMasked;
  final ProPlan plan;
  final ProGrantStatus status;

  /// `null` — bekor qilinguncha.
  final int? durationDays;
  final DateTime? startsAt;

  /// `null` — muddatsiz yoki hali boshlanmagan (kutilmoqda).
  final DateTime? expiresAt;
  final String? note;
  final DateTime? createdAt;

  bool get pending => status == ProGrantStatus.pending;
}

@immutable
class ProGrantResult {
  const ProGrantResult({
    required this.grant,
    this.replaced = false,
    this.extended = false,
  });

  factory ProGrantResult.fromJson(Map<String, Object?> j) => ProGrantResult(
    grant: ProGrant.fromJson(j),
    replaced: j['replaced'] == true,
    extended: j['extended'] == true,
  );

  final ProGrant grant;
  final bool replaced;
  final bool extended;
}

/// Server xato kodi bilan (`invalid_email`, `invalid_tier`,
/// `invalid_duration`, `invalid_note`, `pending_cannot_extend`,
/// `duration_required`, `too_many_grants`, `rate_limited`).
class ProGrantException extends BackendException {
  const ProGrantException(BackendFailure failure, String? code, [String? detail])
    : super(failure, detail, code);
}
