"""Offline tests for the Gemini TTS provider (python3 -m unittest discover -s tool/tts -p 'test_*.py').

No network, no key: the HTTP layer is a fake function. Nothing here has ever talked to the real service.
"""
import base64
import contextlib
import io
import json
import math
import os
import struct
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent))
import synth  # noqa: E402
import synth_uz as su  # noqa: E402

REPO = Path(__file__).resolve().parent.parent.parent
KEY = "AIzaSyFAKE-TEST-KEY-1234567890abcdef"
SR = 24000


def tone(seconds, sr=SR, freq=220.0, amp=8000):
    n = int(sr * seconds)
    return struct.pack("<%dh" % n, *[int(amp * math.sin(2 * math.pi * freq * i / sr)) for i in range(n)])


def wav_b64(seconds=0.4, sr=SR, freq=220.0):
    return base64.b64encode(synth.pcm_to_wav_bytes(tone(seconds, sr, freq), sr)).decode()


def ok_response(*items, extra_steps=()):
    """items: base64 audio strings, all in ONE model_output step (the last one must win)."""
    steps = list(extra_steps) + [{"type": "model_output", "content": [{"type": "audio", "data": d, "mime_type": "audio/wav"} for d in items]}]
    return (200, json.dumps({"id": "i1", "status": "completed", "steps": steps}).encode(), {"Content-Type": "application/json"})


class Fake:
    def __init__(self, responses):
        self.responses, self.calls, self.sleeps, self.diag = list(responses), [], [], []

    def post(self, url, headers, body):
        self.calls.append((url, dict(headers), body))
        r = self.responses.pop(0) if len(self.responses) > 1 else self.responses[0]
        return r

    def get(self, url, headers):
        self.calls.append((url, dict(headers), None))
        return self.responses.pop(0)

    def provider(self, **kw):
        kw.setdefault("min_interval_s", 0)
        kw.setdefault("sleep", self.sleeps.append)
        return su.GeminiProvider(key=KEY, http_post=self.post, http_get=self.get, diag=self.diag.append, **kw)


class RequestTests(unittest.TestCase):
    def test_request_shape(self):
        f = Fake([ok_response(wav_b64())])
        pcm, sr = f.provider().synthesize("Salom dunyo.", "Fola")
        self.assertEqual(sr, SR)
        self.assertEqual(len(pcm), len(tone(0.4)))
        url, headers, body = f.calls[0]
        self.assertEqual(url, "https://generativelanguage.googleapis.com/v1beta/interactions")
        self.assertEqual(headers["x-goog-api-key"], KEY)
        self.assertEqual(headers["Content-Type"], "application/json")
        self.assertEqual(json.loads(body.decode("utf-8")), {
            "model": "gemini-3.8-flash-tts",
            "input": [{"type": "user_input", "content": [{"type": "text", "text": "Salom dunyo.", "annotations": [
                {"type": "speech_metadata", "style": ""}]}]}],
            "response_format": {"type": "audio"},
            "generation_config": {"speech_config": [{"voice": "Fola"}]}})
        self.assertNotIn(KEY.encode(), body)           # the key travels only in the header

    def test_style_only_in_metadata_never_in_text_and_no_language_parameter(self):
        f = Fake([ok_response(wav_b64())])
        f.provider(model="gemini-3.8-flash-lite-tts", style="calm, slow").synthesize("Faqat shu matn.", "Kore")
        j = json.loads(f.calls[0][2])
        item = j["input"][0]["content"][0]
        self.assertEqual(j["model"], "gemini-3.8-flash-lite-tts")
        self.assertEqual(item["text"], "Faqat shu matn.")
        self.assertEqual(item["annotations"][0]["style"], "calm, slow")
        self.assertNotIn("calm", item["text"])
        self.assertNotIn("language", json.dumps(j).lower())

    def test_bad_voice_model_and_missing_key(self):
        with self.assertRaises(SystemExit):
            Fake([]).provider().synthesize("x", "Fo la!")
        with self.assertRaises(SystemExit):
            su.GeminiProvider(key=KEY, model="bad model;")
        old = os.environ.pop("GEMINI_API_KEY", None)
        try:
            with self.assertRaises(SystemExit) as cm:
                su.GeminiProvider()
            self.assertIn("GEMINI_API_KEY", str(cm.exception))
            self.assertIn("Nothing was sent", str(cm.exception))
        finally:
            if old is not None:
                os.environ["GEMINI_API_KEY"] = old

    def test_min_interval_is_waited_between_calls(self):
        f = Fake([ok_response(wav_b64())])
        p = f.provider(min_interval_s=6.0)
        p.synthesize("bir.", "Fola")
        p.synthesize("ikki.", "Fola")
        self.assertEqual(len(f.sleeps), 1)
        self.assertGreater(f.sleeps[0], 5.0)


