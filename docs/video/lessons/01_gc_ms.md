# 01 — Gaz xromatografi–mass-spektrometr (GC-MS)

RU: Газовый хромато-масс-спектрометр (ГХ-МС) · EN: Gas chromatograph–mass spectrometer (GC-MS)

Kalit atamalar — EN: carrier gas, injector, capillary column, retention time, ion source, quadrupole, m/z, detector, chromatogram, mass spectrum · RU: газ-носитель, инжектор, капиллярная колонка, время удерживания, ионный источник, квадруполь, m/z, детектор, хроматограмма, масс-спектр

**Holat:** EXPERT_REVIEW_PENDING — bu ilmiy video-dars REJASI va storyboard, tayyor video emas.
**Sxema:** `mass_spec_gc` — `tool/illustrations/schematic/mass_spec_gc.svg`
(`assets/instruments/schematic/mass_spec_gc_1200.png`), 10 ta raqamli belgi.
**Ilovadagi karta:** `/lab/instruments/lc/a3-tox-gc-ms`.
**Ishlaydigan namuna animatsiya:** bor (ovozsiz, subtitrli) — [SAMPLES.md](SAMPLES.md).

## 1. O‘quv maqsadlari

- GC-MS ning ikki blokini (gaz xromatografi va mass-spektrometr) va 10 ta raqamli qismini sxemada ko‘rsatib bera olish.
- Namuna qanday kiritilishi va nega u uchuvchan bo‘lishi kerakligini tushuntirish.
- Kolonkada ajralish (ushlanish vaqti) va m/z bo‘yicha ajralishning farqini aytish.
- Natijaning ikki ko‘rinishini — xromatogramma va mass-spektrni — farqlash.

## 2. Maqsadli auditoriya

Tibbiyot kolleji va OTM talabalari (klinik laboratoriya diagnostikasi), toksikologiya bo‘limiga yangi kelgan
laborantlar. Oldindan: xromatografiya haqida umumiy tushuncha.

## 3. Davomiylik

Taxminan 4 daqiqa (storyboard bo‘yicha 4:04). Ishlaydigan qisqa namuna (sahnalar 2, 6–11) — `SAMPLES.md`.

## 4. Storyboard

