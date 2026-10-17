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
Uzun slaydlar ilovaning 16:9 kanvasi (1280×720, asosiy matn ≥ 26 px) byudjeti bo'yicha
davom slaydlariga bo'linadi (D-59): band chegarasida, bitta uzun band — faqat jumla oxirida;
sahifa raqami eyebrow'da ("... · 1/2"), sarlavha va manba har qismda bir xil (qidiruv uchun).
Har kontent slaydida `ref` — deck `refs` jadvaliga: "Adabiyotlar" raqami + shu slayd bo'lim/sahifalari
(ilova manba oynasida to'liq yozuv ko'rsatadi).
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

# ------------------------------------------------------- 16:9 kanvas byudjeti ----
# Ilova slaydni 1280×720 kanvasda chizadi (lib/features/classroom/lecture_canvas.dart —
# o'lchamlar aynan shu) va ekranga teng masshtablaydi. Proyektorda o'qilishi uchun asosiy
# matn kamida MIN_FONT px (1280 kenglikda). Slayd PACK_FONT da sig'maydigan bo'lsa, davom
# slaydlariga ("... · 2/3") bo'linadi: bandlar chegarasida, bitta uzun band esa faqat jumla
# oxirida (hech qachon jumla o'rtasida emas). Hisob — ehtiyotkor taxmin (harf kengligi ×
# belgilar soni, so'zma-so'z o'rash); haqiqiy o'lchov ilovada (sig'masa — kichraytiriladi,
# matn kesilmaydi). Taxmin deterministik (PIL/shriftga bog'liq emas).
CANVAS_W, CANVAS_H = 1280, 720
PAD_X = 72
CONTENT_W = CANVAS_W - 2 * PAD_X        # 1136
TITLE_TOP = 96
TITLE_SIZES = (44, 40, 36, 32)          # 2 qatorgacha; bo'lmasa 32 px da ko'proq qator
QA_TITLE_SIZES = (40, 36, 32, 28)       # savol: 3 qatorgacha
TITLE_LH = 1.15
TITLE_GAP = 24
FOOTER_TOP = 664
BODY_BOTTOM = FOOTER_TOP - 24           # manba qatorisiz
SRC_SIZE = 17
SRC_LH = 1.3
SRC_GAP = 12                            # manba va footer orasida
BODY_SRC_GAP = 16                       # tana va manba orasida
BULLET_INDENT = 30                      # belgi + bo'shliq
BODY_LH = 1.35
ITEM_GAP = 0.5                          # bandlar orasida (em)
PACK_FONT = 28                          # bo'lish shu shriftda hisoblanadi (ilova 34→26)
MIN_FONT = 26
PLAN_INDENT = 64                        # raqamli doiracha + bo'shliq
TABLE_FONT = 24
TABLE_LH = 1.3
TABLE_PAD_X, TABLE_PAD_Y = 14, 10
SOURCES_FONT = 20
SOURCES_GAP = 8
FIG_IMG_W = 520                         # rasm qutisi (ilovada izoh qisqa bo'lsa 640); izoh o'ngda
CREDIT_SIZE = 18
FIG_GAP = 40
FIG_CAP_W = CONTENT_W - FIG_IMG_W - FIG_GAP
CAP_GAP = 0.4
QA_LETTER = 44
QA_OPT_PAD = 14
QA_OPT_GAP = 12
NOTE_SIZE = 18
# O'rtacha harf kengligi (em) — Inter 400, tilga qarab (o'lchangan: uz 0.46, en 0.47,
# ru 0.53) + ~8% zaxira.
EM = {'uz': 0.50, 'en': 0.51, 'ru': 0.57}
BOLD_K = 1.05

SKIP_TITLES_FOR_SEARCH = set()
WARNINGS = []   # bo'linmaydigan (bitta jumla) va sig'maydigan holatlar


# ------------------------------------------------------------- yordamchi ----

