import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/otp_auth.dart';
import 'backend_models.dart';
import 'lab_backend.dart';
import 'partner_models.dart';
import 'supabase_backend.dart' show SessionStore;

/// Cloudflare Worker API manzili (build vaqtida, repoda yo'q):
///
///   flutter build ipa --dart-define=LG_API_URL=https://labguide-api.<sub>.workers.dev
///
/// Bo'sh bo'lsa — mavjud tanlov (Supabase yoki “server ulanmagan”) saqlanadi.
@immutable
class ApiConfig {
  const ApiConfig({required this.url});

  static const fromEnvironment = ApiConfig(
    url: String.fromEnvironment('LG_API_URL'),
  );

  final String url;

  bool get isConfigured {
    final u = Uri.tryParse(url.trim());
    return u != null && u.scheme == 'https' && u.host.isNotEmpty;
  }

  Uri resolve(String path, [Map<String, String>? query]) {
    final base = url.trim().replaceAll(RegExp(r'/+$'), '');
    final u = Uri.parse('$base$path');
    return query == null ? u : u.replace(queryParameters: query);
  }
}

/// Qurilmaning xavfsiz omborida (Keychain/Keystore) Cloudflare sessiyasi.
class SecureApiSessionStore implements SessionStore {
  const SecureApiSessionStore();

  static const _key = 'labguide.api.session';
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}

enum QaResult { correct, partial, incorrect, skipped }

/// Savol-javob belgisi: ustoz qo'yadi, baho (1–5) ixtiyoriy.
@immutable
class QaMark {
  const QaMark({
    required this.id,
    required this.userId,
    required this.dayId,
    required this.questionId,
    required this.result,
    required this.grade,
    required this.markedAt,
  });

  factory QaMark.fromJson(Map<String, Object?> j) => QaMark(
    id: j['id']! as String,
    userId: j['user_id']! as String,
    dayId: j['day_id']! as String,
    questionId: j['question_id']! as String,
    result: QaResult.values.byName(j['result']! as String),
    grade: (j['grade'] as num?)?.toInt(),
    markedAt: DateTime.parse(j['marked_at']! as String),
  );

  final String id;
  final String userId;
  final String dayId;
  final String questionId;
  final QaResult result;
  final int? grade;
  final DateTime markedAt;
}

class _ApiResponse {
  const _ApiResponse(this.status, this.data);
  final int status;
  final Object? data;

  Map<String, Object?> get map =>
      (data is Map) ? (data! as Map).cast<String, Object?>() : const {};
  String? get error => map['error'] as String?;
  bool get ok => status >= 200 && status < 300;
}

/// Cloudflare Workers + D1 serveri (`cloudflare/`). Kod, limitlar va
/// vakolatlar serverda; ilova faqat natijani ko'rsatadi.
///
/// Hali ko'chirilmagan bo'limlar (murojaatlar, admin panel, tekshiruv,
/// hamkorlar, Pro) `BackendFailure.unavailable` beradi — ishlayotgandek
/// ko'rsatilmaydi.
class CloudflareLabBackend implements LabBackend {
  CloudflareLabBackend(
    this.config, {
    SessionStore? sessionStore,
    http.Client? httpClient,
    DateTime Function()? clock,
    this.timeout = const Duration(seconds: 20),
  }) : _sessions = sessionStore ?? const SecureApiSessionStore(),
       _http = httpClient ?? http.Client(),
       _clock = clock ?? DateTime.now;

  final ApiConfig config;
  final SessionStore _sessions;
  final http.Client _http;
  final DateTime Function() _clock;
  final Duration timeout;

  final _sessionLost = StreamController<void>.broadcast();
  String? _token;
  String? _email;
  String? _userId;

  @override
  bool get isConfigured => true;
  @override
  bool get isAvailable => true;
  @override
  bool get isDemo => false;
  @override
  bool get hasSession => _token != null;
  @override
  String? get sessionEmail => _email;
  @override
  String? get userId => _userId;
  @override
  Stream<void> get sessionLost => _sessionLost.stream;

