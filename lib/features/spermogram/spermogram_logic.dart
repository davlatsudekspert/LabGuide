/// Spermogramma: sanash va baholash mantig'i (UI'siz, test qilinadi).
///
/// Chegaralar — JSST 2021 (6-nashr) Table 8.3 dagi pastki 5-persentil
/// ([spermLimits]). Atamalar — JSST 2010 (5-nashr) Table A1.3 ta'riflari:
/// 6-nashrda atamalar uchun alohida chegara berilmagan (EAU 11.3.2).
/// Natija tashxis emas — faqat "ko'rsatishi mumkin".
library;

// ───────────────────────── Pastki chegaralar ─────────────────────────

/// Baholanadigan ko'rsatkichlar.
enum SpermParam {
  volume,
  concentration,
  totalNumber,
  totalMotility,
  progressive,
  vitality,
  normalForms,
}

/// JSST 2021, Table 8.3 (p. 213): pastki 5-persentil va 95% IO, mediana.
class SpermLimit {
  const SpermLimit({
    required this.param,
    required this.lower,
    required this.ciLow,
    required this.ciHigh,
    required this.median,
    required this.n,
  });

  final SpermParam param;

  /// Pastki 5-persentil (pastki referens chegara).
  final double lower;

  /// 95% ishonch oralig'i.
  final double ciLow;
  final double ciHigh;

  /// 50-persentil.
  final double median;

  /// Jadvaldagi erkaklar soni (N).
  final int n;
}

const spermLimits = <SpermLimit>[
  SpermLimit(
    param: SpermParam.volume,
    lower: 1.4,
    ciLow: 1.3,
    ciHigh: 1.5,
    median: 3.0,
    n: 3586,
  ),
  SpermLimit(
    param: SpermParam.concentration,
    lower: 16,
    ciLow: 15,
    ciHigh: 18,
    median: 66,
    n: 3587,
  ),
  SpermLimit(
    param: SpermParam.totalNumber,
    lower: 39,
    ciLow: 35,
    ciHigh: 40,
    median: 210,
    n: 3584,
  ),
  SpermLimit(
    param: SpermParam.totalMotility,
    lower: 42,
    ciLow: 40,
    ciHigh: 43,
    median: 64,
    n: 3488,
  ),
  SpermLimit(
    param: SpermParam.progressive,
    lower: 30,
    ciLow: 29,
    ciHigh: 31,
    median: 55,
    n: 3389,
  ),
  SpermLimit(
    param: SpermParam.vitality,
    lower: 54,
    ciLow: 50,
    ciHigh: 56,
    median: 78,
    n: 1337,
  ),
  SpermLimit(
    param: SpermParam.normalForms,
    lower: 4,
    ciLow: 3.9,
    ciHigh: 4.0,
    median: 14,
    n: 3335,
  ),
];

SpermLimit spermLimit(SpermParam p) =>
    spermLimits.firstWhere((l) => l.param == p);

/// pH: JSST 2021 §2.4.2.5 — 7,2 dan past qiymat urug' pufakchasi ishqoriy
/// suyuqligi yetishmasligini (yoki siydik aralashganini) ko'rsatishi mumkin.
/// Bu Table 8.3 dagi persentil emas.
const spermPhLow = 7.2;

// ───────────────────────── Sanash ─────────────────────────

/// JSST 2021 §2.4.6.1: harakatchanlikning to'rt toifasi (a, b, c, d).
enum MotilityGrade { rapid, slow, nonProgressive, immotile }

/// JSST: har bir takrorda taxminan 200 ta spermatozoid (§2.4.6, p. 24).
const spermWhoTarget = 200;
const spermTargets = [100, spermWhoTarget];

/// Butun foizlar: yig'indi 100 bo'lmasa (99 yoki 101), eng katta guruh
/// tuzatiladi — JSST 2021 §2.4.6.2 qoidasi. [counts] bo'sh bo'lsa — nollar.
List<int> roundedPercents(List<int> counts) {
  final total = counts.fold<int>(0, (a, b) => a + b);
  if (total == 0) return List.filled(counts.length, 0);
  final r = <int>[for (final c in counts) (c * 100 / total).round()];
  final diff = 100 - r.fold<int>(0, (a, b) => a + b);
  if (diff != 0) {
    var dominant = 0;
    for (var i = 1; i < counts.length; i++) {
      if (counts[i] > counts[dominant]) dominant = i;
    }
    r[dominant] += diff;
  }
  return r;
}

