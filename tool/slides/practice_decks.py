"""Amaliy mashg'ulot protokollari (kunga bog'lanmagan to'plam): texnika bo'yicha
PPTX taqdimotlar.

Nima uchun alohida: curriculum.json dagi M9 "Laborator tekshiruv usullarini
amaliyotda o'zlashtirish" kunlari (d091-d142 va h.k.) bir xil umumiy nomda; dastur
(KLD_ixtisoslashtirish_864) ham, dars jadvallari ham ularda kunma-kun aniq mavzu
yoki texnikani ko'rsatmaydi. Shuning uchun texnika taqdimotlari hech bir kunga
BIRIKTIRILMAYDI: "Amaliy mashg'ulot protokollari" nomli raqamsiz to'plam, har biri
texnika nomi bilan. Kun <-> mavzu moslik o'ylab topilmaydi.

Manba: tool/slides/data/books_extra_practice.json
  "books":     pack.json'da yo'q kitoblar (qisqa va to'liq bibliografiya)
  "protocols": [{id, group, title, slides:[{type, label, title, bullets|table|images, refs}]}]
Matn kitoblardan o'z so'zim bilan; har kontent slaydda muallif + qisqa nom + bo'lim/sahifa,
oxirgi slayd - "Adabiyotlar". Kontent bo'lmasa slayd yo'q.

Render: make_practice_decks.py (make_topic_decks.render_deck).
"""
import dataclasses

import deck_content as dc

LANGS = dc.LANGS

SET_TITLE = {'uz': 'Amaliy mashg‘ulot protokollari',
             'ru': 'Протоколы практических занятий',
             'en': 'Practical-session protocols'}
EYEBROW = {'uz': 'Amaliy mashg‘ulot protokoli', 'ru': 'Протокол практического занятия',
           'en': 'Practical-session protocol'}
OUTLINE = {'uz': 'Protokol rejasi', 'ru': 'План протокола', 'en': 'Protocol outline'}

LABELS = {
    'purpose': {'uz': 'Maqsad', 'ru': 'Цель', 'en': 'Purpose'},
    'principle': {'uz': 'Usul tamoyili', 'ru': 'Принцип метода', 'en': 'Principle'},
    'sampling': {'uz': 'Namuna olish', 'ru': 'Взятие материала', 'en': 'Specimen collection'},
    'materials': {'uz': 'Materiallar va reagentlar', 'ru': 'Материалы и реактивы',
                  'en': 'Materials and reagents'},
    'procedure': {'uz': 'Bajarish tartibi', 'ru': 'Порядок выполнения', 'en': 'Procedure'},
    'reading': {'uz': 'Natijani o‘qish va hisoblash', 'ru': 'Учёт и расчёт результата',
                'en': 'Reading and calculation'},
    'errors': {'uz': 'Xatolik manbalari', 'ru': 'Источники ошибок', 'en': 'Sources of error'},
    'qc': {'uz': 'Sifat nazorati', 'ru': 'Контроль качества', 'en': 'Quality control'},
    'safety': {'uz': 'Xavfsizlik', 'ru': 'Безопасность', 'en': 'Safety'},
    'avoid': {'uz': 'Tavsiya etilmaydi', 'ru': 'Не рекомендуется', 'en': 'Not recommended'},
    'atlas': {'uz': 'Mikroskopik atlas', 'ru': 'Микроскопический атлас', 'en': 'Microscopy atlas'},
    # Reaktiv tayyorlash va test dasturi (yarim avtomat analizator); har bunday slaydda "excerpts" —
    # data/analyzer_source_excerpts.json dagi manba parchalari (test_analyzer_protocols.py).
    'analyzer': {'uz': 'Yarim avtomat analizator', 'ru': 'Полуавтоматический анализатор',
                 'en': 'Semi-automatic analyser'},
}

MAX_BULLETS = 6


@dataclasses.dataclass
class PracticeDay:
    """Deck.day o'rnini bosuvchi yengil obyekt (kunga bog'lanmagan)."""
    id: str
    protocol: dict

    def title(self, lang):
        return dc.L(self.protocol['title'], lang)


def protocols(repo):
    return repo.practice.get('protocols', [])


def find(repo, pid):
    for p in protocols(repo):
        if p['id'] == pid:
            return p
    raise KeyError(pid)


def _refs(src, refs, lang):
    out = []
    for r in refs:
        loc = dc.L(r.get('loc'), lang) if r.get('loc') else ''
        if 'pack' in r:
            out.append(src.pack(r['pack'], loc))
        else:
            out.append(src.book(r['book'], loc))
    return dc.dedupe(out)


