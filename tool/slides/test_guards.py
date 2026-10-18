"""Qorovul (guard) testlari: ma'ruza taqdimotlari eksporti (D-59, D-65).

  python3 -m unittest discover -s tool/slides -p 'test_*.py'

Faqat o'qiydi (hech narsa yozmaydi): eksport byudjeti ilova kanvasi bilan bir
xil (1280×720, asosiy matn ≥ 26 px), har deck fayli `status: sourced`, decklar
soni kamaymaydi. Jadval: docs/GUARDS.md.
"""
import glob
import json
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import export_app_decks as ex  # noqa: E402

REPO = os.path.dirname(os.path.dirname(HERE))

# 2026-10-18 holati — kamaymasligi kerak (ko'payishi mumkin).
MIN_DECK_FILES = 372
MIN_DAY_DECKS = 98
MIN_PROTOCOL_DECKS = 27


class ExportGuards(unittest.TestCase):
    def test_canvas_matches_app(self):
        self.assertEqual((ex.CANVAS_W, ex.CANVAS_H), (1280, 720))
        self.assertGreaterEqual(ex.MIN_FONT, 26)
        dart = open(os.path.join(REPO, 'lib/features/classroom/lecture_canvas.dart'),
                    encoding='utf-8').read()
        self.assertIn('static const double width = 1280;', dart)
        self.assertIn('static const double height = 720;', dart)

    def test_export_writes_sourced_status(self):
        src = open(ex.__file__, encoding='utf-8').read()
        self.assertIn("'status': 'sourced'", src)
        self.assertNotIn("'status': 'draft'", src)

    def test_deck_files_sourced(self):
        files = sorted(glob.glob(os.path.join(ex.DECK_DIR, '*.json')))
        self.assertGreaterEqual(len(files), MIN_DECK_FILES)
        for f in files:
            with open(f, encoding='utf-8') as fh:
                self.assertEqual(json.load(fh).get('status'), 'sourced', f)
            self.assertRegex(os.path.basename(f), r'^[a-z0-9-]+\.(uz|ru|en)\.json$')

    def test_index_counts(self):
        with open(os.path.join(ex.OUT_DIR, 'index_v2.json'), encoding='utf-8') as fh:
            idx = json.load(fh)
        kinds = [d.get('kind') for d in idx['decks']]
        self.assertGreaterEqual(kinds.count('day'), MIN_DAY_DECKS)
        self.assertGreaterEqual(kinds.count('protocol'), MIN_PROTOCOL_DECKS)
        ids = [d['id'] for d in idx['decks']]
        self.assertEqual(len(ids), len(set(ids)))


if __name__ == '__main__':
    unittest.main()
