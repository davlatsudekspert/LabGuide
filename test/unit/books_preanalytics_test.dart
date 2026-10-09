// Kitoblardan (Aripova 2007, Selivanov 2005, Sobirova 2006, Lyubina 1984)
// kiritilgan bilim: manbalar, katalog, preanalitika va siydik claim'lari.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/lab/preanalytics_info.dart';
import 'package:labguide/features/tools/calc_info.dart';

ContentPack _pack() => ContentPack.fromJson(
  (jsonDecode(File('assets/content/core/pack.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

const _books = {
  'book-aripova-2007',
  'book-selivanov-2005',
  'book-sobirova-2006',
  'book-lyubina-1984',
};

const _cards = [
  'urine-chemistry',
  'urine-microscopy',
  'urine-culture',
  'urine-24h',
  'sputum-afb',
  'fecal-occult-blood',
  'hpv-test',
  'vaginal-wet-mount',
];

void _threeLangs(LocalizedText t, String where) {
  for (final lang in LocalizedText.requiredLanguages) {
    expect(t.values[lang]?.trim(), isNotEmpty, reason: '$where $lang');
  }
  // O'zbekcha: faqat ‘ va ’ (oddiy apostrof emas).
  expect(t.values['uz']!.contains("'"), isFalse, reason: where);
}

void main() {
  final pack = _pack();

  group('kitoblar — manba va katalog', () {
    test('har kitob: darslik, faqat iqtibos, katalog yozuvi, fayl yo‘q', () {
      for (final id in _books) {
        final s = pack.source(id)!;
        expect(s.kind, isNot('web'), reason: id);
        expect(s.reuseRights, 'citation_only', reason: id);
        final item = pack.libraryItem(s.libraryItemId!)!;
        expect(item.file, isNull, reason: id);
        expect(item.filePack, isNull, reason: id);
        expect(item.rights.allowsSharedPack, isFalse, reason: id);
        expect(item.year, isNotNull, reason: id);
        expect(item.authors, isNotEmpty, reason: id);
        _threeLangs(item.note!, id);
      }
    });

    test('Sobirova — TTA saytidagi ochiq nusxa, faqat o‘qish havolasi', () {
      final item = pack.libraryItem('lib-book-sobirova-2006')!;
      expect(item.access, LibraryAccess.freeToRead);
      expect(Uri.parse(item.url!).host, 'biochem.medprof.tma.uz');
      expect(item.isbn, '978-9943-08-010-2');
      expect(item.licence, isNull);
      // Boshqalari — faqat katalog, havolasiz.
      for (final id in [
        'lib-book-aripova-2007',
        'lib-book-selivanov-2005',
        'lib-book-lyubina-1984',
      ]) {
        final i = pack.libraryItem(id)!;
        expect(i.access, LibraryAccess.catalogOnly, reason: id);
        expect(i.url, isNull, reason: id);
      }
      expect(
        pack.libraryItem('lib-book-aripova-2007')!.isbn,
        '978-9943-03-034-3',
      );
    });
  });

  group('siydik va qon bo‘lmagan namunalar — yangi claim’lar', () {
    test('kartalar draft; yangi kitob iqtibosi doim rasmiy manba bilan', () {
      var bookClaims = 0;
      for (final id in _cards) {
        final a = pack.analyte(id)!;
        expect(a.status, ContentStatus.draft, reason: id);
        for (final c in a.claims) {
          final ids = c.refs.map((r) => r.sourceId).toSet();
          if (ids.intersection(_books).isEmpty) continue;
          bookClaims++;
          // Kitob — qo'shimcha: har claim'da kamida bitta veb (rasmiy) manba.
          expect(
            ids.any((s) => pack.source(s)!.kind == 'web'),
            isTrue,
            reason: '$id: ${c.text.of('en')}',
          );
          for (final r in c.refs) {
            expect((r.locator ?? r.pages ?? '').trim(), isNotEmpty);
          }
          _threeLangs(c.text, id);
        }
      }
      expect(bookClaims, greaterThanOrEqualTo(12));
    });

    bool says(String card, String source, String en) => pack
        .analyte(card)!
        .claims
        .any(
          (c) =>
              c.refs.any((r) => r.sourceId == source) &&
              c.text.of('en').contains(en),
        );

    test('kechikkan siydik: glyukoza, pH, cho‘kma — JSST jadvali bilan', () {
      expect(
        says('urine-chemistry', 'who-dil-lab-99-1', 'about 2 hours'),
        isTrue,
      );
      expect(says('urine-chemistry', 'who-dil-lab-99-1', 'pH rises'), isTrue);
      expect(
        says('urine-chemistry', 'who-basic-lab-manual-2003', 'within 1 hour'),
        isTrue,
      );
      expect(
        says('urine-microscopy', 'who-dil-lab-99-1', 'must not be frozen'),
        isTrue,
      );
      expect(
        says(
          'urine-microscopy',
          'who-dil-lab-99-1',
          'erythrocytes about 1 hour',
        ),
        isTrue,
      );
      expect(
        says('urine-chemistry', 'book-aripova-2007', 'biliverdin'),
        isTrue,
      );
    });

    test('FIT — parhezsiz, gvayak — parhez (NCI)', () {
      expect(
        says(
          'fecal-occult-blood',
          'nci-crc-screening-tests',
          'typically needs no diet',
        ),
        isTrue,
      );
    });

    test('sulfosalitsil sinamasi soxta musbati kiritilmagan (tasdiq yo‘q)', () {
      for (final id in _cards) {
        for (final c in pack.analyte(id)!.claims) {
          expect(
            c.text.of('en').toLowerCase().contains('sulfosalicylic'),
            isFalse,
          );
        }
      }
    });
  });

  group('preanalitika ekrani ma’lumotlari', () {
    final items = [
      ...patientPrep,
      ...mixingRules,
      ...storageRules,
      ...urgentSamples,
    ];

    test('uch til; har bandda manba; kitob yolg‘iz manba emas', () {
      for (final x in items) {
        _threeLangs(x.text, x.text.of('en'));
        expect(x.refs, isNotEmpty);
        expect(
          x.refs.any((r) => !r.source.id.startsWith('book-')),
          isTrue,
          reason: x.text.of('en'),
        );
      }
      for (final t in tubeForTest) {
        _threeLangs(t.tests, t.tests.of('en'));
        _threeLangs(t.note, t.tests.of('en'));
        expect(
          t.refs.any((r) => !r.source.id.startsWith('book-')),
          isTrue,
          reason: t.tests.of('en'),
        );
        if (t.tube case final i?) expect(i, inInclusiveRange(0, 9));
      }
      for (final r in stabilityRows) {
        _threeLangs(r.analyte, r.analyte.of('en'));
        if (r.note case final n?) _threeLangs(n, r.analyte.of('en'));
        expect(r.page, inInclusiveRange(20, 50));
      }
    });

    test(
      'EDTA aralashtirish: ag‘darishlar soni yozilmagan (JSST bermaydi)',
      () {
        for (final x in mixingRules) {
          for (final lang in ['uz', 'ru', 'en']) {
            expect(x.text.of(lang), isNot(contains('8–10')));
            expect(x.text.of(lang), isNot(contains('8-10')));
          }
        }
      },
    );

    test('barqarorlik: JSST jadvalidagi qiymatlar va formatlash', () {
      StabilityRow row(String en) =>
          stabilityRows.firstWhere((r) => r.analyte.of('en') == en);
      expect(
        [row('ALT').frozen, row('ALT').fridge, row('ALT').room],
        ['7d', '7d', '3d'],
      );
      expect(row('Bilirubin (total)').room, '1d');
      expect(row('Potassium').fridge, '6w');
      expect(formatStability('7d', 'uz'), '7 kun');
      expect(formatStability('3m–2y', 'ru'), '3 мес – 2 г');
      expect(formatStability('6w', 'en'), '6 wk');
      expect(() => formatStability('7x', 'en'), throwsFormatException);
      for (final r in stabilityRows) {
        for (final code in [r.frozen, r.fridge, r.room]) {
          for (final lang in ['uz', 'ru', 'en']) {
            expect(formatStability(code, lang), isNotEmpty);
          }
        }
      }
    });

    test('manbalar ro‘yxati: noyob, JSST 2010 birinchi', () {
      final sources = preanalyticsSources();
      expect(sources.first.id, CalcSources.whoPhlebotomy2010.id);
      expect(sources.map((s) => s.id).toSet(), hasLength(sources.length));
      expect(sources.map((s) => s.id), contains('who-dil-lab-99-1'));
      expect(sources.map((s) => s.id), contains('book-selivanov-2005'));
      // Havolasiz kitob — katalog yozuvi; qolganlari https.
      for (final s in sources) {
        if (s.url == null) {
          expect(s.id, startsWith('book-'));
        } else {
          expect(Uri.parse(s.url!).isScheme('https'), isTrue, reason: s.id);
        }
      }
    });
  });
}