/// Harakatchanlik hisoblagichi: bosish +1, bekor qilish — oxirgi bosish.
/// Maqsadga yetgach ham sanash to'xtatilmaydi: JSST bo'yicha joriy maydonda
/// barcha toifalar sanab bo'linmaguncha davom etiladi (§2.4.6, p. 24).
class MotilityCount {
  final _counts = {for (final g in MotilityGrade.values) g: 0};
  final _history = <MotilityGrade>[];

  int count(MotilityGrade g) => _counts[g]!;
  int get total => _history.length;
  bool get isEmpty => total == 0;
  bool get canUndo => _history.isNotEmpty;

  void add(MotilityGrade g) {
    _counts[g] = _counts[g]! + 1;
    _history.add(g);
  }

  void undo() {
    if (_history.isEmpty) return;
    final g = _history.removeLast();
    _counts[g] = _counts[g]! - 1;
  }

  void reset() {
    _history.clear();
    for (final g in MotilityGrade.values) {
      _counts[g] = 0;
    }
  }

  /// To'rt toifa foizi (butun, yig'indi 100).
  List<int> get percents =>
      roundedPercents([for (final g in MotilityGrade.values) count(g)]);

  /// Progressiv harakat (PR = a + b), %.
  double? get progressive => isEmpty
      ? null
      : (count(MotilityGrade.rapid) + count(MotilityGrade.slow)) * 100 / total;

  /// Umumiy harakatchanlik (PR + NP = a + b + c), %.
  double? get totalMotility =>
      isEmpty ? null : (total - count(MotilityGrade.immotile)) * 100 / total;
}

/// JSST 2021 §2.4.9.6: nuqson sohalari — bosh (H), bo'yin va o'rta qism
/// (NM), dum (T), ortiqcha qoldiq sitoplazma (C).
enum MorphDefect { head, neckMidpiece, tail, cytoplasm }

/// Morfologiya hisoblagichi: har spermatozoid bir marta sanaladi; anormal
/// hujayraning har bir nuqsoni alohida belgilanadi (§2.4.9.6, p. 52).
class MorphologyCount {
  final _history = <Set<MorphDefect>>[];

  int get total => _history.length;
  bool get isEmpty => total == 0;
  bool get canUndo => _history.isNotEmpty;
  int get normal => _history.where((d) => d.isEmpty).length;
  int get abnormal => total - normal;

  int defect(MorphDefect d) => _history.where((s) => s.contains(d)).length;

  void addNormal() => _history.add(const {});

  /// Anormal hujayra: kamida bitta nuqson bo'lishi shart.
  bool addAbnormal(Set<MorphDefect> defects) {
    if (defects.isEmpty) return false;
    _history.add(Set.unmodifiable(defects));
    return true;
  }

  void undo() {
    if (_history.isNotEmpty) _history.removeLast();
  }

  void reset() => _history.clear();

  double? get normalPercent => isEmpty ? null : normal * 100 / total;

  /// Nuqsonli hujayralar ulushi (hamma sanalganlarga nisbatan, %).
  /// Bir hujayrada bir necha nuqson bo'lishi mumkin — yig'indi 100 dan oshadi.
  double? defectPercent(MorphDefect d) =>
      isEmpty ? null : defect(d) * 100 / total;

  /// Teratozoospermiya indeksi: nuqsonlar soni / anormal hujayralar soni
  /// (JSST 2021 §2.5.17.2 misoli, p. 80–81).
  double? get tzi {
    if (abnormal == 0) return null;
    final sum = MorphDefect.values.fold(0, (a, d) => a + defect(d));
    return sum / abnormal;
  }
}

// ───────────────────────── Baholash ─────────────────────────

/// Kiritilgan natijalar (bo'sh maydon — `null`).
class SpermInput {
  const SpermInput({
    this.volume,
    this.concentration,
    this.progressive,
    this.totalMotility,
    this.vitality,
    this.normalForms,
    this.ph,
  });

  /// mL.
  final double? volume;

  /// 10⁶/mL.
  final double? concentration;
  final double? progressive;
  final double? totalMotility;
  final double? vitality;
  final double? normalForms;
  final double? ph;

  /// Umumiy son = konsentratsiya × hajm (JSST 2021 §2.4.8.7), 10⁶.
  double? get totalNumber =>
      volume == null || concentration == null ? null : volume! * concentration!;

