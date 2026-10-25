import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/entitlements/feature.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/exam_question.dart';
import '../learn/exam_session.dart';
import '../learn/exam_widgets.dart';
import '../profile/pro_gate.dart';
import '../support/support_screens.dart' show formatWhen;
import '../toifa/toifa_bank.dart';
import 'learner_analytics.dart';
import 'pro_widgets.dart';

/// Imtihon simulyatsiyasi (Talaba Pro, D-78) — `/learn/simulation`.
///
/// Bepul imtihon rejimi va toifa testi O'ZGARMAYDI. Simulyatsiya — imtihon
/// sharoiti: vaqt va o'tish chegarasi majburiy, savollar barcha mavzulardan
/// muvozanatli tanlanadi, savollar ketma-ket (orqaga qaytish va belgilash
/// yo'q), har savolga sarflangan vaqt hisobotda. Natija oddiy tarixga ham
/// yoziladi (bepul ro'yxatda ko'rinadi, hech qachon yashirilmaydi).
class SimulationSetupScreen extends StatefulWidget {
  const SimulationSetupScreen({super.key});

  @override
  State<SimulationSetupScreen> createState() => _SimulationSetupScreenState();
}

class _SimulationSetupScreenState extends State<SimulationSetupScreen> {
  String _source = PackQuestionSource.sourceId;
  final _count = TextEditingController(text: '50');
  final _minutes = TextEditingController(text: '60');
  final _pass = TextEditingController(text: '70');
  bool _tried = false;

  @override
  void dispose() {
    _count.dispose();
    _minutes.dispose();
    _pass.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) => int.tryParse(c.text.trim());

  String? _countError(AppLocalizations l, int max) {
    final n = _parse(_count);
    return n == null || n < 1 || n > max ? l.examCountError(max) : null;
  }

  String? _minutesError(AppLocalizations l) {
    final n = _parse(_minutes);
    return n == null || n < 1 || n > 240 ? l.toifaTimeError : null;
  }

  String? _passError(AppLocalizations l) {
    final n = _parse(_pass);
    return n == null || n < 1 || n > 100 ? l.toifaPassError : null;
  }

  bool _toifaHere(BuildContext context) {
    final settings = context.services.settings;
    return toifaAvailable(
      settings.language,
      SchedulerBinding.instance.platformDispatcher.locales,
      role: settings.role,
      region: settings.attestationRegion,
    );
  }

