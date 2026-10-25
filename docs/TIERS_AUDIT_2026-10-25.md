# Obuna rejalari auditi (Free / Pro / Premium) — 2026-10-25

Faqat o‘qish auditi. Kod o‘zgartirilmadi, hech narsa birlashtirilmadi, push/deploy/do‘kon API chaqiruvi yo‘q.
Tekshirilgan tarmoqlar (SHA):

| Tarmoq | HEAD | Holat |
|---|---|---|
| `fix/images-apparatus` (reliz qilinayotgan) = `img/tables` | `2e787e4` | `main` (`4b0f057`) + 51 commit (rasm/video/sxema). **Pro kodi yo‘q.** |
| `main` = `origin/main` | `4b0f057` | Pro yo‘q (D-58). |
| `pro/tiers-premium` = `origin/pro/tiers-premium` | `531ba02` | `main 4b0f057` + Pro ishi (D-71…D-76). Hamma bayroq O‘CHIQ. |
| `pro-next` (lokal) / `origin/pro-next` | `57a2d15` / `b532f04` | `pro/tiers-premium` ning ajdodi; sinov **30 kun** (D-74/75, eskirgan). |
| `pro-later` | `5fc26af` | Arxiv: D-58 dan oldingi Pro (`7141aff^`), do‘kon sinovi 7/14 kun (D-49, eskirgan). |

Eslatma: D-76 matnida “push qilinmadi” deyilgan, lekin `origin/pro/tiers-premium` = `531ba02` (masofada bor).

## 0. Qisqa xulosa (qaror uchun)

1. **Reliz tarmog‘ida (`fix/images-apparatus`) obuna yo‘q.** Hamma funksiya hamma uchun bepul; xarid plagini,
   to‘lov oynasi, `/profile/purchase`, `proEnabled`, `ProGatePolicy` — yo‘q. Paywall’ga hech qanday yo‘l yo‘q.
   Qorovul: `test/guards/product_policy_guard_test.dart:47-114` (“D-58: ilovada Pro / to‘lov / obuna yo‘q”).
2. **Pro/Premium kodi faqat `pro/tiers-premium` da** va u yerda ham standart buildda HECH NARSA yopilmaydi:
   `BuildFlags.proEnabled` = `LG_PRO_ENABLED` (standart `false`, `lib/core/build_flags.dart:19,41`), CI bu bayroqni
   hech qayerda bermaydi (`.github/workflows/*.yml` da `LG_PRO_ENABLED` yo‘q); `ProGatePolicy.gated = {}`
   (`lib/core/entitlements/pro_catalog.dart:150`); server `LG_BILLING_ENABLED` o‘chiq → `/v1/billing/*`, `/v1/pro/*` 404.
3. **Bepul sinov: kodda 7 kun, 30 kun EMAS.** `cloudflare/src/trial.ts:33 TRIAL_DAYS = 7`,
   `pro_catalog.dart:131 serverTrialDays = 7`, D-76 (egasi qarori, 2026-10-24). 30 kun faqat eskirgan `pro-next`
   (`trial.ts:31`, `pro_catalog.dart:126`) va SUPERSEDED D-74/D-75 da. Sinov **hech bir real buildda ishlamaydi**:
   qurilma attestatsiyasi (Play Integrity / App Attest) yozilmagan — server `UnconfiguredVerifier` → 503
   (`trial.ts:94`), ilova `UnconfiguredDeviceAttestor` → tugma ko‘rinmaydi (`entitlement_service.dart:342`).
4. **Talaba rejasini ($1.49/$9.99) sotib bo‘lmaydi:** `studentVerified=false` (`entitlement_service.dart:149`),
   `BillingCatalog.offered` talaba mahsulotini yashiradi (`billing_catalog.dart:156`), talaba tasdig‘i yozilmagan.
5. **Pro tarmog‘ining o‘z sayt qorovuli qizil:** `site/privacy` §10a “Pro/obuna/подписка” so‘zlari va
   `PRIVACY_POLICY.md` bilan mos emasligi — `tool/site/check_site.py` 13 xato (bu auditda ishga tushirildi).
