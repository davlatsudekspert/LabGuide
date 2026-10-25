# Quality control (Levey–Jennings + Westgard) — quality self-check (2026-10-25)

Method: Remotion stills while iterating (EN vertical all scenes, UZ horizontal 6 scenes), then frames from
the **final MP4s** with `node video_studio/scripts/qa_frames.mjs` (60 % of every scene + t = 0, 0.5, 1.5 s)
for **EN vertical**, **UZ horizontal** and **RU vertical**, viewed as contact sheets; full-size re-check of
the fixed hook and 1-2s scenes after the splice. Subtitles: `node video_studio/scripts/subcheck.mjs --id qc`.
ffprobe + `ebur128` on the MP4s. Verdicts: video JS engine = independent Python = the app's own verdicts
from the walk (`MATH_APPENDIX.md` §2).

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| Q-Q1 | walk | The new-test form is a lazy list: only 5 of 10 fields built at 844 px | form filled in a tall view (as the app's own QC test), frame taken at phone size |
| Q-Q2 | walk | `bring()` with `.first` finders threw on unbuilt widgets / multiple matches | `walk_kit.bring` now drags until the widget is built (down, then up) |
| Q-Q3 | brand | The app's "copied" snackbar names two spreadsheet products | frame taken just before the tap; both names added to the deny list |
| Q-Q4 | subtitles | First voice pass: 8 RU and 7 UZ cues wrapped to 3 rows, UZ L02 19.2 chars/s | RU/UZ rewritten; now EN 16.7, RU 16.5, UZ 16.2 chars/s, ≤ 2 rows |
| Q-Q5 | final MP4, vertical | "1-2s" wrapped at the hyphen ("1-" / "2s") in the burned-in subtitle | the plate renders rule codes with a non-breaking hyphen (U+2011); SRT/VTT keep the plain hyphen |
| Q-Q6 | final MP4 | Kicker "THE 1-2S RULE": the uppercase style turned "s" into "S" | kicker reworded ("One value beyond 2 SD"; RU/UZ likewise) |
| Q-Q7 | final MP4, vertical hook | Illustrative badge sat on the top edge of the subtitle plate | badge moved to the top of the frame |
| Q-Q8 | final MP4, horizontal | Long targets note (UZ/RU) ran off the right edge (one-line badge) | `Badge` got an optional `maxWidth` (wraps) |
| Q-Q9 | splice (all six) | The first splice passed `--no-subs` to the renderer, which also switches the burned-in subtitle plate off: frames 0–905 (hook … 1-2s, ≈ 0–30 s) had no subtitles | `splice.mjs` fixed (no `--no-subs`); frames 0–905 re-spliced; subtitles checked in the final MP4s |

Q-Q5…Q-Q8 were fixed with `scripts/splice.mjs` (frames 0–905 = hook … 1-2s scene re-rendered and spliced
into all six MP4s; frame count verified, narration re-muxed) — no full re-render.

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 79.70 s, AAC-LC 48 kHz (`OUTPUTS.md`).
* Loudness: −16.3 LUFS integrated, true peak −2.3 dBTP (EN vertical, UZ horizontal).
* Hook: chart already drawn at t = 0 (runs 1–5), run 6 pops above +2 SD at ≈ 0.5 s, "+2.3 SD" at ≈ 0.6 s.
* Every point/verdict/statistic computed; the app's verdicts equal the video's (12/12 runs).
* Point shapes as in the app (● accepted ▲ warning ■ rejected), labels "Illustrative control data — not a real
  lot" on every data scene and thumbnails; "Real app screens · illustrative data" on app scenes.

## Open items

* Listening review of the English synthetic voice — **nobody has listened to it**.
* Expert review: card paraphrases of the rule texts (E3); the app's stricter-than-1981 handling of 1-2s is
  shown as the app's behaviour, not as the only Westgard practice.
* Native review RU/UZ («Вестгард» transliteration; UZ «seriya», «siljish»).
