#!/usr/bin/env python3
"""Ilova ichidagi Ma'ruza bo'limi uchun taqdimotlar (JSON) eksporti.

PPTX generatorlari (make_topic_decks.py, make_practice_decks.py) bilan BIR XIL
mazmun: bir xil manbalar, bir xil slaydlar, har kontent slaydida manba qatori,
oxirgi slayd — "Adabiyotlar", rasmlar faqat repodagi mavjud assetlardan. Farqi
faqat chiqish formatida: ilovaning ma'ruza pleyeri (lecture_decks.dart,
lecture_slide.dart) o'qiydigan JSON.

Chiqish:
  assets/lectures/decks/<id>.<til>.json   - har deck, har til (uz/ru/en) alohida
  assets/lectures/index_v2.json           - ixcham indeks + qidiruv matni

Ishga tushirish (kontent o'zgarganda qayta):
  python3 tool/slides/export_app_decks.py            # fayllarni qayta yozadi
  python3 tool/slides/export_app_decks.py --check    # yozmasdan, fayllar dolzarbligini tekshiradi

d001 (muallif tayyorlagan, rasmli, faqat uz) — assets/lectures/d001.json o'z joyida
qoladi va indeksda uz uchun shu fayl ko'rsatiladi (`f` maydoni); generatorning d001 decki
(boshqa, yupqaroq mazmun) eksport qilinmaydi. Ilovada d001 ru/en da "faqat o'zbekcha"
belgisi bilan ochiladi.

PPTX slayd turlari -> ilova shablonlari (title, bullets, table, figure, qa):
  title    -> title        outline  -> bullets      text    -> bullets
  columns  -> bullets ("Sarlavha: matn")             table   -> table
  card     -> figure (rasm + qatorlar izoh)          pair    -> 2 ta figure
  gallery  -> figure (har foto alohida)              qa_q+qa_a -> bitta qa (javob tugma bilan)
  sources  -> bullets (ixcham, raqamlangan)
Uzun slaydlar (PPTX'dagi kabi) bir necha slaydga bo'linadi; sahifa raqami
eyebrow'da ("... · 1/2"), sarlavha o'zgarmaydi (qidiruv uchun).
"""
import argparse
import json
import os
import re
import sys
import types

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import deck_content as dc  # noqa: E402
import practice_decks as pd  # noqa: E402

REPO = dc.REPO
OUT_DIR = os.path.join(REPO, 'assets', 'lectures')
DECK_DIR = os.path.join(OUT_DIR, 'decks')
SCHEMA = 2
LANGS = dc.LANGS

# d001 — muallif tayyorlagan rasmli deck (uz); indeksda shu fayl ishlatiladi.
AUTHORED = {('d001', 'uz'): 'assets/lectures/d001.json'}

# Bo'lish byudjeti (belgilar): ilova pleyeri slaydni aylantiradi, lekin juda uzun
# slayd proyektorda o'qilmaydi — PPTX'dagi sahifalash kabi.
BULLET_CHARS = 900
BULLET_MAX = 7
TABLE_CHARS = 1000
TABLE_ROWS = 9
CAPTION_CHARS = 900
SOURCES_PER_SLIDE = 7

SKIP_TITLES_FOR_SEARCH = set()


# ------------------------------------------------------------- yordamchi ----

def split_sentences(text, seps='.!?'):
    parts = re.split(r'(?<=[' + re.escape(seps) + r'])\s+', text)
    return [p for p in parts if p]


def normalize_for_search(s):
    """lib/features/content/analyte_search.dart normalizeForSearch bilan bir xil."""
    s = s.lower()
    s = re.sub("[‘’ʻʼ`'´]", '', s)
    s = s.replace('ё', 'е')
    s = re.sub(r'[\-‐–—_/,.;:()\[\]·]+', ' ', s)
    s = re.sub(r'\s+', ' ', s).strip()
    return s


def eyebrow_with_page(eyebrow, i, n):
    if n <= 1:
        return eyebrow or None
    pg = f'{i}/{n}'
    return f'{eyebrow} · {pg}' if eyebrow else pg


