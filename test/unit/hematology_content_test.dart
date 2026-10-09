import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/learn_screens.dart';

/// Gematologiya va koagulyatsiya bo'lagi (content_src/additions/hematology.json)
/// asosiy paketga to'g'ri qo'shilganini tekshiradi.
ContentPack bundledPack() => ContentPack.fromJson(
  (jsonDecode(File('assets/content/core/pack.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
);

const hematology = [
  'hemoglobin',
  'hematocrit',
  'rbc-count',
  'wbc-count',
  'neutrophils',
  'lymphocytes',
  'monocytes',
  'eosinophils',
  'basophils',
  'platelets',
  'mcv',
  'mch',
  'mchc',
  'rdw',
  'reticulocytes',
  'esr',
  // Qo'shimcha (kanonik ro'yxatdan tashqari) kartalar.
  'mpv',
  'blood-smear',
  'hemoglobin-electrophoresis',
  'g6pd',
];
const coagulation = [
  'pt-inr',
  'aptt',
  'fibrinogen',
  'd-dimer',
  'coagulation-factors',
  'protein-c-s',
];

/// Umumiy qon tahlili (OAK/ОАК/CBC) tarkibidagi kartalar.
const cbcCards = [
  'hemoglobin',
  'hematocrit',
  'rbc-count',
  'wbc-count',
  'neutrophils',
  'lymphocytes',
  'monocytes',
  'eosinophils',
  'basophils',
  'platelets',
  'mcv',
  'mch',
  'mchc',
  'rdw',
  'mpv',
];

void main() {
  late ContentPack pack;
  late AnalyteSearch search;

  setUpAll(() {
    pack = bundledPack();
    search = AnalyteSearch(pack);
  });

  List<String> ids(String q, {String lang = 'uz', String? group}) =>
      search.search(q, lang: lang, groupId: group).map((a) => a.id).toList();

  test('groups exist with names in three languages', () {
    final h = pack.group('hematology')!;
    final c = pack.group('coagulation')!;
    expect(h.names.of('uz'), 'Gematologiya (umumiy qon tahlili)');
    expect(c.names.of('uz'), 'Qon ivishi (koagulyatsiya)');
    for (final g in [h, c]) {
      for (final lang in ['uz', 'ru', 'en']) {
        expect(g.names.values[lang], isNotEmpty, reason: '${g.id} $lang');
      }
    }
    expect(ids('', group: 'hematology'), hematology);
    expect(ids('', group: 'coagulation'), coagulation);
  });

  test('every card is a sourced draft with refs on every claim', () {
    for (final id in [...hematology, ...coagulation]) {
      final a = pack.analyte(id)!;
      expect(a.status, ContentStatus.draft, reason: id);
      expect(a.contentState, ContentState.sourcedSample, reason: id);
      expect(a.isReviewerApproved, isFalse, reason: id);
      expect(a.referenceIntervals, isEmpty, reason: id);
      expect(a.claims.length, greaterThanOrEqualTo(5), reason: id);
      expect(a.sections, containsAll(['purpose', 'preanalytics']), reason: id);
      expect(a.related, isNotEmpty, reason: id);
      for (final lang in ['uz', 'ru', 'en']) {
        expect(a.names.values[lang], isNotEmpty, reason: '$id $lang');
        expect(a.tagline!.values[lang], isNotEmpty, reason: '$id $lang');
        expect(a.specimen!.values[lang], isNotEmpty, reason: '$id $lang');
      }
      for (final c in a.claims) {
        expect(c.refs, isNotEmpty, reason: '$id ${c.section}');
        for (final r in c.refs) {
          expect(r.locator, isNotEmpty, reason: '$id ${c.section}');
          final s = pack.source(r.sourceId)!;
          expect(s.url, startsWith('https://'), reason: s.id);
        }
        for (final lang in ['uz', 'ru', 'en']) {
          expect(c.text.values[lang]?.trim(), isNotEmpty, reason: '$id $lang');
        }
      }
    }
  });

  test('specimen tubes follow the WHO order-of-draw table', () {
    bool citesWhoTable(Analyte a) => a.claims.any(
      (c) =>
          c.section == 'preanalytics' &&
          c.refs.any(
            (r) => r.sourceId == 'who-phlebotomy-2010' && r.pages == '16',
          ),
    );
    for (final id in cbcCards) {
      final a = pack.analyte(id)!;
      expect(a.specimen!.of('en'), contains('EDTA'), reason: id);
      expect(citesWhoTable(a), isTrue, reason: id);
    }
    for (final id in ['pt-inr', 'aptt', 'fibrinogen', 'coagulation-factors']) {
      final a = pack.analyte(id)!;
      expect(a.specimen!.of('en'), contains('sodium citrate'), reason: id);
      expect(citesWhoTable(a), isTrue, reason: id);
    }
  });

  test('decision limits keep the source wording', () {
    final hb = pack.analyte('hemoglobin')!.decisionLimits;
    expect(hb, hasLength(9));
    expect(hb.every((d) => d.unit == 'g/L' && d.highExclusive), isTrue);
    expect(hb.every((d) => d.sourceIds.single == 'who-hb-cutoffs-2024'), isTrue);
    double cutoff(String population) =>
        hb.firstWhere((d) => d.population.of('en') == population).high!;
    expect(cutoff('Non-pregnant women 15–65 years'), 120);
    expect(cutoff('Men 15–65 years'), 130);
    expect(cutoff('Pregnancy, second trimester'), 105);

    final plt = pack.analyte('platelets')!.decisionLimits;
    final low = plt.firstWhere((d) => d.low == null && d.high == 150000);
    expect(low.highExclusive, isTrue);
    final high = plt.firstWhere((d) => d.low == 450000);
    expect(high.lowExclusive, isTrue);
    expect(plt.every((d) => d.unit == '/µL'), isTrue);

    final factors = pack.analyte('coagulation-factors')!.decisionLimits;
    expect(factors.map((d) => (d.low, d.high)), [
      (5, 40),
      (1, 5),
      (null, 1),
    ]);
    // INR, D-dimer va fibrinogen uchun manbada raqam yo'q — chegara ham yo'q.
    for (final id in ['pt-inr', 'd-dimer', 'fibrinogen', 'esr']) {
      expect(pack.analyte(id)!.decisionLimits, isEmpty, reason: id);
    }
  });

  test('search finds cards by synonyms in uz, ru and en', () {
    expect(ids('gemoglobin').first, 'hemoglobin');
    expect(ids('Hb').first, 'hemoglobin');
    expect(ids('гемоглобин', lang: 'ru').first, 'hemoglobin');
    expect(ids('hemoglobin', lang: 'en').first, 'hemoglobin');
    expect(ids('hba1c').first, 'hba1c');
    expect(ids('EChT').first, 'esr');
    expect(ids('СОЭ', lang: 'ru').first, 'esr');
    expect(ids('ESR', lang: 'en').first, 'esr');
    expect(ids('AChTV').first, 'aptt');
    expect(ids('АЧТВ', lang: 'ru').first, 'aptt');
    expect(ids('aPTT', lang: 'en').first, 'aptt');
    expect(ids('МНО', lang: 'ru').first, 'pt-inr');
    expect(ids('INR', lang: 'en').first, 'pt-inr');
    expect(ids('Д-димер', lang: 'ru').first, 'd-dimer');
    expect(ids('trombotsitlar').first, 'platelets');
    expect(ids('тромбоциты', lang: 'ru').first, 'platelets');
    expect(ids('leykotsitlar').first, 'wbc-count');
    expect(ids('фибриноген', lang: 'ru').first, 'fibrinogen');
    expect(ids('eozinofil').first, 'eosinophils');
    expect(ids('ретикулоциты', lang: 'ru').first, 'reticulocytes');
    // O'zbek kirill yozuvi lotinga o'giriladi.
    expect(ids('гематокрит').first, 'hematocrit');
  });

  test('complete blood count (OAK / ОАК / CBC) finds every CBC card', () {
    for (final q in ['OAK', 'ОАК', 'CBC', 'umumiy qon tahlili']) {
      expect(ids(q), containsAll(cbcCards), reason: q);
    }
    expect(
      ids('leykoformula'),
      containsAll([
        'neutrophils',
        'lymphocytes',
        'monocytes',
        'eosinophils',
        'basophils',
      ]),
    );
  });

  test('practice questions: each group has sourced questions', () {
    for (final g in ['hematology', 'coagulation']) {
      final qs = questionsForGroup(pack, g);
      expect(qs.length, greaterThanOrEqualTo(4), reason: g);
      for (final q in qs) {
        expect(q.isDraft, isTrue, reason: q.id);
        expect(q.refs, isNotEmpty, reason: q.id);
        for (final lang in ['uz', 'ru', 'en']) {
          expect(q.prompt.values[lang], isNotEmpty, reason: '${q.id} $lang');
        }
      }
    }
    // Har kanonik kartada kamida bitta savol (karta ichidan mashq).
    for (final id in [...hematology, ...coagulation]) {
      expect(questionsForAnalyte(pack, id), isNotEmpty, reason: id);
    }
  });
}
