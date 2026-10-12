"""Sitologiya bo'limi sarlavha rasmi (hero.svg) va eski chizmalar.

Hujayra kartalaridagi rasmlar — annotated/*.svg (raqamli izohli sxemalar).

Bu mikrofoto EMAS — Papanikolau bo'yog'idagi umumiy ko'rinishni o'rgatish
uchun qo'lda tuzilgan sxema (gonokokk — Gram bo'yog'ida). Belgilar
lib/features/cytology/cytology_content.dart dagi tavsif va manbalarga
tayanadi. Hamma rasm bitta masshtabda: 1 mkm = 7 px (600 px ≈ 86 mkm).

  python3 tool/illustrations/cyto/gen_cyto.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --cyto
"""
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'cells'))
from gen_cells import blob, smooth_path  # noqa: E402

UM = 7
W = H = 600
CX = CY = 300

PINK = 'url(#eo)'      # eozinofil (pushti-to'q sariq) sitoplazma
CYAN = 'url(#cy)'      # sianofil (ko'k-yashil) sitoplazma
NUC = '#2F2C66'
NUC_LIGHT = '#6E6AA6'

DEFS = '''<defs>
  <radialGradient id="bg" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="#F7F6F1"/><stop offset="1" stop-color="#E9E8E0"/></radialGradient>
  <radialGradient id="bg_gram" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="#FBF1F2"/><stop offset="1" stop-color="#F1DCDF"/></radialGradient>
  <radialGradient id="eo" cx="45%" cy="40%" r="70%"><stop offset="0" stop-color="#F9D3D2"/><stop offset="1" stop-color="#EFA7AE"/></radialGradient>
  <radialGradient id="cy" cx="45%" cy="40%" r="70%"><stop offset="0" stop-color="#CFE7E1"/><stop offset="1" stop-color="#93C3BA"/></radialGradient>
  <radialGradient id="cy_dense" cx="45%" cy="40%" r="70%"><stop offset="0" stop-color="#9FCBC2"/><stop offset="1" stop-color="#5E9F95"/></radialGradient>
  <radialGradient id="trich" cx="45%" cy="40%" r="70%"><stop offset="0" stop-color="#D5DDD6"/><stop offset="1" stop-color="#A8B7AE"/></radialGradient>
  <radialGradient id="neut" cx="45%" cy="40%" r="70%"><stop offset="0" stop-color="#EEE8EE"/><stop offset="1" stop-color="#D5CAD8"/></radialGradient>
  <radialGradient id="neut_gram" cx="45%" cy="40%" r="70%"><stop offset="0" stop-color="#F6D9DF"/><stop offset="1" stop-color="#E8B4C0"/></radialGradient>
  <filter id="soft"><feGaussianBlur stdDeviation="0.7"/></filter>
</defs>'''


def svg(body, bg='url(#bg)'):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            f'{DEFS}\n<rect width="{W}" height="{H}" fill="{bg}"/>\n{body}\n</svg>\n')


def poly(cx, cy, r, rnd, n=7, irr=0.18, rot=None):
    """Ko'pburchakli (yassi epiteliy) hujayra: burchaklari silliqlangan."""
    rot = rnd.uniform(0, 2 * math.pi) if rot is None else rot
    pts = []
    for i in range(n):
        a = rot + 2 * math.pi * i / n + rnd.uniform(-0.18, 0.18)
        rr = r * rnd.uniform(1 - irr, 1 + irr)
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return smooth_path(pts)


def folds(cx, cy, r, rnd, n=2, color='#C98A92'):
    s = []
    for _ in range(n):
        a = rnd.uniform(0, math.pi)
        L = r * rnd.uniform(0.5, 0.9)
        x0, y0 = cx + r * 0.3 * math.cos(a + 1.6), cy + r * 0.3 * math.sin(a + 1.6)
        pts = [(x0 - L / 2 * math.cos(a), y0 - L / 2 * math.sin(a)),
               (x0 + rnd.uniform(-8, 8), y0 + rnd.uniform(-8, 8)),
               (x0 + L / 2 * math.cos(a), y0 + L / 2 * math.sin(a))]
        s.append(f'<path d="{smooth_path(pts, closed=False)}" fill="none" stroke="{color}" stroke-width="2" opacity="0.45" stroke-linecap="round"/>')
    return '\n'.join(s)


