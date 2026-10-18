# Amaliy protokollar: yarim avtomat analizator va keng tarqalgan tahlillar bo‘yicha manbalar qamrovi

Sana: 2026-10-17. Egasining so‘rovi: «Yarim avtomat analizatorlar uchun reaktiv tayyorlash bormi? D vitamini va
boshqa oddiy tahlillar ham». Qoida: har bir qadam, hajm, to‘lqin uzunligi, omil, vaqt va me’yor faqat o‘qiladigan
manbadan (muallif, kitob, bo‘lim/sahifa). Manba bo‘lmasa — protokol yozilmaydi, bo‘shliq shu yerda ko‘rsatiladi.

Yangilanish 2026-10-18: kitoblarda yo‘q 19 test ishlab chiqaruvchilarning ochiq IFU lari asosida yopildi — pastdagi
«Kitoblarda yo‘q 19 test» bo‘limiga qarang.

## Qanday tekshirildi

Drive «KDL» va «KDL WORD» papkalari (Google Drive MCP). Kitoblar to‘liq matnda o‘qildi: MCP matni ~150 ming
belgida kesilgani uchun fayllar yuklab olinib, PDF — `pdftotext`, `.doc/.docx` — LibreOffice orqali matnga
o‘girildi; skanlangan Yusupova (2022) kitobi 231 betning hammasi OCR qilindi (tesseract).

| Manba (Drive fayli) | Holati |
|---|---|
| Aripov A.N. va b., 2006 — QVP qo‘llanmasi (`Rukov-uzb.doc`; to‘liq nusxa `klinik labaratoriya diagnostikasi qo'llanma.docx`) | To‘liq o‘qildi. Hospitex Diagnostics to‘plamlari va Screen Master Plus fotometri uchun **«… aniqlash uchun dastur tuzish»** jadvallari faqat 5 ta test uchun bor: ALT, mochevina, glyukoza, umumiy/bog‘langan bilirubin, gemoglobin. III bob — ichki sifat nazorati. |
| Aripova G.S., Po‘latova F.G. va b., 2007 — «Klinik va biokimyoviy tekshiruv usullari» (PDF) | To‘liq o‘qildi. Faqat eski qo‘lda bajariladigan usullar (pastda). |
| Kurbonova Z.Ch., 2023 (PDF, 183 b.) | To‘liq o‘qildi (pdftotext, bosma sahifa = PDF sahifa). Biokimyoviy aniqlash usullari yo‘q — talqin. |
| Yusupova N.A. va b., 2022 (skan PDF) | To‘liq OCR. 5-bob — talqin; fotometrik usul faqat **siydik** oqsili uchun. |
| Agzamxodjaev T.S. va b., 2016 (`klinik_laborator_tashhislash … (3).doc`) | To‘liq o‘qildi. Siydik oqsili (nefelometrik, biuret), KFK (Rozalski, 340 nm, hajmsiz) — bu ro‘yxatdagi testlar uchun usul yo‘q. |
| Saidov S.A., Isajanov M.S., 2017 | To‘liq o‘qildi. Faqat referens qiymatlar va talqin (usul yo‘q). |
| ADTI 7-bo‘lim ma’ruzalari (`7- Булим.doc`) | To‘liq o‘qildi. Fermentativ usullar faqat tamoyil darajasida (xolesterinoksidaza, urikaza, ureaza) — hajm/vaqt/omil yo‘q. |
| `ВИТАМИНЛАР.doc` | O‘qildi: D vitamini biokimyosi, tahlil usuli yo‘q. |
| Menshikov, 1987 (DjVu, 6,8 MB) | **O‘qilmadi**: MCP yuklab olishda javob juda katta (ulanish uzildi). Unifitsirlangan qo‘lda usullar manbasi bo‘lishi mumkin — keyingi qadam. |
| Sultonov (103 MB .doc), Nikolaev 1991 (96 MB), Hodjibekov (50 MB), Sobirova 2006 | Sultonov — MCP matni bo‘sh; qolganlari hajmi katta yoki nazariy darslik (Sobirova matnida usul topilmadi). |
| WHO Manual of basic techniques, 2003 (pack’da bor) | Bu safar ochilmadi (IRIS sahifasi PDF bermadi) — yuvish/texnik xizmat uchun ishlatilmadi. |

