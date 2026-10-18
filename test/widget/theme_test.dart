// Mavzu tanlash (D-64): saqlanish, almashtirish, tokenlar va tor ekran.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/design/themes.dart';
import 'package:labguide/design/tokens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:labguide/l10n/gen/app_localizations_ru.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

LgPalette _palette(WidgetTester tester) =>
    LgPalette.of(tester.element(find.byType(LgPage).last));

LgStyle _style(WidgetTester tester) =>
    LgStyle.of(tester.element(find.byType(LgPage).last));

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  group('persistence', () {
    test('default is Classic; choice is stored and restored', () async {
      final store = MemoryKeyValueStore();
      final a = SettingsController(store, systemLocales: const [Locale('uz')]);
      expect(a.appTheme, LgThemeId.classic);
      await a.setAppTheme(LgThemeId.ivory);
      expect(store.getString(StoreKeys.appTheme), 'ivory');
      expect(StoreKeys.all, contains(StoreKeys.appTheme));

      final b = SettingsController(store, systemLocales: const [Locale('uz')]);
      expect(b.appTheme, LgThemeId.ivory);
      // Rejim (kunduzgi/tungi) mavzudan mustaqil.
      await b.setThemeMode(ThemeMode.dark);
      expect(
        SettingsController(store, systemLocales: const []).appTheme,
        LgThemeId.ivory,
      );

      b.resetToDefaults(const [Locale('uz')]);
      expect(b.appTheme, LgThemeId.classic);
    });

    test('unknown stored value falls back to Classic', () async {
      final store = MemoryKeyValueStore();
      await store.setString(StoreKeys.appTheme, 'neon');
      expect(
        SettingsController(store, systemLocales: const []).appTheme,
        LgThemeId.classic,
      );
    });
  });

  group('registry', () {
    test('every theme has light and dark palettes and 5 swatches', () {
      for (final t in LgThemeId.values) {
        for (final b in Brightness.values) {
          final theme = buildLgTheme(b, theme: t);
          expect(theme.brightness, b);
          expect(theme.extension<LgPalette>(), t.palette(b));
          expect(theme.extension<LgStyle>()!.id, t);
          expect(t.swatches(b), hasLength(5));
          expect(theme.scaffoldBackgroundColor, t.palette(b).bg);
        }
      }
    });

    test('Ivory: serif display titles, body stays Inter', () {
      final ivory = buildLgTheme(Brightness.light, theme: LgThemeId.ivory);
      expect(ivory.textTheme.displaySmall!.fontFamily, kSerifLatin);
      expect(ivory.textTheme.headlineMedium!.fontFamily, kSerifLatin);
      expect(
        ivory.textTheme.displaySmall!.fontFamilyFallback,
        contains(kSerifCyrillic),
      );
      expect(ivory.textTheme.bodyLarge!.fontFamily, 'Inter');
      expect(ivory.textTheme.titleLarge!.fontFamily, 'Inter');
      // Ruscha interfeys: kirill glyphli serif asosiy.
      final ru = buildLgTheme(
        Brightness.dark,
        theme: LgThemeId.ivory,
        cyrillic: true,
      );
      expect(ru.textTheme.displaySmall!.fontFamily, kSerifCyrillic);
      // Klassik — o'zgarmagan.
      final classic = buildLgTheme(Brightness.light);
      expect(classic.textTheme.displaySmall!.fontFamily, 'Inter');
      expect(classic.extension<LgPalette>(), LgPalette.light);
    });

    test('Ivory palette: near-black primary, warm gold accent', () {
      const p = LgPalette.ivoryLight;
      expect(p.brand.computeLuminance(), lessThan(0.01));
      expect(p.bg.computeLuminance(), greaterThan(0.8));
      // Oltin: qizil > yashil > ko'k.
      expect(p.accent.r > p.accent.g && p.accent.g > p.accent.b, isTrue);
      const d = LgPalette.ivoryDark;
      expect(d.bg.computeLuminance(), lessThan(0.02));
      expect(d.ink.computeLuminance(), greaterThan(0.8));
    });
  });

  testWidgets('Profile → Theme: switching applies app-wide and persists', (
    tester,
  ) async {
    final store = MemoryKeyValueStore();
    final s = await makeServices(tester, store: store);
    await pumpApp(tester, s);
    await goTo(tester, '/profile');
    final row = find.byKey(const ValueKey('profile-theme-row'));
    await scrollTo(tester, row);
    expect(find.textContaining(uz.themeClassicName), findsWidgets);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text(uz.themeTitle), findsWidgets);
    expect(_palette(tester), LgPalette.light);

    await tester.tap(find.byKey(const ValueKey('theme-card-ivory')));
    await tester.pumpAndSettle();
    expect(s.settings.appTheme, LgThemeId.ivory);
    expect(store.getString(StoreKeys.appTheme), 'ivory');
    expect(_palette(tester), LgPalette.ivoryLight);
    expect(_style(tester).serifDisplay, isTrue);
    // Tanlangan karta semantikada belgilangan.
    expect(
      tester.getSemantics(find.byKey(const ValueKey('theme-card-ivory'))),
      matchesSemantics(
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
        label: '${uz.themeIvoryName}. ${uz.themeIvoryDesc}',
      ),
    );

    // Tungi rejim — Ivory'ning tungi palitrasi.
    await scrollTo(tester, find.text(uz.themeDark));
    await tester.tap(find.text(uz.themeDark));
    await tester.pumpAndSettle();
    expect(_palette(tester), LgPalette.ivoryDark);

    // Boshqa ekranlar ham shu mavzuda.
    await goTo(tester, '/home');
    expect(_palette(tester), LgPalette.ivoryDark);
    expect(tester.takeException(), isNull);

    // Klassikka qaytish.
    await goTo(tester, '/profile/theme');
    await tester.tap(find.byKey(const ValueKey('theme-card-classic')));
    await tester.pumpAndSettle();
    expect(_palette(tester), LgPalette.dark);
    expect(store.getString(StoreKeys.appTheme), 'classic');
  });

  testWidgets('saved theme is applied on next launch', (tester) async {
    final store = MemoryKeyValueStore();
    await store.setString(StoreKeys.appTheme, 'ivory');
    final s = await makeServices(tester, store: store);
    await pumpApp(tester, s);
    expect(s.settings.appTheme, LgThemeId.ivory);
    expect(_palette(tester), LgPalette.ivoryLight);
  });

  for (final (lang, strings) in [
    (AppLanguage.uz, uz),
    (AppLanguage.ru, AppLocalizationsRu()),
    (AppLanguage.en, AppLocalizationsEn()),
  ]) {
    for (final appTheme in LgThemeId.values) {
      testWidgets('theme screen fits 320 px ×1.3: ${lang.name} '
          '${appTheme.name}', (tester) async {
        final s = await makeServices(
          tester,
          language: lang,
          appTheme: appTheme,
          themeMode: lang == AppLanguage.ru ? ThemeMode.dark : ThemeMode.light,
        );
        await pumpApp(tester, s, size: const Size(320, 1200), textScale: 1.3);
        await goTo(tester, '/profile/theme');
        expect(tester.takeException(), isNull);
        for (final t in LgThemeId.values) {
          final card = find.byKey(ValueKey('theme-card-${t.name}'));
          expect(card, findsOneWidget);
          expect(tester.getRect(card).right, lessThanOrEqualTo(320));
        }
        expect(find.text(strings.themeIvoryDesc), findsOneWidget);
        expect(find.text(strings.themeSystem), findsWidgets);
        await goTo(tester, '/profile');
        expect(tester.takeException(), isNull);
      });
    }
  }
}

final uz = AppLocalizationsUz();
