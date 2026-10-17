import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/ui/content_widgets.dart';
import '../learn/classes_screens.dart' show ClassesGate, classesErrorText;
import '../learn/exam_controller.dart';
import '../learn/exam_question.dart';
import '../learn/exam_session.dart';
import '../learn/exam_widgets.dart';
import '../learn/learn_screens.dart' show QuizOptionButton, QuizOptionState;
import '../settings/settings_controller.dart';
import '../support/support_screens.dart' show formatWhen;
import 'classroom_screens.dart' show CurriculumGate;
import 'lecture_catalog.dart';
import 'lecture_library.dart' show openDeck;
import 'topic_questions.dart';
import 'topic_test.dart';

// Mavzu testi ekranlari: talaba (va har kim) uchun — bitta savol bitta
// ekranda, katta variant kartalari, darhol izoh, saqlanadigan qoralama,
// natija va xatolar tahlili (“Slaydni ko'rish” bilan); ustoz uchun —
// “Guruhga topshirish” (mavjud topshiriq mexanizmi orqali). Ko'rinish —
// mashq/imtihon ekranlaridagi bilan bir xil (LgPage, LgPanel, ScoreHero,
// ExamReviewCard, QuizOptionButton).

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

AssetBundle _bundle(BuildContext context) =>
    context.services.curriculum.bundle ?? rootBundle;

String topicTestLocation(String deckId) => '/learn/lecture/test/$deckId';

void openTopicTest(BuildContext context, String deckId) =>
    unawaited(context.push(topicTestLocation(deckId)));

void openAssignDeckTest(BuildContext context, String deckId) =>
    unawaited(context.push('${topicTestLocation(deckId)}/assign'));

/// “Guruhga topshirish” — ustoz rolida (server huquqni baribir tekshiradi).
bool canAssignTests(BuildContext context) =>
    context.services.settings.role == AppRole.teacher;

/// Joriy hovuzlar (manbalar yuklanmagan bo'lsa — to'liq emas).
DeckPools deckPools(BuildContext context) {
  final s = context.services;
  return DeckPools.of(s.curriculum.curriculum, s.content.pack, s.toifa.bank);
}

/// Savol id → savol (paket + toifa banki).
ExamQuestion? topicQuestion(BuildContext context, String id) {
  final s = context.services;
  final pack = s.content.pack;
  if (pack == null) return null;
  final bank = s.toifa.bank;
  return bank == null
      ? PackQuestionSource.of(pack).question(id)
      : ClassQuestionSource.of(pack, bank).question(id);
}

/// Savolga eng mos slayd (ishonchli moslik bo'lmasa — null: deck boshi).
int? slideFor(BuildContext context, ExamQuestion q, DeckEntry deck) =>
    matchSlide(
      q,
      deck,
      _lang(context),
      analyteNames: packAnalyteNames(context.services.content.pack),
    );

/// Topshiriq (mavzu testi) qaysi deck bo'yicha: deck id yoki mavzu id si.
DeckEntry? deckOfAssignment(BuildContext context, GroupAssignment a) {
  final c = DeckCatalog.peek(_bundle(context));
  if (c == null) return null;
  return (a.deckId == null ? null : c.byId(a.deckId!)) ??
      (a.topicId == null ? null : c.byTopic(a.topicId!));
}

/// “Slaydni ko'rish” havolasi (moslik bo'lmasa — “Taqdimotni boshidan”).
class SlideLink extends StatelessWidget {
  const SlideLink({super.key, required this.question, required this.deck});

  final ExamQuestion question;
  final DeckEntry deck;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slide = slideFor(context, question, deck);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 10),
      child: LgButton.link(
        key: ValueKey('slide-link-${question.id}'),
        label: slide == null ? l.topicTestOpenDeckStart : l.topicTestOpenSlide,
        icon: Icons.slideshow_outlined,
        onPressed: () => openDeck(context, deck.id, slide: slide ?? 0),
      ),
    );
  }
}

/// Deck uchun test holati (manbalar yuklanishini tinglaydi). Toifa banki
/// kerak bo'lsa yuklanadi.
class DeckTestBuilder extends StatefulWidget {
  const DeckTestBuilder({super.key, required this.deck, required this.builder});

  final DeckEntry deck;
  final Widget Function(
    BuildContext context,
    DeckTestState state,
    List<ExamQuestion> pool,
  )
  builder;

  @override
  State<DeckTestBuilder> createState() => _DeckTestBuilderState();
}

