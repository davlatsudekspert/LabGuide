# App Store va TestFlight uchun materiallar

App Store Connect’ga kiritiladigan matnlar va javoblar. Hammasi ilovaning haqiqiy holatiga
mos: mehmon rejimida ilova serverga ma’lumot yubormaydi, hisob bilan nima saqlanishi —
[PRIVACY_POLICY.md](PRIVACY_POLICY.md) (2026-10-17, kodga qarab tekshirilgan); ilova tashxis
qo‘ymaydi, kontent ilmiy adabiyotga asoslangan o‘quv ma’lumotnomasi (D-65). Ilova o‘zgarsa, shu hujjat ham yangilanadi.

**Va’da qilinmaydigan narsalar:** hamkor reklamasi va hamkor statistikasi (do‘kon buildida
kompilyatsiyadan chiqarilgan, `LG_PARTNER_ADS`), murojaatga skrinshot biriktirish (serverda
yo‘q). **Pullik obuna/to‘lov:** bepul versiyada (`main`, D-58) yo‘q; **bu tarmoqda (`paid/pro-premium`, D-77) bor** —
unga 16-bo‘lim va `TERMS_OF_USE.md` tegishli, 1–15-bo‘limlardagi bepul versiya matnlari o‘zgartirilmagan.
Bepul versiya tavsiflarida hamkor reklamasi va murojaat skrinshoti tilga olinmaydi. D-65 (2026-10-18, egasi qarori): kontent “qoralama” deb
yozilmaydi — tavsifda manbalarga asoslangani va tibbiy eslatma (tashxis emas, natijani shifokor
baholaydi, referens oraliqlar laboratoriyaga bog‘liq) yoziladi; eslatmani olib tashlamang. Rus/ingliz tavsifida O‘zbekistonga xos
bo‘limlar (bilim va malakani baholash) yo‘q: ular faqat o‘zbek tili yoki UZ mintaqasida ko‘rinadi.
Tavsiflar 2026-10-10 holatiga yangilangan (119 karta, 43 holat).

## 1. Ilova yozuvi (New App)

| Maydon | Qiymat |
|---|---|
| Platforma | iOS |
| Name (≤ 30) | **LabGuide** (band bo‘lsa: “LabGuide UZ”) |
| Bundle ID | **uz.labguide.app** |
| SKU | `labguide-ios` |
| Primary category | **Education** |
| Secondary category | Medical |

Nega Education birinchi: ilova o‘quv va ma’lumotnoma vositasi; natija talqini, tashxis yoki
doza bermaydi (Apple 1.4.1 bo‘yicha tibbiy ilovalarga qo‘shimcha talablar qo‘yiladi).

## 2. Subtitle (≤ 30 belgi)

- uz: **Laboratoriya qo‘llanmasi** (24)
- ru: **Клиническая лаборатория** (23)
- en: **Clinical lab companion** (22)

## 3. Promotional text (≤ 170)

- **uz:** Tahlillar atlasi, klinik kalkulyatorlar, har kuni 5 ta savol, leykoformula va
  Westgard sifat nazorati — manbalari bilan, internetsiz.
- **ru:** Атлас анализов, клинические калькуляторы, 5 вопросов в день, лейкоформула и
  контроль качества по Вестгарду — с источниками, без интернета.
- **en:** Lab test atlas, clinical calculators, 5 daily questions, differential count and
  Westgard QC — with sources, fully offline.

## 4. Description (≤ 4000)

### uz
LabGuide — biokimyo va klinik laboratoriya uchun qo‘llanma: laboratoriya mutaxassisi, shifokor,
talaba va o‘qituvchi uchun.

• Tahlillar atlasi: 119 ta karta (glyukoza, HbA1c, kreatinin, lipidlar, jigar fermentlari,
elektrolitlar, gormonlar, gematologiya, siydik tahlili va boshqalar) va 43 ta holat. Har bir da’vo
manbaga bog‘langan: har kartada “Manba: muallif, yil, nom” ro‘yxati.
• Birliklar: SI (mmol/L, µmol/L) yoki an’anaviy (mg/dL) — Profilda tanlanadi; kalkulyatorlar
tanlangan tizimda boshlanadi. Moddaga xos birlik konvertori.
• Klinik kalkulyatorlar: eGFR (CKD-EPI 2021) va KDIGO kategoriyasi, albumin/kreatinin nisbati,
anion oralig‘i, albumin bo‘yicha tuzatilgan kalsiy, LDL (Friedewald, Sampson) va non-HDL,
osmolyallik, HbA1c NGSP ↔ IFCC va eAG. Har birida formula, cheklovlar va manba.
• Laboratoriya kalkulyatorlari: hisoblash kamerasi, leykoformula, retikulotsitlar, yorug‘lik
mikroskopi, rang ko‘rsatkichi, siydik cho‘kmasi (Nechiporenko, Addis, Zimnitskiy — klassik
usullar, belgi bilan), suyultirish.
• Leykoformula: qo‘lda sanash va “ko‘rmasdan sanash” (mikroskopdan ko‘z uzmay: tovush va tebranish
signallari), tarix va morfologiya atlasi.
• Mikroskopiya atlasi: litsenziyali mikrofotografiyalar, muallif va litsenziya ko‘rsatiladi.
• Jadvallar va algoritmlar: anemiya, soxta KQT natijalari, sariqlik, jigar sindromlari,
najas/parazitlar, eskirgan usullar.
• Kunlik savol: har kuni 5 ta savol, har javobdan keyin izoh va manba, ketma-ket kunlar
hisobi va ixtiyoriy mahalliy eslatma.
• Ichki sifat nazorati: Levey–Jennings grafigi, Westgard qoidalari (1-2s, 1-3s, 2-2s, R-4s,
4-1s, 10x), lot va maqsad tarixi, CSV eksport va zaxira nusxa.
• Preanalitika, analizator katalogi, izohli testlar, kutubxona (ochiq va rasmiy manbalar).
• Bilim va malakani baholash (o‘zbek tilidagi savollar; mashq natijasi rasmiy baho emas).

Uch tilda: o‘zbek, rus, ingliz. Internet shart emas. Hisobsiz (mehmon) ishlaydi — bu rejimda
ilova serverga ma’lumot yubormaydi.

Muhim: LabGuide o‘quv va ma’lumotnoma vositasi. U natijani talqin qilmaydi, tashxis qo‘ymaydi
va dori dozasini taklif qilmaydi. Natijalar klinik manzara va laboratoriyangiz referens
intervallari bilan birga baholanadi (referens oraliqlar laboratoriya va usulga bog‘liq).
Kontent ilmiy adabiyotga asoslangan; manbalar ilovada ko‘rsatilgan.

### ru
LabGuide — справочник по биохимии и клинической лабораторной диагностике для специалистов
лаборатории, врачей, студентов и преподавателей.

