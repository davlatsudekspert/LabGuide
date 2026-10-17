#!/usr/bin/env python3
"""Amaliy mashg'ulot protokollari to'plamini PPTX qiladi (kunga bog'lanmagan).

Ma'lumot: tool/slides/data/books_extra_practice.json (practice_decks.py).
Render: make_topic_decks.render_deck (16:9, bir xil dizayn). PPTX'lar repoga qo'shilmaydi.

  python3 tool/slides/make_practice_decks.py --lang all --out /tmp/practice_decks
  python3 tool/slides/make_practice_decks.py --id kapillyar-qon-olish --lang uz --out /tmp/x
  python3 tool/slides/make_practice_decks.py --dry-run
  python3 tool/slides/make_practice_decks.py --lang all --out /tmp/p --zip /tmp/protokollar.zip
"""
import argparse
import os
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import deck_content as dc  # noqa: E402
import practice_decks as pd  # noqa: E402

README = {
    'uz': ['LabGuide — Amaliy mashg‘ulot protokollari (16:9, televizor uchun)', '',
           'Bu to‘plam o‘quv kunlariga BIRIKTIRILMAGAN: M9 amaliy kunlari uchun dastur va dars jadvallarida',
           'kunma-kun aniq mavzu ko‘rsatilmagan, shuning uchun taqdimotlar texnika nomi bilan beriladi.', '',
           'Tuzilishi: sarlavha → protokol rejasi → mazmun slaydlari (maqsad, materiallar, bajarish tartibi,',
           'natijani hisoblash, xatolik manbalari, sifat nazorati, xavfsizlik — manbada bor bo‘lsa) → "Adabiyotlar".',
           'Har mazmun slaydida pastda qisqa manba qatori (muallif, qisqa nom, bo‘lim/sahifa); to‘liq ro‘yxat —',
           'oxirgi "Adabiyotlar" slaydida. Matn kitoblardan o‘z so‘zim bilan; son, hajm, vaqt va konsentratsiya',
           'faqat manbada ko‘ringan joyda. Slaydlar tahrirlanadi (PowerPoint/LibreOffice). Shrift: Inter.'],
    'ru': ['LabGuide — Протоколы практических занятий (16:9, для телевизора)', '',
           'Набор НЕ привязан к учебным дням: в программе и расписаниях нет конкретной темы по дням практики М9,',
           'поэтому презентации названы по методике.', '',
           'Структура: титул → план протокола → содержательные слайды (цель, материалы, порядок выполнения,',
           'расчёт, источники ошибок, контроль качества, безопасность — если есть в источнике) → «Литература».',
           'На каждом слайде внизу краткая ссылка (автор, краткое название, раздел/страница). Текст пересказан',
           'своими словами; числа, объёмы, время и концентрации приведены только там, где они видны в источнике.'],
    'en': ['LabGuide — Practical-session protocols (16:9, for TV)', '',
           'This set is NOT tied to course days: the programme and the timetables give no day-specific topic for the',
           'module 9 practice days, so the decks are named by technique.', '',
           'Structure: title → protocol outline → content slides (purpose, materials, procedure, calculation,',
           'sources of error, quality control, safety — where the source supports it) → "References".',
           'Every slide carries a short source line (author, short title, section/page). Text is paraphrased;',
           'numbers, volumes, times and concentrations appear only where they are visible in the source.'],
}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--id', action='append', default=[], help='protokol id (takrorlash mumkin); bo‘lmasa — hammasi')
    ap.add_argument('--lang', default='uz', help='uz,ru,en yoki all')
    ap.add_argument('--out', default='practice_out')
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--zip', help='yaratilgan decklarni (hamma tillar, til papkalari bilan) zip + README qilish')
    a = ap.parse_args(argv)
    langs = list(dc.LANGS) if a.lang == 'all' else [x.strip() for x in a.lang.split(',')]
    for lg in langs:
        if lg not in dc.LANGS:
            ap.error(f'noma’lum til: {lg}')
    repo = dc.Repo()
    errs = pd.validate(repo)
    if errs:
        raise SystemExit('books_extra_practice.json xatolari:\n  ' + '\n  '.join(errs))
    ps = [pd.find(repo, i) for i in a.id] if a.id else pd.protocols(repo)
    made = []
    for p in ps:
        for lg in langs:
            deck, cov = pd.build_practice_deck(repo, p, lg)
            if a.dry_run:
                if lg == langs[0]:
                    print(f'{p["id"]:<34} ~{cov["slides"]:>3} slayd  manba {cov["sources"]}  '
                          f'{dc.L(p["title"], "uz")}')
                continue
            import make_topic_decks as mk
            fn = os.path.join(a.out, lg, f'amaliy-protokol_{p["id"]}.pptx')
            n = mk.render_deck(deck, fn)
            made.append((lg, p, fn, n, deck))
            print(f'{fn}  ({n} slayd)')
    if not a.dry_run:
        import make_topic_decks as mk
        if mk.WARNINGS:
            print('OGOHLANTIRISHLAR (joylashtirish):', *mk.WARNINGS, sep='\n  ')
    if a.zip and made:
        with zipfile.ZipFile(a.zip, 'w', zipfile.ZIP_DEFLATED) as z:
            for lg, p, fn, n, deck in made:
                z.write(fn, f'{lg}/{os.path.basename(fn)}')
            lines = []
            for lg in langs:
                lines += README[lg] + ['']
            lines += ['Fayl | Texnika (uz) | Guruh | Slayd (uz) | Manbalar', '--- | --- | --- | --- | ---']
            first = langs[0]
            for lg, p, fn, n, deck in made:
                if lg == first:
                    lines.append(f'{os.path.basename(fn)} | {dc.L(p["title"], "uz")} | '
                                 f'{dc.L(p["group"], "uz")} | {n} | {len(deck.sources.entries)}')
            z.writestr('README.txt', '\n'.join(lines) + '\n')
        print('zip:', a.zip)


if __name__ == '__main__':
    main()
