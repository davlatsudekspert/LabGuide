// Haqiqiy o'quv dasturi asset'i (ustozning 6 oylik kalendar-rejasi): to'liq
// yuklanadi va shaxsiy/tashkiliy ma'lumotsiz (D-42).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';

void main() {
  final raw = File('assets/curriculum/curriculum.json').readAsStringSync();

  test('asset parses: 9 modules, 143 days in order', () {
    final c = Curriculum.parse(raw);
    expect(c.modules.length, 9);
    expect(c.topics.length, greaterThanOrEqualTo(143));
    final orders = [for (final t in c.topics) t.order];
    expect(orders.first, 1);
    expect(orders.last, 143);
  });

  test('asset carries no curator, clinic or group dates', () {
    for (final s in [
      'Karimova',
      'Turg',
      'poliklinika',
      'ADTI',
      'curator',
      'group_curator',
      '"base"',
      '"date"',
    ]) {
      expect(raw.contains(s), isFalse, reason: s);
    }
  });
}
