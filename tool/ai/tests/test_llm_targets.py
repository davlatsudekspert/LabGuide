import unittest

import helpers  # noqa: F401
import extract
import llm
import schemas
import targets
from helpers import FakeAPIError, FakeClient, make_root, resp

SCHEMA = schemas.CONTENT_REVIEW
OK = {"findings": [], "summary": "nothing"}


def mk(client, **kw):
    sleeps = []
    logs = []
    kw.setdefault("sleep", sleeps.append)
    kw.setdefault("rand", lambda: 0.5)
    m = llm.LLM(client, "claude-sonnet-5-5", log=logs.append, **kw)
    return m, sleeps, logs


class LLMTests(unittest.TestCase):
    def test_request_shape(self):
        c = FakeClient([resp(OK)])
        m, _, _ = mk(c, effort="low")
        r = m.call("SYS", "USER", SCHEMA, 1234)
        self.assertTrue(r.ok)
        kw = c.calls[0]
        self.assertEqual(kw["model"], "claude-sonnet-5-5")
        self.assertEqual(kw["max_tokens"], 1234)
        self.assertEqual(kw["system"], "SYS")
        self.assertEqual(kw["messages"], [{"role": "user", "content": "USER"}])
        self.assertEqual(kw["output_config"]["format"], {"type": "json_schema", "schema": SCHEMA})
        self.assertEqual(kw["output_config"]["effort"], "low")
        for forbidden in ("tool_choice", "thinking", "temperature", "top_p", "top_k"):
            self.assertNotIn(forbidden, kw)

    def test_retry_with_exponential_backoff_then_success(self):
        c = FakeClient([FakeAPIError(429), FakeAPIError(529), FakeAPIError(500), resp(OK)])
        m, sleeps, _ = mk(c)
        r = m.call("s", "u", SCHEMA, 100)
        self.assertTrue(r.ok)
        self.assertEqual(r.attempts, 4)
        self.assertEqual(sleeps, [2.0, 4.0, 8.0])  # rand=0.5 -> jitter 1.0

    def test_retry_after_header_respected_and_capped(self):
        c = FakeClient([FakeAPIError(429, retry_after="7"), FakeAPIError(429, retry_after="999"), resp(OK)])
        m, sleeps, _ = mk(c, max_delay=30)
        self.assertTrue(m.call("s", "u", SCHEMA, 100).ok)
        self.assertEqual(sleeps, [7.0, 30.0])

    def test_gives_up_after_max_attempts(self):
        c = FakeClient([FakeAPIError(500, "down")])
        m, sleeps, _ = mk(c, max_attempts=3)
        r = m.call("s", "u", SCHEMA, 100)
        self.assertFalse(r.ok)
        self.assertEqual(len(c.calls), 3)
        self.assertEqual(len(sleeps), 2)
        self.assertIn("status=500", r.error)

    def test_non_retryable_400_fails_fast_and_is_not_fatal(self):
        c = FakeClient([FakeAPIError(400, "bad schema")])
        m, sleeps, _ = mk(c)
        r = m.call("s", "u", SCHEMA, 100)
        self.assertFalse(r.ok)
        self.assertFalse(r.fatal)
        self.assertEqual(len(c.calls), 1)
        self.assertEqual(sleeps, [])

    def test_auth_error_is_fatal(self):
        for status in (401, 403, 404):
            c = FakeClient([FakeAPIError(status)])
            m, _, _ = mk(c)
            r = m.call("s", "u", SCHEMA, 100)
            self.assertTrue(r.fatal, status)
            self.assertEqual(len(c.calls), 1)

    def test_connection_errors_retried_by_class_name(self):
        class APIConnectionError(Exception):
            pass

        c = FakeClient([APIConnectionError("net"), resp(OK)])
        m, sleeps, _ = mk(c)
        self.assertTrue(m.call("s", "u", SCHEMA, 100).ok)
        self.assertEqual(len(sleeps), 1)

    def test_usage_counted_even_for_unusable_replies(self):
        cases = {
            "max_tokens": resp(text='{"findings": [', stop="max_tokens", tin=111, tout=222),
            "refusal": resp(text="", stop="refusal", tin=111, tout=5),
            "not json": resp(text="hello", tin=111, tout=7),
            "not object": resp(text="[1]", tin=111, tout=7),
        }
        for name, rp in cases.items():
            m, _, _ = mk(FakeClient([rp]))
            r = m.call("s", "u", SCHEMA, 100)
            self.assertFalse(r.ok, name)
            self.assertEqual(r.in_tokens, 111, name)
            self.assertGreater(r.out_tokens, 0, name)

    def test_secret_never_in_error_or_log(self):
        key = "sk-ant-api03-SECRETSECRETSECRET"
        c = FakeClient([FakeAPIError(500, f"upstream echoed {key} oops"), FakeAPIError(400, f"bad {key}")])
        m, _, logs = mk(c, api_key=key)
        r = m.call("s", "u", SCHEMA, 100)
        self.assertFalse(r.ok)
        blob = (r.error or "") + "\n".join(logs)
        self.assertNotIn("SECRETSECRET", blob)
        self.assertIn("[REDACTED]", r.error)

    def test_redact_pattern_without_known_key(self):
        self.assertNotIn("abcdefgh12345", llm.redact("x sk-ant-abcdefgh12345 y"))

    def test_api_key_from_env(self):
        self.assertIsNone(llm.api_key_from_env({}))
        self.assertIsNone(llm.api_key_from_env({"ANTHROPIC_API_KEY": "  "}))
        self.assertEqual(llm.api_key_from_env({"ANTHROPIC_API_KEY": " k "}), "k")


class TargetTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp, cls.root = make_root()
        cls.loaded = extract.load_all(cls.root)

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    def sel(self, target, task="content_review", n=20):
        return targets.select_items(target, task, self.loaded, n)

    def test_validate_target_rejects_unsafe(self):
        for bad in ("", "a b", "x;rm -rf", "$(id)", "a" * 121, "../etc", "a`b`"):
            with self.assertRaises(targets.TargetError, msg=bad):
                targets.validate_target(bad)
        for good in ("cytology", "analyte:alt", "all-small", "group:liver,cytology", "id:cytology:draftNote"):
            self.assertEqual(targets.validate_target(good), good)

    def test_max_items_hard_cap(self):
        self.assertEqual(targets.clamp_max_items(20), 20)
        self.assertEqual(targets.clamp_max_items("500"), 60)
        self.assertEqual(targets.clamp_max_items(20.0), 20)
        for bad in (0, -3, "x", None):
            with self.assertRaises(targets.TargetError):
                targets.clamp_max_items(bad)

    def test_selectors(self):
        self.assertEqual([i["id"] for i in self.sel("analyte:alt")[0]], ["analyte:alt"])
        self.assertEqual([i["id"] for i in self.sel("alt")[0]], ["analyte:alt"])
        self.assertEqual({i["id"] for i in self.sel("group:liver")[0]}, {"analyte:alt", "analyte:ast"})
        self.assertEqual({i["domain"] for i in self.sel("cytology")[0]}, {"cytology"})
        self.assertEqual([i["id"] for i in self.sel("condition:cond-1")[0]], ["condition:cond-1"])
        self.assertEqual({i["domain"] for i in self.sel("pack")[0]}, {"analytes", "conditions"})
        path_items, _ = self.sel("lib/features/spermogram/spermogram_content.dart")
        self.assertTrue(path_items and all(i["domain"] == "spermogram" for i in path_items))
        self.assertEqual({i["id"] for i in self.sel("analyte:alt,analyte:ast,analyte:alt")[0]}, {"analyte:alt", "analyte:ast"})

    def test_all_small_round_robin_and_cap(self):
        items, notes = self.sel("all-small", n=7)
        self.assertEqual(len(items), 7)
        self.assertGreater(len({i["domain"] for i in items}), 3)
        self.assertTrue(any("max_items" in n for n in notes))

    def test_no_match_is_error(self):
        with self.assertRaises(targets.TargetError):
            self.sel("analyte:nope")
        with self.assertRaises(targets.TargetError):
            self.sel("zzz-nothing")

    def test_task_eligibility_filters_quiz_for_quiz_draft(self):
        items, notes = self.sel("quiz", task="content_review")
        self.assertEqual(len(items), 1)
        with self.assertRaises(targets.TargetError):
            self.sel("quiz", task="quiz_draft")
        items, notes = self.sel("analytes,quiz", task="quiz_draft")
        self.assertTrue(all(i["domain"] != "quiz" for i in items))
        self.assertTrue(notes)

    def test_domains_needed_limits_dart_parsing(self):
        self.assertEqual(targets.domains_needed("analyte:alt"), ("analytes",))
        self.assertEqual(targets.domains_needed("cytology"), ("cytology",))
        self.assertEqual(targets.domains_needed("all-small"), extract.ALL_DOMAINS)


if __name__ == "__main__":
    unittest.main()
