# SPECTROPHOTOMETRY — topic video 1 of the second batch

Status: **EXPERT_REVIEW_PENDING** · audio: **English synthetic narration (Kokoro-82M, voice `af_heart`),
listening review pending** · RU/UZ editions = burned-in + SRT/VTT subtitles and on-screen text in that
language. Same framework and quality bar as the flagships (`docs/video/calibration/`, `docs/video/leukocyte/`).

| File | What |
|---|---|
| `storyboard.json` | Scene graph (11 scenes), timing rules, ONE illustrative data set (standard, sample, high sample, illustrative linearity limit) |
| `lines.en.json`, `lines.ru.json`, `lines.uz.json` | Narration (EN, + TTS respellings) / subtitles (RU, UZ) and on-screen texts; app path names copied from the app's ARB |
| `SCRIPT.md` | Generated: per-scene script with the voice time windows, EN/RU/UZ side by side |
| `MATH_APPENDIX.md` | Generated: every number on screen, JS vs independent Python (`scripts/crosscheck_photometry.py`) |
| `CLAIMS_AND_EVIDENCE.md` | Every on-screen claim → app text / lecture slide / code; epistemic table |
| `OUTPUTS.md` | Generated after rendering: ffprobe facts and sha256 |
| `QA.md` | Quality self-check |
| `DESCRIPTION.md` | Draft description texts (EN/RU/UZ) with the synthetic-voice disclosure and credits |

Reuse (no new per-language scenes): `OpticalBench`/`Cuvette` (calibration), generic `Plot` (new, shared by
the batch), `PhoneShotsLayer` (now also landscape phone frames: the lecture's full-screen mode turns the phone),
`CtaLayer`. Layers: `video_studio/src/videos/photometry/`.

Rebuild:

```sh
cd video_studio
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/photometry_walk_test.dart --update-goldens)
npm run voice -- --id photometry --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin> --tp -2.4
node scripts/subcheck.mjs --id photometry
npm run render -- --id photometry --lang all --format all
npm run docs -- --id photometry
```
