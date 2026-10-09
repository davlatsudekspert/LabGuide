import 'dart:math';

/// Kunlik to'plamdagi savollar soni.
const kDailySize = 5;

/// Rolga mos mavzulardan olinadigan savollar soni (qolgani — boshqa
/// mavzulardan, bilim tor bo'lib qolmasin).
const kDailyPriority = 3;

/// Qurilma urug'i bilan aralashtirilgan, id bo'yicha barqaror tartib.
List<String> _order(Iterable<String> ids, int seed) =>
    (ids.toSet().toList()..sort())..shuffle(Random(seed));

/// [order] dan [day] uchun [n] ta savol: kunlar bo'yicha aylanadi, shuning
/// uchun hovuz tugamaguncha savollar takrorlanmaydi.
List<String> _slice(List<String> order, int day, int n) {
  if (order.isEmpty || n <= 0) return const [];
  final take = min(n, order.length);
  final start = (day * take) % order.length;
  return [for (var i = 0; i < take; i++) order[(start + i) % order.length]];
}

/// Kunlik to'plam: sana ([day]) va qurilma urug'i ([seed]) bo'yicha
/// deterministik — kun ichida va ilova qayta ochilganda o'zgarmaydi.
/// [priority] — rolga mos mavzular savollari (bo'sh bo'lsa hammasi
/// [others] dan).
List<String> pickDaily({
  required Iterable<String> priority,
  required Iterable<String> others,
  required int day,
  required int seed,
  int size = kDailySize,
}) {
  final prio = _order(priority, seed);
  final prioSet = prio.toSet();
  final rest = _order(others.where((id) => !prioSet.contains(id)), seed + 1);
  var nPrio = rest.isEmpty ? size : min(kDailyPriority, size);
  if (prio.isEmpty) nPrio = 0;
  final out = [
    ..._slice(prio, day, nPrio),
    ..._slice(rest, day, size - min(nPrio, prio.length)),
  ];
  // Biror hovuz kichik bo'lsa — ikkinchisidan to'ldiriladi.
  if (out.length < size) {
    for (final id in [...prio, ...rest]) {
      if (out.length >= size) break;
      if (!out.contains(id)) out.add(id);
    }
  }
  return out;
}
