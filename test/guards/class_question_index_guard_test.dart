// Qorovul: ustoz topshirgan mavzu testining har bir savoli ustoz, talaba va
// katta ekran ishlatadigan indeksda (classQuestionIndex) topilishi kerak.
// 2026-10-18: deck matnidan olingan (derived) savollar indeksga kirmay
// qolgan — ustoz “Talaba ko'rinishida sinash”da va talaba testda “savol
// ilovangizdagi to'plamda yo'q” xatosini ko'rgan.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

void main() {
  test('mavzu testi savollarining hammasi topshiriq indeksida bor', () {
    final cur = Curriculum.parse(
      File('assets/curriculum/curriculum.json').readAsStringSync(),
    );
    final pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
    final bank = ToifaBank.fromJson(
      _json('assets/toifa/kdl_tests.json'),
      _json('assets/toifa/kdl_oral.json'),
    );
    final index = classQuestionIndex(pack, bank);
    var derived = 0;
    final missing = <String>[];
    for (final t in cur.topics) {
      final derivedIds = t.derivedQuizCandidates.toSet();
      for (final q in verifiedTopicQuestions(t, pack, bank)) {
        if (derivedIds.contains(q.id)) derived++;
        if (!index.containsKey(q.id)) missing.add('${t.id}: ${q.id}');
      }
    }
    expect(missing, isEmpty);
    // Derived savollar haqiqatan tekshirildi (bo'sh to'plam emas).
    expect(derived, greaterThan(100));
  });
}
