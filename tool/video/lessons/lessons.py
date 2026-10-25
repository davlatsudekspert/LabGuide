#!/usr/bin/env python3
"""Apparat sinflari bo‘yicha ilmiy video-dars REJALARI (docs/video/lessons/).

Bu skript video yasamaydi. U faqat:

1. `build` — har dars faylidagi avtomatik bloklarni qayta yozadi:
   * `<!-- auto:parts-list KEY PREFIX -->` … `<!-- /auto:parts-list -->` —
     sxemadagi raqamli belgilar ro‘yxati (uz nomi, RU/EN nomi);
   * `<!-- auto:epistemic-parts KEY PREFIX -->` … `<!-- /auto:epistemic-parts -->` —
     har qism vazifasi, ishlash prinsipi (PR) va natija (RS) bayonotlari
     epistemik teg bilan. Yagona manba — tool/illustrations/schematic/parts_src.py
     (ilovadagi “Qismlari va ishlash prinsipi” paneli bilan bir xil matn);
   * docs/video/lessons/README.md dagi `<!-- auto:index -->` jadvali —
     sahnalar soni, davomiylik va teglar soni HAR FAYLDAN HISOBLANADI.
2. `check` — qoidalarni tekshiradi (xato bo‘lsa exit 1):
   * 32 ta sxema kaliti darslarda qamralgan; har kalitning har raqamli belgisi
     storyboard “Ekranda” ustunida kamida bir marta bor;
   * har dars bir xil bo‘lim tuzilmasida; holat — EXPERT_REVIEW_PENDING;
   * davomiylik 180–360 s; diktor matni ≤ 2,5 so‘z/s;
   * keltirilgan har [ID] epistemik jadvalda bor; “Manbaga ko‘ra” deyilgan joyda
     kamida bitta SOURCED bayonot keltirilgan; STANDARD_TEXTBOOK yoki
     NEEDS_EXPERT bayonotga tayangan diktor matni / bosqich matni / xato
     bandida “umumiy tamoyil bo‘yicha” iborasi bo‘lishi shart;
   * matndagi har raqam keltirilgan SOURCED bayonot matnida ham bo‘lishi shart
     (belgi raqamlari “3-belgi” ko‘rinishida yoziladi va hisobga olinmaydi);
   * ishlab chiqaruvchi / model nomi faqat SOURCED bayonotda bo‘lsa;
   * SOURCED qatordagi manba id lari catalog.json `sources` da bor;
     `lab_cards[<id>].<maydon>` havolasi mavjud va o‘sha maydon manbasi
     qatorda ko‘rsatilgan;
   * ilova havolalari (`/lab/...`) mavjud marshrutlar;
   * namunaviy animatsiya subtitrlari (tool/video/lessons/sample_*.json) dars
     jadvalidagi ID larga tayanadi va xuddi shu qoidalarga bo‘ysunadi.

    python3 tool/video/lessons/lessons.py build
    python3 tool/video/lessons/lessons.py check
"""
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
DOCS = os.path.join(ROOT, 'docs', 'video', 'lessons')
sys.path.insert(0, os.path.join(ROOT, 'tool', 'illustrations', 'schematic'))
from parts_src import PARTS, TB  # noqa: E402

CATALOG = json.load(open(os.path.join(ROOT, 'assets', 'instruments', 'catalog.json'), encoding='utf-8'))
SOURCE_IDS = {s['id'] for s in CATALOG['sources']}
LAB_CARDS = {c['id']: c for c in CATALOG['lab_cards']}
CATEGORIES = {c['id'] for c in CATALOG['categories']}

TAGS = ('SOURCED', 'STANDARD_TEXTBOOK', 'NEEDS_EXPERT')
HEDGE = 'umumiy tamoyil bo‘yicha'

