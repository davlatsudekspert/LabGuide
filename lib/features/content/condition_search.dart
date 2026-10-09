import 'analyte_search.dart';
import 'content_model.dart';

/// Shifokor qo'llanmasi qidiruvi: holat nomlari (uch tilda), so'zlashuv
/// sinonimlari va paneldagi tahlil nomlari bo'yicha. Tahlil nomi bo'yicha
/// moslik pastroq baholanadi — “TSH” so'rovida avval nomi mos holatlar,
/// keyin TSH buyuriladigan holatlar chiqadi.
class ConditionSearch {
  ConditionSearch(this.pack)
    : _names = {
        for (final c in pack.conditions)
          c.id: SearchEntry(
            {
              for (final e in c.names.values.entries)
                e.key: normalizeForSearch(e.value),
            },
            [for (final s in c.synonyms) normalizeForSearch(s)],
          ),
      },
      _tests = {
        for (final c in pack.conditions)
          c.id: SearchEntry(const {}, [
            for (final t in c.panel)
              for (final n in t.names.all) normalizeForSearch(n),
          ]),
      };

  final ContentPack pack;
  final Map<String, SearchEntry> _names;
  final Map<String, SearchEntry> _tests;

  /// [query] bo'sh bo'lsa — tizim bo'yicha filtrlangan to'liq ro'yxat
  /// (paket tartibida). Aks holda moslik bo'yicha tartiblanadi.
  List<ClinicalCondition> search(
    String query, {
    ConditionSystem? system,
    required String lang,
  }) {
    final q = normalizeForSearch(query);
    final candidates = pack.conditions.where(
      (c) => system == null || c.system == system,
    );
    if (q.isEmpty) return candidates.toList();
    final queries = searchVariants(q);
    final scored = <(ClinicalCondition, int)>[];
    for (final c in candidates) {
      final byName = _names[c.id]!.bestScore(queries, lang);
      // Tahlil nomi bo'yicha moslik — nom mosligidan doim pastda.
      final byTest = _tests[c.id]!.bestScore(queries, lang) ~/ 4;
      final score = byName > byTest ? byName : byTest;
      if (score > 0) scored.add((c, score));
    }
    scored.sort((x, y) {
      final byScore = y.$2.compareTo(x.$2);
      if (byScore != 0) return byScore;
      return x.$1.names.of(lang).compareTo(y.$1.names.of(lang));
    });
    return [for (final s in scored) s.$1];
  }
}
