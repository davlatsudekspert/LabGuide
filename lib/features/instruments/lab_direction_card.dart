import 'package:flutter/foundation.dart';

import '../content/content_model.dart';

/// Laboratoriya yo'nalishi (apparat kategoriyasidan alohida: TB, OIV...).
enum LabDirection {
  tb,
  hiv,
  virology,
  bacteriology,
  mycology,
  parasitology,
  hematology,
  coagulation,
  transfusion,
  biochemistry,
  immunology,
  urinalysis,
  cytology,
  histology,
  oncology,
  genetics,
  molecular,
  toxicology,
  reproductive,
  neonatal,
  transplant,
  general;

  static LabDirection parse(String raw) => values.firstWhere(
    (d) => d.name == raw,
    orElse: () => throw FormatException('unknown lab direction: $raw'),
  );
}

/// Platforma (apparat) va test (reagent/usul) HAR DOIM alohida kartalar.
enum LabCardKind {
  platform,
  test,
  method;

  static LabCardKind parse(String raw) => values.firstWhere(
    (k) => k.name == raw,
    orElse: () => throw FormatException('unknown card kind: $raw'),
  );
}

/// Tekshiruv holati. Standart — [needsReview]; boshqa qiymat dalilsiz qo'yilmaydi.
enum LabAuditStatus {
  needsReview,

  /// Manbasi hali yo'q: karta faqat bo'sh qoldiq (stub); ommaga ko'rsatilmaydi.
  needsSource;

  static LabAuditStatus parse(String raw) => switch (raw) {
    'NEEDS_REVIEW' => needsReview,
    'NEEDS_SOURCE' => needsSource,
    _ => throw FormatException('unknown audit status: $raw'),
  };
}

enum LabCardPriority {
  p1,
  p2,
  p3;

  static LabCardPriority parse(String raw) => switch (raw) {
    'P1' => p1,
    'P2' => p2,
    'P3' => p3,
    _ => throw FormatException('unknown priority: $raw'),
  };
}

/// Yo'nalish kartasidagi apparat SINFI sxematik chizmasi (LabGuide'ning o'z
/// original ishi, aniq model emas; docs/LAB_CARD_IMAGE_COVERAGE.md). Fayllar:
/// `assets/instruments/schematic/<key>_480.png` va `<key>_1200.png`; manba —
/// `tool/illustrations/schematic/gen.py`. Ro'yxatda yo'q kalit — katalog
/// yuklanishida [FormatException].
enum LabSchematic {
  massSpecGc('mass_spec_gc'),
  massSpecLc('mass_spec_lc'),
  maldiTof('maldi_tof'),
  microbialIdAst('microbial_id_ast'),
  bloodCulture('blood_culture'),
  mycobacterialCulture('mycobacterial_culture'),
  flowCytometer('flow_cytometer'),
  realTimePcr('real_time_pcr'),
  cartridgeMolecular('cartridge_molecular'),
  coagAnalyzer('coag_analyzer'),
  elisaReader('elisa_reader'),
  bscClass2('bsc_class2'),
  autoclave('autoclave'),
  bloodGasIse('blood_gas_ise'),
  hba1cAnalyzer('hba1c_analyzer'),
  labFridge('lab_fridge'),
  fluorescenceMicroscope('fluorescence_microscope'),
  casa('casa'),
  gelCardSystem('gel_card_system'),
  esrAnalyzer('esr_analyzer'),
  aggregometer('aggregometer'),
  electrophoresis('electrophoresis'),
  osmometer('osmometer'),
  tlc('tlc'),
  analyticalBalance('analytical_balance');

  const LabSchematic(this.key);

  final String key;

  /// Karta uchun kichik nusxa (~480 px).
  String get asset => 'assets/instruments/schematic/${key}_480.png';

  /// To'liq ekran uchun katta nusxa (~1200 px).
  String get assetLarge => 'assets/instruments/schematic/${key}_1200.png';

