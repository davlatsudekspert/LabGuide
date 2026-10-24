// Ma'lumotnoma kartalari sxemasi: NEEDS_SOURCE stub, yashirinlik, manba turi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/instruments/instrument_catalog.dart';
import 'package:labguide/features/instruments/lab_direction_card.dart';

Map<String, Object?> _base() =>
    (jsonDecode(File('assets/instruments/catalog.json').readAsStringSync())
            as Map)
        .cast<String, Object?>();

Map<String, Object?> _src(String id, String type, String url) => {
  'id': id,
  'title': id,
  'url': url,
  'doc_ref': 'v1',
  'accessed': '2026-10-24',
  'type': type,
};

Map<String, Object?> _txt(String t, List<String> src) => {
  'text': {'uz': t, 'ru': t, 'en': t},
  'sources': src,
};

Map<String, Object?> _card(String id, String dir, List<String> src) => {
  'id': id,
  'lab_direction': dir,
  'card_kind': 'test',
  'name': {'uz': id, 'ru': id, 'en': id},
  'tasks': [_txt('x', src)],
  'sources': src,
};

Map<String, Object?> _stub(String id, String dir) => {
  'id': id,
  'lab_direction': dir,
  'card_kind': 'method',
  'name': {'uz': id, 'ru': id, 'en': id},
  'audit_status': 'NEEDS_SOURCE',
  'needs_source_reason': 'no source yet',
  'priority': 'P2',
};

InstrumentCatalog _with(List<Map<String, Object?>> cards,
    [List<Map<String, Object?>> extraSources = const []]) {
  final raw = _base();
  raw['sources'] = [...(raw['sources']! as List), ...extraSources];
  raw['lab_cards'] = cards;
  return InstrumentCatalog.fromJson(raw);
}

void main() {
  final off = _src('o1', 'official_agency', 'https://www.who.int/x');
  final mk = _src('m1', 'manufacturer_marketing', 'https://www.cepheid.com/x');

  test('LabDirection: 22 yo‘nalish, parse qat’iy', () {
    expect(LabDirection.values.length, 22);
    expect(LabDirection.parse('molecular'), LabDirection.molecular);
    expect(() => LabDirection.parse('nope'), throwsFormatException);
    expect(LabAuditStatus.parse('NEEDS_SOURCE'), LabAuditStatus.needsSource);
    expect(() => LabAuditStatus.parse('VERIFIED'), throwsFormatException);
  });

  test('NEEDS_SOURCE stub: manbasiz yuklanadi, saqlanadi, lekin yashirin', () {
    final c = _with([
      _card('a', 'hiv', ['o1']),
      _stub('s', 'bacteriology'),
    ], [off]);
    expect(c.labCards.length, 2);
    expect(c.publicLabCards.map((x) => x.id), ['a']);
    expect(c.labCard('s'), isNull);
    expect(c.labCardsIn(LabDirection.bacteriology), isEmpty);
    expect(c.publicLabDirections, [LabDirection.hiv]);
    final s = c.labCards.last;
    expect(s.isPublic, isFalse);
    expect(s.needsSourceReason, 'no source yet');
    expect(s.priority, LabCardPriority.p2);
  });

  test('stub shakli qat’iy: kontent maydoni yoki sababsiz — rad', () {
    final withTasks = _stub('s', 'hiv')..['tasks'] = [_txt('x', ['o1'])];
    expect(() => _with([withTasks], [off]), throwsFormatException);
    final noReason = _stub('s', 'hiv')..remove('needs_source_reason');
    expect(() => _with([noReason], [off]), throwsFormatException);
    final badPrio = _stub('s', 'hiv')..['priority'] = 'P9';
    expect(() => _with([badPrio], [off]), throwsFormatException);
    final reviewed = _stub('s', 'hiv')..['expert_reviewed'] = true;
    expect(() => _with([reviewed], [off]), throwsFormatException);
  });

  test('NEEDS_REVIEW karta: har matnda manba shart', () {
    final c = _card('a', 'hiv', ['o1'])..['tasks'] = [_txt('x', [])];
    expect(() => _with([c], [off]), throwsFormatException);
  });

  test('faqat marketing manbali karta rad etiladi; rasmiy bilan qo‘shilsa — ok', () {
    expect(
      () => _with([_card('a', 'tb', ['m1'])], [mk]),
      throwsFormatException,
    );
    final ok = _with([_card('a', 'tb', ['m1', 'o1'])], [mk, off]);
    expect(ok.labCard('a'), isNotNull);
    expect(ok.sources['m1']!.type, SourceType.manufacturerMarketing);
  });

  test('noma’lum manba turi rad etiladi', () {
    expect(
      () => _with([], [_src('z', 'blog', 'https://example.com/')]),
      throwsFormatException,
    );
  });

  test('stub bilan bog‘langan karta: havola yashirin, xato emas', () {
    final a = _card('a', 'tb', ['o1'])..['linked'] = ['s'];
    final c = _with([a, _stub('s', 'tb')], [off]);
    expect(c.labCard('a')!.linked, ['s']);
    expect(c.labCard('s'), isNull);
  });

  test('haqiqiy katalog: stub bor, ommaviy ro‘yxatda yo‘q, JSON round-trip', () {
    final raw = _base();
    final c = InstrumentCatalog.fromJson(raw);
    final stubs = c.labCards.where((x) => !x.isPublic).toList();
    expect(stubs, isNotEmpty);
    for (final s in stubs) {
      expect(c.labCard(s.id), isNull);
      expect(c.publicLabCards.contains(s), isFalse);
    }
    final again = InstrumentCatalog.fromJson(
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, Object?>(),
    );
    expect(again.labCards.length, c.labCards.length);
    expect(again.models.length, 26);
  });
}
