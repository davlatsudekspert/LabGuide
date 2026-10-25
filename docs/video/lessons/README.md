# Apparat sinflari bo‘yicha ilmiy video-dars rejalari (2026-10-25)

**Bu — REJALAR va STORYBOARDLAR, tayyor videolar emas.** Har dars uchun: o‘quv maqsadlari, auditoriya,
davomiylik, sahnalar jadvali (ilovaning original SVG sxemasi, raqamli belgilar, animatsiya g‘oyasi, o‘zbekcha diktor
matni, EN/RU atamalar, soniya), olti majburiy bosqich, xatolar/xavfsizlik/QC havolalari, o‘z-o‘zini tekshirish
savollari va epistemik jadval. Faqat ikki dars uchun **ishlaydigan namunaviy animatsiya** bor (ovozsiz, subtitrli
MP4) — [SAMPLES.md](SAMPLES.md). Holat: **EXPERT_REVIEW_PENDING** — hech bir dars mutaxassis tomonidan ko‘rilmagan.

Qamrov: ilovadagi 32 ta sxema kaliti (`tool/illustrations/schematic/gen.py`, `docs/SCHEMATICS_PROVENANCE.md`) —
29 ta dars; yaqin sinflar birlashtirilgan: biokimyo analizatori + fotometr, 5 va 3 qismli gematologiya, siydik
test-chizig‘i + siydik tizimi. Har kalitning har raqamli belgisi storyboardda kamida bir marta ko‘rsatiladi
(`lessons.py check` tekshiradi).

## Darslar ro‘yxati

Sahnalar soni, davomiylik va teglar soni har fayldan **hisoblanadi** (`python3 tool/video/lessons/lessons.py build`);
teglar — 8-bo‘limdagi barcha qatorlar (8.1 sxema qismlari avtomatik + 8.2 dars bayonotlari).

