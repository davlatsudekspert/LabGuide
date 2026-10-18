# Mustaqil tibbiy-kontent ko‘rigi: 6 bo‘lim (2026-10-18)

Bo‘limlar: sitologiya, spermogramma, qon guruhi, gistologiya, siydik tahlili, qon morfologiyasi.
Bu ko‘rik ishlamay qolgan AI-API ko‘rigi o‘rnida qilindi. Egasining qoidasi: «xato qilishga
haqqimiz yo‘q». Shuning uchun har bo‘limda raqamlar, birliklar, tasniflar va referens chegaralari
**shu sessiyada qayta ochilgan birlamchi manba matni** bilan solishtirildi (PDF → matn, Europe
PMC to‘liq matni, rasmiy sahifalar). Avvalgi audit: `AUDIT_2026-10-17_NEW_SECTIONS_MEDICAL.md`.

Hukm: **OK** — manbadagi so‘z/raqam bilan mos; **tuzatildi** — xato topildi va tuzatildi;
**mutaxassis** — manba bilan to‘liq tasdiqlab bo‘lmadi yoki manbaning o‘zi shubhali, domla
qarori kerak.

## Usul

1. Har bo‘lim kontent fayli (`*_content.dart`, `cytology_more.dart`) to‘liq o‘qildi: inglizcha va
   ruscha matn to‘liq, o‘zbekcha — raqamlar va ma’no bo‘yicha.
2. Uch til raqamlari avtomatik solishtirildi (har `LocalizedText` dagi barcha sonlar uz = ru = en):
   farq topilmadi (faqat «AB0»/«ABO» yozuvi va so‘z bilan yozilgan «bir/two» kabi sonlar).
3. Birlamchi manbalar shu sessiyada qayta yuklab olindi:
   - JSST 2021 sperma qo‘llanmasi (iris.who.int, bitstream 4038e736…, 9789240030787-eng.pdf) va
     JSST 2010 (9789241547789_eng.pdf, ruscha nashr ham) — `pdftotext`;
   - JSST *Manual of basic techniques for a health laboratory* 2003 (9241545305.pdf) — `pdftotext`;
   - JSST *Safe Blood… Module 3*, BSH 2012 (Transfus Med 2013), UK HTM 2013, RF № 1134н —
     oldingi sessiya matnlari qayta grep qilindi;
   - Delanghe 2014 (PMC3936984), Pangarkar 2022, Kattoor 2022, Kamal 2022, Poflee 2022,
     Kamal–Topiwala 2022, Wojcik 2026, ASCCP 2019 (PMC7147428), Cattaneo 2025 (PMC12358786),
     Adewoyin 2014 (PMC4415389), Takami 2026 (PMC13639491) — Europe PMC to‘liq matni;
   - AAFP 2005 va 2022 urinalysis sharhlari (aafp.org sahifa matni, jadvallar bilan);
   - Michigan Histology Laboratory Manual (2026-02-12 PDF, 306 bet);
   - CDC STI 2021 (gonoreya), MedlinePlus Pap smear, MSD «Evaluation of Anemia», HPA Liver,
     EAU Male Infertility — sahifa matni.

## Topilgan va tuzatilgan xatolar

