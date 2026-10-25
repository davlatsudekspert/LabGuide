# GC-MS — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved.

Apparatus art: the app's ORIGINAL schematic `tool/illustrations/schematic/mass_spec_gc.svg` (LabGuide's own
work, `docs/SCHEMATICS_PROVENANCE.md`; same drawing as in the app card). Part names are copied from the app
(ARB `schemPartsMassSpecGc*Name`, EN/RU/UZ). Chromatogram and spectra are **illustrative schematic panels**
(`MATH_APPENDIX.md`), no numbers on the axes, no real compound. Real app frames: free-app checkout
`/home/user/wt-audit` (commit `215d3e8`), `video_studio/flutter_walk/gcms_walk_test.dart` + `labcard_kit.dart`.
The app card cites its source on screen under each field; those source lines are kept outside the bright
crop window in the video (the flagships keep bibliographic/publisher names off camera). **No price/tier
statement.**

## 1. Claims → evidence

| # | Where | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| G1 | hook · L01–L02, three "?" peaks | One unknown sample with three peaks; GC-MS separates, then reads fragments | illustrative panel; principle: L1/L2 (below) | illustrative + STANDARD_TEXTBOOK |
| G2 | gc · L03, parts 1–5, carrier-gas path | Carrier gas cylinder, autosampler, heated injector, oven + capillary column, heated transfer line | Lesson 01 C1–C5 (STANDARD_TEXTBOOK, parts_src TB); names = app ARB; card `technology` (SOURCED `a3-statpearls-ms`) for "GC coupled to MS" | STANDARD_TEXTBOOK (parts), SOURCED (coupling) |
| G3 | separate · L04, zones leaving the column at different times + chromatogram | Compounds leave the column at different times: retention time | Lesson 01 PR, C4 (STANDARD_TEXTBOOK) | STANDARD_TEXTBOOK |
| G4 | separate · L05, chip | For GC the analyte must be volatile, sometimes after derivatization | App card `specimens` (SOURCED `a3-statpearls-ms`); lesson L3 | SOURCED |
| G5 | ms · L06, parts 6–10, ion path, signal wire | Ion source, quadrupole, detector, vacuum pumps, data system | Card `technology` (ion source, mass analyser, detector — SOURCED); C7/C8 SOURCED; C6, C10 STANDARD_TEXTBOOK; **C9 vacuum pumps NEEDS_EXPERT** (lesson: pump types/absolute wording unsourced — the video only names the part) | mixed |
| G6 | quad · L07 | Molecules are ionised and break into fragment ions | C6 (STANDARD_TEXTBOOK, partly `a3-statpearls-ms`), app part text "producing fragments" | STANDARD_TEXTBOOK |
| G7 | quad · L08, one ion colour passes at a time | The quadrupole sorts ions by m/z and passes them in turn | Card `principle` (SOURCED: "ions are sorted by m/z and measured by a detector"); C7 SOURCED. The colour cycling is a schematic of a scan, not a timing | SOURCED |
| G8 | result · L09, chromatogram + spectrum of peak B | Result: chromatogram over retention time and a mass spectrum per peak | Card `principle` ("spectrum of m/z against relative intensity", SOURCED); lesson RS (STANDARD_TEXTBOOK) | SOURCED + STANDARD_TEXTBOOK |
| G9 | result · L10, pill | Identified against a spectral library or standards | Lesson RS, C10; app ARB `schemPartsMassSpecGcResult` | STANDARD_TEXTBOOK |
| G10 | qc · L11, dashed extra peak, badge | Without QC, peaks that do not belong to the sample can appear | Card `qc_calibration_note` (SOURCED `a3-statpearls-ms`): "Without quality control, peaks that do not correspond to sample ions may appear"; the source gives no calibration procedure (the video gives none) | SOURCED |
| G11 | app_card · L12, frames `g_dir`, `g_card` | Lab → Instruments and methods → Toxicology → GC-MS card | Routes `/lab/instruments/d/toxicology`, `/lab/instruments/lc/a3-tox-gc-ms`; ARB `labInstruments`, `labDirToxicology`; real frames | code + real screen |
| G12 | app_card · L13, frames `g_parts`, `g_principle` | The same schematic with numbered parts; principle, specimens, tasks — each with a source | `SchematicFigure` + parts panel (`schematic-parts-mass_spec_gc`); `_LabCard.field` prints the source titles under every text | code + real screen |
| G13 | app_safety · L14, frames `g_qc`, `g_bio` | QC notes and biosafety: hot parts, glasses, coat, gloves | Card `qc_calibration_note`, `biosafety` (SOURCED: "Parts of the apparatus get hot … safety glasses, long trousers, closed shoes, a long lab coat and gloves") | SOURCED |
| G14 | end note | "A reference card — methods and limits come from your laboratory and its SOPs." | App `labDirDisclaimer` ("Educational reference only… not an operating protocol") | app text |
| G15 | audio | English synthetic narration (Kokoro-82M `af_heart`), RU/UZ = subtitles; **nobody has listened to it** | owner decision 2026-10-25 | disclosure |

Card status shown by the app itself: `audit_status NEEDS_REVIEW`, "Expert reviewed: not yet" (visible in
frame `g_dir`) — consistent with this video's EXPERT_REVIEW_PENDING.

## 2. Epistemic table

| ID | Statement | Tag |
|---|---|---|
| E1 | GC coupled to MS (ion source, analyser, detector); ions sorted by m/z; spectrum m/z vs relative intensity | SOURCED (`a3-statpearls-ms`, NCBI Bookshelf) |
| E2 | Analyte volatility / derivatization | SOURCED |
| E3 | Retention time separation in the column; EI fragmentation; library/standard identification | STANDARD_TEXTBOOK |
| E4 | Vacuum pumps reduce ion–gas collisions | **NEEDS_EXPERT** (named only) |
| E5 | QC: spurious peaks without QC; biosafety list | SOURCED |
| E6 | Panels (peaks, spectra) | illustrative, no real compound |

RU/UZ terms (ГХ-МС, «время удерживания», «дериватизация»; «ushlanish vaqti», «derivatizatsiya») follow the
app's ARB/catalog wording — NEEDS_NATIVE_REVIEW.
