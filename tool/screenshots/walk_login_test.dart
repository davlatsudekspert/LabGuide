// Kirish ekrani (email + Google/Apple tugmalari) — hozirgi holat uchun ekran rasmlari.
//   flutter test tool/screenshots/walk_login_test.dart --update-goldens
//   -> tool/screenshots/out/walk/login_*/NN_*.png
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/auth/social_auth.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/social_fakes.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      final tag = '${platform.name}_${theme == ThemeMode.light ? 'light' : 'dark'}';
      testWidgets('kirish ekrani ($tag)', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final s = await makeServices(
          tester,
          onboarded: false,
          role: null,
          language: AppLanguage.uz,
          themeMode: theme,
          socialAuth: SocialAuthService(
            providers: [
              FakeSocialProvider(SocialProvider.apple),
              FakeSocialProvider(SocialProvider.google),
            ],
            backend: FakeSocialBackend(),
          ),
        );
        await pumpApp(tester, s, size: const Size(390, 844));
        await goTo(tester, '/welcome/auth');
        final w = Walk(tester, 'login_$tag');
        await w.snap('kirish');
        expect(tester.takeException(), isNull);
        debugDefaultTargetPlatformOverride = null;
      });
    }
  }
}
