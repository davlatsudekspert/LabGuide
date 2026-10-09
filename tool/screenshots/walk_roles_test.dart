// Har rol uchun ilovani boshidan oxirigacha ko'rib chiqish: bosh sahifa va 5 tab
// (walk_helper.dart). Rasmlar: tool/screenshots/out/walk/roles_<rol>_<til>/.
//   flutter test tool/screenshots/walk_roles_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Future<void> _tour(
  WidgetTester tester,
  AppRole role,
  AppLanguage lang, {
  ThemeMode theme = ThemeMode.light,
  double textScale = 1,
}) async {
  await start(
    tester,
    role: role,
    lang: lang,
    theme: theme,
    textScale: textScale,
  );
  final suffix = textScale > 1 ? '_katta' : '';
  final w = Walk(tester, 'roles_${role.name}_${lang.name}$suffix');
  await w.snap('bosh');
  await w.scroll(700);
  await w.snap('bosh_past');
  for (final tab in ['/tests', '/lab', '/library', '/learn']) {
    await goTo(tester, tab);
    await w.snap(tab.substring(1));
    await w.scroll(900);
    await w.snap('${tab.substring(1)}_past');
  }
  await goTo(tester, '/profile');
  await w.snap('profil');
}

void main() {
  setUpAll(loadAppFonts);

  for (final role in AppRole.values) {
    testWidgets('rol: ${role.name} (uz)', (tester) async {
      await _tour(tester, role, AppLanguage.uz);
    });
  }

  testWidgets('shifokor (ru, qorong‘i, katta shrift)', (tester) async {
    await _tour(
      tester,
      AppRole.doctor,
      AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.3,
    );
  });

  testWidgets('talaba (en)', (tester) async {
    await _tour(tester, AppRole.student, AppLanguage.en);
  });
}
