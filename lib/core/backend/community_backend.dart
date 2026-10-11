import 'package:flutter/foundation.dart';

import 'backend_models.dart';

/// Hamjamiyat (D-43): mutaxassisni avtomatik tasdiqlash, savol-javob,
/// shikoyat va mashina tarjimasi. Faqat Cloudflare serveri (`LG_API_URL`)
/// ulangan buildda mavjud — aks holda hamjamiyat UI umuman ko'rinmaydi.
///
/// Hamma qoidalar (kim javob beradi, kim ovoz beradi, admin, limitlar)
/// serverda; ilova faqat natijani ko'rsatadi.
abstract interface class CommunityBackend {
  /// Kirilgan hisob (mehmon emas) — savol berish, tasdiqlash, shikoyat.
  bool get hasSession;

  Future<CommunityMe> communityMe();

  /// Hujjat rasmi (JPEG/PNG, ≤ 5 MB) — serverda AI bilan tekshiriladi va
  /// SAQLANMAYDI. Natija darhol qaytadi.
  Future<CommunityMe> verifySpecialist({
    required SpecialistRole role,
    required String country,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<QuestionPage> questions({
    String? topic,
    bool mine = false,
    int limit = 20,
    int offset = 0,
  });

  /// Savol id si. [lang] — ilova tili (server matndan ham aniqlaydi).
  Future<String> askQuestion({
    required String title,
    required String body,
    String? topic,
    required String lang,
  });

  Future<QuestionThread> question(String id);
  Future<String> answer(String questionId, String body, {required String lang});

  /// Yangi ovozlar soni.
  Future<int> vote(String answerId, {required bool up});
  Future<void> setBestAnswer(String questionId, String? answerId);
  Future<void> report({
    required PostKind kind,
    required String id,
    required ReportReason reason,
  });

  /// Mashina tarjimasi (serverda keshlanadi).
  Future<PostTranslation> translate({
    required PostKind kind,
    required String id,
    required String lang,
  });

  // --- admin (server bergan vakolat + TOTP)
  Future<void> pinQuestion(String id, {required bool pinned});
  Future<void> deleteQuestion(String id);
  Future<void> deleteAnswer(String id);
  Future<List<CommunityMemberAdmin>> adminMembers({
    MemberStatus status = MemberStatus.suspended,
  });
  Future<void> adminRestore(String userHash);
  Future<void> adminRevoke(String userHash);

  /// Bir tugma: egasi tasdig'i (chaqiruvchining o'z emaili) + boshlang'ich
  /// savol-javoblar. Idempotent. Faqat admin (aal2).
  Future<CommunityLaunchResult> adminCommunityLaunch();
}

class CommunityLaunchResult {
  const CommunityLaunchResult({
    required this.ownerVerified,
    required this.questionsAdded,
    required this.answersAdded,
  });

  final bool ownerVerified;
  final int questionsAdded;
  final int answersAdded;
}

/// Server xato kodi bilan (masalan, `not_verified`, `contact_data`).
class CommunityException extends BackendException {
  const CommunityException(super.failure, this.code, [super.detail]);

  final String? code;
}

enum SpecialistRole {
  laborant,
  biochemist,
  kdlDoctor('kdl_doctor'),
  teacher,
  other,
  clinicalLabDiagnostics('clinical_lab_diagnostics');

  const SpecialistRole([this._wire]);
  final String? _wire;
  String get wire => _wire ?? name;

  /// Foydalanuvchi tanlay oladiganlar (oxirgisi — faqat server, egasi).
  static const selectable = [laborant, biochemist, kdlDoctor, teacher, other];

  static SpecialistRole? parse(Object? v) {
    for (final r in values) {
      if (r.wire == v) return r;
    }
    return null;
  }
}

enum MemberStatus {
  none,
  verified,
  rejected,
  suspended;

  static MemberStatus parse(Object? v) =>
      values.firstWhere((s) => s.name == v, orElse: () => none);
}

enum VerifyMethod {
  aiAuto('ai_auto'),
  manual('manual_document_review');

  const VerifyMethod(this.wire);
  final String wire;

  static VerifyMethod? parse(Object? v) {
    for (final m in values) {
      if (m.wire == v) return m;
    }
    return null;
  }
}

enum PostKind { question, answer }

enum ReportReason {
  spam,
  wrong,
  abuse,
  fakeSpecialist('fake_specialist'),
  patientData('patient_data'),
  other;

  const ReportReason([this._wire]);
  final String? _wire;
  String get wire => _wire ?? name;
}

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

@immutable
class CommunityMe {
  const CommunityMe({
    required this.status,
    this.method,
    this.role,
    this.country,
    this.reason,
    this.verifiedAt,
    this.institution,
    this.specialtyCode,
    this.credential,
    this.year,
    this.isOwner = false,
    this.canAsk = true,
    this.canAnswer = false,
    this.admin = false,
  });

  factory CommunityMe.fromJson(Map<String, Object?> j) => CommunityMe(
    status: MemberStatus.parse(j['status']),
    method: VerifyMethod.parse(j['method']),
    role: SpecialistRole.parse(j['role']),
    country: j['country'] as String?,
    reason: j['reason'] as String?,
    verifiedAt: _date(j['verified_at']),
    institution: j['institution'] as String?,
    specialtyCode: j['specialty_code'] as String?,
    credential: j['credential'] as String?,
    year: (j['year'] as num?)?.toInt(),
    isOwner: j['is_owner'] == true,
    canAsk: j['can_ask'] != false,
    canAnswer: j['can_answer'] == true,
    admin: j['admin'] == true,
  );

  final MemberStatus status;
  final VerifyMethod? method;
  final SpecialistRole? role;
  final String? country;

  /// Server kodlari (`doc=…;field=…`) — faqat ma'lumot uchun.
  final String? reason;
  final DateTime? verifiedAt;
  final String? institution;
  final String? specialtyCode;
  final String? credential;
  final int? year;
  final bool isOwner;
  final bool canAsk;
  final bool canAnswer;

  /// Admin (aal2) — qadash/o'chirish tugmalari uchun (server tekshiradi).
  final bool admin;
}

enum AuthorKind { owner, specialist, member }

@immutable
class CommunityAuthor {
  const CommunityAuthor({
    required this.kind,
    this.name,
    this.verified = false,
    this.method,
    this.role,
    this.country,
    this.isMe = false,
  });

  factory CommunityAuthor.fromJson(Map<String, Object?> j) => CommunityAuthor(
    kind: AuthorKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => AuthorKind.member,
    ),
    name: j['name'] as String?,
    verified: j['verified'] == true,
    method: VerifyMethod.parse(j['method']),
    role: SpecialistRole.parse(j['role']),
    country: j['country'] as String?,
    isMe: j['is_me'] == true,
  );

  final AuthorKind kind;

  /// Faqat egasi uchun (server sozlamasi LG_OWNER_DISPLAY_NAME).
  final String? name;
  final bool verified;
  final VerifyMethod? method;
  final SpecialistRole? role;
  final String? country;
  final bool isMe;
}

@immutable
class QuestionSummary {
  const QuestionSummary({
    required this.id,
    required this.title,
    required this.text,
    required this.lang,
    required this.topic,
    required this.pinned,
    required this.answerCount,
    required this.bestAnswerId,
    required this.createdAt,
    required this.author,
  });

