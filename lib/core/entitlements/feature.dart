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
  /// Talaba tomonidagi Pro imkoniyatlari.
  learner('learner'),

  /// Ustoz paneli Pro imkoniyatlari (bugungi bepul guruhlar EMAS).
  teacherPanel('teacher_panel'),

  /// Butun Lab bo'limi (D-76): apparatlar katalogi, yo'nalish kartalari,
  /// koagulogramma, kalibrlash, QC, kalkulyatorlar, leykoformula sanash va
  /// baholash, rasmli Lab bo'limlari.
  lab('lab');

  const ProCapability(this.wire);

  /// Server bilan umumiy nom.
  final String wire;
}

/// Obuna darajasi = ochilgan imkoniyatlar TO'PLAMI (D-76). Avvalgi chiziqli
/// zinapoya (free < pro < teacher) BEKOR: Mutaxassis ustoz panelini, Ustoz
/// esa Lab'ni ochmaydi, shuning uchun "yuqori daraja pastkisini qamraydi"
/// degan qoida yo'q. Bir nechta amaldagi huquq (masalan, Ustoz obunasi va
/// Mutaxassis admin granti) birlashtiriladi ([operator |]).
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

  /// [capability] ochiqmi (`null` — bepul funksiya, doim ochiq).
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

/// Ilova imkoniyatlari: qaysi biri bepul, qaysi biri qaysi Pro toifasida
/// (D-46, D-53, D-76; docs/PRO_BILLING_PLAN.md). Yangi pullik imkoniyat faqat
/// shu yerga qo'shiladi — ekranlar `EntitlementService.can(...)` ni
/// (yoki `requireFeature`) so'raydi.
///
/// Muhim: tekshiruv faqat amal BOSHLANISHIDAN oldin yoki NATIJADAN keyin
/// qilinadi. Boshlangan sanash yoki imtihon hech qachon to'lov oynasi bilan
/// to'xtatilmaydi (obuna o'rtada tugasa ham oxirigacha ishlaydi).
///
/// Haqiqatan yopilishi esa [ProGatePolicy.gated] ga bog'liq (standart —
/// HECH NARSA). Lab funksiyalari [ProGatePolicy.plannedLabGate] da
/// REJALASHTIRILGAN, lekin FAOL EMAS. To'lov yoqilmagan buildda hamma
/// imkoniyat ochiq — yopiq tugma yoki "tez orada" yozuvi ko'rsatilmaydi
/// (App Store 2.1 / 3.1.1).
enum Feature {
  /// Asosiy qo'llanmalar.
  basicGuides(null),

  /// Kunlik 5 ta savol (D-53).
  dailyQuestions(null),

  /// Xatolarni qayta ishlash — cheklanmaydi (D-53).
  mistakeReview(null),

  /// Cheksiz natijalar tarixi (bepulda oxirgi 3 tasi ko'rinadi).
  unlimitedHistory(ProCapability.learner),

  /// Cheksiz savollar: mavzu bo'yicha mashq va kartadan mini-test
  /// (bepulda — kunlik 5 ta savol).
  unlimitedQuestions(ProCapability.learner),

  /// Imtihon simulyatsiyasi (vaqtli test).
  examSimulation(ProCapability.learner),

  /// To'liq toifa banki: rasmiy test va mavzu bo'yicha mashq.
  fullToifaBank(ProCapability.learner),

  /// Zaif mavzular tahlili (natijada mavzular bo'yicha).
  weakTopics(ProCapability.learner),

  /// Mikroskopiya atlasi mashqlari.
  atlasPractice(ProCapability.learner),

  /// Ustoz paneli: guruh ochish (a'zolar, baholar, hisobotlar).
  groups(ProCapability.teacherPanel),

  /// Ustoz paneli: guruh topshiriqlari.
  assignments(ProCapability.teacherPanel),

  /// Ustoz paneli: ma'ruza rejimi (avtomatik taqdimot).
  autoPresentation(ProCapability.teacherPanel),

  // ---------------------------------------------------------------- Lab (D-76)
  // Ekran (kirish sahifasi) OCHILADI va ko'rinadi; quyidagi AMAL yoki
  // vosita boshlanishidan oldin tekshiriladi.

  /// Leykoformula: sanashni boshlash (hisoblagich, "ko'rmasdan" rejim) va
  /// natijani saqlash (sanash sessiyasi ichida).
  leukocyteCounter(ProCapability.lab),

  /// Leykoformula: foiz va mutlaq sonlar kalkulyatori.
  absoluteCounts(ProCapability.lab),

  /// Leykoformula: natijani baholash (izohlash).
  leukocyteEvaluation(ProCapability.lab),

  /// Rasmli Lab bo'limlari ichidagi sahifalar va vositalar: sitologiya,
  /// spermogramma, qon guruhi, gistologiya, siydik tahlili, qon
  /// morfologiyasi, koprologiya.
  labSections(ProCapability.lab),

  /// Koagulogramma bo'limi ichidagi sahifalar va vositalar.
  coagulogram(ProCapability.lab),

  /// Apparatlar katalogi: toifa / ishlab chiqaruvchi / apparat kartasi.
  labInstruments(ProCapability.lab),

  /// Lab yo'nalishlari bo'yicha ma'lumotnoma kartalari.
  labDirections(ProCapability.lab),

  /// Kalibrlash: hisoblash va yozuvni saqlash, kalibrlash jurnali.
  calibration(ProCapability.lab),

  /// Sifat nazorati (QC): yangi to'plam, to'plamni ochish va natija kiritish.
  qualityControl(ProCapability.lab),

  /// Lab kalkulyatorlari (har bir kalkulyatorni ochish).
  labCalculators(ProCapability.lab);

  const Feature(this.capability);

  /// Qaysi Pro toifasiga tegishli (`null` — bepul funksiya).
  final ProCapability? capability;

  /// Obunani talab qiladigan funksiya (TOIFA bo'yicha). Haqiqatan yopilishi
  /// esa [ProGatePolicy.gated] ga bog'liq (D-71: standart — hech narsa).
  bool get pro => capability != null;
}
