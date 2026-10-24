import 'package:flutter/foundation.dart';

import 'billing_catalog.dart';
import 'feature.dart';

/// Pro narx va sinov KATALOGI — faqat MA'LUMOT (D-71). Ekranlar bu yerdan
/// narx o'qimaydi: foydalanuvchi ko'radigan narx har doim do'kondan
/// (mahalliy valyutada) keladi. Bu katalog — do'konlarda mahsulot narxini
/// qo'yish uchun egasiga ko'rsatma va testlar uchun yagona manba.
///
/// DIQQAT: hamma narx TAKLIF (PROPOSED) — egasi tasdiqlamagan. Eski narxlar
/// (D-48/D-50/D-57) va eski 7/14 kunlik sinov (D-49) hech qayerda faol emas.
@immutable
class ProPlanSpec {
  const ProPlanSpec({
    required this.monthlyProductId,
    required this.yearlyProductId,
    required this.tier,
    required this.student,
    required this.monthlyUsd,
    this.yearlyUsd,
  });

  final String monthlyProductId;
  final String yearlyProductId;
  final ProTier tier;
  final bool student;

  /// TAKLIF qilingan bazaviy oylik narx (AQSh dollari). Tasdiqlanmagan.
  final double monthlyUsd;

  /// Yillik narx. `null` — belgilanmagan va yillik mahsulot taklif
  /// QILINMAYDI.
  // TODO(owner): yillik narxlar (yoki yillik umuman yo'qligi) — D-71, ochiq
  // qaror #2. Belgilanmaguncha null.
  final double? yearlyUsd;

  bool get annualOffered => yearlyUsd != null;
}

abstract final class ProPricing {
  /// TAKLIF (PROPOSED, tasdiqlanmagan) bazaviy oylik narxlar.
  static const plans = <ProPlanSpec>[
    ProPlanSpec(
      monthlyProductId: BillingCatalog.studentMonthly,
      yearlyProductId: BillingCatalog.studentYearly,
      tier: ProTier.pro,
      student: true,
      monthlyUsd: 1.49,
    ),
    ProPlanSpec(
      monthlyProductId: BillingCatalog.proMonthly,
      yearlyProductId: BillingCatalog.proYearly,
      tier: ProTier.pro,
      student: false,
      monthlyUsd: 3.99,
    ),
    ProPlanSpec(
      monthlyProductId: BillingCatalog.teacherMonthly,
      yearlyProductId: BillingCatalog.teacherYearly,
      tier: ProTier.teacher,
      student: false,
      monthlyUsd: 5.99,
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

/// Bepul foydalanish davri sozlamasi (D-71, ochiq qaror #4).
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
