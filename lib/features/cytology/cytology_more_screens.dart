import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart';
import '../tools/sources_panel.dart';
import '../tools/tool_screens.dart' show formatResult;
import 'cytology_more.dart';

/// Manbalar ro'yxati (takrorsiz, birinchi uchragan lokator bilan).
List<CalcRef> _uniqueRefs(Iterable<CalcRef> refs) {
  final seen = <String>{};
  return [
    for (final r in refs)
      if (seen.add(r.source.id)) r,
  ];
}

/// Sahifa pastidagi manbalar bloki.
List<Widget> _sources(BuildContext context, Iterable<CalcRef> refs) {
  final l = AppLocalizations.of(context);
  return [
    LgSectionTitle(l.diffSourcesTitle),
    for (final (i, r) in _uniqueRefs(refs).indexed)
      CalcSourceTile(index: i + 1, ref: r),
  ];
}

/// Bitta band: sarlavha, matn va lokatorli manbalar (kichik matnda).
class _FactPanel extends StatelessWidget {
  const _FactPanel(this.fact);

  final CytoFact fact;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LgPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fact.title.of(lang), style: text.titleSmall),
            const SizedBox(height: 4),
            Text(fact.body.of(lang), style: text.bodyMedium),
            const SizedBox(height: 6),
            _RefLine(fact.refs),
          ],
        ),
      ),
    );
  }
}

/// "Manba: ... (lokator)" — qisqa satr.
class _RefLine extends StatelessWidget {
  const _RefLine(this.refs);

  final List<CalcRef> refs;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final s = [
      for (final r in refs)
        r.locator.isEmpty
            ? _short(r.source.citation)
            : '${_short(r.source.citation)} — ${r.locator}',
    ].join('; ');
    return Text(s, style: text.bodySmall?.copyWith(color: p.sub));
  }

  /// Bibliografiyaning birinchi qismi (muallif yoki tashkilot).
  static String _short(String citation) {
    final i = citation.indexOf('. ');
    return i > 0 ? citation.substring(0, i) : citation;
  }
}

// ───────────────────────── Namuna sifati ─────────────────────────

class CytoAdequacyScreen extends StatelessWidget {
  const CytoAdequacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.cytoAdequacyTitle,
      subtitle: l.cytoTitle,
      children: [
        const SourcesPanel(cytoAdequacyRefs),
        for (final f in cytoAdequacy) _FactPanel(f),
        LgSectionTitle(l.cytoArtefactsTitle),
        for (final f in cytoArtefacts) _FactPanel(f),
        ..._sources(context, cytoAdequacyRefs),
      ],
    );
  }
}

// ───────────────────────── Reaktiv o'zgarishlar ─────────────────────────

class CytoReactiveScreen extends StatelessWidget {
  const CytoReactiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return LgPage(
      title: l.cytoReactiveTitle,
      subtitle: l.cytoTitle,
      children: [
        const SourcesPanel(cytoReactiveRefs),
        Text(l.cytoReactiveIntro, style: text.bodyMedium),
        LgSectionTitle(l.cytoCompareTitle),
        // Telefon ekrani uchun: har belgi — alohida panel, ustunlar qatorma-qator.
        for (final row in cytoCompare)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.feature.of(lang), style: text.titleSmall),
                  for (final (i, c) in row.cells.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 104,
                            child: Text(
                              cytoCompareHeads[i].of(lang),
                              style: text.labelLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c?.of(lang) ?? '— ${l.cytoCompareNone}',
                              style: c == null
                                  ? text.bodySmall?.copyWith(color: p.sub)
                                  : text.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  _RefLine(row.refs),
                ],
              ),
            ),
          ),
        LgSectionTitle(l.cytoReactiveTypesTitle),
        for (final f in cytoReactiveTypes) _FactPanel(f),
        ..._sources(context, cytoReactiveRefs),
      ],
    );
  }
}

// ───────────────────────── Yetilish indeksi ─────────────────────────

