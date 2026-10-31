# Pro bepul sinovi — suiiste’molga qarshi eslatmalar (D-74 → D-77 addendum, 2026-10-25)

> Holat: **o‘chiq**. Hech narsa deploy qilinmagan. `LG_BILLING_ENABLED` o‘chiq (yo‘llar 404). Haqiqiy qurilma
> attestatsiyasi tekshiruvchilari endi kodda bor (`cloudflare/src/attestation.ts`: Play Integrity, DeviceCheck),
> lekin secretlar sozlanmagan → sinov **`503 trial_unavailable`** (fail closed), ilova tugmani ko‘rsatmaydi.
> Google/Apple serverlari bilan haqiqiy so‘rov va qurilmada sinov — **NOT VERIFIED** (faqat soxta fetch va
> sintetik tokenlar bilan unit testlar). `0016`/`0019` — faqat fayl.

## 1. Maqsad va qoida (bitta sinov)
- **30 kun** (D-80, 2026-10-31; avval 7 kun — D-76/D-77), kartasiz, avtomatik pullik emas; faqat SERVER qaror qiladi va faqat SERVER soati.
- **Bir marta**: bir hisobga, bir kanonik emailga va bir qurilmaga (unikal indekslar). Hisob o‘chirib qayta
  ro‘yxatdan o‘tish sinovni qaytarmaydi (yozuv 24 oy saqlanadi, hisobdan uziladi).
- **Bitta sinov = bitta reja**: foydalanuvchi tanlagan reja (Talaba / Ustoz / Mutaxassis / Premium) 30 kunga
  ochiladi; boshqa reja sinovi keyin YO‘Q (`trial_already_used`). Reja ruxsati (D-74 (f)): ustoz paneli bor reja
  — serverda ustoz (`teacher_accounts`), Lab bor reja — tasdiqlangan mutaxassis; Premium — ikkalasi.
- Holat mashinasi (`GET /v1/billing/trial`): `not_started` → `active` (start) → `expired` (`now >= expires_at`,
  server soati). `expired` dan hech qachon qayta boshlanmaydi. 30 kundan keyin faqat pullik funksiyalar yopiladi;
  Free va saqlangan ma’lumot qoladi.
- Mijoz yuborgan vaqt (`started_at`, `now`, `days`, `Date` sarlavhasi) O‘QILMAYDI (test:
  `trial_antiabuse.test.ts` “clock tampering”).

## 2. Oqim
1. Ilova: hisobga kirgan foydalanuvchi; tugma faqat `GET /v1/billing/status` → `trial.<platforma>` = true
   (platforma `TRIAL_PLATFORMS` da VA shu platforma tekshiruvchisi sozlangan) VA `PlatformDeviceAttestor.available`.
2. `POST /v1/billing/trial/challenge {platform}` → 32 baytli nonce (5 daqiqa, hisobga bog‘langan, SHA-256).
3. Ilova (`lib/core/entitlements/platform_device_attestor.dart`, platforma kanali `uz.labguide.app/attestation`):
   - **Android** (`MainActivity.kt`, `com.google.android.play:integrity`): classic Play Integrity so‘rovi;
     Integrity nonce = `base64url(SHA-256("labguide-trial-v1|<nonce>|<ANDROID_ID>"))`; `device_id` = ANDROID_ID.
   - **iOS** (`AppDelegate.swift`): `DCDevice.generateToken` (DeviceCheck); `device_id` = Keychain’dagi tasodifiy UUID.
4. `POST /v1/billing/trial/start {tier, email, attestation: {platform, token, nonce, device_id}}`. Server tartibi:
   sessiya → biror tekshiruvchi sozlanganmi (503 `trial_unavailable`) → hisob/IP limiti → reja / attestatsiya
   tahlili → platforma ruxsati (403) → shu platforma sozlanganmi (503) → email = hisob emaili (403
   `email_not_verified`) → bloklangan domen (403 `email_domain_not_allowed`, ixtiyoriy ro‘yxat) → reja ruxsati
   (403 `plan_not_allowed`) → amaldagi do‘kon obunasi (409 `already_subscribed`, do‘kon sinovi ham) → hisob /
   kanonik email (409) → IP tarmog‘i limitlari (429) → nonce (400 `invalid_nonce`, bir martalik) → attestatsiya
   tokeni takrori (403) → tekshiruvchi (403 `device_attestation_failed` / 502 `device_attestation_unavailable`)
   → platforma bayrog‘i / qurilma kaliti (409) → yozuv (unikal indekslar, poyga) → `markUsed` → jurnal → 201.

## 3. Qurilma tekshiruvi — nima persist qiladi (halol)

