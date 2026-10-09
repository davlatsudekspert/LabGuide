"""Mikroskopiya atlasi rasmlarini yuklash va ilova uchun tayyorlash.

    python3 tool/microscopy_images.py [--cache DIR]

- Manzillar tool/microscopy_atlas_src.py dagi ``IMAGES`` dan olinadi.
- Wikimedia Commons: katta fayl uchun 1920 px thumbnail (Commons ruxsat
  bergan o'lcham), kichigi — asl fayl. CDC PHIL: hi-res fayl.
- 429 bo'lsa ``Retry-After`` kutiladi (Wikimedia limitlari qattiq).
- Ishlov: EXIF yo'nalishi qo'llanadi, rang sRGB'ga o'tkaziladi, uzun tomoni
  MAX_SIDE gacha **faqat kichraytiriladi** (kattalashtirilmaydi), JPEG
  sifat 80. Kesish, yozuv qo'shish, rang tuzatish yo'q; EXIF/ICC yozilmaydi.
- ``--cache`` papkasida ``<id>.orig`` bo'lsa, qayta yuklanmaydi.

Talab: Pillow (pip install pillow).
"""
import argparse
import io
import pathlib
import sys
import time
import urllib.parse
import urllib.request

from PIL import Image, ImageCms, ImageOps

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from microscopy_atlas_src import IMAGES, IMG_DIR, MAX_SIDE, ROOT  # noqa: E402

UA = "LabGuideBot/0.1 (+https://github.com/davlatsudekspert/labguide)"
QUALITY = 80
Image.MAX_IMAGE_PIXELS = 60_000_000


def download_url(img):
    """Commons: thumb.wikimedia.org standart o'lchamlari (1920/1280 px) —
    upload.wikimedia.org asl fayllari umumiy IP'dan tez-tez 429 qaytaradi.
    ``"fetch": "original"`` — asl fayl (kichik rasm yoki aniq nusxa kerak)."""
    url = img["file_url"]
    if img["provider"] != "commons":
        return url
    w, _ = img["original_size"]
    if img.get("fetch") == "original" or w <= 1280:
        return url
    width = 1920 if w > 1920 else 1280
    # upload.wikimedia.org/wikipedia/commons/a/ab/Name.jpg →
    # thumb.wikimedia.org/wikipedia/commons/thumb/a/ab/Name.jpg/1920px-Name.jpg
    head, name = url.rsplit("/", 1)
    head = head.replace(
        "upload.wikimedia.org/wikipedia/commons/",
        "thumb.wikimedia.org/wikipedia/commons/thumb/",
        1,
    )
    return f"{head}/{name}/{width}px-{name}"


def fetch(url):
    while True:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        try:
            with urllib.request.urlopen(req, timeout=300) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code == 429 or e.code >= 500:
                wait = max(30, min(int(e.headers.get("retry-after") or 120), 650))
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


def process(data, out):
    im = Image.open(io.BytesIO(data))
    im = ImageOps.exif_transpose(im)
    if im.mode in ("RGBA", "LA", "P"):
        rgba = im.convert("RGBA")
        if rgba.getextrema()[3][0] < 255:
            sys.exit(f"{out}: shaffof piksellar bor — qo'lda tekshiring")
        im = rgba
    im = to_srgb(im)
    w, h = im.size
    if max(w, h) > MAX_SIDE:
        k = MAX_SIDE / max(w, h)
        im = im.resize((round(w * k), round(h * k)), Image.LANCZOS)
    im.save(out, "JPEG", quality=QUALITY, optimize=True, progressive=True)
    return im.size


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", type=pathlib.Path,
                    default=ROOT / "build/microscopy_cache")
    args = ap.parse_args()
    args.cache.mkdir(parents=True, exist_ok=True)
    out_dir = ROOT / IMG_DIR
    out_dir.mkdir(parents=True, exist_ok=True)
    for img in IMAGES:
        cached = args.cache / f"{img['id']}.orig"
        if not cached.exists():
            url = download_url(img)
            print(img["id"], "←", urllib.parse.unquote(url), flush=True)
            cached.write_bytes(fetch(url))
            time.sleep(10)
        out = out_dir / f"{img['id']}.jpg"
        size = process(cached.read_bytes(), out)
        print(f"{img['id']}: {size[0]}x{size[1]}, {out.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