# Avtomatik qatorlarda TB (darslik) bo‘lsa ham NEEDS_EXPERT ga ko‘tariladigan
# bayonotlar (sabab docs/video/lessons/README.md “Topilmalar”). Raqamli TB matn
# avtomatik NEEDS_EXPERT bo‘ladi.
NEEDS_EXPERT_OVERRIDES = {
    ('mass_spec_gc', 'C9'): 'mutlaq ibora (“urilmaydi”) va nasos turlari manbasiz',
    ('mass_spec_lc', 'C8'): 'vakuum tuzilmasi manbasiz',
    ('microbial_id_ast', 'C3'): 'vakuum bilan to‘ldirish — muayyan dizayn, manbasiz',
    ('real_time_pcr', 'C5'): 'filtr g‘ildiragi — optik dizaynlardan biri, manbasiz',
    ('cartridge_molecular', 'C2'): 'kartrij ichki tuzilmasi manbasiz',
}

# Bir darsdagi bir nechta kalit uchun prefikslar (ID: PREFIX-C3).
SECTIONS = [
    '## 1. O‘quv maqsadlari',
    '## 2. Maqsadli auditoriya',
    '## 3. Davomiylik',
    '## 4. Storyboard',
    '## 5. Olti majburiy bosqich',
    '## 6. Keng tarqalgan xatolar, xavfsizlik va QC',
    '## 7. O‘z-o‘zini tekshirish savollari',
    '## 8. Epistemik holat',
]
STAGES = ['### 5.1', '### 5.2', '### 5.3', '### 5.4', '### 5.5', '### 5.6']

# Ilovadagi mavjud marshrutlar (lib/app/router.dart, 541d853 da tekshirilgan).
ROUTES = {
    '/lab', '/lab/qc', '/lab/qc/eqa', '/lab/qc/rejected', '/lab/qc/critical', '/lab/calibration',
    '/lab/calibration/log', '/lab/preanalytics', '/lab/instruments', '/lab/calculators',
    '/lab/calculators/units', '/lab/calculators/dilution', '/lab/microscopy', '/lab/urinalysis',
    '/lab/urinalysis/collect', '/lab/urinalysis/strip', '/lab/urinalysis/sediment', '/lab/urinalysis/reader',
    '/lab/coagulogram', '/lab/coagulogram/sample', '/lab/coagulogram/tests', '/lab/coagulogram/reader',
    '/lab/bloodgroup', '/lab/bloodgroup/methods', '/lab/bloodgroup/errors', '/lab/bloodgroup/quality',
    '/lab/bloodgroup/reader', '/lab/spermogram', '/lab/spermogram/preanalytics', '/lab/spermogram/assess',
    '/lab/differential', '/lab/bloodmorph', '/lab/bloodmorph/quality', '/lab/coprology',
}

BRANDS = ['Mindray', 'Roche', 'Abbott', 'HUMAN', 'Cepheid', 'GeneXpert', 'Xpert', 'BACTEC', 'MGIT 960',
          'VITEK', 'bioMérieux', 'Bruker', 'cobas', 'Alinity', 'ARCHITECT', 'CELL-DYN', 'HumaCount',
          'Sysmex', 'Beckman', 'Siemens', 'Thermo', 'Agilent', 'Waters', 'Shimadzu']

_OG = re.compile(r"(?<=[oOgG])'(?=[A-Za-z])")
_TUTUQ = re.compile(r"(?<=[A-Za-z])'(?=[A-Za-z])")


def uz_norm(s):
    return _TUTUQ.sub('’', _OG.sub('‘', s))


def cell(s):
    return s.replace('|', '\\|').replace('\n', ' ')


def lesson_files():
    return sorted(f for f in os.listdir(DOCS) if re.match(r'\d\d_.*\.md$', f))


# ------------------------------------------------------------------ auto rows
def auto_tag(key, rid, src, text):
    cat = [s for s in src if s != TB]
    if (key, rid) in NEEDS_EXPERT_OVERRIDES:
        return 'NEEDS_EXPERT', f'parts_src: TB; {NEEDS_EXPERT_OVERRIDES[(key, rid)]}' + (
            f'; qisman manba: {", ".join(cat)}' if cat else '')
    if TB not in src:
        return 'SOURCED', ', '.join(f'`{s}`' for s in cat)
    note = 'parts_src: TB (darslik, mutaxassis tasdig‘isiz)' + (
        f'; qisman manba: {", ".join(f"`{s}`" for s in cat)}' if cat else '')
    if re.search(r'\d', text):
        return 'NEEDS_EXPERT', note + '; raqam darslik manbasiz'
    return 'STANDARD_TEXTBOOK', note


