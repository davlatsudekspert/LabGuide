# Koagulogramma bo‘limi: manbalar, tekshirilmaganlar

Sana: 2026-10-18. Kod: `lib/features/coagulogram/` (`coag_content.dart` — matn va manbalar,
`coag_logic.dart` — ISTH DIC bali, PT/APTT birikmasi, sitrat formulasi, `coag_screens.dart`).
Yo‘l: `/lab/coagulogram` (`tests`, `sample`, `reader`, `dic`, `monitoring`). Karta sxemasi:
`tool/illustrations/coagulogram/gen_coagulogram.py` → `tool/illustrations/render_card.cjs` →
`assets/coagulogram/card.png` (sitrat probirkasi va sekundomer; matnsiz). Testlar:
`test/unit/coagulogram_logic_test.dart`, `test/widget/coagulogram_test.dart`. Qaror: D-61.

Holat (D-65): sahifa boshida «Manbalar» paneli (`cgLeadRefs`) va tibbiy eslatma. Har sahifada «tashxis emas» eslatmasi.
Bog‘liq: pack kartalari `pt-inr`, `aptt`, `fibrinogen`, `d-dimer`, `coagulation-factors`, `protein-c-s`
(havola, nusxa emas); amaliy protokol `gemostaz-uchun-venoz-qon-olish`.

## 1. Manbalar (hammasi shu sessiyada ochib o‘qildi)

| Kod | Manba | Qanday o‘qildi |
|---|---|---|
| WFH p3 | Hickey K. Sample integrity and preanalytical variables. In: de Lima Montalvão S, Kitchen S (eds). *Diagnosis of Hemophilia and Other Bleeding Disorders: A Laboratory Manual*, 3rd ed. WFH, 2025, Part 3. https://www1.wfh.org/publications/files/pdf-2537.pdf | PDF to‘liq (21–23-betlar) |
| WFH p5 | Khasiani A. Initial evaluation of hemostasis. O‘sha qo‘llanma, Part 5. https://www1.wfh.org/publications/files/pdf-2550.pdf | PDF to‘liq (31–43-betlar) |
| Magnette | Magnette A va boshq. Pre-analytical issues in the haemostasis laboratory. *Thromb J* 2016. doi:10.1186/s12959-016-0123-z (PMC5154122, ochiq) | Europe PMC to‘liq matni; lokator = bo‘lim/jadval |
| Toh | Toh CH, Alhamdi Y, Abrams ST. *Ann Lab Med* 2016. doi:10.3343/alm.2016.36.6.505 (PMC5011102, ochiq) | To‘liq matn, 1-jadval (ISTH mezonlari) |
| Iba | Iba T va boshq. *J Clin Med* 2019. doi:10.3390/jcm8050728 (PMC6572234, CC BY) | To‘liq matn, 1-jadval |
| Wada | Wada H va boshq. *J Intensive Care* 2014. doi:10.1186/2052-0492-2-15 (PMC4267589) | «Diagnosis of DIC» bo‘limi |
| CHEST OAC | Ageno W va boshq. Oral anticoagulant therapy, ACCP 9th ed. *Chest* 2012 (PMC3278051) | PMC sahifasi: 1.5, 1.8, 2.5, 3.5 bo‘limlar |
| CHEST PAR | Garcia DA va boshq. Parenteral anticoagulants, ACCP 9th ed. *Chest* 2012 (PMC3278070) | PMC sahifasi: 1.1.4, 1.2.3 bo‘limlar |
| MedlinePlus | PT/INR, PTT, D-dimer test sahifalari | Sahifa matni («What is it used for?», «What do the results mean?») |

Ochilmaganlar va sababi: **Taylor FB va boshq., Thromb Haemost 2001** (ISTH DIC balining asl maqolasi) —
Thieme sahifasi avtomat so‘rovlarni to‘sdi; mezonlar uni yozgan qo‘mita a’zosi Toh (2016) va Iba (2019)
jadvallaridan olindi, ikkalasi bir xil. **NCBI Bookshelf (StatPearls)** — reCAPTCHA bilan to‘sildi, ishlatilmadi.
**CLSI H21** — pullik; WFH va Magnette uni keltirgan joylarigina («WFH (CLSI 2024)» deb).

## 2. Da’vo → manba (asosiy)

