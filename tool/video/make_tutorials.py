#!/usr/bin/env python3
"""LabGuide ustoz/talaba o'quv videolarini yig'ish (ffmpeg + Pillow + numpy).

Kadrlar: `flutter test tool/video/frames_test.dart --update-goldens`
(haqiqiy ilova vidjetlari, 1080x1920 PNG + frames.json: bosiladigan vidjet
to'rtburchagi, logik 360x640).

    python3 tool/video/make_tutorials.py [--only 1 3] [--frames DIR] [--out DIR]

Chiqish: NN_nom.mp4 (1080x1920, H.264, 30 fps, yuv420p, faststart), .srt,
.txt (tavsif + hashtag), _contact.png. Ovoz/musiqa yo'q (jim AAC trek bor).
"""
import argparse
import json
import math
import os
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(ROOT))
LOGO = os.path.join(REPO, 'assets/images/logo_mark_large.png')
FONT_DIR = '/usr/share/fonts/opentype/inter/'
W, H, FPS = 1080, 1920, 30
SCALE = 3  # logik px -> piksel
SAFE_TOP, SAFE_BOTTOM = 220, 380  # Shorts/Reels interfeysi uchun
# Ilova kadrining yuqoridagi bo'sh holat paneli (47 dp * 3) kesib tashlanadi:
# kontent 141 px yuqoriga siljiydi, navigatsiya paneli xavfsiz zonaga yaqinlashadi.
SHIFT_UP = 141
XFADE = 0.4
TITLE_SEC, END_SEC = 3.5, 4.5
BG1, BG2 = (10, 52, 42), (22, 94, 76)
ACCENT = (255, 184, 0)

CONTACT = 'labguide@nfcstore.uz'
END_LINES = ['LabGuide', 'TestFlight / Google Play sinov versiyasi',
             f'Savollar: {CONTACT}']

