#!/usr/bin/env python3
"""Qo'llanma videolarini yig'ish (docs/TUTORIAL_VIDEOS.md).

Kirish: tool/screenshots/out/tutorial/<teacher|student>/ (kadrlar + frames.json,
tutorial_<rol>_test.dart --update-goldens bilan). Chiqish: portret MP4
1080x1920, H.264, 30 fps; ovozsiz, o'zbekcha yozuvlar (Inter), bosish joyi
belgisi, 0.3 s o'tish, boshida va oxirida kartochka.

  python3 tool/screenshots/tutorial_compose.py teacher [--out DIR] [--preview]

--preview: video o'rniga har qadamning oxirgi kadri (tap bilan) — DIR/preview/.
Faqat ilova kadrlari va PIL bilan chizilgan belgilar ishlatiladi.
"""
import argparse
import json
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
FONTS = os.path.join(ROOT, 'assets', 'fonts')
W, H, FPS = 1080, 1920, 30
FADE = 0.3

BG = (238, 240, 233)
BRAND = (23, 70, 60)
BRAND_SOFT = (207, 231, 218)
INK = (25, 38, 34)
MUTED = (86, 104, 97)
ACCENT = (232, 140, 48)

# (kadr, raqam, yozuv, izoh, soniya)
TEACHER = {
    'title': 'Ustoz: testni boshlash',
    'subtitle': 'Guruh → test → QR → natijalar',
    'steps': [
        ('01_rol', '1', 'Profil → Rol: «Ustoz»', 'Avval email bilan hisobga kiring', 3.0),
        ('02_rol_ustoz', '1', '«Ustoz»ni tanlab, «Davom etish»', None, 2.5),
        ('04_scroll', '2', 'O‘rganish → «Guruh va topshiriqlar»', None, 3.0),
        ('05_guruhlar', '3', '«Guruh yaratish»', None, 2.5),
        ('06_ustoz_royxat', '3', 'Bir marta: ustoz sifatida ro‘yxatdan o‘ting', None, 3.0),
        ('08_guruh_nomi', '4', 'Guruh nomini yozing → «Guruhni yaratish»', None, 3.0),
        ('09_guruh_kod_qr', '5', 'Guruh tayyor: taklif kodi va QR', 'Talabalar QR ni skanerlaydi yoki 8 belgili kodni yozadi', 4.0),
        ('10_guruh_talabalar', '5', 'Talabalar qo‘shildi', 'Ro‘yxatda taxalluslari bilan', 2.5),
        ('11_maruza_royxat', '6', 'Testni tanlang: O‘rganish → «Ma’ruza rejimi»', None, 2.5),
        ('12_maruza_mavzu', '6', 'Mavzu ostidagi «Mavzu testi»', None, 2.5),
        ('13_mavzu_testi', '7', '«Guruhga topshirish»', None, 2.5),
        ('14_topshirish_bosh', '8', 'Guruh tanlangan — savollar sonini belgilang', None, 3.0),
        ('15_topshirish_5_savol', '8', '5 ta savol · har talabaga boshqa savollar', 'Variantli test: savollar mavzu hovuzidan', 3.5),
        ('16_variant_muddat', '9', 'Muddat va javoblar qachon ochilishi', None, 2.5),
        ('17_muddat_natija_sozlandi', '9', 'Muddat: 1 kun · Javoblar: muddat tugagach', 'Ball darhol, to‘g‘ri javoblar — keyin', 3.5),
        ('18_scroll', '10', '«Topshiriqni berish»', None, 2.5),
        ('20_guruh_topshiriq', '11', 'Guruh sahifasida testni oching', None, 2.5),
        ('21_topshiriq_ustoz', '12', '«Test QR» — talabalarga ko‘rsating', None, 2.5),
        ('22_test_qr', '12', 'Talabalar skanerlaydi → test darhol ochiladi', 'Telefon, ekran yoki proyektorda', 4.0),
        ('23_natija_1', '13', 'Natijalar o‘zi yangilanadi', 'Har 10 soniyada — sahifani yangilash shart emas', 3.5),
        ('24_natija_2', '13', '2 / 3 topshirdi — «Katta ekran»', None, 2.5),
        ('25_katta_ekran', '14', 'Katta ekran: jonli reyting', 'Kim yechmoqda, kim topshirdi', 4.0),
        ('26_katta_ekran_3', '14', 'Hamma topshirdi: 3 / 3', None, 2.5),
        ('27_yakunlashdan_oldin', '15', '«Testni yakunlash»', None, 2.5),
        ('28_yakunlash_tasdiq', '15', 'Tasdiqlang — yangi urinish qabul qilinmaydi', None, 3.0),
        ('29_yakunlandi', '15', 'Test yakunlandi — talabalarga javoblar ochildi', None, 3.0),
        ('30_taqsimot_eng_qiyin', '16', 'Natijalar taqsimoti va eng qiyin savollar', None, 4.0),
        ('31_katta_ekran_eng_qiyin', '16', 'Katta ekranda — birga muhokama qiling', None, 4.0),
    ],
}

