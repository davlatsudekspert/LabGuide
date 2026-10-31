> **FUTURE — not in the free app (D-58).** Kod `pro-next` tarmog'ida, bayroq ortida
> (`LG_PRO_ENABLED`, server `LG_BILLING_ENABLED`; D-71). `pro-later` — eski surat.
> **Narxlar va sinov muddatlari bu hujjatning eski qismlarida ESKIRGAN** (29 000 so'm/$4.99, Ustoz $6.99, 7/14 kun).
> **D-76 (2026-10-24, egasi):** to'rt reja (Premium qo'shildi), imkoniyatlar `learner`/`teacher_panel`/`lab`, Lab — Pro
> (REJA, faol emas), sinov 7 kun, mehmon xarid qilmaydi — `docs/DECISIONS.md` D-76.
> **SUPERSEDED (D-80, 2026-10-31, egasi qarori):** sinov uzunligi endi **30 kun** (hamma pullik reja; Bepul o‘zgarmagan).
> Hujjatdagi 7 / 14 kunlik sinov matni — tarix.
> Amaldagi narxlar (EGASI QARORI 2026-10-24, lekin YOQILMAGAN), to'rt daraja (D-76), yangi mahsulot id'lari va admin
> tomonidan Pro berish — **D-73** (§2 pastda yangilangan); ochiq qarorlar — D-73 §5. Bu hujjatdagi yopish ro'yxati (§1) `main` dagi
> bepul imkoniyatlar bilan ziddiyatda: hech narsa yopilmaydi.

# Pro obuna: huquqlar, xarid va server tekshiruvi

Holat (2026-10-17): **kod to‘liq tayyor — to‘lov o‘zi yoqiladi**, egasi do‘konlarda
mahsulotlarni yaratib, kalitlarni GitHub secretlariga qo‘yishi bilan (9-bo‘lim).
Shungacha ilova **to‘liq bepul/ochiq** ishlaydi va hech qanday xarid elementi
ko‘rsatmaydi (App Store 2.1 / 3.1.1).

Bog‘liq qarorlar: D-46 (paketlar), D-48 (narxlar), D-49 (sinov: Pro 7 kun,
Ustoz Pro 14 kun; talaba tasdig‘i), D-50 (talaba narxi), D-53 (bepul — kunlik 5 savol),
D-57 (Ustoz Pro yangi narxi: 39 000 so‘m/oy).
Tadqiqot: `docs/PAYMENTS_RESEARCH.md`.

## 0. Asosiy qoidalar

1. **To‘lov yoqilmagan bo‘lsa — hammasi ochiq.** `purchasesEnabled` =
   do‘kon javob berdi VA kamida bitta mahsulot yuklandi VA serverda shu do‘kon
   kaliti sozlangan (`GET /v1/billing/status`). `false` bo‘lsa: `can()` doim
   `true`, tarix cheklanmaydi, Profil’da “Obuna” qatori yo‘q, “Hali mavjud emas”,
   “E-bosqichda rejalashtirilgan”, “to‘lov yoqilmagan” yozuvlari yo‘q.
2. Boshlangan test, sanash yoki imtihon **hech qachon** to‘lov oynasi bilan
   to‘xtatilmaydi: `requireFeature()` faqat “Boshlash” bosilganda yoki
   natijadan keyin chaqiriladi.
3. Bepul tarixda oxirgi 3 natija ko‘rinadi; eskilari **o‘chirilmaydi**
   (“Yana N ta eski natija saqlangan”). Obuna tugasa Pro davrida saqlangan
   natijalar ko‘rinib turadi.
4. TestFlight/debug/CI buildlarda (`LG_ALL_FEATURES_OPEN=true`) hamma imkoniyat ochiq.
5. Narx **hech qachon** ilovaga qotirilmaydi — faqat do‘kondan (mahalliy valyutada).
6. Pro bitta lokal sozlamaga bog‘lanmaydi (kesh imzolangan, hisobga bog‘langan, muddatli).
7. Xarid uchun hisob **shart emas** (App Store 5.1.1): mehmon xaridi qurilmada
   ishlaydi, hisobga kirilganda serverga bog‘lanadi.

