import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// O'quv dasturi (`curriculum.json`): modul → mavzu → ilova materiallariga
// havolalar. Fayl ustoz yuborgan kalendar-mavzuli rejadan tayyorlanadi;
// asset sifatida qo'shilganda ham shaxsiy/tashkiliy ma'lumot (kurator,
// klinika nomi, guruhga xos sanalar) kiritilmaydi — faqat kun tartibi
// (`n`), hafta, modul, mavzu, soat, turi va havolalar. Sana bo'lmasa —
// ustoz guruh uchun belgilagan boshlanish sanasidan hisoblanadi
// ([studyDayDate]).
//
// O'quvchi bardoshli: noma'lum maydonlar e'tiborsiz qoldiriladi, nomzod
// savollar (`oral_candidates`, `test_candidates`) faqat id ro'yxati —
// kalitlari tekshirilmagan, ustoz tanlaydi.

/// Mavzu nomi: `title_uz`/`title_ru`/`title_en` yoki `title` (matn yoki
/// `{uz, ru, en}`). Tarjima bo'lmasa — o'zbekcha.
@immutable
class CurriculumText {
  const CurriculumText(this.values);

  factory CurriculumText.fromJson(Map<String, Object?> j, String key) {
    final out = <String, String>{};
    switch (j[key]) {
      case final String s when s.trim().isNotEmpty:
        out['uz'] = s.trim();
      case final Map<Object?, Object?> m:
        for (final e in m.entries) {
          if (e.value case final String s when s.trim().isNotEmpty) {
            out['${e.key}'] = s.trim();
          }
        }
    }
    for (final lang in const ['uz', 'ru', 'en']) {
      if (j['${key}_$lang'] case final String s when s.trim().isNotEmpty) {
        out[lang] = s.trim();
      }
    }
    return CurriculumText(out);
  }

  final Map<String, String> values;

  bool get isEmpty => values.isEmpty;

  String of(String lang) =>
      values[lang] ?? values['uz'] ?? values.values.firstOrNull ?? '';
}

enum CurriculumTopicType {
  lecture,
  practical,
  seminar,
  attestation,
  other;

  static CurriculumTopicType parse(Object? raw) => switch (raw) {
    'lecture' => lecture,
    'practical' || 'lab' => practical,
    'seminar' => seminar,
    'attestation' => attestation,
    _ => other,
  };
}

/// Mavzu materiallari: ilova ichidagi kartalar, jadvallar, atlas,
/// kalkulyatorlar va toifa banki mavzusi.
@immutable
class CurriculumLinks {
  const CurriculumLinks({
    this.analytes = const [],
    this.conditions = const [],
    this.reference = const [],
    this.tools = const [],
    this.microscopy = const [],
    this.toifaTopic,
    this.gap = false,
  });

  factory CurriculumLinks.fromJson(Object? raw) {
    final j = raw is Map
        ? raw.cast<String, Object?>()
        : const <String, Object?>{};
    return CurriculumLinks(
      analytes: _ids(j['analytes']),
      conditions: _ids(j['conditions']),
      reference: _ids(j['reference']),
      // Faqat ilova ichidagi manzillar (tashqi havola emas).
      tools: [
        for (final t in _ids(j['tools']))
          if (t.startsWith('/lab/') || t.startsWith('/learn/')) t,
      ],
      microscopy: _ids(j['microscopy']),
      toifaTopic: switch (j['toifa_topic']) {
        final String s when s.isNotEmpty => s,
        _ => null,
      },
      gap: j['gap'] == true,
    );
  }

  final List<String> analytes;
  final List<String> conditions;
  final List<String> reference;
  final List<String> tools;

  /// Atlas bo'limlari (`blood`, `urine`, `parasites`...).
  final List<String> microscopy;
  final String? toifaTopic;

  /// Ilovada bu mavzu bo'yicha material yetarli emas (halol belgi).
  final bool gap;

  bool get isEmpty =>
      analytes.isEmpty &&
      conditions.isEmpty &&
      reference.isEmpty &&
      tools.isEmpty &&
      microscopy.isEmpty;
}

@immutable
class CurriculumTopic {
  const CurriculumTopic({
    required this.id,
    required this.moduleId,
    required this.order,
    required this.title,
    this.type = CurriculumTopicType.other,
    this.hours,
    this.week,
    this.date,
    this.links = const CurriculumLinks(),
    this.goals = const [],
    this.keyPoints = const [],
    this.oralCandidates = const [],
    this.testCandidates = const [],
    this.packQuizCandidates = const [],
    this.testGap = false,
    this.oralGap = false,
  });

