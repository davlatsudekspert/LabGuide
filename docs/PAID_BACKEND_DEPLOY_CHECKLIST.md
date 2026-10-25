# Pullik backend: deploy oldidan tekshiruv ro‘yxati (`paid/srv`, D-77 addendum)

> **DEPLOY QILINMAGAN va bu hujjat bo‘yicha ham egasining yozma ruxsatisiz QILINMAYDI.**
> Bu ishda faqat lokal tekshiruv bajarildi: `npx tsc --noEmit` va `npx vitest run` (Miniflare ichidagi lokal D1).
> `wrangler deploy`, `wrangler d1 migrations apply --remote`, `wrangler secret put`, CI `deploy_api` — ISHGA
> TUSHIRILMAGAN. Apple / Google / Cloudflare API’lariga haqiqiy so‘rov yuborilmagan. Haqiqiy do‘kon xaridi
> sinalmagan (NOT VERIFIED).

## 0. Ruxsat va tartib

1. Egasi yozma ruxsat beradi (sana, kim, qaysi muhit: **avval test Worker + test D1**, keyin production).
2. Bepul reliz (`main`) do‘konda tasdiqlangan bo‘lsin; pullik build shu tarmoqdan alohida yig‘iladi.
3. Har qadamdan keyin `GET /v1/health` va `GET /v1/billing/status` (faqat `LG_BILLING_ENABLED=true` muhitda).

## 1. Migratsiyalar (tartib bilan, qayta tahrirlanmaydi)

| # | Fayl | Nima qiladi | Qaytarish |
|---|---|---|---|
| 1 | `0014_billing.sql` | `entitlements` (do‘kon obunalari) — 0003 dagi bo‘sh jadval o‘rniga | jadvalni o‘chirish (ma’lumot yo‘qoladi) |
| 2 | `0015_pro_grants.sql` | admin bergan Pro | `DROP TABLE pro_grants` |
| 3 | `0016_pro_trials.sql` | sinov yozuvlari (HMAC), nonce’lar | `DROP TABLE pro_trials, pro_trial_challenges` |
| 4 | `0017_billing_notifications.sql` | ASSN v2 / RTDN takror jurnali | `DROP TABLE billing_notifications` |
| 5 | `0018_premium_tier.sql` | `premium` darajasi (0015/0016 jadvallari qayta quriladi) | 0018 dan oldingi zaxira nusxadan |
| 6 | **`0019_trial_attest_guest.sql`** (yangi) | `pro_trial_attest_tokens` (attestatsiya tokeni takrori, faqat SHA-256), `entitlements` ga `period_type` / `auto_renew` / `pending_product_id` ustunlari, `store_guest_entitlements` + `store_guest_devices` (mehmon xaridlari) | yangi jadvallarni `DROP`; qo‘shilgan ustunlar qoladi (SQLite — zararsiz, standart qiymatli) |

Buyruqlar (faqat ruxsatdan keyin, **avval test bazada**):
```
cd cloudflare
npx wrangler d1 export <test-db> --remote --output backup-before-0019.sql     # zaxira
npx wrangler d1 migrations apply <test-db> --remote                            # 0014…0019
npx wrangler d1 migrations list <test-db> --remote                             # hammasi "applied"
```
Lokal tekshiruv (ruxsat shart emas): `npx wrangler d1 migrations apply labguide --local` va `npx vitest run`
(test muhiti hamma migratsiyani `readD1Migrations` bilan qo‘llaydi; `migration_0018.test.ts` eski jadval ustida).

## 2. Worker o‘zgaruvchilari va secretlar (faqat NOMLAR — qiymat repoga yozilmaydi)

`wrangler.toml` **o‘zgartirilmaydi** (qorovul: `cloudflare/test/guards.test.ts` — `LG_BILLING_ENABLED`,
`LG_BILLING_SANDBOX`, `TRIAL_PLATFORMS=…ios`, Play Integrity / DeviceCheck kalitlari faylda bo‘lmasligi kerak).
Hammasi `wrangler secret put <NOM>` (yoki Dashboard → Worker → Settings → Variables) orqali.

