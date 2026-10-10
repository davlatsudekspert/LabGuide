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
          'group_id': 'g1',
          'topic_id': 'day-01',
          'day_id': 'day-01',
          'opened_at': '2026-10-01T00:00:00.000Z',
          'lecture_done_at': '2026-10-01T01:00:00.000Z',
          'oral_done_at': null,
          'test_assignment_id': 'a1',
          'closed_at': null,
          'open': true,
        },
        {
          'group_id': 'g1',
          'topic_id': 'day-00',
          'opened_at': '2026-09-01T00:00:00.000Z',
          'closed_at': '2026-09-02T00:00:00.000Z',
          'open': false,
        },
      ]);
      final t = await backend.groupTopics('g1');
      expect(t.single.topicId, 'day-01', reason: 'yopilgan mavzu ko‘rinmaydi');
      expect(t.single.lectureDoneAt, isNotNull);
      expect(t.single.oralDoneAt, isNull);
      expect(t.single.testAssignmentId, 'a1');
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

  group('kontrakt: ustoz va mavzular (LabBackend)', () {
    setUp(signIn);

    Matcher fails(BackendFailure f) =>
        throwsA(isA<BackendException>().having((e) => e.failure, 'failure', f));

    test(
      'registerTeacher → POST /v1/me/teacher; sessiyasiz — unauthorized',
      () async {
        api.on('POST', '/v1/me/teacher', 200, {'teacher': true});
        await backend.registerTeacher();
        expect(api.last('/v1/me/teacher').method, 'POST');
        api.on('GET', '/v1/me', 200, {
          'admin_account': false,
          'aal': 'aal1',
          'reviewer': false,
          'teacher': true,
        });
        final a = await backend.myAccess();
        expect(a.teacher, isTrue);
        expect(a.admin, isFalse);
        await backend.signOut();
        await expectLater(
          backend.registerTeacher(),
          fails(BackendFailure.unauthorized),
        );
      },
    );

    test('a’zolar: taxallus va tartib raqami (GroupMember)', () async {
      api.on('GET', '/v1/groups/g1/members', 200, [
        {
          'user_id': 't',
          'member_role': 'teacher',
          'display_name': null,
          'seat_no': null,
          'label': 'Ustoz',
          'joined_at': '2026-10-10T09:00:00.000Z',
        },
        {
          'user_id': 's2',
          'member_role': 'student',
          'display_name': 'Yulduz',
          'seat_no': 2,
          'label': 'Yulduz',
          'joined_at': '2026-10-10T09:05:00.000Z',
        },
        {
          'user_id': 's1',
          'member_role': 'student',
          'display_name': null,
          'seat_no': 1,
          'label': 'Talaba 01',
          'joined_at': '2026-10-10T09:01:00.000Z',
        },
      ]);
      final m = await backend.groupMembers('g1');
      expect(m.first.isTeacher, isTrue);
      expect(m.first.seatNo, isNull);
      expect(m[1].alias, 'Yulduz');
      expect(m[1].seatNo, 2);
      expect(m.last.alias, isNull, reason: '"Talaba 01" — taxallus emas');
      expect(m.last.seatNo, 1);
      // Begona guruh (404) — bo'sh ro'yxat (RLS kabi).
      api.on('GET', '/v1/groups/g9/members', 404, {'error': 'not_found'});
      expect(await backend.groupMembers('g9'), isEmpty);
    });

    test(
      'setMyAlias: PUT /alias, bo‘sh — null; begona guruh — forbidden',
      () async {
        api.on('PUT', '/v1/groups/g1/alias', 200, {'alias': null});
        await backend.setMyAlias('g1', '   ');
        expect(jsonDecode(api.last('/v1/groups/g1/alias').body), {
          'alias': null,
        });
        await backend.setMyAlias('g1', ' Lola ');
        expect(jsonDecode(api.last('/v1/groups/g1/alias').body), {
          'alias': 'Lola',
        });
        api.on('PUT', '/v1/groups/g1/alias', 400, {
          'error': 'invalid_nickname',
        });
        await expectLater(
          backend.setMyAlias('g1', 'Y'),
          fails(BackendFailure.invalid),
        );
        expect(jsonDecode(api.last('/v1/groups/g1/alias').body), {
          'alias': 'Y',
        }, reason: 'qisqa taxallus jim tashlanmaydi — server rad etadi');
        api.on('PUT', '/v1/groups/g9/alias', 404, {'error': 'not_found'});
        await expectLater(
          backend.setMyAlias('g9', 'Lola'),
          fails(BackendFailure.forbidden),
        );
      },
    );

    test('mavzu: ochish, bosqich, test boshlash/yakunlash', () async {
      api.on('PUT', '/v1/groups/g1/topics/d008-L', 200, {});
      await backend.openTopic('g1', 'd008-L');
      api.on('PUT', '/v1/groups/g1/topics/bad%20id', 400, {
        'error': 'invalid_topic',
      });
      await expectLater(
        backend.openTopic('g1', 'bad id'),
        fails(BackendFailure.invalid),
      );
      api.on('POST', '/v1/groups/g1/topics/d008-L/stage', 200, {});
      await backend.markTopicStage('g1', 'd008-L', TopicStage.lecture);
      expect(jsonDecode(api.last('/v1/groups/g1/topics/d008-L/stage').body), {
        'stage': 'lecture',
      });
      await backend.markTopicStage('g1', 'd008-L', TopicStage.oral);
      expect(jsonDecode(api.last('/v1/groups/g1/topics/d008-L/stage').body), {
        'stage': 'oral',
      });

      api.on('POST', '/v1/groups/g1/topics/d008-L/test', 201, {
        'id': 'a7',
        'topic_id': 'd008-L',
        'status': 'open',
      });
      final id = await backend.startTopicTest(
        groupId: 'g1',
        topicId: 'd008-L',
        title: ' Test: buyrak ',
        questionIds: const ['kdl-t-031', 'creatinine-q1'],
        correctIndexes: const [1, 0],
        timeLimitMinutes: 15,
      );
      expect(id, 'a7');
      expect(jsonDecode(api.last('/v1/groups/g1/topics/d008-L/test').body), {
        'title': 'Test: buyrak',
        'question_ids': ['kdl-t-031', 'creatinine-q1'],
        'correct_indexes': [1, 0],
        'time_limit_minutes': 15,
      });
      api.on('POST', '/v1/groups/g1/topics/d008-L/test', 409, {
        'error': 'test_exists',
      });
      await expectLater(
        backend.startTopicTest(
          groupId: 'g1',
          topicId: 'd008-L',
          title: 'Ikkinchi',
          questionIds: const ['q1'],
          correctIndexes: const [0],
        ),
        fails(BackendFailure.invalid),
      );

      api.on('POST', '/v1/groups/g1/topics/d008-L/finish', 204);
      await backend.finishTopicTest('g1', 'd008-L');
      api.on('POST', '/v1/groups/g1/topics/d009-L/finish', 404, {
        'error': 'no_test',
      });
      await expectLater(
        backend.finishTopicTest('g1', 'd009-L'),
        fails(BackendFailure.notFound),
      );
    });

    test('begona ustoz / talaba: forbidden; ro‘yxatlar — bo‘sh', () async {
      // Worker a'zo bo'lmaganga 404 beradi (guruh borligi bildirilmaydi),
      // talabaga — 403. Ikkalasi ham kontraktda `forbidden`.
      for (final status in [403, 404]) {
        final body = {'error': status == 403 ? 'forbidden' : 'not_found'};
        api
          ..on('PUT', '/v1/groups/g2/topics/d1', status, body)
          ..on('POST', '/v1/groups/g2/topics/d1/stage', status, body)
          ..on('POST', '/v1/groups/g2/topics/d1/test', status, body)
          ..on('POST', '/v1/groups/g2/topics/d1/finish', status, body)
          ..on('POST', '/v1/groups/g2/assignments', status, body)
          ..on('DELETE', '/v1/groups/g2/members/u9', status, body)
          ..on('POST', '/v1/assignments/a2/start', status, body)
          ..on('POST', '/v1/assignments/a2/submit', status, body)
          ..on('GET', '/v1/assignments/a2/key', status, body);
        final calls = <Future<Object?> Function()>[
          () => backend.openTopic('g2', 'd1'),
          () => backend.markTopicStage('g2', 'd1', TopicStage.lecture),
          () => backend.startTopicTest(
            groupId: 'g2',
            topicId: 'd1',
            title: 'Test',
            questionIds: const ['q1'],
            correctIndexes: const [0],
          ),
          () => backend.finishTopicTest('g2', 'd1'),
          () => backend.createAssignment(
            groupId: 'g2',
            title: 'Test',
            questionIds: const ['q1'],
            correctIndexes: const [0],
          ),
          () => backend.removeMember('g2', 'u9'),
          () => backend.startAssignment('a2'),
          () => backend.submitAssignment('a2', const [0]),
          () => backend.assignmentKey('a2'),
        ];
        for (final (i, run) in calls.indexed) {
          await expectLater(
            run(),
            fails(BackendFailure.forbidden),
            reason: '$status #$i',
          );
        }
      }
      for (final p in [
        '/v1/groups/g2/topics',
        '/v1/groups/g2/assignments',
        '/v1/groups/g2/submissions',
        '/v1/assignments/a2/submissions',
      ]) {
        api.on('GET', p, 404, {'error': 'not_found'});
      }
      expect(await backend.groupTopics('g2'), isEmpty);
      expect(await backend.assignments('g2'), isEmpty);
      expect(await backend.groupSubmissions('g2'), isEmpty);
      expect(await backend.submissions('a2'), isEmpty);
    });

    test('topshiriq: topic_id, vaqt; kech topshirish — invalid', () async {
      api.on('GET', '/v1/groups/g1/assignments', 200, [
        {
          'id': 'a7',
          'group_id': 'g1',
          'title': 'Test: buyrak',
          'day_id': 'd008-L',
          'topic_id': 'd008-L',
          'question_ids': ['q1', 'q2'],
          'time_limit_minutes': 15,
          'due_at': null,
          'status': 'open',
          'created_at': '2026-10-10T09:00:00.000Z',
        },
      ]);
      final a = (await backend.assignments('g1')).single;
      expect(a.topicId, 'd008-L');
      expect(a.timeLimitMinutes, 15);
      for (final e in [
        'time_over',
        'past_due',
        'closed',
        'already_submitted',
      ]) {
        api.on('POST', '/v1/assignments/a7/submit', 409, {'error': e});
        await expectLater(
          backend.submitAssignment('a7', const [1, 1]),
          fails(BackendFailure.invalid),
          reason: e,
        );
      }
      api.on('POST', '/v1/assignments/a7/start', 409, {'error': 'not_open'});
      await expectLater(
        backend.startAssignment('a7'),
        fails(BackendFailure.invalid),
      );
    });

    test(
      'guruh limitlari: 10 guruh / 200 a’zo / 300 mavzu — rateLimited',
      () async {
        api
          ..on('POST', '/v1/groups', 429, {'error': 'limit_groups'})
          ..on('POST', '/v1/groups/join', 429, {'error': 'group_full'})
          ..on('PUT', '/v1/groups/g1/topics/d1', 429, {
            'error': 'limit_topics',
          });
        await expectLater(
          backend.createGroup('Guruh'),
          fails(BackendFailure.rateLimited),
        );
        await expectLater(
          backend.joinGroup('ABCD2345'),
          fails(BackendFailure.rateLimited),
        );
        await expectLater(
          backend.openTopic('g1', 'd1'),
          fails(BackendFailure.rateLimited),
        );
      },
    );

    test(
      'a’zo bo‘lmagan guruhdan chiqish va chiqarilgan talaba — xato emas',
      () async {
        api
          ..on('POST', '/v1/groups/g9/leave', 404, {'error': 'not_found'})
          ..on('DELETE', '/v1/groups/g1/members/u9', 404, {
            'error': 'member_not_found',
          });
        await backend.leaveGroup('g9');
        await backend.removeMember('g1', 'u9');
      },
    );

    test('tarmoq/server xatolari: network, unavailable', () async {
      api.on('GET', '/v1/groups', 502, null);
      await expectLater(backend.myGroups(), fails(BackendFailure.network));
      api.on('GET', '/v1/groups', 503, {'error': 'not_configured'});
      await expectLater(backend.myGroups(), fails(BackendFailure.unavailable));
      api.offline = true;
      await expectLater(
        backend.groupTopics('g1'),
        fails(BackendFailure.network),
      );
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
