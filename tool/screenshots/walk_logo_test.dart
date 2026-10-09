// Yangi logo: welcome, kirish va bosh sahifa sarlavhasi — kunduzgi va tungi
// rejim (walk_helper.dart). Rasmlar: tool/screenshots/out/walk/logo_*.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final (theme, lang) in [
    (ThemeMode.light, AppLanguage.uz),
    (ThemeMode.dark, AppLanguage.ru),
  ]) {
    testWidgets('logo: ${theme.name} ${lang.name}', (tester) async {
      await start(tester, theme: theme, lang: lang);
      final w = Walk(tester, 'logo_${theme.name}_${lang.name}');
      await goTo(tester, '/home');
      await w.snap('bosh_sarlavha');
      // Yangi foydalanuvchi: welcome va kirish ekranlari.
      final fresh = await makeServices(
        tester,
        language: lang,
        themeMode: theme,
        onboarded: false,
        role: null,
      );
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, fresh);
      await tester.runAsync(() async {
        final ctx = tester.element(find.byType(Scaffold).first);
        await precacheImage(
          const AssetImage('assets/images/logo_mark_large.png'),
          ctx,
        );
      });
      await goTo(tester, '/welcome');
      await w.snap('welcome');
      await goTo(tester, '/welcome/auth');
      await w.snap('kirish');
    });
  }
}
