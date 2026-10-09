# Mikroskopiya atlasi — mustaqil tekshiruv (2026-10-09)

Atlas: `assets/microscopy/atlas.json` (manba: `tool/microscopy_atlas_src.py`),
24 rasm. Tekshiruvchi atlasni yig'gan ishdan mustaqil ravishda har rasmni
manba sahifasidan qayta ko'rib chiqdi.

## Usul

1. **Manba va fayl.** Wikimedia Commons: `action=query&prop=imageinfo`
   (`url|size|sha1|extmetadata|user`) va sahifa wikitext'i (litsenziya
   shabloni). Asl fayl `upload.wikimedia.org` dan umumiy IP'ga 429 qaytargani
   uchun ilovadagi nusxa Commons 500 px thumbnail bilan solishtirildi
   (256×256 ga keltirib, piksel farqining o'rtachasi, 0–255 shkala) va tomonlar
   nisbati tekshirildi. API'dagi o'lcham/sha1 `original_size` va `file_url` bilan
   solishtirildi. CDC PHIL: `Details.aspx?pid=…` sahifasi (Caption, Content
   Provider, Creation Date, Copyright Restrictions) va `.tif` / `_lores.jpg`
   fayllari (HTTP 206); ilovadagi nusxa `_lores.jpg` bilan solishtirildi.
2. **Litsenziya.** Sahifadagi shablon (`{{self|cc-by-sa-4.0}}` va h.k.),
   `LicenseShortName`/`LicenseUrl`; jurnal rasmlari uchun maqolaning PMC
   litsenziyasi (PubMed/PMC copyright API). NC/ND — hech birida yo'q.
3. **Nom.** Har rasm to'liq o'lchamda ko'rildi (shubhalilari kesib,
   kattalashtirib), manba izohi bilan solishtirildi.
4. **Draft.** “Nimaga e'tibor berish” matni ilovada faqat rasm kartasida,
   har doim «Draft · mutaxassis tekshiruvi kutilmoqda» belgisi bilan
   chiqadi (`_DraftNote`, `micDraftTag`); atlas bosh sahifasidagi ogohlantirish
   (`micEduNotice`) ham buni aytadi. Mashq ekranida note ko'rsatilmaydi.

## Umumiy topilmalar va tuzatishlar

- **Muallif sahifasiga havola yo'q edi.** Atlasda muallif nomi bor edi, lekin
  havola yo'q. Qo'shildi: `author_url` (Commons foydalanuvchi sahifasi;
  sahifasi yaratilmagan Vladimir064 va Paulo Mourao uchun —
  `Special:ListFiles/<user>`; jurnal rasmlari uchun maqola DOI). Ilovada
  «Muallif sahifasi» qatori; validator Commons rasmida havolani talab qiladi.
  CDC PHIL fotograflari uchun alohida sahifa yo'q — CDC, fotograf nomi va
  PHIL sahifasi (CDC shartlari bo'yicha) yetarli.
- **O'zgartirish qaydi** («faqat kichraytirilgan, kesilmagan, yozuv
  qo'shilmagan», asl va ilova o'lchami) har rasm kartasida bor (`micResized`) —
  CC BY/BY-SA “indicate if changes were made” talabiga javob beradi. CC BY-SA
  rasmlarida ShareAlike eslatmasi ham bor.
- **Ko'p litsenziyali fayllar** (`GFDL|cc-by-sa-all`, `cc-by-sa-3.0|GFDL`):
  atlas CC BY-SA 4.0 / 3.0 ni tanlagan — bu ruxsat etilgan tanlov.
- **Nomi faqat manba izohiga tayanadigan 3 rasm** “Nomi manba izohi
  bo'yicha” deb aniqlashtirildi (`label_note`, uch tilda sababi bilan) va
  “Bu nima?” mashqidan chiqarildi. Validator (Python va Dart): `label_note`
  bo'lgan rasm mashqda bo'lolmaydi. Bo'lim muqovalari va mashq mozaikasi
  namunaviy rasmlarga (u-cryst-uric-1, b-baso-1) almashtirildi.
- Olib tashlangan rasm yo'q.

## Jadval

Piksel farqi — ilova nusxasi va manba thumbnail'i orasidagi o'rtacha farq
(0–255); hammasi ≤ 3,1 (JPEG qayta siqish darajasi), tomonlar nisbati ±0,004
ichida — rasmlar manbadagi bilan bir xil, kesilmagan.

