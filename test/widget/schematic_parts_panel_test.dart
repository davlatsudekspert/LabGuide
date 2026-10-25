// “Qismlari va ishlash prinsipi” paneli (egasi talabi 2026-10-25): chizma
// ostida, standart holatda yopiq; ochilganda rasmdagi raqamlar tartibida
// qismlar (nomi + vazifasi), so‘ng prinsip va natija. Yo‘nalish kartalari va
// model kartasida bir xil vidjet; 320 px ×1.3 / ×2.0 da overflow yo‘q;
// ru/en matnlari tilga mos; ekran o‘quvchi uchun “n. nom. vazifa”.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/features/instruments/instrument_image.dart';
import 'package:labguide/features/instruments/schematic_parts.dart';
import 'package:labguide/features/instruments/schematic_parts_l10n.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

Finder _panel(String key) => find.byKey(ValueKey('schematic-parts-$key'));

Future<void> _scrollTo(WidgetTester tester, Finder f) async {
  for (var i = 0; i < 40 && f.evaluate().isEmpty; i++) {
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
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

/// Kartani ochadi, panelni topadi, yopiqligini tekshiradi va ochadi.
Future<SchematicPartsEntry> _openPanel(
  WidgetTester tester,
  AppServices s,
  String route,
  String key,
  AppLocalizations l,
) async {
  await goTo(tester, '/lab/instruments');
  await goTo(tester, route);
  final entry = s.instruments.schematicParts!.of(key)!;
  await _scrollTo(tester, _panel(key));
  expect(_panel(key), findsOneWidget, reason: key);
  // Yopiq: sarlavha bor, qismlar ro‘yxati qurilmagan (karta qisqa).
  expect(
    find.descendant(
      of: _panel(key),
      matching: find.text(l.schemPartsPanelTitle),
    ),
    findsOneWidget,
    reason: key,
  );
  expect(find.byKey(const ValueKey('schematic-part-1')), findsNothing);
  await tester.tap(
    find.descendant(
      of: _panel(key),
      matching: find.text(l.schemPartsPanelTitle),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: key);
  return entry;
}

void _expectExpanded(
  WidgetTester tester,
  SchematicPartsEntry e,
  AppLocalizations l,
  double width,
) {
  for (final p in e.parts) {
    final row = find.byKey(ValueKey('schematic-part-${p.n}'));
    expect(row, findsOneWidget, reason: '${e.key} #${p.n}');
    expect(
      find.descendant(of: row, matching: find.text('${p.n}')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: row,
        matching: find.text(schematicPartsText(l, p.nameId)!),
      ),
      findsOneWidget,
      reason: '${e.key} #${p.n}',
    );
    expect(
      find.descendant(
        of: row,
        matching: find.text(schematicPartsText(l, p.fnId)!),
      ),
      findsOneWidget,
    );
    final r = tester.getRect(row);
    expect(r.left, greaterThanOrEqualTo(0), reason: e.key);
    expect(r.right, lessThanOrEqualTo(width), reason: e.key);
  }
  final principle = find.byKey(const ValueKey('schematic-parts-principle'));
  final result = find.byKey(const ValueKey('schematic-parts-result'));
  expect(
    tester.widget<Text>(principle).data,
    schematicPartsText(l, e.principleId),
  );
  expect(tester.widget<Text>(result).data, schematicPartsText(l, e.resultId));
  expect(find.text(l.schemPartsPrincipleTitle), findsOneWidget);
  expect(find.text(l.schemPartsResultTitle), findsOneWidget);
  expect(find.text(l.schemPartsClassNote), findsOneWidget);
  expect(tester.getRect(result).right, lessThanOrEqualTo(width));
}

final _labCases = <(String, String)>[
  ('a3-tox-gc-ms', 'mass_spec_gc'),
  ('a3-bac-vitek2-platform', 'microbial_id_ast'),
  ('a3-bac-maldi-tof-platform', 'maldi_tof'),
  ('tb-genexpert-platform', 'cartridge_molecular'),
  ('a3-mol-realtime-pcr-platform', 'real_time_pcr'),
  ('a3-imm-flow-cytometer-platform', 'flow_cytometer'),
  ('a3-tb-bactec-mgit960-platform', 'mycobacterial_culture'),
  ('a1-elisa-reader-platform', 'elisa_reader'),
];

void main() {
  setUpAll(loadAppFonts);

  testWidgets('uz, 320 px ×1.3: lab kartalari va biokimyo model kartasi', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await tester.runAsync(s.instruments.ensureCatalog);
    expect(s.instruments.schematicParts, isNotNull);
    await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
    final l = lookupAppLocalizations(const Locale('uz'));
    for (final (id, key) in _labCases) {
      final e = await _openPanel(tester, s, '/lab/instruments/lc/$id', key, l);
      // Panel chizma va “aniq model emas” izohi ostida.
      expect(find.byKey(const ValueKey('lab-card-schematic')), findsOneWidget);
      expect(
        tester.getTopLeft(_panel(key)).dy,
        greaterThan(
          tester
              .getTopLeft(find.byKey(const ValueKey('schematic-not-photo')))
              .dy,
        ),
        reason: id,
      );
      _expectExpanded(tester, e, l, 320);
      await _scrollTo(
        tester,
        find.byKey(const ValueKey('schematic-parts-result')),
      );
      expect(tester.takeException(), isNull, reason: id);
    }
    // Model kartasi (foto yo‘q — biokimyo turi chizmasi).
    final e = await _openPanel(
      tester,
      s,
      '/lab/instruments/m/roche-cobas-c-311',
      'chemistry',
      l,
    );
    expect(find.byKey(const ValueKey('instrument-schematic')), findsOneWidget);
    _expectExpanded(tester, e, l, 320);
    expect(e.parts, hasLength(8));
    expect(tester.takeException(), isNull);
  });

  testWidgets('uz, 320 px ×2.0: GC-MS paneli sig‘adi', (tester) async {
    final s = await makeServices(tester);
    await tester.runAsync(s.instruments.ensureCatalog);
    await pumpApp(tester, s, size: const Size(320, 640), textScale: 2.0);
    final l = lookupAppLocalizations(const Locale('uz'));
    final e = await _openPanel(
      tester,
      s,
      '/lab/instruments/lc/a3-tox-gc-ms',
      'mass_spec_gc',
      l,
    );
    _expectExpanded(tester, e, l, 320);
    await _scrollTo(
      tester,
      find.byKey(const ValueKey('schematic-parts-result')),
    );
    expect(tester.takeException(), isNull);
  });

  for (final (lang, dark) in [
    (AppLanguage.ru, true),
    (AppLanguage.en, false),
  ]) {
    testWidgets('${lang.name}: GC-MS va gematologiya model kartasi', (
      tester,
    ) async {
      final s = await makeServices(
        tester,
        language: lang,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      );
      await tester.runAsync(s.instruments.ensureCatalog);
      await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
      final l = lookupAppLocalizations(lang.locale);
      final e = await _openPanel(
        tester,
        s,
        '/lab/instruments/lc/a3-tox-gc-ms',
        'mass_spec_gc',
        l,
      );
      _expectExpanded(tester, e, l, 320);
      final h = await _openPanel(
        tester,
        s,
        '/lab/instruments/m/human-humacount-5d',
        'hematology5',
        l,
      );
      _expectExpanded(tester, h, l, 320);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ekran o‘quvchi: qism qatori “n. nom. vazifa”, panel tugma', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final s = await makeServices(tester);
    await tester.runAsync(s.instruments.ensureCatalog);
    await pumpApp(tester, s);
    final l = lookupAppLocalizations(const Locale('uz'));
    final e = await _openPanel(
      tester,
      s,
      '/lab/instruments/lc/a3-bac-maldi-tof-platform',
      'maldi_tof',
      l,
    );
    final p = e.parts.first;
    expect(
      tester.getSemantics(find.byKey(const ValueKey('schematic-part-1'))),
      matchesSemantics(
        label:
            '1. ${schematicPartsText(l, p.nameId)}. '
            '${schematicPartsText(l, p.fnId)}',
      ),
    );
    handle.dispose();
  });

  testWidgets('qismlar indeksi bo‘lmasa panel yo‘q, chizma qoladi', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLgTheme(Brightness.light),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SchematicFigure(
            asset: 'assets/instruments/schematic/tlc_480.png',
            assetLarge: 'assets/instruments/schematic/tlc_1200.png',
            semanticLabel: 'x',
            viewerTitle: 'x',
          ),
        ),
      ),
    );
    expect(find.byType(SchematicPartsPanel), findsNothing);
    expect(find.byKey(const ValueKey('schematic-not-photo')), findsOneWidget);
  });
}
