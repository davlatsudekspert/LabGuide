# GC-MS — topic video 3 of the second batch

Status: **EXPERT_REVIEW_PENDING** · audio: **English synthetic narration (Kokoro-82M, `af_heart`), listening
review pending** · RU/UZ = subtitles + on-screen text.

Files as in the other topic videos (`storyboard.json`, `lines.*.json`, generated `SCRIPT.md` /
`MATH_APPENDIX.md` (data appendix: the panels are illustrative, no numbers on screen) / `OUTPUTS.md`,
hand-written `CLAIMS_AND_EVIDENCE.md`, `QA.md`, `DESCRIPTION.md`).

Reuse: generic `SchematicTourLayer` (two tours of the app's original `mass_spec_gc` schematic with drawn flow
paths), `SchematicStage` with a new `overlay` (zoomed column and quadrupole), generic `Plot` (chromatogram,
stick spectrum), `PhoneShotsLayer` (crops by measured mark name), `CtaLayer`. Walk: `flutter_walk/
gcms_walk_test.dart` on the shared `labcard_kit.dart` (also used by the PCR and osmometry videos).

```sh
cd video_studio
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/gcms_walk_test.dart --update-goldens)
npm run voice -- --id gcms --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin> --tp -2.4
node scripts/subcheck.mjs --id gcms
npm run render -- --id gcms --lang all --format all
npm run docs -- --id gcms
```
