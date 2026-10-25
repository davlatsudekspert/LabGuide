import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../learn/quiz_session.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import '../tools/manual_calculators.dart';
import '../tools/sources_panel.dart';
import '../tools/tool_screens.dart' show formatResult, parseFieldNumber;
import '../lab/lab_links.dart';
import 'bloodmorph_content.dart';
import 'bloodmorph_logic.dart';
import '../howto/howto_registry.dart';
import '../howto/howto_widgets.dart';

const bmBase = '/lab/bloodmorph';
const bmCardImage = 'assets/bloodmorph/card.png';
const bmSchemeImage = 'assets/bloodmorph/scheme.png';

/// Tegishli bo'limlar (boshqa tab yoki shu tabdagi boshqa bo'lim).
const bmLeukoRoute = '/lab/differential';
const bmReticCalcRoute = '/lab/calculators/reticulocytes';
const bmAnemiaTableRoute = '/learn/reference/anemia';

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

/// Da'vo matni va manba raqamlari: “… [1, 3]”.
String _marked(BuildContext context, BmFact f, List<CalcRef> refs) {
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
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

/// Mikrofoto: nisbati saqlanadi, bosilsa kattalashtirib ko'rish.
class BmPhoto extends StatelessWidget {
  const BmPhoto({
    super.key,
    required this.image,
    required this.semanticLabel,
    this.maxHeight = 340,
    this.zoom = true,
  });

  final BmImage image;
  final String semanticLabel;
  final double maxHeight;
  final bool zoom;

  @override
  Widget build(BuildContext context) {
    final picture = ClipRRect(
      borderRadius: BorderRadius.circular(LgRadius.card),
      child: Image.asset(
        image.asset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: maxHeight * image.width / image.height,
        ),
        child: AspectRatio(
          aspectRatio: image.width / image.height,
          child: Semantics(
            image: true,
            label: semanticLabel,
            child: zoom
                ? GestureDetector(
                    key: ValueKey('bm-photo-${image.file}'),
                    onTap: () => _openZoom(context),
                    child: picture,
                  )
                : picture,
          ),
        ),
      ),
    );
  }

  void _openZoom(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Image.asset(image.asset, semanticLabel: semanticLabel),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: IconButton.filled(
                  tooltip: l.micClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rasm muallifi, litsenziyasi va manba sahifasi.
class BmCredit extends StatelessWidget {
  const BmCredit({super.key, required this.image});

  final BmImage image;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      key: ValueKey('bm-credit-${image.file}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgMetric(
          label: context.tr(BmL.stain),
          value: context.tr(image.stain ?? BmL.stainNotStated),
        ),
        LgMetric(label: l.micAuthor, value: image.author),
        LgMetric(label: l.micLicense, value: image.license),
        LgMetric(label: context.tr(BmL.checked), value: bmCheckedAt),
        const SizedBox(height: 8),
        Text(context.tr(BmL.captionTitle), style: text.labelLarge),
        const SizedBox(height: 2),
        Text('“${image.caption}”', style: text.bodySmall),
        const SizedBox(height: 4),
        Text(context.tr(image.captionTr), style: text.bodyMedium),
        const SizedBox(height: 4),
        LgRow(
          title: l.micSourcePage,
          subtitle: 'File:${image.commonsTitle}',
          icon: Icons.open_in_new_rounded,
          onTap: () => openExternalLink(context, image.sourcePage),
        ),
        LgRow(
          title: l.micLicenseText(image.license),
          subtitle: Uri.parse(image.licenseUrl).host,
          icon: Icons.gavel_rounded,
          onTap: () => openExternalLink(context, image.licenseUrl),
          divider: false,
        ),
        Text(
          '${context.tr(BmL.resized)}: ${image.width}×${image.height} px '
          '(${image.originalWidth}×${image.originalHeight} px).',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

/// Kontent paketidagi tegishli tahlil kartalari (bo'lsa) — takrorlanmaydi,
/// faqat havola.
class _RelatedCards extends StatelessWidget {
  const _RelatedCards(this.ids);

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) return const SizedBox.shrink();
    return ContentGate(
      builder: (context, pack) {
        final cards = [for (final id in ids) ?pack.analyte(id)];
        if (cards.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgSectionTitle(context.tr(BmL.relatedCards)),
            for (final (i, a) in cards.indexed)
              AnalyteRow(
                analyte: a,
                divider: i < cards.length - 1,
                onTap: () => openLabAnalyte(context, a.id),
              ),
          ],
        );
      },
    );
  }
}

/// Bo'limlar (sarlavha + belgili da'volar + ixtiyoriy rasm).
List<Widget> _sections(
  BuildContext context,
  List<BmSection> sections,
  List<CalcRef> refs,
) => [
  for (final s in sections) ...[
    LgSectionTitle(context.tr(s.title)),
    if (s.image case final img?) ...[
      BmPhoto(
        image: img,
        semanticLabel: context.tr(img.captionTr),
        maxHeight: 220,
      ),
      const SizedBox(height: 4),
      Text(
        '${context.tr(img.captionTr)} — ${img.author}, ${img.license}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 8),
    ],
    for (final f in s.facts) _Bullet(_marked(context, f, refs)),
  ],
];

// ───────────────────────── Bosh sahifa ─────────────────────────

class BloodMorphScreen extends StatelessWidget {
  const BloodMorphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (BmL.normalTitle, BmL.normalSub, Icons.circle_outlined, 'normal'),
      (BmL.findingsTitle, BmL.findingsSub, Icons.bubble_chart_outlined, 'rbc'),
      (BmL.plateletsTitle, BmL.plateletsSub, Icons.grain_rounded, 'platelets'),
      (BmL.reticTitle, BmL.reticSub, Icons.calculate_outlined, 'retic'),
      (BmL.anemiaTitle, BmL.anemiaSub, Icons.water_drop_outlined, 'anemia'),
      (BmL.qualityTitle, BmL.qualitySub, Icons.fact_check_outlined, 'quality'),
      (BmL.quizTitle, BmL.quizSub, Icons.quiz_outlined, 'quiz'),
      (BmL.creditsTitle, BmL.creditsSub, Icons.copyright_outlined, 'credits'),
    ];
    return LgPage(
      title: l.bloodMorphTitle,
      subtitle: context.tr(BmL.subtitle),
      children: [
        const HowToButton(HowToSection.bloodMorph),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  bmCardImage,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SourcesPanel(bmLeadRefs),
        Text(
          context.tr(BmL.photoNote),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        for (final (i, (title, sub, icon, path)) in rows.indexed)
          LgRow(
            key: ValueKey('bm-row-$path'),
            title: context.tr(title),
            subtitle: context.tr(sub),
            icon: icon,
            onTap: () => context.push('$bmBase/$path'),
            divider: i < rows.length - 1,
          ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in BmSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

// ───────────────────────── Normal eritrotsit ─────────────────────────

class BmNormalScreen extends StatelessWidget {
  const BmNormalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final refs = bmUniqueRefs([
      for (final s in bmNormalSections) ...s.facts,
      bmReferGeneral,
    ]);
    return LgPage(
      title: context.tr(BmL.normalTitle),
      subtitle: AppLocalizations.of(context).bloodMorphTitle,
      children: [
        LgSectionTitle(context.tr(BmL.schemeTitle)),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Semantics(
                image: true,
                label: context.tr(BmL.schemeLabel),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(LgRadius.card),
                  child: Image.asset(
                    bmSchemeImage,
                    key: const ValueKey('bm-scheme'),
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: Text(context.tr(BmL.schemeLabel), style: text.bodySmall),
        ),
        ..._sections(context, bmNormalSections, refs),
        const SizedBox(height: 6),
        LgNotice(_marked(context, bmReferGeneral, refs), kind: NoticeKind.info),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Eritrotsit o'zgarishlari ─────────────────────────

const _rbcGroups = [
  BmGroup.size,
  BmGroup.colour,
  BmGroup.shape,
  BmGroup.inclusion,
  BmGroup.arrangement,
];

class BmFindingsScreen extends StatelessWidget {
  const BmFindingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LgPage(
      title: context.tr(BmL.findingsTitle),
      subtitle: AppLocalizations.of(context).bloodMorphTitle,
      children: [
        Text(
          context.tr(BmL.photoNote),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        for (final g in _rbcGroups) ...[
          LgSectionTitle(context.tr(BmL.groups[g]!)),
          for (final f in bmFindings.where((f) => f.group == g))
            _FindingRow(finding: f),
        ],
      ],
    );
  }
}

class _FindingRow extends StatelessWidget {
  const _FindingRow({required this.finding});

  final BmFinding finding;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final name = context.tr(finding.name);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.7)),
        ),
      ),
      child: LgPressable(
        key: ValueKey('bm-item-${finding.id}'),
        onTap: () => context.push('$bmBase/rbc/${finding.id}'),
        borderRadius: BorderRadius.circular(14),
        semanticLabel: name,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: finding.image == null
                      ? Container(
                          width: 64,
                          height: 64,
                          color: p.soft,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: p.sub,
                          ),
                        )
                      : Image.asset(
                          finding.image!.asset,
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
                        context.tr(finding.see.first.text),
                        style: text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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

/// Topilma kartasi (eritrotsit yoki trombotsit) — sahifa ichidagi bloklar.
List<Widget> _findingBody(
  BuildContext context,
  BmFinding f,
  List<CalcRef> refs,
) {
  final text = Theme.of(context).textTheme;
  String m(BmFact x) => _marked(context, x, refs);
  final image = f.image;
  return [
    if (image != null)
      BmPhoto(
        image: image,
        semanticLabel: '${context.tr(f.name)}. ${context.tr(image.captionTr)}',
      )
    else
      LgNotice(context.tr(BmL.noPhoto), kind: NoticeKind.info),
    if (f.aka case final aka?) ...[
      const SizedBox(height: 8),
      Text(
        '${context.tr(BmL.akaTitle)}: ${context.tr(aka)}',
        style: text.bodySmall,
      ),
    ],
    LgSectionTitle(context.tr(BmL.seeTitle)),
    for (final x in f.see) _Bullet(m(x)),
    LgSectionTitle(context.tr(BmL.pointsTitle)),
    Text(m(f.pointsTo), style: text.bodyMedium),
    const SizedBox(height: 4),
    Text(context.tr(BmL.notDiagnosis), style: text.bodySmall),
    if (f.confuse case final c?) ...[
      LgSectionTitle(context.tr(BmL.confuseTitle)),
      Text(m(c), style: text.bodyMedium),
    ],
    LgSectionTitle(context.tr(BmL.referTitle)),
    if (f.refer case final r?) ...[
      LgNotice(m(r), kind: NoticeKind.warning),
      const SizedBox(height: 8),
    ],
    Text(m(bmReferGeneral), style: text.bodyMedium),
    if (image != null) ...[
      LgSectionTitle(context.tr(BmL.imageTitle)),
      BmCredit(image: image),
    ],
  ];
}

class BmFindingScreen extends StatelessWidget {
  const BmFindingScreen({super.key, required this.findingId});

  final String findingId;

  @override
  Widget build(BuildContext context) {
    final f = bmFinding(findingId);
    if (f == null) {
      return LgPage(
        title: context.tr(BmL.findingsTitle),
        children: [
          LgStateView(
            kind: StateKind.empty,
            title: context.tr(BmL.findingsTitle),
          ),
        ],
      );
    }
    final refs = bmUniqueRefs([...f.facts, bmReferGeneral]);
    return LgPage(
      title: context.tr(f.name),
      subtitle: context.tr(BmL.groups[f.group]!),
      children: [
        ..._findingBody(context, f, refs),
        _RelatedCards(f.analytes),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Trombotsitlar ─────────────────────────

class BmPlateletsScreen extends StatelessWidget {
  const BmPlateletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final refs = bmUniqueRefs([
      ...bmPlateletIntro,
      for (final f in bmPlatelets) ...f.facts,
      bmReferGeneral,
    ]);
    return LgPage(
      title: context.tr(BmL.plateletsTitle),
      subtitle: AppLocalizations.of(context).bloodMorphTitle,
      children: [
        LgSectionTitle(context.tr(BmL.normalPlatelets)),
        for (final x in bmPlateletIntro) _Bullet(_marked(context, x, refs)),
        for (final f in bmPlatelets) ...[
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Semantics(
              header: true,
              child: Text(
                context.tr(f.name),
                key: ValueKey('bm-plt-${f.id}'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._findingBody(context, f, refs),
        ],
        LgSectionTitle(context.tr(BmL.leukoLinkTitle)),
        LgRow(
          key: const ValueKey('bm-leuko-link'),
          title: AppLocalizations.of(context).diffTitle,
          subtitle: context.tr(BmL.leukoLinkSub),
          icon: Icons.biotech_outlined,
          onTap: () => context.push(bmLeukoRoute),
          divider: false,
        ),
        const _RelatedCards(['platelets', 'mpv', 'blood-smear']),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Retikulotsitlar ─────────────────────────

/// Ishlangan misol: mavjud kalkulyator funksiyasi bilan hisoblanadi
/// (manba formulasi — JSST 9.12; CRC — Chueh 2022).
ReticResult bmWorkedExample() => (reticulocytes(
  counted: 15,
  examined: 500,
  hematocrit: 30,
  rbc: 3.0,
) as ManualOk<ReticResult>).value;

class BmReticScreen extends StatelessWidget {
  const BmReticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final refs = bmUniqueRefs([for (final s in bmReticSections) ...s.facts]);
    final ex = bmWorkedExample();
    String n(double v) => formatResult(v, locale, maxDecimals: 1);
    return LgPage(
      title: context.tr(BmL.reticTitle),
      subtitle: AppLocalizations.of(context).bloodMorphTitle,
      children: [
        ..._sections(context, bmReticSections, refs),
        LgSectionTitle(context.tr(BmL.workedTitle)),
        Text(context.tr(BmL.workedInput), style: text.bodyMedium),
        const SizedBox(height: 4),
        LgMetric(label: context.tr(BmL.workedPercent), value: n(ex.percent)),
        LgMetric(label: context.tr(BmL.workedAbsolute), value: n(ex.absolute!)),
        LgMetric(
          label: context.tr(BmL.workedCorrected),
          value: n(ex.corrected),
        ),
        const SizedBox(height: 8),
        LgRow(
          key: const ValueKey('bm-retic-calc'),
          title: context.tr(BmL.calcLink),
          subtitle: context.tr(BmL.calcLinkSub),
          icon: Icons.calculate_outlined,
          onTap: () => context.push(bmReticCalcRoute),
          divider: false,
        ),
        const _RelatedCards(['reticulocytes']),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Surtma sifati ─────────────────────────

class BmQualityScreen extends StatelessWidget {
  const BmQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final refs = bmUniqueRefs([for (final s in bmQualitySections) ...s.facts]);
    return LgPage(
      title: context.tr(BmL.qualityTitle),
      subtitle: AppLocalizations.of(context).bloodMorphTitle,
      children: [
        ..._sections(context, bmQualitySections, refs),
        const SizedBox(height: 6),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Anemiya yordamchisi ─────────────────────────

class BmAnemiaScreen extends StatefulWidget {
  const BmAnemiaScreen({super.key});

  @override
  State<BmAnemiaScreen> createState() => _BmAnemiaScreenState();
}

class _BmAnemiaScreenState extends State<BmAnemiaScreen> {
  final _ctrl = {for (final f in BmField.values) f: TextEditingController()};
  final _values = <BmField, double>{};
  final _errors = <BmField, String>{};
  var _population = BmPopulation.woman15to65;
  var _inflammation = false;

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(BmField f, String raw) {
    setState(() {
      _values.remove(f);
      _errors.remove(f);
      if (raw.trim().isEmpty) return;
      final v = parseFieldNumber(context, raw);
      if (v == null || !bmFieldValid(f, v)) {
        _errors[f] = context.tr(BmL.invalid);
        return;
      }
      _values[f] = v;
    });
  }

  LocalizedText _label(BmField f) => switch (f) {
    BmField.hb => BmL.fieldHb,
    BmField.mcv => BmL.fieldMcv,
    BmField.rdw => BmL.fieldRdw,
    BmField.rdwUpper => BmL.fieldRdwUpper,
    BmField.ferritin => BmL.fieldFerritin,
    BmField.retic => BmL.fieldRetic,
  };

  Widget _field(BmField f) => LgField(
    key: ValueKey('bm-in-${f.name}'),
    label: context.tr(_label(f)),
    controller: _ctrl[f],
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textInputAction: f == BmField.retic
        ? TextInputAction.done
        : TextInputAction.next,
    onChanged: (s) => _onChanged(f, s),
    errorText: _errors[f],
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final input = BmAnemiaInput(
      population: _population,
      hb: _values[BmField.hb],
      mcv: _values[BmField.mcv],
      rdw: _values[BmField.rdw],
      rdwUpper: _values[BmField.rdwUpper],
      ferritin: _values[BmField.ferritin],
      inflammation: _inflammation,
      retic: _values[BmField.retic],
    );
    final r = bmAssessAnemia(input);
    final refs = bmHelperRefs;
    return LgPage(
      title: context.tr(BmL.anemiaTitle),
      subtitle: AppLocalizations.of(context).bloodMorphTitle,
      children: [
        const SourcesPanel(bmLeadRefs),
        Text(context.tr(BmL.anemiaIntro), style: text.bodyMedium),
        LgSectionTitle(context.tr(BmL.populationTitle)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in BmPopulation.values)
              LgChoiceChip(
                key: ValueKey('bm-pop-${p.name}'),
                label: context.tr(BmL.populations[p]!),
                selected: p == _population,
                onTap: () => setState(() => _population = p),
              ),
          ],
        ),
        _field(BmField.hb),
        _field(BmField.mcv),
        _field(BmField.rdw),
        _field(BmField.rdwUpper),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(context.tr(BmL.rdwUpperHint), style: text.bodySmall),
        ),
        _field(BmField.ferritin),
        const SizedBox(height: 10),
        Wrap(
          children: [
            LgChoiceChip(
              key: const ValueKey('bm-inflammation'),
              label: context.tr(BmL.inflammation),
              selected: _inflammation,
              onTap: () => setState(() => _inflammation = !_inflammation),
            ),
          ],
        ),
        _field(BmField.retic),
        LgSectionTitle(context.tr(BmL.resultTitle)),
        Semantics(
          liveRegion: true,
          container: true,
          child: Column(
            key: const ValueKey('bm-result'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: r.mcvClass == null
                ? [Text(context.tr(BmL.emptyHint), style: text.bodyMedium)]
                : _results(context, input, r),
          ),
        ),
        const SizedBox(height: 10),
        LgNotice(context.tr(BmL.redFlag)),
        const SizedBox(height: 8),
        LgNotice(context.tr(BmL.helperRefer), kind: NoticeKind.info),
        const SizedBox(height: 6),
        LgRow(
          key: const ValueKey('bm-anemia-table'),
          title: context.tr(BmL.tableLink),
          subtitle: context.tr(BmL.tableLinkSub),
          icon: Icons.account_tree_outlined,
          onTap: () => openInTab(context, bmAnemiaTableRoute),
          divider: false,
        ),
        _Refs(refs),
      ],
    );
  }

  List<Widget> _results(
    BuildContext context,
    BmAnemiaInput input,
    BmAnemiaResult r,
  ) {
    final text = Theme.of(context).textTheme;
    final mcv = r.mcvClass!;
    final pattern = r.hasPattern ? bmPatterns[(mcv, r.rdwHigh!)] : null;
    return [
      LgMetric(
        label: context.tr(BmL.cutoffLabel),
        value: '< ${r.hbCutoff} g/L',
      ),
      if (r.anaemic case final a?)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: LgTag(
            context.tr(a ? BmL.anaemicYes : BmL.anaemicNo),
            tone: a ? LgTone.warning : LgTone.neutral,
          ),
        ),
      LgSectionTitle(context.tr(BmL.patternTitle)),
      Text(
        context.tr(BmL.mcvClasses[mcv]!),
        key: const ValueKey('bm-mcv-class'),
        style: text.titleMedium,
      ),
      Text(
        context.tr(
          r.rdwHigh == null
              ? BmL.rdwUnknown
              : r.rdwHigh!
              ? BmL.rdwHigh
              : BmL.rdwNormal,
        ),
        style: text.bodyMedium,
      ),
      const SizedBox(height: 8),
      if (pattern != null)
        LgPanel(
          key: const ValueKey('bm-pattern'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr(pattern.pattern), style: text.titleSmall),
              const SizedBox(height: 6),
              Text(context.tr(BmL.differentialsTitle), style: text.labelLarge),
              Text(context.tr(pattern.differentials), style: text.bodyMedium),
              const SizedBox(height: 6),
              Text(context.tr(BmL.clueTitle), style: text.labelLarge),
              Text(context.tr(pattern.clue), style: text.bodyMedium),
              const SizedBox(height: 4),
              Text(context.tr(BmL.notDiagnosis), style: text.bodySmall),
            ],
          ),
        )
      else
        LgPanel(
          key: const ValueKey('bm-mcv-only'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr(bmMcvOnly[mcv]!), style: text.bodyMedium),
              const SizedBox(height: 4),
              Text(context.tr(BmL.notDiagnosis), style: text.bodySmall),
            ],
          ),
        ),
      const SizedBox(height: 6),
      Text(context.tr(BmL.ageNote), style: text.bodySmall),
      if (input.ferritin != null) ...[
        LgSectionTitle(context.tr(BmL.ferritinTitle)),
        if (r.ferritinCutoff case final c?) ...[
          LgMetric(label: 'WHO 2020', value: '< $c µg/L'),
          Text(
            context.tr(r.ferritinLow! ? BmL.ferritinLow : BmL.ferritinNotLow),
            key: const ValueKey('bm-ferritin'),
            style: text.bodyMedium,
          ),
        ] else
          Text(
            context.tr(BmL.ferritinNoCutoff),
            key: const ValueKey('bm-ferritin'),
            style: text.bodyMedium,
          ),
        const SizedBox(height: 4),
        Text(context.tr(BmL.ferritinInflNote), style: text.bodySmall),
      ],
      if (r.reticBand case final b?) ...[
        LgSectionTitle(context.tr(BmL.reticTitleShort)),
        Text(
          context.tr(BmL.reticBands[b]!),
          key: const ValueKey('bm-retic'),
          style: text.bodyMedium,
        ),
      ],
    ];
  }
}

// ───────────────────────── Mualliflar ─────────────────────────

/// Bo'limdagi barcha rasmlar, takrorsiz.
List<BmImage> bmAllImages() {
  final seen = <String>{};
  return [
    for (final f in [...bmFindings, ...bmPlatelets])
      if (f.image case final img? when seen.add(img.file)) img,
    for (final s in [
      ...bmNormalSections,
      ...bmQualitySections,
      ...bmReticSections,
    ])
      if (s.image case final img? when seen.add(img.file)) img,
  ];
}

class BmCreditsScreen extends StatelessWidget {
  const BmCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: context.tr(BmL.creditsTitle),
      subtitle: AppLocalizations.of(context).bloodMorphTitle,
      children: [
        Text(context.tr(BmL.creditsIntro), style: text.bodyMedium),
        for (final img in bmAllImages()) ...[
          LgSectionTitle(context.tr(img.captionTr)),
          BmPhoto(
            image: img,
            semanticLabel: context.tr(img.captionTr),
            maxHeight: 140,
            zoom: false,
          ),
          const SizedBox(height: 6),
          BmCredit(image: img),
        ],
      ],
    );
  }
}

// ───────────────────────── Mashq ─────────────────────────

class BmQuizItem {
  const BmQuizItem(this.finding, this.question);

  /// Rasmli savol bo'lsa — ko'rsatilgan topilma; bilim savolida `null`.
  final BmFinding? finding;
  final QuizQuestion question;
}

/// Rasmli mashqqa kiradigan kartalar: rasmi bor, `quiz` belgilangan va
/// chalg'ituvchilari yozilgan.
List<BmFinding> bmQuizPool() => [
  for (final f in [...bmFindings, ...bmPlatelets])
    if (f.image != null && f.quiz && bmDistractors.containsKey(f.id)) f,
];

List<BmQuizItem> buildBmQuiz(Random rnd) {
  final pool = bmQuizPool()..shuffle(rnd);
  final know = [...bmKnowledge]..shuffle(rnd);
  return [
    for (final f in pool.take(bmPictureQuizSize))
      () {
        final ids = [f.id, ...bmDistractors[f.id]!]..shuffle(rnd);
        return BmQuizItem(
          f,
          QuizQuestion(
            id: 'bm-${f.id}',
            prompt: BmL.quizPrompt,
            options: [
              for (final id in ids)
                QuizOption(
                  text: bmFinding(id)!.name,
                  explanation: bmFinding(id)!.see.first.text,
                ),
            ],
            correctIndex: ids.indexOf(f.id),
            basis: f.see.first.text,
            refs: const [],
            reviewState: ReviewState.pending,
          ),
        );
      }(),
    for (final k in know.take(bmKnowledgeQuizSize))
      () {
        final order = [for (var i = 0; i < k.options.length; i++) i]
          ..shuffle(rnd);
        return BmQuizItem(
          null,
          QuizQuestion(
            id: 'bm-k-${k.id}',
            prompt: k.prompt,
            options: [
              for (final i in order)
                QuizOption(text: k.options[i], explanation: k.basis.text),
            ],
            correctIndex: order.indexOf(k.correct),
            basis: k.basis.text,
            refs: const [],
            reviewState: ReviewState.pending,
          ),
        );
      }(),
  ];
}

class BmQuizScreen extends StatefulWidget {
  const BmQuizScreen({super.key, this.random});

  final Random? random;

  @override
  State<BmQuizScreen> createState() => _BmQuizScreenState();
}

class _BmQuizScreenState extends State<BmQuizScreen> {
  List<BmQuizItem>? _items;
  QuizSession? _session;

  void _start() => setState(() {
    _items = buildBmQuiz(widget.random ?? Random());
    _session = QuizSession([for (final i in _items!) i.question]);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final s = _session;
    return LgPage(
      key: ValueKey((s == null, s?.index, s?.finished)),
      title: context.tr(BmL.quizTitle),
      subtitle: l.bloodMorphTitle,
      children: [
        if (s == null) ...[
          Text(context.tr(BmL.quizIntro), style: text.bodyLarge),
          const SizedBox(height: 16),
          LgButton(
            key: const ValueKey('bm-quiz-start'),
            label: context.tr(BmL.quizStart),
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
            finding: _items![s.index].finding,
            onChanged: () => setState(() {}),
          ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.session,
    required this.finding,
    required this.onChanged,
  });

  final QuizSession session;
  final BmFinding? finding;
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
    final f = finding;
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
        // Javobni oshkor qilmaslik uchun ekran o'quvchiga nom aytilmaydi.
        if (f != null) ...[
          BmPhoto(
            key: ValueKey('bm-quiz-photo-${f.id}'),
            image: f.image!,
            semanticLabel: context.tr(BmL.quizImageLabel),
            maxHeight: 260,
          ),
          const SizedBox(height: 10),
        ],
        Semantics(
          header: true,
          child: Text(context.tr(q.prompt), style: text.headlineSmall),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LgPressable(
              key: ValueKey('bm-opt-$i'),
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
            f == null
                ? context.tr(q.basis)
                : [
                    if (answer != q.correctIndex)
                      '${context.tr(q.options[answer].text)}: '
                          '${context.tr(q.options[answer].explanation)}',
                    '${context.tr(q.options[q.correctIndex].text)}: '
                        '${context.tr(q.options[q.correctIndex].explanation)}',
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
