"""Mavzu taqdimotlari mazmuni (PPTX'siz): ilovadagi tekshirilgan kontentdan
slaydlar ro'yxatini yig'adi. Hech narsa o'ylab topilmaydi — kontent bo'lmasa
slayd yo'q.

Manbalar:
  assets/curriculum/curriculum.json   - mavzu -> havolalar
  assets/content/core/pack.json       - analit/holat kartalari, mashq savollari
  assets/microscopy/atlas.json        - mikroskopiya fotolari (litsenziya bilan)
  assets/toifa/kdl_*.json             - toifa test va og'zaki banki
  tool/slides/data/app_content.json   - Dart'dan ko'chirilgan leykoformula,
                                        sitologiya, "Jadvallar" (extract_dart_content.py)
  tool/slides/data/books_extra.json   - (ixtiyoriy) ustoz kitoblaridan o'z
                                        so'zim bilan qisqa mazmun, sahifa/bo'lim bilan

Render: make_topic_decks.py.
"""
import collections
import dataclasses
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
LANGS = ('uz', 'ru', 'en')

# ---------------------------------------------------------------- matnlar --

UI = {
    'module_topic': {
        'uz': '{m}-modul · {n}-mavzu', 'ru': 'Модуль {m} · Тема {n}',
        'en': 'Module {m} · Topic {n}'},
    'h_practical': {
        'uz': 'Amaliy mashg‘ulot — {h} soat', 'ru': 'Практическое занятие — {h} ч',
        'en': 'Practical session — {h} h'},
    'h_lecture': {
        'uz': 'Ma’ruza — {h} soat', 'ru': 'Лекция — {h} ч', 'en': 'Lecture — {h} h'},
    'h_attestation': {
        'uz': 'Attestatsiya — {h} soat', 'ru': 'Аттестация — {h} ч',
        'en': 'Assessment — {h} h'},
    'outline': {'uz': 'Dars rejasi', 'ru': 'План занятия', 'en': 'Lesson outline'},
    'purpose': {'uz': 'Nima uchun tekshiriladi', 'ru': 'Для чего назначают',
                'en': 'What it is used for'},
    'physiology': {'uz': 'Fiziologiya', 'ru': 'Физиология', 'en': 'Physiology'},
    'limits': {'uz': 'Me’yor va qaror chegaralari',
               'ru': 'Референсные значения и пороги принятия решений',
               'en': 'Reference values and decision limits'},
    'results': {'uz': 'Natija talqini', 'ru': 'Интерпретация результата',
                'en': 'Interpreting the result'},
    'high': {'uz': 'Oshishi', 'ru': 'Повышение', 'en': 'High'},
    'low': {'uz': 'Pasayishi', 'ru': 'Снижение', 'en': 'Low'},
    'positive': {'uz': 'Musbat natija', 'ru': 'Положительный результат',
                 'en': 'Positive result'},
    'negative': {'uz': 'Manfiy natija', 'ru': 'Отрицательный результат',
                 'en': 'Negative result'},
    'preanalytics': {'uz': 'Preanalitika va halaqit beruvchilar',
                     'ru': 'Преаналитика и влияющие факторы',
                     'en': 'Pre-analytics and interferences'},
    'p_pre': {'uz': 'Preanalitika', 'ru': 'Преаналитика', 'en': 'Pre-analytics'},
    'p_interf': {'uz': 'Halaqit beruvchilar', 'ru': 'Влияющие факторы',
                 'en': 'Interferences'},
    'limitations': {'uz': 'Cheklovlar', 'ru': 'Ограничения', 'en': 'Limitations'},
    'specimen': {'uz': 'Namuna', 'ru': 'Образец', 'en': 'Specimen'},
    'units': {'uz': 'Birliklar', 'ru': 'Единицы', 'en': 'Units'},
    'population': {'uz': 'Kim uchun', 'ru': 'Для кого', 'en': 'Population'},
    'related': {'uz': 'Bog‘liq tahlillar', 'ru': 'Связанные исследования',
                'en': 'Related tests'},
    'th_indicator': {'uz': 'Ko‘rsatkich', 'ru': 'Показатель', 'en': 'Indicator'},
    'th_value': {'uz': 'Qiymat', 'ru': 'Значение', 'en': 'Value'},
    'th_who': {'uz': 'Kimlar uchun / izoh', 'ru': 'Для кого / примечание',
               'en': 'Population / note'},
    'th_tier': {'uz': 'Daraja', 'ru': 'Приоритет', 'en': 'Priority'},
    'th_goal': {'uz': 'Maqsad', 'ru': 'Цель', 'en': 'Target'},
    'obsolete': {'uz': 'qo‘llanma eskirgan', 'ru': 'рекомендация устарела',
                 'en': 'guideline superseded'},
    'cond_summary': {'uz': 'Qisqacha', 'ru': 'Кратко', 'en': 'Overview'},
    'cond_panel': {'uz': 'Tavsiya etiladigan tahlillar',
                   'ru': 'Рекомендуемые исследования', 'en': 'Tests to consider'},
    'tier_first_line': {'uz': 'Birinchi navbatda', 'ru': 'В первую очередь',
                        'en': 'First line'},
    'tier_additional': {'uz': 'Qo‘shimcha', 'ru': 'Дополнительно',
                        'en': 'Additional'},
    'tier_monitoring': {'uz': 'Kuzatuv', 'ru': 'Наблюдение', 'en': 'Monitoring'},
    'cond_patterns': {'uz': 'Natija naqshlari', 'ru': 'Типичные сочетания результатов',
                      'en': 'Result patterns'},
    'th_finding': {'uz': 'Topilma', 'ru': 'Находка', 'en': 'Finding'},
    'th_meaning': {'uz': 'Ma’nosi', 'ru': 'Значение', 'en': 'Meaning'},
    'cond_cautions': {'uz': 'Ehtiyot bo‘ling', 'ru': 'Важные оговорки',
                      'en': 'Cautions'},
    'cond_label': {'uz': 'Holat', 'ru': 'Состояние', 'en': 'Condition'},
    'ref_label': {'uz': 'Jadvallar va algoritmlar',
                  'ru': 'Таблицы и алгоритмы', 'en': 'Tables and algorithms'},
    'cell_label': {'uz': 'Leykoformula · hujayralar', 'ru': 'Лейкоформула · клетки',
                   'en': 'Differential · cells'},
    'cell_pair': {'uz': 'Leykoformula · adashtiriladigan juftlik',
                  'ru': 'Лейкоформула · похожие клетки',
                  'en': 'Differential · look-alike pair'},
    'cell_find': {'uz': 'Leykoformula · talqin', 'ru': 'Лейкоформула · интерпретация',
                  'en': 'Differential · interpretation'},
    'cell_tech': {'uz': 'Surtma texnikasi', 'ru': 'Техника мазка', 'en': 'Blood film technique'},
    'cell_ranges': {'uz': 'Leykoformula: manbalardagi misol oraliqlari (%)',
                    'ru': 'Лейкоформула: примеры диапазонов из источников (%)',
                    'en': 'Differential: example ranges in sources (%)'},
    'th_cell': {'uz': 'Hujayra', 'ru': 'Клетка', 'en': 'Cell'},
    'th_classic': {'uz': 'Klassik darslik', 'ru': 'Классический учебник',
                   'en': 'Classic textbook'},
    'f_size': {'uz': 'O‘lcham', 'ru': 'Размер', 'en': 'Size'},
    'f_nucleus': {'uz': 'Yadro', 'ru': 'Ядро', 'en': 'Nucleus'},
    'f_cytoplasm': {'uz': 'Sitoplazma', 'ru': 'Цитоплазма', 'en': 'Cytoplasm'},
    'f_granules': {'uz': 'Donachalar', 'ru': 'Гранулы', 'en': 'Granules'},
    'f_key': {'uz': 'Asosiy belgi', 'ru': 'Ключевой признак', 'en': 'Key feature'},
    'f_seen': {'uz': 'Qachon uchraydi', 'ru': 'Когда встречается', 'en': 'Seen in'},
    'f_look': {'uz': 'Qanday ko‘rinadi', 'ru': 'Как выглядит', 'en': 'What it looks like'},
    'f_meaning': {'uz': 'Nimani anglatadi', 'ru': 'Что означает', 'en': 'What it means'},
    'f_confuse': {'uz': 'Nima bilan adashtiriladi', 'ru': 'С чем путают',
                  'en': 'Confused with'},
    'f_method': {'uz': 'Bo‘yoq / preparat', 'ru': 'Окраска / препарат', 'en': 'Stain / preparation'},
    'f_caveat': {'uz': 'Cheklov', 'ru': 'Ограничение', 'en': 'Caveat'},
    'schematic': {'uz': 'Sxema (mikrofoto emas)', 'ru': 'Схема (не микрофотография)',
                  'en': 'Schematic (not a photomicrograph)'},
    'refer': {'uz': 'Shifokorga / gematologga ko‘rsating',
              'ru': 'Покажите врачу / гематологу',
              'en': 'Refer to a physician / haematologist'},
    'tip': {'uz': 'Maslahat', 'ru': 'Подсказка', 'en': 'Tip'},
    'cyto_general': {'uz': 'Sitologiya', 'ru': 'Цитология', 'en': 'Cytology'},
    'cyto_label': {'uz': 'Sitologiya · hujayralar', 'ru': 'Цитология · клетки',
                   'en': 'Cytology · cells'},
    'cyto_degrees': {'uz': 'Qin surtmasi tozalik darajalari',
                     'ru': 'Степени чистоты влагалищного мазка',
                     'en': 'Vaginal smear cleanliness grades'},
    'th_grade': {'uz': 'Daraja', 'ru': 'Степень', 'en': 'Grade'},
    'th_picture': {'uz': 'Surtmada ko‘rinishi', 'ru': 'Картина в мазке', 'en': 'Smear picture'},
    'bethesda': {'uz': 'Bethesda tizimi (2014)', 'ru': 'Система Бетесда (2014)',
                 'en': 'The Bethesda System (2014)'},
    'th_code': {'uz': 'Kod', 'ru': 'Код', 'en': 'Code'},
    'th_name': {'uz': 'Nomi', 'ru': 'Название', 'en': 'Name'},
    'cyto_tech': {'uz': 'Sitologik surtma olish va bo‘yash',
                  'ru': 'Взятие и окраска цитологического мазка',
                  'en': 'Taking and staining the cytology smear'},
    'atlas': {'uz': 'Mikroskopik atlas', 'ru': 'Микроскопический атлас',
              'en': 'Microscopy atlas'},
    'photo': {'uz': 'Foto', 'ru': 'Фото', 'en': 'Photo'},
    'question': {'uz': 'Savol', 'ru': 'Вопрос', 'en': 'Question'},
    'answer': {'uz': 'Javob', 'ru': 'Ответ', 'en': 'Answer'},
    'explanation': {'uz': 'Tushuntirish', 'ru': 'Пояснение', 'en': 'Explanation'},
    'basis': {'uz': 'Asos', 'ru': 'Обоснование', 'en': 'Basis'},
    'oral_q': {'uz': 'Og‘zaki savol', 'ru': 'Устный вопрос', 'en': 'Oral question'},
    'oral_a': {'uz': 'Javob rejasi', 'ru': 'План ответа', 'en': 'Answer outline'},
    'qa_label': {'uz': 'Mashq · savol-javob', 'ru': 'Практика · вопросы и ответы',
                 'en': 'Practice · Q&A'},
    'bank_test': {'uz': 'Toifa imtihoni test banki, №{n}',
                  'ru': 'Банк тестов квалификационного экзамена, №{n}',
                  'en': 'Qualification-exam test bank, no. {n}'},
    'bank_oral': {'uz': 'Toifa imtihoni og‘zaki savollar banki',
                  'ru': 'Банк устных вопросов квалификационного экзамена',
                  'en': 'Qualification-exam oral question bank'},
    'sources': {'uz': 'Adabiyotlar', 'ru': 'Литература', 'en': 'References'},
    'source_prefix': {'uz': 'Manba', 'ru': 'Источник', 'en': 'Source'},
    'more_sources': {'uz': 'va yana {n} ta — oxirgi slaydda',
                     'ru': 'и ещё {n} — на последнем слайде',
                     'en': 'and {n} more — see the last slide'},
    'book_extra': {'uz': 'Darslik bo‘yicha qisqa mazmun',
                   'ru': 'Краткое содержание по учебнику',
                   'en': 'Short summary from the textbook'},
}


