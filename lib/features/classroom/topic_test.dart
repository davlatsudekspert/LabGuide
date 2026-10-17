import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/storage/kv_store.dart';
import '../content/analyte_search.dart';
import '../content/content_model.dart';
import '../learn/exam_question.dart';
import '../learn/exam_session.dart';
import '../toifa/toifa_bank.dart';
import 'curriculum.dart';
import 'lecture_catalog.dart';

// Mavzu testi: har taqdimot (deck) oxirida — shu mavzuga bog'langan FAQAT
// tekshirilgan savollardan 10 ta (kamroq bo'lsa — boricha; 3 tadan kam
// bo'lsa — “savollar tayyorlanmoqda”). Savol o'ylab topilmaydi:
//
// * toifa banki — curriculum `test_candidates.ids` dagi, rasmiy kaliti bor
//   (`scorable`), LabGuide tekshiruvi `ok` va izohi tasdiqlangan savollar;
// * kontent paketi — `test_candidates.pack_quiz_ids` dagi, manbasi (`refs`)
//   ko'rsatilgan mashq savollari.
//
// Variantlari takrorlanadigan savol (biror tilda ikki variant bir xil)
// testga qo'yilmaydi. Natijalar va boshlangan test faqat qurilmada.

/// Bir testdagi savollar soni (kamroq bo'lsa — boricha).
const kTopicTestSize = 10;

/// Shundan kam tekshirilgan savol bo'lsa — test o'tkazilmaydi.
const kTopicTestMin = 3;

/// Har mavzu bo'yicha saqlanadigan natijalar soni.
const kTopicTestHistory = 20;

/// Savol testga qo'yilishi mumkinmi: bitta to'g'ri javob, takrorlanmaydigan
/// variantlar va tekshirilgan kalit.
bool isVerifiedTopicQuestion(ExamQuestion q) {
  if (q.correct.length != 1 || q.optionCount < 2) return false;
  if (!hasUniqueOptions(q)) return false;
  return switch (q) {
    final ToifaTestQuestion t =>
      t.scorable &&
          t.keyCheck.verdict == KeyVerdict.ok &&
          !t.keyCheck.unverified,
    final PackExamQuestion p => p.quiz.refs.isNotEmpty,
    _ => false,
  };
}

/// Har tilda variantlar matni bir-biridan farq qiladi.
bool hasUniqueOptions(ExamQuestion q) {
  for (final lang in kDeckLangs) {
    final seen = <String>{};
    for (var i = 0; i < q.optionCount; i++) {
      final t = normalizeForSearch(q.option(i, lang));
      if (t.isEmpty || !seen.add(t)) return false;
    }
  }
  return true;
}

/// Bitta o'quv dasturi mavzusining tekshirilgan savollari (curriculum
/// tartibida: avval toifa, keyin paket), takrorsiz.
List<ExamQuestion> verifiedTopicQuestions(
  CurriculumTopic topic,
  ContentPack? pack,
  ToifaBank? bank,
) {
  final out = <ExamQuestion>[];
  final seen = <String>{};
  void add(ExamQuestion? q) {
    if (q != null && isVerifiedTopicQuestion(q) && seen.add(q.id)) out.add(q);
  }

  if (bank != null) {
    for (final id in topic.testCandidates) {
      add(bank.test(id));
    }
  }
  if (pack != null) {
    final source = PackQuestionSource.of(pack);
    for (final id in topic.packQuizCandidates) {
      add(source.question(id));
    }
  }
  return out;
}

/// Deck savollari: deckga biriktirilgan barcha mavzular (ma'ruza va
/// amaliyot) bo'yicha, takrorsiz. Mavzusiz deck (amaliy protokol) — bo'sh.
List<ExamQuestion> deckQuestionPool(
  DeckEntry deck,
  Curriculum? curriculum,
  ContentPack? pack,
  ToifaBank? bank,
) {
  if (curriculum == null) return const [];
  final out = <ExamQuestion>[];
  final seen = <String>{};
  for (final id in deck.topics) {
    final t = curriculum.topic(id);
    if (t == null) continue;
    for (final q in verifiedTopicQuestions(t, pack, bank)) {
      if (seen.add(q.id)) out.add(q);
    }
  }
  return out;
}

