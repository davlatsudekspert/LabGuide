"""Ustoz kalendar-rejasidan (curriculum.json) ilova asset'ini yasash.

Faqat o'quv tuzilmasi qoladi: kurator ismlari, klinika/baza nomlari, guruhga
xos sanalar va ichki izohlar olib tashlanadi (D-42). Sana ilovada ustoz
belgilagan boshlanish kunidan hisoblanadi.

  python3 -I tool/curriculum/sanitize.py <manba.json> assets/curriculum/curriculum.json \\
      --translations tool/curriculum/translations.json

Tarjimalar ({modul_yoki_mavzu_id: {ru, en}}) alohida manba faylda saqlanadi
va title_ru/title_en sifatida qo'shiladi. Har modul/mavzu uchun ikkala til
majburiy (yetishmasa — xato).
"""
import json
import sys

LANGS = ('ru', 'en')

TOPIC_KEYS = ('id', 'n', 'title_uz', 'title_ru', 'title_en', 'type', 'hours',
              'week', 'links', 'goals', 'key_points', 'oral_candidates',
              'test_candidates', 'test_gap', 'oral_gap')


def _tr(tr, i):
    e = tr.get(i)
    if e is None:
        return {}
    for lang in LANGS:
        if not str(e.get(lang, '')).strip():
            raise SystemExit(f'translations: {i}.{lang} bo\'sh')
    return {f'title_{lang}': e[lang].strip() for lang in LANGS}


def main(src, dst, translations=None):
    d = json.load(open(src, encoding='utf-8'))
    tr = {}
    if translations:
        tr = json.load(open(translations, encoding='utf-8'))
        ids = {m['id'] for m in d['modules']}
        ids |= {t['id'] for m in d['modules'] for t in m['topics']}
        missing = sorted(ids - tr.keys())
        if missing:
            raise SystemExit(f'translations: tarjimasiz id: {missing}')
        extra = sorted(tr.keys() - ids)
        if extra:
            raise SystemExit(f'translations: ortiqcha id: {extra}')
    p = d['program']
    out = {
        'program': {
            'name': p['name'],
            'credits': p.get('credits'),
            'duration_months': 6,
            'days': p.get('days'),
        },
        'modules': [],
    }
    for m in d['modules']:
        out['modules'].append({
            'id': m['id'],
            'title_uz': m['title_uz'],
            **_tr(tr, m['id']),
            'hours': m.get('hours'),
            'topics': [
                {
                    **{k: t[k] for k in TOPIC_KEYS if t.get(k) is not None},
                    **_tr(tr, t['id']),
                }
                for t in m['topics']
            ],
        })
    json.dump(out, open(dst, 'w', encoding='utf-8'), ensure_ascii=False,
              indent=1)


if __name__ == '__main__':
    args = sys.argv[1:]
    tfile = None
    if '--translations' in args:
        k = args.index('--translations')
        tfile = args[k + 1]
        del args[k:k + 2]
    main(args[0], args[1], tfile)
