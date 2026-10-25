#!/usr/bin/env python3
"""36 ta video auditi (docs/video/AUDIT_36_VIDEOS.md): 30 ta “Qanday
foydalaniladi?” videosi (build/video_out/) va 6 ta ilmiy namuna animatsiya
(--samples DIR, faqat o‘qiladi).

Har video uchun o‘lchanadi (taxmin emas):
  1) ffprobe: konteyner, kodek, o‘lcham, fps, davomiylik, hajm, audio oqimlari, sha256;
  2) aniqlik: kirish kartochkasi, 3 ta o‘rta kadr, yakuniy kartochka — MP4 dagi
     kadr bilan aynan o‘sha kadrning siqilmagan nusxasi (compose.py bilan qayta
     chizilgan) orasidagi PSNR (dB); namunalarda — Laplasian dispersiyasi;
     kadrlar to‘liq o‘lchamda build/video_audit/<video>/ ga yoziladi (ko‘rish uchun);
  3) toshish: subtitr shrifti/qatorlari, kartochka matnlari va yorliq kengligi;
  4) subtitr: SRT va VTT tuzilmasi, o‘zaro tengligi, storyboard bilan tengligi,
     oxirgi cue = davomiylik; kadrga yozilgan matn — OCR (tesseract eng/rus);
  5) atamalar: «…» / “…” ichidagi har UI nomi shu til ARB yoki lib/ matnida
     bormi; uz apostroflar (U+2018 / U+2019);
  6) taqiqlangan so‘zlar (Pro, to‘lov, «Rasmiy emas», video tugmasi);
  9) uchinchi tomon rasmlari (frames.json `assets` × IN_APP_PHOTOS ro‘yxati) va
     mualliflik kartochkasi / credits fayli.
Natija: build/video_audit/audit.json (hisobot shu fayldan yoziladi).

  python3 tool/video/audit36.py [--samples /path/to/lesson_samples] [--only 06_mikroskopiya_uz]
"""
import argparse
import difflib
import glob
import hashlib
import json
import math
import os
import re
import subprocess
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageStat

sys.path.insert(0, os.path.dirname(__file__))
import compose  # noqa: E402

ROOT = compose.ROOT
OUT = os.path.join(ROOT, 'build', 'video_audit')
LANGS = ('uz', 'ru', 'en')
OCR_LANG = {'uz': 'eng', 'ru': 'rus', 'en': 'eng'}

FORBIDDEN = re.compile(
    r'\bpro\b|premium|премиум|obuna|подписк|subscri|to[‘’\']?lov|оплат|payment|paywall|'
    r'rasmiy emas|tez orada|скоро|coming soon',
    re.I)
UZ_BAD = re.compile("(?<=[oOgG])’(?=[a-zA-Z])|'|`|ʻ|ʼ")


def sh(cmd):
    return subprocess.check_output(cmd, text=True)


def probe(path):
    j = json.loads(sh(['ffprobe', '-v', 'error', '-show_entries',
                       'format=format_name,duration,bit_rate:stream=codec_type,codec_name,width,height,'
                       'r_frame_rate,pix_fmt,nb_frames', '-of', 'json', path]))
    v = [s for s in j['streams'] if s['codec_type'] == 'video'][0]
    n, d = v['r_frame_rate'].split('/')
    h = hashlib.sha256(open(path, 'rb').read()).hexdigest()
    return {
        'container': j['format']['format_name'], 'codec': v['codec_name'], 'pix_fmt': v.get('pix_fmt'),
        'w': v['width'], 'h': v['height'], 'fps': int(n) / int(d),
        'duration': round(float(j['format']['duration']), 3),
        'frames': int(v.get('nb_frames') or 0),
        'bytes': os.path.getsize(path), 'kbps': round(int(j['format'].get('bit_rate', 0)) / 1000),
        'audio_streams': sum(1 for s in j['streams'] if s['codec_type'] == 'audio'),
        'other_streams': sum(1 for s in j['streams'] if s['codec_type'] not in ('video', 'audio')),
        'sha256': h,
    }


