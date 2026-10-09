import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'microscopy_atlas.dart';

/// “Bu nima?” savoli: rasm va atlasdagi 4 ta tur nomi.
@immutable
class MicroQuestion {
  const MicroQuestion({
    required this.image,
    required this.options,
    required this.correctIndex,
  });

  final MicroImage image;
  final List<MicroEntity> options;
  final int correctIndex;

  MicroEntity get answer => options[correctIndex];
}

/// Rasm uchun variantlar: to'g'ri tur + 3 ta chalg'ituvchi. Avval shu
/// bo'limdagi turlar (siydik rasmiga siydik nomlari), yetmasa — boshqa
/// bo'limlardan. Hammasi atlasdagi, mashqqa yaroqli turlar.
MicroQuestion buildMicroQuestion(
  MicroAtlas atlas,
  MicroImage image,
  math.Random random,
) {
  final correct = atlas.entity(image.entityId)!;
  final section = atlas.sectionOf(correct).id;
  final pool = [
    for (final e in atlas.entities)
      if (e.quiz && e.id != correct.id) e,
  ];
  final same = [
    for (final e in pool)
      if (atlas.sectionOf(e).id == section) e,
  ]..shuffle(random);
  final other = [
    for (final e in pool)
      if (atlas.sectionOf(e).id != section) e,
  ]..shuffle(random);
  final distractors = [
    ...same,
    ...other,
  ].take(MicroAtlas.optionsPerQuestion - 1).toList();
  final options = [correct, ...distractors]..shuffle(random);
  return MicroQuestion(
    image: image,
    options: List.unmodifiable(options),
    correctIndex: options.indexOf(correct),
  );
}

/// Mashq raundi. Natija faqat foydalanuvchining haqiqiy javoblaridan;
/// har savolga bir marta javob beriladi.
class MicroQuizSession {
  MicroQuizSession(List<MicroQuestion> questions)
    : questions = List.unmodifiable(questions),
      _answers = List<int?>.filled(questions.length, null) {
    if (questions.isEmpty) throw ArgumentError('empty quiz');
  }

  /// Bo'lim (yoki hammasi) bo'yicha tasodifiy raund. [only] berilsa —
  /// faqat shu rasmlar (masalan, xatolarni qayta ishlash).
  factory MicroQuizSession.build(
    MicroAtlas atlas, {
    String? sectionId,
    int limit = defaultLength,
    Iterable<String>? only,
    math.Random? random,
  }) {
    final rnd = random ?? math.Random();
    final ids = only?.toSet();
    final pool = [
      for (final i in atlas.quizImages(sectionId: sectionId))
        if (ids == null || ids.contains(i.id)) i,
    ]..shuffle(rnd);
    return MicroQuizSession([
      for (final i in pool.take(limit)) buildMicroQuestion(atlas, i, rnd),
    ]);
  }

  /// Bitta raunddagi savollar soni (rasm yetarli bo'lsa).
  static const defaultLength = 10;

  final List<MicroQuestion> questions;
  final List<int?> _answers;
  int _index = 0;
  bool _finished = false;
  int _streak = 0;
  int _bestStreak = 0;

  int get index => _index;
  bool get finished => _finished;
  MicroQuestion get current => questions[_index];
  bool get isLast => _index == questions.length - 1;
  int? answerFor(int i) => _answers[i];
  bool get answered => _answers[_index] != null;

  /// Ketma-ket to'g'ri javoblar (joriy va eng uzun).
  int get streak => _streak;
  int get bestStreak => _bestStreak;

  /// Javob qabul qilinsa `true` (qayta javob e'tiborsiz).
  bool answer(int option) {
    if (_finished || _answers[_index] != null) return false;
    RangeError.checkValidIndex(option, current.options, 'option');
    _answers[_index] = option;
    if (option == current.correctIndex) {
      _streak++;
      _bestStreak = math.max(_bestStreak, _streak);
    } else {
      _streak = 0;
    }
    return true;
  }

  bool? get lastCorrect {
    final a = _answers[_index];
    return a == null ? null : a == current.correctIndex;
  }

  /// Javob berilmagan savoldan o'tib bo'lmaydi.
  void next() {
    if (_finished || _answers[_index] == null) return;
    if (isLast) {
      _finished = true;
    } else {
      _index++;
    }
  }

  int get correctCount {
    var n = 0;
    for (var i = 0; i < questions.length; i++) {
      if (_answers[i] == questions[i].correctIndex) n++;
    }
    return n;
  }

  /// Xato javoblar: savol va tanlangan variant.
  List<(MicroQuestion, MicroEntity)> get mistakes => [
    for (var i = 0; i < questions.length; i++)
      if (_answers[i] != null && _answers[i] != questions[i].correctIndex)
        (questions[i], questions[i].options[_answers[i]!]),
  ];
}
