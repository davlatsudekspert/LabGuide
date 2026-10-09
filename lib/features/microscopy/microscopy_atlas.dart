import 'package:flutter/foundation.dart';

import '../content/content_model.dart';

/// Ruxsat etilgan rasm litsenziyalari va ularning kanonik havolasi.
/// NC/ND, noaniq litsenziya — yo'q (validator rad etadi).
const microLicenses = <String, String>{
  'CC0 1.0': 'https://creativecommons.org/publicdomain/zero/1.0/',
  'CC BY 2.0': 'https://creativecommons.org/licenses/by/2.0/',
  'CC BY 3.0': 'https://creativecommons.org/licenses/by/3.0/',
  'CC BY 4.0': 'https://creativecommons.org/licenses/by/4.0/',
  'CC BY-SA 2.0': 'https://creativecommons.org/licenses/by-sa/2.0/',
  'CC BY-SA 3.0': 'https://creativecommons.org/licenses/by-sa/3.0/',
  'CC BY-SA 4.0': 'https://creativecommons.org/licenses/by-sa/4.0/',
  'Public domain': 'https://creativecommons.org/publicdomain/mark/1.0/',
  'CDC PHIL': 'https://www.cdc.gov/other/agencymaterials.html',
};

/// Rasm manbasi.
enum MicroProvider {
  commons,
  cdcPhil;

  static MicroProvider parse(String raw) => switch (raw) {
    'commons' => commons,
    'cdc_phil' => cdcPhil,
    _ => throw FormatException('unknown provider: $raw'),
  };
}

/// “Bu nima?” mashqida savol qanday beriladi.
enum MicroQuizCue {
  /// Manbadagi strelka ko'rsatgan hujayra.
  arrowhead,

  /// Maydon markazidagi hujayra.
  centre,

  /// Butun maydon (kristall, silindr, surtma turi).
  field;

  static MicroQuizCue? parse(Object? raw) => switch (raw) {
    null => null,
    'arrowhead' => arrowhead,
    'centre' => centre,
    'field' => field,
    _ => throw FormatException('unknown quiz cue: $raw'),
  };
}

String _str(Map<String, Object?> j, String key) {
  final v = j[key];
  if (v is! String || v.trim().isEmpty) {
    throw FormatException('"$key" must be a non-empty string');
  }
  return v;
}

@immutable
class MicroSection {
  const MicroSection({
    required this.id,
    required this.name,
    required this.subtitle,
  });

  factory MicroSection.fromJson(Map<String, Object?> j) => MicroSection(
    id: _str(j, 'id'),
    name: LocalizedText.fromJson(j['name']),
    subtitle: LocalizedText.fromJson(j['sub']),
  );

  final String id;
  final LocalizedText name;
  final LocalizedText subtitle;
}

@immutable
class MicroGroup {
  const MicroGroup({
    required this.id,
    required this.sectionId,
    required this.name,
  });

  factory MicroGroup.fromJson(Map<String, Object?> j) => MicroGroup(
    id: _str(j, 'id'),
    sectionId: _str(j, 'section'),
    name: LocalizedText.fromJson(j['name']),
  );

  final String id;
  final String sectionId;
  final LocalizedText name;
}

/// Rasmdagi obyekt turi (masalan, “Neytrofil”). Mashq variantlari faqat
/// shu nomlardan olinadi.
@immutable
class MicroEntity {
  const MicroEntity({
    required this.id,
    required this.groupId,
    required this.name,
    required this.terms,
    required this.quiz,
    this.note,
    this.gap,
  });

  factory MicroEntity.fromJson(Map<String, Object?> j) => MicroEntity(
    id: _str(j, 'id'),
    groupId: _str(j, 'group'),
    name: LocalizedText.fromJson(j['name']),
    terms: (j['terms'] as List? ?? const []).cast<String>(),
    quiz: j['quiz']! as bool,
    note: j['note'] == null ? null : LocalizedText.fromJson(j['note']),
    gap: j['gap'] == null ? null : LocalizedText.fromJson(j['gap']),
  );

  final String id;
  final String groupId;
  final LocalizedText name;

  /// Qidiruv sinonimlari (uz/ru/en, lotin/kirill).
  final List<String> terms;

  /// “Bu nima?” mashqida javob/variant bo'la oladi.
  final bool quiz;

  /// LabGuide'ning qisqa tushuntirishi — **draft**, mutaxassis tekshiruvi
  /// kutilmoqda (hech qachon “tasdiqlangan” deb ko'rsatilmaydi).
  final LocalizedText? note;

  /// Litsenziyali rasm hali yo'q — sababi (halol ko'rsatiladi).
  final LocalizedText? gap;
}

/// Manbadagi asl izoh (so'zma-so'z, manba tilida) va LabGuide tarjimasi.
@immutable
class MicroCaption {
  const MicroCaption({
    required this.lang,
    required this.text,
    required this.translation,
  });