# ---------------------------------------------------------------- mazmun
# Har video: kadr papkasi, sarlavha, kim uchun, kadrlar (id -> sarlavha matni).
VIDEOS = [
    dict(
        n=1, frames='v1', slug='ustoz_royxatdan_otish',
        title='Ustoz sifatida ro‘yxatdan o‘tish', sub='Ustozlar uchun qo‘llanma',
        caps=[
            ('til', 'Ilovani oching va tilni tanlang: O‘zbekcha'),
            ('welcome', '“Boshlash / ro‘yxatdan o‘tish” tugmasini bosing'),
            ('auth', 'Email manzilingizni kiriting'),
            ('auth_filled', 'Foydalanish shartlariga rozilik bering'),
            ('auth_consent', '“Kod olish” — emailingizga 6 xonali kod keladi'),
            ('otp', 'Emailga kelgan 6 xonali kodni kiriting'),
            ('role', 'Rolni tanlang: “Ustoz / tadqiqotchi”'),
            ('role_picked', '“Davom etish” tugmasini bosing'),
            ('home', 'Pastdagi “O‘rganish” bo‘limini oching'),
            ('learn', '“Guruh va topshiriqlar” bo‘limiga kiring'),
            ('classes', '“Guruh yaratish” kartasini bosing'),
            ('register', '“Ustoz sifatida ro‘yxatdan o‘tish” tugmasini bosing'),
            ('registered', 'Tayyor! Endi siz ustozsiz va guruh yarata olasiz'),
        ],
        desc=('LabGuide ilovasida ustoz sifatida ro‘yxatdan o‘tish: til tanlash, '
              'email va kod bilan kirish, “Ustoz / tadqiqotchi” rolini tanlash '
              'va “Ustoz sifatida ro‘yxatdan o‘tish” tugmasi. Qadamma-qadam, '
              '1 daqiqada.'),
        tags='#LabGuide #ustoz #laboratoriya #tibbiyotkolleji #oqituvchi '
             '#oʻzbekiston #biokimyo #shorts #reels',
    ),
    dict(
        n=2, frames='v2', slug='guruh_yaratish',
        title='Guruh yaratish va talabalarni qo‘shish',
        sub='Ustozlar uchun qo‘llanma',
        caps=[
            ('classes', '“Guruh yaratish” kartasini bosing'),
            ('create', 'Guruh nomini yozing'),
            ('named', '“Guruhni yaratish” tugmasini bosing'),
            ('code', 'Guruh tayyor! 8 belgili taklif kodi shu yerda'),
            ('code_qr', 'Talabalar kodni yozadi yoki QR kodni skanerlaydi'),
            ('code_qr_low', 'Kodni yoki taklif matnini nusxalab yuboring'),
            ('student_classes', 'Talaba: “Kod bilan qo‘shilish” ni bosadi'),
            ('join', 'Talaba ustoz bergan kodni kiritadi'),
            ('join_code', 'So‘ng “Qo‘shilish” tugmasini bosadi'),
            ('joined', 'Talaba guruhga qo‘shildi'),
            ('teacher_group', 'Ustozda a’zolar soni oshadi'),
            ('members', 'Talabalar taxallus bilan ko‘rinadi: Talaba 01, Talaba 02'),
        ],
        desc=('LabGuide: guruh yaratish, 8 belgili taklif kodi va QR, talaba '
              'kod bilan qanday qo‘shilishi va ustozda a’zolar ro‘yxati '
              '(Talaba 01, Talaba 02 — haqiqiy ism serverda saqlanmaydi).'),
        tags='#LabGuide #ustoz #guruh #talaba #laboratoriya #tibbiyotkolleji '
             '#oqituvchi #oʻzbekiston #shorts #reels',
    ),
    dict(
        n=3, frames='v3', slug='dars_otish',
        title='Dars o‘tish: mavzu, ma’ruza, savol-javob',
        sub='Ustozlar uchun qo‘llanma',
        caps=[
            ('classes', 'Guruhlar ro‘yxatidan guruhingizni oching'),
            ('group', '“O‘quv rejasi” bo‘limini oching'),
            ('plan', '6 oylik o‘quv dasturi: modullar va mavzular'),
            ('plan_topic', 'Dars o‘tadigan mavzuni tanlang'),
            ('topic', '“Talabalarga ochish” — mavzu talabalarda ko‘rinadi'),
            ('lecture_stage', '1-bosqich: “Ma’ruzani boshlash” ni bosing'),
            ('slide1', 'Slaydlar katta ekranda ko‘rsatiladi'),
            ('slide2', '“Oldinga” bilan keyingi slaydga o‘ting'),
            ('back', 'Ma’ruza tugadi: “O‘tildi deb belgilash”'),
            ('oral_stage', '2-bosqich: og‘zaki savol-javob'),
            ('oral', 'Tayyor savollar va qisqa javob rejasi'),
            ('oral_low', 'Savol berilgach, “So‘raldi” ni belgilang'),
        ],
        desc=('LabGuide: 6 oylik o‘quv rejasini ochish, mavzuni talabalarga '
              'ochish, ma’ruzani slaydlar bilan o‘tish va og‘zaki savol-javob '
              'bosqichi.'),
        tags='#LabGuide #ustoz #dars #maruza #laboratoriya #tibbiyotkolleji '
             '#oqituvchi #oʻzbekiston #shorts #reels',
    ),
    dict(
        n=4, frames='v4', slug='test_otkazish',
        title='Test o‘tkazish va natijalarni ko‘rish',
        sub='Ustozlar uchun qo‘llanma',
        caps=[
            ('topic', '3-bosqich: “Testni tayyorlash” ni bosing'),
            ('minutes', 'Test vaqtini tanlang, masalan 10 daqiqa'),
            ('pick_all', '“Hammasi” — barcha savollarni tanlang'),
            ('picked', '“Testni boshlash” — talabalarda darhol ochiladi'),
            ('s_topic_test', 'Talaba ekrani: mavzuda test ochiq'),
            ('s_test_intro', 'Talaba “Boshlash” ni bosadi'),
            ('s_answer', 'Javob variantini tanlaydi'),
            ('s_answered', '“Keyingi” — keyingi savolga o‘tadi'),
            ('s_finish', 'Oxirida “Yakunlash” tugmasi'),
            ('s_result', 'Talaba natijasini darhol ko‘radi'),
            ('teacher_state', 'Ustoz: kim topshirdi — “Natijalar paneli”'),
            ('results', 'Natijalar: topshirganlar soni va o‘rtacha ball'),
            ('results_students', 'Har talabaning bahosi taxallus bilan ko‘rinadi'),
            ('results_low', 'Har savol bo‘yicha xatolar: nimani qaytarish kerak'),
        ],
        desc=('LabGuide: mavzu testini boshlash, talaba tomonidan yechish va '
              'ustoz uchun natijalar paneli (o‘rtacha ball, savollar bo‘yicha '
              'xatolar).'),
        tags='#LabGuide #ustoz #test #natijalar #laboratoriya #tibbiyotkolleji '
             '#oqituvchi #oʻzbekiston #shorts #reels',
    ),
    dict(
        n=5, frames='v5', slug='talaba_qoshilish_test',
        title='Talaba uchun: qo‘shilish va test yechish',
        sub='Talabalar uchun qo‘llanma',
        caps=[
            ('learn', '“Guruh va topshiriqlar” bo‘limini oching'),
            ('classes', '“Kod bilan qo‘shilish” ni bosing'),
            ('join', 'Ustoz bergan 8 belgili kodni yozing'),
            ('code_typed', '“Qo‘shilish” tugmasini bosing'),
            ('joined', 'Ustoz sizni taxallus yoki tartib raqam bilan ko‘radi'),
            ('s_topic_test', 'Ustoz testni ochganda mavzuda paydo bo‘ladi'),
            ('s_test_intro', '“Boshlash” ni bosing — vaqt hisoblanadi'),
            ('s_answer', 'Javob variantini tanlang'),
            ('s_answered', '“Keyingi” bilan davom eting'),
            ('s_finish', 'Oxirgi savoldan keyin “Yakunlash”'),
            ('s_confirm', 'Tasdiqlang — javoblar ustozga yuboriladi'),
            ('s_result', 'Natijangiz darhol chiqadi'),
        ],
        desc=('LabGuide talabalar uchun: ustoz bergan kod bilan guruhga '
              'qo‘shilish va mavzu testini yechish — boshidan oxirigacha. '
              'Do‘stlaringizga yuboring!'),
        tags='#LabGuide #talaba #test #laboratoriya #tibbiyotkolleji '
             '#oʻzbekiston #oqish #shorts #reels',
    ),
]


