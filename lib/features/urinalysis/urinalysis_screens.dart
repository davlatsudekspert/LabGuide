import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../learn/quiz_session.dart';
import '../microscopy/microscopy_atlas.dart';
import '../microscopy/microscopy_widgets.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import '../tools/manual_calc_info.dart';
import '../tools/manual_calc_screens.dart';
import '../tools/sources_panel.dart';
import '../lab/lab_links.dart';
import 'urinalysis_content.dart';
import 'urinalysis_logic.dart';
import '../howto/howto_registry.dart';
import '../howto/howto_widgets.dart';

const urinBase = '/lab/urinalysis';
const urinCardImage = 'assets/urinalysis/card.png';

/// Pack'dagi siydik kartalari (nusxa emas — id bo'yicha havola).
const urinAnalyteIds = [
  'urine-chemistry',
  'urine-microscopy',
  'urine-24h',
  'urine-culture',
];

/// Bog'liq qo'lda hisoblash usullari (takrorlanmaydi — havola).
const urinManualCalcs = [
  ManualCalc.nechiporenko,
  ManualCalc.addis,
  ManualCalc.zimnitsky,
];

String urElementRoute(String id) => '$urinBase/sediment/$id';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, r) in refs.indexed) CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

/// Da'vo matni va manba raqamlari ([refs] ro'yxatidagi o'rni): "… [1, 3]".
String _marked(BuildContext context, UrFact f, List<CalcRef> refs) {
  final n = {
    for (final r in f.refs)
      refs.indexWhere(
            (x) => x.source.id == r.source.id && x.locator == r.locator,
          ) +
          1,
  }.toList()..sort();
  return '${context.tr(f.text)} [${n.join(', ')}]';
}

/// Belgili ro'yxat bandi.
class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExcludeSemantics(child: Text('•  ')),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Bo'limlar (sarlavha + manbali bandlar) va oxirida manbalar.
class _SectionsPage extends StatelessWidget {
  const _SectionsPage({
    required this.title,
    required this.sections,
    this.extra = const [],
  });

