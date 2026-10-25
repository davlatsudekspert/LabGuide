# 04 — Real vaqt PCR (termosiklator va fluoressent detektsiya)

RU: ПЦР в реальном времени (термоциклер с флуоресцентной детекцией) · EN: Real-time PCR (thermal cycler with fluorescence detection)

Kalit atamalar — EN: thermal cycler, heated lid, Peltier block, primer, polymerase, reverse transcriptase, amplicon, fluorescence, threshold, Cq · RU: термоциклер, нагреваемая крышка, блок Пельтье, праймер, полимераза, обратная транскриптаза, ампликон, флуоресценция, порог, Cq

**Holat:** EXPERT_REVIEW_PENDING — bu ilmiy video-dars REJASI va storyboard, tayyor video emas.
**Sxema:** `real_time_pcr` — `tool/illustrations/schematic/real_time_pcr.svg`
(`assets/instruments/schematic/real_time_pcr_1200.png`), 9 ta raqamli belgi.
**Ilovadagi kartalar:** `/lab/instruments/lc/a3-mol-realtime-pcr-platform`, `/lab/instruments/lc/a1-realtime-pcr-method`,
`/lab/instruments/lc/hiv-rna-viral-load`.
**Ishlaydigan namuna animatsiya:** bor (ovozsiz, subtitrli) — [SAMPLES.md](SAMPLES.md).

## 1. O‘quv maqsadlari

- Real vaqt PCR apparatining 9 ta raqamli qismini va fluoressent signal yo‘lini sxemada ko‘rsatish.
- Bitta siklning uch bosqichini (zanjirlarning ajralishi, praymer birikishi, sintez) va nishonning ko‘payishini tushuntirish.
- Fluoressensiya har siklda o‘lchanishini va signal nimani aks ettirishini aytish.
- Kuchayish egri chizig‘i, chegara va Cq tushunchalarini farqlash.

## 2. Maqsadli auditoriya

Klinik laboratoriya diagnostikasi talabalari, molekulyar (PZR) laboratoriyasiga yangi kelgan laborantlar.
Oldindan: DNK/RNK tuzilishi haqida umumiy tushuncha.

## 3. Davomiylik

Taxminan 4 daqiqa (storyboard bo‘yicha 3:54). Ishlaydigan qisqa namuna (sahnalar 2–3, 5–10) — `SAMPLES.md`.

## 4. Storyboard