# ---------------------------------------------------------------- yordamchi
def font(size, weight='Bold'):
    return ImageFont.truetype(f'{FONT_DIR}Inter-{weight}.otf', size)


def text_w(draw, s, f):
    return draw.textlength(s, font=f)


def wrap(draw, s, f, width):
    lines, cur = [], ''
    for word in s.split(' '):
        t = (cur + ' ' + word).strip()
        if text_w(draw, t, f) <= width or not cur:
            cur = t
        else:
            lines.append(cur)
            cur = word
    lines.append(cur)
    return lines


def fit_caption(draw, s, width, sizes=(56, 52, 48, 44, 40)):
    """Eng katta shrift bilan 2 qatorga sig'dirish."""
    for sz in sizes:
        f = font(sz)
        lines = wrap(draw, s, f, width)
        if len(lines) <= 2:
            return f, sz, lines
    print(f'OGOHLANTIRISH: 2 qatorga sig‘madi: {s}', file=sys.stderr)
    return f, sz, lines


def gradient_bg():
    t = np.linspace(0, 1, H)[:, None, None]
    a = np.array(BG1)[None, None, :]
    b = np.array(BG2)[None, None, :]
    arr = (a * (1 - t) + b * t).astype(np.uint8)
    return Image.fromarray(np.repeat(arr, W, axis=1), 'RGB')


def centered(draw, y, s, f, fill, width=W):
    w = text_w(draw, s, f)
    draw.text(((width - w) / 2, y), s, font=f, fill=fill)


