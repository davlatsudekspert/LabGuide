// Yo‘nalish (lab) kartalaridagi apparat SINFI chizmalari — foydalanuvchi
// sifatida (walk_helper.dart). Chizmasi bor har bir karta ochiladi: rasm
// kesilmaganmi, izoh (“Sxematik tasvir — aniq model emas”) o‘qiladimi, matn
// ustma-ust tushmaydimi — rasmlar ko‘zdan kechiriladi.
//
//   flutter test tool/screenshots/walk_apparatus_cards_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _figure = ValueKey('lab-card-schematic');

Future<void> _precacheSchematics(WidgetTester tester) => tester.runAsync(
  () async {
    // Standart kesh 100 MB: 1200 px nusxalar sig‘may, eskilari chiqib ketardi.
    PaintingBinding.instance.imageCache
      ..maximumSizeBytes = 1 << 30
      ..maximumSize = 2000;
    final ctx = tester.element(find.byType(Scaffold).first);
    for (final s in LabSchematic.values) {
      await precacheImage(AssetImage(s.asset), ctx);
      await precacheImage(AssetImage(s.assetLarge), ctx);
    }
    for (final s in InstrumentSchematic.values) {
      await precacheImage(AssetImage(s.assetLarge), ctx);
    }
  },
);

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

/// “Qismlari va ishlash prinsipi” panelini ochib, uch qadamda suratga oladi:
/// chizma + ochilgan ro‘yxat boshi, ro‘yxat oxiri, prinsip va natija.
Future<void> _snapPanel(
  WidgetTester tester,
  Walk w,
  String route,
  String key,
  String title,
  String name,
) async {
  await goTo(tester, '/lab/instruments');
  await goTo(tester, route);
  final panel = find.byKey(ValueKey('schematic-parts-$key'));
  for (var i = 0; i < 40 && panel.evaluate().isEmpty; i++) {
    await w.scroll(300);
  }
  await tester.ensureVisible(panel);
  await tester.pumpAndSettle();
  await w.tap(find.descendant(of: panel, matching: find.text(title)));
  expect(tester.takeException(), isNull, reason: name);
  // Chizma (raqamli belgilar) va ro‘yxatning boshi bir ekranda.
  final fig = find.byWidgetPredicate(
    (wd) =>
        wd.key == const ValueKey('lab-card-schematic') ||
        wd.key == const ValueKey('instrument-schematic'),
  );
  await tester.runAsync(() async {});
  await Scrollable.ensureVisible(tester.element(fig), alignment: 0.02);
  await tester.pumpAndSettle();
  await w.snap('${name}_1_rasm_va_qismlar');
  await tester.ensureVisible(find.byKey(const ValueKey('schematic-part-1')));
  await w.scroll(220);
  await w.snap('${name}_2_qismlar');
  await tester.ensureVisible(
    find.byKey(const ValueKey('schematic-parts-result')),
  );
  await tester.pumpAndSettle();
  await w.snap('${name}_3_prinsip_natija');
  expect(tester.takeException(), isNull, reason: name);
}

const _panelCards = [
  ('/lab/instruments/lc/a3-tox-gc-ms', 'mass_spec_gc', 'gc_ms'),
  ('/lab/instruments/lc/a3-bac-vitek2-platform', 'microbial_id_ast', 'vitek2'),
  ('/lab/instruments/lc/a3-bac-maldi-tof-platform', 'maldi_tof', 'maldi'),
  ('/lab/instruments/lc/tb-genexpert-platform', 'cartridge_molecular', 'xpert'),
  ('/lab/instruments/lc/a3-mol-realtime-pcr-platform', 'real_time_pcr', 'pcr'),
  ('/lab/instruments/m/roche-cobas-c-311', 'chemistry', 'biokimyo_model'),
];

void main() {
  setUpAll(loadAppFonts);

  // Qismlar paneli (egasi talabi 2026-10-25): uz yorug‘ 390 px va
  // ru qorong‘i 320 px.
  for (final (name, lang, code, theme, size) in [
    (
      'uz_light_390',
      AppLanguage.uz,
      'uz',
      ThemeMode.light,
      const Size(390, 844),
    ),
    ('ru_dark_320', AppLanguage.ru, 'ru', ThemeMode.dark, const Size(320, 640)),
  ]) {
    testWidgets('qismlar paneli — $name', (tester) async {
      final s = await start(tester, lang: lang, theme: theme, size: size);
      await tester.runAsync(s.instruments.ensureCatalog);
      await _precacheSchematics(tester);
      final l = lookupAppLocalizations(Locale(code));
      final w = Walk(tester, 'apparatus_parts_$name');
      for (final (route, key, short) in _panelCards) {
        await _snapPanel(tester, w, route, key, l.schemPartsPanelTitle, short);
      }
    });
  }

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

  // Turli ekran o‘lchamlari, til va rejimlar (egasi talabi 2026-10-25):
  // telefon kichik/katta, planshet, yorug‘/qorong‘i, uch til, katta shrift.
  final variants = <(String, AppLanguage, String, ThemeMode, Size, double)>[
    (
      'en_dark_360_x13',
      AppLanguage.en,
      'en',
      ThemeMode.dark,
      const Size(360, 780),
      1.3,
    ),
    (
      'uz_dark_430',
      AppLanguage.uz,
      'uz',
      ThemeMode.dark,
      const Size(430, 932),
      1.0,
    ),
    (
      'ru_light_820_tablet',
      AppLanguage.ru,
      'ru',
      ThemeMode.light,
      const Size(820, 1180),
      1.0,
    ),
    (
      'uz_light_320_x20',
      AppLanguage.uz,
      'uz',
      ThemeMode.light,
      const Size(320, 640),
      2.0,
    ),
  ];
  for (final (name, lang, code, theme, size, scale) in variants) {
    testWidgets('sakkiz karta — $name', (tester) async {
      final s = await start(
        tester,
        lang: lang,
        theme: theme,
        size: size,
        textScale: scale,
      );
      await tester.runAsync(s.instruments.ensureCatalog);
      await _precacheSchematics(tester);
      final l = lookupAppLocalizations(Locale(code));
      final w = Walk(tester, 'apparatus_cards_$name');
      for (final id in [
        'a3-tox-gc-ms',
        'a3-bac-maldi-tof-platform',
        'a3-bac-vitek2-platform',
        'tb-genexpert-platform',
        'a3-mol-realtime-pcr-platform',
        'a3-imm-flow-cytometer-platform',
        'a3-tb-bactec-mgit960-platform',
        'a1-bsc-class2-platform',
      ]) {
        await _openCard(tester, id);
        expect(tester.takeException(), isNull, reason: '$name $id');
        expect(find.text(l.instSchematicCaption), findsOneWidget, reason: id);
        expect(find.text(l.instSchematicNotPhoto), findsOneWidget, reason: id);
        await w.snap(id);
      }
    });
  }
}
