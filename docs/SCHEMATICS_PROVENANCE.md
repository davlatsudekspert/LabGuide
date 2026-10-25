# Apparat sinfi sxematik chizmalari — kelib chiqishi (2026-10-25)

Fayllar: `assets/instruments/schematic/<kalit>_480.png` (karta) va
`<kalit>_1200.png` (to‘liq ekran), shaffof fon. Ilovada: yo‘nalish (lab)
kartasi ekrani (`lib/features/instruments/lab_direction_screens.dart`,
`SchematicFigure` — model kartasidagi bilan bir xil vidjet, izoh
“Sxematik tasvir — aniq model emas” va kattalashtirish). Qaysi karta qaysi
chizmani oladi — `docs/LAB_CARD_IMAGE_COVERAGE.md`.

## Kelib chiqishi va huquq holati

- **LabGuide’ning o‘z original ishi.** Har bir chizma `tool/illustrations/schematic/gen.py`
  (funksiyalar L1–L25) tomonidan oddiy geometrik shakllardan SVG sifatida
  dasturiy yaratilgan va `tool/illustrations/render.cjs --schematic --quant`
  (Playwright Chromium + pngquant) bilan PNG ga aylantirilgan.
- **Uchinchi tomon materiali yo‘q:** fotosurat, skan, kuzatib chizish (trace),
  boshqa rasm yoki AI-generatsiya ishlatilmagan; tarmoqdan rasm yuklab
  olinmagan.
- **Ishlab chiqaruvchi dizayni yo‘q:** brend, logotip, yozuv, model shakli
  yoki o‘ziga xos korpus dizayni takrorlanmagan; rasmda matn yo‘q. Faqat
  apparat **sinfining** tamoyil darajasidagi umumiy qismlari (masalan,
  GC-MS: termostatdagi kolonka → ion manbai → kvadrupol → detektor, vakuum
  nasoslari, ma’lumot tizimi).
- **Ruxsat kerak emas** (o‘z ishimiz). Ishlab chiqaruvchi fotosuratlari uchun
  ruxsat olinmagan va ular ishlatilmaydi (`docs/INSTRUMENT_IMAGES.md`).
- Palitra va uslub — mavjud model chizmalari (`chemistry`, `hematology5`,
  `immunoassay` ...) bilan bir xil.
- Har bir PNG ko‘zdan kechirildi (1200 px, 480 px, ~160 px eskiz, kunduzgi va
  tungi fon); anatomiya xatolari tuzatildi (masalan, MALDI-TOF da yengil ionlar
  detektorga yaqinroq, elektroforezda anod — qizil sim, albumin anod tomonda).

## Fayllar (sha256)

