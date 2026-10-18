"""Ishlab chiqaruvchi yo'riqnomasi (IFU) asosidagi protokollar: har bir son manba parchasida bormi.

  python3 -m unittest discover -s tool/slides -p 'test_*.py'

Qamrov: books_extra_practice.json dagi refs'i `ifu-*` kitobiga ishora qiladigan protokollar (kurs kitoblarida
usuli yo'q 19 ta test: kreatinin, umumiy oqsil, albumin, xolesterin, triglitseridlar, HDL-C, AST, IF, GGT, amilaza,
siydik kislotasi, kalsiy, temir, fosfor, magniy, CRB, RF, ASLO, D vitamini). Manba — ishlab chiqaruvchi o'z saytida
ochiq e'lon qilgan IFU PDF; so'zma-so'z parchalar data/ifu_source_excerpts.json da (URL, hujjat kodi, tahrir sanasi,
sahifa, sha256).

Tekshiriladi:
  * protokollar ro'yxati aynan kutilgan 19 ta (bo'shliq yopilmagan yoki ortiqcha qo'shilmagan);
  * HAR bir slaydda (sarlavha, bandlar, jadval) "excerpts" bor, ular ifu_source_excerpts.json da mavjud va slayd
    refs'idagi IFU kitobiga tegishli;
  * slayddagi (uz, ru, en) har bir son shu slayd parchalarining birida uchraydi (o'nlik vergul/nuqta farqi
    hisobga olinmaydi) — to'qib chiqarilgan qiymat yo'q;
  * uch tilda sonlar to'plami bir xil;
  * bitta protokol faqat BITTA to'plam IFU sidan (ikki to'plam qiymatlari aralashmagan);
  * birinchi slaydda nomlangan ishlab chiqaruvchi IFU siga misol sifatida asoslangani va laboratoriya to'plami
    IFU si ustunligi aytilgan; reaktiv tayyorlash slaydida ham "IFU" eslatmasi bor;
  * fotometrik testlarda «Reaktivni tayyorlash (yarim avtomat analizator uchun)» va analizator dasturi jadvali bor;
  * parcha metama'lumotlari to'liq (URL ishlab chiqaruvchi domenida, hujjat kodi va sanasi matnda uchraydi).
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

PHOTOMETRIC = ('kreatinin-yaffe-kinetik', 'umumiy-oqsil-biuret', 'albumin-bromkrezol-yashil',
               'umumiy-xolesterin-chod-pap', 'triglitseridlar-gpo-pap', 'yzlp-xolesterin-hdl', 'ast-kinetik-ifcc',
               'ishqoriy-fosfataza-kinetik', 'ggt-kinetik', 'alfa-amilaza-cnpg3', 'siydik-kislotasi-urikaza-pap',
               'kalsiy-arsenazo-iii', 'temir-ferrozin', 'fosfor-fosfomolibdat-uv', 'magniy-ksilidil-kok')
LATEX = ('crb-lateks-agglyutinatsiya', 'revmatoid-omil-lateks', 'aslo-lateks')
ELISA = ('d-vitamini-25oh-elisa',)
EXPECTED = set(PHOTOMETRIC + LATEX + ELISA)
DOMAINS = {'spinreact': 'https://www.spinreact.com/', 'immusmol': 'https://immusmol.com/'}
NUM = re.compile(r'\d+(?:[.,]\d+)?')
PREP_TITLE = 'Reaktivni tayyorlash (yarim avtomat analizator uchun)'
PRECEDENCE = {'uz': 'ustun', 'ru': 'приоритет', 'en': 'precedence'}

with open(os.path.join(HERE, 'data', 'ifu_source_excerpts.json'), encoding='utf-8') as f:
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


def ifu_books(p):
    return {r['book'] for sl in p['slides'] for r in sl.get('refs', []) if r.get('book', '').startswith('ifu-')}


def ifu_protocols():
    return [p for p in pd.protocols(repo()) if ifu_books(p)]


class IfuScope(unittest.TestCase):
    def test_exactly_the_19_former_gaps(self):
        self.assertEqual({p['id'] for p in ifu_protocols()}, EXPECTED)

    def test_one_kit_per_protocol(self):
        for p in ifu_protocols():
            self.assertEqual(len(ifu_books(p)), 1, f'{p["id"]}: bir nechta to‘plam IFU si aralashgan')
            docs = {EXCERPTS[k]['doc'] for sl in p['slides'] for k in sl.get('excerpts', [])}
            self.assertEqual(len(docs), 1, p['id'])
            self.assertEqual({'ifu-' + d for d in docs}, ifu_books(p), p['id'])

    def test_books_are_registered(self):
        books = repo().books['books']
        for p in ifu_protocols():
            for b in ifu_books(p):
                self.assertIn(b, books)
                doc = b[len('ifu-'):]
                meta = next(e for e in EXCERPTS.values() if e['doc'] == doc)
                self.assertIn(meta['url'], books[b]['full'], b)


class IfuExcerpts(unittest.TestCase):
    def test_metadata(self):
        for k, e in EXCERPTS.items():
            for field in ('doc', 'doc_code', 'manufacturer', 'kit', 'document', 'revision', 'url', 'page', 'text',
                          'sha256'):
                self.assertTrue(e.get(field), f'{k}.{field}')
            self.assertTrue(any(e['url'].startswith(d) for d in DOMAINS.values()), k)
            self.assertTrue(e['url'].endswith('.pdf'), k)
            # hujjat kodi har sahifada; tahrir sanasi — muqovadan tashqari har sahifada
            self.assertIn(e['doc_code'], e['text'], k)
            if not e.get('cover'):
                self.assertGreater(len(e['text']), 1500, k)
                self.assertIn(e['revision'], e['text'], k)


class IfuSlides(unittest.TestCase):
    def test_every_slide_has_excerpts_matching_refs(self):
        for p in ifu_protocols():
            for n, sl in enumerate(p['slides'], 1):
                where = f'{p["id"]}#{n}'
                self.assertTrue(sl.get('excerpts'), where)
                books = {r['book'] for r in sl['refs']}
                for k in sl['excerpts']:
                    self.assertIn(k, EXCERPTS, where)
                    self.assertIn('ifu-' + EXCERPTS[k]['doc'], books, where)

    def test_every_number_is_in_the_source_excerpt(self):
        for p in ifu_protocols():
            for n, sl in enumerate(p['slides'], 1):
                allowed = set()
                for k in sl['excerpts']:
                    allowed |= nums(EXCERPTS[k]['text'])
                for lg in dc.LANGS:
                    missing = nums(slide_text(sl, lg)) - allowed
                    self.assertEqual(missing, set(), f'{p["id"]}#{n}/{lg}: IFU parchasida yo‘q son(lar)')

    def test_numbers_are_the_same_in_three_languages(self):
        for p in ifu_protocols():
            for n, sl in enumerate(p['slides'], 1):
                uz = nums(slide_text(sl, 'uz'))
                for lg in ('ru', 'en'):
                    self.assertEqual(nums(slide_text(sl, lg)), uz, f'{p["id"]}#{n}/{lg}')

    def test_first_slide_names_the_ifu_and_its_precedence(self):
        for p in ifu_protocols():
            first = p['slides'][0]
            self.assertEqual(first['label'], 'principle', p['id'])
            for lg in dc.LANGS:
                blob = '\n'.join(first['bullets'][lg])
                self.assertIn('IFU', blob, f'{p["id"]}/{lg}')
                self.assertIn(PRECEDENCE[lg], blob, f'{p["id"]}/{lg}')
                kit = 'Immusmol' if p['id'] in ELISA else 'SPINREACT'
                self.assertIn(kit, blob, f'{p["id"]}/{lg}')

    def test_structure(self):
        for p in ifu_protocols():
            labels = [s['label'] for s in p['slides']]
            for need in ('principle', 'materials', 'procedure', 'reading', 'errors', 'qc', 'safety'):
                self.assertIn(need, labels, p['id'])
            if p['id'] in PHOTOMETRIC:
                an = [s for s in p['slides'] if s['label'] == 'analyzer']
                self.assertEqual([s['type'] for s in an], ['text', 'table'], p['id'])
                self.assertEqual(an[0]['title']['uz'], PREP_TITLE)
                for lg in dc.LANGS:
                    self.assertTrue(any('IFU' in b for b in an[0]['bullets'][lg]), f'{p["id"]}/{lg}')
            else:
                # lateks va ELISA — fotometrik analizator testi emas; buni ochiq aytadi
                self.assertNotIn('analyzer', labels, p['id'])
                prep = [s for s in p['slides'] if s['title']['uz'].startswith('Reaktivlarni tayyorlash')]
                self.assertEqual(len(prep), 1, p['id'])
                self.assertIn('analizator', '\n'.join(prep[0]['bullets']['uz']), p['id'])

    def test_source_oddities_are_shown_not_hidden(self):
        def blob(pid):
            return '\n'.join(slide_text(s, 'uz') for s in pd.find(repo(), pid)['slides'])
        hdl = blob('yzlp-xolesterin-hdl')
        self.assertIn('550–650 nm', hdl)
        self.assertIn('570 nm', hdl)
        self.assertIn('«≥150 IU/mL»', blob('aslo-lateks'))  # IFU dagi bolalar qiymati — o'zgartirmasdan, ogohlantirish bilan


class IfuIndex(unittest.TestCase):
    def test_index_lists_the_new_protocols(self):
        path = os.path.join(HERE, '..', '..', 'assets', 'lectures', 'index_v2.json')
        with open(path, encoding='utf-8') as f:
            idx = json.load(f)
        by = {e['id']: e for e in idx['decks']}
        for pid in EXPECTED:
            self.assertIn(pid, by)
            self.assertEqual(by[pid]['kind'], 'protocol')
            self.assertEqual(by[pid]['l'], ['uz', 'ru', 'en'])
        self.assertIn('yarim avtomat', by['kreatinin-yaffe-kinetik']['kw'])
        self.assertIn('elisa', by['d-vitamini-25oh-elisa']['kw'])


if __name__ == '__main__':
    unittest.main()