<!-- auto:index -->
| # | Dars (fayl) | Sxema kalit(lar)i | Sahna | Davomiylik | SOURCED | STANDARD_TEXTBOOK | NEEDS_EXPERT |
|---|---|---|---|---|---|---|---|
| 1 | [01 — Gaz xromatografi–mass-spektrometr (GC-MS)](01_gc_ms.md) | `mass_spec_gc` | 13 | 4:04 | 8 | 9 | 1 |
| 2 | [02 — Suyuqlik xromatografi–mass-spektrometr (LC-MS; LC-MS/MS haqida eslatma)](02_lc_ms.md) | `mass_spec_lc` | 13 | 3:52 | 10 | 7 | 2 |
| 3 | [03 — MALDI-TOF mass-spektrometr (mikroorganizmlarni identifikatsiya qilish)](03_maldi_tof.md) | `maldi_tof` | 13 | 3:40 | 12 | 4 | 0 |
| 4 | [04 — Real vaqt PCR (termosiklator va fluoressent detektsiya)](04_real_time_pcr.md) | `real_time_pcr` | 13 | 3:54 | 14 | 6 | 1 |
| 5 | [05 — Kartrijli yopiq molekulyar platforma (Xpert turidagi NAAT)](05_cartridge_molecular.md) | `cartridge_molecular` | 12 | 3:22 | 9 | 4 | 1 |
| 6 | [06 — ELISA planshet o‘quvchisi va yuvish qurilmasi](06_elisa_reader.md) | `elisa_reader` | 12 | 3:28 | 13 | 5 | 0 |
| 7 | [07 — Avtomatik biokimyoviy analizator va yarim avtomat fotometr](07_chemistry_photometer.md) | `chemistry`, `photometer` | 14 | 4:10 | 9 | 11 | 0 |
| 8 | [08 — Gematologik analizatorlar: 5 qismli va 3 qismli](08_hematology.md) | `hematology5`, `hematology3` | 14 | 4:06 | 7 | 10 | 1 |
| 9 | [09 — Immunokimyoviy (xemilyuminessent) analizator](09_immunoassay.md) | `immunoassay` | 12 | 3:26 | 6 | 5 | 0 |
| 10 | [10 — Siydik test-chizig‘i o‘quvchisi va avtomatik siydik tahlili tizimi](10_urine.md) | `urine_strip`, `urine_system` | 14 | 3:54 | 7 | 10 | 0 |
| 11 | [11 — Koagulometr (koagulyatsiya analizatori)](11_coag_analyzer.md) | `coag_analyzer` | 13 | 3:56 | 11 | 6 | 0 |
| 12 | [12 — Oqim sitometri](12_flow_cytometer.md) | `flow_cytometer` | 13 | 3:54 | 13 | 5 | 0 |
| 13 | [13 — Avtomatik mikrobiologik identifikatsiya va antibiotiklarga sezgirlik (ID/AST) tizimi](13_microbial_id_ast.md) | `microbial_id_ast` | 12 | 3:22 | 8 | 2 | 3 |
| 14 | [14 — Avtomatik qon ekmasi (gemokultura) tizimi](14_blood_culture.md) | `blood_culture` | 13 | 3:46 | 9 | 6 | 0 |
| 15 | [15 — Avtomatlashtirilgan mikobakteriya kultura tizimi (MGIT turidagi)](15_mycobacterial_culture.md) | `mycobacterial_culture` | 13 | 3:50 | 13 | 3 | 0 |
| 16 | [16 — Qon gazlari va elektrolit (ISE) analizatori](16_blood_gas_ise.md) | `blood_gas_ise` | 12 | 3:32 | 10 | 7 | 0 |
| 17 | [17 — HbA1c analizatori (usul jihatdan neytral sxema)](17_hba1c_analyzer.md) | `hba1c_analyzer` | 11 | 3:12 | 7 | 5 | 2 |
| 18 | [18 — LED floressent mikroskop (auramin bilan bo‘yalgan surtma)](18_fluorescence_microscope.md) | `fluorescence_microscope` | 13 | 3:36 | 9 | 7 | 0 |
| 19 | [19 — II sinf biologik xavfsizlik shkafi](19_bsc_class2.md) | `bsc_class2` | 12 | 3:30 | 11 | 5 | 0 |
| 20 | [20 — Avtoklav (bug‘ sterilizatori)](20_autoclave.md) | `autoclave` | 12 | 3:28 | 9 | 5 | 0 |
| 21 | [21 — Eritrotsitlar cho‘kish tezligi (EChT): Westergren usuli va avtomatik o‘quvchi](21_esr_analyzer.md) | `esr_analyzer` | 13 | 3:38 | 14 | 2 | 1 |
| 22 | [22 — Trombotsit agregometri (LTA) va viskoelastik testlar (TEG/ROTEM)](22_aggregometer.md) | `aggregometer` | 15 | 4:02 | 15 | 1 | 0 |
| 23 | [23 — Elektroforez qurilmasi (oqsil / gemoglobin elektroforezi)](23_electrophoresis.md) | `electrophoresis` | 13 | 3:40 | 13 | 1 | 1 |
| 24 | [24 — Osmometr (muzlash nuqtasi pasayishi usuli)](24_osmometer.md) | `osmometer` | 13 | 3:30 | 10 | 3 | 1 |
| 25 | [25 — Gel (mikrokolonka) kartali tizim va karta sentrifugasi](25_gel_card_system.md) | `gel_card_system` | 14 | 3:42 | 9 | 4 | 0 |
| 26 | [26 — Analitik tarozi: pipetkalarni gravimetrik kalibrlash](26_analytical_balance.md) | `analytical_balance` | 13 | 3:30 | 8 | 5 | 0 |
| 27 | [27 — Laboratoriya sovutkichi/muzlatkichi va harorat monitoringi](27_lab_fridge.md) | `lab_fridge` | 13 | 3:24 | 10 | 3 | 0 |
| 28 | [28 — Kompyuterli sperma tahlili tizimi (CASA)](28_casa.md) | `casa` | 14 | 3:44 | 8 | 5 | 1 |
| 29 | [29 — Yupqa qatlamli xromatografiya (TSX / TLC)](29_tlc.md) | `tlc` | 13 | 3:38 | 11 | 3 | 1 |
| | **Jami: 29 dars, 32 kalit** | | **375** | **106:50** | **293** | **149** | **16** |
<!-- /auto:index -->

