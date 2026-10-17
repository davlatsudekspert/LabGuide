import 'dart:convert';

import 'package:flutter/services.dart';

import '../content/analyte_search.dart';
import 'lecture_decks.dart';

// Ma'ruza bo'limidagi BARCHA taqdimotlar katalogi: kun mavzulari (M1–M9) va
// amaliy protokollar. Indeks — assets/lectures/index_v2.json (ixcham: sarlavhalar,
// slayd sarlavhalari, qidiruv matni); slaydlarning o'zi — har deck va til uchun
// alohida fayl (assets/lectures/decks/<id>.<til>.json), ochilganda yuklanadi.
// Fayllarni tool/slides/export_app_decks.py yozadi.

const kDeckLangs = ['uz', 'ru', 'en'];

enum DeckKind { day, protocol }

/// Ketma-ket bir xil sarlavhali slaydlar guruhi (masalan, bir tahlilning
/// 3 slaydi): sarlavha, birinchi slayd indeksi va slaydlar soni.
class SlideRun {
  const SlideRun(this.title, this.first, this.count);

  final String title;
  final int first;
  final int count;
}

class DeckModule {
  const DeckModule({required this.n, required this.id, required this.titles});

  final int n;
  final String id;
  final Map<String, String> titles;

  String title(String lang) => titles[lang] ?? titles['uz'] ?? id;
}

class DeckEntry {
  const DeckEntry({
    required this.id,
    required this.kind,
    required this.titles,
    required this.slideCounts,
    required this.languages,
    required this.runs,
    required this.keywords,
    this.module,
    this.week,
    this.day,
    this.topics = const [],
    this.files = const {},
    this.groups = const {},
  });

  factory DeckEntry.fromJson(Map<String, Object?> j) {
    Map<String, T> byLang<T>(Object? m, T Function(Object?) f) => {
      for (final e in ((m as Map?) ?? const {}).entries)
        e.key as String: f(e.value),
    };
    return DeckEntry(
      id: j['id']! as String,
      kind: j['kind'] == 'protocol' ? DeckKind.protocol : DeckKind.day,
      module: j['m'] as int?,
      week: j['w'] as int?,
      day: j['d'] as int?,
      topics: [...?(j['topics'] as List?)?.cast<String>()],
      titles: byLang(j['t'], (v) => v! as String),
      slideCounts: byLang(j['n'], (v) => v! as int),
      languages: [...(j['l']! as List).cast<String>()],
      runs: byLang(
        j['st'],
        (v) => [
          for (final r in (v! as List))
            SlideRun((r as List)[0] as String, r[1] as int, r[2] as int),
        ],
      ),
      keywords: j['kw'] as String? ?? '',
      files: byLang(j['f'], (v) => v! as String),
      groups: byLang(j['g'], (v) => v! as String),
    );
  }

  final String id;
  final DeckKind kind;

  /// O'quv dasturi moduli (1–9), hafta va kun (faqat kun mavzulari).
  final int? module;
  final int? week;
  final int? day;
  final List<String> topics;

  /// Tillar bo'yicha sarlavha va slaydlar soni.
  final Map<String, String> titles;
  final Map<String, int> slideCounts;
  final List<String> languages;

  /// Qidiruv uchun slayd sarlavhalari (til bo'yicha).
  final Map<String, List<SlideRun>> runs;

  /// Normallashtirilgan kalit so'zlar (barcha tillar, ` | ` bilan).
  final String keywords;

  /// Standart bo'lmagan fayl yo'llari (muallif decki: `d001.json`).
  final Map<String, String> files;

  /// Protokol guruhi nomi (Gematologiya, ...), til bo'yicha.
  final Map<String, String> groups;

  /// Ilova tiliga mos sarlavha (yo'q bo'lsa — o'zbekcha).
  String title(String lang) =>
      titles[lang] ?? titles['uz'] ?? titles.values.first;

  /// Deck qaysi tilda ochiladi: so'ralgan til bo'lsa o'sha, bo'lmasa
  /// o'zbekcha, u ham bo'lmasa birinchi mavjud.
  String resolveLang(String want) => languages.contains(want)
      ? want
      : languages.contains('uz')
      ? 'uz'
      : languages.first;

