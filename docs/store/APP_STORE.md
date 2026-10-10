# App Store va TestFlight uchun materiallar

App Store Connect’ga kiritiladigan matnlar va javoblar. Hammasi ilovaning haqiqiy holatiga
mos: ilova serverga ma’lumot yubormaydi, tashxis qo‘ymaydi, kontent manbali o‘quv namunasi.
Ilova o‘zgarsa (masalan, email kirish ulanganda), shu hujjat ham yangilanadi.

**Va’da qilinmaydigan narsalar (hozir ishlamaydi):** email orqali kirish, guruhlar/sinflar,
“Taklif va yordam” va hamkor statistikasi (server ulanmagan), pullik obuna/to‘lov (o‘chiq).
Tavsiflarda ular tilga olinmaydi; “qoralama / mutaxassis tekshiruvi kutilmoqda” holati
tavsiflarda ochiq yoziladi — buni olib tashlamang. Rus/ingliz tavsifida O‘zbekistonga xos
bo‘limlar (malaka toifasi) yo‘q: ular faqat o‘zbek tili yoki UZ mintaqasida ko‘rinadi.
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

- **uz:** Tahlillar atlasi (qoralama), klinik kalkulyatorlar, har kuni 5 ta savol, leykoformula va
  Westgard sifat nazorati — manbalari bilan, internetsiz.
- **ru:** Атлас анализов (черновик), клинические калькуляторы, 5 вопросов в день, лейкоформула и
  контроль качества по Вестгарду — с источниками, без интернета.
- **en:** Lab test atlas (draft), clinical calculators, 5 daily questions, differential count and
  Westgard QC — with sources, fully offline.

## 4. Description (≤ 4000)

### uz
LabGuide — biokimyo va klinik laboratoriya uchun qo‘llanma: laboratoriya mutaxassisi, shifokor,
talaba va o‘qituvchi uchun.

• Tahlillar atlasi: 119 ta karta (glyukoza, HbA1c, kreatinin, lipidlar, jigar fermentlari,
elektrolitlar, gormonlar, gematologiya, siydik tahlili va boshqalar) va 43 ta holat. Har bir da’vo
ochiq manbaga bog‘langan. Barcha kartalar QORALAMA: mustaqil mutaxassis tekshiruvi kutilmoqda
(har kartada shunday yoziladi).
• Birliklar: SI (mmol/L, µmol/L) yoki an’anaviy (mg/dL) — Profilda tanlanadi; kalkulyatorlar
tanlangan tizimda boshlanadi. Moddaga xos birlik konvertori.
• Klinik kalkulyatorlar: eGFR (CKD-EPI 2021) va KDIGO toifasi, albumin/kreatinin nisbati,
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
hisobi va ixtiyoriy mahalliy eslatma. Savollar qoralama.
• Ichki sifat nazorati: Levey–Jennings grafigi, Westgard qoidalari (1-2s, 1-3s, 2-2s, R-4s,
4-1s, 10x), lot va maqsad tarixi, CSV eksport va zaxira nusxa.
• Preanalitika, analizator katalogi, izohli testlar, kutubxona (ochiq va rasmiy manbalar).
• Malaka toifasi imtihoniga tayyorgarlik (o‘zbek tilidagi savollar; qoralama, rasmiy natija emas).

Uch tilda: o‘zbek, rus, ingliz. Internet shart emas. Hisobsiz (mehmon) ishlaydi. Ilova hozircha
serverga ma’lumot yubormaydi.

Muhim: LabGuide o‘quv va ma’lumotnoma vositasi. U natijani talqin qilmaydi, tashxis qo‘ymaydi
va dori dozasini taklif qilmaydi. Natijalar klinik manzara va laboratoriyangiz referens
intervallari bilan birga baholanadi. Kontent manbalarga asoslangan QORALAMA o‘quv namunasi:
mustaqil mutaxassis tekshiruvidan hali o‘tmagan.

### ru
LabGuide — справочник по биохимии и клинической лабораторной диагностике для специалистов
лаборатории, врачей, студентов и преподавателей.

