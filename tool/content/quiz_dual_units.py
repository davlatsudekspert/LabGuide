"""Mashq va toifa izohlaridagi laboratoriya qiymatlarini qo'sh birlikka o'tkazadi.

    python3 tool/content/quiz_dual_units.py [--check] [--toifa-src <papka>]

Uslub (egasining qarori, 2026-10-10): SI birinchi, konvensional qavsda —
"7,0 mmol/L (126 mg/dL)"; uz/ru da o'nlik vergul, en da nuqta. Manba qiymatni
faqat konvensional birlikda bergan bo'lsa ham shu tartib: SI hisoblanadi,
qavsda manbadagi asl raqam (o'zgartirilmaydi, yaxlitlanmaydi).

Raqamlar shu skriptda hisoblanadi (qo'lda emas). Har bir tahrir — aniq eski
matn bo'lagi va shablon: `{glucose:140–199}` → "7,8–11,0 mmol/L (140–199
mg/dL)". Eski bo'lak topilmasa va yangisi allaqachon bo'lsa — o'tkazib
yuboriladi (idempotent); ikkalasi ham bo'lmasa — xato.

* Kontent paketi: savol `content_src/additions/*.json` da bo'lsa — o'sha
  faylga, aks holda `assets/content/core/pack.json` ga yoziladi. Keyin
  `tool/build_core_pack.py` ishga tushiriladi.
* Toifa banki: rasmiy `q`, `q_orig`, `options` ga tegilmaydi — faqat LabGuide
  izohi (`verdict_note_uz`) manba faylida tahrirlanadi va
  `tool/toifa/build_toifa.py` bilan asset qayta yig'iladi.
"""
import argparse
import json
import re
import subprocess
import sys
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
PACK = ROOT / 'assets/content/core/pack.json'
ADDITIONS = ROOT / 'content_src/additions'
TOIFA_SRC = Path(
    '/tmp/claude-0/-home-user/8dcb6164-a4cf-5bc3-a722-c55850a85847/scratchpad/toifa/out'
)
REPORT = 'docs/QUIZ_UNITS_2026-10-10.md'
DATE = '2026-10-10'

# Analitga xos rasmiy koeffitsientlar: konvensional → SI ko'paytuvchi.
# (SI birlik, konvensional birlik, ko'paytuvchi, SI xonalari, konv. xonalari)
# Ilovadagi `conversion` (molyar massa) bilan mosligi testda tekshiriladi:
# test/unit/quiz_units_test.dart.
ANALYTES = {
    # 1 mmol/L = 18,016 mg/dL (C6H12O6, 180,156 g/mol).
    'glucose': ('mmol/L', 'mg/dL', 1 / 18.016, 1, 0),
    # Gemoglobin / MCHC: g/dL × 10 = g/L.
    'hemoglobin': ('g/L', 'g/dL', 10, 0, 1),
    'mchc': ('g/L', 'g/dL', 10, 0, 0),
    # Umumiy oqsil: g/dL × 10 = g/L.
    'protein': ('g/L', 'g/dL', 10, 0, 1),
}
UNITS_RU = {'mmol/L': 'ммоль/л', 'mg/dL': 'мг/дл', 'g/L': 'г/л', 'g/dL': 'г/дл'}


def rnd(x: float, digits: int) -> Decimal:
    q = Decimal(1).scaleb(-digits)
    return Decimal(repr(x)).quantize(q, rounding=ROUND_HALF_UP)


def fmt(d: Decimal, lang: str) -> str:
    s = format(d, 'f')
    return s if lang == 'en' else s.replace('.', ',')


def unit(u: str, lang: str) -> str:
    return UNITS_RU.get(u, u) if lang == 'ru' else u


def parse_num(s: str) -> float:
    return float(s.replace(',', '.'))


