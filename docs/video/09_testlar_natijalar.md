# 09 — Testlar, og‘zaki savollar va natijalar

RU: Тесты, устные вопросы и результаты · EN: Tests, oral questions and results

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar
(`09_testlar_natijalar`). Bu mavzuning alohida how-to bo‘limi yo‘q (test dvigatellari O‘rganish
tabida); og‘zaki savollar — `08_bilim_baholash` (cheklangan ko‘rinish) videosida.

## Nega kerak
Hamma rol uchun ochiq mashq vositalari: izohli test (javobdan keyin izoh va manba), imtihon rejimi
(vaqt, mavzular, natija va xatolar tahlili), kunlik 5 savol.

## Qanday ishlaydi
«Izohli test»: mavzu yoki aralash 10 savol; javobdan keyin darhol izoh. «Imtihon rejimi»: mavzular,
savollar soni, vaqt; savollar va variantlar tasodifiy; yakunlagach — foiz, to‘g‘ri/xato, mavzular
bo‘yicha natija, xatolar tahlili; natija faqat shu qurilmada. «Kunlik savol»: har kuni 5 ta (toifa ko‘rinsa
— toifa bankidan, aks holda kontent paketidan). Dalil: `test/widget/exam_flow_test.dart`,
`test/widget/quiz_result_actions_test.dart`, `test/widget/daily_flow_test.dart`.

## Qanday foydalaniladi
1. O‘rganish → «Izohli test» → mavzu → javob → izoh.
2. O‘rganish → «Imtihon rejimi» → sozlamalar → «Imtihonni boshlash» → «Yakunlash».
3. Natija va xatolar tahlili.
4. «Kunlik savol».

## Natijada nima olasiz
Har javobga izoh va manba, imtihon natijasi (foiz, mavzular, xatolar) va har kungi qisqa mashq.

## Qisqa kirish matni
- UZ: Izohli test, imtihon rejimi va kunlik savol: javob — izoh — natija.
- RU: Тест с объяснениями, режим экзамена и вопросы дня: ответ — пояснение — результат.
- EN: Explained quiz, exam mode and daily questions: answer — explanation — result.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Testlar va natijalar | Тесты и результаты | Tests and results | 3 |
| 1 | `learn_rows` | `/learn` | «Izohli test» ni bosish | O‘rganish → «Izohli test» | Обучение → «Тест с объяснениями» | Learn → “Explained quiz” | 3 |
| 2 | `quiz_topics` | `/learn/quiz` | «Aralash: 10 ta» ni bosish | Mavzuni tanlang yoki «Aralash: 10 ta tasodifiy savol» | Выберите тему или «Вперемешку: 10 случайных вопросов» | Choose a topic or “Mixed: 10 random questions” | 3.5 |
| 3 | `quiz_q` | `/learn/quiz` | Variantni bosish | Javobni tanlang | Выберите ответ | Pick an answer | 3 |
| 4 | `quiz_feedback` | `/learn/quiz` | Izoh | Darhol izoh: nega to‘g‘ri yoki noto‘g‘ri — manbasi bilan | Сразу пояснение: почему верно или неверно — с источником | Instant explanation: why it is right or wrong — with a source | 4.5 |
| 5 | `exam_setup` | `/learn/exam` | Imtihon sozlamalari | Imtihon rejimi: mavzular, savollar soni, vaqt | Режим экзамена: темы, число вопросов, время | Exam mode: topics, number of questions, time | 3.5 |
| 6 | `exam_ready` | `/learn/exam` | «Imtihonni boshlash» ni bosish | Savollar va variantlar tasodifiy tartibda → «Imtihonni boshlash» | Вопросы и варианты — в случайном порядке → «Начать экзамен» | Questions and options are shuffled → “Start exam” | 4 |
| 7 | `exam_q` | `/learn/exam/run` | Savol | Taymer, «Belgilash», «Oldingi» / «Keyingi» | Таймер, «Отметить», «Назад» / «Далее» | Timer, “Bookmark”, “Previous” / “Next” | 3.5 |
| 8 | `exam_finish` | `/learn/exam/run` | «Yakunlash» ni tasdiqlash | «Yakunlash» — tasdiqlang | «Завершить» — подтвердите | “Finish” — confirm | 3 |
| 9 | `exam_result` | `/learn/exam/result/:id` | Natija | Natija: foiz, to‘g‘ri va xato, vaqt | Результат: процент, верные и ошибки, время | Result: percentage, right and wrong, time | 4 |
| 10 | `exam_mistakes` | `/learn/exam/result/:id` | Xatolar tahliliga surish | Mavzular bo‘yicha natija va xatolar tahlili | Результат по темам и разбор ошибок | Results by topic and a review of mistakes | 4 |
| 11 | `daily` | `/learn/daily` | Kunlik savol | Kunlik savol: har kuni 5 ta savol | Вопросы дня: 5 вопросов каждый день | Daily questions: 5 questions every day | 4 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 46.0 s, ru — 46.0 s, en — 46.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
45–50 s.

## Kerakli ekran yozuvlari
O‘rganish; izohli test mavzulari, savol, izoh; imtihon sozlamasi (3 savol), savol, yakunlash oynasi,
natija, xatolar; kunlik savol. Imtihonda 3 savoldan 1 tasi ataylab xato javob berilgan (xatolar tahlili
ko‘rinishi uchun).

## Ma’lum cheklovlar
- Natija — ichki mashq uchun, rasmiy baho emas (ekrandagi eslatma).
- Guruh testlari (ustoz → talaba) server va hisob talab qiladi — bu videoda yo‘q (inventar).

## Ilmiy dars rejasi
Yo‘q (bu — vosita qo‘llanmasi).
