import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';

import '../helpers/fake_backend.dart';

/// Test serveridagi guruh qoidalari `supabase/tests/20_groups_classroom.sql`
/// (haqiqiy Postgres) bilan bir xil bo'lishi kerak — UI testlari shunga
/// tayanadi.
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
    now = DateTime.utc(2026, 10, 9, 9);
    b.groupClock = () => now;
  });

  test('kirmagan foydalanuvchi guruh amallarini bajara olmaydi', () async {
    await expectLater(b.myGroups(), _fails(BackendFailure.unauthorized));
    await expectLater(
      b.createGroup('Biokimyo'),
      _fails(BackendFailure.unauthorized),
    );
  });

  test('to‘liq oqim: ustoz → kod → talaba → topshiriq → ball', () async {
    await _as(b, 'teacher@example.com');
    await expectLater(b.createGroup('ab'), _fails(BackendFailure.invalid));
    final g = await b.createGroup('Biokimyo 2-kurs', displayName: 'Ustoz K.');
    expect(g.isTeacher, isTrue);
    expect(g.joinCode, hasLength(8));
    final aid = await b.createAssignment(
      groupId: g.id,
      title: '1-mavzu',
      questionIds: ['q1', 'q2', 'q3'],
      correctIndexes: [1, 0, 2],
      timeLimitMinutes: 10,
    );
    // Ustoz o'z topshirig'ini yecha olmaydi (faqat talaba).
    await expectLater(b.startAssignment(aid), _fails(BackendFailure.forbidden));

    await _as(b, 'student@example.com');
    expect(await b.myGroups(), isEmpty);
    await expectLater(
      b.joinGroup('WRONG123', displayName: 'Ali'),
      _fails(BackendFailure.notFound),
    );
    // Kichik harf va bo'shliq bilan ham qabul qilinadi.
    final gid = await b.joinGroup(
      ' ${g.joinCode!.toLowerCase()} ',
      displayName: 'Aliyev A.',
    );
    expect(gid, g.id);
    final mine = (await b.myGroups()).single;
    expect(mine.isTeacher, isFalse);
    expect(mine.joinCode, isNull, reason: 'kod faqat ustozga ko‘rsatiladi');
    expect(mine.memberCount, 2);
    // Talaba topshiriq bera olmaydi va kalitni ko'rmaydi.
    await expectLater(
      b.createAssignment(
        groupId: g.id,
        title: 'Hack',
        questionIds: ['q1'],
        correctIndexes: [0],
      ),
      _fails(BackendFailure.forbidden),
    );
    await expectLater(b.assignmentKey(aid), _fails(BackendFailure.forbidden));
    final visible = (await b.assignments(g.id)).single;
    expect(visible.questionIds, ['q1', 'q2', 'q3']);
    // Vaqtli topshiriq: boshlamasdan topshirib bo'lmaydi.
    await expectLater(
      b.submitAssignment(aid, [1, 0, 2]),
      _fails(BackendFailure.invalid),
    );
    final start = await b.startAssignment(aid);
    now = now.add(const Duration(minutes: 3));
    expect((await b.startAssignment(aid)).startedAt, start.startedAt);
    final sub = await b.submitAssignment(aid, [1, -1, 0]);
    expect((sub.score, sub.total), (1, 3));
    expect(sub.correct, [true, false, false]);
    // Bir marta topshiriladi.
    await expectLater(
      b.submitAssignment(aid, [1, 0, 2]),
      _fails(BackendFailure.invalid),
    );
    expect((await b.submissions(aid)).single.score, 1);

    // Begona: hech narsa ko'rmaydi va qila olmaydi.
    await _as(b, 'outsider@example.com');
    expect(await b.myGroups(), isEmpty);
    expect(await b.assignments(g.id), isEmpty);
    expect(await b.groupMembers(g.id), isEmpty);
    expect(await b.submissions(aid), isEmpty);
    expect(await b.groupSubmissions(g.id), isEmpty);
    await expectLater(b.startAssignment(aid), _fails(BackendFailure.forbidden));
    await expectLater(
      b.removeMember(g.id, 'user-1'),
      _fails(BackendFailure.forbidden),
    );

    // Ustoz: natija, kalit va a'zolar.
    await _as(b, 'teacher@example.com');
    final subs = await b.groupSubmissions(g.id);
    expect(subs.single.answers, [1, -1, 0]);
    expect(await b.assignmentKey(aid), [1, 0, 2]);
    final members = await b.groupMembers(g.id);
    expect(members.map((m) => m.displayName), ['Ustoz K.', 'Aliyev A.']);
  });

  test('vaqt chegarasi va muddat serverda tekshiriladi', () async {
    await _as(b, 'teacher@example.com');
    final g = await b.createGroup('Klinik biokimyo', displayName: 'Ustoz');
    await expectLater(
      b.createAssignment(
        groupId: g.id,
        title: 'Eski',
        questionIds: ['q'],
        correctIndexes: [0],
        dueAt: now.subtract(const Duration(minutes: 1)),
      ),
      _fails(BackendFailure.invalid),
    );
    final timed = await b.createAssignment(
      groupId: g.id,
      title: 'Vaqtli',
      questionIds: ['q'],
      correctIndexes: [0],
      timeLimitMinutes: 10,
    );
    final due = await b.createAssignment(
      groupId: g.id,
      title: 'Muddatli',
      questionIds: ['q'],
      correctIndexes: [0],
      dueAt: now.add(const Duration(hours: 1)),
    );
    await _as(b, 's1@example.com');
    await b.joinGroup(g.joinCode!, displayName: 'Talaba 1');
    await b.startAssignment(timed);
    now = now.add(const Duration(minutes: 13));
    await expectLater(
      b.submitAssignment(timed, [0]),
      _fails(BackendFailure.invalid),
    );
    now = now.add(const Duration(hours: 1));
    await expectLater(b.startAssignment(due), _fails(BackendFailure.invalid));
    await expectLater(
      b.submitAssignment(due, [0]),
      _fails(BackendFailure.invalid),
    );
  });

  test('a’zoni chiqarish va guruhdan chiqish', () async {
    await _as(b, 'teacher@example.com');
    final g = await b.createGroup('Guruh', displayName: 'Ustoz');
    await _as(b, 's1@example.com');
    await b.joinGroup(g.joinCode!, displayName: 'Talaba 1');
    final s1 = b.userId!;
    await _as(b, 's2@example.com');
    await b.joinGroup(g.joinCode!, displayName: 'Talaba 2');
    // Talaba boshqasini chiqara olmaydi.
    await expectLater(
      b.removeMember(g.id, s1),
      _fails(BackendFailure.forbidden),
    );
    await b.leaveGroup(g.id);
    expect(await b.myGroups(), isEmpty);

    await _as(b, 'teacher@example.com');
    await b.removeMember(g.id, s1);
    final teacherId = b.userId!;
    await b.removeMember(g.id, teacherId); // ustozni chiqarib bo'lmaydi
    await b.leaveGroup(g.id); // ustoz chiqmaydi
    final members = await b.groupMembers(g.id);
    expect(members.single.isTeacher, isTrue);
  });
}
