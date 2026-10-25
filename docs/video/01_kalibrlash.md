# 01 — Kalibrlash: yo‘riqnoma va jurnal

RU: Калибровка: руководство и журнал · EN: Calibration: guide and log

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — ilovaning haqiqiy ekranlari
(`tool/video/howto_walk_test.dart`, mavzu `01_kalibrlash`). Bo‘lim inventari:
`docs/VIDEO_FEATURE_INVENTORY.md` (1-jadval). How-to: `HowToSection.calibration`.

## Nega kerak
Kalibrlash yo‘riqnomasi apparat, analit, reagent REF va IFU versiyasiga aniq mos bo‘lishi kerak; boshqa
modelning yoki boshqa reagentning yo‘riqnomasi xato kalibrlashga olib keladi. Bo‘lim mosligini
tekshiradi va kalibrlash yozuvini qurilmada saqlaydi.

## Qanday ishlaydi
Uch qadam (apparat → analit → reagent) to‘ldirilgach, «Yo‘riqnomani ko‘rsatish» moslikni tekshiradi:
rasmiy manbada shu apparat uchun sozlamasi bor reagentlar (REF) ko‘rsatiladi, kiritilgan REF ro‘yxatda
bormi — aytiladi; so‘ng umumiy ish ketma-ketligi va hujjatlarni qayerdan topish mumkinligi. Yozuv (lot,
birlik, qiymat, natija, QC holati, tasdiqlovchi) faqat shu qurilmada saqlanadi; «qabul qilindi»
natijasi QC o‘tmasa yoki tasdiqlovchi bo‘lmasa saqlanmaydi (`test/widget/calibration_safety_test.dart`).

## Qanday foydalaniladi
1. «1. Apparat»: katalogdan modelni tanlang yoki ro‘yxatda yo‘q apparatni qo‘shing.
2. «2. Analit»: tahlil nomini yozing va ro‘yxatdan tanlang.
3. «3. Reagent»: ishlab chiqaruvchi, REF raqami va IFU versiyasi.
4. «Yo‘riqnomani ko‘rsatish».
5. «Kalibrlash yozuvini yaratish» → «Yozuvni saqlash».
6. «Kalibrlash jurnali»da yozuv va tarix.

## Natijada nima olasiz
Apparat, analit va reagentga mos kalibrlash yo‘riqnomasi hamda qurilmadagi kalibrlash jurnali.

