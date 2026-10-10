import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/cloudflare_backend.dart';
import 'package:labguide/core/backend/supabase_backend.dart'
    show MemorySessionStore;
import 'package:labguide/features/auth/otp_auth.dart';

/// Cloudflare Worker javoblarini taqlid qiluvchi soxta HTTP server.
class _FakeApi {
  final requests = <http.Request>[];
  final responses = <String, (int, Object?)>{};
  bool offline = false;

  void on(String method, String path, int status, [Object? body]) =>
      responses['$method $path'] = (status, body);

  late final client = MockClient((r) async {
    requests.add(r);
    if (offline) throw http.ClientException('offline');
    final hit = responses['${r.method} ${r.url.path}'];
    if (hit == null) return http.Response('{"error":"not_found"}', 404);
    final (status, body) = hit;
    return http.Response(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
  });

  http.Request last(String path) =>
      requests.lastWhere((r) => r.url.path == path);
}

void main() {
  const config = ApiConfig(url: 'https://api.example.test/');
  late _FakeApi api;
  late MemorySessionStore store;
  late CloudflareLabBackend backend;
  final now = DateTime.utc(2026, 10, 10, 12);

  setUp(() {
    api = _FakeApi();
    store = MemorySessionStore();
    backend = CloudflareLabBackend(
      config,
      sessionStore: store,
      httpClient: api.client,
      clock: () => now,
    );
  });

  Future<void> signIn() async {
    api.on('POST', '/v1/auth/otp/verify', 200, {
      'token': 'tok-1',
      'user_id': 'u-1',
      'expires_at': '2026-12-01T00:00:00.000Z',
    });
    final r = await backend.verifyCode('A@Example.com', '123456');
    expect(r.status, OtpVerifyStatus.verified);
  }

  group('ApiConfig', () {
    test('faqat https URL sozlangan hisoblanadi', () {
      expect(const ApiConfig(url: '').isConfigured, isFalse);
      expect(const ApiConfig(url: 'http://x.dev').isConfigured, isFalse);
      expect(const ApiConfig(url: 'https://x.dev').isConfigured, isTrue);
      expect(
        config.resolve('/v1/me').toString(),
        'https://api.example.test/v1/me',
      );
    });

    test('LG_API_URL berilmagan testda sozlanmagan', () {
      expect(ApiConfig.fromEnvironment.isConfigured, isFalse);
    });
  });

  group('OTP', () {
    test("kod so'rovi: email normallashadi, javob holatga aylanadi", () async {
      api.on('POST', '/v1/auth/otp/request', 200, {
        'status': 'sent',
        'retry_after': 60,
        'valid_for': 600,
      });
      final r = await backend.requestCode('  Lab.User@Example.COM ');
      expect(r.status, OtpRequestStatus.sent);
      expect(r.validFor, const Duration(minutes: 10));
      expect(r.retryAfter, const Duration(seconds: 60));
      final req = api.last('/v1/auth/otp/request');
      expect(jsonDecode(req.body), {'email': 'lab.user@example.com'});
      expect(req.headers.containsKey('authorization'), isFalse);
    });

    test("noto'g'ri email tarmoqqa chiqmaydi", () async {
      expect(
        (await backend.requestCode('nope')).status,
        OtpRequestStatus.invalidEmail,
      );
      expect(api.requests, isEmpty);
    });

    test(
      '429 → rateLimited (retry_after), 503 → unavailable, tarmoq → failed',
      () async {
        api.on('POST', '/v1/auth/otp/request', 429, {
          'error': 'rate_limited',
          'retry_after': 37,
        });
        final r = await backend.requestCode('a@example.com');
        expect(r.status, OtpRequestStatus.rateLimited);
        expect(r.retryAfter, const Duration(seconds: 37));
        api.on('POST', '/v1/auth/otp/request', 503, {
          'error': 'not_configured',
        });
        expect(
          (await backend.requestCode('a@example.com')).status,
          OtpRequestStatus.unavailable,
        );
        api.offline = true;
        expect(
          (await backend.requestCode('a@example.com')).status,
          OtpRequestStatus.failed,
        );
      },
    );

    test('tasdiqlash xatolari', () async {
      final cases = <(int, Map<String, Object?>, OtpVerifyStatus)>[
        (
          400,
          {'error': 'invalid_code', 'attempts_left': 3},
          OtpVerifyStatus.invalidCode,
        ),
        (400, {'error': 'expired'}, OtpVerifyStatus.expired),
        (400, {'error': 'no_active_code'}, OtpVerifyStatus.noActiveCode),
        (429, {'error': 'too_many_attempts'}, OtpVerifyStatus.tooManyAttempts),
        (500, {'error': 'internal'}, OtpVerifyStatus.failed),
      ];
      for (final (status, body, expected) in cases) {
        api.on('POST', '/v1/auth/otp/verify', status, body);
        final r = await backend.verifyCode('a@example.com', '111111');
        expect(r.status, expected, reason: '$body');
        if (expected == OtpVerifyStatus.invalidCode) {
          expect(r.attemptsLeft, 3);
        }
      }
      expect(backend.hasSession, isFalse);
      expect(store.value, isNull);
    });

    test(
      'muvaffaqiyat: token xavfsiz omborda, keyingi so‘rovlarda Bearer',
      () async {
        await signIn();
        expect(backend.hasSession, isTrue);
        expect(backend.sessionEmail, 'a@example.com');
        expect(backend.userId, 'u-1');
        expect(jsonDecode(store.value!), containsPair('token', 'tok-1'));
        api.on('GET', '/v1/me', 200, {
          'admin_account': false,
          'aal': 'aal1',
          'reviewer': false,
        });
        final access = await backend.myAccess();
        expect(access.admin, isFalse);
        expect(api.last('/v1/me').headers['authorization'], 'Bearer tok-1');
      },
    );
  });

  group('sessiya', () {
    test(
      'qayta ochilganda tiklanadi (tarmoqsiz), muddati o‘tgani o‘chadi',
      () async {
        await signIn();
        final reopened = CloudflareLabBackend(
          config,
          sessionStore: store,
          httpClient: api.client,
          clock: () => now,
        );
        final before = api.requests.length;
        await reopened.restoreSession();
        expect(reopened.hasSession, isTrue);
        expect(reopened.sessionEmail, 'a@example.com');
        expect(api.requests.length, before);

        final late = CloudflareLabBackend(
          config,
          sessionStore: store,
          httpClient: api.client,
          clock: () => DateTime.utc(2027),
        );
        await late.restoreSession();
        expect(late.hasSession, isFalse);
        expect(store.value, isNull);
      },
    );

    test('server 401 → sessiya o‘chadi va sessionLost', () async {
      await signIn();
      api.on('GET', '/v1/groups', 401, {'error': 'unauthorized'});
      final lost = expectLater(backend.sessionLost, emits(null));
      await expectLater(
        backend.myGroups(),
        throwsA(
          isA<BackendException>().having(
            (e) => e.failure,
            'failure',
            BackendFailure.unauthorized,
          ),
        ),
      );
      await lost;
      expect(backend.hasSession, isFalse);
      expect(store.value, isNull);
    });

    test('chiqish internetsiz ham qurilmadagi sessiyani o‘chiradi', () async {
      await signIn();
      api.offline = true;
      await backend.signOut();
      expect(backend.hasSession, isFalse);
      expect(store.value, isNull);
    });

    test('hisobni o‘chirish → DELETE /v1/me va sessiya tozalanadi', () async {
      await signIn();
      api.on('DELETE', '/v1/me', 204);
      await backend.deleteAccount();
      expect(api.last('/v1/me').method, 'DELETE');
      expect(backend.hasSession, isFalse);
    });

    test('sessiyasiz himoyalangan so‘rov tarmoqqa chiqmaydi', () async {
      await expectLater(backend.myGroups(), throwsA(isA<BackendException>()));
      expect(api.requests, isEmpty);
      expect(await backend.myAccess(), AccessInfo.none);
    });
  });

  group('guruhlar', () {
    setUp(signIn);

    test("ro'yxat, yaratish va qo'shilish (taxallus ixtiyoriy)", () async {
      api.on('GET', '/v1/groups', 200, [
        {
          'id': 'g1',
          'name': 'Gematologiya',
          'join_code': 'ABCD2345',
          'is_teacher': true,
          'member_count': 4,
        },
        {
          'id': 'g2',
          'name': 'Biokimyo',
          'join_code': null,
          'is_teacher': false,
          'member_count': 9,
        },
      ]);
      final gs = await backend.myGroups();
      expect(gs.first.joinCode, 'ABCD2345');
      expect(gs.last.isTeacher, isFalse);
      expect(gs.last.joinCode, isNull);

      api.on('POST', '/v1/groups', 201, {
        'id': 'g3',
        'name': 'Yangi',
        'join_code': 'ZXCV2345',
        'is_teacher': true,
        'member_count': 1,
      });
      final g = await backend.createGroup(' Yangi ', displayName: ' ');
      expect(g.joinCode, 'ZXCV2345');
      expect(jsonDecode(api.last('/v1/groups').body), {
        'name': 'Yangi',
        'display_name': null,
      });

      api.on('POST', '/v1/groups/join', 201, {'group_id': 'g9'});
      expect(await backend.joinGroup('abcd 2345', displayName: 'Lola'), 'g9');
      expect(jsonDecode(api.last('/v1/groups/join').body), {
        'code': 'abcd 2345',
        'display_name': 'Lola',
      });
    });

    test('xato kodlari BackendFailure ga aylanadi', () async {
      final cases = {
        403: BackendFailure.forbidden,
        404: BackendFailure.notFound,
        409: BackendFailure.invalid,
        429: BackendFailure.rateLimited,
        501: BackendFailure.unavailable,
        500: BackendFailure.unknown,
      };
      for (final MapEntry(key: status, value: failure) in cases.entries) {
        api.on('POST', '/v1/groups', status, {'error': 'x'});
        await expectLater(
          backend.createGroup('Guruh'),
          throwsA(
            isA<BackendException>().having((e) => e.failure, 'f', failure),
          ),
          reason: '$status',
        );
      }
    });

    test('test sessiyasi: yaratish, boshlash, topshirish, natija', () async {
      api.on('POST', '/v1/groups/g1/assignments', 201, {'id': 'a1'});
      final id = await backend.createAssignment(
        groupId: 'g1',
        title: 'Kun 3',
        questionIds: const ['q1', 'q2'],
        correctIndexes: const [1, 0],
        timeLimitMinutes: 10,
        dayId: 'day-03',
        start: false,
      );
      expect(id, 'a1');
      final body = jsonDecode(
        api.last('/v1/groups/g1/assignments').body,
      ) as Map<String, Object?>;
      expect(body['start'], isFalse);
      expect(body['day_id'], 'day-03');

      api.on('POST', '/v1/assignments/a1/open', 200, {'status': 'open'});
      await backend.openAssignment('a1');
      api.on('POST', '/v1/assignments/a1/start', 200, {
        'started_at': '2026-10-10T12:00:00.000Z',
        'server_now': '2026-10-10T12:00:01.000Z',
      });
      final st = await backend.startAssignment('a1');
      expect(st.serverNow.isAfter(st.startedAt), isTrue);
      api.on('POST', '/v1/assignments/a1/submit', 201, {
        'assignment_id': 'a1',
        'user_id': 'u-1',
        'score': 1,
        'total': 2,
        'answers': [1, 1],
        'correct': [true, false],
        'submitted_at': '2026-10-10T12:05:00.000Z',
      });
      final sub = await backend.submitAssignment('a1', const [1, 1]);
      expect(sub.percent, 50);
      expect(sub.correct, [true, false]);
      api.on('POST', '/v1/assignments/a1/close', 200, {'status': 'closed'});
      await backend.closeAssignment('a1');
      api.on('GET', '/v1/assignments/a1/key', 403, {'error': 'forbidden'});
      await expectLater(
        backend.assignmentKey('a1'),
        throwsA(
          isA<BackendException>().having(
            (e) => e.failure,
            'f',
            BackendFailure.forbidden,
          ),
        ),
      );
    });

    test('mavzular va belgilar', () async {
      api.on('GET', '/v1/groups/g1/topics', 200, [
        {
          'day_id': 'day-01',
          'opened_at': '2026-10-01T00:00:00.000Z',
          'closed_at': null,
        },
      ]);
      final t = await backend.topics('g1');
      expect(t.single.isOpen, isTrue);
      api.on('PUT', '/v1/groups/g1/topics/day-02', 200, {'day_id': 'day-02'});
      await backend.openTopic('g1', 'day-02');
      api.on('PUT', '/v1/groups/g1/marks', 200, {'id': 'm1'});
      final id = await backend.putMark(
        'g1',
        userId: 'u-2',
        dayId: 'day-02',
        questionId: 'q1',
        result: QaResult.partial,
        grade: 4,
      );
      expect(id, 'm1');
      expect(
        jsonDecode(api.last('/v1/groups/g1/marks').body),
        containsPair('result', 'partial'),
      );
      api.on('GET', '/v1/groups/g1/marks', 200, [
        {
          'id': 'm1',
          'user_id': 'u-2',
          'day_id': 'day-02',
          'question_id': 'q1',
          'result': 'partial',
          'grade': 4,
          'marked_at': '2026-10-10T12:00:00.000Z',
        },
      ]);
      final ms = await backend.marks('g1', dayId: 'day-02');
      expect(ms.single.grade, 4);
      expect(api.last('/v1/groups/g1/marks').url.queryParameters, {
        'day_id': 'day-02',
      });
    });
  });

  test("ko'chirilmagan bo'limlar — unavailable, hamkorlar bo'sh", () async {
    await signIn();
    await expectLater(
      backend.myThreads(),
      throwsA(
        isA<BackendException>().having(
          (e) => e.failure,
          'f',
          BackendFailure.unavailable,
        ),
      ),
    );
    await expectLater(backend.adminStats(), throwsA(isA<BackendException>()));
    expect(await backend.partners(), isEmpty);
    expect(await backend.trackPartnerEvents(const []), 0);
  });
}
