# KALIBRLASH / CALIBRATION — flagship video (quality standard)

Status: **EXPERT_REVIEW_PENDING** · audio: **English synthetic narration (Kokoro-82M, voice `af_heart`),
listening review pending** · RU/UZ editions = burned-in + SRT/VTT subtitles and on-screen text in that language
(owner decision 2026-10-25).

| File | What |
|---|---|
| `storyboard.json` | Scene graph (13 scenes), timing rules, illustrative data (single source for the video and the docs) |
| `lines.en.json`, `lines.ru.json`, `lines.uz.json` | Narration (EN, + TTS respellings) / subtitles (RU, UZ) and on-screen texts |
| `SCRIPT.md` | Generated: per-scene script with the voice time windows, EN/RU/UZ side by side, on-screen text table |
| `MATH_APPENDIX.md` | Generated: data, least-squares sums, slope/intercept, R², residuals, control read-off |
| `CLAIMS_AND_EVIDENCE.md` | Every on-screen claim → code / test / doc evidence; epistemic table (SOURCED / STANDARD_TEXTBOOK / NEEDS_EXPERT) |
| `OUTPUTS.md` | Generated after rendering: ffprobe facts and sha256 of every MP4 / JPG / SRT / VTT |
| `QA.md` | Quality self-check: frames viewed, problems found and fixed, open items |
| `DESCRIPTION.md` | Draft description texts (EN/RU/UZ) with the synthetic-voice disclosure and Kokoro credit |

Sources of the visuals: the app's original schematic (`tool/illustrations/schematic/chemistry.svg`), an original
optical-bench cut-away and chart drawn in code, and **real app screens** rendered from the app with
`video_studio/flutter_walk/calibration_walk_test.dart` (custom "Demo" instrument — no third-party brand).

Rebuild (see `docs/video/STUDIO_README.md`):

```sh
cd video_studio
npm install
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/calibration_walk_test.dart --update-goldens)
npm run voice -- --id calibration --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin>
npm run render -- --id calibration --lang all --format all
npm run docs -- --id calibration
```
