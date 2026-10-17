"""Siydik tahlili bo'limi kartasi uchun sxematik rasm (foto emas).

Shaffof idishda somon-sariq siydik va yonida test-chiziq (10 ta rangli
maydoncha). Maydonchalar ranglari shartli — hech qaysi natijani
ko'rsatmaydi. Matnsiz.

  python3 tool/illustrations/urinalysis/gen_urinalysis.py
  NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --urinalysis
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
W = H = 600

# Shartli maydoncha ranglari (yuqoridan pastga).
PADS = ['#E9C46A', '#8AB17D', '#F4A261', '#C9ADA7', '#A8DADC',
        '#E5989B', '#B5838D', '#90BE6D', '#F6BD60', '#84A59D']


def card():
    body = []
    # Stol yuzasi.
    body.append(f'<rect x="0" y="470" width="{W}" height="{H - 470}" fill="#E4ECE6"/>')
    body.append('<ellipse cx="250" cy="482" rx="150" ry="16" fill="#9FB3A7" opacity="0.45"/>')
    # Idish: shaffof tana, ichida siydik, qopqoq.
    body.append('<path d="M140 210 L360 210 L340 470 Q338 482 326 482 L174 482 '
                'Q162 482 160 470 Z" fill="#F4F8F6" stroke="#9DB0A6" stroke-width="4"/>')
    body.append('<path d="M150 300 L350 300 L340 466 Q338 474 328 474 L172 474 '
                'Q162 474 160 466 Z" fill="#F2D675"/>')
    body.append('<path d="M150 300 L350 300" stroke="#E2BE4E" stroke-width="5"/>')
    # O'lchov chiziqlari.
    for i in range(4):
        y = 250 + i * 50
        body.append(f'<line x1="300" y1="{y}" x2="330" y2="{y}" stroke="#9DB0A6" stroke-width="3"/>')
    # Yaltiroqlik.
    body.append('<path d="M172 230 L160 450" stroke="#FFFFFF" stroke-width="10" '
                'stroke-linecap="round" opacity="0.7"/>')
    body.append('<rect x="128" y="176" width="244" height="40" rx="10" fill="#2F7D62"/>')
    body.append('<rect x="128" y="206" width="244" height="10" fill="#26684F"/>')
    # Test-chiziq: oq plastik tasma va 10 ta maydoncha.
    body.append('<g transform="rotate(8 470 300)">')
    body.append('<rect x="440" y="70" width="60" height="460" rx="10" fill="#FFFFFF" '
                'stroke="#B7C6BD" stroke-width="3"/>')
    for i, c in enumerate(PADS):
        y = 92 + i * 40
        body.append(f'<rect x="452" y="{y}" width="36" height="28" rx="5" fill="{c}"/>')
    body.append('</g>')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">\n'
            f'<rect width="{W}" height="{H}" fill="#F3F7F4"/>\n' + '\n'.join(body) + '\n</svg>\n')


if __name__ == '__main__':
    with open(os.path.join(HERE, 'card.svg'), 'w') as f:
        f.write(card())
    print('svg card')
