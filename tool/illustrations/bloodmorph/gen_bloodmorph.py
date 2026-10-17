"""Qon morfologiyasi bo'limi uchun sxematik rasmlar (mikrofoto emas).

- card.svg — bo'lim kartasi: surtmadagi eritrotsitlar (markazida och joy),
  bitta kichik limfotsit va bir nechta trombotsit. Matnsiz.
- scheme.svg — "Nimaga qarash kerak" raqamli sxemasi (1 µm = 14 px):
  1 — normal eritrotsit (7,5 µm, markaziy och joy ≈ 1/3 diametr),
  2 — mikrotsit (≈ 5 µm), 3 — makrotsit (≈ 9,5 µm), 4 — gipoxrom eritrotsit
  (keng och markaz), 5 — sferotsit (≈ 6 µm, och joysiz, to'qroq),
  6 — kichik limfotsit (yadrosi ≈ normal eritrotsit kattaligida).
  O'lchamlar manbasi: JSST qo'llanmasi 9.10.4 (306–308-betlar), Adewoyin
  2014 (Red cell morphology) — docs/BLOODMORPH_SOURCES.md. Izoh matni
  ilovada (3 tilda), rasmda faqat raqamlar.

  python3 tool/illustrations/bloodmorph/gen_bloodmorph.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --bloodmorph
"""
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
UM = 14  # 1 µm = 14 px (sxema)

RBC = "#E7959F"
RBC_EDGE = "#C9707C"
PALE = "#F8DADD"
BG = "#FBF7F7"


def rbc(cx, cy, d, pallor, fill=RBC, edge=RBC_EDGE):
    """Eritrotsit: gardishi to'q, markazi och (pallor — diametrga nisbat)."""
    r = d / 2
    out = [f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" fill="{fill}" '
           f'stroke="{edge}" stroke-width="2"/>']
    if pallor > 0:
        out.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r * pallor:.1f}" '
                   f'fill="{PALE}"/>')
    return out


def lymphocyte(cx, cy, d, nucleus):
    return [
        f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{d / 2:.1f}" fill="#9EB9E3" '
        'stroke="#6F8FC4" stroke-width="2"/>',
        f'<circle cx="{cx - 3:.1f}" cy="{cy + 2:.1f}" r="{nucleus / 2:.1f}" '
        'fill="#4B2F7E"/>',
    ]


def platelet(cx, cy, rnd):
    rx, ry = rnd.uniform(5, 8), rnd.uniform(4, 6)
    return [f'<ellipse cx="{cx:.0f}" cy="{cy:.0f}" rx="{rx:.1f}" ry="{ry:.1f}" '
            f'fill="#9C6BB8" transform="rotate({rnd.uniform(0, 180):.0f} '
            f'{cx:.0f} {cy:.0f})"/>']


def card():
    w = h = 600
    rnd = random.Random(7)
    body = []
    cells = []
    # Tasodifiy, ustma-ust tushmaydigan eritrotsitlar.
    tries = 0
    while len(cells) < 26 and tries < 5000:
        tries += 1
        d = rnd.uniform(92, 112)
        x, y = rnd.uniform(40, w - 40), rnd.uniform(40, h - 40)
        if any((x - a) ** 2 + (y - b) ** 2 < ((d + e) / 2 + 6) ** 2
               for a, b, e in cells):
            continue
        if (x - 330) ** 2 + (y - 300) ** 2 < (75 + d / 2 + 6) ** 2:
            continue  # limfotsit joyi
        cells.append((x, y, d))
    for x, y, d in cells:
        body += rbc(x, y, d, 0.36)
    body += lymphocyte(330, 300, 150, 118)
    for _ in range(9):
        for _ in range(200):
            x, y = rnd.uniform(20, w - 20), rnd.uniform(20, h - 20)
            if all((x - a) ** 2 + (y - b) ** 2 > (e / 2 + 10) ** 2
                   for a, b, e in cells) and (x - 330) ** 2 + (y - 300) ** 2 > 90 ** 2:
                body += platelet(x, y, rnd)
                break
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" '
            f'width="{w}" height="{h}">\n<rect width="{w}" height="{h}" '
            f'fill="{BG}"/>\n' + '\n'.join(body) + '\n</svg>\n')


def scheme():
    w, h = 900, 600
    body = []
    cy1, cy2 = 190, 440
    items = [
        # (raqam, x, y, chizish)
        (1, 150, cy1, rbc(150, cy1, 7.5 * UM, 0.34)),
        (2, 450, cy1, rbc(450, cy1, 5 * UM, 0.30)),
        (3, 750, cy1, rbc(750, cy1, 9.5 * UM, 0.34)),
        (4, 150, cy2, rbc(150, cy2, 7.5 * UM, 0.66, fill="#F0B9C0",
                          edge="#D38B95")),
        (5, 450, cy2, rbc(450, cy2, 6 * UM, 0, fill="#D86F7E", edge="#B4505F")),
        (6, 750, cy2, lymphocyte(750, cy2, 9 * UM, 7.5 * UM)),
    ]
    for n, x, y, shape in items:
        body += shape
        body.append(f'<circle cx="{x - 95}" cy="{y - 95}" r="22" fill="#1F4E79"/>')
        body.append(f'<text x="{x - 95}" y="{y - 87}" text-anchor="middle" '
                    'font-family="Inter" font-weight="700" font-size="24" '
                    f'fill="#FFFFFF">{n}</text>')
    # Masshtab chizig'i: 5 µm.
    body.append(f'<line x1="40" y1="{h - 30}" x2="{40 + 5 * UM}" y2="{h - 30}" '
                'stroke="#333" stroke-width="4"/>')
    body.append(f'<text x="{40 + 5 * UM + 12}" y="{h - 22}" font-family="Inter" '
                'font-weight="600" font-size="22" fill="#333">5 µm</text>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" '
            f'width="{w}" height="{h}">\n<rect width="{w}" height="{h}" '
            f'fill="{BG}"/>\n' + '\n'.join(body) + '\n</svg>\n')


if __name__ == '__main__':
    with open(os.path.join(HERE, 'card.svg'), 'w') as f:
        f.write(card())
    with open(os.path.join(HERE, 'scheme.svg'), 'w') as f:
        f.write(scheme())
    print('svg card, scheme')
