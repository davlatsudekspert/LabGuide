import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'microscopy_atlas.dart';
import 'microscopy_controller.dart';

const microBase = '/lab/microscopy';

String microImageRoute(String id) => '$microBase/i/$id';
String microSectionRoute(String id) => '$microBase/s/$id';
String microQuizRoute([String? sectionId]) => sectionId == null
    ? '$microBase/quiz'
    : '$microBase/quiz?section=$sectionId';

/// Asl izoh tilining nomi (joriy interfeys tilida).
String microLanguageName(AppLocalizations l, String code) => switch (code) {
  'en' => l.micLangEn,
  'es' => l.micLangEs,
  'ru' => l.micLangRu,
  _ => code.toUpperCase(),
};

/// Kichik nusxa o'lchamlari (px). Oz sonli o'lcham — dekod qilingan rasm
/// keshda qayta ishlatiladi.
abstract final class MicroThumb {
  static const small = 240;
  static const card = 560;
  static const large = 1100;
}

/// Kichik nusxa (grid, mashq): katta JPEG xotiraga to'liq dekod qilinmaydi.
ImageProvider microThumb(MicroImage i, {int width = MicroThumb.card}) =>
    ResizeImage(AssetImage(i.asset), width: width);

/// Atlas yuklanguncha sahifa skeleti; buzilgan bo'lsa — xato va qayta urinish.
/// Tayyor bo'lganda [builder] butun sahifani quradi.
class MicroAtlasGate extends StatefulWidget {
  const MicroAtlasGate({
    super.key,
    required this.fallbackTitle,
    required this.builder,
  });

  final String fallbackTitle;
  final Widget Function(BuildContext context, MicroAtlas atlas) builder;

  @override
  State<MicroAtlasGate> createState() => _MicroAtlasGateState();
}

class _MicroAtlasGateState extends State<MicroAtlasGate> {
  @override
  void initState() {
    super.initState();
    context.services.microscopy.ensureAtlas();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.services.microscopy;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final atlas = c.atlas;
        if (atlas != null) return widget.builder(context, atlas);
        return LgPage(
          title: widget.fallbackTitle,
          children: [
            if (c.state == AtlasLoadState.failed)
              LgStateView(
                kind: StateKind.error,
                title: l.micAtlasError,
                actionLabel: l.actionRetry,
                onAction: c.retry,
              )
            else
              const LgStateView(kind: StateKind.loading, title: ''),
          ],
        );
      },
    );
  }
}

/// Topilmagan rasm/bo'lim — halol holat.
class MicroNotFound extends StatelessWidget {
  const MicroNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.micTitle,
      children: [
        LgStateView(
          kind: StateKind.empty,
          title: l.micNotFound,
          actionLabel: l.micQuizBackToAtlas,
          onAction: () => context.go(microBase),
        ),
      ],
    );
  }
}

/// Yumaloq burchakli mikrofoto. Rasm yuklanguncha yumshoq fon; o'lcham
/// JSON'dagi tomonlar nisbatidan (rasmga bog'liq emas — layout sakramaydi).
class MicroPicture extends StatelessWidget {
  const MicroPicture({
    super.key,
    required this.image,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.cacheWidth = MicroThumb.card,
    this.borderRadius = const BorderRadius.all(Radius.circular(LgRadius.card)),
    this.semanticLabel,
  });

  final MicroImage image;
  final double? aspectRatio;
  final BoxFit fit;

  /// `null` — to'liq o'lcham.
  final int? cacheWidth;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final ImageProvider provider = cacheWidth == null
        ? AssetImage(image.asset)
        : microThumb(image, width: cacheWidth!);
    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: aspectRatio ?? image.aspectRatio,
        child: ColoredBox(
          color: p.soft,
          child: Image(
            image: provider,
            fit: fit,
            semanticLabel: semanticLabel,
            excludeFromSemantics: semanticLabel == null,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) =>
                Center(child: Icon(Icons.broken_image_outlined, color: p.sub)),
          ),
        ),
      ),
    );
  }
}

/// Rasm ustidagi kichik yorliq (qora shaffof fon — har mavzuda o'qiladi).
class MicroGlassPill extends StatelessWidget {
  const MicroGlassPill(this.text, {super.key, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall!
        .copyWith(color: Colors.white, letterSpacing: 0.2);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(LgRadius.tag),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 13, color: Colors.white),
            if (icon != null && text.isNotEmpty) const SizedBox(width: 4),
            if (text.isNotEmpty) Flexible(child: Text(text, style: style)),
          ],
        ),
      ),
    );
  }
}

