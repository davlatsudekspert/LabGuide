// Qorovul: ustoz–talaba testi (sinf) — HAQIQIY asset'lar bilan, HAR BIR
// tayyor deck va HAR BIR savol bo'yicha.
//
// “Guruhga topshirish” ekrani yuboradigan savol id lari va kalit:
//  * serverda qabul qilinadi (cloudflare/src/groups.ts dagi qoidalar shu
//    fayldan o'qiladi — server o'zgarsa, test ham ko'radi);
//  * ustoz ko'rinishi, “Talaba ko'rinishida sinash”, talaba testi, katta
//    ekran va natijalar ishlatadigan qidiruvda (classQuestionIndex /
//    ClassQuestionSource / PackQuestionSource) topiladi;
//  * oddiy va variantli (per_student, D-66) rejimda server balli ilova
//    kalitiga mos keladi (umumiy variant vektorlaridagi id juftlari bilan).
//
// Worker testi (cloudflare/test/real_decks.test.ts) xuddi shu decklarni
// haqiqiy server kodi orqali o'tkazadi: fixture —
// cloudflare/test/real_deck_assignments.json. Asset o'zgarsa:
//   LG_WRITE_FIXTURES=1 flutter test test/guards/classroom_real_assets_guard_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/variant_draw.dart';
import 'package:labguide/features/classroom/classroom_screens.dart'
    show classroomTestTitle;
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/classroom/topic_test_screens.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

const _fixture = 'cloudflare/test/real_deck_assignments.json';

/// Server qoidalari — groups.ts manbasidan (regex va chegaralar).
class _Server {
  _Server(String src) {
    RegExp re(String name) {
      final m = RegExp('const $name = /(.+)/;').firstMatch(src);
      if (m == null) throw StateError('groups.ts: $name topilmadi');
      return RegExp(m.group(1)!);
    }

    int num(String pattern) {
      final m = RegExp(pattern).firstMatch(src);
      if (m == null) throw StateError('groups.ts: $pattern topilmadi');
      return int.parse(m.group(1)!);
    }

    idRe = re('ID_RE');
    topicRe = re('TOPIC_RE');
    maxPool = num(r'const MAX_POOL = (\d+);');
    maxQuestions = num(r'const maxQs = perStudent == null \? (\d+) :');
    maxKey = num(r'Number.isInteger\(k\) && k >= 0 && k <= (\d+)');
    titleMax = num(r"str\(body.title, 3, (\d+), 'invalid_title'\)");
  }

  late final RegExp idRe;
  late final RegExp topicRe;
  late final int maxPool;
  late final int maxQuestions;
  late final int maxKey;
  late final int titleMax;
}

/// Ustoz ekrani (AssignDeckTestScreen) nima yuboradi — o'sha qoidalar bilan.
class _Assign {
  _Assign(this.deck, this.pool);

  final DeckEntry deck;
  final List<ExamQuestion> pool;

  /// Variant hovuzi: id bo'yicha tartiblangan, ≤ kVariantPoolMax.
  List<ExamQuestion> get variantPool {
    final sorted = [...pool]..sort((a, b) => a.id.compareTo(b.id));
    return sorted.length <= kVariantPoolMax
        ? sorted
        : (drawTopicTest(sorted, count: kVariantPoolMax, seed: 1)
            ..sort((a, b) => a.id.compareTo(b.id)));
  }

  /// Oddiy rejim: ustoz eng ko'p savolni tanlasa (≤ 50) — hovuz to'liq.
  List<ExamQuestion> get fixed =>
      drawTopicTest(pool, count: min(pool.length, 50), seed: 7);

  String get dayId => deck.topics.firstWhere(
    (t) => t.endsWith('-L'),
    orElse: () => deck.topics.first,
  );

  /// Variantli testda talabaga nechta savol: standart 10, hovuz kichik
  /// bo'lsa — hovuzning yarmi (ustoz kamaytirgandek).
  int get perStudent => min(kTopicTestSize, variantPool.length ~/ 2);
}

