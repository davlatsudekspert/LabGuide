import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import 'library_catalog.dart';
import 'library_widgets.dart';
import 'reading_controller.dart';

/// Mundarija bandi (ichma-ich daraxt tekis ro'yxatga aylantirilgan).
@immutable
class ReaderTocEntry {
  const ReaderTocEntry(this.title, this.page, this.level);

  final String title;

  /// Manzili yo'q band (faqat sarlavha) — `null`.
  final int? page;
  final int level;
}

/// PDF mundarijasini (outline) tekis ro'yxatga aylantiradi.
List<ReaderTocEntry> flattenOutline(
  List<PdfOutlineNode> nodes, [
  int level = 0,
]) {
  return [
    for (final n in nodes) ...[
      ReaderTocEntry(
        n.title.trim().isEmpty ? '—' : n.title.trim(),
        n.dest?.pageNumber,
        level,
      ),
      ...flattenOutline(n.children, level + 1),
    ],
  ];
}

/// Joriy sahifa qaysi bo'limda: sahifasi [page] dan oshmagan oxirgi band.
int? currentTocIndex(List<ReaderTocEntry> entries, int page) {
  int? best;
  for (final (i, e) in entries.indexed) {
    final p = e.page;
    if (p != null && p <= page) best = i;
  }
  return best;
}

/// “Sahifaga o'tish” maydonidagi qiymat: 1..[total] oralig'ida bo'lsa son.
int? parsePageInput(String input, int total) {
  final n = int.tryParse(input.trim());
  if (n == null || n < 1 || n > total) return null;
  return n;
}

/// Kutubxonadagi ilova ichidagi PDF o'quvchisi. Faqat to'liq tarqatish
/// huquqi qayd etilgan fayllar ochiladi ([canReadInApp]); fayl ochishdan
/// oldin hajmi va sha256 tekshiriladi.
class PdfReaderScreen extends StatelessWidget {
  const PdfReaderScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    final content = context.services.content;
    return ListenableBuilder(
      listenable: content,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final pack = content.pack;
        final item = pack?.libraryItem(itemId);
        if (pack == null || item == null) {
          return LgPage(
            title: l.readerTitle,
            children: [
              ContentGate(
                builder: (context, _) => LgStateView(
                  kind: StateKind.empty,
                  title: l.libItemNotFound,
                  message: l.libItemNotFoundBody,
                ),
              ),
            ],
          );
        }
        if (!canReadInApp(item)) return _ReaderBlocked(item: item);
        return _ReaderLoader(key: ValueKey(item.file!.sha256), item: item);
      },
    );
  }
}

/// Ilova ichida ochib bo'lmaydigan material — halol sabab bilan.
class _ReaderBlocked extends StatelessWidget {
  const _ReaderBlocked({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final url = item.url;
    final pending = openKindOf(item) == LibraryOpenKind.pending;
    return LgPage(
      title: libraryShortTitle(item, max: 80),
      children: [
        LgStateView(
          kind: StateKind.unavailable,
          title: pending ? l.libOpenPending : l.readerBlockedTitle,
          message: pending ? openKindHint(item, l) : l.readerBlockedRights,
          actionLabel: !pending && url != null ? l.libOpenSource : null,
          onAction: !pending && url != null
              ? () => openExternalLink(context, url)
              : null,
        ),
      ],
    );
  }
}

class _ReaderLoader extends StatefulWidget {
  const _ReaderLoader({super.key, required this.item});

  final LibraryItem item;

  @override
  State<_ReaderLoader> createState() => _ReaderLoaderState();
}

class _ReaderLoaderState extends State<_ReaderLoader> {
  late Future<Uint8List> _bytes = _load();

