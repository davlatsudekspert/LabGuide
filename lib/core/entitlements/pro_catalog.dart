import 'package:flutter/foundation.dart';

import 'billing_catalog.dart';
import 'feature.dart';
import 'plan_matrix.dart';

/// Pullik reja (D-73, D-76): Talaba, Ustoz, Mutaxassis, Premium. Tartib =
/// narx tartibi (admin grant / server huquqni hal qilishda TENG holatda
/// ko'rsatish uchun). Qaysi imkoniyat ochilishi tartibdan EMAS —
/// [PlanMatrix] to'plamidan ([tier]).
enum ProPlan {
  student,
  teacher,
  specialist,
  premium;

  /// Server bilan umumiy nom (`student` / `teacher` / `specialist` / `premium`).
  String get wire => name;

  /// Shu reja ochadigan imkoniyatlar to'plami (D-76 matritsasi). Hozir hech
  /// narsa yopilmaydi ([ProGatePolicy.gated] bo'sh), shuning uchun bu faqat
  /// tayyorgarlik.
  ProTier get tier => ProTier(PlanMatrix.capabilities[this]!);

  static ProPlan? parse(Object? raw) {
    for (final p in values) {
      if (p.name == raw) return p;
    }
    return null;
  }
}

/// Pro narx va sinov KATALOGI — faqat MA'LUMOT. Ekranlar bu yerdan narx
/// o'qimaydi: foydalanuvchi ko'radigan narx har doim do'kondan (mahalliy
/// valyutada) keladi. Bu katalog — do'konlarda mahsulot narxini qo'yish
/// uchun egasiga ko'rsatma va testlar uchun yagona manba.
///
/// Narxlar — EGASI QARORI (2026-10-24, D-73; Premium — D-76), lekin Pro o'chiq: to'lov hech
/// qayerda yoqilmagan. Oldingi narxlar va tariflar (D-48/D-50/D-57/D-71/D-72)
/// hamda eski 7/14 kunlik sinov (D-49) hech qayerda faol emas; ro'yxati
/// docs/DECISIONS.md D-73 da.
@immutable
class ProPlanSpec {
  const ProPlanSpec({
    required this.plan,
    required this.monthlyProductId,
    required this.yearlyProductId,
    required this.monthlyUsd,
    required this.yearlyUsd,
  });

  final ProPlan plan;
  final String monthlyProductId;
  final String yearlyProductId;

  /// Oylik narx (AQSh dollari) — egasi qarori, D-73.
  final double monthlyUsd;

  /// Yillik narx (AQSh dollari) — egasi qarori, D-73. `null` bo'lsa yillik
  /// mahsulot taklif QILINMAYDI.
  final double? yearlyUsd;

  bool get annualOffered => yearlyUsd != null;
}

abstract final class ProPricing {
  /// Egasi tasdiqlagan bazaviy narxlar (D-73, D-76; 2026-10-24) — YAGONA
  /// narx manbai (docs va testlar shu ro'yxatdan). Mahalliy
  /// valyuta narxlari (UZS va h.k.) — do'kon narx nuqtalari, ochiq qaror.
  ///
  /// D-77: UNCONFIRMED-until-created-in-store — bu narxlar va mahsulot
  /// id'lari App Store Connect / Play Console'da HALI YARATILMAGAN; do'konda
  /// yaratilgach qayta tekshiriladi. Ilova va server boshqa joyda narx
  /// qotirmaydi (`test/guards/paid_policy_d77_guard_test.dart`).
  static const plans = <ProPlanSpec>[
    ProPlanSpec(
      plan: ProPlan.student,
      monthlyProductId: BillingCatalog.studentMonthly,
      yearlyProductId: BillingCatalog.studentYearly,
      monthlyUsd: 1.49,
      yearlyUsd: 9.99,
    ),
    ProPlanSpec(
      plan: ProPlan.teacher,
      monthlyProductId: BillingCatalog.teacherMonthly,
      yearlyProductId: BillingCatalog.teacherYearly,
      monthlyUsd: 2.49,
      yearlyUsd: 24.99,
    ),
    ProPlanSpec(
      plan: ProPlan.specialist,
      monthlyProductId: BillingCatalog.specialistMonthly,
      yearlyProductId: BillingCatalog.specialistYearly,
      monthlyUsd: 3.49,
      yearlyUsd: 34.99,
    ),
    ProPlanSpec(
      plan: ProPlan.premium,
      monthlyProductId: BillingCatalog.premiumMonthly,
      yearlyProductId: BillingCatalog.premiumYearly,
      monthlyUsd: 4.99,
      yearlyUsd: 49.99,
    ),
  ];

  /// Yillik mahsulot to'lov oynasida ko'rsatilsinmi (faqat narxi belgilangan
  /// reja uchun).
  static bool yearlyOffered(String productId) {
    for (final p in plans) {
      if (p.yearlyProductId == productId) return p.annualOffered;
    }
    return false;
  }
}

