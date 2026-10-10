import 'dart:async';
import 'dart:typed_data';

import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/lab_backend.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/features/auth/otp_auth.dart';

class _User {
  _User(this.id, this.email);
  final String id;
  final String email;
  String? role;
  String? language;
  bool reviewer = false;
  bool teacher = false;
  bool totpVerified = false;
}

/// Widget testlar uchun xotiradagi server. Qoidalari
/// `supabase/migrations` bilan bir xil: admin — faqat server ro'yxatidagi
/// email tasdiqlanganda (ilova emas), admin amallari aal2 talab qiladi,
/// har foydalanuvchi faqat o'z murojaatlarini ko'radi.
///
/// Bitta obyekt ko'p foydalanuvchini saqlaydi — chiqib, boshqa email bilan
/// kirish mumkin (qabul tekshiruvi kabi).
class FakeLabBackend implements LabBackend {
  FakeLabBackend({this.adminEmails = const {'davlatsudekspert@gmail.com'}});

  final Set<String> adminEmails;
  static const otpCode = '123456';
  static const totpCode = '000000';

  final Map<String, _User> _users = {};
  final Map<String, String> _pendingCodes = {};
  _User? _current;
  bool _aal2 = false;
  int _seq = 0;
  final List<SupportThread> _threads = [];
  final List<SupportMessage> _messages = [];
  final Map<String, Uint8List> _files = {};
  final List<AuditEntry> audit = [];
  final _lost = StreamController<void>.broadcast();

  String _id(String p) => '$p-${++_seq}';
  DateTime _now() => DateTime.now().toUtc().add(Duration(microseconds: _seq));

  @override
  bool get isConfigured => true;
  @override
  bool get isAvailable => true;
  @override
  bool get isDemo => false;
  @override
  bool get hasSession => _current != null;
  @override
  String? get sessionEmail => _current?.email;
  @override
  String? get userId => _current?.id;
  @override
  Stream<void> get sessionLost => _lost.stream;

  /// Server sessiyani bekor qildi (masalan, hisob boshqa qurilmada
  /// o'chirildi).
  void revokeSession() {
    _current = null;
    _lost.add(null);
  }

  @override
  Future<OtpRequestResult> requestCode(String email) async {
    if (!isValidEmail(email)) {
      return const OtpRequestResult(OtpRequestStatus.invalidEmail);
    }
    _pendingCodes[normalizeEmail(email)] = otpCode;
    return const OtpRequestResult(
      OtpRequestStatus.sent,
      retryAfter: Duration(seconds: 60),
      validFor: Duration(minutes: 10),
    );
  }

  @override
  Future<OtpVerifyResult> verifyCode(String email, String code) async {
    final key = normalizeEmail(email);
    if (_pendingCodes[key] == null) {
      return const OtpVerifyResult(OtpVerifyStatus.noActiveCode);
    }
    if (code.trim() != _pendingCodes[key]) {
      return const OtpVerifyResult(
        OtpVerifyStatus.invalidCode,
        attemptsLeft: 4,
      );
    }
    _pendingCodes.remove(key);
    _current = _users.putIfAbsent(key, () => _User(_id('user'), key));
    _aal2 = false;
    return const OtpVerifyResult(OtpVerifyStatus.verified);
  }

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> signOut() async {
    _current = null;
    _aal2 = false;
  }

  @override
  Future<void> deleteAccount() async {
    final u = _require();
    _users.remove(u.email);
    _threads.removeWhere((t) => t.userId == u.id);
    _current = null;
  }

  _User _require() =>
      _current ?? (throw const BackendException(BackendFailure.unauthorized));

  bool get _isAdminAccount =>
      _current != null && adminEmails.contains(_current!.email);
  bool get _isAdmin => _isAdminAccount && _aal2;
  void _requireAdmin() {
    if (!_isAdmin) throw const BackendException(BackendFailure.forbidden);
  }

  int get registeredCount => _users.length;

  @override
  Future<AccessInfo> myAccess() async => _current == null
      ? AccessInfo.none
      : AccessInfo(
          adminAccount: _isAdminAccount,
          aal2: _aal2,
          reviewer: _current!.reviewer,
          teacher: _current!.teacher,
        );

  @override
  Future<void> touchProfile({
    required String role,
    required String language,
  }) async {
    final u = _require();
    u
      ..role = role
      ..language = language;
  }

  @override
  Future<MfaStatus> mfaStatus() async {
    final u = _require();
    return MfaStatus(
      verifiedFactorId: u.totpVerified ? 'totp-1' : null,
      aal2: _aal2,
    );
  }

  @override
  Future<TotpEnrollment> mfaEnroll() async {
    _require();
    return const TotpEnrollment(
      factorId: 'totp-1',
      secret: 'JBSWY3DPEHPK3PXP',
      uri: 'otpauth://totp/LabGuide:admin?secret=JBSWY3DPEHPK3PXP&issuer=LabGuide',
    );
  }

