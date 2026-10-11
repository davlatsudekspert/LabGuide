# Kontent auditi 2026-10-11 — klinik biokimyo / laboratoriya diagnostikasi

Mustaqil tekshiruvchi (klinik biokimyogar nuqtai nazari). Qamrov: analit
kartalari va `conditions` (core pack, 119 karta, 43 holat), 7 klinik va
qo‘lda hisob kalkulyatorlari, birlik konversiyalari, 173 viktorina savoli,
ma’lumotnoma (`reference_content.dart`), preanalitika
(`preanalytics_info.dart`), Toifa rasmiy banki (faqat kalit shubhalari),
mikroskopiya/leykoformula rasmlari. Hech bir yozuv `approved/verified` deb
belgilanmadi — hammasi `draft`/`pending` holatida qoldi.

## 1. Nima tekshirildi va qanday

| Qism | Usul | Natija |
|---|---|---|
| Molyar massa / konversiya koeffitsiyentlari (15 karta) | Skript: formula → IUPAC atom massalari → M; mg/dL→SI koeffitsiyenti | 15/15 mos (glyukoza 0,05551; kreatinin 88,40; siydik kislotasi 59,48; bilirubin 17,10; xolesterin 0,02586; TG 0,01129; Ca 0,2495; Mg 0,4114; P 0,3229; laktat 0,1110) |
| Matndagi mg/dL ↔ mmol/L juftliklari (29 ta) | Skript bilan ajratildi, har biri qayta hisoblandi | Hammasi to‘g‘ri (LDL/non-HDL ESC 2019 maqsadlari, ADA/NIDDK diabet chegaralari, likvor glyukozasi 2,77–4,44) |
| eGFR CKD-EPI 2021 | Mustaqil Python qayta hisob (Inker 2021: 142, κ 0,7/0,9, α −0,241/−0,302, −1,200, 0,9938, ×1,012) | 4 test holati 0,01 aniqlikda mos; KDIGO G toifalari to‘g‘ri |
| Anion oralig‘i (+K, Figge albumin 2,5/g/dL) | Formula va test qiymatlari | To‘g‘ri |
| Payne tuzatilgan Ca | SI: 2,0 mmol/L, alb 30 g/L → 2,2495 | To‘g‘ri |
| Friedewald / Sampson / non-HDL | Mustaqil hisob: 200/50/150 → 120 va 123,397; SI 5,2/1,3/1,7 → 3,1214 va 3,2095 | To‘g‘ri; TG chegaralari 400/800 mg/dL to‘g‘ri |
| Osmolyallik | 2Na + glyukoza/18 + BUN/2,8; SI 2Na + glyukoza + mochevina | To‘g‘ri |
| HbA1c NGSP↔IFCC, eAG | NGSP = 0,09148·IFCC + 2,152; eAG 28,7·A1C − 46,7 | To‘g‘ri; ADAG 2-jadval bilan test bor |
| ACR, KDIGO A1–A3 | Chegaralar 3/30 mg/mmol, 30/300 mg/g | To‘g‘ri |
| Qo‘lda hisoblar (kamera, NRBC tuzatish, retikulotsit/RPI, Light, Nechiporenko, Kakovskiy–Addis, Zimnitskiy) | Formulalar va birliklar | To‘g‘ri (izohlar pastda) |
| Viktorina (173) | Har savol va kalit o‘qildi (en), ru/uz da lotin qoldiqlari skript bilan | Kalit xatosi topilmadi |
| Toifa banki (407 “ok” savol) | Har savol va kalit o‘qildi | 2 ta kalit shubhasi (pastda); matn o‘zgartirilmadi |
| Leykoformula rasmlari | Foydalanish joylari | Hammasi “Sxematik rasm — mikrofoto emas” izohi bilan; atlas — manbali haqiqiy mikrofotolar |
| Kritik qiymatlar | `qc_guides_info.dart` | Universal raqamlar yo‘q, laboratoriya belgilaydi — to‘g‘ri yondashuv |