6. **Testlar (bu auditda ishga tushirildi, `pro/tiers-premium@531ba02`, nusxada / `wt-pro-next` da o‘zgartirishsiz):**
   server `vitest` — **24 fayl, 332 test PASS** (billing/trial/tiers/progrants/0018/x509/guards: 8 fayl, 111 PASS);
   Flutter Pro testlari — **12 fayl, 158 test PASS** (`entitlements_test`, `plan_matrix_test`,
   `trial_entitlement_test`, `pro_readiness_d75_test`, `admin_grant_entitlement_test`, `pro_flag_off_test`,
   `lab_gate_test`, `subscription_screen_test`, `entitlements_flow_test`, `admin_pro_grant_test`,
   `pro_flag_default_guard_test`, `product_policy_guard_test`). Hammasi **soxta do‘kon / soxta server / soxta
   attestatsiya** bilan; haqiqiy App Store / Google Play bilan hech narsa sinalmagan → **NOT VERIFIED**.
   Reliz tarmog‘i testlari bu auditda qayta ishga tushirilmadi (NOT RUN).

Holat belgilari: **WORKS_AND_TESTED** — kod bor va avtomatik test o‘tadi (Pro uchun: faqat soxta do‘kon/server bilan;
bu “do‘konda ishlaydi” degani EMAS); **CODE_ONLY_UNTESTED** — kod bor, shu yo‘l testlanmagan yoki real muhitda ishlay
olmaydi; **PLANNED_NOT_WRITTEN** — reja/hujjatda bor, kod yo‘q; **NOT_IN_THIS_BRANCH** — bu tarmoqda yo‘q.

## 1. Funksiya × reja jadvali

Reliz tarmog‘ida (`fix/images-apparatus`) barcha qatorlar: Free = ochiq (WORKS_AND_TESTED — funksiya testlari mavjud,
masalan `exam_flow_test.dart`, `differential_flow_test.dart`, `qc_flow_test.dart`, `classes_flow_test.dart`,
`lecture_auto_test.dart`; bu auditda qayta ishga tushirilmagan), pullik ustunlar = **NOT_IN_THIS_BRANCH**.

Quyidagi jadval — `pro/tiers-premium@531ba02`. “✓” = reja ochadi, “✗” = ochmaydi. **Hozir hamma narsa Free’da
ochiq** (`gated` bo‘sh), shuning uchun pullik reja amalda hech narsa qo‘shmaydi; ✓/✗ faqat egasi `gated` ni
to‘ldirgandagi xatti-harakat. Matritsa: `lib/core/entitlements/plan_matrix.dart:15-24` ↔ `cloudflare/src/tiers.ts:42`
(paritet testi `test/unit/plan_matrix_test.dart`).

