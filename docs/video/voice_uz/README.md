# Uzbek voice-over for the existing LabGuide videos

Status: **pipeline prepared, nothing synthesised.** No TTS service was called, no key exists, nobody has listened to
anything, no video was rendered. Every Uzbek text, respelling and suggestion here is **NEEDS_NATIVE_REVIEW**.

Videos: `overview`, `calibration`, `qc`, `photometry`, `osmometry`, `leukocyte`, `calculators`, `gcms`, `qpcr`
(163 narration lines in total).

## 1. What is in the repository

| What | Where |
|---|---|
| Scene-by-scene plan per video (timing, Uzbek text, TTS-ready text, fit verdict, suggestions) | `docs/video/<id>/voice_uz/plan.json` and `plan.csv` |
| Pronunciation glossary per video (term, written, spoken respelling, risk) | `docs/video/<id>/voice_uz/pronunciation_uz.csv` |
| Fit summary for all videos (estimates) | `docs/video/voice_uz/FIT_SUMMARY.md` / `.json` |
| First sample for the owner's ears (3 lines) | `docs/video/voice_uz/SAMPLE_TEXT.txt` |
| Hand-written SHORTER wordings, used only for TOO_LONG lines | `docs/video/voice_uz/suggestions_uz.json` |
| Lines with `{placeholders}` resolved like the renders do | `docs/video/voice_uz/resolved_lines.json` (from `video_studio/scripts/dump_resolved_lines.mjs`) |
| Text preparation (abbreviations, terms, numbers, symbols -> spoken Uzbek) | `tool/tts/uz_prep.py` |
| Plan builder (re-run after any text or rate change) | `tool/tts/plan_uz.py` |
| Synthesis + fitting + timeline + loudness + report | `tool/tts/synth_uz.py` |
| Swap the audio of finished MP4s without re-rendering | `tool/tts/remux_uz.py` |
| Offline tests (fake provider, fake HTTP) | `tool/tts/test_synth_uz.py` |

## 2. How the plans are built (read this before trusting any number)

* **Timeline.** The existing renders use the English narration timing (`video_studio/public/audio/en/<id>.timing.json`);
  scene boundaries follow it (`layoutScenes` in `video_studio/src/lib/timing.js`, ported in `plan_uz.py`). The Uzbek track
  therefore has to keep the **same total length** and start every line where the English line starts.
* **Available time of a line** = from the line start to the next line's start minus 0.10 s; for the last line of a scene
  to the scene end minus 0.05 s; for the last line of the video to the end minus 0.10 s. `hard_end_s` = next line start
  minus 0.02 s (the absolute limit).
* **Estimated speech duration = characters of the TTS-ready text / 13 characters per second.** This rate is an
  **assumption** (typical for neural TTS in Uzbek), **not measured**; the plans also store a 11 / 15 chars/s band. The
  real rate comes from the sample (section 4). Re-run `python3 tool/tts/plan_uz.py --rate <measured>` afterwards.
* **Verdict.** `OK` = fits within +12 % tempo (ffmpeg atempo). `TOO_LONG by X s` = X seconds still do not fit after the
  maximum +12 % tempo. `TOO_SHORT` = estimated speech below 60 % of the English clip (it is padded with silence; informational).
* **Suggested shorter text** exists only for TOO_LONG lines, marked `SUGGESTED`; it keeps the statement and drops or
  tightens words (no new claims). Where no wording was found that keeps the meaning the entry says
  `NO_SAFE_SHORTENING`. Residual TOO_LONG lines after the suggestions are listed in `FIT_SUMMARY.md`.
  If a suggestion is adopted, `lines.uz.json` must be changed too, otherwise the burned-in subtitle shows the long text.
* **TTS-ready text** (`text_tts`): abbreviations and Latin terms respelled the way an Uzbek reader would say them
  (GC-MS, qPCR, eGFR, QC, Levey–Jennings, Westgard, SD, IFU ...), units and numbers in words (mmol/L, percent, decimals as
  "ikki vergul uch"), Westgard rule names, symbols (= ÷ × + → ~), hyphenated numerals as ordinals (22-siklda). Em dashes
  become commas (pauses). Apostrophes o‘ g‘ (U+2018) and tutuq (U+2019) are kept as in `lines.uz.json`.
  Dates: none occur in these scripts; `uz_prep.py` does **not** expand dates and raises a warning if one appears.