  factory QuestionSummary.fromJson(Map<String, Object?> j) => QuestionSummary(
    id: j['id']! as String,
    title: j['title']! as String,
    text: (j['body'] ?? j['excerpt'] ?? '') as String,
    lang: j['lang']! as String,
    topic: j['topic'] as String?,
    pinned: j['pinned'] == true,
    answerCount: (j['answer_count'] as num?)?.toInt() ?? 0,
    bestAnswerId: j['best_answer_id'] as String?,
    createdAt: _date(j['created_at']) ?? DateTime.now(),
    author: CommunityAuthor.fromJson(
      (j['author']! as Map).cast<String, Object?>(),
    ),
  );

  final String id;
  final String title;

  /// Ro'yxatda — qisqa parcha, savol sahifasida — to'liq matn.
  final String text;
  final String lang;
  final String? topic;
  final bool pinned;
  final int answerCount;
  final String? bestAnswerId;
  final DateTime createdAt;
  final CommunityAuthor author;
}

@immutable
class QuestionPage {
  const QuestionPage({
    required this.items,
    required this.total,
    required this.nextOffset,
  });

  factory QuestionPage.fromJson(Map<String, Object?> j) => QuestionPage(
    items: [
      for (final q in (j['items'] as List? ?? const []))
        QuestionSummary.fromJson((q as Map).cast<String, Object?>()),
    ],
    total: (j['total'] as num?)?.toInt() ?? 0,
    nextOffset: (j['next_offset'] as num?)?.toInt(),
  );