def pair(analyte: str, spec: str, lang: str) -> str:
    """`spec` — qiymat(lar) manbadagi birlikda: "140–199" (konvensional) yoki
    "si:120" (manba SI da bergan — konvensional hisoblanadi)."""
    si_u, conv_u, f, si_d, conv_d = ANALYTES[analyte]
    from_si = spec.startswith('si:')
    raw = spec[3:] if from_si else spec
    parts = raw.split('–')
    si_s, conv_s = [], []
    for p in parts:
        v = parse_num(p)
        # Manbadagi asl raqam — matn bo'yicha aynan (faqat o'nlik belgisi tilga
        # moslanadi).
        orig = p.replace('.', ',') if lang != 'en' else p.replace(',', '.')
        if from_si:
            si_s.append(orig)
            conv_s.append(fmt(rnd(v / f, conv_d), lang))
        else:
            conv_s.append(orig)
            si_s.append(fmt(rnd(v * f, si_d), lang))
    return (f'{"–".join(si_s)} {unit(si_u, lang)} '
            f'({"–".join(conv_s)} {unit(conv_u, lang)})')


def hba1c_pair(percent: str, lang: str) -> str:
    """HbA1c: IFCC mmol/mol = 10,929 × (NGSP % − 2,15); % — asl raqam."""
    v = parse_num(percent)
    mmol = rnd(10.929 * (v - 2.15), 0)
    unit_s = 'ммоль/моль' if lang == 'ru' else 'mmol/mol'
    orig = percent.replace('.', ',') if lang != 'en' else percent.replace(',', '.')
    return f'{fmt(mmol, lang)} {unit_s} ({orig}%)'


TOKEN = re.compile(r'\{([a-z0-9]+):([^}]+)\}')


def render(template: str, lang: str) -> str:
    def sub(m: re.Match) -> str:
        a, spec = m.group(1), m.group(2)
        if a == 'hba1c':
            return hba1c_pair(spec, lang)
        return pair(a, spec, lang)
    return TOKEN.sub(sub, template)


# (savol id, maydon yo'li, til, eski bo'lak, yangi shablon)
QUIZ_EDITS = [
    # ogtt-q2 — NIDDK jadvali, glyukoza mg/dL da berilgan.
    ('ogtt-q2', 'prompt', 'uz',
     'NIDDKning 140–199 mg/dL (prediabet) va 200 mg/dL va undan yuqori (diabet) chegaralari',
     'NIDDKning prediabet uchun {glucose:140–199} va diabet uchun {glucose:200} va undan yuqori chegaralari'),
    ('ogtt-q2', 'prompt', 'ru',
     'пороги NIDDK 140–199 мг/дл (предиабет) и 200 мг/дл и выше (диабет)',
     'пороги NIDDK для предиабета {glucose:140–199} и для диабета {glucose:200} и выше'),
    ('ogtt-q2', 'prompt', 'en',
     'the NIDDK cutoffs of 140–199 mg/dL (prediabetes) and 200 mg/dL or above (diabetes)',
     'the NIDDK cutoffs of {glucose:140–199} for prediabetes and {glucose:200} or above for diabetes'),
    ('ogtt-q2', 'options.0.explanation', 'uz',
     'alohida chegaralar (100–125 va 126 mg/dL va undan yuqori) berilgan.',
     'alohida chegaralar berilgan: {glucose:100–125} va {glucose:126} va undan yuqori.'),
    ('ogtt-q2', 'options.0.explanation', 'ru',
     'отдельные пороги (100–125 и 126 мг/дл и выше).',
     'отдельные пороги: {glucose:100–125} и {glucose:126} и выше.'),
    ('ogtt-q2', 'options.0.explanation', 'en',
     'its own cutoffs in the table (100–125 and 126 mg/dL or above).',
     'its own cutoffs in the table: {glucose:100–125} and {glucose:126} or above.'),
]

# hemoglobin-q1 — JSST 2024, gemoglobin g/L da berilgan (SI asl).
for _lang, _u in (('uz', 'g/L'), ('ru', 'г/л'), ('en', 'g/L')):
    for _v in ('120', '130', '110'):
        QUIZ_EDITS.append(('hemoglobin-q1', 'basis', _lang,
                           f'< {_v} {_u}', f'< {{hemoglobin:si:{_v}}}'))
    for _i, _v in enumerate(('120', '130', '110')):
        QUIZ_EDITS.append((f'hemoglobin-q1', f'options.{_i}.text', _lang,
                           f'< {_v} {_u}', f'< {{hemoglobin:si:{_v}}}'))
