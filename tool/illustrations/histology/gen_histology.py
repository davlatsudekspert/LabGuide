"""Gistologiya bo'limi kartasi uchun sxematik rasm (mikrofoto emas).

Bir qavatli prizmatik epiteliy kesmasi (H&E ranglariga o'xshash): bir qator
baland hujayra, yadrolar asosga yaqin bir qatorda, uchki yuzada mikrovorsinkali
hoshiya, orada bitta qadahsimon hujayra (och shilliq "pufagi"), ostida bazal
membrana va g'ovak biriktiruvchi to'qima. Belgilar manbasi: Michigan
qo'llanmasi, 16–17-betlar (docs/HISTOLOGY_SOURCES.md). Matnsiz.

  python3 tool/illustrations/histology/gen_histology.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --histology
"""
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
W = H = 600


def card():
    rnd = random.Random(11)
    body = []
    top, base = 150, 430          # hujayralar uchki va asos chizig'i
    x0, n = 30, 11
    cw = (W - 2 * x0) / n
    goblet = 5                    # qadahsimon hujayra tartib raqami
    # Biriktiruvchi to'qima (pastda): och pushti fon, to'lqinsimon tolalar,
    # cho'zinchoq fibroblast yadrolari.
    body.append(f'<rect x="0" y="{base}" width="{W}" height="{H - base}" fill="#F6D9E4"/>')
    for i in range(7):
        y = base + 22 + i * 22
        d = f'M0 {y}'
        for k in range(1, 9):
            d += f' Q{k * 75 - 37} {y + rnd.uniform(-9, 9):.0f} {k * 75} {y}'
        body.append(f'<path d="{d}" fill="none" stroke="#E7A9C0" stroke-width="3" opacity="0.8"/>')
    for _ in range(6):
        x, y = rnd.uniform(40, W - 40), rnd.uniform(base + 30, H - 25)
        body.append(f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="16" ry="4.5" fill="#5B3A8C" opacity="0.85" '
                    f'transform="rotate({rnd.uniform(-12, 12):.0f} {x:.0f} {y:.0f})"/>')
    # Bo'shliq (yuqorida).
    body.append(f'<rect x="0" y="0" width="{W}" height="{top - 10}" fill="#FBF7FA"/>')
    # Hujayralar.
    for i in range(n):
        x = x0 + i * cw
        body.append(f'<rect x="{x + 1.5:.1f}" y="{top}" width="{cw - 3:.1f}" height="{base - top}" rx="6" '
                    'fill="#F2B8CF" stroke="#B9638A" stroke-width="2"/>')
        if i == goblet:
            # Qadahsimon hujayra: uchki qismida katta och shilliq "pufagi",
            # yadro asosda siqilgan.
            body.append(f'<ellipse cx="{x + cw / 2:.1f}" cy="{top + 85}" rx="{cw / 2 - 5:.1f}" ry="78" '
                        'fill="#EDE7F3" stroke="#B9638A" stroke-width="1.5"/>')
            body.append(f'<ellipse cx="{x + cw / 2:.1f}" cy="{base - 30}" rx="{cw / 2 - 12:.1f}" ry="12" fill="#4B2A7B"/>')
        else:
            cy = base - 62 + rnd.uniform(-5, 5)
            body.append(f'<ellipse cx="{x + cw / 2:.1f}" cy="{cy:.0f}" rx="{cw / 2 - 11:.1f}" ry="30" '
                        'fill="#5B3A8C" stroke="#3E2266" stroke-width="1.5"/>')
            body.append(f'<circle cx="{x + cw / 2 + 2:.1f}" cy="{cy - 6:.0f}" r="3.5" fill="#2C1450"/>')
            # Mikrovorsinkali hoshiya.
            for k in range(7):
                mx = x + 6 + k * (cw - 12) / 6
                body.append(f'<line x1="{mx:.1f}" y1="{top}" x2="{mx:.1f}" y2="{top - 10}" stroke="#C0577F" stroke-width="2"/>')
    # Bazal membrana.
    body.append(f'<line x1="0" y1="{base + 2}" x2="{W}" y2="{base + 2}" stroke="#C0306A" stroke-width="5"/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            f'<rect width="{W}" height="{H}" fill="#FBF7FA"/>\n' + '\n'.join(body) + '\n</svg>\n')


if __name__ == '__main__':
    with open(os.path.join(HERE, 'card.svg'), 'w') as f:
        f.write(card())
    print('svg card')
