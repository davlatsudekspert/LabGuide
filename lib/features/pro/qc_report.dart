/// Mutaxassis Pro (D-78): QC xulosa hisoboti — FAQAT saqlangan seriyalardan
/// (`evaluateRuns`, Westgard qoidalari bepul QC ekranidagi bilan bir xil).
/// Har daraja va maqsad davri (lot, x̄, SD) bo'yicha: seriyalar soni,
/// kuzatilgan n / x̄ / SD / CV (rad etilgan seriyalarsiz — bepul ekrandagi
/// statistika bilan bir xil qoida), maqsaddan farq (bias, %), ishlagan
/// qoidalar. Hisobot klinik qaror emas va laboratoriyaning QC tartibini
/// almashtirmaydi.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:intl/intl.dart';

import '../../core/export/csv.dart';
import '../../core/export/pdf_report.dart';
import '../../l10n/gen/app_localizations.dart';
import '../qc/qc_export.dart';
import '../qc/qc_model.dart';
import '../qc/qc_rules.dart';
import '../qc/qc_screens.dart' show qcLevelName, verdictLabel;
import '../share/file_export.dart';

/// Bitta daraja × maqsad davri xulosasi.
@immutable
class QcLevelSummary {
  const QcLevelSummary({
    required this.level,
    required this.target,
    required this.runs,
    required this.stats,
    required this.verdicts,
    required this.rules,
    required this.first,
    required this.last,
  });

  final QcLevel level;

  /// Shu davrda amal qilgan maqsad (lot, x̄, SD).
  final QcTarget target;

  /// Shu darajada qiymati bor seriyalar soni (rad etilganlar bilan).
  final int runs;

  /// Kuzatilgan statistika — rad etilgan seriyalarsiz.
  final QcStats stats;

  /// Daraja nuqtai nazaridan xulosalar soni.
  final Map<QcVerdict, int> verdicts;

  /// Shu darajani o'z ichiga olgan buzilishlar (qoida → seriyalar soni).
  final Map<QcRule, int> rules;
  final DateTime first;
  final DateTime last;

  /// Maqsaddan farq, %: (x̄ kuzatilgan − x̄ maqsad) / x̄ maqsad × 100.
  double? get biasPercent {
    final m = stats.mean;
    if (m == null || target.mean == 0) return null;
    return (m - target.mean) / target.mean.abs() * 100;
  }

  /// Kuzatilgan x̄ ning maqsaddan farqi SD birligida.
  double? get biasSd {
    final m = stats.mean;
    if (m == null || target.sd <= 0) return null;
    return (m - target.mean) / target.sd;
  }
}

/// Butun to'plam xulosasi.
@immutable
class QcReport {
  const QcReport({
    required this.set,
    required this.results,
    required this.levels,
    required this.verdicts,
    required this.rules,
  });

  final QcSet set;
  final List<QcRunResult> results;
  final List<QcLevelSummary> levels;

  /// Seriya xulosalari soni.
  final Map<QcVerdict, int> verdicts;

  /// Qoida → u ishlagan seriyalar soni.
  final Map<QcRule, int> rules;

  bool get isEmpty => results.isEmpty;
  DateTime? get from => results.isEmpty ? null : results.first.run.at;
  DateTime? get to => results.isEmpty ? null : results.last.run.at;
}

bool _sameTarget(QcTarget a, QcTarget b) =>
    a.lot == b.lot && a.mean == b.mean && a.sd == b.sd;

