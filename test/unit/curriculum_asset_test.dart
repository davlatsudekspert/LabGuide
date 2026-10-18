// Haqiqiy o'quv dasturi asset'i (ustozning 6 oylik kalendar-rejasi): to'liq
// yuklanadi va shaxsiy/tashkiliy ma'lumotsiz (D-42).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';

void main() {
  final raw = File('assets/curriculum/curriculum.json').readAsStringSync();

  test('asset parses: 9 modules, 143 days in order', () {
    final c = Curriculum.parse(raw);
    expect(c.modules.length, 9);
    expect(c.topics.length, greaterThanOrEqualTo(143));
    final orders = [for (final t in c.topics) t.order];
    expect(orders.first, 1);
    expect(orders.last, 143);
  });

  test('asset carries no curator, clinic or group dates', () {
    for (final s in [
      'Karimova',
      'Turg',
      'poliklinika',
      'ADTI',
      'curator',
      'group_curator',
      '"base"',
      '"date"',
    ]) {
      expect(raw.contains(s), isFalse, reason: s);
    }
  });

  test('M9 practical days carry the LabGuide recommended plan (D-67)', () {
    final c = Curriculum.parse(raw);
    final planned = [
      for (final t in c.topics)
        if (t.isRecommendedPlan) t,
    ];
    expect(planned.length, 45);
    expect(planned.first.id, 'd091-P');
    expect(planned.last.id, 'd142-P');
    for (final t in planned) {
      expect(t.moduleId, 'M9', reason: t.id);
      expect(t.type, CurriculumTopicType.practical, reason: t.id);
      expect(
        t.title.of('uz'),
        isNot('Laborator tekshiruv usullarini amaliyotda o‘zlashtirish'),
        reason: t.id,
      );
      expect(
        t.links.protocols.isNotEmpty || t.links.analytes.isNotEmpty,
        isTrue,
        reason: t.id,
      );
    }
    // Ma'ruza va attestatsiya kunlari — manbadagi sarlavha, tavsiya emas.
    for (final id in ['d090-L', 'd095-L', 'd127-L', 'd143-A']) {
      expect(c.topic(id)!.isRecommendedPlan, isFalse, reason: id);
    }
    // protokol selektori (`id#1-4`) — faqat id.
    expect(c.topic('d096-P')!.links.protocols, [
      'qon-surtmasi-tayyorlash-boyash',
    ]);
  });

  test('every module and topic has non-empty title_ru and title_en', () {
    final j = jsonDecode(raw) as Map<String, Object?>;
    for (final m in (j['modules']! as List).cast<Map<String, Object?>>()) {
      for (final lang in ['ru', 'en']) {
        expect(
          ('${m['title_$lang'] ?? ''}').trim(),
          isNotEmpty,
          reason: 'module ${m['id']} title_$lang',
        );
      }
      for (final t in (m['topics']! as List).cast<Map<String, Object?>>()) {
        for (final lang in ['ru', 'en']) {
          expect(
            ('${t['title_$lang'] ?? ''}').trim(),
            isNotEmpty,
            reason: 'topic ${t['id']} title_$lang',
          );
        }
      }
    }
  });
}
