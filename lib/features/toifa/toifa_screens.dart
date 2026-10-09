import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/ui/content_widgets.dart';
import '../learn/exam_question.dart';
import '../learn/exam_screens.dart';
import '../learn/exam_session.dart';
import '../learn/exam_widgets.dart';
import '../share/result_share.dart';
import 'toifa_bank.dart';
import 'toifa_controller.dart';

/// Bo'lim manzili (O'rganish tabi ichida).
const toifaBase = '/learn/toifa';

/// Bo'lim shu foydalanuvchiga ko'rinadimi: ilova tili o'zbekcha yoki
/// qurilma mintaqasi UZ; shifokor roliga emas.
bool toifaVisible(BuildContext context) => toifaAvailable(
  context.services.settings.language,
  SchedulerBinding.instance.platformDispatcher.locales,
  role: context.services.settings.role,
);

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// Interfeys o'zbekcha bo'lmasa — savollar tili haqida izoh.
class UzbekOnlyTag extends StatelessWidget {
  const UzbekOnlyTag({super.key});

  @override
  Widget build(BuildContext context) {
    if (_lang(context) == 'uz') return const SizedBox.shrink();
    return LgTag(
      AppLocalizations.of(context).toifaUzbekOnly,
      tone: LgTone.neutral,
      icon: Icons.translate_rounded,
    );
  }
}

/// Katta kirish kartasi: O'rganish tabida va laborant bosh sahifasida.
class ToifaEntryCard extends StatelessWidget {
  const ToifaEntryCard({super.key, this.compact = false});

  /// Bosh sahifada — qisqaroq matn.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final toifa = context.services.toifa;
    final exams = context.services.exams;
    return ListenableBuilder(
      listenable: Listenable.merge([toifa, exams]),
      builder: (context, _) {
        final ticket = toifa.ticket;
        final active = exams.active?.sourceId == ToifaQuestionSource.sourceId
            ? exams.active
            : null;
        final status = active != null
            ? l.toifaEntryTestActive(active.answeredCount, active.length)
            : ticket != null && !ticket.done
            ? l.toifaEntryTicketActive(ticket.ratings.length, ticket.ids.length)
            : null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LgRadius.hero),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.soft, p.paper],
              ),
              border: Border.all(color: p.brand.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: p.brand,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.workspace_premium_outlined,
                            color: p.onBrand,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LgEyebrow(l.toifaEyebrow),
                            const SizedBox(height: 2),
                            Semantics(
                              header: true,
                              child: Text(l.toifaTitle, style: text.titleLarge),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    compact ? l.toifaEntryBodyShort : l.toifaEntryBody,
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      LgTag(l.toifaEntryTagTest, icon: Icons.quiz_outlined),
                      LgTag(
                        l.toifaEntryTagOral,
                        icon: Icons.record_voice_over_outlined,
                      ),
                      const UzbekOnlyTag(),
                    ],
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      status,
                      style: text.bodySmall!.copyWith(color: p.brand),
                    ),
                  ],
                  const SizedBox(height: 14),
                  LgButton(
                    label: status != null ? l.toifaContinue : l.toifaOpen,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => openInTab(context, toifaBase),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Toifa tanlash chiplari.
class ToifaCategoryPicker extends StatelessWidget {
  const ToifaCategoryPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final toifa = context.services.toifa;
    // const vidjet ota qayta qurilganda yangilanmaydi — o'zi tinglaydi.
    return ListenableBuilder(
      listenable: toifa,
      builder: (context, _) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in ToifaCategory.values)
            LgChoiceChip(
              label: c.label(l),
              selected: toifa.category == c,
              onTap: () => toifa.setCategory(c),
            ),
        ],
      ),
    );
  }
}

/// Bo'lim sahifasi: bank yuklanguncha sarlavha bilan holat bloki.
class _ToifaPage extends StatelessWidget {
  const _ToifaPage({
    required this.title,
    required this.builder,
    this.subtitle,
    this.pageKey,
  });

  final String title;
  final String? subtitle;

  /// Holat kaliti: o'zgarsa sahifa tepadan boshlanadi (masalan, yangi bilet
  /// yoki keyingi savol).
  final Object? Function()? pageKey;
  final List<Widget> Function(BuildContext context, ToifaBank bank) builder;

  @override
  Widget build(BuildContext context) {
    final toifa = context.services.toifa;
    return ToifaBankGate(
      builder: (context, bank) => ListenableBuilder(
        listenable: Listenable.merge([
          toifa,
          context.services.quizProgress,
          context.services.exams,
        ]),
        builder: (context, _) => LgPage(
          key: pageKey == null ? null : ValueKey(pageKey!()),
          title: title,
          subtitle: subtitle,
          showProfile: false,
          children: builder(context, bank),
        ),
      ),
    );
  }
}

/// Test savollari o'zlashtirilgani: oxirgi javobi to'g'ri bo'lganlar ulushi.
(int mastered, int total) _testMastery(
  BuildContext context,
  Iterable<ToifaTestQuestion> qs,
) {
  final ids = [for (final q in qs) q.id];
  return (context.services.quizProgress.mastered(ids), ids.length);
}

/// Og'zaki savollar: “bildim” deb baholanganlar ulushi.
(int knew, int total) _oralMastery(
  ToifaController toifa,
  Iterable<ToifaOralQuestion> qs,
) {
  var knew = 0;
  var total = 0;
  for (final q in qs) {
    total++;
    if (toifa.mark(q.id)?.rating == OralRating.knew) knew++;
  }
  return (knew, total);
}

int _pct(int a, int b) => b == 0 ? 0 : (a * 100 / b).round();

/// Test xatolari (oxirgi javobi noto'g'ri).
List<ToifaTestQuestion> _testMistakes(BuildContext context, ToifaBank bank) {
  final wrong = context.services.quizProgress.mistakes([
    for (final q in bank.scorable) q.id,
  ]).toSet();
  return [
    for (final q in bank.scorable)
      if (wrong.contains(q.id)) q,
  ];
}