  Future<Uint8List> _load() =>
      context.services.reading.loadFile(widget.item.file!);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snap) {
        if (snap.hasData) {
          return _ReaderView(item: widget.item, bytes: snap.data!);
        }
        final title = libraryShortTitle(widget.item, max: 80);
        if (snap.hasError) {
          final missing =
              snap.error is LibraryFileException &&
              (snap.error! as LibraryFileException).failure ==
                  LibraryFileFailure.missing;
          return LgPage(
            title: title,
            children: [
              LgStateView(
                kind: StateKind.error,
                title: missing ? l.readerFileMissing : l.readerFileCorrupted,
                message: missing
                    ? l.readerFileMissingBody
                    : l.readerFileCorruptedBody,
                actionLabel: l.actionRetry,
                onAction: () => setState(() => _bytes = _load()),
              ),
            ],
          );
        }
        return LgPage(
          title: title,
          children: [
            LgStateView(kind: StateKind.loading, title: l.readerLoading),
          ],
        );
      },
    );
  }
}

class _ReaderView extends StatefulWidget {
  const _ReaderView({required this.item, required this.bytes});

  final LibraryItem item;
  final Uint8List bytes;

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

/// Sheet natijasi: sahifaga o'tish yoki xatcho'p qo'shish.
sealed class _SheetResult {
  const _SheetResult();
}

class _GoToResult extends _SheetResult {
  const _GoToResult(this.page);
  final int page;
}

class _AddBookmarkResult extends _SheetResult {
  const _AddBookmarkResult();
}

class _OpenGoToResult extends _SheetResult {
  const _OpenGoToResult();
}

class _ReaderViewState extends State<_ReaderView> {
  final _controller = PdfViewerController();
  late final ReadingController _reading = context.services.reading;
  late final int _initialPage;
  int _page = 1;
  int? _pageCount;
  List<ReaderTocEntry>? _toc;
  Timer? _saveTimer;
  ScaffoldMessengerState? _messenger;

  /// “Oxirgi o'qilgan joy” xabari — boshqa sahifaga o'tilganda yopiladi.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _resumeSnack;

  String get _id => widget.item.id;
  String get _sha => widget.item.file!.sha256;
  bool get _ready => _pageCount != null;

  @override
  void initState() {
    super.initState();
    _initialPage = _reading.stateOf(_id, _sha)?.lastPage ?? 1;
    _page = _initialPage;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    // Yopilganda oxirgi sahifa albatta yoziladi.
    if (_saveTimer?.isActive ?? false) {
      _saveTimer!.cancel();
      _save();
    }
    // O'quvchi xabarlari boshqa sahifada qolib ketmasin.
    _messenger?.hideCurrentSnackBar();
    super.dispose();
  }

  void _save() =>
      unawaited(_reading.setLastPage(_id, _sha, _page, pageCount: _pageCount));

  void _onReady(PdfDocument document, PdfViewerController controller) {
    final count = document.pages.length;
    setState(() {
      _pageCount = count;
      _page = (controller.pageNumber ?? _page).clamp(1, count);
    });
    _save();
    unawaited(_loadToc(document));
    if (_initialPage > 1) {
      final l = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      _resumeSnack = messenger.showSnackBar(
        SnackBar(
          content: Text(l.readerResumed(_page)),
          action: SnackBarAction(
            label: l.readerFromStart,
            onPressed: () => _goTo(1),
          ),
        ),
      );
    }
  }

  Future<void> _loadToc(PdfDocument document) async {
    List<ReaderTocEntry> toc;
    try {
      toc = flattenOutline(await document.loadOutline());
    } on Object catch (e) {
      debugPrint('outline: $e');
      toc = const [];
    }
    if (mounted) setState(() => _toc = toc);
  }

  void _onPageChanged(int? page) {
    if (page == null || page == _page) return;
    _resumeSnack?.close();
    _resumeSnack = null;
    setState(() => _page = page);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _save);
  }

  Future<void> _goTo(int page) async {
    if (!_controller.isReady) return;
    await _controller.goToPage(pageNumber: page, anchor: PdfPageAnchor.top);
    // Animatsiya tugagach sahifa raqami aniq bo'ladi.
    _onPageChanged(_controller.pageNumber ?? page);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addBookmark() async {
    final l = AppLocalizations.of(context);
    final page = _page;
    final existing = _reading.stateOf(_id, _sha)?.bookmarkAt(page);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _BookmarkNameDialog(
        page: page,
        initial: existing?.name ?? '',
        rename: existing != null,
      ),
    );
    if (name == null || !mounted) return;
    await _reading.addBookmark(_id, _sha, page, name: name);
    _snack(l.readerBookmarkSaved(page));
  }

