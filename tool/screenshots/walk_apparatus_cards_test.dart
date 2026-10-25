// Yo‘nalish (lab) kartalaridagi apparat SINFI chizmalari — foydalanuvchi
// sifatida (walk_helper.dart). Chizmasi bor har bir karta ochiladi: rasm
// kesilmaganmi, izoh (“Sxematik tasvir — aniq model emas”) o‘qiladimi, matn
// ustma-ust tushmaydimi — rasmlar ko‘zdan kechiriladi.
//
//   flutter test tool/screenshots/walk_apparatus_cards_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _figure = ValueKey('lab-card-schematic');

Future<void> _precacheSchematics(WidgetTester tester) =>
    tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold).first);
      for (final s in LabSchematic.values) {
        await precacheImage(AssetImage(s.asset), ctx);
      }
    });

/// Kartani ochib, chizmani ko‘rinadigan joyga suradi.
Future<void> _openCard(WidgetTester tester, String id) async {
  await goTo(tester, '/lab/instruments');
  await goTo(tester, '/lab/instruments/lc/$id');
  final fig = find.byKey(_figure);
  for (var i = 0; i < 30 && fig.evaluate().isEmpty; i++) {
    await tester.drag(
      find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .hitTestable()
          .first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(fig);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('chizmali har karta — uz, yorug‘, 390 px', (tester) async {
    final s = await start(tester);
    await tester.runAsync(s.instruments.ensureCatalog);
    await _precacheSchematics(tester);
    final l = lookupAppLocalizations(const Locale('uz'));
    final w = Walk(tester, 'apparatus_cards_uz');
    final cards = [
      for (final c in s.instruments.catalog!.publicLabCards)
        if (c.schematic != null) c,
    ];
    expect(cards.length, 35);
    // Kartaning tepasi: holat, bildirishnomalar, so‘ng chizma (surilmagan).
    await goTo(tester, '/lab/instruments');
    await goTo(tester, '/lab/instruments/lc/a3-bac-vitek2-platform');
    await w.snap('vitek2_tepa');
    for (final c in cards) {
      await _openCard(tester, c.id);
      expect(tester.takeException(), isNull, reason: c.id);
      expect(find.text(l.instSchematicCaption), findsOneWidget, reason: c.id);
      await w.snap(c.id);
    }
    // To‘liq ekran (kattalashtirish) — bitta karta.
    await _openCard(tester, 'a3-tox-gc-ms');
    await tester.runAsync(() async {
      await precacheImage(
        AssetImage(LabSchematic.massSpecGc.assetLarge),
        tester.element(find.byKey(_figure)),
      );
    });
    await w.tap(find.byKey(_figure));
    await w.snap('gc_ms_kattalashtirish');
  });

  testWidgets('bir nechta karta — ru, qorong‘i, 320 px', (tester) async {
    final s = await start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      size: const Size(320, 640),
    );
    await tester.runAsync(s.instruments.ensureCatalog);
    await _precacheSchematics(tester);
    final l = lookupAppLocalizations(const Locale('ru'));
    final w = Walk(tester, 'apparatus_cards_ru_dark_320');
    for (final id in [
      'a3-tox-gc-ms',
      'a3-tox-lc-ms',
      'a3-bac-maldi-tof-platform',
      'a3-bac-vitek2-platform',
      'tb-genexpert-platform',
      'a3-mol-realtime-pcr-platform',
      'a3-imm-flow-cytometer-platform',
      'a3-tb-bactec-mgit960-platform',
      'a1-bsc-class2-platform',
      'a3-trf-gel-card-system',
    ]) {
      await _openCard(tester, id);
      expect(tester.takeException(), isNull, reason: id);
      expect(find.text(l.instSchematicCaption), findsOneWidget, reason: id);
      await w.snap(id);
    }
  });
}
