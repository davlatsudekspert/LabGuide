// Yo‘nalish (lab) kartasi ekranidagi apparat SINFI chizmasi: model kartasidagi
// bilan bir xil vidjet (SchematicFigure) — rasm, “aniq model emas” izohi,
// lokalizatsiyalangan alt-matn, bosilsa to‘liq ekran. 320 px / ×1.3 shriftda
// overflow yo‘q; istisno kartada chizma yo‘q.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instrument_image.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _figure = ValueKey('lab-card-schematic');
const _caption = ValueKey('lab-card-schematic-caption');

final _cases = <(String, String, String Function(AppLocalizations))>[
  ('a3-tox-gc-ms', 'mass_spec_gc', (l) => l.labSchemGcMs),
  ('a3-bac-maldi-tof-platform', 'maldi_tof', (l) => l.labSchemMaldiTof),
  (
    'a3-bac-vitek2-platform',
    'microbial_id_ast',
    (l) => l.labSchemMicrobialIdAst,
  ),
  (
    'tb-genexpert-platform',
    'cartridge_molecular',
    (l) => l.labSchemCartridgeMolecular,
  ),
  (
    'tb-xpert-mtb-rif-tests',
    'cartridge_molecular',
    (l) => l.labSchemCartridgeMolecular,
  ),
  (
    'a3-mol-realtime-pcr-platform',
    'real_time_pcr',
    (l) => l.labSchemRealTimePcr,
  ),
  (
    'a3-imm-flow-cytometer-platform',
    'flow_cytometer',
    (l) => l.labSchemFlowCytometer,
  ),
  (
    'a3-tb-bactec-mgit960-platform',
    'mycobacterial_culture',
    (l) => l.labSchemMycobacterialCulture,
  ),
];

Future<void> _open(WidgetTester tester, String id) async {
  // Avval ro‘yxatga: bir xil yo‘l shablonida go() sahifa holatini (scroll)
  // saqlab qolmasin.
  await goTo(tester, '/lab/instruments');
  await goTo(tester, '/lab/instruments/lc/$id');
  final fig = find.byKey(_figure);
  // Chizma bildirishnomalar ostida — ko‘ringuncha pastga suriladi.
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
  // Rasmni haqiqiy async'da dekod qilish (testda IO uchun runAsync kerak).
  final img = tester.widget<Image>(
    find.descendant(of: fig, matching: find.byType(Image)),
  );
  await tester.runAsync(() => precacheImage(img.image, tester.element(fig)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('uz, 320 px ×1.3: chizma, izoh, alt-matn, kattalashtirish', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await tester.runAsync(s.instruments.ensureCatalog);
    await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
    final l = lookupAppLocalizations(const Locale('uz'));
    for (final (id, key, label) in _cases) {
      await _open(tester, id);
      expect(tester.takeException(), isNull, reason: id);
      final fig = find.byKey(_figure);
      expect(fig, findsOneWidget, reason: id);
      final img = tester.widget<Image>(
        find.descendant(of: fig, matching: find.byType(Image)),
      );
      expect(
        img.image,
        AssetImage('assets/instruments/schematic/${key}_480.png'),
        reason: id,
      );
      expect(img.fit, BoxFit.contain);
      expect(img.semanticLabel, l.instSchematicSemantics(label(l)), reason: id);
      // Izoh: “Sxematik tasvir — aniq model emas”, ekranga sig‘adi.
      final cap = find.descendant(
        of: find.byKey(_caption),
        matching: find.text(l.instSchematicCaption),
      );
      expect(cap, findsOneWidget, reason: id);
      final r = tester.getRect(cap);
      expect(r.left, greaterThanOrEqualTo(0), reason: id);
      expect(r.right, lessThanOrEqualTo(320), reason: id);
      final fr = tester.getRect(fig);
      expect(fr.width, lessThanOrEqualTo(320), reason: id);
      expect(fr.width / fr.height, closeTo(1.5, 0.01), reason: id);
      // Rasm ostida foto muallifi/litsenziyasi yo‘q — bu foto emas.
      expect(find.textContaining('CC BY'), findsNothing, reason: id);

      await tester.ensureVisible(fig);
      await tester.pumpAndSettle();
      await tester.tap(fig);
      await tester.pumpAndSettle();
      expect(
        find.byType(InstrumentSchematicViewer),
        findsOneWidget,
        reason: id,
      );
      final big = tester.widget<Image>(
        find.descendant(
          of: find.byType(InteractiveViewer),
          matching: find.byType(Image),
        ),
      );
      expect(
        big.image,
        AssetImage('assets/instruments/schematic/${key}_1200.png'),
        reason: id,
      );
      expect(find.text(l.instSchematicCaption), findsOneWidget, reason: id);
      await tester.tap(find.byTooltip(l.micClose));
      await tester.pumpAndSettle();
      expect(find.byType(InstrumentSchematicViewer), findsNothing, reason: id);
      expect(tester.takeException(), isNull, reason: id);
    }
  });

  testWidgets('istisno kartada (AST usuli, kalibratorlar) chizma yo‘q', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await tester.runAsync(s.instruments.ensureCatalog);
    await pumpApp(tester, s, size: const Size(320, 4000), textScale: 1.3);
    final l = lookupAppLocalizations(const Locale('uz'));
    for (final id in [
      'a3-bac-ast-method',
      'a2-method-calibrators-control-materials',
    ]) {
      await goTo(tester, '/lab/instruments/lc/$id');
      expect(tester.takeException(), isNull, reason: id);
      expect(find.byKey(_figure), findsNothing, reason: id);
      expect(find.text(l.instSchematicCaption), findsNothing, reason: id);
    }
  });

  for (final lang in [AppLanguage.ru, AppLanguage.en]) {
    testWidgets('${lang.name}: alt-matn va izoh tilga mos (GC-MS)', (
      tester,
    ) async {
      final s = await makeServices(tester, language: lang);
      await tester.runAsync(s.instruments.ensureCatalog);
      await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
      final l = lookupAppLocalizations(lang.locale);
      await _open(tester, 'a3-tox-gc-ms');
      expect(tester.takeException(), isNull);
      final img = tester.widget<Image>(
        find.descendant(of: find.byKey(_figure), matching: find.byType(Image)),
      );
      expect(img.semanticLabel, l.instSchematicSemantics(l.labSchemGcMs));
      expect(find.text(l.instSchematicCaption), findsOneWidget);
    });
  }
}