  int slides(String lang) =>
      slideCounts[resolveLang(lang)] ?? slideCounts.values.first;

  String path(String lang) =>
      files[lang] ?? 'assets/lectures/decks/$id.$lang.json';
}

class DeckCatalog {
  DeckCatalog(this.modules, this.decks) {
    for (final d in decks) {
      _byId[d.id] = d;
      for (final t in d.topics) {
        _byTopic[t] = d;
      }
    }
  }

  factory DeckCatalog.parse(String json) {
    final j = jsonDecode(json) as Map<String, Object?>;
    return DeckCatalog(
      [
        for (final m in (j['modules']! as List).cast<Map<String, Object?>>())
          DeckModule(
            n: m['n']! as int,
            id: m['id']! as String,
            titles: {
              for (final l in kDeckLangs)
                if (m[l] is String) l: m[l]! as String,
            },
          ),
      ],
      [
        for (final d in (j['decks']! as List).cast<Map<String, Object?>>())
          DeckEntry.fromJson(d),
      ],
    );
  }

  final List<DeckModule> modules;
  final List<DeckEntry> decks;
  final _byId = <String, DeckEntry>{};
  final _byTopic = <String, DeckEntry>{};

  DeckEntry? byId(String id) => _byId[id];

  /// Kun mavzusi (`d012-P`/`d012-L`) → shu kunning decki.
  DeckEntry? byTopic(String topicId) => _byTopic[topicId];

  DeckModule? module(int n) {
    for (final m in modules) {
      if (m.n == n) return m;
    }
    return null;
  }

  List<DeckEntry> inModule(int n) => [
    for (final d in decks)
      if (d.kind == DeckKind.day && d.module == n) d,
  ];

  List<DeckEntry> get protocols => [
    for (final d in decks)
      if (d.kind == DeckKind.protocol) d,
  ];

  // --- yuklash (bundle bo'yicha keshlanadi) ---------------------------------

  static const indexPath = 'assets/lectures/index_v2.json';
  static final _cache = Expando<Future<DeckCatalog>>();
  static final _loaded = Expando<DeckCatalog>();
  static final _deckCache = Expando<Map<String, Future<LectureDeck>>>();
  static final _decksLoaded = Expando<Map<String, LectureDeck>>();

  static Future<DeckCatalog> load(AssetBundle bundle) => _cache[bundle] ??=
      bundle.loadString(indexPath).then((s) => _loaded[bundle] = parseOf(s));

  /// Yuklangan bo'lsa — darhol (birinchi kadrda).
  static DeckCatalog? peek(AssetBundle bundle) => _loaded[bundle];

  static DeckCatalog parseOf(String s) => DeckCatalog.parse(s);

  /// Deck faylini yuklaydi (id + til bo'yicha keshlanadi). [lang] mavjud
  /// bo'lishi shart — [DeckEntry.resolveLang] bilan tanlang.
  static Future<LectureDeck> loadDeck(
    AssetBundle bundle,
    DeckEntry entry,
    String lang,
  ) {
    final futures = _deckCache[bundle] ??= {};
    return futures['${entry.id}.$lang'] ??= bundle
        .loadString(entry.path(lang))
        .then(
          (s) => (_decksLoaded[bundle] ??= {})['${entry.id}.$lang'] =
              LectureDeck.fromJson(jsonDecode(s) as Map<String, Object?>),
        );
  }

  static LectureDeck? peekDeck(
    AssetBundle bundle,
    DeckEntry entry,
    String lang,
  ) => _decksLoaded[bundle]?['${entry.id}.$lang'];
}

// =============================================================================
// Filtr va qidiruv
// =============================================================================

/// Ro'yxat filtri: modul (1–9) yoki amaliy protokollar; til.
class DeckFilter {
  const DeckFilter({this.module, this.protocolsOnly = false, this.lang});

  final int? module;
  final bool protocolsOnly;

  /// Faqat shu tilda mavjud decklar.
  final String? lang;

  bool get isEmpty => module == null && !protocolsOnly && lang == null;

  DeckFilter copyWith({
    Object? module = _keep,
    bool? protocolsOnly,
    Object? lang = _keep,
  }) => DeckFilter(
    module: identical(module, _keep) ? this.module : module as int?,
    protocolsOnly: protocolsOnly ?? this.protocolsOnly,
    lang: identical(lang, _keep) ? this.lang : lang as String?,
  );