def split_long(text, budget):
    """Bitta uzun matnni jumlalar bo'yicha bo'laklarga (budjetga sig'adigan)."""
    if len(text) <= budget:
        return [text]
    for seps in ('.!?', '.!?;', '.!?;:,'):
        sents = split_sentences(text, seps)
        if len(sents) > 1 and all(len(s) <= budget for s in sents):
            break
    else:
        sents = split_sentences(text, '.!?;:,')
    if len(sents) <= 1:
        return [text]
    out, cur = [], ''
    for s in sents:
        if cur and len(cur) + 1 + len(s) > budget:
            out.append(cur)
            cur = s
        else:
            cur = f'{cur} {s}'.strip()
    if cur:
        out.append(cur)
    return out


def paginate_bullets(items, chars=BULLET_CHARS, maxn=BULLET_MAX):
    pages, cur, used = [], [], 0
    queue = []
    for it in items:
        queue += split_long(it, chars)
    for it in queue:
        if cur and (used + len(it) > chars or len(cur) >= maxn):
            pages.append(cur)
            cur, used = [], 0
        cur.append(it)
        used += len(it)
    if cur:
        pages.append(cur)
    return pages or [[]]


def paginate_rows(rows, chars=TABLE_CHARS, maxn=TABLE_ROWS):
    pages, cur, used = [], [], 0
    for r in rows:
        n = sum(len(c) for c in r)
        if cur and (used + n > chars or len(cur) >= maxn):
            pages.append(cur)
            cur, used = [], 0
        cur.append(r)
        used += n
    if cur:
        pages.append(cur)
    return pages or [[]]


def block_bullets(blocks, numbered=False):
    """PPTX bloklari (label, text) -> bandlar ro'yxati."""
    out = []
    for i, b in enumerate(blocks, 1):
        text = b['text']
        if b.get('label'):
            text = f'{b["label"]}: {text}'
        if numbered:
            text = f'{i}. {text}'
        out.append(text)
    return out


def clean(d):
    """Bo'sh/None/False maydonlarni olib tashlaydi (JSON ixcham bo'lsin).
    0 (masalan, to'g'ri javob A) saqlanadi: `0 in (False,)` True bo'lgani uchun `is` bilan."""
    return {k: v for k, v in d.items()
            if v is not None and v is not False and v != '' and v != []}


# ------------------------------------------------------------ konvertatsiya ----