| # | Ekranda (SVG / qatlam / belgilar) | Animatsiya g‘oyasi | Diktor matni (uz) | EN / RU atamalar | Bayonotlar | s |
|---|---|---|---|---|---|---|
| 1 | Kirish kartochkasi; fon — `real_time_pcr.svg` xira | Sarlavha va yorliqlar “Sxematik animatsiya — aniq model emas”, “Ovozsiz namuna (diktorsiz)” | Bu darsda real vaqt PCR, ya’ni real vaqtda kuzatiladigan polimeraza zanjir reaksiyasi apparatini ilovadagi sxematik chizma asosida ko‘ramiz. Chizma aniq model emas. | real-time PCR / ПЦР в реальном времени | — | 10 |
| 2 | `real_time_pcr.svg` to‘liq; 1–9-belgilar xira | Kamera korpus → ochiq qopqoq → optik modul → monitor bo‘ylab suriladi | Manbaga ko‘ra, apparat termosiklator va har siklda fluoressensiyani o‘lchaydigan optik detektordan iborat; yirik avtomat tizimlar ekstraksiya, kuchaytirish va aniqlashni birlashtiradi. | thermal cycler / термоциклер; optical detector / оптический детектор | L1 | 18 |
| 3 | 1–3-belgilar navbat bilan | Har belgi atrofida halqa; pastda nom chipi | Umumiy tamoyil bo‘yicha: 1-belgi — PCR probirkalari qatori, 2-belgi — isitiladigan qopqoq, u qopqoqlarda bug‘ to‘planishining oldini oladi, 3-belgi — termoblok. | PCR tubes / ПЦР-пробирки; heated lid / нагреваемая крышка; thermal block / термоблок | C1, C2, C3 | 18 |
| 4 | 4–9-belgilar navbat bilan | Signal yo‘li kesigi kattalashadi; so‘ng monitor | Umumiy tamoyil bo‘yicha: 4-belgi — qo‘zg‘atuvchi nur manbai, 5-belgi — qo‘zg‘atish filtri, 6-belgi — termoblokdagi reaksiya probirkasi, 7-belgi — nurlanish filtri. Manbaga ko‘ra, 8-belgi — fluoressensiyani o‘lchaydigan detektor, 9-belgi — kuchayish egri chiziqlarini chizadigan dastur. | excitation / возбуждение; emission filter / эмиссионный фильтр; detector / детектор | C4, C5, C6, C7, C8, C9 | 24 |
| 5 | 1-belgi yaqin plan | Matn chipi: “avval — nuklein kislota ajratish” | Manbaga ko‘ra, namunadan avval nuklein kislota ajratib olinadi. RNK nishon bo‘lsa, u avval teskari transkriptaza bilan kDNKga aylantiriladi. | nucleic acid extraction / выделение нуклеиновых кислот; reverse transcriptase / обратная транскриптаза | L3, L2 | 16 |
| 6 | 1 va 3-belgilar | Probirkalar qatori yoy bo‘ylab termoblokka “uchib” o‘tadi; blokdagi uyachalar yonadi | Umumiy tamoyil bo‘yicha, reaksiya aralashmasi solingan probirkalar termoblokka qo‘yiladi va isitiladigan qopqoq bilan yopiladi. | reaction mix / реакционная смесь | C1, C2, C3 | 14 |
| 7 | 3-belgi (blok) + pastki panelda sikl profili | Blok rangi qizil → ko‘k → sariq almashadi; panelda kursor bosqichlar bo‘ylab yuradi (raqamsiz) | Manbaga ko‘ra, har siklda qizdirish DNK zanjirlarini ajratadi, sovutishda praymerlar birikadi, issiqqa chidamli polimeraza yangi zanjir quradi. | denaturation / денатурация; annealing / отжиг; extension / элонгация | L2 | 20 |
| 8 | Pastki panel: DNK belgichalari | Har sikl oxirida belgichalar soni ikki barobar bo‘ladi | Manbaga ko‘ra, har siklda nishon taxminan ikki barobar ko‘payadi. Umumiy tamoyil bo‘yicha, bunday tez harorat almashinuvini termoblok ta’minlaydi. | amplification / амплификация; amplicon / ампликон | L2, C3 | 16 |
| 9 | 4–8-belgilar (signal yo‘li) | Har sikl oxirida: manba chaqnaydi → qo‘zg‘atish filtri kanal rangini oladi → nur probirkaga tushadi → probirka fluoressensiya chiqaradi → nurlanish filtri → detektor yonadi | Manbaga ko‘ra, detektor har siklda probirkalardagi fluoressensiyani o‘lchaydi va signal amplikon to‘planishiga mutanosib. Umumiy tamoyil bo‘yicha, qo‘zg‘atuvchi nur probirkadagi bo‘yoq yoki zondga tushadi, filtrlar kerakli rang kanalini ajratadi. | fluorescence / флуоресценция; channel / канал | L4, C8, C4, C5, C6, C7 | 22 |
| 10 | 9-belgi monitori; pastki panelda egri chiziqlar | Egri chiziqlar sikl sayin o‘sadi; chegara chizig‘i paydo bo‘ladi; Cq nuqtalari o‘qqa tushiriladi (raqamsiz) | Manbaga ko‘ra, asosiy natija — fluoressensiya belgilangan chegaradan o‘tgan sikl, ya’ni Cq. Cq qancha kichik bo‘lsa, boshlang‘ich nishon shuncha ko‘p. | amplification curve / кривая амплификации; threshold / порог; quantification cycle / пороговый цикл | L5, C9 | 22 |
| 11 | 9-belgi | Egri chiziqlar yonida “standartlar bo‘yicha” belgisi | Manbaga ko‘ra, miqdoriy testlarda konsentratsiya standartlar bo‘yicha hisoblanadi; masalan, ilovadagi OIV-1 virus yuki kartasi shunday miqdoriy test. | standard curve / стандартная кривая; viral load / вирусная нагрузка | RS, L10 | 16 |
| 12 | Butun sxema; piktogrammalar: alohida zona, qo‘lqop, niqob | Belgilar xira; pastda karta bo‘limlari: “Sifat nazorati va kalibrlash”, “Cheklovlar” | Manbaga ko‘ra, PZR o‘ta sezgir, ozgina ifloslanish soxta natija berishi mumkin. Shuning uchun alohida PCR zonasi, himoya vositalari va ajratilgan jihozlar ishlatiladi. Ingibitorlar esa kuchaytirishni susaytiradi. | contamination / контаминация; inhibitor / ингибитор | L7, L6, L8 | 24 |
| 13 | Ilova kartalari eslatmasi, so‘ng savollar | Savollar birin-ketin chiqadi | Manbaga ko‘ra, amplifikatsiyaning yo‘qligi namuna manfiy ekanini ishonchli isbotlamaydi. Batafsil ma’lumot ilovadagi real vaqt PCR kartalarida. Endi o‘zingizni tekshiring. | — | L7 | 14 |

