import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/diagram_figure.dart';
import '../../app/widgets/links.dart';
import '../../core/entitlements/feature.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../design/widgets/reveal_on_mount.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/ui/welcome_screen.dart';
import '../classroom/general_test_screen.dart' show generalTestLocation;
import '../classroom/topic_test_screens.dart' show AssignedTestsCard;
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../daily/daily_screens.dart';
import '../profile/pro_gate.dart';
import '../reference/reference_screens.dart';
import '../settings/settings_controller.dart';
import '../toifa/toifa_screens.dart';
import 'exam_screens.dart';
import 'quiz_session.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = context.services.content;
    // Paket yuklangach savollar soni yangilanadi (avval 0 bo'lib qolardi).
    return ListenableBuilder(
      listenable: Listenable.merge([
        content,
        context.services.exams,
        context.services.settings,
        context.services.curriculum,
        context.services.access,
      ]),
      builder: (context, _) =>
          _page(context, l, content.pack?.quiz.length ?? 0),
    );
  }

  Widget _page(BuildContext context, AppLocalizations l, int quizCount) {
    // Ustoz va talaba uchun guruhlar — asosiy ish joyi: birinchi ekranda,
    // katta kartalardan oldin (qo'llanma videosi, 2026-10-18).
    final role = context.services.settings.role;
    final classesFirst = role == AppRole.teacher || role == AppRole.student;
    final classes = LgRow(
      key: const ValueKey('learn-classes'),
      title: l.classesTitle,
      subtitle: l.learnClassesSub,
      icon: Icons.groups_outlined,
      onTap: () => context.push('/learn/classes'),
      divider: !classesFirst || role == AppRole.teacher,
    );
    // Ustozga: guruhga umumiy test (bir nechta mavzudan, 50 tagacha savol).
    final generalTest = role == AppRole.teacher
        ? LgRow(
            key: const ValueKey('learn-general-test'),
            title: l.classesGiveGeneralTest,
            subtitle: l.generalTestSub,
            icon: Icons.add_task_rounded,
            onTap: () => context.push(generalTestLocation),
            divider: !classesFirst,
          )
        : null;
    return LgPage(
      title: l.learnTitle,
      showBrand: true,
      children: [
        if (classesFirst) ...[
          classes,
          ?generalTest,
          const SizedBox(height: 12),
        ],
        LgHeroCard(
          image: kHeroImage,
          tag: l.learnHeroTag,
          title: l.learnHeroTitle,
          body: l.learnHeroBody,
          action: LgButton(
            label: l.learnHeroCta,
            // Shu tab ichida — mashq mavzulari. Boshqa tabga o'tilsa, o'sha
            // tabda oxirgi ochiq sahifa (masalan, tahlil kartasi) chiqardi.
            onPressed: () => context.push('/learn/quiz'),
          ),
        ),
        // Har kuni qaytish uchun: 5 ta savol va ketma-ketlik.
        const DailyCard(),
        // Guruhda berilgan (hali topshirilmagan) testlar — muddati bilan.
        const AssignedTestsCard(),
        // Faqat O'zbekiston foydalanuvchilariga (til uz yoki mintaqa UZ).
        // Talabaga malaka toifasi kerak emas — uning O'rganishida kartasi yo'q
        // (kunlik savollar qoladi, manzil laborant/ustozga ochiq).
        if (toifaVisible(context) &&
            context.services.settings.role != AppRole.student)
          const ToifaEntryCard(),
        // Dars mavzulari kontent paketidan keladi (hozircha bo'sh — domla
        // materiallari kelib, tekshirilgach qo'shiladi).
        ContentGate(
          builder: (context, pack) {
            if (pack.lessons.isEmpty) return const SizedBox.shrink();
            final lang = Localizations.localeOf(context).languageCode;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LgSectionTitle(l.lessonsTitle),
                for (final lesson in pack.lessons)
                  LgRow(
                    title: lesson.title.of(lang),
                    icon: Icons.menu_book_outlined,
                  ),
              ],
            );
          },
        ),
        if (!classesFirst) ...[classes, ?generalTest],
        // Ma'ruza rejimi — faqat o'quv dasturi ilovada bo'lsa (serversiz).
        if (context.services.curriculum.curriculum != null)
          LgRow(
            title: l.lectureListTitle,
            subtitle: l.lectureListSub,
            icon: Icons.slideshow_outlined,
            onTap: () => context.push('/learn/lecture'),
          ),
        LgRow(
          title: l.learnQuiz,
          subtitle: l.learnQuizSub(quizCount),
          icon: Icons.quiz_outlined,
          onTap: () => context.push('/learn/quiz'),
        ),
        LgRow(
          title: l.learnExam,
          // Tugallanmagan imtihon bo'lsa — javoblar va qolgan vaqt.
          subtitle: examRowSubtitle(context, l),
          icon: Icons.timer_outlined,
          onTap: () => context.push('/learn/exam'),
        ),
        LgRow(
          title: l.refTitle,
          subtitle: l.refSub,
          icon: Icons.table_chart_outlined,
          onTap: () => context.push(refBase),
        ),
        LgRow(
          title: l.diffTitle,
          subtitle: l.diffLearnSub,
          icon: Icons.bubble_chart_outlined,
          onTap: () => openInTab(context, '/lab/differential', exact: true),
        ),
        LgRow(
          title: l.micTitle,
          subtitle: l.labMicroscopySub,
          icon: Icons.biotech_outlined,
          onTap: () => openInTab(context, '/lab/microscopy', exact: true),
        ),
        LgRow(
          title: l.cytoTitle,
          subtitle: l.cytoSubtitle,
          icon: Icons.blur_on_rounded,
          onTap: () => openInTab(context, '/lab/cytology', exact: true),
          divider: lessonPlanVisible(context),
        ),
        // Dars rejasi — ustoz ish maydoni: faqat ustoz va admin (D-69 Q5).
        // "Ilmiy ish maydoni" (Kutubxona) alohida qoladi.
        if (lessonPlanVisible(context))
          LgRow(
            key: const ValueKey('learn-lesson-plan'),
            title: l.learnLessonPlan,
            subtitle: l.learnLessonPlanSub,
            icon: Icons.co_present_outlined,
            onTap: () => context.push('/learn/lesson'),
            divider: false,
          ),
        // Lab bo'limlarining mashqlari — bir joyda, bir xil ko'rinishda
        // (D-69 Q8). Mashqi bor har bo'lim; koagulogramma va koprologiyada
        // hozircha mashq yo'q.
        LgSectionTitle(l.learnSectionQuizzesTitle),
        for (final (i, q) in kLabSectionQuizzes.indexed)
          LgRow(
            key: ValueKey('learn-section-quiz-${q.id}'),
            title: l.learnSectionQuizRow(q.title(l)),
            icon: q.icon,
            onTap: () => openInTab(context, q.route, exact: true),
            divider: i < kLabSectionQuizzes.length - 1,
          ),
      ],
    );
  }
}