/// Talaba ilovasi: ExamSession (shuffle bilan), javob — ekrandagi variant,
/// serverga — asl indeks. Server balli: [key] bo'yicha (groups.ts kabi).
({int score, int total}) _serverScore({
  required List<String> pool,
  required List<int> key,
  required List<String> mine,
  required bool variant,
  required List<int> answers,
  required List<String> answerIds,
}) {
  final at = {for (final (i, q) in pool.indexed) q: i};
  final myKey = variant ? [for (final q in mine) key[at[q]!]] : key;
  var ordered = answers;
  if (variant) {
    final pos = {for (final (i, q) in mine.indexed) q: i};
    final o = List<int>.filled(mine.length, -2);
    for (final (i, q) in answerIds.indexed) {
      o[pos[q]!] = answers[i];
    }
    ordered = o;
  }
  var score = 0;
  for (var i = 0; i < myKey.length; i++) {
    if (ordered[i] == myKey[i]) score++;
  }
  return (score: score, total: myKey.length);
}

void main() {
  final cur = Curriculum.parse(
    File('assets/curriculum/curriculum.json').readAsStringSync(),
  );
  final pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
  final bank = ToifaBank.fromJson(
    _json('assets/toifa/kdl_tests.json'),
    _json('assets/toifa/kdl_oral.json'),
  );
  final catalog = DeckCatalog.parse(
    File('assets/lectures/index_v2.json').readAsStringSync(),
  );
  final server = _Server(File('cloudflare/src/groups.ts').readAsStringSync());
  final vectors = _json('cloudflare/test/variant_vectors.json');
  // Umumiy vektorlardagi (topshiriq, talaba) juftlari.
  final pairs = {
    for (final c in (vectors['cases']! as List).cast<Map<String, Object?>>())
      (c['assignment_id']! as String, c['user_id']! as String),
  }.toList();

  final pools = DeckPools.of(cur, pack, bank);
  final ready = [
    for (final d in catalog.decks)
      if (pools.state(d) == DeckTestState.ready) _Assign(d, pools.pool(d)),
  ];

  // Ekranlar ishlatadigan qidiruvlar.
  final index = classQuestionIndex(pack, bank); // ustoz, talaba, katta ekran
  final classSource = ClassQuestionSource.of(pack, bank); // run (aralash)
  final packSource = PackQuestionSource.of(pack); // run (faqat paket)

  test('server qoidalari o‘qildi va ilova chegaralari mos', () {
    expect(server.maxPool, kVariantPoolMax);
    expect(server.maxQuestions, 50);
    expect(server.titleMax, 120);
    expect(kAssignmentTitleMax, server.titleMax);
    // Uzun nom qisqartiriladi; qisqasi o'zgarmaydi.
    expect(fitAssignmentTitle('a' * 200).length, server.titleMax);
    expect(fitAssignmentTitle('a' * 200).endsWith('…'), isTrue);
    expect(fitAssignmentTitle('  Test: Qon  '), 'Test: Qon');
    // Ilova variant mavzusi uchun aynan server regex'ini ishlatadi.
    expect(variantTopic(['hem-1']), 'hem-1');
    expect(variantTopic(['bad topic']), isNull);
    expect(ready.length, greaterThanOrEqualTo(142));
  });

  test('har tayyor deck: id, kalit, sarlavha (uz/ru/en), mavzu — server '
      'qabul qiladi', () {
    final problems = <String>[];
    for (final lang in ['uz', 'ru', 'en']) {
      final l = lookupAppLocalizations(Locale(lang));
      for (final a in ready) {
        final t = topicAssignmentTitle(l, a.deck, lang);
        if (t.trim().length < 3 || t.trim().length > server.titleMax) {
          problems.add('${a.deck.id}/$lang: sarlavha ${t.length}');
        }
      }
    }
    for (final a in ready) {
      final d = a.deck;
      if (!server.topicRe.hasMatch(d.id)) problems.add('${d.id}: deck_id');
      if (!server.topicRe.hasMatch(a.dayId)) problems.add('${d.id}: day_id');
      for (final q in a.variantPool) {
        if (!server.idRe.hasMatch(q.id)) problems.add('${d.id}: id ${q.id}');
        final k = q.correct.single;
        if (k < 0 || k > server.maxKey || k >= q.optionCount) {
          problems.add('${d.id}/${q.id}: kalit $k');
        }
        if (q.optionCount - 1 > server.maxKey) {
          problems.add('${d.id}/${q.id}: variantlar ko‘p');
        }
        final topic = variantTopic(q.topicIds);
        if (topic != null && !server.topicRe.hasMatch(topic)) {
          problems.add('${d.id}/${q.id}: pool_topic');
        }
      }
      if (a.fixed.length > server.maxQuestions) problems.add('${d.id}: >50');
      if (a.variantPool.length > server.maxPool) problems.add('${d.id}: >60');
    }
    expect(problems, isEmpty);
  });

  test('har tayyor deck, har savol: ustoz, “Talaba ko‘rinishida sinash”, '
      'talaba testi, katta ekran va natijalar qidiruvi topadi', () {
    final problems = <String>[];
    for (final a in ready) {
      final ids = [for (final q in a.variantPool) q.id];
      // Talaba testi manbasi: hammasi paketda bo'lsa — PackQuestionSource,
      // aks holda ClassQuestionSource (classes_screens.dart, _packOnly).
      final packOnly = ids.every((id) => packSource.question(id) != null);
      for (final q in a.variantPool) {
        final where = '${a.deck.id}/${q.id}';
        if (index[q.id] == null) problems.add('$where: classQuestionIndex');
        if (classSource.question(q.id) == null) {
          problems.add('$where: ClassQuestionSource');
        }
        if (packOnly && packSource.question(q.id) == null) {
          problems.add('$where: PackQuestionSource');
        }
        // Topilgan savol kaliti ustoz yuborgan kalit bilan bir xil.
        if (index[q.id]?.correct.single != q.correct.single) {
          problems.add('$where: kalit mos emas');
        }
      }
    }
    expect(problems, isEmpty);
  });

  for (final variant in [false, true]) {
    test(
      '${variant ? 'variantli' : 'oddiy'} rejim: talaba ilovadagidek '
      'yechadi, server balli ilova kalitiga mos (to‘g‘ri — to‘liq, xato — 0)',
      () {
        final problems = <String>[];
        var students = 0;
        for (final a in ready) {
          final source = variant ? a.variantPool : a.fixed;
          if (variant && !variantAllowed(source.length, a.perStudent)) {
            problems.add('${a.deck.id}: variant mumkin emas');
            continue;
          }
          final ids = [for (final q in source) q.id];
          final key = [for (final q in source) q.correct.single];
          final topics = [for (final q in source) variantTopic(q.topicIds)];
          for (final (aid, uid) in pairs) {
            final info = GroupAssignment(
              id: aid,
              groupId: 'g',
              title: 't',
              questionIds: ids,
              dueAt: null,
              timeLimitMinutes: null,
              createdAt: DateTime.utc(2026, 10, 18),
              perStudent: variant ? a.perStudent : null,
              poolTopics: variant ? topics : null,
            );
            final mine = info.questionIdsFor(uid);
            if (mine.length != (variant ? a.perStudent : ids.length) ||
                mine.toSet().length != mine.length ||
                !mine.every(ids.contains)) {
              problems.add('${a.deck.id}/$uid: to‘plam');
              continue;
            }
            students++;
            // Talaba ilovasi: AssignmentDetail._start kabi.
            final questions = [for (final id in mine) index[id]!];
            for (final right in [true, false]) {
              final s = ExamSession.build(
                id: '$aid-$uid',
                mode: ExamMode.assignment,
                questions: questions,
                shuffleOptions: !questions.any((q) => q is OfficialKeyQuestion),
                random: Random(uid.hashCode ^ (right ? 1 : 2)),
                startedAt: DateTime.utc(2026, 10, 18),
                assignmentId: aid,
                userId: uid,
              );
              for (var i = 0; i < s.length; i++) {
                final it = s.current;
                s.choose(
                  right
                      ? it.order.indexOf(it.correct.single)
                      : it.order.indexWhere((o) => o != it.correct.single),
                );
                s.next();
              }
              final r = _serverScore(
                pool: ids,
                key: key,
                mine: mine,
                variant: variant,
                answers: s.submissionAnswers(),
                answerIds: s.submissionQuestionIds(),
              );
              final want = right ? r.total : 0;
              if (r.score != want || r.total != mine.length) {
                problems.add(
                  '${a.deck.id}/$uid: ball ${r.score}/${r.total}, '
                  'kutilgan $want',
                );
              }
              // Ilova o'zi hisoblagan ball ham server bilan bir xil.
              if (s.correctCount != r.score) {
                problems.add(
                  '${a.deck.id}/$uid: ilova ${s.correctCount} ≠ '
                  'server ${r.score}',
                );
              }
            }
            // Natijalar (ustoz): har savol bo'yicha hisob — faqat tushganlar.
            final sub = GroupSubmission(
              assignmentId: aid,
              userId: uid,
              score: mine.length,
              total: mine.length,
              submittedAt: DateTime.utc(2026, 10, 18),
              answers: [for (final id in mine) key[ids.indexOf(id)]],
              correct: List.filled(mine.length, true),
              questionIds: variant ? mine : null,
            );
            final tally = tallyQuestions(info, [sub], key);
            final received = tally.fold<int>(0, (n, t) => n + t.received);
            if (received != mine.length) {
              problems.add('${a.deck.id}/$uid: natija jadvali $received');
            }
            for (final t in tally) {
              if (t.received > 0 && index[t.questionId] == null) {
                problems.add('${a.deck.id}: natijada ${t.questionId} yo‘q');
              }
            }
          }
        }
        expect(problems, isEmpty);
        expect(students, greaterThan(500));
      },
    );
  }

  test('dars jadvalidagi mavzu testi (“Testni boshlash”): har mavzu — '
      'sarlavha, id, kalit server qabul qiladi; savollar topiladi', () {
    final problems = <String>[];
    var topics = 0;
    for (final t in cur.topics) {
      final pool = testCandidates(t, pack, bank);
      if (pool.isEmpty) continue;
      topics++;
      if (!server.topicRe.hasMatch(t.id)) problems.add('${t.id}: topic id');
      for (final lang in ['uz', 'ru', 'en']) {
        final title = classroomTestTitle(
          lookupAppLocalizations(Locale(lang)),
          t,
          lang,
        );
        if (title.length < 3 || title.length > server.titleMax) {
          problems.add('${t.id}/$lang: sarlavha ${title.length}');
        }
      }
      for (final q in pool) {
        if (!server.idRe.hasMatch(q.id)) problems.add('${t.id}: id ${q.id}');
        if (index[q.id] == null) problems.add('${t.id}/${q.id}: indeksda yo‘q');
        final k = q.correct.single;
        if (k < 0 || k > server.maxKey || k >= q.optionCount) {
          problems.add('${t.id}/${q.id}: kalit');
        }
      }
    }
    expect(problems, isEmpty);
    expect(topics, greaterThan(100));
  });

  test('Worker fixture (real_deck_assignments.json) asset bilan bir xil', () {
    final decks = [
      for (final a in ready)
        {
          'deck_id': a.deck.id,
          'day_id': a.dayId,
          'title': topicAssignmentTitle(
            lookupAppLocalizations(const Locale('uz')),
            a.deck,
            'uz',
          ),
          'question_ids': [for (final q in a.variantPool) q.id],
          'correct_indexes': [for (final q in a.variantPool) q.correct.single],
          'option_counts': [for (final q in a.variantPool) q.optionCount],
          'pool_topics': [
            for (final q in a.variantPool) variantTopic(q.topicIds),
          ],
          'per_student': a.perStudent,
          // Dart variant tanlovi (umumiy vektor juftlari): Worker ham aynan
          // shuni berishi shart.
          'draws': [
            for (final (aid, uid) in pairs.take(3))
              {
                'assignment_id': aid,
                'user_id': uid,
                'expected': drawVariant(
                  assignmentId: aid,
                  userId: uid,
                  pool: [for (final q in a.variantPool) q.id],
                  poolTopics: [
                    for (final q in a.variantPool) variantTopic(q.topicIds),
                  ],
                  count: a.perStudent,
                ),
              },
          ],
        },
    ];
    // Bir deck — bir qator (diff o'qiladigan, fayl ixcham).
    final comment = jsonEncode(
      'Generated by test/guards/classroom_real_assets_guard_test.dart from '
      'the real bundled assets (every deck with a ready topic test). '
      'Regenerate: LG_WRITE_FIXTURES=1 flutter test '
      'test/guards/classroom_real_assets_guard_test.dart',
    );
    final want =
        '{"_comment": $comment,\n"decks": [\n'
        '${decks.map(jsonEncode).join(',\n')}\n]}';
    final file = File(_fixture);
    if (Platform.environment['LG_WRITE_FIXTURES'] == '1') {
      file.writeAsStringSync('$want\n');
    }
    expect(
      file.existsSync() ? file.readAsStringSync().trimRight() : '',
      want,
      reason: 'fixture eskirgan — LG_WRITE_FIXTURES=1 bilan qayta yozing',
    );
  });
}
