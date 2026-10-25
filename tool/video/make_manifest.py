#!/usr/bin/env python3
"""“Qanday foydalaniladi?” videolari uchun ro‘yxat (assets/howto/videos.json).

Papkadagi <mavzu>_<til>.mp4 fayllarini o‘lchaydi (bayt, soniya, sha256) va
ilova o‘qiydigan sxemada JSON yozadi: har how-to bo‘limi × til uchun bitta
yozuv (docs/video/DELIVERY_PLAN.md). Videolarni HECH QAYERGA yuklamaydi —
faqat lokal fayllarni o‘qiydi (va --stage bilan lokal papkaga nusxalaydi).

  python3 tool/video/make_manifest.py build/video_out \\
      --base-url https://<egasi-hostingi>/labguide/howto/v1 \\
      --out videos.json --sha256sums SHA256SUMS [--stage DIR] [--approval D-NN]

--base-url berilmasa, manzillar ataylab ishlamaydigan
`https://NEEDS-OWNER-HOST.invalid/...` bo‘ladi: ilova tekshiruvchisi bunday
ro‘yxatni rad etadi (tasodifan e’lon qilinmasin).

Fayl nomi (yuklanadigan): <mavzu>_<til>.<sha256 ning 8 belgisi>.mp4 — fayl
o‘zgarsa nomi ham o‘zgaradi (kesh muammosi yo‘q, eski versiya buzilmaydi).

Soniya: ffprobe bo‘lsa — undan, bo‘lmasa MP4 `mvhd` qutisidan (tashqi
kutubxonasiz). Umumiy videoda (10-mavzu, 8 bo‘lim) har bo‘lim qayerdan
boshlanishi tool/video/storyboards.json dan hisoblanadi va SRT bilan
solishtiriladi.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
STORY = os.path.join(ROOT, 'tool', 'video', 'storyboards.json')

SCHEMA_VERSION = 1
LANGS = ('uz', 'ru', 'en')
PLACEHOLDER_BASE = 'https://NEEDS-OWNER-HOST.invalid/labguide/howto/v1'

# lib/features/howto/howto_registry.dart dagi HowToSection tartibi.
SECTIONS = (
    'calibration', 'qc', 'preanalytics', 'calculators', 'instruments',
    'microscopy', 'coprology', 'assessment', 'differential', 'cytology',
    'spermogram', 'bloodGroup', 'histology', 'urinalysis', 'bloodMorph',
    'coagulogram',
)

# 10-mavzu: 8 bo‘lim bitta umumiy videoda; bo‘lim shu kadrdan boshlanadi.
SHARED_TOPIC = '10_boshqa_funksiyalar'
SHARED_START_FRAME = {
    'differential': 'diff_hub',
    'cytology': 'cyto_hub',
    'spermogram': 'sperm_hub',
    'bloodGroup': 'bg_hub',
    'histology': 'histo_hub',
    'urinalysis': 'urin_hub',
    'bloodMorph': 'bm_hub',
    'coagulogram': 'coag_hub',
}

# compose.py: sarlavha kartochkasi davomiyligi (birinchi kadrgacha).
CARD = 3.0

FILE_RE = re.compile(r'^(\d\d_[a-z_]+)_(uz|ru|en)\.mp4$')


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def _boxes(data, start, end):
    """MP4 qutilari: (tur, ma’lumot boshi, quti oxiri)."""
    pos = start
    while pos + 8 <= end:
        size, kind = struct.unpack('>I4s', data[pos:pos + 8])
        header = 8
        if size == 1:
            if pos + 16 > end:
                return
            size = struct.unpack('>Q', data[pos + 8:pos + 16])[0]
            header = 16
        elif size == 0:
            size = end - pos
        if size < header or pos + size > end:
            return
        yield kind.decode('latin-1'), pos + header, pos + size
        pos += size


def mp4_duration(data):
    """`moov/mvhd` dan davomiylik (soniya) yoki None."""
    for kind, body, end in _boxes(data, 0, len(data)):
        if kind != 'moov':
            continue
        for k2, b2, _ in _boxes(data, body, end):
            if k2 != 'mvhd':
                continue
            version = data[b2]
            if version == 1:
                timescale, duration = struct.unpack('>IQ', data[b2 + 20:b2 + 32])
            else:
                timescale, duration = struct.unpack('>II', data[b2 + 12:b2 + 20])
            return duration / timescale if timescale else None
    return None


def ffprobe_duration(path):
    if not shutil.which('ffprobe'):
        return None
    try:
        out = subprocess.run(
            ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
             '-of', 'default=nw=1:nk=1', path],
            check=True, capture_output=True, text=True, timeout=60,
        ).stdout.strip()
        return float(out)
    except (subprocess.SubprocessError, ValueError):
        return None


def duration_of(path):
    d = ffprobe_duration(path)
    if d is None:
        with open(path, 'rb') as f:
            d = mp4_duration(f.read())
    if d is None:
        raise SystemExit(f'{path}: davomiylikni aniqlab bo‘lmadi')
    return round(d, 2)


def topic_sections(story):
    """Mavzu id → [bo‘limlar]. 9-mavzu (bo‘limsiz) ro‘yxatga kirmaydi."""
    out = {}
    for t in story['topics']:
        if t['id'] == SHARED_TOPIC:
            out[t['id']] = list(SHARED_START_FRAME)
        elif t.get('section'):
            out[t['id']] = [t['section']]
    return out


def frame_starts(topic, lang):
    """Kadr id → boshlanish soniyasi (compose.py dagi tartib)."""
    t = CARD
    starts = {}
    for f in topic['frames']:
        if lang not in f.get('langs', list(LANGS)):
            continue
        starts[f['id']] = round(t, 2)
        t += f['sec']
    return starts


def srt_starts(path):
    """SRT dagi har cue boshlanishi (soniya)."""
    if not os.path.exists(path):
        return None
    starts = []
    with open(path, encoding='utf-8') as f:
        for line in f:
            m = re.match(r'(\d+):(\d+):(\d+)[,.](\d+) -->', line)
            if m:
                h, mi, s, ms = (int(x) for x in m.groups())
                starts.append(round(h * 3600 + mi * 60 + s + ms / 1000, 2))
    return starts


def upload_name(topic, lang, sha, ext='mp4'):
    return f'{topic}_{lang}.{sha[:8]}.{ext}'


def build(folder, base_url, story, allow_partial=False):
    """(ro‘yxat, fayllar) — fayllar: yuklanadigan nom, manba, sha256, …"""
    by_topic = topic_sections(story)
    topics = {t['id']: t for t in story['topics']}
    found = {}
    for name in sorted(os.listdir(folder)):
        m = FILE_RE.match(name)
        if m:
            found[(m.group(1), m.group(2))] = os.path.join(folder, name)
    if not found:
        raise SystemExit(f'{folder}: <mavzu>_<til>.mp4 fayllari topilmadi')

    missing = [f'{t}_{lang}.mp4' for t in by_topic for lang in LANGS
               if (t, lang) not in found]
    if missing and not allow_partial:
        raise SystemExit('yetishmaydi (har mavzu uz/ru/en bo‘lishi shart): '
                         + ', '.join(missing))

    files = []
    measured = {}
    for (topic, lang), path in sorted(found.items()):
        sha = sha256_of(path)
        rec = {
            'topic': topic, 'lang': lang, 'source': path,
            'upload_name': upload_name(topic, lang, sha),
            'bytes': os.path.getsize(path), 'seconds': duration_of(path),
            'sha256': sha, 'sections': by_topic.get(topic, []),
        }
        files.append(rec)
        measured[(topic, lang)] = rec
        for ext in ('vtt', 'srt'):
            side = path[:-3] + ext
            if os.path.exists(side):
                s = sha256_of(side)
                files.append({
                    'topic': topic, 'lang': lang, 'source': side,
                    'upload_name': upload_name(topic, lang, s, ext),
                    'bytes': os.path.getsize(side), 'seconds': None,
                    'sha256': s, 'sections': [],
                })

    base = base_url.rstrip('/')
    videos = []
    for section in SECTIONS:
        topic = next((t for t, secs in by_topic.items() if section in secs), None)
        if topic is None:
            raise SystemExit(f'{section}: mavzu topilmadi (storyboards.json)')
        for lang in LANGS:
            rec = measured.get((topic, lang))
            if rec is None:
                continue
            entry = {
                'section': section, 'lang': lang,
                'url': f'{base}/{rec["upload_name"]}',
                'bytes': rec['bytes'], 'seconds': rec['seconds'],
                'sha256': rec['sha256'],
            }
            if topic == SHARED_TOPIC:
                start = frame_starts(topics[topic], lang)[SHARED_START_FRAME[section]]
                cues = srt_starts(rec['source'][:-3] + 'srt')
                if cues is not None and not any(abs(c - start) < 0.05 for c in cues):
                    raise SystemExit(
                        f'{rec["source"]}: {section} boshlanishi {start} s '
                        'SRT dagi birorta cue bilan mos emas')
                entry['start_seconds'] = start
            videos.append(entry)
    return videos, files


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('folder')
    ap.add_argument('--base-url', default=PLACEHOLDER_BASE,
                    help='https://… — egasi videolarni joylagan papka')
    ap.add_argument('--out', help='videos.json (berilmasa — stdout)')
    ap.add_argument('--sha256sums', help='yuklanadigan fayllar uchun SHA256SUMS')
    ap.add_argument('--stage', help='fayllarni yuklanadigan nomlar bilan shu '
                    'lokal papkaga nusxalash (yuklash emas)')
    ap.add_argument('--approval', help='egasi qarori: D-NN (docs/DECISIONS.md)')
    ap.add_argument('--allow-partial', action='store_true')
    args = ap.parse_args(argv)

    if not args.base_url.startswith('https://'):
        raise SystemExit('--base-url https:// bilan boshlanishi kerak')
    if args.approval and not re.fullmatch(r'D-\d+[a-z]?', args.approval):
        raise SystemExit('--approval: D-NN ko‘rinishida')
    with open(STORY, encoding='utf-8') as f:
        story = json.load(f)
    videos, files = build(args.folder, args.base_url, story, args.allow_partial)

    doc = {
        'schema_version': SCHEMA_VERSION,
        'owner_approval': args.approval,
        'videos': videos,
    }
    text = json.dumps(doc, ensure_ascii=False, indent=2) + '\n'
    if args.out:
        with open(args.out, 'w', encoding='utf-8') as f:
            f.write(text)
    else:
        sys.stdout.write(text)

    if args.sha256sums:
        with open(args.sha256sums, 'w', encoding='utf-8') as f:
            for r in files:
                f.write(f'{r["sha256"]}  {r["upload_name"]}\n')
    if args.stage:
        os.makedirs(args.stage, exist_ok=True)
        for r in files:
            shutil.copyfile(r['source'], os.path.join(args.stage, r['upload_name']))

    mp4 = [r for r in files if r['upload_name'].endswith('.mp4')]
    total = sum(r['bytes'] for r in mp4)
    unmapped = sorted({r['topic'] for r in mp4 if not r['sections']})
    print(f'{len(mp4)} ta MP4, {total / 1e6:.1f} MB; ro‘yxatda {len(videos)} ta '
          f'yozuv ({len({v["section"] for v in videos})} bo‘lim)', file=sys.stderr)
    if unmapped:
        print('bo‘limsiz mavzu (ro‘yxatga kirmadi): ' + ', '.join(unmapped),
              file=sys.stderr)
    if args.base_url == PLACEHOLDER_BASE:
        print('DIQQAT: --base-url berilmagan — manzillar .invalid (ilova rad '
              'etadi). Hosting tanlangach qayta yurgizing.', file=sys.stderr)


if __name__ == '__main__':
    main()