class CytoMaturationScreen extends StatefulWidget {
  const CytoMaturationScreen({super.key});

  @override
  State<CytoMaturationScreen> createState() => _CytoMaturationScreenState();
}

class _CytoMaturationScreenState extends State<CytoMaturationScreen> {
  final _p = TextEditingController();
  final _i = TextEditingController();
  final _s = TextEditingController();

  @override
  void dispose() {
    _p.dispose();
    _i.dispose();
    _s.dispose();
    super.dispose();
  }

  /// Bo'sh maydon — 0.
  int? _read(TextEditingController c) =>
      c.text.trim().isEmpty ? 0 : int.tryParse(c.text.trim());

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final text = Theme.of(context).textTheme;
    final p = _read(_p), i = _read(_i), s = _read(_s);
    final mi = (p == null || i == null || s == null)
        ? null
        : cytoMaturationIndex(p, i, s);
    String pct(double v) => formatResult(v, locale, maxDecimals: 1);
    Widget field(String label, TextEditingController c) => LgField(
      label: label,
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 5,
      onChanged: (_) => setState(() {}),
    );
    return LgPage(
      title: l.cytoMaturationTitle,
      subtitle: l.cytoTitle,
      children: [
        const SourcesPanel(cytoMaturationRefs),
        for (final f in cytoMaturation) _FactPanel(f),
        LgSectionTitle(l.cytoMiCalcTitle),
        field(l.cytoMiParabasal, _p),
        field(l.cytoMiIntermediate, _i),
        field(l.cytoMiSuperficial, _s),
        const SizedBox(height: 14),
        Semantics(
          liveRegion: true,
          child: LgPanel(
            child: mi == null
                ? Text(l.cytoMiEmpty, style: text.bodyMedium)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.cytoMiResult, style: text.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${pct(mi.parabasal)} : ${pct(mi.intermediate)} : '
                        '${pct(mi.superficial)}',
                        style: text.headlineSmall,
                      ),
                      LgMetric(
                        label: l.cytoMiParabasal,
                        value: '${pct(mi.parabasal)} %',
                      ),
                      LgMetric(
                        label: l.cytoMiIntermediate,
                        value: '${pct(mi.intermediate)} %',
                      ),
                      LgMetric(
                        label: l.cytoMiSuperficial,
                        value: '${pct(mi.superficial)} %',
                      ),
                      const SizedBox(height: 6),
                      Text(l.cytoMiTotal(p! + i! + s!), style: text.bodySmall),
                    ],
                  ),
          ),
        ),
        LgNotice(l.cytoMiCaveat, kind: NoticeKind.warning),
        ..._sources(context, cytoMaturationRefs),
      ],
    );
  }
}

// ───────────────────────── Boshqa namunalar ─────────────────────────

class CytoOtherScreen extends StatelessWidget {
  const CytoOtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.cytoOtherTitle,
      subtitle: l.cytoTitle,
      children: [
        SourcesPanel([for (final s in cytoOtherSystems) ...s.refs]),
        Text(l.cytoOtherIntro, style: text.bodyMedium),
        for (final sys in cytoOtherSystems) ...[
          LgSectionTitle(sys.title.of(lang)),
          LgPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sys.system.of(lang), style: text.bodyMedium),
                const SizedBox(height: 8),
                Text(l.cytoCategoriesTitle, style: text.labelLarge),
                for (final (i, c) in sys.categories.indexed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${i + 1}. ${c.of(lang)}',
                      style: text.bodyMedium,
                    ),
                  ),
                if (sys.note case final n?) ...[
                  const SizedBox(height: 8),
                  Text(n.of(lang), style: text.bodySmall),
                ],
                const SizedBox(height: 6),
                _RefLine(sys.refs),
              ],
            ),
          ),
        ],
        ..._sources(context, [for (final s in cytoOtherSystems) ...s.refs]),
      ],
    );
  }
}
