import 'purchase_adapter.dart';

/// Ikki xil "bepul davr" siyosati (D-77 addendum; docs/PRO_TRIAL_ABUSE_NOTES.md §5):
///
/// 1. **LabGuide server sinovi** — 7 kun, kartasiz, avtomatik pullik emas,
///    bir hisob/email/qurilmaga bir marta (`cloudflare/src/trial.ts`).
/// 2. **Do'kon kirish taklifi** — Apple Introductory Offer / Play free-trial
///    yoki chegirmali offer: avtomatik yangilanadigan obunaning bir qismi,
///    to'lov usuli kerak, muvofiqlikni DO'KON hal qiladi.
///
/// Qoidalar (bu fayl — yagona joy):
/// * Taklif shartlari (uzunlik, keyingi narx, davr) faqat do'kon
///   ma'lumotidan ko'rsatiladi — ilovada hech qanday kun/narx qotirilmaydi.
/// * Do'kon "haqli emas" desa — taklif ko'rsatilmaydi (server sinovi
///   ishlatilgan foydalanuvchiga "yana bir hafta bepul" deyilmaydi, faqat
///   do'kon haqli desa).
/// * Google Play: taklif faqat [storeOffersAllowed] (egasi qarori,
///   `ProTrialConfig.storeIntroOffersAllowed`, standart `false`) bo'lsa
///   tanlanadi; aks holda asosiy reja (base plan) sotiladi — taklif
///   qo'llanmaydi, ko'rsatilmaydi.
/// * App Store: haqli foydalanuvchiga Apple kirish taklifini O'ZI qo'llaydi
///   (ilova tanlamaydi). Shuning uchun taklif bo'lsa va haqli bo'lsa — shartlar
///   HAR DOIM ko'rsatiladi (aks holda to'lov oynasi do'kon oynasidan farq
///   qiladi). Egasi App Store Connect'da taklif yaratmasa — hech narsa
///   ko'rsatilmaydi.
/// * Xarid faqat foydalanuvchi tugmani bosib, do'konning o'z tasdiq oynasida
///   tasdiqlagandan keyin (StoreKit / Play Billing) — ilova o'zi pul yechmaydi.
abstract final class StoreOfferPolicy {
  /// Ko'rsatiladigan (va qo'llanadigan) taklif yoki `null`.
  static StoreIntroOffer? visible(
    StoreProduct p, {
    required bool ios,
    required bool storeOffersAllowed,
  }) {
    final o = p.introOffer;
    if (o == null || !o.eligible) return null;
    if (!ios && !storeOffersAllowed) return null;
    return o;
  }

  /// To'lov oynasi uchun mahsulot: ko'rinmaydigan taklif olib tashlanadi,
  /// ko'rinadigani `freeTrial` ga ham yoziladi (eski UI maydoni).
  static StoreProduct apply(
    StoreProduct p, {
    required bool ios,
    required bool storeOffersAllowed,
  }) {
    final o = visible(p, ios: ios, storeOffersAllowed: storeOffersAllowed);
    if (o == null) return p.withoutOffer();
    return StoreProduct(
      id: p.id,
      title: p.title,
      displayPrice: p.displayPrice,
      period: p.period,
      freeTrial: o.isFreeTrial ? o.total : null,
      introOffer: o,
    );
  }
}
