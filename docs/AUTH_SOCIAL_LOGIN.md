# Google va Apple bilan kirish (D-56) — egasi qadamlari

Email-kod kirishi yoniga ikkinchi usul. Qaror va xavfsizlik dizayni: `docs/DECISIONS.md` **D-56**;
server: `cloudflare/src/social.ts`; ilova: `lib/features/auth/social_auth.dart`,
`lib/features/auth/ui/social_buttons.dart`. Backend umumiy hujjati: `docs/BACKEND_CLOUDFLARE.md`.

**Muhim:** hammasi *ixtiyoriy va o‘chiq* holda yetkaziladi. Secret/variable berilmaguncha
tugmalar ilovada **ko‘rinmaydi**, serverdagi endpointlar `503 not_configured` beradi, TestFlight va
Play buildlari avvalgidek ishlaydi. Pastdagi qadamlarni istalgan tartibda, bittadan yoqsa bo‘ladi.
Android’da Google va Apple bir-biriga bog‘liq emas.

> **⚠ iPhone (App Store 4.8):** iOS’da Google tugmasi **faqat** “Sign in with Apple” tugmasi ham ko‘rinsa
> chiqadi — bu ilovadagi yagona qoida (`visibleSocialProviders`, `lib/features/auth/social_auth.dart`).
> Apple yo‘q bo‘lsa (`LG_APPLE_SIGNIN` false, entitlement IPA’da yo‘q yoki server `apple: false`), iPhone’da
> Google ham **yashiriladi**, faqat email-kod kirishi qoladi; ilova konsolga ogohlantirish yozadi
> (`social: iOS — Sign in with Apple yo'q, shuning uchun Google tugmasi ham yashirildi`).
> **CI (2026-10-24 dan):** `testflight` rejimida Google (iOS) sozlangan bo‘lsa (`LG_GOOGLE_IOS_CLIENT_ID`
> yoki `LG_GOOGLE_CLIENT_ID` bo‘sh emas), lekin Apple o‘chiq bo‘lib qolsa (`LG_APPLE_SIGNIN` `true` emas yoki
> qo‘lda imzo profilida `com.apple.developer.applesignin` yo‘q) — “Sign in with Apple — entitlement qarori”
> qadami **xato bilan to‘xtaydi** (`::error::`, sababi job summary’da): Google’siz-Apple’siz noto‘g‘ri build
> “yashil” bo‘lib chiqmaydi. Tuzatish: App ID’da Sign In with Apple’ni yoqing → profilni qayta yarating →
> `LG_APPLE_SIGNIN=true`; yoki iOS’da Google’ni o‘chiring (ikkala Google variable’ini bo‘shating). Google
> sozlanmagan bo‘lsa — avvalgidek: Apple o‘chiriladi, build davom etadi.

## 0. Qisqacha: qaysi nomlarni qayerga qo‘yasiz

| Nima | Qayerga | Qiymat |
|---|---|---|
| `GOOGLE_CLIENT_IDS` | GitHub **Secret** → Worker secreti | Google **Web** client ID (`…apps.googleusercontent.com`); bir nechta bo‘lsa vergul bilan |
| `LG_GOOGLE_CLIENT_ID` | GitHub **Variable** | o‘sha **Web** client ID (ilovaga `--dart-define` bilan kiradi) |
| `LG_GOOGLE_IOS_CLIENT_ID` | GitHub **Variable** | Google **iOS** client ID (faqat iOS uchun) |
| `APPLE_SIGNIN_TEAM_ID` | GitHub **Secret** | Apple Team ID (10 belgi) |
| `APPLE_SIGNIN_KEY_ID` | GitHub **Secret** | Sign in with Apple kalitining Key ID si (10 belgi) |
| `APPLE_SIGNIN_PRIVATE_KEY` | GitHub **Secret** | `.p8` fayl **matni** (`-----BEGIN PRIVATE KEY-----` … `-----END PRIVATE KEY-----`) |
| `APPLE_SIGNIN_CLIENT_ID` | GitHub Secret (ixtiyoriy) | bo‘sh qoldiring — standart `uz.labguide.app` |
| `APPLE_SIGNIN_SERVICE_ID` | GitHub Secret (ixtiyoriy) | faqat Android’da Apple kerak bo‘lsa (6-bo‘lim) |
| `LG_APPLE_SIGNIN` | GitHub **Variable** | `true` — **faqat** 1-bo‘limdagi App ID imkoniyati yoqilgandan keyin |
| `LG_APPLE_SERVICE_ID` | GitHub Variable (ixtiyoriy) | Android’da Apple uchun Services ID (6-bo‘lim) |

