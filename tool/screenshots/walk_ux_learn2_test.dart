// O'rganish + kutubxona + profil: ru/en, kichik ekran, katta shrift, qorong'i.
//   flutter test tool/screenshots/walk_ux_learn2_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final (lang, code, role, size, scale, theme) in [
    (
      AppLanguage.ru,
      'ru',
      AppRole.lab,
      const Size(320, 640),
      1.35,
      ThemeMode.dark,
    ),
    (
      AppLanguage.en,
      'en',
      AppRole.lab,
      const Size(390, 844),
      1.0,
      ThemeMode.light,
    ),
    (
      AppLanguage.en,
      'en_doc',
      AppRole.doctor,
      const Size(390, 844),
      1.0,
      ThemeMode.light,
    ),
  ]) {
    testWidgets('screens $code', (tester) async {
      tester.platformDispatcher.localesTestValue = [Locale(lang.name, 'UZ')];
      await start(
        tester,
        lang: lang,
        role: role,
        size: size,
        textScale: scale,
        theme: theme,
      );
      final w = Walk(tester, 'ux2_$code');
      for (final r in [
        '/learn',
        '/learn/exam',
        '/learn/daily',
        '/learn/toifa',
        '/learn/toifa/oral',
        '/learn/toifa/progress',
        '/library',
        '/library/books',
        '/library/packs',
        '/profile',
      ]) {
        await goTo(tester, r);
        await w.snap(r.replaceAll('/', '_').substring(1));
      }
    });
  }
}
