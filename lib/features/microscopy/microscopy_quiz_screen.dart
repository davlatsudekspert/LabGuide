import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'microscopy_atlas.dart';
import 'microscopy_controller.dart';
import 'microscopy_quiz.dart';
import 'microscopy_widgets.dart';

/// “Bu nima?” mashqi: bo'lim tanlash → rasm + 4 variant (darhol javob) →
/// natija va xatolar. Raund natijasi qurilmada saqlanadi (eng yaxshisi).
class MicroQuizScreen extends StatefulWidget {
  const MicroQuizScreen({super.key, this.sectionId, this.random});

  /// Oldindan tanlangan bo'lim (bo'lim sahifasidan kelganda).
  final String? sectionId;

  /// Testlar uchun (savollar tartibi takrorlanadigan bo'lsin).
  final math.Random? random;

  @override
  State<MicroQuizScreen> createState() => _MicroQuizScreenState();
}

class _MicroQuizScreenState extends State<MicroQuizScreen> {
  late final math.Random _random = widget.random ?? math.Random();
  late String? _scope = widget.sectionId;
  MicroQuizSession? _session;

  /// Xatolarni qayta ishlash raundi rekord sifatida yozilmaydi.
  bool _mistakesRound = false;
  bool _newRecord = false;

  final _feedbackKey = GlobalKey();

  void _start(MicroAtlas atlas, {Iterable<String>? only}) {
    setState(() {
      _session = MicroQuizSession.build(
        atlas,
        sectionId: only == null ? _scope : null,
        only: only,
        random: _random,
      );
      _mistakesRound = only != null;
      _newRecord = false;
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final position = Scrollable.maybeOf(
        _feedbackKey.currentContext ?? context,
      )?.position;
      position?.jumpTo(0);
    });
  }

  void _answer(int option) {
    final s = _session!;
    if (!s.answer(option)) return;
    HapticFeedback.selectionClick();
    setState(() {});
    // Javob va “Keyingi” tugmasi ko'rinsin.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _feedbackKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 1,
        duration: LgMotion.of(ctx, LgMotion.page),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _next() async {
    final s = _session!;
    s.next();
    if (s.finished && !_mistakesRound) {
      final record = await context.services.microscopy.recordResult(
        _scope ?? MicroscopyController.allScope,
        s.correctCount,
        s.questions.length,
      );
      if (!mounted) return;
      _newRecord = record;
    }
    setState(() {});
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MicroAtlasGate(
      fallbackTitle: l.micQuizTitle,
      builder: (context, atlas) {
        final s = _session;
        return LgPage(
          title: l.micQuizTitle,
          subtitle: s == null ? l.micQuizSubtitle : null,
          children: [
            if (s == null)
              _QuizSetup(
                atlas: atlas,
                scope: _scope,
                onScope: (v) => setState(() => _scope = v),
                onStart: () => _start(atlas),
              )
            else if (s.finished)
              _QuizResult(
                session: s,
                newRecord: _newRecord,
                mistakesRound: _mistakesRound,
                onRetryMistakes: () => _start(
                  atlas,
                  only: [for (final (q, _) in s.mistakes) q.image.id],
                ),
                onNewRound: () => _start(atlas),
                onChangeScope: () => setState(() => _session = null),
              )
            else
              _QuestionView(
                atlas: atlas,
                session: s,
                feedbackKey: _feedbackKey,
                onAnswer: _answer,
                onNext: _next,
              ),
          ],
        );
      },
    );
  }
}

class _QuizSetup extends StatelessWidget {
  const _QuizSetup({
    required this.atlas,
    required this.scope,
    required this.onScope,
    required this.onStart,
  });