  final LocalizedText title;
  final List<UrSection> sections;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final refs = urRefsOf([for (final s in sections) ...s.facts]);
    return LgPage(
      title: context.tr(title),
      subtitle: l.urinTitle,
      children: [
        const SourcesPanel(urLeadRefs),
        for (final s in sections) ...[
          LgSectionTitle(context.tr(s.title)),
          for (final f in s.facts) _Bullet(_marked(context, f, refs)),
        ],
        ...extra,
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

/// Qo'lda hisoblash usuliga havola.
class _CalcRow extends StatelessWidget {
  const _CalcRow(this.calc, {this.divider = true});

  final ManualCalc calc;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgRow(
      key: ValueKey('urin-calc-${manualCalcRoute(calc)}'),
      title: manualCalcTitle(calc, l),
      subtitle: manualCalcSubtitle(calc, l),
      icon: manualCalcIcon(calc),
      onTap: () => context.push('/lab/calculators/${manualCalcRoute(calc)}'),
      divider: divider,
    );
  }
}

/// Albumin/kreatinin nisbati kalkulyatoriga havola.
class _AcrRow extends StatelessWidget {
  const _AcrRow({this.divider = true});

  final bool divider;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgRow(
      key: const ValueKey('urin-calc-acr'),
      title: l.calcAcr,
      subtitle: l.calcAcrSub,
      icon: Icons.opacity_rounded,
      onTap: () => context.push('/lab/calculators/acr'),
      divider: divider,
    );
  }
}

/// Atlas rasmining yo'li (atlas tekshiruvi: `assets/microscopy/img/<id>.jpg`).
String urAtlasAsset(String atlasId) => 'assets/microscopy/img/$atlasId.jpg';

// ───────────────────────── Bosh sahifa ─────────────────────────

class UrinalysisScreen extends StatelessWidget {
  const UrinalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (UrL.collectTitle, UrL.collectSub, Icons.science_outlined, 'collect'),
      (UrL.physicalTitle, UrL.physicalSub, Icons.palette_outlined, 'physical'),
      (UrL.stripTitle, UrL.stripSub, Icons.view_week_outlined, 'strip'),
      (UrL.sedimentTitle, UrL.sedimentSub, Icons.biotech_outlined, 'sediment'),
      (UrL.readerTitle, UrL.readerSub, Icons.fact_check_outlined, 'reader'),
      (UrL.quizTitle, UrL.quizSub, Icons.quiz_outlined, 'quiz'),
    ];
    return LgPage(
      title: l.urinTitle,
      subtitle: context.tr(UrL.subtitle),
      children: [
        const HowToButton(HowToSection.urinalysis),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  urinCardImage,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Tashxis eslatmasi alohida (keyingi qator) — panelda takrorlanmaydi.
        const SourcesPanel(urLeadRefs, disclaimer: false),
        LgNotice(context.tr(UrL.notDiagnosis), kind: NoticeKind.info),
        for (final (i, (title, sub, icon, path)) in rows.indexed)
          LgRow(
            key: ValueKey('urin-row-$path'),
            title: context.tr(title),
            subtitle: context.tr(sub),
            icon: icon,
            onTap: () => context.push('$urinBase/$path'),
            divider: i < rows.length - 1,
          ),
        LgSectionTitle(context.tr(UrL.relatedTitle)),
        for (final c in urinManualCalcs) _CalcRow(c),
        const _AcrRow(),
        LgRow(
          key: const ValueKey('urin-atlas'),
          title: l.micTitle,
          subtitle: l.labMicroscopySub,
          icon: Icons.photo_library_outlined,
          onTap: () => context.push(microSectionRoute('urine')),
          divider: false,
        ),
        LgSectionTitle(context.tr(UrL.relatedCardsTitle)),
        ContentGate(
          builder: (context, pack) {
            final cards = [for (final id in urinAnalyteIds) ?pack.analyte(id)];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, card) in cards.indexed)
                  AnalyteRow(
                    key: ValueKey('urin-card-${card.id}'),
                    analyte: card,
                    divider: i < cards.length - 1,
                    onTap: () => openLabAnalyte(context, card.id),
                  ),
              ],
            );
          },
        ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in UrSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

// ───────────────────────── 1–2. Yig'ish, fizik xossalar ─────────────────────────

class UrCollectScreen extends StatelessWidget {
  const UrCollectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionsPage(
      title: UrL.collectTitle,
      sections: urCollectSections,
      extra: [
        LgSectionTitle(context.tr(UrL.relatedTitle)),
        const _CalcRow(ManualCalc.nechiporenko),
        const _CalcRow(ManualCalc.addis, divider: false),
      ],
    );
  }
}

class UrPhysicalScreen extends StatelessWidget {
  const UrPhysicalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionsPage(
      title: UrL.physicalTitle,
      sections: urPhysicalSections,
      extra: [
        LgSectionTitle(context.tr(UrL.relatedTitle)),
        const _CalcRow(ManualCalc.zimnitsky, divider: false),
      ],
    );
  }
}

// ───────────────────────── 3. Test-chiziq ─────────────────────────

