"""Leykoformula uchun sxematik hujayra chizmalari (SVG).

Bu mikrofoto EMAS — Romanovskiy bo'yog'idagi umumiy ko'rinishni o'rgatish
uchun qo'lda tuzilgan sxema. Belgilar (o'lcham, yadro, sitoplazma,
donachalar) JSST "Manual of basic techniques for a health laboratory"
(2-nashr, 2003), 9.10.4-bo'lim tavsifiga tayanadi.

Barcha rasmlar bitta masshtabda: 1 mkm = 16 px (600 px = 37,5 mkm).
Taqqoslash uchun chetda eritrotsitlar (~7,5 mkm) chizilgan.

  python3 tool/illustrations/cells/gen_cells.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --cells
"""
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
UM = 16  # 1 mkm piksellarda
W = H = 600
CX = CY = 300


def blob(cx, cy, r, rnd, wobble=0.04, n=28, squash=1.0, rot=0.0, dent=None):
    """Silliq tartibsiz aylana (Catmull-Rom → kubik Bezye)."""
    phases = [(k, rnd.uniform(0, 2 * math.pi), rnd.uniform(0.3, 1.0)) for k in (2, 3, 5)]
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        rr = r * (1 + wobble * sum(a * math.sin(k * t + p) for k, p, a in phases))
        if dent:
            # dent = (burchak, chuqurlik 0..1, kenglik radianda)
            ang, depth, width = dent
            d = math.atan2(math.sin(t - ang), math.cos(t - ang))
            rr *= 1 - depth * math.exp(-(d / width) ** 2)
        x = rr * math.cos(t)
        y = rr * math.sin(t) * squash
        xr = x * math.cos(rot) - y * math.sin(rot)
        yr = x * math.sin(rot) + y * math.cos(rot)
        pts.append((cx + xr, cy + yr))
    return smooth_path(pts)


def smooth_path(pts, closed=True):
    n = len(pts)
    d = f'M{pts[0][0]:.1f} {pts[0][1]:.1f}'
    rng = range(n) if closed else range(n - 1)
    for i in rng:
        p0 = pts[(i - 1) % n] if closed or i > 0 else pts[i]
        p1 = pts[i]
        p2 = pts[(i + 1) % n]
        p3 = pts[(i + 2) % n] if closed or i + 2 < n else p2
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d += f' C{c1[0]:.1f} {c1[1]:.1f} {c2[0]:.1f} {c2[1]:.1f} {p2[0]:.1f} {p2[1]:.1f}'
    return d + (' Z' if closed else '')


def rbc_layer(rnd, avoid_r, count=9):
    """Fondagi eritrotsitlar: markaziy oqarish bilan, hujayradan tashqarida."""
    out = []
    placed = []
    tries = 0
    while len(placed) < count and tries < 4000:
        tries += 1
        r = 7.5 * UM / 2 * rnd.uniform(0.94, 1.06)
        x = rnd.uniform(-20, W + 20)
        y = rnd.uniform(-20, H + 20)
        if math.hypot(x - CX, y - CY) < avoid_r + r + 6:
            continue
        if any(math.hypot(x - px, y - py) < r + pr + 4 for px, py, pr in placed):
            continue
        placed.append((x, y, r))
    for x, y, r in placed:
        out.append(f'<path d="{blob(x, y, r, rnd, 0.008)}" fill="url(#rbc)" stroke="#E2A2A8" stroke-width="1"/>')
    return '\n'.join(out)


def dots(rnd, region, n, rmin, rmax, colors, opacity=(0.75, 1.0), avoid=None, ring=None):
    """Donachalar: [region] (cx, cy, R) aylana ichida, [avoid] ro'yxatidagi
    aylanalardan tashqarida."""
    cx, cy, R = region
    out = []
    k = 0
    tries = 0
    while k < n and tries < n * 60:
        tries += 1
        a = rnd.uniform(0, 2 * math.pi)
        rr = R * math.sqrt(rnd.uniform(0, 1))
        if ring and rr < ring:
            continue
        x, y = cx + rr * math.cos(a), cy + rr * math.sin(a)
        if avoid and any(math.hypot(x - ax, y - ay) < ar for ax, ay, ar in avoid):
            continue
        g = rnd.uniform(rmin, rmax)
        c = rnd.choice(colors)
        o = rnd.uniform(*opacity)
        out.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{g:.2f}" fill="{c}" opacity="{o:.2f}"/>')
        k += 1
    return '\n'.join(out)