def normalize_for_search(s):
    """lib/features/content/analyte_search.dart normalizeForSearch bilan bir xil."""
    s = s.lower()
    s = re.sub("[‘’ʻʼ`'´]", '', s)
    s = s.replace('ё', 'е')
    s = re.sub(r'[\-‐–—_/,.;:()\[\]·]+', ' ', s)
    s = re.sub(r'\s+', ' ', s).strip()
    return s


def wrap_lines(text, size, width, lang, bold=False):
    """So'zma-so'z o'rash: taxminiy qatorlar soni (belgi = o'rtacha harf kengligi)."""
    cpl = max(8, int(width / (EM.get(lang, 0.57) * size * (BOLD_K if bold else 1.0))))
    total = 0
    for para in str(text).split('\n'):
        n, cur = 1, 0
        for w in para.split():
            ln = len(w)
            if cur == 0:
                cur = ln
            elif cur + 1 + ln <= cpl:
                cur += 1 + ln
            else:
                n += 1
                cur = ln
            while cur > cpl:      # juda uzun so'z (URL)
                n += 1
                cur -= cpl
        total += n
    return total


def title_height(title, lang, sizes=TITLE_SIZES, max_lines=2):
    for sz in sizes:
        n = wrap_lines(title, sz, CONTENT_W, lang, bold=True)
        if n <= max_lines:
            return n * sz * TITLE_LH
    sz = sizes[-1]
    return wrap_lines(title, sz, CONTENT_W, lang, bold=True) * sz * TITLE_LH


def body_box(title, lang, source=None, sizes=TITLE_SIZES, max_lines=2):
    """Tana balandligi (px): sarlavha ostidan manba qatori (yoki footer) gacha."""
    top = TITLE_TOP + title_height(title, lang, sizes, max_lines) + TITLE_GAP
    bottom = BODY_BOTTOM
    if source:
        src_h = wrap_lines(source, SRC_SIZE, CONTENT_W, lang) * SRC_SIZE * SRC_LH
        bottom = FOOTER_TOP - SRC_GAP - src_h - BODY_SRC_GAP
    return bottom - top


def items_height(items, size, width, lang, gap=ITEM_GAP, lh=BODY_LH):
    if not items:
        return 0
    return (sum(wrap_lines(t, size, width, lang) for t in items) * size * lh
            + (len(items) - 1) * gap * size)


# --- jumlalar (faqat jumla oxirida bo'linadi) ---------------------------------

_SENT_END = re.compile(r'[.!?…]["»”’)\]]*(\s+)(?=["«„“(\[]?[A-ZÀ-ÖØ-ÞА-ЯЁЎҚҒҲ0-9])')
_ABBR = {'e.g', 'i.e', 'vs', 'cf', 'fig', 'figs', 'no', 'nos', 'dr', 'prof', 'st', 'p', 'pp', 'ch',
         'vol', 'ed', 'eds', 'approx', 'ca', 'al', 'mr', 'mrs', 'т.е', 'т.д', 'т.п', 'т.к', 'др', 'см',
         'рис', 'табл', 'стр', 'г', 'гг', 'h.k', 'sh', 'ya'}


def sentences(text):
    """Matnni jumlalarga ajratadi (' '.join(...) — asl matn). Chegara: . ! ? … dan keyin
    bo'shliq va katta harf/raqam; qisqartmalar (e.g., т.е., bosh harf "A.") chegara emas."""
    out, start = [], 0
    for m in _SENT_END.finditer(text):
        head = text[start:m.start(1)]
        words = head.split()
        prev = words[-1] if words else ''
        tok = prev.lstrip('(«"').rstrip('.!?…"»”’)]').lower()
        if tok in _ABBR or (len(tok) == 1 and tok.isalpha()):
            continue
        out.append(head.strip())
        start = m.end(1)
    tail = text[start:].strip()
    if tail:
        out.append(tail)
    return [x for x in out if x] or [text]


