# Pro obuna: huquqlar qatlami va xarid tekshiruvi rejasi

Holat: **huquqlar qatlami tayyor, to‘lov YOQILMAGAN** (narx tasdiqlanmagan).
Sana: 2026-10-09. Bog‘liq: `docs/proposals/LAB_REPORT_READING.md` (2-bo‘lim).

## 0. Egasining qarorlari (asos)

| Bepul | Pro |
|---|---|
| Leykoformula hisoblagichi | Cheksiz natijalar tarixi |
| Foiz va mutlaq sonlar | PDF eksport |
| Asosiy qo‘llanmalar | Kengaytirilgan mashqlar |
| Tarixda oxirgi 3 natija | Toifa imtihoniga to‘liq tayyorgarlik |

Qoidalar:
1. Boshlangan sanash yoki imtihon **hech qachon** to‘lov oynasi bilan to‘xtatilmaydi.
   `can(Feature)` faqat amal boshlanishidan oldin yoki natijadan keyin so‘raladi;
   obuna o‘rtada tugasa ham boshlangan amal oxirigacha ishlaydi.
2. Bepul tarixda oxirgi 3 natija ko‘rinadi. Eskilari **o‘chirilmaydi**, ekranda
   “Yana N ta eski natija saqlangan” deyiladi.
3. Obuna tugagach Pro davrida saqlangan natijalar ko‘rinib turadi; faqat yangi Pro
   amallar yopiladi.
4. TestFlight/debug buildlarda hamma imkoniyat ochiq.
5. Narx tasdiqlanmaguncha haqiqiy to‘lov yoqilmaydi.
6. Pro huquqi bitta lokal sozlamaga bog‘lanmaydi.

## 1. Hozir nima bor (kodda)

