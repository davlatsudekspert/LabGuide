import 'package:flutter/foundation.dart';

import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';

/// Imtihon dvigateli uchun savol: qaysi bankdan kelishidan qat'i nazar
/// (kontent paketidagi mashq savollari, keyinchalik — toifa imtihoni banki
/// va h.k.). Bir yoki bir nechta to'g'ri javob bo'lishi mumkin.
abstract interface class ExamQuestion {
  String get id;
  String prompt(String lang);
  int get optionCount;
  String option(int index, String lang);

  /// Variant izohi (bankda bo'lmasa — null; UI “izoh yo'q” deydi).
  String? explanation(int index, String lang);

  /// Javob nimaga asoslangani (bo'lmasa — null).
  String? basis(String lang);

  /// To'g'ri variantlar (asl indekslar). Bittadan ko'p bo'lsa — barchasini
  /// tanlash kerak (ball faqat to'liq mos kelganda).
  Set<int> get correct;

  /// Natija tahlili uchun mavzular (manba [ExamQuestionSource.topics] id lari).
  List<String> get topicIds;

  /// Tekshirilmagan (qoralama) — UI “draft” belgisini ko'rsatadi.
  bool get isDraft;

  /// Kontent paketidagi manbalarga havolalar (bo'lmasa — bo'sh).
  List<SourceRef> get refs;
}

/// Tashqi manba havolasi (kontent paketida bo'lmagan banklar uchun).
@immutable
class ExamLink {
  const ExamLink(this.url, [this.locator]);

  final String url;

  /// Manbaning qaysi joyi (bo'lim, jadval) — bo'lmasa null.
  final String? locator;
}

/// Rasmiy kalitni LabGuide tekshirgani: `ok` — kalit to'g'ri; `disputed` —
/// kalit tibbiy jihatdan noto'g'ri yoki belgilanmagan; `ambiguous` — savol
/// noaniq yoki bir nechta javob to'g'ri.
enum KeyVerdict { ok, disputed, ambiguous }

/// Kalit tekshiruvi: ball baribir rasmiy kalit bo'yicha hisoblanadi
/// (imtihonda shu talab qilinadi), izoh esa alohida ko'rsatiladi.
@immutable
class KeyCheck {
  const KeyCheck({
    required this.verdict,
    this.note,
    this.suggested = const [],
    this.links = const [],
    this.unverified = false,
  });

  final KeyVerdict verdict;

  /// Izoh manba bilan tasdiqlanmagan — belgilanadi, taklif javob sifatida
  /// ko'rsatilmaydi.
  final bool unverified;

  /// LabGuide izohi (bo'lmasa — null).
  final String? note;

  /// LabGuide fikricha to'g'ri variant(lar) (asl indekslar; bo'sh — taklif
  /// yo'q).
  final List<int> suggested;

  /// Izoh tayangan manbalar.
  final List<ExamLink> links;

  /// Kalit bahsli yoki noaniq — rasmiy kalit va izoh ikkalasi ko'rsatiladi.
  bool get flagged => verdict != KeyVerdict.ok;
}

/// Ixtiyoriy imkoniyat: rasmiy ro'yxatdan olingan savol. [ExamQuestion.correct]
/// — ro'yxatdagi kalit; [keyCheck] — LabGuide tekshiruvi.
abstract interface class OfficialKeyQuestion implements ExamQuestion {
  KeyCheck get keyCheck;

  /// Ro'yxatdagi tartib raqami (izohlarda “212-savol” kabi havola uchun).
  int get number;
}

extension ExamQuestionKeyX on ExamQuestion {
  /// Rasmiy kalitli savol bo'lsa — tekshiruv, aks holda null.
  KeyCheck? get officialKeyCheck => switch (this) {
    final OfficialKeyQuestion q => q.keyCheck,
    _ => null,
  };
}

/// Mavzu: tanlash chiplari va mavzu bo'yicha natija tahlili uchun.
@immutable
class ExamTopic {
  const ExamTopic(this.id, this.name, this.questions);

  final String id;
  final String Function(AppLocalizations l, String lang) name;
  final List<ExamQuestion> questions;
}

/// Savollar banki. Imtihon sessiyasi faqat [id] va savol id larini
/// saqlaydi — matnlar ko'rsatilayotganda shu manbadan olinadi.
abstract interface class ExamQuestionSource {
  /// Sessiyada saqlanadigan barqaror nom (masalan, `pack`).
  String get id;
  List<ExamQuestion> get questions;
  ExamQuestion? question(String id);

