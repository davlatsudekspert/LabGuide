# 06 — ELISA planshet o‘quvchisi va yuvish qurilmasi

RU: Планшетный ридер ИФА и промыватель · EN: ELISA microplate reader and washer

Kalit atamalar — EN: microplate, well, wash step, substrate, enzyme conjugate, optical density (OD), filter, photodetector, standard curve, cut-off · RU: микропланшет, лунка, отмывка, субстрат, ферментный конъюгат, оптическая плотность, фильтр, фотодетектор, калибровочная кривая, cut-off

**Holat:** EXPERT_REVIEW_PENDING — bu ilmiy video-dars REJASI va storyboard, tayyor video emas.
**Sxema:** `elisa_reader` — `tool/illustrations/schematic/elisa_reader.svg`
(`assets/instruments/schematic/elisa_reader_1200.png`), 8 ta raqamli belgi.
**Ilovadagi kartalar:** `/lab/instruments/lc/a1-elisa-reader-platform`, `/lab/instruments/lc/a1-elisa-method`.

## 1. O‘quv maqsadlari

- O‘quvchi (rider) va yuvish qurilmasining 8 ta raqamli qismini ko‘rsatish.
- Planshetdagi bosqichlar va yuvishning vazifasini tushuntirish.
- Optik zichlik qanday o‘lchanishi va standart egri chiziq bo‘yicha natija olinishini aytish.

## 2. Maqsadli auditoriya

Immunologiya/serologiya laboratoriyasi laborantlari va talabalar. Oldindan: antigen–antitana reaksiyasi tushunchasi.

## 3. Davomiylik

Taxminan 3,5 daqiqa (storyboard bo‘yicha 3:28).

## 4. Storyboard

