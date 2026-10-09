import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/analyte_screen.dart' show rightsLabel;
import '../content/ui/content_widgets.dart';
import 'library_catalog.dart';
import 'library_widgets.dart';

/// Material sahifasi: nima ekanligi, qanday ochilishi (havola / ilova
/// ichida / yuklab olinadigan / kutilmoqda) va bibliografik ma'lumot.
class LibraryItemScreen extends StatelessWidget {
  const LibraryItemScreen({super.key, required this.itemId});

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
            title: l.libBooks,
            children: [
              ContentGate(
                builder: (context, _) => LgStateView(
                  kind: StateKind.empty,
                  title: l.libItemNotFound,
                  message: l.libItemNotFoundBody,
                  actionLabel: l.libBackToCatalog,
                  onAction: () => context.go('/library/books'),
                ),
              ),
            ],
          );
        }
        return _ItemPage(item: item, pack: pack);
      },
    );
  }
}

class _ItemPage extends StatelessWidget {
  const _ItemPage({required this.item, required this.pack});

  final LibraryItem item;
  final ContentPack pack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final shortTitle = libraryShortTitle(item);
    final older = item.supersedes == null
        ? null
        : pack.libraryItem(item.supersedes!);
    final groups = LibraryCatalog(pack).groupsOf(item);
    final provided =
        item.providedBy != null || item.file != null || item.filePack != null;
    final authorsLine = [
      if (item.authors.isNotEmpty)
        item.authors.length > 3
            ? '${item.authors.take(3).join(', ')} …'
            : item.authors.join(', '),
      if (item.year != null) '${item.year}',
    ].join(' · ');
    return LgPage(
      title: shortTitle,
      eyebrow:
          '${libraryKindLabel(item.kind, l)} · ${item.language.toUpperCase()}',
      subtitle: authorsLine.isEmpty ? null : authorsLine,
      children: [
        if (shortTitle != item.title)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(item.title, style: text.bodyMedium),
          ),
        _OpenPanel(item: item),
        if (item.note != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(item.note!.of(lang), style: text.bodyLarge),
          ),
        if (older != null)
          LgNotice(
            l.libItemSupersedes(libraryShortTitle(older)),
            kind: NoticeKind.info,
          ),
        LgSectionTitle(l.libDetailsTitle),
        LgPanel(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
          child: Column(
            children: [
              if (item.authors.isNotEmpty)
                LgMetric(
                  label: l.libFieldAuthors,
                  value: item.authors.join(', '),
                ),
              if (item.year != null)
                LgMetric(label: l.libFieldYear, value: '${item.year}'),
              if (item.edition != null)
                LgMetric(label: l.libFieldEdition, value: item.edition!),
              if (item.publisher != null)
                LgMetric(label: l.libFieldPublisher, value: item.publisher!),
              if (item.isbn != null) LgMetric(label: 'ISBN', value: item.isbn!),
              LgMetric(
                label: l.libFilterLanguage,
                value: libraryLanguageName(item.language),
              ),
              LgMetric(
                label: l.libFilterSectionField,
                value: [
                  for (final c in item.categories) libraryCategoryLabel(c, l),
                ].join(', '),
              ),
              if (groups.isNotEmpty)
                LgMetric(
                  label: l.libFieldTopics,
                  value: [
                    for (final g in pack.groups)
                      if (groups.contains(g.id)) g.names.of(lang),
                  ].join(', '),
                ),
              if (item.file?.pages case final pages?)
                LgMetric(label: l.libFieldPages, value: '$pages'),
              if (!provided)
                LgMetric(
                  label: l.libFieldAccess,
                  value: switch (item.access) {
                    LibraryAccess.openLicence => l.libAccessOpen(
                      item.licence ?? '',
                    ),
                    LibraryAccess.freeToRead => l.libAccessFree,
                    LibraryAccess.catalogOnly => l.libAccessCatalog,
                  },
                )
              else ...[
                if (item.providedBy == 'teacher')
                  LgMetric(
                    label: l.libFieldProvidedBy,
                    value: l.libProvidedByTeacher,
                  ),
                LgMetric(
                  label: l.libFieldRights,
                  value: [
                    rightsLabel(item.rights.distribution, l),
                    if (item.rights.recordedAt != null)
                      l.libFieldRightsRecorded(
                        item.rights.recordedAt!,
                        item.rights.recordedBy ?? '—',
                      ),
                  ].join('\n'),
                ),
              ],
              LgMetric(
                label: l.libFieldStatus,
                value: importStateLabel(item.importState, l),
              ),
            ],
          ),
        ),
        if (item.accessed != null && !provided)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l.libChecked(item.accessed!), style: text.bodySmall),
          ),
      ],
    );
  }
}

