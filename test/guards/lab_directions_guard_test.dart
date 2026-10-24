// TB/OIV yo'nalish kartalari qorovuli: har karta rasmiy manbali (URL + sana),
// uch tilli maydonlar bo'sh emas, uchinchi tomon rasmi yo'q, platforma va
// test alohida id, hammasi NEEDS_REVIEW.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';

Map<String, Object?> _raw() => (jsonDecode(
  File('assets/instruments/catalog.json').readAsStringSync(),
) as Map).cast<String, Object?>();

void main() {
  final raw = _raw();
  final catalog = InstrumentCatalog.fromJson(raw);
  final officialHosts = RegExp(
    r'^https://([a-z0-9-]+\.)*(who\.int|cdc\.gov|nih\.gov|hiv\.gov|ncbi\.nlm\.nih\.gov)/',
  );

  test('kartalar bor; eski 26 model o‘zgarmagan', () {
    expect(catalog.labCards, isNotEmpty);
    expect(catalog.models.length, 26);
  });

  test('har kartada kamida bitta rasmiy manba URL va kirish sanasi', () {
    for (final c in catalog.labCards) {
      expect(c.sourceIds, isNotEmpty, reason: c.id);
      for (final id in c.allSourceIds) {
        final s = catalog.sources[id]!;
        expect(officialHosts.hasMatch(s.url), isTrue, reason: '${c.id} $id');
        expect(DateTime.tryParse(s.accessed), isNotNull, reason: id);
        expect(s.docRef, isNotNull, reason: '$id: versiya/sana qaydi yo‘q');
      }
    }
  });

  test('majburiy uz/ru/en maydonlar bo‘sh emas', () {
    for (final c in raw['lab_cards']! as List) {
      void check(Object? v, String where) {
        if (v is Map && v.containsKey('uz')) {
          for (final l in ['uz', 'ru', 'en']) {
            expect(
              ((v[l] ?? '') as String).trim(),
              isNotEmpty,
              reason: '$where $l',
            );
          }
        } else if (v is Map) {
          v.forEach((k, x) => check(x, '$where.$k'));
        } else if (v is List) {
          for (final x in v) {
            check(x, where);
          }
        }
      }

      check(c, (c as Map)['id']! as String);
    }
  });

  test('rasm maydoni yo‘q (uchinchi tomon fotosi bo‘lishi mumkin emas)', () {
    for (final c in raw['lab_cards']! as List) {
      final m = c as Map;
      expect(m.keys.where((k) => (k as String).contains('image')), isEmpty);
      expect(m.keys.where((k) => (k as String).contains('photo')), isEmpty);
      expect(jsonEncode(m).contains('.png'), isFalse, reason: '${m['id']}');
      expect(jsonEncode(m).contains('.jpg'), isFalse, reason: '${m['id']}');
    }
  });

  test('platforma va test — alohida id, o‘zaro bog‘langan', () {
    final platforms = catalog.labCards
        .where((c) => c.kind == LabCardKind.platform)
        .toList();
    expect(platforms, isNotEmpty);
    for (final p in platforms) {
      expect(p.linked, isNotEmpty);
      for (final id in p.linked) {
        final t = catalog.labCard(id)!;
        expect(t.id, isNot(p.id));
        expect(t.kind, isNot(LabCardKind.platform));
        expect(t.linked, contains(p.id), reason: 'ikki tomonlama havola');
      }
    }
    for (final c in catalog.labCards) {
      expect(c.instrumentVsTestNote, isNotNull, reason: c.id);
    }
  });

  test(
    'hammasi NEEDS_REVIEW, mutaxassis tekshirmagan; model nomi to‘qilmagan',
    () {
      for (final c in raw['lab_cards']! as List) {
        final m = c as Map;
        expect(m['audit_status'], 'NEEDS_REVIEW');
        expect(m['expert_reviewed'], false);
      }
      // Model nomlari rasmiy manbada tasdiqlanmaguncha bo'sh.
      for (final c in catalog.labCards) {
        expect(c.models, isEmpty, reason: c.id);
      }
    },
  );

  test('tashxis avtomatlashtirilmaydi: karta matnida buyruq/dozalash yo‘q', () {
    final text = jsonEncode(raw['lab_cards']).toLowerCase();
    for (final w in ['you have ', 'diagnosis is ', 'prescribe']) {
      expect(text.contains(w), isFalse, reason: w);
    }
  });
}
