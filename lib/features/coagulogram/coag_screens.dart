import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../classroom/lecture_library.dart' show openDeck;
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import '../tools/sources_panel.dart';
import '../lab/lab_links.dart';
import 'coag_content.dart';
import 'coag_logic.dart';
import '../howto/howto_registry.dart';
import '../howto/howto_widgets.dart';

const coagBase = '/lab/coagulogram';
const coagCardImage = 'assets/coagulogram/card.png';

/// Pack'dagi gemostaz kartalari (nusxa emas — id bo'yicha havola).
const coagAnalyteIds = [
  'pt-inr',
  'aptt',
  'fibrinogen',
  'd-dimer',
  'coagulation-factors',
  'protein-c-s',
];

/// Bosh sahifadagi bo'limlar: (sarlavha, izoh, ikonka, yo'l).
const coagRoutes = ['tests', 'sample', 'reader', 'dic', 'monitoring'];

extension on BuildContext {
  String get _lang => Localizations.localeOf(this).languageCode;

  String tr(LocalizedText t) => t.of(_lang);
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

/// Da'vo matni va manba raqamlari: "… [1, 3]".
String _marked(BuildContext context, CgFact f, List<CalcRef> refs) {
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

/// Amaliy protokol taqdimotiga havola.
class _DeckRow extends StatelessWidget {
  const _DeckRow();

  @override
  Widget build(BuildContext context) {
    return LgRow(
      key: const ValueKey('coag-deck'),
      title: context.tr(cgDeckTitle),
      subtitle: context.tr(CgL.deckTitle),
      icon: Icons.slideshow_outlined,
      onTap: () => openDeck(context, cgDeckId),
      divider: false,
    );
  }
}

// ───────────────────────── Bosh sahifa ─────────────────────────

class CoagulogramScreen extends StatelessWidget {
  const CoagulogramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (CgL.testsTitle, CgL.testsSub, Icons.timer_outlined),
      (CgL.sampleTitle, CgL.sampleSub, Icons.science_outlined),
      (CgL.readerTitle, CgL.readerSub, Icons.fact_check_outlined),
      (CgL.dicTitle, CgL.dicSub, Icons.calculate_outlined),
      (CgL.monitoringTitle, CgL.monitoringSub, Icons.medication_outlined),
    ];
    return LgPage(
      title: l.coagTitle,
      subtitle: context.tr(CgL.subtitle),
      children: [
        const HowToButton(HowToSection.coagulogram),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  coagCardImage,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SourcesPanel(cgLeadRefs),
        LgNotice(context.tr(CgL.notDiagnosis), kind: NoticeKind.info),
        for (final (i, (title, sub, icon)) in rows.indexed)
          LgRow(
            key: ValueKey('coag-row-${coagRoutes[i]}'),
            title: context.tr(title),
            subtitle: context.tr(sub),
            icon: icon,
            onTap: () => context.push('$coagBase/${coagRoutes[i]}'),
            divider: i < rows.length - 1,
          ),
        LgSectionTitle(context.tr(CgL.relatedTitle)),
        const _DeckRow(),
        LgSectionTitle(context.tr(CgL.relatedCardsTitle)),
        ContentGate(
          builder: (context, pack) {
            final cards = [for (final id in coagAnalyteIds) ?pack.analyte(id)];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, card) in cards.indexed)
                  AnalyteRow(
                    key: ValueKey('coag-card-${card.id}'),
                    analyte: card,
                    divider: i < cards.length - 1,
                    onTap: () => openLabAnalyte(context, card.id),
                  ),
              ],
            );
          },
        ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in CgSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

// ───────────────────────── 1. Testlar ─────────────────────────

class CgTestsScreen extends StatelessWidget {
  const CgTestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final refs = cgRefsOf([
      ...cgTestsGeneral,
      for (final t in cgTests) ...t.facts,
    ]);
    return LgPage(
      title: context.tr(CgL.testsTitle),
      subtitle: l.coagTitle,
      children: [
        const SourcesPanel(cgLeadRefs),
        LgSectionTitle(context.tr(CgL.generalTitle)),
        for (final f in cgTestsGeneral) _Bullet(_marked(context, f, refs)),
        for (final t in cgTests) ...[
          LgSectionTitle(context.tr(t.name)),
          LgPanel(
            key: ValueKey('coag-test-${t.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.tr(CgL.measuresTitle), style: text.labelLarge),
                const SizedBox(height: 4),
                for (final f in t.measures) _Bullet(_marked(context, f, refs)),
                Text(context.tr(CgL.notesTitle), style: text.labelLarge),
                const SizedBox(height: 4),
                for (final f in t.notes) _Bullet(_marked(context, f, refs)),
                if (t.analyteId case final id?)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      key: ValueKey('coag-test-card-$id'),
                      onPressed: () => openLabAnalyte(context, id),
                      child: Text(context.tr(CgL.openCard)),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── 2. Namuna ─────────────────────────

class CgSampleScreen extends StatelessWidget {
  const CgSampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final refs = cgRefsOf([
      for (final s in cgSampleSections) ...s.facts,
      ...cgErrors,
    ]);
    return LgPage(
      title: context.tr(CgL.sampleTitle),
      subtitle: l.coagTitle,
      children: [
        const SourcesPanel(cgLeadRefs),
        for (final s in cgSampleSections) ...[
          LgSectionTitle(context.tr(s.title)),
          for (final f in s.facts) _Bullet(_marked(context, f, refs)),
        ],
        LgSectionTitle(context.tr(CgL.citrateTitle)),
        const CitrateCalculator(),
        LgSectionTitle(context.tr(CgL.errorsTitle)),
        for (final f in cgErrors) _Bullet(_marked(context, f, refs)),
        LgSectionTitle(context.tr(CgL.relatedTitle)),
        const _DeckRow(),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

/// Yuqori gematokritda sitrat hajmi (WFH formulasi).
class CitrateCalculator extends StatefulWidget {
  const CitrateCalculator({super.key});

  @override
  State<CitrateCalculator> createState() => _CitrateCalculatorState();
}

class _CitrateCalculatorState extends State<CitrateCalculator> {
  final _hct = TextEditingController();
  final _vol = TextEditingController(text: '4.5');
  bool _volLocalized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Standart hajm interfeys tilining o'nlik belgisi bilan (uz/ru: "4,5"),
    // natija kabi. Foydalanuvchi o'zgartirgan bo'lsa — tegilmaydi.
    if (_volLocalized) return;
    _volLocalized = true;
    final lang = Localizations.localeOf(context).languageCode;
    if (lang != 'en' && _vol.text == '4.5') _vol.text = '4,5';
  }

  @override
  void dispose() {
    _hct.dispose();
    _vol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hct = cgParse(_hct.text);
    final vol = cgParse(_vol.text);
    final hctBad =
        _hct.text.trim().isNotEmpty && (hct == null || hct <= 0 || hct >= 100);
    final volBad = _vol.text.trim().isNotEmpty && (vol == null || vol <= 0);
    final c = hct == null || vol == null || hctBad || volBad
        ? null
        : citrateVolumeMl(hctPercent: hct, bloodMl: vol);
    final lang = Localizations.localeOf(context).languageCode;
    String fmt(double v) {
      final s = v.toStringAsFixed(2);
      return lang == 'en' ? s : s.replaceAll('.', ',');
    }

    return LgPanel(
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgField(
            key: const ValueKey('coag-citrate-hct'),
            label: context.tr(CgL.citrateHct),
            controller: _hct,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: hctBad ? context.tr(CgL.invalidNumber) : null,
            onChanged: (_) => setState(() {}),
          ),
          LgField(
            key: const ValueKey('coag-citrate-vol'),
            label: context.tr(CgL.citrateVolume),
            controller: _vol,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: volBad ? context.tr(CgL.invalidNumber) : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          if (c != null && hct! <= citrateHctThreshold)
            Text(
              context.tr(CgL.citrateNotNeeded),
              key: const ValueKey('coag-citrate-not-needed'),
              style: text.bodyMedium,
            )
          else if (c != null)
            Semantics(
              liveRegion: true,
              child: Text(
                '${context.tr(CgL.citrateResult)}: ${fmt(c)}',
                key: const ValueKey('coag-citrate-result'),
                style: text.titleMedium,
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── 3. O'qish yordamchisi ─────────────────────────

enum _Plt { normal, low, unknown }

class CgReaderScreen extends StatefulWidget {
  const CgReaderScreen({super.key});

  @override
  State<CgReaderScreen> createState() => _CgReaderScreenState();
}

class _CgReaderScreenState extends State<CgReaderScreen> {
  bool? _pt;
  bool? _aptt;
  _Plt _plt = _Plt.unknown;

  Widget _pair(
    String key,
    LocalizedText label,
    bool? value,
    void Function(bool) set,
  ) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr(label), style: text.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LgChoiceChip(
                key: ValueKey('coag-$key-normal'),
                label: context.tr(CgL.normal),
                selected: value == false,
                onTap: () => setState(() => set(false)),
              ),
              LgChoiceChip(
                key: ValueKey('coag-$key-long'),
                label: context.tr(CgL.prolonged),
                selected: value == true,
                onTap: () => setState(() => set(true)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final pattern = _pt == null || _aptt == null
        ? null
        : cgPattern(ptProlonged: _pt!, apttProlonged: _aptt!);
    final info = pattern == null ? null : cgPatternInfo[pattern]!;
    final extra = [
      if (pattern != null && _plt == _Plt.low) cgLowPlateletsFact,
      if (pattern != null &&
          _plt == _Plt.low &&
          (pattern == CgPattern.ptOnly || pattern == CgPattern.both))
        cgLowPlateletsPtFact,
    ];
    final refs = cgRefsOf([...?info?.facts, ...extra]);
    return LgPage(
      title: context.tr(CgL.readerTitle),
      subtitle: l.coagTitle,
      children: [
        const SourcesPanel(cgLeadRefs),
        Text(context.tr(CgL.readerIntro), style: text.bodyMedium),
        _pair(
          'pt',
          const LocalizedText({'uz': 'PT', 'ru': 'ПВ', 'en': 'PT'}),
          _pt,
          (v) => _pt = v,
        ),
        _pair(
          'aptt',
          const LocalizedText({'uz': 'APTT', 'ru': 'АЧТВ', 'en': 'APTT'}),
          _aptt,
          (v) => _aptt = v,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr(CgL.plateletsLabel), style: text.titleSmall),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (v, label) in [
                    (_Plt.normal, CgL.normal),
                    (_Plt.low, CgL.low),
                    (_Plt.unknown, CgL.unknown),
                  ])
                    LgChoiceChip(
                      key: ValueKey('coag-plt-${v.name}'),
                      label: context.tr(label),
                      selected: _plt == v,
                      onTap: () => setState(() => _plt = v),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (info == null)
          Text(
            context.tr(CgL.readerEmpty),
            key: const ValueKey('coag-reader-empty'),
            style: text.bodyMedium,
          )
        else ...[
          LgSectionTitle(context.tr(info.label)),
          LgPanel(
            key: ValueKey('coag-pattern-${pattern!.name}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.tr(CgL.causesTitle), style: text.labelLarge),
                const SizedBox(height: 4),
                for (final f in info.causes) _Bullet(_marked(context, f, refs)),
                Text(context.tr(CgL.nextTitle), style: text.labelLarge),
                const SizedBox(height: 4),
                for (final f in info.next) _Bullet(_marked(context, f, refs)),
              ],
            ),
          ),
          for (final f in extra)
            LgNotice(
              _marked(context, f, refs),
              key: ValueKey(
                'coag-plt-note-${identical(f, cgLowPlateletsFact) ? 'low' : 'pt'}',
              ),
              kind: NoticeKind.info,
            ),
          if (pattern == CgPattern.both || _plt == _Plt.low)
            LgRow(
              key: const ValueKey('coag-reader-dic'),
              title: context.tr(CgL.openDic),
              icon: Icons.calculate_outlined,
              onTap: () => context.push('$coagBase/dic'),
              divider: false,
            ),
          LgNotice(
            context.tr(CgL.readerReferral),
            key: const ValueKey('coag-reader-referral'),
            kind: NoticeKind.warning,
          ),
          const SizedBox(height: 6),
          _Refs(refs),
        ],
      ],
    );
  }
}

// ───────────────────────── 4. DIC bali ─────────────────────────

class CgDicScreen extends StatefulWidget {
  const CgDicScreen({super.key});

  @override
  State<CgDicScreen> createState() => _CgDicScreenState();
}

class _CgDicScreenState extends State<CgDicScreen> {
  bool? _underlying;
  CgFrm? _frm;
  final _plt = TextEditingController();
  final _pt = TextEditingController();
  final _fib = TextEditingController();

  @override
  void dispose() {
    _plt.dispose();
    _pt.dispose();
    _fib.dispose();
    super.dispose();
  }

  bool _bad(TextEditingController c) {
    if (c.text.trim().isEmpty) return false;
    final v = cgParse(c.text);
    return v == null || !v.isFinite || v < 0;
  }

  Widget _field(String key, LocalizedText label, TextEditingController c) =>
      LgField(
        key: ValueKey('coag-dic-$key'),
        label: context.tr(label),
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        errorText: _bad(c) ? context.tr(CgL.invalidNumber) : null,
        onChanged: (_) => setState(() {}),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final criteria = [cgDicPlatelets, cgDicFrm, cgDicPt, cgDicFib];
    final score = _underlying == true
        ? dicScore(
            plateletsE9: cgParse(_plt.text),
            frm: _frm,
            ptProlongationSeconds: cgParse(_pt.text),
            fibrinogenGPerL: cgParse(_fib.text),
          )
        : null;
    final refs = cgRefsOf([
      ...cgDicIntro,
      ...criteria,
      cgDicOvert,
      cgDicNonOvert,
    ]);
    final pts = context.tr(CgL.points);
    return LgPage(
      title: context.tr(CgL.dicTitle),
      subtitle: l.coagTitle,
      children: [
        const SourcesPanel(cgLeadRefs),
        for (final f in cgDicIntro) _Bullet(_marked(context, f, refs)),
        const SizedBox(height: 4),
        Text(context.tr(CgL.dicPrecondition), style: text.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LgChoiceChip(
              key: const ValueKey('coag-dic-under-yes'),
              label: context.tr(CgL.yes),
              selected: _underlying == true,
              onTap: () => setState(() => _underlying = true),
            ),
            LgChoiceChip(
              key: const ValueKey('coag-dic-under-no'),
              label: context.tr(CgL.no),
              selected: _underlying == false,
              onTap: () => setState(() => _underlying = false),
            ),
          ],
        ),
        if (_underlying == false)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: LgNotice(
              context.tr(CgL.dicNotApplicable),
              key: const ValueKey('coag-dic-na'),
              kind: NoticeKind.warning,
            ),
          ),
        if (_underlying == true) ...[
          _field('plt', CgL.dicPlatelets, _plt),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(context.tr(CgL.dicFrm), style: text.titleSmall),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (v, label) in [
                (CgFrm.none, CgL.frmNone),
                (CgFrm.moderate, CgL.frmModerate),
                (CgFrm.strong, CgL.frmStrong),
              ])
                LgChoiceChip(
                  key: ValueKey('coag-dic-frm-${v.name}'),
                  label: context.tr(label),
                  selected: _frm == v,
                  onTap: () => setState(() => _frm = v),
                ),
            ],
          ),
          _field('pt', CgL.dicPt, _pt),
          _field('fib', CgL.dicFib, _fib),
          const SizedBox(height: 12),
          if (score == null)
            Text(
              context.tr(CgL.dicFill),
              key: const ValueKey('coag-dic-empty'),
              style: text.bodyMedium,
            )
          else
            LgPanel(
              key: const ValueKey('coag-dic-result'),
              outlined: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LgMetric(
                    label: context.tr(CgL.dicPlatelets),
                    value: '${score.platelets} $pts',
                  ),
                  LgMetric(
                    label: context.tr(CgL.dicFrm),
                    value: '${score.frm} $pts',
                  ),
                  LgMetric(
                    label: context.tr(CgL.dicPt),
                    value: '${score.pt} $pts',
                  ),
                  LgMetric(
                    label: context.tr(CgL.dicFib),
                    value: '${score.fibrinogen} $pts',
                  ),
                  const SizedBox(height: 6),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      '${context.tr(CgL.dicTotal)}: ${score.total}',
                      key: const ValueKey('coag-dic-total'),
                      style: text.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _marked(
                      context,
                      score.compatibleWithOvert ? cgDicOvert : cgDicNonOvert,
                      refs,
                    ),
                    key: ValueKey(
                      score.compatibleWithOvert
                          ? 'coag-dic-overt'
                          : 'coag-dic-nonovert',
                    ),
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
          LgNotice(context.tr(CgL.readerReferral), kind: NoticeKind.warning),
        ],
        LgSectionTitle(context.tr(CgL.dicCriteria)),
        for (final f in criteria) _Bullet(_marked(context, f, refs)),
        _Bullet(_marked(context, cgDicOvert, refs)),
        _Bullet(_marked(context, cgDicNonOvert, refs)),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── 5. Monitoring ─────────────────────────

class CgMonitoringScreen extends StatelessWidget {
  const CgMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final refs = cgRefsOf([for (final s in cgMonitoringSections) ...s.facts]);
    return LgPage(
      title: context.tr(CgL.monitoringTitle),
      subtitle: l.coagTitle,
      children: [
        const SourcesPanel(cgLeadRefs),
        for (final s in cgMonitoringSections) ...[
          LgSectionTitle(context.tr(s.title)),
          for (final f in s.facts) _Bullet(_marked(context, f, refs)),
        ],
        LgNotice(context.tr(CgL.notDiagnosis), kind: NoticeKind.info),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}
