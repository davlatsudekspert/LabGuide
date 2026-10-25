// PDF hisobot yozuvchisi (D-78, tashqi paketsiz): tuzilma (xref ofsetlari,
// sahifalar), joylangan Inter shrifti, uz/ru/en matni glifga o'giriladi va
// ToUnicode orqali qaytarib o'qiladi, sahifa bo'linishi va jadval sarlavhasi.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/export/csv.dart';
import 'package:labguide/core/export/pdf_report.dart';

PdfFont _font(String file, String name) => PdfFont.parse(
  Uint8List.fromList(File('assets/fonts/$file').readAsBytesSync()),
  name: name,
);

/// Barcha FlateDecode oqimlari (ochilgan).
List<String> _streams(Uint8List pdf) {
  final text = latin1.decode(pdf);
  final out = <String>[];
  final rx = RegExp(r'/Length (\d+)[^>]*?/FlateDecode[^>]*>>\nstream\n');
  for (final m in rx.allMatches(text)) {
    final len = int.parse(m[1]!);
    final body = pdf.sublist(m.end, m.end + len);
    try {
      out.add(latin1.decode(ZLibCodec().decode(body)));
    } on Object {
      // Shrift fayli emas bo'lishi mumkin — e'tiborsiz.
    }
  }
  return out;
}

/// Sahifa matnini ToUnicode jadvali bilan qaytarib o'qish.
String _extract(Uint8List pdf) {
  final streams = _streams(pdf);
  final map = <int, String>{};
  for (final s in streams.where((s) => s.contains('beginbfchar'))) {
    for (final m in RegExp(r'<([0-9a-f]{4})> <([0-9a-f]+)>').allMatches(s)) {
      final units = [
        for (var i = 0; i < m[2]!.length; i += 4)
          int.parse(m[2]!.substring(i, i + 4), radix: 16),
      ];
      // F1 va F2 glif raqamlari mos kelishi mumkin — bir xil belgi.
      map[int.parse(m[1]!, radix: 16)] ??= String.fromCharCodes(units);
    }
  }
  final b = StringBuffer();
  for (final s in streams.where((s) => s.contains(' Tj'))) {
    for (final m in RegExp(r'<([0-9a-f]+)> Tj').allMatches(s)) {
      final hex = m[1]!;
      for (var i = 0; i < hex.length; i += 4) {
        b.write(map[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '?');
      }
      b.write('\n');
    }
  }
  return b.toString();
}

void main() {
  final regular = _font('Inter-400.ttf', 'Inter');
  final bold = _font('Inter-600.ttf', 'Inter-SemiBold');

  test('Inter: lotin, o‘zbek (o‘ g‘ ʼ), kirill va belgilar glifga ega', () {
    for (final ch in 'Aao‘g‘’ЖжЎўҚқҒғҲҳ±—x̄%№'.runes) {
      expect(regular.glyphOf(ch), isNot(0), reason: String.fromCharCode(ch));
      expect(bold.glyphOf(ch), isNot(0), reason: String.fromCharCode(ch));
    }
    expect(regular.measure('LabGuide', 10), greaterThan(30));
    expect(regular.measure('', 10), 0);
  });

  test('tuzilma: sarlavha, xref ofsetlari, trailer, sahifalar soni', () {
    final b = PdfReportBuilder(
      regular: regular,
      bold: bold,
      title: 'Kalibrlash jurnali',
      footerNote: 'Klinik qaror emas',
    )
      ..heading1('Kalibrlash jurnali')
      ..text('Qo‘llanma — Журнал калибровки — Calibration log')
      ..keyValues([('Lot', 'L-77'), ('Natija', 'Qabul qilindi')])
      ..table(['Daraja', 'Qiymat', 'Birlik'], [
        ['1', '5.55', 'mmol/L'],
      ]);
    final pdf = b.build(created: DateTime.utc(2026, 10, 25, 12));
    final text = latin1.decode(pdf);
    expect(text, startsWith('%PDF-1.7'));
    expect(text.trimRight(), endsWith('%%EOF'));
    final xref = int.parse(RegExp(r'startxref\n(\d+)').firstMatch(text)![1]!);
    expect(text.substring(xref), startsWith('xref\n'));
    final entries = RegExp(r'(\d{10}) 00000 n ')
        .allMatches(text.substring(xref))
        .map((m) => int.parse(m[1]!))
        .toList();
    expect(entries, isNotEmpty);
    for (final (i, off) in entries.indexed) {
      expect(text.substring(off), startsWith('${i + 1} 0 obj'), reason: '$i');
    }
    expect(RegExp(r'/Type /Page ').allMatches(text), hasLength(1));
    expect(text, contains('/Count 1'));
    expect(text, contains('/FontFile2'));
    expect(text, contains('/Encoding /Identity-H'));
    expect(text, contains('/CreationDate (D:20261025120000Z)'));
    final words = _extract(pdf);
    for (final w in [
      'Kalibrlash jurnali',
      'Qo‘llanma — Журнал калибровки — Calibration log',
      'L-77',
      'mmol/L',
      'Klinik qaror emas',
      '1 / 1',
    ]) {
      expect(words, contains(w), reason: w);
    }
  });

  test('uzun jadval sahifalarga bo‘linadi, sarlavha har sahifada, '
      '“n / N” raqami', () {
    final b = PdfReportBuilder(
      regular: regular,
      bold: bold,
      title: 'QC',
      pageLabel: (p, t) => 'sahifa $p / $t',
    )..table(['Sana', 'Qiymat'], [
      for (var i = 0; i < 120; i++) ['2026-10-${i % 28 + 1}', '$i'],
    ]);
    expect(b.pageCount, greaterThan(1));
    final pdf = b.build();
    final words = _extract(pdf);
    expect('Sana'.allMatches(words).length, b.pageCount);
    expect(words, contains('sahifa ${b.pageCount} / ${b.pageCount}'));
    expect(words, contains('119'));
  });

  test('uzun so‘z va matn qatorlarga bo‘linadi (kenglikdan oshmaydi)', () {
    final b = PdfReportBuilder(regular: regular, bold: bold, title: 't');
    final lines = b.wrap('${'A' * 400} so‘z', 10, 200);
    expect(lines.length, greaterThan(2));
    for (final l in lines) {
      expect(regular.measure(l, 10), lessThanOrEqualTo(200.5));
    }
  });

  test('CSV: BOM, qo‘shtirnoq, formula in’eksiyasidan himoya', () {
    final bytes = csvBytes([
      ['a', 'b'],
      ['=1+1', 'x,"y"'],
      [csvText('=SUM(A1)'), csvText('-5'), 'o‘g‘il'],
    ]);
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    final text = utf8.decode(bytes.sublist(3));
    expect(text, startsWith('a,b\r\n'));
    expect(text, contains('"x,""y"""'));
    expect(text, contains("'=SUM(A1),'-5,o‘g‘il"));
    expect(csvNum(1.23456, 3), '1.235');
    expect(csvNum(null), '');
    expect(csvNum(double.nan), '');
  });
}
