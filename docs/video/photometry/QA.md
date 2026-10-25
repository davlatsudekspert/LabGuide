# Spectrophotometry — quality self-check (2026-10-25)

Method: Remotion stills while iterating (EN vertical, UZ horizontal, RU vertical spot checks), then frames
extracted from the **final MP4s** with `node video_studio/scripts/qa_frames.mjs` (one frame at 60 % of every
scene + t = 0, 0.5, 1.5 s) for **EN vertical**, **UZ horizontal** and **RU vertical**; frames viewed as
half-size contact sheets plus full-size frames for the hook and every fixed scene (beer, bss) after the
splice. App frames viewed as contact sheets (portrait + full-screen landscape slides). Subtitle speed/rows:
`node video_studio/scripts/subcheck.mjs --id photometry` against the real voice timing. ffprobe and
`ffmpeg -af ebur128=peak=true` on the MP4s (`OUTPUTS.md`). Arithmetic: `MATH_APPENDIX.md` (JS = Python).

## Problems found and fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| P-Q1 | walk | Deck slides opened with a spinner (pumpAndSettle timeout) | deck preloaded with `DeckCatalog.loadDeck` (as the app's own lecture tests) |
| P-Q2 | walk / brand | The first "10 %" slide match was the instrument slide whose source names a photometer brand → brand check failed | slide chosen by "10%" AND "90%" in one bullet (the absorbance slide); brand slides never opened |
| P-Q3 | app frames | Portrait slide renders were unreadably small (16:9 slide on a phone) | slides filmed in the app's own Full screen mode (the phone turns landscape, 844×390); `PhoneShotsLayer`/`PhoneFrame` now support landscape frames with a turn animation and a checklist under the phone in vertical |
| P-Q4 | walk / app | Pumping the whole app at 844×390 overflows the shell on `/learn/lecture` (app layout issue at landscape phone size, not filmed) | the walk rotates the view only after entering full screen, as a phone does |
| P-Q5 | subtitles | First voice pass: EN L03 17.7, L07 18.6, L08 18.3 chars/s; RU/UZ several 3-row cues | EN lines shortened (spoken text = subtitle), L03 given its own scene (continuous layer, no cross-fade); RU/UZ rewritten to ≤ 2 rows or two cues. Now EN 16.9, RU 16.7, UZ 16.6 |
| P-Q6 | EN L09 | 3 rows in the vertical plate ("÷ × the standard's concentration") | shortened to "… × C standard." |
| P-Q7 | beer (vertical, final MP4) | "A = ε·ℓ·c" pill overlapped the "linearity limit" label; "real reading" label crossed the curve | pill moved into the empty upper-left of the plot, limit label to the bottom, reading label above the dashed line |
| P-Q8 | bss (RU/UZ) | "known: 10.0 a.u." wrapped to 2–3 lines ("sh.\nb.") | wider reading column, no wrap |
| P-Q9 | ladder | "10^−A" written with a caret | real superscript |
| P-Q10 | CTA | Long menu path wrapped inside the pill | pill text size scales down for long paths (short flagship paths unchanged) |

P-Q7/P-Q8 were found in the final MP4s and fixed **without a full re-render**: `scripts/splice.mjs`
re-rendered only frames 630–1223 (beer + bss) and spliced them into all six MP4s (frame count verified equal,
narration re-muxed).

## Checked and OK

* ffprobe (all six): H.264 High, yuv420p, 30 fps, 69.63 s, AAC-LC 48 kHz mono (`OUTPUTS.md`).
* Loudness (EN vertical, UZ horizontal): −16.2 LUFS integrated, true peak −2.3 dBTP.
* Hook: first frame already busy (beam on, number rolling from the standard's 0.412 up to 1.52); subtitle at
  0.25 s.
* Every number is computed (`MATH_APPENDIX.md`), labels "Illustrative data — not a patient result" on every
  data scene and the thumbnails; "General principle" on the light-path scenes.
* No brand on screen (walk deny list incl. the photometer brand on deck slide 4 and reagent-kit makers).
* Subtitles: vertical 48 px, ≤ 2 rows per the calibrated check; horizontal left zone in phone scenes.

## Open items

* Listening review of the English synthetic voice — **nobody has listened to it**.
* Expert review: E5 (illustrated bend / "reads low"), single-standard calculation as the only model shown.
* Native review RU/UZ (several RU/UZ subtitles are shorter than the EN line).
* App observation (not fixed, read-only checkout): `/learn/lecture` overflows by 5 px when the whole app is
  laid out at 844×390 (landscape phone) — reported, not part of the video.
