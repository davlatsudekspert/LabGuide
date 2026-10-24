import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/instruments_controller.dart';

Map<String, Object?> _legacyJson({String outcome = 'accepted'}) => {
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
  'outcome': outcome,
  'created_at': '2026-01-02T10:00:00.000',
};

const _reagent = ReagentChoice(maker: 'M', ref: 'R', ifuVersion: '1');
const _levels = [CalibratorLevel(name: '1', value: 1, unit: 'mmol/L')];

Future<(InstrumentsController, MemoryKeyValueStore, MyInstrument)>
_make() async {
  final store = MemoryKeyValueStore();
  final c = InstrumentsController(store, bundle: rootBundle);
  final m = await c.addCustom(
    maker: 'Dirui',
    model: 'CS-T240',
    category: InstrumentCategory.chemistry,
  );
  return (c, store, m);
}

Future<CalibrationRecord> _add(
  InstrumentsController c,
  MyInstrument m, {
  CalibrationOutcome outcome = CalibrationOutcome.pending,
  String? approvedBy,
  QcAfter qcAfter = QcAfter.notRun,
  CalibrationKind kind = CalibrationKind.training,
  String? sopRef,
}) => c.addRecord(
  instrument: m,
  instrumentName: 'x',
  analyteId: 'urea',
  reagent: _reagent,
  calibratorLot: 'L',
  levels: _levels,
  performedOn: DateTime(2026, 10, 9),
  outcome: outcome,
  approvedBy: approvedBy,
  qcAfter: qcAfter,
  kind: kind,
  sopRef: sopRef,
);

