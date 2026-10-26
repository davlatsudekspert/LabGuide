# Real-time PCR — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved.

Apparatus art: the app's ORIGINAL schematic `tool/illustrations/schematic/real_time_pcr.svg` (LabGuide's own
work); part names from the app (ARB `schemPartsRealTimePcr*Name`). **Optical path in the corrected order**:
excitation source (4) → excitation filter (5) → tube (6) → emission filter (7) → detector (8)
(`storyboard.json → data.paths`, drawn over the schematic). Curves and Cq: illustrative
(`MATH_APPENDIX.md`). Real app frames: free app `/home/user/wt-audit` (commit `215d3e8`),
`video_studio/flutter_walk/qpcr_walk_test.dart` (+ `labcard_kit.dart`): Lab → Instruments and methods →
Molecular diagnostics → "Real-time PCR (qPCR/RT-qPCR) method" card (`a1-realtime-pcr-method`, single source
`a1-sp-pcr`, NCBI Bookshelf). The platform card (`a3-mol-realtime-pcr-platform`) that states the Cq readout is
**not filmed** — one of its sources names a manufacturer (the walk's brand check stopped it); its text is
used only as evidence below. **No price/tier statement.**

## 1. Claims → evidence

| # | Where | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| R1 | hook · L01–L02, curves A, B, NTC, Cq 22.0 / 31.2 | Two samples cross the threshold at different cycles; which had more target? | illustrative; computed (`MATH_APPENDIX.md` §2) | illustrative |
| R2 | cycle · L03–L04, strands, steps, 1-2-4-8-16-32 | Heat separates strands, primers bind on cooling, a heat-tolerant polymerase builds new strands; the target roughly doubles each cycle | Method card `principle` (SOURCED `a1-sp-pcr`): "Heat separates the strands, primers attach on cooling and a heat-tolerant polymerase (Taq) builds new strands, roughly doubling the target each cycle"; lesson 04 L2 | SOURCED |
| R3 | cycler · L05, parts 1–3 | Tube strip, heated lid, Peltier thermal block that switches temperatures | Lesson C1–C3 (STANDARD_TEXTBOOK, C3 partly `a1-sp-pcr`); app part texts | STANDARD_TEXTBOOK |
| R4 | optics · L06, parts 4–6, blue path | Each cycle the excitation source shines through the excitation filter into the tube | Lesson C4, C6 (STANDARD_TEXTBOOK); **C5 excitation filter NEEDS_EXPERT** (filter wheel is one optical design among several — the video names the part only, as the app does) | STANDARD_TEXTBOOK / NEEDS_EXPERT |
| R5 | optics · L07, parts 7–8, green path | The dye's fluorescence passes the emission filter to the detector | Lesson C7 (STANDARD_TEXTBOOK), C8 SOURCED (`a1-sp-pcr`: detector reads fluorescence each cycle) | SOURCED + STANDARD_TEXTBOOK |
| R6 | curves · L08 | Fluorescence grows with the product: the amplification curve | Platform card `principle` (SOURCED `a1-sp-pcr`): "The fluorescent signal is proportional to amplicon accumulation and is monitored during the run"; lesson L4 | SOURCED (not filmed card) |
| R7 | curves · L09, pill "Lower Cq → more starting target" | Cq = cycle where fluorescence crosses the threshold; lower Cq = more starting target | Platform card `tasks` (SOURCED `a1-sp-pcr`): "The key readout is the quantification cycle (Cq) at which fluorescence crosses a threshold; a lower Cq means more starting target"; lesson L5 | SOURCED (not filmed card) |
| R8 | cautions · L10 | Trace contamination can give false results; no amplification does not prove a negative | Method card `limitations` (SOURCED `a1-sp-pcr`, filmed in `q_limits`): "trace contamination can produce false results; lack of amplification does not reliably prove a sample is negative" | SOURCED |
| R9 | app_card · L11, `q_dir`, `q_card` | Lab → Instruments and methods → Molecular diagnostics → Real-time PCR | Routes `/lab/instruments/d/molecular`, `/lab/instruments/lc/a1-realtime-pcr-method`; ARB `labInstruments`, `labDirMolecular` | code + real screen |
| R10 | app_card · L12, `q_parts`, `q_principle` | This schematic, its numbered parts and the principle — with sources | `SchematicFigure` parts panel; card `principle` + source line (kept outside the crop window) | code + real screen |
| R11 | app_limits · L13, `q_limits`, `q_qc` | Limitations and contamination control are on the card | Card `limitations`, `qc_calibration_note` ("Contamination prevention: a separate PCR area, PPE, a laminar-flow hood with UV light, dedicated equipment, positive-displacement pipettes, and post-amplification work on a separate bench") | SOURCED + real screen |
| R12 | end note | "Reference cards — the assay IFU and your laboratory SOP decide." | `labDirDisclaimer` | app text |
| R13 | audio | English synthetic narration (Kokoro-82M `af_heart`), RU/UZ = subtitles; **nobody has listened to it** | owner decision | disclosure |

## 2. Epistemic table

| ID | Statement | Tag |
|---|---|---|
| E1 | Cycle steps and ≈ doubling per cycle | SOURCED (`a1-sp-pcr`) |
| E2 | Optical path order excitation source → excitation filter → tube → emission filter → detector | STANDARD_TEXTBOOK (C4–C8; C8 SOURCED); C5 wording NEEDS_EXPERT |
| E3 | Signal ∝ amplicon; Cq definition; lower Cq ⇒ more starting target | SOURCED |
| E4 | Contamination / no amplification ≠ negative | SOURCED |
| E5 | Curve shapes, threshold value, Cq numbers | illustrative |

RU «ПЦР в реальном времени», «мишень», «порог»; UZ «nishon», «chegara», «kuchayish egri chizig‘i» follow
the app's catalog/ARB — NEEDS_NATIVE_REVIEW. The app's UZ card name uses "Real-time PCR (kmPCR/RT-qPCR)" and
the platform card "PZR" — the video's UZ text says "Real vaqt PCR" (owner/native reviewer to align).