/// "Dars rejasi" qatori: ustoz yoki server tasdiqlagan admin (D-69 Q5).
bool lessonPlanVisible(BuildContext context) {
  final s = context.services;
  final a = s.access.access;
  return s.settings.effectiveRole == AppRole.teacher ||
      a.adminAccount ||
      a.panelAdmin;
}

/// O'rganish tabidagi "Bo'lim mashqlari": mashqi bor har bir Lab bo'limi.
typedef LabSectionQuiz = ({
  String id,
  String route,
  IconData icon,
  String Function(AppLocalizations l) title,
});

final kLabSectionQuizzes = <LabSectionQuiz>[
  (
    id: 'differential',
    route: '/lab/differential/quiz',
    icon: Icons.bubble_chart_outlined,
    title: (l) => l.diffTitle,
  ),
  (
    id: 'microscopy',
    route: '/lab/microscopy/quiz',
    icon: Icons.biotech_outlined,
    title: (l) => l.micTitle,
  ),
  (
    id: 'cytology',
    route: '/lab/cytology/quiz',
    icon: Icons.blur_on_rounded,
    title: (l) => l.cytoTitle,
  ),
  (
    id: 'spermogram',
    route: '/lab/spermogram/quiz',
    icon: Icons.water_drop_outlined,
    title: (l) => l.spermTitle,
  ),
  (
    id: 'bloodgroup',
    route: '/lab/bloodgroup/quiz',
    icon: Icons.bloodtype_outlined,
    title: (l) => l.bloodGroupTitle,
  ),
  (
    id: 'histology',
    route: '/lab/histology/quiz',
    icon: Icons.grid_view_rounded,
    title: (l) => l.histoTitle,
  ),
  (
    id: 'urinalysis',
    route: '/lab/urinalysis/quiz',
    icon: Icons.science_outlined,
    title: (l) => l.urinTitle,
  ),
  (
    id: 'bloodmorph',
    route: '/lab/bloodmorph/quiz',
    icon: Icons.circle_outlined,
    title: (l) => l.bloodMorphTitle,
  ),
];