def T(key, lang, **kw):
    s = UI[key].get(lang) or UI[key]['uz']
    return s.format(**kw) if kw else s


def L(d, lang, default=''):
    """Ko'p tilli {'uz','ru','en'} dan matn (bo'lmasa uz)."""
    if d is None:
        return default
    if isinstance(d, str):
        return d
    return d.get(lang) or d.get('uz') or default


def num(x, lang):
    if isinstance(x, float) and x.is_integer():
        x = int(x)
    s = str(x)
    return s.replace('.', ',') if lang != 'en' else s


# ----------------------------------------------------------------- yuklash --

def _load(rel):
    with open(os.path.join(REPO, rel), encoding='utf-8') as f:
        return json.load(f)


class Repo:
    def __init__(self):
        self.pack = _load('assets/content/core/pack.json')
        self.cur = _load('assets/curriculum/curriculum.json')
        self.atlas = _load('assets/microscopy/atlas.json')
        self.oral = {q['id']: q for q in _load('assets/toifa/kdl_oral.json')['questions']}
        self.tests = {q['id']: q for q in _load('assets/toifa/kdl_tests.json')['questions']}
        self.app = _load('tool/slides/data/app_content.json')
        p = os.path.join(HERE, 'data', 'books_extra.json')
        self.books = {'books': {}, 'topics': {}}
        if os.path.exists(p):
            with open(p, encoding='utf-8') as f:
                self.books = json.load(f)
        self.an = {a['id']: a for a in self.pack['analytes']}
        self.cond = {c['id']: c for c in self.pack['conditions']}
        self.src = {s['id']: s for s in self.pack['sources']}
        self.quiz = {q['id']: q for q in self.pack['quiz']}
        self.groups = {g['id']: g['names'] for g in self.pack['groups']}
        self.cells = {c['id']: c for c in self.app['cellGuides']}
        self.cyto = {c['id']: c for c in self.app['cytoCells']}
        self.reftopics = {t['id']: t for t in self.app['refTopics']}
        self.atlas_img = {i['id']: i for i in self.atlas['images']}
        self.days = self._days()

    def _days(self):
        days = collections.OrderedDict()
        for mi, m in enumerate(self.cur['modules'], 1):
            for t in m['topics']:
                d = days.setdefault(t['n'], Day(n=t['n'], module=m, module_no=mi, topics=[]))
                d.topics.append(t)
        return days