  static const _keep = Object();

  bool matches(DeckEntry d) {
    if (protocolsOnly && d.kind != DeckKind.protocol) return false;
    if (module != null && d.module != module) return false;
    if (lang != null && !d.languages.contains(lang)) return false;
    return true;
  }
}

/// Qidiruv natijasi: deck, ball va mos kelgan slayd sarlavhalari.
class DeckHit {
  const DeckHit({
    required this.entry,
    required this.score,
    required this.slides,
    required this.slidesLang,
    required this.matchedSlides,
  });

  final DeckEntry entry;
  final int score;

  /// Mos slayd sarlavhalari (birinchi slayd tartibida); bo'sh bo'lishi mumkin
  /// (deck sarlavhasi yoki kalit so'z bo'yicha mos kelgan).
  final List<SlideRun> slides;

  /// [slides] qaysi tildagi sarlavhalar (ilova tili bo'lmasa — boshqa til).
  final String slidesLang;

  /// Mos slaydlar soni (guruhlar bo'yicha yig'indi).
  final int matchedSlides;

  /// Natija bosilganda ochiladigan slayd (mos sarlavha bo'lsa — o'sha).
  int get firstSlide => slides.isEmpty ? 0 : slides.first.first;
}

/// Ball darajalari (kattaroq = yuqoriroq).
abstract final class DeckScore {
  static const titleExact = 1000;
  static const titlePrefix = 800;
  static const titleWord = 700;
  static const titleContains = 600;
  static const slideTitle = 400;
  static const keyword = 100;
}

/// Qidiruv so'rovi: normallashtirilgan variantlar (lotin/kirill, rus yo'nalishi)
/// va ularning so'zlari.
class DeckQuery {
  DeckQuery(String raw)
    : normalized = normalizeForSearch(raw),
      variants = normalizeForSearch(raw).isEmpty
          ? const []
          : [
              for (final v in searchVariants(normalizeForSearch(raw)))
                if (v.isNotEmpty) v,
            ];

  final String normalized;
  final List<String> variants;

  bool get isEmpty => variants.isEmpty;

  /// [haystack] (normallashtirilgan) har bir variantning hamma so'zini
  /// o'z ichiga oladimi.
  bool containsAll(String haystack) {
    for (final v in variants) {
      var ok = true;
      for (final t in v.split(' ')) {
        if (!haystack.contains(t)) {
          ok = false;
          break;
        }
      }
      if (ok) return true;
    }
    return false;
  }
}

class DeckSearch {
  DeckSearch(this.catalog) {
    for (final d in catalog.decks) {
      _titles[d.id] = {
        for (final e in d.titles.entries) e.key: normalizeForSearch(e.value),
      };
      _runs[d.id] = {
        for (final e in d.runs.entries)
          e.key: [for (final r in e.value) normalizeForSearch(r.title)],
      };
    }
  }

  final DeckCatalog catalog;
  final _titles = <String, Map<String, String>>{};
  final _runs = <String, Map<String, List<String>>>{};

