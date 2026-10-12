#!/usr/bin/env python3
"""LabGuide promo roligi (9:16, 1080x1920): haqiqiy ilova kadrlari, telefon mockuplari,
yorliq+sarlavha sahnalari, o'zimiz sintez qilgan musiqa va whoosh; ixtiyoriy ovoz (edge-tts).

    python3 tool/video/make_promo.py --out DIR [--vo DIR]

Kadrlar: /home/user/labguide-videos/work/frames/{promo,v5,v8,v11}/*.png
"""
import argparse
import math
import os
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(ROOT))
FR = '/home/user/labguide-videos/work/frames'
LOGO = os.path.join(REPO, 'assets/images/logo_mark_large.png')
ICON_FONT = '/root/sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'
F = '/usr/share/fonts/opentype/inter/'
W, H, FPS = 1080, 1920, 30
BG1, BG2 = (8, 46, 39), (20, 92, 74)
YEL = (255, 206, 84)
WHITE = (255, 255, 255)
PALE = (205, 228, 218)

def font(name, size):
    return ImageFont.truetype(F + name, size)

# (boshlanish, tugash, turi, ma'lumot)
SCENES = [
    dict(t=3.2, kind='logo', title='LabGuide', sub='Laboratoriya va biokimyoni\noson o‘rganing',
         vo='LabGuide — laboratoriya va biokimyoni oson o‘rganing.'),
    dict(t=4.3, kind='phone', chip='Talabalar uchun', icon=0xe559,
         title='Imtihonga ishonch bilan', sub='Tushuntirishli testlar va imtihon rejimi',
         front='v5/09_s_question.png', back='v5/14_s_result.png',
         vo='Imtihonga ishonch bilan tayyorlaning: tushuntirishli testlar va imtihon rejimi.'),
    dict(t=4.0, kind='phone', chip='Toifa', icon=0xe256,
         title='Rasmiy toifa savollari', sub='488 ta test va og‘zaki javob rejasi',
         front='promo/03_toifa.png', back='promo/02_learn.png',
         vo='Rasmiy toifa savollari — og‘zaki javob rejasi bilan.'),
    dict(t=4.0, kind='phone', chip='Tahlillar', icon=0xe0df,
         title='119 ta tahlil kartasi', sub='Me’yor, sabablar va manbalar bilan',
         front='promo/04_analyte.png', back='promo/01_home.png',
         vo='Yuz o‘n to‘qqizta tahlil kartasi: me’yor, sabablar va manbalar bilan.'),
    dict(t=4.0, kind='phone', chip='Atlas', icon=0xe55a,
         title='Mikroskopiya atlasi', sub='Rasmga qarang — hujayrani toping',
         front='promo/05_atlas.png', back='v8/04_counter.png',
         vo='Mikroskopiya atlasi va leykoformula sanagichi.'),
    dict(t=4.3, kind='phone', chip='Ustoz bilan', icon=0xe2ee,
         title='Dars, taqdimot va test', sub='Guruhga qo‘shiling — hammasi bir joyda',
         front='promo/06_lecture.png', back='v5/06_group.png',
         vo='Ustozingiz guruhiga qo‘shiling: dars, taqdimot va testlar bir joyda.'),
    dict(t=5.2, kind='end', title='LabGuide',
         sub='Ertaga shifokor yoki laborant\nbo‘lsangiz ham — yoningizda',
         button='Tez kunda App Store va Google Play’da', small='Hozir — sinov versiyasi',
         vo='Ertaga shifokor yoki laborant bo‘lsangiz ham, LabGuide yoningizda.'),
]

# ---------------------------------------------------------------- fon
def make_bg():
    y = np.linspace(0, 1, H)[:, None]
    x = np.linspace(0, 1, W)[None, :]
    t = np.clip(0.65 * y + 0.35 * x, 0, 1)[..., None]
    arr = (np.array(BG1) * (1 - t) + np.array(BG2) * t).astype(np.uint8)
    im = Image.fromarray(arr, 'RGB')
    # nozik to'r
    d = ImageDraw.Draw(im, 'RGBA')
    for gx in range(0, W, 90):
        d.line([(gx, 0), (gx, H)], fill=(255, 255, 255, 8))
    for gy in range(0, H, 90):
        d.line([(0, gy), (W, gy)], fill=(255, 255, 255, 8))
    return im

