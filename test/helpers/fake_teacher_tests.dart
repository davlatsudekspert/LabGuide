import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/teacher_tests.dart';

import 'fake_backend.dart';

/// [FakeLabBackend] + Ustoz Pro serveri (xotirada). Qoidalar
/// `cloudflare/src/teachertests.ts` bilan bir xil (egalik, kalit talabaga
/// berilmaydi, muddat/urinishlar/yopilish serverda, faqat a'zo talabalar,
/// rozilik bilan taklifnoma). Reja tekshiruvi — [allows] (standart: ochiq);
/// ilovadagi gate'dan o'tib ketgan holatni sinash uchun yopiladi.
class FakeTeacherLabBackend extends FakeLabBackend implements TeacherTestHost {
  FakeTeacherLabBackend() {
    teacherTestApi = FakeTeacherTests(this);
  }

  @override
  late final FakeTeacherTests teacherTestApi;
}

class _Test {
  _Test(this.id, this.owner, this.input, this.version, this.updatedAt);
  final String id;
  final String owner;
  TeacherTestInput input;
  int version;
  DateTime updatedAt;
}

class _Assignment {
  _Assignment({
    required this.id,
    required this.testId,
    required this.owner,
    required this.groupId,
    required this.groupName,
    required this.userId,
    required this.title,
    required this.questions,
    required this.timeLimit,
    required this.passPercent,
    required this.maxAttempts,
    required this.dueAt,
    required this.acceptLate,
  });
  final String id;
  final String testId;
  final String owner;
  final String groupId;
  final String groupName;
  final String? userId;
  final String title;
  final List<TtQuestion> questions;
  final int? timeLimit;
  final int? passPercent;
  final int maxAttempts;
  final DateTime dueAt;
  final bool acceptLate;
  DateTime? closedAt;
  String? teacherAlias;
}

class _Attempt {
  _Attempt(
    this.id,
    this.assignmentId,
    this.userId,
    this.no,
    this.startedAt,
    this.timeUpAt,
  );
  final String id;
  final String assignmentId;
  final String userId;
  final int no;
  final DateTime startedAt;
  final DateTime? timeUpAt;
  TtState status = TtState.started;
  List<int>? answers;
  int? score;
  DateTime? submittedAt;
  bool late = false;
}

class _Invite {
  _Invite(
    this.id,
    this.token,
    this.groupId,
    this.groupName,
    this.code,
    this.owner,
    this.maxUses,
    this.expiresAt,
  );
  final String id;
  final String token;
  final String groupId;
  final String groupName;
  final String code;
  final String owner;
  final int maxUses;
  final DateTime expiresAt;
  int uses = 0;
  bool revoked = false;
}

class FakeTeacherTests implements TeacherTestBackend {
  FakeTeacherTests(this.host);

  final FakeLabBackend host;

  /// Server reja qarori (`requireTier`): (foydalanuvchi, imkoniyat) → ruxsat.
  bool Function(String userId, String capability) allows = (_, _) => true;

  /// Internet yo'q holatini sinash.
  bool offline = false;

  final calls = <String>[];
  final _tests = <_Test>[];
  final _assignments = <_Assignment>[];
  final _attempts = <_Attempt>[];
  final _invites = <_Invite>[];
  int _seq = 0;

  static const grace = Duration(minutes: 2);

  String _id(String p) =>
      '00000000-0000-4000-8000-${(++_seq).toString().padLeft(12, '0')}';

  DateTime get _now => host.groupClock().toUtc();

  Never _err(BackendFailure f, String code) =>
      throw BackendException(f, code, code);

  String _me() {
    if (offline) _err(BackendFailure.network, 'offline');
    final u = host.userId;
    if (u == null) _err(BackendFailure.unauthorized, 'unauthorized');
    return u;
  }

  String _tier(String cap) {
    final u = _me();
    if (!allows(u, cap)) _err(BackendFailure.forbidden, 'plan_required');
    return u;
  }

  _Test _own(String id) =>
      _tests.where((t) => t.id == id && t.owner == _me()).firstOrNull ??
      _err(BackendFailure.notFound, 'not_found');

