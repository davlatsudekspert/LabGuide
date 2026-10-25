import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../core/backend/teacher_tests.dart';
import '../../core/entitlements/feature.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/exam_widgets.dart' show confirmDialog, showSnack;
import '../profile/pro_gate.dart';
import '../support/support_screens.dart' show formatWhen;
import 'teacher_assign_screens.dart' show ttStudentLabel;
import 'teacher_pro_common.dart';

// Ustoz Pro — natijalarni boshqarish (Feature.teacherResults): talaba va
// savol kesimidagi jamlanma o'z testlari bo'yicha. KO'RISH obunasiz ham
// ochiq (D-78 §7 — avval yaratilgan natijalar yashirilmaydi); CSV eksport —
// yangi pullik amal (gate + server `requireTier`).

String ttStateLabel(AppLocalizations l, TtState s) => switch (s) {
  TtState.assigned => l.ttStateAssigned,
  TtState.started => l.ttStateStarted,
  TtState.submitted => l.ttStateSubmitted,
  TtState.expired => l.ttStateExpired,
};

class TtResultsScreen extends StatefulWidget {
  const TtResultsScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  State<TtResultsScreen> createState() => _TtResultsScreenState();
}

class _TtResultsScreenState extends State<TtResultsScreen> {
  final _data = TtLoad<TtResults>();
  bool _started = false;
  bool _exporting = false;