QUIZ_EDITS += [
    ('hemoglobin-q1', 'options.0.explanation', 'uz',
     'chegara 120 g/L.', 'chegara {hemoglobin:si:120}.'),
    ('hemoglobin-q1', 'options.0.explanation', 'ru',
     'порог — 120 г/л.', 'порог — {hemoglobin:si:120}.'),
    ('hemoglobin-q1', 'options.0.explanation', 'en',
     'is 120 g/L.', 'is {hemoglobin:si:120}.'),
    # hemoglobin-q2 — balandlik tuzatishi (farq) g/L da.
    ('hemoglobin-q2', 'basis', 'uz',
     'Balandlik uchun tuzatish (1000–1499 m da 8 g/L) kuzatilgan',
     'Balandlik uchun tuzatish — 1000–1499 m da {hemoglobin:si:8} — kuzatilgan'),
    ('hemoglobin-q2', 'basis', 'ru',
     'Поправка на высоту (8 г/л для 1000–1499 м) вычитается',
     'Поправка на высоту — {hemoglobin:si:8} для 1000–1499 м — вычитается'),
    ('hemoglobin-q2', 'basis', 'en',
     'The altitude adjustment (8 g/L for 1000–1499 m) is subtracted',
     'The altitude adjustment — {hemoglobin:si:8} for 1000–1499 m — is subtracted'),
    ('hemoglobin-q2', 'options.1.text', 'uz',
     'Tuzatish (8 g/L) chegaraga qo‘shiladi',
     'Tuzatish — {hemoglobin:si:8} — chegaraga qo‘shiladi'),
    ('hemoglobin-q2', 'options.1.text', 'ru',
     'Поправка (8 г/л) добавляется к порогу',
     'Поправка — {hemoglobin:si:8} — добавляется к порогу'),
    ('hemoglobin-q2', 'options.1.text', 'en',
     'An adjustment (8 g/L) is added to the cutoff',
     'An adjustment — {hemoglobin:si:8} — is added to the cutoff'),
    # books-mchc-artefact — MCHC g/dL da berilgan.
    ('books-mchc-artefact', 'prompt', 'uz',
     'MCHC = 39 g/dL', 'MCHC = {mchc:39}'),
    ('books-mchc-artefact', 'prompt', 'ru',
     'MCHC = 39 г/дл', 'MCHC = {mchc:39}'),
    ('books-mchc-artefact', 'prompt', 'en',
     'MCHC 39 g/dL', 'MCHC {mchc:39}'),
    ('books-mchc-artefact', 'basis', 'uz',
     'MCHC 36–38 g/dL dan yuqori', 'MCHC {mchc:36–38} dan yuqori'),
    ('books-mchc-artefact', 'basis', 'ru',
     'MCHC выше 36–38 г/дл', 'MCHC выше {mchc:36–38}'),
    ('books-mchc-artefact', 'basis', 'en',
     'MCHC above 36–38 g/dL', 'MCHC above {mchc:36–38}'),
]

# (toifa id, eski bo'lak, yangi shablon) — faqat `verdict_note_uz` (uz).
TOIFA_EDITS = [
    ('kdl-t-109',
     'qayta so‘rish chegarasidan (~180 mg/dL ≈ 10 mmol/L) oshganda siydikka chiqadi – variantlar ichida faqat 11,9 mmol/L undan yuqori.',
     'qayta so‘rish chegarasidan — taxminan {glucose:180} — oshganda siydikka chiqadi – variantlar ichida faqat {glucose:si:11,9} undan yuqori.'),
    ('kdl-t-264',
     'StatPearls bo‘yicha 60–80 g/L; belgilangan 65–80 g/L –',
     'StatPearls bo‘yicha {protein:si:60–80}; belgilangan {protein:si:65–80} –'),
    ('kdl-t-451',
     'qonda doimo bo‘ladi (normal <5,7%), diabetning',
     'qonda doimo bo‘ladi, normal <{hba1c:5,7}; diabetning'),
]


def get_path(obj, path: str):
    for p in path.split('.'):
        obj = obj[int(p)] if isinstance(obj, list) else obj[p]
    return obj


