#!/usr/bin/env python3
"""M9 amaliy kunlari uchun LabGuide tavsiya etgan amaliy rejani (tool/curriculum/m9_plan.json)
assets/curriculum/curriculum.json ga yozadi va docs/M9_PRACTICAL_TOPICS.md ni yaratadi (D-67).

Manbalarda (dars jadvallari, dastur) bu kunlar uchun kunma-kun mavzu yo'q; reja LabGuide tavsiyasi
sifatida belgilanadi: `plan_source: "labguide_recommended"`, `plan_refs` (darslik bob/bo'lim/sahifa),
`links.protocols` (amaliy protokol id lari; `id#1-4,8` — protokolning shu slaydlari).

Ishlatish:
  python3 tool/curriculum/apply_m9_plan.py           # yozadi
  python3 tool/curriculum/apply_m9_plan.py --check   # dolzarb bo'lmasa 1 bilan chiqadi
"""
import argparse
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
PLAN = os.path.join(HERE, 'm9_plan.json')
CUR = os.path.join(REPO, 'assets', 'curriculum', 'curriculum.json')
DOC = os.path.join(REPO, 'docs', 'M9_PRACTICAL_TOPICS.md')
PRACTICE = os.path.join(REPO, 'tool', 'slides', 'data', 'books_extra_practice.json')
PACK = os.path.join(REPO, 'assets', 'content', 'core', 'pack.json')
TESTS = os.path.join(REPO, 'assets', 'toifa', 'kdl_tests.json')
ORAL = os.path.join(REPO, 'assets', 'toifa', 'kdl_oral.json')
GENERIC = 'Laborator tekshiruv usullarini amaliyotda o‘zlashtirish'
TEST_CAP, ORAL_CAP = 20, 12


def load(p):
    with open(p, encoding='utf-8') as f:
        return json.load(f)


def parse_protocol(spec):
    """'id' yoki 'id#1-4,8' -> (id, [slayd raqamlari] yoki None)."""
    pid, _, sel = spec.partition('#')
    if not sel:
        return pid, None
    out = []
    for part in sel.split(','):
        a, _, b = part.partition('-')
        out += list(range(int(a), int(b or a) + 1))
    return pid, out


def validate(plan, practice, pack):
    errs = []
    protos = {p['id']: p for p in practice['protocols']}
    an = {a['id'] for a in pack['analytes']}
    cond = {c['id'] for c in pack['conditions']}
    books = set(practice.get('books', {}))
    srcs = {s['id'] for s in pack['sources'] if s['kind'] == 'book'}
    for d in plan['days']:
        w = d['id']
        for lg in ('uz', 'ru', 'en'):
            if not d['title'].get(lg, '').strip():
                errs.append(f'{w}: title_{lg} bo‘sh')
        for spec in d['protocols']:
            pid, sel = parse_protocol(spec)
            if pid not in protos:
                errs.append(f'{w}: protokol yo‘q: {pid}')
                continue
            n = len(protos[pid]['slides'])
            for i in sel or []:
                if not 1 <= i <= n:
                    errs.append(f'{w}: {pid}#{i} — protokolda {n} slayd')
        for a in d['analytes']:
            if a not in an:
                errs.append(f'{w}: analit yo‘q: {a}')
        for c in d.get('conditions', []):
            if c not in cond:
                errs.append(f'{w}: holat yo‘q: {c}')
        if not d['plan_refs']:
            errs.append(f'{w}: plan_refs bo‘sh')
        for r in d['plan_refs']:
            if 'book' in r and r['book'] not in books:
                errs.append(f'{w}: kitob yo‘q: {r["book"]}')
            if 'pack' in r and r['pack'] not in srcs:
                errs.append(f'{w}: pack kitobi yo‘q: {r["pack"]}')
            for lg in ('uz', 'ru', 'en'):
                if not r['loc'].get(lg, '').strip():
                    errs.append(f'{w}: plan_refs loc/{lg} bo‘sh')
        if not d['protocols'] and not d['analytes']:
            errs.append(f'{w}: na protokol, na analit')
    return errs