| Nom | Turi | Kerak bo‘lganda | Bo‘lmasa |
|---|---|---|---|
| `LG_BILLING_ENABLED` | var (`true`) | pullik yo‘llarni ochish | barcha `/v1/billing/*`, `/v1/pro/*` — 404 |
| `LG_BILLING_SANDBOX` | var (`true`) | FAQAT test Worker’da | sandbox xaridi `403 sandbox_not_allowed` |
| `APPLE_IAP_KEY_ID`, `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_PRIVATE_KEY` | secret | App Store Server API | `503 store_verifier_not_configured` |
| `APPLE_BUNDLE_ID` | var | standart `uz.labguide.app` emas bo‘lsa | — |
| `APPLE_SUBSCRIPTION_GROUP_ID` | var | ixtiyoriy guruh tekshiruvi | tekshirilmaydi |
| `GOOGLE_PLAY_SERVICE_ACCOUNT` | secret (JSON) | Play Developer API (+ Play Integrity zaxira) | `503 store_verifier_not_configured` |
| `GOOGLE_PLAY_PACKAGE` | var | standart `uz.labguide.app` emas bo‘lsa | — |
| `PLAY_RTDN_AUDIENCE`, `PLAY_RTDN_SERVICE_ACCOUNT` | var | RTDN Pub/Sub OIDC (tavsiya) | — |
| `PLAY_RTDN_TOKEN` | secret | RTDN URL tokeni (zaxira) | ikkalasi yo‘q — RTDN `503` |
| **`PLAY_INTEGRITY_SERVICE_ACCOUNT`** | secret (JSON) | Android sinovi (scope `playintegrity`) | `GOOGLE_PLAY_SERVICE_ACCOUNT` ishlatiladi |
| **`PLAY_INTEGRITY_CERT_SHA256`** | var | ilova imzo sertifikati SHA-256 (Play Console → App integrity → App signing) | Android sinovi `503 trial_unavailable` |
| **`APPLE_DEVICECHECK_KEY_ID`, `APPLE_DEVICECHECK_TEAM_ID`, `APPLE_DEVICECHECK_PRIVATE_KEY`** | secret | iOS sinovi (DeviceCheck kaliti .p8) | iOS sinovi `503 trial_unavailable` |
| **`APPLE_DEVICECHECK_ENV`** | var | `development` — faqat Xcode/dev build | production host |
| `TRIAL_PLATFORMS` | var | `android` (standart); `android,ios` — faqat Apple javobidan keyin | iOS `403 trial_not_available_on_platform` |
| **`TRIAL_BLOCKED_EMAIL_DOMAINS`** | var | ixtiyoriy, egasi tekshirgan bir martalik domenlar | ro‘yxat yo‘q (repoda tekshirilgan ro‘yxat YO‘Q) |
| `APPLE_ROOT_CA_SHA256` | var | faqat Apple root almashtirsa | Apple Root CA - G3 pin |
| `LG_SERVER_SECRET` | secret | **o‘zgartirilmaydi** — barcha HMAC (email, sinov, mehmon qurilmasi, mehmon token imzosi) shundan | almashtirilsa sinov/mehmon yozuvlari mos kelmaydi |

CI (`deploy_api`) faqat ma’lum secretlarni o‘tkazadi — yangi nomlar (qalin) CI ga qo‘shilmagan (bu ishda GitHub
Actions fayllariga tegilmadi). Egasi yoki keyingi dev: workflow’ga qo‘shish yoki `wrangler secret put` bilan qo‘lda.

## 3. `wrangler.toml` farqi

Bu tarmoqda **farq yo‘q**: yangi o‘zgaruvchilar `[vars]` ga yozilmaydi (secret yoki Dashboard). Cron
(`17 22 * * *`) avvalgidek; kunlik tozalash bayroq yoqilganda qo‘shimcha ravishda muddati o‘tgan
`pro_trial_attest_tokens` qatorlarini (`ATTEST_TOKEN_RETENTION_MS`), nonce’larni, saqlash muddati o‘tgan
yozuvlarni va eski bildirishnoma id’larini o‘chiradi.

## 4. Do‘kon tomonidagi URL’lar (egasi konsolda)

- App Store Connect → App → App Store Server Notifications → **Version 2**:
  production URL `https://<worker>/v1/billing/apple/notifications`, sandbox URL — test Worker’ning o‘sha yo‘li.
- Google Cloud Pub/Sub → topic → push subscription → endpoint `https://<worker>/v1/billing/google/rtdn`
  (OIDC: service account = `PLAY_RTDN_SERVICE_ACCOUNT`, audience = `PLAY_RTDN_AUDIENCE`); Play Console →
  Monetization setup → Real-time developer notifications → topic.
- Play Console → App integrity → Play Integrity API → Google Cloud loyihasini bog‘lash (service account’ga
  Play Integrity API ruxsati).
- Apple Developer → Keys → DeviceCheck yoqilgan kalit (.p8).

## 5. Deploydan oldin lokal tekshiruv (bu ishda bajarilgan)

```
cd cloudflare && npx tsc --noEmit && npx vitest run      # 2026-10-25: 28 fayl, 399 test PASS
flutter analyze                                           # xato yo‘q
```
`wrangler dev` (lokal) — ixtiyoriy; bu ishda ishga tushirilmadi.

## 6. Deploydan keyin (test Worker) — tekshiruv

1. `GET /v1/billing/status` → `app_store`/`play_store` true (kalitlar bilan), `trial.android` true faqat
   Play Integrity sozlangan bo‘lsa, `guest.purchase_plans` = `["student","specialist"]`.
2. `docs/PAID_SANDBOX_RUNBOOK.md` matritsasi.
3. Loglar: `npx wrangler tail <worker>` — `attestation rejected <sabab>`, `billing resync`, `guest resync`,
   `attestation verify error` (token / email hech qachon logga yozilmaydi).

## 7. Qaytarish (rollback)

1. Eng tez: `LG_BILLING_ENABLED` ni o‘chirish → barcha pullik yo‘llar 404 (ilova to‘lov oynasini ko‘rsatmaydi,
   hamma imkoniyat ochiq — `ProGatePolicy.gated` bo‘sh bo‘lsa ham).
2. Faqat sinovni to‘xtatish: `PLAY_INTEGRITY_CERT_SHA256` / DeviceCheck secretlarini olib tashlash → `503
   trial_unavailable` (fail closed), mavjud sinovlar muddatigacha qoladi.
3. Kod: oldingi Worker versiyasiga `wrangler rollback` (Cloudflare versiyalari) — ruxsat bilan.
4. Ma’lumot: 1-bo‘limdagi zaxira (`d1 export`) dan; 0019 jadvallarini `DROP` qilish xavfsiz (faqat yangi
   ma’lumot).
