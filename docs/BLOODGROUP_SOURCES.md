# Qon guruhi bo'limi — manbalar va tekshiruv (2026-10-17)

Holat (D-65): har sahifada «Manbalar» paneli — `bgLeadRefs` (BSH 2012, JSST Module 3,
UK Handbook of Transfusion Medicine 2013) va tibbiy eslatma.
Ilovada har sahifada: "o'quv ma'lumotnomasi; laboratoriya SOP'i va me'yoriy talablar o'rnini
bosmaydi; transfuziya qarori mahalliy protokol bo'yicha". Naqsh o'qish mashqi — "faqat o'quv,
bemor uchun xulosa emas". Xatolar sahifasi — "nomuvofiqlik SOP bo'yicha hal bo'lmaguncha guruhga
xos qon berilmaydi".

Kod: `lib/features/bloodgroup/` (content, logic, screens), test: `test/widget/bloodgroup_test.dart`,
rasm: `tool/illustrations/bloodgroup/gen_bloodgroup.py` → `assets/bloodgroup/card.png`
(sxema: chapda erkin eritrotsitlar, o'ngda agglyutinatlar; matnsiz, mikrofoto emas).

## Manbalar (shu sessiyada ochilgan va o'qilgan)

| Kod | Manba | Qanday o'qildi |
|---|---|---|
| BSH | Milkins C et al. BCSH Guidelines for pre-transfusion compatibility procedures in blood transfusion laboratories. *Transfus Med* 2013;23:3–35, doi:10.1111/j.1365-3148.2012.01199.x | Jurnal PDF'i (thebloodproject.com nusxasi) to'liq matn; sahifalar jurnal raqami (PDF 1-bet = 3-bet). BSH sahifasi: e'lon 2012-12-06, oxirgi ko'rib chiqish 2017-04-25, addendum (tarixiy namuna) bor — addendum o'qilmagan. |
| WHO | WHO. Safe Blood and Blood Products. Module 3: Blood Group Serology (reprinted 2009) | who.int sahifasidagi CDN PDF to'liq matn; sahifa — kitobdagi bosma raqam (PDF − 9). |
| HTM | Norfolk D (ed). Handbook of Transfusion Medicine, 5th ed. UK Blood Services, TSO 2013 | Infected Blood Inquiry arxividagi PDF nusxa (RLIT0000812); 2.1–2.2 jadvallar sahifa rasmi bilan ko'zda tekshirildi (OCR buzuq edi). transfusionguidelines.org dagi onlayn versiya endi ochilmadi. |
| RU1134 | Приказ Минздрава России от 20.10.2020 № 1134н | legalacts.ru matni (п. 6–32 va ilova). legalacts: 2021-01-01 dan kuchda, 2027-01-01 gacha amal qiladi. |
| RU363 | Приказ Минздрава РФ от 25.11.2002 № 363 | legalacts.ru matni — **faqat atamalar uchun** (цоликлоны, гемагглютинирующие сыворотки, 0(I)…AB(IV) belgilanishi). Hozirgi kuchi tekshirilmagan; undan protsedura raqamlari olinmagan. |
| Hagman 2024 | Hagman JR et al. *Blood Transfus* 2024;22:106–110, doi:10.2450/bloodtransfus.584 (CC BY-NC-ND) | Europe PMC to'liq matn (PMC10920065), Introduction. |
| Trummer 2026 | Trummer P et al. *Front Immunol* 2026;17:1888597, doi:10.3389/fimmu.2026.1888597 (CC BY) | Europe PMC to'liq matn (PMC13504806), §2.2. |

Ochilmadi: NCBI Bookshelf/StatPearls (reCAPTCHA; Europe PMC kitob sahifasi 403), NZ Blood
Service qo'llanmasi (JS sahifa, matn chiqmadi), Immunohematology 2017 "Recognizing and resolving
ABO discrepancies" (pullik), AABB Technical Manual (yopiq). Ulardan hech narsa olinmagan.

## Da'vo → manba

### 1. ABO va RhD asoslari
| Da'vo | Manba, lokator |
|---|---|
| ABO — eng muhim serologik test | BSH §4.1.1, p. 8 |
| ABO nomos eritrotsit quyish ko'pincha o'limga olib keladi | HTM §2.4.1, p. 8 |
| A, B, AB, O — antigenlar | WHO §4.1, p. 26 |
| Plazmada yo'q antigenga qarshi antitelalar (Landshteyner qoidasi) | WHO §4.1 Table 2, p. 26; HTM §2.4 Table 2.1, p. 8; Hagman 2024 Introduction ("Landsteiner's rule") |
| Anti-A/anti-B asosan IgM, tabiiy, 3 oylikdan keyin hammada | HTM §2.3, p. 7 |
| Tug'ilganda antigenlar kuchsiz; antitelalar ~3 oylikkacha aniqlanmasligi mumkin; chaqaloqda faqat eritrotsit guruhi | WHO §4.4, p. 30 |
| Chaqaloqda teskari usul foydasiz — antitelalar onadan | BSH §4.3.1 ii, p. 9 |
| To'liq guruh = monoklonal anti-A, anti-B (to'g'ri) + A1 va B hujayralar (teskari) | BSH §4.3.1 i, p. 9 |
| Ikki usul bir-birini tasdiqlaydi; farq — xato signali, takrorlash | WHO §4.3, p. 29 |
| Teskari usul — ichki nazorat (transfuziya, HSCT, sovuq agglyutininlar) | BSH §4.1.3, p. 9 |
| Kutilgan reaksiyalar jadvali | WHO 101–102-betdagi mashq 6 va 8 javoblari (A cells o'rniga BSH bo'yicha A1 hujayralar); BSH §4.3.1 |
| Kross usul: anti-A, anti-B reagent + standart eritrotsitlar; chaqaloqda to'g'ri usul; RhD — anti-D IgM | RU1134 п. 11 |
| A1 ≈ 80%, A2 ≈ 20%; anti-A1 A2 da ~2%, A2B da ~25%; odatda kuchsiz; anti-A1 (Dolichos biflorus) faqat A1/A1B | WHO §4.5–4.6, Fig. 10–11, p. 30–31 |
| Расхождение (экстраагглютинин анти-A1) → анти-A1 bilan A2/A2B tasdig'i | RU1134 п. 11 |
| Anti-A,B — donorlar uchun, bemorlar uchun shart emas | WHO §4.6, p. 31 |
| RhD musbat/manfiy, D geni | WHO §5.2, p. 36–37 |
| Anti-D faqat sensibilizatsiyadan keyin, IgG, HTR va HDFN | HTM §2.5, p. 9–10; WHO §5.3, p. 38 |
| D antigeni homila davrida to'liq rivojlangan | WHO §5.2 (Development of the RhD antigen), p. 38 |
| Kuchsiz D va qisman D ta'riflari | WHO §5.4, p. 38–39 |
| Weak/partial D chegarasi noaniq; Fig. 1 algoritmi | BSH §4.7.1 vi, p. 12; Fig. 1, p. 10 |
| Guruh belgilari 0(I), A(II), B(III), AB(IV) (uz/ru) | RU363 §3.1, Таблица 1 |

### 2. Usullar
| Da'vo | Manba |
|---|---|
| Poliklonal → monoklonal (gibridoma) reagentlar; o'ziga xos, kuchli; faqat yo'riqnoma usulida; odatda 2–6 °C; blended | WHO §7.9, p. 79–80 |
| ABO/D reagentlari CE belgili, yo'riqnoma bo'yicha | BSH §2.3.1, p. 5 |
| "Цоликлоны", "гемагглютинирующие сыворотки" atamalari | RU363 §3.1 |
| Plastinka usuli: sezgirligi past, faqat dastlabki tez guruh, tasdiqlash tube/microplate'da; 2 daqiqa ichida o'qish | WHO §7.6 p. 77; §7.7 p. 79; Appendix 1 Technique 2, p. 127–128 |
| Probirka: bug'lanishsiz inkubatsiya; ABO — xona haroratidagi fiziologik eritma; anti-D turlicha (ba'zisi 37 °C) | WHO §7.6 p. 78; §7.13 p. 82 |
| Suspenziya odatda 2–3%, aniq bo'lishi shart | WHO §7.10, p. 80 |
| Mikroplanshet 96 chuqurcha, U-shakl | WHO §7.6, p. 78 |
| Gel-karta: 6 mikronaycha, gel/shisha sharcha, agglyutinat ushlanadi, manfiy — tugmacha; AHG yoki anti-A/anti-B kartalar | WHO §7.18, p. 87 |
| Karta teskari o'qilsa noto'g'ri guruh (O D− → AB D−) | BSH §4.2.2, p. 9; Fig. 2, p. 10 |
| Qattiq faza: eritrotsitlar yuzaga qotirilgan, anti-IgG qoplangan indikator eritrotsitlar | Trummer 2026 §2.2 |
| CAT va qattiq faza — mahalliy validatsiya | BSH §5.2.2, p. 13 |
| Agglyutinatsiya darajalari 4+…1+, −, L | WHO §7.8, p. 79 |
| Probirkada o'qish qadamlari (45 daqiqa cho'kish yoki yengil sentrifuga; oq fon; avval gemoliz; qiya silkitish; lupa ×2–×5; darhol yozish) | WHO §7.7, p. 79 |

