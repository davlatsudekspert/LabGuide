# Osmometry — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved.

**Apparatus art.** The app's ORIGINAL schematic `tool/illustrations/schematic/osmometer.svg` (LabGuide's own work, the same drawing as in the app card). Part names come from the app (ARB `schemPartsOsmometer*Name`, EN/RU/UZ).

**Freezing curves.** Illustrative (`MATH_APPENDIX.md`): arbitrary temperature units, no numbers on the axes (lesson 24: "raqamsiz"). No cryoscopic constant, reference interval or sample volume is stated.

**Real app frames.** From the free app `/home/user/wt-audit` (commit `215d3e8`), filmed by `video_studio/flutter_walk/osmometry_walk_test.dart` (+ `labcard_kit.dart`):
* Lab → Instruments and methods → Clinical biochemistry → "Osmometer (urine / serum osmolality)" card. Card id `a3-bio-osmometer`, single source `a3-statpearls-osmometer` (NCBI Bookshelf). The source lines are kept outside the bright crop window.
* Lab → Calculators → Calculated osmolality (`/lab/calculators/osmolality`). **Illustrative inputs** typed into the app's own form: Na 140, glucose 5, urea 5 mmol/L, measured 300 mOsm/kg. The app computed 290 mOsm/kg and an osmolal gap of 10 mOsm/kg on the filmed screen.

**No price/tier statement.** The card and the calculator are in the free app build.

**Update 2026-10-27 (wording fix).** In the UZ edition the calculators list frame `c_list` (row «Siydik ACR · KDIGO A …») was filmed again from the shipping-wording app (commit `d962a5c`; branch name in WORDING_FIX_2026-10-27.md): the old frame used the banned UZ word (t-word), the new one says «kategoriyasi». Every other frame is unchanged. See `docs/video/WORDING_FIX_2026-10-27.md`.

## 1. Claims → evidence

