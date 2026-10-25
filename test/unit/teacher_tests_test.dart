// Ustoz Pro modellari, tekshiruv (server bilan bir xil cheklovlar), HTTP
// mijoz yo'llari va lokal kesh.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/cloudflare_teacher_tests.dart';
import 'package:labguide/core/backend/teacher_tests.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/teacher_pro/teacher_test_cache.dart';

TtQuestion _q({
  String text = 'Savol',
  List<String> options = const ['A', 'B', 'C'],
  int correct = 0,
  String? explanation,
}) => TtQuestion(
  text: text,
  options: options,
  correct: correct,
  explanation: explanation,
);

void main() {
  group('cheklovlar serverdagi TT_LIMITS bilan bir xil', () {
    test('cloudflare/src/teachertests.ts', () {
      final src = File('cloudflare/src/teachertests.ts').readAsStringSync();
      int limit(String name) =>
          int.parse(RegExp('\\b$name: (\\d+),').firstMatch(src)!.group(1)!);
      expect(limit('questions'), TeacherTestLimits.questions);
      expect(limit('titleMin'), TeacherTestLimits.titleMin);
      expect(limit('titleMax'), TeacherTestLimits.titleMax);
      expect(limit('description'), TeacherTestLimits.description);
      expect(limit('text'), TeacherTestLimits.text);
      expect(limit('option'), TeacherTestLimits.option);
      expect(limit('optionsMin'), TeacherTestLimits.optionsMin);
      expect(limit('optionsMax'), TeacherTestLimits.optionsMax);
      expect(limit('explanation'), TeacherTestLimits.explanation);
      expect(limit('maxAttempts'), TeacherTestLimits.maxAttempts);
      expect(limit('inviteUses'), TeacherTestLimits.inviteUses);
      expect(limit('inviteDays'), TeacherTestLimits.inviteDays);
    });

    test(
      'gate: Ustoz Pro funksiyalari qurilgan va yopiladi; toifalar to‘g‘ri',
      () {
        expect(
          ProGatePolicy.gated,
          containsAll(<Feature>{
            Feature.teacherTests,
            Feature.teacherTestBuilder,
            Feature.teacherTestAssign,
            Feature.teacherResults,
          }),
        );
        expect(Feature.teacherTests.capability, ProCapability.learner);
        for (final f in [
          Feature.teacherTestBuilder,
          Feature.teacherTestAssign,
          Feature.teacherResults,
        ]) {
          expect(f.capability, ProCapability.teacherPanel, reason: f.name);
        }
      },
    );
  });

  group('savol tekshiruvi', () {
    test('to‘g‘ri savol', () => expect(_q().validate(), isNull));
    test('matn', () {
      expect(_q(text: '  ').validate(), 'invalid_question_text');
      expect(_q(text: 'x' * 1001).validate(), 'invalid_question_text');
    });
    test('variantlar 2–6, bo‘sh/uzun emas, takrorsiz', () {
      expect(_q(options: ['A']).validate(), 'invalid_options');
      expect(
        _q(options: List.generate(7, (i) => '$i')).validate(),
        'invalid_options',
      );
      expect(_q(options: ['A', ' ']).validate(), 'invalid_options');
      expect(_q(options: ['A', 'b' * 301]).validate(), 'invalid_options');
      expect(_q(options: ['Qon', 'qon']).validate(), 'duplicate_options');
      expect(_q(options: List.generate(6, (i) => '$i')).validate(), isNull);
    });
    test('kalit va izoh', () {
      expect(_q(correct: 3).validate(), 'invalid_correct');
      expect(_q(correct: -1).validate(), 'invalid_correct');
      expect(_q(explanation: 'e' * 1001).validate(), 'invalid_explanation');
    });
  });

  group('test tekshiruvi', () {
    TeacherTestInput input({
      String title = 'Nazorat testi',
      List<TtQuestion>? questions,
      bool published = true,
      int? limit,
      int? pass,
    }) => TeacherTestInput(
      title: title,
      questions: questions ?? [_q()],
      published: published,
      timeLimitMinutes: limit,
      passPercent: pass,
    );
    test('nom, nashr, vaqt, o‘tish chegarasi, savollar', () {
      expect(input().validate(), isNull);
      expect(input(title: 'ab').validate(), 'invalid_title');
      expect(input(questions: const []).validate(), 'no_questions');
      expect(input(questions: const [], published: false).validate(), isNull);
      expect(input(limit: 0).validate(), 'invalid_time_limit');
      expect(input(limit: 181).validate(), 'invalid_time_limit');
      expect(input(pass: 101).validate(), 'invalid_pass_percent');
      expect(
        input(questions: List.generate(101, (i) => _q(text: 'S$i'))).validate(),
        'invalid_questions',
      );
      expect(input(questions: [_q(correct: 9)]).validate(), 'invalid_correct');
    });
    test('JSON tanasi: holat, versiya, manba', () {
      final j = TeacherTestInput(
        title: ' Nom ',
        description: '  ',
        questions: [
          const TtQuestion(
            text: 'S',
            options: ['A', 'B'],
            correct: 1,
            source: TtSource(TtBank.toifa, 'tf.12'),
          ),
        ],
        published: false,
        version: 4,
      ).toJson();
      expect(j['title'], 'Nom');
      expect(j.containsKey('description'), isFalse);
      expect(j['status'], 'unpublished');
      expect(j['version'], 4);
      expect((j['questions']! as List).single, {
        'text': 'S',
        'options': ['A', 'B'],
        'correct': 1,
        'source': {'bank': 'toifa', 'id': 'tf.12'},
      });
    });
  });

  group('taklifnoma kodi', () {
    test('normallashtirish va ko‘rinish', () {
      expect(TtInviteCode.normalize('abcd-efgh-jklm'), 'ABCDEFGHJKLM');
      expect(TtInviteCode.normalize(' ABCD EFGH JKLM '), 'ABCDEFGHJKLM');
      expect(TtInviteCode.normalize('ABCDEFGHJKL0'), isNull, reason: '0 yo‘q');
      expect(
        TtInviteCode.normalize('ABCDEFGH'),
        isNull,
        reason: 'guruh kodi emas',
      );
      expect(TtInviteCode.format('ABCDEFGHJKLM'), 'ABCD-EFGH-JKLM');
      expect(
        TtInviteCode.appLink('ABCDEFGHJKLM'),
        'labguide://app/ti?t=ABCDEFGHJKLM',
      );
    });
  });

  group('JSON (server javoblari)', () {
    test('talaba testi: holat, boshlangan urinish, birinchi topshirish', () {
      final t = StudentTeacherTest.fromJson({
        'id': 'a1',
        'title': 'T',
        'group_id': 'g1',
        'group_name': 'G',
        'question_count': 3,
        'max_attempts': 2,
        'attempts_used': 1,
        'due_at': '2026-11-01T10:00:00.000Z',
        'late_policy': 'accept',
        'status': 'active',
        'state': 'started',
        'can_start': false,
        'open_attempt_id': 'x1',
        'attempts': [
          {'id': 'x1', 'attempt_no': 1, 'status': 'started', 'total': 3},
        ],
      });
      expect(t.state, TtState.started);
      expect(t.inProgress, isTrue);
      expect(t.acceptLate, isTrue);
      expect(t.firstSubmission, isTrue);
      final done = StudentTeacherTest.fromJson({
        'id': 'a1',
        'title': 'T',
        'group_id': 'g1',
        'due_at': '2026-11-01T10:00:00.000Z',
        'state': 'submitted',
        'attempts': [
          {
            'id': 'x1',
            'status': 'submitted',
            'score': 2,
            'total': 3,
            'percent': 67,
            'review': [
              {
                'text': 'S',
                'options': ['A', 'B'],
                'answer': -1,
                'correct': 1,
              },
            ],
          },
        ],
      });
      expect(done.firstSubmission, isFalse);
      expect(done.attempts.single.review!.single.answer, -1);
    });

    test('natijalar', () {
      final r = TtResults.fromJson({
        'assignment': {
          'id': 'a',
          'test_id': 't',
          'group_id': 'g',
          'title': 'T',
          'question_count': 2,
          'max_attempts': 1,
          'due_at': '2026-11-01T10:00:00.000Z',
          'late_policy': 'reject',
          'status': 'closed',
        },
        'summary': {
          'targets': 3,
          'started': 2,
          'submitted': 1,
          'average_percent': 50,
        },
        'students': [
          {
            'user_id': 'u',
            'seat_no': 1,
            'state': 'submitted',
            'attempts': 1,
            'best_score': 1,
            'total': 2,
            'late': true,
          },
        ],
        'questions': [
          {
            'index': 0,
            'text': 'S',
            'options': ['A', 'B'],
            'correct': 0,
            'answered': 1,
            'right': 0,
            'attempts': 1,
            'correct_percent': 0,
            'chosen': [0, 1],
          },
        ],
        'most_missed': [0],
      });
      expect(r.assignment.closed, isTrue);
      expect(r.targets, 3);
      expect(r.students.single.late, isTrue);
      expect(r.questions.single.chosen, [0, 1]);
      expect(r.mostMissed, [0]);
    });

    test('xato kodlari: reja kerak', () {
      expect(
        const BackendException(
          BackendFailure.forbidden,
          '',
          'tier_insufficient',
        ).planNeeded,
        isTrue,
      );
      expect(
        const BackendException(
          BackendFailure.forbidden,
          '',
          'teacher_role_required',
        ).planNeeded,
        isFalse,
      );
    });
  });

  group('HTTP mijoz: yo‘llar va tanalar (server app.ts bilan)', () {
    test('har amal to‘g‘ri yo‘lga', () async {
      final calls = <String>[];
      final bodies = <String, Object?>{};
      const assignment = {
        'id': 'a1',
        'test_id': 't1',
        'group_id': 'g1',
        'title': 'T',
        'due_at': '2026-11-01T10:00:00.000Z',
      };
      Object? reply(String method, String path) {
        if (path.endsWith('/export')) {
          return {'filename': 'f.csv', 'csv': 'a,b'};
        }
        if (method == 'GET' &&
            (path == '/v1/teacher/tests' ||
                path == '/v1/teacher/assignments' ||
                path.endsWith('/invites') ||
                path == '/v1/me/teacher-tests')) {
          return const [];
        }
        if (path.endsWith('/results')) return {'assignment': assignment};
        if (path == '/v1/me/teacher-tests/a1') return assignment;
        if (path.contains('/assignments') &&
            method == 'POST' &&
            path.startsWith('/v1/teacher/tests/')) {
          return {
            'id': 'a1',
            'test_id': 't1',
            'group_id': 'g1',
            'title': 'T',
            'due_at': '2026-11-01T10:00:00.000Z',
          };
        }
        if (path.startsWith('/v1/teacher-invites/') &&
            path.endsWith('/accept')) {
          return {'group_id': 'g1'};
        }
        if (path.endsWith('/start')) {
          return {
            'attempt_id': 'x1',
            'started_at': '2026-11-01T09:00:00.000Z',
            'server_now': '2026-11-01T09:00:00.000Z',
            'questions': [
              {
                'text': 'S',
                'options': ['A', 'B'],
              },
            ],
          };
        }
        if (path.endsWith('/submit')) {
          return {'id': 'x1', 'status': 'submitted', 'total': 1};
        }
        return {
          'id': 'z',
          'title': 'T',
          'question_count': 0,
          'status': 'published',
          'group_id': 'g1',
          'token': 'ABCDEFGHJKLM',
          'expires_at': '2026-11-01T10:00:00.000Z',
          'group_name': 'G',
        };
      }

      final api = CloudflareTeacherTests((method, path, {body, query}) async {
        final key =
            '$method $path${query == null ? '' : '?${Uri(queryParameters: query).query}'}';
        calls.add(key);
        bodies[key] = body;
        return reply(method, path);
      });
      final input = TeacherTestInput(
        title: 'Nom',
        questions: [_q()],
        published: true,
      );
      await api.teacherTests();
      await api.createTeacherTest(input);
      await api.teacherTest('t 1');
      await api.updateTeacherTest('t1', input);
      await api.deleteTeacherTest('t1');
      await api.assignTeacherTest(
        't1',
        groupId: 'g1',
        userId: 'u1',
        dueAt: DateTime.utc(2026, 11, 1, 10),
        maxAttempts: 2,
        acceptLate: true,
      );
      await api.teacherAssignments(testId: 't1');
      await api.closeTeacherAssignment('a1');
      await api.deleteTeacherAssignment('a1');
      await api.teacherResults('a1');
      await api.exportTeacherResults('a1');
      await api.groupInvites('g1');
      await api.createInvite('g1', maxUses: 5, days: 3);
      await api.revokeInvite('i1');
      await api.previewInvite('ABCDEFGHJKLM');
      await api.acceptInvite('ABCDEFGHJKLM', displayName: ' Ali ');
      await api.myTeacherTests();
      await api.myTeacherTest('a1');
      await api.startTeacherTest('a1');
      await api.submitTeacherTest('a1', attemptId: 'x1', answers: [1, -1]);
      expect(calls, [
        'GET /v1/teacher/tests',
        'POST /v1/teacher/tests',
        'GET /v1/teacher/tests/t%201',
        'PUT /v1/teacher/tests/t1',
        'DELETE /v1/teacher/tests/t1',
        'POST /v1/teacher/tests/t1/assignments',
        'GET /v1/teacher/assignments?test_id=t1',
        'POST /v1/teacher/assignments/a1/close',
        'DELETE /v1/teacher/assignments/a1',
        'GET /v1/teacher/assignments/a1/results',
        'GET /v1/teacher/assignments/a1/export',
        'GET /v1/teacher/groups/g1/invites',
        'POST /v1/teacher/groups/g1/invites',
        'DELETE /v1/teacher/invites/i1',
        'GET /v1/teacher-invites/ABCDEFGHJKLM',
        'POST /v1/teacher-invites/ABCDEFGHJKLM/accept',
        'GET /v1/me/teacher-tests',
        'GET /v1/me/teacher-tests/a1',
        'POST /v1/me/teacher-tests/a1/start',
        'POST /v1/me/teacher-tests/a1/submit',
      ]);
      expect(bodies['POST /v1/teacher/tests/t1/assignments'], {
        'group_id': 'g1',
        'user_id': 'u1',
        'due_at': '2026-11-01T10:00:00.000Z',
        'max_attempts': 2,
        'late_policy': 'accept',
      });
      expect(bodies['POST /v1/teacher-invites/ABCDEFGHJKLM/accept'], {
        'consent': true,
        'display_name': 'Ali',
      });
      expect(bodies['POST /v1/me/teacher-tests/a1/submit'], {
        'attempt_id': 'x1',
        'answers': [1, -1],
      });
      // Har yo'l serverda e'lon qilingan.
      final app = File('cloudflare/src/app.ts').readAsStringSync();
      for (final p in [
        "'/v1/teacher/tests'",
        "'/v1/teacher/tests/:t'",
        "'/v1/teacher/tests/:t/assignments'",
        "'/v1/teacher/assignments'",
        "'/v1/teacher/assignments/:a/close'",
        "'/v1/teacher/assignments/:a/results'",
        "'/v1/teacher/assignments/:a/export'",
        "'/v1/teacher/groups/:g/invites'",
        "'/v1/teacher/invites/:i'",
        "'/v1/teacher-invites/:t'",
        "'/v1/teacher-invites/:t/accept'",
        "'/v1/me/teacher-tests'",
        "'/v1/me/teacher-tests/:a'",
        "'/v1/me/teacher-tests/:a/start'",
        "'/v1/me/teacher-tests/:a/submit'",
      ]) {
        expect(app, contains(p));
      }
      // ...va faqat `billingRoutes` ichida (bayroq o'chiq — 404).
      final billing = app.substring(
        app.indexOf('const billingRoutes'),
        app.indexOf('export { billingEnabled }'),
      );
      expect(app.replaceFirst(billing, '').contains('/v1/teacher'), isFalse);
      expect(app.replaceFirst(billing, '').contains('teacher-tests'), isFalse);
    });
  });

  group('lokal kesh', () {
    test(
      'ro‘yxat foydalanuvchiga bog‘liq; javoblar urinish bo‘yicha',
      () async {
        final store = MemoryKeyValueStore();
        final c = TeacherTestCache(store);
        const t = TeacherTest(
          id: 't1',
          title: 'T',
          questionCount: 1,
          published: true,
          version: 2,
          questions: [
            TtQuestion(text: 'S', options: ['A', 'B'], correct: 1),
          ],
        );
        await c.saveTests('u1', [t]);
        expect(c.tests('u2'), isNull);
        expect(c.tests(null), isNull);
        expect(c.test('u1', 't1')!.questions!.single.correct, 1);
        await c.putTest(
          'u1',
          const TeacherTest(
            id: 't2',
            title: 'B',
            questionCount: 0,
            published: false,
            version: 1,
          ),
        );
        expect(c.tests('u1')!.map((x) => x.id), ['t2', 't1']);
        await c.removeTest('u1', 't1');
        expect(c.tests('u1')!.map((x) => x.id), ['t2']);
        await c.saveAnswers('x1', [1, -1, 0]);
        expect(c.answers('x1', 3), [1, -1, 0]);
        expect(c.answers('x1', 4), isNull, reason: 'uzunlik mos emas');
        await c.clearAnswers('x1');
        expect(c.answers('x1', 3), isNull);
        // Faqat oxirgi 20 ta ochiq urinish saqlanadi.
        for (var i = 0; i < 25; i++) {
          await c.saveAnswers('y$i', [i]);
        }
        expect(c.answers('y0', 1), isNull);
        expect(c.answers('y24', 1), [24]);
        expect(
          StoreKeys.all,
          containsAll([
            StoreKeys.teacherTestsCache,
            StoreKeys.teacherTestAnswers,
          ]),
        );
        // "Lokal ma'lumotni o'chirish" — hammasi tozalanadi.
        await store.clear();
        expect(c.tests('u1'), isNull);
      },
    );
  });
}