| # | Ekranda (SVG / qatlam / belgilar) | Animatsiya g‘oyasi | Diktor matni (uz) | EN / RU atamalar | Bayonotlar | s |
|---|---|---|---|---|---|---|
| 1 | Kirish kartochkasi; fon — `mass_spec_gc.svg` xira | Sarlavha, yorliqlar “Sxematik animatsiya — aniq model emas” va “Ovozsiz namuna (diktorsiz)” | Bu darsda gaz xromatografi–mass-spektrometr, qisqacha GC-MS, qanday ishlashini ilovadagi sxematik chizma asosida ko‘ramiz. Chizma aniq model emas, apparat sinfining umumiy tasviri. | GC-MS / ГХ-МС | — | 10 |
| 2 | `mass_spec_gc.svg` to‘liq, `#callouts` xira (1–10-belgilar) | Kamera chapdan o‘ngga suriladi: ballon → GC bloki → uzatish liniyasi → MS bloki → monitor | Tashqi ko‘rinishda ikki asosiy blok bor: chapda gaz xromatografi, o‘ngda mass-spektrometr. Manbaga ko‘ra, mass-spektrometr ion manbai, massa analizatori va detektordan iborat. | gas chromatograph / газовый хроматограф; mass spectrometer / масс-спектрометр | L1 | 18 |
| 3 | 1–5-belgilar navbat bilan yonadi | Har belgi atrofida halqa; pastda nom chipi (uz + EN) | Umumiy tamoyil bo‘yicha, chap tomondagi qismlar: 1-belgi — tashuvchi gaz ballon, 2-belgi — avtonamunaoluvchi, 3-belgi — injektor, 4-belgi — termostatdagi kapillyar kolonka, 5-belgi — issiq uzatish liniyasi. | carrier gas / газ-носитель; autosampler / автосамплер; injector / инжектор; capillary column / капиллярная колонка; transfer line / линия переноса | C1, C2, C3, C4, C5 | 24 |
| 4 | 6–10-belgilar navbat bilan yonadi | Xuddi shunday; MS kesigi kattalashadi | Umumiy tamoyil bo‘yicha, o‘ng tomonda: 6-belgi — ion manbai, 7-belgi — kvadrupol mass-analizator, 8-belgi — detektor, 9-belgi — vakuum nasoslari, 10-belgi — ma’lumotlar tizimi. | ion source / ионный источник; quadrupole / квадруполь; detector / детектор; vacuum pumps / вакуумные насосы; data system / система обработки данных | C6, C7, C8, C9, C10 | 22 |
| 5 | Avtonamunaoluvchi karuseli yaqin plan (2-belgi) | Flakon ustida matn chipi “uchuvchan, parchalanmasdan gazga o‘tadi” | Manbaga ko‘ra, gaz xromatografiyasi uchun namuna uchuvchan bo‘lishi, ya’ni parchalanmasdan gaz fazasiga o‘ta olishi kerak; buning uchun ba’zan hosilalash, ya’ni derivatizatsiya qo‘llanadi. | volatile / летучий; derivatization / дериватизация | L3 | 16 |
| 6 | 1–3-belgilar yaqin plan | Shpris flakondan namuna oladi va injektorga tushiradi; tomchi bug‘ bulutchasiga aylanadi; 1-belgidan gaz oqimi o‘qlari | Umumiy tamoyil bo‘yicha, avtonamunaoluvchi namunani shpris bilan olib injektorga kiritadi. Qizdirilgan injektorda suyuq namuna bug‘lanadi va tashuvchi gaz oqimiga qo‘shiladi. | syringe / шприц; vaporization / испарение | C1, C2, C3 | 18 |
| 7 | 4-belgi: termostat oynasi (kolonka o‘rami) | Bitta aralash bulutcha spiral bo‘ylab yuradi va uch rangli zonaga ajraladi; zonalar kolonkadan turli vaqtda chiqadi | Umumiy tamoyil bo‘yicha, termostat harorat dasturi bo‘yicha qizdiriladi. Moddalar uchuvchanligi va kolonka bilan o‘zaro ta’siriga ko‘ra kolonkadan turli vaqtda chiqadi — bu ushlanish vaqti deyiladi. | oven / термостат; retention time / время удерживания | C4, PR | 20 |
| 8 | 5–6-belgilar | Zonalar uzatish liniyasidan o‘tib ion manbaiga kiradi; neytral doirachalar “+” belgili kichik bo‘laklarga bo‘linadi | Ajralgan moddalar issiq uzatish liniyasi orqali mass-spektrometrga o‘tadi va ion manbaida ionlanadi. Umumiy tamoyil bo‘yicha, GC-MS da ko‘pincha elektron zarbasi ishlatiladi va ionlar bo‘laklarga ajraladi. | electron ionization / электронная ионизация; fragment ion / ион-фрагмент | C5, C6, L2 | 18 |
| 9 | 7-belgi (kvadrupol sterjenlari) | Turli rangli ionlar sterjenlar orasiga kiradi; har lahzada faqat bitta rang o‘tadi, qolganlari chetga og‘ib so‘nadi; tanlangan rang navbat bilan almashadi | Manbaga ko‘ra, ionlar massa/zaryad nisbati, ya’ni m/z bo‘yicha ajratiladi. Kvadrupolda elektr maydoni ionlarni m/z bo‘yicha saralab, navbat bilan detektorga o‘tkazadi. | mass-to-charge ratio, m/z / отношение массы к заряду | L2, C7 | 18 |
| 10 | 8–9-belgilar | Detektorga yetgan ion chaqnash beradi; signal chizig‘i 10-belgi tomon yuguradi; 9-belgi xira, sekin aylanadi | Detektor kelgan ionlarni kuchaytirilgan elektr signaliga aylantiradi. Umumiy tamoyil bo‘yicha, vakuum nasoslari analizator ichida yuqori vakuum saqlaydi, shunda ionlar yo‘lda havo molekulalari bilan kam to‘qnashadi. | electron multiplier / электронный умножитель; high vacuum / высокий вакуум | C8, C9 | 20 |
| 11 | 10-belgi monitori kattalashtirilgan | Xromatogramma cho‘qqilari zonalar chiqqan vaqtga mos o‘sadi (o‘qlarda raqam yo‘q); bitta cho‘qqi tanlanadi va uning mass-spektri chiziqchalar bo‘lib ochiladi | Natija ikki ko‘rinishda. Manbaga ko‘ra, mass-spektr m/z va nisbiy intensivlik sifatida ko‘rsatiladi. Umumiy tamoyil bo‘yicha, xromatogramma signalni ushlanish vaqti bo‘yicha ko‘rsatadi, modda esa spektrlar kutubxonasi yoki standartlar bilan solishtirib aniqlanadi. | chromatogram / хроматограмма; mass spectrum / масс-спектр; spectral library / библиотека спектров | L2, RS, C10 | 24 |
| 12 | Butun sxema; piktogrammalar: qizigan sirt, ko‘zoynak, qo‘lqop | Belgilar xira; pastda karta bo‘limlari nomi: “Biologik xavfsizlik”, “Sifat nazorati va kalibrlash” | Manbaga ko‘ra, qurilmaning ba’zi qismlari qizib ketadi va namunalar xavfli bo‘lishi mumkin, shuning uchun ko‘zoynak, xalat, qo‘lqop va yopiq poyabzal tavsiya etiladi. Nazorat qo‘llanmasa, spektrda namunaga tegishli bo‘lmagan cho‘qqilar paydo bo‘lishi mumkin. | personal protective equipment / средства индивидуальной защиты; quality control / контроль качества | L6, L5 | 22 |
| 13 | Ilovadagi GC-MS kartasi eslatmasi (`/lab/instruments/lc/a3-tox-gc-ms`), so‘ng savollar | Savollar birin-ketin chiqadi | Manbada qo‘llanish sohasi sifatida sud-tibbiy toksikologiya va dori vositalarini aniqlash keltirilgan. Batafsil ma’lumot ilovadagi GC-MS kartasida. Endi o‘zingizni tekshiring. | forensic toxicology / судебная токсикология | L4 | 14 |