| # | Rasm | Manba | Litsenziya (sahifada → atlasda) | Muallif / havola | Nom (atlas) | Holat | Izoh |
|---|---|---|---|---|---|---|---|
| 1 | u-rbc-1 | [Commons: MicroHematuria.JPG](https://commons.wikimedia.org/wiki/File:MicroHematuria.JPG) — 1743×1501, sha1 e080d461…; farq 1,15 | GFDL + CC BY-SA (barcha versiyalar) → CC BY-SA 4.0 ✔ | Bobjgalindo — [User:Bobjgalindo](https://commons.wikimedia.org/wiki/User:Bobjgalindo) (qo'shildi) | Siydikdagi eritrotsitlar | tasdiqlandi | Bir xil, yadrosiz disklar — izohga mos |
| 2 | u-rbc-2 | [Commons: Haematuria.jpg](https://commons.wikimedia.org/wiki/File:Haematuria.jpg) — 1532×1336; farq 3,06 | CC BY-SA 3.0 → CC BY-SA 3.0 ✔ | J3D3 — [User:J3D3](https://commons.wikimedia.org/wiki/User:J3D3) (qo'shildi) | Siydikdagi eritrotsitlar | tasdiqlandi | Zich eritrotsitlar, bir qismi burishgan/deformatsiyalangan — gematuriya izohiga mos |
| 3 | u-wbc-1 | [Commons: Plenty of pus cells…](https://commons.wikimedia.org/wiki/File:Plenty_of_pus_cells_in_Urine_Microscopy.jpg) — 4000×2250; farq 1,97 | CC BY-SA 4.0 ✔ | Ajay Kumar Chaurasiya — [User page](https://commons.wikimedia.org/wiki/User:Ajay_Kumar_Chaurasiya) (qo'shildi) | Siydikdagi leykotsitlar | tasdiqlandi | Maydon asosan leykotsitlar; 2 ta yassi epiteliy ham bor (manbada nomlanmagan) — mashq savoli «asosan nima» bo'lgani uchun to'g'ri |
| 4 | u-wbc-2 | [Commons: Pus cells (dead leukocytes)…](https://commons.wikimedia.org/wiki/File:Pus_cells_(dead_leukocytes)_in_urine_microscopy.jpg) — 3264×2448; farq 1,38 | CC BY-SA 4.0 ✔ | Ajay Kumar Chaurasiya — havola qo'shildi | Siydikdagi leykotsitlar | tasdiqlandi | Donador leykotsitlar + bakteriyalar |
| 5 | u-epi-1 | [Commons: Pus cells, Epithelial cells, RBCs and Bacteria…](https://commons.wikimedia.org/wiki/File:Pus_cells,_Epithelial_cells,_RBCs_and_Bacteria_in_Urine_Microscopy.jpg) — 4000×2250; farq 3,07 | CC BY-SA 4.0 ✔ (yuklovchi Spicy, muallif Ajay K. C.) | Ajay Kumar Chaurasiya — havola qo'shildi | Epiteliy hujayralari (aralash maydon) | tasdiqlandi | Mashqda emas. Ikki yirik epiteliy ko'rinishidan yassi, lekin manba turini aytmaydi — note buni to'g'ri aytadi |
| 6 | u-epi-2 | [Commons: UrinaryInfection.jpg](https://commons.wikimedia.org/wiki/File:UrinaryInfection.jpg) — 1561×1371; farq 2,39 | CC BY-SA 3.0 ✔ | J3D3 — havola qo'shildi | Epiteliy hujayralari (aralash maydon) | tasdiqlandi | Mashqda emas; epiteliy, leykotsit, eritrotsit — izohga mos |
| 7 | u-rte-1 | [Commons: RTcells.JPG](https://commons.wikimedia.org/wiki/File:RTcells.JPG) — 1443×1230; farq 1,34 | GFDL + CC BY-SA (barcha) → CC BY-SA 4.0 ✔ | Bobjgalindo — havola qo'shildi | Buyrak kanalchalari epiteliysi | **aniqlashtirildi** | Hujayralar yirik, burmali, yadrosi aniq emas — RTE uchun namunaviy emas; «poorly collected sample» ifloslanish epiteliysiga ham ishora. `label_note` qo'shildi, mashqdan chiqarildi |
| 8 | u-cast-hyaline-1 | [Commons: Hyaline Cast…](https://commons.wikimedia.org/wiki/File:Hyaline_Cast_in_Urine_Microscopy.jpg) — 3264×2448; farq 0,94 | CC BY-SA 4.0 ✔ | Ajay Kumar Chaurasiya — havola qo'shildi | Gialin silindr | tasdiqlandi | Shaffof, parallel chetli silindr, ustida bir nechta hujayra |
| 9 | u-cast-granular-1 | [Commons: Granular Casts…](https://commons.wikimedia.org/wiki/File:Granular_Casts_in_Urine_Microscopy.jpg) — 4000×2250; farq 1,86 | CC BY 4.0 ✔ | Ajay Kumar Chaurasiya — havola qo'shildi | Donador silindr | tasdiqlandi | Ikki donador silindr |
| 10 | u-cast-panel-1 | [Commons: RTE cast, muddy granular cast, WBC cast and RBC cast…](https://commons.wikimedia.org/wiki/File:RTE_cast,_muddy_granular_cast,_WBC_cast_and_RBC_cast_in_urine.jpg) — 567×337 (kichraytirilmagan); farq 1,52 | CC BY 4.0 ✔; maqola PMC5603084 — CC BY 4.0 (PMC tasdiqladi) | Mohsenin V. — [doi:10.1186/s40560-017-0251-y](https://doi.org/10.1186/s40560-017-0251-y) (qo'shildi) | Silindrlar: a–d panellar | tasdiqlandi | Mashqda emas; panellar a–d izohdagi bilan mos |
| 11 | u-cryst-caox-1 | [Commons: Calcium Oxalate Monohydrate Crystals…](https://commons.wikimedia.org/wiki/File:Calcium_Oxalate_Monohydrate_Crystals_in_Urine_Microscopy.jpg) — 4000×3000; farq 1,50 | CC BY-SA 4.0 ✔ | Ajay Kumar Chaurasiya — havola qo'shildi | Kalsiy oksalat kristallari | **aniqlashtirildi** | Yirik, to'da bo'lib yotgan qatlamli ovallar — monogidratning kam uchraydigan ko'rinishi, «gantel/konvert» yo'q; polyarizatsiyasiz boshqa ovoidlardan ajratish qiyin. `label_note`, mashqdan chiqarildi |
| 12 | u-cryst-uric-1 | [Commons: UricAcid.jpg](https://commons.wikimedia.org/wiki/File:UricAcid.jpg) — 1597×1536; farq 1,71 | CC BY-SA 3.0 ✔ | J3D3 — havola qo'shildi | Siydik kislotasi kristallari | tasdiqlandi | Romb/limon shaklli plastinkalar va rozetkalar — namunaviy (bu yerda rangsiz) |
| 13 | u-cryst-triple-1 | [Commons: Кристаллы трипельфосфата…](https://commons.wikimedia.org/wiki/File:Кристаллы_трипельфосфата_в_форме_гробовых_крышек_и_призм_на_фоне_аморфных_фосфатов._Осадок_мочи._Нативный_препарат._x400.jpg) — 1810×1741; farq 2,65 | CC BY 4.0 ✔ (Wiki Science Competition 2017) | Vladimir064 — [Special:ListFiles/Vladimir064](https://commons.wikimedia.org/wiki/Special:ListFiles/Vladimir064) (foydalanuvchi sahifasi yo'q) | Tripelfosfat (struvit) | tasdiqlandi | «Tobut qopqog'i» prizmalari + amorf fosfatlar |
| 14 | u-cryst-cystine-1 | [Commons: Cystine in Urine.jpg](https://commons.wikimedia.org/wiki/File:Cystine_in_Urine.jpg) — 2592×1944; farq 0,92 | CC BY-SA 4.0 ✔ | J3D3 — havola qo'shildi | Sistin kristallari | tasdiqlandi | Bitta olti burchakli plastinka — sistin uchun namunaviy |
| 15 | b-neut-1 | [Commons: WBC (neutrophil) at centre…](https://commons.wikimedia.org/wiki/File:WBC_(neutrophil)_at_centre,_numerous_erythrocytes_and_platelets_(dot_like_bodies)_in_Wright's_stained_peripheral_blood_smear_(PBS)_microscopy.jpg) — 3264×2448; farq 1,12 | CC BY-SA 4.0 ✔ | Ajay Kumar Chaurasiya — havola qo'shildi | Neytrofil | tasdiqlandi | Markazda 4–5 segmentli neytrofil |
| 16 | b-neut-2 | [CDC PHIL #18910](https://wwwn.cdc.gov/phil/Details.aspx?pid=18910) — farq 1,07 | CDC PHIL (public domain, kredit talabi) ✔ — matn so'zma-so'z mos | CDC/ Dr. F. Gilbert, 1972 | Neytrofil | tasdiqlandi | Strelkada segment yadroli neytrofil |
| 17 | b-lymph-1 | [CDC PHIL #18909](https://wwwn.cdc.gov/phil/Details.aspx?pid=18909) — farq 1,17 | CDC PHIL ✔ | CDC/ Dr. F. Gilbert, 1972 | Limfotsit | tasdiqlandi | Kichik limfotsit, sitoplazmasi juda ingichka |
| 18 | b-mono-1 | [CDC PHIL #30136](https://wwwn.cdc.gov/phil/Details.aspx?pid=30136) — farq 1,11 | CDC PHIL ✔ | CDC/ Dr. Candler Ballard, 1974 | Monotsit | tasdiqlandi | Bukilgan yadro, keng sitoplazma; rasm qizg'ish tonli (manbada shunday) |
| 19 | b-eos-1 | [CDC PHIL #18907](https://wwwn.cdc.gov/phil/Details.aspx?pid=18907) — farq 1,24 | CDC PHIL ✔ | CDC/ Dr. F. Gilbert, 1972 | Eozinofil | **aniqlashtirildi** | Donachalar bu slaydda binafsha (to'q sariq-qizil emas) — bazofil bilan adashtirish oson. `label_note`, mashqdan chiqarildi |
| 20 | b-baso-1 | [CDC PHIL #18908](https://wwwn.cdc.gov/phil/Details.aspx?pid=18908) — farq 1,18 | CDC PHIL ✔ | CDC/ Dr. F. Gilbert, 1972 | Bazofil | tasdiqlandi | Yadroni yopuvchi to'q binafsha yirik donachalar |
| 21 | b-acanth-1 | [Commons: Acanthocytosis.jpg](https://commons.wikimedia.org/wiki/File:Acanthocytosis.jpg) — 902×671; farq 1,63 | CC BY 2.0 ✔; maqola PMC2467409 — CC BY 2.0 (PMC tasdiqladi) | Zamel, Khan, Pollex, Hegele — [doi:10.1186/1750-1172-3-19](https://doi.org/10.1186/1750-1172-3-19) (qo'shildi) | Akantotsitlar | tasdiqlandi | Abetalipoproteinemiya: ko'p tikansimon eritrotsitlar; markazda limfotsit ham bor (maydon savoli) |
| 22 | b-acanth-2 | [Commons: Acanthocyte smear 2009-10-08.JPG](https://commons.wikimedia.org/wiki/File:Acanthocyte_smear_2009-10-08.JPG) — 3072×2304; farq 1,92 | CC BY-SA 3.0 + GFDL → CC BY-SA 3.0 ✔ | Paulo Henrique Orlandi Mourao — [Special:ListFiles/Paulo_Mourao](https://commons.wikimedia.org/wiki/Special:ListFiles/Paulo_Mourao) (foydalanuvchi sahifasi yo'q) | Akantotsitlar | tasdiqlandi | Markazda kichik, zich, notekis uzunlikdagi o'simtali bitta hujayra; burchakda neytrofil — «markazdagi hujayra» savoli aniq |
| 23 | p-mal-thin-1 | [CDC PHIL #5861](https://wwwn.cdc.gov/phil/Details.aspx?pid=5861) — farq 1,20 | CDC PHIL ✔ | CDC/ Steven Glenn, 1979 | Bezgak (P. falciparum): yupqa surtma | tasdiqlandi | Halqasimon trofozoitlar, bir hujayrada bir nechta, qo'sh xromatin nuqta |
| 24 | p-mal-thick-1 | [CDC PHIL #22817](https://wwwn.cdc.gov/phil/Details.aspx?pid=22817) — farq 1,20 | CDC PHIL ✔ | CDC/ Dr. Mae Mellvin, 1971 | Bezgak (P. falciparum): qalin surtma | tasdiqlandi | O'roqsimon gametotsitlar va halqalar, gemolizlangan fon |

Barcha 17 Commons sahifasi va 7 CDC PHIL sahifasi ochildi; asl izoh,
muallif, sana, o'lcham va litsenziya atlasdagi bilan so'zma-so'z mos.
PHIL “Copyright Restrictions” matni har 7 yozuvda `CDC_TERMS` bilan bir xil.

## Holat bo'yicha

- Tasdiqlandi: 21
- Aniqlashtirildi (nomi manba izohi bo'yicha, mashqdan chiqarildi): 3 —
  u-rte-1, u-cryst-caox-1, b-eos-1
- Olib tashlandi: 0

Mashqda endi 18 rasm (siydik 9, qon 7, parazitlar 2). «Buyrak kanalchalari
epiteliysi», «Kalsiy oksalat» va «Eozinofil» turlari atlasda qoladi va
mashqda faqat chalg'ituvchi variant sifatida chiqadi.

## Keyingi ish (tavsiya)

- Eozinofil, kalsiy oksalat (digidrat/«konvert» yoki «gantel» monogidrat) va
  RTE uchun namunaviy, erkin litsenziyali rasm topilsa — mashqqa shu rasmlar
  qo'shilsin.
- “Nimaga e'tibor berish” matnlari hali draft: mutaxassis (klinik laborant /
  gematolog) tekshiruvidan o'tishi kerak.
