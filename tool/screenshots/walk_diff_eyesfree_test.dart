// Leykoformula: "ko'rmasdan sanash" (mikroskop) rejimi — laborant (uz),
// laborant (ru, qorong'i, shrift 1.35, ovozli buyruqlar), en (320 px,
// shrift 2.0 va landshaft). Tovush/tebranish/mikrofon — soxta (testda
// qurilma yo'q).
//
//   flutter test tool/screenshots/walk_diff_eyesfree_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/features/differential/diff_eyes_free_screens.dart';
import 'package:labguide/features/differential/diff_eyes_free_settings.dart';
import 'package:labguide/features/differential/diff_voice.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

Finder zone(DiffCell c) => find.byKey(ValueKey('ef-zone-${c.name}'));

AppLocalizations l10nOf(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).last));

Future<void> go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(Scaffold).last)).go(location);
  await tester.pumpAndSettle();
}

Future<void> tapZone(WidgetTester tester, DiffCell c, [int n = 1]) async {
  for (var i = 0; i < n; i++) {
    await tester.tap(zone(c));
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// Bosilgan zona ajralib turgan paytdagi rasm uchun.
Future<void> snapFlash(Walk w, WidgetTester tester, DiffCell c, String step) async {
  await tester.tap(zone(c));
  await tester.pump(const Duration(milliseconds: 40));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('out/walk/${w.name}/flash_$step.png'),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    250,
    scrollable: find
        .byWidgetPredicate(
          (x) => x is Scrollable && x.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('uz: hisoblagichdan mikroskop rejimiga, 100 gacha', (
    tester,
  ) async {
    final fakes = installDiffFakes();
    recordHaptics(tester);
    final s = await start(tester);
    final w = Walk(tester, 'diff_eyesfree_uz');
    await goTo(tester, '/lab/differential/count');
    final l = l10nOf(tester);
    await scrollTo(tester, find.text(l.diffEfEntry));
    await w.snap('counter_entry');
    await w.tap(find.text(l.diffEfEntry));
    await w.snap('settings_top');
    await scrollTo(tester, find.text(l.diffEfOrderTitle));
    await w.snap('settings_zones');
    await scrollTo(tester, find.text(l.diffEfPatternsTitle));
    await w.snap('settings_signals');
    // Naqshni sinab ko'rish.
    await w.tap(find.text(l.diffEfPattern(2, l.diffEfPulseMedium)));
    expect(fakes.cues.cues, isNotEmpty);
    await scrollTo(tester, find.text(l.diffVoiceWordsTitle));
    await w.snap('settings_voice');

    await go(tester, eyesFreeSettingsRoute);
    await w.tap(find.byKey(const ValueKey('eyes-free-start')));
    await w.snap('run_empty');
    await tapZone(tester, DiffCell.segmented, 6);
    await tapZone(tester, DiffCell.lymphocyte, 3);
    await snapFlash(w, tester, DiffCell.lymphocyte, 'lymph');
    await w.snap('run_10');
    // Ikki barmoq — bekor.
    final c = tester.getCenter(zone(DiffCell.monocyte));
    final a = await tester.startGesture(c);
    final b = await tester.startGesture(c + const Offset(40, 0), pointer: 9);
    await a.up();
    await b.up();
    await tester.pump(const Duration(milliseconds: 300));
    expect(s.differential.total, 9);
    await tapZone(tester, DiffCell.segmented, 50);
    await tapZone(tester, DiffCell.lymphocyte, 30);
    await tapZone(tester, DiffCell.monocyte, 6);
    await tapZone(tester, DiffCell.eosinophil, 3);
    await tapZone(tester, DiffCell.band, 2);
    await w.snap('run_done');
    expect(s.differential.total, 100);
    await w.tap(find.byKey(const ValueKey('ef-show-result')));
    await w.snap('result');
  });

  testWidgets('ru: qorong\'i, 1.35, chap qo\'l, ovozli buyruqlar', (
    tester,
  ) async {
    final engine = FakeSpeechEngine();
    installDiffFakes(engine: engine);
    recordHaptics(tester);
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
    );
    final w = Walk(tester, 'diff_eyesfree_ru');
    await goTo(tester, eyesFreeSettingsRoute);
    final l = l10nOf(tester);
    await scrollTo(tester, find.text(l.diffEfHandLeft));
    await w.tap(find.text(l.diffEfHandLeft));
    await scrollTo(tester, find.text(l.diffEfOtherZone));
    await w.tap(find.text(l.diffEfOtherZone));
    await w.snap('settings_left_6');
    final sw = find.byKey(const ValueKey('voice-switch'));
    await scrollTo(tester, sw);
    await w.tap(sw);
    await w.snap('voice_consent');
    await w.tap(find.byKey(const ValueKey('voice-consent')));
    await w.snap('voice_on');
    await go(tester, eyesFreeRunRoute);
    await tester.pump(const Duration(milliseconds: 50));
    await w.snap('run_listening');
    engine.say('лимфоцит');
    await tester.pump(const Duration(milliseconds: 300));
    engine.say('палочкоядерный нейтрофил');
    await tester.pump(const Duration(milliseconds: 300));
    await w.snap('run_heard');
    engine.say('какой-то шум');
    await w.snap('run_not_understood');
    expect(s.differential.total, 2);

    // Ruxsat rad etildi.
    await go(tester, eyesFreeSettingsRoute);
    DiffVoiceDevice.engine = () =>
        FakeSpeechEngine(initResult: VoiceInit.permissionDenied);
    await go(tester, eyesFreeRunRoute);
    await w.snap('run_permission_denied');
    await w.tap(find.byKey(const ValueKey('ef-voice-strip')));
    await w.snap('permission_dialog');
  });

  testWidgets('en: 320 px shrift 2.0; landshaft; iOS on-device yo\'q', (
    tester,
  ) async {
    installDiffFakes(
      engine: FakeSpeechEngine(locales: const ['en-US'], onDevice: true),
    );
    recordHaptics(tester);
    final s = await start(
      tester,
      lang: AppLanguage.en,
      textScale: 2.0,
      size: const Size(320, 568),
    );
    await s.differential.setEyesFree(
      const EyesFreeSettings(voice: true, voiceConsent: true),
    );
    final w = Walk(tester, 'diff_eyesfree_en');
    await goTo(tester, eyesFreeSettingsRoute);
    await w.snap('settings_320_x2');
    await w.tap(find.byKey(const ValueKey('eyes-free-start')));
    await tester.pump(const Duration(milliseconds: 50));
    await tapZone(tester, DiffCell.basophil, 2);
    await w.snap('run_320_x2');

    await s.differential.setEyesFree(
      s.differential.eyesFree.copyWith(voice: false),
    );
    tester.view.physicalSize = const Size(844, 390) * 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    await tester.pumpAndSettle();
    await w.snap('run_landscape');
  });
}
