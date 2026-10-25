// Ilmiy tekshiruv jadvali qorovuli (egasi topshirig‘i 4-band, 2026-10-25):
// docs/SCIENTIFIC_REVIEW_TABLE.csv — sxemalar (assets/diagrams, 6 mavzu ×
// uz/ru/en) va 32 apparat sxematik chizmasidagi har bir da’vo mutaxassis
// tekshiruvi uchun alohida qatorda. Qorovul tekshiradi:
//  * CSV bor (UTF-8 BOM), ustunlar to‘g‘ri, item_id takrorlanmaydi;
//  * 32 chizma kaliti va 6 mavzu (18 PNG) qamralgan;
//  * evidence_status ruxsat etilgan to‘plamda;
//  * specialist_decision / reviewed_by / review_date HAMMA qatorda bo‘sh —
//    hech kimning nomidan tasdiq yozilmaydi;
//  * SOURCED qatorida manba id bor (catalog:<id>, ARB kaliti, kod fayli);
//  * schematic_parts.json dagi har bir schemParts* qism / prinsip / natija
//    id jadvalda bor — yangi qism tekshiruv jadvalisiz chiqmaydi.
// Jadvalni qayta yaratish: python3 tool/review/make_scientific_review_tables.py
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _csvPath = 'docs/SCIENTIFIC_REVIEW_TABLE.csv';
const _columns = [
  'item_id',
  'kind',
  'artifact',
  'statement',
  'what_to_check',
  'source_evidence',
  'evidence_status',
  'reviewer_profile',
  'risk_if_wrong',
  'specialist_decision',
  'reviewed_by',
  'review_date',
];
const _statuses = {
  'SOURCED',
  'STANDARD_TEXTBOOK',
  'NEEDS_SOURCE',
  'NEEDS_EXPERT',
  'APP_RULE_AWAITING_EXPERT',
};
const _kinds = {
  'diagram',
  'schematic-part',
  'schematic-principle',
  'schematic-result',
  'schematic-drawing',
  'text-translation',
};
const _topics = [
  'qc_decision',
  'calibration_overview',
  'differential_count',
  'photometry',
  'preanalytics',
  'educational_feedback',
];

