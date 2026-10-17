"""Qon guruhi bo'limi kartasi uchun sxematik rasm (mikrofoto emas).

Ikki tomchi: chapda eritrotsitlar tekis tarqalgan (agglyutinatsiya yo'q),
o'ngda to'dalarga yopishgan (agglyutinatsiya bor). Matnsiz.

  python3 tool/illustrations/bloodgroup/gen_bloodgroup.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --bloodgroup
"""
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
W = H = 600


def cell(x, y, r, rnd):
    """Eritrotsit: ikki tomonlama botiq disk (och markaz)."""
    ang = rnd.uniform(0, 180)
    sq = rnd.uniform(0.82, 1.0)
    return (f'<g transform="rotate({ang:.0f} {x:.1f} {y:.1f})">'
            f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{r:.1f}" ry="{r * sq:.1f}" '
            'fill="#C8423B" stroke="#8E2420" stroke-width="1.4"/>'
            f'<ellipse cx="{x:.1f}" cy="{y:.1f}" rx="{r * 0.45:.1f}" ry="{r * sq * 0.45:.1f}" '
            'fill="#E07A70" opacity="0.85"/></g>')


def drop(cx, cy, rad):
    return (f'<circle cx="{cx}" cy="{cy}" r="{rad}" fill="#FBE9E6" stroke="#E2B7B1" stroke-width="3"/>'
            f'<circle cx="{cx - rad * 0.35:.0f}" cy="{cy - rad * 0.4:.0f}" r="{rad * 0.16:.0f}" '
            'fill="#FFFFFF" opacity="0.7"/>')


def card():
    rnd = random.Random(7)
    body = []
    # Chap tomchi — erkin hujayralar.
    lx, ly, lr = 160, 300, 122
    body.append(drop(lx, ly, lr))
    placed = []
    while len(placed) < 20:
        a = rnd.uniform(0, 2 * math.pi)
        d = math.sqrt(rnd.uniform(0, 1)) * (lr - 26)
        x, y = lx + d * math.cos(a), ly + d * math.sin(a)
        if all(math.hypot(x - px, y - py) > 30 for px, py in placed):
            placed.append((x, y))
            body.append(cell(x, y, 12, rnd))
    # O'ng tomchi — to'dalar (agglyutinatlar).
    rx, ry, rr = 440, 300, 122
    body.append(drop(rx, ry, rr))
    for (gx, gy, n) in [(415, 262, 11), (478, 330, 10), (412, 352, 7)]:
        for i in range(n):
            a = i * 2.4
            d = 9 * math.sqrt(i + 0.5)
            body.append(cell(gx + d * math.cos(a), gy + d * math.sin(a), 11, rnd))
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            '<defs><radialGradient id="bg" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="#FBF5F4"/>'
            '<stop offset="1" stop-color="#F1E3E1"/></radialGradient></defs>\n'
            f'<rect width="{W}" height="{H}" fill="url(#bg)"/>\n' + '\n'.join(body) + '\n</svg>\n')


if __name__ == '__main__':
    with open(os.path.join(HERE, 'card.svg'), 'w') as f:
        f.write(card())
    print('svg card')
