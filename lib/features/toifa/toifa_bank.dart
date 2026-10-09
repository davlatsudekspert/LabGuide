import 'package:material_ui/material_ui.dart';

import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../learn/exam_question.dart';
import '../settings/settings_controller.dart';

/// Bo'lim faqat O'zbekiston foydalanuvchilariga: ilova tili o'zbekcha yoki
/// qurilma mintaqasi (locale countryCode) — UZ.
bool toifaAvailable(AppLanguage language, Iterable<Locale> deviceLocales) =>
    language == AppLanguage.uz ||
    deviceLocales.any((l) => l.countryCode?.toUpperCase() == 'UZ');

/// Malaka toifasi: og'zaki savollar ro'yxati toifa bo'yicha beriladi.
enum ToifaCategory {
  second('3-2'),
  first('1'),
  highest('oliy');

  const ToifaCategory(this.id);

  /// Ma'lumotdagi id (`3-2`, `1`, `oliy`).
  final String id;

  static ToifaCategory? tryParse(String? id) {
    for (final c in values) {
      if (c.id == id) return c;
    }
    return null;
  }

  String label(AppLocalizations l) => switch (this) {
    ToifaCategory.second => l.toifaCatSecond,
    ToifaCategory.first => l.toifaCatFirst,
    ToifaCategory.highest => l.toifaCatHighest,
  };
}

/// Og'zaki savolga o'z bahosi.
enum OralRating {
  knew,
  partial,
  unknown;

  static OralRating? tryParse(String? name) {
    for (final r in values) {
      if (r.name == name) return r;
    }
    return null;
  }

  String label(AppLocalizations l) => switch (this) {
    OralRating.knew => l.toifaRateKnew,
    OralRating.partial => l.toifaRatePartial,
    OralRating.unknown => l.toifaRateUnknown,
  };
}

List<ExamLink> _links(Object? raw) => [
  for (final r in (raw as List? ?? const []))
    ExamLink((r as Map)['url']! as String, r['locator'] as String?),
];

List<String> _strings(Object? raw) =>
    (raw as List? ?? const []).cast<String>().toList(growable: false);

/// Rasmiy ro'yxatdagi test savoli. Matn faqat o'zbekcha (ro'yxat tili) —
/// interfeys tilidan qat'i nazar shu matn ko'rsatiladi.
class ToifaTestQuestion implements OfficialKeyQuestion {
  ToifaTestQuestion({
    required this.id,
    required this.number,
    required this.text,
    required this.options,
    required this.key,
    required this.topic,
    required this.keyCheck,
    this.analytes = const [],
    this.held,
  });

  factory ToifaTestQuestion.fromJson(Map<String, Object?> j) {
    final verdict = KeyVerdict.values.byName(j['verdict']! as String);
    return ToifaTestQuestion(
      id: j['id']! as String,
      number: j['n']! as int,
      text: j['q']! as String,
      options: _strings(j['options']),
      key: (j['key']! as List).cast<int>().toSet(),
      topic: j['topic']! as String,
      keyCheck: KeyCheck(
        verdict: verdict,
        note: j['note'] as String?,
        suggested: (j['suggested'] as List? ?? const []).cast<int>(),
        links: _links(j['refs']),
        unverified: j['unverified'] == true,
      ),
      analytes: _strings(j['analytes']),
      held: j['held'] as String?,
    );
  }

  @override
  final String id;
  @override
  final int number;
  final String text;
  final List<String> options;

  /// Ro'yxatda belgilangan javob (bo'sh — kalit belgilanmagan).
  final Set<int> key;
  final String topic;
  @override
  final KeyCheck keyCheck;

  /// Bog'liq analit kartalari (paketda bo'lmasa — ko'rsatilmaydi).
  final List<String> analytes;

  /// Aniqlashtirilguncha baholanadigan tanlovdan chiqarilgan (sabab).
  final String? held;

