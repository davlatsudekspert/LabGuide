import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/storage/kv_store.dart';
import 'diff_eyes_free_settings.dart';
import 'differential_content.dart';

/// Sanash natijasi (tarixdagi bitta yozuv yoki joriy sanash).
@immutable
class DiffRecord {
  const DiffRecord({
    required this.id,
    required this.savedAt,
    required this.target,
    required this.counts,
    this.wbc,
    this.label = '',
  });

  factory DiffRecord.fromJson(Map<String, Object?> json) {
    final raw = (json['counts'] as Map).cast<String, Object?>();
    return DiffRecord(
      id: json['id']! as String,
      savedAt: DateTime.parse(json['at']! as String),
      target: json['target']! as int,
      counts: {
        for (final c in DiffCell.values)
          if (raw[c.name] case final int n when n > 0) c: n,
      },
      wbc: (json['wbc'] as num?)?.toDouble(),
      label: json['label'] as String? ?? '',
    );
  }

  final String id;
  final DateTime savedAt;
  final int target;
  final Map<DiffCell, int> counts;

  /// Umumiy leykotsitlar, ×10⁹/L (ixtiyoriy).
  final double? wbc;

  /// Ixtiyoriy belgi (namuna raqami) — bemor ismi yozilmasin.
  final String label;

  int get total => counts.values.fold(0, (a, b) => a + b);

  int count(DiffCell c) => counts[c] ?? 0;

  /// Ulush foizda (jami 0 bo'lsa — 0).
  double percent(DiffCell c) => total == 0 ? 0 : count(c) * 100 / total;

  /// Mutlaq son ×10⁹/L: ulush × WBC (WBC kiritilmagan bo'lsa — null).
  double? absolute(DiffCell c) =>
      wbc == null || total == 0 ? null : count(c) / total * wbc!;

  Map<String, Object?> toJson() => {
    'id': id,
    'at': savedAt.toIso8601String(),
    'target': target,
    'counts': {for (final e in counts.entries) e.key.name: e.value},
    'wbc': ?wbc,
    if (label.isNotEmpty) 'label': label,
  };
}

/// Bosish natijasi (UI tebranish/xabar uchun).
enum TapOutcome { added, completed, blocked }

/// Qo'lda leykoformula sanash: joriy sanash (qoralama) va tarix — faqat
/// qurilmada. Sanash, foiz va mutlaq sonlar doim bepul: bu yerda hech
/// qanday to'lov tekshiruvi yo'q va bo'lmasligi kerak ([StoreKeys.differentialDraft], [StoreKeys.differentialHistory]).
class DifferentialController extends ChangeNotifier {
  DifferentialController(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _load();
  }

  static const targets = [100, 200];

  final KeyValueStore _store;
  final DateTime Function() _clock;

  final Map<DiffCell, int> _counts = {};

  /// "Bekor qilish" uchun bosishlar ketma-ketligi.
  final List<DiffCell> _undo = [];
  int _target = 100;
  double? _wbc;
  final List<DiffRecord> _history = [];
  EyesFreeSettings _eyesFree = const EyesFreeSettings();

  int get target => _target;
  double? get wbc => _wbc;
  int count(DiffCell c) => _counts[c] ?? 0;
  int get total => _counts.values.fold(0, (a, b) => a + b);
  bool get isComplete => total >= _target;
  bool get canUndo => _undo.isNotEmpty;
  bool get isEmpty => total == 0;
  List<DiffRecord> get history => List.unmodifiable(_history);

  /// "Ko'rmasdan sanash" rejimi sozlamalari.
  EyesFreeSettings get eyesFree => _eyesFree;

  Future<void> setEyesFree(EyesFreeSettings s) async {
    _eyesFree = s;
    notifyListeners();
    await _store.setString(StoreKeys.differentialEyesFree, encodeEyesFree(s));
  }

  /// Joriy sanash yozuv ko'rinishida (natija jadvali, nusxalash).
  DiffRecord get current => DiffRecord(
    id: 'current',
    savedAt: _clock(),
    target: _target,
    counts: Map.of(_counts),
    wbc: _wbc,
  );

  /// +1. Maqsadga yetilgach yangi bosish qabul qilinmaydi.
  TapOutcome tap(DiffCell c) {
    if (isComplete) return TapOutcome.blocked;
    _counts[c] = count(c) + 1;
    _undo.add(c);
    _changed();
    return isComplete ? TapOutcome.completed : TapOutcome.added;
  }