Secretlar: *Settings → Secrets and variables → Actions → Secrets*; variable’lar — shu sahifadagi
*Variables* yorlig‘i. Secret qiymatlari `deploy_api` rejimida `wrangler secret put` orqali **stdin**
bilan beriladi, logga chiqmaydi (bo‘sh bo‘lganlari o‘tkazib yuboriladi — summary’da yoziladi).

## 1. Apple Developer (Sign in with Apple)

1. https://developer.apple.com/account → **Certificates, Identifiers & Profiles → Identifiers**.
2. `uz.labguide.app` App ID’ni oching → **Capabilities** → **Sign in with Apple** belgisini qo‘ying →
   **Edit** → *Enable as a primary App ID* → **Save**.
   - Imkoniyat yoqilgach eski App Store profili yaroqsiz bo‘ladi. CI’da `SIGNING=cloud`
     (App Store Connect API kaliti) bo‘lsa profilni Xcode o‘zi yangilaydi; qo‘lda imzoda
     (`IOS_CERTIFICATE_P12_BASE64`) `testflight` rejimini `apple_setup=true` bilan bir marta
     ishga tushiring (yangi profil yaratadi) yoki profilni portalda qayta yarating.
3. **Keys → “+”** → nom: `LabGuide Sign in with Apple` → **Sign in with Apple** belgisi → **Configure** →
   *Primary App ID* = `uz.labguide.app` → **Save → Continue → Register**.
   - `.p8` faylni **bir marta** yuklab olasiz (qayta yuklab bo‘lmaydi) — xavfsiz joyda saqlang.
   - Sahifadagi **Key ID** (10 belgi) → `APPLE_SIGNIN_KEY_ID`.
4. **Team ID**: sahifaning yuqori o‘ng burchagidagi hisob nomi ostida yoki *Membership details* →
   `APPLE_SIGNIN_TEAM_ID`.
5. `.p8` fayl matnini (BEGIN/END qatorlari bilan) → `APPLE_SIGNIN_PRIVATE_KEY` secretiga to‘liq joylang.
6. **Tartib (TestFlight buzilmasligi uchun):** avval 2-qadam (imkoniyat) va profil yangilanishi,
   **keyin** `LG_APPLE_SIGNIN` variable’ini `true` qiling. Shundan so‘ng `testflight` rejimi
   `ios/Runner/Runner.entitlements` ni IPA’ga qo‘shadi va tugma ilovada paydo bo‘ladi. Agar variable
   `true` bo‘lib, profilda imkoniyat bo‘lmasa (qo‘lda imzo): Google variable’lari **bo‘sh** bo‘lsa — job
   ogohlantirish chiqaradi, entitlement’ni qo‘shmaydi va davom etadi (Apple tugmasi yashirin); Google
   variable’laridan biri **to‘ldirilgan** bo‘lsa — job **xato bilan to‘xtaydi** (4.8, yuqoridagi izoh). Job summary’dagi “Sign in with Apple: entitlement IPA'ga qo'shiladi” qatorini
   tekshiring. Cloud imzoda entitlement IPA’da bo‘lmasa,
   “IPA tekshiruvi” qadami aniq xabar bilan to‘xtaydi — shunda `LG_APPLE_SIGNIN` ni `false` qiling.