/// Asosiy amal: turi va “bosganda nima bo'ladi” izohi bilan. Ochib
/// bo'lmaydigan material uchun tugma o'chiq va sababi yozilgan.
class _OpenPanel extends StatelessWidget {
  const _OpenPanel({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final kind = openKindOf(item);
    final url = item.url;
    final reading = context.services.reading;
    final Widget action = switch (kind) {
      LibraryOpenKind.inApp => ListenableBuilder(
        listenable: reading,
        builder: (context, _) {
          final state = reading.stateOf(item.id, item.file!.sha256);
          final resume = state != null && state.lastPage > 1;
          return LgButton(
            label: resume ? l.libItemContinue(state.lastPage) : l.libItemRead,
            icon: Icons.auto_stories_outlined,
            onPressed: () =>
                context.push('/library/books/item/${item.id}/read'),
          );
        },
      ),
      LibraryOpenKind.link => LgButton(
        label: l.libOpenSource,
        icon: Icons.open_in_new_rounded,
        onPressed: () => openExternalLink(context, url!),
      ),
      LibraryOpenKind.download => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Yuklash serveri (C bosqich) ulanmaguncha — o'chiq va sababi bilan.
          LgButton(
            label: l.libItemPack(formatFileSize(item.filePack!.size)),
            icon: Icons.download_rounded,
            onPressed: null,
          ),
          LgNotice(l.libDownloadUnavailable),
        ],
      ),
      LibraryOpenKind.pending || LibraryOpenKind.record => LgButton.secondary(
        label: l.libItemCannotOpen,
        icon: Icons.block_rounded,
        onPressed: null,
      ),
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: BorderRadius.circular(LgRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OpenKindLine(item: item, large: true),
          // Havola: sahifadagi kirish sharti (ochiq litsenziya / bepul /
          // pullik yoki cheklangan) — bosishdan oldin ko'rinsin.
          if (kind == LibraryOpenKind.link && item.providedBy == null)
            Padding(
              padding: const EdgeInsets.only(left: 55, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LgTag(
                  switch (item.access) {
                    LibraryAccess.openLicence => l.libAccessOpen(
                      item.licence ?? '',
                    ),
                    LibraryAccess.freeToRead => l.libAccessFree,
                    LibraryAccess.catalogOnly => l.libAccessCatalog,
                  },
                  tone: switch (item.access) {
                    LibraryAccess.openLicence => LgTone.brand,
                    LibraryAccess.freeToRead => LgTone.neutral,
                    LibraryAccess.catalogOnly => LgTone.warning,
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          action,
          // Fayl yoki paket bo'lsa ham rasmiy sahifa alohida havola.
          if (url != null &&
              (kind == LibraryOpenKind.inApp ||
                  kind == LibraryOpenKind.download)) ...[
            const SizedBox(height: 8),
            LgButton.secondary(
              label: l.libOpenSource,
              icon: Icons.open_in_new_rounded,
              onPressed: () => openExternalLink(context, url),
            ),
          ],
        ],
      ),
    );
  }
}