## Har dars faylining tuzilmasi

Sarlavha (uz) + RU/EN sarlavha va kalit atamalar → holat, sxema kaliti va fayllari, ilovadagi karta →
1. O‘quv maqsadlari · 2. Maqsadli auditoriya · 3. Davomiylik (3–6 daqiqa) · 4. Storyboard
(`# | Ekranda (SVG / qatlam / belgilar) | Animatsiya g‘oyasi | Diktor matni (uz) | EN / RU atamalar | Bayonotlar | s`)
· 5. Olti majburiy bosqich (5.1 tashqi ko‘rinish, 5.2 asosiy qismlar — raqamli belgilar, 5.3 namuna qanday kiritiladi,
5.4 ichkarida nima bo‘ladi, 5.5 signal qanday o‘lchanadi, 5.6 natija qanday olinadi) · 6. Keng tarqalgan xatolar,
xavfsizlik va QC (faqat ilovada mavjud bo‘limlarga havola) · 7. O‘z-o‘zini tekshirish savollari (javob + bayonot ID)
· 8. Epistemik holat (8.1 avtomatik, 8.2 qo‘lda).

## Epistemik qoida

| Teg | Ma’nosi | Diktor matnida |
|---|---|---|
| SOURCED | `assets/instruments/catalog.json` `sources[].id` va joyi ko‘rsatilgan: `lab_cards[<id>].<maydon>` yoki `schematic_parts.json` qismi (manbasi `parts_src.py`, `docs/SCHEMATIC_PARTS_SOURCES.md`) | “Manbaga ko‘ra, …” |
| STANDARD_TEXTBOOK | Darslik darajasidagi umumiy tamoyil: `parts_src.py` da `TB` yoki qisman TB (aralash manba — ehtiyotkorlik bilan TB deb sanaladi) | faqat “Umumiy tamoyil bo‘yicha, …” |
| NEEDS_EXPERT | Raqamli TB matn (avtomatik), aniq dizayn yoki noaniq ibora (qo‘lda, `lessons.py` `NEEDS_EXPERT_OVERRIDES`), yoki manbasiz mavzu | faqat “Umumiy tamoyil bo‘yicha” darajasida yoki umuman aytilmaydi |

Qoidalar (barchasi `lessons.py check` bilan avtomatik tekshiriladi):

- Diktor matni, bosqich matni, xato bandi yoki javob STANDARD_TEXTBOOK/NEEDS_EXPERT bayonotga tayansa — matnda
  “umumiy tamoyil bo‘yicha” iborasi bo‘lishi shart; “Manbaga ko‘ra” deyilgan joyda kamida bitta SOURCED bayonot
  keltirilgan bo‘lishi shart.
- **O‘ylab topilgan raqam yo‘q:** matndagi har raqam (harorat, vaqt, foiz, hajm) keltirilgan SOURCED bayonot
  matnida bo‘lishi shart; belgi raqamlari “3-belgi” ko‘rinishida yoziladi va hisobga olinmaydi; narx yo‘q.
- **Model xususiyati yo‘q:** ishlab chiqaruvchi/model nomi faqat SOURCED bayonotda bo‘lsa (masalan, CDC manbasidagi
  Xpert MTB/RIF misoli). Model kartalaridagi raqamli faktlar (unumdorlik va h.k.) ishlatilmaydi.
- **Klinik talqin yo‘q:** natija turi aytiladi, tashxis yoki chegara qiymatlari aytilmaydi (ular kartada manbasi bilan).
- SOURCED qatorlardagi `lab_cards[<id>].<maydon>` havolasi mavjudligi va o‘sha maydon manbasi qatorda ko‘rsatilgani,
  manba id lari `catalog.json` da borligi tekshiriladi; `/lab/...` havolalari mavjud marshrutlar bilan solishtiriladi.