  /// Rasmiy kalit bor va chiqarilmagan — ball hisoblanadigan savol.
  bool get scorable => key.isNotEmpty && held == null;

  @override
  String prompt(String lang) => text;
  @override
  int get optionCount => options.length;
  @override
  String option(int index, String lang) => options[index];
  @override
  String? explanation(int index, String lang) => null;
  @override
  String? basis(String lang) => null;
  @override
  Set<int> get correct => key;
  @override
  List<String> get topicIds => [topic];

  /// Rasmiy ro'yxat savoli — LabGuide qoralamasi emas.
  @override
  bool get isDraft => false;
  @override
  List<SourceRef> get refs => const [];
}

ExamLink? _link(Object? raw) => raw is Map
    ? ExamLink(raw['url']! as String, raw['locator'] as String?)
    : null;

/// Referens interval yoki diagnostik chegara: nomi, qiymati, birligi,
/// sharoiti (namuna/populyatsiya yoki qo'llanma), izoh va manba.
@immutable
class OralFact {
  const OralFact({
    required this.value,
    this.label,
    this.unit,
    this.context = const [],
    this.note,
    this.link,
  });

  /// `reference` bandi: analit, qiymat, birlik, populyatsiya, namuna.
  factory OralFact.reference(Map<String, Object?> j) => OralFact(
    label: j['analyte'] as String?,
    value: j['value']! as String,
    unit: j['unit'] as String?,
    context: [
      for (final k in ['specimen', 'population'])
        if (j[k] case final String v) v,
    ],
    note: j['note'] as String?,
    link: _link(j['ref']),
  );

  /// `cutoffs` bandi: mezon, qiymat, birlik, qo'llanma.
  factory OralFact.cutoff(Map<String, Object?> j) => OralFact(
    label: j['criterion'] as String?,
    value: j['value']! as String,
    unit: j['unit'] as String?,
    context: [if (j['guideline'] case final String g) g],
    link: _link(j['ref']),
  );

  final String? label;
  final String value;
  final String? unit;

  /// Namuna va populyatsiya (referens) yoki qo'llanma (chegara).
  final List<String> context;
  final String? note;
  final ExamLink? link;
}

/// Tarqalgan javoblardagi eskirgan/xato ma'lumot: noto'g'ri → to'g'ri
/// (manba). Manba bilan tasdiqlanmagan tuzatish “to'g'ri” deb ko'rsatilmaydi.
@immutable
class OralPitfall {
  const OralPitfall({
    this.wrong,
    this.right,
    this.text,
    this.links = const [],
    this.verified = false,
  });

  factory OralPitfall.fromJson(Map<String, Object?> j) => OralPitfall(
    wrong: j['wrong'] as String?,
    right: j['right'] as String?,
    text: j['text'] as String?,
    links: _links(j['refs']),
    verified: j['verified'] == true,
  );

  final String? wrong;
  final String? right;

  /// Eski (tuzilmagan) format matni.
  final String? text;
  final List<ExamLink> links;
  final bool verified;
}

/// Og'zaki savol va LabGuide tayyorlagan javob rejasi (mutaxassis
/// tekshiruvi kutilmoqda).
@immutable
class ToifaOralQuestion {
  const ToifaOralQuestion({
    required this.id,
    required this.text,
    required this.categories,
    required this.topic,
    required this.planReady,
    this.plan = const [],
    this.reference = const [],
    this.cutoffs = const [],
    this.pitfalls = const [],
    this.links = const [],
    this.note,
    this.analytes = const [],
    this.held,
    this.checked,
  });

