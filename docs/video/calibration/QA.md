# Calibration flagship — quality self-check (2026-10-25)

Method: Remotion stills at chosen scene positions while iterating (`npm run still`), then frames extracted from
the **final MP4s** with ffmpeg at 60 % of every scene (13 scenes) and viewed at full size for
**EN vertical** and **UZ horizontal**; spot checks of UZ vertical, RU frames and every real app frame
(bottom strips checked for the brand notice). Encoding verified with ffprobe (`OUTPUTS.md`), loudness with
`ffmpeg -af ebur128`.

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| Q1 | app frames (walk) | First walk used a catalogue model → third-party brand name in the instrument title, and the app's brand-example notice (`calBrandWarning`, names two manufacturers) was visible under the reagent fields and, at the very bottom, in the approver-error frame | Custom neutral instrument "Demo / Photometer A"; the walk now pushes the notice out of the viewport before every snapshot and **asserts** it is not visible (test fails otherwise); snackbar frame taken at the top of the page and shown through a crop window |
| Q2 | app frames | Text caret / selection handle in the IFU field | Focus cleared before every snapshot |
| Q3 | app_rules / app_log / app_intro | Screens changed by fixed weights, so the voice talked about QC while the approver screen was shown | Shots carry `cue` (narration line index) and follow the voice |
| Q4 | calibrators | Row captions ("Assigned value, a.u.", "Signal: A") overlapped the numbers | Absolute row grid; spacing checked in vertical and horizontal |
| Q5 | fit / controls (vertical) | Equation panel covered calibrator points and the x-axis labels | Panel moved to the empty upper-left plot corner, fixed width, smaller equation font; chart made taller |
| Q6 | fit (horizontal) | Equation panel ran past the right edge | Fixed 600 px width in the side column |
| Q7 | residuals | Chips "✓ small / ✓ random sign / ✓ no trend" read as a verdict that was not computed | Chips now read "Look for: small · random sign · no trend" (criteria, no ticks) |
| Q8 | analyzer | Camera push-in clipped the monitor callout (8) at the right edge | Narrower schematic, smaller zoom |
| Q9 | phone (vertical) | Phone was small; subtitle plate sat on top of app content | Phone 600 px wide; the phone fades out under the subtitle zone |
| Q10 | phone (horizontal) | Phone covered the header badge; left half empty | Badge under the kicker; shot list (done / current / next) on the left; subtitles move to the left zone in phone scenes |
| Q11 | subtitles (ru/uz) | RU/UZ lines had to fit the English voice windows (up to 25 chars/s) | Translations shortened (RU L06, L10, L18; UZ L08, L10); every cue is held up to 0.9 s after the voice line (never into the next cue) |
| Q12a | audio | After AAC encoding the true peak was −1.4 dBTP (target ≤ −1.5) | WAV normalised to −2 dBTP (still −16 LUFS); audio re-muxed into all six MP4s without re-rendering (`npm run remux`); measured −16.1 LUFS / −2.0 dBTP in every MP4 |
| Q12 | render speed | 0.8 fps with `gl: 'swangle'` | Default GL: ~5.5–6 fps on this shared 4-core box |

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 91.6 s, AAC-LC 48 kHz mono; ebur128: −16.1 LUFS integrated, true peak −2.0 dBTP (`OUTPUTS.md`).

* Hook is legible from the first frame (number already on screen at frame 0, light beam moving).
* Every on-screen number is computed (`MATH_APPENDIX.md`; Python cross-check identical).
* "Illustrative data — not a patient result" visible in the hook, calibrators, all chart scenes and both thumbnails;
  "Schematic — not an exact model" in the analyzer scene; "General principle" on the light-path cut-away;
  "Real app screens · sample values" on every app scene; the app's own "Training record: this is not laboratory
  evidence." is visible in the record detail.
* Subtitles: vertical 48 px (≥ 40 px), max 2 rows, inside x 70–1010 and y ≤ 1640 (above the Shorts/Reels UI);
  horizontal 44 px. Uzbek uses ‘ (U+2018) in o‘/g‘ and ’ (U+2019) for the tutuq belgisi; Russian «».
* No third-party logo or brand name, no watermark, no music; the only logo is the owner's app icon.

## Open items (not done)

* Listening review of the English synthetic voice (Kokoro `af_heart`) — **nobody has listened to it**.
* Expert review of the science (E2 wording, E7, E9 in `CLAIMS_AND_EVIDENCE.md`) and native review of RU/UZ.
* Price/tier: the video says nothing about it; confirm how calibration is offered in the advertised build.
