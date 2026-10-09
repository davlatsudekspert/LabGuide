import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/storage/kv_store.dart';
import 'exam_session.dart';

/// Imtihonlar: davom etayotgan imtihon, boshlangan guruh topshiriqlari va
/// natijalar tarixi. Hammasi faqat qurilmada; har o'zgarishdan keyin
/// darhol yoziladi — ilova fonda yopilsa ham holat yo'qolmaydi.
class ExamController extends ChangeNotifier {
  ExamController(this._store, {DateTime Function()? clock, Random? random})
    : now = clock ?? DateTime.now,
      random = random ?? Random() {
    _load();
  }

  final KeyValueStore _store;

  /// Soat va tasodif manbai (testlarda almashtiriladi).
  DateTime Function() now;
  Random random;

  /// Tarixda saqlanadigan natijalar soni.
  static const historyLimit = 50;

  ExamSession? _active;
  final Map<String, ExamSession> _assignments = {};
  final List<ExamSession> _history = [];

  /// Davom etayotgan (yakunlanmagan) oddiy imtihon.
  ExamSession? get active => _active;

  /// Yakunlangan imtihonlar — eng yangisi birinchi.
  List<ExamSession> get history => List.unmodifiable(_history);

  ExamSession? historyEntry(String id) =>
      _history.where((s) => s.id == id).firstOrNull;

  /// Shu hisob boshlagan topshiriq sessiyasi (boshqa hisobniki qaytmaydi).
  ExamSession? assignmentSession(String assignmentId, String? userId) {
    final s = _assignments[assignmentId];
    return s != null && s.userId == userId ? s : null;
  }

  String newId() =>
      '${now().microsecondsSinceEpoch.toRadixString(36)}'
      '${random.nextInt(1 << 20).toRadixString(36)}';

  void _load() {
    T? read<T>(String key, T Function(Object? json) parse) {
      final raw = _store.getString(key);
      if (raw == null) return null;
      try {
        return parse(jsonDecode(raw));
      } on Object {
        // Buzilgan yozuv — o'qilmaydi, ilova yiqilmaydi.
        return null;
      }
    }

    ExamSession parse(Object? j) =>
        ExamSession.fromJson((j! as Map).cast<String, Object?>());

    _active = read(StoreKeys.examActive, parse);
    _history.addAll(
      read(StoreKeys.examHistory, (j) {
            final out = <ExamSession>[];
            for (final e in j! as List) {
              try {
                out.add(parse(e));
              } on Object {
                // Bitta buzilgan yozuv qolganlarini o'chirmaydi.
              }
            }
            return out;
          }) ??
          const [],
    );
    _assignments.addAll(
      read(
            StoreKeys.examAssignments,
            (j) => {
              for (final e in (j! as Map).entries)
                e.key as String: parse(e.value),
            },
          ) ??
          const {},
    );
  }

  Future<void> _saveActive() async {
    final a = _active;
    if (a == null) {
      await _store.remove(StoreKeys.examActive);
    } else {
      await _store.setString(StoreKeys.examActive, jsonEncode(a.toJson()));
    }
  }

  Future<void> _saveHistory() => _store.setString(
    StoreKeys.examHistory,
    jsonEncode([for (final s in _history) s.toJson()]),
  );

  Future<void> _saveAssignments() => _store.setString(
    StoreKeys.examAssignments,
    jsonEncode({for (final e in _assignments.entries) e.key: e.value.toJson()}),
  );

  /// Yangi oddiy imtihon (oldingisi bo'lsa — bekor qilinadi).
  Future<void> start(ExamSession session) async {
    _active = session;
    notifyListeners();
    await _saveActive();
  }

  /// Javob, belgi yoki joriy savol o'zgardi — darhol yoziladi.
  Future<void> save(ExamSession session) async {
    notifyListeners();
    if (session.mode == ExamMode.assignment) {
      if (session.assignmentId != null) {
        _assignments[session.assignmentId!] = session;
        await _saveAssignments();
      }
    } else if (identical(session, _active)) {
      await _saveActive();
    }
  }

  /// Oddiy imtihonni yakunlab, tarixga qo'shadi.
  Future<ExamSession?> finishActive({bool timedOut = false}) async {
    final s = _active;
    if (s == null) return null;
    s.finish(now(), timedOut: timedOut);
    _active = null;
    _history.insert(0, s);
    if (_history.length > historyLimit) {
      _history.removeRange(historyLimit, _history.length);
    }
    notifyListeners();
    await _saveActive();
    await _saveHistory();
    return s;
  }

  /// Vaqti tugagan imtihon (masalan, ilova yopiq paytda) — halol yakun.
  Future<ExamSession?> settleExpired() async {
    final s = _active;
    if (s == null || !s.expired(now())) return null;
    return finishActive(timedOut: true);
  }

  Future<void> discardActive() async {
    if (_active == null) return;
    _active = null;
    notifyListeners();
    await _saveActive();
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    await _saveHistory();
  }

  Future<void> startAssignment(ExamSession session) async {
    _assignments[session.assignmentId!] = session;
    notifyListeners();
    await _saveAssignments();
  }

  /// Topshiriq yakunlandi (javoblar hali yuborilmagan bo'lishi mumkin).
  Future<void> finishAssignment(
    ExamSession session, {
    bool timedOut = false,
  }) async {
    session.finish(now(), timedOut: timedOut);
    await save(session);
  }

  /// Server javoblarni qabul qildi — lokal nusxa kerak emas.
  Future<void> removeAssignment(String assignmentId) async {
    if (_assignments.remove(assignmentId) == null) return;
    notifyListeners();
    await _saveAssignments();
  }

  void resetInMemory() {
    _active = null;
    _history.clear();
    _assignments.clear();
    notifyListeners();
  }
}