  // -------------------------------------------------------------- http
  Future<_ApiResponse> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final req = http.Request(method, config.resolve(path, query));
    req.headers['accept'] = 'application/json';
    if (auth) {
      final t = _token;
      if (t == null) throw const BackendException(BackendFailure.unauthorized);
      req.headers['authorization'] = 'Bearer $t';
    }
    if (body != null) {
      req.headers['content-type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    final http.Response res;
    try {
      res = await http.Response.fromStream(
        await _http.send(req).timeout(timeout),
      ).timeout(timeout);
    } on SocketException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    } on http.ClientException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    } on TimeoutException catch (e) {
      throw BackendException(BackendFailure.network, '$e');
    }
    Object? data;
    if (res.body.isNotEmpty) {
      try {
        data = jsonDecode(res.body);
      } on FormatException {
        data = null;
      }
    }
    final out = _ApiResponse(res.statusCode, data);
    if (auth && res.statusCode == 401) {
      // Server sessiyani tan olmadi (muddati o'tgan / boshqa qurilmada chiqilgan).
      await _clearSession();
      _sessionLost.add(null);
    }
    return out;
  }

  /// Muvaffaqiyatsiz javobni xato turiga aylantiradi.
  ///
  /// [notFound] — server `404` ni shu amal uchun boshqa xato deb bildiradi.
  /// Worker a'zo bo'lmaganga guruh borligini ham aytmaydi (404); kontraktda
  /// (FakeLabBackend / Supabase RLS) esa begona guruhga ustoz amali —
  /// `forbidden`. [codes] — aniq server kodi (`error`) bo'yicha istisno.
  Future<_ApiResponse> _call(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    BackendFailure? notFound,
    Map<String, BackendFailure?> codes = const {},
  }) async {
    final r = await _send(method, path, body: body, query: query);
    if (r.ok) return r;
    final code = r.error;
    final BackendFailure? failure;
    if (code != null && codes.containsKey(code)) {
      failure = codes[code];
      // null — kontraktda bu holat xato emas (masalan, allaqachon bajarilgan).
      if (failure == null) return r;
    } else if (r.status == 404 && notFound != null) {
      failure = notFound;
    } else {
      failure = _failure(r.status);
    }
    throw BackendException(failure, '$method $path ${r.status} $code');
  }

  static BackendFailure _failure(int status) => switch (status) {
    400 || 409 || 413 || 415 || 422 => BackendFailure.invalid,
    401 => BackendFailure.unauthorized,
    403 => BackendFailure.forbidden,
    404 => BackendFailure.notFound,
    429 => BackendFailure.rateLimited,
    502 || 504 => BackendFailure.network,
    501 || 503 => BackendFailure.unavailable,
    _ => BackendFailure.unknown,
  };

  /// Ro'yxat o'qish: a'zo bo'lmagan guruh (404) — bo'sh ro'yxat, xuddi
  /// Supabase RLS dagi kabi (begona ustoz va admin ham hech narsa ko'rmaydi).
  Future<List<Map<String, Object?>>> _list(String path) async {
    final r = await _send('GET', path);
    if (r.status == 404) return const [];
    if (!r.ok) {
      throw BackendException(
        _failure(r.status),
        'GET $path ${r.status} ${r.error}',
      );
    }
    return _rows(r.data);
  }

  static List<Map<String, Object?>> _rows(Object? data) => [
    for (final r in (data as List? ?? const []))
      (r as Map).cast<String, Object?>(),
  ];

  static Duration? _seconds(Object? v) =>
      v is num ? Duration(seconds: v.toInt()) : null;

  // ----------------------------------------------------------- session
  Future<void> _clearSession() async {
    _token = null;
    _email = null;
    _userId = null;
    await _sessions.delete();
  }

  @override
  Future<void> restoreSession() async {
    final raw = await _sessions.read();
    if (raw == null) return;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      final expires = DateTime.parse(j['expires_at']! as String);
      if (!_clock().isBefore(expires)) {
        await _sessions.delete();
        return;
      }
      // Tarmoqqa chiqilmaydi (bepul tarif so'rovlarini tejash): token
      // birinchi so'rovda server tomonidan tekshiriladi, 401 bo'lsa o'chadi.
      _token = j['token']! as String;
      _email = j['email'] as String?;
      _userId = j['user_id'] as String?;
    } on Object catch (e) {
      debugPrint('api session not restored: ${e.runtimeType}');
      await _sessions.delete();
    }
  }

  @override
  Future<OtpRequestResult> requestCode(String email) async {
    if (!isValidEmail(email)) {
      return const OtpRequestResult(OtpRequestStatus.invalidEmail);
    }
    try {
      final r = await _send(
        'POST',
        '/v1/auth/otp/request',
        body: {'email': normalizeEmail(email)},
        auth: false,
      );
      return switch (r.status) {
        200 => OtpRequestResult(
          OtpRequestStatus.sent,
          retryAfter: _seconds(r.map['retry_after']),
          validFor: _seconds(r.map['valid_for']),
        ),
        400 => const OtpRequestResult(OtpRequestStatus.invalidEmail),
        429 => OtpRequestResult(
          OtpRequestStatus.rateLimited,
          retryAfter: _seconds(r.map['retry_after']),
        ),
        503 => const OtpRequestResult(OtpRequestStatus.unavailable),
        _ => const OtpRequestResult(OtpRequestStatus.failed),
      };
    } on BackendException {
      return const OtpRequestResult(OtpRequestStatus.failed);
    }
  }

  @override
  Future<OtpVerifyResult> verifyCode(String email, String code) async {
    final key = normalizeEmail(email);
    try {
      final r = await _send(
        'POST',
        '/v1/auth/otp/verify',
        body: {'email': key, 'code': code.trim()},
        auth: false,
      );
      if (r.status == 200) {
        final m = r.map;
        _token = m['token']! as String;
        _userId = m['user_id']! as String;
        _email = key;
        await _sessions.write(
          jsonEncode({
            'token': _token,
            'user_id': _userId,
            'email': key,
            'expires_at': m['expires_at'],
          }),
        );
        return const OtpVerifyResult(OtpVerifyStatus.verified);
      }
      return switch (r.error) {
        'invalid_code' => OtpVerifyResult(
          OtpVerifyStatus.invalidCode,
          attemptsLeft: (r.map['attempts_left'] as num?)?.toInt(),
        ),
        'expired' => const OtpVerifyResult(OtpVerifyStatus.expired),
        'no_active_code' ||
        'invalid_email' => const OtpVerifyResult(OtpVerifyStatus.noActiveCode),
        'too_many_attempts' || 'rate_limited' => const OtpVerifyResult(
          OtpVerifyStatus.tooManyAttempts,
        ),
        'not_configured' => const OtpVerifyResult(OtpVerifyStatus.unavailable),
        _ => const OtpVerifyResult(OtpVerifyStatus.failed),
      };
    } on BackendException {
      return const OtpVerifyResult(OtpVerifyStatus.failed);
    }
  }

  @override
  Future<void> signOut() async {
    if (_token != null) {
      try {
        await _send('POST', '/v1/auth/logout');
      } on Object catch (e) {
        // Internet bo'lmasa ham qurilmadagi sessiya o'chiriladi.
        debugPrint('sign out: ${e.runtimeType}');
      }
    }
    await _clearSession();
  }

  @override
  Future<void> deleteAccount() async {
    await _call('DELETE', '/v1/me');
    await _clearSession();
  }

  // ------------------------------------------------------------ access
  @override
  Future<AccessInfo> myAccess() async {
    if (!hasSession) return AccessInfo.none;
    final r = await _call('GET', '/v1/me');
    return AccessInfo.fromJson(r.map);
  }

  @override
  Future<void> touchProfile({
    required String role,
    required String language,
  }) async {
    if (!hasSession) return;
    await _call(
      'PUT',
      '/v1/me/profile',
      body: {'role': role, 'language': language},
    );
  }

  // --------------------------------------------------------------- MFA
  @override
  Future<MfaStatus> mfaStatus() async {
    final m = (await _call('GET', '/v1/auth/mfa')).map;
    return MfaStatus(
      verifiedFactorId: m['verified_factor_id'] as String?,
      aal2: m['aal'] == 'aal2',
    );
  }

  @override
  Future<TotpEnrollment> mfaEnroll() async {
    final m = (await _call('POST', '/v1/auth/mfa/enroll')).map;
    return TotpEnrollment(
      factorId: m['factor_id']! as String,
      secret: m['secret']! as String,
      uri: m['uri']! as String,
    );
  }

  @override
  Future<void> mfaVerify({
    required String factorId,
    required String code,
  }) async {
    await _call(
      'POST',
      '/v1/auth/mfa/verify',
      body: {'factor_id': factorId, 'code': code.trim()},
    );
  }

  // ------------------------------------------------------------ groups
  // Endpoint ↔ metod jadvali: docs/BACKEND_CLOUDFLARE.md. Xatolar kontraktga
  // (FakeLabBackend, test/unit/classroom_rules_test.dart) moslanadi.

  /// `POST /v1/me/teacher` — faqat email kodi bilan kirgan hisob (sessiya
  /// bo'lmasa `unauthorized`). Admin vakolati bermaydi.
  @override
  Future<void> registerTeacher() => _call('POST', '/v1/me/teacher');

  @override
  Future<List<StudyGroup>> myGroups() async {
    final r = await _call('GET', '/v1/groups');
    return [
      for (final g in _rows(r.data))
        StudyGroup(
          id: g['id']! as String,
          name: g['name']! as String,
          joinCode: g['join_code'] as String?,
          isTeacher: g['is_teacher'] == true,
          memberCount: (g['member_count'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// Guruhni faqat ro'yxatdan o'tgan ustoz ([registerTeacher]) yaratadi
  /// (aks holda `forbidden`; 10 tadan ortiq — `rateLimited`).
  /// [displayName] — ixtiyoriy taxallus (ism shart emas).
  @override
  Future<StudyGroup> createGroup(String name, {String? displayName}) async {
    final m = (await _call(
      'POST',
      '/v1/groups',
      body: {'name': name.trim(), 'display_name': _alias(displayName)},
    )).map;
    return StudyGroup(
      id: m['id']! as String,
      name: m['name']! as String,
      joinCode: m['join_code'] as String?,
      isTeacher: true,
      memberCount: (m['member_count'] as num?)?.toInt() ?? 1,
    );
  }

  /// Bo'sh taxallus — null (tartib raqami ko'rinadi; email ishlatilmaydi).
  /// Uzunlik (2–24) va belgilarni server tekshiradi (`invalid`).
  static String? _alias(String? v) {
    final t = v?.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  /// Noto'g'ri kod — `notFound`; guruh to'la (200) — `rateLimited`.
  @override
  Future<String> joinGroup(String code, {String? displayName}) async {
    final m = (await _call(
      'POST',
      '/v1/groups/join',
      body: {'code': code.trim(), 'display_name': _alias(displayName)},
    )).map;
    return m['group_id']! as String;
  }

  @override
  Future<void> setMyAlias(String groupId, String? alias) => _call(
    'PUT',
    '/v1/groups/${_seg(groupId)}/alias',
    body: {'alias': _alias(alias)},
    notFound: BackendFailure.forbidden,
  );

  /// A'zo bo'lmagan guruhdan chiqish — xato emas (kontrakt).
  @override
  Future<void> leaveGroup(String groupId) => _call(
    'POST',
    '/v1/groups/${_seg(groupId)}/leave',
    codes: const {'not_found': null},
  );

  /// Talaba — o'zi va ustoz; ustoz — hamma; begona — bo'sh ro'yxat.
  @override
  Future<List<GroupMember>> groupMembers(String groupId) async =>
      (await _list('/v1/groups/${_seg(groupId)}/members'))
          .map(GroupMember.fromJson)
          .toList();

  @override
  Future<void> removeMember(String groupId, String userId) => _call(
    'DELETE',
    '/v1/groups/${_seg(groupId)}/members/${_seg(userId)}',
    notFound: BackendFailure.forbidden,
    // Talaba allaqachon guruhda yo'q — kontraktda xato emas.
    codes: const {'member_not_found': null},
  );

  /// Ustoz guruhni butunlay o'chiradi (ilova hozircha chaqirmaydi).
  Future<void> deleteGroup(String groupId) => _call(
    'DELETE',
    '/v1/groups/${_seg(groupId)}',
    notFound: BackendFailure.forbidden,
  );

  /// Ustoz taklif kodini yangilaydi (eski kod va QR ishlamay qoladi;
  /// ilova hozircha chaqirmaydi).
  Future<String> rotateJoinCode(String groupId) async {
    final m = (await _call(
      'POST',
      '/v1/groups/${_seg(groupId)}/code',
      notFound: BackendFailure.forbidden,
    )).map;
    return m['join_code']! as String;
  }

  // ---------------------------------------------------------- topics
  /// Ochilgan mavzular (a'zo ko'radi; begona — bo'sh). [closeTopic] bilan
  /// yopilganlar ko'rsatilmaydi.
  @override
  Future<List<GroupTopic>> groupTopics(String groupId) async => [
    for (final t in await _list('/v1/groups/${_seg(groupId)}/topics'))
      if (t['open'] != false) GroupTopic.fromJson(t),
  ];

  /// Faqat guruh egasi-ustoz; noto'g'ri id — `invalid`, ≤ 300 mavzu.
  @override
  Future<void> openTopic(String groupId, String topicId) => _call(
    'PUT',
    _topic(groupId, topicId),
    notFound: BackendFailure.forbidden,
  );

  /// Mavzuni talabalardan yashirish (ilova hozircha chaqirmaydi).
  Future<void> closeTopic(String groupId, String topicId) =>
      _call('DELETE', _topic(groupId, topicId));

  @override
  Future<void> markTopicStage(
    String groupId,
    String topicId,
    TopicStage stage,
  ) => _call(
    'POST',
    '${_topic(groupId, topicId)}/stage',
    body: {'stage': stage.wire},
    notFound: BackendFailure.forbidden,
  );

  /// Mavzuga bitta test: ikkinchisi — `invalid` (409 `test_exists`).
  @override
  Future<String> startTopicTest({
    required String groupId,
    required String topicId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    int? timeLimitMinutes,
  }) async {
    final m = (await _call(
      'POST',
      '${_topic(groupId, topicId)}/test',
      body: {
        'title': title.trim(),
        'question_ids': questionIds,
        'correct_indexes': correctIndexes,
        'time_limit_minutes': timeLimitMinutes,
      },
      notFound: BackendFailure.forbidden,
    )).map;
    return m['id']! as String;
  }

  /// Mavzuda test yo'q — `notFound`; begona guruh — `forbidden`.
  @override
  Future<void> finishTopicTest(String groupId, String topicId) => _call(
    'POST',
    '${_topic(groupId, topicId)}/finish',
    notFound: BackendFailure.forbidden,
    codes: const {'no_test': BackendFailure.notFound},
  );

  String _topic(String groupId, String topicId) =>
      '/v1/groups/${_seg(groupId)}/topics/${_seg(topicId)}';

  // ----------------------------------------------------------- marks
  // Savol-javob belgilari: Worker'da bor, ilova hozircha chaqirmaydi.

  /// Ustoz — guruhdagi hamma belgilar; talaba — faqat o'ziniki.
  Future<List<QaMark>> marks(String groupId, {String? dayId}) async {
    final r = await _call(
      'GET',
      '/v1/groups/${_seg(groupId)}/marks',
      query: dayId == null ? null : {'day_id': dayId},
    );
    return _rows(r.data).map(QaMark.fromJson).toList();
  }

  Future<String> putMark(
    String groupId, {
    required String userId,
    required String dayId,
    required String questionId,
    required QaResult result,
    int? grade,
  }) async {
    final m = (await _call(
      'PUT',
      '/v1/groups/${_seg(groupId)}/marks',
      body: {
        'user_id': userId,
        'day_id': dayId,
        'question_id': questionId,
        'result': result.name,
        'grade': grade,
      },
    )).map;
    return m['id']! as String;
  }

  Future<void> deleteMark(String groupId, String markId) =>
      _call('DELETE', '/v1/groups/${_seg(groupId)}/marks/${_seg(markId)}');

  // ----------------------------------------------------- assignments
  @override
  Future<List<GroupAssignment>> assignments(String groupId) async =>
      (await _list('/v1/groups/${_seg(groupId)}/assignments'))
          .map(GroupAssignment.fromJson)
          .toList();

  /// [start] `false` — qoralama: talabalar ko'rmaydi, ustoz
  /// [openAssignment] bilan boshlaydi. [dayId] — bog'liq mavzu (ixtiyoriy).
  @override
  Future<String> createAssignment({
    required String groupId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    DateTime? dueAt,
    int? timeLimitMinutes,
    String? dayId,
    bool start = true,
  }) async {
    final m = (await _call(
      'POST',
      '/v1/groups/${_seg(groupId)}/assignments',
      body: {
        'title': title.trim(),
        'question_ids': questionIds,
        'correct_indexes': correctIndexes,
        'due_at': dueAt?.toUtc().toIso8601String(),
        'time_limit_minutes': timeLimitMinutes,
        'day_id': dayId,
        'start': start,
      },
      notFound: BackendFailure.forbidden,
    )).map;
    return m['id']! as String;
  }

  /// Ustoz test sessiyasini boshlaydi (ilova hozircha chaqirmaydi).
  Future<void> openAssignment(String assignmentId) => _call(
    'POST',
    '/v1/assignments/${_seg(assignmentId)}/open',
    notFound: BackendFailure.forbidden,
  );

  /// Ustoz test sessiyasini yakunlaydi (ilova [finishTopicTest] ishlatadi).
  Future<void> closeAssignment(String assignmentId) => _call(
    'POST',
    '/v1/assignments/${_seg(assignmentId)}/close',
    notFound: BackendFailure.forbidden,
  );

  /// Faqat shu guruh talabasi (aks holda `forbidden`); yakunlangan yoki
  /// muddati o'tgan test — `invalid`.
  @override
  Future<AssignmentStart> startAssignment(String assignmentId) async {
    final r = await _call(
      'POST',
      '/v1/assignments/${_seg(assignmentId)}/start',
      notFound: BackendFailure.forbidden,
    );
    return AssignmentStart.fromJson(r.map);
  }

  /// Vaqt chegarasi serverda: boshlangandan limit + 2 daqiqa; kech yoki
  /// takroriy topshirish — `invalid`.
  @override
  Future<GroupSubmission> submitAssignment(
    String assignmentId,
    List<int> answers,
  ) async {
    final r = await _call(
      'POST',
      '/v1/assignments/${_seg(assignmentId)}/submit',
      body: {'answers': answers},
      notFound: BackendFailure.forbidden,
    );
    return GroupSubmission.fromJson(r.map);
  }

  /// Talaba — faqat o'zi; ustoz — hamma; begona ustoz va admin — bo'sh.
  @override
  Future<List<GroupSubmission>> submissions(String assignmentId) async =>
      (await _list('/v1/assignments/${_seg(assignmentId)}/submissions'))
          .map(GroupSubmission.fromJson)
          .toList();

  @override
  Future<List<GroupSubmission>> groupSubmissions(String groupId) async =>
      (await _list('/v1/groups/${_seg(groupId)}/submissions'))
          .map(GroupSubmission.fromJson)
          .toList();

  @override
  Future<List<int>> assignmentKey(String assignmentId) async {
    final r = await _call(
      'GET',
      '/v1/assignments/${_seg(assignmentId)}/key',
      notFound: BackendFailure.forbidden,
    );
    return [
      for (final i in (r.map['correct_indexes'] as List? ?? const []))
        (i! as num).toInt(),
    ];
  }

  static String _seg(String v) => Uri.encodeComponent(v);

  // ------------------------------------------------------------------
  // TODO(port): quyidagilar Cloudflare serveriga hali ko'chirilmagan
  // (docs/BACKEND_CLOUDFLARE.md, “Reja”). Ishlayotgandek ko'rsatilmaydi.
  Never _notYet() => throw const BackendException(
    BackendFailure.unavailable,
    'not ported to cloudflare yet',
  );

  @override
  Future<List<SupportThread>> myThreads() async => _notYet();
  @override
  Future<List<SupportMessage>> messages(String threadId) async => _notYet();
  @override
  Future<String> createThread({
    required SupportKind kind,
    required String subject,
    required String body,
    SupportAttachment? attachment,
  }) async => _notYet();
  @override
  Future<void> postMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  }) async => _notYet();
  @override
  Future<void> markRead(String threadId) async => _notYet();
  @override
  Future<Uint8List> attachment(String path) async => _notYet();
  @override
  Future<AdminStats> adminStats() async => _notYet();
  @override
  Future<List<SupportThread>> adminThreads({SupportStatus? status}) async =>
      _notYet();
  @override
  Future<void> adminReply(String threadId, String body) async => _notYet();
  @override
  Future<void> adminSetStatus(String threadId, SupportStatus status) async =>
      _notYet();
  @override
  Future<void> adminMarkRead(String threadId) async => _notYet();
  @override
  Future<AdminUserPage> adminUsers({
    String? query,
    String? role,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async => _notYet();
  @override
  Future<String> adminRevealEmail(String userId) async => _notYet();
  @override
  Future<void> adminSetReviewer(String userId, {required bool enabled}) async =>
      _notYet();
  @override
  Future<List<AuditEntry>> adminAudit({int limit = 50}) async => _notYet();
  @override
  Future<void> submitReview({
    required String kind,
    required String itemId,
    required String contentVersion,
    required ReviewDecision decision,
    String? comment,
  }) async => _notYet();
  @override
  Future<List<ContentReview>> contentReviews() async => _notYet();

  // Hamkorlar: server qismi yo'q — reklama joylari umuman chiqmaydi.
  @override
  Future<List<Partner>> partners() async => const [];
  @override
  Future<int> trackPartnerEvents(List<PartnerEvent> events) async => 0;
  @override
  Future<String> createPartnerRequest(PartnerRequestDraft draft) async =>
      _notYet();
  @override
  Future<List<PartnerRequest>> myPartnerRequests() async => _notYet();
  @override
  Future<List<Partner>> adminPartners() async => _notYet();
  @override
  Future<String> adminSavePartner(PartnerDraft draft, {String? id}) async =>
      _notYet();
  @override
  Future<void> adminSetPartnerStatus(String id, PartnerStatus status) async =>
      _notYet();
  @override
  Future<String> adminUploadPartnerLogo(
    Uint8List bytes,
    String mimeType,
  ) async => _notYet();
  @override
  Future<List<PartnerDayStat>> adminPartnerStats(String id) async => _notYet();
  @override
  Future<List<PartnerRequest>> adminPartnerRequests({
    PartnerRequestStatus? status,
  }) async => _notYet();
  @override
  Future<void> adminUpdatePartnerRequest(
    String id, {
    required PartnerRequestStatus status,
    String? reply,
  }) async => _notYet();

  Future<void> dispose() async {
    await _sessionLost.close();
    _http.close();
  }
}