## Qisqa kirish matni (kartochka)
- UZ: Kalibrlashdan oldin yo‘riqnoma apparatingiz va reagentingizga mosligini tekshiring, natijani jurnalga yozing.
- RU: Перед калибровкой проверьте, что руководство подходит к вашему прибору и реагенту, и запишите результат в журнал.
- EN: Before calibrating, check that the guidance matches your instrument and reagent, then log the result.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Kalibrlash: yo‘riqnoma va jurnal | Калибровка: руководство и журнал | Calibration: guide and log | 3 |
| 1 | `lab_tools` | `/lab` | «Kalibrlash» qatorini bosish | Lab → «Ish vositalari» → «Kalibrlash» | Лаб. → «Рабочие инструменты» → «Калибровка» | Lab → “Work tools” → “Calibration” | 3.5 |
| 2 | `cal_top` | `/lab/calibration` | «Katalogdan tanlash» ni bosish | 1-qadam — apparat: «Katalogdan tanlash» | Шаг 1 — прибор: «Выбрать из каталога» | Step 1 — instrument: “Choose from catalog” | 3.5 |
| 3 | `cal_catalog` | `/lab/calibration (katalog oynasi)` | Model nomini yozish, qatorni bosish | Model nomini yozing va ro‘yxatdan tanlang | Введите модель и выберите её в списке | Type the model and pick it from the list | 3.5 |
| 4 | `cal_analyte` | `/lab/calibration` | Analitni qidirish va tanlash | 2-qadam — analit: masalan, glyukoza | Шаг 2 — аналит: например, глюкоза | Step 2 — analyte: e.g. glucose | 3.5 |
| 5 | `cal_reagent` | `/lab/calibration` | REF va IFU kiritish, «Yo‘riqnomani ko‘rsatish» | 3-qadam — reagent REF va IFU versiyasi → «Yo‘riqnomani ko‘rsatish» | Шаг 3 — REF реагента и версия IFU → «Показать руководство» | Step 3 — reagent REF and IFU revision → “Show guide” | 4.5 |
| 6 | `cal_guide` | `/lab/calibration` | Natija; «Kalibrlash yozuvini yaratish» | Mos yo‘riqnoma: ish ketma-ketligi va hujjatlar manbasi | Подходящее руководство: порядок работы и где найти документы | Matching guidance: the workflow and where to find the documents | 4.5 |
| 7 | `cal_record` | `/lab/calibration` | Lot, birlik, qiymat → «Yozuvni saqlash» | Yozuv: kalibrator loti, birlik va qiymat → «Yozuvni saqlash» | Запись: лот калибратора, единицы и значение → «Сохранить запись» | Record: calibrator lot, unit and value → “Save record” | 4.5 |
| 8 | `cal_saved` | `/lab/calibration` | Saqlandi xabari | Kalibrlash yozuvi saqlandi | Запись калибровки сохранена | Calibration record saved | 3 |
| 9 | `cal_log` | `/lab/calibration/log` | Jurnal ekrani | «Kalibrlash jurnali»: yozuv va tarix — faqat shu qurilmada | «Журнал калибровок»: запись и история — только на этом устройстве | “Calibration log”: the record and its history — on this device only | 4.5 |
| 10 | `howto` | `/lab/calibration` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 45.5 s, ru — 45.5 s, en — 45.5 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
45–50 s (bitta qisqa video). Haqiqiy davomiylik — `docs/video/OUTPUTS.md`.

## Kerakli ekran yozuvlari
Hammasi widget-test render bilan olingan (390×844 @2x, yorug‘, Klassik): Lab tabi, kalibrlash sahifasi,
katalog oynasi (qidiruv «Humalyzer 4000»), analit qidiruvi, reagent maydonlari (REF 10121, IFU 2024-01 —
**namuna qiymatlar**, haqiqiy laboratoriya ma’lumoti emas), yo‘riqnoma natijasi, yozuv shakli, jurnal.
Haqiqiy qurilmada ekran yozuvi (diktor bilan) kelajakda kerak bo‘lsa — o‘sha ketma-ketlik.

## Ma’lum cheklovlar
- Ilova kalibrlashni bajarmaydi; u faqat yo‘riqnoma mosligini va qurilmadagi yozuvni ko‘rsatadi.
- Videodagi lot/REF/IFU va qiymat — namuna; yozuv «o‘quv» belgisi bilan saqlangan.
- Jurnal faqat shu qurilmada (serverga yuborilmaydi).

## Ilmiy dars rejasi (alohida, uzunroq dars — bu video emas)
**NEEDS_EXPERT** — mazmunni laboratoriya mutaxassisi tasdiqlashi kerak; yangi ilmiy da’vo qo‘shilmaydi.
1. Kalibrlash nima va nega kerak (kalibrator, tayinlangan qiymat, metrologik izchillik) — manba: apparat va
   reagent IFU (ilovada «Hujjatlarni qayerdan topish mumkin» bo‘limi).
2. Kalibrlashdan keyingi QC — `02_sifat_nazorati` darsiga bog‘lanadi (Westgard, Clin Chem 1981).
3. Qachon qayta kalibrlash kerak (lot almashishi, QC rad etilishi, servis) — faqat IFU va laboratoriya SOP
   bo‘yicha; ilovadagi umumiy sxema (`DiagramTopic.calibrationOverview`) dan tashqari da’vo yo‘q.