def chromatin(rnd, cid, region, n, light, dark):
    """Yadro ichidagi xromatin naqshi (maska bilan yadro shakliga qirqiladi)."""
    cx, cy, R = region
    s = [f'<g mask="url(#{cid})">']
    for _ in range(n):
        a = rnd.uniform(0, 2 * math.pi)
        rr = R * math.sqrt(rnd.uniform(0, 1))
        x, y = cx + rr * math.cos(a), cy + rr * math.sin(a)
        if rnd.random() < 0.55:
            s.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rnd.uniform(2, 7):.1f}" fill="{dark}" opacity="{rnd.uniform(0.25, 0.6):.2f}"/>')
        else:
            s.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rnd.uniform(2, 6):.1f}" fill="{light}" opacity="{rnd.uniform(0.15, 0.4):.2f}"/>')
    s.append('</g>')
    return '\n'.join(s)


def strands(rnd, cid, region, n, color, width=2.2, opacity=0.45):
    """Monotsit/blast xromatinining ipsimon (to'rsimon) naqshi."""
    cx, cy, R = region
    s = [f'<g mask="url(#{cid})" fill="none" stroke="{color}" stroke-linecap="round">']
    for _ in range(n):
        a = rnd.uniform(0, 2 * math.pi)
        rr = R * math.sqrt(rnd.uniform(0, 1))
        x, y = cx + rr * math.cos(a), cy + rr * math.sin(a)
        pts = [(x, y)]
        ang = rnd.uniform(0, 2 * math.pi)
        for _ in range(4):
            ang += rnd.uniform(-0.9, 0.9)
            L = rnd.uniform(6, 14)
            x, y = x + L * math.cos(ang), y + L * math.sin(ang)
            pts.append((x, y))
        s.append(f'<path d="{smooth_path(pts, closed=False)}" stroke-width="{width * rnd.uniform(0.7, 1.3):.1f}" opacity="{opacity * rnd.uniform(0.6, 1.2):.2f}"/>')
    s.append('</g>')
    return '\n'.join(s)


DEFS = '''<defs>
  <radialGradient id="bg" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="#FBF7F4"/><stop offset="1" stop-color="#EFE6E6"/></radialGradient>
  <radialGradient id="rbc" cx="50%" cy="50%" r="50%"><stop offset="0" stop-color="#FAEDEC"/><stop offset="0.35" stop-color="#F7E1E1"/><stop offset="0.7" stop-color="#EDB6BA"/><stop offset="1" stop-color="#E39CA3"/></radialGradient>
  <radialGradient id="cyto_neut" cx="50%" cy="45%" r="55%"><stop offset="0" stop-color="#F6E3EA"/><stop offset="1" stop-color="#E9CBD8"/></radialGradient>
  <radialGradient id="cyto_eos" cx="50%" cy="45%" r="55%"><stop offset="0" stop-color="#F6E2E4"/><stop offset="1" stop-color="#EBC9CF"/></radialGradient>
  <radialGradient id="cyto_baso" cx="50%" cy="45%" r="55%"><stop offset="0" stop-color="#E7DCEB"/><stop offset="1" stop-color="#D4C2DE"/></radialGradient>
  <radialGradient id="cyto_lymph" cx="50%" cy="50%" r="55%"><stop offset="0" stop-color="#A9C3E6"/><stop offset="1" stop-color="#7D9FD3"/></radialGradient>
  <radialGradient id="cyto_mono" cx="50%" cy="45%" r="55%"><stop offset="0" stop-color="#D9D8E6"/><stop offset="1" stop-color="#BDBDD5"/></radialGradient>
  <radialGradient id="cyto_react" cx="45%" cy="45%" r="58%"><stop offset="0" stop-color="#D3E1F4"/><stop offset="0.6" stop-color="#A9C2E7"/><stop offset="1" stop-color="#3F64B0"/></radialGradient>
  <radialGradient id="cyto_blast" cx="50%" cy="50%" r="55%"><stop offset="0" stop-color="#8FA9D9"/><stop offset="1" stop-color="#4E70B8"/></radialGradient>
  <radialGradient id="nuc" cx="40%" cy="35%" r="70%"><stop offset="0" stop-color="#6B3F95"/><stop offset="1" stop-color="#4A2272"/></radialGradient>
  <radialGradient id="nuc_light" cx="40%" cy="35%" r="70%"><stop offset="0" stop-color="#9B7BBC"/><stop offset="1" stop-color="#7556A0"/></radialGradient>
  <radialGradient id="nuc_blast" cx="40%" cy="35%" r="70%"><stop offset="0" stop-color="#A487C4"/><stop offset="1" stop-color="#7A5AA8"/></radialGradient>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur in="SourceAlpha" stdDeviation="6"/><feOffset dy="3"/><feComponentTransfer><feFuncA type="linear" slope="0.18"/></feComponentTransfer><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>
  <filter id="soft"><feGaussianBlur stdDeviation="0.6"/></filter>
</defs>'''


