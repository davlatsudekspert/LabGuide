# Apple 2026 talablari: nimani bilish, nimani qilish (LabGuide)

Holat: **2026-10-17**. Barcha Apple ma'lumotlari shu kuni `developer.apple.com` dan olindi
(WebFetch/WebSearch). Belgilar: **[V]** — rasmiy Apple sahifasidan tekshirildi;
**[?]** — faqat ikkinchi darajali manbada (blog, yangiliklar ro'yxatining xulosasi) yoki
sahifaning qisqa mazmunida topildi, **tasdiqlanmagan**: ishlatishdan oldin havolani o'zingiz oching.
Hujjat huquqiy maslahat emas; “unsure” bandlari uchun yurist/Apple Developer Support bilan
tekshiring.

## 0. Eng muhim 8 narsa (egasi uchun qisqa)

1. **Egasi olgan xabar — 2026-10-16 App Review Guidelines yangilanishi [V]**
   (`developer.apple.com/news/?id=92th7e5i`): 1.2 (UGC), **2.3.14** (yangi, creative assets),
   **2.5.19** (yangi, yashirin/“uxlab yotgan”/hujjatlanmagan funksiyalar yo'q), 3.1.1(a), 5-bo'lim.
   Bizga ta'siri: 2.5.19 va 1.2 — **yes**; 2.3.14 — do'kon grafikasi uchun **yes**. 3.1.1(a) (tashqi
   to'lov havolasi) va 5-bo'lim (odam savdosi) — **no**.
2. **2.5.19 — bu versiyada to'lov yo'q (D-58).** Pro/obuna kodi ilovadan butunlay olib tashlandi
   (hamma narsa bepul; ish `pro-later` branchida). Reklama UI `LG_PARTNER_ADS` bayrog'i bilan:
   faqat `testflight`/`play_internal` buildlarida `true` (“Namuna / Demo” joylari bilan); `build` va
   kelajakdagi do'kon rejimida `false` — reklama UI kompilyatsiyadan chiqariladi. **Review uchun
   alohida `store` rejimi kerak** (3-bo'lim) — `LG_PARTNER_ADS` siz.
3. **1.2 — endi to'liq (2026-10-18, D-62).** Server har savol/javob muallifiga `author.ref` beradi
   (qaytarib bo'lmaydigan HMAC; id/email emas) → “Foydalanuvchini bloklash” tugmasi ishlaydi; blok
   hisobga ham yoziladi (boshqa qurilmada va server ro'yxatlarida ham yashirin). So'kinish/haqorat
   filtri (uz lotin+kirill, ru, en) savol va javob yaratishda rad etadi. Batafsil — 4-bo'lim.
4. **Yosh reytingi savolnomasi** (4+/9+/13+/16+/18+, Apple 2025-07-24, muddat 2026-01-31 [V]) va
   **“Social media” savoli** (2026-09 dan yangi versiya yuborishda majburiy [V]): javoblar 6-bo'limda.
   Kutilgan natija: **13+** (tibbiy ma'lumot tufayli).
5. **“Regulated medical device” holati** (2026-03-26 dan, yangi ilovalar uchun hozir, mavjudlar
   uchun 2027 boshigacha [V]): ikkinchi toifamiz “Medical” bo'lgani uchun deklaratsiya **majburiy**
   (taklif javob: **No**, 8-bo'lim).
6. **`ios/Runner/PrivacyInfo.xcprivacy` yo'q edi** → qo'shildi va Xcode loyihasiga ulandi (9-bo'lim).
7. **SDK:** 2026-04-28 dan iOS 26 SDK/Xcode 26 majburiy [V]; **2027-aprelidan iOS 27 SDK** [V, yangilik
   sahifasi]. CI hozir macOS-15 + eng yangi barqaror Xcode; faqat ogohlantiradi (10-bo'lim).
8. **Texas/Utah/Louisiana yosh tekshiruvi qonunlari** (Declared Age Range API): bizga tegishliligi
   **unsure** (7-bo'lim). Kod yozilmadi; yurist bilan tekshirish kerak.

## 1. Apple talablari jadvali

Ustunlar: talab (inglizcha nomi) · manba · kuch kirgan sana · bizga tegadimi · nima qilish kerak.

| # | Talab | Manba | Sana | Bizga? | Nima qilish |
|---|---|---|---|---|---|
| 1 | **“Updated App Review Guidelines are now available”** — 1.2, 2.3.14, 2.5.19, 3.1.1(a), 5 [V] | `news/?id=92th7e5i` | 2026-10-16 | **yes** | 2–5-bo'limlar |
| 2 | **“Strengthening App Review Guidelines against nonconsensual intimate imagery and bait-and-switch apps”** — 1.2: NCII (AI-yaratilgan ham) ni oldindan oldini olish/olib tashlash; 2.5.19 [V] | `news/?id=vvzx6cul` | 2026-10-16 | **yes** (UGC bor) | 4-bo'lim: matn-faqat UGC, rasm yuklash yo'q; qoidalarga NCII bandi qo'shing |
| 3 | **Guidelines 2026-06-08**: 1.2 ga yangi band (ishlab chiquvchi kontentni olib tashlash majburiyati), kid/teen safety kirish qismi, 4.3(a)(b), 4.5.3 [V] | `news/?id=a233fmpw` | 2026-06-08 | yes (1.2) | Shikoyatlarga o'z vaqtida javob (4-bo'lim) |
| 4 | **Guidelines 2026-02-06**: tasodifiy/anonim chat 1.2 ga kiradi [V] | `news/?id=d75yllv4` | 2026-02-06 | no (chat yo'q) | — |
| 5 | **Guidelines 2025-11-13**: 5.1.2(i) — **uchinchi tomon AI** bilan shaxsiy ma'lumot ulashish uchun aniq ruxsat; 4.7 (mini apps); 1.2.1(a) [?: yangiliklar ro'yxati xulosasi; 5.1.2(i) matni guidelines sahifasida [V]] | `news/` ro'yxati; guidelines 5.1.2(i) | 2025-11-13 | **yes** (Workers AI) | 4-bo'lim 2-band |
| 6 | **“Updated age ratings in App Store Connect”** — yangi 13+/16+/18+, yangi savollar (in-app controls, capabilities, medical/wellness, violent themes) [V] | `news/?id=ks775ehf` | 2025-07-24; javob muddati **2026-01-31** | **yes** | 6-bo'lim; ASC → App Information → Age Ratings |
| 7 | **“Age rating questionnaire now includes social media questions”** [V] | `news/?id=tlur8uvi` | savol 2026-07-09; **majburiy 2026-09 dan** (yangi versiya/ilova yuborishda) | **yes** | 6-bo'lim |
| 8 | **“Introducing Time Allowances”** (iOS 27: Entertainment/Games/Social Media) [V] | `news/?id=0d2gpmml` | 2026-06-08 | yes (faqat “Social media” javobi orqali) | 6-bo'lim: javob **No** (asoslangan) |
| 9 | **Age requirements for apps distributed in Brazil, Australia, Singapore, Utah, and Louisiana** (Declared Age Range API yangilanishi) [V] | `news/?id=f5zj08ey` | 2026-02-24; Utah **2026-05-06**, Louisiana **2026-07-01** (Apple matni) | **unsure** | 7-bo'lim |
| 10 | **Update for Apps Distributed in Texas** (SB 2420: injunction bekor, **2026-06-04** dan yangi hisoblar) [V] | `news/?id=sg176nne` | 2026-06-04 | **unsure** | 7-bo'lim |
| 11 | Upcoming changes to age ratings in Australia and Vietnam [V] | `news/?id=yrrb45pw` | 2026-06-18 | qisman (Medical/Social media javoblari Avstraliyada 16+ ga olib kelishi mumkin) | 6-bo'lim |
| 12 | Updates to age ratings for the Republic of Korea (GRAC RCN) [V] | `news/?id=oj3r9pvw` (sarlavha [V], matn o'qilmadi) | 2026-08-12 | no (o'yin reytingi) | — |
| 13 | **“Update on regulated medical device apps in the EEA, UK, and US”** [V] | `news/?id=nyqbfz1y` | 2026-03-26; mavjud ilovalar **2027 boshigacha** | **yes** | 8-bo'lim |
| 14 | **SDK minimum requirements**: Xcode 26 / iOS 26 SDK [V] | `news/upcoming-requirements/`; `news/?id=ueeok6yw` | **2026-04-28** | **yes** | 10-bo'lim |
| 15 | **iOS 27 SDK minimum** [V yangilik: “App Store submissions now open…”; upcoming-requirements sahifasida hali yo'q] | `news/?id=k1mtkt1k` | **2027-aprel** (kun aytilmagan) | yes (kelajak) | 10-bo'lim |
| 16 | **iOS and iPadOS minimum system requirements**: iOS 13+ ni nishonlash [V] | `news/upcoming-requirements/` | 2026-09-09 | yes — bizniki iOS 15 ✓ | — |
| 17 | **Approved reasons for APIs** (privacy manifest, required-reason API) [V] | `news/upcoming-requirements/` | 2024-05-01 | **yes** | 9-bo'lim |
| 18 | Commonly used third-party SDK’lar: privacy manifest + imzo (Flutter ro'yxatda) [V] | `support/third-party-SDK-requirements/` | sana yozilmagan | yes | Flutter 3.47.6 o'z manifestini olib keladi [?]; 9-bo'lim |
| 19 | **DSA trader status required for apps in the EU** [V] | `news/upcoming-requirements/` | 2024-10-16 (yangilanish), 2025-02-17 (EU’dan olib tashlanadi) | **yes** (EU’da tarqatsak) | 11-bo'lim |
| 20 | **Updates to Sign in with Apple**: yangi relay domen `private.icloud.com` (ikkalasini ham qabul qiling) [V] | `news/?id=1ptvdtcm` | 2026 oxiriga qadar (aniq sana yo'q) | yes (SIWA qo'shilmoqda) | 12-bo'lim |
| 21 | Sign in with Apple: Koreya dasturchilari uchun server-to-server endpoint [V] | `news/?id=j9zukcr6` | 2026-01-01 | no (Koreya emas) | — |
| 22 | **3.1.2(a)/(c) obuna qoidalari**: kamida 7 kun davr, barcha qurilmalarda, nima olinishini aniq yozing [V] | guidelines | amaldagi | yes | 13-bo'lim |
| 23 | Monthly subscriptions with a 12-month commitment (AQSh va Singapurdan tashqari) [V] | `news/?id=agq42lxe` | 2026-04-27 | ixtiyoriy | 13-bo'lim |
| 24 | **Multiseat purchasing** obunalar uchun *sukut bo'yicha yoqilgan* (2026-09-16); Volume Purchasing **2026-10-22**; Group Purchases “qishda” [V] | `news/?id=likeohx4` | 2026-09-16 | yes (Ustoz Pro, maktab) | 13-bo'lim: qaror kerak |
| 25 | EU yangi biznes shartlari (alternativ to'lov, 2026-10-01) va yangilangan **DPLA** (2026-08-18, 2026-10-13) [V] | `news/?id=gmws0jgp` | 2026-10-01 | qisman (shartlarni qabul qilish) | Account Holder ASC/Developer’da yangi shartlarni qabul qiladi |
| 26 | Tax and price updates (2026-08-27: Marokash, Kongo, Tanzaniya; narxlar 09-14) — **O'zbekiston tilga olinmagan; obunalar o'zgarmaydi** [V] | `news/?id=artln8br` | 2026-08-27 | no | — |
| 27 | Updates to App Tracking Transparency in the EU (iOS 27.2 muqobil prompt) [V xulosa] | `news/` ro'yxati | 2026-09-16 | no (kuzatuv/ATT yo'q) | — |
| 28 | Mini Apps Partner Program / 4.7 [?] | `news/` ro'yxati | 2025-11-13 | no | — |

“Tegishli emas” sabablari qisqacha: ilovada kuzatuv (ATT), o'yin, mini-ilova, tashqi to'lov havolasi,
tasodifiy chat, noyob Koreya/Braziliya (betting) talablari yo'q.

## 2. Kod holati: nima tekshirildi

Quyidagi tekshiruvlar `lib/`, `ios/`, `.github/workflows/ci.yml`, `docs/` bo'yicha (faqat o'qish).
`lib/features/auth`, `cloudflare/`, `ci.yml` o'zgartirilmadi.

## 3. Guideline 2.5.19 — yashirin, “uxlab yotgan” yoki hujjatlanmagan funksiyalar

> **2.5.19** — “Don't include any hidden, dormant, or undocumented features in your app; your app's
> functionality should be clear to end users and App Review. Attempting to hide undocumented features
> in your app binary, such as through code obfuscation or other methods, is grounds for removal…” [V]
>
> **2.3.1(a)** — “All new features, functionality, and product changes must be described with
> specificity in the Notes for Review section of App Store Connect (generic descriptions will be
> rejected) and accessible for review.” [V]

### 3.1 Har bir element bo'yicha

| Element | Qayerda | Holat | “Hujjatlangan va review uchun yetib boriladimi?” | Qaror |
|---|---|---|---|---|
| **To'lov/obuna** | — | **Bu versiyada to'lov yo'q** (D-58): StoreKit/Play Billing kodi, paketlar va server endpointlari olib tashlangan; hamma imkoniyat bepul | — | OK. To'lov keyin to'liq yangilanish sifatida (mahsulotlar versiyaga biriktirilib) qaytadi |
| **Hamkor reklama UI** (`HomePartnerPair`, Lab/apparat kartalari, hamkor sahifalari, “Hamkor bo'lish”) | `lib/core/build_flags.dart` (`LG_PARTNER_ADS`) | `false` (standart, do'kon) — kompilyatsiyadan chiqariladi; `true` faqat `testflight`/`play_internal` | Do'kon buildida yo'q | Review’ga faqat `LG_PARTNER_ADS=false` build yuborilsin; TestFlight/ichki sinov buildlari review’ga yuborilmasin |
| **Hamjamiyat** (savol-javob) | `lib/features/community` | `LG_API_URL` bo'sh bo'lsa UI yo'q; CI sukut bo'yicha URL beradi → ko'rinadi | Savolni **mehmon** ham o'qiydi; savol berish — kirish; javob berish — tasdiqlangan mutaxassis | Notes’da tushuntiring; review uchun **demo hisob** kerak (8.2) |
| **Mutaxassis tasdig'i** (hujjat suratini AI tekshiradi) | `VerifySpecialistScreen` | Ko'rinadi (kirgan foydalanuvchiga) | Reviewer rasm yuklab sinay oladi | Notes’da: “fayl saqlanmaydi, Cloudflare Workers AI”; 5.1.2(i): ekranda ochiq ogohlantirish bor (`cmVerifyInfo`) |
| **Admin panel** (`/profile/admin/*`, `AdminGate`) | `admin_screens.dart` | Faqat server admin huquqi + 2FA bo'lgan hisobga ochiladi | Reviewer ko'rmaydi | Notes’da ochiq yozing (“administrator area for moderation, not available to regular users”). Yashirin yo'l emas: oddiy foydalanuvchida “ruxsat yo'q” sahifasi chiqadi |
| **Demo OTP adapteri** | `otp_auth.dart` (`kDebugMode`) | Release’da kompilyatsiya vaqtida **chiqarib tashlanadi** | — | OK (binarda yo'q) |
| **Ovozli buyruqlar** (leykoformula, eksperimental) | `speech_to_text`, Info.plist | Foydalanuvchi o'zi yoqadi; qurilmada tanish | Reviewer yoqa oladi | Notes’da yozing |
| **Ustoz: avtomatik taqdimot, guruhlar, topshiriqlar** | classroom/lecture | Hamma uchun ochiq (to'lov yo'q) | Reviewer ko'radi | Notes’da tushuntiring |
| **Paketlar** (kontent, GitHub raw) | `lib/features/packs` | Foydalanuvchi bossa JSON/fayl yuklanadi | Reviewer ko'radi | Yuklanadigani **ma'lumot**, bajariladigan kod emas (2.5.2) — Notes’da bir jumla |
| Chuqur havolalar | `Info.plist` | `CFBundleURLTypes`/Associated Domains **yo'q** → tashqaridan yashirin yo'l yo'q | — | OK |
| Server bayroqlari | — | Bu versiyada to'lov yo'q; do'kon buildida hamkor UI yo'q — serverdan yoqiladigan funksiya yo'q | — | Review’dan keyin **yangi funksiya** serverdan yoqilmasin (bait-and-switch, 2.5.19 va 2.3.1) |

### 3.2 Kodda o'zgartirish kerak bo'lganlar (ro'yxat)

1. **`ci.yml`: `store` rejimi** (boshqa muhandis): `LG_PARTNER_ADS` siz (`false`), `flutter build ipa`, TestFlight’ga
   yuklash, lekin `Beta App Review/Submit for Review` faqat shu build’dan. (Hozir TestFlight buildi
   `LG_PARTNER_ADS=true` — demo reklama joylari bilan chiqadi.)
2. **Review demo hisobi** (server, boshqa muhandis): sobit `LG_REVIEW_EMAIL` + sobit kod, faqat
   shu email uchun; **Notes for Review’da ochiq yoziladi** (aks holda yashirin orqa eshik hisoblanadi).
   Muqobil: faqat mehmon rejimi + “har qanday email’ga kod keladi”.
3. Do'kon matni yangilansin (`docs/store/APP_STORE.md`): hujjat hanuz “ilova hozircha serverga ma'lumot
   yubormaydi, email orqali kirish va guruhlar yo'q” deydi, lekin CI sukut bo'yicha serverga ulaydi
   (`LG_API_URL` sukut qiymati bor). Tavsif/App Privacy mos kelmasa — **2.3.1 (noto'g'ri metadata)**
   va 5.1.1. Build qaysi rejimda chiqishiga qarab matnlar va **App Privacy** (hamda
   `PrivacyInfo.xcprivacy`) yangilanishi shart.

### 3.3 Notes for Review — nusxalash uchun tayyor matn (inglizcha)

> **Replace the bracketed items before submitting.**
>
> LabGuide is an offline-first reference and study app for clinical laboratory specialists, physicians,
> students and teachers (Uzbek, Russian, English). It does not diagnose, interpret individual patient
> results or suggest drug doses; all content is source-linked study material.
>
> **How to review (no account needed):** open the app as a guest, pick a role, and use the tabs:
> Home (search, daily 5 questions), Tests (analyte atlas, calculators), Lab (QC, differential count,
> instruments), Library, Learn (quizzes, exam practice, Lecture mode for teachers). Everything except the
> items below works offline and without sign-in.
>
> **Sign-in (optional):** Profile → Sign in. Email one-time code, [Sign in with Apple] [and Google].
> **Demo account for review:** email `[review@…]`, code `[000000]` — this fixed code works only for this
> address and exists only so App Review can sign in without an inbox. [If no demo account: any email you
> control receives a 6-digit code.]
>
> **Community Q&A (user-generated content, Profile → Community / Home card):** anyone can read; signed-in users
> can ask questions (text only; no images, no direct messages, no feed or follow). Only specialists verified by
> an automatic document check can answer or upvote. Safeguards (Guideline 1.2): rules card and sheet; server-side
> blocking of e-mail/phone numbers in posts and a server-side profanity/abuse filter (Uzbek Latin and Cyrillic,
> Russian, English — a post with abusive words is rejected with a clear message); **Report** on every post by others
> (reason list), a post is hidden automatically after 3 reports and reviewed by an administrator; **Block user**
> hides all posts of that user for this account (on this device immediately and on the server, so also on other
> devices); published contact `labguide@nfcstore.uz` (Profile → Contact, and a link on the Community screen);
> administrators can delete posts and suspend users. Demo specialist: [account with verified status] so you can
> answer and upvote.
>
> **Specialist verification (Profile → Community → Verify):** the user photographs a diploma/certificate; the image is
> checked once by an AI model (Cloudflare Workers AI) and is not stored; only role/country/status are kept. The
> screen explains this before the user taps “Send for automatic check”.
>
> **No in-app purchases or subscriptions in this version.** All features are free: exam simulation, full question
> banks, history, weak-topics analysis, atlas practice, groups, assignments and Lecture mode.
>
> **No advertising in this version.**
>
> **Administrator area (not available to regular users or reviewers):** Profile → Admin panel appears only for
> accounts that the server has granted administrator rights and that passed two-factor authentication. It is used to
> process user reports, verify specialists manually and manage partner listings.
>
> **Optional features:** voice commands for the differential counter (microphone + on-device speech recognition,
> off by default); daily reminder (local notification only); content packs downloaded from raw.githubusercontent.com
> (data only: JSON/images, no executable code); camera/photo library only when the user attaches a document photo
> or screenshot.
>
> **Account deletion:** Profile → Privacy → Delete account (removes server data, incl. questions/answers).
> **Support:** labguide@nfcstore.uz. **Privacy policy:** [URL].
> There are no hidden, dormant or undocumented features; features not listed above are not in this build.

## 4. Guideline 1.2 — foydalanuvchi kontenti (lib/features/community)

> **1.2** — apps with UGC must include: “A method for filtering objectionable material from being posted”,
> “A mechanism to report offensive content and timely responses to concerns”, “The ability to block abusive
> users from the service”, “Published contact information so users can easily reach you.” [V]

| Talab | Holat | Dalil (kod) | Qilingan ish / kerak |
|---|---|---|---|
| **Filtrlash** | **Bor (2026-10-18, D-62)** | Server: email/telefon raqam (`contact_data`), matn uzunligi, kunlik limitlar; **so'z filtri** `cloudflare/src/moderation.ts` + ro'yxat `cloudflare/data/abuse_words.json` (uz lotin/kirill, ru, en): savol (sarlavha+matn) va javob yaratishda `400 abusive_language`, ilova uz/ru/en da tushunarli xabar (`cmErrAbusive`). Normallashtirish: katta-kichik harf, ё/е, o‘/g‘ apostroflari, lotin↔kirill o'xshash harflar, takror harflar, “с.у.к.а” kabi bo'lingan harflar. Moslik faqat butun so'z yoki aniq o'zak (so'z boshi) bo'yicha — tibbiy so'zlar (анализ, сукцинат, kalsiy, siydik, spermogramma, pH, бляшка, педикулёз…) testda o'tadi (`cloudflare/test/moderation.test.ts`). UGC faqat matn (rasm yo'q) — NCII yuklab bo'lmaydi | NCII taqiqi qoidalarda bor (`cmRulesC2`, 2026-10-18). Ro'yxatni kengaytirganda tibbiy so'zlar testi yashil qolsin |
| **Shikoyat** | **Bor** | Har post (savol/javob) ostida “Shikoyat” (sabab ro'yxati: spam, noto'g'ri, haqorat, soxta mutaxassis, bemor ma'lumoti, boshqa); server 3 hisoblangan shikoyatda muallifni avtomatik to'xtatadi (`REPORT_THRESHOLD=3`), admin navbati va tiklash bor | **“Timely response”**: ichki SLA yozilsin (masalan 24 soat) va Privacy/qoidalarda aytilsin; admin navbati kunlik ko'riladi (egasi) |
| **Bloklash** | **Bor (2026-10-18, D-62)** | Server `author.ref` = HMAC(server kaliti, `author-ref:`+user_hash) ning 24 belgisi — barqaror, muallifga qaytarilmaydi (id, email, `user_hash` chiqmaydi; testda tekshirilgan). `POST/GET/DELETE /v1/community/blocks` (migratsiya `0011_community_blocks.sql`): blok hisobga yoziladi, server savollar ro'yxati va javoblarda shu ko'ruvchiga bloklangan muallifni ko'rsatmaydi; ilova lokal ro'yxatni ham saqlaydi va hisobdagilar bilan sinxronlaydi | Egasini (LabGuide jamoasi) va o'zini bloklab bo'lmaydi (unga shikoyat). Hisob o'chirilganda bloklar ham o'chadi |
| **Aloqa ma'lumoti** | **Bor** | Profil → Aloqa (`ContactScreen`, `Contact.email = labguide@nfcstore.uz`) | **Qilindi:** hamjamiyat ro'yxati ostida to'g'ridan-to'g'ri “LabGuide bilan aloqa” havolasi. ASC “Support URL” va Play email maydonlarini to'ldiring |

**Shikoyat va o'z vaqtida ko'rib chiqish (2026-10-17, admin panel):** Profil → Aloqa va shikoyat ekranida
ilova ichidagi shikoyat shakli (turlar: shikoyat, nomaqbul kontent, xato, reklama, boshqa; mehmon ham; soatiga 5 ta;
`POST /v1/complaints`). Egasi Admin panel → “Ilova shikoyatlari” va “Hamjamiyat shikoyatlari”da ko'radi, izoh
yozadi, hal qiladi, post muallifini to'xtatadi yoki hisobni butunlay to'xtatadi; har amal jurnalda. Ichki maqsad —
24 soat. Qo'llanma: `docs/ADMIN_PANEL_GUIDE.md`. App Review izohida shu yo'llarni ko'rsating.

**1.2 tekshiruv ro'yxati (2026-10-18):** filtr ✓ (server, uz/ru/en), shikoyat ✓ (har post, 3 shikoyat →
avtomatik yashirish, admin navbati, ichki maqsad 24 soat), bloklash ✓ (`author.ref` + server bloklari), aloqa ✓
(`labguide@nfcstore.uz`, hamjamiyat ekranidan havola), dasturchi kontentni olib tashlay oladi ✓ (admin postni
o'chiradi, muallifni to'xtatadi, hisobni o'chiradi — D-63). NCII taqiqi qoidalar matniga qo'shildi (`cmRulesC2`).

**5.1.2(i) — uchinchi tomon AI bilan ulashish [V guidelines matni]:** “You must clearly disclose where personal
data will be shared with third parties, including with third-party AI, and obtain explicit permission before doing
so.” Bizda: (a) mutaxassis hujjati surati Cloudflare Workers AI’ga yuboriladi — ekranda ochiq tushuntirish va aniq
“Send for automatic check” tugmasi bor (`cmVerifyInfo`); (b) post tarjimasi — foydalanuvchi “Tarjima qilish”ni
bosadi. **Tavsiya (kichik, hozir qilinmadi):** hujjat yuborishdan oldin alohida belgi (checkbox) “AI bilan
tekshirishga roziman” — reviewer “explicit permission” ni qat'iy o'qisa, shu eng xavfsiz yo'l. Egasi qarori.

## 5. Guideline 2.3.14 va do'kon grafikalari

> **2.3.14** — creative assets “must pertain to your app's content and functionality or overarching brand, follow
> standard metadata guidelines, and be appropriate for all audiences. They should not include inappropriate content,
> references to other apps with an intent to mislead, unverifiable product claims, or specific or discounted pricing
> information.” [V]

Qoida: skrinshot, app preview, header/qidiruv natijasi grafikalarida **narx, chegirma, “eng yaxshi/№1/kafolat”,
boshqa ilova bilan taqqoslash, tekshirib bo'lmaydigan raqam** bo'lmasin.

| Joy | Topilma | Qaror |
|---|---|---|
| `docs/store/APP_STORE.md` (subtitle, promo text, tavsif, kalit so'zlar) | Narx/chegirma yo'q. “119 karta, 43 holat” — tekshiriladigan raqam (kontent o'zgarsa yangilang). “manbalari bilan” — to'g'ri. | OK. Eskirgan joylar: “server yo'q” (3.2-band) |
| `docs/store/screenshots/*` | 7–8 ta ekran, to'lov oynasi yo'q | OK. **Keyin** to'lov oynasini skrinshotga qo'shmang (narx = 2.3.14); review screenshot (IAP uchun) alohida va ommaviy emas |
| D-57 asosi: “ChatGPT 228 000 so'm” | **Do'kon matni/grafikasi/reklamada ishlatmang**: boshqa mahsulot bilan taqqoslash + tekshirib bo'lmaydigan da'vo + aniq narx | Ichki hujjatda qolsin |
| `tool/video/promo_lines/lines_*.json` | Narx yo'q. **Ehtiyot talab qiladigan jumlalar:** “**rasmiy** savollar”, “**rasmiy** kalit” (l08, l09, s08-qismi: toifa savollari qoralama, rasmiy emas — `APP_STORE.md`); d01 “tahlil natijasini **to'g'ri talqin qilishga yordam**” va d05 “qaysi ko'rsatkich nimaga ishora qilishi” (ilova esa “talqin qilmaydi” deydi — **tibbiy qurilma deb o'qilishi mumkin**, 8-bo'lim); l10 “**Ishonchli** laboratoriya amaliyoti” (subyektiv da'vo) | Ommaviy do'kon grafikasi/preview uchun: “rasmiy” → “namunaviy / o'quv”, “talqin” → “kontekst bilan tushunish uchun ma'lumotnoma”. Kontent egasi tasdiqlaydi; hozir fayllarga tegilmadi |
| `screen_promo_lines_uz.json` | “Toifa imtihoniga tayyorlaning: rasmiy savollar” | Yuqoridagi kabi |
| Kelajak reklama roliklari (D-50) | Pro/Ustoz narxini ko'rsatmang; “AI” so'zi — ilova LLM chaqirmaydi (D-47a) | “AI” demang |

## 6. Yosh reytingi savolnomasi — aniq javoblar (ASC → App Information → Age Ratings)

Asos: Apple ta'riflari [V] `help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/`
va `.../set-an-app-age-rating/`. Kodga tayanib: hamjamiyat — faqat **matnli** savol-javob, ommaviy ro'yxat,
ovoz berish (faqat tasdiqlangan mutaxassis), eng yaxshi javob; **profil, kuzatish, ulashish, to'g'ridan-to'g'ri xabar,
lenta algoritmi yo'q**; muallif anonim.

| Savol/bo'lim | Javob | Asos |
|---|---|---|
| Parental Controls | **None** | Ilovada ota-ona boshqaruvi yo'q |
| Age Assurance | **None** | Yosh tekshiruvi/Declared Age Range ishlatilmaydi (7-bo'lim) |
| Unrestricted Web Access | **No** | Ichki brauzer/WebView yo'q (`pubspec`da webview yo'q); havolalar tashqi brauzerda |
| **User-Generated Content** | **Yes** | “Broad distribution of content created by users … as a component of the app's intended user experience” — savol-javoblar ilova ichida hamma ko'radi. Reytingga ta'siri: 4+ darajasida, qo'shimcha cheklov yo'q |
| **Messaging and Chat** | **Yes** (ehtiyotkor) | Ta'rifga “public posting” kiradi; to'g'ridan-to'g'ri xabar yo'q. Reytingga ta'siri yo'q (4+). Konservativ javob 2.3.6 xavfini kamaytiradi |
| **Social Media** | **No** — *asoslangan, lekin chegaradosh* | Ta'rif: UGC ni “social feed or similar discovery method that visibly spreads content to many users” orqali qayta tarqatish/kuchaytirish/muloqot (view, like, comment, share). Bizda: tavsiya/lenta algoritmi yo'q (kronologik ro'yxat va mavzu bo'yicha ro'yxat), **ulashish yo'q, kuzatish yo'q, profil yo'q**, “ovoz” faqat tasdiqlangan mutaxassislar tomonidan sifat belgisi. Bu — moderatsiyalangan mutaxassis forumi. **Yes** ga o'tish sharti: lenta/“trend”, ulashish, kuzatish, hamma ovoz bera olishi, profillar, DM. Agar Apple review “Yes” desa: reyting 13+ (Avstraliyada 16+) + “Social Media” descriptor + Time Allowances (iOS 27) da Social Media toifasiga tushadi → o'quv ilovasi uchun noqulay |
| Social Media Disabled for Users Under 13 | **N/A** | “Social Media” = No bo'lgani uchun to'ldirilmaydi |
| Advertising | **No** | Reklama yo‘q: hamkor UI hech bir buildda yoqilmaydi (`LG_PARTNER_ADS=false`) |
| **Medical or Treatment Information** | **Infrequent** | Ta'rif: “diagnoses or guidance around the management of medical conditions … medication guidance, emergency medical care, treatment information.” Ilova tashxis/davolash/doza bermaydi; me'yor, talqin uchun kontekst, “davolash maqsadlari” (KDIGO kabi, eskirganlari olib tashlangan) cheklangan. **Natija: 13+** (Apple jadvali: infrequent medical → 13+; frequent → 16+, Avstraliyada ham 16+). “Frequent” tanlansa 16+ bo'ladi — mazmun kengaysa qayta ko'ring |
| Health or Wellness Topics | **None** | Dieta/mashq/kaloriya yo'q |
| Mature or Suggestive Themes | **None** | — |
| Sexual Content or Nudity | **None** | Spermogramma va sitologiya — laboratoriya ko'rsatkichlari/mikrofotografiyalar, jinsiy kontent emas |
| Profanity or Crude Humor; Horror/Fear | **None** | — |
| Alcohol, Tobacco, or Drug Use or References | **None** (agar toksikologiya/spirt markerlari kartalari bo'lsa — *Infrequent*; reyting 13+ da qoladi) | Kontentni tekshirib tasdiqlang |
| Violence (cartoon/realistic/graphic), Guns or Weapons | **None** | — |
| Gambling, Simulated Gambling, Contests, Loot Boxes | **None / No** | — |
| Age Categories and Override | **Not Applicable** (Made for Kids ishlatilmaydi) | Ilova bolalar uchun emas; Kids category 1.3/5.1.4 talablarini keltirib chiqaradi |
| Age Suitability URL | ixtiyoriy | — |

**Kutilgan global reyting: 13+.** Ilova shartlarida (Terms/Maxfiylik) minimal yosh 13 dan past bo'lmasin va
reytingga mos yozilsin (COPPA/GDPR-K).

**Eslatma — “Social Media” savoli majburiy bo'lish sanasi:** Apple “September 2026” deydi (kun yo'q) [V]; bugundan
beri yangi versiya yuborishda javob talab qilinadi. Bu hujjatdagi javoblarni ASC’da kiritishdan oldin
kontentga qarab yana bir marta tekshiring.

### 6.1 Google Play ekvivalentlari

| Play Console bo'limi | Taklif javob | Asos |
|---|---|---|
| **Content rating (IARC)** — category | “Reference, News, or Educational” | O'quv/ma'lumotnoma ilovasi |
| IARC: zo'ravonlik, jinsiy, til, giyohvand, qimor | **No** (6-jadvaldagi kabi) | — |
| IARC: UGC / foydalanuvchilar o'zaro aloqasi / kontent almashish | **Yes** (savol-javob) | Natijada “Users Interact” belgisi bo'lishi mumkin [?]; kutilgan reyting — yoshi kichik bolalar uchun emas, aniq natijani IARC beradi |
| IARC: joylashuv ulashish | No | — |
| IARC: raqamli xaridlar | Yes (to'lov yoqilganda) | — |
| **Target audience and content** | Yosh guruhlari: **16–17 va 18+** (13–15 ham mumkin; **13 dan past tanlanmasin**) | Bolalarga yo'naltirilmagan |
| **Families / Designed for Families** | **No** | Families siyosati shart emas; “appeals to children”: No |
| **Data safety** | Mavjud jadval (`docs/store/APP_STORE.md` §12) + **o'chirish** savoli | Email, User IDs, Other UGC, App interactions (son), (ixtiyoriy) Photos — *ephemeral*; Ads: **Yes**; “data deletion”: in-app + **veb-havola** (quyida) [V] |
| **Account deletion (Play)** | ilovada yo'l ✓ + **veb sahifa URL’i** (Play shart qiladi) | `support.google.com/googleplay/android-developer/answer/13327111` [V]: ilova yoki dasturchi nomi, topish oson. Maxfiylik sahifasi yetarli bo'lishi uchun unda “Delete account” bo'limi bo'lsin (hozir bor) |
| **Health apps declaration** | Medical → **“Medical Reference and Education”** (va, ehtimol, “Clinical Decision Support” ni *tanlamang*); “Medical Device Apps” — **No** | Play: [V] `answer/14738291`; ilova qaror qabul qilish vositasi emas |
| **User-generated content policy** | Foydalanuvchi shartni qabul qilsin (savol berishdan oldin qoidalar kartasi/ekrani), shikoyat + **bloklash** (ilovada) | `answer/9876937` [V]; blok — 4-bo'lim |
| **Target API level** | Yangi ilova/yangilanish **API 36 (Android 16)**, muddat **2026-08-31** (uzaytirish 2026-11-01 gacha) | [V] `answer/11926878`. Flutter 3.47.6 `targetSdkVersion = 36` (SDK manbasida tekshirildi) ✓ |
| **Play Age Signals API** | Google **majburiy qilmaydi** [V] `answer/16569691`; qonun qo'llanishini o'zimiz hal qilamiz | 7-bo'lim |
| Ads declaration | Yes | Hamkor reklamalari |

## 7. Declared Age Range API va yosh tekshiruvi qonunlari

[V] manbalar: `news/?id=f5zj08ey`, `news/?id=sg176nne`, `news/?id=btkirlj8`, `developer.apple.com/support/age-assurance`.

| Joy | Apple matni (qisqa) | Sana |
|---|---|---|
| **Texas (SB 2420)** | 18 yoshgacha uchun yosh tekshiruvi va ota-ona roziligi (yuklab olish, IAP, muhim yangilanish); dasturchi: Declared Age Range, Significant Change API (PermissionKit), roziligi bekor qilinganda server bildirishnomasi, StoreKit `ageRatingCode`, sandbox sinovi | 2026-06-04 dan yangi Apple hisoblari |
| **Utah** | yangi hisoblar: yosh toifalari API orqali beriladi | **2026-05-06** (Apple); ikkinchi darajali manbalar 2027 ga surilganini aytadi [? tasdiqlanmagan] |
| **Louisiana** | xuddi shunday | **2026-07-01** (Apple) [yuqoridagi izoh] |
| **Brazil, Australia, Singapore** | **18+** ilovalarni yuklab olish yoshi tasdiqlanmaganlarga bloklanadi (App Store avtomatik) | 2026-02-24 |
| Apple Q&A | “In regions where legally required, you need to check the age of the people using your app with the Declared Age Range API.” Sahifa 4+/UGC-siz ilovalar uchun istisno bor-yo'qligini **aytmaydi**; qonun nomlarini keltirmaydi; yurist bilan maslahat | [V] |
| Google | Play Age Signals API **majburiy emas** | [V] |

**Bizga tegishlimi? — unsure.** Dalillar: (a) ilova 18+ emas (Braziliya/Avstraliya/Singapur bloki tegmaydi); (b) maqsadli
auditoriya — kasb egalari va talabalar, voyaga yetmaganlar (17 yosh, kollej) bo'lishi mumkin; (c) Texas qonuni
IAP’ni ham qamraydi (to'lov yoqilganda Apple ota-ona roziligini o'zi so'raydi); dasturchi majburiyati qanday yozilgan
— qonun matni/yurist; (d) bizning “age assurance”imiz yo'q va “Social Media Disabled <13” belgilanmaydi.

**Tavsiya.** Hozir kod yozilmadi (aniq majburiyat tasdiqlanmagan; yig'ilgan ma'lumotni saqlash/kuzatish xavfi bor).
Ish: (1) yurist/Apple Developer Support’dan yozma javob: “13+ o'quv/ma'lumotnoma ilovasi, UGC bor, IAP bor —
Texas/Utah/Louisiana qonunlari bo'yicha Declared Age Range va Significant Change API majburiymi?”; (2) majburiy
bo'lsa — eng kichik amalga oshirish: Pro xaridi ekranida va hamjamiyatda savol berishdan oldin API’dan yosh toifasini
so'rash; voyaga yetmaganlarda UGC yozishni o'chirish; “muhim o'zgarish” (yangi pullik funksiya) da Significant Change
API; ota-ona roziligi bekor qilinganda App Store Server Notification (`RESCIND_CONSENT`) ni serverda qayta ishlash.
(3) To'lovni yoqishdan oldin shuni hal qiling.

## 8. Tibbiy qurilma holati (regulated medical device)

[V] `news/?id=nyqbfz1y`: 2026-03-26 dan App Store EEA, Buyuk Britaniya va AQShda ilova sahifasida “regulated medical
device” holatini ko'rsatadi. **Deklaratsiya shart**, agar (a) birlamchi/ikkilamchi toifa **Health & Fitness yoki
Medical**, yoki (b) yosh reytingi savolnomasida **frequent Medical or Treatment Information**. Yangi ilovalar — hozir;
mavjudlar — **2027 boshigacha** (aks holda yangilanish yuborib bo'lmaydi). Hujjat: `help/app-store-connect/manage-app-information/declare-regulated-medical-device-status`.

- Bizda ikkilamchi toifa **Medical** (`APP_STORE.md` §1) → **deklaratsiya majburiy** (hatto savolnomada “Infrequent”
  bo'lsa ham).
- **Taklif javob: “No”** (ilova tibbiy maqsadda tashxis/profilaktika/monitoring/davolash uchun emas; o'quv va
  ma'lumotnoma, natijani talqin qilmaydi). Qaror **regulyator tasnifiga** bog'liq (EU MDR/IVDR, FDA, UK) —
  yurist/regulyator maslahati. Tavsiya: ikkilamchi toifani **Reference/Medical** o'rniga qayta ko'rib chiqing (Medical
  toifasi shu deklaratsiyani va reviewer e'tiborini oshiradi); qaror egasida.
- Promo matnlarida “talqin qilishga yordam beradi” kabi jumlalar (5-bo'lim) shu javobga zid o'qilishi mumkin.

## 9. Privacy manifest va required-reason API

[V] `news/upcoming-requirements/` — “Approved reasons for APIs (Since May 1, 2024): You'll need to include approved
reasons for the listed APIs used by your app's code (including from third-party SDKs) to upload a new or updated app”.
[V] `support/third-party-SDK-requirements/`: ro'yxatdagi SDK’lar (Flutter ham) manifest + imzo bilan kelishi kerak.

Tekshiruv natijasi:

- **`ios/Runner/PrivacyInfo.xcprivacy` yo'q edi.** Qo'shildi va `project.pbxproj` da Runner “Resources” ga ulandi.
- Runner’ning o'z kodi (`AppDelegate.swift`, `SceneDelegate.swift`) required-reason API (UserDefaults, fayl
  vaqt belgilari, tizim yuklanish vaqti, bo'sh joy, klaviatura tillari) **ishlatmaydi** → `NSPrivacyAccessedAPITypes` bo'sh;
  test shuni tekshiradi (kod o'zgarib API paydo bo'lsa test yiqiladi).
- Plaginlar o'z manifestini olib keladi (pub-cache’da tekshirildi): `shared_preferences_foundation` (UserDefaults,
  `1C8F.1`), `flutter_secure_storage_darwin`, `share_plus`, `image_picker_ios`, `in_app_purchase_storekit`,
  `flutter_local_notifications`, `url_launcher_ios`, `wakelock_plus`. **Manifest topilmadi:**
  `path_provider_foundation`, `audioplayers_darwin`, `speech_to_text`, `pdfium_flutter`, `pdfrx` — ularning manba
  kodida required-reason API qidirildi va topilmadi (grep), lekin ikkilik (`Flutter.framework`, PDFium)
  ichini tekshirib bo'lmaydi. **Haqiqiy tekshiruv:** Xcode → Product → Archive → Organizer →
  “Generate Privacy Report”; App Store Connect yuklashda `ITMS-91053` (missing API declaration) ogohlantirishi
  kelsa, kerakli sabab kodi `Runner/PrivacyInfo.xcprivacy` ga yoziladi.
- Manifestdagi `NSPrivacyCollectedDataTypes`: Email, User ID, Other User Content, Product Interaction —
  hammasi *Linked*, *Tracking=false*, maqsad *App Functionality*; `docs/store/APP_STORE.md` §6 jadvali bilan bir xil
  (server ulangan build). **App Store Connect “App Privacy” javobi shu bilan bir xil bo'lsin.**
- `NSPrivacyTracking=false`, kuzatuv domenlari yo'q (ATT, IDFA, reklama SDK’i yo'q).

## 10. Xcode / SDK talablari va CI

- **Amaldagi (2026-04-28 dan) [V]:** App Store Connect’ga yuklangan ilova **Xcode 26+ va iOS 26 SDK** bilan qurilishi
  shart. CI: `macos-15` runner, `Xcode_*.app` ichidan beta bo'lmagan eng yangisi tanlanadi; major < 26 bo'lsa faqat
  `::warning::` (qadam muvaffaqiyatsiz bo'lmaydi). IPA tekshiruvi “SDK” ni ham ko'radi.
- **Kelajak (2027-aprel) [V yangilik]:** iOS 27 SDK / Xcode 27. “Xcode 27 Release Candidate” 2026-09-09 da chiqqan;
  GitHub `macos-15` image’ida Xcode 27 bo'lishi tasdiqlanmagan [?] — `macos-26` image kerak bo'lishi mumkin.
- **Tavsiya (ci.yml — boshqa muhandis):** (1) Xcode major < 26 bo'lsa qadamni *muvaffaqiyatsiz* qiling;
  (2) 2027-yanvargacha runner image’ini va Flutter (3.47.6) ning Xcode 27 bilan mosligini sinang;
  (3) `IPHONEOS_DEPLOYMENT_TARGET = 15.0` ≥ 13 ✓.
- Android: yuqorida (API 36 ✓).

## 11. EU DSA “trader” holati

[V] `upcoming-requirements`: trader holatisiz ilovalar **EU App Store’dan olib tashlanadi** (2025-02-17 dan); EU’da
yangilanish yuborish uchun ham kerak (2024-10-16 dan). Hujjat: `help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/`.
- Bizga: **yes**, agar ilovani EU davlatlarida tarqatsak (sukut bo'yicha ha). Obuna va reklama bo'lgani uchun
  “trader” deb belgilash ehtimoli yuqori [unsure — yurist].
- Qilish: ASC → Business → Compliance → Digital Services Act: trader yoki non-trader, aloqa manzili/telefon/email
  (ommaviy ko'rinadi) kiriting; yoki ilovani EU’dan chiqarib qo'ying. TestFlight uchun kerak emas, lekin birinchi
  ommaviy yuborishdan oldin tayyor bo'lsin.

## 12. 4.8 Login Services va Sign in with Apple

> **4.8** — “Apps that use a third-party or social login service (such as Facebook Login, Google Sign-In, …) to set up
> or authenticate the user's primary account … must also offer as an equivalent option another login service with
> the following features: limits data collection to the user's name and email address; allows users to keep their
> email address private; does not collect interactions with your app for advertising purposes without consent.” [V]
> Istisno: ilova **faqat** o'z hisob tizimidan foydalansa [V].

- Hozir (email-OTP) → istisno amal qiladi. **Google qo'shilgach** istisno yo'qoladi → **Sign in with Apple** kerak.
- **Sign in with Apple 4.8 uch bandini ham bajaradi** (ism+email, “Hide My Email” orqali yashirin email, reklama uchun
  kuzatuv yo'q) — shuning uchun “Google + Apple + email” yig'indisi 4.8 ga mos. Reviewer uchun Apple tugmasi Google bilan
  **teng ko'rinishda va xuddi shunday joyda** bo'lsin (HIG: Apple tugmasi odatda birinchi).
- Qo'shimcha (boshqa muhandis uchun): (a) **Apple relay domen** `private.icloud.com` yangi manzillar uchun (2026
  oxirigacha) [V `news/?id=1ptvdtcm`]: server `normalizeEmail` hozir domen cheklamaydi ✓ (faqat `EMAIL_RE`); ilovada ham
  domen ro'yxati bo'lmasligi kerak; (b) **hisobni o'chirishda SIWA tokenini bekor qilish** (revoke) — Apple’ning
  hisobni o'chirish talabi (TN3194) [?: TN matni o'qilmadi, `news/?id=j9zukcr6` havolasida keltirilgan]; (c) Resend orqali
  xat yuboriladigan domen Apple Private Email Relay’da ro'yxatdan o'tmasa, relay manzillarga xat yetmasligi mumkin [?:
  umumiy bilim, hujjat o'qilmadi]; (d) 5.1.1(v): hisob yaratish bor → ilova ichida o'chirish bor ✓ (Profil → Maxfiylik);
  (e) 5.1.1(v) bo'yicha ijtimoiy tarmoq hisobini ilova ichidan uzish yo'li (Google/Apple ulanishi) — Google qo'shayotgan
  muhandis bilan kelishing.

## 13. Obuna, narx, shaffoflik

> KELAJAK — bu versiyada to'lov yo'q (D-58); quyidagilar to'lov qaytganda kerak bo'ladi (kod `pro-later` branchida).

- **3.1.2(a):** davr kamida 7 kun (bizda 1 oy/1 yil ✓); obuna barcha qurilmalarda ishlaydi (hisobga bog'langan
  server tekshiruvi ✓); xarid uchun qo'shimcha harakat (ijtimoiy tarmoqda post va h.k.) talab qilinmaydi ✓ [V].
- **3.1.2(c):** obunadan oldin nima olinishini va narxni aniq yozing; Schedule 2 (nom, davr, narx, avtomatik uzaytirish,
  bekor qilish, Terms/Privacy havolalari) — `PurchaseScreen` da bor (`payDisclosure`, `payRestore`, `payManage`, `payTerms`,
  `payPrivacy`, testlar) ✓. Narx **do'kondan** olinadi, kodda yozilmagan ✓ (D-57 tekshiruvi).
- **Bepul sinov** (Introductory Offer): Pro/talaba 7 kun, Ustoz Pro 14 kun (D-49). Muddati va keyingi narx to'lov
  oynasida ko'rinadi (“7 kun bepul, keyin $X / oy”) ✓.
- **Narxni o'zgartirish:** hali sotuvda emas; keyin oshirish — mavjud obunachilardan Apple roziligi (bildirishnoma)
  talab qilishi mumkin. Apple chegara jadvali (`help/app-store-connect/reference/auto-renewable-subscription-price-increase-thresholds`)
  qidiruv parchasida O'zbekiston uchun “USD, 6 (oylik), 60 (yillik)” ko'rsatilgan [?: ma'nosi tasdiqlanmagan —
  sahifani o'zingiz oching].
- **Apple UZS narx pog'onalari:** ochiq rasmiy sahifada topilmadi. ASC → obuna → Subscription Prices → O'zbekiston →
  “All prices” ro'yxatidan **39 000 va 269 000 ga eng yaqin** pog'onani tanlang (D-57).
- **Multiseat purchasing** 2026-09-16 dan obunalar uchun *sukut bo'yicha yoqilgan* [V]. Pro (individual) uchun kerak
  bo'lmasa o'chiring; **Ustoz Pro uchun** (maktab/kollej) — Volume Purchasing (2026-10-22) imkoniyatini
  keyinroq ko'rib chiqing. Qaror egasida.
- **Monthly subscription with 12-month commitment** [V] — ixtiyoriy, hozir kerak emas.
- **Obunalar guruhi darajalari:** 1 — Ustoz Pro (endi eng qimmat, D-57), 2 — Pro, 3 — talaba.

## 14. Egasi bajaradigan ishlar — ro'yxat (tartib bilan)

**Review'dan oldin (blokerlar):**
- [ ] `store` build rejimi (ci.yml, boshqa muhandis) — `LG_PARTNER_ADS` siz (`false`): reklama UI yo'q.
- [x] Serverda `author.ref` (blok uchun) va server bloklari — 4-bo'lim (D-62).
- [ ] Review demo hisobi (sobit kod) va u Notes’da ochiq yozilishi.
- [ ] Do'kon matni va **App Privacy** javobi build bilan mos: server ulanadi → “Data Not Collected” **emas**
      (`APP_STORE.md` §6 jadvali + `PrivacyInfo.xcprivacy`). “Ilova serverga ma'lumot yubormaydi” jumlasini olib tashlang.
- [ ] Age Ratings savolnomasi (6-bo'lim) — ASC’da kiriting; “Social media” savoliga javob.
- [ ] Regulated medical device status = No (8-bo'lim), DSA trader (11-bo'lim), App Privacy, Support URL, Privacy URL.
- [ ] Yangi Apple shartlarini (DPLA, 2026-08-18 / 2026-10-13) Account Holder sifatida qabul qilish.
- [ ] Notes for Review (3.3-bo'lim) — to'ldirib qo'yish.
- [ ] Hamjamiyat qoidalariga: NCII/intim rasmlar taqiqi bandi (matn); shikoyatlarga javob muddati (masalan 24 soat).
- [x] Haqorat filtri (server, uz/ru/en) — `cloudflare/data/abuse_words.json` (D-62).

**Qaror kerak:**
- [ ] Hujjat yuborishdan oldin AI roziligi belgisi (5.1.2(i)).
- [ ] Declared Age Range: yurist javobi (7-bo'lim).
- [ ] Ikkilamchi toifa Medical → qayta ko'rib chiqish (8-bo'lim).
- [ ] Multiseat/Volume Purchasing (13-bo'lim).
- [ ] Promo roliklarda “rasmiy/talqin/ishonchli” jumlalari (5-bo'lim).

**Keyinroq:** iOS 27 SDK (2027-aprel); mavjud ilova uchun medical device holati (2027 boshi); Play Console: Data safety, Health apps,
Content rating, deletion URL.

## 15. Ushbu ishda kodga kiritilgan o'zgarishlar

1. `ios/Runner/PrivacyInfo.xcprivacy` + `project.pbxproj` ulanishi; `test/unit/ios_privacy_manifest_test.dart`.
2. Hamjamiyatda foydalanuvchini bloklash (mahalliy): `CommunityAuthor.ref`, `StoreKeys.communityBlocked`,
   `CommunityController` (block/unblock/isBlocked/canBlock, qurilmada saqlash, “lokal ma'lumotni o'chirish”da tozalash),
   savol/javob ostida tugma, yashirish, “Bloklanganlar” paneli, aloqa havolasi, uz/ru/en matnlar; testlar
   (`test/widget/community_test.dart`, “1.2: foydalanuvchini bloklash”).
3. Narx hujjatlari: `DECISIONS.md` D-57, `PRO_BILLING_PLAN.md`; test fixture’ida Ustoz Pro `displayPrice` → `$6.99`.
