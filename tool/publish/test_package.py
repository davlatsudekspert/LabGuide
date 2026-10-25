"""Unit tests for tool/publish/package.py (python3 -m unittest discover -s tool/publish -p 'test_*.py').

Uses tiny fake clips made with ffmpeg lavfi (2 s) in a temp dir; nothing touches video_studio/out.
Skipped when ffmpeg / ffprobe are not installed.
"""
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import package  # noqa: E402
from common import LANGS  # noqa: E402

HAVE_FFMPEG = bool(shutil.which("ffmpeg")) and bool(shutil.which("ffprobe"))

CLAIMS_OK = """# Claims

| # | Where | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| C1 | hook | something | code | test |
"""
CLAIMS_NO_TABLE = "# Claims\n\nNothing tabular here.\n"


def ff(*args):
    subprocess.run(["ffmpeg", "-v", "error", "-y", *args], check=True)


@unittest.skipUnless(HAVE_FFMPEG, "ffmpeg/ffprobe not installed")
class PackageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.stubs = Path(tempfile.mkdtemp(prefix="pub_stubs_"))
        s = cls.stubs
        for name, size in (("h.mp4", "1920x1080"), ("v.mp4", "1080x1920")):
            ff("-f", "lavfi", "-i", f"color=c=black:s={size}:r=30:d=2", "-f", "lavfi",
               "-i", "sine=frequency=440:sample_rate=48000:d=2", "-c:v", "libx264", "-pix_fmt", "yuv420p",
               "-c:a", "aac", "-shortest", str(s / name))
        ff("-f", "lavfi", "-i", "color=c=black:s=1920x1080:r=30:d=2", "-c:v", "libx264", "-pix_fmt", "yuv420p",
           str(s / "silent.mp4"))
        ff("-f", "lavfi", "-i", "color=c=blue:s=1280x720", "-frames:v", "1", str(s / "thumb.jpg"))
        ff("-f", "lavfi", "-i", "color=c=blue:s=1080x1920", "-frames:v", "1", str(s / "cover.jpg"))
        (s / "x.srt").write_text("1\n00:00:00,000 --> 00:00:01,000\nHello o‘ g‘\n", encoding="utf-8")
        (s / "x.vtt").write_text("WEBVTT\n\n00:00:00.000 --> 00:00:01.000\nHello o‘ g‘\n", encoding="utf-8")

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.stubs, ignore_errors=True)

    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="pub_test_"))
        self.addCleanup(shutil.rmtree, self.tmp, True)
        self.out_root = self.tmp / "out"
        self.docs = self.tmp / "docs_video"
        self.audio = self.tmp / "audio"
        self.dest = self.tmp / "packages"

    def make_topic(self, tid="calibration", claims=CLAIMS_OK, langs=LANGS):
        for lang in langs:
            d = self.out_root / tid / lang
            d.mkdir(parents=True, exist_ok=True)
            shutil.copy(self.stubs / "h.mp4", d / f"{tid}_{lang}_horizontal.mp4")
            shutil.copy(self.stubs / "v.mp4", d / f"{tid}_{lang}_vertical.mp4")
            shutil.copy(self.stubs / "thumb.jpg", d / f"{tid}_{lang}_thumb_1280x720.jpg")
            shutil.copy(self.stubs / "cover.jpg", d / f"{tid}_{lang}_cover_1080x1920.jpg")
            shutil.copy(self.stubs / "x.srt", d / f"{tid}_{lang}.srt")
            shutil.copy(self.stubs / "x.vtt", d / f"{tid}_{lang}.vtt")
        cd = self.docs / tid
        cd.mkdir(parents=True, exist_ok=True)
        if claims is not None:
            (cd / "CLAIMS_AND_EVIDENCE.md").write_text(claims, encoding="utf-8")

    def run_pkg(self, **kw):
        kw.setdefault("out_root", self.out_root)
        kw.setdefault("docs_video", self.docs)
        kw.setdefault("audio_root", self.audio)
        kw.setdefault("out_dir", self.dest)
        kw.setdefault("log", lambda *a: None)
        return package.run(**kw)

    # ---------------------------------------------------------------- happy path
    def test_builds_both_archives_and_manifest(self):
        self.make_topic("calibration")
        self.make_topic("leukocyte")
        res = self.run_pkg()
        self.assertEqual(res["ids"], ["calibration", "leukocyte"])
        yt = zipfile.ZipFile(self.dest / package.YOUTUBE_ZIP)
        ig = zipfile.ZipFile(self.dest / package.INSTAGRAM_ZIP)
        self.assertIsNone(yt.testzip())
        ynames, inames = set(yt.namelist()), set(ig.namelist())
        root = package.YT_ROOT
        for lang in LANGS:
            for tid in ("calibration", "leukocyte"):
                self.assertIn(f"{root}/{tid}/{lang}/{tid}_{lang}_horizontal.mp4", ynames)
                self.assertIn(f"{root}/{tid}/{lang}/{tid}_{lang}_thumb_1280x720.jpg", ynames)
                self.assertIn(f"{root}/{tid}/{lang}/{tid}_{lang}.srt", ynames)
                self.assertIn(f"{root}/{tid}/{lang}/{tid}_{lang}.vtt", ynames)
                for f in ("title.txt", "description.txt", "tags.txt", "chapters.txt", "pinned_comment.txt",
                          "credits.txt", "disclosures.txt", "thumbnail_alt.txt"):
                    self.assertIn(f"{root}/{tid}/{lang}/{f}", ynames)
                self.assertNotIn(f"{root}/{tid}/{lang}/{tid}_{lang}_vertical.mp4", ynames)
                self.assertIn(f"{package.IG_ROOT}/{tid}/{lang}/{tid}_{lang}_vertical.mp4", inames)
                self.assertIn(f"{package.IG_ROOT}/{tid}/{lang}/{tid}_{lang}_cover_1080x1920.jpg", inames)
                self.assertIn(f"{package.IG_ROOT}/{tid}/{lang}/caption.txt", inames)
                self.assertIn(f"{package.IG_ROOT}/{tid}/{lang}/hashtags.txt", inames)
                self.assertNotIn(f"{package.IG_ROOT}/{tid}/{lang}/{tid}_{lang}_horizontal.mp4", inames)
        for r in (root, package.IG_ROOT):
            pass
        for need in ("README.md", "SCHEDULE.md", "SCHEDULE.csv", "MANIFEST.json", "SHA256SUMS.txt"):
            self.assertIn(f"{package.YT_ROOT}/{need}", ynames)
            self.assertIn(f"{package.IG_ROOT}/{need}", inames)
        # UTF-8 Uzbek text with the right apostrophes
        title = yt.read(f"{root}/calibration/uz/title.txt").decode("utf-8")
        self.assertIn("LabGuide’da", title)
        desc = yt.read(f"{root}/calibration/en/description.txt").decode("utf-8")
        self.assertIn("English synthetic narration (Kokoro-82M, Apache-2.0)", desc)
        self.assertIn("Illustrative data — not patient results", desc)
        # manifest facts
        manifest = json.loads((self.dest / package.MANIFEST).read_text(encoding="utf-8"))
        self.assertEqual(manifest["topic_ids"], ["calibration", "leukocyte"])
        f = manifest["topics"][0]["editions"]["en"]["files"]["yt_video"]
        self.assertEqual((f["ffprobe"]["video"]["width"], f["ffprobe"]["video"]["height"]), (1920, 1080))
        self.assertEqual(f["ffprobe"]["video"]["codec"], "h264")
        self.assertEqual(f["ffprobe"]["audio"]["sample_rate_hz"], 48000)
        self.assertAlmostEqual(f["ffprobe"]["duration_sec"], 2.0, delta=0.2)
        v = manifest["topics"][0]["editions"]["en"]["files"]["ig_video"]
        self.assertEqual((v["ffprobe"]["video"]["width"], v["ffprobe"]["video"]["height"]), (1080, 1920))
        t = manifest["topics"][0]["editions"]["en"]["files"]["thumb"]
        self.assertEqual((t["ffprobe"]["video"]["width"], t["ffprobe"]["video"]["height"]), (1280, 720))
        # sha256 in the manifest equals the archived bytes
        name = f"{root}/calibration/en/calibration_en_horizontal.mp4"
        self.assertEqual(hashlib.sha256(yt.read(name)).hexdigest(), f["sha256"])
        self.assertEqual(manifest["archives"][package.YOUTUBE_ZIP]["sha256"],
                         package.sha256_file(self.dest / package.YOUTUBE_ZIP))
        # SHA256SUMS covers every payload entry (not the README)
        sums = yt.read(f"{root}/SHA256SUMS.txt").decode("utf-8")
        self.assertIn(f["sha256"], sums)
        self.assertIn("calibration/en/calibration_en_horizontal.mp4", sums)
        # media stored, text deflated
        self.assertEqual(yt.getinfo(name).compress_type, zipfile.ZIP_STORED)
        self.assertEqual(yt.getinfo(f"{root}/README.md").compress_type, zipfile.ZIP_DEFLATED)
        # placeholders are reported, not invented
        self.assertIn("[[LINK_APP_STORE]]", manifest["placeholders_to_fill"])
        # unverified-copy warning for the ids that have a draft/verified flag
        self.assertTrue(any("no chapters" in w for w in manifest["warnings"]))

    def test_rerun_replaces_without_duplicates(self):
        self.make_topic("calibration")
        self.run_pkg()
        self.run_pkg()
        self.assertEqual(sorted(p.name for p in self.dest.iterdir()),
                         sorted([package.YOUTUBE_ZIP, package.INSTAGRAM_ZIP, package.MANIFEST]))

    def test_dry_run_writes_nothing(self):
        self.make_topic("calibration")
        res = self.run_pkg(dry_run=True)
        self.assertEqual(res["ids"], ["calibration"])
        self.assertFalse(self.dest.exists())

    def test_only_one_archive(self):
        self.make_topic("calibration")
        self.run_pkg(only="instagram")
        self.assertTrue((self.dest / package.INSTAGRAM_ZIP).exists())
        self.assertFalse((self.dest / package.YOUTUBE_ZIP).exists())

    # ---------------------------------------------------------------- refusals
    def test_missing_declared_file_fails_loudly(self):
        self.make_topic("calibration")
        (self.out_root / "calibration" / "uz" / "calibration_uz_thumb_1280x720.jpg").unlink()
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg(ids=["calibration"])
        self.assertIn("calibration_uz_thumb_1280x720.jpg", str(cm.exception))
        self.assertFalse(self.dest.exists())

    def test_refuses_video_without_claims_table(self):
        self.make_topic("calibration", claims=CLAIMS_NO_TABLE)
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg()
        self.assertIn("refused", str(cm.exception))
        self.assertIn("claims table", str(cm.exception))

    def test_refuses_video_without_claims_file(self):
        self.make_topic("calibration", claims=None)
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg()
        self.assertIn("missing", str(cm.exception))

    def test_skip_unclaimed_excludes_only_that_id(self):
        self.make_topic("calibration")
        self.make_topic("leukocyte", claims=CLAIMS_NO_TABLE)
        res = self.run_pkg(skip_unclaimed=True)
        self.assertEqual(res["ids"], ["calibration"])
        self.assertEqual(len(res["excluded"]), 1)
        names = zipfile.ZipFile(self.dest / package.YOUTUBE_ZIP).namelist()
        self.assertFalse(any("/leukocyte/" in n for n in names))

    def test_wrong_dimensions_fail(self):
        self.make_topic("calibration")
        shutil.copy(self.stubs / "v.mp4", self.out_root / "calibration" / "en" / "calibration_en_horizontal.mp4")
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg()
        self.assertIn("1080x1920, expected 1920x1080", str(cm.exception))

    def test_video_without_audio_fails(self):
        self.make_topic("calibration")
        shutil.copy(self.stubs / "silent.mp4", self.out_root / "calibration" / "ru" / "calibration_ru_horizontal.mp4")
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg()
        self.assertIn("no audio", str(cm.exception))

    def test_bad_vtt_fails(self):
        self.make_topic("calibration")
        (self.out_root / "calibration" / "en" / "calibration_en.vtt").write_text("not webvtt\n", encoding="utf-8")
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg()
        self.assertIn("WEBVTT", str(cm.exception))

    def test_unknown_id_has_no_kit_text(self):
        self.make_topic("mystery_topic")
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg(ids=["mystery_topic"])
        self.assertIn("topics.py", str(cm.exception))

    def test_ffprobe_missing_fails(self):
        self.make_topic("calibration")
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg(ffprobe="definitely-not-ffprobe")
        self.assertIn("ffprobe", str(cm.exception))

    def test_nothing_to_package(self):
        self.out_root.mkdir()
        with self.assertRaises(package.PackageError):
            self.run_pkg()

    # ---------------------------------------------------------------- READY.txt logic
    def test_partial_id_not_in_ready_is_skipped_with_warning(self):
        self.make_topic("calibration")
        self.make_topic("qc", langs=("en",))          # still rendering: only the EN edition exists
        (self.out_root / "READY.txt").write_text("calibration\n", encoding="utf-8")
        res = self.run_pkg()
        self.assertEqual(res["ids"], ["calibration"])
        self.assertTrue(any("qc" in w and "skipped" in w for w in res["warnings"]))

    def test_ready_id_with_missing_files_fails(self):
        self.make_topic("calibration")
        self.make_topic("qc", langs=("en",))
        (self.out_root / "READY.txt").write_text("calibration\nqc  # done\n", encoding="utf-8")
        with self.assertRaises(package.PackageError) as cm:
            self.run_pkg()
        self.assertIn("qc", str(cm.exception))

    def test_complete_id_not_listed_in_ready_is_included(self):
        self.make_topic("calibration")
        self.make_topic("leukocyte")
        (self.out_root / "READY.txt").write_text("leukocyte\n", encoding="utf-8")
        res = self.run_pkg()
        self.assertEqual(res["ids"], ["calibration", "leukocyte"])

    # ---------------------------------------------------------------- disk
    def test_not_enough_space_fails_before_writing(self):
        self.make_topic("calibration")
        real = package.free_bytes
        package.free_bytes = lambda p: 1024
        try:
            with self.assertRaises(package.PackageError) as cm:
                self.run_pkg()
        finally:
            package.free_bytes = real
        self.assertIn("not enough disk space", str(cm.exception))
        self.assertEqual([p for p in self.dest.iterdir()], [])

    def test_old_archive_deleted_first_when_both_do_not_fit(self):
        self.make_topic("calibration")
        self.run_pkg()
        old_size = sum(p.stat().st_size for p in self.dest.glob("*.zip"))
        planned = sum(self.run_pkg(dry_run=True)["planned"].values())
        real = package.free_bytes
        # not enough room for old + new at once, but enough once the old archives are deleted
        package.free_bytes = lambda p: package.SPACE_MARGIN + planned - old_size + 1
        logs = []
        try:
            self.run_pkg(log=logs.append)
        finally:
            package.free_bytes = real
        self.assertTrue(any("deleting the old" in l for l in logs))
        self.assertEqual(len(list(self.dest.glob("*.zip"))), 2)
        self.assertEqual([p.name for p in self.dest.glob("*.partial")], [])

    # ---------------------------------------------------------------- CLI
    def test_cli_exit_codes(self):
        self.make_topic("calibration")
        argv = ["--out-root", str(self.out_root), "--docs-video", str(self.docs), "--audio-root", str(self.audio),
                "--out-dir", str(self.dest)]
        self.assertEqual(package.main(argv + ["--dry-run"]), 0)
        (self.docs / "calibration" / "CLAIMS_AND_EVIDENCE.md").write_text(CLAIMS_NO_TABLE, encoding="utf-8")
        self.assertEqual(package.main(argv + ["--dry-run"]), 2)


