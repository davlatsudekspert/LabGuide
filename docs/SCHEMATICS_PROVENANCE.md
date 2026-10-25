# Apparat sinfi sxematik chizmalari — kelib chiqishi (2026-10-25, yangilangan 2026-10-25)

32 ta chizma: 7 ta model kartasi turi (`InstrumentSchematic`: `chemistry`,
`photometer`, `hematology5`, `hematology3`, `immunoassay`, `urine_strip`,
`urine_system`) va 25 ta yo‘nalish kartasi sinfi (`LabSchematic`, L1–L25).
Fayllar: `assets/instruments/schematic/<kalit>_480.png` (karta) va
`<kalit>_1200.png` (to‘liq ekran), shaffof fon. Ilovada: yo‘nalish (lab)
kartasi ekrani (`lib/features/instruments/lab_direction_screens.dart`,
`SchematicFigure` — model kartasidagi bilan bir xil vidjet, izoh
“Sxematik tasvir — aniq model emas” va kattalashtirish). Qaysi karta qaysi
chizmani oladi — `docs/LAB_CARD_IMAGE_COVERAGE.md`.

## Kelib chiqishi va huquq holati

- **LabGuide’ning o‘z original ishi.** Har bir chizma `tool/illustrations/schematic/gen.py`
  (7 model turi va L1–L25 funksiyalari) tomonidan oddiy geometrik shakllardan SVG sifatida
  dasturiy yaratilgan va `tool/illustrations/render.cjs --schematic --quant`
  (Playwright Chromium + pngquant) bilan PNG ga aylantirilgan.
- **Uchinchi tomon materiali yo‘q:** fotosurat, skan, kuzatib chizish (trace),
  boshqa rasm yoki AI-generatsiya ishlatilmagan; tarmoqdan rasm yuklab
  olinmagan.
- **Ishlab chiqaruvchi dizayni yo‘q:** brend, logotip, yozuv, model shakli
  yoki o‘ziga xos korpus dizayni takrorlanmagan. Rasmdagi yagona matn —
  asosiy qismlarni ko‘rsatuvchi raqamli belgilar (1..n, SVG `<g id="callouts">`;
  qorovul test faqat shu guruhdagi raqamlarga ruxsat beradi); qism nomi,
  vazifasi, ishlash prinsipi va natija ilovada (ARB `schemParts*`, manbalari —
  `docs/SCHEMATIC_PARTS_SOURCES.md`). Faqat
  apparat **sinfining** tamoyil darajasidagi umumiy qismlari (masalan,
  GC-MS: termostatdagi kolonka → ion manbai → kvadrupol → detektor, vakuum
  nasoslari, ma’lumot tizimi).
- **Ruxsat kerak emas** (o‘z ishimiz). Ishlab chiqaruvchi fotosuratlari uchun
  ruxsat olinmagan va ular ishlatilmaydi (`docs/INSTRUMENT_IMAGES.md`).
- Palitra va uslub — mavjud model chizmalari (`chemistry`, `hematology5`,
  `immunoassay` ...) bilan bir xil.
- 2026-10-25 yangilanishi: raqamli qism belgilari qo‘shildi; anatomiya
  aniqlashtirildi (biokimyo: reaksiya halqasidagi fotometr nuri va detektori;
  gematologiya 5/3: impedans kamerasi va lazerli oqim kyuvetasi kesigi; siydik
  test-chizig‘i: LED va fotosensorli o‘qish kallagi; siydik tizimi: cho‘kma
  modulida raqamli mikroskopik tasvirlar; MGIT: nazorat va dorili probirka
  o‘sish egri chiziqlari). Barcha 32 PNG `--quant` bilan qayta yaratildi.
