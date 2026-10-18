// Lab tabi auditi qorovuli (2026-10-18, docs/AUDIT_2026-10-18_LAB.md).
//
// Lab tabidan ochiladigan HAR BIR sahifa (hub, har hujayra/element/parazit/
// gistologik namuna, har kalkulyator, QC yo'riqnomalari, apparat katalogi —
// har model, mikroskopiya atlasi — har rasm, 46 amaliy protokol
// taqdimoti, mavjud bo'lmagan id lar) haqiqiy telefon o'lchamida
// (DPR 3, notch) ochiladi va OXIRIGACHA scroll qilinadi:
//
// - layout xatosi (RenderFlex overflow va h.k.) yo'q;
// - cheksiz animatsiya yo'q (pumpAndSettle tugaydi);
// - tarjima qilinmagan ARB kaliti ("cytoTitle" kabi) ko'rinmaydi;
// - "Draft / Qoralama / Черновик", "TODO", "null", "NaN", "Instance of",
//   to'ldirilmagan "{placeholder}" ko'rinmaydi (D-65);
// - ru/en da manba bet raqami o'zbekcha "46-b." bo'lib qolmaydi.
//
// Foydalanuvchi ma'lumoti bor sahifalar ham: QC to'plami (1-2s, 1-3s, R-4s,
// 2-2s, 4-1s, 10x qoidalari ishga tushgan), kalibrlash yozuvi, leykoformula
// tarixi.
//
// Tillar alohida fayllarda (`lab_audit_<til>_test.dart`) — xotira va vaqt
// taqsimlanadi.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/instruments/instruments_controller.dart';
import 'package:labguide/features/qc/qc_model.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import 'lab_audit_routes.dart';

final _keyLike = RegExp(r'^[a-z]{2,}[A-Z][A-Za-z0-9]{2,}$');
final _forbidden = RegExp(
  r'\bDraft\b|\bdraft\b|Qoralama|qoralama|Черновик|черновик|TODO|FIXME|'
  r'Instance of|\bnull\b|\bNaN\b|\bInfinity\b|\{[a-zA-Z_]+\}',
);
final _uzPage = RegExp(r'\d-(b|bet|betlar)\.');

/// Icon glif (Private Use Area) — matn emas.
bool _isIcon(String t) => t.runes.every((r) => r >= 0xE000 && r <= 0xF8FF);

List<String> _visibleTexts() {
  final pages = find.byType(LgPage).hitTestable();
  final root = pages.evaluate().isEmpty
      ? find.byType(Scaffold).last
      : pages.first;
  return [
    for (final e
        in find
            .descendant(of: root, matching: find.byType(RichText))
            .evaluate())
      if ((e.widget as RichText).text.toPlainText() case final t
          when !_isIcon(t))
        t,
  ];
}

typedef LabConfig = ({Size size, double textScale, ThemeMode theme});

/// iPhone 390×844 va kichik Android 360×640; 1,0 va 1,3 shrift; kunduzgi
/// va tungi — har o'lcham har ikki shrift va mavzu bilan bir marta.
const labAuditConfigs = <LabConfig>[
  (size: Size(390, 844), textScale: 1.0, theme: ThemeMode.light),
  (size: Size(390, 844), textScale: 1.3, theme: ThemeMode.dark),
  (size: Size(360, 640), textScale: 1.0, theme: ThemeMode.dark),
  (size: Size(360, 640), textScale: 1.3, theme: ThemeMode.light),
];

