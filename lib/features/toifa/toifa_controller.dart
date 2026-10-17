import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/storage/kv_store.dart';
import '../daily/daily_streak.dart' show dayOf;
import 'toifa_bank.dart';
import 'toifa_daily.dart';

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
    this.number = 0,
    this.counted = false,
    Map<String, int>? boxes,
  }) : ratings = ratings ?? {},
       boxes = boxes ?? {};

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
      number: j['no'] as int? ?? 0,
      counted: j['counted'] as bool? ?? false,
      boxes: {
        for (final e in ((j['boxes'] as Map?) ?? const {}).entries)
          e.key as String: e.value as int,
      },
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

  /// Bilet tartib raqami (Leitner oraliqlari biletlar bilan sanaladi).
  final int number;

  /// Yakunlangan bilet kunlik hisobga yozilgan (bir marta).
  bool counted;

  /// Savolning biletdan oldingi Leitner qutisi (0 — yangi): bahoni
  /// o'zgartirsa quti ikki marta surilmaydi.
  final Map<String, int> boxes;

  /// Takrorlash kerak: "Qisman" yoki "Bilmadim" deb baholanganlar.
  List<String> get toRepeat => [
    for (final id in ids)
      if (ratings[id] case OralRating.partial || OralRating.unknown) id,
  ];

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
    'no': number,
    'counted': counted,
    'boxes': boxes,
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
  ToifaTestMode _mode = ToifaTestMode.exam;
  bool _checklist = false;

  /// Kunlar ([dayOf]) → shu kungi mashg'ulot.
  Map<int, ToifaDay> _days = {};
  int _goal = ToifaGoal.defaultQuestions;
  bool _opened = false;

  /// Leitner: savol → quti; [_ticketNo] — berilgan biletlar soni.
  Map<String, LeitnerCard> _cards = {};
  int _ticketNo = 0;
  ToifaDrill? _drill;

  ToifaLoadState get state => _state;
  ToifaBank? get bank => _bank;

  /// Tanlangan toifa (hali tanlanmagan bo'lsa — null).
  ToifaCategory? get category => _category;

  /// Davom etayotgan og'zaki bilet.
  OralTicket? get ticket => _ticket;

  /// Test: vaqt (daqiqa) va o'tish chegarasi (%) — tanlanmagan bo'lsa null.
  int? get testMinutes => _minutes;
  int? get testPass => _pass;

  /// Oxirgi tanlangan test rejimi (sukut — imtihon).
  ToifaTestMode get testMode => _mode;

  /// Og'zaki javobni tekshirish uchun asosiy so'zlar ro'yxati (ixtiyoriy).
  bool get checklist => _checklist;

  // ------------------------------------------------- Kunlik mashg'ulot

  /// Bugungi kun ([dayOf], mahalliy sana).
  int get today => dayOf(now().toLocal());

  ToifaDay dayStats(int day) => _days[day] ?? ToifaDay.empty;
  ToifaDay get todayStats => dayStats(today);

  /// Kunlik maqsad: shuncha test savoli (yoki bitta bilet).
  int get goalQuestions => _goal;
  bool get todayGoalMet => todayStats.meets(_goal);

  /// Ketma-ket maqsad bajarilgan kunlar.
  int get streak => toifaStreak(_days, today, _goal);

  /// Oxirgi [n] kun (eskidan bugungacha).
  List<(int day, ToifaDay stats)> lastDays([int n = 7]) => [
    for (var d = today - n + 1; d <= today; d++) (d, dayStats(d)),
  ];

  /// Bo'lim ochilgan yoki mashg'ulot bo'lgan (bosh sahifada "Bugun"
  /// kartasi ko'rsatiladi).
  bool get opened => _opened || _days.isNotEmpty;

  /// Mashq rejimidagi test (yakunlangani ham — natija ko'rinishi uchun).
  ToifaDrill? get drill => _drill;

  /// Davom etayotgan (yakunlanmagan) mashq testi.
  ToifaDrill? get activeDrill => (_drill?.finished ?? true) ? null : _drill;

  LeitnerCard? card(String oralId) => _cards[oralId];

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
    _mode = ToifaTestMode.tryParse(settings?['mode'] as String?);
    _checklist = settings?['checklist'] as bool? ?? false;
    final daily = _json(
      StoreKeys.toifaDaily,
      (j) => (j! as Map).cast<String, Object?>(),
    );
    _days = {};
    for (final e in ((daily?['days'] as Map?) ?? const {}).entries) {
      final d = toifaDayOfKey(e.key as String);
      if (d == null || e.value is! Map) continue;
      _days[d] = ToifaDay.fromJson((e.value as Map).cast<String, Object?>());
    }
    final goal = daily?['goal'] as int?;
    _goal = ToifaGoal.options.contains(goal)
        ? goal!
        : ToifaGoal.defaultQuestions;
    _opened = daily?['opened'] as bool? ?? false;
    final leitner = _json(
      StoreKeys.toifaLeitner,
      (j) => (j! as Map).cast<String, Object?>(),
    );
    _ticketNo = leitner?['n'] as int? ?? 0;
    _cards = {};
    for (final e in ((leitner?['b'] as Map?) ?? const {}).entries) {
      try {
        _cards[e.key as String] = LeitnerCard.fromJson(e.value);
      } on Object {
        // Bitta buzilgan yozuv qolganlarini o'chirmaydi.
      }
    }
    // Leitner'dan oldingi baholar: oxirgi bahodan boshlang'ich quti.
    for (final e in _marks.entries) {
      _cards.putIfAbsent(
        e.key,
        () => LeitnerCard(ToifaLeitner.boxFor(e.value.rating), 0),
      );
    }
    _drill = _json(
      StoreKeys.toifaDrill,
      (j) => ToifaDrill.fromJson((j! as Map).cast<String, Object?>()),
    );
  }

  /// Banklar bir marta yuklanadi (bo'lim ochilganda).
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      _bank = _shared != null && identical(_sharedBundle, bundle)
          ? _shared
          : await _parse();
      _state = ToifaLoadState.ready;
      // Bankda yo'q savolli bilet (yangilangan asset) — tashlanadi.
      final t = _ticket;
      if (t != null && t.ids.any((id) => _bank!.oralQuestion(id) == null)) {
        _ticket = null;
        await _store.remove(StoreKeys.toifaTicket);
      }
      // Bankda yo'q savolli mashq testi ham.
      final d = _drill;
      if (d != null && d.ids.any((id) => _bank!.test(id) == null)) {
        _drill = null;
        await _store.remove(StoreKeys.toifaDrill);
      }
    } on Object catch (e) {
      debugPrint('toifa bank rejected: $e');
      _state = ToifaLoadState.failed;
      _loading = null;
    }
    notifyListeners();
  }

  /// Bank o'zgarmas — bir xil asset bundle uchun bir marta o'qiladi
  /// (masalan, “lokal ma'lumotlarni o'chirish”dan keyin yoki testlarda).
  static ToifaBank? _shared;
  static AssetBundle? _sharedBundle;

  Future<ToifaBank> _parse() async {
    final tests = await bundle.loadString(testsAsset, cache: false);
    final oral = await bundle.loadString(oralAsset, cache: false);
    final bank = ToifaBank.fromJson(
      (jsonDecode(tests) as Map).cast<String, Object?>(),
      (jsonDecode(oral) as Map).cast<String, Object?>(),
    );
    _shared = bank;
    _sharedBundle = bundle;
    return bank;
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

  Future<void> setTestSettings({
    int? minutes,
    int? pass,
    ToifaTestMode? mode,
  }) async {
    _minutes = minutes;
    _pass = pass;
    if (mode != null) _mode = mode;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setTestMode(ToifaTestMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setChecklist(bool on) async {
    if (_checklist == on) return;
    _checklist = on;
    notifyListeners();
    await _saveSettings();
  }

  Future<void> _saveSettings() => _store.setString(
    StoreKeys.toifaTestSettings,
    jsonEncode({
      'minutes': _minutes,
      'pass': _pass,
      'mode': _mode.name,
      'checklist': _checklist,
    }),
  );

  Future<void> _saveDaily() {
    // Faqat oxirgi [ToifaGoal.keepDays] kun saqlanadi.
    final from = today - ToifaGoal.keepDays + 1;
    _days.removeWhere((d, _) => d < from);
    return _store.setString(
      StoreKeys.toifaDaily,
      jsonEncode({
        'days': {
          for (final e in _days.entries) toifaKeyOfDay(e.key): e.value.toJson(),
        },
        'goal': _goal,
        'opened': _opened,
      }),
    );
  }

  /// Test javoblari bugungi hisobga (imtihon yakuni, mavzu mashqi).
  Future<void> recordAnswers({required int answered, required int correct}) {
    if (answered <= 0) return Future.value();
    final d = today;
    _days[d] = dayStats(d).add(answered: answered, correct: correct);
    notifyListeners();
    return _saveDaily();
  }

  Future<void> _recordTicket() {
    final d = today;
    _days[d] = dayStats(d).add(tickets: 1);
    return _saveDaily();
  }

  /// Kunlik maqsad ([ToifaGoal.options] dan).
  Future<void> setGoal(int questions) async {
    if (!ToifaGoal.options.contains(questions) || _goal == questions) return;
    _goal = questions;
    notifyListeners();
    await _saveDaily();
  }

  /// Bo'lim birinchi marta ochildi.
  Future<void> markOpened() async {
    if (_opened) return;
    _opened = true;
    notifyListeners();
    await _saveDaily();
  }

  // ------------------------------------------------- Mashq rejimi testi

  Future<void> _saveDrill() async {
    final d = _drill;
    if (d == null) {
      await _store.remove(StoreKeys.toifaDrill);
    } else {
      await _store.setString(StoreKeys.toifaDrill, jsonEncode(d.toJson()));
    }
  }

  /// Yangi mashq testi (oldingisi bo'lsa — almashtiriladi). Faqat rasmiy
  /// kaliti bor savollar.
  Future<ToifaDrill?> startDrill(
    List<ToifaTestQuestion> questions, {
    int? pass,
    bool rework = false,
  }) async {
    final qs = [
      for (final q in questions)
        if (q.scorable) q,
    ];
    if (qs.isEmpty) return null;
    _drill = ToifaDrill(
      id:
          '${now().microsecondsSinceEpoch.toRadixString(36)}'
          '${random.nextInt(1 << 20).toRadixString(36)}',
      ids: [for (final q in qs) q.id],
      keys: [for (final q in qs) q.key.first],
      startedAt: now(),
      pass: pass,
      rework: rework,
    );
    notifyListeners();
    await _saveDrill();
    return _drill;
  }

  /// Joriy savolga javob (bir marta) — darhol bugungi hisobga ham yoziladi.
  /// To'g'rimi — qaytaradi (javob berilgan bo'lsa — null).
  Future<bool?> answerDrill(int option) async {
    final d = _drill;
    if (d == null || d.finished || d.isAnswered(d.index)) return null;
    d.answers[d.index] = option;
    final ok = d.isCorrect(d.index);
    final day = today;
    _days[day] = dayStats(day).add(answered: 1, correct: ok ? 1 : 0);
    notifyListeners();
    await _saveDrill();
    await _saveDaily();
    return ok;
  }

  /// Keyingi savol; oxirgisidan keyin — javobsiz qolgan birinchisiga yoki
  /// yakun.
  Future<void> drillNext() async {
    final d = _drill;
    if (d == null || d.finished) return;
    if (d.answeredCount == d.length) {
      d.finishedAt = now();
    } else if (d.index < d.length - 1) {
      d.index++;
    } else if (d.firstUnanswered case final i?) {
      d.index = i;
    } else {
      d.finishedAt = now();
    }
    notifyListeners();
    await _saveDrill();
  }

  /// Muddatidan oldin yakunlash (javobsizlari noto'g'ri sanaladi).
  Future<void> finishDrill() async {
    final d = _drill;
    if (d == null || d.finished) return;
    d.finishedAt = now();
    notifyListeners();
    await _saveDrill();
  }

  Future<void> discardDrill() async {
    if (_drill == null) return;
    _drill = null;
    notifyListeners();
    await _saveDrill();
  }

  Future<void> _saveTicket() async {
    final t = _ticket;
    if (t == null) {
      await _store.remove(StoreKeys.toifaTicket);
    } else {
      await _store.setString(StoreKeys.toifaTicket, jsonEncode(t.toJson()));
    }
  }

  Future<void> _saveMarks() async {
    await _store.setString(
      StoreKeys.toifaOral,
      jsonEncode({for (final e in _marks.entries) e.key: e.value.toJson()}),
    );
    await _store.setString(
      StoreKeys.toifaLeitner,
      jsonEncode({
        'n': _ticketNo,
        'b': {for (final e in _cards.entries) e.key: e.value.toJson()},
      }),
    );
  }

  void _moveCard(String id, OralRating r, int ticketNo) {
    _cards[id] = LeitnerCard(
      ToifaLeitner.nextBox(_cards[id]?.box, r),
      ticketNo,
    );
  }

  /// Yangi bilet: tanlangan toifa ro'yxatidan 5 ta savol — avval
  /// "Qisman"/"Bilmadim" deb baholangan (muddati kelgan) savollar, keyin
  /// yangilari ([ToifaLeitner.order]). Ichida tartib tasodifiy.
  Future<OralTicket?> drawTicket(ToifaCategory category) async {
    final b = _bank;
    if (b == null) return null;
    // Aniqlashtirilayotgan savollar biletga kirmaydi.
    final pool = [for (final q in b.ticketPool(category)) q.id]
      ..shuffle(random);
    _ticketNo++;
    _ticket = OralTicket(
      category: category,
      ids: ToifaLeitner.order(pool, _cards, _ticketNo)..shuffle(random),
      startedAt: now(),
      number: _ticketNo,
    );
    notifyListeners();
    await _saveTicket();
    await _saveMarks();
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
    // Bahoni o'zgartirish — bilet oldidagi qutidan qayta hisoblanadi.
    final before = t.boxes[id] ??= _cards[id]?.box ?? 0;
    _cards[id] = LeitnerCard(ToifaLeitner.nextBox(before, r), t.number);
    t.ratings[id] = r;
    _marks[id] = OralMark(r, now());
    if (t.done && !t.counted) {
      t.counted = true;
      await _recordTicket();
    }
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
    _moveCard(oralId, r, _ticketNo);
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
    _mode = ToifaTestMode.exam;
    _checklist = false;
    _days = {};
    _goal = ToifaGoal.defaultQuestions;
    _opened = false;
    _cards = {};
    _ticketNo = 0;
    _drill = null;
    notifyListeners();
  }
}