## 5. Olti majburiy bosqich

### 5.1 Tashqi ko‘rinish

Manbaga ko‘ra, gaz xromatografi mass-spektrometr bilan ulangan; MS qismi ion manbai, massa analizatori va
detektordan iborat [L1]. Umumiy tamoyil bo‘yicha, sxemada chapda gaz ballon va avtonamunaoluvchi minorasi
bo‘lgan GC korpusi, o‘ngda vakuum nasoslari bilan MS korpusi va alohida monitor ko‘rinadi [C1, C2, C9, C10].

### 5.2 Asosiy qismlar (raqamli belgilar)

<!-- auto:parts-list mass_spec_gc -->
| Belgi | Qism (uz) | RU | EN | Bayonot |
|---|---|---|---|---|
| 1 | Tashuvchi gaz ballon | Баллон с газом-носителем | Carrier gas cylinder | C1 |
| 2 | Avtonamunaoluvchi | Автосэмплер | Autosampler | C2 |
| 3 | Injektor (bug‘lantirgich) | Инжектор (испаритель) | Injector (inlet) | C3 |
| 4 | Termostat va kapillyar kolonka | Термостат и капиллярная колонка | Oven and capillary column | C4 |
| 5 | Issiq uzatish liniyasi | Обогреваемая линия переноса | Heated transfer line | C5 |
| 6 | Ion manbai | Ионный источник | Ion source | C6 |
| 7 | Mass-analizator (kvadrupol) | Масс-анализатор (квадруполь) | Mass analyser (quadrupole) | C7 |
| 8 | Detektor (elektron ko‘paytirgich) | Детектор (электронный умножитель) | Detector (electron multiplier) | C8 |
| 9 | Vakuum nasoslari | Вакуумные насосы | Vacuum pumps | C9 |
| 10 | Ma’lumotlar tizimi | Система обработки данных | Data system | C10 |
<!-- /auto:parts-list -->

### 5.3 Namuna qanday kiritiladi

Manbaga ko‘ra, namuna uchuvchan bo‘lishi kerak, buning uchun hosilalash qo‘llanishi mumkin [L3]. Umumiy tamoyil
bo‘yicha, avtonamunaoluvchi flakondan namunani olib qizdirilgan injektorga kiritadi; namuna bug‘lanib, tashuvchi
gaz oqimiga qo‘shiladi [C1, C2, C3].

### 5.4 Ichkarida nima bo‘ladi

