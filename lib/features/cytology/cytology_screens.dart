import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../core/entitlements/feature.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../profile/pro_gate.dart';
import '../content/content_model.dart';
import '../learn/quiz_session.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart';
import '../tools/sources_panel.dart';
import 'cytology_content.dart';
import '../howto/howto_registry.dart';
import '../howto/howto_widgets.dart';

const cytoBase = '/lab/cytology';

/// Sitologiya bo'limining bosh sahifasi.
class CytologyScreen extends StatelessWidget {
  const CytologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.cytoTitle,
      subtitle: l.cytoSubtitle,
      // Bo'lim ochiq; ichidagi sahifalar — [Feature.labSections] (D-76).
      children: [
        const HowToButton(HowToSection.cytology),
        LgHeroCard(
          image: const AssetImage('assets/cytology/hero.png'),
          title: l.cytoHeroTitle,
          body: l.cytoHeroBody,
          action: LgButton(
            label: l.cytoHeroCta,
            icon: Icons.biotech_outlined,
            onPressed: () =>
                pushGated(context, Feature.labSections, '$cytoBase/cells'),
          ),
        ),
        Text(
          l.cytoSchematicCaption,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        LgRow(
          title: l.cytoCellsTitle,
          subtitle: l.cytoCellsSub(cytoCells.length),
          icon: Icons.biotech_outlined,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/cells'),
        ),
        LgRow(
          title: l.cytoDegreeTitle,
          subtitle: l.cytoDegreeSub,
          icon: Icons.tune_rounded,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/degree'),
        ),
        LgRow(
          title: l.cytoBethesdaTitle,
          subtitle: l.cytoBethesdaSub,
          icon: Icons.fact_check_outlined,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/bethesda'),
        ),
        LgRow(
          title: l.cytoTechniqueTitle,
          subtitle: l.cytoTechniqueSub,
          icon: Icons.water_drop_outlined,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/technique'),
        ),
        LgRow(
          title: l.cytoAdequacyTitle,
          subtitle: l.cytoAdequacySub,
          icon: Icons.rule_rounded,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/adequacy'),
        ),
        LgRow(
          title: l.cytoReactiveTitle,
          subtitle: l.cytoReactiveSub,
          icon: Icons.compare_arrows_rounded,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/reactive'),
        ),
        LgRow(
          title: l.cytoMaturationTitle,
          subtitle: l.cytoMaturationSub,
          icon: Icons.calculate_outlined,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/maturation'),
        ),
        LgRow(
          title: l.cytoOtherTitle,
          subtitle: l.cytoOtherSub,
          icon: Icons.science_outlined,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/other'),
        ),
        LgRow(
          title: l.cytoQuizTitle,
          subtitle: l.cytoQuizSub(cytoQuizSize),
          icon: Icons.quiz_outlined,
          onTap: () =>
              pushGated(context, Feature.labSections, '$cytoBase/quiz'),
          divider: false,
        ),
        LgNotice(l.sourcesDisclaimer, kind: NoticeKind.info),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in CytoSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

/// Sxematik rasm (mikrofoto emasligi aytiladi).
class CytoPicture extends StatelessWidget {
  const CytoPicture({
    super.key,
    required this.cell,
    this.caption = true,
    this.maxSize = 340,
  });

  final CytoCell cell;
  final bool caption;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final cap = l.cytoSchematicCaption;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxSize),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                image: true,
                label: '${cell.name.of(lang)}. $cap',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LgRadius.card),
                  child: Image.asset(
                    cytoImage(cell.id),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (caption)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ExcludeSemantics(
              child: Text(
                cap,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
      ],
    );
  }
}

class CytoCellsScreen extends StatelessWidget {
  const CytoCellsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.cytoCellsTitle,
      subtitle: l.cytoTitle,
      children: [
        for (final (i, c) in cytoCells.indexed)
          DecoratedBox(
            decoration: BoxDecoration(
              border: i < cytoCells.length - 1
                  ? Border(
                      bottom: BorderSide(color: p.line.withValues(alpha: 0.7)),
                    )
                  : null,
            ),
            child: LgPressable(
              onTap: () => context.push('$cytoBase/cells/${c.id}'),
              borderRadius: BorderRadius.circular(14),
              semanticLabel: c.name.of(lang),
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          cytoImage(c.id),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name.of(lang), style: text.titleSmall),
                            const SizedBox(height: 2),
                            Text(
                              c.key.of(lang),
                              style: text.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (c.refer)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: LgTag(
                                  l.cytoRefer,
                                  tone: LgTone.warning,
                                  icon: Icons.warning_amber_rounded,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, color: p.sub),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CytoCellScreen extends StatelessWidget {
  const CytoCellScreen({super.key, required this.cellId});

  final String cellId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = cytoCell(cellId);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    if (c == null) {
      return LgPage(
        title: l.cytoCellsTitle,
        children: [LgStateView(kind: StateKind.empty, title: l.cytoCellsTitle)],
      );
    }
    final m = cytoMarks[c.id];
    // Karta va sxema manbalari, takrorsiz.
    final seen = <String>{};
    final refs = [
      for (final r in [...c.refs, ...?m?.refs])
        if (seen.add(r.source.id)) r,
    ];
    return LgPage(
      title: c.name.of(lang),
      subtitle: l.cytoCellsTitle,
      children: [
        CytoPicture(cell: c),
        if (m != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${l.cytoMethod}:', style: text.labelLarge),
              LgTag(m.method.of(lang), tone: LgTone.neutral),
            ],
          ),
          LgSectionTitle(l.cytoMarksTitle),
          for (final (i, mk) in m.marks.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: p.brand, width: 1.5),
                      ),
                      child: Text('${i + 1}', style: text.labelMedium),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      label: '${i + 1}. ${mk.of(lang)}',
                      excludeSemantics: true,
                      child: Text(mk.of(lang), style: text.bodyMedium),
                    ),
                  ),
                ],
              ),
            ),
          LgNotice(m.caveat.of(lang), kind: NoticeKind.warning),
        ],
        if (c.refer) LgNotice(l.cytoRefer, kind: NoticeKind.warning),
        LgNotice(c.key.of(lang), title: l.cytoKey, kind: NoticeKind.info),
        _Block(title: l.cytoLook, body: c.look.of(lang)),
        _Block(title: l.cytoMeaning, body: c.meaning.of(lang)),
        if (c.confuse case final cf?)
          _Block(title: l.cytoConfuse, body: cf.of(lang)),
        const SizedBox(height: 8),
        Text(l.cytoNoPhoto, style: text.bodySmall),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Text(l.diffSourcesTitle, style: text.labelLarge),
        ),
        for (final (i, r) in refs.indexed) CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(title),
        Text(body, style: text.bodyMedium),
      ],
    );
  }
}