  factory ToifaOralQuestion.fromJson(Map<String, Object?> j) {
    List<Map<String, Object?>> maps(String k) => [
      for (final e in (j[k] as List? ?? const []))
        (e as Map).cast<String, Object?>(),
    ];
    return ToifaOralQuestion(
      id: j['id']! as String,
      text: j['q']! as String,
      categories: {
        for (final c in _strings(j['categories'])) ?ToifaCategory.tryParse(c),
      },
      topic: j['topic']! as String,
      planReady: j['status'] == 'draft',
      plan: _strings(j['plan']),
      reference: [for (final m in maps('reference')) OralFact.reference(m)],
      cutoffs: [for (final m in maps('cutoffs')) OralFact.cutoff(m)],
      pitfalls: [for (final m in maps('pitfalls')) OralPitfall.fromJson(m)],
      links: _links(j['refs']),
      note: j['note'] as String?,
      analytes: _strings(j['analytes']),
      held: j['held'] as String?,
      checked: j['checked'] as String?,
    );
  }

  final String id;
  final String text;
  final Set<ToifaCategory> categories;
  final String topic;

  /// Reja yozilgan va manba bilan tekshirilgan (`draft`). Aks holda —
  /// reja to'liq emas yoki yo'q (halol ko'rsatiladi).
  final bool planReady;
  final List<String> plan;

  /// Referens intervallar (namuna, populyatsiya; laboratoriyaga qarab).
  final List<OralFact> reference;

  /// Diagnostik chegaralar (qo'llanma bilan).
  final List<OralFact> cutoffs;

  /// Tarqalgan javoblarda uchraydigan eskirgan yoki xato ma'lumotlar.
  final List<OralPitfall> pitfalls;
  final List<ExamLink> links;

  /// Rejaning qaysi qismi alohida tekshirilmagani.
  final String? note;
  final List<String> analytes;

  /// Aniqlashtirilguncha biletga kirmaydi (sabab).
  final String? held;

  /// Agent tekshiruvi sanasi (mutaxassis tasdig'i emas).
  final String? checked;
}

/// Ikkala bank: test va og'zaki savollar.
class ToifaBank {
  ToifaBank({
    required this.topicOrder,
    required this.tests,
    required this.oral,
    this.auditCheckedAt,
  });

  factory ToifaBank.fromJson(
    Map<String, Object?> tests,
    Map<String, Object?> oral,
  ) {
    if (tests['version'] != 1 || oral['version'] != 1) {
      throw const FormatException('toifa version');
    }
    final bank = ToifaBank(
      topicOrder: _strings(tests['topics']),
      auditCheckedAt: oral['audit_checked_at'] as String?,
      tests: [
        for (final q in tests['questions']! as List)
          ToifaTestQuestion.fromJson((q as Map).cast<String, Object?>()),
      ],
      oral: [
        for (final q in oral['questions']! as List)
          ToifaOralQuestion.fromJson((q as Map).cast<String, Object?>()),
      ],
    );
    bank._validate();
    return bank;
  }

  final List<String> topicOrder;

  /// Kontent agent tekshiruvi sanasi (asset versiyasi; mutaxassis emas).
  final String? auditCheckedAt;
  final List<ToifaTestQuestion> tests;
  final List<ToifaOralQuestion> oral;

  late final Map<String, ToifaTestQuestion> _testById = {
    for (final q in tests) q.id: q,
  };
  late final Map<String, ToifaOralQuestion> _oralById = {
    for (final q in oral) q.id: q,
  };

  /// Asset buzilgan bo'lsa — yuklanmaydi (noto'g'ri kalit ko'rsatilmasin).
  void _validate() {
    for (final q in tests) {
      if (q.options.length < 3 || q.options.length > 4) {
        throw FormatException('options ${q.id}');
      }
      if (q.key.length > 1 || q.key.any((k) => k < 0 || k >= q.optionCount)) {
        throw FormatException('key ${q.id}');
      }
    }
    if (_testById.length != tests.length || _oralById.length != oral.length) {
      throw const FormatException('duplicate id');
    }
    for (final c in ToifaCategory.values) {
      if (ticketPool(c).length < ToifaFormat.ticketSize) {
        throw FormatException('category ${c.id}');
      }
    }
  }

