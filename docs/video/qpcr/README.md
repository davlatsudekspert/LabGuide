# REAL-TIME PCR — topic video 4 of the second batch

Status: **EXPERT_REVIEW_PENDING** · audio: **English synthetic narration (Kokoro-82M, `af_heart`), listening
review pending** · RU/UZ = subtitles + on-screen text. Files as in the other topic videos.

Reuse: `SchematicTourLayer` (cycler parts; optical path drawn in the corrected order 4 → 5 → 6 → 7 → 8 with
a camera push-in), generic `Plot` (amplification curves, threshold, Cq), `PhoneShotsLayer` (named crops),
`CtaLayer`; walk on `labcard_kit.dart`.

```sh
cd video_studio
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/qpcr_walk_test.dart --update-goldens)
npm run voice -- --id qpcr --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin> --tp -2.4
node scripts/subcheck.mjs --id qpcr
npm run render -- --id qpcr --lang all --format all
npm run docs -- --id qpcr
```