class UrStripScreen extends StatelessWidget {
  const UrStripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final refs = urRefsOf([
      ...urStripGeneral,
      for (final p in urPads) ...p.facts,
    ]);
    Widget part(LocalizedText head, UrFact? f) => f == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(head), style: text.labelLarge),
                const SizedBox(height: 2),
                Text(_marked(context, f, refs), style: text.bodyMedium),
              ],
            ),
          );
    return LgPage(
      title: context.tr(UrL.stripTitle),
      subtitle: l.urinTitle,
      children: [
        const SourcesPanel(urLeadRefs),
        LgSectionTitle(context.tr(UrL.sectionGeneral)),
        for (final f in urStripGeneral) _Bullet(_marked(context, f, refs)),
        for (final p in urPads) ...[
          LgSectionTitle(context.tr(p.name)),
          LgPanel(
            key: ValueKey('urin-pad-${p.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                part(UrL.detects, p.detects),
                part(UrL.mayPoint, p.mayPoint),
                part(UrL.falsePos, p.falsePos),
                part(UrL.falseNeg, p.falseNeg),
                part(UrL.next, p.next),
              ],
            ),
          ),
        ],
        LgSectionTitle(context.tr(UrL.relatedTitle)),
        const _AcrRow(divider: false),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── 4. Cho'kma ─────────────────────────

class UrSedimentScreen extends StatelessWidget {
  const UrSedimentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final refs = urRefsOf([...urSedimentIntro, urSedimentCrystalsNote]);
    return LgPage(
      title: context.tr(UrL.sedimentTitle),
      subtitle: l.urinTitle,
      children: [
        const SourcesPanel(urLeadRefs),
        LgSectionTitle(context.tr(UrL.preparationTitle)),
        for (final f in urSedimentIntro) _Bullet(_marked(context, f, refs)),
        const _CalcRow(ManualCalc.nechiporenko),
        const _CalcRow(ManualCalc.addis, divider: false),
        for (final g in UrGroup.values) ...[
          LgSectionTitle(context.tr(UrL.groups[g]!)),
          if (g == UrGroup.crystals)
            _Bullet(_marked(context, urSedimentCrystalsNote, refs)),
          for (final e in urElements.where((e) => e.group == g))
            _ElementRow(element: e),
        ],
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

class _ElementRow extends StatelessWidget {
  const _ElementRow({required this.element});

  final UrElement element;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final name = context.tr(element.name);
    final pic = element.pics.firstOrNull;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.7)),
        ),
      ),
      child: LgPressable(
        key: ValueKey('urin-el-${element.id}'),
        onTap: () => context.push(urElementRoute(element.id)),
        borderRadius: BorderRadius.circular(14),
        semanticLabel: name,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: pic == null
                      ? Container(
                          width: 64,
                          height: 64,
                          color: p.soft,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: p.sub,
                          ),
                        )
                      : Image(
                          image: ResizeImage(
                            AssetImage(urAtlasAsset(pic.atlasId)),
                            width: MicroThumb.small,
                          ),
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
                      Text(name, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(element.meaning.text),
                        style: text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
    );
  }
}

/// Atlas rasmi: rasm (bosilsa — atlasda to'liq ko'rinish), panel izohi,
/// atlasning "nom manbaga ko'ra" eslatmasi, muallif va litsenziya.
class _AtlasPicture extends StatelessWidget {
  const _AtlasPicture({
    required this.atlas,
    required this.pic,
    required this.name,
  });

