import 'dart:math';

import '../../core/backend/variant_draw.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../learn/exam_question.dart';
import '../toifa/toifa_bank.dart';
import 'curriculum.dart';
import 'topic_questions.dart';
import 'topic_test.dart';

// Umumiy test (“Umumiy test berish”): ustoz bir nechta manbadan mavzular
// tanlaydi va guruhga 50 tagacha savollik test beradi. Manbalar:
//
// * Toifa savollari — rasmiy KDL ro'yxati (28 mavzu): faqat rasmiy kaliti
//   bor, bitta to'g'ri javobli (`scorable`) savollar; variantlar tartibi
//   saqlanadi (sessiyada rasmiy savol aralashtirilmaydi);
// * Ma'ruza mavzulari — o'quv dasturi modullari (M1–M9) yoki alohida kun
//   mavzulari: mavzu testi bilan bir xil tekshirilgan hovuz
//   ([verifiedTopicQuestions], deck matnidan olingan savollar bilan);
// * Analizlar bo'yicha — kontent paketi guruhlari (eski “Yangi topshiriq”).
//
// Savollar id bo'yicha takrorsiz; tanlangan mavzular bo'yicha navbatma-
// navbat (round-robin) olinadi — server variantli testda xuddi shunday
// qatlamlab tanlaydi ([drawVariant]).

/// Bitta testdagi savollar chegarasi (server: 1–50).
const kGeneralTestMax = 50;

/// Umumiy testning variantli hovuzi chegarasi: 50 savollik variantli test
/// uchun hovuz 100 gacha (server `MAX_POOL` bilan bir xil).
const kGeneralVariantPoolMax = kVariantPoolServerMax;

enum GeneralSource { toifa, lecture, pack }

/// Tanlanadigan mavzu: toifa mavzusi, o'quv dasturi kuni yoki paket guruhi.
class GeneralTopic {
  const GeneralTopic({
    required this.key,
    required this.source,
    required this.name,
    required this.questions,
    this.moduleId,
    this.day,
    this.search = '',
  });

  /// Barqaror kalit (`toifa:anemias`, `day:d010-P`, `pack:kidney`) — server
  /// `pool_topics` qatlami ham shu.
  final String key;
  final GeneralSource source;
  final String Function(AppLocalizations l, String lang) name;
  final List<ExamQuestion> questions;

  /// Ma'ruza kuni qaysi modulda.
  final String? moduleId;

  /// O'quv dasturi mavzusi (ma'ruza manbasida).
  final CurriculumTopic? day;

  /// Qidiruv uchun qo'shimcha matn (boshqa tillardagi nomlar).
  final String search;
}

/// O'quv dasturi moduli (M1–M9) va uning savolli kunlari.
class GeneralModule {
  GeneralModule(this.module, this.days);

  final CurriculumModule module;
  final List<GeneralTopic> days;

  String get id => module.id;
  String get key => 'mod:${module.id}';

  late final List<ExamQuestion> questions = _dedupe([
    for (final d in days) ...d.questions,
  ]);
}

/// Tanlov qatlami: teng taqsimlash birligi.
class GeneralStratum {
  const GeneralStratum(this.key, this.questions);

  final String key;
  final List<ExamQuestion> questions;
}

List<ExamQuestion> _dedupe(Iterable<ExamQuestion> qs) {
  final seen = <String>{};
  return [
    for (final q in qs)
      if (seen.add(q.id)) q,
  ];
}

/// Server kaliti bitta javob saqlaydi: bitta to'g'ri javob, indeks 0–20 va
/// variantlar ichida.
bool generalAssignable(ExamQuestion q) =>
    assignable(q) &&
    q.optionCount >= 2 &&
    q.correct.single >= 0 &&
    q.correct.single < q.optionCount &&
    q.correct.single <= 20;

