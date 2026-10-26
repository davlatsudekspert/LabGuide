# Real-time PCR — quality self-check (2026-10-26)

Method:
- Remotion stills before the render: all scenes for EN vertical (at 15 % and 70 % of each scene) and UZ horizontal (at 70 %).
- Frames from the **final MP4s** with `node video_studio/scripts/qa_frames.mjs`: 60 % of every scene, plus t = 0, 0.5 and 1.5 s. Checked for **EN vertical** and **UZ horizontal**, with a spot check of **RU vertical**.
- After each splice, the frames were taken again and viewed: hook, optics, curves.
- Subtitles: `subcheck.mjs` (chars/s) and `subrows.mjs` (rows with real font metrics). Each flagged cue was checked in the final MP4.
- MP4 facts: ffprobe and `ebur128` (`OUTPUTS.md`).
- Thumbnails 1280×720 and covers 1080×1920 for all three languages.
- Curve arithmetic: `MATH_APPENDIX.md`. The JS curve model and Cq solution are checked against `scripts/crosscheck_qpcr.py`.

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| R-Q1 | walk / brand | The platform card's source line names a manufacturer, and the walk's deny-list stopped it. | That card is not filmed. The video films the method card only (`CLAIMS_AND_EVIDENCE.md`). |
| R-Q2 | subtitles (EN) | L11 (menu path) needed 3 rows on the vertical plate (exact metric check). | `cueMax.en.L11 = 50`. |
| R-Q3 | hook, t = 0 (all six) | Empty axes in the first frame. The A / B / NTC labels sat on top of each other at the curve heads, so "NTC" read as "■TC". | The first frame already shows curve A leaving the baseline, and the trace completes in 1.2 s. Curve-end labels appear only once the curves have separated (from cycle 31, fading in). Frames 0–207 spliced into all six MP4s. |
| R-Q4 | final MP4, vertical (RU) | L07 «Флуоресценция красителя проходит эмиссионный фильтр к детектору.» wrapped to 3 rows. The browser wraps slightly earlier than the PIL measurement (879.6 of 880 px). | `cueMax.ru.L07 = 40` (two cues). `subrows.mjs` now subtracts the plate borders and keeps 1.5 % slack. Frames 676–1268 (optics + curves, which also carry the R-Q3 label change) spliced into all six MP4s. |
| R-Q5 | thumbnails 1280×720 | EN headline broke at the hyphen ("Real-" / "time PCR"). The RU headline took 3 lines and covered its subtitle. The UZ headline touched the plot's axis label. | Headline size now depends on its length, with a non-breaking hyphen. The plot moved 20 px right. All six thumbnails/covers re-rendered and viewed. |

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 73.40 s, AAC-LC 48 kHz (`OUTPUTS.md`).
* Loudness: −16.3 LUFS integrated, true peak −2.2 dBTP (EN vertical, UZ horizontal).
* Subtitle speed: EN worst 16.9, RU 16.3, UZ 16.2 chars/s.
* Subtitle rows:
  * The stricter `subrows` still flags RU L03 #1 and RU L08 (vertical).
  * Both show **2 rows** in the final RU vertical MP4, so they are the margin's false positives.
  * Every other cue is ≤ 2 rows.
* Cq values on screen (22.0, 31.2) are computed in code from the illustrative curves. The spoken "cycle 22 … 31" is the same values rounded.
* Labels:
  * "Illustrative curves — not a real assay or result" on every curve scene and on the thumbnails/covers;
  * "Schematic — not an exact model" on the tours;
  * "General principle" on the cycle scene;
  * "Real app screens" on the app scenes.
* The optical path is drawn in the corrected order 4 → 5 → 6 → 7 → 8 (excitation source → excitation filter → tube → emission filter → detector).
* Cautions ("trace contamination → false results", "no amplification ≠ proven negative") come from the app's cards (source cited there).
* The menu path matches the app route and the real frames.
* No brand names or logos are visible: deny-list check in the walk, plus the platform card left unfilmed.

## Open items

* Listening review of the English synthetic voice: **nobody has listened to it**.
* Expert review of all STANDARD_TEXTBOOK rows (status EXPERT_REVIEW_PENDING).
* Native-speaker review of RU/UZ. UZ naming: the app's platform card uses "PZR", while the video's UZ text says "Real vaqt PCR". The owner or a native reviewer should align these.
* `subrows.mjs` exits 1 on qPCR and photometry because of the verified false positives above. Treat its output as "check these cues in the MP4", not as a hard failure.