@dataclasses.dataclass
class Day:
    n: int
    module: dict
    module_no: int
    topics: list

    @property
    def id(self):
        return f'd{self.n:03d}'

    @property
    def main(self):
        for t in self.topics:
            if t['type'] != 'lecture':
                return t
        return self.topics[0]

    @property
    def links(self):
        return self.main['links']

    def title(self, lang):
        return self.main.get('title_' + lang) or self.main['title_uz']


@dataclasses.dataclass
class Slide:
    kind: str
    title: str = ''
    eyebrow: str = ''
    data: dict = dataclasses.field(default_factory=dict)
    sources: list = dataclasses.field(default_factory=list)  # [{'key','loc'}]
    image: str = None
    names: list = dataclasses.field(default_factory=list)  # birlashgan analit nomlari

    # tarkibiy slaydlar: manba talab qilinmaydi
    NO_SOURCE = ('title', 'outline', 'sources')

    @property
    def is_content(self):
        return self.kind not in self.NO_SOURCE


# ----------------------------------------------------------------- manbalar --

_ORG = {
    'World Health Organization': 'WHO',
    'National Cancer Institute': 'NCI',
    'MedlinePlus [Internet]': 'MedlinePlus',
    'MedlinePlus Medical Encyclopedia': 'MedlinePlus Encyclopedia',
}


def _trunc(s, n):
    s = ' '.join(s.split())
    return s if len(s) <= n else s[:n - 1].rstrip(' ,;:') + '…'


PROVIDERS = {'commons': 'Wikimedia Commons', 'cdc_phil': 'CDC Public Health Image Library'}


def provider_name(p):
    return PROVIDERS.get(p, p.replace('_', ' ').title())


class Sources:
    """Slaydlarda ishlatilgan manbalar reestri (oxirgi slayd uchun)."""

    def __init__(self, repo):
        self.repo = repo
        self.entries = collections.OrderedDict()  # key -> {'short','full','url'}

    # --- pack.json manbasi
    def pack(self, source_id, locator=None, pages=None):
        s = self.repo.src.get(source_id)
        if s is None:
            raise KeyError(f'pack.json: manba yo\'q: {source_id}')
        key = 'pack:' + source_id
        if key not in self.entries:
            if s['kind'] == 'book':
                parts = [x.strip() for x in s['publisher'].split(' · ')]
                authors = parts[0]
                rest = '. '.join(parts[1:])
                surname = authors.split()[0].rstrip(',')
                short = f'{surname}, {s.get("source_date") or ""}'.strip(', ')
                full = f'{authors} {s["title"]}. {rest}'.strip()
                url = None
            else:
                org = s['publisher'].split(' · ')[0]
                short = f'{org}: {_trunc(s["title"], 56)}'
                date = (s.get('source_date') or s.get('accessed') or '')[:10]
                full = f'{s["publisher"].replace(" · ", ", ")}. {s["title"]}. {date}'.strip()
                url = s.get('url')
                if url:
                    full += f'. {url}'
            self.entries[key] = {'short': short, 'full': full, 'url': url,
                                 'locs': [] if s['kind'] == 'book' else None}
        loc = (locator or '').strip()
        if pages:
            loc = (loc + ', ' if loc else '') + f'p. {pages}'
        locs = self.entries[key].get('locs')
        if locs is not None and loc and loc not in locs:
            locs.append(loc)    # kitoblar uchun foydalanilgan bo'lim/sahifalar "Adabiyotlar"da chiqadi
        return {'key': key, 'loc': loc}

    def bib(self, key):
        """Oxirgi slayddagi yozuv: to'liq bibliografiya (+ kitoblar uchun bo'lim/sahifalar)."""
        e = self.entries[key]
        locs = e.get('locs')
        return e['full'] + (' — ' + '; '.join(locs) if locs else '')

    # --- Dart'dan ko'chirilgan CalcRef {'source_id','citation','url','locator'}
    def dart(self, ref):
        key = 'app:' + ref['source_id']
        if key not in self.entries:
            cit = ref['citation']
            head, _, tail = cit.partition('. ')
            org = _ORG.get(head, head if len(head) < 28 else head.split(',')[0])
            title = tail.split('. ')[0] if tail else head
            short = f'{org}: {_trunc(title, 56)}' if tail else _trunc(head, 70)
            full = cit + (f'. {ref["url"]}' if ref.get('url') else '')
            self.entries[key] = {'short': short, 'full': full, 'url': ref.get('url')}
        return {'key': key, 'loc': (ref.get('locator') or '').strip()}

    # --- toifa banki ichidagi {'url','locator'}
    def url(self, ref):
        url = ref['url']
        key = 'url:' + url
        head = ref['locator'].split(' — ')[0].strip()
        if key not in self.entries:
            self.entries[key] = {'short': _trunc(head, 70), 'full': f'{head}. {url}', 'url': url}
        return {'key': key, 'loc': ''}

    # --- mikroskopiya fotosi
    def atlas(self, img):
        key = 'atlas:' + img['id']
        if key not in self.entries:
            title = img['source_title'].replace('File:', '')
            lic = img['license']
            full = (f'{title}. {img["author"]} ({img.get("credit") or "—"}), {lic}, '
                    f'{provider_name(img["provider"])}. {img["source_page"]}')
            self.entries[key] = {'short': f'{img["author"]}, {lic}', 'full': full,
                                 'url': img['source_page']}
        return {'key': key, 'loc': ''}

    # --- ichki: toifa banki (url'siz)
    def bank(self, kind, lang, n=None):
        key = f'bank:{kind}'
        if key not in self.entries:
            self.entries[key] = {
                'short': T('bank_test', lang, n=n) if kind == 'test' else T('bank_oral', lang),
                'full': 'KDL ixtisoslashtirish (toifa) imtihoni savollari banki: '
                        + ('test savollari (ro‘yxat bo‘yicha)' if kind == 'test' else 'og‘zaki savollar'),
                'url': None}
        return {'key': key, 'loc': f'№{n}' if n else ''}

    # --- kitob (books_extra.json)
    def book(self, book_id, loc):
        b = self.repo.books['books'][book_id]
        key = 'book:' + book_id
        if key not in self.entries:
            self.entries[key] = {'short': b['short'], 'full': b['full'], 'url': None}
        return {'key': key, 'loc': loc}

    def short_cite(self, ref, loc_max=44):
        e = self.entries[ref['key']]
        loc = ref.get('loc') or ''
        if loc and len(loc) <= loc_max:
            return f'{e["short"]} ({loc})'
        return e['short']


