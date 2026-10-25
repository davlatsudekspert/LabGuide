# QUALITY CONTROL: LEVEY–JENNINGS + WESTGARD — topic video 2 of the second batch

Status: **EXPERT_REVIEW_PENDING** · audio: **English synthetic narration (Kokoro-82M, voice `af_heart`),
listening review pending** · RU/UZ editions = subtitles + on-screen text.

| File | What |
|---|---|
| `storyboard.json` | Scene graph (11 scenes); ONE illustrative control data set (2 levels, 12 runs designed by z), expected verdicts, rule-card patterns |
| `lines.{en,ru,uz}.json` | Narration / subtitles and on-screen texts |
| `SCRIPT.md`, `MATH_APPENDIX.md`, `OUTPUTS.md` | Generated (`npm run docs -- --id qc`); the appendix compares the video's rule engine, an independent Python re-implementation and the APP's own verdicts from the walk |
| `CLAIMS_AND_EVIDENCE.md`, `QA.md`, `DESCRIPTION.md` | Hand-written |

New reusable pieces: `src/lib/qc.js` (port of the app's `qc_rules.dart`), Levey–Jennings composition in
`src/videos/qc/layers.tsx` on top of the generic `Plot` (point shapes ● ▲ ■ as in the app).

Rebuild:

```sh
cd video_studio
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/qc_walk_test.dart --update-goldens)
npm run voice -- --id qc --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin> --tp -2.4
node scripts/subcheck.mjs --id qc
npm run render -- --id qc --lang all --format all
npm run docs -- --id qc
```
