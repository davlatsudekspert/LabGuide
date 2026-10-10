import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/storage/kv_store.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/analyte_screen.dart' show SourceTile;
import '../content/ui/content_widgets.dart';
import '../packs/pack_catalog.dart';
import '../packs/pack_downloader.dart';
import '../packs/packs_controller.dart';
import '../settings/settings_controller.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart';
import 'library_catalog.dart';
import 'library_filters.dart';
import 'library_widgets.dart';

/// Kutubxona bo'limlari. Rol faqat tartibni o'zgartiradi (eng foydalilari
/// “Siz uchun”da yuqorida) — barcha bo'limlar hamma uchun ochiq.
enum LibrarySection { books, saved, research, sources, packs, intake, review }

/// Rol bo'yicha: “Siz uchun” (yuqorida) va qolgan bo'limlar. Tekshiruv
/// navbati bu yerda yo'q — u faqat server vakolati bilan qo'shiladi.
(List<LibrarySection>, List<LibrarySection>) librarySectionsFor(AppRole role) {
  final top = switch (role) {
    AppRole.student => const [
      LibrarySection.books,
      LibrarySection.saved,
      LibrarySection.research,
    ],
    AppRole.teacher => const [
      LibrarySection.books,
      LibrarySection.intake,
      LibrarySection.sources,
    ],
    AppRole.doctor => const [
      LibrarySection.saved,
      LibrarySection.books,
      LibrarySection.sources,
    ],
    AppRole.lab => const [
      LibrarySection.books,
      LibrarySection.packs,
      LibrarySection.saved,
    ],
  };
  return (
    top,
    [
      for (final x in LibrarySection.values)
        if (!top.contains(x) && x != LibrarySection.review) x,
    ],
  );
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return ListenableBuilder(
      listenable: Listenable.merge([
        services.settings,
        services.access,
        services.content,
      ]),
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final (top, rest) = librarySectionsFor(services.settings.effectiveRole);
        // Tekshiruv navbati — faqat server tekshiruvchi yoki admin deb
        // tasdiqlagan foydalanuvchiga (“Ustoz” roli uni ochmaydi).
        final access = services.access.access;
        final first = [
          ...top,
          if (access.reviewer || access.adminAccount) LibrarySection.review,
        ];
        final uiLang = Localizations.localeOf(context).languageCode;
        // Faqat interfeys tilida mavjud materiallar sanaladi.
        final count = services.content.pack?.library
            .where((i) => libraryItemAvailableIn(i, uiLang))
            .length;
        return LgPage(
          title: l.libTitle,
          subtitle: l.libSubtitle,
          showBrand: true,
          children: [
            const _ContinueReadingCard(),
            _SearchEntry(
              label: l.libSearchEntry,
              onTap: () => context.push('/library/books?search=1'),
            ),
            LgSectionTitle(l.libForYou),
            for (final (i, s) in first.indexed)
              _SectionRow(
                section: s,
                count: count,
                last: i == first.length - 1,
              ),
            LgSectionTitle(l.libMoreSections),
            for (final (i, s) in rest.indexed)
              _SectionRow(section: s, count: count, last: i == rest.length - 1),
          ],
        );
      },
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.section,
    required this.count,
    required this.last,
  });

  final LibrarySection section;

  /// Katalogdagi materiallar soni (paket yuklangan bo'lsa).
  final int? count;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (
      String title,
      String sub,
      IconData icon,
      String path,
    ) = switch (section) {
      LibrarySection.books => (
        l.libBooks,
        count == null ? l.libBooksSub : l.libBooksCount(count!),
        Icons.menu_book_outlined,
        '/library/books',
      ),
      LibrarySection.saved => (
        l.featureSaved,
        l.libSavedSub,
        Icons.bookmark_outline,
        '/library/saved',
      ),
      LibrarySection.research => (
        l.researchTitle,
        l.libResearchSub,
        Icons.edit_note_rounded,
        '/library/research',
      ),
      LibrarySection.sources => (
        l.libSources,
        l.libSourcesSub,
        Icons.fact_check_outlined,
        '/library/sources',
      ),
      LibrarySection.packs => (
        l.libPacks,
        l.libPacksSub,
        Icons.download_for_offline_outlined,
        '/library/packs',
      ),
      LibrarySection.intake => (
        l.libIntake,
        l.libIntakeSub,
        Icons.move_to_inbox_outlined,
        '/library/intake',
      ),
      LibrarySection.review => (
        l.libReview,
        l.libReviewSub,
        Icons.rule_rounded,
        '/library/review',
      ),
    };
    return LgRow(
      title: title,
      subtitle: sub,
      icon: icon,
      onTap: () => context.push(path),
      divider: !last,
    );
  }
}