def candidates(day, topics_by_id, pack, tests, oral):
    quiz = {q['id'] for q in pack['quiz'] if 'correct_index' in q}
    pq = [q for a in day['analytes'] for q in sorted(quiz) if re.fullmatch(re.escape(a) + r'-q\d+', q)]
    src = day.get('candidates_from')
    if src:
        lt = next(t for t in topics_by_id.values() if t['id'].startswith(src + '-'))
        t_ids = list((lt.get('test_candidates') or {}).get('ids') or [])
        o_ids = list((lt.get('oral_candidates') or {}).get('ids') or [])
        if not day['analytes']:
            pq = list((lt.get('test_candidates') or {}).get('pack_quiz_ids') or [])
    else:
        t_ids, o_ids = [], []
    # ma'ruza kunida nomzod bo'lmasa (yoki manba kuni yo'q) — toifa mavzusi bo'yicha
    tt = day['toifa_topic']
    if not t_ids:
        t_ids = [q['id'] for q in sorted(tests, key=lambda q: q['n']) if q['topic'] == tt][:TEST_CAP]
    if not o_ids:
        o_ids = [q['id'] for q in oral if q['topic'] == tt and not q.get('held')][:ORAL_CAP]
    return t_ids, o_ids, pq


def apply(plan, cur, pack, tests, oral):
    by_id = {t['id']: t for m in cur['modules'] for t in m['topics']}
    for d in plan['days']:
        t = by_id[d['id'] + '-P']
        if t['type'] != 'practical':
            raise SystemExit(f'{t["id"]}: amaliy kun emas')
        t_ids, o_ids, pq = candidates(d, by_id, pack, tests, oral)
        new = {}
        for k, v in t.items():
            if k in ('title_ru', 'title_en', 'plan_source', 'plan_block', 'plan_refs'):
                continue
            if k == 'title_uz':
                new['title_uz'] = d['title']['uz']
                new['title_ru'] = d['title']['ru']
                new['title_en'] = d['title']['en']
                new['plan_source'] = plan['plan_source']
                new['plan_block'] = d['block']
                continue
            if k == 'links':
                new['links'] = {
                    'analytes': d['analytes'], 'conditions': d.get('conditions', []),
                    'reference': d['reference'], 'tools': d['tools'], 'microscopy': d['microscopy'],
                    'protocols': d['protocols'], 'toifa_topic': d['toifa_topic'], 'gap': False}
                new['plan_refs'] = d['plan_refs']
                new['oral_candidates'] = {'count': len(o_ids), 'ids': o_ids}
                new['test_candidates'] = {'count': len(t_ids), 'ids': t_ids, 'pack_quiz_ids': pq,
                                          'pack_quiz_count': len(pq)}
                new['test_gap'] = not t_ids and not pq
                new['oral_gap'] = not o_ids
                continue
            if k in ('oral_candidates', 'test_candidates', 'test_gap', 'oral_gap'):
                continue
            new[k] = v
        t.clear()
        t.update(new)
    return cur


# ------------------------------------------------------------------ hujjat ---

def loc(r, lg='uz'):
    return r['loc'][lg]


def book_short(r, practice, pack):
    if 'book' in r:
        return practice['books'][r['book']]['short']
    s = next(x for x in pack['sources'] if x['id'] == r['pack'])
    return f'{s["publisher"].split(" · ")[0].split(",")[0]}, {s.get("source_date") or ""}'.strip(', ')


def protocol_label(spec, protos):
    pid, sel = parse_protocol(spec)
    p = protos[pid]
    t = p['title']['uz']
    if not sel:
        return f'`{pid}` ({t})'
    names = [p['slides'][i - 1]['title']['uz'] for i in sel]
    return f'`{pid}` #{",".join(map(str, sel))} ({"; ".join(names)})'


