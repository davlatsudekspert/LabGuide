# 04 — Kalkulyatorlar

RU: Калькуляторы · EN: Calculators

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar (`04_kalkulyatorlar`).
How-to: `HowToSection.calculators`.

## Nega kerak
Kundalik hisoblar (eGFR, ACR, anion oralig‘i, tuzatilgan kalsiy, LDL, osmolyallik, HbA1c, hisob kamerasi,
leykoformula mutlaq sonlari, retikulotsitlar, Light, rang ko‘rsatkichi, Nechiporenko, Kakovskiy–Addis,
Zimnitskiy, suyultirish, birliklar) qo‘lda xatoga moyil. 17 ta kalkulyator bir joyda, formula va manbasi
bilan.

## Qanday ishlaydi
Maydonlar bo‘sh ochiladi; natija faqat kiritilgan qiymatdan hisoblanadi; noto‘g‘ri kirish (masalan,
jins tanlanmagan, bola yoshi eGFR uchun) — aniq xato matni. Natija ostida formula, cheklovlar va
manbalar. Dalil: `test/widget/clinical_calc_test.dart`, `test/widget/manual_calc_test.dart`,
`test/unit/clinical_calculators_test.dart`.

## Qanday foydalaniladi
1. Kalkulyatorni tanlang.
2. Qiymatlar va birliklar.
3. Parametr (masalan, jins) → «Hisoblash».
4. Izoh va manbalar.

## Natijada nima olasiz
Faqat siz kiritgan qiymatlardan hisoblangan natija — formula va manbasi bilan.

## Qisqa kirish matni
- UZ: 17 ta laboratoriya kalkulyatori: qiymatni kiriting — natija formula va manbasi bilan.
- RU: 17 лабораторных калькуляторов: введите значения — результат с формулой и источником.
- EN: 17 lab calculators: enter your values — get the result with its formula and source.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Kalkulyatorlar | Калькуляторы | Calculators | 3 |
| 1 | `lab_tools` | `/lab` | «Kalkulyatorlar» ni bosish | Lab → «Kalkulyatorlar» | Лаб. → «Калькуляторы» | Lab → “Calculators” | 3 |
| 2 | `calc_list` | `/lab/calculators` | eGFR qatorini bosish | 17 ta kalkulyator: klinik formulalar, qo‘lda usullar, laboratoriya | 17 калькуляторов: клинические, ручные, лабораторные | 17 calculators: clinical formulas, manual methods, laboratory | 4 |
| 3 | `calc_egfr` | `/lab/calculators/egfr` | Bo‘sh forma | eGFR (CKD-EPI 2021): maydonlar bo‘sh — qiymatni o‘zingiz kiritasiz | рСКФ (eGFR, CKD-EPI 2021): поля пустые — значения вводите вы | eGFR (CKD-EPI 2021): fields start empty — you enter the values | 3.5 |
| 4 | `calc_egfr_input` | `/lab/calculators/egfr` | Kreatinin 88, yosh 45; «Erkak» ni bosish | Kreatinin va yosh → jinsni tanlang → «Hisoblash» | Креатинин и возраст → пол → «Рассчитать» | Creatinine and age → sex → “Calculate” | 4 |
| 5 | `calc_egfr_result` | `/lab/calculators/egfr` | Natija | Natija va KDIGO toifasi; kiritilgan qiymatlar ham ko‘rsatiladi | Результат и категория KDIGO; введённые значения тоже видны | Result and KDIGO category; your inputs are shown too | 4 |
| 6 | `calc_egfr_sources` | `/lab/calculators/egfr` | Formula va cheklovlarga surish | Formula va cheklovlar — manbalari bilan | Формула и ограничения — с источниками | Formula and limitations — with sources | 4 |
| 7 | `howto` | `/lab/calculators` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 33.0 s, ru — 33.0 s, en — 33.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
30–35 s (namuna sifatida faqat eGFR ko‘rsatiladi).

## Kerakli ekran yozuvlari
Lab tabi; kalkulyatorlar ro‘yxati; eGFR bo‘sh shakli; kiritilgan qiymatlar (kreatinin 88 µmol/L, 45 yosh,
erkak — **namuna**); natija va KDIGO toifasi; formula va cheklovlar.

## Ma’lum cheklovlar
- Videoda 17 tadan bittasi (eGFR) ko‘rsatilgan; boshqalari xuddi shu tartibda ishlaydi.
- Natija o‘quv va tekshirish vositasi: tashxis qo‘ymaydi (ekrandagi eslatma).

## Ilmiy dars rejasi (alohida)
**NEEDS_EXPERT.** Manbalar — ilovada keltirilganlar: CKD-EPI 2021, KDIGO 2024 (eGFR cheklovlari),
KDIGO ACR toifalari, Payne 1973 (kalsiy), Friedewald va Sampson (LDL), NGSP/IFCC/ADAG (HbA1c); qo‘lda
usullar uchun `lib/features/tools/manual_calc_info.dart` dagi manbalar.
1. eGFR: formula, birliklar, cheklovlar; 2. ACR toifalari; 3. Elektrolit hisoblari; 4. Qo‘lda usullar.
