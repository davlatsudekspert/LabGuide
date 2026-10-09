import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
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
    Widget bullets(List<LocalizedText> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final x in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: text.bodyMedium),
                Expanded(child: Text(x.of(lang), style: text.bodyMedium)),
              ],
            ),
          ),
      ],
    );
    return LgPage(
      title: l.preTitle,
      children: [
        LgSteps([l.preStep1, l.preStep2, l.preStep3, l.preStep4, l.preStep5]),
        LgSectionTitle(l.preOrderTitle),
        Text(l.preOrderSub, style: text.bodySmall),
        const SizedBox(height: 8),
        for (final (i, tube) in drawOrder.indexed)
          _TubeRow(index: i + 1, tube: tube, lang: lang),
        const SizedBox(height: 10),
        bullets(drawOrderNotes),
        LgSectionTitle(l.preHaemolysisTitle),
        bullets(haemolysisCauses),
        LgSectionTitle(l.preTourniquetTitle),
        bullets(tourniquetRules),
        LgSectionTitle(l.preIdTitle),
        bullets(identificationRules),
        const SizedBox(height: 6),
        LgNotice(l.preNotice),
        LgSectionTitle(l.calcSources),
        const CalcSourceTile(
          index: 1,
          ref: CalcRef(
            CalcSources.whoPhlebotomy2010,
            'Section 2.2.3, Table 2.3; 1.1.1; 7.1.3',
          ),
        ),
      ],
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
            Container(
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
            ),
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