def refs_of(src, claim_or_obj):
    """pack'dagi {refs:[{source_id,locator,pages}]} yoki {source_ids, locator}."""
    out = []
    for r in claim_or_obj.get('refs') or []:
        out.append(src.pack(r['source_id'], r.get('locator'), r.get('pages')))
    if not out:
        for sid in claim_or_obj.get('source_ids') or []:
            out.append(src.pack(sid, claim_or_obj.get('locator')))
    return out


def dedupe(refs):
    seen, out = set(), []
    for r in refs:
        k = (r['key'], r['loc'])
        if k not in seen:
            seen.add(k)
            out.append(r)
    return out


# --------------------------------------------------------------- analitlar --

def claims(an, *sections):
    return [c for c in an['claims'] if c['section'] in sections]


def _blocks(lang, items, label_key=None):
    # yorliq faqat guruhning birinchi bandida
    return [{'label': T(label_key, lang) if (label_key and i == 0) else None, 'text': L(c['text'], lang)}
            for i, c in enumerate(items)]


def _range_str(x, lang):
    lo, hi = x.get('low'), x.get('high')
    unit = x.get('unit') or ''
    if lo is not None and hi is not None and not x.get('low_exclusive') and not x.get('high_exclusive'):
        s = f'{num(lo, lang)}–{num(hi, lang)}'
    else:
        parts = []
        if lo is not None:
            parts.append(('>' if x.get('low_exclusive') else '≥') + ' ' + num(lo, lang))
        if hi is not None:
            parts.append(('<' if x.get('high_exclusive') else '≤') + ' ' + num(hi, lang))
        s = '; '.join(parts)
    return f'{s} {unit}'.strip()


def analyte_slides(repo, src, an, lang, seen=None):
    """Bitta analit kartasi -> slaydlar. seen: deck bo'ylab ishlatilgan
    "maqsad" matnlari (bir xil umumiy matn qayta-qayta chiqmasin)."""
    seen = seen if seen is not None else set()
    out = []
    name = L(an['names'], lang)
    group = L(repo.groups.get(an['group']), lang)
    chips = []
    if an.get('specimen'):
        chips.append(f'{T("specimen", lang)}: {L(an["specimen"], lang)}')
    if an.get('units'):
        chips.append(f'{T("units", lang)}: {", ".join(an["units"])}')
    if an.get('population'):
        chips.append(f'{T("population", lang)}: {L(an["population"], lang)}')

    # 1) maqsad + fiziologiya
    pur, phy = claims(an, 'purpose'), claims(an, 'physiology')
    pur = [c for c in pur if L(c['text'], lang) not in seen]
    seen.update(L(c['text'], lang) for c in pur)
    if pur or phy:
        blocks = _blocks(lang, pur, 'purpose') + _blocks(lang, phy, 'physiology')
        rel = [L(repo.an[r]['names'], lang) for r in an.get('related', []) if r in repo.an]
        out.append(Slide('text', title=name, eyebrow=f'{group} · {T("purpose", lang)}',
                         data={'blocks': blocks, 'chips': chips},
                         sources=dedupe([r for c in pur + phy for r in refs_of(src, c)])))
    # 2) me'yor/qaror chegaralari (pack)
    rows, rrefs = [], []
    for x in an.get('decision_limits') or []:
        who = L(x.get('population'), lang)
        note = L(x.get('note'), lang)
        rows.append([L(x['label'], lang), _range_str(x, lang),
                     (who + (' — ' + note if note else '')).strip(' —')])
        rrefs += refs_of(src, x)
    for g in an.get('treatment_goals') or []:
        tag = f' ({T("obsolete", lang)})' if g.get('superseded_by') else ''
        rows.append([f'{g["guideline_name"]}, {g["year"]}{tag}',
                     f'{L(g["target_text"], lang)}', L(g.get('population'), lang)])
        rrefs += refs_of(src, g)
    if rows:
        out.append(Slide('table', title=name, eyebrow=f'{group} · {T("limits", lang)}',
                         data={'header': [T('th_indicator', lang), T('th_value', lang), T('th_who', lang)],
                               'rows': rows, 'widths': [0.30, 0.20, 0.50]},
                         sources=dedupe(rrefs)))
    # 3) natija talqini
    hi, lo = claims(an, 'high_result'), claims(an, 'low_result')
    pos, neg = claims(an, 'positive_result'), claims(an, 'negative_result')
    res = claims(an, 'results')
    cols = []
    if hi:
        cols.append(('high', hi))
    if lo:
        cols.append(('low', lo))
    if pos:
        cols.append(('positive', pos))
    if neg:
        cols.append(('negative', neg))
    if cols or res:
        out.append(Slide('columns', title=name, eyebrow=f'{group} · {T("results", lang)}',
                         data={'cols': [{'head': T(k, lang), 'blocks': _blocks(lang, v)} for k, v in cols],
                               'single': _blocks(lang, res)},
                         sources=dedupe([r for _, v in cols for c in v for r in refs_of(src, c)]
                                        + [r for c in res for r in refs_of(src, c)])))
    # 4) preanalitika
    pre, itf, lim = claims(an, 'preanalytics'), claims(an, 'interference'), claims(an, 'limitations')
    if pre or itf or lim:
        blocks = (_blocks(lang, pre, 'p_pre') + _blocks(lang, itf, 'p_interf')
                  + _blocks(lang, lim, 'limitations'))
        out.append(Slide('text', title=name, eyebrow=f'{group} · {T("preanalytics", lang)}',
                         data={'blocks': blocks, 'chips': []},
                         sources=dedupe([r for c in pre + itf + lim for r in refs_of(src, c)])))
    return out


