import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../library/library_widgets.dart' show LibrarySearchField;
import 'lecture_catalog.dart';
import 'topic_test.dart' show DeckTestState;
import 'topic_test_screens.dart';

// Ma'ruza bo'limining asosiy ro'yxati: BARCHA tayyor taqdimotlar modul bo'yicha
// guruhlangan (M1–M9 + amaliy protokollar), tepada qidiruv va filtr chiplari.
// Qidiruv — oniy (debounce 200 ms): deck sarlavhasi, slayd sarlavhalari va
// kalit so'zlar bo'yicha; lotin/kirill, ruscha, inglizcha (lecture_catalog.dart).

/// Tillarning o'z nomlari (autonim) — chip va ogohlantirishlarda.
const kDeckLangNames = {'uz': 'O‘zbekcha', 'ru': 'Русский', 'en': 'English'};

String deckLangsLabel(DeckEntry d) =>
    d.languages.map((l) => l.toUpperCase()).join(' · ');

/// Tanlangan deckni pleyerda ochadi. [slide] — boshlang'ich slayd, [lang] —
/// ilova tilidan boshqa til (faqat qidiruvda boshqa tildagi slayd tanlanganda).
void openDeck(BuildContext context, String id, {int slide = 0, String? lang}) {
  final q = [if (slide > 0) 's=$slide', if (lang != null) 'l=$lang'];
  context.push('/learn/lecture/deck/$id${q.isEmpty ? '' : '?${q.join('&')}'}');
}

class LectureLibrary extends StatefulWidget {
  const LectureLibrary({
    super.key,
    required this.bundle,
    required this.autoEntry,
    required this.topicsSection,
  });

  final AssetBundle bundle;

  /// "Avtomatik taqdimot" kirish qatori (qidiruv yo'q paytda ko'rinadi).
  final Widget autoEntry;

  /// Tayyor taqdimoti yo'q mavzular (o'quv dasturi bo'yicha avtomatik slaydlar);
  /// qidiruv va filtr yo'q paytda ko'rinadi.
  final Widget topicsSection;

  @override
  State<LectureLibrary> createState() => _LectureLibraryState();
}

class _LectureLibraryState extends State<LectureLibrary> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  DeckFilter _filter = const DeckFilter();
  late final Future<DeckCatalog> _catalog = DeckCatalog.load(widget.bundle);
  DeckSearch? _search;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      // Tozalash — darhol.
      setState(() => _query = '');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _query = v);
    });
  }

  void _clearAll() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _query = '';
      _filter = const DeckFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<DeckCatalog>(
      future: _catalog,
      initialData: DeckCatalog.peek(widget.bundle),
      builder: (context, snap) {
        final catalog = snap.data;
        final browsing = _query.trim().isEmpty && _filter.isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LibrarySearchField(
              key: const ValueKey('lecture-search'),
              controller: _controller,
              label: l.lectureSearchLabel,
              hint: l.lectureSearchHint,
              onChanged: _onChanged,
            ),
            if (catalog != null)
              _FilterBar(
                catalog: catalog,
                filter: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
            if (_query.trim().isEmpty) widget.autoEntry,
            if (catalog == null)
              snap.hasError
                  ? LgStateView(
                      kind: StateKind.error,
                      title: l.lectureDeckLoadFailed,
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
            else
              _results(context, catalog),
            if (browsing) widget.topicsSection,
          ],
        );
      },
    );
  }

  Widget _results(BuildContext context, DeckCatalog catalog) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final search = (_search?.catalog == catalog)
        ? _search!
        : _search = DeckSearch(catalog);
    final hits = search.search(_query, filter: _filter, lang: lang);
    if (hits.isEmpty) {
      return LgStateView(
        key: const ValueKey('lecture-empty'),
        kind: StateKind.empty,
        title: l.lectureNoResultsTitle,
        message: l.lectureNoResultsBody,
        actionLabel: l.lectureClearFilters,
        onAction: _clearAll,
      );
    }
    final text = Theme.of(context).textTheme;
    if (_query.trim().isNotEmpty) {
      final q = DeckQuery(_query);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l.lectureResultsFound(hits.length),
                key: const ValueKey('lecture-result-count'),
                style: text.bodySmall,
              ),
            ),
          ),
          for (final (i, h) in hits.indexed)
            _ResultTile(
              hit: h,
              query: q,
              lang: lang,
              divider: i < hits.length - 1,
            ),
        ],
      );
    }
    // Ko'rish: modul bo'yicha guruhlar + amaliy protokollar.
    final byModule = <int, List<DeckEntry>>{};
    final protocols = <DeckEntry>[];
    for (final h in hits) {
      final d = h.entry;
      if (d.kind == DeckKind.protocol) {
        protocols.add(d);
      } else {
        (byModule[d.module ?? 0] ??= []).add(d);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in catalog.modules)
          if (byModule[m.n] case final decks?)
            _Group(
              keyId: 'm${m.n}',
              title: '${m.n}. ${m.title(lang)}',
              decks: decks,
              lang: lang,
            ),
        if (protocols.isNotEmpty)
          _Group(
            keyId: 'protocols',
            title: l.lectureFilterProtocols,
            decks: protocols,
            lang: lang,
          ),
      ],
    );
  }
}

