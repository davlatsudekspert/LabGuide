// Yo‘nalish kartalari rasmlari qorovuli (egasi talabi 24–25.10): har bir
// ommaviy karta yo LabGuide’ning o‘z apparat SINFI chizmasiga ega (480 va
// 1200 px PNG mavjud, pubspec’da ro‘yxatda, kelib chiqishi sha256 bilan
// hujjatlangan), yo docs/LAB_CARD_IMAGE_COVERAGE.md da sababli istisno.
// Yangi ommaviy karta jadvalga qo‘shilmasa — test yiqiladi.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';

import '../helpers/schematic_svg.dart';

typedef _Row = ({String kind, String? key, String reason});

Map<String, Object?> _raw() => (jsonDecode(
  File('assets/instruments/catalog.json').readAsStringSync(),
) as Map).cast<String, Object?>();

(int, int) _pngSize(Uint8List b) {
  expect(b.sublist(1, 4), 'PNG'.codeUnits);
  final d = ByteData.sublistView(b);
  return (d.getUint32(16), d.getUint32(20));
}

void main() {
  final catalog = InstrumentCatalog.fromJson(_raw());
  final doc = File('docs/LAB_CARD_IMAGE_COVERAGE.md').readAsStringSync();
  final rowRe = RegExp(
    r'^\| `([a-z0-9-]+)` \| (platform|test|method) \| (?:`([a-z0-9_]+)`|—) \| (.+) \|$',
    multiLine: true,
  );
  final rows = <String, _Row>{
    for (final m in rowRe.allMatches(doc))
      m[1]!: (kind: m[2]!, key: m[3], reason: m[4]!.trim()),
  };

  test(
    'jadval = ommaviy kartalar (stub yo‘q, yangi karta tushib qolmagan)',
    () {
      expect(rows, isNotEmpty);
      expect(rows.keys.toSet(), {
        for (final c in catalog.publicLabCards) c.id,
      }, reason: 'docs/LAB_CARD_IMAGE_COVERAGE.md jadvalini yangilang');
      for (final c in catalog.publicLabCards) {
        expect(rows[c.id]!.kind, c.kind.name, reason: c.id);
      }
    },
  );

  test('har karta: chizma (ikki o‘lcham, pubspec) yoki sababli istisno', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      pubspec.contains(
        RegExp(r'^\s+- assets/instruments/schematic/$', multiLine: true),
      ),
      isTrue,
      reason: 'pubspec flutter.assets da schematic katalogi yo‘q',
    );
    for (final c in catalog.publicLabCards) {
      final row = rows[c.id]!;
      final sch = c.schematic;
      if (sch == null) {
        expect(
          row.key,
          isNull,
          reason: '${c.id}: jadvalda kalit, katalogda yo‘q',
        );
        expect(row.reason, startsWith('Istisno:'), reason: c.id);
        expect(row.reason.length, greaterThan(30), reason: c.id);
        continue;
      }
      expect(row.key, sch.key, reason: c.id);
      for (final (path, w, h) in [
        (sch.asset, 480, 320),
        (sch.assetLarge, 1200, 800),
      ]) {
        final f = File(path);
        expect(f.existsSync(), isTrue, reason: path);
        expect(_pngSize(f.readAsBytesSync()), (w, h), reason: path);
      }
    }
  });

  test('istisnolar faqat test/usul yoki apparati manbasiz kartalarda', () {
    // Platforma kartasi (apparatning o‘zi) chizmasiz qolmaydi.
    for (final c in catalog.publicLabCards) {
      if (c.kind == LabCardKind.platform) {
        expect(c.schematic, isNotNull, reason: '${c.id}: platforma chizmasiz');
      }
    }
  });

  test('test/usul kartasi bog‘langan platforma chizmasini oladi', () {
    for (final c in catalog.publicLabCards) {
      if (c.kind == LabCardKind.platform || c.schematic == null) continue;
      final linked = [
        for (final id in c.linked)
          if (catalog.labCard(id) case final o?
              when o.kind == LabCardKind.platform)
            o,
      ];
      if (linked.isEmpty) continue;
      expect(
        linked.map((o) => o.schematic).contains(c.schematic),
        isTrue,
        reason: '${c.id}: bog‘langan platformadan boshqa chizma',
      );
    }
  });

  test(
    'har sinf chizmasi: ishlatiladi, SVG manbasi, hajm, sha256 hujjatda',
    () {
      final prov = File('docs/SCHEMATICS_PROVENANCE.md').readAsStringSync();
      final gen = File('tool/illustrations/schematic/gen.py')
          .readAsStringSync();
      final used = {for (final c in catalog.publicLabCards) ?c.schematic};
      for (final s in LabSchematic.values) {
        expect(used, contains(s), reason: '${s.key}: hech bir kartada yo‘q');
        expect(gen, contains('"${s.key}": ('), reason: '${s.key}: gen.py');
        final svg = File('tool/illustrations/schematic/${s.key}.svg');
        expect(svg.existsSync(), isTrue, reason: svg.path);
        // Rasmda matn yo‘q (D-36a / egasi talabi) — faqat qism belgilari
        // guruhidagi raqamlar (1..n) ruxsat etiladi (egasi talabi 2026-10-25).
        expect(
          calloutNumbers(svg.readAsStringSync()),
          isNotEmpty,
          reason: svg.path,
        );
        for (final path in [s.asset, s.assetLarge]) {
          final bytes = File(path).readAsBytesSync();
          expect(bytes.length, lessThanOrEqualTo(150 * 1024), reason: path);
          expect(
            prov,
            contains(sha256.convert(bytes).toString()),
            reason: '$path sha256 docs/SCHEMATICS_PROVENANCE.md da yo‘q',
          );
        }
      }
    },
  );

  test('stubda chizma yo‘q; noma’lum kalit yuklanishda rad etiladi', () {
    final raw = _raw();
    for (final c in (raw['lab_cards']! as List).cast<Map<String, Object?>>()) {
      if (c['audit_status'] == 'NEEDS_SOURCE') {
        expect(c.containsKey('schematic'), isFalse, reason: '${c['id']}');
      }
    }
    Map<String, Object?> withCard(Map<String, Object?> card) {
      final r = _raw();
      (r['lab_cards']! as List).add(card);
      return r;
    }

    Map<String, String> t(String s) => {'uz': s, 'ru': s, 'en': s};
    // Noma’lum kalit.
    expect(
      () => InstrumentCatalog.fromJson(
        withCard({
          'id': 'x-unknown-schematic',
          'lab_direction': 'general',
          'card_kind': 'platform',
          'name': t('X'),
          'schematic': 'gc_ms_brand_x',
          'sources': ['cdc-xpert-mtb-rif'],
        }),
      ),
      throwsFormatException,
    );
    // Stubga chizma berib bo‘lmaydi.
    expect(
      () => InstrumentCatalog.fromJson(
        withCard({
          'id': 'x-stub-with-image',
          'lab_direction': 'general',
          'card_kind': 'platform',
          'name': t('X'),
          'audit_status': 'NEEDS_SOURCE',
          'needs_source_reason': 'none',
          'schematic': 'autoclave',
        }),
      ),
      throwsFormatException,
    );
    // Ro‘yxatdagi kalit — qabul qilinadi.
    final ok = InstrumentCatalog.fromJson(
      withCard({
        'id': 'x-known-schematic',
        'lab_direction': 'general',
        'card_kind': 'platform',
        'name': t('X'),
        'schematic': 'autoclave',
        'sources': ['cdc-xpert-mtb-rif'],
      }),
    );
    expect(ok.labCard('x-known-schematic')!.schematic, LabSchematic.autoclave);
  });
}
