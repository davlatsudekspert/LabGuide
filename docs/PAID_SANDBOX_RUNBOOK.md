# Pullik tizim: sandbox sinov yo‘riqnomasi (App Store / Google Play) — `paid/srv`, D-77 addendum

> **Bu hujjat — reja.** Bu ishda hech qanday do‘kon hisobiga kirilmagan, mahsulot yaratilmagan, sandbox xaridi
> qilinmagan, deploy qilinmagan. Quyidagi “kutilgan natija” — server/ilova kodi va avtomatik testlar (soxta do‘kon,
> soxta Apple/Google API) bo‘yicha KUTILGAN xatti-harakat; haqiqiy do‘konda **NOT VERIFIED**. Narxlar va mahsulot
> id’lari D-76 dan, do‘konda yaratilmaguncha **UNCONFIRMED**. `<OWNER_TO_CONFIRM>` — egasi to‘ldiradi.

## 1. Egasi tayyorlaydigan narsalar (oldindan)

### 1.1 Umumiy
- Test Worker + test D1 (production emas), migratsiyalar 0014–0019 — `docs/PAID_BACKEND_DEPLOY_CHECKLIST.md`.
- Test Worker o‘zgaruvchilari: `LG_BILLING_ENABLED=true`, `LG_BILLING_SANDBOX=true`, `TRIAL_PLATFORMS=android`
  (iOS sinovi faqat Apple javobidan keyin: `android,ios`).
- Ilova test buildi (do‘konga yuborilmaydi):
  `flutter build … --dart-define=LG_PRO_ENABLED=true --dart-define=LG_API_URL=<test-worker-url>`
  (`LG_FAKE_PURCHASES` YO‘Q — haqiqiy do‘kon). Build bu ishda yig‘ilmagan.
- `ProGatePolicy.gated` — qaysi funksiyalar yopilishi (feat agenti / egasi qarori). Bo‘sh bo‘lsa, sinov va
  xarid holati ko‘rinadi, lekin hech narsa yopilmaydi.

### 1.2 App Store Connect + TestFlight
1. Paid Applications Agreement, soliq, bank — **<OWNER_TO_CONFIRM>** (holat).
2. Bitta obuna guruhi `<OWNER_TO_CONFIRM: guruh nomi/id>`, 8 mahsulot (D-76, UNCONFIRMED):
   `uz.labguide.student.monthly/.yearly`, `uz.labguide.teacher.monthly/.yearly`,
   `uz.labguide.specialist.monthly/.yearly`, `uz.labguide.premium.monthly/.yearly`; narx pog‘onalari
   `<OWNER_TO_CONFIRM>`; lokalizatsiya (uz/ru/en), review skrinshoti.
3. Kirish taklifi (Introductory Offer = Free Trial): egasi qarori D-80 (2026-10-31) — bepul sinov **30 kun**; Apple’da
   8 mahsulotning hammasiga **1 oy** (Apple “1 oy” = kalendar oy, server sinovi esa aniq 30 kun). Apple uni haqli
   foydalanuvchiga O‘ZI qo‘llaydi; ilova shartlarni StoreKit’dan o‘qib ko‘rsatadi, tugash sanasini QAYTA HISOBLAMAYDI —
   do‘kon kvitansiyasidagi sana (`trial_policy.dart`, D-80). Do‘konda yaratilganmi — NOT VERIFIED
   (`tool/store/store_check.py` ASC’da `intro=` ni o‘qiydi). Server sinovi bilan qo‘shilib ketishi (stacking) —
   `docs/RELEASE_CANDIDATE_2026-10-31.md` §3.
4. Family Sharing — O‘CHIQ (D-75).
5. Users and Access → Integrations → In-App Purchase kaliti (.p8, Key ID, Issuer ID) → `APPLE_IAP_*`.
6. Developer → Keys → **DeviceCheck** kaliti (.p8, Key ID, Team ID) → `APPLE_DEVICECHECK_*` (faqat iOS sinovi
   yoqilganda).