TS = re.compile(r'^(\d\d):(\d\d):(\d\d)([,.])(\d\d\d) --> (\d\d):(\d\d):(\d\d)([,.])(\d\d\d)$')


def parse_subs(path, vtt):
    raw = open(path, encoding='utf-8').read()
    errors = []
    if '\r' in raw:
        errors.append('CRLF')
    body = raw
    if vtt:
        if not raw.startswith('WEBVTT\n'):
            errors.append('WEBVTT sarlavhasi yo‘q')
        body = raw[len('WEBVTT\n'):]
    cues = []
    for block in [b for b in body.strip('\n').split('\n\n') if b.strip()]:
        lines = block.split('\n')
        if not lines[0].strip().isdigit():
            errors.append(f'raqam yo‘q: {lines[0][:30]}')
            continue
        m = TS.match(lines[1]) if len(lines) > 1 else None
        if not m:
            errors.append(f'vaqt qatori xato: {lines[1:2]}')
            continue
        sep = ',' if not vtt else '.'
        if m.group(4) != sep or m.group(9) != sep:
            errors.append('ajratgich xato')
        a = int(m.group(1)) * 3600 + int(m.group(2)) * 60 + int(m.group(3)) + int(m.group(5)) / 1000
        b = int(m.group(6)) * 3600 + int(m.group(7)) * 60 + int(m.group(8)) + int(m.group(10)) / 1000
        cues.append((a, b, ' '.join(lines[2:]).strip()))
    for i, (a, b, t) in enumerate(cues):
        if b <= a:
            errors.append(f'cue {i + 1}: tugash ≤ boshlanish')
        if i and a < cues[i - 1][1] - 1e-6:
            errors.append(f'cue {i + 1}: ustma-ust')
        if not t:
            errors.append(f'cue {i + 1}: bo‘sh matn')
    return cues, errors


def frame_at(mp4, index, out_png):
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-i', mp4, '-vf', f'select=eq(n\\,{index})',
                    '-frames:v', '1', '-vsync', '0', out_png], check=True)
    return Image.open(out_png).convert('RGB')


def psnr(a, b):
    diff = ImageChops.difference(a, b)
    mse = sum(v * v for v in ImageStat.Stat(diff).rms) / 3
    return 99.0 if mse == 0 else round(10 * math.log10(255 ** 2 / mse), 1)


def laplacian_var(img):
    g = img.convert('L').filter(ImageFilter.Kernel((3, 3), [0, 1, 0, 1, -4, 1, 0, 1, 0], 1, 128))
    return round(ImageStat.Stat(g).var[0], 1)


def ocr(img, lang):
    p = os.path.join(OUT, '_ocr.png')
    img.convert('L').resize((img.width * 2, img.height * 2), Image.LANCZOS).save(p)
    try:
        return sh(['tesseract', p, '-', '-l', OCR_LANG[lang], '--psm', '6']).replace('\n', ' ')
    except subprocess.CalledProcessError:
        return ''


def norm(s):
    s = s.lower()
    s = re.sub(r'[«»“”„"‘’\'`ʻʼ—–\-→·:;,.!?()\[\]]', ' ', s)
    return re.sub(r'\s+', ' ', s).strip()


def similarity(a, b):
    return round(difflib.SequenceMatcher(None, norm(a), norm(b)).ratio(), 2)


def corpus(lang):
    """Shu tildagi ilova matnlari: ARB qiymatlari + lib/ dagi satr literallari."""
    arb = json.load(open(os.path.join(ROOT, 'lib', 'l10n', f'app_{lang}.arb'), encoding='utf-8'))
    parts = [v for k, v in arb.items() if not k.startswith('@') and isinstance(v, str)]
    for f in glob.glob(os.path.join(ROOT, 'lib', 'features', '**', '*.dart'), recursive=True):
        parts.append(open(f, encoding='utf-8').read())
    for f in glob.glob(os.path.join(ROOT, 'assets', '**', '*.json'), recursive=True):
        if os.path.getsize(f) < 30_000_000:
            parts.append(open(f, encoding='utf-8').read())
    text = '\n'.join(parts)
    return text.replace('\\u2018', '‘').replace('\\u2019', '’')


