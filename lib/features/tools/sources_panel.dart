/// "Manbalar" paneli (D-65): bo'lim qaysi adabiyotga asoslanganini
/// "Manba: Muallif, yil, «nom», bob/bet" ko'rinishida ko'rsatadi va ostida
/// bitta qisqa tibbiy xavfsizlik eslatmasi (tashxis emas; natijani shifokor
/// baholaydi; referens oraliqlar laboratoriya/usulga bog'liq).
///
/// Bu ogohlantirish emas — yumshoq (soft) panel. "Qoralama / tekshirilmagan"
/// so'zlari ishlatilmaydi (test: `test/unit/no_draft_wording_test.dart`).
library;

import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import 'calc_info.dart';

/// Iqtibosning qismlari: mualliflar, yil, sarlavha (Vancouver uslubidagi
/// `CalcSource.citation` dan). Ajratib bo'lmasa — `null`.
({String authors, String? year, String title})? citationParts(String citation) {
  final end = _sentenceEnd(citation, 0);
  if (end == null) return null;
  final authors = _trimDot(citation.substring(0, end + 1));
  final titleStart = end + 2;
  final titleEnd = _sentenceEnd(citation, titleStart);
  final title = _trimDot(
    titleEnd == null
        ? citation.substring(titleStart)
        : citation.substring(titleStart, titleEnd + 1),
  ).trim();
  if (authors.isEmpty || title.isEmpty) return null;
  final rest = titleEnd == null ? '' : citation.substring(titleEnd + 1);
  return (authors: authors, year: _year(rest) ?? _year(citation), title: title);
}

/// "Muallif, yil, «nom», bob/bet" (lokator interfeys tilida: "7-bet").
String shortCitation(
  CalcSource source, {
  String locator = '',
  String Function(String page)? citePage,
}) {
  final parts = citationParts(source.citation);
  final where = locator.isEmpty
      ? ''
      : citePage == null
      ? locator
      : localizePages(locator, citePage);
  final head = parts == null
      ? source.citation
      : [parts.authors, ?parts.year, '«${parts.title}»'].join(', ');
  return where.isEmpty ? head : '$head, $where';
}

/// Kontent paketidagi manba: "Muallif, yil, «nom»". Kutubxona elementi
/// bo'lsa — uning mualliflari va yili, aks holda nashriyot va manba sanasi.
String contentSourceCitation(ContentSource source, ContentPack pack) {
  final item = source.libraryItemId == null
      ? null
      : pack.libraryItem(source.libraryItemId!);
  final authors = (item != null && item.authors.isNotEmpty)
      ? item.authors.join(', ')
      : source.publisher;
  final year =
      item?.year?.toString() ?? _yearRe.firstMatch(source.sourceDate ?? '')?[0];
  return [authors, ?year, '«${source.title}»'].join(', ');
}

/// Manba bo'yicha takrorsiz ro'yxat. Bir manbaning lokatorlari har xil
/// bo'lsa, panelda lokator yozilmaydi (to'liq ro'yxat — sahifa pastida).
List<CalcRef> distinctSources(Iterable<CalcRef> refs) {
  final order = <String>[];
  final locators = <String, Set<String>>{};
  final sources = <String, CalcSource>{};
  for (final r in refs) {
    final id = r.source.id;
    if (!sources.containsKey(id)) order.add(id);
    sources[id] = r.source;
    (locators[id] ??= <String>{}).add(r.locator);
  }
  return [
    for (final id in order)
      CalcRef(
        sources[id]!,
        locators[id]!.length == 1 ? locators[id]!.first : '',
      ),
  ];
}

/// Bo'lim/sahifa boshidagi yumshoq "Manbalar" paneli.
class SourcesPanel extends StatelessWidget {
  const SourcesPanel(
    this.refs, {
    super.key,
    this.max = 4,
    this.disclaimer = true,
    this.note,
  });

  final List<CalcRef> refs;

  /// Ko'pi bilan nechta qator; qolgani "+ yana N ta" (pastdagi ro'yxatda).
  final int max;

  /// Tibbiy xavfsizlik eslatmasi (bitta qisqa qator).
  final bool disclaimer;

  /// Qo'shimcha neytral qator (masalan, "kitoblar faqat iqtibos").
  final String? note;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final unique = distinctSources(refs);
    final shown = unique.take(max).toList();
    return SourcesNote(
      lines: [
        for (final r in shown)
          l.sourceLine(
            shortCitation(r.source, locator: r.locator, citePage: l.citePage),
          ),
        if (unique.length > shown.length)
          l.sourcesPanelMore(unique.length - shown.length),
      ],
      footer: [?note, if (disclaimer) l.sourcesDisclaimer],
    );
  }
}

/// Yumshoq panel: sarlavha ("Manbalar"), manba qatorlari va kichik izoh.
/// Analit kartasi ham shuni ishlatadi (o'z manba qatori bilan).
class SourcesNote extends StatelessWidget {
  const SourcesNote({
    super.key,
    required this.lines,
    this.footer = const [],
    this.title,
  });

  final List<String> lines;
  final List<String> footer;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      child: LgPanel(
        soft: true,
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 18, color: p.brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title ?? l.sourcesPanelTitle,
                    style: text.titleSmall!.copyWith(color: p.ink),
                  ),
                ),
              ],
            ),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  line,
                  style: text.bodySmall!.copyWith(color: p.ink, height: 1.45),
                ),
              ),
            for (final f in footer)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(f, style: text.bodySmall!.copyWith(color: p.sub)),
              ),
          ],
        ),
      ),
    );
  }
}

/// `text` dagi [from] dan keyingi birinchi ". " (Vancouver: mualliflar,
/// sarlavha, jurnal — har biri nuqta va bo'shliq bilan tugaydi; initsiallar
/// nuqtasiz yoki "С.А.," ko'rinishida). "et al." / "2nd ed." / "Дадаев С." —
/// qismning oxiri; nuqta [_trimDot] da saqlanadi.
int? _sentenceEnd(String text, int from) {
  final i = text.indexOf('. ', from);
  return i < 0 ? null : i;
}

/// Oxirgi nuqtani olib tashlaydi, qisqartma bo'lsa — qoldiradi: "et al.",
/// "2nd ed.", nuqtali initsiallar ("Aripov A.N.", "Дадаев С."). Vancouver
/// initsiali nuqtasiz ("Speeckaert M") — u yerdagi nuqta gap oxiri.
String _trimDot(String s) {
  final t = s.trimRight();
  if (!t.endsWith('.')) return t;
  final body = t.substring(0, t.length - 1);
  final m = RegExp(r'(^|[\s.,])([^\s.,]+)$').firstMatch(body);
  final word = m?[2] ?? '';
  final before = m?[1] ?? '';
  final capital =
      word.length == 1 &&
      word.toUpperCase() == word &&
      word != word.toLowerCase();
  // "A.N." — oldida nuqta; "С." — lotin bo'lmagan (kirill) initsial.
  final initial = capital && (before == '.' || word.codeUnitAt(0) > 0x7f);
  final keep = word == 'al' || word == 'ed' || word == 'eds' || initial;
  return keep ? t : body;
}

final _noise = RegExp(
  r'(doi:\S+|https?://\S+|ISBN[\s\d-]+|PMC\d+|PMID\s*\d+|\d{3,}-\d+-[\d-]+)',
);
final _yearRe = RegExp(r'(?<![\d/.])(19|20)\d{2}(?![\d/])');

String? _year(String s) => _yearRe.firstMatch(s.replaceAll(_noise, ''))?[0];