| Platforma | Mexanizm | Doimiy belgi | Qayta o‘rnatish | Factory reset | Tekshirilgan |
|---|---|---|---|---|---|
| Android | Play Integrity verdikti: `PLAY_RECOGNIZED`, paket, imzo sertifikati SHA-256, `MEETS_DEVICE_INTEGRITY` (yoki STRONG), `LICENSED`, `timestampMillis` ≤ 10 daqiqa, nonce | Verdikt doimiy qurilma ID **bermaydi**. Ilova darajasidagi **ANDROID_ID** (Android 8+: imzo kaliti + foydalanuvchi + qurilma) nonce’ga bog‘lanadi → HMAC (`device_key`) | ANDROID_ID **o‘zgarmaydi** → 409 | ANDROID_ID **o‘zgaradi** → yangi sinov (QOLGAN XAVF) | unit test (soxta Google API); qurilmada NOT VERIFIED |
| Android | Play Integrity “device recall” (beta) | zavod sozlamasidan keyin ham saqlanadigan bitlar (Google va’dasi) | — | — | API shakli rasmiy hujjat bilan TEKSHIRILMADI → **kod YO‘Q** |
| iOS | DeviceCheck ikki bit (Apple serverida, qurilma bo‘yicha): bit0 = “sinov ishlatilgan”, bit1 = zaxira | Apple bitlari + Keychain UUID (HMAC) | Apple biti **saqlanadi** (Apple maqsadi); Keychain odatda saqlanadi | Apple bitining saqlanishi rasmiy hujjat bilan shu ishda TEKSHIRILMADI (NOT VERIFIED) | unit test (soxta Apple API); qurilmada NOT VERIFIED; Swift kompilyatsiya qilinmagan |
| iOS | App Attest | kalit qayta o‘rnatishda yangilanadi — doimiy emas | — | — | **NOT DONE** (CBOR/x509/counter tekshiruvi yozilmadi) |

Nega DeviceCheck: “bir marta” uchun Apple tomonida saqlanadigan holat kerak; App Attest bunday holat bermaydi
(faqat ilova haqiqiyligini isbotlaydi). DeviceCheck tokeni nonce’ni bog‘lamaydi — shuning uchun token SHA-256
bir martalik (`pro_trial_attest_tokens`; saqlash muddati `ATTEST_TOKEN_RETENTION_MS`) va DeviceCheck so‘rovi Apple’da token haqiqiyligini
tekshiradi. iOS sinovi baribir standart **o‘chiq** (`TRIAL_PLATFORMS=android`, Apple 3.1.1 javobigacha).

## 4. Boshqa nazoratlar

| Nazorat | Nimani to‘xtatadi | Nimani to‘xtatmaydi |
|---|---|---|
| Hisob shart (sessiya) | mehmon rejimida cheksiz sinov | — |
| Email = hisob emaili (OTP / provayder `email_verified`) | birovning emailini yozish | ko‘p haqiqiy email |
| Kanonik email (Gmail nuqta/`+teg`, googlemail; MS/Yandex `+teg`; `yandex.*`/`ya.ru` → `yandex.ru`) | `ali.v+1@gmail.com` va h.k. | boshqa provayder aliaslari, yangi email |
| Bloklangan domenlar `TRIAL_BLOCKED_EMAIL_DOMAINS` (ixtiyoriy, subdomen bilan) | egasi kiritgan bir martalik pochta xizmatlari | **repoda tekshirilgan ro‘yxat YO‘Q** (o‘ylab topilmadi) — standart bo‘sh |
| IP tarmog‘i (IPv4 /24, IPv6 /48; HMAC): yaratilganiga < 24 soat hisoblar sutkasiga 3 ta, har qanday hisob 20 ta MUVAFFAQIYATLI sinov | “ko‘p hisob ochib darhol sinov” bir tarmoqdan | ko‘p tarmoq / VPN; **ASN cheklovi ATAYLAB yo‘q** (milliy operatorlar CGNAT — halol foydalanuvchilar to‘silardi) |
| Urinish limitlari (hisob 5/soat, IP 30/soat, challenge 20/soat) | ommaviy urinish | — |
| Nonce bir martalik + Integrity nonce’ga bog‘langan + token takrori | token qayta yuborish, boshqa hisobga o‘tkazish | — |
| Poyga (parallel start) | unikal indekslar → aynan bitta 201 | — |
| Amaldagi do‘kon obunasi (do‘kon sinov davri ham) | sinovni obuna ustiga qo‘yish | — |

## 5. Ikki xil “bepul davr” (stacking siyosati)

| | LabGuide server sinovi (shu hujjat) | Do‘kon kirish taklifi (Apple Introductory Offer / Play free-trial offer) |
|---|---|---|
| Kim qaror qiladi | server (hisob + email + qurilma) | do‘kon (Apple ID obuna guruhiga / Google hisobi) |
| Karta, avtomatik pullik | yo‘q / yo‘q | kerak / ha (bekor qilinmasa) |
| Standart holat | kod tayyor, secretsiz o‘chiq | **yaratilmaydi** (egasi qarori D-76); Play’da ilova taklifni tanlamaydi (`storeIntroOffersAllowed = false`) |
| Ilova matni | “to‘lov usuli yo‘q, pul yechilmaydi” | FAQAT do‘kon ma’lumotidan: “{davr} bepul, keyin {narx}” (yoki chegirma narxi), qotirilgan kun/narx yo‘q |
Qoidalar (`lib/core/entitlements/trial_policy.dart`):
- Do‘kon “haqli emas” desa — taklif umuman ko‘rsatilmaydi. Server sinovini ishlatgan foydalanuvchiga ilova o‘zi
  “yana bir hafta bepul” demaydi; faqat do‘kon haqli desa do‘kon shartlari + izoh “bu App Store / Google Play
  taklifi, LabGuide bepul sinovidan alohida” (`proPayStoreOfferNote`).
