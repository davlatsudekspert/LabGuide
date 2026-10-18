"""Qorovul (guard) testlari: D-55 — AI vazifalari faqat qo'lda, faqat taklif.

    python -m unittest discover -s tool/ai/tests

Oflayn (SDK va kalitsiz). Jadval: docs/GUARDS.md.
"""
import re
import unittest

import helpers

import budget
import run_task

WF = helpers.REPO / ".github/workflows/ai_tasks.yml"


class D55Guards(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text = WF.read_text(encoding="utf-8")
        cls.on = re.search(r"^on:\n(.*?)^\S", cls.text, re.S | re.M).group(1)

    def test_only_manual_trigger(self):
        triggers = re.findall(r"^  ([a-z_]+):", self.on, re.M)
        self.assertEqual(triggers, ["workflow_dispatch"])
        for bad in ("pull_request", "pull_request_target", "push:", "schedule"):
            self.assertNotIn(bad, self.on)

    def test_dry_run_default_true(self):
        m = re.search(r"dry_run:\n(?:\s+\w+:.*\n)*?\s+default: (\w+)", self.on)
        self.assertIsNotNone(m)
        self.assertEqual(m.group(1), "true")

    def test_budget_caps(self):
        self.assertEqual(budget.MAX_BUDGET_USD, 10.0)
        self.assertEqual(run_task.DEFAULT_BUDGET_USD, 3.0)

    def test_main_branch_only_and_reports_not_to_main(self):
        self.assertIn("if: ${{ github.ref != 'refs/heads/main' }}", self.text)
        publish = re.search(r"^  publish:\n(.*?)(?=^  [a-z_]+:\n|\Z)", self.text, re.S | re.M).group(1)
        self.assertIn("ai-reports", publish)
        self.assertNotIn("ANTHROPIC_API_KEY", publish)
        self.assertIsNone(re.search(r"git push[^\n]*\bmain\b", publish))


if __name__ == "__main__":
    unittest.main()
