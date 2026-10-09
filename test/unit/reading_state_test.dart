import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/library/pdf_reader_screen.dart';
import 'package:labguide/features/library/reading_controller.dart';
import 'package:pdfrx/pdfrx.dart';

import '../helpers/library_fixtures.dart';
import '../helpers/test_pdf.dart';

const _sha = 'aaaa';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ReadingController make(KeyValueStore store) =>
      ReadingController(store, bundle: rootBundle);

  test('last page and bookmarks survive a restart (same store)', () async {
    final store = MemoryKeyValueStore();
    final a = make(store);
    expect(a.stateOf('book', _sha), isNull);
    await a.setLastPage('book', _sha, 12, pageCount: 40);
    await a.addBookmark('book', _sha, 7, name: '  Jadval   3  ');
    await a.addBookmark('book', _sha, 3);

    final b = make(store);
    final s = b.stateOf('book', _sha)!;
    expect(s.lastPage, 12);
    expect(s.pageCount, 40);
    expect([for (final m in s.bookmarks) m.page], [3, 7]);
    expect(s.bookmarkAt(7)!.name, 'Jadval 3');
    expect(s.bookmarkAt(3)!.name, '');
    expect(b.lastRead!.key, 'book');
  });

  test('bookmark on the same page renames; remove deletes', () async {
    final c = make(MemoryKeyValueStore());
    await c.addBookmark('book', _sha, 5, name: 'Birinchi');
    await c.addBookmark('book', _sha, 5, name: 'Ikkinchi');
    expect(c.stateOf('book', _sha)!.bookmarks.single.name, 'Ikkinchi');
    await c.removeBookmark('book', _sha, 5);
    expect(c.stateOf('book', _sha)!.bookmarks, isEmpty);
  });

  test('long names are cut; pages are clamped to the document', () async {
    final c = make(MemoryKeyValueStore());
    await c.setLastPage('book', _sha, 99, pageCount: 10);
    expect(c.stateOf('book', _sha)!.lastPage, 10);
    await c.setLastPage('book', _sha, 0);
    expect(c.stateOf('book', _sha)!.lastPage, 1);
    final b = await c.addBookmark('book', _sha, 4, name: 'x' * 200);
    expect(b.name.length, ReadingController.maxBookmarkName);
  });

  test('a new file version does not inherit old pages or bookmarks', () async {
    final c = make(MemoryKeyValueStore());
    await c.setLastPage('book', _sha, 30, pageCount: 40);
    await c.addBookmark('book', _sha, 30);
    expect(c.stateOf('book', 'bbbb'), isNull);
    await c.setLastPage('book', 'bbbb', 2, pageCount: 50);
    expect(c.stateOf('book', 'bbbb')!.bookmarks, isEmpty);
    expect(c.stateOf('book', _sha), isNull);
  });

  test('a corrupted stored value starts fresh instead of crashing', () {
    final store = MemoryKeyValueStore({StoreKeys.libraryReading: '{oops'});
    expect(make(store).stateOf('book', _sha), isNull);
  });

  test('loadFile checks size and sha256', () async {
    final pdf = buildTestPdf();
    final item = testLibraryItems(pdf).first;
    final ref = LibraryFileRef.fromJson(
      (item['file']! as Map).cast<String, Object?>(),
    );
    final ok = ReadingController(
      MemoryKeyValueStore(),
      bundle: LibraryTestBundle(pdf: pdf),
    );
    expect(await ok.loadFile(ref), pdf);

    final tampered = Uint8List.fromList(pdf)..[100] ^= 0x01;
    final bad = ReadingController(
      MemoryKeyValueStore(),
      bundle: LibraryTestBundle(pdf: pdf, servedPdf: tampered),
    );
    await expectLater(
      bad.loadFile(ref),
      throwsA(
        isA<LibraryFileException>().having(
          (e) => e.failure,
          'failure',
          LibraryFileFailure.corrupted,
        ),
      ),
    );
    final missing = ReadingController(
      MemoryKeyValueStore(),
      bundle: rootBundle,
    );
    await expectLater(
      missing.loadFile(ref),
      throwsA(
        isA<LibraryFileException>().having(
          (e) => e.failure,
          'failure',
          LibraryFileFailure.missing,
        ),
      ),
    );
  });

  group('table of contents and page input', () {
    test('outline is flattened with levels; current section found', () {
      const nodes = [
        PdfOutlineNode(
          title: '1. Kirish',
          dest: PdfDest(1, PdfDestCommand.fit, null),
          children: [],
        ),
        PdfOutlineNode(
          title: '2. Bob',
          dest: PdfDest(3, PdfDestCommand.fit, null),
          children: [
            PdfOutlineNode(
              title: '2.1',
              dest: PdfDest(4, PdfDestCommand.fit, null),
              children: [],
            ),
          ],
        ),
        PdfOutlineNode(title: '  ', dest: null, children: []),
      ];
      final toc = flattenOutline(nodes);
      expect(
        [for (final e in toc) e.title],
        ['1. Kirish', '2. Bob', '2.1', '—'],
      );
      expect([for (final e in toc) e.level], [0, 0, 1, 0]);
      expect(toc.last.page, isNull);
      expect(currentTocIndex(toc, 1), 0);
      expect(currentTocIndex(toc, 3), 1);
      expect(currentTocIndex(toc, 9), 2);
    });

    test('page input accepts only 1..total', () {
      expect(parsePageInput('7', 10), 7);
      expect(parsePageInput(' 10 ', 10), 10);
      expect(parsePageInput('0', 10), isNull);
      expect(parsePageInput('11', 10), isNull);
      expect(parsePageInput('', 10), isNull);
      expect(parsePageInput('abc', 10), isNull);
    });

    test('the generated test PDF has its outline (real PDFium)', () async {
      setUpPdfiumForTests();
      await pdfrxFlutterInitialize();
      final doc = await PdfDocument.openData(
        buildTestPdf(),
        sourceName: 'outline-test',
      );
      addTearDown(doc.dispose);
      expect(doc.pages, hasLength(10));
      final toc = flattenOutline(await doc.loadOutline());
      expect(
        [for (final e in toc) (e.title, e.page, e.level)],
        [
          ('1. Kirish', 1, 0),
          ("2. Sinov bo'limi", 3, 0),
          ("2.1. Ichki bo'lim", 4, 1),
          ("3. Xatcho'plar sinovi", 6, 0),
          ('4. Yakun', 9, 0),
        ],
      );
    });
  });
}