Umumiy tamoyil bo‘yicha, moddalar termostatdagi kapillyar kolonkada ajraladi va turli vaqtda chiqadi (ushlanish
vaqti), so‘ng issiq uzatish liniyasi orqali ion manbaiga o‘tadi [C4, C5, PR]. Manbaga ko‘ra, namuna ionlanadi [L2].

### 5.5 Signal qanday o‘lchanadi

Manbaga ko‘ra, ionlar m/z bo‘yicha ajratiladi va detektor ularni o‘lchaydi; kvadrupol ionlarni navbat bilan
o‘tkazadi, detektor ularni kuchaytirilgan elektr signaliga aylantiradi [L2, C7, C8]. Umumiy tamoyil bo‘yicha, bu
jarayon yuqori vakuumda boradi [C9].

### 5.6 Natija qanday olinadi

Manbaga ko‘ra, natija m/z va nisbiy intensivlik spektri sifatida ko‘rsatiladi [L2]. Umumiy tamoyil bo‘yicha,
ma’lumotlar tizimi xromatogramma va har cho‘qqi spektrini yozadi va kutubxona yoki standart bilan solishtiradi
[C10, RS]. Klinik yoki sud-tibbiy talqin bu dars doirasidan tashqarida.

## 6. Keng tarqalgan xatolar, xavfsizlik va QC

- Nazorat (QC) qo‘llanmasa, spektrda namunaga tegishli bo‘lmagan cho‘qqilar paydo bo‘lishi mumkin; manba bu
  bo‘limda kalibrlash tartibini bermaydi [L5]. Ilovada: GC-MS kartasi, “Sifat nazorati va kalibrlash” —
  `/lab/instruments/lc/a3-tox-gc-ms`.
- Qizigan qismlar va xavfli namunalar: himoya ko‘zoynagi, xalat, qo‘lqop, yopiq poyabzal [L6] — o‘sha kartaning
  “Biologik xavfsizlik” bo‘limi.
- Uchuvchan bo‘lmagan yoki qizdirilganda parchalanadigan moddani hosilalashsiz GC ga berish — manbadagi talabga
  zid [L3].
- Ichki nazoratning umumiy vositalari (Levey–Jennings, Westgard) — `/lab/qc`; bu bo‘lim GC-MS ga xos emas.

## 7. O‘z-o‘zini tekshirish savollari

1. Manbaga ko‘ra mass-spektrometr qaysi uch qismdan iborat? Javob: ion manbai, massa analizatori, detektor [L1].
2. Nega GC uchun namuna uchuvchan bo‘lishi kerak va bunga qanday erishiladi? Javob: parchalanmasdan gaz fazasiga
   o‘tishi kerak; hosilalash (derivatizatsiya) [L3].
3. Ushlanish vaqti nima? Javob: umumiy tamoyil bo‘yicha — moddaning kolonkadan chiqish vaqti [PR].
4. Mass-spektrning o‘qlari nimani ko‘rsatadi? Javob: m/z va nisbiy intensivlik [L2].
5. Spektrda begona cho‘qqilar paydo bo‘lishining manbada keltirilgan sababi? Javob: nazorat (QC) qo‘llanmagani [L5].

## 8. Epistemik holat