def _slides(repo, src, proto, lang):
    out = []
    for sl in proto['slides']:
        eyebrow = LABELS[sl['label']][lang] if sl.get('label') else ''
        title = dc.L(sl['title'], lang)
        kind = sl['type']
        if kind == 'text':
            blocks = [{'label': None, 'text': x} for x in sl['bullets'][lang]]
            numbered = bool(sl.get('numbered'))
            out.append(dc.Slide('text', title=title, eyebrow=eyebrow,
                                data={'blocks': blocks, 'chips': [], 'bullets': not numbered,
                                      'numbered': numbered, 'warn': bool(sl.get('warn'))},
                                sources=_refs(src, sl['refs'], lang)))
        elif kind == 'table':
            out.append(dc.Slide('table', title=title, eyebrow=eyebrow,
                                data={'header': sl['header'][lang], 'rows': sl['rows'][lang],
                                      'widths': sl['widths']},
                                sources=_refs(src, sl['refs'], lang)))
        elif kind == 'gallery':
            imgs = [next(i for i in repo.atlas['images'] if i['id'] == x) for x in sl['images']]
            for k in range(0, len(imgs), 2):
                pair = imgs[k:k + 2]
                items = []
                for i in pair:
                    cap = i['caption']['tr'].get(lang) or i['caption']['text']
                    items.append({'image': i['asset'], 'caption': cap,
                                  'credit': f'{dc.T("photo", lang)}: {i["author"]}, {i["license"]} · '
                                            f'{dc.provider_name(i["provider"])}'})
                out.append(dc.Slide('gallery', title=title, eyebrow=eyebrow or LABELS['atlas'][lang],
                                    data={'items': items},
                                    sources=[src.atlas(i) for i in pair]))
        else:
            raise ValueError(f'{proto["id"]}: noma’lum slayd turi {kind}')
    return out


def build_practice_deck(repo, proto, lang):
    """Texnika protokoli uchun deck; (Deck, coverage)."""
    src = dc.Sources(repo)
    body = _slides(repo, src, proto, lang)
    cov = {'slides': 0, 'content_slides': len(body), 'sources': 0}
    if not body:
        return None, cov
    titles = []
    for s in body:
        if s.title not in titles:
            titles.append(s.title)
    slides = [dc.Slide('title', title=dc.L(proto['title'], lang), eyebrow=EYEBROW[lang],
                       data={'lines': [dc.L(proto['group'], lang)], 'module': SET_TITLE[lang]})]
    slides.append(dc.Slide('outline', title=OUTLINE[lang], data={'items': titles}))
    slides += body
    slides.append(dc.Slide('sources', title=dc.T('sources', lang),
                           data={'items': [src.bib(k) for k in src.entries]}))
    cov['slides'] = len(slides)
    cov['sources'] = len(src.entries)
    deck = dc.Deck(PracticeDay(proto['id'], proto), lang, slides, src, cov)
    return deck, cov


# ------------------------------------------------------------ tekshiruv ----

def validate(repo):
    """Ma'lumot to'liqligi: xatolar ro'yxati (bo'sh = hammasi joyida)."""
    errs = []
    atlas_ids = {i['id'] for i in repo.atlas['images']}
    seen = set()
    for p in protocols(repo):
        pid = p['id']
        if pid in seen:
            errs.append(f'{pid}: takror id')
        seen.add(pid)
        for lg in LANGS:
            if not dc.L(p['title'], lg).strip() or not dc.L(p['group'], lg).strip():
                errs.append(f'{pid}/{lg}: sarlavha yoki guruh bo‘sh')
        if not p['slides']:
            errs.append(f'{pid}: slayd yo‘q')
        for n, sl in enumerate(p['slides'], 1):
            where = f'{pid}#{n}'
            if sl.get('label') not in LABELS:
                errs.append(f'{where}: noma’lum yorliq {sl.get("label")}')
            for lg in LANGS:
                if not dc.L(sl['title'], lg).strip():
                    errs.append(f'{where}/{lg}: sarlavha yo‘q')
            if sl['type'] == 'gallery':
                for x in sl['images']:
                    if x not in atlas_ids:
                        errs.append(f'{where}: atlasda rasm yo‘q: {x}')
                continue
            if not sl.get('refs'):
                errs.append(f'{where}: manba yo‘q')
            for r in sl.get('refs', []):
                if 'pack' in r:
                    if r['pack'] not in repo.src or repo.src[r['pack']]['kind'] != 'book':
                        errs.append(f'{where}: pack kitobi yo‘q: {r["pack"]}')
                elif r.get('book') not in repo.books['books']:
                    errs.append(f'{where}: kitob yo‘q: {r.get("book")}')
                for lg in LANGS:
                    if not r.get('loc') or not dc.L(r['loc'], lg).strip():
                        errs.append(f'{where}/{lg}: bo‘lim/sahifa ko‘rsatilmagan')
            if sl['type'] == 'text':
                counts = set()
                for lg in LANGS:
                    b = sl['bullets'].get(lg)
                    if not b or any(not x.strip() for x in b):
                        errs.append(f'{where}/{lg}: band bo‘sh')
                        continue
                    counts.add(len(b))
                    if len(b) > MAX_BULLETS:
                        errs.append(f'{where}/{lg}: {len(b)} band (>{MAX_BULLETS})')
                if len(counts) > 1:
                    errs.append(f'{where}: tillarda band soni har xil {sorted(counts)}')
            elif sl['type'] == 'table':
                for lg in LANGS:
                    h, rows = sl['header'].get(lg), sl['rows'].get(lg)
                    if not h or not rows:
                        errs.append(f'{where}/{lg}: jadval bo‘sh')
                        continue
                    if any(len(r) != len(h) for r in rows):
                        errs.append(f'{where}/{lg}: jadval ustunlari mos emas')
                if len(sl['widths']) != len(sl['header']['uz']):
                    errs.append(f'{where}: widths soni ustunlarga mos emas')
    for bid, b in repo.practice.get('books', {}).items():
        if not b.get('short') or not b.get('full'):
            errs.append(f'books/{bid}: short/full yo‘q')
    return errs


