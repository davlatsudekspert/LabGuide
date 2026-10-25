// Mutaxassis Pro (D-78): kalibrlash jurnali CSV ustunlari va qiymatlari,
// QC xulosa hisoboti (har daraja × lot: n, x̄, SD, CV, bias, qoidalar) —
// faqat saqlangan ma'lumotdan, `evaluateRuns` bilan bir xil.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instruments_controller.dart';
import 'package:labguide/features/pro/calibration_export.dart';
import 'package:labguide/features/pro/qc_report.dart';
import 'package:labguide/features/qc/qc_model.dart';
import 'package:labguide/features/qc/qc_rules.dart';

CalibrationRecord _rec({
  String id = 'r1',
  List<CalibratorLevel> levels = const [
    CalibratorLevel(name: '1', value: 5.55, unit: 'mmol/L'),
    CalibratorLevel(name: '2', value: 15.2, unit: 'mmol/L'),
  ],
  String? note,
}) => CalibrationRecord(
  id: id,
  instrumentId: 'm1',
  instrumentName: 'HUMAN HumaLyzer 4000',
  analyteId: 'glucose-plasma-fasting',
  reagent: const ReagentChoice(maker: 'HUMAN', ref: '10121', ifuVersion: '2024-01'),
  calibratorName: 'Autocal',
  calibratorLot: 'L-77',
  lotExpiry: DateTime(2027, 3, 31),
  levels: levels,
  performedOn: DateTime(2026, 10, 1),
  outcome: CalibrationOutcome.accepted,
  createdAt: DateTime(2026, 10, 1, 9, 30),
  kind: CalibrationKind.lab,
  qcAfter: QcAfter.pass,
  approvedBy: 'Mudir, K. Aliyeva',
  approvedAt: DateTime(2026, 10, 1),
  sopRef: 'SOP-12',
  note: note,
);

QcSet _set() => QcSet(
  id: 's1',
  name: 'Glyukoza',
  unit: 'mmol/L',
  targetSource: QcTargetSource.laboratory,
  createdAt: DateTime(2026, 9, 1),
  levels: [
    QcLevel(
      id: 'L1',
      label: 'Past',
      lot: 'B-2',
      mean: 5.2,
      sd: 0.2,
      since: DateTime(2026, 9, 10),
      previous: const [QcTarget(lot: 'A-1', mean: 5, sd: 0.2)],
    ),
    const QcLevel(id: 'L2', label: 'Yuqori', lot: 'C-3', mean: 15, sd: 0.5),
  ],
);

List<QcRun> _runs() {
  final t0 = DateTime(2026, 9, 1, 8);
  final values = <Map<String, double>>[
    {'L1': 5.0, 'L2': 15.0},
    {'L1': 5.5, 'L2': 15.2}, // 1-2s (L1: +2.5 SD)
    {'L1': 5.7, 'L2': 15.1}, // 1-3s (L1: +3.5 SD) → rad
    {'L1': 5.1, 'L2': 14.8},
    // 10-kundan: L1 yangi lot B-2 (x̄ 5.2).
    for (var i = 0; i < 4; i++) {'L1': 5.2 + 0.1 * (i % 2), 'L2': 15.0},
  ];
  return [
    for (final (i, v) in values.indexed)
      QcRun(id: 'r$i', at: t0.add(Duration(days: i < 4 ? i : 9 + i)), values: v),
  ];
}

