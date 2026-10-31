# Release candidate (RC) 2026-10-31 — `rc/paid-1` (`paid/pro-premium`)

> **Holat:** faqat KOD va HUJJAT tayyorlandi. **GitHub Actions / CI, build (Gradle, Xcode, `flutter build`), deploy
> (`deploy_api`, `wrangler`), D1 migratsiyasi (remote), do‘kon konsoli (App Store Connect, Play Console), Apple/Google
> API chaqiruvi, App Review yuborish, production rollout — QILINMAGAN.** Pastda tekshirilmagan hamma narsa **NOT RUN** /
> **NOT VERIFIED** deb yozilgan. Ekspert tasdig‘i yoki ona tili tasdig‘i yozilmagan (hech kim tasdiqlamagan).
> Narx va mahsulot id’lari o‘zgartirilmagan: id’lar `lib/core/entitlements/billing_catalog.dart` da, narx — do‘kondan
> (`ProPricing`); do‘konda yaratilmaguncha **UNCONFIRMED** (D-77).
> Egasi qarori (2026-10-31): pullik rejalar bepul sinovi **30 kun** — `docs/DECISIONS.md` **D-80**. Bepul daraja o‘zgarmagan.

## 1. Nomzodda nima bor

Asos: `paid/pro-premium` (= `origin/rc/paid-1`, `f6af643`) + `origin/feat/toifa-everywhere` (`d962a5c`) birlashmasi
(`git merge --no-ff`, **konfliktsiz**, merge commit `0304fea`) + D-80 (30 kunlik sinov) commitlari.

| Ish | Qayerdan | Izoh |
|---|---|---|
| Ma’ruza slaydlari: **Auto / Manual** o‘tish (15/30/60 s, pauza, eslab qolinadi) | `feat/slides-auto` (`cb2a665`), `rc/paid-1` ga oldin birlashtirilgan | |
| **Baholash** so‘zlari hamma joyda: “toifa” so‘zi foydalanuvchi matnidan olib tashlandi (uz “kategoriya”, ru «категория», en “category”), savol “bank” so‘zi olib tashlandi; bo‘lim hamma til/davlat/rolga ochiq (D-79) | `feat/toifa-everywhere` (`ecfe87a`, `d962a5c`) | kod identifikatorlari (`toifa*`, `/learn/toifa`) o‘zgarmagan |
| **Pullik rejalar:** Free / Talaba Pro / Ustoz Pro / Mutaxassis Pro / Premium; server (`cloudflare/src/billing.ts`, `trial.ts`, `tiers.ts`, `attestation.ts`, mehmon xaridi), ilova (`lib/core/entitlements/*`, Obuna ekrani, to‘lov oynasi), Ustoz Pro (testlar, topshiriqlar, natijalar), D-78 katalog (faqat YANGI pullik funksiyalar; bugungi bepul funksiyalar bepul qoladi) | `paid/*` (D-76, D-77, D-78) | tarif qoidalari, narxlar, id’lar — o‘zgartirilmagan |
| Maxfiylik siyosati, foydalanish shartlari, do‘kon hujjatlari (obuna bandlari) | `docs/store/*`, `site/*` | sinov muddati 30 kunga yangilandi |
| **Bepul sinov = 30 kun** (D-80; D-76/D-77 dagi 7 kun almashtirildi) | shu RC | quyida va `DECISIONS.md` D-80 |
| `store_check` (CI rejimi, faqat o‘qish): obuna holati, USD narx nuqtalari, introductory/free-trial offer | `tool/store/store_check.py` | D-80: Apple `FREE_TRIAL ONE_MONTH`, Play `P1M`/`P30D` kutiladi, farq hisobotga yoziladi (hech narsa o‘zgartirilmaydi) |

### 1.1 D-80 (30 kunlik sinov) — nima o‘zgardi

- **Server:** `cloudflare/src/trial.ts` `TRIAL_DAYS = 30` (yagona manba; `trial_unavailable` mantig‘i, attestatsiya, bir marta
  qoidasi tegilmagan). `billing.ts` — faqat izoh: do‘kon sinov davri tugashi do‘kon kvitansiyasidan olinadi.
- **Server testlari:** `trial.test.ts`, `trial_antiabuse.test.ts`, `teachertests.test.ts` (`TRIAL_DAYS` orqali), `attestation.test.ts`,
  `billing.test.ts` (`days: 30`).
