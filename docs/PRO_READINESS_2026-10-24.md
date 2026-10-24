# Pro tayyorlik auditi — 2026-10-24 (D-75)

Tarmoq: `pro-next`. Boshlang'ich holat: `b532f04` (D-74). Bu ish: D-75 commitlari (server `8630092`,
ilova `0105528`, hujjatlar — keyingi commit). **Production to'lov YOQILMAGAN:** `BuildFlags.proEnabled`
standart `false`, server `LG_BILLING_ENABLED` o'chiq (billing yo'llari 404), `ProGatePolicy.gated` BO'SH,
`LG_BILLING_SANDBOX` o'chiq, `TRIAL_PLATFORMS` standart `android`, haqiqiy do'kon/attestatsiya kalitlari yo'q.
Hech narsa deploy qilinmadi, migratsiyalar faqat fayl (0013–0016).

Holatlar: **IMPLEMENTED_TESTED** — kod + avtomatik test (soxta do'kon/tekshiruvchi bilan);
**IMPLEMENTED_UNTESTED** — kod bor, lekin faqat haqiqiy qurilma/do'konda sinab bo'ladi;
**PARTIAL** — qisman; **MISSING** — yo'q. "Oldin" ustuni — `b532f04` dagi holat.

Narxlar yagona manbada: `lib/core/entitlements/pro_catalog.dart` (`ProPricing`): Talaba 1.49/9.99,
Ustoz 2.49/24.99, Mutaxassis 3.49/34.99 USD. UI do'kon narxini (bo'lmasa katalogni) ko'rsatadi; server va
ekran kodida narx yo'q; test fixture narxlari `ProPricing` dan olinadi
(`pro_flag_default_guard_test :: narx yagona manbada`).

