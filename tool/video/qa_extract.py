#!/usr/bin/env python3
"""Video QA: har MP4 dan har storyboard qadamining o‘rtasidagi kadrni chiqaradi
(ffmpeg) va ko‘zdan kechirish uchun kontakt varaqlarini yig‘adi
(docs/video/QA_REPORT.md).

  python3 tool/video/qa_extract.py [--lang uz] [--topic 01_kalibrlash] [--out DIR]

Chiqish (gitignore): build/video_qa/<mavzu>_<til>/NN_<kadr>.png (720x1280, MP4
dan aynan o‘sha kadr) va build/video_qa/sheets/<mavzu>_<til>_<n>.png (4x2,
har katak 360x640 — subtitr telefon o‘lchamida o‘qiladimi, ko‘rish uchun).
Yana: har subtitr uchun shrift o‘lchami va qatorlar soni (kesilish/toshish
xavfi) — build/video_qa/captions.tsv.
"""
import argparse
import json
import os
import subprocess

from PIL import Image, ImageDraw

import compose

ROOT = compose.ROOT
OUT = os.path.join(ROOT, 'build', 'video_qa')


def caption_metrics(text):
    """compose.caption bilan bir xil tanlov: (shrift o‘lchami, qatorlar)."""
    d = ImageDraw.Draw(Image.new('RGB', (10, 10)))
    tw = compose.W - 24 - 130 - 26
    for size in (40, 37, 34):
        lines = compose.wrap(d, text, compose.font(700, size), tw)
        if len(lines) <= 3:
            break
    return size, lines


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--lang', action='append')
    ap.add_argument('--topic', action='append')
    ap.add_argument('--out', default=OUT)
    a = ap.parse_args()
    story = json.load(open(compose.STORY, encoding='utf-8'))
    os.makedirs(os.path.join(a.out, 'sheets'), exist_ok=True)
    rows = ['video\tstep\tid\tfont_px\tlines\ttext']
    for topic in story['topics']:
        if a.topic and topic['id'] not in a.topic:
            continue
        for lang in a.lang or ['uz', 'ru', 'en']:
            mp4 = os.path.join(compose.OUT, f"{topic['id']}_{lang}.mp4")
            vdir = os.path.join(a.out, f"{topic['id']}_{lang}")
            os.makedirs(vdir, exist_ok=True)
            frames = compose.frames_for(topic, lang)
            cues = compose.timeline(topic, lang)
            ids = ['card'] + [f['id'] for f in frames] + ['end']
            shots = []
            for i, ((t0, t1, text), fid) in enumerate(zip(cues, ids)):
                # Qadam oxiriga yaqin (tap belgisi ko‘rinadigan payt), o‘tishdan oldin.
                t = max(t0 + compose.FADE + 0.1, t1 - 0.45)
                png = os.path.join(vdir, f'{i:02d}_{fid}.png')
                subprocess.run(['ffmpeg', '-v', 'error', '-y', '-ss', f'{t:.3f}', '-i', mp4,
                                '-frames:v', '1', png], check=True)
                shots.append(png)
                if fid not in ('card', 'end'):
                    size, lines = caption_metrics(text)
                    rows.append(f"{topic['id']}_{lang}\t{i}\t{fid}\t{size}\t{len(lines)}\t{text}")
            for n in range(0, len(shots), 8):
                part = shots[n:n + 8]
                sheet = Image.new('RGB', (4 * 360, 2 * 660), 'white')
                d = ImageDraw.Draw(sheet)
                for k, p in enumerate(part):
                    x, y = (k % 4) * 360, (k // 4) * 660
                    sheet.paste(Image.open(p).resize((360, 640), Image.LANCZOS), (x, y + 20))
                    d.text((x + 4, y + 4), os.path.basename(p), fill='red')
                sheet.save(os.path.join(a.out, 'sheets', f"{topic['id']}_{lang}_{n // 8 + 1}.png"))
            print(topic['id'], lang, len(shots), flush=True)
    open(os.path.join(a.out, 'captions.tsv'), 'w', encoding='utf-8').write('\n'.join(rows) + '\n')


if __name__ == '__main__':
    main()
