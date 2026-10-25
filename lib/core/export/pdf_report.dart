/// Oddiy PDF hisobot yozuvchisi (tashqi paketsiz, D-78): A4 sahifalar,
/// sarlavha, matn, kalit–qiymat qatorlari va jadval; matn tanlanadi va
/// qidiriladi (ToUnicode). Shrift — ilova bilan keladigan Inter (TrueType,
/// lotin + kirill + o‘ g‘ belgilari), PDF ichiga to'liq joylanadi
/// (CIDFontType2, Identity-H). Sahifa pastida "sahifa n / N" va izoh.
///
/// Faqat eksport uchun: hech qanday tarmoq yoki plagin ishlatilmaydi.
library;

import 'dart:convert';
import 'dart:io' show ZLibCodec;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle;

/// TrueType shrift metrikasi (faqat PDF uchun kerakli jadvallar).
class PdfFont {
  PdfFont._(
    this.bytes, {
    required this.unitsPerEm,
    required this.ascent,
    required this.descent,
    required this.capHeight,
    required this.bbox,
    required this._advances,
    required this._cmap,
    required this.postScriptName,
  });

  /// [bytes] — `.ttf` fayl (glyf jadvalli TrueType).
  factory PdfFont.parse(Uint8List bytes, {String name = 'Inter'}) {
    final d = ByteData.sublistView(bytes);
    final tables = <String, int>{};
    final count = d.getUint16(4);
    for (var i = 0; i < count; i++) {
      final at = 12 + 16 * i;
      final tag = String.fromCharCodes(bytes.sublist(at, at + 4));
      tables[tag] = d.getUint32(at + 8);
    }
    int table(String t) =>
        tables[t] ?? (throw FormatException('TrueType: $t yo‘q'));
    final head = table('head');
    final hhea = table('hhea');
    final maxp = table('maxp');
    final hmtx = table('hmtx');
    final unitsPerEm = d.getUint16(head + 18);
    final bbox = [
      for (var i = 0; i < 4; i++) d.getInt16(head + 36 + 2 * i),
    ];
    final ascent = d.getInt16(hhea + 4);
    final descent = d.getInt16(hhea + 6);
    final hMetrics = d.getUint16(hhea + 34);
    final glyphs = d.getUint16(maxp + 4);
    final advances = List<int>.filled(glyphs, 0);
    var last = 0;
    for (var g = 0; g < glyphs; g++) {
      if (g < hMetrics) last = d.getUint16(hmtx + 4 * g);
      advances[g] = last;
    }
    var capHeight = (ascent * 0.7).round();
    if (tables['OS/2'] case final os2?) {
      if (d.getUint16(os2) >= 2) capHeight = d.getInt16(os2 + 88);
    }
    return PdfFont._(
      bytes,
      unitsPerEm: unitsPerEm,
      ascent: ascent,
      descent: descent,
      capHeight: capHeight,
      bbox: bbox,
      advances: advances,
      cmap: _readCmap(d, table('cmap')),
      postScriptName: name,
    );
  }

