import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../learn/quiz_session.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import '../tools/sources_panel.dart';
import 'bloodgroup_content.dart';
import 'bloodgroup_logic.dart';

const bloodGroupBase = '/lab/bloodgroup';
const bloodGroupCardImage = 'assets/bloodgroup/card.png';

extension on BuildContext {
  String get _lang => Localizations.localeOf(this).languageCode;

  /// Matn joriy tilda.
  String tr(LocalizedText t) => t.of(_lang);
}

/// Manbalar ro'yxati (takrorsiz, lokator bilan).
class _Refs extends StatelessWidget {
  const _Refs(this.refs);

  final List<CalcRef> refs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final seen = <String>{};
    final unique = [
      for (final r in refs)
        if (seen.add('${r.source.id}|${r.locator}')) r,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, r) in unique.indexed)
          CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

List<CalcRef> _refsOf(Iterable<BgItem> items) => [
  for (final i in items) ...i.refs,
];

/// Mavzu kartasi.
class _ItemCard extends StatelessWidget {
  const _ItemCard(this.item);

  final BgItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LgPanel(
      key: ValueKey('bg-item-${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr(item.title), style: text.titleSmall),
          const SizedBox(height: 6),
          Text(context.tr(item.body), style: text.bodyMedium),
        ],
      ),
    );
  }
}

/// Manbalar paneli va SOP ogohlantirishi (har sahifada).
class _Notices extends StatelessWidget {
  const _Notices();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SourcesPanel(bgLeadRefs),
        LgNotice(context.tr(BgL.sopNote), kind: NoticeKind.error),
      ],
    );
  }
}

/// Oddiy jadval (tor ekranda matn o'raladi, gorizontal toshish yo'q).
class _Grid extends StatelessWidget {
  const _Grid({super.key, required this.header, required this.rows, this.flex});