// ───────────────────────── Tozalik darajasi ─────────────────────────

class CytoDegreeScreen extends StatefulWidget {
  const CytoDegreeScreen({super.key});

  @override
  State<CytoDegreeScreen> createState() => _CytoDegreeScreenState();
}

class _CytoDegreeScreenState extends State<CytoDegreeScreen> {
  CytoLacto _lacto = CytoLacto.many;
  CytoLeuko _leuko = CytoLeuko.single;
  CytoFlora _flora = CytoFlora.none;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final n = cytoDegreeOf(_lacto, _leuko, _flora);
    final d = cytoDegrees[n - 1];
    Widget group<T>(
      String title,
      List<(T, String)> items,
      T value,
      void Function(T) set,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (v, label) in items)
              LgChoiceChip(
                label: label,
                selected: v == value,
                onTap: () => setState(() => set(v)),
              ),
          ],
        ),
      ],
    );
    return LgPage(
      title: l.cytoDegreeTitle,
      subtitle: l.cytoTitle,
      children: [
        const SourcesPanel([
          CalcRef(CytoSources.amsel, ''),
          CalcRef(CytoSources.nugent, ''),
          CalcRef(CytoSources.cdcBv, ''),
        ]),
        Text(l.cytoDegreeIntro, style: text.bodyMedium),
        group(
          l.cytoLacto,
          [
            (CytoLacto.many, l.cytoMany),
            (CytoLacto.few, l.cytoFew),
            (CytoLacto.none, l.cytoNone),
          ],
          _lacto,
          (v) => _lacto = v,
        ),
        group(
          l.cytoLeuko,
          [
            (CytoLeuko.single, l.cytoSingle),
            (CytoLeuko.moderate, l.cytoMany),
            (CytoLeuko.many, l.cytoVeryMany),
          ],
          _leuko,
          (v) => _leuko = v,
        ),
        group(
          l.cytoFlora,
          [
            (CytoFlora.none, l.cytoNone),
            (CytoFlora.mixed, l.cytoMixed),
            (CytoFlora.pathogenic, l.cytoPathogenic),
          ],
          _flora,
          (v) => _flora = v,
        ),
        const SizedBox(height: 14),
        Semantics(
          liveRegion: true,
          child: LgPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.cytoDegreeResult(n), style: text.headlineSmall),
                const SizedBox(height: 4),
                LgTag(
                  d.meaning.of(lang),
                  tone: n <= 2 ? LgTone.brand : LgTone.warning,
                ),
                const SizedBox(height: 8),
                Text(d.picture.of(lang), style: text.bodyMedium),
              ],
            ),
          ),
        ),
        LgSectionTitle(l.cytoDegreeTable),
        for (final g in cytoDegrees)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l.cytoDegreeResult(g.n)} · ${g.meaning.of(lang)}',
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(g.picture.of(lang), style: text.bodySmall),
                ],
              ),
            ),
          ),
        LgNotice(l.cytoDegreeNote),
        CytoCiteLines(
          cytoDegreeCites,
          key: const ValueKey('cyto-degree-cites'),
        ),
        LgNotice(l.cytoDegreeSourceNote),
        for (final (i, r) in cytoDegreeRefs.indexed)
          CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