  final List<QuestionSummary> items;
  final int total;
  final int? nextOffset;
}

@immutable
class CommunityAnswer {
  const CommunityAnswer({
    required this.id,
    required this.body,
    required this.lang,
    required this.upvotes,
    required this.voted,
    required this.isBest,
    required this.createdAt,
    required this.author,
  });

  factory CommunityAnswer.fromJson(Map<String, Object?> j) => CommunityAnswer(
    id: j['id']! as String,
    body: j['body']! as String,
    lang: j['lang']! as String,
    upvotes: (j['upvotes'] as num?)?.toInt() ?? 0,
    voted: j['voted'] == true,
    isBest: j['is_best'] == true,
    createdAt: _date(j['created_at']) ?? DateTime.now(),
    author: CommunityAuthor.fromJson(
      (j['author']! as Map).cast<String, Object?>(),
    ),
  );

  final String id;
  final String body;
  final String lang;
  final int upvotes;
  final bool voted;
  final bool isBest;
  final DateTime createdAt;
  final CommunityAuthor author;
}

@immutable
class QuestionThread {
  const QuestionThread({
    required this.question,
    required this.answers,
    required this.canAnswer,
    required this.canVote,
    required this.isAuthor,
    required this.admin,
  });

  factory QuestionThread.fromJson(Map<String, Object?> j) {
    final v = (j['viewer'] as Map? ?? const {}).cast<String, Object?>();
    return QuestionThread(
      question: QuestionSummary.fromJson(
        (j['question']! as Map).cast<String, Object?>(),
      ),
      answers: [
        for (final a in (j['answers'] as List? ?? const []))
          CommunityAnswer.fromJson((a as Map).cast<String, Object?>()),
      ],
      canAnswer: v['can_answer'] == true,
      canVote: v['can_vote'] == true,
      isAuthor: v['is_author'] == true,
      admin: v['admin'] == true,
    );
  }

  final QuestionSummary question;
  final List<CommunityAnswer> answers;
  final bool canAnswer;
  final bool canVote;
  final bool isAuthor;
  final bool admin;
}

@immutable
class PostTranslation {
  const PostTranslation({
    required this.title,
    required this.body,
    required this.lang,
    required this.sourceLang,
  });

  factory PostTranslation.fromJson(Map<String, Object?> j) => PostTranslation(
    title: j['title'] as String?,
    body: j['body']! as String,
    lang: j['lang']! as String,
    sourceLang: j['source_lang']! as String,
  );

  final String? title;
  final String body;
  final String lang;
  final String sourceLang;
}

@immutable
class CommunityReport {
  const CommunityReport({
    required this.kind,
    required this.reason,
    required this.excerpt,
    required this.createdAt,
  });

  factory CommunityReport.fromJson(Map<String, Object?> j) => CommunityReport(
    kind: j['target_kind'] == 'answer' ? PostKind.answer : PostKind.question,
    reason: ReportReason.values.firstWhere(
      (r) => r.wire == j['reason'],
      orElse: () => ReportReason.other,
    ),
    excerpt: j['excerpt'] as String?,
    createdAt: _date(j['created_at']),
  );

  final PostKind kind;
  final ReportReason reason;
  final String? excerpt;
  final DateTime? createdAt;
}

@immutable
class CommunityMemberAdmin {
  const CommunityMemberAdmin({
    required this.userHash,
    required this.status,
    required this.prevStatus,
    required this.role,
    required this.country,
    required this.method,
    required this.reporters,
    required this.reports,
    required this.isOwner,
  });

  factory CommunityMemberAdmin.fromJson(Map<String, Object?> j) =>
      CommunityMemberAdmin(
        userHash: j['user_hash']! as String,
        status: MemberStatus.parse(j['status']),
        prevStatus: j['prev_status'] == null
            ? null
            : MemberStatus.parse(j['prev_status']),
        role: SpecialistRole.parse(j['role']),
        country: j['country'] as String?,
        method: VerifyMethod.parse(j['method']),
        reporters: (j['reporters'] as num?)?.toInt() ?? 0,
        reports: [
          for (final r in (j['reports'] as List? ?? const []))
            CommunityReport.fromJson((r as Map).cast<String, Object?>()),
        ],
        isOwner: j['is_owner'] == true,
      );

  final String userHash;
  final MemberStatus status;
  final MemberStatus? prevStatus;
  final SpecialistRole? role;
  final String? country;
  final VerifyMethod? method;
  final int reporters;
  final List<CommunityReport> reports;
  final bool isOwner;
}
