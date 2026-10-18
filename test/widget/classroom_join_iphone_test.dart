// iPhone xatosi (2026-10-18, docs/BUGS_2026-10-18_IPHONE.md): "talaba
// sifatida testga qo'shila olmayman". Har bir yo'l uchun foydalanuvchi
// aniq, tarjima qilingan sabab va keyingi qadamni ko'radi:
// - ustoz o'z guruhi kodini / test QR'ini ochdi (Profilda rol "talaba"
//   bo'lsa ham) → “Siz bu guruhning ustozisiz” + ustoz sifatida ochish,
//   talaba ko'rinishida sinash (natija yuborilmaydi), boshqa hisob;
// - ikkinchi hisob: kichik harf/bo'shliqli kod, iPhone apostrofi (’);
// - noto'g'ri taxallus, 0/O/1/I li kod, server xatolari (aniq matn);
// - yangi o'rnatilgan ilova: taklif havolasi onboardingdan keyin ochiladi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/learn/classes_screens.dart';
import 'package:labguide/features/learn/exam_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
const _tall = Size(390, 1800);

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

Future<({String gid, String aid, String code})> _prepare(
  WidgetTester tester,
  AppServices s,
  FakeLabBackend b,
) async {
  await _signIn(tester, s, 'teacher@example.com');
  await b.registerTeacher();
  final g = await b.createGroup('Ali');
  final qs = s.content.pack!.quiz.take(3).toList();
  final aid = await b.createAssignment(
    groupId: g.id,
    title: 'Mavzu testi',
    questionIds: [for (final q in qs) q.id],
    correctIndexes: [for (final q in qs) q.correctIndex],
  );
  return (gid: g.id, aid: aid, code: g.joinCode!);
}

Future<int> _members(FakeLabBackend b, String gid) async =>
    (await b.groupMembers(gid)).length;

