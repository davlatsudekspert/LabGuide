import 'dart:async';

// Qo'llanma videolarini yozishda topilgan sinf UX muammolari
// (docs/TUTORIAL_VIDEOS.md, 2026-10-18; docs/BUGS_2026-10-18_IPHONE.md).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/auth/ui/role_screen.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_test_screens.dart';
import 'package:labguide/features/learn/classes_screens.dart';
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

void main() {
  setUpAll(loadAppFonts);

  testWidgets('3: “Yuborilgan testlar” qatori natijalarni ochadi '
      '(Navigator duplicate key yo‘q)', (tester) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('Gematologiya A');
    await goTo(tester, '/learn/lecture/test/$_deck');
    await _tapKey(tester, 'topic-test-assign');
    await _tapKey(tester, 'assign-due-d3');
    await _tapKey(tester, 'assign-send');
    final a = (await b.assignments(g.id)).single;
    await _tapKey(tester, 'sent-${a.id}');
    expect(tester.takeException(), isNull);
    expect(find.byType(AssignmentScreen), findsOneWidget);
    // Orqaga — guruh sahifasi (natija ichidan).
    await tester.tap(find.byTooltip(uz.actionBack).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(GroupScreen), findsOneWidget);
  });

  testWidgets('3b: guruhsiz ustoz «Guruh yaratish» — assertion yo‘q', (
    tester,
  ) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    await goTo(tester, '/learn/lecture/test/$_deck');
    await _tapKey(tester, 'topic-test-assign');
    await tester.tap(find.text(uz.topicTestCreateGroup));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CreateGroupScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Gematologiya A');
    await tester.tap(find.text(uz.classesCreateAction).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // Topshirishga qaytdi, yangi guruh tanlangan.
    expect(find.byType(CreateGroupScreen), findsNothing);
    final g = (await b.myGroups()).single;
    expect(find.byKey(ValueKey('assign-group-${g.id}')), findsOneWidget);
  });

  for (final (role, first) in [
    (AppRole.teacher, true),
    (AppRole.student, true),
    (AppRole.lab, false),
  ]) {
    testWidgets('1: O‘rganish — $role: «Guruh va topshiriqlar» '
        '${first ? 'birinchi ekranda, kartalardan oldin' : 'joyida'}', (
      tester,
    ) async {
      final s = await makeServices(tester, role: role);
      await pumpApp(tester, s, size: const Size(390, 844));
      await goTo(tester, '/learn');
      final row = find.byKey(const ValueKey('learn-classes'));
      final hero = find.byType(LgHeroCard);
      if (first) {
        expect(row.hitTestable(), findsOneWidget);
        expect(tester.getTopLeft(row).dy, lessThan(tester.getTopLeft(hero).dy));
      } else {
        // Laborant: avvalgi joyida (kartalardan keyin, birinchi ekrandan
        // pastda).
        expect(row.hitTestable(), findsNothing);
      }
    });
  }

  testWidgets('2: guruh sahifasidan «Mavzu testi berish» → qidiruv → '
      'Guruhga topshirish (guruh tanlangan, variant sozlamalari)', (
    tester,
  ) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final other = await b.createGroup('Boshqa guruh');
    final g = await b.createGroup('Ali');
    await goTo(tester, '/learn/classes/g/${g.id}');
    await _tapKey(tester, 'group-topic-test');
    expect(find.byType(DeckTestPickerScreen), findsOneWidget);
    final c = (await tester.runAsync(() => DeckCatalog.load(rootBundle)))!;
    final title = c.byId(_deck)!.title('uz');
    await tester.enterText(
      find.byKey(const ValueKey('deck-pick-search')),
      title.toLowerCase(),
    );
    await tester.pumpAndSettle();
    await _tapKey(tester, 'deck-pick-$_deck');
    expect(find.byType(AssignDeckTestScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('assign-variant')), findsOneWidget);
    expect(find.byKey(const ValueKey('assign-reveal-after')), findsOneWidget);
    await _tapKey(tester, 'assign-due-d3');
    await _tapKey(tester, 'assign-send');
    final a = (await b.assignments(g.id)).single;
    expect(a.deckId, _deck);
    expect(await b.assignments(other.id), isEmpty, reason: 'faqat shu guruh');
  });

  testWidgets('4: QR bilan taxallussiz — avval taxallus so‘raladi; '
      'guruh sahifasida taxallusni o‘zgartirish', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.student);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('Ali');
    await _signIn(tester, s, 'student@example.com');
    unawaited(
      routerOf(tester).push(
        '/learn/classes/join?code=${g.joinCode}',
        extra: JoinGroupScreen.autoJoinExtra,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('join-ask-nick')), findsOneWidget);
    expect(await b.myGroups(), isEmpty, reason: 'hali qo‘shilmadi');
    await tester.enterText(find.byType(TextField).last, 'Lola');
    await _tapKey(tester, 'join-submit');
    expect(find.byType(GroupScreen), findsOneWidget);
    expect((await b.myGroups()).single.myNickname, 'Lola');

    // Guruh sahifasida taxallusni o'zgartirish.
    await _tapKey(tester, 'group-nickname');
    await tester.enterText(
      find.byKey(const ValueKey('nickname-field')),
      'G’ayrat',
    );
    await _tapKey(tester, 'nickname-save');
    expect((await b.myGroups()).single.myNickname, "G'ayrat");
    expect(find.text("G'ayrat"), findsOneWidget);

    // Taxallusi bor talaba boshqa guruhga QR bilan — darhol qo'shiladi.
    await _signIn(tester, s, 'teacher@example.com');
    final g2 = await b.createGroup('Vali');
    await _signIn(tester, s, 'student@example.com');
    unawaited(
      routerOf(tester).push(
        '/learn/classes/join?code=${g2.joinCode}',
        extra: JoinGroupScreen.autoJoinExtra,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('join-ask-nick')), findsNothing);
    expect(await b.myGroups(), hasLength(2));
  });

  testWidgets('5, 6, 9: muddatli vaqtsiz test — sana, taymer emas; ustozda '
      '«Yechmoqda»; uzun nom 2 qator, Test QR tepada', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.student);
    await pumpApp(tester, s, size: const Size(390, 844));
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('Ali');
    final qs = s.content.pack!.quiz.take(3).toList();
    const long =
        'Mavzu testi: Anemiyalar. Klassifikatsiyasi, etiologiyasi va '
        'patogenezi, laborator diagnostikasi va differensial tashxisi';
    final aid = await b.createAssignment(
      groupId: g.id,
      title: long,
      questionIds: [for (final q in qs) q.id],
      correctIndexes: [for (final q in qs) q.correctIndex],
      dueAt: DateTime.now().add(const Duration(hours: 41)),
    );
    await _signIn(tester, s, 'student@example.com');
    await b.joinGroup(g.joinCode!, displayName: 'Lola');
    await goTo(tester, '/learn/classes/g/${g.id}/a/$aid');
    await tapScroll(tester, uz.classesStart);
    await tester.pumpAndSettle();
    // 5: “Muddat: …” — soat:daqiqa:soniya taymeri emas.
    expect(find.byKey(const ValueKey('exam-deadline-date')), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d+:\d\d:\d\d$')), findsNothing);
    // Test sahifasidan chiqiladi (sessiya saqlanadi — “Yechmoqda”).
    await tester.tap(find.byTooltip(uz.actionBack).last);
    await tester.pumpAndSettle();

    // 6: ustoz telefonida “Yechmoqda” (katta ekran bilan bir xil).
    await _signIn(tester, s, 'teacher@example.com');
    await s.settings.setRole(AppRole.teacher);
    await goTo(tester, '/learn/classes/g/${g.id}/a/$aid');
    await tester.pumpAndSettle();
    expect(find.text(uz.boardStarted), findsOneWidget);
    expect(find.text(uz.classesNotSubmitted), findsNothing);

    // 9: nom 2 qatorda qirqilgan; Test QR / Katta ekran birinchi ekranda.
    final qr = find.byKey(const ValueKey('assignment-test-qr'));
    expect(tester.getBottomLeft(qr).dy, lessThan(844 - 120));
    expect(find.byKey(const ValueKey('assignment-board')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lg-title-full')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text(long)),
      findsOneWidget,
    );
  });

  testWidgets('5b: vaqt chegarali testda taymer qoladi', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.student);
    await pumpApp(tester, s, size: _tall);
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('Ali');
    final qs = s.content.pack!.quiz.take(3).toList();
    final aid = await b.createAssignment(
      groupId: g.id,
      title: 'Qisqa test',
      questionIds: [for (final q in qs) q.id],
      correctIndexes: [for (final q in qs) q.correctIndex],
      dueAt: DateTime.now().add(const Duration(hours: 41)),
      timeLimitMinutes: 10,
    );
    await _signIn(tester, s, 'student@example.com');
    await b.joinGroup(g.joinCode!);
    await goTo(tester, '/learn/classes/g/${g.id}/a/$aid');
    await tapScroll(tester, uz.classesStart);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('exam-deadline-date')), findsNothing);
    expect(find.textContaining(RegExp(r'^\d\d:\d\d$')), findsWidgets);
  });

  test('7: natija izohi — muddat YOKI ustoz yakunlaganda', () {
    expect(
      uz.topicTestAnswersLater('x'),
      contains('ustoz testni yakunlaganda'),
    );
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(ru.topicTestAnswersLater('x'), contains('завершит тест'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.topicTestAnswersLater('x'), contains('closes the test'));
  });

  testWidgets('8: rol «Ustoz» (kirgan hisob) — bir bosishda ro‘yxatdan '
      'o‘tadi; kirmagan — tushuntirish', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.lab);
    await pumpApp(tester, s, size: _tall);
    // Kirmagan: tushuntirish.
    await goTo(tester, '/profile/role');
    await tester.tap(find.text(AppRole.teacher.title(uz)));
    await tester.pumpAndSettle();
    expect(find.text(uz.rolesTeacherSignInNote), findsOneWidget);
    await tester.tap(find.byTooltip(uz.actionBack).last);
    await tester.pumpAndSettle();

    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/profile/role');
    await tester.tap(find.text(AppRole.teacher.title(uz)));
    await tester.pumpAndSettle();
    expect(find.text(uz.rolesTeacherRegisterNote), findsOneWidget);
    await _tapKey(tester, 'role-continue');
    expect(s.settings.role, AppRole.teacher);
    expect(s.access.access.teacher, isTrue);
    // Endi guruh darhol yaratiladi (alohida ro'yxatdan o'tish shart emas).
    final g = await b.createGroup('Ali');
    expect(g.isTeacher, isTrue);
  });
}