  Future<void> _start(ExamQuestionSource source) async {
    final l = AppLocalizations.of(context);
    final pool = examPool(source, const {});
    setState(() => _tried = true);
    if (_countError(l, pool.length) != null ||
        _minutesError(l) != null ||
        _passError(l) != null) {
      return;
    }
    // Pullik amal — FAQAT boshlashdan oldin tekshiriladi (D-78); boshlangan
    // simulyatsiya obuna o'rtada tugasa ham oxirigacha ishlaydi.
    if (!await requireFeature(context, Feature.examSimulation)) return;
    if (!mounted) return;
    final exams = context.services.exams;
    if (exams.active != null) {
      final ok = await confirmDialog(
        context,
        title: l.examReplaceTitle,
        body: l.examReplaceBody,
        action: l.examStart,
      );
      if (!ok || !mounted) return;
    }
    final session = ExamSession.build(
      id: exams.newId(),
      mode: ExamMode.exam,
      questions: drawBalanced(pool, _parse(_count)!, exams.random),
      random: exams.random,
      startedAt: exams.now(),
      sourceId: source.id,
      limit: Duration(minutes: _parse(_minutes)!),
      passPercent: _parse(_pass),
      title: l.proSimTitle,
      shuffleOptions: source.id != ToifaQuestionSource.sourceId,
      simulation: true,
    );
    await exams.start(session);
    if (mounted) unawaited(context.push('/learn/exam/run'));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final exams = context.services.exams;
    final toifa = _toifaHere(context);
    if (!toifa) _source = PackQuestionSource.sourceId;
    return LgPage(
      title: l.proSimTitle,
      subtitle: l.proSimSubtitle,
      showProfile: false,
      children: [
        ProFeatureGate(
          feature: Feature.examSimulation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListenableBuilder(
                listenable: exams,
                builder: (context, _) => exams.active?.simulation ?? false
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LgButton(
                          key: const ValueKey('sim-resume'),
                          label: l.examResume,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => context.push('/learn/exam/run'),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              LgSectionTitle(l.proSimConditions),
              LgSteps([
                l.proSimRule1,
                l.proSimRule2,
                l.proSimRule3,
                l.proSimRule4,
              ]),
              if (toifa) ...[
                LgSectionTitle(l.proSimBank),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    LgChoiceChip(
                      key: const ValueKey('sim-bank-pack'),
                      label: l.proSimBankPack,
                      selected: _source == PackQuestionSource.sourceId,
                      onTap: () => setState(
                        () => _source = PackQuestionSource.sourceId,
                      ),
                    ),
                    LgChoiceChip(
                      key: const ValueKey('sim-bank-toifa'),
                      label: l.toifaTestTitle,
                      selected: _source == ToifaQuestionSource.sourceId,
                      onTap: () => setState(
                        () => _source = ToifaQuestionSource.sourceId,
                      ),
                    ),
                  ],
                ),
              ],
              ExamSourceGate(
                key: ValueKey('sim-source-$_source'),
                sourceId: _source,
                builder: _form,
              ),
            ],
          ),
        ),
        // Oldingi simulyatsiyalar — har doim ko'rinadi (ma'lumot; obunasiz
        // ham ochiladi va hech qachon o'chirilmaydi).
        ListenableBuilder(
          listenable: exams,
          builder: (context, _) => SimulationHistory(sessions: exams.history),
        ),
      ],
    );
  }

  Widget _form(BuildContext context, ExamQuestionSource source) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final max = examPool(source, const {}).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.examSettings),
        Text(l.proSimPool(max, source.topics.length), style: text.bodySmall),
        const SizedBox(height: 8),
        NumberPresetField(
          label: l.examCount,
          controller: _count,
          helper: l.examCountHint(max),
          errorText: _tried ? _countError(l, max) : null,
          presets: [
            for (final n in [25, 50, 100])
              if (n < max) ('$n', '$n'),
            (l.examCountAll(max), '$max'),
          ],
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 6),
        NumberPresetField(
          label: l.toifaTimeLabel,
          controller: _minutes,
          helper: l.proSimTimeHelper,
          errorText: _tried ? _minutesError(l) : null,
          presets: [
            for (final n in [30, 60, 90]) (l.examMinutes(n), '$n'),
          ],
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 6),
        NumberPresetField(
          label: l.toifaPassLabel,
          controller: _pass,
          helper: l.proSimPassHelper,
          errorText: _tried ? _passError(l) : null,
          presets: [
            for (final n in [60, 70, 80]) ('$n%', '$n'),
          ],
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        LgNotice(l.examPracticeNotice, kind: NoticeKind.info),
        const SizedBox(height: 12),
        LgButton(
          key: const ValueKey('sim-start'),
          label: l.proSimStart,
          icon: Icons.timer_outlined,
          onPressed: max == 0 ? null : () => _start(source),
        ),
      ],
    );
  }
}

/// Saqlangan simulyatsiyalar (eng yangisi birinchi).
class SimulationHistory extends StatelessWidget {
  const SimulationHistory({super.key, required this.sessions});

  final List<ExamSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sims = [
      for (final s in sessions)
        if (s.simulation) s,
    ];
    if (sims.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.proSimHistory),
        for (final (i, s) in sims.indexed)
          LgRow(
            key: ValueKey('sim-row-${s.id}'),
            title: formatWhen(s.finishedAt ?? s.startedAt, context),
            subtitle: '${s.correctCount}/${s.length} · '
                '${s.passed ?? false ? l.examPassMet(s.passPercent!) : l.examPassMissed(s.passPercent ?? 0)}',
            icon: Icons.timer_outlined,
            trailing: LgTag(
              '${s.percent}%',
              tone: (s.passed ?? false) ? LgTone.brand : LgTone.warning,
            ),
            divider: i < sims.length - 1,
            onTap: () => context.push('$simulationBase/result/${s.id}'),
          ),
      ],
    );
  }
}

