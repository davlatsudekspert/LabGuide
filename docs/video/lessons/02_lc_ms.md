# 02 — Suyuqlik xromatografi–mass-spektrometr (LC-MS; LC-MS/MS haqida eslatma)

RU: Жидкостный хромато-масс-спектрометр (ЖХ-МС; о ЖХ-МС/МС) · EN: Liquid chromatograph–mass spectrometer (LC-MS; note on LC-MS/MS)

Kalit atamalar — EN: mobile phase, high-pressure pump, autosampler, column, electrospray ionisation (ESI), quadrupole, m/z, detector, calibrator, tandem MS · RU: подвижная фаза, насос высокого давления, автосамплер, колонка, электрораспылительная ионизация (ЭРИ), квадруполь, m/z, детектор, калибратор, тандемная МС

**Holat:** EXPERT_REVIEW_PENDING — bu ilmiy video-dars REJASI va storyboard, tayyor video emas.
**Sxema:** `mass_spec_lc` — `tool/illustrations/schematic/mass_spec_lc.svg`
(`assets/instruments/schematic/mass_spec_lc_1200.png`), 9 ta raqamli belgi.
**Ilovadagi karta:** `/lab/instruments/lc/a3-tox-lc-ms`.
**Muhim:** egasi topshirig‘ida “LC-MS/MS” deyilgan, lekin ilovadagi karta va uning manbasi faqat umumiy
LC-MS ni yoritadi; tandem (MS/MS) bosqichi manbada yo‘q va sxemada bitta mass-analizator chizilgan
([README → Topilmalar](README.md#topilmalar)). Shuning uchun dars LC-MS asoslari bilan cheklanadi.

## 1. O‘quv maqsadlari

- LC-MS ning suyuqlik xromatografi va mass-spektrometr bloklarini hamda 9 ta raqamli qismini ko‘rsatish.
- Namuna tayyorlash bosqichlarini (manbadagi ro‘yxat) sanab berish.
- Elektropurkash (ESI) ion manbaining vazifasini tushuntirish.
- Natija — xromatogramma, mass-spektr va kalibratorlar bo‘yicha miqdor ekanini aytish; MS/MS bu darsda yo‘qligini bilish.

## 2. Maqsadli auditoriya

Klinik kimyo va toksikologiya yo‘nalishidagi talabalar va laborantlar. Oldindan: 01-dars (GC-MS) yoki
xromatografiya asoslari.

## 3. Davomiylik

Taxminan 4 daqiqa (storyboard bo‘yicha 3:52).

## 4. Storyboard

| # | Ekranda (SVG / qatlam / belgilar) | Animatsiya g‘oyasi | Diktor matni (uz) | EN / RU atamalar | Bayonotlar | s |
|---|---|---|---|---|---|---|
| 1 | Kirish kartochkasi; fon — `mass_spec_lc.svg` xira | Sarlavha va “Sxematik animatsiya — aniq model emas” yorlig‘i | Bu darsda suyuqlik xromatografi–mass-spektrometr, qisqacha LC-MS, ilovadagi sxematik chizma asosida ko‘riladi. Chizma aniq model emas. | LC-MS / ЖХ-МС | — | 10 |
| 2 | `mass_spec_lc.svg` to‘liq, 1–9-belgilar xira | Kamera chapdagi LC ustunidan o‘ngdagi MS blokiga suriladi | Manbaga ko‘ra, suyuqlik xromatografi mass-spektrometr bilan ulangan va ion manbai sifatida elektropurkash ionlanishi qo‘llanishi mumkin. Chapda LC moduli, o‘ngda mass-spektrometr. | liquid chromatograph / жидкостный хроматограф | L1 | 18 |
| 3 | 1–4-belgilar navbat bilan | Har belgi atrofida halqa; pastda nom chipi | Umumiy tamoyil bo‘yicha: 1-belgi — harakatlanuvchi faza idishlari, 2-belgi — yuqori bosimli nasos, 3-belgi — avtonamunaoluvchi, 4-belgi — termostatdagi kolonka. | mobile phase / подвижная фаза; pump / насос; column / колонка | C1, C2, C3, C4 | 20 |
| 4 | 5–9-belgilar navbat bilan | MS kesigi kattalashadi | Manbaga ko‘ra: 5-belgi — elektropurkash ion manbai, 6-belgi — kvadrupol mass-analizator, 7-belgi — detektor. Umumiy tamoyil bo‘yicha: 8-belgi — vakuum nasoslari, 9-belgi — ma’lumotlar tizimi. | ESI / ЭРИ; quadrupole / квадруполь; detector / детектор; vacuum / вакуум | C5, C6, C7, C8, C9 | 22 |
| 5 | Plazma, zardob, siydik probirkalari piktogrammasi; 3-belgi | Probirka → cho‘ktirish → sentrifuga → flakon ketma-ketligi (ikonka) | Manbaga ko‘ra, namuna tayyorlash odatda oqsilni cho‘ktirish va sentrifugalash yoki filtrlash, qattiq fazali yoki suyuqlik-suyuqlik ekstraksiyasini o‘z ichiga oladi; materiallar — plazma, zardob, siydik, so‘lak va boshqalar. | protein precipitation / осаждение белка; solid-phase extraction / твердофазная экстракция | L3 | 20 |
| 6 | 1–3-belgilar | Erituvchi chiziqlari bo‘ylab oqim; flakondan namuna oqimga qo‘shiladi | Umumiy tamoyil bo‘yicha, nasos suyuq harakatlanuvchi fazani yuqori bosimda kolonka orqali haydaydi, avtonamunaoluvchi esa namunani shu oqimga kiritadi. | injection / ввод пробы; flow / поток | C1, C2, C3, PR | 18 |
| 7 | 4-belgi | Bitta aralash zona kolonka bo‘ylab yurib uch zonaga ajraladi | Umumiy tamoyil bo‘yicha, moddalar kolonka fazasi bilan o‘zaro ta’siriga ko‘ra ajralib, kolonkadan turli vaqtda chiqadi. | separation / разделение; retention time / время удерживания | C4, PR | 16 |
| 8 | 5-belgi (konus va purkagich) | Oqim uchidan zaryadlangan tomchilar purkaladi, tomchilar kichrayib ionlarga aylanadi | Manbaga ko‘ra, elektropurkash manbai kolonkadan chiqqan suyuqlikni zaryadlangan tomchilarga purkab, ionlar hosil qiladi. | charged droplets / заряженные капли; gas-phase ions / ионы в газовой фазе | C5 | 18 |
| 9 | 6–7-belgilar | Turli rangli ionlar sterjenlar orasida saralanadi; tanlangani detektorga yetib chaqnaydi | Manbaga ko‘ra, ionlar massa/zaryad nisbati bo‘yicha ajratiladi va detektor ularni o‘lchaydi; detektor kelgan ionlarni kuchaytirilgan elektr signaliga aylantiradi. | mass-to-charge ratio / отношение массы к заряду | L2, C6, C7 | 18 |
| 10 | 9-belgi monitori | Xromatogramma cho‘qqilari, so‘ng bitta cho‘qqining spektri; yonida “kalibratorlar” belgisi (raqamsiz) | Umumiy tamoyil bo‘yicha, natija — xromatogramma va mass-spektrlar; maqsadli moddalar aniqlanadi va kalibratorlar bo‘yicha konsentratsiyasi hisoblanadi. Manbada qo‘llanish — biomarkerlar, dori vositalari metabolik profili va toksikologik tahlil. | calibrator / калибратор; quantification / количественное определение | RS, C9, L4 | 22 |
| 11 | Butun sxema; 6-belgi atrofida “MS/MS — manbada yo‘q” yorlig‘i | Ikkinchi analizator CHIZILMAYDI; faqat yozuv | Diqqat: manbaga ko‘ra, ishlatilgan manba umumiy mass-spektrometriyani yoritadi, tandem bosqichi va LC-MS/MS ga xos tafsilotlar unda yo‘q. Shuning uchun bu dars faqat LC-MS asoslarini beradi. | tandem MS (MS/MS) / тандемная МС | L5 | 20 |
| 12 | Butun sxema; piktogrammalar: qizigan sirt, ko‘zoynak, qo‘lqop | Karta bo‘limlari nomi chiqadi | Manbaga ko‘ra, qurilmaning ba’zi qismlari qizib ketadi, namunalar xavfli bo‘lishi mumkin; himoya vositalari tavsiya etiladi. Nazorat qo‘llanmasa, spektrda namunaga tegishli bo‘lmagan cho‘qqilar paydo bo‘lishi mumkin. | personal protective equipment / СИЗ; quality control / контроль качества | L7, L6 | 20 |
| 13 | Savollar ekrani | Savollar birin-ketin | Batafsil ma’lumot ilovadagi LC-MS kartasida. Endi o‘zingizni tekshiring. | — | — | 10 |

## 5. Olti majburiy bosqich

### 5.1 Tashqi ko‘rinish

Manbaga ko‘ra, suyuqlik xromatografi mass-spektrometr bilan ulangan; ion manbai sifatida elektropurkash qo‘llanishi
mumkin [L1]. Umumiy tamoyil bo‘yicha, sxemada chapda ustma-ust modullar (erituvchilar, nasos, avtonamunaoluvchi,
kolonka termostati), o‘ngda vakuum nasoslari bilan MS korpusi va monitor ko‘rinadi [C1, C2, C3, C4, C8, C9].

### 5.2 Asosiy qismlar (raqamli belgilar)

<!-- auto:parts-list mass_spec_lc -->
| Belgi | Qism (uz) | RU | EN | Bayonot |
|---|---|---|---|---|
| 1 | Harakatlanuvchi faza idishlari | Ёмкости подвижной фазы | Mobile phase bottles | C1 |
| 2 | Yuqori bosimli nasos | Насос высокого давления | High-pressure pump | C2 |
| 3 | Avtonamunaoluvchi | Автосэмплер | Autosampler | C3 |
| 4 | Kolonka (termostatda) | Колонка (в термостате) | Column (in a thermostat) | C4 |
| 5 | Elektropurkash ion manbai (ESI) | Источник электрораспыления (ESI) | Electrospray ion source (ESI) | C5 |
| 6 | Mass-analizator (kvadrupol) | Масс-анализатор (квадруполь) | Mass analyser (quadrupole) | C6 |
| 7 | Detektor (elektron ko‘paytirgich) | Детектор (электронный умножитель) | Detector (electron multiplier) | C7 |
| 8 | Vakuum nasoslari | Вакуумные насосы | Vacuum pumps | C8 |
| 9 | Ma’lumotlar tizimi | Система обработки данных | Data system | C9 |
<!-- /auto:parts-list -->

### 5.3 Namuna qanday kiritiladi

Manbaga ko‘ra, namuna oqsilni cho‘ktirish, sentrifugalash yoki filtrlash, qattiq fazali yoki suyuqlik-suyuqlik
ekstraksiyasi bilan tayyorlanadi [L3]. Umumiy tamoyil bo‘yicha, avtonamunaoluvchi namunani nasos haydayotgan
harakatlanuvchi faza oqimiga kiritadi [C2, C3, PR].

### 5.4 Ichkarida nima bo‘ladi

Umumiy tamoyil bo‘yicha, moddalar kolonkada ajralib, turli vaqtda chiqadi [C4, PR]. Manbaga ko‘ra, elektropurkash
manbai suyuqlikni zaryadlangan tomchilarga purkab, ionlar hosil qiladi [C5].

### 5.5 Signal qanday o‘lchanadi

Manbaga ko‘ra, ionlar m/z bo‘yicha ajratiladi va detektor ularni o‘lchaydi; detektor ionlarni kuchaytirilgan elektr
signaliga aylantiradi [L2, C6, C7]. Umumiy tamoyil bo‘yicha, mass-analizator ichida yuqori vakuum saqlanadi [C8].

### 5.6 Natija qanday olinadi

Manbaga ko‘ra, natija m/z va nisbiy intensivlik spektri sifatida ko‘rsatiladi [L2]. Umumiy tamoyil bo‘yicha,
ma’lumotlar tizimi xromatogramma va spektrlarni yozadi, maqsadli moddalar konsentratsiyasini kalibratorlar bo‘yicha
hisoblaydi [C9, RS]. Tandem (MS/MS) natija turlari bu darsda yoritilmaydi [L5].

## 6. Keng tarqalgan xatolar, xavfsizlik va QC

- Nazorat (QC) qo‘llanmasa, spektrda begona cho‘qqilar paydo bo‘lishi mumkin; manba bu bo‘limda kalibrlash
  tartibini bermaydi [L6] — `/lab/instruments/lc/a3-tox-lc-ms` (“Sifat nazorati va kalibrlash”).
- Qizigan qismlar va xavfli namunalar — himoya vositalari [L7] (o‘sha karta, “Biologik xavfsizlik”).
- “LC-MS” kartasini “LC-MS/MS bo‘yicha tasdiqlangan ma’lumot” deb taqdim etish — manbaga zid [L5].
- Ichki nazoratning umumiy vositalari — `/lab/qc`.

## 7. O‘z-o‘zini tekshirish savollari

1. Manbada qaysi namuna tayyorlash usullari keltirilgan? Javob: oqsilni cho‘ktirish va sentrifugalash yoki filtrlash,
   qattiq fazali yoki suyuqlik-suyuqlik ekstraksiyasi [L3].
2. Elektropurkash manbai nima qiladi? Javob: suyuqlikni zaryadlangan tomchilarga purkab, ionlar hosil qiladi [C5].
3. Ionlar qaysi nisbat bo‘yicha ajratiladi? Javob: massa/zaryad (m/z) [L2].
4. Nega bu dars LC-MS/MS tafsilotlarini bermaydi? Javob: manbada tandem bosqichi yo‘q [L5].
5. Spektrda begona cho‘qqilar paydo bo‘lishining manbada keltirilgan sababi? Javob: nazorat qo‘llanmagani [L6].

## 8. Epistemik holat

Qoida (to‘liq — [README](README.md#epistemik-qoida)): SOURCED — catalog.json manba id si va joyi;
STANDARD_TEXTBOOK — darslik darajasidagi umumiy tamoyil; NEEDS_EXPERT — aniqlik yoki raqam mutaxassis
tasdig‘ini kutadi. STANDARD_TEXTBOOK va NEEDS_EXPERT bayonotlar diktor matnida faqat “umumiy tamoyil bo‘yicha”
darajasida aytiladi, aniq model xususiyati sifatida emas. Mutaxassis ko‘rigi: EXPERT_REVIEW_PENDING.
Ataylab aytilmaydi: bosim, oqim tezligi, kolonka turi, purkash kuchlanishi, m/z qiymatlari, MS/MS rejimlari.

### 8.1 Sxema qismlari (avtomatik, `parts_src.py` dan)

<!-- auto:epistemic-parts mass_spec_lc -->
| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| C1 | Harakatlanuvchi faza idishlari — Erituvchilar (masalan, suv va organik erituvchi) nasosga beriladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_lc` #1 |
| C2 | Yuqori bosimli nasos — Erituvchilarni barqaror oqim bilan kolonka orqali haydaydi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_lc` #2 |
| C3 | Avtonamunaoluvchi — Flakondan namunani olib, oqimga kiritadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_lc` #3 |
| C4 | Kolonka (termostatda) — Moddalar kolonka fazasi bilan o‘zaro ta’siriga ko‘ra ajraladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_lc` #4 |
| C5 | Elektropurkash ion manbai (ESI) — Kolonkadan chiqqan suyuqlikni zaryadlangan tomchilarga purkab, ionlar hosil qiladi. | SOURCED | `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_lc` #5 |
| C6 | Mass-analizator (kvadrupol) — Elektr maydoni ionlarni m/z bo‘yicha ajratadi va navbat bilan o‘tkazadi. | SOURCED | `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_lc` #6 |
| C7 | Detektor (elektron ko‘paytirgich) — Kelgan ionlarni kuchaytirilgan elektr signaliga aylantiradi. | SOURCED | `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_lc` #7 |
| C8 | Vakuum nasoslari — Mass-analizator ichida yuqori vakuumni saqlaydi. | NEEDS_EXPERT | parts_src: TB; vakuum tuzilmasi manbasiz; `schematic_parts.json` → `mass_spec_lc` #8 |
| C9 | Ma’lumotlar tizimi — Xromatogramma va spektrlarni yozadi, miqdorni hisoblaydi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_lc` #9 |
| PR | Nasos suyuq harakatlanuvchi fazani yuqori bosimda kolonka orqali haydaydi, avtonamunaoluvchi namunani oqimga kiritadi. Moddalar kolonkada ajralib, turli vaqtda chiqadi. Elektropurkash (ESI) manbaida suyuqlik zaryadlangan tomchilarga purkaladi va moddalar gaz fazasidagi ionlarga aylanadi; ionlar m/z bo‘yicha ajratiladi va detektor qayd etadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_lc`.principle |
| RS | Xromatogramma va mass-spektrlar; maqsadli moddalar (dori vositalari, metabolitlar, biomarkerlar) aniqlanadi va kalibratorlar bo‘yicha konsentratsiyasi hisoblanadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_lc`.result |
<!-- /auto:epistemic-parts -->

### 8.2 Dars bayonotlari

| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| L1 | Suyuqlik xromatografi mass-spektrometr bilan ulangan; elektrospray ionizatsiyasi ion manbai sifatida qo‘llanishi mumkin. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-lc-ms].technology |
| L2 | Namuna ionlanadi, ionlar massa/zaryad (m/z) nisbati bo‘yicha ajratiladi va detektor ularni o‘lchaydi; natija m/z va nisbiy intensivlik spektri sifatida ko‘rsatiladi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-lc-ms].principle |
| L3 | Namuna tayyorlash odatda oqsilni cho‘ktirish va sentrifugalash yoki filtrlash, qattiq fazali yoki suyuqlik-suyuqlik ekstraksiyasini o‘z ichiga oladi; materiallar — plazma, zardob, siydik, so‘lak va boshqalar. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-lc-ms].specimens |
| L4 | Klinik kimyoda biomarkerlar va dori vositalarining metabolik profilini o‘lchash, shuningdek toksikologik tahlil uchun qo‘llanadi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-lc-ms].tasks |
| L5 | Ishlatilgan manba umumiy mass-spektrometriyani yoritadi, tandem (MS/MS) bosqichi va LC-MS/MS ga xos tafsilotlar unda yo‘q; karta faqat LC-MS asoslarini beradi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-lc-ms].limitations |
| L6 | Nazorat (QC) qo‘llanmasa, spektrda namunaga tegishli bo‘lmagan cho‘qqilar paydo bo‘lishi mumkin; manba bu bo‘limda kalibrlash tartibini bermaydi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-lc-ms].qc_calibration_note |
| L7 | Qurilmaning ba’zi qismlari qizib ketadi, namunalar xavfli bo‘lishi mumkin; himoya ko‘zoynagi, uzun ishchi kiyim, yopiq poyabzal, xalat va qo‘lqop tavsiya etiladi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-lc-ms].biosafety |
| N1 | LC-MS/MS: ikkinchi mass-analizator va to‘qnashuv bo‘linmasi bilan tandem tuzilma — bu dars manbasida ham, ilova sxemasida ham yo‘q; alohida manba va mutaxassis ko‘rigisiz darsga kiritilmaydi. | NEEDS_EXPERT | manba yo‘q; README.md “Topilmalar” F1 |
