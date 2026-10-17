import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Tayyor taqdimotlar. Muallif yozgan deck: assets/lectures/index.json → har
// deck bir yoki bir nechta o'quv dasturi mavzusiga (topic id) biriktiriladi.
// Barcha decklar katalogi (kun mavzulari va amaliy protokollar, uz/ru/en) —
// assets/lectures/index_v2.json va lecture_catalog.dart.
// Mavzuda tayyor taqdimot bo'lsa, Ma'ruza rejimi uni ko'rsatadi; bo'lmasa —
// avtomatik yig'iladigan slaydlar. Holati "draft" — ustoz tekshiruvi uchun
// qoralama (tasdiqlangan deb ko'rsatilmaydi).

class DeckSlide {
  const DeckSlide({
    required this.title,
    this.eyebrow,
    this.bullets = const [],
    this.note,
    this.source,
    this.section = false,
    this.image,
    this.template = 'bullets',
    this.header = const [],
    this.rows = const [],
    this.footnote,
    this.figure,
    this.caption,
    this.credit,
    this.options = const [],
    this.correct,
    this.explanation,
    this.compact = false,
    this.plan = false,
    this.refs = const [],
    this.stats = const [],
    this.range,
    this.cols = const [],
    this.example,
    this.category,
  });

  /// [srcs] — deck darajasidagi manba qatorlari jadvali: slaydda `src`
  /// indeksi bo'lsa shu yerdan olinadi (hajmni kamaytiradi).
  factory DeckSlide.fromJson(
    Map<String, Object?> j, {
    List<String> srcs = const [],
    List<List<DeckRef>> refs = const [],
    Map<String, String> cats = const {},
  }) => DeckSlide(
    title: j['title']! as String,
    eyebrow: j['eyebrow'] as String?,
    bullets: [...?(j['bullets'] as List?)?.cast<String>()],
    note: j['note'] as String?,
    source:
        j['source'] as String? ??
        (j['src'] is int && (j['src']! as int) < srcs.length
            ? srcs[j['src']! as int]
            : null),
    section: j['section'] == true,
    image: j['image'] as String?,
    template: j['template'] as String? ?? 'bullets',
    header: [...?(j['header'] as List?)?.cast<String>()],
    rows: [
      for (final r in (j['rows'] as List?) ?? const [])
        [...(r as List).cast<String>()],
    ],
    footnote: j['footnote'] as String?,
    figure: j['figure'] as String?,
    caption: j['caption'] as String?,
    credit: j['credit'] as String?,
    options: [...?(j['options'] as List?)?.cast<String>()],
    correct: j['correct'] as int?,
    explanation: j['explanation'] as String?,
    compact: j['compact'] == true,
    plan: j['plan'] == true,
    refs: j['ref'] is int && (j['ref']! as int) < refs.length
        ? refs[j['ref']! as int]
        : const [],
    stats: [
      for (final r in (j['stats'] as List?) ?? const [])
        [...(r as List).cast<String>()],
    ],
    range: j['range'] as Map<String, Object?>?,
    cols: [
      for (final c in (j['cols'] as List?) ?? const [])
        (
          (c as List)[0]! as String,
          c[1]! as String,
          [...(c[2]! as List).cast<String>()],
        ),
    ],
    example: j['ex'] as String?,
    category: cats[(j['eyebrow'] as String? ?? '').split(' · ').first],
  );

  final String title;
  final String? eyebrow;
  final List<String> bullets;

  /// Ustoz izohi (auditoriyaga ko'rsatilmaydi, tugma bilan ochiladi).
  final String? note;

  /// Manba (slayd pastida kichik yozuv).
  final String? source;

  /// Bo'lim boshi slaydi.
  final bool section;

  /// Tayyor dizayndagi slayd rasmi (PPTX ko'rinishi, 16:9). Matn maydonlari
  /// ekran o'quvchi uchun saqlanadi.
  final String? image;

  /// Shablon: `title`, `bullets` (standart), `table`, `figure`, `qa`
  /// (lecture_slide.dart [SlideTemplate]).
  final String template;

  /// Jadval shabloni: sarlavha qatori (bo'sh bo'lishi mumkin), qatorlar va
  /// jadval ostidagi izoh.
  final List<String> header;
  final List<List<String>> rows;
  final String? footnote;

  /// Rasm shabloni: asset yo'li va izoh (qatorlar `\n` bilan).
  final String? figure;
  final String? caption;

  /// Rasm muallifi/litsenziyasi yoki "sxema" izohi (har sahifada).
  final String? credit;

  /// Savol-javob shabloni: variantlar, to'g'ri javob indeksi, tushuntirish.
  final List<String> options;
  final int? correct;
  final String? explanation;

  /// Ixcham bandlar (uzun manbalar ro'yxati).
  final bool compact;

  /// Dars/protokol rejasi slaydi (raqamli bandlar).
  final bool plan;

  /// Shu slayd manbalari: "Adabiyotlar" ro'yxatidagi tartib raqami va shu
  /// slaydda ishlatilgan bo'lim/sahifalar (deck `refs` jadvalidan).
  final List<DeckRef> refs;