## 5. Olti majburiy bosqich

### 5.1 Tashqi ko‘rinish

Manbaga ko‘ra, apparat termosiklator va har siklda fluoressensiyani o‘lchaydigan optik detektordan iborat [L1].
Umumiy tamoyil bo‘yicha, sxemada ochiq isitiladigan qopqoq, termoblok, old tomonda fluoressent signal yo‘lining
kesigi (manba → qo‘zg‘atish filtri → blokdagi probirka → nurlanish filtri → detektor), stol ustidagi probirkalar
qatori va dastur monitori ko‘rinadi [C1, C2, C3, C4, C5, C6, C7].

### 5.2 Asosiy qismlar (raqamli belgilar)

<!-- auto:parts-list real_time_pcr -->
| Belgi | Qism (uz) | RU | EN | Bayonot |
|---|---|---|---|---|
| 1 | PCR probirkalari (qator) | ПЦР-пробирки (стрип) | PCR tubes (strip) | C1 |
| 2 | Isitiladigan qopqoq | Нагреваемая крышка | Heated lid | C2 |
| 3 | Termoblok (Peltye) | Термоблок (Пельтье) | Thermal block (Peltier) | C3 |
| 4 | Qo‘zg‘atuvchi nur manbai | Источник возбуждающего света | Excitation light source | C4 |
| 5 | Qo‘zg‘atish filtri (kanal tanlash) | Фильтр возбуждения (выбор канала) | Excitation filter (channel selection) | C5 |
| 6 | Termoblokdagi reaksiya probirkasi | Реакционная пробирка в термоблоке | Reaction tube in the block | C6 |
| 7 | Nurlanish filtri | Эмиссионный фильтр | Emission filter | C7 |
| 8 | Detektor | Детектор | Detector | C8 |
| 9 | Dastur (kuchayish egri chiziqlari) | Программа (кривые амплификации) | Software (amplification curves) | C9 |
<!-- /auto:parts-list -->

### 5.3 Namuna qanday kiritiladi

Manbaga ko‘ra, namunadan avval nuklein kislota ajratib olinadi; RNK avval teskari transkriptaza bilan kDNKga
aylantiriladi [L3, L2]. Umumiy tamoyil bo‘yicha, reaksiya aralashmasi solingan probirkalar termoblokka qo‘yiladi va
isitiladigan qopqoq bilan yopiladi [C1, C2, C3].

### 5.4 Ichkarida nima bo‘ladi

Manbaga ko‘ra, qizdirish zanjirlarni ajratadi, sovutishda praymerlar birikadi, issiqqa chidamli polimeraza yangi
zanjir quradi va har siklda nishon taxminan ikki barobar ko‘payadi [L2, PR]. Umumiy tamoyil bo‘yicha, haroratni
termoblok almashtiradi [C3].

