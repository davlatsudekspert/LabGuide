#!/usr/bin/env python3
"""Uzbek voice-over for the existing LabGuide videos: plan.json -> per-line TTS -> fitted to the scene windows
of the English timeline -> one loudness-normalised voice_uz.wav per video.

    # 0. nothing is sent anywhere (no keys needed): fit table from the estimates in the plans
    python3 tool/tts/synth_uz.py --all --dry-run
    # 1. the owner's pronunciation check (3 short lines, ~220 characters; needs UZBEKVOICE_API_KEY, or AZURE_* with --provider azure)
    python3 tool/tts/synth_uz.py --sample
    python3 tool/tts/synth_uz.py --sample --apostrophe-variants      # also compares o‘ g‘ spellings
    # 2. one video, then all
    python3 tool/tts/synth_uz.py --video overview
    python3 tool/tts/synth_uz.py --all --use-suggested

Providers
    azure          Azure Speech REST (SSML, riff-48khz-16bit-mono-pcm). Key and region ONLY from the environment
                   (AZURE_SPEECH_KEY, AZURE_SPEECH_REGION); they are never printed, logged or written to the report.
                   Voice uz-UZ-MadinaNeural (default, female) or uz-UZ-SardorNeural (male).
    uzbekvoiceai   UzbekVoice.ai (default; model/voice shoira, also lola kamola jasur sevinch). Written from API facts relayed
                   by the owner's helper; never run against the real service. Key only from UZBEKVOICE_API_KEY (never
                   printed). The response format is unknown, so handling is tolerant (binary audio, JSON with url or
                   base64, async task polling) and the first call prints a diagnostic. 0.5 so'm per character.

    gemini         Gemini TTS (Interactions API; model gemini-3.8-flash-tts, voice Fola; --gemini-style optional). Written from
                   API facts relayed by the owner's helper; never run against the real service. Key only from GEMINI_API_KEY
                   (never printed). Language is auto-detected; 24 kHz WAV is normalised like the other providers.
                   --text-variant spoken (default, pure-Uzbek voice text) | subtitle (the written subtitle text with PDF,
                   eGFR, mmol/L as written) | both (sample only); --voices A,B,C and --max-chars N for the test runs.

Fitting (per line, see fit_decision): trim leading/trailing silence; if the clip is longer than its slot
speed it up with ffmpeg atempo by at most +12 %; shorter clips are padded with silence (optionally slowed down to
at most -12 % with --slow-short). A clip that still does not fit is reported: it may run on into the guard gap up
to the next line's start (status overflow); beyond that it is cut with a short fade (status truncated, exit code 3
unless --allow-unfit). The timeline is the ENGLISH one (docs/video/<id>/voice_uz/plan.json: timeline.total_s), so the
result can replace the audio of the existing MP4s without re-rendering (tool/tts/remux_uz.py).

Loudness: two-pass ffmpeg loudnorm exactly like video_studio/scripts/voice.mjs (-16 LUFS integrated, true peak
-2.4 dBTP by default, LRA 11, linear), 48 kHz mono PCM16.

Nothing here upgrades, buys or enables anything. Azure usage is counted locally (synth.QuotaGuard) and refused above
--azure-char-limit (default 450 000 chars/month; the F0 allowance is 500 000 - verify in the portal).
"""
from __future__ import annotations

import argparse
import array
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
import wave
import xml.sax.saxutils as _xml
from dataclasses import dataclass
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(HERE))
import synth  # noqa: E402  (QuotaGuard, wav helpers, default_http_post)
import uz_prep  # noqa: E402

VIDEOS = ["overview", "calibration", "qc", "photometry", "osmometry", "leukocyte", "calculators", "gcms", "qpcr"]
DEFAULT_OUT_ROOT = REPO / "video_studio" / "out"
SPEECH_RATE_CPS = 10.75   # measured by the owner on real UzbekVoice shoira audio (same value as plan_uz.RATE_CPS)
SAMPLE_FILE = REPO / "docs/video/voice_uz/SAMPLE_TEXT.txt"
AZURE_FORMAT = "riff-48khz-16bit-mono-pcm"
AZURE_VOICES = ("uz-UZ-MadinaNeural", "uz-UZ-SardorNeural")
TARGET_SR = 48000
MAX_TEMPO, MIN_TEMPO = 1.12, 0.88
TARGET_LUFS, TARGET_TP, TARGET_LRA = -16.0, -2.4, 11.0
EXIT_UNFIT = 3


# --------------------------------------------------------------------------- apostrophes

def map_apostrophes(text: str, style: str) -> str:
    """keep: as written (o‘ g‘ U+2018, tutuq U+2019). ascii: all -> '.  modifier: oʻ gʻ U+02BB, tutuq U+02BC."""
    if style == "keep":
        return text
    if style == "ascii":
        return re.sub("[‘’ʻʼ`´]", "'", text)
    if style == "modifier":
        text = re.sub(r"(?i)([og])[‘’ʻʼ'`´]", lambda m: m.group(1) + "ʻ", text)
        return re.sub(r"(?<=\w)[‘’'`´](?=\w)", "ʼ", text)
    raise ValueError("apostrophe style must be keep, ascii or modifier")


# --------------------------------------------------------------------------- providers

class Provider:
    name = "base"
    sample_rate = TARGET_SR

    def synthesize(self, text: str, voice: str) -> tuple[bytes, int]:
        """Return (mono 16-bit PCM, sample rate)."""
        raise NotImplementedError

    def cache_tag(self) -> str:
        return self.name


class AzureProvider(Provider):
    """Azure Speech REST text-to-speech. uz-UZ supports neither <phoneme> nor lexicons (Microsoft Learn), so the
    only pronunciation lever is the respelled plain text produced by uz_prep.py."""
    name = "azure"

    def __init__(self, key: str | None = None, region: str | None = None, *, http_post=synth.default_http_post,
                 guard: synth.QuotaGuard | None = None, min_interval_s: float = 3.2, max_retries: int = 4,
                 sleep=time.sleep, rate: str | None = None):
        self._key = key if key is not None else os.environ.get("AZURE_SPEECH_KEY", "")
        self.region = region if region is not None else os.environ.get("AZURE_SPEECH_REGION", "")
        if not self._key or not self.region:
            raise SystemExit("Azure provider needs AZURE_SPEECH_KEY and AZURE_SPEECH_REGION in the environment "
                             "(see docs/video/voice_uz/README.md). Nothing was sent.")
        if not re.fullmatch(r"[a-z0-9-]{3,40}", self.region):
            raise SystemExit("AZURE_SPEECH_REGION looks wrong (expected e.g. westeurope).")
        self.http_post, self.guard, self.sleep = http_post, guard or synth.QuotaGuard(), sleep
        self.min_interval, self.max_retries, self.rate = min_interval_s, max_retries, rate
        self._last = 0.0
        self.chars_sent = 0
        self.requests = 0

    def __repr__(self):  # never show the key
        return "AzureProvider(region=%r, key=<hidden>)" % self.region

    @staticmethod
    def build_ssml(text: str, voice: str, rate: str | None = None) -> str:
        inner = _xml.escape(text)
        if rate:
            inner = '<prosody rate="%s">%s</prosody>' % (_xml.escape(rate, {'"': "&quot;"}), inner)
        return ("<speak version='1.0' xml:lang='uz-UZ'><voice name='%s'>%s</voice></speak>"
                % (_xml.escape(voice, {"'": "&apos;"}), inner))

    def synthesize(self, text: str, voice: str) -> tuple[bytes, int]:
        url = "https://%s.tts.speech.microsoft.com/cognitiveservices/v1" % self.region
        headers = {"Ocp-Apim-Subscription-Key": self._key, "Content-Type": "application/ssml+xml",
                   "X-Microsoft-OutputFormat": AZURE_FORMAT, "User-Agent": "labguide-tts-uz/1"}
        body = self.build_ssml(text, voice, self.rate).encode("utf-8")
        self.guard.check(len(text))
        for attempt in range(self.max_retries + 1):
            wait = self.min_interval - (time.monotonic() - self._last)
            if wait > 0:
                self.sleep(wait)
            self._last = time.monotonic()
            self.requests += 1
            status, data, hdrs = self.http_post(url, headers, body)
            if status == 200:
                self.guard.add(len(text))
                self.chars_sent += len(text)
                pcm, sr = synth.wav_bytes_to_pcm(data)
                return pcm, sr
            if status in (429, 503) and attempt < self.max_retries:
                ra = (hdrs or {}).get("Retry-After") or (hdrs or {}).get("retry-after")
                self.sleep(float(ra) if ra and ra.replace(".", "").isdigit() else 5.0 * (2 ** attempt))
                continue
            detail = _redact(data[:200].decode("utf-8", "replace"), self._key)
            if status in (401, 403):
                raise SystemExit("Azure rejected the key/region (HTTP %d). If the free quota is used up Azure answers "
                                 "403/429: wait for next month or ask the owner; this tool never upgrades anything. "
                                 "Detail: %s" % (status, detail))
            raise SystemExit("Azure TTS HTTP %d: %s" % (status, detail))
        raise SystemExit("Azure TTS: retries exhausted (HTTP 429/503). Try again later.")

    def cache_tag(self):
        return "azure|" + AZURE_FORMAT + "|" + (self.rate or "")