• Атлас анализов: 119 карточек (глюкоза, HbA1c, креатинин, липиды, печёночные ферменты,
электролиты, гормоны, гематология, анализ мочи и др.) и 43 состояния. Каждое утверждение связано
с открытым источником. Все карточки — ЧЕРНОВИК: независимая экспертная проверка ещё не
завершена (это указано в каждой карточке).
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
необязательное локальное напоминание. Вопросы — черновик.
• Внутрилабораторный контроль качества: карта Леви–Дженнингса, правила Вестгарда (1-2s, 1-3s,
2-2s, R-4s, 4-1s, 10x), история лотов и целевых значений, экспорт CSV и резервная копия.
• Преаналитика, каталог анализаторов, тесты с пояснениями, библиотека (открытые и официальные
источники).

Три языка: узбекский, русский, английский. Работает без интернета и без аккаунта (гостевой
режим). Сейчас приложение не отправляет данные на сервер.

Важно: LabGuide — учебный и справочный инструмент. Он не интерпретирует результаты, не ставит
диагноз и не предлагает дозы препаратов. Результаты оцениваются с учётом клинической картины и
референсных интервалов вашей лаборатории. Материалы основаны на источниках, но это ЧЕРНОВИК:
независимую экспертную проверку они ещё не прошли.

### en
LabGuide is a biochemistry and clinical laboratory companion for lab professionals, physicians,
students and teachers.

• Lab test atlas: 119 cards (glucose, HbA1c, creatinine, lipids, liver enzymes, electrolytes,
hormones, haematology, urinalysis and more) and 43 conditions. Every claim links to an open
source. All cards are DRAFTS: independent expert review is still pending (each card says so).
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
streak and an optional local reminder. The questions are drafts.
• Internal quality control: Levey–Jennings chart, Westgard rules (1-2s, 1-3s, 2-2s, R-4s, 4-1s,
10x), lot and target history, CSV export and backup.
• Preanalytics, an instrument catalogue, explained quizzes and a library of open and official
sources.

Three languages: Uzbek, Russian, English. Works offline and without an account (guest mode).
The app currently sends no data to a server.

Important: LabGuide is a learning and reference tool. It does not interpret results, make a
diagnosis or suggest drug doses. Results are assessed together with the clinical picture and
your laboratory’s reference intervals. Content is source-based but is a DRAFT: it has not yet
passed independent expert review.

## 5. Keywords (≤ 100 belgi, vergul bilan, bo‘shliqsiz)

- uz: `laboratoriya,biokimyo,tahlil,eGFR,Westgard,QC,kalkulyator,glyukoza,kreatinin,preanalitika`
- ru: `лаборатория,биохимия,анализы,рСКФ,Вестгард,контроль качества,калькулятор,глюкоза,креатинин`
- en: `laboratory,biochemistry,lab tests,eGFR,Westgard,QC,Levey-Jennings,calculator,units,preanalytics`

## 6. App Privacy (Ma’lumotlar)

**Hozirgi holat (2026-10-09, TestFlight 0.1.0 (3) va (4), Android run 13–14):** CI’da
`LG_SUPABASE_URL`/`LG_SUPABASE_KEY` secretlari **bo‘sh** (jurnalda `LG_SUPABASE_URL:` qiymatsiz) —
build “server hali ulanmagan” rejimida, email kirish, “Taklif va yordam”, guruhlar va hamkor
statistikasi serverga hech narsa yubormaydi. Shu buildlar uchun to‘g‘ri javob:
**“Data Not Collected”** (Tracking: No). Ilova faqat foydalanuvchi o‘zi “Paketlar”da yuklashni
bossa `raw.githubusercontent.com` dan statik JSON/fayl oladi (so‘rovda shaxsiy ma’lumot yo‘q,
dasturchi saqlamaydi) va tashqi havolalarni brauzerda ochadi — bu Apple ta’rifi bo‘yicha
“collection” emas. Analitika/crash SDK yo‘q.

Secret qo‘yilib server ulangan **birinchi** buildgacha App Privacy quyidagi jadvalga
o‘zgartiriladi (aks holda deklaratsiya noto‘g‘ri bo‘ladi). Server (Supabase) ulangan build uchun javoblar. **Tracking: No** (boshqa kompaniyalar ma’lumoti
bilan birlashtirilmaydi, reklama identifikatori yo‘q). Hamma toifalar — **Linked to the user**,
**not used for tracking**.

| App Store toifasi | Nima | Maqsad |
|---|---|---|
| Contact Info → Email Address | kirish emaili | App Functionality |
| Identifiers → User ID | ichki hisob id si | App Functionality |
| User Content → Customer Support | “Taklif va yordam” xabarlari | App Functionality |
| User Content → Photos or Videos | murojaatga biriktirilgan skrinshot (ixtiyoriy) | App Functionality |
| User Content → Other User Content | guruh javoblari, tekshiruvchi izohlari | App Functionality |
| Usage Data → Product Interaction | oxirgi foydalanilgan kun, rol, til | Analytics, App Functionality |

