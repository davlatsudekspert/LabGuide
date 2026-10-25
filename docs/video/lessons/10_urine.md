# 10 — Siydik test-chizig‘i o‘quvchisi va avtomatik siydik tahlili tizimi

RU: Анализатор мочевых тест-полосок и автоматизированная система анализа мочи · EN: Urine test-strip reader and automated urinalysis system

Kalit atamalar — EN: test strip, reagent pad, reading head, LED, photosensor, reflectometry, semi-quantitative, sediment module, digital microscopy, particle classification · RU: тест-полоска, реагентная зона, считывающая головка, светодиод, фотосенсор, рефлектометрия, полуколичественный, модуль осадка, цифровая микроскопия, классификация частиц

**Holat:** EXPERT_REVIEW_PENDING — bu ilmiy video-dars REJASI va storyboard, tayyor video emas.
**Sxemalar:** `urine_strip` — `tool/illustrations/schematic/urine_strip.svg` (6 ta belgi) va `urine_system` —
`tool/illustrations/schematic/urine_system.svg` (7 ta belgi); PNG — `assets/instruments/schematic/<kalit>_1200.png`.
**Ilovada:** siydik modellari `/lab/instruments/c/urinalysis`; siydik tahlili bo‘limi `/lab/urinalysis`
(yig‘ish, test-chiziq, cho‘kma atlasi, natija o‘qish).

## 1. O‘quv maqsadlari

- Test-chiziq o‘quvchisi va siydik tizimi sxemalarida raqamli qismlarni ko‘rsatish.
- Reflektometriya tamoyilini va yarim miqdoriy natija tushunchasini tushuntirish.
- Cho‘kma modulining raqamli mikroskopiya va tasniflash vazifasini aytish.

## 2. Maqsadli auditoriya

Klinik laboratoriya laborantlari va talabalar. Oldindan: siydikning umumiy tahlili bosqichlari.

## 3. Davomiylik

Taxminan 4 daqiqa (storyboard bo‘yicha 3:54).

## 4. Storyboard

