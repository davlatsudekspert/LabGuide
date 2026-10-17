"""Amaliy mashg'ulot protokollari to'plamining invariantlari.

  python3 -m unittest discover -s tool/slides -p 'test_*.py'

Tekshiriladi: ma'lumot to'liq (validate), uch tilda, har kontent slaydda manba (muallif + qisqa nom +
bo'lim/sahifa), oxirgi slayd "Adabiyotlar", qoralama yozuvi yo'q, protokollar o'quv kunlariga
BIRIKTIRILMAGAN (id raqamsiz, curriculum kunlari bilan kesishmaydi), render joylashtirish
ogohlantirishlarisiz o'tadi, hisobotda "kunma-kun mavzu yo'q" aytilgan.
"""
import os
import re
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import deck_content as dc  # noqa: E402
import practice_decks as pd  # noqa: E402

try:
    import pptx  # noqa: F401
    import make_topic_decks as mk
    HAVE_PPTX = True
except ImportError:  # pragma: no cover
    HAVE_PPTX = False

_repo = None


def repo():
    global _repo
    if _repo is None:
        _repo = dc.Repo()
    return _repo


class PracticeData(unittest.TestCase):
    def test_validate_is_clean(self):
        self.assertEqual(pd.validate(repo()), [])

    def test_there_is_a_set(self):
        self.assertGreaterEqual(len(pd.protocols(repo())), 20)

    def test_ids_are_unnumbered_and_do_not_collide_with_days(self):
        ids = [p['id'] for p in pd.protocols(repo())]
        self.assertEqual(len(ids), len(set(ids)))
        day_ids = {f'd{n:03d}' for n in repo().days}
        for pid in ids:
            self.assertRegex(pid, r'^[a-z0-9-]+$')
            self.assertNotRegex(pid, r'^d\d{3}')
            self.assertNotIn(pid, day_ids)

    def test_practice_is_kept_out_of_day_topics(self):
        # books_extra topics = faqat kunlar; amaliy protokollar kunga bog'lanmaydi
        ids = {p['id'] for p in pd.protocols(repo())}
        for key in repo().books['topics']:
            self.assertNotIn(key, ids)

    def test_no_draft_text_and_no_day_mapping_in_data(self):
        bad = re.compile(r'qoralama|mutaxassis tekshiruvidan|черновик|draft', re.I)
        for p in pd.protocols(repo()):
            blob = repr(p)
            self.assertIsNone(bad.search(blob), p['id'])
            self.assertIsNone(re.search(r'\bd0\d\d\b|\bd1[0-4]\d\b', blob), f'{p["id"]}: kun raqami tilga olingan')

    def test_every_content_slide_cites_book_and_location(self):
        for p in pd.protocols(repo()):
            for n, sl in enumerate(p['slides'], 1):
                if sl['type'] == 'gallery':
                    continue
                self.assertTrue(sl['refs'], f'{p["id"]}#{n}')
                for r in sl['refs']:
                    for lg in dc.LANGS:
                        self.assertTrue(dc.L(r['loc'], lg).strip(), f'{p["id"]}#{n}/{lg}')

    def test_every_protocol_has_safety_and_sources_cover_the_set(self):
        for p in pd.protocols(repo()):
            labels = [s.get('label') for s in p['slides']]
            self.assertIn('safety', labels, p['id'])
        self.assertGreaterEqual(len(repo().practice['books']), 3)

    def test_report_states_there_is_no_day_mapping(self):
        text = '\n'.join(pd.report_section(repo()))
        self.assertIn('kunma-kun mavzu yoki texnikani ko‘rsatmaydi', text)
        self.assertIn('hech bir kunga biriktirilmagan', text)
        self.assertIn('Manbalarda bor, lekin olinmagan', text)
        self.assertNotIn('qoralama', text.lower())


class PracticeDecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.decks = []
        for p in pd.protocols(repo()):
            for lg in dc.LANGS:
                deck, cov = pd.build_practice_deck(repo(), p, lg)
                assert deck is not None, p['id']
                cls.decks.append(deck)

    def test_structure(self):
        for d in self.decks:
            kinds = [s.kind for s in d.slides]
            self.assertEqual(kinds[0], 'title')
            self.assertEqual(kinds[1], 'outline')
            self.assertEqual(kinds[-1], 'sources')
            self.assertEqual(d.slides[-1].title, dc.T('sources', d.lang))
            self.assertGreaterEqual(len(d.content_slides), 3, d.day.id)

    def test_sources_on_every_content_slide_and_listed(self):
        for d in self.decks:
            used = set()
            for i, s in enumerate(d.slides):
                if s.is_content:
                    self.assertTrue(s.sources, f'{d.day.id}/{d.lang} #{i} "{s.title}": manba yo‘q')
                used |= {r['key'] for r in s.sources}
            self.assertEqual(used - set(d.sources.entries), set())
            listed = d.slides[-1].data['items']
            for key in used:
                self.assertIn(d.sources.bib(key), listed, f'{d.day.id}/{d.lang} {key}')

    def test_books_show_their_locations_on_the_references_slide(self):
        for d in self.decks:
            joined = ' '.join(d.slides[-1].data['items'])
            self.assertRegex(joined, r'\d', d.day.id)

    def test_three_languages_really_differ(self):
        by = {}
        for d in self.decks:
            by.setdefault(d.day.id, {})[d.lang] = d
        for pid, langs in by.items():
            self.assertRegex(langs['ru'].slides[0].title, r'[А-Яа-я]', pid)
            self.assertNotRegex(langs['uz'].slides[0].title, r'[А-Яа-я]', pid)
            self.assertRegex(langs['en'].slides[0].title, r'[A-Za-z]', pid)
            self.assertEqual(len({langs[lg].slides[0].title for lg in dc.LANGS}), 3, pid)

    def test_no_draft_text_in_slides(self):
        bad = re.compile(r'qoralama|mutaxassis tekshiruvidan|черновик|draft', re.I)
        for d in self.decks:
            for s in d.slides:
                self.assertIsNone(bad.search(s.title + str(s.data)), d.day.id)


@unittest.skipUnless(HAVE_PPTX, 'python-pptx kerak')
class PracticeRender(unittest.TestCase):
    def test_all_decks_render_without_layout_warnings(self):
        from pptx import Presentation
        out = tempfile.mkdtemp()
        before = len(mk.WARNINGS)
        refs_title = {lg: dc.T('sources', lg) for lg in dc.LANGS}
        for p in pd.protocols(repo()):
            for lg in dc.LANGS:
                deck, _ = pd.build_practice_deck(repo(), p, lg)
                path = os.path.join(out, lg, f'{p["id"]}.pptx')
                n = mk.render_deck(deck, path)
                prs = Presentation(path)
                slides = list(prs.slides)
                self.assertEqual(len(slides), n)
                self.assertAlmostEqual(prs.slide_width / prs.slide_height, 16 / 9, places=2)
                for i, slide in enumerate(slides, 1):
                    texts = [sh.text_frame.text for sh in slide.shapes if sh.has_text_frame]
                    self.assertIn('LabGuide', texts, f'{p["id"]}/{lg} #{i}')
                    self.assertIn(f'{i} / {n}', texts)
                    self.assertNotIn('qoralama', ' '.join(texts).lower())
                last = [sh.text_frame.text for sh in slides[-1].shapes if sh.has_text_frame]
                self.assertIn(refs_title[lg], last, f'{p["id"]}/{lg}')
        self.assertEqual(mk.WARNINGS[before:], [], 'joylashtirish ogohlantirishlari')


if __name__ == '__main__':
    unittest.main()
