# Sxema va apparat chizmalari — ilmiy tekshiruv jadvali (2026-10-25)

Bu hujjat **LabGuide laboratoriya ta’limi ilovasi** kontentining ilmiy tekshiruvi uchun (boshqa hech qaysi ilovaga aloqasi yo‘q). Egasi topshirig‘i (4-band): 18 ta sxema (`assets/diagrams/`, 6 mavzu × uz/ru/en) va 32 ta apparat sxematik chizmasi (`assets/instruments/schematic/`) dagi **mutaxassis tekshiruvini talab qiladigan har bir da’vo** — alohida jadvalda.

- To‘liq jadval: [`docs/SCIENTIFIC_REVIEW_TABLE.csv`](SCIENTIFIC_REVIEW_TABLE.csv) (UTF-8 BOM, 597 qator, bitta qator — bitta tekshiriladigan da’vo).
- Mutaxassislarga paketlar: [`docs/review_packets_tech/`](review_packets_tech/) — har profilga bitta CSV, xavf bo‘yicha tartiblangan.
- Generator: `python3 tool/review/make_scientific_review_tables.py` (faqat stdlib, deterministik; `--check` — fayllar eskirgan bo‘lsa xato). Qorovul: `test/guards/scientific_review_table_guard_test.dart`.

**Muhim:** `specialist_decision`, `reviewed_by`, `review_date` ustunlari **hamma qatorda bo‘sh** (PENDING). Hech bir qator mutaxassis tomonidan tasdiqlangan emas; bu jadvalda hech kimning nomidan tasdiq yozilmaydi. `SOURCED` — faqat “manbaga havola bor” degani, “tasdiqlangan” emas. Manbasiz ma’lumot hech qachon tasdiqlangan deb belgilanmaydi.

## Holat kodlari (evidence_status)

| kod | ma’nosi | qatorlar |
|---|---|---|
| `SOURCED` | katalog manbasi (catalog.json `sources[].id`), ARB kaliti yoki ilovadagi aniq fayl:qator bor; mazmun mutaxassis tomonidan hali tekshirilmagan | 155 |
| `STANDARD_TEXTBOOK` | darslik darajasidagi umumiy ma’lumot, repoda alohida iqtibos yo‘q (hujjatlarda “STANDARD_TEXTBOOK (NEEDS_EXPERT)”) | 108 |
| `NEEDS_SOURCE` | manbasiz aniq raqam/tafsilot (masalan, harorat, son, vaqt) — avval manba topilishi kerak | 2 |
| `NEEDS_EXPERT` | manba to‘liq qamramaydi (qisman manbali), hujjatlar kelishmaydi, tarjima yoki chizma — mutaxassis ko‘rigi kerak | 313 |
| `APP_RULE_AWAITING_EXPERT` | ilovaning o‘z qoidasi/ish tartibi (registr `AWAITING_EXPERT` yoki DECISIONS.md qarori) — tashqi manba emas | 19 |

Holat qanday aniqlandi (hech bir holat o‘z hisobimdan **ko‘tarilmadi**, faqat ehtiyotkor tomonga tushirildi):

1. Sxemalar: `docs/DIAGRAMS_CONTENT_SOURCES.md` jadvali; shu bo‘limdagi NEEDS_EXPERT izohi yoki `docs/DIAGRAMS_PROVENANCE.md` NEEDS_EXPERT ro‘yxati boshqacha desa — ehtiyotkorrog‘i. `APP_UI` → `APP_RULE_AWAITING_EXPERT`; registr (`CALIB-ACCEPTANCE-RULES`, `DIFF-REFER-BODY-WORDING`) yoki `DECISIONS.md` D-20 ga bog‘langan qoida → `APP_RULE_AWAITING_EXPERT`.
2. Apparat chizmalari: `tool/illustrations/schematic/parts_src.py` `src` va `docs/SCHEMATIC_PARTS_SOURCES.md` (ikkalasi solishtirildi). Faqat katalog manbasi → `SOURCED`; manba + darslik → `NEEDS_EXPERT`; faqat darslik → `STANDARD_TEXTBOOK`.
3. O‘z tekshiruvim (katalog bo‘yicha): (a) keltirilgan manba shu chizmani ishlatuvchi karta/modelda bormi; (b) matndagi har bir raqam (°C, daqiqa, mm, son, nm …) shu manbaga havola qilingan `catalog.json` matnida bormi. Topilmasa: `SOURCED` → `NEEDS_EXPERT`; `STANDARD_TEXTBOOK` → `NEEDS_SOURCE`. Katalogda manbaning faqat qisqa iqtiboslari bor — demak “topilmadi” xato degani emas, manbaning o‘zidan tekshirish kerak degani.
4. Chizma elementlari (kesiklar, ekranlar, sensorlar, ranglar) va tarjimalar — doim `NEEDS_EXPERT`: chizma geometriyasi va tarjima hech bir manba bilan qoplanmagan.
5. Yo‘nalish kartalarining o‘zi ham tekshirilmagan: `catalog.json` dagi barcha kartalar `expert_reviewed: false` (registrdagi `LABCARD-*` yozuvlari `AWAITING_EXPERT`) — `source_evidence` ustunida ko‘rsatilgan.