/// Qidiruv maydoniga o'xshash tugma: katalogni qidiruv fokusida ochadi.
class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: LgPressable(
        onTap: onTap,
        color: p.paper,
        semanticLabel: label,
        borderRadius: BorderRadius.circular(LgRadius.button),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.search_rounded, color: p.sub),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      style: text.bodyLarge!.copyWith(color: p.sub),
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

/// Oxirgi ochilgan ilova ichidagi kitob (bo'lsa): bir bosishda o'sha
/// sahifadan davom etiladi.
class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    return ListenableBuilder(
      listenable: Listenable.merge([services.reading, services.content]),
      builder: (context, _) {
        final pack = services.content.pack;
        // Eng oxirgi o'qilgan va hali ham ilovada ochiladigan fayl.
        final uiLang = Localizations.localeOf(context).languageCode;
        final match = pack == null
            ? null
            : services.reading.recent
                  .map((e) => (e, pack.libraryItem(e.key)))
                  .where(
                    (x) =>
                        x.$2 != null &&
                        libraryItemAvailableIn(x.$2!, uiLang) &&
                        canReadInApp(x.$2!) &&
                        x.$2!.file!.sha256 == x.$1.value.fileSha,
                  )
                  .firstOrNull;
        if (match == null) return const SizedBox.shrink();
        final (last, item!) = match;
        return LgPanel(
          soft: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: LgRow(
            title: l.libContinueReading,
            subtitle:
                '${libraryShortTitle(item, max: 70)} · '
                '${l.readerPageLabel(last.value.lastPage)}',
            icon: Icons.auto_stories_outlined,
            divider: false,
            onTap: () => context.push('/library/books/item/${item.id}/read'),
          ),
        );
      },
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bookmarks = context.services.bookmarks;
    return LgPage(
      title: l.featureSaved,
      children: [
        ContentGate(
          builder: (context, pack) => ListenableBuilder(
            listenable: bookmarks,
            builder: (context, _) {
              final saved = [
                for (final id in bookmarks.ids.reversed) ?pack.analyte(id),
              ];
              if (saved.isEmpty) {
                return LgStateView(
                  kind: StateKind.empty,
                  title: l.savedEmptyTitle,
                  message: l.savedEmptyBody,
                  actionLabel: l.featureTests,
                  // Tahlillar ro'yxati (tab ildizi). openInTab Tahlillar
                  // tabida oxirgi ochiq kartani (masalan, Kaliy) ko'rsatardi.
                  onAction: () => context.go('/tests'),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < saved.length; i++)
                    AnalyteRow(
                      analyte: saved[i],
                      divider: i < saved.length - 1,
                      onTap: () =>
                          context.push('/library/saved/analyte/${saved[i].id}'),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}

/// Oflayn paketlar: avval ilova ichidagi asosiy paket (haqiqiy versiya,
/// hajm, tillar), keyin katalogdan yuklanadiganlar, oxirida ixcham
/// “Rejalashtirilgan” bo'limi.
class PacksScreen extends StatefulWidget {
  const PacksScreen({super.key});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(context.services.packs.open());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final packs = context.services.packs;
    return LgPage(
      title: l.libPacks,
      children: [
        LgSectionTitle(l.packsBuiltIn),
        ContentGate(builder: (context, pack) => const _CorePackCard()),
        LgSectionTitle(l.packsDownloadable),
        ListenableBuilder(
          listenable: packs,
          builder: (context, _) {
            final catalog = packs.catalog;
            final loading = packs.catalogState == CatalogState.loading;
            final failure = packs.catalogState == CatalogState.failed
                ? packs.catalogError
                : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (catalog == null && loading)
                  LgStateView(
                    kind: StateKind.loading,
                    title: l.packsCatalogLoading,
                  )
                else if (catalog == null && failure != null)
                  LgStateView(
                    kind: failure == PackDownloadFailure.network
                        ? StateKind.offline
                        : StateKind.error,
                    title: packFailureText(failure, l),
                    actionLabel: l.actionRetry,
                    onAction: packs.refresh,
                  )
                else if (catalog != null) ...[
                  if (failure != null || packs.catalogFromCache)
                    LgNotice(
                      failure == null
                          ? l.packsCatalogCached
                          : '${packFailureText(failure, l)} '
                                '${l.packsCatalogCached}',
                      kind: NoticeKind.info,
                    ),
                  if (catalog.entries.isEmpty)
                    Text(l.packsCatalogEmpty, style: text.bodyMedium)
                  else
                    for (final e in catalog.entries) _CatalogPackCard(entry: e),
                ],
              ],
            );
          },
        ),
        LgSectionTitle(l.packsPlanned),
        LgPanel(
          soft: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final title in [
                l.packsBiochem,
                l.packsSpecimensQc,
                l.packsMicroscopy,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title, style: text.titleSmall)),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(l.packsPlannedBody, style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

String packFailureText(PackDownloadFailure f, AppLocalizations l) =>
    switch (f) {
      PackDownloadFailure.network => l.packsFailNetwork,
      PackDownloadFailure.server => l.packsFailServer,
      PackDownloadFailure.integrity => l.packsFailIntegrity,
      PackDownloadFailure.incompatible => l.packsFailIncompatible,
      PackDownloadFailure.storage => l.packsFailStorage,
      // Bekor qilish xato sifatida ko'rsatilmaydi.
      PackDownloadFailure.cancelled => '',
    };

String _languagesLabel(List<String> codes) =>
    codes.map((e) => e.toUpperCase()).join(' · ');

class _CorePackCard extends StatelessWidget {
  const _CorePackCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final content = context.services.content;
    final m = content.manifest!;
    final pack = content.pack!;
    Widget check(IconData icon, String label, {Color? color}) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? p.brand),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: text.bodyMedium)),
        ],
      ),
    );
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.packsCoreTitle, style: text.titleMedium)),
              LgTag(l.packsInstalled, icon: Icons.check_rounded),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.packsMeta(
              m.version,
              formatBytes(m.totalSize),
              _languagesLabel(m.languages),
            ),
            style: text.bodySmall,
          ),
          check(Icons.wifi_off_rounded, l.packsOffline),
          check(Icons.verified_rounded, l.packsVerified),
          check(Icons.rule_rounded, l.packsCoreState, color: p.amber),
          const SizedBox(height: 8),
          Text(
            l.packsContents(
              pack.analytes.length,
              pack.quiz.length,
              pack.sources.length,
            ),
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CatalogPackCard extends StatelessWidget {
  const _CatalogPackCard({required this.entry});

  final PackCatalogEntry entry;

  Future<void> _confirmRemove(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final packs = context.services.packs;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.packsRemoveTitle),
        content: Text(l.packsRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.packsRemove),
          ),
        ],
      ),
    );
    if (ok == true) await packs.remove(entry.packId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final packs = context.services.packs;
    final installed = packs.installed(entry.packId);
    final job = packs.job(entry.packId);
    final (String status, LgTone tone) = switch (entry.status) {
      PackStatus.test => (l.packsStatusTest, LgTone.warning),
      PackStatus.draft => (l.packsStatusDraft, LgTone.warning),
      PackStatus.reviewed => (l.packsStatusReviewed, LgTone.brand),
    };
    final Widget action;
    if (job != null && job.isRunning) {
      final percent = ((job.fraction ?? 0) * 100).floor();
      action = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: l.packsDownloading(percent),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.fraction,
                minHeight: 6,
                color: p.brand,
                backgroundColor: p.soft,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(
            child: Text(l.packsDownloading(percent), style: text.bodySmall),
          ),
          const SizedBox(height: 8),
          LgButton.secondary(
            label: l.actionCancel,
            icon: Icons.close_rounded,
            onPressed: () => packs.cancel(entry.packId),
          ),
        ],
      );
    } else {
      final failure = job?.failure;
      action = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failure != null)
            LgNotice(packFailureText(failure, l), kind: NoticeKind.error),
          if (installed == null)
            LgButton(
              label: failure != null
                  ? l.actionRetry
                  : l.packsDownload(formatBytes(entry.size)),
              icon: failure != null
                  ? Icons.refresh_rounded
                  : Icons.download_rounded,
              onPressed: () => packs.install(entry),
            )
          else ...[
            if (packs.updateAvailable(entry))
              LgButton(
                label: failure != null
                    ? l.actionRetry
                    : l.packsUpdate(entry.version),
                icon: Icons.system_update_alt_rounded,
                onPressed: () => packs.install(entry),
              ),
            if (packs.updateAvailable(entry)) const SizedBox(height: 8),
            LgButton.secondary(
              label: l.packsRemove,
              icon: Icons.delete_outline_rounded,
              onPressed: () => _confirmRemove(context),
            ),
          ],
        ],
      );
    }
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.title.of(lang), style: text.titleMedium),
          const SizedBox(height: 6),
          LgTag(status, tone: tone, icon: Icons.science_outlined),
          const SizedBox(height: 8),
          Text(entry.summary.of(lang), style: text.bodyMedium),
          const SizedBox(height: 6),
          Text(
            l.packsMeta(
              entry.version,
              formatBytes(entry.size),
              _languagesLabel(entry.languages),
            ),
            style: text.bodySmall,
          ),
          if (installed != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 18, color: p.brand),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.packsInstalledVersion(
                      installed.version,
                      formatBytes(installed.size),
                    ),
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          action,
        ],
      ),
    );
  }
}

