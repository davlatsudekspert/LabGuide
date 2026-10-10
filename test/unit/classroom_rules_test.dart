import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/lab_backend.dart';

import '../helpers/fake_backend.dart';

/// Test serveridagi ustoz/mavzu qoidalari
/// `supabase/tests/30_teacher_topics.sql` bilan bir xil bo'lishi kerak —
/// UI testlari shunga tayanadi. Kontrakt (backend interfeysi) shu qoidalar.
Future<void> _as(FakeLabBackend b, String email) async {
  await b.signOut();
  await b.requestCode(email);
  await b.verifyCode(email, FakeLabBackend.otpCode);
}

Matcher _fails(BackendFailure f) =>
    throwsA(isA<BackendException>().having((e) => e.failure, 'failure', f));

void main() {
  late FakeLabBackend b;
  late DateTime now;

  setUp(() {
    b = FakeLabBackend();
    now = DateTime.utc(2026, 10, 10, 9);
    b.groupClock = () => now;
  });

  test('server ulanmagan: hamma yangi amal — unavailable', () async {
    const u = UnconfiguredBackend();
    for (final run in <Future<Object?> Function()>[
      u.registerTeacher,
      () => u.groupTopics('g'),
      () => u.openTopic('g', 't'),
      () => u.markTopicStage('g', 't', TopicStage.lecture),
      () => u.startTopicTest(
        groupId: 'g',
        topicId: 't',
        title: 'Test',
        questionIds: const ['q'],
        correctIndexes: const [0],
      ),
      () => u.finishTopicTest('g', 't'),
      () => u.setMyAlias('g', null),
    ]) {
      await expectLater(run(), _fails(BackendFailure.unavailable));
    }
  });

  test(
    'taxallus yoki tartib raqami; talaba boshqa talabani ko‘rmaydi',
    () async {
      await _as(b, 'teacher@example.com');
      await b.registerTeacher();
      final g = await b.createGroup('KLD ixtisoslashtirish');
      await _as(b, 's1@example.com');
      await b.joinGroup(g.joinCode!);
      await expectLater(
        b.joinGroup(g.joinCode!, displayName: 'X'),
        completion(g.id),
        reason: 'qayta qo‘shilish o‘zgartirmaydi',
      );
      await _as(b, 's2@example.com');
      await b.joinGroup(g.joinCode!, displayName: '  Yulduz ');
      final seen = await b.groupMembers(g.id);
      expect(seen, hasLength(2), reason: 'o‘zi va ustoz');
      expect(seen.where((m) => !m.isTeacher).single.alias, 'Yulduz');
      expect(seen.where((m) => !m.isTeacher).single.seatNo, 2);
      await b.setMyAlias(g.id, null);
      expect(
        (await b.groupMembers(g.id)).where((m) => !m.isTeacher).single.alias,
        isNull,
      );
      await expectLater(
        b.joinGroup(g.joinCode!, displayName: 'Y'),
        completion(g.id),
      );

      await _as(b, 'teacher@example.com');
      final all = await b.groupMembers(g.id);
      expect(all, hasLength(3));
      expect(all.where((m) => !m.isTeacher).map((m) => m.seatNo), [1, 2]);
      expect(all.where((m) => !m.isTeacher).first.alias, isNull);
    },
  );

  test('mavzu: faqat guruh egasi-ustoz ochadi, bosqich va test', () async {
    await _as(b, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('KLD');
    await _as(b, 'other-teacher@example.com');
    await b.registerTeacher();
    await expectLater(
      b.openTopic(g.id, 'd008-L'),
      _fails(BackendFailure.forbidden),
    );
    await expectLater(b.groupTopics(g.id), completion(isEmpty));

    await _as(b, 'student@example.com');
    await b.joinGroup(g.joinCode!);
    await expectLater(
      b.openTopic(g.id, 'd008-L'),
      _fails(BackendFailure.forbidden),
    );
    await expectLater(
      b.startTopicTest(
        groupId: g.id,
        topicId: 'd008-L',
        title: 'Test',
        questionIds: const ['q1'],
        correctIndexes: const [0],
      ),
      _fails(BackendFailure.forbidden),
    );

    await _as(b, 'teacher@example.com');
    await expectLater(
      b.openTopic(g.id, 'bad id'),
      _fails(BackendFailure.invalid),
    );
    await b.openTopic(g.id, 'd008-L');
    await b.markTopicStage(g.id, 'd008-L', TopicStage.lecture);
    await b.markTopicStage(g.id, 'd008-L', TopicStage.oral);
    final aid = await b.startTopicTest(
      groupId: g.id,
      topicId: 'd008-L',
      title: 'Test: buyrak',
      questionIds: const ['kdl-t-031', 'creatinine-q1'],
      correctIndexes: const [1, 0],
      timeLimitMinutes: 15,
    );
    await expectLater(
      b.startTopicTest(
        groupId: g.id,
        topicId: 'd008-L',
        title: 'Ikkinchi',
        questionIds: const ['q1'],
        correctIndexes: const [0],
      ),
      _fails(BackendFailure.invalid),
    );
    final t = (await b.groupTopics(g.id)).single;
    expect(t.lectureDoneAt, isNotNull);
    expect(t.oralDoneAt, isNotNull);
    expect(t.testAssignmentId, aid);
    final a = (await b.assignments(g.id)).single;
    expect(a.topicId, 'd008-L');
    expect(a.timeLimitMinutes, 15);

    // Talaba: mavzuni ko'radi, yechadi; natijasi faqat o'ziga va ustozga.
    await _as(b, 'student@example.com');
    expect((await b.groupTopics(g.id)).single.topicId, 'd008-L');
    await b.startAssignment(aid);
    final sub = await b.submitAssignment(aid, [1, 1]);
    expect(sub.score, 1);
    expect(sub.correct, [true, false]);
    await _as(b, 'student2@example.com');
    await b.joinGroup(g.joinCode!);
    expect(await b.submissions(aid), isEmpty);
    await _as(b, 'other-teacher@example.com');
    expect(await b.submissions(aid), isEmpty);
    await _as(b, 'davlatsudekspert@gmail.com');
    expect(await b.submissions(aid), isEmpty, reason: 'admin ham ko‘rmaydi');

    await _as(b, 'teacher@example.com');
    expect((await b.submissions(aid)).single.correct, [true, false]);
    await b.finishTopicTest(g.id, 'd008-L');
    await expectLater(
      b.finishTopicTest(g.id, 'd009-L'),
      _fails(BackendFailure.notFound),
    );
    now = now.add(const Duration(minutes: 1));
    await _as(b, 'student2@example.com');
    await expectLater(b.startAssignment(aid), _fails(BackendFailure.invalid));
  });
}