- **Ilova:** `ProTrialConfig.serverTrialDays = 30` (`pro_catalog.dart`); Obuna ekrani sarlavha/matni `{days}` o‘zgaruvchisi bilan.
  ARB uz/ru/en: `proPrivacyTrialNote`, `proTermsBody`, `proGateClosedBody` (+ `lib/l10n/gen/*` — faqat shu 3 kalit, qo‘lda
  mos o‘zgartirildi; `flutter gen-l10n` qayta yasash formatni buzgani uchun ishlatilmadi).
- **Hujjatlar:** D-80 (yangi), D-76/D-77/D-78 yozuvlari SUPERSEDED belgisi bilan, `docs/store/*` (TERMS_OF_USE, PRIVACY_POLICY,
  APP_STORE, PLAY_CONSOLE_UPLOAD), `site/terms`, `site/privacy` (`tool/site/build_site.py` bilan qayta yasaldi), PAID_* ro‘yxatlari,
  HELPER_PROMPT, PRO_TEST_ENVIRONMENT, PAID_SANDBOX_RUNBOOK, PRO_TRIAL_ABUSE_NOTES, GUARDS, DEVICE_TEST_CHECKLIST va boshqalar.
- **Qorovullar:** `paid_policy_d77_guard_test.dart` (c) endi “hamma joyda 30; eski 7 kunlik sinov matni faqat SUPERSEDED tarixda”,
  `pro_flag_default_guard_test.dart`, `paid_texts_consistency_test.dart`, `tool/site/check_site.py` (+ `test_guards.py`).
- **O‘zgartirilmagan (ataylab):** oflayn kesh chegarasi (`OFFLINE_MAX_MS` / `offlineTtl` = **7 kun**) — bu sinov uzunligi emas;
  serverdan yangilanmagan oflayn huquq 7 kundan keyin yopiladi — 30 kunlik davr bundan mustaqil. Yozuv saqlash muddati 730 kun.
  `storeIntroOffersAllowed = false`, `freeTrialDays = null`, `TRIAL_PLATFORMS` standarti (`android`) — qaror kerak (3-bo‘lim).

### 1.2 Tekshiruv natijalari (lokal, 2026-10-31)

| Tekshiruv | Natija |
|---|---|
| Merge `origin/feat/toifa-everywhere` | **PASS** — konfliktsiz |
| ARB apostrof tekshiruvi (`python3 -I tool/l10n/normalize_uz_apostrophes.py --check`) | **PASS** — o‘zgartiriladigan satr: 0 |
| `flutter analyze` | **PASS** — No issues found |
| `flutter test test/guards` | **PASS** — 193 test |
| Pro / to‘lov oynasi / Obuna / sinov / entitlement / billing / teacher_pro testlari (30 fayl) + `arb_parity_test` | **PASS** — 380 test |
| `paid_policy_d77_guard_test` + `paid_texts_consistency_test` (alohida, tuzatishdan keyin) | **PASS** |
| Cloudflare `npx tsc --noEmit` | **PASS** |
| Cloudflare `npm test` (vitest) | **PASS** — 29 fayl / 425 test |
| `tool/site`: `check_site.py` (5 sahifa), `--self-test`, unittest | **PASS** (unittest 9 test) |
| `tool/video` unittest | **PASS** — 7 test |
| `tool/ai/tests` unittest | **PASS** — 93 test |
| `tool/slides` unittest | **FAIL (1 ta)** — 89 testdan 88 PASS; `test_export_app_decks.Fresh.test_files_match_generator`: `assets/lectures/decks/d035|d036|d037|d039.uz.json` generator chiqishidan eskirgan. **`origin/feat/toifa-everywhere` da ham shunday** (D-80 dan oldin bor). Farq: fayllarda “kategoriyasi”, generator manbasi “toifasi” beradi — qaysi tomon to‘g‘ri ekani kontent qarori; qayta yasalmadi. `tool/run_guards.sh --quick` shu sabab to‘xtaydi. |
| To‘liq `flutter test` (2000+ test) | **NOT RUN** |
| Android/iOS build, Gradle/Xcode kompilyatsiya, `wrangler dev` | **NOT RUN** |
| `tool/store/store_check.py` (haqiqiy ASC/Play) | **NOT RUN** (sintaksis va hukm funksiyalari lokal tekshirilgan; Apple/Play maydon nomlari haqiqiy API bilan tekshirilmagan) |
| Haqiqiy do‘kon sandbox xaridi, qurilmada attestatsiya, qurilmada sinov | **NOT RUN** |

