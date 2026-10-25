# 08 — Bilim va malakani baholash

RU: Проверка знаний и компетенций · EN: Knowledge & Skills Assessment

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar
(`08_bilim_baholash`). How-to: `HowToSection.assessment`.

## Kim ko‘radi (ko‘rinish qoidasi)
`toifaVisible` (`lib/features/toifa/toifa_screens.dart`, `toifaAvailable`): rol **shifokor yoki talaba
emas** va Profil → «Bilim va malakani baholash» sozlamasi: «O‘zbekiston» — doim; «Avtomatik» —
interfeys tili o‘zbekcha yoki qurilma mintaqasi UZ bo‘lsa; «Yashirish» — yopiq. Boshqalar to‘g‘ridan-
to‘g‘ri manzil bilan ham kira olmaydi (router redirect `/learn`). Shuning uchun ru/en videolar Profil
sozlamasini «O‘zbekiston» ga o‘tkazish kadri bilan boshlanadi (haqiqiy sozlama).

## Nega kerak
Rasmiy attestatsiya savollari ro‘yxati (KDL) bo‘yicha o‘z bilimini tekshirish: test, mavzu bo‘yicha
mashq, og‘zaki bilet, xatolar ustida ishlash va rivojlanishni kuzatish.

## Qanday ishlaydi
Toifa tanlanadi (3–2, 1, oliy) — og‘zaki bilet shu toifa ro‘yxatidan. «Bilim testi»: rasmiy ro‘yxatdan
tasodifiy savollar (imtihon yoki mashq rejimi). «Mavzu bo‘yicha mashq»: javobdan keyin rasmiy kalit va
manba. «Og‘zaki bilet»: 5 savol, LabGuide tayyorlagan javob rejasi, o‘zini baholash. «Rivojlanish» —
taxminiy tayyorlik (ekranda: «LabGuide hisobi — rasmiy baho emas»). ru/en interfeysda savollar
yordamchi tarjima bilan, rasmiy matn — o‘zbekcha. Dalil: `test/widget/toifa_test.dart`,
`test/widget/toifa_daily_flow_test.dart`, `test/guards/toifa_real_assets_guard_test.dart`.

## Qanday foydalaniladi
1. Toifa va kunlik maqsad. 2. «Bilim testi». 3. «Mavzu bo‘yicha mashq». 4. «Og‘zaki bilet». 5. «Xatolar
ustida ishlash» va «Rivojlanish». 6. Ko‘rinish: o‘zbek tilida yoki Profil → … → «O‘zbekiston».

## Natijada nima olasiz
Rasmiy ro‘yxat savollari bo‘yicha mashq, natijalaringiz va xatolar tahlili — bilimingizni o‘zingiz
tekshirish uchun. **Video ham, how-to ham imtihon natijasi haqida hech qanday da’vo qilmaydi**
(`test/unit/howto_registry_test.dart` qorovuli).