class _DeckTestBuilderState extends State<DeckTestBuilder> {
  @override
  void initState() {
    super.initState();
    if (widget.deck.topics.isNotEmpty) {
      final s = context.services;
      unawaited(s.toifa.ensureLoaded());
      unawaited(s.curriculum.ensureLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.services;
    if (widget.deck.topics.isEmpty) {
      return widget.builder(context, DeckTestState.hidden, const []);
    }
    return ListenableBuilder(
      listenable: Listenable.merge([s.toifa, s.content, s.curriculum]),
      builder: (context, _) {
        final pools = deckPools(context);
        // Manbalar yuklanguncha holat noma'lum — tugma ko'rsatilmaydi.
        if (!pools.complete) {
          return widget.builder(context, DeckTestState.hidden, const []);
        }
        return widget.builder(
          context,
          pools.state(widget.deck),
          pools.pool(widget.deck),
        );
      },
    );
  }
}

/// Ma'ruza ro'yxatidagi deck qatori ostida: “Mavzu testi” tugmasi va eng
/// yaxshi natija belgisi (masalan, 8/10).
class DeckTestBadge extends StatelessWidget {
  const DeckTestBadge({super.key, required this.deck});

  final DeckEntry deck;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final tests = context.services.topicTests;
    return ListenableBuilder(
      listenable: tests,
      builder: (context, _) {
        final best = tests.best(deck.id);
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: LgPressable(
            key: ValueKey('deck-test-${deck.id}'),
            onTap: () => openTopicTest(context, deck.id),
            borderRadius: BorderRadius.circular(LgRadius.button),
            border: Border.all(color: p.brand.withValues(alpha: 0.35)),
            semanticLabel: best == null
                ? l.topicTestAction
                : l.topicTestBadgeLabel(best.correct, best.total),
            child: ExcludeSemantics(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTap),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.quiz_outlined, size: 18, color: p.brand),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l.topicTestAction,
                          style: text.labelLarge!.copyWith(color: p.brand),
                        ),
                      ),
                      if (best != null) ...[
                        const SizedBox(width: 8),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: p.soft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              '${best.correct}/${best.total}',
                              key: ValueKey('deck-test-score-${deck.id}'),
                              style: text.labelMedium!.copyWith(
                                color: p.brand,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Ro'yxatda deckni uzoq bosish — amallar: ochish, mavzu testi, guruhga
/// topshirish (ustoz).
Future<void> showDeckActions(BuildContext context, DeckEntry deck) async {
  final l = AppLocalizations.of(context);
  final pools = deckPools(context);
  final ready = pools.complete && pools.state(deck) == DeckTestState.ready;
  final teacher = canAssignTests(context);
  final lang = _lang(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              deck.title(lang),
              style: Theme.of(sheet).textTheme.titleSmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.co_present_outlined),
            title: Text(l.topicTestOpenLecture),
            onTap: () {
              Navigator.pop(sheet);
              openDeck(context, deck.id);
            },
          ),
          if (ready)
            ListTile(
              key: const ValueKey('deck-action-test'),
              leading: const Icon(Icons.quiz_outlined),
              title: Text(l.topicTestAction),
              onTap: () {
                Navigator.pop(sheet);
                openTopicTest(context, deck.id);
              },
            ),
          if (ready && teacher)
            ListTile(
              key: const ValueKey('deck-action-assign'),
              leading: const Icon(Icons.group_add_outlined),
              title: Text(l.topicTestAssign),
              onTap: () {
                Navigator.pop(sheet);
                openAssignDeckTest(context, deck.id);
              },
            ),
          if (pools.complete && pools.state(deck) == DeckTestState.preparing)
            ListTile(
              leading: const Icon(Icons.hourglass_empty_rounded),
              title: Text(l.topicTestPreparing),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Deck katalogi yuklanguncha holat.
class _DeckGate extends StatelessWidget {
  const _DeckGate({required this.deckId, required this.builder});

  final String deckId;
  final Widget Function(BuildContext context, DeckEntry deck, DeckCatalog c)
  builder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bundle = _bundle(context);
    return FutureBuilder<DeckCatalog>(
      future: DeckCatalog.load(bundle),
      initialData: DeckCatalog.peek(bundle),
      builder: (context, snap) {
        final c = snap.data;
        if (c == null) {
          return snap.hasError
              ? LgStateView(
                  kind: StateKind.error,
                  title: l.lectureDeckLoadFailed,
                )
              : const LgStateView(kind: StateKind.loading, title: '');
        }
        final d = c.byId(deckId);
        if (d == null) {
          return LgStateView(
            kind: StateKind.error,
            title: l.lectureDeckLoadFailed,
          );
        }
        return builder(context, d, c);
      },
    );
  }
}

/// Barcha manbalar (deck katalogi, o'quv dasturi, paket, toifa banki).
Widget _sources(
  String deckId,
  Widget Function(
    BuildContext context,
    DeckEntry deck,
    DeckCatalog catalog,
    List<ExamQuestion> pool,
  )
  builder,
) => _DeckGate(
  deckId: deckId,
  builder: (context, deck, catalog) => CurriculumGate(
    builder: (context, cur) => ContentGate(
      builder: (context, pack) => ToifaBankGate(
        builder: (context, bank) => builder(
          context,
          deck,
          catalog,
          DeckPools.of(cur, pack, bank).pool(deck),
        ),
      ),
    ),
  ),
);

/// Keyingi mavzu: katalog tartibida shu turdagi keyingi deck.
DeckEntry? nextDeck(DeckCatalog c, DeckEntry d) {
  final i = c.decks.indexWhere((e) => e.id == d.id);
  for (var k = i + 1; k < c.decks.length && i >= 0; k++) {
    if (c.decks[k].kind == d.kind) return c.decks[k];
  }
  return null;
}

// =============================================================================
// Talaba: test
// =============================================================================

class TopicTestScreen extends StatefulWidget {
  const TopicTestScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<TopicTestScreen> createState() => _TopicTestScreenState();
}

class _TopicTestScreenState extends State<TopicTestScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tests = context.services.topicTests;
    final catalog = DeckCatalog.peek(_bundle(context));
    final title = catalog?.byId(widget.deckId)?.title(_lang(context));
    return ListenableBuilder(
      listenable: tests,
      builder: (context, _) {
        final draft = tests.draft(widget.deckId);
        return LgPage(
          // Savol almashganda sahifa tepadan boshlanadi.
          key: ValueKey((
            draft?.id,
            draft?.index,
            tests.last(widget.deckId)?.id,
          )),
          title: l.topicTestAction,
          subtitle: title,
          showProfile: false,
          children: [
            _sources(
              widget.deckId,
              (context, deck, catalog, pool) =>
                  _body(context, deck, catalog, pool),
            ),
          ],
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    DeckEntry deck,
    DeckCatalog catalog,
    List<ExamQuestion> pool,
  ) {
    final l = AppLocalizations.of(context);
    final tests = context.services.topicTests;
    final draft = tests.draft(deck.id);
    // Boshlangan test hech qachon to'xtatilmaydi (hovuz o'zgargan bo'lsa ham).
    if (draft != null) {
      return _QuestionView(
        key: ValueKey(draft.id),
        deck: deck,
        session: draft,
        onFinish: () => tests.finish(deck.id),
      );
    }
    if (deck.topics.isEmpty || pool.length < kTopicTestMin) {
      return LgStateView(
        key: const ValueKey('topic-test-preparing'),
        kind: StateKind.empty,
        title: l.topicTestPreparing,
        message: l.topicTestPreparingBody(pool.length),
        actionLabel: l.topicTestOpenLecture,
        onAction: () => openDeck(context, deck.id),
      );
    }
    final last = tests.last(deck.id);
    if (last != null) {
      return _ResultView(
        deck: deck,
        catalog: catalog,
        pool: pool,
        session: last,
        busy: _busy,
        onRetake: () => _start(deck, pool),
        onRework: (ids) => _start(deck, pool, rework: ids),
      );
    }
    return _intro(context, deck, pool);
  }

  Future<void> _start(
    DeckEntry deck,
    List<ExamQuestion> pool, {
    List<String>? rework,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    final tests = context.services.topicTests;
    final seed = tests.nextSeed();
    final byId = {for (final q in pool) q.id: q};
    final questions = rework == null
        ? drawTopicTest(pool, seed: seed)
        : drawTopicTest([for (final id in rework) ?byId[id]], seed: seed);
    await tests.start(
      deck.id,
      buildTopicTestSession(
        id: tests.newId(),
        questions: questions,
        seed: seed,
        startedAt: tests.now(),
        title: rework == null ? deck.title(_lang(context)) : l.examReworkTitle,
        mode: rework == null ? ExamMode.exam : ExamMode.rework,
      ),
    );
    if (mounted) setState(() => _busy = false);
  }

  Widget _intro(BuildContext context, DeckEntry deck, List<ExamQuestion> pool) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final n = pool.length < kTopicTestSize ? pool.length : kTopicTestSize;
    final best = context.services.topicTests.best(deck.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgPanel(
          soft: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgEyebrow(l.topicTestAction),
              Text(deck.title(_lang(context)), style: text.titleMedium),
              const SizedBox(height: 8),
              Text(
                l.topicTestIntro(n),
                key: const ValueKey('topic-test-intro'),
                style: text.bodyMedium,
              ),
              if (best != null) ...[
                const SizedBox(height: 6),
                Text(
                  l.topicTestBest(best.correct, best.total),
                  style: text.bodyMedium,
                ),
              ],
              const SizedBox(height: 14),
              LgButton(
                key: const ValueKey('topic-test-start'),
                label: l.topicTestStart,
                icon: Icons.play_arrow_rounded,
                busy: _busy,
                onPressed: () => _start(deck, pool),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(l.topicTestSavedNote, style: text.bodySmall),
        const SizedBox(height: 6),
        Text(l.topicTestSourcesNote, style: text.bodySmall),
        if (canAssignTests(context)) ...[
          const SizedBox(height: 16),
          LgButton.secondary(
            key: const ValueKey('topic-test-assign'),
            label: l.topicTestAssign,
            icon: Icons.group_add_outlined,
            onPressed: () => openAssignDeckTest(context, deck.id),
          ),
        ],
      ],
    );
  }
}

/// Bitta savol: variant bosilishi bilan javob qulflanadi, to'g'ri javob va
/// izoh ko'rsatiladi; “Keyingi” — keyingi savol (yakunida natija).
class _QuestionView extends StatefulWidget {
  const _QuestionView({
    super.key,
    required this.deck,
    required this.session,
    required this.onFinish,
  });

  final DeckEntry deck;
  final ExamSession session;
  final Future<void> Function() onFinish;

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  bool _finishing = false;

  ExamSession get s => widget.session;

  Future<void> _choose(int display, ExamQuestion q) async {
    final i = s.index;
    if (s.isAnswered(i) || s.finished) return;
    s.choose(display);
    setState(() {});
    final services = context.services;
    await services.topicTests.save(widget.deck.id, s);
    // “Xatolar ustida ishlash” — mavjud mashq tarixi orqali.
    await services.quizProgress.record(q.id, correct: s.isCorrect(i));
  }

  Future<void> _next() async {
    if (_finishing) return;
    if (s.isLast) {
      setState(() => _finishing = true);
      await widget.onFinish();
      return;
    }
    s.next();
    setState(() {});
    await context.services.topicTests.save(widget.deck.id, s);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = _lang(context);
    final i = s.index;
    final item = s.items[i];
    final q = topicQuestion(context, item.questionId);
    final total = s.length;
    final answer = s.answerAt(i)?.firstOrNull;
    final answered = answer != null;
    final right = item.correct.isEmpty ? -1 : item.correct.first;
    final official = q is OfficialKeyQuestion;
    String label(int orig) {
      final t = q!.option(orig, lang);
      return official ? '${optionLetter(orig)}) $t' : t;
    }

    return Column(
      key: const ValueKey('topic-test-question'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            LgEyebrow(l.quizProgress(i + 1, total)),
            if (s.mode == ExamMode.rework)
              LgTag(l.examReworkTitle, tone: LgTone.neutral),
            if (q?.isDraft ?? false)
              LgTag(l.quizDraftTag, tone: LgTone.warning),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (i + (answered ? 1 : 0)) / total,
              minHeight: 6,
              semanticsLabel: l.quizProgress(i + 1, total),
            ),
          ),
        ),
        if (q == null) ...[
          Text(l.examQuestionMissing, style: text.bodyLarge),
          const SizedBox(height: 14),
        ] else ...[
          Semantics(
            header: true,
            child: Text(q.prompt(lang), style: text.headlineSmall),
          ),
          if (q case final OfficialKeyQuestion o)
            OfficialTextToggle(question: o),
          const SizedBox(height: 14),
          for (var k = 0; k < item.order.length; k++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: QuizOptionButton(
                key: ValueKey('topic-option-$k'),
                label: label(item.order[k]),
                state: !answered
                    ? QuizOptionState.idle
                    : item.order[k] == right
                    ? QuizOptionState.correct
                    : item.order[k] == answer
                    ? QuizOptionState.wrong
                    : QuizOptionState.disabled,
                onTap: answered ? null : () => _choose(k, q),
              ),
            ),
          if (answered) ...[
            LgNotice(
              _feedback(l, q, answer, right, lang),
              title: answer == right ? l.quizCorrect : l.quizIncorrect,
              kind: answer == right ? NoticeKind.info : NoticeKind.warning,
            ),
            if (q.basis(lang) case final b? when b.isNotEmpty)
              Text(
                l.quizBasis(b),
                style: text.bodySmall!.copyWith(color: p.sub),
              ),
            if (q is OfficialKeyQuestion)
              const OfficialListSource()
            else
              ExamSources(question: q),
          ],
        ],
        if (answered || q == null) ...[
          const SizedBox(height: 14),
          LgButton(
            key: const ValueKey('topic-test-next'),
            label: s.isLast ? l.quizFinish : l.quizNext,
            busy: _finishing,
            onPressed: _next,
          ),
        ],
        const SizedBox(height: 14),
        Text(l.topicTestSavedNote, style: text.bodySmall),
      ],
    );
  }

  /// Izoh: tanlangan va to'g'ri variant izohi (paket); toifa savolida —
  /// to'g'ri javob (rasmiy ro'yxatda izoh yo'q).
  String _feedback(
    AppLocalizations l,
    ExamQuestion q,
    int answer,
    int right,
    String lang,
  ) {
    final parts = <String>[
      if (q.explanation(answer, lang) case final e? when e.isNotEmpty) e,
      if (answer != right)
        if (q.explanation(right, lang) case final e? when e.isNotEmpty) e,
    ];
    if (answer != right || parts.isEmpty) {
      final t = q.option(right, lang);
      parts.add(
        '${l.quizCorrectAnswer}: '
        '${q is OfficialKeyQuestion ? '${optionLetter(right)}) $t' : t}',
      );
    }
    return parts.join('\n\n');
  }
}

/// Natija: ball, xatolarni takrorlash, qayta topshirish, keyingi mavzu va
/// har xato savol uchun “Slaydni ko'rish”.
class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.deck,
    required this.catalog,
    required this.pool,
    required this.session,
    required this.busy,
    required this.onRetake,
    required this.onRework,
  });

