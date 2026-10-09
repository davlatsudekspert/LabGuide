import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 1600);

/// Internet uzilishini taqlid qiladi (javob yuborishda).
class _FlakyBackend extends FakeLabBackend {
  bool offline = false;

  @override
  Future<GroupSubmission> submitAssignment(
    String assignmentId,
    List<int> answers,
  ) async {
    if (offline) throw const BackendException(BackendFailure.network);
    return super.submitAssignment(assignmentId, answers);
  }
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _finish(WidgetTester tester, AppLocalizations l) async {
  await tapScroll(tester, l.examFinish);
  await tester.tap(find.text(l.examFinish).hitTestable().last);
  await tester.pumpAndSettle();
}

/// Ustoz guruh va topshiriqni server orqali tayyorlaydi.
Future<({String gid, String aid, String code})> _prepare(
  WidgetTester tester,
  AppServices s,
  FakeLabBackend b, {
  int? minutes,
  DateTime? due,
}) async {
  await _signIn(tester, s, 'teacher@example.com');
  final g = await b.createGroup('Biokimyo', displayName: 'Ustoz K.');
  final qs = s.content.pack!.quiz.take(3).toList();
  final aid = await b.createAssignment(
    groupId: g.id,
    title: 'Topshiriq 1',
    questionIds: [for (final q in qs) q.id],
    correctIndexes: [for (final q in qs) q.correctIndex],
    timeLimitMinutes: minutes,
    dueAt: due,
  );
  return (gid: g.id, aid: aid, code: g.joinCode!);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('hisobsiz: kirish taklifi; guruh amallari ko‘rsatilmaydi', (
    tester,
  ) async {
    final s = await makeServices(tester, backend: FakeLabBackend());
    await pumpApp(tester, s);
    await goTo(tester, '/learn/classes');
    expect(find.text(uz.classesSignInTitle), findsOneWidget);
    expect(find.text(uz.classesCreate), findsNothing);
    await goTo(tester, '/learn/classes/join');
    expect(find.text(uz.classesSignInTitle), findsOneWidget);
    expect(find.text(uz.classesJoinAction), findsNothing);
  });

  testWidgets('ustoz yaratadi → talaba qo‘shiladi → topshiradi → natija', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    s.exams.random = Random(3);
    await pumpApp(tester, s, size: _tall);

    // 1. Ustoz: guruh yaratish (kim yaratsa — o'sha ustoz).
    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/learn/classes');
    expect(find.text(uz.classesEmpty), findsOneWidget);
    expect(find.text(uz.classesRoleNote), findsOneWidget);
    await tapScroll(tester, uz.classesCreate);
    await tapScroll(tester, uz.classesCreateAction);
    expect(find.text(uz.classesLengthError(3, 80)), findsOneWidget);
    await enterField(tester, uz.classesGroupName, 'Biokimyo 2-kurs');
    await enterField(tester, uz.classesDisplayName, 'Karimova N.A.');
    await tapScroll(tester, uz.classesCreateAction);
    final group = (await b.myGroups()).single;
    expect(group.isTeacher, isTrue);
    final code = group.joinCode!;
    expect(
      find.text('${code.substring(0, 4)} ${code.substring(4)}'),
      findsOneWidget,
    );
    expect(find.text(uz.classesYouTeacher(1)), findsOneWidget);

    // 2. Topshiriq: mavzu, son, vaqt, muddat — savol bankidan.
    await tapScroll(tester, uz.classesNewAssignment);
    await enterField(tester, uz.classesAssignmentTitle, '1-mavzu: buyrak');
    await tapScroll(tester, 'Buyrak funksiyasi · 8');
    await enterField(tester, uz.examCount, '3');
    await tapScroll(tester, uz.examMinutes(10));
    await tapScroll(tester, uz.classesDueDays(1));
    expect(find.text(uz.classesPreview(3)), findsOneWidget);
    await tapScroll(tester, uz.classesSendAssignment);
    final a = (await b.assignments(group.id)).single;
    expect(a.title, '1-mavzu: buyrak');
    expect(a.questionIds, hasLength(3));
    expect(a.timeLimitMinutes, 10);
    expect(a.dueAt, isNotNull);
    expect(find.text('1-mavzu: buyrak'), findsOneWidget);
    final pack = PackQuestionSource.of(s.content.pack!);
    for (final id in a.questionIds) {
      expect(pack.question(id)!.topicIds, contains('kidney'));
    }

    // 3. Talaba: kod bilan qo'shiladi (noto'g'ri kod — aniq xabar).
    await _signIn(tester, s, 'student@example.com');
    await goTo(tester, '/learn/classes');
    await tapScroll(tester, uz.classesJoin);
    await tester.enterText(find.byType(TextField).first, 'zz-99-yy-88');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'ZZ99YY88',
      reason: 'faqat katta harf va raqam',
    );
    await enterField(tester, uz.classesDisplayName, 'Aliyev Anvar');
    await tapScroll(tester, uz.classesJoinAction);
    expect(find.text(uz.classesCodeNotFound), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, code.toLowerCase());
    await tapScroll(tester, uz.classesJoinAction);
    expect(find.text(uz.classesYouStudent), findsOneWidget);
    expect(find.text(uz.classesStatusNew), findsOneWidget);
    // Talaba kalitni ko'ra olmaydi.
    await expectLater(
      b.assignmentKey(a.id),
      throwsA(
        isA<BackendException>().having(
          (e) => e.failure,
          'failure',
          BackendFailure.forbidden,
        ),
      ),
    );

    // 4. Talaba topshiriqni imtihon UI'sida yechadi.
    await tapScroll(tester, '1-mavzu: buyrak');
    expect(find.text(uz.classesStartNotice(10)), findsOneWidget);
    await tapScroll(tester, uz.classesStart);
    final run = s.exams.assignmentSession(a.id, b.userId)!;
    expect(run.deadline, isNotNull);
    for (var i = 0; i < run.length; i++) {
      await answerCurrent(tester, s, run, correct: i != 0);
      if (i < run.length - 1) await tapScroll(tester, uz.examNext);
    }
    await _finish(tester, uz);
    expect(find.text(uz.classesServerScore), findsOneWidget);
    expect(find.text(uz.quizScore(2, 3)), findsNothing, reason: 'caption');
    expect(find.text('67%'), findsOneWidget);
    final mine = (await b.submissions(a.id)).single;
    expect((mine.score, mine.total), (2, 3));
    expect(s.exams.assignmentSession(a.id, b.userId), isNull);
    // Qayta topshirib bo'lmaydi — boshlash tugmasi yo'q.
    expect(find.text(uz.classesStart), findsNothing);

    // 5. Begona hisob guruhni ko'rmaydi.
    await _signIn(tester, s, 'outsider@example.com');
    await goTo(tester, '/learn/classes');
    expect(find.text(uz.classesEmpty), findsOneWidget);
    await goTo(tester, '/learn/classes/g/${group.id}');
    expect(find.text(uz.classesGroupMissing), findsOneWidget);
    expect(find.text('1-mavzu: buyrak'), findsNothing);
    await goTo(tester, '/learn/classes/g/${group.id}/a/${a.id}');
    expect(find.text(uz.classesAssignmentMissing), findsOneWidget);

    // 6. Ustoz natijalarni ko'radi: talaba, ball, qaysi savolda xato.
    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/learn/classes/g/${group.id}');
    expect(find.text(uz.classesSubmittedOf(1, 1)), findsOneWidget);
    expect(find.text('Aliyev Anvar'), findsOneWidget);
    await goTo(tester, '/learn/classes/g/${group.id}/a/${a.id}');
    expect(find.text('Aliyev Anvar'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('67%'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text(uz.classesWrongOf(1, 1)),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text(uz.classesWrongOf(0, 1)), findsWidgets);
    await tapScroll(tester, 'Aliyev Anvar');
    expect(find.text(uz.classesStudentResultTitle), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining(uz.classesStudentAnswer, findRichText: true),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
  });

  testWidgets('internet yo‘q: javoblar qurilmada, keyin qayta yuboriladi', (
    tester,
  ) async {
    final b = _FlakyBackend();
    final s = await makeServices(tester, backend: b);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b, minutes: 15);
    await _signIn(tester, s, 'student@example.com');
    await b.joinGroup(t.code, displayName: 'Talaba');
    await goTo(tester, '/learn/classes/g/${t.gid}/a/${t.aid}');
    await tapScroll(tester, uz.classesStart);
    final run = s.exams.assignmentSession(t.aid, b.userId)!;
    await answerCurrent(tester, s, run, correct: true);
    b.offline = true;
    await _finish(tester, uz);
    expect(find.text(uz.classesPendingTitle), findsOneWidget);
    expect(s.exams.assignmentSession(t.aid, b.userId)!.finished, isTrue);
    expect(await b.submissions(t.aid), isEmpty);

    b.offline = false;
    await tapScroll(tester, uz.classesResend);
    expect(find.text(uz.classesServerScore), findsOneWidget);
    expect((await b.submissions(t.aid)).single.score, 1);
  });

  testWidgets('vaqt tugasa javoblar o‘zi yuboriladi', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b);
    var now = DateTime.utc(2026, 10, 9, 9);
    s.exams.now = () => now;
    b.groupClock = () => now;
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b, minutes: 5);
    await _signIn(tester, s, 'student@example.com');
    await b.joinGroup(t.code, displayName: 'Talaba');
    await goTo(tester, '/learn/classes/g/${t.gid}/a/${t.aid}');
    await tapScroll(tester, uz.classesStart);
    final run = s.exams.assignmentSession(t.aid, b.userId)!;
    await answerCurrent(tester, s, run, correct: true);
    now = now.add(const Duration(minutes: 5, seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final sub = (await b.submissions(t.aid)).single;
    expect((sub.score, sub.total), (1, 3));
    expect(find.text(uz.classesServerScore), findsOneWidget);
  });

