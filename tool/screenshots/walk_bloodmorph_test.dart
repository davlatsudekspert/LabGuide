// Qon morfologiyasi bo'limi — foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_bloodmorph_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/bloodmorph/bloodmorph_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

/// Rasmlar testda ham chizilsin (asset'lar oldindan dekodlanadi).
Future<void> precacheAll(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      final img = e.widget as Image;
      await precacheImage(img.image, e);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final (lang, w) in [(AppLanguage.ru, 320.0), (AppLanguage.uz, 390.0)]) {
    testWidgets('qon morfologiyasi (${lang.name}, $w)', (tester) async {
      await start(tester, lang: lang, size: Size(w, 844));
      final walk = Walk(tester, 'bloodmorph_${lang.name}_${w.toInt()}');
      Future<void> page(String path, String name, {int scrolls = 0}) async {
        await goTo(tester, '$bmBase$path');
        await precacheAll(tester);
        await walk.snap(name);
        for (var i = 0; i < scrolls; i++) {
          await walk.scroll(700);
          await precacheAll(tester);
          await walk.snap('${name}_$i');
        }
      }

      await goTo(tester, '/lab');
      await walk.scroll(500);
      await precacheAll(tester);
      await walk.snap('lab');
      await page('', 'bosh', scrolls: 1);
      await page('/normal', 'normal', scrolls: 2);
      await page('/rbc', 'royxat', scrolls: 1);
      await page('/rbc/schistocytes', 'karta', scrolls: 2);
      await page('/platelets', 'trombotsit', scrolls: 2);
      await page('/retic', 'retik', scrolls: 2);
      await page('/quality', 'sifat', scrolls: 1);
      await goTo(tester, '$bmBase/anemia');
      for (final (k, v) in [
        ('hb', '95'),
        ('mcv', '72'),
        ('rdw', '18'),
        ('rdwUpper', '15'),
        ('ferritin', '8'),
        ('retic', '50'),
      ]) {
        final f = find.byKey(ValueKey('bm-in-$k'));
        await tester.scrollUntilVisible(
          f,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(f, v);
      }
      await tester.pumpAndSettle();
      await walk.snap('yordamchi');
      await walk.scroll(-3000);
      await walk.snap('yordamchi_bosh');
      await walk.scroll(600);
      await walk.snap('yordamchi_1');
      await walk.scroll(700);
      await walk.snap('yordamchi_2');
      await goTo(tester, '$bmBase/quiz');
      await tester.tap(find.byKey(const ValueKey('bm-quiz-start')));
      await tester.pumpAndSettle();
      await precacheAll(tester);
      await walk.snap('mashq');
      await tester.tap(find.byKey(const ValueKey('bm-opt-1')));
      await tester.pumpAndSettle();
      await walk.scroll(500);
      await walk.snap('mashq_javob');
    });
  }
}