  final DeckEntry deck;
  final DeckCatalog catalog;
  final List<ExamQuestion> pool;
  final ExamSession session;
  final bool busy;
  final VoidCallback onRetake;
  final ValueChanged<List<String>> onRework;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final services = context.services;
    final s = session;
    final tests = services.topicTests;
    final best = tests.best(deck.id);
    // Mavjud mexanizm: oxirgi javobi xato bo'lgan savollar (mashq tarixi).
    final mistakes = services.quizProgress.mistakes([
      for (final q in pool) q.id,
    ]).toList();
    final next = nextDeck(catalog, deck);
    final history = tests.history(deck.id);
    return Column(
      key: const ValueKey('topic-test-result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreHero(
          correct: s.correctCount,
          total: s.length,
          wrong: s.wrongCount,
          unanswered: s.unansweredCount,
          caption: s.mode == ExamMode.rework
              ? '${l.examReworkTitle} · ${l.quizScore(s.correctCount, s.length)}'
              : null,
          badges: [
            if (best != null)
              LgTag(
                l.topicTestBest(best.correct, best.total),
                icon: Icons.emoji_events_outlined,
              ),
          ],
        ),
        if (mistakes.isNotEmpty) ...[
          LgButton(
            key: const ValueKey('topic-test-rework'),
            label: l.topicTestReworkMistakes(
              mistakes.length < kTopicTestSize
                  ? mistakes.length
                  : kTopicTestSize,
            ),
            icon: Icons.replay_rounded,
            busy: busy,
            onPressed: () => onRework(mistakes),
          ),
          const SizedBox(height: 10),
          LgButton.secondary(
            key: const ValueKey('topic-test-retake'),
            label: l.topicTestRetake,
            icon: Icons.restart_alt_rounded,
            onPressed: busy ? null : onRetake,
          ),
        ] else
          LgButton(
            key: const ValueKey('topic-test-retake'),
            label: l.topicTestRetake,
            icon: Icons.restart_alt_rounded,
            busy: busy,
            onPressed: onRetake,
          ),
        if (next != null) ...[
          const SizedBox(height: 10),
          LgButton.secondary(
            key: const ValueKey('topic-test-next-topic'),
            label: l.topicTestNextTopic,
            icon: Icons.arrow_forward_rounded,
            onPressed: () => openDeck(context, next.id),
          ),
        ],
        if (canAssignTests(context)) ...[
          const SizedBox(height: 10),
          LgButton.link(
            label: l.topicTestAssign,
            icon: Icons.group_add_outlined,
            onPressed: () => openAssignDeckTest(context, deck.id),
          ),
        ],
        LgSectionTitle(l.examAnalysis),
        if (s.mistakeIndexes.isEmpty)
          LgStateView(kind: StateKind.success, title: l.quizNoMistakes)
        else
          for (final i in s.mistakeIndexes)
            () {
              final q = topicQuestion(context, s.items[i].questionId);
              return Column(
                key: ValueKey('topic-review-$i'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExamReviewCard(
                    number: i + 1,
                    question: q,
                    chosen: s.answerAt(i),
                    correct: s.items[i].correct,
                  ),
                  if (q != null) SlideLink(question: q, deck: deck),
                ],
              );
            }(),
        if (history.length > 1) ...[
          LgSectionTitle(l.topicTestHistory),
          for (final (i, r) in history.take(5).indexed)
            LgRow(
              title: '${r.correct}/${r.total} · ${r.percent}%',
              subtitle: [
                formatWhen(r.at, context),
                if (r.rework) l.examReworkTitle,
              ].join(' · '),
              icon: r.rework ? Icons.replay_rounded : Icons.quiz_outlined,
              divider: i < history.take(5).length - 1,
            ),
        ],
        const SizedBox(height: 10),
        Text(l.topicTestSourcesNote, style: text.bodySmall),
      ],
    );
  }
}

