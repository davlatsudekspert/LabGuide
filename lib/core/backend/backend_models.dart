import 'package:flutter/foundation.dart';

/// Server bilan ishlashda yuz beradigan xato turlari — UI shu bo'yicha
/// tushunarli xabar tanlaydi.
enum BackendFailure {
  /// Server sozlanmagan (bu buildda backend ulanmagan).
  unavailable,

  /// Internet yo'q yoki server javob bermadi.
  network,

  /// Kirilmagan yoki sessiya tugagan.
  unauthorized,

  /// Ruxsat yo'q (masalan, admin emas yoki 2FA tasdiqlanmagan).
  forbidden,

  /// Spamga qarshi cheklov.
  rateLimited,

  /// Kiritilgan ma'lumot qabul qilinmadi (juda qisqa, noto'g'ri kod...).
  invalid,

  notFound,
  unknown,
}

class BackendException implements Exception {
  const BackendException(this.failure, [this.detail]);

  final BackendFailure failure;

  /// Faqat log uchun.
  final String? detail;

  @override
  String toString() => 'BackendException(${failure.name}: $detail)';
}

/// Server bergan vakolatlar (faqat ko'rinish uchun — har amal serverda
/// qayta tekshiriladi).
@immutable
class AccessInfo {
  const AccessInfo({
    required this.adminAccount,
    required this.aal2,
    required this.reviewer,
  });

  factory AccessInfo.fromJson(Map<String, Object?> json) => AccessInfo(
    adminAccount: json['admin_account'] == true,
    aal2: json['aal'] == 'aal2',
    reviewer: json['reviewer'] == true,
  );

  static const none = AccessInfo(
    adminAccount: false,
    aal2: false,
    reviewer: false,
  );

  final bool adminAccount;
  final bool aal2;
  final bool reviewer;

  /// Admin panelni ochish mumkin (hisob + ikki bosqichli tasdiq).
  bool get admin => adminAccount && aal2;
}

enum SupportKind { suggestion, bug, question }

enum SupportStatus { newThread, inReview, answered, closed }

SupportStatus supportStatusFromWire(String raw) => switch (raw) {
  'new' => SupportStatus.newThread,
  'in_review' => SupportStatus.inReview,
  'answered' => SupportStatus.answered,
  'closed' => SupportStatus.closed,
  _ => throw FormatException('unknown status $raw'),
};

String supportStatusToWire(SupportStatus s) => switch (s) {
  SupportStatus.newThread => 'new',
  SupportStatus.inReview => 'in_review',
  SupportStatus.answered => 'answered',
  SupportStatus.closed => 'closed',
};

@immutable
class SupportThread {
  const SupportThread({
    required this.id,
    required this.userId,
    required this.kind,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUserMessageAt,
    required this.lastAdminMessageAt,
    required this.userReadAt,
    required this.adminReadAt,
  });

  factory SupportThread.fromJson(Map<String, Object?> j) => SupportThread(
    id: j['id']! as String,
    userId: j['user_id']! as String,
    kind: SupportKind.values.byName(j['kind']! as String),
    subject: j['subject']! as String,
    status: supportStatusFromWire(j['status']! as String),
    createdAt: DateTime.parse(j['created_at']! as String),
    updatedAt: DateTime.parse(j['updated_at']! as String),
    lastUserMessageAt: DateTime.parse(j['last_user_message_at']! as String),
    lastAdminMessageAt: _date(j['last_admin_message_at']),
    userReadAt: DateTime.parse(j['user_read_at']! as String),
    adminReadAt: _date(j['admin_read_at']),
  );

  final String id;
  final String userId;
  final SupportKind kind;
  final String subject;
  final SupportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastUserMessageAt;
  final DateTime? lastAdminMessageAt;
  final DateTime userReadAt;
  final DateTime? adminReadAt;

  /// Foydalanuvchi hali ko'rmagan admin javobi bor.
  bool get unreadForUser =>
      lastAdminMessageAt != null && lastAdminMessageAt!.isAfter(userReadAt);

  /// Admin hali o'qimagan foydalanuvchi xabari bor.
  bool get unreadForAdmin =>
      adminReadAt == null || lastUserMessageAt.isAfter(adminReadAt!);
}