def nucleus(cx, cy, r, rnd, dark=True, irregular=0.06, chrom=0):
    fill = NUC if dark else NUC_LIGHT
    s = [f'<path d="{blob(cx, cy, r, rnd, irregular)}" fill="{fill}" filter="url(#soft)"/>']
    for _ in range(chrom):
        a = rnd.uniform(0, 2 * math.pi)
        rr = r * 0.8 * math.sqrt(rnd.uniform(0, 1))
        s.append(f'<circle cx="{cx + rr * math.cos(a):.1f}" cy="{cy + rr * math.sin(a):.1f}" r="{rnd.uniform(1.2, 2.6):.1f}" fill="{NUC}" opacity="0.55"/>')
    return '\n'.join(s)


def squamous(cx, cy, rnd, kind='intermediate', r_um=None, nuc_um=None):
    """Yassi epiteliy: superficial — pushti, piknotik yadro; intermediate —
    ko'k-yashil, pufaksimon yadro."""
    if kind == 'superficial':
        r = (r_um or 24) * UM
        body = [f'<path d="{poly(cx, cy, r, rnd)}" fill="{PINK}" stroke="#D68B95" stroke-width="1.5" opacity="0.92"/>',
                folds(cx, cy, r, rnd)]
        body.append(nucleus(cx + rnd.uniform(-6, 6), cy + rnd.uniform(-6, 6), (nuc_um or 2.6) * UM, rnd, irregular=0.02))
    else:
        r = (r_um or 22) * UM
        body = [f'<path d="{poly(cx, cy, r, rnd)}" fill="{CYAN}" stroke="#6FA79D" stroke-width="1.5" opacity="0.92"/>',
                folds(cx, cy, r, rnd, color='#5E9389')]
        body.append(nucleus(cx + rnd.uniform(-6, 6), cy + rnd.uniform(-6, 6), (nuc_um or 4.2) * UM, rnd, dark=False, chrom=10))
    return '\n'.join(body)


def neutrophil(x, y, rnd, gram=False, r_um=5.5):
    R = r_um * UM
    fill = 'url(#neut_gram)' if gram else 'url(#neut)'
    nuc = '#B8476A' if gram else NUC
    s = [f'<path d="{blob(x, y, R, rnd, 0.05)}" fill="{fill}" stroke="#B9A9BE" stroke-width="1"/>']
    a0 = rnd.uniform(0, 2 * math.pi)
    for i in range(3):
        a = a0 + i * 1.5
        s.append(f'<circle cx="{x + R * 0.38 * math.cos(a):.1f}" cy="{y + R * 0.38 * math.sin(a):.1f}" r="{R * 0.3:.1f}" fill="{nuc}" opacity="0.9"/>')
    return '\n'.join(s)


def scatter(rnd, n, avoid, fn, margin=10):
    out, placed, tries = [], [], 0
    while len(placed) < n and tries < n * 200:
        tries += 1
        x, y = rnd.uniform(margin, W - margin), rnd.uniform(margin, H - margin)
        if any(math.hypot(x - ax, y - ay) < ar for ax, ay, ar in avoid + placed):
            continue
        placed.append((x, y, 40))
        out.append(fn(x, y))
    return '\n'.join(out)


def rods(rnd, n, region=None, color='#4E4A86', avoid=()):
    """Laktobatsillalar: uzun tayoqchalar."""
    s = []
    k = tries = 0
    while k < n and tries < n * 50:
        tries += 1
        if region:
            cx, cy, R = region
            a, rr = rnd.uniform(0, 2 * math.pi), R * math.sqrt(rnd.uniform(0, 1))
            x, y = cx + rr * math.cos(a), cy + rr * math.sin(a)
        else:
            x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        if any(math.hypot(x - ax, y - ay) < ar for ax, ay, ar in avoid):
            continue
        a = rnd.uniform(0, math.pi)
        L = rnd.uniform(4, 7) * UM / 2
        s.append(f'<line x1="{x - L * math.cos(a):.1f}" y1="{y - L * math.sin(a):.1f}" x2="{x + L * math.cos(a):.1f}" y2="{y + L * math.sin(a):.1f}" stroke="{color}" stroke-width="4" stroke-linecap="round" opacity="0.85"/>')
        k += 1
    return '\n'.join(s)


def cocci(rnd, region, n, color='#3E3A78', r=2.0):
    cx, cy, R = region
    s = []
    for _ in range(n):
        a, rr = rnd.uniform(0, 2 * math.pi), R * math.sqrt(rnd.uniform(0, 1))
        s.append(f'<circle cx="{cx + rr * math.cos(a):.1f}" cy="{cy + rr * math.sin(a):.1f}" r="{r * rnd.uniform(0.8, 1.2):.1f}" fill="{color}" opacity="0.8"/>')
    return '\n'.join(s)


