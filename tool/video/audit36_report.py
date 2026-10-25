#!/usr/bin/env python3
"""build/video_audit/audit.json → docs/video/AUDIT_36_VIDEOS.csv va .md jadvali.

O‘lchovlar audit36.py dan; ko‘zdan kechirish natijalari, ilmiy holat va
verdikt — quyidagi VIEW / SCIENCE jadvallarida (auditor qo‘lda yozgan, har biri
ko‘rilgan kadrga asoslangan). Verdikt qoidasi:
  NEEDS_FIX    — hal qilinmagan texnik nuqson bor;
  NEEDS_EXPERT — texnik toza, lekin mutaxassis tasdiqlamagan ilmiy/tibbiy mazmun bor;
  PASS         — texnik toza VA faqat ilova UI qo‘llanmasi (tasdiqlanmagan ilmiy da’vosiz).

  python3 tool/video/audit36_report.py
"""
import csv
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
AUDIT = os.path.join(ROOT, 'build', 'video_audit', 'audit.json')
OCR_SAMPLES = os.path.join(ROOT, 'build', 'video_audit', 'samples_ocr.json')
CSV = os.path.join(ROOT, 'docs', 'video', 'AUDIT_36_VIDEOS.csv')
MD = os.path.join(ROOT, 'docs', 'video', 'AUDIT_36_VIDEOS.md')
BEGIN, END = '<!-- audit:begin -->', '<!-- audit:end -->'

# Mavzu bo‘yicha: (ilova moslig‘i, ilmiy holat, qaysi bayonotlar tasdiqlanmagan)
SCIENCE = {
    '01_kalibrlash': ('IFU moslik qoidalari va kalibrlash yozuvi qoidalari ekranda (CALIB-ACCEPTANCE-RULES, '
                      'CALIB-RECORD-FIELDS, IFU-MATCHING-RULES — AWAITING_EXPERT)'),
    '02_sifat_nazorati': ('Subtitr: «1-2s — ogohlantirish», «1-3s va 2-2s — seriya rad etildi» (Westgard 1981 '
                          'manbali, lekin registrda imzo yo‘q); EQA yo‘riqnomasi matni'),
    '03_preanalitika': ('Subtitr: «Probirkalar tartibi (JSST 2010)»; ekranda bemor tayyorgarligi va probirka '
                        'jadvali (PREANALYTIC-SMEAR-EDTA — AWAITING_EXPERT)'),
    '04_kalkulyatorlar': ('Subtitr: «eGFR (CKD-EPI 2021)», «KDIGO toifasi»; natija va cheklovlar matni '
                          '(EGFR-CHRONICITY-WORDING, EGFR-CATEGORY-ROUNDING — AWAITING_EXPERT)'),
    '05_apparatlar': ('Yo‘nalish kartasi (VITEK 2) ekranda «Mutaxassis tekshirgan: hali yo‘q»; apparat sinfi '
                      'sxemasi (LABCARD-* — AWAITING_EXPERT)'),
    '06_mikroskopiya': ('Atlas rasmlari nomlari/kattalashtirish manba izohidan (masalan, «Kalsiy oksalat '
                        'kristallari · 1600X»), mashq javobi — mutaxassis tasdig‘i yo‘q'),
    '07_najas_parazitologiya': ('Ekranda koprogramma me’yorlari va boyitish usullari (Willis, formalin–efir) '
                                '— manbali, tasdiqlanmagan'),
    '08_bilim_baholash': ('Rasmiy ro‘yxat savollari, LabGuide tayyorlagan javob rejalari; bahsli kalitlar '
                          '(TOIFA-KEY-* — AWAITING_EXPERT)'),
    '09_testlar_natijalar': ('Subtitrlar faqat UI; lekin kadrlarda izohli test savollari, izoh va xatolar '
                             'tahlili (kontent paketi — mutaxassis tasdiqlamagan)'),
    '10_boshqa_funksiyalar': ('Bo‘lim sahifalari: JSST 2021 spermogramma chegaralari, ABO/RhD, leykoformula '
                              '(ANC-*, BLOODGROUP-RETENTION, URINE-SPECIFIC-GRAVITY — AWAITING_EXPERT)'),
    'gc_ms': ('Butun dars: GC-MS tamoyili (C1–C10, L1–L3, PR, RS); vakuum nasosi (9) NEEDS_EXPERT; '
              'LABCARD-A3-TOX-GC-MS — AWAITING_EXPERT; ekranda EXPERT_REVIEW_PENDING'),
    'real_time_pcr': ('Butun dars: optik yo‘l (manba → qo‘zg‘atish filtri → probirka → emissiya filtri → '
                      'detektor), Cq, ikki barobar ko‘payish; LABCARD-A1-REALTIME-PCR-METHOD — AWAITING_EXPERT; '
                      'sxema yangi tuzatilgan (9 belgi) — mutaxassis ko‘rmagan'),
}

