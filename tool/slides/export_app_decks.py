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
import visuals as vz  # noqa: E402

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

# --- vizual shablonlar (lecture_canvas.dart dagi o'lchamlar bilan bir xil) -------------
STAT_ROW = 174                          # raqam kartalari qatori (karta 150 + oraliq 24)
SIDE_W, SIDE_GAP = 400, 40              # yon rasm (bandlar o'ngda emas, chapda; rasm o'ngda)
STEP_COL = 72                           # qadam tuguni (48) + oraliq
STEP_PAD_X, STEP_PAD_Y, STEP_GAP = 20, 14, 16
STEPS_MAX = 6
STEP_W = CONTENT_W - STEP_COL - 2 * STEP_PAD_X
SPLIT_GAP, SPLIT_HEAD, SPLIT_PAD = 32, 80, 20
SPLIT_COL_W = (CONTENT_W - SPLIT_GAP) / 2 - 2 * SPLIT_PAD - BULLET_INDENT
SPLIT_FONT = 24                         # ikki ustun: 24 px da hisoblanadi (jadval kabi)
SPLIT_MAX_PAGES = 3
TREE_ROOT_W, TREE_LINK, TREE_PAD_X, TREE_PAD_Y, TREE_GAP = 300, 64, 18, 12, 12
TREE_FONT = 24                          # daraxt: 24 px da sig'masa — oddiy bandlar
TREE_W = CONTENT_W - TREE_ROOT_W - TREE_LINK - 2 * TREE_PAD_X

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


def steps_height(items, lang, size=PACK_FONT):
    h = 0
    for t in items:
        body = re.sub(r'^\d{1,2}\.\s+', '', t)
        h += max(48, wrap_lines(body, size, STEP_W, lang) * size * 1.3 + 2 * STEP_PAD_Y)
    return h + max(0, len(items) - 1) * STEP_GAP


def split_height(left, right, singles, lang, size=None):
    size = size or SPLIT_FONT
    col = max(items_height(left, size, SPLIT_COL_W, lang), items_height(right, size, SPLIT_COL_W, lang))
    h = SPLIT_HEAD + col + 2 * SPLIT_PAD
    if singles:
        h += 20 + items_height(singles, size, CONTENT_W - BULLET_INDENT, lang)
    return h


def tree_height(items, lang, size=TREE_FONT):
    h = 0
    for t in items:
        m = vz.LABEL_RE.match(t)
        h += (wrap_lines(m.group(1), size, TREE_W, lang, bold=True) * size * 1.25
              + wrap_lines(m.group(2), size, TREE_W, lang) * size * 1.3 + 2 * TREE_PAD_Y)
    return h + (len(items) - 1) * TREE_GAP


def ex_sentences(text):
    return sentences(text)