@immutable
class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.threadId,
    required this.fromAdmin,
    required this.body,
    required this.attachmentPath,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, Object?> j) => SupportMessage(
    id: j['id']! as String,
    threadId: j['thread_id']! as String,
    fromAdmin: j['from_admin'] == true,
    body: j['body']! as String,
    attachmentPath: j['attachment_path'] as String?,
    createdAt: DateTime.parse(j['created_at']! as String),
  );

  final String id;
  final String threadId;
  final bool fromAdmin;
  final String body;
  final String? attachmentPath;
  final DateTime createdAt;
}

/// Murojaatga biriktiriladigan rasm (yuborishdan oldin tekshiriladi).
@immutable
class SupportAttachment {
  const SupportAttachment({required this.bytes, required this.mimeType});

  /// Server bucket chegarasi bilan bir xil.
  static const maxBytes = 5 * 1024 * 1024;
  static const allowedTypes = {'image/png', 'image/jpeg'};

  final Uint8List bytes;
  final String mimeType;

  String get extension => mimeType == 'image/png' ? 'png' : 'jpg';
}

@immutable
class AdminStats {
  const AdminStats(this.json);

  final Map<String, Object?> json;

  int _int(String k) => (json[k] as num?)?.toInt() ?? 0;

  int get registered => _int('registered');
  int get newToday => _int('new_today');
  int get new7d => _int('new_7d');
  int get new30d => _int('new_30d');
  int get activeToday => _int('active_today');
  int get active7d => _int('active_7d');
  int get active30d => _int('active_30d');
  int get withoutProfile => _int('without_profile');

  Map<String, int> _map(String k) => {
    for (final e in ((json[k] as Map?) ?? const {}).entries)
      e.key as String: (e.value as num).toInt(),
  };

  Map<String, int> get byRole => _map('by_role');
  Map<String, int> get byLanguage => _map('by_language');
  Map<String, int> get support => _map('support');

  /// Billing ulanmaguncha `null` — Free/Pro taqsimoti ko'rsatilmaydi.
  Object? get billing => json['billing'];
}

@immutable
class AdminUserRow {
  const AdminUserRow({
    required this.userId,
    required this.emailMasked,
    required this.role,
    required this.language,
    required this.registeredOn,
    required this.lastSeenOn,
  });

  factory AdminUserRow.fromJson(Map<String, Object?> j) => AdminUserRow(
    userId: j['user_id']! as String,
    emailMasked: (j['email_masked'] as String?) ?? '—',
    role: j['role'] as String?,
    language: j['language'] as String?,
    registeredOn: DateTime.parse(j['registered_on']! as String),
    lastSeenOn: _date(j['last_seen_on']),
  );

  final String userId;
  final String emailMasked;
  final String? role;
  final String? language;
  final DateTime registeredOn;
  final DateTime? lastSeenOn;
}

@immutable
class AdminUserPage {
  const AdminUserPage(this.rows, this.total);

  final List<AdminUserRow> rows;
  final int total;
}

@immutable
class AuditEntry {
  const AuditEntry({
    required this.at,
    required this.action,
    required this.target,
    required this.details,
  });

  factory AuditEntry.fromJson(Map<String, Object?> j) => AuditEntry(
    at: DateTime.parse(j['at']! as String),
    action: j['action']! as String,
    target: j['target'] as String?,
    details: ((j['details'] as Map?) ?? const {}).cast<String, Object?>(),
  );

  final DateTime at;
  final String action;
  final String? target;
  final Map<String, Object?> details;
}

enum ReviewDecision { approve, changes }

/// Tekshiruvchining karta/savol bo'yicha qarori. Kontent holatini o'zi
/// o'zgartirmaydi — tahririyat keyingi paketda hisobga oladi.
@immutable
class ContentReview {
  const ContentReview({
    required this.id,
    required this.itemKind,
    required this.itemId,
    required this.contentVersion,
    required this.reviewerId,
    required this.decision,
    required this.createdAt,
    this.comment,
  });

  factory ContentReview.fromJson(Map<String, Object?> j) => ContentReview(
    id: j['id']! as String,
    itemKind: j['item_kind']! as String,
    itemId: j['item_id']! as String,
    contentVersion: j['content_version']! as String,
    reviewerId: j['reviewer_id']! as String,
    decision: ReviewDecision.values.byName(j['decision']! as String),
    comment: j['comment'] as String?,
    createdAt: DateTime.parse(j['created_at']! as String),
  );

