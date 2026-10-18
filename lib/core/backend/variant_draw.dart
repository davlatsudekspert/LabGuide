import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Variantli test (D-66): “Har bir talabaga boshqa savollar”.
///
/// Talabaga tushadigan savollar hovuzdan deterministik tanlanadi. Algoritm
/// Worker'dagi `cloudflare/src/variants.ts` bilan AYNAN bir xil (umumiy test
/// vektorlari: `cloudflare/test/variant_vectors.json`):
///  1. seed = `"<assignmentId>:<userId>"`.
///  2. Har savol uchun h = hex(SHA-256(seed + ":" + savolId)) (UTF-8).
///  3. Savollar mavzu ([poolTopics] i; yo'q — "") bo'yicha qatlamlarga
///     ajratiladi; qatlam ichida h (teng bo'lsa — id) bo'yicha o'sish tartibi.
///  4. Qatlamlar tartibi — hex(SHA-256(seed + "#" + mavzu)) (teng — nomi):
///     qaysi mavzu “ortiqcha” savol berishi talabadan talabaga almashadi.
///  5. Navbatma-navbat: har qatlamdan 1-savol, keyin 2-savol, … [count] ta
///     bo'lguncha. Natija — shu tanlash tartibi (ekrandagi tartib baribir
///     aralashtiriladi).
///
/// Shu sababli har talaba mavzular bo'yicha deyarli bir xil (±1) ulushdagi
/// savollarni oladi — qiyinlik aralashmasi taqqoslanadigan bo'ladi.
List<String> drawVariant({
  required String assignmentId,
  required String userId,
  required List<String> pool,
  List<String?>? poolTopics,
  required int count,
}) {
  final seed = '$assignmentId:$userId';
  String h(String s) => sha256.convert(utf8.encode(s)).toString();
  final strata = <String, List<(String, String)>>{};
  for (var i = 0; i < pool.length; i++) {
    final t = (poolTopics != null && i < poolTopics.length)
        ? poolTopics[i] ?? ''
        : '';
    (strata[t] ??= []).add((pool[i], h('$seed:${pool[i]}')));
  }
  final keyHash = {for (final k in strata.keys) k: h('$seed#$k')};
  final keys = strata.keys.toList()
    ..sort((a, b) {
      final c = keyHash[a]!.compareTo(keyHash[b]!);
      return c != 0 ? c : a.compareTo(b);
    });
  final lists = [
    for (final k in keys)
      strata[k]!..sort((x, y) {
        final c = x.$2.compareTo(y.$2);
        return c != 0 ? c : x.$1.compareTo(y.$1);
      }),
  ];
  final n = count.clamp(0, pool.length);
  final out = <String>[];
  for (var round = 0; out.length < n; round++) {
    for (final l in lists) {
      if (round < l.length && out.length < n) out.add(l[round].$1);
    }
  }
  return out;
}

/// Mavzu testining variantli hovuzi (ko'p bo'lsa — tasodifiy shuncha).
const kVariantPoolMax = 60;

/// Server qabul qiladigan eng katta variantli hovuz (`MAX_POOL`): 50
/// savollik variantli umumiy test uchun 100. Eski server (deploydan oldin)
/// 60 dan kattasini `invalid_questions` bilan rad etadi.
const kVariantPoolServerMax = 100;

/// Variantli rejim mumkinmi: hovuz kamida 2 × [perStudent].
bool variantAllowed(int poolSize, int perStudent) =>
    perStudent >= 1 && poolSize >= perStudent * 2;

/// Server `pool_topics` qabul qiladigan mavzu id si (aks holda — null).
final _topicRe = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.:-]{0,79}$');

String? variantTopic(Iterable<String> topicIds) {
  final t = topicIds.firstOrNull;
  return t != null && _topicRe.hasMatch(t) ? t : null;
}
