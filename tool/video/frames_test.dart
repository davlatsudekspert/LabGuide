// Ustoz o'quv videolari uchun kadrlar (haqiqiy ilova vidjetlari, 360x640 @3x).
//   flutter test tool/video/frames_test.dart --update-goldens
// So'ng: python3 tool/video/make_tutorials.py
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/harness.dart';
import '../screenshots/walk_helper.dart';
import 'rec.dart';

const size = Size(360, 640);
const _topic = 'd003-L';
const _group = 'KDL-1 (namuna)';

extension on Walk {
  Finder scrollable() => find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .first;

  Finder vis(String text) => find.text(text).hitTestable().last;

  Future<void> tapScroll(String text) async {
    final f = find.text(text);
    if (f.hitTestable().evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        f.hitTestable(),
        200,
        scrollable: scrollable(),
      );
    }
    await tap(f.hitTestable().last);
  }

  /// Bosiladigan matnni topib, ko'rinadigan joyga keltiradi (kadr uchun).
  Future<Finder> reveal(String text) async {
    final f = find.text(text);
    if (f.hitTestable().evaluate().isEmpty) {
      await tester.drag(scrollable(), const Offset(0, 3000));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        f.hitTestable(),
        200,
        scrollable: scrollable(),
      );
    }
    await tester.pumpAndSettle();
    await centerOn(tester, f.hitTestable().last);
    return f.hitTestable().last;
  }
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _snackGone(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<(AppServices, FakeLabBackend)> _boot(WidgetTester tester) async {
  installDiffFakes();
  final b = FakeLabBackend();
  final s = await start(
    tester,
    role: AppRole.teacher,
    backend: b,
    size: size,
  );
  return (s, b);
}

/// Ustoz tomoni: ro'yxatdan o'tish, guruh, ikki talaba, mavzu ochish.
Future<String> _prepareGroup(
  WidgetTester tester,
  AppServices s,
  FakeLabBackend b,
  AppLocalizations l,
) async {
  await _signIn(tester, s, 'ustoz@example.com');
  await b.registerTeacher();
  final g = await b.createGroup(_group);
  for (final e in ['s1@example.com', 's2@example.com']) {
    await _signIn(tester, s, e);
    await b.joinGroup(g.joinCode!);
  }
  await _signIn(tester, s, 'ustoz@example.com');
  return g.id;
}

String _topicTitle(AppServices s) => s.curriculum.curriculum!.topics
    .firstWhere((t) => t.id == _topic)
    .title
    .of('uz');

/// Talaba test topshiradi (soxta orqa tomon orqali) — [wrong] bo'lsa
/// toq savollarga xato javob.
Future<void> _studentTakes(
  WidgetTester tester,
  AppServices s,
  FakeLabBackend b,
  Walk w,
  AppLocalizations l,
  String gid,
  String email, {
  bool wrong = false,
  Rec? rec,
  String prefix = '',
}) async {
  await _signIn(tester, s, email);
  await goTo(tester, '/learn/classes/g/$gid/t/$_topic');
  final a = (await b.assignments(gid)).single;
  rec?.on = prefix.isNotEmpty;
  await rec?.shot('${prefix}topic_test', target: await w.reveal(l.classroomTestOpenStudent));
  await w.tapScroll(l.classroomTestOpenStudent);
  await rec?.shot('${prefix}test_intro', target: await w.reveal(l.classesStart));
  await w.tapScroll(l.classesStart);
  final run = s.exams.assignmentSession(a.id, b.userId)!;
  await rec?.shot('${prefix}question');
  for (var i = 0; i < run.length; i++) {
    final item = run.current;
    final q = ClassQuestionSource.of(
      s.content.pack!,
      s.toifa.bank,
    ).question(item.questionId)!;
    final idx = (wrong && i.isOdd)
        ? item.order.firstWhere((o) => !item.correct.contains(o))
        : item.correct.single;
    final opt = await w.reveal(q.option(idx, 'uz'));
    if (i == 0) await rec?.shot('${prefix}answer', target: opt);
    await w.tap(opt);
    if (i == 0) await rec?.shot('${prefix}answered', target: await w.reveal(l.examNext));
    if (i < run.length - 1) await w.tapScroll(l.examNext);
  }
  await rec?.shot('${prefix}finish', target: await w.reveal(l.examFinish));
  await w.tapScroll(l.examFinish);
  await rec?.shot('${prefix}confirm', target: find.text(l.examFinish).hitTestable().last);
  await tester.tap(find.text(l.examFinish).hitTestable().last);
  await tester.pumpAndSettle();
  await rec?.shot('${prefix}result');
  rec?.on = true;
}

/// Ustoz mavzuni ochadi, ma'ruza va savol-javobni o'tadi, testni boshlaydi.
Future<void> _teacherRun(
  WidgetTester tester,
  Walk w,
  AppLocalizations l,
  String gid, {
  required bool startTest,
}) async {
  await goTo(tester, '/learn/classes/g/$gid/t/$_topic');
  await w.tapScroll(l.classroomOpenTopic);
  await w.tapScroll(l.classroomMarkDone);
  await w.tapScroll(l.classroomOralOpen);
  await w.tapScroll(l.classroomOralAsked);
  await goTo(tester, '/learn/classes/g/$gid/t/$_topic');
  await w.tapScroll(l.classroomMarkDone);
  if (!startTest) return;
  await w.tapScroll(l.classroomTestPrepare);
  await w.tapScroll(l.examMinutes(10));
  await w.tapScroll(l.classroomPickAll);
  final picked = tester
      .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
      .where((c) => c.value == true)
      .length;
  await w.tapScroll(l.classroomTestStart(picked));
}

void main() {
  setUpAll(loadAppFonts);

  // ---------------------------------------------------------------- 1
  testWidgets('v1 ustoz royxatdan otish', (tester) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(
      tester,
      onboarded: false,
      role: null,
      languageChosen: false,
      backend: b,
    );
    await pumpApp(tester, s, size: size);
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold).first);
      for (final p in ['logo_mark', 'logo_mark_large']) {
        await precacheImage(AssetImage('assets/images/$p.png'), ctx);
      }
    });
    await tester.pumpAndSettle();
    final r = Rec(tester, 'v1');
    final t = lookupAppLocalizations(const Locale('uz'));
    await r.shot('til', target: r.vis('O‘zbekcha'));
    await r.tapText('O‘zbekcha');
    await r.shot('welcome', target: r.vis(t.welcomeGetStarted));
    await r.tapText(t.welcomeGetStarted);
    await r.shot('auth', target: find.byType(TextField), kind: 'type');
    await tester.enterText(find.byType(TextField), 'ustoz@example.com');
    await tester.pumpAndSettle();
    await r.shot('auth_filled', target: r.vis(t.authConsent));
    await r.tapText(t.authConsent);
    await r.shot('auth_consent', target: r.vis(t.authGetCode));
    await r.tapText(t.authGetCode);
    await r.shot('otp', target: find.byType(TextField), kind: 'type');
    await tester.enterText(find.byType(TextField), FakeLabBackend.otpCode);
    await tester.pumpAndSettle();
    await r.shot('role', target: r.vis(t.roleTeacher));
    await r.tapText(t.roleTeacher);
    await r.shot('role_picked', target: r.vis(t.actionContinue));
    await r.tapText(t.actionContinue);
    await r.shot('home', target: r.vis(t.navLearn));
    await r.tapText(t.navLearn);
    await r.shot('learn', target: await r.reveal(t.classesTitle));
    await r.tapScroll(t.classesTitle);
    await r.shot('classes', target: r.vis(t.classesCreate), scrollTo: false);
    await r.tapScroll(t.classesCreate);
    await r.shot(
      'register',
      target: await r.reveal(t.classesTeacherRegister),
    );
    await r.tapScroll(t.classesTeacherRegister);
    await r.shot('registered', target: find.byType(TextField), kind: 'type');
    r.save();
  });

  // ---------------------------------------------------------------- 2
  testWidgets('v2 guruh yaratish', (tester) async {
    final (s, b) = await _boot(tester);
    final l = l10n(tester, AppLocalizations.of);
    await _signIn(tester, s, 'ustoz@example.com');
    await b.registerTeacher();
    await s.refreshAccess();
    await goTo(tester, '/learn/classes');
    final r = Rec(tester, 'v2');
    await r.shot('classes', target: r.vis(l.classesCreate), scrollTo: false);
    await r.tapScroll(l.classesCreate);
    await r.shot('create', target: find.byType(TextField), kind: 'type');
    await r.enter(l.classesGroupName, _group);
    await r.shot('named', target: await r.reveal(l.classesCreateAction));
    await r.tapScroll(l.classesCreateAction);
    await r.shot('code');
    await _snackGone(tester);
    final g = (await b.myGroups()).single;
    await r.shot('code_qr');
    await r.scroll(420);
    await r.shot('code_qr_low');
    // Talaba qo'shiladi.
    await _signIn(tester, s, 's1@example.com');
    await goTo(tester, '/learn/classes');
    await r.shot('student_classes', target: r.vis(l.classesJoin), scrollTo: false);
    await r.tapScroll(l.classesJoin);
    await r.shot('join', target: find.byType(TextField), kind: 'type');
    await r.enter(l.classesCode, g.joinCode!);
    await r.shot('join_code', target: await r.reveal(l.classesJoinAction));
    await r.tapScroll(l.classesJoinAction);
    await r.shot('joined');
    await _snackGone(tester);
    await _signIn(tester, s, 's2@example.com');
    await b.joinGroup(g.joinCode!);
    await _signIn(tester, s, 'ustoz@example.com');
    await goTo(tester, '/learn/classes/g/${g.id}');
    await r.shot('teacher_group');
    await tester.scrollUntilVisible(
      find.text(l.classesMembersTitle(2)).hitTestable(),
      200,
      scrollable: r.scrollable(),
    );
    await centerOn(
      tester,
      find.text(l.classesMembersTitle(2)),
      alignment: 0.2,
      force: true,
    );
    await r.shot('members');
    r.save();
  });

  // ---------------------------------------------------------------- 3
  testWidgets('v3 dars otish', (tester) async {
    final (s, b) = await _boot(tester);
    final l = l10n(tester, AppLocalizations.of);
    final gid = await _prepareGroup(tester, s, b, l);
    await goTo(tester, '/learn/classes');
    final r = Rec(tester, 'v3');
    await r.shot('classes', target: await r.reveal(_group));
    await r.tapScroll(_group);
    await r.shot('group', target: await r.reveal(l.classroomPlanTitle));
    await r.tapScroll(l.classroomPlanTitle);
    await r.shot('plan');
    await r.scroll(500);
    await r.shot('plan_low');
    final title = _topicTitle(s);
    await goTo(tester, '/learn/classes/g/$gid/plan');
    await r.shot('plan_topic', target: await r.reveal(title));
    await r.tapScroll(title);
    await r.shot('topic', target: await r.reveal(l.classroomOpenTopic));
    await r.tapScroll(l.classroomOpenTopic);
    await r.shot('opened');
    await r.scroll(450);
    await r.shot('lecture_stage', target: await r.reveal(l.lectureStart));
    await r.tapScroll(l.lectureStart);
    await r.shot('slide1', target: find.text('Oldinga'));
    await tester.tap(find.text('Oldinga'));
    await tester.pumpAndSettle();
    await r.shot('slide2');
    routerOf(tester).pop();
    await tester.pumpAndSettle();
    await r.shot('back', target: await r.reveal(l.classroomMarkDone));
    await r.tapScroll(l.classroomMarkDone);
    await r.shot('lecture_done');
    await r.scroll(400);
    await r.shot('oral_stage', target: await r.reveal(l.classroomOralOpen));
    await r.tapScroll(l.classroomOralOpen);
    await r.shot('oral');
    await r.scroll(450);
    await r.shot('oral_low', target: await r.reveal(l.classroomOralAsked));
    await r.tapScroll(l.classroomOralAsked);
    await r.shot('asked');
    r.save();
  });

  // ---------------------------------------------------------------- 4
  testWidgets('v4 test otkazish', (tester) async {
    final (s, b) = await _boot(tester);
    final l = l10n(tester, AppLocalizations.of);
    final gid = await _prepareGroup(tester, s, b, l);
    final w = Walk(tester, 'x');
    await _teacherRun(tester, w, l, gid, startTest: false);
    await goTo(tester, '/learn/classes/g/$gid/t/$_topic');
    final r = Rec(tester, 'v4');
    await r.shot('topic', target: await r.reveal(l.classroomTestPrepare));
    await r.tapScroll(l.classroomTestPrepare);
    await r.shot('setup');
    await r.shot('minutes', target: await r.reveal(l.examMinutes(10)));
    await r.tapScroll(l.examMinutes(10));
    await r.shot('pick_all', target: await r.reveal(l.classroomPickAll));
    await r.tapScroll(l.classroomPickAll);
    final picked = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .where((c) => c.value == true)
        .length;
    final start = l.classroomTestStart(picked);
    await r.shot('picked', target: await r.reveal(start));
    await r.tapScroll(start);
    await _snackGone(tester);
    await r.shot('started');
    await _studentTakes(tester, s, b, w, l, gid, 's1@example.com',
        rec: r, prefix: 's_');
    await _studentTakes(tester, s, b, w, l, gid, 's2@example.com',
        wrong: true);
    await _signIn(tester, s, 'ustoz@example.com');
    await goTo(tester, '/learn/classes/g/$gid/t/$_topic');
    await r.shot('teacher_state', target: await r.reveal(l.classroomTestResults));
    await r.tapScroll(l.classroomTestResults);
    await r.shot('results');
    await tester.scrollUntilVisible(
      find.text(l.classesResults).hitTestable(),
      200,
      scrollable: r.scrollable(),
    );
    await centerOn(
      tester,
      find.text(l.classesResults).hitTestable().last,
      alignment: 0.12,
      force: true,
    );
    await r.shot('results_students');
    await tester.scrollUntilVisible(
      find.text(l.classesByQuestion).hitTestable(),
      200,
      scrollable: r.scrollable(),
    );
    await centerOn(
      tester,
      find.text(l.classesByQuestion).hitTestable().last,
      alignment: 0.12,
      force: true,
    );
    await r.shot('results_low');
    await goTo(tester, '/learn/classes/g/$gid/t/$_topic');
    await r.shot('finish_test', target: await r.reveal(l.classroomTestFinish));
    r.save();
  });

  // ---------------------------------------------------------------- 5
  testWidgets('v5 talaba', (tester) async {
    final (s, b) = await _boot(tester);
    final l = l10n(tester, AppLocalizations.of);
    final w = Walk(tester, 'x');
    await _signIn(tester, s, 'ustoz@example.com');
    await b.registerTeacher();
    final g = await b.createGroup(_group);
    await s.refreshAccess();
    await _teacherRun(tester, w, l, g.id, startTest: true);
    await _signIn(tester, s, 's1@example.com');
    await s.settings.setRole(AppRole.student);
    await goTo(tester, '/learn');
    final r = Rec(tester, 'v5');
    await r.shot('learn', target: await r.reveal(l.classesTitle));
    await r.tapScroll(l.classesTitle);
    await r.shot('classes', target: r.vis(l.classesJoin), scrollTo: false);
    await r.tapScroll(l.classesJoin);
    await r.shot('join', target: find.byType(TextField), kind: 'type');
    await r.enter(l.classesCode, g.joinCode!);
    await r.shot('code_typed', target: await r.reveal(l.classesJoinAction));
    await r.tapScroll(l.classesJoinAction);
    await r.shot('joined');
    await _snackGone(tester);
    await r.shot('group');
    await _studentTakes(tester, s, b, w, l, g.id, 's1@example.com',
        rec: r, prefix: 's_');
    r.save();
  });
}