Hamkorlar (reklama) yoqilsa qo‘shiladi: **Usage Data → Advertising Data** — e’lon ko‘rsatilishi
va bosilishi, **Not linked** (faqat kunlik umumiy son), maqsad: Third-Party Advertising.
Spamga qarshi hisob bo‘yicha faqat bugungi hodisalar soni: **Other Usage Data**, Linked,
maqsad: App Functionality. “Hamkor bo‘lish” arizasi: **Contact Info** (email, ism, telefon),
Linked, maqsad: App Functionality.
Mehmon rejimida va server ulanmagan buildda hech narsa yuborilmaydi.

**Mikrofon / nutqni tanish (leykoformula ovozli buyruqlari, ixtiyoriy, eksperimental):** iOS’da
`requiresOnDeviceRecognition` majburiy — ovoz qurilmadan chiqmaydi, ilova ovozni saqlamaydi va
yubormaydi, shuning uchun App Privacy’da **Audio Data qo‘shilmaydi** (“Data Not Collected” to‘g‘ri
qoladi). Info.plist: `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`
(uz/ru/en `InfoPlist.strings`). Kunlik eslatma — lokal bildirishnoma (push server yo‘q);
ulashish — tizim oynasi, `NSPhotoLibraryAddUsageDescription` faqat “Save Image” uchun.

**Privacy Policy URL** — majburiy. Matn: [PRIVACY_POLICY.md](PRIVACY_POLICY.md). Joylash: GitHub
→ repo Settings → Pages → “Deploy from a branch”, `main` / `docs` — manzil
`https://davlatsudekspert.github.io/LabGuide/store/PRIVACY_POLICY` (yoki o‘z saytingiz).
E’lon qilishdan oldin sana, aloqa, hosting mintaqasi va email xizmatini to‘ldiring.

**Hisobni o‘chirish** (App Store 5.1.1(v)): ilovada Profil → Maxfiylik → “Hisobni o‘chirish”
(server: `delete-account` Edge Function).

## 7. Age rating

Savolnomada: “Medical or Treatment Information” — **Infrequent/Mild** (o‘quv ma’lumoti,
tashxis yo‘q); boshqa barcha toifalar — None. Yakuniy reytingni App Store Connect hisoblaydi.

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
- uz: **QORALAMA build, ichki sinov uchun. Kontent manbalarga asoslangan, lekin mustaqil
  mutaxassis tekshiruvidan HALI O‘TMAGAN — bemor bilan ishlashda foydalanmang.** Tekshiring:
  ochish → mehmon → rol va til → tahlillar atlasi → kalkulyatorlar → leykoformula → imtihon.
- ru: **ЧЕРНОВАЯ сборка для внутреннего тестирования. Материалы ещё НЕ прошли независимую
  экспертную проверку — не используйте их для работы с пациентами.**
- en: **DRAFT build for internal testing. Content has NOT yet passed independent expert
  review — do not use it for patient care.**

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

`flutter test tool/screenshots/store_screenshots_test.dart --update-goldens` — 6.9" iPhone
uchun 1290×2796 px, uch tilda 6 tadan: bosh sahifa, tahlillar atlasi, glyukoza qaror
chegaralari, eGFR natijasi, Levey–Jennings grafigi, izohli test. Natija
`tool/screenshots/out/store/<til>/` da (repoga kirmaydi).

## 11. Ikonka va grafikalar

Hammasi egasining logosidan (`python3 tool/icons/make_icons.py`, D-37):

| Fayl | Qayerga |
|---|---|
| `docs/store/app_store_icon_1024.png` | App Store (buildning AppIcon ichida ham bor — alohida yuklash shart emas) |
| `docs/store/google_play_icon_512.png` | Google Play Console → Store listing → App icon (512×512, shaffofsiz) |
| `docs/store/google_play_feature_graphic.png` | Google Play → Feature graphic (1024×500) |

## 12. Google Play — Data safety

**Hozirgi buildlar (server ulanmagan, `LG_SUPABASE_URL` secret bo‘sh):**
“Does your app collect or share any of the required user data types?” — **No**.
Shifrlash/o‘chirish savollari bu holda so‘ralmaydi. Ads: **No** (hamkor bo‘limi server
ulanmaguncha e’lon ko‘rsatmaydi — yoqilganda Yes). Server ulangan birinchi build yuklanishidan
**oldin** quyidagi jadvalga almashtiriladi:

