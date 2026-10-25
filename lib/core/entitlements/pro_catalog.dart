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
/// D-76: 7 kunlik sinov (HAMMA reja uchun; D-75 dagi 30 kun bekor) — SERVER
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

  /// Server sinovi (D-74/D-76) — `cloudflare/src/trial.ts` `TRIAL_DAYS` bilan bir xil.
  static const int serverTrialDays = 7;

  /// Do'kon kirish taklifi (bepul sinov) ko'rsatilsinmi/tanlansinmi: YO'Q.
  static const bool storeIntroOffersAllowed = false;

  /// Do'kon-native sinov yoqilganmi (hozir — yo'q).
  static bool get enabled =>
      storeIntroOffersAllowed && (freeTrialDays ?? 0) > 0;
}

/// Bepul davr mexanizmi (D-75: server bergan sinov).
enum ProTrialMechanism { undecided, storeIntroOffer, serverGranted }

/// Qaysi pullik imkoniyatlar HAQIQATAN yopiladi (D-71). Standart: **bo'sh** —
/// bugungi `main` da bepul bo'lgan hech narsa yopilmaydi. Eski reja
/// (PRO_BILLING_PLAN §1) hamma `Feature.pro` ni yopardi; bu `main` dagi
/// bepul funksiyalarni olib qo'yish bo'lardi (D-71 ziddiyat ro'yxati).
/// Egasi qaror qilgach faqat shu ro'yxat to'ldiriladi.
abstract final class ProGatePolicy {
  static const Set<Feature> gated = {};

  /// REJALASHTIRILGAN Lab yopilishi (D-76, egasi qarori) — FAOL EMAS.
  /// [gated] ga qo'shilmaguncha (va Pro yoqilmaguncha) hech narsa
  /// yopilmaydi; testlar `EntitlementService(gated: plannedLabGate)` bilan
  /// yopish ishlashini va standart buildda hech narsa yopilmasligini
  /// tekshiradi. Ekran (kirish sahifasi) ochiladi; amal/vosita boshlanishida
  /// `requireFeature` to'lov oynasini ko'rsatadi; boshlangan sanash
  /// to'xtatilmaydi.
  static const Set<Feature> plannedLabGate = {
    Feature.leukocyteCounter,
    Feature.absoluteCounts,
    Feature.leukocyteEvaluation,
    Feature.labSections,
    Feature.coagulogram,
    Feature.labInstruments,
    Feature.labDirections,
    Feature.calibration,
    Feature.qualityControl,
    Feature.labCalculators,
  };
}
