#!/usr/bin/env python3
"""Ilovaning haqiqiy ekran yozuvidan promo rolik (9:16, 1080x1920): telefon ramkasi, bosqich yorlig'i,
ovoz (har bir gap o'z bosqichida), musiqa va yakuniy logotip sahnasi.

    python3 tool/video/make_screen_promo.py --rec run.mp4 --lines lines.json --vo DIR [--vo2 DIR] --out DIR

lines.json: [[nom, boshlanish_soniyasi, matn, yorliq], ...]; oxirgi gap yakuniy sahnada o'qiladi.
Ovoz gapdan uzun bo'lsa, yozuv o'sha joyda to'xtab turadi (freeze), ovoz hech qachon ustma-ust tushmaydi.
"""
import argparse
import json
import os
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

import make_promo as mp

W, H, FPS = mp.W, mp.H, mp.FPS
END_T = 4.2


def wav_len(p):
    with wave.open(p) as w:
        return w.getnframes() / w.getframerate()


def read_wav(p, sr):
    out = subprocess.run(['ffmpeg', '-v', 'error', '-i', p, '-f', 's16le', '-ac', '1', '-ar', str(sr), '-'],
                         capture_output=True, check=True).stdout
    return np.frombuffer(out, dtype=np.int16).astype(float) / 32768