  final List<String> header;
  final List<List<String>> rows;
  final List<double>? flex;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    Widget cell(String s, {bool head = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        s,
        style: head
            ? text.labelMedium!.copyWith(fontWeight: FontWeight.w700)
            : text.bodyMedium,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: TableBorder.symmetric(inside: BorderSide(color: p.line)),
          columnWidths: {
            for (final (i, f) in (flex ?? const <double>[]).indexed)
              i: FlexColumnWidth(f),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: p.soft),
              children: [for (final h in header) cell(h, head: true)],
            ),
            for (final r in rows)
              TableRow(
                decoration: BoxDecoration(color: p.paper),
                children: [for (final c in r) cell(c)],
              ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Bosh sahifa ─────────────────────────

/// Qon guruhi bo'limining bosh sahifasi.
class BloodGroupScreen extends StatelessWidget {
  const BloodGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (BgL.basicsTitle, BgL.basicsSub, Icons.bloodtype_outlined, 'basics'),
      (BgL.methodsTitle, BgL.methodsSub, Icons.science_outlined, 'methods'),
      (BgL.compatTitle, BgL.compatSub, Icons.compare_arrows_rounded, 'compat'),
      (BgL.errorsTitle, BgL.errorsSub, Icons.report_problem_outlined, 'errors'),
      (BgL.qualityTitle, BgL.qualitySub, Icons.fact_check_outlined, 'quality'),
      (BgL.readerTitle, BgL.readerSub, Icons.grid_on_rounded, 'reader'),
      (BgL.quizTitle, BgL.quizSub, Icons.quiz_outlined, 'quiz'),
    ];
    return LgPage(
      title: l.bloodGroupTitle,
      subtitle: context.tr(BgL.subtitle),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  bloodGroupCardImage,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const _Notices(),
        for (final (i, (title, sub, icon, path)) in rows.indexed)
          LgRow(
            key: ValueKey('bg-row-$path'),
            title: context.tr(title),
            subtitle: context.tr(sub),
            icon: icon,
            onTap: () => context.push('$bloodGroupBase/$path'),
            divider: i < rows.length - 1,
          ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in BgSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

// ───────────────────────── 1. Asoslar ─────────────────────────

class BgBasicsScreen extends StatelessWidget {
  const BgBasicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    String g(AboGroup x) => context.tr(aboGroupNames[x]!);
    String sign(bool v) => v ? '+' : '−';
    final none = context.tr(BgL.none);
    final and = context.tr(BgL.andWord);
    final antiA = context.tr(BgL.antiA);
    final antiB = context.tr(BgL.antiB);
    return LgPage(
      title: context.tr(BgL.basicsTitle),
      subtitle: l.bloodGroupTitle,
      children: [
        Text(context.tr(BgL.basicsIntro), style: text.bodyMedium),
        const _Notices(),
        LgSectionTitle(context.tr(BgL.tableAntibodiesTitle)),
        _Grid(
          key: const ValueKey('bg-table-antibodies'),
          flex: const [1.1, 1.2, 1.5],
          header: [
            context.tr(BgL.colGroup),
            context.tr(BgL.colAntigens),
            context.tr(BgL.colAntibodies),
          ],
          rows: [
            [g(AboGroup.a), 'A', antiB],
            [g(AboGroup.b), 'B', antiA],
            [g(AboGroup.ab), 'A $and B', none],
            [g(AboGroup.o), none, '$antiA $and $antiB'],
          ],
        ),
        LgSectionTitle(context.tr(BgL.tablePatternTitle)),
        _Grid(
          key: const ValueKey('bg-table-pattern'),
          flex: const [1.3, 1, 1, 1, 1],
          header: [
            context.tr(BgL.colGroup),
            antiA,
            antiB,
            context.tr(BgL.a1Cells),
            context.tr(BgL.bCells),
          ],
          rows: [
            for (final x in AboGroup.values)
              () {
                final e = expectedPattern(x);
                return [
                  g(x),
                  sign(e.antiA),
                  sign(e.antiB),
                  sign(e.a1Cells),
                  sign(e.bCells),
                ];
              }(),
          ],
        ),
        Text(context.tr(BgL.patternNote), style: text.bodySmall),
        const SizedBox(height: 8),
        for (final i in bgBasics) _ItemCard(i),
        _Refs([
          refBshAboIntro,
          refHtmAboReact,
          ...bgPatternRefs,
          ..._refsOf(bgBasics),
        ]),
      ],
    );
  }
}

// ───────────────────────── 2. Usullar ─────────────────────────

class BgMethodsScreen extends StatelessWidget {
  const BgMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: context.tr(BgL.methodsTitle),
      subtitle: l.bloodGroupTitle,
      children: [
        Text(context.tr(BgL.methodsIntro), style: text.bodyMedium),
        const _Notices(),
        for (final i in bgMethods) _ItemCard(i),
        LgSectionTitle(context.tr(BgL.gradingTitle)),
        _Grid(
          key: const ValueKey('bg-table-grading'),
          flex: const [1, 5],
          header: ['', context.tr(BgL.gradingTitle)],
          rows: [
            for (final (grade, meaning) in bgGrades)
              [grade, context.tr(meaning)],
          ],
        ),
        LgSectionTitle(context.tr(BgL.readingTitle)),
        LgSteps([for (final s in bgTubeReading) context.tr(s)]),
        _Refs([..._refsOf(bgMethods), refWhoGrading, refWhoReading]),
      ],
    );
  }
}

// ───────────────────────── 3. Moslik ─────────────────────────

class BgCompatScreen extends StatelessWidget {
  const BgCompatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    String gs(List<AboGroup> xs) =>
        xs.map((x) => context.tr(aboGroupNames[x]!)).join(', ');
    return LgPage(
      title: context.tr(BgL.compatTitle),
      subtitle: l.bloodGroupTitle,
      children: [
        Text(context.tr(BgL.compatIntro), style: text.bodyMedium),
        const _Notices(),
        for (final i in bgCompat) _ItemCard(i),
        LgSectionTitle(context.tr(BgL.tableSelectTitle)),
        _Grid(
          key: const ValueKey('bg-table-select'),
          flex: const [1, 1.6, 1.6],
          header: [
            context.tr(BgL.colPatient),
            context.tr(BgL.colRbc),
            context.tr(BgL.colPlasma),
          ],
          rows: [
            for (final MapEntry(key: g, value: (rbc, plasma))
                in bgSelectTable.entries)
              [context.tr(aboGroupNames[g]!), gs(rbc), gs(plasma)],
          ],
        ),
        Text(context.tr(BgL.selectNote), style: text.bodySmall),
        _Refs([
          refWhoSelect,
          ..._refsOf(bgCompat),
          refHtmTable22,
          refRu1134Lab,
        ]),
      ],
    );
  }
}

// ───────────────────────── 4. Nomuvofiqlik va xatolar ─────────────────────

class BgErrorsScreen extends StatelessWidget {
  const BgErrorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: context.tr(BgL.errorsTitle),
      subtitle: l.bloodGroupTitle,
      children: [
        Text(context.tr(BgL.errorsIntro), style: text.bodyMedium),
        LgNotice(
          context.tr(BgL.noIssueNote),
          key: const ValueKey('bg-no-issue'),
          kind: NoticeKind.error,
        ),
        const _Notices(),
        LgSectionTitle(context.tr(BgL.causesTitle)),
        for (final i in bgCauses) _ItemCard(i),
        const SizedBox(height: 8),
        for (final i in bgErrors) _ItemCard(i),
        LgSectionTitle(context.tr(BgL.actionsTitle)),
        for (final i in bgActions) _ItemCard(i),
        _Refs([
          refBshResolve,
          ..._refsOf(bgCauses),
          ..._refsOf(bgErrors),
          ..._refsOf(bgActions),
        ]),
      ],
    );
  }
}