  testWidgets('muddat o‘tgan topshiriq boshlanmaydi', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b);
    var now = DateTime.now().toUtc();
    s.exams.now = () => now;
    b.groupClock = () => now;
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(
      tester,
      s,
      b,
      due: now.add(const Duration(hours: 1)),
    );
    await _signIn(tester, s, 'student@example.com');
    await b.joinGroup(t.code, displayName: 'Talaba');
    now = now.add(const Duration(hours: 2));
    await goTo(tester, '/learn/classes/g/${t.gid}');
    expect(find.text(uz.classesStatusOverdue), findsOneWidget);
    await goTo(tester, '/learn/classes/g/${t.gid}/a/${t.aid}');
    expect(find.text(uz.classesOverdueTitle), findsOneWidget);
    expect(find.text(uz.classesStart), findsNothing);
  });

  testWidgets('ustoz talabani chiqaradi; talaba guruhdan chiqadi', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    for (final (email, name) in [
      ('s1@example.com', 'Birinchi T.'),
      ('s2@example.com', 'Ikkinchi T.'),
    ]) {
      await _signIn(tester, s, email);
      await b.joinGroup(t.code, displayName: name);
    }
    // Ikkinchi talaba o'zi chiqadi.
    await goTo(tester, '/learn/classes/g/${t.gid}');
    await tapScroll(tester, uz.classesLeave);
    await tester.tap(find.text(uz.classesLeaveAction).last);
    await tester.pumpAndSettle();
    expect(await b.myGroups(), isEmpty);

    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/learn/classes/g/${t.gid}');
    expect(find.text('Birinchi T.'), findsOneWidget);
    expect(find.text('Ikkinchi T.'), findsNothing);
    await tester.tap(find.byTooltip(uz.classesRemove));
    await tester.pumpAndSettle();
    expect(find.text(uz.classesRemoveTitle('Birinchi T.')), findsOneWidget);
    await tester.tap(find.text(uz.classesRemoveAction).last);
    await tester.pumpAndSettle();
    expect(find.text('Birinchi T.'), findsNothing);
    expect(find.text(uz.classesNoStudents), findsOneWidget);
  });

  // Guruh ekranlari (ma'lumot bilan) — tor ekran/katta shrift/qorong'i.
  for (final lang in AppLanguage.values) {
    for (final (width, scale, theme) in [
      (320.0, 2.0, ThemeMode.light),
      (390.0, 1.0, ThemeMode.dark),
      (430.0, 1.35, ThemeMode.light),
    ]) {
      testWidgets('classes layout: ${lang.name} ${width.toInt()} ×$scale '
          '${theme.name}', (tester) async {
        final b = FakeLabBackend();
        final s = await makeServices(
          tester,
          backend: b,
          language: lang,
          themeMode: theme,
        );
        await pumpApp(tester, s, size: Size(width, 3200), textScale: scale);
        final t = await _prepare(
          tester,
          s,
          b,
          minutes: 20,
          due: DateTime.now().add(const Duration(days: 3)),
        );
        final key = [
          for (final id in (await b.assignments(t.gid)).single.questionIds)
            s.content.pack!.quiz.firstWhere((q) => q.id == id).correctIndex,
        ];
        await _signIn(tester, s, 'student@example.com');
        await b.joinGroup(t.code, displayName: 'Aliyev Anvar Akmalovich');
        await b.startAssignment(t.aid);
        await b.submitAssignment(t.aid, [key[0], -1, (key[2] + 1) % 3]);
        final student = b.userId!;
        Future<void> visit(List<String> routes) async {
          for (final r in routes) {
            await goTo(tester, r);
            expect(tester.takeException(), isNull, reason: r);
          }
        }

        await visit([
          '/learn/classes',
          '/learn/classes/join',
          '/learn/classes/g/${t.gid}',
          '/learn/classes/g/${t.gid}/a/${t.aid}',
        ]);
        await _signIn(tester, s, 'teacher@example.com');
        await visit([
          '/learn/classes',
          '/learn/classes/new',
          '/learn/classes/g/${t.gid}',
          '/learn/classes/g/${t.gid}/assign',
          '/learn/classes/g/${t.gid}/a/${t.aid}',
          '/learn/classes/g/${t.gid}/a/${t.aid}/s/$student',
        ]);
      });
    }
  }
}
