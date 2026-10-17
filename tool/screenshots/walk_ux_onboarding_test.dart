// UX: yangi o'rnatish oqimi (til → xush kelibsiz → email/OTP → rol → bosh) va mehmon yo'li.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);
  for (final lang in AppLanguage.values) {
    testWidgets('onboarding ${lang.name}', (tester) async {
      final s = await makeServices(
        tester,
        onboarded: false,
        role: null,
        languageChosen: false,
        language: lang,
      );
      await pumpApp(tester, s);
      // Logotip rasmlari oldindan dekod qilinadi (aks holda rasmda bo'sh
      // kulrang kvadrat chiqadi — haqiqiy ilovada bunday emas).
      await tester.runAsync(() async {
        final ctx = tester.element(find.byType(Scaffold).first);
        for (final a in ['logo_mark.png', 'logo_mark_large.png']) {
          await precacheImage(AssetImage('assets/images/$a'), ctx);
        }
      });
      await tester.pumpAndSettle();
      final w = Walk(tester, 'ux_onb_${lang.name}');
      await w.snap('til');
      final names = {'uz': 'O‘zbekcha', 'ru': 'Русский', 'en': 'English'};
      await w.tapText(names[lang.name]!);
      await w.snap('welcome');
      final t = l10n(tester, AppLocalizations.of);
      await w.tapText(t.welcomeGetStarted);
      await w.snap('auth');
      await tester.enterText(find.byType(TextField), 'doc@example.com');
      await tester.pumpAndSettle();
      await w.snap('auth_filled');
      await w.tapText(t.authConsent);
      await w.tapText(t.authGetCode);
      await w.snap('otp');
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();
      await w.snap('role');
      await w.scroll(600);
      await w.snap('role_past');
    });
  }
}