class ToifaHubScreen extends StatelessWidget {
  const ToifaHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ToifaPage(
      title: l.toifaTitle,
      subtitle: l.toifaSubtitle,
      builder: (context, bank) => _body(context, l, bank),
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l, ToifaBank bank) {
    final text = Theme.of(context).textTheme;
    final toifa = context.services.toifa;
    final exams = context.services.exams;
    final cat = toifa.category;
    final active = exams.active?.sourceId == ToifaQuestionSource.sourceId
        ? exams.active
        : null;
    final (tm, tt) = _testMastery(context, bank.scorable);
    final oralPool = cat == null
        ? bank.oral.where((q) => q.held == null)
        : bank.ticketPool(cat);
    final (ok, ot) = _oralMastery(toifa, oralPool);
    final mistakes = _testMistakes(context, bank).length;
    final oralUnknown = toifa.oralWith(OralRating.unknown).length;
    final ticket = toifa.ticket;
    return [
      if (_lang(context) != 'uz')
        LgNotice(
          l.toifaUzbekNotice,
          title: l.toifaUzbekOnly,
          kind: NoticeKind.info,
        ),
      LgSectionTitle(l.toifaYourCategory),
      const ToifaCategoryPicker(),
      const SizedBox(height: 8),
      Text(l.toifaCategoryHint, style: text.bodySmall),
      const SizedBox(height: 8),
      _ReadinessStrip(
        test: _pct(tm, tt),
        oral: _pct(ok, ot),
        onTap: () => context.push('$toifaBase/progress'),
      ),
      if (active != null) ActiveExamCard(session: active),
      LgSectionTitle(l.toifaPrepare),
      LgRow(
        title: l.toifaTestTitle,
        subtitle: l.toifaTestRowSub(ToifaFormat.testSize, bank.scorable.length),
        icon: Icons.timer_outlined,
        onTap: () => context.push('$toifaBase/test'),
      ),
      LgRow(
        title: l.toifaPracticeTitle,
        subtitle: l.toifaPracticeRowSub(bank.source.topics.length),
        icon: Icons.category_outlined,
        onTap: () => context.push('$toifaBase/practice'),
      ),
      LgRow(
        title: l.toifaOralTitle,
        subtitle: ticket != null && !ticket.done
            ? l.toifaOralRowActive(ticket.ratings.length, ticket.ids.length)
            : cat == null
            ? l.toifaOralRowPick
            : l.toifaOralRowSub(cat.label(l), bank.ticketPool(cat).length),
        icon: Icons.record_voice_over_outlined,
        onTap: () => context.push('$toifaBase/oral'),
      ),
      LgRow(
        title: l.toifaMistakesTitle,
        subtitle: mistakes + oralUnknown == 0
            ? l.toifaMistakesRowEmpty
            : l.toifaMistakesRowSub(mistakes, oralUnknown),
        icon: Icons.replay_rounded,
        onTap: () => context.push('$toifaBase/mistakes'),
      ),
      LgRow(
        title: l.toifaProgressTitle,
        subtitle: l.toifaProgressRowSub,
        icon: Icons.insights_outlined,
        onTap: () => context.push('$toifaBase/progress'),
        divider: false,
      ),
      LgSectionTitle(l.toifaAboutTitle),
      _AboutPanel(bank: bank),
    ];
  }
}

/// Tayyorlik qisqacha: test va og'zaki — bosilsa “Rivojlanish”.
class _ReadinessStrip extends StatelessWidget {
  const _ReadinessStrip({
    required this.test,
    required this.oral,
    required this.onTap,
  });