class EdgeProvider(Provider):
    """Microsoft Edge read-aloud voices through the unofficial `edge-tts` package (free, no key, same neural voices
    as Azure uz-UZ-MadinaNeural / SardorNeural). NOT an official, licensed channel: fine for drafts and for the owner's
    listening, not recommended for public posting (use --provider azure with an official key for that)."""
    name = "edge"

    def __init__(self, rate: str | None = "-3%", pkgs: str | None = None, min_interval_s: float = 0.5, sleep=time.sleep):
        if pkgs:
            sys.path.insert(0, pkgs)
        try:
            import certifi
            ca = "/root/.ccr/ca-bundle.crt"
            if os.path.exists(ca):
                certifi.where = lambda: ca
            import edge_tts  # noqa: F401
        except ImportError:
            raise SystemExit("edge provider needs the edge-tts package (pip install edge-tts or --edge-pkgs DIR).")
        self.rate, self.min_interval, self.sleep, self._last = rate, min_interval_s, sleep, 0.0
        self.requests = 0

    def synthesize(self, text: str, voice: str) -> tuple[bytes, int]:
        import asyncio
        import subprocess
        import tempfile
        import edge_tts
        wait = self.min_interval - (time.monotonic() - self._last)
        if wait > 0:
            self.sleep(wait)
        err = None
        for attempt in range(4):
            with tempfile.TemporaryDirectory() as td:
                mp3, wav = os.path.join(td, "a.mp3"), os.path.join(td, "a.wav")
                try:
                    self.requests += 1
                    kw = {"rate": self.rate} if self.rate else {}
                    comm = edge_tts.Communicate(text, voice, **kw)
                    asyncio.run(asyncio.wait_for(comm.save(mp3), 90))
                    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", mp3, "-ar", str(TARGET_SR), "-ac", "1",
                                    "-c:a", "pcm_s16le", wav], check=True)
                    self._last = time.monotonic()
                    return synth.wav_bytes_to_pcm(open(wav, "rb").read())
                except Exception as e:  # network hiccup: retry
                    err = e
                    self.sleep(3.0 * (attempt + 1))
        raise SystemExit("edge-tts failed after retries: %s: %s" % (type(err).__name__, str(err)[:200]))

    def cache_tag(self):
        return "edge|" + (self.rate or "")


def _redact(s: str, secret: str) -> str:
    return s.replace(secret, "<hidden>") if secret else s


