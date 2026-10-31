"""Offline tests for the Uzbek voice pipeline (python3 -m unittest discover -s tool/tts -p 'test_*.py').

No network, no keys: Azure is exercised through a fake HTTP function, the audio providers are fakes. Tests that need
ffmpeg are skipped when it is missing. Files touched: temp directories only.
"""
import contextlib
import io
import json
import math
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest
import wave
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import plan_uz  # noqa: E402
import remux_uz  # noqa: E402
import synth  # noqa: E402
import synth_uz as su  # noqa: E402
import uz_prep  # noqa: E402

REPO = Path(__file__).resolve().parent.parent.parent
HAVE_FFMPEG = bool(shutil.which("ffmpeg") and shutil.which("ffprobe"))
SR = 16000


def tone(seconds, sr=SR, freq=220.0, amp=8000):
    n = int(sr * seconds)
    return struct.pack("<%dh" % n, *[int(amp * math.sin(2 * math.pi * freq * i / sr)) for i in range(n)])


def naive_tempo(pcm, sr, tempo):
    """Test-only tempo change (resampling, changes pitch): enough to check durations."""
    import array
    a = array.array("h")
    a.frombytes(pcm)
    n = int(len(a) / tempo)
    return array.array("h", [a[min(len(a) - 1, int(i * tempo))] for i in range(n)]).tobytes()


def wav_seconds(path):
    with wave.open(str(path), "rb") as w:
        return w.getnframes() / w.getframerate(), w.getframerate(), w.getnchannels()


class FakeProvider(su.Provider):
    """sec_per_char tone per request; records what it was asked."""
    name = "fake"

    def __init__(self, sec_per_char=0.07, sr=SR):
        self.spc, self.sr, self.calls = sec_per_char, sr, []

    def synthesize(self, text, voice):
        self.calls.append((text, voice))
        return silence_pad(tone(len(text) * self.spc, self.sr), self.sr), self.sr


def silence_pad(pcm, sr, head=0.2, tail=0.3):
    return su.silence(head, sr) + pcm + su.silence(tail, sr)


class FitDecisionTests(unittest.TestCase):
    def test_fits_untouched(self):
        d = su.fit_decision(2.0, 3.0, 3.1)
        self.assertEqual((d.status, d.tempo, d.fits), ("ok", 1.0, True))

    def test_speed_up_within_12_percent(self):
        d = su.fit_decision(3.3, 3.0, 3.1)  # needs 1.10
        self.assertEqual(d.status, "sped_up")
        self.assertTrue(1.09 < d.tempo <= 1.12)
        self.assertLessEqual(d.final_s, 3.0 + 1e-6)
        self.assertTrue(d.fits)

    def test_speed_up_never_above_cap(self):
        d = su.fit_decision(4.0, 3.0, 3.1)
        self.assertEqual(d.tempo, su.MAX_TEMPO)
        self.assertNotEqual(d.status, "sped_up")

    def test_overflow_into_guard_gap(self):
        d = su.fit_decision(3.4, 3.0, 3.1)  # 3.4/1.12 = 3.036 > 3.0 but <= 3.1
        self.assertEqual(d.status, "overflow")
        self.assertFalse(d.fits)
        self.assertAlmostEqual(d.overflow_s, 3.4 / 1.12 - 3.0, 4)

    def test_truncated_when_beyond_hard_limit(self):
        d = su.fit_decision(5.0, 3.0, 3.1)
        self.assertEqual(d.status, "truncated")
        self.assertEqual(d.final_s, 3.1)

    def test_slow_short_clip_bounded(self):
        d = su.fit_decision(2.0, 5.0, 5.1, slow_to=4.0)
        self.assertEqual(d.status, "slowed")
        self.assertEqual(d.tempo, su.MIN_TEMPO)  # 2.0/4.0 = 0.5 -> clamped to 0.88
        d2 = su.fit_decision(3.8, 5.0, 5.1, slow_to=4.0)
        self.assertTrue(0.88 <= d2.tempo < 1.0)
        d3 = su.fit_decision(2.0, 5.0, 5.1)  # no slow_to: just pad
        self.assertEqual(d3.status, "ok")