  TeacherTest _json(_Test t) => TeacherTest(
    id: t.id,
    title: t.input.title.trim(),
    description: (t.input.description?.trim().isEmpty ?? true)
        ? null
        : t.input.description!.trim(),
    questionCount: t.input.questions.length,
    published: t.input.published,
    version: t.version,
    questions: List.unmodifiable(t.input.questions),
    timeLimitMinutes: t.input.timeLimitMinutes,
    passPercent: t.input.passPercent,
    updatedAt: t.updatedAt,
    assignmentCount: _assignments.where((a) => a.testId == t.id).length,
  );

  void _validate(TeacherTestInput input) {
    final e = input.validate();
    if (e != null) _err(BackendFailure.invalid, e);
  }

  @override
  Future<List<TeacherTest>> teacherTests() async {
    calls.add('teacherTests');
    final me = _me();
    return [
      for (final t in _tests.reversed)
        if (t.owner == me) _json(t),
    ];
  }

  @override
  Future<TeacherTest> teacherTest(String id) async => _json(_own(id));

  @override
  Future<TeacherTest> createTeacherTest(TeacherTestInput input) async {
    calls.add('createTeacherTest');
    final me = _tier('teacher_panel');
    _validate(input);
    final t = _Test(_id('t'), me, input, 1, _now);
    _tests.add(t);
    return _json(t);
  }

  @override
  Future<TeacherTest> updateTeacherTest(
    String id,
    TeacherTestInput input,
  ) async {
    calls.add('updateTeacherTest');
    _tier('teacher_panel');
    final t = _own(id);
    if (input.version != null && input.version != t.version) {
      _err(BackendFailure.invalid, 'version_conflict');
    }
    _validate(input);
    t
      ..input = input
      ..version += 1
      ..updatedAt = _now;
    return _json(t);
  }

  @override
  Future<void> deleteTeacherTest(String id) async {
    final t = _own(id);
    final ids = {
      for (final a in _assignments)
        if (a.testId == t.id) a.id,
    };
    _attempts.removeWhere((x) => ids.contains(x.assignmentId));
    _assignments.removeWhere((a) => a.testId == t.id);
    _tests.remove(t);
  }

  @override
  Future<TtAssignment> assignTeacherTest(
    String testId, {
    required String groupId,
    required DateTime dueAt,
    String? userId,
    int maxAttempts = 1,
    bool acceptLate = false,
  }) async {
    calls.add('assignTeacherTest');
    final me = _tier('teacher_panel');
    final t = _own(testId);
    if (!t.input.published) _err(BackendFailure.invalid, 'not_published');
    final group = (await host.myGroups())
        .where((g) => g.id == groupId && g.isTeacher)
        .firstOrNull;
    if (group == null) _err(BackendFailure.notFound, 'not_found');
    final members = await host.groupMembers(groupId);
    if (userId != null &&
        !members.any((m) => m.userId == userId && !m.isTeacher)) {
      _err(BackendFailure.notFound, 'member_not_found');
    }
    if (!dueAt.isAfter(_now)) _err(BackendFailure.invalid, 'invalid_due');
    final teacher = members.where((m) => m.isTeacher).firstOrNull;
    final a = _Assignment(
      id: _id('a'),
      testId: t.id,
      owner: me,
      groupId: groupId,
      groupName: group.name,
      userId: userId,
      title: t.input.title.trim(),
      questions: List.of(t.input.questions),
      timeLimit: t.input.timeLimitMinutes,
      passPercent: t.input.passPercent,
      maxAttempts: maxAttempts,
      dueAt: dueAt.toUtc(),
      acceptLate: acceptLate,
    )..teacherAlias = teacher?.alias;
    _assignments.add(a);
    return _assignmentJson(
      a,
      targets: userId == null ? members.where((m) => !m.isTeacher).length : 1,
    );
  }

