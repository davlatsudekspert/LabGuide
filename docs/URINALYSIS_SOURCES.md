# Siydik tahlili bo‘limi: manbalar, rasmlar, tekshirilmaganlar

Sana: 2026-10-17. Kod: `lib/features/urinalysis/` (`urinalysis_content.dart` — matn va
manbalar, `urinalysis_logic.dart` — o‘qish yordamchisi va mashq, `urinalysis_screens.dart`).
Yo‘l: `/lab/urinalysis` (`collect`, `physical`, `strip`, `sediment`, `sediment/:id`,
`reader`, `quiz`). Karta sxemasi: `tool/illustrations/urinalysis/gen_urinalysis.py` →
`assets/urinalysis/card.png` (idish va test-chiziq; matnsiz, ranglar shartli — hech qaysi
natijani ko‘rsatmaydi). Test: `test/widget/urinalysis_test.dart`.

Holat (D-65): har sahifa boshida «Manbalar» paneli — `urLeadRefs` (JSST 2003, 7-bob,
233–252-bet; Delanghe va Speeckaert 2014; AAFP 2005, 2022) va bitta tibbiy eslatma. Har sahifada «ishora qilishi
mumkin — tashxis emas» eslatmasi; o‘qish yordamchisi oxirida yo‘llanma eslatmasi.

## 1. Matn manbalari (hammasi shu sessiyada ochib o‘qildi)

| Kod | Manba | Qanday tekshirildi |
|---|---|---|
| WHO | WHO. *Manual of basic techniques for a health laboratory*, 2nd ed., 2003 (ISBN 92 4 154530 5), https://iris.who.int/handle/10665/42295 — ilovada allaqachon bor `CalcSources.whoBasicLab2003` | PDF (iris) to‘liq matni; 7-bob «Examination of urine», 233–252-betlar o‘qildi. Lokator = bo‘lim raqami + bosma bet |
| Delanghe | Delanghe J, Speeckaert M. Preanalytical requirements of urinalysis. *Biochem Med (Zagreb)* 2014. doi:10.11613/BM.2014.011 (PMC3936984, ochiq) | PubMed Central to‘liq matni; lokator = bo‘lim sarlavhasi |
| AAFP 2005 | Simerville JA, Maxted WC, Pahira JJ. Urinalysis: a comprehensive review. *Am Fam Physician* 2005;71(6):1153–62. https://www.aafp.org/pubs/afp/issues/2005/0315/p1153.html | Sahifa matni va jadvallari (1–6) o‘qildi |
| AAFP 2022 | Hitzeman N, Greer D, Carpio E. Office-based urinalysis: a comprehensive review. *Am Fam Physician* 2022;106(1):27–35. https://www.aafp.org/pubs/afp/issues/2022/0700/office-based-urinalysis.html | Sahifa matni va jadvallari (1–7) o‘qildi; 8-jadval matni sahifada yo‘q (rasm) — ishlatilmadi |

Matn so‘zma-so‘z ko‘chirilmagan — o‘z so‘zlarimiz bilan qisqa bayon, har bandda manba
raqami. «Yevropa siydik tahlili qo‘llanmasi» (Kouri va boshq., 2000) va EFLM 2023
qo‘llanmasining o‘zi bu muhitdan ochilmadi (De Gruyter sahifasi to‘sildi), shuning uchun
undan faqat Delanghe 2014 keltirgan qoidalar «Delanghe bayoni bo‘yicha» deb berilgan.

## 2. Da’vo → manba (asosiy; har band kodda `UrFact.refs` bilan)

### 2.1 Yig‘ish va saqlash (`urCollectSections`)