| Funksiya (`Feature`) | Free (bugun) | Talaba | Ustoz | Mutaxassis | Premium | Status / dalil |
|---|---|---|---|---|---|---|
| Qo‘llanmalar, kunlik savollar, xatolar (bepul toifa) | ochiq | ✓ | ✓ | ✓ | ✓ | WORKS_AND_TESTED (`feature.dart:92-98` capability=null; `entitlements_test.dart:166`) |
| “Bepul — kunlik 5 savol” cheklovi (D-53) | — | — | — | — | — | **PLANNED_NOT_WRITTEN** (D-71: `main` da yo‘q) |
| Cheksiz tarix (`unlimitedHistory`) | ochiq | ✓ | ✓ | ✓ | ✓ | WORKS_AND_TESTED (`exam_screens.dart:292`; `entitlements_flow_test.dart:112`) |
| Cheksiz savollar (`unlimitedQuestions`) | ochiq | ✓ | ✓ | ✓ | ✓ | WORKS_AND_TESTED (`learn_screens.dart:335`; `entitlements_flow_test.dart:145`) |
| Imtihon simulyatsiyasi (`examSimulation`) | ochiq | ✓ | ✓ | ✓ | ✓ | WORKS_AND_TESTED (`exam_screens.dart:99`; `entitlements_flow_test.dart:131`) |
| To‘liq toifa banki (`fullToifaBank`) | ochiq | ✓ | ✓ | ✓ | ✓ | CODE_ONLY_UNTESTED UI (`toifa_screens.dart:554`); `can()` unit-test `entitlements_test.dart:230` |
| Zaif mavzular (`weakTopics`) | ochiq | ✓ | ✓ | ✓ | ✓ | CODE_ONLY_UNTESTED UI (`exam_screens.dart:686`) |
| Atlas mashqi (`atlasPractice`) | ochiq | ✓ | ✓ | ✓ | ✓ | WORKS_AND_TESTED (`microscopy_quiz_screen.dart:62`; `entitlements_flow_test.dart:145`) |
| Ustoz: guruh ochish (`groups`) | ochiq | ✗ | ✓ | ✗ | ✓ | CODE_ONLY_UNTESTED UI (`classes_screens.dart:280`). **Faqat ilovada**: server `/v1/groups` `requireTier` ga ulanmagan (`tiers.ts:2,11`) |
| Ustoz: topshiriqlar (`assignments`) | ochiq | ✗ | ✓ | ✗ | ✓ | **PLANNED_NOT_WRITTEN** — `requireFeature` chaqiruvi yo‘q (faqat `feature.dart:123`, `purchase_screen.dart:225`) |
| Ustoz: avto-taqdimot (`autoPresentation`) | ochiq | ✗ | ✓ | ✗ | ✓ | CODE_ONLY_UNTESTED UI (`auto_deck_screens.dart:393`) |
| Lab: leykoformula sanash (`leukocyteCounter`) | ochiq | ✗ | ✗ | ✓ | ✓ | WORKS_AND_TESTED (`differential_screens.dart:830-834`; `lab_gate_test.dart:97,115,165`) |
| Lab: mutlaq sonlar (`absoluteCounts`) | ochiq | ✗ | ✗ | ✓ | ✓ | CODE_ONLY_UNTESTED UI (`differential_screens.dart:182-185`) |
| Lab: baholash (`leukocyteEvaluation`) | ochiq | ✗ | ✗ | ✓ | ✓ | WORKS_AND_TESTED (`router.dart:939`; `lab_gate_test.dart:130`) |
| Lab bo‘limlari: sitologiya, spermogramma, qon guruhi, gistologiya, siydik, qon morfologiyasi, koprologiya (`labSections`) | ochiq | ✗ | ✗ | ✓ | ✓ | WORKS_AND_TESTED (`router.dart:525-731` `labGate`; `lab_gate_test.dart:130` `/lab/cytology/cells`) |
| Koagulogramma (`coagulogram`) | ochiq | ✗ | ✗ | ✓ | ✓ | WORKS_AND_TESTED (`router.dart:745`; `lab_gate_test.dart:130`) |
| Apparatlar katalogi (`labInstruments`) | ochiq | ✗ | ✗ | ✓ | ✓ | CODE_ONLY_UNTESTED UI (`instrument_screens.dart:163,177,233,276`) |
| Yo‘nalish kartalari (`labDirections`) | ochiq | ✗ | ✗ | ✓ | ✓ | CODE_ONLY_UNTESTED UI (`lab_direction_screens.dart:78`) |
| Kalibrlash (`calibration`) | ochiq | ✗ | ✗ | ✓ | ✓ | WORKS_AND_TESTED (`router.dart:502`; `lab_gate_test.dart:130`) |
| QC (`qualityControl`) | ochiq | ✗ | ✗ | ✓ | ✓ | WORKS_AND_TESTED (`qc_screens.dart:240,312`; `lab_gate_test.dart:130,165`) |
| Lab kalkulyatorlari (`labCalculators`) | ochiq | ✗ | ✗ | ✓ | ✓ | WORKS_AND_TESTED (`tool_screens.dart:56-91`; `lab_gate_test.dart:130`) |
| Lab kirish sahifalari, preanalitika, rasm mualliflari | ochiq | ✓ | ✓ | ✓ | ✓ | WORKS_AND_TESTED (D-76 §3; `lab_gate_test.dart:69,130` credits ochiq) |
| “Qanday foydalaniladi?” videolari, sxema qismlari paneli | ochiq (relizda) | — | — | — | — | NOT_IN_THIS_BRANCH (`pro/tiers-premium` da yo‘q; faqat `fix/images-apparatus`) |

Lab rejasi faqat **REJA**: `ProGatePolicy.plannedLabGate` (`pro_catalog.dart:159-170`) — FAOL EMAS. Ustoz va Lab
ajratilishi (“Mutaxassis ustoz panelini olmaydi”, “Ustoz Lab’ni olmaydi”) serverda `tiers.test.ts:100-176` da,
ilovada `entitlements_test.dart:246` va `lab_gate_test.dart:165` da tekshirilgan.