# ------------------------------------------------------------------ holatlar --

def condition_slides(repo, src, cond, lang):
    out = []
    name = L(cond['names'], lang)
    eb = T('cond_label', lang)
    s = cond['summary']
    out.append(Slide('text', title=name, eyebrow=f'{eb} · {T("cond_summary", lang)}',
                     data={'blocks': [{'label': None, 'text': L(s['text'], lang)}], 'chips': []},
                     sources=dedupe(refs_of(src, s))))
    rows, refs = [], []
    for p in cond['panel']:
        rows.append([L(p['names'], lang), T('tier_' + p['tier'], lang), L(p['why'], lang)])
        refs += refs_of(src, p)
    if rows:
        out.append(Slide('table', title=name, eyebrow=f'{eb} · {T("cond_panel", lang)}',
                         data={'header': [T('th_indicator', lang), T('th_tier', lang), T('th_meaning', lang)],
                               'rows': rows, 'widths': [0.27, 0.19, 0.54]},
                         sources=dedupe(refs)))
    rows, refs = [], []
    for p in cond['patterns']:
        rows.append([L(p['finding'], lang), L(p['meaning'], lang)])
        refs += refs_of(src, p)
    if rows:
        out.append(Slide('table', title=name, eyebrow=f'{eb} · {T("cond_patterns", lang)}',
                         data={'header': [T('th_finding', lang), T('th_meaning', lang)],
                               'rows': rows, 'widths': [0.5, 0.5]},
                         sources=dedupe(refs)))
    cau = cond.get('cautions') or []
    if cau:
        out.append(Slide('text', title=name, eyebrow=f'{eb} · {T("cond_cautions", lang)}',
                         data={'blocks': [{'label': None, 'text': L(c['text'], lang)} for c in cau],
                               'chips': [], 'bullets': True},
                         sources=dedupe([r for c in cau for r in refs_of(src, c)])))
    return out


# -------------------------------------------------------- jadvallar (Dart) --

def reftopic_slides(repo, src, rt, lang):
    out = []
    ttl = L(rt['title'], lang)
    for b in rt['blocks']:
        blocks = []
        for f in b.get('facts') or []:
            blocks.append({'label': L(f['label'], lang), 'text': L(f['value'], lang)})
        for x in b.get('bullets') or []:
            blocks.append({'label': None, 'text': L(x, lang)})
        if not blocks:
            continue
        chips = [L(b['tag'], lang)] if b.get('tag') else []
        out.append(Slide('text', title=L(b['title'], lang), eyebrow=f'{T("ref_label", lang)} · {ttl}',
                         data={'blocks': blocks, 'chips': chips, 'warn': bool(b.get('warning')),
                               'bullets': not (b.get('facts'))},
                         sources=dedupe([src.dart(r) for r in b['refs']])))
    return out


# ---------------------------------------------------- hujayralar (Dart) -------

NORMAL_CELLS = ['neutrophil_segmented', 'neutrophil_band', 'lymphocyte_small',
                'lymphocyte_large', 'monocyte', 'eosinophil', 'basophil']
WBC_ANALYTES = {'neutrophils', 'lymphocytes', 'monocytes', 'eosinophils', 'basophils'}
B12 = {'vitamin-b12', 'folate', 'methylmalonic-acid'}
DIFF_TOOL = '/lab/calculators/differential'
EPI = ['superficial', 'intermediate', 'parabasal', 'endocervical', 'metaplastic']
FLORA = ['lactobacilli', 'clue_cell', 'trichomonas', 'candida', 'inflammation', 'gonococcus']
LESION = ['koilocyte', 'hsil']


def cell_selection(day):
    """Mavzu havolalariga qarab qaysi hujayra sxemalari ko'rsatiladi (qoida
    DECKS_COVERAGE.md da yozilgan)."""
    L_ = day.links
    an, title = set(L_['analytes']), day.title('uz').lower()
    diff_tool = DIFF_TOOL in L_['tools']
    ids = []
    if diff_tool or an & WBC_ANALYTES:
        ids += NORMAL_CELLS
    if diff_tool:
        ids += ['lymphocyte_reactive', 'neutrophil_toxic']
    if diff_tool or an & B12 or 'b-12' in title:
        ids.append('neutrophil_hypersegmented')
    if diff_tool or ('leykoz' in title and 'surunkali' not in title):
        ids.append('blast')
    if diff_tool or 'limfoleykoz' in title:
        ids.append('smudge_cell')
    return list(dict.fromkeys(ids)), diff_tool


def cyto_selection(day):
    an = set(day.links['analytes'])
    ids = []
    if 'pap-test' in an:
        ids += EPI
    if 'vaginal-wet-mount' in an:
        ids += FLORA
    if an & {'pap-test', 'hpv-test'}:
        ids += LESION
    return list(dict.fromkeys(ids))


