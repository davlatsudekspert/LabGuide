import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import '../../features/auth/otp_auth.dart';
import 'backend_models.dart';
import 'lab_backend.dart';
import 'partner_models.dart';

/// Sessiya tokenlari saqlanadigan joy. Ilovada — Keychain/Keystore
/// ([SecureSessionStore]); testlarda — xotira.
abstract interface class SessionStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureSessionStore implements SessionStore {
  const SecureSessionStore();

  static const _key = 'labguide.supabase.session';
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class MemorySessionStore implements SessionStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
  @override
  Future<void> delete() async => value = null;
}

class _Challenge {
  _Challenge(this.issuedAt);
  final DateTime issuedAt;
  int attempts = 0;
}

/// Supabase (Auth + Postgres RPC/RLS + Storage + Edge Function) orqali
/// ishlaydigan server.
///
/// Email OTP: kod Supabase Auth'da yaratiladi va tekshiriladi. Ilova faqat
/// foydalanuvchiga tushunarli holat beradi: kod muddati ([otpTtl] — serverda
/// ham shu qiymat sozlanadi), qayta yuborish oralig'i ([resendCooldown]) va
/// bitta kod uchun [maxAttempts] urinish. Server o'z tezlik cheklovlarini
/// ham qo'llaydi (Auth → Rate limits).
class SupabaseLabBackend implements LabBackend {
  SupabaseLabBackend(
    BackendConfig config, {
    SessionStore? sessionStore,
    http.Client? httpClient,
    DateTime Function()? clock,
    this.otpTtl = const Duration(minutes: 10),
    this.resendCooldown = const Duration(seconds: 60),
    this.maxAttempts = 5,
  }) : _sessions = sessionStore ?? const SecureSessionStore(),
       _clock = clock ?? DateTime.now,
       client = SupabaseClient(
         config.url,
         config.publishableKey,
         httpClient: httpClient,
         authOptions: const AuthClientOptions(
           authFlowType: AuthFlowType.implicit,
         ),
       ) {
    _authSub = client.auth.onAuthStateChange.listen(
      _onAuthState,
      onError: (Object e) => debugPrint('auth state error: $e'),
    );
  }

  final SupabaseClient client;
  final SessionStore _sessions;
  final DateTime Function() _clock;
  final Duration otpTtl;
  final Duration resendCooldown;
  final int maxAttempts;

  late final StreamSubscription<AuthState> _authSub;
  final _sessionLost = StreamController<void>.broadcast();
  final Map<String, _Challenge> _challenges = {};
  bool _signingOut = false;

  static const _bucket = 'support-attachments';

  @override
  bool get isConfigured => true;
  @override
  bool get isAvailable => true;
  @override
  bool get isDemo => false;
  @override
  bool get hasSession => client.auth.currentSession != null;
  @override
  String? get sessionEmail => client.auth.currentUser?.email;
  @override
  String? get userId => client.auth.currentUser?.id;
  @override
  Stream<void> get sessionLost => _sessionLost.stream;

  Future<void> _onAuthState(AuthState state) async {
    final session = state.session;
    switch (state.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
      case AuthChangeEvent.mfaChallengeVerified:
        if (session != null) {
          await _sessions.write(jsonEncode(session.toJson()));
        }
      case AuthChangeEvent.signedOut:
        await _sessions.delete();
        if (!_signingOut) _sessionLost.add(null);
      default:
        break;
    }
  }

  @override
  Future<void> restoreSession() async {
    final stored = await _sessions.read();
    if (stored == null) return;
    try {
      await client.auth.recoverSession(stored);
    } on AuthRetryableFetchException {
      // Internet yo'q: token saqlanib qoladi, keyingi safar tiklanadi.
    } on AuthException catch (e) {
      debugPrint('session not recovered: ${e.code}');
      await _sessions.delete();
    }
  }