  /// `stats`: [[qiymat, yorliq], ...] — band matnidan so'zma-so'z.
  final List<List<String>> stats;

  /// `range`: {u: birlik, cap: umumiy yorliq, rows: [[yorliq, izoh, past,
  /// yuqori, bayroq, past matni, yuqori matni], ...]} — analit kartasidan.
  final Map<String, Object?>? range;

  /// `split`: ustunlar (sarlavha, yo'nalish, bandlar).
  final List<(String, String, List<String>)> cols;

  /// `example`: misol matni.
  final String? example;

  /// Bo'lim kategoriyasi (deck `cats` jadvalidan, eyebrow boshi bo'yicha).
  final String? category;
}

/// Slayd manbasi: [index] — deck bibliografiyasidagi (oxirgi "Adabiyotlar"
/// slaydlari) tartib raqami (0 dan), [locators] — shu slaydda ishlatilgan
/// bo'lim/sahifalar.
@immutable
class DeckRef {
  const DeckRef(this.index, [this.locators = const []]);

  factory DeckRef.fromJson(List<Object?> row) =>
      DeckRef(row.first! as int, [for (final x in row.skip(1)) x! as String]);

  final int index;
  final List<String> locators;
}

class LectureDeck {
  const LectureDeck({
    required this.topics,
    required this.lang,
    required this.draft,
    required this.slides,
    this.id,
    this.title,
  });

  factory LectureDeck.fromJson(Map<String, Object?> j) {
    final srcs = [...?(j['srcs'] as List?)?.cast<String>()];
    final refs = [
      for (final r in (j['refs'] as List?) ?? const [])
        [for (final row in r as List) DeckRef.fromJson(row as List)],
    ];
    // `cats` — eyebrow boshlari (birinchi uchrash tartibida) kategoriyasi.
    final heads = <String>[];
    for (final s in (j['slides']! as List).cast<Map<String, Object?>>()) {
      final e = (s['eyebrow'] as String? ?? '').split(' · ').first.trim();
      if (e.isNotEmpty && !heads.contains(e)) heads.add(e);
    }
    final catList = [...?(j['cats'] as List?)?.cast<String>()];
    final cats = <String, String>{
      for (final (i, h) in heads.indexed)
        if (i < catList.length && catList[i].isNotEmpty) h: catList[i],
    };
    return LectureDeck(
      id: j['id'] as String?,
      title: j['title'] as String?,
      topics: [...?(j['topics'] as List?)?.cast<String>()],
      lang: j['lang']! as String,
      draft: (j['status'] ?? 'draft') == 'draft',
      slides: [
        for (final s in (j['slides']! as List).cast<Map<String, Object?>>())
          DeckSlide.fromJson(s, srcs: srcs, refs: refs, cats: cats),
      ],
    );
  }

  /// Katalog id'si (yangi decklarda; eski `d001.json` da yo'q) va sarlavha.
  final String? id;
  final String? title;
  final List<String> topics;

  /// Taqdimot tili (`uz`, `ru`, `en`).
  final String lang;
  final bool draft;
  final List<DeckSlide> slides;

  /// Deck bibliografiyasi: "Adabiyotlar" slaydlari (ixcham) bandlari
  /// ketma-ket, boshidagi "N. " raqamisiz. [DeckRef.index] shu ro'yxatga.
  List<String> get bibliography => [
    for (final s in slides)
      if (s.compact)
        for (final b in s.bullets) b.replaceFirst(RegExp(r'^\d+\.\s+'), ''),
  ];
}

/// Tayyor taqdimotlar (bir marta yuklanadi, bundle bo'yicha keshlanadi).
abstract final class LectureDecks {
  static final _cache = Expando<Future<Map<String, LectureDeck>>>();
  static final _loaded = Expando<Map<String, LectureDeck>>();

  static Future<Map<String, LectureDeck>> all(AssetBundle bundle) =>
      _cache[bundle] ??= _load(bundle).then((m) => _loaded[bundle] = m);

  /// Yuklangan bo'lsa — darhol (birinchi kadrda) qaytaradi.
  static Map<String, LectureDeck>? peek(AssetBundle bundle) => _loaded[bundle];

  static Future<LectureDeck?> forTopic(
    AssetBundle bundle,
    String topicId,
  ) async => (await all(bundle))[topicId];

  static Future<Map<String, LectureDeck>> _load(AssetBundle bundle) async {
    final byTopic = <String, LectureDeck>{};
    final index = jsonDecode(
      await bundle.loadString('assets/lectures/index.json'),
    ) as Map<String, Object?>;
    for (final f in (index['decks']! as List).cast<String>()) {
      final deck = LectureDeck.fromJson(
        jsonDecode(await bundle.loadString('assets/lectures/$f'))
            as Map<String, Object?>,
      );
      for (final t in deck.topics) {
        byTopic[t] = deck;
      }
    }
    return byTopic;
  }
}
