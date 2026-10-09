import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../differential/differential_screens.dart';
import '../partners/partner_widgets.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart';
import 'preanalytics_info.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.labTitle,
      subtitle: l.labSubtitle,
      showBrand: true,
      children: [
        // Leykoformula — eng ko'p so'raladigan bo'lim, eng yuqorida.
        const DifferentialEntryCard(),
        LgHeroCard(
          eyebrow: l.labHeroEyebrow,
          title: l.labHeroTitle,
          body: l.labHeroBody,
          action: LgButton(
            label: l.labHeroCta,
            onPressed: () => context.push('/lab/calibration'),
          ),
        ),
        LgRow(
          title: l.featureQc,
          subtitle: l.labQcSub,
          icon: Icons.show_chart_rounded,
          onTap: () => context.push('/lab/qc'),
        ),
        LgRow(
          title: l.labPreanalytics,
          subtitle: l.labPreanalyticsSub,
          icon: Icons.science_outlined,
          onTap: () => context.push('/lab/preanalytics'),
        ),
        LgRow(
          title: l.featureCalculators,
          subtitle: l.labCalculatorsSub,
          icon: Icons.calculate_outlined,
          onTap: () => context.push('/lab/calculators'),
        ),
        LgRow(
          title: l.labInstruments,
          subtitle: l.labInstrumentsSub,
          icon: Icons.precision_manufacturing_outlined,
          onTap: () => context.push('/lab/instruments'),
        ),
        LgRow(
          title: l.micTitle,
          subtitle: l.labMicroscopySub,
          icon: Icons.biotech_outlined,
          onTap: () => context.push('/lab/microscopy'),
          divider: false,
        ),
        // Faqat haqiqiy faol hamkor bo'lsa — bitta “Reklama” kartasi.
        const LabPartnerCard(),
      ],
    );
  }
}

class PreanalyticsScreen extends StatelessWidget {
  const PreanalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final sources = preanalyticsSources();
    Widget bullets(List<LocalizedText> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final x in items) _Bullet(x.of(lang))],
    );
    Widget cited(List<PreItem> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final x in items)
          _Bullet(x.text.of(lang), refs: x.refs, sources: sources),
      ],
    );
    return LgPage(
      title: l.preTitle,
      children: [
        LgSteps([l.preStep1, l.preStep2, l.preStep3, l.preStep4, l.preStep5]),
        LgSectionTitle(l.prePatientTitle),
        cited(patientPrep),
        LgSectionTitle(l.preOrderTitle),
        Text(l.preOrderSub, style: text.bodySmall),
        const SizedBox(height: 8),
        for (final (i, tube) in drawOrder.indexed)
          _TubeRow(index: i + 1, tube: tube, lang: lang),
        const SizedBox(height: 10),
        bullets(drawOrderNotes),
        LgSectionTitle(l.preMixTitle),
        cited(mixingRules),
        LgSectionTitle(l.preTubeForTestTitle),
        Text(l.preTubeForTestSub, style: text.bodySmall),
        const SizedBox(height: 4),
        for (final t in tubeForTest)
          _TubeForTestRow(item: t, lang: lang, sources: sources),
        LgSectionTitle(l.preHaemolysisTitle),
        bullets(haemolysisCauses),
        LgSectionTitle(l.preTourniquetTitle),
        bullets(tourniquetRules),
        LgSectionTitle(l.preIdTitle),
        bullets(identificationRules),
        LgSectionTitle(l.preStabilityTitle),
        Text(l.preStabilitySub, style: text.bodySmall),
        const SizedBox(height: 4),
        for (final r in stabilityRows)
          _StabilityRowView(row: r, lang: lang, sources: sources),
        LgSectionTitle(l.preStorageTitle),
        cited(storageRules),
        LgSectionTitle(l.preUrgentTitle),
        cited(urgentSamples),
        const SizedBox(height: 6),
        LgNotice(l.preNotice),
        const SizedBox(height: 8),
        LgNotice(l.preBooksNote, kind: NoticeKind.info),
        LgSectionTitle(l.calcSources),
        for (final (i, src) in sources.indexed)
          CalcSourceTile(
            index: i + 1,
            ref: CalcRef(
              src,
              i == 0 ? 'Section 2.2.3, Table 2.3; 1.1.1; 7.1.3' : '',
            ),
          ),
      ],
    );
  }
}