## 1. Paketlar va imkoniyatlar (D-46, D-53)

| Daraja | Imkoniyat (`Feature`) | Qayerda tekshiriladi |
|---|---|---|
| Bepul | kartalar, kalkulyatorlar, preanalitika, leykoformula, kunlik 5 ta savol (`dailyQuestions`), xatolar ustida ishlash (`mistakeReview`, cheklanmaydi) | — |
| Pro | `unlimitedQuestions` — mavzu bo‘yicha mashq, kartadan mini-test | `learn_screens.dart` (`_startGated`, analit testi) |
| Pro | `examSimulation` — vaqtli imtihon | `exam_screens.dart` `_start` |
| Pro | `fullToifaBank` — rasmiy toifa testi, mavzu/aralash mashq | `toifa_screens.dart` (test boshlash, mashq qatorlari) |
| Pro | `weakTopics` — natijada mavzular tahlili | `exam_screens.dart` (natija ekrani) |
| Pro | `atlasPractice` — mikroskopiya atlasi mashqi | `microscopy_quiz_screen.dart` |
| Pro | `unlimitedHistory` — to‘liq tarix | `ExamHistory` (`historyView`) |
| Ustoz Pro | Pro’dagi hammasi + `groups` (guruh ochish, baholar, hisobotlar) | `classes_screens.dart` (Guruh ochish) |
| Ustoz Pro | `assignments` — yangi topshiriq | `classes_screens.dart` |
| Ustoz Pro | `autoPresentation` — Ma’ruza rejimi | `lecture_screens.dart`, `classroom_screens.dart` |

- Guruhga **qo‘shilish** va ustoz bergan topshiriqni bajarish — bepul.
- PDF eksport ilovada **yo‘q** — `Feature` dan olib tashlandi va hech qayerda reklama qilinmaydi.
- Ikki ekranli rejim hali yo‘q — to‘lov oynasida ko‘rsatilmaydi (paydo bo‘lgach `Feature` ga qo‘shiladi).
- Toifa banki (`toifa_bank.dart` → `toifaAllows`) hali `EntitlementService` ga
  ulanmagan: bu fayl boshqa ish bilan parallel o‘zgarmoqda. Hozircha toifa testi va
  mashqi **boshlash tugmasida** `Feature.fullToifaBank` bilan tekshiriladi
  (bepul foydalanuvchiga xatolar mashqi ochiq). Keyin: `toifaAllows(f)` →
  `services.entitlements.can(...)`.

## 2. Mahsulot id’lari (yagona joy)

`lib/core/entitlements/billing_catalog.dart` (`BillingCatalog`) va server
`cloudflare/src/billing.ts` (`BILLING_PRODUCTS`) — bir xil ro‘yxat (unit test
ikkalasini solishtiradi). Eski taklif `labguide.pro.*` ishlatilmaydi.

| Mahsulot id | Daraja | Davr | Narx (USD, egasi qarori D-73; do‘konda qo‘yiladi) | Eski id (alias) |
|---|---|---|---|---|
| `uz.labguide.student.monthly` | Talaba | 1 oy | 1.49 | `uz.labguide.pro.student.monthly` |
| `uz.labguide.student.yearly` | Talaba | 1 yil | 9.99 | `uz.labguide.pro.student.yearly` |
| `uz.labguide.teacher.monthly` | Ustoz | 1 oy | 2.49 | `uz.labguide.teacherpro.monthly` |
| `uz.labguide.teacher.yearly` | Ustoz | 1 yil | 24.99 | `uz.labguide.teacherpro.yearly` |
| `uz.labguide.specialist.monthly` | Mutaxassis | 1 oy | 3.49 | `uz.labguide.pro.monthly` |
| `uz.labguide.specialist.yearly` | Mutaxassis | 1 yil | 34.99 | `uz.labguide.pro.yearly` |
| `uz.labguide.premium.monthly` | Premium (D-76) | 1 oy | 4.99 | — |
| `uz.labguide.premium.yearly` | Premium (D-76) | 1 yil | 49.99 | — |

