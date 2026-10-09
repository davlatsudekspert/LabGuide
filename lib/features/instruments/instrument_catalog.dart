import 'package:flutter/foundation.dart';

import '../content/content_model.dart';

/// Apparat yo'nalishi (laboratoriya bo'limi).
enum InstrumentCategory {
  chemistry,
  hematology,
  immunoassay,
  urinalysis;

  static InstrumentCategory parse(String raw) => values.firstWhere(
    (c) => c.name == raw,
    orElse: () => throw FormatException('unknown category: $raw'),
  );
}

/// Kartadagi ma'lumot qay darajada tasdiqlangan. Har bosqich oldingisini
/// o'z ichiga oladi; dalilsiz yuqori holat qo'yilmaydi ([InstrumentCatalog]
/// validatori tekshiradi).
enum InstrumentStatus {
  /// Rasmiy sahifa/buklet/regulyator hujjatidan apparat ma'lumoti.
  deviceInfo,

  /// Rasmiy operator qo'llanmasi (versiyasi bilan) qo'lda va solishtirilgan.
  ifuAvailable,

  /// Mustaqil laboratoriya mutaxassisi tekshirgan.
  expertReviewed;

  static InstrumentStatus parse(String raw) => switch (raw) {
    'device_info' => deviceInfo,
    'ifu_available' => ifuAvailable,
    'expert_reviewed' => expertReviewed,
    _ => throw FormatException('unknown instrument status: $raw'),
  };
}

/// Reagent tizimining ochiqligi — faqat rasmiy manbada aytilgan bo'lsa.
enum ReagentSystemKind {
  open,
  partlyOpen,
  closed,
  unknown;

  static ReagentSystemKind parse(String raw) => switch (raw) {
    'open' => open,
    'partly_open' => partlyOpen,
    'closed' => closed,
    'unknown' => unknown,
    _ => throw FormatException('unknown reagent system: $raw'),
  };
}

enum ManualAccess {
  public,
  login,
  notPublic;

  static ManualAccess parse(String raw) => switch (raw) {
    'public' => public,
    'login' => login,
    'not_public' => notPublic,
    _ => throw FormatException('unknown manual access: $raw'),
  };
}

@immutable
class CatalogSource {
  const CatalogSource({
    required this.id,
    required this.title,
    required this.url,
    required this.accessed,
    this.docRef,
  });

  factory CatalogSource.fromJson(Map<String, Object?> j) {
    final url = j['url']! as String;
    if (!url.startsWith('https://')) {
      throw FormatException('source url must be https: $url');
    }
    return CatalogSource(
      id: j['id']! as String,
      title: j['title']! as String,
      url: url,
      accessed: j['accessed']! as String,
      docRef: j['doc_ref'] as String?,
    );
  }

  final String id;
  final String title;
  final String url;
  final String accessed;

  /// Hujjat raqami/versiyasi (masalan, “981015/2021-11”, “P/N …”).
  final String? docRef;
}

/// Rasmiy manbadan so'zma-so'z iqtibos.
@immutable
class SourcedQuote {
  const SourcedQuote(this.quote, this.sourceId);

  factory SourcedQuote.fromJson(Map<String, Object?> j) {
    final quote = (j['quote']! as String).trim();
    if (quote.isEmpty) throw const FormatException('empty quote');
    return SourcedQuote(quote, j['source']! as String);
  }

  final String quote;
  final String sourceId;
}

/// Oddiy tilda tushuntirish + uni asoslovchi iqtiboslar.
@immutable
class ExplainedText {
  const ExplainedText(this.text, this.quotes);

  factory ExplainedText.fromJson(Map<String, Object?> j) {
    final quotes = [
      for (final q in j['quotes']! as List)
        SourcedQuote.fromJson((q as Map).cast<String, Object?>()),
    ];
    if (quotes.isEmpty) {
      throw const FormatException('explanation without a source quote');
    }
    return ExplainedText(LocalizedText.fromJson(j['text']), quotes);
  }

  final LocalizedText text;
  final List<SourcedQuote> quotes;
}

@immutable
class InstrumentFact {
  const InstrumentFact(this.label, this.value, this.sourceId);

  factory InstrumentFact.fromJson(Map<String, Object?> j) => InstrumentFact(
    LocalizedText.fromJson(j['label']),
    j['value']! as String,
    j['source']! as String,
  );

  final LocalizedText label;