STUDENT = {
    'title': 'Talaba: testga qo‘shilish',
    'subtitle': 'QR yoki kod → test → natija',
    'steps': [
        ('01_organish', '1', '«O‘rganish» bo‘limini oching', 'Avval email bilan hisobga kiring', 2.5),
        ('02_scroll', '1', '«Guruh va topshiriqlar»', None, 2.5),
        ('03_guruhlar', '2', '«QR kodni skanerlash»', None, 2.5),
        ('04_skaner', '3', 'Ustoz ko‘rsatgan QR kodga kamerani qarating', 'Kod topilishi bilan guruhga qo‘shilasiz', 4.0),
        ('14_kod_guruhlar', 'yoki', 'Kamera ishlamasa: «Kod bilan qo‘shilish»', None, 3.0),
        ('16_kod_taxallus', 'yoki', '8 belgili kod + taxallus → «Qo‘shilish»', 'Taxallus ixtiyoriy — haqiqiy ism shart emas', 3.5),
        ('17_kod_guruh', 'yoki', 'Guruhda testni tanlab, «Boshlash»', None, 3.0),
        ('05_test_ochildi', '4', 'Test ochildi — «Boshlash»', 'Savollar soni va muddat ko‘rsatilgan', 3.5),
        ('06_savol_1', '5', 'Javobni tanlang', None, 2.5),
        ('07_savol_1_tanlandi', '5', 'So‘ng «Keyingi»', None, 2.5),
        ('08_savol_2', '5', 'Har bir savolga javob bering', None, 2.0),
        ('09_savol_2_tanlandi', '5', 'Har bir savolga javob bering', None, 2.0),
        ('10_oxirgi_savol', '6', 'Oxirgi savoldan so‘ng «Yakunlash»', None, 3.0),
        ('11_yakunlash_tasdiq', '6', 'Tasdiqlang — javoblar ustozga yuboriladi', None, 3.0),
        ('12_natija', '7', 'Ball darhol ko‘rinadi', None, 3.0),
        ('13_natija_past', '7', 'To‘g‘ri javoblar keyinroq ochiladi', 'Muddat tugagach yoki ustoz testni yakunlagach', 3.5),
        ('19_xatolar_tahlili', '8', 'Ustoz yakunladi: xatolar tahlili', 'Sizning javobingiz va to‘g‘ri javob, manbasi bilan', 4.0),
    ],
}


def font(weight, size):
    return ImageFont.truetype(os.path.join(FONTS, f'Inter-{weight}.ttf'), size)


def wrap(draw, text, fnt, width):
    words, lines, cur = text.split(), [], ''
    for w in words:
        t = (cur + ' ' + w).strip()
        if draw.textlength(t, font=fnt) <= width or not cur:
            cur = t
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def rounded(im, radius):
    mask = Image.new('L', im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *im.size), radius, fill=255)
    out = Image.new('RGBA', im.size)
    out.paste(im, (0, 0), mask)
    return out


def shadow(canvas, box, radius, blur=28, alpha=70, dy=14):
    sh = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    x0, y0, x1, y1 = box
    ImageDraw.Draw(sh).rounded_rectangle((x0, y0 + dy, x1, y1 + dy), radius, fill=(0, 0, 0, alpha))
    canvas.alpha_composite(sh.filter(ImageFilter.GaussianBlur(blur)))


