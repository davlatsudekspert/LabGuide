import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/storage/kv_store.dart';
import 'toifa_bank.dart';

enum ToifaLoadState { loading, ready, failed }

/// Og'zaki savolga oxirgi baho va sanasi.
@immutable
class OralMark {
  const OralMark(this.rating, this.at);

  factory OralMark.fromJson(Map<String, Object?> j) => OralMark(
    OralRating.tryParse(j['r'] as String?) ?? OralRating.unknown,
    DateTime.parse(j['at']! as String),
  );

  final OralRating rating;
  final DateTime at;

  Map<String, Object?> toJson() => {
    'r': rating.name,
    'at': at.toUtc().toIso8601String(),
  };
}

/// Og'zaki bilet: 5 ta savol → tayyorlanish → har savol rejasini ko'rib
/// o'zini baholash. Ilova yopilsa ham davom ettiriladi.
class OralTicket {
  OralTicket({
    required this.category,
    required this.ids,
    required this.startedAt,
    Map<String, OralRating>? ratings,
    this.reviewing = false,
    this.revealed = false,
    this.index = 0,
  }) : ratings = ratings ?? {};

  factory OralTicket.fromJson(Map<String, Object?> j) {
    final ids = (j['ids']! as List).cast<String>();
    return OralTicket(
      category: ToifaCategory.tryParse(j['cat'] as String?)!,
      ids: ids,
      startedAt: DateTime.parse(j['started']! as String),
      ratings: {
        for (final e in ((j['ratings'] as Map?) ?? const {}).entries)
          e.key as String: ?OralRating.tryParse(e.value as String?),
      },
      reviewing: j['reviewing'] as bool? ?? false,
      revealed: j['revealed'] as bool? ?? false,
      index: (j['index'] as int? ?? 0).clamp(0, ids.length - 1),
    );
  }

  final ToifaCategory category;
  final List<String> ids;
  final DateTime startedAt;
  final Map<String, OralRating> ratings;

  /// Tayyorlanish tugadi — savollar birma-bir ko'rib chiqilmoqda.
  bool reviewing;

  /// Joriy savol rejasi ochilgan.
  bool revealed;
  int index;

  String get currentId => ids[index];
  bool get done => ratings.length >= ids.length;
  int count(OralRating r) => ratings.values.where((v) => v == r).length;

  Map<String, Object?> toJson() => {
    'cat': category.id,
    'ids': ids,
    'started': startedAt.toUtc().toIso8601String(),
    'ratings': {for (final e in ratings.entries) e.key: e.value.name},
    'reviewing': reviewing,
    'revealed': revealed,
    'index': index,
  };
}

/// Toifa imtihoniga tayyorgarlik: banklar (ilova ichidagi asset), tanlangan
/// toifa, og'zaki bilet va baholar, test sozlamalari. Test javoblari umumiy
/// mashq tarixiga ([QuizProgressController]) yoziladi. Hammasi faqat qurilmada.
class ToifaController extends ChangeNotifier {
  ToifaController(
    this._store, {
    required this.bundle,
    DateTime Function()? clock,
    Random? random,
  }) : now = clock ?? DateTime.now,
       random = random ?? Random() {
    _read();
  }

  static const testsAsset = 'assets/toifa/kdl_tests.json';
  static const oralAsset = 'assets/toifa/kdl_oral.json';

  final KeyValueStore _store;
  final AssetBundle bundle;

  /// Soat va tasodif (testlarda almashtiriladi).
  DateTime Function() now;
  Random random;

  ToifaLoadState _state = ToifaLoadState.loading;
  ToifaBank? _bank;
  Future<void>? _loading;

  ToifaCategory? _category;
  Map<String, OralMark> _marks = {};
  OralTicket? _ticket;
  int? _minutes;
  int? _pass;

  ToifaLoadState get state => _state;
  ToifaBank? get bank => _bank;

  /// Tanlangan toifa (hali tanlanmagan bo'lsa — null).
  ToifaCategory? get category => _category;

  /// Davom etayotgan og'zaki bilet.
  OralTicket? get ticket => _ticket;

  /// Test: vaqt (daqiqa) va o'tish chegarasi (%) — tanlanmagan bo'lsa null.
  int? get testMinutes => _minutes;
  int? get testPass => _pass;

  OralMark? mark(String oralId) => _marks[oralId];
  Map<String, OralMark> get marks => Map.unmodifiable(_marks);

  T? _json<T>(String key, T Function(Object? j) parse) {
    final raw = _store.getString(key);
    if (raw == null) return null;
    try {
      return parse(jsonDecode(raw));
    } on Object {
      // Buzilgan yozuv — yo'qdek (ilova yiqilmaydi).
      return null;
    }
  }

  void _read() {
    _category = ToifaCategory.tryParse(
      _store.getString(StoreKeys.toifaCategory),
    );
    _marks =
        _json(
          StoreKeys.toifaOral,
          (j) => {
            for (final e in (j! as Map).entries)
              e.key as String: OralMark.fromJson(
                (e.value as Map).cast<String, Object?>(),
              ),
          },
        ) ??
        {};
    _ticket = _json(
      StoreKeys.toifaTicket,
      (j) => OralTicket.fromJson((j! as Map).cast<String, Object?>()),
    );
    final settings = _json(
      StoreKeys.toifaTestSettings,
      (j) => (j! as Map).cast<String, Object?>(),
    );
    _minutes = settings?['minutes'] as int?;
    _pass = settings?['pass'] as int?;
  }