// =============================================================================
// Ustoz: guruhga topshirish
// =============================================================================

enum _Due { none, d1, d3, d7, custom }

class _Sent {
  const _Sent(this.group, this.assignment, this.done, this.students);

  final StudyGroup group;
  final GroupAssignment assignment;
  final int done;
  final int students;
}

class AssignDeckTestScreen extends StatefulWidget {
  const AssignDeckTestScreen({super.key, required this.deckId});

  final String deckId;

  @override
  State<AssignDeckTestScreen> createState() => _AssignDeckTestScreenState();
}

class _AssignDeckTestScreenState extends State<AssignDeckTestScreen> {
  static const maxQuestions = 50;

  final _count = TextEditingController();
  final Set<String> _picked = {};
  _Due _due = _Due.d3;
  DateTime? _customDue;
  bool _afterDue = false;
  List<ExamQuestion>? _drawn;
  int? _drawnFor;
  List<StudyGroup>? _groups;
  List<_Sent> _sent = const [];
  Object? _error;
  bool _loading = false;
  bool _busy = false;
  bool _tried = false;
  bool _countInit = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  bool get _ready =>
      context.services.backend.isConfigured && context.services.auth.hasAccount;

  Future<void> _load() async {
    if (!mounted || !_ready || _loading) return;
    final backend = context.services.backend;
    _uid = backend.userId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = [
        for (final g in await backend.myGroups())
          if (g.isTeacher) g,
      ];
      final sent = <_Sent>[];
      for (final g in groups) {
        final r = await Future.wait([
          backend.assignments(g.id),
          backend.groupSubmissions(g.id),
          backend.groupMembers(g.id),
        ]);
        final students = {
          for (final m in r[2] as List<GroupMember>)
            if (!m.isTeacher) m.userId,
        };
        for (final a in r[0] as List<GroupAssignment>) {
          if (a.deckId != widget.deckId) continue;
          final done = {
            for (final s in r[1] as List<GroupSubmission>)
              if (s.assignmentId == a.id && students.contains(s.userId))
                s.userId,
          }.length;
          sent.add(_Sent(g, a, done, students.length));
        }
      }
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _sent = sent;
        // Bitta guruh bo'lsa — darhol tanlangan.
        if (groups.length == 1 && _picked.isEmpty) {
          _picked.add(groups.single.id);
        }
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime? get _dueAt {
    final now = context.services.exams.now();
    DateTime endOf(int days) =>
        DateTime(now.year, now.month, now.day + days, 23, 59);
    return switch (_due) {
      _Due.none => null,
      _Due.d1 => endOf(1),
      _Due.d3 => endOf(3),
      _Due.d7 => endOf(7),
      _Due.custom => _customDue,
    };
  }

  int _max(List<ExamQuestion> pool) =>
      pool.length < maxQuestions ? pool.length : maxQuestions;

  int? get _n => int.tryParse(_count.text.trim());

  bool _countOk(List<ExamQuestion> pool) {
    final n = _n;
    return n != null && n >= 1 && n <= _max(pool);
  }

  void _redraw(List<ExamQuestion> pool) {
    final n = _n;
    _drawnFor = n;
    _drawn = n == null || !_countOk(pool)
        ? null
        : drawTopicTest(
            pool,
            count: n,
            seed: context.services.topicTests.nextSeed(),
          );
  }

  Future<void> _pickDate() async {
    final now = context.services.exams.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _customDue ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _due = _Due.custom;
      _customDue = DateTime(date.year, date.month, date.day, 23, 59);
    });
  }

  String _title(DeckEntry deck) {
    final l = AppLocalizations.of(context);
    var t = l.topicTestTitle(deck.title(_lang(context)));
    if (t.length > 120) t = '${t.substring(0, 119).trimRight()}…';
    return t;
  }

  Future<void> _send(DeckEntry deck, List<ExamQuestion> pool) async {
    setState(() => _tried = true);
    final drawn = _drawn;
    final due = _dueAt;
    if (_picked.isEmpty || drawn == null || !_countOk(pool)) return;
    if (_afterDue && due == null) return;
    final l = AppLocalizations.of(context);
    final backend = context.services.backend;
    final topic = deck.topics.firstWhere(
      (t) => t.endsWith('-L'),
      orElse: () => deck.topics.first,
    );
    setState(() {
      _busy = true;
      _error = null;
    });
    var sent = 0;
    try {
      for (final g in [..._picked]) {
        await backend.createAssignment(
          groupId: g,
          title: _title(deck),
          questionIds: [for (final q in drawn) q.id],
          correctIndexes: [for (final q in drawn) q.correct.single],
          dueAt: due,
          dayId: topic,
          deckId: deck.id,
          revealAfterDue: _afterDue,
        );
        sent++;
        _picked.remove(g);
      }
      if (!mounted) return;
      showSnack(context, l.topicTestSent(sent));
      setState(() => _tried = false);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = DeckCatalog.peek(_bundle(context))
        ?.byId(widget.deckId)
        ?.title(_lang(context));
    return LgPage(
      title: l.topicTestAssign,
      subtitle: title,
      showProfile: false,
      children: [
        ClassesGate(
          child: ListenableBuilder(
            listenable: context.services.auth,
            builder: (context, _) {
              // Hisob almashsa — boshqa hisob guruhlari ko'rinmasin.
              final uid = context.services.backend.userId;
              if (_uid != null && uid != _uid) {
                _groups = null;
                _sent = const [];
                _picked.clear();
                WidgetsBinding.instance.addPostFrameCallback((_) => _load());
              }
              return _sources(
                widget.deckId,
                (context, deck, _, pool) => _body(context, deck, pool),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, DeckEntry deck, List<ExamQuestion> pool) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = _lang(context);
    if (deck.topics.isEmpty || pool.length < kTopicTestMin) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.topicTestPreparing,
        message: l.topicTestPreparingBody(pool.length),
      );
    }
    final groups = _groups;
    if (groups == null) {
      if (_error != null) {
        return LgStateView(
          kind: StateKind.error,
          title: classesErrorText(_error!, l),
          actionLabel: l.actionRetry,
          onAction: _load,
        );
      }
      return LgStateView(kind: StateKind.loading, title: l.classesLoading);
    }
    if (groups.isEmpty) {
      return LgStateView(
        kind: StateKind.empty,
        title: l.topicTestNoGroups,
        message: l.topicTestNoGroupsBody,
        actionLabel: l.topicTestCreateGroup,
        onAction: () async {
          await context.push('/learn/classes/new');
          if (mounted) await _load();
        },
      );
    }
    final max = _max(pool);
    // Boshlang'ich son — bir marta (foydalanuvchi o'chirsa, qayta yozilmaydi).
    if (!_countInit) {
      _countInit = true;
      _count.text = '${max < kTopicTestSize ? max : kTopicTestSize}';
    }
    if (_drawnFor != _n || (_drawn == null && _countOk(pool))) _redraw(pool);
    final drawn = _drawn;
    final due = _dueAt;
    final needsDue = _afterDue && due == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.topicTestAssignIntro, style: text.bodyMedium),
        LgSectionTitle(l.topicTestGroups),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in groups)
              LgChoiceChip(
                key: ValueKey('assign-group-${g.id}'),
                label: g.name,
                selected: _picked.contains(g.id),
                onTap: () => setState(() {
                  if (!_picked.remove(g.id)) _picked.add(g.id);
                }),
              ),
          ],
        ),
        if (_tried && _picked.isEmpty)
          LgNotice(l.topicTestPickGroup, kind: NoticeKind.error),
        LgSectionTitle(l.examSettings),
        NumberPresetField(
          label: l.examCount,
          controller: _count,
          hint: '10',
          helper: l.examCountHint(max),
          errorText: _tried && !_countOk(pool) ? l.examCountError(max) : null,
          presets: [
            for (final n in [5, 10, 20])
              if (n < max) ('$n', '$n'),
            (l.examCountAll(max), '$max'),
          ],
          onChanged: () => setState(() => _redraw(pool)),
        ),
        LgSectionTitle(l.classesDueTitle),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (d, label) in [
              (_Due.none, l.classesDueNone),
              (_Due.d1, l.classesDueDays(1)),
              (_Due.d3, l.classesDueDays(3)),
              (_Due.d7, l.classesDueDays(7)),
            ])
              LgChoiceChip(
                key: ValueKey('assign-due-${d.name}'),
                label: label,
                selected: _due == d,
                onTap: () => setState(() => _due = d),
              ),
            LgChoiceChip(
              label: l.classesDuePick,
              selected: _due == _Due.custom,
              onTap: _pickDate,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          due == null
              ? l.classesDueNoneBody
              : l.classesDueAt(formatWhen(due, context)),
          style: text.bodyMedium,
        ),
        LgSectionTitle(l.topicTestReveal),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LgChoiceChip(
              key: const ValueKey('assign-reveal-now'),
              label: l.topicTestRevealNow,
              selected: !_afterDue,
              onTap: () => setState(() => _afterDue = false),
            ),
            LgChoiceChip(
              key: const ValueKey('assign-reveal-after'),
              label: l.topicTestRevealAfterDue,
              selected: _afterDue,
              onTap: () => setState(() => _afterDue = true),
            ),
          ],
        ),
        if (needsDue) ...[
          const SizedBox(height: 8),
          LgNotice(l.topicTestRevealNeedsDue, kind: NoticeKind.error),
        ],
        LgSectionTitle(l.classesPreview(drawn?.length ?? 0)),
        if (drawn == null)
          Text(l.examCountError(max), style: text.bodyMedium)
        else ...[
          LgPanel(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, q) in drawn.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text('${i + 1}.', style: text.labelLarge),
                        ),
                        Expanded(
                          child: Text(q.prompt(lang), style: text.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          LgButton.secondary(
            label: l.classesReshuffle,
            icon: Icons.shuffle_rounded,
            onPressed: () => setState(() => _redraw(pool)),
          ),
        ],
        const SizedBox(height: 10),
        LgNotice(l.classesKeyNotice, kind: NoticeKind.info),
        if (_error != null)
          LgNotice(classesErrorText(_error!, l), kind: NoticeKind.error),
        const SizedBox(height: 12),
        LgButton(
          key: const ValueKey('assign-send'),
          label: l.classesSendAssignment,
          icon: Icons.send_rounded,
          busy: _busy,
          onPressed: needsDue ? null : () => _send(deck, pool),
        ),
        if (_sent.isNotEmpty) ...[
          LgSectionTitle(l.topicTestSentList),
          for (final (i, x) in _sent.indexed)
            LgRow(
              key: ValueKey('sent-${x.assignment.id}'),
              title: x.group.name,
              subtitle: [
                l.classesSubmittedOf(x.done, x.students),
                if (x.assignment.dueAt case final d?)
                  l.classesDue(formatWhen(d, context))
                else
                  l.classesNoDue,
              ].join(' · '),
              icon: Icons.insights_outlined,
              divider: i < _sent.length - 1,
              onTap: () async {
                await context.push(
                  '/learn/classes/g/${x.group.id}/a/${x.assignment.id}',
                );
                if (mounted) await _load();
              },
            ),
        ],
      ],
    );
  }
}

