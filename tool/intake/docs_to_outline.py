"""Domla materiallari (Word) → mavzular ro'yxati, matn va jadvallar, kartalarga moslik.

    python3 tool/intake/docs_to_outline.py <materiallar_papkasi> <natija_papkasi>

- `.doc` fayllar LibreOffice bilan `.docx` ga o'giriladi (asl fayllar o'zgarmaydi).
- Har fayl uchun: `<nom>.md` (sarlavhalar, matn, jadvallar), umumiy `outline.json`
  (fayl → sarlavhalar, so'zlar soni, tilga oid belgi, topilgan analitlar).
- **PHI tekshiruvi**: bemor ma'lumotiga o'xshash joylar (to'liq ism-familiya
  shablonlari, tug'ilgan sana, pasport/JShShIR, telefon) `phi_report.md` ga — ular
  ilovaga kiritilishidan oldin olib tashlanishi kerak.
- Natija papkasi repodan **tashqarida** bo'lsin: muallif ruxsati olinmaguncha
  materiallar repoga qo'shilmaydi (docs/CONTENT_INTAKE.md).
"""
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import docx  # python-docx

ROOT = Path(__file__).resolve().parents[2]
PACK = ROOT / 'assets/content/core/pack.json'

PHI_PATTERNS = {
    'passport': re.compile(r'\b[A-ZА-Я]{2}\s?\d{7}\b'),
    'pinfl': re.compile(r'\b\d{14}\b'),
    'phone': re.compile(r'(?:\+?998[\s-]?)?\(?\d{2}\)?[\s-]?\d{3}[\s-]?\d{2}[\s-]?\d{2}\b'),
    'birth_date': re.compile(
        r'(?:tug[‘\'`ʻ]?ilgan|дата рождения|г\.?\s*р\.?|year of birth)[^\n]{0,20}\d{1,2}[./-]\d{1,2}[./-]\d{2,4}',
        re.IGNORECASE,
    ),
    'full_name': re.compile(
        r'\b[A-ZА-ЯЎҚҒҲ][a-zа-яўқғҳ‘’\']+\s+[A-ZА-ЯЎҚҒҲ][a-zа-яўқғҳ‘’\']+\s+'
        r'[A-ZА-ЯЎҚҒҲ][a-zа-яўқғҳ‘’\']+(?:ovich|evich|ovna|evna|o[‘’]g[‘’]li|qizi|ович|евич|овна|евна)\b'
    ),
}


def to_docx(src: Path, work: Path) -> Path:
    if src.suffix.lower() == '.docx':
        return src
    subprocess.run(
        ['soffice', '--headless', '--convert-to', 'docx', '--outdir', str(work), str(src)],
        check=True, capture_output=True, timeout=180,
    )
    return work / (src.stem + '.docx')


def table_md(table) -> str:
    rows = []
    for r in table.rows:
        cells = [c.text.strip().replace('\n', ' ').replace('|', '/') for c in r.cells]
        rows.append('| ' + ' | '.join(cells) + ' |')
    if len(rows) > 1:
        rows.insert(1, '|' + ' --- |' * len(table.rows[0].cells))
    return '\n'.join(rows)


def analyte_terms() -> dict[str, list[str]]:
    pack = json.loads(PACK.read_text())
    out = {}
    for a in pack['analytes']:
        terms = {*a['names'].values(), *a.get('synonyms', [])}
        out[a['id']] = sorted({t.lower() for t in terms if len(t) >= 3})
    return out


def main() -> None:
    src_dir, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    if ROOT in out_dir.resolve().parents or out_dir.resolve() == ROOT:
        sys.exit('Natija papkasi repodan tashqarida bo‘lsin.')
    out_dir.mkdir(parents=True, exist_ok=True)
    terms = analyte_terms()
    outline, phi = [], []
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        files = sorted(p for p in src_dir.rglob('*') if p.suffix.lower() in ('.doc', '.docx'))
        for f in files:
            try:
                d = docx.Document(str(to_docx(f, work)))
            except Exception as e:  # noqa: BLE001 — buzilgan fayl hisobotga yoziladi
                outline.append({'file': str(f.relative_to(src_dir)), 'error': str(e)})
                continue
            md, headings, text_all = [], [], []
            for block in d.element.body.iterchildren():
                tag = block.tag.rsplit('}', 1)[-1]
                if tag == 'p':
                    p = docx.text.paragraph.Paragraph(block, d)
                    t = p.text.strip()
                    if not t:
                        continue
                    style = (p.style.name or '').lower() if p.style is not None else ''
                    is_heading = style.startswith(('heading', 'заголовок', 'title')) or (
                        len(t) < 120 and all(r.bold for r in p.runs if r.text.strip())
                    )
                    if is_heading:
                        headings.append(t)
                        md.append(f'\n## {t}\n')
                    else:
                        md.append(t)
                    text_all.append(t)
                elif tag == 'tbl':
                    table = docx.table.Table(block, d)
                    md.append('\n' + table_md(table) + '\n')
                    text_all.append(' '.join(c.text for r in table.rows for c in r.cells))
            body = '\n'.join(text_all)
            low = body.lower()
            found = sorted(a for a, ts in terms.items() if any(t in low for t in ts))
            cyr = len(re.findall(r'[А-Яа-яЎўҚқҒғҲҳ]', body))
            lat = len(re.findall(r'[A-Za-z]', body))
            rel = f.relative_to(src_dir)
            (out_dir / (str(rel).replace('/', '__') + '.md')).write_text(
                f'# {rel}\n\n' + '\n'.join(md) + '\n')
            outline.append({
                'file': str(rel),
                'words': len(body.split()),
                'script': 'cyrillic' if cyr > lat else 'latin',
                'headings': headings[:200],
                'analytes': found,
            })
            for kind, rx in PHI_PATTERNS.items():
                for m in rx.finditer(body):
                    phi.append(f'- `{rel}` — {kind}: «{m.group(0)[:60]}»')
    (out_dir / 'outline.json').write_text(json.dumps(outline, ensure_ascii=False, indent=1))
    (out_dir / 'phi_report.md').write_text(
        '# Ehtimoliy shaxsiy ma’lumotlar (tekshirib olib tashlang)\n\n' +
        ('\n'.join(phi) if phi else 'Topilmadi (shablonlar bo‘yicha). Baribir ko‘z bilan tekshiring.') + '\n')
    print(f'{len(outline)} fayl; PHI belgilari: {len(phi)}; natija: {out_dir}')


if __name__ == '__main__':
    if len(sys.argv) != 3 or shutil.which('soffice') is None and not sys.argv[1:]:
        sys.exit(__doc__)
    main()
