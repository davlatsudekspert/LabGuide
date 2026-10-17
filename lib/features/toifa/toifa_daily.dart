import 'dart:math';

import 'package:flutter/foundation.dart';

import '../daily/daily_streak.dart' show dayOf;
import 'toifa_bank.dart';

// Toifa mashg'ulotining kunlik hisobi, og'zaki savollar uchun Leitner
// qutilari va 50 savollik "mashq rejimi" testi — sof mantiq (UI'siz).

/// Kun kaliti — qurilmaning mahalliy sanasi (`yyyy-MM-dd`). UTC lahza
/// berilsa ham mahalliy sanaga o'giriladi: yarim tundan keyingi javob ertangi
/// kunga yoziladi.
String toifaDayKey(DateTime t) {
  final l = t.isUtc ? t.toLocal() : t;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${l.year.toString().padLeft(4, '0')}-${two(l.month)}-${two(l.day)}';
}

/// Kun raqamidan ([dayOf]) kalit.
String toifaKeyOfDay(int day) {
  final u = DateTime.fromMillisecondsSinceEpoch(
    day * Duration.millisecondsPerDay,
    isUtc: true,
  );
  String two(int v) => v.toString().padLeft(2, '0');
  return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}';
}

/// Kalitdan kun raqami ([dayOf]); buzilgan kalit — null.
int? toifaDayOfKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return dayOf(DateTime.utc(y, m, d));
}

/// Kunlik maqsad: [questions] ta test savoli YOKI [tickets] ta og'zaki bilet.
abstract final class ToifaGoal {
  /// Sukut: bitta 50 savollik to'plam yoki bitta bilet.
  static const defaultQuestions = ToifaFormat.testSize;
  static const tickets = 1;

  /// Foydalanuvchi tanlaydigan savollar soni.
  static const options = [20, 50, 100];

  /// Qurilmada saqlanadigan kunlar (eskilari o'chiriladi).
  static const keepDays = 60;
}

/// Bir kunlik toifa mashg'uloti: javob berilgan test savollari, to'g'rilari
/// va yakunlangan og'zaki biletlar.
@immutable
class ToifaDay {
  const ToifaDay({this.answered = 0, this.correct = 0, this.tickets = 0});

  factory ToifaDay.fromJson(Map<String, Object?> j) => ToifaDay(
    answered: (j['a'] as int? ?? 0).clamp(0, 1 << 20),
    correct: (j['c'] as int? ?? 0).clamp(0, 1 << 20),
    tickets: (j['o'] as int? ?? 0).clamp(0, 1 << 20),
  );

  static const empty = ToifaDay();

  final int answered;
  final int correct;
  final int tickets;

  bool get isEmpty => answered == 0 && tickets == 0;

  /// To'g'ri javoblar ulushi (0–100).
  int get percent => answered == 0 ? 0 : (correct * 100 / answered).round();

  ToifaDay add({int answered = 0, int correct = 0, int tickets = 0}) =>
      ToifaDay(
        answered: this.answered + answered,
        correct: this.correct + correct,
        tickets: this.tickets + tickets,
      );

  /// Kunlik maqsad bajarildimi.
  bool meets(int goalQuestions) =>
      answered >= goalQuestions || tickets >= ToifaGoal.tickets;

  /// Maqsadga yaqinlik (0–1): savollar yoki bilet — qaysi biri ko'proq.
  double progress(int goalQuestions) => max(
    goalQuestions <= 0 ? 0.0 : answered / goalQuestions,
    tickets / ToifaGoal.tickets,
  ).clamp(0.0, 1.0);

  Map<String, Object?> toJson() => {'a': answered, 'c': correct, 'o': tickets};

  @override
  bool operator ==(Object other) =>
      other is ToifaDay &&
      other.answered == answered &&
      other.correct == correct &&
      other.tickets == tickets;

  @override
  int get hashCode => Object.hash(answered, correct, tickets);
}