7. Mac’da qo‘lda ishlasangiz: Xcode → Runner → *Signing & Capabilities* → **+ Capability → Sign in with Apple**.

## 2. Google Cloud Console (Google bilan kirish)

1. https://console.cloud.google.com → loyiha tanlang/yarating (masalan `LabGuide`).
2. **Google Auth platform** (eski nomi *APIs & Services → OAuth consent screen*):
   - *App name* `LabGuide`, *User support email* va *Developer contact* — `labguide@nfcstore.uz`.
   - *Audience*: **External**; *Publishing status*: **In production** (aks holda faqat “test users”
     kira oladi). Faqat `openid`, `email`, `profile` (sezgir bo‘lmagan) scope’lar — Google tekshiruvi talab qilinmaydi.
   - *Branding*: logotip, **Privacy policy** havolasi (`docs/store/PRIVACY_POLICY.md` nashr manzili),
     shartlar havolasi.
3. **Clients / Credentials → Create client** (uchta alohida client):
   - **Web application** — nom `LabGuide server`. Redirect URI kerak emas. Chiqqan **Client ID** →
     `GOOGLE_CLIENT_IDS` (secret) **va** `LG_GOOGLE_CLIENT_ID` (variable). Server tokenning `aud` ini shu ro‘yxat bilan
     solishtiradi; ilova uni `serverClientId` sifatida beradi.
   - **Android** — Package name `uz.labguide.app`, **SHA-1** barmoq izi. Ikkita (kerak bo‘lsa uchta) client
     yarating, har biriga o‘z SHA-1:
     - *Upload keystore*: `keytool -list -v -keystore upload.jks -alias <alias>` → `SHA1:` va `SHA256:`.
     - *Play app signing kaliti* (do‘kondan o‘rnatilgan ilovani imzolaydi): Play Console → LabGuide →
       **Test and release → App integrity → App signing** → *App signing key certificate* → SHA-1 va SHA-256.
       **Bu SHA-1 siz Play’dan o‘rnatilgan ilovada Google kirishi ishlamaydi.**
     - *(Ixtiyoriy)* lokal debug kalit: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android`.
     - SHA-256 qiymatlarini ham yozib qo‘ying (Digital Asset Links / keyingi sozlamalar uchun); OAuth Android client
       faqat SHA-1 so‘raydi.
   - **iOS** — Bundle ID `uz.labguide.app`. Chiqqan **Client ID** → `LG_GOOGLE_IOS_CLIENT_ID` (variable).
     CI shu qiymatdan `Info.plist` ga qaytish sxemasini (`com.googleusercontent.apps.<id>`) runner’dagi nusxaga yozadi
     (repoda hech narsa o‘zgarmaydi). Variable yo‘q bo‘lsa iOS’da Google tugmasi chiqmaydi.
4. Hammasi bo‘lgach: GitHub’da `GOOGLE_CLIENT_IDS` (secret), `LG_GOOGLE_CLIENT_ID`, `LG_GOOGLE_IOS_CLIENT_ID` (variable).
   Client ID lar sir emas (ilova ichida ochiq), shuning uchun variable. Hech qanday *client secret* ishlatilmaydi.

## 3. Yoqish tartibi

1. 1–2-bo‘limlarda kerakli qismni bajaring, GitHub’ga nomlarni kiriting.
2. **Actions → LabGuide CI → Run workflow → `deploy_api`**: D1 migratsiyasi `0008_social_login.sql`
   (`auth_identities`, `auth_replay`) qo‘llanadi, secretlar o‘rnatiladi. Summary’da har secret uchun
   “o‘rnatildi / berilmagan” yoziladi (`APPLE_SIGNIN_*` to‘liq bo‘lmasa — ogohlantirish, Apple o‘chiq qoladi).
3. Tekshiring: `curl https://labguide-api.<sub>.workers.dev/v1/auth/providers` →
   `{"google":true,"apple":true,"apple_web":false}` (sozlanganiga qarab).
