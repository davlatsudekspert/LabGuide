# OSMOMETRY — topic video 5 of the second batch

**Status:** EXPERT_REVIEW_PENDING.
**Audio:** English synthetic narration (Kokoro-82M, `af_heart`). Listening review pending.
**RU/UZ:** subtitles and on-screen text only.

The files follow the other topic videos: `storyboard.json`, `lines.*.json`, the generated `SCRIPT.md`, `MATH_APPENDIX.md` and `OUTPUTS.md`, and the hand-written `CLAIMS_AND_EVIDENCE.md`, `QA.md` and `DESCRIPTION.md`.

**Story.** A lower freezing plateau is the hook. Then:
1. the app's osmometer schematic, five numbered parts;
2. the freezing curve: supercooling → stirring wire → plateau;
3. depression → osmolality, mOsm/kg vs mOsm/L;
4. in LabGuide: the osmometer card (schematic, parts, specimens, limitations, errors);
5. the app's calculated-osmolality calculator: the app computes the osmolal gap from illustrative inputs.

The CTA is "measured or calculated — know which one you read".

**Reuse.** `SchematicTourLayer`, the generic `Plot` (new `FreezePlot` on top of it), `PhoneShotsLayer` (named crops; new per-scene `badge` key) and `CtaLayer`. The walk is built on `labcard_kit.dart`, plus a calculator step.

```sh
cd video_studio
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/osmometry_walk_test.dart --update-goldens)
npm run voice -- --id osmometry --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin> --tp -2.4
node scripts/subcheck.mjs --id osmometry && node scripts/subrows.mjs --id osmometry
npm run render -- --id osmometry --lang all --format all
npm run docs -- --id osmometry
```
