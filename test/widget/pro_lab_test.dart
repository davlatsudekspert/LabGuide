// Mutaxassis Pro (D-78): QC xulosa hisoboti va kalibrlash jurnali eksporti.
// Bepul QC va kalibrlash ekranlari ochiq va o'zgarmagan (CSV nusxasi bepul);
// Pro qatori faqat bayroq bilan; eshik holatlari; Talaba/Ustoz rejasi
// Mutaxassis funksiyalarini ochmaydi; eksport fayllari ulashish oynasiga.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/entitlements/pro_catalog.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/share/file_export.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';
import '../helpers/pro_states.dart';
import 'lab_audit_matrix.dart' show seedLabData;

final uz = lookupAppLocalizations(const Locale('uz'));

const _tall = Size(390, 2600);

final _locked = find.byKey(const ValueKey('pay-locked'));

Future<void> _scrollTo(WidgetTester tester, Finder f) => tester.scrollUntilVisible(
  f,
  300,
  scrollable: find.byType(Scrollable).hitTestable().first,
);

Future<void> _tap(WidgetTester tester, Finder f) async {
  await _scrollTo(tester, f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// QC to'plami yo'li (`/lab/qc/set/<id>`).
String _setRoute(List<String> routes) =>
    routes.firstWhere((r) => RegExp(r'^/lab/qc/set/[^/]+$').hasMatch(r));

Future<void> _export(WidgetTester tester, String kind) async {
  await _tap(tester, find.byKey(const ValueKey('export-button')));
  await tester.tap(find.byKey(ValueKey('export-$kind')));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('bayroq o‘chiq: QC va kalibrlash ekranlarida Pro qatori yo‘q, '
      'bepul CSV nusxasi bor', (tester) async {
    final s = await makeServices(tester);
    final routes = await seedLabData(tester, s);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, _setRoute(routes));
    await _scrollTo(tester, find.text(uz.qcCopyCsv));
    expect(find.byKey(const ValueKey('qc-report-entry')), findsNothing);
    await goTo(tester, '/lab/calibration/log');
    expect(find.byKey(const ValueKey('cal-export-entry')), findsNothing);
  });

  for (final state in GateState.values) {
    testWidgets('QC hisobot kirishi (Mutaxassis): ${state.name} — '
        '${opens(state) ? 'ochiladi' : 'to‘lov oynasi'}', (tester) async {
      final (s, _, _) = await proApp(tester, state, plan: ProPlan.specialist);
      final routes = await seedLabData(tester, s);
      await pumpApp(tester, s, size: _tall);
      final setRoute = _setRoute(routes);
      await goTo(tester, setRoute);
      // Bepul QC — ochiq, CSV nusxasi joyida.
      await _scrollTo(tester, find.text(uz.qcCopyCsv));
      await _tap(tester, find.byKey(const ValueKey('qc-report-entry')));
      if (opens(state)) {
        expect(find.byKey(const ValueKey('qc-report')), findsOneWidget);
      } else {
        expect(_locked, findsOneWidget);
        expect(find.text(uz.proLockedLab), findsOneWidget);
        // Faqat Mutaxassis va Premium taklif qilinadi.
        expect(find.text(uz.proTierNameTeacher), findsNothing);
        // To'g'ridan-to'g'ri havola — yopiq holat; ma'lumot o'zgarmagan.
        await goTo(tester, '$setRoute/report');
        expect(find.byKey(const ValueKey('pro-gate-closed')), findsOneWidget);
      }
      expect(s.qc.data.sets, hasLength(1));
    });
  }

  for (final plan in [ProPlan.student, ProPlan.teacher]) {
    testWidgets('${plan.name} obunasi Mutaxassis funksiyalarini ochmaydi', (
      tester,
    ) async {
      final (s, _, _) = await proApp(tester, GateState.subscribed, plan: plan);
      final routes = await seedLabData(tester, s);
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, _setRoute(routes));
      await _tap(tester, find.byKey(const ValueKey('qc-report-entry')));
      expect(_locked, findsOneWidget);
      await goTo(tester, '/lab/calibration/log');
      await _tap(tester, find.byKey(const ValueKey('cal-export-entry')));
      expect(_locked, findsOneWidget);
      expect(find.text(uz.proExportTitle), findsNothing);
    });
  }

  testWidgets('QC hisobot: daraja kartalari, qoidalar, CSV (xulosa + seriyalar) '
      'va PDF eksport', (tester) async {
    final (s, files, _) = await proApp(tester, GateState.trial, plan: ProPlan.specialist);
    final routes = await seedLabData(tester, s);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '${_setRoute(routes)}/report');
    expect(find.byKey(const ValueKey('qc-report')), findsOneWidget);
    expect(find.text(uz.proExportNotClinical), findsOneWidget);
    expect(find.byKey(const ValueKey('qc-report-level-L1-A-1')), findsOneWidget);
    await _scrollTo(tester, find.byKey(const ValueKey('qc-report-level-L2-B-2')));
    expect(find.textContaining('1-3s × '), findsWidgets);
    await _export(tester, 'csv');
    final batch = files.shared.single;
    expect([for (final f in batch) f.mimeType], [ExportFile.csv, ExportFile.csv]);
    String text(ExportFile f) => utf8.decode(f.bytes.sublist(3));
    expect(text(batch.first), startsWith('test,unit,level,lot,target_mean'));
    expect(text(batch.last), startsWith('date,test,level,lot,value,unit'));
    expect(text(batch.last), contains('Glyukoza'));
    await _export(tester, 'pdf');
    final pdf = files.last(ExportFile.pdf)!;
    expect(latin1.decode(pdf.bytes.sublist(0, 8)), '%PDF-1.7');
    expect(pdf.name, startsWith('labguide-qc-glyukoza-'));
  });

  testWidgets('kalibrlash jurnali eksporti (oflayn kesh): CSV jurnal + tarix, '
      'PDF; yozuvlar o‘zgarmaydi', (tester) async {
    final (s, files, _) = await proApp(tester, GateState.offline, plan: ProPlan.specialist);
    await seedLabData(tester, s);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/lab/calibration/log');
    await _tap(tester, find.byKey(const ValueKey('cal-export-entry')));
    await tester.tap(find.byKey(const ValueKey('export-csv')));
    await tester.pumpAndSettle();
    final batch = files.shared.single;
    expect(batch, hasLength(2));
    final log = utf8.decode(batch.first.bytes.sublist(3));
    expect(log, startsWith('record_id,performed_on,kind,instrument'));
    expect(log, contains('HUMAN HumaLyzer 4000'));
    expect(log, contains('L-77'));
    expect(log, contains('5.55,mmol/L'));
    await _tap(tester, find.byKey(const ValueKey('cal-export-entry')));
    await tester.tap(find.byKey(const ValueKey('export-pdf')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(files.last(ExportFile.pdf), isNotNull);
    expect(s.instruments.records, hasLength(1));
  });

  testWidgets('ulashish imkoni bo‘lmasa — halol xabar', (tester) async {
    final (s, files, _) = await proApp(tester, GateState.subscribed, plan: ProPlan.specialist);
    files.available = false;
    await seedLabData(tester, s);
    await pumpApp(tester, s, size: _tall);
    await goTo(tester, '/lab/calibration/log');
    await _tap(tester, find.byKey(const ValueKey('cal-export-entry')));
    await tester.tap(find.byKey(const ValueKey('export-csv')));
    await tester.pumpAndSettle();
    expect(find.text(uz.proExportFailed), findsOneWidget);
  });

  for (final lang in AppLanguage.values) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('maket: ${lang.name} 320 px ×2.0 ${theme.name} — QC hisobot, '
          'QC to‘plami, jurnal, eksport oynasi', (tester) async {
        final (s, _, _) = await proApp(
          tester,
          GateState.subscribed,
          plan: ProPlan.specialist,
          language: lang,
          themeMode: theme,
        );
        final routes = await seedLabData(tester, s);
        await pumpApp(tester, s, size: const Size(320, 640), textScale: 2.0);
        for (final path in [
          _setRoute(routes),
          '${_setRoute(routes)}/report',
          '/lab/calibration/log',
        ]) {
          await goTo(tester, path);
          expect(tester.takeException(), isNull, reason: path);
          for (var i = 0; i < 40; i++) {
            final scroll = find.byType(Scrollable).hitTestable();
            if (scroll.evaluate().isEmpty) break;
            await tester.drag(scroll.first, const Offset(0, -400));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '$path #$i');
          }
        }
        await _tap(tester, find.byKey(const ValueKey('cal-export-entry')));
        expect(find.byKey(const ValueKey('export-pdf')), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'eksport oynasi');
      });
    }
  }
}