# ───────────────────────── hujayralar ─────────────────────────

def superficial():
    rnd = random.Random(11)
    return svg(squamous(CX, CY, rnd, 'superficial'))


def intermediate():
    rnd = random.Random(12)
    return svg(squamous(CX, CY, rnd, 'intermediate'))


def parabasal():
    rnd = random.Random(13)
    body = []
    for (x, y) in [(220, 250), (380, 330), (250, 410)]:
        R = rnd.uniform(8.5, 10) * UM
        body.append(f'<path d="{blob(x, y, R, rnd, 0.05, squash=rnd.uniform(0.85, 1))}" fill="url(#cy_dense)" stroke="#4F8C83" stroke-width="1.5"/>')
        body.append(nucleus(x, y, 4.6 * UM, rnd, dark=False, chrom=8))
    return svg('\n'.join(body))


def endocervical():
    """Bo'yin kanali (silindrsimon) epiteliysi: tepadan — "asalari uyasi",
    yonidan — "panjara" (yadrolar bir chiziqda, pastda)."""
    rnd = random.Random(14)
    s = []
    d = 6.5 * UM
    for row in range(5):
        for col in range(6):
            x = 120 + col * d + (d / 2 if row % 2 else 0)
            y = 110 + row * d * 0.87
            s.append(f'<path d="{blob(x, y, d / 2 * 0.98, rnd, 0.03, n=6)}" fill="url(#cy)" stroke="#5E9389" stroke-width="1.6"/>')
            s.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{2.4 * UM:.1f}" fill="{NUC_LIGHT}" opacity="0.95"/>')
    # Yon ko'rinish: uzun hujayralar, yadro pastda.
    for i in range(7):
        x = 150 + i * 5 * UM
        top, bot = 390, 390 + 20 * UM
        s.append(f'<rect x="{x - 2.4 * UM:.1f}" y="{top}" width="{4.8 * UM:.1f}" height="{bot - top:.1f}" rx="10" fill="url(#cy)" stroke="#5E9389" stroke-width="1.6"/>')
        s.append(f'<ellipse cx="{x:.1f}" cy="{bot - 3.6 * UM:.1f}" rx="{2 * UM:.1f}" ry="{3 * UM:.1f}" fill="{NUC_LIGHT}"/>')
        s.append(f'<rect x="{x - 2.4 * UM:.1f}" y="{top}" width="{4.8 * UM:.1f}" height="{4 * UM:.1f}" rx="8" fill="#E6F1EE" opacity="0.7"/>')
    return svg('\n'.join(s))


def metaplastic():
    rnd = random.Random(15)
    s = []
    for (x, y) in [(250, 260), (390, 370)]:
        R = 10 * UM
        pts = []
        n = 14
        spikes = {2, 6, 10}
        for i in range(n):
            a = 2 * math.pi * i / n
            rr = R * (1.65 if i in spikes else rnd.uniform(0.9, 1.05))
            pts.append((x + rr * math.cos(a), y + rr * math.sin(a)))
        s.append(f'<path d="{smooth_path(pts)}" fill="url(#cy_dense)" stroke="#4F8C83" stroke-width="1.5"/>')
        s.append(nucleus(x, y, 4.4 * UM, rnd, dark=False, chrom=8))
    return svg('\n'.join(s))


def koilocyte():
    rnd = random.Random(16)
    r = 22 * UM
    s = [f'<path d="{poly(CX, CY, r, rnd)}" fill="url(#cy_dense)" stroke="#4F8C83" stroke-width="2"/>']
    # Yadro atrofidagi aniq chegarali bo'shliq (halo).
    s.append(f'<path d="{blob(CX, CY, 13 * UM, rnd, 0.06)}" fill="#F4F6F2" stroke="#3F7D74" stroke-width="3.5"/>')
    # Kattalashgan, to'q, notekis ("mayiz") yadrolar — ikki yadroli.
    s.append(nucleus(CX - 3.5 * UM, CY - 1 * UM, 4.6 * UM, rnd, irregular=0.16))
    s.append(nucleus(CX + 4.2 * UM, CY + 1.5 * UM, 4.0 * UM, rnd, irregular=0.18))
    return svg('\n'.join(s))


