import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../tools/calc_info.dart';
import 'differential_content.dart';
import 'differential_controller.dart';
import 'differential_sources.dart';

/// Leykoformula natijasini me'yor bilan solishtirish (tashxis emas).
///
/// Asosiy o'lchov — mutlaq son (×10⁹/l): foiz yolg'on taassurot berishi
/// mumkin (leykotsitlar kam bo'lsa 90 % neytrofil ham neytropeniya).
/// Me'yor laboratoriyaning o'z blankasi bo'yicha sozlanadi; sukut
/// qiymatlari — [diffDefaultLimitsRef] dagi jadval (kattalar).

/// Baholanadigan ko'rsatkich.
enum DiffMeasure {
  /// Neytrofillar jami (segment + tayoqcha) — mutlaq.
  neutrophils,
  lymphocytes,
  monocytes,
  eosinophils,
  basophils,

  /// Tayoqcha yadrolilar — foizda (chapga siljish belgisi).
  bandsPercent,
}

/// Me'yor oralig'i. [low] `null` — pastki chegara tekshirilmaydi.
@immutable
class DiffLimit {
  const DiffLimit({this.low, required this.high});

  final double? low;
  final double high;

  Map<String, Object?> toJson() => {'low': low, 'high': high};

  static DiffLimit? fromJson(Object? json) {
    if (json is! Map) return null;
    final low = (json['low'] as num?)?.toDouble();
    final high = (json['high'] as num?)?.toDouble();
    if (high == null || !high.isFinite || high <= 0) return null;
    if (low != null && (!low.isFinite || low < 0 || low >= high)) return null;
    return DiffLimit(low: low, high: high);
  }

  @override
  bool operator ==(Object other) =>
      other is DiffLimit && other.low == low && other.high == high;

  @override
  int get hashCode => Object.hash(low, high);
}

/// Sukut me'yorlari: Harrison's Manual of Medicine, 20-nashr (2020),
/// 64-1-jadval (95 % oraliq, kattalar). Tayoqchalar uchun mutlaq qiymat
/// jadvalda yo'q — foizdagi yuqori chegara Lyubina 1984, 6-jadvaldan
/// (1–6 %). MSD ta'riflari farq qiladi (eozinofiliya > 0,5; limfopeniya
/// < 1,0 ×10⁹/l) — bu `diffLimitsSourceNote` da aytilgan.
const diffDefaultLimits = <DiffMeasure, DiffLimit>{
  DiffMeasure.neutrophils: DiffLimit(low: 1.83, high: 7.25),
  DiffMeasure.lymphocytes: DiffLimit(low: 1.5, high: 4.0),
  DiffMeasure.monocytes: DiffLimit(low: 0.2, high: 0.95),
  DiffMeasure.eosinophils: DiffLimit(high: 0.7),
  DiffMeasure.basophils: DiffLimit(high: 0.15),
  DiffMeasure.bandsPercent: DiffLimit(high: 6),
};

const diffDefaultLimitsRef = CalcRef(
  DiffSources.harrisonManual,
  '20th ed., Table 64-1: Normal values for leukocyte concentration in blood',
);

/// Shoshilinch ko'rsatish kerak bo'lgan chegaralar (MSD Manual):
/// og'ir neytropeniya < 0,5 ×10⁹/l, o'rtacha va og'ir eozinofiliya
/// > 1,5 ×10⁹/l. Bu tashxis emas — shifokor/gematologga yo'llash belgisi.
const diffSevereNeutropenia = 0.5;
const diffMarkedEosinophilia = 1.5;
const diffNeutropeniaRef = CalcRef(
  DiffSources.msdNeutropenia,
  'Severity: severe < 500/mcL',
);
const diffEosinophiliaRef = CalcRef(
  DiffSources.msdEosinophilia,
  'Eosinophilia > 500/mcL; moderate 1500–5000/mcL; severe > 5000/mcL',
);
const diffLymphocytopeniaRef = CalcRef(
  DiffSources.msdLymphocytopenia,
  'Lymphocytopenia < 1000/mcL (adults)',
);

enum DiffFlag { low, high }

/// Bitta ko'rsatkich bahosi.
@immutable
class DiffMeasureResult {
  const DiffMeasureResult({
    required this.measure,
    required this.value,
    required this.limit,
    required this.flag,
  });

  final DiffMeasure measure;

  /// Mutlaq son (×10⁹/l) yoki [DiffMeasure.bandsPercent] uchun foiz.
  final double value;
  final DiffLimit limit;
  final DiffFlag? flag;

  /// Talqin bo'limidagi mos topilma (masalan, `neutropenia`).
  String? get findingId => switch ((measure, flag)) {
    (DiffMeasure.neutrophils, DiffFlag.high) => 'neutrophilia',
    (DiffMeasure.neutrophils, DiffFlag.low) => 'neutropenia',
    (DiffMeasure.lymphocytes, DiffFlag.high) => 'lymphocytosis',
    (DiffMeasure.lymphocytes, DiffFlag.low) => 'lymphopenia',
    (DiffMeasure.eosinophils, DiffFlag.high) => 'eosinophilia',
    (DiffMeasure.monocytes, DiffFlag.high) => 'monocytosis',
    (DiffMeasure.basophils, DiffFlag.high) => 'basophilia',
    (DiffMeasure.bandsPercent, DiffFlag.high) => 'left-shift',
    _ => null,
  };

  DiffFinding? get finding {
    final id = findingId;
    if (id == null) return null;
    for (final f in diffFindings) {
      if (f.id == id) return f;
    }
    return null;
  }
}

