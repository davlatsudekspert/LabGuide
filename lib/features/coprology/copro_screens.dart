import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../classroom/lecture_library.dart' show openDeck;
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import 'copro_content.dart';
import 'copro_scheme.dart';

const coproBase = '/lab/coprology';
const coproCardImage = 'assets/coprology/card.png';

/// Pack'dagi najas kartalari (havola).
const coproAnalyteIds = [
  'stool-analysis',
  'stool-ova-parasites',
  'pinworm-test',
  'fecal-occult-blood',
];

const coproRoutes = ['collect', 'macro', 'micro', 'occult', 'parasites'];

String cpElementRoute(String id) => '$coproBase/micro/$id';
String cpParasiteRoute(String id) => '$coproBase/parasites/$id';

extension on BuildContext {
  String get _lang => Localizations.localeOf(this).languageCode;

  String tr(LocalizedText t) => t.of(_lang);
}

class _DraftNotice extends StatelessWidget {
  const _DraftNotice();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgNotice(context.tr(CpL.draftNote), title: l.diffDraftTag);
  }
}

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

String _marked(BuildContext context, CpFact f, List<CalcRef> refs) {
  final n = {
    for (final r in f.refs)
      refs.indexWhere(
            (x) => x.source.id == r.source.id && x.locator == r.locator,
          ) +
          1,
  }.toList()..sort();
  return '${context.tr(f.text)} [${n.join(', ')}]';
}

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

class _DeckRow extends StatelessWidget {
  const _DeckRow(this.deck, {this.divider = false});

  final CpDeck deck;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return LgRow(
      key: ValueKey('copro-deck-${deck.id}'),
      title: context.tr(deck.title),
      subtitle: context.tr(CpL.relatedTitle),
      icon: Icons.slideshow_outlined,
      onTap: () => openDeck(context, deck.id),
      divider: divider,
    );
  }
}

class _SectionsPage extends StatelessWidget {
  const _SectionsPage({
    required this.title,
    required this.sections,
    this.extra = const [],
  });

  final LocalizedText title;
  final List<CpSection> sections;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final refs = cpRefsOf([for (final s in sections) ...s.facts]);
    return LgPage(
      title: context.tr(title),
      subtitle: l.coproTitle,
      children: [
        const _DraftNotice(),
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

// ───────────────────────── Bosh sahifa ─────────────────────────

class CoprologyScreen extends StatelessWidget {
  const CoprologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (CpL.collectTitle, CpL.collectSub, Icons.inventory_2_outlined),
      (CpL.macroTitle, CpL.macroSub, Icons.visibility_outlined),
      (CpL.microTitle, CpL.microSub, Icons.biotech_outlined),
      (CpL.occultTitle, CpL.occultSub, Icons.bloodtype_outlined),
      (CpL.parasitesTitle, CpL.parasitesSub, Icons.bug_report_outlined),
    ];
    return LgPage(
      title: l.coproTitle,
      subtitle: context.tr(CpL.subtitle),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  coproCardImage,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const _DraftNotice(),
        LgNotice(context.tr(CpL.notDiagnosis), kind: NoticeKind.info),
        for (final (i, (title, sub, icon)) in rows.indexed)
          LgRow(
            key: ValueKey('copro-row-${coproRoutes[i]}'),
            title: context.tr(title),
            subtitle: context.tr(sub),
            icon: icon,
            onTap: () => context.push('$coproBase/${coproRoutes[i]}'),
            divider: i < rows.length - 1,
          ),
        LgSectionTitle(context.tr(CpL.relatedTitle)),
        for (final (i, d) in cpDecks.indexed)
          _DeckRow(d, divider: i < cpDecks.length - 1),
        LgSectionTitle(context.tr(CpL.relatedCardsTitle)),
        ContentGate(
          builder: (context, pack) {
            final cards = [for (final id in coproAnalyteIds) ?pack.analyte(id)];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, card) in cards.indexed)
                  AnalyteRow(
                    key: ValueKey('copro-card-${card.id}'),
                    analyte: card,
                    divider: i < cards.length - 1,
                    onTap: () => openInTab(
                      context,
                      '/tests/analyte/${card.id}',
                      exact: true,
                    ),
                  ),
              ],
            );
          },
        ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in CpSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

// ───────────────────────── Yig'ish, makroskopiya, yashirin qon ─────────────────────────

class CpCollectScreen extends StatelessWidget {
  const CpCollectScreen({super.key});

