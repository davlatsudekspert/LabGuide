// Ma'lumotnoma kartalari to'plami (2026-10-24 integratsiya): HAQIQIY fromJson
// parseri orqali barcha kartalar, har bir kartaning invariantlari, stublarning
// yashirinligi, dedup natijasi, litsenziya hujjati va hajm “tormozi”.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';

Map<String, Object?> _raw() => (jsonDecode(
  File('assets/instruments/catalog.json').readAsStringSync(),
) as Map).cast<String, Object?>();

/// Ingliz tilidagi gaplar soni (qisqartmalar e.g./i.e./vs. hisobga olinmaydi).
int _sentences(String s) {
  final t = s.replaceAllMapped(
    RegExp(r'\b(e\.g|i\.e|vs|approx|ca|spp|sp|et al|cf)\.'),
    (m) => m[0]!.replaceAll('.', '§'),
  );
  return RegExp(r'(?<=[.!?])\s+(?=[A-Z"(])').allMatches(t).length + 1;
}

/// Matnli maydonlar: (yo'l, {uz,ru,en}) — manbali ham, ilovaning o'z izohi ham.
Iterable<(String, Map<String, dynamic>, bool)> _texts(
  Map<String, dynamic> c,
) sync* {
  final id = c['id'] as String;
  for (final k in [
    'technology',
    'principle',
    'qc_calibration_note',
    'biosafety',
  ]) {
    if (c[k] != null) {
      yield (
        '$id.$k',
        (c[k] as Map<String, dynamic>)['text'] as Map<String, dynamic>,
        true,
      );
    }
  }
  for (final k in [
    'specimens',
    'tasks',
    'limitations',
    'preanalytic_analytic_errors',
  ]) {
    for (final (i, t) in ((c[k] as List?) ?? const []).indexed) {
      yield (
        '$id.$k[$i]',
        (t as Map<String, dynamic>)['text'] as Map<String, dynamic>,
        true,
      );
    }
  }
  for (final k in ['name', 'instrument_vs_test_note', 'source_caveat']) {
    if (c[k] != null) {
      yield ('$id.$k', (c[k] as Map<String, dynamic>), false);
    }
  }
}

/// Karta ekranida ko'rinadigan stublar (ro'yxat ichida qat'iy belgilangan).
const _expectedStubs = {
  'a1-na-extraction-method',
  'a1-mindray-ba-88a-platform',
  'a2-platform-centrifuge',
  'a2-platform-microbiology-incubator',
  'a3-hiv-genotyping-stub',
  'a3-light-microscope-stub',
  'a3-tb-lamp-platform-stub',
  'a3-truenat-platform-stub',
  'a3-hiv-poc-cd4-device-stub',
  'a3-cytocentrifuge-lbc-stub',
  'a3-hla-luminex-stub',
  'a3-ihc-autostainer-stub',
  'a3-lis-lims-stub',
  'a3-microtome-processor-stub',
  'a3-nephelometer-stub',
  'a3-ngs-sequencer-stub',
  'a3-prenatal-screening-stub',
  'a3-uv-vis-stub',
  'a3-water-purification-stub',
};

/// Dedup'da tashlab yuborilgan id'lar: hech bir joyda qolmasligi shart.
const _droppedIds = [
  'a1-genexpert-platform',
  'a1-xpert-mtb-rif-test',
  'a1-ast-method',
  'a1-maldi-tof-platform',
  'a1-vitek2-platform',
  'a1-mgit-960-platform',
  'a1-realtime-pcr-platform',
  'a1-hiv-viral-load-test',
  'a1-hiv-viral-load-platform',
  'a3-mindray-ba88a-stub',
  'a3-hiv-vl-pcr-test',
];