def auto_rows(key, prefix):
    p = f'{prefix}-' if prefix else ''
    rows = []
    for n, part in enumerate(PARTS[key]['parts'], 1):
        rid = f'C{n}'
        text = uz_norm(f"{part['uz'][0]} — {part['uz'][1]}")
        tag, where = auto_tag(key, rid, part['src'], text)
        rows.append((p + rid, text, tag, f'{where}; `schematic_parts.json` → `{key}` #{n}'))
    for rid, field in (('PR', 'principle'), ('RS', 'result')):
        t = PARTS[key][field]
        text = uz_norm(t['uz'])
        tag, where = auto_tag(key, rid, t['src'], text)
        rows.append((p + rid, text, tag, f'{where}; `schematic_parts.json` → `{key}`.{field}'))
    return rows


def render_epistemic(key, prefix):
    out = ['| ID | Bayonot (uz) | Teg | Manba va joyi |', '|---|---|---|---|']
    for rid, text, tag, where in auto_rows(key, prefix):
        out.append(f'| {rid} | {cell(text)} | {tag} | {cell(where)} |')
    return '\n'.join(out)


def render_parts_list(key, prefix):
    p = f'{prefix}-' if prefix else ''
    out = ['| Belgi | Qism (uz) | RU | EN | Bayonot |', '|---|---|---|---|---|']
    for n, part in enumerate(PARTS[key]['parts'], 1):
        out.append(f"| {n} | {uz_norm(part['uz'][0])} | {part['ru'][0]} | {part['en'][0]} | {p}C{n} |")
    return '\n'.join(out)


AUTO = re.compile(r'(<!-- auto:(parts-list|epistemic-parts) (\w+)(?: (\w+))? -->)\n(.*?)\n?(<!-- /auto:\2 -->)', re.S)


def build_file(path):
    md = open(path, encoding='utf-8').read()

    def rep(m):
        kind, key, prefix = m.group(2), m.group(3), m.group(4) or ''
        body = render_parts_list(key, prefix) if kind == 'parts-list' else render_epistemic(key, prefix)
        return m.group(1) + '\n' + body + '\n' + m.group(6)

    new = AUTO.sub(rep, md)
    if new != md:
        open(path, 'w', encoding='utf-8').write(new)
    return new


# ------------------------------------------------------------------ parsing
def section(md, head):
    i = md.index(head)
    j = md.find('\n## ', i + len(head))
    return md[i:j if j >= 0 else len(md)]


def table_rows(text):
    rows = []
    for ln in text.splitlines():
        if ln.startswith('|') and not re.match(r'\|\s*-', ln):
            cells = [c.strip() for c in re.split(r'(?<!\\)\|', ln.strip())[1:-1]]
            rows.append(cells)
    return rows


def parse(path):
    md = open(path, encoding='utf-8').read()
    info = {'file': os.path.basename(path), 'md': md}
    info['keys'] = re.findall(r'<!-- auto:parts-list (\w+)', md)
    info['title'] = md.splitlines()[0].lstrip('# ').strip()
    ep = {}
    for r in table_rows(section(md, SECTIONS[7])):
        if len(r) == 4 and r[0] != 'ID':
            ep[r[0]] = {'text': r[1], 'tag': r[2], 'where': r[3]}
    info['ep'] = ep
    scenes = []
    for r in table_rows(section(md, SECTIONS[3])):
        if len(r) == 7 and r[0] != '#':
            scenes.append({'n': r[0], 'screen': r[1], 'anim': r[2], 'say': r[3], 'terms': r[4],
                           'ids': re.findall(r'[A-Z0-9]+(?:-[A-Z0-9]+)?', r[5]), 'sec': float(r[6])})
    info['scenes'] = scenes
    return info


