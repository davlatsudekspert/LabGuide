"""Ma'ruza slaydlarining vizual shablonlari (ilova 16:9 kanvasi uchun) — HECH NARSA
O'YLAB TOPILMAYDI: har vizual faqat slaydning o'z matnidan yoki u keltirgan kartadan.

  stats   — bandda uchragan miqdorlar ("150–180 l birlamchi siydik") katta raqam
            kartalari sifatida; qiymat va yorliq — band matnidan SO'ZMA-SO'Z (substring),
            to'liq jumla ostida qoladi.
  range   — analit kartasidagi (pack.json decision_limits) chegaralar chiziqli o'qda:
            qiymat, birlik, aholi guruhi — faqat kartadan; manba — kartaning manbasi.
  steps   — raqamli bajarish tartibi ("1. … 2. …") — raqamli tugunlar va strelkalar;
            bir slaydda ko'pi bilan 6 qadam.
  split   — "Oshishi / Pasayishi" (yoki "Musbat / Manfiy") ikki ustun.
  tree    — "Yorliq: bandlar" ro'yxati (tasnif) — ildiz + shoxlar.
  example — manbadagi ishlangan misol (kalkulyator formulasi, protokol "Misol (…)").

Rasm xaritasi — data/slide_images.json (faqat repodagi mavjud rasmlar, kreditlari bilan).
"""
import re

import deck_content as dc

# ------------------------------------------------------- miqdorlar (stats) ----

_NUM = r'\d+(?:[.,]\d+)?'
_UNIT = (r'(?:%|‰|°C|×\s?10[⁰¹²³⁴⁵⁶⁷⁸⁹]+(?:/[A-Za-zµμлЛ]+)?'
         r'|mmol/mol|mmol/L|mmol/l|ммоль/л|µmol/L|µmol/l|мкмоль/л|mg/dL|mg/dl|мг/дл|g/dL|г/дл'
         r'|g/L|g/l|г/л|mg/L|mg/l|мг/л|mg/g|мг/г|ng/mL|нг/мл|pg/mL|пг/мл|µg/L|мкг/л|U/L|IU/L|Ед/л|МЕ/л'
         r'|fL|фл|µm|мкм|nm|нм|µL|мкл|mL|ml|мл|mm|мм'
         r'|soat\w*|daqiqa\w*|kun\w*|hafta\w*|час\w*|минут\w*|мин\b|сут\w*|дн[еяи]\w*|недел\w*'
         r'|hours?\b|minutes?\b|min\b|days?\b|weeks?\b|ayl/daq|об/мин|rpm'
         r'|l\b|L\b|л\b|g\b|г\b|mg\b|мг\b)(?![A-Za-zА-Яа-яЁё0-9/])')
# ixtiyoriy taqqoslash belgisi + son (+ oraliq) + birlik; oldida harf/raqam bo'lmasin
QUANT = re.compile(rf'(?<![\w.,/–-])((?:[<>≤≥~≈]\s?)?{_NUM}(?:\s?[–-]\s?{_NUM})?\s?{_UNIT})')
_STOP = set(',;:.()[]—–«»"“”')
STATS_MAX = 4
VALUE_MAX = 18          # karta qiymati (belgi) — uzunrog'i karta emas
LABEL_WORDS = 4


# Yorliq boshida/oxirida turmaydigan yordamchi so'zlar va qo'shimchalar (uz/ru/en).
FUNC = set("""
ni i da dan ga gacha li lik va yoki bilan uchun ichida keyin oldin davomida esa ham kabi bo‘lsa
в во на до после при через за и или около от из по к с со не чем
of at in on for or and to after before within than the a an by from with is are
""".split())


def _is_num_tok(w):
    return w[0] in '<>≤≥~≈' or any(ch.isdigit() or ch == '/' for ch in w)


def _words_after(text, end):
    """Miqdordan keyingi so'zlar; ([so'zlar], ishonchli). Ishonchsiz — ibora boshqa miqdorga
    borib taqalsa (u qaysi miqdorga tegishli ekani noaniq)."""
    words = []
    for w in text[end:].split():
        if w[0] in _STOP:
            return words, True
        if _is_num_tok(w):
            return words, False
        stop = w[-1] in _STOP
        w = w.rstrip(''.join(_STOP))
        if w:
            words.append(w)
        if stop or len(words) >= LABEL_WORDS:
            return words, True
    return words, True


def _words_before(text, start):
    words = []
    for w in reversed(text[:start].split()):
        if w[-1] in _STOP:
            return words, True
        if _is_num_tok(w):
            return words, False
        w = w.lstrip(''.join(_STOP))
        if w:
            words.insert(0, w)
        if len(words) >= LABEL_WORDS:
            return words, True
    return words, True


def _good(words):
    """Yordamchi so'zlar chetidan olib tashlanadi; kamida bitta mazmunli so'z (>= 3 harf)."""
    while words and words[0].lower() in FUNC:
        words = words[1:]
    while words and words[-1].lower() in FUNC:
        words = words[:-1]
    if not words or not any(sum(ch.isalpha() for ch in w) >= 3 and w.lower() not in FUNC for w in words):
        return None
    return ' '.join(words)