  final MicroAtlas atlas;
  final UrPic pic;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final image = atlas.image(pic.atlasId);
    if (image == null) return const SizedBox.shrink();
    final panel = pic.panel;
    final labelNote = image.labelNote;
    return Column(
      key: ValueKey('urin-pic-${pic.atlasId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 320,
              maxWidth: 320 * image.aspectRatio,
            ),
            child: LgPressable(
              onTap: () => context.push(microImageRoute(image.id)),
              borderRadius: BorderRadius.circular(LgRadius.card),
              semanticLabel: '$name. ${context.tr(UrL.openAtlas)}',
              child: ExcludeSemantics(
                child: MicroPicture(image: image, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (panel != null)
          Text(context.tr(urPanelNote(panel)), style: text.bodyMedium),
        if (labelNote != null) ...[
          const SizedBox(height: 4),
          LgNotice(
            labelNote.of(Localizations.localeOf(context).languageCode),
            title: l.micLabelBySource,
            kind: NoticeKind.info,
          ),
        ],
        LgMetric(label: l.micAuthor, value: image.author),
        LgMetric(label: l.micLicense, value: image.license),
        LgRow(
          key: ValueKey('urin-open-atlas-${image.id}'),
          title: context.tr(UrL.openAtlas),
          icon: Icons.open_in_new_rounded,
          onTap: () => context.push(microImageRoute(image.id)),
          divider: false,
        ),
      ],
    );
  }
}

class UrElementScreen extends StatelessWidget {
  const UrElementScreen({super.key, required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    final element = urElement(elementId);
    if (element == null) {
      return LgPage(
        title: context.tr(UrL.sedimentTitle),
        children: [
          LgStateView(
            kind: StateKind.empty,
            title: context.tr(UrL.sedimentTitle),
          ),
        ],
      );
    }
    final name = context.tr(element.name);
    final refs = element.refs;
    Widget body(MicroAtlas? atlas) => LgPage(
      title: name,
      subtitle: context.tr(UrL.groups[element.group]!),
      children: [
        const SourcesPanel(urLeadRefs),
        if (element.pics.isEmpty)
          LgNotice(
            context.tr(UrL.noPhoto),
            kind: NoticeKind.info,
            key: const ValueKey('urin-no-photo'),
          )
        else if (atlas != null) ...[
          LgSectionTitle(context.tr(UrL.imageTitle)),
          for (final pic in element.pics) ...[
            _AtlasPicture(atlas: atlas, pic: pic, name: name),
            const SizedBox(height: 8),
          ],
        ],
        LgSectionTitle(context.tr(UrL.lookTitle)),
        for (final f in element.look) _Bullet(_marked(context, f, refs)),
        LgSectionTitle(context.tr(UrL.meaningTitle)),
        LgNotice(
          _marked(context, element.meaning, refs),
          kind: NoticeKind.info,
        ),
        if (element.confuse case final c?) ...[
          LgSectionTitle(context.tr(UrL.confuseTitle)),
          _Bullet(_marked(context, c, refs)),
        ],
        const SizedBox(height: 6),
        _Refs(refs),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            context.tr(UrL.notDiagnosis),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
    if (element.pics.isEmpty) return body(null);
    return MicroAtlasGate(
      fallbackTitle: name,
      builder: (context, atlas) => body(atlas),
    );
  }
}

// ───────────────────────── 5. Natijani o'qish ─────────────────────────

class UrReaderScreen extends StatefulWidget {
  const UrReaderScreen({super.key});

  @override
  State<UrReaderScreen> createState() => _UrReaderScreenState();
}

class _UrReaderScreenState extends State<UrReaderScreen> {
  final _selected = <UrFinding>{};

  Widget _chips(UrFindingKind kind) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final f in UrFinding.values)
        if (urFindingInfo[f]!.kind == kind)
          LgChoiceChip(
            key: ValueKey('urin-find-${f.name}'),
            label: context.tr(urFindingInfo[f]!.label),
            selected: _selected.contains(f),
            onTap: () => setState(() {
              if (!_selected.remove(f)) _selected.add(f);
            }),
          ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final r = readUrinalysis(_selected);
    final facts = [
      for (final f in r.findings) urFindingInfo[f]!.note,
      for (final c in r.combos) urComboInfo[c]!,
    ];
    final refs = urRefsOf(facts);
    return LgPage(
      title: context.tr(UrL.readerTitle),
      subtitle: l.urinTitle,
      children: [
        const SourcesPanel(urLeadRefs),
        Text(context.tr(UrL.readerIntro), style: text.bodyMedium),
        LgSectionTitle(context.tr(UrL.readerStrip)),
        _chips(UrFindingKind.strip),
        LgSectionTitle(context.tr(UrL.readerSediment)),
        _chips(UrFindingKind.sediment),
        const SizedBox(height: 10),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LgButton(
            key: const ValueKey('urin-reader-reset'),
            label: context.tr(UrL.readerReset),
            kind: LgButtonKind.secondary,
            onPressed: () => setState(_selected.clear),
          ),
        ),
        const SizedBox(height: 8),
        if (r.isEmpty)
          Text(
            context.tr(UrL.readerEmpty),
            key: const ValueKey('urin-reader-empty'),
            style: text.bodyMedium,
          )
        else ...[
          LgSectionTitle(context.tr(UrL.readerSingleTitle)),
          for (final f in r.findings)
            Padding(
              key: ValueKey('urin-res-${f.name}'),
              padding: const EdgeInsets.only(bottom: 8),
              child: LgPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(urFindingInfo[f]!.label),
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _marked(context, urFindingInfo[f]!.note, refs),
                      style: text.bodyMedium,
                    ),
                    if (urFindingInfo[f]!.element case final id?)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: () => context.push(urElementRoute(id)),
                          child: Text(context.tr(UrL.readerOpenCard)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (r.combos.isNotEmpty) ...[
            LgSectionTitle(context.tr(UrL.readerComboTitle)),
            for (final c in r.combos)
              LgNotice(
                _marked(context, urComboInfo[c]!, refs),
                key: ValueKey('urin-combo-${c.name}'),
                kind: NoticeKind.info,
              ),
          ],
          LgNotice(
            context.tr(UrL.readerReferral),
            key: const ValueKey('urin-reader-referral'),
            kind: NoticeKind.warning,
          ),
          const SizedBox(height: 6),
          _Refs(refs),
        ],
      ],
    );
  }
}

// ───────────────────────── 6. Mashq ─────────────────────────

class UrQuizScreen extends StatefulWidget {
  const UrQuizScreen({super.key, this.random});

  final Random? random;

  @override
  State<UrQuizScreen> createState() => _UrQuizScreenState();
}

class _UrQuizScreenState extends State<UrQuizScreen> {
  List<UrQuizQuestion>? _items;
  QuizSession? _session;

  void _start() => setState(() {
    _items = buildUrQuiz(widget.random ?? Random());
    _session = QuizSession([for (final i in _items!) i.question]);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MicroAtlasGate(
      fallbackTitle: context.tr(UrL.quizTitle),
      builder: (context, atlas) {
        final text = Theme.of(context).textTheme;
        final s = _session;
        return LgPage(
          key: ValueKey((s == null, s?.index, s?.finished)),
          title: context.tr(UrL.quizTitle),
          subtitle: l.urinTitle,
          children: [
            if (s == null) ...[
              Text(context.tr(UrL.quizIntro), style: text.bodyLarge),
              const SizedBox(height: 16),
              LgButton(
                key: const ValueKey('urin-quiz-start'),
                label: context.tr(UrL.quizStart),
                onPressed: _start,
              ),
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
                  ),
              const SizedBox(height: 16),
              LgButton(label: l.quizRestart, onPressed: _start),
            ] else
              _Question(
                session: s,
                item: _items![s.index],
                atlas: atlas,
                onChanged: () => setState(() {}),
              ),
          ],
        );
      },
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.session,
    required this.item,
    required this.atlas,
    required this.onChanged,
  });

  final QuizSession session;
  final UrQuizQuestion item;
  final MicroAtlas atlas;
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
    final image = item.atlasId == null ? null : atlas.image(item.atlasId!);
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
        if (image != null) ...[
          // Javobni oshkor qilmaslik uchun ekran o'quvchiga nom aytilmaydi.
          Center(
            child: ConstrainedBox(
              key: ValueKey('urin-quiz-photo-${image.id}'),
              constraints: BoxConstraints(
                maxHeight: 260,
                maxWidth: 260 * image.aspectRatio,
              ),
              child: MicroPicture(
                image: image,
                fit: BoxFit.contain,
                semanticLabel: context.tr(UrL.quizImageLabel),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Semantics(
          header: true,
          child: Text(context.tr(q.prompt), style: text.titleLarge),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LgPressable(
              key: ValueKey('urin-opt-$i'),
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
            item.isPicture
                ? [
                    if (answer != q.correctIndex)
                      '${context.tr(q.options[answer].text)}: '
                          '${context.tr(q.options[answer].explanation)}',
                    '${context.tr(q.options[q.correctIndex].text)}: '
                        '${context.tr(q.options[q.correctIndex].explanation)}',
                  ].join('\n\n')
                : context.tr(q.basis),
            title: answer == q.correctIndex ? l.quizCorrect : l.quizIncorrect,
            kind: answer == q.correctIndex
                ? NoticeKind.info
                : NoticeKind.warning,
          ),
          const SizedBox(height: 8),
          LgButton(
            key: const ValueKey('urin-quiz-next'),
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
