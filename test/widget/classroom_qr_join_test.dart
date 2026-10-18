// QR / havola bilan qo'shilish va ustozning jonli natijalari:
// - hisobsiz talaba havola bilan keladi → kirish taklifi (kod saqlanadi) →
//   kirgach shu ekran → taxallus → qo'shiladi → test darhol ochiladi;
// - “Havolani qo'yish” (bufer) va kod maydoniga butun havolani qo'yish;
// - taxallus oldingi guruhdan oldindan to'ldiriladi, band taxallus — aniq xato;
// - QR havola formatida (kamera saytni ochadi); skaner tugmasi yo'q
//   (o'rnatilmagan — hisobotga qarang), o'rniga kamera yo'riqnomasi;
// - ustoz: “Test QR”, “Katta ekran”, natijalar o'zi yangilanadi.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/classroom/board_screen.dart';
import 'package:labguide/features/classroom/invite_link.dart';
import 'package:labguide/features/classroom/qr_code_view.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

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

void _clipboard(WidgetTester tester, String? text) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async => call.method == 'Clipboard.getData'
        ? (text == null ? null : {'text': text})
        : null,
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}

Future<({String gid, String aid, String code})> _prepare(
  WidgetTester tester,
  AppServices s,
  FakeLabBackend b,
) async {
  await _signIn(tester, s, 'teacher@example.com');
  await b.registerTeacher();
  final g = await b.createGroup('Gematologiya A');
  final qs = s.content.pack!.quiz.take(3).toList();
  final aid = await b.createAssignment(
    groupId: g.id,
    title: 'Mavzu testi',
    questionIds: [for (final q in qs) q.id],
    correctIndexes: [for (final q in qs) q.correctIndex],
  );
  return (gid: g.id, aid: aid, code: g.joinCode!);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('havola: kirish → taxallus → qo‘shilish → test darhol ochiladi', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: null);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    await s.auth.signOut();
    await tester.pumpAndSettle();

    // Kamera ochgan sayt → “Ilovada ochish” → labguide://app/j?c=..&a=..
    await goTo(tester, '/j?c=${t.code.toLowerCase()}&a=${t.aid}');
    expect(find.text(uz.classesJoinSignInTitle), findsOneWidget);
    expect(find.text(uz.classesJoinAction), findsNothing);

    // Kirgach — shu ekran, kod va test saqlangan.
    await _signIn(tester, s, 'new.student@example.com');
    expect(find.text(t.code), findsOneWidget);
    expect(find.byKey(const ValueKey('join-opens-test')), findsOneWidget);
    // Skaner plagini yo'q — kamera yo'riqnomasi va “Havolani qo'yish”.
    expect(find.text(uz.classesScanTip), findsOneWidget);
    expect(find.byKey(const ValueKey('join-paste')), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Lola');
    await _tapKey(tester, 'join-submit');
    // Test sahifasi (guruh sahifasi emas) va rol — talaba.
    expect(find.text(uz.classesStart), findsOneWidget);
    expect(find.text('Mavzu testi'), findsWidgets);
    expect(s.settings.role, AppRole.student);
  });

  testWidgets('Havolani qo‘yish; kod maydoniga butun havola; band taxallus', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.student);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    final other = await b.createGroup('Biokimyo B');
    // Boshqa guruhda “Lola” band.
    await _signIn(tester, s, 'lola@example.com');
    await b.joinGroup(t.code, displayName: 'Lola');
    await _signIn(tester, s, 'second@example.com');
    await b.joinGroup(other.joinCode!, displayName: 'Lola');

    await goTo(tester, '/learn/classes/join');
    // Taxallus oldingi guruhdan oldindan to'ldirildi.
    expect(find.widgetWithText(TextField, 'Lola'), findsOneWidget);

    // Bufer: axlat → xabar; havola → kod va test.
    _clipboard(tester, 'salom dunyo');
    await _tapKey(tester, 'join-paste');
    expect(find.text(uz.classesPasteNoCode), findsOneWidget);
    _clipboard(tester, inviteUrl(t.code, assignmentId: t.aid));
    await _tapKey(tester, 'join-paste');
    expect(find.text(t.code), findsOneWidget);
    expect(find.byKey(const ValueKey('join-opens-test')), findsOneWidget);

    // Kod maydoniga taklif matni qo'yilsa ham faqat kod qoladi.
    await tester.enterText(
      find.byKey(const ValueKey('join-code')),
      'Kod: ${t.code.substring(0, 4)}-${t.code.substring(4)}',
    );
    await tester.pumpAndSettle();
    expect(find.text(t.code), findsOneWidget);

    // Band taxallus — tushunarli xato, qo'shilmaydi.
    await _tapKey(tester, 'join-submit');
    expect(find.text(uz.classesNicknameTaken), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Lola'), 'Lola 2');
    await _tapKey(tester, 'join-submit');
    expect(find.text(uz.classesStart), findsOneWidget);
  });

  testWidgets('ustoz: QR havola, Test QR, Katta ekran, jonli yangilanish', (
    tester,
  ) async {
    installDiffFakes();
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);

    // Taklif paneli: QR — sayt havolasi (kod emas).
    await goTo(tester, '/learn/classes/g/${t.gid}');
    final qr = tester.widget<QrCodeView>(
      find.byKey(const ValueKey('invite-qr')),
    );
    expect(qr.data, inviteUrl(t.code));

    // Topshiriq: Test QR (kod + test id).
    await goTo(tester, '/learn/classes/g/${t.gid}/a/${t.aid}');
    await _tapKey(tester, 'assignment-test-qr');
    final dialogQr = tester.widget<QrCodeView>(
      find.descendant(
        of: find.byKey(const ValueKey('test-qr-dialog')),
        matching: find.byType(QrCodeView),
      ),
    );
    expect(dialogQr.data, inviteUrl(t.code, assignmentId: t.aid));
    await tester.tap(find.text(uz.actionClose));
    await tester.pumpAndSettle();
    expect(find.text(uz.classesLiveNote), findsOneWidget);

    // Talaba topshiradi — ustoz sahifasi 10 s ichida o'zi yangilanadi.
    final key = s.content.pack!.quiz.take(3).map((q) => q.correctIndex);
    await _signIn(tester, s, 'live@example.com');
    await b.joinGroup(t.code, displayName: 'Jonli');
    await _signIn(tester, s, 'teacher@example.com');
    await goTo(tester, '/learn/classes/g/${t.gid}/a/${t.aid}');
    expect(find.text('0 / 1'), findsOneWidget);
    await b.actAs('live@example.com', () async {
      await b.startAssignment(t.aid);
      await b.submitAssignment(t.aid, key.toList());
    });
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);

    // Katta ekran: gorizontal so'raladi, reyting va QR.
    await _tapKey(tester, 'assignment-board');
    expect(find.byKey(const ValueKey('lecture-rotate-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lecture-rotate-no')));
    await tester.pumpAndSettle();
    expect(find.byType(AssignmentBoardScreen), findsOneWidget);
    expect(find.text('Jonli'), findsOneWidget);
    final boardQr = tester.widget<QrCodeView>(
      find.byKey(const ValueKey('board-qr')),
    );
    expect(boardQr.data, inviteUrl(t.code, assignmentId: t.aid));
    expect(find.text('${uz.boardSubmitted}: 1 / 1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('board-exit')));
    await tester.pumpAndSettle();
    expect(find.byType(AssignmentBoardScreen), findsNothing);
  });
}