- Hech narsa “mutaxassis tasdiqlagan” deb belgilanmaydi; holat doim EXPERT_REVIEW_PENDING.
- Cheklov: tekshiruv ID keltirilgan matnni nazorat qiladi; ID siz gaplar (kirish, “endi o‘zingizni tekshiring”) qo‘lda
  ko‘rib chiqilgan — ularda texnik da’vo yo‘q.

```sh
python3 tool/video/lessons/lessons.py build   # avtomatik bloklar + shu jadval
python3 tool/video/lessons/lessons.py check   # faqat tekshiruv (xato bo‘lsa exit 1)
```

## Ishlab chiqarish ro‘yxati (checklist)

1. [ ] Mutaxassis ko‘rigi: har darsning 8-bo‘limi (ayniqsa STANDARD_TEXTBOOK va NEEDS_EXPERT qatorlari) va
   “Topilmalar” F1–F12; natija `docs/EXPERT_SIGNOFF_REGISTRY.md` tartibida yoziladi — ungacha holat
   EXPERT_REVIEW_PENDING.
2. [ ] Topilmalar bo‘yicha egasi qarori (sxema/qism matnini tuzatish — alohida ish, bu topshiriqda tahrir qilinmagan).
3. [ ] Diktor matnini o‘qib chiqish (uslub, talaffuz, atamalar `docs/L10N_TERMINOLOGY_DECISIONS.md` bilan).
4. [ ] Ovoz: o‘zbek tilidagi diktor yozuvi yoki TTS (quyida “Yetishmayotgan vositalar”); har sahna soniyasi ovozga
   moslab qayta hisoblanadi.
5. [ ] RU/EN: atamalar qatori bor; to‘liq ru/en diktor matni yo‘q — tarjima va `docs/L10N_REVIEW_QUEUE.md`.
6. [ ] Animatsiya: qolgan 27 dars uchun `tool/video/lessons/anim_<id>.js` + `sample_<id>.json` (namunadagi pleyer va
   render bilan) yoki boshqa vosita; faqat epistemik jadvaldagi darslik/manba darajasidagi jarayon ko‘rsatiladi.
7. [ ] Render → kadrlarni ko‘zdan kechirish (matn sig‘ishi, belgilar, “aniq model emas” yorlig‘i) →
   `report_samples.py` (davomiylik, hajm, sha256).
8. [ ] Ilovaga joylash: `HowToContent.videoUrl` faqat havola sifatida (`docs/video/PLAN.md`); pleyer bog‘liqligi
   qo‘shilmaydi.

## Yetishmayotgan vositalar (halol)

| Kerak | Holat |
|---|---|
| Diktor ovozi (uz) | Ovoz aktyori yo‘q. Repoda `tool/video/uz_tts_chatterbox.py` bor, lekin u tashqi ochiq model va og‘irliklarini talab qiladi — bu muhitda yo‘q va ishlatilmadi. Pullik xizmat ishlatilmaydi |
| Animatsiya vositasi | Ixtisoslashgan animatsiya dasturi yo‘q. Ishlaydigan quvur bor: original SVG + JS animatsiya → Playwright Chromium → ffmpeg (`tool/video/lessons/`); lekin har dars uchun alohida animatsiya skripti yozilishi kerak — hozir faqat 2 ta |
| Mutaxassis | Klinik laboratoriya mutaxassisi ko‘rigi o‘tkazilmagan |
| RU/EN diktor matni | Faqat sarlavha va kalit atamalar; to‘liq tarjima yo‘q (namunalarda subtitrlar uz/ru/en bor, ko‘rib chiqilmagan) |
| Musiqa/ovoz effektlari | Yo‘q (rejalashtirilmagan) |

## Topilmalar

Sxema va qism matnlaridagi mumkin bo‘lgan xato va noaniqliklar. **Hech biri tahrir qilinmadi** (`lib/`, ARB,
`catalog.json`, `parts_src.py`, SVG/PNG o‘zgarmagan) — qaror egasi va mutaxassisga. Darslarda bu joylar diktor
matnida aytilmaydi yoki “umumiy tamoyil bo‘yicha” darajasida yumshatilgan.