  /// Manbadagi qiymat o'zgartirilmasdan (birlik va yozilishi bilan).
  final String value;
  final String sourceId;
}

/// Rasmiy manbada apparatda “validated setting” bor deb ko'rsatilgan
/// reagent. Parametrlar emas — faqat moslik dalili.
@immutable
class ValidatedReagent {
  const ValidatedReagent({
    required this.analyteId,
    required this.name,
    required this.refs,
    required this.sourceId,
  });

  factory ValidatedReagent.fromJson(Map<String, Object?> j) => ValidatedReagent(
    analyteId: j['analyte']! as String,
    name: j['name']! as String,
    refs: (j['refs']! as List).cast<String>(),
    sourceId: j['source']! as String,
  );

  final String analyteId;
  final String name;
  final List<String> refs;
  final String sourceId;
}

@immutable
class InstrumentImage {
  const InstrumentImage({
    required this.asset,
    required this.license,
    required this.licenseUrl,
    required this.author,
    required this.sourcePage,
    required this.caption,
  });

  factory InstrumentImage.fromJson(Map<String, Object?> j) {
    final license = j['license']! as String;
    // Faqat erkin litsenziyalar (NC/ND emas).
    const allowed = {
      'CC0',
      'CC BY 4.0',
      'CC BY-SA 4.0',
      'CC BY 2.0',
      'CC BY-SA 3.0',
      'Public domain',
    };
    if (!allowed.contains(license)) {
      throw FormatException('image licence not allowed: $license');
    }
    return InstrumentImage(
      asset: j['asset']! as String,
      license: license,
      licenseUrl: j['license_url']! as String,
      author: j['author']! as String,
      sourcePage: j['source_page']! as String,
      caption: LocalizedText.fromJson(j['caption']),
    );
  }

  final String asset;
  final String license;
  final String licenseUrl;
  final String author;
  final String sourcePage;
  final LocalizedText caption;
}

@immutable
class DocsPortal {
  const DocsPortal({
    required this.name,
    required this.url,
    required this.login,
    this.note,
  });

  factory DocsPortal.fromJson(Map<String, Object?> j) => DocsPortal(
    name: j['name']! as String,
    url: j['url']! as String,
    login: j['login'] as bool?,
    note: j['note'] == null ? null : LocalizedText.fromJson(j['note']),
  );

  final String name;
  final String url;

  /// `null` — tekshirilmagan.
  final bool? login;
  final LocalizedText? note;
}

@immutable
class InstrumentMaker {
  const InstrumentMaker({
    required this.id,
    required this.name,
    required this.phase,
    required this.website,
    this.docs,
  });

  factory InstrumentMaker.fromJson(Map<String, Object?> j) => InstrumentMaker(
    id: j['id']! as String,
    name: j['name']! as String,
    phase: j['phase']! as int,
    website: j['website']! as String,
    docs: j['docs'] == null
        ? null
        : DocsPortal.fromJson((j['docs']! as Map).cast<String, Object?>()),
  );

  final String id;
  final String name;

  /// 1 — modellar kataloglangan; 2 — keyingi bosqich (modellar hali yo'q).
  final int phase;
  final String website;
  final DocsPortal? docs;
}

@immutable
class CategoryInfo {
  const CategoryInfo({
    required this.category,
    required this.name,
    required this.subtitle,
    required this.terms,
    required this.illustration,
  });

  factory CategoryInfo.fromJson(Map<String, Object?> j) => CategoryInfo(
    category: InstrumentCategory.parse(j['id']! as String),
    name: LocalizedText.fromJson(j['name']),
    subtitle: LocalizedText.fromJson(j['sub']),
    terms: (j['terms']! as List).cast<String>(),
    illustration: j['illustration']! as String,
  );

  final InstrumentCategory category;
  final LocalizedText name;
  final LocalizedText subtitle;

  /// Qidiruv sinonimlari (uz/ru/en).
  final List<String> terms;

  /// LabGuide'ning o'z sxematik chizmasi (aniq model fotosi emas).
  final String illustration;
}

@immutable
class InstrumentModel {
  const InstrumentModel({
    required this.id,
    required this.makerId,
    required this.model,
    required this.category,
    required this.kind,
    required this.aliases,
    required this.localNames,
    required this.purpose,
    required this.principle,
    required this.facts,
    required this.maintenance,
    required this.manualAccess,
    required this.manualNote,
    required this.reagentSystem,
    required this.reagentSystemQuote,
    required this.validatedReagents,
    required this.image,
    required this.status,
  });