LAST = {}


def svg(body, rnd, cell_r):
    LAST['body'], LAST['r'] = body, cell_r
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            f'{DEFS}\n<rect width="{W}" height="{H}" fill="url(#bg)"/>\n'
            f'{rbc_layer(rnd, cell_r)}\n{body}\n</svg>\n')


def nucleus_group(cid, shapes_svg, fill='url(#nuc)', edge='#3B1A5E'):
    """Yadro: maska (xromatin uchun) + to'ldirilgan shakl."""
    return (f'<mask id="{cid}"><g fill="white" stroke="white">{shapes_svg}</g></mask>\n'
            f'<g fill="{fill}" stroke="{fill}" filter="url(#soft)">{shapes_svg}</g>\n'
            f'<g fill="none" stroke="{edge}" stroke-width="1.4" opacity="0.5">{shapes_svg}</g>')


def lobes_shapes(rnd, centers, r, link_w=4.5):
    s = []
    for (x, y), rr in centers:
        s.append(f'<path d="{blob(x, y, rr, rnd, 0.08, squash=rnd.uniform(0.75, 0.95), rot=rnd.uniform(0, 3.14))}" stroke-width="0"/>')
    for i in range(len(centers) - 1):
        (x1, y1), _ = centers[i]
        (x2, y2), _ = centers[i + 1]
        mx, my = (x1 + x2) / 2 + rnd.uniform(-6, 6), (y1 + y2) / 2 + rnd.uniform(-6, 6)
        s.append(f'<path d="M{x1:.1f} {y1:.1f} Q{mx:.1f} {my:.1f} {x2:.1f} {y2:.1f}" fill="none" stroke-width="{link_w}" stroke-linecap="round"/>')
    return '\n'.join(s)


def arc_centers(n, radius, start, span, lobe_r, jitter, rnd):
    out = []
    for i in range(n):
        a = start + span * i / max(1, n - 1)
        out.append(((CX + radius * math.cos(a) + rnd.uniform(-jitter, jitter),
                     CY + radius * math.sin(a) + rnd.uniform(-jitter, jitter)),
                    lobe_r * rnd.uniform(0.9, 1.1)))
    return out


def granulocyte(name, seed, diam_um, cyto, lobes, lobe_r, arc_r, span, gran, extra=''):
    rnd = random.Random(seed)
    R = diam_um * UM / 2
    centers = arc_centers(lobes, arc_r, -math.pi / 2 - span / 2 + rnd.uniform(-0.3, 0.3), span, lobe_r, 4, rnd)
    shapes = lobes_shapes(rnd, centers, lobe_r)
    avoid = [(x, y, r * 0.95) for (x, y), r in centers]
    body = [f'<g filter="url(#shadow)"><path d="{blob(CX, CY, R, rnd, 0.03)}" fill="{cyto}" stroke="#C9A6BC" stroke-width="1.5"/></g>']
    g_under = gran(rnd, R, avoid, under=True)
    if g_under:
        body.append(g_under)
    body.append(nucleus_group(f'm_{name}', shapes))
    body.append(chromatin(rnd, f'm_{name}', (CX, CY, R), 260, '#8D6AB4', '#2E1050'))
    body.append(gran(rnd, R, avoid, under=False))
    body.append(extra)
    return svg('\n'.join(body), rnd, R)


