"""Koagulogramma bo'limi kartasi uchun sxematik rasm (foto emas).

Havorang qopqoqli sitrat probirkasi (to'ldirish belgisi, plazma va
eritrotsit qatlami) va sekundomer — ivish vaqti. Matnsiz; ranglar shartli.

  python3 tool/illustrations/coagulogram/gen_coagulogram.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render_card.cjs \
      tool/illustrations/coagulogram/card.svg assets/coagulogram/card.png
"""
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
W = H = 600


def card():
    b = []
    b.append(f'<rect x="0" y="470" width="{W}" height="{H - 470}" fill="#E4ECE6"/>')
    b.append('<ellipse cx="300" cy="482" rx="210" ry="16" fill="#9FB3A7" opacity="0.45"/>')
    # Probirka (tik), ichida eritrotsitlar (pastda) va plazma (tepada).
    b.append('<rect x="150" y="150" width="110" height="320" rx="50" fill="#F4F8F6" '
             'stroke="#9DB0A6" stroke-width="4"/>')
    b.append('<path d="M156 330 L254 330 L254 420 Q254 464 205 464 Q156 464 156 420 Z" '
             'fill="#C0504D"/>')
    b.append('<rect x="156" y="236" width="98" height="94" fill="#F2D675"/>')
    b.append('<line x1="156" y1="236" x2="254" y2="236" stroke="#E2BE4E" stroke-width="4"/>')
    # To'ldirish belgisi (o'q bilan).
    b.append('<line x1="268" y1="236" x2="300" y2="236" stroke="#2F7D62" stroke-width="5" '
             'stroke-linecap="round"/>')
    b.append('<path d="M300 226 L316 236 L300 246 Z" fill="#2F7D62"/>')
    # Yaltiroqlik.
    b.append('<path d="M172 190 L172 430" stroke="#FFFFFF" stroke-width="9" '
             'stroke-linecap="round" opacity="0.7"/>')
    # Havorang qopqoq.
    b.append('<rect x="138" y="112" width="134" height="56" rx="12" fill="#7FB3D5"/>')
    b.append('<rect x="138" y="152" width="134" height="16" fill="#6A9EC2"/>')
    # Sekundomer.
    cx, cy, r = 430, 300, 92
    b.append(f'<rect x="{cx - 14}" y="{cy - r - 34}" width="28" height="26" rx="6" fill="#2F7D62"/>')
    b.append(f'<circle cx="{cx}" cy="{cy}" r="{r + 10}" fill="#2F7D62"/>')
    b.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#FFFFFF"/>')
    for i in range(12):
        a = i / 12 * 2 * math.pi
        x1, y1 = cx + math.cos(a) * (r - 8), cy + math.sin(a) * (r - 8)
        x2, y2 = cx + math.cos(a) * (r - 22), cy + math.sin(a) * (r - 22)
        b.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
                 'stroke="#9DB0A6" stroke-width="4" stroke-linecap="round"/>')
    # Sektor (o'tgan vaqt) va mil.
    b.append(f'<path d="M{cx} {cy} L{cx} {cy - r + 26} A{r - 26} {r - 26} 0 0 1 '
             f'{cx + (r - 26) * math.sin(math.radians(110)):.1f} '
             f'{cy - (r - 26) * math.cos(math.radians(110)):.1f} Z" fill="#7FB3D5" opacity="0.35"/>')
    b.append(f'<line x1="{cx}" y1="{cy}" x2="{cx + 58 * math.sin(math.radians(110)):.1f}" '
             f'y2="{cy - 58 * math.cos(math.radians(110)):.1f}" stroke="#C0504D" '
             'stroke-width="7" stroke-linecap="round"/>')
    b.append(f'<circle cx="{cx}" cy="{cy}" r="9" fill="#2F7D62"/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            f'<rect width="{W}" height="{H}" fill="#F3F7F4"/>\n' + '\n'.join(b) + '\n</svg>\n')


if __name__ == '__main__':
    with open(os.path.join(HERE, 'card.svg'), 'w') as f:
        f.write(card())
    print('svg card')