  factory MicroCaption.fromJson(Map<String, Object?> j) => MicroCaption(
    lang: _str(j, 'lang'),
    text: _str(j, 'text'),
    translation: LocalizedText.fromJson(j['tr']),
  );

  /// ISO 639-1 (en, es, ru …).
  final String lang;
  final String text;
  final LocalizedText translation;
}

/// Manbada yozilgan bo'yoq/preparat turi (so'zma-so'z) va tarjimasi.
@immutable
class MicroStain {
  const MicroStain(this.text, this.translation);

  factory MicroStain.fromJson(Map<String, Object?> j) =>
      MicroStain(_str(j, 'text'), LocalizedText.fromJson(j['tr']));

  final String text;
  final LocalizedText translation;
}

@immutable
class MicroImage {
  const MicroImage({
    required this.id,
    required this.entityId,
    required this.asset,
    required this.width,
    required this.height,
    required this.originalWidth,
    required this.originalHeight,
    required this.bytes,
    required this.provider,
    required this.sourceTitle,
    required this.sourcePage,
    required this.fileUrl,
    required this.author,
    required this.credit,
    required this.license,
    required this.licenseUrl,
    required this.caption,
    this.authorUrl,
    this.labelNote,
    this.termsQuote,
    this.date,
    this.magnification,
    this.stain,
    this.quizCue,
  });

  factory MicroImage.fromJson(Map<String, Object?> j) {
    List<int> pair(String k) => [
      for (final v in j[k]! as List) (v as num).toInt(),
    ];
    final size = pair('size');
    final original = pair('original_size');
    return MicroImage(
      id: _str(j, 'id'),
      entityId: _str(j, 'entity'),
      asset: _str(j, 'asset'),
      width: size[0],
      height: size[1],
      originalWidth: original[0],
      originalHeight: original[1],
      bytes: (j['bytes']! as num).toInt(),
      provider: MicroProvider.parse(_str(j, 'provider')),
      sourceTitle: _str(j, 'source_title'),
      sourcePage: _str(j, 'source_page'),
      fileUrl: _str(j, 'file_url'),
      author: _str(j, 'author'),
      authorUrl: j['author_url'] as String?,
      labelNote: j['label_note'] == null
          ? null
          : LocalizedText.fromJson(j['label_note']),
      credit: _str(j, 'credit'),
      license: _str(j, 'license'),
      licenseUrl: _str(j, 'license_url'),
      caption: MicroCaption.fromJson(
        (j['caption']! as Map).cast<String, Object?>(),
      ),
      termsQuote: j['terms_quote'] as String?,
      date: j['date'] as String?,
      magnification: j['magnification'] as String?,
      stain: j['stain'] == null
          ? null
          : MicroStain.fromJson((j['stain']! as Map).cast<String, Object?>()),
      quizCue: MicroQuizCue.parse(j['quiz']),
    );
  }

  final String id;
  final String entityId;
  final String asset;
  final int width;
  final int height;
  final int originalWidth;
  final int originalHeight;
  final int bytes;
  final MicroProvider provider;

  /// Manbadagi nom (Commons fayl nomi yoki “CDC PHIL ID#…”).
  final String sourceTitle;
  final String sourcePage;
  final String fileUrl;
  final String author;

  /// Muallif sahifasi (Commons foydalanuvchisi yoki maqola DOI); CDC PHIL
  /// fotografida yo'q.
  final String? authorUrl;

  /// Nom faqat manba izohiga tayanadi, ko'rinishi namunaviy emas — sababi.
  /// Bunday rasm mashqqa kirmaydi.
  final LocalizedText? labelNote;

  /// “Own work”, jurnal maqolasi yoki “CDC Public Health Image Library”.
  final String credit;
  final String license;
  final String licenseUrl;
  final MicroCaption caption;

  /// Manbadagi foydalanish shartlari (CDC PHIL) — so'zma-so'z.
  final String? termsQuote;
  final String? date;

  /// Manbada yozilgan kattalashtirish (so'zma-so'z); `null` — ko'rsatilmagan.
  final String? magnification;
  final MicroStain? stain;

  /// `null` — rasm mashqda ishlatilmaydi (aralash maydon, jurnal paneli).
  final MicroQuizCue? quizCue;

  double get aspectRatio => width / height;

  /// Ilovadagi nusxa kichraytirilgan (kesilmagan).
  bool get resized => width != originalWidth || height != originalHeight;

  bool get shareAlike => license.startsWith('CC BY-SA');
}