// ───────────────────────── 5. Sifat ─────────────────────────

class BgQualityScreen extends StatelessWidget {
  const BgQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: context.tr(BgL.qualityTitle),
      subtitle: l.bloodGroupTitle,
      children: [
        Text(context.tr(BgL.qualityIntro), style: text.bodyMedium),
        const _Notices(),
        for (final i in bgQuality) _ItemCard(i),
        LgSectionTitle(context.tr(BgL.controlsTitle)),
        _Grid(
          key: const ValueKey('bg-table-controls'),
          flex: const [1, 1, 1],
          header: [
            context.tr(BgL.colReagent),
            context.tr(BgL.colPosCtrl),
            context.tr(BgL.colNegCtrl),
          ],
          rows: [
            for (final (reagent, pos, neg) in bgControlTable)
              [context.tr(reagent), context.tr(pos), context.tr(neg)],
          ],
        ),
        _Refs([refBshSamples, ..._refsOf(bgQuality), refBshKey]),
      ],
    );
  }
}

// ───────────────────────── 6. Naqshni o'qish ─────────────────────────

class BgReaderScreen extends StatefulWidget {
  const BgReaderScreen({super.key});

  @override
  State<BgReaderScreen> createState() => _BgReaderScreenState();
}

class _BgReaderScreenState extends State<BgReaderScreen> {
  BgReaction? _antiA;
  BgReaction? _antiB;
  BgReaction? _antiD;
  bool? _a1;
  bool? _b;
  bool? _control;

  BgInput get _input => BgInput(
    antiA: _antiA,
    antiB: _antiB,
    antiD: _antiD,
    a1Cells: _a1,
    bCells: _b,
    control: _control,
  );

  void _reset() => setState(() {
    _antiA = _antiB = _antiD = null;
    _a1 = _b = _control = null;
  });

  /// Reagent qatori: qo'yilmagan / − / + / kuchsiz.
  Widget _reactionRow(
    String id,
    String label,
    BgReaction? value,
    ValueChanged<BgReaction?> onChanged,
  ) {
    final opts = <(BgReaction?, LocalizedText, String)>[
      (null, BgL.notTested, 'none'),
      (BgReaction.neg, BgL.reactionNeg, 'neg'),
      (BgReaction.pos, BgL.reactionPos, 'pos'),
      (BgReaction.weak, BgL.reactionWeak, 'weak'),
      (BgReaction.mixed, BgL.reactionMixed, 'mixed'),
    ];
    return _row(label, [
      for (final (v, t, key) in opts)
        LgChoiceChip(
          key: ValueKey('bg-in-$id-$key'),
          label: context.tr(t),
          selected: value == v,
          onTap: () => setState(() => onChanged(v)),
        ),
    ]);
  }

  /// Hujayra/nazorat qatori: qo'yilmagan / − / +.
  Widget _boolRow(
    String id,
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    final opts = <(bool?, LocalizedText, String)>[
      (null, BgL.notTested, 'none'),
      (false, BgL.reactionNeg, 'neg'),
      (true, BgL.reactionPos, 'pos'),
    ];
    return _row(label, [
      for (final (v, t, key) in opts)
        LgChoiceChip(
          key: ValueKey('bg-in-$id-$key'),
          label: context.tr(t),
          selected: value == v,
          onTap: () => setState(() => onChanged(v)),
        ),
    ]);
  }

