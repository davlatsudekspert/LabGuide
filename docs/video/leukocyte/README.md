# LEYKOFORMULA / LEUKOCYTE DIFFERENTIAL COUNT — flagship 2

Status: **EXPERT_REVIEW_PENDING** · audio: **English synthetic narration (Kokoro-82M, voice `af_heart`),
listening review pending** · RU/UZ editions = burned-in + SRT/VTT subtitles and on-screen text in that language
(owner decision 2026-10-25). Same framework and quality bar as flagship 1 (`docs/video/calibration/`).

| File | What |
|---|---|
| `storyboard.json` | Scene graph (12 scenes), timing rules, the ONE illustrative 100-cell tally (`data.sequence`, WBC) used by the video AND tapped into the app by the walk test |
| `lines.en.json`, `lines.ru.json`, `lines.uz.json` | Narration (EN, + TTS respellings) / subtitles (RU, UZ) and on-screen texts (cell names and features follow the app's own `cellGuides` wording) |
| `SCRIPT.md` | Generated: per-scene script with the voice time windows, EN/RU/UZ side by side, on-screen text table |
| `MATH_APPENDIX.md` | Generated: counts, %, absolute counts, running tally; independent Python cross-check; the app's own numbers and copied text from the walk |
| `CLAIMS_AND_EVIDENCE.md` | Every on-screen claim → code / test / doc evidence; imagery licences; epistemic table (SOURCED / STANDARD_TEXTBOOK / NEEDS_EXPERT) |
| `OUTPUTS.md` | Generated after rendering: ffprobe facts and sha256 of every MP4 / JPG / SRT / VTT |
| `QA.md` | Quality self-check: frames viewed, problems found and fixed, open items |
| `DESCRIPTION.md` | Draft description texts (EN/RU/UZ) with the synthetic-voice disclosure and credits |

Visuals: **original schematic illustrations** drawn in code (`video_studio/src/components/Cells.tsx` — six
leukocytes and red cells to one µm scale, Romanowsky-type colours; `MicroscopeField.tsx` — a procedural
monolayer film under an eyepiece reticle, the stage moving along a battlement track), and **real app screens**
rendered from the free app with `video_studio/flutter_walk/leukocyte_walk_test.dart` (the walk taps the
storyboard's sequence into the real counter, Microscope mode included, and records the app's own result).
No micrographs are used (see `CLAIMS_AND_EVIDENCE.md` §2).

Rebuild (see `docs/video/STUDIO_README.md`):

```sh
cd video_studio
npm install
(cd /home/user/wt-audit && flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
   /home/user/wt-video/video_studio/flutter_walk/leukocyte_walk_test.dart --update-goldens)
npm run voice -- --id leukocyte --python <venv>/bin/python --model <kokoro.onnx> --voices <voices.bin>
node scripts/subcheck.mjs --id leukocyte          # subtitle speed ≤ 17 chars/s, ≤ 2 rows
npm run render -- --id leukocyte --lang all --format all
npm run docs -- --id leukocyte
python3 -I scripts/crosscheck_leukocyte.py ../docs/video/leukocyte/storyboard.json public/frames/en/leukocyte/frames.json
```