class Conv:
    def __init__(self, deck):
        import make_topic_decks as mk
        self.mk = mk
        self.deck = deck
        self.lang = deck.lang
        self.out = []
        self._ctx = types.SimpleNamespace(deck=deck, lang=deck.lang)

    def source(self, spec, refs=None):
        if not spec.is_content:
            return None
        if refs is not None:
            spec = types.SimpleNamespace(sources=refs)
        return self.mk.source_line(self._ctx, spec) or None

    def add(self, **kw):
        if kw.get('template') == 'bullets':
            del kw['template']      # standart shablon
        self.out.append(clean(kw))

    # -- turlar --------------------------------------------------------------

    def title(self, s):
        d = s.data
        self.add(template='title', title=s.title, eyebrow=s.eyebrow or None,
                 bullets=[d['module']] + list(d['lines']))

    def outline(self, s):
        pages = paginate_bullets(s.data['items'])
        for i, pg in enumerate(pages, 1):
            self.add(template='bullets', title=s.title, eyebrow=eyebrow_with_page('', i, len(pages)),
                     bullets=pg)

    def text(self, s):
        d = s.data
        items = []
        chips = d.get('chips') or []
        if chips:
            items.append('  ·  '.join(chips))
        title, eyebrow = s.title, s.eyebrow
        if d.get('lead'):
            # og'zaki savol: sarlavha — savol, bandlar — javob rejasi
            title = d['lead']
            eyebrow = f'{eyebrow.split(" · ")[0]} · {dc.T("oral_a", self.lang)}' if eyebrow else dc.T('oral_a', self.lang)
        items += block_bullets(d['blocks'], numbered=bool(d.get('numbered')))
        pages = paginate_bullets(items)
        src = self.source(s)
        for i, pg in enumerate(pages, 1):
            self.add(template='bullets', title=title, eyebrow=eyebrow_with_page(eyebrow, i, len(pages)),
                     bullets=pg, source=src)

    def columns(self, s):
        d = s.data
        items = []
        for c in d['cols']:
            items += [f'{c["head"]}: {b["text"]}' for b in c['blocks']]
        items += [b['text'] for b in d['single']]
        pages = paginate_bullets(items)
        src = self.source(s)
        for i, pg in enumerate(pages, 1):
            self.add(template='bullets', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, len(pages)),
                     bullets=pg, source=src)

    def table(self, s):
        d = s.data
        pages = paginate_rows(d['rows'])
        src = self.source(s)
        for i, pg in enumerate(pages, 1):
            self.add(template='table', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, len(pages)),
                     header=d['header'] if any(d['header']) else None, rows=pg,
                     footnote=d.get('note') or None, source=src)

    def _caption_pages(self, lines):
        return paginate_bullets(lines, chars=CAPTION_CHARS, maxn=99)

    def card(self, s):
        d = s.data
        lines = []
        if d.get('badge'):
            lines.append(d['badge'])
        lines += [m for m in d.get('marks') or []]
        lines += [f'{k}: {v}' for k, v in d['rows']]
        if d.get('caveat'):
            lines.append(f'{d["caveat"][0]}: {d["caveat"][1]}')
        lines.append(d['note'])
        pages = self._caption_pages(lines)
        src = self.source(s)
        for i, pg in enumerate(pages, 1):
            self.add(template='figure', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, len(pages)),
                     figure=s.image, caption='\n'.join(pg), source=src)

    def pair(self, s):
        d = s.data
        src = self.source(s)
        cap_a = [d['a']['name'], d['note']]
        cap_b = [d['b']['name'], d['tip']]
        if d.get('badge'):
            cap_b.append(d['badge'])
        cap_b.append(d['note'])
        self.add(template='figure', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, 1, 2),
                 figure=d['a']['image'], caption='\n'.join(cap_a), source=src)
        self.add(template='figure', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, 2, 2),
                 figure=d['b']['image'], caption='\n'.join(cap_b), source=src)

    def gallery(self, s):
        items = s.data['items']
        n = len(items)
        for i, it in enumerate(items, 1):
            refs = [s.sources[i - 1]] if len(s.sources) == n else None
            self.add(template='figure', title=s.title, eyebrow=s.eyebrow or None,
                     figure=it['image'], caption=f'{it["caption"]}\n{it["credit"]}',
                     source=self.source(s, refs))

    def qa_q(self, s):
        pass    # savol va javob bitta qa slaydida (qa_a bilan)

    def qa_a(self, s):
        d = s.data
        parts = []
        if d.get('explanation'):
            parts.append(f'{d["labels"]["explanation"]}: {d["explanation"]}')
        if d.get('basis'):
            parts.append(f'{d["labels"]["basis"]}: {d["basis"]}')
        self.add(template='qa', title=d['question'], eyebrow=s.eyebrow, options=d['options'],
                 correct=d['correct'], explanation='\n\n'.join(parts) or None,
                 source=self.source(s))

    def sources(self, s):
        items = [f'{i}. {t}' for i, t in enumerate(s.data['items'], 1)]
        pages = [items[k:k + SOURCES_PER_SLIDE] for k in range(0, len(items), SOURCES_PER_SLIDE)]
        for i, pg in enumerate(pages or [[]], 1):
            self.add(template='bullets', title=s.title, eyebrow=eyebrow_with_page('', i, len(pages)),
                     bullets=pg, compact=True)

    def run(self):
        for s in self.deck.slides:
            getattr(self, s.kind)(s)
        return self.out


def convert(deck):
    return Conv(deck).run()


# -------------------------------------------------------------- yig'ish ----

def day_topic_ids(day):
    return [t['id'] for t in day.topics]


