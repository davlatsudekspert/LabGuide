/// Qo'lda bajariladigan laboratoriya usullari uchun hisoblar — sof Dart.
///
/// Har formula manbadan tekshirilgan (calc_info.dart, `manualCalcInfo`):
/// - hisob kamerasi va yadroli eritrotsit tuzatishi, leykoformuladan
///   mutlaq sonlar, retikulotsit % — WHO “Manual of basic techniques for a
///   health laboratory” (2003), 9.6, 9.12, 9.13 bo'limlari;
/// - tuzatilgan retikulotsit va RPI — Chueh 2022 (Blood Res), Kroll 2015;
/// - Light mezonlari — Light 1972, Harding 2025.
///
/// Klinik me'yor/chegara bu yerda yo'q: natija rang bilan “norma/patologiya”
/// deb belgilanmaydi. Kirish oraliqlari faqat yozish xatosini ushlash uchun.
library;

enum ManualField {
  cells,
  squares,
  squareArea,
  depth,
  dilution,
  wbc,
  neutrophilsSeg,
  neutrophilsBand,
  eosinophils,
  basophils,
  lymphocytes,
  monocytes,
  otherCells,
  nrbc,
  reticCounted,
  rbcExamined,
  hematocrit,
  rbcCount,
  pfProtein,
  serumProtein,
  pfLdh,
  serumLdh,
  ldhUln,
}

enum ManualIssue {
  /// Maydon bo'sh yoki son emas.
  missing,

  /// Qabul qilinadigan oraliqdan tashqarida (birlik/yozish xatosi).
  implausible,

  /// Qiymatlar o'zaro mos emas (leykoformula yig'indisi 100 emas va h.k.).
  inconsistent,
}

sealed class ManualOutcome<T> {
  const ManualOutcome();
}

final class ManualOk<T> extends ManualOutcome<T> {
  const ManualOk(this.value);
  final T value;
}

final class ManualFail<T> extends ManualOutcome<T> {
  const ManualFail(this.issue, {this.field, this.min, this.max, this.sum});
  final ManualIssue issue;
  final ManualField? field;
  final double? min;
  final double? max;

  /// Leykoformula: hisoblangan foizlar yig'indisi.
  final double? sum;
}

ManualFail<T>? _check<T>(
  ManualField field,
  double? v,
  double min,
  double max, {
  bool minExclusive = false,
}) {
  if (v == null) return ManualFail(ManualIssue.missing, field: field);
  final low = minExclusive ? v <= min : v < min;
  if (!v.isFinite || low || v > max) {
    return ManualFail(
      ManualIssue.implausible,
      field: field,
      min: min,
      max: max,
    );
  }
  return null;
}

// ---------------------------------------------------------------------------
// Hisob kamerasi (Neubauer, Goryayev, Fuchs–Rosenthal)
// WHO 2003, 9.6.3: hujayra/mm³ = sanalgan × suyultirish / (maydon × chuqurlik)
// ---------------------------------------------------------------------------

/// Bitta kvadrat maydoni (mm²). Kamera setkasi turiga qarab foydalanuvchi
/// tanlaydi; qiymatlar sof geometriya (1, 1/25, 1/400 mm²).
const chamberSquareAreas = <double>[1, 0.04, 0.0025];

/// Kamera chuqurligi (mm): 0,1 — Neubauer (WHO 9.6.2), 0,2 —
/// Fuchs–Rosenthal (WHO 8.3.3).
const chamberDepths = <double>[0.1, 0.2];

class ChamberResult {
  const ChamberResult({required this.perMicroLitre, required this.volume});

  /// Hujayra / µL (= /mm³) suyultirilmagan namunada.
  final double perMicroLitre;

  /// Sanalgan hajm, µL (= mm³).
  final double volume;

  /// ×10⁹/L (1 µL = 10⁻⁶ L).
  double get gigaPerLitre => perMicroLitre / 1000;

  /// ×10⁶/L — likvor kabi kam hujayrali suyuqliklar uchun.
  double get megaPerLitre => perMicroLitre;
}

ManualOutcome<ChamberResult> chamberCount({
  required double? cells,
  required double? squares,
  required double squareArea,
  required double depth,
  required double? dilution,
}) {
  final fail =
      _check<ChamberResult>(ManualField.cells, cells, 0, 100000) ??
      _check<ChamberResult>(ManualField.squares, squares, 1, 400) ??
      _check<ChamberResult>(ManualField.dilution, dilution, 1, 100000);
  if (fail != null) return fail;
  if (cells! != cells.roundToDouble()) {
    return const ManualFail(
      ManualIssue.implausible,
      field: ManualField.cells,
      min: 0,
      max: 100000,
    );
  }
  if (squares! != squares.roundToDouble()) {
    return const ManualFail(
      ManualIssue.implausible,
      field: ManualField.squares,
      min: 1,
      max: 400,
    );
  }
  if (!(squareArea > 0) || !(depth > 0)) {
    return const ManualFail(ManualIssue.missing, field: ManualField.squareArea);
  }
  final volume = squares * squareArea * depth;
  final perUl = cells / volume * dilution!;
  return ManualOk(ChamberResult(perMicroLitre: perUl, volume: volume));
}

