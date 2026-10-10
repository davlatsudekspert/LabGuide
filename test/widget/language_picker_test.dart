import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/auth/ui/language_picker_screen.dart';
import 'package:labguide/features/auth/ui/welcome_screen.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/features/settings/settings_controller.dart';
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