def caption(canvas, num, text, sub):
    d = ImageDraw.Draw(canvas)
    tx, tw = 200, W - 36 - 200 - 40
    for size in (60, 56, 52, 48, 44, 40):
        tf = font(700, size)
        lines = wrap(d, text, tf, tw)
        sf = font(500, max(32, size - 22))
        slines = wrap(d, sub, sf, tw) if sub else []
        lh, slh = round(size * 1.2), round(sf.size * 1.32)
        th = len(lines) * lh + (len(slines) * slh + 14 if slines else 0)
        if len(lines) <= 2 and th <= 230:
            break
    top, bottom = 50, 50 + max(200, th + 84)
    box = (36, top, W - 36, bottom)
    shadow(canvas, box, 40, blur=20, alpha=40, dy=8)
    d.rounded_rectangle(box, 40, fill=(255, 255, 255))
    cy = (top + bottom) / 2
    cx, r = 116, 54
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=BRAND)
    nf = font(700, 46 if len(num) < 3 else 30)
    d.text((cx, cy), num, font=nf, fill=(255, 255, 255), anchor='mm')
    y = cy - th / 2
    for ln in lines:
        d.text((tx, y + lh / 2), ln, font=tf, fill=INK, anchor='lm')
        y += lh
    if slines:
        y += 14
        for ln in slines:
            d.text((tx, y + slh / 2), ln, font=sf, fill=MUTED, anchor='lm')
            y += slh


