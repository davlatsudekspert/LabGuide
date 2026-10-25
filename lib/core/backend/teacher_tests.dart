import 'package:flutter/foundation.dart';

import 'backend_models.dart';

// Ustoz Pro (D-78): o'z testlari, topshiriq, taklifnoma, natijalar va talaba
// tomoni. Server: `cloudflare/src/teachertests.ts` (faqat
// LG_BILLING_ENABLED=true; aks holda yo'llar 404). Har amal serverda
// tekshiriladi (reja, ustoz hisobi, egalik, muddat); ilovadagi gate — UX.

/// Cheklovlar — server `TT_LIMITS` bilan bir xil (test solishtiradi).
abstract final class TeacherTestLimits {
  static const questions = 100;
  static const titleMin = 3;
  static const titleMax = 120;
  static const description = 1000;
  static const text = 1000;
  static const option = 300;
  static const optionsMin = 2;
  static const optionsMax = 6;
  static const explanation = 1000;
  static const maxAttempts = 5;
  static const inviteUses = 200;
  static const inviteDays = 30;
  static const timeLimitMax = 180;
}

/// Savol nusxasi qaysi ilova bankidan olingan (manba atributi).
enum TtBank {
  quiz,
  toifa,
  deck;

  static TtBank? parse(Object? raw) {
    for (final b in values) {
      if (b.name == raw) return b;
    }
    return null;
  }
}

@immutable
class TtSource {
  const TtSource(this.bank, this.id);

  factory TtSource.fromJson(Map<String, Object?> j) =>
      TtSource(TtBank.parse(j['bank']) ?? TtBank.quiz, j['id']! as String);

  final TtBank bank;
  final String id;

  Map<String, Object?> toJson() => {'bank': bank.name, 'id': id};

  @override
  bool operator ==(Object other) =>
      other is TtSource && other.bank == bank && other.id == id;

  @override
  int get hashCode => Object.hash(bank, id);
}

/// Bitta javobli savol (2–6 variant, kalit, ixtiyoriy izoh).
@immutable
class TtQuestion {
  const TtQuestion({
    required this.text,
    required this.options,
    required this.correct,
    this.explanation,
    this.source,
  });

  factory TtQuestion.fromJson(Map<String, Object?> j) => TtQuestion(
    text: j['text']! as String,
    options: (j['options']! as List).cast<String>(),
    correct: (j['correct']! as num).toInt(),
    explanation: j['explanation'] as String?,
    source: switch (j['source']) {
      final Map<Object?, Object?> m => TtSource.fromJson(m.cast()),
      _ => null,
    },
  );

  final String text;
  final List<String> options;
  final int correct;
  final String? explanation;
  final TtSource? source;

  TtQuestion copyWith({
    String? text,
    List<String>? options,
    int? correct,
    String? explanation,
    bool clearExplanation = false,
  }) => TtQuestion(
    text: text ?? this.text,
    options: options ?? this.options,
    correct: correct ?? this.correct,
    explanation: clearExplanation ? null : (explanation ?? this.explanation),
    source: source,
  );

  Map<String, Object?> toJson() => {
    'text': text,
    'options': options,
    'correct': correct,
    if (explanation != null && explanation!.trim().isNotEmpty)
      'explanation': explanation,
    if (source != null) 'source': source!.toJson(),
  };

  /// Server qoidasi bilan bir xil tekshiruv (xato kodi yoki null).
  String? validate() {
    final t = text.trim();
    if (t.isEmpty || t.length > TeacherTestLimits.text) {
      return 'invalid_question_text';
    }
    if (options.length < TeacherTestLimits.optionsMin ||
        options.length > TeacherTestLimits.optionsMax) {
      return 'invalid_options';
    }
    for (final o in options) {
      final v = o.trim();
      if (v.isEmpty || v.length > TeacherTestLimits.option) {
        return 'invalid_options';
      }
    }
    if ({for (final o in options) o.trim().toLowerCase()}.length !=
        options.length) {
      return 'duplicate_options';
    }
    if (correct < 0 || correct >= options.length) return 'invalid_correct';
    if ((explanation?.trim().length ?? 0) > TeacherTestLimits.explanation) {
      return 'invalid_explanation';
    }
    return null;
  }
}

