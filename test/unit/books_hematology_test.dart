import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/content/condition_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_sources.dart';
import 'package:labguide/features/reference/reference_content.dart';

/// Domla kitoblari (gematologiya, anemiya, parazitologiya, jigar) bilimi:
/// kitob faqat iqtibos sifatida, har da'vo rasmiy/ochiq manba bilan
/// birga, uch tilda va qidiruvda topiladi.
ContentPack bundledPack() => ContentPack.fromJson(
  (jsonDecode(File('assets/content/core/pack.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

const books = [
  'book-najmitdinov-1998',
  'book-dolgov-2009',
  'book-lyubina-1984',
  'book-dadayev-2004',
  'book-sobirova-2006',
  'book-aripova-2007',
];

/// Kitob bilimi qo'shilgan kartalar.
const enriched = [
  'reticulocytes',
  'hemoglobin',
  'rbc-count',
  'hematocrit',
  'mcv',
  'mchc',
  'ferritin',
  'transferrin-tibc',
  'stool-ova-parasites',
  'pinworm-test',
  'fecal-occult-blood',
  'alt',
  'ast',
  'alp',
  'ggt',
  'bilirubin-total',
  'bilirubin-direct',
];

void main() {
  late ContentPack pack;
  setUpAll(() => pack = bundledPack());

  test('books are citation-only sources: no URL, no library file', () {
    for (final id in books) {
      final s = pack.source(id);
      expect(s, isNotNull, reason: id);
      expect(s!.isCitationOnlyBook, isTrue, reason: id);
      expect(s.url, isNull, reason: id);
      expect(s.libraryItemId, isNull, reason: id);
      expect(s.reuseRights, 'citation_only', reason: id);
      expect(s.note, contains('no text'), reason: id);
    }
    // Katalogda kitob faqat bibliografik yozuv (yoki o'qish havolasi):
    // fayl ham, oflayn paket ham yo'q; manba katalogga bog'lanmagan.
    for (final i in pack.library.where((i) => i.id.contains('lyubina'))) {
      expect(i.access, LibraryAccess.catalogOnly, reason: i.id);
      expect(i.file, isNull, reason: i.id);
      expect(i.filePack, isNull, reason: i.id);
    }
  });

  test('a citation-only book must not carry a URL', () {
    expect(
      () => ContentSource.fromJson({
        'id': 'book-x',
        'kind': 'book',
        'title': 'X',
        'publisher': 'Y',
        'url': 'https://example.org/x.pdf',
        'note': 'Citation only',
        'reuse_rights': 'citation_only',
      }),
      throwsFormatException,
    );
    expect(
      () => ContentSource.fromJson({
        'id': 'book-y',
        'kind': 'book',
        'title': 'Y',
        'publisher': 'Z',
        'reuse_rights': 'citation_only',
      }),
      throwsFormatException,
    );
  });

  test('every book-based claim is backed by an official or open source', () {
    final cited = <String>{};
    for (final id in enriched) {
      final a = pack.analyte(id)!;
      expect(a.status, ContentStatus.draft, reason: id);
      expect(a.isReviewerApproved, isFalse, reason: id);
      expect(a.agentChecks, isNotEmpty, reason: id);
      for (final c in a.claims) {
        for (final lang in ['uz', 'ru', 'en']) {
          expect(c.text.values[lang]?.trim(), isNotEmpty, reason: id);
        }
        expect(c.text.of('uz').contains("'"), isFalse, reason: id);
        final kinds = [for (final r in c.refs) pack.source(r.sourceId)!];
        for (final r in c.refs) {
          expect(r.locator, isNotEmpty, reason: '$id ${r.sourceId}');
        }
        if (kinds.any((s) => s.isCitationOnlyBook)) {
          cited.addAll([
            for (final s in kinds)
              if (s.isCitationOnlyBook) s.id,
          ]);
          // Kitob yolg'iz manba emas — kamida bitta veb-manba bilan birga
          // (yoki manba kitobning o'zi ekanini aytgan mahalliy kontekst).
          expect(
            kinds.any((s) => s.kind == 'web'),
            isTrue,
            reason: '$id: ${c.text.of('en')}',
          );
        }
      }
    }
    expect(
      cited,
      containsAll([
        'book-dolgov-2009',
        'book-lyubina-1984',
        'book-sobirova-2006',
        'book-aripova-2007',
        'book-dadayev-2004',
        'book-najmitdinov-1998',
      ]),
    );
  });

  test('reticulocyte card explains IRF, RET-He and MSCV', () {
    final text = pack
        .analyte('reticulocytes')!
        .claims
        .map((c) => c.text.of('en'))
        .join(' ');
    for (final term in ['IRF', 'RET-He', 'MSCV', 'CRC', 'NRBC']) {
      expect(text, contains(term));
    }
  });

  test('ferritin keeps WHO 2020 thresholds with inflammation', () {
    final limits = pack.analyte('ferritin')!.decisionLimits;
    final who = limits
        .where((d) => d.refs.any((r) => r.sourceId == 'who-ferritin-2020'))
        .map((d) => d.high)
        .toList();
    expect(who, [15, 70]);
  });

  test('anaemia and haemolysis guides; jaundice types in the guide', () {
    final anemia = pack.condition('anemia-workup')!;
    expect(anemia.status, ContentStatus.draft);
    expect(
      anemia.analyteIds,
      containsAll(['mcv', 'reticulocytes', 'ferritin']),
    );
    expect(anemia.patterns.length, greaterThanOrEqualTo(5));
    expect(pack.condition('hemolytic-anemia'), isNotNull);
    final jaundice = pack.condition('jaundice-cholestasis')!;
    final findings = jaundice.patterns.map((p) => p.finding.of('en')).join();
    expect(findings, contains('Prehepatic'));
    expect(findings, contains('Posthepatic'));
    expect(findings, contains('De Ritis'));
  });

  group(
    'search finds the new knowledge by Uzbek, Russian and English terms',
    () {
      late AnalyteSearch search;
      late ConditionSearch conditions;
      setUpAll(() {
        search = AnalyteSearch(pack);
        conditions = ConditionSearch(pack);
      });

      final cases = <(String, String, String)>[
        ('IRF', 'en', 'reticulocytes'),
        ('RET-He', 'en', 'reticulocytes'),
        ('фракция незрелых ретикулоцитов', 'ru', 'reticulocytes'),
        ('de Ritis', 'uz', 'ast'),
        ('коэффициент де Ритиса', 'ru', 'ast'),
        ('Kato surtmasi', 'uz', 'stool-ova-parasites'),
        ('толстый мазок по Като', 'ru', 'stool-ova-parasites'),
        ('Kato-Katz', 'en', 'stool-ova-parasites'),
        ('benzidin sinamasi', 'uz', 'fecal-occult-blood'),
        ('бензидиновая проба', 'ru', 'fecal-occult-blood'),
        ('mexanik sariqlik', 'uz', 'bilirubin-total'),
        ('подпечёночная желтуха', 'ru', 'bilirubin-total'),
        ('bog‘langan bilirubin', 'uz', 'bilirubin-direct'),
        ('rang ko‘rsatkichi', 'uz', 'mchc'),
        ('sovuq agglyutininlar', 'uz', 'rbc-count'),
      ];
      for (final (q, lang, id) in cases) {
        test('$q ($lang) → $id', () {
          expect(search.search(q, lang: lang).map((a) => a.id), contains(id));
        });
      }

      test('conditions: anaemia algorithm and haemolysis', () {
        List<String> ids(String q, String lang) => [
          for (final c in conditions.search(q, lang: lang)) c.id,
        ];
        expect(ids('anemiya algoritmi', 'uz'), contains('anemia-workup'));
        expect(ids('алгоритм анемии', 'ru'), contains('anemia-workup'));
        expect(ids('hemolytic anemia', 'en'), contains('hemolytic-anemia'));
        expect(
          ids('jigar osti sariqligi', 'uz'),
          contains('jaundice-cholestasis'),
        );
      });
    },
  );

  group('tables and algorithms (reference page)', () {
    test('every topic is complete in three languages and sourced', () {
      expect(refTopics.length, greaterThanOrEqualTo(6));
      final ids = <String>{};
      void check(LocalizedText t, String where) {
        for (final lang in ['uz', 'ru', 'en']) {
          expect(t.values[lang]?.trim(), isNotEmpty, reason: where);
        }
        expect(t.of('uz').contains("'"), isFalse, reason: where);
      }

      for (final t in refTopics) {
        expect(ids.add(t.id), isTrue, reason: t.id);
        check(t.title, t.id);
        check(t.summary, t.id);
        expect(t.blocks, isNotEmpty, reason: t.id);
        for (final a in t.analytes) {
          expect(pack.analyte(a), isNotNull, reason: '${t.id} → $a');
        }
        for (final b in t.blocks) {
          check(b.title, t.id);
          if (b.tag case final tag?) check(tag, t.id);
          expect(b.refs, isNotEmpty, reason: '${t.id} ${b.title.of('en')}');
          expect(b.facts.isNotEmpty || b.bullets.isNotEmpty, isTrue);
          for (final f in b.facts) {
            check(f.label, t.id);
            check(f.value, t.id);
          }
          for (final x in b.bullets) {
            check(x, t.id);
          }
          // Kitob yolg'iz manba emas.
          expect(
            b.refs.any((r) => r.source.url != null),
            isTrue,
            reason: '${t.id} ${b.title.of('en')}',
          );
        }
      }
    });

    test('reference sources match the content pack', () {
      final all = {
        for (final t in refTopics)
          for (final b in t.blocks)
            for (final r in b.refs) r.source,
      };
      for (final s in all) {
        final p = pack.source(s.id);
        expect(p, isNotNull, reason: s.id);
        if (s.url == null) {
          expect(p!.isCitationOnlyBook, isTrue, reason: s.id);
        } else {
          expect(p!.url, s.url, reason: s.id);
        }
      }
    });

    test('obsolete methods name a replacement; hazardous ones are flagged', () {
      final t = refTopic('obsolete-methods')!;
      for (final b in t.blocks) {
        expect(b.tag, isNotNull, reason: b.title.of('en'));
        expect(b.facts.length, 3, reason: b.title.of('en'));
      }
      final hazardous = [
        for (final b in t.blocks)
          if (b.warning) b.title.of('en'),
      ];
      expect(hazardous.join(), contains('benzidine'));
      expect(hazardous.join(), contains('Mercuric'));
    });

    test('analyte cards link to the matching tables', () {
      List<String> of(String a) => [
        for (final t in refTopicsForAnalyte(a)) t.id,
      ];
      expect(
        of('bilirubin-total'),
        containsAll(['jaundice', 'liver-syndromes']),
      );
      expect(of('mchc'), contains('spurious-cbc'));
      expect(of('stool-ova-parasites'), contains('stool-parasites'));
      expect(of('ferritin'), contains('anemia'));
      expect(refTopic('missing'), isNull);
    });
  });

  test('differential: classic (former-USSR) column and counting technique', () {
    for (final r in exampleRanges) {
      for (final lang in ['uz', 'ru', 'en']) {
        expect(r.classic.values[lang], isNotEmpty);
      }
    }
    final refs = [
      for (final s in techniqueSections)
        for (final r in s.refs) r.source.id,
    ];
    expect(refs, contains(DiffSources.lyubina1984.id));
    expect(DiffSources.lyubina1984.url, isNull);
    final text = techniqueSections
        .expand((s) => [s.title, ...s.items])
        .map((t) => t.of('en'))
        .join(' ');
    expect(text, contains('200'));
    expect(text, contains('zigzag'));
    expect(text, contains('tally'));
  });
}
