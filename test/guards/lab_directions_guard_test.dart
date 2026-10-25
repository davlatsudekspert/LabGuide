// TB/OIV yo'nalish kartalari qorovuli: har karta rasmiy manbali (URL + sana),
// uch tilli maydonlar bo'sh emas, uchinchi tomon rasmi yo'q (faqat o'z sinf
// chizmasi kaliti — lab_card_schematic_guard_test.dart), platforma va
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
    r'^https://([a-z0-9-]+\.)*(who\.int|cdc\.gov|nih\.gov|hiv\.gov|ncbi\.nlm\.nih\.gov|fda\.gov|eucast\.org|ecdc\.europa\.eu|europa\.eu|nist\.gov|unodc\.org)/',
  );
  // Jurnal manbalari: DOI yoki rasmiy/PubMed xostlari.
  final journalHosts = RegExp(r'^https://(doi\.org|dx\.doi\.org)/');

  test('kartalar bor; eski 26 model o‘zgarmagan', () {
    expect(catalog.publicLabCards, isNotEmpty);
    expect(catalog.models.length, 26);
  });

  test('har kartada kamida bitta rasmiy manba URL va kirish sanasi', () {
    for (final c in catalog.publicLabCards) {
      expect(c.sourceIds, isNotEmpty, reason: c.id);
      // Marketing manba yolg‘iz o‘zi kartani asoslamaydi.
      expect(
        c.allSourceIds.any((i) => catalog.sources[i]!.type!.isAuthoritative),
        isTrue,
        reason: '${c.id}: rasmiy/jurnal manba yo‘q',
      );
      for (final id in c.allSourceIds) {
        final s = catalog.sources[id]!;
        expect(s.type, isNotNull, reason: '${c.id} $id: manba turi yo‘q');
        switch (s.type!) {
          case SourceType.officialAgency:
            expect(officialHosts.hasMatch(s.url), isTrue, reason: id);
          case SourceType.journal:
            expect(
              officialHosts.hasMatch(s.url) || journalHosts.hasMatch(s.url),
              isTrue,
              reason: id,
            );
          case SourceType.manufacturerIfu:
          case SourceType.manufacturerMarketing:
            break; // ishlab chiqaruvchi xosti faqat shu turlarda ruxsat.
        }
        expect(DateTime.tryParse(s.accessed), isNotNull, reason: id);
        expect(s.docRef, isNotNull, reason: '$id: versiya/sana qaydi yo‘q');
      }
    }
  });

  test('majburiy uz/ru/en maydonlar bo‘sh emas', () {
    for (final c in (raw['lab_cards']! as List).where(
      (x) => (x as Map)['audit_status'] != 'NEEDS_SOURCE',
    )) {
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

  test(
    'foto maydoni yo‘q: faqat o‘z sinf chizmasi kaliti (uchinchi tomon fotosi '
    'bo‘lishi mumkin emas)',
    () {
      final known = {for (final s in LabSchematic.values) s.key};
      for (final c in raw['lab_cards']! as List) {
        final m = c as Map;
        expect(m.keys.where((k) => (k as String).contains('image')), isEmpty);
        expect(m.keys.where((k) => (k as String).contains('photo')), isEmpty);
        // Fayl yo‘li emas, ro‘yxatdagi kalit (LabSchematic) — PNG yo‘li kodda.
        expect(jsonEncode(m).contains('.png'), isFalse, reason: '${m['id']}');
        expect(jsonEncode(m).contains('.jpg'), isFalse, reason: '${m['id']}');
        if (m['schematic'] case final String key) {
          expect(known, contains(key), reason: '${m['id']}');
          expect(
            m['audit_status'],
            isNot('NEEDS_SOURCE'),
            reason: '${m['id']}',
          );
        }
      }
    },
  );

  test('platforma va test — alohida id; havolalar ikki tomonlama', () {
    final platforms = catalog.publicLabCards
        .where((c) => c.kind == LabCardKind.platform)
        .toList();
    expect(platforms, isNotEmpty);
    // Hech bo‘lmaganda bitta platforma-test juftligi bor (TB asosiy misol).
    expect(platforms.where((p) => p.linked.isNotEmpty), isNotEmpty);
    for (final p in platforms) {
      for (final id in p.linked) {
        final t = catalog.labCard(id)!;
        expect(t.id, isNot(p.id));
        expect(t.kind, isNot(LabCardKind.platform));
        expect(t.linked, contains(p.id), reason: 'ikki tomonlama havola');
      }
    }
    for (final c in catalog.publicLabCards) {
      expect(c.instrumentVsTestNote, isNotNull, reason: c.id);
    }
  });

  test(
    'hammasi NEEDS_REVIEW, mutaxassis tekshirmagan; model nomi to‘qilmagan',
    () {
      for (final c in raw['lab_cards']! as List) {
        final m = c as Map;
        expect(['NEEDS_REVIEW', 'NEEDS_SOURCE'], contains(m['audit_status']));
        expect(m['expert_reviewed'] ?? false, false);
      }
      // Model nomlari rasmiy manbada tasdiqlanmaguncha bo'sh.
      for (final c in catalog.publicLabCards) {
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
