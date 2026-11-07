import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/toifa/lab_ishi_direction.dart';

void main() {
  final raw = jsonDecode(File(labIshiAsset).readAsStringSync()) as Map;
  final qs = [
    for (final e in raw['questions'] as List)
      LabIshiQuestion.fromJson((e as Map).cast<String, Object?>()),
  ];

  test('yo‘nalish savollari to‘g‘ri tuzilgan', () {
    expect(qs.length, greaterThan(400));
    final seen = <int>{};
    for (final q in qs) {
      expect(seen.add(q.number), isTrue, reason: 'takror ${q.number}');
      expect(q.options.length, 4, reason: '${q.number}');
      expect(q.key, inInclusiveRange(0, 3), reason: '${q.number}');
      expect(q.text.trim(), isNotEmpty);
      expect(q.options.every((o) => o.trim().isNotEmpty), isTrue);
    }
  });

  test('foydalanuvchiga ko‘rinadigan matnda taqiqlangan so‘zlar yo‘q', () {
    final src = File('lib/features/toifa/lab_ishi_direction.dart')
        .readAsStringSync()
        .toLowerCase();
    expect(src.contains('toifa'.toLowerCase()) &&
        RegExp(r"'[^']*toifa[^']*'").hasMatch(src), isFalse);
    expect(RegExp(r"'[^']*\bbank[^']*'").hasMatch(src), isFalse);
  });
}