- App Store: haqli foydalanuvchiga Apple taklifni O‘ZI qo‘llaydi — shuning uchun bor bo‘lsa shartlar har doim
  ko‘rsatiladi. Play: faqat egasi yoqsa (`storeOffersAllowed`), aks holda base plan.
- Server: do‘kon sinov davridagi obuna (`period_type = trial`; Apple `offerType=1` + `FREE_TRIAL`, Play
  `offerPhase.freeTrial` / v1 `paymentState=2`) — to‘liq huquq; shu paytda server sinovi boshlanmaydi
  (`already_subscribed`). Teskari tartib (avval server sinovi, keyin do‘kon taklifi) — do‘kon muvofiqligiga
  bog‘liq; bu ataylab cheklanmagan (to‘lovchi foydalanuvchi), lekin ilova matni ularni ajratadi.
- Xarid faqat foydalanuvchi bosganda va do‘konning o‘z tasdiq oynasidan keyin; sinov kodi hech qachon xarid
  boshlamaydi.

## 6. Qolgan xavflar (halol)
- **Factory reset (Android)** → yangi ANDROID_ID → yangi sinov (yangi email + hisob bilan). Device recall
  ulanmaguncha yopilmaydi.
- Yangi/boshqa telefon, qurilma fermalari, ishonchli (MEETS_DEVICE_INTEGRITY) lekin hook qilingan qurilmalar,
  Play Integrity chetlab o‘tish xizmatlari.
- iOS: Keychain UUID va DeviceCheck bitlarining factory reset / qurilma sotilgandan keyingi xulqi tekshirilmagan;
  xato musbat: ishlatilgan iPhone’ni sotib olgan yangi egasi sinov ololmasligi mumkin (bit0 qoladi) — 24 oy emas,
  bit Apple’da cheksiz (biz tozalamaymiz; kerak bo‘lsa `update_two_bits` bilan qo‘lda).
- Huawei/AOSP (Play xizmatlarisiz) va web — attestatsiya yo‘q → sinov berilmaydi.
- `LG_SERVER_SECRET` almashtirilsa barcha `email_key`/`device_key` mos kelmaydi (sinov qayta ochiladi).
- IP tarmog‘i limiti CGNAT ortidagi halol foydalanuvchini kamdan-kam to‘sishi mumkin (faqat yangi hisoblar,
  sutkasiga 3) — 429 da ilova keyinroq urinishni taklif qiladi.
- iOS App Review 3.1.1: server bergan kartasiz sinov — Apple javobigacha iOS’da o‘chiq.

## 7. Maxfiylik
Saqlanadi: sinov id, hisob id (o‘chirilganda NULL), daraja, platforma, boshlanish/tugash, `email_key`,
`device_key` (HMAC-SHA256, server kaliti), `account_deleted_at`, `retain_until`; attestatsiya tokeni xeshi
(qisqa muddat — `ATTEST_TOKEN_RETENTION_MS`, takrorni aniqlash uchun). Saqlanmaydi: email, ANDROID_ID / Keychain UUID (xom), attestatsiya tokeni, IP
(limit kalitlari — IP/tarmoq HMAC, sutkalik). DeviceCheck: Apple serverida qurilmaga 1 bit. Maxfiylik siyosati va
App Privacy (“Device ID — fraud prevention”) / Data safety (“Device or other IDs”) — matnlar agenti va egasi.

## 8. Kodda qayerda
- Server: `cloudflare/src/attestation.ts` (Play Integrity, DeviceCheck, `platformVerifier`), `trial.ts` (oqim,
  holat, limitlar, kanonik email), `jwtsign.ts`, `index.ts` (ulash), migratsiyalar `0016`, `0018`, `0019`.
  Testlar: `test/attestation.test.ts`, `test/trial.test.ts`, `test/trial_antiabuse.test.ts`, `test/guards.test.ts`.
- Ilova: `platform_device_attestor.dart`, `device_attestor.dart`, `entitlement_service.dart` (`startTrial`),
  `trial_policy.dart`; native `android/app/src/main/kotlin/uz/labguide/app/MainActivity.kt`,
  `ios/Runner/AppDelegate.swift`. Testlar: `test/unit/platform_device_attestor_test.dart`,
  `test/unit/paid_srv_entitlements_test.dart`, `test/unit/trial_entitlement_test.dart`.
