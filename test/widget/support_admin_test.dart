import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

/// Qabul tekshiruvi (UI darajasi): ikki test hisob (A, B) va alohida admin.
/// Server qoidalari `supabase/tests/10_acceptance.sql` da haqiqiy Postgres'da
/// alohida tekshiriladi; bu yerda ilova shu qoidalarga to'g'ri javob
/// berishini ko'ramiz.
const _a = 'tester.a@example.com';
const _b = 'tester.b@example.com';
const _admin = 'davlatsudekspert@gmail.com';

final _l = lookupAppLocalizations(const Locale('uz'));

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _signOut(WidgetTester tester, AppServices s) async {
  await s.auth.signOut();
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, int index, String value) async {
  final f = find.byType(TextField).at(index);
  await tester.ensureVisible(f);
  await tester.enterText(f, value);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('sozlanmagan build: murojaat “server ulanmagan” deydi', (
    tester,
  ) async {
    final services = await makeServices(tester);
    await pumpApp(tester, services);
    await goTo(tester, '/profile');
    // Profil uzaygan (Birliklar qatori) — qator ro'yxatda pastroqda.
    final sub = find.text('${_l.supportSub} · ${_l.notAvailableYet}');
    await tester.scrollUntilVisible(
      sub,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(sub, findsOneWidget);
    expect(find.text(_l.adminTitle), findsNothing);
    await _tapText(tester, _l.supportTitle);
    expect(find.text(_l.supportUnavailableTitle), findsOneWidget);
    expect(find.text(_l.supportNew), findsNothing);
  });

  testWidgets('mehmon: murojaat uchun kirish so‘raladi', (tester) async {
    final services = await makeServices(tester, backend: FakeLabBackend());
    await pumpApp(tester, services);
    await goTo(tester, '/profile/support');
    expect(find.text(_l.supportSignInTitle), findsOneWidget);
    await goTo(tester, '/profile/admin');
    expect(find.text(_l.supportSignInTitle), findsOneWidget);
    expect(find.text(_l.adminStats), findsNothing);
  });

  testWidgets('A → admin → A: murojaat, javob, qayta yozish, izolyatsiya', (
    tester,
  ) async {
    final backend = FakeLabBackend();
    final services = await makeServices(tester, backend: backend);
    await pumpApp(tester, services);

    // 1. A hisob: yangi murojaat (skrinshot ixtiyoriy, PHI eslatmasi bor).
    await _signIn(tester, services, _a);
    await goTo(tester, '/profile');
    expect(find.text(_l.adminTitle), findsNothing);
    await _tapText(tester, _l.supportTitle);
    expect(find.text(_l.supportEmptyTitle), findsOneWidget);
    await _tapText(tester, _l.supportNew);
    expect(find.text(_l.supportPhiNotice), findsOneWidget);
    await _tapText(tester, _l.supportKindBug);
    // Bo'sh mavzu — yuborilmaydi.
    await _tapText(tester, _l.supportSend);
    expect(backend.registeredCount, 1);
    expect(await backend.myThreads(), isEmpty);
    await _enter(tester, 0, 'QC grafigi');
    await _enter(tester, 1, 'Levey-Jennings ekranida nuqta ko‘rinmayapti');
    await _tapText(tester, _l.supportSend);
    expect(find.text(_l.supportSent), findsOneWidget);
    expect(find.text('QC grafigi'), findsOneWidget);
    final threadId = (await backend.myThreads()).single.id;
    expect((await backend.myThreads()).single.kind, SupportKind.bug);

    // 2. Admin: email mosligi admin qilmaydi — 2FA'siz panel ochilmaydi.
    await _signOut(tester, services);
    await _signIn(tester, services, _admin);
    await goTo(tester, '/profile');
    expect(find.text(_l.adminTitle), findsOneWidget);
    await _tapText(tester, _l.adminTitle);
    expect(find.text(_l.adminMfaTitle), findsOneWidget);
    expect(find.text(_l.adminStats), findsNothing);
    await _enter(tester, 0, '111111');
    await _tapText(tester, _l.adminMfaVerify);
    expect(find.text(_l.adminMfaWrong), findsOneWidget);
    await _enter(tester, 0, FakeLabBackend.totpCode);
    await _tapText(tester, _l.adminMfaVerify);
    expect(find.text(_l.adminStats), findsOneWidget);
    // Ro'yxatdan o'tgan: A va admin (mehmon sanalmaydi), har biri bir marta.
    expect(backend.registeredCount, 2);
    expect(find.text(_l.adminBilling), findsOneWidget);
    expect(find.text(_l.adminAwaiting(1)), findsOneWidget);

    await _tapText(tester, _l.adminInbox);
    expect(find.text('QC grafigi'), findsOneWidget);
    await _tapText(tester, 'QC grafigi');
    expect(
      find.text('Levey-Jennings ekranida nuqta ko‘rinmayapti'),
      findsOneWidget,
    );
    await _enter(tester, 0, 'Rahmat! Keyingi buildda tuzatamiz.');
    await _tapText(tester, _l.adminSendReply);
    expect(find.text('Rahmat! Keyingi buildda tuzatamiz.'), findsOneWidget);
    expect(backend.audit.map((e) => e.action), contains('support_reply'));

    // 3. B hisob: na A murojaati, na admin panel.
    await _signOut(tester, services);
    await _signIn(tester, services, _b);
    await goTo(tester, '/profile');
    expect(find.text(_l.adminTitle), findsNothing);
    expect(find.text(_l.supportUnreadCount(1)), findsNothing);
    await goTo(tester, '/profile/support');
    expect(find.text(_l.supportEmptyTitle), findsOneWidget);
    await goTo(tester, '/profile/support/thread/$threadId');
    expect(find.text('Rahmat! Keyingi buildda tuzatamiz.'), findsNothing);
    expect(
      find.text('Levey-Jennings ekranida nuqta ko‘rinmayapti'),
      findsNothing,
    );
    await goTo(tester, '/profile/admin');
    expect(find.text(_l.adminForbiddenTitle), findsOneWidget);
    expect(find.text(_l.adminStats), findsNothing);
    await expectLater(
      backend.adminStats(),
      throwsA(
        isA<BackendException>().having(
          (e) => e.failure,
          'failure',
          BackendFailure.forbidden,
        ),
      ),
    );

    // 4. A qayta kiradi: o'qilmagan javob belgisi, javob ko'rinadi, A yana
    // yozadi (murojaat yana “Yangi” bo'ladi).
    await _signOut(tester, services);
    await _signIn(tester, services, _a);
    await goTo(tester, '/profile');
    expect(find.text(_l.supportUnreadCount(1)), findsOneWidget);
    await _tapText(tester, _l.supportTitle);
    await _tapText(tester, 'QC grafigi');
    expect(find.text('Rahmat! Keyingi buildda tuzatamiz.'), findsOneWidget);
    expect(find.textContaining(_l.supportTeam), findsWidgets);
    await _enter(tester, 0, 'Tushunarli, kutaman.');
    await _tapText(tester, _l.supportSend);
    expect(find.text('Tushunarli, kutaman.'), findsOneWidget);
    expect((await backend.myThreads()).single.status, SupportStatus.newThread);
    expect(services.access.unreadReplies, 0);

    // 5. Qayta ochish: ilova qayta qurilganda yozishma saqlanib qoladi.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, services);
    await goTo(tester, '/profile/support/thread/$threadId');
    for (final text in [
      'Levey-Jennings ekranida nuqta ko‘rinmayapti',
      'Rahmat! Keyingi buildda tuzatamiz.',
      'Tushunarli, kutaman.',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('server sessiyani bekor qilsa — mehmon rejimiga qaytadi', (
    tester,
  ) async {
    final backend = FakeLabBackend();
    final services = await makeServices(tester, backend: backend);
    await pumpApp(tester, services);
    await _signIn(tester, services, _a);
    expect(services.auth.hasAccount, isTrue);
    backend.revokeSession();
    await tester.pumpAndSettle();
    expect(services.auth.hasAccount, isFalse);
    expect(services.access.access.adminAccount, isFalse);
  });

  testWidgets('admin foydalanuvchilar: niqoblangan email, ochish jurnalga', (
    tester,
  ) async {
    final backend = FakeLabBackend();
    final services = await makeServices(tester, backend: backend);
    await pumpApp(tester, services);
    await _signIn(tester, services, _a);
    await _signOut(tester, services);
    await _signIn(tester, services, _admin);
    await backend.mfaVerify(factorId: 'totp-1', code: FakeLabBackend.totpCode);
    await goTo(tester, '/profile/admin/users');
    expect(find.text(_a), findsNothing);
    expect(find.textContaining('te***@example.com'), findsOneWidget);
    await _tapText(
      tester,
      find
          .textContaining('te***@example.com')
          .evaluate()
          .map((e) => (e.widget as Text).data!)
          .first,
    );
    await _tapText(tester, _l.adminShowEmail);
    expect(find.text(_a), findsOneWidget);
    expect(backend.audit.map((e) => e.action), contains('reveal_email'));
  });
}