| # | Ekranda (SVG / qatlam / belgilar) | Animatsiya g‘oyasi | Diktor matni (uz) | EN / RU atamalar | Bayonotlar | s |
|---|---|---|---|---|---|---|
| 1 | Kirish kartochkasi; fon — `elisa_reader.svg` xira | Sarlavha va “Sxematik animatsiya — aniq model emas” | Bu darsda ELISA planshet o‘quvchisi va yuvish qurilmasini ilovadagi sxematik chizma asosida ko‘ramiz. | ELISA reader / ИФА-ридер | — | 10 |
| 2 | `elisa_reader.svg` to‘liq, 1–8-belgilar xira | Kamera chapdagi o‘quvchidan o‘ngdagi yuvish qurilmasi va idishlarga suriladi | Manbaga ko‘ra, rang rivojlangandan keyin planshet quduqchalarining optik zichligi o‘lchanadi, bosqichlar orasida esa bog‘lanmagan material yuvib tashlanadi. Chapda o‘quvchi, o‘ngda yuvish qurilmasi. | microplate reader / ридер; washer / промыватель | L1 | 20 |
| 3 | 1, 4, 5-belgilar | Halqa va nom chipi | Manbaga ko‘ra: 1-belgi — 96 quduqchali mikroplanshet, 4-belgi — o‘lchanayotgan quduqcha, 5-belgi — o‘tgan nurni o‘lchaydigan fotodetektor. | 96-well plate / 96-луночный планшет; photodetector / фотодетектор | C1, C4, C5 | 18 |
| 4 | 2, 3-belgilar | Halqa va nom chipi | Umumiy tamoyil bo‘yicha: 2-belgi — lampa, 3-belgi — faqat kerakli to‘lqin uzunligini o‘tkazadigan optik filtr. | lamp / лампа; optical filter / оптический фильтр | C2, C3 | 14 |
| 5 | 6–8-belgilar | Halqa va nom chipi | Manbaga ko‘ra, 6-belgi — quduqchalarga yuvish eritmasini quyib, so‘rib oladigan ignalar. Umumiy tamoyil bo‘yicha: 7-belgi — yuvish eritmasi idishi, 8-belgi — chiqindi idishi. | wash manifold / промывочная гребёнка; wash buffer / промывочный буфер; waste / отходы | C6, C7, C8 | 18 |
| 6 | 1-belgi yaqin plan | Quduqchalarga namuna tomchilari tushadi | Manbaga ko‘ra, qon, zardob, so‘lak, siydik, orqa miya va bo‘g‘im suyuqligi kabi namunalar tilga olingan. Planshetga asoslangan immunoanalizda bir reaktant qattiq yuzaga biriktiriladi. | solid phase / твёрдая фаза; specimen / образец | L2, L3 | 20 |
| 7 | 6-belgi | Ignalar tushib eritma quyadi va so‘radi; quduqchalar “tozalanadi” | Manbaga ko‘ra, bosqichlar orasida yuvish qurilmasi bog‘lanmagan moddalarni yuvib tashlaydi. | wash step / отмывка; unbound material / несвязанные компоненты | PR | 16 |
| 8 | 1 va 4-belgilar | Substrat qo‘shilgach quduqchalar sariq rangga kiradi (intensivligi har xil) | Manbaga ko‘ra, oxirida substrat qo‘shiladi va ferment rang hosil qiladi; ferment signali analit miqdorini aks ettiradi. | substrate / субстрат; colour development / развитие окраски | PR, L2 | 18 |
| 9 | 2–5-belgilar (optik yo‘l) | Lampa → filtr → quduqcha → detektor bo‘ylab nur; rangli quduqcha nurning bir qismini yutadi | Manbaga ko‘ra, o‘quvchi har quduqchadan tanlangan to‘lqin uzunligidagi nurni o‘tkazib, yutilishni, ya’ni optik zichlikni o‘lchaydi. Umumiy tamoyil bo‘yicha, nurni lampa beradi va filtr to‘lqin uzunligini tanlaydi. | absorbance / поглощение; optical density / оптическая плотность | PR, C4, C5, C2, C3 | 22 |
| 10 | Monitor/pastki panel: standart egri chiziq (raqamsiz) | Standart nuqtalar va egri chiziq; noma’lum namuna egri chiziqdan o‘qiladi | Manbaga ko‘ra, o‘lchangan optik zichlik ma’lum konsentratsiyali standartlar egri chizig‘iga qo‘yiladi; natija miqdoriy, sifat yoki yarim miqdoriy bo‘ladi. | standard curve / калибровочная кривая; qualitative / качественный | L4 | 20 |
| 11 | Butun sxema; nazorat quduqchalari belgilanadi | Musbat va manfiy nazorat quduqchalari ramkada | Manbaga ko‘ra, har testda musbat va manfiy nazoratlar bemor namunasidek ishlanadi; musbat nazorat chegara qiymatga yaqin tanlanadi. ELISA skrining vositasi, o‘zi diagnostik emas. | positive/negative control / положительный/отрицательный контроль; screening / скрининг | L5, L6 | 22 |
| 12 | Savollar ekrani | Savollar birin-ketin | Batafsil ma’lumot ilovadagi ELISA kartalarida. Endi o‘zingizni tekshiring. | — | — | 10 |

## 5. Olti majburiy bosqich

### 5.1 Tashqi ko‘rinish

Manbaga ko‘ra, optik zichlik o‘lchanadi va bosqichlar orasida yuvish bajariladi [L1]. Umumiy tamoyil bo‘yicha,
sxemada chapda planshet tashuvchisi va optik yo‘l kesigi bo‘lgan o‘quvchi, o‘ngda ignalar qatori bo‘lgan yuvish
qurilmasi hamda yuvish eritmasi va chiqindi idishlari ko‘rinadi [C2, C3, C7, C8].

### 5.2 Asosiy qismlar (raqamli belgilar)

<!-- auto:parts-list elisa_reader -->
| Belgi | Qism (uz) | RU | EN | Bayonot |
|---|---|---|---|---|
| 1 | 96 quduqchali mikroplanshet | 96-луночный микропланшет | 96-well microplate | C1 |
| 2 | Yorug‘lik manbai (lampa) | Источник света (лампа) | Light source (lamp) | C2 |
| 3 | Optik filtr | Оптический фильтр | Optical filter | C3 |
| 4 | O‘lchanayotgan quduqcha | Измеряемая лунка | Well being read | C4 |
| 5 | Fotodetektor | Фотодетектор | Photodetector | C5 |
| 6 | Yuvish qurilmasi ignalari | Гребёнка игл вошера | Washer needle manifold | C6 |
| 7 | Yuvish eritmasi idishi | Ёмкость промывочного буфера | Wash buffer container | C7 |
| 8 | Chiqindi idishi | Ёмкость для отходов | Waste container | C8 |
<!-- /auto:parts-list -->