def cell_slides(repo, src, day, lang):
    ids, diff_tool = cell_selection(day)
    out = []
    ap = repo.app
    for cid in ids:
        c = repo.cells[cid]
        rows = []
        for k, ui in (('size', 'f_size'), ('nucleus', 'f_nucleus'), ('cytoplasm', 'f_cytoplasm'),
                      ('granules', 'f_granules'), ('key', 'f_key'), ('seenIn', 'f_seen')):
            if c.get(k):
                rows.append((T(ui, lang), L(c[k], lang)))
        out.append(Slide('card', title=L(c['name'], lang), eyebrow=T('cell_label', lang),
                         data={'rows': rows, 'note': T('schematic', lang),
                               'badge': T('refer', lang) if c.get('refer') else None},
                         image=f'assets/differential/{cid}.png',
                         sources=dedupe([src.dart(r) for r in c['refs']])))
    # adashtiriladigan juftliklar
    for cf in ap['confusions']:
        if cf['a'] in ids and cf['b'] in ids or diff_tool:
            a, b = repo.cells[cf['a']], repo.cells[cf['b']]
            refs = dedupe([src.dart(r) for r in cf['refs']])
            na, nb = L(a['name'], lang), L(b['name'], lang)
            out.append(Slide('pair', title=f'{na} — {nb}', eyebrow=T('cell_pair', lang),
                             data={'a': {'name': na, 'image': f'assets/differential/{cf["a"]}.png'},
                                   'b': {'name': nb, 'image': f'assets/differential/{cf["b"]}.png'},
                                   'tip': L(cf['tip'], lang), 'note': T('schematic', lang),
                                   'badge': T('refer', lang) if cf.get('refer') else None},
                             sources=refs))
            out.append(Slide('table', title=f'{na} — {nb}', eyebrow=T('cell_pair', lang),
                             data={'header': ['', na, nb],
                                   'rows': [[L(r[0], lang), L(r[1], lang), L(r[2], lang)] for r in cf['rows']],
                                   'widths': [0.18, 0.41, 0.41]},
                             sources=refs))
    if diff_tool:
        for f in ap['diffFindings']:
            blocks = [{'label': None, 'text': L(f['what'], lang)}]
            blocks += [{'label': None, 'text': L(x, lang), 'bullet': True} for x in f['causes']]
            out.append(Slide('text', title=L(f['title'], lang), eyebrow=T('cell_find', lang),
                             data={'blocks': blocks, 'chips': []},
                             sources=dedupe([src.dart(r) for r in f['refs']])))
        for t in ap['techniqueSections']:
            out.append(Slide('text', title=L(t['title'], lang), eyebrow=T('cell_tech', lang),
                             data={'blocks': [{'label': None, 'text': L(x, lang)} for x in t['items']],
                                   'chips': [], 'bullets': not t.get('numbered'),
                                   'numbered': bool(t.get('numbered'))},
                             sources=dedupe([src.dart(r) for r in t['refs']])))
        ds = ap['diffSources']
        refs = [src.dart({'source_id': ds['who2003']['id'], 'citation': ds['who2003']['citation'],
                          'url': ds['who2003']['url'], 'locator': '9.13, Table 9.12'}),
                src.dart({'source_id': ds['medlineEncyDiff']['id'], 'citation': ds['medlineEncyDiff']['citation'],
                          'url': ds['medlineEncyDiff']['url'], 'locator': 'Normal results'}),
                src.dart({'source_id': ds['lyubina1984']['id'], 'citation': ds['lyubina1984']['citation'],
                          'url': ds['lyubina1984']['url'], 'locator': '§50, табл. 6'})]
        out.append(Slide('table', title=T('cell_ranges', lang), eyebrow=T('cell_label', lang),
                         data={'header': [T('th_cell', lang), 'WHO 2003', 'MedlinePlus', T('th_classic', lang)],
                               'rows': [[L(r['cell'], lang), r['who'].replace('.', ','), r['medline'],
                                         L(r['classic'], lang)] for r in ap['exampleRanges']],
                               'widths': [0.34, 0.2, 0.2, 0.26]},
                         sources=refs))
    return out


def cyto_slides(repo, src, day, lang):
    ids = cyto_selection(day)
    an = set(day.links['analytes'])
    out = []
    ap = repo.app
    marks = ap['cytoMarks']
    for cid in ids:
        c = repo.cyto[cid]
        m = marks.get(cid)
        rows = [(T('f_look', lang), L(c['look'], lang)), (T('f_key', lang), L(c['key'], lang)),
                (T('f_meaning', lang), L(c['meaning'], lang))]
        if c.get('confuse'):
            rows.append((T('f_confuse', lang), L(c['confuse'], lang)))
        refs = [src.dart(r) for r in c['refs']]
        marks_txt = []
        if m:
            marks_txt = [f'{i} — {L(x, lang)}' for i, x in enumerate(m['marks'], 1)]
            rows.append((T('f_method', lang), L(m['method'], lang)))
            refs += [src.dart(r) for r in m['refs']]
        out.append(Slide('card', title=L(c['name'], lang), eyebrow=T('cyto_label', lang),
                         data={'rows': rows, 'note': T('schematic', lang), 'marks': marks_txt,
                               'caveat': (T('f_caveat', lang), L(m['caveat'], lang)) if m else None,
                               'badge': T('refer', lang) if c.get('refer') else None},
                         image=f'assets/cytology/{cid}.png', sources=dedupe(refs)))
    if 'pap-test' in an:
        bi = ap['bethesdaItems']
        out.append(Slide('table', title=T('bethesda', lang), eyebrow=T('cyto_general', lang),
                         data={'header': [T('th_code', lang), T('th_name', lang), T('th_meaning', lang)],
                               'rows': [[b['code'], L(b['name'], lang), L(b['meaning'], lang)] for b in bi],
                               'widths': [0.14, 0.38, 0.48]},
                         sources=dedupe([src.dart(r) for b in bi for r in b['refs']])))
    if 'pap-test' in an and 'vaginal-wet-mount' in an:
        tech = ap['cytoTechnique']
        out.append(Slide('text', title=T('cyto_tech', lang), eyebrow=T('cyto_general', lang),
                         data={'blocks': [{'label': L(s['title'], lang), 'text': L(s['body'], lang)} for s in tech],
                               'chips': []},
                         sources=[src.dart(r) for r in ap['cytoTechniqueRefs']]))
    return out


# ---------------------------------------------------------- atlas (foto) ----

def atlas_slides(repo, src, day, lang):
    out = []
    at = repo.atlas
    for secid in day.links['microscopy']:
        sec = next(s for s in at['sections'] if s['id'] == secid)
        imgs = [i for i in at['images']
                if next(e for e in at['entities'] if e['id'] == i['entity'])['group'] in
                {g['id'] for g in at['groups'] if g['section'] == secid}]
        ents = {e['id']: e for e in at['entities']}
        for k in range(0, len(imgs), 2):
            pair = imgs[k:k + 2]
            items = []
            for i in pair:
                cap = i['caption']['tr'].get(lang) or i['caption']['text']
                ent = ents[i['entity']]
                items.append({'image': i['asset'], 'caption': cap,
                              'credit': f'{T("photo", lang)}: {i["author"]}, {i["license"]} · '
                                        f'{provider_name(i["provider"])}'})
            out.append(Slide('gallery', title=L(sec['name'], lang), eyebrow=T('atlas', lang),
                             data={'items': items},
                             sources=[src.atlas(i) for i in pair]))
    return out


# ------------------------------------------------------ toifa/mashq (Q&A) ----

QA_CAPS = {'quiz': 6, 'test': 6, 'oral': 3}


def _cand(t, key, sub):
    return ((t.get(key) or {}).get(sub)) or []


def oral_questions(repo, day):
    t = day.main
    ids = _cand(t, 'oral_candidates', 'ids')
    tt = day.links.get('toifa_topic')
    if not ids and tt:
        ids = [q['id'] for q in repo.oral.values() if q['topic'] == tt and not q.get('held')]
    return [repo.oral[i] for i in ids if i in repo.oral and not repo.oral[i].get('held')]


def test_questions(repo, day):
    t = day.main
    ids = _cand(t, 'test_candidates', 'ids')
    tt = day.links.get('toifa_topic')
    if not ids and tt:
        ids = [q['id'] for q in repo.tests.values() if q['topic'] == tt]
    out = []
    for i in ids:
        q = repo.tests.get(i)
        # faqat kaliti aniq (verdict ok), yagona to'g'ri javobli savollar
        if q and q['verdict'] == 'ok' and len(q.get('key') or []) == 1 \
                and not q.get('held') and not q.get('unverified'):
            out.append(q)
    return out


