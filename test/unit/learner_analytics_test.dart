// Talaba Pro mantig'i (D-78): muvozanatli tanlov, simulyatsiya vaqti va
// JSON (eski yozuvlar bilan moslik), natijalar tahlili (trend, mavzular,
// zaif mavzular), eksport qatorlari.
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/pro/learner_analytics.dart';
import 'package:labguide/features/pro/results_export.dart';

class _Q implements ExamQuestion {
  _Q(this.id, this.topicIds);

  @override
  final String id;
  @override
  final List<String> topicIds;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  int get optionCount => 4;

  @override
  Set<int> get correct => {0};
}

final _t0 = DateTime(2026, 10, 1, 9);

List<_Q> _pool() => [
  for (var i = 0; i < 60; i++) _Q('a$i', ['A']),
  for (var i = 0; i < 30; i++) _Q('b$i', ['B']),
  for (var i = 0; i < 10; i++) _Q('c$i', ['C']),
];

/// [right] — to'g'ri javob berilgan savollar (ekrandagi indeks).
ExamSession _done(
  List<ExamQuestion> qs, {
  required Set<int> right,
  required DateTime at,
  String source = PackQuestionSource.sourceId,
  bool simulation = false,
  int? pass,
}) {
  final s = ExamSession.build(
    id: 'id-${at.millisecondsSinceEpoch}',
    mode: ExamMode.exam,
    questions: qs,
    random: Random(1),
    startedAt: at,
    sourceId: source,
    limit: const Duration(minutes: 30),
    passPercent: pass,
    simulation: simulation,
  );
  for (var i = 0; i < s.length; i++) {
    s.goTo(i);
    final item = s.items[i];
    final want = item.correct.first;
    final display = item.order.indexOf(want);
    s.choose(right.contains(i) ? display : (display + 1) % item.order.length);
  }
  s.finish(at.add(const Duration(minutes: 10)));
  return s;
}

