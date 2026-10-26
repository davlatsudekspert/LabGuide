# Laboratory calculators — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved.

**What is on screen.** Everything after the hook is **real app frames**. They come from the free app `/home/user/wt-audit` (commit `215d3e8`) and were filmed by `video_studio/flutter_walk/calculators_walk_test.dart`. **Illustrative inputs** (not a patient) were typed into the app's own forms, and the app computed every result on screen.

**The hook** shows the app's own eGFR formula text: `lib/features/tools/calc_info.dart`, `ClinicalCalc.egfr` (EN/RU/UZ strings copied into `lines.*.json → ui.formula / ui.kappa`). It ends in "= ?". The video computes no result. **No price/tier statement.** All calculators are in the free app build.

## 1. Claims → evidence

| # | Where | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| K1 | hook · L01, input pills, formula card | Creatinine 88, age 45, male: what is the eGFR? The formula as the app shows it (CKD-EPI 2021) | Formula and κ/α text = `calc_info.dart` (the app cites Inker 2021 NEJM Table 2; NKF CKD-EPI 2021). Inputs are illustrative. | app text + illustrative |
| K2 | hook · L02, pill "Scr in mg/dL: µmol/L ÷ 88.4" | By hand it is a long formula, and one unit slip changes the answer | The app's formula note: "Scr in mg/dL. µmol/L values are converted with the creatinine molar mass (113.12 g/mol) (≈ ÷ 88.4)". "One unit slip changes the answer" is a general statement about a unit-dependent formula, not a measured error rate. | app text + STANDARD_TEXTBOOK |
| K3 | app_list · L03, `l_lab` | In LabGuide: Lab → Calculators | `lib/features/lab/lab_screens.dart` row `featureCalculators` → `/lab/calculators`; real frame | code + real screen |
| K4 | app_list · L04, `c_list`, `c_list2` | Seventeen: clinical formulas, manual methods and laboratory tools | `CalculatorsScreen`: 7 `ClinicalCalc` + 8 `ManualCalc` + dilution + units = 17 rows (the plan `docs/video/04_kalkulyatorlar.md` also says 17). **Note:** one manual row, "Color index", explains why the app recommends MCH/MCHC instead of calculating. The count is of rows in the list. | code + real screen |
| K5 | app_howto · L05, `c_howto` | "How to use?" shows the steps in the app | `howToButton` sheet with `howToCalculatorsStep1–4`; real frame | code + real screen |
| K6 | app_egfr · L06, `e_empty` | The fields start empty: every value is yours | App test `clinical_calc_test.dart` ("dilution: no prefilled values, calculates only from input"); the eGFR form is empty in the real frame | test + real screen |
| K7 | app_egfr · L07, `e_sex` | Forget the sex, and it asks before it calculates | `errSexMissing` "Choose sex."; app test "eGFR: SI input, sex required, children refused" | test + real screen |
| K8 | app_egfr · L08, `e_result` | The result shows its KDIGO category and the values you entered | Filmed result: 95 mL/min/1.73 m², "KDIGO GFR category G1", "Entered: Serum creatinine 88 µmol/L · Age, years 45". The arithmetic is repeated in `MATH_APPENDIX.md` (JS = Python = 95.1). | real screen + check |
| K9 | app_refs · L09, `e_formula` | Below it: the formula, its limitations and the sources | `ClinicalCalcScreen`: `calcFormula`, `calcLimitations`, `calcSources` sections; app test "every calculator shows formula, limitations and sources". The source list itself is kept out of the bright crop window. | test + real screen |
| K10 | app_checks · L10, `e_child` | Under 18, eGFR is refused: the equation was built on adults | `errEgfrAge` (app): "developed in participants aged 18 or older; it is not calculated for children"; app test | test + real screen |
| K11 | app_checks · L11, `o_unit` | Glucose 90 in mmol/L gets a unit check | `calcUnitCheck`; app test "osmolality: glucose 90 'mmol/L' gets a unit check"; real frame. The calculated value still shows on that screen; the video does not discuss it. | test + real screen |
| K12 | app_units · L12, `p_units` | SI or conventional units, chosen once, in Profile | `profile_screens.dart` `profileUnits` (SI / Conventional); app tests "untouched calculator follows the switch" | test + real screen |
| K13 | app_bench · L13, `d_result` | Bench tools too: dilution, C1·V1 = C2·V2, from your own numbers | `DilutionScreen` (`calcDilutionSub` "C₁V₁ = C₂V₂"); filmed V₁ = 20 mL from C₁ 10, C₂ 2, V₂ 100 (illustrative); app test "dilution … 20" | test + real screen |
| K14 | end · L14 + note | It calculates — you interpret. A learning and checking aid; it does not diagnose | `calcNotDiagnosis`: "A calculation aid for learning and checking. It does not diagnose: interpret the result with the clinical picture and your laboratory's reference intervals." | app text |
| K15 | audio | English synthetic narration (Kokoro-82M `af_heart`); RU/UZ are subtitles. **Nobody has listened to it.** | owner decision | disclosure |

## 2. Epistemic table

| ID | Statement | Tag |
|---|---|---|
| E1 | Every result/verdict on screen | computed by the app (real frames) |
| E2 | eGFR formula, limitations, KDIGO category | app text with the app's cited sources (Inker 2021; NKF; KDIGO 2012/2024) — expert review of the app content is separate |
| E3 | Inputs (creatinine 88 µmol/L, 45, male; age 12; glucose 90 mmol/L; dilution 10/2/100) | illustrative |
| E4 | "Seventeen" | count of list rows (see K4 note) |

**Deliberately not said:**
* no claim that the result is "normal";
* no clinical interpretation of G1;
* no drug dosing;
* no claim that the app is validated or certified.

**Native review.** RU «рСКФ», «толкуете»; UZ «talqin», «an’anaviy birliklar» are NEEDS_NATIVE_REVIEW.