  Future<void> _load(TeacherTestBackend api) async {
    if (_data.loading) return;
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final r = await api.teacherResults(widget.assignmentId);
      if (mounted) setState(() => _data.data = r);
    } on Object catch (e) {
      if (mounted) setState(() => _data.error = e);
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  Future<void> _export(TeacherTestBackend api) async {
    // CSV eksport — Ustoz Pro'ning yangi amali.
    if (!allowOrOffer(context, Feature.teacherResults)) return;
    final l = AppLocalizations.of(context);
    setState(() => _exporting = true);
    try {
      final e = await api.exportTeacherResults(widget.assignmentId);
      await Clipboard.setData(ClipboardData(text: e.csv));
      if (mounted) showSnack(context, l.ttExportCopied);
    } on Object catch (e) {
      if (mounted && !ttOfferIfPlanError(context, e, Feature.teacherResults)) {
        showSnack(context, ttErrorText(e, l));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _close(TeacherTestBackend api) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.ttCloseAssignment,
      body: l.ttCloseAssignmentBody,
      action: l.ttCloseAssignment,
    );
    if (!ok || !mounted) return;
    try {
      await api.closeTeacherAssignment(widget.assignmentId);
      if (mounted) await _load(api);
    } on Object catch (e) {
      if (mounted) showSnack(context, ttErrorText(e, l));
    }
  }

  Future<void> _delete(TeacherTestBackend api) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.ttDeleteAssignment,
      body: l.ttDeleteAssignmentBody,
      action: l.actionDelete,
    );
    if (!ok || !mounted) return;
    try {
      await api.deleteTeacherAssignment(widget.assignmentId);
      if (mounted) context.pop();
    } on Object catch (e) {
      if (mounted) showSnack(context, ttErrorText(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: _data.data?.assignment.title ?? l.ttResultsTitle,
      titleMaxLines: 3,
      subtitle: l.ttResultsTitle,
      children: [
        TeacherProGate(
          builder: (context, api) {
            if (!_started) {
              _started = true;
              WidgetsBinding.instance.addPostFrameCallback((_) => _load(api));
            }
            return ttLoadState(
              context,
              _data,
              () => _load(api),
              (r) => _body(context, l, api, r),
            );
          },
        ),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l,
    TeacherTestBackend api,
    TtResults r,
  ) {
    final text = Theme.of(context).textTheme;
    final a = r.assignment;
    String pct(int? v) => v == null ? '—' : '$v%';
    final byIndex = {for (final q in r.questions) q.index: q};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            LgTag(
              l.ttDueOn(formatWhen(a.dueAt, context)),
              tone: LgTone.neutral,
            ),
            if (a.closed) LgTag(l.ttClosed, tone: LgTone.warning),
            if (a.acceptLate) LgTag(l.ttLateAccepted, tone: LgTone.neutral),
          ],
        ),
        LgSectionTitle(l.ttSummaryTitle),
        LgMetric(label: l.ttSumTargets, value: '${r.targets}'),
        LgMetric(
          label: l.ttSumSubmitted,
          value: '${r.submitted}/${r.targets}',
        ),
        LgMetric(label: l.ttSumAverage, value: pct(r.averagePercent)),
        if (a.passPercent != null)
          LgMetric(label: l.ttSumPassRate, value: pct(r.passRate)),
        LgMetric(
          label: l.ttSumAvgTime,
          value: r.averageSeconds == null
              ? '—'
              : ttDuration(l, r.averageSeconds!),
        ),
        LgNotice(l.ttPrivacyTeacher, kind: NoticeKind.info),
        LgSectionTitle(l.ttStudentsTitle),
        if (r.students.isEmpty)
          Text(l.ttNoStudentsYet, style: text.bodyMedium)
        else
          for (final (i, s) in r.students.indexed)
            LgRow(
              key: ValueKey('tt-res-${s.userId}'),
              title: ttStudentLabel(
                context,
                a.groupId,
                s.userId,
                alias: s.alias,
                seatNo: s.seatNo,
              ),
              subtitle: [
                ttStateLabel(l, s.state),
                if (s.bestScore != null)
                  '${s.bestScore}/${s.total} (${pct(s.bestPercent)})',
                if (s.passed != null) s.passed! ? l.ttPassed : l.ttNotPassed,
                if (s.bestSeconds != null) ttDuration(l, s.bestSeconds!),
                if (s.attempts > 1) l.ttAttemptsN(s.attempts),
                if (s.late) l.ttLate,
              ].join(' · '),
              icon: s.state == TtState.submitted
                  ? Icons.task_alt_rounded
                  : Icons.person_outline_rounded,
              divider: i < r.students.length - 1,
            ),
        LgSectionTitle(l.ttMostMissed),
        if (r.mostMissed.isEmpty)
          Text(l.ttNoResultsYet, style: text.bodyMedium)
        else
          for (final i in r.mostMissed)
            if (byIndex[i] case final q?) _QuestionStat(stat: q),
        LgSectionTitle(l.ttQuestionsStatTitle),
        for (final q in r.questions) _QuestionStat(stat: q, compact: true),
        const SizedBox(height: 16),
        LgButton(
          key: const ValueKey('tt-export'),
          label: l.ttExportCsv,
          icon: Icons.table_view_rounded,
          busy: _exporting,
          onPressed: _exporting ? null : () => _export(api),
        ),
        const SizedBox(height: 10),
        if (!a.closed)
          LgButton.secondary(
            key: const ValueKey('tt-close'),
            label: l.ttCloseAssignment,
            icon: Icons.lock_clock_outlined,
            onPressed: () => _close(api),
          ),
        LgButton.link(
          key: const ValueKey('tt-delete-assignment'),
          label: l.ttDeleteAssignment,
          icon: Icons.delete_outline_rounded,
          onPressed: () => _delete(api),
        ),
      ],
    );
  }
}

class _QuestionStat extends StatelessWidget {
  const _QuestionStat({required this.stat, this.compact = false});

  final TtQuestionStat stat;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final pct = stat.correctPercent;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LgEyebrow(l.ttQuestionNumber(stat.index + 1)),
              LgTag(
                pct == null ? l.ttNoAnswersYet : l.ttCorrectPercent(pct),
                tone: pct != null && pct < 50 ? LgTone.warning : LgTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stat.text,
            style: text.bodyMedium,
            maxLines: compact ? 2 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),
          if (!compact)
            for (final (i, o) in stat.options.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      i == stat.correct
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: i == stat.correct ? p.brand : p.sub,
                      semanticLabel: i == stat.correct
                          ? l.ttCorrectAnswer
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(o, style: text.bodySmall)),
                    const SizedBox(width: 8),
                    Text(
                      '${i < stat.chosen.length ? stat.chosen[i] : 0}',
                      style: text.labelMedium,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
