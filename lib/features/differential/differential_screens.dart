import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/ui/content_widgets.dart';
import '../microscopy/microscopy_widgets.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart';
import '../tools/tool_screens.dart';
import 'differential_content.dart';
import 'differential_controller.dart';
import 'differential_quiz.dart';
import 'differential_sources.dart';

const _base = '/lab/differential';

/// Hujayra kartalari id lari (asosiy beshta tur). Kontent paketida bo'lsa
/// "Tahlil kartalari" bo'limida ko'rsatiladi; bo'lmasa — hech narsa.
const diffAnalyteIds = [
  'wbc-count',
  'neutrophils',
  'lymphocytes',
  'monocytes',
  'eosinophils',
  'basophils',
  'blood-smear',
];

/// Sxema → mikroskopiya atlasidagi tur (litsenziyali haqiqiy rasmlar).
const _atlasEntity = {
  'neutrophil_segmented': 'neutrophil',
  'lymphocyte_small': 'lymphocyte',
  'lymphocyte_large': 'lymphocyte',
  'monocyte': 'monocyte',
  'eosinophil': 'eosinophil',
  'basophil': 'basophil',
};

/// Lab tabining eng yuqorisidagi alohida karta.
class DifferentialEntryCard extends StatelessWidget {
  const DifferentialEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: LgPressable(
        onTap: () => context.push(_base),
        color: p.soft,
        borderRadius: BorderRadius.circular(LgRadius.card),
        semanticLabel: '${l.diffTitle}. ${l.diffLabCardBody}',
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    cellImage('neutrophil_segmented'),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.diffTitle, style: text.titleMedium),
                      const SizedBox(height: 3),
                      Text(l.diffLabCardBody, style: text.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: p.brand),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bo'lim bosh sahifasi.
class DifferentialScreen extends StatelessWidget {
  const DifferentialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    return ListenableBuilder(
      listenable: diff,
      builder: (context, _) => LgPage(
        title: l.diffTitle,
        subtitle: l.diffSubtitle,
        children: [
          LgHeroCard(
            image: AssetImage(cellImage('hero')),
            tag: l.diffDraftTag,
            title: l.diffHeroTitle,
            body: l.diffHeroBody,
            action: LgButton(
              label: diff.isEmpty
                  ? l.diffStartCount
                  : l.diffResumeCount(diff.total, diff.target),
              icon: Icons.touch_app_outlined,
              onPressed: () => context.push('$_base/count'),
            ),
          ),
          Text(
            l.diffSchematicCaption,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          LgRow(
            title: l.diffCellsTitle,
            subtitle: l.diffCellsSub(cellGuides.length),
            icon: Icons.biotech_outlined,
            onTap: () => context.push('$_base/cells'),
          ),
          LgRow(
            title: l.diffAtlasRow,
            subtitle: l.diffAtlasRowSub,
            icon: Icons.photo_library_outlined,
            onTap: () => context.push(microSectionRoute('blood')),
          ),
          LgRow(
            title: l.diffConfusionsTitle,
            subtitle: l.diffConfusionsSub,
            icon: Icons.compare_outlined,
            onTap: () => context.push('$_base/confusions'),
          ),
          LgRow(
            title: l.diffCounterTitle,
            subtitle: l.diffCounterSub,
            icon: Icons.exposure_plus_1_rounded,
            onTap: () => context.push('$_base/count'),
          ),
          LgRow(
            title: l.diffHistoryTitle,
            subtitle: l.diffHistorySub(diff.history.length),
            icon: Icons.history_rounded,
            onTap: () => context.push('$_base/history'),
          ),
          LgRow(
            title: l.diffInterpretTitle,
            subtitle: l.diffInterpretSub,
            icon: Icons.insights_outlined,
            onTap: () => context.push('$_base/interpret'),
          ),
          LgRow(
            title: l.diffTechniqueTitle,
            subtitle: l.diffTechniqueSub,
            icon: Icons.water_drop_outlined,
            onTap: () => context.push('$_base/technique'),
          ),
          LgRow(
            title: l.diffQuizTitle,
            subtitle: l.diffQuizSub(diffQuizSize),
            icon: Icons.quiz_outlined,
            onTap: () => context.push('$_base/quiz'),
            divider: false,
          ),
          LgNotice(l.diffDraftNote),
          const _RelatedCards(),
          LgSectionTitle(l.diffSourcesTitle),
          for (final (i, s) in DiffSources.all.indexed)
            CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
        ],
      ),
    );
  }
}

/// Kontent paketidagi leykotsit kartalari (bo'lsa).
class _RelatedCards extends StatelessWidget {
  const _RelatedCards({this.ids = diffAnalyteIds});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ContentGate(
      builder: (context, pack) {
        final cards = [for (final id in ids) ?pack.analyte(id)];
        if (cards.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgSectionTitle(l.diffRelatedCards),
            for (final (i, a) in cards.indexed)
              AnalyteRow(
                analyte: a,
                divider: i < cards.length - 1,
                onTap: () => openInTab(context, '/tests/analyte/${a.id}'),
              ),
          ],
        );
      },
    );
  }
}