def step_canvas(src, meta, num, text, sub):
    """Statik qadam kadri va ilova ekranining joylashuvi (x, y, masshtab)."""
    canvas = Image.new('RGBA', (W, H), BG + (255,))
    caption(canvas, num, text, sub)
    shot = Image.open(src).convert('RGB')
    lw, lh = meta['w'], meta['h']
    if lh >= lw:  # telefon
        sh_h = 1460
        sw = round(sh_h * lw / lh)
        bez = 14
        x = (W - sw) // 2
        y = 400
        shadow(canvas, (x - bez, y - bez, x + sw + bez, y + sh_h + bez), 70)
        ImageDraw.Draw(canvas).rounded_rectangle(
            (x - bez, y - bez, x + sw + bez, y + sh_h + bez), 70, fill=(28, 32, 30))
        canvas.alpha_composite(rounded(shot.resize((sw, sh_h), Image.LANCZOS), 58), (x, y))
        scale = sw / lw
    else:  # katta ekran (televizor)
        sw = 1000
        sh_h = round(sw * lh / lw)
        bez = 16
        x = (W - sw) // 2
        y = 1120 - sh_h // 2
        d = ImageDraw.Draw(canvas)
        shadow(canvas, (x - bez, y - bez, x + sw + bez, y + sh_h + bez), 18)
        d.rounded_rectangle((x - bez, y - bez, x + sw + bez, y + sh_h + bez), 18, fill=(28, 32, 30))
        d.rectangle((W // 2 - 60, y + sh_h + bez, W // 2 + 60, y + sh_h + bez + 70), fill=(60, 66, 63))
        d.rounded_rectangle((W // 2 - 210, y + sh_h + bez + 66, W // 2 + 210, y + sh_h + bez + 86), 10, fill=(60, 66, 63))
        canvas.alpha_composite(shot.resize((sw, sh_h), Image.LANCZOS).convert('RGBA'), (x, y))
        lf = font(600, 34)
        d.text((W // 2, y - 60), 'Proyektor / televizor', font=lf, fill=MUTED, anchor='mm')
        scale = sw / lw
    return canvas, (x, y, scale)


def ease(t):
    t = max(0.0, min(1.0, t))
    return 1 - (1 - t) ** 3


def draw_tap(base, at, t_left):
    """Bosish belgisi: qadam oxirgi 1.1 s ida paydo bo'ladi va "bosiladi"."""
    if at is None or t_left > 1.1:
        return base
    x, y = at
    p = 1.1 - t_left  # 0 → 1.1
    im = base.copy()
    ov = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    r = 44 * ease(p / 0.3)
    if p > 0.6:  # bosish: kichrayadi, to'lqin tarqaladi
        q = (p - 0.6) / 0.5
        r = 44 - 10 * min(1, q * 3) + 10 * max(0, q * 3 - 1) / 2
        rr = 44 + 70 * ease(q)
        a = int(200 * (1 - q))
        d.ellipse((x - rr, y - rr, x + rr, y + rr), outline=ACCENT + (a,), width=6)
    if r > 1:
        d.ellipse((x - r, y - r, x + r, y + r), fill=ACCENT + (95,), outline=ACCENT + (235,), width=6)
        d.ellipse((x - 8, y - 8, x + 8, y + 8), fill=ACCENT + (255,))
    im.alpha_composite(ov)
    return im


def card(title, subtitle, end=False):
    canvas = Image.new('RGBA', (W, H), BRAND + (255,))
    d = ImageDraw.Draw(canvas)
    logo = Image.open(os.path.join(ROOT, 'assets/images/logo_mark_large.png')).convert('RGBA')
    logo = rounded(logo.resize((300, 300), Image.LANCZOS), 70)
    canvas.alpha_composite(logo, ((W - 300) // 2, 520))
    d.text((W // 2, 960), 'LabGuide', font=font(700, 120), fill=(255, 255, 255), anchor='mm')
    if end:
        d.text((W // 2, 1110), 'labguide.nfcstore.uz', font=font(700, 70), fill=BRAND_SOFT, anchor='mm')
        d.text((W // 2, 1210), title, font=font(500, 44), fill=(255, 255, 255), anchor='mm')
    else:
        y = 1100
        for ln in wrap(d, title, font(700, 70), W - 140):
            d.text((W // 2, y), ln, font=font(700, 70), fill=BRAND_SOFT, anchor='mm')
            y += 88
        d.text((W // 2, y + 30), subtitle, font=font(500, 42), fill=(255, 255, 255), anchor='mm')
    return canvas


def build(kind, out_dir, preview):
    spec = TEACHER if kind == 'teacher' else STUDENT
    src_dir = os.path.join(ROOT, 'tool/screenshots/out/tutorial', kind)
    frames = json.load(open(os.path.join(src_dir, 'frames.json')))['frames']
    by_file = {f['file'][:-4]: f for f in frames}

    # Har segment: (statik kadr, tap nuqtasi yoki None, davomiylik).
    segs = [(card(spec['title'], spec['subtitle']), None, 3.0)]
    for name, num, text, sub, dur in spec['steps']:
        m = by_file[name]
        base, (x, y, s) = step_canvas(os.path.join(src_dir, m['file']), m, num, text, sub)
        at = None if not m['tap'] else (x + m['tap'][0] * s, y + m['tap'][1] * s)
        segs.append((base, at, dur))
    segs.append((card('Savol va takliflar: ilovada «Yordam va aloqa»', None, end=True), None, 3.0))

    if preview:
        pdir = os.path.join(out_dir, 'preview', kind)
        os.makedirs(pdir, exist_ok=True)
        for i, (base, at, _) in enumerate(segs):
            draw_tap(base, at, 0.5).convert('RGB').resize((540, 960)).save(
                os.path.join(pdir, f'{i:02d}.png'))
        return

    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, f'labguide_{kind}_test.mp4')
    ff = subprocess.Popen([
        'ffmpeg', '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
        '-s', f'{W}x{H}', '-r', str(FPS), '-i', '-',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '20', '-pix_fmt', 'yuv420p',
        '-tune', 'stillimage', '-movflags', '+faststart', out,
    ], stdin=subprocess.PIPE)
    nf = int(FADE * FPS)
    for i, (base, at, dur) in enumerate(segs):
        n = int(round(dur * FPS))
        # Oldingi segment bilan o'tish shu segment boshida (n ichida).
        start = nf if i > 0 else 0
        static = base.convert('RGB').tobytes() if at is None else None
        for k in range(start, n):
            if static is not None:
                ff.stdin.write(static)
            else:
                ff.stdin.write(draw_tap(base, at, (n - k) / FPS).convert('RGB').tobytes())
        if i + 1 < len(segs):
            a = draw_tap(base, at, 0.0).convert('RGB')
            b = segs[i + 1][0].convert('RGB')
            for k in range(nf):
                ff.stdin.write(Image.blend(a, b, (k + 1) / (nf + 1)).tobytes())
    ff.stdin.close()
    ff.wait()
    print(out)


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('kind', choices=['teacher', 'student'])
    ap.add_argument('--out', default=os.path.join(ROOT, 'tool/screenshots/out/tutorial/video'))
    ap.add_argument('--preview', action='store_true')
    a = ap.parse_args()
    build(a.kind, a.out, a.preview)
