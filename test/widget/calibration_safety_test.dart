// Kalibrlash jurnali xavfsizligi (audit 2026-10-24 P0): tasdiqlovchi, QC,
// o'quv/laboratoriya turi, tarix va eski yozuv belgisi.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/instruments/instruments_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

Future<void> _seek(WidgetTester tester, Finder f) async {
  if (f.evaluate().isNotEmpty) {
    await tester.ensureVisible(f.last);
    await tester.pumpAndSettle();
    return;
  }
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await _seek(tester, find.text(text));
  await tester.ensureVisible(find.text(text).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  await _seek(tester, find.text(label));
  final field = find.descendant(
    of: find
        .ancestor(of: find.text(label).last, matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, value);
  await tester.pumpAndSettle();
}

/// Kalibrlash sahifasi: saqlangan apparat, glyukoza, reagent va IFU
/// kiritilgan; yozuv shakli ochiq, lot kiritilgan.
Future<AppLocalizations> _openRecordForm(
  WidgetTester tester, {
  KeyValueStore? store,
}) async {
  final l = lookupAppLocalizations(const Locale('uz'));
  final s = await makeServices(tester, store: store as MemoryKeyValueStore?);
  _svc = s;
  final mine = await tester.runAsync(
    () => s.instruments.addFromCatalog('human-humalyzer-4000'),
  );
  await pumpApp(tester, s);
  await goTo(
    tester,
    '/lab/calibration?mine=${mine!.id}&analyte=glucose-plasma-fasting',
  );
  await _enterField(tester, l.calReagentRef, '10121');
  await _enterField(tester, l.calIfuRevision, '2024-01');
  await _tapText(tester, l.calShowGuide);
  await _tapText(tester, l.calRecordCreate);
  await _enterField(tester, l.calCalibratorLot, 'L-77');
  await _enterField(tester, l.calLevelUnit, 'mmol/L');
  return l;
}

late AppServices _svc;

final _l = lookupAppLocalizations(const Locale('uz'));

void main() {
  setUpAll(loadAppFonts);

  testWidgets('«qabul qilindi» tasdiqlovchisiz va QC o‘tmasa bloklanadi', (
    tester,
  ) async {
    final l = await _openRecordForm(tester);
    await _enterField(tester, l.calLevelValue, '5,55');
    // Standart: o'quv yozuvi, QC o'tkazilmagan — ogohlantirish ko'rinadi.
    await _seek(tester, find.text(l.calSafeQcNotRunWarn));
    expect(find.text(l.calSafeTrainingNote), findsOneWidget);
    // QC o'tmasa «qabul qilindi» tanlanmaydi.
    await _tapText(tester, l.calOutcomeAccepted);
    await _seek(tester, find.text(l.calSafeQcPassRequired));
    // QC o'tdi, lekin tasdiqlovchi yo'q.
    await _tapText(tester, l.calSafeQcPass);
    await _tapText(tester, l.calOutcomeAccepted);
    await _tapText(tester, l.calRecordSave);
    await _seek(tester, find.text(l.calSafeApproverRequired));
    final s = _svc;
    expect(s.instruments.records, isEmpty);
    // Tasdiqlovchi kiritilgach saqlanadi.
    await _enterField(tester, l.calSafeApprovedBy, 'QA mudiri');
    await _tapText(tester, l.calRecordSave);
    expect(find.text(l.calRecordSaved), findsOneWidget);
    final r = s.instruments.records.single;
    expect(r.outcome, CalibrationOutcome.accepted);
    expect(r.approvedBy, 'QA mudiri');
    expect(r.qcAfter, QcAfter.pass);
  });

  testWidgets('o‘chirish tarixga «o‘chirildi» yozadi', (tester) async {
    final s = await makeServices(tester);
    final m = await tester.runAsync(
      () => s.instruments.addFromCatalog('human-humalyzer-4000'),
    );
    final rec = await tester.runAsync(
      () => s.instruments.addRecord(
        instrument: m!,
        instrumentName: 'HUMAN',
        analyteId: 'urea',
        reagent: const ReagentChoice(maker: 'H', ref: 'R', ifuVersion: '1'),
        calibratorLot: 'L-1',
        levels: const [CalibratorLevel(name: '1', value: 1, unit: 'mmol/L')],
        performedOn: DateTime(2026, 10, 9),
        outcome: CalibrationOutcome.pending,
      ),
    );
    await pumpApp(tester, s);
    await goTo(tester, '/lab/calibration/log/${rec!.id}');
    await _tapText(tester, _l.calDeleteRecord);
    await _tapText(tester, _l.actionDelete);
    expect(s.instruments.records, isEmpty);
    expect(s.instruments.audit.map((e) => e.action), [
      CalibrationAuditAction.created,
      CalibrationAuditAction.deleted,
    ]);
    // O'chirilgan yozuvning izi jurnal sahifasida ko'rinadi.
    await goTo(tester, '/lab/calibration/log');
    expect(find.text(_l.calLogEmpty), findsOneWidget);
  });

  testWidgets(
    'eski «qabul qilindi» yozuvi «eski, tasdiqlanmagan» belgisi bilan',
    (tester) async {
      final store = MemoryKeyValueStore();
      await store.setString(
        StoreKeys.calibrationLog,
        jsonEncode([
          {
            'id': 'old1',
            'instrument_id': 'i1',
            'instrument_name': 'Old analyser',
            'analyte_id': 'urea',
            'reagent': {'maker': 'M', 'ref': 'R', 'ifu': '1'},
            'calibrator_lot': 'L1',
            'levels': [
              {'name': '1', 'value': 5.0, 'unit': 'mmol/L'},
            ],
            'performed_on': '2026-01-02T00:00:00.000',
            'outcome': 'accepted',
            'created_at': '2026-01-02T10:00:00.000',
          },
        ]),
      );
      final s = await makeServices(tester, store: store);
      await pumpApp(tester, s);
      await goTo(tester, '/lab/calibration/log/old1');
      expect(find.text(_l.calSafeLegacyTag), findsOneWidget);
      expect(find.text(_l.calSafeTrainingTag), findsOneWidget);
      expect(find.text(_l.calOutcomeAccepted), findsOneWidget);
      // Jimgina yangilanmagan.
      expect(s.instruments.records.single.legacy, isTrue);
      expect(s.instruments.records.single.outcome, CalibrationOutcome.accepted);
    },
  );
}
