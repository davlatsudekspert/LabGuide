import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../support/support_screens.dart' show formatWhen;
import '../toifa/toifa_bank.dart';
import 'exam_controller.dart';
import 'exam_question.dart';
import 'exam_session.dart';
import 'exam_widgets.dart';

/// Imtihon rejimi: mavzu, savollar soni va vaqtni tanlash, davom etayotgan
/// imtihon va natijalar tarixi. Internetsiz va mehmon rejimida ishlaydi.
class ExamSetupScreen extends StatefulWidget {
  const ExamSetupScreen({
    super.key,
    this.sourceId = PackQuestionSource.sourceId,
  });

  /// Savollar banki (sukut — kontent paketi).
  final String sourceId;

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends State<ExamSetupScreen> {
  Set<String> _topics = {};
  final _count = TextEditingController(text: '20');
  final _minutes = TextEditingController(text: '20');
  bool _tried = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _settle());
  }

  @override
  void dispose() {
    _count.dispose();
    _minutes.dispose();
    super.dispose();
  }

  /// Ilova yopiq paytda vaqti tugagan imtihon — halol yakunlanadi.
  Future<void> _settle() async {
    if (!mounted) return;
    final services = context.services;
    final done = await services.exams.settleExpired();
    if (done == null || !mounted) return;
    await recordExamProgress(services, done);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l.examSettled),
          action: SnackBarAction(
            label: l.examOpenResult,
            onPressed: () =>
                context.push('${examBase(done.sourceId)}/result/${done.id}'),
          ),
        ),
      );
  }

  int? _parse(TextEditingController c) => int.tryParse(c.text.trim());

  String? _countError(int max) {
    final n = _parse(_count);
    return n == null || n < 1 || n > max ? l10n.examCountError(max) : null;
  }

  String? _minutesError() {
    final n = _parse(_minutes);
    return n == null || n < 1 || n > 180 ? l10n.examTimeError : null;
  }

  AppLocalizations get l10n => AppLocalizations.of(context);

  Future<void> _start(ExamQuestionSource source) async {
    final pool = examPool(source, _topics);
    setState(() => _tried = true);
    if (pool.isEmpty || _countError(pool.length) != null) return;
    if (_minutesError() != null) return;
    final exams = context.services.exams;
    if (exams.active != null) {
      final ok = await confirmDialog(
        context,
        title: l10n.examReplaceTitle,
        body: l10n.examReplaceBody,
        action: l10n.examStart,
      );
      if (!ok || !mounted) return;
    }
    final session = ExamSession.build(
      id: exams.newId(),
      mode: ExamMode.exam,
      questions: drawQuestions(pool, _parse(_count)!, exams.random),
      random: exams.random,
      startedAt: exams.now(),
      sourceId: source.id,
      limit: Duration(minutes: _parse(_minutes)!),
      topicIds: _topics.toList()..sort(),
    );
    await exams.start(session);
    if (mounted) await context.push('/learn/exam/run');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final exams = context.services.exams;
    return LgPage(
      title: l.examTitle,
      subtitle: l.examSubtitle,
      children: [
        ListenableBuilder(
          listenable: exams,
          builder: (context, _) => exams.active == null
              ? const SizedBox.shrink()
              : ActiveExamCard(session: exams.active!),
        ),
        // Hozircha — kontent paketi savollari; boshqa bank (masalan, toifa
        // imtihoni) shu ekranga manba sifatida beriladi.
        ExamSourceGate(sourceId: widget.sourceId, builder: _setup),
        ListenableBuilder(
          listenable: exams,
          builder: (context, _) =>
              ExamHistory(exams: exams, sourceId: widget.sourceId),
        ),
      ],
    );
  }

  Widget _setup(BuildContext context, ExamQuestionSource source) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final pool = examPool(source, _topics);
    final max = pool.length;
    final drafts = pool.any((q) => q.isDraft);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.examTopics),
        TopicChips(
          source: source,
          selected: _topics,
          onChanged: (t) => setState(() => _topics = t),
        ),
        const SizedBox(height: 10),
        Text(l.examPoolCount(max), style: text.bodySmall),
        LgSectionTitle(l.examSettings),
        NumberPresetField(
          label: l.examCount,
          controller: _count,
          hint: '20',
          helper: l.examCountHint(max),
          errorText: _tried ? _countError(max) : null,
          presets: [
            for (final n in [10, 20, 30])
              if (n < max) ('$n', '$n'),
            (l.examCountAll(max), '$max'),
          ],
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 6),
        NumberPresetField(
          label: l.examTime,
          controller: _minutes,
          hint: '20',
          helper: l.examTimeHint,
          errorText: _tried ? _minutesError() : null,
          presets: [
            for (final n in [10, 20, 30, 45]) (l.examMinutes(n), '$n'),
          ],
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 14),
        if (drafts) LgNotice(l.examDraftNotice),
        LgNotice(l.examRulesNotice, kind: NoticeKind.info),
        const SizedBox(height: 12),
        LgButton(
          label: l.examStart,
          icon: Icons.play_arrow_rounded,
          onPressed: max == 0 ? null : () => _start(source),
        ),
      ],
    );
  }
}

