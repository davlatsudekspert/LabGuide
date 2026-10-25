"""Offline unit tests (python3 -m unittest discover -s tool/tts -p 'test_*.py').

Backends are exercised with the built-in stub / 'none' backends and a fake Azure HTTP endpoint;
no network, no model files, no API keys.
"""
import contextlib
import io
import json
import os
import sys
import tempfile
import unittest
import wave
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import synth  # noqa: E402


def wav_info(path):
    with wave.open(str(path), "rb") as w:
        return w.getframerate(), w.getnframes() / w.getframerate(), w.getnchannels(), w.getsampwidth()


class NumberTests(unittest.TestCase):
    def test_uz_numbers(self):
        self.assertEqual(synth.int_to_words(0, "uz"), "nol")
        self.assertEqual(synth.int_to_words(45, "uz"), "qirq besh")
        self.assertEqual(synth.int_to_words(119, "uz"), "yuz o‘n to‘qqiz")
        self.assertEqual(synth.int_to_words(1000, "uz"), "ming")
        self.assertEqual(synth.int_to_words(2024, "uz"), "ikki ming yigirma to‘rt")
        self.assertEqual(synth.int_to_words(1500000, "uz"), "bir million besh yuz ming")

    def test_ru_numbers(self):
        self.assertEqual(synth.int_to_words(21, "ru"), "двадцать один")
        self.assertEqual(synth.int_to_words(21, "ru", fem=True), "двадцать одна")
        self.assertEqual(synth.int_to_words(2000, "ru"), "две тысячи")
        self.assertEqual(synth.int_to_words(5000, "ru"), "пять тысяч")
        self.assertEqual(synth.int_to_words(11000, "ru"), "одиннадцать тысяч")
        self.assertEqual(synth.int_to_words(1234567, "ru"),
                         "один миллион двести тридцать четыре тысячи пятьсот шестьдесят семь")

    def test_en_numbers(self):
        self.assertEqual(synth.int_to_words(95, "en"), "ninety-five")
        self.assertEqual(synth.int_to_words(540, "en"), "five hundred forty")
        self.assertEqual(synth.int_to_words(1001, "en"), "one thousand one")


class NormaliseTests(unittest.TestCase):
    def test_percent_and_units_uz(self):
        self.assertEqual(synth.normalise_text("45 % neytrofil", "uz"), "qirq besh foiz neytrofil")
        self.assertEqual(synth.normalise_text("5,6 mmol/L", "uz"), "besh butun o'ndan olti millimol litr")
        self.assertEqual(synth.normalise_text("37 °C", "uz"), "o'ttiz yetti daraja Tselsiy")

    def test_units_ru_plural(self):
        self.assertEqual(synth.normalise_text("1 %", "ru"), "один процент")
        self.assertEqual(synth.normalise_text("3 %", "ru"), "три процента")
        self.assertEqual(synth.normalise_text("45 %", "ru"), "сорок пять процентов")
        self.assertEqual(synth.normalise_text("21 мин", "ru"), "двадцать одна минута")
        self.assertEqual(synth.normalise_text("2,5 мл", "ru"), "две целых пять десятых миллилитра")

    def test_dash_and_range(self):
        self.assertEqual(synth.normalise_text("LabGuide — ilova", "uz"), "LabGuide, ilova")
        self.assertEqual(synth.normalise_text("3,9 dan 5,5 mmol/L gacha", "uz"),
                         "uch butun o'ndan to'qqiz dan besh butun o'ndan besh millimol litr gacha")

    def test_units_en(self):
        self.assertEqual(synth.normalise_text("1 mg/dL", "en"), "one milligram per decilitre")
        self.assertEqual(synth.normalise_text("5 mg/dL", "en"), "five milligrams per decilitre")
        self.assertEqual(synth.normalise_text("6.5 %", "en"), "six point five percent")

    def test_number_not_inside_words(self):
        self.assertEqual(synth.normalise_text("HbA1c", "en"), "HbA1c")
        self.assertEqual(synth.normalise_text("COVID19", "en"), "COVID19")

    def test_uz_apostrophes(self):
        for src in ["o‘zbek", "o'zbek", "oʻzbek", "o’zbek", "o`zbek", "O‘ZBEK"]:
            self.assertEqual(synth.normalise_text(src, "uz").lower(), "o'zbek")
        self.assertEqual(synth.normalise_text("g‘oya", "uz"), "g'oya")
        self.assertEqual(synth.normalise_text("ma’no a’zo", "uz"), "ma'no a'zo")
        self.assertEqual(synth.normalise_text("o‘n", "uz", "ʻ"), "oʻn")
        # style is applied to number words too
        self.assertIn("to‘rt", synth.normalise_text("4", "uz", "‘"))

    def test_uz_latin_to_cyrillic(self):
        self.assertEqual(synth.uz_latin_to_cyrillic("o‘g‘il shifokor"), "ўғил шифокор")
        self.assertEqual(synth.uz_latin_to_cyrillic("choy"), "чой")
        self.assertEqual(synth.uz_latin_to_cyrillic("elektr neytrofil"), "электр нейтрофил")
        self.assertEqual(synth.uz_latin_to_cyrillic("leykotsitar"), "лейкоцитар")


