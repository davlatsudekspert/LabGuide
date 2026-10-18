# Qon morfologiyasi bo‘limi: manbalar, rasmlar, tekshirilmaganlar

Sana: 2026-10-17. Kod: `lib/features/bloodmorph/` (`bloodmorph_content.dart` — matn va
manbalar, `bloodmorph_logic.dart` — anemiya yordamchisi mantiqi, `bloodmorph_screens.dart`).
Marshrutlar: `/lab/bloodmorph` (+ `normal`, `rbc`, `rbc/:id`, `platelets`, `retic`, `anemia`,
`quality`, `quiz`, `credits`). Rasmlar: `assets/bloodmorph/img/` (`tool/bloodmorph_images.py`),
karta va raqamli sxema: `tool/illustrations/bloodmorph/gen_bloodmorph.py` →
`render.cjs --bloodmorph`. Testlar: `test/widget/bloodmorph_test.dart`. Vizual o‘tish:
`tool/screenshots/walk_bloodmorph_test.dart`.

Holat: ekranda «qoralama» belgisi (gistologiya, sitologiya kabi) — mutaxassis (domla)
tekshiruvidan keyin olib tashlanadi. Leykotsitlar — leykoformula bo‘limida (havola), analit
ma’lumoti — kontent paketidagi kartalarda (havola, takrorlanmaydi), anemiya jadvali —
«Jadvallar va algoritmlar → Anemiya» (havola), retikulotsit hisobi — mavjud kalkulyator
(`/lab/calculators/reticulocytes`; ishlangan misol shu funksiya bilan hisoblanadi).

## 1. Matn manbalari (hammasi shu sessiyada ochilib o‘qildi)

| Kod | Manba | Qanday tekshirildi |
|---|---|---|
| WHO 2003 | WHO. *Manual of basic techniques for a health laboratory*, 2nd ed., 2003 (iris.who.int) | PDF to‘liq matni; 9.10 (299–314-betlar), 9.11, 9.12 (316–319), 9.14 (321) o‘qildi |
| Adewoyin 2014 | Adewoyin AS, Nwogoh B. Peripheral blood film — a review. *Ann Ib Postgrad Med* 2014;12(2):71–79, PMC4415389, CC BY-NC 3.0 | Europe PMC to‘liq matni (XML), Table 1 bilan |
| MSD | Gerber GF. *Evaluation of Anemia*. MSD Manual Professional (full review May 2024) | Sahifa matni olindi (indekslar, surtma, retikulotsitlar, «Characteristics of Common Anemias» jadvali) |
| Takami 2026 | Takami A. How to Interpret the CBC in Daily Practice. *JMA J* 2026, doi:10.31662/jmaj.2026-0173 (mavjud `RefSources.takami2026`) | Europe PMC to‘liq matni: Table 3, Table 4, Table 5, Step 2, Step 5 |
| Cattaneo 2025 | Cattaneo M. Pseudothrombocytopenia and other conditions associated with spuriously low platelet counts. *Haematologica* 2025;110(8):1677–1692, CC BY-NC 4.0 | Europe PMC to‘liq matni; bo‘limlar: Abstract, Epidemiology, Mechanism…, Diagnosis…, Platelet satellitism, Presence of large/giant platelets |
| Chueh 2022 | Korean guidelines for hereditary hemolytic anemia. *Blood Res* 2022, CC BY-NC 4.0 (mavjud `CalcSources.chueh2022`) | Europe PMC to‘liq matni: «Laboratory tests for screening» (CRC, RPI), «Peripheral blood smear» |
| WHO Hb 2024 | WHO guideline on haemoglobin cutoffs, 2024 (mavjud `RefSources.whoHb2024`) | PDF: Table 2 (9-bet; xi-bet) |
| WHO ferritin 2020 | WHO guideline on ferritin, 2020 (mavjud `RefSources.whoFerritin2020`) | PDF: Executive summary, Table 1 |
| Jung 2011 | Jung HH, Danek A, Walker RH. Neuroacanthocytosis syndromes. *Orphanet J Rare Dis* 2011;6:68, CC BY 2.0 | Europe PMC: Definition (akantotsit ta’rifi) |
| Zama 2020 | Zama D, et al. *Ital J Pediatr* 2020;46:102, CC BY 4.0 | Europe PMC: Background (stomatotsit ta’rifi, DHS da kam uchrashi) |
| Najmitdinov 1998 | Наджимитдинов С.Т. *Клиник гематология асослари*, 1998 (Drive «KDL»; mavjud `RefSources.najmitdinov1998`) | Word nusxasi o‘qildi; bet raqamlari yo‘q — lokator: «Кириш: Қоннинг аҳамияти» (эритроцит, 3–13-расмлар матни; ретикулоцит, 14-расм матни). Faqat o‘z so‘zimiz bilan qisqacha |
| Saidov 2017 | Саидов С.А., Исаджанов М.С. *Қоннинг умумий клиник ва иммунофермент таҳлиллари…* Тошкент, 2017 (Drive «KDL WORD») | Word nusxasi o‘qildi; RDW referensi (32-bo‘lim, 36-bet — mundarija bo‘yicha) |
| Commons | Rasm fayl sahifalari | Faqat rasmda nima tasvirlanganini aytish uchun (3 joyda) |