  final int test;
  final int oral;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    Widget cell(String label, int value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value%',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: p.brand,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 5,
              color: p.brand,
              backgroundColor: p.line,
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LgPressable(
        onTap: onTap,
        color: p.paper,
        borderRadius: BorderRadius.circular(LgRadius.card),
        semanticLabel:
            '${l.toifaReadyTest}: $test%. ${l.toifaReadyOral}: $oral%',
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cell(l.toifaReadyTest, test),
                const SizedBox(width: 16),
                cell(l.toifaReadyOral, oral),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: p.sub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Manba va tekshiruv: halol izoh.
class _AboutPanel extends StatelessWidget {
  const _AboutPanel({required this.bank});

  final ToifaBank bank;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final ready = bank.oral.where((q) => q.planReady).length;
    final lines = [
      l.toifaAboutList(bank.tests.length, bank.oral.length),
      l.toifaAboutKeys(
        bank.verdictCount(KeyVerdict.disputed),
        bank.verdictCount(KeyVerdict.ambiguous),
      ),
      if (bank.keyless > 0) l.toifaAboutKeyless(bank.keyless),
      l.toifaAboutOral(ready, bank.oral.length),
      if (bank.oral.where((q) => q.held != null).length + bank.heldTests
          case final held when held > 0)
        l.toifaAboutHeld(held),
      if (bank.auditCheckedAt case final date?) l.toifaAgentChecked(date),
    ];
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OfficialListSource(),
          const SizedBox(height: 6),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(line, style: text.bodyMedium),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Test

class ToifaTestScreen extends StatefulWidget {
  const ToifaTestScreen({super.key});

  @override
  State<ToifaTestScreen> createState() => _ToifaTestScreenState();
}

class _ToifaTestScreenState extends State<ToifaTestScreen> {
  late final TextEditingController _minutes;
  late final TextEditingController _pass;
  bool _tried = false;

  @override
  void initState() {
    super.initState();
    final toifa = context.services.toifa;
    _minutes = TextEditingController(text: toifa.testMinutes?.toString() ?? '');
    _pass = TextEditingController(text: toifa.testPass?.toString() ?? '');
  }

  @override
  void dispose() {
    _minutes.dispose();
    _pass.dispose();
    super.dispose();
  }

  int? _parse(TextEditingController c) => int.tryParse(c.text.trim());

  String? _minutesError(AppLocalizations l) {
    if (_minutes.text.trim().isEmpty) return null;
    final n = _parse(_minutes);
    return n == null || n < 1 || n > 240 ? l.toifaTimeError : null;
  }

  String? _passError(AppLocalizations l) {
    if (_pass.text.trim().isEmpty) return null;
    final n = _parse(_pass);
    return n == null || n < 1 || n > 100 ? l.toifaPassError : null;
  }

  Future<void> _start(ToifaBank bank) async {
    final l = AppLocalizations.of(context);
    setState(() => _tried = true);
    if (_minutesError(l) != null || _passError(l) != null) return;
    final services = context.services;
    final exams = services.exams;
    if (exams.active != null) {
      final ok = await confirmDialog(
        context,
        title: l.examReplaceTitle,
        body: l.examReplaceBody,
        action: l.examStart,
      );
      if (!ok || !mounted) return;
    }
    final minutes = _parse(_minutes);
    final pass = _parse(_pass);
    await services.toifa.setTestSettings(minutes: minutes, pass: pass);
    final session = ExamSession.build(
      id: exams.newId(),
      mode: ExamMode.exam,
      questions: drawQuestions(
        toifaTestPool(bank),
        ToifaFormat.testSize,
        exams.random,
      ),
      random: exams.random,
      startedAt: exams.now(),
      sourceId: ToifaQuestionSource.sourceId,
      limit: minutes == null ? null : Duration(minutes: minutes),
      passPercent: pass,
      shuffleOptions: false,
    );
    await exams.start(session);
    if (mounted) await context.push('$toifaBase/test/run');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ToifaPage(
      title: l.toifaTestTitle,
      subtitle: l.toifaTestSubtitle(ToifaFormat.testSize),
      builder: (context, bank) => _body(context, l, bank),
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l, ToifaBank bank) {
    final exams = context.services.exams;
    final active = exams.active?.sourceId == ToifaQuestionSource.sourceId
        ? exams.active
        : null;
    return [
      if (active != null) ActiveExamCard(session: active),
      const UzbekOnlyTag(),
      LgSectionTitle(l.toifaFormatTitle),
      LgSteps([
        l.toifaFormatStep1(ToifaFormat.testSize, toifaTestPool(bank).length),
        l.toifaFormatStep2,
        l.toifaFormatStep3,
      ]),
      LgSectionTitle(l.examSettings),
      NumberPresetField(
        label: l.toifaTimeLabel,
        controller: _minutes,
        hint: l.toifaNoTime,
        helper: l.toifaTimeHelper,
        errorText: _tried ? _minutesError(l) : null,
        presets: [
          (l.toifaNoTime, ''),
          for (final n in [30, 60, 90]) (l.examMinutes(n), '$n'),
        ],
        onChanged: () => setState(() {}),
      ),
      const SizedBox(height: 6),
      NumberPresetField(
        label: l.toifaPassLabel,
        controller: _pass,
        hint: l.toifaNoPass,
        helper: l.toifaPassHelper,
        errorText: _tried ? _passError(l) : null,
        presets: [
          (l.toifaNoPass, ''),
          for (final n in [60, 70, 80]) ('$n%', '$n'),
        ],
        onChanged: () => setState(() {}),
      ),
      const SizedBox(height: 14),
      LgNotice(l.toifaScoringNotice, kind: NoticeKind.info),
      const SizedBox(height: 12),
      LgButton(
        label: l.toifaTestStart,
        icon: Icons.play_arrow_rounded,
        onPressed: () => _start(bank),
      ),
      ExamHistory(exams: exams, sourceId: ToifaQuestionSource.sourceId),
    ];
  }
}

// ---------------------------------------------------------------- Mashq

/// Mashq doiralari: aralash, xatolar yoki mavzu id.
const _mixed = 'mixed';
const _mistakes = 'mistakes';

class ToifaPracticeListScreen extends StatelessWidget {
  const ToifaPracticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ToifaPage(
      title: l.toifaPracticeTitle,
      subtitle: l.toifaPracticeSubtitle,
      builder: (context, bank) {
        final mistakes = _testMistakes(context, bank).length;
        final topics = bank.source.topics;
        return [
          const UzbekOnlyTag(),
          LgSectionTitle(l.quizChooseTopic),
          LgRow(
            title: l.toifaPracticeMixed(_roundSize()),
            subtitle: l.quizQuestionCount(bank.scorable.length),
            icon: Icons.shuffle_rounded,
            onTap: () => context.push('$toifaBase/practice/$_mixed'),
          ),
          if (mistakes > 0)
            LgRow(
              title: l.toifaPracticeMistakes,
              subtitle: l.quizQuestionCount(mistakes),
              icon: Icons.replay_rounded,
              onTap: () => context.push('$toifaBase/practice/$_mistakes'),
            ),
          for (final (i, t) in topics.indexed)
            Builder(
              builder: (context) {
                final qs = t.questions.cast<ToifaTestQuestion>();
                final (m, n) = _testMastery(context, qs);
                return LgRow(
                  title: t.name(l, _lang(context)),
                  subtitle: m == 0
                      ? l.quizQuestionCount(n)
                      : '${l.quizQuestionCount(n)} · ${l.quizMastered(m, n)}',
                  icon: Icons.label_outline_rounded,
                  onTap: () => context.push('$toifaBase/practice/${t.id}'),
                  divider: i < topics.length - 1,
                );
              },
            ),
        ];
      },
    );
  }
}

int _roundSize() => toifaAllows(ToifaFeature.extendedPractice)
    ? ToifaFormat.practiceRound
    : ToifaFreeProposal.practiceRound;

/// Mavzu bo'yicha mashq: javobdan keyin darhol rasmiy kalit va (bo'lsa)
/// LabGuide izohi. Variantlar ro'yxatdagi tartibda.
class ToifaPracticeScreen extends StatefulWidget {
  const ToifaPracticeScreen({super.key, required this.scope});

  final String scope;

  @override
  State<ToifaPracticeScreen> createState() => _ToifaPracticeScreenState();
}

class _ToifaPracticeScreenState extends State<ToifaPracticeScreen> {
  List<ToifaTestQuestion>? _round;
  final Map<int, int> _answers = {};
  int _index = 0;
  bool _finished = false;

  String _title(AppLocalizations l, ToifaBank bank) => switch (widget.scope) {
    _mixed => l.toifaPracticeMixed(_roundSize()),
    _mistakes => l.toifaPracticeMistakes,
    final t => l.toifaTopic(t),
  };

  /// Raund: avval xato qilinganlar, keyin ko'rilmaganlar, so'ng qolganlari.
  List<ToifaTestQuestion> _draw(ToifaBank bank) {
    final progress = context.services.quizProgress;
    final random = context.services.toifa.random;
    final pool = switch (widget.scope) {
      _mixed => List.of(bank.scorable),
      _mistakes => _testMistakes(context, bank),
      final t => [
        for (final q in bank.scorable)
          if (q.topic == t) q,
      ],
    }..shuffle(random);
    int rank(ToifaTestQuestion q) => switch (progress.statFor(q.id)) {
      null => 1,
      final s when !s.lastCorrect => 0,
      _ => 2,
    };
    if (widget.scope != _mixed) {
      pool.sort((a, b) => rank(a).compareTo(rank(b)));
    }
    return pool.take(_roundSize()).toList();
  }

  void _restart(ToifaBank bank) => setState(() {
    _round = _draw(bank);
    _answers.clear();
    _index = 0;
    _finished = false;
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ToifaBankGate(
      builder: (context, bank) {
        _round ??= _draw(bank);
        final round = _round!;
        return LgPage(
          key: ValueKey((_index, _finished)),
          title: l.toifaPracticeTitle,
          subtitle: _title(l, bank),
          showProfile: false,
          children: [
            if (round.isEmpty)
              LgStateView(
                kind: StateKind.success,
                title: l.quizNoMistakes,
                actionLabel: l.toifaBackToTopics,
                onAction: () => context.pop(),
              )
            else if (_finished)
              ..._result(context, l, bank, round)
            else
              ..._question(context, l, round),
          ],
        );
      },
    );
  }

  List<Widget> _question(
    BuildContext context,
    AppLocalizations l,
    List<ToifaTestQuestion> round,
  ) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final q = round[_index];
    final answer = _answers[_index];
    final answered = answer != null;
    final correct = answered && q.key.contains(answer);
    final check = q.keyCheck;
    return [
      Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          LgEyebrow(l.quizProgress(_index + 1, round.length)),
          LgTag(l.toifaListNumber(q.number), tone: LgTone.neutral),
          if (answered && check.flagged) KeyVerdictTag(verdict: check.verdict),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_index + 1) / round.length,
            minHeight: 6,
            color: p.brand,
            backgroundColor: p.line,
          ),
        ),
      ),
      Semantics(header: true, child: Text(q.text, style: text.headlineSmall)),
      const SizedBox(height: 14),
      for (var i = 0; i < q.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _PracticeOption(
            letter: optionLetter(i),
            label: q.options[i],
            state: !answered
                ? _Opt.idle
                : q.key.contains(i)
                ? _Opt.key
                : i == answer
                ? _Opt.wrong
                : _Opt.idle,
            keyLabel: check.flagged ? l.toifaOfficialKey : l.quizCorrectAnswer,
            onTap: answered
                ? null
                : () {
                    setState(() => _answers[_index] = i);
                    unawaited(
                      context.services.quizProgress.record(
                        q.id,
                        correct: q.key.contains(i),
                      ),
                    );
                  },
          ),
        ),
      if (answered) ...[
        LgNotice(
          correct ? l.toifaPracticeRight : l.toifaPracticeWrong,
          title: correct ? l.quizCorrect : l.quizIncorrect,
          kind: correct ? NoticeKind.info : NoticeKind.warning,
        ),
        KeyCheckNote(question: q),
        const OfficialListSource(),
        _RelatedCards(ids: q.analytes),
        const SizedBox(height: 14),
        LgButton(
          label: _index == round.length - 1 ? l.quizFinish : l.quizNext,
          onPressed: () => setState(() {
            if (_index == round.length - 1) {
              _finished = true;
            } else {
              _index++;
            }
          }),
        ),
      ],
    ];
  }

