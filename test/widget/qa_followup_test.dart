import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
final ru = lookupAppLocalizations(const Locale('ru'));
final en = lookupAppLocalizations(const Locale('en'));

const _tall = Size(390, 2400);

String _location(WidgetTester tester) => GoRouter.of(
  tester.element(find.byType(Scaffold).last),
).routerDelegate.currentConfiguration.uri.path;

void main() {
  setUpAll(loadAppFonts);

  testWidgets('profile offline packs open inside Profile and go back to it', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    // Kutubxona tabida ochiq sahifa bor.
    await goTo(tester, '/library/sources');
    expect(find.text(uz.sourcesTitle), findsWidgets);
    await goTo(tester, '/profile');
    await tester.tap(find.text(uz.libPacks));
    await tester.pumpAndSettle();
    expect(find.text(uz.packsBuiltIn), findsOneWidget);
    await tester.tap(find.byTooltip(uz.actionBack));
    await tester.pumpAndSettle();
    expect(_location(tester), '/profile');
    expect(find.text(uz.profileTitle), findsWidgets);
    // Kutubxona tabidagi ochiq sahifa yo'qolmagan, eski manzil ishlaydi.
    await goTo(tester, '/library/sources');
    expect(find.text(uz.sourcesTitle), findsWidgets);
    await goTo(tester, '/library/packs');
    expect(find.text(uz.packsBuiltIn), findsOneWidget);
  });

  testWidgets('privacy delete confirmation uses the language after reset', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/profile/privacy');
    await tester.tap(find.text(ru.privacyDeleteLocal));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ru.actionDelete));
    await tester.pumpAndSettle();
    final after = s.settings.language;
    expect(after, isNot(AppLanguage.ru), reason: 'til tizim tiliga qaytdi');
    final expected = lookupAppLocalizations(after.locale).privacyDeleted;
    expect(find.text(expected), findsOneWidget);
    expect(find.text(ru.privacyDeleted), findsNothing);
  });

  testWidgets('guest profile card does not repeat the same label', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/profile');
    expect(find.text(uz.profileGuest), findsOneWidget);
    expect(find.text(uz.profileGuestLocal), findsOneWidget);
    expect(find.text(uz.profileGuestSub), findsOneWidget);
  });

  testWidgets('library rows match the titles of the pages they open', (
    tester,
  ) async {
    for (final l in [uz, ru, en]) {
      final s = await makeServices(
        tester,
        language: AppLanguage.values.firstWhere((e) => e.name == l.localeName),
        role: AppRole.teacher,
      );
      await pumpApp(tester, s, size: const Size(390, 4000));
      await goTo(tester, '/library');
      await tester.tap(find.text(l.researchTitle));
      await tester.pumpAndSettle();
        expect(find.text(l.researchTitle), findsWidgets);
      await goTo(tester, '/library');
      await tester.tap(find.text(l.intakeTitle));
      await tester.pumpAndSettle();
      expect(find.text(l.intakeTitle), findsWidgets);
      expect(l.libIntake, l.intakeTitle);
    }
  });

  testWidgets('analysis card practice opens a fresh topic picker', (
    tester,
  ) async {
    final s = await makeServices(tester);
    final pack = s.content.pack!;
    final plain = pack.analytes.firstWhere(
      (a) => !pack.quiz.any((q) => q.topicIds.contains(a.id)),
    );
    await pumpApp(tester, s, size: _tall);
    // O'rganish tabida eski mashq boshlangan.
    await goTo(tester, '/learn/quiz');
    final picker = find.text(uz.quizChooseTopic);
    expect(picker, findsOneWidget);
    await tester.tap(find.textContaining(uz.quizTopicMixed(1).split('1').first));
    await tester.pumpAndSettle();
    expect(picker, findsNothing, reason: 'savol ochilgan, mavzu ro‘yxati yo‘q');
    await goTo(tester, '/tests/analyte/${plain.id}');
    await tester.scrollUntilVisible(
      find.text(uz.analytePractice),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.tap(find.text(uz.analytePractice));
    await tester.pumpAndSettle();
    expect(_location(tester), startsWith('/learn/quiz'));
    expect(picker, findsOneWidget, reason: 'yangi mavzu tanlash ekrani');
  });
}
