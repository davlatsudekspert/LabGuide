import '../content/content_model.dart';
import '../learn/exam_question.dart';
import '../toifa/toifa_bank.dart';
import 'curriculum.dart';

// Mavzu testi va og'zaki savol-javob uchun savollar: kontent paketi mashq
// savollari va toifa banki. Curriculum'dagi id lar avtomatik tanlangan
// NOMZODLAR — kalitlari tekshirilmagan; ustoz ko'rib tanlaydi, ilova
// ularni o'zi “to'g'ri” deb belgilamaydi.

/// Guruh topshirig'idagi savolni id bo'yicha topish: paket + toifa banki
/// (rasmiy kaliti bor savollar).
Map<String, ExamQuestion> classQuestionIndex(
  ContentPack? pack,
  ToifaBank? bank,
) => {
  if (pack != null)
    for (final q in PackQuestionSource.of(pack).questions) q.id: q,
  if (bank != null)
    for (final q in bank.scorable) q.id: q,
};

/// Guruh topshirig'i uchun aralash bank (paket + toifa): mavzu testida
/// ikkala bankdan savol bo'lishi mumkin. Imtihon sessiyasi shu id bilan
/// saqlanadi.
class ClassQuestionSource implements ExamQuestionSource {
  ClassQuestionSource._(this.pack, this.bank)
    : _byId = classQuestionIndex(pack, bank);

  static const sourceId = 'class';

  /// Paket/bank o'zgarmaguncha bitta manba qayta ishlatiladi.
  static ClassQuestionSource of(ContentPack pack, ToifaBank? bank) =>
      identical(_last?.pack, pack) && identical(_last?.bank, bank)
      ? _last!
      : (_last = ClassQuestionSource._(pack, bank));
  static ClassQuestionSource? _last;

  final ContentPack pack;
  final ToifaBank? bank;
  final Map<String, ExamQuestion> _byId;

  @override
  String get id => sourceId;
  @override
  List<ExamQuestion> get questions => _byId.values.toList(growable: false);
  @override
  ExamQuestion? question(String id) => _byId[id];

  /// Natija tahlilida mavzular ko'rsatilmaydi (topshiriq — bitta mavzu).
  @override
  List<ExamTopic> get topics => const [];
}

/// Server kaliti har savolga bitta javob saqlaydi.
bool assignable(ExamQuestion q) => q.correct.length == 1;

/// Test uchun nomzodlar: avval curriculum ro'yxati; bo'lmasa — havolalar
/// bo'yicha (analitlar → paket savollari, toifa mavzusi → toifa testlari).
List<ExamQuestion> testCandidates(
  CurriculumTopic topic,
  ContentPack? pack,
  ToifaBank? bank,
) {
  final out = <ExamQuestion>[];
  final seen = <String>{};
  void add(ExamQuestion? q) {
    if (q != null && assignable(q) && seen.add(q.id)) out.add(q);
  }

  if (bank != null) {
    if (topic.testCandidates.isNotEmpty) {
      for (final id in topic.testCandidates) {
        final q = bank.test(id);
        if (q != null && q.scorable) add(q);
      }
    } else if (topic.links.toifaTopic case final t?) {
      for (final q in bank.scorable) {
        if (q.topic == t) add(q);
      }
    }
  }
  if (pack != null) {
    final source = PackQuestionSource.of(pack);
    if (topic.packQuizCandidates.isNotEmpty) {
      for (final id in topic.packQuizCandidates) {
        add(source.question(id));
      }
    } else if (topic.links.analytes.isNotEmpty) {
      final analytes = topic.links.analytes.toSet();
      for (final q in pack.quiz) {
        if (q.topicIds.any(analytes.contains)) add(source.question(q.id));
      }
    }
  }
  return out;
}

/// Og'zaki savol-javob uchun nomzodlar (toifa og'zaki banki).
List<ToifaOralQuestion> oralCandidates(CurriculumTopic topic, ToifaBank? bank) {
  if (bank == null) return const [];
  if (topic.oralCandidates.isNotEmpty) {
    return [for (final id in topic.oralCandidates) ?bank.oralQuestion(id)];
  }
  final t = topic.links.toifaTopic;
  if (t == null) return const [];
  return [
    for (final q in bank.oral)
      if (q.topic == t && q.held == null) q,
  ];
}
