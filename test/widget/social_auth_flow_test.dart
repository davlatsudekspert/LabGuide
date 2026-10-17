import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/auth/social_auth.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:labguide/l10n/gen/app_localizations_ru.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/social_fakes.dart';
import 'app_flow_test.dart' show tapText;

final uz = AppLocalizationsUz();
final ru = AppLocalizationsRu();
final en = AppLocalizationsEn();

/// Server + soxta provayderlar bilan servislar (kirish ekrani uchun).
Future<({AppServices services, FakeSocialBackend server})> setup(
  WidgetTester tester, {
  List<SocialIdentityProvider>? providers,
  FakeSocialBackend? server,
  AppLanguage language = AppLanguage.uz,
  bool onboarded = false,
}) async {
  final backend = server ?? FakeSocialBackend();
  final services = await makeServices(
    tester,
    language: language,
    onboarded: onboarded,
    role: onboarded ? AppRole.lab : null,
    socialAuth: SocialAuthService(
      providers:
          providers ??
          [
            FakeSocialProvider(SocialProvider.apple),
            FakeSocialProvider(SocialProvider.google),
          ],
      backend: backend,
    ),
  );
  return (services: services, server: backend);
}

Finder get appleButton => find.byType(SignInWithAppleButton);

void main() {
  setUpAll(loadAppFonts);

  testWidgets('provayder sozlanmagan build: tugmalar ham, “yoki” ham yo‘q', (
    tester,
  ) async {
    final s = await makeServices(tester, onboarded: false, role: null);
    await pumpApp(tester, s);
    await goTo(tester, '/welcome/auth');
    expect(find.text(uz.authGetCode), findsOneWidget);
    expect(appleButton, findsNothing);
    expect(find.text(uz.authSignInGoogle), findsNothing);
    expect(find.text(uz.authOr), findsNothing);
  });

  testWidgets('ikkala tugma: Apple birinchi, eni va balandligi bir xil', (
    tester,
  ) async {
    final s = await setup(tester, language: AppLanguage.en);
    await pumpApp(tester, s.services);
    await goTo(tester, '/welcome/auth');
    expect(appleButton, findsOneWidget);
    expect(find.text(en.authSignInApple), findsOneWidget);
    expect(find.text(en.authSignInGoogle), findsOneWidget);
    expect(find.text(en.authOr), findsOneWidget);
    final apple = tester.getRect(appleButton);
    final google = tester.getRect(find.byKey(const ValueKey('social-google')));
    expect(apple.top, lessThan(google.top));
    expect(apple.width, google.width);
    expect(apple.height, greaterThanOrEqualTo(google.height));
    // Email formasi ham joyida.
    expect(find.text(en.authGetCode), findsOneWidget);
  });

  testWidgets('server faqat Google yoqqan: Apple tugmasi yo‘q', (tester) async {
    final s = await setup(
      tester,
      server: FakeSocialBackend(status: const SocialServerStatus(google: true)),
    );
    await pumpApp(tester, s.services);
    await goTo(tester, '/welcome/auth');
    expect(appleButton, findsNothing);
    expect(find.text(uz.authSignInGoogle), findsOneWidget);
  });

  testWidgets('server javob bermasa yoki platforma qo‘llamasa: o‘lik tugma yo‘q', (
    tester,
  ) async {
    final dead = await setup(tester, server: FakeSocialBackend()..status = null);
    await pumpApp(tester, dead.services);
    await goTo(tester, '/welcome/auth');
    expect(appleButton, findsNothing);
    expect(find.text(uz.authSignInGoogle), findsNothing);
    await tester.pumpWidget(const SizedBox());

    final unsupported = await setup(
      tester,
      providers: [
        FakeSocialProvider(SocialProvider.apple, supported: false),
        FakeSocialProvider(SocialProvider.google),
      ],
    );
    await pumpApp(tester, unsupported.services);
    await goTo(tester, '/welcome/auth');
    expect(appleButton, findsNothing);
    expect(find.text(uz.authSignInGoogle), findsOneWidget);
  });

  testWidgets('shart qabul qilinmaguncha provayder ochilmaydi', (tester) async {
    final google = FakeSocialProvider(SocialProvider.google);
    final s = await setup(tester, providers: [google]);
    await pumpApp(tester, s.services);
    await goTo(tester, '/welcome/auth');
    await tapText(tester, uz.authSignInGoogle);
    expect(find.text(uz.authConsentRequired), findsOneWidget);
    expect(google.calls, 0);
    expect(s.services.auth.hasAccount, isFalse);
  });

  testWidgets('Google bilan muvaffaqiyatli kirish: rol ekraniga, hisob ochiq', (
    tester,
  ) async {
    final google = FakeSocialProvider(SocialProvider.google);
    final s = await setup(tester, providers: [google]);
    await pumpApp(tester, s.services);
    await goTo(tester, '/welcome/auth');
    await tapText(tester, uz.authConsent);
    await tapText(tester, uz.authSignInGoogle);
    expect(google.calls, 1);
    expect(s.server.signIns.single.provider, SocialProvider.google);
    expect(s.server.signIns.single.rawNonce, isNotEmpty);
    expect(s.services.auth.hasAccount, isTrue);
    expect(find.text(uz.rolesTitle), findsOneWidget);
  });

  testWidgets('Apple bilan muvaffaqiyatli kirish', (tester) async {
    final apple = FakeSocialProvider(SocialProvider.apple);
    final s = await setup(tester, providers: [apple]);
    await pumpApp(tester, s.services);
    await goTo(tester, '/welcome/auth');
    await tapText(tester, uz.authConsent);
    await tester.tap(appleButton);
    await tester.pumpAndSettle();
    expect(apple.calls, 1);
    expect(s.services.auth.hasAccount, isTrue);
    expect(find.text(uz.rolesTitle), findsOneWidget);
  });

  testWidgets('bekor qilish jim: xato ko‘rsatilmaydi, ekran o‘zgarmaydi', (
    tester,
  ) async {
    final google = FakeSocialProvider(SocialProvider.google, cancel: true);
    final s = await setup(tester, providers: [google]);
    await pumpApp(tester, s.services);
    await goTo(tester, '/welcome/auth');
    await tapText(tester, uz.authConsent);
    await tapText(tester, uz.authSignInGoogle);
    expect(google.calls, 1);
    expect(find.text(uz.authSocialFailed), findsNothing);
    expect(find.text(uz.authGenericError), findsNothing);
    expect(find.text(uz.authGetCode), findsOneWidget);
    expect(s.services.auth.hasAccount, isFalse);
    expect(s.server.signIns, isEmpty);
    // Qayta urinish mumkin.
    google.cancel = false;
    await tapText(tester, uz.authSignInGoogle);
    expect(s.services.auth.hasAccount, isTrue);
  });

  testWidgets('xatolar mahalliy matn bilan; til almashsa matn ham yangilanadi', (
    tester,
  ) async {
    final apple = FakeSocialProvider(
      SocialProvider.apple,
      error: const SocialAuthException('apple: failed'),
    );
    final s = await setup(tester, providers: [apple]);
    await pumpApp(tester, s.services);
    await goTo(tester, '/welcome/auth');
    await tapText(tester, uz.authConsent);
    await tester.tap(appleButton);
    await tester.pumpAndSettle();
    expect(find.text(uz.authSocialFailed), findsOneWidget);
    expect(s.services.auth.hasAccount, isFalse);
    await s.services.settings.setLanguage(AppLanguage.ru);
    await tester.pumpAndSettle();
    expect(find.text(ru.authSocialFailed), findsOneWidget);

    // Server tomoni rad etsa: email tasdiqlanmagan.
    apple.error = null;
    s.server.result = const SocialSignInResult(
      SocialSignInStatus.emailNotVerified,
    );
    await tester.tap(appleButton);
    await tester.pumpAndSettle();
    expect(find.text(ru.authSocialEmailUnverified), findsOneWidget);
    expect(s.services.auth.hasAccount, isFalse);
  });

  testWidgets('Profildan kirish: profilga qaytiladi', (tester) async {
    final s = await setup(
      tester,
      providers: [FakeSocialProvider(SocialProvider.google)],
      onboarded: true,
    );
    await pumpApp(tester, s.services);
    await goTo(tester, '/profile/auth');
    await tapText(tester, uz.authConsent);
    await tapText(tester, uz.authSignInGoogle);
    expect(s.services.auth.hasAccount, isTrue);
    expect(routerOf(tester).state.matchedLocation, isNot('/profile/auth'));
  });

  testWidgets('mehmon rejimi hamon mavjud (tugmalar bilan ham)', (tester) async {
    final s = await setup(tester);
    await pumpApp(tester, s.services);
    expect(find.text(uz.welcomeGuest), findsOneWidget);
    await tapText(tester, uz.welcomeGuest);
    expect(find.text(uz.rolesTitle), findsOneWidget);
    expect(s.services.auth.hasAccount, isFalse);
  });

  for (final lang in AppLanguage.values) {
    testWidgets('320 px × 1.3 (${lang.name}): overflow yo‘q, ikkala tugma ko‘rinadi', (
      tester,
    ) async {
      final s = await setup(tester, language: lang);
      await pumpApp(tester, s.services, size: const Size(320, 3200), textScale: 1.3);
      await goTo(tester, '/welcome/auth');
      expect(tester.takeException(), isNull);
      final l = lookupAppLocalizations(lang.locale);
      expect(find.text(l.authSignInGoogle), findsOneWidget);
      expect(find.text(l.authSignInApple), findsOneWidget);
      // Xato xabari bilan ham.
      await tapText(tester, l.authSignInGoogle);
      expect(tester.takeException(), isNull);
      await s.services.settings.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final apple = tester.getSize(appleButton);
      expect(apple.width, lessThanOrEqualTo(320));
      expect(apple.height, kSocialHeight);
    });
  }

  group('hisobni o‘chirish va Apple', () {
    Future<(AppServices, _LinkedLab, FakeSocialProvider)> account(
      WidgetTester tester, {
      bool appleLinked = true,
      bool cancel = false,
      Object? error,
    }) async {
      final lab = _LinkedLab()
        ..linked = {if (appleLinked) SocialProvider.apple};
      final apple = FakeSocialProvider(
        SocialProvider.apple,
        cancel: cancel,
        error: error,
      );
      final services = await makeServices(
        tester,
        backend: lab,
        socialAuth: SocialAuthService(providers: [apple], backend: lab),
      );
      await tester.runAsync(() => services.auth.requestCode('apple@example.com'));
      await tester.runAsync(() => services.auth.verifyCode(FakeLabBackend.otpCode));
      return (services, lab, apple);
    }

    testWidgets('Apple bilan bog‘langan hisob: Apple tasdig‘i so‘raladi, kod serverga ketadi', (
      tester,
    ) async {
      final (s, lab, apple) = await account(tester);
      await pumpApp(tester, s);
      await goTo(tester, '/profile/privacy');
      await tapText(tester, uz.accountDelete);
      expect(find.textContaining(uz.accountDeleteAppleNote), findsOneWidget);
      await tester.tap(find.text(uz.actionDelete));
      await tester.pumpAndSettle();
      expect(apple.calls, 1);
      expect(lab.deletions, ['apple-auth-code']);
    });

    testWidgets('Apple tasdig‘i bekor qilinsa — hech narsa o‘chirilmaydi', (
      tester,
    ) async {
      final (s, lab, apple) = await account(tester, cancel: true);
      await pumpApp(tester, s);
      await goTo(tester, '/profile/privacy');
      await tapText(tester, uz.accountDelete);
      await tester.tap(find.text(uz.actionDelete));
      await tester.pumpAndSettle();
      expect(apple.calls, 1);
      expect(lab.deletions, isEmpty);
      expect(find.text(uz.accountDeleteAppleCancelled), findsOneWidget);
      expect(s.backend.hasSession, isTrue);
    });

    testWidgets('Apple oynasi xato bersa ham hisobni o‘chirish to‘silmaydi', (
      tester,
    ) async {
      final (s, lab, _) = await account(
        tester,
        error: const SocialAuthException('apple: failed'),
      );
      await pumpApp(tester, s);
      await goTo(tester, '/profile/privacy');
      await tapText(tester, uz.accountDelete);
      await tester.tap(find.text(uz.actionDelete));
      await tester.pumpAndSettle();
      expect(lab.deletions, [null]);
    });

    testWidgets('Apple bilan bog‘lanmagan hisob: Apple so‘ralmaydi', (tester) async {
      final (s, lab, apple) = await account(tester, appleLinked: false);
      await pumpApp(tester, s);
      await goTo(tester, '/profile/privacy');
      await tapText(tester, uz.accountDelete);
      expect(find.textContaining(uz.accountDeleteAppleNote), findsNothing);
      await tester.tap(find.text(uz.actionDelete));
      await tester.pumpAndSettle();
      expect(apple.calls, 0);
      expect(lab.deletions, [null]);
    });
  });
}

const kSocialHeight = 52.0;

/// Soxta server hisobi + Apple identiteti.
class _LinkedLab extends FakeLabBackend implements SocialLoginBackend {
  Set<SocialProvider> linked = {};
  final deletions = <String?>[];

  @override
  Future<SocialServerStatus?> socialStatus() async =>
      const SocialServerStatus(google: true, apple: true, appleWeb: true);

  @override
  Future<SocialSignInResult> socialSignIn(SocialCredential credential) async =>
      const SocialSignInResult(SocialSignInStatus.success, email: 'x@example.com');

  @override
  Future<Set<SocialProvider>> linkedProviders() async => linked;

  @override
  Future<void> deleteAccountWithApple(String? appleAuthorizationCode) async {
    deletions.add(appleAuthorizationCode);
    await deleteAccount();
  }
}