• Атлас анализов: 119 карточек (глюкоза, HbA1c, креатинин, липиды, печёночные ферменты,
электролиты, гормоны, гематология, анализ мочи и др.) и 43 состояния. Каждое утверждение связано
с источником: в каждой карточке список «Источник: автор, год, название».
• Единицы: СИ (ммоль/л, мкмоль/л) или обычные (мг/дл) — выбор в Профиле; калькуляторы
открываются в выбранной системе. Конвертер единиц для конкретного вещества.
• Клинические калькуляторы: рСКФ (CKD-EPI 2021) и категория KDIGO, отношение
альбумин/креатинин, анионный интервал, кальций с поправкой на альбумин, ЛПНП (Friedewald,
Sampson) и не-ЛПВП, осмоляльность, HbA1c NGSP ↔ IFCC и eAG. Для каждого — формула,
ограничения и источник.
• Лабораторные калькуляторы: счётная камера, лейкоформула, ретикулоциты, световая
микроскопия, цветовой показатель, осадок мочи (Нечипоренко, Аддис, Зимницкий —
классические методы, с пометкой), разведения.
• Лейкоформула: ручной подсчёт и режим «считать, не глядя» (не отрываясь от микроскопа: звуки и
вибрация), история и атлас морфологии.
• Атлас микроскопии: лицензированные микрофотографии, автор и лицензия указываются.
• Таблицы и алгоритмы: анемии, ложные результаты ОАК, желтухи, печёночные синдромы,
кал и паразиты, устаревшие методы.
• Вопрос дня: 5 вопросов в день, после каждого ответа — пояснение и источник, серия дней и
необязательное локальное напоминание.
• Внутрилабораторный контроль качества: карта Леви–Дженнингса, правила Вестгарда (1-2s, 1-3s,
2-2s, R-4s, 4-1s, 10x), история лотов и целевых значений, экспорт CSV и резервная копия.
• Преаналитика, каталог анализаторов, тесты с пояснениями, библиотека (открытые и официальные
источники).

Три языка: узбекский, русский, английский. Работает без интернета и без аккаунта (гостевой
режим) — в этом режиме приложение не отправляет данные на сервер.

Важно: LabGuide — учебный и справочный инструмент. Он не интерпретирует результаты, не ставит
диагноз и не предлагает дозы препаратов. Результаты оцениваются с учётом клинической картины и
референтных интервалов вашей лаборатории (интервалы зависят от лаборатории и метода).
Материалы основаны на научной литературе; источники указаны в приложении.

### en
LabGuide is a biochemistry and clinical laboratory companion for lab professionals, physicians,
students and teachers.

• Lab test atlas: 119 cards (glucose, HbA1c, creatinine, lipids, liver enzymes, electrolytes,
hormones, haematology, urinalysis and more) and 43 conditions. Every claim links to an open
source: every card lists “Source: author, year, title”.
• Units: SI (mmol/L, µmol/L) or conventional (mg/dL) — chosen in Profile; calculators start in the
chosen system. Analyte-specific unit converter.
• Clinical calculators: eGFR (CKD-EPI 2021) with KDIGO category, albumin/creatinine ratio,
anion gap, albumin-corrected calcium, LDL (Friedewald, Sampson) and non-HDL, osmolality,
HbA1c NGSP ↔ IFCC and eAG. Each shows its formula, limitations and source.
• Bench calculators: counting chamber, differential count, reticulocytes, light microscopy,
colour index, urine sediment counts (Nechiporenko, Addis, Zimnitsky — classic methods, labelled
as such), dilution.
• Differential count: manual counting and an “eyes-free” mode (keep your eyes on the microscope:
sounds and vibration cues), history and a morphology atlas.
• Microscopy atlas: licensed micrographs with author and licence shown.
• Tables and algorithms: anaemia, spurious CBC results, jaundice, liver syndromes, stool and
parasites, obsolete methods.
• Daily questions: 5 questions a day, an explanation and a source after each answer, a day
streak and an optional local reminder.
• Internal quality control: Levey–Jennings chart, Westgard rules (1-2s, 1-3s, 2-2s, R-4s, 4-1s,
10x), lot and target history, CSV export and backup.
• Preanalytics, an instrument catalogue, explained quizzes and a library of open and official
sources.

Three languages: Uzbek, Russian, English. Works offline and without an account (guest mode) —
in that mode the app sends no data to a server.

Important: LabGuide is a learning and reference tool. It does not interpret results, make a
diagnosis or suggest drug doses. Results are assessed together with the clinical picture and
your laboratory’s reference intervals (they depend on the laboratory and method). Content is
based on the scientific literature; the sources are shown in the app.

## 5. Keywords (≤ 100 belgi, vergul bilan, bo‘shliqsiz) — 2026-10-12 yangilandi

- uz (97): `klinik laboratoriya,KDL,biokimyo,laborant,tahlil,baholash,QC,Westgard,eGFR,leykoformula,preanalitika`
- ru (97): `КДЛ,клиническая лаборатория,биохимия,лаборант,анализы,контроль качества,Вестгард,СКФ,лейкоформула`
- en (95): `clinical laboratory,biochemistry,lab tests,medical lab,QC,Westgard,eGFR,hematology,preanalytics`

Nomda (title) bor so‘z keywords'da takrorlanmaydi (Apple ikkalasini birga hisoblaydi).

**Google Play'da kalit so‘z maydoni yo‘q** — qidiruv nom, qisqa va to‘liq tavsifdan olinadi
(+ "Store settings → Tags" dan 5 tagacha tayyor teg: Medical / Education).
- Nom (≤30): uz `LabGuide: KDL va biokimyo` · ru `LabGuide: КДЛ и биохимия` · en `LabGuide: Clinical Lab Guide`
- Qisqa tavsif (≤80):
  - uz `Klinik laboratoriya diagnostikasi va biokimyo: tahlillar, QC, baholash, kalkulyator`
  - ru `Клиническая лабораторная диагностика и биохимия: анализы, контроль качества`
  - en `Clinical lab diagnostics & biochemistry: lab tests, QC, calculators, exam prep`

## 6. App Privacy (Ma’lumotlar)

**Qaysi build qaysi javobga mos.** Server (Cloudflare Worker + D1, D-41/D-42) build vaqtida
`--dart-define=LG_API_URL=https://…` berilsa ulanadi (CI: secret/variable `LG_API_URL`).
- **`LG_API_URL` bo‘sh build** (2026-10-09 TestFlight 0.1.0 (3), (4) va Android run 13–14 shunday
  edi; `LG_SUPABASE_*` ham bo‘sh — Supabase endi ishlatilmaydi) — “server hali ulanmagan”:
  email kirish, guruhlar serverga hech narsa yubormaydi. Javob: **“Data Not Collected”**
  (Tracking: No). Ilova faqat foydalanuvchi o‘zi “Paketlar”da yuklashni bossa
  `raw.githubusercontent.com` dan statik JSON/fayl oladi (so‘rovda shaxsiy ma’lumot yo‘q,
  dasturchi saqlamaydi) va tashqi havolalarni brauzerda ochadi — bu Apple ta’rifi bo‘yicha
  “collection” emas. Analitika/crash SDK yo‘q.
- **`LG_API_URL` berilgan build** — email kirish va guruhlar ishlaydi. Shu build **birinchi**
  yuklanishidan oldin App Privacy quyidagi jadvalga o‘zgartiriladi (aks holda deklaratsiya
  noto‘g‘ri bo‘ladi). Provayderlar: Cloudflare (server/baza, Sharqiy Yevropa) va Resend (zaxirada Brevo) (faqat
  kirish kodi xati) — ikkalasi xizmat ko‘rsatuvchi, ma’lumot reklama/sotuv uchun berilmaydi.

**Tracking: No** (boshqa kompaniyalar ma’lumoti bilan birlashtirilmaydi, reklama identifikatori
yo‘q). Hamma toifalar — **Linked to the user**, **not used for tracking**. Mazmuni
`cloudflare/migrations` va `PRIVACY_POLICY.md` bilan bir xil.

