# Sxemalar mazmuni — har bir da’vo manbasi (2026-10-25)

Fayllar: `assets/diagrams/<mavzu>.<til>.png` (6 mavzu × uz/ru/en), manba SVG — `tool/diagrams/svg/`,
generator — `tool/diagrams/gen_diagrams.py` (matnlar `T` lug‘atida; izohdagi ID lar shu jadvalga mos).
Kelib chiqishi va sha256: `docs/DIAGRAMS_PROVENANCE.md`.

Qoida: sxemada faqat **jarayon darajasidagi** gap bor va har biri ilovada **allaqachon** iqtibos
qilingan manbaga yoki ilovaning o‘z matniga tayanadi. Yangi raqam, chegara yoki qoida qo‘shilmagan.
Holat ustuni:

- `SOURCED` — ilovadagi aniq joy va undagi manba (pastdagi fayl/qator yoki ARB kaliti).
- `APP_UI` — ilovaning o‘z ishlash tartibi (ilmiy da’vo emas).
- `STANDARD_TEXTBOOK` — umumiy darslik qoidasi; repo’da alohida bet-iqtibos yo‘q.
- `NEEDS_EXPERT` — mutaxassis ko‘rigi kerak (manba to‘liq qamramaydi yoki ilovadagi qoida hali
  `docs/EXPERT_SIGNOFF_REGISTRY.md` da AWAITING_EXPERT).

Har sxema pastida “IFU / laboratoriya SOP’i ustun” mazmunidagi eslatma bor (eskilarida ham bor edi);
ilovadagi `imgDiagramCaption` ham buni takrorlaydi.

## qc_decision — QC seriyasi: qabul yoki rad (QcScreen)

| ID | Sxemadagi gap (en) | Manba (repo) | Holat |
|---|---|---|---|
| QC-1 | Measure the control materials | `lib/features/qc/qc_guides_info.dart:45` (QcGuide.rejected, WHO LQMS 2011 §7-6); ARB `qcIntro` | SOURCED |
| QC-2 | Levey–Jennings chart, target mean ± SD | ARB `qcChartTitle`, `qcIntro`, `qcTargetNote` (Westgard JO et al., Clin Chem 1981; doi:10.1093/clinchem/27.3.493) | SOURCED |
| QC-3 | Rejection rule violated? 1-3s, 2-2s, R-4s, 4-1s, 10x | `lib/features/qc/qc_rules.dart:1-31` (Westgard 1981; `docs/DECISIONS.md` D-20) | SOURCED |
| QC-4 | No → accept the run; 1-2s alone is a warning only | `qc_rules.dart:30` (“1-2s — ogohlantirish”), `qc_rules.dart:275`; ARB `qcAccept`, `qcWarning`; ilova qarori D-20 | NEEDS_EXPERT |
| QC-5 | Yes → reject: stop, do not report (patient) results | `qc_guides_info.dart:76` (WHO LQMS 2011 §7-6) | SOURCED |
| QC-6 | Find the cause; do not just repeat QC | `qc_guides_info.dart:100` | SOURCED |
| QC-7 | Fix it; recheck QC and patient samples | `qc_guides_info.dart:109`, `:119` | SOURCED |
| QC-8 | Report once in control; record the actions | `qc_guides_info.dart:130`, `:141` | SOURCED |
| QC-9 | Footer: Westgard 1981 · WHO LQMS 2011 · lab SOP prevails | `qc_guides_info.dart` notice (“laboratory’s written remedial-action procedure (SOP) … take precedence”) | SOURCED |

NEEDS_EXPERT: QC-4 — ilova 1-2s ni har seriyada “ogohlantirish” deb ko‘rsatadi va barcha rad
qoidalarini tekshiradi (D-20; 1981 dagi “1-2s eshik” tartibidan qattiqroq). Sxema shu ilova xatti-harakatini
aks ettiradi; klinik-kimyo mutaxassisi tasdiqlashi kerak.

## calibration_overview — Kalibrlash tartibi (CalibrationScreen)

| ID | Sxemadagi gap (en) | Manba (repo) | Holat |
|---|---|---|---|
| CAL-1 | Model, reagent and instruction revision | ARB `calStep1` (ilovaning kalibrlash qadamlari) | SOURCED |
| CAL-2 | Calibrator lot; values from this lot’s value sheet | ARB `calStep2`, `calValuesFromSheet`, `calGuide3` | SOURCED |
| CAL-3 | Method-specific preparation | ARB `calStep3` | SOURCED |
| CAL-4 | Calibration according to the instructions | ARB `calStep4` | SOURCED |
| CAL-5 | Post-calibration QC passed? | ARB `calStep5`, `calGuide5`; qabul sharti — registry `CALIB-ACCEPTANCE-RULES` | NEEDS_EXPERT |
| CAL-6 | Yes → accepted by an authorized person | ARB `calSafeQcPassRequired`, `calSafeApproverRequired` | NEEDS_EXPERT |
| CAL-7 | No → not accepted; troubleshoot per IFU and SOP | ARB `calStep6` (“Records and troubleshooting”), `calGuide4` (recalibration triggers in the IFU) | NEEDS_EXPERT |
| CAL-8 | Footer: parameters only from the matching IFU · lab SOP prevails | ARB `calNoMatchBody` | SOURCED |