Do‘konlarda hali HECH QANDAY mahsulot yaratilmagan: avval yaratishda faqat yuqoridagi yangi id’lar ishlatiladi; eski
id’lar faqat serverda/keshda alias. UZS narxlari (Play) va bepul sinov — ochiq qaror (D-73 §5); jadvalda sinov
ustuni yo‘q: `freeTrialDays = null`.

**Narx pog‘onalari:** Apple va Google narxni o‘z ro‘yxatidagi pog‘onalardan tanlatadi,
shuning uchun yuqoridagi dollar raqamlari yaxlitlanishi mumkin (ayniqsa UZS).
Do‘konda eng yaqin pog‘onani tanlang (Talaba < Ustoz < Mutaxassis < Premium tartibi saqlansin) va yakuniy
raqamni `DECISIONS.md` ga yozing. Ilova narxni kodda saqlamaydi — do‘kondan oladi.

**Talaba mahsulotlari** ilovada hozircha **ko‘rsatilmaydi**: talaba holatini
tasdiqlash (D-49) hali yo‘q (`EntitlementService.studentVerified = false`).
Do‘konda yaratib qo‘yish mumkin — server ularni taniydi; tasdiq qo‘shilganda
faqat shu bayroq yoqiladi.

## 3. Arxitektura (kodda)

| Joy | Nima |
|---|---|
| `lib/core/entitlements/feature.dart` | `ProTier` (free/pro/teacher) va `Feature` |
| `lib/core/entitlements/billing_catalog.dart` | id’lar, daraja, davr; EULA / Maxfiylik / “Obunani boshqarish” havolalari |
| `lib/core/entitlements/purchase_adapter.dart` | `PurchaseAdapter` (init, buy, restore, finish, updates), `StoreProduct` (narx/davr/sinov do‘kondan) |
| `lib/core/entitlements/store_purchase_adapter.dart` | `in_app_purchase` 3.3 (iOS — StoreKit 2, Android — Play Billing) |
| `lib/core/entitlements/entitlement_source.dart` | `CloudflareEntitlementSource` (`/v1/billing/*`), Supabase (to‘lovsiz), Unavailable |
| `lib/core/entitlements/entitlement_service.dart` | `can()`, `tier`, `purchasesEnabled`, `gatingActive`, `purchase()`, `restore()`, `start()` |
| `lib/features/profile/pro_gate.dart` | `requireFeature()` — boshlashdan oldin; yopiq bo‘lsa to‘lov oynasi |
| `lib/features/profile/profile_screens.dart` | `PurchaseScreen` (to‘lov oynasi, 3.1.2) |
| `cloudflare/src/billing.ts` | server tekshiruvi, saqlash, bildirishnomalar |
| `cloudflare/migrations/0007_billing.sql` | `entitlements` jadvali |

### Pro manbalari

1. **Build rejimi** — `allFeaturesOpen = kDebugMode || LG_ALL_FEATURES_OPEN`.
2. **Server** — `entitlements` jadvali (faqat server yozadi, do‘kon API’sidan).
3. **Oflayn kesh** — oxirgi server javobi: hisobga bog‘langan, HMAC bilan
   imzolangan (kalit Keychain/Keystore’da), 7 kun; soat 10 daqiqadan ko‘p
   orqaga surilsa Pro bermaydi.
4. **Qurilma (mehmon)** — StoreKit 2 / Play tasdiqlagan joriy tranzaksiya
   (faqat hisobsiz paytda; iOS’da StoreKit bergan muddat bilan).

### Ilova ochilganda (`EntitlementService.start`)