/// Simulyatsiya hisoboti — `/learn/simulation/result/:id`. Saqlangan
/// ma'lumotni KO'RISH obunasiz ham ochiq (D-78: ma'lumot yashirilmaydi).
class SimulationReportScreen extends StatelessWidget {
  const SimulationReportScreen({super.key, required this.resultId});

  final String resultId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final exams = context.services.exams;
    return ListenableBuilder(
      listenable: exams,
      builder: (context, _) {
        final s = exams.historyEntry(resultId);
        if (s == null || !s.simulation) {
          return ExamStatePage(
            title: l.proSimReportTitle,
            state: LgStateView(
              kind: StateKind.empty,
              title: l.examResultMissing,
              actionLabel: l.proSimTitle,
              onAction: () => context.go(simulationBase),
            ),
          );
        }
        return ExamSourceGate(
          sourceId: s.sourceId,
          builder: (context, source) => _page(context, s, source),
        );
      },
    );
  }

  Widget _page(BuildContext context, ExamSession s, ExamQuestionSource source) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final pace = SimulationPace.of(s);
    final prev = previousSimulation(context.services.exams.history, s);
    final delta = prev == null ? null : s.percent - prev.percent;
    final passed = s.passed ?? false;
    final topics = {for (final t in source.topics) t.id: t};
    String topicOf(int i) => [
      for (final id in s.items[i].topicIds)
        if (topics[id] case final t?) t.name(l, lang),
    ].join(', ');
    return LgPage(
      title: l.proSimReportTitle,
      subtitle: formatWhen(s.finishedAt ?? s.startedAt, context),
      showProfile: false,
      children: [
        ScoreHero(
          key: const ValueKey('sim-report'),
          correct: s.correctCount,
          total: s.length,
          wrong: s.wrongCount,
          unanswered: s.unansweredCount,
          spent: pace.spent,
          limit: s.limit,
          badges: [
            LgTag(
              passed
                  ? l.examPassMet(s.passPercent ?? 0)
                  : l.examPassMissed(s.passPercent ?? 0),
              tone: passed ? LgTone.brand : LgTone.warning,
              icon: passed ? Icons.verified_rounded : Icons.flag_outlined,
            ),
            if (s.timedOut) LgTag(l.examTimedOut, tone: LgTone.warning),
          ],
          caption: delta == null
              ? null
              : delta > 0
              ? l.examDeltaUp(delta)
              : delta < 0
              ? l.examDeltaDown(-delta)
              : l.examDeltaSame,
        ),
        LgSectionTitle(l.proSimPace),
        LgPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgMetric(label: l.examSpent, value: formatClock(pace.spent)),
              if (s.limit case final limit?)
                LgMetric(label: l.toifaTimeLabel, value: formatClock(limit)),
              LgMetric(
                label: l.proSimAvgPerQuestion,
                value: formatClock(pace.average),
              ),
            ],
          ),
        ),
        if (pace.slowest.isNotEmpty) ...[
          LgSectionTitle(l.proSimSlowest),
          for (final (j, (i, d)) in pace.slowest.indexed)
            LgRow(
              key: ValueKey('sim-slow-$i'),
              title: '${l.examQuestionN(i + 1)} · ${formatClock(d)}',
              subtitle: [
                s.isCorrect(i)
                    ? l.examCorrectN
                    : (s.isAnswered(i) ? l.examWrongN : l.examSkippedN),
                if (topicOf(i) case final t when t.isNotEmpty) t,
              ].join(' · '),
              icon: s.isCorrect(i)
                  ? Icons.check_circle_outline_rounded
                  : Icons.highlight_off_rounded,
              divider: j < pace.slowest.length - 1,
            ),
        ],
        TopicBreakdown(session: s, source: source),
        const SizedBox(height: 12),
        LgButton.secondary(
          key: const ValueKey('sim-review'),
          label: l.proSimReview,
          icon: Icons.fact_check_outlined,
          onPressed: () => context.push('${examBase(s.sourceId)}/result/${s.id}'),
        ),
        const SizedBox(height: 8),
        Text(l.examPracticeNotice, style: text.bodySmall),
      ],
    );
  }
}