  @override
  Widget build(BuildContext context) => const _SectionsPage(
    title: CpL.collectTitle,
    sections: cpCollectSections,
    extra: [_DeckRow(cpDeckCoprogram), _DeckRow(cpDeckParasites)],
  );
}

class CpMacroScreen extends StatelessWidget {
  const CpMacroScreen({super.key});

  @override
  Widget build(BuildContext context) => const _SectionsPage(
    title: CpL.macroTitle,
    sections: cpMacroSections,
    extra: [_DeckRow(cpDeckCoprogram)],
  );
}

class CpOccultScreen extends StatelessWidget {
  const CpOccultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionsPage(
      title: CpL.occultTitle,
      sections: cpOccultSections,
      extra: [
        LgNotice(context.tr(CpL.notDiagnosis), kind: NoticeKind.info),
        const _AnalyteLink('fecal-occult-blood'),
      ],
    );
  }
}

/// Pack kartasiga havola (matnli tugma).
class _AnalyteLink extends StatelessWidget {
  const _AnalyteLink(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(
        key: ValueKey('copro-analyte-$id'),
        onPressed: () => openInTab(context, '/tests/analyte/$id', exact: true),
        child: Text(context.tr(CpL.openCard)),
      ),
    );
  }
}

// ───────────────────────── Mikroskopiya ─────────────────────────

class CpMicroScreen extends StatelessWidget {
  const CpMicroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final refs = cpRefsOf(cpMicroIntro);
    return LgPage(
      title: context.tr(CpL.microTitle),
      subtitle: l.coproTitle,
      children: [
        const _DraftNotice(),
        for (final f in cpMicroIntro) _Bullet(_marked(context, f, refs)),
        LgSectionTitle(context.tr(CpL.microTitle)),
        for (final (i, e) in cpElements.indexed)
          LgRow(
            key: ValueKey('copro-el-${e.id}'),
            title: context.tr(e.name),
            subtitle: context.tr(e.normal.text),
            icon: Icons.circle_outlined,
            onTap: () => context.push(cpElementRoute(e.id)),
            divider: i < cpElements.length - 1,
          ),
        const SizedBox(height: 6),
        Text(
          context.tr(CpL.notDiagnosis),
          style: text.bodySmall?.copyWith(color: p.sub),
        ),
        const _DeckRow(cpDeckCoprogram),
        _Refs(refs),
      ],
    );
  }
}

class CpElementScreen extends StatelessWidget {
  const CpElementScreen({super.key, required this.elementId});

  final String elementId;