  /// Banklar bir marta yuklanadi (bo'lim ochilganda).
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final tests = await bundle.loadString(testsAsset);
      final oral = await bundle.loadString(oralAsset);
      _bank = ToifaBank.fromJson(
        (jsonDecode(tests) as Map).cast<String, Object?>(),
        (jsonDecode(oral) as Map).cast<String, Object?>(),
      );
      _state = ToifaLoadState.ready;
      // Bankda yo'q savolli bilet (yangilangan asset) — tashlanadi.
      final t = _ticket;
      if (t != null && t.ids.any((id) => _bank!.oralQuestion(id) == null)) {
        _ticket = null;
        await _store.remove(StoreKeys.toifaTicket);
      }
    } on Object catch (e) {
      debugPrint('toifa bank rejected: $e');
      _state = ToifaLoadState.failed;
      _loading = null;
    }
    notifyListeners();
  }

  Future<void> retry() {
    _state = ToifaLoadState.loading;
    _loading = null;
    notifyListeners();
    return ensureLoaded();
  }

  Future<void> setCategory(ToifaCategory c) async {
    if (_category == c) return;
    _category = c;
    notifyListeners();
    await _store.setString(StoreKeys.toifaCategory, c.id);
  }

  Future<void> setTestSettings({int? minutes, int? pass}) async {
    _minutes = minutes;
    _pass = pass;
    notifyListeners();
    await _store.setString(
      StoreKeys.toifaTestSettings,
      jsonEncode({'minutes': minutes, 'pass': pass}),
    );
  }

  Future<void> _saveTicket() async {
    final t = _ticket;
    if (t == null) {
      await _store.remove(StoreKeys.toifaTicket);
    } else {
      await _store.setString(StoreKeys.toifaTicket, jsonEncode(t.toJson()));
    }
  }

  Future<void> _saveMarks() => _store.setString(
    StoreKeys.toifaOral,
    jsonEncode({for (final e in _marks.entries) e.key: e.value.toJson()}),
  );

  /// Yangi bilet: tanlangan toifa ro'yxatidan tasodifiy 5 ta savol.
  Future<OralTicket?> drawTicket(ToifaCategory category) async {
    final b = _bank;
    if (b == null) return null;
    final pool = b.oralFor(category)..shuffle(random);
    _ticket = OralTicket(
      category: category,
      ids: [for (final q in pool.take(ToifaFormat.ticketSize)) q.id],
      startedAt: now(),
    );
    notifyListeners();
    await _saveTicket();
    return _ticket;
  }

  /// Tayyorlanish tugadi — birinchi savol rejasi bilan.
  Future<void> startReview() async {
    final t = _ticket;
    if (t == null) return;
    t
      ..reviewing = true
      ..index = 0
      ..revealed = false;
    notifyListeners();
    await _saveTicket();
  }

  Future<void> reveal() async {
    final t = _ticket;
    if (t == null || t.revealed) return;
    t.revealed = true;
    notifyListeners();
    await _saveTicket();
  }

  /// Biletdagi joriy savolga baho: umumiy tarixga ham yoziladi, keyingi
  /// baholanmagan savolga o'tiladi.
  Future<void> rateCurrent(OralRating r) async {
    final t = _ticket;
    if (t == null) return;
    final id = t.currentId;
    t.ratings[id] = r;
    _marks[id] = OralMark(r, now());
    final next = [
      for (var i = 0; i < t.ids.length; i++)
        if (!t.ratings.containsKey(t.ids[i])) i,
    ];
    if (next.isNotEmpty) {
      t
        ..index = next.first
        ..revealed = false;
    }
    notifyListeners();
    await _saveTicket();
    await _saveMarks();
  }

  /// Bilet ichidagi savolga qaytish (masalan, bahoni o'zgartirish).
  Future<void> openInTicket(int index) async {
    final t = _ticket;
    if (t == null || index < 0 || index >= t.ids.length) return;
    t
      ..index = index
      ..revealed = t.ratings.containsKey(t.ids[index]);
    notifyListeners();
    await _saveTicket();
  }

  Future<void> discardTicket() async {
    if (_ticket == null) return;
    _ticket = null;
    notifyListeners();
    await _saveTicket();
  }

  /// Biletdan tashqari (xatolar ro'yxatidan) baholash.
  Future<void> rate(String oralId, OralRating r) async {
    _marks[oralId] = OralMark(r, now());
    notifyListeners();
    await _saveMarks();
  }

  /// Berilgan baho bilan og'zaki savollar (eng yangisi birinchi).
  List<String> oralWith(OralRating r, {ToifaCategory? category}) {
    final b = _bank;
    final out = [
      for (final e in _marks.entries)
        if (e.value.rating == r &&
            (category == null ||
                (b?.oralQuestion(e.key)?.categories.contains(category) ??
                    false)))
          e,
    ]..sort((a, b) => b.value.at.compareTo(a.value.at));
    return [for (final e in out) e.key];
  }

  /// “Lokal ma'lumotlarni o'chirish”dan keyin (bank qoladi).
  void resetInMemory() {
    _category = null;
    _marks = {};
    _ticket = null;
    _minutes = null;
    _pass = null;
    notifyListeners();
  }
}