4. Yangi build: `build` / `testflight` / `play_internal`. Variable’lar `--dart-define` bilan kiradi.

## 4. Qanday sinash

Avtomatik (kodda): `cd cloudflare && npm ci && npm test && npx tsc` — `test/social.test.ts` soxta RSA
kalitlar bilan imzolangan tokenlarda: to‘g‘ri, noto‘g‘ri `aud`/`iss`, muddati o‘tgan, noto‘g‘ri nonce, tasdiqlanmagan
email, mavjud hisobga bog‘lash, Apple private relay, takroriy ishlatish, kalit almashtirish, hisobni o‘chirish va revoke.
Ilova: `flutter test test/unit/social_auth_test.dart test/widget/social_auth_flow_test.dart`.

Haqiqiy kalitlar bilan qo‘lda (birinchi marta **egasi** qiladi — bularni bu yerda sinab bo‘lmagan):
1. **Bog‘lash (bitta email = bitta hisob):** avval email-kod bilan `siz@gmail.com` bilan kiring, guruhga qo‘shiling yoki
   rol tanlang; chiqing; **Google** bilan o‘sha gmail orqali kiring → ma’lumotlaringiz (rol, guruh) joyida bo‘lishi kerak,
   yangi hisob ochilmasligi kerak.
2. **Apple:** TestFlight’da “Apple bilan kirish” → Face ID → email ulashish yoki **Hide My Email** (private relay) —
   ikkalasi ham ishlashi kerak. Chiqib, yana Apple bilan kiring: o‘sha hisob.
3. **Mehmon:** “Mehmon sifatida davom etish” har ikki ekranda ishlashi kerak (kirish majburiy emas).
4. **Hisobni o‘chirish (Apple):** Profil → Maxfiylik → *Hisobni o‘chirish* → Apple tasdig‘i so‘raladi → o‘chirilgach
   iPhone *Sozlamalar → Apple ID → Parol va xavfsizlik → Apple bilan kirish ishlatadigan ilovalar* ro‘yxatida LabGuide
   **qolmasligi** kerak (revoke ishlagan). Ro‘yxatda qolsa — `audit_log` da `apple_revoke` natijasini ko‘ring:
   `npx wrangler d1 execute labguide-db --remote --command "SELECT at, details FROM audit_log WHERE action='apple_revoke' ORDER BY id DESC LIMIT 5"`.
5. **Android:** internal testdan o‘rnating (Play app signing SHA-1 qo‘shilgan bo‘lishi shart), Google tugmasi → hisob tanlash.
6. Tugma bekor qilinsa (oynani yopish) hech qanday xato chiqmasligi kerak.

## 5. Maxfiylik siyosati va do‘kon deklaratsiyalari

Yangilandi (shu o‘zgarish bilan): `docs/store/PRIVACY_POLICY.md` (uz/ru/en — Google va Apple kirish provayderi sifatida,
nima olinadi, nima saqlanadi), `docs/store/APP_STORE.md` (6- va 12-bo‘limlar), `docs/store/PLAY_CONSOLE_UPLOAD.md`.
Qisqacha:
- **Provayderdan olinadi:** ID token — `sub` (provayderdagi hisob identifikatori), `email`, `email_verified`. Token serverda
  tekshirilib **tashlanadi** (saqlanmaydi). Ism va rasm so‘ralmaydi/saqlanmaydi (Apple’dan faqat `email` scope).
- **Bazaga yoziladi:** identitet (`provider`, `sub`, ichki hisob id, vaqt); email avvalgidek faqat HMAC-hash + niqoblangan ko‘rinish;
  takroriy ishlatishga qarshi token belgisining hashi (token muddatigacha, kunlik tozalanadi).
- **Yangi ma’lumot toifasi yo‘q:** App Store *App Privacy* jadvalida Email Address va User ID allaqachon bor;
  Play *Data safety*’da ham. Faqat **Play Console → App content → Data safety → Account creation methods** (agar so‘ralsa)
  qatoriga *OAuth* va *Other authentication (email kodi)* ni belgilang.
