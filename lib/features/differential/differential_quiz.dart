import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../learn/quiz_session.dart';
import 'differential_content.dart';
import 'differential_entry_points.dart';
import 'differential_screens.dart';

/// "Bu qaysi hujayra?" savollari: rasm id → chalg'ituvchi variantlar
/// (adashtiriladigan hujayralar tanlangan).
const _distractors = <String, List<String>>{
  'neutrophil_segmented': [
    'neutrophil_band',
    'neutrophil_hypersegmented',
    'eosinophil',
  ],
  'neutrophil_band': [
    'neutrophil_segmented',
    'monocyte',
    'neutrophil_hypersegmented',
  ],
  'neutrophil_hypersegmented': [
    'neutrophil_segmented',
    'neutrophil_band',
    'eosinophil',
  ],
  'neutrophil_toxic': ['basophil', 'eosinophil', 'monocyte'],
  'lymphocyte_small': ['blast', 'smudge_cell', 'basophil'],
  'lymphocyte_large': ['monocyte', 'blast', 'lymphocyte_reactive'],
  'lymphocyte_reactive': ['monocyte', 'blast', 'lymphocyte_large'],
  'monocyte': ['lymphocyte_reactive', 'lymphocyte_large', 'blast'],
  'eosinophil': ['basophil', 'neutrophil_toxic', 'neutrophil_segmented'],
  'basophil': ['neutrophil_toxic', 'eosinophil', 'smudge_cell'],
  'smudge_cell': ['lymphocyte_small', 'monocyte', 'blast'],
  'blast': ['lymphocyte_large', 'monocyte', 'lymphocyte_reactive'],
};

int get diffQuizSize => _distractors.length;

/// Kengaytirilgan mashq: rasmli + tavsifli savollar.
int get diffExtendedQuizSize => _distractors.length * 2;

/// Savol: rasm + QuizQuestion (mavjud mashq modeli va sessiyasi).
class DiffQuizItem {
  const DiffQuizItem(this.image, this.question, {this.showImage = true});

  /// To'g'ri javob hujayrasining sxemasi (natijada ham ko'rsatiladi).
  final String image;
  final QuizQuestion question;

  /// Tavsifli savolda rasm javobni oshkor qiladi — ko'rsatilmaydi.
  final bool showImage;
}

const _described = LocalizedText({
  'uz': 'Tavsifga ko‘ra bu qaysi hujayra?',
  'ru': 'Какая клетка соответствует описанию?',
  'en': 'Which cell matches this description?',
});

const _labels = {
  'uz': ('Yadro', 'Sitoplazma', 'Donachalar'),
  'ru': ('Ядро', 'Цитоплазма', 'Гранулы'),
  'en': ('Nucleus', 'Cytoplasm', 'Granules'),
};

/// Tavsif matni: yadro, sitoplazma, donachalar (atlasdagi manbali matn).
LocalizedText _description(CellGuide g) => LocalizedText({
  for (final MapEntry(key: lang, value: (n, c, gr)) in _labels.entries)
    lang:
        '${_described.of(lang)}\n\n'
        '$n: ${g.nucleus.of(lang)}\n'
        '$c: ${g.cytoplasm.of(lang)}\n'
        '$gr: ${g.granules.of(lang)}',
});

const _prompt = LocalizedText({
  'uz': 'Bu qaysi hujayra?',
  'ru': 'Что это за клетка?',
  'en': 'Which cell is this?',
});

/// Har safar savollar va variantlar tartibi aralashtiriladi. [extended] —
/// har hujayra uchun qo'shimcha tavsifli savol.
List<DiffQuizItem> buildDiffQuiz(Random rnd, {bool extended = false}) {
  final items = <DiffQuizItem>[];
  for (final MapEntry(key: id, value: others) in _distractors.entries) {
    if (extended) {
      final ids = [id, ...others]..shuffle(rnd);
      final g = cellGuide(id)!;
      items.add(
        DiffQuizItem(
          id,
          QuizQuestion(
            id: 'diff-desc-$id',
            prompt: _description(g),
            options: [
              for (final o in ids)
                QuizOption(
                  text: cellGuide(o)!.name,
                  explanation: cellGuide(o)!.key,
                ),
            ],
            correctIndex: ids.indexOf(id),
            basis: g.key,
            refs: const [],
            reviewState: ReviewState.pending,
          ),
          showImage: false,
        ),
      );
    }
    final ids = [id, ...others]..shuffle(rnd);
    final options = [
      for (final o in ids)
        QuizOption(text: cellGuide(o)!.name, explanation: cellGuide(o)!.key),
    ];
    final g = cellGuide(id)!;
    items.add(
      DiffQuizItem(
        id,
        QuizQuestion(
          id: 'diff-$id',
          prompt: _prompt,
          options: options,
          correctIndex: ids.indexOf(id),
          basis: g.key,
          refs: const [],
          reviewState: ReviewState.pending,
        ),
      ),
    );
  }
  return items..shuffle(rnd);
}

class DiffQuizScreen extends StatefulWidget {
  const DiffQuizScreen({super.key, this.random, this.extended = false});

  /// Testlarda — oldindan ma'lum tartib.
  final Random? random;