## 2. Da’vo → manba (asosiy; har band kodda `BmFact.refs` bilan)

| Ekran / karta | Da’vo | Manba, joy |
|---|---|---|
| Normal eritrotsit | ikki tomoni botiq disk 7–8 µm, och markaz ≈ 1/3, kiritmasiz; kichik limfotsit yadrosi kattaligida | Adewoyin, Red cell morphology |
| | 6–8 µm, yumaloq, gardishi to‘q pushti; Leyshmanda pushti-qizil | WHO 2003 p. 306, Table 9.10 p. 305 |
| | 6–9 µm (7,2), <6 mikrotsit, 9–12 makrotsit, >12 megalotsit | Najmitdinov 1998 |
| Qayerga qarash | yupqa uchidan oldin; bosh qismi 2× zich; patli uch — to‘plamlar, yirik hujayralar | WHO p. 305; Adewoyin, Interpreting… |
| O‘lcham | anizotsitoz (9 va 6 µm), ko‘p anemiyalarda | WHO p. 309 |
| | RDW/MCV, aralash populyatsiyada MCV me’yorda | MSD indices; Takami Table 3 |
| | RDW «me’yori» 11–15 % / 11,5–14,5 % | Adewoyin; Saidov p. 36 |
| Rang | gipoxromiya — temir tanqisligi; giperxrom — och joysiz | Adewoyin |
| | MCHC < 30 g/dL; sferotsitda MCHC ↑ | MSD indices |
| | polixromaziya = retikulotsitlar, taxminiy baho | MSD Reticulocyte count; Adewoyin |
| | namlik artefakti (yaltiroq chegara) | Adewoyin, Preparation… |
| Shakl | poykilotsitoz ta’rifi, og‘ir anemiya, miyelofibroz | WHO p. 309 |
| | anizo → poykilo → shizotsitoz ketma-ketligi | Najmitdinov 1998 |
| Kiritmalar | HJ, punktatsiya, Pappenxaym, parazitlar; supravital: Xeynts, HbH | Adewoyin |
| Mikrotsitlar | ≈ 5 µm; MCV < 80; temir tanqisligi, sideroblast, talassemiya; ACD; sferotsitdan farqlash | WHO p. 307–308; MSD indices; Adewoyin |
| Makrotsitlar | 9–10 µm; MCV > 100; oval (megaloblast, MDS, gidroksikarbamid) va yumaloq (jigar, alkogol); retikulotsitdan farqlash | WHO p. 307; MSD; Adewoyin |
| Polixromaziya | ko‘kish tus, retikulotsitlar; o‘tkir qon yo‘qotish / gemoliz / tiklanish | MSD Reticulocyte count, Table; Adewoyin |
| Sferotsitlar | ≈ 6 µm, yumaloq, to‘q, och joysiz; HS, issiq AIHA, ABO, kuyish; MCHC ↑; Kumbs, gemoliz belgilari | WHO p. 308; Adewoyin Table 1; MSD; Chueh smear |
| Nishonsimon | markaz/gardish bo‘yalgan, rangsiz halqa; talassemiya, HbC/SC, o‘roqsimon, temir tanq., jigar, splenektomiya; Hb/hajm nomutanosibligi; yakka hujayralar normada ham | WHO p. 306; Adewoyin T1; MSD smear; Najmitdinov |
| Shizotsitlar | bo‘laklar, dubulg‘asimon, keratotsit; TMA (DVS, TTP, HUS), klapan; trombotsitni soxta oshiradi; shoshilinch belgi | WHO p. 308; Adewoyin T1, Platelet morphology; MSD; Takami Table 4, Table 5 |
| O‘roqsimon | cho‘ziq, uchlari egilgan; HbSS/SC/Sβ; elektroforez; 9.11 test | WHO p. 307, 314–315; Adewoyin T1; MSD Table |
| Tomchisimon | shakli (fayl izohi; noksimon — Najmitdinov); miyelofibroz, miyeloftiz, EMH va boshqalar; leykoeritroblastik → gematolog | Commons fayl; Adewoyin T1, Red cell morphology; MSD Table |
| Elliptotsitlar | oval, 8 µm, qutblari to‘q; HE > 25 %, temir tanq., pernitsioz, SCD, talassemiya, miyelofibroz; yengil HE gemolizsiz; oval makrotsitdan farqi | WHO p. 308–309; Adewoyin T1; Chueh smear |
| Stomatotsitlar | og‘izsimon och joy; artefakt, jigar, alkogol, Rh-null, o‘pka; DHS da kam | Zama 2020; Commons fayl; Adewoyin T1 |
| Akantotsitlar | tikansimon o‘simtalar; jigar, buyrak, abetalipoproteinemiya, spur cell, PK; neyroakantotsitoz | Jung 2011; Adewoyin T1 |
| Exinotsitlar | krenatsiyali, yaltiroq chegara; saqlash, nam quritish, fiksatsiya artefakti; uremiya, ovqatlanish | Adewoyin T1, Preparation…, Red cell morphology |
| Bazofil punktatsiya | ko‘k-qora nuqtalar (RNK); talassemiya, qo‘rg‘oshin/mishyak, …, P5′N; bo‘yoq cho‘kmasidan farqi | WHO p. 309; Adewoyin; MSD Table |
| Xauell–Jolli | binafsha donacha (DNK); splenektomiya/aspleniya, gemolitik, megaloblast; trombotsitdan farqi | WHO p. 309; Adewoyin |
| Tanga ustunchalari | tanga kabi; ko‘kish fon — paraproteinemiya, makroglobulinemiya | Adewoyin |
| Agglyutinatsiya | to‘dalar; sovuq agglyutininlar, Valdenström; RBC ↓, MCV/MCHC ↑ | MSD Table; Adewoyin; Takami Table 4 |
| Trombotsitlar (normal) | megakariotsit bo‘lagi, ≈ 1/3 eritrotsit, binafsha-pushti; 20 maydon, nisbat × RBC; ×100 maydonda 7–15, 1 trombotsit/maydon ≈ 15–20 ×10⁹/L | Adewoyin Platelet morphology; WHO 9.14, p. 321 |
| (2026-10-18 tuzatish) | JSST 9.14 dagi «500–1000 eritrotsitga bitta trombotsit — me’yor» olib tashlandi: JSST ning o‘z Table 9.13 (kattalar 1,7–4,0 ×10⁵/mm³) va eritrotsit soni (4–5 ×10¹²/L) bilan nisbat ≈ 1:10–1:30 chiqadi; 1:500–1000 og‘ir trombotsitopeniyaga (≈ 5–10 ×10⁹/L) mos — manbadagi xato | WHO p. 321; Adewoyin |
| Gigant | ≈ eritrotsit kattaligida; tug‘ma/orttirilgan trombotsitopeniya; yuqori IPF — MYH9; analizator sanamaydi, qo‘lda sanash | Adewoyin; Cattaneo Abstract, Presence of large/giant…; Takami Table 4, 5 |
| To‘plamlar (PTCP) | ≥ 5 trombotsit; chetlar, dum; EDTA, harorat/vaqt, antitana; zararsiz; ~0,1 %; 4–20 °C; WBC soxta ↑; tashxis faqat surtmada; darhol sanash; sitrat/geparin har doim emas | Cattaneo (Abstract, Epidemiology, Mechanism, Diagnosis); Adewoyin; Takami Step 5 |
| Satellitizm | neytrofil atrofida; IgG ko‘prigi GPIIb-IIIa–FcγRIII; faqat EDTA; soni soxta ↓ | Cattaneo Abstract, Platelet satellitism |
| Sifat | EDTA 1–2 soat, geparin yo‘q | WHO p. 300 |
| | 2 soat ichida; ≥ 10 marta ag‘darish; 30–45°; 2/3 va patli uch; ≥ 2 surtma | Adewoyin, Preparation… |
| | surtma mezonlari (chiziqlar, uchi, uzunligi, qalinligi, teshiklar); anemiyada tez surtish | WHO p. 301–302 |
| | quritish; metanol 2–3 daqiqa; 4 soat/1 soat ichida; burr artefakti | WHO p. 303; Adewoyin |
| | pH (kislota → qizil, ishqor → ko‘k), Leyshman 6,8–7,2, MGG 6,8–7,0; cho‘kma; vaqtni moslash; kunlik solishtirish | WHO p. 303–305; Adewoyin |
| | saqlashda krenatsiya; MCV ↑, MCHC ↓; PTCP vaqt bilan; monotsitlar chetga, smudge | Adewoyin; Takami Table 4; Cattaneo |
| Retikulotsitlar | tamoyil, briliant krezil ko‘ki; 2+2 tomchi, 15 daqiqa, ×100 | WHO 9.12 (p. 316–318) |
| | % = n × 0,2 (500 da); mutlaq = C × 2n ×10⁹/L; misol 54; referens 0,2–2,0 % (8–110) | WHO 9.12 |
| | CRC = % × Ht ÷ 45; RPI > 3 / < 2 | Chueh 2022 |
| | I–V sinflar; 5–10 ‰ | Najmitdinov 1998 |
| | > 80 / < 20 ×10⁹/L (taxminiy) | Takami Step 2 |
| Yordamchi | Hb chegaralari (10 guruh) | WHO Hb 2024 Table 2 |
| | MCV < 80 / 80–100 / > 100 va 6 qator (talqin, differensial, maslahat) | Takami Table 3 (MSD bilan mos) |
| | faqat MCV bo‘lsa — indekslar mexanizmi | MSD indices |
| | ferritin < 12/< 30 (0–59 oy), < 15/< 70 (5 yosh+), homiladorlik I tr. < 15 | WHO 2020 Table 1 |
| | retikulotsit yo‘l-yo‘riqlari | Takami Step 2; MSD |
| | shoshilinch belgi; yosh/jins eslatmasi | Takami Table 5, Table 3 footnote 4 |

