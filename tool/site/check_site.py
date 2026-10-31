#!/usr/bin/env python3
"""LabGuide statik saytini tekshiradi (faqat standart kutubxona).

    python3 tool/site/check_site.py              # site/ ni tekshiradi
    python3 tool/site/check_site.py --self-test  # tekshiruvchining o'zini sinaydi

Xato topilsa, nol bo'lmagan kod bilan tugaydi. Tekshiriladi:
* ko'rinadigan matnda ichki izoh (katta harfli "Eslatma" so'zi — kichik harfli
  "eslatma" oddiy so'z; "e'lon qilishdan oldin"),
  TODO, repo ichki yo'llari (docs/, lib/, cloudflare/) va qaror raqamlari (D-41);
* D-77 (`paid/pro-premium` tarmog'i; D-58 o'rniga): narx literali ($4.99,
  12 000 so'm, …) hech bir sahifada yo'q — narx faqat do'kondan; sinov muddati
  faqat 30 kun (D-80; "7 kunlik sinov" — eskirgan); to'lov/obuna so'zlari (Pro, obuna,
  subscription, payment va h.k.) faqat `privacy/` va `terms/` sahifalarida (ular
  `docs/store/PRIVACY_POLICY.md` va `docs/store/TERMS_OF_USE.md` dan yasaladi —
  qo'lda qo'shilgan bo'lim "eskirgan" xatosi bilan ushlanadi), boshqa
  sahifalarda taqiqlangan;
* nisbiy havolalar: fayl mavjudligi va `#id` mavjudligi; tashqi resurslar
  (CSS, rasm, skript, shrift) taqiqlangan; `/` bilan boshlanuvchi havola
  taqiqlangan (sayt `/labguide/` ostida ishlashi kerak);
* har sahifada `<html lang>`, `<title>`, viewport;
* `site/privacy/index.html` va `site/terms/index.html` ularning manbasi
  (`docs/store/PRIVACY_POLICY.md`, `docs/store/TERMS_OF_USE.md`) bilan mos
  (eskirgan bo'lsa — `python3 tool/site/build_site.py`); ikkalasida uch til
  bo'limi bor.
"""

from __future__ import annotations

import argparse
import re
import sys
import tempfile
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
SITE = ROOT / 'site'

sys.path.insert(0, str(HERE))
import build_site  # noqa: E402

# (nom, regex) — ko'rinadigan matnga (va title/alt/aria-label/description ga).
BANNED: list[tuple[str, re.Pattern[str]]] = [
    # Katta harf bilan: ichki blok "Eslatma (...)" deb boshlanadi; kichik harfli
    # "eslatma" esa oddiy so'z (kunlik savol eslatmasi) — uni taqiqlash ma'nosiz.
    ('ichki izoh: Eslatma', re.compile(r'\bEslatma\b|\bESLATMA\b')),
    ('ichki izoh: e’lon qilishdan oldin', re.compile(r'e[’\'‘`ʻ]lon qilishdan oldin', re.IGNORECASE)),
    ('TODO', re.compile(r'\b(todo|tbd|fixme)\b', re.IGNORECASE)),
    ('Pro', re.compile(r'\bpro\b', re.IGNORECASE)),
    ('obuna', re.compile(r'\bobuna', re.IGNORECASE)),
    ('subscription', re.compile(r'subscri', re.IGNORECASE)),
    ('payment', re.compile(r'\b(payment|purchase|premium)', re.IGNORECASE)),
    ('to‘lov', re.compile(r'\bto[’\'‘`ʻ]lov', re.IGNORECASE)),
    ('оплата/подписка', re.compile(r'(оплат|подписк|платёж|платеж|премиум)', re.IGNORECASE)),
    ('repo yo‘li', re.compile(r'(?<![\w.])(docs|lib|cloudflare|tool)/[\w./-]+')),
    ('qaror raqami', re.compile(r'\bD-\d{2}\b')),
    # D-77: narx faqat do'kondan (ilovada ham, saytda ham qotirilmaydi).
    ('narx literali', re.compile(
        r'[$€£]\s?\d|\d\s?(usd|uzs|сум)\b|\b(usd|uzs)\s?\d|\d\s?so[’\'‘`ʻ]m\b', re.IGNORECASE)),
    # D-80: sinov faqat 30 kun; "7 kunlik sinov" — SUPERSEDED (D-77, 2026-10-31 gacha).
    ('sinov 30 kun emas', re.compile(
        r'\b(?!30\b)\d+[\s\u00a0-]*(kun(lik)?\s+(bepul\s+)?sinov|days?\s+(free\s+)?trial|'
        r'дн\w*\s+(бесплатн\w*\s+)?(пробн|доступ))|'
        r'(sinov|trial|пробн\w*\s+период\w*)\s+(на\s+|of\s+)?(?!30\b)\d+[\s\u00a0-]*(kun|days?|дн)',
        re.IGNORECASE)),
]