def deck_json(deck_id, lang, title, topics, slides):
    """Deck JSON. Takrorlanuvchi manba qatorlari deck darajasidagi `srcs`
    jadvaliga olinadi (slaydda `src` indeksi) — hajmni ~1 MB ga kamaytiradi."""
    srcs, slim = [], []
    for s in slides:
        s = dict(s)
        if 'source' in s:
            if s['source'] not in srcs:
                srcs.append(s['source'])
            s['src'] = srcs.index(s.pop('source'))
        slim.append(s)
    j = {'schema': SCHEMA, 'id': deck_id, 'lang': lang, 'status': 'sourced',
         'title': title, 'topics': topics}
    if srcs:
        j['srcs'] = srcs
    j['slides'] = slim
    return j


def generic_titles(lang):
    """Qidiruvda ma'no bermaydigan umumiy sarlavhalar (har deckda bor)."""
    return {dc.T('outline', lang), dc.T('sources', lang), pd.OUTLINE[lang]}


def slide_title_runs(slides, lang):
    """Ketma-ket bir xil sarlavhalar: [[sarlavha, birinchi indeks, soni], ...].
    Sarlavha slaydi (deck nomi) va umumiy sarlavhalar (reja, adabiyotlar) tushirib
    qoldiriladi: ular qidiruvda faqat shovqin."""
    skip = generic_titles(lang)
    runs = []
    for i, s in enumerate(slides):
        if i == 0 or s['title'] in skip:
            continue
        if runs and runs[-1][0] == s['title'] and runs[-1][1] + runs[-1][2] == i:
            runs[-1][2] += 1
        else:
            runs.append([s['title'], i, 1])
    return runs


def eyebrow_heads(slides):
    seen, out = set(), []
    for s in slides:
        e = (s.get('eyebrow') or '').split(' · ')[0].strip()
        if e and e not in seen:
            seen.add(e)
            out.append(e)
    return out


def keyword_blob(entries):
    """Normallashtirilgan kalit so'zlar: ' | ' bilan ajratilgan, takrorsiz."""
    seen, out = set(), []
    for t in entries:
        n = normalize_for_search(t)
        if n and n not in seen:
            seen.add(n)
            out.append(n)
    return ' | '.join(out)


