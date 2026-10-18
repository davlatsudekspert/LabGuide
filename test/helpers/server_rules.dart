// Worker (cloudflare/src/groups.ts) topshiriq qoidalari — Dart qorovullari
// uchun manbadan o'qiladi.
import 'dart:io';

/// Server qoidalari — groups.ts manbasidan (regex va chegaralar): server
/// o'zgarsa, qorovullar ham ko'radi.
class ServerRules {
  ServerRules(String src) {
    RegExp re(String name) {
      final m = RegExp('const $name = /(.+)/;').firstMatch(src);
      if (m == null) throw StateError('groups.ts: $name topilmadi');
      return RegExp(m.group(1)!);
    }

    int num(String pattern) {
      final m = RegExp(pattern).firstMatch(src);
      if (m == null) throw StateError('groups.ts: $pattern topilmadi');
      return int.parse(m.group(1)!);
    }

    idRe = re('ID_RE');
    topicRe = re('TOPIC_RE');
    maxPool = num(r'const MAX_POOL = (\d+);');
    maxQuestions = num(r'const maxQs = perStudent == null \? (\d+) :');
    maxKey = num(r'Number.isInteger\(k\) && k >= 0 && k <= (\d+)');
    titleMax = num(r"str\(body.title, 3, (\d+), 'invalid_title'\)");
  }

  late final RegExp idRe;
  late final RegExp topicRe;
  late final int maxPool;
  late final int maxQuestions;
  late final int maxKey;
  late final int titleMax;

  /// Repo ildizidan (flutter test ishchi papkasi).
  static ServerRules load() =>
      ServerRules(File('cloudflare/src/groups.ts').readAsStringSync());
}
