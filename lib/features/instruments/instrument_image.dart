import 'package:material_ui/material_ui.dart';

import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import 'instrument_catalog.dart';

/// Rasm maydonining neytral foni (fotoning o'z rangiga aralashmaydi).
Color _frameColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF242A29)
    : const Color(0xFFF6F6F3);

/// Model kartasidagi rasm bloki (D-36a): aynan shu modelning ruxsatli fotosi
/// yoki neytral belgi + “Model rasmi hozircha mavjud emas”. Boshqa apparat
/// fotosi yoki sxematik chizma bu yerda ko'rsatilmaydi.
class InstrumentImageBlock extends StatelessWidget {
  const InstrumentImageBlock({
    super.key,
    required this.model,
    required this.officialPage,
  });

  final InstrumentModel model;

  /// Ishlab chiqaruvchining rasmiy mahsulot sahifasi (bo'lsa).
  final CatalogSource? officialPage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final img = model.image;
    final page = officialPage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (img != null) ...[
          Semantics(
            button: true,
            label: l.instImageTapToZoom,
            child: Material(
              color: _frameColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LgRadius.card),
                side: BorderSide(color: p.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('instrument-photo'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) =>
                        InstrumentImageViewer(image: img, title: model.model),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      img.asset,
                      fit: BoxFit.contain,
                      semanticLabel: l.instImageSemantics(model.model),
                      errorBuilder: (context, _, _) =>
                          const _MissingMark(compact: true),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(img.caption.of(lang), style: text.bodySmall),
          Text(
            l.instImageTapToZoom,
            style: text.bodySmall!.copyWith(color: p.sub),
          ),
          _Link(
            label: l.instImageCredit(img.author, img.license),
            url: img.sourceUrl,
          ),
          Text(
            l.instImageRightsChecked(img.checkedAt),
            style: text.bodySmall!.copyWith(color: p.sub),
          ),
        ] else
          Container(
            key: const ValueKey('instrument-photo-missing'),
            decoration: BoxDecoration(
              color: _frameColor(context),
              borderRadius: BorderRadius.circular(LgRadius.card),
              border: Border.all(color: p.line),
            ),
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              // Rasmli kartadagi maydon bilan bir xil balandlik (3:2);
              // katta shriftda kerak bo'lsa o'sadi.
              builder: (context, c) => ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (c.maxWidth + 40) * 2 / 3 - 40,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _MissingMark(compact: false),
                      if (page != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.instImageMissingSub,
                          style: text.bodySmall!.copyWith(color: p.sub),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (page != null) _Link(label: l.instMakerSource, url: page.url),
      ],
    );
  }
}

/// Neutral apparat belgisi va “rasm hozircha mavjud emas” yozuvi.
class _MissingMark extends StatelessWidget {
  const _MissingMark({required this.compact});

  /// Belgilangan o'lchamli maydon ichida (errorBuilder) — sig'masa kichrayadi.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 48, color: p.sub),
        const SizedBox(height: 10),
        Text(
          l.instImageMissing,
          style: text.titleSmall!.copyWith(color: p.ink),
          textAlign: TextAlign.center,
        ),
      ],
    );
    if (!compact) return body;
    return Center(
      child: FittedBox(fit: BoxFit.scaleDown, child: body),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => openExternalLink(context, url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded, size: 16, color: p.brand),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: text.bodySmall!.copyWith(
                  color: p.brand,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// To'liq ekran: katta nusxa, InteractiveViewer (ikki barmoq bilan
/// kattalashtirish), pastda muallif va litsenziya.
class InstrumentImageViewer extends StatelessWidget {
  const InstrumentImageViewer({
    super.key,
    required this.image,
    required this.title,
  });

  final InstrumentImage image;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    const fg = Colors.white;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l.micClose,
                  icon: const Icon(Icons.close_rounded, color: fg),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: text.titleMedium!.copyWith(color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 6,
                child: Center(
                  child: Image.asset(
                    image.assetLarge,
                    fit: BoxFit.contain,
                    semanticLabel: l.instImageSemantics(title),
                    errorBuilder: (context, _, _) => Text(
                      l.instImageMissing,
                      style: text.bodyMedium!.copyWith(color: fg),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                '${l.instImageCredit(image.author, image.license)}\n'
                '${image.rights}',
                style: text.bodySmall!.copyWith(color: fg),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yo'nalish sahifasidagi bezak chizmasi — “sxematik” izohi bilan.
class CategoryIllustration extends StatelessWidget {
  const CategoryIllustration({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(LgRadius.card),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              alignment: const Alignment(0, 0.45),
              excludeFromSemantics: true,
              errorBuilder: (context, _, _) =>
                  ColoredBox(color: _frameColor(context)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(l.instIllustration, style: text.bodySmall!.copyWith(color: p.sub)),
      ],
    );
  }
}