/// Uch manbaning hamma tanlanadigan mavzulari (bo'sh mavzular tashlanadi).
class GeneralCatalog {
  GeneralCatalog._(this.curriculum, this.pack, this.bank) {
    final b = bank;
    if (b != null) {
      for (final t in b.topicOrder) {
        final qs = [
          for (final q in b.scorable)
            if (q.topic == t && generalAssignable(q)) q,
        ];
        if (qs.isEmpty) continue;
        toifa.add(
          GeneralTopic(
            key: 'toifa:$t',
            source: GeneralSource.toifa,
            name: (l, _) => l.toifaTopic(t),
            questions: List.unmodifiable(qs),
          ),
        );
      }
    }
    final c = curriculum;
    if (c != null) {
      for (final m in c.modules) {
        final days = <GeneralTopic>[];
        for (final t in m.topics) {
          final qs = [
            for (final q in verifiedTopicQuestions(t, pack, bank))
              if (generalAssignable(q)) q,
          ];
          if (qs.isEmpty) continue;
          days.add(
            GeneralTopic(
              key: 'day:${t.id}',
              source: GeneralSource.lecture,
              name: (_, lang) => t.title.of(lang),
              questions: List.unmodifiable(qs),
              moduleId: m.id,
              day: t,
              search:
                  '${t.title.of('uz')} ${t.title.of('ru')} '
                  '${t.title.of('en')} ${t.id}',
            ),
          );
        }
        if (days.isNotEmpty) modules.add(GeneralModule(m, days));
      }
    }
    final p = pack;
    if (p != null) {
      for (final t in PackQuestionSource.of(p).topics) {
        final qs = [
          for (final q in t.questions)
            if (generalAssignable(q)) q,
        ];
        if (qs.isEmpty) continue;
        final g = p.groups.where((g) => g.id == t.id).firstOrNull;
        packGroups.add(
          GeneralTopic(
            key: 'pack:${t.id}',
            source: GeneralSource.pack,
            name: t.name,
            questions: List.unmodifiable(qs),
            search: g == null
                ? ''
                : '${g.names.of('uz')} ${g.names.of('ru')} ${g.names.of('en')}',
          ),
        );
      }
    }
    for (final t in all) {
      _byKey[t.key] = t;
    }
  }

  /// Bir xil manbalar uchun bitta katalog (har kadrda qayta hisoblanmaydi).
  static GeneralCatalog of(Curriculum? c, ContentPack? p, ToifaBank? b) {
    final last = _last;
    if (last != null &&
        identical(last.curriculum, c) &&
        identical(last.pack, p) &&
        identical(last.bank, b)) {
      return last;
    }
    return _last = GeneralCatalog._(c, p, b);
  }

  static GeneralCatalog? _last;

  final Curriculum? curriculum;
  final ContentPack? pack;
  final ToifaBank? bank;

  final List<GeneralTopic> toifa = [];
  final List<GeneralModule> modules = [];
  final List<GeneralTopic> packGroups = [];
  final Map<String, GeneralTopic> _byKey = {};

  List<GeneralTopic> get lectureDays => [for (final m in modules) ...m.days];

  /// Hamma tanlanadigan mavzular (toifa, ma'ruza kunlari, paket).
  List<GeneralTopic> get all => [...toifa, ...lectureDays, ...packGroups];

  GeneralTopic? byKey(String key) => _byKey[key];

  List<GeneralTopic> topicsOf(GeneralSource s) => switch (s) {
    GeneralSource.toifa => toifa,
    GeneralSource.lecture => lectureDays,
    GeneralSource.pack => packGroups,
  };

  /// Manba savollari soni (takrorsiz).
  int sourceCount(GeneralSource s) =>
      _dedupe([for (final t in topicsOf(s)) ...t.questions]).length;

  /// Tanlangan mavzulardan qatlamlar: butun modul tanlangan bo'lsa — bitta
  /// qatlam (modul), aks holda har kun alohida. Savol birinchi uchragan
  /// qatlamda qoladi (toifa → ma'ruza → paket), bo'sh qatlam tashlanadi.
  List<GeneralStratum> strata(Set<String> selected) {
    final seen = <String>{};
    final out = <GeneralStratum>[];
    void add(String key, Iterable<ExamQuestion> qs) {
      final mine = [
        for (final q in qs)
          if (seen.add(q.id)) q,
      ];
      if (mine.isNotEmpty) out.add(GeneralStratum(key, mine));
    }

    for (final t in toifa) {
      if (selected.contains(t.key)) add(t.key, t.questions);
    }
    for (final m in modules) {
      final picked = [
        for (final d in m.days)
          if (selected.contains(d.key)) d,
      ];
      if (picked.isEmpty) continue;
      if (picked.length == m.days.length) {
        add(m.key, m.questions);
      } else {
        for (final d in picked) {
          add(d.key, d.questions);
        }
      }
    }
    for (final t in packGroups) {
      if (selected.contains(t.key)) add(t.key, t.questions);
    }
    return out;
  }
}