/// "Manba: muallif, yil, «nom», bo'lim, bet" qatorlari — da'vo yonida.
class CytoCiteLines extends StatelessWidget {
  const CytoCiteLines(this.cites, {super.key});

  final List<LocalizedText> cites;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final style = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in cites)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(c.of(lang), style: style),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Bethesda ─────────────────────────

class CytoBethesdaScreen extends StatelessWidget {
  const CytoBethesdaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.cytoBethesdaTitle,
      subtitle: l.cytoTitle,
      children: [
        SourcesPanel(bethesdaRefs()),
        Text(l.cytoBethesdaIntro, style: text.bodyMedium),
        const SizedBox(height: 10),
        for (final b in bethesdaItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      LgTag(
                        b.code,
                        tone: switch (b.tone) {
                          0 => LgTone.brand,
                          1 => LgTone.neutral,
                          _ => LgTone.warning,
                        },
                      ),
                      Text(b.name.of(lang), style: text.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(b.meaning.of(lang), style: text.bodyMedium),
                  if (b.cites.isNotEmpty) CytoCiteLines(b.cites),
                ],
              ),
            ),
          ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, r) in bethesdaRefs().indexed)
          CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

/// Bethesda sahifasi manbalari: kitob, NCI va har toifa manbalari (takrorsiz).
List<CalcRef> bethesdaRefs() {
  final seen = <String>{};
  return [
    for (final r in [
      const CalcRef(CytoSources.bethesda, ''),
      const CalcRef(CytoSources.nciAbnormal, ''),
      const CalcRef(CytoSources.nciPdq, ''),
      for (final b in bethesdaItems) ...b.refs,
    ])
      if (seen.add(r.source.id)) r,
  ];
}

// ───────────────────────── Texnika ─────────────────────────