/// Ketma-ket maqsad bajarilgan kunlar. Bugun hali bajarilmagan bo'lsa —
/// kechagacha sanaladi (kun tugamaguncha seriya uzilmaydi).
int toifaStreak(Map<int, ToifaDay> days, int today, int goalQuestions) {
  bool met(int d) => days[d]?.meets(goalQuestions) ?? false;
  var d = met(today) ? today : today - 1;
  var n = 0;
  while (met(d)) {
    n++;
    d--;
  }
  return n;
}

// ------------------------------------------------------------- Leitner

/// Og'zaki savolning Leitner qutisi: [box] (1 — eng zaif, 5 — mustahkam) va
/// oxirgi baholangan bilet raqami [seen].
@immutable
class LeitnerCard {
  const LeitnerCard(this.box, this.seen);

  factory LeitnerCard.fromJson(Object? j) {
    final l = (j! as List).cast<int>();
    return LeitnerCard(l[0].clamp(1, ToifaLeitner.maxBox), l[1]);
  }

  final int box;
  final int seen;

  List<int> toJson() => [box, seen];
}

/// Oddiy Leitner tizimi: "Bilmadim" → 1-quti, "Qisman" → 2-quti,
/// "Bildim" → bir quti yuqoriga (yangi savol 3-qutidan). Har quti o'z
/// oralig'idan (biletlar soni) keyin yana biletga tushadi; zaif qutidagilar
/// keyingi biletlarda birinchi bo'lib qaytadi.
abstract final class ToifaLeitner {
  static const maxBox = 5;

  /// Quti → necha biletdan keyin yana chiqadi.
  static const intervals = {1: 1, 2: 2, 3: 4, 4: 8, 5: 16};

  /// Bitta biletdagi takror savollar chegarasi — har biletda yangi savol
  /// ham bo'lsin.
  static const maxRepeats = 3;

  static int nextBox(int? box, OralRating r) => switch (r) {
    OralRating.unknown => 1,
    OralRating.partial => 2,
    OralRating.knew => min(maxBox, max(box ?? 0, 2) + 1),
  };

  /// Eski (Leitner'dan oldingi) baho uchun boshlang'ich quti.
  static int boxFor(OralRating r) => nextBox(null, r);

  static bool isDue(LeitnerCard c, int ticketNo) =>
      ticketNo - c.seen >= intervals[c.box]!;

  /// Bilet uchun savollar tartibi: muddati kelgan zaif savollar (1–2-quti,
  /// ko'pi bilan [maxRepeats] ta), keyin hali ko'rilmaganlar, keyin muddati
  /// kelgan mustahkamlari, so'ng qolganlari (muddatiga yaqinlari oldin).
  /// [pool] — oldindan aralashtirilgan (bir guruh ichida tasodif saqlanadi).
  static List<String> order(
    List<String> pool,
    Map<String, LeitnerCard> cards,
    int ticketNo, {
    int size = ToifaFormat.ticketSize,
  }) {
    final weak = <String>[];
    final fresh = <String>[];
    final strong = <String>[];
    final rest = <String>[];
    for (final id in pool) {
      final c = cards[id];
      if (c == null) {
        fresh.add(id);
      } else if (!isDue(c, ticketNo)) {
        rest.add(id);
      } else if (c.box <= 2) {
        weak.add(id);
      } else {
        strong.add(id);
      }
    }
    // Barqaror tartiblash (List.sort barqaror emas) — indeks bilan.
    List<String> by(List<String> ids, int Function(String) key) {
      final idx = {for (final (i, id) in ids.indexed) id: i};
      return ids.toList()..sort((a, b) {
        final c = key(a).compareTo(key(b));
        return c != 0 ? c : idx[a]!.compareTo(idx[b]!);
      });
    }

    final weakSorted = by(weak, (id) => cards[id]!.box);
    final strongSorted = by(strong, (id) => cards[id]!.seen);
    final restSorted = by(
      rest,
      (id) => cards[id]!.seen + intervals[cards[id]!.box]!,
    );
    return [
      ...weakSorted.take(maxRepeats),
      ...fresh,
      ...strongSorted,
      ...weakSorted.skip(maxRepeats),
      ...restSorted,
    ].take(size).toList();
  }
}