## Test bo‘yicha natija

| Test | Yarim avtomat usuli kurs kitoblarida | Topilgan joy (kitob, bo‘lim/sahifa) | Kitobda nima yetishmaydi | Protokol |
|---|---|---|---|---|
| Kreatinin (Yaffe, kinetik) | Yo‘q | Kurbonova 2023, 34–35-b. (faqat Reberg–Tareev sinamasi, KFT formulasi); Yusupova 2022, 163-b. (klinik ahamiyati) | Reagent, to‘lqin, vaqt, omil — hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `kreatinin-yaffe-kinetik` |
| Umumiy oqsil (biuret) | Yo‘q (qisman qo‘lda) | Aripova 2007, 18-b.: kalibrovka 0,5/1,0/1,5% oqsil eritmalari, 4 ml biuret reaktivi, xona haroratida 20 daqiqa, FEK, 1 sm kyuveta | Namuna hajmi, to‘lqin uzunligi, reaktiv tarkibi, hisoblash — yo‘q; Yusupova 82-b. va Agzamxodjaev — biuret faqat siydik oqsili uchun | Kitobda bo‘shliq → **IFU asosida yopildi**: `umumiy-oqsil-biuret` |
| Albumin (BCG) | Yo‘q | — | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `albumin-bromkrezol-yashil` |
| Umumiy xolesterin (CHOD-PAP) | Yo‘q | ADTI 7-bo‘lim (xolesterinoksidaza tamoyili); Aripova 2007 — faqat me’yor | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `umumiy-xolesterin-chod-pap` |
| Triglitseridlar (GPO-PAP) | Yo‘q | — | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `triglitseridlar-gpo-pap` |
| YZLP xolesterini (HDL) | Yo‘q | — | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `yzlp-xolesterin-hdl` |
| AST | Yo‘q (eski qo‘lda) | Aripova 2007, 53–54-b.: 2,4-DNFG kolorimetrik usul (kalibrovka egri chizig‘i bilan) | Kinetik (IFCC tipidagi) usul manbada yo‘q; DNFG usuli ALT protokolida eskirgan deb olinmagan — AST uchun ham olinmadi | Kitobda bo‘shliq → **IFU asosida yopildi**: `ast-kinetik-ifcc` |
| Ishqoriy fosfataza | Yo‘q | Kurbonova 2023, 73, 76, 144, 162-b.; Yusupova 146-b. — talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `ishqoriy-fosfataza-kinetik` |
| GGT | Yo‘q | Yusupova 146-b. — talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `ggt-kinetik` |
| α-amilaza | Yo‘q (qo‘lda, zid) | Aripova 2007, 55–56-b.: Karavey (kraxmal–yod) usuli ikki xil yozilgan (1 ml kraxmal + 0,02 ml namuna va 0,5 ml + 0,01 ml), natija birligi «mg/sutka», me’yorlar mmol/l — o‘zaro zid | Ishonchli parametrlar | Kitobda bo‘shliq → **IFU asosida yopildi**: `alfa-amilaza-cnpg3` |
| Siydik kislotasi (urikaza-PAP) | Yo‘q | ADTI 7-bo‘lim — urikaza tamoyili | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `siydik-kislotasi-urikaza-pap` |
| Kalsiy | Yo‘q | Aripova 2007, Yusupova 145-b. — me’yor/talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `kalsiy-arsenazo-iii` |
| Temir | Yo‘q | Kurbonova (anemiya boblari) — talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `temir-ferrozin` |
| Fosfat | Yo‘q | Yusupova 145-b. — talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `fosfor-fosfomolibdat-uv` |
| Magniy | Yo‘q | Aripova 2007 (me’yor), Yusupova 145-b. — talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `magniy-ksilidil-kok` |
| CRB (lateks) | Yo‘q | Saidov 2017, 28-b.; Yusupova 146-b. — referens/talqin | Lateks sinamasi tartibi | Kitobda bo‘shliq → **IFU asosida yopildi**: `crb-lateks-agglyutinatsiya` |
| Revmatoid omil | Yo‘q | Saidov 2017, 27-b. — referens/talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `revmatoid-omil-lateks` |
| ASLO | Yo‘q | Saidov 2017, 28-b. — referens/talqin | Hammasi | Kitobda bo‘shliq → **IFU asosida yopildi**: `aslo-lateks` |
| **D vitamini (25-OH D)** | Yo‘q (immunoanaliz; fotometrik emas) | Drive’da usul yo‘q (`ВИТАМИНЛАР.doc` — biokimyo; Aripova 2007 — raxit; Yusupova 145-b. — eslatma) | ELISA/CLIA protokoli, kalibrator, birliklar | Kitobda bo‘shliq → **IFU asosida yopildi**: `d-vitamini-25oh-elisa` |

