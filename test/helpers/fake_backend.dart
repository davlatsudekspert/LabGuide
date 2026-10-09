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

  // Guruhlar — UI testlari uchun minimal.
  final List<StudyGroup> _groups = [];

  @override
  Future<List<StudyGroup>> myGroups() async {
    _require();
    return List.of(_groups);
  }

  @override
  Future<StudyGroup> createGroup(String name) async {
    _require();
    final g = StudyGroup(
      id: _id('group'),
      name: name.trim(),
      joinCode: 'ABCD2345',
      isTeacher: true,
      memberCount: 1,
    );
    _groups.add(g);
    return g;
  }

  @override
  Future<void> joinGroup(String code, {String? displayName}) async {
    _require();
    if (code.toUpperCase() != 'ABCD2345') {
      throw const BackendException(BackendFailure.notFound);
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {}

  @override
  Future<List<GroupAssignment>> assignments(String groupId) async => const [];

  @override
  Future<String> createAssignment({
    required String groupId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    DateTime? dueAt,
    int? timeLimitMinutes,
  }) async => _id('assignment');

  @override
  Future<({int score, int total})> submitAssignment(
    String assignmentId,
    List<int> answers,
  ) async => (score: 0, total: answers.length);

  @override
  Future<List<GroupSubmission>> submissions(String assignmentId) async =>
      const [];

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
