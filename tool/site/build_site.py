#!/usr/bin/env python3
"""LabGuide statik sayti: maxfiylik siyosati sahifasini Markdown'dan yasaydi.

    python3 tool/site/build_site.py          # site/privacy/index.html
    python3 tool/site/build_site.py --logo   # + site/logo.png (Pillow kerak)

Manba: docs/store/PRIVACY_POLICY.md (uz/ru/en). Faqat standart kutubxona
(logo uchun ixtiyoriy Pillow). Qayta ishga tushirish xavfsiz: natija faqat
manbaga bog'liq (vaqt yoki tasodif yo'q), shuning uchun tool/site/check_site.py
sahifa eskirganini aniqlay oladi.

Ichki izohlar e'lon qilinmaydi:
* `> Eslatma ...` bilan boshlanadigan (yoki "e'lon qilishdan oldin" deydigan)
  iqtibos bloklari butunlay tashlanadi;
* `<!-- ... -->` izohlari tashlanadi.

Qo'llanadigan Markdown qismi: `#`/`##`/`###` sarlavhalar, paragraflar,
`- ` ro'yxatlar (2 bo'shliqli davom qatorlari bilan), `**qalin**`, `` `kod` ``,
`[matn](havola)`, qator oxiridagi `\\` (majburiy yangi qator). Email manzillari
avtomatik `mailto:` havolaga aylanadi.
"""

from __future__ import annotations

import argparse
import html
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'docs' / 'store' / 'PRIVACY_POLICY.md'
SITE = ROOT / 'site'
OUT = SITE / 'privacy' / 'index.html'
LOGO_SRC = ROOT / 'tool' / 'icons' / 'icon_1024.png'
LOGO_OUT = SITE / 'logo.png'

CONTACT = 'labguide@nfcstore.uz'

# h2 sarlavha -> bo'lim id si va til.
LANG_SECTIONS = {
    'O‘zbekcha': 'uz',
    'Русский': 'ru',
    'English': 'en',
}

TOC_LABEL = {'uz': 'Mundarija', 'ru': 'Содержание', 'en': 'Contents'}

INTERNAL_QUOTE = re.compile(r'^\s*(\*\*)?eslatma\b|e[’\']lon qilishdan oldin', re.IGNORECASE)
EMAIL = re.compile(r'(?<![\w.@/:-])([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})(?![\w@])')


# ------------------------------------------------------------------ inline
def inline(text: str) -> str:
    """Bitta qator ichidagi belgilash (avval HTML ekranlanadi)."""
    codes: list[str] = []

    def keep_code(m: re.Match[str]) -> str:
        codes.append(m.group(1))
        return f'\x00{len(codes) - 1}\x00'

    text = re.sub(r'`([^`]+)`', keep_code, text)
    links: list[tuple[str, str]] = []

    def keep_link(m: re.Match[str]) -> str:
        links.append((m.group(1), m.group(2)))
        return f'\x01{len(links) - 1}\x01'

    text = re.sub(r'\[([^\]]+)\]\(([^)\s]+)\)', keep_link, text)
    text = html.escape(text, quote=False)
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    text = EMAIL.sub(r'<a href="mailto:\1">\1</a>', text)

    def put_link(m: re.Match[str]) -> str:
        label, href = links[int(m.group(1))]
        return f'<a href="{html.escape(href)}">{inline(label)}</a>'

    text = re.sub(r'\x01(\d+)\x01', put_link, text)
    return re.sub(r'\x00(\d+)\x00', lambda m: f'<code>{html.escape(codes[int(m.group(1))])}</code>', text)


def para(lines: list[str]) -> str:
    """Paragraf: qatorlar bo'shliq bilan qo'shiladi; `\\` bilan tugasa — <br>."""
    out = []
    for i, ln in enumerate(lines):
        ln = ln.strip()
        hard = ln.endswith('\\')
        if hard:
            ln = ln[:-1].rstrip()
        out.append(inline(ln) + ('<br>\n' if hard and i < len(lines) - 1 else '\n' if i < len(lines) - 1 else ''))
    return ''.join(out)


# ------------------------------------------------------------------ blocks
def strip_internal(md: str) -> str:
    """HTML izohlari va ichki "Eslatma" iqtiboslarini olib tashlaydi."""
    md = re.sub(r'<!--.*?-->', '', md, flags=re.DOTALL)
    out: list[str] = []
    quote: list[str] = []

    def flush() -> None:
        # Blokning birinchi matnli qatori ichki belgi bo'lsa — butun blok tashlanadi.
        first = next((q.lstrip('>').strip() for q in quote if q.lstrip('>').strip()), '')
        if quote and not INTERNAL_QUOTE.search(first):
            out.extend(quote)
        quote.clear()

    for ln in md.splitlines():
        if ln.startswith('>'):
            quote.append(ln)
            continue
        flush()
        out.append(ln)
    flush()
    return '\n'.join(out) + '\n'


def slug_h3(lang: str, title: str, seen: set[str]) -> str:
    m = re.match(r'(\d+)\.', title)
    base = f'{lang}-{m.group(1)}' if m else f'{lang}-intro'
    sid, n = base, 2
    while sid in seen:
        sid, n = f'{base}-{n}', n + 1
    seen.add(sid)
    return sid


