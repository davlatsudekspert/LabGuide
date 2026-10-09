import 'dart:math';

import 'package:flutter/foundation.dart';

import 'exam_question.dart';

/// Imtihon turi: oddiy (vaqtli), xatolarni qayta ishlash (vaqtsiz) yoki
/// guruh topshirig'i (ball serverda hisoblanadi).
enum ExamMode { exam, rework, assignment }

/// Imtihondagi bitta savol: savol id si, variantlarning ekrandagi tartibi,
/// to'g'ri javob(lar) va mavzular — boshlanganda manbadan yoziladi.
@immutable
class ExamItem {
  const ExamItem({
    required this.questionId,
    required this.order,
    required this.correct,
    required this.position,
    this.topicIds = const [],
  });

  factory ExamItem.fromJson(Map<String, Object?> j) {
    final c = j['c'];
    return ExamItem(
      questionId: j['q']! as String,
      order: (j['o']! as List).cast<int>(),
      correct: c is int ? [c] : (c! as List).cast<int>(),
      position: j['p']! as int,
      topicIds: (j['t'] as List? ?? const []).cast<String>(),
    );
  }

  final String questionId;

  /// Ekrandagi i-variant → asl variant indeksi.
  final List<int> order;

  /// To'g'ri variant(lar), asl indekslar, o'sish tartibida.
  final List<int> correct;

  /// Berilgan ro'yxatdagi asl o'rni (topshiriq javoblari shu tartibda
  /// serverga yuboriladi).
  final int position;

  /// Mavzu bo'yicha tahlil uchun.
  final List<String> topicIds;

  /// Bir nechta to'g'ri javobli savol (variantlar belgilanadi).
  bool get multi => correct.length > 1;

  Map<String, Object?> toJson() => {
    'q': questionId,
    'o': order,
    'c': correct,
    'p': position,
    't': topicIds,
  };
}

/// Mavzu bo'yicha natija.
@immutable
class TopicScore {
  const TopicScore(this.topicId, this.correct, this.total);

  final String topicId;
  final int correct;
  final int total;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();
}

/// Savollar to'plamidan tasodifiy [count] tasini tanlaydi.
List<T> drawQuestions<T>(List<T> pool, int count, Random random) {
  final copy = List.of(pool)..shuffle(random);
  return copy.take(count.clamp(0, copy.length)).toList();
}

/// Imtihon holati: javoblar asl variant indekslarida saqlanadi (variantlar
/// aralashtirilgan bo'lsa ham ball to'g'ri hisoblanadi). Vaqt devor soati
/// bo'yicha — ilova yopilsa ham to'xtamaydi.
class ExamSession {
  ExamSession({
    required this.id,
    required this.mode,
    required this.items,
    required this.startedAt,
    this.sourceId = PackQuestionSource.sourceId,
    this.limit,
    this.deadline,
    this.topicIds = const [],
    this.title,
    this.assignmentId,
    this.groupId,
    this.userId,
    List<List<int>?>? answers,
    Set<int>? flags,
    this._index = 0,
    this._finishedAt,
    this._timedOut = false,
  }) : _answers = answers ?? List<List<int>?>.filled(items.length, null),
       flags = flags ?? <int>{};

  /// Yangi sessiya: savollar va har savol variantlari aralashtiriladi.
  factory ExamSession.build({
    required String id,
    required ExamMode mode,
    required List<ExamQuestion> questions,
    required Random random,
    required DateTime startedAt,
    String sourceId = PackQuestionSource.sourceId,
    Duration? limit,
    DateTime? hardDeadline,
    List<String> topicIds = const [],
    String? title,
    String? assignmentId,
    String? groupId,
    String? userId,
  }) {
    final items = [
      for (final (i, q) in questions.indexed)
        ExamItem(
          questionId: q.id,
          order: List.generate(q.optionCount, (k) => k)..shuffle(random),
          correct: q.correct.toList()..sort(),
          position: i,
          topicIds: q.topicIds,
        ),
    ]..shuffle(random);
    DateTime? deadline = limit == null ? null : startedAt.add(limit);
    if (hardDeadline != null &&
        (deadline == null || hardDeadline.isBefore(deadline))) {
      deadline = hardDeadline;
    }
    return ExamSession(
      id: id,
      mode: mode,
      items: items,
      startedAt: startedAt,
      sourceId: sourceId,
      limit: limit,
      deadline: deadline,
      topicIds: topicIds,
      title: title,
      assignmentId: assignmentId,
      groupId: groupId,
      userId: userId,
    );
  }