### Manbasi bor testlar: yangi «yarim avtomat analizator» bo‘limi

Aripov va b. (2006) I bobidagi «… aniqlash uchun dastur tuzish» jadvallari va usul jadvallaridan. Mavjud
protokollarga ikki slayd qo‘shildi: **«Reaktivni tayyorlash (yarim avtomat analizator uchun)»** (ishchi reagent,
aralashtirish nisbati, barqarorlik, kalibrovka/blank, nol, IFU ustunligi haqida eslatma) va **«Yarim avtomat
analizator: … dasturi»** (rejim, nol, birlik, harorat, kalibrovka/omil, hajmlar, filtr, vaqtlar, me’yor, chiziqlilik).

| Protokol (id) | Manba bo‘limi | Manbadagi ichki ziddiyatlar — ochiq ko‘rsatilgan |
|---|---|---|
| `alt-kinetik-fotometrik` | I bob, «AlAT ni aniqlash uchun dastur tuzish» + «AlAT ni aniqlash usuli» (kinetika, 340 nm, 37 °C, omil 1746, monoreagent 10:1, 60/30 s, chiziqlilik 2,250/0,800/0,350) | Namuna hajmi: dasturda 5,0 µl, qo‘lda 50 µl |
| `mochevina-ureaza-gldg` | I bob, «Mochevinani aniqlash uchun dastur tuzish» (belgilangan vaqt, 340 nm, 5,0/500 µl, 30/60, chiziqlilik 2,0/0,7/0,4) | Dasturdagi me’yor 1,6–8,3, usul bo‘limida 1,66–8,3 mmol/l |
| `glyukoza-gox-pod-fotometrik` | I bob, «Glyukozani aniqlash uchun dastur tuzish» (oxirgi nuqta, 505 nm, standart 5,56, 5,0/500 µl, chiziqlilik 27,8) | Elektron nusxada inkubatsiya/reaksiya vaqti qatorlari siljigan — olinmadi; nol: dasturda suvga, qo‘lda reagentga qarshi |
| `bilirubin-umumiy-bogllangan` | I bob, «Umumiy/bog‘langan bilirubinni aniqlash uchun dastur tuzish» (oxirgi nuqta, 546 nm, 30,0/500 µl, chiziqlilik 340) | Harorat: dasturda 37 °C, qo‘lda xona harorati; reagent hajmi: dasturda 500 µl, qo‘lda 0,45 ml |
| `gemoglobin-gemiglobintsianid` | I bob, «Gemoglobinni aniqlash uchun dastur tuzish» (oxirgi nuqta, 546 nm, chiziqlilik 240 g/l) | Hajmlar: dasturda 50,0 µl / 1250 µl, qo‘lda 5 µl / 1,25 ml |