QUOTED = re.compile(r'«([^«»]+)»|“([^“”]+)”|„([^“„]+)“')


def quoted_terms(text):
    return [next(g for g in m.groups() if g) for m in QUOTED.finditer(text)]


def term_check(texts, lang, corp):
    missing = []
    for t in texts:
        for q in quoted_terms(t):
            q2 = q.rstrip('…').strip()
            # Ichma-ich qo‘shtirnoq va {plural} shablonlari: bo‘laklab qidiriladi.
            parts = [p for p in re.split(r'[„“”«»]|\{[^}]*\}|\d+', q2) if len(p.strip()) > 2]
            if not all(p.strip() in corp for p in parts):
                missing.append(q)
    return sorted(set(missing))


def audit_howto(topic, lang, corp, photos):
    vid = f"{topic['id']}_{lang}"
    mp4 = os.path.join(compose.OUT, vid + '.mp4')
    vdir = os.path.join(OUT, vid)
    os.makedirs(vdir, exist_ok=True)
    r = {'video': vid + '.mp4', 'kind': 'howto', 'topic': topic['id'], 'lang': lang, 'issues': []}
    r['probe'] = p = probe(mp4)
    if p['audio_streams'] or p['other_streams']:
        r['issues'].append('audio/boshqa oqim bor')
    # Subtitrlar.
    expect = compose.timeline(topic, lang)
    srt, e1 = parse_subs(os.path.join(compose.OUT, vid + '.srt'), False)
    vtt, e2 = parse_subs(os.path.join(compose.OUT, vid + '.vtt'), True)
    sub = {'srt_errors': e1, 'vtt_errors': e2, 'cues': len(srt)}
    sub['srt_eq_vtt'] = [(round(a, 3), round(b, 3), t) for a, b, t in srt] == \
                        [(round(a, 3), round(b, 3), t) for a, b, t in vtt]
    sub['eq_storyboard'] = [(round(a, 3), round(b, 3), t) for a, b, t in srt] == \
                           [(round(a, 3), round(b, 3), t) for a, b, t in expect]
    sub['end_vs_duration'] = round(p['duration'] - (srt[-1][1] if srt else 0), 3)
    if e1 or e2 or not sub['srt_eq_vtt'] or not sub['eq_storyboard'] or abs(sub['end_vs_duration']) > 1 / 24 + 1e-3:
        r['issues'].append('subtitr fayllari mos emas')
    r['subs'] = sub
    # Toshish (kartochka + subtitrlar).
    d = ImageDraw.Draw(Image.new('RGB', (10, 10)))
    caps = []
    for f in compose.frames_for(topic, lang):
        size = None
        for s in (40, 37, 34):
            lines = compose.wrap(d, f['text'][lang], compose.font(700, s), compose.W - 24 - 130 - 26)
            if len(lines) <= 3:
                size = s
                break
        widest = max(d.textlength(ln, font=compose.font(700, size or 34)) for ln in lines)
        caps.append((f['id'], size, len(lines), round(widest)))
    over = [c for c in caps if c[1] is None or c[3] > compose.W - 24 - 130 - 26]
    label_w = d.textlength(compose.LABELS[lang][0], font=compose.font(600, 24)) + 36
    title_w = max(d.textlength(ln, font=compose.font(700, 46))
                  for ln in compose.wrap(d, topic['title'][lang], compose.font(700, 46), compose.W - 90))
    r['overflow'] = {'captions': len(caps), 'min_font': min(c[1] or 0 for c in caps),
                     'max_lines': max(c[2] for c in caps), 'over': over,
                     'label_px': round(label_w), 'title_px': round(title_w), 'frame_w': compose.W}
    if over or label_w > compose.W - 24 or title_w > compose.W - 90:
        r['issues'].append('matn kadrdan chiqadi')
    # Aniqlik: kirish, 3 o‘rta, yakun — PSNR va OCR.
    src_dir = os.path.join(compose.FRAMES, lang, topic['id'])
    meta = {m['id']: m for m in json.load(open(os.path.join(src_dir, 'frames.json'), encoding='utf-8'))['frames']}
    frames = compose.frames_for(topic, lang)
    picks = [len(frames) // 4, len(frames) // 2, (3 * len(frames)) // 4]
    checks = []
    fps = compose.FPS
    # kirish
    idx = int(1.5 * fps)
    got = frame_at(mp4, idx, os.path.join(vdir, '00_card.png'))
    ref = compose.card(topic['title'][lang], topic['subtitle'][lang], compose.LABELS[lang][0]).convert('RGB')
    checks.append({'at': 'card', 'psnr': psnr(got, ref), 'lap': laplacian_var(got)})
    t = compose.CARD
    for i, f in enumerate(frames):
        if i in picks:
            m = meta[f['id']]
            base, (x, y, s) = compose.step_canvas(os.path.join(src_dir, m['file']), m, str(i + 1), f['text'][lang])
            at = None if not m['tap'] else (x + m['tap'][0] * s, y + m['tap'][1] * s)
            n = int(round(f['sec'] * fps))
            k = n // 2
            idx = int(round(t * fps)) + k
            ref = compose.draw_tap(base, at, (n - k) / fps).convert('RGB')
            got = frame_at(mp4, idx, os.path.join(vdir, f'{i + 1:02d}_{f["id"]}.png'))
            cap_box = (24, 30, compose.W - 24, 30 + 200)
            text = ocr(got.crop((130, 30, compose.W - 30, 210)), lang)
            checks.append({'at': f['id'], 'psnr': psnr(got, ref), 'lap': laplacian_var(got),
                           'ocr_sim': similarity(text, f['text'][lang]), 'ocr': text.strip()[:160]})
            del cap_box
        t += f['sec']
    end_start = compose.timeline(topic, lang)[-1][0]
    idx = int(round((end_start + 1.5) * fps))
    got = frame_at(mp4, idx, os.path.join(vdir, '99_end.png'))
    ref = compose.card(topic['title'][lang], compose.LABELS[lang][1], compose.LABELS[lang][0], end=True).convert('RGB')
    checks.append({'at': 'end', 'psnr': psnr(got, ref), 'lap': laplacian_var(got)})
    rows = compose.credits_for(topic, lang)
    if rows:
        cstart = compose.timeline(topic, lang)[-2][0]
        got = frame_at(mp4, int(round((cstart + 2) * fps)), os.path.join(vdir, '98_credits.png'))
        ref = compose.credits_card(topic, lang, rows).convert('RGB')
        checks.append({'at': 'credits', 'psnr': psnr(got, ref), 'lap': laplacian_var(got)})
    r['sharpness'] = checks
    if min(c['psnr'] for c in checks) < 30:
        r['issues'].append('siqish sifati past (PSNR < 30 dB)')
    if any(c.get('ocr_sim', 1) < 0.6 for c in checks):
        r['issues'].append('OCR: kadrdagi subtitr kutilgandan farq qiladi (ko‘rib tekshiring)')
    # Atamalar va taqiqlangan so‘zlar.
    texts = [topic['title'][lang], topic['subtitle'][lang]] + [f['text'][lang] for f in frames]
    r['terms_missing'] = term_check(texts, lang, corp)
    r['uz_apostrophe_bad'] = [t for t in texts if lang == 'uz' and UZ_BAD.search(t)]
    r['forbidden'] = [t for t in texts if FORBIDDEN.search(t)]
    if r['uz_apostrophe_bad'] or r['forbidden']:
        r['issues'].append('atama/so‘z qoidasi')
    # Rasmlar huquqi.
    used = sorted({a for f in frames for a in meta[f['id']].get('assets', [])})
    third = [a for a in used if a in photos]
    r['assets'] = {'total': len(used), 'third_party': [(os.path.basename(a), photos[a]['litsenziya'], photos[a]['muallif'])
                                                       for a in third],
                   'own': [a for a in used if a not in photos],
                   'credits_file': os.path.exists(os.path.join(compose.OUT, compose.credits_file(topic, lang))),
                   'credits_card': bool(rows)}
    if third and not (rows and r['assets']['credits_file']):
        r['issues'].append('uchinchi tomon rasmi mualliflarsiz')
    return r


def audit_sample(path, lang, corp, spec_dir):
    name = os.path.basename(path)[:-4]
    vdir = os.path.join(OUT, name)
    os.makedirs(vdir, exist_ok=True)
    r = {'video': name + '.mp4', 'kind': 'sample', 'lang': lang, 'issues': []}
    r['probe'] = p = probe(path)
    if p['audio_streams'] or p['other_streams']:
        r['issues'].append('audio/boshqa oqim bor')
    srt, e1 = parse_subs(path[:-4] + '.srt', False)
    vtt, e2 = parse_subs(path[:-4] + '.vtt', True)
    sub = {'srt_errors': e1, 'vtt_errors': e2, 'cues': len(srt),
           'srt_eq_vtt': [(round(a, 3), round(b, 3), t) for a, b, t in srt] ==
                         [(round(a, 3), round(b, 3), t) for a, b, t in vtt],
           'end_vs_duration': round(p['duration'] - (srt[-1][1] if srt else 0), 3)}
    # Namuna JSON dagi subtitrlar bilan.
    key = name.rsplit('_', 1)[0]
    spec = json.load(open(os.path.join(spec_dir, f'sample_{key}.json'), encoding='utf-8'))
    caps = [c[lang] for sc in spec['scenes'] for c in sc['captions']]
    srt_texts = [t for _, _, t in srt]
    sub['captions_in_srt'] = sum(1 for c in caps if c in srt_texts)
    sub['captions_total'] = len(caps)
    if e1 or e2 or not sub['srt_eq_vtt'] or abs(sub['end_vs_duration']) > 1 / 24 + 1e-3 \
            or sub['captions_in_srt'] != len(caps):
        r['issues'].append('subtitr fayllari mos emas')
    r['subs'] = sub
    checks = []
    fps = p['fps']
    picks = [('card', 1.5)] + [(f'cue{i + 1}', (a + b) / 2) for i, (a, b, _) in
                               enumerate(srt) if i in (len(srt) // 4, len(srt) // 2, (3 * len(srt)) // 4)] + \
            [('end', p['duration'] - 1.5)]
    for tag, tt in picks:
        got = frame_at(path, int(tt * fps), os.path.join(vdir, f'{tag}_{tt:05.1f}s.png'))
        checks.append({'at': tag, 't': round(tt, 2), 'lap': laplacian_var(got)})
    r['sharpness'] = checks
    texts = [t for _, _, t in srt]
    r['terms_missing'] = term_check(texts, lang, corp)
    r['uz_apostrophe_bad'] = [t for t in texts if lang == 'uz' and UZ_BAD.search(t)]
    r['forbidden'] = [t for t in texts if FORBIDDEN.search(t)]
    if r['uz_apostrophe_bad'] or r['forbidden']:
        r['issues'].append('atama/so‘z qoidasi')
    return r


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--samples')
    ap.add_argument('--only', action='append')
    ap.add_argument('--sample-spec', default=os.path.join(ROOT, 'tool', 'video', 'lessons'),
                    help='namunalar render qilingan sample_*.json papkasi')
    a = ap.parse_args()
    os.makedirs(OUT, exist_ok=True)
    story = json.load(open(compose.STORY, encoding='utf-8'))
    photos = compose._photos()
    out_path = os.path.join(OUT, 'audit.json')
    results = json.load(open(out_path)) if os.path.exists(out_path) and a.only else {}
    corp = {lang: corpus(lang) for lang in LANGS}
    for topic in story['topics']:
        for lang in LANGS:
            vid = f"{topic['id']}_{lang}"
            if a.only and vid not in a.only:
                continue
            results[vid] = audit_howto(topic, lang, corp[lang], photos)
            print(vid, results[vid]['issues'] or 'OK', flush=True)
    if a.samples:
        for path in sorted(glob.glob(os.path.join(a.samples, '*.mp4'))):
            name = os.path.basename(path)[:-4]
            if a.only and name not in a.only:
                continue
            lang = name.rsplit('_', 1)[1]
            results[name] = audit_sample(path, lang, corp[lang], a.sample_spec)
            print(name, results[name]['issues'] or 'OK', flush=True)
    json.dump(results, open(out_path, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)


if __name__ == '__main__':
    main()
