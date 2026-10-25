/// Talaba Pro (D-78): imtihon simulyatsiyasi va natijalar tahlili uchun sof
/// mantiq (UI siz, unit testlanadi). Faqat qurilmadagi natijalar tarixidan
/// (`ExamController.history`) — hech narsa o'chirilmaydi yoki
/// yashirilmaydi.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../learn/exam_question.dart';
import '../learn/exam_session.dart';

/// Mavzular bo'yicha MUVOZANATLI tanlov: har mavzudan savollar mavzu
/// hajmiga mutanosib (eng katta qoldiq usuli), mavzusiz savollar alohida
/// guruh; har guruh ichida tasodifiy. Natija — aralashtirilgan, takrorsiz.
List<ExamQuestion> drawBalanced(
  List<ExamQuestion> pool,
  int count,
  Random random,
) {
  final n = count.clamp(0, pool.length);
  if (n == 0) return const [];
  final groups = <String, List<ExamQuestion>>{};
  for (final q in pool) {
    (groups[q.topicIds.firstOrNull ?? ''] ??= []).add(q);
  }
  final keys = groups.keys.toList()..sort();
  for (final k in keys) {
    groups[k]!.shuffle(random);
  }
  final quota = <String, int>{};
  final rest = <(String, double)>[];
  var used = 0;
  for (final k in keys) {
    final exact = groups[k]!.length * n / pool.length;
    final whole = exact.floor();
    quota[k] = whole;
    used += whole;
    rest.add((k, exact - whole));
  }
  rest.sort((a, b) {
    final c = b.$2.compareTo(a.$2);
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  for (final (k, _) in rest) {
    if (used >= n) break;
    if (quota[k]! < groups[k]!.length) {
      quota[k] = quota[k]! + 1;
      used++;
    }
  }
  final out = <ExamQuestion>[
    for (final k in keys) ...groups[k]!.take(quota[k]!),
  ]..shuffle(random);
  return out;
}

/// Mavzu bo'yicha jamlangan natija (bir nechta sessiya bo'ylab).
@immutable
class TopicTrend {
  const TopicTrend({
    required this.sourceId,
    required this.topicId,
    required this.correct,
    required this.total,
    required this.sessions,
    this.earlyPercent,
    this.recentPercent,
  });

  final String sourceId;
  final String topicId;
  final int correct;
  final int total;

  /// Mavzu uchragan sessiyalar soni.
  final int sessions;

  /// Eski yarmi va yangi yarmi aniqligi (kamida 2 sessiya bo'lsa).
  final int? earlyPercent;
  final int? recentPercent;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  /// Yangi − eski (foiz punkti); `null` — taqqoslash uchun kam.
  int? get delta => earlyPercent == null || recentPercent == null
      ? null
      : recentPercent! - earlyPercent!;

  /// Zaif mavzu: kamida [minQuestions] savol va aniqlik [threshold] % dan past.
  bool weak({int minQuestions = 5, int threshold = 60}) =>
      total >= minQuestions && percent < threshold;
}

/// Natijalar tahlili: sessiyalar (eng yangisi birinchi, tarix tartibi).
@immutable
class ResultsAnalytics {
  const ResultsAnalytics(this.sessions);

  /// Eng yangisi birinchi.
  final List<ExamSession> sessions;

  bool get isEmpty => sessions.isEmpty;

  int get average => sessions.isEmpty
      ? 0
      : (sessions.map((s) => s.percent).reduce((a, b) => a + b) /
                sessions.length)
            .round();

  int get best => sessions.isEmpty
      ? 0
      : sessions.map((s) => s.percent).reduce(max);

  int get last => sessions.isEmpty ? 0 : sessions.first.percent;

  int get totalQuestions => sessions.fold(0, (a, s) => a + s.length);
  int get totalCorrect => sessions.fold(0, (a, s) => a + s.correctCount);

  /// So'nggi [window] ta o'rtachasi − undan oldingi [window] ta o'rtachasi
  /// (foiz punkti); `null` — kamida 2 ta sessiya kerak.
  int? trend({int window = 5}) {
    if (sessions.length < 2) return null;
    final w = min(window, sessions.length ~/ 2);
    double avg(Iterable<ExamSession> s) =>
        s.map((e) => e.percent).reduce((a, b) => a + b) / s.length;
    final recent = sessions.take(w);
    final before = sessions.skip(w).take(w);
    return (avg(recent) - avg(before)).round();
  }

  /// Mavzular bo'yicha (manba + mavzu), eng zaifi birinchi.
  List<TopicTrend> topics() {
    final chronological = sessions.reversed.toList();
    final byKey = <(String, String), List<(int, int)>>{};
    for (final s in chronological) {
      for (final t in s.topicBreakdown()) {
        (byKey[(s.sourceId, t.topicId)] ??= []).add((t.correct, t.total));
      }
    }
    int pct(Iterable<(int, int)> xs) {
      final c = xs.fold(0, (a, x) => a + x.$1);
      final t = xs.fold(0, (a, x) => a + x.$2);
      return t == 0 ? 0 : (c * 100 / t).round();
    }

    final out = <TopicTrend>[
      for (final e in byKey.entries)
        TopicTrend(
          sourceId: e.key.$1,
          topicId: e.key.$2,
          correct: e.value.fold(0, (a, x) => a + x.$1),
          total: e.value.fold(0, (a, x) => a + x.$2),
          sessions: e.value.length,
          earlyPercent: e.value.length < 2
              ? null
              : pct(e.value.take(e.value.length ~/ 2)),
          recentPercent: e.value.length < 2
              ? null
              : pct(e.value.skip(e.value.length ~/ 2)),
        ),
    ];
    out.sort((a, b) {
      final c = a.percent.compareTo(b.percent);
      return c != 0 ? c : b.total.compareTo(a.total);
    });
    return out;
  }

  List<TopicTrend> weakTopics() => [
    for (final t in topics())
      if (t.weak()) t,
  ];
}

/// Simulyatsiya hisobotining vaqt qismi.
@immutable
class SimulationPace {
  const SimulationPace({
    required this.spent,
    required this.average,
    required this.slowest,
  });

  factory SimulationPace.of(ExamSession s) {
    final spent = s.spent(s.finishedAt ?? s.startedAt);
    final times = [
      for (var i = 0; i < s.length; i++) (i, s.timeAt(i) ?? Duration.zero),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return SimulationPace(
      spent: spent,
      average: s.length == 0
          ? Duration.zero
          : Duration(seconds: (spent.inSeconds / s.length).round()),
      slowest: times.take(5).where((t) => t.$2 > Duration.zero).toList(),
    );
  }

  final Duration spent;

  /// Bir savolga o'rtacha.
  final Duration average;

  /// Eng ko'p vaqt olgan savollar: (ekrandagi indeks, vaqt).
  final List<(int, Duration)> slowest;
}

/// Shu bankdagi oldingi simulyatsiya (taqqoslash uchun).
ExamSession? previousSimulation(List<ExamSession> history, ExamSession s) {
  final at = history.indexOf(s);
  if (at < 0) return null;
  return history
      .skip(at + 1)
      .where((h) => h.simulation && h.sourceId == s.sourceId)
      .firstOrNull;
}