/// [results] — `evaluateRuns(set, runs)` (vaqt tartibida).
QcReport buildQcReport(QcSet set, List<QcRunResult> results) {
  final verdicts = {for (final v in QcVerdict.values) v: 0};
  final rules = <QcRule, int>{};
  for (final r in results) {
    verdicts[r.verdict] = verdicts[r.verdict]! + 1;
    for (final rule in r.rules) {
      rules[rule] = (rules[rule] ?? 0) + 1;
    }
  }
  final levels = <QcLevelSummary>[];
  for (final level in set.levels) {
    // Maqsad davrlari bo'yicha guruhlash (vaqt tartibida).
    final groups = <(QcTarget, List<QcRunResult>)>[];
    for (final r in results) {
      if (!r.run.values.containsKey(level.id)) continue;
      final t = level.targetAt(r.run.at);
      if (groups.isEmpty || !_sameTarget(groups.last.$1, t)) {
        groups.add((t, [r]));
      } else {
        groups.last.$2.add(r);
      }
    }
    for (final (target, rs) in groups) {
      final lv = {for (final v in QcVerdict.values) v: 0};
      final lr = <QcRule, int>{};
      for (final r in rs) {
        final v = r.levelVerdict(level.id);
        lv[v] = lv[v]! + 1;
        for (final x in r.violations) {
          if (x.levelIds.contains(level.id)) {
            lr[x.rule] = (lr[x.rule] ?? 0) + 1;
          }
        }
      }
      levels.add(
        QcLevelSummary(
          level: level,
          target: target,
          runs: rs.length,
          stats: QcStats.of([
            for (final r in rs)
              if (r.verdict != QcVerdict.reject) r.run.values[level.id]!,
          ]),
          verdicts: lv,
          rules: lr,
          first: rs.first.run.at,
          last: rs.last.run.at,
        ),
      );
    }
  }
  return QcReport(
    set: set,
    results: results,
    levels: levels,
    verdicts: verdicts,
    rules: rules,
  );
}

String _rulesText(Map<QcRule, int> rules) => [
  for (final r in QcRule.values)
    if (rules[r] case final n? when n > 0) '${r.code} × $n',
].join(', ');

/// Xulosa CSV si (har daraja × maqsad davri — bitta qator).
List<List<String>> qcSummaryCsvRows(QcReport report) => [
  [
    'test',
    'unit',
    'level',
    'lot',
    'target_mean',
    'target_sd',
    'from',
    'to',
    'runs',
    'n_used',
    'observed_mean',
    'observed_sd',
    'cv_percent',
    'bias_percent',
    'bias_sd',
    'accept',
    'warning',
    'reject',
    'rules',
  ],
  for (final s in report.levels)
    [
      csvText(report.set.name),
      csvText(report.set.unit),
      csvText(s.level.label),
      csvText(s.target.lot),
      '${s.target.mean}',
      '${s.target.sd}',
      csvDateTime(s.first),
      csvDateTime(s.last),
      '${s.runs}',
      '${s.stats.n}',
      csvNum(s.stats.mean, 3),
      csvNum(s.stats.sd, 3),
      csvNum(s.stats.cv, 1),
      csvNum(s.biasPercent, 1),
      csvNum(s.biasSd, 2),
      '${s.verdicts[QcVerdict.accept]}',
      '${s.verdicts[QcVerdict.warning]}',
      '${s.verdicts[QcVerdict.reject]}',
      _rulesText(s.rules),
    ],
];

String _stamp(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

/// CSV: xulosa + barcha seriyalar (bepul `qcCsv` bilan bir xil ustunlar).
List<ExportFile> qcCsvFiles(QcReport report, {required DateTime now}) {
  final stem = safeFileStem(report.set.name);
  return [
    ExportFile(
      name: 'labguide-qc-$stem-summary-${_stamp(now)}.csv',
      mimeType: ExportFile.csv,
      bytes: csvBytes(qcSummaryCsvRows(report)),
    ),
    ExportFile(
      name: 'labguide-qc-$stem-runs-${_stamp(now)}.csv',
      mimeType: ExportFile.csv,
      // Bepul ekrandagi CSV nusxasi bilan aynan bir xil mazmun (BOM bilan).
      bytes: Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode(qcCsv(report.set, report.results)),
      ]),
    ),
  ];
}

/// Sonni hisobot uchun: 3 xonagacha, ortiqcha nolsiz.
String qcNum(double? v, String locale, {int digits = 3}) {
  if (v == null || !v.isFinite) return '—';
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: digits,
  ).format(v).replaceFirst(RegExp(r'([.,]\d*?)0+$'), r'$1').replaceFirst(
    RegExp(r'[.,]$'),
    '',
  );
}