## Qisqa kirish matni
- UZ: Rasmiy ro‘yxat savollari bo‘yicha test, mashq va og‘zaki bilet — bilimingizni o‘zingiz tekshiring.
- RU: Тест, практика и устный билет по вопросам официального списка — проверьте свои знания сами.
- EN: Tests, practice and oral tickets from the official question list — check your own knowledge.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Bilim va malakani baholash | Проверка знаний и компетенций | Knowledge & Skills Assessment | 3 |
| 1 | `as_profile` (faqat ru/en) | `/profile` | «O‘zbekiston» ni bosish | — | Раздел для Узбекистана: Профиль → «Проверка знаний и компетенций» → «Узбекистан» | For Uzbekistan: Profile → “Knowledge & Skills Assessment” → “Uzbekistan” | 5 |
| 2 | `as_learn` | `/learn` | Bo‘lim kartasi | O‘rganish → «Bilim va malakani baholash» | Обучение → «Проверка знаний и компетенций» | Learn → “Knowledge & Skills Assessment” | 3.5 |
| 3 | `as_hub` | `/learn/toifa` | Bo‘lim tepasi | Kunlik maqsad: savollar yoki bitta bilet; eslatma | Цель на день: вопросы или один билет; напоминание | Daily goal: questions or one ticket; reminder | 3.5 |
| 4 | `as_category` | `/learn/toifa` | «1-toifa» ni bosish | Toifangizni tanlang — og‘zaki bilet shu ro‘yxatdan | Выберите категорию — устный билет из её списка | Choose your category — oral tickets come from its list | 3.5 |
| 5 | `as_rows` | `/learn/toifa` | «Bilim testi» ni bosish | Bilim testi, mavzu bo‘yicha mashq, og‘zaki bilet, xatolar, rivojlanish | Тест знаний, практика по темам, устный билет, ошибки, прогресс | Knowledge test, topic practice, oral ticket, mistakes, progress | 4 |
| 6 | `as_test_setup` | `/learn/toifa/test` | Rejim va format | Bilim testi: imtihon yoki mashq rejimi | Тест знаний: режим экзамена или практики | Knowledge test: exam or practice mode | 3.5 |
| 7 | `as_test_q` | `/learn/toifa/test/run` | Savol | Rasmiy ro‘yxatdan tasodifiy savollar; savollar xaritasi | Случайные вопросы официального списка; официальный текст — на узбекском | Random questions from the official list; the official text is Uzbek | 4 |
| 8 | `as_practice` | `/learn/toifa/practice` | «Gemostaz» ni bosish | Mavzu bo‘yicha mashq: mavzuni tanlang | Практика по темам: выберите тему | Topic practice: choose a topic | 3.5 |
| 9 | `as_practice_q` | `/learn/toifa/practice/:scope` | B variantni bosish | Javobni tanlang | Выберите ответ | Pick an answer | 3 |
| 10 | `as_practice_key` | `/learn/toifa/practice/:scope` | Kalit | Darhol: rasmiy kalit va manba | Сразу: официальный ключ и источник | At once: the official key and its source | 4 |
| 11 | `as_oral` | `/learn/toifa/oral` | «Bilet olish» ni bosish | Og‘zaki bilet: toifangizdan 5 ta savol → «Bilet olish» | Устный билет: 5 вопросов вашей категории → «Взять билет» | Oral ticket: 5 questions from your category → “Draw a ticket” | 4 |
| 12 | `as_ticket` | `/learn/toifa/oral` | «Javob rejasini ko‘rish» ni bosish | Javobni o‘ylab ko‘ring, so‘ng «Javob rejasini ko‘rish» | Обдумайте ответ, затем «Посмотреть план ответа» | Think your answer through, then “View answer plan” | 4 |
| 13 | `as_plan` | `/learn/toifa/oral` | Javob rejasi | Javob rejasi (LabGuide tayyorlagan) — o‘zingizni baholang | План ответа (подготовлен LabGuide) — оцените себя | Answer plan (prepared by LabGuide) — rate yourself | 4 |
| 14 | `as_progress` | `/learn/toifa/progress` | Rivojlanish | Rivojlanish: taxminiy tayyorlik — rasmiy baho emas | Прогресс: примерная готовность — не официальная оценка | Progress: approximate readiness — not an official grade | 4 |
| 15 | `howto` | `/learn/toifa` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 59.0 s, ru — 64.0 s, en — 64.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
55–65 s (ru/en — Profil kadri bilan 5 s uzunroq).

## Kerakli ekran yozuvlari
(ru/en) Profil sozlamasi; O‘rganish kartasi; bo‘lim; toifa tanlash; qatorlar; bilim testi sozlamasi va
savol; mavzu bo‘yicha mashq (Gemostaz), javob va kalit; og‘zaki bilet, javob rejasi; rivojlanish.

## Ma’lum cheklovlar
- Bo‘lim shifokor va talaba roliga ko‘rinmaydi.
- Javob rejalari — LabGuide tayyorlagan o‘quv yordami (ekranda belgilangan), rasmiy javob emas.
- «Taxminiy tayyorlik» — rasmiy baho emas.

## Ilmiy dars rejasi (alohida)
Bu bo‘lim uchun alohida ilmiy dars rejalashtirilmaydi: mazmun — rasmiy savollar ro‘yxati (manba:
«Rasmiy attestatsiya savollari ro‘yxati (KDL, 119)», `docs/TOIFA_TRANSLATION_2026-10-10.md`). Bahsli
kalitli savollar bo‘yicha **NEEDS_EXPERT** (ilovada izoh bilan belgilangan).
