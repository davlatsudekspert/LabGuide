// Umumklinik tekshiruvlar: najas va parazitologiya, biologik suyuqliklar,
// siydik (sutkalik, ekma), sitologiya
// (content_src/additions/general_clinical.json) — paketdagi holati.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/content/ui/analyte_screen.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

const groups = {
  'stool-parasitology': [
    'stool-analysis',
    'stool-ova-parasites',
    'pinworm-test',
    'fecal-occult-blood',
    'h-pylori-tests',
  ],
  'body-fluids': [
    'csf-analysis',
    'pleural-fluid-analysis',
    'synovial-fluid-analysis',
    'sputum-afb',
    'sputum-culture',
  ],
  // Mavjud “Siydik tahlili” guruhiga qo'shiladi.
  'urine': ['urine-24h', 'urine-culture'],
  'cytology': ['pap-test', 'hpv-test', 'vaginal-wet-mount'],
};

const newGroups = ['stool-parasitology', 'body-fluids', 'cytology'];
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
      File('content_src/additions/general_clinical.json').readAsStringSync(),
    ) as Map).cast<String, Object?>();
    List<Map<String, Object?>> items(String key) => [
      for (final e in frag[key]! as List) (e as Map).cast<String, Object?>(),
    ];
    expect(items('analytes').map((a) => a['id']), [
      for (final ids in groups.values) ...ids,
    ]);
    for (final a in items('analytes')) {
      final id = a['id']! as String;
      expect((a['claims']! as List).length, pack.analyte(id)!.claims.length);
    }
    for (final s in items('sources')) {
      expect(pack.source(s['id']! as String), isNotNull, reason: '$s');
    }
    expect(items('groups').map((g) => g['id']), newGroups);
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
        expect(a.synonyms.length, greaterThanOrEqualTo(8), reason: a.id);
        expect(a.related, isNotEmpty, reason: a.id);
        // Sonli me'yorlar faqat matnda, manba izohi bilan.
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
          // O'zbekcha matnda to'g'ri belgilar (o‘, g‘, ’), oddiy ' yo'q.
          expect(c.text.of('uz').contains("'"), isFalse, reason: a.id);
        }
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

  test('sources: open government pages seen on 2026-10-09', () {
    final ids = {for (final a in cards) ...a.sourceIds};
    expect(ids.length, greaterThanOrEqualTo(40));
    for (final id in ids) {
      final s = pack.source(id)!;
      // Darsliklar — qo'shimcha manba (katalog yozuvi, faqat iqtibos).
      if (s.kind != 'web') {
        expect(s.libraryItemId, isNotNull, reason: id);
        expect(s.reuseRights, 'citation_only', reason: id);
        continue;
      }
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
          'www.niddk.nih.gov',
          'www.who.int',
          'iris.who.int',
        ),
        reason: id,
      );
    }
  });

  test('key facts stay tied to the right official source', () {
    bool cites(String card, String section, String source, String en) => pack
        .analyte(card)!
        .claimsFor(section)
        .any(
          (c) =>
              c.refs.any((r) => r.sourceId == source) &&
              c.text.of('en').contains(en),
        );
    // Sil: kamida 3 balg'am namunasi, manfiy surtma silni inkor etmaydi.
    expect(
      cites(
        'sputum-afb',
        'preanalytics',
        'cdc-tb-clinical-lab-diagnosis',
        'At least three',
      ),
      isTrue,
    );
    expect(
      cites(
        'sputum-afb',
        'negative_result',
        'cdc-tb-clinical-lab-diagnosis',
        'do not exclude TB',
      ),
      isTrue,
    );
    // Parazitologiya: 1:3 konservant, bariy/vismut xalaqiti (CDC DPDx).
    expect(
      cites(
        'stool-ova-parasites',
        'preanalytics',
        'cdc-dpdx-stool-collection',
        'three volumes',
      ),
      isTrue,
    );
    expect(
      cites(
        'stool-ova-parasites',
        'interference',
        'cdc-dpdx-stool-collection',
        'bismuth',
      ),
      isTrue,
    );
    // Enterobioz: tasma testi uch kun ketma-ket.
    expect(
      cites(
        'pinworm-test',
        'preanalytics',
        'cdc-pinworm-diagnosing',
        'three mornings',
      ),
      isTrue,
    );
    // PAP: Bethesda atamalari NCI dan.
    expect(
      cites('pap-test', 'results', 'nci-pdq-cervical-screening', 'Bethesda'),
      isTrue,
    );
    // Nam preparat: Amsel mezonlari CDC STI qo'llanmasidan.
    expect(
      cites('vaginal-wet-mount', 'positive_result', 'cdc-std-bv', 'Amsel'),
      isTrue,
    );
    // Light mezonlari: sonli chegaralar manbada yo'q — buni ochiq aytamiz.
    expect(
      cites(
        'pleural-fluid-analysis',
        'limitations',
        'medline-pleural-fluid',
        'does not give the numeric cut-offs',
      ),
      isTrue,
    );
  });

  test('results section title is localized', () {
    for (final lang in langs) {
      final l = lookupAppLocalizations(Locale(lang));
      expect(sectionTitle('results', l), l.sectionResults);
      expect(l.sectionResults, isNot('results'));
    }
  });

  group('search by synonyms (uz/ru/en)', () {
    late AnalyteSearch search;
    setUpAll(() => search = AnalyteSearch(pack));

    String first(String q, String lang) =>
        search.search(q, lang: lang).first.id;

    test('Uzbek (Latin and Cyrillic)', () {
      expect(first('koprogramma', 'uz'), 'stool-analysis');
      expect(first('gijja', 'uz'), 'stool-ova-parasites');
      expect(first('enterobioz', 'uz'), 'pinworm-test');
      expect(first('yashirin qon', 'uz'), 'fecal-occult-blood');
      expect(first('likvor', 'uz'), 'csf-analysis');
      expect(first('орқа мия суюқлиги', 'uz'), 'csf-analysis');
      expect(first('plevra suyuqligi', 'uz'), 'pleural-fluid-analysis');
      expect(first('bo‘g‘im suyuqligi', 'uz'), 'synovial-fluid-analysis');
      expect(first('balg‘amda sil', 'uz'), 'sputum-afb');
      expect(first('sutkalik siydik', 'uz'), 'urine-24h');
      expect(first('siydik ekmasi', 'uz'), 'urine-culture');
      expect(first('PAP-test', 'uz'), 'pap-test');
      expect(first('trixomonada', 'uz'), 'vaginal-wet-mount');
    });

    test('Russian', () {
      expect(first('копрограмма', 'ru'), 'stool-analysis');
      expect(first('кал на яйца глист', 'ru'), 'stool-ova-parasites');
      expect(first('энтеробиоз', 'ru'), 'pinworm-test');
      expect(first('скрытая кровь', 'ru'), 'fecal-occult-blood');
      expect(first('хеликобактер', 'ru'), 'h-pylori-tests');
      expect(first('ликвор', 'ru'), 'csf-analysis');
      expect(first('экссудат', 'ru'), 'pleural-fluid-analysis');
      expect(first('синовиальная жидкость', 'ru'), 'synovial-fluid-analysis');
      expect(first('мокрота на КУБ', 'ru'), 'sputum-afb');
      expect(first('посев мокроты', 'ru'), 'sputum-culture');
      expect(first('суточная моча', 'ru'), 'urine-24h');
      expect(first('посев мочи', 'ru'), 'urine-culture');
      expect(first('мазок по Папаниколау', 'ru'), 'pap-test');
      expect(first('ВПЧ', 'ru'), 'hpv-test');
      expect(first('ключевые клетки', 'ru'), 'vaginal-wet-mount');
      expect(
        search.search('мокрота', lang: 'ru').map((a) => a.id).toSet(),
        containsAll(['sputum-afb', 'sputum-culture']),
      );
    });

    test('English', () {
      expect(first('O&P', 'en'), 'stool-ova-parasites');
      expect(first('pinworm', 'en'), 'pinworm-test');
      expect(first('FIT', 'en'), 'fecal-occult-blood');
      expect(first('urea breath test', 'en'), 'h-pylori-tests');
      expect(first('lumbar puncture', 'en'), 'csf-analysis');
      expect(first('thoracentesis', 'en'), 'pleural-fluid-analysis');
      expect(first('joint fluid', 'en'), 'synovial-fluid-analysis');
      expect(first('AFB', 'en'), 'sputum-afb');
      expect(first('sputum culture', 'en'), 'sputum-culture');
      expect(first('24-hour urine', 'en'), 'urine-24h');
      expect(first('urine culture', 'en'), 'urine-culture');
      expect(first('Pap smear', 'en'), 'pap-test');
      expect(first('HPV', 'en'), 'hpv-test');
      expect(first('wet mount', 'en'), 'vaginal-wet-mount');
    });

    test('group filter keeps canonical order', () {
      for (final g in newGroups) {
        expect(
          search.search('', lang: 'uz', groupId: g).map((a) => a.id),
          groups[g],
          reason: g,
        );
      }
      // Siydik guruhida yangi kartalar mavjudlaridan keyin keladi.
      final urine = search.search('', lang: 'uz', groupId: 'urine');
      expect(urine.map((a) => a.id).skip(urine.length - 2), groups['urine']);
    });
  });

  test('quiz: 3–4 sourced draft questions per group (urine: 2 new)', () {
    for (final MapEntry(key: g, value: ids) in groups.entries) {
      final qs = pack.quiz.where((q) => q.topicIds.any(ids.contains)).toList();
      expect(qs.length, g == 'urine' ? 2 : inInclusiveRange(3, 4), reason: g);
      for (final q in qs) {
        expect(q.isDraft, isTrue, reason: q.id);
        expect(q.refs, isNotEmpty, reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
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
