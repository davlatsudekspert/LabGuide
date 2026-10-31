import array, json, math, random, shutil, sys, tempfile, unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import retime_uz as rt  # noqa: E402
import synth  # noqa: E402
import synth_uz  # noqa: E402

SB = {"timing": {"leadSec": 0.25, "tailSec": 0.35, "gapSec": 0.2},
      "scenes": [{"id": "a", "layer": "hook", "lines": ["L1", "L2"], "minSec": 5},
                 {"id": "b", "layer": "phone", "lines": ["L3"], "minSec": 4}]}


def plan():
    # scene a: 0 .. 9.0 ; scene b: 9.0 .. 14.0 (total)
    mk = lambda i, sc, s0, s1, st, en: {"id": i, "scene": sc, "scene_start_s": s0, "scene_end_s": s1, "start_s": st, "end_s": en,
                                        "text_tts": "x" * 40, "suggested": None}
    return {"videoId": "t", "timeline": {"total_s": 14.0},
            "lines": [mk("L1", "a", 0, 9.0, 0.25, 4.0), mk("L2", "a", 0, 9.0, 4.2, 8.5), mk("L3", "b", 9.0, 14.0, 9.25, 13.0)]}


class Core(unittest.TestCase):
    def test_everything_fits_nothing_changes(self):
        r = rt.retime(plan(), SB, {"L1": 3.0, "L2": 4.0, "L3": 3.5})
        self.assertEqual(r["totalSec"], 14.0)
        self.assertTrue(all(s["extra_s"] == 0 and s["new_s"] == s["orig_s"] for s in r["scenes"]))
        self.assertTrue(all(l["tempo"] == 1.0 for l in r["lines"]))
        self.assertEqual([l["start"] for l in r["lines"]], [0.25, 4.2, 9.25])

    def test_speed_up_instead_of_stretch(self):
        # L1 slot = 4.2-0.1-0.25 = 3.85 s; 4.2 s needs tempo 1.09 -> fits, scene unchanged
        r = rt.retime(plan(), SB, {"L1": 4.2, "L2": 4.0, "L3": 3.5})
        self.assertEqual(r["totalSec"], 14.0)
        self.assertAlmostEqual(r["lines"][0]["tempo"], 4.2 / 3.85 * 1.003, places=3)
        self.assertLessEqual(r["lines"][0]["end"], 4.1 + 1e-6)

    def test_stretch_only_when_beyond_max_tempo(self):
        r = rt.retime(plan(), SB, {"L1": 3.0, "L2": 6.0, "L3": 3.5})
        a, b = r["scenes"]
        self.assertAlmostEqual(r["lines"][1]["tempo"], 1.12)
        end2 = 4.2 + 6.0 / 1.12
        self.assertAlmostEqual(a["new_s"], end2 + 0.35, places=2)
        self.assertGreater(a["extra_s"], 0)
        self.assertEqual(b["extra_s"], 0)
        self.assertAlmostEqual(b["from_s"], a["new_s"], places=3)
        self.assertEqual(r["totalSec"], round(a["new_s"] + 5.0, 3))
        self.assertAlmostEqual(r["lines"][2]["start"], a["new_s"] + 0.25, places=3)

    def test_pushed_next_line_keeps_gap(self):
        r = rt.retime(plan(), SB, {"L1": 6.0, "L2": 2.0, "L3": 1.0})
        l1, l2 = r["lines"][:2]
        self.assertAlmostEqual(l2["start"], l1["end"] + 0.2, places=3)

    def test_never_shorter_never_earlier_never_over_tempo(self):
        rnd = random.Random(7)
        for _ in range(300):
            d = {k: rnd.uniform(0.5, 12) for k in ("L1", "L2", "L3")}
            r = rt.retime(plan(), SB, d)
            for s in r["scenes"]:
                self.assertGreaterEqual(s["new_s"], s["orig_s"] - 1e-9)
            en = {"L1": 0.25, "L2": 4.2, "L3": 0.25}
            for l in r["lines"]:
                sc = r["scenes"][1] if l["id"] == "L3" else r["scenes"][0]
                self.assertGreaterEqual(l["start"] - sc["from_s"], en[l["id"]] - 1e-3)
                self.assertLessEqual(l["tempo"], 1.12 + 1e-9)
                self.assertLessEqual(l["end"], sc["from_s"] + sc["new_s"] - 0.05 + 1e-3)
            for x, y in zip(r["lines"], r["lines"][1:]):
                self.assertLess(x["end"], y["start"])

    def test_estimate_uses_chars_over_rate(self):
        p = plan()
        self.assertAlmostEqual(rt.estimate_durations(p, 10.0)["L1"], 4.0)