# D-77: to'lov/obuna so'zlari faqat shu sahifalarda (manbasi nazoratda:
# privacy — docs/store/PRIVACY_POLICY.md, terms — docs/store/TERMS_OF_USE.md,
# "eskirgan" tekshiruvi bilan).
SUBSCRIPTION_WORDS = {'Pro', 'obuna', 'subscription', 'payment', 'to‘lov', 'оплата/подписка'}
SUBSCRIPTION_TEXT_PAGES = {'privacy/index.html', 'terms/index.html'}

# Generatsiya qilinadigan sahifalar: (sayt yo'li, builder, manba).
GENERATED_PAGES = (
    ('privacy', 'build_privacy', 'SOURCE'),
    ('terms', 'build_terms', 'TERMS_SOURCE'),
)

# Ichki (inline) skriptga ruxsat etilgan sahifalar.
SCRIPT_PAGES = {'j/index.html'}

RESOURCE_ATTRS = {('link', 'href'), ('img', 'src'), ('script', 'src'), ('source', 'src'), ('iframe', 'src')}
TEXT_ATTRS = {'title', 'alt', 'aria-label'}


class Page(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.text: list[str] = []
        self.ids: set[str] = set()
        self.refs: list[tuple[str, str, str]] = []  # (tag, attr, url)
        self.scripts = 0
        self.html_lang = False
        self.title = False
        self.viewport = False
        self._skip = 0

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        a = {k: (v or '') for k, v in attrs}
        if tag in ('script', 'style'):
            self._skip += 1
        if tag == 'script':
            self.scripts += 1
        if tag == 'html' and a.get('lang'):
            self.html_lang = True
        if tag == 'title':
            self.title = True
        if tag == 'meta' and a.get('name') == 'viewport':
            self.viewport = True
        if tag == 'meta' and a.get('name') == 'description':
            self.text.append(a.get('content', ''))
        if 'id' in a:
            self.ids.add(a['id'])
        for k in TEXT_ATTRS:
            if a.get(k):
                self.text.append(a[k])
        for k in ('href', 'src'):
            if k in a:
                self.refs.append((tag, k, a[k]))

    def handle_endtag(self, tag: str) -> None:
        if tag in ('script', 'style') and self._skip:
            self._skip -= 1

    def handle_data(self, data: str) -> None:
        if not self._skip:
            self.text.append(data)


def parse(path: Path) -> Page:
    p = Page()
    p.feed(path.read_text(encoding='utf-8'))
    p.close()
    return p


def check_site(site: Path, check_fresh: bool = True) -> list[str]:
    errors: list[str] = []
    pages = sorted(site.rglob('*.html'))
    if not pages:
        return [f'{site}: HTML sahifa topilmadi']
    parsed = {p.resolve(): parse(p) for p in pages}

    for path, page in parsed.items():
        rel = path.relative_to(site.resolve())
        if not page.html_lang:
            errors.append(f'{rel}: <html lang> yo‘q')
        if not page.title:
            errors.append(f'{rel}: <title> yo‘q')
        if not page.viewport:
            errors.append(f'{rel}: viewport meta yo‘q')
        # JavaScript faqat taklif sahifasida (j/: ?c= kodini ko'rsatish, tashqi
        # so'rovsiz); qolgan sahifalar JS siz.
        if page.scripts and rel.as_posix() not in SCRIPT_PAGES:
            errors.append(f'{rel}: <script> taqiqlangan (faqat {", ".join(sorted(SCRIPT_PAGES))})')
        text = ' '.join(' '.join(page.text).split())
        for name, rx in BANNED:
            if name in SUBSCRIPTION_WORDS and rel.as_posix() in SUBSCRIPTION_TEXT_PAGES:
                continue
            for m in rx.finditer(text):
                ctx = text[max(0, m.start() - 40): m.end() + 40]
                errors.append(f'{rel}: taqiqlangan ({name}): …{ctx}…')
        for tag, attr, url in page.refs:
            errors.extend(f'{rel}: {e}' for e in check_ref(site.resolve(), path, page, parsed, tag, attr, url))

    for extra in ('robots.txt', 'style.css', 'logo.png'):
        if not (site / extra).is_file():
            errors.append(f'{extra} yo‘q')
    css = site / 'style.css'
    if css.is_file():
        body = css.read_text(encoding='utf-8')
        if re.search(r'url\(\s*[\'"]?(https?:)?//', body) or '@import' in body:
            errors.append('style.css: tashqi resurs (url(//…) yoki @import)')
        if 'prefers-color-scheme: dark' not in body:
            errors.append('style.css: qorong‘i mavzu (prefers-color-scheme) yo‘q')

    if check_fresh:
        for name, builder, source in GENERATED_PAGES:
            out = site / name / 'index.html'
            fresh = getattr(build_site, builder)()
            if not out.is_file():
                errors.append(f'{name}/index.html yo‘q: python3 tool/site/build_site.py ni ishga tushiring')
            elif out.read_text(encoding='utf-8') != fresh:
                errors.append(f'{name}/index.html eskirgan: python3 tool/site/build_site.py ni ishga tushiring')
            src_path: Path = getattr(build_site, source)
            src = src_path.read_text(encoding='utf-8')
            for lang in ('uz', 'ru', 'en'):
                if f'<section id="{lang}" lang="{lang}">' not in fresh:
                    errors.append(f'{name}: “{lang}” bo‘limi yo‘q')
            if re.search(r'^>\s*\**eslatma', src, re.IGNORECASE | re.MULTILINE):
                errors.append(f'{src_path.name}: ichki “Eslatma” bloki bor (GitHub’da ham ommaviy) — '
                              'PRIVACY_OPEN_QUESTIONS.md ga ko‘chiring')
    return errors


def check_ref(site: Path, path: Path, page: Page, parsed: dict[Path, Page], tag: str, attr: str, url: str) -> list[str]:
    url = url.strip()
    if not url:
        return [f'bo‘sh {attr} ({tag})']
    parts = urlsplit(url)
    if parts.scheme in ('mailto', 'tel'):
        return []
    if parts.scheme or url.startswith('//'):
        if (tag, attr) in RESOURCE_ATTRS:
            return [f'tashqi resurs taqiqlangan: {url}']
        return []  # tashqi oddiy havola (<a>) — ruxsat
    if url.startswith('/'):
        return [f'ildizdan havola (/…) taqiqlangan, nisbiy yozing: {url}']
    target = path if not parts.path else (path.parent / unquote(parts.path)).resolve()
    if parts.path.endswith('/') or target.is_dir():
        target = target / 'index.html'
    try:
        target.relative_to(site)
    except ValueError:
        return [f'sayt papkasidan tashqariga havola: {url}']
    if not target.is_file():
        return [f'buzuq havola: {url}']
    if parts.fragment:
        tp = parsed.get(target) if target.suffix == '.html' else None
        if tp is None or unquote(parts.fragment) not in tp.ids:
            return [f'buzuq #id: {url}']
    return []


# --------------------------------------------------------------- self-test
def self_test() -> int:
    """Tekshiruvchi xatolarni haqiqatan topishini sinaydi."""
    failures = 0
    good = """<!doctype html><html lang="uz"><head><meta name="viewport" content="x"><title>T</title>
<link rel="stylesheet" href="style.css"></head><body><p id="a">Eslatmalar va ulashish.
Profil sahifasi. Provider.</p><a href="#a">x</a><a href="mailto:a@b.uz">m</a>
<a href="sub/index.html#b">s</a><img src="logo.png" alt=""></body></html>"""
    cases = {
        'toza sahifa': (good, None),
        'Eslatma': (good.replace('Profil sahifasi.', 'Eslatma (ichki).'), 'Eslatma'),
        'TODO': (good.replace('Profil sahifasi.', 'TODO: yozish'), 'TODO'),
        'Pro': (good.replace('Profil sahifasi.', 'LabGuide Pro'), 'Pro'),
        'obuna': (good.replace('Profil sahifasi.', 'Oylik obuna'), 'obuna'),
        'subscription': (good.replace('Provider.', 'Monthly subscription.'), 'subscription'),
        'payment': (good.replace('Provider.', 'Payment details.'), 'payment'),
        'buzuq havola': (good.replace('sub/index.html#b', 'yoq/index.html'), 'buzuq havola'),
        'buzuq #id': (good.replace('href="#a"', 'href="#zz"'), 'buzuq #id'),
        'tashqi CSS': (good.replace('href="style.css"', 'href="https://cdn.example.com/x.css"'), 'tashqi resurs'),
        'ildiz havola': (good.replace('sub/index.html#b', '/privacy/'), 'ildizdan'),
        'skript': (good.replace('</body>', '<script>var x = 1;</script></body>'), '<script> taqiqlangan'),
        # D-77: narx va sinov muddati.
        'narx $': (good.replace('Provider.', 'Only $4.99 a month.'), 'narx literali'),
        'narx so‘m': (good.replace('Profil sahifasi.', 'Oyiga 12 000 so‘m.'), 'narx literali'),
        '7 kunlik sinov': (good.replace('Profil sahifasi.', '7 kunlik bepul sinov.'), 'sinov 30 kun emas'),
        '7-day trial': (good.replace('Provider.', 'A 7-day free trial.'), 'sinov 30 kun emas'),
        '14 дней': (good.replace('Provider.', 'Пробный период 14 дней.'), 'sinov 30 kun emas'),
        '30 kunlik sinov ruxsat': (good.replace('Profil sahifasi.', '30 kunlik bepul sinov. 30 kun ichida o‘chiriladi.'), None),
    }
    for name, (html_text, expect) in cases.items():
        with tempfile.TemporaryDirectory() as d:
            site = Path(d)
            (site / 'index.html').write_text(html_text, encoding='utf-8')
            (site / 'sub').mkdir()
            (site / 'sub' / 'index.html').write_text(
                '<html lang="en"><head><meta name="viewport" content="x"><title>S</title></head>'
                '<body><p id="b">b</p></body></html>', encoding='utf-8')
            (site / 'style.css').write_text('@media (prefers-color-scheme: dark) {}', encoding='utf-8')
            (site / 'logo.png').write_bytes(b'')
            (site / 'robots.txt').write_text('User-agent: *\n', encoding='utf-8')
            errs = check_site(site, check_fresh=False)
            ok = (not errs) if expect is None else any(expect in e for e in errs)
            print(f'  {"ok  " if ok else "XATO"} {name}' + ('' if ok else f' -> {errs}'))
            failures += 0 if ok else 1

    # D-77: obuna so'zlari privacy/ da ruxsat, boshqa sahifada — xato; narx esa privacy/ da ham xato.
    with tempfile.TemporaryDirectory() as d:
        site = Path(d)
        page = ('<html lang="en"><head><meta name="viewport" content="x"><title>P</title></head>'
                '<body><p>{}</p></body></html>')
        (site / 'privacy').mkdir()
        (site / 'privacy' / 'index.html').write_text(page.format('Pro subscription, obuna, подписка.'), encoding='utf-8')
        (site / 'index.html').write_text(page.format('Hello.'), encoding='utf-8')
        (site / 'style.css').write_text('@media (prefers-color-scheme: dark) {}', encoding='utf-8')
        (site / 'logo.png').write_bytes(b'')
        (site / 'robots.txt').write_text('User-agent: *\n', encoding='utf-8')
        ok = check_site(site, check_fresh=False) == []
        print(f'  {"ok  " if ok else "XATO"} privacy/: obuna so‘zlari ruxsat')
        failures += 0 if ok else 1
        (site / 'privacy' / 'index.html').write_text(page.format('Pro subscription: $4.99.'), encoding='utf-8')
        ok = any('narx literali' in e for e in check_site(site, check_fresh=False))
        print(f'  {"ok  " if ok else "XATO"} privacy/: narx literali baribir taqiqlangan')
        failures += 0 if ok else 1
        # terms/ ham obuna so'zlariga ruxsat oladi, lekin narx va 30 kundan boshqa sinov muddati — yo'q.
        (site / 'privacy' / 'index.html').write_text(page.format('Hello.'), encoding='utf-8')
        (site / 'terms').mkdir()
        (site / 'terms' / 'index.html').write_text(
            page.format('Pro subscription, obuna, подписка, payment, to‘lov. 30 kunlik bepul sinov.'), encoding='utf-8')
        ok = check_site(site, check_fresh=False) == []
        print(f'  {"ok  " if ok else "XATO"} terms/: obuna so‘zlari va 30 kunlik sinov ruxsat')
        failures += 0 if ok else 1
        (site / 'terms' / 'index.html').write_text(page.format('Pro: $4.99 oyiga.'), encoding='utf-8')
        ok = any('narx literali' in e for e in check_site(site, check_fresh=False))
        print(f'  {"ok  " if ok else "XATO"} terms/: narx literali taqiqlangan')
        failures += 0 if ok else 1
        (site / 'terms' / 'index.html').write_text(page.format('7 kunlik bepul sinov.'), encoding='utf-8')
        ok = any('sinov 30 kun emas' in e for e in check_site(site, check_fresh=False))
        print(f'  {"ok  " if ok else "XATO"} terms/: 7 kunlik sinov taqiqlangan (D-80)')
        failures += 0 if ok else 1
        (site / 'terms' / 'index.html').write_text(page.format('Hello.'), encoding='utf-8')
        (site / 'index.html').write_text(page.format('Oylik obuna.'), encoding='utf-8')
        ok = any('obuna' in e for e in check_site(site, check_fresh=False))
        print(f'  {"ok  " if ok else "XATO"} bosh sahifada obuna so‘zi taqiqlangan')
        failures += 0 if ok else 1

    # build_site: ichki blok va HTML izohi chiqmaydi, oddiy iqtibos qoladi.
    md = ('# T\n\nSana: **1**\\\nAloqa: x@y.uz\n\n> Eslatma (e’lon qilishdan oldin o‘chiriladi):\n'
          '> - ichki matn\n\n> Oddiy iqtibos\n\n## English\n\n### 1. Bir\n\nMatn `kod` va [h](#en-1).\n'
          '<!-- yashirin TODO -->\n- band\n  davomi\n')
    _, body = build_site.render(md)
    checks = {
        'ichki blok tashlandi': 'ichki matn' not in body and 'Eslatma' not in body,
        'HTML izohi tashlandi': 'yashirin' not in body,
        'oddiy iqtibos qoldi': 'Oddiy iqtibos' in body,
        'til bo‘limi va #id': '<section id="en" lang="en">' in body and 'id="en-1"' in body,
        'email havola': 'href="mailto:x@y.uz"' in body,
        'qator uzilishi': '<br>' in body,
        'ro‘yxat davomi': '<li>band\ndavomi</li>' in body,
        'qayta ishga tushirish bir xil': build_site.render(md)[1] == body,
    }
    for name, ok in checks.items():
        print(f'  {"ok  " if ok else "XATO"} build_site: {name}')
        failures += 0 if ok else 1
    return failures


def main() -> int:
    ap = argparse.ArgumentParser(description='LabGuide statik saytini tekshirish')
    ap.add_argument('--self-test', action='store_true', help='tekshiruvchining o‘zini sinash')
    ap.add_argument('--site', type=Path, default=SITE, help='sayt papkasi (standart: site/)')
    args = ap.parse_args()
    if args.self_test:
        n = self_test()
        print('self-test: hammasi o‘tdi' if n == 0 else f'self-test: {n} ta xato')
        return 1 if n else 0
    errors = check_site(args.site)
    for e in errors:
        print(f'XATO: {e}')
    pages = len(list(args.site.rglob('*.html')))
    print(f'{pages} ta sahifa tekshirildi: ' + ('xato yo‘q' if not errors else f'{len(errors)} ta xato'))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
