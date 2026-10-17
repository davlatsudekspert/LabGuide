"""Qon morfologiyasi bo'limi rasmlarini yuklash va ilova uchun tayyorlash.

    python3 tool/bloodmorph_images.py [--cache DIR]

- Faqat Wikimedia Commons'dagi erkin litsenziyali fayllar (CC0 / CC BY /
  CC BY-SA). Har faylning litsenziyasi, muallifi va asl izohi fayl
  sahifasidan (API: extmetadata + wikitext litsenziya shabloni) tekshirilgan
  (2026-10-17); natija lib/features/bloodmorph/bloodmorph_content.dart dagi
  ``BmImage`` larda va docs/BLOODMORPH_SOURCES.md jadvalida.
- Yuklash: upload.wikimedia.org dagi standart thumbnail (odatda 960 px;
  asli kichik fayl uchun 330 px). Asl fayllarni yuklash bu muhitdan
  cheklangan (HTTP 429), shuning uchun faqat thumbnail. Fayl yo'li Commons
  qoidasi bo'yicha nomning MD5 xeshidan olinadi.
- Ishlov: EXIF yo'nalishi qo'llanadi, rang sRGB, eni 900 px gacha (tik rasm —
  bo'yi 1200 px gacha) **faqat kichraytiriladi**; kesish, yozuv qo'shish,
  rang tuzatish yo'q; JPEG sifat 80, EXIF/ICC yozilmaydi.
- Natija: assets/bloodmorph/img/<id>.jpg

Talab: Pillow (pip install pillow).
"""
import argparse
import hashlib
import io
import pathlib
import time
import urllib.error
import urllib.parse
import urllib.request

from PIL import Image, ImageCms, ImageOps

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/bloodmorph/img"
UA = "LabGuideBot/0.1 (+https://github.com/davlatsudekspert/labguide)"
MAX_W = 900
MAX_H = 1200
QUALITY = 80
# id (ilovadagi rasm nomi) → (Commons fayl nomi, thumbnail eni px). Rasm va nom
# mosligi ko'z bilan tekshirilgan; tanlash sabablari docs/BLOODMORPH_SOURCES.md.
IMAGES = {
    "polychromasia": ("Polychromasia.jpg", 960),
    "spherocytes": ("Hereditary Spherocytosis smear 2010-03-17.JPG", 960),
    "target_cells": ("Target cells.jpg", 960),
    "schistocytes": ("Schizocyte smear 2009-12-22.JPG", 960),
    "sickle_cells": ("Sickle Cell Disease.jpg", 960),
    "teardrop_cells": ("Teardrop Cells smear 2009-09-22.JPG", 960),
    "elliptocytes": ("Hereditary Elliptocytosis 6 0.jpg", 960),
    "stomatocytes": ("Stomatocytes.jpg", 960),
    "acanthocytes": ("Acanthocytes 4.jpg", 960),
    "echinocytes": ("Crenated red cells 11.jpg", 960),
    "basophilic_stippling": ("Basophilic stippling 2.jpg", 960),
    "howell_jolly": ("Howell-Jolly smear 2010-11-17.JPG", 960),
    "rouleaux": ("Rouleaux Red Cells.jpg", 960),
    "agglutination": ("Red cell agglutination.jpg", 960),
    "giant_platelet": ("Micrograph of a giant platelet.jpg", 330),
    "platelet_clumping": ("Platelet Clumping 8.jpg", 960),
    "platelet_satellitism": ("Platelet Satellitism smear 2009-09-11.JPG", 960),
    "anisocytosis": ("Anisocytosis 2.jpg", 960),
    "iron_deficiency": (
        "Iron-deficiency Anemia, Peripheral Blood Smear (4422704616).jpg", 960),
    "reticulocytes": ("Reticulocytes Human Blood Supravital Stain.jpg", 960),
}


def url_for(title, width):
    name = title.replace(" ", "_")
    h = hashlib.md5(name.encode()).hexdigest()
    q = urllib.parse.quote(name)
    return (f"https://upload.wikimedia.org/wikipedia/commons/thumb/"
            f"{h[0]}/{h[:2]}/{q}/{width}px-{q}")


def fetch(url):
    while True:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        try:
            with urllib.request.urlopen(req, timeout=300) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code == 429 or e.code >= 500:
                wait = int(e.headers.get("retry-after") or 60)
                print(f"  HTTP {e.code}, {wait} s kutilmoqda", flush=True)
                time.sleep(wait)
                continue
            raise


def to_srgb(im):
    icc = im.info.get("icc_profile")
    if icc:
        src = ImageCms.ImageCmsProfile(io.BytesIO(icc))
        dst = ImageCms.createProfile("sRGB")
        im = ImageCms.profileToProfile(im.convert("RGB"), src, dst,
                                       outputMode="RGB")
    return im.convert("RGB")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", type=pathlib.Path)
    args = ap.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    for key, (title, width) in IMAGES.items():
        cached = args.cache / f"{key}.orig" if args.cache else None
        if cached and cached.exists():
            raw = cached.read_bytes()
        else:
            raw = fetch(url_for(title, width))
            if cached:
                cached.parent.mkdir(parents=True, exist_ok=True)
                cached.write_bytes(raw)
            time.sleep(2)
        im = to_srgb(ImageOps.exif_transpose(Image.open(io.BytesIO(raw))))
        scale = min(1.0, MAX_W / im.width, MAX_H / im.height)
        if scale < 1:
            im = im.resize((round(im.width * scale), round(im.height * scale)),
                           Image.LANCZOS)
        dest = OUT / f"{key}.jpg"
        im.save(dest, "JPEG", quality=QUALITY, optimize=True)
        print(f"{key}: {im.width}×{im.height}, {dest.stat().st_size // 1024} KB",
              flush=True)


if __name__ == "__main__":
    main()