/// Hovuz (qatlamlar ketma-ket, takrorsiz).
List<ExamQuestion> generalPool(List<GeneralStratum> strata) => [
  for (final s in strata) ...s.questions,
];

/// Qatlamlardan [count] ta savol, navbatma-navbat (round-robin): har qatlam
/// ichida id bo'yicha tartiblab [seed] bilan aralashtiriladi, qatlamlar
/// tartibi ham aralashtiriladi (qaysi mavzu “ortiqcha” savol berishi
/// tasodifiy). Bir xil urug' — bir xil natija.
List<ExamQuestion> drawBalanced(
  List<GeneralStratum> strata, {
  required int count,
  required int seed,
}) {
  final random = Random(seed);
  final lists = [
    for (final s in strata)
      ([...s.questions]..sort((a, b) => a.id.compareTo(b.id)))..shuffle(random),
  ]..shuffle(random);
  final total = lists.fold<int>(0, (n, l) => n + l.length);
  final n = count.clamp(0, total);
  final out = <ExamQuestion>[];
  for (var round = 0; out.length < n; round++) {
    for (final l in lists) {
      if (round < l.length && out.length < n) out.add(l[round]);
    }
  }
  return out;
}

/// Savol id → qatlam kaliti (server `pool_topics` uchun; noto'g'ri belgili
/// kalit — null).
Map<String, String?> stratumOf(List<GeneralStratum> strata) => {
  for (final s in strata)
    for (final q in s.questions) q.id: variantTopic([s.key]),
};

/// Standart sarlavha: “Umumiy test: Toifa · Gematologiya, Biokimyo…”.
String generalTestTitle(
  AppLocalizations l,
  String lang,
  GeneralCatalog catalog,
  Set<String> selected,
) {
  const maxNames = 3;
  var shown = 0;
  var more = false;
  final parts = <String>[];
  void part(String label, List<String> names, {required bool all}) {
    if (names.isEmpty) return;
    if (all) {
      parts.add('$label · ${l.generalAllShort}');
      return;
    }
    final take = <String>[];
    for (final n in names) {
      if (shown >= maxNames) {
        more = true;
        break;
      }
      take.add(n);
      shown++;
    }
    if (take.isEmpty) return;
    parts.add('$label · ${take.join(', ')}');
  }

  final toifa = [
    for (final t in catalog.toifa)
      if (selected.contains(t.key)) t.name(l, lang),
  ];
  part(
    l.generalSourceToifaShort,
    toifa,
    all: catalog.toifa.length > 1 && toifa.length == catalog.toifa.length,
  );
  final lecture = <String>[];
  var allModules = catalog.modules.isNotEmpty;
  for (final m in catalog.modules) {
    final picked = [
      for (final d in m.days)
        if (selected.contains(d.key)) d,
    ];
    if (picked.length != m.days.length) allModules = false;
    if (picked.isEmpty) continue;
    if (picked.length == m.days.length) {
      lecture.add(m.id);
    } else {
      lecture.addAll([for (final d in picked) d.name(l, lang)]);
    }
  }
  part(
    l.generalSourceLectureShort,
    lecture,
    all: catalog.modules.length > 1 && allModules,
  );
  final pack = [
    for (final t in catalog.packGroups)
      if (selected.contains(t.key)) t.name(l, lang),
  ];
  part(
    l.generalSourcePackShort,
    pack,
    all:
        catalog.packGroups.length > 1 &&
        pack.length == catalog.packGroups.length,
  );
  var t = l.generalTestTitle(parts.join(' + '));
  if (more) t = '$t…';
  if (t.length > 120) t = '${t.substring(0, 119).trimRight()}…';
  return t;
}