  @override
  Future<void> mfaVerify({
    required String factorId,
    required String code,
  }) async {
    final u = _require();
    if (code.trim() != totpCode) {
      throw const BackendException(BackendFailure.invalid);
    }
    u.totpVerified = true;
    _aal2 = true;
  }

  SupportThread _thread(String id) => _threads.firstWhere(
    (t) => t.id == id,
    orElse: () => throw const BackendException(BackendFailure.notFound),
  );

  SupportThread _copy(
    SupportThread t, {
    SupportStatus? status,
    DateTime? lastUser,
    DateTime? lastAdmin,
    DateTime? userRead,
    DateTime? adminRead,
  }) => SupportThread(
    id: t.id,
    userId: t.userId,
    kind: t.kind,
    subject: t.subject,
    status: status ?? t.status,
    createdAt: t.createdAt,
    updatedAt: _now(),
    lastUserMessageAt: lastUser ?? t.lastUserMessageAt,
    lastAdminMessageAt: lastAdmin ?? t.lastAdminMessageAt,
    userReadAt: userRead ?? t.userReadAt,
    adminReadAt: adminRead ?? t.adminReadAt,
  );

  void _replace(SupportThread t) {
    _threads[_threads.indexWhere((x) => x.id == t.id)] = t;
  }

  String? _store(SupportAttachment? a) {
    if (a == null) return null;
    if (a.bytes.length > SupportAttachment.maxBytes ||
        !SupportAttachment.allowedTypes.contains(a.mimeType)) {
      throw const BackendException(BackendFailure.invalid);
    }
    final path = '${_require().id}/${_id('file')}.${a.extension}';
    _files[path] = a.bytes;
    return path;
  }

  @override
  Future<List<SupportThread>> myThreads() async {
    final u = _require();
    return _threads.where((t) => t.userId == u.id).toList().reversed.toList();
  }

  @override
  Future<List<SupportMessage>> messages(String threadId) async {
    final t = _thread(threadId);
    if (t.userId != _require().id && !_isAdmin) {
      throw const BackendException(BackendFailure.forbidden);
    }
    return _messages.where((m) => m.threadId == threadId).toList();
  }

  @override
  Future<String> createThread({
    required SupportKind kind,
    required String subject,
    required String body,
    SupportAttachment? attachment,
  }) async {
    final u = _require();
    if (subject.trim().length < 3 || body.trim().isEmpty) {
      throw const BackendException(BackendFailure.invalid);
    }
    final path = _store(attachment);
    final now = _now();
    final t = SupportThread(
      id: _id('thread'),
      userId: u.id,
      kind: kind,
      subject: subject.trim(),
      status: SupportStatus.newThread,
      createdAt: now,
      updatedAt: now,
      lastUserMessageAt: now,
      lastAdminMessageAt: null,
      userReadAt: now,
      adminReadAt: null,
    );
    _threads.add(t);
    _messages.add(
      SupportMessage(
        id: _id('msg'),
        threadId: t.id,
        fromAdmin: false,
        body: body.trim(),
        attachmentPath: path,
        createdAt: now,
      ),
    );
    return t.id;
  }