  factory CurriculumTopic.fromJson(
    Map<String, Object?> j, {
    required String moduleId,
    required int fallbackOrder,
  }) {
    final test = j['test_candidates'];
    final testMap = test is Map ? test.cast<String, Object?>() : null;
    return CurriculumTopic(
      id: (j['id']! as String).trim(),
      moduleId: moduleId,
      order: _int(j['n']) ?? _int(j['day']) ?? fallbackOrder,
      title: CurriculumText.fromJson(j, 'title'),
      type: CurriculumTopicType.parse(j['type']),
      hours: _int(j['hours']),
      week: _int(j['week']),
      date: switch (j['date']) {
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      links: CurriculumLinks.fromJson(j['links']),
      goals: _texts(j['goals']),
      keyPoints: _texts(j['key_points']),
      oralCandidates: _candidateIds(j['oral_candidates']),
      testCandidates: testMap == null
          ? _candidateIds(test)
          : _ids(testMap['ids']),
      packQuizCandidates: testMap == null
          ? const []
          : _ids(testMap['pack_quiz_ids']),
      testGap: j['test_gap'] == true,
      oralGap: j['oral_gap'] == true,
    );
  }

  final String id;
  final String moduleId;

  /// Kun tartibi (`n`): bir kunda ma'ruza va amaliyot bo'lishi mumkin.
  final int order;
  final CurriculumText title;
  final CurriculumTopicType type;
  final int? hours;
  final int? week;

  /// Jadvaldagi sana (asset'da odatda yo'q — guruh boshlanishidan).
  final DateTime? date;
  final CurriculumLinks links;

  /// Ma'ruza slaydlari uchun (bo'lmasa — havolalardan yig'iladi).
  final List<String> goals;
  final List<String> keyPoints;

  /// Toifa og'zaki banki id lari — nomzod (ustoz tanlaydi).
  final List<String> oralCandidates;

  /// Toifa test banki id lari — nomzod, kaliti tekshirilmagan.
  final List<String> testCandidates;

  /// Kontent paketi mashq savollari id lari — nomzod.
  final List<String> packQuizCandidates;
  final bool testGap;
  final bool oralGap;
}

@immutable
class CurriculumModule {
  const CurriculumModule({
    required this.id,
    required this.title,
    required this.topics,
  });

  final String id;
  final CurriculumText title;
  final List<CurriculumTopic> topics;
}

@immutable
class Curriculum {
  Curriculum({required this.name, required this.modules})
    : _byId = {
        for (final m in modules)
          for (final t in m.topics) t.id: t,
      };

  /// [json] — `{program?, modules: [...]}`. Mavzusiz modul tashlab
  /// yuboriladi; takror mavzu id si — xato (jadval chalkashmasin).
  factory Curriculum.fromJson(Map<String, Object?> json) {
    final program = json['program'] is Map
        ? (json['program']! as Map).cast<String, Object?>()
        : const <String, Object?>{};
    final rawModules = json['modules'];
    if (rawModules is! List) {
      throw const FormatException('curriculum: modules');
    }
    var order = 0;
    final seen = <String>{};
    final modules = <CurriculumModule>[];
    for (final (i, raw) in rawModules.indexed) {
      final m = (raw as Map).cast<String, Object?>();
      final id = (m['id'] as String?)?.trim() ?? 'M${i + 1}';
      final topics = <CurriculumTopic>[];
      for (final t in m['topics'] as List? ?? const []) {
        final topic = CurriculumTopic.fromJson(
          (t as Map).cast<String, Object?>(),
          moduleId: id,
          fallbackOrder: ++order,
        );
        if (!seen.add(topic.id)) {
          throw FormatException('curriculum: duplicate topic ${topic.id}');
        }
        order = topic.order > order ? topic.order : order;
        topics.add(topic);
      }
      if (topics.isEmpty) continue;
      modules.add(
        CurriculumModule(
          id: id,
          title: CurriculumText.fromJson(m, 'title'),
          topics: List.unmodifiable(topics),
        ),
      );
    }
    return Curriculum(
      name: CurriculumText.fromJson(program, 'name'),
      modules: List.unmodifiable(modules),
    );
  }