  TtAssignment _assignmentJson(_Assignment a, {int targets = 0}) =>
      TtAssignment(
        id: a.id,
        testId: a.testId,
        groupId: a.groupId,
        groupName: a.groupName,
        userId: a.userId,
        title: a.title,
        questionCount: a.questions.length,
        timeLimitMinutes: a.timeLimit,
        passPercent: a.passPercent,
        maxAttempts: a.maxAttempts,
        dueAt: a.dueAt,
        acceptLate: a.acceptLate,
        closed: a.closedAt != null,
        submittedCount: {
          for (final x in _attempts)
            if (x.assignmentId == a.id && x.status == TtState.submitted)
              x.userId,
        }.length,
        targetCount: targets,
      );

  _Assignment _ownAssignment(String id) =>
      _assignments.where((a) => a.id == id && a.owner == _me()).firstOrNull ??
      _err(BackendFailure.notFound, 'not_found');

  @override
  Future<List<TtAssignment>> teacherAssignments({String? testId}) async {
    final me = _me();
    return [
      for (final a in _assignments.reversed)
        if (a.owner == me && (testId == null || a.testId == testId))
          _assignmentJson(
            a,
            targets: a.userId == null
                ? (await host.groupMembers(a.groupId))
                      .where((m) => !m.isTeacher)
                      .length
                : 1,
          ),
    ];
  }

  @override
  Future<void> closeTeacherAssignment(String id) async {
    final a = _ownAssignment(id);
    a.closedAt ??= _now;
  }

  @override
  Future<void> deleteTeacherAssignment(String id) async {
    final a = _ownAssignment(id);
    _attempts.removeWhere((x) => x.assignmentId == a.id);
    _assignments.remove(a);
  }

  @override
  Future<TtResults> teacherResults(String assignmentId) async {
    calls.add('teacherResults');
    final a = _ownAssignment(assignmentId);
    final members = [
      for (final m in await host.groupMembers(a.groupId))
        if (!m.isTeacher && (a.userId == null || m.userId == a.userId)) m,
    ];
    final ids = {for (final m in members) m.userId};
    final visible = [
      for (final x in _attempts)
        if (x.assignmentId == a.id && ids.contains(x.userId)) x,
    ];
    int pct(int s, int t) => t == 0 ? 0 : (s * 100 / t).round();
    final students = <TtStudentResult>[];
    final lastByUser = <_Attempt>[];
    for (final m in members) {
      final mine = [
        for (final x in visible)
          if (x.userId == m.userId) x,
      ];
      final done = [
        for (final x in mine)
          if (x.status == TtState.submitted) x,
      ];
      _Attempt? best;
      for (final x in done) {
        if (best == null || (x.score ?? 0) > (best.score ?? 0)) best = x;
      }
      if (done.isNotEmpty) lastByUser.add(done.last);
      students.add(
        TtStudentResult(
          userId: m.userId,
          seatNo: m.seatNo,
          alias: m.alias,
          state: _stateOf(a, mine),
          attempts: mine.length,
          total: a.questions.length,
          bestScore: best?.score,
          bestPercent: best == null
              ? null
              : pct(best.score!, a.questions.length),
          passed: best == null || a.passPercent == null
              ? null
              : pct(best.score!, a.questions.length) >= a.passPercent!,
          bestSeconds: best?.submittedAt?.difference(best.startedAt).inSeconds,
          late: done.any((x) => x.late),
        ),
      );
    }
    final questions = <TtQuestionStat>[
      for (final (i, q) in a.questions.indexed)
        () {
          final chosen = List<int>.filled(q.options.length, 0);
          var answered = 0;
          var right = 0;
          for (final x in lastByUser) {
            final ans = x.answers![i];
            if (ans >= 0) {
              answered++;
              chosen[ans]++;
            }
            if (ans == q.correct) right++;
          }
          return TtQuestionStat(
            index: i,
            text: q.text,
            options: q.options,
            correct: q.correct,
            answered: answered,
            right: right,
            attempts: lastByUser.length,
            correctPercent: lastByUser.isEmpty
                ? null
                : pct(right, lastByUser.length),
            chosen: chosen,
          );
        }(),
    ];
    final finished = students.where((s) => s.bestPercent != null).toList();
    final missed = [
      for (final q in questions)
        if (q.attempts > 0) q,
    ]..sort((x, y) => (x.correctPercent ?? 0).compareTo(y.correctPercent ?? 0));
    return TtResults(
      assignment: _assignmentJson(a, targets: members.length),
      targets: members.length,
      started: students.where((s) => s.attempts > 0).length,
      submitted: finished.length,
      averagePercent: finished.isEmpty
          ? null
          : (finished.map((s) => s.bestPercent!).reduce((x, y) => x + y) /
                    finished.length)
                .round(),
      passRate: a.passPercent == null || finished.isEmpty
          ? null
          : pct(finished.where((s) => s.passed!).length, finished.length),
      averageSeconds: finished.isEmpty ? null : finished.first.bestSeconds,
      students: students,
      questions: questions,
      mostMissed: [for (final q in missed.take(5)) q.index],
    );
  }

