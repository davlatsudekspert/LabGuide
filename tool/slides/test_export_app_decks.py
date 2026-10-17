"""Ilova decklari eksportining invariantlari (export_app_decks.py).

  python3 -m unittest discover -s tool/slides -p 'test_*.py'

Tekshiriladi: repodagi assets/lectures/decks va index_v2.json generator bilan
mos (dolzarb); har deck JSON'i ilova sxemasida; oxirgi slayd — "Adabiyotlar" va
u PPTX bilan bir xil bibliografiya; har kontent slaydida manba qatori; rasmlar
repoda bor; id'lar indeks bilan mos; hajm byudjeti.
"""
import json
import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import deck_content as dc  # noqa: E402
import export_app_decks as ex  # noqa: E402
import practice_decks as pd  # noqa: E402

REPO = dc.REPO
TEMPLATES = {'title', 'bullets', 'table', 'figure', 'qa',
             'stats', 'range', 'steps', 'split', 'tree', 'example'}
# Hajm byudjeti: 13 MiB. 12 MiB edi; vizual shablonlar (raqam kartalari, chegaralar
# diagrammasi, ikki ustun, qadamlar, litsenziyali atlas fotolari va ularning manbalari,
# sarlavha/yon rasm kreditlari, bo'lim kategoriyalari) ~0.5 MB qo'shdi (2026-10-17).
SIZE_BUDGET = 13 * 1024 * 1024
_cache = {}


def built():
    if 'b' not in _cache:
        repo = dc.Repo()
        files, index = ex.build_all(repo)
        _cache['b'] = (repo, files, index)
    return _cache['b']


class Fresh(unittest.TestCase):
    def test_files_match_generator(self):
        _, files, index = built()
        stale = ex.write_all(files, index, check=True)
        self.assertEqual(stale, [], 'eskirgan: python3 tool/slides/export_app_decks.py')

    def test_size_budget(self):
        _, files, index = built()
        total = sum(len(ex.dumps(j).encode()) for j in files.values()) + len(ex.dumps(index).encode())
        self.assertLess(total, SIZE_BUDGET)


class Index(unittest.TestCase):
    def test_ids_and_counts(self):
        repo, files, index = built()
        decks = index['decks']
        ids = [d['id'] for d in decks]
        self.assertEqual(len(ids), len(set(ids)))
        days = [d for d in decks if d['kind'] == 'day']
        protos = [d for d in decks if d['kind'] == 'protocol']
        self.assertEqual(len(protos), len(pd.protocols(repo)))
        # PPTX generatori deck beradigan kunlar
        want_days = [day.id for day in repo.days.values() if dc.build_deck(repo, day, 'uz')[0]]
        self.assertEqual([d['id'] for d in days], want_days)
        for d in days:
            self.assertIn(d['m'], range(1, 10))
            self.assertTrue(d['topics'])
        for d in decks:
            self.assertEqual(set(d['t']), set(d['l']), d['id'])
            self.assertEqual(set(d['n']), set(d['l']), d['id'])
            self.assertEqual(set(d['st']), set(d['l']), d['id'])
            self.assertTrue(d['kw'], d['id'])
            self.assertEqual(d['kw'], ex.keyword_blob(d['kw'].split(' | ')), d['id'])
        self.assertEqual([m['n'] for m in index['modules']], list(range(1, 10)))

    def test_normalize_matches_dart(self):
        # lib/features/content/analyte_search.dart normalizeForSearch bilan bir xil natija
        n = ex.normalize_for_search
        self.assertEqual(n("O‘zbekiston, o'zbek—ʻʼ"), 'ozbekiston ozbek')
        self.assertEqual(n('  Ёлка  (Тест) / A-B  '), 'елка тест a b')
        self.assertEqual(n('Qon: 3.5-5.1 mmol/L'), 'qon 3 5 5 1 mmol l')

    def test_every_file_in_index(self):
        _, files, index = built()
        want = set()
        for d in index['decks']:
            for lg in d['l']:
                if lg in d.get('f', {}):
                    self.assertTrue(os.path.exists(os.path.join(REPO, d['f'][lg])), d['id'])
                else:
                    self.assertIn((d['id'], lg), files)
                    want.add((d['id'], lg))
        self.assertEqual(want, set(files))
        self.assertEqual(index['decks'][0]['id'], 'd001')
        self.assertEqual(index['decks'][0]['l'], ['uz'])