  List<Widget> _result(
    BuildContext context,
    AppLocalizations l,
    ToifaBank bank,
    List<ToifaTestQuestion> round,
  ) {
    var right = 0;
    for (final e in _answers.entries) {
      if (round[e.key].key.contains(e.value)) right++;
    }
    final wrong = [
      for (final e in _answers.entries)
        if (!round[e.key].key.contains(e.value)) e,
    ];
    return [
      ScoreHero(correct: right, total: round.length),
      LgButton(
        label: l.quizRestart,
        icon: Icons.replay_rounded,
        onPressed: () => _restart(bank),
      ),
      const SizedBox(height: 10),
      LgButton.secondary(
        label: l.toifaBackToTopics,
        onPressed: () => context.pop(),
      ),
      const SizedBox(height: 10),
      ShareResultButton(
        data: ShareData(
          kind: ShareKind.toifa,
          correct: right,
          total: round.length,
          date: context.services.toifa.now(),
          topic: _title(l, bank),
        ),
      ),
      LgSectionTitle(l.quizMistakes),
      if (wrong.isEmpty)
        Text(l.quizNoMistakes, style: Theme.of(context).textTheme.bodyMedium)
      else
        for (final (n, e) in wrong.indexed)
          ExamReviewCard(
            number: n + 1,
            question: round[e.key],
            chosen: [e.value],
            correct: round[e.key].key.toList(),
          ),
    ];
  }
}

enum _Opt { idle, key, wrong }

class _PracticeOption extends StatelessWidget {
  const _PracticeOption({
    required this.letter,
    required this.label,
    required this.state,
    required this.keyLabel,
    required this.onTap,
  });