* Azure `uz-UZ` voices support **neither SSML `<phoneme>` nor custom lexicons** (Microsoft Learn, language-support table,
  read 2026-10-31); respelling plain text is the only pronunciation lever, so every respelling is a guess until heard.
* **One source word was replaced for the voice** (calculators L08, noted in its plan line): `lines.uz.json` contains a word
  from the owner's banned list there (and in the on-screen key `coResult`); the voice text uses the loanword
  "kategoriyasi". Fix the source subtitle and the on-screen key too (needs a splice/re-render of that scene).

## 3. Keys and prices: what the owner does

### Azure Speech (alternative provider)

Verified from Microsoft's official pages on 2026-10-31 (please re-check, these numbers move):

* Voices: `uz-UZ-MadinaNeural` (female), `uz-UZ-SardorNeural` (male), Standard tier (language-support page).
* Free (F0) pricing tier: **0.5 million neural TTS characters per month free** (Azure pricing page). The S0 price per
  character could not be read from the pricing page text; the quotas page uses **$15 per million characters** in a
  worked example. A full run of all nine videos sends about **10 000 characters**; the sample about **220** (x3 for
  the apostrophe variants).
* F0 real-time TTS: **20 transactions per 60 seconds**, not adjustable; max 10 minutes of audio per request; **batch
  synthesis is not available on F0** (quotas page, updated 2026-10-23). The tool waits 3.2 s between requests.
* REST endpoint `https://<region>.tts.speech.microsoft.com/cognitiveservices/v1`, output header
  `riff-48khz-16bit-mono-pcm` (48 kHz high-fidelity voice model is invoked for 48 kHz output).

Azure steps (the owner, in their own Azure account - nobody else creates this):

1. portal.azure.com -> create resource **Speech** (Azure AI Speech), pricing tier **Free F0**, pick a region
   (e.g. `westeurope`); check that region lists `uz-UZ` voices (not verified by us).
2. Resource -> **Keys and Endpoint** -> `KEY 1` and the **Location/Region**.
3. Put them **only** into the cloud environment: environment menu in the session title bar -> **Edit** -> **Network
   secrets** (named "API credentials" in older apps) or, where that section is missing, environment variables, with exactly
   these names: `AZURE_SPEECH_KEY` and `AZURE_SPEECH_REGION`. **Never paste the key into the chat**, a file or a commit.
   A new session picks them up.
4. In the same Edit dialog, Network access must allow the host `<region>.tts.speech.microsoft.com` (for example
   `westeurope.tts.speech.microsoft.com`) under Allowed domains; otherwise the proxy blocks the call.
5. The tool never prints or logs the key (tests check that), counts characters locally
   (`~/.labguide_tts_azure_usage.json`) and refuses above 450 000 characters per month. It never changes a plan or tier.

### UzbekVoice.ai (default provider, voice `shoira`) - facts relayed by the owner's helper, NOT verified by us

`synth_uz.py` now implements this provider (offline-tested with a fake HTTP layer; **never run against the real service**):

* `POST https://uzbekvoice.ai/api/v1/tts`, header `Authorization: <API_KEY>` (raw key as in the docs; `--uzv-auth bearer`
  sends `Bearer <key>` if the first call shows that is needed), `Content-Type: application/json`.
* Body: `text`, `model` = `shoira` (default) | `lola` | `kamola` | `jasur` | `sevinch`, `blocking` (true waits for the result;
  `--uzv-async` sends false and polls `GET https://uzbekvoice.ai/api/v1/tasks?id=<task_id>` -> `{id, result, state}`).
  `mood` is deprecated and never sent; no webhook is used.
* **Unknown** (the adapter is tolerant): whether the result is binary audio or JSON with `url` / `audio_url` / `result.url`
  or base64; container and sample rate (WAV 16-bit is read directly, anything else is decoded with ffmpeg to 48 kHz);
  per-request character limit; error codes; whether SSML is accepted (plain respelled text only is sent). **The first
  real sample call prints a diagnostic** (HTTP status, content-type, JSON key names, detected container and sample rate;
  never the key) - send that diagnostic back so the handling can be tightened.
* Key: environment variable `UZBEKVOICE_API_KEY` (cloud environment -> Network secrets, never in chat); allowed domain
  `uzbekvoice.ai` in the environment's network settings. Optional: `UZBEKVOICE_AUTH_SCHEME`, `UZBEKVOICE_BASE_URL`.