Ilova qoidalari (manbada yo‘q, shuning uchun aniq aytilgan): RDW uchun yagona son yo‘q —
foydalanuvchi o‘z laboratoriyasining yuqori chegarasini kiritadi; 80 va 100 fL «me’yorda»
oralig‘iga kiradi; 20–80 ×10⁹/L oralig‘ida manba yo‘l-yo‘riqlari qo‘llanmaydi deb yoziladi.

## 3. Rasmlar (hammasi Wikimedia Commons; tekshirildi 2026-10-17)

Har fayl uchun Commons API dan `extmetadata` (LicenseShortName, Artist, ImageDescription) va
wikitext litsenziya shabloni olindi; rasm ko‘z bilan tekshirildi (nom va ko‘rinish mos).
Ishlov: faqat kichraytirish (eni ≤ 900 px), JPEG 80, kesish/yozuv yo‘q. Asl fayllarni yuklash
bu muhitdan cheklangan (HTTP 429) — standart 960 px (gigant trombotsit uchun 330 px)
thumbnail olindi. Jami ≈ 2 MB.

| Ilovadagi fayl | Commons fayli | Muallif | Litsenziya | Qayerda |
|---|---|---|---|---|
| `iron_deficiency` | Iron-deficiency Anemia, Peripheral Blood Smear (4422704616).jpg | Ed Uthman | CC BY 2.0 | Mikrotsitlar kartasi; «Rang» bo‘limi |
| `polychromasia` | Polychromasia.jpg | Prof. Osaro Erhabor | CC0 | Polixromaziya |
| `spherocytes` | Hereditary Spherocytosis smear 2010-03-17.JPG | Paulo Henrique Orlandi Mourao | CC BY-SA 3.0 | Sferotsitlar |
| `target_cells` | Target cells.jpg | Prof. Osaro Erhabor | CC0 | Nishonsimon |
| `schistocytes` | Schizocyte smear 2009-12-22.JPG | Paulo Henrique Orlandi Mourao | CC BY-SA 3.0 | Shizotsitlar |
| `sickle_cells` | Sickle Cell Disease.jpg | Prof. Osaro Erhabor | CC0 | O‘roqsimon |
| `teardrop_cells` | Teardrop Cells smear 2009-09-22.JPG | Paulo Henrique Orlandi Mourao | CC BY-SA 3.0 | Tomchisimon |
| `elliptocytes` | Hereditary Elliptocytosis 6 0.jpg | Dr Erhabor Osaro | CC BY-SA 3.0 | Elliptotsitlar |
| `stomatocytes` | Stomatocytes.jpg | Prof. Osaro Erhabor | CC0 | Stomatotsitlar |
| `acanthocytes` | Acanthocytes 4.jpg | Prof. Erhabor Osaro | CC BY-SA 4.0 | Akantotsitlar |
| `echinocytes` | Crenated red cells 11.jpg | Prof. Erhabor Osaro | CC BY-SA 4.0 | Exinotsitlar |
| `basophilic_stippling` | Basophilic stippling 2.jpg | Prof. Erhabor Osaro | CC BY-SA 4.0 | Bazofil punktatsiya |
| `howell_jolly` | Howell-Jolly smear 2010-11-17.JPG | Paulo Henrique Orlandi Mourao | CC BY-SA 3.0 | Xauell–Jolli |
| `rouleaux` | Rouleaux Red Cells.jpg | Prof. Osaro Erhabor | CC0 | Tanga ustunchalari |
| `agglutination` | Red cell agglutination.jpg | Prof. Erhabor Osaro | CC BY-SA 4.0 | Agglyutinatsiya |
| `giant_platelet` | Micrograph of a giant platelet.jpg | Mikael Häggström, M.D. | CC0 | Gigant trombotsit |
| `platelet_clumping` | Platelet Clumping 8.jpg | Prof. Erhabor Osaro | CC BY-SA 4.0 | Trombotsit to‘plamlari |
| `platelet_satellitism` | Platelet Satellitism smear 2009-09-11.JPG | Paulo Henrique Orlandi Mourao | CC BY-SA 3.0 | Satellitizm |
| `anisocytosis` | Anisocytosis 2.jpg | Prof. Erhabor Osaro | CC BY-SA 4.0 | «O‘lcham» bo‘limi |
| `reticulocytes` | Reticulocytes Human Blood Supravital Stain.jpg | Ed Uthman, MD | CC BY 3.0 | Retikulotsitlar |