  factory ExamSession.fromJson(Map<String, Object?> j) {
    final items = [
      for (final i in j['items']! as List)
        ExamItem.fromJson((i as Map).cast<String, Object?>()),
    ];
    final answers = [
      for (final a in j['answers']! as List)
        switch (a) {
          null => null,
          final int one => [one],
          final List<Object?> many => many.cast<int>(),
          _ => throw const FormatException('answer'),
        },
    ];
    if (answers.length != items.length) {
      throw const FormatException('answers length');
    }
    DateTime? date(String k) =>
        j[k] == null ? null : DateTime.parse(j[k]! as String);
    return ExamSession(
      id: j['id']! as String,
      mode: ExamMode.values.byName(j['mode']! as String),
      items: items,
      startedAt: DateTime.parse(j['started']! as String),
      sourceId: j['source'] as String? ?? PackQuestionSource.sourceId,
      limit: (j['limit'] as int?) == null
          ? null
          : Duration(seconds: j['limit']! as int),
      deadline: date('deadline'),
      topicIds: (j['topics'] as List? ?? const []).cast<String>(),
      title: j['title'] as String?,
      assignmentId: j['assignment'] as String?,
      groupId: j['group'] as String?,
      userId: j['user'] as String?,
      answers: answers,
      flags: (j['flags'] as List? ?? const []).cast<int>().toSet(),
      index: (j['index'] as int? ?? 0).clamp(0, max(0, items.length - 1)),
      finishedAt: date('finished'),
      timedOut: j['timedOut'] as bool? ?? false,
    );
  }

  final String id;
  final ExamMode mode;
  final List<ExamItem> items;
  final DateTime startedAt;

  /// Savollar banki ([ExamQuestionSource.id]).
  final String sourceId;

  /// Berilgan vaqt (bo'lmasa — vaqtsiz).
  final Duration? limit;

  /// Avtomatik yakunlanish vaqti (vaqt chegarasi yoki topshiriq muddati).
  final DateTime? deadline;

  /// Tanlangan mavzular (bo'sh — hammasi).
  final List<String> topicIds;

  /// Topshiriq nomi (oddiy imtihonda — mavzulardan quriladi).
  final String? title;
  final String? assignmentId;
  final String? groupId;

  /// Topshiriqni boshlagan hisob (boshqa hisobga ko'rsatilmaydi).
  final String? userId;

  /// Har savolga tanlangan asl variant(lar), o'sish tartibida (javobsiz —
  /// null).
  final List<List<int>?> _answers;
  final Set<int> flags;
  int _index;
  DateTime? _finishedAt;
  bool _timedOut;

  int get index => _index;
  int get length => items.length;
  ExamItem get current => items[_index];
  bool get isFirst => _index == 0;
  bool get isLast => _index == items.length - 1;
  bool get finished => _finishedAt != null;
  DateTime? get finishedAt => _finishedAt;
  bool get timedOut => _timedOut;

  /// Tanlangan asl variantlar (javobsiz — null).
  List<int>? answerAt(int i) => _answers[i];
  bool isAnswered(int i) => _answers[i] != null;

  /// Ekrandagi variant tanlanganmi.
  bool isSelected(int i, int displayIndex) =>
      _answers[i]?.contains(items[i].order[displayIndex]) ?? false;

  /// Joriy savolga javob (yakunlangach o'zgarmaydi). Bitta to'g'ri javobli
  /// savolda tanlov almashtiriladi; ko'p javoblida — belgilanadi/olinadi.
  void choose(int displayIndex) {
    if (finished) return;
    final item = current;
    RangeError.checkValidIndex(displayIndex, item.order, 'displayIndex');
    final option = item.order[displayIndex];
    if (!item.multi) {
      _answers[_index] = [option];
      return;
    }
    final next = {...?_answers[_index]};
    if (!next.remove(option)) next.add(option);
    _answers[_index] = next.isEmpty ? null : (next.toList()..sort());
  }

