// Ekspert tasdig'i reyestri chirimasligi uchun: har yozuvning fayli va
// belgisi (symbol) hali mavjud, holat AWAITING_EXPERT (hech narsa "tasdiqlangan" emas).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final reg =
      jsonDecode(File('docs/expert_signoff_registry.json').readAsStringSync())
          as Map<String, dynamic>;
  final entries = (reg['entries'] as List).cast<Map<String, dynamic>>();

  test('reyestr bo‘sh emas, id lar takrorlanmaydi, majburiy maydonlar bor', () {
    expect(entries, isNotEmpty);
    expect({for (final e in entries) e['id']}.length, entries.length);
    for (final e in entries) {
      for (final k in [
        'id',
        'area',
        'file',
        'line',
        'symbol',
        'current_rule',
        'required_reviewer_role',
        'status',
        'source_reference',
      ]) {
        expect(e[k], isNotNull, reason: '${e['id']} $k');
        expect(e[k].toString().trim(), isNotEmpty, reason: '${e['id']} $k');
      }
    }
  });

  test('hech narsa tasdiqlangan deb belgilanmagan', () {
    for (final e in entries) {
      expect(e['status'], 'AWAITING_EXPERT', reason: e['id'] as String);
    }
  });

  test('har yozuvning fayli va belgisi hanuz mavjud', () {
    for (final e in entries) {
      final f = File(e['file'] as String);
      expect(f.existsSync(), isTrue, reason: '${e['id']}: ${e['file']}');
      expect(
        f.readAsStringSync().contains(e['symbol'] as String),
        isTrue,
        reason: '${e['id']}: "${e['symbol']}" not in ${e['file']}',
      );
    }
  });

  test('reyestr kerakli mavzularni qamrab oladi', () {
    final ids = entries.map((e) => e['id'] as String).toList();
    for (final p in [
      'ANC-',
      'EGFR-',
      'CORRECTED-CALCIUM',
      'PLATELET',
      'CALIB-',
      'IFU-',
      'TOIFA-KEY-KDL-T-158',
      'TOIFA-KEY-KDL-T-444',
      'EXPERT-QUESTIONS',
      'LABCARD-TB-',
      'LABCARD-HIV-',
      'DIFF-REFER-BODY',
      'HISTOLOGY-',
      'CYTOLOGY-',
    ]) {
      expect(ids.any((i) => i.startsWith(p)), isTrue, reason: p);
    }
  });
}
