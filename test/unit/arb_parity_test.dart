import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // uz'da kalit nomi xato yozilgani (roleTalaba) sababli rol “Student”
  // inglizcha ko'rinib qolgan edi: uch ARB bir xil kalitlarga ega bo'lsin.
  test('uz, ru, en ARB files have identical message keys', () {
    Set<String> keys(String l) =>
        (jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync())
                as Map<String, dynamic>)
            .keys
            .where((k) => !k.startsWith('@'))
            .toSet();
    final en = keys('en');
    expect(keys('uz').difference(en), isEmpty);
    expect(en.difference(keys('uz')), isEmpty);
    expect(en.difference(keys('ru')), isEmpty);
    expect(keys('ru').difference(en), isEmpty);
  });
}
