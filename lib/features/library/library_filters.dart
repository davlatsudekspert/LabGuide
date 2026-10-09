import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'library_catalog.dart';
import 'library_widgets.dart';

enum _Dimension { language, topic, type }

/// Til / Mavzu / Turi tugmalari. Tanlangan qiymat tugmaning o'zida
/// ko'rinadi; bosilganda pastdan variantlar (natija soni bilan) chiqadi.
class LibraryFilterBar extends StatelessWidget {
  const LibraryFilterBar({
    super.key,
    required this.catalog,
    required this.filter,
    required this.onChanged,
  });

  final LibraryCatalog catalog;
  final LibraryFilter filter;
  final ValueChanged<LibraryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    String? join(List<String?> parts) {
      final v = parts.nonNulls.join(' · ');
      return v.isEmpty ? null : v;
    }

    final topic = join([
      if (filter.category case final c?) libraryCategoryLabel(c, l),
      if (filter.group case final g?) catalog.pack.group(g)?.names.of(lang),
    ]);
    final type = join([
      if (filter.kind case final k?) libraryKindLabel(k, l),
      if (filter.open case final o?) openKindShort(o, l),
    ]);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterButton(
          label: l.libFilterLanguage,
          value: filter.language == null
              ? null
              : libraryLanguageName(filter.language!),
          icon: Icons.translate_rounded,
          onTap: () => _open(context, _Dimension.language),
        ),
        _FilterButton(
          label: l.libFilterTopic,
          value: topic,
          icon: Icons.category_outlined,
          onTap: () => _open(context, _Dimension.topic),
        ),
        _FilterButton(
          label: l.libFilterType,
          value: type,
          icon: Icons.layers_outlined,
          onTap: () => _open(context, _Dimension.type),
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context, _Dimension dim) async {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    _Option option(String label, LibraryFilter value, bool selected) =>
        _Option(label, value, catalog.count(value), selected);
    _Option all(LibraryFilter value, bool selected) =>
        option(l.testsFilterAll, value, selected);

    final (String title, List<_Section> sections) = switch (dim) {
      _Dimension.language => (
        l.libFilterLanguage,
        [
          _Section(null, [
            all(filter.copyWith(language: null), filter.language == null),
            for (final code in catalog.languages)
              option(
                libraryLanguageName(code),
                filter.copyWith(language: code),
                filter.language == code,
              ),
          ]),
        ],
      ),
      _Dimension.topic => (
        l.libFilterTopic,
        [
          _Section(l.libFilterSectionField, [
            all(filter.copyWith(category: null), filter.category == null),
            for (final c in catalog.categories)
              option(
                libraryCategoryLabel(c, l),
                filter.copyWith(category: c),
                filter.category == c,
              ),
          ]),
          _Section(l.libFilterSectionGroup, [
            all(filter.copyWith(group: null), filter.group == null),
            for (final g in catalog.groups)
              option(
                g.names.of(lang),
                filter.copyWith(group: g.id),
                filter.group == g.id,
              ),
          ]),
        ],
      ),
      _Dimension.type => (
        l.libFilterType,
        [
          _Section(l.libFilterSectionKind, [
            all(filter.copyWith(kind: null), filter.kind == null),
            for (final k in catalog.kinds)
              option(
                libraryKindLabel(k, l),
                filter.copyWith(kind: k),
                filter.kind == k,
              ),
          ]),
          _Section(l.libFilterSectionOpen, [
            all(filter.copyWith(open: null), filter.open == null),
            for (final o in catalog.openKinds)
              option(
                openKindShort(o, l),
                filter.copyWith(open: o),
                filter.open == o,
              ),
          ]),
        ],
      ),
    };
    final p = LgPalette.of(context);
    final picked = await showModalBottomSheet<LibraryFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: p.paper,
      useRootNavigator: true,
      builder: (context) => _FilterSheet(title: title, sections: sections),
    );
    if (picked != null) onChanged(picked);
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;

  /// Tanlangan qiymat (yo'q bo'lsa — filtr qo'llanmagan).
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final active = value != null;
    final fg = active ? p.onBrand : p.ink;
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(
      fontSize: 13,
      color: fg,
      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
    );
    final text = active ? '$label: $value' : label;
    return LgPressable(
      onTap: onTap,
      selected: active,
      semanticLabel: text,
      color: active ? p.brand : p.paper,
      borderRadius: BorderRadius.circular(LgRadius.chip),
      border: active ? null : Border.all(color: p.outline),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTap),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(active ? Icons.check_rounded : icon, size: 17, color: fg),
                const SizedBox(width: 6),
                Flexible(child: Text(text, style: style)),
                const SizedBox(width: 2),
                Icon(Icons.expand_more_rounded, size: 18, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Option {
  const _Option(this.label, this.value, this.count, this.selected);

  final String label;
  final LibraryFilter value;

  /// Shu variant tanlansa nechta material qoladi.
  final int count;
  final bool selected;
}

class _Section {
  const _Section(this.title, this.options);

  final String? title;
  final List<_Option> options;
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.title, required this.sections});

  final String title;
  final List<_Section> sections;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Semantics(
              header: true,
              child: Text(title, style: text.titleLarge),
            ),
          ),
          for (final section in sections) ...[
            if (section.title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
                child: Text(
                  section.title!.toUpperCase(),
                  style: text.labelSmall!.copyWith(
                    color: p.sub,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            for (final o in section.options) _OptionRow(option: o),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.option});

  final _Option option;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final enabled = option.selected || option.count > 0;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: LgPressable(
        onTap: enabled ? () => Navigator.of(context).pop(option.value) : null,
        selected: option.selected,
        isButton: true,
        color: option.selected ? p.soft : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        semanticLabel: '${option.label}, ${option.count}',
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(
                    option.selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 21,
                    color: option.selected ? p.brand : p.outline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.label,
                      style: text.bodyLarge!.copyWith(
                        fontWeight: option.selected ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${option.count}', style: text.labelMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