def neut_gran(rnd, R, avoid, under):
    if under:
        return ''
    return dots(rnd, (CX, CY, R - 6), 420, 1.0, 1.9, ['#B07AA6', '#9C6A9A', '#C38DB4'], (0.45, 0.85), avoid)


def toxic_gran(rnd, R, avoid, under):
    if under:
        return ''
    return dots(rnd, (CX, CY, R - 7), 260, 2.2, 3.6, ['#3A1458', '#4B1F6B', '#2C0E45'], (0.75, 0.95), avoid)


def eos_gran(rnd, R, avoid, under):
    if under:
        return ''
    return dots(rnd, (CX, CY, R - 7), 330, 4.0, 5.4, ['#E8603E', '#F07A4E', '#D9502F', '#F28A5C'], (0.85, 1.0), avoid)


def baso_gran(rnd, R, avoid, under):
    # Bazofil donachalari yadro ustini ham qoplaydi — yadro chizilgandan keyin.
    if under:
        return ''
    return dots(rnd, (CX, CY, R - 6), 120, 4.5, 7.5, ['#2A0F45', '#3B1660', '#1E0A33', '#4A2276'], (0.85, 1.0))


def lymphocyte(name, seed, diam_um, nuc_frac, cyto='url(#cyto_lymph)', offset=(0, 0)):
    rnd = random.Random(seed)
    R = diam_um * UM / 2
    nr = R * nuc_frac
    nx, ny = CX + offset[0], CY + offset[1]
    shapes = f'<path d="{blob(nx, ny, nr, rnd, 0.05, squash=0.94, rot=0.5, dent=(rnd.uniform(0, 6.28), 0.08, 0.5))}" stroke-width="0"/>'
    body = [f'<g filter="url(#shadow)"><path d="{blob(CX, CY, R, rnd, 0.03)}" fill="{cyto}" stroke="#5E80BF" stroke-width="1.5"/></g>',
            nucleus_group(f'm_{name}', shapes),
            chromatin(rnd, f'm_{name}', (nx, ny, nr), 340, '#7F5CA8', '#250B42')]
    return svg('\n'.join(body), rnd, R)


def neutrophil_seg():
    return granulocyte('seg', 11, 13.5, 'url(#cyto_neut)', 3, 29, 50, 2.3, neut_gran)


def neutrophil_hyper():
    return granulocyte('hyper', 23, 15, 'url(#cyto_neut)', 6, 23, 66, 4.2, neut_gran)


def neutrophil_toxic():
    return granulocyte('toxic', 12, 13.5, 'url(#cyto_neut)', 3, 29, 50, 2.4, toxic_gran)


def eosinophil():
    return granulocyte('eos', 31, 13.5, 'url(#cyto_eos)', 2, 32, 36, 2.1, eos_gran)


def basophil():
    rnd = random.Random(41)
    R = 12 * UM / 2
    centers = arc_centers(2, 22, -1.2, 2.4, 26, 3, rnd)
    shapes = lobes_shapes(rnd, centers, 26, 9)
    body = [f'<g filter="url(#shadow)"><path d="{blob(CX, CY, R, rnd, 0.035)}" fill="url(#cyto_baso)" stroke="#A88DBA" stroke-width="1.5"/></g>',
            nucleus_group('m_baso', shapes, fill='url(#nuc_light)', edge='#4A2A70'),
            baso_gran(rnd, R, None, under=False)]
    return svg('\n'.join(body), rnd, R)


def neutrophil_band():
    rnd = random.Random(17)
    R = 13.5 * UM / 2
    # Bo'laklarga ajralmagan, kengligi deyarli bir xil egilgan (C) yadro.
    pts = []
    for i in range(9):
        a = math.radians(200 + 160 * i / 8)
        rr = 54 + rnd.uniform(-2, 2)
        pts.append((CX + rr * math.cos(a), CY + 8 + rr * math.sin(a) * 1.05))
    shapes = f'<path d="{smooth_path(pts, closed=False)}" fill="none" stroke-width="34" stroke-linecap="round"/>'
    avoid = [(x, y, 20) for x, y in pts]
    body = [f'<g filter="url(#shadow)"><path d="{blob(CX, CY, R, rnd, 0.03)}" fill="url(#cyto_neut)" stroke="#C9A6BC" stroke-width="1.5"/></g>',
            nucleus_group('m_band', shapes),
            chromatin(rnd, 'm_band', (CX, CY, R), 260, '#8D6AB4', '#2E1050'),
            neut_gran(rnd, R, avoid, under=False)]
    return svg('\n'.join(body), rnd, R)


