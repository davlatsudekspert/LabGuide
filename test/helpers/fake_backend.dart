import 'dart:async';
import 'dart:typed_data';

import 'package:labguide/core/backend/admin_console.dart';
import 'package:labguide/core/backend/admin_team.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/lab_backend.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/core/backend/pro_grants.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/auth/otp_auth.dart';
import 'package:labguide/features/classroom/invite_link.dart'
    show nicknameAllowed, normalizeNickname;

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

  /// Variantli test (D-66) qo'llanadimi — widget testlari o'chirib ko'radi.
  bool variantTests = true;
  @override
  bool get supportsVariantTests => variantTests;
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

  /// Faqat test: boshqa qurilmadagi foydalanuvchi nomidan amal (ilovadagi
  /// joriy sessiya o'zgarmaydi) — masalan, ustoz sahifasi ochiq turganda
  /// talaba topshiradi.
  Future<T> actAs<T>(String email, Future<T> Function() body) async {
    final key = normalizeEmail(email);
    final prev = _current;
    _current = _users.putIfAbsent(key, () => _User(_id('user'), key));
    try {
      return await body();
    } finally {
      _current = prev;
    }
  }

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
      _current != null &&
      (adminEmails.contains(_current!.email) ||
          _grants.containsKey(_current!.email));
  bool get _isSuperAdmin =>
      _current != null && adminEmails.contains(_current!.email);

  /// Super admin qo'shgan adminlar (D-44; faqat [FakeAdminTeamBackend]).
  final Map<String, ({String id, DateTime at})> _grants = {};
  bool get _isAdmin =>
      (_isAdminAccount && _aal2) || (allowsPanelAdmin && _isSuperAdmin);

  /// Egasi admin paneli (Cloudflare): ADMIN_EMAILS + email kodi, TOTP siz.
  bool get allowsPanelAdmin => false;
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
          superAdmin: _isSuperAdmin,
          panelAdmin: allowsPanelAdmin && _isSuperAdmin,
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
    // Worker kabi: apostroflar (iPhone ’) normallashtiriladi, belgilar
    // `NICK_RE` bo'yicha tekshiriladi (`400 invalid_nickname`).
    final a = normalizeNickname(alias ?? '');
    if (a.isEmpty) return null;
    _checkLength(a, 2, 24); // ilova maydoni va Worker: 2–24
    if (!nicknameAllowed(a)) {
      throw const BackendException(
        BackendFailure.invalid,
        'invalid nickname',
        'invalid_nickname',
      );
    }
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
            myNickname: m.alias,
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
        .where(
          (g) => g.code == code.toUpperCase().replaceAll(RegExp(r'[\s-]'), ''),
        )
        .firstOrNull;
    if (g == null) throw const BackendException(BackendFailure.notFound);
    if (_isMember(g.id)) return g.id; // SQL: qayta qo'shilish o'zgartirmaydi
    final shown = _aliasOf(displayName);
    if (_members.where((m) => m.groupId == g.id).length >= 200) {
      throw const BackendException(
        BackendFailure.rateLimited,
        'group full',
        'group_full',
      );
    }
    // Server kabi: taxallus guruhda yagona (katta-kichik harf farqsiz).
    if (shown != null &&
        _members.any(
          (m) =>
              m.groupId == g.id &&
              m.alias?.toLowerCase() == shown.toLowerCase(),
        )) {
      throw const BackendException(
        BackendFailure.invalid,
        'nickname taken',
        'nickname_taken',
      );
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
  Future<void> deleteGroup(String groupId) async {
    _require();
    if (!_isTeacher(groupId)) {
      throw const BackendException(BackendFailure.forbidden);
    }
    final ids = {
      for (final a in _assignments)
        if (a.info.groupId == groupId) a.info.id,
    };
    _submissions.removeWhere((s) => ids.contains(s.assignmentId));
    _attempts.removeWhere((k, _) => ids.contains(k.$1));
    _assignments.removeWhere((a) => a.info.groupId == groupId);
    _members.removeWhere((m) => m.groupId == groupId);
    _groups.removeWhere((g) => g.id == groupId);
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
    String? dayId,
    String? deckId,
    bool revealAfterDue = false,
    int? perStudent,
    List<String?>? poolTopics,
  }) async {
    _require();
    if (!_isTeacher(groupId)) {
      throw const BackendException(BackendFailure.forbidden);
    }
    _checkLength(title, 3, 120);
    // 0010: “muddat tugagach” — muddat bo'lishi shart; deck id — mavzu id
    // qoidasi bilan bir xil.
    if ((revealAfterDue && dueAt == null) ||
        (deckId != null && !_topicId.hasMatch(deckId))) {
      throw const BackendException(BackendFailure.invalid);
    }
    // D-66: variantli testda hovuz ≤ 100, takrorsiz, kamida 2 × perStudent.
    if (perStudent != null &&
        (perStudent < 1 ||
            perStudent > 50 ||
            questionIds.toSet().length != questionIds.length ||
            questionIds.length < perStudent * 2 ||
            (poolTopics != null && poolTopics.length != questionIds.length))) {
      throw const BackendException(BackendFailure.invalid, 'per_student');
    }
    if (questionIds.isEmpty ||
        questionIds.length > (perStudent == null ? 50 : 100) ||
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
      topicId: topicId ?? dayId,
      deckId: deckId,
      revealAfterDue: revealAfterDue,
      perStudent: perStudent,
      poolTopics: perStudent == null || poolTopics == null
          ? null
          : List.unmodifiable(poolTopics),
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
    // Server kabi: yakunlangan testni yangidan boshlab bo'lmaydi.
    if (!_attempts.containsKey(key) && a.closedAt != null) {
      throw const BackendException(BackendFailure.invalid, 'not open');
    }
    final started = _attempts.putIfAbsent(key, () => now);
    return AssignmentStart(
      startedAt: started,
      serverNow: now,
      questionIds: a.info.isVariant
          ? a.info.questionIdsFor(_current!.id)
          : null,
    );
  }

  @override
  Future<List<AssignmentAttempt>> assignmentProgress(
    String assignmentId,
  ) async {
    _require();
    final a = _assignments.where((a) => a.info.id == assignmentId).firstOrNull;
    if (a == null || !_owns(a.info.groupId)) return const [];
    return [
      for (final e in _attempts.entries)
        if (e.key.$1 == assignmentId)
          AssignmentAttempt(userId: e.key.$2, startedAt: e.value),
    ];
  }

  @override
  Future<void> closeAssignment(String assignmentId) async {
    _require();
    final a = _assignments.where((a) => a.info.id == assignmentId).firstOrNull;
    if (a == null || !_owns(a.info.groupId)) {
      throw const BackendException(BackendFailure.forbidden);
    }
    if (a.closedAt != null) return;
    a.closedAt = groupClock();
    final i = a.info;
    a.info = GroupAssignment(
      id: i.id,
      groupId: i.groupId,
      title: i.title,
      questionIds: i.questionIds,
      dueAt: i.dueAt,
      timeLimitMinutes: i.timeLimitMinutes,
      createdAt: i.createdAt,
      topicId: i.topicId,
      deckId: i.deckId,
      revealAfterDue: i.revealAfterDue,
      perStudent: i.perStudent,
      poolTopics: i.poolTopics,
      closed: true,
    );
  }

  @override
  Future<GroupSubmission> submitAssignment(
    String assignmentId,
    List<int> answers, {
    List<String>? questionIds,
  }) async {
    final a = _forStudent(assignmentId);
    final u = _current!;
    final now = groupClock();
    final started = _attempts[(assignmentId, u.id)];
    // Yakunlangan: faqat yakunlanishdan oldin boshlaganlarga 2 daqiqa.
    final closedAt = a.closedAt;
    if (closedAt != null &&
        (started == null ||
            started.isAfter(closedAt) ||
            now.isAfter(closedAt.add(submitGrace)))) {
      throw const BackendException(BackendFailure.invalid, 'closed');
    }
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
    // Server kabi: variantli testda kalit — talabaga tushgan savollarniki;
    // javoblar aynan shu to'plamga (istalgan tartibda) bo'lishi shart.
    final info = a.info;
    final mine = info.questionIdsFor(u.id);
    final key = info.isVariant
        ? [for (final q in mine) a.key[info.questionIds.indexOf(q)]]
        : a.key;
    if (answers.length != key.length) {
      throw const BackendException(BackendFailure.invalid);
    }
    var ordered = answers;
    if (info.isVariant) {
      final ids = questionIds;
      if (ids == null ||
          ids.length != mine.length ||
          ids.toSet().length != ids.length ||
          !ids.every(mine.contains)) {
        throw const BackendException(BackendFailure.invalid, 'questions');
      }
      ordered = [for (final q in mine) answers[ids.indexOf(q)]];
    }
    if (_submissions.any(
      (s) => s.assignmentId == assignmentId && s.userId == u.id,
    )) {
      throw const BackendException(BackendFailure.invalid, 'already');
    }
    final correct = [for (var i = 0; i < key.length; i++) ordered[i] == key[i]];
    final s = GroupSubmission(
      assignmentId: assignmentId,
      userId: u.id,
      score: correct.where((c) => c).length,
      total: key.length,
      submittedAt: now.toUtc(),
      answers: List.unmodifiable(ordered),
      correct: List.unmodifiable(correct),
      questionIds: info.isVariant ? List.unmodifiable(mine) : null,
    );
    _submissions.add(s);
    return _forViewer(s);
  }

  /// Server kabi: “muddat tugagach” topshirig'ida talabaga har savol
  /// natijasi (`correct`) muddatgacha berilmaydi.
  GroupSubmission _forViewer(GroupSubmission s) {
    final a = _assignments.firstWhere((a) => a.info.id == s.assignmentId);
    if (_isTeacher(a.info.groupId) || a.info.answersOpen(groupClock())) {
      return s;
    }
    return GroupSubmission(
      assignmentId: s.assignmentId,
      userId: s.userId,
      score: s.score,
      total: s.total,
      submittedAt: s.submittedAt,
      answers: s.answers,
      questionIds: s.questionIds,
    );
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
        if (s.assignmentId == assignmentId && _canSee(s)) _forViewer(s),
    ];
  }

  @override
  Future<List<GroupSubmission>> groupSubmissions(String groupId) async {
    final ids = {for (final a in await assignments(groupId)) a.id};
    return [
      for (final s in _submissions)
        if (ids.contains(s.assignmentId) && _canSee(s)) _forViewer(s),
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
        deckId: i.deckId,
        revealAfterDue: i.revealAfterDue,
        perStudent: i.perStudent,
        poolTopics: i.poolTopics,
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

  /// Bitta joy bo'yicha ko'rsatilishlar yig'indisi.
  int partnerImpressionsAt(String id, PartnerPlacement placement) => [
    for (final e in _partnerEvents.entries)
      if (e.key.$1 == id && e.key.$3 == placement) e.value[0],
  ].fold(0, (a, b) => a + b);

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

  /// Ustoz yakunlagan vaqt ([FakeLabBackend.closeAssignment]).
  DateTime? closedAt;
}

/// Cloudflare serveriga o'xshash soxta server: adminlar boshqaruvi (D-44)
/// bor; Supabase'dan hali ko'chirilmagan admin bo'limlari (statistika,
/// murojaatlar, foydalanuvchilar, jurnal, hamkorlar, tekshiruv) —
/// `unavailable` ([legacyAdminApi] `true` bo'lsa — ishlaydi).
///
/// Qoidalar serverdagidek: faqat super admin (+aal2) qo'shadi/oladi; email
/// faqat niqoblangan holda qaytadi; olib tashlangan admin darhol vakolatini
/// yo'qotadi.
class FakeAdminTeamBackend extends FakeLabBackend
    implements AdminTeamBackend, ProGrantBackend {
  FakeAdminTeamBackend({super.adminEmails, this.legacyAdminApi = false});

  final bool legacyAdminApi;
  static const maxGranted = 20;

  /// Ilova qaysi emaillarni yuborganini tekshirish uchun (faqat test).
  final List<String> addCalls = [];

  static String mask(String email) {
    final i = email.indexOf('@');
    final local = email.substring(0, i);
    return '${local.substring(0, local.length < 2 ? local.length : 2)}***${email.substring(i)}';
  }

  Never _notYet() => throw const BackendException(
    BackendFailure.unavailable,
    'not ported to cloudflare yet',
  );

  void _requireSuper() {
    _requireAdmin();
    if (!_isSuperAdmin) {
      throw const AdminTeamException(
        BackendFailure.forbidden,
        'not_super_admin',
      );
    }
  }

  @override
  Future<AdminTeam> adminTeam() async {
    _requireAdmin();
    final me = _current!.email;
    return AdminTeam(
      canManage: _isSuperAdmin,
      maxGranted: maxGranted,
      admins: [
        for (final e in adminEmails)
          AdminEntry(
            id: null,
            emailMasked: mask(e),
            kind: AdminKind.superAdmin,
            active: _users.containsKey(e),
            you: e == me,
          ),
        for (final g
            in _grants.entries.toList()
              ..sort((a, b) => b.value.at.compareTo(a.value.at)))
          AdminEntry(
            id: g.value.id,
            emailMasked: mask(g.key),
            kind: AdminKind.granted,
            active: _users.containsKey(g.key),
            you: g.key == me,
            createdAt: g.value.at,
          ),
      ],
    );
  }

  @override
  Future<AdminEntry> addAdmin(String email) async {
    _requireSuper();
    addCalls.add(email);
    if (!isValidEmail(email)) {
      throw const AdminTeamException(BackendFailure.invalid, 'invalid_email');
    }
    final e = normalizeEmail(email);
    if (adminEmails.contains(e)) {
      throw const AdminTeamException(
        BackendFailure.invalid,
        'already_super_admin',
      );
    }
    if (_grants.containsKey(e)) {
      throw const AdminTeamException(BackendFailure.invalid, 'already_admin');
    }
    if (_grants.length >= maxGranted) {
      throw const AdminTeamException(BackendFailure.invalid, 'too_many_admins');
    }
    final g = (id: _id('grant'), at: _now());
    _grants[e] = g;
    audit.add(
      AuditEntry(
        action: 'admin_grant_added',
        at: g.at,
        target: g.id,
        details: const {},
      ),
    );
    return AdminEntry(
      id: g.id,
      emailMasked: mask(e),
      kind: AdminKind.granted,
      active: _users.containsKey(e),
      you: false,
      createdAt: g.at,
    );
  }

  @override
  Future<void> removeAdmin(String id) async {
    _requireSuper();
    final key = _grants.entries
        .where((g) => g.value.id == id)
        .map((g) => g.key)
        .firstOrNull;
    if (key == null) throw const BackendException(BackendFailure.notFound);
    _grants.remove(key);
    if (_current?.email == key) _aal2 = false;
    audit.add(
      AuditEntry(
        action: 'admin_grant_removed',
        at: _now(),
        target: id,
        details: const {},
      ),
    );
  }

  // ------------------------------------------- admin Pro berish (D-73)
  /// Serverdagi `pro_grants` o'rnida: email → qator. Qoidalar serverdagidek:
  /// admin roli + TOTP (aal2) shart, email normallashtiriladi, hisob bo'lmasa
  /// kutilmoqda, qayta berish almashtiradi yoki uzaytiradi, ro'yxatda faqat
  /// faol va kutilayotganlar.
  final Map<String, _FakeProGrant> _proGrants = {};

  /// Ilova yuborgan so'rovlar (faqat test).
  final List<Map<String, Object?>> grantCalls = [];

  void _requireProAdmin() {
    if (!(_isAdminAccount && _aal2)) {
      throw const ProGrantException(BackendFailure.forbidden, 'forbidden');
    }
  }

  ProGrant _view(String email, _FakeProGrant g) => ProGrant(
    id: g.id,
    emailMasked: FakeAdminTeamBackend.mask(email),
    plan: g.plan,
    status: g.startsAt == null ? ProGrantStatus.pending : ProGrantStatus.active,
    durationDays: g.days,
    startsAt: g.startsAt,
    expiresAt: g.expiresAt,
    note: g.note,
    createdAt: g.createdAt,
  );

  @override
  Future<List<ProGrant>> proGrants() async {
    _requireProAdmin();
    return [
      for (final e in _proGrants.entries) _view(e.key, e.value),
    ];
  }

  @override
  Future<ProGrantResult> grantPro({
    required String email,
    required ProPlan plan,
    int? durationDays,
    String? note,
    bool extend = false,
  }) async {
    _requireProAdmin();
    grantCalls.add({
      'email': email,
      'plan': plan,
      'days': durationDays,
      'note': note,
      'extend': extend,
    });
    if (!isValidEmail(email)) {
      throw const ProGrantException(BackendFailure.invalid, 'invalid_email');
    }
    if (!proGrantDurations.contains(durationDays)) {
      throw const ProGrantException(BackendFailure.invalid, 'invalid_duration');
    }
    final n = (note ?? '').trim();
    if (n.length > proGrantNoteMax) {
      throw const ProGrantException(BackendFailure.invalid, 'invalid_note');
    }
    final e = normalizeEmail(email);
    final now = _now();
    final account = _users.containsKey(e);
    final cur = _proGrants[e];
    DateTime? until(DateTime from) =>
        durationDays == null ? null : from.add(Duration(days: durationDays));
    if (cur == null) {
      final g = _FakeProGrant(
        id: _id('pg'),
        plan: plan,
        days: durationDays,
        note: n.isEmpty ? null : n,
        createdAt: now,
        startsAt: account ? now : null,
        expiresAt: account ? until(now) : null,
      );
      _proGrants[e] = g;
      return ProGrantResult(grant: _view(e, g));
    }
    if (extend) {
      if (cur.startsAt == null) {
        throw const ProGrantException(
          BackendFailure.invalid,
          'pending_cannot_extend',
        );
      }
      if (durationDays == null) {
        throw const ProGrantException(
          BackendFailure.invalid,
          'duration_required',
        );
      }
      final base = cur.expiresAt;
      if (base != null) {
        cur.expiresAt = (base.isAfter(now) ? base : now).add(
          Duration(days: durationDays),
        );
      }
      if (plan.index > cur.plan.index) cur.plan = plan;
      return ProGrantResult(grant: _view(e, cur), extended: true);
    }
    cur
      ..plan = plan
      ..days = durationDays
      ..note = n.isEmpty ? null : n
      ..startsAt = account ? now : null
      ..expiresAt = account ? until(now) : null;
    return ProGrantResult(grant: _view(e, cur), replaced: true);
  }

  @override
  Future<void> revokePro(String id) async {
    _requireProAdmin();
    final key = _proGrants.entries
        .where((g) => g.value.id == id)
        .map((g) => g.key)
        .firstOrNull;
    if (key == null) throw const BackendException(BackendFailure.notFound);
    _proGrants.remove(key);
  }

  /// Boshqa qurilmadagi super admin olib tashladi (test: mavjud sessiya).
  void revokeGrantFor(String email) {
    final e = normalizeEmail(email);
    _grants.remove(e);
    // Server sessiyalarni aal1 ga tushiradi.
    if (_current?.email == e) _aal2 = false;
  }

  @override
  Future<AdminStats> adminStats() async =>
      legacyAdminApi ? super.adminStats() : _notYet();
  @override
  Future<List<SupportThread>> adminThreads({SupportStatus? status}) async =>
      legacyAdminApi ? super.adminThreads(status: status) : _notYet();
  @override
  Future<AdminUserPage> adminUsers({
    String? query,
    String? role,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async => legacyAdminApi
      ? super.adminUsers(
          query: query,
          role: role,
          language: language,
          limit: limit,
          offset: offset,
        )
      : _notYet();
  @override
  Future<List<AuditEntry>> adminAudit({int limit = 50}) async =>
      legacyAdminApi ? super.adminAudit(limit: limit) : _notYet();
  @override
  Future<List<ContentReview>> contentReviews() async =>
      legacyAdminApi ? super.contentReviews() : _notYet();
  @override
  Future<List<SupportThread>> myThreads() async =>
      legacyAdminApi ? super.myThreads() : _notYet();
}

/// Cloudflare egasi admin paneli soxtasi: ADMIN_EMAILS dagi email kod bilan
/// kirsa — TOTP siz admin ([allowsPanelAdmin]); foydalanuvchilar (rol,
/// to'xtatish), ilova shikoyatlari, hamjamiyat shikoyatlari, jurnal.
/// Qoidalar serverdagidek: oddiy foydalanuvchi — `forbidden`, admin
/// to'xtatilmaydi, o'z rolini o'zgartira olmaydi, to'xtatilgan hisob kira
/// olmaydi, shikoyat — soatiga 5 ta (mehmon ham).
class FakeAdminConsoleBackend extends FakeAdminTeamBackend
    implements AdminConsoleBackend, ComplaintsBackend, SupportAttachmentPolicy {
  FakeAdminConsoleBackend({super.adminEmails}) : super(legacyAdminApi: true);

  @override
  bool get allowsPanelAdmin => true;
  @override
  bool get supportAttachments => false;

  final Set<String> _suspendedEmails = {};
  final Map<String, String> nicknames = {};
  final Map<String, String> communityStatus = {};
  final List<Complaint> complaints = [];
  final List<ReportItem> reports = [];
  final Map<String, int> _complaintHits = {};

  /// Keyingi admin o'qishi shu xato bilan tugaydi (xato holatini sinash).
  BackendException? failNext;

  /// Berilsa — admin o'qishlari shu tugaguncha kutadi (yuklanish holati).
  Completer<void>? hold;

  Future<void> _gate() async {
    final h = hold;
    if (h != null) await h.future;
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  void _panel() {
    if (!_isAdmin) {
      throw const AdminConsoleException(BackendFailure.forbidden, 'forbidden');
    }
  }

  _User _byId(String id) => _users.values.firstWhere(
    (u) => u.id == id,
    orElse: () =>
        throw const AdminConsoleException(BackendFailure.notFound, 'not_found'),
  );

  void _log(String action, String? target, [Map<String, Object?>? d]) =>
      audit.add(
        AuditEntry(
          at: _now(),
          action: action,
          target: target,
          details: d ?? const {},
          actorMasked: _current == null
              ? null
              : FakeAdminTeamBackend.mask(_current!.email),
        ),
      );

  @override
  Future<OtpVerifyResult> verifyCode(String email, String code) async {
    if (_suspendedEmails.contains(normalizeEmail(email))) {
      return const OtpVerifyResult(OtpVerifyStatus.accountSuspended);
    }
    return super.verifyCode(email, code);
  }

  @override
  Future<AdminStats> adminStats() async {
    await _gate();
    _panel();
    final base = (await super.adminStats()).json;
    final today = DateTime.utc(2026, 10, 17);
    return AdminStats({
      ...base,
      'billing': null,
      'online_now': _current == null ? 0 : 1,
      'suspended_accounts': _suspendedEmails.length,
      'new_by_day': [
        for (var i = 13; i >= 0; i--)
          {
            'day': today
                .subtract(Duration(days: i))
                .toIso8601String()
                .substring(0, 10),
            'n': i == 0 ? _users.length : (i % 3),
          },
      ],
      'groups': {
        'groups': 2,
        'teachers': 1,
        'students': 7,
        'assignments': 3,
        'results': 12,
      },
      'complaints': {
        'open': complaints
            .where((c) => c.status == ComplaintStatus.open)
            .length,
        'resolved': complaints
            .where((c) => c.status == ComplaintStatus.resolved)
            .length,
      },
      'community': {
        'questions': 4,
        'answers': 6,
        'verified': 1,
        'suspended': communityStatus.values
            .where((s) => s == 'suspended')
            .length,
        'reports_open': reports
            .where((r) => r.status == ReportStatus.open)
            .length,
      },
    });
  }

  AdminAccountRow _row(_User u) => AdminAccountRow(
    userId: u.id,
    emailMasked: FakeAdminTeamBackend.mask(u.email),
    role: u.role ?? 'student',
    language: u.language ?? 'uz',
    registeredOn: DateTime.utc(2026, 10, 9),
    lastSeenOn: DateTime.utc(2026, 10, 16),
    status: _suspendedEmails.contains(u.email)
        ? AccountStatus.suspended
        : AccountStatus.active,
    admin: adminEmails.contains(u.email),
  );

  @override
  Future<AdminAccountPage> adminAccounts({
    String? email,
    String? name,
    String? role,
    AccountStatus? status,
    int limit = 20,
    int offset = 0,
  }) async {
    await _gate();
    _panel();
    if (email != null && !isValidEmail(email)) {
      throw const AdminConsoleException(
        BackendFailure.invalid,
        'invalid_email',
      );
    }
    if (name != null && (name.length < 2 || name.length > 40)) {
      throw const AdminConsoleException(BackendFailure.invalid, 'invalid_name');
    }
    final rows = [
      for (final u in _users.values)
        if ((email == null || u.email == normalizeEmail(email)) &&
            // Taxallus: `%`/`_` oddiy belgi (serverdagi LIKE ekranlash kabi).
            (name == null ||
                (nicknames[u.id]?.toLowerCase().contains(name.toLowerCase()) ??
                    false)) &&
            (role == null || (u.role ?? 'student') == role))
          _row(u),
    ].where((r) => status == null || r.status == status).toList();
    return AdminAccountPage(
      rows.skip(offset).take(limit).toList(),
      rows.length,
    );
  }

  @override
  Future<AdminUserDetail> adminUserDetail(String userId) async {
    await _gate();
    _panel();
    final u = _byId(userId);
    return AdminUserDetail(
      account: _row(u),
      you: u.id == _current?.id,
      teacher: u.teacher,
      groupsOwned: 0,
      groupsJoined: nicknames.containsKey(u.id) ? 1 : 0,
      supportThreads: _threads.where((t) => t.userId == u.id).length,
      complaints: complaints.where((c) => c.userId == u.id).length,
      communityStatus: communityStatus[u.id] ?? 'none',
      communityOwner: false,
      reporters: 0,
      questions: 0,
      answers: 0,
    );
  }

  @override
  Future<void> adminSetRole(String userId, String role) async {
    _panel();
    final u = _byId(userId);
    if (u.id == _current!.id) {
      throw const AdminConsoleException(BackendFailure.forbidden, 'self');
    }
    final from = u.role;
    u.role = role;
    _log('role_changed', u.id, {'from': from, 'to': role});
  }

  @override
  Future<void> adminSuspendAccount(String userId) async {
    _panel();
    final u = _byId(userId);
    if (u.id == _current!.id) {
      throw const AdminConsoleException(BackendFailure.forbidden, 'self');
    }
    if (adminEmails.contains(u.email)) {
      throw const AdminConsoleException(BackendFailure.forbidden, 'admin');
    }
    if (_suspendedEmails.add(u.email)) _log('account_suspended', u.id);
  }

  @override
  Future<void> adminReactivateAccount(String userId) async {
    _panel();
    final u = _byId(userId);
    if (_suspendedEmails.remove(u.email)) _log('account_reactivated', u.id);
  }

  @override
  Future<void> adminDeleteAccount({
    required String email,
    required String confirmUserId,
  }) async {
    _panel();
    if (!isValidEmail(email)) {
      throw const AdminConsoleException(
        BackendFailure.invalid,
        'invalid_email',
      );
    }
    final u = _users[normalizeEmail(email)];
    if (u == null) {
      throw const AdminConsoleException(BackendFailure.notFound, 'not_found');
    }
    if (u.id != confirmUserId) {
      throw const AdminConsoleException(
        BackendFailure.invalid,
        'confirmation_mismatch',
      );
    }
    if (u.id == _current!.id) {
      throw const AdminConsoleException(BackendFailure.forbidden, 'self');
    }
    if (adminEmails.contains(u.email)) {
      throw const AdminConsoleException(BackendFailure.forbidden, 'admin');
    }
    _users.remove(u.email);
    _threads.removeWhere((t) => t.userId == u.id);
    deletedByAdmin.add(u.id);
    _log('account_deleted_by_admin', u.id, {'via': 'admin_console'});
  }

  /// Admin panelidan o'chirilgan hisoblar (testlar tekshiradi).
  final List<String> deletedByAdmin = [];

  @override
  Future<void> adminSuspendCommunity(String userId) async {
    _panel();
    communityStatus[_byId(userId).id] = 'suspended';
    _log('community_suspended', userId);
  }

  @override
  Future<void> adminRestoreCommunity(String userId) async {
    _panel();
    communityStatus[_byId(userId).id] = 'none';
    _log('community_restored', userId);
  }

  @override
  Future<void> submitComplaint({
    required ComplaintKind kind,
    required String body,
    String? targetRef,
    String? lang,
  }) async {
    if (body.trim().length < 5 || body.length > 2000) {
      throw const ComplaintException(BackendFailure.invalid);
    }
    final key = _current?.id ?? 'guest';
    final n = (_complaintHits[key] ?? 0) + 1;
    _complaintHits[key] = n;
    if (n > 5) {
      throw const ComplaintException(
        BackendFailure.rateLimited,
        retryAfter: Duration(minutes: 30),
      );
    }
    complaints.insert(
      0,
      Complaint(
        id: _id('complaint'),
        kind: kind,
        body: body.trim(),
        status: ComplaintStatus.open,
        createdAt: _now(),
        targetRef: targetRef,
        anonymous: _current == null,
        userId: _current?.id,
        emailMasked: _current == null
            ? null
            : FakeAdminTeamBackend.mask(_current!.email),
      ),
    );
  }

  Complaint _complaint(String id) => complaints.firstWhere(
    (c) => c.id == id,
    orElse: () =>
        throw const AdminConsoleException(BackendFailure.notFound, 'not_found'),
  );

  Complaint _replaceComplaint(
    Complaint c, {
    String? note,
    ComplaintStatus? status,
  }) {
    final s = status ?? c.status;
    final n = Complaint(
      id: c.id,
      kind: c.kind,
      body: c.body,
      status: s,
      createdAt: c.createdAt,
      targetRef: c.targetRef,
      adminNote: note ?? c.adminNote,
      anonymous: c.anonymous,
      userId: c.userId,
      emailMasked: c.emailMasked,
      resolvedAt: s == ComplaintStatus.resolved ? _now() : null,
    );
    complaints[complaints.indexWhere((x) => x.id == c.id)] = n;
    return n;
  }

  @override
  Future<List<Complaint>> adminComplaints({
    ComplaintStatus? status,
    ComplaintKind? kind,
  }) async {
    await _gate();
    _panel();
    return complaints
        .where(
          (c) =>
              (status == null || c.status == status) &&
              (kind == null || c.kind == kind),
        )
        .toList();
  }

  @override
  Future<Complaint> adminComplaint(String id) async {
    await _gate();
    _panel();
    return _complaint(id);
  }

  @override
  Future<Complaint> adminComplaintNote(String id, String note) async {
    _panel();
    final c = _replaceComplaint(_complaint(id), note: note.trim());
    _log('complaint_note', id);
    return c;
  }

  @override
  Future<Complaint> adminSetComplaintStatus(
    String id,
    ComplaintStatus status,
  ) async {
    _panel();
    final c = _replaceComplaint(_complaint(id), status: status);
    _log(
      status == ComplaintStatus.resolved
          ? 'complaint_resolved'
          : 'complaint_reopened',
      id,
    );
    return c;
  }

  @override
  Future<List<ReportItem>> adminReports({
    ReportStatus status = ReportStatus.open,
  }) async {
    await _gate();
    _panel();
    return reports.where((r) => r.status == status).toList();
  }

  void _setReport(ReportItem r, ReportStatus status, {String? author}) {
    reports[reports.indexWhere((x) => x.id == r.id)] = ReportItem(
      kind: r.kind,
      id: r.id,
      status: status,
      reports: r.reports,
      reporters: r.reporters,
      reasons: r.reasons,
      excerpt: r.excerpt,
      questionId: r.questionId,
      postDeleted: r.postDeleted,
      authorStatus: author ?? r.authorStatus,
      lastAt: r.lastAt,
    );
  }

  @override
  Future<void> dismissReport(ReportItem item) async {
    _panel();
    _setReport(item, ReportStatus.dismissed);
    _log('report_dismissed', '${item.kind}:${item.id}');
  }

  @override
  Future<void> resolveReport(ReportItem item) async {
    _panel();
    _setReport(item, ReportStatus.resolved);
    _log('report_resolved', '${item.kind}:${item.id}');
  }

  @override
  Future<void> suspendReportAuthor(ReportItem item) async {
    _panel();
    _setReport(item, ReportStatus.resolved, author: 'suspended');
    _log('community_suspended', '${item.kind}:${item.id}');
  }

  @override
  Future<List<AuditEntry>> adminAudit({int limit = 50}) async {
    await _gate();
    _panel();
    return audit.reversed.take(limit).toList();
  }
}

class _FakeProGrant {
  _FakeProGrant({
    required this.id,
    required this.plan,
    required this.createdAt,
    this.days,
    this.note,
    this.startsAt,
    this.expiresAt,
  });

  final String id;
  ProPlan plan;
  int? days;
  String? note;
  final DateTime createdAt;
  DateTime? startsAt;
  DateTime? expiresAt;
}