| Savol | Javob |
|---|---|
| Ma’lumot to‘planadimi? | Ha (faqat hisob ochilganda) |
| Uchinchi tomonga beriladimi (sharing)? | Yo‘q (Supabase va email xizmati — xizmat ko‘rsatuvchi, sharing emas) |
| Uzatishda shifrlanganmi? | Ha (HTTPS) |
| O‘chirishni so‘rash mumkinmi? | Ha — ilovada “Hisobni o‘chirish” va siyosatdagi aloqa manzili |
| Personal info → Email address | To‘planadi; majburiy (hisob uchun); App functionality, Account management |
| Messages → Other in-app messages | To‘planadi; ixtiyoriy; App functionality (yordam) |
| Photos and videos → Photos | To‘planadi; ixtiyoriy; App functionality (murojaatga skrinshot) |
| App activity → App interactions | To‘planadi; oxirgi faol kun; Analytics |
| App activity → Other user-generated content | To‘planadi; ixtiyoriy; guruh javoblari, tekshiruv izohlari |
| Location, Contacts, Financial, Health, Device IDs | To‘planmaydi |

**Ovozli buyruqlar (RECORD_AUDIO, ixtiyoriy, eksperimental):** Android’da rejim faqat
qurilmada oflayn tanish mavjud bo‘lsa yoqiladi (`MainActivity` →
`SpeechRecognizer.isOnDeviceRecognitionAvailable`, Android 12+; speech_to_text `onDevice: true`
shu holda `createOnDeviceSpeechRecognizer` ishlatadi). Ovoz qurilmadan chiqmaydi, ilova uni
saqlamaydi — Data safety’da **Audio qo‘shilmaydi** (egasi qarori, 2026-10-09). Kunlik eslatma
(`POST_NOTIFICATIONS`) va ulashish ma’lumot to‘plamaydi.

Reklama: ilovada hamkor e’lonlari bo‘lsa, Play Console → App content → **Ads: Yes**.
Hisobni o‘chirish havolasi (Play talabi): siyosat sahifasi + ilovadagi tugma.


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
- uz: Qoralama sinov versiyasi. Kontent manbalarga asoslangan, lekin mustaqil mutaxassis
  tekshiruvidan hali o‘tmagan — bemorlar bilan ishlashda foydalanmang. Tekshiring: mehmon
  rejimi, rol va til, tahlillar atlasi, kalkulyatorlar, leykoformula, imtihon.
- ru: Черновая тестовая версия. Материалы основаны на источниках, но ещё не прошли
  независимую экспертную проверку — не используйте для работы с пациентами. Проверьте:
  гостевой режим, роль и язык, атлас анализов, калькуляторы, лейкоформула, экзамен.
- en: Draft test build. Content is source-based but has not yet passed independent expert
  review — do not use it for patient care. Please check: guest mode, role and language, test
  atlas, calculators, differential count, exam.

(CI release notes’ni API orqali yozmaydi — Play Console’da release sahifasiga qo‘lda qo‘ying.)

## 14. Maxfiylik siyosatini ochiq havolada joylash

Tekshirildi (2026-10-09): repo **public**; GitHub Pages **yoqilmagan**
(`davlatsudekspert.github.io/LabGuide/...` → 404).
- **Tavsiya:** Settings → Pages → Source “Deploy from a branch”, `main` / `/docs`. Bir necha
  daqiqadan so‘ng: `https://davlatsudekspert.github.io/LabGuide/store/PRIVACY_POLICY` (Jekyll
  markdown’ni HTML qiladi). Eslatma: `docs/` dagi boshqa fayllar ham sahifa bo‘lib chiqadi
  (repo baribir public).
- **Hozir ishlaydigan zaxira:** `https://github.com/davlatsudekspert/LabGuide/blob/main/docs/store/PRIVACY_POLICY.md`
  (200 qaytaradi). `raw.githubusercontent.com` havolasi ham 200, lekin oddiy matn — do‘kon
  uchun yaroqsiz ko‘rinadi.
- E’lon qilishdan oldin `[sana]`, `[email]`, `[hosting mintaqasi]`, `[email yuborish xizmati]`
  joylarini to‘ldiring va “Eslatma” blokini olib tashlang.