/// Manbalar raqami: “[2] Page 21 · [5] 1.2.1”.
String _refLine(
  AppLocalizations l,
  List<CalcRef> refs,
  List<CalcSource> sources,
) => [
  for (final r in refs)
    '[${sources.indexWhere((s) => s.id == r.source.id) + 1}]'
        '${r.locator.isEmpty ? '' : ' ${localizePages(r.locator, l.citePage)}'}',
].join(' · ');

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {this.refs = const [], this.sources = const []});

  final String text;
  final List<CalcRef> refs;
  final List<CalcSource> sources;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: t.bodyMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: t.bodyMedium),
                if (refs.isNotEmpty)
                  Text(
                    _refLine(AppLocalizations.of(context), refs, sources),
                    style: t.bodySmall!.copyWith(color: p.sub),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tahlil → probirka: rang belgisi (tartibdagi probirkadan), probirka nomi
/// va o'rni, izoh, manbalar.
class _TubeForTestRow extends StatelessWidget {
  const _TubeForTestRow({
    required this.item,
    required this.lang,
    required this.sources,
  });

  final TubeForTest item;
  final String lang;
  final List<CalcSource> sources;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final index = item.tube;
    final tube = index == null ? null : drawOrder[index];
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CapDot(colors: tube?.colors ?? const []),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.tests.of(lang), style: text.titleSmall),
                  Text(
                    tube == null
                        ? l.preTubeNone
                        : l.preTubeSlot(tube.name.of(lang), index! + 1),
                    style: text.bodySmall!.copyWith(color: p.brand),
                  ),
                  Text(item.note.of(lang), style: text.bodySmall),
                  Text(
                    _refLine(l, item.refs, sources),
                    style: text.bodySmall!.copyWith(color: p.sub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barqarorlik qatori: analit, uch harorat, izoh, sahifa.
class _StabilityRowView extends StatelessWidget {
  const _StabilityRowView({
    required this.row,
    required this.lang,
    required this.sources,
  });

  final StabilityRow row;
  final String lang;
  final List<CalcSource> sources;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    Widget cell(String temp, String code) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.soft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$temp · ${formatStability(code, lang)}',
        style: text.bodySmall!.copyWith(color: p.ink),
      ),
    );
    final n = sources.indexWhere((s) => s.id == CalcSources.whoDilLab99.id) + 1;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.analyte.of(lang), style: text.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                cell('−20 °C', row.frozen),
                cell('4–8 °C', row.fridge),
                cell(l.preStabilityRoom, row.room),
              ],
            ),
            if (row.note case final note?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(note.of(lang), style: text.bodySmall),
              ),
            Text(
              '[$n] ${l.citePage('${row.page}')}',
              style: text.bodySmall!.copyWith(color: p.sub),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapDot extends StatelessWidget {
  const _CapDot({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: 12, top: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: p.line, width: 1.5),
        gradient: colors.isEmpty
            ? null
            : LinearGradient(
                colors: colors.length == 1
                    ? [colors.first, colors.first]
                    : colors,
                stops: colors.length == 1 ? null : const [0.5, 0.5],
              ),
      ),
    );
  }
}

/// Probirka qatori: tartib raqami, qopqoq rangi belgisi (rang matn bilan
/// ham aytiladi — faqat rangga tayanmaydi), nomi va izohi.
class _TubeRow extends StatelessWidget {
  const _TubeRow({required this.index, required this.tube, required this.lang});

  final int index;
  final DrawTube tube;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final colors = tube.colors;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              child: Text(
                '$index',
                style: text.titleSmall!.copyWith(color: p.brand),
              ),
            ),
            _CapDot(colors: colors),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tube.name.of(lang), style: text.titleSmall),
                  Text(l.preCap(tube.cap.of(lang)), style: text.bodySmall),
                  if (tube.note != null)
                    Text(tube.note!.of(lang), style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