/// Sxematik rasm: izoh bilan (mikrofoto emasligi aytiladi).
class CellPicture extends StatelessWidget {
  const CellPicture({
    super.key,
    required this.id,
    this.caption = true,
    this.maxSize = 340,
    this.semanticName,
  });

  final String id;
  final bool caption;
  final double maxSize;
  final String? semanticName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
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
                label: [?semanticName, l.diffSchematicCaption].join('. '),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LgRadius.card),
                  child: ColoredBox(
                    color: p.soft,
                    child: Image.asset(
                      cellImage(id),
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
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
                l.diffSchematicCaption,
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
            ),
          ),
      ],
    );
  }
}

/// Kichik dumaloq rasm (ro'yxat va tugmalarda) — dekorativ.
class _Thumb extends StatelessWidget {
  const _Thumb(this.id, {this.size = 56});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipOval(
      // Hujayra kichik rasmda ham ko'rinsin: markazga yaqinlashtiriladi.
      child: Transform.scale(
        scale: _thumbZoom[id] ?? 2.4,
        child: Image.asset(
          cellImage(id),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

/// Sxemadagi hujayra diametri (px, 600 lik rasmda) bo'yicha yaqinlashtirish.
const _thumbZoom = {
  'lymphocyte_small': 3.0,
  'lymphocyte_large': 2.6,
  'basophil': 2.7,
  'lymphocyte_reactive': 2.0,
  'monocyte': 1.8,
  'blast': 1.9,
  'neutrophil_hypersegmented': 2.2,
};

class _Sources extends StatelessWidget {
  const _Sources(this.refs);

  final List<CalcRef> refs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Text(
            l.diffSourcesTitle,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        for (final (i, r) in refs.indexed) CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final x in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: text.bodyMedium),
                Expanded(child: Text(x, style: text.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReferNotice extends StatelessWidget {
  const _ReferNotice();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgNotice(
      l.diffReferBody,
      title: l.diffReferTitle,
      kind: NoticeKind.error,
    );
  }
}

// ───────────────────────── Hujayralar ─────────────────────────

class DiffCellsScreen extends StatelessWidget {
  const DiffCellsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return LgPage(
      title: l.diffCellsTitle,
      subtitle: l.diffSchematicCaption,
      children: [
        Text(l.diffScaleNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        for (final (i, c) in cellGuides.indexed)
          _CellListRow(
            guide: c,
            lang: lang,
            divider: i < cellGuides.length - 1,
          ),
      ],
    );
  }
}

class _CellListRow extends StatelessWidget {
  const _CellListRow({
    required this.guide,
    required this.lang,
    required this.divider,
  });

  final CellGuide guide;
  final String lang;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: p.line.withValues(alpha: 0.7)))
            : null,
      ),
      child: LgPressable(
        onTap: () => context.push('$_base/cells/${guide.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _Thumb(guide.id),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guide.name.of(lang), style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${l.diffSize}: ${guide.size.of(lang)}',
                      style: text.bodySmall,
                    ),
                    if (guide.refer)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: LgTag(
                          l.diffReferTitle,
                          tone: LgTone.warning,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ExcludeSemantics(
                child: Icon(Icons.chevron_right_rounded, color: p.sub),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiffCellScreen extends StatelessWidget {
  const DiffCellScreen({super.key, required this.cellId});

  final String cellId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final g = cellGuide(cellId);
    if (g == null) {
      return LgPage(
        title: l.diffCellsTitle,
        children: [LgStateView(kind: StateKind.empty, title: l.diffCellsTitle)],
      );
    }
    return LgPage(
      title: g.name.of(lang),
      subtitle: l.diffCellsTitle,
      children: [
        CellPicture(id: g.id, semanticName: g.name.of(lang)),
        if (g.refer) const _ReferNotice(),
        LgNotice(g.key.of(lang), title: l.diffKeySign, kind: NoticeKind.info),
        _FeatureTable(
          rows: [
            (l.diffSize, g.size.of(lang)),
            (l.diffNucleus, g.nucleus.of(lang)),
            (l.diffCytoplasm, g.cytoplasm.of(lang)),
            (l.diffGranules, g.granules.of(lang)),
          ],
        ),
        if (g.seenIn != null) ...[
          LgSectionTitle(l.diffSeenIn),
          Text(
            g.seenIn!.of(lang),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (_atlasEntity[g.id] case final entity?) _RealSmear(entity: entity),
        if (g.analyteId != null) _RelatedCards(ids: [g.analyteId!]),
        _Sources(g.refs),
      ],
    );
  }
}

/// Mikroskopiya atlasidagi litsenziyali mikrofotolar (bo'lsa). Atlas
/// yuklanmagan yoki rasm yo'q bo'lsa — hech narsa ko'rsatilmaydi.
class _RealSmear extends StatefulWidget {
  const _RealSmear({required this.entity});

  final String entity;

  @override
  State<_RealSmear> createState() => _RealSmearState();
}

class _RealSmearState extends State<_RealSmear> {
  @override
  void initState() {
    super.initState();
    context.services.microscopy.ensureAtlas();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final micro = context.services.microscopy;
    return ListenableBuilder(
      listenable: micro,
      builder: (context, _) {
        final atlas = micro.atlas;
        final images = atlas?.imagesOf(widget.entity) ?? const [];
        if (atlas == null || images.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgSectionTitle(l.diffRealSmear),
            Text(
              l.diffRealSmearNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final i in images.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MicroImageCard(atlas: atlas, image: i),
              ),
          ],
        );
      },
    );
  }
}

/// "Belgi — qiymat" jadvali (uzun matn uchun: yorliq tepada).
class _FeatureTable extends StatelessWidget {
  const _FeatureTable({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (label, value)) in rows.indexed)
            MergeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: i < rows.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: p.line.withValues(alpha: 0.7),
                          ),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: text.labelMedium!.copyWith(color: p.brand),
                    ),
                    const SizedBox(height: 2),
                    Text(value, style: text.bodyMedium),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Adashtiriladiganlar ─────────────────────────

class DiffConfusionsScreen extends StatelessWidget {
  const DiffConfusionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.diffConfusionsTitle,
      subtitle: l.diffSchematicCaption,
      children: [for (final c in confusions) _ConfusionCard(c)],
    );
  }
}

class _ConfusionCard extends StatelessWidget {
  const _ConfusionCard(this.c);

  final Confusion c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final a = cellGuide(c.a)!;
    final b = cellGuide(c.b)!;
    Widget side(CellGuide g) => Expanded(
      child: LgPressable(
        onTap: () => context.push('$_base/cells/${g.id}'),
        borderRadius: BorderRadius.circular(16),
        semanticLabel: g.name.of(lang),
        child: Column(
          children: [
            CellPicture(
              id: g.id,
              caption: false,
              semanticName: g.name.of(lang),
            ),
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: Text(
                g.name.of(lang),
                textAlign: TextAlign.center,
                style: text.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
    return LgPanel(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              '${a.name.of(lang)} ↔ ${b.name.of(lang)}',
              style: text.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [side(a), const SizedBox(width: 10), side(b)],
          ),
          const SizedBox(height: 4),
          Text(
            l.diffSchematicCaption,
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
          const SizedBox(height: 6),
          for (final (label, va, vb) in c.rows)
            MergeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: p.line.withValues(alpha: 0.7)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      label.of(lang),
                      style: text.labelMedium!.copyWith(color: p.brand),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(va.of(lang), style: text.bodyMedium),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(vb.of(lang), style: text.bodyMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          LgNotice(c.tip.of(lang), title: l.diffTip, kind: NoticeKind.info),
          if (c.refer) const _ReferNotice(),
          _Sources(c.refs),
        ],
      ),
    );
  }
}

// ───────────────────────── Hisoblagich ─────────────────────────

String _fmt(BuildContext context, double v, {int decimals = 1}) => formatResult(
  v,
  Localizations.localeOf(context).toLanguageTag(),
  maxDecimals: decimals,
);

class DiffCounterScreen extends StatefulWidget {
  const DiffCounterScreen({super.key});

  @override
  State<DiffCounterScreen> createState() => _DiffCounterScreenState();
}

class _DiffCounterScreenState extends State<DiffCounterScreen> {
  final _wbc = TextEditingController();
  final _label = TextEditingController();
  String? _wbcError;
  bool _wbcInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wbcInit) return;
    _wbcInit = true;
    final v = context.services.differential.wbc;
    if (v != null) _wbc.text = _fmt(context, v, decimals: 2);
  }

  @override
  void dispose() {
    _wbc.dispose();
    _label.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _tap(DiffCell c) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    switch (diff.tap(c)) {
      case TapOutcome.added:
        HapticFeedback.selectionClick();
      case TapOutcome.completed:
        HapticFeedback.heavyImpact();
        SemanticsService.sendAnnouncement(
          View.of(context),
          l.diffDoneTitle(diff.target),
          Directionality.of(context),
        );
        _snack(l.diffDoneTitle(diff.target));
      case TapOutcome.blocked:
        HapticFeedback.vibrate();
        _snack(l.diffBlocked);
    }
  }

  void _decrement(DiffCell c) {
    if (context.services.differential.decrement(c)) {
      HapticFeedback.mediumImpact();
    }
  }

  void _onWbc(String raw) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    if (raw.trim().isEmpty) {
      setState(() => _wbcError = null);
      diff.setWbc(null);
      return;
    }
    final v = parseFieldNumber(context, raw);
    if (v == null || v <= 0 || !v.isFinite) {
      setState(() => _wbcError = l.diffWbcInvalid);
      diff.setWbc(null);
      return;
    }
    setState(() => _wbcError = null);
    diff.setWbc(v);
  }

  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.diffResetTitle),
        content: Text(l.diffResetBody(diff.total)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.diffResetConfirm),
          ),
        ],
      ),
    );
    if (ok ?? false) diff.reset();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final saved = await context.services.differential.save(label: _label.text);
    if (saved == null || !mounted) return;
    _label.clear();
    _snack(l.diffSaved);
  }

  Future<void> _copy(DiffRecord r) async {
    final l = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: diffReportText(context, r)));
    if (mounted) _snack(l.diffCopied);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return ListenableBuilder(
      listenable: diff,
      builder: (context, _) {
        final record = diff.current;
        return LgPage(
          title: l.diffCounterTitle,
          subtitle: l.diffTapHint,
          children: [
            _ProgressPanel(diff: diff),
            if (diff.isComplete)
              LgNotice(
                l.diffDoneBody,
                title: l.diffDoneTitle(diff.target),
                kind: NoticeKind.info,
              ),
            const SizedBox(height: 4),
            _PairGrid(
              children: [
                for (final c in DiffCell.values)
                  _CountButton(
                    cell: c,
                    name: diffCellNames[c]!.of(lang),
                    label: diffCellButton[c]!.of(lang),
                    count: diff.count(c),
                    percent: diff.total == 0
                        ? null
                        : _fmt(context, record.percent(c)),
                    done: diff.isComplete,
                    onTap: () => _tap(c),
                    onLongPress: () => _decrement(c),
                  ),
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                LgButton.secondary(
                  label: l.diffUndo,
                  icon: Icons.undo_rounded,
                  expand: false,
                  onPressed: diff.canUndo ? diff.undo : null,
                ),
                LgButton.secondary(
                  label: l.diffReset,
                  icon: Icons.restart_alt_rounded,
                  expand: false,
                  onPressed: diff.isEmpty ? null : _reset,
                ),
              ],
            ),
            LgField(
              label: l.diffWbcLabel,
              hint: l.diffWbcHint,
              controller: _wbc,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onChanged: _onWbc,
              errorText: _wbcError,
            ),
            LgSectionTitle(l.diffResultTitle),
            if (diff.isEmpty)
              Text(l.diffTapHint, style: text.bodyMedium)
            else ...[
              DiffResultTable(record: record),
              if (record.wbc == null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l.diffAbsNeedWbc,
                    style: text.bodySmall!.copyWith(color: p.sub),
                  ),
                ),
              if (diff.count(DiffCell.other) > 0)
                LgNotice(
                  l.diffOtherWarning,
                  title: l.diffReferTitle,
                  kind: NoticeKind.error,
                ),
              LgField(
                label: l.diffLabelField,
                hint: l.diffLabelHint,
                controller: _label,
                maxLength: 40,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 14),
              LgButton(
                label: l.diffSave,
                icon: Icons.save_alt_rounded,
                onPressed: _save,
              ),
              const SizedBox(height: 10),
              LgButton.secondary(
                label: l.diffCopy,
                icon: Icons.copy_rounded,
                onPressed: () => _copy(record),
              ),
            ],
            const SizedBox(height: 8),
            LgRow(
              title: l.diffHistoryTitle,
              subtitle: l.diffHistorySub(diff.history.length),
              icon: Icons.history_rounded,
              onTap: () => context.push('$_base/history'),
              divider: false,
            ),
          ],
        );
      },
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.diff});

  final DifferentialController diff;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final progress = (diff.total / diff.target).clamp(0.0, 1.0);
    return LgPanel(
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Semantics(
                liveRegion: true,
                label: '${diff.total} / ${diff.target}',
                child: ExcludeSemantics(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${diff.total}',
                          style: text.displaySmall!.copyWith(
                            color: diff.isComplete ? p.brand : p.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${diff.target}',
                          style: text.titleLarge!.copyWith(color: p.sub),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Semantics(
                label: l.diffTargetLabel,
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final t in DifferentialController.targets)
                      LgChoiceChip(
                        label: '$t',
                        selected: diff.target == t,
                        onTap: () => diff.setTarget(t),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: p.paper,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ikki ustunli to'r: shrift kattalashganda ham ikki ustun qoladi —
/// sanash paytida barcha tugmalar bir ekranga yaqin turadi. Juda tor
/// ekranda (ustun 120 px dan kichik bo'lsa) bitta ustun.
class _PairGrid extends StatelessWidget {
  const _PairGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth < 250 ? 1 : 2;
      return Column(
        children: [
          for (var i = 0; i < children.length; i += cols)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < cols; j++) ...[
                      if (j > 0) const SizedBox(width: 8),
                      Expanded(
                        child: i + j < children.length
                            ? children[i + j]
                            : const SizedBox(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// Katta sanash tugmasi: bosish +1, uzoq bosish −1 (ekran o'quvchida —
/// alohida amal).
class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.cell,
    required this.name,
    required this.label,
    required this.count,
    required this.percent,
    required this.done,
    required this.onTap,
    required this.onLongPress,
  });

  final DiffCell cell;

  /// To'liq nom (ekran o'quvchi uchun) va tugmadagi qisqa nom.
  final String name;
  final String label;
  final int count;
  final String? percent;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final active = count > 0;
    final radius = BorderRadius.circular(LgRadius.card);
    return Semantics(
      button: true,
      label: l.diffButtonSemantics(name, count),
      customSemanticsActions: {
        CustomSemanticsAction(label: l.diffDecrementAction): onLongPress,
      },
      child: ExcludeSemantics(
        child: Material(
          color: active ? p.soft : p.paper,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('diff-count-${cell.name}'),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Opacity(
              opacity: done ? 0.6 : 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 104),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Thumb(diffCellImage[cell]!, size: 40),
                          const Spacer(),
                          Flexible(
                            flex: 3,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.end,
                              style: text.headlineMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                                color: active ? p.brand : p.sub,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(label, style: text.titleSmall),
                      if (percent != null)
                        Text('$percent%', style: text.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Natija jadvali: soni, %, mutlaq son (WBC bo'lsa).
class DiffResultTable extends StatelessWidget {
  const DiffResultTable({super.key, required this.record});

  final DiffRecord record;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final hasAbs = record.wbc != null;
    final head = text.labelMedium!.copyWith(color: p.brand);
    Widget cell(String s, {TextStyle? style, bool end = true}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        s,
        textAlign: end ? TextAlign.end : TextAlign.start,
        style: style ?? text.bodyMedium,
      ),
    );
    final rows = [
      for (final c in DiffCell.values)
        if (record.count(c) > 0 || c != DiffCell.other) c,
    ];
    return LgPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Table(
        columnWidths: {
          0: const FlexColumnWidth(),
          1: const IntrinsicColumnWidth(),
          2: const IntrinsicColumnWidth(),
          if (hasAbs) 3: const IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: p.line.withValues(alpha: 0.7)),
        ),
        children: [
          TableRow(
            children: [
              cell(l.diffColCell, style: head, end: false),
              cell(l.diffColCount, style: head),
              cell('%', style: head),
              if (hasAbs) cell(l.diffColAbs, style: head),
            ],
          ),
          for (final c in rows)
            TableRow(
              children: [
                cell(diffCellNames[c]!.of(lang), end: false),
                cell('${record.count(c)}', style: text.titleSmall),
                cell(_fmt(context, record.percent(c))),
                if (hasAbs)
                  cell(_fmt(context, record.absolute(c)!, decimals: 2)),
              ],
            ),
          TableRow(
            children: [
              cell('Σ', style: text.titleSmall, end: false),
              cell('${record.total}', style: text.titleSmall),
              cell('100', style: text.titleSmall),
              if (hasAbs)
                cell(
                  _fmt(context, record.wbc!, decimals: 2),
                  style: text.titleSmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Nusxalanadigan matn (lokal formatda).
String diffReportText(BuildContext context, DiffRecord r) {
  final l = AppLocalizations.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  final b = StringBuffer(l.diffCopyHeader(r.total));
  if (r.label.isNotEmpty) b.write(' · ${r.label}');
  b.writeln();
  for (final c in DiffCell.values) {
    if (c == DiffCell.other && r.count(c) == 0) continue;
    b.write(
      '${diffCellNames[c]!.of(lang)}: ${r.count(c)} '
      '(${_fmt(context, r.percent(c))}%)',
    );
    final abs = r.absolute(c);
    if (abs != null) {
      b.write(' — ${_fmt(context, abs, decimals: 2)} ×10⁹/L');
    }
    b.writeln();
  }
  if (r.wbc != null) {
    b.writeln(l.diffWbcLine(_fmt(context, r.wbc!, decimals: 2)));
  }
  b.write(l.diffCopyFooter);
  return b.toString();
}

// ───────────────────────── Tarix ─────────────────────────

String _date(BuildContext context, DateTime t) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.yMMMd(locale).format(t)}, ${DateFormat.Hm(locale).format(t)}';
}

String _summary(BuildContext context, DiffRecord r) {
  final lang = Localizations.localeOf(context).languageCode;
  return [
    for (final c in DiffCell.values)
      if (r.count(c) > 0) '${diffCellShort[c]!.of(lang)} ${r.count(c)}',
  ].join(' · ');
}

/// Ko'rsatiladigan yozuvlar va yashirilganlar soni (`limit == null` —
/// hammasi). Ma'lumotga tegmaydi.
(List<DiffRecord>, int) visibleHistory(List<DiffRecord> all, int? limit) {
  if (limit == null || limit >= all.length) return (all, 0);
  final n = limit < 0 ? 0 : limit;
  return (all.sublist(0, n), all.length - n);
}

class DiffHistoryScreen extends StatelessWidget {
  const DiffHistoryScreen({super.key, this.visibleLimit});

  /// Ro'yxatda nechta yozuv chiziladi (`null` — hammasi). Yozuvlar baribir
  /// qurilmada to'liq saqlanadi; bu faqat ko'rsatish chegarasi.
  final int? visibleLimit;

  Future<void> _clear(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.diffHistoryClearTitle),
        content: Text(l.diffHistoryClearBody(diff.history.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (ok ?? false) await diff.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    return ListenableBuilder(
      listenable: diff,
      builder: (context, _) {
        final all = diff.history;
        final (items, hidden) = visibleHistory(all, visibleLimit);
        return LgPage(
          title: l.diffHistoryTitle,
          subtitle: l.diffHistorySub(all.length),
          children: [
            if (all.isEmpty)
              LgStateView(
                kind: StateKind.empty,
                title: l.diffHistoryEmptyTitle,
                message: l.diffHistoryEmptyBody,
                actionLabel: l.diffStartCount,
                onAction: () => context.push('$_base/count'),
              )
            else ...[
              for (final (i, r) in items.indexed)
                LgRow(
                  title: [
                    _date(context, r.savedAt),
                    if (r.label.isNotEmpty) r.label,
                  ].join(' · '),
                  subtitle: _summary(context, r),
                  icon: Icons.assignment_outlined,
                  onTap: () => context.push('$_base/history/${r.id}'),
                  divider: i < items.length - 1,
                ),
              if (hidden > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    l.diffHistoryMore(hidden),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 14),
              LgButton.secondary(
                label: l.diffHistoryClear,
                icon: Icons.delete_outline_rounded,
                onPressed: () => _clear(context),
              ),
            ],
            const SizedBox(height: 8),
            LgNotice(l.diffHistoryLocalNote, kind: NoticeKind.info),
          ],
        );
      },
    );
  }
}

class DiffRecordScreen extends StatelessWidget {
  const DiffRecordScreen({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    return ListenableBuilder(
      listenable: diff,
      builder: (context, _) {
        final r = diff.record(recordId);
        if (r == null) {
          return LgPage(
            title: l.diffHistoryTitle,
            children: [
              LgStateView(
                kind: StateKind.empty,
                title: l.diffHistoryEmptyTitle,
              ),
            ],
          );
        }
        return LgPage(
          title: _date(context, r.savedAt),
          subtitle: r.label.isEmpty ? l.diffResultTitle : r.label,
          children: [
            DiffResultTable(record: r),
            if (r.wbc == null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l.diffAbsNeedWbc,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (r.count(DiffCell.other) > 0)
              LgNotice(
                l.diffOtherWarning,
                title: l.diffReferTitle,
                kind: NoticeKind.error,
              ),
            const SizedBox(height: 14),
            LgButton(
              label: l.diffCopy,
              icon: Icons.copy_rounded,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(
                  ClipboardData(text: diffReportText(context, r)),
                );
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l.diffCopied)));
              },
            ),
            const SizedBox(height: 10),
            LgButton.secondary(
              label: l.actionDelete,
              icon: Icons.delete_outline_rounded,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final router = GoRouter.of(context);
                await diff.delete(r.id);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l.diffDeleted)));
                if (router.canPop()) router.pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// ───────────────────────── Talqin ─────────────────────────

class DiffInterpretScreen extends StatelessWidget {
  const DiffInterpretScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return LgPage(
      title: l.diffInterpretTitle,
      subtitle: l.diffTitle,
      children: [
        LgNotice(l.diffInterpretIntro),
        LgNotice(l.diffAbsNote, kind: NoticeKind.info),
        for (final f in diffFindings)
          LgPanel(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(f.title.of(lang), style: text.titleLarge),
                ),
                const SizedBox(height: 6),
                Text(f.what.of(lang), style: text.bodyMedium),
                const SizedBox(height: 10),
                Text(
                  l.diffPossibleCauses,
                  style: text.labelLarge!.copyWith(color: p.brand),
                ),
                const SizedBox(height: 6),
                _Bullets([for (final c in f.causes) c.of(lang)]),
                _Sources(f.refs),
              ],
            ),
          ),
        LgSectionTitle(l.diffRangesTitle),
        Text(l.diffRangesBody, style: text.bodyMedium),
        const SizedBox(height: 8),
        _RangesTable(lang: lang),
        // Klassik (MDH) ustun — faqat solishtirish uchun; asosiysi blanka.
        LgNotice(l.diffRangesClassicNote, kind: NoticeKind.info),
        _Sources(const [
          whoCount,
          CalcRef(DiffSources.medlineEncyDiff, 'Normal results'),
          lyubinaTable6,
        ]),
      ],
    );
  }
}

class _RangesTable extends StatelessWidget {
  const _RangesTable({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, r) in exampleRanges.indexed)
            MergeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: i < exampleRanges.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: p.line.withValues(alpha: 0.7),
                          ),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.cell.of(lang)}, %', style: text.titleSmall),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 16,
                      runSpacing: 2,
                      children: [
                        Text(
                          '${l.diffRangesWho}: ${r.who}',
                          style: text.bodyMedium,
                        ),
                        Text(
                          '${l.diffRangesMedline}: ${r.medline}',
                          style: text.bodyMedium,
                        ),
                        Text(
                          '${l.diffRangesClassic}: ${r.classic.of(lang)}',
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Texnika ─────────────────────────

class DiffTechniqueScreen extends StatelessWidget {
  const DiffTechniqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return LgPage(
      title: l.diffTechniqueTitle,
      subtitle: l.diffTitle,
      children: [
        for (final s in techniqueSections) ...[
          LgSectionTitle(s.title.of(lang)),
          if (s.numbered)
            LgSteps([for (final x in s.items) x.of(lang)])
          else
            _Bullets([for (final x in s.items) x.of(lang)]),
          _Sources(s.refs),
        ],
        const SizedBox(height: 8),
        LgNotice(l.diffDraftNote),
      ],
    );
  }
}