Narxlar (USD, faqat MA’LUMOT; ekranda do‘kon narxi ko‘rsatiladi) — `pro_catalog.dart:70-99`:

| Reja | Oylik | Yillik | App Store id (kanonik) | Play obuna + base plan |
|---|---|---|---|---|
| Talaba | 1.49 | 9.99 | `uz.labguide.student.monthly/.yearly` | `uz.labguide.student` + `monthly`/`yearly` |
| Ustoz | 2.49 | 24.99 | `uz.labguide.teacher.monthly/.yearly` | `uz.labguide.teacher` |
| Mutaxassis | 3.49 | 34.99 | `uz.labguide.specialist.monthly/.yearly` | `uz.labguide.specialist` |
| Premium | 4.99 | 49.99 | `uz.labguide.premium.monthly/.yearly` | `uz.labguide.premium` |

Server ro‘yxati `cloudflare/src/billing.ts:60,87` (paritet: `entitlements_test.dart:626`). Do‘konlarda mahsulot
**yaratilmagan** (D-73) — NOT VERIFIED.

## 2. Egasining 11 savoliga javoblar

**1. Free’da nima ishlaydi?** Reliz tarmog‘ida — hammasi (o‘qish, testlar, imtihon, toifa, atlas, butun Lab,
kalkulyatorlar, ustoz paneli: guruh/topshiriq/ma’ruza, hamjamiyat, videolar). Cheklov yo‘q (D-58,
`product_policy_guard_test.dart:47`). `pro/tiers-premium` standart buildida ham hammasi ochiq (`gated={}`,
`pro_flag_off_test.dart`, `lab_gate_test.dart:69`). “Kunlik 5 savol” cheklovi PLANNED_NOT_WRITTEN.

**2. Pro nimani ochadi?** Relizda — Pro yo‘q (NOT_IN_THIS_BRANCH). `pro/tiers-premium` da “Pro” = uch reja:
Talaba (`learner`), Ustoz (`learner`+`teacher_panel`), Mutaxassis (`learner`+`lab`) — `plan_matrix.dart:15-24`.
Lekin `gated` bo‘sh, shuning uchun **bugun hech narsani qo‘shimcha ochmaydi** (hammasi allaqachon bepul).
Talaba rejasi sotuvda ko‘rinmaydi (`billing_catalog.dart:156`, talaba tasdig‘i yo‘q).