  @override
  Future<TtExport> exportTeacherResults(String assignmentId) async {
    calls.add('exportTeacherResults');
    _tier('teacher_panel');
    final r = await teacherResults(assignmentId);
    return TtExport(
      filename: 'labguide-results.csv',
      csv: [
        'student,state,attempts,best_score,total',
        for (final s in r.students)
          '${s.alias ?? 'Talaba ${s.seatNo.toString().padLeft(2, '0')}'},${s.state.name},${s.attempts},${s.bestScore ?? ''},${s.total}',
      ].join('\r\n'),
    );
  }

  @override
  Future<List<TtInvite>> groupInvites(String groupId) async {
    final me = _me();
    return [
      for (final i in _invites.reversed)
        if (i.groupId == groupId && i.owner == me && !i.revoked) _inviteJson(i),
    ];
  }

  TtInvite _inviteJson(_Invite i) => TtInvite(
    id: i.id,
    groupId: i.groupId,
    token: i.token,
    maxUses: i.maxUses,
    uses: i.uses,
    expiresAt: i.expiresAt,
    active: !i.revoked && _now.isBefore(i.expiresAt) && i.uses < i.maxUses,
  );

  @override
  Future<TtInvite> createInvite(
    String groupId, {
    int maxUses = 50,
    int days = 7,
  }) async {
    calls.add('createInvite');
    final me = _tier('teacher_panel');
    final g = (await host.myGroups())
        .where((g) => g.id == groupId && g.isTeacher)
        .firstOrNull;
    if (g == null) _err(BackendFailure.notFound, 'not_found');
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final n = ++_seq;
    final token = [
      for (var i = 0; i < 12; i++) alphabet[(n * 7 + i * 11) % alphabet.length],
    ].join();
    final i = _Invite(
      _id('i'),
      token,
      g.id,
      g.name,
      g.joinCode!,
      me,
      maxUses,
      _now.add(Duration(days: days)),
    );
    _invites.add(i);
    return _inviteJson(i);
  }

  @override
  Future<void> revokeInvite(String id) async {
    final me = _me();
    final i = _invites.where((x) => x.id == id && x.owner == me).firstOrNull;
    if (i == null) _err(BackendFailure.notFound, 'not_found');
    i.revoked = true;
  }

  _Invite _invite(String token) {
    final t = TtInviteCode.normalize(token);
    final i = _invites.where((x) => x.token == t).firstOrNull;
    if (i == null) _err(BackendFailure.notFound, 'not_found');
    if (i.revoked || !_now.isBefore(i.expiresAt) || i.uses >= i.maxUses) {
      _err(BackendFailure.invalid, 'invite_expired');
    }
    return i;
  }

  @override
  Future<TtInvitePreview> previewInvite(String token) async {
    final me = _me();
    final i = _invite(token);
    final mine = await host.myGroups();
    return TtInvitePreview(
      groupId: i.groupId,
      groupName: i.groupName,
      alreadyMember: mine.any((g) => g.id == i.groupId),
      ownGroup: i.owner == me,
      expiresAt: i.expiresAt,
    );
  }