### 5.5 Signal qanday o‘lchanadi

Manbaga ko‘ra, detektor har siklda fluoressensiyani o‘lchaydi, signal amplikon to‘planishiga mutanosib va real vaqtda
kuzatiladi [C8, L4]. Umumiy tamoyil bo‘yicha, qo‘zg‘atuvchi nur filtr orqali termoblokdagi probirkaga tushadi,
probirkadagi bo‘yoq yoki zond fluoressensiya chiqaradi, nurlanish filtri uni qo‘zg‘atuvchi nurdan ajratib detektorga
o‘tkazadi [C4, C5, C6, C7]. Sxemada manba turi, filtr tuzilishi va o‘qish yo‘nalishi ko‘rsatilmaydi — ular apparatga
qarab farq qiladi.

### 5.6 Natija qanday olinadi

Manbaga ko‘ra, dastur kuchayish egri chiziqlari, chegara chizig‘i va Cq qiymatlarini hisoblaydi; Cq qancha kichik
bo‘lsa, boshlang‘ich nishon shuncha ko‘p; miqdoriy testlarda konsentratsiya standartlar bo‘yicha hisoblanadi [C9, L5,
RS]. Klinik talqin bu dars doirasidan tashqarida — ilovadagi test kartalarida manbali cheklovlar bilan.

## 6. Keng tarqalgan xatolar, xavfsizlik va QC

- Ifloslanish: PZR o‘ta sezgir, ozgina ifloslanish soxta natija beradi [L7]; oldini olish — alohida PCR zonasi,
  himoya vositalari, ultrabinafsha nurli laminar shkaf, ajratilgan jihozlar, amplifikatsiyadan keyingi ishni boshqa
  stolda bajarish [L6]. Ilovada: `/lab/instruments/lc/a1-realtime-pcr-method` (“Sifat nazorati va kalibrlash”).
- Ingibitorlar (geparin, gemoglobin, proteinaza K qoldig‘i va boshqalar) kuchaytirishni susaytiradi [L8] —
  `/lab/instruments/lc/a3-mol-realtime-pcr-platform` (“Preanalitik va analitik xatolar”).
- Amplifikatsiya yo‘qligini “manfiy” deb yakuniy xulosa qilish — manbaga zid [L7].
- Avtomat tizimlarda har namunaga ichki nazorat qo‘shiladi; asbobni kalibrlash tartibi manbalarda berilmagan [L9].
- Preanalitika (namuna olish, tashish) umumiy qoidalari — `/lab/preanalytics`.

## 7. O‘z-o‘zini tekshirish savollari

1. Bir siklning uch bosqichi qaysilar? Javob: qizdirishda zanjirlar ajraladi, sovutishda praymerlar birikadi,
   polimeraza yangi zanjir quradi [L2].
2. RNK nishon bo‘lsa, PCR dan oldin nima qilinadi? Javob: teskari transkriptaza bilan kDNKga aylantiriladi [L2].
3. Cq nima va u boshlang‘ich nishon miqdori bilan qanday bog‘liq? Javob: fluoressensiya chegaradan o‘tgan sikl; Cq
   qancha kichik bo‘lsa, nishon shuncha ko‘p [L5].
4. Nega amplifikatsiyaning yo‘qligi manfiy natijaning yakuniy isboti emas? Javob: manba shunday ogohlantiradi,
   masalan, ingibitorlar kuchaytirishni susaytirishi mumkin [L7, L8].
5. Ifloslanishning oldini olishning ikkita chorasini ayting. Javob: alohida PCR zonasi, ajratilgan jihozlar [L6].

## 8. Epistemik holat