def cited(text):
    return [i.strip() for grp in re.findall(r'\[([A-Z0-9,\s\-]+)\]', text) for i in grp.split(',') if i.strip()]


NUM = re.compile(r'(?<![A-Za-z\d])\d+(?:[.,]\d+)?(?![A-Za-z\d])')  # CD4, K3EDTA, 7H9 — nom, raqam emas


def numbers(text):
    t = re.sub(r'\d+(?:[–-]\d+)?-belgi\w*', ' ', text)
    t = re.sub(r'\[[A-Z0-9,\s\-]+\]', ' ', t)
    t = re.sub(r'`[^`]*`', ' ', t)
    t = re.sub(r'\b[A-Z]{1,3}-?C\d+\b', ' ', t)
    return NUM.findall(t)


# ------------------------------------------------------------------ checks
def check():
    errs, warns = [], []
    covered = {}
    infos = []
    for f in lesson_files():
        info = parse(os.path.join(DOCS, f))
        infos.append(info)
        md, ep = info['md'], info['ep']
        e = lambda m: errs.append(f'{f}: {m}')  # noqa: E731
        pos = -1
        for head in SECTIONS:
            p = md.find(head)
            if p < pos:
                e(f'bo‘lim yo‘q yoki tartib buzilgan: {head}')
            pos = max(pos, p)
        for st in STAGES:
            if st not in md:
                e(f'bosqich yo‘q: {st}')
        if 'EXPERT_REVIEW_PENDING' not in md:
            e('holat EXPERT_REVIEW_PENDING yozilmagan')
        if re.search(r'expert[- ]approved|EXPERT_APPROVED|mutaxassis tasdiqlagan', md, re.I):
            e('“mutaxassis tasdiqlagan” degan ibora bor')
        if not info['keys']:
            e('auto:parts-list bloki yo‘q')
        for k in info['keys']:
            covered.setdefault(k, []).append(f)
        # epistemik jadval
        for rid, row in ep.items():
            if row['tag'] not in TAGS:
                e(f'{rid}: noma’lum teg {row["tag"]}')
            if row['tag'] == 'SOURCED':
                ids = re.findall(r'`([a-z0-9][a-z0-9\-]+)`', row['where'])
                srcs = [i for i in ids if i in SOURCE_IDS]
                if not srcs:
                    e(f'{rid}: SOURCED, lekin catalog sources id yo‘q')
                for card, field in re.findall(r'lab_cards\[([\w\-]+)\]\.(\w+)', row['where']):
                    c = LAB_CARDS.get(card)
                    if c is None or c.get(field) in (None, []):
                        e(f'{rid}: lab_cards[{card}].{field} yo‘q')
                        continue
                    v = c[field]
                    fsrc = set(v.get('sources', [])) if isinstance(v, dict) else {
                        s for x in v for s in x.get('sources', [])}
                    if not fsrc & set(srcs):
                        e(f'{rid}: lab_cards[{card}].{field} manbasi ({sorted(fsrc)}) qatorda yo‘q')
        # storyboard
        total = 0.0
        callouts = {}
        for sc in info['scenes']:
            total += sc['sec']
            for m in re.finditer(r'(?:(\w+)\s+)?(\d+)(?:–(\d+))?-belgi', sc['screen']):
                a, b = int(m.group(2)), int(m.group(3) or m.group(2))
                callouts.setdefault('*', set()).update(range(a, b + 1))
            for m in re.finditer(r'`(\w+)`\s*:\s*([\d–, ]+)-belgi', sc['screen']):
                for part in m.group(2).split(','):
                    a, _, b = part.strip().partition('–')
                    if a:
                        callouts.setdefault(m.group(1), set()).update(range(int(a), int(b or a) + 1))
            words = len(sc['say'].split())
            if words > 2.5 * sc['sec'] + 0.5:
                e(f'sahna {sc["n"]}: {words} so‘z / {sc["sec"]:g} s — diktor uchun juda ko‘p')
            check_text(e, f'sahna {sc["n"]}', sc['say'], sc['ids'], ep)
        info['total'] = total
        m = re.search(r'storyboard bo‘yicha (\d+):(\d\d)', section(md, SECTIONS[2]))
        if not m or int(m.group(1)) * 60 + int(m.group(2)) != round(total):
            e(f'3-bo‘limda “storyboard bo‘yicha {fmt(total)}” yozilishi kerak')
        if not 180 <= total <= 360:
            e(f'davomiylik {total:g} s (180–360 bo‘lishi kerak)')
        for k in info['keys']:
            n = len(PARTS[k]['parts'])
            have = callouts.get(k, set()) | (callouts.get('*', set()) if len(info['keys']) == 1 else set())
            miss = sorted(set(range(1, n + 1)) - have)
            if miss:
                e(f'{k}: storyboardda ko‘rsatilmagan belgilar {miss}')
        # bosqich matnlari, xatolar, savollar
        for head in (SECTIONS[4], SECTIONS[5], SECTIONS[6]):
            for para in re.split(r'\n(?=### |- |\d+\. )', section(md, head)):
                if '<!--' in para or para.startswith('| '):
                    continue
                para = '\n'.join(ln for ln in para.splitlines() if not ln.startswith('#'))
                para = re.sub(r'^\d+\.\s', '', para)
                ids = cited(para)
                check_text(e, head[:5] + ' ' + para[:40].replace('\n', ' '), para, ids, ep, need_ids=False)
        for route in re.findall(r'`(/lab[^`\s]*)`', md):
            ok = route in ROUTES or re.fullmatch(r'/lab/instruments/lc/([\w\-]+)', route) and \
                route.rsplit('/', 1)[1] in LAB_CARDS or re.fullmatch(r'/lab/instruments/c/(\w+)', route) and \
                route.rsplit('/', 1)[1] in CATEGORIES
            if not ok:
                e(f'mavjud bo‘lmagan marshrut: {route}')
    # namunaviy animatsiyalar: subtitrlar dars jadvaliga mos bo‘lishi kerak
    by_file = {i['file']: i for i in infos}
    for sp in sorted(f for f in os.listdir(os.path.dirname(__file__)) if re.match(r'sample_\w+\.json$', f)):
        data = json.load(open(os.path.join(os.path.dirname(__file__), sp), encoding='utf-8'))
        info = by_file.get(os.path.basename(data['lesson']))
        if info is None:
            errs.append(f'{sp}: dars fayli topilmadi')
            continue
        for k, sc in enumerate(data['scenes'], 1):
            scene_rows = [info['ep'][i] for i in sc['ids'] if i in info['ep']]
            if len(scene_rows) != len(sc['ids']):
                errs.append(f'{sp} sahna {k}: dars jadvalida yo‘q ID {sc["ids"]}')
            callout_nums = {str(n) for n in sc.get('cycle', []) + sc.get('focus', [])}
            for c in sc['captions']:
                rows = scene_rows
                if 'ids' in c:
                    rows = [info['ep'][i] for i in c['ids'] if i in info['ep']]
                    if len(rows) != len(c['ids']) or not set(c['ids']) <= set(sc['ids']):
                        errs.append(f'{sp} sahna {k}: subtitr ID lari {c["ids"]} sahna/dars jadvalida yo‘q')
                uz = ' '.join(c['uz'].split()).lower()
                if any(r['tag'] != 'SOURCED' for r in rows) and 'umumiy tamoyil' not in uz:
                    errs.append(f'{sp} sahna {k}: TB/NEEDS_EXPERT bayonot, lekin subtitrda “Umumiy tamoyil” yo‘q')
                if 'manbaga ko‘ra' in uz and not any(r['tag'] == 'SOURCED' for r in rows):
                    errs.append(f'{sp} sahna {k}: “Manbaga ko‘ra”, lekin SOURCED bayonot yo‘q')
                src_text = ' '.join(r['text'] for r in rows if r['tag'] == 'SOURCED')
                for num in numbers(c['uz']):
                    if num not in src_text and num not in callout_nums:  # “1 gaz ballon” — belgi raqami
                        errs.append(f'{sp} sahna {k}: raqam {num} SOURCED bayonotda yo‘q')
    allkeys = set(PARTS)
    miss = sorted(allkeys - set(covered))
    if miss:
        errs.append(f'darsda qamralmagan sxema kalitlari: {miss}')
    for w in warns:
        print('OGOHLANTIRISH', w)
    for x in errs:
        print('XATO', x)
    print(f'{len(infos)} dars, {len(set(covered))}/{len(allkeys)} kalit, xato: {len(errs)}')
    return infos, errs