/// Bepul foydalanish davri sozlamasi (D-71/D-73 → D-75 → D-76).
///
/// D-80 (2026-10-31, egasi qarori): 30 kunlik sinov (HAMMA pullik reja uchun;
/// D-76/D-77 dagi 7 kun almashtirildi; Bepul daraja o'zgarmagan) — SERVER
/// beradigan, kartasiz sinov (M1, [ProTrialMechanism.serverGranted]). Server qoidasi: `cloudflare/src/trial.ts`
/// (`TRIAL_DAYS`, `TRIAL_PLATFORMS` — standart faqat Android; iOS Apple
/// yozma javobidan keyin). Ilova sinov tugmasini faqat server imkoniyat
/// so'rovi (`GET /v1/billing/status` → `trial.<platforma>`) `true` desa va
/// qurilma attestatsiyasi sozlangan bo'lsa ko'rsatadi.
///
/// * [freeTrialDays] — DO'KON kirish taklifi (Apple Introductory Offer /
///   Play free-trial offer) kunlari: `null` = YO'Q. Ikki marta sinov bo'lmasin
///   (POLICY_REVIEW §4 "Trial stacking"): do'kon sinov taklifi ilovada
///   ko'rsatilmaydi va tanlanmaydi ([storeIntroOffersAllowed] = false).
/// * [serverTrialDays] — server sinovi uzunligi (faqat matn uchun; qaror
///   serverda). Sinov hech qachon xarid boshlamaydi va pul yechmaydi.
abstract final class ProTrialConfig {
  static const int? freeTrialDays = null;
  static const ProTrialMechanism mechanism = ProTrialMechanism.serverGranted;

  /// Server sinovi (D-74/D-80) — `cloudflare/src/trial.ts` `TRIAL_DAYS` bilan bir xil.
  static const int serverTrialDays = 30;

  /// Do'kon kirish taklifi (bepul sinov) ko'rsatilsinmi/tanlansinmi: YO'Q.
  static const bool storeIntroOffersAllowed = false;

  /// Do'kon-native sinov yoqilganmi (hozir — yo'q).
  static bool get enabled =>
      storeIntroOffersAllowed && (freeTrialDays ?? 0) > 0;
}

/// Bepul davr mexanizmi (D-75: server bergan sinov).
enum ProTrialMechanism { undecided, storeIntroOffer, serverGranted }

/// Qaysi pullik imkoniyatlar HAQIQATAN yopiladi (D-71 → D-78).
///
/// D-78 (egasi qarori, 2026-10-25): [Feature] katalogida faqat YANGI Pro
/// funksiyalar bor — bugun `main` da bepul bo'lgan hech narsa yopilmaydi
/// (D-76 dagi Lab yopilishi rejasi, kunlik limit, "oxirgi 3 natija" tarixi, atlas /
/// toifa / mashq yopilishi BEKOR). [gated] ga faqat QURILGAN funksiya
/// (ekran + test) qo'shiladi; qurilmagan katalog qatori to'lov oynasida
/// va'da qilinmaydi.
///
/// Pro bayrog'i (`LG_PRO_ENABLED`) o'chiq buildda bu ro'yxat ta'sir
/// qilmaydi: `EntitlementService.disabled()` hamma narsani ochadi va Pro
/// kirish nuqtalari ko'rsatilmaydi.
abstract final class ProGatePolicy {
  ///
  /// Qurilgan (ekran + test): Talaba Pro va Mutaxassis Pro —
  /// `lib/features/pro/*`; Ustoz Pro — test yaratish
  /// (`lib/features/teacher_pro/teacher_test_screens.dart`), topshirish va
  /// taklifnoma (`teacher_assign_screens.dart`), natijalar va CSV
  /// (`teacher_results_screens.dart`); talaba tomoni — Ustoz testlarini
  /// boshlash (`student_teacher_tests_screens.dart`). Testlar:
  /// `test/widget/pro_learner_test.dart`, `pro_lab_test.dart`,
  /// `teacher_pro_test.dart`, server `cloudflare/test/teachertests.test.ts`.
  static const Set<Feature> gated = {
    // Talaba Pro — ekranlar: lib/features/pro/{results,simulation}_screens.dart.
    Feature.resultsAnalytics,
    Feature.examSimulation,
    Feature.resultsExport,
    // Mutaxassis Pro — lib/features/pro/{calibration_export,qc_report*}.dart.
    Feature.calibrationExport,
    Feature.qcReport,
    // Ustoz Pro va talaba tomoni (`teacherTests`).
    Feature.teacherTests,
    Feature.teacherTestBuilder,
    Feature.teacherTestAssign,
    Feature.teacherResults,
  };

  /// Butun pullik katalog (regressiya testi: hammasi yopilganda ham bugungi
  /// bepul funksiyalar ochiq qoladi).
  static final Set<Feature> catalog = Set.unmodifiable(Feature.values);
}