  // ------------------------------------------------------------------ OTP
  @override
  Future<OtpRequestResult> requestCode(String email) async {
    if (!isValidEmail(email)) {
      return const OtpRequestResult(OtpRequestStatus.invalidEmail);
    }
    final key = normalizeEmail(email);
    final now = _clock();
    final previous = _challenges[key];
    if (previous != null) {
      final next = previous.issuedAt.add(resendCooldown);
      if (now.isBefore(next)) {
        return OtpRequestResult(
          OtpRequestStatus.rateLimited,
          retryAfter: next.difference(now),
        );
      }
    }
    try {
      await client.auth.signInWithOtp(email: key, shouldCreateUser: true);
    } on AuthRetryableFetchException {
      return const OtpRequestResult(OtpRequestStatus.failed);
    } on AuthException catch (e) {
      if (e.statusCode == '429' || (e.code ?? '').contains('rate_limit')) {
        final seconds = int.tryParse(
          RegExp(r'(\d+)\s*second').firstMatch(e.message)?.group(1) ?? '',
        );
        return OtpRequestResult(
          OtpRequestStatus.rateLimited,
          retryAfter: Duration(seconds: seconds ?? resendCooldown.inSeconds),
        );
      }
      if (e.code == 'email_address_invalid' || e.code == 'validation_failed') {
        return const OtpRequestResult(OtpRequestStatus.invalidEmail);
      }
      debugPrint('otp request failed: ${e.code} ${e.statusCode}');
      return const OtpRequestResult(OtpRequestStatus.failed);
    } on Object catch (e) {
      debugPrint('otp request failed: $e');
      return const OtpRequestResult(OtpRequestStatus.failed);
    }
    _challenges[key] = _Challenge(now);
    return OtpRequestResult(
      OtpRequestStatus.sent,
      retryAfter: resendCooldown,
      validFor: otpTtl,
    );
  }

  @override
  Future<OtpVerifyResult> verifyCode(String email, String code) async {
    final key = normalizeEmail(email);
    final challenge = _challenges[key];
    if (challenge == null) {
      return const OtpVerifyResult(OtpVerifyStatus.noActiveCode);
    }
    final expired = !_clock().isBefore(challenge.issuedAt.add(otpTtl));
    if (expired) return const OtpVerifyResult(OtpVerifyStatus.expired);
    if (challenge.attempts >= maxAttempts) {
      return const OtpVerifyResult(OtpVerifyStatus.tooManyAttempts);
    }
    challenge.attempts++;
    try {
      final res = await client.auth.verifyOTP(
        type: OtpType.email,
        email: key,
        token: code.trim(),
      );
      if (res.session == null) {
        return const OtpVerifyResult(OtpVerifyStatus.failed);
      }
      _challenges.remove(key);
      return const OtpVerifyResult(OtpVerifyStatus.verified);
    } on AuthRetryableFetchException {
      challenge.attempts--; // tarmoq xatosi urinish hisoblanmaydi
      return const OtpVerifyResult(OtpVerifyStatus.failed);
    } on AuthException catch (e) {
      if (e.statusCode == '429') {
        return const OtpVerifyResult(OtpVerifyStatus.tooManyAttempts);
      }
      // Supabase noto'g'ri va muddati o'tgan kodni bir xil qaytaradi
      // (otp_expired); muddatni ilova o'zi biladi.
      final left = maxAttempts - challenge.attempts;
      return left <= 0
          ? const OtpVerifyResult(OtpVerifyStatus.tooManyAttempts)
          : OtpVerifyResult(OtpVerifyStatus.invalidCode, attemptsLeft: left);
    } on Object catch (e) {
      debugPrint('otp verify failed: $e');
      return const OtpVerifyResult(OtpVerifyStatus.failed);
    }
  }

