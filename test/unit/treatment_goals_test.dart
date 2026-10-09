// Davolash maqsadlari (lipidlar), agent tekshiruvi yozuvlari va sutkalik
// siydik misol qiymatlari — model va validator.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';

Map<String, Object?> packJson() => (jsonDecode(
  File('assets/content/core/pack.json').readAsStringSync(),
) as Map).cast<String, Object?>();

ContentPack parse(Map<String, Object?> json) => ContentPack.fromJson(json);

Map<String, Object?> analyteOf(Map<String, Object?> json, String id) =>
    (json['analytes']! as List).cast<Map<String, Object?>>().firstWhere(
      (a) => a['id'] == id,
    );

List<Map<String, Object?>> goalsOf(Map<String, Object?> json, String id) =>
    (analyteOf(json, id)['treatment_goals']! as List)
        .cast<Map<String, Object?>>();

const langs = ['uz', 'ru', 'en'];

/// Audit A (docs/CONTENT_AUDIT_2026-10-09_A.md) tekshirgan 1–10-guruhlar.
const auditAGroups = [
  'carbohydrate',
  'kidney',
  'liver',
  'lipids',
  'proteins',
  'electrolytes',
  'enzymes',
  'urine',
  'endocrine',
  'infection-serology',
];

void main() {
  late ContentPack pack;
  setUpAll(() => pack = parse(packJson()));

  group('lipid treatment goals', () {
    test('LDL-C: four guidelines, each fully attributed', () {
      final ldl = pack.analyte('ldl-c')!;
      expect(ldl.treatmentGoals.map((g) => g.guidelineId).toSet(), {
        'ncep-atp3-2001',
        'ncep-atp3-2004',
        'esc-eas-2019',
        'acc-aha-2018',
      });
      for (final g in ldl.treatmentGoals) {
        expect(g.guidelineName, isNotEmpty);
        expect(g.year, inInclusiveRange(2001, 2019));
        for (final lang in langs) {
          expect(g.population.values[lang], isNotEmpty, reason: g.guidelineId);
          expect(g.target.values[lang], isNotEmpty, reason: g.guidelineId);
        }
        expect(g.refs, isNotEmpty);
        for (final r in g.refs) {
          expect(r.locator, isNotEmpty);
          expect(ldl.sourceIds, contains(r.sourceId));
        }
      }
      // Manbadagi raqamlar (ATP III 4/5-jadval, ESC/EAS 2019 7-jadval).
      String en(String id) => ldl.treatmentGoals
          .where((g) => g.guidelineId == id)
          .map((g) => g.target.of('en'))
          .join(' | ');
      expect(en('ncep-atp3-2001'), '< 100 mg/dL | < 130 mg/dL | < 160 mg/dL');
      expect(en('esc-eas-2019'), contains('< 1.4 mmol/L (< 55 mg/dL)'));
      expect(en('esc-eas-2019'), contains('< 1.8 mmol/L (< 70 mg/dL)'));
      expect(en('esc-eas-2019'), contains('< 2.6 mmol/L (< 100 mg/dL)'));
      expect(en('esc-eas-2019'), contains('< 3.0 mmol/L (< 116 mg/dL)'));
      expect(en('ncep-atp3-2004'), contains('optional goal: < 70 mg/dL'));
      expect(en('acc-aha-2018'), contains('≥ 70 mg/dL (≥ 1.8 mmol/L)'));
    });

    test('non-HDL-C goals; other lipid cards have none', () {
      final nonHdl = pack.analyte('non-hdl-c')!;
      expect(nonHdl.treatmentGoals.map((g) => g.guidelineId).toSet(), {
        'ncep-atp3-2001',
        'ncep-atp3-2004',
        'esc-eas-2019',
      });
      expect(
        nonHdl.treatmentGoals
            .where((g) => g.guidelineId == 'ncep-atp3-2001')
            .map((g) => g.target.of('en')),
        ['< 130 mg/dL', '< 160 mg/dL', '< 190 mg/dL'],
      );
      for (final id in ['cholesterol-total', 'hdl-c', 'triglycerides']) {
        expect(pack.analyte(id)!.treatmentGoals, isEmpty, reason: id);
      }
    });

    test('goals are kept apart from RI and DL; cards stay draft', () {
      for (final id in ['ldl-c', 'non-hdl-c']) {
        final a = pack.analyte(id)!;
        expect(a.referenceIntervals, isEmpty, reason: id);
        expect(a.decisionLimits, isEmpty, reason: id);
        expect(a.status, ContentStatus.draft);
        expect(a.reviewState, ReviewState.pending);
      }
    });

    test('one guideline id = one name and one year', () {
      for (final id in ['ldl-c', 'non-hdl-c']) {
        final seen = <String, (String, int)>{};
        for (final g in pack.analyte(id)!.treatmentGoals) {
          final v = seen.putIfAbsent(
            g.guidelineId,
            () => (g.guidelineName, g.year),
          );
          expect(v, (g.guidelineName, g.year));
        }
      }
    });
  });

  group('treatment goal validator', () {
    void rejects(String why, void Function(Map<String, Object?> goal) edit) {
      final json = packJson();
      edit(goalsOf(json, 'ldl-c').first);
      expect(() => parse(json), throwsFormatException, reason: why);
    }

    test(
      'accepts the bundled pack',
      () => expect(parse(packJson()), isNotNull),
    );

    test('rejects incomplete goals', () {
      rejects('no locator', (g) {
        g['refs'] = [
          {'source_id': 'nhlbi-atp3-xsum'},
        ];
      });
      rejects('empty locator', (g) {
        g['refs'] = [
          {'source_id': 'nhlbi-atp3-xsum', 'locator': ' '},
        ];
      });
      rejects('no refs', (g) => g['refs'] = <Object>[]);
      rejects('no year', (g) => g.remove('year'));
      rejects('string year', (g) => g['year'] = '2001');
      rejects('no guideline name', (g) => g['guideline_name'] = ' ');
      rejects('bad guideline id', (g) => g['guideline_id'] = 'NCEP ATP');
      rejects('no population', (g) => g.remove('population'));
      rejects('population without uz', (g) {
        g['population'] = {'ru': 'x', 'en': 'x'};
      });
      rejects('target lacks unit', (g) {
        g['target_text'] = {'uz': '< 100', 'ru': '< 100', 'en': '< 100'};
      });
      rejects('target without number', (g) {
        g['target_text'] = {'uz': 'mg/dL', 'ru': 'mg/dL', 'en': 'mg/dL'};
      });
      rejects('unlisted source', (g) {
        g['refs'] = [
          {'source_id': 'medline-crp', 'locator': 'x'},
        ];
      });
      rejects('same guideline, other year', (g) => g['year'] = 2002);
    });

    test('structure-only card cannot carry goals', () {
      final json = packJson();
      analyteOf(json, 'ldl-c')
        ..['content_state'] = 'structure_only'
        ..['claims'] = <Object>[]
        ..['decision_limits'] = <Object>[];
      expect(() => parse(json), throwsFormatException);
    });
  });

  group('agent checks', () {
    test('every card of audit A has the agent check; nothing approved', () {
      final ids = [
        for (final a in pack.analytes)
          if (auditAGroups.contains(a.group)) a.id,
      ];
      expect(ids, hasLength(59));
      for (final id in ids) {
        final a = pack.analyte(id)!;
        final check = a.agentChecks.singleWhere(
          (c) => c.report == 'docs/CONTENT_AUDIT_2026-10-09_A.md',
        );
        expect(check.date, '2026-10-09');
        expect(check.scope, isNotEmpty);
        expect(File(check.report).existsSync(), isTrue);
        expect(a.status, ContentStatus.draft, reason: id);
        expect(a.contentState, ContentState.sourcedSample, reason: id);
        expect(a.reviewState, ReviewState.pending, reason: id);
        expect(a.isReviewerApproved, isFalse, reason: id);
      }
      // Qolgan guruhlar (audit B) hali belgilanmagan.
      for (final a in pack.analytes) {
        if (!auditAGroups.contains(a.group)) {
          expect(
            a.agentChecks.where((c) => c.report.contains('_A.md')),
            isEmpty,
            reason: a.id,
          );
        }
      }
    });

    test('validator: date, scope and report required', () {
      void rejects(Map<String, Object?> check) {
        final json = packJson();
        (analyteOf(json, 'crp')['review']! as Map)['agent_checks'] = [check];
        expect(() => parse(json), throwsFormatException, reason: '$check');
      }

      const ok = {
        'date': '2026-10-09',
        'scope': 'sources',
        'report': 'docs/x.md',
      };
      rejects({...ok, 'date': '09.10.2026'});
      rejects({...ok, 'date': '2026-13-45'});
      rejects({...ok, 'scope': ''});
      rejects({...ok, 'report': ' '});
      expect(() => rejects({...ok}..remove('report')), throwsA(anything));
    });
  });

  group('urine-24h example values', () {
    late Analyte card;
    setUpAll(() => card = pack.analyte('urine-24h')!);

    test('no reference interval; examples labelled, 24 h units', () {
      expect(card.referenceIntervals, isEmpty);
      expect(card.decisionLimits, isEmpty);
      final examples = card.claims
          .where((c) => c.text.of('en').startsWith('Example reference'))
          .toList();
      expect(examples, hasLength(2));
      expect(examples[0].text.of('en'), contains('800–2,000 mL/24 h'));
      expect(examples[0].text.of('uz'), contains('800–2000 mL/24 soat'));
      expect(examples[0].text.of('ru'), contains('800–2000 mL/24 ч'));
      expect(examples[1].text.of('en'), contains('less than 100 mg/24 h'));
      expect(examples[1].text.of('uz'), contains('100 mg/24 soat dan kam'));
      expect(examples[1].text.of('ru'), contains('менее 100 mg/24 ч'));
      for (final c in examples) {
        expect(c.refs.single.locator, 'Normal Results');
        expect(c.text.of('en'), contains('own reference interval'));
        expect(c.text.of('uz'), contains('o‘z referens intervali'));
        expect(c.text.of('ru'), contains('своей лаборатории'));
        // Bir martalik namuna nisbatlari bilan aralashmaydi.
        expect(c.text.of('en'), isNot(contains('mg/g')));
      }
    });

    test('note separates 24-hour amounts from random-sample ratios', () {
      final note = card.notes['results']!;
      expect(note.of('en'), contains('ACR, mg/g'));
      expect(note.of('en'), contains('mL/24 h'));
      expect(note.of('uz'), contains('Bir martalik (tasodifiy)'));
      expect(note.of('ru'), contains('разовой (случайной)'));
      final limits = card.claimsFor('limitations').single;
      expect(limits.text.of('en'), contains('single (random) urine sample'));
    });
  });
}
