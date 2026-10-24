import 'package:flutter/foundation.dart';

import 'feature.dart';
import 'pro_catalog.dart';

/// Obuna davri.
enum BillingPeriod { month, year }

/// Do'kondagi bitta obuna mahsuloti. Narx bu yerda YO'Q — faqat do'kondan
/// (mahalliy valyutada) keladi.
@immutable
class BillingProduct {
  const BillingProduct(
    this.id, {
    required this.tier,
    required this.period,
    this.student = false,
  });

  final String id;
  final ProTier tier;
  final BillingPeriod period;

  /// Talaba chegirmasi (D-50): faqat talaba holati tasdiqlangan hisobga.
  final bool student;
}

/// Mahsulot id'lari — YAGONA joy. Server ham shu ro'yxatni biladi
/// (`cloudflare/src/billing.ts` → `BILLING_PRODUCTS`); App Store Connect va
/// Play Console'da aynan shu id'lar bilan yaratiladi (docs/PRO_BILLING_PLAN.md).
/// Narxlar va bepul sinov do'konda sozlanadi; ilova ularni do'kondan o'qiydi.
/// TAKLIF qilingan narxlar va sinov sozlamasi — `pro_catalog.dart` (D-71);
/// eski D-48/D-49/D-50/D-57 narxlari va 7/14 kunlik sinov ESKIRGAN.
abstract final class BillingCatalog {
  static const proMonthly = 'uz.labguide.pro.monthly';
  static const proYearly = 'uz.labguide.pro.yearly';
  static const studentMonthly = 'uz.labguide.pro.student.monthly';
  static const studentYearly = 'uz.labguide.pro.student.yearly';
  static const teacherMonthly = 'uz.labguide.teacherpro.monthly';
  static const teacherYearly = 'uz.labguide.teacherpro.yearly';

  static const all = <BillingProduct>[
    BillingProduct(proMonthly, tier: ProTier.pro, period: BillingPeriod.month),
    BillingProduct(proYearly, tier: ProTier.pro, period: BillingPeriod.year),
    BillingProduct(
      studentMonthly,
      tier: ProTier.pro,
      period: BillingPeriod.month,
      student: true,
    ),
    BillingProduct(
      studentYearly,
      tier: ProTier.pro,
      period: BillingPeriod.year,
      student: true,
    ),
    BillingProduct(
      teacherMonthly,
      tier: ProTier.teacher,
      period: BillingPeriod.month,
    ),
    BillingProduct(
      teacherYearly,
      tier: ProTier.teacher,
      period: BillingPeriod.year,
    ),
  ];

  static final ids = {for (final p in all) p.id};

  static BillingProduct? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Xarid qaysi darajani ochadi. Katalogda yo'q (eski/sinov) mahsulot —
  /// Pro (hech qachon Ustoz Pro emas).
  static ProTier tierOf(String productId) =>
      byId(productId)?.tier ?? ProTier.pro;

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