// =============================================================================
// Talaba: Bosh sahifa / O'rganish — berilgan testlar
// =============================================================================

class _Open {
  const _Open(this.group, this.assignment);

  final StudyGroup group;
  final GroupAssignment assignment;
}

/// Talabaga berilgan, hali topshirilmagan va muddati o'tmagan testlar
/// (muddat bilan). Server/hisob yo'q yoki test yo'q — hech narsa
/// ko'rsatilmaydi.
class AssignedTestsCard extends StatefulWidget {
  const AssignedTestsCard({super.key});

  @override
  State<AssignedTestsCard> createState() => _AssignedTestsCardState();
}

class _AssignedTestsCardState extends State<AssignedTestsCard> {
  List<_Open> _open = const [];
  String? _loadedFor;
  int _gen = 0;
  ExamController? _exams;

  @override
  void initState() {
    super.initState();
    // Shu qurilmada topshiriq boshlansa/yuborilsa — ro'yxat yangilanadi.
    _exams = context.services.exams..addListener(_examsChanged);
  }

  @override
  void dispose() {
    _exams?.removeListener(_examsChanged);
    super.dispose();
  }

  String _sig = '';

  /// Har javobda emas — faqat topshiriq boshlanganda, yakunlanganda yoki
  /// yuborilganda (serverga ortiqcha so'rov yo'q).
  String _signature() {
    final exams = context.services.exams;
    return [
      for (final x in _open)
        switch (exams.assignmentSession(x.assignment.id, _loadedFor)) {
          null => 'n',
          final s when s.finished => 'f',
          _ => 's',
        },
    ].join();
  }