  final MicroAtlas atlas;
  final String? scope;
  final ValueChanged<String?> onScope;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final c = context.services.microscopy;
    final available = atlas.quizImages(sectionId: scope).length;
    final count = math.min(available, MicroQuizSession.defaultLength);
    final mosaic = [
      for (final id in const ['b-baso-1', 'u-cryst-uric-1', 'p-mal-thick-1'])
        ?atlas.image(id),
    ];
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final best = c.best(scope ?? MicroscopyController.allScope);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgPanel(
              soft: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MicroMosaic(images: mosaic, size: 64),
                  const SizedBox(height: 14),
                  Text(l.micQuizHeroBody, style: text.bodyLarge),
                ],
              ),
            ),
            LgSectionTitle(l.micQuizScope),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LgChoiceChip(
                  label: l.micQuizScopeChip(
                    l.micAllGroups,
                    atlas.quizImages().length,
                  ),
                  selected: scope == null,
                  onTap: () => onScope(null),
                ),
                for (final s in atlas.sections)
                  if (atlas.quizImages(sectionId: s.id).isNotEmpty)
                    LgChoiceChip(
                      label: l.micQuizScopeChip(
                        s.name.of(lang),
                        atlas.quizImages(sectionId: s.id).length,
                      ),
                      selected: scope == s.id,
                      onTap: () => onScope(s.id),
                    ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  best == null
                      ? Icons.flag_outlined
                      : Icons.emoji_events_outlined,
                  color: p.brand,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    best == null
                        ? l.micQuizNoBest
                        : l.micQuizBest(best.correct, best.total),
                    style: text.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LgButton(
              label: l.micQuizStart(count),
              icon: Icons.play_arrow_rounded,
              onPressed: count > 0 ? onStart : null,
            ),
            const SizedBox(height: 8),
            LgNotice(l.micQuizRules, kind: NoticeKind.info),
          ],
        );
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.atlas,
    required this.session,
    required this.feedbackKey,
    required this.onAnswer,
    required this.onNext,
  });

  final MicroAtlas atlas;
  final MicroQuizSession session;
  final GlobalKey feedbackKey;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final q = session.current;
    final total = session.questions.length;
    final chosen = session.answerFor(session.index);
    final answered = chosen != null;
    final done = session.index + (answered ? 1 : 0);
    final prompt = switch (q.image.quizCue!) {
      MicroQuizCue.arrowhead => l.micQuizPromptArrow,
      MicroQuizCue.centre => l.micQuizPromptCentre,
      MicroQuizCue.field => l.micQuizPromptField,
    };
    final correctName = q.answer.name.of(lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              l.micQuizProgress(session.index + 1, total),
              style: text.titleSmall,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                excludeSemantics: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: done / total,
                    minHeight: 8,
                    color: p.brand,
                    backgroundColor: p.soft,
                  ),
                ),
              ),
            ),
            if (session.streak >= 2) ...[
              const SizedBox(width: 10),
              LgTag(
                l.micQuizStreak(session.streak),
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Rasm to'liq ko'rinadi (strelka kesilmasin): contain, qora fon.
        LgPressable(
          onTap: () => openMicroViewer(
            context,
            q.image,
            answered ? correctName : l.micQuizTitle,
          ),
          borderRadius: BorderRadius.circular(LgRadius.card),
          semanticLabel: l.micQuizTapToZoom,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(LgRadius.card),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: ColoredBox(
                    color: Colors.black,
                    child: Image(
                      image: microThumb(q.image, width: MicroThumb.large),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: 10,
                bottom: 10,
                child: MicroGlassPill('', icon: Icons.zoom_out_map_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Semantics(header: true, child: Text(prompt, style: text.titleMedium)),
        const SizedBox(height: 10),
        for (final (i, option) in q.options.indexed) ...[
          _OptionTile(
            letter: String.fromCharCode(65 + i),
            label: option.name.of(lang),
            state: !answered
                ? _OptionState.idle
                : i == q.correctIndex
                ? _OptionState.correct
                : i == chosen
                ? _OptionState.wrong
                : _OptionState.disabled,
            onTap: answered ? null : () => onAnswer(i),
          ),
          const SizedBox(height: 8),
        ],
        KeyedSubtree(
          key: feedbackKey,
          child: answered
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    _Feedback(
                      correct: chosen == q.correctIndex,
                      correctName: correctName,
                      onOpenCard: () =>
                          context.push(microImageRoute(q.image.id)),
                    ),
                    const SizedBox(height: 12),
                    LgButton(
                      label: session.isLast ? l.quizFinish : l.quizNext,
                      icon: session.isLast
                          ? Icons.flag_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: onNext,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, disabled }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final (
      Color bg,
      Color border,
      Color badge,
      Color badgeFg,
      IconData? icon,
    ) = switch (state) {
      _OptionState.idle => (p.paper, p.outline, p.soft, p.brand, null),
      _OptionState.correct => (
        p.soft,
        p.brand,
        p.brand,
        p.onBrand,
        Icons.check_circle_rounded,
      ),
      _OptionState.wrong => (
        p.amberBg,
        p.danger,
        p.danger,
        p.paper,
        Icons.cancel_rounded,
      ),
      _OptionState.disabled => (p.paper, p.line, p.bg, p.sub, null),
    };
    final suffix = switch (state) {
      _OptionState.correct => l.quizCorrectAnswer,
      _OptionState.wrong => l.quizYourAnswer,
      _ => null,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LgRadius.button),
        border: Border.all(
          color: border,
          width: state == _OptionState.idle ? 1 : 2,
        ),
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
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badge,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      letter,
                      style: text.labelLarge!.copyWith(
                        color: badgeFg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: text.bodyLarge!.copyWith(
                            color: state == _OptionState.disabled
                                ? p.sub
                                : p.ink,
                          ),
                        ),
                        if (suffix != null)
                          Text(
                            suffix,
                            style: text.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: state == _OptionState.wrong
                                  ? p.danger
                                  : p.brand,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: state == _OptionState.wrong ? p.danger : p.brand,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.correct,
    required this.correctName,
    required this.onOpenCard,
  });

  final bool correct;
  final String correctName;
  final VoidCallback onOpenCard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final fg = correct ? p.brand : p.danger;
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: correct ? p.soft : p.amberBg,
          borderRadius: BorderRadius.circular(LgRadius.button),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    correct
                        ? Icons.celebration_rounded
                        : Icons.lightbulb_outline_rounded,
                    color: fg,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      correct ? l.micQuizCorrect : l.micQuizWrong(correctName),
                      style: text.titleMedium!.copyWith(color: fg),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: onOpenCard,
                  icon: Icon(Icons.photo_outlined, size: 18, color: p.ink),
                  label: Text(
                    l.micQuizOpenCard,
                    style: text.labelLarge!.copyWith(
                      color: p.ink,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizResult extends StatelessWidget {
  const _QuizResult({
    required this.session,
    required this.newRecord,
    required this.mistakesRound,
    required this.onRetryMistakes,
    required this.onNewRound,
    required this.onChangeScope,
  });

  final MicroQuizSession session;
  final bool newRecord;
  final bool mistakesRound;
  final VoidCallback onRetryMistakes;
  final VoidCallback onNewRound;
  final VoidCallback onChangeScope;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final total = session.questions.length;
    final correct = session.correctCount;
    final ratio = correct / total;
    final mistakes = session.mistakes;
    final title = ratio >= 0.9
        ? l.micQuizResultGreat
        : ratio >= 0.6
        ? l.micQuizResultGood
        : l.micQuizResultKeep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Semantics(
            label: l.micQuizScore(correct, total),
            excludeSemantics: true,
            child: SizedBox.square(
              dimension: 156,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: ratio,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    color: p.brand,
                    backgroundColor: p.soft,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(ratio * 100).round()}%',
                          style: text.headlineMedium,
                        ),
                        Text('$correct / $total', style: text.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.micQuizScore(correct, total),
          textAlign: TextAlign.center,
          style: text.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (newRecord)
              LgTag(l.micQuizNewRecord, icon: Icons.emoji_events_rounded),
            LgTag(
              l.micQuizBestStreak(session.bestStreak),
              tone: LgTone.neutral,
              icon: Icons.local_fire_department_rounded,
            ),
          ],
        ),
        LgSectionTitle(l.quizMistakes),
        if (mistakes.isEmpty)
          Text(l.quizNoMistakes, style: text.bodyMedium)
        else
          for (final (q, chosen) in mistakes)
            _MistakeRow(
              question: q,
              chosen: chosen.name.of(lang),
              correct: q.answer.name.of(lang),
            ),
        const SizedBox(height: 18),
        if (mistakes.isNotEmpty) ...[
          LgButton(
            label: l.micQuizRetryMistakes(mistakes.length),
            icon: Icons.replay_rounded,
            onPressed: onRetryMistakes,
          ),
          const SizedBox(height: 10),
        ],
        if (mistakes.isEmpty)
          LgButton(
            label: l.micQuizNewRound,
            icon: Icons.refresh_rounded,
            onPressed: onNewRound,
          )
        else
          LgButton.secondary(
            label: l.micQuizNewRound,
            icon: Icons.refresh_rounded,
            onPressed: onNewRound,
          ),
        const SizedBox(height: 6),
        LgButton.link(label: l.micQuizChangeScope, onPressed: onChangeScope),
        LgButton.link(
          label: l.micQuizBackToAtlas,
          onPressed: () => context.go(microBase),
        ),
      ],
    );
  }
}

class _MistakeRow extends StatelessWidget {
  const _MistakeRow({
    required this.question,
    required this.chosen,
    required this.correct,
  });

  final MicroQuestion question;
  final String chosen;
  final String correct;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: LgPressable(
        onTap: () => context.push(microImageRoute(question.image.id)),
        color: p.paper,
        borderRadius: BorderRadius.circular(LgRadius.button),
        semanticLabel:
            '${l.quizYourAnswer}: $chosen. ${l.quizCorrectAnswer}: $correct',
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: MicroPicture(
                    image: question.image,
                    aspectRatio: 1,
                    cacheWidth: MicroThumb.small,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '${l.quizYourAnswer}: ',
                          children: [
                            TextSpan(
                              text: chosen,
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationColor: p.danger,
                              ),
                            ),
                          ],
                        ),
                        style: text.bodySmall!.copyWith(color: p.danger),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l.quizCorrectAnswer}: $correct',
                        style: text.titleSmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.sub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