// ---------------------------------------------------------------------------
// Leykoformuladan mutlaq sonlar va yadroli eritrotsit tuzatishi
// WHO 2003, 9.6.4 (tuzatish) va 9.13.3 (mutlaq son = ulush × WBC).
// ---------------------------------------------------------------------------

/// Leykoformula qatorlari (tartib — ekrandagidek).
const differentialFields = [
  ManualField.neutrophilsSeg,
  ManualField.neutrophilsBand,
  ManualField.eosinophils,
  ManualField.basophils,
  ManualField.lymphocytes,
  ManualField.monocytes,
  ManualField.otherCells,
];

/// Yig'indi 100 % dan qancha farq qilishi mumkin (200 hujayra sanalganda
/// yarim foizlar yaxlitlanadi).
const differentialSumTolerance = 0.5;

class DifferentialResult {
  const DifferentialResult({
    required this.wbcEntered,
    required this.wbcUsed,
    required this.nrbcAbsolute,
    required this.absolute,
    required this.percentSum,
  });

  /// Kiritilgan WBC, ×10⁹/L.
  final double wbcEntered;

  /// Hisobda ishlatilgan WBC (yadroli eritrotsitlar bo'yicha tuzatilgan
  /// bo'lsa — tuzatilgani), ×10⁹/L.
  final double wbcUsed;

  /// Yadroli eritrotsitlar, ×10⁹/L (kiritilmagan bo'lsa `null`).
  final double? nrbcAbsolute;

  /// Har tur uchun mutlaq son, ×10⁹/L (faqat kiritilgan qatorlar).
  final Map<ManualField, double> absolute;
  final double percentSum;

  bool get corrected => nrbcAbsolute != null;
}

/// [percents] — kiritilgan qatorlar (bo'sh qator — 0 emas, hisobga
/// kirmaydi). [nrbcPer100] — 100 leykotsitga yadroli eritrotsitlar soni
/// (ixtiyoriy).
ManualOutcome<DifferentialResult> differentialAbsolute({
  required double? wbc,
  required Map<ManualField, double> percents,
  double? nrbcPer100,
}) {
  final w = _check<DifferentialResult>(
    ManualField.wbc,
    wbc,
    0,
    1000,
    minExclusive: true,
  );
  if (w != null) return w;
  if (percents.isEmpty) {
    return const ManualFail(
      ManualIssue.missing,
      field: ManualField.neutrophilsSeg,
    );
  }
  for (final e in percents.entries) {
    final f = _check<DifferentialResult>(e.key, e.value, 0, 100);
    if (f != null) return f;
  }
  if (nrbcPer100 != null) {
    final f = _check<DifferentialResult>(ManualField.nrbc, nrbcPer100, 0, 1000);
    if (f != null) return f;
  }
  final sum = percents.values.fold<double>(0, (a, b) => a + b);
  if ((sum - 100).abs() > differentialSumTolerance) {
    return ManualFail(ManualIssue.inconsistent, sum: sum);
  }
  // WHO 9.6.4: NRBC = n × WBC / (100 + n); tuzatilgan WBC = WBC − NRBC.
  double? nrbc;
  var used = wbc!;
  if (nrbcPer100 != null && nrbcPer100 > 0) {
    nrbc = nrbcPer100 * wbc / (100 + nrbcPer100);
    used = wbc - nrbc;
  } else if (nrbcPer100 == 0) {
    nrbc = 0;
  }
  return ManualOk(
    DifferentialResult(
      wbcEntered: wbc,
      wbcUsed: used,
      nrbcAbsolute: nrbc,
      absolute: {for (final e in percents.entries) e.key: e.value / 100 * used},
      percentSum: sum,
    ),
  );
}

// ---------------------------------------------------------------------------
// Retikulotsitlar
// % va mutlaq son — WHO 2003, 9.12.4. Tuzatilgan % = % × Ht/45 (Chueh 2022).
// RPI = tuzatilgan % / yetilish koeffitsiyenti (Kroll 2015 jadvali).
// ---------------------------------------------------------------------------

/// Kattalar uchun “normal” gematokrit (Chueh 2022: “e.g., 45”).
const normalHematocrit = 45.0;

/// Yetilish koeffitsiyenti jadvali (Kroll 2015): (Ht %, koeffitsiyent).
const maturationTable = <(double, double)>[
  (45, 1.0),
  (35, 1.5),
  (25, 2.0),
  (20, 2.5),
];

/// Jadvaldagi eng yaqin Ht nuqtasining koeffitsiyenti. Teng masofada
/// kattaroq koeffitsiyent (ehtiyotkor — RPI past chiqadi). Bu ilova
/// qoidasi, manbada oraliq chegaralari berilmagan.
double suggestedMaturation(double hct) {
  var best = maturationTable.first;
  for (final row in maturationTable) {
    final d = (row.$1 - hct).abs();
    final bd = (best.$1 - hct).abs();
    if (d < bd || (d == bd && row.$2 > best.$2)) best = row;
  }
  return best.$2;
}