class ParseTests(unittest.TestCase):
    def test_last_audio_item_wins_and_other_steps_are_ignored(self):
        thought = {"type": "thought", "content": [{"type": "audio", "data": wav_b64(2.0)}]}
        f = Fake([ok_response(wav_b64(0.3), wav_b64(0.5, freq=330.0), extra_steps=[thought])])
        pcm, sr = f.provider().synthesize("x.", "Fola")
        self.assertEqual(len(pcm), len(tone(0.5)))
        self.assertEqual(pcm, tone(0.5, freq=330.0))

    def test_no_audio_item_is_a_clear_exit_with_keys_only(self):
        body = json.dumps({"id": "i", "steps": [{"type": "model_output", "content": [{"type": "text", "text": "no"}]}]}).encode()
        with self.assertRaises(SystemExit) as cm:
            Fake([(200, body, {})]).provider().synthesize("x.", "Fola")
        self.assertIn("no model_output audio", str(cm.exception))
        self.assertIn("id, steps", str(cm.exception))

    def test_non_json_and_bad_base64(self):
        with self.assertRaises(SystemExit):
            Fake([(200, b"<html>", {})]).provider().synthesize("x.", "Fola")
        with self.assertRaises(SystemExit):
            Fake([ok_response("@@@not base64@@@")]).provider().synthesize("x.", "Fola")

    def test_raw_pcm_with_mime_is_tolerated(self):
        raw = base64.b64encode(tone(0.2)).decode()
        body = json.dumps({"steps": [{"type": "model_output", "content": [
            {"type": "audio", "data": raw, "mime_type": "audio/L16;rate=24000"}]}]}).encode()
        pcm, sr = Fake([(200, body, {})]).provider().synthesize("x.", "Fola")
        self.assertEqual((sr, len(pcm)), (24000, len(tone(0.2))))

    def test_first_call_diagnostic_once_without_secret(self):
        f = Fake([ok_response(wav_b64(0.5))])
        p = f.provider()
        p.synthesize("bir.", "Fola")
        p.synthesize("ikki.", "Fola")
        text = "\n".join(f.diag)
        self.assertEqual(len(f.diag), 2)               # one HTTP line + one audio line, only for the first call
        self.assertIn("HTTP 200", text)
        self.assertIn("response keys: id, status, steps", text)
        self.assertIn("24000 Hz", text)
        self.assertIn("0.50 s", text)
        self.assertIn("bytes", text)
        self.assertNotIn(KEY, text)
        self.assertNotIn("AIza", text)