Qoida (to‘liq — [README](README.md#epistemik-qoida)): SOURCED — catalog.json manba id si va joyi;
STANDARD_TEXTBOOK — darslik darajasidagi umumiy tamoyil; NEEDS_EXPERT — aniqlik yoki raqam mutaxassis
tasdig‘ini kutadi. STANDARD_TEXTBOOK va NEEDS_EXPERT bayonotlar diktor matnida faqat “umumiy tamoyil bo‘yicha”
darajasida aytiladi, aniq model xususiyati sifatida emas. Mutaxassis ko‘rigi: EXPERT_REVIEW_PENDING.
Ataylab aytilmaydi: sikl harorati va davomiyligi, sikllar soni, Cq qiymatlari, bo‘yoq/zond nomlari, OIV toifalari
chegaralari (ular ilovadagi test kartasida manbasi bilan). Sxemadagi signal yo‘li darslik darajasida va soddalashtirilgan (2026-10-25 tuzatilgan: nur probirkadan o‘tadi) —
[README → Topilmalar](README.md#topilmalar) F2, F9.

### 8.1 Sxema qismlari (avtomatik, `parts_src.py` dan)

<!-- auto:epistemic-parts real_time_pcr -->
| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| C1 | PCR probirkalari (qator) — Reaksiya aralashmasi va namuna; shaffof qopqoq orqali o‘qiladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `real_time_pcr` #1 |
| C2 | Isitiladigan qopqoq — Probirka qopqoqlarida bug' to‘planishining oldini oladi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `real_time_pcr` #2 |
| C3 | Termoblok (Peltye) — Denaturatsiya, praymer birikishi va sintez haroratlarini tez almashtiradi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a1-sp-pcr`; `schematic_parts.json` → `real_time_pcr` #3 |
| C4 | Qo‘zg‘atuvchi nur manbai — Bo‘yoq yoki zondni qo‘zg‘atadigan nur beradi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `real_time_pcr` #4 |
| C5 | Qo‘zg‘atish filtri (kanal tanlash) — Har bir bo‘yoq kanali uchun kerakli qo‘zg‘atuvchi nurni ajratadi. | NEEDS_EXPERT | parts_src: TB; filtr g‘ildiragi — optik dizaynlardan biri, manbasiz; `schematic_parts.json` → `real_time_pcr` #5 |
| C6 | Termoblokdagi reaksiya probirkasi — Qo‘zg‘atuvchi nur probirkadagi bo‘yoq yoki zondga tushadi; u amplikon miqdoriga mutanosib fluoressensiya chiqaradi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); qisman manba: `a1-sp-pcr`; `schematic_parts.json` → `real_time_pcr` #6 |
| C7 | Nurlanish filtri — Faqat bo‘yoq chiqargan fluoressent nurni o‘tkazadi, qo‘zg‘atuvchi nurni to‘sadi. | STANDARD_TEXTBOOK | parts_src: TB (darslik, mutaxassis tasdig‘isiz); `schematic_parts.json` → `real_time_pcr` #7 |
| C8 | Detektor — Probirkalardan kelgan fluoressensiyani har siklda o‘lchaydi. | SOURCED | `a1-sp-pcr`; `schematic_parts.json` → `real_time_pcr` #8 |
| C9 | Dastur (kuchayish egri chiziqlari) — Egri chiziqlar, chegara chizig‘i va Cq qiymatlarini hisoblaydi. | SOURCED | `a1-sp-pcr`; `schematic_parts.json` → `real_time_pcr` #9 |
| PR | Termoblok har siklda haroratni almashtiradi: qizdirish DNK zanjirlarini ajratadi, sovutishda praymerlar birikadi, issiqqa chidamli polimeraza yangi zanjir quradi — nishon har siklda taxminan ikki barobar ko‘payadi (RNK avval teskari transkriptaza bilan kDNK ga aylantiriladi). Optik modul har siklda interkalyatsiyalanuvchi bo‘yoq yoki zond fluoressensiyasini o‘lchaydi; signal amplikon to‘planishiga mutanosib. | SOURCED | `a1-sp-pcr`; `schematic_parts.json` → `real_time_pcr`.principle |
| RS | Kuchayish egri chiziqlari va har namuna uchun Cq (Ct) — fluoressensiya chegarani kesib o‘tgan sikl; Cq qancha past bo‘lsa, boshlang‘ich nishon shuncha ko‘p. Miqdoriy testlarda konsentratsiya standartlar bo‘yicha hisoblanadi (masalan, OIV-1 virus yuklamasi, nusxa/ml). | SOURCED | `a1-sp-pcr`, `a3-fda-cobas-hiv1`; `schematic_parts.json` → `real_time_pcr`.result |
<!-- /auto:epistemic-parts -->

### 8.2 Dars bayonotlari

| ID | Bayonot (uz) | Teg | Manba va joyi |
|---|---|---|---|
| L1 | Termosiklator va fluoressensiyani har siklda o‘lchaydigan optik detektor; interkalyatsion bo‘yoqlar yoki ketma-ketlikka xos zondlar ishlatiladi; yirik avtomat tizimlar ekstraksiya, kuchaytirish va aniqlashni birlashtiradi. | SOURCED | `a1-sp-pcr`, `a3-fda-cobas-hiv1`; catalog.json lab_cards[a3-mol-realtime-pcr-platform].technology |
| L2 | Qizdirish zanjirlarni ajratadi, sovutishda praymerlar bog‘lanadi, issiqqa chidamli polimeraza yangi zanjir quradi; har siklda nishon taxminan ikki barobar ko‘payadi. RNK avval teskari transkriptaza bilan kDNKga aylantiriladi. | SOURCED | `a1-sp-pcr`; catalog.json lab_cards[a1-realtime-pcr-method].principle |
| L3 | Namunadan avval nuklein kislota ajratib olinadi. | SOURCED | `a1-sp-pcr`; catalog.json lab_cards[a1-realtime-pcr-method].specimens |
| L4 | Fluoressent signal amplikon to‘planishiga proporsional bo‘lib, reaksiya davomida real vaqtda kuzatiladi; PZR tugagandan keyingi qayta ishlash talab qilinmaydi. | SOURCED | `a1-sp-pcr`; catalog.json lab_cards[a3-mol-realtime-pcr-platform].principle |
| L5 | Asosiy natija — fluoressensiya belgilangan chegaradan o‘tgan kvantlash sikli (Cq); Cq qancha kichik bo‘lsa, boshlang‘ich nishon shuncha ko‘p. | SOURCED | `a1-sp-pcr`; catalog.json lab_cards[a3-mol-realtime-pcr-platform].tasks |
| L6 | Ifloslanishni oldini olish: alohida PCR zonasi, shaxsiy himoya vositalari, UV nurli laminar shkaf, ajratilgan jihozlar, pozitiv siljituvchi pipetkalar, amplifikatsiyadan keyingi ishni boshqa stolda bajarish. | SOURCED | `a1-sp-pcr`; catalog.json lab_cards[a1-realtime-pcr-method].qc_calibration_note |
| L7 | Juda yuqori sezgirlik tufayli ozgina ifloslanish soxta natija berishi mumkin; amplifikatsiyaning yo‘qligi namuna manfiy ekanini ishonchli isbotlamaydi. | SOURCED | `a1-sp-pcr`; catalog.json lab_cards[a1-realtime-pcr-method].limitations |
| L8 | PZR ingibitorlari (geparin, gemoglobin, proteinaza K qoldig‘i, ionli detergentlar va boshqalar) kuchaytirishni susaytiradi. | SOURCED | `a1-sp-pcr`; catalog.json lab_cards[a3-mol-realtime-pcr-platform].preanalytic_analytic_errors |
| L9 | Avtomat tizimlarda har namunaga ichki nazorat qo‘shilib, ekstraksiya va kuchaytirish jarayoni kuzatiladi; asbobni kalibrlash tartibi bu manbalarda berilmagan. | SOURCED | `a3-fda-cobas-hiv1`; catalog.json lab_cards[a3-mol-realtime-pcr-platform].qc_calibration_note |
| L10 | OIV-1 virus yuki — real vaqt RT-PCR bilan miqdoriy aniqlash; boshlang‘ich darajani o‘lchash va antiretrovirus terapiya davomida kuzatish uchun. | SOURCED | `a3-fda-cobas-hiv1`; catalog.json lab_cards[hiv-rna-viral-load].tasks |
