import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Ekrandan tashqaridagi (gorizontal chiplar yoki pastdagi qator) elementni
/// ko'rinadigan qilib bosish.
Future<void> tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.last);
  await tester.pumpAndSettle();
  await tester.tap(f.hitTestable().last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Tests → Hormones group → TSH → related free T4', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await makeServices(tester, role: AppRole.doctor);
    await pumpApp(tester, s);
    await tapVisible(tester, find.text(l.navTests));
    final pack = s.content.pack!;
    await tapVisible(
      tester,
      find.text(pack.group('endocrine')!.names.of('uz')),
    );
    expect(find.text(l.testsResultCount(16)), findsOneWidget);
    await tapVisible(tester, find.text(pack.analyte('tsh')!.names.of('uz')));
    expect(find.text(pack.analyte('tsh')!.tagline!.of('uz')), findsOneWidget);
    final ft4 = pack.analyte('ft4')!.names.of('uz');
    await tester.scrollUntilVisible(find.text(ft4), 400);
    await tapVisible(tester, find.text(ft4));
    expect(find.text(ft4), findsWidgets);
    expect(find.text(pack.analyte('ft4')!.tagline!.of('uz')), findsOneWidget);
  });

  // Ro'yxat pastidagi mavzu tanlanganda savol tepadan ko'rinadi (avval eski
  // scroll tufayli savolning boshi yashirinib qolardi).
  testWidgets('quiz topic at the bottom opens the question from the top', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, textScale: 1.35);
    await goTo(tester, '/learn/quiz');
    await tapVisible(
      tester,
      find.text(s.content.pack!.group('endocrine')!.names.of('ru')),
    );
    // LgEyebrow matnni katta harflarda ko'rsatadi.
    expect(
      find.text(l.quizProgress(1, 16).toUpperCase()).hitTestable(),
      findsOneWidget,
    );
  });
}