class Decks(unittest.TestCase):
    def test_schema_and_sources_last(self):
        repo, files, index = built()
        by_id = {d['id']: d for d in index['decks']}
        sources_title = {lg: dc.T('sources', lg) for lg in dc.LANGS}
        for (did, lg), j in files.items():
            why = f'{did}.{lg}'
            e = by_id[did]
            self.assertEqual(j['id'], did, why)
            self.assertEqual(j['lang'], lg, why)
            self.assertEqual(j['schema'], ex.SCHEMA, why)
            self.assertEqual(j['title'], e['t'][lg], why)
            self.assertEqual(len(j['slides']), e['n'][lg], why)
            srcs = j.get('srcs', [])
            sl = j['slides']
            self.assertEqual(sl[0]['template'], 'title', why)
            self.assertEqual(sl[-1]['title'], sources_title[lg], why)
            self.assertTrue(sl[-1]['bullets'], why)
            for i, s in enumerate(sl):
                w = f'{why}#{i}'
                self.assertTrue(s['title'].strip(), w)
                t = s.get('template', 'bullets')
                self.assertIn(t, TEMPLATES, w)
                if 'src' in s:
                    self.assertLess(s['src'], len(srcs), w)
                if t == 'table':
                    cols = len(s['header']) if s.get('header') else len(s['rows'][0])
                    self.assertTrue(all(len(r) == cols for r in s['rows']), w)
                elif t == 'figure':
                    self.assertTrue(os.path.exists(os.path.join(REPO, s['figure'])), w)
                    self.assertTrue(s.get('caption') or s.get('credit'), w)
                elif t == 'qa':
                    self.assertGreaterEqual(len(s['options']), 2, w)
                    self.assertIn(s['correct'], range(len(s['options'])), w)
                elif t in ('bullets', 'steps', 'tree'):
                    self.assertTrue(s.get('bullets'), w)
                elif t == 'stats':
                    self.assertTrue(s.get('bullets'), w)
                    self.assertTrue(2 <= len(s['stats']) <= 4, w)
                elif t == 'range':
                    self.assertTrue(s['range']['rows'], w)
                elif t == 'split':
                    self.assertEqual(len(s['cols']), 2, w)
                    self.assertTrue(s['cols'][0][2] or s['cols'][1][2], w)
                elif t == 'example':
                    self.assertTrue(s.get('ex'), w)
                if s.get('figure') and t != 'figure':
                    # sarlavha/yon rasm — har doim krediti (sxema yoki foto muallifi) bilan
                    self.assertTrue(s.get('credit'), w)
                # reja/adabiyotlar/sarlavhadan boshqa hamma slaydda manba qatori
                generic = i == 0 or s['title'] in ex.generic_titles(lg)
                if not generic:
                    self.assertIn('src', s, w)
                    self.assertTrue(srcs[s['src']].strip(), w)
            for s in srcs:
                self.assertLessEqual(len(s), 500, why)

    def test_same_bibliography_as_pptx(self):
        """"Adabiyotlar" slaydi PPTX generatoridagi bibliografiya bilan aynan bir xil."""
        repo, files, index = built()
        for did, lg in [('d012', 'uz'), ('d045', 'ru'), ('d007', 'en'), ('kapillyar-qon-olish', 'uz'),
                        ('siydik-chokmasi-mikroskopiya', 'ru')]:
            if did.startswith('d'):
                day = repo.days[int(did[1:])]
                deck, _ = dc.build_deck(repo, day, lg)
            else:
                deck, _ = pd.build_practice_deck(repo, pd.find(repo, did), lg)
            want = [src for src in deck.slides[-1].data['items']]
            got = []
            for s in files[(did, lg)]['slides']:
                if s['title'] == dc.T('sources', lg):
                    got += [re.sub(r'^\d+\. ', '', b) for b in s['bullets']]
            self.assertEqual(got, want, f'{did}.{lg}')

    def test_slide_content_parity_with_pptx_specs(self):
        """Har PPTX kontent slaydi ilovada ham bor: sarlavhalar to'plami mos,
        savol-javoblar soni teng, rasmlar to'plami teng (faqat repodagi assetlar)."""
        repo, files, index = built()
        for did in ('d012', 'd027', 'd045', 'd013'):
            for lg in dc.LANGS:
                deck, _ = dc.build_deck(repo, repo.days[int(did[1:])], lg)
                app = files[(did, lg)]['slides']
                # og'zaki savol slaydida sarlavha — savolning o'zi (javob rejasi bandlarda)
                spec_titles = {s.data.get('lead') or s.title for s in deck.slides
                               if s.kind not in ('qa_q', 'qa_a')}
                app_titles = {s['title'] for s in app}
                self.assertEqual(spec_titles - app_titles, set(), f'{did}.{lg} yetishmaydi')
                self.assertEqual(sum(1 for s in app if s.get('template') == 'qa'),
                                 sum(1 for s in deck.slides if s.kind == 'qa_a'), f'{did}.{lg}')
                imgs = set()
                for s in deck.slides:
                    if s.image:
                        imgs.add(s.image)
                    if s.kind == 'pair':
                        imgs |= {s.data['a']['image'], s.data['b']['image']}
                    if s.kind == 'gallery':
                        imgs |= {i['image'] for i in s.data['items']}
                # PPTX rasmlari ilovada ham bor; ilovada qo'shimcha — faqat sarlavha/yon rasm
                # (data/slide_images.json xaritasidan yoki shu deckning o'z rasmlaridan)
                app_figs = {s['figure'] for s in app if s.get('template') == 'figure'}
                self.assertEqual(app_figs, imgs, f'{did}.{lg}')
                mapped = {r['image'] for r in repo.images['rules']}
                extra = {s['figure'] for s in app if s.get('figure') and s.get('template') != 'figure'}
                self.assertEqual(extra - mapped - imgs, set(), f'{did}.{lg}')

    def test_slide_refs_point_into_bibliography(self):
        """Har kontent slaydida to'liq manbalar (`ref` -> deck `refs`): "Adabiyotlar"
        ro'yxatidagi raqam + shu slayd bo'lim/sahifalari. Ilova manba oynasi shu."""
        _, files, _ = built()
        for (did, lg), j in files.items():
            bib = [b for s in j['slides'] if s.get('compact') for b in s['bullets']]
            refs = j.get('refs', [])
            used = set()
            for i, s in enumerate(j['slides']):
                w = f'{did}.{lg}#{i}'
                if 'src' in s:
                    self.assertIn('ref', s, w)
                if 'ref' in s:
                    used.add(s['ref'])
                    rl = refs[s['ref']]
                    self.assertTrue(rl, w)
                    for row in rl:
                        self.assertIn(row[0], range(len(bib)), w)
                        self.assertTrue(all(isinstance(x, str) and x.strip() for x in row[1:]), w)
            self.assertEqual(used, set(range(len(refs))), f'{did}.{lg}: ishlatilmagan refs')

    def test_figures_exist_and_declared_in_pubspec(self):
        """Har rasm (figure va d001 slayd rasmlari) repoda bor va pubspec.yaml assets
        ro'yxatidagi papkada (aks holda ilovada bo'sh joy chiqadi)."""
        _, files, _ = built()
        with open(os.path.join(REPO, 'pubspec.yaml'), encoding='utf-8') as f:
            declared = set(re.findall(r'^\s+- (assets/\S+/)\s*$', f.read(), re.M))
        paths = {s['figure'] for j in files.values() for s in j['slides'] if s.get('figure')}
        with open(os.path.join(REPO, 'assets', 'lectures', 'd001.json'), encoding='utf-8') as f:
            paths |= {s['image'] for s in json.load(f)['slides'] if s.get('image')}
        self.assertTrue(paths)
        for p in sorted(paths):
            self.assertTrue(os.path.exists(os.path.join(REPO, p)), p)
            self.assertIn(os.path.dirname(p) + '/', declared, p)