## Umumiy son

| kind | qator | SOURCED | STANDARD_TEXTBOOK | NEEDS_SOURCE | NEEDS_EXPERT | APP_RULE_AWAITING_EXPERT | high | medium | low |
|---|---|---|---|---|---|---|---|---|---|
| `diagram` | 44 | 28 | 2 | 0 | 4 | 10 | 9 | 25 | 10 |
| `schematic-part` | 223 | 99 | 105 | 2 | 17 | 0 | 3 | 175 | 45 |
| `schematic-principle` | 32 | 13 | 0 | 0 | 19 | 0 | 2 | 30 | 0 |
| `schematic-result` | 32 | 15 | 1 | 0 | 16 | 0 | 10 | 22 | 0 |
| `schematic-drawing` | 72 | 0 | 0 | 0 | 72 | 0 | 0 | 11 | 61 |
| `text-translation` | 194 | 0 | 0 | 0 | 185 | 9 | 0 | 62 | 132 |
| **jami** | 597 | 155 | 108 | 2 | 313 | 19 | 24 | 325 | 248 |

## Eng yuqori xavfli 30 qator (avval shular)

Tartib: xavf (high > medium > low), so‘ng holat (NEEDS_SOURCE > APP_RULE/NEEDS_EXPERT > STANDARD_TEXTBOOK > SOURCED), so‘ng item_id.

