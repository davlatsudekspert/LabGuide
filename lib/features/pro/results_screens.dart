import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/entitlements/feature.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/exam_question.dart';
import '../learn/exam_session.dart';
import '../learn/exam_widgets.dart';
import '../support/support_screens.dart' show formatWhen;
import '../toifa/toifa_bank.dart';
import 'learner_analytics.dart';
import 'pro_widgets.dart';
import 'results_export.dart';

/// Natijalar tahlili (Talaba Pro, D-78) — `/learn/results`.
///
/// Bepul "Natijalar tarixi" (har bank ostida) O'ZGARMAYDI. Bu ekran —
/// kengaytirilgan ko'rinish: barcha banklar bo'yicha to'liq tarix, umumiy
/// trend, mavzular bo'yicha aniqlik va o'zgarish, zaif mavzular, eksport.
/// Faqat qurilmadagi tarixdan; hech narsa o'chirilmaydi.
class ResultsAnalyticsScreen extends StatefulWidget {
  const ResultsAnalyticsScreen({super.key});

  @override
  State<ResultsAnalyticsScreen> createState() => _ResultsAnalyticsScreenState();
}

class _ResultsAnalyticsScreenState extends State<ResultsAnalyticsScreen> {
  /// `null` — barcha banklar.
  String? _bank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final exams = context.services.exams;
    return LgPage(
      title: l.proResultsTitle,
      subtitle: l.proResultsSubtitle,
      showProfile: false,
      children: [
        ProFeatureGate(
          feature: Feature.resultsAnalytics,
          child: ListenableBuilder(
            listenable: exams,
            builder: (context, _) {
              final all = exams.history;
              if (all.isEmpty) {
                return LgStateView(
                  key: const ValueKey('results-empty'),
                  kind: StateKind.empty,
                  title: l.proResultsEmpty,
                  actionLabel: l.examNew,
                  onAction: () => context.go('/learn/exam'),
                );
              }
              // Mavzu nomlari uchun banklar yuklanadi (paket; toifa bo'lsa — u ham).
              final needsToifa = all.any(
                (s) => s.sourceId == ToifaQuestionSource.sourceId,
              );
              Widget body(BuildContext context) => _Body(
                sessions: all,
                bank: _bank,
                onBank: (b) => setState(() => _bank = b),
              );
              return ExamSourceGate(
                sourceId: PackQuestionSource.sourceId,
                builder: (context, _) => needsToifa
                    ? ToifaBankGate(builder: (context, _) => body(context))
                    : body(context),
              );
            },
          ),
        ),
      ],
    );
  }
}

String bankLabel(AppLocalizations l, String sourceId) => switch (sourceId) {
  PackQuestionSource.sourceId => l.proSimBankPack,
  ToifaQuestionSource.sourceId => l.toifaTestTitle,
  _ => l.proResultsBankOther,
};

class _Body extends StatelessWidget {
  const _Body({required this.sessions, required this.bank, required this.onBank});

  final List<ExamSession> sessions;
  final String? bank;
  final ValueChanged<String?> onBank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final banks = {for (final s in sessions) s.sourceId}.toList();
    final shown = bank == null || !banks.contains(bank)
        ? sessions
        : [
            for (final s in sessions)
              if (s.sourceId == bank) s,
          ];
    final a = ResultsAnalytics(shown);
    final trend = a.trend();
    final topics = a.topics();
    final weak = a.weakTopics();
    String topicName(String sourceId, String topicId) {
      final source = examSourceOf(context, sourceId);
      for (final t in source?.topics ?? const <ExamTopic>[]) {
        if (t.id == topicId) return t.name(l, lang);
      }
      return topicId;
    }

    String title(ExamSession s) =>
        examSessionTitle(s, examSourceOf(context, s.sourceId), l, lang);

    Future<void> export() {
      final locale = Localizations.localeOf(context).toLanguageTag();
      final bundle = DefaultAssetBundle.of(context);
      return runExport(
        context,
        feature: Feature.resultsExport,
        pdf: () async => [
          await resultsPdf(
            a,
            l: l,
            locale: locale,
            bundle: bundle,
            title: title,
            topicName: topicName,
            now: DateTime.now(),
          ),
        ],
        csv: () async => resultsCsvFiles(
          a,
          title: title,
          topicName: topicName,
          now: DateTime.now(),
        ),
      );
    }

