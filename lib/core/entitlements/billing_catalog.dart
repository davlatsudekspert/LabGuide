import 'package:flutter/foundation.dart';

import 'feature.dart';
import 'pro_catalog.dart';

/// Obuna davri.
enum BillingPeriod { month, year }

/// Do'kondagi bitta obuna mahsuloti. Narx bu yerda YO'Q — faqat do'kondan
/// (mahalliy valyutada) keladi.
@immutable
class BillingProduct {
  const BillingProduct(this.id, {required this.plan, required this.period});

  final String id;
  final ProPlan plan;
  final BillingPeriod period;

  ProTier get tier => plan.tier;

  /// Talaba chegirmasi (D-50): faqat talaba holati tasdiqlangan hisobga.
  bool get student => plan == ProPlan.student;
}

/// Mahsulot id'lari — YAGONA joy. Server ham shu ro'yxatni biladi
/// (`cloudflare/src/billing.ts` → `BILLING_PRODUCTS`); App Store Connect va
/// Play Console'da aynan shu id'lar bilan yaratiladi (docs/PRO_BILLING_PLAN.md).
/// Narxlar va bepul sinov do'konda sozlanadi; ilova ularni do'kondan o'qiydi.
/// Egasi narxlari (D-73) — `pro_catalog.dart`; eski D-48/D-49/D-50/D-57/D-71/
/// D-72 narxlari va 7/14 kunlik sinov ESKIRGAN.
abstract final class BillingCatalog {
  static const studentMonthly = 'uz.labguide.student.monthly';
  static const studentYearly = 'uz.labguide.student.yearly';
  static const teacherMonthly = 'uz.labguide.teacher.monthly';
  static const teacherYearly = 'uz.labguide.teacher.yearly';
  static const specialistMonthly = 'uz.labguide.specialist.monthly';
  static const specialistYearly = 'uz.labguide.specialist.yearly';

  /// Eski (D-46…D-72) id → yangi id. Do'konda hech qachon mahsulot
  /// yaratilmagan (D-73), shuning uchun faqat server qatori / eski kesh
  /// bo'lsa o'qiladi; yangi mahsulot YARATILMAYDI.
  static const legacyAliases = <String, String>{
    'uz.labguide.pro.monthly': specialistMonthly,
    'uz.labguide.pro.yearly': specialistYearly,
    'uz.labguide.pro.student.monthly': studentMonthly,
    'uz.labguide.pro.student.yearly': studentYearly,
    'uz.labguide.teacherpro.monthly': teacherMonthly,
    'uz.labguide.teacherpro.yearly': teacherYearly,
  };

  static const all = <BillingProduct>[
    BillingProduct(
      studentMonthly,
      plan: ProPlan.student,
      period: BillingPeriod.month,
    ),
    BillingProduct(
      studentYearly,
      plan: ProPlan.student,
      period: BillingPeriod.year,
    ),
    BillingProduct(
      teacherMonthly,
      plan: ProPlan.teacher,
      period: BillingPeriod.month,
    ),
    BillingProduct(
      teacherYearly,
      plan: ProPlan.teacher,
      period: BillingPeriod.year,
    ),
    BillingProduct(
      specialistMonthly,
      plan: ProPlan.specialist,
      period: BillingPeriod.month,
    ),
    BillingProduct(
      specialistYearly,
      plan: ProPlan.specialist,
      period: BillingPeriod.year,
    ),
  ];

  static final ids = {for (final p in all) p.id};

  /// Eski id ham yangisiga o'giriladi ([legacyAliases]).
  static BillingProduct? byId(String id) {
    final key = legacyAliases[id] ?? id;
    for (final p in all) {
      if (p.id == key) return p;
    }
    return null;
  }

  /// Xarid qaysi darajani ochadi. Katalogda yo'q (sinov) mahsulot — Pro
  /// (hech qachon Ustoz darajasi emas).
  static ProTier tierOf(String productId) =>
      byId(productId)?.tier ?? ProTier.pro;

  /// Xarid qaysi pullik daraja (`null` — katalogda yo'q).
  static ProPlan? planOf(String productId) => byId(productId)?.plan;

  /// Talaba holati tasdiqlangan hisob. Hozir ilovada bunday tasdiq YO'Q
  /// (D-49: talaba bileti bilan tasdiqlash — keyin), shuning uchun talaba
  /// mahsulotlari to'lov oynasida ko'rsatilmaydi.
  static bool offered(BillingProduct p, {required bool studentVerified}) =>
      (!p.student || studentVerified) &&
      (p.period != BillingPeriod.year || ProPricing.yearlyOffered(p.id));
}

/// To'lov oynasidagi majburiy havolalar (App Store 3.1.2).
abstract final class BillingLinks {
  /// Foydalanish shartlari: Apple'ning standart EULA'si.
  static const termsOfUse =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Maxfiylik siyosati (docs/store/PRIVACY_POLICY.md; App Store Connect'dagi
  /// havola bilan bir xil bo'lsin — docs/store/APP_STORE.md 14-bo'lim).
  static const privacyPolicy =
      'https://github.com/davlatsudekspert/LabGuide/blob/main/docs/store/PRIVACY_POLICY.md';

  /// Obunani boshqarish (bekor qilish) sahifasi.
  static String manageSubscriptions({
    required bool ios,
    String? productId,
    String package = 'uz.labguide.app',
  }) => ios
      ? 'https://apps.apple.com/account/subscriptions'
      : Uri.https('play.google.com', '/store/account/subscriptions', {
          'package': package,
          'sku': ?productId,
        }).toString();
}