| Joy | Nima |
|---|---|
| `lib/core/entitlements/feature.dart` | `Feature` enum: qaysi imkoniyat bepul, qaysi Pro |
| `lib/core/entitlements/entitlement_service.dart` | `EntitlementService`: `can()`, `historyVisibleLimit()`, `historyView()`, `restore()`, `purchase()` |
| `lib/core/entitlements/entitlement_cache.dart` | Imzolangan (HMAC-SHA256, kalit Keychain/Keystore'da), hisobga bog‘langan, muddatli kesh |
| `lib/core/entitlements/entitlement_source.dart` | `EntitlementSource`: Supabase (`my_entitlements` RPC + `verify-purchase`) yoki “ulanmagan” |
| `lib/core/entitlements/purchase_adapter.dart` | `PurchaseAdapter` interfeysi + `UnavailablePurchaseAdapter` (hech qanday oyna yo‘q) |
| `supabase/migrations/…1200_entitlements.sql` | `entitlements` jadvali, RLS, `my_entitlements()`, `entitlement_active()`, `entitlement_apply()` |
| `supabase/tests/20_entitlements.sql` | Qabul testi (RLS, yozish faqat service role, tartib, refund) |
| `supabase/functions/verify-purchase/` | Edge Function skeleti: hozir har doim `503 not_configured` |
| Profil → Obuna va tiklash | Halol holat: “To‘lov hali yoqilmagan; TestFlight’da hamma imkoniyat ochiq” |
| O‘rganish → Imtihon → Tarix | Yagona namunaviy ulanish: `historyView()` (bepulda 3 ta + Pro davri) |

Boshqa bo‘limlarga (leykoformula, toifa imtihoni, PDF) gating hali **ulanmagan** —
ular parallel qurilmoqda. Ulash: `context.services.entitlements.can(Feature.x)`
ni boshlash tugmasidan oldin yoki natija ekranida tekshirish.

### Pro manbalari (tartib bilan)

1. **Build rejimi** — `allFeaturesOpen = kDebugMode || LG_ALL_FEATURES_OPEN`.
2. **Server** — `entitlements` jadvali; faqat server (service role) yozadi.
3. **Oflayn kesh** — oxirgi server javobi: foydalanuvchi id’siga bog‘langan,
   HMAC bilan imzolangan, 7 kun amal qiladi (`offlineTtl`), har xaridning o‘z
   `expires_at` muddati ham tekshiriladi (server va qurilma soati farqi hisobga
   olinadi). Soat javob olingan paytdan 10 daqiqadan ko‘proq orqaga surilsa kesh
   Pro bermaydi. Imzo buzilsa yoki boshqa hisobniki bo‘lsa — e’tiborsiz.

Cheklov (halol): qurilmadagi kesh — qulaylik, xavfsizlik chegarasi emas
(root/jailbreak qurilmada kalit ham o‘qilishi mumkin). Shu sababli serverda
ishlaydigan Pro amallar (masalan, kelajakdagi AI o‘qish) `entitlement_active()`
bilan **serverda** qayta tekshiriladi.

### Pro davrlari (obuna tugagach saqlangan natijalar)

Server qatorlari muddati o‘tgandan keyin ham o‘chirilmaydi (`expired`). Ilova
har qatordan `started_at..expires_at` davrini oladi; shu davrda saqlangan natija
bepul rejimda ham ko‘rinadi. Qaytarilgan (refund, `revoked`) xarid davr hisoblanmaydi
— natijalar o‘chmaydi, faqat “N ta eski natija saqlangan” qatoriga tushadi.
Kesh oflayn muddati o‘tgan bo‘lsa ham davrlar ishlatiladi (bu huquq emas, tarix).

## 2. Ma’lumot modeli (server)

`public.entitlements`: `user_id`, `product_id`, `platform` (`app_store` |
`play_store`), `status`, `started_at`, `expires_at`, `original_transaction_id`,
`ownership` (`purchased` | `family_shared`), `environment` (`production` |
`sandbox`), `event_at`, `updated_at`. Noyob: `(platform, original_transaction_id)`.

| status | Pro beradimi | Manba |
|---|---|---|
| `active` | ha | App Store 1 / Play `ACTIVE` |
| `grace_period` | ha | App Store 4 / Play `IN_GRACE_PERIOD` |
| `billing_retry` | yo‘q | App Store 3 / Play `ON_HOLD` |
| `paused` | yo‘q | Play `PAUSED` |
| `expired` | yo‘q | App Store 2 / Play `EXPIRED` |
| `revoked` | yo‘q | refund, Family Sharing to‘xtatildi, Play voided |

RLS: foydalanuvchi faqat o‘z qatorini o‘qiydi; `anon`/`authenticated` uchun
insert/update/delete yo‘q. `entitlement_apply()` faqat `service_role`:
- eskiroq hodisa (`event_at`) yangisining ustidan yozilmaydi (`stale`);
- xarid boshqa hisobga bog‘langan bo‘lsa — ko‘chirilmaydi (`owned_by_other`).

Hisob o‘chirilsa (`delete-account`) qatorlar `on delete cascade` bilan ketadi.
Do‘kondagi obuna esa davom etadi — hisob o‘chirish oynasida “obunani App Store /
Google Play sozlamalarida bekor qiling” degan matn qo‘shiladi (Apple talabi).

## 3. Xarid oqimi (yoqilgandan keyin)

```
Ilova (StoreKit 2 / Play Billing) ──xarid──▶ do'kon
   │ transactionId / purchaseToken
   ▼
verify-purchase (Edge Function, foydalanuvchi JWT)
   │ App Store Server API / Play Developer API (kalitlar faqat secrets'da)
   ▼
entitlement_apply (service role) ──▶ entitlements
   ▲
billing-notifications (Edge Function) ◀── ASSN v2 / RTDN (Pub/Sub push)
```

Ilova bergan holat yoki muddatga **ishonilmaydi** — faqat identifikator olinadi.

### 3.1 iOS: StoreKit 2 + App Store Server Notifications v2
- Xarid: `Product.purchase(options: [.appAccountToken(<Supabase user UUID>)])` —
  server bildirishnomani shu UUID orqali hisobga bog‘laydi.
- `Transaction.updates` tinglanadi (ilova yopiq paytdagi yangilanishlar,
  Ask to Buy, refund); har tranzaksiya serverga yuborilgach `finish()`.
- Server: `GET /inApps/v1/transactions/{id}` va
  `GET /inApps/v1/subscriptions/{originalTransactionId}` (ES256 JWT, In-App
  Purchase kaliti). JWS Apple root sertifikat zanjiri bilan tekshiriladi,
  `bundleId` solishtiriladi. Avval production, `4040010` bo‘lsa sandbox.
- ASSN v2 (App Store Connect → App Information → Production/Sandbox URL):
  `SUBSCRIBED`, `DID_RENEW`, `DID_FAIL_TO_RENEW` (subtype `GRACE_PERIOD`),
  `GRACE_PERIOD_EXPIRED`, `EXPIRED`, `REFUND`, `REVOKE` (Family Sharing),
  `DID_CHANGE_RENEWAL_STATUS`. `signedPayload` imzosi tekshiriladi; `signedDate`
  → `event_at`.

### 3.2 Android: Google Play Billing + RTDN
- Play Billing Library (joriy talab qilingan versiya), `obfuscatedAccountId` =
  Supabase user UUID ning hash’i.
- Server: `purchases.subscriptionsv2.get`; xarid **3 kun ichida acknowledge**
  qilinadi (aks holda Google pulni qaytaradi) — serverda.
- RTDN: Pub/Sub push → `billing-notifications`; `SUBSCRIPTION_PURCHASED`,
  `RENEWED`, `IN_GRACE_PERIOD`, `ON_HOLD`, `PAUSED`, `EXPIRED`, `REVOKED`.
  Voided Purchases API — refund’lar uchun kunlik tekshiruv.
- Yangilash/almashtirishda `linkedPurchaseToken` zanjiri: asl token
  `original_transaction_id` sifatida qoladi.

### 3.3 Tiklash (Restore Purchases)
- iOS: `AppStore.sync()` → `Transaction.currentEntitlements` → id’lar
  `verify-purchase` (`action: restore`) ga. Tugma Obuna ekranida doim bor
  (App Store talabi); hozir o‘chirilgan va “Hali mavjud emas” deb yozilgan.
- Android: `queryPurchasesAsync(SUBS)` → tokenlar serverga.
- Xarid boshqa LabGuide hisobiga bog‘langan bo‘lsa — ko‘chirilmaydi,
  foydalanuvchiga “bu xarid boshqa hisobda” deyiladi (`BillingOutcome.ownedByOther`).
  Ko‘chirish siyosati (masalan, qo‘llab-quvvatlash orqali) — egasining qarori.

### 3.4 Oilaviy ulashish va qaytarish
- **Family Sharing** (iOS, ixtiyoriy, mahsulotda yoqiladi): `inAppOwnershipType =
  FAMILY_SHARED` → `ownership = family_shared`. `REVOKE` kelsa → `revoked`.
  Yoqish-yoqmaslik egasining qarori (bir marta yoqilgach o‘chirib bo‘lmaydi).
- **Refund**: `REFUND` (Apple) / `REVOKED` yoki voided (Google) → `revoked`;
  Pro darhol yopiladi, qator o‘chmaydi, davr hisobga olinmaydi; natijalar
  o‘chirilmaydi.

### 3.5 Grace period va billing retry
- App Store Connect’da **Billing Grace Period** yoqiladi (tavsiya: 16 kun).
  Grace davrida Pro ochiq, Obuna ekranida “to‘lovni yangilang” eslatmasi.
- Billing retry / Play `ON_HOLD` — Pro yopiq; to‘lov tiklansa `DID_RENEW` /
  `RECOVERED` bilan qaytadi.

## 4. Narx tasdiqlangandan keyingi qadamlar (tartib bilan)

1. **Egasi:** narx, davrlar (oylik/yillik), bepul sinov (bor/yo‘q, necha kun),
   Family Sharing, mahsulot id’lari (taklif: `labguide.pro.monthly`,
   `labguide.pro.yearly` — tasdiqlanmagan).
2. App Store Connect: Paid Applications Agreement, soliq/bank; Subscription Group;
   mahsulotlar; lokalizatsiya (uz/ru/en); review skrinshoti; Grace Period.
   Google Play Console: merchant hisob; subscription + base plan; RTDN topic.
3. Kalitlar (faqat `supabase secrets set`): `APPLE_ISSUER_ID`, `APPLE_KEY_ID`,
   `APPLE_PRIVATE_KEY_P8`, `APPLE_BUNDLE_ID`, `GOOGLE_SERVICE_ACCOUNT_JSON`,
   `GOOGLE_PACKAGE_NAME`. Repoga va ilovaga hech qachon tushmaydi.
4. `verify-purchase` ichidagi `verifyApple` / `verifyGoogle` yoziladi (JWS
   tekshiruvi, Play acknowledge); `billing-notifications` funksiyasi qo‘shiladi.
5. Ilovada haqiqiy `PurchaseAdapter` (StoreKit 2 / Play Billing; Flutter’da
   `in_app_purchase` paketi yoki native kanal — litsenziya va SK2 qo‘llovi
   tekshiriladi). Obuna ekrani: do‘kondan kelgan narx (`displayPrice`), davr,
   avtomatik yangilanish, bekor qilish yo‘li, Foydalanish shartlari va Maxfiylik
   havolalari (3.1.2).
6. Sandbox / StoreKit Configuration file / Play license testers bilan sinov:
   xarid, yangilanish, grace, refund, tiklash, boshqa hisob, oflayn.
7. Faqat shundan keyin: `supabase secrets set LG_BILLING_ENABLED=true` va store
   build’da `LG_ALL_FEATURES_OPEN=false`.

## 5. App Store qoidalari (qisqa)

- **3.1.1**: raqamli imkoniyat (Pro) faqat In-App Purchase orqali; ilovada
  tashqi to‘lov havolasi yoki “saytda arzonroq” degan matn yo‘q. Tiklash tugmasi bor.
- **3.1.2**: obuna doimiy qiymat beradi; to‘lov oynasida narx, davr, avtomatik
  yangilanish va shartlar aniq ko‘rsatiladi; bepul sinov bo‘lsa — tugash sanasi.
- **5.1.1(v)**: hisob o‘chirish ilovada bor (`delete-account`); obunani bekor
  qilish haqida eslatma qo‘shiladi.
- **Ochiq savol (egasiga):** hozirgi dizayn Pro’ni LabGuide hisobiga bog‘laydi
  (server qatori). Apple ro‘yxatdan o‘tmasdan xarid qilishga ruxsat berishni
  kutishi mumkin (5.1.1). Variant: hisobsiz foydalanuvchi uchun StoreKit 2
  `Transaction.currentEntitlements` (qurilmada JWS tekshiriladi) to‘rtinchi
  manba sifatida, hisobga kirganda serverga bog‘lanadi. Qaror kerak.
- Hech bir boshlangan sanash/imtihon to‘lov oynasi bilan to‘xtatilmaydi; to‘lov
  oynasi faqat foydalanuvchi o‘zi bosganda ochiladi.

## 6. CI va build rejimlari

| Build | `LG_ALL_FEATURES_OPEN` | Natija |
|---|---|---|
| `flutter run` (debug) | — | `kDebugMode` → hamma ochiq |
| CI `build` rejimi (push/PR, sinov APK, imzosiz iOS) | `true` | hamma ochiq |
| CI `testflight` rejimi | `true` | hamma ochiq (TestFlight) |
| Kelajakdagi `store` rejimi (App Store / Play production) | `false` | haqiqiy huquqlar |

`.github/workflows/ci.yml` da `LG_ALL_FEATURES_OPEN` env’i rejimdan hisoblanadi
va har `flutter build` ga `--dart-define` bilan beriladi. Do‘kon relizi uchun
`mode: store` qo‘shilganda ifoda avtomatik `false` beradi (u faqat `build` va
`testflight` uchun `true`). Release store build qo‘shilganda CI’da tekshiruv
qo‘shiladi: `store` rejimida `LG_ALL_FEATURES_OPEN=true` bo‘lsa — xato.

Eslatma: TestFlight’dan App Store versiyasiga o‘tganda qurilmadagi natijalar
saqlanadi; store build’da bepul foydalanuvchiga ular “N ta eski natija saqlangan”
bo‘lib ko‘rinadi (o‘chirilmaydi).

## 7. Testlar

- `test/unit/entitlements_test.dart`: TestFlight ochiq; bepul limit 3; eski
  natijalar o‘chmaydi; obuna tugagach Pro davri natijalari ko‘rinadi; refund;
  grace / billing retry; oflayn kesh muddati; soat orqaga; imzo buzilishi;
  boshqa hisob; tiklash natijalari.
- `test/widget/entitlements_flow_test.dart`: imtihon tarixi (bepul: 3 ta + “N ta
  eski natija saqlangan”; debug: hammasi), Obuna ekranining halol holati.
- `supabase/tests/20_entitlements.sql` (`tool/backend_test.sh`): RLS, mijoz
  yoza olmaydi, `entitlement_apply` faqat service role, stale hodisa, boshqa
  hisob, refund qatorni o‘chirmaydi.

## 8. Ma’lum cheklovlar

- `ExamController.historyLimit = 50` — mavjud kod 50 tadan eski natijani
  qurilmadan o‘chiradi. Bu “eski natijalar o‘chirilmaydi” qoidasiga zid;
  Pro “cheksiz tarix” ulanayotganda bu chegara qayta ko‘rib chiqilishi kerak
  (imtihon bo‘limi egasi bilan kelishib).
- Hisobsiz (mehmon) foydalanuvchi uchun server huquqi yo‘q (5-bo‘limdagi savol).
- Pro davrlari faqat hisobga kirilgan paytda (kesh shu hisobniki) ma’lum.