/// Qidiruv uchun normallashtirish: kichik harf, apostrof turlari, “ё”.
String normalizeMicroQuery(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[ʻʼ‘’`\']'), '')
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r'[\s\-_/.,:;()«»"“”]+'), ' ')
    .trim();

/// Mikroskopiya atlasi: bo'lim → guruh → tur → rasm. Yuklashda to'liq
/// tekshiriladi ([MicroAtlas.fromJson]); buzilgan atlas ko'rsatilmaydi.
@immutable
class MicroAtlas {
  const MicroAtlas({
    required this.version,
    required this.accessed,
    required this.maxSide,
    required this.sections,
    required this.groups,
    required this.entities,
    required this.images,
  });

  factory MicroAtlas.fromJson(Map<String, Object?> json) {
    if (json['schema_version'] != 1) {
      throw FormatException('unsupported schema: ${json['schema_version']}');
    }
    List<Map<String, Object?>> list(String k) => [
      for (final e in json[k]! as List) (e as Map).cast<String, Object?>(),
    ];
    final atlas = MicroAtlas(
      version: _str(json, 'atlas_version'),
      accessed: _str(json, 'accessed'),
      maxSide: (json['max_side']! as num).toInt(),
      sections: list('sections').map(MicroSection.fromJson).toList(),
      groups: list('groups').map(MicroGroup.fromJson).toList(),
      entities: list('entities').map(MicroEntity.fromJson).toList(),
      images: list('images').map(MicroImage.fromJson).toList(),
    );
    atlas._validate();
    return atlas;
  }

  final String version;

  /// Manbalar (litsenziya, muallif, izoh) qayta tekshirilgan sana.
  final String accessed;
  final int maxSide;
  final List<MicroSection> sections;
  final List<MicroGroup> groups;
  final List<MicroEntity> entities;
  final List<MicroImage> images;

  /// Mashqda kamida shuncha variant bo'ladi.
  static const optionsPerQuestion = 4;

  void _validate() {
    void unique(Iterable<String> ids, String what) {
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) throw FormatException('duplicate $what: $id');
      }
    }

    unique(sections.map((s) => s.id), 'section');
    unique(groups.map((g) => g.id), 'group');
    unique(entities.map((e) => e.id), 'entity');
    unique(images.map((i) => i.id), 'image');
    final sectionIds = {for (final s in sections) s.id};
    final groupIds = {for (final g in groups) g.id};
    for (final g in groups) {
      if (!sectionIds.contains(g.sectionId)) {
        throw FormatException('${g.id}: unknown section ${g.sectionId}');
      }
    }
    for (final e in entities) {
      if (!groupIds.contains(e.groupId)) {
        throw FormatException('${e.id}: unknown group ${e.groupId}');
      }
      final has = images.any((i) => i.entityId == e.id);
      // Rasmsiz tur faqat “litsenziyali rasm hali yo'q” sababi bilan.
      if (has == (e.gap != null)) {
        throw FormatException('${e.id}: images and gap must be exclusive');
      }
      if (e.gap != null && e.quiz) {
        throw FormatException('${e.id}: gap entity cannot be a quiz answer');
      }
    }
    final entityIds = {for (final e in entities) e.id};
    for (final i in images) {
      validateImage(i);
      if (!entityIds.contains(i.entityId)) {
        throw FormatException('${i.id}: unknown entity ${i.entityId}');
      }
      if (i.width > maxSide || i.height > maxSide) {
        throw FormatException('${i.id}: larger than $maxSide px');
      }
      if (i.quizCue != null && !entity(i.entityId)!.quiz) {
        throw FormatException('${i.id}: quiz image of a non-quiz entity');
      }
    }
    final quizEntities = entities.where((e) => e.quiz).length;
    if (quizEntities < optionsPerQuestion) {
      throw const FormatException('not enough quiz entities');
    }
  }

  /// Bitta rasm yozuvining litsenziya/muallif/manba qoidalari.
  static void validateImage(MicroImage i) {
    final canonical = microLicenses[i.license];
    if (canonical == null ||
        i.license.contains('NC') ||
        i.license.contains('ND')) {
      throw FormatException('${i.id}: licence not allowed: ${i.license}');
    }
    if (i.licenseUrl != canonical) {
      throw FormatException('${i.id}: licence url mismatch: ${i.licenseUrl}');
    }
    for (final url in [i.sourcePage, i.fileUrl, ?i.authorUrl]) {
      if (!url.startsWith('https://')) {
        throw FormatException('${i.id}: url must be https: $url');
      }
    }
    if (!i.asset.startsWith('assets/microscopy/') ||
        !i.asset.endsWith('.jpg')) {
      throw FormatException('${i.id}: bad asset path ${i.asset}');
    }
    if (i.labelNote != null && i.quizCue != null) {
      throw FormatException('${i.id}: label-by-source image cannot be a quiz');
    }
    // Faqat kichraytirish: tomonlar nisbati saqlanadi (kesilmagan).
    final ratio = i.originalWidth / i.originalHeight;
    if (i.width > i.originalWidth || (i.aspectRatio - ratio).abs() > 0.01) {
      throw FormatException('${i.id}: image cropped or upscaled');
    }
    switch (i.provider) {
      case MicroProvider.commons:
        if (!i.sourcePage.startsWith(
          'https://commons.wikimedia.org/wiki/File:',
        )) {
          throw FormatException('${i.id}: not a Commons file page');
        }
        if (i.license == 'CDC PHIL') {
          throw FormatException('${i.id}: CDC licence on a Commons file');
        }
        // CC BY: muallifga havola (Commons sahifasi yoki maqola) majburiy.
        if (i.authorUrl == null) {
          throw FormatException('${i.id}: author link missing');
        }
      case MicroProvider.cdcPhil:
        if (i.license != 'CDC PHIL') {
          throw FormatException('${i.id}: PHIL image needs CDC PHIL terms');
        }
        // CDC va (bo'lsa) fotograf krediti, shartlar matni — majburiy.
        if (!i.author.startsWith('CDC') ||
            (i.termsQuote ?? '').trim().isEmpty ||
            !i.sourcePage.startsWith('https://wwwn.cdc.gov/phil/')) {
          throw FormatException('${i.id}: CDC credit/terms missing');
        }
    }
  }

  /// Fayllar mavjudligini tekshirish (test va build vositalari uchun).
  List<String> missingAssets(bool Function(String path) exists) => [
    for (final i in images)
      if (!exists(i.asset)) i.asset,
  ];

  MicroSection? section(String id) =>
      sections.where((s) => s.id == id).firstOrNull;

  MicroGroup group(String id) => groups.firstWhere((g) => g.id == id);

  MicroEntity? entity(String id) =>
      entities.where((e) => e.id == id).firstOrNull;

  MicroImage? image(String id) => images.where((i) => i.id == id).firstOrNull;

  MicroSection sectionOf(MicroEntity e) =>
      sections.firstWhere((s) => s.id == group(e.groupId).sectionId);

  List<MicroGroup> groupsIn(String sectionId) => [
    for (final g in groups)
      if (g.sectionId == sectionId) g,
  ];

  List<MicroEntity> entitiesIn(String groupId) => [
    for (final e in entities)
      if (e.groupId == groupId) e,
  ];

  List<MicroImage> imagesOf(String entityId) => [
    for (final i in images)
      if (i.entityId == entityId) i,
  ];

  List<MicroImage> imagesInSection(String sectionId) => [
    for (final g in groupsIn(sectionId))
      for (final e in entitiesIn(g.id)) ...imagesOf(e.id),
  ];

  List<MicroEntity> gapsIn(String sectionId) => [
    for (final g in groupsIn(sectionId))
      for (final e in entitiesIn(g.id))
        if (e.gap != null) e,
  ];

  /// Mashq uchun yaroqli rasmlar (bo'lim bo'yicha yoki hammasi).
  List<MicroImage> quizImages({String? sectionId}) => [
    for (final i in images)
      if (i.quizCue != null &&
          (sectionId == null || sectionOf(entity(i.entityId)!).id == sectionId))
        i,
  ];

  /// Nom, sinonim, guruh/bo'lim nomi, asl izoh va tarjima bo'yicha (uch
  /// tilda) qidiruv. Natija — turlar (rasmsiz “hali yo'q” turlari ham);
  /// nomi mos kelganlar birinchi.
  List<MicroEntity> search(String query) {
    final words = normalizeMicroQuery(query)
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    final whole = words.join(' ');
    final scored = <(MicroEntity, int, int)>[];
    for (final (index, e) in entities.indexed) {
      final g = group(e.groupId);
      final s = sectionOf(e);
      final names = e.name.all.map(normalizeMicroQuery).toList();
      final hay = [
        ...names,
        ...e.terms.map(normalizeMicroQuery),
        ...g.name.all.map(normalizeMicroQuery),
        ...s.name.all.map(normalizeMicroQuery),
        for (final i in imagesOf(e.id)) ...[
          normalizeMicroQuery(i.caption.text),
          ...i.caption.translation.all.map(normalizeMicroQuery),
          ?i.stain?.text.toLowerCase(),
        ],
      ];
      if (!words.every((w) => hay.any((h) => h.contains(w)))) continue;
      final score = names.any((n) => n.startsWith(whole))
          ? 0
          : names.any((n) => n.contains(whole))
          ? 1
          : e.terms.any((t) => normalizeMicroQuery(t).startsWith(words.first))
          ? 2
          : 3;
      scored.add((e, score, index));
    }
    scored.sort(
      (a, b) => a.$2 != b.$2 ? a.$2.compareTo(b.$2) : a.$3.compareTo(b.$3),
    );
    return [for (final (e, _, _) in scored) e];
  }
}
