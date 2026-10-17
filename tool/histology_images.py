"""Gistologiya bo'limi rasmlarini yuklash va ilova uchun tayyorlash.

    python3 tool/histology_images.py [--cache DIR]

- Faqat Wikimedia Commons'dagi erkin litsenziyali fayllar (CC0 / CC BY /
  CC BY-SA). Har faylning litsenziyasi, muallifi va asl izohi fayl
  sahifasidan qo'lda tekshirilgan (2026-10-17); natija
  lib/features/histology/histology_content.dart dagi ``HistoImage`` larda va
  docs/HISTOLOGY_SOURCES.md jadvalida.
- Yuklash: ``Special:FilePath?width=960`` (Commons standart thumbnail'i).
- Ishlov: EXIF yo'nalishi qo'llanadi, rang sRGB, eni 900 px gacha (tik rasm —
  bo'yi 1200 px gacha) **faqat kichraytiriladi**; kesish, yozuv qo'shish,
  rang tuzatish yo'q; JPEG sifat 80, EXIF/ICC yozilmaydi.
- Natija: assets/histology/img/<id>.jpg

Talab: Pillow (pip install pillow).
"""
import argparse
import io
import pathlib
import time
import urllib.error
import urllib.parse
import urllib.request

from PIL import Image, ImageCms, ImageOps

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/histology/img"
UA = "LabGuideBot/0.1 (+https://github.com/davlatsudekspert/labguide)"
MAX_W = 900
MAX_H = 1200
QUALITY = 80

# id (ilovadagi rasm nomi) → Commons fayl nomi. Rasm va nom mosligi ko'z
# bilan tekshirilgan; tanlash sabablari docs/HISTOLOGY_SOURCES.md da.
IMAGES = {
    "simple_squamous": "Epithelial Tissues Simple Squamous Epithelium (41722161021).jpg",
    "simple_cuboidal": "Epithelial Tissues Simple Cuboidal Epithelium (41681552432).jpg",
    "simple_columnar": "Epithelial Tissues Simple Columnar Epithelium (27854453538).jpg",
    "pseudostratified": "Epithelial Tissues Pseudostratified Columnar Epithelium (26915091897).jpg",
    "stratified_squamous": "Epithelial Tissues Stratified Squamous Epithelium (40230837610).jpg",
    "transitional": "Epithelial Tissues Transitional (27025225607).jpg",
    "loose_ct": "Connective Tissue Loose Aerolar (41743648512).jpg",
    "dense_regular": "Connective Tissue White Fibrous Connective (27986735128).jpg",
    "adipose": "Connective Tissues Adipose (26915768737).jpg",
    "hyaline": "Connective Tissue Hyaline Cartilage (26989336187).jpg",
    "elastic_cartilage": "Connective Tissue Elastic Cartilage (41855666011).jpg",
    "fibrocartilage": "Connective Tissue Fibrocartilage (27988652098).jpg",
    "bone": "Connective Tissue Compact Bone (41068142774).jpg",
    "skeletal": "Muscle Tissue Skeletal Muscle Fibers (40153601630).jpg",
    "cardiac": "Cardiac muscle histology 400x.jpg",
    "smooth": "Muscle Tissue Smooth (40087100000).jpg",
    "neuron": "Nervous Tissue Spinal Cord Motor Neuron (41850850452).jpg",
    "nerve": "Nervous Tissue Nerve Bundle (40106758860).jpg",
    "liver": "Histopathology of liver zones.jpg",
    "kidney": "Benign kidney -- intermed mag.jpg",
    "stain_pas": "Renal corpuscle.jpg",
}


def fetch(title):
    url = ("https://commons.wikimedia.org/wiki/Special:FilePath/"
           + urllib.parse.quote(title.replace(" ", "_")) + "?width=960")
    while True:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        try:
            with urllib.request.urlopen(req, timeout=300) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code == 429 or e.code >= 500:
                print(f"  HTTP {e.code}, 60 s kutilmoqda", flush=True)
                time.sleep(60)
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
    for key, title in IMAGES.items():
        cached = args.cache / f"{key}.orig" if args.cache else None
        if cached and cached.exists():
            raw = cached.read_bytes()
        else:
            raw = fetch(title)
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
        print(f"{key}: {im.width}×{im.height}, {dest.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
