import 'package:flutter/foundation.dart';

import '../content/content_model.dart';

/// Laboratoriya yo'nalishi (apparat kategoriyasidan alohida: TB, OIV...).
enum LabDirection {
  tb,
  hiv;

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
  needsReview;

  static LabAuditStatus parse(String raw) => switch (raw) {
    'NEEDS_REVIEW' => needsReview,
    _ => throw FormatException('unknown audit status: $raw'),
  };
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
/// Rasm maydoni yo'q: faqat LabGuide'ning o'z sxemasi bo'lishi mumkin.
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
  });

  factory LabDirectionCard.fromJson(Map<String, Object?> j) {
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
