import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/storage/kv_store.dart';

/// Og'zaki savol-javobda talabaga baho (faqat ustoz qurilmasida).
enum OralGrade {
  knew,
  partial,
  didNot;

  static OralGrade? tryParse(Object? raw) =>
      values.where((g) => g.name == raw).firstOrNull;
}

/// Ustoz qurilmasidagi dars ma'lumotlari. Hech biri serverga
/// yuborilmaydi: real ism (lokal belgi), og'zaki baholar va guruh
/// boshlanish sanasi faqat shu qurilmada (“Lokal ma'lumotlarni o'chirish”
/// bilan o'chadi).
class ClassroomLocal extends ChangeNotifier {
  ClassroomLocal(this._store) {
    _read();
  }

  final KeyValueStore _store;

  final Map<String, DateTime> _start = {};
  final Map<String, Map<String, String>> _names = {};
  final Map<String, Set<String>> _asked = {};
  final Map<String, Map<String, Map<String, OralGrade>>> _grades = {};

  static String _topicKey(String groupId, String topicId) =>
      '$groupId|$topicId';

  void _read() {
    final raw = _store.getString(StoreKeys.classroomLocal);
    if (raw == null) return;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      for (final e in ((j['start'] as Map?) ?? const {}).entries) {
        final d = DateTime.tryParse('${e.value}');
        if (d != null) _start['${e.key}'] = d;
      }
      for (final e in ((j['names'] as Map?) ?? const {}).entries) {
        _names['${e.key}'] = {
          for (final n in (e.value as Map).entries) '${n.key}': '${n.value}',
        };
      }
      for (final e in ((j['asked'] as Map?) ?? const {}).entries) {
        _asked['${e.key}'] = {for (final q in e.value as List) '$q'};
      }
      for (final e in ((j['grades'] as Map?) ?? const {}).entries) {
        _grades['${e.key}'] = {
          for (final q in (e.value as Map).entries)
            '${q.key}': {
              for (final u in (q.value as Map).entries)
                '${u.key}': ?OralGrade.tryParse(u.value),
            },
        };
      }
    } on Object catch (e) {
      debugPrint('classroom local: $e');
    }
  }

  Future<void> _save() async {
    notifyListeners();
    await _store.setString(
      StoreKeys.classroomLocal,
      jsonEncode({
        'start': {
          for (final e in _start.entries)
            e.key: e.value.toIso8601String().substring(0, 10),
        },
        'names': _names,
        'asked': {for (final e in _asked.entries) e.key: e.value.toList()},
        'grades': {
          for (final e in _grades.entries)
            e.key: {
              for (final q in e.value.entries)
                q.key: {for (final u in q.value.entries) u.key: u.value.name},
            },
        },
      }),
    );
  }

  /// Guruhning 1-o'quv kuni (jadval sanalari shundan).
  DateTime? startDate(String groupId) => _start[groupId];

  Future<void> setStartDate(String groupId, DateTime? date) {
    if (date == null) {
      _start.remove(groupId);
    } else {
      _start[groupId] = DateTime(date.year, date.month, date.day);
    }
    return _save();
  }

  /// Ustoz o'zi uchun yozgan belgi (masalan, real ism) — faqat qurilmada.
  String? localName(String groupId, String userId) => _names[groupId]?[userId];

  Future<void> setLocalName(String groupId, String userId, String? name) {
    final v = name?.trim() ?? '';
    final m = _names.putIfAbsent(groupId, () => {});
    if (v.isEmpty) {
      m.remove(userId);
    } else {
      m[userId] = v.length > 60 ? v.substring(0, 60) : v;
    }
    return _save();
  }

  bool asked(String groupId, String topicId, String questionId) =>
      _asked[_topicKey(groupId, topicId)]?.contains(questionId) ?? false;

  int askedCount(String groupId, String topicId) =>
      _asked[_topicKey(groupId, topicId)]?.length ?? 0;

  Future<void> setAsked(
    String groupId,
    String topicId,
    String questionId, {
    required bool value,
  }) {
    final s = _asked.putIfAbsent(_topicKey(groupId, topicId), () => {});
    value ? s.add(questionId) : s.remove(questionId);
    return _save();
  }

  OralGrade? grade(
    String groupId,
    String topicId,
    String questionId,
    String userId,
  ) => _grades[_topicKey(groupId, topicId)]?[questionId]?[userId];

  Map<String, OralGrade> grades(
    String groupId,
    String topicId,
    String questionId,
  ) => Map.unmodifiable(
    _grades[_topicKey(groupId, topicId)]?[questionId] ?? const {},
  );

  Future<void> setGrade(
    String groupId,
    String topicId,
    String questionId,
    String userId,
    OralGrade? grade,
  ) {
    final q = _grades
        .putIfAbsent(_topicKey(groupId, topicId), () => {})
        .putIfAbsent(questionId, () => {});
    grade == null ? q.remove(userId) : q[userId] = grade;
    return _save();
  }

  void resetInMemory() {
    _start.clear();
    _names.clear();
    _asked.clear();
    _grades.clear();
    notifyListeners();
  }
}