enum DeckTestState {
  /// Deck hech qaysi mavzuga bog'lanmagan — tugma ko'rsatilmaydi.
  hidden,

  /// Mavzu bor, lekin tekshirilgan savol [kTopicTestMin] dan kam.
  preparing,
  ready,
}

DeckTestState deckTestState(DeckEntry deck, List<ExamQuestion> pool) =>
    deck.topics.isEmpty
    ? DeckTestState.hidden
    : pool.length < kTopicTestMin
    ? DeckTestState.preparing
    : DeckTestState.ready;

/// Pul (bank) yuklangan nusxalar bo'yicha keshlangan hovuz: ro'yxatda har
/// qator uchun qayta hisoblanmaydi.
class DeckPools {
  DeckPools._(this.curriculum, this.pack, this.bank);

  static DeckPools of(Curriculum? c, ContentPack? p, ToifaBank? b) {
    final last = _last;
    if (last != null &&
        identical(last.curriculum, c) &&
        identical(last.pack, p) &&
        identical(last.bank, b)) {
      return last;
    }
    return _last = DeckPools._(c, p, b);
  }

  static DeckPools? _last;

  final Curriculum? curriculum;
  final ContentPack? pack;
  final ToifaBank? bank;
  final _cache = <String, List<ExamQuestion>>{};

  /// Hamma manba yuklangan (aks holda natija to'liq emas).
  bool get complete => curriculum != null && pack != null && bank != null;

  List<ExamQuestion> pool(DeckEntry deck) => _cache[deck.id] ??=
      List.unmodifiable(deckQuestionPool(deck, curriculum, pack, bank));

  DeckTestState state(DeckEntry deck) => deckTestState(deck, pool(deck));
}

/// [pool] dan [count] ta savol: id bo'yicha tartiblab, [seed] bilan
/// aralashtiriladi — bir xil urug' har doim bir xil test beradi.
List<ExamQuestion> drawTopicTest(
  List<ExamQuestion> pool, {
  int count = kTopicTestSize,
  required int seed,
}) {
  final sorted = [...pool]..sort((a, b) => a.id.compareTo(b.id));
  sorted.shuffle(Random(seed));
  return sorted.take(count.clamp(0, sorted.length)).toList();
}

/// Test sessiyasi: savollar [questions] tartibida; paket savollarida
/// variantlar [seed] bilan aralashtiriladi, rasmiy (toifa) savollarda — asl
/// tartib (“Hammasi to'g'ri” kabi variantlar o'z o'rnida qoladi).
ExamSession buildTopicTestSession({
  required String id,
  required List<ExamQuestion> questions,
  required int seed,
  required DateTime startedAt,
  required String title,
  ExamMode mode = ExamMode.exam,
}) {
  final random = Random(seed);
  return ExamSession(
    id: id,
    mode: mode,
    sourceId: TopicTestController.sourceId,
    startedAt: startedAt,
    title: title,
    items: [
      for (final (i, q) in questions.indexed)
        ExamItem(
          questionId: q.id,
          order: q is OfficialKeyQuestion
              ? List.generate(q.optionCount, (k) => k)
              : (List.generate(q.optionCount, (k) => k)..shuffle(random)),
          correct: q.correct.toList()..sort(),
          position: i,
          topicIds: q.topicIds,
        ),
    ],
  );
}

// =============================================================================
// Natija
// =============================================================================

/// Bitta urinish natijasi (tarix va “eng yaxshi natija” belgisi uchun).
@immutable
class TopicTestResult {
  const TopicTestResult({
    required this.correct,
    required this.total,
    required this.at,
    this.rework = false,
  });