NEEDS_EXPERT: CAL-5/CAL-6/CAL-7 — “qabul” sharti ilova qoidasi (registry `CALIB-ACCEPTANCE-RULES`,
AWAITING_EXPERT), ishlab chiqaruvchi chegarasi emas. Laboratoriya sifat menejeri / metrolog ko‘rsin.

## differential_count — Leykoformulani qo‘lda sanash (DifferentialScreen)

| ID | Sxemadagi gap (en) | Manba (repo) | Holat |
|---|---|---|---|
| DIF-1 | Check the film: even, no lines or holes | `lib/features/differential/differential_content.dart:1264-1284` (WHO 2003 §9.10.3, `whoFilm`) | SOURCED |
| DIF-2 | If poor, make a new one | o‘sha joy: “A badly spread film gives a wrong differential” (WHO 2003) — “yangisini tayyorlash” shundan kelib chiqadigan amal | STANDARD_TEXTBOOK / NEEDS_EXPERT |
| DIF-3 | Count in the monolayer, ×100 oil; one way, no repeated fields | `differential_content.dart:1340-1350` (WHO 2003 §9.10.4; Gulati 2013) | SOURCED |
| DIF-4 | Count to the SOP target; usually 100 cells | `differential_content.dart:1355` (WHO 2003 §9.13; Lyubina 1984 — 200) | SOURCED |
| DIF-5 | % of each cell type; absolute = fraction × WBC | `differential_content.dart:1360`; ARB `diffAbsNote` | SOURCED |
| DIF-6 | Blasts or unidentified cells? → do not interpret yourself; a hematologist or physician reviews the smear | ARB `diffReferBody`, `diffOtherWarning` | NEEDS_EXPERT |
| DIF-7 | No → compare with the reference interval on your lab’s report form | ARB `diffInterpretIntro`, `diffRangesBody` | SOURCED |
| DIF-8 | Footer: WHO 2003 · your lab SOP prevails | ARB `diffRangesWho` (ilovadagi qisqa iqtibos: “WHO 2003” / “ВОЗ 2003” / “JSST 2003”); to‘liq nom `lib/features/differential/differential_sources.dart` (`DiffSources.who2003`: WHO. Manual of basic techniques for a health laboratory, 2nd ed., 2003) | NEEDS_EXPERT |

NEEDS_EXPERT: DIF-2 (yangi surtma — amaliy xulosa), DIF-6 (registry `DIFF-REFER-BODY-WORDING`,
AWAITING_EXPERT). DIF-8: pastki iqtibos ilovaning o‘z qisqa shakli (`diffRangesWho`); bibliografik tafsilot
qo‘shilmagan. uz atama: “referens interval” (docs/L10N_TERMINOLOGY_DECISIONS.md, NEEDS_NATIVE_REVIEW);
ru “референтный интервал”, en “reference interval” — 6 sxemadan faqat shu yerda uchraydi. ICSH iqtibosi ishlatilmadi — ilovaning leykoformula ekranlarida ICSH keltirilmagan.

## photometry — Absorbsion fotometriya (fotometrik / biokimyo apparat kartasi)

Asosiy manba — ilovadagi ma’ruza `assets/lectures/decks/fotometriya-asoslari-biokimyo.{uz,ru,en}.json`
(Aripov A.N. va b., 2006, I bob “Fotometriyaning asosiy tushunchalari”, “1.3 Glyukoza”).

| ID | Sxemadagi gap (en) | Manba (repo) | Holat |
|---|---|---|---|
| PHO-1 | Light source → filter (λ) → cuvette → detector → result | deck, “Principle” 1/2: source → slit → filter → cuvette → photodetector → microprocessor; filtr o‘rniga monoxromator bo‘lishi mumkin (DIAGRAMS_PROVENANCE.md NEEDS_EXPERT 4) | NEEDS_EXPERT |
| PHO-2 | Absorbance A = log₁₀(I₀ / I) | deck “About absorbance” (A = 1 → 10 % o‘tadi — shu ta’rifga mos); ta’rifning o‘zi | STANDARD_TEXTBOOK |
| PHO-3 | Beer–Lambert law A = ε · ℓ · c (ℓ — kyuvetadagi optik yo‘l) | umumiy optika qonuni; deck: optik yo‘l 1 sm | STANDARD_TEXTBOOK |
| PHO-4 | Measure blank → standard → sample | deck “Manual determination” 2 va 4 | SOURCED |
| PHO-5 | C = (A sample ÷ A standard) × C standard | deck “Manual determination” 5 | SOURCED |
| PHO-6 | Above the linearity limit? → dilute, repeat, multiply by the dilution factor | deck “Manual determination” 6; “About absorbance” 2/2 | SOURCED |
| PHO-7 | Footer: wavelength, blank and limits per the reagent IFU | deck 4 (“as in the instructions”) | SOURCED |