Bo‘yoq faqat fayl sahifasida yozilgan bo‘lsa ko‘rsatiladi (retikulotsit — supravital);
qolganlarida «manbada ko‘rsatilmagan». Muallif izohlaridagi klinik da’volar manba sifatida
ishlatilmagan — faqat rasmda nima borligini aniqlash uchun.

Sxemalar (mikrofoto emas): `assets/bloodmorph/card.png` (bo‘lim kartasi, matnsiz) va
`assets/bloodmorph/scheme.png` (1–6 raqamli: normal, mikrotsit, makrotsit, gipoxrom, sferotsit,
kichik limfotsit; 1 µm = 14 px, o‘lchamlar WHO p. 306–308 va Adewoyin bo‘yicha; izoh ilovada
3 tilda).

Mashq: rasmli savollar faqat rasmi bor kartalardan; chalg‘ituvchilar rasmda ikkinchi o‘zgarish
ko‘rinib qolishi mumkin bo‘lgan juftlardan (masalan, punktatsiya rasmida polixromatofil hujayra,
shizotsit rasmida tomchisimon shakl, akantotsit ↔ exinotsit) ataylab tanlanmagan.

## 4. Tekshirilmagan yoki chiqarib tashlanganlar

- **ICSH 2015** (Palmer L, et al. *Int J Lab Hematol* 2015;37:287–303, doi:10.1111/ijlh.12327) —
  Wiley sahifasi bu muhitdan yopiq (Cloudflare 403), PMC da yo‘q, uchinchi tomon nusxasi 404.
  Shuning uchun ICSH atamalari va **baholash (1+/2+/3+, %) jadvali kiritilmadi**.