BOKEH = [(160, 380, 260, (255, 214, 102, 40)), (900, 260, 220, (90, 200, 150, 55)),
         (880, 1500, 300, (255, 214, 102, 34)), (140, 1600, 260, (90, 200, 150, 45)),
         (540, 980, 340, (120, 220, 170, 22))]

def icon_img(cp, size, color):
    f = ImageFont.truetype(ICON_FONT, int(size * 0.9))
    im = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    ch = chr(cp)
    l, t, r, b = d.textbbox((0, 0), ch, font=f)
    d.text(((size - (r - l)) / 2 - l, (size - (b - t)) / 2 - t), ch, font=f, fill=color)
    return im

DECOR = [(0xe0df, 120, 300, 70), (0xe55a, 930, 520, 60), (0xe0e3, 80, 1180, 56), (0xe199, 980, 1260, 64),
         (0xe0df, 860, 1780, 50), (0xe55a, 200, 1820, 48), (0xe3d8, 520, 140, 46)]

def bg_frame(base, tt):
    im = base.copy()
    layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i, (bx, by, r, col) in enumerate(BOKEH):
        dx = 40 * math.sin(tt * 0.35 + i)
        dy = 30 * math.cos(tt * 0.28 + i * 1.7)
        d.ellipse([bx + dx - r, by + dy - r, bx + dx + r, by + dy + r], fill=col)
    layer = layer.filter(ImageFilter.GaussianBlur(70))
    im = Image.alpha_composite(im.convert('RGBA'), layer)
    for i, (cp, x, y, s) in enumerate(DECOR):
        ic = DECOR_IMG[i]
        yy = int(y + 12 * math.sin(tt * 0.6 + i))
        im.alpha_composite(ic, (x - s // 2, yy - s // 2))
    return im

# ---------------------------------------------------------------- telefon
def phone(path, width):
    src = Image.open(os.path.join(FR, path)).convert('RGB')
    src = src.crop((0, 110, src.width, src.height))  # bo'sh status bar
    h = int(width * src.height / src.width)
    scr = src.resize((width, h), Image.LANCZOS)
    pad = int(width * 0.035)
    fw, fh = width + 2 * pad, h + 2 * pad
    frame = Image.new('RGBA', (fw, fh), (0, 0, 0, 0))
    d = ImageDraw.Draw(frame)
    d.rounded_rectangle([0, 0, fw - 1, fh - 1], radius=int(width * 0.11), fill=(14, 22, 20, 255))
    mask = Image.new('L', (width, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, width - 1, h - 1], radius=int(width * 0.085), fill=255)
    frame.paste(scr, (pad, pad), mask)
    return frame

def with_shadow(img, angle):
    rot = img.rotate(angle, resample=Image.BICUBIC, expand=True)
    sh = Image.new('RGBA', (rot.width + 120, rot.height + 120), (0, 0, 0, 0))
    a = rot.split()[3].point(lambda v: int(v * 0.55))
    blk = Image.new('RGBA', rot.size, (0, 0, 0, 255))
    blk.putalpha(a)
    sh.alpha_composite(blk, (70, 80))
    sh = sh.filter(ImageFilter.GaussianBlur(28))
    sh.alpha_composite(rot, (60, 60))
    return sh

def ease(x):
    x = max(0.0, min(1.0, x))
    return 1 - (1 - x) ** 3

def text_center(d, y, txt, f, fill, spacing=10):
    for line in txt.split('\n'):
        l, t, r, b = d.textbbox((0, 0), line, font=f)
        d.text(((W - (r - l)) / 2 - l, y), line, font=f, fill=fill)
        y += (b - t) + spacing
    return y

def chip(d, im, y, txt, cp, alpha):
    f = font('Inter-Bold.otf', 38)
    l, t, r, b = d.textbbox((0, 0), txt, font=f)
    tw = r - l
    iw = 46
    w = tw + iw + 76
    x = (W - w) // 2
    col = YEL + (int(255 * alpha),)
    d.rounded_rectangle([x, y, x + w, y + 74], radius=37, fill=col)
    ic = icon_img(cp, iw, (30, 40, 30, int(255 * alpha)))
    im.alpha_composite(ic, (x + 28, y + 14))
    d.text((x + 28 + iw + 14 - l, y + 37 - (b - t) / 2 - t), txt, font=f, fill=(30, 40, 30, int(255 * alpha)))

# ---------------------------------------------------------------- sahnalar
def render_phone_scene(bg, sc, lt, cache):
    im = bg
    d = ImageDraw.Draw(im, 'RGBA')
    a = ease(lt / 0.5)
    chip(d, im, 170 - int(30 * (1 - a)), sc['chip'], sc['icon'], a)
    ft = font('Inter-ExtraBold.otf', 76)
    fs = font('Inter-Medium.otf', 42)
    y = 285 - int(30 * (1 - a))
    y = text_center(d, y, sc['title'], ft, WHITE[:3] + (int(255 * a),))
    text_center(d, y + 14, sc['sub'], fs, PALE + (int(255 * a),))
    pa = ease((lt - 0.15) / 0.6)
    back = cache['back']
    front = cache['front']
    fl = 10 * math.sin(lt * 1.6)
    bx = 560 + int(220 * (1 - pa))
    im.alpha_composite(_fade(back, pa * 0.95), (bx, 620 + int(fl)))
    fx = 120 - int(260 * (1 - pa))
    im.alpha_composite(_fade(front, pa), (fx, 560 + int(-fl)))
    return im

def _fade(img, a):
    if a >= 0.999:
        return img
    c = img.copy()
    c.putalpha(c.split()[3].point(lambda v: int(v * a)))
    return c

def render_logo(bg, sc, lt, logo, end=False):
    im = bg
    d = ImageDraw.Draw(im, 'RGBA')
    a = ease(lt / 0.6)
    s = int(300 * (0.8 + 0.2 * a))
    lg = logo.resize((s, s), Image.LANCZOS)
    y0 = 560 if not end else 470
    im.alpha_composite(_fade(lg, a), ((W - s) // 2, y0 + (300 - s) // 2))
    ft = font('Inter-ExtraBold.otf', 120)
    fs = font('Inter-Medium.otf', 50)
    y = text_center(d, y0 + 340, sc['title'], ft, (255, 255, 255, int(255 * a)))
    y = text_center(d, y + 20, sc['sub'], fs, PALE + (int(255 * a),), spacing=14)
    if end:
        b = ease((lt - 0.5) / 0.5)
        fb = font('Inter-Bold.otf', 42)
        txt = sc['button']
        l, t, r, bb = d.textbbox((0, 0), txt, font=fb)
        w = r - l + 90
        x = (W - w) // 2
        yb = y + 60
        d.rounded_rectangle([x, yb, x + w, yb + 110], radius=55, fill=YEL + (int(255 * b),))
        d.text((x + 45 - l, yb + 55 - (bb - t) / 2 - t), txt, font=fb, fill=(30, 40, 30, int(255 * b)))
        text_center(d, yb + 150, sc['small'], font('Inter-Medium.otf', 36), PALE + (int(220 * b),))
    return im

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--vo', default=None, help="sahna ovozlari: vo/N.mp3")
    ap.add_argument('--name', default='LabGuide-promo-talaba-uz')
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    fdir = os.path.join(a.out, 'frames')
    os.makedirs(fdir, exist_ok=True)
    global DECOR_IMG
    DECOR_IMG = [icon_img(cp, s, (255, 255, 255, 34)) for cp, _, _, s in DECOR]
    base = make_bg()
    logo = Image.open(LOGO).convert('RGBA')
    # ovoz bo'lsa sahna uzunligi ovozga moslanadi
    durs = []
    for i, sc in enumerate(SCENES):
        d = sc['t']
        if a.vo:
            p = os.path.join(a.vo, f'{i}.wav')
            if os.path.exists(p):
                with wave.open(p) as w:
                    d = max(d, w.getnframes() / w.getframerate() + 0.9)
        durs.append(d)
    starts = np.cumsum([0] + durs[:-1])
    total = sum(durs)
    n = 0
    for i, sc in enumerate(SCENES):
        cache = {}
        if sc['kind'] == 'phone':
            cache['front'] = with_shadow(phone(sc['front'], 600), -6)
            cache['back'] = with_shadow(phone(sc['back'], 460), 7)
        nf = int(round(durs[i] * FPS))
        for k in range(nf):
            lt = k / FPS
            tt = (starts[i] + lt)
            bg = bg_frame(base, tt)
            if sc['kind'] == 'phone':
                im = render_phone_scene(bg, sc, lt, cache)
            else:
                im = render_logo(bg, sc, lt, logo, end=sc['kind'] == 'end')
            # sahnalar orasida qisqa oq "flash" o'rniga yumshoq o'tish
            if k < 6 and i > 0:
                ov = Image.new('RGBA', (W, H), (255, 255, 255, int(70 * (1 - k / 6))))
                im = Image.alpha_composite(im, ov)
            im.convert('RGB').save(os.path.join(fdir, f'f{n:05d}.jpg'), quality=92)
            n += 1
    # ---- musiqa va whoosh
    sr = 44100
    tN = int(total * sr)
    t = np.arange(tN) / sr
    chords = [[220.0, 277.18, 329.63], [196.0, 246.94, 293.66], [174.61, 220.0, 261.63], [196.0, 246.94, 329.63]]
    mus = np.zeros(tN)
    seg = 2.0
    for ci in range(int(total / seg) + 1):
        ch = chords[ci % 4]
        s0, s1 = int(ci * seg * sr), min(tN, int((ci + 1) * seg * sr))
        if s0 >= tN:
            break
        tt = t[s0:s1] - ci * seg
        env = np.minimum(1, tt / 0.3) * np.minimum(1, (seg - tt) / 0.4)
        for f in ch:
            mus[s0:s1] += 0.06 * env * (np.sin(2 * np.pi * f * tt) + 0.3 * np.sin(2 * np.pi * 2 * f * tt))
        # yengil puls (8-lik)
        for b in range(8):
            bs = s0 + int(b * seg / 8 * sr)
            be = min(s1, bs + int(0.12 * sr))
            if bs < be:
                tb = np.arange(be - bs) / sr
                mus[bs:be] += 0.05 * np.exp(-tb * 30) * np.sin(2 * np.pi * ch[0] * 2 * tb)
    rng = np.random.default_rng(1)
    for st in starts[1:]:
        s0 = int((st - 0.25) * sr)
        L = int(0.5 * sr)
        if s0 < 0 or s0 + L > tN:
            continue
        noise = rng.standard_normal(L)
        k = np.ones(40) / 40
        noise = np.convolve(noise, k, mode='same')
        env = np.sin(np.linspace(0, np.pi, L)) ** 2
        mus[s0:s0 + L] += 0.25 * noise * env
    fade = np.minimum(1, t / 1.0) * np.minimum(1, (total - t) / 1.5)
    mus *= fade
    vo = np.zeros(tN)
    if a.vo:
        for i in range(len(SCENES)):
            p = os.path.join(a.vo, f'{i}.wav')
            if not os.path.exists(p):
                continue
            with wave.open(p) as w:
                x = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(float) / 32768
            s0 = int((starts[i] + 0.45) * sr)
            e = min(tN, s0 + len(x))
            vo[s0:e] += x[: e - s0]
        duck = np.convolve((np.abs(vo) > 0.01).astype(float), np.ones(4410) / 4410, mode='same')
        mus *= 1 - 0.65 * np.clip(duck * 3, 0, 1)
    mix = np.clip(mus + vo * 1.0, -1, 1)
    st = np.stack([mix, mix], 1)
    wav = os.path.join(a.out, 'audio.wav')
    with wave.open(wav, 'w') as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(sr)
        w.writeframes((st * 32767).astype(np.int16).tobytes())
    out = os.path.join(a.out, a.name + '.mp4')
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-framerate', str(FPS), '-i', os.path.join(fdir, 'f%05d.jpg'),
                    '-i', wav, '-c:v', 'libx264', '-preset', 'medium', '-crf', '19', '-pix_fmt', 'yuv420p',
                    '-c:a', 'aac', '-b:a', '192k', '-movflags', '+faststart', '-shortest', out], check=True)
    # subtitr
    def ts(x):
        h = int(x // 3600); m = int(x % 3600 // 60); s = x % 60
        return f'{h:02d}:{m:02d}:{int(s):02d},{int((s % 1) * 1000):03d}'
    with open(os.path.join(a.out, a.name + '.srt'), 'w', encoding='utf-8') as f:
        for i, sc in enumerate(SCENES):
            f.write(f"{i + 1}\n{ts(starts[i] + 0.4)} --> {ts(starts[i] + durs[i] - 0.2)}\n{sc['vo']}\n\n")
    print(out, round(total, 1), 's,', n, 'kadr')

if __name__ == '__main__':
    main()