def clue_cell():
    rnd = random.Random(17)
    r = 22 * UM
    s = [f'<path d="{poly(CX, CY, r, rnd)}" fill="{CYAN}" stroke="#6FA79D" stroke-width="1.2" opacity="0.85"/>',
         nucleus(CX, CY, 4 * UM, rnd, dark=False)]
    # Hujayra yuzasi va chetlari kokkobatsillalar bilan qoplangan
    # (chegara "tukli", noaniq).
    s.append(cocci(rnd, (CX, CY, r * 1.08), 900, color='#2F3A6B', r=1.9))
    s.append(cocci(rnd, (CX, CY, 290), 140, color='#2F3A6B', r=1.9))
    return svg('\n'.join(s))


def lactobacilli():
    rnd = random.Random(18)
    s = [squamous(250, 270, rnd, 'intermediate', r_um=19)]
    s.append(rods(rnd, 70, avoid=[(250, 270, 19 * UM * 0.8)]))
    return svg('\n'.join(s))


def trichomonas():
    rnd = random.Random(19)
    s = [squamous(150, 470, rnd, 'intermediate', r_um=17)]
    for (x, y, rot) in [(330, 220, -0.4), (450, 380, 0.9), (220, 160, 2.2)]:
        R = 8 * UM
        pts = []
        n = 20
        for i in range(n):
            a = 2 * math.pi * i / n
            rr = R * (1 + 0.35 * math.cos(a))  # nok shakli
            px, py = rr * math.cos(a), rr * math.sin(a) * 0.78
            pts.append((x + px * math.cos(rot) - py * math.sin(rot), y + px * math.sin(rot) + py * math.cos(rot)))
        s.append(f'<path d="{smooth_path(pts)}" fill="url(#trich)" stroke="#7E9188" stroke-width="1.5"/>')
        # Ekssentrik, och, cho'ziq yadro (tor uchiga yaqin).
        nx, ny = x - 0.45 * R * math.cos(rot), y - 0.45 * R * math.sin(rot)
        s.append(f'<ellipse cx="{nx:.1f}" cy="{ny:.1f}" rx="{2.8 * UM:.1f}" ry="{1.5 * UM:.1f}" transform="rotate({math.degrees(rot):.0f} {nx:.1f} {ny:.1f})" fill="#8D8BB5" opacity="0.9"/>')
        s.append(cocci(rnd, (x + 0.2 * R * math.cos(rot), y + 0.2 * R * math.sin(rot), R * 0.6), 14, color='#C2566B', r=2.2))
        # Xivchinlar (Papanikolau surtmasida ko'pincha ko'rinmaydi).
        bx, by = x - 1.25 * R * math.cos(rot), y - 1.25 * R * math.sin(rot)
        for k in (-0.5, 0, 0.5):
            ex = bx - 9 * UM * math.cos(rot + k)
            ey = by - 9 * UM * math.sin(rot + k)
            mx, my = (bx + ex) / 2 + rnd.uniform(-10, 10), (by + ey) / 2 + rnd.uniform(-10, 10)
            s.append(f'<path d="M{bx:.1f} {by:.1f} Q{mx:.1f} {my:.1f} {ex:.1f} {ey:.1f}" fill="none" stroke="#7E9188" stroke-width="1.6" opacity="0.7"/>')
    s.append(scatter(rnd, 5, [(150, 470, 130), (330, 220, 80), (450, 380, 80), (220, 160, 80)], lambda x, y: neutrophil(x, y, rnd)))
    return svg('\n'.join(s))


def candida():
    rnd = random.Random(20)
    s = [squamous(300, 330, rnd, 'intermediate', r_um=20)]
    col = '#B98A9B'
    # Psevdogifa: ketma-ket cho'ziq bo'g'imlar (hujayralar ustidan "shish").
    x, y, a = 60, 200, 0.35
    for _ in range(11):
        L = rnd.uniform(5, 7) * UM
        ex, ey = x + L * math.cos(a), y + L * math.sin(a)
        s.append(f'<line x1="{x:.1f}" y1="{y:.1f}" x2="{ex:.1f}" y2="{ey:.1f}" stroke="{col}" stroke-width="{2.2 * UM:.1f}" stroke-linecap="round" opacity="0.9"/>')
        s.append(f'<circle cx="{ex:.1f}" cy="{ey:.1f}" r="{1.2 * UM:.1f}" fill="#9E6E80" opacity="0.6"/>')
        x, y, a = ex, ey, a + rnd.uniform(-0.25, 0.25)
    # Kurtaklanayotgan achitqi hujayralari.
    for (bx, by) in [(470, 140), (500, 470), (110, 470), (420, 520)]:
        s.append(f'<ellipse cx="{bx}" cy="{by}" rx="{2.4 * UM:.1f}" ry="{1.8 * UM:.1f}" fill="{col}"/>')
        s.append(f'<ellipse cx="{bx + 3.4 * UM:.1f}" cy="{by - 1 * UM:.1f}" rx="{1.4 * UM:.1f}" ry="{1.1 * UM:.1f}" fill="{col}"/>')
    return svg('\n'.join(s))


