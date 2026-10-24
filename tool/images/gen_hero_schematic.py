#!/usr/bin/env python3
"""Original abstract hero schematic (double helix + nodes) in the app palette.

Drawn procedurally; no third-party material. Output: assets/images/hero_schematic.webp
Run: python3 tool/images/gen_hero_schematic.py
"""
import math
from PIL import Image, ImageDraw, ImageFilter

W, H, S = 1600, 900, 2  # supersample x2
BRAND, DEEP, SOFT, AMBER = (25, 76, 64), (13, 40, 34), (233, 239, 225), (200, 150, 70)

img = Image.new("RGB", (W * S, H * S))
px = img.load()
for y in range(H * S):
    for x in range(W * S):
        t = (x / (W * S) * 0.6 + y / (H * S) * 0.4)
        px[x, y] = tuple(int(DEEP[i] + (BRAND[i] - DEEP[i]) * (1 - t)) for i in range(3))
lay = Image.new("RGBA", img.size, (0, 0, 0, 0))
d = ImageDraw.Draw(lay)

def helix(cx_off, amp, phase, alpha, scale, ang):
    pts1, pts2, rungs = [], [], []
    n = 140
    for i in range(n + 1):
        u = i / n
        x = (-0.1 + 1.2 * u) * W * S
        a = u * 6.5 * math.pi + phase
        y0 = H * S * 0.5 + cx_off * S
        y1 = y0 + math.sin(a) * amp * S
        y2 = y0 - math.sin(a) * amp * S
        pts1.append((x, y1)); pts2.append((x, y2))
        if i % 4 == 0:
            rungs.append(((x, y1), (x, y2), math.cos(a)))
    for (p, q, c) in rungs:
        d.line([p, q], fill=SOFT + (int(alpha * 0.35),), width=int(3 * scale * S))
    for pts, col in ((pts1, SOFT), (pts2, AMBER)):
        d.line(pts, fill=col + (alpha,), width=int(8 * scale * S), joint="curve")
    for (p, q, c) in rungs:
        for pt, col in ((p, SOFT), (q, AMBER)):
            r = (9 + 4 * c) * scale * S
            d.ellipse([pt[0] - r, pt[1] - r, pt[0] + r, pt[1] + r], fill=col + (alpha,))

helix(40, 190, 0.0, 200, 1.0, 0)
helix(-190, 90, 2.0, 70, 0.7, 0)
helix(260, 70, 4.0, 55, 0.6, 0)
# soft floating nodes
import random
random.seed(7)
for _ in range(34):
    x, y = random.randint(0, W * S), random.randint(0, H * S)
    r = random.randint(5, 16) * S
    d.ellipse([x - r, y - r, x + r, y + r], outline=SOFT + (60,), width=2 * S)
lay = lay.filter(ImageFilter.GaussianBlur(0.6 * S))
img = Image.alpha_composite(img.convert("RGBA"), lay).convert("RGB").resize((W, H), Image.LANCZOS)
img.save("assets/images/hero_schematic.webp", quality=80, method=6)
