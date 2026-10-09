"""Asosiy kontent paketiga bo'lak (fragment) fayllarni qo'shadi.

    python3 tool/build_core_pack.py

`content_src/additions/*.json` — har biri bitta yo'nalish (masalan,
`hematology.json`), tuzilmasi pack.json bo'limlari bilan bir xil:
    {"groups": [...], "analytes": [...], "sources": [...], "quiz": [...],
     "conditions": [...], "library": [...]}
Yozuvlar `id` bo'yicha **upsert** qilinadi (bor bo'lsa — almashtiriladi,
yo'q bo'lsa — oxiriga qo'shiladi). Skript qayta-qayta ishga tushirilsa natija
bir xil. Keyin manifest qayta quriladi (`tool/build_content_manifest.dart`).

Bir nechta ishchi parallel kontent qo'shganda har biri faqat o'z bo'lak
faylini yozadi — pack.json'dagi to'qnashuv shu skriptni qayta ishga tushirib
hal qilinadi.
"""
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PACK = ROOT / 'assets/content/core/pack.json'
ADDITIONS = ROOT / 'content_src/additions'
SECTIONS = ('groups', 'analytes', 'sources', 'quiz', 'conditions', 'library')


def main() -> None:
    pack = json.loads(PACK.read_text())
    seen: dict[tuple[str, str], str] = {}
    for f in sorted(ADDITIONS.glob('*.json')):
        frag = json.loads(f.read_text())
        unknown = set(frag) - set(SECTIONS)
        if unknown:
            sys.exit(f'{f.name}: noma\'lum bo\'lim {sorted(unknown)}')
        for section in SECTIONS:
            items = frag.get(section, [])
            if not items:
                continue
            target = pack.setdefault(section, [])
            index = {item['id']: i for i, item in enumerate(target)}
            for item in items:
                key = (section, item['id'])
                if key in seen and seen[key] != f.name:
                    sys.exit(f'{section}/{item["id"]}: {seen[key]} va {f.name} da takror')
                seen[key] = f.name
                if item['id'] in index:
                    target[index[item['id']]] = item
                else:
                    index[item['id']] = len(target)
                    target.append(item)
    PACK.write_text(json.dumps(pack, ensure_ascii=False, indent=1) + '\n')
    subprocess.run(['dart', 'run', 'tool/build_content_manifest.dart'], cwd=ROOT, check=True)
    print('pack:', {s: len(pack.get(s, [])) for s in SECTIONS})


if __name__ == '__main__':
    main()
