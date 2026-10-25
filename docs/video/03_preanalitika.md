# 03 — Preanalitika: namuna yo‘li

RU: Преаналитика: путь образца · EN: Preanalytics: the sample’s path

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar
(`03_preanalitika`). How-to: `HowToSection.preanalytics`.

## Nega kerak
Laboratoriya xatolarining katta qismi tahlilgacha bosqichda yuzaga keladi (ilovadagi og‘zaki bilet javob
rejasida keltirilgan ma’lumot). Bemor tayyorgarligi, probirka tanlash va tartibi, saqlash va tashish
qoidalari bir sahifada, manbalari bilan.

## Qanday ishlaydi
Statik ma’lumotnoma sahifasi: 5 bosqich, umumiy sxema, bemor tayyorgarligi (har band oxirida manba
belgisi), venepunksiyada probirkalar tartibi (JSST 2010, 2.3-jadval; NCCLS 2003 konsensusi asosida),
qaysi tahlilga qaysi probirka, saqlash va tashish. Dalil: `test/unit/preanalytics_test.dart`.

## Qanday foydalaniladi
1. Tepada — 5 bosqich.
2. Bemor tayyorgarligi.
3. Probirkalar tartibi.
4. Ajratish, saqlash, tashish, qabul qilish.
5. Laboratoriya SOP i bilan solishtirish.

## Natijada nima olasiz
Namuna olishdan oldin va keyin tekshiriladigan qoidalar — manbalari bilan, bir sahifada.

## Qisqa kirish matni
- UZ: Natija namuna olinishidan oldin boshlanadi: tayyorgarlik, probirka va tartib — bir sahifada.
- RU: Результат начинается до взятия образца: подготовка, пробирка и порядок — на одной странице.
- EN: A result starts before the sample is taken: preparation, tube and order — on one page.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Preanalitika: namuna yo‘li | Преаналитика: путь образца | Preanalytics: the sample’s path | 3 |
| 1 | `lab_tools` | `/lab` | «Preanalitika» ni bosish | Lab → «Preanalitika» | Лаб. → «Преаналитика» | Lab → “Preanalytics” | 3 |
| 2 | `pre_top` | `/lab/preanalytics` | Sahifa tepasi | 5 bosqich: tahlilga tayyorlashdan qabul qilishgacha | 5 этапов: от подготовки к анализу до приёма | 5 stages: from preparing for the test to receipt | 4 |
| 3 | `pre_patient` | `/lab/preanalytics` | Bemor tayyorgarligiga surish | Bemor tayyorgarligi — har band manbasi bilan | Подготовка пациента — у каждого пункта источник | Patient preparation — every point with its source | 4.5 |
| 4 | `pre_tubes` | `/lab/preanalytics` | Probirkalar tartibiga surish | Probirkalar tartibi (JSST 2010) va qopqoq ranglari | Порядок пробирок (ВОЗ 2010) и цвета крышек | Order of draw (WHO 2010) and cap colours | 4.5 |
| 5 | `pre_more` | `/lab/preanalytics` | Pastroqqa surish | Qaysi tahlilga qaysi probirka — laboratoriyangiz SOP i bilan solishtiring | Какая пробирка для какого анализа — сверяйте с СОП вашей лаборатории | Which tube for which test — check against your lab’s SOP | 4.5 |
| 6 | `howto` | `/lab/preanalytics` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 31.0 s, ru — 31.0 s, en — 31.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
30–35 s.

## Kerakli ekran yozuvlari
Lab tabi; preanalitika sahifasining tepasi, bemor tayyorgarligi, probirkalar tartibi va pastki qismi
(surish bilan).

## Ma’lum cheklovlar
- Probirka ranglari va qo‘shimchalar ishlab chiqaruvchiga qarab farq qiladi — sahifada shunday yozilgan.
- Interaktiv qism yo‘q (faqat o‘qish).

## Ilmiy dars rejasi (alohida)
**NEEDS_EXPERT.** Manbalar — sahifada keltirilganlar (JSST 2010 «WHO guidelines on drawing blood», NCCLS
2003, MedlinePlus tayyorgarlik sahifalari) va `docs/BOOKS_PREANALYTICS_2026-10-09.md`.
1. Preanalitik xatolar turlari; 2. Bemor tayyorgarligi; 3. Probirkalar tartibi va sababi; 4. Saqlash va
tashish; 5. Namunani rad etish mezonlari (laboratoriya SOP i bo‘yicha).
