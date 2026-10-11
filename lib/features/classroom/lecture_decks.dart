import 'dart:convert';

import 'package:flutter/services.dart';

// Tayyor (muallif yozgan) taqdimotlar: assets/lectures/index.json → har deck
// bir yoki bir nechta o'quv dasturi mavzusiga (topic id) biriktiriladi.
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
  });

  factory DeckSlide.fromJson(Map<String, Object?> j) => DeckSlide(
    title: j['title']! as String,
    eyebrow: j['eyebrow'] as String?,
    bullets: [...?(j['bullets'] as List?)?.cast<String>()],
    note: j['note'] as String?,
    source: j['source'] as String?,
    section: j['section'] == true,
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
}

class LectureDeck {
  const LectureDeck({
    required this.topics,
    required this.lang,
    required this.draft,
    required this.slides,
  });

  factory LectureDeck.fromJson(Map<String, Object?> j) => LectureDeck(
    topics: (j['topics']! as List).cast<String>(),
    lang: j['lang']! as String,
    draft: j['status'] != 'approved',
    slides: [
      for (final s in (j['slides']! as List).cast<Map<String, Object?>>())
        DeckSlide.fromJson(s),
    ],
  );

  final List<String> topics;

  /// Taqdimot tili (hozircha faqat `uz`).
  final String lang;
  final bool draft;
  final List<DeckSlide> slides;
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
