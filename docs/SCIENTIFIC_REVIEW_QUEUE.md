# Ilmiy tekshiruv navbati (mutaxassis ko‘rigini kutayotgan bandlar)

LabGuide o‘quv kontenti uchun. Manba: `docs/SCIENTIFIC_REVIEW_TABLE.csv` (qayta yaratish: `python3 tool/review/make_review_queue.py`). **Hech kim nomidan tasdiq yozilmagan**: `specialist_decision`, `reviewed_by`, `review_date` ustunlari hamma qatorda bo‘sh. Bu ro‘yxat tibbiy yoki laboratoriya ko‘rsatmasi emas — faqat tekshirish navbati.

Jami kutayotgan: **332** (APP_RULE_AWAITING_EXPERT 19, NEEDS_EXPERT 313). Xavf: yuqori 11, o‘rta 122, past 199.

Tartib qoidasi: avval xavf (yuqori → past), keyin ilova qoidasi (APP_RULE) → natija → prinsip → diagramma → qism → rasm elementi → tarjima; keyin `item_id`.

## 1. Eng xavfli 30 band (birinchi navbat)

| # | Mavzu | item_id | Nima tekshiriladi | Kim ko‘radi | Xavf | Holat |
|---|---|---|---|---|---|---|
| 1 | Kalibrlash | `DIAG-calibration_overview-06` | ‘Vakolatli shaxs tomonidan qabul’ — ilova qoidasi (registry CALIB-ACCEPTANCE-RULES, AWAITING_EXPERT), ishlab chiqaruvchi chegarasi emas. | laboratoriya sifat menejeri / metrolog | high | APP_RULE_AWAITING_EXPERT |
| 2 | Kalibrlash | `DIAG-calibration_overview-07` | ‘Qabul qilinmaydi — sabab IFU va SOP bo‘yicha’ — ilova qoidasi (CALIB-ACCEPTANCE-RULES). | laboratoriya sifat menejeri / metrolog | high | APP_RULE_AWAITING_EXPERT |
| 3 | Leykoformula | `DIAG-differential_count-06` | Blast/aniqlanmagan hujayrada yo‘llash matni — registry DIFF-REFER-BODY-WORDING (AWAITING_EXPERT). | gematolog | high | APP_RULE_AWAITING_EXPERT |
| 4 | Sifat nazorati (QC) | `DIAG-qc_decision-04` | Ilova qarori D-20: 1-2s har seriyada faqat ogohlantirish, barcha rad qoidalari tekshiriladi (1981 dagi ‘1-2s eshik’ tartibidan qattiqroq) — klinik biokimyogar t | klinik biokimyogar | high | APP_RULE_AWAITING_EXPERT |
| 5 | Biologik xavfsizlik va sterilizatsiya | `SCHEM-autoclave-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | biologik xavfsizlik mutaxassisi | high | NEEDS_EXPERT |
| 6 | Biologik xavfsizlik va sterilizatsiya | `SCHEM-bsc_class2-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | biologik xavfsizlik mutaxassisi | high | NEEDS_EXPERT |
| 7 | Mikroskopiya | `SCHEM-fluorescence_microscope-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | sil (TB) laboratoriyasi mutaxassisi | high | NEEDS_EXPERT |
| 8 | Gematologiya va gemostaz | `SCHEM-gel_card_system-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | transfuziolog (immunogematolog) | high | NEEDS_EXPERT |
| 9 | Mikrobiologiya | `SCHEM-microbial_id_ast-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | mikrobiolog | high | NEEDS_EXPERT |
| 10 | Preanalitika | `DIAG-preanalytics-06` | ‘Namuna yaroqlimi?’ — yaroqlilik mezonlari ilovada sanalmagan, laboratoriya SOP’iga topshirilgan. | klinik laboratoriya shifokori (umumiy klinik tahlillar) | high | NEEDS_EXPERT |
| 11 | Biologik xavfsizlik va sterilizatsiya | `SCHEM-bsc_class2-part-02` | 2-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qismi bor) — manba qamr | biologik xavfsizlik mutaxassisi | high | NEEDS_EXPERT |
| 12 | Kalibrlash | `DIAG-calibration_overview-05` | Kalibrlashdan keyin QC o‘tishi qabul sharti sifatida — ilova qoidasi (CALIB-ACCEPTANCE-RULES). | laboratoriya sifat menejeri / metrolog | medium | APP_RULE_AWAITING_EXPERT |
| 13 | Asosiy jihozlar | `SCHEM-analytical_balance-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | laboratoriya sifat menejeri / metrolog | medium | NEEDS_EXPERT |
| 14 | Mikrobiologiya | `SCHEM-blood_culture-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | mikrobiolog | medium | NEEDS_EXPERT |
| 15 | Mikroskopiya | `SCHEM-casa-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | reproduktiv laboratoriya mutaxassisi (androlog) | medium | NEEDS_EXPERT |
| 16 | Kimyo / fotometr analizatorlari | `SCHEM-chemistry-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | klinik biokimyogar | medium | NEEDS_EXPERT |
| 17 | Kimyo / fotometr analizatorlari | `SCHEM-electrophoresis-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | klinik biokimyogar | medium | NEEDS_EXPERT |
| 18 | Immunoanaliz va ELISA | `SCHEM-elisa_reader-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | immunolog | medium | NEEDS_EXPERT |
| 19 | Gematologiya va gemostaz | `SCHEM-hematology3-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | gematolog | medium | NEEDS_EXPERT |
| 20 | Massa-spektrometriya | `SCHEM-mass_spec_gc-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | toksikolog (analitik kimyogar) | medium | NEEDS_EXPERT |
| 21 | Massa-spektrometriya | `SCHEM-mass_spec_lc-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | toksikolog (analitik kimyogar) | medium | NEEDS_EXPERT |
| 22 | Siydik tahlili | `SCHEM-urine_strip-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | klinik laboratoriya shifokori (umumiy klinik tahlillar) | medium | NEEDS_EXPERT |
| 23 | Siydik tahlili | `SCHEM-urine_system-result` | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDARD_TEXTBOOK qismi bo | klinik laboratoriya shifokori (umumiy klinik tahlillar) | medium | NEEDS_EXPERT |
| 24 | Kimyo / fotometr analizatorlari | `SCHEM-blood_gas_ise-principle` | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi. [qisman manbali ( | klinik biokimyogar | medium | NEEDS_EXPERT |
| 25 | Molekulyar diagnostika | `SCHEM-cartridge_molecular-principle` | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi. [qisman manbali ( | sil (TB) laboratoriyasi mutaxassisi | medium | NEEDS_EXPERT |
| 26 | Mikroskopiya | `SCHEM-casa-principle` | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi. [qisman manbali ( | reproduktiv laboratoriya mutaxassisi (androlog) | medium | NEEDS_EXPERT |
| 27 | Gematologiya va gemostaz | `SCHEM-coag_analyzer-principle` | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi. [qisman manbali ( | gematolog | medium | NEEDS_EXPERT |
| 28 | Gematologiya va gemostaz | `SCHEM-esr_analyzer-principle` | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi. [qisman manbali ( | gematolog | medium | NEEDS_EXPERT |
| 29 | Gematologiya va gemostaz | `SCHEM-flow_cytometer-principle` | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi. [qisman manbali ( | immunolog | medium | NEEDS_EXPERT |
| 30 | Mikroskopiya | `SCHEM-fluorescence_microscope-principle` | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi. [qisman manbali ( | sil (TB) laboratoriyasi mutaxassisi | medium | NEEDS_EXPERT |

## 2. Mavzu bo‘yicha (har mavzuda xavf bo‘yicha tartiblangan)

| Mavzu | Jami | Yuqori | O‘rta | Past | Birinchi 30 ichida |
|---|---|---|---|---|---|
| Kalibrlash | 24 | 2 | 7 | 15 | 3 |
| Leykoformula | 24 | 1 | 11 | 12 | 1 |
| Sifat nazorati (QC) | 24 | 1 | 12 | 11 | 1 |
| Biologik xavfsizlik va sterilizatsiya | 12 | 3 | 5 | 4 | 3 |
| Mikroskopiya | 15 | 1 | 8 | 6 | 4 |
| Gematologiya va gemostaz | 40 | 1 | 19 | 20 | 5 |
| Mikrobiologiya | 21 | 1 | 12 | 8 | 2 |
| Preanalitika | 24 | 1 | 6 | 17 | 1 |
| Asosiy jihozlar | 11 | 0 | 3 | 8 | 1 |
| Kimyo / fotometr analizatorlari | 38 | 0 | 11 | 27 | 3 |
| Immunoanaliz va ELISA | 9 | 0 | 2 | 7 | 1 |
| Massa-spektrometriya | 22 | 0 | 7 | 15 | 2 |
| Siydik tahlili | 9 | 0 | 3 | 6 | 2 |
| Molekulyar diagnostika | 11 | 0 | 7 | 4 | 1 |
| Fotometriya | 18 | 0 | 7 | 11 | 0 |
| O‘quv natijalari oqimi | 24 | 0 | 2 | 22 | 0 |
| Diagrammalar (boshqa) | 3 | 0 | 0 | 3 | 0 |
| Umumiy matnlar (sxemalar) | 3 | 0 | 0 | 3 | 0 |

### Kalibrlash (24)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 1 | `DIAG-calibration_overview-06` | high | APP_RULE_AWAITING_EXPERT | ‘Vakolatli shaxs tomonidan qabul’ — ilova qoidasi (registry CALIB-ACCEPTANCE-RULES, AWAITING_EXPERT), ishlab chiqaruvchi chegarasi emas. |
| 2 | `DIAG-calibration_overview-07` | high | APP_RULE_AWAITING_EXPERT | ‘Qabul qilinmaydi — sabab IFU va SOP bo‘yicha’ — ilova qoidasi (CALIB-ACCEPTANCE-RULES). |
| 12 | `DIAG-calibration_overview-05` | medium | APP_RULE_AWAITING_EXPERT | Kalibrlashdan keyin QC o‘tishi qabul sharti sifatida — ilova qoidasi (CALIB-ACCEPTANCE-RULES). |
| 72 | `DIAG-calibration_overview-l10n-ru-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 73 | `DIAG-calibration_overview-l10n-ru-no` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 74 | `DIAG-calibration_overview-l10n-ru-ok` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 75 | `DIAG-calibration_overview-l10n-uz-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 76 | `DIAG-calibration_overview-l10n-uz-no` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 77 | `DIAG-calibration_overview-l10n-uz-ok` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 139 | `DIAG-calibration_overview-alt-en` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-calibration_overvie |
| 140 | `DIAG-calibration_overview-alt-ru` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-calibration_overvie |
| 141 | `DIAG-calibration_overview-alt-uz` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-calibration_overvie |
| 210 | `DIAG-calibration_overview-l10n-ru-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 211 | `DIAG-calibration_overview-l10n-ru-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 212 | `DIAG-calibration_overview-l10n-ru-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 213 | `DIAG-calibration_overview-l10n-ru-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 214 | `DIAG-calibration_overview-l10n-ru-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 215 | `DIAG-calibration_overview-l10n-ru-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 216 | `DIAG-calibration_overview-l10n-uz-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 217 | `DIAG-calibration_overview-l10n-uz-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 218 | `DIAG-calibration_overview-l10n-uz-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 219 | `DIAG-calibration_overview-l10n-uz-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 220 | `DIAG-calibration_overview-l10n-uz-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 221 | `DIAG-calibration_overview-l10n-uz-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |

### Leykoformula (24)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 3 | `DIAG-differential_count-06` | high | APP_RULE_AWAITING_EXPERT | Blast/aniqlanmagan hujayrada yo‘llash matni — registry DIFF-REFER-BODY-WORDING (AWAITING_EXPERT). |
| 43 | `DIAG-differential_count-02` | medium | NEEDS_EXPERT | ‘Yomon surtma — yangisini tayyorlang’ — WHO 2003 dan amaliy xulosa (to‘g‘ridan-to‘g‘ri iqtibos emas). [Holat: hujjatdagi holat ‘STANDARD_TEX |
| 78 | `DIAG-differential_count-l10n-ru-d2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 79 | `DIAG-differential_count-l10n-ru-footer` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘ВОЗ 2003’ — ilova ARB `diffRangesWho` qisqa iqtibos |
| 80 | `DIAG-differential_count-l10n-ru-refer` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 81 | `DIAG-differential_count-l10n-ru-report` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 82 | `DIAG-differential_count-l10n-ru-s2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. en ‘×100 oil’ → ‘иммерсия ×100’ (2026-10-25 da tuzat |
| 83 | `DIAG-differential_count-l10n-uz-d2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 84 | `DIAG-differential_count-l10n-uz-footer` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘JSST 2003’ — ilova ARB `diffRangesWho` qisqa iqtibo |
| 85 | `DIAG-differential_count-l10n-uz-refer` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 86 | `DIAG-differential_count-l10n-uz-report` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘Referens interval’ — L10N_TERMINOLOGY_DECISIONS.md  |
| 87 | `DIAG-differential_count-l10n-uz-s2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. en ‘×100 oil’ → ‘×100 immersiya’ (2026-10-25 da tuza |
| 148 | `DIAG-differential_count-08` | low | NEEDS_EXPERT | Pastki iqtibos ‘WHO 2003’ (ilova ARB `diffRangesWho` qisqa shakli); to‘liq nom: WHO ‘Manual of basic techniques for a health laboratory’, 2n |
| 225 | `DIAG-differential_count-alt-en` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-differential_count- |
| 226 | `DIAG-differential_count-alt-ru` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-differential_count- |
| 227 | `DIAG-differential_count-alt-uz` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-differential_count- |
| 228 | `DIAG-differential_count-l10n-ru-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 229 | `DIAG-differential_count-l10n-ru-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 230 | `DIAG-differential_count-l10n-ru-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 231 | `DIAG-differential_count-l10n-ru-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 232 | `DIAG-differential_count-l10n-uz-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 233 | `DIAG-differential_count-l10n-uz-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 234 | `DIAG-differential_count-l10n-uz-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 235 | `DIAG-differential_count-l10n-uz-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |

### Sifat nazorati (QC) (24)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 4 | `DIAG-qc_decision-04` | high | APP_RULE_AWAITING_EXPERT | Ilova qarori D-20: 1-2s har seriyada faqat ogohlantirish, barcha rad qoidalari tekshiriladi (1981 dagi ‘1-2s eshik’ tartibidan qattiqroq) —  |
| 102 | `DIAG-qc_decision-l10n-ru-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 103 | `DIAG-qc_decision-l10n-ru-ok` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 104 | `DIAG-qc_decision-l10n-ru-r1` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘stop’ → ‘остановить’ (2026-10-25 da qaytarildi; ilo |
| 105 | `DIAG-qc_decision-l10n-ru-r2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 106 | `DIAG-qc_decision-l10n-ru-r3` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 107 | `DIAG-qc_decision-l10n-ru-r4` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘Выдача — после восстановления КК’ — qisqartirilgan  |
| 108 | `DIAG-qc_decision-l10n-uz-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 109 | `DIAG-qc_decision-l10n-uz-ok` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 110 | `DIAG-qc_decision-l10n-uz-r1` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘stop’ → ‘to‘xtating’ (2026-10-25 da qaytarildi; ilo |
| 111 | `DIAG-qc_decision-l10n-uz-r2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 112 | `DIAG-qc_decision-l10n-uz-r3` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘patient samples’ → ‘bemor namunalarini’ (2026-10-25 |
| 113 | `DIAG-qc_decision-l10n-uz-r4` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘QC tiklangach natija bering’ — qisqartirilgan ibora |
| 145 | `DIAG-qc_decision-alt-en` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-qc_decision-NN qato |
| 146 | `DIAG-qc_decision-alt-ru` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-qc_decision-NN qato |
| 147 | `DIAG-qc_decision-alt-uz` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-qc_decision-NN qato |
| 278 | `DIAG-qc_decision-l10n-ru-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 279 | `DIAG-qc_decision-l10n-ru-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 280 | `DIAG-qc_decision-l10n-ru-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 281 | `DIAG-qc_decision-l10n-ru-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 282 | `DIAG-qc_decision-l10n-uz-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 283 | `DIAG-qc_decision-l10n-uz-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 284 | `DIAG-qc_decision-l10n-uz-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 285 | `DIAG-qc_decision-l10n-uz-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |

### Biologik xavfsizlik va sterilizatsiya (12)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 5 | `SCHEM-autoclave-result` | high | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 6 | `SCHEM-bsc_class2-result` | high | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 11 | `SCHEM-bsc_class2-part-02` | high | NEEDS_EXPERT | 2-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 61 | `SCHEM-bsc_class2-drawing-01` | medium | NEEDS_EXPERT | Havo oqimi yo‘nalishlari II sinf shkafiga mosmi (pastga oqimning bir qismi orqa panjaraga ketishi ko‘rsatilmagan). (Chizma geometriyasi hech |
| 114 | `SCHEM-autoclave-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 115 | `SCHEM-autoclave-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 116 | `SCHEM-bsc_class2-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 117 | `SCHEM-bsc_class2-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 153 | `SCHEM-autoclave-drawing-01` | low | NEEDS_EXPERT | Manometr/termometr tasviri. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 154 | `SCHEM-autoclave-drawing-02` | low | NEEDS_EXPERT | Klapan va suv idishi joylashuvi umumiy sinfga mosmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 155 | `SCHEM-autoclave-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 160 | `SCHEM-bsc_class2-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |

### Mikroskopiya (15)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 7 | `SCHEM-fluorescence_microscope-result` | high | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 15 | `SCHEM-casa-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 26 | `SCHEM-casa-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 30 | `SCHEM-fluorescence_microscope-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 50 | `SCHEM-casa-part-01` | medium | NEEDS_EXPERT | 1-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 55 | `SCHEM-fluorescence_microscope-part-07` | medium | NEEDS_EXPERT | 7-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 65 | `SCHEM-fluorescence_microscope-drawing-01` | medium | NEEDS_EXPERT | Auramin bo‘yog‘idagi KChT ko‘rinishi va kattaligi to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi m |
| 124 | `SCHEM-fluorescence_microscope-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 125 | `SCHEM-fluorescence_microscope-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 163 | `SCHEM-casa-drawing-01` | low | NEEDS_EXPERT | Izlar tasviri CASA kinematikasiga mosmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 164 | `SCHEM-casa-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 175 | `SCHEM-fluorescence_microscope-drawing-02` | low | NEEDS_EXPERT | Epi-fluoressensiya tuzilishi to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 176 | `SCHEM-fluorescence_microscope-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 294 | `SCHEM-casa-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 295 | `SCHEM-casa-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Gematologiya va gemostaz (40)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 8 | `SCHEM-gel_card_system-result` | high | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 19 | `SCHEM-hematology3-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 27 | `SCHEM-coag_analyzer-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 28 | `SCHEM-esr_analyzer-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 29 | `SCHEM-flow_cytometer-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 31 | `SCHEM-gel_card_system-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 33 | `SCHEM-hematology3-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 51 | `SCHEM-coag_analyzer-part-05` | medium | NEEDS_EXPERT | 5-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 53 | `SCHEM-flow_cytometer-part-05` | medium | NEEDS_EXPERT | 5-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 54 | `SCHEM-flow_cytometer-part-06` | medium | NEEDS_EXPERT | 6-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 56 | `SCHEM-hematology5-part-06` | medium | NEEDS_EXPERT | 6-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 66 | `SCHEM-gel_card_system-drawing-01` | medium | NEEDS_EXPERT | Reaksiya darajalari (4+ … 1+, manfiy) ko‘rinishi to‘g‘rimi; tarqalgan hujayralar aralash maydon (mixed field) deb noto‘g‘ri o‘qilmaydimi. (C |
| 68 | `SCHEM-hematology5-drawing-01` | medium | NEEDS_EXPERT | Impedans va lazerli oqim kanalining sxematik tuzilishi to‘g‘rimi (teshik, elektrodlar, nur yo‘li). (Chizma geometriyasi hech bir manba bilan |
| 69 | `SCHEM-hematology5-drawing-03` | medium | NEEDS_EXPERT | Umumiy qon tahlili namunasi (EDTA turi) to‘g‘ri ko‘rsatilganmi; qopqoq rangi mamlakat/ishlab chiqaruvchiga qarab farq qilishi izohlanishi ke |
| 120 | `SCHEM-coag_analyzer-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 121 | `SCHEM-coag_analyzer-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 122 | `SCHEM-flow_cytometer-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 123 | `SCHEM-flow_cytometer-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 126 | `SCHEM-gel_card_system-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 127 | `SCHEM-gel_card_system-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 149 | `SCHEM-aggregometer-drawing-01` | low | NEEDS_EXPERT | Agregatsiya va TEG/ROTEM iz shakllari to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 150 | `SCHEM-aggregometer-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 167 | `SCHEM-coag_analyzer-drawing-01` | low | NEEDS_EXPERT | Laxta hosil bo‘lganda o‘tgan nur kamayishi (egri chiziq yo‘nalishi) to‘g‘ri ko‘rsatilganmi. (Chizma geometriyasi hech bir manba bilan qoplan |
| 168 | `SCHEM-coag_analyzer-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 171 | `SCHEM-esr_analyzer-drawing-01` | low | NEEDS_EXPERT | Avtomatik o‘quvchi probirkalari Westergren uzunligida emas — usul farqi (modifikatsiyalangan usul) izohlanishi kerakmi. (Chizma geometriyasi |
| 172 | `SCHEM-esr_analyzer-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 173 | `SCHEM-flow_cytometer-drawing-01` | low | NEEDS_EXPERT | Optik sxema to‘g‘rimi (FSC nur o‘qida, SSC/FL 90° da). (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali |
| 174 | `SCHEM-flow_cytometer-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 177 | `SCHEM-gel_card_system-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 180 | `SCHEM-hematology3-drawing-01` | low | NEEDS_EXPERT | Kulter tamoyili sxemasi to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 181 | `SCHEM-hematology3-drawing-02` | low | NEEDS_EXPERT | Gistogramma shakllari (cho‘qqilar nisbati va joylashuvi) o‘quv uchun maqbulmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat |
| 182 | `SCHEM-hematology5-drawing-02` | low | NEEDS_EXPERT | 5 klaster 5 qismli differensialni anglatadi — klasterlar joylashuvi o‘quv uchun maqbulmi. (Chizma geometriyasi hech bir manba bilan qoplanma |
| 286 | `SCHEM-aggregometer-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 287 | `SCHEM-aggregometer-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 305 | `SCHEM-esr_analyzer-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 306 | `SCHEM-esr_analyzer-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 309 | `SCHEM-hematology3-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 310 | `SCHEM-hematology3-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 311 | `SCHEM-hematology5-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 312 | `SCHEM-hematology5-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Mikrobiologiya (21)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 9 | `SCHEM-microbial_id_ast-result` | high | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 14 | `SCHEM-blood_culture-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 38 | `SCHEM-microbial_id_ast-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 46 | `SCHEM-blood_culture-part-01` | medium | NEEDS_EXPERT | 1-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 47 | `SCHEM-blood_culture-part-03` | medium | NEEDS_EXPERT | 3-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 48 | `SCHEM-blood_culture-part-04` | medium | NEEDS_EXPERT | 4-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 58 | `SCHEM-microbial_id_ast-part-01` | medium | NEEDS_EXPERT | 1-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 59 | `SCHEM-mycobacterial_culture-part-03` | medium | NEEDS_EXPERT | 3-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 71 | `SCHEM-mycobacterial_culture-drawing-02` | medium | NEEDS_EXPERT | DST egri chiziqlari talqini to‘g‘ri ko‘rsatilganmi (qaysi biri nazorat). (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism  |
| 128 | `SCHEM-microbial_id_ast-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 129 | `SCHEM-microbial_id_ast-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 130 | `SCHEM-mycobacterial_culture-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 131 | `SCHEM-mycobacterial_culture-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 156 | `SCHEM-blood_culture-drawing-01` | low | NEEDS_EXPERT | Och rangli flakonlar ma’nosi (qonsiz/manfiy?) tushunarlimi; musbat flakon chirog‘i rangi ko‘rsatilganmi. (Chizma geometriyasi hech bir manba |
| 157 | `SCHEM-blood_culture-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 196 | `SCHEM-microbial_id_ast-drawing-01` | low | NEEDS_EXPERT | Karta–somon–probirka ulanishi va skaner tasviri to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi man |
| 197 | `SCHEM-microbial_id_ast-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 198 | `SCHEM-mycobacterial_culture-drawing-01` | low | NEEDS_EXPERT | Musbat probirka sensori ko‘rinishi to‘g‘rimi (UB ostida to‘q sariq fluoressensiya). (Chizma geometriyasi hech bir manba bilan qoplanmagan —  |
| 199 | `SCHEM-mycobacterial_culture-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 290 | `SCHEM-blood_culture-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 291 | `SCHEM-blood_culture-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Preanalitika (24)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 10 | `DIAG-preanalytics-06` | high | NEEDS_EXPERT | ‘Namuna yaroqlimi?’ — yaroqlilik mezonlari ilovada sanalmagan, laboratoriya SOP’iga topshirilgan. |
| 96 | `DIAG-preanalytics-l10n-ru-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 97 | `DIAG-preanalytics-l10n-ru-no` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 98 | `DIAG-preanalytics-l10n-ru-ok` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 99 | `DIAG-preanalytics-l10n-uz-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 100 | `DIAG-preanalytics-l10n-uz-no` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 101 | `DIAG-preanalytics-l10n-uz-ok` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 261 | `DIAG-preanalytics-alt-en` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-preanalytics-NN qat |
| 262 | `DIAG-preanalytics-alt-ru` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-preanalytics-NN qat |
| 263 | `DIAG-preanalytics-alt-uz` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-preanalytics-NN qat |
| 264 | `DIAG-preanalytics-l10n-ru-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 265 | `DIAG-preanalytics-l10n-ru-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 266 | `DIAG-preanalytics-l10n-ru-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 267 | `DIAG-preanalytics-l10n-ru-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 268 | `DIAG-preanalytics-l10n-ru-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 269 | `DIAG-preanalytics-l10n-ru-s5` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 270 | `DIAG-preanalytics-l10n-ru-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 271 | `DIAG-preanalytics-l10n-uz-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 272 | `DIAG-preanalytics-l10n-uz-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 273 | `DIAG-preanalytics-l10n-uz-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 274 | `DIAG-preanalytics-l10n-uz-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 275 | `DIAG-preanalytics-l10n-uz-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 276 | `DIAG-preanalytics-l10n-uz-s5` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 277 | `DIAG-preanalytics-l10n-uz-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |

### Asosiy jihozlar (11)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 13 | `SCHEM-analytical_balance-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 34 | `SCHEM-lab_fridge-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 45 | `SCHEM-analytical_balance-part-06` | medium | NEEDS_EXPERT | 6-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 151 | `SCHEM-analytical_balance-drawing-01` | low | NEEDS_EXPERT | Havo harorati/bosimi/namligi o‘lchagichlari chizilmagan, lekin prinsip matnida havo harorati yozilishi aytiladi — soddalashtirish maqbulmi.  |
| 152 | `SCHEM-analytical_balance-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 185 | `SCHEM-lab_fridge-drawing-01` | low | NEEDS_EXPERT | Buferli zond va DDL joylashuvi CDC tavsiyasiga mosmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali. |
| 186 | `SCHEM-lab_fridge-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 288 | `SCHEM-analytical_balance-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 289 | `SCHEM-analytical_balance-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 315 | `SCHEM-lab_fridge-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 316 | `SCHEM-lab_fridge-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Kimyo / fotometr analizatorlari (38)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 16 | `SCHEM-chemistry-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 17 | `SCHEM-electrophoresis-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 24 | `SCHEM-blood_gas_ise-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 32 | `SCHEM-hba1c_analyzer-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 39 | `SCHEM-osmometer-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 40 | `SCHEM-photometer-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 41 | `SCHEM-tlc-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 52 | `SCHEM-electrophoresis-part-05` | medium | NEEDS_EXPERT | 5-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 62 | `SCHEM-chemistry-drawing-02` | medium | NEEDS_EXPERT | Zardob/plazma probirkasi tasviri biokimyo uchun maqbulmi (qopqoq rangi da’vo qilinmaydi); raqamsiz disk (STAT/kalibrator?) tushunarlimi. (Ch |
| 63 | `SCHEM-electrophoresis-drawing-01` | medium | NEEDS_EXPERT | Qutblar, fraksiyalar joylashuvi va densitogramma yo‘nalishi (an’anaviy ko‘rinish) chalg‘itmaydimi. (Chizma geometriyasi hech bir manba bilan |
| 67 | `SCHEM-hba1c_analyzer-drawing-01` | medium | NEEDS_EXPERT | Usulni ko‘rsatmaslik (kartada bir nechta usul) va reagent idishlari tasviri chalg‘itmaydimi. (Chizma geometriyasi hech bir manba bilan qopla |
| 158 | `SCHEM-blood_gas_ise-drawing-01` | low | NEEDS_EXPERT | Sensor kassetasi tasviri to‘g‘rimi; shpritsni zondga ulash tasviri amaliyotga mosmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — |
| 159 | `SCHEM-blood_gas_ise-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 165 | `SCHEM-chemistry-drawing-01` | low | NEEDS_EXPERT | Lampa/detektor joylashuvi sinf uchun umumiy tamoyilmi (ko‘p analizatorlarda boshqacha); nur yo‘li to‘g‘ri ko‘rsatilganmi. (Chizma geometriya |
| 166 | `SCHEM-chemistry-drawing-03` | low | NEEDS_EXPERT | Matn va chizma mosligi: ISE moduli ko‘rsatilmasligi muammo emasmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjud |
| 169 | `SCHEM-electrophoresis-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 178 | `SCHEM-hba1c_analyzer-drawing-02` | low | NEEDS_EXPERT | Probirka turi to‘g‘ri. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 179 | `SCHEM-hba1c_analyzer-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 200 | `SCHEM-osmometer-drawing-01` | low | NEEDS_EXPERT | Muzlash egri chizig‘i shakli to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 201 | `SCHEM-osmometer-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 202 | `SCHEM-photometer-drawing-01` | low | NEEDS_EXPERT | Yarim avtomatik fotometr uchun oqim kyuvetasi tasviri umumiy sinfga mosmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qis |
| 203 | `SCHEM-photometer-drawing-02` | low | NEEDS_EXPERT | Displeyda egri chiziq ko‘rsatilishi (kinetik o‘lchov) sinfga xosmi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavju |
| 206 | `SCHEM-tlc-drawing-01` | low | NEEDS_EXPERT | Fluoressensiya so‘nishi tasviri va erituvchi sathi start chizig‘idan pastligi to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmag |
| 207 | `SCHEM-tlc-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 292 | `SCHEM-blood_gas_ise-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 293 | `SCHEM-blood_gas_ise-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 296 | `SCHEM-chemistry-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 297 | `SCHEM-chemistry-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 301 | `SCHEM-electrophoresis-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 302 | `SCHEM-electrophoresis-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 307 | `SCHEM-hba1c_analyzer-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 308 | `SCHEM-hba1c_analyzer-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 323 | `SCHEM-osmometer-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 324 | `SCHEM-osmometer-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 325 | `SCHEM-photometer-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 326 | `SCHEM-photometer-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 327 | `SCHEM-tlc-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 328 | `SCHEM-tlc-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Immunoanaliz va ELISA (9)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 18 | `SCHEM-elisa_reader-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 64 | `SCHEM-elisa_reader-drawing-01` | medium | NEEDS_EXPERT | Darslik tartibi (monoxromatik nur quduqchadan o‘tib detektorga tushadi) to‘g‘ri ko‘rsatilganmi; ayrim o‘quvchilarda filtr quduqchadan keyin  |
| 170 | `SCHEM-elisa_reader-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 183 | `SCHEM-immunoassay-drawing-01` | low | NEEDS_EXPERT | Hemilyuminessensiya detektori tasviri tushunarlimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 184 | `SCHEM-immunoassay-drawing-02` | low | NEEDS_EXPERT | Zardob/plazma probirkasi tasviri immunoanaliz uchun maqbulmi (qopqoq rangi da’vo qilinmaydi). (Chizma geometriyasi hech bir manba bilan qopl |
| 303 | `SCHEM-elisa_reader-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 304 | `SCHEM-elisa_reader-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 313 | `SCHEM-immunoassay-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 314 | `SCHEM-immunoassay-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Massa-spektrometriya (22)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 20 | `SCHEM-mass_spec_gc-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 21 | `SCHEM-mass_spec_lc-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 35 | `SCHEM-maldi_tof-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 36 | `SCHEM-mass_spec_gc-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 37 | `SCHEM-mass_spec_lc-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 57 | `SCHEM-mass_spec_gc-part-06` | medium | NEEDS_EXPERT | 6-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 70 | `SCHEM-mass_spec_lc-drawing-02` | medium | NEEDS_EXPERT | Klinik LC-MS/MS da odatda uchlik kvadrupol — bitta kvadrupol tasviri soddalashtirish sifatida qabul qilinadimi. (Chizma geometriyasi hech bi |
| 187 | `SCHEM-maldi_tof-drawing-01` | low | NEEDS_EXPERT | ‘Yengil ionlar avval yetadi’ tasviri to‘g‘rimi (SCHEMATICS_PROVENANCE.md da tuzatilgan deb qayd etilgan). (Chizma geometriyasi hech bir manb |
| 188 | `SCHEM-maldi_tof-drawing-02` | low | NEEDS_EXPERT | Qo‘shimcha raqamsiz element chalg‘itmaydimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 189 | `SCHEM-maldi_tof-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 190 | `SCHEM-mass_spec_gc-drawing-01` | low | NEEDS_EXPERT | GC-MS (EI) ion optikasi tartibi to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 191 | `SCHEM-mass_spec_gc-drawing-02` | low | NEEDS_EXPERT | Ikki bosqichli vakuum tizimi tasviri to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 192 | `SCHEM-mass_spec_gc-drawing-03` | low | NEEDS_EXPERT | Kolonka va termostat tasviri. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 193 | `SCHEM-mass_spec_gc-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 194 | `SCHEM-mass_spec_lc-drawing-01` | low | NEEDS_EXPERT | Elektropurkash manbai tasviri to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 195 | `SCHEM-mass_spec_lc-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 317 | `SCHEM-maldi_tof-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 318 | `SCHEM-maldi_tof-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 319 | `SCHEM-mass_spec_gc-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 320 | `SCHEM-mass_spec_gc-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 321 | `SCHEM-mass_spec_lc-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 322 | `SCHEM-mass_spec_lc-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Siydik tahlili (9)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 22 | `SCHEM-urine_strip-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 23 | `SCHEM-urine_system-result` | medium | NEEDS_EXPERT | Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi. [qisman manbali (STANDA |
| 42 | `SCHEM-urine_strip-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 208 | `SCHEM-urine_strip-drawing-01` | low | NEEDS_EXPERT | LED soni/rangi va maydonchalar soni umumiy tamoyil sifatida to‘g‘rimi (aniq model raqami emasligi). (Chizma geometriyasi hech bir manba bila |
| 209 | `SCHEM-urine_system-drawing-01` | low | NEEDS_EXPERT | Zarracha tasvirlari morfologik jihatdan to‘g‘ri tanilarlimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi m |
| 329 | `SCHEM-urine_strip-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 330 | `SCHEM-urine_strip-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 331 | `SCHEM-urine_system-l10n-ru` | low | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 332 | `SCHEM-urine_system-l10n-uz` | low | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |

### Molekulyar diagnostika (11)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 25 | `SCHEM-cartridge_molecular-principle` | medium | NEEDS_EXPERT | Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qm |
| 49 | `SCHEM-cartridge_molecular-part-04` | medium | NEEDS_EXPERT | 4-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 60 | `SCHEM-real_time_pcr-part-03` | medium | NEEDS_EXPERT | 3-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi. [qisman manbali (STANDARD_TEXTBOOK qis |
| 118 | `SCHEM-cartridge_molecular-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 119 | `SCHEM-cartridge_molecular-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 132 | `SCHEM-real_time_pcr-l10n-ru` | medium | NEEDS_EXPERT | ru atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va ru tibbiy-laboratoriya atamashunosligiga mos. |
| 133 | `SCHEM-real_time_pcr-l10n-uz` | medium | NEEDS_EXPERT | uz atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va uz tibbiy-laboratoriya atamashunosligiga mos. |
| 161 | `SCHEM-cartridge_molecular-drawing-01` | low | NEEDS_EXPERT | Modul/kartrij tasviri aniq ishlab chiqaruvchi dizayniga o‘xshab qolmaganmi (LAB_CARD_IMAGE_COVERAGE qoidasi). (Chizma geometriyasi hech bir  |
| 162 | `SCHEM-cartridge_molecular-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |
| 204 | `SCHEM-real_time_pcr-drawing-01` | low | NEEDS_EXPERT | Optik yo‘l va Cq chegara chizig‘i tasviri to‘g‘rimi. (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.) |
| 205 | `SCHEM-real_time_pcr-drawing-alt` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi. |

### Fotometriya (18)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 44 | `DIAG-photometry-01` | medium | NEEDS_EXPERT | Optik yo‘l: manba → filtr → kyuveta → detektor; avtomatik analizatorlarda filtr o‘rniga monoxromator/panjara bo‘lishi mumkin (DIAGRAMS_PROVE |
| 90 | `DIAG-photometry-l10n-ru-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 91 | `DIAG-photometry-l10n-ru-f1` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘Absorbance’ → ‘Поглощение (оптическая плотность)’ — |
| 92 | `DIAG-photometry-l10n-ru-f2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘Beer–Lambert’ → ‘Бугера–Ламберта–Бера’ (rus an’anas |
| 93 | `DIAG-photometry-l10n-uz-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 94 | `DIAG-photometry-l10n-uz-f1` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘Absorbance’ → ‘Yutilish (optik zichlik)’ — ilova AR |
| 95 | `DIAG-photometry-l10n-uz-f2` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. ‘Beer–Lambert’ → ‘Buger–Lambert–Ber’. |
| 250 | `DIAG-photometry-alt-en` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-photometry-NN qator |
| 251 | `DIAG-photometry-alt-ru` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-photometry-NN qator |
| 252 | `DIAG-photometry-alt-uz` | low | NEEDS_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-photometry-NN qator |
| 253 | `DIAG-photometry-l10n-ru-bench` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 254 | `DIAG-photometry-l10n-ru-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 255 | `DIAG-photometry-l10n-ru-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 256 | `DIAG-photometry-l10n-ru-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 257 | `DIAG-photometry-l10n-uz-bench` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 258 | `DIAG-photometry-l10n-uz-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 259 | `DIAG-photometry-l10n-uz-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 260 | `DIAG-photometry-l10n-uz-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |

### O‘quv natijalari oqimi (24)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 88 | `DIAG-educational_feedback-l10n-ru-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 89 | `DIAG-educational_feedback-l10n-uz-d` | medium | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 134 | `DIAG-educational_feedback-01` | low | APP_RULE_AWAITING_EXPERT | Ilova xatti-harakati (ilmiy da’vo emas): savollar → ball. [Holat: hujjatdagi holat ‘APP_UI’ → ehtiyotkor talqin APP_RULE_AWAITING_EXPERT; AP |
| 135 | `DIAG-educational_feedback-02` | low | APP_RULE_AWAITING_EXPERT | Ilova xatti-harakati: xato bo‘lmasa — qayta yoki boshqa mavzu. [Holat: hujjatdagi holat ‘APP_UI’ → ehtiyotkor talqin APP_RULE_AWAITING_EXPER |
| 136 | `DIAG-educational_feedback-03` | low | APP_RULE_AWAITING_EXPERT | Ilova xatti-harakati: xatolar tahlili (to‘g‘ri javob va izoh). [Holat: hujjatdagi holat ‘APP_UI’ → ehtiyotkor talqin APP_RULE_AWAITING_EXPER |
| 137 | `DIAG-educational_feedback-04` | low | APP_RULE_AWAITING_EXPERT | Ilova xatti-harakati: faqat xato savollarni qayta ishlash (halqa). [Holat: hujjatdagi holat ‘APP_UI’ → ehtiyotkor talqin APP_RULE_AWAITING_E |
| 138 | `DIAG-educational_feedback-05` | low | APP_RULE_AWAITING_EXPERT | Izoh: ‘LabGuide mashqi tartibi — laboratoriya jarayoni emas’. [Holat: hujjatdagi holat ‘APP_UI’ → ehtiyotkor talqin APP_RULE_AWAITING_EXPERT |
| 142 | `DIAG-educational_feedback-alt-en` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-educational_feedbac |
| 143 | `DIAG-educational_feedback-alt-ru` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-educational_feedbac |
| 144 | `DIAG-educational_feedback-alt-uz` | low | APP_RULE_AWAITING_EXPERT | Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; sxemadagi da’volar yuqoridagi DIAG-educational_feedbac |
| 236 | `DIAG-educational_feedback-l10n-ru-done` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 237 | `DIAG-educational_feedback-l10n-ru-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 238 | `DIAG-educational_feedback-l10n-ru-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 239 | `DIAG-educational_feedback-l10n-ru-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 240 | `DIAG-educational_feedback-l10n-ru-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 241 | `DIAG-educational_feedback-l10n-ru-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 242 | `DIAG-educational_feedback-l10n-ru-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 243 | `DIAG-educational_feedback-l10n-uz-done` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 244 | `DIAG-educational_feedback-l10n-uz-footer` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 245 | `DIAG-educational_feedback-l10n-uz-s1` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 246 | `DIAG-educational_feedback-l10n-uz-s2` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 247 | `DIAG-educational_feedback-l10n-uz-s3` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 248 | `DIAG-educational_feedback-l10n-uz-s4` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |
| 249 | `DIAG-educational_feedback-l10n-uz-title` | low | NEEDS_EXPERT | Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. |

### Diagrammalar (boshqa) (3)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 222 | `DIAG-common-caption` | low | NEEDS_EXPERT | Sxema ostidagi izoh: ‘umumiy sxema — IFU va laboratoriya SOP’i ustun’ uch tilda bir xil ma’noda. |
| 223 | `DIAG-common-l10n-ru-yesno` | low | NEEDS_EXPERT | Qaror tarmoqlari yorliqlari (Ha/Yo‘q) shu tilda to‘g‘ri. |
| 224 | `DIAG-common-l10n-uz-yesno` | low | NEEDS_EXPERT | Qaror tarmoqlari yorliqlari (Ha/Yo‘q) shu tilda to‘g‘ri. |

### Umumiy matnlar (sxemalar) (3)

| # | item_id | Xavf | Holat | Nima tekshiriladi |
|---|---|---|---|---|
| 298 | `SCHEM-common-instSchematicCaption` | low | NEEDS_EXPERT | Sxematik chizma haqidagi umumiy izoh (aniq model emas / tamoyil darajasi) uch tilda bir xil ma’noda va to‘g‘ri. |
| 299 | `SCHEM-common-instSchematicNotPhoto` | low | NEEDS_EXPERT | Sxematik chizma haqidagi umumiy izoh (aniq model emas / tamoyil darajasi) uch tilda bir xil ma’noda va to‘g‘ri. |
| 300 | `SCHEM-common-schemPartsClassNote` | low | NEEDS_EXPERT | Sxematik chizma haqidagi umumiy izoh (aniq model emas / tamoyil darajasi) uch tilda bir xil ma’noda va to‘g‘ri. |

## 3. Manbasi aniq faktlar (hujjatlashtirilgan, tasdiqlanmagan)

154 band katalog/ilova manbasiga bog‘langan (`docs/SCIENTIFIC_REVIEW_SOURCED.csv`: har qatorda manba identifikatori). **SOURCED = manba bor; bu mutaxassis tasdig‘i degani emas.** Manba bilan bog‘liq ilovadagi qisqa iqtiboslar asl manba bilan solishtirilishi kerak.

| Mavzu | SOURCED qatorlar |
|---|---|
| Gematologiya va gemostaz | 35 |
| Kimyo / fotometr analizatorlari | 27 |
| Immunoanaliz va ELISA | 11 |
| Massa-spektrometriya | 10 |
| Mikrobiologiya | 10 |
| Biologik xavfsizlik va sterilizatsiya | 9 |
| Asosiy jihozlar | 8 |
| Sifat nazorati (QC) | 8 |
| Siydik tahlili | 7 |
| Molekulyar diagnostika | 6 |
| Preanalitika | 6 |
| Kalibrlash | 5 |
| Leykoformula | 5 |
| Fotometriya | 4 |
| Mikroskopiya | 3 |
