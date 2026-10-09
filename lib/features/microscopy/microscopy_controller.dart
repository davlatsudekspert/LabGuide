import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/storage/kv_store.dart';
import 'microscopy_atlas.dart';

enum AtlasLoadState { loading, ready, failed }

/// “Bu nima?” mashqining eng yaxshi natijasi (bo'lim bo'yicha).
@immutable
class MicroQuizBest {
  const MicroQuizBest({
    required this.correct,
    required this.total,
    required this.at,
  });

  factory MicroQuizBest.fromJson(Map<String, Object?> j) => MicroQuizBest(
    correct: (j['correct']! as num).toInt(),
    total: (j['total']! as num).toInt(),
    at: DateTime.parse(j['at']! as String),
  );

  final int correct;
  final int total;
  final DateTime at;

  double get ratio => total == 0 ? 0 : correct / total;

  Map<String, Object?> toJson() => {
    'correct': correct,
    'total': total,
    'at': at.toIso8601String(),
  };
}

/// Mikroskopiya atlasi (ilova ichidagi manbali JSON) va mashq natijalari.
/// Natijalar faqat qurilmada saqlanadi.
class MicroscopyController extends ChangeNotifier {
  MicroscopyController(
    this._store, {
    required this.bundle,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _best = _readBest();
  }

  static const atlasAsset = 'assets/microscopy/atlas.json';

  /// Mashq doirasi: bo'lim id yoki hammasi.
  static const allScope = 'all';

  final KeyValueStore _store;
  final AssetBundle bundle;
  final DateTime Function() _clock;

  AtlasLoadState _state = AtlasLoadState.loading;
  MicroAtlas? _atlas;
  Future<void>? _loading;
  Map<String, MicroQuizBest> _best = const {};

  AtlasLoadState get state => _state;
  MicroAtlas? get atlas => _atlas;

  MicroQuizBest? best(String scope) => _best[scope];

  Map<String, MicroQuizBest> _readBest() {
    final raw = _store.getString(StoreKeys.microscopyQuiz);
    if (raw == null) return const {};
    try {
      return {
        for (final e in (jsonDecode(raw) as Map).entries)
          e.key as String: MicroQuizBest.fromJson(
            (e.value as Map).cast<String, Object?>(),
          ),
      };
    } on Object {
      // Buzilgan yozuv — natijalar yo'qdek (atlasga ta'sir qilmaydi).
      return const {};
    }
  }

  /// Atlas bir marta yuklanadi (ekran ochilganda).
  Future<void> ensureAtlas() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final raw = await bundle.loadString(atlasAsset);
      _atlas = MicroAtlas.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
      _state = AtlasLoadState.ready;
    } on Object catch (e) {
      debugPrint('microscopy atlas rejected: $e');
      _state = AtlasLoadState.failed;
      _loading = null;
    }
    notifyListeners();
  }

  Future<void> retry() {
    _state = AtlasLoadState.loading;
    _loading = null;
    notifyListeners();
    return ensureAtlas();
  }

  /// Raund natijasi. Eng yaxshi natija (ulush bo'yicha, teng bo'lsa — ko'proq
  /// savolli) saqlanadi. Yangi rekord bo'lsa `true`.
  Future<bool> recordResult(String scope, int correct, int total) async {
    if (total <= 0) return false;
    final prev = _best[scope];
    final next = MicroQuizBest(correct: correct, total: total, at: _clock());
    final better =
        prev == null ||
        next.ratio > prev.ratio ||
        (next.ratio == prev.ratio && total > prev.total);
    if (!better) return false;
    final updated = {..._best, scope: next};
    await _store.setString(
      StoreKeys.microscopyQuiz,
      jsonEncode({for (final e in updated.entries) e.key: e.value.toJson()}),
    );
    _best = Map.unmodifiable(updated);
    notifyListeners();
    return true;
  }

  /// “Lokal ma'lumotlarni o'chirish”dan keyin.
  void resetInMemory() {
    _best = const {};
    notifyListeners();
  }
}