    return Column(
      key: const ValueKey('results-analytics'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (banks.length > 1) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LgChoiceChip(
                key: const ValueKey('results-bank-all'),
                label: l.examAllTopics,
                selected: bank == null,
                onTap: () => onBank(null),
              ),
              for (final b in banks)
                LgChoiceChip(
                  key: ValueKey('results-bank-$b'),
                  label: bankLabel(l, b),
                  selected: bank == b,
                  onTap: () => onBank(b),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        LgPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgMetric(label: l.proResultsSessions, value: '${shown.length}'),
              LgMetric(label: l.proResultsAverage, value: '${a.average}%'),
              LgMetric(label: l.proResultsBest, value: '${a.best}%'),
              LgMetric(label: l.proResultsLast, value: '${a.last}%'),
              if (trend != null)
                LgMetric(
                  label: l.proResultsTrend,
                  value: l.proPoints(signedInt(trend)),
                ),
              LgMetric(
                label: l.proResultsAnswered,
                value: '${a.totalCorrect} / ${a.totalQuestions}',
              ),
            ],
          ),
        ),
        LgSectionTitle(l.proResultsChart),
        _TrendBars(sessions: shown.take(20).toList().reversed.toList()),
        const SizedBox(height: 4),
        Text(l.examProgressOld, style: text.bodySmall),
        LgSectionTitle(l.proResultsWeak),
        if (weak.isEmpty)
          Text(l.proResultsNoWeak, style: text.bodyMedium)
        else
          for (final (i, t) in weak.indexed)
            LgRow(
              key: ValueKey('results-weak-${t.topicId}'),
              title: topicName(t.sourceId, t.topicId),
              subtitle: l.proResultsTopicRow(t.correct, t.total, t.sessions),
              icon: Icons.priority_high_rounded,
              trailing: LgTag('${t.percent}%', tone: LgTone.warning),
              divider: i < weak.length - 1,
              onTap: () => context.push(examBase(t.sourceId)),
            ),
        const SizedBox(height: 4),
        Text(l.proResultsWeakRule, style: text.bodySmall),
        LgSectionTitle(l.proResultsTopics),
        if (topics.isEmpty)
          Text(l.proResultsNoTopics, style: text.bodyMedium)
        else
          for (final (i, t) in topics.indexed)
            LgRow(
              key: ValueKey('results-topic-${t.sourceId}-${t.topicId}'),
              title: topicName(t.sourceId, t.topicId),
              subtitle: [
                l.proResultsTopicRow(t.correct, t.total, t.sessions),
                if (t.delta case final d?)
                  '${l.proResultsTrend}: ${l.proPoints(signedInt(d))}',
              ].join(' · '),
              icon: t.delta == null
                  ? Icons.remove_rounded
                  : t.delta! > 0
                  ? Icons.trending_up_rounded
                  : t.delta! < 0
                  ? Icons.trending_down_rounded
                  : Icons.trending_flat_rounded,
              trailing: LgTag(
                '${t.percent}%',
                tone: t.percent >= 60 ? LgTone.brand : LgTone.warning,
              ),
              divider: i < topics.length - 1,
            ),
        LgSectionTitle(l.proResultsHistory),
        for (final (i, s) in shown.indexed)
          LgRow(
            key: ValueKey('results-row-${s.id}'),
            title: title(s),
            subtitle: [
              formatWhen(s.finishedAt ?? s.startedAt, context),
              '${s.correctCount}/${s.length}',
              bankLabel(l, s.sourceId),
              if (s.simulation) l.proSimTag,
            ].join(' · '),
            icon: s.simulation
                ? Icons.timer_outlined
                : (s.mode == ExamMode.rework
                      ? Icons.replay_rounded
                      : Icons.assignment_outlined),
            trailing: LgTag(
              '${s.percent}%',
              tone: (s.passed ?? s.percent >= 50) ? LgTone.brand : LgTone.warning,
            ),
            divider: i < shown.length - 1,
            onTap: () => context.push(
              s.simulation
                  ? '$simulationBase/result/${s.id}'
                  : '${examBase(s.sourceId)}/result/${s.id}',
            ),
          ),
        const SizedBox(height: 14),
        ExportButton(onPressed: export),
        const SizedBox(height: 8),
        Text(l.examPracticeNotice, style: text.bodySmall),
      ],
    );
  }
}

/// So'nggi natijalar ustunchalari (eskidan yangiga); aniq qiymatlar —
/// pastdagi ro'yxatda.
class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.sessions});

  final List<ExamSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    const height = 72.0;
    return Semantics(
      label: l.examProgressLabel(sessions.map((s) => '${s.percent}%').join(', ')),
      child: ExcludeSemantics(
        child: LgPanel(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, s) in sessions.indexed) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 4 + (height - 4) * s.percent / 100,
                      decoration: BoxDecoration(
                        color: s.simulation
                            ? p.brand
                            : p.brand.withValues(alpha: 0.4),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
                for (var i = sessions.length; i < 20; i++) ...[
                  const SizedBox(width: 4),
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