  void toggleFlag() {
    if (finished) return;
    if (!flags.remove(_index)) flags.add(_index);
  }

  bool isFlagged(int i) => flags.contains(i);

  void goTo(int i) {
    if (i < 0 || i >= items.length) return;
    _index = i;
  }

  void next() => goTo(_index + 1);
  void previous() => goTo(_index - 1);

  int get answeredCount => _answers.where((a) => a != null).length;
  int get unansweredCount => items.length - answeredCount;

  /// Qolgan vaqt (vaqtsiz bo'lsa null). Manfiy bo'lmaydi.
  Duration? remaining(DateTime now) {
    final d = deadline;
    if (d == null) return null;
    final left = d.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool expired(DateTime now) {
    final d = deadline;
    return d != null && !now.isBefore(d);
  }

  /// Yakunlash. Vaqt tugagan bo'lsa yakun vaqti — muddatning o'zi (ilova
  /// yopiq paytda tugagan bo'lsa ham sarflangan vaqt oshib ketmaydi).
  void finish(DateTime now, {bool timedOut = false}) {
    if (finished) return;
    _timedOut = timedOut;
    _finishedAt = timedOut && deadline != null && deadline!.isBefore(now)
        ? deadline
        : now;
  }

  Duration spent(DateTime now) {
    final end = _finishedAt ?? now;
    final d = end.difference(startedAt);
    return d.isNegative ? Duration.zero : d;
  }

  /// To'liq mos kelgandagina to'g'ri (ko'p javobli savolda ham).
  bool isCorrect(int i) => listEquals(_answers[i], items[i].correct);

  int get correctCount {
    var n = 0;
    for (var i = 0; i < items.length; i++) {
      if (isCorrect(i)) n++;
    }
    return n;
  }

  /// Javob berilgan, lekin noto'g'ri.
  int get wrongCount => answeredCount - correctCount;

  /// Foiz (0–100, butun).
  int get percent =>
      items.isEmpty ? 0 : (correctCount * 100 / items.length).round();

  /// Xato yoki javobsiz qolgan savollar (ekrandagi tartibda).
  List<int> get mistakeIndexes => [
    for (var i = 0; i < items.length; i++)
      if (!isCorrect(i)) i,
  ];

  /// Mavzu bo'yicha natija (savol bir nechta mavzuga tegishli bo'lsa —
  /// har birida hisoblanadi). Eng zaif mavzu birinchi.
  List<TopicScore> topicBreakdown() {
    final right = <String, int>{};
    final total = <String, int>{};
    for (var i = 0; i < items.length; i++) {
      for (final t in items[i].topicIds) {
        total[t] = (total[t] ?? 0) + 1;
        if (isCorrect(i)) right[t] = (right[t] ?? 0) + 1;
      }
    }
    return [
      for (final e in total.entries)
        TopicScore(e.key, right[e.key] ?? 0, e.value),
    ]..sort((a, b) {
      final c = a.percent.compareTo(b.percent);
      return c != 0 ? c : b.total.compareTo(a.total);
    });
  }

  /// Serverga yuboriladigan javoblar: berilgan (topshiriq) tartibida,
  /// javobsiz savol — -1. Topshiriq savollari bitta javobli.
  List<int> submissionAnswers() {
    final out = List<int>.filled(items.length, -1);
    for (var i = 0; i < items.length; i++) {
      final a = _answers[i];
      out[items[i].position] = a == null || a.isEmpty ? -1 : a.first;
    }
    return out;
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'mode': mode.name,
    'source': sourceId,
    'items': [for (final i in items) i.toJson()],
    'started': startedAt.toUtc().toIso8601String(),
    'limit': limit?.inSeconds,
    'deadline': deadline?.toUtc().toIso8601String(),
    'topics': topicIds,
    'title': title,
    'assignment': assignmentId,
    'group': groupId,
    'user': userId,
    'answers': _answers,
    'flags': flags.toList()..sort(),
    'index': _index,
    'finished': _finishedAt?.toUtc().toIso8601String(),
    'timedOut': _timedOut,
  };
}
