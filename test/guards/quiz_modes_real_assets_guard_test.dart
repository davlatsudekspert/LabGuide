// Qorovul: O'rganish → Mashq (quiz), Imtihon rejimi, toifa mavzu mashqi va
// kunlik savollar — HAQIQIY asset'lar bilan, HAR BIR mavzu va savol.
// Har ko'rsatiladigan mavzu savol beradi; sessiyadagi har savol o'z manbasi
// orqali topiladi (ekranda “savol to'plamda yo'q” chiqmaydi).
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/daily/daily_screens.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/learn/learn_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

const _langs = ['uz', 'ru', 'en'];

void main() {
  final pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
  final bank = ToifaBank.fromJson(
    _json('assets/toifa/kdl_tests.json'),
    _json('assets/toifa/kdl_oral.json'),
  );
  final packSource = PackQuestionSource.of(pack);

  List<String> checkQuestion(ExamQuestion q, String where) => [
    if (q.correct.isEmpty) '$where: kalit yo‘q',
    for (final k in q.correct)
      if (k < 0 || k >= q.optionCount) '$where: kalit $k',
    for (final lang in _langs) ...[
      if (q.prompt(lang).trim().isEmpty) '$where: savol ($lang)',
      for (var i = 0; i < q.optionCount; i++)
        if (q.option(i, lang).trim().isEmpty) '$where: $i-variant ($lang)',
    ],
  ];

  test('Mashq (quiz): har guruh savol beradi, har savol uch tilda, kalit '
      'oralig‘ida; deck matnidan olinganlar mashqqa kirmaydi', () {
    final problems = <String>[];
    final practice = [
      for (final q in pack.quiz)
        if (!q.isDerived) q,
    ];
    expect(practice.length, greaterThanOrEqualTo(150));
    var groupsShown = 0;
    for (final g in pack.groups) {
      final qs = questionsForGroup(pack, g.id);
      if (qs.isEmpty) continue;
      groupsShown++;
      for (final q in qs) {
        if (q.isDerived) problems.add('${g.id}/${q.id}: derived mashqda');
      }
    }
    // Analit kartasidagi mini-test ham faqat mashq savollari.
    for (final a in pack.analytes) {
      for (final q in questionsForAnalyte(pack, a.id)) {
        if (q.isDerived) problems.add('${a.id}/${q.id}: derived kartada');
      }
    }
    for (final q in practice) {
      final where = q.id;
      if (q.correctIndex < 0 || q.correctIndex >= q.options.length) {
        problems.add('$where: kalit');
      }
      for (final lang in _langs) {
        if (q.prompt.of(lang).trim().isEmpty) problems.add('$where: $lang');
        for (final o in q.options) {
          if (o.text.of(lang).trim().isEmpty) problems.add('$where: $lang var');
        }
      }
    }
    expect(problems, isEmpty);
    expect(groupsShown, greaterThanOrEqualTo(8));
  });

  test('Imtihon rejimi (paket): har mavzu savol beradi, har savol manbadan '
      'topiladi; sessiya to‘liq/nol ball', () {
    final problems = <String>[];
    expect(packSource.topics, isNotEmpty);
    for (final t in packSource.topics) {
      final pool = examPool(packSource, {t.id});
      if (pool.isEmpty) problems.add('${t.id}: bo‘sh');
      for (final q in pool) {
        if (!identical(packSource.question(q.id), q)) {
          problems.add('${t.id}/${q.id}: manbada yo‘q');
        }
        problems.addAll(checkQuestion(q, '${t.id}/${q.id}'));
      }
      final r = Random(t.id.hashCode);
      final s = ExamSession.build(
        id: t.id,
        mode: ExamMode.exam,
        questions: drawQuestions(pool, 20, r),
        random: r,
        startedAt: DateTime.utc(2026, 10, 18),
        topicIds: [t.id],
      );
      for (var i = 0; i < s.length; i++) {
        s.choose(s.current.order.indexOf(s.current.correct.first));
        s.next();
      }
      if (s.correctCount != s.length) problems.add('${t.id}: ball');
    }
    // “Hammasi” = barcha mashq savollari.
    expect(examPool(packSource, const {}).length, packSource.questions.length);
    expect(problems, isEmpty);
  });

  test('Toifa: har mavzu (mavzu bo‘yicha mashq va imtihon) savol beradi', () {
    final problems = <String>[];
    final src = bank.source;
    for (final t in src.topics) {
      final pool = examPool(src, {t.id});
      if (pool.isEmpty) problems.add('${t.id}: bo‘sh');
      for (final q in pool) {
        if (src.question(q.id) == null) problems.add('${t.id}/${q.id}');
        problems.addAll(checkQuestion(q, '${t.id}/${q.id}'));
      }
    }
    // Toifa ro'yxatidagi har mavzuning kamida bitta ball beradigan savoli bor.
    final shown = {for (final t in src.topics) t.id};
    for (final t in bank.topicOrder) {
      if (bank.tests.any((q) => q.topic == t && q.scorable) &&
          !shown.contains(t)) {
        problems.add('$t: ro‘yxatda yo‘q');
      }
    }
    expect(problems, isEmpty);
  });

  test('Kunlik savollar: har rol uchun hovuz bo‘sh emas, har id topiladi', () {
    for (final role in AppRole.values) {
      final p = dailyPoolFor(packSource, role);
      final ids = [...p.priority, ...p.others];
      expect(ids, isNotEmpty, reason: role.name);
      for (final id in ids) {
        expect(packSource.question(id), isNotNull, reason: '$role $id');
      }
    }
    // Laborant/talaba uchun ustuvor mavzular haqiqatan mavjud (nom o'zgarsa
    // ustuvorlik jimgina yo'qolmasin).
    expect(dailyPoolFor(packSource, AppRole.lab).priority, isNotEmpty);
    final toifa = dailyPoolFor(bank.source, AppRole.lab);
    expect(toifa.others.length, greaterThanOrEqualTo(380));
    for (final id in toifa.others) {
      final q = bank.test(id)!;
      expect(q.scorable && q.keyCheck.verdict == KeyVerdict.ok, isTrue);
    }
  });
}