def paginate(items, fits, what=''):
    """Bandlarni sahifalarga: band chegarasida; bitta band sahifaga sig'masa — jumlalar
    bo'yicha (bitta jumla ham sig'masa — o'zi alohida sahifa, ilova kichraytiradi).
    fits(list) -> bool."""
    pages, cur, queue = [], [], list(items)
    while queue:
        it = queue.pop(0)
        if fits(cur + [it]):
            cur.append(it)
            continue
        if cur:
            pages.append(cur)
            cur = []
        if fits([it]):
            cur = [it]
            continue
        sents = sentences(it)
        piece = []
        for snt in sents:
            if fits([' '.join(piece + [snt])]):
                piece.append(snt)
            else:
                break
        if not piece:
            WARNINGS.append(f'{what}: bitta jumla sig\'madi: {sents[0][:60]}')
            piece = sents[:1]
        rest = sents[len(piece):]
        if rest:
            pages.append([' '.join(piece)])
            queue.insert(0, ' '.join(rest))
        else:
            cur = [' '.join(piece)]
    if cur:
        pages.append(cur)
    return pages or [[]]


def eyebrow_with_page(eyebrow, i, n):
    if n <= 1:
        return eyebrow or None
    pg = f'{i}/{n}'
    return f'{eyebrow} · {pg}' if eyebrow else pg


def bullets_fit(items, title, lang, source=None, indent=BULLET_INDENT, size=PACK_FONT):
    return items_height(items, size, CONTENT_W - indent, lang) <= body_box(title, lang, source)


def paginate_bullets(items, title, lang, source=None, indent=BULLET_INDENT, size=PACK_FONT):
    avail = body_box(title, lang, source)
    width = CONTENT_W - indent
    return paginate(items, lambda xs: items_height(xs, size, width, lang) <= avail, title[:40])


def table_height(header, rows, lang, size=TABLE_FONT):
    cols = max([len(header or [])] + [len(r) for r in rows] + [1])
    flex = [1.0] * cols
    if cols > 2:
        flex[-1] = 1.4
    tot = sum(flex)
    widths = [CONTENT_W * f / tot - 2 * TABLE_PAD_X for f in flex]

    def row_h(r, k=1.0):
        n = max([wrap_lines(c, size * k, widths[i], lang, bold=(i == 0))
                 for i, c in enumerate(r)] or [1])
        return n * size * k * TABLE_LH + 2 * TABLE_PAD_Y
    h = row_h(header, 0.8) if any(header or []) else 0
    return h + sum(row_h(r) for r in rows)


def paginate_rows(rows, header, title, lang, source=None, note=None):
    avail = body_box(title, lang, source)
    if note:
        avail -= wrap_lines(note, NOTE_SIZE, CONTENT_W, lang) * NOTE_SIZE * 1.3 + 12
    pages, cur = [], []
    for r in rows:
        if cur and table_height(header, cur + [r], lang) > avail:
            pages.append(cur)
            cur = []
        cur.append(r)
    if cur:
        pages.append(cur)
    for pg in pages:
        if table_height(header, pg, lang) > avail:
            WARNINGS.append(f'{title[:40]}: jadval qatori sig\'madi')
    return pages or [[]]


def paginate_caption(lines, title, lang, source=None, credit=None):
    """Rasm izohi (qatorlar) — o'ng ustunga. [credit] (rasm muallifi/litsenziyasi yoki
    "sxema" izohi) har sahifada alohida, kichik shriftda — rasm har sahifada bor."""
    avail = body_box(title, lang, source)
    if credit:
        avail -= 30 + wrap_lines(credit, CREDIT_SIZE, FIG_CAP_W, lang) * CREDIT_SIZE * 1.3

    def fits(xs):
        return items_height(xs, PACK_FONT, FIG_CAP_W, lang, gap=CAP_GAP) <= avail
    return paginate(lines, fits, title[:40]) if lines else [[]]


