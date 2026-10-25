# 05 — Apparatlar va metodikalar

RU: Приборы и методики · EN: Instruments and methods

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar (`05_apparatlar`).
How-to: `HowToSection.instruments`.

## Nega kerak
Laborant o‘z apparatining modelini, uning sinfini (masalan, 5 qismli gematologik analizator) va kalibrlash
yoki QC ga tez o‘tishni bir joyda ko‘radi; laboratoriya yo‘nalishlari bo‘yicha ma’lumotnoma kartalari
platforma, test va usulni ajratib ko‘rsatadi.

## Qanday ishlaydi
Katalog: 4 yo‘nalish (biokimyo, gematologiya, immunokimyo, siydik) → ishlab chiqaruvchi → model kartasi
(sxematik tasvir — aniq model emas; ishlab chiqaruvchi manbasi havolasi; «Mening apparatim sifatida
saqlash», «Kalibrlash», «Sifat nazorati (QC)»). «Laboratoriya yo‘nalishlari (ma’lumotnoma)»: sil, OIV,
bakteriologiya va boshqalar; har karta holati va ogohlantirishlari ochiq yozilgan; 35 kartada apparat
sinfi sxemasi. Dalil: `test/widget/instruments_flow_test.dart`, `test/widget/lab_cards_directions_test.dart`,
`test/widget/lab_card_schematic_test.dart`.

## Qanday foydalaniladi
1. Yo‘nalishni tanlang yoki qidiring. 2. Ishlab chiqaruvchi va model. 3. Model kartasi: saqlash,
kalibrlash, QC. 4. Laboratoriya yo‘nalishlari kartalari. 5. Sxema — sinf tasviri.

## Natijada nima olasiz
Apparat va yo‘nalish bo‘yicha ma’lumotnoma kartalari, sxemalar va kalibrlash/QC ga tez o‘tish.

## Qisqa kirish matni
- UZ: Apparatingizni katalogdan toping: model kartasi, sxema va kalibrlash/QC ga bir bosishda.
- RU: Найдите свой прибор в каталоге: карточка модели, схема и переход к калибровке/QC в одно касание.
- EN: Find your instrument in the catalog: model card, schematic and one tap to calibration/QC.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Apparatlar va metodikalar | Приборы и методики | Instruments and methods | 3 |
| 1 | `lab_tools` | `/lab` | «Apparatlar va metodikalar» ni bosish | Lab → «Apparatlar va metodikalar» | Лаб. → «Приборы и методики» | Lab → “Instruments and methods” | 3 |
| 2 | `ins_top` | `/lab/instruments` | «Gematologiya» ni bosish | Yo‘nalishni tanlang (masalan, gematologiya) yoki qidiring | Выберите направление (например, гематология) или найдите модель | Choose a direction (e.g. hematology) or search | 3.5 |
| 3 | `ins_makers` | `/lab/instruments/c/hematology` | Ishlab chiqaruvchini bosish | Ishlab chiqaruvchini tanlang | Выберите производителя | Choose the manufacturer | 3 |
| 4 | `ins_models` | `/lab/instruments/c/hematology/:maker` | Modelni bosish | Modelni tanlang | Выберите модель | Choose the model | 3 |
| 5 | `ins_model` | `/lab/instruments/m/:id` | Model kartasi | Model kartasi: sxematik tasvir — aniq model emas | Карточка модели: схема, а не точная модель | Model card: a schematic, not the exact model | 4 |
| 6 | `ins_model_actions` | `/lab/instruments/m/:id` | Tugmalarga surish | «Mening apparatim sifatida saqlash», so‘ng kalibrlash yoki QC | «Сохранить как „Мой прибор“», затем калибровка или QC | “Save as ‘My instrument’”, then calibration or QC | 4 |
| 7 | `ins_directions` | `/lab/instruments` | «Bakteriologiya — ma’lumotnoma kartalari» ni bosish | «Laboratoriya yo‘nalishlari (ma’lumotnoma)», masalan, bakteriologiya | «Направления лаборатории (справочник)», например, бактериология | “Laboratory directions (reference)”, e.g. bacteriology | 4 |
| 8 | `ins_dir_cards` | `/lab/instruments/d/bacteriology` | Kartani bosish | Yo‘nalish kartalari: platforma, test va usul alohida | Карточки направления: платформа, тест и метод отдельно | Direction cards: platform, test and method separately | 3.5 |
| 9 | `ins_card` | `/lab/instruments/lc/a3-bac-vitek2-platform` | Karta tepasi | Kartada holati va ogohlantirishlar ochiq yozilgan — o‘quv ma’lumotnomasi | В карточке открыто указаны статус и предупреждения — учебный справочник | The card openly shows its status and notices — a learning reference | 4.5 |
| 10 | `ins_schematic` | `/lab/instruments/lc/a3-bac-vitek2-platform` | Sxemaga surish | Apparat sinfi sxemasi — umumiy tasvir, aniq model emas | Схема класса приборов — общее изображение, не точная модель | Instrument-class schematic — a general drawing, not an exact model | 4 |
| 11 | `howto` | `/lab/instruments` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 47.0 s, ru — 47.0 s, en — 47.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
45–50 s.

## Kerakli ekran yozuvlari
Lab tabi; apparatlar; gematologiya → Mindray → BC-5390; model kartasi (tepasi va tugmalar);
laboratoriya yo‘nalishlari → bakteriologiya → VITEK 2 kartasi (tepasi va sxema).

## Ma’lum cheklovlar
- Rasmlar — LabGuide chizgan sxemalar, aniq model fotosurati emas (kartada yozilgan).
- Yo‘nalish kartalarida «Mutaxassis tekshirgan: hali yo‘q» holati ekranda ochiq ko‘rinadi — video uni
  yashirmaydi (`docs/LAB_CARDS_UNVERIFIED.md`).

## Ilmiy dars rejasi (alohida)
**NEEDS_EXPERT** (yo‘nalish kartalari hali mutaxassis tasdig‘isiz). Manbalar — kartalardagi manbalar
(`docs/LAB_CARDS_SOURCE_LICENSES.md`, `docs/LAB_DIRECTIONS_2026-10-24.md`).
1. Analizator sinflari (fotometrik, gematologik 3/5 qismli, immunokimyoviy, siydik); 2. Platforma va test
farqi; 3. Apparat → kalibrlash → QC zanjiri.
