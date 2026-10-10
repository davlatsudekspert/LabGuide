# Google Play Console: birinchi AAB'ni yuklash (ichki test)

Maqsad: LabGuide'ni Play Console'da yaratish va imzolangan AAB'ni **Internal testing** (ichki test)
trekiga qo'lda yuklash. **Production'ga yubormang.** Ommaviy reliz bu hujjatda yo'q.

## 0. Tayyor fayl

| Narsa | Qiymat |
|---|---|
| Fayl | `dist/LabGuide-0.1.0-20.aab` (repoga kirmaydi; `/dist/` .gitignore'da) |
| Hajmi | 88 404 384 bayt (~84,3 MiB) |
| SHA-256 | `0a6e3c341b6abae6bf05e99564d07ae928afdb5b5d085c1a83f249ef3d43af91` |
| Paket (applicationId) | `uz.labguide.app` |
| versionCode / versionName | 20 / 0.1.0 |
| minSdk / targetSdk | 24 / 36 (Play talabi: targetSdk >= 35 — bajarilgan) |
| Imzo | upload kaliti (CN=LabGuide), `jarsigner -verify`: "jar verified" (debug kalit emas) |
| Upload sertifikati SHA-256 | `19:29:AB:51:9C:FE:61:D5:48:15:93:64:0C:54:C5:B4:B6:C5:A3:C4:38:37:35:3C:9D:B2:57:76:56:E8:FA:24` |
| Build | server ulanmagan (`LG_SUPABASE_URL/KEY` bo'sh), `LG_ALL_FEATURES_OPEN=true` |

Faylni tekshirish: `sha256sum LabGuide-0.1.0-20.aab` (yuqoridagi qiymat bilan bir xil bo'lsin).

**Ruxsatlar (haqiqiy, AAB manifestidan):** `INTERNET`, `RECORD_AUDIO` (ixtiyoriy ovozli buyruqlar,
faqat qurilmada oflayn tanish bo'lsa yoqiladi), `POST_NOTIFICATIONS` (kunlik eslatma),
`RECEIVE_BOOT_COMPLETED` (eslatmani qayta ishga tushirishdan keyin tiklash), `VIBRATE`.
Kamera, joylashuv, kontaktlar, xotira ruxsatlari **yo'q**.

**Kalit haqida:** upload kaliti (`.jks`) va parollari repoda yo'q. Ularni xavfsiz joyda (parol
menejeri + zaxira nusxa) saqlang. Play App Signing'da yo'qolsa upload key'ni Play orqali
tiklash (reset) mumkin, lekin vaqt oladi.

## 1. Ilovani yaratish

1. https://play.google.com/console → **Create app**.
2. App name: **LabGuide** (band bo'lsa "LabGuide UZ").
3. Default language: **O'zbekcha (uz)**; ro'yxatda bo'lmasa — Russian yoki English tanlab, keyin
   Store listing'da uz tarjimasini qo'shing.
4. App or game: **App**. Free or paid: **Free** (keyin pullikka o'zgartirib bo'lmaydi).
5. Deklaratsiyalar: Developer Program Policies va US export laws'ni tasdiqlang (egasi o'zi
   belgilaydi). **Create app**.
6. **Play App Signing:** Google imzo kalitini boshqaradi (tavsiya, majburiy). Bizning kalit —
   *upload key*. Birinchi AAB yuklanganda "Use Play App Signing" taklifini qabul qiling.

## 2. App content (Policy → App content)

Dashboard'dagi "Set up your app" ro'yxatidagi bo'limlar:

| Bo'lim | Javob |
|---|---|
| Privacy policy | `https://github.com/davlatsudekspert/LabGuide/blob/main/docs/store/PRIVACY_POLICY.md` (GitHub Pages yoqilsa: `https://davlatsudekspert.github.io/LabGuide/store/PRIVACY_POLICY`). Matnda `[sana]`, `[email]` kabi to'ldirilmagan joylar bo'lsa — avval to'ldiring (APP_STORE.md 14-bo'lim). |
| App access | "All functionality is available without special access" — hammasi login'siz ochiq (mehmon rejimi). |
| Ads | **No, my app does not contain ads** (hozirgi buildda e'lon yo'q). |
| Content rating | Kategoriya: *Reference, News, or Educational*. So'rovnomada zo'ravonlik, jinsiy kontent, qimor, giyohvand moddalar, foydalanuvchi kontenti almashinuvi, joylashuv — hammasiga **No**. Email manzilingizni kiriting, natijani saqlang. |
| Target audience | **18 va undan katta** (faqat kattalar). Bolalarga yo'naltirilmagan. |
| Data safety | Server ulanmagan build uchun: "Does your app collect or share any of the required user data types?" → **No**. Ovozli buyruqlar faqat qurilmada oflayn ishlaydi, ovoz qurilmadan chiqmaydi va saqlanmaydi — Audio **qo'shilmaydi**. Data deletion savollari bu holda so'ralmaydi. Server ulangan birinchi build'dan oldin APP_STORE.md 12-bo'lim jadvaliga o'zgartiriladi. |
| Health apps | Ilova tibbiy qurilma emas, tashxis qo'ymaydi, doza bermaydi. Kategoriya: ma'lumotnoma / ta'lim. "Medical device / diagnosis / treatment" variantlarini **tanlamang**; sog'liq bilan bog'liq funksiya sifatida faqat "Educational / reference" ni belgilang. |
| Government apps, Financial features, News | Mos emas — "No". |
| Advertising ID | Ishlatilmaydi — "No". |

## 3. Store listing (Grow → Store presence → Main store listing)

Matnlar: `docs/store/APP_STORE.md` — 2 (qisqa shior), 3 (promo), 4 (to'liq tavsif; uz/ru/en).
Play'da *Short description* ≤ 80 belgi (promo matndan qisqartiring), *Full description* ≤ 4000
(APP_STORE.md 4-bo'lim matni). "Qoralama / mutaxassis tekshiruvi kutilmoqda" jumlasini
olib tashlamang.

| Element | Fayl |
|---|---|
| App icon (512×512) | `docs/store/google_play_icon_512.png` |
| Feature graphic (1024×500) | `docs/store/google_play_feature_graphic.png` |
| Skrinshotlar | `docs/store/screenshots/<til>/NN_nom.png` — 1290×2796 px (9:19,5, Play talabiga mos), uz 8 ta, ru/en 7 tadan, tayyor. Qayta yaratish: `flutter test tool/screenshots/store_screenshots_test.dart --update-goldens --concurrency=1` (natija `tool/screenshots/out/store/<til>/`, so'ng `docs/store/screenshots/` ga optimallab nusxalanadi). Kamida 2 ta telefon skrinshoti kerak. |

Kategoriya: **Education** (ixtiyoriy ikkinchisi: Medical emas, Education qoldiring). Aloqa
email'i — egasining ommaviy emaili.

## 4. Ichki test (Testing → Internal testing)

1. **Test and release → Testing → Internal testing → Create new release**.
2. Play App Signing so'ralsa — qabul qiling.
3. **Upload**: `dist/LabGuide-0.1.0-20.aab` (egasi faylni o'zi tanlaydi).
4. Release name: `0.1.0 (20)`.
5. Release notes (APP_STORE.md 13-bo'lim):
   - uz: Qoralama sinov versiyasi. Kontent manbalarga asoslangan, lekin mustaqil mutaxassis tekshiruvidan hali o'tmagan — bemorlar bilan ishlashda foydalanmang.
   - ru / en matnlari ham o'sha bo'limda.
6. **Testers** yorlig'i → email ro'yxati yarating (100 tagacha), tester emaillarini kiriting, saqlang.
7. **Next → Save → Review release**; xatolar bo'lmasa **Start rollout to Internal testing**.
8. Testers yorlig'idagi **opt-in havolani** (Copy link) testerlarga yuboring. Tester havolani ochib
   "Become a tester" bosadi, so'ng Play Store'dan o'rnatadi.

Ogohlantirish: Production trekka, "Promote release" yoki "Send for review" (Production) tugmalarini
**bosmang**.

## 5. Shaxsiy hisob: yopiq test talabi

Shaxsiy dasturchi akkaunti (2023-11-13 dan keyin ochilgan) production'ga chiqishdan oldin:
**Closed testing**, **kamida 12 tester**, **ketma-ket kamida 14 kun** opt-in. Ichki test bu
hisobga kirmaydi. Closed testing → Create track → Testers (email ro'yxati yoki Google Group) →
Countries → release → rollout. Talab o'zgarishi mumkin — Google'ning joriy sahifasini tekshiring.

## 6. Keyinroq: CI orqali avtomatik yuklash (qisqa)

Birinchi AAB qo'lda yuklangach, GitHub Actions `mode=play_internal` ishlaydi. Kerakli secretlar:

- `ANDROID_KEYSTORE_BASE64` (`base64 -w0 labguide-upload.jks`)
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS` (= `upload`)
- `ANDROID_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (5-chi; xizmat akkaunti JSON matni)

Service account: Google Cloud'da Google Play Android Developer API'ni yoqing → service account +
JSON kalit → Play Console → Users and permissions → Invite new user (service account emaili) →
LabGuide uchun "Release to testing tracks" va "View app information". CI versionCode'lari 21+
bo'ladi (bu AAB 20), shuning uchun mos keladi.

---

## Claude yordamchisi uchun prompt

Quyidagini to'liq nusxalab, Chrome'dagi Claude (Claude in Chrome) ga bering. Play Console'ni
oldindan oching va tizimga kiring.

```text
Sen menga Google Play Console'da "LabGuide" ilovasini sozlash va birinchi AAB'ni ICHKI TEST
(Internal testing) trekiga yuklashda bosqichma-bosqich yordam berasan. Men o'zbek tilida
gaplashaman, sen ham o'zbekcha javob ber.

KONTEKST
- Ilova: LabGuide, paket nomi uz.labguide.app, bepul (Free), toifa Education.
- Ilova biokimyo/klinik laboratoriya o'quv va ma'lumotnoma vositasi. Tibbiy qurilma emas,
  tashxis qo'ymaydi, doza bermaydi. Hozirgi build serverga ulanmagan, reklama yo'q.
- Ruxsatlar: INTERNET, RECORD_AUDIO (ixtiyoriy, faqat qurilmada oflayn ovozli buyruq),
  POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE. Kamera/joylashuv yo'q.
- Fayl: LabGuide-0.1.0-20.aab (versionCode 20, versionName 0.1.0), kompyuterimda.

BOSQICHLAR (shu tartibda, har birini men bilan tasdiqlab)
1. Create app: nom LabGuide, default til o'zbekcha (bo'lmasa English), App, Free; deklaratsiyalarni
   men o'zim belgilayman.
2. App content: Privacy policy URL =
   https://github.com/davlatsudekspert/LabGuide/blob/main/docs/store/PRIVACY_POLICY.md ;
   App access = hammasi login'siz ochiq; Ads = No; Content rating = Reference/Educational,
   barcha savollarga No; Target audience = 18+; Data safety = hech qanday ma'lumot to'planmaydi
   va ulashilmaydi (No), ovoz qurilmadan chiqmaydi; Health apps = ma'lumotnoma/ta'lim, tibbiy
   qurilma emas.
3. Store listing: matnlarni men senga beraman (docs/store/APP_STORE.md). Ikonka 512 px va
   feature graphic 1024x500 fayllarini men o'zim tanlab yuklayman.
4. Testing -> Internal testing -> Create new release. AAB faylni MEN O'ZIM tanlab yuklayman.
   Release notes'ni men beraman. Testers -> email ro'yxatini men kiritaman.
5. Review release'dan keyin "Start rollout to Internal testing".

QOIDALAR (qat'iy)
- Har bir "Save", "Submit", "Next", "Start rollout", "Send for review", "Publish" kabi tugmani
  bosishdan OLDIN nimani bosmoqchi ekaningni ayt va mendan aniq "ha" javobini kut.
- To'lov, kredit karta, shaxsiy ma'lumot (pasport, manzil, telefon), parol, 2FA kodi, kalit
  fayllarini HECH QACHON o'zing kiritma yoki so'rama; bunday maydonga kelganda to'xtab, menga
  ayt.
- Production trekka (Production, "Promote to production", "Apply for production") TEGMA.
- Boshqa ilovalar (masalan NFCSTORE) va ularning sozlamalariga TEGMA; faqat LabGuide.
- Faylni yuklash dialogida fayl tanlashni men qilaman; sen kutib tur.
- Sahifa kutilgandan farq qilsa yoki xato chiqsa, taxmin qilma: ekranda nima borligini
  aytib, men bilan hal qil.
- Maxfiy narsalarni (parol, kalit, token) chatga yozma va sahifaga kiritma.

Boshlash: avval ochiq tab'larni ko'r, Play Console'dagi hozirgi holatni qisqa ayt, so'ng 1-qadamdan
boshlaymiz.
```