| Da’vo | Manba, joy |
|---|---|
| Ertalabki — eng quyuq; tasodifiy — skrining; o‘rta porsiya ≈ 20 ml, darhol yopish; terminal porsiya | WHO 7.1.1, p. 233 |
| 24 soatlik yig‘ish tartibi, hajmni o‘lchash | WHO 7.1.1, p. 233 |
| Ertalabki birinchi o‘rta porsiya ko‘p ishlatiladi; tungi bakteriya o‘sishi; ikkinchi ertalabki (2–4 soat keyin); birinchi oqimda hujayralar ko‘p; o‘rta porsiya eng maqbul | Delanghe «Which sampling procedure…» |
| Eritrotsit shakli uchun ertalabki siydik (osmolyallik, pH) | Delanghe «Particle analysis» |
| Nitrit uchun qovuqda ≈ 4 soat; tez-tez siyishda soxta manfiy | AAFP 2022 «Leukocyte Esterase and Nitrites» |
| Go‘dak qopchasi 1–3 soat; qopcha — dastlabki tahlilga, ekmaga emas; LE/nitrit musbat → kateter/suprapubik | WHO 7.1.1, p. 234; AAFP 2022 «Specimen Collection», SORT |
| JYYI (NAAT) uchun yuvilmagan birinchi oqim | AAFP 2022 «White Blood Cells» |
| S. haematobium: 10:00–14:00, ≥ 10 ml terminal porsiya, butun namuna | WHO 7.2.8, p. 249 |
| Yuvish bo‘yicha manbalar farqi (WHO: sovun va suv; Delanghe: yuvish −20 % soxta musbat, sovun/antiseptik tavsiya etilmaydi; AAFP 2005: 32 % va 29 %; AAFP 2022: ASM tavsiyasi) | WHO 7.2.9, p. 251–252; Delanghe «Which precautions…»; AAFP 2005/2022 «Specimen Collection» |
| Idish: keng og‘izli, toza, quruq; ekmaga steril; yorug‘likka sezgir moddalar — qorong‘i idish | WHO 7.1, p. 233; Delanghe «Which sampling container…» |
| Vakuum naychalar silindrlarni parchalaydi (gialin ≥ 58 %, hujayrali 51 %) | Delanghe «Which sampling container…» |
| Bitta namunada chiziq va ekma: siydikni chiziqqa tomizish | Delanghe «Use of preservatives…» |
| pH 1 soat ichida; mikroskopiyaga yangi siydik | WHO 7.2.3 p. 235; 7.2.7 p. 241 |
| Zarrachalar: xona haroratida < 1 soat, sovutilganda < 4 soat (Yevropa qo‘llanmasi, Delanghe bayoni) | Delanghe «Particle analysis» |
| > 2 soat kechikish ishonchsiz; sovutish; vaqtni yozish | AAFP 2005 «Specimen Collection»; Delanghe «Is it a matter of time?» |
| Chiziq: sovutilgan, 24 soat ichida — konservantsiz; muzlatish o‘rnini bosmaydi | Delanghe «Use of preservatives…» |
| Sovutishda tuzlar cho‘kadi; kristal uchun alohida ulush; xona haroratiga keltirib aralashtirish | WHO p. 241; Delanghe «Particle analysis», «Optimal urine quality management…» |
| Turib qolgan siydik: lizis (ishqoriy pH, past zichlik), nitrit soxta musbat, keton soxta manfiy | Delanghe «Use of preservatives…», «Interfering effect…»; AAFP 2022 Table 2 |
| Formaldegid 8–10 tomchi / 300 ml faqat mikroskopiya uchun; bor kislotasi soxta manfiy; sovutish afzal | WHO p. 241; Delanghe «Use of preservatives…», «Summary» |

### 2.2 Fizik xossalar (`urPhysicalSections`)

| Da’vo | Manba, joy |
|---|---|
| Me’yor: tiniq, somon-sariq (uroxrom); to‘q sariq; rangsiz; JSST yozish shakli | WHO 7.2.1, p. 234; AAFP 2022 Table 1 |
| Loyqalik: hujayra/tuz; fosfatlar yoki piuriya; LR+ ≈ 3 | WHO p. 234; AAFP 2005 Table 1; AAFP 2022 Table 3 |
| Ranglar (qizil, to‘q sariq, jigarrang, yashil/ko‘k, oq, binafsha, ko‘pikli) va sabablari | AAFP 2022 Table 1 (qisman AAFP 2005, WHO) |
| Hid (quyuq, meva, ammiak, najas, oltingugurt) | AAFP 2005, AAFP 2022 «Visual Appearance and Odor» |
| Zichlik 1,003–1,030; < 1,010 / > 1,020; 1,010 da qotish | AAFP 2005 «Specific Gravity» |
| > 1,020 va < 1,003 sabablari; chiziqdagi zichlik — hozirgi holat | AAFP 2022 «Urine Specific Gravity» |

### 2.3 Test-chiziq (`urStripGeneral`, `urPads`)

