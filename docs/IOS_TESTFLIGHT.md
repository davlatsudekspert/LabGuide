# iOS: Mac'siz build va TestFlight (GitHub Actions)

Workflow: `.github/workflows/ci.yml` (“LabGuide CI”). `main` ga har push va PR’da imzosiz
tekshiruv (testlar, Android sinov APK, iOS build) o‘zi ishlaydi.

**Tarix:** 2026-10-09 gacha ilova `davlatsudekspert/nfcx` ichidagi `labguide/` papkasida edi
(D-01, D-34). O‘sha yerdagi run’lar: build — o‘tdi; testflight — sertifikat va API kalit
o‘qildi (Team 5Z9CT2W378), bundle ID / profil bosqichi o‘tdi, lekin App Store Connect’da
`uz.labguide.app` uchun ilova yozuvi yo‘qligi sababli to‘xtadi.

## 1. Imzosiz tekshiruv (secret kerak emas)

**Actions → LabGuide CI → Run workflow** — branch `main`, **mode: build** (yoki shunchaki
`main` ga push). Linux’da `flutter analyze` + testlar, Android sinov APK’lari (artefakt) va
macOS’da imzosiz iOS release build.

## 2. TestFlight uchun bir martalik sozlash

### Secretlar
Yangi repo uchun yangi API kalit (nfcx’dagilardan foydalanilmaydi):

1. App Store Connect → **Users and Access → Integrations → App Store Connect API → Team Keys
   → +**. Nomi masalan `LabGuide CI`, ruxsat **Admin** (bulut sertifikati bilan imzolash
   uchun kerak). `AuthKey_XXXX.p8` faylini yuklab oling — u faqat bir marta beriladi.
2. Shu sahifadan **Issuer ID** va kalitning **Key ID** sini oling.
3. GitHub → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Qiymat |
|---|---|
| `ASC_KEY_ID` | Key ID |
| `ASC_ISSUER_ID` | Issuer ID |
| `ASC_KEY_P8_BASE64` | `.p8` faylning matni (Notepad’da ochib, hammasini nusxalang) yoki base64 |
| `IOS_TEAM_ID` | ixtiyoriy: `5Z9CT2W378` |

`.p12` sertifikat **shart emas**: `IOS_CERTIFICATE_*` secretlari bo‘lmasa, workflow arxivni
imzosiz yig‘adi va eksportda Apple’ning bulutdagi (cloud-managed) Distribution sertifikati
bilan imzolaydi; App Store profilini Xcode o‘zi yaratadi (`-allowProvisioningUpdates`).
O‘z sertifikatingiz bilan imzolamoqchi bo‘lsangiz — `IOS_CERTIFICATE_P12_BASE64` va
`IOS_CERTIFICATE_PASSWORD` qo‘shing (qo‘lda imzo yo‘li).

Kalit public repoda xavfsizmi: secretlar shifrlangan holda saqlanadi, loglarda yashiriladi va
fork’dan kelgan PR’larga berilmaydi; TestFlight rejimini faqat yozish huquqi borlar ishga
tushiradi.

### Bundle ID va profil
**Run workflow → mode: testflight, apple_setup: ✓**. Workflow App Store Connect API orqali
`uz.labguide.app` bundle ID ni ro‘yxatdan o‘tkazadi (qo‘lda imzo yo‘lida “LabGuide AppStore
CI” profilini ham yaratadi). Ilova yozuvi hali yo‘q bo‘lsa, shu yerda aniq xabar bilan to‘xtaydi — bu kutilgan.

### Ilova yozuvi (faqat qo‘lda — API buni qila olmaydi)
App Store Connect → **Apps → + → New App**: platforma iOS, nomi **LabGuide** (band bo‘lsa,
masalan “LabGuide UZ” — qurilmadagi nom baribir LabGuide), asosiy til, Bundle ID
**uz.labguide.app**, SKU (masalan `labguide-ios`).

## 3. TestFlight’ga yuklash

**Run workflow → mode: testflight**. Imzolangan IPA yasaladi, tekshiriladi (bundle ID,
versiya, SDK, entitlements), `altool` (ishlamasa `xcodebuild -exportArchive`) bilan TestFlight’ga yuklanadi va processing holati
kutiladi. Build raqami App Store Connect’dagi oxirgisidan bittaga katta (avtomatik).
App Store review’ga **yuborilmaydi**, reliz **qilinmaydi**.