def paginate_sources(items, title, lang):
    avail = body_box(title, lang)
    return paginate(items, lambda xs: items_height(xs, SOURCES_FONT, CONTENT_W, lang,
                                                   gap=SOURCES_GAP / SOURCES_FONT, lh=1.3) <= avail,
                    'Adabiyotlar')


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
        self._bib = {k: i for i, k in enumerate(deck.sources.entries)}

    def source(self, spec, refs=None):
        if not spec.is_content:
            return None
        if refs is not None:
            spec = types.SimpleNamespace(sources=refs)
        return self.mk.source_line(self._ctx, spec) or None

    def refs(self, spec, refs=None):
        """Slayd manbalari — "Adabiyotlar" ro'yxatidagi tartib raqami (0 dan) va shu
        slaydda ishlatilgan bo'lim/sahifalar: [[i, loc1, loc2...], ...]. Ilova manba
        oynasida to'liq yozuvni (muallif, kitob, sahifa) kesmasdan ko'rsatadi."""
        if not spec.is_content:
            return None
        out = []
        for r in (refs if refs is not None else spec.sources):
            i = self._bib[r['key']]
            row = next((x for x in out if x[0] == i), None)
            if row is None:
                row = [i]
                out.append(row)
            loc = (r.get('loc') or '').strip()
            if loc and loc not in row[1:]:
                row.append(loc)
        return out or None

    def add(self, **kw):
        if kw.get('template') == 'bullets':
            del kw['template']      # standart shablon
        self.out.append(clean(kw))

    def _bullet_pages(self, items, title, src, indent=BULLET_INDENT):
        return paginate_bullets(items, title, self.lang, src, indent=indent)

    # -- turlar --------------------------------------------------------------

    def title(self, s):
        d = s.data
        self.add(template='title', title=s.title, eyebrow=s.eyebrow or None,
                 bullets=[d['module']] + list(d['lines']))

    def outline(self, s):
        pages = self._bullet_pages(s.data['items'], s.title, None, indent=PLAN_INDENT)
        for i, pg in enumerate(pages, 1):
            self.add(template='bullets', title=s.title, eyebrow=eyebrow_with_page('', i, len(pages)),
                     bullets=pg, plan=True)

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
        src = self.source(s)
        pages = self._bullet_pages(items, title, src)
        refs = self.refs(s)
        for i, pg in enumerate(pages, 1):
            self.add(template='bullets', title=title, eyebrow=eyebrow_with_page(eyebrow, i, len(pages)),
                     bullets=pg, source=src, refs=refs)

    def columns(self, s):
        d = s.data
        items = []
        for c in d['cols']:
            items += [f'{c["head"]}: {b["text"]}' for b in c['blocks']]
        items += [b['text'] for b in d['single']]
        src = self.source(s)
        pages = self._bullet_pages(items, s.title, src)
        refs = self.refs(s)
        for i, pg in enumerate(pages, 1):
            self.add(template='bullets', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, len(pages)),
                     bullets=pg, source=src, refs=refs)

    def table(self, s):
        d = s.data
        src = self.source(s)
        header = d['header'] if any(d['header']) else None
        note = d.get('note') or None
        pages = paginate_rows(d['rows'], header, s.title, self.lang, src, note)
        refs = self.refs(s)
        for i, pg in enumerate(pages, 1):
            self.add(template='table', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, len(pages)),
                     header=header, rows=pg, footnote=note, source=src, refs=refs)

    def _figures(self, s, image, lines, credit, src, refs):
        """Bitta rasm + izoh qatorlari; izoh sig'masa — rasm takrorlanadigan davom slaydlari."""
        pages = paginate_caption(lines, s.title, self.lang, src, credit)
        for i, pg in enumerate(pages, 1):
            self.add(template='figure', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, len(pages)),
                     figure=image, caption='\n'.join(pg), credit=credit, source=src, refs=refs)

    def card(self, s):
        d = s.data
        lines = []
        if d.get('badge'):
            lines.append(d['badge'])
        lines += [m for m in d.get('marks') or []]
        lines += [f'{k}: {v}' for k, v in d['rows']]
        if d.get('caveat'):
            lines.append(f'{d["caveat"][0]}: {d["caveat"][1]}')
        self._figures(s, s.image, lines, d['note'], self.source(s), self.refs(s))

    def pair(self, s):
        d = s.data
        src = self.source(s)
        refs = self.refs(s)
        cap_a = [d['a']['name']]
        cap_b = [d['b']['name'], d['tip']]
        if d.get('badge'):
            cap_b.append(d['badge'])
        parts = [(d[k]['image'], paginate_caption(c, s.title, self.lang, src, d['note']))
                 for k, c in (('a', cap_a), ('b', cap_b))]
        total = sum(len(p) for _, p in parts)
        k = 0
        for image, pages in parts:
            for pg in pages:
                k += 1
                self.add(template='figure', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, k, total),
                         figure=image, caption='\n'.join(pg), credit=d['note'], source=src, refs=refs)

    def gallery(self, s):
        items = s.data['items']
        n = len(items)
        for i, it in enumerate(items, 1):
            rs = [s.sources[i - 1]] if len(s.sources) == n else None
            src = self.source(s, rs)
            pages = paginate_caption([it['caption']], s.title, self.lang, src, it['credit'])
            for k, pg in enumerate(pages, 1):
                ey = s.eyebrow or None
                if len(pages) > 1:
                    ey = eyebrow_with_page(s.eyebrow, k, len(pages))
                self.add(template='figure', title=s.title, eyebrow=ey, figure=it['image'],
                         caption='\n'.join(pg), credit=it['credit'], source=src, refs=self.refs(s, rs))

    def qa_q(self, s):
        pass    # savol va javob bitta qa slaydida (qa_a bilan)

    def qa_a(self, s):
        d = s.data
        parts = []
        if d.get('explanation'):
            parts.append(f'{d["labels"]["explanation"]}: {d["explanation"]}')
        if d.get('basis'):
            parts.append(f'{d["labels"]["basis"]}: {d["basis"]}')
        src = self.source(s)
        refs = self.refs(s)
        q = d['question']
        # Javob ko'rinishi: savol (sarlavha) + to'g'ri javob qutisi + izoh. Izoh sig'masa —
        # qolgani davom slaydida (sarlavha — o'sha savol), PPTX'dagi kabi.
        ans = d['options'][d['correct']]
        box = wrap_lines(ans, PACK_FONT, CONTENT_W - QA_LETTER - 60, self.lang, bold=True) \
            * PACK_FONT * 1.3 + 32 + 24
        avail = body_box(q, self.lang, src, QA_TITLE_SIZES, 3) - box
        first, rest = [], list(parts)
        if parts and avail >= 2 * PACK_FONT * BODY_LH:
            pages = paginate(parts, lambda xs: items_height(xs, PACK_FONT, CONTENT_W, self.lang) <= avail,
                             q[:40])
            first = pages[0]
            rest = [x for pg in pages[1:] for x in pg]
        cont = self._bullet_pages(rest, q, src) if rest else []
        n = 1 + len(cont)
        self.add(template='qa', title=q, eyebrow=eyebrow_with_page(s.eyebrow, 1, n), options=d['options'],
                 correct=d['correct'], explanation='\n\n'.join(first) or None,
                 source=src, refs=refs)
        for k, pg in enumerate(cont, 2):
            self.add(template='bullets', title=q, eyebrow=eyebrow_with_page(s.eyebrow, k, n),
                     bullets=pg, source=src, refs=refs)

    def sources(self, s):
        items = [f'{i}. {t}' for i, t in enumerate(s.data['items'], 1)]
        pages = paginate_sources(items, s.title, self.lang)
        for i, pg in enumerate(pages, 1):
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
    srcs, refs, slim = [], [], []
    for s in slides:
        s = dict(s)
        if 'source' in s:
            if s['source'] not in srcs:
                srcs.append(s['source'])
            s['src'] = srcs.index(s.pop('source'))
        if 'refs' in s:
            # slayd manbalari ham deck jadvalida (davom slaydlari bir xil ro'yxatni ulashadi)
            if s['refs'] not in refs:
                refs.append(s['refs'])
            s['ref'] = refs.index(s.pop('refs'))
        slim.append(s)
    j = {'schema': SCHEMA, 'id': deck_id, 'lang': lang, 'status': 'sourced',
         'title': title, 'topics': topics}
    if srcs:
        j['srcs'] = srcs
    if refs:
        j['refs'] = refs
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