/// Foydalanuvchi ma'lumoti bor sahifalar: QC to'plami (Westgard qoidalari
/// ishga tushgan seriyalar bilan), kalibrlash yozuvi, leykoformula tarixi.
Future<List<String>> seedLabData(WidgetTester tester, AppServices s) async {
  final routes = <String>[];
  await tester.runAsync(() async {
    final set = await s.qc.addSet(
      name: 'Glyukoza',
      unit: 'mmol/L',
      targetSource: QcTargetSource.laboratory,
      levels: [
        (label: 'Past', lot: 'A-1', mean: 5, sd: 0.2),
        (label: 'Yuqori', lot: 'B-2', mean: 15, sd: 0.5),
      ],
    );
    // Qabul, 1-2s, 1-3s, R-4s, 2-2s, 4-1s va 10x — vaqt tartibida (rad
    // etilgan seriya keyingi qoidalarda ishlatilmaydi — D-27).
    final runs = <Map<String, double>>[
      {'L1': 5.0, 'L2': 15.0}, // qabul
      {'L1': 5.5, 'L2': 15.2}, // 1-2s (ogohlantirish)
      {'L1': 5.7, 'L2': 15.1}, // 1-3s
      {'L1': 5.5, 'L2': 13.9}, // R-4s
      {'L1': 5.45, 'L2': 16.1}, // 2-2s (seriya ichida)
      for (var i = 0; i < 2; i++) {'L1': 5.25, 'L2': 15.6}, // → 4-1s
      for (var i = 0; i < 4; i++) {'L1': 5.1, 'L2': 15.25}, // → 10x
    ];
    final t0 = DateTime(2026, 9, 1, 8);
    for (final (i, v) in runs.indexed) {
      await s.qc.addRun(set.id, v, at: t0.add(Duration(days: i)));
    }
    final codes = {for (final r in s.qc.data.runsOf(set.id)) ...r.enteredRules};
    expect(
      codes,
      containsAll(['1-2s', '1-3s', '2-2s', 'R-4s', '4-1s', '10x']),
      reason: 'QC qoidalari ishga tushdi',
    );
    routes
      ..add('/lab/qc')
      ..add('/lab/qc/set/${set.id}')
      ..add('/lab/qc/set/${set.id}/target/L1');
    final mine = await s.instruments.addFromCatalog('human-humalyzer-4000');
    final rec = await s.instruments.addRecord(
      instrument: mine,
      instrumentName: 'HUMAN HumaLyzer 4000',
      analyteId: 'glucose-plasma-fasting',
      reagent: const ReagentChoice(
        maker: 'HUMAN',
        ref: '10121',
        ifuVersion: '2024-01',
      ),
      calibratorLot: 'L-77',
      levels: const [CalibratorLevel(name: '1', value: 5.55, unit: 'mmol/L')],
      performedOn: DateTime(2026, 10, 1),
      outcome: CalibrationOutcome.accepted,
      note: 'Audit',
    );
    routes
      ..add('/lab/calibration/log')
      ..add('/lab/calibration/log/${rec.id}')
      ..add('/lab/calibration?mine=${mine.id}&analyte=glucose-plasma-fasting')
      ..add('/lab/instruments/m/human-humalyzer-4000');
    final diff = s.differential..setWbc(7.2);
    for (final c in DiffCell.values) {
      for (var i = 0; i < 3; i++) {
        diff.tap(c);
      }
    }
    final r = await diff.save(label: 'Audit');
    routes
      ..add('/lab/differential/count')
      ..add('/lab/differential/history')
      ..add('/lab/differential/history/${r!.id}');
  });
  return routes;
}

void runLabAudit(AppLanguage lang) {
  setUpAll(loadAppFonts);

  for (final c in labAuditConfigs) {
    final tag =
        '${lang.name} ${c.size.width.toInt()}×${c.size.height.toInt()} '
        '×${c.textScale} ${c.theme.name}';
    testWidgets('Lab: barcha sahifalar xatosiz — $tag', (tester) async {
      final s = await makeServices(tester, language: lang, themeMode: c.theme);
      // Tungi konfiguratsiyalarda — foydalanuvchi ma'lumoti bilan; kunduzgida
      // — bo'sh holatlar (QC, kalibrlash jurnali, tarix bo'sh).
      final seeded = c.theme == ThemeMode.dark
          ? await seedLabData(tester, s)
          : const <String>[];
      await pumpApp(tester, s, size: c.size, textScale: c.textScale);
      final catalog = DeckCatalog.peek(s.curriculum.bundle ?? rootBundle)!;
      expect(catalog.protocols, hasLength(46), reason: '46 amaliy protokol');
      for (final e in catalog.protocols) {
        expect(e.languages, containsAll(['uz', 'ru', 'en']), reason: e.id);
        await tester.runAsync(
          () => DeckCatalog.loadDeck(rootBundle, e, e.resolveLang(lang.name)),
        );
      }
      final routes = [
        ...labStaticRoutes,
        ...labContentRoutes(),
        ...labCatalogRoutes(s),
        ...labMissingRoutes,
        ...protocolDeckRoutes(catalog),
        ...seeded,
      ];
      final failures = <String>[];
      for (final r in routes) {
        routerOf(tester).go(r);
        try {
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 10),
          );
        } on FlutterError {
          failures.add('$r: cheksiz animatsiya (pumpAndSettle tugamadi)');
          continue;
        }
        final seen = <String>{};
        void check() {
          if (tester.takeException() case final e?) failures.add('$r: $e');
          for (final t in _visibleTexts()) {
            if (!seen.add(t)) continue;
            if (_keyLike.hasMatch(t.trim())) failures.add('$r: kalit «$t»');
            if (_forbidden.firstMatch(t) case final m?) {
              failures.add('$r: «${m[0]}» — $t');
            }
            if (lang != AppLanguage.uz && _uzPage.hasMatch(t)) {
              failures.add('$r: o‘zbekcha bet — $t');
            }
          }
        }

        check();
        final page = find.byType(LgPage).hitTestable();
        if (page.evaluate().isEmpty) continue;
        final list = find
            .descendant(of: page.first, matching: find.byType(Scrollable))
            .first;
        for (var i = 0; i < 80; i++) {
          final pos = tester.state<ScrollableState>(list).position;
          if (pos.pixels >= pos.maxScrollExtent - 1) break;
          pos.jumpTo((pos.pixels + 500).clamp(0, pos.maxScrollExtent));
          await tester.pump();
          check();
        }
      }
      expect(failures, isEmpty, reason: failures.toSet().join('\n'));
    }, timeout: const Timeout(Duration(minutes: 30)));
  }
}
