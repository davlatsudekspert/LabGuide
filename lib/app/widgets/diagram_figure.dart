import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';

/// LabGuide uchun repoda yaratilgan original jarayon sxemalari
/// (`tool/diagrams/gen_diagrams.py`; kelib chiqishi: docs/DIAGRAMS_PROVENANCE.md,
/// mazmun manbalari: docs/DIAGRAMS_CONTENT_SOURCES.md). Fayllar:
/// `assets/diagrams/<mavzu>.<til>.png` (1920×1280 = 960×640 nisbatda 2×, uz/ru/en).
enum DiagramTopic {
  calibrationOverview('calibration_overview'),
  differentialCount('differential_count'),
  educationalFeedback('educational_feedback'),
  photometry('photometry'),
  preanalytics('preanalytics'),
  qcDecision('qc_decision');

  const DiagramTopic(this.file);

  final String file;

  /// Foydalanuvchi tiliga mos fayl (til yo'q bo'lsa — inglizcha).
  String asset(String lang) =>
      'assets/diagrams/$file.${const {'uz', 'ru', 'en'}.contains(lang) ? lang : 'en'}.png';

  /// Uch tilli muqobil matn (a11y).
  String alt(AppLocalizations l) => switch (this) {
    calibrationOverview => l.imgDiagramCalibrationOverviewAlt,
    differentialCount => l.imgDiagramDifferentialCountAlt,
    educationalFeedback => l.imgDiagramEducationalFeedbackAlt,
    photometry => l.imgDiagramPhotometryAlt,
    preanalytics => l.imgDiagramPreanalyticsAlt,
    qcDecision => l.imgDiagramQcDecisionAlt,
  };
}

/// Sxema bloki: rasm (foydalanuvchi tilida), ko'rinadigan izoh va
/// “kattalashtirish” (matn kichik ekranda o'qilishi uchun to'liq ekran).
class DiagramFigure extends StatelessWidget {
  const DiagramFigure({super.key, required this.topic});

  final DiagramTopic topic;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final asset = topic.asset(lang);
    final alt = topic.alt(l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: alt,
          hint: l.imgDiagramTapToZoom,
          excludeSemantics: true,
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LgRadius.card),
              side: BorderSide(color: p.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('diagram-${topic.file}'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => _DiagramViewer(asset: asset, alt: alt),
                ),
              ),
              child: AspectRatio(
                aspectRatio: 960 / 640,
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (context, _, _) => ColoredBox(
                    color: p.line,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: p.sub,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(l.imgDiagramCaption, style: text.bodySmall),
        Text(
          l.imgDiagramTapToZoom,
          style: text.bodySmall!.copyWith(color: p.sub),
        ),
      ],
    );
  }
}

class _DiagramViewer extends StatelessWidget {
  const _DiagramViewer({required this.asset, required this.alt});

  final String asset;
  final String alt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                tooltip: l.micClose,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    semanticLabel: alt,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