### 5.3 Namuna qanday kiritiladi

Manbaga ko‘ra, namuna (masalan, zardob) planshet quduqchalariga solinadi; bir reaktant qattiq yuzaga biriktirilgan
[L2, L3]. Planshet o‘quvchiga tashuvchida kiritiladi [C1].

### 5.4 Ichkarida nima bo‘ladi

Manbaga ko‘ra, quduqchalarda antigen–antitana reaksiyasi bosqichma-bosqich boradi, bosqichlar orasida yuvish
qurilmasi bog‘lanmagan moddalarni yuvib tashlaydi, oxirida substrat qo‘shilib ferment rang hosil qiladi [PR, C6].

### 5.5 Signal qanday o‘lchanadi

Manbaga ko‘ra, o‘quvchi har quduqchadan tanlangan to‘lqin uzunligidagi nurni o‘tkazib, yutilishni (optik zichlik)
o‘lchaydi, fotodetektor o‘tgan nurni qayd etadi [PR, C4, C5]. Umumiy tamoyil bo‘yicha, nurni lampa beradi, filtr
to‘lqin uzunligini tanlaydi [C2, C3].

### 5.6 Natija qanday olinadi

Manbaga ko‘ra, optik zichlik standartlar egri chizig‘iga qo‘yiladi va natija miqdoriy, sifat yoki yarim miqdoriy
ko‘rinishda beriladi [L4]. Umumiy tamoyil bo‘yicha, sifatiy natija chegara qiymatga (cut-off) nisbatan beriladi [RS].

## 6. Keng tarqalgan xatolar, xavfsizlik va QC

- Xatolar planshet, bufer, antitelo, bloklovchi vosita, antigen, ferment konyugati, yuvish, substrat, o‘qish asbobi
  yoki operatordan kelib chiqishi mumkin [L7] — `/lab/instruments/lc/a1-elisa-method` (“Preanalitik va analitik
  xatolar”).
- Nazoratsiz seriya: har testda musbat va manfiy nazoratlar [L5] — o‘sha karta, “Sifat nazorati va kalibrlash”;
  umumiy QC vositalari — `/lab/qc`.
- ELISA musbat natijasini yakuniy tashxis deb qabul qilish: manbaga ko‘ra, u skrining vositasi [L6].
- Asbobga xos texnik xizmat va filtrlar bo‘yicha ma’lumot manbada yo‘q [L8] — darsda to‘qilmaydi.

## 7. O‘z-o‘zini tekshirish savollari

1. Bosqichlar orasida yuvish nima uchun kerak? Javob: bog‘lanmagan moddalarni yuvib tashlash uchun [PR].
2. O‘quvchi nimani o‘lchaydi? Javob: tanlangan to‘lqin uzunligida yutilish, ya’ni optik zichlik [PR].
3. Noma’lum namuna konsentratsiyasi qanday topiladi? Javob: standartlar egri chizig‘idan [L4].
4. Musbat nazorat qanday tanlanadi? Javob: chegara qiymatga yaqin [L5].
5. Nega ELISA natijasi yakuniy tashxis emas? Javob: manbaga ko‘ra, u skrining vositasi [L6].

## 8. Epistemik holat

