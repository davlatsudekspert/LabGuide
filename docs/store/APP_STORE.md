# App Store va TestFlight uchun materiallar

App Store Connect’ga kiritiladigan matnlar va javoblar. Hammasi ilovaning haqiqiy holatiga
mos: ilova serverga ma’lumot yubormaydi, tashxis qo‘ymaydi, kontent manbali o‘quv namunasi.
Ilova o‘zgarsa (masalan, email kirish ulanganda), shu hujjat ham yangilanadi.

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

- **uz:** Tahlillar atlasi, klinik kalkulyatorlar, Westgard qoidalari bilan sifat nazorati va izohli
  testlar — manbalari bilan, internetsiz.
- **ru:** Атлас анализов, клинические калькуляторы, контроль качества по правилам Вестгарда и
  тесты с пояснениями — с источниками, без интернета.
- **en:** Lab test atlas, clinical calculators, Westgard quality control and explained quizzes —
  with sources, fully offline.

## 4. Description (≤ 4000)

### uz
LabGuide — biokimyo va klinik laboratoriya uchun qo‘llanma: laboratoriya mutaxassisi, shifokor,
talaba va o‘qituvchi uchun.

• Tahlillar atlasi: 35 ta ko‘rsatkich (glyukoza, HbA1c, kreatinin, eGFR, jigar fermentlari,
lipidlar, elektrolitlar, siydik tahlili va boshqalar). Har bir da’vo ochiq manbaga bog‘langan
(MedlinePlus, NIDDK, NHLBI, JSST).
• Klinik kalkulyatorlar: eGFR (CKD-EPI 2021) va KDIGO toifasi, albumin/kreatinin nisbati,
anion oralig‘i, albumin bo‘yicha tuzatilgan kalsiy, LDL (Friedewald, Sampson) va non-HDL,
osmolyallik, HbA1c NGSP ↔ IFCC va eAG. Har birida formula, cheklovlar va manba.
• Moddaga xos birlik konvertori (mg/dL ↔ mmol/L yoki µmol/L).
• Ichki sifat nazorati: Levey–Jennings grafigi, Westgard qoidalari (1-2s, 1-3s, 2-2s, R-4s,
4-1s, 10x), lot va maqsad tarixi, CSV eksport va zaxira nusxa.
• Preanalitika: JSST 2010 bo‘yicha probirkalar tartibi, gemoliz sabablari, bemorni aniqlash.
• Izohli testlar: har bir javob izohi va manbasi, xatolar ustida ishlash.
• Kutubxona: ochiq litsenziyali va rasmiy manbalar katalogi.

Uch tilda: o‘zbek, rus, ingliz. Internet shart emas. Ilova serverga hech qanday ma’lumot
yubormaydi.

Muhim: LabGuide o‘quv va ma’lumotnoma vositasi. U natijani talqin qilmaydi, tashxis qo‘ymaydi
va dori dozasini taklif qilmaydi. Natijalar klinik manzara va laboratoriyangiz referens
intervallari bilan birga baholanadi. Kontent manbalarga asoslangan o‘quv namunasi bo‘lib,
mustaqil mutaxassis tekshiruvidan o‘tkazilmoqda.

### ru
LabGuide — справочник по биохимии и клинической лабораторной диагностике для специалистов
лаборатории, врачей, студентов и преподавателей.

• Атлас анализов: 35 показателей (глюкоза, HbA1c, креатинин, рСКФ, печёночные ферменты,
липиды, электролиты, анализ мочи и др.). Каждое утверждение связано с открытым источником
(MedlinePlus, NIDDK, NHLBI, ВОЗ).
• Клинические калькуляторы: рСКФ (CKD-EPI 2021) и категория KDIGO, отношение
альбумин/креатинин, анионный интервал, кальций с поправкой на альбумин, ЛПНП (Friedewald,
Sampson) и не-ЛПВП, осмоляльность, HbA1c NGSP ↔ IFCC и eAG. Для каждого — формула,
ограничения и источник.
• Конвертер единиц для конкретного вещества (мг/дл ↔ ммоль/л или мкмоль/л).
• Внутрилабораторный контроль качества: карта Леви–Дженнингса, правила Вестгарда (1-2s, 1-3s,
2-2s, R-4s, 4-1s, 10x), история лотов и целевых значений, экспорт CSV и резервная копия.
• Преаналитика: порядок взятия пробирок по ВОЗ 2010, причины гемолиза, идентификация пациента.
• Тесты с пояснениями: разбор каждого ответа и источник, работа над ошибками.
• Библиотека: каталог открытых и официальных источников.

Три языка: узбекский, русский, английский. Работает без интернета. Приложение не отправляет
данные на сервер.

Важно: LabGuide — учебный и справочный инструмент. Он не интерпретирует результаты, не ставит
диагноз и не предлагает дозы препаратов. Результаты оцениваются с учётом клинической картины и
референсных интервалов вашей лаборатории. Материалы основаны на источниках и проходят
независимую экспертную проверку.

### en
LabGuide is a biochemistry and clinical laboratory companion for lab professionals, physicians,
students and teachers.

• Lab test atlas: 35 analytes (glucose, HbA1c, creatinine, eGFR, liver enzymes, lipids,
electrolytes, urinalysis and more). Every claim links to an open source (MedlinePlus, NIDDK,
NHLBI, WHO).
• Clinical calculators: eGFR (CKD-EPI 2021) with KDIGO category, albumin/creatinine ratio,
anion gap, albumin-corrected calcium, LDL (Friedewald, Sampson) and non-HDL, osmolality,
HbA1c NGSP ↔ IFCC and eAG. Each shows its formula, limitations and source.
• Analyte-specific unit converter (mg/dL ↔ mmol/L or µmol/L).
• Internal quality control: Levey–Jennings chart, Westgard rules (1-2s, 1-3s, 2-2s, R-4s, 4-1s,
10x), lot and target history, CSV export and backup.
• Preanalytics: WHO 2010 order of draw, causes of hemolysis, patient identification.
• Explained quizzes: an explanation and a source for every answer, mistake review.
• Library: a catalog of open and official sources.

Three languages: Uzbek, Russian, English. Works offline. The app sends no data to a server.

Important: LabGuide is a learning and reference tool. It does not interpret results, make a
diagnosis or suggest drug doses. Results are assessed together with the clinical picture and
your laboratory’s reference intervals. Content is source-based learning material and is
undergoing independent expert review.

## 5. Keywords (≤ 100 belgi, vergul bilan, bo‘shliqsiz)

- uz: `laboratoriya,biokimyo,tahlil,eGFR,Westgard,QC,kalkulyator,glyukoza,kreatinin,preanalitika`
- ru: `лаборатория,биохимия,анализы,рСКФ,Вестгард,контроль качества,калькулятор,глюкоза,креатинин`
- en: `laboratory,biochemistry,lab tests,eGFR,Westgard,QC,Levey-Jennings,calculator,units,preanalytics`

## 6. App Privacy (Ma’lumotlar)

Server (Supabase) ulangan build uchun javoblar. **Tracking: No** (boshqa kompaniyalar ma’lumoti
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

**What to Test**
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

Reklama: ilovada hamkor e’lonlari bo‘lsa, Play Console → App content → **Ads: Yes**.
Hisobni o‘chirish havolasi (Play talabi): siyosat sahifasi + ilovadagi tugma.