def apply(text: str, old: str, new: str, where: str) -> tuple[str, bool]:
    # Yangi matn eski bo'lakni o'z ichiga olishi mumkin ("< 120 g/L" →
    # "< 120 g/L (12,0 g/dL)"), shuning uchun avval yangisi tekshiriladi.
    if new in text:
        return text, False
    if old in text:
        if text.count(old) != 1:
            sys.exit(f'{where}: eski bo\'lak bir necha marta uchradi: {old!r}')
        return text.replace(old, new), True
    sys.exit(f'{where}: eski bo\'lak ham, yangisi ham topilmadi: {old!r}')


def load(p: Path):
    return json.loads(p.read_text())


def quiz_owners() -> tuple[dict, dict]:
    files: dict[Path, dict] = {}
    owner: dict[str, Path] = {}
    for f in sorted(ADDITIONS.glob('*.json')):
        files[f] = load(f)
        for q in files[f].get('quiz', []):
            owner.setdefault(q['id'], f)
    files[PACK] = load(PACK)
    for q in files[PACK]['quiz']:
        owner.setdefault(q['id'], PACK)
    return files, owner


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--check', action='store_true', help='faqat ko\'rsatish, yozmaslik')
    ap.add_argument('--toifa-src', type=Path, default=TOIFA_SRC)
    args = ap.parse_args(argv)

    files, owner = quiz_owners()
    touched: set[Path] = set()
    changed_quiz: list[str] = []
    log = []
    for qid, path, lang, old, tmpl in QUIZ_EDITS:
        f = owner[qid]
        q = next(x for x in files[f]['quiz'] if x['id'] == qid)
        loc = get_path(q, path)
        new = render(tmpl, lang)
        loc[lang], did = apply(loc[lang], old, new, f'{qid}.{path}.{lang}')
        if did:
            touched.add(f)
            log.append((qid, f'{path}.{lang}', old, new))
            if qid not in changed_quiz:
                changed_quiz.append(qid)

    toifa_path = args.toifa_src / 'tests.json'
    tests = load(toifa_path)
    toifa_changed = []
    for tid, old, tmpl in TOIFA_EDITS:
        x = next(t for t in tests if t['id'] == tid)
        new = render(tmpl, 'uz')
        x['verdict_note_uz'], did = apply(x['verdict_note_uz'], old, new, tid)
        if did:
            toifa_changed.append(tid)
            log.append((tid, 'note.uz', old, new))
            changes = x.setdefault('audit', {}).setdefault('changes', [])
            msg = f'qo‘sh birlik (SI, konvensional qavsda) — {REPORT}'
            if msg not in changes:
                changes.append(msg)

    for qid, field, old, new in log:
        print(f'{qid} [{field}]\n  - {old}\n  + {new}')
    if args.check:
        return 0

    # review.agent_checks (mark_agent_check.py uslubida, mutaxassis tasdig'i emas).
    entry = {
        'date': DATE,
        'scope': 'dual units: SI first, conventional in parentheses; values '
                 'computed by tool/content/quiz_dual_units.py with '
                 'analyte-specific factors; source numbers kept; answer key unchanged',
        'report': REPORT,
    }
    for qid in changed_quiz:
        f = owner[qid]
        q = next(x for x in files[f]['quiz'] if x['id'] == qid)
        checks = q.setdefault('review', {}).setdefault('agent_checks', [])
        if not any(c.get('date') == DATE and c.get('report') == REPORT for c in checks):
            checks.append(dict(entry))
            touched.add(f)
    for f in touched:
        f.write_text(json.dumps(files[f], ensure_ascii=False, indent=1) + '\n')
    if toifa_changed:
        toifa_path.write_text(json.dumps(tests, ensure_ascii=False, indent=1))
    print(f'quiz: {changed_quiz}; toifa: {toifa_changed}')
    if touched:
        subprocess.run([sys.executable, str(ROOT / 'tool/build_core_pack.py')], cwd=ROOT, check=True)
    if toifa_changed:
        subprocess.run([sys.executable, str(ROOT / 'tool/toifa/build_toifa.py'),
                        '--src', str(args.toifa_src)], cwd=ROOT, check=True)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