  @override
  Future<String> acceptInvite(String token, {String? displayName}) async {
    calls.add('acceptInvite');
    final me = _me();
    final i = _invite(token);
    if (i.owner == me) _err(BackendFailure.invalid, 'own_group');
    if ((await host.myGroups()).any((g) => g.id == i.groupId)) return i.groupId;
    await host.joinGroup(i.code, displayName: displayName);
    i.uses++;
    return i.groupId;
  }

  // ------------------------------------------------------------ talaba
  Future<_Assignment> _mine(String id) async {
    final me = _me();
    final groups = {
      for (final g in await host.myGroups())
        if (!g.isTeacher) g.id,
    };
    return _assignments
            .where(
              (a) =>
                  a.id == id &&
                  groups.contains(a.groupId) &&
                  (a.userId == null || a.userId == me),
            )
            .firstOrNull ??
        _err(BackendFailure.notFound, 'not_found');
  }

  bool _timedOut(_Attempt x) =>
      x.timeUpAt != null && _now.isAfter(x.timeUpAt!.add(grace));

  TtState _stateOf(_Assignment a, List<_Attempt> mine) {
    if (mine.any((x) => x.status == TtState.started && !_timedOut(x))) {
      return TtState.started;
    }
    if (mine.any((x) => x.status == TtState.submitted)) {
      return TtState.submitted;
    }
    if (a.closedAt != null || (_now.isAfter(a.dueAt) && !a.acceptLate)) {
      return TtState.expired;
    }
    if (mine.length >= a.maxAttempts) return TtState.expired;
    return TtState.assigned;
  }

  String? _blocked(_Assignment a, int used) {
    if (a.closedAt != null) return 'closed';
    if (_now.isAfter(a.dueAt) && !a.acceptLate) return 'past_due';
    if (used >= a.maxAttempts) return 'no_attempts_left';
    return null;
  }

  bool _revealed(_Assignment a, List<_Attempt> mine) =>
      a.closedAt != null ||
      _now.isAfter(a.dueAt) ||
      mine.length >= a.maxAttempts;

  TtAttempt _attemptJson(_Attempt x, _Assignment a, bool reveal) => TtAttempt(
    id: x.id,
    attemptNo: x.no,
    status: x.status,
    startedAt: x.startedAt,
    submittedAt: x.submittedAt,
    score: x.score,
    total: a.questions.length,
    percent: x.score == null
        ? null
        : (x.score! * 100 / a.questions.length).round(),
    passed: x.score == null || a.passPercent == null
        ? null
        : (x.score! * 100 / a.questions.length).round() >= a.passPercent!,
    late: x.late,
    seconds: x.submittedAt?.difference(x.startedAt).inSeconds,
    review: reveal && x.answers != null
        ? [
            for (final (i, q) in a.questions.indexed)
              TtReviewItem(
                text: q.text,
                options: q.options,
                answer: x.answers![i],
                correct: q.correct,
                explanation: q.explanation,
              ),
          ]
        : null,
  );

  StudentTeacherTest _studentJson(
    _Assignment a,
    List<_Attempt> mine, {
    bool detail = false,
  }) {
    final open = mine
        .where((x) => x.status == TtState.started && !_timedOut(x))
        .firstOrNull;
    final done = mine.where((x) => x.status == TtState.submitted).toList();
    _Attempt? best;
    for (final x in done) {
      if (best == null || (x.score ?? 0) > (best.score ?? 0)) best = x;
    }
    final reveal = _revealed(a, mine);
    return StudentTeacherTest(
      id: a.id,
      title: a.title,
      groupId: a.groupId,
      groupName: a.groupName,
      teacherAlias: a.teacherAlias,
      questionCount: a.questions.length,
      timeLimitMinutes: a.timeLimit,
      passPercent: a.passPercent,
      maxAttempts: a.maxAttempts,
      attemptsUsed: mine.length,
      dueAt: a.dueAt,
      acceptLate: a.acceptLate,
      closed: a.closedAt != null,
      state: _stateOf(a, mine),
      canStart: open == null && _blocked(a, mine.length) == null,
      openAttemptId: open?.id,
      bestPercent: best == null
          ? null
          : (best.score! * 100 / a.questions.length).round(),
      late: done.any((x) => x.late),
      attempts: detail
          ? [for (final x in mine) _attemptJson(x, a, reveal)]
          : const [],
    );
  }

