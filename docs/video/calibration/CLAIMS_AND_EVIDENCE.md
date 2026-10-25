# Calibration (flagship) — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved; the science and
the RU/UZ wording have not been reviewed by a laboratory specialist or a native-speaker reviewer.

Code references are to branch `video/studio` (HEAD at the time of writing) unless stated; the real app frames
were rendered from the read-only Flutter checkout `/home/user/wt-audit` (branch `fix/images-apparatus`,
commit `215d3e8`) with `video_studio/flutter_walk/calibration_walk_test.dart`. The calibration record,
acceptance rule and history code is identical on both (`git diff 215d3e8 HEAD` of
`calibration_screens.dart` only adds the D-76 `Feature.calibration` gate — default "not locked" — around the
same buttons). **The video makes no statement about price, tiers or availability**; before publishing, the
owner must confirm how the calibration feature is offered in the build being advertised.

## 1. Claims → evidence

| # | Where (scene · line / on-screen) | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| C1 | hook · L01, big number | "Absorbance 0.486" | `storyboard.json → data.controls[QC-H].abs`; badge "Illustrative data — not a patient result" on screen | illustrative data |
| C2 | hook · L02, "No calibration — no answer." | An absorbance alone does not give a concentration | Textbook: conversion needs a calibration (standard/calibrator or factor). See E2 | STANDARD_TEXTBOOK → wording NEEDS_EXPERT |
| C3 | analyzer · L03, callouts 4/5 | Light passes through the reaction cuvette; the photometer measures absorbance | `schematic_parts` `chemistry` #4/#5 = CH-C4/CH-C5 (SOURCED: `mr-bs480-br`, `ro-c303`), table in `docs/video/lessons/07_chemistry_photometer.md` §8.1; part names from ARB `schemPartsChemistryReactionName`, `…PhotometerName` | SOURCED |
| C4 | analyzer · L04, chip "Concentration: from the calibration", callout 8 | Concentration is calculated from a calibration; computer and software manage calibration | CH-PR (SOURCED: `mr-bs480-br`, `ro-c311`, `ab-c4000`); CH-C8 "manages calibration, calculates results" (STANDARD_TEXTBOOK); ARB `schemPartsChemistryComputerName` | SOURCED + STANDARD_TEXTBOOK |
| C5 | analyzer, badge | "Schematic — not an exact model" | Art = `tool/illustrations/schematic/chemistry.svg`, LabGuide's own original work (`docs/SCHEMATICS_PROVENANCE.md`); wording follows ARB `instSchematicCaption` | provenance |
| C6 | lightpath · L05, A = −log₁₀(I/I₀), I₀/I bars | More light absorbed → less reaches the detector → higher absorbance | Definition of absorbance (Beer–Lambert, lesson 07 statement T1); bars drawn with T = 10^−A in code (`OpticalBench.tsx`) so picture and readout agree | STANDARD_TEXTBOOK |
| C7 | lightpath, labels | Lamp → filter → cuvette → detector | PH-C3 "Lamp → interference filter → cuvette → photodetector" (SOURCED `hu-hl4000`); badge "General principle" | SOURCED (order) |
| C8 | calibrators · L06 | Calibrators have assigned values; each level gives one signal | ARB `calStep2` "Calibrator lot and assigned values", `calGuide3` (value sheet per lot); signal-per-level = textbook | app text + STANDARD_TEXTBOOK |
| C9 | calibrators, badges | "Values: from the lot's value sheet"; "Number of points and model: per IFU" | ARB `calValuesFromSheet`, `calGuide3`, `calGuide2` | app text |
| C10 | points/fit · L07, L08 | Absorbance vs concentration, point by point; a least-squares line = the calibration curve (for this illustrative linear example) | Textbook OLS; model choice is method-specific (C9) | STANDARD_TEXTBOOK |
| C11 | fit · L09, equation panel | slope 0.0796, intercept 0.0114, R² 0.9999 — computed from the points shown | `video_studio/src/lib/regression.js` → `MATH_APPENDIX.md` §2; independent Python re-computation gave slope 0.07956, intercept 0.0114, R² 0.999902 | computed |
| C12 | controls · L10, panel "0.486 → 5.97, target 6.0 · 99.4 % of target" | A control with a known target is read off the curve | Inverse prediction ĉ = (A − b₀)/b₁, `MATH_APPENDIX.md` §3; no pass/fail stated | computed + STANDARD_TEXTBOOK |
| C13 | residuals · L11, title, residual panel, chips "small · random sign · no trend" | R² alone is not enough; residuals should be small with no trend | Regression diagnostics (textbook). Chips are what to look for, not a verdict on real data | STANDARD_TEXTBOOK |
| C14 | residuals · L12, amber badge | Acceptance limits come from the IFU and the lab SOP | ARB `calGuide4` (when to recalibrate — in the IFU), `calGuide5` (run QC, record it); no numeric limit anywhere in the video | app text |
| C15 | app_intro · L13 | LabGuide does not calibrate the analyzer; it records how calibration was done | `docs/video/01_kalibrlash.md` ("Ilova kalibrlashni bajarmaydi"); `CalibrationRecord` fields (`instruments_controller.dart`); end-card note `ctaNote` | code + doc |
| C16 | app_intro · L14, frames `cal_path`, `cal_reagent`, `cal_guide` | Instrument, analyte, reagent REF, IFU revision; without a verified guide parameters are not guessed | `CalibrationScreen` steps 1–3, `_showGuide` / `matchIfu`; ARB `calGuideNoneTitle`, `calGuideNoneBody` ("We do not guess parameters"); real frames | code + real screen |
| C17 | app_record · L15, frame `cal_record` | Record: calibrator lot, assigned values, unit (copied from the value sheet) | `_RecordForm` (lot required `calLotRequired`; name + numeric value + unit per level `calLevelInvalid`); ARB `calValuesFromSheet` | code + real screen |
| C18 | app_rules · L16, frames `cal_rule_qc`, `cal_rule_qc_err` | "Accepted" is blocked until QC after calibration has passed | `validateCalibrationAcceptance` (`instruments_controller.dart` l.141–152); UI: Accepted chip dimmed and refused when `_qcAfter != pass` (`calibration_screens.dart` `_RecordFormState.build`); tests `test/unit/calibration_safety_test.dart` ("accepted needs approver first, then passing QC", "accepted without approver or QC pass is refused"), `test/widget/calibration_safety_test.dart` | code + tests + real screen |
| C19 | app_rules · L17, frames `cal_rule_approver`, `cal_ready` | …and until an authorized person is named | Same function: `approverRequired` when name/role is empty; ARB `calSafeApproverRequired`. **Limit:** the app requires a name or role text; it does not verify identity or authority — the video says "named", not "verified" | code + tests + real screen |
| C20 | app_log · L18, frames `cal_saved`, `cal_log` | Saved records go to the calibration log on this device | `InstrumentsController` persists to the local `KeyValueStore` (`StoreKeys.calibrationLog`); ARB `calLogSub` "— on this device" | code + real screen |
| C21 | app_log · L19, frames `cal_detail`, `cal_history` | Create, edit, delete each leave a history entry, even after deletion | `CalibrationAuditAction {created, edited, deleted}`; unit test "create, edit and delete leave append-only audit entries"; widget test "o‘chirish tarixga «o‘chirildi» yozadi"; ARB `calSafeHistoryNote` (removed only by "delete local data") | code + tests + real screen |
| C22 | app scenes, badge | "Real app screens · sample values" | Frames = widget-test renders of `LabGuideApp` (real content pack, no server). Sample inputs: custom instrument "Demo / Photometer A" (no third-party brand), REF 10121, IFU 2024-01, lot L-77, 5.55 mmol/L, approver "Lab manager"; record type **Training** (the app itself shows "Training record: this is not laboratory evidence.") | provenance |
| C23 | end · L20 | "Calibration is not just a curve. It's confidence in every result." (owner's tagline) | About calibration as a laboratory practice, not a LabGuide guarantee; the end card adds "LabGuide documents calibration — it does not perform it." | owner tagline, bounded |
| C24 | end · L21, pill | Lab → Calibration | Route `/lab/calibration` from the Lab tab tile (`lab-calibration`, `docs/VIDEO_FEATURE_INVENTORY.md` §1) | app |
| C25 | audio | English synthetic narration in every edition; RU/UZ editions = subtitles + on-screen text | Owner decision 2026-10-25; `tool/tts/synth.py` backend `kokoro` (Kokoro-82M v1.0 int8, Apache-2.0, voice `af_heart`); `docs/video/tts/VOICE_DECISION.md`. **Nobody has listened to it yet** | disclosure |

Brand rule check: no third-party logo or brand name on screen. The catalogue example notice in the app
(`calBrandWarning`, which names two manufacturers) is kept off screen: frames are taken where it is not
visible and the snackbar frame is shown through a crop window (`storyboard.json → app_log → crop`).

## 2. Epistemic table (statements the video relies on)

| ID | Statement | Tag | Source / note |
|---|---|---|---|
| E1 | In a photometric chemistry analyzer the photometer measures the absorbance of light passing the reaction cuvette | SOURCED | CH-C5, CH-PR (`catalog.json` sources `mr-bs480-br`, `ro-c303`, `ro-c311`) |
| E2 | Concentration is obtained from the signal through a calibration (calibrator/standard or factor) | SOURCED (analyzer) / STANDARD_TEXTBOOK (general) | CH-PR; PH-PR ("standard or factor"). Hook wording "nobody can say" is rhetorical → **NEEDS_EXPERT** wording check (factor methods) |
| E3 | Light path lamp → interference filter → cuvette → photodetector | SOURCED | PH-C3 (`hu-hl4000`) |
| E4 | A = −log₁₀(I/I₀); within a limited range absorbance is proportional to concentration | STANDARD_TEXTBOOK | Beer–Lambert; lesson 07 T1 |
| E5 | Calibrators have lot-specific assigned values from the value sheet; number of points and model come from the IFU | SOURCED (app text) | ARB `calGuide2`, `calGuide3` |
| E6 | Ordinary least squares, R² = 1 − SS_res/SS_tot, inverse prediction | STANDARD_TEXTBOOK | `MATH_APPENDIX.md` |
| E7 | A high R² alone does not establish an adequate fit; inspect residuals (small, no systematic trend) | STANDARD_TEXTBOOK | regression diagnostics; **NEEDS_EXPERT** if the lab wants a specific guideline cited (e.g. a linearity-evaluation standard) — none is cited in the video |
| E8 | Acceptance criteria come from the IFU and the laboratory SOP | STANDARD_TEXTBOOK + app text | ARB `calGuide4`, `calGuide5`; no number given |
| E9 | The illustrative 5-point linear curve is representative of a photometric calibration | **NEEDS_EXPERT** | Many photometric methods use 1–2 point calibration with a blank; the video says "Number of points and model: per IFU" on screen |
| E10 | LabGuide behaviour (record fields, acceptance rule, local log, append-only history) | SOURCED (code + tests) | C15–C21 |

Review checklist for the expert: E2 wording, E7, E9, RU/UZ terminology (`slope` = «наклон» / «qiyalik»,
`intercept` = «свободный член» / «ozod had», `residuals` = «остатки» / «qoldiqlar», `a.u.` = «усл. ед.» /
«shartli birlik») — all NEEDS_NATIVE_REVIEW per `docs/L10N_TERMINOLOGY_DECISIONS.md` practice.
