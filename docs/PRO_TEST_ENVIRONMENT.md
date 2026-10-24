# Pro’ni faqat TEST muhitida yoqish (D-75)

> **Muhim: production to‘lovlari YOQILMAGAN.** Do‘konga chiqadigan (release) buildda
> `LG_PRO_ENABLED` berilmaydi — `BuildFlags.proEnabled = false`; production serverda
> `LG_BILLING_ENABLED` o‘rnatilmagan — barcha `/v1/billing/*` yo‘llari 404; `LG_BILLING_SANDBOX`
> o‘rnatilmagan; `ProGatePolicy.gated` bo‘sh — bugun bepul bo‘lgan hech narsa pullik emas. Quyidagi
> qadamlar faqat sinov uchun. Hech qanday kalit, parol yoki token bu faylga yozilmaydi — ular faqat
> Cloudflare Worker secretlariga egasi tomonidan qo‘yiladi.

## 1. Eng oddiy: emulyatorda soxta xarid (do‘kon va serversiz)
Faqat debug/profile build. Release buildda bu rejim IMKONSIZ (`BuildFlags.fakePurchases` =
`!kReleaseMode && ...`, qorovul: `test/guards/pro_flag_default_guard_test.dart`).
```
flutter run --dart-define=LG_PRO_ENABLED=true --dart-define=LG_FAKE_PURCHASES=true
```
- Profil → “Obuna”: narxlar katalogdan (Talaba 1.49/9.99, Ustoz 2.49/24.99, Mutaxassis 3.49/34.99 USD).
- Hisobga kiring (email kodi) → “Bepul sinovni boshlash” tugmasi chiqadi (soxta attestatsiya) → tasdiq oynasi →
  30 kunlik sinov. Sinov hech qanday xarid boshlamaydi.
- “Obuna bo‘lish” → soxta do‘kon → Pro (`environment: sandbox`). Ilova qayta ochilsa holat yo‘qoladi.
- Pul, haqiqiy do‘kon yoki server ishtirok etmaydi.

## 2. Test serveri (staging Worker) — haqiqiy sandbox xaridlari
Faqat ALOHIDA test Worker va test D1 bazasida (production emas).
1. Migratsiyalarni test D1 ga qo‘llang: `0013_billing`, `0014_pro_grants`, `0015_pro_trials`,
   `0016_billing_notifications` (production D1 ga emas).
2. Test Worker o‘zgaruvchilari:
   - `LG_BILLING_ENABLED=true` — billing yo‘llari ochiladi;
   - `LG_BILLING_SANDBOX=true` — Apple Sandbox va Play litsenziya testeri xaridlari qabul qilinadi
     (muhit `sandbox` deb yoziladi). Production’da bu YO‘Q: sandbox xaridi `403 sandbox_not_allowed`;
   - `TRIAL_PLATFORMS=android` (standart). iOS ni faqat Apple yozma javobidan keyin qo‘shing
     (`docs/APPLE_REVIEW_QUESTION_DRAFT.md`);
   - secretlar (egasi qo‘yadi): `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY`,
     `GOOGLE_PLAY_SERVICE_ACCOUNT`, RTDN uchun `PLAY_RTDN_AUDIENCE` + `PLAY_RTDN_SERVICE_ACCOUNT`
     (tavsiya, Pub/Sub OIDC) yoki `PLAY_RTDN_TOKEN`; ixtiyoriy `APPLE_SUBSCRIPTION_GROUP_ID`.
   - Kalitlar bo‘lmasa: `503 store_verifier_not_configured` (ilova to‘lov oynasini ko‘rsatmaydi).
3. Ilova (test build, do‘konga yuborilmaydi):
   ```
   flutter run --release --dart-define=LG_PRO_ENABLED=true --dart-define=LG_API_URL=<test-worker-url>
   ```
   (`LG_API_URL` — `lib/core/backend/cloudflare_backend.dart` dagi server manzili bayrog‘i; release
   rejimida `LG_FAKE_PURCHASES` ishlamaydi.)

## 3. Apple — TestFlight va Sandbox hisoblari
1. App Store Connect → Users and Access → Sandbox → Testers: sinov Apple ID yarating (haqiqiy Apple ID emas).
2. iPhone: Settings → App Store → Sandbox Account → shu hisob bilan kiring.
3. TestFlight buildni (Pro bayrog‘i bilan yig‘ilgan alohida test build) o‘rnating.
4. Har 6 mahsulotni sotib oling (`uz.labguide.student|teacher|specialist.monthly|yearly`), tiklang
   (o‘chirib qayta o‘rnatish, boshqa qurilma), boshqa LabGuide hisobida `owned_by_other` ni tekshiring.
5. Sandbox’da bekor qilish → davr oxirigacha Pro → EXPIRED; refund (sandbox) → ASSN V2 REFUND → Pro darhol yo‘q.
6. App Store Connect → App Store Server Notifications: Sandbox URL = test Worker
   `/v1/billing/apple/notifications`, Version 2; “Request a Test Notification”.
7. iOS’da bepul sinov tugmasi CHIQMAYDI (`TRIAL_PLATFORMS=android`) — bu kutilgan holat.

## 4. Google — Play litsenziya testerlari
1. Play Console → Setup → License testing: tester Google hisoblarini qo‘shing.
2. Ichki test treki (internal testing) — Pro bayrog‘i bilan yig‘ilgan test build.
3. Obunalar: `uz.labguide.student`, `uz.labguide.teacher`, `uz.labguide.specialist`; har birida base
   plan `monthly` (P1M) va `yearly` (P1Y). **Free-trial offer yaratmang** (30 kun — server sinovi).
4. Test kartalari: “Always approves” → xarid; “Always declines” → IN_GRACE_PERIOD (Pro bor) → ON_HOLD
   (Pro yo‘q); “Approves then charges back” → voided/REVOKED (Pro darhol yo‘q); oylik rejani pauza → PAUSED
   (Pro yo‘q) → RECOVERED.
5. RTDN: Pub/Sub topic → push subscription (OIDC token, audience = `PLAY_RTDN_AUDIENCE`) → test Worker
   `/v1/billing/google/rtdn`; Play Console’da “Send test message”.
6. Bepul sinov (Android): Play Integrity tekshiruvchisi hali YO‘Q (attestatsiya sozlanmagan → tugma
   chiqmaydi). Sinov oqimini faqat 1-bo‘limdagi soxta rejimda ko‘rish mumkin.

## 5. Avtomatik testlar
- Server: `cd cloudflare && npx vitest run` (soxta do‘kon tekshiruvchilari va test Apple zanjiri;
  haqiqiy do‘konga murojaat yo‘q), `npx tsc --noEmit`.
- Ilova: `flutter test test/unit/pro_readiness_d75_test.dart test/widget/subscription_screen_test.dart
  test/guards/pro_flag_default_guard_test.dart`.

## 6. Production’ni yoqish (BU HUJJAT DOIRASIDA EMAS)
Faqat egasining yozma qarori bilan: do‘kon mahsulotlari, kalitlar, migratsiyalar, `LG_BILLING_ENABLED`,
Data safety / App Privacy, maxfiylik siyosati, Apple javobi (iOS sinovi) — `docs/DECISIONS.md` D-75.
