// Ustoz: taqdimotdan “Guruhga topshirish” (mavjud topshiriq mexanizmi,
// soxta server bilan) — guruhlar, savollar soni, muddat, javoblar qachon
// ko'rinadi; talaba Bosh sahifada testni muddati bilan ko'radi, topshiradi;
// “muddat tugagach” — javoblar yopiq; ustoz natijasi: taqsimot va eng qiyin
// savollar (slayd havolasi bilan).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/classroom/topic_test_screens.dart';
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
const _deck = 'd013';

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

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

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'ustoz deckdan 2 guruhga topshiradi; talaba ko‘radi, topshiradi; natijalar',
    (tester) async {
      installDiffFakes();
      final b = FakeLabBackend();
      final s = await makeServices(tester, backend: b, role: AppRole.teacher);
      await pumpApp(tester, s, size: _tall);
      await _signIn(tester, s, 'teacher@example.com');
      await b.registerTeacher();
      final gA = await b.createGroup('Gematologiya A');
      final gB = await b.createGroup('Gematologiya B');

      // Deckdan: test sahifasi → “Guruhga topshirish”.
      await goTo(tester, '/learn/lecture/test/$_deck');
      await _tapKey(tester, 'topic-test-assign');
      expect(find.text(uz.topicTestAssign), findsWidgets);
      expect(find.byKey(ValueKey('assign-group-${gA.id}')), findsOneWidget);
      expect(find.byKey(ValueKey('assign-group-${gB.id}')), findsOneWidget);

      // Guruh tanlanmagan — yuborilmaydi.
      await _tapKey(tester, 'assign-send');
      expect(find.text(uz.topicTestPickGroup), findsOneWidget);
      expect(await b.assignments(gA.id), isEmpty);

      // “Muddat tugagach” muddatsiz bo'lmaydi.
      await _tapKey(tester, 'assign-group-${gA.id}');
      await _tapKey(tester, 'assign-group-${gB.id}');
      await _tapKey(tester, 'assign-due-none');
      await _tapKey(tester, 'assign-reveal-after');
      expect(find.text(uz.topicTestRevealNeedsDue), findsOneWidget);
      await _tapKey(tester, 'assign-due-d3');
      expect(find.text(uz.topicTestRevealNeedsDue), findsNothing);
      // Savollar soni: 5.
      await tapScroll(tester, '5');
      await _tapKey(tester, 'assign-send');
      expect(find.text(uz.topicTestSent(2)), findsOneWidget);

      final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
      final pool = deckQuestionPool(
        c.byId(_deck)!,
        s.curriculum.curriculum,
        s.content.pack,
        s.toifa.bank,
      ).map((q) => q.id).toSet();
      for (final g in [gA, gB]) {
        final a = (await b.assignments(g.id)).single;
        expect(a.deckId, _deck);
        expect(a.topicId, 'd013-L');
        expect(a.revealAfterDue, isTrue);
        expect(a.dueAt, isNotNull);
        expect(a.questionIds.length, 5);
        expect(pool.containsAll(a.questionIds), isTrue);
        expect(a.title, uz.topicTestTitle(c.byId(_deck)!.title('uz')));
      }
      // Yuborilgan testlar ro'yxati (natijalarga havola).
      final aA = (await b.assignments(gA.id)).single;
      expect(find.byKey(ValueKey('sent-${aA.id}')), findsOneWidget);

      // Talaba: Bosh sahifada — berilgan test, muddati bilan.
      await _signIn(tester, s, 'teacher@example.com');
      final code = gA.joinCode!;
      await _signIn(tester, s, 'student@example.com');
      await b.joinGroup(code);
      await s.settings.setRole(AppRole.student);
      final row = find.byKey(ValueKey('assigned-${aA.id}'));
      await goTo(tester, '/home');
      await tester.scrollUntilVisible(
        row,
        300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(row, findsOneWidget);
      await goTo(tester, '/learn');
      await tester.scrollUntilVisible(
        row,
        300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(
        find.descendant(
          of: row,
          matching: find.textContaining('Gematologiya A'),
        ),
        findsOneWidget,
      );
      await tester.tap(row);
      await tester.pumpAndSettle();
      await tapScroll(tester, uz.classesStart);
      final run = s.exams.assignmentSession(aA.id, b.userId)!;
      for (var i = 0; i < run.length; i++) {
        await _answer(tester, s, run, correct: i < 2);
        if (i < run.length - 1) await tapScroll(tester, uz.examNext);
      }
      await tapScroll(tester, uz.examFinish);
      await tester.tap(find.text(uz.examFinish).hitTestable().last);
      await tester.pumpAndSettle();
      // Muddatgacha: ball bor, to'g'ri javoblar yopiq.
      expect(find.text(uz.classesServerScore), findsOneWidget);
      final later0 = uz.topicTestAnswersLater('#').split('(').first.trim();
      expect(find.textContaining(later0), findsOneWidget);
      expect(find.text(uz.examAnalysis), findsNothing);
      expect((await b.submissions(aA.id)).single.correct, isNull);
      // Topshirilgan test Bosh sahifadan yo'qoladi.
      await goTo(tester, '/learn');
      expect(find.byKey(ValueKey('assigned-${aA.id}')), findsNothing);

      // Muddat o'tdi — xatolar tahlili ochiladi (slayd havolasi bilan).
      final later = aA.dueAt!.add(const Duration(minutes: 1));
      b.groupClock = () => later;
      s.exams.now = () => later;
      await goTo(tester, '/learn/classes/g/${gA.id}/a/${aA.id}');
      expect(find.text(uz.examAnalysis), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(SlideLink).first,
        300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(find.byType(SlideLink), findsWidgets);

      // Ustoz natijasi: kim topshirdi, o'rtacha, taqsimot, eng qiyin savollar.
      await _signIn(tester, s, 'teacher@example.com');
      await s.settings.setRole(AppRole.teacher);
      await goTo(tester, '/learn/classes/g/${gA.id}/a/${aA.id}');
      expect(find.text('40%'), findsWidgets);
      final dist = find.byKey(const ValueKey('score-distribution'));
      await tester.scrollUntilVisible(
        dist,
        300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(dist, findsOneWidget);
      expect(find.text(uz.topicTestHardest), findsOneWidget);
      final hardest = find
          .byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('hardest-'),
          )
          .first;
      await tester.ensureVisible(hardest);
      await tester.pumpAndSettle();
      final link = find.descendant(
        of: hardest,
        matching: find.byType(SlideLink),
      );
      expect(link, findsOneWidget);
      // Pleyer deck faylini birinchi kadrda o'qishi uchun — oldindan.
      await tester.runAsync(
        () => DeckCatalog.loadDeck(rootBundle, c.byId(_deck)!, 'uz'),
      );
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.byTooltip(uz.lectureClose), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  // E2E (docs/E2E_CLASSROOM_2026-10-18.md): deckdan berilgan testni ustoz
  // topshiriq sahifasidan yakunlay olmasdi; boshlamagan talabaga yakunlangan
  // test “Boshlash” bilan ko'rinardi; qurilma soati oldinda bo'lsa javoblar
  // server yopiq desa ham lokal kalitdan ochilardi.
  testWidgets('ustoz testni yakunlaydi; yakunlangan test va javoblar holati', (
    tester,
  ) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('Gematologiya A');
    final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
    final pool = deckQuestionPool(
      c.byId(_deck)!,
      s.curriculum.curriculum,
      s.content.pack,
      s.toifa.bank,
    ).take(3).toList();
    final due = b.groupClock().add(const Duration(days: 3));
    final aid = await b.createAssignment(
      groupId: g.id,
      title: 'Mavzu testi',
      questionIds: [for (final q in pool) q.id],
      correctIndexes: [for (final q in pool) q.correct.single],
      dueAt: due,
      dayId: 'd013-L',
      deckId: _deck,
      revealAfterDue: true,
    );
    await _signIn(tester, s, 'late@example.com');
    await b.joinGroup(g.joinCode!);
    await _signIn(tester, s, 'student@example.com');
    await b.joinGroup(g.joinCode!);
    await b.startAssignment(aid);
    await b.submitAssignment(aid, [for (final q in pool) q.correct.single]);
    final page = '/learn/classes/g/${g.id}/a/$aid';
    final later0 = uz.topicTestAnswersLater('#').split('(').first.trim();

    // Qurilma soati muddatdan o'tgan, server esa hali yopiq (correct: null)
    // — javoblar ochilmaydi.
    final realNow = s.exams.now;
    s.exams.now = () => due.add(const Duration(hours: 1));
    await goTo(tester, page);
    expect(find.textContaining(later0), findsOneWidget);
    expect(find.text(uz.examAnalysis), findsNothing);
    s.exams.now = realNow;

    // Ustoz: “Testni yakunlash” (tasdiq bilan).
    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, page);
    expect(find.byKey(const ValueKey('assignment-closed')), findsNothing);
    await _tapKey(tester, 'assignment-close');
    expect(find.text(uz.classroomTestFinishTitle), findsOneWidget);
    await tester.tap(find.text(uz.classroomTestFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('assignment-closed')), findsOneWidget);
    expect(find.byKey(const ValueKey('assignment-close')), findsNothing);
    expect((await b.assignments(g.id)).single.closed, isTrue);

    // Boshlamagan talaba: “Test yakunlandi”, “Boshlash” yo'q; ro'yxatda ham.
    await _signIn(tester, s, 'late@example.com');
    await goTo(tester, page);
    expect(find.byKey(const ValueKey('assignment-closed')), findsOneWidget);
    expect(find.text(uz.classesStart), findsNothing);
    await expectLater(b.startAssignment(aid), throwsA(isA<BackendException>()));
    await goTo(tester, '/learn/classes/g/${g.id}');
    expect(find.text(uz.classroomStatusTestDone), findsOneWidget);
    expect(find.text(uz.classesStatusNew), findsNothing);

    // Topshirgan talaba: yakunlangach javoblar tahlili ochiq.
    await _signIn(tester, s, 'student@example.com');
    await goTo(tester, page);
    expect(find.text(uz.examAnalysis), findsOneWidget);
    expect(find.textContaining(later0), findsNothing);
  });

  testWidgets('guruh yo‘q — guruh ochish taklifi', (tester) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/learn/lecture/test/$_deck/assign');
    expect(find.text(uz.topicTestNoGroups), findsOneWidget);
    expect(find.text(uz.topicTestCreateGroup), findsOneWidget);
  });
}