  static Map<int, int> _readCmap(ByteData d, int cmap) {
    final n = d.getUint16(cmap + 2);
    int? fmt12;
    int? fmt4;
    for (var i = 0; i < n; i++) {
      final rec = cmap + 4 + 8 * i;
      final platform = d.getUint16(rec);
      final encoding = d.getUint16(rec + 2);
      final sub = cmap + d.getUint32(rec + 4);
      final format = d.getUint16(sub);
      if (format == 12 && (platform == 3 || platform == 0)) fmt12 ??= sub;
      if (format == 4 && (platform == 3 && encoding == 1 || platform == 0)) {
        fmt4 ??= sub;
      }
    }
    final out = <int, int>{};
    if (fmt12 != null) {
      final groups = d.getUint32(fmt12 + 12);
      for (var g = 0; g < groups; g++) {
        final at = fmt12 + 16 + 12 * g;
        final start = d.getUint32(at);
        final end = d.getUint32(at + 4);
        final glyph = d.getUint32(at + 8);
        for (var c = start; c <= end && c < 0x30000; c++) {
          out[c] = glyph + (c - start);
        }
      }
      return out;
    }
    if (fmt4 == null) throw const FormatException('TrueType: cmap yo‘q');
    final segs = d.getUint16(fmt4 + 6) ~/ 2;
    final ends = fmt4 + 14;
    final starts = ends + 2 * segs + 2;
    final deltas = starts + 2 * segs;
    final ranges = deltas + 2 * segs;
    for (var s = 0; s < segs; s++) {
      final end = d.getUint16(ends + 2 * s);
      final start = d.getUint16(starts + 2 * s);
      final delta = d.getInt16(deltas + 2 * s);
      final range = d.getUint16(ranges + 2 * s);
      for (var c = start; c <= end && c != 0xFFFF; c++) {
        int glyph;
        if (range == 0) {
          glyph = (c + delta) & 0xFFFF;
        } else {
          final at = ranges + 2 * s + range + 2 * (c - start);
          glyph = d.getUint16(at);
          if (glyph != 0) glyph = (glyph + delta) & 0xFFFF;
        }
        if (glyph != 0) out[c] = glyph;
      }
    }
    return out;
  }

  final Uint8List bytes;
  final int unitsPerEm;
  final int ascent;
  final int descent;
  final int capHeight;
  final List<int> bbox;
  final String postScriptName;
  final List<int> _advances;
  final Map<int, int> _cmap;

  /// Belgi uchun glif (yo'q bo'lsa — 0, `.notdef`).
  int glyphOf(int rune) => _cmap[rune] ?? 0;

  /// Glif kengligi — 1000 birlikda (PDF).
  double width1000(int glyph) =>
      (glyph < _advances.length ? _advances[glyph] : 0) * 1000 / unitsPerEm;

  /// Matn kengligi (pt) — [size] pt shriftda.
  double measure(String text, double size) {
    var w = 0.0;
    for (final r in text.runes) {
      w += width1000(glyphOf(r));
    }
    return w * size / 1000;
  }
}

/// RGB rang (0–1).
@immutable
class PdfColor {
  const PdfColor(this.r, this.g, this.b);

  static const black = PdfColor(0.1, 0.1, 0.12);
  static const grey = PdfColor(0.42, 0.42, 0.46);
  static const line = PdfColor(0.82, 0.82, 0.85);
  static const headerFill = PdfColor(0.93, 0.94, 0.96);

  final double r;
  final double g;
  final double b;

  String get _rgb => '${_n(r)} ${_n(g)} ${_n(b)}';
}