kesh → `GET /v1/billing/status` (shu do‘kon sozlanganmi) → do‘konga ulanish va
mahsulotlar → `GET /v1/billing/entitlements` → do‘kondagi joriy obunalarni
**jim** o‘qish (iOS: `Transaction.currentEntitlements`, Apple ID so‘ralmaydi;
Android: `queryPurchases`). Server bilmagan obuna bo‘lsa — hisobga bog‘lanadi.
`purchaseStream` ilova ochilishi bilan tinglanadi: yangilanish, Ask to Buy,
kutilgan to‘lov yakuni server tekshiruvidan **keyin** yakunlanadi (`finish`).

## 4. Xarid oqimi

```
Ilova (StoreKit 2 / Play Billing) ──xarid──▶ do'kon
   │ transactionId (iOS) / purchaseToken (Android)
   ▼
POST /v1/billing/verify (sessiya tokeni bilan)
   │ App Store Server API / Play Developer API (kalitlar faqat Worker secretlarida)
   ▼
entitlements (D1) ──▶ javob: {server_time, items[], owned_by_other}
   │
   ▼ shundan keyin ilova tranzaksiyani yakunlaydi (finish / acknowledge)

ASSN v2 / RTDN ──▶ /v1/billing/apple/notifications, /v1/billing/google/rtdn
   (tanadan faqat id olinadi, holat do'kon API'sidan qayta o'qiladi)
```

- **iOS:** `appAccountToken` = hisob UUID’i. Server: `GET /inApps/v1/transactions/{id}`
  va `GET /inApps/v1/subscriptions/{id}` (ES256 JWT, `aud=appstoreconnect-v1`,
  `bid=uz.labguide.app`), avval production, 404 (4040010) bo‘lsa sandbox.
  `signedTransactionInfo` dan `bundleId`, `productId`, `originalTransactionId`,
  `expiresDate`, `revocationDate`, `inAppOwnershipType`, `appAccountToken` tekshiriladi.
  Holat: 1 active, 2 expired, 3 billing_retry, 4 grace_period, 5 revoked.
- **Android:** `obfuscatedAccountId` = SHA-256(hisob id). Server:
  `purchases.subscriptionsv2.get`; `ACTIVE`/`CANCELED` (muddat tugaguncha) → active,
  `IN_GRACE_PERIOD` → grace_period, `ON_HOLD` → billing_retry, `PAUSED`, `EXPIRED`;
  `PENDING` → `409 purchase_pending` (ilova “to‘lov kutilmoqda” deydi).
  Tasdiqlanmagan xarid serverda **acknowledge** qilinadi (3 kun qoidasi); ilova
  ham `completePurchase` qiladi. Pro ↔ Ustoz Pro almashtirishda eski obuna
  `ChangeSubscriptionParam` bilan almashtiriladi; `linkedPurchaseToken` zanjiri
  bitta qatorda qoladi.
- **Bitta xarid — bitta hisob:** `(platform, original_transaction_id)` noyob;
  boshqa hisob uni ololmaydi (`owned_by_other`), hisob belgisi
  (appAccountToken / obfuscatedAccountId) boshqa hisobniki bo‘lsa ham.
- Eskiroq hodisa (`event_at`) yangisining ustidan yozilmaydi.
- Kalitlar bo‘lmasa: `503 not_configured` → ilova to‘lovni yoqmaydi.
- **Cheklov (halol):** JWS x5c sertifikat zanjiri Apple Root CA bilan
  tekshirilmaydi. Buning o‘rniga tranzaksiya har doim App Store Server API’dan
  (TLS + bizning ES256 kalit) so‘raladi; bildirishnoma tanasiga ishonilmaydi —
  undan faqat `transactionId` olinib, holat API’dan qayta o‘qiladi.

## 5. To‘lov oynasi (App Store 3.1.2)

`PurchaseScreen` (`/profile/purchase`, `?feature=` bilan boshlash tugmasidan):
- har reja: nom (Oylik/Yillik), **narx/davr do‘kondan** (“$4.99 / oy”),
  bepul sinov do‘kondagi kirish taklifidan (iOS — foydalanuvchi haqli bo‘lsa,
  Android — Play qaytargan offer) — “7 kun bepul, keyin $4.99 / oy”;