| # | item_id | holat | mutaxassis | xavf |
|---|---|---|---|---|
| 1 | `DIAG-calibration_overview-06` | APP_RULE_AWAITING_EXPERT | laboratoriya sifat menejeri / metrolog | high — kalibrlash noto‘g‘ri qabul qilinsa, keyingi barcha natijalar sistematik xato bo‘ladi |
| 2 | `DIAG-calibration_overview-07` | APP_RULE_AWAITING_EXPERT | laboratoriya sifat menejeri / metrolog | high — qabul qilinmagan kalibrlash bilan ishlash — sistematik xato |
| 3 | `DIAG-differential_count-06` | APP_RULE_AWAITING_EXPERT | gematolog | high — blast/aniqlanmagan hujayra yo‘llanmasa — o‘tkir leykozni kechiktirish xavfi |
| 4 | `DIAG-preanalytics-06` | NEEDS_EXPERT | klinik laboratoriya shifokori (umumiy klinik tahlillar) | high — yaroqsiz namuna tahlilga ketsa — noto‘g‘ri natija bemorga beriladi |
| 5 | `DIAG-qc_decision-04` | APP_RULE_AWAITING_EXPERT | klinik biokimyogar | high — 1-2s ni noto‘g‘ri talqin qilish seriyani asossiz qabul/rad qilishga olib keladi |
| 6 | `SCHEM-autoclave-result` | NEEDS_EXPERT | biologik xavfsizlik mutaxassisi | high — samaradorlik indikatorlari noto‘g‘ri tushunilsa — sterillanmagan yuk ishlatiladi |
| 7 | `SCHEM-bsc_class2-part-02` | NEEDS_EXPERT | biologik xavfsizlik mutaxassisi | high — old panjarani to‘sish operator himoyasini buzadi |
| 8 | `SCHEM-bsc_class2-result` | NEEDS_EXPERT | biologik xavfsizlik mutaxassisi | high — shkaf sinovi/sertifikati ahamiyati tushunilmasa — himoyasiz ishlash |
| 9 | `SCHEM-fluorescence_microscope-result` | NEEDS_EXPERT | sil (TB) laboratoriyasi mutaxassisi | high — KChT (AFB) darajalash xato bo‘lsa — sil tashxisi/kuzatuvida xato |
| 10 | `SCHEM-gel_card_system-result` | NEEDS_EXPERT | transfuziolog (immunogematolog) | high — qon guruhi/DAT reaksiyasini noto‘g‘ri o‘qish — mos kelmaydigan transfuziya xavfi |
| 11 | `SCHEM-microbial_id_ast-result` | NEEDS_EXPERT | mikrobiolog | high — MIK va S/R toifasi xato tushunilsa — noto‘g‘ri antibiotik tanlovi |
| 12 | `DIAG-photometry-05` | SOURCED | klinik biokimyogar | high — hisob formulasi xato bo‘lsa — bemor natijasi xato |
| 13 | `DIAG-photometry-06` | SOURCED | klinik biokimyogar | high — suyultirish omili unutilsa — natija bir necha marta past chiqadi |
| 14 | `DIAG-qc_decision-03` | SOURCED | klinik biokimyogar | high — rad qoidasi noto‘g‘ri bo‘lsa, nazoratdan chiqqan seriya natijalari bemorga beriladi |
| 15 | `DIAG-qc_decision-05` | SOURCED | klinik biokimyogar | high — rad qilingan seriyada bemor natijasi berilsa — noto‘g‘ri klinik qaror |
| 16 | `SCHEM-autoclave-principle` | SOURCED | biologik xavfsizlik mutaxassisi | high — sterilizatsiya harorat/bosim/vaqt sharti noto‘g‘ri o‘rgatilsa — sterillanmagan material, infeksiya xavfi |
| 17 | `SCHEM-bsc_class2-principle` | SOURCED | biologik xavfsizlik mutaxassisi | high — havo oqimi himoyasi noto‘g‘ri tushunilsa — operator infeksiyalanishi xavfi |
| 18 | `SCHEM-cartridge_molecular-result` | SOURCED | sil (TB) laboratoriyasi mutaxassisi | high — MTB/RIF natijasi noto‘g‘ri o‘qilsa — sil/rifampitsin chidamliligi bo‘yicha noto‘g‘ri qaror |
| 19 | `SCHEM-coag_analyzer-result` | SOURCED | gematolog | high — INR hisobi (ISI) xato tushunilsa — antikoagulyant dozasi bo‘yicha xato |
| 20 | `SCHEM-flow_cytometer-result` | SOURCED | immunolog | high — mutlaq CD4 hisobi xato tushunilsa — OIV bosqichi bo‘yicha xato |
| 21 | `SCHEM-gel_card_system-part-06` | SOURCED | transfuziolog (immunogematolog) | high — musbat reaksiya ko‘rinishi xato bo‘lsa — qon guruhi xato aniqlanadi |
| 22 | `SCHEM-gel_card_system-part-07` | SOURCED | transfuziolog (immunogematolog) | high — manfiy reaksiya ko‘rinishi xato bo‘lsa — qon guruhi xato aniqlanadi |
| 23 | `SCHEM-mycobacterial_culture-result` | SOURCED | sil (TB) laboratoriyasi mutaxassisi | high — DST talqini (1/2-qator) xato bo‘lsa — sil davolash rejimi noto‘g‘ri |
| 24 | `SCHEM-real_time_pcr-result` | SOURCED | molekulyar diagnost | high — Cq/virus yuki talqini xato bo‘lsa — OIV davolash monitoringida xato |
| 25 | `SCHEM-coag_analyzer-part-04` | NEEDS_SOURCE | gematolog | medium — qism vazifasi xato bo‘lsa, talaba apparat ishlashini noto‘g‘ri tushunadi (bemor natijasiga bevosita ta’sir yo‘q) |
| 26 | `SCHEM-real_time_pcr-part-01` | NEEDS_SOURCE | molekulyar diagnost | medium — qism vazifasi xato bo‘lsa, talaba apparat ishlashini noto‘g‘ri tushunadi (bemor natijasiga bevosita ta’sir yo‘q) |
| 27 | `DIAG-calibration_overview-05` | APP_RULE_AWAITING_EXPERT | laboratoriya sifat menejeri / metrolog | medium — jarayon qadami xato bo‘lsa, talaba noto‘g‘ri tartibni o‘rganadi |
| 28 | `DIAG-calibration_overview-l10n-ru-d` | NEEDS_EXPERT | tibbiy tilshunos (ru) | medium — qaror/harakat qatori; noto‘g‘ri tarjima noto‘g‘ri harakatga olib kelishi mumkin |
| 29 | `DIAG-calibration_overview-l10n-ru-no` | NEEDS_EXPERT | tibbiy tilshunos (ru) | medium — qaror/harakat qatori; noto‘g‘ri tarjima noto‘g‘ri harakatga olib kelishi mumkin |
| 30 | `DIAG-calibration_overview-l10n-ru-ok` | NEEDS_EXPERT | tibbiy tilshunos (ru) | medium — qaror/harakat qatori; noto‘g‘ri tarjima noto‘g‘ri harakatga olib kelishi mumkin |