/// Mashq to'plami: mavzu (guruh yoki bitta analit), umumiy laboratoriya
/// hisoblari yoki aralash tasodifiy savollar.
class QuizScope {
  const QuizScope(this.title, this.questions, {this.redraw});

  /// Sarlavha har chizilishda joriy til bilan quriladi (til almashsa,
  /// ochiq mashq sarlavhasi ham yangilanadi).
  final String Function(AppLocalizations l, String lang) title;
  final List<QuizQuestion> questions;

  /// Qayta boshlashda yangi to'plam (aralash rejim — yangi tasodifiy savollar).
  final QuizScope Function()? redraw;
}

/// Aralash rejimdagi savollar soni.
const kMixedQuizSize = 10;

/// Guruh savollari: `topic_ids` da guruhning analiti yoki guruhning o'zi
/// (validator ikkalasini ham qabul qiladi) bo'lgan savollar.
List<QuizQuestion> questionsForGroup(ContentPack pack, String groupId) {
  final ids = {
    groupId,
    for (final a in pack.analytes)
      if (a.group == groupId) a.id,
  };
  return [
    for (final q in pack.quiz)
      if (q.topicIds.any(ids.contains)) q,
  ];
}

List<QuizQuestion> questionsForAnalyte(ContentPack pack, String analyteId) => [
  for (final q in pack.quiz)
    if (q.topicIds.contains(analyteId)) q,
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, this.analyteId});

  /// Berilsa — faqat shu analit savollari (analit kartasidan ochilganda).
  final String? analyteId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizScope? _scope;
  QuizSession? _session;

  // Bir analit testidan boshqasiga o'tilganda State qayta ishlatilishi
  // mumkin — sessiya yangi analit uchun qaytadan yig'iladi.
  @override
  void didUpdateWidget(QuizScreen old) {
    super.didUpdateWidget(old);
    if (old.analyteId != widget.analyteId) {
      _scope = null;
      _session = null;
    }
  }

  void _start(QuizScope scope) => setState(() {
    _scope = scope;
    _session = QuizSession(scope.questions);
  });

  /// Yangi raund — [Feature.unlimitedQuestions] (D-71: hozir hech narsa
  /// yopilmagan, `ProGatePolicy.gated` bo'sh). Xatolar ustida ishlash
  /// ([_start] to'g'ridan-to'g'ri) hech qachon cheklanmaydi.
  Future<void> _startGated(QuizScope scope) async {
    if (!await requireFeature(context, Feature.unlimitedQuestions)) return;
    if (mounted) _start(scope);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = context.services.content;
    // Paket yuklanishi kutilsa ham sarlavha (analit nomi) yangilanadi va
    // kartadan mini-test boshlanadi.
    return ListenableBuilder(
      listenable: content,
      builder: (context, _) {
        final analyteId = widget.analyteId;
        final loaded = content.pack;
        // Kartadan mini-test.
        if (analyteId != null && _session == null && loaded != null) {
          _scope = QuizScope(
            (_, lang) => loaded.analyte(analyteId)?.names.of(lang) ?? analyteId,
            questionsForAnalyte(loaded, analyteId),
          );
          _session = QuizSession(_scope!.questions);
        }
        return _page(context, l);
      },
    );
  }

  Widget _page(BuildContext context, AppLocalizations l) {
    final analyteId = widget.analyteId;
    final current = _session;
    return LgPage(
      // Mavzu tanlanganda yoki keyingi savolga o'tilganda sahifa tepadan
      // boshlanadi: aks holda ro'yxat pastidagi mavzu (masalan, "Gormonlar")
      // tanlansa, eski scroll tufayli savolning boshi ko'rinmay qolardi.
      key: ValueKey((current == null, current?.index, current?.finished)),
      buildAllChildren: true,
      title: l.learnQuiz,
      subtitle: _scope?.title(l, Localizations.localeOf(context).languageCode),
      children: [
        ContentGate(
          builder: (context, pack) {
            final session = _session;
            if (session == null) {
              return _TopicPicker(
                pack: pack,
                onPick: _startGated,
                onPickMistakes: _start,
              );
            }
            if (session.questions.isEmpty) {
              return LgStateView(kind: StateKind.empty, title: l.learnQuiz);
            }
            return session.finished
                ? _QuizResult(
                    session: session,
                    onRestart: () =>
                        _startGated(_scope!.redraw?.call() ?? _scope!),
                    onRetryMistakes: () => _start(
                      QuizScope((l, _) => l.quizTopicMistakes, [
                        for (final (QuizQuestion q, _) in session.mistakes) q,
                      ]),
                    ),
                    onOtherTopic: analyteId == null
                        ? () => setState(() {
                            _scope = null;
                            _session = null;
                          })
                        : null,
                  )
                : _QuizQuestion(
                    session: session,
                    onChanged: () => setState(() {}),
                  );
          },
        ),
      ],
    );
  }
}

