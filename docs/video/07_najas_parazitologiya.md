# 07 — Najas tahlili va parazitologiya

RU: Копрология и паразитология · EN: Stool analysis and parasitology

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar
(`07_najas_parazitologiya`). How-to: `HowToSection.coprology`.

## Nega kerak
Koprogramma va ichak parazitlarini aniqlash bosqichlari (namuna yig‘ishdan mikroskopiyagacha) bitta
bo‘limda, har band manbasi bilan; tuxum va sistalar kaliti sxematik rasmlarda.

## Qanday ishlaydi
Bo‘lim sahifasi: manbalar paneli, «Namuna yig‘ish», «Makroskopik tekshiruv», «Koprogramma
mikroskopiyasi» (har element alohida karta), «Yashirin qon» (FIT va gvayak testi), «Ichak parazitlari»
(boyitish usullari, tuxum va sistalar kaliti — sxema); amaliy protokollar (taqdimot) va tahlil kartalari.
**Bo‘lim mashqi yo‘q** (inventar). Dalil: `test/widget/coprology_test.dart`, `docs/COPROLOGY_SOURCES.md`.

## Qanday foydalaniladi
1. «Namuna yig‘ish». 2. «Makroskopik tekshiruv». 3. «Koprogramma mikroskopiyasi». 4. «Yashirin qon».
5. «Ichak parazitlari». 6. Amaliy protokollar va tahlil kartalari.

## Natijada nima olasiz
Namuna olishdan natijagacha koprologiya ma’lumotnomasi — manbalari bilan; bu tashxis emas.

## Qisqa kirish matni
- UZ: Najas tahlili: namuna yig‘ishdan parazitlar kalitigacha — manbalari bilan.
- RU: Копрология: от сбора пробы до ключа паразитов — с источниками.
- EN: Stool analysis: from specimen collection to the parasite key — with sources.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Najas tahlili va parazitologiya | Копрология и паразитология | Stool analysis and parasitology | 3 |
| 1 | `lab_sections` | `/lab` | «Najas tahlili va parazitlar» kartasini bosish | Lab → «Najas tahlili va parazitlar» | Лаб. → «Копрология и паразиты» | Lab → “Stool analysis and parasites” | 3.5 |
| 2 | `copro_top` | `/lab/coprology` | Bo‘lim tepasi | Manbalar tepada; bu o‘quv ma’lumotnomasi, tashxis emas | Источники — вверху; это учебный справочник, не диагноз | Sources at the top; a learning reference, not a diagnosis | 4 |
| 3 | `copro_rows` | `/lab/coprology` | «Namuna yig‘ish» ni bosish | Namuna yig‘ish, makroskopiya, mikroskopiya, yashirin qon, parazitlar | Сбор пробы, макроскопия, микроскопия, скрытая кровь, паразиты | Collection, macroscopy, microscopy, occult blood, parasites | 4 |
| 4 | `copro_collect` | `/lab/coprology/collect` | Sahifa | «Namuna yig‘ish»: idish va yetkazish — manbali bandlar | «Сбор пробы»: контейнер и доставка — пункты с источниками | “Specimen collection”: container and delivery — referenced points | 4 |
| 5 | `copro_micro` | `/lab/coprology/micro` | Sahifa | «Koprogramma mikroskopiyasi»: nimani ko‘rasiz | «Микроскопия копрограммы»: что видно | “Coprogram microscopy”: what you see | 3.5 |
| 6 | `copro_micro_more` | `/lab/coprology/micro` | Pastga surish | Har element — alohida karta; amaliy protokol (taqdimot) | Каждый элемент — отдельная карточка; практический протокол (презентация) | Each element has its own card; a practical protocol (slides) | 4 |
| 7 | `copro_parasites` | `/lab/coprology/parasites` | Sahifa | «Ichak parazitlari»: boyitish usullari | «Кишечные паразиты»: методы обогащения | “Intestinal parasites”: concentration methods | 3.5 |
| 8 | `copro_parasites_key` | `/lab/coprology/parasites` | Kalitga surish | Tuxum va sistalar kaliti — sxematik rasmlar | Ключ яиц и цист — схематические рисунки | Key to eggs and cysts — schematic drawings | 4 |
| 9 | `howto` | `/lab/coprology` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 41.0 s, ru — 41.0 s, en — 41.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
35–40 s.

## Kerakli ekran yozuvlari
Lab tabi; bo‘lim tepasi; qatorlar; namuna yig‘ish; koprogramma mikroskopiyasi (tepasi va elementlar);
ichak parazitlari (boyitish usullari va tuxum/sista kaliti).

## Ma’lum cheklovlar
- Tuxum va sistalar — sxematik rasmlar (mikrofoto emas).
- Bo‘lim mashqi yo‘q; videoda mashq ko‘rsatilmaydi.
- Mikroskopiya atlasidagi «Qon parazitlari (bezgak)» — boshqa mavzu (qon surtmasi).

## Ilmiy dars rejasi (alohida)
**NEEDS_EXPERT.** Manbalar — bo‘limda keltirilganlar: Kurbonova Z.Ch., 2023 («Klinik laboratoriya
tashxisi: darslik»); WHO, 2003 («Manual of basic techniques for a health laboratory», 2nd ed.); Malik Z,
2025 («Overview of Malabsorption»); CDC DPDx, 2016 («Stool specimens — specimen processing»).
1. Namuna yig‘ish va saqlash; 2. Makroskopiya; 3. Koprogramma mikroskopiyasi; 4. Yashirin qon testlari;
5. Boyitish usullari va asosiy tuxum/sistalar.