class AudioHelperTests(unittest.TestCase):
    def test_trim_silence(self):
        pcm = silence_pad(tone(1.0), SR, head=0.5, tail=0.7)
        t = su.trim_silence(pcm, SR)
        self.assertAlmostEqual(su.pcm_seconds(t, SR), 1.0 + 0.03 + 0.08, delta=0.03)
        self.assertEqual(su.trim_silence(su.silence(1.0, SR), SR), b"")

    def test_fit_clip_speeds_up_and_pads(self):
        pcm = silence_pad(tone(3.3), SR)
        r = su.fit_clip(pcm, SR, available=3.2, hard=3.3, tempo_fn=naive_tempo)
        self.assertEqual(r.decision.status, "sped_up")
        self.assertLessEqual(su.pcm_seconds(r.pcm, SR), 3.2 + 0.01)

    def test_fit_clip_truncates_with_fade(self):
        pcm = tone(6.0)
        r = su.fit_clip(pcm, SR, available=3.0, hard=3.1, tempo_fn=naive_tempo, trim=False)
        self.assertEqual(r.decision.status, "truncated")
        self.assertAlmostEqual(su.pcm_seconds(r.pcm, SR), 3.1, delta=0.01)
        import array
        a = array.array("h")
        a.frombytes(r.pcm)
        self.assertLess(abs(a[-1]), 200)  # faded to ~0

    def test_timeline_places_clips_on_the_english_timeline(self):
        c1, c2 = tone(1.0), tone(0.5)
        buf, warns = su.build_timeline([(2.0, c2), (0.25, c1)], total_s=5.0, sr=SR)
        self.assertEqual(warns, [])
        self.assertEqual(len(buf) // 2, 5 * SR)
        import array
        a = array.array("h")
        a.frombytes(buf)
        self.assertEqual(max(abs(x) for x in a[: int(0.25 * SR) - 1]), 0)       # silence before first clip
        self.assertGreater(max(abs(x) for x in a[int(0.3 * SR): int(1.2 * SR)]), 1000)
        self.assertEqual(max(abs(x) for x in a[int(1.4 * SR): int(1.9 * SR)]), 0)  # gap
        self.assertGreater(max(abs(x) for x in a[int(2.05 * SR): int(2.4 * SR)]), 1000)
        self.assertEqual(max(abs(x) for x in a[int(2.6 * SR):]), 0)

    def test_timeline_warns_on_overlap_and_overrun(self):
        buf, warns = su.build_timeline([(0.0, tone(1.0)), (0.5, tone(1.0)), (2.5, tone(1.0))], total_s=3.0, sr=SR)
        self.assertEqual(len(buf) // 2, 3 * SR)
        self.assertTrue(any("overlap" in w for w in warns))
        self.assertTrue(any("past the end" in w for w in warns))

    @unittest.skipUnless(HAVE_FFMPEG, "ffmpeg missing")
    def test_ffmpeg_atempo_changes_duration(self):
        out = su.ffmpeg_tempo(tone(2.0), SR, 1.1)
        self.assertAlmostEqual(su.pcm_seconds(out, SR), 2.0 / 1.1, delta=0.06)

    @unittest.skipUnless(HAVE_FFMPEG, "ffmpeg missing")
    def test_loudnorm_two_pass_hits_target(self):
        with tempfile.TemporaryDirectory() as d:
            src, dst = Path(d) / "a.wav", Path(d) / "b.wav"
            su.write_wav(src, tone(8.0, sr=SR, amp=3000), SR)
            m = su.loudnorm_two_pass(src, dst)
            self.assertAlmostEqual(m["after"]["I"], -16.0, delta=1.0)
            self.assertLessEqual(m["after"]["TP"], -2.0)
            secs, sr, ch = wav_seconds(dst)
            self.assertEqual((sr, ch), (48000, 1))
            self.assertAlmostEqual(secs, 8.0, delta=0.05)


class TextTests(unittest.TestCase):
    def test_apostrophe_styles(self):
        t = "o‘zbek g‘isht me’yor"
        self.assertEqual(su.map_apostrophes(t, "keep"), t)
        self.assertEqual(su.map_apostrophes(t, "ascii"), "o'zbek g'isht me'yor")
        m = su.map_apostrophes(t, "modifier")
        self.assertIn("oʻzbek", m)
        self.assertIn("gʻisht", m)
        self.assertIn("meʼyor", m)
        with self.assertRaises(ValueError):
            su.map_apostrophes(t, "x")

    def test_prep_hard_terms(self):
        sp, used, warns = uz_prep.prepare("Levey–Jennings, Westgard, eGFR, qPCR, GC-MS, 5 mmol/L.")
        self.assertEqual(sp, "Livi Jenings, Vestgard, e ge ef er, kyu pe se er, ji si em es, besh millimol litr.")
        self.assertEqual(warns, [])
        self.assertTrue(all(u["risk"] in ("LOW", "MEDIUM", "HIGH") for u in used))

    def test_prep_numbers_dates_symbols(self):
        sp, _, w = uz_prep.prepare("o‘rtachadan +2,3 SD; 1-3s va R-4s; 22-siklda; 10 % i; 2–5 bo‘lak")
        self.assertEqual(sp, "o‘rtachadan plyus ikki vergul uch es de; bir uch es va er to‘rt es; "
                             "yigirma ikkinchi siklda; o‘n foizi; ikkidan beshgacha bo‘lak")
        self.assertEqual(w, [])
        sp, _, w = uz_prep.prepare("Tahlil 15.03.2026 sanasida.")
        self.assertTrue(any("date" in x or "digit" in x for x in w))  # dates are NOT silently expanded
        sp, _, _ = uz_prep.prepare("1,52", decimal="formal")
        self.assertEqual(sp, "bir butun yuzdan ellik ikki")

    def test_prep_suffix_and_brand(self):
        self.assertEqual(uz_prep.prepare("LabGuide’da PDF’da SOP’idan")[0], "Leb Gaydda pe de ef da es o pe idan")

    def test_banned_words_never_in_prep_output(self):
        for t in ("Natija KDIGO kategoriyasi.",):
            self.assertIsNone(uz_prep.BANNED.search(uz_prep.prepare(t)[0]))

    def test_sample_file(self):
        items = su.parse_sample(REPO / "docs/video/voice_uz/SAMPLE_TEXT.txt")
        self.assertEqual([i["id"] for i in items], ["S1", "S2", "S3"])
        total = sum(len(i["text_tts"]) for i in items) / 13.0
        self.assertTrue(10 <= total <= 20, total)
        src = json.loads((REPO / "docs/video/overview/lines.uz.json").read_text(encoding="utf-8"))["lines"]
        self.assertEqual(items[0]["text"], src["L01"])
        self.assertEqual(items[1]["text"], src["L02"])
        self.assertIsNone(uz_prep.BANNED.search(Path(REPO / "docs/video/voice_uz/SAMPLE_TEXT.txt").read_text(encoding="utf-8")))


class AzureProviderTests(unittest.TestCase):
    KEY = "SECRET-KEY-0123456789abcdef"

    def make(self, responses, **kw):
        calls = []

        def post(url, headers, body):
            calls.append((url, dict(headers), body))
            return responses.pop(0)

        with tempfile.TemporaryDirectory() as d:
            guard = synth.QuotaGuard(path=Path(d) / "u.json", limit=kw.pop("limit", 450_000))
            p = su.AzureProvider(key=self.KEY, region="westeurope", http_post=post, guard=guard,
                                 sleep=lambda s: None, min_interval_s=0, **kw)
            return p, calls, d

    def wav(self, seconds=0.5, sr=48000):
        return synth.pcm_to_wav_bytes(tone(seconds, sr), sr)

    def test_request_shape_and_output(self):
        p, calls, _ = self.make([(200, self.wav(), {})])
        pcm, sr = p.synthesize("Salom <dunyo> & hamma", "uz-UZ-MadinaNeural")
        self.assertEqual(sr, 48000)
        url, headers, body = calls[0]
        self.assertEqual(url, "https://westeurope.tts.speech.microsoft.com/cognitiveservices/v1")
        self.assertEqual(headers["X-Microsoft-OutputFormat"], "riff-48khz-16bit-mono-pcm")
        self.assertEqual(headers["Content-Type"], "application/ssml+xml")
        self.assertEqual(headers["Ocp-Apim-Subscription-Key"], self.KEY)
        ssml = body.decode("utf-8")
        self.assertIn("xml:lang='uz-UZ'", ssml)
        self.assertIn("name='uz-UZ-MadinaNeural'", ssml)
        self.assertIn("Salom &lt;dunyo&gt; &amp; hamma", ssml)
        self.assertNotIn("<phoneme", ssml)       # unsupported for uz-UZ
        self.assertNotIn("<lexicon", ssml)
        self.assertNotIn(self.KEY, ssml)

    def test_sardor_and_prosody_rate(self):
        p, calls, _ = self.make([(200, self.wav(), {})], rate="-5%")
        p.synthesize("x", "uz-UZ-SardorNeural")
        ssml = calls[0][2].decode()
        self.assertIn("uz-UZ-SardorNeural", ssml)
        self.assertIn('<prosody rate="-5%">x</prosody>', ssml)

    def test_retry_on_429_then_ok(self):
        p, calls, _ = self.make([(429, b"", {"Retry-After": "1"}), (200, self.wav(), {})])
        p.synthesize("x", "uz-UZ-MadinaNeural")
        self.assertEqual(len(calls), 2)

    def test_error_never_leaks_key(self):
        p, _, _ = self.make([(401, ("denied for " + self.KEY).encode(), {})])
        with self.assertRaises(SystemExit) as cm:
            p.synthesize("x", "uz-UZ-MadinaNeural")
        self.assertNotIn(self.KEY, str(cm.exception))
        self.assertNotIn(self.KEY, repr(p))
        self.assertIn("<hidden>", str(cm.exception))

    def test_quota_guard_blocks_before_any_request(self):
        p, calls, _ = self.make([(200, self.wav(), {})], limit=3)
        with self.assertRaises(SystemExit):
            p.synthesize("long text", "uz-UZ-MadinaNeural")
        self.assertEqual(calls, [])

    def test_missing_env_is_a_clear_exit(self):
        old = {k: os.environ.pop(k, None) for k in ("AZURE_SPEECH_KEY", "AZURE_SPEECH_REGION")}
        try:
            with self.assertRaises(SystemExit) as cm:
                su.AzureProvider()
            self.assertIn("AZURE_SPEECH_KEY", str(cm.exception))
        finally:
            for k, v in old.items():
                if v is not None:
                    os.environ[k] = v

class UzbekVoiceProviderTests(unittest.TestCase):
    KEY = "UZV-SECRET-KEY-98765"

    def wav(self, seconds=0.4, sr=24000):
        return synth.pcm_to_wav_bytes(tone(seconds, sr), sr)

    def make(self, posts, gets=None, **kw):
        post_calls, get_calls, diag = [], [], []
        posts, gets = list(posts), list(gets or [])

        def post(url, headers, body):
            post_calls.append((url, dict(headers), body))
            return posts.pop(0)

        def get(url, headers):
            get_calls.append((url, dict(headers)))
            return gets.pop(0)

        kw.setdefault("sleep", lambda s: None)
        p = su.UzbekVoiceAIProvider(key=self.KEY, http_post=post, http_get=get, diag=diag.append, **kw)
        return p, post_calls, get_calls, diag

    def test_request_shape_default_voice_and_no_deprecated_mood(self):
        p, posts, _, _ = self.make([(200, self.wav(), {"Content-Type": "audio/wav"})])
        pcm, sr = p.synthesize("Salom", "shoira")
        self.assertEqual(sr, 24000)
        url, headers, body = posts[0]
        self.assertEqual(url, "https://uzbekvoice.ai/api/v1/tts")
        self.assertEqual(headers["Authorization"], self.KEY)                  # raw key, as in the docs
        self.assertEqual(headers["Content-Type"], "application/json")
        j = json.loads(body.decode("utf-8"))
        self.assertEqual(j, {"text": "Salom", "model": "shoira", "blocking": True})
        self.assertNotIn("mood", j)
        self.assertEqual(su.UzbekVoiceAIProvider.DEFAULT_MODEL, "shoira")

    def test_bearer_scheme_and_async_flag(self):
        p, posts, _, _ = self.make([(200, self.wav(), {})], auth_scheme="bearer", blocking=False)
        p.synthesize("x", "lola")
        self.assertEqual(posts[0][1]["Authorization"], "Bearer " + self.KEY)
        self.assertFalse(json.loads(posts[0][2])["blocking"])

    def test_rejects_unknown_model(self):
        p, posts, _, _ = self.make([])
        with self.assertRaises(SystemExit):
            p.synthesize("x", "uz-UZ-MadinaNeural")
        self.assertEqual(posts, [])

    def test_json_with_url_is_downloaded_without_leaking_key_to_other_hosts(self):
        j = json.dumps({"result": {"url": "https://cdn.example.org/a/b.wav"}, "state": "done"}).encode()
        p, _, gets, _ = self.make([(200, j, {"Content-Type": "application/json"})], gets=[(200, self.wav(), {})])
        pcm, sr = p.synthesize("x", "shoira")
        self.assertEqual(gets[0][0], "https://cdn.example.org/a/b.wav")
        self.assertNotIn("Authorization", gets[0][1])

    def test_json_with_base64(self):
        import base64
        j = json.dumps({"audio": base64.b64encode(self.wav()).decode()}).encode()
        p, _, _, _ = self.make([(200, j, {})])
        pcm, sr = p.synthesize("x", "shoira")
        self.assertGreater(len(pcm), 1000)

    def test_async_task_polling(self):
        start = json.dumps({"task_id": "t-123"}).encode()
        running = json.dumps({"id": "t-123", "state": "PENDING", "result": {}}).encode()
        done = json.dumps({"id": "t-123", "state": "SUCCESS", "result": {"audio_url": "https://uzbekvoice.ai/files/t.wav"}}).encode()
        p, _, gets, _ = self.make([(202, start, {})], gets=[(200, running, {}), (200, done, {}), (200, self.wav(), {})],
                                  blocking=False)
        pcm, sr = p.synthesize("x", "shoira")
        self.assertEqual(gets[0][0], "https://uzbekvoice.ai/api/v1/tasks?id=t-123")
        self.assertEqual(gets[0][1]["Authorization"], self.KEY)               # same headers as the docs say
        self.assertEqual(gets[2][0], "https://uzbekvoice.ai/files/t.wav")
        self.assertEqual(gets[2][1]["Authorization"], self.KEY)               # own host: key allowed
        self.assertGreater(len(pcm), 1000)

    def test_task_failure_and_timeout(self):
        start = json.dumps({"task_id": "t"}).encode()
        p, _, _, _ = self.make([(200, start, {})], gets=[(200, json.dumps({"state": "failed"}).encode(), {})])
        with self.assertRaises(SystemExit):
            p.synthesize("x", "shoira")
        p, _, _, _ = self.make([(200, start, {})], gets=[(200, json.dumps({"state": "queued"}).encode(), {})] * 5,
                               poll_interval_s=1.0, poll_timeout_s=3.0)
        with self.assertRaises(SystemExit) as cm:
            p.synthesize("x", "shoira")
        self.assertIn("not finished", str(cm.exception))

    def test_first_call_diagnostic_is_printed_once_and_has_no_secret(self):
        p, _, _, diag = self.make([(200, self.wav(), {"Content-Type": "audio/wav"}), (200, self.wav(), {})])
        p.synthesize("one", "shoira")
        p.synthesize("two", "shoira")
        text = "\n".join(diag)
        self.assertEqual(text.count("first-call diagnostic"), 1)
        self.assertIn("binary audio (wav)", text)
        self.assertIn("container wav, 24000 Hz", text)
        self.assertNotIn(self.KEY, text)

    def test_errors_never_leak_the_key(self):
        p, _, _, diag = self.make([(401, ("bad key " + self.KEY).encode(), {})])
        with self.assertRaises(SystemExit) as cm:
            p.synthesize("x", "shoira")
        self.assertNotIn(self.KEY, str(cm.exception) + repr(p) + "".join(diag))
        p, _, _, _ = self.make([(500, ("boom " + self.KEY).encode(), {})])
        with self.assertRaises(SystemExit) as cm:
            p.synthesize("x", "shoira")
        self.assertNotIn(self.KEY, str(cm.exception))

    def test_unrecognised_response_is_a_clear_exit(self):
        p, _, _, diag = self.make([(200, b"<html>hi</html>", {"Content-Type": "text/html"})])
        with self.assertRaises(SystemExit):
            p.synthesize("x", "shoira")
        self.assertIn("neither audio nor JSON", "\n".join(diag))

    def test_retry_on_429(self):
        p, posts, _, _ = self.make([(429, b"", {"Retry-After": "1"}), (200, self.wav(), {})])
        p.synthesize("x", "shoira")
        self.assertEqual(len(posts), 2)

    def test_char_budget_blocks_before_any_request(self):
        with tempfile.TemporaryDirectory() as d:
            b = su.CharBudget(Path(d) / "u.json", limit=10)
            p, posts, _, _ = self.make([(200, self.wav(), {})], budget=b)
            with self.assertRaises(SystemExit):
                p.synthesize("this text is longer than ten characters", "shoira")
            self.assertEqual(posts, [])
            p, posts, _, _ = self.make([(200, self.wav(), {})], budget=b)
            p.synthesize("short", "shoira")
            self.assertEqual(b.used(), 5)

    def test_missing_key_and_bad_settings(self):
        old = os.environ.pop("UZBEKVOICE_API_KEY", None)
        try:
            with self.assertRaises(SystemExit) as cm:
                su.UzbekVoiceAIProvider()
            self.assertIn("UZBEKVOICE_API_KEY", str(cm.exception))
        finally:
            if old is not None:
                os.environ["UZBEKVOICE_API_KEY"] = old
        with self.assertRaises(SystemExit):
            su.UzbekVoiceAIProvider(key="k", auth_scheme="basic")
        with self.assertRaises(SystemExit):
            su.UzbekVoiceAIProvider(key="k", base_url="http://uzbekvoice.ai/api/v1")

    @unittest.skipUnless(HAVE_FFMPEG, "ffmpeg missing")
    def test_mp3_response_is_decoded_through_ffmpeg(self):
        with tempfile.TemporaryDirectory() as d:
            w = Path(d) / "a.wav"
            su.write_wav(w, tone(0.5, 24000), 24000)
            mp3 = Path(d) / "a.mp3"
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(w), str(mp3)], check=True)
            p, _, _, diag = self.make([(200, mp3.read_bytes(), {"Content-Type": "audio/mpeg"})])
            pcm, sr = p.synthesize("x", "shoira")
            self.assertEqual(sr, 48000)
            self.assertAlmostEqual(su.pcm_seconds(pcm, sr), 0.5, delta=0.15)

    def test_default_provider_and_voice_in_cli_dry_run(self):
        args = su.parse_args([])
        self.assertEqual(args.provider, "uzbekvoiceai")
        self.assertIsNone(args.voice)          # resolved to shoira in main()