def write_doc(plan, cur, practice, pack, check=False):
    protos = {p['id']: p for p in practice['protocols']}
    by_id = {t['id']: t for m in cur['modules'] for t in m['topics']}
    blocks = {b['id']: b for b in plan['blocks']}
    md = [
        '# M9 amaliy kunlari (d091–d142): manbalardagi holat va LabGuide tavsiya etgan amaliy reja', '',
        'Avtomatik: `python3 tool/curriculum/apply_m9_plan.py` (`tool/curriculum/m9_plan.json` → '
        '`assets/curriculum/curriculum.json` + shu hujjat). Qaror: **D-67** (`docs/DECISIONS.md`).', '',
        '## 1. Manbalarda nima yozilgan (aniq iqtiboslar)', '',
        '**Xulosa: kunma-kun amaliy mavzu hech bir manbada yo‘q.** 9-modulning 45 ta amaliy kunida barcha '
        'jadvallar bir xil umumiy nomni beradi; aniq mavzu faqat 8 ta ma’ruza kunida bor. Dasturda modul soatlari bor, '
        'mavzu/kun ro‘yxati yo‘q. Shuning uchun quyidagi reja — manba emas, **LabGuide tavsiyasi** (ustoz o‘zgartirishi mumkin).', '',
        '### 1.1. Dars jadvallari', '',
        '| Fayl (Drive / egasi yuklagan) | Davr | M9 amaliy kunlari | Ma’ruza kunlari (M9) | Oxiri |', '|---|---|---|---|---|',
        '| `дарс_жадвали_тулик_энг_охирги_Тургунова_Д_хайитга_узгаргани.doc` (Drive `1UBFIu755QfSvGGQOYjq6lcIX_UPDylkd`), '
        '2026-05-10 bosma nusxasi ham shu tuzilishda | 20.02–14.08.2026 | №90–№93, №95–№99, №101–№104, №106–№110, №112–№114, '
        '№116–№119, №121–№125, №127–№141 — har biri: «Amaliy yo‘nalishdagi mashg‘ulot | Laborator tekshiruv usullarini '
        'amaliyotda o‘zlashtirish. | … | 6» (№136–№141: «6+2», qo‘shimcha 13.35–14.55) | №89 «Umumiy qon taxlilini amaliyotda '
        'o‘zlashtirish.», №94 «Leykositar formulani…», №100 «Umumiy siydik taxlilini…», №105 «Umumiy balg’am taxlilini…», '
        '№111 «Umumiy axlat (najas) taxlilini…», №115 «Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari. '
        'Bioximik analizatorni dasturlashni amaliyotda o‘zlashtirish.», №120 «Laktatdegidrogenaza, Ishqoriy fosfotaza fermentlar '
        'tekshiruvini…», №126 «SRB, RF, ASLO lar tekshiruvini…» | №142 «Attestatsiya | Laborator tekshiruv usullarini amaliyotda '
        'o‘zlashtirish.» |',
        '| Turg‘unova jadvali, 2026-04-25 tahriri (egasi yuklagan .doc; `дарс жадвали 1. тулик.doc` bilan bir xil tuzilish) | '
        '20.02–18.08.2026 | №91–№94, №96–№100, №102–№105, №107–№111, №113–№115, №117–№120, №122–№126, №128–№143 — '
        '«Laborator tekshiruv usullarini amaliyotda o‘zlashtirish.» (6 soat) | №90, №95, №101, №106, №112, №116, №121, №127 '
        '(nomlari yuqoridagi bilan bir xil) | №144 attestatsiya (15.08). Sana xatosi manbada: №137 «07.06», №138 «08.06» '
        '(aslida 07.08/08.08) — sanalar ilovaga kiritilmaydi |',
        '| `1_864_2025_2026_6_oylik_Каримова_Зумрадхон_.pdf` (curriculum.json shu asosda, 143 kun) | 05.01–30.06.2026 | '
        'd091–d142 dagi 45 kun — umumiy nom | d090, d095, d101, d106, d112, d116, d121, d127 | d143 attestatsiya |', '',
        'Kun soni farqi (143 / 144 / 142) faqat oxirida (qo‘shimcha amaliy kun yoki bayram siljishi); `curriculum.json` '
        'kun soni o‘zgartirilmadi (D-42: guruhga xos jadval varianti asset’ga kiritilmaydi; batafsil — '
        '`docs/KDL_SCHEDULE_COMPARE_2026-10-17.md`).', '',
        '### 1.2. Dastur (`КЛД_ихтисослаштириш_864_кредит_Тўлиқ_дастур_Печатсиз.doc`, Drive `1TY9csJ6iVNzy624xAlwrgw8r21iJ1HTq`)', '',
        '- «3. DASTUR MAZMUNI» jadvali, 9-qator: «9 | MODUL: Laborator tekshiruv usullarini amaliyotda o‘zlashtirish. | 324 | 48 | '
        '| 276 |» — jami 324, ma’ruza 48, 276 soat «Laboratoriya ishi» ustunida (sarlavha qatori hujjatda qisman buzilgan; '
        'ustunlar tartibi M7 qatoridan aniqlangan: 120 = 12 + 20 + 72 + 16). Jami qatori: «864 | 138 | 128 | 518 | 26 | 54» '
        '(laboratoriya ishi ustuni yig‘indisi qatorlar bo‘yicha 528 — manbaning o‘zidagi nomuvofiqlik).',
        '- Hujjatda «amaliy mashg‘ulotlar mavzulari», «laboratoriya ishlari» yoki «mustaqil ish» mavzulari ro‘yxati, '
        'mavzu-soat jadvali **yo‘q** (.doc LibreOffice orqali to‘liq matnga o‘girib tekshirildi, 29 KB matn). Taqrizda '
        '«Dasturda xar bir amaliy mashg‘ulotning taqvimiy rejasi … ko‘rsatib o‘tilgan» deyilgan, lekin bunday reja hujjat '
        'ichida yo‘q.',
        '- Mashg‘ulotlar tartibi: «kunduzgi, kuniga 6 kredit»; jihozlar: «MINDRAY BS 300 …, Mindray BA-88A va RAYTO yarim '
        'avtomatik bioximik analizatori …», «« BIOZERS» mikroskopi, … gematologik va urino analizatorlar».', '',
        'Boshqa Drive qidiruvlari (`amaliyotda`, `жадвал`, `режа`, `reja`, `jadval`): faqat yuqoridagi jadvallar, 2024–2025 '
        'va 2025–2026 guruh jadvallari (Jalolov; «7.D.A.Turg‘unova +++.doc») — M9 amaliy kunlari ularda ham umumiy nomda.', '',
        '## 2. LabGuide tavsiya etgan amaliy reja', '',
        'Ilovada va ma’lumotda halol belgilangan: `plan_source: "labguide_recommended"`; kun sarlavhasi yonida '
        '«LabGuide tavsiya etgan amaliy reja» (ru «Рекомендованный LabGuide план практики», en «LabGuide recommended practical '
        'plan»); kun taqdimotining birinchi mazmun slaydi — «Kun rejasi» (jadvaldagi umumiy nom, tavsiya, mashq qilinadigan '
        'protokollar va reja asoslangan darslik bobi — «Manba» qatorida).', '',
        '**Tuzilishi.** ' + plan['frame']['uz'], '',
        '- Har ma’ruza kunidan keyingi amaliy kunlar o‘sha ma’ruza mavzusini mashq qiladi; blok ichida: namuna olish → '
        'tayyorlash/bo‘yash → sanash/o‘lchash → talqin/sifat nazorati → takrorlash.',
        '- d128–d142: avval SRB/RF/ASLO (d127 dan keyin), keyin gemostaz uchun namuna va koagulogramma, preanalitika '
        '(venoz qon, namuna xatolari), biologik xavfsizlik, ichki sifat nazorati (bosqichlar, Levey–Jennings/Westgard — ilovaning '
        '«Sifat nazorati» bo‘limida), so‘ng yakuniy takrorlash va attestatsiyaga tayyorgarlik.',
        '- Har kun faqat ilovadagi manbali kontentga bog‘langan: 27 ta amaliy protokol (`links.protocols`; `id#1-4` — protokolning '
        'shu slaydlari), analit kartalari, lab bo‘limlari (`/lab/...`), atlas, jadvallar. Yangi tibbiy matn qo‘shilmagan.',
        '- «Reja manbasi» ustuni — kunning mavzusi va o‘rni asoslangan darslik bob/bo‘lim/sahifa (protokollarda avval '
        'tekshirilgan joylar; «mundarija bo‘yicha» — sahifa kitob mundarijasidan, Drive matn nusxasida shu bob matni yo‘q).', '',
        '| Kun | Blok | Mavzu (uz) | Bog‘langan kontent | Reja manbasi | Asos |', '|---|---|---|---|---|---|']
    for d in plan['days']:
        t = by_id[d['id'] + '-P']
        links = [protocol_label(s, protos) for s in d['protocols']]
        links += [f'analit `{a}`' for a in d['analytes']]
        links += [f'holat `{c}`' for c in d.get('conditions', [])]
        links += [f'jadval `{r}`' for r in d['reference']]
        links += [f'atlas `{m}`' for m in d['microscopy']]
        links += [f'`{x}`' for x in d['tools']]
        tc = t['test_candidates']
        links.append(f'toifa `{d["toifa_topic"]}` (test {tc["count"]}, paket {tc["pack_quiz_count"]}, '
                     f'og‘zaki {t["oral_candidates"]["count"]})')
        refs = '; '.join(f'{book_short(r, practice, pack)} — {loc(r)}' for r in d['plan_refs'])
        md.append(f'| {d["id"]} | {d["block"]} | {d["title"]["uz"]} | {"<br>".join(links)} | {refs} | {d["why"]} |')
    md += ['', '### Bloklar', '']
    for b in plan['blocks']:
        days = [d['id'] for d in plan['days'] if d['block'] == b['id']]
        md.append(f'- **{b["id"]}** — {b["uz"]}: {days[0]}–{days[-1]} ({len(days)} kun)')
    md += ['', '### Cheklovlar', '',
           '- LDG va ishqoriy fosfataza, SRB/RF/ASLO va koagulogramma uchun ilovada alohida amaliy protokol yo‘q: bu kunlar '
           'analit kartalari (MedlinePlus/WHO/CDC manbali) va mos protokol slaydi (zardob tayyorlash, EChT, gemostaz uchun qon '
           'olish) bilan bog‘langan. Kurbonova (2023) ning 9–12-boblari Drive matn nusxasida yo‘q (matn 80-betda tugaydi) — '
           'bu boblar uchun sahifa mundarijadan olingan va shunday belgilangan.',
           '- Takrorlash kunlari (d138–d141) yangi kontent emas: tegishli protokollarning hisoblash/xatolik/sifat nazorati '
           'slaydlari.',
           '- Reja tavsiya: ustoz guruh jadvaliga moslab o‘zgartirishi mumkin; manbada kunma-kun mavzu paydo bo‘lsa, '
           '`m9_plan.json` o‘sha manbaga moslab yangilanadi va `plan_source` o‘zgartiriladi.', '']
    text = '\n'.join(md)
    if check:
        old = open(DOC, encoding='utf-8').read() if os.path.exists(DOC) else None
        return old != text
    with open(DOC, 'w', encoding='utf-8') as f:
        f.write(text)
    return True


def dumps(cur):
    return json.dumps(cur, ensure_ascii=False, indent=1)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--check', action='store_true')
    a = ap.parse_args(argv)
    plan, practice, pack = load(PLAN), load(PRACTICE), load(PACK)
    errs = validate(plan, practice, pack)
    if errs:
        raise SystemExit('m9_plan.json xatolari:\n  ' + '\n  '.join(errs))
    raw = open(CUR, encoding='utf-8').read()
    cur = json.loads(raw)
    cur = apply(plan, cur, pack, load(TESTS)['questions'], load(ORAL)['questions'])
    text = dumps(cur)
    if a.check:
        stale = text != raw
        stale_doc = write_doc(plan, cur, practice, pack, check=True)
        if stale or stale_doc:
            print('Eskirgan: python3 tool/curriculum/apply_m9_plan.py')
            sys.exit(1)
        print('Hammasi dolzarb.')
        return
    with open(CUR, 'w', encoding='utf-8') as f:
        f.write(text)
    write_doc(plan, cur, practice, pack)
    print(f'yozildi: {len(plan["days"])} kun; {os.path.relpath(DOC, REPO)}')


if __name__ == '__main__':
    main()