| # | Ekranda (SVG / qatlam / belgilar) | Animatsiya g‘oyasi | Diktor matni (uz) | EN / RU atamalar | Bayonotlar | s |
|---|---|---|---|---|---|---|
| 1 | Kirish kartochkasi; ikki sxema xira | Sarlavha va “Sxematik animatsiya — aniq model emas” | Bu darsda siydik test-chizig‘i o‘quvchisi va avtomatik siydik tahlili tizimini ilovadagi sxematik chizmalar asosida ko‘ramiz. | urinalysis / анализ мочи | — | 10 |
| 2 | `urine_strip.svg` to‘liq; `urine_strip`: 1–6-belgi xira | Kamera chiziqdan o‘quvchi kallagiga suriladi | Umumiy tamoyil bo‘yicha, test-chiziq siydikka botiriladi va har maydonchadagi reagent o‘z moddasi bilan rang beradi; apparat chiziqni o‘qish kallagi ostidan o‘tkazadi. | test strip / тест-полоска; reagent pad / реагентная зона | US-PR | 18 |
| 3 | `urine_strip`: 1, 3-belgi | Halqa va nom chipi | Manbaga ko‘ra: 1-belgi — siydik namunasi va test-chiziq, 3-belgi — LED va fotosensorli o‘qish kallagi. | reading head / считывающая головка; photosensor / фотосенсор | US-C1, US-C3 | 16 |
| 4 | `urine_strip`: 2, 4, 5, 6-belgi | Halqa va nom chipi | Umumiy tamoyil bo‘yicha: 2-belgi — chiziq lotogi, 4-belgi — displey, 5-belgi — printer, 6-belgi — ishlatilgan chiziqlar qutisi. | strip tray / лоток; display / дисплей; printer / принтер | US-C2, US-C4, US-C5, US-C6 | 18 |
| 5 | `urine_strip`: 1, 2-belgi | Chiziq siydikka botiriladi, lotokka qo‘yiladi va suriladi | Manbaga ko‘ra, chiziq siydikka qisqa botiriladi. Umumiy tamoyil bo‘yicha, u lotokka qo‘yiladi va o‘qish kallagi ostiga suriladi. | dipping / погружение | US-C1, US-C2 | 16 |
| 6 | `urine_strip`: 3-belgi kesigi | Turli rangli LED nurlari maydonchaga tushadi, qaytgan nur sensorga | Manbaga ko‘ra, o‘qish kallagi maydonchalarni bir necha to‘lqin uzunlikdagi nur bilan yoritadi va qaytgan nurni o‘lchaydi. Umumiy tamoyil bo‘yicha, bu reflektometriya deyiladi. | reflectometry / рефлектометрия; LED / светодиод | US-C3, US-PR | 20 |
| 7 | `urine_strip`: 4-belgi displeyi | Maydonchalar ro‘yxati darajalar bilan (raqamsiz) | Umumiy tamoyil bo‘yicha, rang intensivligi yarim miqdoriy darajaga aylantiriladi va natija har maydoncha bo‘yicha beriladi — masalan, glyukoza, oqsil, qon, nitrit. | semi-quantitative / полуколичественный | US-PR, US-RS | 18 |
| 8 | `urine_system.svg` to‘liq; `urine_system`: 1–7-belgi xira | Rakalar transport yo‘li bo‘ylab chapdan o‘ngga yuradi | Endi avtomatik tizim. Manbaga ko‘ra, namuna rakalari transport yo‘li bo‘ylab ikki modulga boradi: kimyoviy modul va cho‘kma moduli. | transport line / транспортная линия; module / модуль | UA-PR | 18 |
| 9 | `urine_system`: 1, 2, 4, 5-belgi | Halqa va nom chipi | Manbaga ko‘ra: 1-belgi — transport yo‘li, 2-belgi — test-chiziq kimyoviy moduli, 4-belgi — mikroskop va kamerali cho‘kma moduli, 5-belgi — zarracha tasvirlari displeyi. | chemistry module / химический модуль; sediment module / модуль осадка | UA-C1, UA-C2, UA-C4, UA-C5 | 20 |
| 10 | `urine_system`: 3, 6, 7-belgi | Halqa va nom chipi | Umumiy tamoyil bo‘yicha: 3-belgi — namuna ignalari, 6-belgi — reagent va yuvish eritmasi, 7-belgi — chiqindi idishi. | sampling needles / иглы пробоотбора | UA-C3, UA-C6, UA-C7 | 14 |
| 11 | `urine_system`: 4, 5-belgi | Kamera kadri olinadi; zarrachalar tasvirlari galereyaga “tushadi” | Manbaga ko‘ra, cho‘kma moduli siydikni mikroskop orqali raqamli suratga oladi; dastur zarrachalarni, masalan, eritrotsit, leykotsit, silindr va kristallarni tasniflaydi, tasvirlarni ekranda ko‘rib chiqish mumkin. | digital microscopy / цифровая микроскопия; classification / классификация | UA-C4, UA-PR, UA-C5 | 22 |
| 12 | `urine_system`: 5-belgi | Natija jadvali va tasvir galereyasi | Umumiy tamoyil bo‘yicha, natija — chiziq kimyosi va cho‘kma elementlari soni yoki toifasi, ko‘rib chiqish uchun tasvirlar bilan. | sediment elements / элементы осадка | UA-RS | 18 |
| 13 | Ilova: siydik tahlili bo‘limi eslatmasi | Bo‘lim nomlari ramkada | Ilovada siydik yig‘ish qoidalari, test-chiziq, cho‘kma atlasi va natija o‘qish bo‘limlari bor. | — | — | 16 |
| 14 | Savollar ekrani | Savollar birin-ketin | Endi o‘zingizni tekshiring. | — | — | 10 |

## 5. Olti majburiy bosqich

### 5.1 Tashqi ko‘rinish

Umumiy tamoyil bo‘yicha, test-chiziq o‘quvchisi — displey, printer va chiziq lotogi bo‘lgan ixcham stol apparati;
avtomatik tizim — transport yo‘li bilan tutashgan ikki modul (kimyoviy va cho‘kma) [US-C2, US-C4, US-C5, UA-C3].
Manbaga ko‘ra, tizimda raka transport yo‘li va ikkita modul bor [UA-C1, UA-C2, UA-C4].

### 5.2 Asosiy qismlar (raqamli belgilar)

Test-chiziq o‘quvchisi (`urine_strip`):

<!-- auto:parts-list urine_strip US -->
| Belgi | Qism (uz) | RU | EN | Bayonot |
|---|---|---|---|---|
| 1 | Siydik namunasi va test-chiziq | Проба мочи и тест-полоска | Urine sample and test strip | US-C1 |
| 2 | Chiziq lotogi (uzatgich) | Лоток для полосок (транспорт) | Strip tray (transport) | US-C2 |
| 3 | O‘qish kallagi (LED va fotosensor) | Считывающая головка (светодиоды и фотосенсор) | Reading head (LEDs and photosensor) | US-C3 |
| 4 | Displey | Дисплей | Display | US-C4 |
| 5 | Printer | Принтер | Printer | US-C5 |
| 6 | Ishlatilgan chiziqlar qutisi | Контейнер для использованных полосок | Used strip bin | US-C6 |
<!-- /auto:parts-list -->

Avtomatik siydik tizimi (`urine_system`):