  @override
  Widget build(BuildContext context) {
    final e = cpElement(elementId);
    if (e == null) {
      return LgPage(
        title: context.tr(CpL.microTitle),
        children: [
          LgStateView(kind: StateKind.empty, title: context.tr(CpL.microTitle)),
        ],
      );
    }
    final refs = e.refs;
    return LgPage(
      title: context.tr(e.name),
      subtitle: context.tr(CpL.microTitle),
      children: [
        const _DraftNotice(),
        LgSectionTitle(context.tr(CpL.elementLookTitle)),
        for (final f in e.look) _Bullet(_marked(context, f, refs)),
        LgSectionTitle(context.tr(CpL.normalTitle)),
        _Bullet(_marked(context, e.normal, refs)),
        LgSectionTitle(context.tr(CpL.meaningTitle)),
        for (final f in e.meaning)
          LgNotice(_marked(context, f, refs), kind: NoticeKind.info),
        if (e.confuse case final c?) ...[
          LgSectionTitle(context.tr(CpL.confuseTitle)),
          _Bullet(_marked(context, c, refs)),
        ],
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Parazitlar ─────────────────────────

class CpParasitesScreen extends StatelessWidget {
  const CpParasitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final refs = cpRefsOf([
      ...cpConcentration,
      for (final p in cpParasites) CpFact(p.common, [p.size.ref]),
      CpFact(CpL.sizeChartRbc, [cpRbcSize.ref]),
    ]);
    return LgPage(
      title: context.tr(CpL.parasitesTitle),
      subtitle: l.coproTitle,
      children: [
        const _DraftNotice(),
        LgSectionTitle(context.tr(CpL.concentrationTitle)),
        for (final f in cpConcentration) _Bullet(_marked(context, f, refs)),
        LgSectionTitle(context.tr(CpL.parasiteListTitle)),
        for (final p in cpParasites)
          _ParasiteRow(key: ValueKey('copro-par-${p.id}'), parasite: p),
        LgSectionTitle(context.tr(CpL.sizeChartTitle)),
        LgPanel(
          key: const ValueKey('copro-size-chart'),
          child: CpSizeChart(
            unit: context.tr(CpL.microUnit),
            rows: [
              (context.tr(CpL.sizeChartRbc), cpRbcSize),
              for (final p in cpParasites)
                (
                  '${p.latin.split(' ').first} (${context.tr(p.stage).toLowerCase()})',
                  p.size,
                ),
            ],
          ),
        ),
        Text(context.tr(CpL.schemeNote), style: text.bodySmall),
        LgSectionTitle(context.tr(CpL.relatedTitle)),
        const _DeckRow(cpDeckParasites, divider: true),
        const _DeckRow(cpDeckPinworm),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

class _ParasiteRow extends StatelessWidget {
  const _ParasiteRow({super.key, required this.parasite});

  final CpParasite parasite;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final name = '${parasite.latin} — ${context.tr(parasite.common)}';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.7)),
        ),
      ),
      child: LgPressable(
        onTap: () => context.push(cpParasiteRoute(parasite.id)),
        borderRadius: BorderRadius.circular(14),
        semanticLabel: name,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: p.paper,
                    child: CpSchematic(shape: parasite.shape, size: 64),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parasite.latin,
                        style: text.titleSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${context.tr(parasite.common)} · '
                        '${context.tr(parasite.stage)}',
                        style: text.bodySmall,
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

class CpParasiteScreen extends StatelessWidget {
  const CpParasiteScreen({super.key, required this.parasiteId});

  final String parasiteId;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final par = cpParasite(parasiteId);
    if (par == null) {
      return LgPage(
        title: context.tr(CpL.parasitesTitle),
        children: [
          LgStateView(
            kind: StateKind.empty,
            title: context.tr(CpL.parasitesTitle),
          ),
        ],
      );
    }
    final refs = par.refs;
    return LgPage(
      title: par.latin,
      subtitle: '${context.tr(par.common)} · ${context.tr(par.stage)}',
      children: [
        const _DraftNotice(),
        LgPanel(
          key: ValueKey('copro-scheme-${par.id}'),
          soft: true,
          child: Column(
            children: [
              Semantics(
                image: true,
                label: '${context.tr(CpL.schemeLabel)}: ${par.latin}',
                child: CpSchematic(shape: par.shape, size: 200),
              ),
              const SizedBox(height: 6),
              LgTag(context.tr(CpL.schemeLabel), tone: LgTone.neutral),
              const SizedBox(height: 6),
              Text(
                context.tr(CpL.schemeNote),
                style: text.bodySmall?.copyWith(color: p.sub),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        LgSectionTitle(context.tr(CpL.lookTitle)),
        for (final f in par.look) _Bullet(_marked(context, f, refs)),
        LgSectionTitle(context.tr(CpL.notesTitle)),
        for (final f in par.notes) _Bullet(_marked(context, f, refs)),
        _AnalyteLink(par.analyteId),
        if (par.id == 'enterobius') const _DeckRow(cpDeckPinworm),
        const SizedBox(height: 6),
        _Refs(refs),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(context.tr(CpL.notDiagnosis), style: text.bodySmall),
        ),
      ],
    );
  }
}