  List<_Attempt> _attemptsOf(String aid, String uid) => [
    for (final x in _attempts)
      if (x.assignmentId == aid && x.userId == uid) x,
  ];

  @override
  Future<List<StudentTeacherTest>> myTeacherTests() async {
    calls.add('myTeacherTests');
    final me = _me();
    final groups = {
      for (final g in await host.myGroups())
        if (!g.isTeacher) g.id,
    };
    return [
      for (final a in _assignments.reversed)
        if (groups.contains(a.groupId) && (a.userId == null || a.userId == me))
          _studentJson(a, _attemptsOf(a.id, me)),
    ];
  }

  @override
  Future<StudentTeacherTest> myTeacherTest(String id) async {
    final a = await _mine(id);
    return _studentJson(a, _attemptsOf(a.id, _me()), detail: true);
  }

  TtRun _run(_Attempt x, _Assignment a, bool resumed) => TtRun(
    attemptId: x.id,
    attemptNo: x.no,
    startedAt: x.startedAt,
    timeUpAt: x.timeUpAt,
    serverNow: _now,
    resumed: resumed,
    questions: [
      for (final q in a.questions)
        TtRunQuestion(text: q.text, options: q.options),
    ],
  );

  @override
  Future<TtRun> startTeacherTest(String id) async {
    calls.add('startTeacherTest');
    final a = await _mine(id);
    final me = _me();
    final mine = _attemptsOf(a.id, me);
    final open = mine.where((x) => x.status == TtState.started).firstOrNull;
    if (open != null && !_timedOut(open)) return _run(open, a, true);
    if (open != null) open.status = TtState.expired;
    _tier('learner');
    final blocked = _blocked(a, mine.length);
    if (blocked != null) _err(BackendFailure.invalid, blocked);
    final ends = [
      if (a.timeLimit != null) _now.add(Duration(minutes: a.timeLimit!)),
      if (!a.acceptLate) a.dueAt,
    ]..sort();
    final x = _Attempt(
      _id('x'),
      a.id,
      me,
      mine.length + 1,
      _now,
      ends.firstOrNull,
    );
    _attempts.add(x);
    return _run(x, a, false);
  }

  @override
  Future<TtAttempt> submitTeacherTest(
    String id, {
    required String attemptId,
    required List<int> answers,
  }) async {
    calls.add('submitTeacherTest');
    final a = await _mine(id);
    final me = _me();
    final x =
        _attempts
            .where(
              (x) =>
                  x.id == attemptId && x.assignmentId == a.id && x.userId == me,
            )
            .firstOrNull ??
        _err(BackendFailure.notFound, 'not_found');
    if (x.status == TtState.submitted) {
      _err(BackendFailure.invalid, 'already_submitted');
    }
    if (x.status == TtState.expired || _timedOut(x)) {
      x.status = TtState.expired;
      _err(BackendFailure.invalid, 'time_over');
    }
    if (answers.length != a.questions.length) {
      _err(BackendFailure.invalid, 'invalid_answers');
    }
    x
      ..answers = List.of(answers)
      ..score = [
        for (final (i, q) in a.questions.indexed)
          if (answers[i] == q.correct) 1,
      ].length
      ..submittedAt = _now
      ..late = a.acceptLate && _now.isAfter(a.dueAt)
      ..status = TtState.submitted;
    return _attemptJson(x, a, _revealed(a, _attemptsOf(a.id, me)));
  }

  /// Talaba guruhdan chiqdi (server `teacherLeaveStatements`).
  void forgetMember(String groupId, String userId) {
    final ids = {
      for (final a in _assignments)
        if (a.groupId == groupId) a.id,
    };
    _attempts.removeWhere(
      (x) => x.userId == userId && ids.contains(x.assignmentId),
    );
  }
}