NEEDS_EXPERT: PHO-1 — avtomatik analizatorlarda filtr o‘rniga monoxromator/panjara bo‘lishi mumkin
(sxema umumiy tamoyil). Atamalar: en “absorbance” uchun ilova ARB’ida ru “поглощение”, uz “yutilish”
(`schemParts*`), ma’ruzada ru “оптическая плотность”, uz “optik zichlik”; sxema ilovaning o‘z iborasini oladi —
ru “Поглощение (оптическая плотность)”, uz “Yutilish (optik zichlik)” (`schemPartsElisaReaderPrinciple` dagi kabi).
Atama qarori (IUPAC: absorbance ≠ optical density) mutaxassisniki — o‘zimiz “tuzatmadik”. Qonun nomi: uz
“Buger–Lambert–Ber qonuni”, ru “закон Бугера–Ламберта–Бера” (ma’ruza atamasi).

## preanalytics — Preanalitik bosqich (PreanalyticsScreen)

| ID | Sxemadagi gap (en) | Manba (repo) | Holat |
|---|---|---|---|
| PRE-1 | 1 Prepare for testing — patient preparation | ARB `preStep1`, `prePatientTitle`; `lib/features/lab/preanalytics_info.dart:936` (`patientPrep`, WHO 2010, MedlinePlus) | SOURCED |
| PRE-2 | 2 Select specimen and additive — tube for the test, order of draw | ARB `preStep2`, `preOrderSub` (WHO 2010, Table 2.3); `preanalytics_info.dart:414` (`tubeForTest`) | SOURCED |
| PRE-3 | 3 Collect and identify — full name matches the request form | ARB `preStep3`; `preanalytics_info.dart:288` (`identificationRules`, ekran manbasi WHO 2010) | SOURCED |
| PRE-4 | 4 Separate and store — within sample stability | ARB `preStep4`, `preStabilitySub` (WHO/DIL/LAB/99.1); `preanalytics_info.dart:797` | SOURCED |
| PRE-5 | 5 Transport and receive — recheck labels and forms | ARB `preStep5`; `identificationRules` (“Recheck tube labels and forms before dispatch”) | SOURCED |
| PRE-6 | Specimen acceptable? Yes → analysis; No → lab SOP | yaroqlilik mezonlari ilovada sanalmagan (faqat gemoliz sabablari, to‘ldirish nisbati); qaror laboratoriya SOP’iga topshirilgan | NEEDS_EXPERT |
| PRE-7 | Footer: WHO phlebotomy guidelines 2010 · lab SOP prevails | ARB `preNotice` | SOURCED |

## educational_feedback — Test natijasidan o‘rganish (_QuizResult)

| ID | Sxemadagi gap (en) | Manba (repo) | Holat |
|---|---|---|---|
| EDU-1 | Answer the questions → see your score | `lib/features/learn/learn_screens.dart:734` (`_QuizResult`), ARB `quizScore` | APP_UI |
| EDU-2 | Any mistakes? No → try again or another topic | `learn_screens.dart:766-777`, ARB `quizRestart`, `quizOtherTopic` | APP_UI |
| EDU-3 | Yes → review your mistakes: correct answer and explanation | `learn_screens.dart:801`, ARB `quizMistakes`, `quizCorrectAnswer` | APP_UI |
| EDU-4 | Practice mistakes — only the questions you missed (loop) | `learn_screens.dart:382`, `:769` (`onRetryMistakes`), ARB `examReworkMistakes` | APP_UI |
| EDU-5 | Footer: how LabGuide practice works — not a lab procedure | — | APP_UI |

## Til (uz/ru/en)

Tuzatildi (2026-10-25, ilmiy ko‘rik jadvali `docs/SCIENTIFIC_REVIEW_TABLE.md` topilmalari asosida):
differential 2-qadam ru/uz — “иммерсия ×100” / “×100 immersiya” (en “×100 oil” bilan teng); QC rad bloki ru/uz —
“остановить” / “to‘xtating” qaytarildi (ilova `qc_guides_info.dart:76` dagi kabi); uz QC 4-qadam — “bemor
namunalarini”; uz “Referens oraliq” → “Referens interval”; differential pastki iqtibosi — ilovaning
`diffRangesWho` shakli. Holatlar ko‘tarilmadi — QC-4, CAL-5, PHO-1 ehtiyotkor `NEEDS_EXPERT` ga tushirildi.

Matnlar ilova ARB atamalariga moslandi (`calStep*`, `preStep*`, `quiz*`, `qc*`, `diff*`). Uzbek: o‘ g‘ —
U+2018, tutuq ’ — U+2019 (`tool/l10n/normalize_uz_apostrophes.py --check` toza). Tibbiy tilshunos ko‘rigi
kerak (umumiy NEEDS_EXPERT): ru/uz qisqartirilgan sxema iboralari (masalan, “Выдача — после
восстановления КК”, “QC tiklangach natija bering”).