  /// [query] bo'sh bo'lsa — filtrga mos hamma decklar (katalog tartibida,
  /// ballsiz). Aks holda ball bo'yicha: deck sarlavhasi (to'liq > boshi >
  /// so'z boshi > ichida) > slayd sarlavhasi > kalit so'z. [lang] — ilova tili:
  /// sarlavha va slaydlar shu tilda ko'rsatiladi.
  List<DeckHit> search(
    String query, {
    DeckFilter filter = const DeckFilter(),
    required String lang,
  }) {
    final q = DeckQuery(query);
    final out = <DeckHit>[];
    for (final d in catalog.decks) {
      if (!filter.matches(d)) continue;
      if (q.isEmpty) {
        out.add(
          DeckHit(
            entry: d,
            score: 0,
            slides: const [],
            slidesLang: lang,
            matchedSlides: 0,
          ),
        );
        continue;
      }
      if (!q.containsAll(d.keywords)) continue;
      var score = DeckScore.keyword;
      // Deck sarlavhasi (ilova tilidagi sarlavha biroz ustun).
      for (final e in _titles[d.id]!.entries) {
        final s = _titleScore(q, e.value);
        if (s > 0 && s + (e.key == lang ? 20 : 0) > score) {
          score = s + (e.key == lang ? 20 : 0);
        }
      }
      // Slayd sarlavhalari: ilova tilida; bo'lmasa boshqa tilda.
      var slides = <SlideRun>[];
      var slidesLang = lang;
      final order = [
        lang,
        for (final l in d.languages)
          if (l != lang) l,
      ];
      for (final l in order) {
        final norm = _runs[d.id]?[l];
        final runs = d.runs[l];
        if (norm == null || runs == null) continue;
        final found = <SlideRun>[];
        for (final (k, n) in norm.indexed) {
          if (q.containsAll(n)) found.add(runs[k]);
        }
        if (found.isNotEmpty) {
          slides = found;
          slidesLang = l;
          break;
        }
      }
      if (slides.isNotEmpty) {
        final s =
            DeckScore.slideTitle + (slides.length > 20 ? 20 : slides.length);
        if (s > score) score = s;
      }
      out.add(
        DeckHit(
          entry: d,
          score: score,
          slides: slides,
          slidesLang: slidesLang,
          matchedSlides: slides.fold(0, (a, r) => a + r.count),
        ),
      );
    }
    if (!q.isEmpty) {
      // Ball bo'yicha kamayish; teng ballda katalog tartibi (barqaror).
      final order = {for (final (i, h) in out.indexed) h: i};
      out.sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : order[a]!.compareTo(order[b]!);
      });
    }
    return out;
  }

  /// Deck sarlavhasining so'rovga mosligi (0 — mos emas).
  int _titleScore(DeckQuery q, String title) {
    var best = 0;
    for (final v in q.variants) {
      var s = 0;
      if (title == v) {
        s = DeckScore.titleExact;
      } else if (title.startsWith(v)) {
        s = DeckScore.titlePrefix;
      } else if (title.contains(' $v')) {
        s = DeckScore.titleWord;
      } else if (v.split(' ').every(title.contains)) {
        s = DeckScore.titleContains;
      }
      if (s > best) best = s;
    }
    return best;
  }
}

// =============================================================================
// Qidiruv so'zlarini matnda ajratib ko'rsatish
// =============================================================================

/// [text] ichida [query] variantlariga mos qismlar (asl matn indekslarida,
/// birlashtirilgan, tartiblangan). Normallashtirish [normalizeForSearch] bilan
/// bir xil (apostroflar tushiriladi, ё→е, tinish belgilari bo'shliq).
List<(int, int)> highlightRanges(String text, DeckQuery q) {
  if (q.isEmpty || text.isEmpty) return const [];
  // Normallashtirilgan matn va har belgining asl indeksi.
  final norm = StringBuffer();
  final map = <int>[];
  var lastSpace = true;
  for (var i = 0; i < text.length; i++) {
    var ch = text[i].toLowerCase();
    if ('‘’ʻʼ`\'´'.contains(ch)) continue;
    if (ch == 'ё') ch = 'е';
    if ('-‐–—_/,.;:()[]·'.contains(ch) || ch.trim().isEmpty) ch = ' ';
    if (ch == ' ') {
      if (lastSpace) continue;
      lastSpace = true;
    } else {
      lastSpace = false;
    }
    norm.write(ch);
    for (var k = 0; k < ch.length; k++) {
      map.add(i);
    }
  }
  final n = norm.toString();
  final ranges = <(int, int)>[];
  for (final v in q.variants) {
    for (final t in v.split(' ')) {
      if (t.isEmpty) continue;
      var from = 0;
      while (true) {
        final at = n.indexOf(t, from);
        if (at < 0) break;
        final start = map[at];
        final end = map[at + t.length - 1] + 1;
        ranges.add((start, end));
        from = at + t.length;
      }
    }
  }
  if (ranges.isEmpty) return const [];
  ranges.sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <(int, int)>[ranges.first];
  for (final r in ranges.skip(1)) {
    final last = merged.last;
    if (r.$1 <= last.$2) {
      merged[merged.length - 1] = (last.$1, r.$2 > last.$2 ? r.$2 : last.$2);
    } else {
      merged.add(r);
    }
  }
  return merged;
}
