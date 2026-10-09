import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import 'qc_guides_info.dart';

String qcGuideTitle(QcGuide g, AppLocalizations l) => switch (g) {
  QcGuide.rejected => l.qgRejected,
  QcGuide.eqa => l.qgEqa,
  QcGuide.critical => l.qgCritical,
};

String qcGuideSubtitle(QcGuide g, AppLocalizations l) => switch (g) {
  QcGuide.rejected => l.qgRejectedSub,
  QcGuide.eqa => l.qgEqaSub,
  QcGuide.critical => l.qgCriticalSub,
};

IconData qcGuideIcon(QcGuide g) => switch (g) {
  QcGuide.rejected => Icons.report_gmailerrorred_rounded,
  QcGuide.eqa => Icons.compare_arrows_rounded,
  QcGuide.critical => Icons.notification_important_outlined,
};

/// QC yo'riqnomasi sahifasi: kirish, bo'limlar (bosqichlar yoki ro'yxat),
/// ogohlantirish va manbalar.
class QcGuideScreen extends StatelessWidget {
  const QcGuideScreen({super.key, required this.guide});

  final QcGuide guide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final g = qcGuides[guide]!;
    return LgPage(
      title: qcGuideTitle(guide, l),
      subtitle: qcGuideSubtitle(guide, l),
      children: [
        LgPanel(child: Text(g.intro.of(lang), style: text.bodyLarge)),
        for (final s in g.sections) ...[
          LgSectionTitle(s.title.of(lang)),
          if (s.numbered)
            LgSteps([for (final x in s.items) x.of(lang)])
          else
            for (final x in s.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7, right: 10),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: p.brand,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(child: Text(x.of(lang), style: text.bodyMedium)),
                  ],
                ),
              ),
        ],
        const SizedBox(height: 10),
        LgNotice(g.notice.of(lang), kind: NoticeKind.info),
        LgSectionTitle(l.calcSources),
        for (final (i, r) in g.refs.indexed)
          CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}