/// Ustozning testi. Ro'yxatda [questions] bo'sh bo'lishi mumkin (faqat
/// [questionCount]); to'liq test — `teacherTest(id)`.
@immutable
class TeacherTest {
  const TeacherTest({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.published,
    required this.version,
    this.description,
    this.questions,
    this.timeLimitMinutes,
    this.passPercent,
    this.updatedAt,
    this.assignmentCount = 0,
  });

  factory TeacherTest.fromJson(Map<String, Object?> j) => TeacherTest(
    id: j['id']! as String,
    title: j['title']! as String,
    description: j['description'] as String?,
    questionCount: (j['question_count'] as num?)?.toInt() ?? 0,
    published: j['status'] == 'published',
    version: (j['version'] as num?)?.toInt() ?? 1,
    questions: switch (j['questions']) {
      final List<Object?> l => [
        for (final q in l) TtQuestion.fromJson((q! as Map).cast()),
      ],
      _ => null,
    },
    timeLimitMinutes: (j['time_limit_minutes'] as num?)?.toInt(),
    passPercent: (j['pass_percent'] as num?)?.toInt(),
    updatedAt: DateTime.tryParse(j['updated_at'] as String? ?? ''),
    assignmentCount: (j['assignment_count'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String title;
  final String? description;
  final int questionCount;
  final bool published;
  final int version;
  final List<TtQuestion>? questions;
  final int? timeLimitMinutes;
  final int? passPercent;
  final DateTime? updatedAt;
  final int assignmentCount;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'question_count': questionCount,
    'status': published ? 'published' : 'unpublished',
    'version': version,
    if (questions != null) 'questions': [for (final q in questions!) q.toJson()],
    'time_limit_minutes': timeLimitMinutes,
    'pass_percent': passPercent,
    'updated_at': updatedAt?.toUtc().toIso8601String(),
    'assignment_count': assignmentCount,
  };
}

/// Yaratish / tahrirlash tanasi.
@immutable
class TeacherTestInput {
  const TeacherTestInput({
    required this.title,
    required this.questions,
    required this.published,
    this.description,
    this.timeLimitMinutes,
    this.passPercent,
    this.version,
  });

  final String title;
  final String? description;
  final List<TtQuestion> questions;
  final bool published;
  final int? timeLimitMinutes;
  final int? passPercent;

  /// Tahrirda: serverdagi versiya (boshqa qurilmadagi tahrir ustidan
  /// yozilmasin — `409 version_conflict`).
  final int? version;

  Map<String, Object?> toJson() => {
    'title': title.trim(),
    if (description != null && description!.trim().isNotEmpty)
      'description': description!.trim(),
    'questions': [for (final q in questions) q.toJson()],
    'status': published ? 'published' : 'unpublished',
    'time_limit_minutes': timeLimitMinutes,
    'pass_percent': passPercent,
    'version': ?version,
  };

  /// Server qoidasi bilan bir xil (xato kodi yoki null).
  String? validate() {
    final t = title.trim();
    if (t.length < TeacherTestLimits.titleMin ||
        t.length > TeacherTestLimits.titleMax) {
      return 'invalid_title';
    }
    if ((description?.trim().length ?? 0) > TeacherTestLimits.description) {
      return 'invalid_description';
    }
    if (questions.length > TeacherTestLimits.questions) {
      return 'invalid_questions';
    }
    if (published && questions.isEmpty) return 'no_questions';
    final l = timeLimitMinutes;
    if (l != null && (l < 1 || l > TeacherTestLimits.timeLimitMax)) {
      return 'invalid_time_limit';
    }
    final p = passPercent;
    if (p != null && (p < 1 || p > 100)) return 'invalid_pass_percent';
    for (final q in questions) {
      if (q.validate() case final e?) return e;
    }
    return null;
  }
}

/// Topshiriq (ustoz tomoni).
@immutable
class TtAssignment {
  const TtAssignment({
    required this.id,
    required this.testId,
    required this.groupId,
    required this.title,
    required this.questionCount,
    required this.maxAttempts,
    required this.dueAt,
    required this.acceptLate,
    required this.closed,
    this.groupName,
    this.userId,
    this.timeLimitMinutes,
    this.passPercent,
    this.submittedCount = 0,
    this.targetCount = 0,
  });

  factory TtAssignment.fromJson(Map<String, Object?> j) => TtAssignment(
    id: j['id']! as String,
    testId: j['test_id']! as String,
    groupId: j['group_id']! as String,
    groupName: j['group_name'] as String?,
    userId: j['user_id'] as String?,
    title: j['title']! as String,
    questionCount: (j['question_count'] as num?)?.toInt() ?? 0,
    timeLimitMinutes: (j['time_limit_minutes'] as num?)?.toInt(),
    passPercent: (j['pass_percent'] as num?)?.toInt(),
    maxAttempts: (j['max_attempts'] as num?)?.toInt() ?? 1,
    dueAt: DateTime.parse(j['due_at']! as String),
    acceptLate: j['late_policy'] == 'accept',
    closed: j['status'] == 'closed',
    submittedCount: (j['submitted_count'] as num?)?.toInt() ?? 0,
    targetCount: (j['target_count'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String testId;
  final String groupId;
  final String? groupName;

  /// Bitta talabaga (null — butun guruhga).
  final String? userId;
  final String title;
  final int questionCount;
  final int? timeLimitMinutes;
  final int? passPercent;
  final int maxAttempts;
  final DateTime dueAt;
  final bool acceptLate;
  final bool closed;
  final int submittedCount;
  final int targetCount;
}

/// Talaba holati (server `StudentState`).
enum TtState {
  assigned,
  started,
  submitted,
  expired;

  static TtState parse(Object? raw) => switch (raw) {
    'started' => started,
    'submitted' => submitted,
    'expired' => expired,
    _ => assigned,
  };
}

@immutable
class TtStudentResult {
  const TtStudentResult({
    required this.userId,
    required this.state,
    required this.attempts,
    required this.total,
    this.seatNo,
    this.alias,
    this.bestScore,
    this.bestPercent,
    this.passed,
    this.bestSeconds,
    this.late = false,
    this.lastSubmittedAt,
  });

  factory TtStudentResult.fromJson(Map<String, Object?> j) => TtStudentResult(
    userId: j['user_id']! as String,
    seatNo: (j['seat_no'] as num?)?.toInt(),
    alias: j['alias'] as String?,
    state: TtState.parse(j['state']),
    attempts: (j['attempts'] as num?)?.toInt() ?? 0,
    bestScore: (j['best_score'] as num?)?.toInt(),
    total: (j['total'] as num?)?.toInt() ?? 0,
    bestPercent: (j['best_percent'] as num?)?.toInt(),
    passed: j['passed'] as bool?,
    bestSeconds: (j['best_seconds'] as num?)?.toInt(),
    late: j['late'] == true,
    lastSubmittedAt: DateTime.tryParse(j['last_submitted_at'] as String? ?? ''),
  );

  final String userId;
  final int? seatNo;
  final String? alias;
  final TtState state;
  final int attempts;
  final int? bestScore;
  final int total;
  final int? bestPercent;
  final bool? passed;
  final int? bestSeconds;
  final bool late;
  final DateTime? lastSubmittedAt;
}

@immutable
class TtQuestionStat {
  const TtQuestionStat({
    required this.index,
    required this.text,
    required this.options,
    required this.correct,
    required this.answered,
    required this.right,
    required this.attempts,
    required this.chosen,
    this.correctPercent,
  });

  factory TtQuestionStat.fromJson(Map<String, Object?> j) => TtQuestionStat(
    index: (j['index']! as num).toInt(),
    text: j['text']! as String,
    options: (j['options'] as List? ?? const []).cast<String>(),
    correct: (j['correct'] as num?)?.toInt() ?? 0,
    answered: (j['answered'] as num?)?.toInt() ?? 0,
    right: (j['right'] as num?)?.toInt() ?? 0,
    attempts: (j['attempts'] as num?)?.toInt() ?? 0,
    correctPercent: (j['correct_percent'] as num?)?.toInt(),
    chosen: [
      for (final c in (j['chosen'] as List? ?? const [])) (c as num).toInt(),
    ],
  );

  final int index;
  final String text;
  final List<String> options;
  final int correct;
  final int answered;
  final int right;
  final int attempts;
  final int? correctPercent;
  final List<int> chosen;
}

@immutable
class TtResults {
  const TtResults({
    required this.assignment,
    required this.targets,
    required this.started,
    required this.submitted,
    required this.students,
    required this.questions,
    required this.mostMissed,
    this.averagePercent,
    this.passRate,
    this.averageSeconds,
  });

  factory TtResults.fromJson(Map<String, Object?> j) {
    final s = (j['summary'] as Map? ?? const {}).cast<String, Object?>();
    return TtResults(
      assignment: TtAssignment.fromJson((j['assignment']! as Map).cast()),
      targets: (s['targets'] as num?)?.toInt() ?? 0,
      started: (s['started'] as num?)?.toInt() ?? 0,
      submitted: (s['submitted'] as num?)?.toInt() ?? 0,
      averagePercent: (s['average_percent'] as num?)?.toInt(),
      passRate: (s['pass_rate'] as num?)?.toInt(),
      averageSeconds: (s['average_seconds'] as num?)?.toInt(),
      students: [
        for (final r in (j['students'] as List? ?? const []))
          TtStudentResult.fromJson((r as Map).cast()),
      ],
      questions: [
        for (final r in (j['questions'] as List? ?? const []))
          TtQuestionStat.fromJson((r as Map).cast()),
      ],
      mostMissed: [
        for (final i in (j['most_missed'] as List? ?? const []))
          (i as num).toInt(),
      ],
    );
  }

  final TtAssignment assignment;
  final int targets;
  final int started;
  final int submitted;
  final int? averagePercent;
  final int? passRate;
  final int? averageSeconds;
  final List<TtStudentResult> students;
  final List<TtQuestionStat> questions;
  final List<int> mostMissed;
}

@immutable
class TtExport {
  const TtExport({required this.filename, required this.csv});

  factory TtExport.fromJson(Map<String, Object?> j) => TtExport(
    filename: j['filename'] as String? ?? 'labguide-results.csv',
    csv: j['csv'] as String? ?? '',
  );

  final String filename;
  final String csv;
}

@immutable
class TtInvite {
  const TtInvite({
    required this.id,
    required this.groupId,
    required this.token,
    required this.maxUses,
    required this.uses,
    required this.expiresAt,
    required this.active,
  });

  factory TtInvite.fromJson(Map<String, Object?> j) => TtInvite(
    id: j['id']! as String,
    groupId: j['group_id']! as String,
    token: j['token']! as String,
    maxUses: (j['max_uses'] as num?)?.toInt() ?? 1,
    uses: (j['uses'] as num?)?.toInt() ?? 0,
    expiresAt: DateTime.parse(j['expires_at']! as String),
    active: j['active'] == true,
  );

  final String id;
  final String groupId;
  final String token;
  final int maxUses;
  final int uses;
  final DateTime expiresAt;
  final bool active;
}

/// Taklifnoma kodi: 12 belgi (0/O/1/I yo'q), `ABCD-EFGH-JKLM` ko'rinishida.
abstract final class TtInviteCode {
  static final _re = RegExp(r'^[A-HJ-NP-Z2-9]{12}$');

  static String? normalize(String? raw) {
    if (raw == null) return null;
    final t = raw.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    return _re.hasMatch(t) ? t : null;
  }

  static String format(String token) => token.length == 12
      ? '${token.substring(0, 4)}-${token.substring(4, 8)}-${token.substring(8)}'
      : token;

  /// Ilova havolasi (ilova o'rnatilgan telefonda to'g'ridan-to'g'ri ochiladi).
  static String appLink(String token) =>
      Uri(scheme: 'labguide', host: 'app', path: '/ti', queryParameters: {
        't': token,
      }).toString();
}

@immutable
class TtInvitePreview {
  const TtInvitePreview({
    required this.groupId,
    required this.groupName,
    required this.alreadyMember,
    required this.ownGroup,
    this.teacherAlias,
    this.expiresAt,
  });

  factory TtInvitePreview.fromJson(Map<String, Object?> j) => TtInvitePreview(
    groupId: j['group_id']! as String,
    groupName: j['group_name']! as String,
    teacherAlias: j['teacher_alias'] as String?,
    alreadyMember: j['already_member'] == true,
    ownGroup: j['own_group'] == true,
    expiresAt: DateTime.tryParse(j['expires_at'] as String? ?? ''),
  );

  final String groupId;
  final String groupName;
  final String? teacherAlias;
  final bool alreadyMember;
  final bool ownGroup;
  final DateTime? expiresAt;
}

@immutable
class TtReviewItem {
  const TtReviewItem({
    required this.text,
    required this.options,
    required this.answer,
    required this.correct,
    this.explanation,
  });

  factory TtReviewItem.fromJson(Map<String, Object?> j) => TtReviewItem(
    text: j['text']! as String,
    options: (j['options'] as List? ?? const []).cast<String>(),
    answer: (j['answer'] as num?)?.toInt() ?? -1,
    correct: (j['correct'] as num?)?.toInt() ?? 0,
    explanation: j['explanation'] as String?,
  );

  final String text;
  final List<String> options;
  final int answer;
  final int correct;
  final String? explanation;
}

/// Talabaning urinishi (natija — o'ziga doim ko'rinadi; javoblar kaliti va
/// izohlar faqat [review] ochiq bo'lsa).
@immutable
class TtAttempt {
  const TtAttempt({
    required this.id,
    required this.attemptNo,
    required this.status,
    required this.total,
    this.startedAt,
    this.submittedAt,
    this.score,
    this.percent,
    this.passed,
    this.late = false,
    this.seconds,
    this.review,
  });

  factory TtAttempt.fromJson(Map<String, Object?> j) => TtAttempt(
    id: j['id']! as String,
    attemptNo: (j['attempt_no'] as num?)?.toInt() ?? 1,
    status: TtState.parse(j['status']),
    startedAt: DateTime.tryParse(j['started_at'] as String? ?? ''),
    submittedAt: DateTime.tryParse(j['submitted_at'] as String? ?? ''),
    score: (j['score'] as num?)?.toInt(),
    total: (j['total'] as num?)?.toInt() ?? 0,
    percent: (j['percent'] as num?)?.toInt(),
    passed: j['passed'] as bool?,
    late: j['late'] == true,
    seconds: (j['seconds'] as num?)?.toInt(),
    review: switch (j['review']) {
      final List<Object?> l => [
        for (final r in l) TtReviewItem.fromJson((r! as Map).cast()),
      ],
      _ => null,
    },
  );

  final String id;
  final int attemptNo;

  /// `started` / `submitted` / `expired` (server qatori).
  final TtState status;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int? score;
  final int total;
  final int? percent;
  final bool? passed;
  final bool late;
  final int? seconds;
  final List<TtReviewItem>? review;
}

/// Talabaga berilgan Ustoz testi.
@immutable
class StudentTeacherTest {
  const StudentTeacherTest({
    required this.id,
    required this.title,
    required this.groupId,
    required this.groupName,
    required this.questionCount,
    required this.maxAttempts,
    required this.attemptsUsed,
    required this.dueAt,
    required this.acceptLate,
    required this.closed,
    required this.state,
    required this.canStart,
    this.teacherAlias,
    this.timeLimitMinutes,
    this.passPercent,
    this.openAttemptId,
    this.bestPercent,
    this.passed,
    this.late = false,
    this.attempts = const [],
  });

  factory StudentTeacherTest.fromJson(
    Map<String, Object?> j,
  ) => StudentTeacherTest(
    id: j['id']! as String,
    title: j['title']! as String,
    groupId: j['group_id']! as String,
    groupName: j['group_name'] as String? ?? '',
    teacherAlias: j['teacher_alias'] as String?,
    questionCount: (j['question_count'] as num?)?.toInt() ?? 0,
    timeLimitMinutes: (j['time_limit_minutes'] as num?)?.toInt(),
    passPercent: (j['pass_percent'] as num?)?.toInt(),
    maxAttempts: (j['max_attempts'] as num?)?.toInt() ?? 1,
    attemptsUsed: (j['attempts_used'] as num?)?.toInt() ?? 0,
    dueAt: DateTime.parse(j['due_at']! as String),
    acceptLate: j['late_policy'] == 'accept',
    closed: j['status'] == 'closed',
    state: TtState.parse(j['state']),
    canStart: j['can_start'] == true,
    openAttemptId: j['open_attempt_id'] as String?,
    bestPercent: (j['best_percent'] as num?)?.toInt(),
    passed: j['passed'] as bool?,
    late: j['late'] == true,
    attempts: [
      for (final a in (j['attempts'] as List? ?? const []))
        TtAttempt.fromJson((a as Map).cast()),
    ],
  );

  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final String? teacherAlias;
  final int questionCount;
  final int? timeLimitMinutes;
  final int? passPercent;
  final int maxAttempts;
  final int attemptsUsed;
  final DateTime dueAt;
  final bool acceptLate;
  final bool closed;
  final TtState state;
  final bool canStart;
  final String? openAttemptId;
  final int? bestPercent;
  final bool? passed;
  final bool late;
  final List<TtAttempt> attempts;

  /// Boshlangan (topshirilmagan) urinish bor — davom ettiriladi (gate yo'q).
  bool get inProgress => openAttemptId != null;

  /// Hali hech narsa topshirilmagan — "natija ustozga ko'rinadi" ogohlantirishi.
  bool get firstSubmission =>
      !attempts.any((a) => a.status == TtState.submitted) &&
      state != TtState.submitted;
}

@immutable
class TtRunQuestion {
  const TtRunQuestion({required this.text, required this.options});

  factory TtRunQuestion.fromJson(Map<String, Object?> j) => TtRunQuestion(
    text: j['text']! as String,
    options: (j['options'] as List? ?? const []).cast<String>(),
  );

  final String text;
  final List<String> options;
}

/// Boshlangan urinish (kalitsiz savollar va server vaqti).
@immutable
class TtRun {
  const TtRun({
    required this.attemptId,
    required this.attemptNo,
    required this.startedAt,
    required this.serverNow,
    required this.resumed,
    required this.questions,
    this.timeUpAt,
  });

  factory TtRun.fromJson(Map<String, Object?> j) => TtRun(
    attemptId: j['attempt_id']! as String,
    attemptNo: (j['attempt_no'] as num?)?.toInt() ?? 1,
    startedAt: DateTime.parse(j['started_at']! as String),
    timeUpAt: DateTime.tryParse(j['time_up_at'] as String? ?? ''),
    serverNow: DateTime.parse(j['server_now']! as String),
    resumed: j['resumed'] == true,
    questions: [
      for (final q in (j['questions'] as List? ?? const []))
        TtRunQuestion.fromJson((q as Map).cast()),
    ],
  );

  final String attemptId;
  final int attemptNo;
  final DateTime startedAt;
  final DateTime? timeUpAt;
  final DateTime serverNow;
  final bool resumed;
  final List<TtRunQuestion> questions;
}

/// Ustoz Pro serveri (faqat Cloudflare; Pro bayrog'i yoqilgan buildda).
abstract interface class TeacherTestBackend {
  // --- ustoz: testlar (teacherTestBuilder)
  Future<List<TeacherTest>> teacherTests();
  Future<TeacherTest> teacherTest(String id);
  Future<TeacherTest> createTeacherTest(TeacherTestInput input);
  Future<TeacherTest> updateTeacherTest(String id, TeacherTestInput input);
  Future<void> deleteTeacherTest(String id);

  // --- ustoz: topshirish va taklifnoma (teacherTestAssign)
  Future<TtAssignment> assignTeacherTest(
    String testId, {
    required String groupId,
    required DateTime dueAt,
    String? userId,
    int maxAttempts = 1,
    bool acceptLate = false,
  });
  Future<List<TtAssignment>> teacherAssignments({String? testId});
  Future<void> closeTeacherAssignment(String id);
  Future<void> deleteTeacherAssignment(String id);
  Future<List<TtInvite>> groupInvites(String groupId);
  Future<TtInvite> createInvite(String groupId, {int maxUses = 50, int days = 7});
  Future<void> revokeInvite(String id);

  // --- ustoz: natijalar (teacherResults)
  Future<TtResults> teacherResults(String assignmentId);
  Future<TtExport> exportTeacherResults(String assignmentId);

  // --- talaba: taklifnoma (rozilik) va Ustoz testlari (teacherTests)
  Future<TtInvitePreview> previewInvite(String token);

  /// Guruh id si.
  Future<String> acceptInvite(String token, {String? displayName});
  Future<List<StudentTeacherTest>> myTeacherTests();
  Future<StudentTeacherTest> myTeacherTest(String id);
  Future<TtRun> startTeacherTest(String id);
  Future<TtAttempt> submitTeacherTest(
    String id, {
    required String attemptId,
    required List<int> answers,
  });
}

/// Server [TeacherTestBackend] ni beradimi (Cloudflare — ha).
abstract interface class TeacherTestHost {
  TeacherTestBackend get teacherTestApi;
}

/// Server xato kodi bo'yicha (masalan, `tier_insufficient`).
extension TtErrorX on BackendException {
  /// Serverdagi reja bu amalni ochmaydi (client gate'dan o'tib ketgan holat).
  bool get planNeeded =>
      code == 'plan_required' || code == 'tier_insufficient';
}
