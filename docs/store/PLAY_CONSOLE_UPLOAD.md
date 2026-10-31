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
| Build | server ulanmagan (`LG_API_URL` bo'sh; Supabase endi ishlatilmaydi), `LG_ALL_FEATURES_OPEN=true` (eski bayroq; D-58 dan keyin yo'q — bu AAB bepul versiya, to'lov yo'q; pullik build uchun 7-bo'lim) |

Faylni tekshirish: `sha256sum LabGuide-0.1.0-20.aab` (yuqoridagi qiymat bilan bir xil bo'lsin).

**Ruxsatlar (haqiqiy, AAB manifestidan):** `INTERNET`, `RECORD_AUDIO` (ixtiyoriy ovozli buyruqlar,
faqat qurilmada oflayn tanish bo'lsa yoqiladi), `POST_NOTIFICATIONS` (kunlik eslatma),
`RECEIVE_BOOT_COMPLETED` (eslatmani qayta ishga tushirishdan keyin tiklash), `VIBRATE`.
Kamera, joylashuv, kontaktlar, xotira ruxsatlari **yo'q**. **Keyingi buildlardan (D-68):**
`CAMERA` qo'shiladi (ilova ichidagi QR skaner, faqat skaner ochilganda so'raladi;
`android.hardware.camera` — `required="false"`). Data safety izohi: APP_STORE.md 12-bo'lim
("QR skaner").

**Kalit haqida:** upload kaliti (`.jks`) va parollari repoda yo'q. Ularni xavfsiz joyda (parol
menejeri + zaxira nusxa) saqlang. Play App Signing'da yo'qolsa upload key'ni Play orqali
tiklash (reset) mumkin, lekin vaqt oladi.

## 1. Ilovani yaratish

1. https://play.google.com/console → **Create app**.
2. App name: **LabGuide** (band bo'lsa "LabGuide UZ").
3. Default language: **O'zbekcha (uz)**; ro'yxatda bo'lmasa — Russian yoki English tanlab, keyin
   Store listing'da uz tarjimasini qo'shing.
4. App or game: **App**. Free or paid: **Free** (keyin pullikka o'zgartirib bo'lmaydi). Pullik versiya ham **Free** qoladi: pullik imkoniyatlar ilova ichidagi obuna (Play Billing) sifatida sotiladi — 7-bo'lim.
5. Deklaratsiyalar: Developer Program Policies va US export laws'ni tasdiqlang (egasi o'zi
   belgilaydi). **Create app**.
6. **Play App Signing:** Google imzo kalitini boshqaradi (tavsiya, majburiy). Bizning kalit —
   *upload key*. Birinchi AAB yuklanganda "Use Play App Signing" taklifini qabul qiling.

## 2. App content (Policy → App content)

Dashboard'dagi "Set up your app" ro'yxatidagi bo'limlar:

| Bo'lim | Javob |
|---|---|
| Privacy policy | `https://labguide.nfcstore.uz/privacy/` (Foydalanish shartlari: `https://labguide.nfcstore.uz/terms/` — pullik versiya, 7-bo'lim; `site/privacy/index.html`, joylash — `site/README.md`; sayt joylanmaguncha zaxira: `https://github.com/davlatsudekspert/LabGuide/blob/main/docs/store/PRIVACY_POLICY.md`). Matnda sana (2026-10-17) va aloqa (labguide@nfcstore.uz) taklif qilingan — egasi tasdiqlasin; ochiq savollar `docs/store/PRIVACY_OPEN_QUESTIONS.md` (APP_STORE.md 14-bo'lim). |
| Contact details (Store listing) | Email: **labguide@nfcstore.uz** (ilovadagi Profil → Aloqa va shikoyat bilan bir xil; kodda `lib/core/contact.dart`). Egasi alias ishlashini sinov xati bilan tasdiqlasin. Telefon/sayt — ixtiyoriy. |
| App access | "All functionality is available without special access" — hammasi login'siz ochiq (mehmon rejimi). |
| Ads | **No, my app does not contain ads** (do'kon buildida hamkor reklamasi kompilyatsiyadan chiqarilgan — `LG_PARTNER_ADS=false`, `lib/core/build_flags.dart`). |
| Content rating | Kategoriya: *Reference, News, or Educational*. So'rovnomada zo'ravonlik, jinsiy kontent, qimor, giyohvand moddalar, joylashuv — **No**. **Foydalanuvchi kontenti / foydalanuvchilar o'zaro aloqasi (user-generated content, users can interact) — Yes**: hamjamiyat savol-javoblari (server ulangan buildda hisobli foydalanuvchi savol yozadi, javoblar ilovada hammaga ochiq; D-43). Play UGC siyosati talablari: ilova ichida shikoyat qilish va moderatsiya bor (admin panel; 3 ta turli foydalanuvchi shikoyati hisobni ko'rib chiqquncha to'xtatadi; maxfiylik siyosati 'Hamjamiyat' bandi). Hamjamiyat faqat `LG_API_URL` berilgan buildda mavjud, lekin so'rovnomani do'kondagi ilovaning to'liq (server ulangan) holatiga mos to'ldiring. Email manzilingizni kiriting, natijani saqlang. |
| Target audience | **18 va undan katta** (faqat kattalar). Bolalarga yo'naltirilmagan. |
| Data safety | **`LG_API_URL` bo'sh build (server ulanmagan):** "Does your app collect or share any of the required user data types?" → **No**; Data deletion savollari so'ralmaydi. **`LG_API_URL` berilgan build (Cloudflare server):** **Yes, collects** — *Personal info → Email address* (Account management, App functionality; sinf uchun majburiy, umuman ixtiyoriy — mehmon rejimida yo'q), *Personal info → User IDs* (Account management, App functionality; shu qatorga Google/Apple provayder identifikatori ham kiradi, D-56 — yangi toifa yo'q, *Name* qo'shilmaydi), *Account creation methods*: OAuth (Google, Apple) + Other authentication (email kodi) — Play so'rasa, *App activity → Other user-generated content* (guruh taxallusi, test javoblari va ball; hamjamiyat savol-javoblari — ilova ichida ommaviy; App functionality); *Photos and videos → Photos* (mutaxassis hujjati, ixtiyoriy, **processed ephemerally** — Workers AI tekshiruvidan keyin saqlanmaydi; App functionality, D-43); *Messages → Other in-app messages* ("Taklif va yordam" murojaatlari va ilova ichidagi shikoyatlar — mehmondan ham, identifikatorsiz; App functionality); [*App interactions* — oxirgi faol kun va daqiqaga yaxlitlangan oxirgi faollik vaqti, faqat umumiy "hozir onlayn" soni uchun; kerak bo'lsa]. **Shared: No** (Cloudflare, Resend va zaxira email xizmati Brevo — xizmat ko'rsatuvchi). **Encrypted in transit: Yes** (HTTPS). **Deletion: Yes** — ilovada Profil → Maxfiylik va ma'lumotlar → "Hisobni o'chirish" va aloqa emaili labguide@nfcstore.uz (Delete account URL maydoniga: `https://labguide.nfcstore.uz/delete-account/`). Ovozli buyruqlar faqat qurilmada oflayn ishlaydi — Audio **qo'shilmaydi**. To'liq jadval: APP_STORE.md 12-bo'lim. |
| Health apps | Ilova tibbiy qurilma emas, tashxis qo'ymaydi, doza bermaydi. Kategoriya: ma'lumotnoma / ta'lim. "Medical device / diagnosis / treatment" variantlarini **tanlamang**; sog'liq bilan bog'liq funksiya sifatida faqat "Educational / reference" ni belgilang. |
| Government apps, Financial features, News | Mos emas — "No". |
| Advertising ID | Ishlatilmaydi — "No". |

## 3. Store listing (Grow → Store presence → Main store listing)

Matnlar: `docs/store/APP_STORE.md` — 2 (qisqa shior), 3 (promo), 4 (to'liq tavsif; uz/ru/en).
Play'da *Short description* ≤ 80 belgi (promo matndan qisqartiring), *Full description* ≤ 4000
(APP_STORE.md 4-bo'lim matni). Tibbiy eslatmani (tashxis emas; natijani shifokor baholaydi)
olib tashlamang; kontent "qoralama" deb yozilmaydi (D-65).

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
   - uz: Sinov versiyasi. Kontent — adabiyotga asoslangan o'quv ma'lumotnomasi, tashxis emas; bemor bo'yicha qarorlarda foydalanmang.
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

## 7. Pullik versiya (`paid/pro-premium`, D-77): obunalar, Data safety, review

> **Holat (2026-10-25).** Bu bo‘lim FAQAT `paid/txt` / `paid/pro-premium` tarmog‘i uchun. 0–6-bo‘limlar va pastdagi
> Claude yordamchisi prompti **bepul ichki test AAB si** (0.1.0 (20), to‘lov yo‘q, D-58) uchun — ular o‘zgartirilmagan.
> Hech narsa yuborilmagan: Play Console/Billing API chaqirilmagan, obunalar **yaratilmagan** (id’lar va narxlar
> UNCONFIRMED-until-created-in-store), haqiqiy litsenziya-tester xaridi sinalmagan (NOT VERIFIED). **Matnlarda narx
> yo‘q** (narx Play’dan). Play siyosatlari va maydon uzunliklari o‘zgaradi — **NEEDS_OWNER_CHECK:** nashrdan oldin
> Play Payments / Subscriptions siyosati va Console yordamini qayta o‘qing.

### 7.1 Ilova turi va ruxsat

- Create app → **Free or paid: Free** (ilova ichidagi obuna — Play Billing; “Contains in-app purchases” deb ko‘rinadi).
- Manifestga `com.android.vending.BILLING` (oddiy ruxsat) `in_app_purchase` bilan qo‘shiladi — 0-bo‘limdagi ruxsatlar
  ro‘yxati pullik build uchun yangilanadi. Pullik build **faqat shu tarmoqdan** yig‘iladi (bepul build — `main`dan).
- Ads: **No** (o‘zgarmaydi). Financial features: **No** (to‘lovni Google Play qayta ishlaydi; LabGuide moliyaviy ilova emas).

### 7.2 Monetize → Products → Subscriptions

4 ta obuna × 2 ta base plan (`monthly` — P1M, `yearly` — P1Y). Id’lar kodda (`billing_catalog.dart`; **yangi id
o‘ylab topilmadi**): subscription id `uz.labguide.student`, `uz.labguide.teacher`, `uz.labguide.specialist`,
`uz.labguide.premium`; base plan id `monthly` / `yearly`. Narxni egasi tanlaydi (hujjatda yozilmaydi). **Free-trial
offer — egasi qarori D-80 (2026-10-31): 30 kun / 1 oy, Play Console’da egasi o‘rnatadi** (8 ta base plan uchun;
yaratilganmi — NOT VERIFIED; Play’da trial davomiyligi variantlarini Console’da tekshiring). Ilovadagi server sinovi ham 30 kun;
kod bo‘yicha ilova do‘kon takliflarini hozircha yoqmagan (`storeIntroOffersAllowed = false`) — bayroq o‘zgartirilmagan,
ikki sinovning qo‘shilishi (stacking) NEEDS_OWNER_CHECK. Tugash sanasi — Play’ning o‘z kvitansiya sanasi (`expiryTime`),
qayta hisoblanmaydi. `PRO_BILLING_PLAN.md` 9.2-bo‘limdagi “6 subscription” va “Free trial 7/14 kun
offer” **eskirgan** (D-76/D-77/D-80).

| Maydon | uz | ru | en |
|---|---|---|---|
| Name — Talaba | Talaba Pro | Студент Pro | Student Pro |
| Benefits (har biri ≤ 40, ko‘pi bilan 4 ta) | Ustoz bergan testlar · Natijalar tarixi · Imtihon simulyatsiyasi · PDF/CSV eksport, qo‘shimcha materiallar | Тесты от преподавателя · История результатов · Симуляция экзамена · Экспорт PDF/CSV и материалы | Teacher-assigned tests · Results history · Exam simulation · PDF/CSV export and extra materials |
| Name — Ustoz | Ustoz Pro | Преподаватель Pro | Teacher Pro |
| Benefits | Test yaratish · Talabalarni biriktirish, guruhlar · Natijalarni boshqarish | Создание тестов · Студенты и группы · Управление результатами | Create tests · Attach students and groups · Manage results |
| Name — Mutaxassis | Mutaxassis Pro | Специалист Pro | Specialist Pro |
| Benefits | Professional laboratoriya funksiyalari | Профессиональные функции лаборатории | Professional laboratory functions |
| Name — Premium | Premium | Premium | Premium |
| Benefits | Talaba Pro imkoniyatlari · Ustoz Pro imkoniyatlari · Mutaxassis Pro imkoniyatlari | Возможности Студент Pro · Возможности Преподаватель Pro · Возможности Специалист Pro | Student Pro features · Teacher Pro features · Specialist Pro features |

Description (≤ 80, har reja uchun bir xil naqsh): uz “Ixtiyoriy pullik reja. Bepul imkoniyatlar bepul qoladi.” · ru “Необязательный платный план. Бесплатные
функции остаются бесплатными.” · en “Optional paid plan. Free features stay free.” Qo‘shimcha: **Setup → License testing**, **Payments profile**,
RTDN, service account — `PRO_BILLING_PLAN.md` 9.2 (3–5-bandlar o‘zgarmagan) va `PRO_TEST_ENVIRONMENT.md` 4-bo‘lim.

### 7.3 Store listing — to‘liq tavsif oxiriga obuna bloki (narxsiz)

Play subscriptions siyosati: narx, davr, avtomatik yangilanish, bekor qilish yo‘li va shartlar havolasi ochiq bo‘lishi
kerak (narxni Play ko‘rsatadi). APP_STORE.md 4-bo‘lim tavsifiga **16.3-banddagi** blok qo‘yiladi, faqat “Apple hisobingiz” /
“Settings → your name → Subscriptions” o‘rniga Play varianti:

- **uz:** … to‘lov xaridni tasdiqlaganingizda Google Play hisobingizdan olinadi … Obunani Google Play → profil belgisi → To‘lovlar va
  obunalar → Obunalar bo‘limida boshqarish va bekor qilish mumkin.
- **ru:** … оплата списывается с вашей учётной записи Google Play при подтверждении покупки … Управлять подпиской и отменить её
  можно в Google Play → значок профиля → Платежи и подписки → Подписки.
- **en:** … payment is charged to your Google Play account when you confirm the purchase … You can manage and cancel it in Google Play →
  profile icon → Payments & subscriptions → Subscriptions.

Hamma tilda oxirida: Foydalanish shartlari `https://labguide.nfcstore.uz/terms/` · Maxfiylik siyosati
`https://labguide.nfcstore.uz/privacy/`. Qisqa tavsifga (≤ 80) obuna qo‘shilmaydi. Tibbiy eslatma va D-65 qoidalari o‘zgarmaydi.

### 7.4 App content — pullik versiyada o‘zgaradigan javoblar (**NEEDS_OWNER_CHECK**: aniq so‘zlar)

| Bo‘lim | Pullik build uchun |
|---|---|
| App access | “All functionality is available without special access” **endi to‘g‘ri emas**: xarid, tiklash va bepul sinov hisob talab qiladi. “Some functionality is restricted” → review uchun kirish yo‘riqnomasi: `<REVIEW_ACCOUNT>` (egasi to‘ldiradi: email kodi qanday olinadi) + sinov xaridi uchun **License testing** hisobi `<LICENSE_TESTER>`; bepul qism hisobsiz ochiq. |
| Privacy policy | `https://labguide.nfcstore.uz/privacy/` (16-bo‘lim — obuna/sinov/to‘lov; sana 2026-10-25, nashr kuniga almashtiring). Terms: `https://labguide.nfcstore.uz/terms/`. |
| Data safety — qo‘shiladi | **Financial info → Purchase history:** to‘planadi (do‘kon tranzaksiya/xarid tokeni, reja, holat, vaqt), ulashilmaydi (Google Play — to‘lov provayderi), maqsad *App functionality*; hisob o‘chirilganda o‘chadi. **Device or other IDs:** bepul sinov uchun qurilma belgisining kalitli xeshi (xom ID saqlanmaydi) — *Fraud prevention, security, and compliance*; to‘planadi, ulashilmaydi; “ixtiyoriy” (sinov tugmasi bosilganda). Qurilma xeshi hisob o‘chirilgandan keyin ham 24 oy saqlanadi — **NEEDS_LAWYER_REVIEW** va Data deletion savoliga javobda “ba’zi ma’lumot xavfsizlik/firibgarlikka qarshi saqlanadi” deb ko‘rsatish (aniq so‘z — egasi). Email, User IDs, UGC, Messages, Photos qatorlari o‘zgarmaydi (APP_STORE.md 12-bo‘lim). |
| Data safety — o‘zgarmaydi | Encrypted in transit: Yes; Delete account URL: `https://labguide.nfcstore.uz/delete-account/` (sahifada obuna so‘zlari yo‘q — D-77; “do‘kon obunasi bekor bo‘lmaydi” — maxfiylik siyosati 10 va 16-bo‘limlarida). |
| Content rating / Target audience | o‘zgarmaydi (18+); obunalar kattalarga mo‘ljallangan emas, balki ilova bolalarga mo‘ljallanmagan (siyosat 15-bo‘lim). |

### 7.5 Tekshiruv uchun test qadamlari (ichki test, **QILINMAGAN — NOT VERIFIED**)

1. **Setup → License testing** ga tester Google hisoblarini qo‘shing (`<LICENSE_TESTER>`); ichki test trekiga pullik build (billing yoqilgan) yuklang
   (egasi; bu tarmoqda build qilinmagan).
2. Ilovada tester hisobi bilan kiring → Profil → Obuna → reja → “Obuna bo‘lish” → Play oynasida tasdiqlang (test kartasi: “Always approves”).
3. Pullik imkoniyatlar ochiladi → Profil → Obuna → **“Xaridni tiklash”** (shu ekran va to‘lov oynasi pastida) → boshqa qurilmada tiklash.
4. “Obunani boshqarish yoki bekor qilish” Play obuna sahifasini ochadi; bekor qilingach to‘langan davr oxirigacha ishlaydi, keyin faqat pullik qism yopiladi.
5. Sinov (30 kun, D-80): Android’da tugma faqat Play Integrity sozlangan serverda chiqadi (hozir sozlanmagan — tugma yashirin; `PRO_TEST_ENVIRONMENT.md` 4-bo‘lim 6-band).
6. Oflayn, “Always declines” (grace/hold), “Approves then charges back” (refund) holatlari — `PRO_TEST_ENVIRONMENT.md` 4-bo‘lim.

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
  tashxis qo'ymaydi, doza bermaydi. Reklama yo'q. Mehmon rejimida serverga hech narsa
  yuborilmaydi; ixtiyoriy hisob (email kodi, Google, Apple) bilan server (Cloudflare) ishlatiladi.
- Ruxsatlar: INTERNET, RECORD_AUDIO (ixtiyoriy, faqat qurilmada oflayn ovozli buyruq),
  POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE. Kamera/joylashuv yo'q.
- Fayl: LabGuide-0.1.0-20.aab (versionCode 20, versionName 0.1.0), kompyuterimda.

BOSQICHLAR (shu tartibda, har birini men bilan tasdiqlab)
1. Create app: nom LabGuide, default til o'zbekcha (bo'lmasa English), App, Free; deklaratsiyalarni
   men o'zim belgilayman.
2. App content: Privacy policy URL = https://labguide.nfcstore.uz/privacy/
   (sayt joylanmagan bo'lsa: https://github.com/davlatsudekspert/LabGuide/blob/main/docs/store/PRIVACY_POLICY.md);
   Delete account URL = https://labguide.nfcstore.uz/delete-account/ ;
   App access = hammasi login'siz ochiq; Ads = No; Content rating = Reference/Educational,
   foydalanuvchi kontenti (hamjamiyat) savoliga Yes, qolgan savollarga No; Target audience = 18+; Data safety = `LG_API_URL` bo'sh buildda hech
   qanday ma'lumot to'planmaydi va ulashilmaydi (No), `LG_API_URL` berilgan buildda 54-qatordagi
   (2-bo'lim jadvali) javoblar; ovoz qurilmadan chiqmaydi; Health apps = ma'lumotnoma/ta'lim, tibbiy
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