- nima kiradi (faqat ilovada bor imkoniyatlar), bepul nima qoladi;
- avtomatik yangilanish sharti (24 soat, to‘lov qachon olinadi, qayerda bekor qilinadi);
- **Xaridni tiklash**, **Obunani boshqarish yoki bekor qilish**
  (`apps.apple.com/account/subscriptions` / Play subscriptions),
  **Foydalanish shartlari (EULA)** — Apple standart EULA,
  **Maxfiylik siyosati** — `docs/store/PRIVACY_POLICY.md` havolasi;
- hisobni o‘chirish oynasida: “obuna hisob bilan bekor bo‘lmaydi” (5.1.1(v)).

Matnlar uz/ru/en (`pay*` kalitlari, ARB oxirida).

## 6. Server: endpointlar va jadval

| Yo‘l | Kim | Nima |
|---|---|---|
| `GET /v1/billing/status` | hamma | `{app_store: bool, play_store: bool}` — kalitlar bormi |
| `GET /v1/billing/entitlements` (= `/v1/entitlements`) | sessiya | `{server_time, items[], owned_by_other}` |
| `POST /v1/billing/verify` | sessiya | `{platform, product_id, token}` yoki `{platform, purchases:[…]}` (tiklash, ≤ 10) |
| `POST /v1/billing/apple/notifications` | Apple | ASSN v2 `{signedPayload}` |
| `POST /v1/billing/google/rtdn[?token=…]` | Pub/Sub | RTDN push; D-75: Pub/Sub OIDC (`PLAY_RTDN_AUDIENCE`) yoki `PLAY_RTDN_TOKEN` majburiy (hech biri — 503), `messageId` takrori tashlanadi |

`entitlements`: `platform`, `original_transaction_id`, `user_id`, `product_id`,
`status`, `started_at`, `expires_at`, `ownership`, `environment`, `latest_token`,
`event_at`, `updated_at`. Qator muddati o‘tsa ham o‘chmaydi (Pro davrlari);
hisob o‘chirilsa — o‘chadi (do‘kondagi obuna davom etadi).
Limitlar: verify — hisobga 30/soat, IP ga 120/soat.

## 7. Testlar

- `test/unit/entitlements_test.dart`: to‘lov yoqilmagan → hammasi ochiq (do‘kon
  yo‘q / mahsulot yo‘q / server sozlanmagan); D-53 bepul ro‘yxati; Pro va Ustoz Pro;
  grace/billing retry/refund; oflayn kesh; xarid → server → `finish`; server
  xatosida yakunlanmaydi; pending/cancel; tiklash; boshqa hisob; mehmon xaridi va
  hisobga bog‘lash; `start()`; do‘kon yuborgan tranzaksiya; katalog = server ro‘yxati;
  `CloudflareEntitlementSource` (status, verify tanasi, 503/409/502).
- `test/widget/entitlements_flow_test.dart`: to‘lovsiz do‘kon build (tarix to‘liq,
  Obuna qatori yo‘q, “Hali mavjud emas” yo‘q); to‘lov yoqilgach tarix 3 ta;
  imtihon boshlashdan oldin to‘lov oynasi; to‘lov oynasi (narx/sinov/shartlar/
  tiklash) va mehmon xaridi; ru; TestFlight.
- `cloudflare/test/billing.test.ts` (`npm test`): sozlanmagan → 503; App Store
  (production→sandbox, ES256 imzo tekshiriladi), boshqa hisob, appAccountToken,
  bundle/mahsulot xatolari, ASSN refund, eski hodisa, hisob o‘chirish; Play
  (acknowledge, pending, canceled, obfuscatedAccountId, RTDN token va voided).

## 8. CI va build rejimlari