/// Davom etayotgan imtihon: qaysi bankdan bo'lsa, o'sha bo'limda ochiladi.
class ActiveExamCard extends StatelessWidget {
  const ActiveExamCard({super.key, required this.session});

  final ExamSession session;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final exams = context.services.exams;
    final lang = Localizations.localeOf(context).languageCode;
    final left = session.remaining(exams.now());
    return LgPanel(
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgEyebrow(l.examActiveTitle),
          Text(
            examSessionTitle(
              session,
              examSourceOf(context, session.sourceId),
              l,
              lang,
            ),
            style: text.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            left == null
                ? l.examAnsweredOf(session.answeredCount, session.length)
                : l.examActiveBody(
                    session.answeredCount,
                    session.length,
                    formatClock(left),
                  ),
            style: text.bodyMedium,
          ),
          const SizedBox(height: 14),
          LgButton(
            label: l.examResume,
            icon: Icons.play_arrow_rounded,
            onPressed: () => context.push('${examBase(session.sourceId)}/run'),
          ),
          const SizedBox(height: 4),
          LgButton.link(
            label: l.examDiscard,
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: l.examDiscardTitle,
                body: l.examDiscardBody,
                action: l.examDiscardAction,
              );
              if (ok) await exams.discardActive();
            },
          ),
        ],
      ),
    );
  }
}

/// Natijalar tarixi — faqat shu bankdagi imtihonlar.
class ExamHistory extends StatelessWidget {
  const ExamHistory({super.key, required this.exams, required this.sourceId});

  final ExamController exams;
  final String sourceId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final all = [
      for (final s in exams.history)
        if (s.sourceId == sourceId) s,
    ];
    // Toifa: cheklanmagan tarix — keyin Pro bo'lishi mumkin (hozir ochiq).
    final history =
        sourceId == ToifaQuestionSource.sourceId &&
            !toifaAllows(ToifaFeature.unlimitedHistory)
        ? all.take(ToifaFreeProposal.historySize).toList()
        : all;
    final recent = history.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.examHistory),
        if (history.isEmpty)
          Text(l.examHistoryEmpty, style: text.bodyMedium)
        else ...[
          _ProgressStrip(sessions: recent.reversed.toList()),
          const SizedBox(height: 8),
          Text(
            l.examHistoryStats(
              recent.length,
              (recent.map((s) => s.percent).reduce((a, b) => a + b) /
                      recent.length)
                  .round(),
              recent.map((s) => s.percent).reduce((a, b) => a > b ? a : b),
            ),
            style: text.bodySmall,
          ),
          const SizedBox(height: 6),
          for (final (i, s) in history.indexed)
            LgRow(
              title: examSessionTitle(
                s,
                examSourceOf(context, s.sourceId),
                l,
                lang,
              ),
              subtitle: l.examHistoryRow(
                formatWhen(s.finishedAt ?? s.startedAt, context),
                s.correctCount,
                s.length,
                formatClock(s.spent(exams.now())),
              ),
              icon: s.mode == ExamMode.rework
                  ? Icons.replay_rounded
                  : Icons.timer_outlined,
              trailing: LgTag(
                '${s.percent}%',
                tone: (s.passed ?? s.percent >= 50)
                    ? LgTone.brand
                    : LgTone.warning,
              ),
              divider: i < history.length - 1,
              onTap: () =>
                  context.push('${examBase(s.sourceId)}/result/${s.id}'),
            ),
          const SizedBox(height: 8),
          LgButton.link(
            label: l.examHistoryClear,
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: l.examHistoryClear,
                body: l.examHistoryClearBody,
                action: l.actionDelete,
              );
              if (ok) await exams.clearHistory(sourceId: sourceId);
            },
          ),
        ],
      ],
    );
  }
}