  factory InstrumentModel.fromJson(Map<String, Object?> j) {
    Map<String, Object?>? map(String k) =>
        (j[k] as Map?)?.cast<String, Object?>();
    final manual = map('manual')!;
    final reagent = map('reagent_system')!;
    return InstrumentModel(
      id: j['id']! as String,
      makerId: j['maker']! as String,
      model: j['model']! as String,
      category: InstrumentCategory.parse(j['category']! as String),
      kind: LocalizedText.fromJson(j['kind']),
      aliases: (j['aliases'] as List? ?? const []).cast<String>(),
      localNames: (map('local_names') ?? const {}).cast<String, String>(),
      purpose: map('purpose') == null
          ? null
          : ExplainedText.fromJson(map('purpose')!),
      principle: map('principle') == null
          ? null
          : ExplainedText.fromJson(map('principle')!),
      facts: [
        for (final f in j['facts'] as List? ?? const [])
          InstrumentFact.fromJson((f as Map).cast<String, Object?>()),
      ],
      maintenance: [
        for (final m in j['maintenance'] as List? ?? const [])
          SourcedQuote.fromJson((m as Map).cast<String, Object?>()),
      ],
      manualAccess: ManualAccess.parse(manual['access']! as String),
      manualNote: LocalizedText.fromJson(manual['note']),
      reagentSystem: ReagentSystemKind.parse(reagent['kind']! as String),
      reagentSystemQuote: reagent['quote'] == null
          ? null
          : SourcedQuote.fromJson(
              (reagent['quote']! as Map).cast<String, Object?>(),
            ),
      validatedReagents: [
        for (final r in j['validated_reagents'] as List? ?? const [])
          ValidatedReagent.fromJson((r as Map).cast<String, Object?>()),
      ],
      image: map('image') == null
          ? null
          : InstrumentImage.fromJson(map('image')!),
      status: InstrumentStatus.parse(j['status']! as String),
    );
  }

  final String id;
  final String makerId;
  final String model;
  final InstrumentCategory category;
  final LocalizedText kind;
  final List<String> aliases;
  final Map<String, String> localNames;

  /// `null` — rasmiy manbada aniq maqsad yozilmagan (ilova shuni aytadi).
  final ExplainedText? purpose;
  final ExplainedText? principle;
  final List<InstrumentFact> facts;

  /// Rasmiy manbadagi parvarish haqidagi iqtiboslar. Bosqichma-bosqich
  /// kundalik ro'yxat faqat rasmiy qo'llanmadan qo'shiladi.
  final List<SourcedQuote> maintenance;
  final ManualAccess manualAccess;
  final LocalizedText manualNote;
  final ReagentSystemKind reagentSystem;
  final SourcedQuote? reagentSystemQuote;
  final List<ValidatedReagent> validatedReagents;
  final InstrumentImage? image;
  final InstrumentStatus status;

  Iterable<SourcedQuote> get _allQuotes => [
    ...?purpose?.quotes,
    ...?principle?.quotes,
    ...maintenance,
    ?reagentSystemQuote,
  ];

  Set<String> get sourceIds => {
    for (final q in _allQuotes) q.sourceId,
    for (final f in facts) f.sourceId,
    for (final r in validatedReagents) r.sourceId,
  };

  List<ValidatedReagent> reagentsFor(String analyteId) => [
    for (final r in validatedReagents)
      if (r.analyteId == analyteId) r,
  ];
}