## 2. CI bayroqlari va secretlar: DO‘KON build va TESTER (preview) build

Manba: `.github/workflows/ci.yml` (`workflow_dispatch`). Aniq iboralar:

- `pro_preview` — “FAQAT testflight / play_internal: pullik qatlam (Talaba/Ustoz/Mutaxassis/Premium) interfeysini TESTERLARGA
  KO'RSATISH uchun LG_PRO_ENABLED + LG_ALL_FEATURES_OPEN yoqiladi (hamma imkoniyat ochiq, do'kon xaridi va billing serveri YO'Q).
  Do'kon/reliz buildlarida doim o'chiq.” (standart `false`)
- `pro_gating` — “FAQAT pro_preview bilan: hamma imkoniyatni OCHMASDAN (pullik funksiyalar obunasiz yopiq) sandbox xarid sinovi
  uchun build. Standart false = hamma ochiq.” (standart `false`)
- `billing_preview` — “FAQAT deploy_api: pullik server yo'llarini (admin Pro berish, ustoz testlari, huquqlar) YOQISH — Worker
  secretiga bayroq yoziladi. Do'kon tekshiruvi (Apple/Google kalitlari) yo'q: xarid 503, sinov fail-closed. Bepul ilova yo'llariga
  ta'sir qilmaydi.” (standart `false`)
- `env`: `LG_PRO_ENABLED` = `pro_preview` **VA** mode `testflight`/`play_internal` bo‘lsa `true`, aks holda `false`;
  `LG_ALL_FEATURES_OPEN` = `pro_preview` **VA** `!pro_gating` **VA** mode `testflight`/`play_internal` bo‘lsa `true`, aks holda `false`;
  `LG_PARTNER_ADS: 'false'` (hech bir buildda yoqilmaydi); `LG_FAKE_PURCHASES` CI’da umuman berilmaydi.

### 2.1 Build kombinatsiyalari

| Maqsad | `mode` | `pro_preview` | `pro_gating` | `LG_PRO_ENABLED` | `LG_ALL_FEATURES_OPEN` | Kimga |
|---|---|---|---|---|---|---|
| Bepul reliz (do‘konda tekshiruvda turgan versiya; push/PR/`build`/`deploy_*` ham) | har qanday | `false` | — | `false` | `false` | ommaga |
| **TESTER preview** (pullik interfeys ko‘rinadi, hamma ochiq, xarid yo‘q) | `testflight` / `play_internal` | `true` | `false` | `true` | **`true`** | faqat testerlar |
| **Sandbox xarid sinovi** (pullik funksiyalar obunasiz yopiq, haqiqiy do‘kon mahsulotlari) | `testflight` / `play_internal` | `true` | `true` | `true` | `false` | faqat testerlar |
| **Pullik DO‘KON (ommaviy) build** | shu CI’da alohida rejim YO‘Q | — | — | `true` bo‘lishi kerak | **`false` bo‘lishi shart** | ommaga |

Ommaviy pullik build uchun bayroqlar holati “sandbox xarid sinovi” qatori bilan bir xil (`pro_preview=true` + `pro_gating=true`);
CI’da bundan boshqa yo‘l yo‘q va input nomi “preview” — chalg‘itadi. Bu build `testflight`/`play_internal` orqali faqat ichki trekka
yuklanadi; production’ga o‘tkazish — do‘kon konsolida qo‘lda (4-bo‘lim, egasining alohida ruxsati). CI **o‘zgartirilmagan**
(alohida input kerakmi — egasi/rahbar qarori).

### 2.2 OMMAVIY do‘kon buildida O‘CHIQ bo‘lishi shart