def check_text(e, where, text, ids, ep, need_ids=True):
    missing = [i for i in ids if i not in ep]
    if missing:
        e(f'{where}: epistemik jadvalda yo‘q ID {missing}')
    rows = [ep[i] for i in ids if i in ep]
    if any(r['tag'] != 'SOURCED' for r in rows) and HEDGE not in ' '.join(text.split()).lower():
        e(f'{where}: darslik/NEEDS_EXPERT bayonot “{HEDGE}” iborasisiz')
    src_text = ' '.join(r['text'] for r in rows if r['tag'] == 'SOURCED')
    if 'manbaga ko‘ra' in ' '.join(text.split()).lower() and not src_text:
        e(f'{where}: “Manbaga ko‘ra” deyilgan, lekin SOURCED bayonot keltirilmagan')
    for num in numbers(text):
        if num not in src_text:
            e(f'{where}: raqam {num} SOURCED bayonotda yo‘q')
    for b in BRANDS:
        if re.search(r'\b' + re.escape(b) + r'\b', text) and b not in src_text:
            e(f'{where}: “{b}” nomi SOURCED bayonotsiz')


# ------------------------------------------------------------------ index
def fmt(sec):
    return f'{int(sec // 60)}:{int(round(sec % 60)):02d}'


def index(infos):
    out = ['| # | Dars (fayl) | Sxema kalit(lar)i | Sahna | Davomiylik | SOURCED | STANDARD_TEXTBOOK | NEEDS_EXPERT |',
           '|---|---|---|---|---|---|---|---|']
    tot = [0, 0, 0, 0, 0.0]
    for i, info in enumerate(infos, 1):
        c = [sum(1 for r in info['ep'].values() if r['tag'] == t) for t in TAGS]
        out.append(f"| {i} | [{cell(info['title'])}]({info['file']}) | "
                   f"{', '.join(f'`{k}`' for k in info['keys'])} | {len(info['scenes'])} | "
                   f"{fmt(info['total'])} | {c[0]} | {c[1]} | {c[2]} |")
        tot[0] += len(info['scenes'])
        tot[1] += c[0]
        tot[2] += c[1]
        tot[3] += c[2]
        tot[4] += info['total']
    nkeys = len({k for info in infos for k in info['keys']})
    out.append(f'| | **Jami: {len(infos)} dars, {nkeys} kalit** | | **{tot[0]}** | **{fmt(tot[4])}** | '
               f'**{tot[1]}** | **{tot[2]}** | **{tot[3]}** |')
    return '\n'.join(out)


def build():
    for f in lesson_files():
        build_file(os.path.join(DOCS, f))
    infos, errs = check()
    readme = os.path.join(DOCS, 'README.md')
    if os.path.exists(readme):
        md = open(readme, encoding='utf-8').read()
        new = re.sub(r'(<!-- auto:index -->)\n(.*?)\n?(<!-- /auto:index -->)',
                     lambda m: m.group(1) + '\n' + index(infos) + '\n' + m.group(3), md, flags=re.S)
        if new != md:
            open(readme, 'w', encoding='utf-8').write(new)
    return errs


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'check'
    errs = build() if cmd == 'build' else check()[1]
    sys.exit(1 if errs else 0)