def inflammation():
    rnd = random.Random(21)
    s = [squamous(300, 300, rnd, 'intermediate', r_um=18)]
    s.append(scatter(rnd, 26, [(300, 300, 18 * UM * 0.7)], lambda x, y: neutrophil(x, y, rnd), margin=20))
    return svg('\n'.join(s))


def gonococcus():
    """Gram bo'yog'i: neytrofillar ichida juft, loviyasimon gramm-manfiy
    (qizil-pushti) diplokokklar."""
    rnd = random.Random(22)
    s = []
    for (x, y) in [(220, 230), (400, 360), (190, 430)]:
        R = 6.5 * UM
        s.append(neutrophil(x, y, rnd, gram=True, r_um=6.5))
        for _ in range(5):
            a, rr = rnd.uniform(0, 2 * math.pi), R * 0.75 * math.sqrt(rnd.uniform(0.2, 1))
            px, py = x + rr * math.cos(a), y + rr * math.sin(a)
            rot = rnd.uniform(0, 180)
            for sgn in (-1, 1):
                s.append(f'<ellipse cx="{px + sgn * 4.8:.1f}" cy="{py:.1f}" rx="4.6" ry="6.2" transform="rotate({rot:.0f} {px:.1f} {py:.1f})" fill="#C0304F"/>')
    return svg('\n'.join(s), bg='url(#bg_gram)')


def hsil():
    rnd = random.Random(23)
    s = [squamous(160, 170, rnd, 'intermediate', r_um=17)]
    for (x, y) in [(360, 330), (430, 300), (400, 400), (330, 420), (470, 380)]:
        R = rnd.uniform(5.5, 6.5) * UM
        s.append(f'<path d="{blob(x, y, R, rnd, 0.07)}" fill="url(#cy_dense)" stroke="#4F8C83" stroke-width="1.3"/>')
        s.append(nucleus(x, y, R * 0.72, rnd, irregular=0.18, chrom=12))
    return svg('\n'.join(s))


CELLS = {
    'superficial': superficial,
    'intermediate': intermediate,
    'parabasal': parabasal,
    'endocervical': endocervical,
    'metaplastic': metaplastic,
    'koilocyte': koilocyte,
    'clue_cell': clue_cell,
    'lactobacilli': lactobacilli,
    'trichomonas': trichomonas,
    'candida': candida,
    'inflammation': inflammation,
    'gonococcus': gonococcus,
    'hsil': hsil,
}


def hero():
    """Sarlavha rasmi (1200×520): bir nechta asosiy element yonma-yon."""
    rnd = random.Random(30)
    hw, hh = 1200, 520
    parts = [squamous(170, 270, rnd, 'superficial', r_um=26),
             squamous(470, 250, rnd, 'intermediate', r_um=24)]
    # Koilotsit
    r = 23 * UM
    parts.append(f'<path d="{poly(790, 270, r, rnd)}" fill="url(#cy_dense)" stroke="#4F8C83" stroke-width="2"/>')
    parts.append(f'<path d="{blob(790, 270, 13 * UM, rnd, 0.06)}" fill="#F4F6F2" stroke="#3F7D74" stroke-width="3.5"/>')
    parts.append(nucleus(790 - 3 * UM, 270, 4.6 * UM, rnd, irregular=0.16))
    parts.append(nucleus(790 + 4 * UM, 272, 3.9 * UM, rnd, irregular=0.18))
    parts.append(rods(rnd, 40, region=(1060, 260, 150)))
    for (x, y) in [(330, 450), (650, 460), (980, 450), (1100, 120)]:
        parts.append(neutrophil(x, y, rnd))
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {hw} {hh}" width="{hw}" height="{hh}">\n'
            f'{DEFS}\n<rect width="{hw}" height="{hh}" fill="url(#bg)"/>\n' + '\n'.join(parts) + '\n</svg>\n')


if __name__ == '__main__':
    # Hujayra rasmlari endi annotated/ dagi izohli sxemalardan (egasi bergan
    # paket, 2026-10-12): assets/cytology/<id>.png. Bu skript faqat sarlavha
    # rasmini yasaydi (render.cjs --cyto hero).
    with open(os.path.join(HERE, 'hero.svg'), 'w') as f:
        f.write(hero())
    print('svg hero')
