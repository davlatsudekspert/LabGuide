#!/usr/bin/env python3
"""Video qo‘llanmalarni yig‘ish (docs/video/PLAN.md).

Kirish: tool/video/out/frames/<til>/<mavzu>/ (haqiqiy ilova kadrlari +
frames.json; tool/video/howto_walk_test.dart --update-goldens bilan) va
tool/video/storyboards.json (kadr tartibi, soniyalar, uz/ru/en subtitrlar).

Chiqish (build/video_out/, gitignore):
  <mavzu>_<til>.mp4  — 720x1280, H.264, 24 fps, OVOZSIZ, subtitrlar kadrga
                       yozilgan (burned-in), bosish joyi — to‘q sariq doira;
  <mavzu>_<til>.srt / .vtt — o‘sha matn va vaqtlar alohida fayl sifatida.

  python3 tool/video/compose.py [--lang uz] [--topic 01_kalibrlash]
      [--subs-only] [--preview] [--out DIR]

--subs-only: faqat SRT/VTT (kadrlar shart emas — vaqtlar storyboarddan).
--preview: video o‘rniga har kadrning yakuniy ko‘rinishi (PNG) — DIR/preview/.
Faqat ilova kadrlari va PIL bilan chizilgan belgilar ishlatiladi; ovoz yo‘q
(matnni o‘qiydigan diktor/TTS vositasi yo‘q).
"""
import argparse
import json
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
FONTS = os.path.join(ROOT, 'assets', 'fonts')
FRAMES = os.path.join(ROOT, 'tool', 'video', 'out', 'frames')
STORY = os.path.join(ROOT, 'tool', 'video', 'storyboards.json')
OUT = os.path.join(ROOT, 'build', 'video_out')

W, H, FPS = 720, 1280, 24
FADE = 0.3
CARD, END = 3.0, 3.0

BG = (238, 240, 233)
BRAND = (23, 70, 60)
BRAND_SOFT = (207, 231, 218)
INK = (25, 38, 34)
MUTED = (86, 104, 97)
ACCENT = (232, 140, 48)

LABELS = {
    'uz': ('Ovozsiz, subtitrli ekran yozuvi — diktorsiz',
           'Savol va takliflar: ilovada «Yordam va aloqa»'),
    'ru': ('Без звука, с субтитрами — запись экрана без диктора',
           'Вопросы и предложения: в приложении «Помощь и связь»'),
    'en': ('Silent screen recording with subtitles — no narration',
           'Questions and ideas: “Help & contact” in the app'),
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


def shadow(canvas, box, radius, blur=18, alpha=60, dy=9):
    sh = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    x0, y0, x1, y1 = box
    ImageDraw.Draw(sh).rounded_rectangle((x0, y0 + dy, x1, y1 + dy), radius, fill=(0, 0, 0, alpha))
    canvas.alpha_composite(sh.filter(ImageFilter.GaussianBlur(blur)))


def caption(canvas, num, text):
    """Kadrga yozilgan subtitr: tepada oq kartochka, chapda qadam raqami."""
    d = ImageDraw.Draw(canvas)
    tx, tw = 130, W - 24 - 130 - 26
    # Telefon ekranida o‘qilsin: kamida 34 px (720 px kenglikda), 3 qatorgacha.
    for size in (40, 37, 34):
        tf = font(700, size)
        lines = wrap(d, text, tf, tw)
        lh = round(size * 1.22)
        if len(lines) <= 3:
            break
    else:
        sys.exit(f'subtitr juda uzun (34 px da 3 qatordan oshadi): {text}')
    th = len(lines) * lh
    top, bottom = 30, 30 + max(132, th + 52)
    shadow(canvas, (24, top, W - 24, bottom), 26, blur=12, alpha=34, dy=5)
    d.rounded_rectangle((24, top, W - 24, bottom), 26, fill=(255, 255, 255))
    cy = (top + bottom) / 2
    cx, r = 76, 34
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=BRAND)
    d.text((cx, cy), num, font=font(700, 30 if len(num) < 3 else 22), fill=(255, 255, 255), anchor='mm')
    y = cy - th / 2
    for ln in lines:
        d.text((tx, y + lh / 2), ln, font=tf, fill=INK, anchor='lm')
        y += lh
    return bottom