  void _examsChanged() {
    if (!mounted || _loadedFor == null) return;
    final sig = _signature();
    if (sig == _sig) return;
    _sig = sig;
    unawaited(_load(_loadedFor));
  }

  Future<void> _load(String? uid) async {
    final gen = ++_gen;
    final services = context.services;
    if (uid == null) {
      if (_open.isNotEmpty) setState(() => _open = const []);
      return;
    }
    try {
      final backend = services.backend;
      final out = <_Open>[];
      for (final g in await backend.myGroups()) {
        if (g.isTeacher) continue;
        final r = await Future.wait([
          backend.assignments(g.id),
          backend.groupSubmissions(g.id),
        ]);
        final done = {
          for (final s in r[1] as List<GroupSubmission>)
            if (s.userId == uid) s.assignmentId,
        };
        final now = services.exams.now();
        for (final a in r[0] as List<GroupAssignment>) {
          if (done.contains(a.id) || a.closed) continue;
          if (a.dueAt case final d? when !d.isAfter(now)) continue;
          out.add(_Open(g, a));
        }
      }
      out.sort((a, b) {
        final x = a.assignment.dueAt;
        final y = b.assignment.dueAt;
        if (x == null || y == null) return x == null ? (y == null ? 0 : 1) : -1;
        return x.compareTo(y);
      });
      if (mounted && gen == _gen) {
        setState(() => _open = out);
        _sig = _signature();
      }
    } on Object {
      // Bosh sahifa kartasi — xato bo'lsa jim (guruh sahifasi halol ko'rsatadi).
      if (mounted && gen == _gen) setState(() => _open = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    if (!services.backend.isConfigured) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: services.auth,
      builder: (context, _) {
        final uid = services.auth.hasAccount ? services.backend.userId : null;
        if (uid != _loadedFor) {
          _loadedFor = uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _load(uid);
          });
        }
        if (_open.isEmpty) return const SizedBox.shrink();
        final shown = _open.take(3).toList();
        return Column(
          key: const ValueKey('assigned-tests'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgSectionTitle(l.topicTestAssignedTitle),
            for (final (i, x) in shown.indexed)
              LgRow(
                key: ValueKey('assigned-${x.assignment.id}'),
                title: x.assignment.title,
                subtitle: [
                  x.group.name,
                  if (x.assignment.dueAt case final d?)
                    l.classesDue(formatWhen(d, context))
                  else
                    l.classesNoDue,
                ].join(' · '),
                icon: Icons.assignment_outlined,
                divider: i < shown.length - 1,
                onTap: () async {
                  await context.push(
                    '/learn/classes/g/${x.group.id}/a/${x.assignment.id}',
                  );
                  if (mounted) unawaited(_load(_loadedFor));
                },
              ),
          ],
        );
      },
    );
  }
}