## 2. Tuzatilgan xatolar

| # | Joy | Xato | Tuzatish | Manba | Og‘irlik |
|---|---|---|---|---|---|
| 1 | `conditions.json` → `metabolic-syndrome`, glyukoza naqshi (uz/ru/en) | Mezon “och qoringa glyukoza ≥ 126 mg/dL (≈7,0 mmol/L)” deb berilgan edi. Bu diabet chegarasi; metabolik sindrom mezoni — ≥ 100 mg/dL (5,6 mmol/L) yoki qand pasaytiruvchi dori. Natijada 100–125 mg/dL dagi bemorda mezon “yo‘q” deb o‘qilardi. | “≥ 100 mg/dL (≈5,6 mmol/L) yoki dori”; izoh: 100–125 — yuqori qand/prediabet, ≥ 126 — diabet bo‘lishi mumkin | NHLBI *What Is Metabolic Syndrome?* (“High blood sugar levels” — sindrom sharti) + *Diagnosis → Blood sugar* (“100–125 mg/dL … high blood sugar levels or prediabetes”); xalqaro uyg‘unlashtirilgan mezon bilan mos: Alberti KGMM va boshq. Circulation 2009;120:1640–5, doi:10.1161/CIRCULATIONAHA.109.192644 (PubMed 19805654) | Yuqori |
| 2 | `books_hem_liver.json` → `anemia-workup`, “MCV normal, retikulotsit past/normal” (uz/ru/en) | en: “With severe anaemia and very low reticulocytes, marrow failure **is ruled out**” — teskari ma’no (aslida ko‘mik yetishmovchiligini istisno qilish, ya’ni tekshirish kerak). ru/uz “исключают / istisno qilinadi” ikki ma’noli. | en “must be excluded (investigated)”; ru “необходимо исключить (обследовать)”; uz “istisno qilish (tekshirish) kerak” | MedlinePlus *Reticulocyte Count* → “What do the results mean?” (past retikulotsit — ko‘mik yetishmovchiligi belgisi bo‘lishi mumkin) | Yuqori (xavfli noto‘g‘ri xulosa) |
| 3 | `preanalytics_info.dart`, gemoliz sabablari (en) | “23 gauge or **smaller**” — gauge raqami kichik = igna yo‘g‘on; uz/ru “ingichka/тоньше” bilan zid edi | “23 gauge or **finer**” | WHO *Guidelines on drawing blood* 2010 (gemoliz sabablari) | Past |

Regressiya testlari: `test/unit/conditions_test.dart` → “clinical content audit
2026-10-11” guruhi (№1, №2). Kalkulyator kodi o‘zgarmadi — mavjud testlar
mustaqil hisob bilan mos keldi.

## 3. Noaniq yoki egasi qarori kerak bo‘lgan masalalar (kontent o‘zgartirilmadi)