  final String letter;
  final String label;
  final _Opt state;
  final String keyLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final (Color bg, Color border, String? suffix) = switch (state) {
      _Opt.idle => (p.paper, p.line, null),
      _Opt.key => (p.soft, p.brand, keyLabel),
      _Opt.wrong => (p.amberBg, p.amber, l.quizYourAnswer),
    };
    final fg = state == _Opt.wrong ? p.amber : p.brand;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LgRadius.button),
        border: Border.all(color: border, width: state == _Opt.idle ? 1 : 2),
      ),
      child: LgPressable(
        onTap: onTap,
        color: bg,
        borderRadius: BorderRadius.circular(LgRadius.button),
        semanticLabel: suffix == null
            ? '$letter. $label'
            : '$letter. $label. $suffix',
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state == _Opt.idle ? null : fg,
                      border: Border.all(
                        color: state == _Opt.idle ? p.outline : fg,
                        width: 1.5,
                      ),
                    ),
                    child: state == _Opt.idle
                        ? Text(letter, style: text.labelLarge)
                        : Icon(
                            state == _Opt.key
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 18,
                            color: p.onBrand,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: text.bodyLarge),
                        if (suffix != null)
                          Text(
                            suffix,
                            style: text.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bog'liq analit kartalari (paketda borlari).
class _RelatedCards extends StatelessWidget {
  const _RelatedCards({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pack = context.services.content.pack;
    final analytes = [for (final id in ids) ?pack?.analyte(id)];
    if (analytes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.toifaRelatedCards),
        for (final (i, a) in analytes.indexed)
          AnalyteRow(
            analyte: a,
            divider: i < analytes.length - 1,
            onTap: () => context.push('$toifaBase/analyte/${a.id}'),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Og'zaki

class ToifaOralScreen extends StatelessWidget {
  const ToifaOralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ToifaPage(
      title: l.toifaOralTitle,
      subtitle: l.toifaOralSubtitle(ToifaFormat.ticketSize),
      pageKey: () {
        final t = context.services.toifa.ticket;
        return (t?.startedAt, t?.reviewing, t?.index, t?.done);
      },
      builder: (context, bank) {
        final ticket = context.services.toifa.ticket;
        if (ticket == null) return _intro(context, l, bank);
        if (!ticket.reviewing) return _prep(context, l, bank, ticket);
        if (ticket.done) return _summary(context, l, bank, ticket);
        return _review(context, l, bank, ticket);
      },
    );
  }

  Future<void> _draw(BuildContext context, ToifaCategory c) async {
    final toifa = context.services.toifa;
    await toifa.drawTicket(c);
  }

  List<Widget> _intro(
    BuildContext context,
    AppLocalizations l,
    ToifaBank bank,
  ) {
    final toifa = context.services.toifa;
    final text = Theme.of(context).textTheme;
    final cat = toifa.category;
    return [
      const UzbekOnlyTag(),
      LgSectionTitle(l.toifaYourCategory),
      const ToifaCategoryPicker(),
      if (cat != null) ...[
        const SizedBox(height: 8),
        Text(
          l.toifaOralPool(cat.label(l), bank.ticketPool(cat).length),
          style: text.bodySmall,
        ),
      ],
      LgSectionTitle(l.toifaOralHowTitle),
      LgSteps([
        l.toifaOralStep1(ToifaFormat.ticketSize),
        l.toifaOralStep2,
        l.toifaOralStep3,
      ]),
      const SizedBox(height: 8),
      LgNotice(l.toifaPlanDisclaimer),
      const SizedBox(height: 8),
      LgButton(
        label: cat == null ? l.toifaPickCategoryFirst : l.toifaDrawTicket,
        icon: Icons.style_outlined,
        onPressed: cat == null ? null : () => _draw(context, cat),
      ),
    ];
  }

  List<Widget> _prep(
    BuildContext context,
    AppLocalizations l,
    ToifaBank bank,
    OralTicket ticket,
  ) {
    final toifa = context.services.toifa;
    final text = Theme.of(context).textTheme;
    return [
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          LgTag(
            ticket.category.label(l),
            icon: Icons.workspace_premium_outlined,
          ),
          const UzbekOnlyTag(),
        ],
      ),
      LgSectionTitle(l.toifaTicketTitle),
      Text(l.toifaPrepHint, style: text.bodyMedium),
      const SizedBox(height: 8),
      for (final (i, id) in ticket.ids.indexed)
        LgPanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Num(i + 1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  bank.oralQuestion(id)?.text ?? id,
                  style: text.titleMedium,
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),
      LgButton(
        label: l.toifaShowPlans,
        icon: Icons.visibility_outlined,
        onPressed: toifa.startReview,
      ),
      const SizedBox(height: 4),
      LgButton.link(
        label: l.toifaNewTicket,
        onPressed: () async {
          final ok = await confirmDialog(
            context,
            title: l.toifaNewTicket,
            body: l.toifaNewTicketBody,
            action: l.toifaNewTicket,
          );
          if (ok && context.mounted) await _draw(context, ticket.category);
        },
      ),
    ];
  }

  List<Widget> _review(
    BuildContext context,
    AppLocalizations l,
    ToifaBank bank,
    OralTicket ticket,
  ) {
    final toifa = context.services.toifa;
    final q = bank.oralQuestion(ticket.currentId)!;
    return [
      _TicketDots(ticket: ticket),
      _OralQuestionView(
        number: ticket.index + 1,
        total: ticket.ids.length,
        question: q,
        revealed: ticket.revealed,
        onReveal: toifa.reveal,
        rating: ticket.ratings[q.id],
        onRate: toifa.rateCurrent,
      ),
    ];
  }

  List<Widget> _summary(
    BuildContext context,
    AppLocalizations l,
    ToifaBank bank,
    OralTicket ticket,
  ) {
    final toifa = context.services.toifa;
    final text = Theme.of(context).textTheme;
    return [
      ScoreHero(
        correct: ticket.count(OralRating.knew),
        total: ticket.ids.length,
        title: l.toifaTicketDone,
        caption: l.toifaTicketSummary(
          ticket.count(OralRating.knew),
          ticket.count(OralRating.partial),
          ticket.count(OralRating.unknown),
        ),
      ),
      LgButton(
        label: l.toifaNewTicket,
        icon: Icons.style_outlined,
        onPressed: () => _draw(context, toifa.category ?? ticket.category),
      ),
      const SizedBox(height: 10),
      LgButton.secondary(
        label: l.toifaMistakesTitle,
        icon: Icons.replay_rounded,
        onPressed: () => context.push('$toifaBase/mistakes'),
      ),
      LgSectionTitle(l.toifaTicketTitle),
      for (final (i, id) in ticket.ids.indexed)
        LgRow(
          title: bank.oralQuestion(id)?.text ?? id,
          subtitle: ticket.ratings[id]?.label(l),
          icon: _ratingIcon(ticket.ratings[id]),
          onTap: () => context.push('$toifaBase/oral/q/$id'),
          divider: i < ticket.ids.length - 1,
        ),
      const SizedBox(height: 8),
      Text(l.toifaRatingsSaved, style: text.bodySmall),
    ];
  }
}

IconData _ratingIcon(OralRating? r) => switch (r) {
  OralRating.knew => Icons.check_circle_outline_rounded,
  OralRating.partial => Icons.adjust_rounded,
  OralRating.unknown => Icons.help_outline_rounded,
  null => Icons.radio_button_unchecked_rounded,
};

class _Num extends StatelessWidget {
  const _Num(this.n);

  final int n;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$n',
        style: Theme.of(context).textTheme.labelMedium!
            .copyWith(color: p.brand, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Bilet bo'yicha holat: har savol — baholangan/joriy/kutilmoqda; bosilsa
/// shu savolga o'tiladi.
class _TicketDots extends StatelessWidget {
  const _TicketDots({required this.ticket});

  final OralTicket ticket;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final toifa = context.services.toifa;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (i, id) in ticket.ids.indexed)
          LgPressable(
            onTap: () => toifa.openInTicket(i),
            selected: i == ticket.index,
            color: i == ticket.index
                ? p.brand
                : ticket.ratings.containsKey(id)
                ? p.soft
                : p.paper,
            border: Border.all(color: i == ticket.index ? p.brand : p.line),
            borderRadius: BorderRadius.circular(LgRadius.chip),
            semanticLabel:
                '${l.examQuestionN(i + 1)}. '
                '${ticket.ratings[id]?.label(l) ?? ''}',
            child: ExcludeSemantics(
              child: SizedBox(
                width: kMinTap,
                height: kMinTap,
                child: Center(
                  child: ticket.ratings.containsKey(id) && i != ticket.index
                      ? Icon(
                          _ratingIcon(ticket.ratings[id]),
                          size: 20,
                          color: p.brand,
                        )
                      : Text(
                          '${i + 1}',
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: i == ticket.index ? p.onBrand : p.ink,
                              ),
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Og'zaki savol: matn → “Javob rejasini ko'rish” → reja, eskirgan xatolar,
/// manbalar, bog'liq kartalar → o'zini baholash.
class _OralQuestionView extends StatelessWidget {
  const _OralQuestionView({
    required this.question,
    required this.revealed,
    required this.onReveal,
    required this.rating,
    required this.onRate,
    this.number,
    this.total,
  });

  final ToifaOralQuestion question;
  final bool revealed;
  final VoidCallback onReveal;
  final OralRating? rating;
  final ValueChanged<OralRating> onRate;
  final int? number;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final q = question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (number != null) LgEyebrow(l.quizProgress(number!, total!)),
            LgTag(l.toifaTopic(q.topic), tone: LgTone.neutral),
            if (q.held != null)
              LgTag(
                l.toifaHeld,
                tone: LgTone.warning,
                icon: Icons.pending_outlined,
              ),
          ],
        ),
        if (q.held != null) ...[
          const SizedBox(height: 6),
          Text(
            l.toifaHeldBody,
            style: text.bodySmall!.copyWith(color: p.amber),
          ),
        ],
        const SizedBox(height: 8),
        Semantics(header: true, child: Text(q.text, style: text.headlineSmall)),
        const SizedBox(height: 14),
        if (!revealed) ...[
          Text(l.toifaRevealHint, style: text.bodyMedium),
          const SizedBox(height: 12),
          LgButton(
            label: l.toifaShowPlan,
            icon: Icons.visibility_outlined,
            onPressed: onReveal,
          ),
        ] else ...[
          LgPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    LgEyebrow(l.toifaPlanTitle),
                    LgTag(
                      l.toifaPlanPending,
                      tone: LgTone.warning,
                      icon: Icons.pending_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (q.plan.isEmpty)
                  Text(
                    l.toifaPlanMissing,
                    style: text.bodyMedium!.copyWith(color: p.amber),
                  )
                else
                  LgSteps(q.plan),
                if (!q.planReady || q.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      [
                        if (!q.planReady) l.toifaPlanNotChecked,
                        ?q.note,
                      ].join(' '),
                      style: text.bodySmall!.copyWith(color: p.amber),
                    ),
                  ),
                if (q.checked case final date?)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l.toifaAgentChecked(date),
                      style: text.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          // Referens interval va diagnostik chegara — alohida bloklarda.
          if (q.reference.isNotEmpty)
            _FactBlock(
              title: l.toifaReferenceTitle,
              facts: q.reference,
              icon: Icons.straighten_rounded,
            ),
          if (q.cutoffs.isNotEmpty)
            _FactBlock(
              title: l.toifaCutoffTitle,
              facts: q.cutoffs,
              icon: Icons.rule_rounded,
            ),
          if (q.pitfalls.isNotEmpty) _PitfallBlock(pitfalls: q.pitfalls),
          if (q.links.isNotEmpty) ...[
            LgSectionTitle(l.quizSources),
            for (final link in q.links) ExamLinkRow(link: link),
          ],
          _RelatedCards(ids: q.analytes),
          LgSectionTitle(l.toifaRateTitle),
          Text(l.toifaRateHint, style: text.bodySmall),
          const SizedBox(height: 10),
          for (final r in OralRating.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: rating == r
                  ? LgButton(
                      label: r.label(l),
                      icon: _ratingIcon(r),
                      onPressed: () => onRate(r),
                    )
                  : LgButton.secondary(
                      label: r.label(l),
                      icon: _ratingIcon(r),
                      onPressed: () => onRate(r),
                    ),
            ),
        ],
      ],
    );
  }
}

/// Referens intervallar yoki diagnostik chegaralar: har biri — nomi va
/// qiymati (birlik bilan), sharoiti (namuna/populyatsiya yoki qo'llanma),
/// izoh va manba.
class _FactBlock extends StatelessWidget {
  const _FactBlock({
    required this.title,
    required this.facts,
    required this.icon,
  });

  final String title;
  final List<OralFact> facts;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 18, color: p.brand),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: text.titleSmall!.copyWith(color: p.brand),
                  ),
                ),
              ),
            ],
          ),
          for (final (i, f) in facts.indexed) ...[
            if (i > 0) Divider(height: 18, color: p.line),
            if (i == 0) const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  if (f.label != null)
                    TextSpan(text: '${f.label}: ', style: text.bodyMedium),
                  TextSpan(
                    text: f.unit == null ? f.value : '${f.value} ${f.unit}',
                    style: text.titleSmall,
                  ),
                ],
              ),
            ),
            if (f.context.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(f.context.join(' · '), style: text.bodySmall),
              ),
            if (f.note != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  f.note!,
                  style: text.bodySmall!.copyWith(color: p.sub),
                ),
              ),
            if (f.link != null) ExamLinkRow(link: f.link!),
          ],
        ],
      ),
    );
  }
}

