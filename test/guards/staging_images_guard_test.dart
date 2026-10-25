// Staging mikrofotolar (docs/image_staging) — EKSPERT TASDIG'ISIZ ILOVAGA
// CHIQMASLIGI uchun qorovul (egasi qarori 2026-10-25).
//
// Qoidalar:
//  1. Har staging elementida mutaxassislik, tasvir turi va chiqarish holati bor;
//     holat `STAGED_NEEDS_EXPERT_ID` bo'lsa `expert_signoff` bo'sh bo'ladi.
//  2. Holat o'zgarishi (tasdiqlangan) FAQAT to'liq `expert_signoff`
//     {name, specialty, date, decision: approved} bilan mumkin.
//  3. Staging elementlarining fayl nomi, ID'si va manba sahifasi ilova kodida
//     (lib/), atlas/katalog JSON'larida va pubspec'da UCHRAMAYDI; assets/
//     ichida shu nomli fayl yo'q.
//  4. docs/image_staging pubspec assets'iga kirmagan.
//  5. Mutaxassislik paketlari (CSV) 31 ta elementni aniq bir martadan qamraydi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[\s_]+'), '');

void main() {
  final file = File('docs/image_staging/commons_candidates.json');
  final doc = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  final items = (doc['items']! as List).cast<Map<String, Object?>>();

  test('31 element, hammasida mutaxassislik, tur va qulf holati bor', () {
    expect(items.length, 31);
    final ids = items.map((e) => e['id']).toSet();
    expect(ids.length, items.length, reason: 'ID takrorlanmasin');
    for (final it in items) {
      final id = it['id'];
      expect(it['expert_specialty'], isA<String>(), reason: '$id');
      expect(it['image_kind'], isA<String>(), reason: '$id');
      expect(it['release_status'], isNotNull, reason: '$id');
    }
  });

  test('ekspert imzosisiz holat o‘zgarmaydi (imzo to‘liq bo‘lishi shart)', () {
    for (final it in items) {
      final id = it['id'];
      final status = it['status'];
      final sign = it['expert_signoff'];
      if (status == 'STAGED_NEEDS_EXPERT_ID') {
        expect(sign, isNull, reason: '$id: staged element imzosiz');
        expect(it['release_status'], 'HOLD_EXPERT', reason: '$id');
        continue;
      }
      // Boshqa har qanday holat — faqat to'liq imzo bilan.
      expect(
        sign,
        isA<Map>(),
        reason: '$id: $status uchun expert_signoff kerak',
      );
      final m = (sign! as Map).cast<String, Object?>();
      for (final k in ['name', 'specialty', 'date']) {
        expect((m[k] as String?)?.trim(), isNotEmpty, reason: '$id signoff.$k');
      }
      expect(m['decision'], 'approved', reason: '$id');
    }
  });

  test(
    'staging rasmlari ilova kodida, atlasda, katalogda va assets’da yo‘q',
    () {
      final haystack = StringBuffer();
      for (final root in ['lib', 'assets']) {
        for (final e in Directory(root).listSync(recursive: true)) {
          if (e is! File) continue;
          final p = e.path;
          if (p.contains('/l10n/gen/')) continue;
          if (p.endsWith('.dart') || p.endsWith('.json')) {
            if (e.lengthSync() > 8 * 1024 * 1024) continue;
            haystack.write(e.readAsStringSync());
            haystack.write('\n');
          }
        }
      }
      haystack.write(File('pubspec.yaml').readAsStringSync());
      final text = haystack.toString();
      final textNorm = _norm(text);
      final assetNames = [
        for (final e in Directory('assets').listSync(recursive: true))
          if (e is File) _norm(e.path.split('/').last),
      ];
      for (final it in items) {
        final id = it['id']! as String;
        final title = it['file_title']! as String;
        final page = it['page_url']! as String;
        expect(text.contains(id), isFalse, reason: '$id kodda/JSON’da');
        expect(
          textNorm.contains(_norm(title)),
          isFalse,
          reason: '$id fayl nomi ($title) kodda/JSON’da',
        );
        expect(
          text.contains(page),
          isFalse,
          reason: '$id manba sahifasi ilovada',
        );
        expect(
          assetNames.contains(_norm(title)),
          isFalse,
          reason: '$id fayli assets’da ($title)',
        );
      }
    },
  );

  test('docs/image_staging pubspec assets’iga kirmagan', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('image_staging'), isFalse);
    expect(pubspec.contains('- docs/'), isFalse);
  });

  test('mutaxassislik paketlari 31 elementni aniq bir martadan qamraydi', () {
    final seen = <String>[];
    for (final f in Directory('docs/image_staging/expert_packets').listSync()) {
      if (f is File && f.path.endsWith('.csv')) {
        final lines = f.readAsLinesSync();
        for (final l in lines.skip(1)) {
          final id = l.replaceAll('﻿', '').split(',').first;
          if (id.startsWith('LG26X-')) seen.add(id);
        }
      }
    }
    final expected = items.map((e) => e['id']! as String).toList()..sort();
    seen.sort();
    expect(seen, expected);
  });
}
