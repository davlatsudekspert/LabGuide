/// Koagulogramma: ISTH ochiq DIC bali, PT/APTT birikmasi va yuqori
/// gematokritda sitrat hajmi.
///
/// Bal chegaralari — Toh 2016 (Ann Lab Med, 1-jadval) va Iba 2019 (J Clin
/// Med, 1-jadval) bo'yicha: trombotsit ≥ 100 → 0, < 100 → 1, < 50 → 2;
/// fibrin bilan bog'liq marker yo'q/o'rtacha/keskin → 0/2/3; PT uzayishi
/// < 3 s → 0, ≥ 3 va < 6 → 1, ≥ 6 → 2; fibrinogen ≥ 1 g/l → 0, < 1 → 1;
/// ≥ 5 — ochiq DIC bilan mos. Sitrat — WFH 2025, 3-qism, 21-bet.
library;

import 'coag_content.dart';

/// Fibrin bilan bog'liq marker (D-dimer, FDP) darajasi.
enum CgFrm { none, moderate, strong }

/// Ochiq DIC uchun chegaraviy bal.
const dicOvertCutoff = 5;

int dicPlateletPoints(double plateletsE9) => plateletsE9 >= 100
    ? 0
    : plateletsE9 >= 50
    ? 1
    : 2;

int dicFrmPoints(CgFrm frm) => switch (frm) {
  CgFrm.none => 0,
  CgFrm.moderate => 2,
  CgFrm.strong => 3,
};

int dicPtPoints(double prolongationSeconds) => prolongationSeconds < 3
    ? 0
    : prolongationSeconds < 6
    ? 1
    : 2;

int dicFibrinogenPoints(double gPerL) => gPerL >= 1 ? 0 : 1;

class DicScore {
  const DicScore({
    required this.platelets,
    required this.frm,
    required this.pt,
    required this.fibrinogen,
  });

  final int platelets;
  final int frm;
  final int pt;
  final int fibrinogen;

  int get total => platelets + frm + pt + fibrinogen;

  /// ≥ 5: ochiq DIC bilan mos keladi (manba jadvali).
  bool get compatibleWithOvert => total >= dicOvertCutoff;
}

/// Kiritmalar: trombotsit (×10⁹/l), marker darajasi, PT uzayishi (s),
/// fibrinogen (g/l). Manfiy yoki chekli bo'lmagan son — `null`.
DicScore? dicScore({
  required double? plateletsE9,
  required CgFrm? frm,
  required double? ptProlongationSeconds,
  required double? fibrinogenGPerL,
}) {
  bool ok(double? v) => v != null && v.isFinite && v >= 0;
  if (!ok(plateletsE9) ||
      frm == null ||
      !ok(ptProlongationSeconds) ||
      !ok(fibrinogenGPerL)) {
    return null;
  }
  return DicScore(
    platelets: dicPlateletPoints(plateletsE9!),
    frm: dicFrmPoints(frm),
    pt: dicPtPoints(ptProlongationSeconds!),
    fibrinogen: dicFibrinogenPoints(fibrinogenGPerL!),
  );
}

/// PT va APTT holatidan birikma.
CgPattern cgPattern({required bool ptProlonged, required bool apttProlonged}) =>
    switch ((ptProlonged, apttProlonged)) {
      (true, false) => CgPattern.ptOnly,
      (false, true) => CgPattern.apttOnly,
      (true, true) => CgPattern.both,
      (false, false) => CgPattern.normal,
    };

/// Gematokrit shu qiymatdan yuqori bo'lsa, sitrat hajmi tuzatiladi.
const citrateHctThreshold = 55.0;

/// WFH formulasi: C = 1,85·10⁻³ × (100 − Ht) × V (ml). Ht 0–100 % oralig'ida
/// emas yoki V ≤ 0 — `null`.
double? citrateVolumeMl({required double hctPercent, required double bloodMl}) {
  if (!hctPercent.isFinite || !bloodMl.isFinite) return null;
  if (hctPercent <= 0 || hctPercent >= 100 || bloodMl <= 0) return null;
  return 1.85e-3 * (100 - hctPercent) * bloodMl;
}

/// Kiritilgan matndan son (vergul ham qabul qilinadi). Bo'sh — `null`.
double? cgParse(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}