- 2026-10-25, ilmiy ko‘rik jadvali (docs/SCIENTIFIC_REVIEW_TABLE.md,
  “Topilgan nomuvofiqliklar”) bo‘yicha tuzatishlar: ELISA o‘quvchisida optik
  yo‘l darslik tartibida (lampa → filtr → quduqcha → detektor; belgilar
  2–5 shu tartibda); HbA1c usul jihatdan neytral — kolonka/detektor kesigi va
  xromatogramma olib tashlandi (kartada bir nechta usul bor); namuna
  probirkalari: gematologiya — bir xil binafsha (EDTA turi) qopqoqli butun
  qon, biokimyo/immunoanaliz — neytral qopqoqli och somon rang (zardob/plazma);
  3 qismli gematologiya displeyida uch xil sxematik gistogramma (WBC uch
  subpopulyatsiya, RBC, o‘ngga cho‘zilgan PLT). Qayta yaratilgan PNG lar:
  `elisa_reader`, `hba1c_analyzer`, `hematology5`, `hematology3`,
  `chemistry`, `immunoassay` (sha256 quyida).
- 2026-10-25, real vaqt PCR (ilmiy ko‘rik F2): optik modul kesigi fluoressent signal yo‘li sifatida qayta chizildi
  — manba → qo‘zg‘atish filtri → termoblok kesigidagi reaksiya probirkasi → nurlanish filtri → detektor (nur
  probirkadan o‘tadi; avval filtr g‘ildiragidan to‘g‘ri detektorga borardi); belgilar 7 → 9. Manba turi, filtr
  tuzilishi va o‘qish yo‘nalishi ataylab ko‘rsatilmaydi. Qayta yaratilgan PNG: `real_time_pcr`.
- Har bir PNG ko‘zdan kechirildi (1200 px, 480 px, ~160 px eskiz, kunduzgi va
  tungi fon); anatomiya xatolari tuzatildi (masalan, MALDI-TOF da yengil ionlar
  detektorga yaqinroq, elektroforezda anod — qizil sim, albumin anod tomonda).

## Fayllar (sha256)

Yaratilgan/yangilangan: 2026-10-25 (raqamli qism belgilari qo‘shildi). Vosita:
`tool/illustrations/schematic/gen.py` → `render.cjs --schematic --quant`.
LabGuide’ning o‘z original ishi; ishlab chiqaruvchi dizayni yo‘q.

