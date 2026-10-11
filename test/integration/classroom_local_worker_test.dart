// Haqiqiy HTTP: CloudflareLabBackend -> mahalliy Worker (wrangler dev --local,
// cloudflare/dev/local.ts; xat yuborilmaydi, kodlar GET /__outbox dan olinadi).
//
//   cd cloudflare && npx wrangler dev --local --port 8799 -c dev/wrangler.local.toml
//   LG_LOCAL_API=http://127.0.0.1:8799 flutter test test/integration
//
// LG_LOCAL_API berilmasa test o'tkazib yuboriladi (server kerak).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/cloudflare_backend.dart';
import 'package:labguide/core/backend/supabase_backend.dart'
    show MemorySessionStore;
import 'package:labguide/features/auth/otp_auth.dart';

void main() {
  final base = Platform.environment['LG_LOCAL_API'];
  if (base == null || base.isEmpty) {
    test(
      'mahalliy Worker bilan sinov',
      () {},
      skip: 'LG_LOCAL_API berilmagan (mahalliy Worker kerak)',
    );
    return;
  }
  if (!base.contains('127.0.0.1') && !base.contains('localhost')) {
    throw StateError('Faqat mahalliy Worker: $base');
  }
  final config = ApiConfig(url: base);
  final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  Future<String> lastCode(String email) async {
    final r = await http.get(Uri.parse('$base/__outbox'));
    final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
    return list.lastWhere((m) => m['to'] == email.toLowerCase())['code']
        as String;
  }

  Future<CloudflareLabBackend> login(String email, String lang) async {
    final b = CloudflareLabBackend(config, sessionStore: MemorySessionStore());
    final req = await b.requestCode(email);
    expect(req.status, OtpRequestStatus.sent);
    final v = await b.verifyCode(email, await lastCode(email));
    expect(v.status, OtpVerifyStatus.verified);
    return b;
  }

  group('ustoz + 2 talaba, haqiqiy HTTP', () {
    test('OTP xatolari: noto\'g\'ri email, noto\'g\'ri kod, kodsiz', () async {
      final b = CloudflareLabBackend(
        config,
        sessionStore: MemorySessionStore(),
      );
      expect(
        (await b.requestCode('not-an-email')).status,
        OtpRequestStatus.invalidEmail,
      );
      final e = 'bad.$stamp@example.test';
      expect((await b.requestCode(e)).status, OtpRequestStatus.sent);
      // 60 s ichida qayta so'rash
      final again = await b.requestCode(e);
      expect(again.status, OtpRequestStatus.rateLimited);
      expect(again.retryAfter, isNotNull);
      expect(
        (await b.verifyCode(e, '000000')).status,
        anyOf(OtpVerifyStatus.invalidCode, OtpVerifyStatus.verified),
      );
      expect(
        (await b.verifyCode('nobody.$stamp@example.test', '123456')).status,
        OtpVerifyStatus.noActiveCode,
      );
    });

    test('to\'liq oqim', () async {
      final teacher = await login('ustoz.$stamp@example.test', 'uz');
      await teacher.touchProfile(role: 'teacher', language: 'uz');
      await teacher.registerTeacher();

      // Ustoz bo'lmagan hisob guruh ocha olmaydi.
      final s1 = await login('t1.$stamp@example.test', 'ru');
      final s2 = await login('t2.$stamp@example.test', 'en');
      await expectLater(
        s1.createGroup('Yashirin guruh'),
        throwsA(isA<BackendException>()),
      );

      final g = await teacher.createGroup('Klinik laboratoriya 1-kurs');
      expect(g.isTeacher, isTrue);
      expect(g.joinCode, hasLength(8));

      // Noto'g'ri kod.
      await expectLater(
        s1.joinGroup('ZZZZZZZZ'),
        throwsA(
          isA<BackendException>().having(
            (e) => e.failure,
            'failure',
            BackendFailure.notFound,
          ),
        ),
      );
      final g1 = await s1.joinGroup(g.joinCode!, displayName: 'Lola');
      final g2 = await s2.joinGroup(g.joinCode!.toLowerCase());
      expect(g1, g.id);
      expect(g2, g.id);

      // Talaba kodni ko'rmaydi; ustoz 3 a'zoni ko'radi, talaba esa 2 ni.
      final mine = (await s1.myGroups()).single;
      expect(mine.joinCode, isNull);
      expect(mine.isTeacher, isFalse);
      final tm = await teacher.groupMembers(g.id);
      expect(tm, hasLength(3));
      final sm = await s2.groupMembers(g.id);
      expect(sm.where((m) => !m.isTeacher), hasLength(1));
      expect(sm.every((m) => m.alias != 'Lola'), isTrue);

      // Mavzu: ochilmagan -> ochiq; talaba ocha olmaydi.
      expect(await s1.groupTopics(g.id), isEmpty);
      await expectLater(
        s1.openTopic(g.id, 'd001-L'),
        throwsA(isA<BackendException>()),
      );
      await teacher.openTopic(g.id, 'd001-L');
      var topics = await s1.groupTopics(g.id);
      expect(topics.single.lectureDoneAt, isNull);
      await teacher.markTopicStage(g.id, 'd001-L', TopicStage.lecture);
      await teacher.markTopicStage(g.id, 'd001-L', TopicStage.oral);
      topics = await s2.groupTopics(g.id);
      expect(topics.single.lectureDoneAt, isNotNull);
      expect(topics.single.oralDoneAt, isNotNull);
      expect(topics.single.testAssignmentId, isNull);

      // Test.
      final aid = await teacher.startTopicTest(
        groupId: g.id,
        topicId: 'd001-L',
        title: 'Test: kirish',
        questionIds: ['q1', 'q2', 'q3'],
        correctIndexes: [0, 1, 2],
        timeLimitMinutes: 10,
      );
      expect((await s1.groupTopics(g.id)).single.testAssignmentId, aid);
      await expectLater(
        s1.assignmentKey(aid),
        throwsA(isA<BackendException>()),
      );
      expect(await teacher.assignmentKey(aid), [0, 1, 2]);
      await s1.startAssignment(aid);
      await s2.startAssignment(aid);
      final r1 = await s1.submitAssignment(aid, [0, 1, 2]);
      final r2 = await s2.submitAssignment(aid, [0, 0, -1]);
      expect((r1.score, r1.total), (3, 3));
      expect((r2.score, r2.total), (1, 3));
      await expectLater(
        s1.submitAssignment(aid, [0, 1, 2]),
        throwsA(isA<BackendException>()),
      );

      // Natijalar: talaba faqat o'zini, ustoz hammani.
      final own = await s1.submissions(aid);
      expect(own, hasLength(1));
      expect(own.single.userId, s1.userId);
      expect(await teacher.submissions(aid), hasLength(2));
      expect(await s2.groupSubmissions(g.id), hasLength(1));
      expect(await teacher.groupSubmissions(g.id), hasLength(2));

      await teacher.finishTopicTest(g.id, 'd001-L');

      // Chiqib ketgan talaba guruhni ko'rmaydi.
      await s2.leaveGroup(g.id);
      expect(await s2.myGroups(), isEmpty);
      expect(await s2.groupTopics(g.id), isEmpty);
      expect(await s2.groupSubmissions(g.id), isEmpty);
    });
  });
}
