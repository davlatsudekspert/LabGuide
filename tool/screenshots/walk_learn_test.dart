// O'rganish: imtihon rejimi va ustoz–talaba guruhlari — foydalanuvchi
// sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_learn_test.dart --update-goldens
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/auth/ui/welcome_screen.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/fake_backend.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

extension on Walk {
  /// Matnni topguncha pastga suradi (ro'yxat elementlari dangasa quriladi),
  /// keyin bosadi.
  Future<void> tapScroll(String text) async {
    final f = find.text(text);
    if (f.hitTestable().evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        f.hitTestable(),
        250,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .hitTestable()
            .first,
      );
    }
    await tap(f.hitTestable().last);
  }
}

/// Soat qotiriladi — taymer va sanalar har safar bir xil chiqadi.
DateTime _now = DateTime(2026, 10, 9, 9, 30);

Future<AppServices> _start(
  WidgetTester tester, {
  FakeLabBackend? backend,
  AppLanguage lang = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1,
  AppRole role = AppRole.student,
}) async {
  _now = DateTime(2026, 10, 9, 9, 30);
  final s = await makeServices(
    tester,
    language: lang,
    themeMode: theme,
    role: role,
    backend: backend,
  );
  s.exams.now = () => _now;
  s.exams.random = Random(7);
  backend?.groupClock = () => _now;
  await pumpApp(tester, s, textScale: textScale);
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold).first);
    await precacheImage(kHeroImage, ctx);
    await precacheImage(const AssetImage('assets/images/logo_mark.png'), ctx);
  });
  return s;
}