- **App Store 4.8:** Apple tugmasi Google’dan oldin va bir xil o‘lchamda; iOS’da Google faqat Apple bilan birga
  ko‘rinadi (ilova qoidasi, testlar: `test/unit/social_auth_test.dart`, `test/widget/social_ios_parity_test.dart`);
  email kodi ham bor; 5.1.1(v): hisobni ilova ichida o‘chirish +
  Apple tokenini bekor qilish. App Review izohiga yozing: “Sign in with Apple is offered next to Google and email-code
  sign-in; guest mode needs no sign-in; account deletion: Profile → Privacy → Delete account.”

## 6. Android’da Apple (ixtiyoriy, hozircha o‘chiq)

Android’da Apple ichki brauzer orqali (veb-oqim) ishlaydi va **Services ID** + haqiqiy domen tasdig‘ini talab qiladi
(Apple Services ID uchun domen egaligini tasdiqlashni — verification fayl — so‘rashi mumkin; `workers.dev` subdomenida buni bajarish qiyin). Shuning uchun Android’da
Apple tugmasi **standart holatda yashirin**. Kerak bo‘lsa: o‘z domeningizni Worker’ga ulang → Identifiers → Services IDs →
`uz.labguide.app.service` → *Sign in with Apple* sozlash (Primary App ID, domen, Return URL
`https://<domen>/v1/auth/apple/callback`) → `APPLE_SIGNIN_SERVICE_ID` (secret) va `LG_APPLE_SERVICE_ID` (variable). Server tomoni
(`/v1/auth/apple/callback`, qo‘shimcha `aud`) tayyor; Android real qurilmada sinalmagan.

## 7. Nima ishlamasa

| Belgi | Sabab |
|---|---|
| Tugma umuman yo‘q | variable/secret berilmagan, server `providers` da `false`, yoki platforma qo‘llamaydi (Apple: Android; Google iOS: `LG_GOOGLE_IOS_CLIENT_ID` yo‘q) |
| iPhone’da Google tugmasi yo‘q, Android’da bor | iPhone’da Apple tugmasi yo‘q — 4.8 qoidasi Google’ni ham yashiradi; `LG_APPLE_SIGNIN`, App ID imkoniyati va entitlement’ni tekshiring |
| Google: “Kirib bo‘lmadi”, Play’dan o‘rnatilganda | Play app signing SHA-1 Android client’ga qo‘shilmagan |
| Google: server `401 invalid_token` | `GOOGLE_CLIENT_IDS` da **Web** client ID yo‘q (ilova `serverClientId` = `LG_GOOGLE_CLIENT_ID`) |
| Apple: `401 invalid_token` | tokenning `aud` i `uz.labguide.app` emas (`APPLE_SIGNIN_CLIENT_ID` noto‘g‘ri berilgan) |
| iOS build’da Apple tugmasi bor, bosilganda xato | entitlement IPA’da yo‘q — “IPA tekshiruvi” bunga yo‘l qo‘ymaydi; `LG_APPLE_SIGNIN=false` qiling |
| `403 email_not_verified` / `400 email_required` | provayder emailni tasdiqlanmagan/bermagan deb ko‘rsatdi — foydalanuvchi email kodidan foydalanadi |
| `502 provider_unavailable` | Google/Apple kalit manziliga yetib bo‘lmadi; keyin o‘zi tuzaladi (eski kesh ishlatiladi) |

**Qaytarish:** `GOOGLE_CLIENT_IDS` va/yoki `APPLE_SIGNIN_*` secretlarini o‘chirib `deploy_api` ni qayta ishga tushiring —
endpointlar `503`, tugmalar yo‘qoladi; email-kod kirishi va mavjud hisoblar ta’sirlanmaydi (bog‘langan identitetlar
bazada qoladi).
