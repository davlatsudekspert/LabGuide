import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/library/library_catalog.dart';

import '../helpers/library_fixtures.dart';
import '../helpers/test_pdf.dart';

Map<String, Object?> _packJson() => (jsonDecode(
  File('assets/content/core/pack.json').readAsStringSync(),
) as Map).cast<String, Object?>();

ContentPack _realPack() => ContentPack.fromJson(_packJson());

/// Haqiqiy paket + sinov materiallari (ilova ichidagi, kutilayotgan,
/// yuklab olinadigan, shaxsiy).
ContentPack _packWithFixtures() {
  final json = _packJson();
  json['library'] = [
    ...(json['library']! as List),
    ...testLibraryItems(buildTestPdf()),
  ];
  return ContentPack.fromJson(json);
}

List<String> _ids(List<LibraryItem> items) => [for (final i in items) i.id];

void main() {
  group(
    'open kind (havola / ilova ichida / yuklab olinadigan / kutilmoqda)',
    () {
      test('real catalog: links or catalogue records, none is in-app', () {
        final pack = _realPack();
        expect(pack.library, hasLength(29));
        for (final item in pack.library) {
          // Havolasiz yozuv faqat “faqat katalog” kitob (domla kitoblari).
          expect(
            openKindOf(item),
            item.url == null ? LibraryOpenKind.record : LibraryOpenKind.link,
            reason: item.id,
          );
          if (item.url == null) {
            expect(item.access, LibraryAccess.catalogOnly, reason: item.id);
          }
          expect(canReadInApp(item), isFalse, reason: item.id);
        }
      });

      test('fixtures are classified honestly', () {
        final pack = _packWithFixtures();
        LibraryOpenKind kind(String id) => openKindOf(pack.libraryItem(id)!);
        expect(kind(testPdfItemId), LibraryOpenKind.inApp);
        expect(kind(pendingItemId), LibraryOpenKind.pending);
        expect(kind(downloadItemId), LibraryOpenKind.download);
        expect(kind(personalItemId), LibraryOpenKind.record);
        expect(canReadInApp(pack.libraryItem(pendingItemId)!), isFalse);
      });

      test('not received / received items are pending even with a link', () {
        for (final state in [ImportState.notReceived, ImportState.received]) {
          final item = LibraryItem(
            id: 'x',
            kind: LibraryItemKind.book,
            title: 'X',
            authors: const [],
            language: 'uz',
            categories: const [LibraryCategory.biochemistry],
            topics: const [],
            importState: state,
            rights: const RightsRecord(
              distribution: DistributionRights.unknown,
            ),
            url: 'https://example.org/x',
          );
          expect(openKindOf(item), LibraryOpenKind.pending);
        }
      });
    },
  );

  group('search', () {
    final catalog = LibraryCatalog(_realPack());

    test('by title, author, and across scripts', () {
      expect(
        _ids(
          catalog.apply(const LibraryFilter(query: 'biosafety'), lang: 'en'),
        ),
        contains('lib-who-biosafety-manual-4-en'),
      );
      // Muallif familiyasi.
      expect(
        _ids(catalog.apply(const LibraryFilter(query: 'Rifai'), lang: 'uz')),
        ['lib-tietz-textbook-lab-medicine-7'],
      );
      // Lotin so'rovi kirill nomni topadi (lex.uz hujjati).
      expect(
        _ids(catalog.apply(const LibraryFilter(query: 'metrolog'), lang: 'uz')),
        contains('lib-lexuz-vm-112-metrologiya'),
      );
      // Kirill so'rovi o'zbekcha lotin nomni topadi.
      expect(
        _ids(catalog.apply(const LibraryFilter(query: 'сийдик'), lang: 'uz')),
        contains('lib-ziyonet-siydik-chokmasi'),
      );
      // Apostrof variantlari farq qilmaydi.
      expect(
        catalog.apply(const LibraryFilter(query: "cho'kma"), lang: 'uz'),
        isNotEmpty,
      );
      expect(
        catalog.apply(const LibraryFilter(query: 'cho‘kma'), lang: 'uz'),
        isNotEmpty,
      );
    });

    test('title matches rank above note matches', () {
      final results = catalog.apply(
        const LibraryFilter(query: 'biokimyo'),
        lang: 'uz',
      );
      expect(results.first.id, 'lib-sammu-biokimyo-baykulov');
    });

    test('kind and category labels are searchable in all languages', () {
      final manuals = catalog.apply(
        const LibraryFilter(query: 'руководство'),
        lang: 'ru',
      );
      expect(manuals, isNotEmpty);
      final byLabel = catalog.apply(
        const LibraryFilter(query: 'qo‘llanma'),
        lang: 'uz',
      );
      expect(
        byLabel.where((i) => i.kind == LibraryItemKind.manual),
        isNotEmpty,
      );
    });

    test('nonsense finds nothing', () {
      expect(
        catalog.apply(const LibraryFilter(query: 'zzqqxx'), lang: 'uz'),
        isEmpty,
      );
    });
  });

  group('filters', () {
    final pack = _realPack();
    final catalog = LibraryCatalog(pack);

    test('no filter: everything, interface language first', () {
      final all = catalog.apply(LibraryFilter.none, lang: 'ru');
      expect(all, hasLength(pack.library.length));
      final firstOther = all.indexWhere((i) => i.language != 'ru');
      expect(all.skip(firstOther).where((i) => i.language == 'ru'), isEmpty);
    });

    test('language, category, group, kind and open kind combine', () {
      final uz = catalog.apply(const LibraryFilter(language: 'uz'), lang: 'uz');
      expect(uz.every((i) => i.language == 'uz'), isTrue);
      expect(
        uz,
        hasLength(pack.library.where((i) => i.language == 'uz').length),
      );

      final kidney = catalog.apply(
        const LibraryFilter(group: 'kidney'),
        lang: 'uz',
      );
      expect(_ids(kidney), contains('lib-ziyonet-buyrak-disfunksiyasi'));
      expect(
        kidney.every((i) => catalog.groupsOf(i).contains('kidney')),
        isTrue,
      );

      final combo = catalog.apply(
        const LibraryFilter(
          language: 'en',
          category: LibraryCategory.biochemistry,
          kind: LibraryItemKind.book,
        ),
        lang: 'en',
      );
      expect(combo, isNotEmpty);
      for (final i in combo) {
        expect(i.language, 'en');
        expect(i.categories, contains(LibraryCategory.biochemistry));
        expect(i.kind, LibraryItemKind.book);
      }

      expect(
        catalog.count(const LibraryFilter(open: LibraryOpenKind.inApp)),
        0,
      );
      expect(
        catalog.count(const LibraryFilter(open: LibraryOpenKind.link)),
        pack.library.where((i) => i.url != null).length,
      );
    });

    test('query and filters together; clear keeps the query', () {
      const f = LibraryFilter(query: 'who', language: 'ru');
      final results = catalog.apply(f, lang: 'ru');
      expect(results, isNotEmpty);
      expect(results.every((i) => i.language == 'ru'), isTrue);
      final cleared = f.clearSelections();
      expect(cleared.hasSelections, isFalse);
      expect(cleared.query, 'who');
      expect(catalog.count(cleared), greaterThanOrEqualTo(catalog.count(f)));
    });

    test('copyWith can set and unset each dimension', () {
      const f = LibraryFilter(language: 'uz', kind: LibraryItemKind.book);
      expect(f.copyWith(language: null).language, isNull);
      expect(f.copyWith(language: null).kind, LibraryItemKind.book);
      expect(f.copyWith(query: 'x').language, 'uz');
      expect(f.copyWith(open: LibraryOpenKind.link).open, LibraryOpenKind.link);
      expect(LibraryFilter.none.isActive, isFalse);
      expect(const LibraryFilter(query: ' ').isActive, isFalse);
    });

    test('option lists only show what the catalog has', () {
      expect(catalog.languages, ['uz', 'ru', 'en']);
      expect(catalog.openKinds, [LibraryOpenKind.link, LibraryOpenKind.record]);
      expect(catalog.kinds, isNot(contains(LibraryItemKind.ifu)));
      expect(catalog.groups.map((g) => g.id), contains('urine'));
    });
  });

  group('in-app file schema', () {
    Map<String, Object?> withItem(Map<String, Object?> item) {
      final json = _packJson();
      // Haqiqiy katalog qoladi (kitob manbalari unga tayanadi).
      json['library'] = [...(json['library']! as List), item];
      return json;
    }

    final pdf = buildTestPdf();
    final base = testLibraryItems(pdf).first;

    test('a fully recorded file parses', () {
      final pack = ContentPack.fromJson(withItem(base));
      final file = pack.libraryItem(base['id']! as String)!.file!;
      expect(file.size, pdf.length);
      expect(file.pages, 10);
    });

    test('file without full rights record is rejected', () {
      for (final rights in [
        {'distribution': 'unknown'},
        {
          'distribution': 'personal_only',
          'recorded_at': '2026-10-09',
          'recorded_by': 'x',
          'evidence': 'y',
        },
        // Kim qayd etgani yo'q.
        {
          'distribution': 'permitted',
          'recorded_at': '2026-10-09',
          'evidence': 'y',
        },
      ]) {
        expect(
          () => ContentPack.fromJson(withItem({...base, 'rights': rights})),
          throwsFormatException,
          reason: '$rights',
        );
      }
    });

    test('file for an item that has not arrived is rejected', () {
      expect(
        () => ContentPack.fromJson(
          withItem({...base, 'import_state': 'not_received'}),
        ),
        throwsFormatException,
      );
    });

    test('bad file references are rejected', () {
      final file = base['file']! as Map<String, Object?>;
      for (final bad in [
        {...file, 'format': 'epub'},
        {...file, 'path': 'books/x.pdf'},
        {...file, 'path': 'assets/../secret.pdf'},
        {...file, 'sha256': 'abc'},
        {...file, 'size': 0},
      ]) {
        expect(
          () => ContentPack.fromJson(withItem({...base, 'file': bad})),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });

    test('every in-app file in the shipped pack exists with its checksum', () {
      // Hozircha bunday fayl yo'q; kelganda — asset, hajm va sha256 mos.
      for (final item in _realPack().library) {
        final file = item.file;
        if (file == null) continue;
        final f = File(file.path);
        expect(f.existsSync(), isTrue, reason: file.path);
        expect(f.lengthSync(), file.size, reason: file.path);
      }
    });
  });
}