/// Galereya kartasi: rasm, tur nomi va manbadagi preparat ma'lumoti.
class MicroImageCard extends StatelessWidget {
  const MicroImageCard({super.key, required this.atlas, required this.image});

  final MicroAtlas atlas;
  final MicroImage image;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final entity = atlas.entity(image.entityId)!;
    final name = entity.name.of(lang);
    final meta = [
      ?image.magnification,
      ?image.stain?.translation.of(lang),
    ].join(' · ');
    const radius = BorderRadius.all(Radius.circular(LgRadius.card));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: p.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LgPressable(
        onTap: () => context.push(microImageRoute(image.id)),
        color: p.paper,
        borderRadius: radius,
        semanticLabel: l.micImageSemantics(name),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  MicroPicture(
                    image: image,
                    aspectRatio: 4 / 3,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(LgRadius.card),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: MicroGlassPill(
                      image.provider == MicroProvider.cdcPhil
                          ? 'CDC PHIL'
                          : image.license,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleSmall),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1, right: 4),
                          child: Icon(
                            meta.isEmpty
                                ? Icons.person_outline_rounded
                                : Icons.biotech_outlined,
                            size: 15,
                            color: p.sub,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            meta.isEmpty ? image.author : meta,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Litsenziyali rasmi hali topilmagan tur — bo'sh joy emas, halol karta.
class MicroGapCard extends StatelessWidget {
  const MicroGapCard({super.key, required this.entity});

  final MicroEntity entity;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final name = entity.name.of(lang);
    const radius = BorderRadius.all(Radius.circular(LgRadius.card));
    return LgPressable(
      onTap: () => showMicroGap(context, entity),
      color: p.bg,
      borderRadius: radius,
      border: Border.all(color: p.outline.withValues(alpha: 0.6)),
      semanticLabel: '$name. ${l.micNoImageYet}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: p.soft.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(LgRadius.card - 6),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hide_image_outlined, color: p.sub, size: 28),
                        const SizedBox(height: 6),
                        Flexible(
                          child: Text(
                            l.micNoImageYet,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelMedium!.copyWith(color: p.sub),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    l.micGapWhy,
                    style: text.bodySmall!.copyWith(
                      color: p.brand,
                      decoration: TextDecoration.underline,
                    ),
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

/// “Nega rasm yo'q?” — sababi (manbali, sana bilan).
Future<void> showMicroGap(BuildContext context, MicroEntity entity) {
  final l = AppLocalizations.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entity.name.of(lang),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            LgNotice(entity.gap!.of(lang), title: l.micNoImageYet),
          ],
        ),
      ),
    ),
  );
}

/// Grid: rasmli turlar — har rasm alohida karta; rasmsizlari — “hali yo'q”.
List<Widget> microCards(MicroAtlas atlas, Iterable<MicroEntity> entities) => [
  for (final e in entities)
    if (e.gap != null)
      MicroGapCard(entity: e)
    else
      for (final i in atlas.imagesOf(e.id))
        MicroImageCard(atlas: atlas, image: i),
];

/// Mikrofotoni to'liq ekranda ochish (pastki tablar ustida).
Future<void> openMicroViewer(
  BuildContext context,
  MicroImage image,
  String title,
) {
  final duration = LgMotion.of(context, LgMotion.page);
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, _, _) => MicroViewer(image: image, title: title),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// To'liq ekran ko'rish: InteractiveViewer (ikki barmoq / ikki marta bosish)
/// va tugmalar (+ / − / asl ko'rinish) — har kim kattalashtira oladi.
/// Pastda muallif va litsenziya doim ko'rinadi.
class MicroViewer extends StatefulWidget {
  const MicroViewer({super.key, required this.image, required this.title});

  final MicroImage image;
  final String title;

  @override
  State<MicroViewer> createState() => _MicroViewerState();
}

class _MicroViewerState extends State<MicroViewer>
    with SingleTickerProviderStateMixin {
  static const _maxScale = 8.0;
  final _transform = TransformationController();
  final _viewportKey = GlobalKey();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..addListener(_tick);
  Matrix4Tween? _tween;
  Offset? _doubleTapAt;

  void _tick() {
    final t = _tween;
    if (t != null) {
      _transform.value = t.evaluate(
        CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
      );
    }
  }

  double get _scale => _transform.value.getMaxScaleOnAxis();

  Size get _viewport =>
      (_viewportKey.currentContext?.findRenderObject() as RenderBox?)?.size ??
      MediaQuery.sizeOf(context);

  /// [focal] nuqtasi atrofida [scale] gacha (viewport koordinatasida).
  Matrix4 _matrixFor(double scale, Offset focal) {
    if (scale <= 1.001) return Matrix4.identity();
    final scene = _transform.toScene(focal);
    final size = _viewport;
    var tx = focal.dx - scene.dx * scale;
    var ty = focal.dy - scene.dy * scale;
    // Kontent viewport'dan chiqib ketmasin.
    tx = tx.clamp(size.width - size.width * scale, 0.0);
    ty = ty.clamp(size.height - size.height * scale, 0.0);
    return Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(tx, ty, 0);
  }

  void _animateTo(Matrix4 target) {
    if (LgMotion.reduced(context)) {
      _transform.value = target;
      return;
    }
    _tween = Matrix4Tween(begin: _transform.value, end: target);
    _anim.forward(from: 0);
  }

  void _zoomBy(double factor) {
    final size = _viewport;
    final next = (_scale * factor).clamp(1.0, _maxScale);
    _animateTo(_matrixFor(next, size.center(Offset.zero)));
  }

  void _onDoubleTap() {
    if (_scale > 1.05) {
      _animateTo(Matrix4.identity());
    } else {
      final at = _doubleTapAt ?? _viewport.center(Offset.zero);
      _animateTo(_matrixFor(2.5, at));
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final image = widget.image;
    const fg = Colors.white;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
              onDoubleTap: _onDoubleTap,
              child: InteractiveViewer(
                key: _viewportKey,
                transformationController: _transform,
                minScale: 1,
                maxScale: _maxScale,
                child: Center(
                  child: Image.asset(
                    image.asset,
                    fit: BoxFit.contain,
                    semanticLabel: l.micImageSemantics(widget.title),
                  ),
                ),
              ),
            ),
          ),
          // Yuqori panel: yopish va sarlavha.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 16, 18),
                  child: Row(
                    children: [
                      _ViewerButton(
                        icon: Icons.close_rounded,
                        tooltip: l.micClose,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium!.copyWith(color: fg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Pastki panel: tugmalar, muallif va litsenziya.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ViewerButton(
                            icon: Icons.zoom_out_rounded,
                            tooltip: l.micZoomOut,
                            onTap: () => _zoomBy(1 / 1.6),
                          ),
                          const SizedBox(width: 14),
                          _ViewerButton(
                            icon: Icons.fit_screen_rounded,
                            tooltip: l.micZoomReset,
                            onTap: () => _animateTo(Matrix4.identity()),
                          ),
                          const SizedBox(width: 14),
                          _ViewerButton(
                            icon: Icons.zoom_in_rounded,
                            tooltip: l.micZoomIn,
                            onTap: () => _zoomBy(1.6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${image.author} · ${image.license}',
                        textAlign: TextAlign.center,
                        style: text.bodySmall!.copyWith(
                          color: fg.withValues(alpha: 0.92),
                        ),
                      ),
                      Text(
                        l.micViewerHint,
                        textAlign: TextAlign.center,
                        style: text.bodySmall!.copyWith(
                          color: fg.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerButton extends StatelessWidget {
  const _ViewerButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          color: Colors.white.withValues(alpha: 0.16),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 48,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bir nechta mikrofotodan dekorativ “doiralar” (hero kartalar uchun).
class MicroMosaic extends StatelessWidget {
  const MicroMosaic({super.key, required this.images, this.size = 58});

  final List<MicroImage> images;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final step = size * 0.68;
    return ExcludeSemantics(
      child: SizedBox(
        width: size + step * (images.length - 1),
        height: size,
        child: Stack(
          children: [
            for (final (i, img) in images.indexed)
              Positioned(
                left: step * i,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: p.paper, width: 3),
                    color: p.soft,
                  ),
                  child: ClipOval(
                    child: Image(
                      image: microThumb(img, width: MicroThumb.small),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
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