def static_bg():
    base = mp.make_bg()
    layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for bx, by, r, col in mp.BOKEH:
        d.ellipse([bx - r, by - r, bx + r, by + r], fill=col)
    return Image.alpha_composite(base.convert('RGBA'), layer.filter(ImageFilter.GaussianBlur(70)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rec', required=True)
    ap.add_argument('--lines', required=True)
    ap.add_argument('--vo', required=True)
    ap.add_argument('--vo2', default=None, help="ikkinchi ovoz varianti (xuddi shu video bilan)")
    ap.add_argument('--out', required=True)
    ap.add_argument('--name', default='LabGuide-ekran-promo-uz')
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    lines = json.load(open(a.lines))
    vos = [a.vo] + ([a.vo2] if a.vo2 else [])
    dur = {n: max(wav_len(os.path.join(v, f'{n}.wav')) for v in vos) for n, *_ in lines}

    # ---- yozuv kadrlari
    src = os.path.join(a.out, 'src')
    os.makedirs(src, exist_ok=True)
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', a.rec, '-vf', f'fps={FPS}', '-q:v', '3',
                    os.path.join(src, 's%05d.jpg')], check=True)
    nsrc = len(os.listdir(src))
    rec_len = nsrc / FPS

    # ---- vaqt jadvali: (chiqish vaqti -> manba vaqti), ovoz uchun to'xtashlar
    body, end_line = lines[:-1], lines[-1]
    holds = []   # (manba_vaqti, davomiylik)
    starts = {}
    shift, prev_end = 0.0, 0.0
    for n, t0, *_ in body:
        s = max(t0 + shift, prev_end + 0.3)
        if s > t0 + shift:
            holds.append((t0, s - (t0 + shift)))
            shift = s - t0
        starts[n] = s
        prev_end = s + dur[n]
    rec_out = rec_len + shift
    if prev_end + 0.4 > rec_out:
        holds.append((rec_len - 0.05, prev_end + 0.4 - rec_out))
        rec_out = prev_end + 0.4
    starts[end_line[0]] = rec_out + 0.5
    total = rec_out + max(END_T, dur[end_line[0]] + 1.2)

    def src_time(t):
        acc = 0.0
        for ht, hd in holds:
            if t < ht + acc:
                break
            if t < ht + acc + hd:
                return ht
            acc += hd
        return min(t - acc, rec_len - 1 / FPS)

    def label_at(t):
        cur = body[0]
        for ln in body:
            if starts[ln[0]] - 0.2 <= t:
                cur = ln
        return cur[3]

    # ---- kadrlar
    bg = static_bg()
    base = mp.make_bg()
    last_im = None
    logo = Image.open(mp.LOGO).convert('RGBA')
    mp.DECOR_IMG = [mp.icon_img(cp, s, (255, 255, 255, 34)) for cp, _, _, s in mp.DECOR]
    sh_h = 1640
    sw = int(round(sh_h * 1080 / 2338))
    pad = 16
    fw, fh = sw + 2 * pad, sh_h + 2 * pad
    frame = Image.new('RGBA', (fw, fh), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle([0, 0, fw - 1, fh - 1], radius=64, fill=(14, 22, 20, 255))
    mask = Image.new('L', (sw, sh_h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw - 1, sh_h - 1], radius=50, fill=255)
    shadow = Image.new('RGBA', (fw + 120, fh + 120), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([60, 70, 60 + fw, 70 + fh], radius=64, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(26))
    px, py = (W - fw) // 2, H - fh - 40
    plate = bg.copy()
    plate.alpha_composite(shadow, (px - 60, py - 60))
    plate.alpha_composite(frame, (px, py))
    fchip = mp.font('Inter-Bold.otf', 46)
    fdir = os.path.join(a.out, 'frames')
    os.makedirs(fdir, exist_ok=True)
    nf = int(round(total * FPS))
    end_scene = dict(title='LabGuide', sub='Laboratoriya va biokimyo —\nbitta ilovada',
                     button='Tez kunda App Store va Google Play’da', small='Hozir — sinov versiyasi')
    for k in range(nf):
        t = k / FPS
        if t < rec_out:
            si = min(nsrc, int(round(src_time(t) * FPS)) + 1)
            scr = Image.open(os.path.join(src, f's{si:05d}.jpg')).convert('RGB').resize((sw, sh_h), Image.LANCZOS)
            im = plate.copy()
            im.paste(scr, (px + pad, py + pad), mask)
            d = ImageDraw.Draw(im, 'RGBA')
            txt = label_at(t)
            l, tp, r, b = d.textbbox((0, 0), txt, font=fchip)
            cw = r - l + 70
            cx = (W - cw) // 2
            d.rounded_rectangle([cx, 82, cx + cw, 82 + 84], radius=42, fill=mp.YEL + (255,))
            d.text((cx + 35 - l, 82 + 42 - (b - tp) / 2 - tp), txt, font=fchip, fill=(30, 40, 30))
        else:
            lt = t - rec_out
            im = mp.render_logo(mp.bg_frame(base, t), end_scene, lt, logo, end=True)
            if lt < 0.35:
                im = Image.blend(last_im, im.convert('RGB'), lt / 0.35)
        if t < rec_out:
            last_im = im.convert('RGB')
        im.convert('RGB').save(os.path.join(fdir, f'f{k:05d}.jpg'), quality=92)

    # ---- audio: musiqa + ovoz
    sr = 44100
    tN = int(total * sr)
    tt = np.arange(tN) / sr
    chords = [[220.0, 277.18, 329.63], [196.0, 246.94, 293.66], [174.61, 220.0, 261.63], [196.0, 246.94, 329.63]]
    mus = np.zeros(tN)
    seg = 2.0
    for ci in range(int(total / seg) + 1):
        ch = chords[ci % 4]
        s0, s1 = int(ci * seg * sr), min(tN, int((ci + 1) * seg * sr))
        if s0 >= tN:
            break
        x = tt[s0:s1] - ci * seg
        env = np.minimum(1, x / 0.3) * np.minimum(1, (seg - x) / 0.4)
        for f in ch:
            mus[s0:s1] += 0.05 * env * (np.sin(2 * np.pi * f * x) + 0.3 * np.sin(2 * np.pi * 2 * f * x))
    mus *= np.minimum(1, tt / 1.0) * np.minimum(1, (total - tt) / 1.5)

    def ts(x):
        h = int(x // 3600); m = int(x % 3600 // 60); s = x % 60
        return f'{h:02d}:{m:02d}:{int(s):02d},{int((s % 1) * 1000):03d}'

    with open(os.path.join(a.out, a.name + '.srt'), 'w', encoding='utf-8') as f:
        for i, (n, _, txt, *_) in enumerate(lines):
            f.write(f'{i + 1}\n{ts(starts[n])} --> {ts(starts[n] + dur[n] + 0.2)}\n{txt}\n\n')

    for vi, vdir in enumerate(vos):
        vo = np.zeros(tN)
        for n, *_ in lines:
            x = read_wav(os.path.join(vdir, f'{n}.wav'), sr)
            x = x / (np.abs(x).max() + 1e-9) * 0.85
            s0 = int(starts[n] * sr)
            e = min(tN, s0 + len(x))
            vo[s0:e] += x[: e - s0]
        duck = np.convolve((np.abs(vo) > 0.02).astype(float), np.ones(8820) / 8820, mode='same')
        m2 = mus * (1 - 0.7 * np.clip(duck * 3, 0, 1))
        mix = np.clip(m2 + vo, -1, 1)
        wav = os.path.join(a.out, f'audio{vi}.wav')
        with wave.open(wav, 'w') as w:
            w.setnchannels(2); w.setsampwidth(2); w.setframerate(sr)
            w.writeframes((np.stack([mix, mix], 1) * 32767).astype(np.int16).tobytes())
        suffix = '' if vi == 0 else f'-ovoz{vi + 1}'
        out = os.path.join(a.out, a.name + suffix + '.mp4')
        subprocess.run(['ffmpeg', '-v', 'error', '-y', '-framerate', str(FPS), '-i', os.path.join(fdir, 'f%05d.jpg'),
                        '-i', wav, '-c:v', 'libx264', '-preset', 'medium', '-crf', '19', '-pix_fmt', 'yuv420p',
                        '-c:a', 'aac', '-b:a', '192k', '-movflags', '+faststart', '-shortest', out], check=True)
        print(out, round(total, 1), 's')
    print('holds', [(round(h, 1), round(d, 1)) for h, d in holds], 'starts', {k: round(v, 1) for k, v in starts.items()})


if __name__ == '__main__':
    main()