| Bayroq / sozlama | Ommaviy do‘kon buildida |
|---|---|
| `LG_ALL_FEATURES_OPEN` (`pro_preview` bilan `pro_gating` **belgilanmasa** `true` bo‘ladi) | **O‘CHIQ** — `pro_gating=true` shart; aks holda pullik funksiyalar hammaga bepul ochiq |
| `LG_PARTNER_ADS` | **O‘CHIQ** (CI’da doim `'false'`) |
| `LG_FAKE_PURCHASES` | **O‘CHIQ / berilmaydi** (release build doim `false`, `kReleaseMode`) |
| Server `LG_BILLING_SANDBOX` (Worker secret) | production’da sandbox qabul qilishni **o‘chirish** istagi bor, lekin **NEEDS_OWNER_CHECK**: Apple App Review xaridni sandbox’da sinashi mumkin; `appleGet` (`billing.ts`) `LG_BILLING_SANDBOX` o‘rnatilmasa sandbox tranzaksiyani `purchase_not_found` bilan rad etadi. Qaror oldin `LG_BILLING_SANDBOX=true` (faqat review davrida) yoki alohida yo‘l — NOT VERIFIED |
| `TRIAL_PLATFORMS` | standart `android`; `android,ios` faqat Apple’ning yozma javobidan keyin (`docs/APPLE_REVIEW_QUESTION_DRAFT.md`, yuborilmagan) |
| `pro_preview` (tester buildi, hamma ochiq) | ommaviy trekka **chiqarilmaydi** |

### 2.3 DO‘KON build vs TESTER build: secretlar