| App Store toifasi | Nima (kodda) | Maqsad |
|---|---|---|
| Contact Info → Email Address | kirish emaili (serverda faqat HMAC-hash + niqoblangan ko‘rinish; Resend (zaxirada Brevo) orqali kod yuboriladi; Google/Apple bilan kirishda ham o‘sha email — provayder tasdiqlagani, D-56) | App Functionality |
| Identifiers → User ID | ichki tasodifiy hisob id si (`users.id`); Google/Apple bilan kirishda provayder `sub` i ham (`auth_identities`, D-56) | App Functionality |
| User Content → Other User Content | guruh taxallusi (yoki “Talaba NN”), test javoblari, har savol natijasi va ball | App Functionality |
| Usage Data → Product Interaction | oxirgi faollik **kuni** (`last_seen_on`) va daqiqaga yaxlitlangan oxirgi faollik vaqti (`last_seen_at`, faqat admin paneldagi umumiy “hozir onlayn” soni uchun; 0009) | App Functionality |
| User Content → Customer Support | “Taklif va yordam” murojaatlari (tur, mavzu, xabarlar; `support_threads`/`support_messages`) va ilova ichidagi shikoyatlar (`complaints`, mehmondan ham — identifikatorsiz) | App Functionality |
| User Content → Other User Content (hamjamiyat, D-43) | savol va javoblar matni (**ilova ichida ommaviy**, muallif ismsiz), ovozlar, shikoyatlar; mutaxassis holati (kasb, mamlakat kodi, sana) | App Functionality |

**Google / Apple bilan kirish (D-56).** Yangi toifa qo‘shilmaydi: server provayder tokenidan faqat `sub`, email va
tasdiq belgisini o‘qiydi (Apple’dan faqat email scope; Google’ning standart oynasi tokenga ism/rasm qo‘shishi mumkin,
lekin ular o‘qilmaydi va saqlanmaydi), token tekshirilgach tashlanadi — *Name* toifasi **qo‘shilmaydi**. Provayderlar (Google, Apple) — kirish identifikatsiyasi; ular bilan ma’lumot ulashilmaydi. Tracking: No.
Apple 4.8 (Apple tugmasi Google’dan kam emas, email-kod va mehmon rejimi bor) va 5.1.1(v) (ilovada hisobni o‘chirish +
Apple tokenini bekor qilish) bajarilgan — `docs/AUTH_SOCIAL_LOGIN.md`. App Review izohiga shuni yozing.

**Hamjamiyat (D-43) — hujjat surati va tarjima.** Mutaxassis tasdig‘i uchun yuklangan surat
faqat so‘rov davomida Cloudflare Workers AI ga uzatiladi va **saqlanmaydi** (D1/R2/log —
`cloudflare/test/community.test.ts` “FAYL SAQLANMAYDI” testi). Apple ta’rifi bo‘yicha real vaqtda
bir martalik qayta ishlash “collection” emas, shuning uchun **Photos or Videos qo‘shilmaydi**;
egasi ehtiyotkorlik uchun *Photos → App Functionality, Linked* deb belgilashni tanlashi mumkin
(qaror egasida). Tarjima uchun post matni Workers AI ga yuboriladi — bu allaqachon e’lon
qilingan User Content; tarjima keshlanadi. Ilovada kamera/galereya uchun
`NSCameraUsageDescription` / `NSPhotoLibraryUsageDescription` matnlari (mavjud image_picker)
hujjat tasdig‘ini ham, D-68 dan ilova ichidagi QR skanerni ham qamraydi (kadr qurilmada o‘qiladi,
saqlanmaydi — App Privacy’da yangi toifa yo‘q).

Rol va til sozlamasi ham hisobda saqlanadi — alohida App Store toifasi yo‘q, shuning uchun
yuqoridagilarga kiritilgan (talab bo‘lsa Other Data Types). **Diagnostics** (crash/performance)
to‘planmaydi: SDK yo‘q, Worker `observability` o‘chiq. IP faqat suiiste’molga qarshi hash-teg
sifatida ishlatiladi, saqlanmaydi (Location/Device ID yo‘q). **Customer Support** endi bor
(yuqoridagi jadval: murojaatlar `support.ts`, shikoyatlar `complaints.ts`, 0009). **Photos or
Videos** (murojaat skrinshoti) — server biriktirma qabul qilmaydi, qo‘shilmaydi. **Advertising
Data** — do‘kon buildida hamkor reklamasi yo‘q (`LG_PARTNER_ADS=false`), qo‘shilmaydi. Mehmon
rejimida hisob yo‘q; mehmon faqat ixtiyoriy shikoyat matnini yuborishi mumkin (identifikatorsiz).
Server ulanmagan buildda hech narsa yuborilmaydi.

**Mikrofon / nutqni tanish (leykoformula ovozli buyruqlari, ixtiyoriy, eksperimental):** iOS’da
`requiresOnDeviceRecognition` majburiy — ovoz qurilmadan chiqmaydi, ilova ovozni saqlamaydi va
yubormaydi, shuning uchun App Privacy’da **Audio Data qo‘shilmaydi** (“Data Not Collected” to‘g‘ri
qoladi). Info.plist: `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`
(uz/ru/en `InfoPlist.strings`). Kunlik eslatma — lokal bildirishnoma (push server yo‘q);
ulashish — tizim oynasi, `NSPhotoLibraryAddUsageDescription` faqat “Save Image” uchun.

**Privacy Policy URL** — majburiy. Matn: [PRIVACY_POLICY.md](PRIVACY_POLICY.md), sahifa
`site/privacy/index.html` (`python3 tool/site/build_site.py` bilan yasaladi). Taklif qilingan
manzil: `https://labguide.nfcstore.uz/privacy/` (joylash — `site/README.md`). Matnda sana
(2026-10-17) va aloqa (labguide@nfcstore.uz) — **egasi tasdiqlaydi**; ochiq savollar:
[PRIVACY_OPEN_QUESTIONS.md](PRIVACY_OPEN_QUESTIONS.md).

**Support / aloqa (App Store Connect “Support URL”, Play “Email address” / “Developer contact”):**
qo‘llab-quvvatlash aloqasi — **labguide@nfcstore.uz** (ilovada: Profil → Aloqa va shikoyat; kodda
`lib/core/contact.dart`). App Store Connect “Support URL” maydoni URL talab qiladi: bosh sahifa
`https://labguide.nfcstore.uz/` (`site/index.html`, unda aloqa emaili bor) — `mailto:` emas, haqiqiy
sahifa bering. Play Console Store listing → Contact details → Email: shu manzil. **Egasi manzil
ishlashini tasdiqlamaguncha (Cloudflare Email Routing → Gmail, sinov xati bilan) topshirmang.**
Manzil o‘zgarsa — `Contact.email`, PRIVACY_POLICY.md va do‘kon maydonlarini birga yangilang.

**Hisobni o‘chirish** (App Store 5.1.1(v)): ilovada Profil → Maxfiylik va ma’lumotlar → “Hisobni
o‘chirish” (server: `DELETE /v1/me`, `cloudflare/src/auth.ts` `deleteAccount` — profil, sessiyalar,
Google/Apple bog‘lanishi, a’zolik, javoblar va ball, murojaatlar, hamjamiyat ma’lumotlari; ustozning
guruhlari ham; ilova ichidagi shikoyat matni hisobdan uzilib qoladi; Apple tokeni bekor qilinadi).
Veb yo‘riqnoma: `https://labguide.nfcstore.uz/delete-account/` (`site/delete-account/index.html`).

## 7. Age rating