  Widget _row(String label, List<Widget> chips) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.titleSmall),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final input = _input;
    final r = readPattern(input);
    return LgPage(
      title: context.tr(BgL.readerTitle),
      subtitle: l.bloodGroupTitle,
      children: [
        Text(context.tr(BgL.readerIntro), style: text.bodyMedium),
        LgNotice(
          context.tr(BgL.readerTrainingOnly),
          key: const ValueKey('bg-reader-training'),
          kind: NoticeKind.error,
        ),
        LgSectionTitle(context.tr(BgL.forwardHead)),
        _reactionRow('antiA', context.tr(BgL.antiA), _antiA, (v) => _antiA = v),
        _reactionRow('antiB', context.tr(BgL.antiB), _antiB, (v) => _antiB = v),
        _reactionRow('antiD', context.tr(BgL.antiD), _antiD, (v) => _antiD = v),
        LgSectionTitle(context.tr(BgL.reverseHead)),
        _boolRow('a1', context.tr(BgL.a1Cells), _a1, (v) => _a1 = v),
        _boolRow('b', context.tr(BgL.bCells), _b, (v) => _b = v),
        _boolRow(
          'control',
          context.tr(BgL.controlLabel),
          _control,
          (v) => _control = v,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LgButton(
            label: context.tr(BgL.reset),
            kind: LgButtonKind.secondary,
            onPressed: _reset,
          ),
        ),
        const SizedBox(height: 8),
        if (input.isEmpty)
          Text(context.tr(BgL.readerEmpty), style: text.bodyMedium)
        else
          _ReaderResult(result: r),
        _Refs([
          refWhoAnswers,
          refWhoDemo,
          refBshTests,
          refBshFigA1,
          for (final f in r.flags) ...bgFlagInfo[f]!.refs,
        ]),
      ],
    );
  }
}

class _ReaderResult extends StatelessWidget {
  const _ReaderResult({required this.result});

  final BgResult result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final r = result;
    String g(AboGroup x) => context.tr(aboGroupNames[x]!);
    final rh = switch (r.rh) {
      RhResult.positive => context.tr(BgL.rhPositive),
      RhResult.negative => context.tr(BgL.rhNegative),
      RhResult.weak => context.tr(BgL.rhWeak),
      RhResult.mixedField => context.tr(BgL.rhMixed),
      null => null,
    };
    final (headline, headlineKey) = r.invalid
        ? (context.tr(BgL.invalidTitle), 'bg-res-invalid')
        : r.discrepancy
        ? (context.tr(BgL.discrepancyTitle), 'bg-res-discrepancy')
        : r.anomaly
        ? (context.tr(BgL.anomalyTitle), 'bg-res-anomaly')
        : (null, null);
    return LgPanel(
      key: const ValueKey('bg-reader-result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headline != null)
            Text(
              headline,
              key: ValueKey<String>(headlineKey!),
              style: text.titleMedium!.copyWith(
                color: p.danger,
                fontWeight: FontWeight.w700,
              ),
            )
          else if (r.group case final grp?)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(BgL.concordant), style: text.bodySmall),
                Text(
                  g(grp),
                  key: const ValueKey('bg-res-group'),
                  style: text.headlineSmall!.copyWith(
                    color: p.brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          // Anomaliyada to'g'ri usul bo'yicha guruh ham aytilmaydi.
          if (r.forward case final f? when !r.anomaly)
            Text(
              '${context.tr(BgL.forwardSays)}: ${g(f)}',
              key: const ValueKey('bg-res-forward'),
              style: text.bodyMedium,
            ),
          if (r.reverse case final rv?)
            Text(
              '${context.tr(BgL.reverseSays)}: ${g(rv)}',
              key: const ValueKey('bg-res-reverse'),
              style: text.bodyMedium,
            ),
          if (rh != null)
            Text(rh, key: const ValueKey('bg-res-rh'), style: text.titleSmall),
          for (final f in BgFlag.values)
            if (r.flags.contains(f))
              LgNotice(
                context.tr(bgFlagInfo[f]!.text),
                key: ValueKey('bg-flag-${f.name}'),
                kind: f == BgFlag.discrepancy || f == BgFlag.controlPositive
                    ? NoticeKind.error
                    : NoticeKind.warning,
              ),
        ],
      ),
    );
  }
}