| Maqsad | Kerak (faqat nomlar) |
|---|---|
| Android imzoli AAB (`play_internal`, do‘kon uchun ham) | `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`; Play yuklash: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` |
| iOS imzoli IPA / TestFlight (`testflight`) | `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8_BASE64`; ixtiyoriy `IOS_CERTIFICATE_P12_BASE64`, `IOS_CERTIFICATE_PASSWORD`, `IOS_TEAM_ID` |
| Server (`deploy_api`) | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `LG_SERVER_SECRET`, (`RESEND_API_KEY` yoki `BREVO_API_KEY`), `ADMIN_EMAILS` (yoki `LG_ADMIN_EMAILS`) |
| Pullik server (do‘kon tekshiruvi) | `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY`, `APPLE_DEVICECHECK_KEY_ID`, `APPLE_DEVICECHECK_TEAM_ID`, `APPLE_DEVICECHECK_PRIVATE_KEY`, `GOOGLE_PLAY_SERVICE_ACCOUNT`, `PLAY_INTEGRITY_SERVICE_ACCOUNT` (ixtiyoriy), `PLAY_INTEGRITY_CERT_SHA256`, `PLAY_RTDN_AUDIENCE`, `PLAY_RTDN_SERVICE_ACCOUNT` (yoki `PLAY_RTDN_TOKEN`), `TRIAL_PLATFORMS`, `LG_BILLING_SANDBOX` |
| Kirish (ixtiyoriy, o‘zgarmagan) | `APPLE_SIGNIN_*`, repo variables `LG_GOOGLE_CLIENT_ID`, `LG_GOOGLE_IOS_CLIENT_ID`, `LG_APPLE_SERVICE_ID`, `LG_APPLE_SIGNIN` |
| `store_check` (faqat o‘qish) | `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8_BASE64`, `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` |
| TESTER preview build (`pro_preview`, hamma ochiq) | qo‘shimcha do‘kon/billing secretlari **shart emas** (xarid va billing serveri yo‘q); imzo/yuklash secretlari yuqoridagidek |
| Sandbox xarid sinovi | to‘liq “Pullik server” to‘plami + do‘kon mahsulotlari + sandbox/License tester hisoblari |

Eslatma: ilovaning o‘zi `API_URL` ni `LG_API_URL` orqali oladi (sir emas). Qiymatlar hujjatga yozilmaydi.

## 3. Ochiq qaror: ikki sinov mexanizmi (stacking) — KOD O‘ZGARTIRILMAGAN

Egasi qarori D-80: sinov 30 kun; do‘konlarda **Apple Introductory Offer = 1 oy (8 mahsulotning hammasiga)** va **Google Play free
trial 30 kun / 1 oy** o‘rnatiladi. Kodda esa ilovaning O‘Z server sinovi bor (30 kun) va do‘kon takliflari hozircha o‘chirilgan:

| Platforma | Server sinovi (30 kun) | Do‘kon taklifi (1 oy) |
|---|---|---|
| Android | `TRIAL_PLATFORMS` standarti `android` — yoqiq (attestatsiya secretlari sozlansa) | Play’da taklif yaratilsa ham `storeIntroOffersAllowed = false` — ilova uni tanlamaydi |
| iOS | `TRIAL_PLATFORMS` da `ios` yo‘q — o‘chiq | Apple haqli foydalanuvchiga taklifni O‘ZI qo‘llaydi va ilova shartlarni ko‘rsatadi (`trial_policy.dart`) |

Natija: Android’da bepul davr = server sinovi, iOS’da = Apple 1 oylik taklifi. Agar ikkalasi yoqilsa (masalan `TRIAL_PLATFORMS=android,ios`
yoki `storeIntroOffersAllowed=true`), bitta foydalanuvchi ~2 oy bepul olishi mumkin. Qaysi platformada qaysi mexanizm asosiy — **egasi
qarori kerak** (ishlab chiquvchi o‘zgartirmadi).

**Do‘kon sinov sanasi:** Apple “1 oy” — KALENDAR oy (28–31 kun), server sinovi esa aniq 30 kun. Do‘kon taklifining tugash vaqti — do‘konning
o‘z kvitansiya sanasi (Apple `expiresDate`, Google Play `expiryTime`); ilova ham, server ham uni qayta HISOBLAMAYDI va 30 kunga
tenglashtirmaydi (`billing.ts`, `trial_policy.dart`). Server sinovi esa server soati bilan aniq 30 kun.

## 4. Haqiqiy relizni nima to‘sadi: tartibli ro‘yxat (kim qiladi)

Hammasi **NOT RUN** (hech biri bu yerda bajarilmagan).

### 4.1 Apple (egasi / yordamchi — App Store Connect)

1. **Guideline 4.3 (spam / o‘xshash ilova) bo‘yicha holat — NOMA’LUM.** Resolution Center’da joriy holatni egasi tekshiradi; hal
   bo‘lmaguncha pullik versiya yuborilmaydi. *(egasi)*
2. 8 ta obuna mahsuloti App Store Connect’da yaratilganmi — NOT VERIFIED (`store_check` ko‘rsatadi). *(egasi / yordamchi)*
3. Hammasi 8 mahsulot uchun: **review skrinshoti** (to‘lov oynasi: narx va davr xarid tugmasidan yuqorida) — hozircha YO‘Q. *(egasi / yordamchi)*
4. Hammasi 8 mahsulotga **Introductory Offer = Free Trial, 1 oy** o‘rnatish (D-80). *(egasi / yordamchi)*
5. Kalitlar → GitHub Secrets: `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY`, `APPLE_DEVICECHECK_KEY_ID`,
   `APPLE_DEVICECHECK_TEAM_ID`, `APPLE_DEVICECHECK_PRIVATE_KEY`. *(egasi)*
6. App Store Server Notifications V2 manzili, Sandbox tester akkaunti. *(egasi / yordamchi)*
7. Serverdan beriladigan kartasiz sinov bo‘yicha Apple’ga savol (`docs/APPLE_REVIEW_QUESTION_DRAFT.md`, 30 kunga yangilangan, YUBORILMAGAN) —
   iOS’da `TRIAL_PLATFORMS=ios` shu javobdan keyin. *(egasi)*

### 4.2 Google Play (egasi / yordamchi — Play Console)

1. **Production access** 2026-10-27 da so‘ralgan — **kutilmoqda** (holat NOT VERIFIED). Berilmaguncha production rollout yo‘q. *(egasi)*
2. 8 obuna (base plan) yaratilganmi — NOT VERIFIED. **Free trial offer 30 kun / 1 oy**ni Play Console’da o‘rnatish (D-80; mavjud davomiylik
   variantlari Console’da tekshiriladi). *(egasi / yordamchi)*
3. Service account (Financial data + Manage orders and subscriptions) → `GOOGLE_PLAY_SERVICE_ACCOUNT`; `PLAY_INTEGRITY_SERVICE_ACCOUNT` (ixtiyoriy),
   `PLAY_INTEGRITY_CERT_SHA256`; RTDN: `PLAY_RTDN_AUDIENCE`, `PLAY_RTDN_SERVICE_ACCOUNT` (yoki `PLAY_RTDN_TOKEN`); License testers. *(egasi)*

### 4.3 GitHub Secrets (faqat nomlar)

Apple: `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY`, `APPLE_DEVICECHECK_KEY_ID`, `APPLE_DEVICECHECK_TEAM_ID`,
`APPLE_DEVICECHECK_PRIVATE_KEY`. Google: `GOOGLE_PLAY_SERVICE_ACCOUNT`, `PLAY_INTEGRITY_SERVICE_ACCOUNT` (ixtiyoriy),
`PLAY_INTEGRITY_CERT_SHA256`, `PLAY_RTDN_AUDIENCE`, `PLAY_RTDN_SERVICE_ACCOUNT` (yoki `PLAY_RTDN_TOKEN`). Server sozlamalari: `TRIAL_PLATFORMS`,
`LG_BILLING_SANDBOX`. Mavjud (oldindan): `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8_BASE64`, `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`, `ANDROID_KEYSTORE_*`,
`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `LG_SERVER_SECRET`, `ADMIN_EMAILS`. Qaysilari qo‘yilgani — NOT VERIFIED.