  bool get isEmpty => [
    volume,
    concentration,
    progressive,
    totalMotility,
    vitality,
    normalForms,
    ph,
  ].every((v) => v == null);
}

/// Atamalar (JSST 2010 Table A1.3 ta'riflari).
enum SpermTerm {
  normozoospermia,
  oligozoospermia,
  asthenozoospermia,
  teratozoospermia,
  oligoasthenozoospermia,
  oligoteratozoospermia,
  asthenoteratozoospermia,
  oligoasthenoteratozoospermia,
  azoospermia,
  necrozoospermia,
}

/// Kiritishdagi xato (masalan, PR umumiy harakatchanlikdan katta).
enum SpermInputError { progressiveAboveTotal }

class SpermAssessment {
  const SpermAssessment({
    required this.below,
    required this.terms,
    required this.countBasis,
    required this.lowPh,
    required this.errors,
  });

  /// Pastki chegaradan past ko'rsatkichlar.
  final Set<SpermParam> below;

  /// Ko'rsatishi mumkin bo'lgan atamalar (tashxis emas).
  final List<SpermTerm> terms;

  /// Oligozoospermiya qaysi ko'rsatkich bo'yicha: umumiy son (afzal) yoki
  /// konsentratsiya; son kiritilmagan bo'lsa `null`.
  final SpermParam? countBasis;

  /// pH 7,2 dan past.
  final bool lowPh;

  final Set<SpermInputError> errors;

  bool get hasFindings => below.isNotEmpty || terms.isNotEmpty || lowPh;
}

SpermAssessment assessSperm(SpermInput i) {
  final errors = <SpermInputError>{};
  if (i.progressive != null &&
      i.totalMotility != null &&
      i.progressive! > i.totalMotility!) {
    errors.add(SpermInputError.progressiveAboveTotal);
  }
  final below = <SpermParam>{};
  void check(SpermParam p, double? v) {
    if (v != null && v < spermLimit(p).lower) below.add(p);
  }

  check(SpermParam.volume, i.volume);
  check(SpermParam.concentration, i.concentration);
  check(SpermParam.totalNumber, i.totalNumber);
  check(SpermParam.totalMotility, i.totalMotility);
  check(SpermParam.progressive, i.progressive);
  check(SpermParam.vitality, i.vitality);
  check(SpermParam.normalForms, i.normalForms);

  // Spermatozoid topilmadi: boshqa sperma atamalari qo'llanmaydi.
  final none = i.concentration == 0;
  if (none) {
    return SpermAssessment(
      below: below,
      terms: const [SpermTerm.azoospermia],
      countBasis: SpermParam.concentration,
      lowPh: i.ph != null && i.ph! < spermPhLow,
      errors: errors,
    );
  }

  // Umumiy son afzal (JSST 2010 Table A1.3 izohi), bo'lmasa konsentratsiya.
  final countBasis = i.totalNumber != null
      ? SpermParam.totalNumber
      : i.concentration != null
      ? SpermParam.concentration
      : null;
  final oligo = countBasis != null && below.contains(countBasis);
  final astheno = below.contains(SpermParam.progressive);
  final terato = below.contains(SpermParam.normalForms);

  final terms = <SpermTerm>[];
  final combo = switch ((oligo, astheno, terato)) {
    (true, true, true) => SpermTerm.oligoasthenoteratozoospermia,
    (true, true, false) => SpermTerm.oligoasthenozoospermia,
    (true, false, true) => SpermTerm.oligoteratozoospermia,
    (false, true, true) => SpermTerm.asthenoteratozoospermia,
    (true, false, false) => SpermTerm.oligozoospermia,
    (false, true, false) => SpermTerm.asthenozoospermia,
    (false, false, true) => SpermTerm.teratozoospermia,
    (false, false, false) => null,
  };
  if (combo != null) {
    terms.add(combo);
  } else if (countBasis != null &&
      i.progressive != null &&
      i.normalForms != null) {
    // Normozoospermiya — uchala ko'rsatkich kiritilgan va chegaradan past emas.
    terms.add(SpermTerm.normozoospermia);
  }
  if (below.contains(SpermParam.vitality)) {
    terms.add(SpermTerm.necrozoospermia);
  }
  return SpermAssessment(
    below: below,
    terms: terms,
    countBasis: countBasis,
    lowPh: i.ph != null && i.ph! < spermPhLow,
    errors: errors,
  );
}