Yangi umumiy protokol: **`yarim-avtomat-biokimyo-analizator`** — «Yarim avtomat biokimyoviy analizatorda ishlash:
test dasturi, kalibrovka, nazorat» (Aripov va b., 2006: I bob — Screen Master tavsifi va dastur jadvallari; III bob —
ichki sifat nazorati, jadval 3.2). Manbada **yo‘q** va shuning uchun yozilmagan: lampani qizdirish vaqti, yuvish
tartibi, kunlik/haftalik texnik xizmat — slaydda «analizator qo‘llanmasidan oling» deb aytilgan. Mindray BA-88A,
Rayto, BTS-350, Humalyzer bo‘yicha o‘qiladigan manba Drive’da yo‘q (DECKS_COVERAGE.md dagi d041/d116 izohi bilan bir
xil) — ular nomi bilan parametr berilmagan.

## Kitoblarda yo‘q 19 test: ishlab chiqaruvchi IFU lari bo‘yicha yopildi (2026-10-18)

Kurs kitoblarida usuli bo‘lmagan 19 test uchun manba — ishlab chiqaruvchi o‘z saytida **ochiq** e’lon qilgan to‘plam
yo‘riqnomasi (IFU, instructions for use). Qoidalar:

- **Bitta protokol — bitta to‘plam.** Ikki to‘plam qiymatlari aralashtirilmagan (test: `test_one_kit_per_protocol`).
  To‘plamlar orasida farq bo‘lgani uchun har test uchun bitta hujjatli to‘plam tanlangan; boshqa to‘plamlar bor ekani
  birinchi slaydda aytiladi.
- Har protokolning birinchi slaydi: «bu protokol misol sifatida <ishlab chiqaruvchi> «<to‘plam>» IFU siga (kod, tahrir
  sanasi) asoslangan; laboratoriyangizdagi to‘plam IFU si har doim ustun». Fotometrik testlarda «Reaktivni tayyorlash
  (yarim avtomat analizator uchun)» slaydi ham IFU ustunligini takrorlaydi.
- Har bir son (to‘lqin uzunligi, harorat, hajm, nisbat, inkubatsiya/o‘qish vaqti, omil/standart konsentratsiyasi,
  chiziqlilik, barqarorlik, me’yor) IFU sahifasidan. So‘zma-so‘z parchalar (URL, hujjat kodi, tahrir sanasi, sahifa,
  PDF sha256) — `tool/slides/data/ifu_source_excerpts.json`; `tool/slides/test_ifu_protocols.py` har slayddagi har
  bir son (uz/ru/en) shu parchada borligini va uch tilda sonlar bir xilligini tekshiradi.
- Analizator dasturi jadvali IFU dagi **qo‘lda bajarish sxemasidan** (1,0 ml reagent + namuna, sharoit, vaqt, omil)
  olingan — yarim avtomat analizatorga aynan shu qiymatlar kiritiladi; analizator modeliga xos parametrlar
  (aspiratsiya hajmi, yuvish, kyuveta turi) IFU da yo‘q va yozilmagan.

### Test bo‘yicha manba

Barcha SPINREACT hujjatlari: SPINREACT, S.A.U., Sant Esteve de Bas (Girona), Ispaniya; ko‘p tilli varaqaning ingliz
tilidagi sahifasi; manzil `https://www.spinreact.com/assets/files/Inserts/…`, 2026-10-18 da yuklab olingan.