def default_http_get(url: str, headers: dict, timeout: float = 60.0) -> tuple[int, bytes, dict]:
    import urllib.error
    import urllib.request
    req = urllib.request.Request(url, headers=headers, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read(), dict(r.headers)
    except urllib.error.HTTPError as e:
        return e.code, e.read(), dict(e.headers or {})


class CharBudget:
    """Local cumulative character counter for a prepaid service (UzbekVoice: 0.5 so'm per character).

    A safety net only - the provider's own balance is authoritative. It never tops anything up. Reset by deleting the file.
    """

    def __init__(self, path: Path, limit: int):
        self.path, self.limit = Path(path), limit

    def used(self) -> int:
        try:
            return int(json.loads(self.path.read_text()).get("chars", 0))
        except (OSError, ValueError):
            return 0

    def check(self, chars: int) -> None:
        if self.used() + chars > self.limit:
            raise SystemExit("Local character budget: %d used + %d requested > limit %d. Not calling the API. "
                             "(Raise --uzv-char-limit only after checking your balance; delete %s to reset.)"
                             % (self.used(), chars, self.limit, self.path))

    def add(self, chars: int) -> None:
        try:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            self.path.write_text(json.dumps({"chars": self.used() + chars}))
        except OSError:
            pass


def _sniff_audio(data: bytes) -> str | None:
    if data[:4] == b"RIFF" and data[8:12] == b"WAVE":
        return "wav"
    if data[:3] == b"ID3" or (len(data) > 2 and data[0] == 0xFF and data[1] & 0xE0 == 0xE0):
        return "mp3"
    if data[:4] == b"OggS":
        return "ogg"
    if data[:4] == b"fLaC":
        return "flac"
    if data[4:8] == b"ftyp":
        return "mp4/m4a"
    return None


def decode_audio_bytes(data: bytes) -> tuple[bytes, int, str]:
    """Any container -> (mono 16-bit PCM, sample rate, container name). 16-bit PCM WAV is read directly; everything
    else (mp3, ogg, flac, m4a, other WAV flavours) goes through ffmpeg at 48 kHz."""
    kind = _sniff_audio(data)
    if kind is None:
        raise ValueError("response bytes are not a recognised audio container")
    if kind == "wav":
        try:
            pcm, sr = synth.wav_bytes_to_pcm(data)
            return pcm, sr, "wav"
        except Exception:  # not 16-bit PCM etc.: let ffmpeg convert
            pass
    if not shutil.which("ffmpeg"):
        raise SystemExit("received %s audio; ffmpeg is needed to decode it" % kind)
    p = subprocess.run(["ffmpeg", "-v", "error", "-i", "pipe:0", "-f", "s16le", "-ar", str(TARGET_SR), "-ac", "1",
                        "pipe:1"], input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if p.returncode != 0 or not p.stdout:
        raise SystemExit("ffmpeg could not decode the %s audio: %s" % (kind, p.stderr.decode("utf-8", "replace")[:200]))
    return p.stdout, TARGET_SR, kind


class UzbekVoiceAIProvider(Provider):
    """UzbekVoice.ai text-to-speech (https://uzbekvoice.ai). Written from facts relayed by the owner's helper who read
    the API documentation while logged in; NEVER RUN against the real service (no call has been made).

    Known (from that relay):
      POST https://uzbekvoice.ai/api/v1/tts
           headers  Authorization: <API_KEY>   (raw key as in the docs; --uzv-auth bearer switches to 'Bearer <key>')
                    Content-Type: application/json
           body     {"text": str, "model": shoira|lola|kamola|jasur|sevinch, "blocking": bool,
                     "webhook_notification_url": optional}      ('mood' is DEPRECATED: never sent)
           blocking=true waits for the result; false returns a task_id.
      GET  https://uzbekvoice.ai/api/v1/tasks?id=<task_id>   same headers -> JSON {id, result:{...}, state}
    UNKNOWN (so the handling is deliberately tolerant and the first call prints a diagnostic): whether the TTS result is
    binary audio or JSON (url / base64), container and sample rate, per-request limits, error codes, SSML support
    (plain respelled text only is sent). The first real sample call confirms the format.

    Environment: UZBEKVOICE_API_KEY (secret, never printed), optional UZBEKVOICE_AUTH_SCHEME (raw|bearer),
    UZBEKVOICE_BASE_URL (default https://uzbekvoice.ai/api/v1).
    Price relayed by the owner: 0.5 so'm per character. Licence / commercial use: OPEN (no terms page found).
    """
    name = "uzbekvoiceai"
    MODELS = ("shoira", "lola", "kamola", "jasur", "sevinch")
    DEFAULT_MODEL = "shoira"
    DONE_STATES = {"done", "completed", "complete", "success", "succeeded", "finished", "ready"}
    FAIL_STATES = {"failed", "failure", "error", "cancelled", "canceled"}

    def __init__(self, key: str | None = None, base_url: str | None = None, auth_scheme: str | None = None, *,
                 blocking: bool = True, http_post=synth.default_http_post, http_get=default_http_get,
                 sleep=time.sleep, poll_interval_s: float = 2.0, poll_timeout_s: float = 180.0,
                 budget: CharBudget | None = None, diag=None, max_retries: int = 3, min_interval_s: float = 0.0):
        self._key = key if key is not None else os.environ.get("UZBEKVOICE_API_KEY", "")
        if not self._key:
            raise SystemExit("UzbekVoice provider needs UZBEKVOICE_API_KEY in the environment (cloud environment -> Network "
                             "secrets; never paste it into the chat). Nothing was sent.")
        self.base = (base_url or os.environ.get("UZBEKVOICE_BASE_URL") or "https://uzbekvoice.ai/api/v1").rstrip("/")
        if not self.base.startswith("https://"):
            raise SystemExit("UZBEKVOICE_BASE_URL must start with https://")
        self.scheme = (auth_scheme or os.environ.get("UZBEKVOICE_AUTH_SCHEME") or "raw").lower()
        if self.scheme not in ("raw", "bearer"):
            raise SystemExit("auth scheme must be raw or bearer")
        self.blocking, self.http_post, self.http_get, self.sleep = blocking, http_post, http_get, sleep
        self.poll_interval, self.poll_timeout, self.max_retries = poll_interval_s, poll_timeout_s, max_retries
        self.min_interval = min_interval_s
        self.budget = budget
        self.diag = diag if diag is not None else (lambda m: print(m, file=sys.stderr))
        self._diag_done = False
        self._last = 0.0
        self.chars_sent = 0
        self.requests = 0

    def __repr__(self):
        return "UzbekVoiceAIProvider(base=%r, auth=%s, key=<hidden>)" % (self.base, self.scheme)

    # -- plumbing ---------------------------------------------------------------------------------------
    def _headers(self, json_body: bool) -> dict:
        h = {"Authorization": self._key if self.scheme == "raw" else "Bearer " + self._key}
        if json_body:
            h["Content-Type"] = "application/json"
        return h

    def _safe(self, b: bytes, n: int = 200) -> str:
        return _redact(b[:n].decode("utf-8", "replace"), self._key)

    def _diagnostic(self, what: str, status: int, headers: dict, data: bytes) -> None:
        """One-time first-response report. Contains no secret: no key, no header values except content-type, no URLs
        beyond the host."""
        if self._diag_done:
            return
        self._diag_done = True
        ctype = (headers or {}).get("Content-Type") or (headers or {}).get("content-type") or "?"
        info = ["UzbekVoice first-call diagnostic (%s): HTTP %d, content-type %s, %d bytes" % (what, status, ctype, len(data))]
        kind = _sniff_audio(data)
        if kind:
            info.append("  body looks like binary audio (%s)" % kind)
        else:
            try:
                j = json.loads(data.decode("utf-8"))
                if isinstance(j, dict):
                    info.append("  JSON object, keys: %s" % ", ".join(sorted(map(str, j.keys()))))
                    if isinstance(j.get("result"), dict):
                        info.append("  result keys: %s" % ", ".join(sorted(map(str, j["result"].keys()))))
                    if "state" in j:
                        info.append("  state: %s" % str(j["state"])[:40])
                else:
                    info.append("  JSON %s" % type(j).__name__)
            except ValueError:
                info.append("  body is neither audio nor JSON (first bytes: %r)" % data[:12])
        self.diag("\n".join(info))

    def _request(self, method: str, url: str, body: bytes | None) -> tuple[int, bytes, dict]:
        for attempt in range(self.max_retries + 1):
            wait = self.min_interval - (time.monotonic() - self._last)
            if wait > 0:
                self.sleep(wait)
            self._last = time.monotonic()
            self.requests += 1
            if method == "POST":
                status, data, hdrs = self.http_post(url, self._headers(True), body)
            else:
                status, data, hdrs = self.http_get(url, self._headers(False))
            if status in (429, 503) and attempt < self.max_retries:
                ra = (hdrs or {}).get("Retry-After") or (hdrs or {}).get("retry-after")
                self.sleep(float(ra) if ra and ra.replace(".", "").isdigit() else 3.0 * (2 ** attempt))
                continue
            return status, data, hdrs
        return status, data, hdrs

    @staticmethod
    def _dig(obj, *paths):
        for path in paths:
            cur = obj
            for k in path.split("."):
                cur = cur.get(k) if isinstance(cur, dict) else None
            if cur:
                return cur
        return None

    def _audio_from_json(self, j: dict) -> bytes | None:
        """Tolerant extraction: base64 or url, at the top level or under result."""
        import base64
        b64 = self._dig(j, "audio_base64", "base64", "audio", "result.audio_base64", "result.base64", "result.audio",
                        "result.data", "data")
        if isinstance(b64, str):
            raw = b64.split(",", 1)[1] if b64.startswith("data:") and "," in b64 else b64
            try:
                data = base64.b64decode(raw, validate=False)
                if _sniff_audio(data):
                    return data
            except ValueError:
                pass
        url = self._dig(j, "url", "audio_url", "file_url", "result.url", "result.audio_url", "result.file_url",
                        "result.file", "result.audio_file")
        if isinstance(url, str) and url.startswith("http"):
            host = url.split("/")[2]
            same_host = host == self.base.split("/")[2]
            status, data, _ = (self.http_get(url, self._headers(False) if same_host else {}))  # key only to its own host
            if status != 200:
                raise SystemExit("UzbekVoice: downloading the result failed (HTTP %d from %s)" % (status, host))
            return data
        return None

    def _poll(self, task_id: str) -> dict:
        waited = 0.0
        last_state = None
        while True:
            status, data, hdrs = self._request("GET", "%s/tasks?id=%s" % (self.base, task_id), None)
            self._diagnostic("task poll", status, hdrs, data)
            if status != 200:
                raise SystemExit("UzbekVoice task poll HTTP %d: %s" % (status, self._safe(data)))
            try:
                j = json.loads(data.decode("utf-8"))
            except ValueError:
                raise SystemExit("UzbekVoice task poll: response is not JSON: %s" % self._safe(data, 80))
            state = str(j.get("state", "")).lower()
            last_state = state or last_state
            if state in self.FAIL_STATES:
                raise SystemExit("UzbekVoice task failed (state %s): %s" % (state, self._safe(data)))
            if state in self.DONE_STATES or (not state and self._audio_from_json_probe(j)):
                return j
            if waited >= self.poll_timeout:
                raise SystemExit("UzbekVoice: task not finished after %.0f s (last state %r)" % (waited, last_state))
            self.sleep(self.poll_interval)
            waited += self.poll_interval

    def _audio_from_json_probe(self, j: dict) -> bool:
        return bool(self._dig(j, "url", "audio_url", "result.url", "result.audio_url", "audio_base64", "result.audio_base64"))

    # -- the one public call ------------------------------------------------------------------------------
    def synthesize(self, text: str, voice: str) -> tuple[bytes, int]:
        model = (voice or self.DEFAULT_MODEL).lower()
        if model not in self.MODELS:
            raise SystemExit("UzbekVoice model must be one of %s (got %r)" % (", ".join(self.MODELS), voice))
        if self.budget:
            self.budget.check(len(text))
        body = json.dumps({"text": text, "model": model, "blocking": self.blocking}, ensure_ascii=False).encode("utf-8")
        status, data, hdrs = self._request("POST", self.base + "/tts", body)
        self._diagnostic("tts", status, hdrs, data)
        if status in (401, 403):
            raise SystemExit("UzbekVoice rejected the key (HTTP %d). Check UZBEKVOICE_API_KEY and, if the docs say so, "
                             "UZBEKVOICE_AUTH_SCHEME=bearer. Balance used up also ends here. Detail: %s" % (status, self._safe(data)))
        if status not in (200, 201, 202):
            raise SystemExit("UzbekVoice TTS HTTP %d: %s" % (status, self._safe(data)))
        audio = data if _sniff_audio(data) else None
        if audio is None:
            try:
                j = json.loads(data.decode("utf-8"))
            except ValueError:
                raise SystemExit("UzbekVoice: unrecognised response (neither audio nor JSON); see the diagnostic above")
            audio = self._audio_from_json(j) if isinstance(j, dict) else None
            if audio is None and isinstance(j, dict):
                task_id = self._dig(j, "task_id", "id", "result.task_id")
                if not task_id:
                    raise SystemExit("UzbekVoice: JSON response has neither audio, url nor task_id (keys: %s)"
                                     % ", ".join(sorted(map(str, j.keys()))))
                done = self._poll(str(task_id))
                audio = self._audio_from_json(done)
                if audio is None:
                    raise SystemExit("UzbekVoice: finished task has no audio/url in its result (keys: %s)"
                                     % ", ".join(sorted(map(str, (done.get("result") or {}).keys())
                                                         if isinstance(done.get("result"), dict) else done.keys())))
        try:
            pcm, sr, kind = decode_audio_bytes(audio)
        except ValueError as e:
            raise SystemExit("UzbekVoice: " + str(e))
        if self.budget:
            self.budget.add(len(text))
        self.chars_sent += len(text)
        if not hasattr(self, "_fmt_reported"):
            self._fmt_reported = True
            self.diag("UzbekVoice audio: container %s, %d Hz, %.2f s for %d characters" % (kind, sr, len(pcm) / 2 / sr, len(text)))
        return pcm, sr

    def cache_tag(self):
        return "uzbekvoiceai|" + ("blocking" if self.blocking else "async")


GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/interactions"
GEMINI_VOICES_URL = "https://generativelanguage.googleapis.com/v1beta/voices"
GEMINI_DEFAULT_MODEL = "gemini-3.8-flash-tts"
GEMINI_DEFAULT_VOICE = "Fola"
GEMINI_KNOWN_MODELS = ("gemini-3.8-flash-tts", "gemini-3.8-flash-lite-tts", "gemini-3.1-flash-tts-preview",
                       "gemini-2.5-pro-preview-tts")
GEMINI_COMPARE_VOICES = ("Fola", "Kore", "Puck", "Charon", "Leda", "Sulafat", "Zephyr")
GEMINI_CHUNK_CHARS = 900
GEMINI_MIN_INTERVAL_S = 6.0
_VOICE_RE = re.compile(r"[A-Za-z0-9_-]{2,40}")
_MODEL_RE = re.compile(r"[A-Za-z0-9._-]{3,64}")
_GOOGLE_KEY_RE = re.compile(r"AIza[0-9A-Za-z_\-]{20,}")


def split_chunks(text: str, limit: int = GEMINI_CHUNK_CHARS) -> list[str]:
    """Split on sentence ends into pieces of at most `limit` characters (a single over-long sentence is cut at the
    last comma / semicolon / space before the limit, and only as a last resort in the middle of a word)."""
    text = text.strip()
    if len(text) <= limit:
        return [text] if text else []
    pieces: list[str] = []
    for sent in re.split(r"(?<=[.!?…])\s+", text):
        sent = sent.strip()
        while len(sent) > limit:
            cut = max(sent.rfind(", ", 0, limit), sent.rfind("; ", 0, limit))
            cut = cut + 1 if cut >= limit // 3 else max(sent.rfind(" ", 0, limit), -1)
            if cut < limit // 3:
                cut = limit
            pieces.append(sent[:cut].strip())
            sent = sent[cut:].strip()
        if sent:
            pieces.append(sent)
    chunks: list[str] = []
    for p in pieces:
        if chunks and len(chunks[-1]) + 1 + len(p) <= limit:
            chunks[-1] += " " + p
        else:
            chunks.append(p)
    return chunks


class GeminiProvider(Provider):
    """Gemini text-to-speech through the Interactions API. Written from facts relayed by the owner's helper (Google's
    docs, 2026-10-31); NEVER RUN against the real service (no key existed, no call has been made).

      POST https://generativelanguage.googleapis.com/v1beta/interactions
           headers  x-goog-api-key: <GEMINI_API_KEY>, Content-Type: application/json
           body     {"model": ..., "input": [{"type": "user_input", "content": [{"type": "text", "text": T,
                      "annotations": [{"type": "speech_metadata", "style": S}]}]}],
                     "response_format": {"type": "audio"}, "generation_config": {"speech_config": [{"voice": V}]}}
      response: steps[] with type 'model_output', content[] items type 'audio', base64 WAV in `data` (24 kHz mono 16-bit
                PCM per the docs). The LAST such item is used.
    The language is auto-detected (no language parameter). The text is read verbatim, so NO style instruction is ever put
    into the text: style goes only into speech_metadata.style (default empty). Long texts are split on sentences into
    chunks of at most 900 characters (the real limit is unknown) and the clips are joined.
    Rate limits are unknown: --min-interval (default 6 s) between calls and exponential backoff on 429 / 5xx (3 retries).
    Free tier: Google may use the data to improve its products and humans may read it: only public text is sent.
    Key ONLY from the environment (GEMINI_API_KEY); never printed, logged or written.
    """
    name = "gemini"

    def __init__(self, key: str | None = None, model: str = GEMINI_DEFAULT_MODEL, style: str = "", *,
                 url: str = GEMINI_URL, http_post=synth.default_http_post, http_get=default_http_get,
                 sleep=time.sleep, min_interval_s: float = GEMINI_MIN_INTERVAL_S, max_retries: int = 3,
                 backoff_s: float = 8.0, budget: "CharBudget | None" = None, diag=None,
                 chunk_chars: int = GEMINI_CHUNK_CHARS, chunk_gap_s: float = 0.15):
        self._key = key if key is not None else os.environ.get("GEMINI_API_KEY", "")
        if not self._key:
            raise SystemExit("Gemini provider needs GEMINI_API_KEY in the environment (repository secret GEMINI_API_KEY "
                             "for the workflow, see docs/video/voice_uz/README.md; never paste it into the chat). "
                             "Nothing was sent.")
        if not _MODEL_RE.fullmatch(model or ""):
            raise SystemExit("--gemini-model looks wrong (letters, digits, . _ - only): %r" % model)
        if not url.startswith("https://"):
            raise SystemExit("Gemini URL must start with https://")
        self.model, self.style, self.url = model, style or "", url
        self.http_post, self.http_get, self.sleep = http_post, http_get, sleep
        self.min_interval, self.max_retries, self.backoff = min_interval_s, max_retries, backoff_s
        self.budget, self.chunk_chars, self.chunk_gap = budget, chunk_chars, chunk_gap_s
        self.diag = diag if diag is not None else (lambda m: print(m, file=sys.stderr))
        self._first_http = False
        self._first_audio = False
        self._last = 0.0
        self.chars_sent = 0
        self.requests = 0

    def __repr__(self):  # never show the key
        return "GeminiProvider(model=%r, key=<hidden>)" % self.model

    # -- plumbing ---------------------------------------------------------------------------------------
    def _headers(self) -> dict:
        return {"x-goog-api-key": self._key, "Content-Type": "application/json"}

    def _safe(self, s: str, n: int = 300) -> str:
        s = _GOOGLE_KEY_RE.sub("<hidden>", _redact(s, self._key))
        return s[:n]

    def _detail(self, data: bytes) -> str:
        text = data[:2000].decode("utf-8", "replace")
        try:
            j = json.loads(text)
            msg = (j.get("error") or {}).get("message") if isinstance(j, dict) and isinstance(j.get("error"), dict) else None
            if msg:
                return self._safe(str(msg))
        except ValueError:
            pass
        return self._safe(text)

    @staticmethod
    def _json_keys(data: bytes) -> str:
        try:
            j = json.loads(data.decode("utf-8"))
        except ValueError:
            return "(body is not JSON, %d bytes)" % len(data)
        if isinstance(j, dict):
            return ", ".join(sorted(map(str, j.keys()))) or "(empty object)"
        return "(JSON %s)" % type(j).__name__

    def _wait_interval(self) -> None:
        wait = self.min_interval - (time.monotonic() - self._last)
        if wait > 0:
            self.sleep(wait)
        self._last = time.monotonic()

    def _request(self, method: str, url: str, body: bytes | None) -> tuple[int, bytes, dict, int]:
        """Returns (status, data, headers, retries used). 429 and 5xx are retried with exponential backoff."""
        for attempt in range(self.max_retries + 1):
            self._wait_interval()
            self.requests += 1
            if method == "POST":
                status, data, hdrs = self.http_post(url, self._headers(), body)
            else:
                status, data, hdrs = self.http_get(url, {"x-goog-api-key": self._key})
            if (status == 429 or 500 <= status <= 599) and attempt < self.max_retries:
                ra = (hdrs or {}).get("Retry-After") or (hdrs or {}).get("retry-after")
                try:
                    delay = min(120.0, float(ra)) if ra else self.backoff * (2 ** attempt)
                except ValueError:
                    delay = self.backoff * (2 ** attempt)
                self.diag("Gemini HTTP %d (%s): retry %d/%d in %.0f s" % (
                    status, "rate limit / quota" if status == 429 else "server error", attempt + 1, self.max_retries, delay))
                self.sleep(delay)
                continue
            return status, data, hdrs, attempt
        raise AssertionError("unreachable")  # pragma: no cover

    @staticmethod
    def extract_audio(j) -> tuple[str | None, str | None]:
        """(base64 data, mime type) of the LAST audio item of a model_output step; None when there is none."""
        found: tuple[str | None, str | None] = (None, None)
        if not isinstance(j, dict):
            return found
        for step in j.get("steps") or []:
            if isinstance(step, dict) and step.get("type") == "model_output":
                for item in step.get("content") or []:
                    if isinstance(item, dict) and item.get("type") == "audio" and isinstance(item.get("data"), str) \
                            and item["data"]:
                        found = (item["data"], item.get("mime_type"))
        if found[0] is None:  # tolerance: a flat `outputs` list of content items
            for item in j.get("outputs") or []:
                if isinstance(item, dict) and item.get("type") == "audio" and isinstance(item.get("data"), str) \
                        and item["data"]:
                    found = (item["data"], item.get("mime_type"))
        return found

    def build_body(self, text: str, voice: str) -> bytes:
        body = {"model": self.model,
                "input": [{"type": "user_input", "content": [
                    {"type": "text", "text": text, "annotations": [{"type": "speech_metadata", "style": self.style}]}]}],
                "response_format": {"type": "audio"},
                "generation_config": {"speech_config": [{"voice": voice}]}}
        return json.dumps(body, ensure_ascii=False).encode("utf-8")

    def _one(self, text: str, voice: str) -> tuple[bytes, int]:
        import base64
        import binascii
        status, data, _, retries = self._request("POST", self.url, self.build_body(text, voice))
        if not self._first_http:
            self._first_http = True
            self.diag("Gemini first-call diagnostic: HTTP %d, response keys: %s" % (status, self._json_keys(data)))
        if status != 200:
            detail = self._detail(data)
            if status in (401, 403):
                raise SystemExit("Gemini rejected the key (HTTP %d). Check the GEMINI_API_KEY secret, that the "
                                 "Generative Language API is enabled for its project and that the model %r is allowed. "
                                 "Detail: %s" % (status, self.model, detail))
            if status == 404:
                raise SystemExit("Gemini HTTP 404: model %r or endpoint not found (try --gemini-model %s). Detail: %s"
                                 % (self.model, GEMINI_KNOWN_MODELS[0], detail))
            if status == 429 or 500 <= status <= 599:
                raise SystemExit("Gemini HTTP %d persisted after %d retries (%s). Free-tier limits are unknown: wait, "
                                 "raise --min-interval (now %g s) or check the quota in AI Studio. Detail: %s"
                                 % (status, retries, "rate limit / quota" if status == 429 else "server error",
                                    self.min_interval, detail))
            raise SystemExit("Gemini TTS HTTP %d: %s" % (status, detail))
        try:
            j = json.loads(data.decode("utf-8"))
        except ValueError:
            raise SystemExit("Gemini: HTTP 200 but the body is not JSON (%d bytes); see the diagnostic above" % len(data))
        b64, mime = self.extract_audio(j)
        if b64 is None:
            raise SystemExit("Gemini: no model_output audio item in the response (keys: %s). The text may have been "
                             "refused or the response format differs." % self._json_keys(data))
        try:
            raw = base64.b64decode(b64.split(",", 1)[1] if b64.startswith("data:") and "," in b64 else b64)
        except (binascii.Error, ValueError):
            raise SystemExit("Gemini: the audio data is not valid base64")
        if _sniff_audio(raw) is None and mime and re.search(r"pcm|l16", mime, re.I):
            m = re.search(r"rate=(\d+)", mime)
            pcm, sr, kind = raw[: len(raw) // 2 * 2], int(m.group(1)) if m else 24000, "raw-pcm"
        else:
            try:
                pcm, sr, kind = decode_audio_bytes(raw)
            except ValueError as e:
                raise SystemExit("Gemini: " + str(e))
        if not self._first_audio:
            self._first_audio = True
            self.diag("Gemini audio: %d bytes decoded (%s), %d Hz, %.2f s for %d characters" % (
                len(raw), kind, sr, len(pcm) / 2 / sr, len(text)))
        return pcm, sr

    # -- public ---------------------------------------------------------------------------------------------
    def synthesize(self, text: str, voice: str) -> tuple[bytes, int]:
        voice = voice or GEMINI_DEFAULT_VOICE
        if not _VOICE_RE.fullmatch(voice):
            raise SystemExit("Gemini voice name looks wrong (letters, digits, _ - only): %r" % voice)
        chunks = split_chunks(text, self.chunk_chars)
        if not chunks:
            raise SystemExit("Gemini: empty text")
        total = sum(len(c) for c in chunks)
        if self.budget:
            self.budget.check(total)
        pcms, sr_seen = [], None
        for c in chunks:
            pcm, sr = self._one(c, voice)
            if sr_seen is None:
                sr_seen = sr
            elif sr != sr_seen:
                raise SystemExit("Gemini: sample rate changed between chunks (%d vs %d)" % (sr_seen, sr))
            pcms.append(pcm)
            self.chars_sent += len(c)
            if self.budget:
                self.budget.add(len(c))
        gap = b"\x00\x00" * int(round(self.chunk_gap * sr_seen))
        return gap.join(pcms), sr_seen

    def list_voices(self, language_code: str = "uz", page_size: int = 50) -> list[str]:
        """GET /v1beta/voices?language_code=uz&page_size=50 (extended voices). Tolerant: names from name / voice / id."""
        status, data, _, _ = self._request("GET", "%s?language_code=%s&page_size=%d" % (
            GEMINI_VOICES_URL, language_code, page_size), None)
        if status != 200:
            raise SystemExit("Gemini voices HTTP %d: %s" % (status, self._detail(data)))
        try:
            j = json.loads(data.decode("utf-8"))
        except ValueError:
            raise SystemExit("Gemini voices: response is not JSON")
        items = j.get("voices") if isinstance(j, dict) else None
        names = []
        for it in items or []:
            if isinstance(it, dict):
                n = it.get("name") or it.get("voice") or it.get("id") or it.get("display_name")
                if n:
                    names.append(self._safe(str(n), 80))
            elif isinstance(it, str):
                names.append(self._safe(it, 80))
        return names

    def cache_tag(self):
        return "gemini|%s|%s" % (self.model, self.style)


def make_provider(name: str, args) -> Provider:
    mi = getattr(args, "min_interval", None)
    if name == "azure":
        return AzureProvider(rate=args.rate, guard=synth.QuotaGuard(limit=args.azure_char_limit),
                             min_interval_s=3.2 if mi is None else mi)
    if name == "edge":
        return EdgeProvider(rate=args.rate if args.rate else "-3%", pkgs=getattr(args, "edge_pkgs", None))
    if name == "uzbekvoiceai":
        return UzbekVoiceAIProvider(
            auth_scheme=args.uzv_auth, blocking=not args.uzv_async,
            budget=CharBudget(Path.home() / ".labguide_tts_uzbekvoice_usage.json", args.uzv_char_limit))
    if name == "gemini":
        return GeminiProvider(
            model=args.gemini_model, style=args.gemini_style,
            min_interval_s=GEMINI_MIN_INTERVAL_S if mi is None else mi,
            budget=CharBudget(Path.home() / ".labguide_tts_gemini_usage.json", args.gemini_char_limit))
    raise SystemExit("unknown provider %r (azure, uzbekvoiceai, gemini)" % name)


# --------------------------------------------------------------------------- audio helpers (pure python)

def pcm_seconds(pcm: bytes, sr: int) -> float:
    return len(pcm) / 2 / sr


def trim_silence(pcm: bytes, sr: int, thresh_db: float = -45.0, keep_head: float = 0.03,
                 keep_tail: float = 0.08, frame_s: float = 0.01) -> bytes:
    """Cut leading/trailing frames whose peak is below thresh_db (dBFS); keep a little air at both ends."""
    a = array.array("h")
    a.frombytes(pcm[: len(pcm) // 2 * 2])
    n = len(a)
    f = max(1, int(sr * frame_s))
    thr = 32768.0 * 10 ** (thresh_db / 20.0)
    first = last = None
    for i in range(0, n, f):
        if max(abs(x) for x in a[i:i + f]) >= thr:
            if first is None:
                first = i
            last = min(n, i + f)
    if first is None:
        return b""  # all silence
    s = max(0, first - int(keep_head * sr))
    e = min(n, last + int(keep_tail * sr))
    return a[s:e].tobytes()


def fade_out(pcm: bytes, sr: int, seconds: float = 0.06) -> bytes:
    a = array.array("h")
    a.frombytes(pcm)
    k = min(len(a), int(seconds * sr))
    for j in range(k):
        idx = len(a) - k + j
        a[idx] = int(a[idx] * (1 - (j + 1) / k))
    return a.tobytes()


def silence(seconds: float, sr: int) -> bytes:
    return b"\x00\x00" * int(round(seconds * sr))


def ffmpeg_tempo(pcm: bytes, sr: int, tempo: float) -> bytes:
    """Pitch-preserving tempo change with ffmpeg atempo (needs ffmpeg on PATH)."""
    if not shutil.which("ffmpeg"):
        raise SystemExit("ffmpeg is required for tempo changes")
    p = subprocess.run(["ffmpeg", "-v", "error", "-f", "s16le", "-ar", str(sr), "-ac", "1", "-i", "pipe:0",
                        "-filter:a", "atempo=%.5f" % tempo, "-f", "s16le", "pipe:1"],
                       input=pcm, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if p.returncode != 0:
        raise SystemExit("ffmpeg atempo failed: " + p.stderr.decode("utf-8", "replace")[:300])
    return p.stdout


# --------------------------------------------------------------------------- fitting

@dataclass
class FitDecision:
    status: str        # ok | sped_up | slowed | overflow | truncated
    tempo: float       # applied atempo factor (1.0 = untouched)
    final_s: float     # duration after tempo (and truncation)
    overflow_s: float  # seconds beyond the slot (0 when it fits)
    fits: bool         # inside the slot (guard included)?


def fit_decision(dur: float, available: float, hard: float, *, max_tempo: float = MAX_TEMPO,
                 min_tempo: float = MIN_TEMPO, slow_to: float | None = None) -> FitDecision:
    """Pure decision logic.

    dur        trimmed clip length (s)         available  slot length: start -> slot_end (s)
    hard       latest allowed length (s): start -> next line start minus 20 ms
    slow_to    if given (e.g. the English clip length) and the clip is shorter, slow it down towards it, but never
               below min_tempo
    """
    if dur <= available + 1e-9:
        if slow_to and dur < slow_to:
            tempo = max(min_tempo, dur / slow_to)
            if tempo < 0.999:
                return FitDecision("slowed", round(tempo, 5), dur / tempo, 0.0, True)
        return FitDecision("ok", 1.0, dur, 0.0, True)
    need = dur / available
    if need <= max_tempo:
        tempo = min(max_tempo, need * 1.003)  # tiny safety so rounding never leaves it 1 ms over
        return FitDecision("sped_up", round(tempo, 5), dur / tempo, 0.0, True)
    final = dur / max_tempo
    if final <= hard + 1e-9:
        return FitDecision("overflow", max_tempo, final, final - available, False)
    return FitDecision("truncated", max_tempo, hard, final - available, False)


@dataclass
class FitResult:
    pcm: bytes
    decision: FitDecision
    raw_s: float
    trimmed_s: float
    note: str = ""


def fit_clip(pcm: bytes, sr: int, available: float, hard: float, *, max_tempo: float = MAX_TEMPO,
             min_tempo: float = MIN_TEMPO, slow_to: float | None = None, tempo_fn=ffmpeg_tempo,
             trim: bool = True) -> FitResult:
    raw_s = pcm_seconds(pcm, sr)
    t = trim_silence(pcm, sr) if trim else pcm
    if not t:
        return FitResult(b"", FitDecision("ok", 1.0, 0.0, 0.0, True), raw_s, 0.0, "clip is silent")
    dur = pcm_seconds(t, sr)
    d = fit_decision(dur, available, hard, max_tempo=max_tempo, min_tempo=min_tempo, slow_to=slow_to)
    out = t
    if abs(d.tempo - 1.0) > 1e-6:
        out = tempo_fn(t, sr, d.tempo)
    if d.status == "truncated":
        out = fade_out(out[: int(hard * sr) * 2], sr)
    return FitResult(out, d, raw_s, dur)


def build_timeline(clips: list[tuple[float, bytes]], total_s: float, sr: int) -> tuple[bytes, list[str]]:
    """Place clips (start_s, pcm) on a silent buffer of exactly total_s. Returns (pcm, warnings)."""
    n = int(round(total_s * sr))
    buf = array.array("h", [0]) * n
    warns = []
    for start, pcm in sorted(clips, key=lambda c: c[0]):
        a = array.array("h")
        a.frombytes(pcm)
        s = int(round(start * sr))
        end = s + len(a)
        if end > n:
            warns.append("clip at %.3f s runs %.3f s past the end of the video: cut" % (start, (end - n) / sr))
            a = a[: n - s]
            end = n
        seg = buf[s:end]
        if any(seg):  # overlap: sum with clipping
            warns.append("overlap at %.3f s" % start)
            a = array.array("h", [max(-32768, min(32767, x + y)) for x, y in zip(a, seg)])
        buf[s:end] = a
    return buf.tobytes(), warns


def write_wav(path: Path, pcm: bytes, sr: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(synth.pcm_to_wav_bytes(pcm, sr))


# --------------------------------------------------------------------------- loudness (as voice.mjs)

def _json_tail(stderr: str) -> dict:
    return json.loads(stderr[stderr.rindex("{"): stderr.rindex("}") + 1])


def loudnorm_two_pass(src: Path, dst: Path, *, lufs: float = TARGET_LUFS, tp: float = TARGET_TP,
                      lra: float = TARGET_LRA, run=subprocess.run) -> dict:
    """Two-pass EBU R128 normalisation, linear=true, 48 kHz mono PCM16. Returns measured numbers."""
    if not shutil.which("ffmpeg"):
        raise SystemExit("ffmpeg is required for loudness normalisation (or pass --no-loudnorm)")
    p1 = run(["ffmpeg", "-hide_banner", "-i", str(src), "-af",
              "loudnorm=I=%g:TP=%g:LRA=%g:print_format=json" % (lufs, tp, lra), "-f", "null", "-"],
             capture_output=True, text=True)
    m = _json_tail(p1.stderr)
    flt = ("loudnorm=I=%g:TP=%g:LRA=%g:measured_I=%s:measured_TP=%s:measured_LRA=%s:measured_thresh=%s:offset=%s:"
           "linear=true:print_format=json" % (lufs, tp, lra, m["input_i"], m["input_tp"], m["input_lra"],
                                              m["input_thresh"], m["target_offset"]))
    p2 = run(["ffmpeg", "-y", "-hide_banner", "-i", str(src), "-af", flt, "-ar", str(TARGET_SR), "-ac", "1",
              "-c:a", "pcm_s16le", str(dst)], capture_output=True, text=True)
    a = _json_tail(p2.stderr)
    return {"target": {"I": lufs, "TP": tp, "LRA": lra},
            "before": {"I": float(m["input_i"]), "TP": float(m["input_tp"]), "LRA": float(m["input_lra"])},
            "after": {"I": float(a["output_i"]), "TP": float(a["output_tp"]), "LRA": float(a["output_lra"])}}


# --------------------------------------------------------------------------- plans and texts

def load_plan(path: Path) -> dict:
    plan = json.loads(Path(path).read_text(encoding="utf-8"))
    if plan.get("schema") != "labguide.voice_uz.plan/1":
        raise SystemExit("%s: not a labguide.voice_uz.plan/1 file" % path)
    return plan


def plan_path(video: str, repo: Path = REPO) -> Path:
    return repo / "docs/video" / video / "voice_uz" / "plan.json"


def line_text(line: dict, use_suggested: bool, text_variant: str = "spoken") -> tuple[str, str]:
    """(text to send, 'original'|'suggested'|'subtitle'). Suggested is used only when it exists and was asked for.
    text_variant 'subtitle' sends the ORIGINAL written Uzbek subtitle text (PDF, eGFR, mmol/L as written) - meant for
    LLM-based TTS (Gemini) that may read such terms by itself; the default 'spoken' is the pure-Uzbek voice text."""
    if text_variant == "subtitle":
        return line["text_uz"], "subtitle"
    s = line.get("suggested") or {}
    if use_suggested and s.get("status") == "SUGGESTED" and s.get("text_tts"):
        return s["text_tts"], "suggested"
    return line["text_tts"], "original"


def parse_sample(path: Path) -> list[dict]:
    items = []
    for raw in Path(path).read_text(encoding="utf-8").splitlines():
        raw = raw.strip()
        if not raw or raw.startswith("#"):
            continue
        sid, _, text = raw.partition("|")
        if not text.strip():
            raise SystemExit("bad sample line (need 'id | text'): %r" % raw)
        spoken, _, warns = uz_prep.prepare(text.strip())
        if warns:
            raise SystemExit("sample line %s cannot be expanded: %s" % (sid.strip(), warns))
        items.append({"id": sid.strip(), "text": text.strip(), "text_tts": spoken})
    if not items:
        raise SystemExit("no sample lines in %s" % path)
    return items


# --------------------------------------------------------------------------- synthesis with cache

class Synthesizer:
    def __init__(self, provider: Provider, voice: str, cache_dir: Path | None, apostrophe: str = "keep",
                 force: bool = False):
        self.provider, self.voice, self.cache_dir = provider, voice, cache_dir
        self.apostrophe, self.force = apostrophe, force
        self.api_calls = 0
        self.chars_sent = 0

    def synth(self, text: str) -> tuple[bytes, int, str]:
        send = map_apostrophes(text, self.apostrophe)
        key = hashlib.sha256("\x1f".join([self.provider.cache_tag(), self.voice, send]).encode("utf-8")).hexdigest()[:24]
        cfile = self.cache_dir / (key + ".wav") if self.cache_dir else None
        if cfile and cfile.exists() and not self.force:
            pcm, sr = synth.wav_bytes_to_pcm(cfile.read_bytes())
            return pcm, sr, send
        pcm, sr = self.provider.synthesize(send, self.voice)
        self.api_calls += 1
        self.chars_sent += len(send)
        if cfile:
            cfile.parent.mkdir(parents=True, exist_ok=True)
            cfile.write_bytes(synth.pcm_to_wav_bytes(pcm, sr))
        return pcm, sr, send


# --------------------------------------------------------------------------- one video

def next_starts(lines: list[dict], total_s: float) -> list[float]:
    return [lines[i + 1]["start_s"] if i + 1 < len(lines) else total_s for i in range(len(lines))]


def run_video(plan: dict, out_root: Path, *, synthesizer: Synthesizer | None, dry_run: bool = False,
              allow_unfit: bool = False, use_suggested: bool = False, max_tempo: float = MAX_TEMPO, slow_short: bool = False,
              loudnorm: bool = True, lufs: float = TARGET_LUFS, tp: float = TARGET_TP, tempo_fn=ffmpeg_tempo,
              rate_cps: float | None = None, text_variant: str = "spoken") -> dict:
    vid = plan["videoId"]
    total_s = plan["timeline"]["total_s"]
    lines = plan["lines"]
    rate = rate_cps or plan["assumptions"]["speech_rate_chars_per_s"]
    out_dir = out_root / vid / "uz"
    rows, clips, sr_seen = [], [], None
    for line in lines:
        text, variant = line_text(line, use_suggested, text_variant)
        avail = line["available_s"]
        hard = line["hard_end_s"] - line["start_s"]
        row = {"id": line["id"], "scene": line["scene"], "start_s": line["start_s"], "available_s": avail,
               "hard_s": round(hard, 3), "text_variant": variant, "chars_sent": len(text)}
        if dry_run:
            if variant == "subtitle":
                est = len(text) / rate
            else:
                est = line["suggested"]["est_speech_s"] if variant == "suggested" else line["est_speech_s"]
                est = est * plan["assumptions"]["speech_rate_chars_per_s"] / rate
            d = fit_decision(est, avail, hard, max_tempo=max_tempo,
                             slow_to=line["en_clip_s"] if slow_short else None)
            row.update(raw_s=None, trimmed_s=round(est, 3), estimated=True)
        else:
            pcm, sr, _ = synthesizer.synth(text)
            if sr_seen is None:
                sr_seen = sr
            elif sr != sr_seen:
                raise SystemExit("sample rate changed between lines (%d vs %d)" % (sr_seen, sr))
            fr = fit_clip(pcm, sr, avail, hard, max_tempo=max_tempo,
                          slow_to=line["en_clip_s"] if slow_short else None, tempo_fn=tempo_fn)
            d = fr.decision
            row.update(raw_s=round(fr.raw_s, 3), trimmed_s=round(fr.trimmed_s, 3), estimated=False)
            clips.append((line["start_s"], fr.pcm))
            write_wav(out_dir / "lines" / (line["id"] + ".wav"), fr.pcm, sr)
        row.update(status=d.status, tempo=d.tempo, final_s=round(d.final_s, 3), overflow_s=round(d.overflow_s, 3),
                   fits=d.fits)
        rows.append(row)
    unfit = [r["id"] for r in rows if r["status"] in ("overflow", "truncated")]
    truncated = [r["id"] for r in rows if r["status"] == "truncated"]
    report = {
        "schema": "labguide.voice_uz.report/1", "videoId": vid, "dry_run": dry_run, "timeline_total_s": total_s,
        "provider": None if dry_run else synthesizer.provider.name, "voice": None if dry_run else synthesizer.voice,
        "apostrophe": None if dry_run else synthesizer.apostrophe, "text_variant": "suggested" if use_suggested else "original",
        "voice_text": text_variant, "max_tempo": max_tempo, "lines": rows,
        "summary": {"lines": len(rows), "chars_sent": sum(r["chars_sent"] for r in rows),
                    "sped_up": sum(r["status"] == "sped_up" for r in rows),
                    "overflow": sum(r["status"] == "overflow" for r in rows),
                    "truncated": len(truncated), "unfit_ids": unfit,
                    "api_calls": 0 if dry_run else synthesizer.api_calls},
        "warnings": [],
        "review": "NEEDS_NATIVE_REVIEW - nobody has listened to this audio",
    }
    if dry_run:
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / "report.dry_run.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        return report
    pcm, warns = build_timeline(clips, total_s, sr_seen)
    report["warnings"] += warns
    raw_wav = out_dir / "voice_uz.raw.wav"
    # A track with cut-off lines must never be muxed by accident: it gets a different name unless --allow-unfit.
    final_wav = out_dir / ("voice_uz.wav" if (allow_unfit or not truncated) else "voice_uz.UNFIT.wav")
    if truncated and not allow_unfit:
        report["warnings"].append("lines %s were cut to fit: output named voice_uz.UNFIT.wav (shorten them or "
                                  "re-run with --allow-unfit)" % ", ".join(truncated))
    write_wav(raw_wav, pcm, sr_seen)
    if loudnorm:
        report["loudness"] = loudnorm_two_pass(raw_wav, final_wav, lufs=lufs, tp=tp)
        raw_wav.unlink()
    else:
        raw_wav.replace(final_wav)
        report["loudness"] = None
        report["warnings"].append("loudness normalisation skipped (--no-loudnorm): not -16 LUFS / -2.4 dBTP")
    with wave.open(str(final_wav), "rb") as w:
        report["output"] = {"file": str(final_wav), "sample_rate": w.getframerate(), "channels": w.getnchannels(),
                            "seconds": round(w.getnframes() / w.getframerate(), 3)}
    (out_dir / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    (out_dir / "report.md").write_text(report_markdown(report), encoding="utf-8")
    return report


def report_markdown(rep: dict) -> str:
    out = ["# Uzbek voice report - %s%s" % (rep["videoId"], " (dry run, estimates)" if rep["dry_run"] else ""), "",
           "Status: %s" % rep["review"], "",
           "| line | scene | start | slot s | trimmed s | tempo | final s | status |", "|---|---|---|---|---|---|---|---|"]
    for r in rep["lines"]:
        out.append("| %s | %s | %.2f | %.2f | %s | %.3f | %.2f | %s |" % (
            r["id"], r["scene"], r["start_s"], r["available_s"], r["trimmed_s"], r["tempo"], r["final_s"],
            r["status"] + (" (%.2f s over)" % r["overflow_s"] if r["overflow_s"] else "")))
    s = rep["summary"]
    out += ["", "lines %d, chars sent %d, sped up %d, overflow %d, truncated %d" % (
        s["lines"], s["chars_sent"], s["sped_up"], s["overflow"], s["truncated"])]
    if s["unfit_ids"]:
        out.append("Do not fit their slot: " + ", ".join(s["unfit_ids"]))
    if rep.get("loudness"):
        ls = rep["loudness"]
        out.append("Loudness: %.1f LUFS / %.1f dBTP -> %.1f LUFS / %.1f dBTP (target %g / %g)" % (
            ls["before"]["I"], ls["before"]["TP"], ls["after"]["I"], ls["after"]["TP"], ls["target"]["I"], ls["target"]["TP"]))
    for w in rep["warnings"]:
        out.append("WARNING: " + w)
    return "\n".join(out) + "\n"


# --------------------------------------------------------------------------- sample mode

def run_sample(items: list[dict], out_root: Path, synthesizer: Synthesizer, *, gap_s: float = 0.5,
               rate_cps: float = SPEECH_RATE_CPS, label: str = "", text_variant: str = "spoken") -> dict:
    out_dir = out_root / "voice_uz_sample"
    parts, rows, sr_seen = [], [], None
    for it in items:
        pcm, sr, sent = synthesizer.synth(it["text_tts"])
        sr_seen = sr_seen or sr
        t = trim_silence(pcm, sr)
        sec = pcm_seconds(t, sr)
        rows.append({"id": it["id"], "chars": len(sent), "seconds": round(sec, 2),
                     "chars_per_s": round(len(sent) / sec, 2) if sec else None,
                     "estimated_s": round(len(sent) / rate_cps, 2), "text_tts": it["text_tts"]})
        parts.append(t)
        write_wav(out_dir / ("%s%s.wav" % (it["id"], label)), t, sr)
    buf = b"".join(p + silence(gap_s, sr_seen) for p in parts)
    name = "sample%s.wav" % label
    write_wav(out_dir / name, buf, sr_seen)
    tot_chars, tot_s = sum(r["chars"] for r in rows), sum(r["seconds"] for r in rows)
    rep = {"schema": "labguide.voice_uz.sample/1", "file": str(out_dir / name), "lines": rows,
           "measured_chars_per_s": round(tot_chars / tot_s, 2) if tot_s else None,
           "assumed_chars_per_s": rate_cps, "total_seconds": round(tot_s, 2),
           "provider": synthesizer.provider.name, "voice": synthesizer.voice, "apostrophe": synthesizer.apostrophe,
           "text_variant": text_variant,
           "next_step": "Listen. If the measured rate differs, re-run tool/tts/plan_uz.py --rate <measured> to refresh the fit tables."}
    (out_dir / ("sample%s.json" % label)).write_text(json.dumps(rep, ensure_ascii=False, indent=2), encoding="utf-8")
    return rep


# --------------------------------------------------------------------------- CLI

def parse_args(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("plans", nargs="*", help="plan.json files (or use --video / --all)")
    ap.add_argument("--video", help="comma separated video ids")
    ap.add_argument("--all", action="store_true", help="all 9 videos")
    ap.add_argument("--provider", default="uzbekvoiceai", choices=["uzbekvoiceai", "azure", "gemini", "edge"],
                    help="uzbekvoiceai (default, voice shoira), azure (uz-UZ-MadinaNeural / uz-UZ-SardorNeural) or gemini (GEMINI_API_KEY, voice Fola)")
    ap.add_argument("--voice", default=None, help="uzbekvoiceai: shoira (default) lola kamola jasur sevinch; azure: uz-UZ-MadinaNeural (default) or uz-UZ-SardorNeural; gemini: Fola (default) Kore Puck Charon Leda Sulafat Zephyr ...")
    ap.add_argument("--voices", default=None, help="with --sample: comma separated voices, all synthesized in ONE run (one character cap, one process)")
    ap.add_argument("--text-variant", default="spoken", choices=["spoken", "subtitle", "both"],
                    help="spoken (default): the pure-Uzbek voice text; subtitle: the ORIGINAL written subtitle text (PDF, eGFR, mmol/L as written); both: only with --sample")
    ap.add_argument("--max-chars", type=int, default=None,
                    help="abort BEFORE any request when the planned characters of this run exceed N (also checked in --dry-run)")
    ap.add_argument("--gemini-model", default=GEMINI_DEFAULT_MODEL, help="Gemini model (default %s; also gemini-3.8-flash-lite-tts, previews gemini-3.1-flash-tts-preview, gemini-2.5-pro-preview-tts)" % GEMINI_DEFAULT_MODEL)
    ap.add_argument("--gemini-style", default="", help="Gemini speech_metadata.style (default empty); NEVER put style instructions into the text")
    ap.add_argument("--gemini-char-limit", type=int, default=40_000, help="local cumulative character budget for Gemini (a safety net; the free-tier limits are unknown)")
    ap.add_argument("--list-gemini-voices", action="store_true", help="GET /v1beta/voices?language_code=uz&page_size=50 and print the names (one request)")
    ap.add_argument("--out-root", default=str(DEFAULT_OUT_ROOT), help="default video_studio/out (gitignored)")
    ap.add_argument("--dry-run", action="store_true", help="no network, no keys: fit table from the plans' estimates")
    ap.add_argument("--sample", action="store_true", help="synthesize only docs/video/voice_uz/SAMPLE_TEXT.txt")
    ap.add_argument("--sample-file", default=str(SAMPLE_FILE))
    ap.add_argument("--apostrophe-variants", action="store_true", help="with --sample: keep / ascii / modifier spellings")
    ap.add_argument("--apostrophe", default="keep", choices=["keep", "ascii", "modifier"])
    ap.add_argument("--use-suggested", action="store_true", help="use the SUGGESTED shorter texts where a plan has them")
    ap.add_argument("--rate", help='Azure prosody rate, e.g. "-5%%" (default: none)')
    ap.add_argument("--rate-cps", type=float, help="override the plan's assumed chars/second (dry run)")
    ap.add_argument("--max-tempo", type=float, default=MAX_TEMPO)
    ap.add_argument("--slow-short", action="store_true", help="slow short clips down towards the English clip length (max -12 %%)")
    ap.add_argument("--no-loudnorm", action="store_true")
    ap.add_argument("--lufs", type=float, default=TARGET_LUFS)
    ap.add_argument("--tp", type=float, default=TARGET_TP)
    ap.add_argument("--allow-unfit", action="store_true", help="exit 0 even if lines were truncated")
    ap.add_argument("--force", action="store_true", help="ignore the synthesis cache")
    ap.add_argument("--uzv-auth", default=None, choices=["raw", "bearer"], help="UzbekVoice Authorization scheme (default raw)")
    ap.add_argument("--uzv-async", action="store_true", help="UzbekVoice: blocking=false + poll /tasks (default blocking=true)")
    ap.add_argument("--uzv-char-limit", type=int, default=19_000,
                    help="local cumulative character budget for UzbekVoice (10 000 so'm = 20 000 chars; a 165-char sample was already spent)")
    ap.add_argument("--price-per-char", type=float, default=0.5, help="so'm per character, shown in dry-run cost lines (owner's figure, unverified)")
    ap.add_argument("--edge-pkgs", default=None, help="directory holding the edge_tts package (provider edge)")
    ap.add_argument("--azure-char-limit", type=int, default=450_000)
    ap.add_argument("--min-interval", type=float, default=None, help="seconds between requests (default: Azure 3.2 = F0 20 per 60 s; Gemini 6)")
    return ap.parse_args(argv)


def cost_note(a, chars: int) -> str:
    if a.provider == "gemini":
        return " (Gemini is billed per audio token, not per character; the character count is only the size estimate)"
    return (" = about %.0f so'm at %g so'm/char (owner's figure for UzbekVoice, unverified)" % (chars * a.price_per_char, a.price_per_char)
            if a.provider == "uzbekvoiceai" else "")


def sample_items_for(items: list[dict], variant: str) -> list[dict]:
    """spoken: text_tts (pure Uzbek) is sent; subtitle: the written text as in the sample file."""
    if variant == "subtitle":
        return [dict(it, text_tts=it["text"]) for it in items]
    return items


def check_cap(planned: int, cap: int | None, what: str) -> None:
    if cap is not None and planned > cap:
        raise SystemExit("character cap: %s would send %d characters > --max-chars %d. Nothing was sent. "
                         "(Shorten the text / fewer voices, or raise the cap on purpose.)" % (what, planned, cap))


def planned_video_chars(plan: dict, use_suggested: bool, text_variant: str) -> int:
    return sum(len(line_text(l, use_suggested, text_variant)[0]) for l in plan["lines"])


def main(argv=None) -> int:
    a = parse_args(argv)
    out_root = Path(a.out_root)
    if a.voice is None:
        a.voice = ("uz-UZ-MadinaNeural" if a.provider in ("azure", "edge")
                   else GEMINI_DEFAULT_VOICE if a.provider == "gemini" else UzbekVoiceAIProvider.DEFAULT_MODEL)
    if a.provider in ("azure", "edge") and a.voice not in AZURE_VOICES:
        print("note: voice %r is not one of %s" % (a.voice, ", ".join(AZURE_VOICES)), file=sys.stderr)
    if a.text_variant != "spoken" and a.provider != "gemini":
        print("note: --text-variant %s sends text the provider was not tested with (written terms such as PDF/eGFR); "
              "meant for Gemini" % a.text_variant, file=sys.stderr)
    if a.list_gemini_voices:
        for n in make_provider("gemini", a).list_voices("uz", 50):
            print(n)
        return 0

    if a.sample:
        if a.voices and a.provider != "gemini":
            raise SystemExit("--voices is only for --provider gemini (use --voice otherwise)")
        base_items = parse_sample(Path(a.sample_file))
        variants = ["spoken", "subtitle"] if a.text_variant == "both" else [a.text_variant]
        voices = [v.strip() for v in a.voices.split(",") if v.strip()] if a.voices else [a.voice]
        apos = ["keep", "ascii", "modifier"] if a.apostrophe_variants else [a.apostrophe]
        per_variant = {v: sum(len(i["text_tts"]) for i in sample_items_for(base_items, v)) for v in variants}
        planned = sum(per_variant.values()) * len(voices) * len(apos)
        check_cap(planned, a.max_chars, "the sample run (%d voice(s) x %d text variant(s))" % (len(voices), len(variants)))
        if a.dry_run:
            tot = 0.0
            for v in variants:
                for it in sample_items_for(base_items, v):
                    est = len(it["text_tts"]) / SPEECH_RATE_CPS
                    tot += est
                    print("%s%s  %3d chars  ~%.1f s   %s" % (it["id"], " [%s]" % v if len(variants) > 1 or v != "spoken" else "",
                                                               len(it["text_tts"]), est, it["text_tts"]))
            print("one voice: ~%.1f s (at the measured %g chars/s), %d characters; this run (%d voice(s)): %d characters%s; "
                  "nothing was sent" % (tot, SPEECH_RATE_CPS, sum(per_variant.values()), len(voices), planned, cost_note(a, planned)))
            return 0
        provider = make_provider(a.provider, a)
        failed, done = [], 0
        for voice in voices:
            try:
                for v in apos:
                    for tv in variants:
                        parts = []
                        if a.apostrophe_variants:
                            parts.append(v)
                        if a.provider == "gemini" or len(voices) > 1:
                            parts.append(voice)
                        if a.provider == "gemini" or tv != "spoken" or len(variants) > 1:
                            parts.append(tv)
                        label = ("_" + "_".join(parts)) if parts else ""
                        sy = Synthesizer(provider, voice, out_root / ".cache_uz", v, a.force)
                        rep = run_sample(sample_items_for(base_items, tv), out_root, sy, label=label, text_variant=tv)
                        done += 1
                        print("sample [%s, %s, %s]: %s  %.1f s, measured %.1f chars/s (plans use %g)" % (
                            voice, v, tv, rep["file"], rep["total_seconds"], rep["measured_chars_per_s"] or 0, SPEECH_RATE_CPS))
            except SystemExit as e:  # one failing voice must not hide the others, unless nothing worked at all
                print("voice %s FAILED: %s" % (voice, e), file=sys.stderr)
                failed.append(voice)
                if not done or len(voices) == 1:
                    return 1
        if failed:
            print("failed voices: %s" % ", ".join(failed), file=sys.stderr)
            return 1
        return 0

    ids = VIDEOS if a.all else (a.video.split(",") if a.video else [])
    paths = [Path(p) for p in a.plans] + [plan_path(v) for v in ids]
    if not paths:
        print("nothing to do: give plan.json files, --video ID[,ID] or --all (or --sample)", file=sys.stderr)
        return 2
    if a.text_variant == "both":
        raise SystemExit("--text-variant both is only for --sample")
    plans = [load_plan(p) for p in paths]
    planned = sum(planned_video_chars(pl, a.use_suggested, a.text_variant) for pl in plans)
    check_cap(planned, a.max_chars, "this run (%d video(s))" % len(plans))
    provider = None if a.dry_run else make_provider(a.provider, a)
    unfit_any = False
    total_chars = 0
    for plan in plans:
        sy = None if a.dry_run else Synthesizer(provider, a.voice, out_root / ".cache_uz", a.apostrophe, a.force)
        rep = run_video(plan, out_root, synthesizer=sy, dry_run=a.dry_run, allow_unfit=a.allow_unfit,
                        use_suggested=a.use_suggested,
                        max_tempo=a.max_tempo, slow_short=a.slow_short, loudnorm=not a.no_loudnorm,
                        lufs=a.lufs, tp=a.tp, rate_cps=a.rate_cps, text_variant=a.text_variant)
        s = rep["summary"]
        print("%-12s lines %2d  chars %5d  sped_up %2d  overflow %2d  truncated %2d%s" % (
            rep["videoId"], s["lines"], s["chars_sent"], s["sped_up"], s["overflow"], s["truncated"],
            "  [dry run]" if a.dry_run else "  -> %s" % rep["output"]["file"]))
        if s["unfit_ids"]:
            print("   do not fit their slot: " + " ".join(s["unfit_ids"]))
        unfit_any = unfit_any or bool(s["truncated"])
        total_chars += s["chars_sent"]
    print("characters %s: %d%s" % ("to send" if a.dry_run else "sent or cached", total_chars, cost_note(a, total_chars)))
    if unfit_any and not a.allow_unfit and not a.dry_run:
        print("some lines were truncated: shorten them (--use-suggested, owner edits) or pass --allow-unfit",
              file=sys.stderr)
        return EXIT_UNFIT
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