| # | Bo‘lim | Oldin | Keyin | Manba (aniq joy) |
|---|---|---|---|---|
| 1 | Qon morfologiyasi — Trombotsitlar | «500–1000 eritrotsitga bitta trombotsit — taxminan me’yor» (uz/ru/en) | «×100 da 20 maydon; trombotsit/eritrotsit nisbati × eritrotsitlar soni. Adewoyin: normada ×100 maydonda ≈ 7–15 trombotsit; maydondagi 1 trombotsit ≈ 15–20 ×10⁹/L» | JSST 2003 §9.14 p. 321 jumlasi so‘zma-so‘z shunday, lekin u JSST ning o‘z Table 9.13 (kattalar 1,7–4,0 ×10⁵/mm³) bilan zid: RBC 4–5 ×10¹²/L da nisbat ≈ 1:10–1:30; 1:500–1000 — og‘ir trombotsitopeniya (≈ 5–10 ×10⁹/L). Yangi raqamlar: Adewoyin 2014, «Platelet morphology»: «approximately 7–15 platelets on x100 objective. A platelet/hpf is equivalent to approximately 15,000–20,000 platelets» |
| 2 | Qon guruhi — Qaydlar | «Transfuziyadan oldingi namuna kamida 3 kun saqlanadi» | «…transfuziyadan **keyin** kamida 3 kun saqlanadi» (ru «после трансфузии», en «post-transfusion») | BSH 2012 §3.9.2, p. 8: «retained for at least 3 days post-transfusion» (Key recommendation ham shunday). Eski matn muddatni namuna olingan kundan hisoblashga undardi |
| 3 | Sitologiya — Gonokokk kartasi | «Erkaklarda uretra surtmasida gonoreya uchun yuqori ishonchli» | «Simptomli erkaklarda — diagnostik; simptomsiz erkaklarda manfiy surtma istisno qilmaydi; endotservikal Gram sezgir emas — NAAT» | CDC STI 2021, Gonococcal infections: «considered diagnostic… among symptomatic men»; «a negative Gram stain should not be considered sufficient for ruling out infection among asymptomatic men»; «Gram stain of endocervical… specimens… is insensitive» |
| 4 | Sitologiya — Boshqa namunalar, Parij tizimi | 5 toifa (Unsatisfactory, NHGUC, AUC, SHGUC, HGUC) — to‘liq ro‘yxatdek | 6-toifa qo‘shildi: «Urotelial bo‘lmagan xavfli o‘smalar (Non-urothelial; ilgari "boshqa xavfli o‘smalar")» | Wojcik 2026, Table 2 (TPS 2.0 diagnostic categories): «Non‑urothelial — Previously called other malignancies» |
| 5 | Gistologiya — Luxol fast blue | «miyelin **va Nissl moddasini** bo‘yaydi» | «asosan miyelinni bo‘yaydi (klassik Klyuver–Barrera usulida hujayralar va Nissl moddasi uchun qo‘shimcha bo‘yoq bilan)» | Michigan manual p. 9 «myelin and Nissle bodies» deydi, lekin keltirgan asl ish — Klüver & Barrera 1953 «Combined Staining of **Cells and Fibers**»: Nissl moddasini kombinatsiyadagi ikkinchi (krezil) bo‘yoq ko‘rsatadi. Yumshatildi, **mutaxassis** tasdig‘i kerak |
| 6 | Gistologiya — Jigar | uz «portal yo‘llar (o‘rtacha **oltitagacha**)» (= «oltitagacha»), ru/en «в среднем около шести / on average six» | uz «o‘rtacha oltita» | HPA Liver: «surrounded on average by six portal tracts» — ma’no siljishi tuzatildi |

Har tuzatishga regressiya testi qo‘shildi (`test/widget/{cytology,bloodgroup,bloodmorph,histology}_test.dart`,
«tibbiy ko‘rib chiqish 2026-10-18»). Manba hujjatlari yangilandi: `BLOODMORPH_SOURCES.md`,
`BLOODGROUP_SOURCES.md`, `CYTOLOGY_SOURCES.md`, `HISTOLOGY_SOURCES.md`.

## 1. Sitologiya (`cytology_content.dart`, `cytology_more.dart`)

