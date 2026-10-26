# Laboratory calculators — quality self-check (2026-10-26)

Method:
- Remotion stills before the render: EN vertical, all scenes at 10 % and 70 %; UZ horizontal (hook, eGFR, end); RU vertical and EN horizontal hook after the formula fix.
- Frames from the **final MP4s** with `node video_studio/scripts/qa_frames.mjs`: 60 % of every scene, plus t = 0, 0.5 and 1.5 s.
  - Checked: **EN vertical** and **UZ horizontal**.
  - Spot check: **RU vertical**.
  - The eGFR scene was also checked at 24 / 27 / 30.5 s in EN vertical and UZ horizontal, because its 60 % frame falls in a shot cross-fade.
- Walk frames viewed for all three languages.
- Subtitles: `subcheck.mjs` and `subrows.mjs`.
- MP4 facts: ffprobe and `ebur128`.
- Thumbnails and covers.
- Arithmetic: app on screen = JS = Python (`MATH_APPENDIX.md`).

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| K-Q1 | walk | `Walk.bring` sent a drag shorter than the touch slop. Flutter treats that as a **tap**, so it opened the "Color index" row instead of scrolling the list. | `walk_kit.bring` skips drags ≤ 24 px. Shared kit: earlier walks only brought rows at the target position. |
| K-Q2 | walk | The "How to use?" sheet stayed open over the next routes; a mark with a Latin-only finder failed in RU. | The sheet is closed via its navigator; the mark was removed. |
| K-Q3 | walk | The dilution result mark took the screen subtitle "C₁V₁ = C₂V₂" (it also contains "V₁ ="). | Uses `.last` (the result line). |
| K-Q4 | subtitles | First voice pass: 3-row cues (EN L04, RU L02/L04/L05, UZ L05/L09/L10), UZ L05 21.4 chars/s. | RU/UZ L05 rewritten; `cueMax` set for long lines. Now EN 16.1, RU 15.7, UZ 16.6 chars/s; 0 of 102 cue renders > 2 rows. |
| K-Q5 | stills: hook | The formula wrapped inside "min(Scr/κ, 1)". | Each factor of the app's formula is kept on one line. |

No splice was needed: every fix was made before the final render.

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 63.97 s, AAC-LC 48 kHz (`OUTPUTS.md`).
* Loudness: −16.2 LUFS integrated, true peak −2.3 dBTP (EN vertical, UZ horizontal).
* Hook: the app's formula card is on screen from t = 0, the input pills appear by about 0.6 s, and "eGFR = ?" appears at about 1.9 s. The video computes no result.
* Results on screen (all computed by the app; `MATH_APPENDIX.md` agrees):
  * eGFR 95 mL/min/1.73 m², KDIGO G1;
  * under 18: refused;
  * glucose 90 mmol/L: unit check (the app still shows 375 mOsm/kg);
  * dilution V₁ = 20 mL.
* Labels:
  * "Illustrative inputs — not a patient" on the hook;
  * "Real app screens · illustrative values" on every scene with typed inputs and on the thumbnails;
  * "Real app screens" on the others.
* The source list under the eGFR formula stays outside the bright crop window. No brand names: the walk's deny-list check passed.

## Known, not fixed (minor)

* EN vertical L13: the plate wraps "C1·V1 = / C2·V2" at the "=". It is readable, and the subtitle text is correct.
* K4: the "17" is the count of rows in the list. One of them, "Color index", explains rather than calculates (`CLAIMS_AND_EVIDENCE.md`).

## Open items

* Listening review of the English synthetic voice: **nobody has listened to it**.
* Expert review of the app content shown (the eGFR limitations text, the KDIGO category) and of the video's wording.
* Native-speaker review of RU/UZ.
