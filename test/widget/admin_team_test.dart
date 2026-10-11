// Admin panel (D-44): boshqaruv sahifasi va adminlar boshqaruvi — uz/ru/en.
// Vakolat faqat server (soxta Cloudflare: FakeAdminTeamBackend) bergan holda;
// ilova email solishtirib hech narsa bermaydi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/fake_community.dart';
import '../helpers/harness.dart';

const _owner = 'davlatsudekspert@gmail.com';
const _helper = 'helper.lab@gmail.com';

AppLocalizations _l(AppLanguage lang) => lookupAppLocalizations(lang.locale);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<AppServices> _setup(
  WidgetTester tester,
  FakeLabBackend lab, {
  AppLanguage language = AppLanguage.uz,
}) async {
  final s = await makeServices(
    tester,
    language: language,
    backend: lab,
    community: FakeCommunityBackend(lab),
  );
  await pumpApp(tester, s);
  return s;
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _mfa(WidgetTester tester, AppLocalizations l) async {
  await tester.enterText(find.byType(TextField).last, FakeLabBackend.totpCode);
  await _tap(tester, find.text(l.adminMfaVerify));
}

/// Egasi serverda allaqachon [_helper] ni qo'shgan.
Future<FakeAdminTeamBackend> _withHelper() async {
  final lab = FakeAdminTeamBackend();
  await lab.requestCode(_owner);
  await lab.verifyCode(_owner, FakeLabBackend.otpCode);
  await lab.mfaVerify(factorId: 'totp-1', code: FakeLabBackend.totpCode);
  await lab.addAdmin(_helper);
  await lab.signOut();
  lab.addCalls.clear();
  return lab;
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('egasi: panel bo‘limlari, admin qo‘shish va olib tashlash '
        '(${lang.name})', (tester) async {
      final l = _l(lang);
      final lab = FakeAdminTeamBackend();
      final s = await _setup(tester, lab, language: lang);
      await _signIn(tester, s, _owner);
      await goTo(tester, '/profile');
      // Bitta kirish: moderatsiya alohida qator emas, panel ichida.
      expect(find.text(l.cmAdminTitle), findsNothing);
      await _tap(tester, find.text(l.adminTitle));
      // aal1 — faqat 2FA oynasi.
      expect(find.text(l.adminMfaTitle), findsOneWidget);
      expect(find.text(l.admTeam), findsNothing);
      await _mfa(tester, l);

      // Boshqaruv sahifasi: holat, bo'limlar, faqat haqiqiy ma'lumot.
      expect(find.text(l.admYouSuper), findsOneWidget);
      expect(find.text(l.cmAdminTitle), findsOneWidget);
      expect(find.text(l.admQueueEmpty), findsOneWidget);
      expect(find.text(l.admLaunchRow), findsOneWidget);
      expect(find.text(l.supportTitle), findsOneWidget);
      // Murojaatlar bu serverda yo'q — ochiq aytiladi, statistika ko'rinmaydi.
      expect(find.text(l.admNotConnected), findsOneWidget);
      expect(find.text(l.adminStats), findsNothing);
      expect(find.text(l.adminRegistered), findsNothing);
      await tester.scrollUntilVisible(
        find.text(l.admLegacyNote),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l.admReview), findsOneWidget);
      expect(find.text(l.admTeamCount(1)), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('admin-row-team')));

      // Adminlar boshqaruvi.
      expect(find.text(l.admAddTitle), findsOneWidget);
      expect(find.text('da***@gmail.com'), findsOneWidget);
      expect(find.text(_owner), findsNothing);
      expect(find.text(l.admNoGranted), findsOneWidget);
      // Super adminni olib tashlash tugmasi yo'q.
      expect(find.byTooltip(l.admRemove), findsNothing);

      // Noto'g'ri email — serverga yuborilmaydi.
      await tester.enterText(find.byType(TextField).first, 'not-an-email');
      await _tap(tester, find.byKey(const ValueKey('admin-team-add-button')));
      expect(find.text(l.admInvalidEmail), findsOneWidget);
      expect(lab.addCalls, isEmpty);

      // Tasdiqsiz qo'shilmaydi.
      await tester.enterText(
        find.byType(TextField).first,
        ' Helper.Lab@Gmail.com ',
      );
      await _tap(tester, find.byKey(const ValueKey('admin-team-add-button')));
      expect(find.text(l.admAddConfirmTitle), findsOneWidget);
      await tester.tap(find.text(l.actionCancel));
      await tester.pumpAndSettle();
      expect(lab.addCalls, isEmpty);

      await _tap(tester, find.byKey(const ValueKey('admin-team-add-button')));
      await tester.tap(find.text(l.admAddButton).last);
      await tester.pumpAndSettle();
      expect(lab.addCalls, hasLength(1));
      expect(find.text(l.admAdded('he***@gmail.com')), findsOneWidget);
      expect(find.text('he***@gmail.com'), findsOneWidget);
      expect(find.textContaining('helper.lab'), findsNothing);
      expect(find.text(l.admListTitle(2)), findsOneWidget);
      expect(find.textContaining(l.admNotSignedIn), findsOneWidget);

      // Takror — server xatosi tushunarli matn bilan.
      await tester.enterText(find.byType(TextField).first, _helper);
      await _tap(tester, find.byKey(const ValueKey('admin-team-add-button')));
      await tester.tap(find.text(l.admAddButton).last);
      await tester.pumpAndSettle();
      expect(find.text(l.admErrAlready), findsOneWidget);
      // Egasi emailini qo'shib bo'lmaydi.
      await tester.enterText(find.byType(TextField).first, _owner);
      await _tap(tester, find.byKey(const ValueKey('admin-team-add-button')));
      await tester.tap(find.text(l.admAddButton).last);
      await tester.pumpAndSettle();
      expect(find.text(l.admErrSuper), findsOneWidget);

      // Olib tashlash — tasdiq bilan.
      await _tap(tester, find.byTooltip(l.admRemove));
      expect(find.text(l.admRemoveTitle), findsOneWidget);
      expect(find.text(l.admRemoveBody('he***@gmail.com')), findsOneWidget);
      await tester.tap(find.text(l.actionCancel));
      await tester.pumpAndSettle();
      expect(find.text('he***@gmail.com'), findsOneWidget);
      await _tap(tester, find.byTooltip(l.admRemove));
      await tester.tap(find.text(l.admRemove).last);
      await tester.pumpAndSettle();
      expect(find.text(l.admRemoved('he***@gmail.com')), findsOneWidget);
      expect(find.text(l.admListTitle(1)), findsOneWidget);
      expect(
        lab.audit.map((e) => e.action),
        containsAll(['admin_grant_added', 'admin_grant_removed']),
      );
    });

    testWidgets('qo‘shilgan admin: to‘liq panel, lekin boshqaruvsiz '
        '(${lang.name})', (tester) async {
      final l = _l(lang);
      final lab = await _withHelper();
      final s = await _setup(tester, lab, language: lang);
      await _signIn(tester, s, _helper);
      await goTo(tester, '/profile');
      await _tap(tester, find.text(l.adminTitle));
      // Email mosligi emas — server bergan vakolat ham 2FA siz ochmaydi.
      expect(find.text(l.adminMfaTitle), findsOneWidget);
      await _mfa(tester, l);
      expect(find.text(l.admYouAdmin), findsOneWidget);
      expect(find.text(l.admLaunchRow), findsNothing);
      await _tap(tester, find.text(l.admReportsQueue));
      expect(find.text(l.cmAdminSuspended), findsOneWidget);
      expect(find.byKey(const ValueKey('cm-launch-card')), findsNothing);
      await goTo(tester, '/profile/admin/admins');
      expect(find.text(l.admTeamOwnerOnly), findsOneWidget);
      expect(find.text(l.admAddTitle), findsNothing);
      expect(find.byTooltip(l.admRemove), findsNothing);
      expect(find.text(l.admYou), findsOneWidget);
    });
  }

  testWidgets('olib tashlangan admin darhol panelni yo‘qotadi', (tester) async {
    final l = _l(AppLanguage.uz);
    final lab = await _withHelper();
    final s = await _setup(tester, lab);
    await _signIn(tester, s, _helper);
    await goTo(tester, '/profile/admin');
    await _mfa(tester, l);
    expect(find.text(l.admYouAdmin), findsOneWidget);
    // Egasi boshqa qurilmada olib tashladi.
    lab.revokeGrantFor(_helper);
    await goTo(tester, '/home');
    await goTo(tester, '/profile/admin/admins');
    expect(find.text(l.adminForbiddenTitle), findsOneWidget);
    expect(find.text(l.admTeamOwnerOnly), findsNothing);
    await goTo(tester, '/profile/admin');
    expect(find.text(l.adminForbiddenTitle), findsOneWidget);
  });

  testWidgets('oddiy foydalanuvchi: panel va adminlar sahifasi yopiq', (
    tester,
  ) async {
    final l = _l(AppLanguage.uz);
    final lab = await _withHelper();
    final s = await _setup(tester, lab);
    await _signIn(tester, s, 'someone@gmail.com');
    await goTo(tester, '/profile');
    expect(find.text(l.adminTitle), findsNothing);
    await goTo(tester, '/profile/admin/admins');
    expect(find.text(l.adminForbiddenTitle), findsOneWidget);
    expect(find.text(l.admAddTitle), findsNothing);
    expect(lab.addCalls, isEmpty);
  });

  testWidgets('adminlar boshqaruvisiz server: bo‘lim ko‘rinmaydi', (
    tester,
  ) async {
    final l = _l(AppLanguage.uz);
    final s = await _setup(tester, FakeLabBackend());
    await _signIn(tester, s, _owner);
    await goTo(tester, '/profile/admin');
    await _mfa(tester, l);
    expect(find.text(l.adminStats), findsOneWidget);
    expect(find.text(l.admTeam), findsNothing);
    expect(find.text(l.admLegacyNote), findsNothing);
    await goTo(tester, '/profile/admin/admins');
    expect(find.text(l.admNotConnected), findsOneWidget);
  });
}