**3. Premium Pro’dan nima qo‘shadi?** Premium = `learner`+`teacher_panel`+`lab` (hammasi). Ustozdan farqi — Lab,
Mutaxassisdan farqi — ustoz paneli (`tiers.test.ts:157`, `entitlements_test.dart:230`). Bugun amalda farq yo‘q
(`gated` bo‘sh). Premium sinovi uchun ham ustoz (`teacher_accounts`), ham tasdiqlangan mutaxassis shart
(`trial.test.ts:346`) — deyarli hech kim olmaydi (D-76 ochiq qaror #2).

**4. Bepul sinov haqiqatan ishlaydimi?** **Yo‘q (real buildda).** Kod: server beradigan, kartasiz, **7 kun**, hamma
reja (`trial.ts:33`), bir hisob/kanonik email/qurilmaga bir marta (`trial.test.ts:144-229`), standart **faqat
Android** (`trial.ts:109` `TRIAL_PLATFORMS ?? 'android'`; iOS → `403 trial_not_available_on_platform`,
`trial.test.ts:437`), do‘kon kirish takliflari o‘chiq (`pro_catalog.dart:127,134`). Soxta attestatsiya bilan
testlar o‘tadi (WORKS_AND_TESTED, faqat soxta), lekin haqiqiy Play Integrity / App Attest tekshiruvchisi va
native plaginlar **PLANNED_NOT_WRITTEN** → server 503, ilovada tugma yo‘q.
**Farq:** egasi “30 kun” deb hisoblaydi; kod va testlar **7 kun** (D-76, 2026-10-24 egasi qarori bilan 30 → 7).
30 kun faqat `pro-next@57a2d15` (`trial.ts:31 TRIAL_DAYS = 30`, `pro_catalog.dart:126 serverTrialDays = 30`),
D-72/D-74/D-75 (SUPERSEDED) va `docs/PRO_PROPOSAL_D72.md` §D da qolgan. Reliz tarmog‘ining o‘zida ham
`docs/DECISIONS.md:1200-1203` (D-70, “TAKLIF”) hali “Oddiy $3.99, Ustoz $5.99, 30 kunlik bepul foydalanish” deb
yozadi — “30 kun” tasavvurining ehtimoliy manbai; D-76 u yerda yo‘q. “7 kun, bir telefonga bir marta, standart
faqat Android” — kodda xuddi shunday (D-75/D-76), lekin ishlamaydi (attestatsiya yo‘q).

**5. Sinov tugagach nima yopiladi / ochiq qoladi?** Sinov tugashi bilan huquq yo‘qoladi (`resolveAccess`,
`billing.ts:628-660`; `trial.test.ts:373` “7 kundan keyin huquq yo‘q, qayta sinov yo‘q”). Yopiladigani — faqat
`gated` dagi funksiyalar; bugun `gated` bo‘sh → **hech narsa yopilmaydi**. Bepul funksiyalar, ma’lumot va
saqlangan natijalar qoladi (`proSubEnded`, `billing_lifecycle.test.ts:247`; Pro davridagi natijalar ko‘rinadi
`entitlements_test.dart:317`). Boshlangan sanash/imtihon hech qachon to‘xtatilmaydi (`pro_gate.dart` `inProgress`,
`lab_gate_test.dart:115`).

**6. Obuna bo‘lganda funksiyalar ochiladimi?** Kodda — ha, darhol: xarid → server tekshiruvi → kesh → `can()`
(`entitlement_service.dart:638-690`; `entitlements_test.dart:449`, `entitlements_flow_test.dart` “hisob bilan
xarid (to‘rt reja)”). Faqat soxta do‘kon bilan (WORKS_AND_TESTED). Haqiqiy do‘kon bilan NOT VERIFIED; bugun
ochiladigan narsa yo‘q (`gated` bo‘sh); mehmon xarid qila olmaydi (`signInRequired`, `entitlement_service.dart:653-655`).

**7. Obuna tugasa / bekor qilinsa / pul qaytarilsa?** Bekor qilish — to‘langan davr oxirigacha huquq bor
(`billing.ts:443` `CANCELED → active`; `billing_lifecycle.test.ts:55`). Muddat tugashi — huquq yo‘q
(`entitlements_test.dart:383`). Grace — huquq bor; billing retry / on hold / pause — yo‘q
(`billing.ts:310-316,440-447`; `billing_lifecycle.test.ts:79,107`; `entitlements_test.dart:299`). Refund/revoke —
darhol `revoked` (`billing.ts:939,1006,1103`; `billing.test.ts:263,543`; `entitlements_test.dart:309`). Hammasi
soxta tekshiruvchi va o‘zimiz imzolagan ASSN fixturasi bilan (`test/apple_jws_fixture.ts`) — real NOT VERIFIED.

**8. Android / iOS integratsiyasi tayyormi?** Relizda — **yo‘q** (plagin yo‘q). `pro/tiers-premium` da:

| Qism | Holat | Dalil |
|---|---|---|
| `in_app_purchase ^3.3.1`, `_android ^0.5.4`, `_storekit ^0.4.14` | bor | `pubspec.yaml:58-61` |
| Android native kod / `BILLING` ruxsati | plagin manifest birlashtirishi orqali (repo’da qo‘lda yo‘q) | `android/` da `BILLING` yo‘q; D-71 ogohlantirish |
| iOS: In-App Purchase capability | maxsus entitlement kerak emas; `Runner.entitlements` da faqat Apple Sign-In | NOT VERIFIED (Xcode/App ID) |
| Ilova adapteri (StoreKit 2 / Play base plan, `appAccountToken`/`obfuscatedAccountId`) | CODE (soxta bilan test) | `store_purchase_adapter.dart:311-404`; `entitlements_test.dart:469` |
| Mahsulot id’lari (8 ta + eski aliaslar) | bor | `billing_catalog.dart:32-50`; `billing.ts:60-93` |
| Server: App Store Server API, Play Developer API tekshiruvi | CODE (soxta bilan test) | `billing.ts:318,450`; kalitsiz `503` |
| Apple JWS x5c → Apple Root CA G3 pin | CODE | `x509.ts`; `x509.test.ts` |
| ASSN v2 webhook `/v1/billing/apple/notifications` | CODE | `app.ts:164`; `billing.test.ts:263` |
| Google RTDN `/v1/billing/google/rtdn` (Pub/Sub OIDC yoki token) | CODE | `app.ts:165`; `billing_lifecycle.test.ts:185` |
| D1 migratsiyalar 0014–0018 | faqat fayl, production’ga qo‘llanmagan | `cloudflare/migrations/0014…0018`; `migration_0018.test.ts` |
| Secretlar | YO‘Q (sozlanmagan) | `APPLE_IAP_KEY_ID/ISSUER_ID/PRIVATE_KEY`, `APPLE_BUNDLE_ID`, `APPLE_SUBSCRIPTION_GROUP_ID`, `APPLE_ROOT_CA_SHA256`, `GOOGLE_PLAY_SERVICE_ACCOUNT`, `GOOGLE_PLAY_PACKAGE`, `PLAY_RTDN_AUDIENCE`/`PLAY_RTDN_SERVICE_ACCOUNT` yoki `PLAY_RTDN_TOKEN`, `LG_BILLING_ENABLED`, `LG_BILLING_SANDBOX`, `TRIAL_PLATFORMS`, `LG_SERVER_SECRET` |
| CI: billing secretlari, `LG_PRO_ENABLED` | YO‘Q | `.github/workflows/ci.yml` |
| Do‘kon mahsulotlari (App Store Connect / Play Console) | YO‘Q | D-73, D-75 |
| Qurilma attestatsiyasi (sinov uchun) | PLANNED_NOT_WRITTEN | `trial.ts:94`, `device_attestor.dart:45` |
| Sandbox sinov matritsasi | PLANNED_NOT_WRITTEN | `docs/PRO_TEST_ENVIRONMENT.md` (reja) |

Xulosa: kod skeleti to‘liq va testlangan, lekin **ikkala do‘kon bilan ham bir marta ham haqiqiy xarid qilinmagan**.

**9. Oflayn holat qanday tekshiriladi?** Imzolangan kesh: HMAC-SHA256, kalit Keychain/Keystore’da
(`entitlement_cache.dart`, `flutter_secure_storage`), hisobga bog‘langan; muddat = min(7 kun, server
`offline_until`) (`entitlement_service.dart:526-532`, `billing.ts:790-796`); oflaynda uzaytirilmaydi; soat
`receivedAt` dan 10 daqiqadan ko‘p orqaga surilsa kesh bekor (`entitlement_service.dart:204,238-242`). Testlar:
`entitlements_test.dart:368,383,392,400,420,429,437`, `pro_readiness_d75_test.dart:53,81` — WORKS_AND_TESTED.
Cheklov: soatni “olish vaqti” va “7 kun” oralig‘iga qaytarish (monoton vaqt yo‘q) oflayn Pro’ni ≤ 7 kun ichida
cho‘zishi mumkin — kichik xavf. Grace period serverdan keladi. Bepul funksiyalar oflaynda hech qachon yopilmaydi.

**10. Restore Purchases bormi?** Kodda bor: `EntitlementService.restore()` (`entitlement_service.dart:644`), iOS’da
foydalanuvchi bosganda `sync()` (`store_purchase_adapter.dart:369-389`), tugma “Obuna” ekranida
(`subscription_screen.dart:320-332`, faqat `purchasesEnabled`) va to‘lov oynasida (`purchase_screen.dart:366`);
server `restore: true` (`billing_lifecycle.test.ts:163`). Testlar `entitlements_test.dart:524,534,538`,
`entitlements_flow_test.dart:284` — soxta bilan WORKS_AND_TESTED; haqiqiy do‘kon NOT VERIFIED. Mehmon tiklay
olmaydi (avval hisob, D-76) — App Store 5.1.1 xavfi (pastda). Relizda — NOT_IN_THIS_BRANCH.

**11. Matnlar mosmi?** Qisman. Mos: `pro*` kalitlari uch tilda 154 tadan, narx raqami ARB’da yo‘q
(`pro_flag_default_guard_test`); narxlar 1.49/9.99, 2.49/24.99, 3.49/34.99, 4.99/49.99 `pro_catalog.dart`,
D-76, `PRO_BILLING_PLAN.md:73-80` da bir xil; sinov “7” — ARB `proPrivacyTrialNote`, `site/privacy` §10a, D-76,
`APPLE_REVIEW_QUESTION_DRAFT.md` da bir xil. Nomuvofiqliklar:
- Ustoz reja nomi: to‘lov oynasi/“Obuna” — “Ustoz Pro / Pro для преподавателя / Teacher Pro”
  (`proPayTierTeacher`), admin va hujjatlar — “Ustoz / Преподаватель / Teacher” (`proPlanTeacher`).
- Eski “Pro” yorlig‘i (`proPayTierPro`, `purchase_screen.dart:77`) reja yo‘q holatda ko‘rinadi.
- To‘lov oynasidagi maxfiylik havolasi GitHub (`billing_catalog.dart:170`), qolgan joylarda
  `https://labguide.nfcstore.uz/privacy/` (`product_policy_guard_test` “maxfiylik siyosati havolasi”).
- `docs/store/APP_STORE.md:10` va `PLAY_CONSOLE_UPLOAD.md:18` — “to‘lov yo‘q (D-58)”; Pro tarmog‘i bu
  hujjatlarni yangilamagan. `docs/store/PRIVACY_POLICY.md` da obuna/sinov bo‘limi yo‘q, lekin `site/privacy`
  da §10a bor → `check_site.py`: 13 xato (shu jumladan “privacy/index.html eskirgan”).
- Reliz `docs/DECISIONS.md` D-70 (`:1200-1203`) — eski TAKLIF narxlar ($1.49/$3.99/$5.99, 30 kun); D-71…D-76 faqat
  Pro tarmog‘ida. Birlashtirishda D-70 ga “SUPERSEDED (D-73/D-76)” belgisi kerak.
- `PRO_READINESS_2026-10-24.md:17-18` faqat 3 reja (Premium yo‘q), T qatori “30 kunlik sinov” (sarlavhada D-76 izohi bor).
- Auto-renew oshkoralik matni bor (`proPayDisclosure`, `proPayManage`, `proPayTerms` EULA, `proSubPriceYearlyNote`).
- D-58 (relizda kuchda): Pro/to‘lov do‘kon buildidan olib tashlangan (Apple 2.5.19/2.1). D-76: to‘rt reja, `lab`,
  7 kun, mehmon xarid qilmaydi — faqat `pro/tiers-premium` da. `proEnabled`/`ProGatePolicy.gated`:
  `main`/`fix` — yo‘q; `pro-next`, `pro/tiers-premium` — `false` / `{}`; `pro-later` — `proEnabled` yo‘q (D-58 dan oldingi kod).

## 3. Joriy reliz nimani yetkazadi (`fix/images-apparatus@2e787e4`)

- Hech narsa yopilmagan, paywall ham, xarid tugmasi ham, “tez orada” ham yo‘q. `pubspec.yaml` da
  `in_app_purchase` yo‘q; `lib/core/entitlements/` yo‘q; marshrutlarda `/profile/purchase` yo‘q
  (`product_policy_guard_test.dart:69,90`). Server migratsiyalari 0013 gacha; `users.plan` ustuni
  (`0009_admin_console.sql:12`) bor, lekin hech bir endpoint uni bermaydi (D-58). Eski jadval `entitlements`
  (`0003_planned_ports.sql:83`) bo‘sh, faqat hisob o‘chirishda `DELETE` (`auth.ts:586`).
- Do‘kon hujjatlari bunga mos: “pullik obuna/to‘lov — bu versiyada yo‘q” (`docs/store/APP_STORE.md:10`).
- `site/` qorovuli o‘tadi (`check_site.py`: “xato yo‘q”, bu auditda ishga tushirildi).

## 4. Rollar (mehmon / talaba / ustoz / shifokor / laborant) va rejalar

- `AppRole { doctor, lab, student, teacher }` (`lib/features/settings/settings_controller.dart:13`) — faqat UI
  afzalligi (bosh sahifa, kutubxona, toifa ko‘rinishi), **hech qanday ruxsat yoki reja bermaydi**. Pro tarmog‘ida
  ham qaror faqat serverdagi huquqdan (`tiers.test.ts:100` — rol “teacher” bo‘lsa ham Talaba rejasi panelni ochmaydi).
- Mehmon: ilova to‘liq ishlaydi (server yo‘q). Pro tarmog‘ida mehmon xarid, tiklash, sinov ololmaydi (D-76 §5;
  `entitlements_flow_test.dart:295`, `trial.test.ts:109`).
- Ustoz paneli relizda bepul: server `teacher_accounts` (o‘z-o‘zini ro‘yxatdan o‘tkazish, D-42;
  `cloudflare/src/groups.ts:181`) → guruhlar, topshiriqlar, ma’ruza/avto-taqdimot, doska. Pro tarmog‘ida ham
  server tomonda bepul (`tiers.test.ts:236` “bepul ustoz paneli o‘zgarmadi”); `teacher_panel` faqat ilova
  tomonida yopilardi (va topshiriqlar umuman ulanmagan).
- Lab (laborant/shifokor): relizda butunlay bepul; Pro tarmog‘ida `lab` imkoniyati Mutaxassis/Premium uchun
  REJA (faol emas). Mutaxassis sinovi faqat hamjamiyatda tasdiqlangan mutaxassisga (`trial.test.ts:324-334`).

## 5. Do‘kon siyosati xavflari

| Xavf | Qoida | Holat |
|---|---|---|
| Raqamli obuna faqat IAP orqali, tashqi to‘lov havolasi yo‘q | Apple 3.1.1, Play Payments | Kodda faqat `in_app_purchase` (`product_policy_guard_test` “xarid plaginlari faqat in_app_purchase*”). OK |
| Server beradigan kartasiz sinov va admin bergan Pro iOS’da | Apple 3.1.1 | NOANIQ — `APPLE_REVIEW_QUESTION_DRAFT.md` (yuborilmagan); iOS sinovi standart yopiq |
| Mehmon xarid qila olmaydi | Apple 5.1.1 (hisobsiz sotib olish imkoni) | XAVF (D-76 ochiq qaror #4) |
| Auto-renew, narx, davr, EULA, maxfiylik havolasi | Apple 3.1.2, Play Subscriptions | Matn bor; maxfiylik havolasi GitHub’ga — nashr qilingan sayt URL’i bo‘lishi kerak; App Store metadata’da EULA/Privacy havolasi — NOT VERIFIED |
| Restore tugmasi | Apple 3.1.1 | Bor (soxta bilan test) |
| “Tez orada”/yopiq tugma | Apple 2.1 | Yo‘q (`gated` bo‘sh bo‘lsa paywall ko‘rinmaydi) |
| Sinov bilan ikki marta sinov (store intro + server) | Play/Apple sinov qoidalari | Do‘kon takliflari o‘chiq (`pro_catalog.dart:134`); Play’da free-trial offer yaratmaslik kerak (`PRO_TEST_ENVIRONMENT.md:59`) |
| Mavjud bepul funksiyalarni pullik qilish | Foydalanuvchi e’tirozi, D-71 | `gated` to‘ldirilsa bugungi bepul funksiyalar olib qo‘yiladi — grandfathering qarori yo‘q |
| Sinov xeshlarini 24 oy saqlash | Apple 5.1.1(v), GDPR-o‘xshash | Yurist tekshiruvi kerak (D-75 #3) |
| App Privacy / Data safety: Purchase History, Device ID | Apple/Play | Yangilanmagan (D-75 #9) |

## 6. Egasi uchun xulosa

Reliz (`fix/images-apparatus`) — xavfsiz: obuna yo‘q, hamma narsa bepul, qorovullar buni ushlab turadi.
Pro/Premium — yaxshi testlangan skelet, lekin: (a) yopiladigan funksiya ro‘yxati bo‘sh, (b) do‘kon mahsulotlari,
kalitlar, migratsiyalar yo‘q, (c) sinov 7 kun va attestatsiyasiz ishlamaydi, (d) Talaba rejasini sotib bo‘lmaydi,
(e) store/privacy hujjatlari va sayt qorovuli mos emas. Birlashtirish rejasi: `docs/TIERS_INTEGRATION_PLAN.md`;
to‘liq matritsa: `docs/TIERS_MATRIX.csv`.
