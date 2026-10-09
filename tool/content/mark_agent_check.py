"""Kartalarga avtomatik (agent) tekshiruv yozuvini qo'shadi.

    python3 tool/content/mark_agent_check.py <hisobot.md> <id> [<id> ...]
        [--date YYYY-MM-DD] [--scope "..."] [--no-build]

Har bir analit kartasining `review.agent_checks` ro'yxatiga
`{"date", "scope", "report"}` yoziladi. Bu **mutaxassis tasdig'i emas**:
`status`, `content_state`, `review.state`, `reviewer_id`, `reviewed_at` va
`translation_review` ga tegilmaydi (karta `draft` bo'lib qoladi).

* Karta `content_src/additions/*.json` da bo'lsa — o'sha bo'lak faylga
  yoziladi (aks holda `build_core_pack.py` uni qayta yozib yuborardi);
  aks holda — to'g'ridan-to'g'ri `assets/content/core/pack.json` ga.
* Bir xil (sana, hisobot) yozuvi qayta qo'shilmaydi — skript idempotent.
* Sana berilmasa, hisobot fayli nomidagi `YYYY-MM-DD` olinadi.
* Oxirida `tool/build_core_pack.py` ishga tushiriladi (pack + manifest);
  `--no-build` bilan o'tkazib yuboriladi.
"""
import argparse
import datetime
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
PACK = ROOT / 'assets/content/core/pack.json'
ADDITIONS = ROOT / 'content_src/additions'
DEFAULT_SCOPE = (
    'sources opened and compared with claims; locators; numbers, units, '
    'specimen; RI/DL separation; uz/ru/en consistency'
)


def load(path: Path) -> dict:
    return json.loads(path.read_text())


def save(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=1) + '\n')


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('report', help='hisobot fayli (repo ichida), masalan docs/CONTENT_AUDIT_2026-10-09_A.md')
    ap.add_argument('ids', nargs='+', help='analit id lari')
    ap.add_argument('--date', help='YYYY-MM-DD (standart: hisobot nomidagi sana)')
    ap.add_argument('--scope', default=DEFAULT_SCOPE)
    ap.add_argument('--no-build', action='store_true')
    args = ap.parse_args(argv)

    report_path = (ROOT / args.report).resolve()
    if not report_path.is_file():
        sys.exit(f'hisobot topilmadi: {args.report}')
    report = report_path.relative_to(ROOT).as_posix()
    date = args.date
    if date is None:
        m = re.search(r'\d{4}-\d{2}-\d{2}', report_path.name)
        if not m:
            sys.exit('--date bering: hisobot nomida sana yo\'q')
        date = m.group(0)
    datetime.date.fromisoformat(date)  # noto'g'ri sana — xato
    if not args.scope.strip():
        sys.exit('--scope bo\'sh bo\'lmasin')
    if len(set(args.ids)) != len(args.ids):
        sys.exit('id lar takrorlangan')

    # Qaysi id qaysi faylda: avval bo'lak fayllar, keyin pack.json.
    files: dict[Path, dict] = {}
    owner: dict[str, Path] = {}
    for f in sorted(ADDITIONS.glob('*.json')):
        data = load(f)
        files[f] = data
        for a in data.get('analytes', []):
            owner.setdefault(a['id'], f)
    pack = load(PACK)
    files[PACK] = pack
    for a in pack['analytes']:
        owner.setdefault(a['id'], PACK)

    unknown = [i for i in args.ids if i not in owner]
    if unknown:
        sys.exit(f'noma\'lum analit(lar): {unknown}')

    entry = {'date': date, 'scope': args.scope, 'report': report}
    touched: set[Path] = set()
    added = 0
    for card_id in args.ids:
        f = owner[card_id]
        card = next(a for a in files[f]['analytes'] if a['id'] == card_id)
        review = card.setdefault('review', {'reviewer_id': None, 'reviewed_at': None, 'state': 'pending'})
        checks = review.setdefault('agent_checks', [])
        if any(c.get('date') == date and c.get('report') == report for c in checks):
            continue
        checks.append(dict(entry))
        touched.add(f)
        added += 1
    for f in touched:
        save(f, files[f])
    print(f'{added} ta yozuv qo\'shildi ({len(args.ids) - added} tasi avval bor edi); '
          f'fayllar: {sorted(p.relative_to(ROOT).as_posix() for p in touched)}')
    if touched and not args.no_build:
        subprocess.run([sys.executable, str(ROOT / 'tool/build_core_pack.py')], cwd=ROOT, check=True)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