def quiz_questions(repo, day):
    t = day.main
    ids = _cand(t, 'test_candidates', 'pack_quiz_ids')
    if not ids and day.links['analytes']:
        an = set(day.links['analytes'])
        ids = [q['id'] for q in repo.pack['quiz'] if an & set(q.get('topic_ids') or [])]
    return [repo.quiz[i] for i in ids if i in repo.quiz and 'correct_index' in repo.quiz[i]]


def _qa_pair(lang, question, options, correct, explanation, basis, refs):
    q = Slide('qa_q', title=T('question', lang), eyebrow=T('qa_label', lang),
              data={'question': question, 'options': options}, sources=refs)
    a = Slide('qa_a', title=T('answer', lang), eyebrow=T('qa_label', lang),
              data={'question': question, 'options': options, 'correct': correct,
                    'explanation': explanation, 'basis': basis,
                    'labels': {'explanation': T('explanation', lang), 'basis': T('basis', lang)}},
              sources=refs)
    return [q, a]


def qa_slides(repo, src, day, lang, caps=None):
    caps = caps or QA_CAPS
    out, counts = [], {}
    for q in quiz_questions(repo, day):
        if len(out) // 2 >= caps['quiz']:
            break
        refs = dedupe(refs_of(src, q))
        if not refs:
            continue  # manbasiz savol — slaydga qo'yilmaydi
        opts = [L(o['text'], lang) for o in q['options']]
        ci = q['correct_index']
        out += _qa_pair(lang, L(q['prompt'], lang), opts, ci,
                        L(q['options'][ci].get('explanation'), lang), L(q.get('basis'), lang), refs)
    counts['quiz'] = len(out) // 2
    n0 = len(out)
    for q in test_questions(repo, day)[:caps['test']]:
        tr = q.get('tr', {}).get(lang) if lang != 'uz' else None
        text = tr['q'] if tr else q['q']
        opts = tr['options'] if tr else q['options']
        note = tr.get('note') if tr else q.get('note')
        refs = [src.url(r) for r in q.get('refs') or []] or [src.bank('test', lang, q['n'])]
        out += _qa_pair(lang, text, opts, q['key'][0], note or '', '', dedupe(refs))
    counts['test'] = (len(out) - n0) // 2
    n0 = len(out)
    for q in oral_questions(repo, day)[:caps['oral']]:
        tr = q.get('tr', {}).get(lang) if lang != 'uz' else None
        text = tr['q'] if tr else q['q']
        plan = tr['plan'] if tr else q['plan']
        refs = [src.url(r) for r in q.get('refs') or []] or [src.bank('oral', lang)]
        out.append(Slide('text', title=T('oral_a', lang), eyebrow=f'{T("qa_label", lang)} · {T("oral_q", lang)}',
                         data={'lead': text, 'blocks': [{'label': None, 'text': x} for x in plan],
                               'chips': [], 'numbered': True},
                         sources=dedupe(refs)))
    counts['oral'] = len(out) - n0
    return out, counts


def oral_reference_slides(repo, src, day, lang):
    """Toifa og'zaki banki savollaridagi (manbali) me'yor va qaror chegaralari."""
    rows, refs, note, seen = [], [], '', set()
    for q in oral_questions(repo, day):
        tr = (q.get('tr') or {}).get(lang) if lang != 'uz' else None
        tref = (tr or {}).get('reference') or []
        tcut = (tr or {}).get('cutoffs') or []
        for i, r in enumerate(q.get('reference') or []):
            o = tref[i] if i < len(tref) else {}
            name = o.get('analyte') or r['analyte']
            unit = o.get('unit') or r.get('unit') or ''
            who = ', '.join(x for x in (o.get('population') or r.get('population'),
                                         o.get('specimen') or r.get('specimen')) if x)
            val = f'{o.get("value") or r["value"]} {unit}'.strip()
            k = (name, val, who)
            if k in seen:
                continue
            seen.add(k)
            rows.append([name, val, who])
            refs.append(src.url(r['ref']))
            note = note or o.get('note') or r.get('note') or ''
        for i, c in enumerate(q.get('cutoffs') or []):
            o = tcut[i] if i < len(tcut) else {}
            name = o.get('criterion') or c['criterion']
            val = f'{o.get("value") or c["value"]} {o.get("unit") or c.get("unit") or ""}'.strip()
            who = o.get('guideline') or c.get('guideline') or ''
            k = (name, val, who)
            if k in seen:
                continue
            seen.add(k)
            rows.append([name, val, who])
            refs.append(src.url(c['ref']))
    if not rows:
        return []
    return [Slide('table', title=T('limits', lang), eyebrow=T('qa_label', lang) + ' · ' + T('oral_q', lang),
                  data={'header': [T('th_indicator', lang), T('th_value', lang), T('th_who', lang)],
                        'rows': rows, 'widths': [0.30, 0.20, 0.50], 'note': note},
                  sources=dedupe(refs))]


# ---------------------------------------------- kitoblardan qo'shimcha ------

def book_slides(repo, src, day, lang):
    """Ustoz kitoblaridan o'z so'zim bilan qisqa mazmun (data/books_extra.json);
    shu tilda mazmun bo'lmasa slayd tashlanadi."""
    out = []
    for e in repo.books['topics'].get(day.id, []):
        refs = [src.pack(r['pack'], L(r['loc'], lang)) for r in e['refs']]
        if 'table' in e:
            t = e['table']
            if lang not in t['rows']:
                continue
            out.append(Slide('table', title=L(e['title'], lang), eyebrow=T('book_extra', lang),
                             data={'header': t['header'][lang], 'rows': t['rows'][lang],
                                   'widths': t['widths']}, sources=refs))
            continue
        bl = e['bullets'].get(lang)
        if not bl:
            continue
        out.append(Slide('text', title=L(e['title'], lang), eyebrow=T('book_extra', lang),
                         data={'blocks': [{'label': None, 'text': x} for x in bl], 'chips': [],
                               'bullets': True}, sources=refs))
    return out


# --------------------------------------------------------------- yig'ish ----

@dataclasses.dataclass
class Deck:
    day: Day
    lang: str
    slides: list
    sources: Sources
    coverage: dict

    @property
    def content_slides(self):
        return [s for s in self.slides if s.is_content]


def _sig(sl):
    d = {k: v for k, v in sl.data.items() if k != 'chips'}
    return (sl.kind, sl.eyebrow, json.dumps(d, sort_keys=True, ensure_ascii=False))