def side_fits(items, title, lang, source):
    width = CONTENT_W - SIDE_W - SIDE_GAP - BULLET_INDENT
    return items_height(items, MIN_FONT, width, lang) <= body_box(title, lang, source)


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
    def __init__(self, deck, repo=None):
        import make_topic_decks as mk
        self.mk = mk
        self.deck = deck
        self.repo = repo
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

    # -- vizual shablonlar ----------------------------------------------------

    def _emit_bullets(self, items, title, eyebrow, src, refs):
        """Oddiy bandlar; bandlarda >= 2 miqdor bo'lsa — raqam kartalari (stats) bilan
        (kartalar qatori uchun joy ajratib bo'linadi)."""
        lang = self.lang
        if not vz.has_stats(items, lang):
            pages = self._bullet_pages(items, title, src)
            for i, pg in enumerate(pages, 1):
                self.add(template='bullets', title=title, eyebrow=eyebrow_with_page(eyebrow, i, len(pages)),
                         bullets=pg, source=src, refs=refs)
            return
        avail = body_box(title, lang, src) - STAT_ROW
        width = CONTENT_W - BULLET_INDENT
        pages = paginate(items, lambda xs: items_height(xs, PACK_FONT, width, lang) <= avail, title[:40])
        for i, pg in enumerate(pages, 1):
            st = vz.stats_for(pg, lang)
            self.add(template='stats' if st else 'bullets', title=title,
                     eyebrow=eyebrow_with_page(eyebrow, i, len(pages)), bullets=pg, stats=st,
                     source=src, refs=refs)

    def _steps(self, items, title, eyebrow, src, refs):
        """Raqamli tartib -> 'steps' (sahifada <= STEPS_MAX qadam). Bo'linishda raqamsiz
        bo'lak chiqsa (bitta qadam sahifaga sig'masa) — None (oddiy bandlar)."""
        lang = self.lang
        avail = body_box(title, lang, src)
        pages = paginate(items, lambda xs: len(xs) <= STEPS_MAX and steps_height(xs, lang) <= avail,
                         title[:40])
        if any(not re.match(r'^\d{1,2}\.\s', x) for pg in pages for x in pg):
            return False
        for i, pg in enumerate(pages, 1):
            self.add(template='steps', title=title, eyebrow=eyebrow_with_page(eyebrow, i, len(pages)),
                     bullets=pg, source=src, refs=refs)
        return True

    def _tree(self, items, title, eyebrow, src, refs):
        if not vz.tree_ok(items):
            return False
        if tree_height(items, self.lang) > body_box(title, self.lang, src):
            return False
        self.add(template='tree', title=title, eyebrow=eyebrow or None, bullets=items, source=src, refs=refs)
        return True

    def _example(self, title, given, ex, src, refs):
        self.add(template='example', title=title, eyebrow=dc.T('example', self.lang), bullets=given,
                 ex=ex, source=src, refs=refs)

    def _tree_context(self, s):
        head = (s.eyebrow or '').split(' · ')[0]
        lg = self.lang
        return head in {dc.T('ref_label', lg), dc.T('book_extra', lg)} or head in {
            v[lg] for v in pd.LABELS.values()}

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
        refs = self.refs(s)
        if d.get('example'):
            # kalkulyator formulasi + manbadagi ishlangan misol (deck_content.example_slides)
            given = items[:-1]
            self._example(title, given, d['example'], src, refs)
            return
        # protokol bandidagi manbali "Misol (…): … → …" — alohida misol kartasi
        exs = [x for x in items if vz.is_example_item(x)] if not d.get('numbered') else []
        items = [x for x in items if x not in exs]
        if items:
            done = False
            if d.get('numbered') and not d.get('lead') and not chips:
                done = self._steps(items, title, eyebrow, src, refs)
            elif not chips and not d.get('lead') and self._tree_context(s):
                done = self._tree(items, title, eyebrow, src, refs)
            if not done:
                if d.get('lead'):
                    pages = self._bullet_pages(items, title, src)
                    for i, pg in enumerate(pages, 1):
                        self.add(template='bullets', title=title,
                                 eyebrow=eyebrow_with_page(eyebrow, i, len(pages)),
                                 bullets=pg, source=src, refs=refs)
                else:
                    self._emit_bullets(items, title, eyebrow, src, refs)
        for x in exs:
            self._example(title, [], x, src, refs)

    SPLIT_KINDS = (('high', 'up'), ('low', 'down'), ('positive', 'pos'), ('negative', 'neg'))

    def _split_pages(self, cols, singles, title, src):
        """Ikki ustun (yuqori/past yoki musbat/manfiy) -> sahifalar [(chap, o'ng, yakka)].
        Ustunlar navbatma-navbat (pastroq ustunga) to'ldiriladi; band sig'masa — faqat jumla
        oxirida bo'linadi va qolgani keyingi sahifada shu ustunda davom etadi. Bitta jumla
        ham sig'masa — None (oddiy bandlar)."""
        lang = self.lang
        avail = body_box(title, lang, src)
        queues = [list(cols[0][2]), list(cols[1][2])]

        def fits(cl, cr):
            return split_height(cl, cr, [], lang) <= avail

        pages = []
        while queues[0] or queues[1]:
            cur = [[], []]
            full = [False, False]
            while not all(full[k] or not queues[k] for k in (0, 1)):
                hs = [items_height(cur[k], SPLIT_FONT, SPLIT_COL_W, lang) for k in (0, 1)]
                order = sorted((k for k in (0, 1) if queues[k] and not full[k]), key=lambda k: hs[k])
                k = order[0]
                x = queues[k][0]
                trial = [cur[0] + [x], cur[1]] if k == 0 else [cur[0], cur[1] + [x]]
                if fits(*trial):
                    cur = trial
                    queues[k].pop(0)
                    continue
                # jumla oxirida bo'lish: sig'adigan eng uzun boshlang'ich qism
                sents = ex_sentences(x)
                piece = []
                for snt in sents:
                    cand = ' '.join(piece + [snt])
                    trial = [cur[0] + [cand], cur[1]] if k == 0 else [cur[0], cur[1] + [cand]]
                    if fits(*trial):
                        piece.append(snt)
                    else:
                        break
                if piece and len(piece) < len(sents):
                    cur[k] = cur[k] + [' '.join(piece)]
                    queues[k][0] = ' '.join(sents[len(piece):])
                if not cur[k] and not piece:
                    return None
                full[k] = True
            if not cur[0] and not cur[1]:
                return None
            pages.append([cur[0], cur[1], []])
            if len(pages) > SPLIT_MAX_PAGES:
                return None
        rest = list(singles)
        while rest and split_height(pages[-1][0], pages[-1][1], pages[-1][2] + rest[:1], lang) <= avail:
            pages[-1][2].append(rest.pop(0))
        return pages, rest

    def columns(self, s):
        d = s.data
        items = []
        for c in d['cols']:
            items += [f'{c["head"]}: {b["text"]}' for b in c['blocks']]
        items += [b['text'] for b in d['single']]
        src = self.source(s)
        refs = self.refs(s)
        lang = self.lang
        kinds = {dc.T(k, lang): code for k, code in self.SPLIT_KINDS}
        cols = [(c['head'], kinds.get(c['head']), [b['text'] for b in c['blocks']]) for c in d['cols']]
        res = None
        if len(cols) == 2 and all(code for _, code, _ in cols) and \
                {cols[0][1], cols[1][1]} in ({'up', 'down'}, {'pos', 'neg'}):
            res = self._split_pages(cols, [b['text'] for b in d['single']], s.title, src)
        if res is None:
            self._emit_bullets(items, s.title, s.eyebrow, src, refs)
            return
        pages, rest = res
        extra = self._bullet_pages(rest, s.title, src) if rest else []
        n = len(pages) + len(extra)
        for i, (cl, cr, sg) in enumerate(pages, 1):
            self.add(template='split', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, n),
                     cols=[[cols[0][0], cols[0][1], cl], [cols[1][0], cols[1][1], cr]], bullets=sg,
                     source=src, refs=refs)
        for k, pg in enumerate(extra, len(pages) + 1):
            self.add(template='bullets', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, k, n),
                     bullets=pg, source=src, refs=refs)

    def table(self, s):
        d = s.data
        src = self.source(s)
        header = d['header'] if any(d['header']) else None
        note = d.get('note') or None
        pages = paginate_rows(d['rows'], header, s.title, self.lang, src, note)
        refs = self.refs(s)
        # kartadagi chegaralar diagrammasi (faqat kartadagi sonlar) — jadvaldan oldin
        blocks = vz.range_blocks(d.get('limits') or [])
        for i, b in enumerate(blocks, 1):
            self.add(template='range', title=s.title, eyebrow=eyebrow_with_page(s.eyebrow, i, len(blocks)),
                     range=b, source=src, refs=refs)
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
        if self.repo is not None:
            decorate(self.out, self.deck, self.repo)
        return self.out


