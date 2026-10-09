import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/instruments_controller.dart';

Map<String, Object?> _raw() => (jsonDecode(
  File('assets/instruments/catalog.json').readAsStringSync(),
) as Map).cast<String, Object?>();

Set<String> _analyteIds() {
  final pack = jsonDecode(
    File('assets/content/core/pack.json').readAsStringSync(),
  ) as Map;
  return {for (final a in pack['analytes'] as List) (a as Map)['id'] as String};
}

void main() {
  late InstrumentCatalog catalog;

  setUpAll(() {
    catalog = InstrumentCatalog.fromJson(_raw(), knownAnalytes: _analyteIds());
  });

  group('katalog fayli', () {
    test(
      'Phase 1: Mindray, HUMAN, Roche, Abbott — har yo‘nalishda model bor',
      () {
        final phase1 = {
          for (final m in catalog.makers)
            if (m.phase == 1) m.id,
        };
        expect(phase1, {'mindray', 'human', 'roche', 'abbott'});
        for (final c in InstrumentCategory.values) {
          expect(catalog.inCategory(c), isNotEmpty, reason: c.name);
        }
        expect(catalog.models.length, greaterThanOrEqualTo(20));
        // Keyingi bosqich ishlab chiqaruvchilarida hali model yo'q.
        for (final m in catalog.plannedMakers) {
          expect(catalog.models.where((x) => x.makerId == m.id), isEmpty);
        }
      },
    );

    test('har karta manbali; holat dalilsiz ko‘tarilmagan', () {
      for (final m in catalog.models) {
        expect(m.sourceIds, isNotEmpty, reason: m.id);
        expect(m.status, InstrumentStatus.deviceInfo, reason: m.id);
        for (final id in m.sourceIds) {
          final s = catalog.sources[id]!;
          expect(s.url, startsWith('https://'));
          expect(s.accessed, '2026-10-09');
        }
        expect(m.purpose != null || m.principle != null, isTrue, reason: m.id);
      }
    });

    test('kundalik parvarish bosqichlari to‘qilmagan (faqat iqtibos)', () {
      final raw = _raw();
      for (final m in raw['models']! as List) {
        final map = m as Map;
        expect(map.containsKey('maintenance_steps'), isFalse);
        for (final q in map['maintenance'] as List) {
          expect((q as Map)['source'], isNotNull);
        }
      }
    });

    test('rasm faqat litsenziyali va fayli mavjud', () {
      final withImage = catalog.models.where((m) => m.image != null).toList();
      expect(withImage, isNotEmpty);
      for (final m in withImage) {
        final img = m.image!;
        expect(File(img.asset).existsSync(), isTrue, reason: img.asset);
        expect(img.license, 'CC BY-SA 4.0');
        expect(img.author, isNotEmpty);
        expect(img.sourcePage, startsWith('https://commons.wikimedia.org/'));
      }
    });

    test(
      'HumaLyzer 4000: reagent REF ro‘yxati flayerdan, analitlar mavjud',
      () {
        final hl = catalog.model('human-humalyzer-4000')!;
        expect(hl.reagentSystem, ReagentSystemKind.open);
        final glucose = hl.reagentsFor('glucose-plasma-fasting');
        expect(
          glucose.expand((r) => r.refs),
          containsAll(['10121', '10260', '10786']),
        );
        expect(
          catalog.sources[glucose.first.sourceId]!.docRef,
          '981015/2021-11',
        );
      },
    );
  });

  group('validator', () {
    Map<String, Object?> mutate(void Function(Map<String, Object?> m) f) {
      final raw = _raw();
      final first = ((raw['models']! as List).first as Map)
          .cast<String, Object?>();
      f(first);
      (raw['models']! as List)[0] = first;
      return raw;
    }

    test('“Yo‘riqnoma mavjud” holati dalilsiz rad etiladi', () {
      expect(
        () => InstrumentCatalog.fromJson(
          mutate((m) => m['status'] = 'ifu_available'),
        ),
        throwsFormatException,
      );
    });

    test('noma’lum manba rad etiladi', () {
      expect(
        () => InstrumentCatalog.fromJson(
          mutate(
            (m) => (m['facts']! as List).add({
              'label': {'uz': 'a', 'ru': 'a', 'en': 'a'},
              'value': '1',
              'source': 'nowhere',
            }),
          ),
        ),
        throwsFormatException,
      );
    });

    test('NC litsenziyali rasm rad etiladi', () {
      expect(
        () => InstrumentCatalog.fromJson(
          mutate(
            (m) => m['image'] = {
              'asset': 'x.jpg',
              'license': 'CC BY-NC 4.0',
              'license_url': 'https://creativecommons.org/licenses/by-nc/4.0/',
              'author': 'a',
              'source_page': 'https://example.org',
              'caption': {'uz': 'a', 'ru': 'a', 'en': 'a'},
            },
          ),
        ),
        throwsFormatException,
      );
    });

    test('iqtibossiz tushuntirish rad etiladi', () {
      expect(
        () => InstrumentCatalog.fromJson(
          mutate(
            (m) => m['purpose'] = {
              'text': {'uz': 'a', 'ru': 'a', 'en': 'a'},
              'quotes': <Object>[],
            },
          ),
        ),
        throwsFormatException,
      );
    });
  });

  group('qidiruv (uz/ru/en)', () {
    List<String> ids(String q) => [for (final m in catalog.search(q)) m.id];

    test('model nomi chiziqcha va bo‘shliqsiz ham topiladi', () {
      expect(ids('bs240').first, 'mindray-bs-240');
      expect(ids('BS 240').first, 'mindray-bs-240');
      expect(ids('cobas c 311').first, 'roche-cobas-c-311');
      expect(ids('c311').first, 'roche-cobas-c-311');
      expect(ids('REF 18250').single, 'human-humalyzer-4000');
    });

    test('yo‘nalish nomi uch tilda', () {
      for (final q in ['gematologiya', 'гематолог', 'hematology']) {
        final r = catalog.search(q);
        expect(r, isNotEmpty, reason: q);
        expect(
          r.every((m) => m.category == InstrumentCategory.hematology),
          isTrue,
          reason: q,
        );
      }
      for (final q in ['siydik', 'моча', 'urine']) {
        expect(
          catalog
              .search(q)
              .every((m) => m.category == InstrumentCategory.urinalysis),
          isTrue,
          reason: q,
        );
      }
      expect(catalog.search('биохим'), isNotEmpty);
    });

    test('bir nechta so‘z: ishlab chiqaruvchi + yo‘nalish', () {
      final r = catalog.search('mindray gematologiya');
      expect(r, isNotEmpty);
      expect(r.every((m) => m.makerId == 'mindray'), isTrue);
      expect(
        r.every((m) => m.category == InstrumentCategory.hematology),
        isTrue,
      );
    });

    test('bo‘sh va topilmaydigan so‘rov', () {
      expect(catalog.search('   '), isEmpty);
      expect(catalog.search('zzzz-nothing'), isEmpty);
    });
  });

  group('InstrumentsController', () {
    test('apparat, reagent tanlovi va kalibrlash yozuvi qayta ochilganda saqlanadi', () async {
      final store = MemoryKeyValueStore();
      final a = InstrumentsController(store, bundle: rootBundle);
      final m = await a.addFromCatalog(
        'human-humalyzer-4000',
        label: ' 1-xona ',
        manualVersion: 'v2.1',
      );
      expect(m.label, '1-xona');
      const reagent = ReagentChoice(
        maker: 'HUMAN',
        ref: '10121',
        ifuVersion: '2024-01',
      );
      await a.addRecord(
        instrument: m,
        instrumentName: 'HUMAN HumaLyzer 4000 · 1-xona',
        analyteId: 'glucose-plasma-fasting',
        reagent: reagent,
        calibratorLot: ' L-77 ',
        levels: const [CalibratorLevel(name: '1', value: 5.55, unit: 'mmol/L')],
        performedOn: DateTime(2026, 10, 9),
        outcome: CalibrationOutcome.accepted,
      );

      final b = InstrumentsController(store, bundle: rootBundle);
      expect(b.mine.single.reagents['glucose-plasma-fasting']!.ref, '10121');
      final r = b.records.single;
      expect(r.calibratorLot, 'L-77');
      expect(r.levels.single.value, 5.55);
      expect(r.manualVersion, 'v2.1');
      expect(b.storeError, isNull);
    });

    test('lot yoki darajasiz yozuv yaratilmaydi', () async {
      final c = InstrumentsController(
        MemoryKeyValueStore(),
        bundle: rootBundle,
      );
      final m = await c.addCustom(
        maker: 'Dirui',
        model: 'CS-T240',
        category: InstrumentCategory.chemistry,
      );
      expect(
        () => c.addRecord(
          instrument: m,
          instrumentName: 'x',
          analyteId: 'urea',
          reagent: const ReagentChoice(
            maker: 'Dirui',
            ref: 'R',
            ifuVersion: '1',
          ),
          calibratorLot: ' ',
          levels: const [CalibratorLevel(name: '1', value: 1, unit: 'mmol/L')],
          performedOn: DateTime(2026),
          outcome: CalibrationOutcome.pending,
        ),
        throwsArgumentError,
      );
      expect(c.records, isEmpty);
    });

    test('buzilgan saqlangan ma’lumot ustiga yozilmaydi', () async {
      final store = MemoryKeyValueStore();
      await store.setString(StoreKeys.myInstruments, '{not json');
      final c = InstrumentsController(store, bundle: rootBundle);
      expect(c.storeError, isNotNull);
      await expectLater(c.addFromCatalog('mindray-bs-240'), throwsStateError);
      expect(store.getString(StoreKeys.myInstruments), '{not json');
    });
  });
}