| Fayl | Chizma | O‘lcham | Hajm | sha256 |
|---|---|---|---|---|
| `chemistry_480.png` | M `chemistry` | 480×320 | 16 KB | `dd09cbcccfa11058fe965fc76ccbb586d9b28d351764a4e59c585cafd8b89f35` |
| `chemistry_1200.png` | M `chemistry` | 1200×800 | 49 KB | `f98f7929159b74b8029e81fe45c4878a3a77b66d1984ea902ac2be91e926cf97` |
| `photometer_480.png` | M `photometer` | 480×320 | 15 KB | `555aafdc5b409d3764f669f8d83d4405635d178264f2255e38fe2350240c040e` |
| `photometer_1200.png` | M `photometer` | 1200×800 | 41 KB | `ca2f4ea7b1611ad63fd56969ebdb9745ba4f0258197433bb7055364d1b127aa6` |
| `hematology5_480.png` | M `hematology5` | 480×320 | 17 KB | `f2be51b9c7c9103906ecb10b71eee5a44738a1cb99836c850dce653f1beac844` |
| `hematology5_1200.png` | M `hematology5` | 1200×800 | 51 KB | `b5a1d17ab146456e25c27ddcb2eaa0cdc1a6344a1b0c528bbec1c128e42e4997` |
| `hematology3_480.png` | M `hematology3` | 480×320 | 14 KB | `b1d7445769cb770dded1615c908abc6a15ed2c5165851d5e43bf561b30364a6f` |
| `hematology3_1200.png` | M `hematology3` | 1200×800 | 44 KB | `6d416171c03998be1a1d51e26ae9a1e097cf94e7779c991071f3e95d8ddd79fa` |
| `immunoassay_480.png` | M `immunoassay` | 480×320 | 17 KB | `287188337d504cc0086daf2df7e0434e432f0e346ec8262bcefa8ec63864475d` |
| `immunoassay_1200.png` | M `immunoassay` | 1200×800 | 48 KB | `7fc7668ef41ef31a37a3f43dc38d1139e7f4eadd1cdbdaae8c58ed631646f2d0` |
| `urine_strip_480.png` | M `urine_strip` | 480×320 | 12 KB | `0042a87ae7ce4797b6332af1fc5d3fbd6eca6b3afcea4154fe769de2b066e0bb` |
| `urine_strip_1200.png` | M `urine_strip` | 1200×800 | 36 KB | `544ca4345e47061da63944514c7591fe92142f8e1e5479a4235188c5b8dcadbb` |
| `urine_system_480.png` | M `urine_system` | 480×320 | 16 KB | `4151cdbf2559fcdd886f3b25dd9347fec5ea33defb031125e66d830d04cdd601` |
| `urine_system_1200.png` | M `urine_system` | 1200×800 | 41 KB | `845ab767586b132bcf66ac04bef396ee567b4e8aa7681aebfba5d6cc92d7bf5f` |
| `mass_spec_gc_480.png` | L1 `mass_spec_gc` | 480×320 | 18 KB | `461c2aec24053f3c3cc24b954696124c2e802006d6af737e231c29ef63d39102` |
| `mass_spec_gc_1200.png` | L1 `mass_spec_gc` | 1200×800 | 50 KB | `d03a2586aac8dad6527e1522400e39f01370a6e2ba799750dd4bac996882880f` |
| `mass_spec_lc_480.png` | L2 `mass_spec_lc` | 480×320 | 17 KB | `681d78cdbbd87ee1c491ad2a443ba1bd94f602f336a8651ff09df9fd7035d04c` |
| `mass_spec_lc_1200.png` | L2 `mass_spec_lc` | 1200×800 | 49 KB | `3f26edad37e105f6b1c7bf8b9068adde88e43d7cae3fadbbc0269b2ead9ea822` |
| `maldi_tof_480.png` | L3 `maldi_tof` | 480×320 | 13 KB | `fe67080fc82140b279e1962abb0f7aa76b8164df07a7cdb8057304f6883c2557` |
| `maldi_tof_1200.png` | L3 `maldi_tof` | 1200×800 | 36 KB | `a743d2cb52a668b14de6a043a641b405883ff8a568a3282f7c67e448603b0156` |
| `microbial_id_ast_480.png` | L4 `microbial_id_ast` | 480×320 | 14 KB | `e087f792dcca4af34ff8022be556da96ecf8a7947d69b9af7e7e66f7f9be37b7` |
| `microbial_id_ast_1200.png` | L4 `microbial_id_ast` | 1200×800 | 33 KB | `7312156c2c93fd627b5668dbc9a9dbec474dffc3d9306409cff669d55bc911a0` |
| `blood_culture_480.png` | L5 `blood_culture` | 480×320 | 15 KB | `dee63c44dccb9f06a62b80d127b928d7d14ca194dc096ed09fe3e065e4d26142` |
| `blood_culture_1200.png` | L5 `blood_culture` | 1200×800 | 35 KB | `623987f929a009bfbb72a5d3557a564e5e3195a4899fb412980dd9698749541a` |
| `mycobacterial_culture_480.png` | L6 `mycobacterial_culture` | 480×320 | 13 KB | `5568c76b82226a1b6f4f3573b798273c44a2394625ddbd0a46041b45686ae612` |
| `mycobacterial_culture_1200.png` | L6 `mycobacterial_culture` | 1200×800 | 35 KB | `689730df64ee6c384b4768f917bc0eb51f48587812dee08eaca78144410e71fd` |
| `flow_cytometer_480.png` | L7 `flow_cytometer` | 480×320 | 13 KB | `6ae2709779f4bf4f7cae472555d4341f241d68c646d7a0ed48311e2d7ac1b477` |
| `flow_cytometer_1200.png` | L7 `flow_cytometer` | 1200×800 | 38 KB | `bc440fc6f2eca7977bf73f0ab7cc901dbe2736ed524a2d407e3542fb94598dbb` |
| `real_time_pcr_480.png` | L8 `real_time_pcr` | 480×320 | 15 KB | `209ff89065884846286d616d9b15022d59923e743b811e262bc218002e5bd0fa` |
| `real_time_pcr_1200.png` | L8 `real_time_pcr` | 1200×800 | 40 KB | `f576a49e821834b3f3dd1d78d9be27954a7c784057b24be947eaa48b31a98570` |
| `cartridge_molecular_480.png` | L9 `cartridge_molecular` | 480×320 | 11 KB | `befcda350705b5432095a417a49cd4d0a46a826dd40befdc94483d94e780f943` |
| `cartridge_molecular_1200.png` | L9 `cartridge_molecular` | 1200×800 | 31 KB | `76567414d0357c4b7656238c150cc9ccebbd2f9da1e07706cec19b58db27174e` |
| `coag_analyzer_480.png` | L10 `coag_analyzer` | 480×320 | 14 KB | `5d125d95a6a64195da5ed85bf73a2b5cc93579eb6caca1496fbc38324bc40c3e` |
| `coag_analyzer_1200.png` | L10 `coag_analyzer` | 1200×800 | 40 KB | `3d03603bfd9d69087115c693590b557f0207b68b1b26c290185d73f7b271907f` |
| `elisa_reader_480.png` | L11 `elisa_reader` | 480×320 | 14 KB | `d0d52a7730afca36597b49741d7286a9e2f50741a931c177f391baeefc4bfa60` |
| `elisa_reader_1200.png` | L11 `elisa_reader` | 1200×800 | 41 KB | `0dd20df3e221074bd3c57dae484a2458944caaeec08b2b5fcfefef7a3822f5bb` |
| `bsc_class2_480.png` | L12 `bsc_class2` | 480×320 | 12 KB | `5b67611ad5d4ced8e4f0fb4e868452385b5f37d055977ff6aadaa1f67ea7b695` |
| `bsc_class2_1200.png` | L12 `bsc_class2` | 1200×800 | 32 KB | `3d0731ffd008679d0d07985f616fe1cfb97f10319a14094aacaf69f5b9620110` |
| `autoclave_480.png` | L13 `autoclave` | 480×320 | 17 KB | `1f8c5567b862f89d87dc7211c8c6e355ff7ad1f30759ced9f3a8735811ca3165` |
| `autoclave_1200.png` | L13 `autoclave` | 1200×800 | 50 KB | `004305bc40d9a61c3874728f7ce33e351c3846a0aa5b4f4d5b066fdfa143598d` |
| `blood_gas_ise_480.png` | L14 `blood_gas_ise` | 480×320 | 13 KB | `57ee5ee67067ac6dcd7351676265ff77daccb4b8081292588221826123d468d1` |
| `blood_gas_ise_1200.png` | L14 `blood_gas_ise` | 1200×800 | 38 KB | `128511d2561ea97efb71140a1458670aaca0edf2e66c669733f7f87ac6fc161e` |
| `hba1c_analyzer_480.png` | L15 `hba1c_analyzer` | 480×320 | 13 KB | `4e0c862416f93a48a2c7a3945575320bc2aa7bfbd040dfeaba296bd5abbd950e` |
| `hba1c_analyzer_1200.png` | L15 `hba1c_analyzer` | 1200×800 | 39 KB | `89f7bb1412f0a3d27a3cbffe2a632cff3f21997e3580796909e600a7737755bd` |
| `lab_fridge_480.png` | L16 `lab_fridge` | 480×320 | 11 KB | `6aff4ca4f3efe925be40a56febd64a27d33227a041ff6d5ee9cb3bda45ac62c6` |
| `lab_fridge_1200.png` | L16 `lab_fridge` | 1200×800 | 35 KB | `58e88b9298336309f15d6d94b81aa2cfd385c462f81c8db41211fda3836e2413` |
| `fluorescence_microscope_480.png` | L17 `fluorescence_microscope` | 480×320 | 13 KB | `a6f60b48979dd1a33b55b7378912d29c197aba84cab73c1da7ce25b2790320b7` |
| `fluorescence_microscope_1200.png` | L17 `fluorescence_microscope` | 1200×800 | 38 KB | `b350a3b67431ecd4f6d463dd32fa74e0a0076a85f624dab77113d0939af6fec8` |
| `casa_480.png` | L18 `casa` | 480×320 | 12 KB | `bc9273474e61113fe19f82570bcbd182fa7f453b6e3bbf4f1a29ef827f722d26` |
| `casa_1200.png` | L18 `casa` | 1200×800 | 35 KB | `eb43989dcc1718770aefd901786707224b731e76153bb476bc6f77b3ccf14c1f` |
| `gel_card_system_480.png` | L19 `gel_card_system` | 480×320 | 11 KB | `24b358a8811c7e1b4047a2fe38cea298808c47bd981c19fb39b65abf45159ffe` |
| `gel_card_system_1200.png` | L19 `gel_card_system` | 1200×800 | 27 KB | `fcfcb1b4431c980ba6f93cee50280db436e8ae902e66c607545a85aa70367441` |
| `esr_analyzer_480.png` | L20 `esr_analyzer` | 480×320 | 10 KB | `02ccc2ae8b4f17e4d3301386f8b5a577c976e5f7b7de54ece544be04605f46f6` |
| `esr_analyzer_1200.png` | L20 `esr_analyzer` | 1200×800 | 28 KB | `af7193cf187a01fa3bd379c07dbe773c3cec3a5f609ca1b69b5aae82a9682e3b` |
| `aggregometer_480.png` | L21 `aggregometer` | 480×320 | 15 KB | `da763917032d7a0e1b36152177a67d8bb7795589a51843c5fd1d44df4e2d5019` |
| `aggregometer_1200.png` | L21 `aggregometer` | 1200×800 | 38 KB | `d8b39ccdb9cf56e13f83fbbf693a4887eea20bb190a9c5c4042a30709b0c6728` |
| `electrophoresis_480.png` | L22 `electrophoresis` | 480×320 | 11 KB | `d9b1f9591ebd479d90b0e6a456f3a9a2671a2d4f1be0c14a9621f819628553d3` |
| `electrophoresis_1200.png` | L22 `electrophoresis` | 1200×800 | 34 KB | `55665124c29dbfa1fc03216d3323babc5b079857c981545f6bf32bf5de706274` |
| `osmometer_480.png` | L23 `osmometer` | 480×320 | 11 KB | `b9284a5160290fb0e330c91b027ec46a55b09ed1309c3f68b7192b556f8e629c` |
| `osmometer_1200.png` | L23 `osmometer` | 1200×800 | 32 KB | `896f908c12e2202eefe2a04da609952beb3872d9c960c895fd3f204d1c5cccca` |
| `tlc_480.png` | L24 `tlc` | 480×320 | 13 KB | `a8bfb355964c00881c0d0a9fbdfd91882ec5e3e965906b5034df34fe0efa93e3` |
| `tlc_1200.png` | L24 `tlc` | 1200×800 | 40 KB | `18653d049e0e24b5861c6cbf4efe876c5790380364bb1ae37bdac3eb9d9d39ef` |
| `analytical_balance_480.png` | L25 `analytical_balance` | 480×320 | 12 KB | `2630ef45c41a31d2dae38316f59dc0e277ce4bbfc36186445d9063dc97c7c093` |
| `analytical_balance_1200.png` | L25 `analytical_balance` | 1200×800 | 36 KB | `45bb0fb455ae738f46dce1ac055a43f11c734c2ccb43ac7b85c8f479518af3ee` |
