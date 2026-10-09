import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/learn_screens.dart';

/// Yurak markerlari, temir va vitaminlar bo'lagi
/// (content_src/additions/cardio_iron.json) asosiy paketga to'g'ri
/// qo'shilganini tekshiradi.
ContentPack bundledPack() => ContentPack.fromJson(
  (jsonDecode(File('assets/content/core/pack.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

const cardiac = ['troponin', 'natriuretic-peptides', 'ck-mb', 'lipoprotein-a'];
const ironVitamins = [
  'iron',
  'ferritin',
  'transferrin-tibc',
  'vitamin-b12',
  'folate',
  'homocysteine',
  'methylmalonic-acid',
  'vitamin-e',
];
const allCards = [...cardiac, ...ironVitamins, 'lactate'];

void main() {
  late ContentPack pack;
  setUpAll(() => pack = bundledPack());

  test('both groups exist in three languages', () {
    for (final id in ['cardiac', 'iron-vitamins']) {
      final g = pack.group(id);
      expect(g, isNotNull, reason: id);
      for (final lang in LocalizedText.requiredLanguages) {
        expect(g!.names.values[lang], isNotEmpty, reason: '$id $lang');
      }
    }
    expect(pack.group('cardiac')!.names.of('uz'), 'Yurak markerlari');
    expect(pack.group('iron-vitamins')!.names.of('uz'), 'Temir va vitaminlar');
    expect([
      for (final a in pack.analytes)
        if (a.group == 'cardiac') a.id,
    ], cardiac);
    expect([
      for (final a in pack.analytes)
        if (a.group == 'iron-vitamins') a.id,
    ], ironVitamins);
    expect(pack.analyte('lactate')!.group, 'carbohydrate');
  });

  test('every new card is a sourced draft with three languages', () {
    for (final id in allCards) {
      final a = pack.analyte(id);
      expect(a, isNotNull, reason: id);
      a!;
      expect(a.status, ContentStatus.draft, reason: id);
      expect(a.contentState, ContentState.sourcedSample, reason: id);
      expect(a.reviewState, ReviewState.pending, reason: id);
      expect(a.isReviewerApproved, isFalse, reason: id);
      expect(a.translationReview, {
        'uz': 'pending',
        'ru': 'pending',
        'en': 'pending',
      }, reason: id);
      expect(a.referenceIntervals, isEmpty, reason: id);
      expect(a.synonyms.length, greaterThanOrEqualTo(5), reason: id);
      expect(a.units, isNotEmpty, reason: id);
      for (final text in [a.names, a.tagline!, a.specimen!]) {
        for (final lang in LocalizedText.requiredLanguages) {
          expect(text.values[lang]!.trim(), isNotEmpty, reason: '$id $lang');
        }
      }
      // Har bo'limda kamida bitta manbali da'vo yoki tahririy izoh.
      for (final s in a.sections.where((s) => s != 'related_tests')) {
        expect(
          a.claimsFor(s).isNotEmpty || a.notes.containsKey(s),
          isTrue,
          reason: '$id $s',
        );
      }
      for (final c in a.claims) {
        expect(c.refs, isNotEmpty, reason: '$id ${c.section}');
        for (final r in c.refs) {
          expect(r.locator, isNotEmpty, reason: '$id ${c.section}');
          expect(a.sourceIds, contains(r.sourceId), reason: id);
        }
        for (final lang in LocalizedText.requiredLanguages) {
          expect(c.text.values[lang]!.trim(), isNotEmpty, reason: id);
        }
        expect(c.text.values['uz']!.contains("'"), isFalse, reason: id);
      }
      for (final r in a.related) {
        expect(pack.analyte(r), isNotNull, reason: '$id → $r');
      }
    }
  });

  test('sources are dated open government web pages', () {
    final cited = {for (final id in allCards) ...pack.analyte(id)!.sourceIds};
    for (final id in cited) {
      final s = pack.source(id)!;
      // Kitob — faqat iqtibos (havolasiz, kutubxonaga qo'yilmaydi).
      if (s.kind == 'book') {
        expect(s.isCitationOnlyBook, isTrue, reason: id);
        continue;
      }
      expect(s.kind, 'web', reason: id);
      expect(s.url, startsWith('https://'), reason: id);
      expect(s.accessed, isNotNull, reason: id);
      expect(s.sourceDate, isNotNull, reason: id);
      expect(
        Uri.parse(s.url!).host,
        anyOf(
          'medlineplus.gov',
          'www.nhlbi.nih.gov',
          'www.niddk.nih.gov',
          'ods.od.nih.gov',
          'www.cdc.gov',
          'www.who.int',
          'doi.org',
        ),
        reason: id,
      );
    }
  });

  test('decision limits keep the source bounds and wording', () {
    (double?, double?, bool, bool) b(DecisionLimit d) =>
        (d.low, d.high, d.lowExclusive, d.highExclusive);
    final ferritin = pack.analyte('ferritin')!.decisionLimits;
    expect(ferritin.map(b), [
      (null, 30, false, true), // ODS: < 30 µg/L
      (null, 10, false, true), // ODS: < 10 µg/L
      (null, 15, false, false), // CDC 1998: ≤ 15 µg/L
      (null, 15, false, true), // JSST 2020: sog'lom kattalar < 15 µg/L
      (null, 70, false, true), // JSST 2020: yallig'lanishda < 70 µg/L
    ]);
    expect(ferritin.every((d) => d.unit == 'µg/L'), isTrue);
    expect(pack.analyte('transferrin-tibc')!.decisionLimits.map(b), [
      (null, 16, false, true),
    ]);
    expect(pack.analyte('vitamin-b12')!.decisionLimits.map(b), [
      (null, 200, false, false),
      (150, 399, false, false),
    ]);
    expect(pack.analyte('folate')!.decisionLimits.map(b), [
      (3, null, true, false),
      (140, null, true, false),
    ]);
    expect(pack.analyte('methylmalonic-acid')!.decisionLimits.map(b), [
      (0.271, null, true, false),
    ]);
    // Ochiq manbada qaror chegarasi topilmagan kartalar — raqamsiz.
    for (final id in ['troponin', 'natriuretic-peptides', 'lipoprotein-a']) {
      expect(pack.analyte(id)!.decisionLimits, isEmpty, reason: id);
    }
    expect(pack.analyte('troponin')!.notes.keys, ['limitations']);
  });

  test('lactate converts with the lactic acid molar mass', () {
    final c = pack.analyte('lactate')!.conversion!;
    // C3H6O3: 3 × 12.011 + 6 × 1.008 + 3 × 15.999.
    expect(c.molarMass, closeTo(3 * 12.011 + 6 * 1.008 + 3 * 15.999, 1e-9));
    expect(c.siUnit, 'mmol/L');
  });

  group('search finds new cards by synonyms', () {
    late AnalyteSearch search;
    setUpAll(() => search = AnalyteSearch(pack));

    String first(String q, String lang) =>
        search.search(q, lang: lang).first.id;

    final cases = <(String, String, String)>[
      ('troponin', 'uz', 'troponin'),
      ('тропонин', 'ru', 'troponin'),
      ('hs-cTnI', 'en', 'troponin'),
      ('NT-proBNP', 'en', 'natriuretic-peptides'),
      ('НУП', 'ru', 'natriuretic-peptides'),
      ('КК-МВ', 'ru', 'ck-mb'),
      ('CK-MB', 'en', 'ck-mb'),
      ('Lp(a)', 'en', 'lipoprotein-a'),
      ('липопротеин а', 'ru', 'lipoprotein-a'),
      ('temir', 'uz', 'iron'),
      ('сывороточное железо', 'ru', 'iron'),
      ('ферритин', 'ru', 'ferritin'),
      ('ОЖСС', 'ru', 'transferrin-tibc'),
      ('TIBC', 'en', 'transferrin-tibc'),
      ('transferrin to‘yinishi', 'uz', 'transferrin-tibc'),
      ('B12', 'uz', 'vitamin-b12'),
      ('кобаламин', 'ru', 'vitamin-b12'),
      ('foliy kislotasi', 'uz', 'folate'),
      ('фолиевая кислота', 'ru', 'folate'),
      ('гомоцистеин', 'ru', 'homocysteine'),
      ('MMA', 'en', 'methylmalonic-acid'),
      ('токоферол', 'ru', 'vitamin-e'),
      ('sut kislotasi', 'uz', 'lactate'),
      ('лактат', 'ru', 'lactate'),
    ];
    for (final (q, lang, id) in cases) {
      test('$q ($lang) → $id', () => expect(first(q, lang), id));
    }

    test('existing searches still win', () {
      expect(first('КК', 'ru'), 'ck');
      expect(first('СРБ', 'ru'), 'crp');
    });
  });

  test('quiz: each new group has sourced draft questions', () {
    final ids = {for (final q in pack.quiz) q.id};
    for (final g in ['cardiac', 'iron-vitamins']) {
      final qs = questionsForGroup(pack, g);
      expect(qs.length, inInclusiveRange(2, 4), reason: g);
      for (final q in qs) {
        expect(q.isDraft, isTrue, reason: q.id);
        expect(q.refs, isNotEmpty, reason: q.id);
        expect(q.refs.every((r) => r.locator != null), isTrue, reason: q.id);
        expect(q.prompt.values['uz']!.contains("'"), isFalse, reason: q.id);
      }
    }
    expect(ids, contains('lactate-q1'));
    // TSAT savoli: to'g'ri javob formuladan kelib chiqadi (50/400×100).
    final tsat = pack.quiz.firstWhere((q) => q.id == 'transferrin-tibc-q1');
    expect(tsat.options[tsat.correctIndex].text.of('en'), '${50 / 400 * 100}%');
  });
}