class ReticResult {
  const ReticResult({
    required this.percent,
    required this.corrected,
    required this.maturation,
    required this.maturationSuggested,
    required this.rpi,
    required this.hematocrit,
    this.absolute,
  });

  /// Kiritilgan Ht, %.
  final double hematocrit;

  /// Retikulotsitlar, eritrotsitlarga nisbatan %.
  final double percent;

  /// Ht bo'yicha tuzatilgan %.
  final double corrected;
  final double maturation;

  /// Koeffitsiyentni ilova taklif qildi (foydalanuvchi tanlamagan).
  final bool maturationSuggested;
  final double rpi;

  /// ×10⁹/L (RBC kiritilgan bo'lsa).
  final double? absolute;
}

ManualOutcome<ReticResult> reticulocytes({
  required double? counted,
  required double? examined,
  required double? hematocrit,
  double? rbc,
  double? maturation,
}) {
  final fail =
      _check<ReticResult>(ManualField.reticCounted, counted, 0, 100000) ??
      _check<ReticResult>(ManualField.rbcExamined, examined, 100, 100000) ??
      _check<ReticResult>(ManualField.hematocrit, hematocrit, 5, 75);
  if (fail != null) return fail;
  if (rbc != null) {
    final f = _check<ReticResult>(ManualField.rbcCount, rbc, 0.3, 10);
    if (f != null) return f;
  }
  if (counted! > examined!) {
    return const ManualFail(
      ManualIssue.inconsistent,
      field: ManualField.reticCounted,
    );
  }
  final pct = counted / examined * 100;
  final corrected = pct * hematocrit! / normalHematocrit;
  final factor = maturation ?? suggestedMaturation(hematocrit);
  return ManualOk(
    ReticResult(
      percent: pct,
      corrected: corrected,
      maturation: factor,
      maturationSuggested: maturation == null,
      rpi: corrected / factor,
      hematocrit: hematocrit,
      // WHO: C × 2n × 10⁹/L (500 eritrotsitda) = RBC(×10¹²) × % × 10.
      absolute: rbc == null ? null : rbc * pct * 10,
    ),
  );
}

// ---------------------------------------------------------------------------
// Light mezonlari (plevra suyuqligi). Light 1972; zamonaviy shakli — Harding
// 2025, Table 1: ekssudat — kamida bitta mezon bajarilsa.
// ---------------------------------------------------------------------------

enum LightVerdict {
  /// Kamida bitta mezon bajarildi.
  exudate,

  /// Uchala mezon ham bajarilmadi.
  transudate,

  /// Ikki mezon bajarilmadi, uchinchisi (ULN yo'q) baholanmadi.
  incomplete,
}

class LightResult {
  const LightResult({
    required this.proteinRatio,
    required this.ldhRatio,
    required this.ldhOfUln,
    required this.verdict,
  });

  final double proteinRatio;
  final double ldhRatio;

  /// Suyuqlik LDH / zardob LDH ning yuqori chegarasi (ULN kiritilgan bo'lsa).
  final double? ldhOfUln;
  final LightVerdict verdict;

  bool get proteinMet => proteinRatio > 0.5;
  bool get ldhRatioMet => ldhRatio > 0.6;
  bool? get ldhUlnMet => ldhOfUln == null ? null : ldhOfUln! > 2 / 3;
}

ManualOutcome<LightResult> lightCriteria({
  required double? pfProtein,
  required double? serumProtein,
  required double? pfLdh,
  required double? serumLdh,
  double? ldhUln,
}) {
  final fail =
      _check<LightResult>(ManualField.pfProtein, pfProtein, 0, 200) ??
      _check<LightResult>(
        ManualField.serumProtein,
        serumProtein,
        0,
        200,
        minExclusive: true,
      ) ??
      _check<LightResult>(ManualField.pfLdh, pfLdh, 0, 100000) ??
      _check<LightResult>(
        ManualField.serumLdh,
        serumLdh,
        0,
        100000,
        minExclusive: true,
      );
  if (fail != null) return fail;
  if (ldhUln != null) {
    final f = _check<LightResult>(
      ManualField.ldhUln,
      ldhUln,
      0,
      100000,
      minExclusive: true,
    );
    if (f != null) return f;
  }
  final protein = pfProtein! / serumProtein!;
  final ldh = pfLdh! / serumLdh!;
  final ofUln = ldhUln == null ? null : pfLdh / ldhUln;
  final r = LightResult(
    proteinRatio: protein,
    ldhRatio: ldh,
    ldhOfUln: ofUln,
    verdict: LightVerdict.transudate,
  );
  final met = r.proteinMet || r.ldhRatioMet || (r.ldhUlnMet ?? false);
  return ManualOk(
    LightResult(
      proteinRatio: protein,
      ldhRatio: ldh,
      ldhOfUln: ofUln,
      verdict: met
          ? LightVerdict.exudate
          : (ofUln == null ? LightVerdict.incomplete : LightVerdict.transudate),
    ),
  );
}
