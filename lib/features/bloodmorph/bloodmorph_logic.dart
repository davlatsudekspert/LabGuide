/// Qon morfologiyasi: anemiya tasnifi yordamchisining sof mantiqi (UI'siz).
///
/// Chegaralar o'ylab topilmagan — faqat manbadagi raqamlar:
/// - Hb: JSST 2024, Table 2 (9-bet) — guruh bo'yicha anemiya chegarasi;
/// - MCV: <80 fL mikrotsitar, 80–100 normotsitar, >100 makrotsitar
///   (Takami 2026, Table 3; MSD Manual — RBC indices);
/// - RDW: manbada son yo'q (faqat "me'yorda / yuqori") — shuning uchun
///   laboratoriyaning o'z yuqori chegarasi kiritiladi;
/// - ferritin: JSST 2020, Table 1 (sog'lom / infeksiya-yallig'lanish);
/// - retikulotsitlar (mutlaq): ≈ >80×10⁹/L va ≈ <20×10⁹/L (Takami 2026,
///   Step 2 — "taxminiy yo'l-yo'riq").
/// Natija tashxis emas: "qaysi guruhga to'g'ri keladi va nimaga ishora
/// qilishi mumkin".
library;

/// JSST 2024 Table 2 dagi aholi guruhlari.
enum BmPopulation {
  child6to23m,
  child24to59m,
  child5to11y,
  girl12to14y,
  boy12to14y,
  woman15to65,
  man15to65,
  pregnantT1,
  pregnantT2,
  pregnantT3,
}

/// Anemiya chegarasi, g/L (Hb shundan past bo'lsa — anemiya).
/// JSST 2024, Table 2 ("Based on the 5th percentile").
int bmHbCutoff(BmPopulation p) => switch (p) {
  BmPopulation.child6to23m => 105,
  BmPopulation.child24to59m => 110,
  BmPopulation.child5to11y => 115,
  BmPopulation.girl12to14y => 120,
  BmPopulation.boy12to14y => 120,
  BmPopulation.woman15to65 => 120,
  BmPopulation.man15to65 => 130,
  BmPopulation.pregnantT1 => 110,
  BmPopulation.pregnantT2 => 105,
  BmPopulation.pregnantT3 => 110,
};

enum BmMcvClass { micro, normo, macro }

/// Takami 2026 Table 3: past (<80 fL), me'yorda (80–100), yuqori (>100).
/// 80 va 100 ning o'zi — "me'yorda" oralig'ida.
BmMcvClass bmMcvClass(double mcv) => mcv < 80
    ? BmMcvClass.micro
    : mcv > 100
    ? BmMcvClass.macro
    : BmMcvClass.normo;

/// Ferritin chegarasi, µg/L (JSST 2020, Table 1). `null` — manbada shu
/// guruh va holat uchun chegara yo'q (homiladorlik II–III trimestr yoki
/// homiladorlikda yallig'lanish).
int? bmFerritinCutoff(BmPopulation p, {required bool inflammation}) =>
    switch (p) {
      // 0–59 oy: sog'lom <12, infeksiya/yallig'lanish <30.
      BmPopulation.child6to23m ||
      BmPopulation.child24to59m => inflammation ? 30 : 12,
      // Homiladorlik: faqat I trimestr, faqat sog'lom (<15).
      BmPopulation.pregnantT1 => inflammation ? null : 15,
      BmPopulation.pregnantT2 || BmPopulation.pregnantT3 => null,
      // 5 yoshdan katta bolalar, o'smirlar, kattalar: <15 / <70.
      _ => inflammation ? 70 : 15,
    };

/// Retikulotsitlar (mutlaq son) bo'yicha Takami 2026 Step 2 yo'l-yo'rig'i.
enum BmReticBand {
  /// ≈ >80×10⁹/L — ilik javobi yetarli yoki kuchaygan.
  high,

  /// ≈ <20×10⁹/L — og'ir anemiyada eritropoez keskin pasaygan.
  veryLow,

  /// 20–80: manbadagi ikkala yo'l-yo'riq ham qo'llanmaydi.
  between,
}

BmReticBand bmReticBand(double absolute) => absolute > 80
    ? BmReticBand.high
    : absolute < 20
    ? BmReticBand.veryLow
    : BmReticBand.between;

/// Kiritish maydonlari va ruxsat etilgan oraliq (fizik ma'noga ega
/// qiymatlar; tashqarisi — kiritish xatosi).
enum BmField { hb, mcv, rdw, rdwUpper, ferritin, retic }

(double, double) bmFieldRange(BmField f) => switch (f) {
  BmField.hb => (20, 250),
  BmField.mcv => (40, 150),
  BmField.rdw => (5, 40),
  BmField.rdwUpper => (5, 40),
  BmField.ferritin => (0, 100000),
  BmField.retic => (0, 1000),
};

bool bmFieldValid(BmField f, double v) {
  final (lo, hi) = bmFieldRange(f);
  return v.isFinite && v >= lo && v <= hi;
}

class BmAnemiaInput {
  const BmAnemiaInput({
    required this.population,
    this.hb,
    this.mcv,
    this.rdw,
    this.rdwUpper,
    this.ferritin,
    this.inflammation = false,
    this.retic,
  });

  final BmPopulation population;

  /// g/L.
  final double? hb;

  /// fL.
  final double? mcv;

  /// RDW-CV, %.
  final double? rdw;

  /// Laboratoriya RDW referens oralig'ining yuqori chegarasi, %.
  final double? rdwUpper;

  /// µg/L.
  final double? ferritin;

  /// Infeksiya yoki yallig'lanish bor (CRP/AGP bilan aniqlangan).
  final bool inflammation;

  /// Retikulotsitlar, mutlaq son ×10⁹/L.
  final double? retic;
}

class BmAnemiaResult {
  const BmAnemiaResult({
    required this.hbCutoff,
    this.anaemic,
    this.mcvClass,
    this.rdwHigh,
    this.ferritinCutoff,
    this.ferritinLow,
    this.reticBand,
  });

  final int hbCutoff;

  /// `null` — Hb kiritilmagan.
  final bool? anaemic;
  final BmMcvClass? mcvClass;

  /// `null` — RDW yoki uning yuqori chegarasi kiritilmagan.
  final bool? rdwHigh;

  /// `null` — manbada chegara yo'q (yoki ferritin kiritilmagan bo'lsa ham
  /// chegara ko'rsatiladi).
  final int? ferritinCutoff;

  /// `null` — ferritin kiritilmagan yoki chegara yo'q.
  final bool? ferritinLow;
  final BmReticBand? reticBand;

  /// Takami Table 3 qatori aniqlanadimi (MCV va RDW holati ma'lum).
  bool get hasPattern => mcvClass != null && rdwHigh != null;
}

BmAnemiaResult bmAssessAnemia(BmAnemiaInput i) {
  final cutoff = bmHbCutoff(i.population);
  final fCut = bmFerritinCutoff(i.population, inflammation: i.inflammation);
  final rdwKnown = i.rdw != null && i.rdwUpper != null;
  return BmAnemiaResult(
    hbCutoff: cutoff,
    anaemic: i.hb == null ? null : i.hb! < cutoff,
    mcvClass: i.mcv == null ? null : bmMcvClass(i.mcv!),
    rdwHigh: rdwKnown ? i.rdw! > i.rdwUpper! : null,
    ferritinCutoff: fCut,
    ferritinLow: i.ferritin == null || fCut == null ? null : i.ferritin! < fCut,
    reticBand: i.retic == null ? null : bmReticBand(i.retic!),
  );
}