class Visuals(unittest.TestCase):
    """Vizual shablonlar: hech qanday son yoki matn o'ylab topilmaydi."""

    def _all(self):
        _, files, _ = built()
        for (did, lg), j in files.items():
            for i, s in enumerate(j['slides']):
                yield did, lg, j, i, s

    def test_every_stats_number_is_in_the_slide_text(self):
        """Raqam kartasidagi qiymat ham, yorliq ham — shu slayd bandlarining so'zma-so'z
        bo'lagi; kartadagi har son matnda bor."""
        n = 0
        for did, lg, j, i, s in self._all():
            if s.get('template') != 'stats':
                continue
            w = f'{did}.{lg}#{i}'
            text = '\n'.join(s['bullets'])
            for value, label in s['stats']:
                n += 1
                self.assertIn(value, text, w)
                self.assertIn(label, text, w)
                for num in re.findall(r'\d+(?:[.,]\d+)?', value):
                    self.assertIn(num, text, w)
        self.assertGreater(n, 100)

    def test_every_range_number_is_in_the_cited_card(self):
        """Chegaralar diagrammasidagi har son, birlik va yorliq — slayd keltirgan analit
        kartasining (pack.json decision_limits) o'zida; manba — kartaning manbasi."""
        repo, files, _ = built()
        by_name = {}
        for a in repo.pack['analytes']:
            for lg in dc.LANGS:
                by_name[(dc.L(a['names'], lg), lg)] = a
        n = 0
        for did, lg, j, i, s in self._all():
            if s.get('template') != 'range':
                continue
            w = f'{did}.{lg}#{i}'
            a = by_name[(s['title'], lg)]
            lims = a['decision_limits']
            nums = {x for x in lims for x in (x.get('low'), x.get('high')) if x is not None}
            texts = {dc.num(v, lg) for v in nums}
            labels = {dc.L(x['label'], lg) for x in lims} | {dc.L(x.get('population'), lg) for x in lims}
            units = {x.get('unit') for x in lims}
            r = s['range']
            self.assertIn(r['u'], units, w)
            if r.get('cap'):
                self.assertIn(r['cap'], labels, w)
            for lab, sub, lo, hi, flags, lo_t, hi_t in r['rows']:
                n += 1
                self.assertIn(lab, labels, w)
                if sub:
                    self.assertIn(sub, labels, w)
                for v, t in ((lo, lo_t), (hi, hi_t)):
                    self.assertEqual(v is None, t is None, w)
                    if v is not None:
                        self.assertIn(v, nums, w)
                        self.assertIn(t, texts, w)
            # manba: jadval slaydi bilan bir xil (kartaning manbalari)
            nxt = next(x for x in j['slides'][i + 1:] if x.get('template') == 'table')
            self.assertEqual(nxt['title'], s['title'], w)
            self.assertEqual(nxt.get('src'), s.get('src'), w)
        self.assertGreater(n, 20)

    def test_steps_are_numbered_and_at_most_six(self):
        n = 0
        for did, lg, j, i, s in self._all():
            if s.get('template') != 'steps':
                continue
            w = f'{did}.{lg}#{i}'
            nums = [int(re.match(r'^(\d{1,2})\.\s', b).group(1)) for b in s['bullets']]
            self.assertLessEqual(len(nums), 6, w)
            self.assertEqual(nums, list(range(nums[0], nums[0] + len(nums))), w)
            n += 1
        self.assertGreater(n, 30)

    def test_split_and_tree_keep_source_text(self):
        """Ikki ustun bandlari — PPTX "Oshishi: …" bandlarining matni (yorliqsiz), daraxt —
        "Yorliq: matn" bandlari; hech biri bo'sh emas."""
        repo, files, _ = built()
        heads = {lg: {dc.T(k, lg) for k in ('high', 'low', 'positive', 'negative')} for lg in dc.LANGS}
        kinds = {'up', 'down', 'pos', 'neg'}
        for did, lg, j, i, s in self._all():
            w = f'{did}.{lg}#{i}'
            if s.get('template') == 'split':
                for head, kind, items in s['cols']:
                    self.assertIn(head, heads[lg], w)
                    self.assertIn(kind, kinds, w)
                    self.assertTrue(all(x.strip() for x in items), w)
            if s.get('template') == 'tree':
                self.assertTrue(3 <= len(s['bullets']) <= 6, w)
                for b in s['bullets']:
                    self.assertRegex(b, r'^[^:.;!?\n]{2,48}: .+', w)

    def test_examples_come_from_sources(self):
        """Misol kartasi matni manbadagi formulaning o'zidan (manual_calc_info.dart) yoki
        protokol bandidan; manbasi bor."""
        repo, files, _ = built()
        allowed = set()
        for ci in repo.app['manualCalcInfo'].values():
            for f in ci['formula']:
                for lg in dc.LANGS:
                    allowed.add(f[lg])
        n = 0
        for did, lg, j, i, s in self._all():
            if s.get('template') != 'example':
                continue
            w = f'{did}.{lg}#{i}'
            self.assertIn('src', s, w)
            ok = any(s['ex'] in a for a in allowed) or did in {p['id'] for p in pd.protocols(repo)}
            self.assertTrue(ok, w)
            n += 1
        self.assertGreater(n, 5)

    def test_side_images_once_per_deck_and_mapped(self):
        """Yon rasm — faqat xaritadagi rasm, deckda bir marta, kredit bilan; mavzuga mos
        (xarita qoidasi: deck id, analit guruhi yoki Jadval)."""
        repo, files, _ = built()
        rules = {r['image']: r for r in repo.images['rules']}
        for (did, lg), j in files.items():
            seen = []
            for i, s in enumerate(j['slides'][1:], 1):
                if s.get('figure') and s.get('template', 'bullets') == 'bullets':
                    w = f'{did}.{lg}#{i}'
                    r = rules[s['figure']]
                    seen.append(s['figure'])
                    self.assertEqual(s['credit'], dc.T(r['credit'], lg), w)
            self.assertEqual(len(seen), len(set(seen)), f'{did}.{lg}')
        for r in repo.images['rules']:
            self.assertTrue(os.path.exists(os.path.join(REPO, r['image'])), r['id'])
            self.assertIn(r['credit'], dc.UI, r['id'])

    def test_categories_align_with_eyebrows(self):
        _, files, _ = built()
        for (did, lg), j in files.items():
            heads = ex.eyebrow_heads(j['slides'])
            self.assertEqual(len(j.get('cats', [])), len(heads), f'{did}.{lg}')

    def test_new_templates_fit(self):
        """Vizual shablonlar byudjetga sig'adi: stats — kartalar qatori + bandlar MIN_FONT da,
        steps — PACK_FONT da, split — SPLIT_FONT da, tree — TREE_FONT da; yon rasmli
        bandlar — tor ustunda MIN_FONT da."""
        misfit = []
        for did, lg, j, i, s in self._all():
            t = s.get('template', 'bullets')
            srcs = j.get('srcs', [])
            src = srcs[s['src']] if 'src' in s else None
            box = ex.body_box(s['title'], lg, src)
            w = f'{did}.{lg}#{i} {t}'
            if t == 'stats':
                h = ex.items_height(s['bullets'], ex.MIN_FONT, ex.CONTENT_W - ex.BULLET_INDENT, lg) + ex.STAT_ROW
            elif t == 'steps':
                h = ex.steps_height(s['bullets'], lg)
            elif t == 'split':
                h = ex.split_height(s['cols'][0][2], s['cols'][1][2], s.get('bullets', []), lg)
            elif t == 'tree':
                h = ex.tree_height(s['bullets'], lg)
            elif t == 'bullets' and s.get('figure') and i > 0:
                h = 0 if ex.side_fits(s['bullets'], s['title'], lg, src) else box + 1
            else:
                continue
            if h > box:
                one = len(s.get('bullets', [])) == 1 and len(ex.sentences(s['bullets'][0])) == 1
                if not one:
                    misfit.append(w)
        self.assertEqual(misfit, [])

    def test_photo_galleries_have_licence_and_source(self):
        """Litsenziyali atlas fotolari (bloodmorph, histology): kredit — muallif va litsenziya,
        manba — Wikimedia Commons fayl sahifasi ("Adabiyotlar"da)."""
        _, files, _ = built()
        n = 0
        for did, lg, j, i, s in self._all():
            f = s.get('figure') or ''
            if s.get('template') == 'figure' and ('/bloodmorph/img/' in f or '/histology/img/' in f):
                n += 1
                w = f'{did}.{lg}#{i}'
                self.assertRegex(s['credit'], r'CC|Public', w)
                self.assertIn('Wikimedia Commons', s['credit'], w)
                self.assertIn('src', s, w)
        self.assertGreater(n, 20)


