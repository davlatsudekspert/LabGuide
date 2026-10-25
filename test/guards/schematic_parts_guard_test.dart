// Sxema qismlari qorovuli (egasi talabi 2026-10-25): ilovadagi har bir
// sxematik chizma (7 model turi + 25 yo‘nalish kartasi sinfi) uchun
// assets/instruments/schematic_parts.json da yozuv bor, kamida bitta qism,
// rasmdagi raqamli belgilar soni qismlar soniga teng (1..n), har bir matn
// id uz/ru/en ARB da bor va bo‘sh emas, manbalar hujjatida har qism
// qatori bor. Noma’lum kalit yoki buzilgan tuzilma yuklashda rad etiladi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';
import 'package:labguide/features/instruments/schematic_parts.dart';
import 'package:labguide/features/instruments/schematic_parts_l10n.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/schematic_svg.dart';

Map<String, Object?> _raw() =>
    (jsonDecode(File(SchematicPartsIndex.asset).readAsStringSync()) as Map)
        .cast<String, Object?>();

void main() {
  final index = SchematicPartsIndex.fromJson(_raw());
  final allKeys = {
    for (final s in InstrumentSchematic.values) s.key,
    for (final s in LabSchematic.values) s.key,
  };

  test('32 ta chizma kaliti — har biri uchun qismlar yozuvi', () {
    expect(allKeys, hasLength(32));
    expect(index.keys.toSet(), allKeys);
    for (final k in allKeys) {
      final e = index.of(k)!;
      expect(e.parts, isNotEmpty, reason: k);
      expect(
        [for (final p in e.parts) p.n],
        [for (var i = 1; i <= e.parts.length; i++) i],
        reason: k,
      );
    }
  });

  test(
    'SVG: belgilar soni = qismlar soni, raqamlar 1..n, boshqa matn yo‘q',
    () {
      for (final k in allKeys) {
        final svg = File('tool/illustrations/schematic/$k.svg')
            .readAsStringSync();
        final n = index.of(k)!.parts.length;
        expect(calloutNumbers(svg), [
          for (var i = 1; i <= n; i++) i,
        ], reason: k);
        expect(
          '<g class="callout"'.allMatches(svg).length,
          n,
          reason: '$k: belgilar guruhi',
        );
      }
    },
  );

  test('har bir matn id uz/ru/en da bor va bo‘sh emas', () {
    final ids = {for (final k in index.keys) ...index.of(k)!.textIds};
    // Dart jadvali JSON bilan sinxron (generator: parts_l10n.py).
    expect(schematicPartsTextIds, ids);
    for (final lang in ['uz', 'ru', 'en']) {
      final l = lookupAppLocalizations(Locale(lang));
      expect(index.missingTexts(l), isEmpty, reason: lang);
      for (final id in ids) {
        expect(schematicPartsText(l, id)!.trim(), isNotEmpty, reason: id);
      }
    }
    // ru — haqiqatan tarjima (kirill harflari), en bilan bir xil emas.
    final ru = lookupAppLocalizations(const Locale('ru'));
    final en = lookupAppLocalizations(const Locale('en'));
    for (final id in ids) {
      expect(
        schematicPartsText(ru, id),
        matches(RegExp('[а-яё]', caseSensitive: false)),
        reason: id,
      );
      expect(schematicPartsText(ru, id), isNot(schematicPartsText(en, id)));
    }
    // Panel sarlavhalari.
    for (final lang in ['uz', 'ru', 'en']) {
      final l = lookupAppLocalizations(Locale(lang));
      for (final s in [
        l.schemPartsPanelTitle,
        l.schemPartsPanelHint,
        l.schemPartsPartsTitle,
        l.schemPartsPrincipleTitle,
        l.schemPartsResultTitle,
        l.schemPartsClassNote,
      ]) {
        expect(s.trim(), isNotEmpty, reason: lang);
      }
    }
    expect(
      lookupAppLocalizations(const Locale('uz')).schemPartsPanelTitle,
      'Qismlari va ishlash prinsipi',
    );
  });

  test('ARB da yetim schemParts* kaliti yo‘q (uch tilda bir xil)', () {
    const ui = {
      'schemPartsPanelTitle',
      'schemPartsPanelHint',
      'schemPartsPartsTitle',
      'schemPartsPrincipleTitle',
      'schemPartsResultTitle',
      'schemPartsClassNote',
    };
    for (final lang in ['uz', 'ru', 'en']) {
      final arb = jsonDecode(
        File('lib/l10n/app_$lang.arb').readAsStringSync(),
      ) as Map<String, Object?>;
      final keys = {
        for (final k in arb.keys)
          if (k.startsWith('schemParts')) k,
      };
      expect(keys, {...ui, ...schematicPartsTextIds}, reason: lang);
    }
  });

  test('manbalar hujjati: har kalit bo‘limi va har qism qatori', () {
    final doc = File('docs/SCHEMATIC_PARTS_SOURCES.md').readAsStringSync();
    for (final k in allKeys) {
      final start = doc.indexOf('## `$k`');
      expect(start, isNonNegative, reason: k);
      final end = doc.indexOf('\n## ', start + 1);
      final section = doc.substring(start, end < 0 ? doc.length : end);
      final rows = RegExp(
        r'^\| (\d+|P|R) \| .+ \| (.+) \|$',
        multiLine: true,
      ).allMatches(section).toList();
      expect(rows, hasLength(index.of(k)!.parts.length + 2), reason: k);
      for (final r in rows) {
        expect(
          r[2]!.contains('STANDARD_TEXTBOOK (NEEDS_EXPERT)') ||
              r[2]!.contains('<https://'),
          isTrue,
          reason: '$k: ${r[0]}',
        );
      }
    }
  });

  group('yuklovchi rad etadi', () {
    Map<String, Object?> mutate(void Function(Map<String, Object?>) f) {
      final r = _raw();
      f((r['schematics']! as Map).cast<String, Object?>());
      return r;
    }

    test('noma’lum kalit', () {
      expect(
        () => SchematicPartsIndex.fromJson(
          mutate(
            (m) => m['gc_ms_brand_x'] = {
              'parts': [
                {'n': 1, 'id': 'schemPartsX1'},
              ],
              'principle_id': 'schemPartsXPrinciple',
              'result_id': 'schemPartsXResult',
            },
          ),
        ),
        throwsFormatException,
      );
    });

    test('qismsiz yozuv', () {
      expect(
        () => SchematicPartsIndex.fromJson(
          mutate((m) => (m['autoclave']! as Map)['parts'] = <Object>[]),
        ),
        throwsFormatException,
      );
    });

    test('raqamlar ketma-ket emas', () {
      expect(
        () => SchematicPartsIndex.fromJson(
          mutate(
            (m) => (((m['tlc']! as Map)['parts']! as List)[1] as Map)['n'] = 5,
          ),
        ),
        throwsFormatException,
      );
    });

    test('takroriy id', () {
      expect(
        () => SchematicPartsIndex.fromJson(
          mutate((m) {
            final parts = (m['tlc']! as Map)['parts']! as List;
            (parts[1] as Map)['id'] = (parts[0] as Map)['id'];
          }),
        ),
        throwsFormatException,
      );
    });

    test('sxema versiyasi', () {
      expect(
        () => SchematicPartsIndex.fromJson({..._raw(), 'schema_version': 2}),
        throwsFormatException,
      );
    });
  });
}