class ErrorTests(unittest.TestCase):
    def test_429_is_retried_with_exponential_backoff_then_succeeds(self):
        f = Fake([(429, b"{}", {}), (429, b"{}", {}), ok_response(wav_b64())])
        f.provider(backoff_s=8.0).synthesize("x.", "Fola")
        self.assertEqual(len(f.calls), 3)
        self.assertEqual(f.sleeps, [8.0, 16.0])
        self.assertTrue(any("retry 1/3" in m and "429" in m for m in f.diag))

    def test_retry_after_header_and_5xx(self):
        f = Fake([(503, b"", {"Retry-After": "7"}), ok_response(wav_b64())])
        f.provider().synthesize("x.", "Fola")
        self.assertEqual(f.sleeps, [7.0])

    def test_429_exhausted_after_three_retries_has_clear_message(self):
        f = Fake([(429, json.dumps({"error": {"message": "Quota exceeded for " + KEY}}).encode(), {})])
        with self.assertRaises(SystemExit) as cm:
            f.provider().synthesize("x.", "Fola")
        msg = str(cm.exception)
        self.assertEqual(len(f.calls), 4)              # first try + 3 retries
        self.assertEqual(f.sleeps, [8.0, 16.0, 32.0])
        self.assertIn("429", msg)
        self.assertIn("after 3 retries", msg)
        self.assertIn("--min-interval", msg)
        self.assertNotIn(KEY, msg)

    def test_400_is_not_retried_and_shows_the_api_message(self):
        f = Fake([(400, json.dumps({"error": {"code": 400, "message": "Invalid voice 'Nope'"}}).encode(), {})])
        with self.assertRaises(SystemExit) as cm:
            f.provider().synthesize("x.", "Fola")
        self.assertEqual(len(f.calls), 1)
        self.assertIn("HTTP 400", str(cm.exception))
        self.assertIn("Invalid voice 'Nope'", str(cm.exception))

    def test_auth_and_404_messages_never_leak_the_key(self):
        for status in (401, 403, 404, 400, 429):
            f = Fake([(status, ("denied " + KEY + " also AIzaSyOTHERKEYOTHERKEY12345678").encode(), {})])
            p = f.provider(max_retries=0)
            with self.assertRaises(SystemExit) as cm:
                p.synthesize("x.", "Fola")
            self.assertNotIn(KEY, str(cm.exception))
            self.assertNotIn("OTHERKEY", str(cm.exception))
            self.assertNotIn(KEY, repr(p))
            self.assertNotIn(KEY, "\n".join(f.diag))

    def test_key_not_in_request_body_or_anything_written(self):
        with tempfile.TemporaryDirectory() as d:
            f = Fake([ok_response(wav_b64())])
            sy = su.Synthesizer(f.provider(), "Fola", Path(d) / ".c", "keep")
            su.run_sample([{"id": "G1", "text": "Salom.", "text_tts": "Salom."}], Path(d), sy)
            for fp in Path(d).rglob("*"):
                if fp.is_file():
                    self.assertNotIn(KEY.encode(), fp.read_bytes(), fp)
            self.assertNotIn(KEY.encode(), f.calls[0][2])

    def test_local_char_budget_blocks_before_any_request(self):
        with tempfile.TemporaryDirectory() as d:
            f = Fake([ok_response(wav_b64())])
            p = f.provider(budget=su.CharBudget(Path(d) / "u.json", 5))
            with self.assertRaises(SystemExit):
                p.synthesize("juda uzun matn.", "Fola")
            self.assertEqual(f.calls, [])


class ChunkTests(unittest.TestCase):
    def test_short_text_is_one_chunk(self):
        self.assertEqual(su.split_chunks("Salom. Qalaysiz?"), ["Salom. Qalaysiz?"])
        self.assertEqual(su.split_chunks("   "), [])

    def test_sentences_are_packed_up_to_900_and_nothing_is_lost(self):
        sents = ["Bu %d-jumla, uzunroq matn bilan to‘ldirilgan." % i + " so‘z" * 12 + "." for i in range(40)]
        text = " ".join(sents)
        chunks = su.split_chunks(text)
        self.assertGreater(len(chunks), 1)
        self.assertTrue(all(len(c) <= 900 for c in chunks))
        self.assertEqual(" ".join(chunks), text)
        for c in chunks:
            self.assertTrue(c.endswith("."))           # cut only on sentence ends here

    def test_one_overlong_sentence_is_cut_at_commas_or_spaces(self):
        text = ", ".join("so‘z%d" % i for i in range(400))
        chunks = su.split_chunks(text, 900)
        self.assertTrue(all(len(c) <= 900 for c in chunks))
        self.assertEqual(" ".join(chunks).replace(" ", ""), text.replace(" ", ""))
        self.assertTrue(all(not c.endswith(" ") for c in chunks))
        blob = "x" * 2500                              # no separator at all: hard cut
        self.assertEqual("".join(su.split_chunks(blob, 900)), blob)

    def test_provider_sends_one_request_per_chunk_and_joins_audio(self):
        text = " ".join("Bu gap raqam %d, yetarlicha uzun." % i + " ha" * 20 + "." for i in range(30))
        n = len(su.split_chunks(text))
        f = Fake([ok_response(wav_b64(0.2))])
        p = f.provider(chunk_gap_s=0.1)
        pcm, sr = p.synthesize(text, "Fola")
        self.assertEqual(len(f.calls), n)
        self.assertGreater(n, 1)
        sent = [json.loads(c[2])["input"][0]["content"][0]["text"] for c in f.calls]
        self.assertTrue(all(len(s) <= 900 for s in sent))
        self.assertEqual(" ".join(sent), text)
        self.assertEqual(len(pcm), n * len(tone(0.2)) + (n - 1) * 2 * int(0.1 * SR))
        self.assertEqual(p.chars_sent, sum(len(s) for s in sent))