## Har bir sxema (diagramma) bo‘yicha

| # | sxema | qator | SOURCED | STANDARD_TEXTBOOK | NEEDS_SOURCE | NEEDS_EXPERT | APP_RULE_AWAITING_EXPERT | high | asosiy mutaxassis | birinchi tekshiriladigan |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `qc_decision` (uz/ru/en) | 32 | 8 | 0 | 0 | 20 | 4 | 3 | klinik biokimyogar | `DIAG-qc_decision-04` |
| 2 | `calibration_overview` (uz/ru/en) | 29 | 5 | 0 | 0 | 18 | 6 | 2 | laboratoriya sifat menejeri / metrolog | `DIAG-calibration_overview-06` |
| 3 | `photometry` (uz/ru/en) | 24 | 4 | 2 | 0 | 18 | 0 | 2 | klinik biokimyogar | `DIAG-photometry-05` |
| 4 | `differential_count` (uz/ru/en) | 29 | 5 | 0 | 0 | 23 | 1 | 1 | gematolog | `DIAG-differential_count-06` |
| 5 | `preanalytics` (uz/ru/en) | 30 | 6 | 0 | 0 | 24 | 0 | 1 | klinik laboratoriya shifokori (umumiy klinik tahlillar) | `DIAG-preanalytics-06` |
| 6 | `educational_feedback` (uz/ru/en) | 24 | 0 | 0 | 0 | 16 | 8 | 0 | tibbiy pedagog | `DIAG-educational_feedback-l10n-ru-d` |

## Har bir apparat chizmasi bo‘yicha (ustuvorlik tartibida)