  static Curriculum parse(String source) =>
      Curriculum.fromJson((jsonDecode(source) as Map).cast<String, Object?>());

  final CurriculumText name;
  final List<CurriculumModule> modules;
  final Map<String, CurriculumTopic> _byId;

  /// Jadval tartibida (kun, keyin fayldagi tartib).
  late final List<CurriculumTopic> topics = [
    for (final m in modules) ...m.topics,
  ]..sort((a, b) => a.order.compareTo(b.order));

  CurriculumTopic? topic(String id) => _byId[id];

  CurriculumModule? moduleOf(CurriculumTopic t) =>
      modules.where((m) => m.id == t.moduleId).firstOrNull;
}

/// Kun tartibi → sana: [start] — 1-o'quv kuni; yakshanba o'tkaziladi
/// (6 kunlik o'quv haftasi). Bayram kunlari hisobga olinmaydi — ustoz
/// boshlanish sanasini o'zgartirib moslaydi (ko'rsatishda “taxminiy”).
DateTime studyDayDate(DateTime start, int order) {
  var d = DateTime(start.year, start.month, start.day);
  while (d.weekday == DateTime.sunday) {
    d = d.add(const Duration(days: 1));
  }
  for (var i = 1; i < order; i++) {
    d = d.add(const Duration(days: 1));
    if (d.weekday == DateTime.sunday) d = d.add(const Duration(days: 1));
  }
  return d;
}

/// O'quv dasturi qayerdan: asset (bo'lsa). Hozircha asset qo'shilmagan —
/// ekranlar “dastur hali qo'shilmagan” deb halol ko'rsatadi.
abstract final class CurriculumLoader {
  static const assetPath = 'assets/curriculum/curriculum.json';

  /// Fayl yo'q — null; buzilgan — [FormatException].
  static Future<Curriculum?> load(
    AssetBundle bundle, {
    String path = assetPath,
  }) async {
    final String raw;
    try {
      raw = await bundle.loadString(path, cache: false);
    } on Object {
      return null;
    }
    return Curriculum.parse(raw);
  }
}

enum CurriculumState { idle, loading, ready, missing, error }

class CurriculumController extends ChangeNotifier {
  CurriculumController({this.bundle, Curriculum? curriculum})
    : _curriculum = curriculum,
      _state = curriculum == null
          ? CurriculumState.idle
          : CurriculumState.ready;

  /// Dastur asset'i qayerdan o'qiladi (null — “qo'shilmagan”).
  final AssetBundle? bundle;
  Curriculum? _curriculum;
  CurriculumState _state;
  Future<void>? _loading;

  Curriculum? get curriculum => _curriculum;
  CurriculumState get state => _state;

  Future<void> ensureLoaded() =>
      _state == CurriculumState.ready ? Future.value() : _loading ??= _load();

  Future<void> _load() async {
    // Ekran qurilayotganda (initState) chaqirilishi mumkin — tinglovchilar
    // keyingi mikrovazifada xabardor qilinadi.
    _state = CurriculumState.loading;
    await Future<void>.microtask(() {});
    final bundle = this.bundle;
    if (bundle == null) {
      _set(CurriculumState.missing);
      return;
    }
    try {
      final c = await CurriculumLoader.load(bundle);
      _curriculum = c;
      _set(c == null ? CurriculumState.missing : CurriculumState.ready);
    } on Object catch (e) {
      debugPrint('curriculum: $e');
      _set(CurriculumState.error);
    }
  }

  /// Testlar va keyinroq yuklab olinadigan dastur uchun.
  void use(Curriculum c) {
    _curriculum = c;
    _set(CurriculumState.ready);
  }

  void _set(CurriculumState s) {
    _state = s;
    notifyListeners();
  }
}

int? _int(Object? raw) => switch (raw) {
  final num n => n.toInt(),
  final String s => int.tryParse(s),
  _ => null,
};

List<String> _ids(Object? raw) => [
  for (final e in raw is List ? raw : const [])
    if (e is String && e.trim().isNotEmpty) e.trim(),
];

List<String> _texts(Object? raw) => _ids(raw);

/// `{count, ids: [...]}` yoki to'g'ridan-to'g'ri ro'yxat.
List<String> _candidateIds(Object? raw) => switch (raw) {
  final Map<Object?, Object?> m => _ids(m['ids']),
  final List<Object?> l => _ids(l),
  _ => const [],
};
