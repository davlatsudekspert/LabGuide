"""LabGuide ikonkalari va brend rasmlari — bitta manbadan (egasi bergan logo).

Ishlatish (repo ildizida, Pillow kerak):
    python3 tool/icons/make_icons.py

Manba: tool/icons/logo_source_green.webp — egasi 2026-10-09 da tasdiqlagan yashil
logo (1679×937: yumaloq kvadrat belgi + “LabGuide” yozuvi, sutrang fonda). Asl fayl
o'zgartirilmaydi. Belgi manbada ~611×611 px — 1024 px do'kon ikonkasi shundan
**kattalashtirilgan** (interpolatsiya), haqiqiy yuqori aniqlik yoki vektor emas;
dizayner ≥1024 px yoki SVG manba bersa, shu skript qayta ishga tushiriladi.
Eski ko'k-firuza manba (logo_source.jpg) tarix uchun saqlanadi, ishlatilmaydi. Skript:
- belgini kesib oladi va burchaklarini ichki ranglar bilan to'ldiradi
  (App Store/Google Play ikonkasi kvadrat, shaffofsiz; niqobni platforma
  o'zi qo'yadi);
- iOS AppIcon (barcha o'lchamlar), Android legacy + adaptive ikonkalar,
  ishga tushish ekrani belgisi, ilova ichidagi brend belgisi;
- do'kon fayllari: docs/store/app_store_icon_1024.png,
  google_play_icon_512.png, google_play_feature_graphic.png (1024×500).
"""
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'tool/icons/logo_source_green.webp'

# Belgi joylashuvi manbada (o'lchab topilgan): kvadrat va burchak radiusi.
# Yashil manbada: kvadrat x 532–1144, y 83–692; burchak radiusi ~125 px.
ICON_BOX = (533, 83, 1144, 694)
CORNER_RADIUS = 125
INSET = 22  # plitkaning 3D qirrasi (yorug' hoshiya ~20 px) va sutrang fon bilan aralashgan chet


def full_bleed() -> Image.Image:
    """Kvadrat, burchaklari to'ldirilgan belgi (1024 px, RGB).

    Plitkaning 3D qirrasi (yorug' hoshiya) ichidan kesiladi; burchakdagi
    plitkadan tashqari joy yoy ichidagi ranglar bilan to'ldirilib, yumshatiladi
    — platforma niqobi (iOS ~22 %, Google Play ~20 %) faqat toza qismni ko'rsatadi.
    """
    x0, y0, x1, y1 = ICON_BOX
    inset = INSET
    src = Image.open(SOURCE).convert('RGB').crop(
        (x0 + inset, y0 + inset, x1 - inset, y1 - inset))
    n = src.width
    # Plitka burchak markazi yangi koordinatalarda va qirradan ichkari radius.
    c = CORNER_RADIUS - inset
    inner = CORNER_RADIUS - inset - 8
    px = src.load()
    out = src.copy()
    opx = out.load()
    filled = Image.new('L', src.size, 0)
    fpx = filled.load()
    for cx, cy in ((c, c), (n - 1 - c, c), (c, n - 1 - c), (n - 1 - c, n - 1 - c)):
        for y in range(max(0, cy - CORNER_RADIUS), min(n, cy + CORNER_RADIUS)):
            for x in range(max(0, cx - CORNER_RADIUS), min(n, cx + CORNER_RADIUS)):
                # Faqat burchak kvadranti (markazdan tashqariga qaragan tomon).
                if (x - cx) * (cx - n / 2) < 0 or (y - cy) * (cy - n / 2) < 0:
                    continue
                dx, dy = x - cx, y - cy
                d = math.hypot(dx, dy)
                if d <= inner:
                    continue
                opx[x, y] = px[round(cx + dx / d * inner), round(cy + dy / d * inner)]
                fpx[x, y] = 255
    soft = out.filter(ImageFilter.GaussianBlur(8))
    out.paste(soft, mask=filled.filter(ImageFilter.GaussianBlur(3)))
    big = out.resize((1024, 1024), Image.LANCZOS)
    return big.filter(ImageFilter.UnsharpMask(radius=1.2, percent=60, threshold=2))