| Build | `LG_ALL_FEATURES_OPEN` | Natija |
|---|---|---|
| `flutter run` (debug) | — | hamma ochiq |
| CI `build` / `testflight` / `play_internal` | `true` | hamma ochiq (do‘kon mahsulotlari bo‘lsa, to‘lov oynasi sandbox bilan sinaladi) |
| Do‘kon relizi (`mode: store`, keyin) | `false` | to‘lov yoqilgan bo‘lsa — haqiqiy huquqlar; yoqilmagan bo‘lsa — hammasi ochiq |

`deploy_api` rejimi Worker secretlarini stdin orqali qo‘yadi (bo‘sh bo‘lsa
o‘tkazib yuboradi, App Store uchtasi faqat birga).

## 9. EGASI NIMA QILADI (to‘lovni yoqish)

To‘lov quyidagilar tugagach **avtomatik** yoqiladi — ilovani qayta yozish shart emas.
Tartib muhim emas; oxirida bitta `deploy_api` ishga tushiriladi.

### 9.1 App Store Connect
1. **Agreements, Tax, and Banking** → **Paid Applications Agreement** ni qabul
   qiling; bank hisobi va soliq shakllarini (W-8BEN va h.k.) to‘ldiring. Holat
   “Active” bo‘lmaguncha mahsulotlar StoreKit’da yuklanmaydi.
2. **Apps → LabGuide → Monetization → Subscriptions** → **Subscription Group**
   yarating (masalan, “LabGuide Pro”). Oltita mahsulot **bitta guruhda** bo‘lsin
   (Pro ↔ Ustoz Pro almashtirish Apple tomonidan avtomatik).
   Darajalar (Level): 1 — Ustoz Pro (oylik va yillik; eng qimmat, D-57), 2 — Pro, 3 — Pro talaba.
3. 2-bo‘limdagi **6 ta auto-renewable subscription** — aynan shu Product ID’lar
   bilan. Har biri uchun: davr (1 Month / 1 Year), narx (bazaviy mamlakat — AQSh,
   O‘zbekiston uchun alohida narx nuqtasi, D-48/D-50), **Introductory Offer →
   Free Trial**: Pro va talaba — 7 kun, Ustoz Pro — 14 kun; lokalizatsiya
   (uz yo‘q bo‘lsa — en va ru: nom + tavsif); **Review screenshot** (to‘lov oynasi
   skrinshoti) va review eslatmasi.
4. Guruh lokalizatsiyasi (en, ru) va **Billing Grace Period** — 16 kun (tavsiya).
5. **App Store Server Notifications V2:** App Information → Production va
   Sandbox URL: `https://<worker-url>/v1/billing/apple/notifications`.
6. **In-App Purchase kaliti:** Users and Access → Integrations →
   **In-App Purchase** → Generate key → `.p8` faylni yuklab oling (bir marta!).
   GitHub → Settings → Secrets and variables → Actions:
   - `APPLE_IAP_KEY_ID` — kalit ID (10 belgi),
   - `APPLE_IAP_ISSUER_ID` — Issuer ID (shu sahifa tepasida, UUID),
   - `APPLE_IAP_PRIVATE_KEY` — `.p8` fayl matni to‘liq (`-----BEGIN PRIVATE KEY-----`…).
   Uchalasi birga bo‘lmasa CI ularni o‘rnatmaydi.
7. Ilova versiyasini review’ga yuborganda mahsulotlarni ham shu versiyaga
   biriktiring (birinchi obunalar ilova bilan birga ko‘rib chiqiladi). Review
   eslatmasiga: “Subscriptions: Profile → Subscription and restore; no account
   required to purchase.”

### 9.2 Google Play Console
1. **Payments profile** (merchant) faol, “Uzbekistan tax info” to‘ldirilgan
   (`PAYMENTS_RESEARCH.md` 5-bo‘lim).
2. **Monetize → Products → Subscriptions:** 6 ta subscription — aynan shu
   Product ID’lar bilan; har birida bitta **auto-renewing base plan**
   (oylik — P1M, yillik — P1Y), narxlar (O‘zbekiston — UZS). Bepul sinov uchun
   base plan’ga **offer** qo‘shing: eligibility “New customer acquisition — never
   had this subscription”, phase **Free trial** 7 kun (Pro, talaba) / 14 kun
   (Ustoz Pro). Boshqa (chegirmali) offer qo‘shmang — ilova ularni ko‘rsatmaydi.
   Base plan va offer’ni **Activate** qiling.
