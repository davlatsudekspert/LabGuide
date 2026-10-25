/// CSV yozish (Excel / Sheets uchun): RFC 4180 qo'shtirnoq qoidasi va
/// formula in'eksiyasidan himoya (`= + - @` bilan boshlangan foydalanuvchi
/// matni oldiga `'`). Qiymatlar nuqta bilan (lokal formatsiz). Fayl UTF-8
/// BOM bilan boshlanadi — Excel kirill va o‘ g‘ ni to'g'ri ochadi.
library;

import 'dart:convert';
import 'dart:typed_data';

String csvCell(String v) {
  if (v.contains(RegExp(r'[",\n\r;]'))) return '"${v.replaceAll('"', '""')}"';
  return v;
}

/// Foydalanuvchi kiritgan matn (nom, lot, izoh) — formula sifatida
/// bajarilmasin.
String csvText(String v) => v.startsWith(RegExp('[=+\\-@\t\r]')) ? "'$v" : v;

/// Raqam: nuqta bilan, ortiqcha nolsiz emas — [digits] xona.
String csvNum(num? v, [int digits = 2]) =>
    v == null || !v.isFinite ? '' : v.toStringAsFixed(digits);

String _two(int v) => v.toString().padLeft(2, '0');

/// `2026-10-25 14:05` (qurilma vaqti).
String csvDateTime(DateTime t) {
  final l = t.toLocal();
  return '${l.year}-${_two(l.month)}-${_two(l.day)} ${_two(l.hour)}:${_two(l.minute)}';
}

/// `2026-10-25`.
String csvDate(DateTime t) {
  final l = t.toLocal();
  return '${l.year}-${_two(l.month)}-${_two(l.day)}';
}

/// Qatorlar → CSV matni (oxirida yangi qator).
String encodeCsv(List<List<String>> rows) =>
    '${rows.map((r) => r.map(csvCell).join(',')).join('\r\n')}\r\n';

/// UTF-8 BOM bilan baytlar.
Uint8List csvBytes(List<List<String>> rows) =>
    Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(encodeCsv(rows))]);