class VoicesTests(unittest.TestCase):
    def test_list_voices_request_and_names(self):
        f = Fake([(200, json.dumps({"voices": [{"name": "Fola"}, {"voice": "Kore"}, "Puck"]}).encode(), {})])
        names = f.provider().list_voices("uz", 50)
        self.assertEqual(names, ["Fola", "Kore", "Puck"])
        url, headers, _ = f.calls[0]
        self.assertEqual(url, "https://generativelanguage.googleapis.com/v1beta/voices?language_code=uz&page_size=50")
        self.assertEqual(headers, {"x-goog-api-key": KEY})


class CliTests(unittest.TestCase):
    def run_main(self, argv, provider=None, env_key=False):
        out, err = io.StringIO(), io.StringIO()
        env = {"GEMINI_API_KEY": KEY} if env_key else {}
        with mock.patch.dict(os.environ, env, clear=False), contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            if not env_key:
                os.environ.pop("GEMINI_API_KEY", None)
            ctx = mock.patch.object(su, "make_provider", return_value=provider) if provider else contextlib.nullcontext()
            with ctx:
                try:
                    rc = su.main(argv)
                except SystemExit as e:
                    rc = str(e)
        return rc, out.getvalue(), err.getvalue()

    def test_sample_file_fits_the_compare_cap(self):
        items = su.parse_sample(REPO / "docs/video/voice_uz/GEMINI_TEST.txt")
        self.assertEqual(len(items), 4)
        spoken = sum(len(i["text_tts"]) for i in su.sample_items_for(items, "spoken"))
        written = sum(len(i["text_tts"]) for i in su.sample_items_for(items, "subtitle"))
        total = (spoken + written) * len(su.GEMINI_COMPARE_VOICES)
        self.assertLessEqual(total, 3000)
        joined = " ".join(i["text"] for i in items)
        for term in ("Levey–Jennings", "Westgard", "eGFR", "qPCR", "GC-MS", "5 mmol/L", "PDF", "mg/dL"):
            self.assertIn(term, joined)

    def test_char_cap_aborts_before_the_provider_is_even_created(self):
        base = ["--provider", "gemini", "--sample", "--sample-file", str(REPO / "docs/video/voice_uz/GEMINI_TEST.txt"),
                "--voices", ",".join(su.GEMINI_COMPARE_VOICES), "--text-variant", "both"]
        rc, out, err = self.run_main(base + ["--max-chars", "3000", "--dry-run"])
        self.assertEqual(rc, 0)
        self.assertIn("nothing was sent", out)
        rc, out, err = self.run_main(base + ["--max-chars", "2000"])      # no key set: the cap message must come first
        self.assertIn("character cap", str(rc))
        self.assertIn("Nothing was sent", str(rc))
        self.assertNotIn("GEMINI_API_KEY", str(rc))
        rc, _, _ = self.run_main(["--provider", "gemini", "--all", "--max-chars", "5000"])
        self.assertIn("character cap", str(rc))
        rc, _, _ = self.run_main(["--provider", "gemini", "--all", "--max-chars", "12000", "--dry-run"])
        self.assertEqual(rc, 0)

    def test_missing_key_is_a_clear_message(self):
        rc, _, _ = self.run_main(["--provider", "gemini", "--sample", "--sample-file",
                                  str(REPO / "docs/video/voice_uz/GEMINI_TEST.txt")])
        self.assertIn("GEMINI_API_KEY", str(rc))

    def test_both_text_variants_send_different_texts_and_name_the_files(self):
        with tempfile.TemporaryDirectory() as d:
            f = Fake([ok_response(wav_b64(0.3))])
            rc, out, err = self.run_main(
                ["--provider", "gemini", "--sample", "--sample-file", str(REPO / "docs/video/voice_uz/GEMINI_TEST.txt"),
                 "--voices", "Fola,Kore", "--text-variant", "both", "--out-root", d],
                provider=f.provider(), env_key=True)
            self.assertEqual(rc, 0, err)
            sent = [json.loads(c[2])["input"][0]["content"][0]["text"] for c in f.calls]
            self.assertEqual(len(sent), 2 * (2 * 4 - 2))   # G1 and G2 are identical in both variants: served from the cache the 2nd time
            voices = [json.loads(c[2])["generation_config"]["speech_config"][0]["voice"] for c in f.calls]
            self.assertEqual(set(voices), {"Fola", "Kore"})
            self.assertTrue(any("glomerulyar" in s for s in sent) and not any("eGFR" in s for s in sent[:4]))
            self.assertTrue(any("eGFR" in s and "mmol/L" in s for s in sent))
            self.assertTrue(any("PDF" in s and "mg/dL" in s for s in sent))
            names = {p.name for p in (Path(d) / "voice_uz_sample").glob("sample_*.wav")}
            self.assertEqual(names, {"sample_Fola_spoken.wav", "sample_Fola_subtitle.wav",
                                     "sample_Kore_spoken.wav", "sample_Kore_subtitle.wav"})
            for fp in Path(d).rglob("*"):
                if fp.is_file():
                    self.assertNotIn(KEY.encode(), fp.read_bytes())
            self.assertNotIn(KEY, out + err)

    def test_failed_first_voice_stops_the_run_after_one_request(self):
        f = Fake([(400, b'{"error":{"message":"bad"}}', {})])
        with tempfile.TemporaryDirectory() as d:
            rc, out, err = self.run_main(
                ["--provider", "gemini", "--sample", "--sample-file", str(REPO / "docs/video/voice_uz/GEMINI_TEST.txt"),
                 "--voices", "Fola,Kore", "--out-root", d], provider=f.provider(), env_key=True)
        self.assertEqual(rc, 1)
        self.assertEqual(len(f.calls), 1)
        self.assertIn("FAILED", err)

    def test_video_subtitle_variant_uses_the_written_text(self):
        line = {"text_uz": "Me’yor oraliqlari — PDF’da.", "text_tts": "Me’yor oraliqlari, faylda."}
        self.assertEqual(su.line_text(line, False), (line["text_tts"], "original"))
        self.assertEqual(su.line_text(line, False, "subtitle"), (line["text_uz"], "subtitle"))
        self.assertEqual(su.line_text(line, True, "subtitle"), (line["text_uz"], "subtitle"))
        rc, out, _ = self.run_main(["--provider", "gemini", "--video", "overview", "--text-variant", "subtitle", "--dry-run"])
        self.assertEqual(rc, 0)
        self.assertIn("characters to send: 1489", out)
        rc, _, _ = self.run_main(["--provider", "gemini", "--video", "overview", "--text-variant", "both"])
        self.assertIn("only for --sample", str(rc))

    def test_default_voice_and_model(self):
        a = su.parse_args(["--provider", "gemini"])
        self.assertEqual((a.gemini_model, a.gemini_style, a.min_interval, a.text_variant),
                         ("gemini-3.8-flash-tts", "", None, "spoken"))
        self.assertEqual(su.GEMINI_DEFAULT_VOICE, "Fola")


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.wf = (REPO / ".github/workflows/uz_voice.yml").read_text(encoding="utf-8")

    def test_modes_secret_caps_and_owner_restriction(self):
        for s in ("gemini-compare:docs/video/voice_uz/*.txt", "gemini-all", "gemini-video:*",
                  "secrets.GEMINI_API_KEY", "GEMINI_VOICE:-Fola", "--max-chars \"${GEMINI_COMPARE_CAP:-3000}\"",
                  "--max-chars \"${GEMINI_ALL_CAP:-12000}\"", "--text-variant both", "--text-variant spoken",
                  "Fola,Kore,Puck,Charon,Leda,Sulafat,Zephyr", "github.actor == 'davlatsudekspert'",
                  "compare:*)", "sample:*)", "video:*)", "UZBEKVOICE_API_KEY"):
            self.assertIn(s, self.wf, s)
        self.assertIn("GEMINI_API_KEY secret yo'q", self.wf)

    def test_key_is_never_echoed_or_put_on_a_command_line(self):
        for line in self.wf.splitlines():
            if "GEMINI_API_KEY" in line and "secrets." not in line:
                self.assertNotRegex(line, r"echo\s+[\"']?\$\{?GEMINI_API_KEY")
                self.assertNotIn("--key", line)
        self.assertNotIn("set -x", self.wf)


if __name__ == "__main__":
    unittest.main()
