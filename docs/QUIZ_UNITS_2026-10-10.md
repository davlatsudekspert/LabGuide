# Mashq va kunlik savollar: qo'sh birlik (2026-10-10)

Egasining qarori: savol matnidagi laboratoriya qiymatlari jahon adabiyoti
uslubida — **SI birinchi, konvensional qavsda**, masalan "7,0 mmol/L
(126 mg/dL)" (uz/ru — o'nlik vergul, en — nuqta). Manba qiymatni faqat
konvensional birlikda bergan bo'lsa: SI hisoblanadi, qavsda manbadagi asl
raqam (o'zgartirilmagan, yaxlitlanmagan).

* Raqamlar `tool/content/quiz_dual_units.py` da hisoblandi (qo'lda emas);
  skript idempotent, `--check` bilan faqat ko'rsatadi.
* Kunlik savollar shu ikki hovuzdan olinadi (kontent paketi `quiz` va toifa
  banki) — alohida matn yo'q.
* "≥", "<", "=" belgilari aynan saqlandi; `correct_index` / toifa `key`
  o'zgarmadi. Kontent `draft` (`review_state: pending`) qoladi; o'zgargan
  savollarga `review.agent_checks` yozildi (mutaxassis tasdig'i emas).
* Toifa banki: rasmiy `q`, `q_orig`, `options` ga tegilmadi — faqat LabGuide
  izohi (`note`, manbada `verdict_note_uz`); asset
  `tool/toifa/build_toifa.py` bilan qayta yig'ildi.
* Tekshiruv: `test/unit/quiz_units_test.dart` — matndan "X SI (Y konv.)"
  juftlarini ajratib, analit koeffitsientiga (yaxlitlash chegarasida) va
  til o'nlik belgisiga mosligini, juftsiz konvensional/SI qiymat
  qolmaganini va koeffitsientlar ilovadagi `conversion` (molyar massa)
  ma'lumotiga mosligini tekshiradi.

## Koeffitsientlar va yaxlitlash

| Analit | Konversiya | Yaxlitlash | Ilova ma'lumoti bilan |
|---|---|---|---|
| Glyukoza | mmol/L = mg/dL ÷ 18,016 | SI 1 xona; mg/dL butun | 180,156 g/mol → 18,0156 — mos |
| Gemoglobin | g/L = g/dL × 10 | g/L butun; g/dL 1 xona | — (birlik ko'paytuvchisi) |
| MCHC | g/L = g/dL × 10 | butun | — |
| Umumiy oqsil | g/L = g/dL × 10 | g/L butun; g/dL 1 xona | — |
| HbA1c | mmol/mol = 10,929 × (% − 2,15) | butun | — |

Testda qo'shimcha tekshirildi (bu safar matnda uchramadi): xolesterin/LDL/
HDL/non-HDL 38,67, triglitseridlar 88,57, kreatinin 88,42 (ilovada
10000/113,12 = 88,40 — farq 0,02 %), siydik kislotasi 59,48, bilirubin 17,1,
kalsiy 0,2495, magniy 0,4114, fosfat 0,3229 — hammasi ilovadagi molyar
massalarga 0,1 % ichida mos.

## O'zgargan savollar

### Kontent paketi (4 savol)

| id | Joy | Eski → yangi | Koeffitsient |
|---|---|---|---|
| `ogtt-q2` (pack.json) | savol uz/ru/en | 140–199 mg/dL → 7,8–11,0 mmol/L (140–199 mg/dL); 200 mg/dL → 11,1 mmol/L (200 mg/dL) | glyukoza ÷18,016 |
| `ogtt-q2` | A variant izohi uz/ru/en | 100–125 va 126 mg/dL → 5,6–6,9 mmol/L (100–125 mg/dL) va 7,0 mmol/L (126 mg/dL) | glyukoza ÷18,016 |
| `hemoglobin-q1` (hematology.json) | asos, 3 variant, A izohi uz/ru/en | < 120 g/L → < 120 g/L (12,0 g/dL); < 130 g/L → < 130 g/L (13,0 g/dL); < 110 g/L → < 110 g/L (11,0 g/dL) | g/L ÷10 (manba SI) |
| `hemoglobin-q2` (hematology.json) | asos, B variant uz/ru/en | 8 g/L → 8 g/L (0,8 g/dL) (balandlik tuzatishi) | g/L ÷10 (manba SI) |
| `books-mchc-artefact` (books_hem_liver.json) | savol uz/ru/en | MCHC 39 g/dL → 390 g/L (39 g/dL) | ×10 |
| `books-mchc-artefact` | asos uz/ru/en | 36–38 g/dL → 360–380 g/L (36–38 g/dL) | ×10 |

Qavs ichma-ich tushmasligi uchun ayrim jumlalarda tartib biroz o'zgardi
(masalan "140–199 mg/dL (prediabet)" → "prediabet uchun 7,8–11,0 mmol/L
(140–199 mg/dL)"; "Tuzatish (8 g/L)" → "Tuzatish — 8 g/L (0,8 g/dL) —");
ma'no va javob kaliti o'zgarmagan.

### Toifa banki — faqat LabGuide izohi (3 savol)

| id | Eski → yangi | Koeffitsient |
|---|---|---|
| `kdl-t-109` | (~180 mg/dL ≈ 10 mmol/L) → taxminan 10,0 mmol/L (180 mg/dL); 11,9 mmol/L → 11,9 mmol/L (214 mg/dL) | glyukoza 18,016 |
| `kdl-t-264` | 60–80 g/L → 60–80 g/L (6,0–8,0 g/dL); 65–80 g/L → 65–80 g/L (6,5–8,0 g/dL) | g/L ÷10 |
| `kdl-t-451` | normal <5,7% → normal <39 mmol/mol (5,7%) | 10,929 × (% − 2,15) |

## O'zgartirilmaganlar va sabab

| id | Matndagi qiymat | Sabab |
|---|---|---|
| `unit-factor` | "glyukoza ≈ 18,0 mg/dL har 1 mmol/L ga, kreatinin ≈ 11,3 mg/dL" | Koeffitsientning o'zi haqida gap, laboratoriya natijasi emas (testda istisno) |
| `transferrin-tibc-q1` | temir 50 µg/dL, TIBC 400 µg/dL | Temir koeffitsienti (µmol/L ×0,179) topshiriqdagi ro'yxatda ham, ilovadagi `conversion` ma'lumotida ham yo'q — egasi qaroriga qoldirildi; hisob (50/400×100) birlikka bog'liq emas |
| `vitamin-b12-q1` | B12 250 pg/mL, 150–399 pg/mL | pg/mL → pmol/L (×0,738) ro'yxatda yo'q (vitamin/gormon toifasi) |
| `platelets-q1` | 150 000/µL va h.k. | Hujayra soni (/µL ↔ ×10⁹/L) — konsentratsiya konversiyasi ro'yxatida yo'q |
| `hematocrit-q1`, `coagulation-factors-q1`, `lipoprotein-a-q1`, `vaginal-wet-mount-q2`, `transferrin-tibc-q1` (%) | foiz | Ulush/faollik — birlik konversiyasi tegishli emas |
| `csf-analysis-q1` | 2/3 nisbat | Nisbat |
| Toifa `kdl-t-184` | ×10⁹/L, % | Hujayra soni |
| Toifa `kdl-t-363` | U, kat | Ferment birliklari — o'zgartirilmaydi |
| Toifa `kdl-t-109`, `kdl-t-264` rasmiy variantlari ("11.9 mmol/l", "65-80 g/l") | — | Rasmiy matn — o'zgartirilmaydi |
| Manba lokatorlari (`refs.locator`, masalan `kdl-t-109` "~180 mg/dL") | — | Manba iqtibosi, savol matni emas |

Ishonchsiz deb belgilangan qiymat yo'q: barcha o'zgargan raqamlar manbadagi
asl qiymatdan bitta rasmiy koeffitsient bilan hisoblangan.
