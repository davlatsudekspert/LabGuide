// Ma'ruza taqdimotlari katalogi (assets/lectures/index_v2.json + decks/*.json):
// har deck ilova parserida o'qiladi, oxirgi slayd — "Adabiyotlar", id'lar indeks
// bilan mos; qidiruv darajalari va ajratib ko'rsatish.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/content/analyte_search.dart';

const _sourcesTitle = {
  'uz': 'Adabiyotlar',
  'ru': 'Литература',
  'en': 'References',
};

DeckCatalog _real() =>
    DeckCatalog.parse(File('assets/lectures/index_v2.json').readAsStringSync());

LectureDeck _load(DeckEntry e, String lang) => LectureDeck.fromJson(
  jsonDecode(File(e.path(lang)).readAsStringSync()) as Map<String, Object?>,
);

/// pubspec.yaml dagi asset papkalari (Flutter ichki fayllarni qayta
/// qidirmaydi: rasm papkasi ro'yxatda bo'lishi shart).
Set<String> _assetDirs() => {
  for (final m in RegExp(
    r'^\s+- (assets/[^\s]+/)\s*$',
    multiLine: true,
  ).allMatches(File('pubspec.yaml').readAsStringSync()))
    m.group(1)!,
};

void main() {
  final catalog = _real();

  group('indeks va decklar', () {
    test('143 kun mavzusi (45 tasi M9 tavsiya etilgan amaliy reja) + 46 amaliy protokol (19 tasi ishlab chiqaruvchi IFU si asosida), id takrorlanmaydi', () {
      expect(catalog.decks.where((d) => d.kind == DeckKind.day).length, 143);
      expect(
        catalog.decks.where((d) => d.kind == DeckKind.protocol).length,
        46,
      );
      final ids = [for (final d in catalog.decks) d.id];
      expect(ids.toSet().length, ids.length);
      expect(catalog.modules.map((m) => m.n), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      for (final d in catalog.decks.where((d) => d.kind == DeckKind.day)) {
        expect(d.module, inInclusiveRange(1, 9), reason: d.id);
        expect(d.day, isNotNull, reason: d.id);
        expect(d.topics, isNotEmpty, reason: d.id);
      }
      // d001: muallif decki (uz) va uning ru/en tarjimalari.
      expect(catalog.byId('d001')!.languages, ['uz', 'ru', 'en']);
      expect(catalog.byTopic('d001-L')?.id, 'd001');
    });

    test('har deck/til fayli ilova parserida o‘qiladi, indeks bilan mos', () {
      final dirs = _assetDirs();
      var files = 0;
      for (final e in catalog.decks) {
        expect(e.languages, isNotEmpty, reason: e.id);
        for (final lang in e.languages) {
          files++;
          final deck = _load(e, lang);
          final why = '${e.id}.$lang';
          expect(deck.lang, lang, reason: why);
          if (deck.id != null) expect(deck.id, e.id, reason: why);
          expect(deck.slides.length, e.slideCounts[lang], reason: why);
          expect(deck.slides, isNotEmpty, reason: why);
          if (deck.title != null) {
            expect(deck.title, e.titles[lang], reason: why);
          }
          expect(e.titles[lang], isNotEmpty, reason: why);
          for (final s in deck.slides) {
            expect(s.title.trim(), isNotEmpty, reason: why);
          }
          // Slayd sarlavhalari indeksi deck bilan mos.
          for (final r in e.runs[lang]!) {
            for (var k = 0; k < r.count; k++) {
              expect(
                deck.slides[r.first + k].title,
                r.title,
                reason: '$why #${r.first + k}',
              );
            }
          }
          // Rasm assetlari mavjud va bundle papkalarida.
          for (final s in deck.slides) {
            for (final a in [?s.figure, ?s.image]) {
              expect(File(a).existsSync(), isTrue, reason: '$why: $a');
              expect(
                dirs.contains('${a.substring(0, a.lastIndexOf('/'))}/'),
                isTrue,
                reason: '$why: $a pubspec.yaml da yo‘q',
              );
            }
          }
        }
        // Indeksda ko'rsatilgan har fayl diskda, boshqa fayl yo'q.
      }
      final onDisk = Directory('assets/lectures/decks')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .length;
      final standard = [
        for (final e in catalog.decks)
          for (final l in e.languages)
            if (!e.files.containsKey(l)) 1,
      ].length;
      expect(onDisk, standard, reason: 'indeksda yo‘q fayl qolgan');
      expect(files, greaterThan(360));
    });

    test('oxirgi slayd — Adabiyotlar; har kontent slaydida manba', () {
      for (final e in catalog.decks) {
        for (final lang in e.languages) {
          if (e.files.containsKey(lang)) continue; // muallif decki (d001)
          final deck = _load(e, lang);
          final why = '${e.id}.$lang';
          expect(deck.slides.last.title, _sourcesTitle[lang], reason: why);
          expect(deck.slides.last.bullets, isNotEmpty, reason: why);
          expect(deck.slides.first.template, 'title', reason: why);
          // Sarlavha, reja va adabiyotlardan boshqa hamma slaydda manba qatori.
          final plan = deck.slides[1].title;
          for (final (i, s) in deck.slides.indexed) {
            if (i == 0 || s.title == plan || s.title == _sourcesTitle[lang]) {
              continue;
            }
            expect(s.source, isNotNull, reason: '$why #$i ${s.title}');
            expect(s.source, isNotEmpty, reason: '$why #$i');
          }
        }
      }
    });

    test('shablon maydonlari to‘liq: jadval, rasm, savol-javob', () {
      final seen = <String>{};
      for (final e in catalog.decks) {
        for (final lang in e.languages) {
          if (e.files.containsKey(lang)) continue;
          for (final (i, s) in _load(e, lang).slides.indexed) {
            final why = '${e.id}.$lang #$i ${s.template}';
            seen.add(s.template);
            switch (s.template) {
              case 'table':
                expect(s.rows, isNotEmpty, reason: why);
                final cols = s.header.isNotEmpty
                    ? s.header.length
                    : s.rows.first.length;
                for (final r in s.rows) {
                  expect(r.length, cols, reason: why);
                }
              case 'figure':
                expect(s.figure, isNotNull, reason: why);
                expect(s.caption, isNotEmpty, reason: why);
              case 'qa':
                expect(s.options.length, greaterThanOrEqualTo(2), reason: why);
                expect(
                  s.correct,
                  inInclusiveRange(0, s.options.length - 1),
                  reason: why,
                );
              case 'title':
                expect(i, 0, reason: why);
                expect(s.bullets, isNotEmpty, reason: why);
              case 'bullets' || 'steps' || 'tree':
                expect(s.bullets, isNotEmpty, reason: why);
              case 'stats':
                expect(s.bullets, isNotEmpty, reason: why);
                expect(s.stats.length, inInclusiveRange(2, 4), reason: why);
                for (final st in s.stats) {
                  // qiymat va yorliq — band matnining bo'lagi
                  expect(s.bullets.join('\n'), contains(st[0]), reason: why);
                  expect(s.bullets.join('\n'), contains(st[1]), reason: why);
                }
              case 'range':
                expect(s.range?['rows'], isNotEmpty, reason: why);
              case 'split':
                expect(s.cols.length, 2, reason: why);
              case 'example':
                expect(s.example, isNotEmpty, reason: why);
              default:
                fail('noma’lum shablon: $why');
            }
            if (s.figure != null && s.template != 'figure') {
              // sarlavha/yon rasm — krediti bilan
              expect(s.credit, isNotEmpty, reason: why);
            }
          }
        }
      }
      expect(seen, {
        'title',
        'bullets',
        'table',
        'figure',
        'qa',
        'stats',
        'range',
        'steps',
        'split',
        'tree',
        'example',
      });
    });

    // 13 MiB: vizual shablonlar va litsenziyali fotolar ~0.5 MB qo'shdi
    // 16 MiB (D-67): M9 ning 45 ta amaliy kuni decklari ~2.8 MB qo'shdi
    // (tool/slides/test_export_app_decks.py SIZE_BUDGET bilan bir xil).
    test('hajm: yangi assetlar 16 MB dan oshmaydi', () {
      var bytes = File('assets/lectures/index_v2.json').lengthSync();
      for (final f in Directory('assets/lectures/decks').listSync()) {
        if (f is File) bytes += f.lengthSync();
      }
      expect(bytes, lessThan(16 * 1024 * 1024));
    });

    test(
      'kalit so‘zlar normallashtirilgan va sarlavhalarni o‘z ichiga oladi',
      () {
        for (final e in catalog.decks) {
          expect(normalizeForSearch(e.keywords), e.keywords, reason: e.id);
          for (final l in e.languages) {
            expect(
              e.keywords,
              contains(normalizeForSearch(e.titles[l]!)),
              reason: '${e.id}.$l',
            );
          }
        }
      },
    );
  });

  group('DeckEntry', () {
    test('resolveLang: so‘ralgan til → o‘zbekcha → birinchi mavjud', () {
      const uzOnly = DeckEntry(
        id: 'x',
        kind: DeckKind.day,
        titles: {'uz': 'X'},
        slideCounts: {'uz': 3},
        languages: ['uz'],
        runs: {},
        keywords: '',
      );
      expect(uzOnly.resolveLang('uz'), 'uz');
      expect(uzOnly.resolveLang('ru'), 'uz');
      expect(uzOnly.resolveLang('en'), 'uz');
      const enOnly = DeckEntry(
        id: 'y',
        kind: DeckKind.protocol,
        titles: {'en': 'Y'},
        slideCounts: {'en': 2},
        languages: ['en'],
        runs: {},
        keywords: '',
      );
      expect(enOnly.resolveLang('ru'), 'en');
      final d = catalog.byId('d001')!;
      final full = catalog.byId('d012')!;
      expect(full.resolveLang('ru'), 'ru');
      expect(full.path('en'), 'assets/lectures/decks/d012.en.json');
      expect(d.path('uz'), 'assets/lectures/d001.json');
      expect(d.resolveLang('ru'), 'ru');
      expect(d.path('ru'), 'assets/lectures/d001.ru.json');
      expect(d.path('en'), 'assets/lectures/d001.en.json');
      expect(d.slides('en'), 30);
      expect(full.slides('ru'), full.slideCounts['ru']);
    });
  });

  group('qidiruv ballari (sintetik katalog)', () {
    // Ball darajalari: to'liq sarlavha > boshi > so'z boshi > ichida >
    // slayd sarlavhasi > faqat kalit so'z.
    Map<String, Object?> deck(
      String id,
      String title, {
      List<List<Object>> runs = const [],
      String kw = '',
    }) => {
      'id': id,
      'kind': 'day',
      'm': 1,
      'd': 1,
      'topics': ['$id-P'],
      't': {'uz': title},
      'n': {'uz': 5},
      'l': ['uz'],
      'st': {'uz': runs},
      'kw': kw.isEmpty ? normalizeForSearch(title) : kw,
    };
    final synthetic = DeckCatalog.parse(
      jsonEncode({
        'modules': [
          {'n': 1, 'id': 'M1', 'uz': 'Modul'},
        ],
        'decks': [
          deck('keyword', 'Boshqa mavzu', kw: 'boshqa mavzu | temir'),
          deck(
            'slide',
            'Anemiyalar',
            runs: [
              ['Temir tanqisligi', 2, 3],
            ],
            kw: 'anemiyalar | temir tanqisligi',
          ),
          deck('contains', 'Antitemir sinamasi'),
          deck('word', 'Kamqonlikda temir'),
          deck('prefix', 'Temir almashinuvi'),
          deck('exact', 'Temir'),
        ],
      }),
    );
    final search = DeckSearch(synthetic);

    test('tartib: exact > prefix > word > contains > slide > keyword', () {
      final hits = search.search('temir', lang: 'uz');
      expect(
        [for (final h in hits) h.entry.id],
        ['exact', 'prefix', 'word', 'contains', 'slide', 'keyword'],
      );
      expect(hits.first.score, greaterThan(DeckScore.titlePrefix));
      expect(hits[1].score, greaterThanOrEqualTo(DeckScore.titlePrefix));
      expect(hits.last.score, DeckScore.keyword);
      final slide = hits.firstWhere((h) => h.entry.id == 'slide');
      expect(slide.matchedSlides, 3);
      expect(slide.firstSlide, 2);
      expect(slide.slides.single.title, 'Temir tanqisligi');
    });

    test('bir nechta so‘z: hammasi bo‘lishi shart (AND)', () {
      final ids = [
        for (final h in search.search('temir tanqisligi', lang: 'uz'))
          h.entry.id,
      ];
      expect(ids, ['slide']);
      expect(search.search('temir yo‘q so‘z', lang: 'uz'), isEmpty);
    });

    test('bo‘sh so‘rov: filtrga mos hammasi, katalog tartibida', () {
      final all = search.search('  ', lang: 'uz');
      expect(
        [for (final h in all) h.entry.id],
        ['keyword', 'slide', 'contains', 'word', 'prefix', 'exact'],
      );
      expect(all.every((h) => h.matchedSlides == 0), isTrue);
    });
  });

  group('qidiruv (haqiqiy katalog)', () {
    final search = DeckSearch(catalog);
    List<String> ids(String q, {String lang = 'uz', DeckFilter? f}) => [
      for (final h in search.search(
        q,
        lang: lang,
        filter: f ?? const DeckFilter(),
      ))
        h.entry.id,
    ];

    test('lotin: tahlil nomi bo‘yicha deck va slayd topiladi', () {
      final hits = search.search('glyukoza', lang: 'uz');
      expect(
        hits.first.entry.id,
        'd059',
      ); // sarlavha “Glyukozani…” bilan boshlanadi
      final d045 = hits.firstWhere((h) => h.entry.id == 'd045');
      expect(d045.slides.first.title, 'Och qoringa plazma glyukozasi');
      expect(d045.firstSlide, 2);
      expect(d045.matchedSlides, greaterThanOrEqualTo(4));
    });

    test('kirill (o‘zbekcha) so‘rov lotin sarlavhani topadi', () {
      final latin = ids('glyukoza');
      final cyr = ids('глюкоза');
      expect(cyr, containsAll(['d045', 'd059']));
      expect(latin, containsAll(cyr.where(latin.contains).toList()));
      // Kirill so‘rov: o‘zbekcha ilovada slayd sarlavhasi lotinda topiladi.
      final d045 = search
          .search('глюкоза', lang: 'uz')
          .firstWhere((h) => h.entry.id == 'd045');
      expect(d045.slidesLang, 'uz');
      expect(d045.slides.first.title, 'Och qoringa plazma glyukozasi');
    });

    test('ruscha va inglizcha so‘rovlar', () {
      final ru = search.search('глюкоза', lang: 'ru');
      expect(ru.map((h) => h.entry.id), containsAll(['d045', 'd059']));
      expect(
        ru.firstWhere((h) => h.entry.id == 'd045').slides.first.title,
        'Глюкоза плазмы натощак',
      );
      // Rus so‘zining oxirgi unlisi qirqiladi: печень → печени.
      expect(ids('печень', lang: 'ru'), containsAll(['d007', 'd049']));
      final en = search.search('glucose', lang: 'en');
      expect(en.map((h) => h.entry.id), containsAll(['d045', 'd059']));
      expect(
        en.firstWhere((h) => h.entry.id == 'd045').slides.first.title,
        'Fasting plasma glucose',
      );
    });

    test('ilova tili boshqa bo‘lsa: slaydlar topilgan tilda qaytariladi', () {
      // O‘zbekcha ilovada inglizcha so‘z: deck topiladi, slaydlar EN da.
      final h = search
          .search('fasting plasma', lang: 'uz')
          .firstWhere((h) => h.entry.id == 'd045');
      expect(h.slidesLang, 'en');
      expect(h.slides.first.title, 'Fasting plasma glucose');
    });

    test('apostrof variantlari farq qilmaydi', () {
      final a = ids("o'zbekiston");
      final b = ids('o‘zbekiston');
      final c = ids('oʻzbekiston');
      final d = ids('ozbekiston');
      expect(a, contains('d002'));
      expect(a, b);
      expect(b, c);
      expect(c, d);
    });

    test('filtr: modul, protokollar, til', () {
      final all = ids('');
      expect(all.length, 189);
      final m3 = ids('', f: const DeckFilter(module: 3));
      expect(m3.length, catalog.inModule(3).length);
      expect(m3.every((id) => catalog.byId(id)!.module == 3), isTrue);
      final prot = ids('', f: const DeckFilter(protocolsOnly: true));
      expect(prot.length, 46);
      expect(
        ids('', f: const DeckFilter(lang: 'ru')).length,
        189,
        reason: 'd001 ham ru da (tarjima)',
      );
      expect(ids('glyukoza', f: const DeckFilter(module: 99)), isEmpty);
      expect(ids('glyukoza', f: const DeckFilter(protocolsOnly: true)), [
        'glyukoza-gox-pod-fotometrik',
      ]);
    });

    test('kombinatsiya: modul + so‘rov', () {
      final hits = ids('glyukoza', f: const DeckFilter(module: 7));
      expect(hits, isNotEmpty);
      expect(hits.every((id) => catalog.byId(id)!.module == 7), isTrue);
    });
  });

  group('highlightRanges', () {
    test('apostroflar tushiriladi, indekslar asl matnda', () {
      const t = 'O‘zbekistonda klinik biokimyo';
      final r = highlightRanges(t, DeckQuery("o'zbekiston"));
      expect(r, hasLength(1));
      expect(t.substring(r.single.$1, r.single.$2), 'O‘zbekiston');
    });

    test('bir nechta so‘z, birlashtirish va katta/kichik harf', () {
      const t = 'Temir tanqisligi anemiyasi';
      final r = highlightRanges(t, DeckQuery('TEMIR tanq'));
      expect([for (final x in r) t.substring(x.$1, x.$2)], ['Temir', 'tanq']);
      final merged = highlightRanges('abcabc', DeckQuery('abc bca'));
      expect(merged, [(0, 6)]);
    });

    test('kirill so‘rov lotin matnni ajratadi (translit)', () {
      const t = 'Och qoringa plazma glyukozasi';
      final r = highlightRanges(t, DeckQuery('глюкоза'));
      expect([for (final x in r) t.substring(x.$1, x.$2)], ['glyukoza']);
    });

    test('ё → е va bo‘sh so‘rov', () {
      expect(highlightRanges('Всё хорошо', DeckQuery('все')).map((x) => x.$2), [
        3,
      ]);
      expect(highlightRanges('abc', DeckQuery('  ')), isEmpty);
    });
  });
}