| Test | Protokol (id) | Hujjat (kod, tahrir) | Fayl (`…/Inserts/`), sahifa | Natija |
|---|---|---|---|---|
| Kreatinin (Yaffe, kinetik) | `kreatinin-yaffe-kinetik` | CREATININE-J, BSIS13-I, 07/11/22 | `Bioquimica/bsis13_crea-j-2022-nuevas-precauciones.pdf`, 2-b. | Qo‘shildi |
| Umumiy oqsil (biuret) | `umumiy-oqsil-biuret` | TOTAL PROTEIN, BSIS30-I, 08/11/22 | `Bioquimica/bsis30_prot-tot-2022-noves-precaucions.pdf`, 2-b. | Qo‘shildi |
| Albumin (BCG) | `albumin-bromkrezol-yashil` | ALBUMIN, BSIS02-I, 11/02/16 | `albumina.pdf`, 2-b. | Qo‘shildi |
| Umumiy xolesterin (CHOD-PAP) | `umumiy-xolesterin-chod-pap` | CHOLESTEROL (CHOD-POD), BSIS11-I, 23/12/25 | `Bioquimica/bsis11_colesterol-2025.pdf`, 2-b. | Qo‘shildi |
| Triglitseridlar (GPO-PAP) | `triglitseridlar-gpo-pap` | TRIGLYCERIDES (GPO-POD), BSIS31-I, 17/09/20 | `triglycerides-trigliceridos.pdf`, 2-b. | Qo‘shildi |
| YZLP xolesterini (HDL) | `yzlp-xolesterin-hdl` | HDLc-D (to‘g‘ridan-to‘g‘ri), BSIS37-I, 13/09/18 | `Bioquimica/BSIS37_HDLc_02-2018.pdf`, 2-b. | Qo‘shildi |
| AST | `ast-kinetik-ifcc` | GOT (AST)-LQ, BEIS46-I, 02/11/22 | `Bioquimica/beis46_gotast-lq-2022-noves-precaucions.pdf`, 2-b. | Qo‘shildi |
| Ishqoriy fosfataza | `ishqoriy-fosfataza-kinetik` | ALP-LQ (DGKC), BEIS44-I, 02/03/23 | `Bioquimica/beis44_alp-lq-2023-noves-precaucions.pdf`, 2-b. | Qo‘shildi |
| GGT | `ggt-kinetik` | γ-GT (karboksi substrat), BEIS08-I, 06/06/16 | `Bioquimica/BEIS08_GGT_2016.pdf`, 2-b. | Qo‘shildi |
| α-amilaza | `alfa-amilaza-cnpg3` | AMYLASE-LQ (CNPG3), BEIS27-I, 07/06/16 | `Bioquimica/BEIS27_AMILASA-LQ_02-2016.pdf`, 2-b. | Qo‘shildi |
| Siydik kislotasi | `siydik-kislotasi-urikaza-pap` | URIC ACID (urikaza-POD), BSIS01-I, 04/02/16 | `uric-acid-acido-urico.pdf`, 2-b. | Qo‘shildi |
| Kalsiy | `kalsiy-arsenazo-iii` | CALCIUM-A III (arsenazo III), BSIS09-I, 07/11/22 | `Bioquimica/bsis09_ca-a-iii-2022-noves-precaucions.pdf`, 2-b. | Qo‘shildi |
| Temir | `temir-ferrozin` | IRON-FZ (ferrozin), BSIS24-I, 08/11/22 | `Bioquimica/bsis24_fe-2022-noves-precaucions.pdf`, 2-b. | Qo‘shildi |
| Fosfat | `fosfor-fosfomolibdat-uv` | PHOSPHORUS-UV (fosfomolibdat), BSIS15-I, 08/11/22 | `Bioquimica/bsis15_p-uv-2022-nuevas-precauciones-en-espera.pdf`, 1-b. | Qo‘shildi |
| Magniy | `magniy-ksilidil-kok` | MAGNESIUM (ksilidil ko‘ki), BSIS79-I, 08/11/22 | `Bioquimica/bsis79_mg-xilidil-2022-noves-precaucions.pdf`, 2-b. | Qo‘shildi |
| CRB (lateks) | `crb-lateks-agglyutinatsiya` | CRP-LATEX, SGIS03-I, 17/01/23 | `Serologia/sgis03_crp-2023-noves-precaucions.pdf`, 2-b. | Qo‘shildi |
| Revmatoid omil (lateks) | `revmatoid-omil-lateks` | RF-LATEX, SGIS02-I, 23/01/26 | `Serologia/sgis02_fr-dmc-2026.pdf`, 2-b. | Qo‘shildi |
| ASLO (lateks) | `aslo-lateks` | ASO-LATEX, SGIS01-I, 27/10/25 | `Serologia/sgis01_aso-2025.pdf`, 2-b. | Qo‘shildi |
| D vitamini (25-OH D) | `d-vitamini-25oh-elisa` | Immusmol SAS (Bordo, Fransiya), «25-OH Vitamin D (total) ELISA» MS E-5800 (IVD), IFU Version 11.0, effective 2024-08-02 | `https://immusmol.com/wp-content/uploads/2025/02/IFU-MS-E-5800-V11.0.pdf`, 1–7-b. | Qo‘shildi |

