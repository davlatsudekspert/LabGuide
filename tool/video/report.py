#!/usr/bin/env python3
"""Video hujjatlarini yangilash (docs/video/).

1. docs/video/<mavzu>.md — `<!-- storyboard:begin -->` … `<!-- storyboard:end -->`
   orasidagi jadval tool/video/storyboards.json dan qayta yoziladi (kadr,
   haqiqiy marshrut, ekrandagi amal, uz/ru/en subtitr, soniya).
2. docs/video/OUTPUTS.md — build/video_out/ dagi har MP4 / SRT / VTT:
   davomiylik, o‘lcham, kodek, audio oqimlari soni (0 bo‘lishi shart), hajm,
   sha256 (ffprobe bilan o‘lchanadi; taxmin yozilmaydi).

  python3 tool/video/report.py [--docs-only]
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
STORY = os.path.join(ROOT, 'tool', 'video', 'storyboards.json')
DOCS = os.path.join(ROOT, 'docs', 'video')
OUT = os.path.join(ROOT, 'build', 'video_out')
BEGIN, END = '<!-- storyboard:begin -->', '<!-- storyboard:end -->'

sys.path.insert(0, os.path.dirname(__file__))
from compose import (CARD, CREDIT_TEXT, CREDITS_SEC, END as END_CARD, credits_for,  # noqa: E402
                     timeline)


def cell(s):
    return s.replace('|', '\\|').replace('\n', ' ')


def table(topic):
    rows = [
        '| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |',
        '|---|---|---|---|---|---|---|---|',
        f"| — | kartochka | — | Sarlavha | {cell(topic['title']['uz'])} | {cell(topic['title']['ru'])} "
        f"| {cell(topic['title']['en'])} | {CARD:g} |",
    ]
    for i, f in enumerate(topic['frames'], 1):
        only = f.get('langs')
        note = f" (faqat {'/'.join(only)})" if only else ''
        rows.append(
            f"| {i} | `{f['id']}`{note} | `{f['route']}` | {cell(f['action'])} | {cell(f['text']['uz']) or '—'} "
            f"| {cell(f['text']['ru'])} | {cell(f['text']['en'])} | {f['sec']:g} |")
    if any(credits_for(topic, lang) for lang in ['uz', 'ru', 'en']):
        rows.append(f'| — | mualliflar kartochkasi | — | Uchinchi tomon rasmlari: muallif, litsenziya (+ `<mavzu>_<til>_credits.txt`) '
                    f'| {CREDIT_TEXT["uz"][0]} | {CREDIT_TEXT["ru"][0]} | {CREDIT_TEXT["en"][0]} | {CREDITS_SEC:g} |')
    rows.append(f'| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | {END_CARD:g} |')
    total = {lang: timeline(topic, lang)[-1][1] for lang in ['uz', 'ru', 'en']}
    rows.append('')
    rows.append('Jami davomiylik (storyboard bo‘yicha): ' +
                ', '.join(f'{k} — {v:.1f} s' for k, v in total.items()) + '.')
    return '\n'.join(rows)


def update_docs(story):
    for topic in story['topics']:
        path = os.path.join(DOCS, f"{topic['id']}.md")
        md = open(path, encoding='utf-8').read()
        a, b = md.index(BEGIN) + len(BEGIN), md.index(END)
        md = md[:a] + '\n' + table(topic) + '\n' + md[b:]
        open(path, 'w', encoding='utf-8').write(md)
        print('yangilandi:', os.path.relpath(path, ROOT))


def probe(path):
    j = json.loads(subprocess.check_output([
        'ffprobe', '-v', 'error', '-show_entries',
        'format=duration:stream=codec_type,codec_name,width,height,r_frame_rate',
        '-of', 'json', path]))
    v = [s for s in j['streams'] if s['codec_type'] == 'video'][0]
    audio = sum(1 for s in j['streams'] if s['codec_type'] == 'audio')
    return float(j['format']['duration']), v, audio


def sha(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def outputs(story):
    lines = [
        '# Video qo‘llanmalar — chiqarilgan fayllar',
        '',
        '**Yorliq: ovozsiz, subtitrli ekran yozuvi — diktorsiz.** Har video — ilovaning haqiqiy ekranlari',
        '(widget test render, serversiz, haqiqiy kontent) dan yig‘ilgan; ovoz yo‘q, diktor yo‘q (TTS vositasi',
        'yo‘q). Subtitrlar kadrga yozilgan (burned-in) va alohida SRT/VTT fayl sifatida ham bor.',
        '',
        'Fayllar repoga qo‘shilmaydi: `build/video_out/` (gitignore). Qayta yig‘ish — `docs/video/PLAN.md`.',
        'Bu jadval `python3 tool/video/report.py` bilan ffprobe va sha256 orqali o‘lchab yozilgan.',
        '',
        '| Fayl | Til | Davomiylik | O‘lcham | Kodek, fps | Audio | Hajm | sha256 |',
        '|---|---|---|---|---|---|---|---|',
    ]
    total, count = 0, 0
    for topic in story['topics']:
        for lang in ['uz', 'ru', 'en']:
            mp4 = os.path.join(OUT, f"{topic['id']}_{lang}.mp4")
            if not os.path.exists(mp4):
                lines.append(f"| `{topic['id']}_{lang}.mp4` | {lang} | — | — | — | — | yo‘q | — |")
                continue
            dur, v, audio = probe(mp4)
            if audio:
                sys.exit(f'{mp4}: audio oqimi bor — video ovozsiz bo‘lishi kerak')
            size = os.path.getsize(mp4)
            total += size
            count += 1
            num, den = v['r_frame_rate'].split('/')
            lines.append(
                f"| `{topic['id']}_{lang}.mp4` | {lang} | {dur:.1f} s | {v['width']}×{v['height']} "
                f"| {v['codec_name']}, {int(num) / int(den):g} | yo‘q (0 oqim) | {size / 1e6:.2f} MB "
                f"| `{sha(mp4)}` |")
    lines += ['', f'Jami: {count} ta MP4, {total / 1e6:.1f} MB.', '',
              '## Subtitr va mualliflik fayllari (SRT / VTT / credits.txt)', '',
              'credits.txt — videoda ko‘rinadigan uchinchi tomon rasmlarining muallifi, litsenziyasi va manba havolasi; '
              'video e’lon qilinsa, tavsifga shu matn qo‘shiladi.', '',
              '| Fayl | Til | Hajm | sha256 |', '|---|---|---|---|']
    for topic in story['topics']:
        for lang in ['uz', 'ru', 'en']:
            for ext in ['srt', 'vtt', 'credits.txt']:
                p = os.path.join(OUT, f"{topic['id']}_{lang}{'_' if ext == 'credits.txt' else '.'}{ext}")
                if ext == 'credits.txt' and not os.path.exists(p):
                    continue
                if os.path.exists(p):
                    lines.append(f"| `{os.path.basename(p)}` | {lang} | {os.path.getsize(p)} B | `{sha(p)}` |")
                else:
                    lines.append(f"| `{os.path.basename(p)}` | {lang} | yo‘q | — |")
    open(os.path.join(DOCS, 'OUTPUTS.md'), 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    print('yozildi: docs/video/OUTPUTS.md', count, 'MP4')


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--docs-only', action='store_true')
    a = ap.parse_args()
    s = json.load(open(STORY, encoding='utf-8'))
    update_docs(s)
    if not a.docs_only:
        outputs(s)