/// Eskirgan / ko'p uchraydigan xato: “Noto'g'ri → To'g'ri (manba)”. Manba
/// bilan tasdiqlanmagan tuzatish “to'g'ri” deb ko'rsatilmaydi.
class _PitfallBlock extends StatelessWidget {
  const _PitfallBlock({required this.pitfalls});

  final List<OralPitfall> pitfalls;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    Widget line(IconData icon, Color color, String label, String value) =>
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$label: ',
                        style: text.titleSmall!.copyWith(color: color),
                      ),
                      TextSpan(text: value, style: text.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.amberBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.history_edu_outlined, size: 18, color: p.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.toifaPitfallsTitle,
                    style: text.titleSmall!.copyWith(color: p.amber),
                  ),
                ),
              ],
            ),
            for (final (i, f) in pitfalls.indexed) ...[
              if (i > 0) Divider(height: 18, color: p.line),
              if (f.wrong != null)
                line(
                  Icons.cancel_outlined,
                  p.amber,
                  l.toifaWrongLabel,
                  f.wrong!,
                ),
              if (f.right != null)
                f.verified
                    ? line(
                        Icons.check_circle_outline_rounded,
                        p.brand,
                        l.toifaRightLabel,
                        f.right!,
                      )
                    : line(
                        Icons.help_outline_rounded,
                        p.sub,
                        l.toifaNeedsSource,
                        f.right!,
                      ),
              if (f.text != null)
                line(
                  Icons.info_outline_rounded,
                  p.amber,
                  f.verified ? l.toifaPitfallsTitle : l.toifaNeedsSource,
                  f.text!,
                ),
              if (f.verified)
                for (final link in f.links) ExamLinkRow(link: link),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bitta og'zaki savol (xatolar ro'yxatidan yoki bilet yakunidan).
