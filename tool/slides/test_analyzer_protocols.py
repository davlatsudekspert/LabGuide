"""Yarim avtomat analizator slaydlari: har bir son manba parchasida bormi.

  python3 -m unittest discover -s tool/slides -p 'test_*.py'

Qamrov: books_extra_practice.json dagi "analyzer" yorliqli slaydlar (mavjud biokimyo protokollariga
qo'shilgan «Reaktivni tayyorlash (yarim avtomat analizator uchun)» va «... dasturi» slaydlari) hamda
yangi «yarim-avtomat-biokimyo-analizator» protokolining barcha slaydlari.

Tekshiriladi:
  * har slaydda "excerpts" bor, ular data/analyzer_source_excerpts.json da mavjud va slayd manbasi
    (refs) bilan bir kitobga tegishli;
  * slayddagi (uz, ru, en) har bir son shu slayd parchalarining birida uchraydi — to'qib chiqarilgan
    qiymat yo'q (o'nlik vergul/nuqta farqi hisobga olinmaydi);
  * uch tilda sonlar to'plami bir xil (tarjima uz matnga sodiq);
  * reaktiv tayyorlash slaydlarida «to'plam yo'riqnomasi (IFU) ustun» eslatmasi bor;
  * manbada bir-biriga zid qiymatlar ochiq ko'rsatilgan (yashirilmagan).
"""
import json
import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import deck_content as dc  # noqa: E402
import practice_decks as pd  # noqa: E402

GEN_ID = 'yarim-avtomat-biokimyo-analizator'
WITH_ANALYZER = ('alt-kinetik-fotometrik', 'mochevina-ureaza-gldg', 'glyukoza-gox-pod-fotometrik',
                 'bilirubin-umumiy-bogllangan', 'gemoglobin-gemiglobintsianid')
NUM = re.compile(r'\d+(?:[.,]\d+)?')
IFU_MARK = {'uz': 'IFU', 'ru': 'IFU', 'en': 'IFU'}

with open(os.path.join(HERE, 'data', 'analyzer_source_excerpts.json'), encoding='utf-8') as f:
    EXCERPTS = json.load(f)['excerpts']

_repo = None


def repo():
    global _repo
    if _repo is None:
        _repo = dc.Repo()
    return _repo


def nums(text):
    return {float(m.replace(',', '.')) for m in NUM.findall(text)}


def slide_text(sl, lg):
    parts = [dc.L(sl['title'], lg)]
    if sl['type'] == 'text':
        parts += sl['bullets'][lg]
    elif sl['type'] == 'table':
        parts += sl['header'][lg]
        parts += [c for row in sl['rows'][lg] for c in row]
    return '\n'.join(parts)


def checked_slides():
    out = []
    for p in pd.protocols(repo()):
        for n, sl in enumerate(p['slides'], 1):
            if p['id'] == GEN_ID or sl.get('label') == 'analyzer':
                out.append((f'{p["id"]}#{n}', p, sl))
    return out


class AnalyzerSlides(unittest.TestCase):
    def test_scope(self):
        ids = {p['id'] for _, p, _ in checked_slides()}
        self.assertEqual(ids, set(WITH_ANALYZER) | {GEN_ID})
        for pid in WITH_ANALYZER:
            sls = [s for s in pd.find(repo(), pid)['slides'] if s.get('label') == 'analyzer']
            self.assertEqual([s['type'] for s in sls], ['text', 'table'], pid)
            self.assertEqual(sls[0]['title']['uz'], 'Reaktivni tayyorlash (yarim avtomat analizator uchun)')

    def test_excerpts_exist_and_match_refs(self):
        for where, p, sl in checked_slides():
            self.assertTrue(sl.get('excerpts'), where)
            books = {r['book'] for r in sl['refs']}
            for k in sl['excerpts']:
                self.assertIn(k, EXCERPTS, where)
                self.assertIn(EXCERPTS[k]['book'], books, where)
                self.assertGreater(len(EXCERPTS[k]['text']), 200, k)

    def test_every_number_is_in_the_source_excerpt(self):
        for where, p, sl in checked_slides():
            allowed = set()
            for k in sl['excerpts']:
                allowed |= nums(EXCERPTS[k]['text'])
            for lg in dc.LANGS:
                missing = nums(slide_text(sl, lg)) - allowed
                self.assertEqual(missing, set(), f'{where}/{lg}: manbada yo‘q son(lar)')

    def test_numbers_are_the_same_in_three_languages(self):
        for where, p, sl in checked_slides():
            uz = nums(slide_text(sl, 'uz'))
            for lg in ('ru', 'en'):
                self.assertEqual(nums(slide_text(sl, lg)), uz, f'{where}/{lg}')

    def test_prep_slides_say_the_kit_ifu_takes_precedence(self):
        for where, p, sl in checked_slides():
            if sl['type'] == 'text' and sl.get('label') == 'analyzer':
                for lg in dc.LANGS:
                    self.assertTrue(any(IFU_MARK[lg] in b for b in sl['bullets'][lg]), f'{where}/{lg}')

    def test_source_contradictions_are_shown_not_hidden(self):
        def blob(pid, lg='uz'):
            return '\n'.join(slide_text(s, lg) for s in pd.find(repo(), pid)['slides']
                             if s.get('label') == 'analyzer')
        alt = blob('alt-kinetik-fotometrik')
        self.assertIn('5,0 µl', alt)
        self.assertIn('50 µl', alt)
        self.assertIn('mos emas', alt)
        self.assertIn('mos emas', blob('gemoglobin-gemiglobintsianid'))
        self.assertIn('mos emas', blob('bilirubin-umumiy-bogllangan'))
        self.assertIn('o‘qib bo‘lmaydi', blob('glyukoza-gox-pod-fotometrik'))

    def test_generic_protocol_states_what_the_source_lacks(self):
        p = pd.find(repo(), GEN_ID)
        labels = [s['label'] for s in p['slides']]
        for need in ('principle', 'procedure', 'qc', 'errors', 'safety'):
            self.assertIn(need, labels)
        text = '\n'.join(b for s in p['slides'] if s['type'] == 'text' for b in s['bullets']['uz'])
        self.assertIn('berilmagan', text)  # texnik xizmat/yuvish/qizdirish manbada yo'q
        self.assertNotRegex(text, r'BA-88|Mindray')  # manbasiz model nomi yo'q


class AnalyzerIndex(unittest.TestCase):
    def test_index_lists_and_finds_the_new_protocol(self):
        path = os.path.join(HERE, '..', '..', 'assets', 'lectures', 'index_v2.json')
        with open(path, encoding='utf-8') as f:
            idx = json.load(f)
        by = {e['id']: e for e in idx['decks']}
        e = by[GEN_ID]
        self.assertEqual(e['kind'], 'protocol')
        self.assertEqual(e['l'], ['uz', 'ru', 'en'])
        for word in ('analizator', 'анализатор', 'analyser', 'kalibrovka'):
            self.assertIn(word, e['kw'])
        for pid in WITH_ANALYZER:
            self.assertIn('yarim avtomat', by[pid]['kw'], pid)


if __name__ == '__main__':
    unittest.main()
