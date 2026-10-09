import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/storage/kv_store.dart';
import 'daily_picker.dart';
import 'daily_streak.dart';

/// Ishga tushirishlar orasida o'zgarmaydigan xesh (String.hashCode
/// kafolatlanmagan).
int _stableHash(String s) =>
    s.codeUnits.fold(17, (h, c) => (h * 31 + c) & 0x3fffffff);

/// Kunlik savolga berilgan javob (asl variant indeksi).
@immutable
class DailyAnswer {
  const DailyAnswer(this.chosen, {required this.correct});

  final int chosen;
  final bool correct;
}

/// Bugungi to'plam: kun, savollar manbasi va id lari, berilgan javoblar.
class DailySet {
  DailySet({
    required this.day,
    required this.sourceId,
    required this.ids,
    Map<String, DailyAnswer>? answers,
  }) : answers = answers ?? {};

  factory DailySet.fromJson(Map<String, Object?> j) => DailySet(
    day: j['day']! as int,
    sourceId: j['src']! as String,
    ids: (j['ids']! as List).cast<String>(),
    answers: {
      for (final e in ((j['ans'] as Map?) ?? const {}).entries)
        e.key as String: switch (e.value) {
          [final int chosen, final bool correct] => DailyAnswer(
            chosen,
            correct: correct,
          ),
          _ => throw const FormatException('daily answer'),
        },
    },
  );

  final int day;
  final String sourceId;
  final List<String> ids;
  final Map<String, DailyAnswer> answers;

  bool get done => ids.isNotEmpty && ids.every(answers.containsKey);
  int get answeredCount => ids.where(answers.containsKey).length;
  int get correctCount =>
      ids.where((id) => answers[id]?.correct ?? false).length;

  /// Birinchi javobsiz savol (hammasi javoblangan bo'lsa — oxirgisi).
  int get nextIndex {
    final i = ids.indexWhere((id) => !answers.containsKey(id));
    return i < 0 ? ids.length - 1 : i;
  }

  Map<String, Object?> toJson() => {
    'day': day,
    'src': sourceId,
    'ids': ids,
    'ans': {
      for (final e in answers.entries) e.key: [e.value.chosen, e.value.correct],
    },
  };
}

/// Kunlik savol uchun savollar hovuzi (UI manbadan yig'adi).
@immutable
class DailyPool {
  const DailyPool({
    required this.sourceId,
    required this.priority,
    required this.others,
  });

  final String sourceId;
  final List<String> priority;
  final List<String> others;

  bool get isEmpty => priority.isEmpty && others.isEmpty;
}

/// Kunlik 5 ta savol va ketma-ketlik (streak). Hammasi faqat qurilmada.
class DailyController extends ChangeNotifier {
  DailyController(this._store, {DateTime Function()? clock, Random? random})
    : now = clock ?? DateTime.now,
      _random = random ?? Random() {
    _read();
  }

  /// Ko'p kunlik tarix saqlanmaydi: seriya uchun shu yetarli.
  static const keepDays = 400;

  final KeyValueStore _store;
  final Random _random;

  /// Soat (testlarda almashtiriladi).
  DateTime Function() now;

  int? _seed;
  final Set<int> _done = {};
  int _best = 0;
  DailySet? _set;

  int get today => dayOf(now());

  /// Joriy to'plam (bugungi bo'lmasa ham — [ensureToday] yangilaydi).
  DailySet? get current => _set;

  /// Bugungi to'plam (hali tuzilmagan bo'lsa — null).
  DailySet? get todaySet => _set?.day == today ? _set : null;

  Set<int> get doneDays => Set.unmodifiable(_done);

  StreakStats get streak => computeStreak(_done, today, storedBest: _best);

  /// Hech bo'lmasa bir kun bajarilgan.
  bool get everCompleted => _done.isNotEmpty;

  T? _json<T>(String key, T Function(Map<String, Object?> j) parse) {
    final raw = _store.getString(key);
    if (raw == null) return null;
    try {
      return parse((jsonDecode(raw) as Map).cast<String, Object?>());
    } on Object {
      // Buzilgan yozuv — yo'qdek (ilova yiqilmaydi).
      return null;
    }
  }

  void _read() {
    final s = _json(StoreKeys.dailyStreak, (j) => j);
    _seed = s?['seed'] as int?;
    _best = s?['best'] as int? ?? 0;
    _done
      ..clear()
      ..addAll(((s?['days'] as List?) ?? const []).whereType<int>());
    _set = _json(StoreKeys.dailyToday, DailySet.fromJson);
  }

  int get _deviceSeed => _seed ??= _random.nextInt(1 << 31);

  Future<void> _saveStreak() async {
    final days = _done.toList()..sort();
    final kept = days.length > keepDays
        ? days.sublist(days.length - keepDays)
        : days;
    await _store.setString(
      StoreKeys.dailyStreak,
      jsonEncode({'seed': _deviceSeed, 'best': _best, 'days': kept}),
    );
  }

  Future<void> _saveSet() async {
    final s = _set;
    if (s == null) {
      await _store.remove(StoreKeys.dailyToday);
    } else {
      await _store.setString(StoreKeys.dailyToday, jsonEncode(s.toJson()));
    }
  }

  /// Bugungi to'plam: kun ichida bir marta tuziladi va saqlanadi. Manba
  /// (masalan, til o'zgarib toifa banki yopilsa) faqat hali javob
  /// berilmagan bo'lsa almashadi. Hovuz bo'sh bo'lsa — null.
  DailySet? ensureToday(DailyPool pool, {bool Function(String id)? exists}) {
    final day = today;
    final s = _set;
    if (s != null && s.day == day) {
      final valid = exists == null || s.ids.every(exists);
      final sameSource = s.sourceId == pool.sourceId;
      if (valid && (sameSource || s.answers.isNotEmpty)) return s;
    }
    if (pool.isEmpty) return null;
    final seedNew = _seed == null;
    _set = DailySet(
      day: day,
      sourceId: pool.sourceId,
      ids: pickDaily(
        priority: exists == null ? pool.priority : pool.priority.where(exists),
        others: exists == null ? pool.others : pool.others.where(exists),
        day: day,
        seed: _deviceSeed ^ _stableHash(pool.sourceId),
      ),
    );
    // Build vaqtida chaqiriladi — tinglovchilar xabardor qilinmaydi.
    _saveSet();
    if (seedNew) _saveStreak();
    return _set;
  }

  /// Javob bir marta qabul qilinadi. To'plam tugasa — kun bajarilgan.
  /// Qaytaradi: shu javob bilan to'plam yakunlandi.
  Future<bool> answer(String id, int chosen, {required bool correct}) async {
    final s = _set;
    if (s == null || !s.ids.contains(id) || s.answers.containsKey(id)) {
      return false;
    }
    s.answers[id] = DailyAnswer(chosen, correct: correct);
    final finished = s.done;
    if (finished) {
      _done.add(s.day);
      final st = computeStreak(_done, today, storedBest: _best);
      _best = st.best;
    }
    notifyListeners();
    await _saveSet();
    if (finished) await _saveStreak();
    return finished;
  }

  /// "Lokal ma'lumotlarni o'chirish"dan keyin.
  void resetInMemory() {
    _seed = null;
    _best = 0;
    _done.clear();
    _set = null;
    notifyListeners();
  }
}