| # | chizma | qator | SOURCED | STANDARD_TEXTBOOK | NEEDS_SOURCE | NEEDS_EXPERT | APP_RULE_AWAITING_EXPERT | high | medium | asosiy mutaxassis | birinchi tekshiriladigan |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `bsc_class2` | 14 | 5 | 3 | 0 | 6 | 0 | 3 | 10 | biologik xavfsizlik mutaxassisi | `SCHEM-bsc_class2-part-02` |
| 2 | `gel_card_system` | 13 | 5 | 2 | 0 | 6 | 0 | 3 | 9 | transfuziolog (immunogematolog) | `SCHEM-gel_card_system-result` |
| 3 | `autoclave` | 14 | 4 | 4 | 0 | 6 | 0 | 2 | 9 | biologik xavfsizlik mutaxassisi | `SCHEM-autoclave-result` |
| 4 | `fluorescence_microscope` | 14 | 2 | 4 | 0 | 8 | 0 | 1 | 9 | sil (TB) laboratoriyasi mutaxassisi | `SCHEM-fluorescence_microscope-result` |
| 5 | `coag_analyzer` | 13 | 3 | 3 | 1 | 6 | 0 | 1 | 9 | gematolog | `SCHEM-coag_analyzer-result` |
| 6 | `flow_cytometer` | 14 | 5 | 2 | 0 | 7 | 0 | 1 | 9 | immunolog | `SCHEM-flow_cytometer-result` |
| 7 | `real_time_pcr` | 13 | 4 | 3 | 1 | 5 | 0 | 1 | 9 | molekulyar diagnost | `SCHEM-real_time_pcr-result` |
| 8 | `microbial_id_ast` | 12 | 3 | 2 | 0 | 7 | 0 | 1 | 8 | mikrobiolog | `SCHEM-microbial_id_ast-result` |
| 9 | `cartridge_molecular` | 11 | 2 | 3 | 0 | 6 | 0 | 1 | 7 | sil (TB) laboratoriyasi mutaxassisi | `SCHEM-cartridge_molecular-result` |
| 10 | `mycobacterial_culture` | 13 | 5 | 2 | 0 | 6 | 0 | 1 | 7 | sil (TB) laboratoriyasi mutaxassisi | `SCHEM-mycobacterial_culture-result` |
| 11 | `mass_spec_gc` | 18 | 2 | 7 | 0 | 9 | 0 | 0 | 11 | toksikolog (analitik kimyogar) | `SCHEM-mass_spec_gc-part-06` |
| 12 | `mass_spec_lc` | 16 | 3 | 6 | 0 | 7 | 0 | 0 | 11 | toksikolog (analitik kimyogar) | `SCHEM-mass_spec_lc-drawing-02` |
| 13 | `tlc` | 14 | 6 | 3 | 0 | 5 | 0 | 0 | 10 | toksikolog (analitik kimyogar) | `SCHEM-tlc-principle` |
| 14 | `aggregometer` | 14 | 9 | 1 | 0 | 4 | 0 | 0 | 10 | gematolog | `SCHEM-aggregometer-part-02` |
| 15 | `chemistry` | 15 | 5 | 4 | 0 | 6 | 0 | 0 | 9 | klinik biokimyogar | `SCHEM-chemistry-drawing-02` |
| 16 | `electrophoresis` | 12 | 6 | 0 | 0 | 6 | 0 | 0 | 9 | klinik biokimyogar | `SCHEM-electrophoresis-drawing-01` |
| 17 | `hematology5` | 14 | 4 | 4 | 0 | 6 | 0 | 0 | 9 | gematolog | `SCHEM-hematology5-drawing-01` |
| 18 | `maldi_tof` | 14 | 5 | 3 | 0 | 6 | 0 | 0 | 9 | mikrobiolog | `SCHEM-maldi_tof-principle` |
| 19 | `elisa_reader` | 14 | 5 | 4 | 0 | 5 | 0 | 0 | 9 | immunolog | `SCHEM-elisa_reader-drawing-01` |
| 20 | `immunoassay` | 15 | 6 | 5 | 0 | 4 | 0 | 0 | 9 | klinik biokimyogar | `SCHEM-immunoassay-part-03` |
| 21 | `hba1c_analyzer` | 15 | 2 | 7 | 0 | 6 | 0 | 0 | 8 | klinik biokimyogar | `SCHEM-hba1c_analyzer-drawing-01` |
| 22 | `esr_analyzer` | 13 | 6 | 2 | 0 | 5 | 0 | 0 | 8 | gematolog | `SCHEM-esr_analyzer-principle` |
| 23 | `blood_culture` | 12 | 2 | 2 | 0 | 8 | 0 | 0 | 7 | mikrobiolog | `SCHEM-blood_culture-part-01` |
| 24 | `blood_gas_ise` | 13 | 2 | 6 | 0 | 5 | 0 | 0 | 7 | klinik biokimyogar | `SCHEM-blood_gas_ise-principle` |
| 25 | `urine_system` | 12 | 5 | 3 | 0 | 4 | 0 | 0 | 7 | klinik laboratoriya shifokori (umumiy klinik tahlillar) | `SCHEM-urine_system-result` |
| 26 | `casa` | 11 | 1 | 3 | 0 | 7 | 0 | 0 | 6 | reproduktiv laboratoriya mutaxassisi (androlog) | `SCHEM-casa-part-01` |
| 27 | `analytical_balance` | 13 | 4 | 3 | 0 | 6 | 0 | 0 | 6 | laboratoriya sifat menejeri / metrolog | `SCHEM-analytical_balance-part-06` |
| 28 | `lab_fridge` | 11 | 4 | 2 | 0 | 5 | 0 | 0 | 6 | laboratoriya sifat menejeri / metrolog | `SCHEM-lab_fridge-principle` |
| 29 | `osmometer` | 11 | 3 | 3 | 0 | 5 | 0 | 0 | 6 | klinik biokimyogar | `SCHEM-osmometer-principle` |
| 30 | `hematology3` | 12 | 3 | 3 | 0 | 6 | 0 | 0 | 5 | gematolog | `SCHEM-hematology3-principle` |
| 31 | `photometer` | 12 | 4 | 3 | 0 | 5 | 0 | 0 | 5 | klinik biokimyogar | `SCHEM-photometer-principle` |
| 32 | `urine_strip` | 11 | 2 | 4 | 0 | 5 | 0 | 0 | 5 | klinik laboratoriya shifokori (umumiy klinik tahlillar) | `SCHEM-urine_strip-principle` |

