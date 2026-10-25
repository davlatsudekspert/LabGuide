# 10 — Boshqa asosiy funksiyalar

RU: Другие основные разделы · EN: Other main sections

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar
(`10_boshqa_funksiyalar`). How-to: `differential`, `cytology`, `spermogram`, `bloodGroup`, `histology`,
`urinalysis`, `bloodMorph`, `coagulogram`.

## Nega kerak
Lab tabidagi rasmli bo‘limlar — leykoformula, sitologiya, spermogramma, qon guruhi, gistologiya, siydik
tahlili, qon morfologiyasi, koagulogramma — har biri o‘z ish vositasi va mashqiga ega. Video ularni
qisqa tanishtiradi va har bo‘lim tepasidagi «Qanday foydalaniladi?» tugmasini ko‘rsatadi.

## Qanday ishlaydi
- Leykoformula: hujayralar, hisoblagich (+1 / −1, 100 yoki 200), saqlangan natijalar, talqin, mashq.
- Sitologiya: hujayralar, tozalik darajasi (belgilash → daraja), Bethesda, mashq.
- Spermogramma: JSST 2021 chegaralari, hisoblagich, baholash, atamalar, preanalitika, mashq.
- Qon guruhi: ABO/RhD, usullar, moslik, xatolar, reaksiya naqshini o‘qish, mashq.
- Gistologiya: to‘qimalar (haqiqiy mikrofotolar), bo‘yash usullari, mashq, mualliflar.
- Siydik tahlili: yig‘ish, fizik xossalar, test-chiziq, cho‘kma, natijani o‘qish, mashq.
- Qon morfologiyasi: normal eritrotsit, o‘zgarishlar, trombotsitlar, retikulotsitlar, anemiya, mashq.
- Koagulogramma: testlar, namuna, natijani o‘qish, ISTH DIC bali, antikoagulyant monitoringi (mashq yo‘q).
- Profil: til, birliklar, mavzu, «Bilim va malakani baholash» ko‘rinishi.
Dalil: har bo‘lim widget testi (`docs/VIDEO_FEATURE_INVENTORY.md`, 2-jadval).

## Qanday foydalaniladi
Har bo‘lim tepasida «Qanday foydalaniladi?» — 5 ta qadam va natija (ARB, uz/ru/en).

## Natijada nima olasiz
Bo‘limlar xaritasi va har bo‘limni ishlatish tartibi.