* **Price (owner's figure, unverified): 0.5 so'm per character.** Balance 10 000 so'm = 20 000 characters; a 165-character
  sample cost 83 so'm. The tool keeps a local cumulative character counter (`~/.labguide_tts_uzbekvoice_usage.json`) and
  stops at `--uzv-char-limit` (default 19 000). It never tops up anything. Cached lines are never charged twice.
* Planned spend (characters = what is sent; full table in `FIT_SUMMARY.md`): sample **219 characters = about 110 so'm**; first
  pass of all nine videos **10 124 characters = about 5 062 so'm** (9 615 characters = 4 808 so'm with the suggested
  shorter texts); the longest video, **overview, 1 486 characters = about 743 so'm per full redo**. Per video: overview 1 486,
  calibration 1 341, qc 989, photometry 942, osmometry 1 014, leukocyte 1 416, calculators 837, gcms 1 108, qpcr 991.
  Redoing everything once more would use the other half of the balance, so listen to the sample and fix the respellings
  **before** the first pass, and re-run only changed lines (the cache does that).

## 4. Commands

All from the repository root. `--out-root` defaults to `video_studio/out` (gitignored).

```bash
# 0. No keys, no network: what would be sent, how it would fit (also prints characters and so'm)
python3 tool/tts/synth_uz.py --all --dry-run
python3 tool/tts/synth_uz.py --all --dry-run --use-suggested
python3 tool/tts/synth_uz.py --sample --dry-run          # shows the three respelled sample lines

# 1. FIRST: the pronunciation sample (3 lines, about 14 s, 219 characters)
python3 tool/tts/synth_uz.py --sample                                   # UzbekVoice, voice shoira, apostrophes as written
python3 tool/tts/synth_uz.py --sample --voice lola                      # other UzbekVoice voices: kamola jasur sevinch
python3 tool/tts/synth_uz.py --sample --provider azure                  # Azure uz-UZ-MadinaNeural (alternative)
python3 tool/tts/synth_uz.py --sample --provider azure --voice uz-UZ-SardorNeural
python3 tool/tts/synth_uz.py --sample --apostrophe-variants             # o‘ g‘ as written / ASCII ' / modifier ʻ (3x the characters)
#    -> video_studio/out/voice_uz_sample/sample*.wav + sample*.json (prints the MEASURED chars/second)
#    Listen for: PDF, Levey–Jennings, Westgard, eGFR, qPCR, GC-MS, mmol/L, o‘ g‘ ma’lumot.
#    Fix wrong words in tool/tts/uz_prep.py (rules/_ABBR) or the glossary, then:
python3 tool/tts/plan_uz.py --rate 12.5          # use the measured rate; rewrites the plans and FIT_SUMMARY

# 2. One video, then all (re-uses cached lines: a repeat costs no characters); add --provider azure for Azure
python3 tool/tts/synth_uz.py --video overview --allow-unfit              # first video: cut lines are tolerated, listen to them
python3 tool/tts/synth_uz.py --video overview
python3 tool/tts/synth_uz.py --all
python3 tool/tts/synth_uz.py --all --use-suggested                       # shorter texts where a plan has them
#    -> video_studio/out/<id>/uz/{voice_uz.wav, lines/*.wav, report.json, report.md}
```

* Exit code 3 and a file named `voice_uz.UNFIT.wav` mean some lines had to be cut to fit even at +12 % tempo; shorten
  them (plan suggestions, or edit the text and re-run `plan_uz.py`) instead of using that file. `--allow-unfit` writes the
  normal name anyway. Lines that run into the guard gap but not into the next line are reported as `overflow` (fine, listen to them).
* `voice_uz.wav`: 48 kHz mono PCM16, exactly the length of the English timeline, two-pass loudnorm to **-16 LUFS /
  -2.4 dBTP** (LRA 11, linear) like `video_studio/scripts/voice.mjs`; the report shows before/after numbers.
* `--slow-short` slows short clips down towards the English clip length (max -12 %); off by default (they are padded).

## 5. Swapping the new audio into the videos WITHOUT re-rendering

How the earlier renders got their sound: the Remotion compositions contain **no audio at all**.
`video_studio/scripts/render.mjs` pipes the frames into the system ffmpeg and muxes
`public/audio/en/<id>.wav` (the English narration) as AAC 160 kbit/s 48 kHz at render time - for **every** language
edition. `video_studio/scripts/remux.mjs` already replaces that track in finished MP4s with `-c:v copy`.

