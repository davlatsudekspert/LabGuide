# LABGUIDE OVERVIEW — why the specialist, the teacher and the student use it

**Status:** EXPERT_REVIEW_PENDING.
**Audio:** English synthetic narration (Kokoro-82M, `af_heart`). Listening review pending.
**RU/UZ:** subtitles and on-screen text only (owner decision 2026-10-25).
**Length:** about 114 s (target 110–150 s). Formats: 16:9 1920×1080 and 9:16 1080×1920, thumbnail 1280×720, cover 1080×1920, SRT/VTT, for en / ru / uz.

The files follow the other topic videos: `storyboard.json`, `lines.*.json`, the generated `SCRIPT.md` and `OUTPUTS.md`, and the hand-written `CLAIMS_AND_EVIDENCE.md`, `QA.md` and `DESCRIPTION.md`. There is no `MATH_APPENDIX.md`: the video computes nothing.

**Story (12 scenes).**
1. **hook** — original motion graphics: files, chat bubbles and a calculator fly in; "Where did I save it?".
2. **what** — one app, three languages (the same home screen in uz / ru / en); works offline, no account needed, no ads or tracking.
3. **roles** — the home screen follows the role (specialist, teacher, student).
4. **spec_a–d, specialist** — test cards (units, guideline thresholds, cited sources), calculators, Levey–Jennings + Westgard, calibration record, differential counter, instrument catalog and atlases, category-assessment practice (Uzbekistan), records stay on the phone.
5. **teach_a–b, teacher** — lecture slides and practical protocols (full screen), class with code and QR, lecture test with per-student questions, results by student and by question.
6. **stud_a–b, student** — Learn tab, daily five, explained quiz, timed practice exam with mistakes review, an assigned test on the home screen.
7. **end** — "One app for the specialist, the teacher and the student." and the disclosure note.

**Reuse.** Layers `hook`, `what`, `roles`, `role` are new (`video_studio/src/videos/overview/layers.tsx`); they use the shared `PhoneFrame`, `Pill`, `Badge`, the `shotWindows` helper of `PhoneShots` and the flagship `CtaLayer`. App frames: the new `flutter_walk/overview_walk_test.dart` (two walks per language) plus frames reused from the calibration, qc, leukocyte, calculators and photometry walks (`scripts/overview_frames.py`, list in `storyboard.json → data.reuse`).

**Honesty notes (details in `CLAIMS_AND_EVIDENCE.md`).**
* The category-assessment practice is shown for the **specialist**: the app hides it from the student and physician roles.
* The test cards give guideline thresholds on some cards and **no** laboratory reference intervals; the narration never says "reference ranges" about the app.
* Class screens are filmed with the app's widget-test fake server: demo data.

```sh
cd video_studio
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/overview_walk_test.dart --update-goldens)
python3 scripts/overview_frames.py
npm run voice -- --id overview --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin> --tp -2.4
node scripts/subcheck.mjs --id overview && node scripts/subrows.mjs --id overview
npm run render -- --id overview --lang all --format all
npm run docs -- --id overview
```