class ToifaOralQuestionScreen extends StatefulWidget {
  const ToifaOralQuestionScreen({super.key, required this.id});

  final String id;

  @override
  State<ToifaOralQuestionScreen> createState() =>
      _ToifaOralQuestionScreenState();
}

class _ToifaOralQuestionScreenState extends State<ToifaOralQuestionScreen> {
  bool _revealed = false;

  // Boshqa savolga o'tilganda State qayta ishlatiladi — reja yopiladi.
  @override
  void didUpdateWidget(ToifaOralQuestionScreen old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) _revealed = false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ToifaPage(
      title: l.toifaOralTitle,
      builder: (context, bank) {
        final q = bank.oralQuestion(widget.id);
        if (q == null) {
          return [
            LgStateView(kind: StateKind.empty, title: l.examQuestionMissing),
          ];
        }
        final toifa = context.services.toifa;
        return [
          _OralQuestionView(
            question: q,
            revealed: _revealed,
            onReveal: () => setState(() => _revealed = true),
            rating: toifa.mark(q.id)?.rating,
            onRate: (r) async {
              await toifa.rate(q.id, r);
              if (context.mounted) showSnack(context, l.toifaRatingSaved);
            },
          ),
        ];
      },
    );
  }
}

// ---------------------------------------------------------------- Xatolar

class ToifaMistakesScreen extends StatelessWidget {
  const ToifaMistakesScreen({super.key});

