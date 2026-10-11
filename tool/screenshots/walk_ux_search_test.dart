// UX: qidiruv va bo'sh holatlar, mehmon yo'li.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

void main() {
  setUpAll(loadAppFonts);
  final q = {
    AppLanguage.uz: ['glyukoza', 'qand', 'xyzxyz', 'ALT', 'jigar'],
    AppLanguage.ru: ['глюкоза', 'сахар', 'xyzxyz', 'АЛТ', 'печень'],
    AppLanguage.en: ['glucose', 'sugar', 'xyzxyz', 'ALT', 'liver'],
  };
  for (final lang in AppLanguage.values) {
    testWidgets('search ${lang.name}', (tester) async {
      await start(tester, role: AppRole.doctor, lang: lang);
      final w = Walk(tester, 'ux_search_${lang.name}');
      await goTo(tester, '/tests');
      var i = 0;
      for (final s in q[lang]!) {
        await tester.enterText(find.byType(TextField).first, s);
        await tester.pumpAndSettle();
        await w.snap('tests_${i++}_$s');
      }
      await goTo(tester, '/tests/conditions');
      i = 0;
      for (final s in q[lang]!) {
        await tester.enterText(find.byType(TextField).first, s);
        await tester.pumpAndSettle();
        await w.snap('cond_${i++}_$s');
      }
    });
  }
}