class Canvas16x9(unittest.TestCase):
    """16:9 kanvas byudjeti (1280×720, asosiy matn ≥ MIN_FONT px)."""

    EGFR = ('eGFR sistatin C bo‘yicha ham hisoblanishi mumkin — bu ko‘plab hujayralar ishlab '
            'chiqaradigan oqsil bo‘lib, uning darajasiga mushak hajmi, yosh va ovqatlanish ta’sir '
            'qilmaydi. NIDDK ma’lumotiga ko‘ra, kreatinin va sistatin C ni birga qo‘llash afzal va '
            'faqat kreatinindan aniqroq, ayniqsa eGFR muhim qaror chegarasiga yaqin bo‘lganda '
            '(masalan, dori dozasini belgilash yoki buyrak transplantatsiyasiga baholash).')

    def test_sentences_round_trip_and_abbreviations(self):
        s = ex.sentences(self.EGFR)
        self.assertEqual(len(s), 2)
        self.assertEqual(' '.join(s), self.EGFR)
        self.assertEqual(ex.sentences('Masalan, e.g. Glukoza. Keyin A. Smith yozgan. 3.5 mmol/L. Tamom'),
                         ['Masalan, e.g. Glukoza.', 'Keyin A. Smith yozgan.', '3.5 mmol/L.', 'Tamom'])
        self.assertEqual(ex.sentences('Без деления, т.е. Норма.'), ['Без деления, т.е. Норма.'])
        self.assertEqual(ex.sentences('kichik harf. davom etadi'), ['kichik harf. davom etadi'])

    def test_paginate_splits_only_at_sentence_end(self):
        # tor byudjet: bitta jumla sig'adi, ikkitasi emas
        one = len(ex.sentences(self.EGFR)[1]) + 5
        pages = ex.paginate(['Qisqa band.', self.EGFR, 'Oxirgi.'],
                            lambda xs: sum(len(x) for x in xs) <= one)
        flat = [x for pg in pages for x in pg]
        self.assertEqual(' '.join(flat), ' '.join(['Qisqa band.', self.EGFR, 'Oxirgi.']))
        for x in flat:
            self.assertRegex(x, r'[.!?…)]$')
        # bitta jumla ham sig'masa — kesilmaydi, butunligicha qoladi
        ex.WARNINGS.clear()
        pages = ex.paginate(['Bir jumla juda uzun.'], lambda xs: False)
        self.assertEqual(pages, [['Bir jumla juda uzun.']])
        self.assertTrue(ex.WARNINGS)

    def test_every_bullet_slide_fits_at_min_font(self):
        """Bandli slaydlar MIN_FONT (26 px) da 16:9 kanvasga sig'adi; sig'maydigani faqat
        bo'linmaydigan bitta jumla (ilova o'zi kichraytiradi)."""
        _, files, _ = built()
        misfit = []
        for (did, lg), j in files.items():
            srcs = j.get('srcs', [])
            for i, s in enumerate(j['slides']):
                if s.get('template', 'bullets') != 'bullets' or s.get('compact'):
                    continue
                src = srcs[s['src']] if 'src' in s else None
                indent = ex.PLAN_INDENT if s.get('plan') else ex.BULLET_INDENT
                h = ex.items_height(s['bullets'], ex.MIN_FONT, ex.CONTENT_W - indent, lg)
                if h > ex.body_box(s['title'], lg, src):
                    one = len(s['bullets']) == 1 and len(ex.sentences(s['bullets'][0])) == 1
                    if not one:
                        misfit.append(f'{did}.{lg}#{i}')
        self.assertEqual(misfit, [])

    def test_continuations_keep_sources_and_numbering(self):
        """Davom slaydlari: eyebrow 'k/n' ketma-ket, manba (src/ref) har qismida bir xil."""
        _, files, _ = built()
        for (did, lg), j in files.items():
            sl = j['slides']
            for i, s in enumerate(sl):
                m = re.search(r'(?:^| · )(\d+)/(\d+)$', s.get('eyebrow') or '')
                if not m or m.group(1) != '1':
                    continue
                n = int(m.group(2))
                group = sl[i:i + n]
                self.assertEqual(len(group), n, f'{did}.{lg}#{i}')
                base = s['eyebrow'][:m.start()]
                for k, g in enumerate(group, 1):
                    w = f'{did}.{lg}#{i + k - 1}'
                    self.assertEqual(g['title'], s['title'], w)
                    self.assertEqual(g.get('eyebrow'), ex.eyebrow_with_page(base, k, n) if base
                                     else f'{k}/{n}', w)
                    self.assertEqual(g.get('src'), s.get('src'), w)
                    self.assertEqual(g.get('ref'), s.get('ref'), w)

    def test_authored_d001_untouched(self):
        with open(os.path.join(REPO, 'assets', 'lectures', 'd001.json'), encoding='utf-8') as f:
            j = json.load(f)
        self.assertEqual(len(j['slides']), 30)
        self.assertEqual(j['lang'], 'uz')


if __name__ == '__main__':
    unittest.main()
