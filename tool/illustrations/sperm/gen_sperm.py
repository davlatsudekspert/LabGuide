"""Spermogramma bo'limi kartasi uchun sxematik rasm (mikrofoto emas).

  python3 tool/illustrations/sperm/gen_sperm.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --sperm
"""
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
W = H = 600


def sperm(x, y, ang, s, rnd):
    """Bosh (oval, akrosoma qopqog'i), bo'yin/o'rta qism, uzun to'lqinsimon dum."""
    ca, sa = math.cos(ang), math.sin(ang)

    def p(u, v):
        return x + u * ca - v * sa, y + u * sa + v * ca

    hx, hy = p(0, 0)
    out = [f'<g transform="rotate({math.degrees(ang):.1f} {hx:.1f} {hy:.1f})">',
           f'<ellipse cx="{hx:.1f}" cy="{hy:.1f}" rx="{14 * s:.1f}" ry="{9.5 * s:.1f}" fill="#7C6BB0" stroke="#4E3F86" stroke-width="1.6"/>',
           f'<path d="M{hx - 3 * s:.1f} {hy - 9 * s:.1f} A{14 * s:.1f} {9.5 * s:.1f} 0 0 1 {hx - 3 * s:.1f} {hy + 9 * s:.1f}" fill="none" stroke="#C9C2E6" stroke-width="{4 * s:.1f}" opacity="0.8"/>',
           '</g>']
    pts = []
    ph = rnd.uniform(0, 6.28)
    for i in range(60):
        u = -14 * s - i * 4.2 * s
        amp = (2 + i * 0.35) * s
        pts.append(p(u, amp * math.sin(i * 0.33 + ph)))
    mid = ' '.join(f'{a:.1f},{b:.1f}' for a, b in pts[:6])
    tail = ' '.join(f'{a:.1f},{b:.1f}' for a, b in pts[5:])
    out.append(f'<polyline points="{mid}" fill="none" stroke="#5A4B95" stroke-width="{4.5 * s:.1f}" stroke-linecap="round"/>')
    out.append(f'<polyline points="{tail}" fill="none" stroke="#6E62A6" stroke-width="{1.8 * s:.1f}" stroke-linecap="round" stroke-linejoin="round"/>')
    return '\n'.join(out)


def card():
    rnd = random.Random(5)
    body = []
    for (x, y, a, s) in [(330, 250, -0.5, 2.2), (190, 380, 0.35, 1.7), (450, 430, -1.2, 1.5), (150, 170, 0.9, 1.3)]:
        body.append(sperm(x, y, a, s, rnd))
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            '<defs><radialGradient id="bg" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="#F6F4FA"/>'
            '<stop offset="1" stop-color="#E7E3F1"/></radialGradient></defs>\n'
            f'<rect width="{W}" height="{H}" fill="url(#bg)"/>\n' + '\n'.join(body) + '\n</svg>\n')


if __name__ == '__main__':
    with open(os.path.join(HERE, 'card.svg'), 'w') as f:
        f.write(card())
    print('svg card')
