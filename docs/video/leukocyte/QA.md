# Leukocyte differential flagship — quality self-check (2026-10-25)

Method: Remotion stills at chosen scene positions while iterating (`npm run still`, EN/RU vertical, UZ
horizontal), then frames extracted from the **final MP4s** with ffmpeg at 60 % of every scene (12 scenes, plus
t = 0, 0.5, 1.5 s for the hook) and viewed at full size for **EN vertical** and **UZ horizontal**; spot checks
of EN horizontal (6 scenes) and RU vertical + horizontal (4 scenes each); every real app frame viewed (EN) as a
contact sheet. Subtitle speed and row count checked against the real voice timing with
`node scripts/subcheck.mjs --id leukocyte`. Encoding verified with ffprobe (`OUTPUTS.md`), loudness with
`ffmpeg -af ebur128=peak=true`. Arithmetic: `MATH_APPENDIX.md` (JS = independent Python = the app's own numbers).

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| Q1 | walk test | Rows below the fold of a lazy list (Microscope-mode row, sample-label field) were not built → `Bad state: No element` | `bring()` scrolls until the widget exists (down, then up) before measuring |
| Q2 | app frames `d_assess` | First framing showed mostly range numbers and cut the "This is not a diagnosis" note | Frame centred on the note (`diffAssessNote`), ring on it; WBC frame scrolled so the WBC field is visible |
| Q3 | cells | Monocyte nucleus read as a round blob, not kidney-shaped; red cells had no visible central pallor; portrait red cells mostly clipped | Notched (kidney) nucleus with fine lacy chromatin; stronger pale centre in the red-cell gradient; reference red cells placed on a ring next to the leukocyte, one µm scale for all six cells (monocyte visibly the largest) |
| Q4 | hook (horizontal) | "Lost count?" pill overlapped the tally sheet; long UZ column headers collided ("Segment Tayoqcha") | Pill moved above the sheet; column header size fitted to the label length |
| Q5 | field | Leader lines crossed the field (targets on the far side); smear-diagram labels ran together ("Считать здесь Тонкий край"); labels collided with the slide diagram (vertical) | Targets chosen on the label side and labels sorted by target position; "Count here" label above the zone; the cell labels fade out when the slide diagram appears (second line) |
| Q6 | track | Slow phase too long (only 21 of 100 counted at 60 %); colour emoji "⏩" in the badge; "Segment24" (UZ) collided in the tally panel | 5 slow cells then fast-forward; text glyph "▸▸"; wider name column, no wrap |
| Q7 | app_tap (vertical) | Zoomed phone cropped the left button column and the count ("1/100"); phone partly under the subtitle plate | Phone unzoomed on the left, microscope field + callout in a right column, bottom fade above the subtitle zone |
| Q8 | app_tap (horizontal) | Zoom cut the app title | Unzoomed (full screen visible) |
| Q9 | formula (horizontal) | Formula panel wrapped and the footnote ran under the subtitles | Formulas on one line, WBC note below, rows 54 px; everything ends above y = 900 |
| Q10 | subtitles RU/UZ (speed) | With the real voice: RU L04 17.1, UZ L03 17.3, UZ L04 21.6, UZ L11 17.1 chars/s (> 17) | Translations shortened; worst now EN 16.7, RU 16.1, UZ 16.5 chars/s |
| Q11 | subtitles RU (rows) | In the first RU render several cues wrapped to **3 rows** on the vertical plate (e.g. L07 "Эозинофил: обычно два / сегмента и крупные / оранжево-красные гранулы.") and covered the cell features — the 40-chars-per-row estimate is too optimistic for Cyrillic at 48 px | `subcheck.mjs` now uses per-language row capacity calibrated on rendered frames (EN 38, RU 32, UZ 33); RU L03/L07/L08/L10/L19/L21/L22/L23 and UZ L10/L16/L22 shortened; RU and UZ editions re-rendered |
| Q12 | audio | After AAC the MP4 true peak was −1.9 dBTP (target ≤ −2) | `voice.mjs --tp -2.4` (new option; cached clips, timing verified identical), WAV re-normalised, EN MP4s remuxed without re-render, RU/UZ rendered with the new WAV: −16.2 LUFS, −2.2 dBTP |
| Q13 | thumbnail | "100 cells. Every tap counted." overstates the app (taps past the target are refused) | "100 cells, one tap each." (RU/UZ likewise); "Schematic illustration — not a micrograph" added to the cover |
| Q14 | cover (all languages) | Illustrative badge overlapped the tally labels; RU two-line subtitle touched the field ring | Field 760 px moved down, tally and badges re-spaced; thumbnails regenerated alone (`npm run render -- --thumbs-only`) |

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 112.6 s, AAC-LC 48 kHz mono (`OUTPUTS.md`).
* The first frame is busy: microscope field already panning (stage moving), tally strokes appearing, the sum
  flips to "97?" at ≈ 1.4 s; illustrative badge on screen.
* Every number is computed (sequence → tally → %, ×10⁹/L); the app frames show the same numbers because the
  walk tapped the same sequence (`MATH_APPENDIX.md` §4–5).
* Labels: "Schematic illustration — not a micrograph" on the field and cell scenes and both thumbnails;
  "Illustrative count — not a patient result" on hook, track, arithmetic scenes and thumbnails; "Real app
  screens · illustrative count" on every app scene.
* Subtitles: vertical 48 px (≥ 40 px), ≤ 2 rows per the calibrated check, plate bottom y = 1640 (above the
  Shorts/Reels UI); horizontal 44 px, left zone in phone scenes. Uzbek ‘ (U+2018) in o‘/g‘, ’ (U+2019) as
  tutuq belgisi; Russian «».
* No third-party logo or brand name (walk asserts it; deny list in the test); no music; no micrographs.

## Open items (not done)

* Listening review of the English synthetic voice (Kokoro `af_heart`) — **nobody has listened to it**.
* Expert review of the morphology drawings and wording (E7, E10, E11 in `CLAIMS_AND_EVIDENCE.md`) and native
  review of RU/UZ (several RU/UZ subtitles are now shorter than the English line — e.g. RU L10 drops the
  cytoplasm, which is still on the card).
* The long press (−1) is stated and shown in the app's own hint, but not filmed.
* Length 112.6 s (calibration: 91.6 s); a ≤ 60 s cut for Shorts/Reels was not made.
* Price/tier: the video says nothing about it; confirm how the counter is offered in the advertised build.