3. **Service account (Play Developer API):** Google Cloud Console (Play Console
   bog‘langan loyiha) → IAM → Service accounts → yangi hisob → Keys → JSON.
   Play Console → **Users and permissions** → shu emailni taklif qiling, ruxsatlar:
   “View financial data, orders, and cancellation survey responses” va
   “Manage orders and subscriptions” (faqat LabGuide ilovasi uchun).
   “Google Play Android Developer API” loyihada yoqilgan bo‘lsin.
   GitHub secret: `GOOGLE_PLAY_BILLING_SERVICE_ACCOUNT_JSON` — JSON fayl matni
   (yuklash uchun ishlatilayotgan `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` dan **alohida**,
   kam vakolatli hisob tavsiya etiladi).
4. **RTDN:** Google Cloud → Pub/Sub → topic (masalan, `play-billing`), topic’ga
   `google-play-developer-notifications@system.gserviceaccount.com` ga
   **Pub/Sub Publisher** roli; Play Console → Monetization setup → Real-time
   developer notifications → shu topic. Topic’da **Push subscription**:
   endpoint `https://<worker-url>/v1/billing/google/rtdn?token=<tasodifiy-satr>`.
   Shu `<tasodifiy-satr>` ni (`openssl rand -hex 24`) GitHub secret
   `PLAY_RTDN_TOKEN` ga qo‘ying.
5. **License testers** (Setup → License testing) — sinov xaridlari pulsiz.

### 9.3 Yoqish va tekshirish
1. GitHub → Actions → CI → Run workflow → `mode: deploy_api`. Natijada
   “secret … o‘rnatildi” qatorlari va `0007_billing.sql` migratsiyasi.
2. Tekshiruv: `curl https://<worker-url>/v1/billing/status` →
   `{"app_store":true,"play_store":true}`.
3. TestFlight / ichki test (sandbox Apple ID, license tester) bilan:
   xarid, sinov, tiklash, boshqa hisob, bekor qilish, grace, refund.
4. Faqat shundan keyin do‘kon relizi `LG_ALL_FEATURES_OPEN=false` bilan.
   Mahsulotlar yoki kalitlar bo‘lmasa ham reliz xavfsiz: ilova hammasini ochiq
   qoldiradi va xarid elementini ko‘rsatmaydi.

## 10. Ma’lum cheklovlar

- JWS x5c zanjiri Apple Root CA bilan tekshirilmaydi (4-bo‘lim — o‘rniga API’dan
  qayta so‘rash).
- Oflaynda yoki server javob bermasa (`/v1/billing/status`) to‘lov yoqilmaydi —
  bepul foydalanuvchi shu paytda hamma imkoniyatni ko‘radi (ataylab yumshoq:
  “yopiq tugma” ko‘rsatgandan ko‘ra ochiq qoldirish xavfsizroq).
- Mehmon xaridi qurilmada faqat shu sessiyada (ilova ochilganda jim tiklanadi);
  Android’da muddat qurilmada ma’lum emas — do‘kon joriy deb bergan obuna amalda.
- Talaba tasdig‘i yo‘q — talaba mahsulotlari ko‘rsatilmaydi.
- `toifaAllows` hali `EntitlementService` ga ulanmagan (1-bo‘lim).
- `ExamController.historyLimit = 50` — 50 tadan eski natija qurilmadan o‘chadi
  (“eski natijalar o‘chirilmaydi” qoidasiga zid; imtihon bo‘limi bilan kelishib).
- Supabase backend’da (`verify-purchase` hali 503) to‘lov yoqilmaydi; ishlaydigan
  server — Cloudflare Worker.