// ------------------------------------------------------- Mashq rejimi

/// Test rejimi: imtihon (vaqt, natija oxirida) yoki mashq (har javobdan
/// keyin darhol to'g'ri/xato).
enum ToifaTestMode {
  exam,
  practice;

  static ToifaTestMode tryParse(String? name) =>
      name == practice.name ? practice : exam;
}

/// Mashq rejimidagi test (50 savol yoki xatolarni qayta ishlash). Har javob
/// darhol yoziladi — ilova yopilsa ham davom ettiriladi. Kalit boshlanganda
/// yoziladi (bank yangilansa ham ball o'zgarmaydi).
class ToifaDrill {
  ToifaDrill({
    required this.id,
    required this.ids,
    required this.keys,
    required this.startedAt,
    Map<int, int>? answers,
    this.index = 0,
    this.finishedAt,
    this.pass,
    this.rework = false,
  }) : answers = answers ?? {} {
    if (keys.length != ids.length) throw const FormatException('keys');
  }

  factory ToifaDrill.fromJson(Map<String, Object?> j) {
    final ids = (j['ids']! as List).cast<String>();
    DateTime? date(String k) =>
        j[k] == null ? null : DateTime.parse(j[k]! as String);
    return ToifaDrill(
      id: j['id']! as String,
      ids: ids,
      keys: (j['keys']! as List).cast<int>(),
      startedAt: DateTime.parse(j['started']! as String),
      answers: {
        for (final e in ((j['answers'] as Map?) ?? const {}).entries)
          int.parse(e.key as String): e.value as int,
      },
      index: (j['index'] as int? ?? 0).clamp(0, max(0, ids.length - 1)),
      finishedAt: date('finished'),
      pass: j['pass'] as int?,
      rework: j['rework'] as bool? ?? false,
    );
  }

  final String id;
  final List<String> ids;

  /// Har savolning rasmiy kaliti (asl variant indeksi).
  final List<int> keys;
  final DateTime startedAt;

  /// Savol o'rni → tanlangan variant.
  final Map<int, int> answers;
  int index;
  DateTime? finishedAt;

  /// O'tish chegarasi, % (tanlanmagan — null).
  final int? pass;

  /// Xatolarni qayta ishlash raundi.
  final bool rework;

  int get length => ids.length;
  bool get finished => finishedAt != null;
  bool isAnswered(int i) => answers.containsKey(i);
  bool isCorrect(int i) => answers[i] == keys[i];
  int get answeredCount => answers.length;
  int get correctCount =>
      answers.entries.where((e) => keys[e.key] == e.value).length;
  int get wrongCount => answeredCount - correctCount;
  int get unansweredCount => length - answeredCount;

  /// Hammasidan foiz (javobsiz — noto'g'ri sanaladi, imtihondagidek).
  int get percent => length == 0 ? 0 : (correctCount * 100 / length).round();
  bool? get passed => pass == null ? null : percent >= pass!;

  /// Noto'g'ri javob berilgan savollar o'rni (tartibda).
  List<int> get wrongIndexes => [
    for (var i = 0; i < length; i++)
      if (isAnswered(i) && !isCorrect(i)) i,
  ];

  /// Birinchi javobsiz savol (hammasi javoblangan — null).
  int? get firstUnanswered {
    for (var i = 0; i < length; i++) {
      if (!isAnswered(i)) return i;
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'ids': ids,
    'keys': keys,
    'started': startedAt.toUtc().toIso8601String(),
    'answers': {for (final e in answers.entries) '${e.key}': e.value},
    'index': index,
    'finished': finishedAt?.toUtc().toIso8601String(),
    'pass': pass,
    'rework': rework,
  };
}