/// Butun natija bahosi.
@immutable
class DiffAssessment {
  const DiffAssessment({
    required this.results,
    required this.needsWbc,
    required this.refer,
    this.incomplete = false,
    this.counted = 0,
    this.target = 0,
  });

  /// Tartib: [DiffMeasure.values]. Leykotsitlar soni kiritilmagan bo'lsa
  /// faqat tayoqchalar (foiz) baholanadi.
  final List<DiffMeasureResult> results;

  /// Mutlaq sonlar uchun leykotsitlar soni kerak.
  final bool needsWbc;

  /// Shifokor/gematologga ko'rsatish kerak: "boshqa" hujayra (blast va
  /// h.k.), og'ir neytropeniya yoki yaqqol eozinofiliya.
  final bool refer;

  /// Sanash maqsadga (100/200 hujayra, JSST 2003 §9.10) yetmagan: ulushlar
  /// hali ishonchsiz — me'yor bilan solishtirilmaydi ([results] bo'sh).
  /// "Boshqa" hujayra (blast) ulushga bog'liq emas — [refer] tugallanmagan
  /// sanashda ham ko'rsatiladi.
  final bool incomplete;

  /// Sanalgan hujayralar va maqsad (tugallanmagan sanash izohi uchun).
  final int counted;
  final int target;

  /// "Hammasi me'yorda" faqat to'liq baho, mutlaq sonlar bor va yo'llash
  /// belgisi yo'q bo'lganda aytiladi (yo'llash bilan birga hech qachon).
  bool get allNormal =>
      !incomplete &&
      !needsWbc &&
      !refer &&
      results.isNotEmpty &&
      flagged.isEmpty;

  List<DiffMeasureResult> get flagged => [
    for (final r in results)
      if (r.flag != null) r,
  ];
}

double _measureValue(DiffRecord r, DiffMeasure m) => switch (m) {
  DiffMeasure.neutrophils =>
    r.absolute(DiffCell.segmented)! + r.absolute(DiffCell.band)!,
  DiffMeasure.lymphocytes => r.absolute(DiffCell.lymphocyte)!,
  DiffMeasure.monocytes => r.absolute(DiffCell.monocyte)!,
  DiffMeasure.eosinophils => r.absolute(DiffCell.eosinophil)!,
  DiffMeasure.basophils => r.absolute(DiffCell.basophil)!,
  DiffMeasure.bandsPercent => r.percent(DiffCell.band),
};

/// [record] ni [limits] bo'yicha baholaydi (yozuvda bo'lmagan ko'rsatkich
/// uchun — sukut qiymati).
DiffAssessment assessDifferential(
  DiffRecord record, [
  Map<DiffMeasure, DiffLimit> limits = diffDefaultLimits,
]) {
  if (record.total == 0) {
    return const DiffAssessment(results: [], needsWbc: false, refer: false);
  }
  final other = record.count(DiffCell.other) > 0;
  if (record.total < record.target) {
    return DiffAssessment(
      results: const [],
      needsWbc: false,
      refer: other,
      incomplete: true,
      counted: record.total,
      target: record.target,
    );
  }
  final hasWbc = record.wbc != null;
  final results = <DiffMeasureResult>[];
  for (final m in DiffMeasure.values) {
    if (!hasWbc && m != DiffMeasure.bandsPercent) continue;
    final limit = limits[m] ?? diffDefaultLimits[m]!;
    final v = _measureValue(record, m);
    final shown = _shown(m, v);
    final flag = shown > limit.high
        ? DiffFlag.high
        : (limit.low != null && shown < limit.low!)
        ? DiffFlag.low
        : null;
    results.add(
      DiffMeasureResult(measure: m, value: v, limit: limit, flag: flag),
    );
  }
  var refer = other;
  if (hasWbc) {
    // Yo'llash chegaralari ham ekrandagi (yaxlitlangan) qiymat bo'yicha:
    // 0,497 ekranda "0,50" — "< 0,5" deb yo'llanmaydi.
    final n = _shown(
      DiffMeasure.neutrophils,
      _measureValue(record, DiffMeasure.neutrophils),
    );
    final e = _shown(
      DiffMeasure.eosinophils,
      _measureValue(record, DiffMeasure.eosinophils),
    );
    if (n < diffSevereNeutropenia || e > diffMarkedEosinophilia) refer = true;
  }
  return DiffAssessment(
    results: results,
    needsWbc: !hasWbc,
    refer: refer,
    counted: record.total,
    target: record.target,
  );
}

/// Ekrandagi aniqlik: 2 kasr (×10⁹/l) yoki 1 kasr (%). Me'yor belgisi ham,
/// yo'llash chegarasi ham shu qiymat bo'yicha — ko'rinadigan son bilan bir.
double _shown(DiffMeasure m, double v) => m == DiffMeasure.bandsPercent
    ? (v * 10).roundToDouble() / 10
    : (v * 100).roundToDouble() / 100;

String encodeDiffLimits(Map<DiffMeasure, DiffLimit> limits) => jsonEncode({
  for (final e in limits.entries)
    if (diffDefaultLimits[e.key] != e.value) e.key.name: e.value.toJson(),
});

/// Faqat to'g'ri saqlangan qiymatlar olinadi, qolgani — sukut.
Map<DiffMeasure, DiffLimit> decodeDiffLimits(String? raw) {
  final out = Map<DiffMeasure, DiffLimit>.of(diffDefaultLimits);
  if (raw == null) return out;
  try {
    final json = jsonDecode(raw);
    if (json is! Map) return out;
    for (final m in DiffMeasure.values) {
      final l = DiffLimit.fromJson(json[m.name]);
      if (l != null) out[m] = l;
    }
  } on Object {
    // Buzilgan sozlama — sukut me'yorlari.
  }
  return out;
}
