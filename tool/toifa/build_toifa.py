#!/usr/bin/env python3
"""Toifa (malaka toifasi) imtihoniga tayyorgarlik — ilova assetlarini yig'ish.

Kirish (tayyorlangan, tekshirilgan ma'lumot; repoga kirmaydi):
  <src>/tests.json — test savollari (rasmiy ro'yxat, kalit + LabGuide tekshiruvi)
  <src>/oral.json  — og'zaki savollar (toifalar, LabGuide javob rejasi)
Chiqish:
  assets/toifa/kdl_tests.json, assets/toifa/kdl_oral.json

Faqat ilovaga kerakli maydonlar yoziladi (asl matnlar `q_orig`, `options_orig`,
javoblar fayllari belgilari va h.k. kirmaydi). Validatsiyada xato bo'lsa —
fayllar yozilmaydi.

  python3 tool/toifa/build_toifa.py [--src <papka>]
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SRC = Path(
    '/tmp/claude-0/-home-user/8dcb6164-a4cf-5bc3-a722-c55850a85847/scratchpad/toifa/out'
)
OUT = ROOT / 'assets' / 'toifa'

TOPICS = [
    'safety_ethics', 'qc_lab_management', 'preanalytics', 'hematology_cells',
    'hemopoiesis_leukemia', 'anemias', 'hemostasis',
    'biochemistry_proteins_enzymes', 'carbohydrates_diabetes', 'lipids',
    'liver_pigments', 'kidney_nitrogen', 'water_electrolytes_acid_base',
    'minerals_vitamins', 'hormones', 'urinalysis', 'stool_coprology',
    'csf_body_fluids', 'sputum_tb', 'cytology_gyn', 'std_microscopy',
    'parasitology', 'immunology_serology', 'molecular_pcr', 'tumor_markers',
    'cardiac_markers', 'orphan_screening', 'other',
]
CATEGORIES = ['3-2', '1', 'oliy']
VERDICTS = {'ok', 'disputed', 'ambiguous'}
ORAL_STATUS = {'draft', 'todo', 'needs_expert'}
TEST_STATUS = {None, 'draft', 'ok', 'needs_expert'}

# Egasining qarori bilan aniqlashtirilguncha baholanadigan bilet/imtihon
# tanlovidan chiqarilgan yozuvlar (asl matn o'zgarmaydi, ro'yxatda
# "aniqlashtirilmoqda" bilan ko'rinadi). `status: needs_expert` ham shunday.
HELD = {
    'kdl-o-283': "savol matni aniqlashtirilmoqda (ehtimol 'qin disbakteriozi')",
}
ID_T = re.compile(r'^kdl-t-\d{3}$')
ID_O = re.compile(r'^kdl-o-\d{3}$')
ANALYTE = re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')

errors: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


LETTERS = 'ABCD'
VARIANT_REF = re.compile(r'\b((?:[0-3](?:, | va ))*[0-3])(-| )(variant)')
PAREN_REF = re.compile(r'\(([0-3])\)')


def letters(m: re.Match) -> str:
    refs = re.sub(r'[0-3]', lambda d: LETTERS[int(d.group(0))], m.group(1))
    return f'{refs} {m.group(3)}'


def clean_note(note: str) -> str:
    """Ichki (parser) izohlari foydalanuvchiga ko'rsatilmaydi. Tayyorlovchi
    variantlarni 0 dan sanagan ("1 va 3 variantlar") — ilovada variantlar
    A–D harflari bilan ko'rsatiladi, shuning uchun harfga o'giriladi."""
    parts = re.split(r'(?<=[.!?])\s+', note.strip())
    keep = [p for p in parts if p and not p.startswith('Parser')]
    out = ' '.join(keep).strip()
    out = VARIANT_REF.sub(letters, out)
    return PAREN_REF.sub(lambda m: f'({LETTERS[int(m.group(1))]})', out)


def refs_of(raw, where: str) -> list:
    out = []
    for r in raw or []:
        url = (r.get('url') or '').strip()
        if not url.startswith('https://'):
            err(f'{where}: manba URL https emas: {url!r}')
            continue
        item = {'url': url}
        loc = (r.get('locator') or '').strip()
        if loc:
            item['locator'] = loc
        out.append(item)
    return out


def text(v, where: str) -> str:
    if not isinstance(v, str) or not v.strip():
        err(f"{where}: bo'sh matn")
        return ''
    return v.strip()


def build_tests(src: list) -> list:
    out, seen, numbers = [], set(), set()
    for x in src:
        qid = x.get('id', '?')
        if not ID_T.match(qid) or qid in seen:
            err(f"test id noto'g'ri yoki takror: {qid}")
        seen.add(qid)
        n = x.get('n')
        if not isinstance(n, int) or n in numbers:
            err(f"{qid}: raqam noto'g'ri yoki takror: {n}")
        numbers.add(n)
        options = [text(o, f'{qid} variant') for o in x.get('options', [])]
        # Rasmiy formatda 4 variant; bitta savolda asl hujjatda 3 ta qolgan
        # (parse_fix bilan izohlangan) — faqat shu holatga ruxsat.
        if len(options) != 4 and not (len(options) == 3 and x.get('parse_fix')):
            err(f"{qid}: variantlar soni {len(options)} (4 bo'lishi kerak)")
        if len(set(options)) != len(options):
            err(f'{qid}: takror variant')
        key = x.get('key', [])
        if len(key) > 1:
            err(f'{qid}: bir nechta kalit — rasmiy formatda bitta')
        for k in key:
            if not isinstance(k, int) or not 0 <= k < len(options):
                err(f"{qid}: kalit indeksi {k} variantlar oralig'idan tashqarida")
        status = x.get('status')
        if status not in TEST_STATUS:
            err(f'{qid}: holat {status!r}')
        verdict = x.get('verdict')
        if verdict not in VERDICTS:
            err(f'{qid}: verdict {verdict!r}')
        if not key and verdict == 'ok':
            err(f'{qid}: kalitsiz savol "ok" bo\'la olmaydi')
        topic = x.get('topic')
        if topic not in TOPICS:
            err(f'{qid}: mavzu {topic!r}')
        note = clean_note(x.get('verdict_note_uz') or '')
        if verdict != 'ok' and not note:
            err(f"{qid}: {verdict} uchun izoh yo'q")
        suggested = x.get('key_suggested')
        if suggested is not None:
            for k in suggested:
                if not isinstance(k, int) or not 0 <= k < len(options):
                    err(f"{qid}: taklif indeksi {k} noto'g'ri")
        analytes = x.get('analyte_ids') or []
        for a in analytes:
            if not ANALYTE.match(a):
                err(f'{qid}: analit id {a!r}')
        item = {
            'id': qid,
            'n': n,
            'q': text(x.get('q'), f'{qid} savol'),
            'options': options,
            'key': key,
            'topic': topic,
            'verdict': verdict,
        }
        if note:
            item['note'] = note
        # Manba bilan tasdiqlanmagan izoh: belgilanadi, taklif esa javob
        # sifatida ko'rsatilmaydi (ilova ham tekshiradi).
        unverified = bool(x.get('note_unverified'))
        if unverified:
            item['unverified'] = True
        if suggested and verdict != 'ok':
            item['suggested'] = sorted(suggested)
        refs = refs_of(x.get('refs'), qid)
        if refs:
            item['refs'] = refs
        if analytes:
            item['analytes'] = analytes
        if status == 'needs_expert':
            item['held'] = 'mutaxassis tekshiruvi kerak'
        checked = (x.get('audit') or {}).get('checked_at')
        if checked:
            item['checked'] = checked
        out.append(item)
    out.sort(key=lambda i: i['n'])
    return out


# "Referens interval" va "diagnostik chegara" ma'lumotda ajratilgan bo'lsa,
# ilovada alohida bloklarda ko'rsatiladi. Qabul qilinadigan shakllar:
#  - alohida maydonlar: `reference_uz` / `cutoffs_uz` (satrlar ro'yxati);
#  - `plan_uz` bandi obyekt: {"kind": "reference"|"cutoff", "text": "..."};
#  - tuzilgan `reference_intervals[]` / `decision_limits[]` (manba bilan).
# Eski (ajratilmagan) format ham o'qiladi — barcha bandlar rejada qoladi.


def split_plan(x: dict, oid: str):
    plan, reference, cutoffs = [], [], []
    for p in x.get('plan_uz') or []:
        if isinstance(p, dict):
            kind = p.get('kind')
            t = text(p.get('text'), f'{oid} reja')
            if kind == 'reference':
                reference.append(t)
            elif kind == 'cutoff':
                cutoffs.append(t)
            elif kind in (None, 'plan'):
                plan.append(t)
            else:
                err(f'{oid}: reja bandi turi {kind!r}')
            continue
        # Matnli bandlar rejada qoladi: manbasiz ajratib olinmaydi (referens
        # va chegaralar `reference_intervals` / `decision_limits` dan keladi).
        plan.append(text(p, f'{oid} reja'))
    for field, target in (('reference_uz', reference), ('cutoffs_uz', cutoffs)):
        for t in x.get(field) or []:
            target.append(text(t, f'{oid} {field}'))
    return plan, reference, cutoffs


def ref_one(r, where: str):
    if not r:
        return None
    got = refs_of([r], where)
    return got[0] if got else None


def opt(d: dict, key: str):
    v = d.get(key)
    return v.strip() if isinstance(v, str) and v.strip() else None


def build_reference(x: dict, oid: str) -> list:
    out = []
    for r in x.get('reference_intervals') or []:
        item = {
            'analyte': text(r.get('analyte'), f'{oid} RI analit'),
            'value': text(r.get('value_text'), f'{oid} RI qiymat'),
        }
        for k_in, k_out in (('unit', 'unit'), ('population', 'population'),
                            ('specimen', 'specimen'), ('note', 'note')):
            if v := opt(r, k_in):
                item[k_out] = v
        link = ref_one(r.get('ref'), f'{oid} RI')
        if link is None:
            err(f"{oid}: referens interval manbasiz")
        else:
            item['ref'] = link
        out.append(item)
    return out


def build_cutoffs(x: dict, oid: str) -> list:
    out = []
    for r in x.get('decision_limits') or []:
        item = {
            'criterion': text(r.get('criterion'), f'{oid} DL mezon'),
            'value': text(r.get('value_text'), f'{oid} DL qiymat'),
        }
        for k in ('unit', 'guideline'):
            if v := opt(r, k):
                item[k] = v
        if 'guideline' not in item:
            err(f"{oid}: diagnostik chegara qo'llanmasiz")
        link = ref_one(r.get('ref'), f'{oid} DL')
        if link is None:
            err(f"{oid}: diagnostik chegara manbasiz")
        else:
            item['ref'] = link
        out.append(item)
    return out


def build_pitfalls(x: dict, oid: str) -> list:
    structured = x.get('pitfalls')
    if structured:
        out = []
        for p in structured:
            refs = refs_of(p.get('refs'), f'{oid} xato')
            verified = bool(p.get('verified')) and bool(refs)
            item = {
                'wrong': text(p.get('wrong_uz'), f'{oid} xato'),
                'right': text(p.get('right_uz'), f'{oid} xato'),
                'verified': verified,
            }
            if refs:
                item['refs'] = refs
            out.append(item)
        return out
    # Eski format: tuzilmagan matn (manba bilan tasdiqlanmagan deb olinadi).
    return [
        {'text': text(p, f'{oid} xato'), 'verified': False}
        for p in x.get('pitfalls_uz') or []
    ]


def build_oral(src: list) -> list:
    out, seen = [], set()
    for x in src:
        oid = x.get('id', '?')
        if not ID_O.match(oid) or oid in seen:
            err(f"og'zaki id noto'g'ri yoki takror: {oid}")
        seen.add(oid)
        cats = x.get('categories') or []
        if not cats or any(c not in CATEGORIES for c in cats):
            err(f'{oid}: toifalar {cats!r}')
        topic = x.get('topic')
        if topic not in TOPICS:
            err(f'{oid}: mavzu {topic!r}')
        status = x.get('status')
        if status not in ORAL_STATUS:
            err(f'{oid}: holat {status!r}')
        plan, reference, cutoffs = split_plan(x, oid)
        refs = refs_of(x.get('refs'), oid)
        if status == 'draft' and (
            len(plan) + len(reference) + len(cutoffs) < 3 or not refs
        ):
            err(f"{oid}: draft rejada kamida 3 band va manba bo'lishi kerak")
        item = {
            'id': oid,
            'q': text(x.get('q'), f'{oid} savol'),
            'categories': [c for c in CATEGORIES if c in cats],
            'topic': topic,
            'status': status,
            'plan': plan,
        }
        # Eski matnli bandlar ham obyektga aylantiriladi.
        reference = [{'value': t} for t in reference] + build_reference(x, oid)
        cutoffs = [{'value': t} for t in cutoffs] + build_cutoffs(x, oid)
        if reference:
            item['reference'] = reference
        if cutoffs:
            item['cutoffs'] = cutoffs
        pitfalls = build_pitfalls(x, oid)
        if pitfalls:
            item['pitfalls'] = pitfalls
        held = HELD.get(oid) or (
            'mutaxassis tekshiruvi kerak' if status == 'needs_expert' else None)
        if held:
            item['held'] = held
        checked = (x.get('audit') or {}).get('checked_at')
        if checked:
            item['checked'] = checked
        if refs:
            item['refs'] = refs
        note = (x.get('note') or '').strip()
        if note:
            item['note'] = note
        analytes = x.get('analyte_ids') or []
        for a in analytes:
            if not ANALYTE.match(a):
                err(f'{oid}: analit id {a!r}')
        if analytes:
            item['analytes'] = analytes
        out.append(item)
    out.sort(key=lambda i: i['id'])
    for c in CATEGORIES:
        n = sum(1 for i in out if c in i['categories'] and 'held' not in i)
        if n < 5:
            err(f'toifa {c}: biletga {n} ta savol (kamida 5 kerak)')
    return out


def dump(obj) -> str:
    return json.dumps(obj, ensure_ascii=False, separators=(',', ':')) + '\n'


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--src', type=Path, default=DEFAULT_SRC)
    args = ap.parse_args()
    tests = build_tests(json.loads((args.src / 'tests.json').read_text()))
    oral = build_oral(json.loads((args.src / 'oral.json').read_text()))
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        print(f"{len(errors)} ta xato — fayllar yozilmadi", file=sys.stderr)
        return 1
    # Kelib chiqish: agent tekshiruvi sanasi (mutaxassis tasdig'i emas).
    checked = max(
        [i['checked'] for i in tests + oral if 'checked' in i], default=None)
    meta = {'version': 1, 'topics': TOPICS, 'audit_checked_at': checked}
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / 'kdl_tests.json').write_text(dump({**meta, 'questions': tests}))
    (OUT / 'kdl_oral.json').write_text(
        dump({**meta, 'categories': CATEGORIES, 'questions': oral}))
    keyless = sum(1 for t in tests if not t['key'])
    held = [i['id'] for i in tests + oral if 'held' in i]
    print(f"test: {len(tests)} (kalitsiz {keyless}), og'zaki: {len(oral)}, "
          f"tekshiruv: {checked}, chiqarilgan: {held}")
    for c in CATEGORIES:
        print(f"  toifa {c}: {sum(1 for i in oral if c in i['categories'])}")
    return 0


if __name__ == '__main__':
    sys.exit(main())