  @override
  Future<void> postMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  }) async {
    final t = _thread(threadId);
    if (t.userId != _require().id) {
      throw const BackendException(BackendFailure.forbidden);
    }
    final path = _store(attachment);
    final now = _now();
    _messages.add(
      SupportMessage(
        id: _id('msg'),
        threadId: threadId,
        fromAdmin: false,
        body: body.trim(),
        attachmentPath: path,
        createdAt: now,
      ),
    );
    _replace(
      _copy(
        t,
        lastUser: now,
        userRead: now,
        status:
            t.status == SupportStatus.answered ||
                t.status == SupportStatus.closed
            ? SupportStatus.newThread
            : null,
      ),
    );
  }

  @override
  Future<void> markRead(String threadId) async {
    final t = _thread(threadId);
    if (t.userId != _require().id) {
      throw const BackendException(BackendFailure.forbidden);
    }
    _replace(_copy(t, userRead: _now()));
  }

  @override
  Future<Uint8List> attachment(String path) async {
    final owner = path.split('/').first;
    if (owner != _require().id && !_isAdmin) {
      throw const BackendException(BackendFailure.forbidden);
    }
    return _files[path] ??
        (throw const BackendException(BackendFailure.notFound));
  }

  @override
  Future<AdminStats> adminStats() async {
    _requireAdmin();
    int count(SupportStatus s) => _threads.where((t) => t.status == s).length;
    final roles = <String, int>{};
    final langs = <String, int>{};
    for (final u in _users.values) {
      if (u.role != null) roles[u.role!] = (roles[u.role!] ?? 0) + 1;
      if (u.language != null) {
        langs[u.language!] = (langs[u.language!] ?? 0) + 1;
      }
    }
    return AdminStats({
      'registered': _users.length,
      'new_today': _users.length,
      'new_7d': _users.length,
      'new_30d': _users.length,
      'active_today': _users.values.where((u) => u.role != null).length,
      'active_7d': _users.values.where((u) => u.role != null).length,
      'active_30d': _users.values.where((u) => u.role != null).length,
      'by_role': roles,
      'by_language': langs,
      'without_profile': _users.values.where((u) => u.role == null).length,
      'billing': null,
      'support': {
        'new': count(SupportStatus.newThread),
        'in_review': count(SupportStatus.inReview),
        'answered': count(SupportStatus.answered),
        'closed': count(SupportStatus.closed),
        'awaiting_reply':
            count(SupportStatus.newThread) + count(SupportStatus.inReview),
      },
    });
  }

  @override
  Future<List<SupportThread>> adminThreads({SupportStatus? status}) async {
    _requireAdmin();
    return _threads
        .where((t) => status == null || t.status == status)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> adminReply(String threadId, String body) async {
    _requireAdmin();
    final t = _thread(threadId);
    final now = _now();
    _messages.add(
      SupportMessage(
        id: _id('msg'),
        threadId: threadId,
        fromAdmin: true,
        body: body.trim(),
        attachmentPath: null,
        createdAt: now,
      ),
    );
    _replace(
      _copy(t, lastAdmin: now, adminRead: now, status: SupportStatus.answered),
    );
    audit.add(
      AuditEntry(
        at: now,
        action: 'support_reply',
        target: threadId,
        details: const {},
      ),
    );
  }

  @override
  Future<void> adminSetStatus(String threadId, SupportStatus status) async {
    _requireAdmin();
    final t = _thread(threadId);
    _replace(_copy(t, status: status));
    audit.add(
      AuditEntry(
        at: _now(),
        action: 'support_status',
        target: threadId,
        details: {'to': supportStatusToWire(status)},
      ),
    );
  }

  @override
  Future<void> adminMarkRead(String threadId) async {
    _requireAdmin();
    _replace(_copy(_thread(threadId), adminRead: _now()));
  }

  @override
  Future<AdminUserPage> adminUsers({
    String? query,
    String? role,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async {
    _requireAdmin();
    final all = _users.values
        .where(
          (u) =>
              (query == null || u.email.contains(query.toLowerCase())) &&
              (role == null || u.role == role) &&
              (language == null || u.language == language),
        )
        .toList();
    final page = all.skip(offset).take(limit);
    return AdminUserPage([
      for (final u in page)
        AdminUserRow(
          userId: u.id,
          emailMasked:
              '${u.email.substring(0, 2)}***@${u.email.split('@').last}',
          role: u.role,
          language: u.language,
          registeredOn: DateTime.utc(2026, 10, 9),
          lastSeenOn: u.role == null ? null : DateTime.utc(2026, 10, 9),
        ),
    ], all.length);
  }

  @override
  Future<String> adminRevealEmail(String userId) async {
    _requireAdmin();
    audit.add(
      AuditEntry(
        at: _now(),
        action: 'reveal_email',
        target: userId,
        details: const {},
      ),
    );
    return _users.values.firstWhere((u) => u.id == userId).email;
  }

  @override
  Future<void> adminSetReviewer(String userId, {required bool enabled}) async {
    _requireAdmin();
    _users.values.firstWhere((u) => u.id == userId).reviewer = enabled;
    audit.add(
      AuditEntry(
        at: _now(),
        action: enabled ? 'reviewer_granted' : 'reviewer_revoked',
        target: userId,
        details: const {},
      ),
    );
  }

  @override
  Future<List<AuditEntry>> adminAudit({int limit = 50}) async {
    _requireAdmin();
    return audit.reversed.take(limit).toList();
  }

  // Kontent tekshiruvi — SQL bilan bir xil: faqat reviewer yozadi/o'qiydi.
  final List<ContentReview> _reviews = [];

  /// Testlar uchun: admin panelidan o'tmasdan reviewer qilish.
  void grantReviewer(String email) =>
      _users[normalizeEmail(email)]!.reviewer = true;

  @override
  Future<void> submitReview({
    required String kind,
    required String itemId,
    required String contentVersion,
    required ReviewDecision decision,
    String? comment,
  }) async {
    final u = _require();
    if (!u.reviewer) throw const BackendException(BackendFailure.forbidden);
    final note = comment?.trim();
    if (decision == ReviewDecision.changes && (note == null || note.isEmpty)) {
      throw const BackendException(BackendFailure.invalid);
    }
    _reviews.insert(
      0,
      ContentReview(
        id: _id('review'),
        itemKind: kind,
        itemId: itemId,
        contentVersion: contentVersion,
        reviewerId: u.id,
        decision: decision,
        comment: note == null || note.isEmpty ? null : note,
        createdAt: _now(),
      ),
    );
  }

  @override
  Future<List<ContentReview>> contentReviews() async {
    final u = _require();
    return u.reviewer || _isAdminAccount ? List.of(_reviews) : const [];
  }

  // ------------------------------------------------------------ guruhlar
  // Qoidalar `supabase/migrations/*groups*.sql` bilan bir xil: guruhni
  // yaratgan hisob — ustoz; talaba faqat kod bilan qo'shiladi; a'zo bo'lmagan
  // hech narsa ko'rmaydi; kalit faqat ustozga; ball serverda; bir marta
  // topshiriladi; muddat va vaqt chegarasi serverda tekshiriladi.

  /// Server soati (muddat/vaqt chegarasi) — testlarda suriladi.
  DateTime Function() groupClock = DateTime.now;

  /// Vaqt chegarasi tugagach tarmoq kechikishi uchun qo'shimcha vaqt.
  static const submitGrace = Duration(minutes: 2);
  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final List<_Group> _groups = [];
  final List<_Member> _members = [];
  final List<_Assignment> _assignments = [];
  final Map<(String, String), DateTime> _attempts = {};
  final List<GroupSubmission> _submissions = [];

  _Member? _membership(String groupId) => _members
      .where((m) => m.groupId == groupId && m.userId == _current?.id)
      .firstOrNull;
  bool _isMember(String groupId) => _membership(groupId) != null;
  bool _isTeacher(String groupId) => _membership(groupId)?.teacher ?? false;

  /// Taxallus: bo'sh — null (tartib raqami ko'rinadi); email ishlatilmaydi.
  String? _aliasOf(String? alias) {
    final a = alias?.trim() ?? '';
    if (a.isEmpty) return null;
    _checkLength(a, 2, 60);
    return a;
  }

  /// Guruh egasi va ro'yxatdan o'tgan ustoz (SQL `_owns_group`).
  bool _owns(String groupId) {
    final u = _current;
    if (u == null || !u.teacher) return false;
    return _groups.any((g) => g.id == groupId && g.ownerId == u.id);
  }

  void _checkLength(String value, int min, int max) {
    final n = value.trim().length;
    if (n < min || n > max) {
      throw const BackendException(BackendFailure.invalid);
    }
  }

  String _newCode() {
    String code;
    do {
      final n = ++_seq * 7919 + _groups.length * 104729;
      code = [
        for (var i = 0; i < 8; i++)
          _codeAlphabet[(n ~/ (i + 1) + i * 13) % _codeAlphabet.length],
      ].join();
    } while (_groups.any((g) => g.code == code));
    return code;
  }

  @override
  Future<List<StudyGroup>> myGroups() async {
    _require();
    return [
      for (final g in _groups.reversed)
        if (_membership(g.id) case final m?)
          StudyGroup(
            id: g.id,
            name: g.name,
            joinCode: m.teacher ? g.code : null,
            isTeacher: m.teacher,
            memberCount: _members.where((x) => x.groupId == g.id).length,
          ),
    ];
  }

  @override
  Future<void> registerTeacher() async {
    _require().teacher = true;
  }

  @override
  Future<StudyGroup> createGroup(String name, {String? displayName}) async {
    final u = _require();
    if (!u.teacher) throw const BackendException(BackendFailure.forbidden);
    _checkLength(name, 3, 80);
    final shown = _aliasOf(displayName);
    if (_groups.where((g) => g.ownerId == u.id).length >= 10) {
      throw const BackendException(BackendFailure.rateLimited);
    }
    final g = _Group(_id('group'), u.id, name.trim(), _newCode());
    _groups.add(g);
    _members.add(_Member(g.id, u.id, shown, teacher: true, joinedAt: _now()));
    return StudyGroup(
      id: g.id,
      name: g.name,
      joinCode: g.code,
      isTeacher: true,
      memberCount: 1,
    );
  }

  @override
  Future<String> joinGroup(String code, {String? displayName}) async {
    final u = _require();
    final g = _groups
        .where((g) => g.code == code.trim().toUpperCase())
        .firstOrNull;
    if (g == null) throw const BackendException(BackendFailure.notFound);
    if (_isMember(g.id)) return g.id; // SQL: qayta qo'shilish o'zgartirmaydi
    final shown = _aliasOf(displayName);
    if (_members.where((m) => m.groupId == g.id).length >= 200) {
      throw const BackendException(BackendFailure.rateLimited);
    }
    _members.add(
      _Member(
        g.id,
        u.id,
        shown,
        teacher: false,
        joinedAt: _now(),
        seatNo: g.nextSeat++,
      ),
    );
    return g.id;
  }

  @override
  Future<void> setMyAlias(String groupId, String? alias) async {
    final m = _membership(groupId);
    if (m == null) throw const BackendException(BackendFailure.forbidden);
    m.alias = _aliasOf(alias);
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    final u = _require();
    _members.removeWhere(
      (m) => m.groupId == groupId && m.userId == u.id && !m.teacher,
    );
  }

  @override
  Future<List<GroupMember>> groupMembers(String groupId) async {
    _require();
    if (!_isMember(groupId)) return const []; // RLS: begona — bo'sh
    // RLS: talaba — o'zi va ustoz qatori; ustoz — hamma.
    final all = _isTeacher(groupId);
    return [
      for (final m in _members)
        if (m.groupId == groupId &&
            (all || m.teacher || m.userId == _current?.id))
          GroupMember(
            userId: m.userId,
            alias: m.alias,
            seatNo: m.seatNo,
            isTeacher: m.teacher,
            joinedAt: m.joinedAt,
          ),
    ];
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    _require();
    if (!_isTeacher(groupId)) {
      throw const BackendException(BackendFailure.forbidden);
    }
    _members.removeWhere(
      (m) => m.groupId == groupId && m.userId == userId && !m.teacher,
    );
  }

  @override
  Future<List<GroupAssignment>> assignments(String groupId) async {
    _require();
    if (!_isMember(groupId)) return const [];
    return [
      for (final a in _assignments.reversed)
        if (a.info.groupId == groupId) a.info,
    ];
  }

  @override
  Future<String> createAssignment({
    required String groupId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    DateTime? dueAt,
    int? timeLimitMinutes,
    String? topicId,
  }) async {
    _require();
    if (!_isTeacher(groupId)) {
      throw const BackendException(BackendFailure.forbidden);
    }
    _checkLength(title, 3, 120);
    if (questionIds.isEmpty ||
        questionIds.length > 50 ||
        questionIds.length != correctIndexes.length ||
        correctIndexes.any((i) => i < 0) ||
        (timeLimitMinutes != null &&
            (timeLimitMinutes < 1 || timeLimitMinutes > 180)) ||
        (dueAt != null && !dueAt.isAfter(groupClock()))) {
      throw const BackendException(BackendFailure.invalid);
    }
    final a = GroupAssignment(
      id: _id('assignment'),
      groupId: groupId,
      title: title.trim(),
      questionIds: List.unmodifiable(questionIds),
      dueAt: dueAt?.toUtc(),
      timeLimitMinutes: timeLimitMinutes,
      createdAt: _now(),
      topicId: topicId,
    );
    _assignments.add(_Assignment(a, List.unmodifiable(correctIndexes)));
    return a.id;
  }

  /// Faqat shu guruhning talabasi (SQL dagi kabi; ustoz yecha olmaydi).
  _Assignment _forStudent(String assignmentId) {
    final u = _require();
    final a = _assignments.where((a) => a.info.id == assignmentId).firstOrNull;
    if (a == null ||
        !_members.any(
          (m) => m.groupId == a.info.groupId && m.userId == u.id && !m.teacher,
        )) {
      throw const BackendException(BackendFailure.forbidden);
    }
    return a;
  }

  @override
  Future<AssignmentStart> startAssignment(String assignmentId) async {
    final a = _forStudent(assignmentId);
    final now = groupClock();
    final key = (assignmentId, _current!.id);
    final due = a.info.dueAt;
    if (!_attempts.containsKey(key) && due != null && now.isAfter(due)) {
      throw const BackendException(BackendFailure.invalid, 'past due');
    }
    final started = _attempts.putIfAbsent(key, () => now);
    return AssignmentStart(startedAt: started, serverNow: now);
  }

  @override
  Future<GroupSubmission> submitAssignment(
    String assignmentId,
    List<int> answers,
  ) async {
    final a = _forStudent(assignmentId);
    final u = _current!;
    final now = groupClock();
    final started = _attempts[(assignmentId, u.id)];
    final due = a.info.dueAt;
    if (due != null) {
      final grace = started != null && !started.isAfter(due)
          ? submitGrace
          : Duration.zero;
      if (now.isAfter(due.add(grace))) {
        throw const BackendException(BackendFailure.invalid, 'past due');
      }
    }
    final limit = a.info.timeLimitMinutes;
    if (limit != null &&
        (started == null ||
            now.isAfter(started.add(Duration(minutes: limit) + submitGrace)))) {
      throw const BackendException(BackendFailure.invalid, 'time over');
    }
    if (answers.length != a.key.length) {
      throw const BackendException(BackendFailure.invalid);
    }
    if (_submissions.any(
      (s) => s.assignmentId == assignmentId && s.userId == u.id,
    )) {
      throw const BackendException(BackendFailure.invalid, 'already');
    }
    final correct = [
      for (var i = 0; i < a.key.length; i++) answers[i] == a.key[i],
    ];
    final s = GroupSubmission(
      assignmentId: assignmentId,
      userId: u.id,
      score: correct.where((c) => c).length,
      total: a.key.length,
      submittedAt: now.toUtc(),
      answers: List.unmodifiable(answers),
      correct: List.unmodifiable(correct),
    );
    _submissions.add(s);
    return s;
  }

  /// RLS: o'z natijasi yoki ustoz bo'lgan guruhniki.
  bool _canSee(GroupSubmission s) {
    final a = _assignments.firstWhere((a) => a.info.id == s.assignmentId);
    return s.userId == _current?.id || _isTeacher(a.info.groupId);
  }

  @override
  Future<List<GroupSubmission>> submissions(String assignmentId) async {
    _require();
    return [
      for (final s in _submissions)
        if (s.assignmentId == assignmentId && _canSee(s)) s,
    ];
  }

  @override
  Future<List<GroupSubmission>> groupSubmissions(String groupId) async {
    final ids = {for (final a in await assignments(groupId)) a.id};
    return [
      for (final s in _submissions)
        if (ids.contains(s.assignmentId) && _canSee(s)) s,
    ];
  }

  @override
  Future<List<int>> assignmentKey(String assignmentId) async {
    _require();
    final a = _assignments.where((a) => a.info.id == assignmentId).firstOrNull;
    if (a == null || !_isTeacher(a.info.groupId)) {
      throw const BackendException(BackendFailure.forbidden);
    }
    return a.key;
  }

  // ------------------------------------------------------------- mavzular
  // `20261010000100_teacher_topics.sql`: a'zo ochilgan mavzularni ko'radi;
  // ochish, bosqich va testni faqat guruh egasi-ustoz o'zgartiradi.

  final Map<(String, String), GroupTopic> _topics = {};
  static final _topicId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.:-]{0,79}$');

  void _requireOwner(String groupId) {
    _require();
    if (!_owns(groupId)) throw const BackendException(BackendFailure.forbidden);
  }

  @override
  Future<List<GroupTopic>> groupTopics(String groupId) async {
    _require();
    if (!_isMember(groupId)) return const [];
    return [
      for (final t in _topics.values)
        if (t.groupId == groupId) t,
    ];
  }

  @override
  Future<void> openTopic(String groupId, String topicId) async {
    _requireOwner(groupId);
    if (!_topicId.hasMatch(topicId)) {
      throw const BackendException(BackendFailure.invalid);
    }
    _topics.putIfAbsent(
      (groupId, topicId),
      () => GroupTopic(
        groupId: groupId,
        topicId: topicId,
        openedAt: groupClock().toUtc(),
      ),
    );
  }

  @override
  Future<void> markTopicStage(
    String groupId,
    String topicId,
    TopicStage stage,
  ) async {
    await openTopic(groupId, topicId);
    final t = _topics[(groupId, topicId)]!;
    final now = groupClock().toUtc();
    _topics[(groupId, topicId)] = switch (stage) {
      TopicStage.lecture => t.copyWith(lectureDoneAt: t.lectureDoneAt ?? now),
      TopicStage.oral => t.copyWith(oralDoneAt: t.oralDoneAt ?? now),
    };
  }

  @override
  Future<String> startTopicTest({
    required String groupId,
    required String topicId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    int? timeLimitMinutes,
  }) async {
    await openTopic(groupId, topicId);
    final t = _topics[(groupId, topicId)]!;
    if (t.testAssignmentId != null) {
      throw const BackendException(BackendFailure.invalid, 'already started');
    }
    final id = await createAssignment(
      groupId: groupId,
      title: title,
      questionIds: questionIds,
      correctIndexes: correctIndexes,
      timeLimitMinutes: timeLimitMinutes,
      topicId: topicId,
    );
    _topics[(groupId, topicId)] = t.copyWith(testAssignmentId: id);
    return id;
  }

  @override
  Future<void> finishTopicTest(String groupId, String topicId) async {
    _requireOwner(groupId);
    final id = _topics[(groupId, topicId)]?.testAssignmentId;
    if (id == null) throw const BackendException(BackendFailure.notFound);
    final a = _assignments.firstWhere((a) => a.info.id == id);
    final now = groupClock().toUtc();
    final due = a.info.dueAt;
    if (due == null || due.isAfter(now)) {
      final i = a.info;
      a.info = GroupAssignment(
        id: i.id,
        groupId: i.groupId,
        title: i.title,
        questionIds: i.questionIds,
        dueAt: now,
        timeLimitMinutes: i.timeLimitMinutes,
        createdAt: i.createdAt,
        topicId: i.topicId,
      );
    }
  }

  // ----------------------------------------------------------- Hamkorlar
  // `supabase/migrations/20261009001000_partners.sql` qoidalari: hamma faqat
  // e'lon qilingan va bugun faol hamkorni ko'radi; yozish — admin (aal2);
  // hodisa: ≤ 20 bir chaqiruvda, hisobga kuniga ≤ 100, admin sanalmaydi.

  /// Hamkor faolligini tekshirish soati (testda sanani surish uchun).
  DateTime Function() partnerClock = DateTime.now;

  final List<Partner> _partners = [];
  final List<PartnerRequest> _partnerRequests = [];

  /// (hamkor, kun, joy) → [ko'rsatilish, bog'lanish].
  final Map<(String, DateTime, PartnerPlacement), List<int>> _partnerEvents =
      {};
  final Map<String, (DateTime, int)> _eventQuota = {};

  /// Server so'rovlari soni (kesh va tejamkorlikni tekshirish uchun).
  int partnerFeedCalls = 0;
  int partnerTrackCalls = 0;

  /// Server ishlamay qolganini taqlid qilish (internet yo'q).
  bool partnersOffline = false;

  /// Test uchun to'g'ridan-to'g'ri hamkor qo'yish (admin oqimisiz).
  void seedPartner(Partner p) => _partners.add(p);

  DateTime get _today => tashkentToday(partnerClock());

  ({int impressions, int contacts}) partnerTotals(String id) {
    var i = 0;
    var c = 0;
    for (final e in _partnerEvents.entries) {
      if (e.key.$1 != id) continue;
      i += e.value[0];
      c += e.value[1];
    }
    return (impressions: i, contacts: c);
  }

  @override
  Future<List<Partner>> partners() async {
    partnerFeedCalls++;
    if (partnersOffline) {
      throw const BackendException(BackendFailure.network);
    }
    return _partners.where((p) => p.isLiveOn(_today)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<int> trackPartnerEvents(List<PartnerEvent> events) async {
    final u = _current;
    if (u == null || events.isEmpty) return 0;
    var accepted = 0;
    for (var i = 0; i < events.length; i += 20) {
      final batch = events.skip(i).take(20).toList();
      partnerTrackCalls++;
      if (_isAdminAccount) continue;
      final today = _today;
      final q = _eventQuota[u.id];
      final used = (q != null && q.$1 == today ? q.$2 : 0) + batch.length;
      if (used > 100) throw const BackendException(BackendFailure.rateLimited);
      _eventQuota[u.id] = (today, used);
      for (final e in batch) {
        final live = _partners.any(
          (p) => p.id == e.partnerId && p.isLiveOn(today),
        );
        if (!live) continue;
        final row = _partnerEvents.putIfAbsent((
          e.partnerId,
          today,
          e.placement,
        ), () => [0, 0]);
        row[e.kind == PartnerEventKind.impression ? 0 : 1]++;
        accepted++;
      }
    }
    return accepted;
  }

  @override
  Future<String> createPartnerRequest(PartnerRequestDraft draft) async {
    final u = _require();
    if (!draft.isValid) throw const BackendException(BackendFailure.invalid);
    final dayAgo = _now().subtract(const Duration(days: 1));
    final recent = _partnerRequests.where(
      (r) => r.userId == u.id && r.createdAt.isAfter(dayAgo),
    );
    if (recent.length >= 3) {
      throw const BackendException(BackendFailure.rateLimited);
    }
    String? clean(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();
    final r = PartnerRequest(
      id: _id('preq'),
      userId: u.id,
      company: draft.company.trim(),
      contactName: draft.contactName.trim(),
      phone: clean(draft.phone),
      email: clean(draft.email)?.toLowerCase(),
      products: draft.products.trim(),
      message: draft.message.trim(),
      status: PartnerRequestStatus.newRequest,
      adminReply: null,
      createdAt: _now(),
      repliedAt: null,
    );
    _partnerRequests.add(r);
    return r.id;
  }

  @override
  Future<List<PartnerRequest>> myPartnerRequests() async {
    final u = _require();
    return _partnerRequests
        .where((r) => r.userId == u.id)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<Partner>> adminPartners() async {
    _requireAdmin();
    return _partners.reversed.toList();
  }

  void _validatePartner(PartnerDraft d) {
    bool bad(String? v, bool Function(String) ok) => v != null && !ok(v);
    final name = d.name.trim().length;
    if (name < 2 ||
        name > 120 ||
        d.summary.keys.any((k) => !const {'uz', 'ru', 'en'}.contains(k)) ||
        d.summary.values.any((v) => v.trim().length > 300) ||
        d.regions.any((r) => !uzRegionCodes.contains(r)) ||
        d.endsOn.isBefore(d.startsOn) ||
        bad(d.phone, isValidPartnerPhone) ||
        bad(d.telegram, isValidTelegram) ||
        bad(d.website, isValidHttpsUrl) ||
        bad(d.email, isValidPartnerEmail) ||
        bad(d.brochureUrl, isValidHttpsUrl) ||
        bad(d.logoUrl, isValidHttpsUrl) ||
        d.links.length > 200 ||
        d.links.any(
          (l) =>
              !isValidCatalogId(l.catalogId) ||
              (l.registrationNo != null &&
                  (l.target != PartnerLinkTarget.model ||
                      l.registrationNo!.trim().length < 3 ||
                      l.registrationNo!.trim().length > 60)),
        )) {
      throw const BackendException(BackendFailure.invalid);
    }
  }

  void _checkPublishable(Partner p) {
    if (p.summary.values.every((v) => v.trim().isEmpty) ||
        !p.hasContact ||
        p.links.isEmpty) {
      throw const BackendException(BackendFailure.invalid);
    }
  }

  @override
  Future<String> adminSavePartner(PartnerDraft draft, {String? id}) async {
    _requireAdmin();
    _validatePartner(draft);
    final index = id == null ? -1 : _partners.indexWhere((p) => p.id == id);
    if (id != null && index < 0) {
      throw const BackendException(BackendFailure.notFound);
    }
    final p = Partner(
      id: id ?? _id('partner'),
      name: draft.name.trim(),
      kind: draft.kind,
      logoUrl: draft.logoUrl,
      summary: {
        for (final e in draft.summary.entries)
          if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
      },
      regions: draft.regions.toSet().toList(),
      phone: draft.phone,
      telegram: draft.telegram,
      website: draft.website,
      email: draft.email,
      brochureUrl: draft.brochureUrl,
      startsOn: draft.startsOn,
      endsOn: draft.endsOn,
      status: index < 0 ? PartnerStatus.draft : _partners[index].status,
      links: draft.links,
    );
    if (p.status == PartnerStatus.published) _checkPublishable(p);
    if (index < 0) {
      _partners.add(p);
    } else {
      _partners
        ..removeAt(index)
        ..add(p);
    }
    audit.add(
      AuditEntry(
        at: _now(),
        action: index < 0 ? 'partner_created' : 'partner_updated',
        target: p.id,
        details: {'name': p.name, 'links': p.links.length},
      ),
    );
    return p.id;
  }

  @override
  Future<void> adminSetPartnerStatus(String id, PartnerStatus status) async {
    _requireAdmin();
    final index = _partners.indexWhere((p) => p.id == id);
    if (index < 0) throw const BackendException(BackendFailure.notFound);
    final old = _partners[index];
    if (status == PartnerStatus.published) _checkPublishable(old);
    _partners[index] = Partner.fromJson({
      ...old.toJson(),
      'status': status.name,
    });
    audit.add(
      AuditEntry(
        at: _now(),
        action: switch (status) {
          PartnerStatus.published => 'partner_published',
          PartnerStatus.paused => 'partner_paused',
          PartnerStatus.draft => 'partner_draft',
        },
        target: id,
        details: {'from': old.status.name, 'to': status.name},
      ),
    );
  }

  @override
  Future<String> adminUploadPartnerLogo(
    Uint8List bytes,
    String mimeType,
  ) async {
    _requireAdmin();
    if (bytes.length > 1024 * 1024 ||
        !SupportAttachment.allowedTypes.contains(mimeType)) {
      throw const BackendException(BackendFailure.invalid);
    }
    return 'https://example.supabase.co/storage/v1/object/public/'
        'partner-logos/${_id('logo')}.png';
  }

  @override
  Future<List<PartnerDayStat>> adminPartnerStats(String id) async {
    _requireAdmin();
    return [
      for (final e in _partnerEvents.entries)
        if (e.key.$1 == id)
          PartnerDayStat(
            day: e.key.$2,
            placement: e.key.$3,
            impressions: e.value[0],
            contacts: e.value[1],
          ),
    ]..sort((a, b) => b.day.compareTo(a.day));
  }

  @override
  Future<List<PartnerRequest>> adminPartnerRequests({
    PartnerRequestStatus? status,
  }) async {
    _requireAdmin();
    return _partnerRequests
        .where((r) => status == null || r.status == status)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> adminUpdatePartnerRequest(
    String id, {
    required PartnerRequestStatus status,
    String? reply,
  }) async {
    _requireAdmin();
    final index = _partnerRequests.indexWhere((r) => r.id == id);
    if (index < 0) throw const BackendException(BackendFailure.notFound);
    final old = _partnerRequests[index];
    final text = reply?.trim();
    final hasReply = text != null && text.isNotEmpty;
    _partnerRequests[index] = PartnerRequest(
      id: old.id,
      userId: old.userId,
      company: old.company,
      contactName: old.contactName,
      phone: old.phone,
      email: old.email,
      products: old.products,
      message: old.message,
      status: status,
      adminReply: hasReply ? text : old.adminReply,
      createdAt: old.createdAt,
      repliedAt: hasReply ? _now() : old.repliedAt,
    );
    audit.add(
      AuditEntry(
        at: _now(),
        action: 'partner_request',
        target: id,
        details: {'from': old.status.wire, 'to': status.wire},
      ),
    );
  }
}

class _Group {
  _Group(this.id, this.ownerId, this.name, this.code);
  final String id;
  final String ownerId;
  final String name;
  final String code;

  /// Keyingi talabaning tartib raqami (qayta ishlatilmaydi).
  int nextSeat = 1;
}

class _Member {
  _Member(
    this.groupId,
    this.userId,
    this.alias, {
    required this.teacher,
    required this.joinedAt,
    this.seatNo,
  });
  final String groupId;
  final String userId;
  String? alias;
  final bool teacher;
  final DateTime joinedAt;
  final int? seatNo;
}

class _Assignment {
  _Assignment(this.info, this.key);
  GroupAssignment info;
  final List<int> key;
}