7. App Store Server Notifications → Version 2 → Sandbox URL = `https://<test-worker>/v1/billing/apple/notifications`.
8. Users and Access → Sandbox → Testers: kamida 2 sandbox Apple ID (A, B) `<OWNER_TO_CONFIRM>`.
9. TestFlight: ichki testerlar; Pro bayrog‘i bilan yig‘ilgan alohida build.

### 1.3 Google Play Console (internal / closed testing)
1. Payments profile / merchant — `<OWNER_TO_CONFIRM>`.
2. 4 obuna (`uz.labguide.student|teacher|specialist|premium`) × 2 base plan (`monthly` P1M, `yearly` P1Y);
   narxlar (UZS pog‘onalari) `<OWNER_TO_CONFIRM>`. **Free-trial offer — egasi qarori D-80: 30 kun / 1 oy, Play Console’da
   egasi o‘rnatadi** (NOT VERIFIED). Kod bo‘yicha ilova standartda faqat base plan sotadi: offer yaratilsa ham
   `storeIntroOffersAllowed = false` bo‘lgani uchun tanlanmaydi (bu bayroq D-80 da O‘ZGARTIRILMAGAN — qaror kerak).
3. Setup → License testing: tester Google hisoblari (A, B) `<OWNER_TO_CONFIRM>`.
4. Internal testing treki — Pro bayrog‘i bilan yig‘ilgan test build; testerlar ro‘yxati.
5. Google Cloud: service account (Play Developer API: “View financial data, orders…” + “Manage orders and
   subscriptions”) → `GOOGLE_PLAY_SERVICE_ACCOUNT`.
6. App integrity → Play Integrity API → Cloud loyihasini bog‘lash; service account (scope `playintegrity`) →
   `PLAY_INTEGRITY_SERVICE_ACCOUNT`; App signing key certificate SHA-256 → `PLAY_INTEGRITY_CERT_SHA256`.
7. RTDN: Pub/Sub topic `<OWNER_TO_CONFIRM>` → push subscription (OIDC, audience = `PLAY_RTDN_AUDIENCE`) →
   `https://<test-worker>/v1/billing/google/rtdn`; Play Console → Monetization setup → topic; “Send test
   notification” → serverda `billing_notification` / `TEST` / `ignored`.

### 1.4 Server secretlari (faqat nomlar)
`LG_SERVER_SECRET` (mavjud), `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY`,
`APPLE_SUBSCRIPTION_GROUP_ID` (ixtiyoriy), `GOOGLE_PLAY_SERVICE_ACCOUNT`, `PLAY_RTDN_AUDIENCE`,
`PLAY_RTDN_SERVICE_ACCOUNT` (yoki `PLAY_RTDN_TOKEN`), `PLAY_INTEGRITY_SERVICE_ACCOUNT`, `PLAY_INTEGRITY_CERT_SHA256`,
`APPLE_DEVICECHECK_KEY_ID`, `APPLE_DEVICECHECK_TEAM_ID`, `APPLE_DEVICECHECK_PRIVATE_KEY`, `APPLE_DEVICECHECK_ENV`
(faqat dev), `TRIAL_BLOCKED_EMAIL_DOMAINS` (ixtiyoriy).

## 2. Sinov matritsasi

Har qator: **qadam → kutilgan natija (kod bo‘yicha)**. Natija ustunini egasi/tester to‘ldiradi
(PASS/FAIL + sana + qurilma). Hozir hammasi — **NOT RUN**.