def _merge_same(existing, new):
    """Bir xil mazmunli slaydlar (masalan, leykoformula analitlarining umumiy
    preanalitikasi) qayta chiqmaydi: nomi oldingi slayd sarlavhasiga qo'shiladi."""
    sigs = {_sig(x): x for x in existing}
    out = []
    for x in new:
        prev = sigs.get(_sig(x))
        if prev is not None and prev.names and x.names[0] not in prev.names:
            prev.names.append(x.names[0])
            prev.sources = dedupe(prev.sources + x.sources)
        else:
            out.append(x)
            sigs[_sig(x)] = x
    return out


def collect(repo, day, lang):
    """Mavzu kontentini yig'adi: (guruhlar, Sources, coverage)."""
    src = Sources(repo)
    L_ = day.links
    cov = {'analytes': {}, 'conditions': [], 'reftopics': [], 'cells': [], 'cyto': [],
           'atlas': 0, 'qa': {}, 'oral_reference': 0, 'books': 0, 'missing': []}
    groups = []  # (guruh kaliti, [slaydlar])

    an_slides, seen_purpose = [], set()
    for aid in L_['analytes']:
        a = repo.an.get(aid)
        if not a:
            cov['missing'].append(f'analit {aid}: paketda yo‘q')
            continue
        sl = analyte_slides(repo, src, a, lang, seen_purpose)
        if not a['claims'] and not sl:
            cov['missing'].append(f'analit {aid}: kartada da’vo yo‘q')
        for x in sl:
            x.names = [L(a['names'], lang)]
        cov['analytes'][aid] = {'slides': len(sl),
                                'limits': bool(a.get('decision_limits') or a.get('treatment_goals'))}
        an_slides += _merge_same(an_slides, sl)
    for x in an_slides:
        if len(x.names) > 1:
            x.title = ', '.join(x.names)
    if an_slides:
        groups.append(('analytes', an_slides))
    co_slides = []
    for cid in L_['conditions']:
        c = repo.cond.get(cid)
        if not c:
            cov['missing'].append(f'holat {cid}: paketda yo‘q')
            continue
        co_slides += condition_slides(repo, src, c, lang)
        cov['conditions'].append(cid)
    if co_slides:
        groups.append(('conditions', co_slides))
    rf_slides = []
    for rid in L_['reference']:
        rt = repo.reftopics.get(rid)
        if not rt:
            cov['missing'].append(f'jadval {rid}: topilmadi')
            continue
        rf_slides += reftopic_slides(repo, src, rt, lang)
        cov['reftopics'].append(rid)
    if rf_slides:
        groups.append(('reftopics', rf_slides))
    cs = cell_slides(repo, src, day, lang)
    if cs:
        cov['cells'] = cell_selection(day)[0]
        groups.append(('cells', cs))
    ys = cyto_slides(repo, src, day, lang)
    if ys:
        cov['cyto'] = cyto_selection(day)
        groups.append(('cyto', ys))
    ats = atlas_slides(repo, src, day, lang)
    if ats:
        cov['atlas'] = sum(len(s.data['items']) for s in ats)
        groups.append(('atlas', ats))
    bs = book_slides(repo, src, day, lang)
    if bs:
        cov['books'] = len(bs)
        groups.append(('books', bs))
    ors = oral_reference_slides(repo, src, day, lang)
    if ors:
        cov['oral_reference'] = len(ors[0].data['rows'])
        groups.append(('oralref', ors))
    qs, counts = qa_slides(repo, src, day, lang)
    cov['qa'] = counts
    if qs:
        groups.append(('qa', qs))
    if L_['analytes'] and not any(v['limits'] for v in cov['analytes'].values()) and not ors:
        cov['missing'].append('me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q')
    if L_.get('gap'):
        cov['missing'].append('curriculum: gap bayrog‘i (havolalar yetarli emas)')
    return groups, src, cov


GROUP_LABEL = {
    'analytes': {'uz': 'Tahlillar', 'ru': 'Исследования', 'en': 'Tests'},
    'conditions': {'uz': 'Holatlar', 'ru': 'Состояния', 'en': 'Conditions'},
    'reftopics': {'uz': 'Jadvallar va algoritmlar', 'ru': 'Таблицы и алгоритмы', 'en': 'Tables and algorithms'},
    'cells': {'uz': 'Leykoformula hujayralari', 'ru': 'Клетки лейкоформулы', 'en': 'Differential cells'},
    'cyto': {'uz': 'Sitologiya', 'ru': 'Цитология', 'en': 'Cytology'},
    'atlas': {'uz': 'Mikroskopik atlas', 'ru': 'Микроскопический атлас', 'en': 'Microscopy atlas'},
    'books': {'uz': 'Darslik bo‘yicha mazmun', 'ru': 'Материал из учебников', 'en': 'Textbook material'},
    'oralref': {'uz': 'Me’yoriy qiymatlar', 'ru': 'Референсные значения', 'en': 'Reference values'},
    'qa': {'uz': 'Mashq: savol-javob', 'ru': 'Практика: вопросы и ответы', 'en': 'Practice: Q&A'},
}


def build_deck(repo, day, lang):
    """Mavzu uchun to'liq deck; kontent bo'lmasa — (None, coverage)."""
    groups, src, cov = collect(repo, day, lang)
    body = [s for _, g in groups for s in g]
    if not body:
        return None, cov
    title_lines = []
    for t in day.topics:
        key = {'practical': 'h_practical', 'lecture': 'h_lecture', 'attestation': 'h_attestation'}[t['type']]
        title_lines.append(T(key, lang, h=t['hours']))
    slides = [Slide('title', title=day.title(lang),
                    eyebrow=T('module_topic', lang, m=day.module_no, n=day.n),
                    data={'lines': title_lines,
                          'module': day.module.get('title_' + lang) or day.module['title_uz']})]
    items = []
    for gid, g in groups:
        names = []
        for s in g:
            for nm in (s.names or [s.title]):
                if nm and nm not in names and s.kind not in ('qa_q', 'qa_a'):
                    names.append(nm)
        if gid == 'qa':
            names = [f'{cov["qa"].get("quiz", 0) + cov["qa"].get("test", 0)} + {cov["qa"].get("oral", 0)}']
        elif len(names) > 6:
            names = names[:6] + ['…']
        items.append(f'{GROUP_LABEL[gid][lang]}: ' + '; '.join(names))
    slides.append(Slide('outline', title=T('outline', lang), data={'items': items}))
    slides += body
    slides.append(Slide('sources', title=T('sources', lang),
                        data={'items': [src.bib(k) for k in src.entries]}))
    cov['slides'] = len(slides)
    cov['content_slides'] = len(body)
    return Deck(day, lang, slides, src, cov), cov