def title_card(video):
    im = gradient_bg()
    d = ImageDraw.Draw(im)
    logo = Image.open(LOGO).convert('RGBA').resize((340, 340), Image.LANCZOS)
    im.paste(logo, ((W - 340) // 2, 380), logo)
    centered(d, 770, 'LabGuide', font(84), (255, 255, 255))
    f = font(66)
    y = 920
    for ln in wrap(d, video['title'], f, 900):
        centered(d, y, ln, f, (255, 255, 255))
        y += 86
    centered(d, y + 40, video['sub'], font(42, 'Medium'), ACCENT)
    centered(d, 1440, 'Namunaviy ma’lumotlar bilan ko‘rsatilgan',
             font(32, 'Medium'), (190, 215, 205))
    return im


def end_card():
    im = gradient_bg()
    d = ImageDraw.Draw(im)
    logo = Image.open(LOGO).convert('RGBA').resize((300, 300), Image.LANCZOS)
    im.paste(logo, ((W - 300) // 2, 400), logo)
    centered(d, 740, END_LINES[0], font(92), (255, 255, 255))
    f = font(50)
    y = 890
    for ln in wrap(d, END_LINES[1], f, 900):
        centered(d, y, ln, f, (255, 255, 255))
        y += 70
    centered(d, y + 50, END_LINES[2], font(46, 'SemiBold'), ACCENT)
    return im


def caption_layout(rect_px, text, idx, total, base=None):
    """Sarlavha paneli joyi: xavfsiz zona ichida (tepa 220 va past 380 px
    tashqarida), ajratilgan vidjetni yopmaydigan va ilova kontentini eng kam
    yopadigan balandlik tanlanadi."""
    probe = ImageDraw.Draw(Image.new('RGB', (10, 10)))
    pad_x, pad_y = 44, 28
    f, sz, lines = fit_caption(probe, text, 900 - 2 * pad_x + 40)
    lh = int(sz * 1.28)
    bar_h = len(lines) * lh + 2 * pad_y
    top_y = SAFE_TOP + 72  # hisoblagich pill'i uchun joy
    bot_y = H - SAFE_BOTTOM - bar_h
    mask = None
    if base is not None:
        a = np.asarray(base).astype(int)
        bg = a[SAFE_TOP + 40, 8]
        m = (np.abs(a[:, 60:W - 60] - bg).max(axis=2) > 28).sum(axis=1)
        mask = np.concatenate([[0], np.cumsum(m)])

    def cost(y):
        c = 0.0
        if mask is not None:
            c = (mask[y + bar_h] - mask[y - 62]) / ((bar_h + 62) * (W - 120))
        if rect_px is not None:
            x, yy, w, h = rect_px
            mg = 28
            if not (yy + h + mg < y - 66 or yy - mg > y + bar_h):
                c += 10.0
        return c

    best = min(range(top_y, bot_y + 1, 12),
               key=lambda y: (round(cost(y), 3), abs(y - bot_y) if False else 0))
    # teng bo'lsa — tepa/pastki chekka afzal (ko'z odatlangan joy)
    ties = [y for y in range(top_y, bot_y + 1, 12)
            if abs(cost(y) - cost(best)) < 0.004]
    y = min(ties, key=lambda v: min(abs(v - top_y), abs(v - bot_y)))
    return dict(y=y, bar_h=bar_h, f=f, lines=lines, lh=lh, pad_y=pad_y)


def draw_caption(im, lay, idx, total):
    ov = Image.new('RGBA', im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    x0, x1 = 60, W - 60
    y, bh = lay['y'], lay['bar_h']
    d.rounded_rectangle([x0, y, x1, y + bh], radius=36, fill=(8, 30, 25, 238))
    d.rounded_rectangle([x0, y, x1, y + bh], radius=36,
                        outline=(255, 255, 255, 60), width=2)
    ty = y + lay['pad_y'] - 4
    for ln in lay['lines']:
        w = text_w(d, ln, lay['f'])
        d.text(((W - w) / 2, ty), ln, font=lay['f'], fill=(255, 255, 255, 255))
        ty += lay['lh']
    # qadam hisoblagichi
    cf = font(36)
    s = f'{idx}/{total}'
    cw = text_w(d, s, cf) + 44
    cy = y - 62
    d.rounded_rectangle([x0, cy, x0 + cw, cy + 52], radius=26,
                        fill=ACCENT + (255,))
    d.text((x0 + 22, cy + 3), s, font=cf, fill=(20, 20, 20, 255))
    out = im.convert('RGBA')
    out.alpha_composite(ov)
    return out.convert('RGB')


def highlight_overlay(rect_px, kind, t):
    """Animatsiyali ajratish: pulsatsiyalanuvchi kontur + bosish doirasi.
    Qaytaradi: (RGBA rasm, (x, y) joylashuv) yoki None."""
    if rect_px is None:
        return None
    x, y, w, h = rect_px
    appear = min(1.0, max(0.0, (t - 0.45) / 0.35))
    if appear <= 0:
        return None
    mar = 70
    S = 2  # supersampling
    ow, oh = int(w + 2 * mar), int(h + 2 * mar)
    im = Image.new('RGBA', (ow * S, oh * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    pulse = 0.5 + 0.5 * math.sin(2 * math.pi * (t - 0.45) / 1.1)
    grow = 8 + 8 * pulse
    a = int(255 * appear)
    r = [(mar - grow) * S, (mar - grow) * S, (mar + w + grow) * S,
         (mar + h + grow) * S]
    rad = int(min(36, (h + 2 * grow) / 2) * S)
    d.rounded_rectangle(r, radius=rad, outline=(255, 255, 255, a), width=16 * S // 1)
    d.rounded_rectangle(r, radius=rad, outline=ACCENT + (a,), width=10 * S // 1)
    if kind == 'tap':
        cx, cy = (mar + (w - min(80, w / 2) if w > 240 else w / 2)) * S, (mar + h / 2) * S
        # tap nuqtasi
        pr = (30 + 5 * pulse) * S
        d.ellipse([cx - pr, cy - pr, cx + pr, cy + pr],
                  fill=ACCENT + (int(95 * appear),),
                  outline=(255, 255, 255, a), width=5 * S)
        # kengayuvchi to'lqin
        ph = ((t - 0.45) % 1.1) / 1.1
        rr = (30 + 60 * ph) * S
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr],
                  outline=ACCENT + (int(200 * (1 - ph) * appear),), width=6 * S)
    im = im.resize((ow, oh), Image.LANCZOS)
    return im, (int(x - mar), int(y - mar))


def paste_overlay(arr, ov):
    if ov is None:
        return arr
    im, (ox, oy) = ov
    x0, y0 = max(ox, 0), max(oy, 0)
    x1, y1 = min(ox + im.width, W), min(oy + im.height, H)
    if x1 <= x0 or y1 <= y0:
        return arr
    crop = im.crop((x0 - ox, y0 - oy, x1 - ox, y1 - oy))
    o = np.asarray(crop, dtype=np.uint16)
    al = o[..., 3:4]
    reg = arr[y0:y1, x0:x1].astype(np.uint16)
    arr[y0:y1, x0:x1] = ((reg * (255 - al) + o[..., :3] * al) // 255).astype(
        np.uint8)
    return arr


# ---------------------------------------------------------------- yig'ish
def shift_up(im):
    a = np.asarray(im)
    pad = np.repeat(a[-1:, :, :], SHIFT_UP, axis=0)
    return Image.fromarray(np.concatenate([a[SHIFT_UP:], pad], axis=0))


def ink(base, y0, y1):
    """Sahifa foni rangidan farq qiladigan piksellar ulushi (yopiladigan kontent)."""
    a = np.asarray(base)
    bg = a[SAFE_TOP + 40, 8].astype(int)
    reg = a[max(0, y0):min(H, y1), 40:W - 40].astype(int)
    return float((np.abs(reg - bg).max(axis=2) > 28).mean())


def build_scenes(video, frames_dir):
    meta = {f['id']: f for f in json.load(
        open(os.path.join(frames_dir, video['frames'], 'frames.json')))}
    total = len(video['caps'])
    scenes = []
    scenes.append(dict(kind='title', img=title_card(video),
                       dur=TITLE_SEC, caption=video['title'], rect=None,
                       hk=None))
    for i, (fid, cap) in enumerate(video['caps'], 1):
        fr = meta[fid]
        base = Image.open(os.path.join(frames_dir, video['frames'],
                                       fr['file'])).convert('RGB')
        assert base.size == (W, H), base.size
        base = shift_up(base)
        rect = None
        if fr['rect']:
            rect = [c * SCALE for c in fr['rect']]
            rect[1] -= SHIFT_UP
        lay = caption_layout(rect, cap, i, total, base)
        img = draw_caption(base, lay, i, total)
        dur = min(5.0, max(3.4, 3.0 + len(cap) / 30.0))
        scenes.append(dict(kind='frame', img=img, dur=dur, caption=cap,
                           rect=rect, hk=fr['kind']))
    scenes.append(dict(kind='end', img=end_card(), dur=END_SEC,
                       caption=' / '.join(END_LINES[1:]), rect=None, hk=None))
    t = 0.0
    for s in scenes:
        s['t0'] = t
        s['arr'] = np.asarray(s['img'], dtype=np.uint8)
        t += s['dur'] - XFADE
    total_dur = t + XFADE
    return scenes, total_dur


def scene_frame(s, tl):
    arr = s['arr'].copy()
    if s['rect'] is not None:
        arr = paste_overlay(arr, highlight_overlay(s['rect'], s['hk'], tl))
    return arr


def render_video(video, frames_dir, out_dir):
    scenes, total = build_scenes(video, frames_dir)
    name = f"{video['n']:02d}_{video['slug']}"
    mp4 = os.path.join(out_dir, name + '.mp4')
    nframes = int(round(total * FPS))
    cmd = ['ffmpeg', '-y', '-loglevel', 'error',
           '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{W}x{H}',
           '-r', str(FPS), '-i', '-',
           '-f', 'lavfi', '-i', 'anullsrc=r=44100:cl=stereo',
           '-t', f'{nframes / FPS:.3f}',
           '-c:v', 'libx264', '-preset', 'medium', '-crf', '24',
           '-profile:v', 'high', '-pix_fmt', 'yuv420p', '-r', str(FPS),
           '-c:a', 'aac', '-b:a', '48k',
           '-movflags', '+faststart', mp4]
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    for n in range(nframes):
        t = n / FPS
        cur = [i for i, s in enumerate(scenes)
               if s['t0'] <= t < s['t0'] + s['dur']]
        if not cur:
            cur = [len(scenes) - 1]
        a = cur[0]
        arr = scene_frame(scenes[a], t - scenes[a]['t0'])
        if len(cur) == 2:
            b = cur[1]
            k = int(255 * (t - scenes[b]['t0']) / XFADE)
            arr2 = scene_frame(scenes[b], t - scenes[b]['t0'])
            arr = ((arr.astype(np.uint16) * (255 - k) + arr2.astype(np.uint16) * k)
                   // 255).astype(np.uint8)
        p.stdin.write(arr.tobytes())
    p.stdin.close()
    if p.wait() != 0:
        raise SystemExit('ffmpeg xato')
    write_srt(os.path.join(out_dir, name + '.srt'), scenes)
    write_txt(os.path.join(out_dir, name + '.txt'), video, total)
    contact_sheet(os.path.join(out_dir, name + '_contact.png'), video, scenes)
    print(f'{name}.mp4  {total:.1f} s  {os.path.getsize(mp4) / 1e6:.1f} MB')


def ts(sec):
    ms = int(round(sec * 1000))
    h, ms = divmod(ms, 3600000)
    m, ms = divmod(ms, 60000)
    s, ms = divmod(ms, 1000)
    return f'{h:02d}:{m:02d}:{s:02d},{ms:03d}'


def write_srt(path, scenes):
    lines = []
    for i, s in enumerate(scenes, 1):
        a = s['t0'] + (0.2 if i > 1 else 0.0)
        b = s['t0'] + s['dur'] - (XFADE / 2 if i < len(scenes) else 0.0)
        lines += [str(i), f'{ts(a)} --> {ts(b)}', s['caption'], '']
    open(path, 'w', encoding='utf-8').write('\n'.join(lines))


def write_txt(path, video, total):
    txt = (f"{video['title']} | LabGuide\n\n{video['desc']}\n\n"
           'LabGuide — laboratoriya amaliyoti va o‘rganish ilovasi. '
           'Hozir TestFlight / Google Play sinov versiyasida.\n'
           'Videodagi ma’lumotlar namunaviy (demo): guruh “KDL-1 (namuna)”, '
           'ustoz@example.com, Talaba 01/02.\n'
           f'Savollar: {CONTACT}\n\n{video["tags"]}\n')
    open(path, 'w', encoding='utf-8').write(txt)


def contact_sheet(path, video, scenes):
    cols = 6
    tw, th = 270, 480
    rows = (len(scenes) + cols - 1) // cols
    sheet = Image.new('RGB', (cols * (tw + 10) + 10, rows * (th + 10) + 10),
                      (30, 30, 30))
    for i, s in enumerate(scenes):
        arr = s['arr'].copy()
        if s['rect'] is not None:
            arr = paste_overlay(arr, highlight_overlay(s['rect'], s['hk'], 1.0))
        im = Image.fromarray(arr).resize((tw, th), Image.LANCZOS)
        sheet.paste(im, (10 + (i % cols) * (tw + 10), 10 + (i // cols) * (th + 10)))
    sheet.save(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--only', type=int, nargs='*')
    ap.add_argument('--frames', default='/home/user/labguide-videos/work/frames')
    ap.add_argument('--out', default='/home/user/labguide-videos')
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    for v in VIDEOS:
        if a.only and v['n'] not in a.only:
            continue
        render_video(v, a.frames, a.out)


if __name__ == '__main__':
    main()