void main() {
  setUpAll(loadAppFonts);

  testWidgets('ustoz o‘z guruhi kodini kiritdi (Profilda rol — talaba): '
      'aniq sabab va yo‘l', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    // Egasi Profilda rolni "talaba"ga almashtirdi — server huquqi o'zgarmaydi.
    await s.settings.setRole(AppRole.student);
    final before = await _members(b, t.gid);

    await goTo(tester, '/learn/classes/join');
    await tester.enterText(
      find.byKey(const ValueKey('join-code')),
      t.code.toLowerCase(),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ali');
    await _tapKey(tester, 'join-submit');

    expect(find.byKey(const ValueKey('join-own-group')), findsOneWidget);
    expect(find.text(uz.classesOwnGroupTitle), findsOneWidget);
    expect(find.text(uz.classesOwnGroupBody), findsOneWidget);
    expect(find.byType(GroupScreen), findsNothing, reason: 'qo‘shilmadi');
    expect(find.text(uz.classesOwnGroupOpen), findsOneWidget);
    expect(find.text(uz.classesSwitchAccount), findsOneWidget);
    expect(await _members(b, t.gid), before, reason: 'talaba bo‘lmadi');

    // Kod o'zgarsa — panel yo'qoladi.
    await tester.enterText(find.byKey(const ValueKey('join-code')), 'ABCD');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('join-own-group')), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('join-code')), t.code);
    await tester.pumpAndSettle();
    await _tapKey(tester, 'join-submit');

    // “Ustoz sifatida ochish” → guruh sahifasi (ustoz ko'rinishi).
    await _tapKey(tester, 'join-own-open');
    expect(find.byType(GroupScreen), findsOneWidget);
    expect(find.byType(JoinGroupScreen), findsNothing);
  });

  testWidgets('guruhlar ro‘yxati yuklanmagan bo‘lsa ham server javobidan '
      'keyin ustoz guruhi aniqlanadi', (tester) async {
    final b = _NoListOnceBackend();
    final s = await makeServices(tester, backend: b);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    b.failNextList = true;
    await goTo(tester, '/learn/classes/join');
    await tester.enterText(find.byKey(const ValueKey('join-code')), t.code);
    await tester.pumpAndSettle();
    await _tapKey(tester, 'join-submit');
    expect(find.byKey(const ValueKey('join-own-group')), findsOneWidget);
    expect(find.byType(GroupScreen), findsNothing);
  });

  testWidgets('ustoz test QR’ini ochdi → talaba ko‘rinishida sinash '
      '(natija yuborilmaydi)', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);

    await goTo(tester, '/j?c=${t.code}&a=${t.aid}');
    expect(find.byKey(const ValueKey('join-opens-test')), findsOneWidget);
    await _tapKey(tester, 'join-submit');
    expect(find.byKey(const ValueKey('join-own-group')), findsOneWidget);
    // Test bilan kelgan: asosiy tugma — talaba ko'rinishida sinash.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('join-own-open')),
        matching: find.text(uz.classesPreviewAsStudent),
      ),
      findsOneWidget,
    );
    await _tapKey(tester, 'join-own-open');
    // Test sahifasi (ustoz): sinash tugmasi.
    expect(find.byType(AssignmentScreen), findsOneWidget);
    expect(find.text(uz.classesPreviewNote), findsOneWidget);
    await _tapKey(tester, 'assignment-preview');
    expect(
      find.byKey(const ValueKey('assignment-preview-run')),
      findsOneWidget,
    );
    final run = tester.widget<ExamRunner>(find.byType(ExamRunner));
    await answerCurrent(tester, s, run.session, correct: true);
    await tapScroll(tester, uz.examFinish);
    await tester.tap(find.text(uz.examFinish).hitTestable().last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('assignment-preview-run')), findsNothing);
    expect(find.text(uz.classesPreviewResult(1, 3)), findsOneWidget);
    // Hech narsa yuborilmadi, lokal topshiriq sessiyasi ham yo'q.
    expect(await b.submissions(t.aid), isEmpty);
    expect(s.exams.assignmentSession(t.aid, b.userId), isNull);
    expect(s.exams.history, isEmpty);
  });

  testWidgets('ikkinchi hisob: kichik harf/bo‘shliqli kod va iPhone '
      'apostrofi (’) bilan qo‘shiladi', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: null);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    await _signIn(tester, s, 'second.phone@example.com');

    await goTo(tester, '/learn/classes/join');
    final spaced =
        '${t.code.substring(0, 4).toLowerCase()} ${t.code.substring(4)}';
    await tester.enterText(find.byKey(const ValueKey('join-code')), spaced);
    await tester.pumpAndSettle();
    expect(find.text(t.code), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'G’ayrat');
    await _tapKey(tester, 'join-submit');

    expect(find.byType(GroupScreen), findsOneWidget, reason: 'qo‘shildi');
    expect(find.byKey(const ValueKey('join-own-group')), findsNothing);
    expect(s.settings.role, AppRole.student, reason: 'rol avtomatik');
    await _signIn(tester, s, 'teacher@example.com');
    final m = await b.groupMembers(t.gid);
    expect(m.map((x) => x.alias), contains("G'ayrat"));
  });

  testWidgets('noto‘g‘ri taxallus va 0/O/1/I li kod — aniq sabab, '
      'serverga yuborilmaydi', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    await _signIn(tester, s, 'student@example.com');
    await goTo(tester, '/learn/classes/join');

    await tester.enterText(find.byKey(const ValueKey('join-code')), 'ABCD0123');
    await tester.pumpAndSettle();
    expect(find.text(uz.classesCodeAmbiguous), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('join-code')), t.code);
    await tester.enterText(find.byType(TextField).last, 'Ali 🙂');
    await _tapKey(tester, 'join-submit');
    expect(find.text(uz.classesNicknameInvalid), findsOneWidget);
    expect(await b.myGroups(), isEmpty, reason: 'qo‘shilmadi');

    await tester.enterText(find.byType(TextField).last, 'Ali');
    await _tapKey(tester, 'join-submit');
    expect(find.byType(GroupScreen), findsOneWidget);
  });

  testWidgets('yangi o‘rnatilgan ilova: taklif havolasi onboardingdan '
      'keyin qo‘shilish ekranini ochadi', (tester) async {
    final b = FakeLabBackend();
    final s = await makeServices(
      tester,
      backend: b,
      onboarded: false,
      role: null,
    );
    await pumpApp(tester, s, size: _tall);
    routerOf(tester).go('/j?c=ABCD2345&a=a1');
    await tester.pumpAndSettle();
    expect(find.byType(JoinGroupScreen), findsNothing);
    await s.settings.completeOnboarding();
    await tester.pumpAndSettle();
    expect(find.byType(JoinGroupScreen), findsOneWidget);
    final uri = routerOf(tester).routeInformationProvider.value.uri;
    expect(uri.path, '/learn/classes/join');
    expect(uri.queryParameters, {'code': 'ABCD2345', 'a': 'a1'});
  });

  test('server xatolari — aniq, tarjima qilingan matn', () {
    String text(BackendException e) => classesErrorText(e, uz);
    expect(
      text(
        const BackendException(
          BackendFailure.invalid,
          'POST /v1/groups/join 400',
          'invalid_nickname',
        ),
      ),
      uz.classesNicknameInvalid,
    );
    expect(
      text(
        const BackendException(BackendFailure.rateLimited, '', 'group_full'),
      ),
      uz.classesGroupFull,
    );
    expect(
      text(
        const BackendException(BackendFailure.invalid, '', 'nickname_taken'),
      ),
      uz.classesNicknameTaken,
    );
    expect(
      text(const BackendException(BackendFailure.notFound)),
      uz.classesCodeNotFound,
    );
    expect(text(const BackendException(BackendFailure.network)), uz.errNetwork);
    expect(
      text(const BackendException(BackendFailure.rateLimited)),
      uz.errRateLimited,
    );
    expect(
      text(const BackendException(BackendFailure.unauthorized)),
      uz.errSessionExpired,
    );
  });
}

/// Qo'shilish ekrani ochilganda guruhlar ro'yxati bir marta yuklanmaydi
/// (tarmoq uzilishi).
class _NoListOnceBackend extends FakeLabBackend {
  bool failNextList = false;

  @override
  Future<List<StudyGroup>> myGroups() async {
    if (failNextList) {
      failNextList = false;
      throw const BackendException(BackendFailure.network);
    }
    return super.myGroups();
  }
}