def render(md: str) -> tuple[str, str]:
    """(sarlavha, asosiy HTML) qaytaradi."""
    md = strip_internal(md)
    lines = md.splitlines()
    title = 'LabGuide'
    parts: list[str] = []
    seen: set[str] = set()
    lang: str | None = None
    section: list[str] = []
    toc: list[tuple[str, str]] = []
    i = 0

    def target() -> list[str]:
        return section if lang else parts

    def close_section() -> None:
        nonlocal section, toc
        if lang is None:
            return
        name = next(k for k, v in LANG_SECTIONS.items() if v == lang)
        body = [f'<section id="{lang}" lang="{lang}">\n<h2>{html.escape(name)}</h2>\n']
        if toc:
            body.append(f'<details class="toc"><summary>{TOC_LABEL[lang]}</summary>\n<ul>\n')
            body.extend(f'<li><a href="#{sid}">{inline(t)}</a></li>\n' for sid, t in toc)
            body.append('</ul>\n</details>\n')
        body.extend(section)
        body.append('</section>\n')
        parts.extend(body)
        section, toc = [], []

    while i < len(lines):
        ln = lines[i]
        s = ln.strip()
        if not s:
            i += 1
            continue
        if s.startswith('# '):
            title = s[2:].strip()
            i += 1
            continue
        if s.startswith('## '):
            name = s[3:].strip()
            close_section()
            if name in LANG_SECTIONS:
                lang = LANG_SECTIONS[name]
            else:
                lang = None
                parts.append(f'<h2>{inline(name)}</h2>\n')
            i += 1
            continue
        if s.startswith('### '):
            t = s[4:].strip()
            if lang:
                sid = slug_h3(lang, t, seen)
                toc.append((sid, t))
                target().append(f'<h3 id="{sid}">{inline(t)}</h3>\n')
            else:
                target().append(f'<h3>{inline(t)}</h3>\n')
            i += 1
            continue
        if s.startswith('> '):
            block = []
            while i < len(lines) and lines[i].startswith('>'):
                block.append(lines[i].lstrip('>').strip())
                i += 1
            target().append(f'<blockquote><p>{para(block)}</p></blockquote>\n')
            continue
        if s.startswith('- '):
            items: list[list[str]] = []
            while i < len(lines):
                cur = lines[i]
                if cur.startswith('- '):
                    items.append([cur[2:]])
                elif cur.startswith('  ') and cur.strip() and items:
                    items[-1].append(cur.strip())
                else:
                    break
                i += 1
            target().append('<ul>\n' + ''.join(f'<li>{para(it)}</li>\n' for it in items) + '</ul>\n')
            continue
        block = []
        while i < len(lines) and lines[i].strip() and not re.match(r'(#{1,3} |- |> )', lines[i].strip()):
            block.append(lines[i])
            i += 1
        cls = ' class="meta"' if lang is None and not parts else ''
        target().append(f'<p{cls}>{para(block)}</p>\n')
    close_section()
    return title, ''.join(parts)


# ---------------------------------------------------------------- template
PAGE = """<!doctype html>
<html lang="uz">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title_short}</title>
<meta name="description" content="LabGuide maxfiylik siyosati — Политика конфиденциальности — Privacy Policy.">
<meta name="color-scheme" content="light dark">
<link rel="icon" href="../logo.png">
<link rel="stylesheet" href="../style.css">
</head>
<body>
<!-- Bu fayl avtomatik yasalgan: python3 tool/site/build_site.py (manba: docs/store/PRIVACY_POLICY.md). Qo'lda tahrirlamang. -->
<a class="skip" href="#main">Asosiy matnga o‘tish</a>
<header class="top">
<div class="wrap">
<a class="brand" href="../index.html"><img src="../logo.png" alt="" width="36" height="36">LabGuide</a>
<ul class="langs" aria-label="Til / Язык / Language">
<li><a href="#uz" hreflang="uz">UZ</a></li>
<li><a href="#ru" hreflang="ru">RU</a></li>
<li><a href="#en" hreflang="en">EN</a></li>
</ul>
</div>
</header>
<main id="main" class="wrap">
<h1>{title}</h1>
{body}</main>
<footer class="foot">
<div class="wrap">
<nav aria-label="Sayt">
<a href="../index.html">LabGuide</a>
<a href="index.html">Maxfiylik · Конфиденциальность · Privacy</a>
<a href="../delete-account/index.html">Hisobni o‘chirish · Удаление аккаунта · Delete account</a>
</nav>
<p>Aloqa · Контакт · Contact: <a href="mailto:{contact}">{contact}</a></p>
</div>
</footer>
</body>
</html>
"""


def build_privacy(source: Path = SOURCE) -> str:
    title, body = render(source.read_text(encoding='utf-8'))
    return PAGE.format(
        title=inline(title),
        title_short='LabGuide — Privacy Policy',
        body=body,
        contact=CONTACT,
    )


def build_logo() -> None:
    try:
        from PIL import Image
    except ImportError:
        sys.exit('Pillow topilmadi: pip install pillow (yoki --logo siz ishga tushiring)')
    im = Image.open(LOGO_SRC).convert('RGB').resize((192, 192), Image.LANCZOS)
    q = im.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG)
    q.save(LOGO_OUT, optimize=True)
    print(f'yozildi: {LOGO_OUT.relative_to(ROOT)}')


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--logo', action='store_true', help='site/logo.png ni ham qayta yasash (Pillow)')
    args = ap.parse_args()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(build_privacy(), encoding='utf-8')
    print(f'yozildi: {OUT.relative_to(ROOT)}')
    if args.logo:
        build_logo()


if __name__ == '__main__':
    main()
