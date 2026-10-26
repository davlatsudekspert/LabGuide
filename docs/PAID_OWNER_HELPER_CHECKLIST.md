# Pullik tizim: egasi + yordamchi ish ro‘yxati (2026-10-26)

> Holat: Cloudflare serveri deploy qilingan (migratsiya 0014–0020, `LG_BILLING_ENABLED` yoqilgan, do‘kon kalitlari YO‘Q).
> Test buildlar (`pro_preview`) TestFlight (build 35) va Play ichki trekda. Quyidagilar do‘kon/akkaunt tomonida —
> faqat egasi (yoki egasi ruxsat bergan yordamchi) qila oladi. Kod tomoni tayyor; kalitlar GitHub Secrets’ga
> qo‘yilgach `deploy_api` BIR MARTA qayta ishga tushiriladi (yangi nomlar `ci.yml` “Worker secretlari” qadamiga ulangan).
> Batafsil: `PAID_SANDBOX_RUNBOOK.md`, `PAID_BACKEND_DEPLOY_CHECKLIST.md`.

## 0. Qaror kerak (egasi)
- [ ] Narx nuqtalari: ilovadagi bazaviy narxlar (USD) `ProPricing`da: Talaba 1.49 / 9.99, Ustoz 2.49 / 24.99,
      Mutaxassis 3.49 / 34.99, Premium 4.99 / 49.99 (oy / yil). UZS va boshqa valyuta narxlarini do‘konda tanlaysiz.
- [ ] Bepul sinov: 7 kun, do‘kon “introductory offer” sifatida (rozilikka qarshi pul yechilmaydi).

## 1. Mahsulotlar (8 ta; ID lar aynan shunday) — App Store Connect va Google Play
| Reja | Oylik ID | Yillik ID |
|---|---|---|
| Talaba Pro | `uz.labguide.student.monthly` | `uz.labguide.student.yearly` |
| Ustoz Pro | `uz.labguide.teacher.monthly` | `uz.labguide.teacher.yearly` |
| Mutaxassis Pro | `uz.labguide.specialist.monthly` | `uz.labguide.specialist.yearly` |
| Premium | `uz.labguide.premium.monthly` | `uz.labguide.premium.yearly` |
- [ ] App Store Connect: bitta obuna guruhi, 8 mahsulot, har biriga uz/ru/en nom-tavsif, 7 kunlik introductory offer.
- [ ] Google Play: 8 ta obuna (base plan), 7 kunlik free trial offer. Ilovada: Obuna ekrani + Tiklash + Shartlar/Maxfiylik havolalari bor.

## 2. Apple kalitlari → GitHub Secrets (nomlar)
- [ ] `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY` (App Store Connect → Users and Access → Integrations → In-App Purchase).
- [ ] `APPLE_DEVICECHECK_KEY_ID`, `APPLE_DEVICECHECK_TEAM_ID`, `APPLE_DEVICECHECK_PRIVATE_KEY` (Developer → Keys → DeviceCheck).
- [ ] App Store Server Notifications V2 URL: `https://labguide-api.davlatsudekspert.workers.dev/v1/billing/apple/notifications`
- [ ] Sandbox tester akkauntlari (Users and Access → Sandbox).

## 3. Google kalitlari → GitHub Secrets
- [ ] `GOOGLE_PLAY_SERVICE_ACCOUNT` (JSON; Play Console’da “Financial data/Orders” ruxsati).
- [ ] `PLAY_INTEGRITY_SERVICE_ACCOUNT` (JSON, ixtiyoriy — bo‘lmasa yuqoridagisi), `PLAY_INTEGRITY_CERT_SHA256` (Play Console → App integrity → App signing).
- [ ] RTDN: Pub/Sub topic + push endpoint `…/v1/billing/google/rtdn`; `PLAY_RTDN_AUDIENCE`, `PLAY_RTDN_SERVICE_ACCOUNT` (yoki zaxira `PLAY_RTDN_TOKEN`).
- [ ] License testers (Play Console → Settings → License testing).

## 4. Serverni yoqish (bir marta)
- [ ] GitHub Secrets’ga yuqoridagilar. Sinov uchun `LG_BILLING_SANDBOX` = `true`, `TRIAL_PLATFORMS` = `android` (Apple DeviceCheck sinalgach `android,ios`).
- [ ] Actions → LabGuide CI → `deploy_api` (+ `billing_preview` belgilangan) — BIR marta.
- [ ] Tekshiruv: `GET /v1/billing/status` (app_store/play_store true bo‘lishi kerak).

## 5. Sinov (sandbox) — `PAID_SANDBOX_RUNBOOK.md` §2 matritsasi
- [ ] Sotib olish, tiklash, bekor qilish, muddat tugashi, yangilanish, oflayn; mehmon va akkauntli; 7 kunlik sinov bir martalik.
- [ ] Hamma natija PASS/FAIL yoziladi; real do‘kon sinalmaguncha “sinalgan” deb yozilmaydi.

## 6. Reliz oldidan (Production — alohida ruxsat)
- [ ] Mutaxassis ko‘rigi (ilmiy kontent), huquqshunos ko‘rigi (Shartlar operator nomi, 24 oylik sinov xesh saqlash), RU/UZ ona tili tekshiruvi.
- [ ] `main` ga birlashtirish va Production relizi — faqat egasining alohida ruxsati bilan.
