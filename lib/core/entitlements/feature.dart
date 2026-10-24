/// Obuna darajasi: bepul, Pro (shaxsiy yoki talaba) va Ustoz Pro.
/// Ustoz Pro Pro'dagi hamma narsani ham ochadi.
enum ProTier {
  free,
  pro,
  teacher;

  /// [other] darajadagi imkoniyatni ochadimi.
  bool covers(ProTier other) => index >= other.index;
}

/// Ilova imkoniyatlari: qaysi biri bepul, qaysi biri Pro yoki Ustoz Pro
/// (D-46, D-53; docs/PRO_BILLING_PLAN.md). Yangi pullik imkoniyat faqat shu
/// yerga qo'shiladi — ekranlar `EntitlementService.can(...)` ni so'raydi.
///
/// Muhim: tekshiruv faqat amal BOSHLANISHIDAN oldin yoki NATIJADAN keyin
/// qilinadi. Boshlangan sanash yoki imtihon hech qachon to'lov oynasi bilan
/// to'xtatilmaydi (obuna o'rtada tugasa ham oxirigacha ishlaydi).
///
/// To'lov yoqilmagan buildda (do'kon mahsulotlari yuklanmagan yoki server
/// sozlanmagan) hamma imkoniyat ochiq — yopiq tugma yoki "tez orada" yozuvi
/// ko'rsatilmaydi (App Store 2.1 / 3.1.1).
enum Feature {
  /// Leykoformula hisoblagichi.
  leukocyteCounter(ProTier.free),

  /// Foiz va mutlaq sonlar.
  absoluteCounts(ProTier.free),

  /// Asosiy qo'llanmalar.
  basicGuides(ProTier.free),

  /// Kunlik 5 ta savol (D-53).
  dailyQuestions(ProTier.free),

  /// Xatolarni qayta ishlash — cheklanmaydi (D-53).
  mistakeReview(ProTier.free),

  /// Cheksiz natijalar tarixi (bepulda oxirgi 3 tasi ko'rinadi).
  unlimitedHistory(ProTier.pro),

  /// Cheksiz savollar: mavzu bo'yicha mashq va kartadan mini-test
  /// (bepulda — kunlik 5 ta savol).
  unlimitedQuestions(ProTier.pro),

  /// Imtihon simulyatsiyasi (vaqtli test).
  examSimulation(ProTier.pro),

  /// To'liq toifa banki: rasmiy test va mavzu bo'yicha mashq.
  fullToifaBank(ProTier.pro),

  /// Zaif mavzular tahlili (natijada mavzular bo'yicha).
  weakTopics(ProTier.pro),

  /// Mikroskopiya atlasi mashqlari.
  atlasPractice(ProTier.pro),

  /// Ustoz Pro: guruh ochish (a'zolar, baholar, hisobotlar).
  groups(ProTier.teacher),

  /// Ustoz Pro: guruh topshiriqlari.
  assignments(ProTier.teacher),

  /// Ustoz Pro: ma'ruza rejimi (avtomatik taqdimot).
  autoPresentation(ProTier.teacher);

  const Feature(this.tier);

  final ProTier tier;

  /// Obunani talab qiladigan DARAJA (reja). Haqiqatan yopilishi esa
  /// [ProGatePolicy.gated] ga bog'liq (D-71: standart — hech narsa).
  bool get pro => tier != ProTier.free;
}