## 11. Admin tomonidan Pro berish (D-73) — server bilan bog‘lanish
`GET /v1/billing/entitlements` javobiga (faqat `LG_BILLING_ENABLED=true`) admin bergan huquq alohida qator bo‘lib
qo‘shiladi: `source: admin_grant`, `platform: admin_grant`, `product_id: admin_grant.<daraja>`, `plan`, `ownership:
granted`; javob ildizida `resolved: {source, plan, expires_at}` — hal qilingan (yuqori daraja, teng bo‘lsa uzoqroq muddat,
to‘liq tenglikda do‘kon). Do‘kon obunasi hech qachon bosib o‘tilmaydi. Berish/bekor qilish yo‘llari, xavfsizlik va jurnal:
D-73 §3 va `docs/ADMIN_PANEL_GUIDE.md` §8. Migratsiya `0015_pro_grants.sql` — hali qo‘llanmagan.

## 12. Reja ↔ panel ajratish va bepul sinov (D-74) — HAMMASI O‘CHIQ
- Daraja × imkoniyat matritsasi: `cloudflare/src/tiers.ts` (`TIER_CAPABILITIES`, `requireTier`), ilova nusxasi
  `lib/core/entitlements/plan_matrix.dart`. **D-76:** Talaba — `learner`; Ustoz — `learner`, `teacher_panel`; Mutaxassis —
  `learner`, `lab` (ustoz panelisiz); Premium — uchalasi. (D-74 dagi “Mutaxassis — uchalasi” bekor.)
  Qaror faqat serverdagi huquqdan (rol emas). Inert yo‘llar: `GET /v1/pro/access`, `GET /v1/pro/check/:capability`.
- Bepul sinov (bir telefonga bir marta): `POST /v1/billing/trial/challenge`, `POST /v1/billing/trial/start`;
  `entitlements` javobida `source: trial`, `platform: trial`, `product_id: trial.<daraja>`, ildizda `trial_used`.
  Attestatsiya sozlanmaguncha 503. Jadval `0016_pro_trials.sql` (qo‘llanmagan). Tafsilot va xavflar:
  `docs/PRO_TRIAL_ABUSE_NOTES.md`, D-74.
- Ilova: Profil → **Obuna** (`/profile/subscription`, faqat `BuildFlags.proEnabled`): rejalar, USD narxlar (katalog),
  holat, sinov qoidasi, tiklash; to‘lov oynasi (`/profile/purchase`) shu ekrandan.
- Eslatma: 9-bo‘limdagi 7/14 kunlik do‘kon sinovi ESKIRGAN (D-71/D-73). Server sinovi muddati — **7 kun, hamma reja
  uchun (D-76)** — D-80 (2026-10-31) bilan **30 kun**ga almashtirildi; D-74/D-75 dagi 30 kun D-76 da bekor qilingan edi.

## D-75 yangilanishi
Do'kon tekshiruvchilari injeksiya qilinadi, Apple JWS imzosi tekshiriladi, sandbox faqat `LG_BILLING_SANDBOX=true`, Play'da
obuna + base plan (`monthly`/`yearly`) kanonik id'ga moslanadi, sinov `TRIAL_PLATFORMS` (standart `android`).
Batafsil: `docs/DECISIONS.md` D-75, `docs/PRO_READINESS_2026-10-24.md`, `docs/PRO_TEST_ENVIRONMENT.md`.

## D-76 yangilanishi
To'rt reja (Talaba 1.49/9.99, Ustoz 2.49/24.99, Mutaxassis 3.49/34.99, Premium 4.99/49.99 USD — egasi narxlari, yagona
manba `pro_catalog.dart`), `lab` imkoniyati (Mutaxassis va Premium), Lab funksiyalari `ProGatePolicy.plannedLabGate` da
(faol EMAS; `gated` bo'sh), server sinovi 7 kun, mehmon xarid/tiklash/sinov olmaydi (avval hisobga kirish), migratsiya
`0018_premium_tier.sql` (faqat fayl). App Store: 8 mahsulot; Play: 4 obuna × 2 base plan. Batafsil: `docs/DECISIONS.md` D-76.
