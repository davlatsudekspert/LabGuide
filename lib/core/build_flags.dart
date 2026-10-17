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

/// [kPartnerAds] ni o'qish uchun yagona joy. Release buildda bu doimiy
/// ([kReleaseMode] ham doimiy) — `false` bo'lsa kompilyator reklama kodini
/// butunlay olib tashlaydi. Debug/test buildda [debugPartnerAdsOverride]
/// orqali widget testlari ikkala holatni ham tekshiradi.
abstract final class BuildFlags {
  /// Faqat testlar uchun (release buildda e'tiborsiz).
  @visibleForTesting
  static bool? debugPartnerAdsOverride;

  static bool get partnerAds =>
      kReleaseMode ? kPartnerAds : (debugPartnerAdsOverride ?? kPartnerAds);
}