  static LabSchematic parse(String raw) => values.firstWhere(
    (v) => v.key == raw,
    orElse: () => throw FormatException('unknown lab card schematic: $raw'),
  );
}

/// Uch tilli matn + uni asoslagan manba id'lari (kamida bitta).
@immutable
class SourcedText {
  const SourcedText(this.text, this.sourceIds);

  factory SourcedText.fromJson(Object? json) {
    if (json is! Map) throw const FormatException('sourced text expected');
    final ids = (json['sources'] as List? ?? const []).cast<String>();
    if (ids.isEmpty) {
      throw const FormatException('lab card text without a source');
    }
    return SourcedText(LocalizedText.fromJson(json['text']), ids);
  }

  final LocalizedText text;
  final List<String> sourceIds;
}

/// Yangi (ixtiyoriy maydonli) yo'nalish kartasi. Yo'q maydon `null`/bo'sh —
/// ilova uni “tekshirilmagan” deb ko'rsatadi, hech narsa to'qilmaydi.
/// Foto maydoni yo'q: faqat LabGuide'ning o'z apparat sinfi sxemasi
/// ([schematic]) bo'lishi mumkin; stub kartada u ham bo'lmaydi.
@immutable
class LabDirectionCard {
  const LabDirectionCard({
    required this.id,
    required this.direction,
    required this.kind,
    required this.name,
    required this.instrumentVsTestNote,
    required this.technology,
    required this.specimens,
    required this.tasks,
    required this.principle,
    required this.limitations,
    required this.qcCalibrationNote,
    required this.preanalyticAnalyticErrors,
    required this.biosafety,
    required this.models,
    required this.linked,
    required this.sourceIds,
    required this.auditStatus,
    required this.expertReviewed,
    this.needsSourceReason,
    this.priority,
    this.sourceCaveat,
    this.schematic,
  });

  factory LabDirectionCard.fromJson(Map<String, Object?> j) {
    if (j['audit_status'] == 'NEEDS_SOURCE') return LabDirectionCard._stub(j);
    SourcedText? one(String k) =>
        j[k] == null ? null : SourcedText.fromJson(j[k]);
    List<SourcedText> many(String k) => [
      for (final e in j[k] as List? ?? const []) SourcedText.fromJson(e),
    ];
    final status = j['audit_status'] == null
        ? LabAuditStatus.needsReview
        : LabAuditStatus.parse(j['audit_status']! as String);
    final expert = j['expert_reviewed'] as bool? ?? false;
    if (expert) {
      throw FormatException('${j['id']}: expert_reviewed needs evidence');
    }
    final sources = (j['sources'] as List? ?? const []).cast<String>();
    if (sources.isEmpty) {
      throw FormatException('${j['id']}: lab card without sources');
    }
    return LabDirectionCard(
      id: j['id']! as String,
      direction: LabDirection.parse(j['lab_direction']! as String),
      kind: LabCardKind.parse(j['card_kind']! as String),
      name: LocalizedText.fromJson(j['name']),
      instrumentVsTestNote: j['instrument_vs_test_note'] == null
          ? null
          : LocalizedText.fromJson(j['instrument_vs_test_note']),
      technology: one('technology'),
      specimens: many('specimens'),
      tasks: many('tasks'),
      principle: one('principle'),
      limitations: many('limitations'),
      qcCalibrationNote: one('qc_calibration_note'),
      preanalyticAnalyticErrors: many('preanalytic_analytic_errors'),
      biosafety: one('biosafety'),
      models: (j['models'] as List? ?? const []).cast<String>(),
      linked: (j['linked'] as List? ?? const []).cast<String>(),
      sourceIds: sources,
      auditStatus: status,
      expertReviewed: expert,
      sourceCaveat: j['source_caveat'] == null
          ? null
          : LocalizedText.fromJson(j['source_caveat']),
      schematic: j['schematic'] == null
          ? null
          : LabSchematic.parse(j['schematic']! as String),
    );
  }

