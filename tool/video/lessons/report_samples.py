#!/usr/bin/env python3
"""Namunaviy video-darslar hisobotini yangilash (docs/video/lessons/SAMPLES.md).

build/lesson_samples/ dagi har MP4 / SRT / VTT uchun ffprobe bilan o‘lchanadi
(taxmin yozilmaydi): davomiylik, o‘lcham, kadr tezligi, kodek, audio oqimlari
soni (0 bo‘lishi shart), hajm, sha256. Jadval `<!-- samples:begin -->` …
`<!-- samples:end -->` orasiga yoziladi.

    python3 tool/video/lessons/report_samples.py
"""
import hashlib
import json
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
OUT = os.path.join(ROOT, 'build', 'lesson_samples')
DOC = os.path.join(ROOT, 'docs', 'video', 'lessons', 'SAMPLES.md')


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def probe(path):
    r = subprocess.run(['ffprobe', '-v', 'error', '-show_streams', '-show_format', '-of', 'json', path],
                       capture_output=True, text=True, check=True)
    return json.loads(r.stdout)


def main():
    files = sorted(f for f in os.listdir(OUT) if re.search(r'\.(mp4|srt|vtt)$', f))
    if not files:
        sys.exit(f'{OUT} bo‘sh — avval render_sample.cjs ni yurgizing')
    rows = ['| Fayl | Davomiylik | O‘lcham, fps | Kodek | Audio | Hajm | sha256 |',
            '|---|---|---|---|---|---|---|']
    for f in files:
        p = os.path.join(OUT, f)
        size = os.path.getsize(p)
        hsize = f'{size / 1048576:.2f} MB' if size > 100000 else f'{size} B'
        if f.endswith('.mp4'):
            j = probe(p)
            v = [s for s in j['streams'] if s['codec_type'] == 'video'][0]
            a = [s for s in j['streams'] if s['codec_type'] == 'audio']
            num, den = v['r_frame_rate'].split('/')
            rows.append(f"| `{f}` | {float(j['format']['duration']):.2f} s | {v['width']}×{v['height']}, "
                        f"{int(num) / int(den):g} | {v['codec_name']} | {len(a)} | {hsize} | `{sha256(p)}` |")
        else:
            rows.append(f'| `{f}` | — | — | {f[-3:]} | — | {hsize} | `{sha256(p)}` |')
    md = open(DOC, encoding='utf-8').read()
    md = re.sub(r'(<!-- samples:begin -->)\n(.*?)\n?(<!-- samples:end -->)',
                lambda m: m.group(1) + '\n' + '\n'.join(rows) + '\n' + m.group(3), md, flags=re.S)
    open(DOC, 'w', encoding='utf-8').write(md)
    print('\n'.join(rows))


if __name__ == '__main__':
    main()
