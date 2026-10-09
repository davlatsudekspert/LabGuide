import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/condition_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:labguide/features/content/ui/conditions_screens.dart';

Map<String, Object?> packJson() => (jsonDecode(
  File('assets/content/core/pack.json').readAsStringSync(),
) as Map).cast<String, Object?>();

/// `content_src/README.md` jadvalidagi kanonik analit id lari.
Set<String> canonicalIds() {
  final ids = <String>{};
  for (final line in File('content_src/README.md').readAsLinesSync()) {
    if (!line.startsWith('|')) continue;
    final cells = line.split('|');
    if (cells.length < 4) continue;
    ids.addAll(RegExp('`([a-z0-9-]+)`').allMatches(cells[3]).map((m) => m[1]!));
  }
  return ids;
}

Map<String, Object?> minimalCondition() => {
  'id': 'test-cond',
  'status': 'draft',
  'system': 'endocrine',
  'names': {'uz': 'A', 'ru': 'А', 'en': 'A'},
  'synonyms': ['x'],
  'summary': {
    'text': {'uz': 'a', 'ru': 'а', 'en': 'a'},
    'refs': [
      {'source_id': 'niddk-diagnosis', 'locator': 'A1C test'},
    ],
  },
  'panel': [
    {
      'analyte_id': 'hba1c',
      'names': {'uz': 'a', 'ru': 'а', 'en': 'a'},
      'why': {'uz': 'a', 'ru': 'а', 'en': 'a'},
      'tier': 'first_line',
      'refs': [
        {'source_id': 'niddk-diagnosis', 'locator': 'A1C test'},
      ],
    },
  ],
  'patterns': [
    {
      'finding': {'uz': 'a', 'ru': 'а', 'en': 'a'},
      'meaning': {'uz': 'a', 'ru': 'а', 'en': 'a'},
      'refs': [
        {'source_id': 'niddk-diagnosis', 'locator': 'A1C test'},
      ],
    },
  ],
  'review': {'state': 'pending'},
};

ContentPack withCondition(void Function(Map<String, Object?> c) patch) {
  final json = packJson();
  final c = minimalCondition();
  patch(c);
  json['conditions'] = [c];
  return ContentPack.fromJson(json);
}