<!-- auto:parts-list urine_system UA -->
| Belgi | Qism (uz) | RU | EN | Bayonot |
|---|---|---|---|---|
| 1 | Namuna transport yo‘li | Транспортная линия | Sample transport line | UA-C1 |
| 2 | Kimyoviy modul (test-chiziq) | Химический модуль (тест-полоска) | Chemistry module (test strip) | UA-C2 |
| 3 | Namuna ignalari | Пробоотборные иглы | Sampling needles | UA-C3 |
| 4 | Cho‘kma moduli (mikroskop va kamera) | Модуль осадка (микроскоп и камера) | Sediment module (microscope and camera) | UA-C4 |
| 5 | Displey (zarracha tasvirlari) | Дисплей (изображения частиц) | Display (particle images) | UA-C5 |
| 6 | Reagent va yuvish eritmasi | Реагент и промывочный раствор | Reagent and wash solution | UA-C6 |
| 7 | Chiqindi idishi | Ёмкость для отходов | Waste container | UA-C7 |
<!-- /auto:parts-list -->

### 5.3 Namuna qanday kiritiladi

Manbaga ko‘ra, o‘quvchida chiziq siydikka qisqa botiriladi [US-C1]; tizimda namuna rakalari transport yo‘li bo‘ylab
modullarga boradi [UA-C1, UA-PR]. Umumiy tamoyil bo‘yicha, har modul probirkadan o‘z ignasi bilan namuna oladi
[UA-C3].

### 5.4 Ichkarida nima bo‘ladi

Umumiy tamoyil bo‘yicha, maydonchalardagi reagentlar o‘z moddasi bilan rang beradi [US-PR]. Manbaga ko‘ra, cho‘kma
moduli siydikni mikroskop orqali raqamli suratga oladi [UA-PR].

### 5.5 Signal qanday o‘lchanadi

Manbaga ko‘ra, o‘qish kallagi maydonchalarni bir necha to‘lqin uzunlikdagi nur bilan yoritadi va qaytgan nurni
o‘lchaydi; cho‘kma modulida kamera tasvir oladi va dastur zarrachalarni tasniflaydi [US-C3, UA-C4, UA-PR]. Umumiy
tamoyil bo‘yicha, chiziqni o‘qish usuli reflektometriya deyiladi [US-PR].

### 5.6 Natija qanday olinadi

Umumiy tamoyil bo‘yicha, rang intensivligi yarim miqdoriy darajaga aylantiriladi; hisobotda har maydoncha natijasi va
cho‘kma elementlari soni yoki toifasi bo‘ladi [US-PR, US-RS, UA-RS]. Manbaga ko‘ra, cho‘kma tasvirlari ekranda ko‘rib
chiqiladi [UA-C5].

## 6. Keng tarqalgan xatolar, xavfsizlik va QC

- Siydik yig‘ish qoidalari (preanalitika) — `/lab/urinalysis/collect`; umumiy preanalitika — `/lab/preanalytics`.
- Test-chiziq maydonchalari va ularni o‘qish — `/lab/urinalysis/strip`; natijani o‘qish — `/lab/urinalysis/reader`.
- Avtomat tasniflagan tasvirlarni ko‘rib chiqmasdan yakunlash: manbaga ko‘ra, tasvirlar ekranda ko‘rib chiqish uchun
  beriladi [UA-PR] — cho‘kma atlasi `/lab/urinalysis/sediment`.
- Ichki sifat nazorati — `/lab/qc`; model kartalari — `/lab/instruments/c/urinalysis`.

## 7. O‘z-o‘zini tekshirish savollari

1. O‘qish kallagi nimani o‘lchaydi? Javob: maydonchalardan qaytgan nurni [US-C3].
2. Umumiy tamoyil bo‘yicha, rang intensivligi qanday natijaga aylanadi? Javob: yarim miqdoriy darajaga [US-PR].
3. Avtomatik tizimda qaysi ikki modul bor? Javob: kimyoviy (test-chiziq) va cho‘kma modullari [UA-PR].
4. Cho‘kma moduli qanday ishlaydi? Javob: siydikni mikroskop orqali raqamli suratga oladi, dastur zarrachalarni
   tasniflaydi [UA-PR].

## 8. Epistemik holat

