// Tablar auditi (docs/AUDIT_2026-10-18_TABS.md): Lab tabidan tashqari
// hamma tab va onboarding — iPhone (390×844, DPR 3, notch) va kichik
// telefon (360×640, ×1.3), uz/ru/en, kunduzgi/tungi.
// Rasmlar: tool/screenshots/out/walk/audit_<variant>/NN_<qadam>.png
//
//   flutter test tool/screenshots/walk_audit_tabs_test.dart --update-goldens
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

const _routes = [
  '/home',
  '/home/search',
  '/tests',
  '/tests/analyte/hba1c',
  '/tests/analyte/tsh',
  '/tests/conditions',
  '/library',
  '/library/books',
  '/library/books/item/lib-sammu-kld-lelevich',
  '/library/packs',
  '/library/research',
  '/learn',
  '/learn/quiz',
  '/learn/exam',
  '/learn/daily',
  '/learn/toifa',
  '/learn/toifa/test',
  '/learn/toifa/oral',
  '/learn/toifa/progress',
  '/learn/classes',
  '/learn/classes/join',
  '/learn/lecture',
  '/learn/lecture/test/d012',
  '/profile',
  '/profile/theme',
  '/profile/help',
  '/profile/contact',
  '/profile/support',
  '/profile/privacy',
];

Future<void> _tour(
  WidgetTester tester,
  String variant, {
  required AppLanguage lang,
  required ThemeMode theme,
  required Size size,
  double textScale = 1,
  LgThemeId appTheme = LgThemeId.classic,
}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  final s = await start(
    tester,
    lang: lang,
    theme: theme,
    size: size,
    textScale: textScale,
    appTheme: appTheme,
  );
  final w = Walk(tester, 'audit_$variant');
  for (final role in AppRole.values) {
    await s.settings.setRole(role);
    await goTo(tester, '/home');
    await w.snap('home_${role.name}');
  }
  await s.settings.setRole(AppRole.lab);
  for (final r in _routes) {
    await goTo(tester, r);
    await w.snap(r.substring(1).replaceAll('/', '_'));
  }
  debugDefaultTargetPlatformOverride = null;
}

void main() {
  setUpAll(loadAppFonts);
  testWidgets('uz 390 light', (t) => _tour(t, 'uz390',
      lang: AppLanguage.uz, theme: ThemeMode.light, size: const Size(390, 844)));
  testWidgets('ru 360 x1.3 dark', (t) => _tour(t, 'ru360',
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      size: const Size(360, 640),
      textScale: 1.3));
  testWidgets('en 360 x1.3 ivory', (t) => _tour(t, 'en360',
      lang: AppLanguage.en,
      theme: ThemeMode.light,
      size: const Size(360, 640),
      textScale: 1.3,
      appTheme: LgThemeId.ivory));
  for (final (lang, size, scale) in [
    (AppLanguage.uz, const Size(390, 844), 1.0),
    (AppLanguage.ru, const Size(360, 640), 1.3),
    (AppLanguage.en, const Size(360, 640), 1.3),
  ]) {
    testWidgets('onboarding ${lang.name} ${size.width.toInt()}', (t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final s = await makeServices(t,
          language: lang, onboarded: false, role: null);
      await pumpApp(t, s, size: size, textScale: scale);
      final w = Walk(t, 'audit_onb_${lang.name}${size.width.toInt()}');
      await w.snap('start');
      for (final r in ['/welcome', '/welcome/auth', '/welcome/role']) {
        await goTo(t, r);
        await w.snap(r.substring(1).replaceAll('/', '_'));
      }
      await t.runAsync(() => s.auth.requestCode('student@example.com'));
      await goTo(t, '/welcome/auth/otp');
      await w.snap('otp');
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('flows ru 360 x1.3', (t) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final s = await start(t,
        lang: AppLanguage.uz, size: const Size(360, 640), textScale: 1.3);
    final w = Walk(t, 'audit_flows');
    final l = lookupAppLocalizations(const Locale('uz'));
    // Toifa: mashq rejimi — darhol javob.
    await goTo(t, '/learn/toifa/test');
    await t.tap(find.byKey(const ValueKey('toifa-mode-practice')));
    await t.pumpAndSettle();
    await tapScroll(t, l.toifaDrillStart);
    await w.snap('drill_q1');
    final d = s.toifa.activeDrill!;
    final q = s.toifa.bank!.test(d.ids[0])!;
    final wrong = List.generate(q.optionCount, (i) => i)
        .firstWhere((i) => i != d.keys[0]);
    await tapScroll(t, q.options[wrong]);
    await w.snap('drill_wrong');
    await w.scroll(400);
    await w.snap('drill_wrong_scrolled');
    // Og'zaki bilet.
    await goTo(t, '/learn/toifa/oral');
    await w.snap('oral');
    // Imtihon.
    await goTo(t, '/learn/exam');
    await w.snap('exam');
    await goTo(t, '/learn/quiz');
    await w.snap('quiz');
    debugDefaultTargetPlatformOverride = null;
  });
}
