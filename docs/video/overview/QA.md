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
| O-Q3 | subtitles | First voice pass: EN 18.8, RU 20.4, UZ 19.9 chars/s and 11 cue renders with 3 rows in the vertical edition. | Shortened 2 EN and about 16 RU/UZ lines (EN audio re-synthesised, 113.7 s); `cueMax` for 7 long lines. Now EN 17.0, RU 16.9, UZ 16.5 chars/s; 0 of 208 cue renders > 2 rows. |
| O-Q4 | stills: hook, vertical | The labelled file sheet overlapped the headline; the chat bubbles collided with the calculator and the subtitle plate; the labelled sheet was clipped by the canvas edge in horizontal. | Objects re-placed around the headline and above the subtitle plate; headline moved up in vertical. |
| O-Q5 | stills: what/roles, horizontal | The language trio sat under the left-aligned subtitle zone; the role labels collided with the subtitle plate. | Phones narrowed and moved right (`subZone: left`); role phones raised and slightly smaller. |
| O-Q6 | final MP4: what, vertical | The "Русский" language chip was clipped at the top of the phone mask and touched the pills row. | Phones moved down inside a taller mask, pills moved up. **Spliced** into the three vertical MP4s (frames 285–655, `splice.mjs`; length unchanged at 113.67 s), re-checked on EN and UZ. |
| O-Q7 | wording rule | The calculators eGFR frame shows «KDIGO GFR toifasi» in Uzbek; the owner's rule keeps the word «toifa» out of the video. | Replaced by the osmometry calculator result frame (`c_result`), highlighted by its mark. |

## Change after the first render (owner decision 2026-10-26: category-assessment practice for all languages, countries and roles)

* L12 (EN/RU/UZ) is now region-neutral and role-neutral and stays in the specialist block: EN "Specialists can also practise for the qualification category assessment." (spoken with a short pause so the subtitle stays ≤ 17 chars/s), RU «Специалист может готовиться и к проверке знаний на категорию.», UZ «Mutaxassis bilim va malakani baholashga ham tayyorlanishi mumkin.»
* The on-screen pill "Shown for Uzbekistan" (`chUz`) was removed from all packs and the storyboard.
* The narration was re-synthesised; only L12 and L13 moved (< 0.07 s) and the scene boundaries and total length (113.67 s) are unchanged, so the frames of the changed scene (`spec_d`, frames 1745–2015) were re-rendered and spliced into all six MP4s with the full new narration track re-muxed; SRT/VTT regenerated. Subtitles re-checked: EN 17.0, RU 16.9, UZ 16.5 chars/s; 0 of 208 cue renders over 2 rows.
* Final-MP4 frames of `spec_d` re-extracted and viewed (see "Checked and OK").

## Second round (owner rules, 2026-10-26): wording, recaptured frames, 3D hook

* **Wording rule:** the word «toifa» and the words "bank/банк" must not be visible or audible. Grep over `lines.*.json`, `DESCRIPTION.md`, `SCRIPT.md`, the `overview` kit texts, all SRT/VTT and the video source: no hit (the internal frame id `toifa_hub` and the file name `toifa_bank.dart` mentioned in CLAIMS_AND_EVIDENCE.md are identifiers, not shown). The app-side rename is commit ecfe87a on the owner's separate app branch: every frame of the two walks was **re-captured from that commit** (the walk ran from that checkout; same harness) and the frames' captured texts were grepped (no «toifa», no "bank"); OCR of the Uzbek frames showing the section found none; the level chips now read "3–2-kategoriya / 1-kategoriya". The reused frames of earlier videos were OCR-checked only for the Uzbek set (no «toifa»); the RU/EN reused frames were not OCR-checked for "bank".
* The eGFR calculator frame (Uzbek text «KDIGO GFR toifasi») was replaced by the osmolality calculator frame.
* **3D hook:** new `hero3d.tsx` (CSS 3D phone with a real app frame, glossy SVG test tubes / beaker / flask / microscope silhouette, app icon with a glint) used in the hook, the thumbnail and the cover. Checked on final MP4 frames at 0, 0.5, 1, 1.5, 2, 3, 4.5, 6, 7, 7.6, 8.2 and 9 s for EN vertical and UZ horizontal: no blank frame, strong motion from t = 0, subtitles do not overlap the phone or the objects.
* **Known defect in the delivered MP4s:** in the hook, the right chat bubble is partly hidden by the phone in the vertical edition (first letters of "Anyone have the thresholds?") and one bubble is partly covered by a sheet in the horizontal edition. The fix (bubbles drawn above the phone) is in the source; re-splicing frames 0–315 failed because the disk was full, so the MP4s still show the earlier z-order unless the splice was re-run (see OUTPUTS.md hashes).

## Checked and OK

* **ffprobe (all six):** H.264 High, yuv420p, 30 fps, 113.67 s, AAC-LC 48 kHz mono (`OUTPUTS.md`).
* **Loudness:** −16.2 LUFS integrated, peak −2.0 dBFS (EN vertical, UZ horizontal, RU vertical). Narration WAV target was −16 LUFS / −2.4 dBTP before AAC.
* **Hook:** the headline is on screen from t = 0; files, chat bubbles and the calculator fly in during the first 0.5 s (scattered files fill the frame by 0.5 s); the subtitle starts at 0.25 s.
* **Subtitles:** 34 / 36 / 34 cues (EN/RU/UZ); at most 2 rows in every render; all cues sit inside the safe zone (vertical subtitle plate above the bottom 15 %). Gaps between cues over 0.45 s occur only at scene boundaries where the narration pauses (at 24.9, 56.8, 66.1, 85.3 and 105.4 s).
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
* Frames of earlier videos (calibration, qc, leukocyte, osmometry, photometry) were reused unchanged; they come from the same app commit.

## Open items

* Listening review of the English synthetic voice: **nobody has listened to it.** `spoken` respellings (e.g. "Levvy Jennings", "West-gard", "Lab Guide") are unverified by ear.
* Expert review of the app content shown (test-card thresholds, QC rules text, protocol slides) and of the video's wording.
* Native-speaker review of RU/UZ (subtitles, on-screen text, `topics.py` kit texts).
* The class server (code/QR, tests, results) was filmed with the app's fake server; **whether the real class server is deployed and reachable was not verified.**
* Remotion licence company-size check (owner).