class _TopicPicker extends StatelessWidget {
  const _TopicPicker({
    required this.pack,
    required this.onPick,
    required this.onPickMistakes,
  });

  final ContentPack pack;
  final ValueChanged<QuizScope> onPick;

  /// Xatolar ustida ishlash.
  final ValueChanged<QuizScope> onPickMistakes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    // Deck matnidan olingan savollar faqat mavzu testida (curriculum).
    final practice = [
      for (final q in pack.quiz)
        if (!q.isDerived) q,
    ];
    final general = [
      for (final q in practice)
        if (q.topicIds.isEmpty) q,
    ];
    final groups = [
      for (final g in pack.groups) (g, questionsForGroup(pack, g.id)),
    ].where((e) => e.$2.isNotEmpty).toList();
    final mixedSize = practice.length < kMixedQuizSize
        ? practice.length
        : kMixedQuizSize;
    final progress = context.services.quizProgress;
    String sub(List<QuizQuestion> qs) {
      final n = qs.length;
      final m = progress.mastered(qs.map((q) => q.id));
      return m == 0
          ? l.quizQuestionCount(n)
          : '${l.quizQuestionCount(n)} · ${l.quizMastered(m, n)}';
    }

    final mistakes = {
      ...progress.mistakes([for (final q in pack.quiz) q.id]),
    };
    QuizScope mixed() => QuizScope(
      (l, _) => l.quizTopicMixed(mixedSize),
      (List.of(practice)..shuffle()).take(mixedSize).toList(),
      redraw: mixed,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.quizChooseTopic),
        if (mistakes.isNotEmpty)
          LgRow(
            title: l.quizTopicMistakes,
            subtitle: l.quizQuestionCount(mistakes.length),
            icon: Icons.replay_rounded,
            onTap: () => onPickMistakes(
              QuizScope((l, _) => l.quizTopicMistakes, [
                for (final q in pack.quiz)
                  if (mistakes.contains(q.id)) q,
              ]),
            ),
          ),
        LgRow(
          title: l.quizTopicMixed(mixedSize),
          subtitle: l.quizQuestionCount(practice.length),
          icon: Icons.shuffle_rounded,
          onTap: () => onPick(mixed()),
        ),
        if (general.isNotEmpty)
          LgRow(
            title: l.quizTopicGeneral,
            subtitle: sub(general),
            icon: Icons.calculate_outlined,
            onTap: () =>
                onPick(QuizScope((l, _) => l.quizTopicGeneral, general)),
          ),
        for (final (i, (group, questions)) in groups.indexed)
          LgRow(
            title: group.names.of(lang),
            subtitle: sub(questions),
            icon: groupIcon(group.id),
            onTap: () =>
                onPick(QuizScope((_, lang) => group.names.of(lang), questions)),
            divider: i < groups.length - 1,
          ),
        const SizedBox(height: 14),
        Text(l.quizReviewNote, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _QuizQuestion extends StatelessWidget {
  const _QuizQuestion({required this.session, required this.onChanged});

  final QuizSession session;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final q = session.current;
    final answer = session.answerFor(session.index);
    final answered = answer != null;
    final total = session.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [LgEyebrow(l.quizProgress(session.index + 1, total))],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (session.index + 1) / total,
              minHeight: 6,
              semanticsLabel: l.quizProgress(session.index + 1, total),
            ),
          ),
        ),
        Semantics(
          header: true,
          child: Text(q.prompt.of(lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QuizOptionButton(
              label: q.options[i].text.of(lang),
              state: !answered
                  ? QuizOptionState.idle
                  : i == q.correctIndex
                  ? QuizOptionState.correct
                  : i == answer
                  ? QuizOptionState.wrong
                  : QuizOptionState.disabled,
              onTap: answered
                  ? null
                  : () {
                      // Ikki marta tez bosilsa ham natija bir marta yoziladi.
                      if (!session.answer(i)) return;
                      onChanged();
                      // Natija faqat qurilmada — “xatolar ustida ishlash” uchun.
                      context.services.quizProgress.record(
                        q.id,
                        correct: i == q.correctIndex,
                      );
                    },
            ),
          ),
        if (answered) ...[
          // Kichik ekranda izoh pastda qolmasin (audit 2026-10-18).
          RevealOnMount(
            child: LgNotice(
              [
                q.options[answer].explanation.of(lang),
                if (answer != q.correctIndex)
                  q.options[q.correctIndex].explanation.of(lang),
              ].join('\n\n'),
              title: answer == q.correctIndex ? l.quizCorrect : l.quizIncorrect,
              kind: answer == q.correctIndex
                  ? NoticeKind.info
                  : NoticeKind.warning,
            ),
          ),
          Text(
            l.quizBasis(q.basis.of(lang)),
            style: text.bodySmall!.copyWith(color: p.sub),
          ),
          // Savol qaysi manbaga tayanadi — ochib tekshirish mumkin.
          for (final r in q.refs)
            if (context.services.content.pack?.source(r.sourceId)
                case final src?)
              InkWell(
                onTap: src.url == null
                    ? null
                    : () => openExternalLink(context, src.url!),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: kMinTap),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l.quizSources}: ${src.publisher} — ${src.title}'
                            '${r.locator == null ? '' : ' · ${r.locator}'}',
                            style: text.bodySmall!.copyWith(color: p.brand),
                          ),
                        ),
                        if (src.url != null) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: p.brand,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 14),
          LgButton(
            label: session.isLast ? l.quizFinish : l.quizNext,
            onPressed: () {
              session.next();
              onChanged();
            },
          ),
        ],
        const SizedBox(height: 14),
        Text(l.quizReviewNote, style: text.bodySmall),
      ],
    );
  }
}