**To‘liq va yangi javoblar (2025-07 savolnomasi, 13+/16+/18+, “Social media” savoli bilan) —
[APPLE_2026_REQUIREMENTS.md](../APPLE_2026_REQUIREMENTS.md) 6-bo‘lim.** Qisqasi: Medical or
Treatment Information — **Infrequent** (natija **13+**); User-Generated Content — **Yes**; Messaging
and Chat — **Yes** (ommaviy savol-javob, DM yo‘q); Advertising — **No** (do‘kon buildida hamkor
reklamasi kompilyatsiyadan chiqarilgan, `lib/core/build_flags.dart`);
Social Media — **No** (lenta/ulashish/kuzatish yo‘q); qolganlari None. Yakuniy reytingni App Store
Connect hisoblaydi. Shuningdek: “regulated medical device” deklaratsiyasi (ikkilamchi toifa Medical
bo‘lgani uchun majburiy) — o‘sha hujjatning 8-bo‘limi.

> **Eslab qoling (2026-10-17):** CI sukut bo‘yicha `LG_API_URL` bilan quradi (email kirish,
> guruhlar, hamjamiyat, murojaatlar ishlaydi). Tavsiflar endi “mehmon rejimida serverga ma’lumot
> yubormaydi” deydi; §6 jadvali server ulangan buildga mos. Ommaviy yuborishdan oldin
> `ios/Runner/PrivacyInfo.xcprivacy` ham shunga mos bo‘lsin (Apple 2.3.1: aniq metadata).

## 8. Export compliance

`ITSAppUsesNonExemptEncryption = NO` (Info.plist’da, CI tekshiradi): ilova shifrlashdan faqat
tizim orqali foydalanadi, o‘z shifrlash algoritmi yo‘q.

## 9. TestFlight

**Beta App Description**
- uz: LabGuide — biokimyo va klinik laboratoriya qo‘llanmasi: tahlillar atlasi, kalkulyatorlar,
  sifat nazorati (Westgard), preanalitika va izohli testlar. Internetsiz, uch tilda.
- ru: LabGuide — справочник по биохимии и клинической лаборатории: атлас анализов,
  калькуляторы, контроль качества (Вестгард), преаналитика и тесты. Без интернета, три языка.
- en: LabGuide — a biochemistry and clinical lab companion: test atlas, calculators, quality
  control (Westgard), preanalytics and explained quizzes. Offline, three languages.

**What to Test** — CI (`mode=testflight`) har buildga en-US va ru matnini API orqali yozadi
(App Store Connect o‘zbek tilini qo‘llamaydi). Har matn boshida ogohlantirish turadi:
- uz: **Sinov build, ichki sinov uchun. Kontent — adabiyotga asoslangan o‘quv ma’lumotnomasi,
  tashxis emas; bemor bo‘yicha qarorlarda foydalanmang.** Tekshiring:
  ochish → mehmon → rol va til → tahlillar atlasi → kalkulyatorlar → leykoformula → imtihon.
- ru: **Тестовая сборка для внутреннего тестирования. Материалы — учебный справочник на основе
  литературы, не диагноз; не используйте их для решений по пациентам.**
- en: **Test build for internal testing. Content is an educational reference based on the
  literature — not a diagnosis; do not use it for patient care decisions.**

Qo‘shimcha (oldingi) yo‘riqnoma:
- uz: Rolni tanlang va bosh sahifani ko‘ring. Tahlillar atlasida qidiring (lotin va kirill
  yozuvida). Kalkulyatorlarda o‘z qiymatlaringizni kiriting — birlikni ataylab adashtirib
  ko‘ring. Laboratoriya → Sifat nazorati: test qo‘shing, bir necha seriya kiriting va Westgard
  xulosasini tekshiring. Tilni va mavzuni (yorug‘/qorong‘i) almashtiring. Xato yoki noaniq
  matnni skrinshot bilan yuboring.
- ru: Выберите роль и посмотрите главную. Поищите в атласе анализов (латиницей и кириллицей).
  Введите свои значения в калькуляторы — попробуйте намеренно перепутать единицы. Лаборатория →
  Контроль качества: добавьте тест, внесите несколько серий и проверьте вывод по Вестгарду.
  Переключите язык и тему. Ошибки и неточности присылайте со скриншотом.
- en: Pick a role and look at Home. Search the test atlas (Latin and Cyrillic). Enter your own
  values in the calculators — try mixing up units on purpose. Lab → Quality control: add a
  test, enter several runs and check the Westgard verdict. Switch language and theme. Send
  errors or unclear text with a screenshot.

Ichki test (Internal Testing) uchun Apple review kerak emas; tashqi test (External) uchun
Beta App Review, aloqa ma’lumotlari va maxfiylik siyosati havolasi kerak.

## 10. Skrinshotlar