| Element | Muammo | Dalil | Taklif | Ishonch |
|---|---|---|---|---|
| `ldl-c`, `non-hdl-c` treatment_goals — NCEP ATP III 2001/2004 | Ekranda ESC/EAS 2019 va ACC/AHA 2018 bilan yonma-yon, “eskirgan” belgisisiz. ATP III maqsadlari ACC/AHA 2013/2018 bilan almashtirilgan. | ACC/AHA 2018 Blood Cholesterol Guideline | Guruhga “tarixiy (almashtirilgan)” belgisi yoki ATP III ni olib tashlash | Yuqori |
| ACC/AHA dislipidemiya yo‘riqnomasi | 2026 yilda yangi ACC/AHA dislipidemiya yo‘riqnomasi chiqqan bo‘lishi mumkin (LDL maqsadlari qaytarilgan) — tekshira olmadim | — | Egasi/ekspert yangi nashrni tekshirsin; tasdiqlansa 2018 yozuvlari yangilanadi | Past |
| `hba1c` claim “Point-of-care tests … should not be used for diagnosis” va `hba1c-q2` viktorina kaliti | ADA Standards of Care (2023 dan) FDA tasdiqlagan, o‘rtacha murakkablikdagi CLIA laboratoriyasida bajarilgan POC A1C ni tashxis uchun ruxsat beradi; NIDDK matni eskiroq | ADA Standards of Care, 2-bo‘lim (Diagnosis) | “Sertifikatlanmagan POC qurilmalar tashxis uchun ishlatilmaydi” deb aniqlashtirish | O‘rta |
| HbA1c chegaralari faqat % da | SI-birinchi qoidasi: 6,5 % = 48 mmol/mol, 5,7–6,4 % = 39–46 mmol/mol (IFCC) — kartada ko‘rsatilmaydi | NGSP master tenglamasi (kalkulyatorda bor) | DL ga IFCC ekvivalentini hisoblab ko‘rsatish (glyukozadagi “hisoblangan” belgisi kabi) | Yuqori |
| Glyukoza/OGTT prediabet chegarasi (NIDDK/ADA 100–125 mg/dL) | O‘zbekiston/MDH amaliyoti JSST mezoniga tayanadi: IFG 6,1–6,9 mmol/L (110–125 mg/dL); populyatsiya “NIDDK” deb ko‘rsatilgan, lekin JSST alternativasi yo‘q | WHO/IDF 2006; WHO 2011 (HbA1c) | JSST chegaralarini alohida DL sifatida qo‘shish | O‘rta |
| `preeclampsia` naqshi “protein ≥ 5 g/24 h” og‘ir belgi sifatida | ACOG 2013 va Practice Bulletin 222 (2020) massiv proteinuriyani og‘ir belgilar ro‘yxatidan chiqargan; manba (NICHD) eskiroq | ACOG PB 222 (2020) | Uni olib tashlash yoki “eski mezon” deb belgilash | O‘rta |
| `heart-failure` naqshi “41–49 % borderline” | Joriy atama — “mildly reduced EF (HFmrEF)” (Universal definition 2021, ESC 2021, AHA/ACC 2022) | Bozkurt 2021 | Atamani yangilash | O‘rta |
| `metabolic-syndrome` TG “consistently > 150 mg/dL” | Uyg‘unlashtirilgan mezon ≥ 150 mg/dL (1,7 mmol/L); NHLBI sahifasi “> 150” deydi | Alberti 2009 | ≥ 150 ga o‘zgartirish (manba farqini izohlab) | O‘rta |
| `calcium-disorders`: ikkilamchi giperparatireoz sababi “low phosphate or magnesium” | Manbada shunday (MedlinePlus PTH), lekin klinik jihatdan CKD da fosfat yuqori bo‘ladi; og‘ir gipomagniyemiya PTH sekretsiyasini kamaytiradi | MedlinePlus *PTH test* | Ekspert ko‘rigi | Past |
| `hemochromatosis`: “HFE C282Y gomozigota → birlamchi gemoxromatozni tasdiqlaydi” | Penetrantlik to‘liq emas — genotip temir ortiqchaligi belgilari bilan birga tashxis | EASL 2022 | “temir ortiqchaligi bilan birga” qo‘shish | Past |
| `reference_content` MCHC: “> 36 g/dL artefakt ehtimoli (Takami 2026)” | Irsiy sferotsitozda MCHC 36–38 g/dL bo‘lishi mumkin; manba (Takami 2026) ni ko‘ra olmadim | — | “artefakt yoki sferotsitoz” deb aniqlashtirish (holatlarda sferotsitoz naqshi bor) | Past |
| `preanalytics_info` kaliy: “ajratilmagan qonda xona haroratida 1 soatda ko‘tariladi” | Odatda ko‘tarilish sovutilgan ajratilmagan qonda tezroq; WHO/DIL/LAB/99.1 sahifasini tekshira olmadim | — | Manba sahifasi bilan solishtirish | Past |
| Retikulotsit yetilish jadvali (Ht 45/35/25/**20** → 1,0/1,5/2,0/2,5) | Klassik Hillman jadvalida Ht **15** % → 2,5 (ba’zi manbalarda 20). Ilova manba sifatida Kroll 2015 ni ko‘rsatadi | Hillman 1969 (ilovada manba bor) | Kroll 2015 jadvali bilan qayta solishtirish | Past |
| Corrected Ca (Payne) cheklovlari | Tuzatilgan kalsiy ko‘p holatda (CKD, og‘ir bemorlar) ishonchsiz; ionlangan Ca afzal — cheklovlarda yozilmagan | KDIGO CKD-MBD 2017 | Cheklov qo‘shish | O‘rta |
| eGFR cheklovlari | Barqaror bo‘lmagan holat (AKI), mushak massasi o‘ta past/yuqori — kalkulyator izohida yo‘q (viktorina `egfr-q2` da bor) | KDIGO 2024 CKD | Cheklov qo‘shish; manbani KDIGO 2024 ga yangilash (G/A toifalari o‘zgarmagan) | O‘rta |
| `ldl-c`/`non-hdl-c` target_text (ru/uz) | “mmol/L”, “mg/dL”, nuqtali o‘nlik — ru da “ммоль/л”, uz/ru da vergul bo‘lishi kerak | Ilova birlik qoidasi | `goalTextInSi` regex’i lotin “mg/dL” ga bog‘liq — birga o‘zgartirish kerak | Past |
| Viktorina `troponin-q1` “12 soat ichida takrorlanadi” | hs-cTn algoritmlari 0/1 soat yoki 0/2 soat (ESC 2023) | ESC ACS 2023 | Izohga hs-troponin algoritmini qo‘shish | Past |
| Holatlar matnida mg/dL birinchi | Qoida: SI birinchi | — | Egasi qaroriga ko‘ra ommaviy almashtirish | Past |

## 4. Toifa rasmiy banki — kalit shubhalari (o‘zgartirilmadi)

Bankda 81 savol allaqachon `ambiguous`/`disputed`. Qolgan 407 “ok” savoldan:

| Savol | Shubha | Ishonch |
|---|---|---|
| `kdl-t-246` “Axlatning nordon reaksiyasi qaysi holda?” — kalit “Axiliya” | Nordon (pH < 6) reaksiya **bijg‘ish (brodil) dispepsiyasiga** xos; axiliyada (chirish) reaksiya ishqoriy. Kutilgan kalit — “Brodil dispepsiya”. | Yuqori |
| `kdl-t-420` “Aldolaza, aminotransferaza, LDG-1 ↑, KK normal” — kalit “Virusli gepatit” | Virusli gepatitda LDG-**5** oshadi, LDG-1 — miokard/eritrotsit izofermenti. Asl matnda LDG-5 bo‘lishi ehtimol. | O‘rta |

Eskirgan, lekin rasmiy kalitga ko‘ra “to‘g‘ri” javoblar (o‘quv izohi kerak):
prostata saratoni — kislota fosfataza (`t-302`, `t-317`, hozir PSA); MI —
CK (`t-105`, `t-300`, `t-381`, hozir troponin); o‘tkir leykoz turi —
sitokimyo (`t-049`, `t-237`, hozir immunofenotiplash); pankreas — amilaza
(`t-068`, hozir lipaza afzal).

## 5. Og‘irlik bo‘yicha hisob

- Yuqori: 2 tuzatildi (metabolik sindrom glyukoza mezoni; anemiya algoritmidagi teskari xulosa); 2 ochiq (ATP III maqsadlari belgisiz; HbA1c IFCC ko‘rsatilmaydi); 1 Toifa kalit shubhasi.
- O‘rta: 0 tuzatildi; 7 ochiq (POC A1C, JSST glyukoza mezonlari, preeklampsiya proteinuriyasi, HFmrEF atamasi, TG ≥ 150, Payne cheklovi, eGFR cheklovlari) + 1 Toifa kalit shubhasi.
- Past: 1 tuzatildi (igna gauge, en); 9 ochiq.
- Kalkulyator formulalari va konversiya koeffitsiyentlarida xato topilmadi.