## Mutaxassis paketlari (har biriga bitta fayl)

Egasi har bir mutaxassisga bitta CSV beradi; mutaxassis faqat `specialist_decision` (masalan: TO‘G‘RI / TUZATISH KERAK / MANBA KERAK + izoh), `reviewed_by` (ism, malaka) va `review_date` ni o‘zi to‘ldiradi. To‘ldirilgan paket bu jadvalga qo‘lda ko‘chiriladi (skript bu ustunlarni hech qachon to‘ldirmaydi).

| mutaxassis profili | paket | qator | high | medium | low | NEEDS_SOURCE | NEEDS_EXPERT + APP_RULE | STANDARD_TEXTBOOK | SOURCED |
|---|---|---|---|---|---|---|---|---|---|
| biologik xavfsizlik mutaxassisi | [`biologik_xavfsizlik_mutaxassisi.csv`](review_packets_tech/biologik_xavfsizlik_mutaxassisi.csv) | 24 | 5 | 15 | 4 | 0 | 8 | 7 | 9 |
| klinik biokimyogar | [`klinik_biokimyogar.csv`](review_packets_tech/klinik_biokimyogar.csv) | 97 | 5 | 62 | 30 | 0 | 27 | 30 | 40 |
| sil (TB) laboratoriyasi mutaxassisi | [`sil_laboratoriyasi_mutaxassisi.csv`](review_packets_tech/sil_laboratoriyasi_mutaxassisi.csv) | 32 | 3 | 17 | 12 | 0 | 14 | 9 | 9 |
| transfuziolog (immunogematolog) | [`transfuziolog.csv`](review_packets_tech/transfuziolog.csv) | 11 | 3 | 7 | 1 | 0 | 4 | 2 | 5 |
| gematolog | [`gematolog.csv`](review_packets_tech/gematolog.csv) | 65 | 2 | 45 | 18 | 1 | 21 | 13 | 30 |
| laboratoriya sifat menejeri / metrolog | [`sifat_menejeri_metrolog.csv`](review_packets_tech/sifat_menejeri_metrolog.csv) | 29 | 2 | 17 | 10 | 0 | 11 | 5 | 13 |
| immunolog | [`immunolog.csv`](review_packets_tech/immunolog.csv) | 24 | 1 | 16 | 7 | 0 | 8 | 6 | 10 |
| klinik laboratoriya shifokori (umumiy klinik tahlillar) | [`klinik_laboratoriya_shifokori.csv`](review_packets_tech/klinik_laboratoriya_shifokori.csv) | 27 | 1 | 17 | 9 | 0 | 7 | 7 | 13 |
| mikrobiolog | [`mikrobiolog.csv`](review_packets_tech/mikrobiolog.csv) | 32 | 1 | 22 | 9 | 0 | 15 | 7 | 10 |
| molekulyar diagnost | [`molekulyar_diagnost.csv`](review_packets_tech/molekulyar_diagnost.csv) | 11 | 1 | 7 | 3 | 1 | 3 | 3 | 4 |
| reproduktiv laboratoriya mutaxassisi (androlog) | [`reproduktiv_laboratoriya_mutaxassisi.csv`](review_packets_tech/reproduktiv_laboratoriya_mutaxassisi.csv) | 9 | 0 | 6 | 3 | 0 | 5 | 3 | 1 |
| tibbiy pedagog | [`tibbiy_pedagog.csv`](review_packets_tech/tibbiy_pedagog.csv) | 6 | 0 | 0 | 6 | 0 | 6 | 0 | 0 |
| tibbiy tilshunos (ru) | [`tibbiy_tilshunos_ru.csv`](review_packets_tech/tibbiy_tilshunos_ru.csv) | 92 | 0 | 31 | 61 | 0 | 92 | 0 | 0 |
| tibbiy tilshunos (uz) | [`tibbiy_tilshunos_uz.csv`](review_packets_tech/tibbiy_tilshunos_uz.csv) | 96 | 0 | 31 | 65 | 0 | 96 | 0 | 0 |
| toksikolog (analitik kimyogar) | [`toksikolog.csv`](review_packets_tech/toksikolog.csv) | 42 | 0 | 32 | 10 | 0 | 15 | 16 | 11 |

