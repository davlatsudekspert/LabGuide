# GC-MS — quality self-check (2026-10-25)

Method: frames from the **final MP4s** with `node video_studio/scripts/qa_frames.mjs`: 60 % of every scene, plus
t = 0, 0.5 and 1.5 s. Checked for **EN vertical** and **UZ horizontal**, with spot checks of **RU vertical** and
EN horizontal. Frames were viewed as contact sheets. After each splice, extra frames were viewed full size:
the hook (0–2.6 s), QC → app card (54–68 s, EN) and the RU result scene.

Other checks:
- Subtitles: `node video_studio/scripts/subcheck.mjs --id gcms` (chars/s) and `node video_studio/scripts/subrows.mjs --id gcms` (exact rows with real Inter-600 metrics).
- MP4 facts: ffprobe and `ebur128` (`OUTPUTS.md`).
- Thumbnails 1280×720 and covers 1080×1920 for all three languages.

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| G-Q1 | final MP4, vertical (EN) | L11 ("Without quality control, …") and L12 (the menu path) wrapped to **3 rows** on the vertical plate. The estimated row check had missed it; the exact metric check (`subrows`) found it. | `storyboard.timing.cueFont.en.L11 = 0.9` (plate font 43 px, still ≥ 40 px; reading time unchanged). `cueMax.en.L12 = 45` (path split into 3 cues). Frames 1599–2075 spliced into EN vertical + horizontal; EN SRT/VTT regenerated. 0 of 130 cue renders exceed 2 rows. |
| G-Q2 | hook, t = 0 (all six) | The first frame showed empty axes: the trace took 1.6 s to draw and the question appeared at 1.2 s. | The first peak with its "?" is already drawn at t = 0. The trace completes in 1 s and the question pops at 0.7 s. Frames 0–75 spliced into all six MP4s; seam at 2.5 s checked. |
| G-Q3 | result scene, RU | The long rotated axis label «Относительная интенсивность» ran up into the title «Масс-спектр пика B». | RU label shortened to «Отн. интенсивность». Frames 1299–1598 spliced into RU vertical + horizontal. |
| G-Q4 | final MP4, vertical (RU) | L12 «В LabGuide: Лаб. → Приборы и методики → Токсикология → ГХ-МС.» wrapped to 3 rows, although `subrows` had measured 2. The browser wraps slightly earlier than the PIL measurement (the same was seen on qPCR RU L07: 879.6 of 880 px). | `cueMax.ru.L12 = 40` (3 shorter cues). Frames 1749–2075 spliced into RU vertical + horizontal; RU SRT/VTT regenerated. `subrows.mjs` now subtracts the plate borders and keeps 1.5 % slack. |

All four were fixed with `scripts/splice.mjs`: only those frames were re-rendered, the frame count was verified and the narration re-muxed. There was no full re-render. GC-MS was rendered after the `--no-subs` splice bug was found, so all of its splices carry the burned-in subtitles (checked in the frames).

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 82.90 s, AAC-LC 48 kHz (`OUTPUTS.md`).
* Loudness: −16.2 LUFS integrated, true peak −2.3 dBTP (EN vertical, UZ horizontal).
* Subtitle speed: EN worst 17.0, RU 15.9, UZ 16.8 chars/s. All cues have ≤ 2 rows: 0 of 134 cue renders are flagged by `subrows`, even with the new 1.5 % margin.
* Labels:
  * "Illustrative schematic panels — no real compound" on every chart scene and on the thumbnails/covers;
  * "Schematic — not an exact model" on the schematic tours;
  * "Real app screens" on the app scenes.
* No numbers on the chromatogram/spectrum axes, following the lesson plan.
* Part names on screen match the app's part names (EN/RU/UZ).
* The menu path in L12 matches the app route and the real frames (`CLAIMS_AND_EVIDENCE.md` G11).
* The CTA shows the short form "Lab → Instruments and methods → GC-MS"; the full path, including Toxicology, is shown and spoken in L12.
* No brand names or logos: the walk's deny-list check passed, and the card's source lines are kept out of the bright crop window.
* A frame taken at 60 % of the app-card scene falls in the 0.3 s cross-fade between two app shots. This is the normal shot transition, not a defect; frames 0.3 s either side are clean.

## Open items

* Listening review of the English synthetic voice: **nobody has listened to it**.
* Expert review of every STANDARD_TEXTBOOK row in `CLAIMS_AND_EVIDENCE.md` (status EXPERT_REVIEW_PENDING).
* Native-speaker review of RU/UZ wording (UZ «Ushlanish vaqti», «Cho‘qqidan moddagacha»; RU «Отн. интенсивность»).
* Tooling note: the 3-row EN vertical issue only appears at the exact plate font. The estimate in `subcheck.mjs` is kept, but `subrows.mjs` is now the gate.
