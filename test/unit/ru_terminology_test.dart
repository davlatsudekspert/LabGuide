import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ruscha atamalar: ГОСТ Р ИСО 15189 bo'yicha «референтный интервал»
/// («референсный» emas) va ruscha matnda lotin birliklari (mg/dL) yo'q.
/// Rasmiy manba nomlari/iqtiboslari bundan mustasno (ularda bu so'zlar
/// pack.json `ru` maydonlarida uchramaydi).
void main() {
  final bad = RegExp('референс', caseSensitive: false);
  final latinUnits = RegExp(r'\b(mg/dL|mmol/L|µmol/L|g/dL|ng/mL|IU/L|mg/24)');

  void walk(Object? o, String path, void Function(String path, String ru) f) {
    if (o is Map) {
      for (final e in o.entries) {
        if (e.key == 'ru' && e.value is String) {
          f('$path/ru', e.value as String);
        } else {
          walk(e.value, '$path/${e.key}', f);
        }
      }
    } else if (o is List) {
      for (var i = 0; i < o.length; i++) {
        walk(o[i], '$path/$i', f);
      }
    }
  }

  test('pack.json ruscha maydonlarda «референс*» va lotin birliklari yo‘q', () {
    final pack = jsonDecode(
      File('assets/content/core/pack.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final offenders = <String>[];
    walk(pack, '', (path, ru) {
      if (bad.hasMatch(ru)) offenders.add('$path: референс');
      final m = latinUnits.firstMatch(ru);
      if (m != null) offenders.add('$path: ${m.group(0)}');
    });
    expect(offenders, isEmpty);
  });

  test('app_ru.arb: «референс*» va lotin birliklari yo‘q', () {
    final arb = jsonDecode(
      File('lib/l10n/app_ru.arb').readAsStringSync(),
    ) as Map<String, Object?>;
    final offenders = <String>[];
    for (final e in arb.entries) {
      final v = e.value;
      if (e.key.startsWith('@') || v is! String) continue;
      if (bad.hasMatch(v)) offenders.add('${e.key}: референс');
      final m = latinUnits.firstMatch(v);
      if (m != null) offenders.add('${e.key}: ${m.group(0)}');
    }
    expect(offenders, isEmpty);
  });

  test('ruscha kontent fayllarida «референс*» yo‘q', () {
    final offenders = <String>[];
    for (final f in Directory('lib/features').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        // O'zbek kirill manba nomi («референс кўрсаткичлари») — rasmiy.
        if (bad.hasMatch(lines[i]) && !lines[i].contains('кўрсаткич')) {
          offenders.add('${f.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
