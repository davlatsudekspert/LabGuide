/// Ilova imkoniyatlari: qaysi biri bepul, qaysi biri Pro (egasining
/// qarori, docs/PRO_BILLING_PLAN.md). Yangi pullik imkoniyat faqat shu
/// yerga qo'shiladi — ekranlar `EntitlementService.can(...)` ni so'raydi.
///
/// Muhim: tekshiruv faqat amal BOSHLANISHIDAN oldin yoki NATIJADAN keyin
/// qilinadi. Boshlangan sanash yoki imtihon hech qachon to'lov oynasi bilan
/// to'xtatilmaydi (obuna o'rtada tugasa ham oxirigacha ishlaydi).
enum Feature {
  /// Leykoformula hisoblagichi.
  leukocyteCounter(pro: false),

  /// Foiz va mutlaq sonlar.
  absoluteCounts(pro: false),

  /// Asosiy qo'llanmalar.
  basicGuides(pro: false),

  /// Cheksiz natijalar tarixi (bepulda oxirgi 3 tasi ko'rinadi).
  unlimitedHistory(pro: true),

  /// PDF eksport.
  pdfExport(pro: true),

  /// Kengaytirilgan mashqlar.
  advancedPractice(pro: true),

  /// Toifa imtihoniga to'liq tayyorgarlik.
  categoryExamPrep(pro: true);

  const Feature({required this.pro});

  /// Pro obunani talab qiladi.
  final bool pro;
}