/// PDF hisobot.
Future<ExportFile> qcReportPdf(
  QcReport report, {
  required AppLocalizations l,
  required String locale,
  required AssetBundle bundle,
  required DateTime now,
}) async {
  final (regular, bold) = await PdfFonts.load(bundle);
  final date = DateFormat.yMd(locale);
  final stamp = DateFormat.yMd(locale).add_Hm();
  final set = report.set;
  String n(double? v, [int d = 3]) => qcNum(v, locale, digits: d);
  final b = PdfReportBuilder(
    regular: regular,
    bold: bold,
    title: '${l.proQcReportTitle} · ${set.name}',
    footerNote: 'LabGuide · ${l.proExportNotClinical}',
    pageLabel: (p, t) => l.proExportPage(p, t),
  )
    ..heading1(l.proQcReportTitle)
    ..keyValues([
      (l.qcSetName, set.name),
      (l.qcUnit, set.unit),
      if (report.from case final f?)
        (l.proQcPeriodLabel, '${date.format(f)} — ${date.format(report.to!)}'),
      (l.qcRunHistory, '${report.results.length}'),
      (
        l.proQcVerdictsLabel,
        '${l.qcAccept}: ${report.verdicts[QcVerdict.accept]} · '
            '${l.qcWarning}: ${report.verdicts[QcVerdict.warning]} · '
            '${l.qcReject}: ${report.verdicts[QcVerdict.reject]}',
      ),
      (l.proQcRulesFired, report.rules.isEmpty ? l.proQcNoRules : _rulesText(report.rules)),
    ])
    ..text(l.proExportCreated(stamp.format(now)), color: PdfColor.grey)
    ..gap(2)
    ..text(l.proExportNotClinical, size: 8.5, color: PdfColor.grey)
    ..heading2(l.proQcByLevel)
    ..table(
      [
        l.proQcColLevel,
        l.qcLot,
        l.proQcColTarget,
        l.proQcColObserved,
        'CV %',
        l.proQcColBias,
        l.proQcRulesFired,
      ],
      [
        for (final s in report.levels)
          [
            qcLevelName(s.level.label, l),
            s.target.lot.isEmpty ? '—' : s.target.lot,
            '${n(s.target.mean)} ± ${n(s.target.sd)}',
            s.stats.n == 0
                ? '—'
                : 'n=${s.stats.n} · ${n(s.stats.mean)} ± ${n(s.stats.sd)}',
            n(s.stats.cv, 1),
            s.biasPercent == null
                ? '—'
                : '${n(s.biasPercent, 1)} % (${n(s.biasSd, 2)} SD)',
            s.rules.isEmpty ? '—' : _rulesText(s.rules),
          ],
      ],
      widths: const [1.1, 1, 1.4, 1.8, 0.7, 1.4, 1.4],
    )
    ..text(l.qcStatsExcluded, size: 8, color: PdfColor.grey)
    ..heading2(l.qcRunHistory)
    ..table(
      [
        l.proColDate,
        for (final lv in set.levels) '${qcLevelName(lv.label, l)} (z)',
        l.proColStatus,
        l.proQcRulesFired,
      ],
      [
        for (final r in report.results)
          [
            stamp.format(r.run.at),
            for (final lv in set.levels)
              if (r.run.values[lv.id] case final v?)
                '${n(v)}${r.z[lv.id] == null ? '' : ' (${n(r.z[lv.id], 2)})'}'
              else
                '—',
            verdictLabel(r.verdict, l),
            r.rules.isEmpty ? '—' : [for (final x in r.rules) x.code].join(', '),
          ],
      ],
    )
    ..text(l.qcRulesSource, size: 8, color: PdfColor.grey);
  return ExportFile(
    name: 'labguide-qc-${safeFileStem(set.name)}-${_stamp(now)}.pdf',
    mimeType: ExportFile.pdf,
    bytes: b.build(created: now),
  );
}