String categoryLabel(LibraryCategory c, AppLocalizations l) => switch (c) {
  LibraryCategory.biochemistry => l.catBiochemistry,
  LibraryCategory.clinicalLab => l.catClinicalLab,
  LibraryCategory.instruments => l.catInstruments,
  LibraryCategory.methods => l.catMethods,
  LibraryCategory.tests => l.catTests,
};

String kindLabel(LibraryItemKind k, AppLocalizations l) => switch (k) {
  LibraryItemKind.book => l.kindBook,
  LibraryItemKind.manual => l.kindManual,
  LibraryItemKind.method => l.kindMethod,
  LibraryItemKind.ifu => l.kindIfu,
  LibraryItemKind.article => l.kindArticle,
  LibraryItemKind.questionSet => l.kindQuestionSet,
  LibraryItemKind.website => l.kindWebsite,
};

/// Kitoblar, qo'llanmalar, metodikalar katalogi: qidiruv va til / mavzu /
/// tur filtrlari. Yangi adabiyot kontent paketiga `library` yozuvi sifatida
/// qo'shiladi — ilova kodi o'zgarmaydi.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key, this.focusSearch = false});

  /// Kutubxona bosh sahifasidagi qidiruvdan kelinganda — klaviatura ochiq.
  final bool focusSearch;

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  final _searchKey = GlobalKey();
  LibraryFilter _filter = LibraryFilter.none;
  LibraryCatalog? _catalog;

  @override
  void initState() {
    super.initState();
    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _set(LibraryFilter f) => setState(() => _filter = f);

  void _clearAll() {
    _query.clear();
    _set(LibraryFilter.none);
    // Ro'yxat boshiga — qidiruv va filtrlar yana ko'rinsin.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _searchKey.currentContext;
      if (target != null && target.mounted) {
        unawaited(
          Scrollable.ensureVisible(
            target,
            duration: LgMotion.of(context, LgMotion.page),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return LgPage(
      title: l.libBooks,
      children: [
        LibrarySearchField(
          key: _searchKey,
          controller: _query,
          focusNode: _focus,
          label: l.libSearchLabel,
          hint: l.libSearchHint,
          onChanged: (v) => _set(_filter.copyWith(query: v)),
        ),
        ContentGate(
          builder: (context, pack) {
            if (pack.library.isEmpty) {
              return LgStateView(
                kind: StateKind.empty,
                title: l.booksEmptyTitle,
                message: l.booksEmptyBody,
              );
            }
            final catalog = _catalog?.pack == pack && _catalog?.lang == lang
                ? _catalog!
                : _catalog = LibraryCatalog(pack, lang: lang);
            final results = catalog.apply(_filter, lang: lang);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LibraryFilterBar(
                  catalog: catalog,
                  filter: _filter,
                  // Varaq tanlovi + maydondagi joriy so'z (varaq ochiq paytda
                  // o'zgargan bo'lsa ham eskisi qaytmaydi).
                  onChanged: (f) => _set(f.copyWith(query: _query.text)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            l.libResultCount(
                              results.length,
                              catalog.items.length,
                            ),
                            style: text.bodySmall,
                          ),
                        ),
                      ),
                      if (_filter.isActive)
                        LgButton.link(
                          label: l.libClearFilters,
                          icon: Icons.close_rounded,
                          expand: false,
                          onPressed: _clearAll,
                        ),
                    ],
                  ),
                ),
                if (results.isEmpty)
                  LgStateView(
                    kind: StateKind.empty,
                    title: _filter.hasSelections
                        ? l.libFilteredEmptyTitle
                        : l.testsEmptyTitle,
                    message: _filter.hasSelections
                        ? l.libFilteredEmptyBody
                        : l.libQueryEmptyBody,
                    actionLabel: _filter.hasSelections
                        ? l.booksResetFilters
                        : l.testsClearSearch,
                    onAction: _clearAll,
                  )
                else
                  for (final item in results) LibraryItemCard(item: item),
                const SizedBox(height: 8),
                LgNotice(l.booksCatalogNote, kind: NoticeKind.info),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Katalog qatori: nomi, qisqa ma'lumot va “qanday ochiladi” belgisi.
/// Bosilganda material sahifasi ochiladi.
class LibraryItemCard extends StatelessWidget {
  const LibraryItemCard({super.key, required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final authors = item.authors.length > 2
        ? '${item.authors.take(2).join(', ')} …'
        : item.authors.join(', ');
    final meta = [
      kindLabel(item.kind, l),
      if (authors.isNotEmpty) authors,
      if (item.year != null) '${item.year}',
      item.language.toUpperCase(),
    ].join(' · ');
    final title = libraryShortTitle(item, max: 140);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: LgPressable(
        onTap: () => context.push('/library/books/item/${item.id}'),
        color: p.paper,
        borderRadius: BorderRadius.circular(LgRadius.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(meta, style: text.bodySmall),
                    const SizedBox(height: 12),
                    OpenKindLine(item: item),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ExcludeSemantics(
                child: Icon(Icons.chevron_right_rounded, color: p.sub),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Domla/tekshiruvchi uchun: manbalar orasidagi ochiq farqlar va
/// tasdiqlanmagan (draft) kontent soni.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.sourcesTitle,
      children: [
        Text(l.sourcesBody, style: text.bodyMedium),
        const SizedBox(height: 8),
        ContentGate(
          builder: (context, pack) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgSectionTitle('${l.sourcesContent} (${pack.sources.length})'),
              LgPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < pack.sources.length; i++)
                      SourceTile(index: i + 1, source: pack.sources[i]),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Kod bilan birga versiyalanadigan formulalar va usullar manbalari.
        LgSectionTitle('${l.sourcesMethods} (${CalcSources.methods.length})'),
        LgPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, src) in CalcSources.methods.indexed)
                CalcSourceTile(index: i + 1, ref: CalcRef(src, '')),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ilmiy ish / dars rejasi maydoni. Qoralama faqat shu qurilmada
/// saqlanadi; ilova natija yoki iqtibos yaratmaydi.
class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key, this.lessonPlan = false});

  final bool lessonPlan;

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  late final KeyValueStore _store = context.services.store;
  late final String _questionKey = widget.lessonPlan
      ? StoreKeys.lessonQuestion
      : StoreKeys.researchQuestion;
  late final String _notesKey = widget.lessonPlan
      ? StoreKeys.lessonNotes
      : StoreKeys.researchNotes;
  late final _question = TextEditingController(
    text: _store.getString(_questionKey) ?? '',
  );
  late final _notes = TextEditingController(
    text: _store.getString(_notesKey) ?? '',
  );
  bool _showOutline = false;
  Timer? _autosave;

  /// Yozish to'xtagach qisqa kutib saqlaydi — “Saqlash” bosilmasa ham
  /// qoralama yo'qolmaydi.
  void _scheduleAutosave(String _) {
    _autosave?.cancel();
    _autosave = Timer(const Duration(milliseconds: 600), _persist);
  }

  Future<void> _persist() async {
    await _store.setString(_questionKey, _question.text);
    await _store.setString(_notesKey, _notes.text);
  }

  @override
  void dispose() {
    // Sahifadan chiqishda ham saqlanadi.
    if (_autosave?.isActive ?? false) {
      _autosave!.cancel();
      unawaited(_persist());
    }
    _question.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    _autosave?.cancel();
    await _persist();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.researchSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: widget.lessonPlan ? l.learnLessonPlan : l.researchTitle,
      children: [
        LgField(
          label: l.researchQuestion,
          controller: _question,
          hint: l.researchQuestionHint,
          textInputAction: TextInputAction.next,
          onChanged: _scheduleAutosave,
        ),
        LgField(
          label: l.researchNotes,
          controller: _notes,
          hint: l.researchNotesHint,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          onChanged: _scheduleAutosave,
        ),
        const SizedBox(height: 8),
        Text(l.researchAutosave, style: text.bodySmall),
        const SizedBox(height: 12),
        LgButton(label: l.researchSave, onPressed: _save),
        const SizedBox(height: 10),
        LgButton.secondary(
          label: l.researchOutline,
          icon: _showOutline
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded,
          onPressed: () => setState(() => _showOutline = !_showOutline),
        ),
        if (_showOutline)
          LgPanel(
            child: LgSteps([
              l.researchStep1,
              l.researchStep2,
              l.researchStep3,
              l.researchStep4,
            ]),
          ),
        const SizedBox(height: 8),
        Text(l.researchNoFabrication, style: text.bodySmall),
      ],
    );
  }
}
