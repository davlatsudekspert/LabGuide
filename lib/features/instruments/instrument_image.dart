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
/// bo'lsa — foto (muallif va litsenziya bilan). Foto yo'q bo'lsa — apparat
/// TURINING LabGuide chizgan sxematik tasviri va ko'rinib turuvchi izoh
/// “Sxematik tasvir — aniq model emas”. Sxematik chizma hech qachon
/// model fotosi sifatida ko'rsatilmaydi va boshqa apparat fotosi qo'yilmaydi.
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
        ] else ...[
          _SchematicBlock(model: model, hasPage: page != null),
        ],
        if (page != null) _Link(label: l.instMakerSource, url: page.url),
      ],
    );
  }
}

/// Foto yo'q model: apparat turining sxematik chizmasi + majburiy izoh
/// (uz/ru/en) — foydalanuvchi buni aniq model fotosi deb o'ylamasligi uchun.
class _SchematicBlock extends StatelessWidget {
  const _SchematicBlock({required this.model, required this.hasPage});

  final InstrumentModel model;

  /// Rasmiy sahifa havolasi bor — “aniq model rasmini u yerda ko'ring” izohi.
  final bool hasPage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final schematic = model.schematic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SchematicFigure(
          asset: schematic.asset,
          assetLarge: schematic.assetLarge,
          semanticLabel: l.instSchematicSemantics(model.kind.of(lang)),
          viewerTitle: model.model,
          figureKey: const ValueKey('instrument-schematic'),
          captionKey: const ValueKey('instrument-schematic-caption'),
        ),
        if (hasPage) ...[
          const SizedBox(height: 4),
          Text(
            l.instImageMissingSub,
            style: text.bodySmall!.copyWith(color: p.sub),
          ),
        ],
      ],
    );
  }
}

/// LabGuide chizgan sxematik tasvir (apparat TURI yoki SINFI, aniq model
/// emas): ramkadagi kichik nusxa, ko'rinib turuvchi izoh “Sxematik tasvir —
/// aniq model emas”, bosilsa to'liq ekran ([InstrumentSchematicViewer]).
/// Model kartasi va yo'nalish (lab) kartasi shu vidjetni qayta ishlatadi.
class SchematicFigure extends StatelessWidget {
  const SchematicFigure({
    super.key,
    required this.asset,
    required this.assetLarge,
    required this.semanticLabel,
    required this.viewerTitle,
    this.figureKey,
    this.captionKey,
  });

  final String asset;
  final String assetLarge;

  /// Rasm mazmunining lokalizatsiyalangan tavsifi (ekran o'quvchi uchun).
  final String semanticLabel;

  /// To'liq ekran sarlavhasi.
  final String viewerTitle;
  final Key? figureKey;
  final Key? captionKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: l.instSchematicTapToZoom,
          child: Material(
            color: _frameColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LgRadius.card),
              side: BorderSide(color: p.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: figureKey,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => InstrumentSchematicViewer(
                    asset: assetLarge,
                    title: viewerTitle,
                    semanticLabel: semanticLabel,
                  ),
                ),
              ),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    semanticLabel: semanticLabel,
                    errorBuilder: (context, _, _) =>
                        const _MissingMark(compact: true),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          key: captionKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(Icons.info_outline_rounded, size: 16, color: p.ink),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l.instSchematicCaption,
                style: text.bodySmall!.copyWith(
                  color: p.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Text(
          l.instSchematicTapToZoom,
          style: text.bodySmall!.copyWith(color: p.sub),
        ),
      ],
    );
  }
}

/// Neutral apparat belgisi va “rasm hozircha mavjud emas” yozuvi
/// (rasm fayli o'qilmaganda — errorBuilder).
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
    return _ViewerScaffold(
      title: title,
      asset: image.assetLarge,
      semanticLabel: l.instImageSemantics(title),
      footer:
          '${l.instImageCredit(image.author, image.license)}\n'
          '${image.rights}',
    );
  }
}

/// Sxematik chizmaning to'liq ekrani — pastda “aniq model emas” izohi.
class InstrumentSchematicViewer extends StatelessWidget {
  const InstrumentSchematicViewer({
    super.key,
    required this.asset,
    required this.title,
    this.semanticLabel,
  });

  /// Katta nusxa (~1200 px).
  final String asset;
  final String title;

  /// Rasm tavsifi; berilmasa — izoh matni.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _ViewerScaffold(
      title: title,
      asset: asset,
      semanticLabel: semanticLabel ?? l.instSchematicCaption,
      footer: l.instSchematicCaption,
    );
  }
}

class _ViewerScaffold extends StatelessWidget {
  const _ViewerScaffold({
    required this.title,
    required this.asset,
    required this.semanticLabel,
    required this.footer,
  });

  final String title;
  final String asset;
  final String semanticLabel;
  final String footer;

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
                    asset,
                    fit: BoxFit.contain,
                    semanticLabel: semanticLabel,
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
                footer,
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
