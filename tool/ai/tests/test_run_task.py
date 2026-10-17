import json
import os
import unittest
from pathlib import Path

import helpers  # noqa: F401
import run_task
from helpers import FakeAPIError, FakeClient, REPO, make_root, resp

KEY = "sk-ant-api03-TESTKEYTESTKEYTESTKEY"


def finding(**kw):
    base = {"field": "claim[1]:high_result", "language": "en", "category": "overclaim", "severity": "major",
            "quote": "A high ALT confirms liver disease.", "reason": "'confirms' is diagnostic wording",
            "what_to_check": "Compare with the cited locator"}
    base.update(kw)
    return base


class RunBase(unittest.TestCase):
    def setUp(self):
        self.tmp, self.root = make_root()
        self.addCleanup(self.tmp.cleanup)
        self.logs: list[str] = []
        self.summary = self.root / "summary.md"

    def go(self, argv, client=None, env=None, **kw):
        e = {"ANTHROPIC_API_KEY": KEY, "GITHUB_STEP_SUMMARY": str(self.summary)} if env is None else env
        factory = (lambda key: client) if client is not None else None
        args = ["--root", str(self.root), "--date", "2026-10-17", *argv]
        return run_task.run(args, env=e, client_factory=factory, sleep=lambda s: None, log=self.logs.append)

    def reports(self):
        d = self.root / "docs/ai_reports"
        return sorted(p.name for p in d.glob("*")) if d.exists() else []

    def log_text(self):
        return "\n".join(self.logs)


class DryRunTests(RunBase):
    def test_dry_run_calls_nothing_and_writes_no_report(self):
        def boom(key):
            raise AssertionError("dry-run mijoz yaratmasligi kerak")

        rc = run_task.run(["--root", str(self.root), "--task", "content_review", "--target", "pack", "--dry-run"],
                          env={"ANTHROPIC_API_KEY": KEY, "GITHUB_STEP_SUMMARY": str(self.summary)},
                          client_factory=boom, log=self.logs.append)
        self.assertEqual(rc, 0)
        self.assertEqual(self.reports(), [])
        text = self.log_text()
        self.assertIn("DRY RUN", text)
        self.assertIn("analyte:alt", text)
        self.assertIn("estimated input tokens", text)
        self.assertIn("worst case", text)
        self.assertNotIn(KEY, text)
        self.assertIn("DRY RUN", self.summary.read_text())

    def test_dry_run_works_without_key(self):
        rc = self.go(["--task", "translate_check", "--target", "cytology", "--dry-run"], env={})
        self.assertEqual(rc, 0)


class ArgValidationTests(RunBase):
    def test_opus_only_for_content_review(self):
        rc = self.go(["--task", "ru_terminology", "--target", "pack", "--model", "claude-opus-5-5", "--dry-run"])
        self.assertEqual(rc, 2)
        self.assertIn("faqat content_review", self.log_text())
        self.assertEqual(self.go(["--task", "content_review", "--target", "pack", "--model", "claude-opus-5-5", "--dry-run"]), 0)

    def test_bad_inputs_rejected(self):
        cases = [
            ["--task", "content_review", "--target", "x;y", "--dry-run"],
            ["--task", "content_review", "--target", "pack", "--model", "gpt-4", "--dry-run"],
            ["--task", "content_review", "--target", "pack", "--budget-usd", "50", "--dry-run"],
            ["--task", "content_review", "--target", "pack", "--budget-usd", "abc", "--dry-run"],
            ["--task", "content_review", "--target", "pack", "--max-items", "0", "--dry-run"],
            ["--task", "content_review", "--target", "pack", "--date", "yesterday", "--dry-run"],
            ["--task", "content_review", "--target", "nothing-matches-this", "--dry-run"],
            ["--task", "content_review", "--target", "pack", "--out-dir", "../outside", "--dry-run"],
        ]
        for argv in cases:
            self.assertEqual(self.go(argv), 2, argv)

    def test_max_items_clamped_to_60(self):
        ns = run_task.validate_args(run_task.build_parser().parse_args(
            ["--task", "content_review", "--target", "pack", "--max-items", "1000", "--root", str(self.root)]))
        self.assertEqual(ns.max_items, 60)


class MissingKeyTests(RunBase):
    def test_missing_key_fails_clearly_before_any_call(self):
        client = FakeClient([resp({})])
        rc = self.go(["--task", "content_review", "--target", "analyte:alt"], client=client, env={})
        self.assertEqual(rc, 3)
        self.assertIn("ANTHROPIC_API_KEY", self.log_text())
        self.assertEqual(client.calls, [])
        self.assertEqual(self.reports(), [])