String _n(double v) {
  final s = v.toStringAsFixed(2);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

/// Sahifadagi chizish buyrug'i.
sealed class _Op {}

class _TextOp extends _Op {
  _TextOp(this.text, this.x, this.y, this.size, this.bold, this.color);
  final String text;
  final double x;
  final double y;
  final double size;
  final bool bold;
  final PdfColor color;
}

class _LineOp extends _Op {
  _LineOp(this.x1, this.y1, this.x2, this.y2, this.color);
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final PdfColor color;
}

class _RectOp extends _Op {
  _RectOp(this.x, this.y, this.w, this.h, this.color);
  final double x;
  final double y;
  final double w;
  final double h;
  final PdfColor color;
}

/// A4 hisobot quruvchisi. Elementlar yuqoridan pastga joylanadi; joy
/// tugasa yangi sahifa ochiladi (jadval sarlavhasi takrorlanadi).
class PdfReportBuilder {
  PdfReportBuilder({
    required this.regular,
    required this.bold,
    required this.title,
    this.footerNote = '',
    this.pageLabel,
  }) {
    _newPage();
  }

  static const pageWidth = 595.28;
  static const pageHeight = 841.89;
  static const margin = 40.0;
  static const _bottom = margin + 28;

  final PdfFont regular;
  final PdfFont bold;

  /// Hujjat nomi (PDF metama'lumoti).
  final String title;

  /// Har sahifa pastidagi izoh (masalan, "Klinik qaror emas").
  final String footerNote;

  /// `"sahifa 1 / 3"` matni: (joriy, jami) → matn.
  final String Function(int page, int total)? pageLabel;

  final _pages = <List<_Op>>[];
  late double _y;

  double get _width => pageWidth - 2 * margin;

  void _newPage() {
    _pages.add(<_Op>[]);
    _y = pageHeight - margin;
  }

  void _ensure(double h) {
    if (_y - h < _bottom) _newPage();
  }

  PdfFont _font(bool b) => b ? bold : regular;

  /// [text] ni [maxWidth] ga sig'adigan qatorlarga bo'lish.
  List<String> wrap(String text, double size, double maxWidth, {bool b = false}) {
    final font = _font(b);
    final out = <String>[];
    for (final para in text.split('\n')) {
      var line = '';
      for (final word in para.split(' ')) {
        final next = line.isEmpty ? word : '$line $word';
        if (font.measure(next, size) <= maxWidth) {
          line = next;
          continue;
        }
        if (line.isNotEmpty) out.add(line);
        // Juda uzun so'z — belgilar bo'yicha bo'linadi.
        var rest = word;
        while (font.measure(rest, size) > maxWidth && rest.length > 1) {
          var cut = rest.length - 1;
          while (cut > 1 && font.measure(rest.substring(0, cut), size) > maxWidth) {
            cut--;
          }
          out.add(rest.substring(0, cut));
          rest = rest.substring(cut);
        }
        line = rest;
      }
      out.add(line);
    }
    return out;
  }

  void _lines(
    List<String> lines,
    double size, {
    bool b = false,
    PdfColor color = PdfColor.black,
    double indent = 0,
  }) {
    final lh = size * 1.35;
    for (final line in lines) {
      _ensure(lh);
      _y -= lh;
      _pages.last.add(_TextOp(line, margin + indent, _y + size * 0.25, size, b, color));
    }
  }

  /// Hujjat sarlavhasi.
  void heading1(String text) {
    _lines(wrap(text, 17, _width, b: true), 17, b: true);
    gap(4);
  }

  /// Bo'lim sarlavhasi.
  void heading2(String text) {
    gap(8);
    _ensure(40);
    _lines(wrap(text, 12.5, _width, b: true), 12.5, b: true);
    gap(2);
  }

  /// Oddiy matn.
  void text(
    String text, {
    double size = 9.5,
    bool b = false,
    PdfColor color = PdfColor.black,
  }) => _lines(wrap(text, size, _width, b: b), size, b: b, color: color);

  /// Kalit — qiymat qatorlari (ikki ustun).
  void keyValues(List<(String, String)> rows, {double size = 9.5}) {
    const keyWidth = 170.0;
    final lh = size * 1.35;
    for (final (k, v) in rows) {
      final kl = wrap(k, size, keyWidth - 8);
      final vl = wrap(v, size, _width - keyWidth, b: true);
      final n = math.max(kl.length, vl.length);
      _ensure(n * lh);
      for (var i = 0; i < n; i++) {
        _y -= lh;
        final base = _y + size * 0.25;
        if (i < kl.length) {
          _pages.last.add(_TextOp(kl[i], margin, base, size, false, PdfColor.grey));
        }
        if (i < vl.length) {
          _pages.last.add(
            _TextOp(vl[i], margin + keyWidth, base, size, true, PdfColor.black),
          );
        }
      }
    }
  }

  /// Jadval: [widths] — nisbiy ustun kengliklari (berilmasa — teng).
  void table(
    List<String> headers,
    List<List<String>> rows, {
    List<double>? widths,
    double size = 8,
  }) {
    final total = (widths ?? List.filled(headers.length, 1.0)).fold<double>(
      0,
      (a, b) => a + b,
    );
    final cols = [
      for (final w in widths ?? List.filled(headers.length, 1.0))
        w / total * _width,
    ];
    const pad = 3.0;
    final lh = size * 1.3;

    List<List<String>> cells(List<String> row, bool b) => [
      for (var i = 0; i < cols.length; i++)
        wrap(i < row.length ? row[i] : '', size, cols[i] - 2 * pad, b: b),
    ];

    void drawRow(List<List<String>> c, {required bool header}) {
      final n = c.fold<int>(1, (a, l) => math.max(a, l.length));
      final h = n * lh + 2 * pad;
      final top = _y;
      if (header) {
        _pages.last.add(_RectOp(margin, top - h, _width, h, PdfColor.headerFill));
      }
      var x = margin;
      for (var i = 0; i < cols.length; i++) {
        for (final (j, line) in c[i].indexed) {
          _pages.last.add(
            _TextOp(
              line,
              x + pad,
              top - pad - (j + 1) * lh + size * 0.3,
              size,
              header,
              PdfColor.black,
            ),
          );
        }
        x += cols[i];
      }
      _y -= h;
      _pages.last.add(_LineOp(margin, _y, margin + _width, _y, PdfColor.line));
    }

    final head = cells(headers, true);
    double heightOf(List<List<String>> c) =>
        c.fold<int>(1, (a, l) => math.max(a, l.length)) * lh + 2 * pad;
    _ensure(heightOf(head) + lh * 2);
    drawRow(head, header: true);
    for (final row in rows) {
      final c = cells(row, false);
      if (_y - heightOf(c) < _bottom) {
        _newPage();
        drawRow(head, header: true);
      }
      drawRow(c, header: false);
    }
    gap(6);
  }

  void gap([double h = 8]) {
    _y -= h;
    if (_y < _bottom) _newPage();
  }

  /// Sahifalar soni (yig'ilgandan keyin).
  int get pageCount => _pages.length;

  /// PDF baytlari.
  Uint8List build({DateTime? created}) {
    final w = _PdfWriter();
    final fonts = [regular, bold];
    final used = [<int, int>{}, <int, int>{}]; // glif → belgi
    String hex(String text, int f) {
      final b = StringBuffer('<');
      for (final r in text.runes) {
        final g = fonts[f].glyphOf(r);
        used[f].putIfAbsent(g, () => r);
        b.write(g.toRadixString(16).padLeft(4, '0'));
      }
      b.write('>');
      return b.toString();
    }

    final total = _pages.length;
    final contents = <String>[];
    for (final (i, ops) in _pages.indexed) {
      final s = StringBuffer();
      void textOp(_TextOp t) {
        final f = t.bold ? 1 : 0;
        s.write(
          'BT ${t.color._rgb} rg /F${f + 1} ${_n(t.size)} Tf '
          '${_n(t.x)} ${_n(t.y)} Td ${hex(t.text, f)} Tj ET\n',
        );
      }

      for (final op in ops) {
        switch (op) {
          case _RectOp(:final x, :final y, :final w, :final h, :final color):
            s.write('${color._rgb} rg ${_n(x)} ${_n(y)} ${_n(w)} ${_n(h)} re f\n');
          case _LineOp(:final x1, :final y1, :final x2, :final y2, :final color):
            s.write(
              '${color._rgb} RG 0.5 w ${_n(x1)} ${_n(y1)} m ${_n(x2)} ${_n(y2)} l S\n',
            );
          case final _TextOp t:
            textOp(t);
        }
      }
      // Pastki qism: izoh va sahifa raqami.
      s.write('${PdfColor.line._rgb} RG 0.5 w ${_n(margin)} ${_n(margin + 16)} m '
          '${_n(pageWidth - margin)} ${_n(margin + 16)} l S\n');
      if (footerNote.isNotEmpty) {
        final note = wrap(footerNote, 7, _width - 70).first;
        textOp(_TextOp(note, margin, margin + 4, 7, false, PdfColor.grey));
      }
      final label = pageLabel?.call(i + 1, total) ?? '${i + 1} / $total';
      textOp(
        _TextOp(
          label,
          pageWidth - margin - regular.measure(label, 7),
          margin + 4,
          7,
          false,
          PdfColor.grey,
        ),
      );
      contents.add(s.toString());
    }

    final catalog = w.reserve();
    final pages = w.reserve();
    final fontRefs = [for (final _ in fonts) w.reserve()];
    final pageRefs = <int>[];
    for (final c in contents) {
      final stream = w.stream(latin1.encode(c), compress: true);
      final page = w.add(
        '<< /Type /Page /Parent $pages 0 R /MediaBox [0 0 ${_n(pageWidth)} '
        '${_n(pageHeight)}] /Resources << /Font << /F1 ${fontRefs[0]} 0 R '
        '/F2 ${fontRefs[1]} 0 R >> >> /Contents $stream 0 R >>',
      );
      pageRefs.add(page);
    }
    w.set(
      pages,
      '<< /Type /Pages /Kids [${pageRefs.map((p) => '$p 0 R').join(' ')}] '
      '/Count ${pageRefs.length} >>',
    );
    for (final (i, font) in fonts.indexed) {
      final name = font.postScriptName;
      final file = w.stream(
        font.bytes,
        compress: true,
        extra: '/Length1 ${font.bytes.length}',
      );
      double scale(num v) => v * 1000 / font.unitsPerEm;
      final descriptor = w.add(
        '<< /Type /FontDescriptor /FontName /$name /Flags 32 /FontBBox '
        '[${font.bbox.map((v) => _n(scale(v))).join(' ')}] /ItalicAngle 0 '
        '/Ascent ${_n(scale(font.ascent))} /Descent ${_n(scale(font.descent))} '
        '/CapHeight ${_n(scale(font.capHeight))} /StemV ${i == 0 ? 80 : 140} '
        '/FontFile2 $file 0 R >>',
      );
      final glyphs = used[i].keys.toList()..sort();
      final widths = [
        for (final g in glyphs) '$g [${_n(font.width1000(g))}]',
      ].join(' ');
      final cid = w.add(
        '<< /Type /Font /Subtype /CIDFontType2 /BaseFont /$name '
        '/CIDSystemInfo << /Registry (Adobe) /Ordering (Identity) '
        '/Supplement 0 >> /FontDescriptor $descriptor 0 R /DW 1000 '
        '/W [$widths] /CIDToGIDMap /Identity >>',
      );
      final toUnicode = w.stream(
        latin1.encode(_cmap(used[i])),
        compress: true,
      );
      w.set(
        fontRefs[i],
        '<< /Type /Font /Subtype /Type0 /BaseFont /$name /Encoding /Identity-H '
        '/DescendantFonts [$cid 0 R] /ToUnicode $toUnicode 0 R >>',
      );
    }
    w.set(catalog, '<< /Type /Catalog /Pages $pages 0 R >>');
    final t = (created ?? DateTime.now()).toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    final date =
        'D:${t.year}${two(t.month)}${two(t.day)}${two(t.hour)}${two(t.minute)}${two(t.second)}Z';
    final info = w.add(
      '<< /Title ${_utf16(title)} /Producer (LabGuide) /Creator (LabGuide) '
      '/CreationDate ($date) >>',
    );
    return w.finish(root: catalog, info: info);
  }

  static String _utf16(String s) {
    final b = StringBuffer('<FEFF');
    for (final unit in s.codeUnits) {
      b.write(unit.toRadixString(16).padLeft(4, '0'));
    }
    b.write('>');
    return b.toString();
  }

  static String _cmap(Map<int, int> used) {
    final entries = used.entries.toList()..sort((a, b) => a.key - b.key);
    final b = StringBuffer(
      '/CIDInit /ProcSet findresource begin\n12 dict begin\nbegincmap\n'
      '/CIDSystemInfo << /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def\n'
      '/CMapName /Adobe-Identity-UCS def\n/CMapType 2 def\n'
      '1 begincodespacerange\n<0000> <FFFF>\nendcodespacerange\n',
    );
    for (var i = 0; i < entries.length; i += 100) {
      final chunk = entries.skip(i).take(100).toList();
      b.write('${chunk.length} beginbfchar\n');
      for (final e in chunk) {
        final units = String.fromCharCode(e.value).codeUnits;
        b.write(
          '<${e.key.toRadixString(16).padLeft(4, '0')}> '
          '<${units.map((u) => u.toRadixString(16).padLeft(4, '0')).join()}>\n',
        );
      }
      b.write('endbfchar\n');
    }
    b.write('endcmap\nCMapName currentdict /CMap defineresource pop\nend\nend\n');
    return b.toString();
  }
}

/// Past darajali PDF obyektlari va xref jadvali.
class _PdfWriter {
  final _objects = <List<int>?>[];

  int reserve() {
    _objects.add(null);
    return _objects.length;
  }

  void set(int ref, String body) => _objects[ref - 1] = latin1.encode(body);

  int add(String body) {
    final r = reserve();
    set(r, body);
    return r;
  }

  int stream(List<int> data, {bool compress = false, String extra = ''}) {
    final body = compress ? ZLibCodec(level: 6).encode(data) : data;
    final r = reserve();
    _objects[r - 1] = [
      ...latin1.encode(
        '<< /Length ${body.length}${compress ? ' /Filter /FlateDecode' : ''}'
        '${extra.isEmpty ? '' : ' $extra'} >>\nstream\n',
      ),
      ...body,
      ...latin1.encode('\nendstream'),
    ];
    return r;
  }

  Uint8List finish({required int root, required int info}) {
    final out = BytesBuilder(copy: false)
      ..add(latin1.encode('%PDF-1.7\n'))
      ..add(const [0x25, 0xE2, 0xE3, 0xCF, 0xD3, 0x0A]);
    final offsets = <int>[];
    for (final (i, o) in _objects.indexed) {
      offsets.add(out.length);
      out
        ..add(latin1.encode('${i + 1} 0 obj\n'))
        ..add(o ?? latin1.encode('null'))
        ..add(latin1.encode('\nendobj\n'));
    }
    final xref = out.length;
    final b = StringBuffer('xref\n0 ${_objects.length + 1}\n0000000000 65535 f \n');
    for (final off in offsets) {
      b.write('${off.toString().padLeft(10, '0')} 00000 n \n');
    }
    b.write(
      'trailer\n<< /Size ${_objects.length + 1} /Root $root 0 R /Info $info 0 R >>\n'
      'startxref\n$xref\n%%EOF\n',
    );
    out.add(latin1.encode(b.toString()));
    return out.toBytes();
  }
}

/// Ilova shriftlari (Inter 400 va 600) — PDF uchun, bir marta yuklanadi.
abstract final class PdfFonts {
  static (PdfFont, PdfFont)? _cache;

  static Future<(PdfFont, PdfFont)> load(AssetBundle bundle) async {
    if (_cache case final c?) return c;
    Future<PdfFont> one(String asset, String name) async {
      final data = await bundle.load(asset);
      return PdfFont.parse(
        Uint8List.sublistView(data),
        name: name,
      );
    }

    return _cache = (
      await one('assets/fonts/Inter-400.ttf', 'Inter'),
      await one('assets/fonts/Inter-600.ttf', 'Inter-SemiBold'),
    );
  }
}