  factory TopicTestResult.of(ExamSession s, DateTime at) => TopicTestResult(
    correct: s.correctCount,
    total: s.length,
    at: s.finishedAt ?? at,
    rework: s.mode == ExamMode.rework,
  );

  factory TopicTestResult.fromJson(Map<String, Object?> j) => TopicTestResult(
    correct: j['c']! as int,
    total: j['t']! as int,
    at: DateTime.parse(j['at']! as String),
    rework: j['r'] == true,
  );

  final int correct;
  final int total;
  final DateTime at;

  /// Xatolar ustida ishlash (eng yaxshi natijaga kirmaydi).
  final bool rework;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  Map<String, Object?> toJson() => {
    'c': correct,
    't': total,
    'at': at.toUtc().toIso8601String(),
    if (rework) 'r': true,
  };
}

/// Eng yaxshi natija (foiz bo'yicha; teng bo'lsa — ko'proq savolli, keyin
/// yangirog'i). Xatolar ustida ishlash hisobga olinmaydi.
TopicTestResult? bestResult(Iterable<TopicTestResult> results) {
  TopicTestResult? best;
  for (final r in results) {
    if (r.rework) continue;
    if (best == null ||
        r.percent > best.percent ||
        (r.percent == best.percent && r.total > best.total)) {
      best = r;
    }
  }
  return best;
}

// =============================================================================
// Holat (qurilmada)
// =============================================================================

/// Mavzu testlari: har deck uchun boshlangan test (qoralama), oxirgi
/// yakunlangan urinish (xatolar tahlili uchun) va natijalar tarixi. Har
/// o'zgarishdan keyin darhol yoziladi — ilova yopilsa ham test davom etadi.
/// Boshqa imtihonlarga (ExamController) tegmaydi: mavzu testi boshlansa,
/// davom etayotgan imtihon yoki boshqa mavzu testi to'xtamaydi.
class TopicTestController extends ChangeNotifier {
  TopicTestController(this._store, {DateTime Function()? clock, Random? random})
    : now = clock ?? DateTime.now,
      random = random ?? Random() {
    _load();
  }

  /// Sessiya manbasi id si (ExamSession.sourceId).
  static const sourceId = 'topic';

  final KeyValueStore _store;
  DateTime Function() now;
  Random random;

  final Map<String, ExamSession> _drafts = {};
  final Map<String, ExamSession> _last = {};
  final Map<String, List<TopicTestResult>> _history = {};

  ExamSession? draft(String deckId) => _drafts[deckId];
  ExamSession? last(String deckId) => _last[deckId];
  List<TopicTestResult> history(String deckId) =>
      List.unmodifiable(_history[deckId] ?? const []);
  TopicTestResult? best(String deckId) => bestResult(history(deckId));

  /// Yangi urug' (savollar tanlovi va variantlar tartibi uchun).
  int nextSeed() => random.nextInt(1 << 31);

  String newId() =>
      '${now().microsecondsSinceEpoch.toRadixString(36)}'
      '${random.nextInt(1 << 20).toRadixString(36)}';