def convert(deck, repo=None):
    return Conv(deck, repo).run()


# ----------------------------------------------------------------- rasmlar ----

def _deck_groups(repo, deck):
    """Deck mavzusi analitlarining guruhlari (tartib bilan)."""
    links = getattr(deck.day, 'links', None) or {}
    out = []
    for a in links.get('analytes', []):
        g = repo.an.get(a, {}).get('group')
        if g and g not in out:
            out.append(g)
    return out, links.get('reference', [])


def title_image(repo, deck, slides):
    """Sarlavha slaydi rasmi: xaritadagi aniq deck -> analit guruhi/Jadval -> deckning o'zidagi
    birinchi rasm (u allaqachon mavzuga tegishli, krediti bilan)."""
    did = deck.day.id
    rules = repo.images['rules']
    groups, refs = _deck_groups(repo, deck)
    for r in rules:
        if not r.get('side_only') and did in r.get('decks', []):
            return r['image'], vz.credit_text(r, deck.lang)
    for g in groups:
        for r in rules:
            if not r.get('side_only') and g in r.get('groups', []):
                return r['image'], vz.credit_text(r, deck.lang)
    for rid in refs:
        for r in rules:
            if not r.get('side_only') and rid in r.get('reference', []):
                return r['image'], vz.credit_text(r, deck.lang)
    for s in slides:
        if s.get('figure') and s.get('template') == 'figure':
            return s['figure'], s.get('credit')
    return None, None