class Files(unittest.TestCase):
    def test_lines_file_shapes(self):
        with tempfile.TemporaryDirectory() as t:
            f = Path(t) / "l.json"
            ids = ["L1", "L2"]
            for obj in ({"lines": [{"id": "L1", "trimmed_s": 3.1}, {"id": "L2", "raw_s": 2.0}]},
                        {"lines": {"L1": 3.1, "L2": 2.0}}, {"L1": 3.1, "L2": 2.0},
                        [{"id": "L1", "duration_s": 3.1}, {"id": "L2", "seconds": 2.0}]):
                f.write_text(json.dumps(obj))
                self.assertEqual(rt.read_lines_file(f, ids), {"L1": 3.1, "L2": 2.0})
            f.write_text(json.dumps({"L1": 3.1}))
            with self.assertRaises(SystemExit):
                rt.read_lines_file(f, ids)

    def test_assemble_places_clips_and_pads(self):
        sr = 48000
        def tone(sec):
            a = array.array("h", [int(8000 * math.sin(2 * math.pi * 220 * i / sr)) for i in range(int(sec * sr))])
            return synth.pcm_to_wav_bytes(a.tobytes(), sr)
        with tempfile.TemporaryDirectory() as t:
            t = Path(t)
            (t / "clips").mkdir()
            d = {"L1": 3.0, "L2": 6.0, "L3": 3.5}
            for k, v in d.items():
                (t / "clips" / (k + ".wav")).write_bytes(tone(v))
            r = rt.retime(plan(), SB, d)
            out = t / "out" / "t.wav"
            rep = rt.assemble_wav(r, t / "clips", out, loudnorm=shutil.which("ffmpeg") is not None)
            self.assertAlmostEqual(rep["seconds"], r["totalSec"], places=1)
            self.assertEqual(rep["sample_rate"], 48000)
            if rep["loudness"]:
                self.assertAlmostEqual(rep["loudness"]["after"]["I"], -16.0, delta=1.0)
            # mismatched clip length is refused
            (t / "clips" / "L1.wav").write_bytes(tone(1.0))
            with self.assertRaises(SystemExit):
                rt.assemble_wav(r, t / "clips", out, loudnorm=False)


class RealPlans(unittest.TestCase):
    def test_all_nine_dry_run_invariants(self):
        for v in rt.VIDEOS:
            p, sb = rt.load_plan(v), rt.load_storyboard(v)
            r = rt.retime(p, sb, rt.estimate_durations(p, rt.RATE_CPS))
            self.assertGreaterEqual(r["totalSec"], r["orig_total_s"] - 1e-6, v)
            self.assertEqual([s["id"] for s in r["scenes"]], [s["id"] for s in sb["scenes"]])
            self.assertAlmostEqual(sum(s["new_s"] for s in r["scenes"]), r["totalSec"], delta=0.01)
            for s in r["scenes"]:
                self.assertGreaterEqual(s["new_s"], s["orig_s"] - 1e-6, (v, s["id"]))

    def test_faster_voice_never_longer(self):
        for v in ("calculators", "qc"):
            p, sb = rt.load_plan(v), rt.load_storyboard(v)
            slow = rt.retime(p, sb, rt.estimate_durations(p, 11.6))["totalSec"]
            fast = rt.retime(p, sb, rt.estimate_durations(p, 14.2))["totalSec"]
            self.assertLessEqual(fast, slow)


if __name__ == "__main__":
    unittest.main()
