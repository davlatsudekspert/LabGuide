import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/entitlements/feature.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../qc/qc_rules.dart';
import '../qc/qc_screens.dart' show qcLevelName;
import 'pro_widgets.dart';
import 'qc_report.dart';

/// QC xulosa hisoboti (Mutaxassis Pro, D-78) — `/lab/qc/set/:id/report`.
/// Faqat saqlangan seriyalardan; hech narsa o'zgartirmaydi va o'chirmaydi.
class QcReportScreen extends StatelessWidget {
  const QcReportScreen({super.key, required this.setId});

  final String setId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final qc = context.services.qc;
    final set = qc.data.set(setId);
    return LgPage(
      title: l.proQcReportTitle,
      subtitle: set?.name,
      showProfile: false,
      children: [
        ProFeatureGate(
          feature: Feature.qcReport,
          child: ListenableBuilder(
            listenable: qc,
            builder: (context, _) {
              final s = qc.data.set(setId);
              if (s == null) {
                return LgStateView(kind: StateKind.empty, title: l.qcSetMissing);
              }
              final report = buildQcReport(s, evaluateRuns(s, qc.data.runsOf(s.id)));
              return _ReportBody(report: report);
            },
          ),
        ),
      ],
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report});

  final QcReport report;

  Future<void> _export(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return runExport(
      context,
      feature: Feature.qcReport,
      pdf: () async => [
        await qcReportPdf(
          report,
          l: l,
          locale: locale,
          bundle: DefaultAssetBundle.of(context),
          now: DateTime.now(),
        ),
      ],
      csv: () async => qcCsvFiles(report, now: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMd(locale);
    String n(double? v, [int d = 3]) => qcNum(v, locale, digits: d);
    if (report.isEmpty) {
      return LgStateView(
        key: const ValueKey('qc-report-empty'),
        kind: StateKind.empty,
        title: l.proQcNoRuns,
      );
    }
    String rules(Map<QcRule, int> r) => r.isEmpty
        ? l.proQcNoRules
        : [
            for (final rule in QcRule.values)
              if (r[rule] case final c? when c > 0) '${rule.code} × $c',
          ].join(', ');
    return Column(
      key: const ValueKey('qc-report'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgNotice(l.proExportNotClinical, kind: NoticeKind.info),
        LgSectionTitle(l.proQcSummary),
        LgPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgMetric(
                label: l.proQcPeriodLabel,
                value: '${date.format(report.from!)} — ${date.format(report.to!)}',
              ),
              LgMetric(
                label: l.qcRunHistory,
                value: '${report.results.length}',
              ),
              LgMetric(
                label: l.qcAccept,
                value: '${report.verdicts[QcVerdict.accept]}',
              ),
              LgMetric(
                label: l.qcWarning,
                value: '${report.verdicts[QcVerdict.warning]}',
              ),
              LgMetric(
                label: l.qcReject,
                value: '${report.verdicts[QcVerdict.reject]}',
              ),
              LgMetric(label: l.proQcRulesFired, value: rules(report.rules)),
            ],
          ),
        ),
        LgSectionTitle(l.proQcByLevel),
        for (final s in report.levels)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LgPanel(
              key: ValueKey('qc-report-level-${s.level.id}-${s.target.lot}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(qcLevelName(s.level.label, l), style: text.titleMedium),
                      if (s.target.lot.isNotEmpty)
                        LgTag('${l.qcLot} ${s.target.lot}', tone: LgTone.neutral),
                    ],
                  ),
                  Text(
                    '${date.format(s.first)} — ${date.format(s.last)}',
                    style: text.bodySmall,
                  ),
                  LgMetric(
                    label: l.proQcColTarget,
                    value: '${n(s.target.mean)} ± ${n(s.target.sd)} ${report.set.unit}',
                  ),
                  LgMetric(
                    label: l.proQcColObserved,
                    value: s.stats.n == 0
                        ? '—'
                        : 'n = ${s.stats.n} · ${n(s.stats.mean)} ± ${n(s.stats.sd)}',
                  ),
                  LgMetric(label: 'CV', value: s.stats.cv == null ? '—' : '${n(s.stats.cv, 1)} %'),
                  LgMetric(
                    label: l.proQcColBias,
                    value: s.biasPercent == null
                        ? '—'
                        : '${n(s.biasPercent, 1)} % · ${n(s.biasSd, 2)} SD',
                  ),
                  LgMetric(
                    label: l.proQcVerdictsLabel,
                    value:
                        '${s.verdicts[QcVerdict.accept]} / ${s.verdicts[QcVerdict.warning]} / '
                        '${s.verdicts[QcVerdict.reject]}',
                  ),
                  LgMetric(label: l.proQcRulesFired, value: rules(s.rules)),
                ],
              ),
            ),
          ),
        Text(l.qcStatsExcluded, style: text.bodySmall),
        const SizedBox(height: 6),
        Text(l.proQcVerdictsHint, style: text.bodySmall),
        const SizedBox(height: 14),
        ExportButton(onPressed: () => _export(context)),
        const SizedBox(height: 8),
        Text(l.qcRulesSource, style: text.bodySmall),
      ],
    );
  }
}