### 3. Moslik
| Da'vo | Manba |
|---|---|
| Og'ir o'tkir gemolitik reaksiyalar — ABO nomos, ko'pincha identifikatsiya xatosi | WHO §6.3, p. 45 |
| Moslik tekshiruvi 4 bosqichi | WHO §6.1, p. 42 |
| Katta/kichik sinama ta'rifi; kichik sinama ko'pincha kerak emas | WHO §6.1, p. 42 |
| IAT sinamasi: ta'rif, standart usul, majburiy holatlar | BSH §7.3, p. 17–18 |
| Xona harorati + 37 °C IAT; agglyutinatsiya/gemoliz — nomos | WHO §7.21, p. 88–89 |
| Immediate spin: ABO uchun, kuchsiz anti-A/B da ishonchsiz, IgG ni aniqlamaydi, standart nazorat yo'q | BSH §7.4, p. 18 |
| Elektron berish shartlari va qo'llanmaydigan holatlar | BSH §7.5, p. 18–19; HTM §2.7.3, p. 11 |
| RF: shifokor nazorat tekshiruvi, plastinkada individual moslik, biologik sinama (15 daq, 2 mL/daq, krioprecipitatdan tashqari) | RU1134 п. 19, 23 |
| O "universal donor" va plazmadagi yuqori titrli anti-A/B; SAG-M < 20 mL plazma | HTM §2.4–2.4.1, p. 8 |
| O plazmaga boy komponentlar A/B/AB ga berilmaydi (mos bo'lsa) | HTM §2.4.1, p. 8; WHO §4.7, p. 32 |
| Bir xil ABO; A/B ga O; AB ga O dan oldin A yoki B | BSH §7.7, p. 19 |
| ABO mos eritrotsit/plazma jadvali | WHO Fig. 14–15, p. 45 |
| UK tanlov tartibi, yuqori titrga tekshirilgan zaxira variantlar | HTM Table 2.2, p. 9 (sahifa rasmi bilan tekshirildi) |
| RhD tanlash: JSST qoidasi; BSH istisnolari va doim D− guruhlar | WHO §6.3, p. 45; BSH §7.8, p. 19 |

### 4. Nomuvofiqlik va xatolar
| Da'vo | Manba |
|---|---|
| Anomaliya qon berishdan oldin hal qilinadi; shoshilinch — O guruh | BSH §4.8.1–4.8.2, p. 12 |
| To'g'ri/teskari tomondagi sabablar ro'yxati | BSH Appendix 3, Fig. A1, p. 28 |
| A/B variantlari kuchsiz/manfiy, ma'lumotnoma laboratoriyasi | BSH §4.7.1 iv, p. 12 |
| A2/A2B dagi anti-A1 qo'shimcha reaksiya | WHO §4.5, p. 31; Activity 10 javoblari, p. 103 |
| Aralash maydon sabablari; intrauterin transfuziya | BSH §4.7.1 i–ii, p. 12 |
| Sovuq alloantitela — yuqori harorat yoki antigensiz hujayra | BSH §4.7.1 iii, p. 12 |
| Kuchli sovuq autoantitela — diluent nazorati, iliq yuvish | BSH §4.4.10, p. 11 |
| Teskari usulni 37 °C da; 37 °C da gemoliz — DAT, shifokorga | WHO §7.14, p. 84 |
| Rulo: A/G nisbati, 1,5% gipertonik eritma, Varton dirildog'i, 37 °C eritmada yuvish | WHO §7.14, p. 83–84 |
| Orttirilgan B mexanizmi, A1 bemorlar, keksalik + kolorektal saraton, o'tkinchi, o'lim holati | Hagman 2024 Introduction |
| Anti-B reagenti orttirilgan B bilan reaksiya bermasligi kerak | BSH §4.2.4, p. 9 |
| Kuchsiz/yo'q antitelalar: chaqaloq, keksalik, immunodefitsit; kuchaytirish usullari; ikki to'g'ri usul bo'yicha guruh | BSH Fig. A1, p. 28 |
| Potentsiatorlar (PEG) — soxta musbat; diluent nazorati musbat → yaroqsiz; DAT, potentsiatorsiz takror, iliq yuvish; teskari hujayralarda anti-c | BSH §4.2.3 p. 9; §4.4.9 p. 11; Fig. A1; §4.7.1 v p. 12 |
| Reagent saqlash/standartlash, ifloslangan namuna, yomon texnika | WHO §7.14, p. 83–84 |
| Fiziologik eritma pH 6,5–7,5; pipetkadagi zardob qoldig'i | WHO §7.4–7.5, p. 76–77 |
| Hal qilish: tarix, takror test, yangi namuna, ma'lumotnoma lab.; natijani ikki marta mustaqil yozish | BSH Fig. A1, p. 28 |
| Tarixiy natijadan farq — darhol yangi namuna | BSH §4.6.2, p. 12 |
| Kuchsiz D reaksiyasi algoritmi (≤50 yosh ayol / doimiy transfuziya → D−, tasdiqlash) | BSH Fig. 1, p. 10; §4.8.4, p. 12–13 |
| Ma'lum qisman D — D manfiy | BSH §4.8.4 ii, p. 13 |
| Shoshilinch guruh: anti-A, anti-B, anti-D + nazorat yoki teskari; AB D+ ehtiyot; ikkinchi test; O guruh | BSH §8.4.3, §8.6.1–8.6.2, p. 23–24 |

### 5. Sifat va preanalitika
| Da'vo | Manba |
|---|---|
| Identifikatsiya/yorliq xatolari → ABO nomos transfuziya | BSH §3.1, p. 6 |
| Namuna yorlig'i; so'rovnoma bilan mos kelmasa qabul qilinmaydi | WHO §6.2, p. 42–43 |
| Namuna ma'lumotlarini kompyuter yozuvi bilan solishtirish | BSH §4.6.1, p. 12 |
| RF: namuna ≤ 24 soat oldin, yorliq tarkibi | RU1134 п. 7 |
| WBIT ≈ 1/2000; birinchi bemor uchun ikkinchi namuna | BSH §7.2.1, p. 17; Key recommendation 12, p. 4; HTM §2.7.1, p. 10 |
| Ikki namuna mustaqil olinadi | BSH Appendix 7, p. 29–30 |
| Vazifalarni ajratish; D ikki marta (xavfsiz avtomatika bo'lmasa); avtomatika afzal | BSH §4.5.4 p. 11; §4.3.2 i p. 10–11; §4.1.2 p. 9 |
| Reagent QC (JSST): ishga tushirishdan oldin, har seriya/kunda; mezonlar; ishlatilmaydigan holatlar | WHO §7.12, p. 81 |
| Reagent QC (BSH): seriyada, lot almashganda, analizator ishga tushganda, ≥ har 12 soat; nazorat xatosi | BSH §4.4, Table 2, p. 11 |
| Reagent qaydlari | WHO §7.11, p. 81; BSH §2.3.6, p. 6 |
| Audit izi | BSH §2.1.4, p. 5 |
| Namunani transfuziyadan keyin ≥ 3 kun saqlash ("at least 3 days post-transfusion") | BSH §3.9.2, p. 8 |
| RF: probirka va birlik qoldig'i (≥ 5 mL) 48 soat 2–6 °C | RU1134 п. 28 |

### 6. Mashq va naqsh o'qish
- 10 savol; har biri yuqoridagi da'volardan (naqsh savollari — WHO mashq 8 javoblari; nomuvofiqlik —
  WHO §4.3, BSH §4.8.1; 1+ — WHO §7.8; plastinka — WHO §7.7; chaqaloq — BSH §4.3.1, WHO §4.4;
  immediate spin — BSH §7.4; ikkinchi namuna — BSH §7.2.1; rulo — WHO §7.14).
- Naqsh o'qish mantig'i (`bloodgroup_logic.dart`): to'g'ri (anti-A, anti-B) va teskari (A1, B
  hujayralar) natija Landshteyner qoidasi bo'yicha solishtiriladi; mos kelmasa guruh **aytilmaydi**,
  ustun bo'yicha "antigen ham, antitela ham bor/yo'q" belgilanadi va BSH Fig. A1 sabablari
  ko'rsatiladi. Nazorat musbat → yaroqsiz (BSH §4.4.9). AB D+ va nazoratsiz → ogohlantirish
  (BSH §8.4.3). Kuchsiz anti-D → BSH Fig. 1 izohi.
- Tibbiy audit (2026-10-17) bo'yicha: anti-A/anti-B bilan **kuchsiz** reaksiya yoki **aralash maydon**
  (yangi tanlov; anti-D da ham) — anomaliya: ikki usul mos bo'lsa ham guruh **aytilmaydi**
  ("Anomaliya — guruh aytilmaydi"), takrorlash/tekshirish va ma'lumotnoma laboratoriyasi izohi
  (BSH §4.7.1 i, iv, p. 12; §4.8.1; Fig. A1, p. 28 — PDF matni qayta o'qildi).

## Atamalar (ruscha) — tekshiruv holati

| Atama | Holat |
|---|---|
| группа крови по системе AB0, резус-принадлежность | ✔ RU1134 matnida |
| перекрёстный метод (AB0) | ✔ RU1134 п. 11 ("перекрестным методом") |
| прямое и обратное определение | ✔ RU1134 п. 11 |
| стандартные эритроциты | ✔ RU1134 п. 11 |
| экстраагглютинин анти-A1, реактив анти-A1 | ✔ RU1134 п. 11 |
| непрямой антиглобулиновый тест | ✔ RU1134 п. 11, 14 |
| проба на индивидуальную совместимость, метод на плоскости, биологическая проба | ✔ RU1134 п. 19, 23 |
| цоликлоны, гемагглютинирующие сыворотки, непрямая проба Кумбса | ✔ RU363 §3–4 (2002, kuchi tekshirilmagan) |
| 0(I), A(II), B(III), AB(IV) | ✔ RU363 Таблица 1 |
| гелевые карты / колоночная агглютинация | ✘ rasmiy RF hujjatida tekshirilmadi (keng tarqalgan atama) |
| твердофазный метод | ✘ tekshirilmadi |
| «большая» / «малая» проба | ✘ tekshirilmadi — ilovada qo'shtirnoqda va izoh bilan |
| солевая проба с немедленным центрифугированием (immediate spin) | ✘ tekshirilmadi — tarjima-tavsif |
| электронная выдача (electronic issue) | ✘ tekshirilmadi — tarjima-tavsif |
| смешанное поле, полиагглютинабельность, монетные столбики, вартонов студень, приобретённый B | ✘ RF me'yoriy hujjatida tekshirilmadi |

O'zbekcha atamalar (kesishgan/kross usul, to'g'ri/teskari usul, tsoliklon, rulo va h.k.) rasmiy
o'zbek manbasi bilan solishtirilmagan. **O'zbekiston SSV me'yorlari umuman tekshirilmagan** —
ilovada RF buyrug'i faqat "MDH amaliyoti" misoli sifatida, manbasi bilan berilgan.

## Tekshirib bo'lmagan va shuning uchun kiritilmagan narsalar

- Agglyutinatsiya darajalarining gel-kartadagi ko'rinishi (qaysi daraja — qaysi qatlam) va
  qattiq faza usulida musbat/manfiy ko'rinishi (monoqatlam/tugmacha) — ochiq manbada tasdiqlanmadi.
- Qattiq faza usulida ABO guruhlash (faqat antitela aniqlash prinsipi bor).
- AABB standartlari (elektron moslik, ikki marta aniqlash), FDA talablari.
- Ax, Am, Ael va boshqa kuchsiz kichik guruhlarning alohida serologik naqshlari (faqat umumiy
  "A/B variantlari" va A2 ma'lumoti berildi; "Ax" sarlavhada misol nomi sifatida).
- Gipogammaglobulinemiyaning alohida tilga olinishi — BSH "immunodeficiency" deydi, shunday
  berildi.
- Ximerizm haqida BSH dagi "egizaklar orasidagi transfuziya"dan boshqa sabablar.
- Reagent/eritrotsit nisbati bo'yicha aniq raqamlar (RF № 363 dagi 1:10 va boshqalar) — eskirgan
  bo'lishi mumkin, kiritilmadi; faqat JSST "suspenziya 2–3%, aniq bo'lishi kerak" berildi.
- Muddati o'tgan reagent soxta natija beradi degan aniq da'vo — manbada shu so'z bilan yo'q;
  o'rniga "yo'riqnoma bo'yicha saqlash/ishlatish, seriya va muddatni qayd etish" berildi.
- RF № 1134n ilovasidagi to'liq moslik jadvali (A anti-A1 bilan va h.k.) — ilovada faqat havola,
  jadval ko'chirilmagan (UK/JSST jadvali bilan aralashib ketmasligi uchun).
- BSH 2012 addendum (tarixiy namuna ta'rifi) — o'qilmagan.
- Monoklonal anti-D (DVI) tanlash, anti-CDE, RhD genotiplash — kiritilmadi.
- Terapevtik antitelalar (anti-CD38 va b.) interferensiyasi — manba bor (Trummer 2026), lekin
  bo'lim doirasidan tashqari deb qoldirildi.
- Roliklar (video) — rejada bor, bu bosqichda qilinmadi.