  void _load() {
    final raw = _store.getString(StoreKeys.topicTests);
    if (raw == null) return;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      ExamSession? session(Object? v) {
        try {
          return ExamSession.fromJson((v! as Map).cast<String, Object?>());
        } on Object {
          return null; // bitta buzilgan yozuv qolganlarini o'chirmaydi
        }
      }

      for (final e in ((j['drafts'] as Map?) ?? const {}).entries) {
        if (session(e.value) case final s?) _drafts['${e.key}'] = s;
      }
      for (final e in ((j['last'] as Map?) ?? const {}).entries) {
        if (session(e.value) case final s?) _last['${e.key}'] = s;
      }
      for (final e in ((j['history'] as Map?) ?? const {}).entries) {
        _history['${e.key}'] = [
          for (final r in (e.value as List? ?? const []))
            if (r is Map) TopicTestResult.fromJson(r.cast<String, Object?>()),
        ];
      }
    } on Object catch (e) {
      debugPrint('topic tests: $e');
    }
  }

  Future<void> _save() async {
    notifyListeners();
    await _store.setString(
      StoreKeys.topicTests,
      jsonEncode({
        'drafts': {for (final e in _drafts.entries) e.key: e.value.toJson()},
        'last': {for (final e in _last.entries) e.key: e.value.toJson()},
        'history': {
          for (final e in _history.entries)
            e.key: [for (final r in e.value) r.toJson()],
        },
      }),
    );
  }

  /// Yangi test (shu deckning yakunlanmagan testi o'rniga — faqat foydalanuvchi
  /// “Qayta topshirish”/“Xatolarni takrorlash”ni bosganda).
  Future<void> start(String deckId, ExamSession session) {
    _drafts[deckId] = session;
    return _save();
  }

  /// Javob yoki joriy savol o'zgardi.
  Future<void> save(String deckId, ExamSession session) {
    if (!identical(_drafts[deckId], session)) return Future.value();
    return _save();
  }

  /// Testni yakunlaydi: natija tarixga, sessiya — xatolar tahlili uchun.
  Future<TopicTestResult?> finish(String deckId) async {
    final s = _drafts.remove(deckId);
    if (s == null) return null;
    s.finish(now());
    _last[deckId] = s;
    final r = TopicTestResult.of(s, now());
    final h = _history[deckId] ??= [];
    h.insert(0, r);
    if (h.length > kTopicTestHistory) {
      h.removeRange(kTopicTestHistory, h.length);
    }
    await _save();
    return r;
  }

  Future<void> discard(String deckId) async {
    if (_drafts.remove(deckId) == null) return;
    await _save();
  }

  void resetInMemory() {
    _drafts.clear();
    _last.clear();
    _history.clear();
    notifyListeners();
  }
}

// =============================================================================
// Savol → slayd
// =============================================================================

/// Savol bilan slayd sarlavhasini solishtirishda e'tiborsiz qoldiriladigan
/// umumiy so'zlar (savol so'zlari, bog'lovchilar).
const _stop = {
  'qaysi',
  'qanday',
  'nima',
  'nimaga',
  'quyidagi',
  'quyidagilardan',
  'hammasi',
  'yuqorida',
  'aytilganlarning',
  'barchasi',
  'uchun',
  'bilan',
  'hisoblanadi',
  'boladi',
  'bolib',
  'kerak',
  'mumkin',
  'emas',
  'asosiy',
  'which',
  'what',
  'following',
  'with',
  'from',
  'that',
  'this',
  'there',
  'these',
  'those',
  'than',
  'into',
  'used',
  'when',
  'above',
  'none',
  'only',
  'какой',
  'какая',
  'какие',
  'каких',
  'какое',
  'следующих',
  'является',
  'являются',
  'выше',
  'перечисленное',
  'перечисленные',
  'всего',
  'более',
  'менее',
  'только',
  'чтобы',
  'когда',
  'если',
  'который',
  'которая',
  'laboratoriya',
  'laboratory',
  'лаборатория',
  'tahlil',
  'analysis',
  'анализ',
  'usul',
  'method',
  'метод',
  'natija',
  'result',
  'результат',
};

/// Deckning umumiy slaydlari (reja, mini-test, manbalar) — savolga bog'lanmaydi.
final _generic = RegExp(
  r'^(dars maqsadi|dars rejasi|protokol rejasi|mini test|nazorat savollari|'
  r'manbalar|adabiyotlar|plan|lesson plan|protocol plan|sources|references|'
  r'literature|review questions|цель|план|мини тест|контрольные вопросы|'
  r'источники|литература)',
);

List<String> _tokens(String s) => [
  for (final t in normalizeForSearch(s).split(' '))
    if (t.length >= 4 && !_stop.contains(t)) t,
];