# ------------------------------------------------------------- hisobot -----

def report_section(repo):
    """docs/DECKS_COVERAGE.md uchun "Amaliy mashg'ulot protokollari" bo'limi (Markdown qatorlari)."""
    ps = protocols(repo)
    if not ps:
        return []
    md = ['', '## Amaliy mashg‘ulot protokollari (kunga bog‘lanmagan to‘plam)', '',
          'M9 modulining amaliy kunlari (`d091`–`d142`, jumladan yuqoridagi “Deck yo‘q” ro‘yxatidagilar) '
          'curriculumda bir xil umumiy nom bilan turadi. Dastur hujjati (`КЛД_ихтисослаштириш_864_кредит`: '
          'M9 — 324 soat, shundan ma’ruza 48, laboratoriya ishi 276 (`curriculum.json`da M9 — 330 soat: '
          'ma’ruza 48, amaliy 270, attestatsiya 6, qo‘shimcha 6); mavzu yoki texnika ro‘yxati yo‘q, '
          'faqat umumiy kompetensiyalar va jihozlar ro‘yxati) hamda dars jadvallari (Karimova, Turg‘unova '
          'T1/T2) bu kunlarda **kunma-kun mavzu yoki texnikani ko‘rsatmaydi**: aniq mavzu faqat '
          'ma’ruza kunlarida (d090, d095, d101, d106, d112, d116, d121, d127 — ular allaqachon alohida '
          'deck), qolganlari “Laborator tekshiruv usullarini amaliyotda o‘zlashtirish”. Shu sababli '
          'texnika taqdimotlari **hech bir kunga biriktirilmagan**: nomi texnikaga qarab berilgan raqamsiz '
          'to‘plam. Kun ↔ texnika moslik manbalarda yo‘q, shuning uchun o‘ylab topilmadi '
          '(ma’ruza kunlari oralig‘idagi kunlar o‘sha ma’ruza mavzusiga tegishli degan taxmin ham '
          'hujjatlarda tasdiqlanmagan — ishlatilmadi).', '',
          'Qoidalar: matn kitoblardan o‘z so‘zim bilan; har slaydda muallif + qisqa nom + bo‘lim/sahifa; '
          'oxirgi slayd — “Adabiyotlar”. Son, hajm, vaqt va konsentratsiya faqat manbada ko‘ringan joyda '
          '(sahifasi bilan); manbalar bir-biriga zid bo‘lsa — yangi/ishonchlisi yoki umuman olinmagan; '
          'eskirgan/xavfli usullar olinmagan. Faqat mavjud rasmlar (`assets/microscopy`) ishlatilgan '
          '(atlasda najas va balg‘am fotolari yo‘q — o‘sha protokollarda rasm slaydi yo‘q). “Qin tozalik '
          'darajalari” jadvali yuqoridagi sitologiya mavzu decklarida manbasi yo‘qligi uchun yo‘q; u faqat shu '
          'to‘plamdagi urogenital protokolda, Kurbonova (2023, 70-b.) manbasi bilan berilgan.', '',
          '| Texnika (uz) | Guruh | Slayd (uz) | Manbalar |', '|---|---|---|---|']
    for p in ps:
        deck, cov = build_practice_deck(repo, p, 'uz')
        md.append(f'| {dc.L(p["title"], "uz")} | {dc.L(p["group"], "uz")} | {cov["slides"]} | '
                  f'{cov["sources"]} |')
    md.append('')
    notes = repo.practice.get('skipped')
    if notes:
        md += ['### Manbalarda bor, lekin olinmagan', '']
        for n in notes:
            md.append(f'- {dc.L(n, "uz")}')
        md.append('')
    return md