  Future<void> _toggleBookmark() async {
    final l = AppLocalizations.of(context);
    if (_reading.stateOf(_id, _sha)?.bookmarkAt(_page) != null) {
      await _reading.removeBookmark(_id, _sha, _page);
      _snack(l.readerBookmarkRemoved);
    } else {
      await _addBookmark();
    }
  }

  Future<void> _showGoTo() async {
    final total = _pageCount;
    if (total == null) return;
    final page = await showDialog<int>(
      context: context,
      builder: (context) => _GoToPageDialog(total: total, current: _page),
    );
    if (page != null) await _goTo(page);
  }

  Future<void> _handle(_SheetResult? result) async {
    switch (result) {
      case _GoToResult(:final page):
        await _goTo(page);
      case _AddBookmarkResult():
        await _addBookmark();
      case _OpenGoToResult():
        await _showGoTo();
      case null:
        break;
    }
  }

  Future<void> _showToc() async {
    final p = LgPalette.of(context);
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: p.paper,
      builder: (context) => _TocSheet(entries: _toc, page: _page),
    );
    await _handle(result);
  }

  Future<void> _showBookmarks() async {
    final p = LgPalette.of(context);
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: p.paper,
      builder: (context) => _BookmarksSheet(
        reading: _reading,
        itemId: _id,
        fileSha: _sha,
        page: _page,
      ),
    );
    await _handle(result);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _reading,
            builder: (context, _) => _ReaderTopBar(
              title: libraryShortTitle(widget.item, max: 90),
              status: _ready
                  ? l.readerPageOf(_page, _pageCount!)
                  : l.readerLoading,
              bookmarked:
                  _reading.stateOf(_id, _sha)?.bookmarkAt(_page) != null,
              onBookmark: _ready ? _toggleBookmark : null,
            ),
          ),
          Expanded(
            child: ClipRect(
              child: PdfViewer.data(
                widget.bytes,
                sourceName: 'labguide-library:$_id:$_sha',
                controller: _controller,
                initialPageNumber: _initialPage,
                params: PdfViewerParams(
                  backgroundColor: p.bg,
                  margin: 10,
                  pageDropShadow: BoxShadow(
                    color: p.shadow.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                  onViewerReady: _onReady,
                  onPageChanged: _onPageChanged,
                  loadingBannerBuilder: (
                    context,
                    bytesDownloaded,
                    totalBytes,
                  ) => Center(child: CircularProgressIndicator(color: p.brand)),
                  errorBannerBuilder: (context, error, stackTrace, ref) =>
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: LgStateView(
                          kind: StateKind.error,
                          title: l.readerOpenFailed,
                          message: l.readerFileCorruptedBody,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ReaderToolbar(
        enabled: _ready,
        onToc: _showToc,
        onBookmarks: _showBookmarks,
        onGoTo: _showGoTo,
        onZoomOut: () => unawaited(_controller.zoomDown()),
        onZoomIn: () => unawaited(_controller.zoomUp()),
      ),
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  const _ReaderTopBar({
    required this.title,
    required this.status,
    required this.bookmarked,
    required this.onBookmark,
  });

  final String title;
  final String status;
  final bool bookmarked;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5);
    return ColoredBox(
      color: p.bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Row(
            children: [
              _RoundIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: l.actionBack,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: scaler),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium,
                        ),
                      ),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _RoundIconButton(
                icon: bookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_add_outlined,
                tooltip: bookmarked
                    ? l.readerBookmarkRemove
                    : l.readerAddBookmark,
                selected: bookmarked,
                onTap: onBookmark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: tooltip,
        onTap: onTap,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            width: kMinTap + 4,
            height: kMinTap + 4,
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: onTap == null
                    ? p.sub.withValues(alpha: 0.5)
                    : selected
                    ? p.brand
                    : p.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReaderToolbar extends StatelessWidget {
  const _ReaderToolbar({
    required this.enabled,
    required this.onToc,
    required this.onBookmarks,
    required this.onGoTo,
    required this.onZoomOut,
    required this.onZoomIn,
  });

  final bool enabled;
  final VoidCallback onToc;
  final VoidCallback onBookmarks;
  final VoidCallback onGoTo;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    VoidCallback? on(VoidCallback f) => enabled ? f : null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.paper,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: _ToolButton(
                  icon: Icons.toc_rounded,
                  label: l.readerToc,
                  onTap: on(onToc),
                ),
              ),
              Expanded(
                child: _ToolButton(
                  icon: Icons.bookmarks_outlined,
                  label: l.readerBookmarks,
                  onTap: on(onBookmarks),
                ),
              ),
              Expanded(
                child: _ToolButton(
                  icon: Icons.find_in_page_outlined,
                  label: l.readerGoToShort,
                  tooltip: l.readerGoTo,
                  onTap: on(onGoTo),
                ),
              ),
              _RoundIconButton(
                icon: Icons.zoom_out_rounded,
                tooltip: l.readerZoomOut,
                onTap: on(onZoomOut),
              ),
              _RoundIconButton(
                icon: Icons.zoom_in_rounded,
                tooltip: l.readerZoomIn,
                onTap: on(onZoomIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final color = onTap == null ? p.sub.withValues(alpha: 0.5) : p.ink;
    // Pastki panel tab nomlari kabi: juda katta shriftda ham bir qatorda.
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: tooltip ?? label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 23, color: color),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    textScaler: scaler,
                    style: text.labelSmall!.copyWith(
                      color: color,
                      fontSize: 11.5,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Semantics(
        header: true,
        child: Text(title, style: text.titleLarge),
      ),
    );
  }
}

class _TocSheet extends StatelessWidget {
  const _TocSheet({required this.entries, required this.page});

  final List<ReaderTocEntry>? entries;
  final int page;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final list = entries;
    final current = list == null ? null : currentTocIndex(list, page);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: EdgeInsets.fromLTRB(
          12,
          0,
          12,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _SheetHeader(title: l.readerToc),
          if (list == null)
            LgStateView(kind: StateKind.loading, title: l.readerLoading)
          else if (list.isEmpty)
            LgStateView(
              kind: StateKind.empty,
              title: l.readerTocEmpty,
              message: l.readerTocEmptyBody,
              actionLabel: l.readerGoTo,
              onAction: () =>
                  Navigator.of(context).pop(const _OpenGoToResult()),
            )
          else
            for (final (i, e) in list.indexed)
              _TocRow(
                entry: e,
                current: i == current,
                onTap: e.page == null
                    ? null
                    : () => Navigator.of(context).pop(_GoToResult(e.page!)),
                palette: p,
                text: text,
                pageLabel: e.page == null ? '' : '${e.page}',
              ),
        ],
      ),
    );
  }
}

class _TocRow extends StatelessWidget {
  const _TocRow({
    required this.entry,
    required this.current,
    required this.onTap,
    required this.palette,
    required this.text,
    required this.pageLabel,
  });

  final ReaderTocEntry entry;
  final bool current;
  final VoidCallback? onTap;
  final LgPalette palette;
  final TextTheme text;
  final String pageLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = palette;
    final style = entry.level == 0 ? text.titleSmall! : text.bodyLarge!;
    return LgPressable(
      onTap: onTap,
      selected: current,
      color: current ? p.soft : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      semanticLabel: [
        entry.title,
        if (entry.page != null) l.readerPageLabel(entry.page!),
      ].join(', '),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: EdgeInsets.fromLTRB(10 + 18.0 * entry.level, 10, 12, 10),
          child: ExcludeSemantics(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: style.copyWith(color: current ? p.brand : null),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  pageLabel,
                  style: text.labelMedium!.copyWith(
                    color: current ? p.brand : p.sub,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarksSheet extends StatelessWidget {
  const _BookmarksSheet({
    required this.reading,
    required this.itemId,
    required this.fileSha,
    required this.page,
  });

  final ReadingController reading;
  final String itemId;
  final String fileSha;
  final int page;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListenableBuilder(
        listenable: reading,
        builder: (context, _) {
          final marks = reading.stateOf(itemId, fileSha)?.bookmarks ?? const [];
          final here = marks.any((b) => b.page == page);
          return ListView(
            controller: scroll,
            padding: EdgeInsets.fromLTRB(
              12,
              0,
              12,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              _SheetHeader(title: l.readerBookmarks),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: here
                    // Shu sahifa belgilangan — tugma nomini o'zgartiradi.
                    ? LgButton.secondary(
                        label: l.readerRenameBookmark,
                        icon: Icons.edit_outlined,
                        onPressed: () =>
                            Navigator.of(context)
                                .pop(const _AddBookmarkResult()),
                      )
                    : LgButton(
                        label: l.readerAddBookmark,
                        icon: Icons.bookmark_add_outlined,
                        onPressed: () =>
                            Navigator.of(context)
                                .pop(const _AddBookmarkResult()),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Text(
                  here
                      ? '${l.readerPageLabel(page)} · ${l.readerBookmarkedPage}'
                      : l.readerPageLabel(page),
                  textAlign: TextAlign.center,
                  style: text.bodySmall,
                ),
              ),
              if (marks.isEmpty)
                LgStateView(
                  kind: StateKind.empty,
                  title: l.readerBookmarksEmpty,
                  message: l.readerBookmarksEmptyBody,
                )
              else
                for (final b in marks)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: LgPressable(
                            onTap: () =>
                                Navigator.of(context).pop(_GoToResult(b.page)),
                            selected: b.page == page,
                            color: b.page == page ? p.soft : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            semanticLabel: [
                              if (b.name.isNotEmpty) b.name,
                              l.readerPageLabel(b.page),
                            ].join(', '),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 52),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: ExcludeSemantics(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bookmark_rounded,
                                        color: p.brand,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.name.isEmpty
                                                  ? l.readerPageLabel(b.page)
                                                  : b.name,
                                              style: text.titleSmall,
                                            ),
                                            if (b.name.isNotEmpty)
                                              Text(
                                                l.readerPageLabel(b.page),
                                                style: text.bodySmall,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _RoundIconButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: l.readerBookmarkRemove,
                          onTap: () => unawaited(
                            reading.removeBookmark(itemId, fileSha, b.page),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _BookmarkNameDialog extends StatefulWidget {
  const _BookmarkNameDialog({
    required this.page,
    required this.initial,
    required this.rename,
  });

  final int page;
  final String initial;

  /// Shu sahifada xatcho'p bor — nomi o'zgartiriladi.
  final bool rename;

  @override
  State<_BookmarkNameDialog> createState() => _BookmarkNameDialogState();
}

class _BookmarkNameDialogState extends State<_BookmarkNameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_name.text);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(widget.rename ? l.readerRenameBookmark : l.readerAddBookmark),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.readerPageLabel(widget.page), style: text.bodyMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: ReadingController.maxBookmarkName,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l.readerBookmarkName,
              hintText: l.readerBookmarkNameHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        TextButton(onPressed: _submit, child: Text(l.readerSave)),
      ],
    );
  }
}

class _GoToPageDialog extends StatefulWidget {
  const _GoToPageDialog({required this.total, required this.current});

  final int total;
  final int current;

  @override
  State<_GoToPageDialog> createState() => _GoToPageDialogState();
}

class _GoToPageDialogState extends State<_GoToPageDialog> {
  final _input = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit() {
    final page = parsePageInput(_input.text, widget.total);
    if (page == null) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(page);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.readerGoTo),
      content: TextField(
        controller: _input,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.go,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) {
          if (_invalid) setState(() => _invalid = false);
        },
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l.readerPageOf(widget.current, widget.total),
          hintText: l.readerGoToHint(widget.total),
          errorText: _invalid ? l.readerGoToError(widget.total) : null,
          errorMaxLines: 2,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        TextButton(onPressed: _submit, child: Text(l.readerGo)),
      ],
    );
  }
}