| # | Holat | Platforma | Qadam | Kutilgan natija | Natija |
|---|---|---|---|---|---|
| P1 | Xarid (hisob bilan) | iOS, Android | Hisobga kiring → Profil → Obuna → to‘lov oynasi → reja → do‘kon oynasida tasdiqlash | Do‘kon oynasi ochiladi (narx do‘kondan); tasdiqdan keyin `POST /v1/billing/verify` 200; “Obuna faol · sana gacha”; serverda `entitlements` qatori (`environment = sandbox`) | NOT RUN |
| P2 | Xarid bekor (oynani yopish) | ikkalasi | Do‘kon oynasini yoping | Xabar yo‘q, pul yo‘q, holat o‘zgarmaydi | NOT RUN |
| P3 | Ask to Buy / kutilayotgan to‘lov | iOS / Android (naqd) | Kutilayotgan to‘lov | “To‘lov kutilmoqda”; tasdiqlangach `updates` orqali avtomatik ochiladi | NOT RUN |
| R1 | Tiklash (hisob bilan) | ikkalasi | Ilovani o‘chirib qayta o‘rnating → kiring → “Xaridlarni tiklash” | “Xarid tiklandi.”; o‘sha `original_transaction_id` | NOT RUN |
| R2 | Tiklash — hech narsa yo‘q | ikkalasi | Xaridsiz hisob/Apple ID | “Tiklanadigan faol obuna topilmadi.” | NOT RUN |
| R3 | Boshqa LabGuide hisobi | ikkalasi | A hisobida sotib oling → chiqing → B hisobi bilan tiklang | B ga huquq YO‘Q; “Xarid boshqa hisobga bog‘langan” (`owned_by_other`) | NOT RUN |
| G1 | Mehmon xaridi | ikkalasi | Hisobsiz → to‘lov oynasi → Mutaxassis → xarid | Do‘kon oynasi (hisob belgisisiz); `POST /v1/billing/guest/verify` 200; Lab ochiladi, ustoz paneli YO‘Q; `store_guest_entitlements` qatori | NOT RUN |
| G2 | Mehmon — Ustoz/Premium | ikkalasi | Hisobsiz → Ustoz reja kartasi | Xarid tugmasi yo‘q, “ustoz paneli — hisobga kiring” izohi | NOT RUN |
| G3 | Mehmon tiklashi | ikkalasi | Ilovani qayta o‘rnating (hisobsiz) → “Xaridlarni tiklash” | “Xarid tiklandi.” (o‘sha do‘kon hisobi); yangi qurilma belgisi bilan token | NOT RUN |
| G4 | Mehmon → hisob | ikkalasi | G1 dan keyin hisobga kiring | `POST /v1/billing/guest/link` → xarid hisobga o‘tadi; chiqib mehmon bo‘lsangiz — huquq YO‘Q (“hisobga kiring”, ikki marta berilmaydi) | NOT RUN |
| G5 | Mehmon — 6-qurilma | ikkalasi | Bitta xaridni 6 ta qurilmada mehmon sifatida tiklash | 6-sida `device_limit` (huquq yo‘q) | NOT RUN |
| C1 | Bekor qilish | ikkalasi | Do‘kon obuna sozlamalari → bekor | Davr oxirigacha huquq; Obuna ekranida “Avtomatik yangilash o‘chirilgan: sana gacha”; keyin EXPIRED → huquq yo‘q, Free + ma’lumot qoladi | NOT RUN |
| N1 | Yangilanish | ikkalasi | Sandbox tezlashtirilgan davr | ASSN `DID_RENEW` / RTDN `RENEWED` → `expires_at` oldinga | NOT RUN |
| E1 | Muddat tugashi | ikkalasi | Bekor + davr o‘tishi | `EXPIRED` → huquq yo‘q | NOT RUN |
| GR1 | Grace / billing retry | Android: “Always declines” karta; iOS: sandbox “billing retry” | To‘lov rad | IN_GRACE_PERIOD — huquq bor (Apple: `gracePeriodExpiresDate` gacha); ON_HOLD / billing retry — yo‘q; RECOVERED — qaytadi | NOT RUN |
| PA1 | Pauza (Play) | Android | Oylik rejani pauza | PAUSED — huquq yo‘q; tiklangach bor | NOT RUN |
| RF1 | Refund / chargeback | iOS sandbox refund; Android “Approves then charges back” | Qaytarish | ASSN `REFUND` / RTDN voided → darhol `revoked`, huquq yo‘q (mehmon xaridida ham) | NOT RUN |
| U1 | Yuqoriga o‘tish | ikkalasi | Talaba → Mutaxassis | Darhol yangi reja, bitta qator (Apple: o‘sha original id; Play: `linkedPurchaseToken`) | NOT RUN |
| D1 | Pastga o‘tish | ikkalasi | Premium → Talaba | Joriy davr oxirigacha Premium; “Keyingi yangilanishdan: Talaba rejasi” (Apple `autoRenewProductId`; Play `deferredItemReplacement` — maydon NOT VERIFIED) | NOT RUN |
| O1 | Oflayn | ikkalasi | Xariddan keyin internetni o‘chiring | ≤ 7 kun (yoki obuna tugashigacha) huquq; keyin yo‘q; Free ishlaydi | NOT RUN |
| O2 | Soat orqaga | ikkalasi | Oflayn, 6-kuni ilovani oching, soatni 1-kunga qaytaring | Huquq YO‘Q (monoton yuqori belgi); soat to‘g‘rilansa — qaytadi; internetda server javobi tiklaydi | NOT RUN |
| ST1 | Do‘kon sinovi (faqat egasi taklif yaratsa) | iOS (Apple o‘zi qo‘llaydi) / Android (`storeIntroOffersAllowed` true bo‘lsa) | Haqli Apple ID / Google hisob | Kartada do‘kondan olingan shart: “{davr} bepul, keyin {narx}”; serverda `period_type = trial`, huquq bor; server sinovidan keyin bo‘lsa — “bu do‘kon taklifi” izohi | NOT RUN |
| T1 | Server sinovi — boshlash | Android | Hisob → Obuna → “Bepul sinovni boshlash” | Tugma faqat `status.trial.android = true` (Play Integrity sozlangan) bo‘lsa; 201, 30 kun (D-80), `GET /v1/billing/trial` → `active` | NOT RUN |
| T2 | Sinov — muddat | Android | 30 kun (server soati; D-80) | `expired`; pullik funksiyalar yopiladi, Free + ma’lumot qoladi; qayta sinov yo‘q | NOT RUN |
| T3 | Sinov — takror | Android | Ilovani o‘chirib qayta o‘rnatib, yangi hisob bilan | 409 `trial_already_used` (o‘sha ANDROID_ID); factory reset’dan keyin — YANGI sinov (qolgan xavf) | NOT RUN |
| T4 | Sinov — email aliasi | ikkalasi | `ali.v+x@gmail.com` (avval `aliv@gmail.com` olgan) | 409 | NOT RUN |
| T5 | Sinov — root / emulyator | Android | Root qilingan yoki emulyator | 403 `device_attestation_failed` (MEETS_DEVICE_INTEGRITY yo‘q) | NOT RUN |
| T6 | Sinov — sozlanmagan | ikkalasi | Play Integrity / DeviceCheck secretlarisiz | Tugma yo‘q; server 503 `trial_unavailable` | NOT RUN |
| T7 | Sinov — iOS (faqat `TRIAL_PLATFORMS=android,ios`) | iOS | DeviceCheck bilan | 201; Apple biti bit0=1; ilovani qayta o‘rnatib boshqa hisob — 409 | NOT RUN |

