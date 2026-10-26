"""Tests for the publishing kit texts, chapters and schedule (python3 -m unittest discover -s tool/publish -p 'test_*.py').

No network, no ffmpeg needed.
"""
import csv
import io
import json
import re
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import chapters  # noqa: E402
import kit  # noqa: E402
import schedule  # noqa: E402
from common import (DISCLOSURES, HASHTAGS_MAX, HASHTAGS_MIN, IG_CAPTION_MAX, LANGS, PAID_LINE,  # noqa: E402
                    PUBLISH_DOCS, REPO, YT_TAGS_MAX, YT_TITLE_MAX)
from topics import BY_ID, IDS, TOPICS  # noqa: E402

REQUIRED_IDS = ["calibration", "leukocyte", "photometry", "qc", "gcms", "qpcr", "osmometry",
                "calculators", "exam_simulation", "teacher_pro", "premium_overview"]


class TopicTextTests(unittest.TestCase):
    def test_all_required_topics_exist_in_order(self):
        self.assertEqual(IDS, REQUIRED_IDS)

    def test_lint_is_clean(self):
        problems = []
        for t in TOPICS:
            problems += kit.lint_topic(t)
        self.assertEqual(problems, [])

    def test_titles_hashtags_instagram_limits(self):
        for t in TOPICS:
            for lang in LANGS:
                self.assertLessEqual(len(t["title"][lang]), YT_TITLE_MAX, (t["id"], lang))
                n = len(kit.hashtags(t, lang))
                self.assertTrue(HASHTAGS_MIN <= n <= HASHTAGS_MAX, (t["id"], lang, n))
                self.assertLessEqual(kit.instagram_total(t, lang), IG_CAPTION_MAX, (t["id"], lang))
                self.assertLessEqual(len(", ".join(kit.youtube_tags(t, lang))), YT_TAGS_MAX, (t["id"], lang))
                self.assertEqual(len(kit.youtube_hashtags(t, lang)), 3)

    def test_hook_is_the_first_two_lines_of_the_description(self):
        for t in TOPICS:
            for lang in LANGS:
                first = kit.youtube_description(t, lang, None).split("\n")[:2]
                self.assertEqual(first, list(t["hook"][lang]))

    def test_instagram_hook_first_and_cta_last(self):
        for t in TOPICS:
            for lang in LANGS:
                cap, _ = kit.instagram_caption(t, lang)
                self.assertTrue(cap.startswith(t["ig"][lang][0]))
                self.assertIn("[[LINK_BIO]]", cap.split("\n")[-1])

    def test_mandatory_disclosures_in_every_description_and_caption(self):
        for t in TOPICS:
            for lang in LANGS:
                d = kit.youtube_description(t, lang, None)
                c = kit.instagram_caption(t, lang)[0]
                for key, texts in DISCLOSURES.items():
                    want = texts[lang].rstrip(".")
                    if key == "voice" and lang == "en":
                        want = "English synthetic narration (Kokoro-82M, Apache-2.0)"
                    self.assertIn(want, d, (t["id"], lang, key))
                    self.assertIn(want, c, (t["id"], lang, key))
        en = kit.youtube_description(BY_ID["calibration"], "en", None)
        self.assertIn("Illustrative data — not patient results", en)
        self.assertIn("Educational use, not medical advice", en)
        self.assertIn("Expert review pending", en)

    def test_no_price_or_product_id_anywhere(self):
        for t in TOPICS:
            for lang in LANGS:
                for label, text in kit._public_texts(t, lang):
                    self.assertIsNone(kit.PRICE_RE.search(text), (t["id"], lang, label))

    def test_uzbek_apostrophes(self):
        for t in TOPICS:
            for label, text in kit._public_texts(t, "uz"):
                self.assertIsNone(kit.UZ_BAD_APOSTROPHES.search(text), (t["id"], label))
            blob = json.dumps(t["title"]["uz"], ensure_ascii=False)
            self.assertNotIn("'", blob)
        self.assertIn("o‘", BY_ID["calibration"]["shows"]["uz"][0] + BY_ID["calibration"]["shows"]["uz"][3] + "o‘")

    def test_paid_topics_carry_the_paid_line_and_free_topics_do_not(self):
        paid = [t for t in TOPICS if t["tier"] == "paid"]
        self.assertEqual([t["id"] for t in paid], ["exam_simulation", "teacher_pro", "premium_overview"])
        for t in TOPICS:
            for lang in LANGS:
                d = kit.youtube_description(t, lang, None)
                if t["tier"] == "paid":
                    self.assertIn(PAID_LINE[lang], d)
                    self.assertIn("7", PAID_LINE[lang])
                else:
                    self.assertNotIn(PAID_LINE[lang], d)
        self.assertIn("7-day free trial where offered", PAID_LINE["en"])

    def test_paid_text_does_not_claim_offline_for_account_features(self):
        for tid in ("exam_simulation", "teacher_pro", "premium_overview"):
            d = kit.youtube_description(BY_ID[tid], "en", None)
            self.assertNotIn("Works offline", d)

    def test_spectrophotometry_is_an_alias_of_photometry(self):
        from topics import ALIASES
        self.assertEqual(ALIASES, {"spectrophotometry": "photometry"})
        d = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, d, True)
        (d / "READY.txt").write_text("spectrophotometry\n", encoding="utf-8")
        self.assertEqual(kit.read_ready_ids(d), {"photometry"})

    def test_verified_topics(self):
        # verified = every sentence checked against the rendered video; the three paid topics are still drafts
        self.assertEqual([t["id"] for t in TOPICS if t["verified"]],
                         ["calibration", "leukocyte", "photometry", "qc", "gcms", "qpcr", "osmometry", "calculators"])
        self.assertEqual([t["id"] for t in TOPICS if not t["verified"]],
                         ["exam_simulation", "teacher_pro", "premium_overview"])

    def test_no_overclaiming_words(self):
        bad = re.compile(r"\b(guarantee|guaranteed|certified|clinically (validated|proven)|FDA|CE[- ]marked|"
                         r"replaces? (your )?(doctor|laboratory|SOP)|diagnos(e|es|is) (patients|disease))\b", re.I)
        for t in TOPICS:
            text = " ".join(x for _, x in kit._public_texts(t, "en"))
            # "does not diagnose" is the intended negation; strip it before looking for claims
            text = text.replace("does not diagnose", "")
            self.assertIsNone(bad.search(text), (t["id"], bad.search(text)))


