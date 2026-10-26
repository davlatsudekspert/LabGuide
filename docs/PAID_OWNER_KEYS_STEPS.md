# EGASI: kalitlarni olish va GitHub Secrets’ga qo‘yish (maxfiy — faqat siz qilasiz)

GitHub → repo `davlatsudekspert/labguide` → Settings → Secrets and variables → Actions → New repository secret.
Kalit qiymatlarini hech kimga/chatga yubormang — to‘g‘ridan-to‘g‘ri shu yerga.

## Apple
1. **In-App Purchase kaliti:** App Store Connect → Users and Access → Integrations → In-App Purchase → “+” → kalit yarating.
   `.p8` faylni FAQAT BIR MARTA yuklab olasiz. Secrets: `APPLE_IAP_KEY_ID` (Key ID), `APPLE_IAP_ISSUER_ID` (Issuer ID),
   `APPLE_IAP_PRIVATE_KEY` (`.p8` fayl matni to‘liq, BEGIN/END qatorlari bilan).
2. **DeviceCheck kaliti:** developer.apple.com → Certificates, Identifiers & Profiles → Keys → “+” → DeviceCheck belgilang →
   yuklab oling. Secrets: `APPLE_DEVICECHECK_KEY_ID`, `APPLE_DEVICECHECK_TEAM_ID` (Membership sahifasidagi Team ID),
   `APPLE_DEVICECHECK_PRIVATE_KEY` (`.p8` matni).
3. **Sandbox tester:** App Store Connect → Users and Access → Sandbox → Testers (alohida email, haqiqiy Apple ID emas).

## Google
1. Play Console → Setup → **API access**: bog‘langan Google Cloud loyihasini ko‘ring (yoki yangi bog‘lang). Cloud Console →
   IAM → Service Accounts → yangi service account (masalan `labguide-billing`) → Keys → JSON yarating.
   Play Console → Users and permissions → service account emailini taklif qiling (Financial data + Manage orders and
   subscriptions). Secret: `GOOGLE_PLAY_SERVICE_ACCOUNT` (JSON to‘liq matni). (`PLAY_INTEGRITY_SERVICE_ACCOUNT` ixtiyoriy.)
2. **Imzo sertifikati SHA-256:** Play Console → App integrity (yoki Setup → App signing) → “App signing key certificate” →
   SHA-256. Secret: `PLAY_INTEGRITY_CERT_SHA256`. Play Integrity API’ni shu Cloud loyihada yoqing.
3. **RTDN (obuna bildirishnomalari):** Cloud Console → Pub/Sub → Topic yarating (`play-rtdn`) → ruxsat: Publisher roli
   `google-play-developer-notifications@system.gserviceaccount.com` ga → Subscription (Push) → endpoint
   `https://labguide-api.davlatsudekspert.workers.dev/v1/billing/google/rtdn` (OIDC: service account + audience). Play Console →
   Monetization setup → Real-time developer notifications → topic nomi `projects/<loyiha-id>/topics/play-rtdn`.
   Secrets: `PLAY_RTDN_AUDIENCE`, `PLAY_RTDN_SERVICE_ACCOUNT` (OIDC uchun service account emaili).
4. **License testers:** Play Console → Settings → License testing → test email’lar.

## Sinov rejimi (Secrets)
`TRIAL_PLATFORMS` = `android`, `LG_BILLING_SANDBOX` = `true`.

## Hammasi tayyor bo‘lgach
Menga xabar bering: `store_check` bilan narx/holatni tekshiraman, so‘ng siz Actions’da `deploy_api` (+ `billing_preview`) ni
BIR marta bosasiz, undan keyin `play_internal` va `testflight` (`pro_preview` + `pro_gating`).