class PlanTests(unittest.TestCase):
    """The nine committed plans against the repository's own sources (offline)."""

    def plans(self):
        for v in plan_uz.VIDEOS:
            yield v, su.load_plan(su.plan_path(v))

    def test_all_nine_plans_are_consistent_with_timing_and_scripts(self):
        for v, plan in self.plans():
            timing = json.loads((REPO / "video_studio/public/audio/en" / ("%s.timing.json" % v)).read_text())
            uz = json.loads((REPO / "docs/video" / v / "lines.uz.json").read_text(encoding="utf-8"))["lines"]
            ids = [l["id"] for l in plan["lines"]]
            self.assertEqual(ids, [t["id"] for t in timing["lines"]], v)
            self.assertEqual(plan["timeline"]["total_s"], timing["totalSec"])
            prev_end = 0
            for l, t in zip(plan["lines"], timing["lines"]):
                self.assertAlmostEqual(l["start_s"], t["start"], 3)
                self.assertAlmostEqual(l["end_s"], t["end"], 3)
                self.assertGreater(l["available_s"], 0.5)
                self.assertGreaterEqual(l["available_s"], l["en_clip_s"] - 1e-6)
                self.assertGreaterEqual(l["hard_end_s"], l["start_s"] + l["available_s"] - 1e-6)
                self.assertGreaterEqual(l["start_s"], prev_end - 1e-6)
                prev_end = l["end_s"]
                self.assertEqual(l["review"] in ("NEEDS_NATIVE_REVIEW", "NEEDS_MANUAL"), True)
                self.assertEqual(l["chars_written"], len(l["text_uz"]))
                self.assertEqual(l["chars_spoken"], len(l["text_tts"]))
                self.assertNotRegex(l["text_tts"], r"\d")
                if (l["text_uz_template"] or l["text_uz"]) != uz[l["id"]]:   # only the one replaced word may differ
                    self.assertTrue(any("SOURCE_TERM_REPLACED" in n for n in l["notes"]), (v, l["id"]))
                if l["fit"].startswith("TOO_LONG"):
                    self.assertIsNotNone(l["suggested"], (v, l["id"]))
                else:
                    self.assertIsNone(l["suggested"], (v, l["id"]))
            self.assertEqual(plan["summary"]["lines"], len(ids))

    def test_no_banned_words_in_any_voice_file(self):
        files = list((REPO / "docs/video/voice_uz").glob("*")) + [
            f for v in plan_uz.VIDEOS for f in (REPO / "docs/video" / v / "voice_uz").glob("*")]
        files += [REPO / "tool/tts" / n for n in ("uz_prep.py", "plan_uz.py", "synth_uz.py", "remux_uz.py", "test_synth_uz.py")]
        files += [REPO / "video_studio/scripts/dump_resolved_lines.mjs"]
        self.assertGreater(len(files), 30)
        for f in files:
            self.assertIsNone(uz_prep.BANNED.search(f.read_text(encoding="utf-8")), str(f))

    def test_suggestions_are_shorter_and_marked(self):
        for v, plan in self.plans():
            for l in plan["lines"]:
                s = l["suggested"]
                if s and s["status"] == "SUGGESTED":
                    self.assertLess(s["chars_spoken"], l["chars_spoken"], (v, l["id"]))
                    self.assertEqual(s["review"], "NEEDS_NATIVE_REVIEW")
                    self.assertNotRegex(s["text_tts"], r"\d")

    def test_csv_and_glossary_exist(self):
        for v in plan_uz.VIDEOS:
            d = REPO / "docs/video" / v / "voice_uz"
            rows = (d / "plan.csv").read_text(encoding="utf-8").strip().splitlines()
            plan = su.load_plan(d / "plan.json")
            self.assertEqual(len(rows) - 1, len(plan["lines"]))
            head = (d / "pronunciation_uz.csv").read_text(encoding="utf-8").splitlines()[0]
            self.assertTrue(head.startswith("term,written,spoken_respelling,risk"))

    def test_judge_rules(self):
        self.assertEqual(plan_uz.judge(3.0, 4.0, 3.5)["fit"], "OK")
        self.assertEqual(plan_uz.judge(1.0, 4.0, 3.5)["fit"], "TOO_SHORT")
        j = plan_uz.judge(5.0, 4.0, 4.0)  # 5/1.12 = 4.464
        self.assertEqual(j["fit"], "TOO_LONG by 0.46 s")
        self.assertEqual(plan_uz.judge(4.4, 4.0, 4.0)["fit"], "OK")  # 10 % speed-up is enough


