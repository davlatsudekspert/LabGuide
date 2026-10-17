import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/analyte_search.dart';
import '../content/condition_search.dart';
import '../content/ui/conditions_screens.dart';
import '../content/ui/content_widgets.dart';
import '../content/ui/tests_screen.dart';
import '../instruments/instrument_screens.dart';
import '../library/library_catalog.dart';
import '../library/library_widgets.dart';

/// Bosh sahifa tepasidagi qidiruv maydoni: bosilganda umumiy qidiruv
/// ekrani ochiladi (klaviatura bosh sahifani surmaydi).
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: LgPressable(
        onTap: () => context.push('/home/search'),
        color: p.paper,
        borderRadius: BorderRadius.circular(LgRadius.card),
        semanticLabel: l.homeSearchHint,
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LgRadius.card),
              border: Border.all(color: p.line),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: p.sub),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.homeSearchHint,
                    style: text.bodyLarge!.copyWith(color: p.sub),
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

/// Umumiy qidiruv: tahlillar, holatlar, apparatlar va o'quv materiallari
/// bir joyda, guruhlangan. O'zbek lotin/kirill, ruscha va inglizcha nomlar,
/// qisqartmalar va sinonimlar bilan ishlaydi (har bo'limning o'z qidiruvi).
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  static const _perSection = 6;

  final _query = TextEditingController();
  AnalyteSearch? _analytes;
  ConditionSearch? _conditions;
  LibraryCatalog? _library;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final q = _query.text.trim();
    return LgPage(
      title: l.searchTitle,
      showProfile: false,
      children: [
        SearchBox(
          controller: _query,
          label: l.searchTitle,
          hint: l.homeSearchHint,
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        if (q.isEmpty)
          LgNotice(l.searchPrompt, kind: NoticeKind.info)
        else
          ContentGate(
            builder: (context, pack) {
              final analytes =
                  (_analytes?.pack == pack
                          ? _analytes!
                          : _analytes = AnalyteSearch(pack))
                      .search(q, lang: lang);
              final conditions =
                  (_conditions?.pack == pack
                          ? _conditions!
                          : _conditions = ConditionSearch(pack))
                      .search(q, lang: lang);
              final library =
                  (_library?.pack == pack && _library!.lang == lang
                          ? _library!
                          : _library = LibraryCatalog(pack, lang: lang))
                      .apply(LibraryFilter(query: q));
              return CatalogGate(
                builder: (context, catalog) {
                  final instruments = catalog.search(q);
                  final empty =
                      analytes.isEmpty &&
                      conditions.isEmpty &&
                      library.isEmpty &&
                      instruments.isEmpty;
                  if (empty) {
                    return LgStateView(
                      kind: StateKind.empty,
                      title: l.testsEmptyTitle,
                      message: l.searchPrompt,
                    );
                  }
                  final a = analytes.take(_perSection).toList();
                  final c = conditions.take(3).toList();
                  final m = instruments.take(_perSection).toList();
                  final b = library.take(_perSection).toList();
                  return Semantics(
                    liveRegion: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (a.isNotEmpty) ...[
                          _Section(l.featureTests, analytes.length),
                          for (final (i, x) in a.indexed)
                            AnalyteRow(
                              analyte: x,
                              divider: i < a.length - 1,
                              onTap: () =>
                                  context.push('/home/analyte/${x.id}'),
                            ),
                        ],
                        if (c.isNotEmpty) ...[
                          _Section(l.condSearchSection, conditions.length),
                          for (final (i, x) in c.indexed)
                            ConditionRow(
                              condition: x,
                              divider: i < c.length - 1,
                              onTap: () =>
                                  context.push('/home/conditions/${x.id}'),
                            ),
                        ],
                        if (m.isNotEmpty) ...[
                          _Section(l.labInstruments, instruments.length),
                          for (final (i, x) in m.indexed)
                            ModelRow(
                              catalog: catalog,
                              model: x,
                              showMaker: true,
                              divider: i < m.length - 1,
                              onTap: () => openInTab(
                                context,
                                '/lab/instruments/m/${x.id}',
                              ),
                            ),
                        ],
                        if (b.isNotEmpty) ...[
                          _Section(l.searchSectionLibrary, library.length),
                          for (final (i, x) in b.indexed)
                            LgRow(
                              title: libraryShortTitle(x, max: 90),
                              icon: Icons.menu_book_outlined,
                              divider: i < b.length - 1,
                              onTap: () => openInTab(
                                context,
                                '/library/books/item/${x.id}',
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.count);

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => LgSectionTitle('$title · $count');
}