| Da’vo | Manba | Hukm |
|---|---|---|
| Bethesda 2014 toifalari: NILM, ASC-US, LSIL, ASC-H, HSIL, SCC, AGC (endotservikal/endometrial/NOS), AGC favor neoplastic (endotservikal/NOS), AIS, adenokarsinoma (endotservikal/endometrial/bachadondan tashqari/NOS) | Pangarkar 2022, «The 2014 Bethesda System» jadvali | OK |
| «Favor neoplastic» — AIS/adenokarsinomaga yetmaydi | Wang 2023 (PMC10348779): «falls short of the interpretation for… AIS or invasive adenocarcinoma» | OK |
| An’anaviy surtma 8 000–12 000, suyuq asosli 5 000 yassi hujayra | Wang 2023: «5,000 (LBP) and 8,000–12,000 (CP…)» | OK |
| 2 000 hujayra chegarasi (atrofiya, gisterektomiya, nur/kimyo) | Pangarkar 2022 «Cellularity»: «can be lowered to 2000 cells in atrophic, post-hysterectomy… post-therapy»; Wang 2023 | OK |
| TZ komponenti ≥ 10 endotservikal/metaplastik hujayra, ikkala preparatda | Pangarkar: «at least 10 well-preserved endocervical/squamous metaplastic cells, singly, or in clusters» | OK |
| > 75 % yopilgan — yaroqsiz | Wang 2023: «more than 75% of squamous cells… obscured» | OK |
| Anomal hujayrali namuna — ta’rifga ko‘ra yaroqli | Pangarkar: «Any smear with abnormal cells is by definition satisfactory» | OK |
| Yaroqsiz + HPV yo‘q/noma’lum/manfiy → 2–4 oyda takror; HPV triaji tavsiya etilmaydi | ASCCP 2019 G.2: «repeat age-based screening… in 2 to 4 months… Triage using HPV testing is not recommended» | OK |
| AGC: kolposkopiya + endotservikal namuna; ≥ 35 yosh yoki xavf → endometrial; atipik endometrial hujayralarda avval endometrial + endotservikal | ASCCP 2019 G.1 (to‘liq matn qayta o‘qildi): «initial evaluation limited to endometrial and endocervical sampling is preferred» | OK |
| HSIL: kolposkopiya yoki tezlashtirilgan davolash (biopsiyasiz) | ASCCP 2019 Major changes 3: «expedited treatment, defined as treatment without preceding colposcopic biopsy» | OK |
| ASC-US yadrosi oraliq yadrodan 2,5–3× (metaplastikdan ~2×) | Kattoor 2022: «2.5–3 times the area of a normal intermediate nucleus… or twice the size of a squamous metaplastic cell nucleus» | OK |
| Reaktiv yadro < 2× oraliq yadro | Kamal 2022: «nuclear size remains <2 times the size of an intermediate cell nucleus» | OK |
| Nur: erta (6 oy) — kattalashish, N:C saqlanadi, vakuola, ko‘p yadroli/g‘alati | Poflee 2022: «Acute changes are seen in the first 6 months… preserved N:C ratio, cytoplasmic vacuolation… multinucleated and bizarre-shaped cells» | OK |
| Yetilish indeksi: faqat yakka hujayra; parabazal ustun — atrofiya, tug‘ruqdan keyin, faqat progestinli kontratseptiv; erta menopauzada oraliq ustun; shartlar; qin yon devori | Kamal–Topiwala 2022 (to‘liq matn): «Cells in cell clusters are not counted»; «shift to left… progestin-only contraceptives»; «In early menopause… intermediate cell predominance»; «Prerequisites…»; «proximal portion of the lateral wall of the vagina» | OK |
| Seroz suyuqlik: ND, NFM, AUS, SFM, MAL | Wang 2023 Serous, Table 1 | OK |
| JSST o‘pka tizimi: 5 toifa | Dolezal 2024 | OK |
| Parij tizimi 2-nashr toifalari | Wojcik 2026 Table 2–3 | **tuzatildi** (#4) |
| Gonokokk: Gram surtma ishonchliligi | CDC 2021 | **tuzatildi** (#3) |
| Bemor tayyorgarligi: hayzdan tashqari, 2 kun jinsiy aloqa/chayish/qin dorilari/spermitsidsiz | MedlinePlus Pap smear: «For two days before your test, you should not…» | OK |
| Trixomonada: nok shakli, ekssentrik yadro, 4 oldingi xivchin, to‘lqinsimon membrana, aksostil; NAAT | CDC DPDx, CDC 2021 | OK |
| Kandida psevdogifalari; kalit hujayra — Amsel mezonlaridan biri; laktobatsillalar sitolizi | CDC 2021 (BV, candidiasis); Kamal–Topiwala («cytolysis… intermediate cell») | OK |
| Qin surtmasi tozalik darajalari I–IV | РОАГ 2019 «Клинические рекомендации … патологическими выделениями из половых путей женщин», 2-е изд., «Бактериальный вагиноз — Классификация»: Heurlein (1910), 4 daraja, «лишь историческое значение»; Kurbonova 2023, 6.5, 70-b. (o‘zbek darsligi — Hay–Ison 0–IV); Ison & Hay 2002, Sex Transm Infect 78:413–415 | **tasdiqlandi (adabiyot: ROAG 2019; Kurbonova 2023, 70-b.; Ison–Hay 2002)** — ziddiyat ekranda ikkala qator bilan; darajalar matni — an’anaviy sxema (Heurlein asl matni ochiq emas) |
| Har darajaga pH oralig‘i (4,0–4,5 … 7,0–7,5) | yuqoridagi uch manbada yo‘q; Menshikov 1987 (Drive djvu, MCP orqali yuklab bo‘lmadi), Novikova 2018 §21.1.1 (ochiq PDF faqat parcha), WebSearch/CyberLeninka API — darslik manbasi topilmadi | **olib tashlandi** (manbasiz raqam ilovada qolmadi) |
| Ruscha AGC-FN atamasi | RF Minzdrav KR 597 (2024) «Цервикальная интраэпителиальная неоплазия, эрозия и эктропион шейки матки», «Список сокращений»: «атипичные железистые клетки, похожие на неопластичные»; Grigoruk 2024, 103-b.: «… подозрительные на аденокарциному» | **tasdiqlandi (adabiyot: KR 597 2024; Grigoruk 2024, 103-b.)** — atama KR 597 ga almashtirildi, ikkinchi variant ham ko‘rsatildi |

## 2. Spermogramma (`spermogram_logic.dart`, `spermogram_content.dart`)

| Da’vo | Manba (JSST 2021 PDF, bosma bet) | Hukm |
|---|---|---|
| Pastki chegaralar (95% IO), mediana, N: hajm 1,4 (1,3–1,5) mL, 3,0, 3586; konsentratsiya 16 (15–18), 66, 3587; umumiy son 39 (35–40), 210, 3584; umumiy harakat 42 (40–43), 64, 3488; PR 30 (29–31), 55, 3389; tiriklik 54 (50–56), 78, 1337; normal shakl 4 (3,9–4,0), 14, 3335 | Table 8.3, p. 212 — har katak qayta solishtirildi | OK |
| ~3500 erkak, 12 mamlakat; 5-persentil — fertil/infertil chegarasi emas; multiparametrik chegaralar yo‘q | §8.1.1 p. 211 («around 3500 men in 12 countries»); §8.1.3 p. 214; §8.1.2.1 p. 213 | OK |
| pH < 7,2 — urug‘ pufakchasi suyuqligi kamligi yoki siydik; 30 daq, har holda 1 soat ichida; spermatozoidsiz eyakulyatda pH < 7,0 — CBAVD | §2.4.2.5 p. 17–18; §2.5.4 | OK |
| EAU: pH > 7,2 «consensus threshold»; normal bo‘lsa bitta tahlil yetarli; ≥ 2 tahlilda o‘zgarish — qo‘shimcha tekshiruv; 6-nashrda atama chegaralari yo‘q | EAU Male Infertility §11.3.2, Table 11.2 (sahifa matni) | OK |
| Harakat toifalari a ≥ 25 µm/s (½ dum), b 5–< 25, c < 5 µm/s, d harakatsiz | §2.4.6.1 p. 24 | OK |
| Har takrorda ~200 spermatozoid; 200 ga yetsa ham maydon tugatiladi; yaxlitlash qoidasi 99/101 | §2.4.6 p. 24; §2.4.6.2 p. 25 | OK |
| Morfologiya ≥ 200; TZI = nuqsonlar ÷ anormal; sitoplazma > ⅓ bosh | §2.4.9.6 p. 51–54; TZI ta’rifi («between 1.00 and 4.00») | OK |
| Azoospermiya — faqat sentrifugalangan cho‘kmadan keyin; konsentratsiya 0 → «shubha» | §2.4.8.8 p. 35 | OK |
| Tiyilish 2–7 kun; masturbatsiya; lateks prezervativ, lubrikant; 20–37 °C; 30/60 daq; tashish 50 daq; idish; qabul qaydlari | §2.3.1 p. 13–14; §2.3.2 p. 14–15 (so‘zma-so‘z solishtirildi) | OK |
| Suyulish 30 + 30 daq 37 °C; tiriklik 30 daq / 1 soat | §2.4.6, p. 23–24; §2.4.7 p. 26 | OK |
| Atamalar ta’riflari, «-spermia/-zoospermia» qoidasi, umumiy son ustunligi | JSST 2010 Table A1.3, p. 225–226 (PDF matni) | OK |
| Nekrozoospermiya = past tiriklik VA ko‘p harakatsiz | JSST 2010 Table A1.3 | OK |

## 3. Qon guruhi (`bloodgroup_logic.dart`, `bloodgroup_content.dart`)

| Da’vo | Manba | Hukm |
|---|---|---|
| Landshteyner qoidasi, 4 kutilgan naqsh; nomuvofiqlikda guruh aytilmaydi; kuchsiz/aralash maydon — anomaliya | JSST Module 3 §4.1, §4.3; BSH §4.7.1, §4.8.1, Fig. A1; mantiq 16 kombinatsiya bo‘yicha oldingi auditda tekshirilgan, kod o‘zgarmagan | OK |
| ABO — eng muhim serologik test; ABO nomos eritrotsit «often fatal» | BSH §4.1.1; HTM §2.4.1 («often fatal») | OK |
| A1 ≈ 80 %, A2 ≈ 20 %; anti-A1: A2 da 2 %, A2B da 25 % | JSST Module 3 Fig. 10, p. 31 | OK |
| Plastinka — 2 daqiqa ichida; probirka — ≥ 45 daqiqa cho‘kish yoki yengil sentrifuga; lupa ×2–×5 | JSST §7.7 p. 79 (so‘zma-so‘z) | OK |
| Agglyutinatsiya darajalari 4+…1+, −, L | JSST §7.8 p. 79 | OK |
| Rulo — 1 tomchi 1,5 % gipertonik eritma; Varton dirildog‘i — 37 °C eritmada yuvish | JSST §7.14 p. 83–84 | OK |
| Fiziologik eritma pH 6,5–7,5 | JSST §7.4–7.5 | OK |
| RhD tanlash: istisnolar (> 50 yosh ayol, erkaklar) va doim D− (< 51 ayol, < 18, immun anti-D, transfuziyaga qaram) | BSH §7.8.1, §7.8.3, p. 19 | OK |
| Elektron berish qo‘llanmaydigan holatlar (ABO-nomos HSCT, 3 oy ichida ABO-nomos a’zo ko‘chirish, homila/chaqaloq + ona IgG) | BSH §7.5, p. 18 | OK |
| WBIT ≈ 1/2000 | BSH §7.2.1, p. 17 | OK |
| Reagent nazorati analizatorda ≥ har 12 soat | BSH §4.4.4, p. 11 | OK |
| Namunani saqlash muddati | BSH §3.9.2 | **tuzatildi** (#2) |
| SAG-M < 20 mL plazma | HTM 2013 p. 8 | OK |
| RF № 1134н: namuna ≤ 24 soat oldin, yorliq; kross usul; anti-D IgM; biologik sinama 15 daq 2 mL/daq (krioprecipitatdan tashqari); 48 soat 2–6 °C, ≥ 5 mL | 1134н п. 7, 11, 23, 28 (matn qayta grep) | OK |
| O‘zbekiston me’yorlari | lex.uz: Qonun 402-II, 10-modda (ishlatish tartibini SSV belgilaydi); PQ-19 (20.01.2026), 1-ilova 2-band (qon xizmati SOP — 2026-yil may); moslik sinamalari bo‘yicha SSV buyrug‘i ochiq bazada topilmadi (qidiruv so‘zlari BLOODGROUP_SOURCES.md da) | **qisman tasdiqlandi (adabiyot: Qonun 402-II; PQ-19)**; moslik sinamasi bo‘yicha milliy buyruq — **ochiq** |
| Ruscha atamalar «большая/малая проба», «солевая проба с немедленным центрифугированием», «электронная выдача» | № 1134н п. 14 «г», 17, 19, 20 va Аксельрод 2018 (Гематология и трансфузиология 63(4):372–435) — «проба на индивидуальную совместимость», «проба на совместимость с использованием непрямого антиглобулинового теста»; «большая/малая», immediate spin, электронная выдача — yo‘q | **tuzatildi (adabiyot: № 1134н; Аксельрод 2018)** — «major/minor (термины ВОЗ)», IAT nomi 1134н bo‘yicha, immediate spin va electronic issue kartalarida «в приказе № 1134н нет» |

## 4. Gistologiya (`histology_content.dart`)

| Da’vo | Manba | Hukm |
|---|---|---|
| H&E: gematoksilin asosli bo‘yoq, nuklein kislotalar; eozin kislotali; kollagen qizil-to‘q sariq, aktin pushtiroq, elastin shishasimon qizil | Michigan manual p. 6 (so‘zma-so‘z) | OK |
| Masson: kollagen/retikulyar/shilliq ko‘k yoki yashil, muskul qizil, yadro qizil (temir gematoksilinda qora) | Michigan p. 7 | OK |
| Elastik bo‘yoqlar (aldegid-fuksin, Veygert, Verxoff–van Gizon), kumush (III tip kollagen), PAS (bazal membrana, glikokaliks) | Michigan p. 7–9 | OK |
| LFB | Michigan p. 9 + Klüver–Barrera 1953 | **tuzatildi / mutaxassis** (#5) |
| Gialin tog‘ay — II tip kollagen, siqilishga chidamli, tomirsiz; elastik — quloq suprasi, epiglottis, hujayra ko‘p, faqat elastin bo‘yog‘ida ishonchli; tolali — I+II tip, perixondriysiz, disk, cho‘zilishga mustahkam, suyakka birikadi | Michigan p. 111–114 (amaliy savollar javoblari bilan) | OK |
| Jigar: plastinkalar, sinusoidlar, Kupffer, triada, qon portaldan markaziy venaga | Michigan p. 197; HPA Liver | OK |
| Bo‘lakcha atrofida o‘rtacha 6 portal yo‘l | HPA Liver: «on average by six portal tracts» | **tuzatildi** (uz, #6) |
| Zonalar 1–3 | Boyd 2020; Michigan amaliy savoli («Zone 1 is the first zone to receive nutrients…») | OK |
| Buyrak: tanacha, proksimal (atsidofil, cho‘tkasimon hoshiya, eng ko‘p), distal (och, tor, past kubsimon) | Michigan p. 205–207 | OK |
| O‘tuvchi epiteliy suv va tuzlarni deyarli o‘tkazmaydi | Michigan p. 19, 208, 210 («essentially impermeable to salts and water») | OK |
| Rasmlar (11 ta) | oldingi auditda ko‘z bilan tekshirilgan; fayllar o‘zgarmagan | OK |
| O‘zbekcha gistologik atamalar | Zokirova N.B. «Gistologiya asoslari», Toshkent, 2025 (PDF, bet raqami bilan) | **tasdiqlandi / tuzatildi (adabiyot: Zokirova 2025)**: o‘tuvchi → o‘zgaruvchan epiteliy (28–30-b.), jiyak (12, 29, 118-b.), Kupfer (102-b.), siyrak tolali (39-b.), oraliq disk (78-b.), bazofil modda (14-b.) |
| O‘zbekcha serologik atamalar | Najmitdinov 1998, IV bob: «тўғри ёки бевосита / билвосита усул», «перекрест (чатиштириш)», «шахсий мослик», «билвосита Кумбс синамаси» | **tasdiqlandi (adabiyot: Najmitdinov 1998)** — sinonim va «Manba» qatori bilan qo‘shildi |

## 5. Siydik tahlili (`urinalysis_content.dart`, `urinalysis_logic.dart`)

| Da’vo | Manba | Hukm |
|---|---|---|
| Namuna turlari, o‘rta porsiya ≈ 20 ml, 24 soatlik yig‘ish, go‘dak qopchasi 1–3 soat | JSST 2003 §7.1.1, p. 233–234 (so‘zma-so‘z) | OK |
| pH ≈ 6,0 (5,0–7,0), 1 soat ichida; ishqoriy 7,8–8,0 — infeksiya, vegetarian; kristallar faqat juda kam kasalliklarda ahamiyatli | JSST §7.2.3, p. 235–236 | OK |
| pH 4,5–8, ko‘pincha 5,5–6,5; tosh turlari | AAFP 2022 «Urinary pH» | OK |
| Oqsil: iz 5–10, 1+ 30, 2+ 100, 3+ 300, 4+ 1000 mg/dL; ortostatik — 8 soat yotgandan keyin manfiy | AAFP 2022 Table 4; AAFP 2005 «Proteinuria» | OK |
| Glyukozuriya 180–200 mg/dL (≈ 10–11 mmol/L), SGLT-2, Fanconi | AAFP 2022 «Glucose» («9.99 to 11.10 mmol per L») | OK |
| Soxta musbat/manfiy jadvallari (glyukoza, keton, bilirubin, urobilinogen, qon, nitrit, LE, zichlik) | AAFP 2005 Table 2; AAFP 2022 Table 2; Delanghe 2014 (har band to‘liq matnda topildi: «moderately high ketone concentrations (40 mg/dL)», «povidone-iodine… menstrual blood… semen», «proteinuria (> 1 g/L) or ketoacids», «formaldehyde (0.4 g/L) or sodium azide», «etodolac», «p-aminosalicylic acid… porphobilinogen») | OK |
| Nitrit: > 10 000/mL; ochiq havoda 1 hafta — ⅓, 2 hafta — ¾ soxta musbat; qovuqda 4 soat | AAFP 2005 «Nitrites»; AAFP 2022 | OK |
| LR+: nitrit 13, loyqa 3; LE+nitrit manfiy LR− 0,2 | AAFP 2022 Table 3 | OK |
| Zichlik 1,003–1,030; < 1,010 / > 1,020; 1,010 da qotish | AAFP 2005 «Specific Gravity» | OK |
| Mikrogematuriya: kattalarda ≥ 3, bolalarda > 5 er/k.m.; leykotsit erkak < 2, ayol < 5; > 5 — simptomli bemorda IMY; yassi > 5 — ifloslanish; 5 bakteriya/k.m. ≈ 100 000 KOE/mL | AAFP 2022 «Red/White Blood Cells», «Epithelial Cells»; AAFP 2005 «Bacteriuria» | OK |
| Cho‘kma 12 ml, 400 g, 5 daq, tormozsiz, 12:1; vakuum naychalar silindrlarni ≥ 58 % / 51 % kamaytiradi; 1 soat / 4 soat (sovutilgan) | Delanghe 2014 «Manual methods», «Which sampling container…» | OK |
| Eritrotsit 8 / 5–6 / 9–10 µm; leykotsit 10–15 µm; kalsiy oksalat 10–20 / ≈ 50 µm; siydik kislotasi va uch fosfat 30–150; sistin 30–60; xolesterin 50–100; achitqi 5–12; S. haematobium tuxumi 120–150 µm | JSST 2003 §7.2.7–7.2.8, p. 241–252 (PDF da «µm» → «mm» bo‘lib chiqqan, raqamlar mos) | OK |
| Silindrlar ahamiyati (AAFP vs JSST farqi ko‘rsatilgan); eritrotsitar silindr kontakt sportda normal bo‘lishi mumkin | AAFP 2005 Table 6; JSST p. 243–244 | OK |
| Ranglar va hidlar | AAFP 2022 Table 1 va «Visual Appearance and Odor» | OK |

## 6. Qon morfologiyasi (`bloodmorph_logic.dart`, `bloodmorph_content.dart`)

| Da’vo | Manba | Hukm |
|---|---|---|
| Hb anemiya chegaralari (g/L): 6–23 oy 105; 24–59 oy 110; 5–11 yosh 115; 12–14 yosh (qiz/o‘g‘il) 120; ayol 120; erkak 130; homiladorlik I/II/III 110/105/110 | JSST 2024 Hb cutoffs Table 2 | OK |
| Ferritin: < 5 yosh < 12 / < 30 (yallig‘lanish); ≥ 5 yosh < 15 / < 70; homiladorlik I tr. < 15 | JSST 2020 Table 1 | OK |
| MCV < 80 / 80–100 / > 100; MCHC < 30 g/dL — gipoxromiya; sferotsitda MCHC ↑; yuqori RDW aralash populyatsiya | MSD «Evaluation of Anemia» («MCHC is < 30%»); Takami 2026 Table 3 (6 qator so‘zma-so‘z solishtirildi) | OK |
| Normal eritrotsit 6–8 µm; mikrotsit ≈ 5; makrotsit 9–10; sferotsit 6; elliptotsit 8 µm; anizo/poykilotsitoz; Xauell–Jolli («one or more large purple granules»); bazofil punktatsiya; nishonsimon; o‘roqsimon | JSST 2003 §9.10.4, p. 305–310 (so‘zma-so‘z) | OK |
| Retikulotsit: 2 + 2 tomchi, 15 daqiqa; % = n × 0,2 (500 da); mutlaq = RBC × 2n ×10⁹/L, misol 54; referens 0,2–2,0 % (8–110 ×10⁹/L), chaqaloq 2,0–6,0 % | JSST §9.12, p. 316–318, Table 9.11 (2–20 ×10⁻³; 20–60 ×10⁻³) | OK |
| Leyshman pH 6,8–7,2 (afzali 7,0–7,2), MGG 6,8–7,0 | JSST p. 303–305 | OK |
| Trombotsit soni taxmini | JSST §9.14 + Adewoyin | **tuzatildi** (#1) |
| Gigant trombotsit; analizator 1,5–3 µm bo‘yicha ajratadi; PTCP ≈ 0,1 %, 4–20 °C, ≥ 5 trombotsit to‘plami; satellitizm GPIIb-IIIa–FcγRIII | Cattaneo 2025 (to‘liq matn) | OK |
| > 80 / < 20 ×10⁹/L retikulotsit yo‘l-yo‘riqlari | Takami 2026 Step 2 | OK |
| Kurs darsligi raqamlari (6–9 µm, 7,2 µm; < 6 / 9–12 / > 12 µm; 5–10 ‰; I–V sinflar; RDW 11,5–14,5 %) | Najmitdinov 1998 to‘liq Word matni; Saidov 2017 (32-bo‘lim, 36-b.) — so‘zma-so‘z topildi | **tasdiqlandi (adabiyot: Najmitdinov 1998; Saidov 2017)**; bitta nomuvofiqlik: «avval anizo-, keyin poykilotsitoz» — kitobda «birga»; bloodmorph bu ish doirasidan tashqari, BLOODMORPH_SOURCES.md da taklif |

## Tekshirib bo‘lmagan (yoki manba o‘zi shubhali) — ro‘yxat

1. ~~Qin surtmasi tozalik darajalari~~ — 2026-10-18 adabiyot bilan hal qilindi (pastga qarang);
   darajalarning har biri bo‘yicha Heurlein asl matni — ochiq.
2. LFB va Nissl moddasi (gistologiya) — yumshatildi; bu ishda qayta ko‘rilmadi (ochiq).
3. ~~Ruscha Bethesda «favor neoplastic»; RF me’yorida yo‘q ruscha atamalar; o‘zbekcha gistologik va
   serologik atamalar~~ — hal qilindi (pastga qarang). Tsoliklon, rulo — o‘zbek darsligida topilmadi.
4. O‘zbekiston: qonun va PQ-19 topildi; moslik sinamalari bo‘yicha SSV buyrug‘i — ochiq.
5. ~~Najmitdinov 1998, Saidov 2017 raqamlari~~ — qayta ochildi, tasdiqlandi (1 nomuvofiqlik).
6. JSST 2003 qo‘llanmasidagi boshqa jumlalar ham ehtiyot bilan: §9.14 dagi trombotsit nisbati xato
   ekani aniqlandi (#1) — shu kitobdan olingan boshqa raqamlar (o‘lchamlar, pH, retikulotsit) alohida
   solishtirildi va mos.

## Testlar

- `flutter analyze` — muammo yo‘q.
- Bo‘lim testlari (6 fayl) — hammasi o‘tdi; 4 ta yangi regressiya testi qo‘shildi.
- To‘liq to‘plam (`flutter test --concurrency=3`) — 1587 o‘tdi, 1 o‘tkazib yuborilgan (skip), xato yo‘q.

## Adabiyot bo‘yicha tasdiqlash — «mutaxassis» bandlari (2026-10-18, ikkinchi bosqich)

Egasining ko‘rsatmasi: «ilmiy adabiyotdan o‘zing tekshir va tasdiqla». Har band uchun manba shu
sessiyada ochildi (PubMed, WebFetch/curl, Google Drive «KDL» kitoblari, lex.uz). Ilovada har hal
qilingan da’vo yonida «Manba: muallif, yil, «nom», bo‘lim, bet» qatori ko‘rinadi
(`CytoDegree` jadvali ostida `cytoDegreeCites`, `BethesdaItem.cites`, `BgItem.cites`, gistologiyada
fakt matni + [n] belgisi).

| # | Band | Hukm | Manba (aniq joy) | O‘zgarish |
|---|---|---|---|---|
| 1 | Tozalik darajalari I–IV | tasdiqlandi (adabiyot: ROAG 2019; Kurbonova 2023, 70-b.; Ison–Hay 2002) | РОАГ 2019, «Бактериальный вагиноз — Классификация»; Kurbonova 2023 §6.5, 70-b.; Sex Transm Infect 2002;78:413 (PMID 12473800, doi:10.1136/sti.78.6.413) | Manba qatorlari qo‘shildi; Heurlein — «tarixiy», o‘zbek darsligida Hay–Ison — ziddiyat ikkala qator bilan |
| 1a | Daraja bo‘yicha pH | ochiq → raqamlar olib tashlandi | Qidirildi: ROAG 2019, Kurbonova 2023, Ison–Hay 2002 (yo‘q); Menshikov 1987 djvu (yuklab bo‘lmadi); Novikova 2018 §21.1.1 (faqat mundarija); Kishkun — onlayn matn yo‘q; CyberLeninka API «Heurlein», «степени чистоты влагалищного содержимого» | `CytoDegree.ph` olib tashlandi; ARB izohlari yangilandi |
| 2 | Ruscha AGC-FN | tasdiqlandi (adabiyot: KR 597 2024; Grigoruk 2024, 103-b.) | base.garant.ru/410436907 (KR ID 597, Список сокращений); Grigoruk 2024 PDF 103-b. | ru: «похожие на неопластичные» + ikkinchi variant qatori |
| 3 | Ruscha transfuziya atamalari | tuzatildi (adabiyot: № 1134н п. 14 «г», 17, 19, 20; Аксельрод 2018) | 1134н matni; CyberLeninka (Аксельрод 2018, «Проба на индивидуальную совместимость») | «Большая/малая» olib tashlandi; IAT nomi; immediate spin/electronic issue — «в 1134н нет» |
| 4 | O‘zbekcha atamalar | tuzatildi/tasdiqlandi (adabiyot: Zokirova 2025; Najmitdinov 1998) | Zokirova 2025 (14, 28–30, 39, 78, 102, 118-b.); Najmitdinov 1998 IV bob | 6 gistologik atama; serologik sinonimlar |
| 5 | O‘zbekiston transfuziya me’yorlari | qisman (adabiyot: Qonun 402-II 10-modda; PQ-19 2026) — moslik bo‘yicha buyruq ochiq | lex.uz/docs/-46727; lex.uz/docs/-8011648; lex.uz qidiruvi (7 so‘z) | Yangi `uz-rules` kartasi |
| 6 | Najmitdinov/Saidov raqamlari | tasdiqlandi (adabiyot: Najmitdinov 1998; Saidov 2017) | to‘liq Word matnlari, so‘zma-so‘z | 1 nomuvofiqlik (bloodmorph, doiradan tashqari) — BLOODMORPH_SOURCES.md |

Regressiya testlari: `test/widget/{cytology,bloodgroup,histology}_test.dart` — «adabiyot tekshiruvi
2026-10-18».