/// So'nggi natijalar (eskidan yangiga): bitta rang, oxirgisi ajratilgan.
/// Aniq qiymatlar pastdagi ro'yxatda (jadval o'rnida).
class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.sessions});

  final List<ExamSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    const height = 64.0;
    return Semantics(
      label: l.examProgressLabel(
        sessions.map((s) => '${s.percent}%').join(', '),
      ),
      child: ExcludeSemantics(
        child: LgPanel(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            children: [
              SizedBox(
                height: height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, s) in sessions.indexed) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 4 + (height - 4) * s.percent / 100,
                          decoration: BoxDecoration(
                            color: i == sessions.length - 1
                                ? p.brand
                                : p.brand.withValues(alpha: 0.35),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                    for (var i = sessions.length; i < 10; i++) ...[
                      const SizedBox(width: 6),
                      const Expanded(child: SizedBox()),
                    ],
                  ],
                ),
              ),
              Container(height: 1, color: p.line),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(l.examProgressOld, style: text.bodySmall),
                  ),
                  Text(
                    '${l.examProgressLast}: ${sessions.last.percent}%',
                    style: text.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Imtihonni yechish (to'liq ekran). Sahifa yopilsa ham imtihon saqlanadi
/// va vaqt davom etadi — “Imtihon rejimi” ekranidan qaytiladi.
class ExamRunScreen extends StatefulWidget {
  const ExamRunScreen({super.key, this.base = '/learn/exam'});

  /// Faol imtihon bo'lmasa — shu bo'limga qaytiladi.
  final String base;

  @override
  State<ExamRunScreen> createState() => _ExamRunScreenState();
}

class _ExamRunScreenState extends State<ExamRunScreen> {
  bool _leaving = false;

  Future<void> _finish({required bool timedOut}) async {
    final services = context.services;
    setState(() => _leaving = true);
    final done = await services.exams.finishActive(timedOut: timedOut);
    if (done == null) return;
    await recordExamProgress(services, done);
    if (mounted) context.go('${examBase(done.sourceId)}/result/${done.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final exams = context.services.exams;
    final lang = Localizations.localeOf(context).languageCode;
    return ListenableBuilder(
      listenable: exams,
      builder: (context, _) {
        final s = exams.active;
        if (_leaving) {
          return ExamStatePage(
            title: l.examTitle,
            state: LgStateView(kind: StateKind.loading, title: l.examSaving),
          );
        }
        if (s == null) {
          return ExamStatePage(
            title: l.examTitle,
            state: LgStateView(
              kind: StateKind.empty,
              title: l.examNoActive,
              message: l.examNoActiveBody,
              actionLabel: l.examNew,
              onAction: () => context.go(widget.base),
            ),
          );
        }
        return ExamRunner(
          session: s,
          title: examSessionTitle(
            s,
            examSourceOf(context, s.sourceId),
            l,
            lang,
          ),
          onFinish: _finish,
        );
      },
    );
  }
}

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({
    super.key,
    required this.resultId,
    this.base = '/learn/exam',
  });

  final String resultId;

  /// Natija topilmasa — shu bo'limga qaytiladi.
  final String base;

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  bool _all = false;

  Future<void> _rework(ExamSession s, ExamQuestionSource source) async {
    final l = AppLocalizations.of(context);
    final exams = context.services.exams;
    final questions = [
      for (final i in s.mistakeIndexes) ?source.question(s.items[i].questionId),
    ];
    if (questions.isEmpty) return;
    if (exams.active != null) {
      final ok = await confirmDialog(
        context,
        title: l.examReplaceTitle,
        body: l.examReplaceBody,
        action: l.examStart,
      );
      if (!ok || !mounted) return;
    }
    await exams.start(
      ExamSession.build(
        id: exams.newId(),
        mode: ExamMode.rework,
        questions: questions,
        random: exams.random,
        startedAt: exams.now(),
        sourceId: source.id,
        topicIds: s.topicIds,
      ),
    );
    if (mounted) await context.push('${examBase(source.id)}/run');
  }

  /// Shu mavzulardagi oldingi urinish (taqqoslash uchun).
  ExamSession? _previous(ExamSession s) {
    final history = context.services.exams.history;
    final at = history.indexOf(s);
    if (at < 0) return null;
    return history
        .skip(at + 1)
        .where(
          (h) =>
              h.mode == s.mode &&
              h.sourceId == s.sourceId &&
              h.topicIds.length == s.topicIds.length &&
              h.topicIds.every(s.topicIds.contains),
        )
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final exams = context.services.exams;
    return ListenableBuilder(
      listenable: exams,
      builder: (context, _) {
        final s = exams.historyEntry(widget.resultId);
        if (s == null) {
          return ExamStatePage(
            title: l.examResultTitle,
            state: LgStateView(
              kind: StateKind.empty,
              title: l.examResultMissing,
              actionLabel: l.examNew,
              onAction: () => context.go(widget.base),
            ),
          );
        }
        return ExamSourceGate(
          sourceId: s.sourceId,
          builder: (context, source) => _page(s, source),
        );
      },
    );
  }

  Widget _page(ExamSession s, ExamQuestionSource source) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final prev = _previous(s);
    final mistakes = s.mistakeIndexes;
    final shown = _all ? [for (var i = 0; i < s.length; i++) i] : mistakes;
    final delta = prev == null ? null : s.percent - prev.percent;
    return LgPage(
      title: l.examResultTitle,
      subtitle:
          '${examSessionTitle(s, source, l, lang)} · '
          '${formatWhen(s.finishedAt ?? s.startedAt, context)}',
      showProfile: false,
      children: [
        ScoreHero(
          correct: s.correctCount,
          total: s.length,
          wrong: s.wrongCount,
          unanswered: s.unansweredCount,
          spent: s.spent(s.finishedAt ?? s.startedAt),
          limit: s.limit,
          badges: [
            if (s.passed case final passed?)
              LgTag(
                passed
                    ? l.examPassMet(s.passPercent!)
                    : l.examPassMissed(s.passPercent!),
                tone: passed ? LgTone.brand : LgTone.warning,
                icon: passed ? Icons.verified_rounded : Icons.flag_outlined,
              ),
            if (s.timedOut)
              LgTag(l.examTimedOut, tone: LgTone.warning, icon: Icons.alarm),
            if (delta != null)
              LgTag(
                delta > 0
                    ? l.examDeltaUp(delta)
                    : delta < 0
                    ? l.examDeltaDown(-delta)
                    : l.examDeltaSame,
                tone: delta >= 0 ? LgTone.brand : LgTone.neutral,
                icon: delta > 0
                    ? Icons.trending_up_rounded
                    : delta < 0
                    ? Icons.trending_down_rounded
                    : Icons.trending_flat_rounded,
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (mistakes.isNotEmpty) ...[
          LgButton(
            label: l.examReworkMistakes(mistakes.length),
            icon: Icons.replay_rounded,
            onPressed: () => _rework(s, source),
          ),
          const SizedBox(height: 10),
        ],
        LgButton.secondary(
          label: l.examNew,
          icon: Icons.add_rounded,
          onPressed: () => context.go(examBase(s.sourceId)),
        ),
        TopicBreakdown(session: s, source: source),
        LgSectionTitle(l.examAnalysis),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LgChoiceChip(
              label: l.examFilterMistakes(mistakes.length),
              selected: !_all,
              onTap: () => setState(() => _all = false),
            ),
            LgChoiceChip(
              label: l.examFilterAll(s.length),
              selected: _all,
              onTap: () => setState(() => _all = true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          LgStateView(kind: StateKind.success, title: l.quizNoMistakes)
        else
          for (final i in shown)
            ExamReviewCard(
              number: i + 1,
              question: source.question(s.items[i].questionId),
              chosen: s.answerAt(i),
              correct: s.items[i].correct,
            ),
        const SizedBox(height: 8),
        // Rasmiy ro'yxat savollari — LabGuide qoralamasi emas.
        if (s.sourceId != ToifaQuestionSource.sourceId)
          Text(l.quizReviewNote, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Bosh “O'rganish” ekrani uchun: davom etayotgan imtihon bo'lsa qatorda
/// ko'rsatiladi.
String examRowSubtitle(BuildContext context, AppLocalizations l) {
  final exams = context.services.exams;
  final s = exams.active;
  if (s == null) return l.learnExamSub;
  final left = s.remaining(exams.now());
  return left == null
      ? l.examAnsweredOf(s.answeredCount, s.length)
      : l.examActiveBody(s.answeredCount, s.length, formatClock(left));
}