def rounded(img: Image.Image, radius_ratio: float = 0.22) -> Image.Image:
    """Shaffof burchakli yumaloq kvadrat (ilova ichi, splash, legacy)."""
    size = img.width
    scale = 4  # silliq chet uchun katta niqob
    mask = Image.new('L', (size * scale, size * scale), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size * scale - 1, size * scale - 1),
        radius=size * scale * radius_ratio,
        fill=255,
    )
    out = img.convert('RGBA')
    out.putalpha(mask.resize((size, size), Image.LANCZOS))
    return out


def edge_color(img: Image.Image) -> tuple[int, int, int]:
    """Adaptive ikonka foni: chap va pastki chetning o'rtacha rangi."""
    small = img.resize((64, 64), Image.LANCZOS)
    px = small.load()
    pts = [px[2, y] for y in range(8, 56)] + [px[x, 61] for x in range(8, 56)]
    return tuple(round(sum(c[i] for c in pts) / len(pts)) for i in range(3))


def main() -> None:
    big = full_bleed()
    bg = edge_color(big)

    # iOS — barcha o'lchamlar, shaffofsiz.
    ios = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for item in json.loads((ios / 'Contents.json').read_text())['images']:
        pts = float(item['size'].split('x')[0])
        px = round(pts * int(item['scale'].rstrip('x')))
        big.resize((px, px), Image.LANCZOS).save(ios / item['filename'], optimize=True)

    res = ROOT / 'android/app/src/main/res'
    # Android legacy (48 dp) — yumaloq kvadrat.
    for density, px in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        rounded(big.resize((px, px), Image.LANCZOS)).save(
            res / f'mipmap-{density}/ic_launcher.png', optimize=True)

    # Android adaptive: 108 dp tuval, rasm ko'rinadigan 72 dp maydonni to'liq
    # qoplaydi (doira/squircle niqob belgi markazini kesmaydi), fon — chet rangi.
    for density, px in {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432}.items():
        layer = Image.new('RGBA', (px, px), (0, 0, 0, 0))
        inner = round(px * 72 / 108)
        off = (px - inner) // 2
        layer.paste(big.resize((inner, inner), Image.LANCZOS), (off, off))
        layer.save(res / f'mipmap-{density}/ic_launcher_foreground.png', optimize=True)
    (res / 'mipmap-anydpi-v26/ic_launcher.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '</adaptive-icon>\n')
    (res / 'values/ic_launcher_background.xml').write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        f'    <color name="ic_launcher_background">#{bg[0]:02X}{bg[1]:02X}{bg[2]:02X}</color>\n'
        '</resources>\n')

    # Ishga tushish ekrani belgisi (Android < 12 va iOS).
    for density, px in {'mdpi': 96, 'hdpi': 144, 'xhdpi': 192, 'xxhdpi': 288, 'xxxhdpi': 384}.items():
        rounded(big.resize((px, px), Image.LANCZOS)).save(
            res / f'drawable-{density}/launch_icon.png', optimize=True)
    launch = ROOT / 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
    for name, px in {'LaunchImage.png': 96, 'LaunchImage@2x.png': 192, 'LaunchImage@3x.png': 288}.items():
        rounded(big.resize((px, px), Image.LANCZOS)).save(launch / name, optimize=True)

    # Ilova ichidagi brend belgisi.
    rounded(big.resize((256, 256), Image.LANCZOS)).save(
        ROOT / 'assets/images/logo_mark.png', optimize=True)
    # Kirish/welcome ekranlaridagi katta belgi (yozuvsiz; yozuv ilovada matn).
    rounded(big.resize((512, 512), Image.LANCZOS)).save(
        ROOT / 'assets/images/logo_mark_large.png', optimize=True)

    # Do'kon fayllari.
    store = ROOT / 'docs/store'
    store.mkdir(parents=True, exist_ok=True)
    big.save(store / 'app_store_icon_1024.png', optimize=True)
    big.resize((512, 512), Image.LANCZOS).save(store / 'google_play_icon_512.png', optimize=True)
    # Feature graphic 1024×500: belgi va yozuv (manba nisbati 2.048 ga kesiladi).
    src = Image.open(SOURCE).convert('RGB')
    h = round(src.width / 2.048)
    top = 50
    src.crop((0, top, src.width, top + h)).resize((1024, 500), Image.LANCZOS).save(
        store / 'google_play_feature_graphic.png', optimize=True)
    big.save(ROOT / 'tool/icons/icon_1024.png', optimize=True)
    print('ok, adaptive background', '#%02X%02X%02X' % bg)


if __name__ == '__main__':
    main()
