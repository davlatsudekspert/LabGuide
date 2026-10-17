"""`.github/workflows/ai_tasks.yml` tuzilmasi bo'yicha oflayn tekshiruvlar (YAML kutubxonasisiz, matn bo'yicha).

2026-10-17 jonli ishga tushirishdagi nosozliklar:
  * publish: artifact `incoming/` ga yuklab olingan, keyin `actions/checkout` ish papkasini tozalagan
    ("Deleting the contents of ...") -> "Hisobot yo'q".
  * concurrency: bitta umumiy guruh -> navbatdagi uchinchi dispatch (translate_check) bekor qilindi.
"""
import re
import unittest

import helpers

WF = helpers.REPO / ".github/workflows/ai_tasks.yml"


def job_block(text: str, name: str) -> str:
    m = re.search(rf"^  {name}:\n(.*?)(?=^  [a-z_]+:\n|\Z)", text, re.S | re.M)
    assert m, name
    return m.group(1)


@unittest.skipUnless(WF.exists(), "workflow fayli yo'q")
class WorkflowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text = WF.read_text(encoding="utf-8")
        cls.run_job = job_block(cls.text, "run")
        cls.publish = job_block(cls.text, "publish")

    def test_publish_checks_out_before_downloading_artifact(self):
        i_checkout = self.publish.index("actions/checkout@")
        i_download = self.publish.index("actions/download-artifact@")
        self.assertLess(i_checkout, i_download, "checkout ish papkasini tozalaydi - artifact undan keyin yuklansin")

    def test_publish_downloads_outside_workspace_and_reads_same_dir(self):
        m = re.search(r"actions/download-artifact@[^\n]*\n\s+with:\n(?:\s+\w[\w-]*:.*\n)*?\s+path: (.+)\n", self.publish)
        self.assertIsNotNone(m)
        path = m.group(1).strip()
        self.assertIn("runner.temp", path)
        self.assertIn("AI_INCOMING", self.publish)
        self.assertIn('files=("$AI_INCOMING"/*)', self.publish)
        self.assertNotIn("files=(incoming/*)", self.publish)

    def test_upload_path_matches_run_task_out_dir(self):
        self.assertIn("path: docs/ai_reports/", self.run_job)
        self.assertIn('compgen -G "docs/ai_reports/*.json"', self.run_job)

    def test_concurrency_is_per_task_and_target_and_never_cancels(self):
        m = re.search(r"^concurrency:\n((?:  .*\n)+)", self.text, re.M)
        self.assertIsNotNone(m)
        block = m.group(1)
        self.assertIn("inputs.task", block)
        self.assertIn("inputs.target", block)
        self.assertIn("cancel-in-progress: false", block)

    def test_security_model_kept(self):
        # kalit faqat bitta joyda, `run` ishida
        self.assertEqual(self.text.count("secrets.ANTHROPIC_API_KEY"), 1)
        self.assertIn("secrets.ANTHROPIC_API_KEY", self.run_job)
        self.assertNotIn("ANTHROPIC_API_KEY", self.publish)
        self.assertNotIn("secrets.", self.publish)
        # publish repo kodini ishga tushirmaydi
        self.assertNotRegex(self.publish, r"python|tool/ai")
        # faqat ai-reports tarmog'iga
        self.assertIn("git push origin HEAD:refs/heads/ai-reports", self.publish)
        self.assertNotRegex(self.publish, r"push[^\n]*(main|--force|-f\b)")
        # barcha action'lar SHA bo'yicha
        for ref in re.findall(r"uses:\s*(\S+)", self.text):
            self.assertRegex(ref, r"^[\w.-]+/[\w.-]+@[0-9a-f]{40}$", ref)
        # faqat qo'lda
        self.assertNotRegex(self.text, r"^\s+(pull_request|pull_request_target|push|schedule):", )
        self.assertIn("contents: read", self.run_job)
        self.assertIn("persist-credentials: false", self.run_job)


if __name__ == "__main__":
    unittest.main()
