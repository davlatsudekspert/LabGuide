import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import 'harness.dart';
import 'test_pdf.dart';

/// Testlardagi “ilova ichidagi fayl” — dasturiy yaratilgan sinov PDF'i
/// (repoga begona PDF qo'shilmaydi).
const testPdfAsset = 'assets/books/labguide-test.pdf';
const testPdfItemId = 'test-labguide-sinov';
const pendingItemId = 'test-pending-book';
const downloadItemId = 'test-download-book';
const personalItemId = 'test-personal-method';

/// Sinov materiallari: ilova ichidagi PDF (to'liq huquq qaydi bilan),
/// hali kelmagan kitob, yuklab olinadigan kitob va faqat shaxsiy material.
List<Map<String, Object?>> testLibraryItems(Uint8List pdf) => [
  {
    'id': testPdfItemId,
    'kind': 'manual',
    'title': 'LabGuide sinov hujjati',
    'authors': ['LabGuide'],
    'year': 2026,
    'language': 'uz',
    'categories': ['methods'],
    'topics': ['urine'],
    'provided_by': 'teacher',
    'received_at': '2026-10-09',
    'import_state': 'cataloged',
    'rights': {
      'distribution': 'permitted',
      'recorded_at': '2026-10-09',
      'recorded_by': 'test',
      'evidence': 'test fixture',
    },
    'file': {
      'path': testPdfAsset,
      'size': pdf.length,
      'sha256': sha256.convert(pdf).toString(),
      'format': 'pdf',
      'pages': 10,
    },
  },
  {
    'id': pendingItemId,
    'kind': 'book',
    'title': 'Kutilayotgan sinov kitobi',
    'authors': ['Domla'],
    'language': 'ru',
    'categories': ['biochemistry'],
    'topics': [],
    'provided_by': 'teacher',
    'import_state': 'not_received',
    'rights': {'distribution': 'unknown'},
  },
  {
    'id': downloadItemId,
    'kind': 'book',
    'title': 'Yuklab olinadigan sinov kitobi',
    'authors': ['Domla'],
    'language': 'uz',
    'categories': ['clinical_lab'],
    'topics': [],
    'provided_by': 'teacher',
    'import_state': 'cataloged',
    'rights': {
      'distribution': 'permitted',
      'recorded_at': '2026-10-09',
      'recorded_by': 'test',
      'evidence': 'test fixture',
    },
    'file_pack': {
      'pack_id': 'book-test',
      'version': '1',
      'size': 3 * 1024 * 1024,
      'sha256': 'a' * 64,
    },
  },
  {
    'id': personalItemId,
    'kind': 'method',
    'title': 'Shaxsiy sinov metodikasi',
    'authors': [],
    'language': 'uz',
    'categories': ['methods'],
    'topics': [],
    'provided_by': 'teacher',
    'import_state': 'cataloged',
    'rights': {
      'distribution': 'personal_only',
      'recorded_at': '2026-10-09',
      'recorded_by': 'test',
      'evidence': 'domla izohi',
    },
  },
];

/// Asosiy paketga sinov materiallarini qo'shadigan va sinov PDF'ini
/// [testPdfAsset] manzilida beradigan bundle.
class LibraryTestBundle extends CachingAssetBundle {
  LibraryTestBundle({Uint8List? pdf, this.servedPdf})
    : pdf = pdf ?? buildTestPdf() {
    _inner = PatchedPackBundle(rootBundle, (json) {
      json['library'] = [
        ...(json['library']! as List),
        ...testLibraryItems(this.pdf),
      ];
    });
  }

  /// Katalogda e'lon qilingan fayl.
  final Uint8List pdf;

  /// Haqiqatda beriladigan baytlar (buzilgan fayl sinovi uchun boshqacha).
  final Uint8List? servedPdf;
  late final PatchedPackBundle _inner;

  @override
  Future<ByteData> load(String key) async {
    if (key == testPdfAsset) {
      return ByteData.sublistView(servedPdf ?? pdf);
    }
    return _inner.load(key);
  }
}

/// PDFium'ni test muhitida ulash: `flutter test` build hook'i yuklagan
/// kutubxona (`build/native_assets/<os>/`) va vaqtinchalik kesh papkasi.
void setUpPdfiumForTests() {
  Pdfrx.cacheDirectoryPath ??= Directory.systemTemp.path;
  if (Pdfrx.pdfiumModulePath != null) return;
  final (dir, name) = Platform.isMacOS
      ? ('macos', 'libpdfium.dylib')
      : Platform.isWindows
      ? ('windows', 'pdfium.dll')
      : ('linux', 'libpdfium.so');
  final lib = File('${Directory.current.path}/build/native_assets/$dir/$name');
  if (lib.existsSync()) Pdfrx.pdfiumModulePath = lib.path;
}