Bo‘shliq sifatida qolgan test yo‘q (19/19).

### Manbadagi g‘alati yoki ziddiyatli joylar — qanday hal qilindi

- **HDL:** IFU da to‘lqin uzunligi ikki joyda turlicha — «Procedure»da 550–650 nm, «Additional equipment»da 570 nm;
  slaydda ikkalasi ham ko‘rsatilgan (570 nm oraliq ichida). Cho‘ktirish usuli (SPINREACT HDLc-P, BSIS12-I) tanlanmadi:
  uning IFU si hisoblashni umumiy xolesterin IFU siga topshiradi, supernatantning suyultirish omilini aytmaydi — ikki
  hujjatni birlashtirish kerak bo‘lardi.
- **ASLO:** IFU me’yorida «Up to 200 IU/mL (adults) and ≥150 IU/mL (children < 6 years old)» — bolalar uchun «≥» belgisi
  g‘alati; o‘zgartirilmay, «o‘z IFU ingizdan tekshiring» ogohlantirishi bilan berilgan (test: `test_source_oddities_are_shown_not_hidden`).
- **Ishqoriy fosfataza:** R1 dagi dietanolamin konsentratsiyasi IFU da «1 mmol/L» (pH 10,4 bufer uchun shubhali) —
  slaydga **olinmagan**; faqat pH va MgCl2 berilgan. **Kalsiy:** arsenazo III «120 mmol/L» — xuddi shunday olinmagan.
- **Fosfor:** «Inorganic phosphate increases by 4 to 5 mg/dL per day» (gemolizlangan namunani saqlashda) — mantiqan
  shubhali, slaydga son olinmagan (faqat «gemolizlangan namuna yaroqsiz» qoidasi).
- **Belgilar:** `pdftotext` PDF shriftidagi µ, Δ, ≥, γ, ±, → belgilarini ba’zan tushirib qoldiradi. Slaydda ishlatilgan
  «≥» chegaralari (albumin ≥ 0,40; xolesterin ≥ 0,1 va ≥ 240 mg/dl; GGT ≥ 1,80) PDF sahifasining tasviridan tekshirildi.
  Belgisi tasvirdan tekshirilmagan blank chegaralari (IF, amilaza, siydik kislotasi, fosfor) slaydga olinmagan.
- **GGT:** R2 tabletkasini eritish hajmi qadoqqa bog‘liq (1001185/1001186/1001187) — slaydda misol (15 ml) va «aniq hajm
  o‘z IFU ingizda» deyilgan.

### Qidirilgan, lekin tanlanmagan manbalar

