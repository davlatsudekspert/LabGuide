import 'dart:convert';

import '../../core/backend/teacher_tests.dart';
import '../../core/storage/kv_store.dart';

/// Ustoz testlari keshi (qurilmada; "Lokal ma'lumotni o'chirish" tozalaydi).
/// Ustoz ro'yxati internetsiz ham ko'rinadi; talabaning boshlangan
/// urinishidagi javoblar ilova yopilsa ham yo'qolmaydi.
class TeacherTestCache {
  TeacherTestCache(this._store);

  final KeyValueStore _store;

  static String _testsKey(String uid) => 'teacherPro.tests.$uid';
  static String _answersKey(String attemptId) => 'teacherPro.answers.$attemptId';

  List<TeacherTest>? tests(String? uid) {
    if (uid == null) return null;
    final raw = _store.getString(_testsKey(uid));
    if (raw == null) return null;
    try {
      return [
        for (final j in jsonDecode(raw) as List)
          TeacherTest.fromJson((j as Map).cast()),
      ];
    } on Object {
      return null;
    }
  }

  Future<void> saveTests(String? uid, List<TeacherTest> tests) async {
    if (uid == null) return;
    await _store.setString(
      _testsKey(uid),
      jsonEncode([for (final t in tests) t.toJson()]),
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
    final raw = _store.getStringList(_answersKey(attemptId));
    if (raw == null || raw.length != length) return null;
    return [for (final v in raw) int.tryParse(v) ?? -1];
  }

  Future<void> saveAnswers(String attemptId, List<int> answers) =>
      _store.setStringList(_answersKey(attemptId), [
        for (final a in answers) '$a',
      ]);

  Future<void> clearAnswers(String attemptId) =>
      _store.remove(_answersKey(attemptId));
}