/// RFC 4180 CSV (qo‘shtirnoqli maydonlar, ichki "" va vergul/yangi qator).
List<List<String>> _parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      row.add(field.toString());
      field.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(field.toString());
      field.clear();
      rows.add(row);
      row = <String>[];
    } else {
      field.write(c);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

void main() {
  final file = File(_csvPath);

  test('CSV bor, UTF-8 BOM, ustunlar to‘g‘ri, item_id yagona', () {
    expect(file.existsSync(), isTrue, reason: _csvPath);
    final bytes = file.readAsBytesSync();
    expect(bytes.take(3).toList(), [0xEF, 0xBB, 0xBF], reason: 'UTF-8 BOM');
  });

  final text = file.existsSync()
      ? utf8.decode(file.readAsBytesSync()).replaceFirst('﻿', '')
      : '';
  final table = _parseCsv(text);
  final header = table.isEmpty ? <String>[] : table.first;
  final rows = [
    for (final r in table.skip(1))
      {for (var i = 0; i < header.length && i < r.length; i++) header[i]: r[i]},
  ];

  test('sarlavha va qatorlar tuzilishi', () {
    expect(header, _columns);
    expect(rows, isNotEmpty);
    for (final r in table.skip(1)) {
      expect(r, hasLength(_columns.length), reason: r.first);
    }
    final ids = [for (final r in rows) r['item_id']!];
    expect(ids.toSet().length, ids.length, reason: 'takroriy item_id');
    for (final r in rows) {
      expect(_kinds, contains(r['kind']), reason: r['item_id']);
      expect(r['statement']!.trim(), isNotEmpty, reason: r['item_id']);
      expect(r['what_to_check']!.trim(), isNotEmpty, reason: r['item_id']);
      expect(r['reviewer_profile']!.trim(), isNotEmpty, reason: r['item_id']);
      expect(
        r['risk_if_wrong'],
        matches(RegExp(r'^(high|medium|low) — \S')),
        reason: r['item_id'],
      );
    }
  });

  test('32 chizma kaliti va 6 mavzu (18 PNG) qamralgan', () {
    final parts = (jsonDecode(
      File('assets/instruments/schematic_parts.json').readAsStringSync(),
    ) as Map)['schematics'] as Map<String, Object?>;
    expect(parts.keys, hasLength(32));
    final ids = [for (final r in rows) r['item_id']!];
    for (final key in parts.keys) {
      for (final suffix in ['principle', 'result', 'part-01', 'drawing-01']) {
        expect(ids, contains('SCHEM-$key-$suffix'), reason: key);
      }
      for (final size in ['480', '1200']) {
        expect(
          File('assets/instruments/schematic/${key}_$size.png').existsSync(),
          isTrue,
          reason: key,
        );
      }
    }
    final pngs = Directory('assets/diagrams')
        .listSync()
        .map((e) => e.path.split('/').last)
        .where((n) => n.endsWith('.png'))
        .toSet();
    expect(pngs, hasLength(18));
    final topics = {for (final p in pngs) p.split('.').first};
    expect(topics, _topics.toSet(), reason: 'yangi mavzu jadvalga qo‘shilsin');
    final artifacts = rows.map((r) => r['artifact']!).join('\n');
    for (final t in _topics) {
      expect(ids.any((i) => i.startsWith('DIAG-$t-')), isTrue, reason: t);
      expect(artifacts, contains('assets/diagrams/$t.{uz,ru,en}.png'));
      for (final lang in ['uz', 'ru']) {
        expect(
          ids.any((i) => i.startsWith('DIAG-$t-l10n-$lang-')),
          isTrue,
          reason: '$t $lang tarjima qatorlari',
        );
        expect(artifacts, contains('assets/diagrams/$t.$lang.png'));
      }
      expect(ids, contains('DIAG-$t-alt-en'), reason: t);
    }
  });

  test('evidence_status ruxsat etilgan to‘plamda', () {
    for (final r in rows) {
      expect(_statuses, contains(r['evidence_status']), reason: r['item_id']);
    }
  });

  test('specialist_decision / reviewed_by / review_date bo‘sh (PENDING)', () {
    for (final r in rows) {
      for (final c in ['specialist_decision', 'reviewed_by', 'review_date']) {
        expect(r[c], isEmpty, reason: '${r['item_id']}: $c');
      }
    }
  });

  test('SOURCED qatorida manba id bor', () {
    final src = RegExp(
      r'catalog:[a-z0-9-]+|ARB `?[a-z][A-Za-z0-9]+|[\w/]+\.dart(:\d+)?|'
      r'assets/[\w/.{},-]+\.json',
    );
    for (final r in rows.where((r) => r['evidence_status'] == 'SOURCED')) {
      final ev = r['source_evidence']!;
      expect(ev, startsWith('src: '), reason: r['item_id']);
      expect(
        src.hasMatch(ev.split('; doc:').first),
        isTrue,
        reason: '${r['item_id']}: $ev',
      );
    }
    // Manbasiz qatorlar SOURCED emas.
    for (final r in rows.where((r) => r['source_evidence']!.startsWith('NONE'))) {
      expect(r['evidence_status'], isNot('SOURCED'), reason: r['item_id']);
    }
  });

  test('schematic_parts.json dagi har bir schemParts* id jadvalda bor', () {
    final parts = (jsonDecode(
      File('assets/instruments/schematic_parts.json').readAsStringSync(),
    ) as Map)['schematics'] as Map<String, Object?>;
    final artifacts = rows.map((r) => r['artifact']!).join('\n');
    final ids = {for (final r in rows) r['item_id']!};
    for (final e in parts.entries) {
      final m = e.value! as Map<String, Object?>;
      final list = (m['parts']! as List).cast<Map<String, Object?>>();
      for (final p in list) {
        final id = p['id']! as String;
        final n = p['n']! as int;
        expect(
          artifacts,
          contains('ARB ${id}Name/${id}Fn'),
          reason: '$id jadvalda yo‘q — tool/review/make_scientific_review_tables.py ni ishga tushiring',
        );
        expect(
          ids,
          contains('SCHEM-${e.key}-part-${n.toString().padLeft(2, '0')}'),
          reason: id,
        );
      }
      for (final k in ['principle_id', 'result_id']) {
        expect(artifacts, contains('ARB ${m[k]};'), reason: '${e.key} $k');
      }
    }
  });
}