## 3. Server loglarini o‘qish

- `npx wrangler tail <test-worker> --format pretty` (ruxsat bilan). Logda faqat tur/kod: `attestation rejected
  nonce_mismatch|device_integrity|unlicensed|certificate_mismatch|stale_token|…`, `attestation verify error
  <kod>`, `billing resync <kod>`, `guest resync <kod>`, `play acknowledge failed <status>`. Email, token,
  tranzaksiya id YOZILMAYDI.
- D1 jurnali: `SELECT action, target, details, created_at FROM audit_log WHERE action IN
  ('pro_trial_started','billing_notification') ORDER BY created_at DESC LIMIT 50;`
- Bildirishnomalar: `SELECT * FROM billing_notifications ORDER BY received_at DESC LIMIT 20;` (`outcome`:
  `updated` / `no_row` / `ignored` / `sandbox_ignored`).
- Mehmon: `SELECT platform, product_id, status, period_type, linked_user_id IS NOT NULL AS linked FROM
  store_guest_entitlements ORDER BY updated_at DESC LIMIT 20;`

## 4. To‘xtatish / qaytarish

`LG_BILLING_ENABLED` ni olib tashlash → hamma pullik yo‘l 404, ilova to‘lov oynasini ko‘rsatmaydi. Sinovni
alohida to‘xtatish — attestatsiya secretlarini olib tashlash (503 `trial_unavailable`). Batafsil:
`docs/PAID_BACKEND_DEPLOY_CHECKLIST.md` §7.