| Da’vo | Manba, joy |
|---|---|
| PT: tashqi/umumiy yo‘l, V, VII, X ga sezgir, II ga kamroq; uzaytiruvchi holatlar; yengil yetishmovchilikda uzayish kam | WFH p5, PT, 32–33-b. |
| INR = (PT/MNPT)^ISI; INR muammolari (2-jadval); ISI < 1,7 tavsiyasi | CHEST OAC 1.5 |
| PT qo‘llanishi va natijalar | MedlinePlus PT/INR |
| APTT: VIII, IX, XI, XII skriningi; reagentlar; ellag kislotasi va PKK; VIII yuqori — IX/XI yashirinishi; tekshiruv tartibi | WFH p5, APTT, 34–35-b. |
| APTT qo‘llanishi, uzayish va qisqarish sabablari | MedlinePlus PTT |
| Aralashtirish testi, 8-jadval (VII — faqat PT; II, V, X — ikkalasi) | WFH p5, 36–38-b. |
| TT: sabablar, ~15 s nazorat misoli, 4 soat / 2 soat; protamin (2 s); reptilaza (10-jadval) | WFH p5, 39–41-b. |
| Clauss usuli; FDP va geparin ta’siri; PT-dan hisoblangan fibrinogen cheklovlari | WFH p5, 41–43-b. |
| Fibrinogen < 1 g/l: sezgirlik 22 %, o‘ziga xoslik 100 %; dinamika | Toh, 3) Fibrinogen level |
| D-dimer: nima, qo‘llanish, yuqori bo‘lish sabablari, antikoagulyant — soxta manfiy | MedlinePlus D-dimer |
| D-dimer testlari almashtirilmaydi; buyrak/jigar | Toh, 4) Fibrin-related markers |
| 3,2 % (0,105–0,109 mol/l) sitrat, bitta probirka turi; 3,8 % ta’siri | WFH p3, 21-b.; Magnette (Sample tubes…); CHEST OAC 1.5 |
| Igna 19–21G / 22–23G (Magnette 19–22G); jgut < 1 daqiqa | WFH p3; Magnette (Blood sampling) |
| Olish tartibi; «tashlab yuboriladigan» probirka | Magnette (Sequence of drawing blood); WFH p3 |
| To‘ldirish ≥ 80 % (WFH, ICSH 2021) va > 90 % (Magnette); 89/78/67 % ma’lumoti | WFH p3; Magnette (Filling the tubes) |
| Ht > 55 %: C = 1,85·10⁻³ × (100 − Ht) × V; misol 70 %, 4,5 ml → 0,25 ml | WFH p3, 21–22-b. |
| Aralashtirish 3–6 (WFH 3–5) marta; tashish 15–25 °C, ≤ 1 soat; sovutmaslik | Magnette (Mixing; Transportation; Storage) |
| Sentrifuga: 1500 g ≥ 15 daqiqa (Magnette) va > 1700 g 10 daqiqa (WFH); ikki marta < 10×10⁹/l | Magnette (Centrifugation); WFH p3, 22-b. |
| 4 soat qoidasi; PT 24 soat; UFH 1 soat; plazma saqlash, eritish | WFH p3, 22-b.; Magnette (Storage) |
| Preanalitik xatolar (gemoliz, laxta, ifloslanish, sovutish, lipemiya, bemor omillari) | Magnette; WFH p3 |
| ISTH ochiq DIC bali mezonlari va ≥ 5 talqini | Toh 1-jadval; Iba 1-jadval |
| < 5 — non-overt DIC ga ishora; «me’yor» monitoringni to‘xtatmaydi; marker chegaralari laboratoriyada | Toh 1-jadval, 2) Composite scoring, 4) Fibrin-related markers |
| Bitta marker bilan tashxis qo‘yilmaydi | Toh 1. General principles; Wada «Diagnosis of DIC» |
| Trombotsitopeniya sabablari; PT + trombotsitopeniya jigar kasalligida | Toh 2) Platelet count; 4) Fibrin-related markers |
| VKA monitoringi, VII yarim umri; INR ≈ 2,0–3,0 | CHEST OAC 1.5, 1.8 |
| UFH: APTT 1,5–2,5 × (tasdiqlanmagan), mahalliy moslash, anti-Xa 0,3–0,7; LMWH — anti-Xa | CHEST PAR 1.1.4, 1.2.3 |
| Dabigatran va TT; rivaroksaban — PT/APTT bilan kuzatilmaydi | CHEST OAC 2.5, 3.5 |

## 3. Kiritilmaganlar va sababi

- **Me’yoriy oraliqlar raqamlari** (PT s, APTT s, fibrinogen g/l, D-dimer) — reagent/analizatorga bog‘liq;
  manbalar laboratoriya o‘z oralig‘ini tuzishini talab qiladi. Faqat manba misollari (TT ~15 s, Clauss 2,1 g/l
  standart emas — kiritilmadi).
- **Taylor 2001 dagi non-overt DIC bali** (dinamik mezonlar) — asl maqola ochilmadi.
- **JAAM, JMHLW, SIC ballari** — topshiriqda yo‘q; Iba/Wada tilga olgan, kiritilmadi.
- **PT uzayishi qaysi qiymatga nisbatan** (normal nazorat yoki yuqori chegara) — ochilgan jadvallarda yo‘q;
  ekranda ochiq aytiladi.
- **Bleeding time, PFA, lupus antikoagulyant testlari** — faqat zarur joyda tilga olinadi, alohida karta yo‘q.