/// Mavzu testi tugmasi: taqdimot oxirida (oxirgi slayd) va menyuda.
class DeckTestEndButton extends StatelessWidget {
  const DeckTestEndButton({super.key, required this.deck});

  final DeckEntry deck;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DeckTestBuilder(
      deck: deck,
      builder: (context, state, _) => switch (state) {
        DeckTestState.hidden => const SizedBox.shrink(),
        _ => LgButton(
          key: const ValueKey('lecture-topic-test'),
          label: l.topicTestAction,
          icon: Icons.quiz_outlined,
          onPressed: () => openTopicTest(context, deck.id),
        ),
      },
    );
  }
}

/// Pleyer menyusi: mavzu testi va (ustoz) guruhga topshirish.
class DeckTestMenu extends StatelessWidget {
  const DeckTestMenu({super.key, required this.deck});

  final DeckEntry deck;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DeckTestBuilder(
      deck: deck,
      builder: (context, state, _) {
        if (state == DeckTestState.hidden) return const SizedBox.shrink();
        final teacher = canAssignTests(context) && state == DeckTestState.ready;
        return PopupMenuButton<String>(
          key: const ValueKey('lecture-test-menu'),
          tooltip: l.topicTestMenu,
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (v) => v == 'assign'
              ? openAssignDeckTest(context, deck.id)
              : openTopicTest(context, deck.id),
          itemBuilder: (context) => [
            PopupMenuItem(
              key: const ValueKey('lecture-menu-test'),
              value: 'test',
              child: Text(l.topicTestAction),
            ),
            if (teacher)
              PopupMenuItem(
                key: const ValueKey('lecture-menu-assign'),
                value: 'assign',
                child: Text(l.topicTestAssign),
              ),
          ],
        );
      },
    );
  }
}

/// [CurriculumTopic] uchun eski (topic) marshrutdagi deck.
DeckEntry? deckForTopic(BuildContext context, String topicId) =>
    DeckCatalog.peek(_bundle(context))?.byTopic(topicId);