  /// −1 (uzoq bosish). Shu turdagi oxirgi bosish ham tarixdan olinadi.
  bool decrement(DiffCell c) {
    if (count(c) == 0) return false;
    _counts[c] = count(c) - 1;
    if (_counts[c] == 0) _counts.remove(c);
    final i = _undo.lastIndexOf(c);
    if (i >= 0) _undo.removeAt(i);
    _changed();
    return true;
  }

  /// Oxirgi bosishni bekor qilish.
  DiffCell? undo() {
    if (_undo.isEmpty) return null;
    final c = _undo.removeLast();
    _counts[c] = count(c) - 1;
    if (_counts[c] == 0) _counts.remove(c);
    _changed();
    return c;
  }

  /// Maqsad (100/200). Allaqachon sanalganidan kam maqsad tanlanmaydi.
  bool setTarget(int t) {
    if (!targets.contains(t) || t < total || t == _target) return false;
    _target = t;
    _changed();
    return true;
  }

  void setWbc(double? v) {
    final next = v == null || v <= 0 || !v.isFinite ? null : v;
    if (next == _wbc) return;
    _wbc = next;
    _changed();
  }

  /// Joriy sanashni tozalash (maqsad va WBC saqlanib qoladi).
  void reset() {
    _counts.clear();
    _undo.clear();
    _changed();
  }

  /// Joriy natijani tarixga yozish (yangisi birinchi).
  Future<DiffRecord?> save({String label = ''}) async {
    if (isEmpty) return null;
    final now = _clock();
    final record = DiffRecord(
      id: now.microsecondsSinceEpoch.toString(),
      savedAt: now,
      target: _target,
      counts: Map.of(_counts),
      wbc: _wbc,
      label: label.trim(),
    );
    // Tarix hech qachon yashirincha qisqartirilmaydi — faqat foydalanuvchi
    // o'chiradi. Ko'rsatish chegarasi (bo'lsa) UI'da: DiffEntryPoints.
    _history.insert(0, record);
    notifyListeners();
    await _persistHistory();
    return record;
  }

  DiffRecord? record(String id) {
    for (final r in _history) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> delete(String id) async {
    _history.removeWhere((r) => r.id == id);
    notifyListeners();
    await _persistHistory();
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    await _store.remove(StoreKeys.differentialHistory);
  }

  /// "Lokal ma'lumotlarni o'chirish" dan keyin.
  void resetInMemory() {
    _counts.clear();
    _undo.clear();
    _history.clear();
    _target = 100;
    _wbc = null;
    _eyesFree = const EyesFreeSettings();
    notifyListeners();
  }

  void _changed() {
    notifyListeners();
    _store.setString(
      StoreKeys.differentialDraft,
      jsonEncode({
        'target': _target,
        'wbc': ?_wbc,
        'taps': [for (final c in _undo) c.name],
      }),
    );
  }

  Future<void> _persistHistory() => _store.setString(
    StoreKeys.differentialHistory,
    jsonEncode([for (final r in _history) r.toJson()]),
  );

  void _load() {
    _eyesFree = decodeEyesFree(
      _store.getString(StoreKeys.differentialEyesFree),
    );
    try {
      final raw = _store.getString(StoreKeys.differentialDraft);
      if (raw != null) {
        final json = (jsonDecode(raw) as Map).cast<String, Object?>();
        final t = json['target'] as int? ?? 100;
        _target = targets.contains(t) ? t : 100;
        _wbc = (json['wbc'] as num?)?.toDouble();
        for (final name in (json['taps'] as List? ?? const []).cast<String>()) {
          final c = DiffCell.values.asNameMap()[name];
          if (c == null || total >= _target) continue;
          _undo.add(c);
          _counts[c] = count(c) + 1;
        }
      }
    } on Object {
      // Buzilgan qoralama — yangidan boshlanadi.
      _counts.clear();
      _undo.clear();
    }
    try {
      final raw = _store.getString(StoreKeys.differentialHistory);
      if (raw != null) {
        for (final e in jsonDecode(raw) as List) {
          _history.add(DiffRecord.fromJson((e as Map).cast<String, Object?>()));
        }
      }
    } on Object {
      _history.clear();
    }
  }
}
