"""Koprologiya bo'limi kartasi uchun sxematik rasm (foto emas).

Qopqog'i buraladigan namuna idishi va lupa ostidagi sxematik gijja tuxumi
(qalin, g'adir-budur qobiqli oval — askarida tuxumi sxemasi). Matnsiz;
ranglar shartli.

  python3 tool/illustrations/coprology/gen_coprology.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render_card.cjs \
      tool/illustrations/coprology/card.svg assets/coprology/card.png
"""
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
W = H = 600


def card():
    b = []
    b.append(f'<rect x="0" y="470" width="{W}" height="{H - 470}" fill="#E4ECE6"/>')
    b.append('<ellipse cx="300" cy="482" rx="220" ry="16" fill="#9FB3A7" opacity="0.45"/>')
    # Namuna idishi: shaffof tana, qopqoq, yorliq.
    b.append('<path d="M110 260 L270 260 L262 468 Q260 478 250 478 L130 478 '
             'Q120 478 118 468 Z" fill="#F4F8F6" stroke="#9DB0A6" stroke-width="4"/>')
    b.append('<rect x="132" y="330" width="116" height="80" rx="8" fill="#FFFFFF" '
             'stroke="#B7C6BD" stroke-width="3"/>')
    for i in range(3):
        y = 352 + i * 20
        b.append(f'<line x1="146" y1="{y}" x2="{230 - i * 24}" y2="{y}" stroke="#B7C6BD" '
                 'stroke-width="5" stroke-linecap="round"/>')
    b.append('<rect x="98" y="222" width="184" height="46" rx="10" fill="#2F7D62"/>')
    for i in range(7):
        x = 114 + i * 24
        b.append(f'<line x1="{x}" y1="228" x2="{x}" y2="262" stroke="#26684F" stroke-width="4"/>')
    # Lupa: doira ichida sxematik tuxum.
    cx, cy, r = 420, 250, 110
    b.append(f'<line x1="{cx - 70}" y1="{cy + 80}" x2="{cx - 150}" y2="{cy + 180}" '
             'stroke="#2F7D62" stroke-width="26" stroke-linecap="round"/>')
    b.append(f'<circle cx="{cx}" cy="{cy}" r="{r + 12}" fill="#2F7D62"/>')
    b.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#FBF6E9"/>')
    # Tuxum: mamillyar tashqi qavat (do'mboqchalar), silliq ichki qobiq, massa.
    for i in range(26):
        a = i / 26 * 2 * math.pi
        x, y = cx + math.cos(a) * 62, cy + math.sin(a) * 48
        b.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="9" fill="#B8864B"/>')
    b.append(f'<ellipse cx="{cx}" cy="{cy}" rx="62" ry="48" fill="#C99A5E"/>')
    b.append(f'<ellipse cx="{cx}" cy="{cy}" rx="46" ry="34" fill="#F6EBD2" '
             'stroke="#7A5A33" stroke-width="4"/>')
    b.append(f'<circle cx="{cx}" cy="{cy}" r="20" fill="#D9C39A"/>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            f'<rect width="{W}" height="{H}" fill="#F3F7F4"/>\n' + '\n'.join(b) + '\n</svg>\n')


if __name__ == '__main__':
    with open(os.path.join(HERE, 'card.svg'), 'w') as f:
        f.write(card())
    print('svg card')
