# Amaliy protokollar: yarim avtomat analizator va keng tarqalgan tahlillar bo‘yicha manbalar qamrovi

Sana: 2026-10-17. Egasining so‘rovi: «Yarim avtomat analizatorlar uchun reaktiv tayyorlash bormi? D vitamini va
boshqa oddiy tahlillar ham». Qoida: har bir qadam, hajm, to‘lqin uzunligi, omil, vaqt va me’yor faqat o‘qiladigan
manbadan (muallif, kitob, bo‘lim/sahifa). Manba bo‘lmasa — protokol yozilmaydi, bo‘shliq shu yerda ko‘rsatiladi.

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

| Test | Yarim avtomat usuli manbada | Topilgan joy (kitob, bo‘lim/sahifa) | Nima yetishmaydi | Protokol |
|---|---|---|---|---|
| Kreatinin (Yaffe, kinetik) | Yo‘q | Kurbonova 2023, 34–35-b. (faqat Reberg–Tareev sinamasi, KFT formulasi); Yusupova 2022, 163-b. (klinik ahamiyati) | Reagent, to‘lqin, vaqt, omil — hammasi | Bo‘shliq |
| Umumiy oqsil (biuret) | Yo‘q (qisman qo‘lda) | Aripova 2007, 18-b.: kalibrovka 0,5/1,0/1,5% oqsil eritmalari, 4 ml biuret reaktivi, xona haroratida 20 daqiqa, FEK, 1 sm kyuveta | Namuna hajmi, to‘lqin uzunligi, reaktiv tarkibi, hisoblash — yo‘q; Yusupova 82-b. va Agzamxodjaev — biuret faqat siydik oqsili uchun | Bo‘shliq |
| Albumin (BCG) | Yo‘q | — | Hammasi | Bo‘shliq |
| Umumiy xolesterin (CHOD-PAP) | Yo‘q | ADTI 7-bo‘lim (xolesterinoksidaza tamoyili); Aripova 2007 — faqat me’yor | Hammasi | Bo‘shliq |
| Triglitseridlar (GPO-PAP) | Yo‘q | — | Hammasi | Bo‘shliq |
| YZLP xolesterini (HDL) | Yo‘q | — | Hammasi | Bo‘shliq |
| AST | Yo‘q (eski qo‘lda) | Aripova 2007, 53–54-b.: 2,4-DNFG kolorimetrik usul (kalibrovka egri chizig‘i bilan) | Kinetik (IFCC tipidagi) usul manbada yo‘q; DNFG usuli ALT protokolida eskirgan deb olinmagan — AST uchun ham olinmadi | Bo‘shliq |
| Ishqoriy fosfataza | Yo‘q | Kurbonova 2023, 73, 76, 144, 162-b.; Yusupova 146-b. — talqin | Hammasi | Bo‘shliq |
| GGT | Yo‘q | Yusupova 146-b. — talqin | Hammasi | Bo‘shliq |
| α-amilaza | Yo‘q (qo‘lda, zid) | Aripova 2007, 55–56-b.: Karavey (kraxmal–yod) usuli ikki xil yozilgan (1 ml kraxmal + 0,02 ml namuna va 0,5 ml + 0,01 ml), natija birligi «mg/sutka», me’yorlar mmol/l — o‘zaro zid | Ishonchli parametrlar | Bo‘shliq |
| Siydik kislotasi (urikaza-PAP) | Yo‘q | ADTI 7-bo‘lim — urikaza tamoyili | Hammasi | Bo‘shliq |
| Kalsiy | Yo‘q | Aripova 2007, Yusupova 145-b. — me’yor/talqin | Hammasi | Bo‘shliq |
| Temir | Yo‘q | Kurbonova (anemiya boblari) — talqin | Hammasi | Bo‘shliq |
| Fosfat | Yo‘q | Yusupova 145-b. — talqin | Hammasi | Bo‘shliq |
| Magniy | Yo‘q | Aripova 2007 (me’yor), Yusupova 145-b. — talqin | Hammasi | Bo‘shliq |
| CRB (lateks) | Yo‘q | Saidov 2017, 28-b.; Yusupova 146-b. — referens/talqin | Lateks sinamasi tartibi | Bo‘shliq |
| Revmatoid omil | Yo‘q | Saidov 2017, 27-b. — referens/talqin | Hammasi | Bo‘shliq |
| ASLO | Yo‘q | Saidov 2017, 28-b. — referens/talqin | Hammasi | Bo‘shliq |
| **D vitamini (25-OH D)** | Yo‘q (immunoanaliz; fotometrik emas) | Drive’da usul yo‘q (`ВИТАМИНЛАР.doc` — biokimyo; Aripova 2007 — raxit; Yusupova 145-b. — eslatma) | ELISA/CLIA protokoli, kalibrator, birliklar | **Bo‘shliq** — pastga qarang |

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

## D vitamini

- Drive kitoblarida 25-OH D ni aniqlash protokoli yo‘q → **protokol yozilmadi** (bo‘shliq).
- Pack kartasi `vitamin-d` (assets/content/core/pack.json) tekshirildi: «nima o‘lchanadi» qismi manbali va to‘g‘ri —
  ko‘pchilik tahlillar 25(OH)D ni o‘lchaydi (MedlinePlus «What is a vitamin D test?»), namuna — venadan qon,
  natija «umumiy D vitamini» yoki D2/D3 alohida berilishi mumkin, faol 1,25(OH)2D boshqa tahlil (MedlinePlus).
  Shu sababli kartaga yangi matn qo‘shilmadi.
- Pack manbalari **laboratoriya usulini** (immunoanaliz ELISA/CLIA yoki LC-MS/MS) aytmaydi — MedlinePlus sahifasi
  2026-10-17 da qayta ochilib tekshirildi: usul va birliklar ko‘rsatilmagan. Usul haqida yozish uchun yangi rasmiy
  manba kerak (masalan, NIH ODS «Vitamin D — Fact Sheet for Health Professionals» yoki aniq to‘plamning IFU’si) —
  egasi tasdiqlasa qo‘shiladi.

## Tekshiruvlar

- `tool/slides/data/analyzer_source_excerpts.json` — Aripov 2006 dan so‘zma-so‘z parchalar (bo‘lim nomi bilan).
- `tool/slides/test_analyzer_protocols.py` — har bir yangi slayddagi har bir son (uz/ru/en) shu parchalarda borligi,
  uch tilda sonlar bir xilligi, IFU eslatmasi, manbadagi ziddiyatlar yashirilmagani.
- `test/widget/lecture_library_test.dart` — yangi protokol ochiladi va hamma slaydlari toshib ketmasdan chiziladi.