def lymphocyte_small():
    return lymphocyte('lsmall', 51, 8.5, 0.86)


def lymphocyte_large():
    return lymphocyte('llarge', 52, 12.5, 0.62, offset=(-12, 6))


def monocyte():
    rnd = random.Random(61)
    R = 18 * UM / 2
    nr = R * 0.58
    nx, ny = CX + 10, CY - 6
    shapes = f'<path d="{blob(nx, ny, nr, rnd, 0.07, squash=0.82, rot=0.3, dent=(1.9, 0.45, 0.55))}" stroke-width="0"/>'
    vac = []
    for _ in range(9):
        a = rnd.uniform(0, 2 * math.pi)
        rr = rnd.uniform(nr + 8, R - 14)
        x, y = CX + rr * math.cos(a), CY + rr * math.sin(a)
        if math.hypot(x - nx, y - ny) < nr + 6:
            continue
        vac.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{rnd.uniform(4, 8):.1f}" fill="#EEF0F8" stroke="#AEB2CF" stroke-width="1" opacity="0.9"/>')
    body = [f'<g filter="url(#shadow)"><path d="{blob(CX, CY, R, rnd, 0.06)}" fill="url(#cyto_mono)" stroke="#9EA0C4" stroke-width="1.5"/></g>',
            dots(rnd, (CX, CY, R - 6), 380, 0.8, 1.4, ['#B48AB0', '#C79BBF'], (0.35, 0.65), [(nx, ny, nr)]),
            '\n'.join(vac),
            nucleus_group('m_mono', shapes, fill='url(#nuc_light)', edge='#4F2F7A'),
            strands(rnd, 'm_mono', (nx, ny, nr), 120, '#4B2A73', 2.4, 0.5)]
    return svg('\n'.join(body), rnd, R)


def reactive_lymphocyte():
    rnd = random.Random(71)
    R = 16 * UM / 2
    # Atrofdagi eritrotsitlarga "yopishgan" to'lqinsimon chet.
    cell = blob(CX, CY, R, rnd, 0.05, n=36, dent=(0.6, 0.12, 0.35))
    nr = R * 0.42
    nx, ny = CX - 30, CY - 14
    shapes = f'<path d="{blob(nx, ny, nr, rnd, 0.06, squash=0.9, rot=0.8)}" stroke-width="0"/>'
    body = [f'<g filter="url(#shadow)"><path d="{cell}" fill="url(#cyto_react)" stroke="#2F4F98" stroke-width="2.5"/></g>',
            nucleus_group('m_react', shapes),
            chromatin(rnd, 'm_react', (nx, ny, nr), 260, '#8E6CB6', '#2B0D49')]
    return svg('\n'.join(body), rnd, R)


def blast():
    rnd = random.Random(81)
    R = 17 * UM / 2
    nr = R * 0.8
    nx, ny = CX + 4, CY
    shapes = f'<path d="{blob(nx, ny, nr, rnd, 0.04, squash=0.95)}" stroke-width="0"/>'
    nucleoli = []
    for (dx, dy, r) in [(-22, -18, 11), (24, 10, 9), (-4, 30, 7)]:
        nucleoli.append(f'<circle cx="{nx + dx}" cy="{ny + dy}" r="{r}" fill="#B9C3E6" stroke="#6E7FBE" stroke-width="2" opacity="0.9"/>')
    body = [f'<g filter="url(#shadow)"><path d="{blob(CX, CY, R, rnd, 0.03)}" fill="url(#cyto_blast)" stroke="#3E5EA8" stroke-width="1.5"/></g>',
            # Yadro atrofidagi och zona.
            f'<path d="{blob(nx, ny, nr + 6, rnd, 0.03)}" fill="#C7D3EE" opacity="0.6"/>',
            nucleus_group('m_blast', shapes, fill='url(#nuc_blast)', edge='#5A3E8C'),
            chromatin(rnd, 'm_blast', (nx, ny, nr), 900, '#B9A2D4', '#5B3B88'),
            '\n'.join(nucleoli)]
    return svg('\n'.join(body), rnd, R)


