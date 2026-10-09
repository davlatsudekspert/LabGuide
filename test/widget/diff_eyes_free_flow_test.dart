import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/features/differential/diff_eyes_free.dart';
import 'package:labguide/features/differential/diff_eyes_free_screens.dart';
import 'package:labguide/features/differential/diff_eyes_free_settings.dart';
import 'package:labguide/features/differential/diff_voice.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

final en = AppLocalizationsEn();
final uz = AppLocalizationsUz();

Finder _zone(DiffCell c) => find.byKey(ValueKey('ef-zone-${c.name}'));

Future<void> _tapZone(WidgetTester tester, DiffCell c, [int n = 1]) async {
  for (var i = 0; i < n; i++) {
    await tester.tap(_zone(c));
    await tester.pump(const Duration(milliseconds: 20));
  }
  await tester.pump(const Duration(milliseconds: 200));
}

/// Router (to'liq ekranli sahifada LgPage yo'q).
Future<void> _go(WidgetTester tester, String location) async {
  GoRouter.of(tester.element(find.byType(Scaffold).last)).go(location);
  await tester.pumpAndSettle();
}

Future<void> _twoFingerTap(WidgetTester tester, DiffCell c) async {
  final center = tester.getCenter(_zone(c));
  final a = await tester.startGesture(center);
  final b = await tester.startGesture(center + const Offset(30, 0), pointer: 7);
  await tester.pump(const Duration(milliseconds: 40));
  await a.up();
  await b.up();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('zonalar bilan sanash 100 da to\'xtaydi; bekor qilish; signal', (
    tester,
  ) async {
    final fakes = installDiffFakes();
    final haptics = recordHaptics(tester);
    final s = await makeServices(tester, language: AppLanguage.en);
    await pumpApp(tester, s);
    await goTo(tester, '/lab/differential/count');
    await tester.scrollUntilVisible(
      find.text(en.diffEfEntry),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(en.diffEfEntry));
    await tester.pumpAndSettle();
    expect(find.text(en.diffEfSettingsTitle), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('eyes-free-start')));
    await tester.pumpAndSettle();

    // To'liq ekran: pastki tablar yo'q, 7 zona + bekor zonasi.
    expect(find.byType(NavigationBar), findsNothing);
    for (final c in DiffCell.values) {
      expect(_zone(c), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('ef-undo')), findsOneWidget);

    // 1-zona (segment) — pastda o'ngda (o'ng qo'l).
    final seg = tester.getRect(_zone(DiffCell.segmented));
    final lym = tester.getRect(_zone(DiffCell.lymphocyte));
    expect(seg.left, greaterThan(lym.left));
    expect(seg.top, lym.top);
    expect(seg.top, greaterThan(tester.getRect(_zone(DiffCell.other)).top));

    await _tapZone(tester, DiffCell.band);
    expect(s.differential.count(DiffCell.band), 1);
    expect(haptics, ['medium', 'medium']);
    expect(fakes.cues.cues, [Cue.tap]);

    // Ikki barmoq — bekor.
    haptics.clear();
    await _twoFingerTap(tester, DiffCell.monocyte);
    expect(s.differential.total, 0);
    expect(s.differential.count(DiffCell.monocyte), 0);
    expect(haptics, ['heavy', 'selection']);
    expect(fakes.cues.cues.last, Cue.undo);

    // Katta "bekor" zonasi.
    await _tapZone(tester, DiffCell.lymphocyte, 2);
    await tester.tap(find.byKey(const ValueKey('ef-undo')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(s.differential.count(DiffCell.lymphocyte), 1);

    // Sudrash (barmoq sirpanib ketdi) — sanalmaydi.
    await tester.drag(_zone(DiffCell.segmented), const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 200));
    expect(s.differential.total, 1);

    // 10-hujayra — qo'shimcha signal.
    fakes.cues.cues.clear();
    await _tapZone(tester, DiffCell.segmented, 9);
    expect(s.differential.total, 10);
    expect(fakes.cues.cues.last, Cue.ten);

    // 100 gacha.
    await _tapZone(tester, DiffCell.segmented, 89);
    expect(s.differential.total, 99);
    haptics.clear();
    await _tapZone(tester, DiffCell.eosinophil);
    expect(s.differential.total, 100);
    expect(s.differential.isComplete, isTrue);
    expect(fakes.cues.cues.last, Cue.done);
    expect(haptics, ['light', 'light', 'heavy', 'heavy', 'long']);
    expect(find.text(en.diffDoneTitle(100)), findsOneWidget);

    // Yana bosish — qo'shilmaydi, "qabul qilinmadi" signali.
    await tester.tapAt(tester.getRect(_zone(DiffCell.segmented)).bottomRight -
        const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 200));
    expect(s.differential.total, 100);
    expect(fakes.cues.cues.last, Cue.blocked);

    // Natijaga o'tish — oddiy hisoblagich, o'sha sanash.
    await tester.tap(find.byKey(const ValueKey('ef-show-result')));
    await tester.pumpAndSettle();
    expect(find.text(en.diffCounterTitle), findsWidgets);
    expect(s.differential.total, 100);
  });

  testWidgets('chap qo\'l, 6 zona, ekran yoqiq; ekran o\'quvchi', (
    tester,
  ) async {
    final fakes = installDiffFakes();
    recordHaptics(tester);
    final handle = tester.ensureSemantics();
    final s = await makeServices(tester, language: AppLanguage.uz);
    await s.differential.setEyesFree(
      const EyesFreeSettings(
        leftHanded: true,
        includeOther: false,
        undoZone: false,
        keepAwake: true,
      ),
    );
    await pumpApp(tester, s);
    await goTo(tester, eyesFreeRunRoute);
    expect(fakes.awake.calls, [true]);
    expect(_zone(DiffCell.other), findsNothing);
    expect(find.byKey(const ValueKey('ef-undo')), findsNothing);
    final seg = tester.getRect(_zone(DiffCell.segmented));
    final lym = tester.getRect(_zone(DiffCell.lymphocyte));
    expect(seg.left, lessThan(lym.left));

    // Ekran o'quvchi: zona tugma sifatida, nomi va soni bilan; bosish
    // amali sanaydi, maxsus amal — bekor qiladi.
    final label = uz.diffEfZoneSemantics(
      diffCellNames[DiffCell.monocyte]!.of('uz'),
      0,
      0,
      100,
    );
    expect(find.bySemanticsLabel(label), findsOneWidget);
    final node = tester.getSemantics(find.bySemanticsLabel(label));
    expect(node.flagsCollection.isButton, isTrue);
    tester.semantics.tap(find.semantics.byLabel(label));
    await tester.pump(const Duration(milliseconds: 200));
    expect(s.differential.count(DiffCell.monocyte), 1);
    tester.semantics.customAction(
      find.semantics.byLabel(
        uz.diffEfZoneSemantics(
          diffCellNames[DiffCell.monocyte]!.of('uz'),
          1,
          1,
          100,
        ),
      ),
      CustomSemanticsAction(label: uz.diffEfUndoZone),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(s.differential.total, 0);

    await tester.tap(find.byKey(const ValueKey('ef-exit')));
    await tester.pumpAndSettle();
    expect(fakes.awake.calls, [true, false]);
    handle.dispose();
  });

  testWidgets('ovoz: rozilik, buyruqlar, ruxsat rad etilganda halol xabar', (
    tester,
  ) async {
    final engine = FakeSpeechEngine();
    installDiffFakes(engine: engine);
    recordHaptics(tester);
    final s = await makeServices(tester, language: AppLanguage.uz);
    await pumpApp(tester, s);
    await _go(tester, eyesFreeSettingsRoute);

    // Yoqish — avval ogohlantirish (Android matni: testda platforma Android).
    final sw = find.byKey(const ValueKey('voice-switch'));
    await tester.scrollUntilVisible(
      sw,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(sw);
    await tester.pumpAndSettle();
    expect(find.text(uz.diffVoiceConsentTitle), findsOneWidget);
    expect(find.text(uz.diffVoicePrivacyAndroid), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('voice-consent')));
    await tester.pumpAndSettle();
    expect(s.differential.eyesFree.voice, isTrue);
    expect(s.differential.eyesFree.voiceConsent, isTrue);

    await goTo(tester, eyesFreeRunRoute);
    await tester.pump(const Duration(milliseconds: 50));
    expect(engine.listenedLocale, 'ru-RU');
    expect(find.textContaining(uz.diffVoiceListening(uz.diffVoiceLangRu)), findsOneWidget);
    expect(find.textContaining(uz.diffVoiceFallback(uz.diffVoiceLangRu)), findsOneWidget);

    engine.say('лимфоцит лимфоцит');
    await tester.pump(const Duration(milliseconds: 200));
    expect(s.differential.count(DiffCell.lymphocyte), 2);
    expect(find.textContaining(uz.diffVoiceHeard('лимфоцит лимфоцит')), findsOneWidget);
    engine.say('отмена');
    await tester.pump(const Duration(milliseconds: 200));
    expect(s.differential.count(DiffCell.lymphocyte), 1);

    // Mikrofonni to'xtatish.
    await tester.tap(find.byKey(const ValueKey('ef-mic')));
    await tester.pumpAndSettle();
    expect(engine.stops, greaterThan(0));
    expect(find.textContaining(uz.diffVoiceHeard('отмена')), findsNothing);

    // Ruxsat rad etildi.
    engine.initResult = VoiceInit.permissionDenied;
    await _go(tester, eyesFreeSettingsRoute);
    final denied = FakeSpeechEngine(initResult: VoiceInit.permissionDenied);
    DiffVoiceDevice.engine = () => denied;
    await goTo(tester, eyesFreeRunRoute);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text(uz.diffVoicePermissionDenied), findsOneWidget);
    // Bosilsa — to'liq matn oynada.
    await tester.tap(find.byKey(const ValueKey('ef-voice-strip')));
    await tester.pumpAndSettle();
    expect(find.text(uz.diffVoicePermissionDenied), findsNWidgets(2));
    await tester.tapAt(const Offset(5, 300));
    await tester.pumpAndSettle();
    // Zonalar baribir ishlaydi.
    await _tapZone(tester, DiffCell.basophil);
    expect(s.differential.count(DiffCell.basophil), 1);
  });

  testWidgets('320 px, shrift 2.0: zonalar va sozlamalar sig\'adi', (
    tester,
  ) async {
    installDiffFakes(engine: FakeSpeechEngine(locales: const []));
    recordHaptics(tester);
    final s = await makeServices(tester, language: AppLanguage.ru);
    await s.differential.setEyesFree(
      const EyesFreeSettings(voice: true, voiceConsent: true),
    );
    await pumpApp(tester, s, size: const Size(320, 568), textScale: 2.0);
    await goTo(tester, eyesFreeRunRoute);
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    // Har zona kamida 44 px (barmoq bilan topiladigan).
    for (final c in DiffCell.values) {
      final r = tester.getRect(_zone(c));
      expect(r.height, greaterThanOrEqualTo(44), reason: c.name);
      expect(r.width, greaterThanOrEqualTo(100), reason: c.name);
    }
    await _tapZone(tester, DiffCell.segmented);
    expect(tester.takeException(), isNull);

    await _go(tester, eyesFreeSettingsRoute);
    for (var i = 0; i < 12; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });

  // Layout matritsasining shu ekranlar uchun qisqa varianti (to'liq
  // matritsa — layout_matrix_*_test.dart, u yerga ham yo'llar qo'shilgan).
  for (final lang in AppLanguage.values) {
    for (final (w, h, scale, theme) in [
      (320.0, 568.0, 1.0, ThemeMode.light),
      (320.0, 568.0, 2.0, ThemeMode.light),
      (390.0, 844.0, 1.35, ThemeMode.dark),
      (820.0, 1180.0, 1.0, ThemeMode.light),
      (844.0, 390.0, 1.0, ThemeMode.light),
    ]) {
      testWidgets('layout ${lang.name} ${w.toInt()}x${h.toInt()} x$scale', (
        tester,
      ) async {
        installDiffFakes(engine: FakeSpeechEngine(locales: const ['en-US']));
        recordHaptics(tester);
        final s = await makeServices(tester, language: lang, themeMode: theme);
        await s.differential.setEyesFree(
          const EyesFreeSettings(voice: true, voiceConsent: true),
        );
        await pumpApp(tester, s, size: Size(w, h), textScale: scale);
        await goTo(tester, eyesFreeRunRoute);
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        for (final c in DiffCell.values) {
          expect(
            tester.getRect(_zone(c)).height,
            greaterThanOrEqualTo(40),
            reason: c.name,
          );
        }
        await _tapZone(tester, DiffCell.lymphocyte, 100);
        expect(tester.takeException(), isNull);
        await goTo(tester, eyesFreeSettingsRoute);
        expect(tester.takeException(), isNull);
        for (var i = 0; i < 20; i++) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -500),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