| # | Joy | Topilma | Nega muhim | Taklif | Darsda qanday hal qilindi |
|---|---|---|---|---|---|
| F1 | `mass_spec_lc` (sxema, `a3-tox-lc-ms` karta) | Topshiriqda “LC-MS/MS”, lekin karta va uning yagona manbasi (`a3-statpearls-ms`) faqat umumiy LC-MS ni yoritadi; kartaning o‘zi “tandem (MS/MS) tafsilotlari manbada yo‘q” deydi; sxemada bitta kvadrupol | “LC-MS/MS” nomi manbasiz tafsilotni (ikkinchi analizator, to‘qnashuv bo‘linmasi) taxmin qilishga undaydi | Nomni LC-MS da qoldirish yoki MS/MS uchun alohida manba qo‘shib, sxemani mutaxassis bilan yangilash | 02-dars “LC-MS; LC-MS/MS haqida eslatma”; MS/MS — `N1` (NEEDS_EXPERT), chizilmaydi |
| F2 | `real_time_pcr` sxemasi (optik modul kesigi) | Nur yo‘li: nur manbai (4) → filtr g‘ildiragi (5) → detektor (6); probirkalar/termoblok bu yo‘lda ko‘rsatilmagan | O‘quvchi fluoressensiya probirkada emas, modul ichida paydo bo‘ladi deb tushunishi mumkin | Qo‘zg‘atuvchi nur va nurlanish uyachalarga yetishini sxematik ko‘rsatish yoki “soddalashtirilgan” izoh (mutaxassis bilan) | Animatsiya nurni probirkaga “chizmaydi”; 04-dars 8-bo‘limida eslatma TUZATILDI (2026-10-25): sxema va animatsiyada nur yo‘li manba → qo‘zg‘atish filtri → termoblokdagi probirka → nurlanish filtri → detektor (belgilar 4–8); manba turi va o‘qish yo‘nalishi ko‘rsatilmaydi. |
| F3 | `coag_analyzer` #4 nomi “O‘lchash kyuvetalari (37 °C)” va prinsip matni | Harorat qism nomida, lekin qism manbasi `STANDARD_TEXTBOOK (NEEDS_EXPERT)`; prinsip ham qisman TB | Ilovada raqam manbasiz fakt sifatida ko‘rinadi | `a1-sp-pt` da tasdiqlansa — manba id sini qo‘shish; aks holda raqamni olib tashlash | `C4`, `PR` — NEEDS_EXPERT (avtomatik); diktor harorat aytmaydi TUZATILDI (2026-10-25): qism nomi va prinsipdan “37 °C” olib tashlandi. |
| F4 | `mass_spec_gc` #9 “Vakuum nasoslari” | “…ionlar havo molekulalariga urilmaydi” — mutlaq ibora; nasos turlari manbasiz | To‘qnashuvlar kamayadi, yo‘qolmaydi | “…havo molekulalari bilan kam to‘qnashadi” | `C9` — NEEDS_EXPERT (qo‘lda); diktor “kam to‘qnashadi”, hedge bilan | — **TUZATILDI (2026-10-25, parts_src.py): «…ionlarning havo molekulalari bilan to‘qnashuvi kamayadi»; nasos turlari hali NEEDS_EXPERT**
| F5 | `osmometer` prinsipi (parts_src) va `a3-bio-osmometer` karta prinsipi | “1 mol erigan modda suvning muzlash nuqtasini taxminan 1,86 °C ga pasaytiradi” | Krioskopik doimiy 1 kg suvdagi 1 mol erigan **zarracha** (1 osmol/kg) uchun; dissotsilanuvchi moddada (masalan, NaCl) pasayish taxminan ikki barobar | “1 kg suvda 1 mol erigan zarracha (1 osmol/kg) …” — manba matni bilan solishtirib | `PR` — NEEDS_EXPERT; diktor raqamni aytmaydi TUZATILDI (2026-10-25): sxema prinsipi va karta prinsipi “1 kg suvdagi 1 mol erigan zarracha (1 osmol)”, elektrolitlarda dissotsiatsiya, natija mOsm/kg (osmolyarlik — mOsm/l); “1 kg suvga” qismi darslik darajasi (NEEDS_EXPERT). |
| F6 | `tlc` #8 “UB nuridagi dog‘lar” | “Moddalar fluoressensiyani so‘ndiradi…” | Faqat 254 nm da nur yutadigan moddalar so‘ndiradi; shuning uchun reagent purkash ham bor | “UB nurini yutadigan moddalar…” | Diktor shunday aytadi, hedge bilan |
| F7 | `microbial_id_ast` #3 va prinsip | “Vakuum suspenziyani somon orqali karta quduqchalariga tortadi” — muayyan dizayn, manbasiz | Model xususiyati sinf tamoyili sifatida ko‘rinadi | Manba qo‘shish yoki umumlashtirish | `C3` — NEEDS_EXPERT; diktor “aniq mexanizm manbada yo‘q” deydi |
| F8 | `cartridge_molecular` #2 “Reaksiya naychasi” | Kartrij ichki tuzilmasi manbasiz | Muayyan dizayn sinf tamoyili sifatida | Manba yoki umumlashtirish | `C2` — NEEDS_EXPERT |
| F9 | `real_time_pcr` #5 “Filtr g‘ildiragi” | Optik dizaynlardan biri, sinf uchun yagona emas, manbasiz | Hamma apparatda g‘ildirak bor degan taassurot | “filtrlar (masalan, filtr g‘ildiragi)” | `C5` — NEEDS_EXPERT, hedge bilan TUZATILDI (2026-10-25): filtr g‘ildiragi o‘rniga umumiy qo‘zg‘atish va nurlanish filtrlari (tuzilishi ko‘rsatilmaydi). |
| F10 | Teg nomuvofiqligi: `blood_culture` #4 (“har o‘n daqiqada”), `esr_analyzer` prinsipi (2,5 mm), `casa` prinsipi (kamida 200 ta iz) | parts_src da qisman TB, lekin xuddi shu fakt lab kartasida manbali (`a1-fda-k173873`, `a3-statpearls-esr`, `a2-who-semen6`) | Avtomatik teglash ularni ortiqcha ehtiyotkor sanaydi | parts_src manbalarini kartadagi manba bilan moslash (egasi qarori) | Darslarda shu faktlar lab karta qatori (`L…`, SOURCED) orqali keltirilgan |
| F11 | `gel_card_system` sxemasi | Uchinchi mikronaychada hujayralar ustun bo‘ylab tarqoq (oraliq/aralash ko‘rinish), qismlar ro‘yxatida izohsiz | Talaba savol beradi; talqin manbada yo‘q | Izoh qo‘shish yoki chizmani ikki holat bilan cheklash (mutaxassis) | Darsda bu naycha tilga olinmaydi |
| F12 | `mass_spec_gc` #1, `mass_spec_lc` #8 | “odatda geliy”, “turbomolekulyar va forvakuum” — TB, aniqlik mutaxassisni kutadi | Kichik | Mutaxassis tasdig‘i | Hedge bilan yoki aytilmaydi |

Kuzatuv (xato emas): ayrim yo‘nalish kartalarida QC/biologik xavfsizlik bo‘limlari bo‘sh (“Hali kiritilmagan”,
masalan, `tb-genexpert-platform`) — darslar ularni to‘qimaydi, faqat mavjud bo‘limlarga havola beradi.

## Fayllar

- Darslar: `docs/video/lessons/01_gc_ms.md` … `29_tlc.md`; namunalar: [SAMPLES.md](SAMPLES.md).
- Skriptlar: `tool/video/lessons/lessons.py` (avtomatik bloklar, tekshiruv, indeks), `player.html`,
  `render_sample.cjs`, `anim_gc_ms.js`, `anim_real_time_pcr.js`, `sample_gc_ms.json`, `sample_real_time_pcr.json`,
  `report_samples.py`.
- Video chiqishi: `build/lesson_samples/` (gitignore).
