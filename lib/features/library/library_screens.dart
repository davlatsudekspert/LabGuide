import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../core/storage/kv_store.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/analyte_screen.dart' show SourceTile, rightsLabel;
import '../content/ui/content_widgets.dart';
import '../packs/pack_catalog.dart';
import '../packs/pack_downloader.dart';
import '../packs/packs_controller.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.libTitle,
      subtitle: l.libSubtitle,
      showBrand: true,
      children: [
        LgRow(
          title: l.libBooks,
          subtitle: l.libBooksSub,
          icon: Icons.menu_book_outlined,
          onTap: () => context.push('/library/books'),
        ),
        LgRow(
          title: l.libPacks,
          subtitle: l.libPacksSub,
          icon: Icons.download_for_offline_outlined,
          onTap: () => context.push('/library/packs'),
        ),
        LgRow(
          title: l.featureSaved,
          subtitle: l.libSavedSub,
          icon: Icons.bookmark_outline,
          onTap: () => context.push('/library/saved'),
        ),
        LgRow(
          title: l.featureResearch,
          subtitle: l.libResearchSub,
          icon: Icons.edit_note_rounded,
          onTap: () => context.push('/library/research'),
        ),
        LgRow(
          title: l.libSources,
          subtitle: l.libSourcesSub,
          icon: Icons.fact_check_outlined,
          onTap: () => context.push('/library/sources'),
        ),
        LgRow(
          title: l.libReview,
          subtitle: l.libReviewSub,
          icon: Icons.rule_rounded,
          onTap: () => context.push('/library/review'),
          divider: false,
        ),
      ],
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
                  onAction: () => openInTab(context, '/tests'),
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

/// Kitoblar, qo'llanmalar, metodikalar katalogi. Yangi adabiyot kontent
/// paketiga `library` yozuvi sifatida qo'shiladi — ilova kodi o'zgarmaydi.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

/// Katalog tillari — o'z nomi bilan (til tanlagichdagi kabi).
const _catalogLanguages = [
  ('uz', 'O‘zbekcha'),
  ('ru', 'Русский'),
  ('en', 'English'),
];

class _BooksScreenState extends State<BooksScreen> {
  LibraryCategory? _category;
  String? _language;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.libBooks,
      children: [
        ContentGate(
          builder: (context, pack) {
            if (pack.library.isEmpty) {
              return LgStateView(
                kind: StateKind.empty,
                title: l.booksEmptyTitle,
                message: l.booksEmptyBody,
              );
            }
            final items = pack.library
                .where(
                  (i) =>
                      (_category == null || i.categories.contains(_category)) &&
                      (_language == null || i.language == _language),
                )
                .toList();
            // Interfeys tilidagi materiallar birinchi (tartib saqlanadi).
            final lang = Localizations.localeOf(context).languageCode;
            final ordered = [
              ...items.where((i) => i.language == lang),
              ...items.where((i) => i.language != lang),
            ];
            final languages = {for (final i in pack.library) i.language};
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      LgChoiceChip(
                        label: l.testsFilterAll,
                        selected: _category == null,
                        onTap: () => setState(() => _category = null),
                      ),
                      for (final c in LibraryCategory.values) ...[
                        const SizedBox(width: 6),
                        LgChoiceChip(
                          label: categoryLabel(c, l),
                          selected: _category == c,
                          onTap: () => setState(
                            () => _category = _category == c ? null : c,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (languages.length > 1) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (code, name) in _catalogLanguages)
                        if (languages.contains(code))
                          LgChoiceChip(
                            label: name,
                            selected: _language == code,
                            onTap: () => setState(
                              () => _language = _language == code ? null : code,
                            ),
                          ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                if (items.isEmpty)
                  LgStateView(
                    kind: StateKind.empty,
                    title: l.testsEmptyTitle,
                    actionLabel: l.booksResetFilters,
                    onAction: () => setState(() {
                      _category = null;
                      _language = null;
                    }),
                  )
                else
                  for (final item in ordered) LibraryItemCard(item: item),
                LgNotice(l.booksCatalogNote, kind: NoticeKind.info),
              ],
            );
          },
        ),
      ],
    );
  }
}

