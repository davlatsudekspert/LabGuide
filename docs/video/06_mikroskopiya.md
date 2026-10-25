# 06 — Mikroskopiya atlasi va mashq

RU: Атлас микроскопии и тренировка · EN: Microscopy atlas and practice

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar (`06_mikroskopiya`).
How-to: `HowToSection.microscopy`.

## Nega kerak
Siydik cho‘kmasi, qon surtmasi va qon parazitlarini tanishni mashq qilish uchun litsenziyali mikrofotolar
va o‘zini tekshirish mashqi.

## Qanday ishlaydi
3 bo‘lim (siydik cho‘kmasi, periferik qon surtmasi, qon parazitlari — bezgak); har rasm kartasida nomi 3
tilda, litsenziya, muallif va asl izoh; rasmi hali yo‘q elementlar ochiq belgilangan. Qidiruv (uz/ru/en).
«Bu nima?» mashqi: bo‘lim tanlanadi, 4 variant — hammasi atlasdagi nomlardan, javob darhol. Dalil:
`test/widget/microscopy_flow_test.dart`, `test/unit/microscopy_atlas_test.dart`.

## Qanday foydalaniladi
1. Bo‘limni tanlang. 2. Rasm kartasi. 3. Qidiruv. 4. «Mashqni boshlash». 5. Natija va xatolarni qayta
ishlash.

## Natijada nima olasiz
Litsenziyali mikrofotolar atlasi va o‘zingizni tekshirish uchun rasmli mashq.

## Qisqa kirish matni
- UZ: Litsenziyali mikrofotolar: ko‘ring, qidiring va «Bu nima?» mashqida o‘zingizni tekshiring.
- RU: Лицензированные микрофото: смотрите, ищите и проверяйте себя в тренировке «Что это?».
- EN: Licensed micrographs: browse, search and test yourself with “What is it?”.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Mikroskopiya atlasi va mashq | Атлас микроскопии и тренировка | Microscopy atlas and practice | 3 |
| 1 | `lab_sections` | `/lab` | «Mikroskopiya atlasi» ni bosish | Lab → «Mikroskopiya atlasi» | Лаб. → «Атлас микроскопии» | Lab → “Microscopy atlas” | 3 |
| 2 | `mic_top` | `/lab/microscopy` | Atlas tepasi | Qidiruv, «Bu nima?» mashqi va bo‘limlar | Поиск, тренировка «Что это?» и разделы | Search, the “What is it?” practice and sections | 3.5 |
| 3 | `mic_sections` | `/lab/microscopy` | «Siydik cho‘kmasi» ni bosish | Bo‘limlar: siydik cho‘kmasi, qon surtmasi, qon parazitlari (bezgak) | Разделы: осадок мочи, мазок крови, паразиты крови (малярия) | Sections: urine sediment, blood film, blood parasites (malaria) | 4 |
| 4 | `mic_section` | `/lab/microscopy/s/urine` | Rasmni bosish | Litsenziyali mikrofotolar; rasmi hali yo‘q elementlar ham ochiq ko‘rsatilgan | Лицензированные снимки; элементы без снимка тоже честно показаны | Licensed micrographs; items without a picture yet are shown openly | 4 |
| 5 | `mic_image` | `/lab/microscopy/i/:id` | Rasm kartasi | Rasm kartasi: nomi 3 tilda, litsenziya, asl izoh | Карточка снимка: название на 3 языках, лицензия, исходная подпись | Image card: the name in 3 languages, license, original caption | 4 |
| 6 | `mic_search` | `/lab/microscopy` | Qidiruvga yozish | Qidiruv: masalan, «oksalat» | Поиск: например, «оксалат» | Search: e.g. “oxalate” | 3 |
| 7 | `mic_quiz_setup` | `/lab/microscopy/quiz` | «Boshlash» ni bosish | Mashq: bo‘limni tanlang → «Boshlash» | Тренировка: выберите раздел → «Начать» | Practice: choose a section → “Start” | 3.5 |
| 8 | `mic_quiz_q` | `/lab/microscopy/quiz` | A variantni bosish | Rasmga qarang va 4 variantdan birini tanlang | Посмотрите на снимок и выберите 1 из 4 вариантов | Look at the image and pick 1 of 4 options | 3.5 |
| 9 | `mic_quiz_answer` | `/lab/microscopy/quiz` | Javob | Javob darhol: to‘g‘ri yoki to‘g‘ri javob ko‘rsatiladi | Ответ сразу: «верно» или показан правильный ответ | Instant answer: correct, or the right answer is shown | 4 |
| 10 | `howto` | `/lab/microscopy` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | mualliflar kartochkasi | — | Uchinchi tomon rasmlari: muallif, litsenziya (+ `<mavzu>_<til>_credits.txt`) | Rasmlar: mualliflar va litsenziyalar | Снимки: авторы и лицензии | Images: authors and licenses | 7 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 50.0 s, ru — 50.0 s, en — 50.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
40–45 s.

## Kerakli ekran yozuvlari
Lab tabi; atlas; bo‘limlar; siydik cho‘kmasi; rasm kartasi; qidiruv «oksalat»; mashq sozlamasi; savol;
javob. Mashq savollari tasodifiy — har tilda boshqa rasm chiqishi mumkin (haqiqiy xatti-harakat).

## Ma’lum cheklovlar
- Ba’zi elementlar uchun litsenziyali rasm hali yo‘q (ekranda «… uchun rasm hali yo‘q»).
- O‘quv rasmlari — tashxis uchun emas (ekrandagi eslatma).

## Ilmiy dars rejasi (alohida)
**NEEDS_EXPERT.** Manbalar: atlasdagi har rasmning manba sahifasi (Wikimedia Commons, litsenziyalar —
«Mualliflar va litsenziyalar» sahifasi), `docs/MICROSCOPY_AUDIT_2026-10-09.md`.
1. Siydik cho‘kmasi elementlari; 2. Periferik qon hujayralari; 3. Bezgak: yupqa va qalin surtma.
