import 'package:flutter/foundation.dart';

/// Pro imkoniyat TOIFASI (D-74, D-76) — funksiya emas. Har pullik funksiya
/// ([Feature]) shu toifalardan biriga tegishli va reja faqat o'z
/// to'plamidagini ocha oladi.
///
/// QAROR SERVERDA: `cloudflare/src/tiers.ts` (`requireTier`) — serverda
/// saqlangan huquqdan (do'kon / admin grant / sinov), ilovadagi roldan
/// emas. Ilova nusxasi ([PlanMatrix]) faqat UI ko'rsatmalari va
/// [EntitlementService.can] uchun (test ikkalasini solishtiradi).
enum ProCapability {
  /// Talaba Pro: natijalar tahlili, imtihon simulyatsiyasi, eksport,
  /// ustoz bilan ishlanadigan maxsus testlar (talaba tomoni).
  learner('learner'),

  /// Ustoz Pro: test yaratish, talabalarni biriktirish, natijalarni
  /// boshqarish (bugungi bepul guruhlar va topshiriqlar EMAS).
  teacherPanel('teacher_panel'),

  /// Mutaxassis Pro: professional laboratoriya funksiyalari — kalibrlash
  /// jurnali va QC eksporti, QC xulosa hisoboti (bugungi bepul Lab bo'limi
  /// EMAS — u to'liq bepul qoladi, egasi qarori 2026-10-25).
  lab('lab');

  const ProCapability(this.wire);

  /// Server bilan umumiy nom.
  final String wire;
}

/// Obuna darajasi = ochilgan imkoniyatlar TO'PLAMI (D-76). Avvalgi chiziqli
/// zinapoya (free < pro < teacher) BEKOR: Mutaxassis ustoz panelini, Ustoz
/// esa Mutaxassis funksiyalarini ochmaydi, shuning uchun "yuqori daraja
/// pastkisini qamraydi" degan qoida yo'q. Bir nechta amaldagi huquq
/// (masalan, Ustoz obunasi va Mutaxassis admin granti) birlashtiriladi
/// ([operator |]).
@immutable
class ProTier {
  const ProTier(this.capabilities);

  /// Pro yo'q.
  static const free = ProTier({});

  /// Hamma imkoniyat (TestFlight/debug build — `allFeaturesOpen`).
  static const all = ProTier({
    ProCapability.learner,
    ProCapability.teacherPanel,
    ProCapability.lab,
  });

  final Set<ProCapability> capabilities;

  bool get isFree => capabilities.isEmpty;

  /// [capability] ochiqmi (`null` — bepul, doim ochiq).
  bool allows(ProCapability? capability) =>
      capability == null || capabilities.contains(capability);

  /// [feature] ni ochadimi (faqat to'plam bo'yicha; yopish siyosati —
  /// [EntitlementService.can]).
  bool covers(Feature feature) => allows(feature.capability);

  /// Ikki huquq birlashmasi.
  ProTier operator |(ProTier other) =>
      ProTier({...capabilities, ...other.capabilities});

  @override
  bool operator ==(Object other) =>
      other is ProTier && setEquals(other.capabilities, capabilities);

  @override
  int get hashCode => Object.hashAllUnordered(capabilities);

  @override
  String toString() =>
      'ProTier(${[for (final c in capabilities) c.wire].join(', ')})';
}

