# LabGuide overview — quality self-check (2026-10-26)

Method:
- Walk frames (`overview_walk_test.dart`, 2 walks × 3 languages) viewed as contact sheets for EN, UZ and RU; the new frames also viewed full size (EN).
- Remotion stills before the render: EN vertical (all scenes at 35 %, 50 %, 90 %), UZ horizontal (all scenes), EN horizontal (hook, what, roles, spec_a, spec_b, teach_b), thumbnails and covers (EN, UZ).
- Frames from the **final MP4s** with `node video_studio/scripts/qa_frames.mjs`: 60 % of every scene plus t = 0, 0.5 and 1.5 s.
  - Checked in full: **EN vertical** (all 12 scenes + hook moments) and **UZ horizontal** (all 12 scenes; hook, what, roles, teach_a, teach_b and end opened full size).
  - Spot check: **RU vertical** (scenes 3–12).
  - After the splice (below): `what` scene re-extracted from EN and UZ vertical.
- Subtitles: `subcheck.mjs` (≤ 17 chars/s) and `subrows.mjs` (rows per cue render); SRT gap scan.
- MP4 facts: ffprobe and `ebur128`.

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| O-Q1 | walk | The random "mixed" quiz drew questions whose source line names a publisher; the brand check failed the walk (flaky). | `walk_kit.snap(brandOk:)` for that one frame only, with a named `crop` mark that dims everything from the source line down (the video uses `crop: "crop"`). Publisher names stay off camera. |
| O-Q2 | walk | The glucose test card at an earlier scroll position showed the "Based on sources: …" note with publisher names. | Frame taken at a scroll position where the note is out of the viewport (brand check passes). |
| O-Q3 | subtitles | First voice pass: EN 18.8, RU 20.4, UZ 19.9 chars/s and 11 cue renders with 3 rows in the vertical edition. | Shortened 2 EN and about 16 RU/UZ lines (EN audio re-synthesised, 113.7 s); `cueMax` for 7 long lines. Now EN 17.0, RU 16.9, UZ 16.5 chars/s; 0 of 210 cue renders > 2 rows. |
| O-Q4 | stills: hook, vertical | The labelled file sheet overlapped the headline; the chat bubbles collided with the calculator and the subtitle plate; the labelled sheet was clipped by the canvas edge in horizontal. | Objects re-placed around the headline and above the subtitle plate; headline moved up in vertical. |
| O-Q5 | stills: what/roles, horizontal | The language trio sat under the left-aligned subtitle zone; the role labels collided with the subtitle plate. | Phones narrowed and moved right (`subZone: left`); role phones raised and slightly smaller. |
| O-Q6 | final MP4: what, vertical | The "Русский" language chip was clipped at the top of the phone mask and touched the pills row. | Phones moved down inside a taller mask, pills moved up. **Spliced** into the three vertical MP4s (frames 285–655, `splice.mjs`; length unchanged at 113.67 s), re-checked on EN and UZ. |
| O-Q7 | design | `e_result` (calculators) with a named crop left a mostly dark phone. | Crop removed (nothing needing a crop is visible), result highlighted by its mark instead. |

## Checked and OK

* **ffprobe (all six):** H.264 High, yuv420p, 30 fps, 113.67 s, AAC-LC 48 kHz mono (`OUTPUTS.md`).
* **Loudness:** −16.2 LUFS integrated, peak −2.0 dBFS (EN vertical, UZ horizontal, RU vertical). Narration WAV target was −16 LUFS / −2.4 dBTP before AAC.
* **Hook:** the headline is on screen from t = 0; files, chat bubbles and the calculator fly in during the first 0.5 s (scattered files fill the frame by 0.5 s); the subtitle starts at 0.25 s.
* **Subtitles:** 35 / 36 / 34 cues (EN/RU/UZ); at most 2 rows in every render; all cues sit inside the safe zone (vertical subtitle plate above the bottom 15 %). Gaps between cues over 0.45 s occur only at scene boundaries where the narration pauses (at 24.9, 56.8, 66.1, 85.3 and 105.4 s).
* **Language on screen:** EN/RU/UZ kickers, callouts, pills, badges and the end note appear in the edition's language; the app frames follow the edition language (the "three languages" scene deliberately shows UZ, RU and EN homes in every edition). UZ text uses ‘ ’ (no ASCII apostrophe: `normalize_uz_apostrophes.py --check` clean; no apostrophe in `lines.uz.json`). No «референс…» in any RU text.
* **Labels:** "Real app screens" on every app scene; "· sample values" where control/calibration/count data appear; "· demo class data" on the class and assigned-test scenes. Disclosure on the end card: reference and learning aid, does not diagnose, content under expert review.
* **No brand names / third-party marks:** the walk's deny-list check passed on every new frame; sources are never on camera; the hook uses invented generic objects; no store badges, links, prices or "Pro" wording anywhere (grep of all three language packs).
* **Real vs generated:** every number inside a phone is the app's own output for illustrative inputs; the video adds none.
* **Thumbnails and covers:** EN and UZ (and RU thumbnail) opened; text fits, phones overlap deliberately.
* **Tests:** `python3 -m unittest discover -s tool/publish` — 53 tests OK (REQUIRED_IDS, verified list and the "paid topics last" test were updated for the new topic; `overview` is first in the schedule).

## Known, not fixed (minor)

* Subtitle plates sit over the lower part of the phone in the vertical edition (the phone fades out under them), as in the flagship videos.
* In horizontal role scenes a dimmed second phone (the neighbouring shot) sits behind the main phone on purpose; on the first shot of the very first role scene it shows the next frame.
* The quiz frame is a random draw of the app (a different question in every language walk).
* The exam result frame shows the app's own "Good result!" wording for an illustrative 4/5 run.
* EN L16 and UZ L22 are at 17.0–17.2 chars/s (limit 17): readable, borderline.
* Frames of earlier videos (calibration, qc, leukocyte, calculators, photometry) were reused unchanged; they come from the same app commit.

## Open items

* Listening review of the English synthetic voice: **nobody has listened to it.** `spoken` respellings (e.g. "Levvy Jennings", "West-gard", "Lab Guide") are unverified by ear.
* Expert review of the app content shown (test-card thresholds, QC rules text, protocol slides) and of the video's wording.
* Native-speaker review of RU/UZ (subtitles, on-screen text, `topics.py` kit texts).
* The class server (code/QR, tests, results) was filmed with the app's fake server; **whether the real class server is deployed and reachable was not verified.**
* Remotion licence company-size check (owner).