Qoida (to‘liq — [README](README.md#epistemik-qoida)): SOURCED — catalog.json manba id si va joyi;
STANDARD_TEXTBOOK — darslik darajasidagi umumiy tamoyil; NEEDS_EXPERT — aniqlik yoki raqam mutaxassis
tasdig‘ini kutadi. STANDARD_TEXTBOOK va NEEDS_EXPERT bayonotlar diktor matnida faqat “umumiy tamoyil bo‘yicha”
darajasida aytiladi, aniq model xususiyati sifatida emas. Mutaxassis ko‘rigi: EXPERT_REVIEW_PENDING.
Ataylab aytilmaydi: to‘lqin uzunligi qiymatlari, inkubatsiya vaqti va harorati, cut-off qiymatlari.

### 8.1 Sxema qismlari (avtomatik, `parts_src.py` dan)

<!-- auto:epistemic-parts elisa_reader -->
| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| C1 | 96 quduqchali mikroplanshet — Reaksiya va rang quduqchalarda; tashuvchi planshetni o‘quvchiga olib kiradi. | SOURCED | `a1-sp-elisa`; `schematic_parts.json` → `elisa_reader` #1 |
| C2 | Yorug‘lik manbai (lampa) — Quduqchadan o‘tadigan nurni beradi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `elisa_reader` #2 |
| C3 | Optik filtr — Faqat kerakli to‘lqin uzunligini o‘tkazadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `elisa_reader` #3 |
| C4 | O‘lchanayotgan quduqcha — Rangli eritma nurning bir qismini yutadi. | SOURCED | `a1-sp-elisa`; `schematic_parts.json` → `elisa_reader` #4 |
| C5 | Fotodetektor — O‘tgan nurni o‘lchaydi; undan yutilish hisoblanadi. | SOURCED | `a1-sp-elisa`; `schematic_parts.json` → `elisa_reader` #5 |
| C6 | Yuvish qurilmasi ignalari — Quduqchalarga yuvish eritmasini quyadi va so‘rib oladi. | SOURCED | `a1-sp-elisa`; `schematic_parts.json` → `elisa_reader` #6 |
| C7 | Yuvish eritmasi idishi — Yuvish qurilmasiga bufer beradi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `elisa_reader` #7 |
| C8 | Chiqindi idishi — So‘rilgan suyuqlik to‘planadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `elisa_reader` #8 |
| PR | Planshet quduqchalarida antigen–antitana reaksiyasi bosqichma-bosqich boradi; bosqichlar orasida yuvish qurilmasi bog‘lanmagan moddalarni yuvib tashlaydi. Oxirida substrat qo‘shiladi va ferment rang hosil qiladi. O‘quvchi har quduqchadan tanlangan to‘lqin uzunlikdagi nurni o‘tkazib, yutilishni (optik zichlik) o‘lchaydi; noma’lum namunalar standart egri chiziq bo‘yicha hisoblanadi. | SOURCED | `a1-sp-elisa`; `schematic_parts.json` → `elisa_reader`.principle |
| RS | Har quduqcha uchun optik zichlik (OD) qiymatlari; standart egri chiziq bo‘yicha konsentratsiya yoki chegara qiymatga (cut-off) nisbatan sifatiy natija (musbat/manfiy). | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a1-sp-elisa`; `schematic_parts.json` → `elisa_reader`.result |
<!-- /auto:epistemic-parts -->

### 8.2 Dars bayonotlari

| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| L1 | Rang rivojlangandan keyin planshet yacheykalarining optik zichligi (absorbsiya) o‘lchanadi; bosqichlar orasida bog‘lanmagan material yuvib tashlanadi (odatda 96 yacheykali polistirol planshet). | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-reader-platform].technology |
| L2 | Planshetga asoslangan immunoanaliz: bir reaktant qattiq yuzaga biriktiriladi, ferment signali (odatda rang o‘zgarishi) analit miqdorini aks ettiradi. | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-method].technology |
| L3 | Qon, zardob, so‘lak, siydik, orqa miya va bo‘g‘im suyuqligi kabi suyuqliklar tilga olingan. | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-method].specimens |
| L4 | O‘lchangan optik zichlik ma’lum konsentratsiyali standartlar egri chizig‘iga qo‘yilib, natija miqdoriy, sifat yoki yarim miqdoriy ko‘rinishda beriladi. | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-reader-platform].tasks |
| L5 | Har testda musbat va manfiy nazoratlar bemor namunasidek ishlanadi; musbat nazorat chegara qiymatga yaqin tanlanadi. | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-method].qc_calibration_note |
| L6 | ELISA skrining vositasi; o‘zi diagnostik emas (masalan, OIV musbatlari tasdiqlovchi test talab qiladi). | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-method].limitations |
| L7 | Xatolar planshet, bufer, antitelo, bloklovchi vosita, antigen, ferment konyugati, yuvish, substrat, o‘qish asbobi yoki operatordan kelib chiqishi mumkin. | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-method].preanalytic_analytic_errors |
| L8 | Yuvish bosqichlari va o‘qish asbobi xato manbalari qatoriga kiradi; asbobga xos texnik xizmat va filtrlar bo‘yicha ma’lumot bu manbada yo‘q. | SOURCED | `a1-sp-elisa`; catalog.json lab_cards[a1-elisa-reader-platform].preanalytic_analytic_errors |