Qoida (to‘liq — [README](README.md#epistemik-qoida)): SOURCED — catalog.json manba id si va joyi;
STANDARD_TEXTBOOK — darslik darajasidagi umumiy tamoyil; NEEDS_EXPERT — aniqlik yoki raqam mutaxassis
tasdig‘ini kutadi. STANDARD_TEXTBOOK va NEEDS_EXPERT bayonotlar diktor matnida faqat “umumiy tamoyil bo‘yicha”
darajasida aytiladi, aniq model xususiyati sifatida emas. Mutaxassis ko‘rigi: EXPERT_REVIEW_PENDING.
Ataylab aytilmaydi: harorat dasturi, gaz oqimi, vakuum darajasi, ionlash energiyasi, m/z qiymatlari — manbada yo‘q.

### 8.1 Sxema qismlari (avtomatik, `parts_src.py` dan)

<!-- auto:epistemic-parts mass_spec_gc -->
| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| C1 | Tashuvchi gaz ballon — Inert gaz (odatda geliy) namunani kolonka bo‘ylab olib yuradi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_gc` #1 |
| C2 | Avtonamunaoluvchi — Flakondan namunani shpris bilan olib, injektorga kiritadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_gc` #2 |
| C3 | Injektor (bug‘lantirgich) — Qizdirilgan kirish joyi: suyuq namuna bug‘lanib, gaz oqimiga qo‘shiladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_gc` #3 |
| C4 | Termostat va kapillyar kolonka — Harorat dasturi bo‘yicha qizdiriladi; moddalar kolonkada ajraladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_gc` #4 |
| C5 | Issiq uzatish liniyasi — Ajralgan moddalarni kondensatsiyasiz mass-spektrometrga o‘tkazadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_gc` #5 |
| C6 | Ion manbai — Molekulalarni ionlaydi (GC-MS da ko‘pincha elektron zarbasi bilan), ionlar bo‘laklarga ajraladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_gc` #6 |
| C7 | Mass-analizator (kvadrupol) — Elektr maydoni ionlarni m/z bo‘yicha ajratadi va navbat bilan o‘tkazadi. | SOURCED | `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_gc` #7 |
| C8 | Detektor (elektron ko‘paytirgich) — Kelgan ionlarni kuchaytirilgan elektr signaliga aylantiradi. | SOURCED | `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_gc` #8 |
| C9 | Vakuum nasoslari — Turbomolekulyar va forvakuum nasoslari yuqori vakuum hosil qiladi — ionlar havo molekulalariga urilmaydi. | NEEDS_EXPERT | parts_src: TB; mutlaq ibora (“urilmaydi”) va nasos turlari manbasiz; `schematic_parts.json` → `mass_spec_gc` #9 |
| C10 | Ma’lumotlar tizimi — Xromatogramma va spektrlarni yozadi, kutubxona bilan solishtiradi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `mass_spec_gc` #10 |
| PR | Namuna injektorda bug‘lanadi, tashuvchi gaz (odatda geliy) uni termostatdagi kapillyar kolonkaga olib kiradi. Moddalar uchuvchanligi va kolonka bilan o‘zaro ta’siriga ko‘ra turli vaqtda chiqadi (ushlanish vaqti). Mass-spektrometrda ular ionlanadi, ionlar massa/zaryad nisbati (m/z) bo‘yicha ajratiladi va detektor qayd etadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_gc`.principle |
| RS | Xromatogramma (signal — ushlanish vaqti bo‘yicha) va har cho‘qqining mass-spektri (m/z — nisbiy intensivlik); moddalar spektrlar kutubxonasi yoki standartlar bilan solishtirib aniqlanadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a3-statpearls-ms`; `schematic_parts.json` → `mass_spec_gc`.result |
<!-- /auto:epistemic-parts -->

### 8.2 Dars bayonotlari

| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| L1 | Gaz xromatografi mass-spektrometr bilan ulangan: ion manbai, massa analizatori va detektordan iborat. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-gc-ms].technology |
| L2 | Namuna ionlanadi, ionlar massa/zaryad (m/z) nisbati bo‘yicha ajratiladi va detektor ularni o‘lchaydi; natija m/z va nisbiy intensivlik spektri sifatida ko‘rsatiladi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-gc-ms].principle |
| L3 | GC uchun namuna uchuvchan bo‘lishi — parchalanmasdan gaz fazasiga o‘ta olishi kerak; uchuvchanlik va termik barqarorlik uchun hosilalash (derivatizatsiya) qo‘llanishi mumkin. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-gc-ms].specimens |
| L4 | Sud-tibbiy toksikologiya va dori vositalarini aniqlashda qo‘llanadi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-gc-ms].tasks |
| L5 | Nazorat (QC) qo‘llanmasa, spektrda namunaga tegishli bo‘lmagan cho‘qqilar paydo bo‘lishi mumkin; manba bu bo‘limda kalibrlash tartibini bermaydi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-gc-ms].qc_calibration_note |
| L6 | Qurilmaning ba’zi qismlari qizib ketadi, namunalar xavfli bo‘lishi mumkin; himoya ko‘zoynagi, uzun ishchi kiyim, yopiq poyabzal, xalat va qo‘lqop tavsiya etiladi. | SOURCED | `a3-statpearls-ms`; catalog.json lab_cards[a3-tox-gc-ms].biosafety |
