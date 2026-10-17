import json
import unittest
from pathlib import Path

import helpers  # noqa: F401  (sys.path)
import extract
from helpers import FIXTURES, REPO, make_root


class TokenizerTests(unittest.TestCase):
    def test_adjacent_strings_and_escapes(self):
        toks = extract.tokenize("x = 'a\\'b' \"c\" 'd\\n' ;")
        strs = [t for t in toks if t.kind == "str"]
        self.assertEqual(len(strs), 1)
        self.assertEqual(strs[0].val, "a'bcd\n")

    def test_comments_skipped_but_urls_in_strings_kept(self):
        toks = extract.tokenize("// c\nx = 'https://a.b/c'; /* y = 'q' */ z")
        self.assertEqual([t.val for t in toks if t.kind == "str"], ["https://a.b/c"])
        self.assertEqual([t.val for t in toks if t.kind == "id"], ["x", "z"])

    def test_interpolation_flagged(self):
        toks = extract.tokenize("'a $b c'")
        self.assertTrue(toks[0].interp)
        self.assertFalse(extract.tokenize("'a \\$b'")[0].interp)


class DartExtractorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.items = extract.extract_dart_text((FIXTURES / "sample_content.dart.txt").read_text(), "cytology")
        cls.by_id = {i["id"]: i for i in cls.items}

    def test_short_ui_labels_dropped_long_notes_kept(self):
        ids = list(self.by_id)
        self.assertNotIn("cytology:SampleL:subtitle", ids)
        self.assertIn("cytology:draftNote", ids)

    def test_ids_unique(self):
        self.assertEqual(len(self.by_id), len(self.items))

    def test_constructor_item_has_three_languages_and_ref(self):
        step = self.items_with_origin("Erkakka")
        self.assertEqual([t["field"] for t in step["texts"]], ["text0", "text1"])
        body = step["texts"][1]
        self.assertTrue(body["uz"].startswith("Erkakka namuna"))
        self.assertIn("it's the same information", body["en"])
        self.assertEqual(len(step["refs"]), 1)
        ref = step["refs"][0]
        self.assertEqual(ref["source_id"], "sample-who-2021")
        self.assertEqual(ref["locator"], "Table 8.3, p. 213")
        self.assertIn("Geneva: WHO; 2021", ref["citation"])  # qo'shni satrlar birlashgan
        self.assertEqual(ref["url"], "https://example.org/who")

    def test_inline_calcref_resolved(self):
        step = self.items_with_origin("Eyakulyat kamida")
        self.assertEqual([(r["source_id"], r["locator"]) for r in step["refs"]], [("sample-atlas", "Ch. 5")])

    def test_map_entry_label_and_second_language_text(self):
        it = self.by_id["cytology:sampleGrades:rapid"]
        self.assertIn("≥ 25 µm/s", it["texts"][0]["en"])

    def test_string_with_double_slash_is_not_a_comment(self):
        it = self.by_id["cytology:sampleQuiz:sample-q-limit"]
        self.assertIn("https://example.org/limit", it["texts"][0]["en"])
        self.assertEqual(len(it["texts"]), 2)  # sharh ichidagi `_T({'uz': 'x'})` hisobga olinmagan

    def test_templated_text_flagged(self):
        it = self.by_id["cytology:SampleL:templated"] if "cytology:SampleL:templated" in self.by_id else self.by_id["cytology:templated"]
        self.assertTrue(it["texts"][0].get("templated"))

    def test_origin_has_file_and_line(self):
        for it in self.items:
            self.assertRegex(it["origin"], r"^test\.dart:\d+$")

    def items_with_origin(self, uz_prefix):
        for it in self.items:
            if any(t["uz"].startswith(uz_prefix) for t in it["texts"]):
                return it
        raise AssertionError(uz_prefix)


class PackExtractorTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pack = json.loads((FIXTURES / "sample_pack.json").read_text())
        cls.out = extract.pack_items(cls.pack)

    def test_counts(self):
        self.assertEqual([len(self.out[k]) for k in ("analytes", "conditions", "quiz")], [2, 1, 1])

    def test_analyte_claims_with_source_metadata_and_no_synonyms(self):
        alt = self.out["analytes"][0]
        self.assertEqual(alt["id"], "analyte:alt")
        self.assertEqual(alt["group"], "liver")
        c0 = alt["texts"][0]
        self.assertEqual(c0["field"], "claim[0]:purpose")
        self.assertEqual(c0["refs"][0]["source"]["title"], "Sample ALT page")
        self.assertNotIn("reuse_rights", c0["refs"][0]["source"])
        self.assertEqual(alt["facts"]["decision_limits"][0]["high"], 56)
        self.assertNotIn("synonyms", json.dumps(alt))
        self.assertNotIn("reference_intervals", alt["facts"])  # bo'sh ro'yxat tashlanadi

    def test_library_not_exported(self):
        blob = json.dumps(self.out, ensure_ascii=False)
        self.assertNotIn("Not to be sent", blob)

    def test_condition_texts_found_recursively(self):
        c = self.out["conditions"][0]
        self.assertEqual(c["id"], "condition:cond-1")
        self.assertEqual(c["texts"][0]["field"], "summary.text")
        self.assertEqual(c["refs"][0]["source_id"], "src-1")

    def test_quiz_item_flattened(self):
        q = self.out["quiz"][0]
        fields = [t["field"] for t in q["texts"]]
        self.assertIn("prompt", fields)
        self.assertIn("options[0].text", fields)


class LoadAllTests(unittest.TestCase):
    def test_load_from_synthetic_root(self):
        tmp, root = make_root()
        self.addCleanup(tmp.cleanup)
        loaded = extract.load_all(root)
        self.assertEqual(set(loaded), set(extract.ALL_DOMAINS))
        self.assertTrue(all(i["id"].startswith("spermogram:") for i in loaded["spermogram"]))

    def test_real_repo_smoke(self):
        """Haqiqiy repo fayllari ajratiladi (yozilmaydi) - tuzilma o'zgarsa shu test sinadi."""
        if not (REPO / extract.PACK_REL).exists():
            self.skipTest("repo tashqarisida")
        loaded = extract.load_all(REPO)
        for dom in ("cytology", "spermogram", "bloodgroup"):
            self.assertGreater(len(loaded[dom]), 20, dom)
            for it in loaded[dom]:
                for t in it["texts"]:
                    self.assertTrue(all(t[l].strip() for l in extract.LANGS))
        self.assertGreater(len(loaded["analytes"]), 50)


if __name__ == "__main__":
    unittest.main()