# Ko‘zdan kechirilgan kadrlar (to‘liq o‘lcham 720×1280) bo‘yicha qayd va qolgan nuqsonlar.
OPEN_DEFECTS = {
    'real_time_pcr': ('6-bosqich «Natija» (59,5–73,5 s): qism chipi «7 Emission filter / Emissiya filtri», '
                      'kamera esa monitorni (9 — dasturiy ta’minot) ko‘rsatadi: sample_real_time_pcr.json '
                      'da focus [7] belgilar 9 taga qayta raqamlangandan keyin [9] ga o‘zgartirilmagan. '
                      'Namunani qayta render qilish kerak (build/lesson_samples — boshqa agent papkasi, '
                      'o‘zgartirilmadi)'),
}

NOTES = {
    '06_mikroskopiya': ('11–12 ta uchinchi tomon mikrofotosi (CC BY-SA 4.0/3.0, CC BY 4.0, CDC PHIL): yangi '
                        '«Rasmlar: mualliflar va litsenziyalar» kartochkasi (7 s) + _credits.txt (havolalar); '
                        'mashq savoli tasodifiy (tillarda har xil rasm)'),
    '10_boshqa_funksiyalar': ('5–6 ta gistologiya mikrofotosi (CC0 1.0, Berkshire CC) — mualliflar kartochkasi '
                              '+ _credits.txt (CC0 talab qilmaydi, lekin ko‘rsatildi)'),
    '01_kalibrlash': 'Tarix qatori lokallashtirilgan (c8fd248); analit id xom ko‘rinadi (Ma’lumot)',
    '08_bilim_baholash': 'ru/en: Profil → «O‘zbekiston» sozlamasi kadri bilan (haqiqiy sozlama)',
    'gc_ms': 'Yorliq: «Ovozsiz namuna (diktorsiz)» — ekran yozuvi emas, animatsiya (to‘g‘ri)',
    'real_time_pcr': ('en chipida ikkinchi qator ruscha nom (pleyer qoidasi: en → ru); yorliq «Ovozsiz namuna '
                      '(diktorsiz)»'),
}


def topic_of(r):
    return r['topic'] if r['kind'] == 'howto' else r['video'].rsplit('_', 1)[0]


