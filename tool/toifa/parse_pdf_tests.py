#!/usr/bin/env python3
"""Rasmiy test PDF (`pdftotext -layout`) -> JSON (savol, 4 variant). Kalit PDF'da YO'Q.

  pdftotext -layout <file>.pdf out.txt
  python3 tool/toifa/parse_pdf_tests.py out.txt <direction_id> <title> > questions.json

Ishonchsiz bloklar (variantlar 4 ta bo'lib ajralmagan) `needs_manual: true` bilan
belgilanadi — ularni qo'lda tuzatmay turib ilovaga kiritib bo'lmaydi.
"""
import json, re, sys

def norm_quotes(s):
    return s.replace('’', "'").replace('ʻ', "'").replace('ʼ', "'").replace('‘', "'").strip()

def blocks(txt):
    parts = re.split(r'\n\s*(\d{1,4})(?:\.\s+|[ \t]{2,}|(?<=\d{3})[ \t])', '\n' + txt)
    out = []
    for i in range(1, len(parts) - 1, 2):
        lines = [l.strip() for l in parts[i + 1].split('\n') if l.strip()]
        n = int(parts[i])
        # Ketma-ketlikka tushmaydigan raqam (variant ichidagi "3. ...") — oldingi savolga qo'shiladi.
        if out and n != out[-1][0] + 1:
            out[-1][1].extend([f'{n}. ' + lines[0]] + lines[1:] if lines else [f'{n}.'])
            continue
        out.append((n, lines))
    return out

def split_stem_options(lines):
    # variant "- " bilan boshlansa (toksikologiya PDF)
    if any(l.startswith('- ') for l in lines):
        stem, opts = [], []
        for l in lines:
            if l.startswith('- '):
                opts.append(l[2:].strip())
            elif opts:
                opts[-1] += ' ' + l          # davom qatori
            else:
                stem.append(l)
        return ' '.join(stem), opts, len(opts) == 4
    # belgisiz variantlar: savol ':' yoki '?' bilan tugaydigan birinchi qatorgacha
    for i, l in enumerate(lines):
        if re.search(r'[:?]\s*$', l) and i < len(lines) - 1:
            rest = lines[i + 1:]
            return ' '.join(lines[:i + 1]), rest, len(rest) == 4
    if len(lines) == 5:
        return lines[0], lines[1:], True
    return ' '.join(lines[:1]), lines[1:], False

def main(path, did, title):
    qs = []
    for n, lines in blocks(open(path, encoding='utf8').read()):
        stem, opts, ok = split_stem_options(lines)
        q = {'id': f'{did}-t-{n:03d}', 'n': n, 'q': norm_quotes(stem),
             'options': [norm_quotes(o) for o in opts],
             'key': None, 'verdict': 'unverified'}
        if not ok:
            q['needs_manual'] = True
        qs.append(q)
    json.dump({'version': 1, 'direction': did, 'title': title,
               'note': "Rasmiy PDF ro'yxati; to'g'ri javob kaliti PDF'da yo'q. "
                       "key=null — tekshirilmagan; ilovaga kalitsiz kiritilmaydi.",
               'questions': qs}, sys.stdout, ensure_ascii=False, indent=1)

if __name__ == '__main__':
    main(*sys.argv[1:4])