/// O'zbekcha qo'shimchalar (-lar, -ning, -da...) va ruscha kelishiklar uchun:
/// bir so'z boshqasining boshi (kamida 5 harf) yoki umumiy boshi ≥ 7 harf.
bool _sameWord(String a, String b) {
  if (a == b) return true;
  final n = min(a.length, b.length);
  if (n >= 5 && (a.startsWith(b) || b.startsWith(a))) return true;
  var k = 0;
  while (k < n && a.codeUnitAt(k) == b.codeUnitAt(k)) {
    k++;
  }
  return k >= 7;
}

/// Savol uchun eng mos slayd (deck faylidagi indeks). Ishonchli moslik
/// bo'lmasa — null (deck boshidan ochiladi).
///
/// Ball: slayd sarlavhasida savolga bog'langan analit nomi to'liq bo'lsa
/// +3; savol matni va to'g'ri javobdagi har mos so'z +1. Ishonchli: ball ≥ 2
/// va boshqa sarlavhali har slayddan yuqori (teng bo'lsa — deck boshi).
int? matchSlide(
  ExamQuestion q,
  DeckEntry deck,
  String lang, {
  List<String> Function(String analyteId, String lang)? analyteNames,
}) {
  final shown = deck.resolveLang(lang);
  final runs = deck.runs[shown] ?? deck.runs['uz'] ?? const <SlideRun>[];
  if (runs.isEmpty) return null;
  final words = <String>{
    ..._tokens(q.prompt(shown)),
    for (final c in q.correct)
      if (c >= 0 && c < q.optionCount) ..._tokens(q.option(c, shown)),
  };
  final analyteIds = switch (q) {
    final ToifaTestQuestion t => t.analytes,
    final PackExamQuestion p => p.quiz.topicIds,
    _ => const <String>[],
  };
  final names = [
    if (analyteNames != null)
      for (final a in analyteIds)
        for (final n in analyteNames(a, shown))
          if (_tokens(n).isNotEmpty) _tokens(n),
  ];
  final scores = <int>[];
  for (final r in runs) {
    // Savol slaydlari (mini-test, og'zaki savol rejasi — sarlavha “?”/“:” bilan
    // tugaydi) va umumiy slaydlar mavzu mazmuni emas: ularga bog'lanmaydi.
    final t = r.title.trim();
    final skip =
        t.endsWith('?') ||
        t.endsWith(':') ||
        _generic.hasMatch(normalizeForSearch(t));
    final title = skip ? const <String>[] : _tokens(t);
    var score = 0;
    if (title.isNotEmpty) {
      for (final n in names) {
        if (n.every((w) => title.any((t) => _sameWord(w, t)))) {
          score += 3;
          break;
        }
      }
      for (final w in words) {
        if (title.any((t) => _sameWord(w, t))) score++;
      }
    }
    scores.add(score);
  }
  var bestRun = 0;
  for (var i = 1; i < scores.length; i++) {
    if (scores[i] > scores[bestRun]) bestRun = i;
  }
  final best = scores[bestRun];
  if (best == 0) return null;
  // Raqib — boshqa sarlavhali slaydlardagi eng yuqori ball (bir tahlilning
  // ketma-ket slaydlari raqib emas).
  var second = 0;
  for (var i = 0; i < scores.length; i++) {
    if (runs[i].title != runs[bestRun].title && scores[i] > second) {
      second = scores[i];
    }
  }
  final confident = best >= 2 && best > second;
  return confident ? runs[bestRun].first : null;
}

/// Kontent paketidagi analit nomlari va sinonimlari (slayd moslash uchun).
List<String> Function(String, String) packAnalyteNames(ContentPack? pack) =>
    (id, lang) {
      final a = pack?.analyte(id);
      if (a == null) return const [];
      return [a.names.of(lang), if (lang != 'uz') a.names.of('uz')];
    };