class RealRunTests(RunBase):
    def test_content_review_end_to_end(self):
        client = FakeClient([resp({"findings": [finding(), finding(quote="invented", severity="minor")], "summary": "s"}),
                             resp({"findings": [], "summary": "nothing to flag"})])
        rc = self.go(["--task", "content_review", "--target", "group:liver"], client=client)
        self.assertEqual(rc, 0)
        self.assertEqual(len(client.calls), 2)
        self.assertEqual(self.reports(), ["2026-10-17_content_review_group-liver.json", "2026-10-17_content_review_group-liver.md"])
        data = json.loads((self.root / "docs/ai_reports/2026-10-17_content_review_group-liver.json").read_text())
        self.assertEqual(data["meta"]["status"], "complete")
        self.assertEqual(data["meta"]["review_status"], "ai_suggestions_unreviewed")
        self.assertEqual(data["meta"]["tokens_in"], 2000)
        self.assertEqual(data["meta"]["tokens_out"], 600)
        self.assertAlmostEqual(data["meta"]["cost_usd"], 2 * (1000 * 2 + 300 * 10) / 1e6, places=6)
        first = data["results"][0]["result"]["findings"]
        self.assertEqual([f["quote_verified"] for f in first], [True, False])
        md = (self.root / "docs/ai_reports/2026-10-17_content_review_group-liver.md").read_text()
        self.assertIn("AI taklifi", md)
        self.assertIn("quote not found in item", md)
        self.assertIn("No findings.", md)
        # hech narsa maxfiy emas
        for blob in (md, json.dumps(data), self.log_text(), self.summary.read_text()):
            self.assertNotIn("TESTKEYTESTKEY", blob)
        # logda faqat token sonlari, so'rov/javob matni yo'q
        self.assertIn("in=1000 out=300", self.log_text())
        self.assertNotIn("confirms", self.log_text())

    def test_request_sends_item_as_data_with_schema(self):
        client = FakeClient([resp({"findings": [], "summary": ""})])
        self.assertEqual(self.go(["--task", "content_review", "--target", "analyte:alt"], client=client), 0)
        kw = client.calls[0]
        self.assertIn("<item_json>", kw["messages"][0]["content"])
        self.assertIn("analyte:alt", kw["messages"][0]["content"])
        self.assertNotIn(KEY, json.dumps(kw))
        self.assertEqual(kw["output_config"]["format"]["type"], "json_schema")

    def test_budget_guard_stops_run_and_marks_skipped(self):
        # har chaqiruv ~ $0.0023; max_tokens=8000 -> eng yomon holat ~$0.08 > 0.05 -> birinchi chaqiruvdan oldin ham to'xtaydi
        client = FakeClient([resp({"findings": [], "summary": ""})])
        rc = self.go(["--task", "content_review", "--target", "pack", "--budget-usd", "0.05"], client=client)
        self.assertEqual(rc, 1)  # hech narsa bajarilmadi
        self.assertEqual(client.calls, [])
        self.assertIn("BUDGET", self.log_text())

    def test_budget_guard_partial_after_observed_usage(self):
        # kichik max_tokens bilan birinchisi sig'adi, kuzatilgan sarf ikkinchisiga to'sqinlik qiladi
        client = FakeClient([resp({"findings": [], "summary": ""}, tin=1000, tout=1500)])
        rc = self.go(["--task", "content_review", "--target", "pack", "--budget-usd", "0.03", "--max-tokens", "2000"], client=client)
        self.assertEqual(rc, 0)
        data = json.loads(next((self.root / "docs/ai_reports").glob("*.json")).read_text())
        self.assertEqual(data["meta"]["status"], "partial")
        self.assertEqual(len(client.calls), 1)
        self.assertEqual(data["meta"]["items_done"], 1)
        self.assertGreaterEqual(data["meta"]["items_skipped_budget"], 1)
        self.assertLessEqual(data["meta"]["cost_usd"], 0.03)

    def test_schema_violation_recorded_as_failure_not_crash(self):
        client = FakeClient([resp({"findings": [{"field": "x"}], "summary": "s"}), resp({"findings": [], "summary": ""})])
        rc = self.go(["--task", "content_review", "--target", "group:liver"], client=client)
        self.assertEqual(rc, 0)
        data = json.loads(next((self.root / "docs/ai_reports").glob("*.json")).read_text())
        self.assertFalse(data["results"][0]["ok"])
        self.assertIn("sxemaga mos emas", data["results"][0]["error"])
        self.assertTrue(data["results"][1]["ok"])
        self.assertEqual(data["meta"]["status"], "partial")

    def test_fatal_auth_error_aborts_remaining_items(self):
        client = FakeClient([FakeAPIError(401, "invalid x-api-key")])
        rc = self.go(["--task", "translate_check", "--target", "all-small", "--max-items", "6"], client=client)
        self.assertEqual(rc, 1)
        self.assertEqual(len(client.calls), 1)
        data = json.loads(next((self.root / "docs/ai_reports").glob("*.json")).read_text())
        self.assertEqual(data["meta"]["items_aborted"], 5)
        self.assertEqual(data["meta"]["status"], "failed")

    def test_three_consecutive_failures_abort(self):
        client = FakeClient([resp(text="not json")])
        rc = self.go(["--task", "translate_check", "--target", "all-small", "--max-items", "8"], client=client)
        self.assertEqual(rc, 1)
        self.assertEqual(len(client.calls), 3)

    def test_quiz_draft_end_to_end_marks_ai_draft_and_drops_unquoted(self):
        def loc(x):
            return {"uz": x, "ru": x, "en": x}

        def q(quote):
            return {"source_field": "claim[0]:purpose", "support_lang": "en", "support_quote": quote,
                    "prompt": loc("P"), "basis": loc("B"), "correct_index": 2,
                    "options": [{"text": loc(f"opt{i}"), "explanation": loc("E")} for i in range(4)]}

        good = "ALT is an enzyme released into the blood when liver cells are damaged."
        client = FakeClient([resp({"questions": [q(good), q("not in the card")], "skipped_reason": ""})])
        rc = self.go(["--task", "quiz_draft", "--target", "analyte:alt"], client=client)
        self.assertEqual(rc, 0)
        data = json.loads(next((self.root / "docs/ai_reports").glob("*.json")).read_text())
        res = data["results"][0]["result"]
        self.assertEqual(len(res["questions"]), 1)
        self.assertEqual(res["questions"][0]["status"], "ai_draft")
        self.assertEqual(len(res["rejected"]), 1)
        self.assertIn("so'zma-so'z", res["rejected"][0]["reject_reason"])
        self.assertIn("exactly 4 options", client.calls[0]["system"])

    def test_ru_terminology_and_translate_check_render(self):
        ru = {"suggestions": [{"field": "claim[0]:purpose", "original_term": "х", "issue": "i", "suggested_term": "у",
                               "basis": "unsure", "confidence": "low", "rationale": "r"}], "summary": "s"}
        self.assertEqual(self.go(["--task", "ru_terminology", "--target", "analyte:alt"], client=FakeClient([resp(ru)])), 0)
        tc = {"mismatches": [{"field": "f", "type": "omission", "severity": "minor", "quote_uz": "a", "quote_ru": "",
                              "quote_en": "c", "explanation": "e"}], "summary": "s"}
        self.assertEqual(self.go(["--task", "translate_check", "--target", "analyte:alt"], client=FakeClient([resp(tc)])), 0)
        mds = [p for p in (self.root / "docs/ai_reports").glob("*.md")]
        self.assertEqual(len(mds), 2)

    def test_same_day_rerun_does_not_overwrite(self):
        for _ in range(2):
            self.assertEqual(self.go(["--task", "content_review", "--target", "analyte:alt"],
                                     client=FakeClient([resp({"findings": [], "summary": ""})])), 0)
        self.assertEqual(len(self.reports()), 4)
        self.assertTrue(any("_r2" in n for n in self.reports()))

    def test_output_with_key_like_text_is_not_written(self):
        leaked = {"findings": [finding(reason=f"leak {KEY}")], "summary": ""}
        client = FakeClient([resp(leaked)])
        rc = self.go(["--task", "content_review", "--target", "analyte:alt"], client=client)
        self.assertEqual(rc, 4)
        self.assertEqual(self.reports(), [])
        self.assertNotIn("TESTKEYTESTKEY", self.log_text())

    def test_key_not_written_anywhere_under_root(self):
        client = FakeClient([resp({"findings": [], "summary": ""})])
        self.go(["--task", "content_review", "--target", "analyte:alt"], client=client)
        for p in self.root.rglob("*"):
            if p.is_file():
                self.assertNotIn(b"TESTKEYTESTKEY", p.read_bytes(), str(p))


class RealRepoDryRunTests(unittest.TestCase):
    def test_dry_run_on_real_repo_writes_nothing(self):
        if not (REPO / "assets/content/core/pack.json").exists():
            self.skipTest("repo tashqarisida")
        logs: list[str] = []
        before = set(p.name for p in (REPO / "docs").glob("*"))
        for target in ("all-small", "cytology", "spermogram", "bloodgroup", "analyte:alt"):
            rc = run_task.run(["--task", "content_review", "--target", target, "--dry-run", "--max-items", "60"],
                              env={}, log=logs.append)
            self.assertEqual(rc, 0, target)
        self.assertEqual(before, set(p.name for p in (REPO / "docs").glob("*")))
        self.assertFalse((REPO / "docs/ai_reports").exists())


if __name__ == "__main__":
    unittest.main()
