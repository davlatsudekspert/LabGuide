// Sxematik chizma SVG sidagi raqamli qism belgilari (gen.py `callouts`).
// Rasmdagi yagona ruxsat etilgan matn — `<g id="callouts">` ichidagi
// raqamlar; boshqa joyda `<text` bo‘lsa yoki raqam bo‘lmagan matn bo‘lsa —
// test xatosi.
import 'package:flutter_test/flutter_test.dart';

/// Belgilar raqamlari (tartib bilan). Qoidaga zid SVG — `fail`.
List<int> calloutNumbers(String svg) {
  final start = svg.indexOf('<g id="callouts"');
  final outside = start < 0 ? svg : svg.substring(0, start);
  if (outside.contains('<text') || outside.contains('<tspan')) {
    fail('belgilar guruhidan tashqarida matn bor');
  }
  if (start < 0) return const [];
  final inside = svg.substring(start);
  if (inside.contains('<tspan') ||
      '<text'.allMatches(inside).length !=
          RegExp(r'<text [^>]*>[^<]*</text>').allMatches(inside).length) {
    fail('belgilar guruhida murakkab matn');
  }
  final out = <int>[];
  for (final m in RegExp(r'<text [^>]*>([^<]*)</text>').allMatches(inside)) {
    final t = m[1]!;
    if (!RegExp(r'^[1-9][0-9]?$').hasMatch(t)) {
      fail('belgida raqam emas: "$t"');
    }
    out.add(int.parse(t));
  }
  return out;
}
