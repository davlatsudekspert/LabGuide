import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/toifa/lab_ishi_direction.dart';

void main() {
  List<LabIshiQuestion> read(String asset) => [
    for (final e in (jsonDecode(File(asset).readAsStringSync()) as Map)['questions'] as List)
      LabIshiQuestion.fromJson((e as Map).cast<String, Object?>()),
  ];

  for (final (asset, min) in [(labIshiAsset, 400), (toxLabAsset, 200)]) {
    test('yo‘nalish savollari to‘g‘ri tuzilgan: $asset', () {
      final qs = read(asset);
      expect(qs.length, greaterThan(min));
      final seen = <int>{};
      for (final q in qs) {
        expect(seen.add(q.number), isTrue, reason: 'takror ${q.number}');
        expect(q.options.length, 4, reason: '${q.number}');
        expect(q.key, inInclusiveRange(0, 3), reason: '${q.number}');
        expect(q.text.trim(), isNotEmpty);
        expect(q.options.every((o) => o.trim().isNotEmpty), isTrue);
      }
    });
  }

  test('foydalanuvchiga ko‘rinadigan matnda taqiqlangan so‘zlar yo‘q', () {
    final src = File('lib/features/toifa/lab_ishi_direction.dart')
        .readAsStringSync()
        .toLowerCase();
    expect(src.contains('toifa'.toLowerCase()) &&
        RegExp(r"'[^']*toifa[^']*'").hasMatch(src), isFalse);
    expect(RegExp(r"'[^']*\bbank[^']*'").hasMatch(src), isFalse);
  });
}