def step_canvas(src, meta, num, text):
    canvas = Image.new('RGBA', (W, H), BG + (255,))
    bottom = caption(canvas, num, text)
    shot = Image.open(src).convert('RGB')
    lw, lh = meta['w'], meta['h']
    top = max(bottom + 26, 236)
    sh_h = H - top - 26
    sw = round(sh_h * lw / lh)
    bez = 9
    x = (W - sw) // 2
    shadow(canvas, (x - bez, top - bez, x + sw + bez, top + sh_h + bez), 46)
    ImageDraw.Draw(canvas).rounded_rectangle(
        (x - bez, top - bez, x + sw + bez, top + sh_h + bez), 46, fill=(28, 32, 30))
    canvas.alpha_composite(rounded(shot.resize((sw, sh_h), Image.LANCZOS), 38), (x, top))
    return canvas, (x, top, sw / lw)


def ease(t):
    t = max(0.0, min(1.0, t))
    return 1 - (1 - t) ** 3


def draw_tap(base, at, t_left):
    """Bosish belgisi: kadrning oxirgi 1.1 s ida paydo bo‘ladi va “bosiladi”."""
    if at is None or t_left > 1.1:
        return base
    x, y = at
    p = 1.1 - t_left
    im = base.copy()
    ov = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    r = 29 * ease(p / 0.3)
    if p > 0.6:
        q = (p - 0.6) / 0.5
        r = 29 - 7 * min(1, q * 3) + 7 * max(0, q * 3 - 1) / 2
        rr = 29 + 46 * ease(q)
        a = int(200 * (1 - q))
        d.ellipse((x - rr, y - rr, x + rr, y + rr), outline=ACCENT + (a,), width=4)
    if r > 1:
        d.ellipse((x - r, y - r, x + r, y + r), fill=ACCENT + (95,), outline=ACCENT + (235,), width=4)
        d.ellipse((x - 5, y - 5, x + 5, y + 5), fill=ACCENT + (255,))
    im.alpha_composite(ov)
    return im