| # | Where | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| O1 | hook · L01, curves A/B, "pure water" line | Two samples freeze; one plateau sits lower | illustrative (`MATH_APPENDIX.md` §1–2) | illustrative |
| O2 | hook · L02 | Dissolved particles lower the freezing point; that is what an osmometer measures | Schematic principle (`schemPartsOsmometerPrinciple`, app): "Dissolved particles lower the freezing point … Osmolality is calculated from the measured depression"; lesson 24 L2 (SOURCED `a3-statpearls-osmometer`) | SOURCED |
| O3 | tour · L03, parts 1–5 | Freezing-point osmometer: sample tubes, thermistor probe, cooling block, stirring wire, display | Lesson 24 C1–C5: C2 and C3 are SOURCED (`a3-statpearls-osmometer`); C1, C4 and C5 are STANDARD_TEXTBOOK. Names = app ARB. Freezing point as the main clinical method: lesson L1 (SOURCED) | SOURCED (C2, C3) / STANDARD_TEXTBOOK |
| O4 | freeze · L04, ring 1 "supercooled" | The cooling block supercools the sample below its freezing point | Part C3 text (SOURCED): "Cools the sample below its freezing point"; principle PR (NEEDS_EXPERT as a whole in lesson 24) | SOURCED + STANDARD_TEXTBOOK |
| O5 | freeze · L05, ring 2 | The stirring wire vibrates and freezing starts | Part C4 (STANDARD_TEXTBOOK): "Vibrates to start freezing in the supercooled sample" | STANDARD_TEXTBOOK |
| O6 | freeze · L06, plateau line | Released heat lifts the temperature to a plateau, the freezing point | Principle PR (lesson 24: NEEDS_EXPERT): "Released latent heat raises the temperature to the freezing point, giving a plateau"; tour L03 names the thermistor (C2, SOURCED: "measures temperature precisely") | NEEDS_EXPERT (wording at principle level only) |
| O7 | result · L07, ΔT arrows, pill | More particles → deeper depression → osmolality | Lesson L2 (SOURCED): "dissolved particles lower the freezing point; from the depression osmolality is determined". No proportionality constant shown. | SOURCED |
| O8 | result · L08, two unit cards | Osmolality per kg water (mOsm/kg); osmolarity per litre of solution | Schematic `result` (RS, SOURCED): "Urine or serum osmolality in mOsm/kg: particles per kilogram of water (osmolarity, by contrast, is per litre of solution, mOsm/L)" | SOURCED |
| O9 | app_card · L09, `o_dir`, `o_card` | Lab → Instruments and methods → Clinical biochemistry → Osmometer | Routes `/lab/instruments/d/biochemistry`, `/lab/instruments/lc/a3-bio-osmometer`; ARB `labInstruments`, `labDirBiochemistry`; real frames | code + real screen |
| O10 | app_card · L10, `o_parts`, `o_specimens` | The same schematic and parts, plus specimens, each with its source | Card schematic + parts panel; card `specimens` ("Serum, heparinised plasma, tears, sweat and urine; centrifuge to remove particles …") with its source line (dimmed) | SOURCED + real screen |
| O11 | app_limits · L11, `o_limits` | Particles, air bubbles, evaporated or viscous samples, and high alcohol or acetone distort the reading | Card `limitations` (SOURCED; filmed): "Freezing-point osmometers are disturbed by particles, air bubbles, evaporated or viscous samples and high ethanol, methanol or acetone …". "alcohol" = the card's ethanol and methanol. | SOURCED |
| O12 | app_limits · L12, `o_errors` | An uncleaned container carries the last sample into the next | Card `preanalytic_analytic_errors` (SOURCED; filmed): "Failure to clean the sample container lets the previous sample skew the next reading …" | SOURCED |
| O13 | app_calc · L13, `c_list`, `c_form` | Lab → Calculators → Calculated osmolality: from sodium, glucose and urea | Route `/lab/calculators/osmolality`; `calculatedOsmolality()` in `lib/features/tools/clinical_calculators.dart` (mmol/L: 2·Na + glucose + urea; source cited in the app: Lynd 2008 Table 1; mg/dL variant Rasouli 2016); app test `test/widget/clinical_calc_test.dart` | code + real screen |
| O14 | app_calc · L14, `c_result` | Add the measured value and it shows the osmolal gap | Same function: `gap = measured − calculated`; filmed result 290 mOsm/kg, gap 10 mOsm/kg from the illustrative inputs (`MATH_APPENDIX.md` §3 repeats the arithmetic) | code + real screen |
| O15 | end · L15 + note | Measured or calculated — know which number you read; your laboratory's SOP and reference intervals decide | App texts `calcNotDiagnosis` ("does not diagnose: interpret … with your laboratory's reference intervals") and `labDirDisclaimer` | app text |
| O16 | audio | English synthetic narration (Kokoro-82M `af_heart`); RU/UZ are subtitles. **Nobody has listened to it.** | owner decision | disclosure |

## 2. Epistemic table

| ID | Statement | Tag |
|---|---|---|
| E1 | Freezing-point depression is the main clinical method; thermistor probe; cooling block | SOURCED (`a3-statpearls-osmometer`) |
| E2 | Sequence supercooling → stirring wire starts freezing → latent heat → plateau | STANDARD_TEXTBOOK / NEEDS_EXPERT (principle wording, lesson 24 PR) |
| E3 | Particles lower the freezing point → osmolality; mOsm/kg vs mOsm/L | SOURCED |
| E4 | Interferences, carry-over | SOURCED |
| E5 | Calculated osmolality formula and gap | app code + its cited sources (Lynd 2008; Rasouli 2016) |
| E6 | Curve shapes, plateau heights; calculator inputs | illustrative |

**Deliberately not said:**
* the 1.86 °C per osmol/kg constant (lesson 24 F5, expert pending);
* reference intervals;
* any meaning of a "normal" or "abnormal" gap;
* sample volume;
* vapour-pressure / membrane osmometers, beyond the card's own limitation text, which is visible but not narrated.

**Direction list frame (`o_dir`).** Its first visible line, "test", is the wrapped tail of the row "Glycated haemoglobin (HbA1c) test", scrolled under the header. It is not a card called "test". The video dims everything outside the osmometer row (`crop: card`).

**Wording to review.** RU «криоскопический осмометр», «переохлаждение», «осмоляльный зазор» and UZ «o‘ta sovish», «osmolyal farq» follow the app's ARB and catalog; all are NEEDS_NATIVE_REVIEW.
