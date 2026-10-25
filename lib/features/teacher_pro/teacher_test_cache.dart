import 'dart:convert';

import '../../core/backend/teacher_tests.dart';
import '../../core/storage/kv_store.dart';

/// Ustoz testlari keshi (qurilmada; "Lokal ma'lumotni o'chirish" tozalaydi).
/// Ustoz ro'yxati internetsiz ham ko'rinadi (faqat oxirgi hisobniki — boshqa
/// hisob bilan kirilsa ko'rsatilmaydi); talabaning boshlangan urinishidagi
/// javoblar ilova yopilsa ham yo'qolmaydi.
class TeacherTestCache {
  TeacherTestCache(this._store);

  final KeyValueStore _store;

  /// Saqlanadigan ochiq urinishlar soni (eskisi o'chadi).
  static const maxAnswerSets = 20;

  Map<String, Object?> _read(String key) {
    final raw = _store.getString(key);
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map).cast<String, Object?>();
    } on Object {
      return {};
    }
  }

  List<TeacherTest>? tests(String? uid) {
    if (uid == null) return null;
    final m = _read(StoreKeys.teacherTestsCache);
    if (m['uid'] != uid) return null;
    try {
      return [
        for (final j in m['tests']! as List)
          TeacherTest.fromJson((j as Map).cast()),
      ];
    } on Object {
      return null;
    }
  }

  Future<void> saveTests(String? uid, List<TeacherTest> tests) async {
    if (uid == null) return;
    await _store.setString(
      StoreKeys.teacherTestsCache,
      jsonEncode({
        'uid': uid,
        'tests': [for (final t in tests) t.toJson()],
      }),
    );
  }

  /// To'liq testni (savollari bilan) ro'yxatdagi o'rniga yozadi.
  Future<void> putTest(String? uid, TeacherTest test) async {
    final list = [...?tests(uid)];
    final i = list.indexWhere((t) => t.id == test.id);
    if (i < 0) {
      list.insert(0, test);
    } else {
      list[i] = test;
    }
    await saveTests(uid, list);
  }

  Future<void> removeTest(String? uid, String id) async {
    final list = tests(uid);
    if (list == null) return;
    await saveTests(uid, [
      for (final t in list)
        if (t.id != id) t,
    ]);
  }

  TeacherTest? test(String? uid, String id) {
    for (final t in tests(uid) ?? const <TeacherTest>[]) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<int>? answers(String attemptId, int length) {
    final v = _read(StoreKeys.teacherTestAnswers)[attemptId];
    if (v is! List || v.length != length) return null;
    return [for (final a in v) a is int ? a : -1];
  }

  Future<void> saveAnswers(String attemptId, List<int> answers) async {
    final m = _read(StoreKeys.teacherTestAnswers)
      ..remove(attemptId)
      ..[attemptId] = answers;
    while (m.length > maxAnswerSets) {
      m.remove(m.keys.first);
    }
    await _store.setString(StoreKeys.teacherTestAnswers, jsonEncode(m));
  }

  Future<void> clearAnswers(String attemptId) async {
    final m = _read(StoreKeys.teacherTestAnswers);
    if (m.remove(attemptId) == null) return;
    await _store.setString(StoreKeys.teacherTestAnswers, jsonEncode(m));
  }
}