/// Filtr chiplari: modul / hammasi / amaliy protokollar va til.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.catalog,
    required this.filter,
    required this.onChanged,
  });

  final DeckCatalog catalog;
  final DeckFilter filter;
  final ValueChanged<DeckFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final allSelected = filter.module == null && !filter.protocolsOnly;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LgChoiceChip(
                key: const ValueKey('lecture-filter-all'),
                label: l.lectureFilterAll,
                selected: allSelected,
                onTap: () => onChanged(
                  filter.copyWith(module: null, protocolsOnly: false),
                ),
              ),
              for (final m in catalog.modules)
                LgChoiceChip(
                  key: ValueKey('lecture-filter-m${m.n}'),
                  label: l.lectureFilterModule(m.n),
                  selected: filter.module == m.n,
                  onTap: () => onChanged(
                    filter.copyWith(module: m.n, protocolsOnly: false),
                  ),
                ),
              LgChoiceChip(
                key: const ValueKey('lecture-filter-protocols'),
                label: l.lectureFilterProtocols,
                selected: filter.protocolsOnly,
                onTap: () => onChanged(
                  filter.copyWith(module: null, protocolsOnly: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LgChoiceChip(
                key: const ValueKey('lecture-lang-all'),
                label: l.lectureLangAll,
                selected: filter.lang == null,
                onTap: () => onChanged(filter.copyWith(lang: null)),
              ),
              for (final code in kDeckLangs)
                LgChoiceChip(
                  key: ValueKey('lecture-lang-$code'),
                  label: kDeckLangNames[code]!,
                  selected: filter.lang == code,
                  onTap: () => onChanged(filter.copyWith(lang: code)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Guruh (modul yoki protokollar): sarlavha, soni va decklar.
class _Group extends StatelessWidget {
  const _Group({
    required this.keyId,
    required this.title,
    required this.decks,
    required this.lang,
  });

  final String keyId;
  final String title;
  final List<DeckEntry> decks;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final slides = decks.fold<int>(0, (a, d) => a + d.slides(lang));
    final langs = [
      for (final c in kDeckLangs)
        if (decks.any((d) => d.languages.contains(c))) c.toUpperCase(),
    ].join(' · ');
    return Column(
      key: ValueKey('lecture-group-$keyId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(title),
        Semantics(
          label: [
            l.lectureDecksCount(decks.length),
            l.lectureSlidesCount(slides),
            langs,
          ].join(', '),
          excludeSemantics: true,
          child: Text(
            [
              l.lectureDecksCount(decks.length),
              l.lectureSlidesCount(slides),
              langs,
            ].join(' · '),
            key: ValueKey('lecture-group-count-$keyId'),
            style: text.bodySmall,
          ),
        ),
        const SizedBox(height: 4),
        for (final (i, d) in decks.indexed)
          _DeckRow(deck: d, lang: lang, divider: i < decks.length - 1),
      ],
    );
  }
}

/// Deck qatori: bosish — pleyer; o'ngda — “Mavzu testi” va eng yaxshi natija
/// (8/10); savollar yetmasa — “Savollar tayyorlanmoqda”; uzoq bosish — amallar
/// (mavzu testi, ustozga “Guruhga topshirish”).
class _DeckRow extends StatelessWidget {
  const _DeckRow({
    required this.deck,
    required this.lang,
    required this.divider,
  });

  final DeckEntry deck;
  final String lang;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    return DeckTestBuilder(
      deck: deck,
      builder: (context, state, _) {
        final ready = state == DeckTestState.ready;
        final row = LgRow(
          key: ValueKey('deck-${deck.id}'),
          title: deck.title(lang),
          subtitle: [
            deckMeta(l, deck, lang),
            if (state == DeckTestState.preparing) l.topicTestPreparingShort,
          ].join(' · '),
          icon: deck.kind == DeckKind.protocol
              ? Icons.science_outlined
              : Icons.co_present_outlined,
          divider: divider && !ready,
          onTap: () => openDeck(context, deck.id),
        );
        return GestureDetector(
          onLongPress: () => showDeckActions(context, deck),
          child: !ready
              ? row
              : DecoratedBox(
                  decoration: BoxDecoration(
                    border: divider
                        ? Border(
                            bottom: BorderSide(
                              color: p.line.withValues(alpha: 0.7),
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      row,
                      // Qator matni bilan bir chiziqda (ikonka 42 + 12).
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 54,
                          bottom: 12,
                        ),
                        child: DeckTestBadge(deck: deck),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

/// Qator ostidagi izoh: kun/hafta (yoki protokol guruhi), slaydlar soni, tillar.
String deckMeta(AppLocalizations l, DeckEntry d, String lang) => [
  if (d.kind == DeckKind.protocol)
    ?(d.groups[lang] ?? d.groups['uz'])
  else ...[
    if (d.day != null) l.classroomDayN(d.day!),
    if (d.week != null) l.classroomWeekN(d.week!),
  ],
  l.lectureSlidesCount(d.slides(lang)),
  deckLangsLabel(d),
].join(' · ');

/// Qidiruv natijasi: deck sarlavhasi (mos so'zlar ajratilgan), mos slaydlar.
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.hit,
    required this.query,
    required this.lang,
    required this.divider,
  });

  final DeckHit hit;
  final DeckQuery query;
  final String lang;
  final bool divider;

  static const _maxHits = 3;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final d = hit.entry;
    final shown = d.resolveLang(lang);
    // Boshqa tildagi slaydlar topilgan bo'lsa — deck o'sha tilda ochiladi.
    final slideLang = hit.slides.isEmpty ? null : hit.slidesLang;
    final otherLang = slideLang != null && slideLang != shown
        ? slideLang
        : null;
    final title = d.title(lang);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: p.line.withValues(alpha: 0.7)))
            : null,
      ),
      child: Column(
        key: ValueKey('result-${d.id}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgPressable(
            onTap: () =>
                openDeck(context, d.id, slide: hit.firstSlide, lang: otherLang),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedText(title, query: query, style: text.titleSmall!),
                  const SizedBox(height: 3),
                  Text(
                    deckMeta(l, d, lang),
                    style: text.bodySmall!.copyWith(fontSize: 13),
                  ),
                  if (hit.matchedSlides > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      l.lectureSlidesMatch(hit.matchedSlides),
                      key: ValueKey('match-count-${d.id}'),
                      style: text.labelMedium!.copyWith(color: p.brand),
                    ),
                  ],
                ],
              ),
            ),
          ),
          for (final r in hit.slides.take(_maxHits))
            LgPressable(
              key: ValueKey('hit-${d.id}-${r.first}'),
              onTap: () =>
                  openDeck(context, d.id, slide: r.first, lang: otherLang),
              borderRadius: BorderRadius.circular(10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTap),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.slideshow_outlined,
                          size: 18,
                          color: p.sub,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: HighlightedText(
                          [
                            if (otherLang != null)
                              '(${otherLang.toUpperCase()}) ',
                            r.title,
                          ].join(),
                          query: query,
                          style: text.bodyMedium!,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (hit.slides.length > _maxHits)
            Padding(
              padding: const EdgeInsets.fromLTRB(38, 0, 8, 8),
              child: Text(
                l.lectureMoreSlides(hit.slides.length - _maxHits),
                style: text.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// Matn: so'rovga mos qismlar qalin va fon bilan ajratiladi (rangga
/// tayanmaydi: qalinlik ham o'zgaradi).
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    super.key,
    required this.query,
    required this.style,
  });

  final String text;
  final DeckQuery query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final ranges = highlightRanges(text, query);
    if (ranges.isEmpty) return Text(text, style: style);
    final hi = style.copyWith(
      fontWeight: FontWeight.w800,
      color: p.brand,
      backgroundColor: p.soft,
    );
    final spans = <TextSpan>[];
    var at = 0;
    for (final (s, e) in ranges) {
      if (s > at) spans.add(TextSpan(text: text.substring(at, s)));
      spans.add(TextSpan(text: text.substring(s, e), style: hi));
      at = e;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
