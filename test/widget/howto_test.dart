// “Qanday foydalaniladi?” tugmasi: bo‘lim sahifasidan ochiladi (uz/ru/en),
// 320 px va 2.0 shrift masshtabida (yorug‘ va tungi) toshmaydi, qadamlar
// tilga olgan ekranlar routerda haqiqatan bor, video havolasi faqat video
// ro‘yxatga olinganda ko‘rinadi.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/howto/howto_registry.dart';
import 'package:labguide/features/howto/howto_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Bo‘lim → uning asosiy sahifasi (tugma shu yerda).
const _hub = {
  HowToSection.calibration: '/lab/calibration',
  HowToSection.qc: '/lab/qc',
  HowToSection.preanalytics: '/lab/preanalytics',
  HowToSection.calculators: '/lab/calculators',
  HowToSection.instruments: '/lab/instruments',
  HowToSection.microscopy: '/lab/microscopy',
  HowToSection.coprology: '/lab/coprology',
  HowToSection.assessment: '/learn/toifa',
  HowToSection.differential: '/lab/differential',
  HowToSection.cytology: '/lab/cytology',
  HowToSection.spermogram: '/lab/spermogram',
  HowToSection.bloodGroup: '/lab/bloodgroup',
  HowToSection.histology: '/lab/histology',
  HowToSection.urinalysis: '/lab/urinalysis',
  HowToSection.bloodMorph: '/lab/bloodmorph',
  HowToSection.coagulogram: '/lab/coagulogram',
};

Future<void> _open(WidgetTester tester, HowToSection s) async {
  final key = find.byKey(ValueKey('howto-${s.id}'));
  expect(key, findsOneWidget, reason: s.id);
  await tester.ensureVisible(key);
  await tester.pumpAndSettle();
  await tester.tap(key);
  await tester.pumpAndSettle();
}

Future<void> _close(WidgetTester tester, AppLocalizations l) async {
  final close = find.descendant(
    of: find.byType(HowToSheet),
    matching: find.text(l.actionClose),
  );
  await tester.ensureVisible(close);
  await tester.pumpAndSettle();
  await tester.tap(close);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  test('har bo‘lim uchun asosiy sahifa belgilangan', () {
    expect(_hub.keys.toSet(), HowToSection.values.toSet());
  });

  for (final lang in AppLanguage.values) {
    testWidgets('tugma how-to oynasini ochadi (${lang.name})', (tester) async {
      final s = await makeServices(tester, language: lang);
      // Bilim va malakani baholash: ru/en da Profil sozlamasi “O‘zbekiston”.
      await s.settings.setAttestationRegion(AttestationRegion.uz);
      await pumpApp(tester, s);
      final l = lookupAppLocalizations(lang.locale);
      for (final sec in [
        HowToSection.calibration,
        HowToSection.qc,
        HowToSection.coprology,
        HowToSection.assessment,
        HowToSection.differential,
      ]) {
        await goTo(tester, _hub[sec]!);
        expect(find.text(l.howToButton), findsOneWidget, reason: sec.id);
        await _open(tester, sec);
        final c = HowToRegistry.of(sec);
        expect(find.byType(HowToSheet), findsOneWidget);
        expect(find.text(c.title(l)), findsWidgets);
        expect(find.text(l.howToStepsTitle), findsOneWidget);
        expect(find.text(c.steps.first(l)), findsOneWidget);
        expect(find.text(c.result(l)), findsOneWidget);
        // Video ro‘yxatga olinmagan — video haqida hech narsa yo‘q.
        expect(find.text(l.howToWatchVideo), findsNothing);
        await _close(tester, l);
        expect(find.byType(HowToSheet), findsNothing);
      }
    });
  }

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('320 px, shrift ×2.0, ${theme.name}: hamma bo‘lim — toshmaydi', (
      tester,
    ) async {
      for (final lang in [AppLanguage.ru, AppLanguage.uz]) {
        final s = await makeServices(tester, language: lang, themeMode: theme);
        await s.settings.setAttestationRegion(AttestationRegion.uz);
        await pumpApp(tester, s, size: const Size(320, 640), textScale: 2.0);
        final l = lookupAppLocalizations(lang.locale);
        for (final sec in HowToSection.values) {
          await goTo(tester, _hub[sec]!);
          await _open(tester, sec);
          expect(find.byType(HowToSheet), findsOneWidget, reason: sec.id);
          // Oxirgi qadam va natija surib ko‘rinadi (kesilmaydi).
          final last = find.text(HowToRegistry.of(sec).result(l));
          await tester.ensureVisible(last);
          await tester.pumpAndSettle();
          expect(last.hitTestable(), findsOneWidget, reason: sec.id);
          await _close(tester, l);
        }
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('en, 390 px: qadamlar tilga olgan har ekran routerda bor', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.en);
    await s.settings.setAttestationRegion(AttestationRegion.uz);
    await pumpApp(tester, s);
    for (final c in HowToRegistry.all.values) {
      for (final r in c.routes) {
        await goTo(tester, r);
        final cfg = routerOf(tester).routerDelegate.currentConfiguration;
        expect(cfg.isError, isFalse, reason: '${c.id}: $r');
        expect(cfg.uri.path, r, reason: '${c.id}: $r (redirect)');
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('video ro‘yxatga olinsa — oynada “Videoni ko‘rish” chiqadi', (
    tester,
  ) async {
    final s = await makeServices(tester, language: AppLanguage.uz);
    await pumpApp(tester, s);
    final base = HowToRegistry.of(HowToSection.qc);
    final withVideo = HowToContent(
      section: base.section,
      title: base.title,
      steps: base.steps,
      result: base.result,
      videoUrl: 'https://example.org/qc.mp4',
    );
    final ctx = tester.element(find.byType(Scaffold).first);
    unawaited(showHowTo(ctx, withVideo));
    await tester.pumpAndSettle();
    final l = lookupAppLocalizations(const Locale('uz'));
    expect(find.byKey(const ValueKey('howto-video-qc')), findsOneWidget);
    expect(find.text(l.howToWatchVideo), findsOneWidget);
    // Bir xil oyna, video yo‘q — tugma ham yo‘q.
    await _close(tester, l);
    final ctx2 = tester.element(find.byType(Scaffold).first);
    unawaited(showHowTo(ctx2, base));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('howto-video-qc')), findsNothing);
  });
}