Tayyor rasmlar: `docs/store/screenshots/<til>/NN_nom.png` (uz, ru, en; 1290×2796 px = 6.9"
iPhone, yorug' mavzu, shrift 1.0; uz 8 ta, ru/en 7 tadan): `01_home`, `02_analyte_glucose`
(manbalar ko'rinadi), `03_leukoformula`, `04_daily_result`,
`05_reference` (jadvallar va algoritmlar; D-65 dan oldin olingan — “qoralama” belgisi
eski, keyingi yangilashda qayta olinadi), `06_egfr`, `07_qc`
(Levey–Jennings), `08_toifa` (faqat uz).

Qayta yaratish: `flutter test tool/screenshots/store_screenshots_test.dart --update-goldens
--concurrency=1` — natija `tool/screenshots/out/store/<til>/` ga (gitignore), so'ng PIL
`optimize=True` bilan `docs/store/screenshots/` ga nusxalanadi.

## 11. Ikonka va grafikalar

Hammasi egasining logosidan (`python3 tool/icons/make_icons.py`, D-37):

| Fayl | Qayerga |
|---|---|
| `docs/store/app_store_icon_1024.png` | App Store (buildning AppIcon ichida ham bor — alohida yuklash shart emas) |
| `docs/store/google_play_icon_512.png` | Google Play Console → Store listing → App icon (512×512, shaffofsiz) |
| `docs/store/google_play_feature_graphic.png` | Google Play → Feature graphic (1024×500) |

## 12. Google Play — Data safety

**`LG_API_URL` bo‘sh build (server ulanmagan; hozirgacha yuklangan buildlar):**
“Does your app collect or share any of the required user data types?” — **No**.
Shifrlash/o‘chirish savollari bu holda so‘ralmaydi. Ads: **No**.

**`LG_API_URL` berilgan build (Cloudflare Worker + D1 ulangan)** — birinchi shunday build
yuklanishidan **oldin** Data safety quyidagicha to‘ldiriladi (manba: `cloudflare/src`,
`cloudflare/migrations`; matn `PRIVACY_POLICY.md` bilan bir xil):

| Savol | Javob |
|---|---|
| Ma’lumot to‘planadimi? | Ha (faqat email bilan kirilganda; mehmon rejimida hech narsa yuborilmaydi) |
| Uchinchi tomonga beriladimi (sharing)? | **Yo‘q** (Cloudflare — server/baza, Resend (zaxirada Brevo) — kod xati: xizmat ko‘rsatuvchi, LabGuide nomidan qayta ishlaydi; sharing emas) |
| Uzatishda shifrlanganmi? | **Ha** (HTTPS) |
| O‘chirishni so‘rash mumkinmi? | **Ha** — ilovada Profil → Maxfiylik → “Hisobni o‘chirish” va aloqa emaili labguide@nfcstore.uz |
| Personal info → Email address | To‘planadi; sinf (guruh) uchun majburiy, umuman ilova uchun **ixtiyoriy** (mehmon rejimida yo‘q); Account management, App functionality (serverda faqat hash + niqoblangan ko‘rinish) |
| Personal info → User IDs | To‘planadi; ichki hisob id si (tasodifiy) va Google/Apple provayder identifikatori (`sub`, D-56); Account management, App functionality |
| Account creation methods (Play so‘rasa) | **OAuth** (Google, Apple) va **Other authentication** (email kodi); mehmon rejimida hisob shart emas |
| App activity → Other user-generated content | To‘planadi; ixtiyoriy (sinfda); guruh taxallusi, test javoblari va ball; App functionality |
| App activity → App interactions | Oxirgi faol **kun** (`last_seen_on`) va daqiqaga yaxlitlangan oxirgi faollik vaqti (`last_seen_at`, faqat umumiy “hozir onlayn” soni uchun); App functionality — Play talab qilsa shu qatorni qo‘shing |
| Messages → Other in-app messages | To‘planadi; ixtiyoriy; “Taklif va yordam” murojaatlari (hisob bilan) va ilova ichidagi shikoyatlar (mehmondan ham, identifikatorsiz); App functionality. Shared: No |
| App activity → Other user-generated content (hamjamiyat, D-43) | To‘planadi; ixtiyoriy; savol/javob matni (**ilova ichida hamma ko‘radi**, muallif ismsiz), ovoz, shikoyat; App functionality |
| Photos and videos → Photos (hamjamiyat, D-43) | Ixtiyoriy; mutaxassis hujjati surati — **ephemeral processing: Yes** (faqat AI tekshiruvi vaqtida, saqlanmaydi); App functionality (hisobni tasdiqlash) |
| Location, Contacts, Financial, Health, Device or other IDs, Diagnostics | LabGuide o‘zi to‘plamaydi (skrinshot biriktirish serverda yo‘q; hamkor reklamasi do‘kon buildida yo‘q). **D-68 dan:** Android QR skaneridagi Google ML Kit SDK diagnostikasi — quyidagi izoh |

**Ovozli buyruqlar (RECORD_AUDIO, ixtiyoriy, eksperimental):** Android’da rejim faqat
qurilmada oflayn tanish mavjud bo‘lsa yoqiladi (`MainActivity` →
`SpeechRecognizer.isOnDeviceRecognitionAvailable`, Android 12+; speech_to_text `onDevice: true`
shu holda `createOnDeviceSpeechRecognizer` ishlatadi). Ovoz qurilmadan chiqmaydi, ilova uni
saqlamaydi — Data safety’da **Audio qo‘shilmaydi** (egasi qarori, 2026-10-09). Kunlik eslatma
(`POST_NOTIFICATIONS`) va ulashish ma’lumot to‘plamaydi.

**QR skaner (CAMERA, D-68, `mobile_scanner`):** kamera kadri faqat qurilmada o‘qiladi, saqlanmaydi
va yuborilmaydi — *Photos and videos* **qo‘shilmaydi**. QR dan olingan taklif kodi kod qo‘lda
yozilgandagi kabi guruhga qo‘shilish so‘roviga ketadi (yangi toifa yo‘q). Android’da bundled
Google ML Kit (barcode-scanning 17.3.0) Google’ga SDK diagnostikasini yuboradi (Google “ML Kit
Android data disclosure”: qurilma/ilova ma’lumoti, unumdorlik ko‘rsatkichlari, API sozlamasi,
foydalanuvchini aniqlash uchun mo‘ljallanmagan o‘rnatish identifikatori; HTTPS, uchinchi tomonga
berilmaydi). Play SDK ma’lumotini ilova to‘plagan deb hisoblaydi — tavsiya: *App info and
performance → Diagnostics* va *Device or other IDs* — **Collected, Shared: No**, maqsad *Analytics*
(Google’ning o‘z xizmati uchun), ixtiyoriy (faqat skaner ochilganda). Bu `LG_API_URL` bo‘sh
buildga ham tegishli (“No” javobi endi to‘g‘ri bo‘lmasligi mumkin) — yakuniy qaror egasida
(`PRIVACY_OPEN_QUESTIONS.md`). iOS: Apple Vision, uchinchi tomon SDK yo‘q; `NSCameraUsageDescription`
(uz/ru/en `InfoPlist.strings`) QR skanerni ham qamraydi.

Reklama: do‘kon buildida hamkor e’lonlari yo‘q (`LG_PARTNER_ADS=false`) — Play Console → App
content → **Ads: No**. Hisobni o‘chirish havolasi (Play talabi, “Delete account URL”):
`https://labguide.nfcstore.uz/delete-account/` (`site/delete-account/index.html`) + ilovadagi tugma.


## 13. Test tarqatish: holat va egasidan kerakli amallar

Faqat **ichki/yopiq test**. Production, App Store review, Play production — CI’da yo‘q.

### iOS — TestFlight (`mode=testflight`)
- Build raqami: App Store Connect’dagi eng oxirgi + 1 (run_number emas). Hozirgi: **0.1.0 (4)**,
  run 14, processingState **VALID**; (3) — run 12, VALID.
- Eksport muvofiqligi: Info.plist `ITSAppUsesNonExemptEncryption = NO` → buildda avtomatik
  javob berilgan (CI IPA’da tekshiradi; `beta` qadami ham `usesNonExemptEncryption` ni ko‘rsatadi).
- `TestFlight — ichki guruh va "What to Test"` qadami (2026-10-09 qo‘shildi): en-US/ru
  “What to Test”, barcha **Internal** guruhlarga biriktirish (guruhda “Automatic distribution”
  yoqilgan bo‘lsa — o‘tkazib yuboradi), `internalBuildState` ni summary’ga yozadi. Tashqi
  guruhlarga tegmaydi. Xato bo‘lsa — faqat ogohlantirish.
- **Egasi:** App Store Connect → LabGuide → TestFlight → Internal Testing → “+” guruh
  (masalan “LabGuide ichki”), testerlarni qo‘shing (ular App Store Connect foydalanuvchisi
  bo‘lishi kerak: Users and Access, istalgan rol), “Automatic distribution” ni yoqing.
  Testerlar iPhone’da **TestFlight** ilovasini o‘rnatib, emaildagi taklifni qabul qiladi;
  keyingi buildlar TestFlight’da “Update” bilan yangilanadi. Tashqi testerlar (ommaviy havola)
  Beta App Review talab qiladi — hozircha kerak emas.

### Android — Google Play ichki test (`mode=play_internal`)
- versionCode = GitHub run_number (har run’da oshadi). Imzoli AAB faqat `ANDROID_KEYSTORE_BASE64`,
  `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` secretlari bo‘lsa
  yasaladi va `labguide-android-<run>` artifact’iga qo‘shiladi. **Hozir bu secretlar yo‘q**
  (run 13/14 jurnalida `ANDROID_SIGNED: false`) — artifact’da faqat debug kalitli sinov APK’lar.
- `play_internal`: testlar → imzoli AAB → `r0adkll/upload-google-play@v1`, trek `internal`,
  holat `play_status` (standart `draft`; ilova Play’da hali “draft app” bo‘lsa faqat draft
  ruxsat etiladi). iOS job ishlamaydi. Secret yo‘q bo‘lsa — xatosiz o‘tkaziladi va summary’da
  nima yetishmasligi yoziladi; Play API rad etsa (ilova yo‘q, birinchi AAB qo‘lda yuklanmagan,
  ruxsat yo‘q) — ogohlantirish, AAB artifact’da qoladi.
- **Egasi bajaradigan amallar (tartib bilan):**
  1. Upload kaliti: `keytool -genkeypair -v -keystore upload.jks -keyalg RSA -keysize 2048
     -validity 10000 -alias upload`; `base64 -w0 upload.jks` → GitHub secretlar
     `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (=upload),
     `ANDROID_KEY_PASSWORD`. Fayl va parollarni xavfsiz joyda saqlang (yo‘qolsa — Play’da
     upload key reset so‘rash kerak bo‘ladi).
  2. Play Console → **Create app**: nomi LabGuide, til, App/Free, deklaratsiyalar.
     Paket nomi `uz.labguide.app` birinchi AAB bilan bog‘lanadi.
  3. **Birinchi AAB’ni qo‘lda yuklash:** `mode=build` (yoki `play_internal`) run’idan
     `labguide-android-<run>` artifact’ini yuklab, `app-release.aab` ni Testing → Internal
     testing → Create new release orqali yuklang; Play App Signing’ni qabul qiling. API yangi
     ilovaga birinchi yuklashni qila olmaydi (“Package not found”).
  4. Service account: Google Cloud’da loyiha → Google Play Android Developer API’ni yoqing →
     service account va JSON kalit yarating. Play Console → **Users and permissions** → Invite
     new user → service account emaili → LabGuide ilovasiga “Release to testing tracks”
     (va “View app information”) ruxsati. JSON matnini `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
     secretiga qo‘ying. (Play Console’ning eski “API access” sahifasi endi shart emas.)
  5. Internal testing → Testers → email ro‘yxati (100 tagacha) yarating, testerlarga
     **opt-in havolasini** yuboring: `https://play.google.com/apps/internaltest/<ID>`
     (aniq havola shu sahifadagi “Copy link”da). Tester havolani ochib “Become a tester”ni
     bosadi, so‘ng Play Store’dan o‘rnatadi/yangilaydi.
  6. **Shaxsiy dasturchi akkaunti** (2023-11-13 dan keyin yaratilgan) uchun Google’ning joriy
     talabi (support.google.com/googleplay/android-developer/answer/14151465, 2026-10-09
     tekshirildi): production’ga ariza berishdan oldin **yopiq test** (Closed testing),
     **kamida 12 tester**, **ketma-ket kamida 14 kun** opt-in bo‘lib turishi shart. Yopiq test:
     Testing → Closed testing → Create track (yoki “Alpha”) → Testers: email ro‘yxati yoki
     Google Group → Countries → release. Opt-in havola formati:
     `https://play.google.com/apps/testing/uz.labguide.app` (web opt-in sahifasi).
     Ichki test (internal) bu 12/14 hisobiga **kirmaydi**.
  7. Store listing, Data safety (12-bo‘lim), Content rating, Target audience (18+ / kattalar),
     Privacy policy URL (14-bo‘lim) — ichki test uchun ham Play ba’zilarini so‘raydi.

### Release notes / “What’s new” (Play, internal)
- uz: Sinov versiyasi. Kontent — adabiyotga asoslangan o‘quv ma’lumotnomasi, tashxis emas;
  bemor bo‘yicha qarorlarda foydalanmang. Tekshiring: mehmon
  rejimi, rol va til, tahlillar atlasi, kalkulyatorlar, leykoformula, imtihon.
- ru: Тестовая версия. Материалы — учебный справочник на основе литературы, не диагноз;
  не используйте для решений по пациентам. Проверьте:
  гостевой режим, роль и язык, атлас анализов, калькуляторы, лейкоформула, экзамен.
- en: Test build. Content is an educational reference based on the literature — not a
  diagnosis; do not use it for patient care decisions. Please check: guest mode, role and language, test
  atlas, calculators, differential count, exam.

(CI release notes’ni API orqali yozmaydi — Play Console’da release sahifasiga qo‘lda qo‘ying.)

## 14. Maxfiylik siyosatini ochiq havolada joylash

2026-10-17 dan: statik sayt `site/` (bosh sahifa, maxfiylik siyosati, hisobni o‘chirish
yo‘riqnomasi). Siyosat sahifasi `docs/store/PRIVACY_POLICY.md` dan
`python3 tool/site/build_site.py` bilan yasaladi; `python3 tool/site/check_site.py` ichki
izoh, taqiqlangan so‘zlar va buzuq havolalarni tekshiradi. Joylash (Cloudflare Pages yoki
istalgan statik hosting, taklif: `https://labguide.nfcstore.uz/`) — `site/README.md`.

| Maydon | Manzil |
|---|---|
| Privacy policy (App Store, Play, Google OAuth) | `https://labguide.nfcstore.uz/privacy/` |
| Homepage / Support URL (Google OAuth, App Store) | `https://labguide.nfcstore.uz/` |
| Delete account URL (Play Data safety) | `https://labguide.nfcstore.uz/delete-account/` |
| Foydalanish shartlari / Terms of Use (pullik versiya: tavsif, ilovadagi to‘lov oynasi) | `https://labguide.nfcstore.uz/terms/` |

Sayt joylanmaguncha zaxira: `https://github.com/davlatsudekspert/LabGuide/blob/main/docs/store/PRIVACY_POLICY.md`
(ichki izohsiz). Google OAuth “In production” uchun domen (`nfcstore.uz`) Google Search Console’da
tasdiqlangan bo‘lishi kerak. Ochiq savollar: [PRIVACY_OPEN_QUESTIONS.md](PRIVACY_OPEN_QUESTIONS.md).

## 15. Keyingi reliz (Pro bilan) uchun do'kon qidiruvi rejasi — 2026-10-18 (pullik tafsilotlar: 16-bo‘lim)

Muammo: App Store Connect'da faqat English (US) sahifa bor (Apple o'zbek tilini do'kon
tili sifatida qo'llamaydi), ruscha sahifa ochilmagan. Shu sabab "laborant", "КДЛ",
"лаборант" qidiruvi LabGuide'ni topmasligi mumkin. 1.0 tekshiruvda bo'lgani uchun
tegilmadi — Pro relizi bilan birga qilinadi:

1. English (US) keywords — o'zbekcha so'zlar qo'shiladi (100 belgigacha, nomdagi
   so'zlar takrorlanmaydi), masalan:
   `laborant,tahlil,KDL,baholash,klinik laboratoriya,biokimyo,leykoformula,Westgard,eGFR`
2. Russian localization ochiladi: nom `LabGuide: КДЛ и биохимия`, subtitle
   `Клиническая лаборатория`, keywords 5-bo'limdagi ru qatori
   (`КДЛ,лаборант,анализы,биохимия,...`), ruscha skrinshotlar (docs/store/screenshots/ru).
3. Google Play: to'liq tavsifda "laborant / лаборант / KDL / КДЛ" so'zlari tabiiy
   matnda 2–3 martadan.
4. iPad uchun moslashtirilgan (ikki ustunli) ko'rinish va yangi iPad skrinshotlari.

## 16. Pullik versiya (`paid/pro-premium`, D-77): obunalar, review, App Privacy

> **Holat (2026-10-25).** Bu bo‘lim FAQAT `paid/txt` / `paid/pro-premium` tarmog‘iga tegishli. 1–15-bo‘limlardagi
> bepul versiya matnlari (nom, subtitle, promo, tavsif 4, kalit so‘zlar) **o‘zgartirilmagan** — ular `main`dagi
> tekshiruvdagi bepul versiya uchun. Pullik versiya chiqarilganda 4-bo‘lim tavsifiga 16.3-bandagi blok
> qo‘shiladi. Hech narsa yuborilmagan: do‘kon/billing API chaqirilmagan, mahsulotlar do‘konda **yaratilmagan**
> (id’lar va narx pog‘onalari UNCONFIRMED-until-created-in-store). Haqiqiy sandbox xaridi bir marta ham sinalmagan
> (NOT VERIFIED). **Matnlarda narx yo‘q** (narx do‘kondan); egasi bergan narxlar faqat D-76 / `ProPricing` da.
> Apple qoidalari (3.1.1, 3.1.2, 5.1.1) va maydon uzunliklari o‘zgarib turadi — **NEEDS_OWNER_CHECK**:
> nashrdan oldin joriy App Review Guidelines va App Store Connect yordamini qayta o‘qing.

### 16.1 Obuna guruhi va mahsulotlar (App Store Connect → Monetization → Subscriptions)

Bitta **Subscription Group**; unga 8 ta auto-renewable mahsulot (4 reja × oylik/yillik). Mahsulot id’lari
`lib/core/entitlements/billing_catalog.dart` dan olingan (**yangi id o‘ylab topilmadi**):
`uz.labguide.student|teacher|specialist|premium` + `.monthly` / `.yearly` — do‘konda yaratilmaguncha UNCONFIRMED.
Narx pog‘onalarini egasi App Store Connect’da tanlaydi (hujjatda yozilmaydi). **Introductory Offer / Free Trial
YARATILMAYDI** (bepul sinov — ilova ichidagi 7 kunlik server sinovi, 16.2). `PRO_BILLING_PLAN.md` 9.1-bo‘limdagi
“6 mahsulot”, “Introductory Offer → Free Trial 7/14 kun” va “Pro ↔ Ustoz Pro” darajalari **eskirgan** (D-76/D-77
bilan almashtirilgan).

| Maydon | uz (agar ASC uzbek tilini qabul qilsa) | ru | en (US) |
|---|---|---|---|
| Subscription Group — Display Name | LabGuide rejalari | Планы LabGuide | LabGuide plans |
| Talaba — Display Name (≤ 30) | Talaba Pro | Студент Pro | Student Pro |
| Talaba — Description (≤ 45) | Ustoz testlari, tarix, imtihon simulyatsiyasi | Тесты, история, симуляция экзамена | Assigned tests, history, exam simulation |
| Ustoz — Display Name | Ustoz Pro | Преподаватель Pro | Teacher Pro |
| Ustoz — Description | Test yaratish, guruhlar, natijalar | Создание тестов, группы, результаты | Create tests, groups, manage results |
| Mutaxassis — Display Name | Mutaxassis Pro | Специалист Pro | Specialist Pro |
| Mutaxassis — Description | Professional laboratoriya funksiyalari | Профессиональные функции лаборатории | Professional laboratory functions |
| Premium — Display Name | Premium | Premium | Premium |
| Premium — Description | Talaba, Ustoz va Mutaxassis imkoniyatlari | Все возможности Студент, Преп., Специалист | Student, Teacher and Specialist features |

Level (guruh ichidagi daraja) tartibini egasi tanlaydi — NEEDS_OWNER_CHECK (matritsa: Talaba — o‘qish; Ustoz —
o‘qish + ustoz paneli; Mutaxassis — o‘qish + professional laboratoriya funksiyalari; Premium — hammasi;
`lib/core/entitlements/plan_matrix.dart`). Reference name’lar (ichki): “Student Pro Monthly” va h.k. Review
screenshot: to‘lov oynasi (Profil → Obuna → Obuna bo‘lish) — narx va davr xarid tugmasidan yuqorida ko‘rinadi.
ASC o‘zbek tilini do‘kon tili sifatida qo‘llamaydi (15-bo‘lim) — uz ustuni Play uchun; ASC’da en va ru.

### 16.2 Bepul sinov va “Restore” joyi

- **Bepul sinov = ilova ichidagi 7 kun, bir marta, karta yo‘q** (server beradi; Apple “Introductory Offer” emas).
  Profil → Obuna → “Bepul sinovni boshlash: <reja>”. Tugagach **faqat pullik imkoniyatlar yopiladi**; bepul qism va
  ma’lumotlar qoladi. Sinov tugmasi faqat qurilma tekshiruvi (Apple App Attest/DeviceCheck) sozlangan platformada
  chiqadi — hozir iOS’da server sinovi o‘chiq (`TRIAL_PLATFORMS`, attestatsiya yo‘q): **NEEDS_OWNER_CHECK** —
  topshiriladigan buildda iOS’da sinov bormi, review izohiga shuni aniq yozing. Apple 3.1.1/3.1.2 nuqtai nazaridan
  kartasiz, server beradigan sinov savol tug‘dirishi mumkin (`PAID_TRIAL_MODELS` Model A) — NEEDS_OWNER_CHECK.
- Agar kelajakda do‘kon “Introductory Offer” yoqilsa: ilova matnlari (`proPayTrial`, `proPayStoreTrialNote`)
  narx va yangilanish shartlari **do‘kon oynasidagidek** ekanini aytadi; ikkala sinovni birga qo‘llamang (7 + 7 kun
  chalkashligi).
- **Xaridni tiklash:** Profil → Obuna → “Xaridni tiklash” va to‘lov oynasi (Obuna bo‘lish) pastida. Obunani boshqarish:
  “Obunani boshqarish yoki bekor qilish” (Apple obuna sahifasi). Mehmon rejimida xarid, tiklash va sinov yo‘q
  (hisobga kirish tugmasi chiqadi) — **NEEDS_OWNER_CHECK:** Apple 5.1.1 hisobsiz xaridni kutishi mumkin.

### 16.3 Tavsifga qo‘shiladigan obuna bloki (narxsiz) — 4-bo‘lim tavsifi oxiriga

Apple 3.1.2: obuna nomi, davri, narxi (do‘kon ko‘rsatadi), avtomatik yangilanish, bekor qilish yo‘li, Foydalanish
shartlari va Maxfiylik havolalari metadatada bo‘lishi kerak.

**uz**
Pullik rejalar (ixtiyoriy): Talaba Pro, Ustoz Pro, Mutaxassis Pro va Premium. Bugun bepul imkoniyatlar bepul
qoladi. 7 kunlik bepul sinov bir marta beriladi va karta talab qilmaydi; sinov yoki obuna tugasa, faqat pullik
imkoniyatlar yopiladi. Obuna avtomatik yangilanadi: narx va davr xariddan oldin App Store oynasida ko‘rsatiladi,
to‘lov xaridni tasdiqlaganingizda Apple hisobingizdan olinadi. Joriy davr tugashidan kamida 24 soat oldin bekor
qilinmasa, obuna yangilanadi. Obunani Sozlamalar → ismingiz → Obunalar bo‘limida boshqarish va bekor qilish mumkin.
Foydalanish shartlari: https://labguide.nfcstore.uz/terms/ · Maxfiylik siyosati: https://labguide.nfcstore.uz/privacy/

**ru**
Платные планы (по желанию): Студент Pro, Преподаватель Pro, Специалист Pro и Premium. Функции, бесплатные сегодня,
остаются бесплатными. Бесплатный пробный период на 7 дней даётся один раз, карта не нужна; когда пробный период или
подписка заканчиваются, закрываются только платные функции. Подписка продлевается автоматически: цена и период
показываются в окне App Store до покупки, оплата списывается с вашей учётной записи Apple при подтверждении покупки.
Если не отменить подписку как минимум за 24 часа до конца текущего периода, она продлится. Управлять подпиской и
отменить её можно в Настройки → ваше имя → Подписки.
Условия использования: https://labguide.nfcstore.uz/terms/ · Политика конфиденциальности: https://labguide.nfcstore.uz/privacy/

**en**
Paid plans (optional): Student Pro, Teacher Pro, Specialist Pro and Premium. Features that are free today stay free. The
7-day free trial is given once and needs no card; when a trial or subscription ends, only the paid features close.
Subscriptions renew automatically: the price and period are shown in the App Store sheet before you buy, and payment is
charged to your Apple Account when you confirm the purchase. Unless cancelled at least 24 hours before the end of the
current period, the subscription renews. You can manage and cancel it in Settings → your name → Subscriptions.
Terms of Use: https://labguide.nfcstore.uz/terms/ · Privacy Policy: https://labguide.nfcstore.uz/privacy/

**What’s New (paid versiya, narxsiz)**
- uz: Yangi: ixtiyoriy pullik rejalar (Talaba Pro, Ustoz Pro, Mutaxassis Pro, Premium). Bepul imkoniyatlar bepul qoladi.
- ru: Новое: необязательные платные планы (Студент Pro, Преподаватель Pro, Специалист Pro, Premium). Бесплатные функции остаются бесплатными.
- en: New: optional paid plans (Student Pro, Teacher Pro, Specialist Pro, Premium). Free features stay free.

**License Agreement / Terms of Use havolasi.** Foydalanish shartlari: `https://labguide.nfcstore.uz/terms/`
(`TERMS_OF_USE.md`, uch tilda; ilovadagi to‘lov oynasi shu manzilni ochadi — `Contact.termsOfUseUrl`). Variantlar:
(a) App Store Connect → App Information → License Agreement: *Standard Apple EULA* (ilova tavsifida Foydalanish
shartlari havolasi baribir turadi) yoki (b) *Custom* — Apple’ning minimal EULA bandlari (tomon nomi/manzili, Apple
uchinchi tomon manfaatdor ekani va h.k.) hozirgi matnda YO‘Q → yurist qo‘shishi yoki (a) tanlanishi kerak.
**NEEDS_OWNER_CHECK / NEEDS_LAWYER_REVIEW.**

### 16.4 App Review Information → Notes (ingliz tilida; placeholderlarni egasi to‘ldiradi)

```text
LabGuide is an educational reference app for clinical laboratory professionals and students. It does not diagnose or
interpret patient results.

FREE vs PAID: every feature that was free in the previous version stays free (no daily limits). Optional auto-renewing
subscriptions (Student Pro, Teacher Pro, Specialist Pro, Premium) add extra features. Subscriptions are sold only with
In-App Purchase. When a trial or subscription ends, only the paid features close; free features and the user's data stay.

WHERE TO FIND IT: Profile tab -> "Subscription and restore" -> plans -> "Subscribe". The purchase screen shows each plan's
name, the price and period from the App Store (above the buy button), the auto-renewal terms, "Restore purchases",
"Manage or cancel subscription", and links to the Terms of Use (https://labguide.nfcstore.uz/terms/) and the Privacy
Policy (https://labguide.nfcstore.uz/privacy/).

SIGN-IN: buying, restoring and the free trial need an account (email code, Google or Apple). Guest mode keeps all free
features and shows a "Sign in" button instead of the buy button.
Review account: <REVIEW_ACCOUNT - NEEDS_OWNER_CHECK: owner decides how the reviewer signs in, e.g. Sign in with Apple, or a
monitored mailbox for the email code>.

FREE TRIAL: a 7-day in-app trial (given once per phone/account/email, no card, never converts to a paid plan by itself).
It is not an App Store introductory offer. <TRIAL_ON_IOS - NEEDS_OWNER_CHECK: state whether the trial button is available
on iOS in this build; if the device check is not enabled on iOS, say so.>

SANDBOX TEST STEPS:
1. Sign in with the review account above (Profile -> Sign in).
2. Profile -> Subscription and restore -> choose a plan -> Subscribe -> confirm in the App Store sheet (sandbox:
   <SANDBOX_TESTER - NEEDS_OWNER_CHECK: Apple sandbox account details if the reviewer needs one>).
3. The paid features of the plan unlock (e.g. Teacher Pro: teacher panel).
4. Delete and reinstall (or use another device) -> sign in -> "Restore purchases" restores the plan.
5. "Manage or cancel subscription" opens the App Store subscriptions page.
6. After the sandbox subscription expires, only the paid features close; free features and data remain.

Contact: labguide@nfcstore.uz
```

**Sandbox hisoblari / test bosqichi (egasi, ichki):** `PRO_TEST_ENVIRONMENT.md` 3-bo‘lim (Sandbox tester → Settings → App Store →
Sandbox Account → TestFlight build). Xarid, tiklash, boshqa hisob (`owned_by_other`), bekor qilish, grace, refund va oflayn
holatlar — QILINMAGAN (NOT VERIFIED). Production serverda sandbox xaridini qabul qilish siyosati (`LG_BILLING_SANDBOX`) —
NEEDS_OWNER_CHECK: o‘chiq bo‘lsa App Review sandbox xaridi rad etiladi.

### 16.5 App Privacy (Ma’lumotlar) — pullik build uchun o‘zgarishlar (**NEEDS_OWNER_CHECK**: aniq toifa va maqsadlar)

Pullik build doim serverga ulanadi (`LG_API_URL` berilgan): 6-bo‘limdagi “Data Not Collected” (server ulanmagan build)
javobi **yaroqsiz**; “server ulangan” jadvalga quyidagilar qo‘shiladi. Tracking: No (o‘zgarmaydi).

| App Store toifasi | Nima (kodda / matnda) | Maqsad | Eslatma |
|---|---|---|---|
| Purchases → Purchase History | do‘kon tranzaksiya identifikatori, sotib olingan mahsulot (reja), holat, boshlanish/tugash vaqti (`entitlements`); hisob o‘chirilganda o‘chadi | App Functionality | Linked to user. Maxfiylik siyosati 16-bo‘lim |
| Identifiers → Device ID | bepul sinov uchun: kanonik email va qurilma belgisining faqat kalitli xeshlari (xom qiymat saqlanmaydi); hisob o‘chirilganda hisobdan uziladi, 24 oy saqlanadi | App Functionality (suiiste’molga qarshi — Apple ro‘yxatida alohida maqsad bo‘lmasa *Other Purposes*) | Linked/Not linked va maqsad — egasi hal qiladi; 24 oy — **NEEDS_LAWYER_REVIEW** |
| Contact Info → Email Address | o‘zgarmaydi (sinov xeshi uchun ham ishlatiladi) | App Functionality | — |

Karta ma’lumoti LabGuide’da yo‘q (to‘lovni Apple qayta ishlaydi) — *Financial Info* qo‘shilmaydi. `PrivacyInfo.xcprivacy`
(`ios/Runner/`) ni ham shu jadvalga solishtiring (Apple 2.3.1; `in_app_purchase` iOS’da StoreKit’ni ishlatadi).
Age rating: In-App Purchases savollari bor bo‘lsa, “obuna bor” deb belgilang; Medical bandi o‘zgarmaydi
([APPLE_2026_REQUIREMENTS.md](../APPLE_2026_REQUIREMENTS.md) 6-bo‘lim).