## Qisqa kirish matni
- UZ: Lab bo‘limlari: har birining tepasida «Qanday foydalaniladi?».
- RU: Разделы лаборатории: вверху каждого — «Как пользоваться?».
- EN: Lab sections: each has “How to use?” at the top.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Boshqa asosiy bo‘limlar | Другие основные разделы | Other main sections | 3 |
| 1 | `lab_top` | `/lab` | Lab tabi | Lab: rasmli bo‘limlar va atlaslar | Лаб.: разделы и атласы | Lab: sections and atlases | 3 |
| 2 | `diff_hub` | `/lab/differential` | «Qanday foydalaniladi?» ni bosish | Har bo‘lim tepasida — «Qanday foydalaniladi?» | Вверху каждого раздела — «Как пользоваться?» | At the top of every section — “How to use?” | 3.5 |
| 3 | `diff_howto` | `/lab/differential` | How-to oynasi | Qadamlar va natija — sizning tilingizda, internetsiz | Шаги и результат — на вашем языке, без интернета | Steps and the result — in your language, offline | 4.5 |
| 4 | `diff_count` | `/lab/differential/count` | Hisoblagich | Leykoformula: hisoblagich — bosish +1, uzoq bosish −1 | Лейкоформула: счётчик — нажатие +1, долгое нажатие −1 | Differential: counter — tap +1, long-press −1 | 4 |
| 5 | `cyto_hub` | `/lab/cytology` | Bo‘lim | Sitologiya: hujayralar, tozalik darajasi, Bethesda, mashq | Цитология: клетки, степень чистоты, Bethesda, тренировка | Cytology: cells, cleanliness grade, Bethesda, practice | 3.5 |
| 6 | `cyto_degree` | `/lab/cytology/degree` | Tozalik darajasi | Ko‘rganingizni belgilang — ilova darajani ko‘rsatadi | Отметьте увиденное — приложение покажет степень | Mark what you see — the app shows the grade | 3.5 |
| 7 | `sperm_hub` | `/lab/spermogram` | Bo‘lim | Spermogramma: JSST 2021 chegaralari, hisoblagich, baholash | Спермограмма: пределы ВОЗ 2021, счётчик, оценка | Semen analysis: WHO 2021 limits, counter, assessment | 3.5 |
| 8 | `bg_hub` | `/lab/bloodgroup` | Bo‘lim | Qon guruhi: ABO va RhD, usullar, moslik, xatolar | Группа крови: AB0 и RhD, методы, совместимость, ошибки | Blood grouping: ABO and RhD, methods, compatibility, errors | 3.5 |
| 9 | `histo_hub` | `/lab/histology` | Bo‘lim | Gistologiya: to‘qimalar, bo‘yash usullari, mashq | Гистология: ткани, методы окраски, тренировка | Histology: tissues, staining methods, practice | 3 |
| 10 | `histo_items` | `/lab/histology/items` | To‘qimalar ro‘yxati | Haqiqiy mikrofotolar, har biri asosiy belgi bilan | Настоящие микрофотографии с главным признаком | Real micrographs, each with its key feature | 3.5 |
| 11 | `urin_hub` | `/lab/urinalysis` | Bo‘lim | Siydik tahlili: yig‘ish, test-chiziq, cho‘kma, natijani o‘qish | Анализ мочи: сбор, тест-полоска, осадок, чтение результата | Urinalysis: collection, strip, sediment, result reader | 3.5 |
| 12 | `bm_hub` | `/lab/bloodmorph` | Bo‘lim | Qon morfologiyasi: eritrotsitlar, trombotsitlar, anemiya | Морфология крови: эритроциты, тромбоциты, анемия | Blood morphology: red cells, platelets, anaemia | 3.5 |
| 13 | `coag_hub` | `/lab/coagulogram` | Bo‘lim | Koagulogramma: testlar, namuna, natijani o‘qish, DIC bali | Коагулограмма: тесты, проба, чтение результата, балл ДВС | Coagulogram: tests, sample, result reading, DIC score | 3.5 |
| 14 | `profile` | `/profile` | Profil | Profil: til, birliklar va bo‘lim ko‘rinishi | Профиль: язык, единицы и видимость раздела | Profile: language, units and section visibility | 4 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 56.0 s, ru — 56.0 s, en — 56.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
50–55 s (har bo‘lim 3–4 s; batafsil — bo‘limning o‘z how-to oynasida).

## Kerakli ekran yozuvlari
Lab tabi; leykoformula (how-to oynasi bilan), hisoblagich; sitologiya va tozalik darajasi; spermogramma,
qon guruhi, gistologiya (+ to‘qimalar ro‘yxati), siydik tahlili, qon morfologiyasi, koagulogramma; Profil.

## Ma’lum cheklovlar
- Har bo‘lim faqat qisqa ko‘rsatilgan (alohida chuqur video yo‘q).
- Sxematik rasmlar — LabGuide chizgan (mikrofoto emas), kartalarda yozilgan.

## Ilmiy dars rejasi (alohida, har bo‘lim uchun)
**NEEDS_EXPERT** — har bo‘lim bo‘yicha alohida dars; manbalar — bo‘limlarda keltirilganlar:
sitologiya — Nayar R, Wilbur DC (Bethesda, 2015), `docs/CYTOLOGY_SOURCES.md`; spermogramma — WHO 2021 va
2010, EAU; qon guruhi — Milkins C va boshq. 2013, WHO 2009, Norfolk D 2013, `docs/BLOODGROUP_SOURCES.md`;
gistologiya — Hortsch M (Michigan), Human Protein Atlas, `docs/HISTOLOGY_SOURCES.md`; qon morfologiyasi —
WHO 2003, Adewoyin AS 2014, Gerber GF 2024, `docs/BLOODMORPH_SOURCES.md`; siydik — WHO 2003, Delanghe J
2014, Simerville JA 2005, `docs/URINALYSIS_SOURCES.md`; koagulogramma — Hickey K 2025, Khasiani A 2025,
Magnette A 2016, Wada H 2014, `docs/COAGULOGRAM_SOURCES.md`.
