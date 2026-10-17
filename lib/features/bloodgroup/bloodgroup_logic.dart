/// Qon guruhi: reaksiya naqshini o'qish mantig'i (UI'siz, test qilinadi).
///
/// Faqat o'quv mashqi. Kutilgan naqsh — JSST Module 3 (§4.1 Table 2,
/// 101–102-betlardagi javoblar) va BSH 2012 §4.3.1: to'g'ri usul — anti-A,
/// anti-B; teskari usul — A1 va B standart eritrotsitlari. To'g'ri va teskari
/// natija mos kelmasa — nomuvofiqlik (guruh aytilmaydi). Nomuvofiqlik
/// sabablari toifasi BSH 2012 Fig. A1 bo'yicha. Bemor uchun xulosa emas.
library;

/// ABO guruhi.
enum AboGroup { o, a, b, ab }

/// Reagent bilan reaksiya. `weak` — kuchsiz musbat, `mixed` — aralash
/// maydon. Ikkalasi ham agglyutinatsiya bor deb o'qiladi, lekin anti-A /
/// anti-B da anomaliya: guruh aytilmaydi, takrorlash va tekshirish kerak
/// (BSH 2012 §4.7.1 i, iv; §4.8.1; Fig. A1).
enum BgReaction { neg, pos, weak, mixed }

extension on BgReaction {
  bool get positive => this != BgReaction.neg;
}

/// Kiritilgan natijalar. `null` — test qo'yilmagan.
class BgInput {
  const BgInput({
    this.antiA,
    this.antiB,
    this.antiD,
    this.a1Cells,
    this.bCells,
    this.control,
  });

  /// To'g'ri usul: bemor eritrotsitlari + reagentlar.
  final BgReaction? antiA;
  final BgReaction? antiB;
  final BgReaction? antiD;

  /// Teskari usul: bemor plazmasi (zardobi) + A1 / B eritrotsitlari.
  /// `true` — agglyutinatsiya bor.
  final bool? a1Cells;
  final bool? bCells;

  /// Nazorat (diluent/autonazorat). `true` — musbat.
  final bool? control;

  bool get forwardDone => antiA != null && antiB != null;
  bool get reverseDone => a1Cells != null && bCells != null;
  bool get isEmpty =>
      antiA == null &&
      antiB == null &&
      antiD == null &&
      a1Cells == null &&
      bCells == null &&
      control == null;
}

/// RhD natijasi (o'quv talqini).
enum RhResult { positive, negative, weak, mixedField }

/// Belgilar (ogohlantirishlar). Har biri ekranda manbali izoh bilan chiqadi.
enum BgFlag {
  /// To'g'ri va teskari natija mos emas.
  discrepancy,

  /// A antigeni ham, anti-A ham aniqlandi (A ustunida ortiqcha reaksiya).
  aBothPositive,

  /// A antigeni ham, anti-A ham aniqlanmadi.
  aBothNegative,

  /// B antigeni ham, anti-B ham aniqlandi.
  bBothPositive,

  /// B antigeni ham, anti-B ham aniqlanmadi.
  bBothNegative,

  /// Faqat to'g'ri usul — to'liq guruh uchun teskari usul kerak.
  reverseMissing,

  /// Faqat teskari usul — to'g'ri usul kerak.
  forwardMissing,

  /// Nazorat musbat — natija yaroqsiz.
  controlPositive,

  /// Hamma reagent bilan musbat (AB, D+) va nazorat qo'yilmagan.
  allPositiveNoControl,

  /// Anti-A yoki anti-B bilan kuchsiz reaksiya — anomaliya, guruh
  /// aytilmaydi (BSH §4.7.1 iv, Fig. A1).
  weakForward,

  /// Aralash maydon (anti-A, anti-B yoki anti-D) — anomaliya: guruh
  /// tasdiqlanishidan oldin takrorlanadi/tekshiriladi (BSH §4.7.1 i).
  mixedField,

  /// Anti-D bilan kuchsiz reaksiya.
  weakD,
}

class BgResult {
  const BgResult({
    required this.forward,
    required this.reverse,
    required this.rh,
    required this.flags,
  });

  /// Faqat to'g'ri usul bo'yicha guruh (anti-A, anti-B).
  final AboGroup? forward;

  /// Faqat teskari usul bo'yicha guruh (A1, B eritrotsitlari).
  final AboGroup? reverse;

  final RhResult? rh;
  final Set<BgFlag> flags;