def card(title, subtitle, label, end=False):
    canvas = Image.new('RGBA', (W, H), BRAND + (255,))
    d = ImageDraw.Draw(canvas)
    logo = Image.open(os.path.join(ROOT, 'assets/images/logo_mark_large.png')).convert('RGBA')
    logo = rounded(logo.resize((200, 200), Image.LANCZOS), 46)
    canvas.alpha_composite(logo, ((W - 200) // 2, 330))
    d.text((W // 2, 630), 'LabGuide', font=font(700, 80), fill=(255, 255, 255), anchor='mm')
    y = 740
    if end:
        d.text((W // 2, y), 'labguide.nfcstore.uz', font=font(700, 46), fill=BRAND_SOFT, anchor='mm')
        y += 70
        for ln in wrap(d, subtitle, font(500, 30), W - 100):
            d.text((W // 2, y), ln, font=font(500, 30), fill=(255, 255, 255), anchor='mm')
            y += 40
    else:
        for ln in wrap(d, title, font(700, 46), W - 90):
            d.text((W // 2, y), ln, font=font(700, 46), fill=BRAND_SOFT, anchor='mm')
            y += 58
        y += 14
        for ln in wrap(d, subtitle, font(500, 28), W - 100):
            d.text((W // 2, y), ln, font=font(500, 28), fill=(255, 255, 255), anchor='mm')
            y += 38
    # Halol yorliq: ovozsiz, diktorsiz.
    lf = font(600, 24)
    tw = d.textlength(label, font=lf)
    d.rounded_rectangle((W / 2 - tw / 2 - 18, 1150, W / 2 + tw / 2 + 18, 1196), 23,
                        outline=BRAND_SOFT, width=2)
    d.text((W // 2, 1173), label, font=lf, fill=BRAND_SOFT, anchor='mm')
    return canvas


def frames_for(topic, lang):
    return [f for f in topic['frames'] if lang in f.get('langs', ['uz', 'ru', 'en'])]


def timeline(topic, lang):
    """(boshlanish, tugash, matn) — SRT/VTT uchun; video bilan bir xil."""
    cues, t = [], 0.0
    cues.append((0.0, CARD, f"{topic['title'][lang]} — {LABELS[lang][0]}"))
    t = CARD
    for f in frames_for(topic, lang):
        cues.append((t, t + f['sec'], f['text'][lang]))
        t += f['sec']
    cues.append((t, t + END, LABELS[lang][1]))
    return cues


def ts(sec, sep):
    ms = int(round(sec * 1000))
    h, ms = divmod(ms, 3600000)
    m, ms = divmod(ms, 60000)
    s, ms = divmod(ms, 1000)
    return f'{h:02d}:{m:02d}:{s:02d}{sep}{ms:03d}'


def write_subs(topic, lang, out_dir):
    cues = timeline(topic, lang)
    base = os.path.join(out_dir, f"{topic['id']}_{lang}")
    with open(base + '.srt', 'w', encoding='utf-8') as f:
        for i, (a, b, text) in enumerate(cues, 1):
            f.write(f'{i}\n{ts(a, ",")} --> {ts(b, ",")}\n{text}\n\n')
    with open(base + '.vtt', 'w', encoding='utf-8') as f:
        f.write('WEBVTT\n\n')
        for i, (a, b, text) in enumerate(cues, 1):
            f.write(f'{i}\n{ts(a, ".")} --> {ts(b, ".")}\n{text}\n\n')
    return base


def build(topic, lang, out_dir, preview):
    src_dir = os.path.join(FRAMES, lang, topic['id'])
    meta = json.load(open(os.path.join(src_dir, 'frames.json'), encoding='utf-8'))['frames']
    by_id = {m['id']: m for m in meta}
    wanted = frames_for(topic, lang)
    missing = [f['id'] for f in wanted if f['id'] not in by_id]
    extra = [m['id'] for m in meta if m['id'] not in {f['id'] for f in wanted}]
    if missing or extra:
        sys.exit(f"{topic['id']} {lang}: storyboardda bor, kadri yo‘q: {missing}; "
                 f"kadri bor, storyboardda yo‘q: {extra}")
    order = [m['id'] for m in meta]
    if order != [f['id'] for f in wanted]:
        sys.exit(f"{topic['id']} {lang}: kadrlar tartibi storyboard bilan bir xil emas")

    segs = [(card(topic['title'][lang], topic['subtitle'][lang], LABELS[lang][0]), None, CARD)]
    for i, f in enumerate(wanted, 1):
        m = by_id[f['id']]
        base, (x, y, s) = step_canvas(os.path.join(src_dir, m['file']), m, str(i), f['text'][lang])
        at = None if not m['tap'] else (x + m['tap'][0] * s, y + m['tap'][1] * s)
        segs.append((base, at, f['sec']))
    segs.append((card(topic['title'][lang], LABELS[lang][1], LABELS[lang][0], end=True), None, END))

    if preview:
        pdir = os.path.join(out_dir, 'preview', lang, topic['id'])
        os.makedirs(pdir, exist_ok=True)
        for i, (base, at, _) in enumerate(segs):
            draw_tap(base, at, 0.5).convert('RGB').save(os.path.join(pdir, f'{i:02d}.png'))
        return None

    out = os.path.join(out_dir, f"{topic['id']}_{lang}.mp4")
    ff = subprocess.Popen([
        'ffmpeg', '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
        '-s', f'{W}x{H}', '-r', str(FPS), '-i', '-',
        '-c:v', 'libx264', '-preset', 'medium', '-crf', '24', '-pix_fmt', 'yuv420p',
        '-tune', 'stillimage', '-an', '-movflags', '+faststart',
        '-metadata', f"title=LabGuide — {topic['title'][lang]}",
        '-metadata', f'comment={LABELS[lang][0]}',
        out,
    ], stdin=subprocess.PIPE)
    nf = int(FADE * FPS)
    for i, (base, at, dur) in enumerate(segs):
        n = int(round(dur * FPS))
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
    if ff.wait() != 0:
        sys.exit(f'ffmpeg xatosi: {out}')
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--lang', choices=['uz', 'ru', 'en'], action='append')
    ap.add_argument('--topic', action='append')
    ap.add_argument('--out', default=OUT)
    ap.add_argument('--subs-only', action='store_true')
    ap.add_argument('--preview', action='store_true')
    a = ap.parse_args()
    story = json.load(open(STORY, encoding='utf-8'))
    os.makedirs(a.out, exist_ok=True)
    for topic in story['topics']:
        if a.topic and topic['id'] not in a.topic:
            continue
        for lang in a.lang or ['uz', 'ru', 'en']:
            write_subs(topic, lang, a.out)
            if not a.subs_only:
                print(build(topic, lang, a.out, a.preview) or f"preview {topic['id']} {lang}", flush=True)


if __name__ == '__main__':
    main()