class LibraryItemCard extends StatelessWidget {
  const LibraryItemCard({super.key, required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final pack = context.services.content.pack;
    final older = item.supersedes == null
        ? null
        : pack?.libraryItem(item.supersedes!);
    final meta = [
      kindLabel(item.kind, l),
      if (item.authors.isNotEmpty) item.authors.join(', '),
      if (item.year != null) '${item.year}',
      if (item.edition != null) item.edition!,
      item.language.toUpperCase(),
    ].join(' · ');
    final shared = item.filePack != null && item.rights.allowsSharedPack;
    final lang = Localizations.localeOf(context).languageCode;
    // Domla/foydalanuvchi bergan material — tarqatish huquqi va paket holati
    // muhim; ochiq katalog yozuvida esa kirish turi va litsenziya.
    final provided = item.providedBy != null || item.filePack != null;
    final url = item.url;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: text.titleMedium),
          const SizedBox(height: 4),
          Text(meta, style: text.bodySmall),
          if (item.publisher != null)
            Text(item.publisher!, style: text.bodySmall),
          if (item.note != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(item.note!.of(lang), style: text.bodyMedium),
            ),
          if (older != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l.libItemSupersedes(older.title),
                style: text.bodySmall,
              ),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in item.categories)
                LgTag(categoryLabel(c, l), tone: LgTone.neutral),
              if (provided)
                LgTag(
                  rightsLabel(item.rights.distribution, l),
                  tone: item.rights.allowsSharedPack
                      ? LgTone.brand
                      : LgTone.warning,
                )
              else
                LgTag(
                  switch (item.access) {
                    LibraryAccess.openLicence => l.libAccessOpen(
                      item.licence ?? '',
                    ),
                    LibraryAccess.freeToRead => l.libAccessFree,
                    LibraryAccess.catalogOnly => l.libAccessCatalog,
                  },
                  tone: item.access == LibraryAccess.openLicence
                      ? LgTone.brand
                      : LgTone.neutral,
                ),
            ],
          ),
          if (item.accessed != null && !provided)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.libChecked(item.accessed!), style: text.bodySmall),
            ),
          const SizedBox(height: 12),
          if (url != null)
            LgButton.secondary(
              label: l.libOpenSource,
              icon: Icons.open_in_new_rounded,
              onPressed: () => openExternalLink(context, url),
            ),
          if (provided) ...[
            if (url != null) const SizedBox(height: 8),
            // Paket yuklash infratuzilmasi (C bosqich) ulanmaguncha tugma
            // o'chirilgan — muvaffaqiyat ko'rsatilmaydi.
            LgButton.secondary(
              label: shared
                  ? '${l.libItemPack(formatBytes(item.filePack!.size))} · '
                        '${l.notAvailableYet}'
                  : l.libItemNoPack,
              icon: Icons.download_rounded,
              onPressed: null,
            ),
          ],
        ],
      ),
    );
  }
}

/// Domla/tekshiruvchi uchun: manbalar orasidagi ochiq farqlar va
/// tasdiqlanmagan (draft) kontent soni.
class ReviewQueueScreen extends StatelessWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.libReview,
      children: [
        ContentGate(
          builder: (context, pack) {
            final draftQuestions = pack.quiz.where((q) => q.isDraft).length;
            final draftCards = pack.analytes
                .where((a) => !a.isReviewerApproved)
                .length;
            final open = pack.openDiscrepancies;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LgPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.reviewDraftCards(draftCards),
                        style: text.bodyLarge,
                      ),
                      Text(
                        l.reviewDraftQuestions(draftQuestions),
                        style: text.bodyLarge,
                      ),
                      Text(
                        l.reviewCatalog(pack.library.length),
                        style: text.bodyLarge,
                      ),
                    ],
                  ),
                ),
                LgSectionTitle(l.reviewDiscrepancies),
                Text(l.reviewDiscrepanciesBody, style: text.bodyMedium),
                const SizedBox(height: 8),
                if (open.isEmpty)
                  LgStateView(
                    kind: StateKind.empty,
                    title: l.reviewNoDiscrepancies,
                  )
                else
                  for (final d in open) _DiscrepancyCard(pack: pack, d: d),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DiscrepancyCard extends StatelessWidget {
  const _DiscrepancyCard({required this.pack, required this.d});

  final ContentPack pack;
  final Discrepancy d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final subject =
        pack.analyte(d.subjectId)?.names.of(lang) ??
        pack.lessons
            .where((x) => x.id == d.subjectId)
            .firstOrNull
            ?.title
            .of(lang) ??
        d.subjectId;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject, style: text.titleMedium),
          Text(l.reviewField(d.field), style: text.bodySmall),
          for (final pos in d.positions) ...[
            const SizedBox(height: 10),
            Text(
              [
                pack.source(pos.ref.sourceId)?.title ?? pos.ref.sourceId,
                if (pos.ref.pages != null) l.citePage(pos.ref.pages!),
              ].join(' · '),
              style: text.titleSmall,
            ),
            Text(pos.statement, style: text.bodyMedium),
          ],
        ],
      ),
    );
  }
}

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