| Maydoncha | Manbalar |
|---|---|
| Umumiy: botirish, shkala vaqti, yarim miqdoriy yozish, saqlash | WHO 7.2.2, p. 234 |
| 60–120 s; LE vaqtga sezgir; ochiq havoda nitrit soxta musbat (1 hafta — ⅓, 2 hafta — ¾) | AAFP 2022 «Dipstick Urinalysis»; AAFP 2005 «Nitrites» |
| Choosing Wisely (AUA, AAP); qon → mikroskopiya | AAFP 2022 «Best Practices», SORT |
| pH | WHO p. 235–236; AAFP 2022 «Urinary pH», Table 2; Delanghe «Interfering effect…» |
| Oqsil | AAFP 2022 «Protein», Table 4, SORT; AAFP 2005 «Proteinuria»; WHO p. 236–238; Delanghe |
| Glyukoza | AAFP 2022 «Glucose», Table 2; WHO p. 236; Delanghe |
| Ketonlar | WHO p. 239; AAFP 2005 «Ketonuria», Table 2; AAFP 2022 «Ketones», Table 2; Delanghe |
| Bilirubin | AAFP 2005 «Bilirubin and Urobilinogen»; AAFP 2022 «Bilirubin…», Table 2; Delanghe |
| Urobilinogen | AAFP 2005, AAFP 2022 Table 2; Delanghe |
| Qon | AAFP 2005 «Hematuria», Table 2; AAFP 2022 «Blood»; WHO 7.2.2; Delanghe |
| Nitrit | AAFP 2005 «Nitrites», Table 2; AAFP 2022 «Leukocyte Esterase and Nitrites», Table 3, SORT, «Bacteria»; Delanghe |
| Leykotsitar esteraza | AAFP 2005 «Leukocyte Esterase», Table 2; AAFP 2022 Table 2–3; Delanghe |
| Nisbiy zichlik | AAFP 2022; AAFP 2005 Table 2; Delanghe |

### 2.4 Cho‘kma (`urSedimentIntro`, `urElements`)

| Element | Manbalar |
|---|---|
| Tayyorlash: 12 ml, 400 g, 5 daq, tormozsiz, 12:1; 20–80 % yo‘qotish, CV ≤ 100 % | Delanghe «Manual methods» |
| ×10/×40, kondensor; silindrlar — chetda, xira yorug‘lik; fazali kontrast, polarizatsiya | WHO p. 241; AAFP 2022 eFigure B, «Setting Up…» |
| Kristallar umumiy (sog‘lomda ham, pH, sovuqda hosil bo‘lishi) | WHO p. 236, 245; AAFP 2005; AAFP 2022 |
| Eritrotsitlar (o‘lchamlar, «soya» hujayralar, ≥ 3 / > 5 k/m, achitqi bilan adashish) | WHO p. 241–242, 248; AAFP 2022 «Red Blood Cells», Fig. 4; AAFP 2005 |
| Dismorf eritrotsitlar, akantotsit/G1, fazali kontrast, ertalabki siydik | Delanghe «Particle analysis»; AAFP 2022; AAFP 2005 |
| Leykotsitlar (10–15 µm, yiring; < 2 / < 5 k/m; > 5 k/m) | WHO p. 242; AAFP 2005; AAFP 2022 |
| Yassi, o‘tuvchi, buyrak kanalchalari epiteliysi | AAFP 2005 «Cells»; AAFP 2022 «Epithelial Cells»; WHO p. 242–243 |
| Silindrlar: gialin, donador, eritrotsitar, leykotsitar, epitelial, mumsimon/keng, yog‘li, soxta | WHO p. 243–244; AAFP 2005 «Casts», Table 6; AAFP 2022 «Crystals and Casts» |
| Kristallar: kalsiy oksalat, siydik kislotasi, uch fosfat, sistin, amorf, xolesterin, sulfanilamid | WHO p. 245–248; AAFP 2005 «Crystals»; AAFP 2022 |
| Bakteriyalar, achitqi, S. haematobium tuxumlari | WHO p. 248–252; AAFP 2005 «Bacteriuria»; AAFP 2022 «Bacteria» |

### 2.5 O‘qish yordamchisi (`urFindingInfo`, `urComboInfo`, `readUrinalysis`)

20 ta topilma (9 chiziq, 11 cho‘kma); har biri yuqoridagi manbali qisqa izoh. Birikmalar —
faqat manbada ta’riflanganlari:

| Birikma | Qoida | Manba |
|---|---|---|
| Qon bor, eritrotsit yo‘q | qon ∧ ¬eritrotsit ∧ ¬dismorf | Delanghe «Interfering effect…»; AAFP 2005 «Hematuria» |
| Glomerulyar ko‘rinish | dismorf ∨ eritrotsitar silindr | AAFP 2005 «Glomerular…Hematuria»; AAFP 2022 |
| Urologik ko‘rinish | eritrotsit ∧ ¬oqsil ∧ ¬dismorf ∧ ¬eritr. silindr | AAFP 2005 «Urologic Hematuria» |
| Nitrit + LE | ikkalasi | AAFP 2005 Table 3; AAFP 2022 SORT, «Bacteria» |
| Piuriya, nitrit yo‘q | (LE ∨ leykotsit) ∧ ¬nitrit | AAFP 2022; AAFP 2005 «Leukocyte Esterase» |
| Ifloslanish | yassi epiteliy ∧ (bakteriya ∨ piuriya ∨ eritrotsit ∨ qon) | AAFP 2022 «Epithelial Cells», «Specimen Collection» |
| Ureaza / ishqoriy | ishqoriy pH ∧ (nitrit ∨ bakteriya) | AAFP 2022 «Urinary pH»; AAFP 2005 «Crystals» |

Test 2^20 ta barcha tanlovni mustaqil ta’rif bilan solishtiradi. Har natija oxirida
«tashxis emas — shifokorga» eslatmasi.

### 2.6 Mashq

7 ta rasmli savol (atlas «mashqqa yaroqli» deb belgilagan butun maydon rasmlari) va 15 ta
bilim savoli — har biri yuqoridagi manbali bandlardan (`UrQuizItem.refs`). Har mashqda 12
ta savol, takrorsiz.

## 3. Rasmlar — faqat mikroskopiya atlasidan (id bo‘yicha havola, nusxa yo‘q)

Bo‘lim yangi foto qo‘shmaydi: `assets/microscopy/atlas.json` dagi rasmlarga id bilan
havola qiladi; muallif, litsenziya va asl izoh ekranda atlasdan o‘qiladi, «Atlasda ochish»
— to‘liq kredit sahifasi (`/lab/microscopy/i/<id>`). Atlas litsenziyalari 2026-10-09 da
tekshirilgan (`docs/MICROSCOPY_AUDIT_2026-10-09.md`). Test: rasm atlasda bor, atlas turi
kartaga mos (butun maydon rasmida atlas nomi karta nomini o‘z ichiga oladi; panelda asl
izohdagi harf mos), fayl bor.

| Atlas id | Commons fayli | Muallif | Litsenziya | Kartada | Mashqda |
|---|---|---|---|---|---|
| u-rbc-1 | MicroHematuria.JPG | Bobjgalindo | CC BY-SA 4.0 | Eritrotsitlar | ha |
| u-rbc-2 | Haematuria.jpg | J3D3 | CC BY-SA 3.0 | Eritrotsitlar | ha |
| u-wbc-1 | Plenty of pus cells in Urine Microscopy.jpg | Ajay Kumar Chaurasiya | CC BY-SA 4.0 | Leykotsitlar | ha |
| u-wbc-2 | Pus cells (dead leukocytes) in urine microscopy.jpg | Ajay Kumar Chaurasiya | CC BY-SA 4.0 | Leykotsitlar | ha |
| u-cast-hyaline-1 | Hyaline Cast in Urine Microscopy.jpg | Ajay Kumar Chaurasiya | CC BY-SA 4.0 | Gialin silindr | ha |
| u-cast-granular-1 | Granular Casts in Urine Microscopy.jpg | Ajay Kumar Chaurasiya | CC BY 4.0 | Donador silindr | ha |
| u-cast-panel-1 | RTE cast, muddy granular cast, WBC cast and RBC cast in urine.jpg | Mohsenin V. | CC BY 4.0 | Panel (a) epitelial, (b) donador, (c) leykotsitar, (d) eritrotsitar silindr — panel harfi ekranda yozilgan | yo‘q |
| u-cryst-caox-1 | Calcium Oxalate Monohydrate Crystals in Urine Microscopy.jpg | Ajay Kumar Chaurasiya | CC BY-SA 4.0 | Kalsiy oksalat (atlasning «nom manbaga ko‘ra, ko‘rinishi namunaviy emas» eslatmasi bilan) | yo‘q |
| u-cryst-uric-1 | UricAcid.jpg | J3D3 | CC BY-SA 3.0 | Siydik kislotasi | ha |
| u-cryst-triple-1 | Кристаллы трипельфосфата … x400.jpg | Vladimir064 | CC BY 4.0 | Uch fosfat | ha |
| u-cryst-cystine-1 | Cystine in Urine.jpg | J3D3 | CC BY-SA 4.0 | Sistin | ha |