| Fayl | Chizma | O‘lcham | Hajm | sha256 |
|---|---|---|---|---|
| `mass_spec_gc_480.png` | L1 `mass_spec_gc` | 480×320 | 15 KB | `85c7457547ea0108d9868f603d581c6819c89c2aa81ad2477dc2dfb17b6ddbe3` |
| `mass_spec_gc_1200.png` | L1 `mass_spec_gc` | 1200×800 | 42 KB | `b3bbb97d44a40641923fa0d940315c7d0121dad048df3f5cb5741195cac06b0b` |
| `mass_spec_lc_480.png` | L2 `mass_spec_lc` | 480×320 | 14 KB | `4a506a0c7e91fa402214f1cc43e85fecfffc86c6f95e6c483ff54b40c3eef95a` |
| `mass_spec_lc_1200.png` | L2 `mass_spec_lc` | 1200×800 | 42 KB | `87f55f5c14a44c35bd1b85effafddca79c2dbf6637a7450f27b7721cdce39d23` |
| `maldi_tof_480.png` | L3 `maldi_tof` | 480×320 | 11 KB | `35793dc1e447b8d642c53383faead579de6e6436a60855e042e06a7ef257bbef` |
| `maldi_tof_1200.png` | L3 `maldi_tof` | 1200×800 | 30 KB | `630143c840833bd93d3261c5cfcc10dcad3addc91adc927a4850621afefab095` |
| `microbial_id_ast_480.png` | L4 `microbial_id_ast` | 480×320 | 12 KB | `f2b053bacf0b495265f5b2397cb5d195574e9ae0c67ec5fe8e82d021c3b7ab34` |
| `microbial_id_ast_1200.png` | L4 `microbial_id_ast` | 1200×800 | 27 KB | `057b928f5b55bc50d5d50c3ed434aeed1bf9d7c1c8bdd2a4623afcc5e7915339` |
| `blood_culture_480.png` | L5 `blood_culture` | 480×320 | 13 KB | `ba35aa98eaa426f11e676a97b624306b6fab03ae49997e6336abd555aa20a785` |
| `blood_culture_1200.png` | L5 `blood_culture` | 1200×800 | 27 KB | `3e43db88f255c36b30754905dfe5dea67dd3710b5c4eb04717f1feabfd9e9fc7` |
| `mycobacterial_culture_480.png` | L6 `mycobacterial_culture` | 480×320 | 10 KB | `0b3ee61e349a59945ce341bca84c1a2148109b294a39c0b385410ad2112e8d38` |
| `mycobacterial_culture_1200.png` | L6 `mycobacterial_culture` | 1200×800 | 29 KB | `baf85ad2c6fe8952f7c924a1cf9ef774f329f1404c01506c3d7fbdbf83de5d88` |
| `flow_cytometer_480.png` | L7 `flow_cytometer` | 480×320 | 10 KB | `18674370ae6d5f9549614ad33c167b04ce7d867f07a1076cddb49c722a409aa9` |
| `flow_cytometer_1200.png` | L7 `flow_cytometer` | 1200×800 | 31 KB | `1c2668c68ee1ccf0f7b0645f3219580738e57cfbbf817aacff5b2a660fdf48bc` |
| `real_time_pcr_480.png` | L8 `real_time_pcr` | 480×320 | 12 KB | `049f832308304a8653a41530e97af61e311bdf10e5031efbe281e7e396b438e3` |
| `real_time_pcr_1200.png` | L8 `real_time_pcr` | 1200×800 | 31 KB | `82b8a9ecae7a4450bf86360676d786ceb77b5b4a6639d05b9fc48cd63b67a2b9` |
| `cartridge_molecular_480.png` | L9 `cartridge_molecular` | 480×320 | 9 KB | `1cf746824f6a4ba562d052f816213affae6474dfde071eebccda6f34a194ccbd` |
| `cartridge_molecular_1200.png` | L9 `cartridge_molecular` | 1200×800 | 22 KB | `afb377473fd083998a2d8ea7ed1da199097013bd7d9dd67bec0e63157eb25993` |
| `coag_analyzer_480.png` | L10 `coag_analyzer` | 480×320 | 12 KB | `98301f632644922eabc6d89cdfd83505a325b6bdfa6f5070c15880e33bd166b3` |
| `coag_analyzer_1200.png` | L10 `coag_analyzer` | 1200×800 | 34 KB | `291603039245d52c1cb74fa83830d05111199ba778d1f630109078eecf0152a4` |
| `elisa_reader_480.png` | L11 `elisa_reader` | 480×320 | 11 KB | `202ec7d0896e89142f8fc507857e8878d7cac4fbcdbb7abf75fcadf28089583f` |
| `elisa_reader_1200.png` | L11 `elisa_reader` | 1200×800 | 31 KB | `2a0ed8ac2b79ee44ce2e6f75fb2f6b61e15676e90fd7e10392411a13a1cefc9c` |
| `bsc_class2_480.png` | L12 `bsc_class2` | 480×320 | 9 KB | `91209a83ebc1d61c58538ec947f3a1729b46160b42b2a1b9f931cce7980d4eff` |
| `bsc_class2_1200.png` | L12 `bsc_class2` | 1200×800 | 23 KB | `0697a916b3cd0c25c9f2a44f0d542fd79b392b68e781b56d93942a36ef61d440` |
| `autoclave_480.png` | L13 `autoclave` | 480×320 | 14 KB | `2d2725e8d3c629c98da8717aebf1dcd9f0acf3199eea78e60ff60b7c5054922f` |
| `autoclave_1200.png` | L13 `autoclave` | 1200×800 | 38 KB | `1c7202ef1fff854dd9bc892d2f5f5aff730c389769e1155fe9be9cf7d7d2191a` |
| `blood_gas_ise_480.png` | L14 `blood_gas_ise` | 480×320 | 10 KB | `01ae4028f28ba3222f74db6b321d046ba1c23f2eb6d6b2c41835518f31a97fe3` |
| `blood_gas_ise_1200.png` | L14 `blood_gas_ise` | 1200×800 | 30 KB | `544391a5bebb64f1842b862fc15daa871037a80ec20466b769f6930479b7ab97` |
| `hba1c_analyzer_480.png` | L15 `hba1c_analyzer` | 480×320 | 11 KB | `c35234e7988af0d7bd13e7d2f56c60cc7697140cb5f002cc3442183e48c10e96` |
| `hba1c_analyzer_1200.png` | L15 `hba1c_analyzer` | 1200×800 | 34 KB | `f290a29bd4a83799f17e30be2af93930203a466f75ddfe28eabf83c607781a7c` |
| `lab_fridge_480.png` | L16 `lab_fridge` | 480×320 | 9 KB | `ea50de61546bd9ae48f5dbc6c76bf7efed8fa57f52edf34ec6d1c7e38d27b38b` |
| `lab_fridge_1200.png` | L16 `lab_fridge` | 1200×800 | 29 KB | `4e089a230cd579d5dfd2e3027ba32c4e66927ae9cae6d757faf34b44072eede1` |
| `fluorescence_microscope_480.png` | L17 `fluorescence_microscope` | 480×320 | 10 KB | `c883c0668223fbcdb0e647f3be459fa1d8cb04bacad569059ca25f687a8c551d` |
| `fluorescence_microscope_1200.png` | L17 `fluorescence_microscope` | 1200×800 | 30 KB | `29e287448cc12dcf8a7a0c733050e0843c5d8a23e231abd38909bdbd026b34dd` |
| `casa_480.png` | L18 `casa` | 480×320 | 10 KB | `da34a6b4bf9569ff04084d26eb981eb7ad07bfef59ca49ab3a9543db81444b1d` |
| `casa_1200.png` | L18 `casa` | 1200×800 | 29 KB | `32e7e108a6eda35ab2b0667b05494560c2b6d8e30aa255bd0630edd17203a8c9` |
| `gel_card_system_480.png` | L19 `gel_card_system` | 480×320 | 8 KB | `639bbf22c4e08772bd30b62f9e7c79776bbd3ef95c851532dd120494479f0ec0` |
| `gel_card_system_1200.png` | L19 `gel_card_system` | 1200×800 | 19 KB | `7c9951153f5969462d78295b357995322e6a1592e15b724be5737d8c452f4bd7` |
| `esr_analyzer_480.png` | L20 `esr_analyzer` | 480×320 | 7 KB | `c2b728c2684063780f894c5d210c15bb1f82593f4bcffe4f593a8b41f6b87933` |
| `esr_analyzer_1200.png` | L20 `esr_analyzer` | 1200×800 | 21 KB | `bb437a88b8056cbd13822f98823e83a70f56b104a5df9bf7724a96ea5ca2c955` |
| `aggregometer_480.png` | L21 `aggregometer` | 480×320 | 11 KB | `9c97c54fee3428478cae3204b3728959a9514300dee53c6c4584663b6b55f925` |
| `aggregometer_1200.png` | L21 `aggregometer` | 1200×800 | 30 KB | `e69535e7a9d80f5f563096c84e8c2e226e5c0ad1f15e35ef44ffa1f49fe352ee` |
| `electrophoresis_480.png` | L22 `electrophoresis` | 480×320 | 8 KB | `6430e63099b6ae954e54f20caf43c8cbc2ff96469ad5c729ecd0aaa8ac528b03` |
| `electrophoresis_1200.png` | L22 `electrophoresis` | 1200×800 | 27 KB | `bf9e2d7769cfb483661076e5b6beca3a1459dc3476f738ac4305881604a38806` |
| `osmometer_480.png` | L23 `osmometer` | 480×320 | 9 KB | `b4673c89a0e326df65333a35956dda6d0157978b03eb39f2309eb5ee22663602` |
| `osmometer_1200.png` | L23 `osmometer` | 1200×800 | 29 KB | `cb1be611bdb40d874d30e1734628dd0ed98a69eb8a2054c3c100d10909f0e909` |
| `tlc_480.png` | L24 `tlc` | 480×320 | 9 KB | `9e83e1ad700b72af7e46497a811f742f6a071d24c29115e6c2dfb983ef79492e` |
| `tlc_1200.png` | L24 `tlc` | 1200×800 | 31 KB | `ba63bfecb46f8f8a67ae5b6910d4c70225b770a6d3fc6f8d86c2bf2aa7a11846` |
| `analytical_balance_480.png` | L25 `analytical_balance` | 480×320 | 10 KB | `cada8dbb81731f60a9974f7923e0951e7f0046067ec032aff5c8f8f7cba3d548` |
| `analytical_balance_1200.png` | L25 `analytical_balance` | 1200×800 | 32 KB | `71bacbea7b198d1499df5d036c3f3c4bf0bf280124cb19ccf422e627c37807f1` |