/// Snackbar o'z vaqtida yopiladi (tugmalarni to'sib qolmasin).
Future<void> _waitSnack(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _signOut(WidgetTester tester, AppServices s) async {
  await s.auth.signOut();
  await tester.pumpAndSettle();
}

/// Joriy savolga to'g'ri yoki noto'g'ri javob (ekrandagi matn bo'yicha).
Future<void> _answer(
  Walk w,
  AppServices s,
  ExamSession session, {
  required bool correct,
  String lang = 'uz',
}) async {
  final item = session.current;
  final q = s.content.pack!.quiz.firstWhere((q) => q.id == item.questionId);
  final idx = correct
      ? item.correct.single
      : item.order.firstWhere((o) => !item.correct.contains(o));
  await w.tapScroll(q.options[idx].text.of(lang));
}

ExamSession _assignmentSession(AppServices s) => s.exams.assignmentSession(
  s.backend.userId == null ? '' : _lastAssignment!,
  s.backend.userId,
)!;

String? _lastAssignment;

/// Ustoz guruh va topshiriqni server orqali tayyorlaydi (UI keyin ko'riladi).
Future<({String code, String group, String assignment})> _teacherSetup(
  WidgetTester tester,
  AppServices s,
  FakeLabBackend backend, {
  int count = 4,
}) async {
  await _signIn(tester, s, 'ustoz@example.com');
  final g = await backend.createGroup(
    'Biokimyo 2-kurs',
    displayName: 'Karimova N.A.',
  );
  final qs = s.content.pack!.quiz.take(count).toList();
  final a = await backend.createAssignment(
    groupId: g.id,
    title: '1-mavzu: hisoblar',
    questionIds: [for (final q in qs) q.id],
    correctIndexes: [for (final q in qs) q.correctIndex],
    dueAt: _now.add(const Duration(days: 2)),
    timeLimitMinutes: 15,
  );
  await _signOut(tester, s);
  return (code: g.joinCode!, group: g.id, assignment: a);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('talaba: imtihon, guruhga qo‘shilish, topshiriq (uz)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final backend = FakeLabBackend();
    final s = await _start(tester, backend: backend);
    final w = Walk(tester, 'learn_student_uz');

    // --- Imtihon rejimi (mehmon, internetsiz)
    await goTo(tester, '/learn');
    await w.snap('learn');
    await w.tapScroll(l.learnExam);
    await w.snap('imtihon_sozlash');
    await w.tapScroll('Buyrak funksiyasi · 8');
    await w.enter(l.examCount, '5');
    await w.enter(l.examTime, '10');
    await w.snap('sozlandi');
    await w.scroll(400);
    await w.snap('sozlandi_past');
    await w.tapScroll(l.examStart);
    await w.snap('savol_1');
    final exam = s.exams.active!;
    await _answer(w, s, exam, correct: true);
    await w.snap('javob_tanlandi');
    await w.tapScroll(l.examFlag);
    await w.tapScroll(l.examNext);
    _now = _now.add(const Duration(minutes: 2, seconds: 14));
    await _answer(w, s, exam, correct: false);
    await w.snap('savol_2_xato');
    await w.tapScroll(l.examNext);
    await _answer(w, s, exam, correct: true);
    await w.tapScroll(l.examNext);
    await w.tapScroll(l.examNext); // 4-savol javobsiz
    await _answer(w, s, exam, correct: true);
    _now = _now.add(const Duration(minutes: 6, seconds: 25));
    await w.snap('oxirgi_savol_kam_vaqt');
    await w.scroll(600);
    await w.snap('savollar_xaritasi');
    await w.tap(find.text(l.examFinish).hitTestable().last);
    await w.snap('yakunlash_oynasi');
    await w.tap(find.text(l.examFinish).hitTestable().last);
    await w.snap('natija');
    await w.scroll(500);
    await w.snap('natija_xatolar');
    await w.scroll(700);
    await w.snap('natija_xatolar_2');
    await w.scroll(-3000);
    await w.tapScroll(l.examReworkMistakes(2));
    await w.snap('xatolar_qayta_ishlash');
    // Orqaga — natijaga qaytadi; “Imtihon rejimi”da davom etayotgan imtihon.
    await w.tap(find.byTooltip(l.actionBack));
    await w.snap('natijaga_qaytdi');
    await goTo(tester, '/learn/exam');
    await w.snap('sozlash_davom_etayotgan');
    await w.scroll(1500);
    await w.snap('natijalar_tarixi');
    await goTo(tester, '/learn');
    await w.snap('learn_davom_etayotgan');

    // --- Guruh: ustoz tayyorlagan guruhga talaba kod bilan qo'shiladi
    final t = await _teacherSetup(tester, s, backend);
    await goTo(tester, '/learn/classes');
    await w.snap('guruhlar_kirish_kerak');
    await _signIn(tester, s, 'talaba@example.com');
    await goTo(tester, '/learn/classes');
    await w.snap('guruhlar_bosh');
    await w.tapScroll(l.classesJoin);
    await w.snap('qoshilish');
    await tester.enterText(find.byType(TextField).first, 'xxxx1111');
    await w.enter(l.classesDisplayName, 'Aliyev Anvar');
    await w.tapScroll(l.classesJoinAction);
    await w.snap('notogri_kod');
    await tester.enterText(find.byType(TextField).first, t.code.toLowerCase());
    await w.snap('kod_kiritildi');
    await w.tapScroll(l.classesJoinAction);
    await w.snap('guruh_talaba');
    await _waitSnack(tester);
    await w.tapScroll('1-mavzu: hisoblar');
    await w.snap('topshiriq_boshlash');
    await w.tapScroll(l.classesStart);
    _lastAssignment = t.assignment;
    final run = _assignmentSession(s);
    await w.snap('topshiriq_savol_1');
    for (var i = 0; i < run.length; i++) {
      await _answer(w, s, run, correct: i != 1);
      if (i < run.length - 1) await w.tapScroll(l.examNext);
    }
    await w.tap(find.text(l.examFinish).hitTestable().last);
    await w.tap(find.text(l.examFinish).hitTestable().last);
    await w.snap('topshiriq_natija');
    await w.scroll(600);
    await w.snap('topshiriq_xatolar');
    await w.tap(find.byTooltip(l.actionBack));
    await w.snap('guruh_topshirildi');
  });

  testWidgets('ustoz: guruh, topshiriq, natijalar (ru, qorong‘i, katta)', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final backend = FakeLabBackend();
    final s = await _start(
      tester,
      backend: backend,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
      role: AppRole.teacher,
    );
    final w = Walk(tester, 'learn_teacher_ru_dark_large');
    await _signIn(tester, s, 'ustoz@example.com');
    await goTo(tester, '/learn/classes');
    await w.snap('guruhlar_bosh');
    await w.tapScroll(l.classesCreate);
    await w.snap('yaratish');
    await w.enter(l.classesGroupName, 'Биохимия, 2 курс');
    await w.enter(l.classesDisplayName, 'Каримова Н.А.');
    await w.snap('yaratish_toldirildi');
    await w.tapScroll(l.classesCreateAction);
    await w.snap('guruh_kod');
    await _waitSnack(tester);
    await w.tapScroll(l.classesCopyInvite);
    await w.snap('nusxalandi');
    await _waitSnack(tester);
    await w.scroll(-2000);
    await w.tapScroll(l.classesNewAssignment);
    await w.snap('topshiriq_yangi');
    await w.enter(l.classesAssignmentTitle, 'Тема 1: почки');
    await w.tapScroll('Функция почек · 8');
    await w.enter(l.examCount, '4');
    await w.tapScroll(l.examMinutes(20));
    await w.tapScroll(l.classesDueDays(3));
    await w.snap('topshiriq_vaqt_muddat');
    await w.scroll(500);
    await w.snap('topshiriq_savollar');
    await w.scroll(800);
    await w.snap('topshiriq_yuborish');
    await w.tapScroll(l.classesSendAssignment);
    await w.snap('guruh_topshiriq_bilan');
    await _waitSnack(tester);

    // Ikki talaba qo'shiladi va topshiradi (server orqali).
    final g = (await backend.myGroups()).single;
    final a = (await backend.assignments(g.id)).single;
    final key = [
      for (final id in a.questionIds)
        s.content.pack!.quiz.firstWhere((q) => q.id == id).correctIndex,
    ];
    await _signOut(tester, s);
    for (final (email, name, wrong) in [
      ('s1@example.com', 'Алиев Анвар', 0),
      ('s2@example.com', 'Валиева Барно', 2),
    ]) {
      await _signIn(tester, s, email);
      await backend.joinGroup(g.joinCode!, displayName: name);
      await backend.startAssignment(a.id);
      await backend.submitAssignment(a.id, [
        for (final (i, k) in key.indexed) i < wrong ? (k + 1) % 3 : k,
      ]);
      await _signOut(tester, s);
    }
    await _signIn(tester, s, 'ustoz@example.com');
    await _signIn(tester, s, 's3@example.com');
    await backend.joinGroup(g.joinCode!, displayName: 'Саидов Тимур');
    await _signOut(tester, s);
    await _signIn(tester, s, 'ustoz@example.com');

    await goTo(tester, '/learn/classes/g/${g.id}');
    await w.snap('guruh_azolar');
    await w.scroll(900);
    await w.snap('guruh_azolar_past');
    await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
    await w.snap('natijalar_jadval');
    await w.scroll(700);
    await w.snap('natijalar_savollar');
    await w.scroll(-3000);
    await w.tapScroll('Валиева Барно');
    await w.snap('talaba_tafsilot');
    await w.scroll(700);
    await w.snap('talaba_tafsilot_past');
  });

  testWidgets('imtihon va guruhlar — en', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    final backend = FakeLabBackend();
    final s = await _start(
      tester,
      backend: backend,
      lang: AppLanguage.en,
      role: AppRole.teacher,
    );
    final w = Walk(tester, 'learn_en');
    await goTo(tester, '/learn/exam');
    await w.snap('exam_setup');
    await w.tapScroll(l.examCountAll(71));
    await w.tapScroll(l.examMinutes(10));
    await w.tapScroll(l.examStart);
    await w.snap('exam_run');
    // Vaqt tugaydi — imtihon o'zi yakunlanadi.
    _now = _now.add(const Duration(minutes: 11));
    await tester.pump(const Duration(seconds: 1));
    await w.snap('exam_timed_out_result');
    final t = await _teacherSetup(tester, s, backend);
    await _signIn(tester, s, 'student@example.com');
    await backend.joinGroup(t.code, displayName: 'Anvar Aliyev');
    await goTo(tester, '/learn/classes');
    await w.snap('classes_student');
    await goTo(tester, '/learn/classes/g/${t.group}');
    await w.snap('class_student_assignments');
    await goTo(tester, '/learn/classes/g/${t.group}/a/${t.assignment}');
    await w.snap('assignment_start');
    await _signOut(tester, s);
    await goTo(tester, '/learn/classes');
    await w.snap('classes_signed_out');
  });
}