void main() {
  group('validateCalibrationAcceptance', () {
    test('only accepted is constrained', () {
      for (final o in [
        CalibrationOutcome.pending,
        CalibrationOutcome.rejected,
      ]) {
        expect(
          validateCalibrationAcceptance(
            outcome: o,
            approvedBy: null,
            qcAfter: QcAfter.fail,
          ),
          isNull,
        );
      }
    });

    test('accepted needs approver first, then passing QC', () {
      CalibrationIssue? v(String? who, QcAfter q) =>
          validateCalibrationAcceptance(
            outcome: CalibrationOutcome.accepted,
            approvedBy: who,
            qcAfter: q,
          );
      expect(v(null, QcAfter.pass), CalibrationIssue.approverRequired);
      expect(v('  ', QcAfter.pass), CalibrationIssue.approverRequired);
      expect(v('QA officer', QcAfter.notRun), CalibrationIssue.qcPassRequired);
      expect(v('QA officer', QcAfter.fail), CalibrationIssue.qcPassRequired);
      expect(v('QA officer', QcAfter.pass), isNull);
    });
  });

  group('CalibrationRecord JSON', () {
    test('legacy record loads with safe defaults and is not upgraded', () {
      final r = CalibrationRecord.fromJson(_legacyJson());
      expect(r.outcome, CalibrationOutcome.accepted);
      expect(r.kind, CalibrationKind.training);
      expect(r.qcAfter, QcAfter.notRun);
      expect(r.approvedBy, isNull);
      expect(r.approvedAt, isNull);
      expect(r.sopRef, isNull);
      expect(r.legacy, isTrue);
      final out = r.toJson();
      for (final k in [
        'kind',
        'qc_after',
        'approved_by',
        'approved_at',
        'sop_ref',
      ]) {
        expect(out.containsKey(k), isFalse, reason: k);
      }
      expect(CalibrationRecord.fromJson(out).legacy, isTrue);
    });

    test('new record round-trips all new fields', () {
      final r = CalibrationRecord(
        id: 'n1',
        instrumentId: 'i1',
        instrumentName: 'A',
        analyteId: 'urea',
        reagent: _reagent,
        calibratorLot: 'L',
        levels: _levels,
        performedOn: DateTime(2026, 10, 9),
        outcome: CalibrationOutcome.accepted,
        createdAt: DateTime(2026, 10, 9, 8),
        kind: CalibrationKind.lab,
        qcAfter: QcAfter.pass,
        approvedBy: 'Head of lab',
        approvedAt: DateTime(2026, 10, 9, 9),
        sopRef: 'SOP-12',
      );
      final back = CalibrationRecord.fromJson(
        (jsonDecode(jsonEncode(r.toJson())) as Map).cast<String, Object?>(),
      );
      expect(back.legacy, isFalse);
      expect(back.kind, CalibrationKind.lab);
      expect(back.qcAfter, QcAfter.pass);
      expect(back.approvedBy, 'Head of lab');
      expect(back.approvedAt, DateTime(2026, 10, 9, 9));
      expect(back.sopRef, 'SOP-12');
      expect(back.outcome, CalibrationOutcome.accepted);
    });

    test('unknown enum names fall back to the safe default', () {
      final j = _legacyJson()
        ..['kind'] = 'weird'
        ..['qc_after'] = 'weird';
      final r = CalibrationRecord.fromJson(j);
      expect(r.kind, CalibrationKind.training);
      expect(r.qcAfter, QcAfter.notRun);
    });
  });

  group('InstrumentsController safety', () {
    test('accepted without approver or QC pass is refused', () async {
      final (c, _, m) = await _make();
      Future<void> acc({String? who, QcAfter q = QcAfter.pass}) => _add(
        c,
        m,
        outcome: CalibrationOutcome.accepted,
        approvedBy: who,
        qcAfter: q,
        kind: CalibrationKind.lab,
      );
      await expectLater(acc(), throwsArgumentError);
      await expectLater(acc(who: 'QA', q: QcAfter.fail), throwsArgumentError);
      await expectLater(acc(who: 'QA', q: QcAfter.notRun), throwsArgumentError);
      expect(c.records, isEmpty);
      expect(c.audit, isEmpty);
      await acc(who: ' QA officer ');
      expect(c.records.single.approvedBy, 'QA officer');
      expect(c.records.single.approvedAt, isNotNull);
    });

    test('defaults are training, QC not run, pending', () async {
      final (c, _, m) = await _make();
      final r = await _add(c, m, sopRef: ' SOP-1 ');
      expect(r.kind, CalibrationKind.training);
      expect(r.qcAfter, QcAfter.notRun);
      expect(r.outcome, CalibrationOutcome.pending);
      expect(r.sopRef, 'SOP-1');
      expect(r.legacy, isFalse);
    });

    test('create, edit and delete leave append-only audit entries', () async {
      final (c, store, m) = await _make();
      final r = await _add(c, m);
      await c.updateRecord(
        r.copyWith(
          outcome: CalibrationOutcome.accepted,
          approvedBy: 'QA',
          qcAfter: QcAfter.pass,
        ),
      );
      await c.removeRecord(r.id);
      expect(c.records, isEmpty);
      expect(c.audit.map((e) => e.action), [
        CalibrationAuditAction.created,
        CalibrationAuditAction.edited,
        CalibrationAuditAction.deleted,
      ]);
      expect(c.auditFor(r.id), hasLength(3));
      // Qayta ochilganda ham saqlanadi.
      final again = InstrumentsController(store, bundle: rootBundle);
      expect(again.audit, hasLength(3));
      expect(again.audit.last.recordId, r.id);
    });

    test('invalid edit is refused and not audited', () async {
      final (c, _, m) = await _make();
      final r = await _add(c, m);
      await expectLater(
        c.updateRecord(r.copyWith(outcome: CalibrationOutcome.accepted)),
        throwsArgumentError,
      );
      expect(c.auditFor(r.id), hasLength(1));
      expect(c.records.single.outcome, CalibrationOutcome.pending);
    });

    test(
      'legacy record survives other writes unchanged, history wiped by reset',
      () async {
        final store = MemoryKeyValueStore();
        await store.setString(
          StoreKeys.calibrationLog,
          jsonEncode([_legacyJson()]),
        );
        final c = InstrumentsController(store, bundle: rootBundle);
        final m = await c.addCustom(
          maker: 'D',
          model: 'M',
          category: InstrumentCategory.chemistry,
        );
        await _add(c, m);
        final stored = (jsonDecode(
          store.getString(StoreKeys.calibrationLog)!,
        ) as List).cast<Map<String, Object?>>();
        final old = stored.firstWhere((e) => e['id'] == 'old1');
        expect(old.containsKey('kind'), isFalse);
        expect(old['outcome'], 'accepted');
        c.resetInMemory();
        expect(c.audit, isEmpty);
        expect(StoreKeys.all, contains(StoreKeys.calibrationAudit));
      },
    );
  });
}