void main() {
  group('drawBalanced', () {
    test('mavzu hajmiga mutanosib, takrorsiz, aniq son', () {
      final pool = _pool();
      final out = drawBalanced(pool, 50, Random(7));
      expect(out, hasLength(50));
      expect(out.map((q) => q.id).toSet(), hasLength(50));
      int n(String t) => out.where((q) => q.topicIds.first == t).length;
      expect(n('A'), 30);
      expect(n('B'), 15);
      expect(n('C'), 5);
    });

    test('qoldiq taqsimoti va chegaralar', () {
      final pool = _pool();
      expect(drawBalanced(pool, 0, Random(1)), isEmpty);
      expect(drawBalanced(pool, 500, Random(1)), hasLength(100));
      final seven = drawBalanced(pool, 7, Random(1));
      expect(seven, hasLength(7));
      expect(seven.map((q) => q.id).toSet(), hasLength(7));
      // Mavzusiz savollar ham guruh sifatida qatnashadi.
      final mixed = [..._pool().take(10), _Q('x', const [])];
      expect(drawBalanced(mixed, 11, Random(1)), hasLength(11));
    });
  });

  group('simulyatsiya sessiyasi', () {
    test('har savol vaqti yoziladi; yakunda joriy savol hisoblanadi', () {
      final qs = _pool().take(3).toList();
      final s = ExamSession.build(
        id: 's1',
        mode: ExamMode.exam,
        questions: qs,
        random: Random(2),
        startedAt: _t0,
        limit: const Duration(minutes: 5),
        passPercent: 70,
        simulation: true,
      );
      expect(s.simulation, isTrue);
      s.markEntered(_t0);
      s.recordDwell(_t0.add(const Duration(seconds: 40)));
      s.goTo(1);
      s.recordDwell(_t0.add(const Duration(seconds: 55)));
      s.goTo(2);
      s.finish(_t0.add(const Duration(seconds: 85)));
      expect(s.timeAt(0), const Duration(seconds: 40));
      expect(s.timeAt(1), const Duration(seconds: 15));
      expect(s.timeAt(2), const Duration(seconds: 30));
      final pace = SimulationPace.of(s);
      expect(pace.spent, const Duration(seconds: 85));
      expect(pace.average, const Duration(seconds: 28));
      expect(pace.slowest.first, (0, const Duration(seconds: 40)));
    });

    test('vaqt tugasa — vaqt muddatgacha hisoblanadi', () {
      final s = ExamSession.build(
        id: 's2',
        mode: ExamMode.exam,
        questions: _pool().take(2).toList(),
        random: Random(2),
        startedAt: _t0,
        limit: const Duration(minutes: 1),
        simulation: true,
      )..markEntered(_t0);
      s.finish(_t0.add(const Duration(hours: 3)), timedOut: true);
      expect(s.timeAt(0), const Duration(minutes: 1));
      expect(s.finishedAt, _t0.add(const Duration(minutes: 1)));
    });

    test('JSON: simulyatsiya maydonlari saqlanadi; eski (bepul) yozuv '
        'o‘zgarmaydi va yangi maydonlarsiz o‘qiladi', () {
      final sim = _done(_pool().take(4).toList(), right: {0, 1}, at: _t0, simulation: true, pass: 50);
      final back = ExamSession.fromJson(
        (jsonDecode(jsonEncode(sim.toJson())) as Map).cast<String, Object?>(),
      );
      expect(back.simulation, isTrue);
      expect(back.timeAt(0), isNotNull);
      expect(back.percent, sim.percent);

      final free = _done(_pool().take(4).toList(), right: {0}, at: _t0);
      final json = free.toJson();
      expect(json.containsKey('sim'), isFalse);
      expect(json.containsKey('times'), isFalse);
      expect(json.containsKey('entered'), isFalse);
      final old = ExamSession.fromJson(
        (jsonDecode(jsonEncode(json)) as Map).cast<String, Object?>(),
      );
      expect(old.simulation, isFalse);
      expect(old.timeAt(0), isNull);
      // Bepul sessiyada vaqt yozuvchi chaqiruvlar hech narsa qilmaydi.
      old.recordDwell(_t0);
      expect(old.timeAt(0), isNull);
    });
  });

  group('natijalar tahlili', () {
    // Eskidan yangiga: A mavzusi yaxshilanadi, C zaif.
    List<ExamSession> history() {
      final qs = [
        for (var i = 0; i < 4; i++) _Q('a$i', ['A']),
        for (var i = 0; i < 2; i++) _Q('c$i', ['C']),
      ];
      final out = <ExamSession>[];
      for (var k = 0; k < 4; k++) {
        final s = _done(qs, right: {}, at: _t0.add(Duration(days: k)));
        // Ekrandagi tartibda: A savollarining k tasi to'g'ri, C — hech qachon.
        final right = <int>{};
        var a = 0;
        for (var i = 0; i < s.length; i++) {
          if (s.items[i].topicIds.first == 'A' && a < k + 1) {
            right.add(i);
            a++;
          }
        }
        out.insert(0, _done(qs, right: right, at: _t0.add(Duration(days: k))));
      }
      return out; // eng yangisi birinchi
    }

    test('o‘rtacha, eng yaxshi, oxirgisi, trend', () {
      final a = ResultsAnalytics(history());
      expect(a.sessions, hasLength(4));
      // Har sessiya 6 savol: 1..4 to'g'ri → 17, 33, 50, 67 %.
      expect([for (final s in a.sessions) s.percent], [67, 50, 33, 17]);
      expect(a.best, 67);
      expect(a.last, 67);
      expect(a.average, 42);
      expect(a.trend(), 34, reason: '(67+50)/2 − (33+17)/2 = 33,5');
      expect(a.totalQuestions, 24);
      expect(a.totalCorrect, 10);
      expect(const ResultsAnalytics([]).trend(), isNull);
    });

    test('mavzular: zaifi birinchi, o‘zgarish, zaif mavzu qoidasi', () {
      final a = ResultsAnalytics(history());
      final topics = a.topics();
      expect([for (final t in topics) t.topicId], ['C', 'A']);
      final c = topics.first;
      expect((c.correct, c.total, c.sessions, c.percent), (0, 8, 4, 0));
      expect(c.weak(), isTrue);
      final at = topics.last;
      expect((at.correct, at.total), (10, 16));
      expect(at.earlyPercent, 38, reason: '(1+2)/8');
      expect(at.recentPercent, 88, reason: '(3+4)/8');
      expect(at.delta, 50);
      expect(at.weak(), isFalse);
      expect([for (final t in a.weakTopics()) t.topicId], ['C']);
    });

    test('oldingi simulyatsiya — shu bankda', () {
      final qs = _pool().take(3).toList();
      final s1 = _done(qs, right: {0}, at: _t0, simulation: true);
      final s2 = _done(qs, right: {0, 1}, at: _t0.add(const Duration(days: 1)));
      final s3 = _done(qs, right: {0, 1, 2}, at: _t0.add(const Duration(days: 2)), simulation: true);
      final h = [s3, s2, s1];
      expect(previousSimulation(h, s3), same(s1));
      expect(previousSimulation(h, s1), isNull);
    });

    test('eksport qatorlari: sessiyalar va mavzular', () {
      final a = ResultsAnalytics(history());
      final rows = resultsCsvRows(a.sessions, title: (s) => '=Test');
      expect(rows.first.first, 'finished_at');
      expect(rows, hasLength(5));
      expect(rows[1][2], "'=Test", reason: 'formula in’eksiyasi');
      expect(rows[1][3], 'exam');
      expect(rows[1][8], '67');
      final topics = topicsCsvRows(a.topics(), topicName: (src, id) => 'T$id');
      expect(topics[1].sublist(0, 3), ['pack', 'C', 'TC']);
      expect(topics[1].last, 'yes');
      expect(signedInt(5), '+5');
      expect(signedInt(-3), '−3');
      expect(signedInt(0), '0');
    });
  });
}