  /// NEEDS_SOURCE stub: faqat id, yo'nalish, tur, nom, sabab, ixtiyoriy
  /// ustuvorlik. Boshqa kontent maydonlari bo'sh bo'lishi shart.
  factory LabDirectionCard._stub(Map<String, Object?> j) {
    const allowed = {
      'id',
      'lab_direction',
      'card_kind',
      'name',
      'audit_status',
      'needs_source_reason',
      'priority',
      'expert_reviewed',
    };
    for (final e in j.entries) {
      if (allowed.contains(e.key)) continue;
      final v = e.value;
      final empty =
          v == null || (v is List && v.isEmpty) || (v is String && v.isEmpty);
      if (!empty) {
        throw FormatException('${j['id']}: stub has content field ${e.key}');
      }
    }
    if (j['expert_reviewed'] == true) {
      throw FormatException('${j['id']}: expert_reviewed needs evidence');
    }
    final reason = j['needs_source_reason'];
    if (reason is! String || reason.trim().isEmpty) {
      throw FormatException('${j['id']}: needs_source_reason missing');
    }
    return LabDirectionCard(
      id: j['id']! as String,
      direction: LabDirection.parse(j['lab_direction']! as String),
      kind: LabCardKind.parse(j['card_kind']! as String),
      name: LocalizedText.fromJson(j['name']),
      instrumentVsTestNote: null,
      technology: null,
      specimens: const [],
      tasks: const [],
      principle: null,
      limitations: const [],
      qcCalibrationNote: null,
      preanalyticAnalyticErrors: const [],
      biosafety: null,
      models: const [],
      linked: const [],
      sourceIds: const [],
      auditStatus: LabAuditStatus.needsSource,
      expertReviewed: false,
      needsSourceReason: reason,
      priority: j['priority'] == null
          ? null
          : LabCardPriority.parse(j['priority']! as String),
    );
  }

  final String id;
  final LabDirection direction;
  final LabCardKind kind;
  final LocalizedText name;

  /// Platforma yoki test ekanini ajratib turuvchi izoh.
  final LocalizedText? instrumentVsTestNote;
  final SourcedText? technology;
  final List<SourcedText> specimens;
  final List<SourcedText> tasks;
  final SourcedText? principle;
  final List<SourcedText> limitations;
  final SourcedText? qcCalibrationNote;
  final List<SourcedText> preanalyticAnalyticErrors;
  final SourcedText? biosafety;

  /// Rasmiy manbada tasdiqlangan model nomlari; bo'sh — tekshirilmagan.
  final List<String> models;

  /// Bog'langan kartalar (platforma <-> test).
  final List<String> linked;
  final List<String> sourceIds;
  final LabAuditStatus auditStatus;
  final bool expertReviewed;

  /// Faqat NEEDS_SOURCE uchun: nega manba yo'q (ichki, UI'da ko'rsatilmaydi).
  final String? needsSourceReason;
  final LabCardPriority? priority;

  /// Ixtiyoriy: manba eskirgan/tor bo'lsa kartada ko'rinadigan uch tilli
  /// ogohlantirish (ilovaning o'z izohi, manbaga bog'lanmagan).
  final LocalizedText? sourceCaveat;

  /// Ixtiyoriy: apparat sinfining sxematik chizmasi (platforma kartasida —
  /// o'zi, test/usul kartasida — u bajariladigan platformaniki). `null` —
  /// mazmunli apparat yo'q (chizma majburan qo'yilmaydi).
  final LabSchematic? schematic;

  /// NEEDS_SOURCE kartalar hech qachon ommaga ko'rsatilmaydi.
  bool get isPublic => auditStatus != LabAuditStatus.needsSource;

  Iterable<String> get allSourceIds => {
    ...sourceIds,
    for (final t in [
      technology,
      principle,
      qcCalibrationNote,
      biosafety,
      ...specimens,
      ...tasks,
      ...limitations,
      ...preanalyticAnalyticErrors,
    ])
      ...?t?.sourceIds,
  };
}