class LexiconTests(unittest.TestCase):
    def test_whole_word_case_insensitive(self):
        lex = {"pcr": "pe se er", "dnk": "de en ka"}
        self.assertEqual(synth.apply_lexicon("PCR va DNK; pcrx", lex), "pe se er va de en ka; pcrx")

    def test_backend_specific_and_phrases(self):
        lex = {"labguide": {"default": "Leb Gayd", "azure": "Lab Gaid"}, "zanjirli reaksiya": "zanjirli reaksiya"}
        self.assertEqual(synth.apply_lexicon("LabGuide", lex, "azure"), "Lab Gaid")
        self.assertEqual(synth.apply_lexicon("LabGuide", lex, "piper"), "Leb Gayd")

    def test_longest_key_first(self):
        lex = {"hba": "H B A", "hba1c": "glycated haemoglobin"}
        self.assertEqual(synth.apply_lexicon("HbA1c", lex), "glycated haemoglobin")

    def test_shipped_lexicons_load_and_apply(self):
        for lang in ("uz", "ru", "en"):
            lex = synth.load_lexicon(lang)
            self.assertTrue(lex, lang)
        self.assertIn("pe se er", synth.prepare_text("PCR usuli", "uz"))
        self.assertIn("P C R", synth.prepare_text("PCR test", "en"))

    def test_extra_lexicon_file(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "x.json"
            p.write_text(json.dumps({"entries": {"Neytrofil": "neytro-fil"}}), encoding="utf-8")
            lex = synth.load_lexicon("uz", [p])
            self.assertEqual(synth.prepare_text("neytrofil", "uz", lexicon=lex), "neytro-fil")


class ScriptTests(unittest.TestCase):
    def test_validation(self):
        with self.assertRaises(ValueError):
            synth.validate_script({"lang": "de", "lines": [{"id": "a", "text": "x"}]})
        with self.assertRaises(ValueError):
            synth.validate_script({"lang": "uz", "lines": []})
        with self.assertRaises(ValueError):
            synth.validate_script({"lang": "uz", "lines": [{"id": "../a", "text": "x"}]})
        with self.assertRaises(ValueError):
            synth.validate_script({"lang": "uz", "lines": [{"id": "a", "text": "x"}, {"id": "a", "text": "y"}]})
        with self.assertRaises(ValueError):
            synth.validate_script({"lang": "uz", "lines": [{"id": "a", "text": "  "}]})

    def test_stub_manifest_timing_and_files(self):
        script = {"lang": "uz", "gap_s": 0.5, "voice": "v",
                  "lines": [{"id": "a", "text": "Salom dunyo"}, {"id": "b", "text": "Xayr", "gap_s": 1.0},
                            {"id": "c", "text": "Tugadi"}]}
        be = synth.StubBackend(sample_rate=8000, sec_per_char=0.01)
        with tempfile.TemporaryDirectory() as d:
            m = synth.synth_script(script, d, be, concat=True, srt=True)
            self.assertEqual([x["id"] for x in m["lines"]], ["a", "b", "c"])
            prev_end, prev_gap = None, None
            for ln in m["lines"]:
                sr, dur, ch, sw = wav_info(Path(d) / ln["file"])
                self.assertEqual((sr, ch, sw), (8000, 1, 2))
                self.assertAlmostEqual(dur, ln["duration"], places=2)
                self.assertAlmostEqual(ln["end"] - ln["start"], ln["duration"], places=2)
                if prev_end is not None:
                    self.assertAlmostEqual(ln["start"], prev_end + prev_gap, places=2)
                prev_end, prev_gap = ln["end"], ln["gap_after"]
            self.assertEqual(m["lines"][0]["start"], 0.0)
            self.assertEqual(m["lines"][1]["gap_after"], 1.0)
            self.assertFalse(m["estimated"])
            self.assertAlmostEqual(m["total_duration"], m["lines"][-1]["end"], places=3)
            # concatenated file length == manifest total
            _, cdur, _, _ = wav_info(Path(d) / "narration.wav")
            self.assertAlmostEqual(cdur, m["total_duration"], places=1)
            srt = (Path(d) / "narration.srt").read_text(encoding="utf-8")
            self.assertIn("00:00:00,000 --> ", srt)
            on_disk = json.loads((Path(d) / "manifest.json").read_text(encoding="utf-8"))
            self.assertEqual(on_disk["schema"], synth.SCHEMA)
            self.assertEqual(on_disk["voice"], "v")

    def test_text_is_normalised_before_backend(self):
        be = synth.StubBackend(sample_rate=8000, sec_per_char=0.001)
        script = {"lang": "uz", "lines": [{"id": "a", "text": "PCR: 45 % o‘zgarish"}]}
        with tempfile.TemporaryDirectory() as d:
            m = synth.synth_script(script, d, be)
        self.assertEqual(be.calls[0][0], "pe se er: qirq besh foiz o'zgarish")
        self.assertEqual(m["lines"][0]["text"], "PCR: 45 % o‘zgarish")  # original kept

    def test_none_backend_estimates_and_flags(self):
        script = {"lang": "ru", "lines": [{"id": "a", "text": "Короткая строка."},
                                          {"id": "b", "text": "Это гораздо более длинная строка, которая должна длиться дольше первой."}]}
        with tempfile.TemporaryDirectory() as d:
            m = synth.synth_script(script, d, synth.NoneBackend(sample_rate=8000))
            self.assertTrue(m["estimated"])
            self.assertTrue(all(x["estimated"] for x in m["lines"]))
            self.assertLess(m["lines"][0]["duration"], m["lines"][1]["duration"])
            self.assertGreaterEqual(m["lines"][0]["duration"], 0.8)
            data = (Path(d) / "a.wav").read_bytes()
            pcm, sr = synth.wav_bytes_to_pcm(data)
            self.assertEqual(sr, 8000)
            self.assertEqual(set(pcm), {0})  # silent

    def test_cache_skips_second_backend_call(self):
        class Counting(synth.StubBackend):
            name = "counting"
        be = Counting(sample_rate=8000, sec_per_char=0.001)
        script = {"lang": "en", "lines": [{"id": "a", "text": "Hello there"}]}
        with tempfile.TemporaryDirectory() as d:
            synth.synth_script(script, d, be)
            synth.synth_script(script, d, be)
        self.assertEqual(len(be.calls), 1)

    def test_main_dry_run_and_none(self):
        with tempfile.TemporaryDirectory() as d:
            sp = Path(d) / "s.json"
            sp.write_text(json.dumps({"lang": "uz", "lines": [{"id": "x", "text": "5 %"}]}), encoding="utf-8")
            with contextlib.redirect_stdout(io.StringIO()) as buf:
                self.assertEqual(synth.main([str(sp), "--out", d + "/o", "--dry-run"]), 0)
                self.assertEqual(synth.main([str(sp), "--out", d + "/o", "--backend", "none"]), 0)
            self.assertIn("besh foiz", buf.getvalue())
            self.assertTrue((Path(d) / "o" / "manifest.json").exists())

    def test_shipped_test_scripts_validate(self):
        for lang in ("en", "ru", "uz"):
            s = json.loads((Path(__file__).parent / "testdata" / f"{lang}_lab.json").read_text(encoding="utf-8"))
            synth.validate_script(s)


class FakeAzure:
    """Minimal fake of the Azure TTS REST endpoint."""

    def __init__(self, statuses=None):
        self.requests = []
        self.statuses = list(statuses or [])

    def __call__(self, url, headers, body, timeout=60.0):
        self.requests.append((url, headers, body.decode("utf-8")))
        if self.statuses:
            st = self.statuses.pop(0)
            if st != 200:
                return st, b"err", ({"Retry-After": "0"} if st == 429 else {})
        return 200, synth.pcm_to_wav_bytes(b"\x01\x00" * 2400, 24000), {}


class AzureTests(unittest.TestCase):
    def mk(self, fake, limit=450_000, tmp=None):
        guard = synth.QuotaGuard(path=Path(tmp) / "usage.json", limit=limit)
        return synth.AzureBackend(key="KEY", region="westeurope", http_post=fake, guard=guard,
                                  min_interval_s=0, sleep=lambda s: None)

    def test_request_shape(self):
        fake = FakeAzure()
        with tempfile.TemporaryDirectory() as d:
            be = self.mk(fake, tmp=d)
            pcm, sr = be.synthesize("Salom <dunyo> & do'stlar", "uz", None)
        url, headers, body = fake.requests[0]
        self.assertEqual(url, "https://westeurope.tts.speech.microsoft.com/cognitiveservices/v1")
        self.assertEqual(headers["Ocp-Apim-Subscription-Key"], "KEY")
        self.assertEqual(headers["Content-Type"], "application/ssml+xml")
        self.assertEqual(headers["X-Microsoft-OutputFormat"], "riff-24khz-16bit-mono-pcm")
        self.assertIn("xml:lang='uz-UZ'", body)
        self.assertIn("uz-UZ-MadinaNeural", body)
        self.assertIn("Salom &lt;dunyo&gt; &amp; do'stlar", body)  # XML-escaped
        self.assertEqual(sr, 24000)
        self.assertEqual(len(pcm), 4800)

    def test_full_script_through_azure_stub(self):
        fake = FakeAzure()
        script = {"lang": "uz", "voice": "uz-UZ-SardorNeural", "lines": [{"id": "a", "text": "Salom"}, {"id": "b", "text": "Xayr"}]}
        with tempfile.TemporaryDirectory() as d:
            m = synth.synth_script(script, d + "/out", self.mk(fake, tmp=d))
            self.assertEqual(len(fake.requests), 2)
            self.assertIn("uz-UZ-SardorNeural", fake.requests[0][2])
            self.assertEqual(m["backend"], "azure")
            self.assertEqual(m["sample_rate"], 24000)
            # second run is served from the cache: no extra characters spent
            synth.synth_script(script, d + "/out", self.mk(fake, tmp=d))
            self.assertEqual(len(fake.requests), 2)

    def test_retry_on_429_then_success(self):
        fake = FakeAzure(statuses=[429, 429, 200])
        with tempfile.TemporaryDirectory() as d:
            be = self.mk(fake, tmp=d)
            be.synthesize("Salom", "uz", None)
        self.assertEqual(len(fake.requests), 3)

    def test_auth_failure_does_not_retry_or_upgrade(self):
        fake = FakeAzure(statuses=[403])
        with tempfile.TemporaryDirectory() as d:
            be = self.mk(fake, tmp=d)
            with self.assertRaises(SystemExit) as cm:
                be.synthesize("Salom", "uz", None)
        self.assertIn("does not upgrade", str(cm.exception))
        self.assertEqual(len(fake.requests), 1)

    def test_quota_guard_blocks_before_network(self):
        fake = FakeAzure()
        with tempfile.TemporaryDirectory() as d:
            be = self.mk(fake, limit=10, tmp=d)
            be.synthesize("12345", "uz", None)  # 5 chars used
            with self.assertRaises(SystemExit) as cm:
                be.synthesize("1234567", "uz", None)  # 5 + 7 > 10
        self.assertIn("safety limit", str(cm.exception))
        self.assertEqual(len(fake.requests), 1)

    def test_missing_credentials(self):
        old = {k: os.environ.pop(k, None) for k in ("AZURE_SPEECH_KEY", "AZURE_SPEECH_REGION")}
        try:
            with self.assertRaises(SystemExit) as cm:
                synth.AzureBackend()
            self.assertIn("AZURE_SPEECH_KEY", str(cm.exception))
        finally:
            for k, v in old.items():
                if v is not None:
                    os.environ[k] = v

    def test_bad_region_rejected(self):
        with self.assertRaises(SystemExit):
            synth.AzureBackend(key="k", region="evil.example.com/x")

    def test_rate_prosody(self):
        s = synth.AzureBackend.build_ssml("a", "ru", "ru-RU-SvetlanaNeural", "-5%")
        self.assertIn('<prosody rate="-5%">a</prosody>', s)
        self.assertIn("xml:lang='ru-RU'", s)


class SileroStubTests(unittest.TestCase):
    def test_silero_backend_with_fake_modules(self):
        import types
        calls = {}

        class FakeAudio(list):
            pass

        class FakeModel:
            def to(self, dev):
                return self

            def apply_tts(self, text, speaker, sample_rate):
                calls["args"] = (text, speaker, sample_rate)
                return [0.0, 0.5, -0.5, 0.0]

        fake_torch = types.SimpleNamespace(device=lambda x: x)
        fake_silero = types.SimpleNamespace(silero_tts=lambda language, speaker: (FakeModel(), "ex"))
        sys.modules["torch"], sys.modules["silero"] = fake_torch, fake_silero
        try:
            be = synth.SileroBackend()
            pcm, sr = be.synthesize("salom", "uz", None)
        finally:
            sys.modules.pop("torch", None)
            sys.modules.pop("silero", None)
        self.assertEqual(calls["args"], ("салом", "uzb_saida", 48000))
        self.assertEqual(sr, 48000)
        self.assertEqual(len(pcm), 8)


if __name__ == "__main__":
    unittest.main()
