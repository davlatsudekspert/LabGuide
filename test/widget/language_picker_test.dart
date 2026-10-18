import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/auth/ui/language_picker_screen.dart';
import 'package:labguide/features/auth/ui/welcome_screen.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:labguide/l10n/gen/app_localizations_ru.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final ru = AppLocalizationsRu();

void main() {
  setUpAll(loadAppFonts);

  testWidgets('fresh install starts with the language picker', (tester) async {
    final s = await makeServices(
      tester,
      onboarded: false,
      languageChosen: false,
      role: null,
    );
    await pumpApp(tester, s);
    expect(find.byType(LanguagePickerScreen), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    // Faqat uchta til, shu tartibda.
    final names = ['English', 'Русский', 'O‘zbekcha'];
    final ys = [for (final n in names) tester.getTopLeft(find.text(n)).dy];
    expect(ys, orderedEquals([...ys]..sort()));
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Добро пожаловать'), findsOneWidget);
    expect(find.text('Xush kelibsiz'), findsOneWidget);
    expect(s.settings.languageChosen, isFalse);
  });

  // Audit 2026-10-18 (tablar): kichik telefon + katta shrift — "O‘zbekcha"
  // kartasi ekrandan pastda qolib, surilmaguncha ko‘rinmasdi.
  for (final (w, h, scale) in [
    (360.0, 640.0, 1.3),
    (320.0, 568.0, 1.0),
    (390.0, 844.0, 1.3),
  ]) {
    testWidgets('audit: all three languages visible without scrolling '
        '${w.toInt()}×${h.toInt()} ×$scale', (tester) async {
      final s = await makeServices(
        tester,
        onboarded: false,
        languageChosen: false,
        role: null,
      );
      await pumpApp(tester, s, size: Size(w, h), textScale: scale);
      final screen = tester.getRect(find.byType(LanguagePickerScreen));
      final safeBottom = screen.bottom - 34;
      for (final n in ['English', 'Русский', 'O‘zbekcha']) {
        final card = find.ancestor(
          of: find.text(n),
          matching: find.byType(LgPressable),
        );
        final r = tester.getRect(card.first);
        expect(r.bottom, lessThanOrEqualTo(safeBottom), reason: n);
        expect(r.top, greaterThanOrEqualTo(screen.top + 47), reason: n);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('audit: iPhone 390×844 keeps the logo', (tester) async {
    final s = await makeServices(
      tester,
      onboarded: false,
      languageChosen: false,
      role: null,
    );
    await pumpApp(tester, s);
    expect(find.byType(LgLogoHero), findsOneWidget);
  });

  testWidgets('tapping Русский switches locale and opens Russian welcome', (
    tester,
  ) async {
    final s = await makeServices(
      tester,
      onboarded: false,
      languageChosen: false,
      role: null,
    );
    await pumpApp(tester, s);
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(s.settings.language, AppLanguage.ru);
    expect(s.settings.languageChosen, isTrue);
    expect(find.byType(LanguagePickerScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text(ru.welcomeGuest), findsOneWidget);
  });

  testWidgets('choice persists: next launch skips the picker', (tester) async {
    final store = MemoryKeyValueStore();
    final s = await makeServices(
      tester,
      store: store,
      onboarded: false,
      languageChosen: false,
      role: null,
    );
    await pumpApp(tester, s);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(store.getBool(StoreKeys.languageChosen), isTrue);
    final again = SettingsController(store, systemLocales: const []);
    expect(again.languageChosen, isTrue);
    expect(again.language, AppLanguage.en);
  });

  testWidgets('already onboarded user never sees the picker', (tester) async {
    final store = MemoryKeyValueStore();
    // Eski o'rnatma: faqat onboarded saqlangan, languageChosen kaliti yo'q.
    await store.setBool(StoreKeys.onboarded, true);
    final legacy = SettingsController(store, systemLocales: const []);
    expect(legacy.languageChosen, isTrue);

    final s = await makeServices(tester, languageChosen: false);
    expect(s.settings.onboarded, isTrue);
    expect(s.settings.languageChosen, isTrue);
    await pumpApp(tester, s);
    expect(find.byType(LanguagePickerScreen), findsNothing);
    await goTo(tester, '/welcome/language');
    expect(find.byType(LanguagePickerScreen), findsNothing);
  });

  test('suggest maps device locale', () {
    const s = LanguagePickerScreen.suggest;
    expect(s(const [Locale('ru', 'RU')]), AppLanguage.ru);
    expect(s(const [Locale('uz')]), AppLanguage.uz);
    expect(s(const [Locale('uz', 'UZ')]), AppLanguage.uz);
    expect(s(const [Locale('de')]), AppLanguage.en);
    expect(s(const []), AppLanguage.en);
  });

  testWidgets('device locale card is pre-highlighted', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ru', 'RU')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final s = await makeServices(
      tester,
      onboarded: false,
      languageChosen: false,
      role: null,
    );
    await pumpApp(tester, s);
    bool selected(String name) =>
        tester
            .getSemantics(find.bySemanticsLabel(RegExp('^$name\\.')))
            .flagsCollection
            .isSelected ==
        Tristate.isTrue;
    expect(selected('Русский'), isTrue);
    expect(selected('English'), isFalse);
    expect(selected('O‘zbekcha'), isFalse);
  });

  testWidgets('device locale uz_UZ pre-highlights O‘zbekcha', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('uz', 'UZ')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final s = await makeServices(
      tester,
      onboarded: false,
      languageChosen: false,
      role: null,
    );
    await pumpApp(tester, s);
    bool selected(String name) =>
        tester
            .getSemantics(find.bySemanticsLabel(RegExp('^$name\\.')))
            .flagsCollection
            .isSelected ==
        Tristate.isTrue;
    expect(selected('O‘zbekcha'), isTrue);
    expect(selected('English'), isFalse);
    expect(selected('Русский'), isFalse);
  });

  testWidgets('root Profile shows its title once (no header duplicate)', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s);
    await goTo(tester, '/profile');
    final title = l10n(tester, (c) => AppLocalizations.of(c).profileTitle);
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('reduced motion renders instantly', (tester) async {
    final s = await makeServices(
      tester,
      onboarded: false,
      languageChosen: false,
      role: null,
    );
    const ratio = 3.0;
    tester.view.devicePixelRatio = ratio;
    tester.view.physicalSize = const Size(390, 844) * ratio;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpWidget(LabGuideApp(services: s));
    // Bitta kadr: animatsiyasiz hammasi to'liq ko'rinadi.
    await tester.pump();
    final fade = tester.widgetList<FadeTransition>(find.byType(FadeTransition));
    expect(fade.every((f) => f.opacity.value == 1), isTrue);
    expect(find.text('Русский'), findsOneWidget);
  });

  testWidgets('no overflow at 320 wide, large text, dark', (tester) async {
    final s = await makeServices(
      tester,
      onboarded: false,
      languageChosen: false,
      role: null,
      themeMode: ThemeMode.dark,
    );
    await pumpApp(
      tester,
      s,
      size: const Size(320, 568),
      textScale: 2,
      platformBrightness: Brightness.dark,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('O‘zbekcha'), findsOneWidget);
  });
}