/// Manbasi eskirgan/tor kartalar: ko'rinadigan caveat shart (qoida 7).
const _caveatCards = {
  'a3-bac-vitek2-platform',
  'a3-bac-ast-method',
  'a3-tb-bactec-mgit960-platform',
  'tb-genexpert-platform',
  'a1-elisa-reader-platform',
  'a3-mol-realtime-pcr-platform',
  'a2-test-hba1c',
  'a2-platform-hba1c-analyzer',
  'a3-hiv-cd4-flow-method',
  'a2-test-arterial-blood-gas-panel',
  'a2-platform-blood-gas-ise-analyzer',
};

void main() {
  final raw = _raw();
  final rawCards = (raw['lab_cards']! as List).cast<Map<String, dynamic>>();
  // HAQIQIY parser: bitta ham karta o‘tkazib yuborilmaydi.
  final catalog = InstrumentCatalog.fromJson(raw);

  test('barcha kartalar fromJson’dan o‘tadi; id va manba id’lari noyob', () {
    expect(catalog.labCards.length, rawCards.length);
    expect({for (final c in rawCards) c['id']}.length, rawCards.length);
    final srcIds = [for (final s in raw['sources']! as List) (s as Map)['id']];
    expect(srcIds.toSet().length, srcIds.length);
    expect(catalog.models.length, 26);
  });

  test('har bir ommaviy karta: invariantlar', () {
    for (final c in rawCards.where(
      (x) => x['audit_status'] != 'NEEDS_SOURCE',
    )) {
      final id = c['id'] as String;
      expect(c['expert_reviewed'], false, reason: id);
      expect(c['audit_status'], 'NEEDS_REVIEW', reason: id);
      expect(
        c['models'] ?? const [],
        isEmpty,
        reason: '$id: model to‘qilmaydi',
      );
      for (final (path, t, sourced) in _texts(c)) {
        for (final l in ['uz', 'ru', 'en']) {
          expect(
            ((t[l] ?? '') as String).trim(),
            isNotEmpty,
            reason: '$path $l',
          );
        }
        expect(
          _sentences(t['en'] as String),
          lessThanOrEqualTo(2),
          reason: '$path: ingliz tilida 2 gapdan ko‘p',
        );
        // manbali ibora (parafraz) <-> manbasiz izoh (ilovaning o‘zi) alohida.
        final m = c[path.split('.').last.replaceAll(RegExp(r'\[\d+\]'), '')];
        if (!sourced) {
          expect(m is Map && m.containsKey('sources'), isFalse, reason: path);
        }
      }
      final card = catalog.labCards.firstWhere((x) => x.id == id);
      expect(card.sourceIds, isNotEmpty, reason: id);
      for (final s in card.allSourceIds) {
        expect(catalog.sources.containsKey(s), isTrue, reason: '$id: $s');
      }
      // Matn maydonlarining manbalari kartaning umumiy ro‘yxatida.
      expect(
        card.sourceIds.toSet().containsAll(card.allSourceIds),
        isTrue,
        reason: '$id: umumiy manbalar ro‘yxati to‘liq emas',
      );
      // Kamida bitta rasmiy/jurnal manba; faqat marketing — taqiqlangan.
      expect(
        card.allSourceIds.any((s) => catalog.sources[s]!.type!.isAuthoritative),
        isTrue,
        reason: id,
      );
      expect(
        card.allSourceIds.every(
          (s) => catalog.sources[s]!.type != SourceType.manufacturerMarketing,
        ),
        isTrue,
        reason: '$id: marketing manbasi ishlatilmagan bo‘lishi kerak',
      );
      expect(card.instrumentVsTestNote, isNotNull, reason: id);
    }
  });

  test('har bir manba: https, tur, sana, hujjat qaydi, nashriyotchi', () {
    final used = {for (final c in catalog.labCards) ...c.allSourceIds};
    for (final id in used) {
      final s = catalog.sources[id]!;
      expect(s.url.startsWith('https://'), isTrue, reason: id);
      expect(s.type, isNotNull, reason: id);
      expect(DateTime.tryParse(s.accessed), isNotNull, reason: id);
      expect(s.docRef, isNotNull, reason: id);
    }
  });

  test(
    'platforma/test/usul turlari izchil; havolalar mavjud va ikki tomonlama',
    () {
      final byId = {for (final c in catalog.labCards) c.id: c};
      for (final c in catalog.publicLabCards) {
        for (final l in c.linked) {
          final o = byId[l];
          expect(o, isNotNull, reason: '${c.id} -> $l (osilib qolgan havola)');
          expect(o!.isPublic, isTrue, reason: '${c.id} stubga bog‘langan: $l');
          expect(o.linked, contains(c.id), reason: '$l -> ${c.id} yo‘q');
          if (c.kind == LabCardKind.platform) {
            expect(
              o.kind,
              isNot(LabCardKind.platform),
              reason: '${c.id} -> $l',
            );
          }
        }
      }
      // Platforma va test aloqasi bo‘lgan asosiy juftliklar.
      for (final pair in [
        ['hiv-rna-viral-load', 'a3-mol-realtime-pcr-platform'],
        ['a1-realtime-pcr-method', 'a3-mol-realtime-pcr-platform'],
        ['a3-bac-ast-method', 'a3-bac-vitek2-platform'],
        ['a3-tb-mgit-culture-dst-method', 'a3-tb-bactec-mgit960-platform'],
      ]) {
        expect(byId[pair[0]]!.linked, contains(pair[1]));
        expect(byId[pair[1]]!.linked, contains(pair[0]));
      }
      expect(byId['a3-mol-realtime-pcr-platform']!.kind, LabCardKind.platform);
      expect(byId['hiv-rna-viral-load']!.kind, LabCardKind.test);
    },
  );

  test(
    'OIV virus yuki: eski id saqlangan, ommaviy, PZR platformasi alohida',
    () {
      final vl = catalog.labCard('hiv-rna-viral-load')!;
      expect(vl.direction, LabDirection.hiv);
      expect(vl.linked, ['a3-mol-realtime-pcr-platform']);
      expect(vl.expertReviewed, isFalse);
      // O‘chirilgan, dalilsiz ibora (sifatli NAT) qayta tiklanmagan.
      final txt = jsonEncode(
        rawCards.firstWhere((c) => c['id'] == 'hiv-rna-viral-load'),
      ).toLowerCase();
      expect(txt.contains('earliest'), isFalse);
      expect(txt.contains('nonreactive'), isFalse);
    },
  );

  test('dedup: tashlangan id’lar hech qayerda yo‘q (karta, havola, matn)', () {
    final all = jsonEncode(raw['lab_cards']);
    for (final d in _droppedIds) {
      expect(all.contains('"$d"'), isFalse, reason: d);
    }
  });

  test('caveat: eskirgan/tor manbali kartalarda uch tilli ogohlantirish', () {
    for (final id in _caveatCards) {
      final c = catalog.labCard(id)!;
      expect(c.sourceCaveat, isNotNull, reason: id);
      for (final l in ['uz', 'ru', 'en']) {
        expect(c.sourceCaveat!.of(l).trim(), isNotEmpty, reason: '$id $l');
      }
      expect(c.expertReviewed, isFalse, reason: id);
    }
  });

  test(
    'NEEDS_SOURCE stublar: aniq to‘plam, kontentsiz, hech qayerda ko‘rinmaydi',
    () {
      final stubs = catalog.labCards.where((c) => !c.isPublic).toList();
      expect({for (final s in stubs) s.id}, _expectedStubs);
      for (final s in stubs) {
        // Texnik parametr yo‘q: parser faqat id/yo‘nalish/tur/nom/sabab/ustuvorlik.
        final m = rawCards.firstWhere((c) => c['id'] == s.id);
        expect(
          m.keys.toSet().difference({
            'id',
            'lab_direction',
            'card_kind',
            'name',
            'audit_status',
            'needs_source_reason',
            'priority',
            'expert_reviewed',
          }),
          isEmpty,
          reason: s.id,
        );
        expect(s.sourceIds, isEmpty);
        // Nomda texnik parametr/raqam yo‘q (faqat tushuncha nomi; BA-88A — model nomi).
        expect(
          RegExp(r'[0-9]\s*(%|ml|mL|nm|°|rpm|kDa|min|h\b|mm|µ|g\b)')
              .hasMatch(s.name.of('en')),
          isFalse,
          reason: s.id,
        );
        expect(s.technology, isNull);
        expect(s.tasks, isEmpty);
        expect(s.models, isEmpty);
        expect(s.expertReviewed, isFalse);
        // Ro‘yxatlar:
        expect(catalog.labCard(s.id), isNull, reason: s.id);
        expect(catalog.publicLabCards.map((c) => c.id), isNot(contains(s.id)));
        for (final d in LabDirection.values) {
          expect(catalog.labCardsIn(d).map((c) => c.id), isNot(contains(s.id)));
        }
        // Sanoq: yo‘nalish faqat ommaviy kartasi bo‘lsa ro‘yxatda.
        for (final d in catalog.publicLabDirections) {
          expect(catalog.labCardsIn(d), isNotEmpty);
        }
        // Havola: ommaviy kartalar stubga bog‘lanmagan.
        for (final c in catalog.publicLabCards) {
          expect(c.linked, isNot(contains(s.id)));
        }
        // Qidiruv: apparat qidiruvi stub nomini hech qachon qaytarmaydi.
        for (final r in catalog.search(s.name.of('en'))) {
          expect(r.id, isNot(s.id));
        }
      }
      expect(
        catalog.publicLabCards.length + stubs.length,
        catalog.labCards.length,
      );
    },
  );

  test(
    'so‘zma-so‘z nusxa tormozi: hech bir bayonot 300 belgidan uzun emas',
    () {
      for (final c in rawCards.where(
        (x) => x['audit_status'] != 'NEEDS_SOURCE',
      )) {
        for (final (path, t, _) in _texts(c)) {
          for (final l in ['uz', 'ru', 'en']) {
            expect(
              (t[l] as String).length,
              lessThanOrEqualTo(300),
              reason: '$path $l',
            );
          }
        }
      }
    },
  );

  test(
    'litsenziya hujjati har bir manbani qamrab oladi; NC/ND ogohlantirishi bor',
    () {
      final doc = File('docs/LAB_CARDS_SOURCE_LICENSES.md').readAsStringSync();
      final used = {for (final c in catalog.labCards) ...c.allSourceIds};
      for (final id in used) {
        expect(
          doc.contains('`$id`'),
          isTrue,
          reason: 'litsenziya qatori yo‘q: $id',
        );
      }
      expect(doc.contains('NC'), isTrue);
      expect(doc.toLowerCase().contains('verbatim'), isTrue);
      expect(doc.toLowerCase().contains('pro'), isTrue);
    },
  );

  test('holat JSON’i katalogga mos', () {
    final st = (jsonDecode(
      File('docs/lab_cards_status.json').readAsStringSync(),
    ) as Map).cast<String, dynamic>();
    final cards = (st['cards'] as List).cast<Map<String, dynamic>>();
    expect(cards.length, catalog.labCards.length);
    for (final c in cards) {
      final card = catalog.labCards.firstWhere((x) => x.id == c['id']);
      expect(
        c['status'],
        card.isPublic ? 'NEEDS_REVIEW' : 'NEEDS_SOURCE_HIDDEN',
      );
      expect(c['direction'], card.direction.name);
      expect(c['kind'], card.kind.name);
    }
    expect(st['public_cards'], catalog.publicLabCards.length);
    expect(st['hidden_stubs'], _expectedStubs.length);
  });
}
