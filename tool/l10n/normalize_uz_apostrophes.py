#!/usr/bin/env python3
"""Normalise ASCII in-word apostrophes in Uzbek (Latin) strings.

Project convention (L10N audit 2026-10-24):
  * o' / g'  ->  oʻ / gʻ  written as U+2018 (o‘ g‘)
  * tutuq (ma'lumot, e'lon, IFU'lari)  ->  U+2019

Only *in-word* apostrophes (letter ' letter) inside Uzbek strings are touched.
English clitics (patient's, can't, it's ...), quote marks ('text'), URLs, ids,
code and every non-Uzbek string are left alone. The script is idempotent.

Uzbek context:
  * lib/l10n/app_uz.arb      - every value (keys starting with '@' are skipped)
  * JSON files               - strings that sit under a dict key named "uz",
                               every string in files named *.uz.json, and a few
                               explicit Uzbek-only paths (EXTRA_UZ_PATHS).

Usage:
  python3 tool/l10n/normalize_uz_apostrophes.py --dry-run          # default targets
  python3 tool/l10n/normalize_uz_apostrophes.py                    # rewrite default targets
  python3 tool/l10n/normalize_uz_apostrophes.py --file assets/instruments/catalog.json [--dry-run]
  python3 tool/l10n/normalize_uz_apostrophes.py --check            # exit 1 if anything would change

assets/instruments/catalog.json is NOT in the default targets (owned by another
branch); run it explicitly with --file after merging.
"""
import argparse
import glob
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

LEFT = '‘'   # o‘ g‘
TUTUQ = '’'  # tutuq

# JSON paths (with list indices collapsed to []) that are Uzbek without a "uz" key.
EXTRA_UZ_PATHS = [
    re.compile(r'^/library/\[\]/(title|publisher)$'),
    re.compile(r'^/categories/\[\]/terms/\[\]$'),
]

CLITIC = re.compile(r'^(s|t|d|m|re|ve|ll)$')
INWORD = re.compile(r"(?<=[A-Za-z])'(?=[A-Za-z])")
TAIL = re.compile(r'[A-Za-z]*')


def normalize_text(s):
    """Return s with in-word ASCII apostrophes replaced (Uzbek text only)."""
    if "'" not in s:
        return s

    def fn(m):
        i = m.start()
        prev = s[i - 1]
        nxt = s[i + 1]
        tail = TAIL.match(s, i + 1).group(0)
        if CLITIC.match(tail):  # English possessive / contraction
            return m.group(0)
        if prev in 'oOgG':
            before = s[i - 2] if i >= 2 else ''
            acronym = prev.isupper() and before.isupper() and nxt.islower()
            if not acronym:
                return LEFT
        return TUTUQ

    return INWORD.sub(fn, s)


def _is_uz_path(path, fname):
    if fname.endswith('.uz.json'):
        return True
    if '/uz' in path.split('/') or 'uz' in path.split('/'):
        return True
    return any(p.match(path) for p in EXTRA_UZ_PATHS)


def _walk(o, path, fname, changes):
    if isinstance(o, dict):
        return {k: _walk(v, path + '/' + k, fname, changes) for k, v in o.items()}
    if isinstance(o, list):
        return [_walk(v, path + '/[]', fname, changes) for v in o]
    if isinstance(o, str) and _is_uz_path(path, fname):
        n = normalize_text(o)
        if n != o:
            changes.append((path, o, n))
        return n
    return o


DUMP_STYLES = [
    dict(indent=1), dict(indent=2), dict(separators=(',', ':')), dict(indent=4),
]


def process_json(text, fname):
    data = json.loads(text)
    style = None
    for st in DUMP_STYLES:
        for end in ('\n', ''):
            if json.dumps(data, ensure_ascii=False, **st) + end == text:
                style = (st, end)
                break
        if style:
            break
    changes = []
    out = _walk(data, '', fname, changes)
    if not changes:
        return text, changes
    if style is None:
        raise SystemExit(f'{fname}: cannot reproduce original JSON formatting; refusing to rewrite')
    st, end = style
    return json.dumps(out, ensure_ascii=False, **st) + end, changes


ARB_LINE = re.compile(r'^(\s*"(?!@)[^"]+"\s*:\s*")(.*)(",?\s*)$')


def process_arb(text):
    changes = []
    lines = text.split('\n')
    for i, ln in enumerate(lines):
        m = ARB_LINE.match(ln)
        if not m or "'" not in m.group(2):
            continue
        n = normalize_text(m.group(2))
        if n != m.group(2):
            changes.append((f'line {i + 1}', m.group(2), n))
            lines[i] = m.group(1) + n + m.group(3)
    return '\n'.join(lines), changes


def default_targets():
    t = [os.path.join(ROOT, 'lib/l10n/app_uz.arb')]
    for f in sorted(glob.glob(os.path.join(ROOT, 'assets', '**', '*.json'), recursive=True)):
        if f.endswith(os.path.join('instruments', 'catalog.json')):
            continue
        t.append(f)
    return t


def process_file(path):
    with open(path, encoding='utf-8', newline='') as f:
        text = f.read()
    if "'" not in text:
        return text, text, []
    if path.endswith('.arb'):
        new, ch = process_arb(text)
    else:
        new, ch = process_json(text, os.path.basename(path))
    return text, new, ch


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--file', action='append', help='file to process (repeatable); default: ARB + assets/**/*.json except instruments/catalog.json')
    ap.add_argument('--dry-run', action='store_true', help='print changes, write nothing')
    ap.add_argument('--check', action='store_true', help='like --dry-run, exit 1 if anything would change')
    ap.add_argument('-q', '--quiet', action='store_true', help='only print per-file counts')
    a = ap.parse_args(argv)
    files = [os.path.abspath(f) for f in a.file] if a.file else default_targets()
    total = 0
    for f in files:
        old, new, ch = process_file(f)
        if not ch:
            continue
        total += len(ch)
        print(f'{os.path.relpath(f, ROOT)}: {len(ch)} string(s)')
        if not a.quiet:
            for p, o, n in ch:
                print(f'  {p}\n    - {o[:140]}\n    + {n[:140]}')
        if not (a.dry_run or a.check):
            with open(f, 'w', encoding='utf-8', newline='') as fh:
                fh.write(new)
    print(f'total strings {"to change" if (a.dry_run or a.check) else "changed"}: {total}')
    return 1 if (a.check and total) else 0


if __name__ == '__main__':
    sys.exit(main())