Rasmsiz kartalar («rasm hozircha yo‘q»): dismorf eritrotsitlar, yassi, o‘tuvchi va buyrak
kanalchalari epiteliysi, mumsimon/keng va yog‘li silindrlar, soxta silindrlar, amorf
tuzlar, xolesterin, dori kristallari, bakteriyalar, achitqi, S. haematobium tuxumlari.
Atlasdagi `u-rte-1` (izohda «RT cells», lekin ko‘rinishi namunaviy emas) va aralash maydon
rasmlari (`u-epi-1`, `u-epi-2`) kartalarga qo‘yilmadi — nom rasmga aniq mos kelishi
kafolatlanmagan. Morfologik sxemalar chizilmadi (xato ko‘rinish o‘rgatib qo‘yish xavfi).

## 4. Havola, takror emas

- Nechiporenko, Kakovskiy–Addis, Zimnitskiy — mavjud qo‘lda hisoblash ekranlari
  (`/lab/calculators/nechiporenko`, `addis-kakovsky`, `zimnitsky`); albumin/kreatinin —
  `/lab/calculators/acr`. Formula va me’yorlar bu bo‘limda takrorlanmaydi.
- Kontent paketidagi kartalar `urine-chemistry`, `urine-microscopy`, `urine-24h`,
  `urine-culture` — id bo‘yicha havola (`/tests/analyte/<id>`), matni ko‘chirilmagan.
- Mikroskopiya atlasining «Siydik cho‘kmasi» bo‘limi — havola.

## 5. Manbalar farqi (ikkalasi ham ko‘rsatildi)

- Donador va epitelial silindrlar ahamiyati: JSST 2003 — «tashxisiy ahamiyatsiz»; AAFP
  2005/2022 — kanalcha shikastlanishi, kuchaygan buyrak kasalligi va b.
- Bakteriologik namunadan oldin yuvish: JSST (sovun va suv) ↔ Delanghe (sovun/antiseptik
  tavsiya etilmaydi) ↔ AAFP (foydasi isbotlanmagan).
- Xlorpromazin bilirubin maydonchasida: AAFP 2005 jadvalida soxta manfiy, AAFP 2022 va
  Delanghe — soxta musbat; ilovada ikki yangi manba bo‘yicha soxta musbat.
- Urobilinogen va nitrit: AAFP 2005 — nitrit soxta musbat; Delanghe — soxta manfiy;
  ilovada Delanghe bo‘yicha (AAFP 2005 bu band uchun keltirilmagan).

## 6. Tekshirilmagan yoki qoldirilganlar

- JSST 7.3–7.4 jadvallaridagi «k/m da 0–10 eritrotsit / leykotsit — me’yor» chegaralari
  AAFP/AUA mezonlari (≥ 3 eritrotsit, < 2/< 5 leykotsit) bilan zid — chiqarildi; ilovada
  AAFP/AUA chegaralari.
- JSST cho‘kma sentrifugasi (2000 g, 5 daq) va AAFP (1500–3000 rpm) parametrlari —
  Delanghe standarti bilan farq qiladi; faqat Delanghe standarti berildi, «SOP ustun»
  eslatmasi bilan.
- Dismorf eritrotsitlar uchun foiz chegaralari (akantotsitlar ≥ 5 % va b.) — shu sessiyada
  ochiq birlamchi manba o‘qilmadi, kiritilmadi.
- Mumsimon va keng silindrlar ko‘rinishining batafsil ta’rifi — manbalarda yo‘q, faqat
  tarkib va ahamiyat berildi.
- KDIGO albuminuriya toifalari, ADA keton tavsiyalari — bu bo‘limda yangi da’vo sifatida
  berilmadi (ACR kalkulyatoriga havola bor).
- Lyubina / Nechiporenko / Addis bo‘yicha rus me’yorlari — bu bo‘limda yangi da’vo yo‘q;
  ular mavjud kalkulyatorlarda (Lyubina 1984 va Aripova 2007 sahifalari bilan). Kurs
  adabiyoti (Google Drive «KDL») bu bo‘lim uchun ishlatilmadi.
- EFLM European Urinalysis Guideline 2023 va 2000 yilgi Yevropa qo‘llanmasi — matni
  ochilmadi; Delanghe orqali keltirilgan qoidalar shunday belgilangan.
- Trichomonas, spermatozoidlar, mikrofilyariyalar — JSST faqat ro‘yxatda tilga oladi,
  ko‘rinish ta’rifi o‘qilmadi; alohida karta qilinmadi.