/// Variant kartasining holati (mashq va mavzu testi).
enum QuizOptionState { idle, correct, wrong, disabled }

/// Katta bosiladigan variant kartasi: javobdan keyin to'g'ri/xato belgisi.
class QuizOptionButton extends StatelessWidget {
  const QuizOptionButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final QuizOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final (
      Color bg,
      Color border,
      IconData? icon,
      String? suffix,
    ) = switch (state) {
      QuizOptionState.idle => (p.paper, p.line, null, null),
      QuizOptionState.correct => (
        p.soft,
        p.brand,
        Icons.check_circle_rounded,
        l.quizCorrectAnswer,
      ),
      QuizOptionState.wrong => (
        p.amberBg,
        p.amber,
        Icons.cancel_rounded,
        l.quizYourAnswer,
      ),
      QuizOptionState.disabled => (p.paper, p.line, null, null),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LgRadius.button),
        border: Border.all(
          color: border,
          width: state == QuizOptionState.idle ? 1 : 2,
        ),
      ),
      child: LgPressable(
        onTap: onTap,
        color: bg,
        borderRadius: BorderRadius.circular(LgRadius.button),
        semanticLabel: suffix == null ? label : '$label. $suffix',
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
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
                              color: state == QuizOptionState.wrong
                                  ? p.amber
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
                      color: state == QuizOptionState.wrong ? p.amber : p.brand,
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

class _QuizResult extends StatelessWidget {
  const _QuizResult({
    required this.session,
    required this.onRestart,
    this.onOtherTopic,
    this.onRetryMistakes,
  });

  final QuizSession session;
  final VoidCallback onRestart;
  final VoidCallback? onOtherTopic;

  /// Faqat xato javob berilgan savollarni qayta ishlash.
  final VoidCallback? onRetryMistakes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final mistakes = session.mistakes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgStateView(
          kind: StateKind.success,
          title: l.quizDoneTitle,
          message: l.quizScore(session.correctCount, session.questions.length),
        ),
        // Amallar natija ostida, xatolar ro'yxatidan oldin: uzun ro'yxatni
        // oxirigacha aylantirmasdan qayta urinish mumkin.
        const SizedBox(height: 8),
        if (mistakes.isNotEmpty && onRetryMistakes != null) ...[
          LgButton(
            label: l.examReworkMistakes(mistakes.length),
            onPressed: onRetryMistakes,
          ),
          const SizedBox(height: 10),
          LgButton.secondary(label: l.quizRestart, onPressed: onRestart),
        ] else
          LgButton(label: l.quizRestart, onPressed: onRestart),
        if (onOtherTopic != null) ...[
          const SizedBox(height: 10),
          LgButton.secondary(label: l.quizOtherTopic, onPressed: onOtherTopic),
        ],
        const SizedBox(height: 8),
        LgSectionTitle(l.quizMistakes),
        if (mistakes.isEmpty)
          Text(l.quizNoMistakes, style: text.bodyMedium)
        else
          for (final (QuizQuestion q, int chosen) in mistakes)
            LgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.prompt.of(lang), style: text.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${l.quizYourAnswer}: ${q.options[chosen].text.of(lang)}',
                    style: text.bodyMedium,
                  ),
                  Text(
                    '${l.quizCorrectAnswer}: ${q.options[q.correctIndex].text.of(lang)}',
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.options[q.correctIndex].explanation.of(lang),
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
        const SizedBox(height: 16),
        const DiagramFigure(topic: DiagramTopic.educationalFeedback),
      ],
    );
  }
}