class EndToEndTests(unittest.TestCase):
    def plan(self, **over):
        lines = [
            {"id": "L01", "scene": "a", "start_s": 0.25, "end_s": 2.0, "en_clip_s": 1.75, "available_s": 2.0,
             "hard_end_s": 2.38, "text_tts": "a" * 20, "est_speech_s": 1.5, "suggested": None},
            {"id": "L02", "scene": "a", "start_s": 2.5, "end_s": 4.0, "en_clip_s": 1.5, "available_s": 1.4,
             "hard_end_s": 4.5, "text_tts": "b" * 20, "est_speech_s": 1.5,
             "suggested": {"status": "SUGGESTED", "text_tts": "b" * 10, "est_speech_s": 0.8}},
            {"id": "L03", "scene": "b", "start_s": 4.6, "end_s": 6.0, "en_clip_s": 1.4, "available_s": 1.0,
             "hard_end_s": 6.5, "text_tts": "c" * 40, "est_speech_s": 2.8, "suggested": None},
        ]
        return {"schema": "labguide.voice_uz.plan/1", "videoId": "t", "timeline": {"total_s": 7.0},
                "assumptions": {"speech_rate_chars_per_s": 13.0}, "lines": lines}

    def run_it(self, out, **kw):
        prov = FakeProvider(sec_per_char=0.07)
        sy = su.Synthesizer(prov, "uz-UZ-MadinaNeural", Path(out) / ".c", "keep")
        rep = su.run_video(self.plan(), Path(out), synthesizer=sy, tempo_fn=naive_tempo, **kw)
        return rep, prov

    def test_full_run_without_loudnorm(self):
        with tempfile.TemporaryDirectory() as d:
            rep, prov = self.run_it(d, loudnorm=False, allow_unfit=False)
            by = {r["id"]: r for r in rep["lines"]}
            self.assertEqual(by["L01"]["status"], "ok")            # 1.4 s of speech in a 2.0 s slot
            self.assertEqual(by["L02"]["status"], "sped_up")       # 1.4 s speech + air, slot 1.4 s
            self.assertEqual(by["L03"]["status"], "truncated")     # 2.8 s speech in a 1.0 s slot
            self.assertEqual(rep["summary"]["unfit_ids"], ["L03"])
            out = Path(d) / "t" / "uz"
            # a track with a cut line never gets the normal name
            self.assertTrue((out / "voice_uz.UNFIT.wav").exists())
            self.assertFalse((out / "voice_uz.wav").exists())
            secs, sr, ch = wav_seconds(out / "voice_uz.UNFIT.wav")
            self.assertAlmostEqual(secs, 7.0, delta=0.001)
            self.assertTrue((out / "report.json").exists() and (out / "report.md").exists())
            self.assertEqual(len(prov.calls), 3)

    def test_allow_unfit_uses_normal_name_and_cache_avoids_second_call(self):
        with tempfile.TemporaryDirectory() as d:
            rep, prov = self.run_it(d, loudnorm=False, allow_unfit=True)
            self.assertTrue((Path(d) / "t" / "uz" / "voice_uz.wav").exists())
            rep2, prov2 = self.run_it(d, loudnorm=False, allow_unfit=True)
            self.assertEqual(prov2.calls, [])                       # served from the cache: no API calls, no cost

    def test_use_suggested_sends_the_shorter_text(self):
        with tempfile.TemporaryDirectory() as d:
            rep, prov = self.run_it(d, loudnorm=False, allow_unfit=True, use_suggested=True)
            self.assertIn(("b" * 10, "uz-UZ-MadinaNeural"), prov.calls)
            self.assertNotIn(("b" * 20, "uz-UZ-MadinaNeural"), prov.calls)

    @unittest.skipUnless(HAVE_FFMPEG, "ffmpeg missing")
    def test_full_run_with_loudnorm_matches_english_length(self):
        with tempfile.TemporaryDirectory() as d:
            prov = FakeProvider(sec_per_char=0.07)
            sy = su.Synthesizer(prov, "v", Path(d) / ".c", "keep")
            plan = self.plan()
            plan["lines"] = plan["lines"][:2]
            rep = su.run_video(plan, Path(d), synthesizer=sy, loudnorm=True, tempo_fn=naive_tempo)
            self.assertEqual(rep["output"]["sample_rate"], 48000)
            self.assertAlmostEqual(rep["output"]["seconds"], 7.0, delta=0.05)
            self.assertAlmostEqual(rep["loudness"]["after"]["I"], -16.0, delta=1.5)

    def test_dry_run_needs_no_keys_and_no_network(self):
        with tempfile.TemporaryDirectory() as d:
            def boom(*a, **k):
                raise AssertionError("network used in dry run")

            old = synth.default_http_post
            synth.default_http_post = boom
            keys = {k: os.environ.pop(k, None) for k in ("AZURE_SPEECH_KEY", "AZURE_SPEECH_REGION")}
            try:
                rep = su.run_video(self.plan(), Path(d), synthesizer=None, dry_run=True)
            finally:
                synth.default_http_post = old
                for k, v in keys.items():
                    if v is not None:
                        os.environ[k] = v
            self.assertTrue(rep["dry_run"])
            self.assertEqual(rep["summary"]["api_calls"], 0)
            self.assertEqual(rep["lines"][2]["status"], "truncated")

    def test_cli_dry_run_all_exits_zero_and_prints_each_video(self):
        with tempfile.TemporaryDirectory() as d:
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                rc = su.main(["--all", "--dry-run", "--out-root", d])
            self.assertEqual(rc, 0)
            for v in plan_uz.VIDEOS:
                self.assertIn(v, buf.getvalue())

    def test_report_and_files_never_contain_the_key(self):
        key = "SECRET-KEY-0123456789abcdef"
        with tempfile.TemporaryDirectory() as d:
            def post(url, headers, body):
                return 200, synth.pcm_to_wav_bytes(silence_pad(tone(1.0, 48000), 48000), 48000), {}

            guard = synth.QuotaGuard(path=Path(d) / "u.json")
            prov = su.AzureProvider(key=key, region="westeurope", http_post=post, guard=guard, sleep=lambda s: None,
                                    min_interval_s=0)
            sy = su.Synthesizer(prov, "uz-UZ-MadinaNeural", Path(d) / ".c", "keep")
            plan = self.plan()
            plan["lines"] = plan["lines"][:1]
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
                su.run_video(plan, Path(d), synthesizer=sy, loudnorm=False, tempo_fn=naive_tempo)
            blob = buf.getvalue() + "".join(
                p.read_text(errors="ignore") for p in Path(d).rglob("*") if p.is_file() and p.suffix in (".json", ".md"))
            self.assertNotIn(key, blob)

    def test_sample_mode_with_fake_provider(self):
        with tempfile.TemporaryDirectory() as d:
            items = su.parse_sample(REPO / "docs/video/voice_uz/SAMPLE_TEXT.txt")
            prov = FakeProvider(sec_per_char=0.07)
            sy = su.Synthesizer(prov, "uz-UZ-MadinaNeural", None, "ascii")
            rep = su.run_sample(items, Path(d), sy)
            self.assertEqual(len(prov.calls), 3)
            self.assertTrue(all("‘" not in c[0] and "’" not in c[0] for c in prov.calls))   # ascii variant applied
            self.assertTrue(Path(rep["file"]).exists())
            self.assertAlmostEqual(rep["measured_chars_per_s"], 1 / 0.07, delta=1.5)