- **StatPearls / NCBI Bookshelf** — reCAPTCHA bilan yopiq; ishlatilmadi.
- **ASH Image Bank** — https://imagebank.hematology.org/permissions (2026-10-17): mualliflik
  huquqi ASH da; ruxsatsiz foydalanish faqat shaxsiy/notijorat va «ommaga e’lon qilinmasdan,
  tarmoqqa joylanmasdan» — ilovaga qo‘yib bo‘lmaydi; rasmlari olinmadi. DjVu atlaslar (mualliflik huquqi) — ishlatilmadi.
- **Makrotsitlar rasmi**: Commons’dagi «Macrocytes.jpg» (Erhabor, CC0) past kattalashtirishda,
  o‘lcham mo‘ljalisiz — makrotsit ekanini ko‘z bilan tasdiqlab bo‘lmadi; karta rasmsiz
  («rasm topilmadi») va mashqqa kirmaydi. «Microcytosis.jpg» ham xuddi shu sababli
  almashtirildi (Ed Uthman temir tanqisligi rasmi — muallif MCV 55 fL deb yozgan).
- «Spherocytes.jpg» (Erhabor) va «Schistocytes.jpg» (Erhabor) — rasmda boshqa o‘zgarishlar
  ko‘p (sferotsit rasmida bo‘laklar, shizotsit rasmida bo‘laklar kam) — Mourao rasmlari olindi.