class ClaimsTableTests(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="pub_claims_"))
        self.addCleanup(shutil.rmtree, self.tmp, True)

    def check(self, text):
        d = self.tmp / "x"
        d.mkdir(exist_ok=True)
        (d / "CLAIMS_AND_EVIDENCE.md").write_text(text, encoding="utf-8")
        return package.claims_table_problem(self.tmp, "x")

    def test_table_accepted(self):
        self.assertIsNone(self.check(CLAIMS_OK))

    def test_header_only_table_rejected(self):
        self.assertIsNotNone(self.check("| Claim | Evidence |\n|---|---|\n"))

    def test_table_without_evidence_column_rejected(self):
        self.assertIsNotNone(self.check("| Claim | Note |\n|---|---|\n| a | b |\n"))

    def test_missing_file(self):
        self.assertIn("missing", package.claims_table_problem(self.tmp, "nope"))

    def test_real_flagship_claims_tables_are_accepted(self):
        docs = Path(__file__).resolve().parents[2] / "docs" / "video"
        for tid in ("calibration", "leukocyte"):
            if (docs / tid / "CLAIMS_AND_EVIDENCE.md").is_file():
                self.assertIsNone(package.claims_table_problem(docs, tid), tid)


if __name__ == "__main__":
    unittest.main()
