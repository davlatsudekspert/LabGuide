"""Ustoz kalendar-rejasidan (curriculum.json) ilova asset'ini yasash.

Faqat o'quv tuzilmasi qoladi: kurator ismlari, klinika/baza nomlari, guruhga
xos sanalar va ichki izohlar olib tashlanadi (D-42). Sana ilovada ustoz
belgilagan boshlanish kunidan hisoblanadi.

  python3 -I tool/curriculum/sanitize.py <manba.json> assets/curriculum/curriculum.json
"""
import json
import sys

TOPIC_KEYS = ('id', 'n', 'title_uz', 'title_ru', 'title_en', 'type', 'hours',
              'week', 'links', 'goals', 'key_points', 'oral_candidates',
              'test_candidates', 'test_gap', 'oral_gap')


def main(src, dst):
    d = json.load(open(src, encoding='utf-8'))
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
            'hours': m.get('hours'),
            'topics': [
                {k: t[k] for k in TOPIC_KEYS if t.get(k) is not None}
                for t in m['topics']
            ],
        })
    json.dump(out, open(dst, 'w', encoding='utf-8'), ensure_ascii=False,
              indent=1)


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