  /// Ro'yxatda bir yo'la ko'rsatiladigan test xatolari.
  static const shown = 30;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ToifaPage(
      title: l.toifaMistakesTitle,
      subtitle: l.toifaMistakesSubtitle,
      builder: (context, bank) {
        final toifa = context.services.toifa;
        final text = Theme.of(context).textTheme;
        final tests = _testMistakes(context, bank);
        final unknown = toifa.oralWith(OralRating.unknown);
        final partial = toifa.oralWith(OralRating.partial);
        if (tests.isEmpty && unknown.isEmpty && partial.isEmpty) {
          return [
            LgStateView(
              kind: StateKind.empty,
              title: l.toifaMistakesEmpty,
              message: l.toifaMistakesEmptyBody,
              actionLabel: l.toifaPracticeTitle,
              onAction: () => context.push('$toifaBase/practice'),
            ),
          ];
        }
        Widget oralRow(String id, int i, int n) => LgRow(
          title: bank.oralQuestion(id)?.text ?? id,
          subtitle: [
            l.toifaTopic(bank.oralQuestion(id)?.topic ?? 'other'),
            if (bank.oralQuestion(id)?.held != null) l.toifaHeld,
          ].join(' · '),
          icon: _ratingIcon(toifa.mark(id)?.rating),
          onTap: () => context.push('$toifaBase/oral/q/$id'),
          divider: i < n - 1,
        );
        return [
          LgSectionTitle(l.toifaMistakesTests(tests.length)),
          if (tests.isEmpty)
            Text(l.quizNoMistakes, style: text.bodyMedium)
          else ...[
            LgButton(
              label: l.toifaPracticeMistakes,
              icon: Icons.replay_rounded,
              onPressed: () => context.push('$toifaBase/practice/$_mistakes'),
            ),
            const SizedBox(height: 6),
            for (final (i, q) in tests.take(shown).indexed)
              ExamReviewCard(
                number: i + 1,
                question: q,
                chosen: null,
                correct: q.key.toList(),
                showChosen: false,
              ),
            if (tests.length > shown)
              Text(
                l.toifaMoreMistakes(tests.length - shown),
                style: text.bodySmall,
              ),
          ],
          LgSectionTitle(l.toifaMistakesOralUnknown(unknown.length)),
          if (unknown.isEmpty)
            Text(l.toifaNothingHere, style: text.bodyMedium)
          else
            for (final (i, id) in unknown.indexed)
              oralRow(id, i, unknown.length),
          if (partial.isNotEmpty) ...[
            LgSectionTitle(l.toifaMistakesOralPartial(partial.length)),
            for (final (i, id) in partial.indexed)
              oralRow(id, i, partial.length),
          ],
        ];
      },
    );
  }
}

// ---------------------------------------------------------------- Rivojlanish

class ToifaProgressScreen extends StatelessWidget {
  const ToifaProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ToifaPage(
      title: l.toifaProgressTitle,
      subtitle: l.toifaProgressSubtitle,
      builder: (context, bank) => _body(context, l, bank),
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l, ToifaBank bank) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final toifa = context.services.toifa;
    final exams = context.services.exams;
    final cat = toifa.category;
    final oral = cat == null
        ? [
            for (final q in bank.oral)
              if (q.held == null) q,
          ]
        : bank.ticketPool(cat);
    final (tm, tt) = _testMastery(context, bank.scorable);
    final (ok, ot) = _oralMastery(toifa, oral);
    final testPct = _pct(tm, tt);
    final oralPct = _pct(ok, ot);
    final ready = ((testPct + oralPct) / 2).round();
    final recent = [
      for (final s in exams.history)
        if (s.sourceId == ToifaQuestionSource.sourceId &&
            s.mode == ExamMode.exam)
          s,
    ].take(5).toList();
    final rows =
        [
          for (final t in bank.topicOrder)
            (
              t,
              _testMastery(context, bank.scorable.where((q) => q.topic == t)),
              _oralMastery(toifa, oral.where((q) => q.topic == t)),
            ),
        ].where((r) => r.$2.$2 + r.$3.$2 > 0).toList()..sort((a, b) {
          double score(((int, int), (int, int)) x) {
            final total = x.$1.$2 + x.$2.$2;
            return total == 0 ? 0 : (x.$1.$1 + x.$2.$1) / total;
          }

          return score((a.$2, a.$3)).compareTo(score((b.$2, b.$3)));
        });
    return [
      ScoreHero(
        correct: ready,
        total: 100,
        title: l.toifaReadyTitle,
        ringLabel: '',
        caption: l.toifaReadyCaption,
      ),
      Row(
        children: [
          Expanded(
            child: _BigStat(
              value: '$testPct%',
              label: l.toifaReadyTestDetail(tm, tt),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BigStat(
              value: '$oralPct%',
              label: l.toifaReadyOralDetail(ok, ot),
            ),
          ),
        ],
      ),
      if (cat == null) ...[
        const SizedBox(height: 8),
        Text(l.toifaProgressPickCategory, style: text.bodySmall),
        const SizedBox(height: 6),
        const ToifaCategoryPicker(),
      ],
      LgSectionTitle(l.toifaRecentTests),
      if (recent.isEmpty)
        Text(l.examHistoryEmpty, style: text.bodyMedium)
      else
        for (final (i, s) in recent.indexed)
          LgRow(
            title: '${s.correctCount}/${s.length} · ${s.percent}%',
            // Chegara holati izohda — tor ekranda sarlavhani siqmaydi.
            subtitle: [
              formatWhenShort(s.finishedAt ?? s.startedAt, context),
              if (s.passed case final passed?)
                passed ? l.toifaPassedShort : l.toifaNotPassedShort,
            ].join(' · '),
            icon: s.passed == false
                ? Icons.flag_outlined
                : Icons.timer_outlined,
            onTap: () => context.push('$toifaBase/test/result/${s.id}'),
            divider: i < recent.length - 1,
          ),
      LgSectionTitle(l.examByTopic),
      Text(l.toifaByTopicNote, style: text.bodySmall),
      const SizedBox(height: 6),
      LgPanel(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Column(
          children: [
            for (final (t, (m, n), (k, o)) in rows)
              Semantics(
                container: true,
                label:
                    '${l.toifaTopic(t)}: ${l.toifaReadyTest} '
                    '${_pct(m, n)}%, ${l.toifaReadyOral} ${_pct(k, o)}%',
                child: ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.toifaTopic(t), style: text.titleSmall),
                        const SizedBox(height: 6),
                        if (n > 0)
                          _Bar(
                            label: l.toifaBarTest(m, n),
                            value: m / n,
                            color: _pct(m, n) >= 50 ? p.brand : p.amber,
                          ),
                        if (o > 0)
                          _Bar(
                            label: l.toifaBarOral(k, o),
                            value: k / o,
                            color: _pct(k, o) >= 50 ? p.brand : p.amber,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }
}

/// Qisqa sana-vaqt (tarix qatorlari uchun).
String formatWhenShort(DateTime t, BuildContext context) {
  final local = t.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.day)}.${two(local.month)}.${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: text.headlineSmall!.copyWith(
              color: p.brand,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              color: color,
              backgroundColor: p.line,
            ),
          ),
        ],
      ),
    );
  }
}
