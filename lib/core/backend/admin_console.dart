import 'package:flutter/foundation.dart';

import 'backend_models.dart';

/// Egasi admin paneli (Cloudflare serveri: `cloudflare/src/adminconsole.ts`,
/// `complaints.ts`): foydalanuvchilar (rol, hisobni to'xtatish), ilova
/// ichidagi shikoyatlar, hamjamiyat shikoyatlari. Statistika, murojaatlar va
/// jurnal — `LabBackend` ning umumiy admin metodlari orqali.
///
/// Boshqa serverlarda (bu interfeys amalga oshirilmagan bo'lsa) tegishli
/// bo'limlar ko'rinmaydi. Hamma qoida serverda: email kodi bilan kirgan va
/// emaili maxfiy `ADMIN_EMAILS` da bo'lgan hisob (har so'rovda qayta
/// tekshiriladi); email faqat niqoblangan holda keladi, hash kelmaydi.
abstract interface class AdminConsoleBackend {
  /// [email] — to'liq email (server HMAC bilan aniq qidiradi); [name] —
  /// guruhdagi taxallus (2–40 belgi; `%`/`_` oddiy belgi).
  Future<AdminAccountPage> adminAccounts({
    String? email,
    String? name,
    String? role,
    AccountStatus? status,
    int limit = 20,
    int offset = 0,
  });

  Future<AdminUserDetail> adminUserDetail(String userId);

  /// Profil roli: student / teacher / doctor / lab (o'zini emas).
  Future<void> adminSetRole(String userId, String role);

  /// Hisobni to'xtatish: sessiyalari o'chadi, qayta kira olmaydi. Adminni emas.
  Future<void> adminSuspendAccount(String userId);
  Future<void> adminReactivateAccount(String userId);

  /// Foydalanuvchining hamma qurilmalardagi sessiyalarini bekor qilish (hisob
  /// to'xtatilmaydi, qayta kira oladi). Step-up (bir martalik). O'zini emas
  /// (`self`). Natija — bekor qilingan sessiyalar soni.
  Future<int> adminRevokeSessions(String userId);

  /// Hisobni butunlay o'chirish (D-63): [email] — foydalanuvchining to'liq
  /// emaili (server HMAC bilan aniq solishtiradi), [confirmUserId] — panel
  /// ko'rsatgan hisob id si (boshqa hisob o'chirilmaydi). O'zi o'chirgandagi
  /// yo'l: guruhlar, hamjamiyat, murojaatlar, Apple tokeni. O'zini va adminni
  /// emas. Xato kodlari: `confirmation_mismatch`, `not_found`, `self`, `admin`.
  Future<void> adminDeleteAccount({
    required String email,
    required String confirmUserId,
  });

  /// Hamjamiyatda yozishni to'xtatish / tiklash.
  Future<void> adminSuspendCommunity(String userId);
  Future<void> adminRestoreCommunity(String userId);

  /// Ilova ichidagi shikoyatlar (Profil → Aloqa va shikoyat).
  Future<List<Complaint>> adminComplaints({
    ComplaintStatus? status,
    ComplaintKind? kind,
  });
  Future<Complaint> adminComplaint(String id);
  Future<Complaint> adminComplaintNote(String id, String note);
  Future<Complaint> adminSetComplaintStatus(String id, ComplaintStatus status);

  /// Hamjamiyat postlariga shikoyatlar (post bo'yicha guruhlangan).
  Future<List<ReportItem>> adminReports({
    ReportStatus status = ReportStatus.open,
  });
  Future<void> dismissReport(ReportItem item);
  Future<void> resolveReport(ReportItem item);
  Future<void> suspendReportAuthor(ReportItem item);
}

/// Shikoyat yuborish (hisobli foydalanuvchi ham, mehmon ham).
abstract interface class ComplaintsBackend {
  /// Soatiga 5 ta: oshsa [ComplaintException] (`rateLimited`, [retryAfter]).
  Future<void> submitComplaint({
    required ComplaintKind kind,
    required String body,
    String? targetRef,
    String? lang,
  });
}