def build_all(repo):
    """-> (decklar {(id, til): json}, indeks dict)."""
    errs = pd.validate(repo)
    if errs:
        raise SystemExit('books_extra_practice.json xatolari:\n  ' + '\n  '.join(errs))
    files, entries = {}, []
    modules = []
    for mi, m in enumerate(repo.cur['modules'], 1):
        modules.append({'n': mi, 'id': m['id'],
                        'uz': m['title_uz'], 'ru': m.get('title_ru') or m['title_uz'],
                        'en': m.get('title_en') or m['title_uz']})

    def entry(deck_id, kind, extra, per_lang, kw_extra):
        langs = [lg for lg in LANGS if lg in per_lang]
        e = {'id': deck_id, 'kind': kind}
        e.update(extra)
        e['t'] = {lg: per_lang[lg]['title'] for lg in langs}
        e['n'] = {lg: len(per_lang[lg]['slides']) for lg in langs}
        e['l'] = langs
        e['st'] = {lg: slide_title_runs(per_lang[lg]['slides'], lg) for lg in langs}
        kws = []
        for lg in langs:
            sl = per_lang[lg]['slides']
            kws += [per_lang[lg]['title']] + [r[0] for r in e['st'][lg]] + eyebrow_heads(sl)
            kws += kw_extra.get(lg, [])
        e['kw'] = keyword_blob(kws)
        return e

    # --- kun mavzulari
    for day in repo.days.values():
        per_lang = {}
        for lg in LANGS:
            deck, _cov = dc.build_deck(repo, day, lg)
            if deck is None:
                break
            slides = convert(deck)
            per_lang[lg] = deck_json(day.id, lg, day.title(lg), day_topic_ids(day), slides)
        if not per_lang:
            continue
        # muallif decki (uz) o'z faylida qoladi; indeks uchun uning sarlavhalari
        authored = {}
        for (did, lg), path in AUTHORED.items():
            if did == day.id:
                with open(os.path.join(REPO, path), encoding='utf-8') as f:
                    j = json.load(f)
                authored[lg] = {'title': j['title'], 'slides': j['slides']}
        if authored:
            # muallif decki bor kun: faqat uning tillari (generatorning ru/en decki mazmunan
            # boshqa va yupqaroq bo'lardi); muallif decki tarjima qilingach qo'shiladi
            per_lang = {}
        for lg, j in per_lang.items():
            files[(day.id, lg)] = j
        view ={lg: ({'title': j['title'], 'slides': j['slides']}) for lg, j in per_lang.items()}
        view.update(authored)
        mod = day.module
        kw_extra = {lg: [mod.get('title_' + lg) or mod['title_uz']] for lg in LANGS}
        e = entry(day.id, 'day',
                  {'m': day.module_no, 'w': day.main.get('week'), 'd': day.n,
                   'topics': day_topic_ids(day)},
                  view, kw_extra)
        f = {lg: AUTHORED[(day.id, lg)] for lg in LANGS if (day.id, lg) in AUTHORED}
        if f:
            e['f'] = f
        entries.append(e)

    # --- amaliy protokollar
    for p in pd.protocols(repo):
        per_lang = {}
        for lg in LANGS:
            deck, _cov = pd.build_practice_deck(repo, p, lg)
            if deck is None:
                continue
            slides = convert(deck)
            per_lang[lg] = deck_json(p['id'], lg, dc.L(p['title'], lg), [], slides)
            files[(p['id'], lg)] = per_lang[lg]
        if not per_lang:
            continue
        kw_extra = {lg: [dc.L(p['group'], lg)] for lg in per_lang}
        e = entry(p['id'], 'protocol',
                  {'g': {lg: dc.L(p['group'], lg) for lg in per_lang}}, per_lang, kw_extra)
        entries.append(e)

    index = {'schema': SCHEMA, 'modules': modules, 'decks': entries}
    return files, index


def dumps(obj):
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':'))


def write_all(files, index, check=False):
    expected = {}
    for (did, lg), j in files.items():
        expected[os.path.join(DECK_DIR, f'{did}.{lg}.json')] = dumps(j)
    expected[os.path.join(OUT_DIR, 'index_v2.json')] = dumps(index)
    stale = []
    if os.path.isdir(DECK_DIR):
        for fn in sorted(os.listdir(DECK_DIR)):
            p = os.path.join(DECK_DIR, fn)
            if p not in expected:
                stale.append(p)
    changed = []
    for p, text in expected.items():
        old = None
        if os.path.exists(p):
            with open(p, encoding='utf-8') as f:
                old = f.read()
        if old != text:
            changed.append(p)
    if check:
        return changed + stale
    os.makedirs(DECK_DIR, exist_ok=True)
    for p in changed:
        with open(p, 'w', encoding='utf-8') as f:
            f.write(expected[p])
    for p in stale:
        os.remove(p)
    return changed + stale


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--check', action='store_true',
                    help='fayllarga yozmaydi; dolzarb bo‘lmasa 1 bilan chiqadi')
    a = ap.parse_args(argv)
    repo = dc.Repo()
    files, index = build_all(repo)
    changed = write_all(files, index, check=a.check)
    total = sum(len(dumps(j).encode()) for j in files.values())
    print(f'decklar: {len(index["decks"])} (fayllar: {len(files)}), '
          f'hajm: {total / 1e6:.2f} MB + indeks {len(dumps(index).encode()) / 1e6:.2f} MB')
    for lg in LANGS:
        n = sum(1 for e in index['decks'] if lg in e['l'])
        print(f'  {lg}: {n} deck')
    if a.check:
        if changed:
            print('Eskirgan fayllar (python3 tool/slides/export_app_decks.py):')
            for p in changed:
                print('  ', os.path.relpath(p, REPO))
            raise SystemExit(1)
        print('Hammasi dolzarb.')
    else:
        print(f'yozildi/o‘zgardi: {len(changed)}')


if __name__ == '__main__':
    main()