/// PULLIK imkoniyatlar katalogi — egasi qarori (2026-10-25, D-78).
///
/// Asosiy qoida: **bugun `main` da (do'kondagi bepul versiya) bor bo'lgan
/// HECH NARSA bu ro'yxatda emas** — Lab bo'limi, atlas, toifa / Bilim va
/// ko'nikmalarni baholash, testlar, kunlik savollar, mashq, natijalar
/// tarixi (bepul ko'rinishi), guruhlar, topshiriqlar, ma'ruza rejimi,
/// kalkulyatorlar, QC (shu jumladan CSV nusxasi), kalibrlash — hammasi
/// bepul va cheklovsiz (kunlik limit yo'q). Ro'yxatda faqat YANGI yoki
/// KENGAYTIRILGAN imkoniyatlar (Pro delta). Bepul qism hech qachon
/// tekshirilmaydi, shuning uchun bepul funksiya uchun [Feature] yo'q.
///
/// Tekshiruv faqat amal BOSHLANISHIDAN oldin (`allowOrOffer` /
/// `requireFeature`): boshlangan amal hech qachon to'xtatilmaydi, obuna
/// tugasa foydalanuvchi ma'lumoti O'CHIRILMAYDI va yashirilmaydi — faqat
/// yangi pullik amalni boshlash yopiladi.
///
/// Haqiqatan yopilishi [ProGatePolicy.gated] ga bog'liq: unga faqat
/// QURILGAN (ekrani va testi bor) funksiya qo'shiladi — bo'sh pullik va'da
/// yo'q. To'lov yoqilmagan buildda hamma imkoniyat ochiq.
///
/// Server nusxasi: `cloudflare/src/tiers.ts` `FEATURE_CAPABILITIES` (test
/// `test/unit/plan_matrix_test.dart` solishtiradi).
enum Feature {
  // ------------------------------------------------- Talaba Pro (learner)

  /// Natijalar tahlili: barcha banklar bo'yicha to'liq tarix, mavzular
  /// bo'yicha aniqlik va trend, zaif mavzular (bepul imtihon tarixi va har
  /// natijadagi mavzular tahlili o'zgarmaydi).
  resultsAnalytics('results_analytics', ProCapability.learner),

  /// Imtihon simulyatsiyasi: imtihon sharoiti (majburiy vaqt va o'tish
  /// chegarasi, mavzular bo'yicha muvozanatli tanlov, ketma-ket — orqaga
  /// qaytish va belgilash yo'q), har savolga sarflangan vaqt bilan hisobot,
  /// tarixga saqlanadi. Bepul imtihon rejimi va toifa testi o'zgarmaydi.
  examSimulation('exam_simulation', ProCapability.learner),

  /// Natijalarni PDF va CSV fayl sifatida eksport qilish (ulashish oynasi).
  resultsExport('results_export', ProCapability.learner),

  /// Ustoz Pro'da yaratilgan maxsus testlarni yechish (talaba tomoni).
  /// Bugungi bepul guruh topshiriqlari (slayd/mavzu testlari) bunga
  /// KIRMAYDI. Ustoz tomoni qurilgach ulanadi.
  teacherTests('teacher_tests', ProCapability.learner),

  // -------------------------------------------- Ustoz Pro (teacherPanel)

  /// O'z testini yaratish va tahrirlash (savollar, variantlar, kalit).
  teacherTestBuilder('teacher_test_builder', ProCapability.teacherPanel),

  /// Yaratilgan testga talabalar / guruhni biriktirish (muddat bilan).
  teacherTestAssign('teacher_test_assign', ProCapability.teacherPanel),

  /// Natijalarni boshqarish: o'z testlari bo'yicha talaba va savol
  /// kesimidagi jamlanma, eksport.
  teacherResults('teacher_results', ProCapability.teacherPanel),

  // -------------------------------------------------- Mutaxassis Pro (lab)

  /// Kalibrlash jurnalini CSV va PDF ga eksport qilish (apparat, analit,
  /// reagent, kalibrator loti, darajalar, natija, tasdiqlagan, audit).
  calibrationExport('calibration_export', ProCapability.lab),

  /// QC xulosa hisoboti (saqlangan ma'lumotdan: har daraja bo'yicha n, x̄,
  /// SD, CV, maqsaddan farq, ishlagan Westgard qoidalari) va QC ma'lumotini
  /// CSV/PDF fayl sifatida eksport (bepul CSV nusxasi o'zgarmaydi).
  qcReport('qc_report', ProCapability.lab);

  const Feature(this.wire, this.capability);

  /// Server bilan umumiy nom (`tiers.ts` `FEATURE_CAPABILITIES`).
  final String wire;

  /// Qaysi Pro toifasiga tegishli.
  final ProCapability capability;
}
