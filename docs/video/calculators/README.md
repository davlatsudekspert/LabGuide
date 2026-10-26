# LABORATORY CALCULATORS — topic video 6 of the second batch (overview)

**Status:** EXPERT_REVIEW_PENDING.
**Audio:** English synthetic narration (Kokoro-82M, `af_heart`). Listening review pending.
**RU/UZ:** subtitles and on-screen text only.

The files follow the other topic videos: `storyboard.json`, `lines.*.json`, the generated `SCRIPT.md`, `MATH_APPENDIX.md` and `OUTPUTS.md`, and the hand-written `CLAIMS_AND_EVIDENCE.md`, `QA.md` and `DESCRIPTION.md`.

**Story.**
* **Hook:** the app's own CKD-EPI 2021 formula with illustrative inputs and "eGFR = ?", plus the unit-conversion trap.
* **Then, all real app frames:**
  1. Lab → Calculators (17 rows);
  2. "How to use?";
  3. eGFR: empty form, the "choose sex" check, and the result with its KDIGO category and the entered values;
  4. formula and limitations;
  5. the under-18 refusal and the glucose-90 unit check;
  6. SI or conventional units in Profile;
  7. dilution C₁V₁ = C₂V₂.
* **CTA:** "It calculates — you interpret."

**Reuse.** `PhoneShotsLayer` (named crops, per-scene badge) and `CtaLayer`; a new small `FormulaCard` for the hook. The walk is `flutter_walk/calculators_walk_test.dart`, built on `walk_kit.dart`.

```sh
cd video_studio
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/calculators_walk_test.dart --update-goldens)
npm run voice -- --id calculators --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin> --tp -2.4
node scripts/subcheck.mjs --id calculators && node scripts/subrows.mjs --id calculators
npm run render -- --id calculators --lang all --format all
npm run docs -- --id calculators
```