void main() {
  test('kalibrlash CSV: ustunlar, har daraja — qator, barcha saqlangan '
      'maydonlar, formula himoyasi', () {
    final rows = calibrationCsvRows(
      [_rec(note: '=HYPERLINK("x")'), _rec(id: 'r2', levels: const [])],
      analyteName: (id) => id == 'glucose-plasma-fasting' ? 'Glyukoza' : id,
    );
    expect(rows.first, calibrationCsvHeader);
    expect(rows, hasLength(1 + 2 + 1));
    final row = Map.fromIterables(rows.first, rows[1]);
    expect(row['performed_on'], '2026-10-01');
    expect(row['kind'], 'lab');
    expect(row['instrument'], 'HUMAN HumaLyzer 4000');
    expect(row['analyte'], 'Glyukoza');
    expect(row['reagent_ref'], '10121');
    expect(row['reagent_ifu'], '2024-01');
    expect(row['calibrator_lot'], 'L-77');
    expect(row['lot_expiry'], '2027-03-31');
    expect(row['level'], '1');
    expect(row['level_value'], '5.55');
    expect(row['level_unit'], 'mmol/L');
    expect(row['outcome'], 'accepted');
    expect(row['qc_after'], 'pass');
    expect(row['approved_by'], 'Mudir, K. Aliyeva');
    expect(row['sop_ref'], 'SOP-12');
    expect(row['note'], "'=HYPERLINK(\"x\")");
    expect(Map.fromIterables(rows.first, rows[2])['level_value'], '15.2');
    // Darajasiz yozuv — bitta qator, daraja ustunlari bo'sh.
    final empty = Map.fromIterables(rows.first, rows[3]);
    expect((empty['level'], empty['level_value']), ('', ''));
    // Jurnalda bo'lmagan maydon to'qilmaydi.
    expect(rows.first, isNot(contains('analyst')));
  });

  test('kalibrlash CSV fayllari: jurnal va tarix, UTF-8 BOM', () {
    final files = calibrationCsvFiles(
      [_rec()],
      [
        CalibrationAuditEntry(
          recordId: 'r1',
          action: CalibrationAuditAction.created,
          at: DateTime(2026, 10, 1, 9, 30),
          summary: 'glucose-plasma-fasting · accepted',
        ),
      ],
      analyteName: (id) => id,
      now: DateTime(2026, 10, 25),
    );
    expect([for (final f in files) f.name], [
      'labguide-calibration-log-2026-10-25.csv',
      'labguide-calibration-audit-2026-10-25.csv',
    ]);
    expect(files.first.bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    final audit = utf8.decode(files.last.bytes.sublist(3));
    expect(audit, startsWith('at,record_id,action,summary\r\n'));
    expect(audit, contains('2026-10-01 09:30,r1,created,'));
  });

  test('QC xulosa: daraja × lot davrlari, n/x̄/SD (rad etilgansiz), bias, '
      'qoidalar va seriya xulosalari', () {
    final set = _set();
    final results = evaluateRuns(set, _runs());
    final report = buildQcReport(set, results);
    expect(report.results, hasLength(8));
    expect(report.verdicts.values.reduce((a, b) => a + b), 8);
    expect(report.verdicts[QcVerdict.reject], greaterThanOrEqualTo(1));
    expect(report.rules[QcRule.r13s], 1);
    expect(report.rules[QcRule.r12s], 2, reason: '1-2s ham 1-3s seriyasida');
    expect(report.rules[QcRule.r22s], 1);
    // L1: ikki lot davri (A-1, B-2); L2: bitta.
    final l1 = [
      for (final s in report.levels)
        if (s.level.id == 'L1') s,
    ];
    expect([for (final s in l1) s.target.lot], ['A-1', 'B-2']);
    final a = l1.first;
    expect(a.runs, 4);
    // Rad etilgan (5.7) statistikaga kirmaydi: 5.0, 5.5, 5.1.
    expect(a.stats.n, 3);
    expect(a.stats.mean, closeTo(5.2, 1e-9));
    expect(a.biasPercent, closeTo(4.0, 1e-9));
    expect(a.biasSd, closeTo(1.0, 1e-9));
    expect(a.rules[QcRule.r13s], 1);
    expect(a.verdicts[QcVerdict.reject], 1);
    final b = l1.last;
    expect(b.runs, 4);
    expect(b.stats.n, 4);
    expect(b.stats.mean, closeTo(5.25, 1e-9));
    expect(b.stats.cv, isNotNull);
    final l2 = report.levels.where((s) => s.level.id == 'L2').single;
    expect(l2.target.lot, 'C-3');
    expect(l2.stats.n, 7, reason: 'butun seriya rad etilgani hisobga olinmaydi');
    expect(report.from, DateTime(2026, 9, 1, 8));

    final rows = qcSummaryCsvRows(report);
    expect(rows.first.first, 'test');
    expect(rows, hasLength(1 + 3));
    final first = Map.fromIterables(rows.first, rows[1]);
    expect(first['lot'], 'A-1');
    expect(first['n_used'], '3');
    expect(first['observed_mean'], '5.200');
    expect(first['bias_percent'], '4.0');
    expect(first['rules'], contains('1-3s × 1'));
  });

  test('QC xulosa: seriyasiz to‘plam — bo‘sh hisobot', () {
    final report = buildQcReport(_set(), const []);
    expect(report.isEmpty, isTrue);
    expect(report.levels, isEmpty);
    expect(report.from, isNull);
  });
}