/// Server murojaatga skrinshot biriktirishni qo'llaydimi (Cloudflare'da R2
/// hali ulanmagan — `false`, tanlash tugmasi ko'rsatilmaydi).
abstract interface class SupportAttachmentPolicy {
  bool get supportAttachments;
}

/// Server xato kodi bilan (`self`, `admin`, `owner`, `invalid_email`,
/// `invalid_name`, `not_suspended`, …).
class AdminConsoleException extends BackendException {
  const AdminConsoleException(
    BackendFailure failure,
    String? code, [
    String? detail,
  ]) : super(failure, detail, code);
}

class ComplaintException extends BackendException {
  const ComplaintException(
    BackendFailure failure, {
    this.retryAfter,
    String? detail,
  }) : super(failure, detail);

  final Duration? retryAfter;
}

DateTime? _date(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toUtc() : null;

int _int(Object? v) => v is num ? v.toInt() : 0;

enum AccountStatus { active, suspended }

@immutable
class AdminAccountRow {
  const AdminAccountRow({
    required this.userId,
    required this.emailMasked,
    required this.role,
    required this.language,
    required this.registeredOn,
    required this.lastSeenOn,
    required this.status,
    required this.admin,
  });

  factory AdminAccountRow.fromJson(Map<String, Object?> j) => AdminAccountRow(
    userId: j['user_id']! as String,
    emailMasked: (j['email_masked'] as String?) ?? '—',
    role: j['role'] as String?,
    language: j['language'] as String?,
    registeredOn: _date(j['registered_on']) ?? DateTime.utc(1970),
    lastSeenOn: _date(j['last_seen_on']),
    status: j['status'] == 'suspended'
        ? AccountStatus.suspended
        : AccountStatus.active,
    admin: j['admin'] == true,
  );

  final String userId;
  final String emailMasked;
  final String? role;
  final String? language;
  final DateTime registeredOn;
  final DateTime? lastSeenOn;
  final AccountStatus status;
  final bool admin;
}

@immutable
class AdminAccountPage {
  const AdminAccountPage(this.rows, this.total);

  final List<AdminAccountRow> rows;
  final int total;
}

@immutable
class AdminUserDetail {
  const AdminUserDetail({
    required this.account,
    required this.you,
    required this.teacher,
    required this.groupsOwned,
    required this.groupsJoined,
    required this.supportThreads,
    required this.complaints,
    required this.communityStatus,
    required this.communityOwner,
    required this.reporters,
    required this.questions,
    required this.answers,
  });

  factory AdminUserDetail.fromJson(Map<String, Object?> j) {
    final c = ((j['community'] as Map?) ?? const {}).cast<String, Object?>();
    return AdminUserDetail(
      account: AdminAccountRow.fromJson(j),
      you: j['you'] == true,
      teacher: j['teacher'] == true,
      groupsOwned: _int(j['groups_owned']),
      groupsJoined: _int(j['groups_joined']),
      supportThreads: _int(j['support_threads']),
      complaints: _int(j['complaints']),
      communityStatus: (c['status'] as String?) ?? 'none',
      communityOwner: c['is_owner'] == true,
      reporters: _int(c['reporters']),
      questions: _int(c['questions']),
      answers: _int(c['answers']),
    );
  }

  final AdminAccountRow account;

  /// Bu — admin o'zi (rol va to'xtatish amallari yo'q).
  final bool you;
  final bool teacher;
  final int groupsOwned;
  final int groupsJoined;
  final int supportThreads;
  final int complaints;

  /// none | verified | rejected | suspended.
  final String communityStatus;
  final bool communityOwner;
  final int reporters;
  final int questions;
  final int answers;

  bool get communitySuspended => communityStatus == 'suspended';
}

enum ComplaintKind {
  complaint('complaint'),
  inappropriate('inappropriate'),
  bug('bug'),
  ad('ad'),
  other('other');

  const ComplaintKind(this.wire);
  final String wire;

  static ComplaintKind parse(Object? raw) => ComplaintKind.values.firstWhere(
    (k) => k.wire == raw,
    orElse: () => ComplaintKind.other,
  );
}

enum ComplaintStatus { open, resolved }

@immutable
class Complaint {
  const Complaint({
    required this.id,
    required this.kind,
    required this.body,
    required this.status,
    required this.createdAt,
    this.targetRef,
    this.adminNote,
    this.anonymous = true,
    this.userId,
    this.emailMasked,
    this.resolvedAt,
  });

  factory Complaint.fromJson(Map<String, Object?> j) => Complaint(
    id: j['id']! as String,
    kind: ComplaintKind.parse(j['kind']),
    body: (j['body'] as String?) ?? '',
    status: j['status'] == 'resolved'
        ? ComplaintStatus.resolved
        : ComplaintStatus.open,
    createdAt: _date(j['created_at']) ?? DateTime.utc(1970),
    targetRef: j['target_ref'] as String?,
    adminNote: j['admin_note'] as String?,
    anonymous: j['anonymous'] != false,
    userId: j['user_id'] as String?,
    emailMasked: j['email_masked'] as String?,
    resolvedAt: _date(j['resolved_at']),
  );

  final String id;
  final ComplaintKind kind;
  final String body;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String? targetRef;
  final String? adminNote;
  final bool anonymous;
  final String? userId;
  final String? emailMasked;
  final DateTime? resolvedAt;
}

enum ReportStatus { open, dismissed, resolved }

@immutable
class ReportItem {
  const ReportItem({
    required this.kind,
    required this.id,
    required this.status,
    required this.reports,
    required this.reporters,
    required this.reasons,
    required this.excerpt,
    required this.questionId,
    required this.postDeleted,
    required this.authorStatus,
    required this.lastAt,
  });

  factory ReportItem.fromJson(Map<String, Object?> j) => ReportItem(
    kind: (j['kind'] as String?) ?? 'question',
    id: j['id']! as String,
    status: ReportStatus.values.asNameMap()[j['status']] ?? ReportStatus.open,
    reports: _int(j['reports']),
    reporters: _int(j['reporters']),
    reasons: [for (final r in (j['reasons'] as List? ?? const [])) '$r'],
    excerpt: j['excerpt'] as String?,
    questionId: j['question_id'] as String?,
    postDeleted: j['post_deleted'] == true,
    authorStatus: (j['author_status'] as String?) ?? 'none',
    lastAt: _date(j['last_at']) ?? DateTime.utc(1970),
  );

  /// question | answer.
  final String kind;
  final String id;
  final ReportStatus status;
  final int reports;
  final int reporters;
  final List<String> reasons;
  final String? excerpt;

  /// Postni ochish uchun (javobda — uning savoli).
  final String? questionId;
  final bool postDeleted;
  final String authorStatus;
  final DateTime lastAt;
}

/// Do'kondan yuklab olishlar va sotuvlar soni: ilova ularni ko'rmaydi
/// (analitika SDK yo'q, to'lov yo'q) — egasi konsollarda ko'radi.
abstract final class StoreConsoles {
  static const appStoreConnect = 'https://appstoreconnect.apple.com/';
  static const playConsole = 'https://play.google.com/console/';
}

@immutable
class DayCount {
  const DayCount(this.day, this.count);

  /// Toshkent kuni.
  final DateTime day;
  final int count;
}

/// `GET /v1/admin/stats` ning Cloudflare qismi (Supabase statistikasida
/// bu maydonlar yo'q — `null`).
extension OwnerStats on AdminStats {
  Map<String, int>? _section(String k) {
    final m = json[k];
    if (m is! Map) return null;
    return {
      for (final e in m.entries)
        if (e.value is num) e.key as String: (e.value as num).toInt(),
    };
  }

  int? _opt(String k) => (json[k] as num?)?.toInt();

  int? get onlineNow => _opt('online_now');
  int? get suspendedAccounts => _opt('suspended_accounts');
  Map<String, int>? get groupsSection => _section('groups');
  Map<String, int>? get communitySection => _section('community');
  Map<String, int>? get complaintsSection => _section('complaints');

  /// Oxirgi 14 kun (eskidan yangiga); server bermasa — bo'sh.
  List<DayCount> get newByDay => [
    for (final e in (json['new_by_day'] as List? ?? const []))
      if (e is Map && DateTime.tryParse('${e['day']}') != null)
        DayCount(DateTime.parse('${e['day']}'), _int(e['n'])),
  ];

  DateTime? get generatedAt => _date(json['generated_at']);
}