void main() {
  final pack = ContentPack.fromJson(packJson());

  group('bundled guide', () {
    test('at least 30 conditions across systems, all sourced drafts', () {
      expect(pack.conditions.length, greaterThanOrEqualTo(30));
      expect(
        {for (final c in pack.conditions) c.system}.length,
        greaterThanOrEqualTo(10),
      );
      for (final c in pack.conditions) {
        expect(c.status, ContentStatus.draft, reason: c.id);
        expect(c.reviewState, ReviewState.pending, reason: c.id);
        expect(c.isReviewerApproved, isFalse, reason: c.id);
        expect(c.panelFor(PanelTier.firstLine), isNotEmpty, reason: c.id);
        expect(c.patterns, isNotEmpty, reason: c.id);
        expect(c.synonyms, isNotEmpty, reason: c.id);
        for (final r in [
          ...c.summary.refs,
          for (final t in c.panel) ...t.refs,
          for (final p in c.patterns) ...p.refs,
          for (final w in c.cautions) ...w.refs,
        ]) {
          expect(pack.source(r.sourceId), isNotNull, reason: c.id);
          expect(r.locator, isNotNull, reason: '${c.id} ${r.sourceId}');
        }
      }
    });

    test('every text is complete in uz/ru/en; Uzbek uses ‘ and ’', () {
      for (final c in pack.conditions) {
        final texts = [
          c.names,
          c.summary.text,
          for (final t in c.panel) ...[t.names, t.why],
          for (final p in c.patterns) ...[p.finding, p.meaning],
          for (final w in c.cautions) w.text,
        ];
        for (final t in texts) {
          for (final lang in ['uz', 'ru', 'en']) {
            expect(t.values[lang]?.trim(), isNotEmpty, reason: c.id);
          }
          expect(t.values['uz']!.contains("'"), isFalse, reason: c.id);
        }
      }
    });

    test('panel analyte ids are canonical or present in the pack', () {
      final allowed = {...canonicalIds(), for (final a in pack.analytes) a.id};
      for (final c in pack.conditions) {
        for (final id in c.analyteIds) {
          expect(allowed, contains(id), reason: '${c.id} → $id');
        }
      }
    });

    test('required conditions are present', () {
      for (final id in [
        'type-2-diabetes',
        'gestational-diabetes',
        'hypothyroidism',
        'hyperthyroidism',
        'chronic-kidney-disease',
        'urinary-tract-infection',
        'acute-pancreatitis',
        'hepatitis-b',
        'hepatitis-c',
        'fatty-liver-disease',
        'jaundice-cholestasis',
        'myocardial-infarction',
        'heart-failure',
        'dyslipidemia',
        'iron-deficiency-anemia',
        'b12-folate-deficiency',
        'bleeding-disorders',
        'venous-thromboembolism',
        'sepsis',
        'hiv',
        'syphilis',
        'rheumatoid-arthritis',
        'systemic-lupus',
        'gout',
        'osteoporosis',
        'hyperparathyroidism',
        'vitamin-d-deficiency',
        'pregnancy',
        'pcos',
        'infertility',
        'prostate-psa',
        'cushing-syndrome',
      ]) {
        expect(pack.condition(id), isNotNull, reason: id);
      }
    });
  });

  group('validator', () {
    test('accepts a minimal sourced condition', () {
      expect(withCondition((_) {}).conditions, hasLength(1));
    });

    test('rejects a pattern without source', () {
      expect(
        () => withCondition(
          (c) => ((c['patterns']! as List).first as Map)['refs'] = [],
        ),
        throwsFormatException,
      );
    });

    test('rejects a panel test without source or with unknown source', () {
      expect(
        () => withCondition(
          (c) => ((c['panel']! as List).first as Map)['refs'] = [],
        ),
        throwsFormatException,
      );
      expect(
        () => withCondition(
          (c) => ((c['panel']! as List).first as Map)['refs'] = [
            {'source_id': 'nope', 'locator': 'x'},
          ],
        ),
        throwsFormatException,
      );
    });

    test('rejects a ref without locator', () {
      expect(
        () => withCondition(
          (c) => (c['summary']! as Map)['refs'] = [
            {'source_id': 'niddk-diagnosis'},
          ],
        ),
        throwsFormatException,
      );
    });

    test('rejects a missing language', () {
      expect(
        () => withCondition(
          (c) => ((c['patterns']! as List).first as Map)['meaning'] = {
            'uz': 'a',
            'en': 'a',
          },
        ),
        throwsFormatException,
      );
    });

    test('rejects no first-line test and unreviewed published', () {
      expect(
        () => withCondition(
          (c) => ((c['panel']! as List).first as Map)['tier'] = 'monitoring',
        ),
        throwsFormatException,
      );
      expect(
        () => withCondition((c) => c['status'] = 'published'),
        throwsFormatException,
      );
    });
  });

  group('search', () {
    final search = ConditionSearch(pack);
    List<String> ids(String q, String lang) => [
      for (final c in search.search(q, lang: lang)) c.id,
    ];

    test('colloquial and multilingual names', () {
      expect(ids('qand', 'uz').first, 'type-2-diabetes');
      expect(ids('qand', 'uz'), contains('gestational-diabetes'));
      expect(ids('диабет', 'ru'), contains('type-2-diabetes'));
      expect(
        ids('anemia', 'en'),
        containsAll(['iron-deficiency-anemia', 'b12-folate-deficiency']),
      );
      expect(
        ids('щитовид', 'ru').take(2),
        containsAll(['hypothyroidism', 'hyperthyroidism']),
      );
      expect(ids('kamqonlik', 'uz'), contains('iron-deficiency-anemia'));
      // Kirill yozuvidagi o'zbekcha so'rov.
      expect(ids('қанд', 'uz'), contains('type-2-diabetes'));
    });

    test('test names find conditions, but below name matches', () {
      final tsh = ids('TSH', 'en');
      expect(
        tsh,
        containsAll(['hypothyroidism', 'hyperthyroidism', 'infertility']),
      );
      expect(ids('psa', 'en').first, 'prostate-psa');
    });

    test('system filter and empty query', () {
      expect(search.search('', lang: 'uz'), hasLength(pack.conditions.length));
      final liver = search.search(
        '',
        system: ConditionSystem.liver,
        lang: 'uz',
      );
      expect(liver, isNotEmpty);
      expect(liver.every((c) => c.system == ConditionSystem.liver), isTrue);
      expect(ids('zzzqqq', 'uz'), isEmpty);
    });
  });

  group('reverse index and helpers', () {
    test('analyte → conditions', () {
      final hba1c = [for (final c in pack.conditionsForAnalyte('hba1c')) c.id];
      expect(hba1c, containsAll(['type-2-diabetes', 'pcos']));
      final tsh = [for (final c in pack.conditionsForAnalyte('tsh')) c.id];
      expect(tsh, containsAll(['hypothyroidism', 'hyperthyroidism']));
      expect(pack.conditionsForAnalyte('no-such-analyte'), isEmpty);
    });

    test('source numbering follows first citation, without duplicates', () {
      final c = pack.condition('type-2-diabetes')!;
      expect(c.sourceIds.toSet().length, c.sourceIds.length);
      expect(c.sourceIds.first, c.summary.refs.first.sourceId);
    });

    test('tab base and referral text', () {
      expect(tabBase('/tests/conditions/x/analyte/hba1c'), '/tests');
      expect(tabBase('/library/saved/analyte/hba1c'), '/library/saved');
      expect(tabBase('/home'), '/home');
      final l = AppLocalizationsUz();
      final text = referralText(pack.condition('type-2-diabetes')!, 'uz', l);
      expect(text, startsWith('2-tip qandli diabet'));
      expect(text, contains(l.condTierFirstLine));
      expect(text, contains('• HbA1c'));
      expect(text, endsWith(l.condReferralFooter));
    });
  });
}
