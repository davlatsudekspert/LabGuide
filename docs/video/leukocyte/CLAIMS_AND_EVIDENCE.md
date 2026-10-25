# Leukocyte differential count (flagship 2) — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved; the morphology, the
counting rules and the RU/UZ wording have not been reviewed by a haematology/laboratory specialist or a
native-speaker reviewer.

Code references are to the read-only Flutter checkout used for the walk, `/home/user/wt-audit`, branch
`fix/images-apparatus`, commit `215d3e8` (the **free** app). The real app frames were rendered from it with
`video_studio/flutter_walk/leukocyte_walk_test.dart`. On branch `video/studio` (paid line, D-76/D-77) the same
differential code carries extra entitlement gates (`Feature.leukocyteCounter` on the Microscope-mode start
button, `Feature.leukocyteEvaluation` on Interpretation links, `Feature.absoluteCounts` on the separate
absolute-count calculator; defaults "not locked"). **The video says nothing about price, tiers or
availability**; before publishing, the owner must confirm how the differential is offered in the build being
advertised.

## 1. Claims → evidence

| # | Where (scene · line / on-screen) | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| C1 | hook · L01–L02, paper tally, "Σ 97? ~~87~~", "Lost count?" | A manual 100-cell tally on paper is easy to lose count of | Rhetorical hook. Tally strokes = first 87 cells of the illustrative sequence (`storyboard.json → data.hook`); badge "Illustrative count — not a patient result" on screen. The app's own paper method (10 strokes per row, 10 rows = 100) is in `differential_content.dart` technique "No counter: a paper tally table" (WHO 2003 §9.13.3, Lyubina 1984 §61) | rhetorical → NEEDS_EXPERT (wording) |
| C2 | field · L03, chip "×100 oil immersion" | Under the oil objective a stained film shows red cells, platelets and white cells | App technique text "With the ×100 oil objective, first check leukocytes are evenly spread" (`differential_content.dart` l.1340, refs WHO 2003 §9.10.4, Gulati 2013) | SOURCED (app) + STANDARD_TEXTBOOK (platelets) |
| C3 | field · L04, slide diagram "Count here", badge "Monolayer: red cells touch, don't overlap" | Count where red cells touch but do not overlap | App technique text l.1345 "Count in the readable monolayer just before the thin end: red cells touch but do not overlap. Avoid the thick part and the very edge." | SOURCED (app → WHO 2003 §9.10.4, Gulati 2013) |
| C4 | cells · L05, card | Segmented neutrophil 12–15 µm, 2–5 lobes joined by thin chromatin strands, pale pink cytoplasm, fine mauve granules | `cellGuides` `neutrophil_segmented` (`differential_content.dart` l.150–181), ref `whoCells` = WHO 2003 §9.10.4, Table 9.10 | SOURCED |
| C5 | cells · L06, card | Band neutrophil: one curved nucleus (C/S), not divided into lobes; no thin strand | `cellGuides` `neutrophil_band` + `confusions` band/segmented (WHO 2003 §9.10.4 "Immature granulocytes"; Oskarsson 2022). Size deliberately not shown (the app: "not given separately") | SOURCED |
| C6 | cells · L07, card | Eosinophil 12–15 µm, usually 2 lobes ("spectacles"), large round densely packed orange-red granules | `cellGuides` `eosinophil` (WHO 2003 §9.10.4) | SOURCED |
| C7 | cells · L08, card | Basophil 11–13 µm, very large deep-purple granules that cover the nucleus | `cellGuides` `basophil` (WHO 2003 §9.10.4). Narration says "large" (app: "very large … less densely packed than in eosinophils") | SOURCED |
| C8 | cells · L09, card | Lymphocyte (small) 7–10 µm, round dense nucleus, scant cytoplasm as a thin blue rim | `cellGuides` `lymphocyte_small` (WHO 2003 §9.10.4). The video shows the small lymphocyte only; the app also lists large and reactive lymphocytes | SOURCED |
| C9 | cells · L10, card | Monocyte 15–25 µm, the largest leukocyte; folded / kidney-shaped pale nucleus; grey-blue cytoplasm with vacuoles | `cellGuides` `monocyte` (WHO 2003 §9.10.4) | SOURCED |
| C10 | cells, all drawings; badge "Schematic illustration — not a micrograph"; "Red cell ≈ 7.5 µm (same scale)" | The cells are original schematic illustrations drawn to one scale | Drawn in code by LabGuide for this video (`video_studio/src/components/Cells.tsx`): diameters 13.5 / 13.5 / 8.6 / 18.5 / 13.5 / 12 µm, red cells 7.1–7.9 µm, mid-points of the app's ranges; red-cell size from the app's `diffScaleNote` ("~7.5 µm"). Romanowsky-type colours chosen by the author (not colour-calibrated) | provenance; colours NEEDS_EXPERT |
| C11 | track · L11, mini-map battlement track, "One direction · no field twice" | Move field by field in one direction, never back, so no cell is counted twice | App technique text l.1350 (WHO 2003; Gulati 2013) and "Moving along the film: edges and middle" (Lyubina 1984 §61: zigzag/meander covering edges and middle). The video's track is schematic | SOURCED (app) |
| C12 | track · L12, tally panel to 100 | Classify each leukocyte as you meet it, usually to 100 | App technique l.1355 "Usually 100 leukocytes are counted … some laboratories 25 to 200–300 — follow your SOP"; CIS textbooks often 200 (app text, Lyubina 1984) | SOURCED (app) |
| C13 | track, tally numbers | Running tally 1…100 | Computed from `data.sequence` (`src/lib/differential.js → tallyAt`); "Fast-forward" badge in the fast part | computed, illustrative |
| C14 | app_tap · L13, frame `d_count0` | Every cell class has its own big button | `DiffCounterScreen` → `_CountButton` per `DiffCell` (7 classes: segmented, band, lymphocyte, monocyte, eosinophil, basophil, other), `minHeight: 104` (`differential_screens.dart` l.1219–1307); real frame | code + real screen |
| C15 | app_tap · L14, frames `d_tap1…d_tap6`, ripple + ring | One tap adds one to that cell; a long press takes one away | `DifferentialController.tap` (+1, l.161), `decrement` (−1 on long press, l.170); app subtitle "Tap: +1 · Long-press: −1" visible in every counter frame; widget test `differential_flow_test.dart` ("hisoblagich 100 da to'xtaydi…": long press −1). The walk taps the real buttons in the order of `data.sequence` and asserts the counts. **The long press itself is not filmed** (stated, not shown) | code + test + real screen |
| C16 | app_tap · L15 | The total and each percentage update with each tap | `_ProgressPanel` (`total / target`), `_CountButton` shows `percent` (`DiffRecord.percent`) — visible changing across `d_tap1…d_tap6` (e.g. 66.7 % → 50 %) | code + real screen |
| C17 | app_target · L16, frames `d_half`, `d_done` | Choose 100 or 200 cells; at the target counting stops | `DifferentialController.targets = [100, 200]` (l.81), `isComplete`; `d_done` shows "100 cells counted — Counting has stopped" (ARB `diffDoneTitle`, `diffDoneBody`) | code + test + real screen |
| C18 | app_target · L17, frame `d_blocked` | An extra tap is not added | `tap()` returns `TapOutcome.blocked` when complete (l.162); snackbar "Target reached — tap not added" (ARB `diffBlocked`); walk asserts total stays 100; widget test (eosinophil taps after 100 stay 0) | code + test + real screen |
| C19 | eyes_free · L18, frames `ef_settings`, `ef_run` | Microscope mode: big screen zones, so the eyes stay on the eyepiece | `DiffEyesFreeSettingsScreen` / `DiffEyesFreeScreen` (route `/lab/differential/count/eyes-free/run`); ARB `diffEfEntrySub` "Large screen zones; a sound and vibration on every tap", `diffEfHowBody` "…without looking away from the microscope"; test `diff_eyes_free_flow_test.dart` | code + test + real screen |
| C20 | eyes_free · L19, frames `ef_tap`, `ef_patterns` | Each cell type has its own vibration pattern; every 10th cell a longer signal | `cellPatterns` (`diff_eyes_free.dart` l.24), `tenPattern` + `total % 10 == 0` (l.35, l.230); ARB `diffEfHowBody`. **Limit:** vibration is felt only if enabled on the phone (ARB `diffEfHapticsSub`); the video cannot show a vibration — the frames show the zones and the pattern list | code + test + real screen |
| C21 | formula · L20, table | % = n ÷ total × 100; absolute = n ÷ total × WBC | `DiffRecord.percent` / `absolute` (`differential_controller.dart` l.53–57); video math `src/lib/differential.js`; `MATH_APPENDIX.md` (JS = independent Python = the app's own numbers from the walk) | computed + code |
| C22 | app_result · L21, frames `d_result`, `d_wbc` | Enter the WBC, and absolute counts appear next to each percentage | `DiffResultTable` adds the ×10⁹/L column only when `record.wbc != null`; without WBC: "Enter the WBC to see absolute counts." (ARB `diffAbsNeedWbc`); walk enters 8 → 4.48 / 0.24 / 2.4 / 0.48 / 0.32 / 0.08 (copied text in `MATH_APPENDIX.md` §5) | code + test + real screen |
| C23 | app_result · L22, frames `d_assess`, `d_limits` | Reference ranges come from your lab's report form; the comparison is not a diagnosis | `DiffAssessmentPanel` + ARB `diffAssessNote` ("This is not a diagnosis…"), `DiffLimitsScreen` + ARB `diffLimitsSub` ("Enter the ranges printed on your laboratory's report — assessment uses them"); copy footer `diffCopyFooter` ("Reference intervals: see the laboratory report form"). **Limit:** until the user edits them, the app uses its sourced default adult limits (Harrison's Manual 20th ed. Table 64-1; bands Lyubina 1984 Table 6) — these default numbers are visible in the `d_assess`/`d_limits` frames; the video itself states no range. Assessment only for a complete count (`incomplete`) | code + real screen; NEEDS_EXPERT (showing default numbers on screen) |
| C24 | app_save · L23, frames `d_saved`, `d_copied`, `d_history` | Save the result on this device, or copy it as text | `save()` → `StoreKeys.differentialHistory` (local store); snackbar "Result saved (on this device only)"; `_copy` → `Clipboard.setData(diffReportText(…))`, snackbar "Result copied"; history list. **There is no PDF/file export**: `DiffEntryPoints.pdfExportAvailable == false` (`differential_entry_points.dart` l.21), asserted in `differential_flow_test.dart` — the video says "copy it as text", nothing about export | code + test + real screen |
| C25 | app scenes, badge "Real app screens · illustrative count" | The app frames are real | Widget-test renders of `LabGuideApp` (real content pack, no server, guest, role lab, 390×844 @2x). Only device plugins faked (sound player, wake lock; the app's own test fakes) and the clipboard channel recorded. Sample label "Demo 1" (no patient name), WBC 8 (illustrative) | provenance |
| C26 | end · L24 | "Keep your eyes on the cells. LabGuide keeps the count." | Bounded to what the counter does: per-class counting, stop at target, undo, Microscope mode; the count survives leaving the screen (`_changed()` writes `StoreKeys.differentialDraft`, restored in `_load`; hub button "Continue counting (n/target)"). End-card note: "A counting aid: reference ranges come from your laboratory, conclusions from the clinician." | owner tagline, bounded |
| C27 | end · L25, pill | Lab → Differential count | `DifferentialEntryCard` is the first item of the Lab tab (`differential_flow_test.dart` "kirish nuqtalari…"); frame `d_lab` (walk) | app |
| C28 | audio | English synthetic narration in every edition; RU/UZ editions = subtitles + on-screen text | Owner decision 2026-10-25; `tool/tts/synth.py` backend `kokoro` (Kokoro-82M v1.0 int8 ONNX, Apache-2.0, voice `af_heart`); **nobody has listened to it yet** | disclosure |

Not claimed (on purpose): no diagnosis or interpretation of the illustrative result; no normal range stated by
the narration; no PDF/file export; no voice commands (the app has an *experimental* voice-counting mode —
device-dependent — not shown); no statement on accuracy, speed or time saved; no price/tier.

Brand rule check: no third-party logo or brand name on screen. The walk fails if any deny-listed word
(analyser/microscope manufacturers, publishers used as brands: Sysmex, CellaVision, Mindray, Roche, Abbott,
Beckman, Siemens, Horiba, Bio-Rad, MSD, Merck, McGraw, Harrison, MedlinePlus) is visible in a frame
(`_Walk.brandCheck`). The sources list and the limits source note (which name a textbook and a manual) stay off
screen.

## 2. Imagery and licences

| Visual | Source | Licence / status |
|---|---|---|
| All cells, smear field, slide diagram, tally paper | Original schematic illustrations drawn in code by LabGuide (`Cells.tsx`, `MicroscopeField.tsx`, `layers.tsx`) | LabGuide's own work; labelled "Schematic illustration — not a micrograph" on screen |
| Cell thumbnails on the counter buttons (inside app frames) | The app's own schematic drawings (`assets/differential/*.png`, app caption "Schematic drawing (made by LabGuide) — not a micrograph") | LabGuide's own work |
| App screens | Real app (walk test) | LabGuide |
| Logo | Owner's app icon (`assets/images/logo_mark_large.png`) | owner |
| Micrographs | **None used.** The app's atlas has CDC PHIL photos (b-neut-2 #18910, b-lymph-1 #18909, b-mono-1 #30136, b-baso-1 #18908, b-eos-1 #18907) but their PHIL pages were not re-checked live (`IN_APP_PHOTOS_LIVE_CHECK_2026-10-25.md`: NOT RUN), and b-eos-1 carries the app's own note that its granules look purple ("easily confused with a basophil") — so it is not a "correct eosinophil" image. No frame shows the in-app "Real smear" section | — |

## 3. Epistemic table (statements the video relies on)

| ID | Statement | Tag | Source / note |
|---|---|---|---|
| E1 | Differential counting is done with the ×100 oil objective on a stained (Romanowsky-type) film | SOURCED | App technique (WHO 2003 §9.10, §9.13) |
| E2 | Count in the monolayer where red cells touch but do not overlap; avoid the thick part and the very edge | SOURCED | App technique (WHO 2003 §9.10.4; Gulati 2013) |
| E3 | Move systematically in one direction without revisiting fields; leukocyte distribution differs between edges and centre, so the track should cover both | SOURCED | App technique (WHO 2003; Lyubina 1984 §61) |
| E4 | Usually 100 cells; 200 in many CIS textbooks; the lab SOP decides | SOURCED | App technique |
| E5 | Morphology of segmented/band neutrophil, eosinophil, basophil, small lymphocyte, monocyte as stated in C4–C9 | SOURCED | `cellGuides` (WHO 2003 §9.10.4 Table 9.10) |
| E6 | Size ranges (12–15, 7–10, 15–25, 12–15, 11–13 µm) and red cell ≈ 7.5 µm | SOURCED | `cellGuides`, `diffScaleNote` |
| E7 | The schematic drawings are morphologically representative (lobe count 3 shown for "2–5", one band shape, granule density/colour, monocyte nucleus shape) | **NEEDS_EXPERT** | Drawn by the video author from the app's descriptions; colours not calibrated to a stain |
| E8 | percent = n/total × 100; absolute = n/total × WBC | STANDARD_TEXTBOOK | App code; `MATH_APPENDIX.md` |
| E9 | Interpretation needs the laboratory's reference interval and the clinical picture; the comparison is not a diagnosis | SOURCED (app text) | ARB `diffInterpretIntro`, `diffAssessNote`, `diffLimitsSub` |
| E10 | The illustrative tally (56/3/30/6/4/1, WBC 8) is presented only as an example, not as typical or normal | **NEEDS_EXPERT** | A reviewer may prefer a tally that avoids looking like a "normal" pattern; the app's own default limits mark it "within the reference range" in the `d_assess` frame |
| E11 | Hook wording "On paper, a hundred-cell differential is easy to lose" | **NEEDS_EXPERT** | Rhetorical; no data on error rates is cited or implied |
