// “Qanday foydalaniladi?” tugmasi va oynasi (bottom sheet).
//
// Tugma bo‘lim sahifasining kirish qismida (sarlavha ostida) bitta qator
// bo‘lib turadi; bosilganda bo‘limning raqamlangan qadamlari va “natijada
// nima olasiz” qatori ochiladi. “Videoni ko‘rish (hajm)” tugmasi faqat shu
// bo‘lim uchun ILOVA TILIDA video ro‘yxatga olingan bo‘lsa ko‘rinadi
// (assets/howto/videos.json; hozir bo‘sh — tugma ham, “tez orada” kabi joy
// egallovchi yozuv ham yo‘q). Video tizim brauzeri/pleyerida ochiladi;
// internet bo‘lmasa — oynada halol xabar, matnli qadamlar joyida qoladi.
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'howto_registry.dart';
import 'howto_videos.dart';

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
        // LgButton ichidagi Center butun kenglikni egallaydi — tugma matn
        // kengligida, chap tomonda tursin.
        child: IntrinsicWidth(
          child: LgButton.link(
            key: ValueKey('howto-${section.id}'),
            label: l.howToButton,
            icon: Icons.help_outline_rounded,
            expand: false,
            onPressed: () => _open(context),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final videos = context.services.howToVideos;
    // Kichik JSON; odatda ilova ochilganda allaqachon yuklangan.
    if (!videos.isLoaded) {
      await videos.ensureLoaded();
      if (!context.mounted) return;
    }
    await showHowTo(context, videos.contentFor(section));
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
    final video = content.videoFor(l.localeName);
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
              HowToVideoAction(sectionId: content.id, video: video),
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

/// “Videoni ko‘rish (1,3 MB)” — hajm tugmaning o‘zida (mobil internet), ostida
/// “ovozsiz, subtitrli · 0:46 · brauzerda ochiladi”. Bosilganda avval
/// manzil tekshiriladi: internet yo‘q yoki fayl joyida emas — oynada xabar
/// (matnli qadamlar shu yerda), aks holda video tashqi ilovada ochiladi.
class HowToVideoAction extends StatefulWidget {
  const HowToVideoAction({
    super.key,
    required this.sectionId,
    required this.video,
  });

  final String sectionId;
  final HowToVideo video;

  @override
  State<HowToVideoAction> createState() => _HowToVideoActionState();
}

class _HowToVideoActionState extends State<HowToVideoAction> {
  bool _checking = false;
  HowToVideoReach? _failure;

  Future<void> _watch() async {
    setState(() {
      _checking = true;
      _failure = null;
    });
    final reach = await context.services.howToVideos.probe(widget.video);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _failure = reach == HowToVideoReach.ok ? null : reach;
    });
    if (reach == HowToVideoReach.ok) {
      await openExternalLink(context, widget.video.url.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final v = widget.video;
    final start = v.startSeconds;
    final failure = _failure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgButton.secondary(
          key: ValueKey('howto-video-${widget.sectionId}'),
          label: '${l.howToWatchVideo} (${formatVideoSize(l, v.bytes)})',
          icon: Icons.play_circle_outline_rounded,
          busy: _checking,
          onPressed: _watch,
        ),
        const SizedBox(height: 6),
        Text(
          l.howToVideoNote(formatVideoTime(v.seconds)),
          style: text.bodySmall!.copyWith(color: p.sub),
        ),
        if (start != null && start > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              // Pastga yaxlitlanadi: foydalanuvchi bo‘lim boshini o‘tkazib yubormasin.
              l.howToVideoStartsAt(formatVideoTime(start.floorToDouble())),
              key: const ValueKey('howto-video-start'),
              style: text.bodySmall!.copyWith(color: p.sub),
            ),
          ),
        if (failure != null)
          Semantics(
            liveRegion: true,
            child: LgNotice(
              key: ValueKey('howto-video-${failure.name}'),
              failure == HowToVideoReach.offline
                  ? l.howToVideoOffline
                  : l.howToVideoUnavailable,
            ),
          ),
      ],
    );
  }
}

/// Mobil internet uchun hajm: o‘nlik MB (1 MB = 1 000 000 bayt — trafik
/// hisobi kabi), bitta kasr raqami, til bo‘yicha ajratgich (uz/ru “1,3”).
String formatVideoSize(AppLocalizations l, int bytes) {
  final mb = bytes / 1000000;
  final f = NumberFormat.decimalPatternDigits(
    locale: l.localeName,
    decimalDigits: 1,
  );
  return l.howToVideoMb(f.format(mb < 0.1 ? 0.1 : mb));
}

/// Davomiylik / boshlanish vaqti: “0:46”, “1:04”.
String formatVideoTime(double seconds) {
  final s = seconds.round();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}
