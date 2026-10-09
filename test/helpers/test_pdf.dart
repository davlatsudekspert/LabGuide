import 'dart:convert';
import 'dart:typed_data';

/// Mundarija (outline) bandi: sarlavha, sahifa (1 dan) va ichki bandlar.
class TestPdfHeading {
  const TestPdfHeading(this.title, this.page, [this.children = const []]);

  final String title;
  final int page;
  final List<TestPdfHeading> children;
}

/// Sinov uchun standart mundarija: boblar va bitta ichki bo'lim.
const testPdfOutline = [
  TestPdfHeading('1. Kirish', 1),
  TestPdfHeading("2. Sinov bo'limi", 3, [
    TestPdfHeading("2.1. Ichki bo'lim", 4),
  ]),
  TestPdfHeading("3. Xatcho'plar sinovi", 6),
  TestPdfHeading('4. Yakun', 9),
];

/// "LabGuide sinov hujjati" — testlar uchun dasturiy yaratiladigan kichik
/// PDF (begona fayl repoga qo'shilmaydi). Faqat ASCII matn va Helvetica
/// (PDF ning standart shriftlaridan biri — fayl ichiga joylanmaydi).
Uint8List buildTestPdf({
  int pages = 10,
  List<TestPdfHeading> outline = testPdfOutline,
}) {
  final objects = <int, String>{};
  var next = 1;
  int reserve() => next++;

  final catalog = reserve();
  final pagesRoot = reserve();
  final outlinesRoot = reserve();
  final font = reserve();
  final fontBold = reserve();
  final pageIds = [for (var i = 0; i < pages; i++) reserve()];
  final contentIds = [for (var i = 0; i < pages; i++) reserve()];

  String chapterOf(int page) {
    var title = '';
    void walk(List<TestPdfHeading> items) {
      for (final h in items) {
        if (h.page <= page) title = h.title;
        walk(h.children);
      }
    }

    walk(outline);
    return title;
  }

  String esc(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');

  const lines = [
    'Bu hujjat faqat ilova sinovi uchun yaratilgan.',
    "Unda tibbiy yoki texnik ma'lumot yo'q.",
    "Mundarija, xatcho'p va sahifaga o'tish shu fayl bilan tekshiriladi.",
  ];
  for (var i = 0; i < pages; i++) {
    final n = i + 1;
    final body = StringBuffer()
      // Yuqoridagi rangli chiziq.
      ..writeln('0.11 0.42 0.39 rg 0 792 595 50 re f')
      ..writeln(
        'BT /F2 13 Tf 1 1 1 rg 40 810 Td (LabGuide sinov hujjati) Tj ET',
      )
      ..writeln(
        'BT /F2 26 Tf 0.1 0.1 0.1 rg 40 720 Td (${esc(chapterOf(n))}) Tj ET',
      )
      ..writeln(
        'BT /F1 14 Tf 0.3 0.3 0.3 rg 40 690 Td (Sahifa $n / $pages) Tj ET',
      );
    for (var j = 0; j < lines.length; j++) {
      body.writeln(
        'BT /F1 13 Tf 0.2 0.2 0.2 rg 40 ${640 - j * 22} Td '
        '(${esc(lines[j])}) Tj ET',
      );
    }
    // Katta sahifa raqami — skrinshotda qaysi sahifa ochiqligi ko'rinsin.
    body.writeln('BT /F2 160 Tf 0.8 0.88 0.87 rg 200 280 Td ($n) Tj ET');
    final stream = body.toString();
    objects[contentIds[i]] =
        '<< /Length ${latin1.encode(stream).length} >>\n'
        'stream\n${stream}endstream';
    objects[pageIds[i]] =
        '<< /Type /Page /Parent $pagesRoot 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 $font 0 R /F2 $fontBold 0 R >> >> '
        '/Contents ${contentIds[i]} 0 R >>';
  }

  // Mundarija daraxti: har band — /Dest bilan sahifaga.
  (int, int, int) writeOutline(List<TestPdfHeading> items, int parent) {
    final ids = [for (final _ in items) reserve()];
    var total = 0;
    for (var i = 0; i < items.length; i++) {
      final h = items[i];
      final parts = <String>[
        '/Title (${esc(h.title)})',
        '/Parent $parent 0 R',
        '/Dest [${pageIds[h.page - 1]} 0 R /Fit]',
        if (i > 0) '/Prev ${ids[i - 1]} 0 R',
        if (i < items.length - 1) '/Next ${ids[i + 1]} 0 R',
      ];
      if (h.children.isNotEmpty) {
        final (f, l, c) = writeOutline(h.children, ids[i]);
        parts.addAll(['/First $f 0 R', '/Last $l 0 R', '/Count $c']);
        total += c;
      }
      objects[ids[i]] = '<< ${parts.join(' ')} >>';
      total++;
    }
    return (ids.first, ids.last, total);
  }

  final (first, last, count) = writeOutline(outline, outlinesRoot);
  objects[outlinesRoot] =
      '<< /Type /Outlines /First $first 0 R /Last $last 0 R /Count $count >>';
  objects[catalog] =
      '<< /Type /Catalog /Pages $pagesRoot 0 R /Outlines $outlinesRoot 0 R '
      '/PageMode /UseOutlines >>';
  objects[pagesRoot] =
      '<< /Type /Pages /Kids [${pageIds.map((p) => '$p 0 R').join(' ')}] '
      '/Count $pages >>';
  objects[font] = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>';
  objects[fontBold] =
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>';

  final out = BytesBuilder();
  void write(String s) => out.add(latin1.encode(s));
  write('%PDF-1.4\n');
  final offsets = <int, int>{};
  for (var id = 1; id < next; id++) {
    offsets[id] = out.length;
    write('$id 0 obj\n${objects[id]}\nendobj\n');
  }
  final xref = out.length;
  write('xref\n0 $next\n0000000000 65535 f \n');
  for (var id = 1; id < next; id++) {
    write('${offsets[id].toString().padLeft(10, '0')} 00000 n \n');
  }
  write(
    'trailer\n<< /Size $next /Root $catalog 0 R '
    '/Info << /Title (LabGuide sinov hujjati) >> >>\n'
    'startxref\n$xref\n%%EOF\n',
  );
  return out.toBytes();
}
