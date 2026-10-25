// “Qanday foydalaniladi?” tugmasi va oynasi (bottom sheet).
//
// Tugma bo‘lim sahifasining kirish qismida (sarlavha ostida) bitta qator
// bo‘lib turadi; bosilganda bo‘limning raqamlangan qadamlari va “natijada
// nima olasiz” qatori ochiladi. Video havolasi faqat shu bo‘lim uchun video
// ro‘yxatga olingan bo‘lsa ko‘rinadi (hozir hech biri yo‘q — “tez orada”
// kabi joy egallovchi yozuv ham yo‘q).
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'howto_registry.dart';

/// Bo‘lim sarlavhasi ostidagi kichik havola-tugma.
class HowToButton extends StatelessWidget {
  const HowToButton(this.section, {super.key});

  final HowToSection section;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: LgButton.link(
          key: ValueKey('howto-${section.id}'),
          label: l.howToButton,
          icon: Icons.help_outline_rounded,
          expand: false,
          onPressed: () => showHowTo(context, HowToRegistry.of(section)),
        ),
      ),
    );
  }
}

/// How-to oynasini ochadi.
Future<void> showHowTo(BuildContext context, HowToContent content) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      // Pastki menyu (shell) ustida: oyna pastini tablar yopmasin.
      useRootNavigator: true,
      builder: (_) => HowToSheet(content: content),
    );

/// Qadamlar, natija va (ro‘yxatga olingan bo‘lsa) video havolasi.
class HowToSheet extends StatelessWidget {
  const HowToSheet({super.key, required this.content});

  final HowToContent content;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final video = content.videoUrl;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SingleChildScrollView(
        key: ValueKey('howto-sheet-${content.id}'),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.howToButton.toUpperCase(),
              style: text.labelSmall!.copyWith(
                color: p.sub,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Semantics(
              header: true,
              child: Text(content.title(l), style: text.headlineSmall),
            ),
            LgSectionTitle(l.howToStepsTitle),
            LgSteps([for (final s in content.steps) s(l)]),
            LgSectionTitle(l.howToResultTitle),
            LgPanel(child: Text(content.result(l), style: text.bodyMedium)),
            if (video != null) ...[
              const SizedBox(height: 14),
              LgButton.secondary(
                key: ValueKey('howto-video-${content.id}'),
                label: l.howToWatchVideo,
                icon: Icons.play_circle_outline_rounded,
                onPressed: () => openExternalLink(context, video),
              ),
            ],
            const SizedBox(height: 14),
            LgButton.secondary(
              label: l.actionClose,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
