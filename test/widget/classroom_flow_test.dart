import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/classroom/classroom_local.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/qr_code_view.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 2400);
const _topic = 'd008-L';

Curriculum _fixture() => Curriculum.parse(
  File('test/fixtures/curriculum_sample.json').readAsStringSync(),
);

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

/// Aralash (paket + toifa) savolga to'g'ri yoki noto'g'ri javob.
Future<void> _answer(
  WidgetTester tester,
  AppServices s,
  ExamSession session, {
  required bool correct,
}) async {
  final item = session.current;
  final q = ClassQuestionSource.of(
    s.content.pack!,
    s.toifa.bank,
  ).question(item.questionId)!;
  final idx = correct
      ? item.correct.single
      : item.order.firstWhere((o) => !item.correct.contains(o));
  await tapScroll(tester, q.option(idx, 'uz'));
}

Future<void> _scrollTo(WidgetTester tester, Finder f) =>
    tester.scrollUntilVisible(
      f,
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );

void main() {
  setUpAll(loadAppFonts);

  testWidgets('server ulanmagan: halol holat; ma’ruza esa serversiz ishlaydi', (
    tester,
  ) async {
    final fakes = installDiffFakes();
    final s = await makeServices(tester, role: AppRole.teacher);
    s.curriculum.use(_fixture());
    await pumpApp(tester, s, size: _tall);
    expect(s.backend.isConfigured, isFalse);
    for (final r in [
      '/learn/classes',
      '/learn/classes/new',
      '/learn/classes/g/g1/plan',
      '/learn/classes/g/g1/t/$_topic',
    ]) {
      await goTo(tester, r);
      expect(find.text(uz.classesUnavailableTitle), findsOneWidget, reason: r);
      expect(find.text(uz.classroomOpenTopic), findsNothing);
    }

    // Ma'ruza rejimi: ro'yxat → slaydlar; ekran yoqiq turadi.
    await goTo(tester, '/learn/lecture');
    expect(find.text('Buyrak va siydik'), findsOneWidget);
    await tapScroll(
      tester,
      'Buyrak kasalliklarining laborator ko‘rsatkichlari',
    );
    expect(fakes.awake.calls, [true]);
    expect(
      find.text('Buyrak kasalliklarining laborator ko‘rsatkichlari'),
      findsOneWidget,
    );
    final total = RegExp(r'1 / (\d+)');
    final counter = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .firstWhere(total.hasMatch);
    final n = int.parse(total.firstMatch(counter)!.group(1)!);
    expect(n, greaterThanOrEqualTo(5));
    await tester.tap(find.text(uz.lectureNext));
    await tester.pumpAndSettle();
    expect(find.text(uz.lectureConcepts), findsOneWidget);
    expect(find.textContaining('Kreatinin'), findsWidgets);
    for (var i = 2; i < n; i++) {
      await tester.tap(find.text(uz.lectureNext));
      await tester.pumpAndSettle();
    }
    expect(find.text(uz.lectureCounter(n, n)), findsOneWidget);
    expect(find.text(uz.lectureEndTitle), findsOneWidget);
    // Oxirgi slayddan keyin oldinga yo'q; orqaga ishlaydi.
    await tester.tap(find.text(uz.lectureNext));
    await tester.pumpAndSettle();
    expect(find.text(uz.lectureCounter(n, n)), findsOneWidget);
    await tester.tap(find.text(uz.lecturePrev));
    await tester.pumpAndSettle();
    expect(find.text(uz.lectureCounter(n - 1, n)), findsOneWidget);
    await tester.tap(find.byTooltip(uz.lectureClose));
    await tester.pumpAndSettle();
    expect(fakes.awake.calls, [true, false]);
  });

  testWidgets('o‘quv dasturi yo‘q: “qo‘shilmagan” deb ko‘rsatiladi', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/learn/lecture');
    expect(find.text(uz.classroomNoCurriculumTitle), findsOneWidget);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('KLD');
    await goTo(tester, '/learn/classes/g/${g.id}/plan');
    expect(find.text(uz.classroomNoCurriculumTitle), findsOneWidget);
  });

  testWidgets('ustoz: guruh, QR, mavzu ochish → ma’ruza → savol-javob → test; '
      'talaba: taxallussiz, material va test; ustoz natijasi', (tester) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    s.curriculum.use(_fixture());
    await pumpApp(tester, s, size: _tall);

    // Ustoz guruh ochadi: kod va QR.
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('KLD ixtisoslashtirish');
    await goTo(tester, '/learn/classes/g/${g.id}');
    expect(find.byType(QrCodeView), findsOneWidget);
    final qr = tester.widget<QrCodeView>(find.byType(QrCodeView));
    expect(qr.data, g.joinCode);
    expect(
      qr.semanticLabel,
      uz.classesQrLabel(g.joinCode!.split('').join(' ')),
    );

    // Talaba kod bilan, taxallussiz qo'shiladi (QR havola kodi to'ldiradi).
    await _signIn(tester, s, 'student@example.com');
    await goTo(tester, '/learn/classes/join?code=${g.joinCode}');
    await tapScroll(tester, uz.classesJoinAction);
    expect(find.text(uz.classesYouStudent), findsOneWidget);
    await tapScroll(tester, uz.classroomTopicsTitle);
    expect(find.text(uz.classroomNoTopicsStudent), findsOneWidget);

    // Ustoz: jadval — hafta/kun → mavzu → holat.
    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/learn/classes/g/${g.id}');
    expect(find.text(uz.classesSeat('01')), findsOneWidget);
    await tapScroll(tester, uz.classroomPlanTitle);
    expect(find.text('Buyrak va siydik'), findsOneWidget);
    expect(find.text(uz.classroomStatusClosed), findsNWidgets(3));
    expect(find.textContaining(uz.classroomDayN(8)), findsNWidgets(2));
    await tapScroll(
      tester,
      'Buyrak kasalliklarining laborator ko‘rsatkichlari',
    );

    // Mavzu sahifasi: ochish, materiallar.
    expect(find.text(uz.classroomStatusClosed), findsOneWidget);
    await tapScroll(tester, uz.classroomOpenTopic);
    expect(find.text(uz.classroomStatusOpened), findsOneWidget);
    expect((await b.groupTopics(g.id)).single.topicId, _topic);
    await _scrollTo(tester, find.text('Surunkali buyrak kasalligi (SBK)'));
    expect(find.text('Kreatinin'), findsOneWidget);

    // 1. Ma'ruza o'tildi.
    await tapScroll(tester, uz.classroomMarkDone);
    expect(find.text(uz.classroomStatusLectured), findsOneWidget);

    // 2. Og'zaki: nomzodlar, “so'raldi”, talabaga baho (faqat qurilmada).
    await tapScroll(tester, uz.classroomOralOpen);
    expect(find.text(uz.classroomOralNotice), findsOneWidget);
    expect(find.text(uz.classroomCandidate(1).toUpperCase()), findsOneWidget);
    expect(find.text(uz.classroomCandidate(2).toUpperCase()), findsOneWidget);
    await tester.tap(find.text(uz.classroomOralAsked).first);
    await tester.pumpAndSettle();
    expect(s.classroom.asked(g.id, _topic, 'kdl-o-042'), isTrue);
    await tapScroll(tester, uz.classroomOralGrade(0));
    await tester.tap(find.text(uz.classroomGradePartial).last);
    await tester.pumpAndSettle();
    final student = (await b.groupMembers(g.id))
        .firstWhere((m) => !m.isTeacher);
    expect(
      s.classroom.grade(g.id, _topic, 'kdl-o-042', student.userId),
      OralGrade.partial,
    );
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    expect(find.text(uz.classroomStageOralBody(1)), findsOneWidget);
    await tapScroll(tester, uz.classroomMarkDone);
    expect(find.text(uz.classroomStatusOral), findsOneWidget);

    // 3. Test: nomzodlardan ustoz tanlaydi (avtomatik tanlanmaydi).
    await tapScroll(tester, uz.classroomTestPrepare);
    expect(find.text(uz.classroomCandidatesNotice), findsOneWidget);
    expect(find.text(uz.classroomCandidatesTitle(0, 4)), findsOneWidget);
    await tapScroll(tester, uz.classroomTestStart(0));
    expect(find.text(uz.classroomPickAtLeastOne), findsOneWidget);
    expect(await b.assignments(g.id), isEmpty);
    await tapScroll(tester, uz.classroomPickAll);
    await tester.tap(find.byType(CheckboxListTile).at(1));
    await tester.pumpAndSettle();
    await tapScroll(tester, uz.examMinutes(10));
    await tapScroll(tester, uz.classroomTestStart(3));
    final a = (await b.assignments(g.id)).single;
    expect(a.topicId, _topic);
    expect(a.timeLimitMinutes, 10);
    expect(a.questionIds, ['kdl-t-031', 'creatinine-q1', 'urea-q1']);
    expect(find.text(uz.classroomStatusTestRunning), findsOneWidget);

    // Talaba: ochilgan mavzu, material va test (paket + toifa savollari).
    await _signIn(tester, s, 'student@example.com');
    await goTo(tester, '/learn/classes/g/${g.id}/plan');
    expect(find.text(uz.classroomStatusTestRunning), findsOneWidget);
    expect(find.text('Buyrak: amaliy mashg‘ulot'), findsNothing);
    await tapScroll(
      tester,
      'Buyrak kasalliklarining laborator ko‘rsatkichlari',
    );
    expect(find.text(uz.classroomOpenTopic), findsNothing);
    expect(find.text(uz.classroomOralOpen), findsNothing);
    await tapScroll(tester, a.title);
    await tapScroll(tester, uz.classesStart);
    final run = s.exams.assignmentSession(a.id, b.userId)!;
    expect(run.sourceId, ClassQuestionSource.sourceId);
    for (var i = 0; i < run.length; i++) {
      await _answer(tester, s, run, correct: i != 1);
      if (i < run.length - 1) await tapScroll(tester, uz.examNext);
    }
    await tapScroll(tester, uz.examFinish);
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(find.text(uz.classesServerScore), findsOneWidget);
    final mine = (await b.submissions(a.id)).single;
    expect(mine.score, 2);

    // Ustoz: natijalar paneli (talaba raqami, savol bo'yicha xato),
    // lokal belgi faqat qurilmada; testni yakunlash.
    await _signIn(tester, s, 'teacher@example.com');
    await s.classroom.setLocalName(g.id, mine.userId, 'Aliyev A.');
    await goTo(tester, '/learn/classes/g/${g.id}/t/$_topic');
    expect(find.text(uz.classroomTestSubmitted(1, 1)), findsOneWidget);
    await tapScroll(tester, uz.classroomTestResults);
    expect(find.text('Aliyev A. · ${uz.classesSeat('01')}'), findsOneWidget);
    await _scrollTo(tester, find.text(uz.classesWrongOf(1, 1)));
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    await tapScroll(tester, uz.classroomTestFinish);
    await tester.tap(find.text(uz.classroomTestFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(find.text(uz.classroomStatusTestDone), findsWidgets);
    final members = await b.groupMembers(g.id);
    expect(
      members.every((m) => m.alias == null),
      isTrue,
      reason: 'serverda ism yo‘q',
    );
  });

  // Yangi ekranlar: tor ekran / katta shrift / qorong'i, uch tilda.
  for (final lang in AppLanguage.values) {
    for (final (width, scale, theme) in [
      (320.0, 2.0, ThemeMode.light),
      (430.0, 1.35, ThemeMode.dark),
    ]) {
      testWidgets('classroom layout: ${lang.name} ${width.toInt()} ×$scale '
          '${theme.name}', (tester) async {
        installDiffFakes();
        final b = FakeLabBackend();
        final s = await makeServices(
          tester,
          backend: b,
          language: lang,
          themeMode: theme,
          role: AppRole.teacher,
        );
        s.curriculum.use(_fixture());
        await pumpApp(tester, s, size: Size(width, 3200), textScale: scale);
        await _signIn(tester, s, 'teacher@example.com');
        await b.registerTeacher();
        final g = await b.createGroup('KLD ixtisoslashtirish 2026');
        await s.classroom.setStartDate(g.id, DateTime(2026, 1, 5));
        await _signIn(tester, s, 'student@example.com');
        await b.joinGroup(g.joinCode!, displayName: 'Yulduz');
        await _signIn(tester, s, 'teacher@example.com');
        await b.openTopic(g.id, _topic);
        await b.markTopicStage(g.id, _topic, TopicStage.lecture);
        Future<void> visit(List<String> routes) async {
          for (final r in routes) {
            await goTo(tester, r);
            expect(tester.takeException(), isNull, reason: r);
          }
        }

        await visit([
          '/learn/classes/new',
          '/learn/classes/g/${g.id}',
          '/learn/classes/g/${g.id}/plan',
          '/learn/classes/g/${g.id}/t/$_topic',
          '/learn/classes/g/${g.id}/t/$_topic/oral',
          '/learn/classes/g/${g.id}/t/$_topic/test',
          '/learn/classes/g/${g.id}/t/d027-L',
          '/learn/lecture',
          '/learn/lecture/$_topic',
        ]);
        for (var i = 0; i < 8; i++) {
          await tester.tap(find.byIcon(Icons.chevron_right_rounded).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'slide $i');
        }
        await _signIn(tester, s, 'student@example.com');
        await visit([
          '/learn/classes/join',
          '/learn/classes/g/${g.id}/plan',
          '/learn/classes/g/${g.id}/t/$_topic',
        ]);
      });
    }
  }
}
