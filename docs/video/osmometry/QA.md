# Osmometry — quality self-check (2026-10-26)

Method:
- Remotion stills before the render: all scenes for EN vertical (at 15 % and 70 %), UZ horizontal (at 70 %), and EN vertical / RU horizontal (at 90 %) after the curve fixes.
- Frames from the **final MP4s** with `node video_studio/scripts/qa_frames.mjs`: 60 % of every scene, plus t = 0, 0.5 and 1.5 s. Checked for **EN vertical** and **UZ horizontal**, with a spot check of **RU vertical**.
- After the splice, the frames of the direction list were taken again: EN vertical at 39.8 / 40.5 / 41.5 s and UZ horizontal at 40.5 s.
- App frames from the walk viewed for all three languages.
- Subtitles: `subcheck.mjs` (chars/s) and `subrows.mjs` (exact rows with the 1.5 % margin).
- MP4 facts: ffprobe and `ebur128` (`OUTPUTS.md`).
- Thumbnails and covers for all three languages.
- Curve and calculator arithmetic: JS = Python (`MATH_APPENDIX.md`).

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| S-Q1 | walk | The result frame showed the input form again: the result title "Calculated osmolality" is also the screen title, and `bring()` took the title. | The walk brings the result panel (`LgPanel`) itself. |
| S-Q2 | subtitles (first voice pass) | EN L04 18.1, L06 17.6, L07 17.1 chars/s. RU and UZ had 3-row cues (L02, L04, L06–L09) and RU L05 19.8 / UZ L15 22.1 chars/s. | EN L04/L06/L07 shortened, plus TTS-only pauses in `spoken` (same words). RU/UZ lines shortened; `cueMax` for long lines. Now EN 17.0, RU 16.5, UZ 16.4 chars/s; 0 of 142 cue renders > 2 rows. |
| S-Q3 | stills: hook / result | The A/B labels sat at the curve ends, below the plot. The post-plateau decline left the plot. The two ΔT arrows and labels overlapped. | Letters sit above each plateau; the decline is gentler (k = 0.02); each ΔT arrow is inside its own plateau with its label to the right. |
| S-Q4 | stills: RU hook | «Плато ниже — почему?» wrapped before the dash. | A non-breaking space before the dash (all languages). |
| S-Q5 | final MP4, app scene | In the direction list the first visible line was "test": the wrapped tail of the HbA1c test row, scrolled under the header. | `crop: card` on `o_dir` (everything outside the osmometer row dimmed). Frames 1186–1501 spliced into all six MP4s. |

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 78.20 s, AAC-LC 48 kHz (`OUTPUTS.md`).
* Loudness: −16.1 LUFS integrated, true peak −2.2 dBTP (EN vertical, UZ horizontal).
* The hook shows both curves at t = 0, the question pops at 0.7 s, and the plateau lines and letters appear at about 1 s.
* No numbers on the freezing-curve axes.
* Labels:
  * "Illustrative curves — not a real sample or result" on every curve scene and on the thumbnails/covers;
  * "Schematic — not an exact model" on the tour;
  * "Real app screens · illustrative values" on the calculator scene.
* Calculator on screen: 290 mOsm/kg, gap 10 mOsm/kg = 2·140 + 5 + 5 and 300 − 290 (JS and Python agree).
* The card's source lines are dimmed (named crops). The walk's brand deny-list check passed: the list contains a third-party branded platform card below the osmometer row, and it is not in view.
* Every claim maps to `CLAIMS_AND_EVIDENCE.md` (O1–O16). The cryoscopic constant and reference intervals are deliberately not stated.

## Open items

* Listening review of the English synthetic voice: **nobody has listened to it**.
* Expert review:
  * principle-level wording of supercooling → stirring wire → plateau (lesson 24 PR, NEEDS_EXPERT);
  * all STANDARD_TEXTBOOK rows;
  * the app card itself (`expert_reviewed: false`).
* Native-speaker review of RU/UZ («криоскопический», «осмоляльный зазор»; «o‘ta sovish», «osmolyal farq»).