@unittest.skipUnless(HAVE_FFMPEG, "ffmpeg missing")
class RemuxTests(unittest.TestCase):
    def test_remux_copies_video_and_replaces_audio(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            ed = root / "qc" / "uz"
            ed.mkdir(parents=True)
            mp4 = ed / "qc_uz_vertical.mp4"
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "lavfi", "-i", "color=c=blue:s=64x64:r=30:d=2",
                            "-f", "lavfi", "-i", "sine=f=440:d=2", "-c:v", "libx264", "-pix_fmt", "yuv420p",
                            "-c:a", "aac", str(mp4)], check=True)
            wav = ed / "voice_uz.wav"
            su.write_wav(wav, tone(2.0, 48000), 48000)
            rc = remux_uz.main(["--video", "qc", "--root", str(root)])
            self.assertEqual(rc, 0)
            out = ed / "uzvoice" / "qc_uz_vertical.mp4"
            self.assertTrue(out.exists())
            self.assertAlmostEqual(remux_uz.probe_duration(out), 2.0, delta=0.1)
            codecs = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "stream=codec_name", "-of", "csv=p=0", str(out)],
                                    capture_output=True, text=True).stdout.split()
            self.assertEqual(sorted(codecs), ["aac", "h264"])
            # length mismatch is refused
            su.write_wav(wav, tone(3.0, 48000), 48000)
            self.assertEqual(remux_uz.main(["--video", "qc", "--root", str(root)]), 3)

    def test_dry_run_prints_command_only(self):
        with tempfile.TemporaryDirectory() as d:
            ed = Path(d) / "qc" / "uz"
            ed.mkdir(parents=True)
            (ed / "qc_uz_vertical.mp4").write_bytes(b"x")
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                rc = remux_uz.main(["--video", "qc", "--root", d, "--dry-run"])
            self.assertEqual(rc, 0)
            self.assertIn("-c:v copy", buf.getvalue())


if __name__ == "__main__":
    unittest.main()