  bool get invalid => flags.contains(BgFlag.controlPositive);
  bool get discrepancy => flags.contains(BgFlag.discrepancy);

  /// To'g'ri usulda anomaliya (kuchsiz reaksiya yoki aralash maydon):
  /// BSH §4.7.1, §4.8.1 — guruh hal bo'lmaguncha aytilmaydi.
  bool get anomaly =>
      flags.contains(BgFlag.weakForward) || flags.contains(BgFlag.mixedField);

  /// O'quv talqini: ikkala usul mos kelsa, nazorat musbat bo'lmasa va
  /// anomaliya yo'q bo'lsa. Aks holda — `null` (guruh aytilmaydi).
  AboGroup? get group =>
      !invalid &&
          !discrepancy &&
          !anomaly &&
          forward != null &&
          forward == reverse
      ? forward
      : null;
}

/// Anti-A / anti-B → antigenlar → guruh.
AboGroup groupFromAntigens({required bool a, required bool b}) =>
    switch ((a, b)) {
      (true, true) => AboGroup.ab,
      (true, false) => AboGroup.a,
      (false, true) => AboGroup.b,
      (false, false) => AboGroup.o,
    };

/// Teskari usul: plazmadagi antitelalar o'z eritrotsitida yo'q antigenga
/// qarshi (Landshteyner qoidasi). A1 hujayrasi agglyutinatsiyasi = anti-A.
AboGroup groupFromAntibodies({required bool antiA, required bool antiB}) =>
    groupFromAntigens(a: !antiA, b: !antiB);

/// Guruhga kutilgan to'liq naqsh (anti-A, anti-B, A1 hujayra, B hujayra).
({bool antiA, bool antiB, bool a1Cells, bool bCells}) expectedPattern(
  AboGroup g,
) {
  final a = g == AboGroup.a || g == AboGroup.ab;
  final b = g == AboGroup.b || g == AboGroup.ab;
  return (antiA: a, antiB: b, a1Cells: !a, bCells: !b);
}

BgResult readPattern(BgInput i) {
  final flags = <BgFlag>{};
  AboGroup? forward;
  AboGroup? reverse;
  if (i.forwardDone) {
    forward = groupFromAntigens(a: i.antiA!.positive, b: i.antiB!.positive);
    if (i.antiA == BgReaction.weak || i.antiB == BgReaction.weak) {
      flags.add(BgFlag.weakForward);
    }
    if (i.antiA == BgReaction.mixed || i.antiB == BgReaction.mixed) {
      flags.add(BgFlag.mixedField);
    }
  }
  if (i.reverseDone) {
    reverse = groupFromAntibodies(antiA: i.a1Cells!, antiB: i.bCells!);
  }
  if (forward != null && reverse == null) flags.add(BgFlag.reverseMissing);
  if (reverse != null && forward == null) flags.add(BgFlag.forwardMissing);
  if (forward != null && reverse != null && forward != reverse) {
    flags.add(BgFlag.discrepancy);
    final aAntigen = i.antiA!.positive;
    final bAntigen = i.antiB!.positive;
    // Antigen bor bo'lsa, unga qarshi antitela bo'lmasligi kerak (va aksincha).
    if (aAntigen && i.a1Cells!) flags.add(BgFlag.aBothPositive);
    if (!aAntigen && !i.a1Cells!) flags.add(BgFlag.aBothNegative);
    if (bAntigen && i.bCells!) flags.add(BgFlag.bBothPositive);
    if (!bAntigen && !i.bCells!) flags.add(BgFlag.bBothNegative);
  }
  RhResult? rh;
  if (i.antiD != null) {
    rh = switch (i.antiD!) {
      BgReaction.pos => RhResult.positive,
      BgReaction.neg => RhResult.negative,
      BgReaction.weak => RhResult.weak,
      BgReaction.mixed => RhResult.mixedField,
    };
    if (i.antiD == BgReaction.weak) flags.add(BgFlag.weakD);
    if (i.antiD == BgReaction.mixed) flags.add(BgFlag.mixedField);
  }
  if (i.control == true) flags.add(BgFlag.controlPositive);
  // BSH §8.4.3: AB D+ (hammasi musbat) naqshida nazoratsiz sovuq
  // agglyutininlar aniqlanmay qolishi mumkin.
  if (i.control == null &&
      forward == AboGroup.ab &&
      (i.antiD?.positive ?? false)) {
    flags.add(BgFlag.allPositiveNoControl);
  }
  return BgResult(forward: forward, reverse: reverse, rh: rh, flags: flags);
}