| # | Talab | Oldin | Hozir | Kod (fayl:qator) | Testlar |
|---|---|---|---|---|---|
| 1 | Google Play Billing (xarid, acknowledge, oylik+yillik base plan, Play sinov taklifi YO'Q) | PARTIAL (sinov taklifini tanlar edi, base plan moslashi yo'q) | IMPLEMENTED_UNTESTED (plagin yo'li faqat qurilmada; moslash va siyosat testlangan) | `lib/core/entitlements/store_purchase_adapter.dart:184` (faqat asosiy reja, kanonik id), `:311` buy (`applicationUserName` = obfuscatedAccountId `:327`), `:393` finish→`completePurchase`; server ack `cloudflare/src/billing.ts:491`; `billing_catalog.dart:90,107` | `pro_readiness_d75_test :: Play obuna + base plan → kanonik id`, `:: do‘kon sinov taklifi ko‘rsatilmaydi`; `billing.test.ts :: base plan … acknowledge obuna id si bilan`, `:: subscriptionsv2 … acknowledge` |
| 2 | Apple StoreKit 2 (oylik+yillik, obuna guruhi, restore) | IMPLEMENTED_UNTESTED | IMPLEMENTED_UNTESTED (guruh — App Store Connect sozlamasi; server ixtiyoriy `APPLE_SUBSCRIPTION_GROUP_ID` tekshiruvi) | `store_purchase_adapter.dart:135` (kirish taklifi ko'rsatilmaydi), `:369` restore + `:377` `sync()`; `billing.ts:309` guruh tekshiruvi | `entitlements_test` (soxta adapter bilan xarid/tiklash oqimi); haqiqiy StoreKit — `docs/PRO_TEST_ENVIRONMENT.md` |
| 3 | Server tekshiruvi (Apple JWS imzo + bundle + muhit; Google subscriptionsv2 + acknowledge), injeksiya, kalitsiz 503 | PARTIAL (JWS imzosi tekshirilmas edi, injeksiya yo'q, `not_configured`) | IMPLEMENTED_TESTED (haqiqiy API'lar soxta `fetch` bilan; jonli kalit bilan sinalmagan) | `billing.ts:126` `StoreVerifier`, `:309` verifyApple, `:364` muhit, `:441` verifyGoogle; `cloudflare/src/x509.ts:198` (x5c → Apple Root CA G3 pin `:26`, OID, muddat, ES256) | `x509.test.ts` (3), `billing.test.ts :: ASSN v2: imzo …`, `:: production host sandbox … environment_mismatch`, `guards.test.ts :: kalitsiz do‘kon tekshiruvchisi — 503 store_verifier_not_configured` |
| 4 | Oylik/yillik, mahsulot id moslashi, aliaslar | IMPLEMENTED_TESTED | IMPLEMENTED_TESTED | `billing_catalog.dart:24–107`, `billing.ts:36–100` (`BILLING_PRODUCTS`, `PLAY_SUBSCRIPTIONS`, `canonicalProduct`) | `progrants.test.ts :: mahsulot id lari`, `pro_readiness_d75_test :: Play obuna + base plan` |
| 5 | Restore (iOS/Android) + server qayta sinxronlash | PARTIAL (server qayta o'qimas edi) | IMPLEMENTED_TESTED | `entitlement_service.dart:643`; `billing.ts:824` (`restore: true`) → `:874` resync | `billing_lifecycle.test.ts :: restore: true — … serverda yangilanadi`, `entitlements_test` (tiklash), `subscription_screen_test` (tiklash tugmasi) |
| 6 | Bekor qilish / muddat: davr oxirigacha; tugagach Pro yo'q, BEPUL hammasi ishlaydi | PARTIAL (aniq test yo'q) | IMPLEMENTED_TESTED | `billing.ts:431` (Play CANCELED → active muddatgacha), `:623` resolveAccess; `entitlement_service.dart:429` `can()` (gated bo'sh) | `billing_lifecycle.test.ts :: bekor qilish …`, `:: Pro tugadi — bepul ustoz paneli …`; `subscription_screen_test :: Pro tugadi …`; `pro_readiness_d75_test :: kesh chegarasi …` (hamma `Feature` ochiq) |
| 7 | Refund/revoke/chargeback: ASSN V2 + RTDN, imzo/auth, idempotent, audit; grace — bor, hold/pause — yo'q | PARTIAL (imzo/auth ixtiyoriy, takror yo'q, audit yo'q, voided API "faol" desa e'tiborsiz) | IMPLEMENTED_TESTED | `billing.ts:928` ASSN (REFUND/REVOKE → revoked), `:1008` RTDN auth (OIDC `social.ts:170` yoki token; hech biri — 503), `:1032` RTDN (REVOKED/voided → revoked); jadval `migrations/0016_billing_notifications.sql` | `billing.test.ts :: ASSN v2 …`, `:: RTDN: autentifikatsiya majburiy …`; `billing_lifecycle.test.ts :: DID_FAIL_TO_RENEW …`, `:: ON_HOLD va PAUSED …`, `:: REVOKE …`, `:: RTDN OIDC …` |
| 8 | Qurilmalararo sinxron: serverda saqlash; kirish, ishga tushish, qaytishda yangilash; ziddiyat: yuqori daraja → uzoq muddat | PARTIAL (qaytishda yangilash yo'q) | IMPLEMENTED_TESTED | `entitlement_service.dart:477` start, `:705` onResume (5 daq.), `lib/main.dart:75` AppLifecycleListener, `lib/app/app_scope.dart:202` (kirish/chiqish), `:274` `_beats` = `billing.ts:623` | `pro_readiness_d75_test :: ilova qayta ochilganda …`, `:: ziddiyat …`; `progrants.test.ts :: huquqni hal qilish …` |
| 9 | Daraja huquqlari serverda; Talaba lokal rolni almashtirib Ustoz-Pro ololmaydi | IMPLEMENTED_TESTED | IMPLEMENTED_TESTED | `cloudflare/src/tiers.ts:37,56`; ilova `plan_matrix.dart` | `tiers.test.ts :: Talaba rejasi … hatto profil roli “teacher” …`; `pro_readiness_d75_test :: Talaba rejasi ustoz paneli …` |
| 10 | Sandbox: faqat `LG_BILLING_SANDBOX=true`; production sandbox'ni rad; debug soxta xarid (release'da imkonsiz) | MISSING | IMPLEMENTED_TESTED | `billing.ts:142,159`, Apple host tanlash; `lib/core/build_flags.dart:47`; `lib/core/entitlements/debug_fake_purchases.dart`; `docs/PRO_TEST_ENVIRONMENT.md` | `billing.test.ts :: LG_BILLING_SANDBOX yo‘q …`, `:: test xaridi … 403`; `billing_lifecycle.test.ts :: sandbox …`; `pro_flag_default_guard_test :: D-75 …` (4 qorovul); `pro_readiness_d75_test :: soxta (debug) xarid oqimi` |
| 11 | Oflayn: imzolangan kesh, max = min(davr oxiri, 7 kun), uzaytirilmaydi, bepulga yopiladi | PARTIAL (7 kun lokal) | PARTIAL → asosan bajarilgan: server `offline_until` (min(7 kun, huquq tugashi)) + qurilmada HMAC (Keychain/Keystore kaliti) imzo; **server ASIMMETRIK imzosi YO'Q** (kesh qurilma kaliti bilan imzolanadi) | `billing.ts:771`; `entitlement_service.dart:526,231`; `entitlement_cache.dart:108,118` | `billing_lifecycle.test.ts :: min(hozir + 7 kun …)`; `pro_readiness_d75_test` (oflayn guruhi, 3 test); `entitlements_test` (imzo buzilsa e'tiborsiz) |
| 12 | “Obuna” ekrani: to'lanadigan narx eng ko'zga tashlanadigan, yillik — yillik, boshqarish/bekor, Restore, Terms/Privacy, iOS'da boshqa to'lov yo'li yo'q, sinov matni | PARTIAL (havolalar, sinov matni yo'q) | IMPLEMENTED_TESTED | `lib/features/profile/subscription_screen.dart:74` narx, `:167` sinov bo'limi, `:334` boshqarish, shartlar, maxfiylik; ARB `proSubTrial*`, `proSubEnded`, `proSubPriceYearlyNote`, `proSubWithoutSubscription` (uz/ru/en) | `subscription_screen_test` (11 test: havolalar, `http` yo'q, 320px×1.3 uch tilda) |
| T | 30 kunlik sinov: platforma (iOS 403 standart), imkoniyat so'rovi, tugma faqat so'rov+attestatsiya bilan, xarid yo'q | PARTIAL (platforma cheklovi yo'q) | IMPLEMENTED_TESTED | `cloudflare/src/trial.ts:106,124,261`; `billing.ts:783` status; `entitlement_service.dart:345,361,372`; `entitlement_source.dart` `trialOffered` | `trial.test.ts :: iOS standart bo‘yicha — 403 …`, `:: imkoniyat so‘rovi …`, `:: … TRIAL_PLATFORMS=android,ios …`, `:: sinov hech qachon do‘kon xaridini boshlamaydi …`; `subscription_screen_test` D-75 guruhi (3) |
| A | Haqiqiy qurilma attestatsiyasi (Play Integrity, DeviceCheck/App Attest) | MISSING | MISSING (kalitlar va native plagin kerak; interfeys + soxta bor) | `trial.ts` `DeviceAttestationVerifier`, `device_attestor.dart` | — |

**Hisob (12 talab + sinov + attestatsiya = 14 qator):** IMPLEMENTED_TESTED — 10; IMPLEMENTED_UNTESTED — 2
(#1, #2: plagin/do'kon yo'li faqat qurilmada); PARTIAL — 1 (#11: server asimmetrik imzosi yo'q);
MISSING — 1 (A: haqiqiy attestatsiya).

## Qorovullar (yangi)
- `test/guards/pro_flag_default_guard_test.dart` → D-75 guruhi: `fakePurchases` release'da doimiy false;
  `DebugFake*` faqat `main.dart` da `fake ?` ortida; CI/ios/android LG_FAKE_PURCHASES ni yoqmaydi;
  sandbox/iOS sinov standartlari; narx yagona manbada. Mavjudlari: `proEnabled` standart false,
  `gated` bo'sh, do'kon sinov taklifi yo'q.
- `cloudflare/test/guards.test.ts :: qorovul: Pro to‘lov standartlari (D-75)` (2).

## Ma'lum cheklovlar
- Apple App Review sandbox'da sinaydi: production'da `LG_BILLING_SANDBOX` o'chiq bo'lsa, review xaridi rad
  etiladi (`sandbox_not_allowed`). Review davrida yoqish yoki alohida yondashuv — egasi qarori (D-75 §ochiq).
- Haqiqiy App Store/Play API'lari jonli kalit bilan sinalmagan; JSON shakli rasmiy hujjatlardan (izohlarda URL).
- Play RTDN voided: egasi qoidasi bo'yicha har qanday refund/chargeback darhol huquqni oladi.
