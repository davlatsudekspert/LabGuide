// Ilova ichidagi QR skaner (D-68), soxta skaner bilan (plagin kerak emas):
// - qo'shilish ekranidagi “QR kodni skanerlash” → test havolasi → tebranish,
//   skaner yopiladi, guruhga qo'shiladi va test darhol ochiladi;
// - begona QR — xabar, skaner ochiq qoladi; chiroq tugmasi;
// - “Guruh va topshiriqlar” dagi skaner → xom kod → guruh sahifasi;
// - kamera ruxsati yo'q: “Sozlamalarni ochish”, qaytganda qayta urinish,
//   “Kodni yozish” → kod maydoni;
// - veb/desktop (qo'llanmaydi) — tugmalar yo'q;
// - 320 px, 1.3× shrift, uz/ru/en — toshib ketish yo'q.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/classroom/invite_link.dart';
import 'package:labguide/features/classroom/qr_scanner.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/fake_qr_scanner.dart';
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

/// Ustoz guruh va test yaratadi; so'ng talaba sifatida kiriladi.
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
  await _signIn(tester, s, 'student@example.com');
  return (gid: g.id, aid: aid, code: g.joinCode!);
}

/// Tebranish chaqiruvlarini yozib boradi.
List<String> _recordHaptics(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add('${call.arguments}');
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('qo‘shilish ekrani: test QR → tebranish → qo‘shildi → test', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final qr = FakeQrScanner();
    final s = await makeServices(
      tester,
      backend: b,
      role: AppRole.student,
      qrScanner: qr,
    );
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);
    final haptics = _recordHaptics(tester);

    await goTo(tester, '/learn/classes/join');
    expect(find.text(uz.qrScanAction), findsOneWidget);
    await _tapKey(tester, 'join-scan');
    expect(find.byKey(const ValueKey('qr-scan-screen')), findsOneWidget);
    expect(find.text(uz.qrScanHint), findsOneWidget);
    final cam = qr.last!;

    // Chiroq.
    expect(cam.torchOn, isFalse);
    await tester.tap(find.byKey(const ValueKey('qr-torch')));
    await tester.pumpAndSettle();
    expect(cam.torchOn, isTrue);
    expect(find.byTooltip(uz.qrScanTorchOff), findsOneWidget);

    // Begona QR — xabar, skaner ochiq.
    cam.emit('WIFI:S:Lab;T:WPA;P:secret;;');
    await tester.pump();
    expect(find.byKey(const ValueKey('qr-not-invite')), findsOneWidget);
    expect(find.text(uz.qrScanNotInvite), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.byKey(const ValueKey('qr-not-invite')), findsNothing);
    expect(haptics, isEmpty);

    // Ustozning “Test QR” havolasi.
    cam.emit(inviteUrl(t.code, assignmentId: t.aid));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.mediumImpact']);
    expect(find.byKey(const ValueKey('qr-scan-screen')), findsNothing);
    expect(cam.disposed, isTrue);
    // Qo'shildi va test sahifasi ochildi.
    expect(find.text(uz.classesStart), findsOneWidget);
    expect(find.text('Mavzu testi'), findsWidgets);
    final groups = await b.myGroups();
    expect(groups.map((g) => g.id), contains(t.gid));
  });

  testWidgets('Guruh va topshiriqlar: skaner → xom kod → guruh sahifasi', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final qr = FakeQrScanner();
    final s = await makeServices(
      tester,
      backend: b,
      role: AppRole.student,
      qrScanner: qr,
    );
    await pumpApp(tester, s, size: _tall);
    final t = await _prepare(tester, s, b);

    await goTo(tester, '/learn/classes');
    await _tapKey(tester, 'classes-scan');
    qr.last!.emit('  ${t.code.toLowerCase()}\n');
    await tester.pumpAndSettle();
    // Qo'shilish ekrani o'zi yuboradi → guruh sahifasi (test emas).
    expect(find.byKey(const ValueKey('join-submit')), findsNothing);
    expect(find.text('Gematologiya A'), findsWidgets);
    expect(find.text(uz.classesStart), findsNothing);
    expect((await b.myGroups()).map((g) => g.id), contains(t.gid));

    // Deep link (extra yo'q) — avtomatik qo'shilmaydi.
    await goTo(tester, '/j?c=${t.code}');
    expect(find.byKey(const ValueKey('join-submit')), findsOneWidget);
  });

  testWidgets('ruxsat yo‘q: sozlamalar, qayta urinish, kodni yozish', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final qr = FakeQrScanner(initialStatus: QrCameraStatus.permissionDenied);
    final s = await makeServices(
      tester,
      backend: b,
      role: AppRole.student,
      qrScanner: qr,
    );
    await pumpApp(tester, s, size: _tall);
    await _prepare(tester, s, b);

    await goTo(tester, '/learn/classes/join');
    await _tapKey(tester, 'join-scan');
    expect(find.byKey(const ValueKey('qr-denied')), findsOneWidget);
    expect(find.text(uz.qrScanDeniedTitle), findsOneWidget);
    await tester.tap(find.text(uz.qrScanOpenSettings));
    await tester.pumpAndSettle();
    expect(qr.settingsOpened, 1);

    // Sozlamalardan qaytdi — kamera qayta ishga tushiriladi.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(qr.last!.retries, 1);
    // Ruxsat berildi — skaner ko'rinishi.
    qr.last!.status = QrCameraStatus.running;
    await tester.pump();
    expect(find.byKey(const ValueKey('qr-scan-screen')), findsOneWidget);
    qr.last!.status = QrCameraStatus.permissionDenied;
    await tester.pump();

    // Zaxira: kodni qo'lda yozish → kod maydoni fokusda.
    await tester.tap(find.byKey(const ValueKey('qr-type-code')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('qr-denied')), findsNothing);
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('join-code')),
    );
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('kamera ochilmadi — yozish yo‘li; yopish', (tester) async {
    final b = FakeLabBackend();
    final qr = FakeQrScanner(initialStatus: QrCameraStatus.failed);
    final s = await makeServices(
      tester,
      backend: b,
      role: AppRole.student,
      qrScanner: qr,
    );
    await pumpApp(tester, s, size: _tall);
    await _prepare(tester, s, b);
    await goTo(tester, '/learn/classes/join');
    await _tapKey(tester, 'join-scan');
    expect(find.text(uz.qrScanFailedTitle), findsOneWidget);
    expect(find.text(uz.qrScanOpenSettings), findsNothing);
    await tester.tap(find.byKey(const ValueKey('qr-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('join-submit')), findsOneWidget);
  });

  testWidgets('veb/desktop (qo‘llanmaydi) — skaner tugmalari yo‘q', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await makeServices(
      tester,
      backend: b,
      role: AppRole.student,
      qrScanner: FakeQrScanner(isSupported: false),
    );
    await pumpApp(tester, s, size: _tall);
    await _prepare(tester, s, b);
    await goTo(tester, '/learn/classes/join');
    expect(find.byKey(const ValueKey('join-scan')), findsNothing);
    expect(find.byKey(const ValueKey('join-paste')), findsOneWidget);
    await goTo(tester, '/learn/classes');
    expect(find.byKey(const ValueKey('classes-scan')), findsNothing);
  });

  test('plagin skaneri faqat Android va iOS da', () {
    for (final p in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = p;
      expect(
        const MobileQrScanner().isSupported,
        p == TargetPlatform.android || p == TargetPlatform.iOS,
        reason: '$p',
      );
    }
    debugDefaultTargetPlatformOverride = null;
  });

  group('320 px, 1.3× shrift', () {
    for (final lang in AppLanguage.values) {
      testWidgets('${lang.name}: qo‘shilish, skaner, ruxsat yo‘q', (
        tester,
      ) async {
        final b = FakeLabBackend();
        final qr = FakeQrScanner();
        final s = await makeServices(
          tester,
          backend: b,
          language: lang,
          role: AppRole.student,
          qrScanner: qr,
        );
        await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
        await _prepare(tester, s, b);
        final l = lookupAppLocalizations(lang.locale);

        await goTo(tester, '/learn/classes');
        expect(find.text(l.qrScanAction), findsOneWidget);
        expect(tester.takeException(), isNull);

        await goTo(tester, '/learn/classes/join');
        await _tapKey(tester, 'join-scan');
        qr.last!.emit('not a code');
        await tester.pump();
        expect(find.text(l.qrScanNotInvite), findsOneWidget);
        expect(find.text(l.qrScanTypeCode), findsOneWidget);
        expect(tester.takeException(), isNull);

        qr.last!.status = QrCameraStatus.permissionDenied;
        await tester.pumpAndSettle();
        expect(find.text(l.qrScanDeniedTitle), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text(l.qrScanTypeCode),
          80,
          scrollable: find.byType(Scrollable).last,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('qr-close')));
        await tester.pumpAndSettle();
      });
    }
  });
}
