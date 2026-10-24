import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/features/auth/social_auth.dart';
import 'package:labguide/features/auth/ui/social_buttons.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../helpers/harness.dart';
import '../helpers/social_fakes.dart';

final uz = AppLocalizationsUz();
final en = AppLocalizationsEn();

Finder get appleButton => find.byType(SignInWithAppleButton);
Finder get googleButton => find.byKey(const ValueKey('social-google'));

void main() {
  setUpAll(loadAppFonts);

  // App Store 4.8: kirish ekranidagi haqiqiy tugmalar,
  // {iOS, Android} × {Apple bor/yo‘q} × {Google bor/yo‘q}.
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final apple in [true, false]) {
      for (final google in [true, false]) {
        final appleShown = apple;
        final googleShown = google && (platform != TargetPlatform.iOS || apple);
        testWidgets('${platform.name} apple=$apple google=$google: '
            'Apple ${appleShown ? 'bor' : 'yo‘q'}, '
            'Google ${googleShown ? 'bor' : 'yo‘q'}, email formasi doim bor', (
          tester,
        ) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          final services = await makeServices(
            tester,
            onboarded: false,
            role: null,
            socialAuth: SocialAuthService(
              providers: [
                FakeSocialProvider(SocialProvider.apple, supported: apple),
                FakeSocialProvider(SocialProvider.google, supported: google),
              ],
              backend: FakeSocialBackend(),
            ),
          );
          await pumpApp(tester, services);
          await goTo(tester, '/welcome/auth');
          expect(appleButton, appleShown ? findsOneWidget : findsNothing);
          expect(googleButton, googleShown ? findsOneWidget : findsNothing);
          expect(find.text(uz.authGetCode), findsOneWidget);
          debugDefaultTargetPlatformOverride = null;
        });
      }
    }
  }

  testWidgets(
    'himoya qatlami: iOS’da SocialSignInButtons Apple’siz Google chizmaydi',
    (tester) async {
      Future<void> pump(List<SocialProvider> providers) => tester.pumpWidget(
        MaterialApp(
          theme: buildLgTheme(Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: AppLanguage.en.locale,
          home: Scaffold(
            body: SocialSignInButtons(providers: providers, onPressed: (_) {}),
          ),
        ),
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await pump(const [SocialProvider.google]);
      expect(googleButton, findsNothing);
      expect(find.text(en.authOr), findsNothing);
      await pump(const [SocialProvider.apple, SocialProvider.google]);
      expect(googleButton, findsOneWidget);
      expect(appleButton, findsOneWidget);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await pump(const [SocialProvider.google]);
      expect(googleButton, findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