- Häggström’ning kichik (300 px atrofidagi) bitta-hujayra rasmlari (nishonsimon, punktatsiya,
  elliptotsit, exinotsit) — asl fayllarni yuklash cheklangan, standart thumbnail o‘lchami
  aslidan katta; ishlatilmadi (gigant trombotsitdan tashqari, 330 px thumbnail).
- Guy Waterval’ning frantsuzcha seriyasi (Ovalocytes, Stomatocytes-1, Echinocytes-12 …) —
  litsenziyasi Apache 2.0 (topshiriqdagi CC0/CC BY/CC BY-SA/PD ro‘yxatida yo‘q); olinmadi.
- «Rouleaux formation side view.jpg» — qin surtmasidagi nam preparat; qon surtmasi emas, olinmadi.
- Adewoyin 2014 dagi gigant trombotsit sindromlari ro‘yxati (Bernard–Soulier, May–Hegglin,
  Wiskott–Aldrich) **kiritilmadi**: Wiskott–Aldrich sindromida trombotsitlar odatda kichik —
  manbadagi bu band shubhali, ikkinchi manba bilan tasdiqlanmadi.
- Adewoyin’dagi «fiksatsiya 10–20 daqiqa» — WHO usulidagi 2–3 daqiqa bilan zid; faqat WHO
  qiymati yozildi.
- WHO 2003 dagi «retikulotsitlar qonda 4 soatda yo‘qoladi» jumlasi — boshqa manbalarga (1–2 kun
  yetilish, Adewoyin) zid; kiritilmadi.
- Pappenxaym tanachalari, «bite»/«blister» hujayralar, Kabo halqalari — qamrovda yo‘q yoki mos
  rasm tanlanmadi; faqat «Kiritmalar» matnida eslatilgan (manbali).
- Shizotsitlar uchun ICSH miqdoriy chegarasi (%), RDW uchun yagona son — manbasiz, yozilmadi.