  /// Kengaytirilgan mashq (DiffEntryPoints.openExtendedQuiz orqali).
  final bool extended;

  @override
  State<DiffQuizScreen> createState() => _DiffQuizScreenState();
}

class _DiffQuizScreenState extends State<DiffQuizScreen> {
  List<DiffQuizItem>? _items;
  QuizSession? _session;

  void _start() => setState(() {
    _items = buildDiffQuiz(
      widget.random ?? Random(),
      extended: widget.extended,
    );
    _session = QuizSession([for (final i in _items!) i.question]);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _session;
    return LgPage(
      key: ValueKey((s == null, s?.index, s?.finished)),
      title: widget.extended
          ? l.diffQuizExtended(diffExtendedQuizSize)
          : l.diffQuizTitle,
      subtitle: l.diffTitle,
      children: [
        if (s == null) ...[
          const CellPicture(id: 'lymphocyte_reactive', maxSize: 240),
          const SizedBox(height: 12),
          Text(l.diffQuizIntro, style: Theme.of(context).textTheme.bodyLarge),
          if (widget.extended) ...[
            const SizedBox(height: 8),
            Text(
              l.diffQuizExtendedIntro,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 16),
          LgButton(label: l.diffQuizStart, onPressed: _start),
          if (!widget.extended) ...[
            const SizedBox(height: 10),
            LgButton.secondary(
              label: l.diffQuizExtended(diffExtendedQuizSize),
              onPressed: () => DiffEntryPoints.openExtendedQuiz(context),
            ),
          ],
          const SizedBox(height: 14),
          Text(l.quizReviewNote, style: Theme.of(context).textTheme.bodySmall),
        ] else if (s.finished)
          _Result(session: s, items: _items!, onRestart: _start)
        else
          _Question(
            session: s,
            image: _items![s.index].showImage ? _items![s.index].image : null,
            onChanged: () => setState(() {}),
          ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.session,
    required this.image,
    required this.onChanged,
  });

  final QuizSession session;
  final String? image;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
          children: [
            LgEyebrow(l.quizProgress(session.index + 1, total)),
            LgTag(l.quizDraftTag, tone: LgTone.warning),
          ],
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
        if (image != null) ...[
          CellPicture(id: image!, maxSize: 220),
          const SizedBox(height: 10),
        ],
        Semantics(
          header: true,
          child: Text(q.prompt.of(lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Option(
              label: q.options[i].text.of(lang),
              state: !answered
                  ? _State.idle
                  : i == q.correctIndex
                  ? _State.correct
                  : i == answer
                  ? _State.wrong
                  : _State.idle,
              onTap: answered
                  ? null
                  : () {
                      if (session.answer(i)) onChanged();
                    },
            ),
          ),
        if (answered) ...[
          LgNotice(
            [
              if (answer != q.correctIndex)
                '${q.options[answer].text.of(lang)}: '
                    '${q.options[answer].explanation.of(lang)}',
              '${q.options[q.correctIndex].text.of(lang)}: '
                  '${q.options[q.correctIndex].explanation.of(lang)}',
            ].join('\n\n'),
            title: answer == q.correctIndex ? l.quizCorrect : l.quizIncorrect,
            kind: answer == q.correctIndex
                ? NoticeKind.info
                : NoticeKind.warning,
          ),
          const SizedBox(height: 8),
          LgButton(
            label: session.isLast ? l.quizFinish : l.quizNext,
            onPressed: () {
              session.next();
              onChanged();
            },
          ),
        ],
      ],
    );
  }
}

enum _State { idle, correct, wrong }

class _Option extends StatelessWidget {
  const _Option({required this.label, required this.state, this.onTap});

  final String label;
  final _State state;
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
      _State.idle => (p.paper, p.line, null, null),
      _State.correct => (
        p.soft,
        p.brand,
        Icons.check_circle_rounded,
        l.quizCorrectAnswer,
      ),
      _State.wrong => (
        p.amberBg,
        p.amber,
        Icons.cancel_rounded,
        l.quizYourAnswer,
      ),
    };
    final fg = state == _State.wrong ? p.amber : p.brand;
    return LgPressable(
      onTap: onTap,
      color: bg,
      border: Border.all(color: border, width: state == _State.idle ? 1 : 2),
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
                            color: fg,
                          ),
                        ),
                    ],
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.session,
    required this.items,
    required this.onRestart,
  });

  final QuizSession session;
  final List<DiffQuizItem> items;
  final VoidCallback onRestart;

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
        LgSectionTitle(l.quizMistakes),
        if (mistakes.isEmpty)
          Text(l.quizNoMistakes, style: text.bodyMedium)
        else
          for (final (q, chosen) in mistakes)
            LgPanel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72,
                    child: CellPicture(
                      id: items.firstWhere((i) => i.question == q).image,
                      caption: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l.quizYourAnswer}: ${q.options[chosen].text.of(lang)}',
                          style: text.bodyMedium,
                        ),
                        Text(
                          '${l.quizCorrectAnswer}: '
                          '${q.options[q.correctIndex].text.of(lang)}',
                          style: text.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(q.basis.of(lang), style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 16),
        LgButton(label: l.quizRestart, onPressed: onRestart),
      ],
    );
  }
}
