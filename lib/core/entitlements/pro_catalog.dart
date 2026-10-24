import 'package:flutter/foundation.dart';

import 'billing_catalog.dart';
import 'feature.dart';

/// Pullik daraja (D-73): Talaba, Ustoz, Mutaxassis. Tartib = narx tartibi:
/// admin grant va server huquqni hal qilishda yuqori daraja yutadi.
enum ProPlan {
  student,
  teacher,
  specialist;

  /// Server bilan umumiy nom (`student` / `teacher` / `specialist`).
  String get wire => name;

  /// Shu daraja ilovada ochadigan imkoniyatlar darajasi. Talaba — Pro;
  /// Ustoz — Ustoz Pro (guruhlar); Mutaxassis — Ustoz Pro darajasi (eng
  /// qimmat reja kamroq bermasin).
  // TODO(owner): qaysi daraja nimani ochishi (D-73, ochiq qaror) — hozir
  // hech narsa yopilmaydi ([ProGatePolicy.gated] bo'sh), shuning uchun bu
  // moslik faqat tayyorgarlik.
  ProTier get tier => switch (this) {
    student => ProTier.pro,
    teacher => ProTier.teacher,
    specialist => ProTier.teacher,
  };

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
/// Narxlar — EGASI QARORI (2026-10-24, D-73), lekin Pro o'chiq: to'lov hech
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
  /// Egasi tasdiqlagan bazaviy narxlar (D-73, 2026-10-24). Mahalliy
  /// valyuta narxlari (UZS va h.k.) — do'kon narx nuqtalari, ochiq qaror.
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

/// Bepul foydalanish davri sozlamasi (D-71/D-73, ochiq qaror).
///
/// [freeTrialDays] semantikasi:
/// * `null` (standart) — **o'chiq**: hech qanday bepul davr taklif qilinmaydi
///   va hech bir mexanizm yoqilmaydi. Eski 7/14 kun bu yerda YO'Q.
/// * `> 0` — bepul davr uzunligi (kun). MEXANIZM qaror qilinmagan, ikki variant:
///   (a) do'kon-native kirish taklifi (Apple Introductory Offer / Google Play
///   free-trial offer): kunlar do'konda sozlanadi, ilova uni do'kondan o'qiydi
///   (`StoreProduct.freeTrial`), karta/Apple ID olinadi, 3.1.2 matni do'kondan;
///   (b) server tomonidan beriladigan sinov huquqi (kartasiz): serverda
///   `trial_until` yoziladi — HALI YO'Q (faqat shu sozlama va
///   [ProTrialMechanism] ilgagi bor).
/// Ilova hozir [freeTrialDays] ni faqat HUJJAT/TEKSHIRUV uchun o'qiydi:
/// to'lov oynasidagi sinov yozuvi har doim do'kon javobidan olinadi.
abstract final class ProTrialConfig {
  static const int? freeTrialDays = null;
  static const ProTrialMechanism mechanism = ProTrialMechanism.undecided;

  static bool get enabled => (freeTrialDays ?? 0) > 0;
}

/// Bepul davr mexanizmi — egasi qarori kutilmoqda.
enum ProTrialMechanism { undecided, storeIntroOffer, serverGranted }

/// Qaysi pullik imkoniyatlar HAQIQATAN yopiladi (D-71). Standart: **bo'sh** —
/// bugungi `main` da bepul bo'lgan hech narsa yopilmaydi. Eski reja
/// (PRO_BILLING_PLAN §1) hamma `Feature.pro` ni yopardi; bu `main` dagi
/// bepul funksiyalarni olib qo'yish bo'lardi (D-71 ziddiyat ro'yxati).
/// Egasi qaror qilgach faqat shu ro'yxat to'ldiriladi.
abstract final class ProGatePolicy {
  static const Set<Feature> gated = {};
}
