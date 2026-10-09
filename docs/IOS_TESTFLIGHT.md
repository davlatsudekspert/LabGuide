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
**Settings → Secrets and variables → Actions → New repository secret**. Secret qiymatlarini
GitHub boshqa repodan ko‘chirib bermaydi — ular qayta kiritiladi (nfcx’dagilar bilan bir xil
qiymatlar, bitta Apple jamoasi):

| Secret | Qiymat |
|---|---|
| `ASC_KEY_ID` | App Store Connect API kalit ID |
| `ASC_ISSUER_ID` | Issuer ID |
| `ASC_KEY_P8_BASE64` | `AuthKey_….p8` fayl (base64 yoki matnning o‘zi) |
| `IOS_CERTIFICATE_P12_BASE64` | Apple Distribution sertifikati `.p12` (base64) — nfcx’dagi `NOVA_IOS_CERTIFICATE_BASE64` bilan bir xil |
| `IOS_CERTIFICATE_PASSWORD` | `.p12` paroli — `NOVA_IOS_CERTIFICATE_PASSWORD` bilan bir xil |
| `IOS_TEAM_ID` | ixtiyoriy: `5Z9CT2W378` (sertifikat jamoasi bilan solishtiriladi) |

`.p12` → base64: `base64 -i distribution.p12 | pbcopy` (macOS) yoki
`base64 -w0 distribution.p12` (Linux). Ilova profili secret emas — API’dan olinadi.

### Bundle ID va profil
**Run workflow → mode: testflight, apple_setup: ✓**. Workflow App Store Connect API orqali
`uz.labguide.app` bundle ID ni ro‘yxatdan o‘tkazadi va “LabGuide AppStore CI” profilini
yaratadi. Ilova yozuvi hali yo‘q bo‘lsa, shu yerda aniq xabar bilan to‘xtaydi — bu kutilgan.

### Ilova yozuvi (faqat qo‘lda — API buni qila olmaydi)
App Store Connect → **Apps → + → New App**: platforma iOS, nomi **LabGuide** (band bo‘lsa,
masalan “LabGuide UZ” — qurilmadagi nom baribir LabGuide), asosiy til, Bundle ID
**uz.labguide.app**, SKU (masalan `labguide-ios`).

## 3. TestFlight’ga yuklash

**Run workflow → mode: testflight**. Imzolangan IPA yasaladi, tekshiriladi (bundle ID,
versiya, SDK, entitlements), `altool` (ishlamasa `xcodebuild -exportArchive`) bilan TestFlight’ga yuklanadi va processing holati
kutiladi. Build raqami App Store Connect’dagi oxirgisidan bittaga katta (avtomatik).
App Store review’ga **yuborilmaydi**, reliz **qilinmaydi**.
