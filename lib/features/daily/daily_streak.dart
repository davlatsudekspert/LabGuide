import 'package:flutter/foundation.dart';

/// Kalendar kuni — 1970-01-01 dan beri kunlar soni. Soat, vaqt mintaqasi va
/// yozgi vaqt (23/25 soatlik kun) hisobga kirmaydi: faqat yil/oy/kun.
///
/// Qurilmaning joriy mahalliy sanasi olinadi; mintaqa o'zgarsa ham kunlar
/// soatlar emas, sana bo'yicha solishtiriladi.
int dayOf(DateTime t) =>
    DateTime.utc(t.year, t.month, t.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// Kun raqamidan sana (UTC, faqat yil/oy/kun ishlatiladi).
DateTime dateOfDay(int day) => DateTime.fromMillisecondsSinceEpoch(
  day * Duration.millisecondsPerDay,
  isUtc: true,
);

/// Hafta raqami (dushanbadan boshlanadi). 1970-01-01 — payshanba.
int weekOf(int day) => (day + 3) ~/ 7;

/// Ketma-ketlik holati.
@immutable
class StreakStats {
  const StreakStats({
    required this.current,
    required this.best,
    required this.todayDone,
    required this.frozen,
    required this.freezeUsedThisWeek,
  });

  static const empty = StreakStats(
    current: 0,
    best: 0,
    todayDone: false,
    frozen: {},
    freezeUsedThisWeek: false,
  );

  /// Joriy seriyadagi bajarilgan kunlar (muzlatilgan kunlar sanalmaydi).
  final int current;

  /// Eng uzun seriya.
  final int best;
  final bool todayDone;

  /// Joriy seriyani saqlab qolgan muzlatilgan kunlar.
  final Set<int> frozen;

  /// Shu haftaning muzlatishi ishlatilgan.
  final bool freezeUsedThisWeek;
}

/// Muzlatish qoidasi (oddiy va halol): bitta o'tkazib yuborilgan kun seriyani
/// uzmaydi, agar o'sha haftada (dushanba–yakshanba) muzlatish hali
/// ishlatilmagan bo'lsa. Ketma-ket ikki kun o'tkazilsa — seriya uziladi.
/// Muzlatilgan kun bajarilgan deb sanalmaydi.
({int count, Set<int> frozen}) _chainEndingAt(Set<int> done, int end) {
  var d = end;
  var count = 0;
  final frozen = <int>{};
  final weeks = <int>{};
  while (true) {
    if (done.contains(d)) {
      count++;
      d--;
      continue;
    }
    // Bitta kunlik bo'shliq: oldingi kun bajarilgan va haftalik muzlatish bor.
    if (done.contains(d - 1) && !weeks.contains(weekOf(d))) {
      frozen.add(d);
      weeks.add(weekOf(d));
      d--;
      continue;
    }
    return (count: count, frozen: frozen);
  }
}

/// [done] — bajarilgan kunlar ([dayOf]), [today] — bugungi kun.
///
/// Bugun hali bajarilmagan bo'lsa seriya kechagi kungacha sanaladi (kun
/// tugamaguncha uzilmaydi). Soat orqaga surilib (masalan, g'arbga uchib)
/// bugun oxirgi bajarilgan kundan oldin bo'lib qolsa — o'sha kun "bugun"
/// deb olinadi: seriya yo'qolmaydi va ikki marta sanalmaydi.
StreakStats computeStreak(Set<int> done, int today, {int storedBest = 0}) {
  if (done.isEmpty) {
    return StreakStats(
      current: 0,
      best: storedBest,
      todayDone: false,
      frozen: const {},
      freezeUsedThisWeek: false,
    );
  }
  final latest = done.reduce((a, b) => a > b ? a : b);
  final now = latest > today ? latest : today;
  final todayDone = done.contains(now);
  final chain = _chainEndingAt(done, todayDone ? now : now - 1);
  var best = storedBest;
  for (final d in done) {
    // Faqat seriya oxiri bo'lgan kunlar (keyingi kun bajarilmagan).
    if (done.contains(d + 1)) continue;
    final c = _chainEndingAt(done, d).count;
    if (c > best) best = c;
  }
  if (chain.count > best) best = chain.count;
  return StreakStats(
    current: chain.count,
    best: best,
    todayDone: todayDone,
    frozen: chain.frozen,
    freezeUsedThisWeek: chain.frozen.any((d) => weekOf(d) == weekOf(now)),
  );
}