// ───────────────────────── 7. Mashq ─────────────────────────

/// Savollar (variantlar aralashtirilgan).
List<QuizQuestion> buildBgQuiz(Random rnd) => [
  for (final item in [...bgQuiz]..shuffle(rnd))
    () {
      final order = List.generate(item.options.length, (i) => i)..shuffle(rnd);
      return QuizQuestion(
        id: item.id,
        prompt: item.prompt,
        options: [
          for (final o in order)
            QuizOption(text: item.options[o], explanation: item.basis),
        ],
        correctIndex: order.indexOf(0),
        basis: item.basis,
        refs: const [],
        reviewState: ReviewState.pending,
      );
    }(),
];

class BgQuizScreen extends StatefulWidget {
  const BgQuizScreen({super.key, this.random});

  final Random? random;

  @override
  State<BgQuizScreen> createState() => _BgQuizScreenState();
}

class _BgQuizScreenState extends State<BgQuizScreen> {
  QuizSession? _session;

  void _start() => setState(() {
    _session = QuizSession(buildBgQuiz(widget.random ?? Random()));
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final s = _session;
    return LgPage(
      key: ValueKey((s == null, s?.index, s?.finished)),
      title: context.tr(BgL.quizTitle),
      subtitle: l.bloodGroupTitle,
      children: [
        if (s == null) ...[
          Text(context.tr(BgL.quizIntro), style: text.bodyLarge),
          const SizedBox(height: 16),
          LgButton(label: context.tr(BgL.quizStart), onPressed: _start),
          const SizedBox(height: 14),
          Text(l.quizReviewNote, style: text.bodySmall),
        ] else if (s.finished) ...[
          LgStateView(
            kind: StateKind.success,
            title: l.quizDoneTitle,
            message: l.quizScore(s.correctCount, s.questions.length),
          ),
          LgSectionTitle(l.quizMistakes),
          if (s.mistakes.isEmpty)
            Text(l.quizNoMistakes, style: text.bodyMedium)
          else
            for (final (q, chosen) in s.mistakes)
              LgPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr(q.prompt), style: text.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${l.quizYourAnswer}: '
                      '${context.tr(q.options[chosen].text)}',
                      style: text.bodyMedium,
                    ),
                    Text(
                      '${l.quizCorrectAnswer}: '
                      '${context.tr(q.options[q.correctIndex].text)}',
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(context.tr(q.basis), style: text.bodySmall),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          LgButton(label: l.quizRestart, onPressed: _start),
        ] else
          _Question(session: s, onChanged: () => setState(() {})),
        const _Refs(bgQuizRefs),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.session, required this.onChanged});

  final QuizSession session;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
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
          child: Text(context.tr(q.prompt), style: text.headlineSmall),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LgPressable(
              key: ValueKey('bg-opt-$i'),
              onTap: answered
                  ? null
                  : () {
                      if (session.answer(i)) onChanged();
                    },
              color: !answered
                  ? p.paper
                  : i == q.correctIndex
                  ? p.soft
                  : i == answer
                  ? p.amberBg
                  : p.paper,
              border: Border.all(
                color: !answered
                    ? p.line
                    : i == q.correctIndex
                    ? p.brand
                    : i == answer
                    ? p.amber
                    : p.line,
                width: answered && (i == q.correctIndex || i == answer) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(LgRadius.button),
              semanticLabel: [
                context.tr(q.options[i].text),
                if (answered && i == q.correctIndex) l.quizCorrectAnswer,
                if (answered && i == answer && i != q.correctIndex)
                  l.quizYourAnswer,
              ].join('. '),
              child: ExcludeSemantics(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(q.options[i].text),
                            style: text.bodyLarge,
                          ),
                        ),
                        if (answered && i == q.correctIndex)
                          Icon(Icons.check_circle_rounded, color: p.brand)
                        else if (answered && i == answer)
                          Icon(Icons.cancel_rounded, color: p.amber),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (answered) ...[
          LgNotice(
            context.tr(q.basis),
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
