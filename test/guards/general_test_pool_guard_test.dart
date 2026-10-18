// Qorovul: “Umumiy test berish” — har manbaning (toifa, ma'ruza modullari va
// kunlari, analizlar) har bir tanlanadigan mavzusi hovuzidagi savol id lari
// ustoz, talaba, katta ekran va natijalar ishlatadigan indeksda
// (classQuestionIndex) topilishi va server kaliti (`correct.single`)
// variantlar ichida bo'lishi shart. Haqiqiy asset'lar bilan.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/variant_draw.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/general_test.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart' show Locale;

import '../helpers/server_rules.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

void main() {
  final cur = Curriculum.parse(
    File('assets/curriculum/curriculum.json').readAsStringSync(),
  );
  final pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
  final bank = ToifaBank.fromJson(
    _json('assets/toifa/kdl_tests.json'),
    _json('assets/toifa/kdl_oral.json'),
  );
  final catalog = GeneralCatalog.of(cur, pack, bank);
  final index = classQuestionIndex(pack, bank);
  final server = ServerRules.load();

  test('har manba mavzusi: id indeksda, server kaliti oralig‘ida', () {
    final problems = <String>[];
    void check(String where, List<ExamQuestion> qs) {
      if (qs.isEmpty) problems.add('$where: bo‘sh');
      final ids = <String>{};
      for (final q in qs) {
        if (!ids.add(q.id)) problems.add('$where: takror ${q.id}');
        final hit = index[q.id];
        if (hit == null) {
          problems.add('$where: indeksda yo‘q ${q.id}');
          continue;
        }
        if (hit.correct.length != 1) {
          problems.add('$where: bitta javob emas ${q.id}');
          continue;
        }
        if (!server.idRe.hasMatch(q.id)) problems.add('$where: id ${q.id}');
        final k = hit.correct.single;
        if (k < 0 || k >= hit.optionCount || k > server.maxKey) {
          problems.add('$where: kalit $k oraliqda emas ${q.id}');
        }
        // Indeksdagi savol — xuddi shu kalit (ustoz yuborgan = server).
        if (q.correct.single != k) problems.add('$where: kalit farqi ${q.id}');
      }
    }

    for (final s in GeneralSource.values) {
      for (final t in catalog.topicsOf(s)) {
        check(t.key, t.questions);
      }
    }
    for (final m in catalog.modules) {
      check(m.key, m.questions);
    }
    // “Hammasini tanlash” har manbada va hammasi birga.
    for (final s in GeneralSource.values) {
      final keys = {for (final t in catalog.topicsOf(s)) t.key};
      check('all:${s.name}', generalPool(catalog.strata(keys)));
    }
    check(
      'all',
      generalPool(catalog.strata({for (final t in catalog.all) t.key})),
    );
    expect(problems, isEmpty);
  });

  test('manbalar to‘liq: toifa mavzulari, M1–M9, analiz guruhlari', () {
    // Toifa: rasmiy ro'yxatdagi barcha baholanadigan savollar (480 ta);
    // savoli yo'q mavzu (masalan, ro'yxatda bo'sh bo'lim) ko'rsatilmaydi.
    expect(
      catalog.toifa,
      hasLength(bank.scorable.map((q) => q.topic).toSet().length),
    );
    expect(catalog.toifa.length, greaterThanOrEqualTo(25));
    expect(
      catalog.sourceCount(GeneralSource.toifa),
      bank.scorable.where((q) => q.correct.length == 1).length,
    );
    expect(catalog.sourceCount(GeneralSource.toifa), greaterThan(400));
    expect(
      [for (final m in catalog.modules) m.id],
      [for (var i = 1; i <= 9; i++) 'M$i'],
    );
    expect(catalog.lectureDays.length, greaterThan(100));
    expect(catalog.packGroups, isNotEmpty);
    // Mavzu kalitlari server `pool_topics` qoidasiga (TOPIC_RE) mos.
    for (final key in [
      for (final t in catalog.all) t.key,
      for (final m in catalog.modules) m.key,
    ]) {
      expect(variantTopic([key]), key, reason: key);
      expect(server.topicRe.hasMatch(key), isTrue, reason: key);
    }
    // 50 savollik variantli test: hovuz 100 — server qabul qiladi.
    expect(kGeneralTestMax, server.maxQuestions);
    expect(kGeneralVariantPoolMax, server.maxPool);
    expect(variantAllowed(kGeneralVariantPoolMax, kGeneralTestMax), isTrue);
  });

  test(
    'teng taqsimlash: mavzular bo‘yicha ±1, takrorsiz, urug‘ — barqaror',
    () {
      final picked = {
        catalog.toifa.first.key,
        for (final d in catalog.modules[2].days) d.key,
      };
      final strata = catalog.strata(picked);
      // Butun modul — bitta qatlam.
      expect(strata.map((s) => s.key), [
        catalog.toifa.first.key,
        catalog.modules[2].key,
      ]);
      final a = drawBalanced(strata, count: 30, seed: 7);
      final b = drawBalanced(strata, count: 30, seed: 7);
      expect([for (final q in a) q.id], [for (final q in b) q.id]);
      expect({for (final q in a) q.id}, hasLength(30));
      final small = strata.first.questions.length;
      final fromFirst = a.where(strata.first.questions.contains).length;
      expect(fromFirst, small < 15 ? small : 15);
    },
  );

  test(
    'standart sarlavha (uz/ru/en) server chegarasida — har manba va hammasi',
    () {
      final problems = <String>[];
      final sets = <String, Set<String>>{
        for (final t in catalog.all) t.key: {t.key},
        for (final s in GeneralSource.values)
          'all:${s.name}': {for (final t in catalog.topicsOf(s)) t.key},
        'all': {for (final t in catalog.all) t.key},
        'mix': {
          ...catalog.toifa.take(4).map((t) => t.key),
          for (final d in catalog.modules.last.days.take(3)) d.key,
          ...catalog.packGroups.take(2).map((t) => t.key),
        },
      };
      for (final lang in ['uz', 'ru', 'en']) {
        final l = lookupAppLocalizations(Locale(lang));
        for (final e in sets.entries) {
          final t = generalTestTitle(l, lang, catalog, e.value);
          if (t.trim().length < 3 || t.length > server.titleMax) {
            problems.add('${e.key}/$lang: ${t.length}');
          }
        }
      }
      expect(problems, isEmpty);
    },
  );
}