def quantities(text, lang='uz'):
    """[(qiymat, yorliq)] — ikkalasi ham matnning bo'lagi (so'zma-so'z). Yorliq — miqdor
    turgan iboradagi qisqa so'z birikmasi (tinish belgisigacha). Ikki miqdor ORASIDAGI
    so'zlar yorliq bo'lmaydi (qaysi miqdorga tegishli ekani noaniq) — bunday miqdor
    kartaga chiqmaydi."""
    out = []
    for m in QUANT.finditer(text):
        v = m.group(1).strip()
        if len(v) > VALUE_MAX:
            continue
        after, a_ok = _words_after(text, m.end(1))
        before, b_ok = _words_before(text, m.start(1))
        cands = []
        if a_ok:
            cands.append(after)
        if b_ok:
            # o'zbekchada aniqlovchi ko'pincha sondan oldin keladi ("erkaklarda 130 g/L")
            if lang == 'uz' and (not after or after[0].lower() in FUNC):
                cands.insert(0, before)
            else:
                cands.append(before)
        lab = None
        for c in cands:
            lab = _good(c)
            if lab and lab in text:
                break
            lab = None
        if lab:
            out.append((v, lab))
    return out


def stats_for(items, lang='uz'):
    """Sahifa bandlaridan kartalar: 2..STATS_MAX ta turli qiymat (bo'lmasa None)."""
    seen, cards = set(), []
    for t in items:
        for v, lab in quantities(t, lang):
            if v in seen:
                continue
            seen.add(v)
            cards.append([v, lab])
    if len(cards) < 2:
        return None
    return cards[:STATS_MAX]


def has_stats(items, lang='uz'):
    return stats_for(items, lang) is not None


# -------------------------------------------------------------- misollar ----

EXAMPLE_RE = re.compile(r'^(?:Misol|Пример|Example)\b[^:]{0,40}:\s.*(?:→|=)')


def is_example_item(t):
    return bool(EXAMPLE_RE.match(t))


# ---------------------------------------------------------- tasnif (tree) ----

LABEL_RE = re.compile(r'^([^:.;!?\n]{2,48}): (.+)$', re.S)
TREE_MIN, TREE_MAX = 3, 6


def tree_ok(items):
    if not TREE_MIN <= len(items) <= TREE_MAX:
        return False
    labs = []
    for t in items:
        m = LABEL_RE.match(t)
        if not m:
            return False
        labs.append(m.group(1))
    return len(set(labs)) == len(labs)


# ------------------------------------------------------- chegaralar (range) ----

RANGE_ROWS = 5


def range_blocks(limits):
    """Kartadagi chegaralar -> [{u, cap, rows}] (birlik bo'yicha, har sahifada <= RANGE_ROWS).
    Qator: [yorliq, izoh (aholi guruhi), past, yuqori, bayroq(1=past ochiq >,2=yuqori ochiq <),
    past matni, yuqori matni] — matnlar kartadagi son (deck_content.num) ko'rinishida."""
    by_unit = {}
    for x in limits:
        if x['low'] is None and x['high'] is None:
            continue
        by_unit.setdefault(x['unit'], []).append(x)
    out = []
    for unit, xs in by_unit.items():
        same = len({x['label'] for x in xs}) == 1 and len(xs) > 1
        rows = []
        for x in xs:
            lab, sub = (x['population'], None) if same else (x['label'], x['population'] or None)
            flags = (1 if x['low_exclusive'] else 0) | (2 if x['high_exclusive'] else 0)
            rows.append([lab, sub, x['low'], x['high'], flags, x['low_text'], x['high_text']])
        for k in range(0, len(rows), RANGE_ROWS):
            out.append({'u': unit, 'cap': xs[0]['label'] if same else None, 'rows': rows[k:k + RANGE_ROWS]})
    return out


# ------------------------------------------------------------ kategoriya ----

def category_map(repo, lang):
    """Eyebrow boshi (birinchi " · " gacha) -> kategoriya kaliti (ilova: ikon + rang)."""
    import practice_decks as pd
    m = {}
    for gid, names in repo.groups.items():
        m[dc.L(names, lang)] = gid
    for key, cat in (('qa_label', 'qa'), ('ref_label', 'reference'), ('cond_label', 'condition'),
                     ('cell_label', 'cells'), ('cell_pair', 'cells'), ('cell_find', 'cells'),
                     ('cell_tech', 'technique'), ('cyto_general', 'cytology'), ('cyto_label', 'cytology'),
                     ('atlas', 'atlas'), ('book_extra', 'book'), ('example', 'example')):
        m.setdefault(dc.T(key, lang).split(' · ')[0], cat)
    for key, names in pd.LABELS.items():
        m.setdefault(names[lang], 'p_' + key)
    return m


# ---------------------------------------------------------------- rasmlar ----

def credit_text(rule, lang):
    return dc.T(rule['credit'], lang)


def group_names(repo, lang):
    return {dc.L(names, lang): gid for gid, names in repo.groups.items()}


def reftopic_titles(repo, lang):
    return {dc.L(rt['title'], lang): rid for rid, rt in repo.reftopics.items()}