- **DiaSys** (diasys-diagnostics.com) — D vitaminidan boshqa 18 test uchun ingliz tilidagi IFU lar ochiq va yuklab
  olindi, lekin ularning ko‘pchiligi faqat avtomatik analizator (BioMajesty) uchun hajmlarni beradi (masalan, kreatinin: namuna 5 µl + R1 80 µl
  + R2 20 µl, «Cycle 19/24/32»), qo‘lda/yarim avtomat pipetkalash sxemasi yo‘q. Yarim avtomat analizator uchun hajmni
  o‘zim qayta hisoblashim kerak bo‘lardi — shuning uchun olinmadi.
- **BioSystems** (biosystems.es), **Human** (human.de) — 403; **Linear Chemicals** (linear.es) — ulanmadi.
- **NIH ODS** «Vitamin D — Fact Sheet for Health Professionals» (ods.od.nih.gov, HTML va PDF) — 403 (curl va
  WebFetch). **NCBI Bookshelf** (IOM 2011 «Dietary Reference Intakes for Calcium and Vitamin D», NBK56061) — brauzer
  tekshiruvi (reCAPTCHA), matn olinmadi. Shu sababli D vitamini protokoli faqat IFU ga tayanadi; status tasnifi
  (tanqislik/yetishmovchilik/yetarli/toksiklik) IFU ning o‘zida keltirilgan adabiyot jadvalidan.
- **BioVendor** 25-OH Vitamin D ELISA — IFU «Research Use Only» (diagnostika uchun emas) → olinmadi. R&D Systems
  RDKAP1971 IFU — server javob bermadi.
- SPINREACT saytidagi boshqa variantlar (GOT eski BEIS09, ALP DGKC beis07, kalsiy o-krezolftalein BSIS08 — xloroform/
  metanolli reagent, HDLc-P BSIS12) yuklab olindi, lekin har test uchun bitta hujjat tanlandi (yuqoridagi jadval).

## D vitamini

- Drive kitoblarida 25-OH D ni aniqlash protokoli yo‘q edi; 2026-10-18 da **Immusmol 25-OH Vitamin D (total) ELISA IFU
  (MS E-5800, v11.0)** asosida `d-vitamini-25oh-elisa` protokoli qo‘shildi: raqobatli ELISA, standartlar 0–120 ng/ml,
  mikroplanshet fotometri 450 nm. Bu yarim avtomat fotometrik analizator testi emas — slaydda ochiq aytilgan.
- Pack kartasi `vitamin-d` (assets/content/core/pack.json) tekshirildi: «nima o‘lchanadi» qismi manbali va to‘g‘ri —
  ko‘pchilik tahlillar 25(OH)D ni o‘lchaydi (MedlinePlus «What is a vitamin D test?»), namuna — venadan qon,
  natija «umumiy D vitamini» yoki D2/D3 alohida berilishi mumkin, faol 1,25(OH)2D boshqa tahlil (MedlinePlus).
  Kartaga yangi matn qo‘shilmadi (bu ish faqat protokollar to‘plamiga tegishli).
- NIH ODS sahifasi ushbu muhitdan ochilmadi (403) — qo‘shimcha kontekst (usullar orasidagi farq, VDSP standartlash)
  shu manba ochilganda qo‘shilishi mumkin.

## Tekshiruvlar

- `tool/slides/data/analyzer_source_excerpts.json` — Aripov 2006 dan so‘zma-so‘z parchalar (bo‘lim nomi bilan).
- `tool/slides/test_analyzer_protocols.py` — har bir yangi slayddagi har bir son (uz/ru/en) shu parchalarda borligi,
  uch tilda sonlar bir xilligi, IFU eslatmasi, manbadagi ziddiyatlar yashirilmagani.
- `tool/slides/data/ifu_source_excerpts.json` + `tool/slides/test_ifu_protocols.py` — 19 ta IFU protokolining HAR bir
  slaydi: son → IFU parchasi, uch til, bitta to‘plam, IFU ustunligi eslatmasi, parcha metama’lumotlari.
- `test/widget/lecture_library_test.dart` — yangi protokollar ochiladi va hamma slaydlari toshib ketmasdan chiziladi.
