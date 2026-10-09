// Infeksiya serologiyasi, autoimmun testlar va o'sma markerlari
// (content_src/additions/infection_immuno.json) — paketdagi holati.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/content/ui/analyte_screen.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

const groups = {
  'infection-serology': [
    'hbsag',
    'anti-hcv',
    'hiv-test',
    'syphilis-tests',
    'procalcitonin',
  ],
  'autoimmune': ['aso', 'rheumatoid-factor', 'anti-ccp', 'ana'],
  'tumor-markers': ['psa', 'cea', 'afp', 'ca-125', 'ca-19-9'],
};

const serology = ['hbsag', 'anti-hcv', 'hiv-test', 'syphilis-tests'];
const langs = ['uz', 'ru', 'en'];

ContentPack bundledPack() => ContentPack.fromJson(
  (jsonDecode(File('assets/content/core/pack.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

void main() {
  late ContentPack pack;
  late List<Analyte> cards;

  setUpAll(() {
    pack = bundledPack();
    cards = [
      for (final ids in groups.values)
        for (final id in ids) pack.analyte(id)!,
    ];
  });

  test('fragment file and pack agree (run tool/build_core_pack.py)', () {
    final frag = (jsonDecode(
      File('content_src/additions/infection_immuno.json').readAsStringSync(),
    ) as Map).cast<String, Object?>();
    List<Map<String, Object?>> items(String key) => [
      for (final e in frag[key]! as List) (e as Map).cast<String, Object?>(),
    ];
    expect(items('analytes').map((a) => a['id']), [
      for (final ids in groups.values) ...ids,
    ]);
    for (final a in items('analytes')) {
      // Bo'lak va paketdagi karta bir xil (pack.json qo'lda tahrirlanmagan).
      final id = a['id']! as String;
      expect((a['claims']! as List).length, pack.analyte(id)!.claims.length);
    }
    for (final s in items('sources')) {
      expect(pack.source(s['id']! as String), isNotNull, reason: '$s');
    }
  });

  test('groups and canonical ids, three languages', () {
    for (final MapEntry(key: g, value: ids) in groups.entries) {
      final group = pack.group(g);
      expect(group, isNotNull, reason: g);
      for (final lang in langs) {
        expect(group!.names.values[lang], isNotEmpty, reason: '$g $lang');
      }
      for (final id in ids) {
        expect(pack.analyte(id)?.group, g, reason: id);
      }
    }
  });

  test(
    'every card: sourced draft, each claim cited with a locator, 3 languages',
    () {
      for (final a in cards) {
        expect(a.status, ContentStatus.draft, reason: a.id);
        expect(a.contentState, ContentState.sourcedSample, reason: a.id);
        expect(a.isReviewerApproved, isFalse, reason: a.id);
        expect(a.translationReview, {
          'uz': 'pending',
          'ru': 'pending',
          'en': 'pending',
        });
        expect(a.claims.length, greaterThanOrEqualTo(6), reason: a.id);
        expect(a.synonyms.length, greaterThanOrEqualTo(5), reason: a.id);
        expect(a.related, isNotEmpty, reason: a.id);
        // Referens interval va qaror chegarasi yo'q: manbalar umumiy son bermaydi.
        expect(a.referenceIntervals, isEmpty, reason: a.id);
        expect(a.decisionLimits, isEmpty, reason: a.id);
        for (final text in [a.names, a.tagline!, a.specimen!]) {
          for (final lang in langs) {
            expect(
              text.values[lang]?.trim(),
              isNotEmpty,
              reason: '${a.id} $lang',
            );
          }
        }
        for (final c in a.claims) {
          expect(c.refs, isNotEmpty, reason: '${a.id} ${c.section}');
          for (final r in c.refs) {
            expect(r.locator, isNotEmpty, reason: '${a.id} ${c.section}');
            expect(a.sourceIds, contains(r.sourceId));
          }
          for (final lang in langs) {
            expect(c.text.values[lang]?.trim(), isNotEmpty, reason: a.id);
          }
        }
        // Har bir bo'limda kamida bitta da'vo yoki izoh bor.
        for (final s in a.sections.where((s) => s != 'related_tests')) {
          expect(
            a.claimsFor(s).isNotEmpty || a.notes.containsKey(s),
            isTrue,
            reason: '${a.id} $s',
          );
        }
      }
    },
  );

  test(
    'sources: open web pages seen on 2026-10-09, rights still to verify',
    () {
      final ids = {for (final a in cards) ...a.sourceIds};
      expect(ids.length, greaterThanOrEqualTo(20));
      for (final id in ids) {
        final s = pack.source(id)!;
        expect(s.kind, 'web', reason: id);
        expect(s.url, startsWith('https://'), reason: id);
        expect(s.accessed, '2026-10-09', reason: id);
        expect(s.sourceDate, isNotNull, reason: id);
        expect(s.reuseRights, 'verify_before_distribution', reason: id);
        expect(
          Uri.parse(s.url!).host,
          anyOf(
            'medlineplus.gov',
            'www.cdc.gov',
            'www.cancer.gov',
            'iris.who.int',
          ),
          reason: id,
        );
      }
    },
  );

  test('serology cards: positive/negative sections and a privacy note', () {
    for (final id in serology) {
      final a = pack.analyte(id)!;
      expect(a.claimsFor('positive_result'), isNotEmpty, reason: id);
      expect(a.claimsFor('negative_result'), isNotEmpty, reason: id);
      expect(a.notes['limitations'], isNotNull, reason: id);
    }
    // Musbat skrining natijasi tasdiqlovchi testni talab qiladi.
    final hiv = pack.analyte('hiv-test')!.claimsFor('positive_result');
    expect(hiv.any((c) => c.text.of('en').contains('follow-up test')), isTrue);
    final syph = pack.analyte('syphilis-tests')!.claimsFor('positive_result');
    expect(
      syph.any((c) => c.text.of('en').contains('treponemal test')),
      isTrue,
    );
    final hcv = pack.analyte('anti-hcv')!.claimsFor('positive_result');
    expect(hcv.any((c) => c.text.of('en').contains('HCV RNA')), isTrue);
  });

  test('tumor markers: never presented as a stand-alone screening test', () {
    for (final id in groups['tumor-markers']!) {
      final a = pack.analyte(id)!;
      final limits = a.claimsFor('limitations');
      expect(
        limits.any((c) => c.refs.any((r) => r.sourceId == 'nci-tumor-markers')),
        isTrue,
        reason: id,
      );
      expect(
        limits.any((c) => c.text.of('en').contains('screen')),
        isTrue,
        reason: id,
      );
    }
  });

  test('new section titles are localized', () {
    for (final lang in langs) {
      final l = lookupAppLocalizations(Locale(lang));
      expect(sectionTitle('positive_result', l), l.sectionPositiveResult);
      expect(sectionTitle('negative_result', l), l.sectionNegativeResult);
      expect(l.sectionPositiveResult, isNot('positive_result'));
    }
  });

  group('search by synonyms (uz/ru/en)', () {
    late AnalyteSearch search;
    setUpAll(() => search = AnalyteSearch(pack));

    String first(String q, String lang) =>
        search.search(q, lang: lang).first.id;

    test('Uzbek', () {
      expect(first('gepatit B', 'uz'), 'hbsag');
      expect(first('gepatit C', 'uz'), 'anti-hcv');
      expect(first('OIV', 'uz'), 'hiv-test');
      expect(first('zaxm', 'uz'), 'syphilis-tests');
      expect(first('prokalsitonin', 'uz'), 'procalcitonin');
      expect(first('revmatoid omil', 'uz'), 'rheumatoid-factor');
      expect(first('antinuklear', 'uz'), 'ana');
      expect(first('alfa-fetoprotein', 'uz'), 'afp');
    });

    test('Russian (incl. Cyrillic look-alike letters)', () {
      expect(first('гепатит В', 'ru'), 'hbsag');
      expect(first('гепатит С', 'ru'), 'anti-hcv');
      expect(first('ВИЧ', 'ru'), 'hiv-test');
      expect(first('реакция Вассермана', 'ru'), 'syphilis-tests');
      expect(first('АСЛО', 'ru'), 'aso');
      expect(first('АЦЦП', 'ru'), 'anti-ccp');
      expect(first('АНФ', 'ru'), 'ana');
      expect(first('ПСА', 'ru'), 'psa');
      expect(first('РЭА', 'ru'), 'cea');
      expect(first('АФП', 'ru'), 'afp');
      expect(first('СА-125', 'ru'), 'ca-125');
      expect(first('СА 19-9', 'ru'), 'ca-19-9');
      expect(
        search.search('онкомаркер', lang: 'ru').map((a) => a.id).toSet(),
        containsAll(groups['tumor-markers']!),
      );
    });

    test('English', () {
      expect(first('HBsAg', 'en'), 'hbsag');
      expect(first('hepatitis C', 'en'), 'anti-hcv');
      expect(first('HIV', 'en'), 'hiv-test');
      expect(first('RPR', 'en'), 'syphilis-tests');
      expect(first('procalcitonin', 'en'), 'procalcitonin');
      expect(first('ASO', 'en'), 'aso');
      expect(first('rheumatoid factor', 'en'), 'rheumatoid-factor');
      expect(first('anti-CCP', 'en'), 'anti-ccp');
      expect(first('ANA', 'en'), 'ana');
      expect(first('PSA', 'en'), 'psa');
      expect(first('CEA', 'en'), 'cea');
      expect(first('CA-125', 'en'), 'ca-125');
      expect(first('CA19-9', 'en'), 'ca-19-9');
    });

    test('group filter keeps canonical order', () {
      for (final MapEntry(key: g, value: ids) in groups.entries) {
        expect(
          search.search('', lang: 'uz', groupId: g).map((a) => a.id),
          ids,
          reason: g,
        );
      }
    });
  });

  test('quiz: 2–4 sourced draft questions per group', () {
    for (final MapEntry(key: g, value: ids) in groups.entries) {
      final qs = pack.quiz.where((q) => q.topicIds.any(ids.contains)).toList();
      expect(qs.length, inInclusiveRange(2, 4), reason: g);
      for (final q in qs) {
        expect(q.isDraft, isTrue, reason: q.id);
        expect(q.refs, isNotEmpty, reason: q.id);
        for (final r in q.refs) {
          expect(pack.source(r.sourceId), isNotNull, reason: q.id);
          expect(r.locator, isNotEmpty, reason: q.id);
        }
        for (final lang in langs) {
          expect(q.prompt.values[lang], isNotEmpty, reason: q.id);
          for (final o in q.options) {
            expect(o.text.values[lang], isNotEmpty, reason: q.id);
            expect(o.explanation.values[lang], isNotEmpty, reason: q.id);
          }
        }
      }
    }
  });
}