### 4.4 Keyin (tartib bilan; har biri egasining alohida ruxsatini talab qiladi — 5-bo‘lim)

1. `store_check` (faqat o‘qish): mahsulotlar, USD narx nuqtalari, **D-80 sinov (Apple 1 oy, Play 30 kun)** hisobotini ko‘rish.
2. **Bitta** `deploy_api` (+ `billing_preview`) — Cloudflare Worker, migratsiyalar `0014…0020`, secretlar. Oldin zaxira nusxa
   (`docs/PAID_BACKEND_DEPLOY_CHECKLIST.md`).
3. **Bitta** `pro_gating` test build (`pro_preview` + `pro_gating`; `play_internal` va `testflight` — har biri bir marta).
4. Sandbox xarid sinovlari (`docs/PAID_SANDBOX_RUNBOOK.md` §2: sotib olish, tiklash, bekor qilish, muddat tugashi, mehmon/akkaunt, **30 kunlik
   sinov**, oflayn) — har qatorga PASS / FAIL / NOT RUN.
5. **Ekspert va ona tili tekshiruvi (gate):** ilmiy kontent — `docs/EXPERT_SIGNOFF_REGISTRY.md` (hammasi AWAITING_EXPERT; bu hujjat hech narsani
   tasdiqlamaydi); uz/ru ona tili — `docs/L10N_REVIEW_QUEUE.md`; huquqshunos ko‘rigi (Terms/Privacy — sinov muddati 30 kunga o‘zgargan, shuning
   uchun qayta ko‘rik kerak). *(egasi tayinlaydi; tasdiqni faqat tegishli shaxs beradi)*
6. Maxfiylik siyosati/shartlar sayti (`deploy_site`), App Privacy va Play Data Safety formalari obunaga mos.
7. Do‘konga yuborish (App Review) va production rollout.

Ochiq texnik masalalar: (a) 3-bo‘limdagi stacking qarori; (b) `LG_BILLING_SANDBOX` va Apple review sandbox’i (2.2); (c) `tool/slides` eskirgan
`d035/036/037/039.uz.json` (1.2); (d) CI’da ommaviy pullik build uchun alohida input yo‘q (2.1).

## 5. Egasining ALOHIDA ruxsati kerak bo‘lgan harakatlar

Quyidagilarning hech biri bu RC doirasida bajarilmagan va ruxsatsiz bajarilmaydi:

1. GitHub Actions ishga tushirish (har qanday `mode`), shu jumladan macOS runner’dagi iOS/TestFlight buildlari va `store_check`.
2. `deploy_api` (Cloudflare Worker, D1 migratsiyalar, secret yozish), `billing_preview`.
3. `play_internal` / `testflight` buildlari (`pro_preview`, `pro_gating`) — har biri bir marta.
4. `deploy_site` (labguide.nfcstore.uz).
5. Do‘kon konsoli harakatlari: App Store Connect / Play Console’da mahsulot, offer, narx, formalarni o‘zgartirish; Apple/Google’ga savol yuborish.
6. Production rollout va App Review’ga yuborish (Submit for Review).
7. `main` ga merge, PR ochish; `force-push`.
8. Bepul versiya (do‘konda tekshiruvda) ni o‘zgartirish, almashtirish yoki bekor qilish.
9. Ekspert / ona tili / huquqiy tasdiqni “berilgan” deb yozish — faqat tegishli shaxsning o‘zi beradi.