class CytoTechniqueScreen extends StatelessWidget {
  const CytoTechniqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.cytoTechniqueTitle,
      subtitle: l.cytoTitle,
      children: [
        for (final (i, s) in cytoTechnique.indexed) ...[
          LgSectionTitle('${i + 1}. ${s.title.of(lang)}'),
          Text(s.body.of(lang), style: text.bodyMedium),
        ],
        const SizedBox(height: 8),
        LgNotice(l.sourcesDisclaimer, kind: NoticeKind.info),
        for (final (i, r) in cytoTechniqueRefs.indexed)
          CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

// ───────────────────────── Mashq ─────────────────────────

/// Adashtiriladigan elementlar — chalg'ituvchi variantlar shulardan.
const _distractors = <String, List<String>>{
  'superficial': ['intermediate', 'parabasal', 'koilocyte'],
  'intermediate': ['superficial', 'parabasal', 'clue_cell'],
  'parabasal': ['metaplastic', 'hsil', 'intermediate'],
  'endocervical': ['metaplastic', 'hsil', 'parabasal'],
  'metaplastic': ['parabasal', 'hsil', 'endocervical'],
  'koilocyte': ['intermediate', 'hsil', 'superficial'],
  'clue_cell': ['lactobacilli', 'intermediate', 'koilocyte'],
  'lactobacilli': ['clue_cell', 'candida', 'inflammation'],
  'trichomonas': ['inflammation', 'candida', 'parabasal'],
  'candida': ['lactobacilli', 'trichomonas', 'clue_cell'],
  'inflammation': ['trichomonas', 'gonococcus', 'lactobacilli'],
  'gonococcus': ['inflammation', 'trichomonas', 'clue_cell'],
  'hsil': ['parabasal', 'metaplastic', 'koilocyte'],
};

class CytoQuizItem {
  const CytoQuizItem(this.cell, this.question);
  final CytoCell cell;
  final QuizQuestion question;
}

const _prompt = LocalizedText({
  'uz': 'Bu nima?',
  'ru': 'Что это?',
  'en': 'What is this?',
});

List<CytoQuizItem> buildCytoQuiz(Random rnd) {
  final ids = _distractors.keys.toList()..shuffle(rnd);
  return [
    for (final id in ids.take(cytoQuizSize))
      () {
        final opts = [id, ..._distractors[id]!]..shuffle(rnd);
        final c = cytoCell(id)!;
        return CytoQuizItem(
          c,
          QuizQuestion(
            id: 'cyto-$id',
            prompt: _prompt,
            options: [
              for (final o in opts)
                QuizOption(
                  text: cytoCell(o)!.name,
                  explanation: cytoCell(o)!.key,
                ),
            ],
            correctIndex: opts.indexOf(id),
            basis: c.key,
            refs: const [],
            reviewState: ReviewState.pending,
          ),
        );
      }(),
  ];
}

class CytoQuizScreen extends StatefulWidget {
  const CytoQuizScreen({super.key, this.random});

  final Random? random;

  @override
  State<CytoQuizScreen> createState() => _CytoQuizScreenState();
}

class _CytoQuizScreenState extends State<CytoQuizScreen> {
  List<CytoQuizItem>? _items;
  QuizSession? _session;

  void _start() => setState(() {
    _items = buildCytoQuiz(widget.random ?? Random());
    _session = QuizSession([for (final i in _items!) i.question]);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final s = _session;
    return LgPage(
      key: ValueKey((s == null, s?.index, s?.finished)),
      title: l.cytoQuizTitle,
      subtitle: l.cytoTitle,
      children: [
        if (s == null) ...[
          CytoPicture(cell: cytoCell('koilocyte')!, maxSize: 240),
          const SizedBox(height: 12),
          Text(l.cytoQuizIntro, style: text.bodyLarge),
          const SizedBox(height: 16),
          LgButton(label: l.cytoQuizStart, onPressed: _start),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LgPanel(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        child: CytoPicture(
                          cell: _items!.firstWhere((i) => i.question == q).cell,
                          caption: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l.quizYourAnswer}: '
                              '${q.options[chosen].text.of(lang)}',
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
              ),
          const SizedBox(height: 16),
          LgButton(label: l.quizRestart, onPressed: _start),
        ] else
          _Question(
            session: s,
            cell: _items![s.index].cell,
            onChanged: () => setState(() {}),
          ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.session,
    required this.cell,
    required this.onChanged,
  });

  final QuizSession session;
  final CytoCell cell;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
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
        // Rasm javobni oshkor qilmasligi uchun ekran o'quvchiga nom
        // aytilmaydi (faqat izoh).
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                image: true,
                label: l.cytoSchematicCaption,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LgRadius.card),
                  child: Image.asset(
                    cytoImage(cell.id),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(q.prompt.of(lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LgPressable(
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
                q.options[i].text.of(lang),
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
                            q.options[i].text.of(lang),
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