Qoida (to‘liq — [README](README.md#epistemik-qoida)): SOURCED — catalog.json manba id si va joyi;
STANDARD_TEXTBOOK — darslik darajasidagi umumiy tamoyil; NEEDS_EXPERT — aniqlik yoki raqam mutaxassis
tasdig‘ini kutadi. STANDARD_TEXTBOOK va NEEDS_EXPERT bayonotlar diktor matnida faqat “umumiy tamoyil bo‘yicha”
darajasida aytiladi, aniq model xususiyati sifatida emas. Mutaxassis ko‘rigi: EXPERT_REVIEW_PENDING.
Qism manbalari ishlab chiqaruvchi sahifalari; darsda model xususiyati aytilmaydi. Ataylab aytilmaydi: to‘lqin
uzunliklari, unumdorlik, darajalar shkalasi, referens qiymatlar.

### 8.1 Sxema qismlari (avtomatik, `parts_src.py` dan)

Test-chiziq o‘quvchisi:

<!-- auto:epistemic-parts urine_strip US -->
| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| US-C1 | Siydik namunasi va test-chiziq — Chiziq siydikka qisqa botiriladi; maydonchalar reaksiyaga kirishadi. | SOURCED | `ro-u411`; `schematic_parts.json` → `urine_strip` #1 |
| US-C2 | Chiziq lotogi (uzatgich) — Chiziq shu yerga qo‘yiladi va o‘qish kallagi ostiga suriladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `urine_strip` #2 |
| US-C3 | O‘qish kallagi (LED va fotosensor) — Maydonchalarni bir necha to‘lqin uzunlikdagi nur bilan yoritadi va qaytgan nurni o‘lchaydi. | SOURCED | `ro-u411`; `schematic_parts.json` → `urine_strip` #3 |
| US-C4 | Displey — Natijalar va apparat holatini ko‘rsatadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `urine_strip` #4 |
| US-C5 | Printer — Natijalarni chop etadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `urine_strip` #5 |
| US-C6 | Ishlatilgan chiziqlar qutisi — O‘qilgan chiziqlar shu yerga tushadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `urine_strip` #6 |
| US-PR | Test-chiziq siydikka botiriladi; har maydonchadagi reagent o‘z moddasi bilan rang beradi. Apparat chiziqni o‘qish kallagi ostidan o‘tkazadi: turli to‘lqin uzunlikdagi LEDlar maydonchalarni yoritadi, fotosensor qaytgan nurni o‘lchaydi (reflektometriya). Rang intensivligi yarim miqdoriy darajaga aylantiriladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `ro-u411`; `schematic_parts.json` → `urine_strip`.principle |
| US-RS | Har maydoncha bo‘yicha sifatiy yoki yarim miqdoriy natija (masalan, glyukoza, oqsil, qon, leykotsitlar, nitrit, pH, nisbiy zichlik) va bosma hisobot. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `ro-u411`; `schematic_parts.json` → `urine_strip`.result |
<!-- /auto:epistemic-parts -->

Avtomatik siydik tizimi:

<!-- auto:epistemic-parts urine_system UA -->
| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| UA-C1 | Namuna transport yo‘li — Probirkali rakalarni modullar oldidan navbat bilan o‘tkazadi. | SOURCED | `ro-6500`; `schematic_parts.json` → `urine_system` #1 |
| UA-C2 | Kimyoviy modul (test-chiziq) — Chiziq maydonchalarini reflektometriya va tasvir orqali o‘qiydi. | SOURCED | `ro-6500`; `schematic_parts.json` → `urine_system` #2 |
| UA-C3 | Namuna ignalari — Har modul probirkadan o‘z ignasi bilan namuna oladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `urine_system` #3 |
| UA-C4 | Cho‘kma moduli (mikroskop va kamera) — Siydik zarrachalarining raqamli mikroskopik tasvirlarini oladi. | SOURCED | `ro-6500`, `mr-eu5600`; `schematic_parts.json` → `urine_system` #4 |
| UA-C5 | Displey (zarracha tasvirlari) — Tasniflangan zarracha tasvirlari va natijalar ko‘rib chiqiladi. | SOURCED | `mr-eu5600`; `schematic_parts.json` → `urine_system` #5 |
| UA-C6 | Reagent va yuvish eritmasi — Modullarni yuvish va o‘lchash uchun eritmalar. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `urine_system` #6 |
| UA-C7 | Chiqindi idishi — Ishlatilgan suyuqliklar to‘planadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `urine_system` #7 |
| UA-PR | Namuna rakalari transport yo‘li bo‘ylab ikki modulga boradi. Kimyoviy modul test-chiziq maydonchalarini reflektometriya bilan o‘qiydi. Cho‘kma moduli siydikni mikroskop orqali raqamli suratga oladi; dastur zarrachalarni (eritrotsit, leykotsit, silindr, kristall va boshqalar) tasniflaydi, tasvirlarni ekranda ko‘rib chiqish mumkin. | SOURCED | `ro-6500`, `mr-eu5600`; `schematic_parts.json` → `urine_system`.principle |
| UA-RS | Chiziq kimyosi natijalari va cho‘kma elementlari (eritrotsit, leykotsit, silindr, kristall, bakteriya va boshq.) soni yoki toifasi, ko‘rib chiqish uchun tasvirlar bilan. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `ro-6500`, `mr-eu5600`; `schematic_parts.json` → `urine_system`.result |
<!-- /auto:epistemic-parts -->

### 8.2 Dars bayonotlari

Qo‘shimcha bayonot yo‘q — dars 8.1 dagi qismlar, prinsip (PR) va natija (RS) ga tayanadi.