Cheapest way (seconds per video, no Node, no `node_modules`, video stream copied bit for bit):

```bash
python3 tool/tts/remux_uz.py --video overview --dry-run      # prints the ffmpeg commands
python3 tool/tts/remux_uz.py --video overview                # out/<id>/uz/*.mp4 -> out/<id>/uz/uzvoice/*.mp4
python3 tool/tts/remux_uz.py --video overview --inplace      # replace the originals instead
```

It is the same as `ffmpeg -i video.mp4 -i voice_uz.wav -map 0:v:0 -c:v copy -map 1:a:0 -c:a aac -b:a 160k -ar 48000 -t <len> -movflags +faststart out.mp4`
for each `<id>_uz_vertical.mp4` and `<id>_uz_horizontal.mp4`, and refuses if the WAV and MP4 lengths differ by more than 0.06 s.

* Only the **Uzbek edition** (`out/<id>/uz/`) gets the Uzbek voice. The Russian and English editions keep the English voice
  (owner decision 2026-10-25) unless the owner decides otherwise.
* A re-render is needed only if the **visual timing** changes, i.e. if the English voice or `storyboard.json` change.
  Adopting a shorter suggested wording changes text only, not timing; the picture stays.

## 6. Subtitles

* Burned-in subtitles: the Uzbek edition's MP4 has the Uzbek subtitle plate rendered into the video (text from
  `lines.uz.json`, cues timed by the English timing). The remux keeps it untouched. Because the Uzbek line often ends
  earlier than the English one, a subtitle may stay on screen a little after the voice ends; harmless.
* Sidecar `.srt` / `.vtt` (`out/<id>/uz/<id>_uz.*`) stay valid for the same reason.
* If a **suggested shorter text** is adopted for the voice, the burned-in subtitle still shows the long text. Either keep the
  long subtitle (spoken text is a shortened version of it - acceptable only if the owner agrees) or change
  `lines.uz.json` and re-render / splice (`video_studio/scripts/splice.mjs`) the affected frame ranges.
* Russian and English editions: subtitles and on-screen text unchanged.
* Recommended description line (from `docs/video/tts/VOICE_DECISION.md`): "Diktor ovozi sun’iy intellekt yordamida yaratilgan."

## 7. OPEN items (nothing here is claimed to be fine)

Licence and commercial use:

1. **Azure Speech, free F0 tier**: is audio produced on F0 allowed in advertising videos? The official pages read did not say; a
   Microsoft employee's forum answer (2023, see `docs/video/tts/VOICE_DECISION.md` section 4) says commercial use needs a
   paid (pay-as-you-go) subscription. The owner must confirm with Azure Product Terms / Microsoft support. If not
   confirmed, use F0 for drafts only.
2. **Azure**: disclosure of synthetic voice (Microsoft recommends it; Instagram / YouTube may ask for an AI-content label).
3. **Azure**: whether `uz-UZ` voices are offered in the chosen region (not verified).
4. **UzbekVoice.ai** (voices shoira, lola, kamola, jasur, sevinch): whether commercial / advertising use of the generated audio
   is allowed, attribution, retention of the submitted text, free/paid terms, and - for each voice - whose voice it is and under
   which consent/licence. The site has **no terms page (404)**, and a web search on 2026-10-31 found no official terms either.
   **Owner to ask UzbekVoice in writing via https://uzbekvoice.ai/contact or Telegram t.me/UzbekVoiceAIGroup** and keep the
   answer; do not publish ad videos with this voice before that. Also open: the price (0.5 so'm/character) and the API
   details above come from the owner's helper, not from us.
5. Neither provider's terms were read in full; this is not legal advice.

Owner decisions needed: which voice (shoira / lola / kamola / jasur / sevinch, or Azure Madina / Sardor) after listening; whether Russian and English editions stay
English-voiced; whether shortened wordings may replace the subtitle text; native review of the respellings
(`pronunciation_uz.csv`, risk HIGH first); apostrophe spelling that Azure reads correctly (test with `--apostrophe-variants`).

## 8. NOT RUN (honest list)

No real TTS call, no key, no listening (so no judgement of naturalness, accent, stress or respellings), no render, no
remux of real MP4s (only unit tests with a 2-second fake clip), no measurement of the real speech rate (13 chars/s is an
assumption), no check of `uz-UZ` regional availability, no licence confirmation. Unit tests (offline) and the dry run were run.