/// Qidiruv uchun normallashtirish: kichik harf, apostrof turlari, bo'shliq
/// va chiziqchalar e'tiborsiz (“BS-240” = “bs240” = “BS 240”).
String normalizeInstrumentQuery(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[ʻʼ‘’`\']'), '')
    .replaceAll(RegExp(r'[\s\-_/.()]+'), '');

@immutable
class InstrumentCatalog {
  const InstrumentCatalog({
    required this.version,
    required this.categories,
    required this.makers,
    required this.sources,
    required this.models,
  });

  factory InstrumentCatalog.fromJson(
    Map<String, Object?> json, {
    Set<String> knownAnalytes = const {},
  }) {
    if (json['schema_version'] != 1) {
      throw FormatException('unsupported schema: ${json['schema_version']}');
    }
    List<Map<String, Object?>> list(String k) => [
      for (final e in json[k]! as List) (e as Map).cast<String, Object?>(),
    ];
    final catalog = InstrumentCatalog(
      version: json['catalog_version']! as String,
      categories: list('categories').map(CategoryInfo.fromJson).toList(),
      makers: list('makers').map(InstrumentMaker.fromJson).toList(),
      sources: {
        for (final s in list('sources').map(CatalogSource.fromJson)) s.id: s,
      },
      models: list('models').map(InstrumentModel.fromJson).toList(),
    );
    catalog._validate(knownAnalytes);
    return catalog;
  }

  final String version;
  final List<CategoryInfo> categories;
  final List<InstrumentMaker> makers;
  final Map<String, CatalogSource> sources;
  final List<InstrumentModel> models;

  void _validate(Set<String> knownAnalytes) {
    final makerIds = {for (final m in makers) m.id};
    final ids = <String>{};
    for (final m in models) {
      if (!ids.add(m.id)) throw FormatException('duplicate model: ${m.id}');
      if (!makerIds.contains(m.makerId)) {
        throw FormatException('${m.id}: unknown maker ${m.makerId}');
      }
      if (maker(m.makerId).phase != 1) {
        throw FormatException('${m.id}: maker not catalogued yet');
      }
      for (final s in m.sourceIds) {
        if (!sources.containsKey(s)) {
          throw FormatException('${m.id}: unknown source $s');
        }
      }
      if (m.purpose == null && m.principle == null && m.facts.isEmpty) {
        throw FormatException('${m.id}: empty card');
      }
      // Yuqori holat dalilsiz qo'yilmaydi: hozircha katalogda rasmiy
      // qo'llanma versiyasi yoki mutaxassis tekshiruvi qaydi yo'q.
      if (m.status != InstrumentStatus.deviceInfo) {
        throw FormatException('${m.id}: ${m.status} needs evidence fields');
      }
      if (knownAnalytes.isNotEmpty) {
        for (final r in m.validatedReagents) {
          if (!knownAnalytes.contains(r.analyteId)) {
            throw FormatException('${m.id}: unknown analyte ${r.analyteId}');
          }
        }
      }
    }
  }

  InstrumentMaker maker(String id) => makers.firstWhere(
    (m) => m.id == id,
    orElse: () => throw StateError('maker $id'),
  );

  InstrumentModel? model(String id) =>
      models.where((m) => m.id == id).firstOrNull;

  CategoryInfo category(InstrumentCategory c) =>
      categories.firstWhere((x) => x.category == c);

  List<InstrumentModel> inCategory(InstrumentCategory c, {String? makerId}) => [
    for (final m in models)
      if (m.category == c && (makerId == null || m.makerId == makerId)) m,
  ];

  /// Shu yo'nalishda modeli bor ishlab chiqaruvchilar (katalog tartibida).
  List<(InstrumentMaker, int)> makersIn(InstrumentCategory c) => [
    for (final mk in makers)
      if (inCategory(c, makerId: mk.id).length case final n when n > 0) (mk, n),
  ];

  List<InstrumentMaker> get plannedMakers => [
    for (final m in makers)
      if (m.phase > 1) m,
  ];

  /// Model, sinonim, ishlab chiqaruvchi va yo'nalish nomi (uch tilda) bo'yicha
  /// qidiruv. Aniq model mosligi birinchi.
  List<InstrumentModel> search(String query) {
    final words = query
        .split(RegExp(r'\s+'))
        .map(normalizeInstrumentQuery)
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    final whole = normalizeInstrumentQuery(query);
    final scored = <(InstrumentModel, int)>[];
    for (final m in models) {
      final mk = maker(m.makerId);
      final cat = category(m.category);
      final names = [
        m.model,
        ...m.aliases,
        ...m.localNames.values,
      ].map(normalizeInstrumentQuery).toList();
      final hay = [
        ...names,
        normalizeInstrumentQuery(mk.name),
        normalizeInstrumentQuery(mk.id),
        ...cat.name.all.map(normalizeInstrumentQuery),
        ...cat.terms.map(normalizeInstrumentQuery),
        ...m.kind.all.map(normalizeInstrumentQuery),
      ];
      if (!words.every((w) => hay.any((h) => h.contains(w)))) continue;
      final score = names.any((n) => n == whole)
          ? 0
          : names.any((n) => n.contains(whole))
          ? 1
          : 2;
      scored.add((m, score));
    }
    scored.sort((a, b) => a.$2.compareTo(b.$2));
    return [for (final (m, _) in scored) m];
  }
}