class ChapterTests(unittest.TestCase):
    SB = {"timing": {"leadSec": 0.25, "tailSec": 0.35, "gapSec": 0.2},
          "scenes": [{"id": "a", "lines": ["L1"], "minSec": 4}, {"id": "b", "lines": ["L2"], "minSec": 4},
                     {"id": "c", "lines": ["L3"], "minSec": 4}, {"id": "d", "lines": ["L4"], "minSec": 6}]}
    TM = {"totalSec": 30.0, "lines": [{"id": "L1", "start": 0.25, "end": 6.0}, {"id": "L2", "start": 6.5, "end": 12.0},
                                      {"id": "L3", "start": 12.5, "end": 19.0}, {"id": "L4", "start": 20.0, "end": 28.0}]}

    def test_layout_matches_js_rules(self):
        scenes, total = chapters.layout_scenes(self.SB, self.TM)
        self.assertEqual([s[0] for s in scenes], ["a", "b", "c", "d"])
        self.assertEqual(scenes[0][1], 0.0)
        self.assertAlmostEqual(scenes[1][1], 6.25)       # first.start - lead
        self.assertAlmostEqual(scenes[3][1], 19.75)
        self.assertEqual(total, 30.0)
        self.assertAlmostEqual(scenes[-1][2], 30.0)

    def test_timestamp_format(self):
        self.assertEqual(chapters.fmt_ts(0), "0:00")
        self.assertEqual(chapters.fmt_ts(68.4), "1:08")
        self.assertEqual(chapters.fmt_ts(3725), "1:02:05")

    def _write(self, d, tid, spec_lines):
        (d / "docs" / tid).mkdir(parents=True)
        (d / "audio" / "en").mkdir(parents=True)
        (d / "docs" / tid / "storyboard.json").write_text(json.dumps(self.SB), encoding="utf-8")
        (d / "audio" / "en" / f"{tid}.timing.json").write_text(json.dumps(self.TM), encoding="utf-8")
        for lang in LANGS:
            (d / "docs" / tid / f"lines.{lang}.json").write_text(
                json.dumps({"lines": {k: f"{lang} line {k}" for k in spec_lines}}), encoding="utf-8")

    def test_auto_chapters_are_at_least_ten_seconds_and_flagged(self):
        d = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, d, True)
        self._write(d, "zzz", ["L1", "L2", "L3", "L4"])
        res = chapters.compute({"id": "zzz", "chapters": None}, d / "docs", d / "audio")
        chs = res["chapters"]
        self.assertEqual(chs[0]["start"], 0.0)
        for c in chs:
            self.assertGreaterEqual(c["end"] - c["start"], 10.0)
            self.assertTrue(c["auto"])
        self.assertEqual(chs[0]["titles"]["uz"], "uz line L1")
        self.assertTrue(any("automatic" in p for p in res["problems"]))

    def test_explicit_chapters_and_validation(self):
        d = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, d, True)
        self._write(d, "zzz", ["L1", "L2", "L3", "L4"])
        titles = lambda s: {"en": s, "ru": s, "uz": s}  # noqa: E731
        spec = [("a", titles("A")), ("c", titles("C"))]
        res = chapters.compute({"id": "zzz", "chapters": spec}, d / "docs", d / "audio")
        self.assertEqual([chapters.fmt_ts(c["start"]) for c in res["chapters"]], ["0:00", "0:12"])
        self.assertTrue(any("at least 3" in p for p in res["problems"]))
        with self.assertRaises(chapters.ChapterError):
            chapters.compute({"id": "zzz", "chapters": [("a", titles("A")), ("nope", titles("N"))]},
                             d / "docs", d / "audio")
        with self.assertRaises(chapters.ChapterError):
            chapters.compute({"id": "zzz", "chapters": [("b", titles("B"))]}, d / "docs", d / "audio")

    def test_missing_storyboard_gives_reason_not_crash(self):
        res = chapters.compute({"id": "nope", "chapters": None}, Path("/nonexistent"), Path("/nonexistent"))
        self.assertIsNone(res["chapters"])
        self.assertIn("storyboard", res["reason"])

    def test_real_flagship_chapters(self):
        docs = REPO / "docs" / "video"
        audio = REPO / "video_studio" / "public" / "audio"
        for tid, first_starts in (("calibration", ["0:00", "0:17", "0:27", "0:53", "1:08"]),
                                  ("leukocyte", ["0:00", "0:15", "0:44", "1:04", "1:21", "1:40"])):
            if not (audio / "en" / f"{tid}.timing.json").is_file():
                self.skipTest("narration timing manifests are not present (git-ignored build output)")
            res = chapters.compute(BY_ID[tid], docs, audio)
            self.assertEqual([chapters.fmt_ts(c["start"]) for c in res["chapters"]], first_starts)
            self.assertEqual(res["problems"], [])
            for c in res["chapters"]:
                self.assertGreaterEqual(c["end"] - c["start"], 10.0)


