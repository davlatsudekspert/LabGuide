import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/learn_screens.dart';

/// Gormon kartalari (content_src/additions/endocrine.json → pack.json):
/// har karta manbali draft, har da'vo manbaga bog'langan, uch til to'liq,
/// qidiruvda qisqartma va sinonimlar bilan topiladi.
ContentPack bundledPack() => ContentPack.fromJson(
  (jsonDecode(File('assets/content/core/pack.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

/// Shifokor qo'llanmasi shu id larga havola qiladi (content_src/README.md).
const hormoneIds = [
  'tsh',
  'ft4',
  'ft3',
  'anti-tpo',
  'lh',
  'fsh',
  'prolactin',
  'estradiol',
  'progesterone',
  'testosterone',
  'hcg',
  'cortisol',
  'insulin',
  'c-peptide',
  'pth',
  'vitamin-d',
];

void main() {
  late ContentPack pack;
  late List<Analyte> hormones;

  setUpAll(() {
    pack = bundledPack();
    hormones = pack.analytes.where((a) => a.group == 'endocrine').toList();
  });

  test('endocrine group exists in three languages with canonical ids', () {
    final group = pack.group('endocrine')!;
    for (final lang in LocalizedText.requiredLanguages) {
      expect(group.names.values[lang], isNotEmpty, reason: lang);
    }
    expect(group.names.of('uz'), 'Gormonlar');
    expect(hormones.map((a) => a.id), hormoneIds);
  });

  test('every hormone card is a sourced draft awaiting review', () {
    for (final a in hormones) {
      expect(a.status, ContentStatus.draft, reason: a.id);
      expect(a.contentState, ContentState.sourcedSample, reason: a.id);
      expect(a.reviewState, ReviewState.pending, reason: a.id);
      expect(a.isReviewerApproved, isFalse, reason: a.id);
      expect(a.translationReview, {
        'uz': 'pending',
        'ru': 'pending',
        'en': 'pending',
      }, reason: a.id);
      // Referens interval va qaror chegarasi — faqat laboratoriya blankidan
      // (manbalarda universal raqam yo'q).
      expect(a.referenceIntervals, isEmpty, reason: a.id);
      expect(a.decisionLimits, isEmpty, reason: a.id);
      // Asosiy bo'limlar yozilgan.
      for (final s in ['purpose', 'physiology', 'preanalytics']) {
        expect(a.claimsFor(s), isNotEmpty, reason: '${a.id} $s');
      }
      expect(
        a.claims.where((c) => c.section.endsWith('_result')),
        isNotEmpty,
        reason: a.id,
      );
      expect(a.claimsFor('limitations'), isNotEmpty, reason: a.id);
    }
  });

  test('every claim cites a listed web source with a section locator', () {
    for (final a in hormones) {
      expect(a.sourceIds, isNotEmpty, reason: a.id);
      for (final c in a.claims) {
        expect(c.refs, isNotEmpty, reason: '${a.id} ${c.section}');
        for (final r in c.refs) {
          expect(a.sourceIds, contains(r.sourceId), reason: a.id);
          expect(r.locator, isNotEmpty, reason: '${a.id} ${r.sourceId}');
        }
      }
      for (final id in a.sourceIds) {
        final s = pack.source(id)!;
        expect(s.kind, 'web', reason: id);
        expect(s.url, startsWith('https://'), reason: id);
        expect(s.accessed, '2026-10-09', reason: id);
        expect(s.sourceDate, isNotNull, reason: id);
        // Faqat ochiq davlat manbalari (MedlinePlus, NIH, FDA).
        expect(
          Uri.parse(s.url!).host,
          anyOf(
            'medlineplus.gov',
            'www.niddk.nih.gov',
            'www.nichd.nih.gov',
            'www.fda.gov',
          ),
          reason: id,
        );
      }
    }
  });

  test('names, taglines, specimen and claims are complete in uz/ru/en', () {
    for (final a in hormones) {
      final texts = <LocalizedText>[
        a.names,
        a.tagline!,
        a.specimen!,
        for (final c in a.claims) c.text,
      ];
      for (final t in texts) {
        for (final lang in LocalizedText.requiredLanguages) {
          expect(t.values[lang]?.trim(), isNotEmpty, reason: '${a.id} $lang');
        }
        // O'zbekcha: o‘ g‘ — U+2018, tutuq belgisi — U+2019.
        final uz = t.values['uz']!;
        expect(uz.contains("'"), isFalse, reason: uz);
        expect(RegExp('[oOgG]’').hasMatch(uz), isFalse, reason: uz);
      }
      expect(a.synonyms, isNotEmpty, reason: a.id);
    }
  });

  test('related cards link both ways inside the thyroid panel', () {
    expect(pack.analyte('tsh')!.related, containsAll(['ft4', 'ft3']));
    expect(pack.analyte('ft4')!.related, contains('tsh'));
    expect(pack.analyte('pth')!.related, containsAll(['calcium', 'vitamin-d']));
    for (final a in hormones) {
      expect(a.related, isNotEmpty, reason: a.id);
      for (final r in a.related) {
        expect(pack.analyte(r), isNotNull, reason: '${a.id} → $r');
      }
    }
  });

  test('practice questions: 2–4 per hormone area, drafts with sources', () {
    final questions = questionsForGroup(pack, 'endocrine');
    expect(questions, hasLength(16));
    int count(List<String> ids) =>
        questions.where((q) => q.topicIds.any(ids.contains)).length;
    final areas = {
      'thyroid': ['tsh', 'ft4', 'ft3', 'anti-tpo'],
      'reproductive': [
        'lh',
        'fsh',
        'prolactin',
        'estradiol',
        'progesterone',
        'testosterone',
        'hcg',
      ],
      'adrenal': ['cortisol'],
      'glucose': ['insulin', 'c-peptide'],
      'bone': ['pth', 'vitamin-d'],
    };
    for (final e in areas.entries) {
      expect(count(e.value), inInclusiveRange(2, 4), reason: e.key);
    }
    for (final q in questions) {
      expect(q.isDraft, isTrue, reason: q.id);
      expect(q.refs, isNotEmpty, reason: q.id);
      for (final r in q.refs) {
        expect(pack.source(r.sourceId), isNotNull, reason: q.id);
        expect(r.locator, isNotEmpty, reason: q.id);
      }
      expect(q.options.length, greaterThanOrEqualTo(3), reason: q.id);
    }
  });

  group('search finds hormones by name, abbreviation and synonym', () {
    late AnalyteSearch search;
    setUpAll(() => search = AnalyteSearch(pack));

    List<String> ids(String q, {String lang = 'uz'}) =>
        search.search(q, lang: lang).map((a) => a.id).toList();

    test('abbreviations in Latin and Cyrillic', () {
      expect(ids('TSH').first, 'tsh');
      expect(ids('ТТГ', lang: 'ru').first, 'tsh');
      expect(ids('TTG').first, 'tsh');
      expect(ids('FT4').first, 'ft4');
      expect(ids('свТ4', lang: 'ru').first, 'ft4');
      expect(ids('свТ3', lang: 'ru').first, 'ft3');
      expect(ids('anti-TPO').first, 'anti-tpo');
      expect(ids('ЛГ', lang: 'ru').first, 'lh');
      expect(ids('ФСГ', lang: 'ru').first, 'fsh');
      expect(ids('ХГЧ', lang: 'ru').first, 'hcg');
      expect(ids('hCG', lang: 'en').first, 'hcg');
      expect(ids('ПТГ', lang: 'ru').first, 'pth');
      expect(ids('25(OH)D').first, 'vitamin-d');
    });

    test('names and topic words', () {
      expect(ids('prolactin', lang: 'en').first, 'prolactin');
      expect(ids('пролактин', lang: 'ru').first, 'prolactin');
      expect(ids('kortizol').first, 'cortisol');
      expect(ids('insulin').first, 'insulin');
      expect(ids('C-peptid').first, 'c-peptide');
      expect(ids('D vitamini').first, 'vitamin-d');
      expect(ids('homiladorlik testi').first, 'hcg');
      expect(ids('тест на беременность', lang: 'ru').first, 'hcg');
      // "qalqonsimon" — qalqonsimon bez kartalarining hammasi.
      expect(
        ids('qalqonsimon').toSet(),
        containsAll(['tsh', 'ft4', 'ft3', 'anti-tpo']),
      );
      expect(ids('qalqonsimon').first, isIn(['tsh', 'ft4', 'ft3', 'anti-tpo']));
      expect(ids('щитовидная', lang: 'ru').take(4).toSet(), {
        'tsh',
        'ft4',
        'ft3',
        'anti-tpo',
      });
    });

    test('existing searches keep their first hit', () {
      expect(ids('АЛТ', lang: 'ru'), ['alt']);
      expect(ids('kalsiy').first, 'calcium');
      expect(ids('glyukoza').first, 'glucose-plasma-fasting');
    });
  });
}