  ToifaTestQuestion? test(String id) => _testById[id];
  ToifaOralQuestion? oralQuestion(String id) => _oralById[id];

  /// Ball hisoblanadigan (rasmiy kaliti bor) savollar.
  late final List<ToifaTestQuestion> scorable = [
    for (final q in tests)
      if (q.scorable) q,
  ];

  /// Ro'yxatda kalit belgilanmagan savollar soni (testga kirmaydi).
  int get keyless => tests.where((q) => q.key.isEmpty).length;

  /// Aniqlashtirilguncha testdan chiqarilgan savollar soni.
  int get heldTests => tests.where((q) => q.held != null).length;

  int verdictCount(KeyVerdict v) =>
      scorable.where((q) => q.keyCheck.verdict == v).length;

  List<ToifaOralQuestion> oralFor(ToifaCategory c) => [
    for (final q in oral)
      if (q.categories.contains(c)) q,
  ];

  /// Biletga kiradigan savollar: aniqlashtirilayotganlari chiqarilgan.
  List<ToifaOralQuestion> ticketPool(ToifaCategory c) => [
    for (final q in oralFor(c))
      if (q.held == null) q,
  ];

  late final ToifaQuestionSource source = ToifaQuestionSource(this);
}

/// Imtihon dvigateli uchun bank: faqat rasmiy kaliti bor savollar.
class ToifaQuestionSource implements ExamQuestionSource {
  ToifaQuestionSource(this.bank);

  static const sourceId = 'toifa';

  final ToifaBank bank;

  @override
  String get id => sourceId;
  @override
  List<ExamQuestion> get questions => bank.scorable;
  @override
  ExamQuestion? question(String id) => bank.test(id);

  @override
  late final List<ExamTopic> topics = [
    for (final t in bank.topicOrder)
      ExamTopic(t, (l, _) => l.toifaTopic(t), [
        for (final q in bank.scorable)
          if (q.topic == t) q,
      ]),
  ].where((t) => t.questions.isNotEmpty).toList();
}

/// Imtihon formati (egasi aytgan): test — 50 savol, og'zaki bilet — 5 savol.
abstract final class ToifaFormat {
  /// Og'zaki biletdagi savollar soni.
  static const ticketSize = 5;

  /// Testdagi savollar soni (rasmiy format).
  static const testSize = 50;

  /// Mavzu bo'yicha mashq raundidagi savollar soni.
  static const practiceRound = 20;
}

/// Keyin Pro obunaga o'tishi mumkin bo'lgan imkoniyatlar.
enum ToifaFeature {
  /// To'liq savollar banki (barcha rasmiy test savollari).
  fullBank,

  /// Cheklanmagan natijalar tarixi.
  unlimitedHistory,

  /// Kengaytirilgan mashq (to'liq raundlar).
  extendedPractice,
}

/// Imkoniyat ochiqmi — yagona tekshiruv nuqtasi. Hozir (TestFlight) hammasi
/// ochiq. Tekshiruv faqat yangi test/bilet/mashq tuzilayotganda qilinadi:
/// boshlangan test yoki bilet hech qachon to'xtatilmaydi. To'lov oynasi yo'q.
bool toifaAllows(ToifaFeature feature) => true;

/// Imkoniyat yopiq bo'lgandagi qiymatlar — faqat TAKLIF (egasi hali qaror
/// qilmagan). Hozir [toifaAllows] doim true.
abstract final class ToifaFreeProposal {
  static const bankSize = 100;
  static const historySize = 5;
  static const practiceRound = 10;
}

/// Test uchun savollar to'plami ([ToifaFeature.fullBank] bo'yicha).
List<ToifaTestQuestion> toifaTestPool(ToifaBank bank) =>
    toifaAllows(ToifaFeature.fullBank)
    ? bank.scorable
    : bank.scorable.take(ToifaFreeProposal.bankSize).toList();