class StatusTests(unittest.TestCase):
    def test_ready_when_all_files_present_or_listed(self):
        d = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, d, True)
        t = BY_ID["qc"]
        self.assertEqual(kit.topic_status(t, d, None)[0], "NOT READY")
        for lang in LANGS:
            (d / "qc" / lang).mkdir(parents=True)
            for kind in kit.FILE_PATTERNS:
                (d / "qc" / lang / kit.fname(kind, "qc", lang)).write_bytes(b"x")
        self.assertEqual(kit.topic_status(t, d, None)[0], "READY")
        shutil.rmtree(d / "qc")
        self.assertEqual(kit.topic_status(t, d, {"qc"})[0], "READY")
        self.assertIn("missing", kit.topic_status(t, d, {"qc"})[1])

    def test_read_ready_ids(self):
        d = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, d, True)
        self.assertIsNone(kit.read_ready_ids(d))
        (d / "READY.txt").write_text("qc\n# comment\n\ngcms # done\n", encoding="utf-8")
        self.assertEqual(kit.read_ready_ids(d), {"qc", "gcms"})


class ScheduleTests(unittest.TestCase):
    STATUSES = {t["id"]: ("NOT READY", "") for t in TOPICS}

    def test_six_weeks_and_proposal_label(self):
        rows = schedule.rows(self.STATUSES)
        self.assertEqual(sorted({r["week"] for r in rows}), [1, 2, 3, 4, 5, 6])
        for r in rows:
            self.assertTrue(r["proposal_status"].startswith("PROPOSAL"))
        md = schedule.render_md(self.STATUSES, "2000-01-01")
        self.assertIn("PROPOSAL", md)
        self.assertIn("needs the owner's approval", md)
        self.assertIn("Nothing is published", md)
        self.assertIn("Unreviewed-science rule", md)
        self.assertIn("Ad-readiness checklist", md)

    def test_every_topic_scheduled_once_with_three_editions_per_platform(self):
        rows = [r for r in schedule.rows(self.STATUSES) if r["topic_id"] != "—"]
        for tid in IDS:
            mine = [r for r in rows if r["topic_id"] == tid]
            for platform in ("YouTube", "Instagram"):
                langs = sorted(r["language_edition"] for r in mine if r["platform"] == platform)
                self.assertEqual(langs, ["en", "ru", "uz"], (tid, platform))

    def test_paid_topics_are_last_and_gated(self):
        rows = [r for r in schedule.rows(self.STATUSES) if r["topic_id"] in ("exam_simulation", "teacher_pro",
                                                                              "premium_overview")]
        self.assertTrue(all("GP" in r["gates"] for r in rows))
        free_weeks = {r["week"] for r in schedule.rows(self.STATUSES)
                      if r["topic_id"] not in ("—", "exam_simulation", "teacher_pro", "premium_overview")}
        self.assertLess(max(free_weeks), min(r["week"] for r in rows))

    def test_csv_parses_and_has_no_calendar_dates(self):
        text = schedule.render_csv(self.STATUSES)
        rows = list(csv.DictReader(io.StringIO(text)))
        self.assertEqual(list(rows[0].keys()), schedule.CSV_FIELDS)
        self.assertIsNone(re.search(r"\d{4}-\d{2}-\d{2}", text))
        self.assertTrue(all(r["file"].endswith((".mp4", "—")) for r in rows))

    def test_checklist_names_every_required_blocker(self):
        text = " ".join(" ".join(row) for row in schedule.CHECKLIST)
        for needle in ("Music", "Kokoro", "OFL", "Remotion", "Listening review", "Expert science review",
                       "Native RU", "store approval", "Paid features"):
            self.assertIn(needle.lower(), text.lower(), needle)


class CommittedKitTests(unittest.TestCase):
    def test_a_file_per_topic_plus_schedule_is_committed(self):
        for tid in IDS:
            p = PUBLISH_DOCS / f"{tid}.md"
            self.assertTrue(p.is_file(), p)
            self.assertIn("PROPOSAL", p.read_text(encoding="utf-8"))
        self.assertTrue((PUBLISH_DOCS / "spectrophotometry.md").is_file())     # alias of photometry
        self.assertTrue((PUBLISH_DOCS / "SCHEDULE.md").is_file())
        self.assertTrue((PUBLISH_DOCS / "SCHEDULE.csv").is_file())

    def test_committed_md_has_no_price_tokens(self):
        for tid in IDS:
            text = (PUBLISH_DOCS / f"{tid}.md").read_text(encoding="utf-8")
            self.assertIsNone(kit.PRICE_RE.search(text), tid)


if __name__ == "__main__":
    unittest.main()