def main():
    a = json.load(open(AUDIT, encoding='utf-8'))
    ocr = json.load(open(OCR_SAMPLES)) if os.path.exists(OCR_SAMPLES) else {}
    rows = []
    for key, r in a.items():
        p = r['probe']
        t = topic_of(r)
        fmt = (f"{p['container'].split(',')[0]}/{p['codec']} {p['pix_fmt']}, {p['w']}×{p['h']}, "
               f"{p['fps']:g} fps, {p['duration']:.1f} s, {p['bytes'] / 1e6:.2f} MB, audio={p['audio_streams']}")
        s = r['sharpness']
        if r['kind'] == 'howto':
            sharp = (f"PSNR min {min(c['psnr'] for c in s):.1f} dB (≥38 = siqish artefakti sezilmaydi), "
                     f"kadrlar ko‘rildi: {', '.join(c['at'] for c in s)}")
            ov = r['overflow']
            overflow = (f"0 toshish; subtitr {ov['captions']} ta, min {ov['min_font']} px, ≤{ov['max_lines']} qator; "
                        f"yorliq {ov['label_px']}/{ov['frame_w']} px")
            sims = [c['ocr_sim'] for c in s if 'ocr_sim' in c]
            sub = (f"SRT=VTT={'ha' if r['subs']['srt_eq_vtt'] else 'YO‘Q'}, storyboard bilan "
                   f"{'teng' if r['subs']['eq_storyboard'] else 'FARQ'}, {r['subs']['cues']} cue, oxiri−davomiylik "
                   f"{r['subs']['end_vs_duration']:+.3f} s; OCR {min(sims):.2f}–{max(sims):.2f} (kadrlar ko‘rildi)")
            rights = ('Inter (OFL), logo (egasi, D-37), ilova ekranlari (o‘z), sxema/kartalar (LabGuide)')
            if r['assets']['third_party']:
                lic = sorted({x[1] for x in r['assets']['third_party']})
                rights += (f"; {len(r['assets']['third_party'])} ta uchinchi tomon rasmi ({', '.join(lic)}) — "
                           f"mualliflar kartochkasi {'bor' if r['assets']['credits_card'] else 'YO‘Q'}, credits.txt "
                           f"{'bor' if r['assets']['credits_file'] else 'YO‘Q'}")
            else:
                rights += '; uchinchi tomon rasmi yo‘q'
            app = 'faqat mavjud ekranlar; video tugmasi yo‘q; Pro/to‘lov yo‘q; «Rasmiy emas» yo‘q'
            if t == '08_bilim_baholash' or t == '10_boshqa_funksiyalar':
                app += '; bo‘lim nomi «Bilim va malakani baholash» to‘g‘ri' if t == '08_bilim_baholash' else ''
            frames = 'kirish/yakun kartochkasi: halol yorliq bor, brend taqlidi yo‘q, da’vo yo‘q'
        else:
            sharp = (f"Laplasian min {min(c['lap'] for c in s):.0f} (keskin), kadrlar ko‘rildi: "
                     f"{', '.join(c['at'] for c in s)}")
            overflow = '0 toshish (kadrlar to‘liq o‘lchamda ko‘rildi)'
            sims = ocr.get(key, [])
            sub = (f"SRT=VTT={'ha' if r['subs']['srt_eq_vtt'] else 'YO‘Q'}, JSON subtitrlari SRT da "
                   f"{r['subs']['captions_in_srt']}/{r['subs']['captions_total']}, oxiri−davomiylik "
                   f"{r['subs']['end_vs_duration']:+.3f} s; OCR {min(sims):.2f}–{max(sims):.2f} "
                   f"(bosqich chiplari ham o‘qilgan; kadrlar ko‘rildi)" if sims else '')
            rights = 'Inter (OFL), logo (egasi), ilovaning ORIGINAL sxemasi (SCHEMATICS_PROVENANCE); uchinchi tomon rasmi yo‘q'
            app = 'ilova sxemasi asosida dars namunasi (ilova ekrani emas); Pro/to‘lov yo‘q'
            frames = 'kirish/yakun kartochkasi: «Sxematik animatsiya — aniq model emas», «Ovozsiz namuna», EXPERT_REVIEW_PENDING'
        terms = ('ARB bilan mos (qo‘shtirnoqdagi barcha UI nomlari ARB/lib da topildi); uz apostrof to‘g‘ri'
                 if not r['terms_missing'] and not r['uz_apostrophe_bad'] else
                 f"ARB da yo‘q: {r['terms_missing']}; apostrof: {r['uz_apostrophe_bad']}")
        if r['kind'] == 'sample':
            terms = ('uz apostrof to‘g‘ri; qism nomlari ilova ARB (schemParts*) dan; ru/en tarjima — '
                     'L10N_REVIEW_QUEUE bo‘yicha ko‘rilmagan' if not r['uz_apostrophe_bad'] else terms)
        open_defect = OPEN_DEFECTS.get(t)
        tech_issues = r['issues'] + ([open_defect] if open_defect else [])
        verdict = 'NEEDS_FIX' if tech_issues else ('NEEDS_EXPERT' if t in SCIENCE else 'PASS')
        fixed = []
        if t in ('06_mikroskopiya', '10_boshqa_funksiyalar'):
            fixed.append('mualliflar kartochkasi + credits.txt qo‘shildi, video qayta yig‘ildi')
        if r['kind'] == 'howto':
            fixed.append('kadrlar c8fd248/2e787e4 ilovasidan qayta render, OUTPUTS qayta yozildi')
        rows.append({
            'file': r['video'], 'format_duration_size': fmt, 'sharpness': sharp, 'overflow': overflow,
            'subtitle_sync': sub, 'terminology': terms, 'app_conformity': app,
            'science_status': 'NEEDS_EXPERT: ' + SCIENCE[t] if t in SCIENCE else 'ilmiy da’vo yo‘q',
            'open_close_frames': frames, 'rights_sources': rights, 'VERDICT': verdict,
            'notes': '; '.join(x for x in [open_defect and 'OCHIQ NUQSON: ' + open_defect, NOTES.get(t)] if x),
            'FIXED': '; '.join(fixed) if fixed else '—',
            'sha256': r['probe']['sha256'],
        })
    with open(CSV, 'w', encoding='utf-8', newline='') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    counts = {v: sum(1 for r in rows if r['VERDICT'] == v) for v in ('PASS', 'NEEDS_FIX', 'NEEDS_EXPERT')}
    table = ['| Fayl | Davomiylik · hajm | Aniqlik | Toshish | Subtitr | Verdikt | Izoh |', '|---|---|---|---|---|---|---|']
    for r, (key, a_r) in zip(rows, a.items()):
        p = a_r['probe']
        table.append(f"| `{r['file']}` | {p['duration']:.1f} s · {p['bytes'] / 1e6:.2f} MB | "
                     f"{r['sharpness'].split(',')[0]} | yo‘q | "
                     f"{'mos' if 'FARQ' not in r['subtitle_sync'] and 'YO‘Q' not in r['subtitle_sync'] else 'FARQ'} | "
                     f"**{r['VERDICT']}** | {r['notes'].replace('|', '/')[:160] or '—'} |")
    md = open(MD, encoding='utf-8').read()
    head = (f"**Natija: PASS — {counts['PASS']}, NEEDS_FIX — {counts['NEEDS_FIX']}, "
            f"NEEDS_EXPERT — {counts['NEEDS_EXPERT']} (jami {len(rows)}).**")
    a_i, b_i = md.index(BEGIN) + len(BEGIN), md.index(END)
    md = md[:a_i] + '\n' + head + '\n\n' + '\n'.join(table) + '\n' + md[b_i:]
    open(MD, 'w', encoding='utf-8').write(md)
    print(counts)


if __name__ == '__main__':
    main()