  /// `analyte` yoki `quiz`.
  final String itemKind;
  final String id;
  final String itemId;
  final String contentVersion;
  final String reviewerId;
  final ReviewDecision decision;
  final String? comment;
  final DateTime createdAt;
}

@immutable
class TotpEnrollment {
  const TotpEnrollment({
    required this.factorId,
    required this.secret,
    required this.uri,
  });

  final String factorId;
  final String secret;
  final String uri;
}

/// Admin ikki bosqichli himoyasi holati.
@immutable
class MfaStatus {
  const MfaStatus({required this.verifiedFactorId, required this.aal2});

  /// Tasdiqlangan TOTP faktori (yo'q bo'lsa — ro'yxatdan o'tkazish kerak).
  final String? verifiedFactorId;
  final bool aal2;
}

@immutable
class StudyGroup {
  const StudyGroup({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.isTeacher,
    required this.memberCount,
  });

  final String id;
  final String name;

  /// Faqat ustozga ko'rsatiladi.
  final String? joinCode;
  final bool isTeacher;
  final int memberCount;
}

@immutable
class GroupAssignment {
  const GroupAssignment({
    required this.id,
    required this.groupId,
    required this.title,
    required this.questionIds,
    required this.dueAt,
    required this.timeLimitMinutes,
    required this.createdAt,
  });

  factory GroupAssignment.fromJson(Map<String, Object?> j) => GroupAssignment(
    id: j['id']! as String,
    groupId: j['group_id']! as String,
    title: j['title']! as String,
    questionIds: (j['question_ids']! as List).cast<String>(),
    dueAt: _date(j['due_at']),
    timeLimitMinutes: (j['time_limit_minutes'] as num?)?.toInt(),
    createdAt: DateTime.parse(j['created_at']! as String),
  );

  final String id;
  final String groupId;
  final String title;
  final List<String> questionIds;
  final DateTime? dueAt;
  final int? timeLimitMinutes;
  final DateTime createdAt;
}

@immutable
class GroupSubmission {
  const GroupSubmission({
    required this.assignmentId,
    required this.userId,
    required this.score,
    required this.total,
    required this.submittedAt,
    this.answers = const [],
    this.correct,
  });

  factory GroupSubmission.fromJson(Map<String, Object?> j) => GroupSubmission(
    assignmentId: j['assignment_id']! as String,
    userId: j['user_id']! as String,
    score: (j['score']! as num).toInt(),
    total: (j['total']! as num).toInt(),
    submittedAt: DateTime.parse(j['submitted_at']! as String),
    answers: [
      for (final a in (j['answers'] as List? ?? const []))
        (a as num?)?.toInt() ?? -1,
    ],
    correct: (j['correct'] as List?)?.map((c) => c == true).toList(),
  );

  final String assignmentId;
  final String userId;
  final int score;
  final int total;
  final DateTime submittedAt;

  /// Talaba javoblari topshiriq tartibida (javobsiz — -1).
  final List<int> answers;

  /// Har savol bo'yicha server hisoblagan natija (eski yozuvlarda yo'q).
  final List<bool>? correct;

  int get percent => total == 0 ? 0 : (score * 100 / total).round();
}

/// Guruh a'zosi: guruh ichida ko'rinadigan ism (email ko'rsatilmaydi).
@immutable
class GroupMember {
  const GroupMember({
    required this.userId,
    required this.displayName,
    required this.isTeacher,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, Object?> j) => GroupMember(
    userId: j['user_id']! as String,
    displayName: j['display_name']! as String,
    isTeacher: j['member_role'] == 'teacher',
    joinedAt: DateTime.parse(j['joined_at']! as String),
  );

  final String userId;
  final String displayName;
  final bool isTeacher;
  final DateTime joinedAt;
}

/// Topshiriq boshlangan vaqt (server soati) — vaqt chegarasi shundan.
@immutable
class AssignmentStart {
  const AssignmentStart({required this.startedAt, required this.serverNow});

  factory AssignmentStart.fromJson(Map<String, Object?> j) => AssignmentStart(
    startedAt: DateTime.parse(j['started_at']! as String),
    serverNow: DateTime.parse(j['server_now']! as String),
  );

  final DateTime startedAt;

  /// Server hozirgi vaqti: qurilma soati farq qilsa ham taymer to'g'ri.
  final DateTime serverNow;
}

DateTime? _date(Object? raw) =>
    raw == null ? null : DateTime.parse(raw as String);