def decorate(slides, deck, repo):
    """Sarlavha rasmi va kontent slaydlariga yon rasm (xarita bo'yicha, bir rasm deckda bir
    marta, faqat sig'sa) — data/slide_images.json."""
    lang = deck.lang
    did = deck.day.id
    img, credit = title_image(repo, deck, slides)
    if img and slides and slides[0].get('template') == 'title':
        slides[0]['figure'] = img
        if credit:
            slides[0]['credit'] = credit
    gnames = vz.group_names(repo, lang)
    rtitles = vz.reftopic_titles(repo, lang)
    rules = repo.images['rules']
    used = set()
    for s in slides[1:]:
        if s.get('template', 'bullets') != 'bullets' or s.get('plan') or s.get('compact') or 'source' not in s:
            continue
        parts = (s.get('eyebrow') or '').split(' · ')
        g = gnames.get(parts[0])
        rid = rtitles.get(parts[1]) if len(parts) > 1 and parts[0] == dc.T('ref_label', lang) else None
        for r in rules:
            if r['image'] in used:
                continue
            hit = (did in r.get('decks', []) or (g and g in r.get('groups', []))
                   or (rid and rid in r.get('reference', [])))
            if hit and side_fits(s['bullets'], s['title'], lang, s['source']):
                s['figure'] = r['image']
                s['credit'] = vz.credit_text(r, lang)
                used.add(r['image'])
                break


# -------------------------------------------------------------- yig'ish ----

def day_topic_ids(day):
    return [t['id'] for t in day.topics]


def deck_json(deck_id, lang, title, topics, slides, cats=None):
    """Deck JSON. Takrorlanuvchi manba qatorlari deck darajasidagi `srcs`
    jadvaliga olinadi (slaydda `src` indeksi) — hajmni ~1 MB ga kamaytiradi.
    `cats` — eyebrow boshlari (eyebrow_heads tartibida) kategoriyasi: ilova har bo'lim
    uchun aksent rangi va ikon tanlaydi (bo'sh satr — umumiy)."""
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
    if cats is not None:
        heads = eyebrow_heads(slim)
        if heads:
            j['cats'] = [cats.get(h, '') for h in heads]
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
            slides = convert(deck, repo)
            per_lang[lg] = deck_json(day.id, lg, day.title(lg), day_topic_ids(day), slides,
                                     vz.category_map(repo, lg))
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
            slides = convert(deck, repo)
            per_lang[lg] = deck_json(p['id'], lg, dc.L(p['title'], lg), [], slides,
                                     vz.category_map(repo, lg))
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
