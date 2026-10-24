import 'package:flutter/foundation.dart';

/// Hamkor (reklama) UI build bayrog'i: `--dart-define=LG_PARTNER_ADS=true`.
///
/// Standart `false` — do'konga yuboriladigan buildda reklama/hamkor UI
/// umuman yo'q (bosh sahifa juftligi, Lab kartasi, apparat kartalari,
/// hamkor sahifalari, "Hamkor bo'lish", admin hamkor bo'limlari, ko'rsatuv
/// hisoboti). `true` faqat TestFlight va Play ichki test buildlarida
/// (ci.yml `testflight` / `play_internal`): haqiqiy hamkor kartalari,
/// hamkor bo'lmasa — "Namuna" demo kartalari.
const bool kPartnerAds = bool.fromEnvironment('LG_PARTNER_ADS');

/// Pro (obuna) build bayrog'i: `--dart-define=LG_PRO_ENABLED=true`.
///
/// Standart `false` (D-71). `false` bo'lsa ilova `main` (bepul reliz) bilan
/// bir xil: to'lov oynasi, Profil'da obuna qatori, `/profile/purchase`
/// yo'li yo'q, do'kon plagini ishga tushirilmaydi, serverga billing
/// so'rovi ketmaydi, hech bir imkoniyat yopilmaydi.
const bool kProEnabled = bool.fromEnvironment('LG_PRO_ENABLED');

/// FAQAT DEBUG (D-75): `--dart-define=LG_FAKE_PURCHASES=true` — soxta do'kon,
/// soxta server va soxta attestatsiya (lib/core/entitlements/
/// debug_fake_purchases.dart) bilan obuna oqimini emulyatorda sinash.
/// Release buildda e'tiborsiz: [BuildFlags.fakePurchases] doimiy `false`.
const bool kFakePurchasesRequested = bool.fromEnvironment('LG_FAKE_PURCHASES');

/// [kPartnerAds] ni o'qish uchun yagona joy. Release buildda bu doimiy
/// ([kReleaseMode] ham doimiy) — `false` bo'lsa kompilyator reklama kodini
/// butunlay olib tashlaydi. Debug/test buildda [debugPartnerAdsOverride]
/// orqali widget testlari ikkala holatni ham tekshiradi.
abstract final class BuildFlags {
  /// Faqat testlar uchun (release buildda e'tiborsiz).
  @visibleForTesting
  static bool? debugPartnerAdsOverride;

  /// Faqat testlar uchun (release buildda e'tiborsiz).
  @visibleForTesting
  static bool? debugProEnabledOverride;

  /// Pro qatlami yoqilganmi. Release buildda doimiy [kProEnabled].
  static bool get proEnabled =>
      kReleaseMode ? kProEnabled : (debugProEnabledOverride ?? kProEnabled);

  /// Soxta xaridlar (D-75). Release buildda DOIMIY `false` (`kReleaseMode`
  /// const) — kod kompilyatsiyada olib tashlanadi; faqat Pro yoqilgan
  /// debug/profile buildda ishlaydi.
  static bool get fakePurchases =>
      !kReleaseMode && kFakePurchasesRequested && proEnabled;

  static bool get partnerAds =>
      kReleaseMode ? kPartnerAds : (debugPartnerAdsOverride ?? kPartnerAds);
}