## Egasi uchun qaror

1. **Birinchi navbat (high xavf):** klinik biokimyogar (QC rad qoidalari, fotometriya hisobi), laboratoriya sifat menejeri (kalibrlashni qabul qilish qoidasi), gematolog (blast yo‘llanmasi, INR), biologik xavfsizlik mutaxassisi (avtoklav, BXSh), sil laboratoriyasi mutaxassisi (MGIT DST, Xpert, AFB), transfuziolog (gel karta), mikrobiolog (MIK), molekulyar diagnost va immunolog (virus yuki, CD4).
2. **`NEEDS_SOURCE` qatorlari** — mutaxassisdan oldin manba topilishi kerak (yoki raqam matndan olib tashlanadi).
3. **Tarjima paketlari** (uz/ru tibbiy tilshunos) — mazmun tasdiqlangandan keyin.
4. Mutaxassis javobisiz hech bir qator “tasdiqlangan” deb ko‘rsatilmaydi; ilovada “Sxematik tasvir — aniq model emas” va “IFU / SOP ustun” izohlari qoladi.

## Topilgan nomuvofiqliklar

Tuzatilmadi (lib/, ARB, katalog, assets o‘zgartirilmaydi) — faqat ro‘yxat; har biri jadvalda tegishli qatorda ham bor.