  /// Mavzular — ko'rsatiladigan tartibda, faqat savoli borlari.
  List<ExamTopic> get topics;
}

/// Tanlangan mavzular savollari (bo'sh tanlov — hammasi), takrorsiz.
List<ExamQuestion> examPool(
  ExamQuestionSource source,
  Iterable<String> topicIds,
) {
  final ids = topicIds.toSet();
  if (ids.isEmpty) return List.of(source.questions);
  final seen = <String>{};
  return [
    for (final t in source.topics)
      if (ids.contains(t.id))
        for (final q in t.questions)
          if (seen.add(q.id)) q,
  ];
}

final _unitSlash = RegExp(
  r'(?<=(?<![\p{L}])(?:mmol|µmol|mg|g|ммоль|мкмоль|мг|г))/(?=(?:L|dL|mol|л|дл|моль)(?![\p{L}]))',
  unicode: true,
);
final _numUnit = RegExp(
  r'(?<=\d) (?=(?:mmol|µmol|mg|g|ммоль|мкмоль|мг|г)/)',
  unicode: true,
);

/// Birlik ("mmol/L", "mg/dL") satr oxirida "mmol/" + "L" ga bo'linib
/// qolmasligi uchun: "/" dan keyin so'z biriktiruvchi, raqam bilan birlik
/// orasida bo'linmaydigan bo'shliq. Faqat ko'rsatish uchun.
String keepUnitsTogether(String s) =>
    s.replaceAll(_numUnit, '\u00A0').replaceAll(_unitSlash, '/\u2060');

/// Kontent paketidagi mashq savoli (bitta to'g'ri javob).
class PackExamQuestion implements ExamQuestion {
  PackExamQuestion(this.quiz, this.topicIds);

  final QuizQuestion quiz;
  @override
  final List<String> topicIds;

  @override
  String get id => quiz.id;
  @override
  String prompt(String lang) => keepUnitsTogether(quiz.prompt.of(lang));
  @override
  int get optionCount => quiz.options.length;
  @override
  String option(int index, String lang) =>
      keepUnitsTogether(quiz.options[index].text.of(lang));
  @override
  String? explanation(int index, String lang) =>
      keepUnitsTogether(quiz.options[index].explanation.of(lang));
  @override
  String? basis(String lang) => keepUnitsTogether(quiz.basis.of(lang));
  @override
  Set<int> get correct => {quiz.correctIndex};
  @override
  bool get isDraft => quiz.isDraft;
  @override
  List<SourceRef> get refs => quiz.refs;
}

/// Kontent paketi mashq savollari: mavzular — “Laboratoriya hisoblari”
/// (analitga bog'lanmagan savollar) va analitlar guruhlari.
class PackQuestionSource implements ExamQuestionSource {
  PackQuestionSource(this.pack) {
    final groupOf = {for (final a in pack.analytes) a.id: a.group};
    final groupIds = {for (final g in pack.groups) g.id};
    for (final q in pack.quiz) {
      final topics = q.topicIds.isEmpty
          ? const [generalTopic]
          : {
              for (final t in q.topicIds)
                if (groupIds.contains(t)) t else ?groupOf[t],
            }.toList();
      final e = PackExamQuestion(q, topics);
      _questions.add(e);
      _byId[q.id] = e;
    }
  }

  static const sourceId = 'pack';

  /// Analitga bog'lanmagan (umumiy hisob) savollar mavzusi.
  static const generalTopic = 'general';

  final ContentPack pack;
  final List<PackExamQuestion> _questions = [];
  final Map<String, PackExamQuestion> _byId = {};
  List<ExamTopic>? _topics;

  /// Paket o'zgarmaguncha bitta manba qayta ishlatiladi.
  static PackQuestionSource of(ContentPack pack) => identical(_last?.pack, pack)
      ? _last!
      : (_last = PackQuestionSource(pack));
  static PackQuestionSource? _last;

  @override
  String get id => sourceId;
  @override
  List<ExamQuestion> get questions => _questions;
  @override
  ExamQuestion? question(String id) => _byId[id];

  @override
  List<ExamTopic> get topics => _topics ??= [
    ExamTopic(generalTopic, (l, _) => l.quizTopicGeneral, [
      for (final q in _questions)
        if (q.topicIds.contains(generalTopic)) q,
    ]),
    for (final g in pack.groups)
      ExamTopic(g.id, (_, lang) => g.names.of(lang), [
        for (final q in _questions)
          if (q.topicIds.contains(g.id)) q,
      ]),
  ].where((t) => t.questions.isNotEmpty).toList();
}
