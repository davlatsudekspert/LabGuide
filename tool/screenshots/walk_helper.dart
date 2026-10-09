// Foydalanuvchi sifatida bosqichma-bosqich o'tish uchun yordamchi: har
// qadamda ekran rasmi (tool/screenshots/out/walk/<ssenariy>/NN_<qadam>.png).
//
// Yangi bo'lim uchun: tool/screenshots/walk_<bo'lim>_test.dart yarating,
// shu faylni import qiling va `start` + `Walk` bilan ssenariy yozing:
//   flutter test tool/screenshots/walk_<bo'lim>_test.dart --update-goldens
// So'ng rasmlarni ko'zdan kechiring (Read) va topilgan kamchiliklarni tuzating.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';

class Walk {
  Walk(this.tester, this.name);

  final WidgetTester tester;
  final String name;
  int _n = 0;

  Future<void> snap(String step) async {
    await tester.pumpAndSettle();
    _n++;
    await expectLater(
      find.byType(LabGuideApp),
      matchesGoldenFile(
        'out/walk/$name/${_n.toString().padLeft(2, '0')}_$step.png',
      ),
    );
  }

  Future<void> tap(Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(String text) => tap(find.text(text).hitTestable().last);

  Future<void> scroll(double dy) async {
    await tester.drag(
      find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .hitTestable()
          .first,
      Offset(0, -dy),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(String label, String value) async {
    final field = find.descendant(
      of: find
          .ancestor(of: find.text(label).last, matching: find.byType(Column))
          .first,
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(field.first);
    await tester.enterText(field.first, value);
    await tester.pumpAndSettle();
  }
}

Future<AppServices> start(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1,
  AppRole role = AppRole.lab,
  Size size = const Size(390, 844),
}) async {
  final s = await makeServices(
    tester,
    language: lang,
    themeMode: theme,
    role: role,
  );
  await pumpApp(tester, s, textScale: textScale, size: size);
  // Rasmlarni oldindan dekod qilish (testda real async kerak).
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold).first);
    for (final n in ['chemistry', 'hematology', 'immunoassay', 'urinalysis']) {
      await precacheImage(AssetImage('assets/instruments/img/$n.png'), ctx);
    }
    await precacheImage(const AssetImage('assets/images/logo_mark.png'), ctx);
  });
  return s;
}