def smudge():
    rnd = random.Random(91)
    R = 14 * UM / 2
    # Sitoplazmasiz, ezilgan, chegarasi noaniq yadro qoldig'i.
    shape = blob(CX, CY, R, rnd, 0.1, n=30, squash=0.72, rot=0.4)
    streaks = []
    for _ in range(26):
        a = rnd.uniform(-0.5, 0.5) + 0.4
        x, y = CX + rnd.uniform(-R * 0.7, R * 0.7), CY + rnd.uniform(-R * 0.45, R * 0.45)
        L = rnd.uniform(20, 60)
        streaks.append(f'<path d="M{x:.1f} {y:.1f} l{L * math.cos(a):.1f} {L * math.sin(a):.1f}" stroke="#5E3C88" stroke-width="{rnd.uniform(1.5, 4):.1f}" opacity="{rnd.uniform(0.2, 0.45):.2f}" stroke-linecap="round"/>')
    body = [f'<mask id="m_smudge"><path d="{shape}" fill="white"/></mask>',
            f'<path d="{shape}" fill="#9A7DBE" opacity="0.75" filter="url(#soft)"/>',
            f'<path d="{blob(CX - 6, CY + 2, R * 0.55, rnd, 0.2, squash=0.7)}" fill="#7A58A6" opacity="0.55"/>',
            f'<g mask="url(#m_smudge)">{"".join(streaks)}</g>',
            strands(rnd, 'm_smudge', (CX, CY, R), 90, '#4E2C78', 1.8, 0.4)]
    return svg('\n'.join(body), rnd, R)


CELLS = {
    'neutrophil_segmented': neutrophil_seg,
    'neutrophil_band': neutrophil_band,
    'neutrophil_hypersegmented': neutrophil_hyper,
    'neutrophil_toxic': neutrophil_toxic,
    'lymphocyte_small': lymphocyte_small,
    'lymphocyte_large': lymphocyte_large,
    'lymphocyte_reactive': reactive_lymphocyte,
    'monocyte': monocyte,
    'eosinophil': eosinophil,
    'basophil': basophil,
    'smudge_cell': smudge,
    'blast': blast,
}

def hero():
    """Sarlavha rasmi: 5 ta asosiy hujayra bir qatorda (1200×520)."""
    rnd = random.Random(7)
    hw, hh = 1200, 520
    parts = []
    # Fon eritrotsitlari — hujayralar orasida.
    for _ in range(60):
        x, y = rnd.uniform(-30, hw + 30), rnd.uniform(-30, hh + 30)
        r = 7.5 * UM / 2 * 0.8
        parts.append((x, y, r))
    cells = [
        ('lymphocyte_small', 150, 300),
        ('neutrophil_segmented', 370, 230),
        ('monocyte', 620, 300),
        ('eosinophil', 860, 220),
        ('basophil', 1060, 320),
    ]
    bodies = []
    keep = []
    for name, x, y in cells:
        CELLS[name]()
        R = LAST['r'] * 0.8
        keep.append((x, y, R))
        bodies.append(f'<g transform="translate({x - CX * 0.8:.1f} {y - CY * 0.8:.1f}) scale(0.8)">{LAST["body"]}</g>')
    rbcs = []
    for x, y, r in parts:
        if any(math.hypot(x - cx, y - cy) < cr + r + 6 for cx, cy, cr in keep):
            continue
        keep.append((x, y, r))
        rbcs.append(f'<path d="{blob(x, y, r, rnd, 0.008)}" fill="url(#rbc)" stroke="#E2A2A8" stroke-width="1"/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {hw} {hh}" width="{hw}" height="{hh}">\n'
            f'{DEFS}\n<rect width="{hw}" height="{hh}" fill="url(#bg)"/>\n'
            + '\n'.join(rbcs) + '\n' + '\n'.join(bodies) + '\n</svg>\n')


if __name__ == '__main__':
    for name, fn in CELLS.items():
        with open(os.path.join(HERE, f'{name}.svg'), 'w') as f:
            f.write(fn())
        print('svg', name)
    with open(os.path.join(HERE, 'hero.svg'), 'w') as f:
        f.write(hero())
    print('svg hero')