  @override
  Future<void> signOut() async {
    _signingOut = true;
    try {
      await client.auth.signOut();
    } on Object catch (e) {
      // Internet bo'lmasa ham qurilmadagi sessiya o'chiriladi.
      debugPrint('sign out: $e');
    } finally {
      await _sessions.delete();
      _signingOut = false;
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _guard(() => client.functions.invoke('delete-account'));
    await signOut();
  }

  // ------------------------------------------------------------- helpers
  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on BackendException {
      rethrow;
    } on PostgrestException catch (e) {
      throw BackendException(_postgrestFailure(e), '${e.code} ${e.message}');
    } on StorageException catch (e) {
      final status = e.statusCode ?? '';
      throw BackendException(
        status == '413'
            ? BackendFailure.invalid
            : status == '403' || status == '401'
            ? BackendFailure.forbidden
            : BackendFailure.unknown,
        'storage $status ${e.message}',
      );
    } on FunctionException catch (e) {
      throw BackendException(
        e.status == 401 ? BackendFailure.unauthorized : BackendFailure.unknown,
        'function ${e.status}',
      );
    } on AuthRetryableFetchException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    } on AuthException catch (e) {
      throw BackendException(BackendFailure.unauthorized, '${e.code}');
    } on SocketException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    } on http.ClientException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    } on TimeoutException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    }
  }

  static BackendFailure _postgrestFailure(PostgrestException e) =>
      switch (e.code) {
        '42501' => BackendFailure.forbidden,
        '54000' => BackendFailure.rateLimited,
        '22023' || '23514' || '23502' || '22P02' => BackendFailure.invalid,
        '23505' => BackendFailure.invalid,
        'P0002' => BackendFailure.notFound,
        'PGRST301' || 'PGRST303' => BackendFailure.unauthorized,
        _ => BackendFailure.unknown,
      };

  String _requireUser() {
    final id = userId;
    if (id == null) {
      throw const BackendException(BackendFailure.unauthorized);
    }
    return id;
  }

  static String _randomName() {
    final r = Random.secure();
    return List.generate(
      16,
      (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Future<String?> _upload(SupportAttachment? a) async {
    if (a == null) return null;
    if (a.bytes.length > SupportAttachment.maxBytes ||
        !SupportAttachment.allowedTypes.contains(a.mimeType)) {
      throw const BackendException(BackendFailure.invalid, 'attachment');
    }
    final path = '${_requireUser()}/${_randomName()}.${a.extension}';
    await _guard(
      () => client.storage
          .from(_bucket)
          .uploadBinary(
            path,
            a.bytes,
            fileOptions: FileOptions(contentType: a.mimeType),
          ),
    );
    return path;
  }

  static List<Map<String, Object?>> _rows(Object? data) => [
    for (final r in (data as List? ?? const []))
      (r as Map).cast<String, Object?>(),
  ];

  // ------------------------------------------------------------ access
  @override
  Future<AccessInfo> myAccess() async {
    if (!hasSession) return AccessInfo.none;
    final data = await _guard(() => client.rpc<Object?>('my_access'));
    return AccessInfo.fromJson((data! as Map).cast<String, Object?>());
  }

  @override
  Future<void> touchProfile({
    required String role,
    required String language,
  }) async {
    if (!hasSession) return;
    await _guard(
      () => client.rpc<Object?>(
        'touch_profile',
        params: {'p_role': role, 'p_language': language},
      ),
    );
  }

  // ---------------------------------------------------------------- MFA
  @override
  Future<MfaStatus> mfaStatus() async {
    final factors = await _guard(client.auth.mfa.listFactors);
    final aal = client.auth.mfa.getAuthenticatorAssuranceLevel().currentLevel;
    return MfaStatus(
      verifiedFactorId: factors.totp.firstOrNull?.id,
      aal2: aal == AuthenticatorAssuranceLevels.aal2,
    );
  }

  @override
  Future<TotpEnrollment> mfaEnroll() async {
    final factors = await _guard(client.auth.mfa.listFactors);
    // Oldingi tugallanmagan urinishlar yangisiga xalal bermasin.
    for (final f in factors.all) {
      if (f.factorType == FactorType.totp &&
          f.status != FactorStatus.verified) {
        await _guard(() => client.auth.mfa.unenroll(f.id));
      }
    }
    final res = await _guard(
      () => client.auth.mfa.enroll(
        issuer: 'LabGuide',
        friendlyName: 'LabGuide admin',
      ),
    );
    final totp = res.totp!;
    return TotpEnrollment(factorId: res.id, secret: totp.secret, uri: totp.uri);
  }

  @override
  Future<void> mfaVerify({
    required String factorId,
    required String code,
  }) async {
    try {
      await client.auth.mfa.challengeAndVerify(
        factorId: factorId,
        code: code.trim(),
      );
    } on AuthRetryableFetchException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    } on AuthException catch (e) {
      throw BackendException(BackendFailure.invalid, '${e.code}');
    }
  }

  // ------------------------------------------------------------ support
  @override
  Future<List<SupportThread>> myThreads() async {
    final uid = _requireUser();
    final data = await _guard(
      () => client
          .from('support_threads')
          .select()
          .eq('user_id', uid)
          .order('updated_at', ascending: false),
    );
    return _rows(data).map(SupportThread.fromJson).toList();
  }

  @override
  Future<List<SupportMessage>> messages(String threadId) async {
    final data = await _guard(
      () => client
          .from('support_messages')
          .select()
          .eq('thread_id', threadId)
          .order('created_at'),
    );
    return _rows(data).map(SupportMessage.fromJson).toList();
  }

  @override
  Future<String> createThread({
    required SupportKind kind,
    required String subject,
    required String body,
    SupportAttachment? attachment,
  }) async {
    final path = await _upload(attachment);
    final id = await _guard(
      () => client.rpc<Object?>(
        'support_create_thread',
        params: {
          'p_kind': kind.name,
          'p_subject': subject,
          'p_body': body,
          'p_attachment': path,
        },
      ),
    );
    return id! as String;
  }

  @override
  Future<void> postMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  }) async {
    final path = await _upload(attachment);
    await _guard(
      () => client.rpc<Object?>(
        'support_post_message',
        params: {'p_thread': threadId, 'p_body': body, 'p_attachment': path},
      ),
    );
  }

  @override
  Future<void> markRead(String threadId) => _guard(
    () => client.rpc<Object?>(
      'support_mark_read',
      params: {'p_thread': threadId},
    ),
  );

  @override
  Future<Uint8List> attachment(String path) =>
      _guard(() => client.storage.from(_bucket).download(path));

  // -------------------------------------------------------------- admin
  @override
  Future<AdminStats> adminStats() async {
    final data = await _guard(() => client.rpc<Object?>('admin_stats'));
    return AdminStats((data! as Map).cast<String, Object?>());
  }

  @override
  Future<List<SupportThread>> adminThreads({SupportStatus? status}) async {
    final data = await _guard(() {
      var q = client.from('support_threads').select();
      if (status != null) q = q.eq('status', supportStatusToWire(status));
      return q.order('updated_at', ascending: false).limit(100);
    });
    return _rows(data).map(SupportThread.fromJson).toList();
  }

  @override
  Future<void> adminReply(String threadId, String body) => _guard(
    () => client.rpc<Object?>(
      'admin_reply',
      params: {'p_thread': threadId, 'p_body': body},
    ),
  );

  @override
  Future<void> adminSetStatus(String threadId, SupportStatus status) => _guard(
    () => client.rpc<Object?>(
      'admin_set_thread_status',
      params: {'p_thread': threadId, 'p_status': supportStatusToWire(status)},
    ),
  );

  @override
  Future<void> adminMarkRead(String threadId) => _guard(
    () =>
        client.rpc<Object?>('admin_mark_read', params: {'p_thread': threadId}),
  );

  @override
  Future<AdminUserPage> adminUsers({
    String? query,
    String? role,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _guard(
      () => client.rpc<Object?>(
        'admin_list_users',
        params: {
          'p_query': query,
          'p_role': role,
          'p_language': language,
          'p_limit': limit,
          'p_offset': offset,
        },
      ),
    );
    final rows = _rows(data);
    return AdminUserPage(
      rows.map(AdminUserRow.fromJson).toList(),
      rows.isEmpty ? 0 : (rows.first['total']! as num).toInt(),
    );
  }

  @override
  Future<String> adminRevealEmail(String userId) async {
    final e = await _guard(
      () =>
          client.rpc<Object?>('admin_reveal_email', params: {'p_user': userId}),
    );
    return (e as String?) ?? '';
  }

  @override
  Future<void> adminSetReviewer(String userId, {required bool enabled}) =>
      _guard(
        () => client.rpc<Object?>(
          'admin_set_reviewer',
          params: {'p_user': userId, 'p_enabled': enabled},
        ),
      );

  @override
  Future<List<AuditEntry>> adminAudit({int limit = 50}) async {
    final data = await _guard(
      () => client
          .from('admin_audit')
          .select('at, action, target, details')
          .order('at', ascending: false)
          .limit(limit),
    );
    return _rows(data).map(AuditEntry.fromJson).toList();
  }

  // --------------------------------------------------- content review
  @override
  Future<void> submitReview({
    required String kind,
    required String itemId,
    required String contentVersion,
    required ReviewDecision decision,
    String? comment,
  }) => _guard(
    () => client.rpc(
      'review_submit',
      params: {
        'p_kind': kind,
        'p_item': itemId,
        'p_version': contentVersion,
        'p_decision': decision.name,
        'p_comment': comment,
      },
    ),
  );

  @override
  Future<List<ContentReview>> contentReviews() async {
    final data = await _guard(
      () => client
          .from('content_reviews')
          .select(
            'id, item_kind, item_id, content_version, reviewer_id, decision, '
            'comment, created_at',
          )
          .order('created_at', ascending: false)
          .limit(1000),
    );
    return _rows(data).map(ContentReview.fromJson).toList();
  }

  // ------------------------------------------------------------- groups
  @override
  Future<List<StudyGroup>> myGroups() async {
    final uid = _requireUser();
    final groups = _rows(
      await _guard(
        () => client
            .from('study_groups')
            .select('id, name, join_code, created_at')
            .order('created_at', ascending: false),
      ),
    );
    final members = _rows(
      await _guard(
        () => client
            .from('group_members')
            .select('group_id, user_id, member_role'),
      ),
    );
    return [
      for (final g in groups)
        () {
          final id = g['id']! as String;
          final mine = members.firstWhere(
            (m) => m['group_id'] == id && m['user_id'] == uid,
            orElse: () => const {'member_role': 'student'},
          );
          final teacher = mine['member_role'] == 'teacher';
          return StudyGroup(
            id: id,
            name: g['name']! as String,
            joinCode: teacher ? g['join_code'] as String? : null,
            isTeacher: teacher,
            memberCount: members.where((m) => m['group_id'] == id).length,
          );
        }(),
    ];
  }

  @override
  Future<StudyGroup> createGroup(String name, {String? displayName}) async {
    final data = await _guard(
      () => client.rpc<Object?>(
        'create_group',
        params: {'p_name': name, 'p_display_name': _nameOr(displayName)},
      ),
    );
    final m = (data! as Map).cast<String, Object?>();
    return StudyGroup(
      id: m['id']! as String,
      name: name.trim(),
      joinCode: m['join_code']! as String,
      isTeacher: true,
      memberCount: 1,
    );
  }

  /// Guruhda ko'rinadigan ism: foydalanuvchi kiritgani, bo'lmasa emailning
  /// @ gacha qismi.
  String _nameOr(String? displayName) =>
      (displayName == null || displayName.trim().length < 2)
      ? (sessionEmail ?? 'user').split('@').first
      : displayName.trim();

  @override
  Future<String> joinGroup(String code, {String? displayName}) async {
    final id = await _guard(
      () => client.rpc<Object?>(
        'join_group',
        params: {'p_code': code, 'p_display_name': _nameOr(displayName)},
      ),
    );
    return id! as String;
  }

  @override
  Future<void> leaveGroup(String groupId) => _guard(
    () => client.rpc<Object?>('leave_group', params: {'p_group': groupId}),
  );

  @override
  Future<List<GroupMember>> groupMembers(String groupId) async {
    final data = await _guard(
      () => client
          .from('group_members')
          .select('user_id, display_name, member_role, joined_at')
          .eq('group_id', groupId)
          .order('joined_at'),
    );
    return _rows(data).map(GroupMember.fromJson).toList();
  }

  @override
  Future<void> removeMember(String groupId, String userId) => _guard(
    () => client.rpc<Object?>(
      'remove_member',
      params: {'p_group': groupId, 'p_user': userId},
    ),
  );

  @override
  Future<List<GroupAssignment>> assignments(String groupId) async {
    final data = await _guard(
      () => client
          .from('assignments')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: false),
    );
    return _rows(data).map(GroupAssignment.fromJson).toList();
  }

  @override
  Future<String> createAssignment({
    required String groupId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    DateTime? dueAt,
    int? timeLimitMinutes,
  }) async {
    final id = await _guard(
      () => client.rpc<Object?>(
        'create_assignment',
        params: {
          'p_group': groupId,
          'p_title': title,
          'p_question_ids': questionIds,
          'p_correct': correctIndexes,
          'p_due': dueAt?.toUtc().toIso8601String(),
          'p_time_limit': timeLimitMinutes,
        },
      ),
    );
    return id! as String;
  }

  @override
  Future<AssignmentStart> startAssignment(String assignmentId) async {
    final data = await _guard(
      () => client.rpc<Object?>(
        'start_assignment',
        params: {'p_assignment': assignmentId},
      ),
    );
    return AssignmentStart.fromJson((data! as Map).cast<String, Object?>());
  }

  @override
  Future<GroupSubmission> submitAssignment(
    String assignmentId,
    List<int> answers,
  ) async {
    final data = await _guard(
      () => client.rpc<Object?>(
        'submit_assignment',
        params: {'p_assignment': assignmentId, 'p_answers': answers},
      ),
    );
    final m = (data! as Map).cast<String, Object?>();
    return GroupSubmission(
      assignmentId: assignmentId,
      userId: userId ?? '',
      score: (m['score']! as num).toInt(),
      total: (m['total']! as num).toInt(),
      submittedAt: _clock().toUtc(),
      answers: answers,
      correct: (m['correct'] as List?)?.map((c) => c == true).toList(),
    );
  }

  static const _submissionColumns =
      'assignment_id, user_id, score, total, answers, correct, submitted_at';

  @override
  Future<List<GroupSubmission>> submissions(String assignmentId) async {
    final data = await _guard(
      () => client
          .from('submissions')
          .select(_submissionColumns)
          .eq('assignment_id', assignmentId)
          .order('submitted_at'),
    );
    return _rows(data).map(GroupSubmission.fromJson).toList();
  }

  @override
  Future<List<GroupSubmission>> groupSubmissions(String groupId) async {
    final ids = [for (final a in await assignments(groupId)) a.id];
    if (ids.isEmpty) return const [];
    final data = await _guard(
      () => client
          .from('submissions')
          .select(_submissionColumns)
          .inFilter('assignment_id', ids)
          .order('submitted_at'),
    );
    return _rows(data).map(GroupSubmission.fromJson).toList();
  }

  @override
  Future<List<int>> assignmentKey(String assignmentId) async {
    final rows = _rows(
      await _guard(
        () => client
            .from('assignment_keys')
            .select('correct_indexes')
            .eq('assignment_id', assignmentId),
      ),
    );
    // RLS: ustoz bo'lmasa qator qaytmaydi.
    if (rows.isEmpty) throw const BackendException(BackendFailure.forbidden);
    return [
      for (final i in rows.single['correct_indexes']! as List)
        (i! as num).toInt(),
    ];
  }

  // ----------------------------------------------------------- partners
  static const _logoBucket = 'partner-logos';
  static const _logoMaxBytes = 1024 * 1024;

  @override
  Future<List<Partner>> partners() async {
    final data = await _guard(() => client.rpc<Object?>('partners_feed'));
    return _rows(data).map(Partner.fromJson).toList();
  }

  @override
  Future<int> trackPartnerEvents(List<PartnerEvent> events) async {
    // Mehmon hodisasi sanalmaydi (server ham rad etadi).
    if (!hasSession || events.isEmpty) return 0;
    var accepted = 0;
    for (var i = 0; i < events.length; i += 20) {
      final batch = events.skip(i).take(20).map((e) => e.toJson()).toList();
      final n = await _guard(
        () => client.rpc<Object?>('partner_track', params: {'p_events': batch}),
      );
      accepted += (n as num?)?.toInt() ?? 0;
    }
    return accepted;
  }

  @override
  Future<String> createPartnerRequest(PartnerRequestDraft draft) async {
    _requireUser();
    final id = await _guard(
      () => client.rpc<Object?>(
        'partner_request_create',
        params: {
          'p_company': draft.company,
          'p_contact': draft.contactName,
          'p_phone': draft.phone,
          'p_email': draft.email,
          'p_products': draft.products,
          'p_message': draft.message,
        },
      ),
    );
    return id! as String;
  }

  @override
  Future<List<PartnerRequest>> myPartnerRequests() async {
    final uid = _requireUser();
    final data = await _guard(
      () => client
          .from('partner_requests')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false),
    );
    return _rows(data).map(PartnerRequest.fromJson).toList();
  }

  @override
  Future<List<Partner>> adminPartners() async {
    final data = await _guard(() => client.rpc<Object?>('admin_partners'));
    return _rows(data).map(Partner.fromJson).toList();
  }

  @override
  Future<String> adminSavePartner(PartnerDraft draft, {String? id}) async {
    final saved = await _guard(
      () => client.rpc<Object?>(
        'admin_partner_save',
        params: {'p_id': id, 'p': draft.toJson()},
      ),
    );
    return saved! as String;
  }

  @override
  Future<void> adminSetPartnerStatus(String id, PartnerStatus status) => _guard(
    () => client.rpc<Object?>(
      'admin_partner_set_status',
      params: {'p_id': id, 'p_status': status.name},
    ),
  );

  @override
  Future<String> adminUploadPartnerLogo(
    Uint8List bytes,
    String mimeType,
  ) async {
    if (bytes.length > _logoMaxBytes ||
        !SupportAttachment.allowedTypes.contains(mimeType)) {
      throw const BackendException(BackendFailure.invalid, 'logo');
    }
    final path = '${_randomName()}.${mimeType == 'image/png' ? 'png' : 'jpg'}';
    await _guard(
      () => client.storage
          .from(_logoBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          ),
    );
    return client.storage.from(_logoBucket).getPublicUrl(path);
  }

  @override
  Future<List<PartnerDayStat>> adminPartnerStats(String id) async {
    final data = await _guard(
      () => client
          .from('partner_events')
          .select('day, placement, impressions, contacts')
          .eq('partner_id', id)
          .order('day', ascending: false)
          .limit(2000),
    );
    return _rows(data).map(PartnerDayStat.fromJson).toList();
  }

  @override
  Future<List<PartnerRequest>> adminPartnerRequests({
    PartnerRequestStatus? status,
  }) async {
    final data = await _guard(() {
      var q = client.from('partner_requests').select();
      if (status != null) q = q.eq('status', status.wire);
      return q.order('created_at', ascending: false).limit(100);
    });
    return _rows(data).map(PartnerRequest.fromJson).toList();
  }

  @override
  Future<void> adminUpdatePartnerRequest(
    String id, {
    required PartnerRequestStatus status,
    String? reply,
  }) => _guard(
    () => client.rpc<Object?>(
      'admin_partner_request_update',
      params: {'p_id': id, 'p_status': status.wire, 'p_reply': reply},
    ),
  );

  Future<void> dispose() async {
    await _authSub.cancel();
    await _sessionLost.close();
    await client.dispose();
  }
}