1. **DRAW-ELISA** — `elisa_reader` chizmasi: `gen.py` izohi “lampa → filtr → quduqcha → detektor”, lekin chizilgan tartib lampa (2) → quduqcha (3) → filtr (4) → detektor (5). Prinsip matni “tanlangan to‘lqin uzunligidagi nur quduqchadan o‘tadi” deydi. Qaysi tartib ko‘zda tutilgani mutaxassis bilan aniqlansin (SCHEM-elisa_reader-drawing-01).
2. **DRAW-HBA1C** — `hba1c_analyzer`: docs/LAB_CARD_IMAGE_COVERAGE.md (a2-test-hba1c, a2-platform-hba1c-analyzer) “ichki usul ataylab ko‘rsatilmagan” deydi, lekin 2026-10-25 yangilangan chizma (SCHEMATICS_PROVENANCE.md) ion almashinuv kolonkasi, fotometrik detektor va xromatogrammani ko‘rsatadi; `labSchemHba1cAnalyzer` alt-matnida esa kolonka/detektor yo‘q. Karta bir nechta usulni (ion almashinish, borat affinligi, immunoanaliz, ferment) qamraydi (SCHEM-hba1c_analyzer-drawing-01).
3. **DRAW-TUBES** — `hematology5` avtoyuklagichi (`rack(..., caps=TUBE_CAPS)`), `chemistry` va `immunoassay` namuna rakalari turli rangli qopqoqli (binafsha, qizil, sariq, ko‘k, yashil) to‘liq qon probirkalari bilan chizilgan. Umumiy qon tahlili — EDTA (binafsha), biokimyo/immunoanaliz — zardob/plazma. `coag_analyzer` (havorang) va `hba1c_analyzer` (binafsha) to‘g‘ri chizilgani uchun bu nomuvofiqlik ko‘zga tashlanadi.
4. **DRAW-HEM3** — `hematology3` displeyida uchta bir xil Gauss shaklidagi gistogramma; haqiqiy 3 qismli WBC gistogrammasida uchta subpopulyatsiya, PLT gistogrammasi o‘ngga cho‘zilgan — soddalashtirish o‘quvchini chalg‘itishi mumkin (SCHEM-hematology3-drawing-02).
5. **L10N-REFERENS** — `differential_count.uz.png` va ARB `diffInterpretIntro`/`diffRangesBody` “referens oraliq” deydi; docs/L10N_TERMINOLOGY_DECISIONS.md uz uchun yagona atama “referens interval” (NEEDS_NATIVE_REVIEW) deb qayd etgan.
6. **L10N-DIF-OIL** — `differential_count` 2-qadam: en “×100 oil”, ru/uz faqat “×100” — immersion moyi haqidagi ma’lumot tushib qolgan.
7. **L10N-QC-STOP** — `qc_decision`: en “Reject: stop, do not report results”; ru “Отклонить: результаты пациентов не выдавать”, uz “Rad: bemor natijalarini bermang” — “stop/to‘xtating” yo‘q. uz 4-qadam “QC va namunalarni” — en “patient samples” (‘bemor’ yo‘q).
8. **CIT-WHO2003** — `differential_count` pastki iqtibosi “WHO basic laboratory manual 2003” — WHO 2003 hujjatining rasmiy nomi “Manual of basic techniques for a health laboratory, 2nd ed.”; ru/uz da “Руководство ВОЗ 2003” / “JSST qo‘llanmasi 2003” (nom qisqartirilgan).
9. **TERM-ABS** — `photometry`: en “Absorbance” → ru “Оптическая плотность”, uz “Optik zichlik” (IUPAC bo‘yicha absorbance va optical density farqlanadi; ilova ma’ruzasi atamasi bilan bir xil — atama qarori kerak, DIAGRAMS_CONTENT_SOURCES.md da allaqachon NEEDS_EXPERT).
10. **DOC-DISAGREE** — docs/DIAGRAMS_CONTENT_SOURCES.md: QC-4 jadvalda `SOURCED`, lekin shu bo‘limning NEEDS_EXPERT izohida (qator 34) mutaxassis tasdig‘i talab qilingan — jadvalda ehtiyotkor holat olindi.
11. **DOC-DISAGREE** — CAL-5: DIAGRAMS_CONTENT_SOURCES.md da `SOURCED`, lekin registr `CALIB-ACCEPTANCE-RULES` (AWAITING_EXPERT) qabul shartini ilova qoidasi deb belgilaydi — ehtiyotkorrog‘i olindi.
12. **DOC-GAP** — `differential_count` sxemasining pastki iqtibosi (“WHO basic laboratory manual 2003 · lab SOP prevails”) docs/DIAGRAMS_CONTENT_SOURCES.md jadvalida ID siz — jadvalga DIAG-differential_count-08 sifatida qo‘shildi.
13. **DOC-DISAGREE** — PHO-1 (fotometriya optik yo‘li): DIAGRAMS_CONTENT_SOURCES.md da `SOURCED`, DIAGRAMS_PROVENANCE.md:96 da NEEDS_EXPERT (filtr o‘rniga monoxromator) — ehtiyotkorrog‘i olindi.
14. **SRC-SCOPE** — SCHEM-urine_strip-principle: manba `ro-6500` shu chizmani ishlatuvchi karta/modellarda keltirilmagan.
15. **NUM-UNVERIFIED** — SCHEM-flow_cytometer-part-06: “90 °” keltirilgan manba (a3-statpearls-flow) bo‘yicha katalog matnida yo‘q.
16. **NUM-NO-SOURCE** — SCHEM-real_time_pcr-part-01: “8 tube” — manbasiz aniq raqam (STANDARD_TEXTBOOK).
17. **NUM-NO-SOURCE** — SCHEM-coag_analyzer-part-04: “37 °C” — manbasiz aniq raqam (STANDARD_TEXTBOOK).

## Qayta yaratish

```
python3 tool/review/make_scientific_review_tables.py          # CSV + MD + paketlar
python3 tool/review/make_scientific_review_tables.py --check  # eskirgan bo‘lsa exit 1
flutter test test/guards/scientific_review_table_guard_test.dart
```

Qorovul: CSV bor; 32 chizma kaliti va 6 mavzu (18 PNG) qamralgan; holat ruxsat etilgan to‘plamda; `specialist_decision`/`reviewed_by`/`review_date` bo‘sh; `SOURCED` qatorida manba id bor; `schematic_parts.json` dagi har bir `schemParts*` qism/prinsip/natija id jadvalda bor — yangi qism tekshiruv jadvalisiz chiqmaydi.
