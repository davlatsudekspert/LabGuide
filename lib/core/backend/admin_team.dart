import 'package:flutter/foundation.dart';

import 'backend_models.dart';

/// Adminlar boshqaruvi (D-44). Faqat Cloudflare serveri bu imkoniyatga ega;
/// boshqa serverlarda ([LabBackend] bu interfeysni amalga oshirmasa)
/// bo'lim ko'rinmaydi.
///
/// Hamma qoida serverda: faqat super admin (maxfiy `LG_ADMIN_EMAILS`)
/// qo'shadi/olib tashlaydi, admin amallari TOTP (aal2) talab qiladi; ilova
/// email solishtirib hech kimga vakolat bermaydi. Email ilovaga faqat
/// niqoblangan ko'rinishda keladi.
abstract interface class AdminTeamBackend {
  Future<AdminTeam> adminTeam();

  /// Email bo'yicha admin qo'shish (faqat super admin).
  Future<AdminEntry> addAdmin(String email);

  /// Qo'shilgan adminni olib tashlash (super admin olib tashlanmaydi).
  Future<void> removeAdmin(String id);
}

enum AdminKind { superAdmin, granted }

@immutable
class AdminEntry {
  const AdminEntry({
    required this.id,
    required this.emailMasked,
    required this.kind,
    required this.active,
    required this.you,
    this.createdAt,
  });

  factory AdminEntry.fromJson(Map<String, Object?> j) => AdminEntry(
    id: j['id'] as String?,
    emailMasked: j['email_masked'] as String? ?? '—',
    kind: j['kind'] == 'super' ? AdminKind.superAdmin : AdminKind.granted,
    active: j['active'] == true,
    you: j['you'] == true,
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? ''),
  );

  /// Super adminda `null` — API orqali olib tashlanmaydi.
  final String? id;
  final String emailMasked;
  final AdminKind kind;

  /// Hisob bor (vakolat kuchda, 2FA dan keyin). `false` — email hali
  /// kod bilan kirmagan.
  final bool active;
  final bool you;
  final DateTime? createdAt;

  bool get removable => kind == AdminKind.granted && id != null;
}

@immutable
class AdminTeam {
  const AdminTeam({
    required this.canManage,
    required this.admins,
    this.maxGranted = 20,
  });

  factory AdminTeam.fromJson(Map<String, Object?> j) => AdminTeam(
    canManage: j['can_manage'] == true,
    maxGranted: (j['max_granted'] as num?)?.toInt() ?? 20,
    admins: [
      for (final a in (j['admins'] as List? ?? const []))
        AdminEntry.fromJson((a as Map).cast<String, Object?>()),
    ],
  );

  final bool canManage;
  final int maxGranted;
  final List<AdminEntry> admins;

  int get grantedCount =>
      admins.where((a) => a.kind == AdminKind.granted).length;
}

/// Server xato kodi bilan (`already_admin`, `already_super_admin`,
/// `too_many_admins`, `invalid_email`, `not_super_admin`).
class AdminTeamException extends BackendException {
  const AdminTeamException(super.failure, this.code, [super.detail]);

  final String? code;
}
