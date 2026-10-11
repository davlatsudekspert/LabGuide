# 1-mavzu (M1, d001): ustoz bilan sinash uchun taqdimot qoralamasi.
# Ishlatish: python3 tool/slides/make_m1.py chiqish.pptx  (python-pptx kerak)
# Mazmun toifa og'zaki rejalari kdl-o-006/007/037 va JSST manbalaridan;
# tasdiqlanmagan — ustoz tekshiradi.
import os
import sys
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR

INK = RGBColor(0x18, 0x3A, 0x36)
BG = RGBColor(0xF4, 0xF2, 0xEC)
SOFT = RGBColor(0xE6, 0xEC, 0xDD)
MUTED = RGBColor(0x53, 0x6C, 0x65)
ACC = RGBColor(0xC2, 0x7A, 0x2C)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
LOGO = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'images', 'logo_mark.png')
FONT = 'Inter'

prs = Presentation()
prs.slide_width, prs.slide_height = Inches(13.333), Inches(7.5)
W, H = prs.slide_width, prs.slide_height
blank = prs.slide_layouts[6]
total = []


def fill(shape, color):
    shape.fill.solid(); shape.fill.fore_color.rgb = color; shape.line.fill.background()


def text(slide, x, y, w, h, s, size=20, color=INK, bold=False, align=PP_ALIGN.LEFT, anchor=MSO_ANCHOR.TOP):
    tb = slide.shapes.add_textbox(x, y, w, h); tf = tb.text_frame; tf.word_wrap = True
    tf.vertical_anchor = anchor
    tf.margin_left = tf.margin_right = 0
    lines = s if isinstance(s, list) else [s]
    for i, line in enumerate(lines):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.alignment = align
        r = p.add_run(); r.text = line
        r.font.size = Pt(size); r.font.bold = bold; r.font.color.rgb = color; r.font.name = FONT
    return tb


def base(slide, num=True):
    bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, W, H); fill(bg, BG)
    slide.shapes.add_picture(LOGO, Inches(0.6), Inches(0.42), height=Inches(0.42))
    text(slide, Inches(1.12), Inches(0.44), Inches(6), Inches(0.4),
         'LabGuide · 1-mavzu', 13, MUTED, True)
    if num:
        text(slide, Inches(10.2), Inches(6.92), Inches(2.5), Inches(0.35),
             f'{len(prs.slides)}', 12, MUTED, align=PP_ALIGN.RIGHT)
        text(slide, Inches(0.6), Inches(6.92), Inches(9), Inches(0.35),
             'Ustoz tekshiruvi uchun qoralama · LabGuide', 11, MUTED)


def notes(slide, s):
    slide.notes_slide.notes_text_frame.text = s


def title_slide():
    s = prs.slides.add_slide(blank)
    bg = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, W, H); fill(bg, INK)
    band = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, Inches(6.6), W, Inches(0.9)); fill(band, RGBColor(0x12, 0x2D, 0x2A))
    s.shapes.add_picture(LOGO, Inches(0.8), Inches(0.8), height=Inches(0.8))
    text(s, Inches(1.8), Inches(0.92), Inches(8), Inches(0.6), 'LabGuide', 26, WHITE, True)
    text(s, Inches(0.8), Inches(2.0), Inches(11.5), Inches(0.5),
         'KLINIK LABORATOR DIAGNOSTIKA · 1-MODUL · 1-MAVZU', 15, RGBColor(0xC9, 0xD8, 0xC2), True)
    text(s, Inches(0.8), Inches(2.6), Inches(11.8), Inches(2.2),
         ['Laborator xizmatni tashkillashtirish.', 'Tibbiy etika va deontologiya'], 44, WHITE, True)
    text(s, Inches(0.8), Inches(4.75), Inches(11.5), Inches(0.9),
         'Amaliy mashg‘ulot (4 soat) + Ma’naviyat darsi (2 soat)', 20, RGBColor(0xDD, 0xE6, 0xD8))
    text(s, Inches(0.8), Inches(6.8), Inches(11.8), Inches(0.5),
         'Ustoz tekshiruvi uchun qoralama — dars oldidan mazmunni ko‘rib chiqing', 14, RGBColor(0xC9, 0xD8, 0xC2))
    notes(s, 'Kirish. Dars rejasi: laboratoriya xizmati tuzilishi, sifat tizimi, xavfsizlik, etika va deontologiya. '
             'Oxirida og‘zaki savollar (toifa banki: kdl-o-006, kdl-o-007, kdl-o-037).')


def section(n, t, sub):
    s = prs.slides.add_slide(blank)
    bg = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, W, H); fill(bg, INK)
    text(s, Inches(0.8), Inches(2.3), Inches(3), Inches(1.4), f'{n:02d}', 80, ACC, True)
    text(s, Inches(0.8), Inches(3.75), Inches(11.5), Inches(1.0), t, 38, WHITE, True)
    text(s, Inches(0.8), Inches(4.75), Inches(11.5), Inches(0.8), sub, 20, RGBColor(0xC9, 0xD8, 0xC2))
    return s


def bullets(t, items, note='', foot=None):
    s = prs.slides.add_slide(blank); base(s)
    text(s, Inches(0.6), Inches(1.05), Inches(12.1), Inches(0.9), t, 32, INK, True)
    tb = s.shapes.add_textbox(Inches(0.6), Inches(2.0), Inches(12.1), Inches(4.5))
    tf = tb.text_frame; tf.word_wrap = True
    for i, it in enumerate(items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.space_after = Pt(10)
        head, _, rest = it.partition(' — ')
        r = p.add_run(); r.text = '●  '; r.font.size = Pt(14); r.font.color.rgb = ACC; r.font.name = FONT
        r = p.add_run(); r.text = head; r.font.size = Pt(22); r.font.bold = bool(rest); r.font.color.rgb = INK; r.font.name = FONT
        if rest:
            r = p.add_run(); r.text = ' — ' + rest; r.font.size = Pt(22); r.font.color.rgb = INK; r.font.name = FONT
    if foot:
        text(s, Inches(0.6), Inches(6.45), Inches(12.1), Inches(0.4), foot, 12, MUTED)
    notes(s, note)
    return s


def cards(t, items, cols=3, note='', foot=None):
    s = prs.slides.add_slide(blank); base(s)
    text(s, Inches(0.6), Inches(1.05), Inches(12.1), Inches(0.9), t, 32, INK, True)
    rows = (len(items) + cols - 1) // cols
    gap = Inches(0.25)
    cw = (Inches(12.13) - gap * (cols - 1)) / cols
    top = Inches(2.05); avail = Inches(4.3)
    ch = (avail - gap * (rows - 1)) / rows
    for i, (h, b) in enumerate(items):
        r, c = divmod(i, cols)
        x = Inches(0.6) + (cw + gap) * c; y = top + (ch + gap) * r
        box = s.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, int(x), int(y), int(cw), int(ch)); fill(box, SOFT)
        box.adjustments[0] = 0.08
        text(s, int(x + Inches(0.25)), int(y + Inches(0.18)), int(cw - Inches(0.5)), Inches(0.5), h, (16 if cols > 3 else 20) if rows > 1 else 22, INK, True)
        text(s, int(x + Inches(0.25)), int(y + Inches(0.62 if cols > 3 else 0.72)), int(cw - Inches(0.5)), int(ch - Inches(0.8)), b, (14 if cols > 3 else 17) if rows > 1 else 19, MUTED)
    if foot:
        text(s, Inches(0.6), Inches(6.45), Inches(12.1), Inches(0.4), foot, 12, MUTED)
    notes(s, note)
    return s


def flow(t, steps, note='', foot=None):
    s = prs.slides.add_slide(blank); base(s)
    text(s, Inches(0.6), Inches(1.05), Inches(12.1), Inches(0.9), t, 32, INK, True)
    n = len(steps); gap = Inches(0.35)
    cw = (Inches(12.13) - gap * (n - 1)) / n
    for i, (h, b) in enumerate(steps):
        x = Inches(0.6) + (cw + gap) * i
        box = s.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, int(x), Inches(2.3), int(cw), Inches(3.6))
        fill(box, INK if i == 1 else SOFT); box.adjustments[0] = 0.06
        col = WHITE if i == 1 else INK
        text(s, int(x + Inches(0.3)), Inches(2.5), int(cw - Inches(0.6)), Inches(0.5), f'{i+1}-bosqich', 14, ACC, True)
        text(s, int(x + Inches(0.3)), Inches(2.95), int(cw - Inches(0.6)), Inches(0.7), h, 24, col, True)
        text(s, int(x + Inches(0.3)), Inches(3.75), int(cw - Inches(0.6)), Inches(2.1), b, 15, WHITE if i == 1 else MUTED)
        if i < n - 1:
            a = s.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, int(x + cw + Inches(0.04)), Inches(3.9), Inches(0.27), Inches(0.35)); fill(a, ACC)
    if foot:
        text(s, Inches(0.6), Inches(6.2), Inches(12.1), Inches(0.6), foot, 14, MUTED)
    notes(s, note)
    return s


# ---------------- slides ----------------
title_slide()

bullets('Dars maqsadi va rejasi', [
    'Laboratoriya xizmati — tuzilishi, vazifalari va tahlil jarayonining bosqichlari',
    'Sifat tizimi — JSST LQMS ning 12 ta asosiy elementi, ISO 15189',
    'Xavfsizlik — umumiy, yong‘in, elektr va biologik xavfsizlik',
    'Tibbiy etika va deontologiya — tamoyillar, konfidensiallik, halollik',
    'Ma’naviyat darsi — kasbiy burch, jamoa, bemor oldidagi mas’uliyat',
    'Yakun — og‘zaki savollar va amaliy vaziyatlar',
], 'Talabalar dars oxirida: tahlil jarayoni bosqichlarini, sifat tizimi elementlarini, '
   'asosiy xavfsizlik qoidalarini va etika tamoyillarini aytib bera olishi kerak.')

section(1, 'Laborator xizmatni tashkillashtirish', 'Laboratoriya — tashxis jarayonining ajralmas qismi')

cards('Klinik laboratoriyaning vazifalari', [
    ('Tashxis', 'Kasallikni aniqlash va tasdiqlash uchun ishonchli natija berish'),
    ('Monitoring', 'Davolash samarasini va kasallik kechishini kuzatish'),
    ('Skrining va profilaktika', 'Yashirin kasalliklarni erta aniqlash, xavf omillarini baholash'),
    ('Shoshilinch yordam', 'Kritik natijalarni o‘z vaqtida shifokorga yetkazish'),
    ('Sifat va xavfsizlik', 'Natijalarning aniqligi, xodim va bemor xavfsizligi'),
    ('Ta’lim va ilm', 'Xodimlarni o‘qitish, yangi metodlarni joriy etish'),
], 3, 'Laboratoriya natijasi ko‘plab klinik qarorlarga asos bo‘ladi — shuning uchun xato narxi yuqori. '
      'Misol: kaliy natijasi noto‘g‘ri bo‘lsa (gemoliz), noto‘g‘ri davolash boshlanishi mumkin.')

flow('Tahlil jarayoni: uch bosqich', [
    ('Preanalitik', 'Tahlil buyurtmasi, bemorni tayyorlash, namuna olish, belgilash, tashish, saqlash, qabul qilish'),
    ('Analitik', 'O‘lchash, kalibrlash, ichki sifat nazorati (QC), uskunaga xizmat'),
    ('Postanalitik', 'Natijani tekshirish va tasdiqlash, hisobot, kritik qiymatni xabar qilish, namunani saqlash'),
], 'Adabiyotda laboratoriya xatolarining eng katta qismi preanalitik bosqichga to‘g‘ri kelishi '
   'ko‘rsatilgan (taxminan 60–70 %; Plebani M., Clin Chem Lab Med 2006). '
   'Ilovada: Lab → Preanalitika bo‘limi (namuna olish tartibi, JSST).',
   'Xatolarning katta qismi preanalitik bosqichda yuzaga keladi (Plebani, 2006) — laborant ishi shu yerdan boshlanadi.')

cards('Sifat tizimi — JSST LQMS ning 12 ta elementi', [
    ('Tashkilot', 'Tuzilma, rahbariyat majburiyati'),
    ('Xodimlar', 'Malaka, o‘qitish, kompetensiya'),
    ('Uskunalar', 'Tanlash, kalibrlash, xizmat'),
    ('Xarid va zaxira', 'Reagentlar, yaroqlilik muddati'),
    ('Jarayon nazorati', 'QC, namuna bilan ishlash'),
    ('Axborot', 'Natija, hisobot, maxfiylik'),
    ('Hujjatlar', 'SOP, jurnallar, yozuvlar'),
    ('Hodisalar', 'Xatolarni qayd etish, tahlil'),
    ('Baholash', 'Ichki/tashqi audit, EQA'),
    ('Yaxshilash', 'Tuzatuvchi choralar'),
    ('Mijozga xizmat', 'Shifokor va bemor fikri'),
    ('Bino, xavfsizlik', 'Joylashuv, himoya'),
], 4, 'Manba: WHO. Laboratory Quality Management System: Handbook. 2011. '
      'Xalqaro standart: ISO 15189:2022 — tibbiy laboratoriyalar sifati va kompetensiyasi.',
   'Manba: WHO Laboratory Quality Management System Handbook (2011); ISO 15189:2022')

bullets('Hujjatlar va yozuvlar', [
    'SOP (standart operatsion tartib) — har bir tahlil va jarayon uchun yozma, tasdiqlangan, ish joyida mavjud',
    'Jurnallar — QC natijalari, uskuna xizmati, harorat (muzlatgich/termostat), reagent lotlari',
    'Kuzatuvchanlik — “kim, qachon, qaysi uskuna va reagent bilan” savoliga javob topilishi kerak',
    'Hodisalar — xato va nomuvofiqliklar yashirilmaydi, qayd etiladi va tahlil qilinadi',
    'Qoida — “Yozilmagan ish — bajarilmagan ish”',
], 'Amaliy topshiriq: guruh bitta oddiy tahlil (masalan, glyukoza) uchun SOP tuzilmasini yozib chiqsin: '
   'maqsad, namuna, reagent, uskuna, QC, hisoblash, referens oraliq, xavfsizlik.')

section(2, 'Laboratoriya xavfsizligi', 'Xodim, bemor va atrof-muhitni himoya qilish')

cards('Umumiy xavfsizlik tizimi', [
    ('Tashkiliy', 'Yozma xavfsizlik rejasi va SOP, mas’ul shaxs, ish boshlashda va davriy o‘qitish, favqulodda vaziyat mashqlari'),
    ('Elektr', 'Shikastlangan rozetka/uskuna belgilanib ishdan chiqariladi; nam qo‘l bilan ulash taqiqlanadi; ta’mirda tokdan ajratish (lockout/tagout)'),
    ('Yong‘in', 'Yonuvchi erituvchilar minimal miqdorda, maxsus shkafda; ochiq olov nazoratsiz qoldirilmaydi; yo‘laklar ochiq'),
], 3, 'Toifa og‘zaki savoli kdl-o-006 rejasi asosida. Har bir xodim avariya jihozlari joyini bilishi kerak: '
      'o‘t o‘chirgich, signal, chiqish yo‘llari, avariya dushi/ko‘z yuvgich, birinchi yordam qutisi.')

cards('Yong‘in chiqqanda: RACE va PASS', [
    ('RACE — harakat tartibi', 'Rescue — odamlarni olib chiqish\nAlarm — signalni yoqish\nConfine — eshiklarni yopib olovni cheklash\nEvacuate/Extinguish — evakuatsiya yoki o‘chirish'),
    ('PASS — o‘t o‘chirgich', 'Pull — chekani tortish\nAim — olov asosiga yo‘naltirish\nSqueeze — richagni bosish\nSweep — yonma-yon purkash'),
    ('O‘t o‘chirgich sinfi', 'A — qattiq yonuvchilar\nB — yonuvchi suyuqlik/gazlar\nC — tok ostidagi uskunalar (elektr o‘tkazmaydigan vosita)\nKiyim yonsa — “to‘xta, yot, dumala”'),
], 3, 'kdl-o-006. Amaliy mashq: talabalar laboratoriyadagi o‘t o‘chirgich, avariya dushi va chiqish yo‘lini ko‘rsatib bersin.')

bullets('Biologik xavfsizlik (1): asoslar', [
    'Asos — har bir ish uchun xavfni baholash: ma’lumot → baholash → nazorat strategiyasi → choralar → qayta ko‘rish',
    'BSL darajalari — qon, tana suyuqliklari va to‘qimalar bilan ish odatda BSL-2 sharoitida',
    'Taqiqlanadi — ovqatlanish, ichish, chekish, kosmetika; og‘iz bilan pipetkalash (faqat mexanik dozator)',
], 'kdl-o-007 rejasi; manba: WHO Laboratory Biosafety Manual, 4th ed. (2020). '
   'BSL-1 — sog‘lom kattalarda kasallik chaqirmaydigan agentlar; BSL-2 — HBV, OIV, Salmonella va h.k.; BSL-3/4 — havo orqali yuqadigan og‘ir agentlar.',
   'Manba: WHO Laboratory Biosafety Manual, 4-nashr (2020)')

bullets('Biologik xavfsizlik (2): amaliyot', [
    'SHHV — xalat, qo‘lqop (lab tashqarisida kiyilmaydi, qayta ishlatilmaydi), sachrash xavfida ko‘z/yuz himoyasi',
    'O‘tkir buyumlar — igna qopqog‘i qayta kiydirilmaydi; darhol teshilmaydigan konteynerga',
    'Aerozol — sentrifugalash va ochish yopiq stakanlarda yoki biologik xavfsizlik shkafida',
    'Chiqindilar — yuqumli material yo‘q qilishdan oldin zararsizlantiriladi (afzali avtoklav), biohazard belgisi bilan',
], 'kdl-o-007. Dekontaminatsiya: ish yuzalari ish oxirida va har to‘kilishdan keyin dezinfeksiya qilinadi.',
   'Manba: WHO Laboratory Biosafety Manual, 4-nashr (2020)')

flow('Igna sanchilsa yoki qon shilliq qavatga tushsa', [
    ('Darhol', 'Teri — oqar suv va sovun bilan yuvish; ko‘z/shilliq qavat — ko‘p suv bilan chayish'),
    ('Xabar berish', 'Rahbarga darhol xabar berish, hodisani qayd etish'),
    ('Profilaktika', 'Muassasa tartibi bo‘yicha ekspozitsiyadan keyingi baholash va profilaktika — imkon qadar tezroq'),
], 'kdl-o-007: xodimlar salomatligi — kasbiy sog‘liq talablari (jumladan, emlash), ekspozitsiyadan keyingi profilaktika tartibi. '
   'Aniq dori va muddatlar muassasa protokoli va amaldagi milliy ko‘rsatmaga ko‘ra — ustoz mahalliy tartibni aytib o‘tsin.',
   'Har bir laboratoriyada ekspozitsiyadan keyingi tartib yozma bo‘lishi va xodimlarga ma’lum bo‘lishi kerak.')

section(3, 'Tibbiy etika va deontologiya', 'Kasbiy burch va xulq-atvor')

cards('Tushunchalar va asosiy tamoyillar', [
    ('Tibbiy etika', 'Tibbiyot xodimining bemor, hamkasblar va jamiyatga munosabatidagi axloqiy tamoyillar'),
    ('Deontologiya', 'Kasbiy burch va xulq-atvor qoidalari haqidagi ta’limot'),
    ('Bemor manfaati', 'Bemor manfaatini ustun qo‘yish, zarar yetkazmaslik'),
    ('Avtonomiya', 'Bemor huquqi va ixtiyoriy xabardor rozilik'),
    ('Kamsitmaslik', 'Xizmat faqat tibbiy ehtiyojga qarab ko‘rsatiladi'),
    ('Adolat', 'Har bir bemorga bir xil sifat va e’tibor'),
], 3, 'kdl-o-037 rejasi asosida.')

bullets('Laboratoriyada konfidensiallik', [
    'Tibbiy sir — tahlil natijalari va bemor ma’lumotlari faqat vakolatli shaxslarga beriladi',
    'Muddatsiz — bu majburiyat bemor vafotidan keyin ham saqlanadi',
    'Telefon — natija telefon orqali begonaga aytilmaydi',
    'Blankalar — ochiq qoldirilmaydi, ekranlar qulflanadi',
    'Elektron tizim — kirish faqat shaxsiy login bilan, parol hech kimga berilmaydi',
    'Ijtimoiy tarmoq — bemor natijasi yoki namunasi suratini joylash taqiqlanadi',
], 'Muhokama: “Qo‘shnim mendan tanishining OIV tahlili natijasini so‘radi” — laborant qanday javob beradi?')

cards('Kasbiy halollik va javobgarlik', [
    ('Kompetensiya', 'Doimiy o‘qish va malaka oshirish; bilmagan metodni mustaqil bajarmaslik'),
    ('Halollik', 'Xato yashirilmaydi — qayd etiladi va tuzatiladi. Natijani “to‘g‘rilab” yozish taqiqlanadi'),
    ('Kritik natija', 'Hayot uchun xavfli qiymat darhol shifokorga yetkaziladi va qayd etiladi'),
    ('Hamkasblar', 'Hurmat va aniq kommunikatsiya: laborant–shifokor–hamshira; bemor oldida hamkasb tanqid qilinmaydi'),
], 2, 'kdl-o-037. O‘zbekistonda tibbiyot xodimlarining odob-axloq kodeksi SSV ning 2022-yil 24-martdagi 88-son buyrug‘i bilan '
      'tasdiqlangan — ustoz matnini lex.uz da tekshirib, asosiy talablarini o‘qib bersin.',
   'O‘zbekiston: tibbiyot xodimlari odob-axloq kodeksi (SSV, 2022, 88-son buyruq) — matnini lex.uz da tekshiring')

section(4, 'Ma’naviyat darsi', 'Kasb — bu mas’uliyat')

bullets('Laborant — ko‘rinmas, lekin hal qiluvchi', [
    'Har bir probirka ortida — inson: bola, ona, keksa bemor',
    'Aniqlik — bu g‘amxo‘rlik: to‘g‘ri belgilangan namuna bemor hayotini saqlaydi',
    'Jamoa — laboratoriya, klinika va bemor o‘rtasidagi ishonch',
    'O‘qishdan to‘xtamaslik — tibbiyot har yili yangilanadi',
    'Halollik — “Bilmayman, aniqlab beraman” deyish kasbiy jasorat',
], 'Ustoz o‘z tajribasidan bitta voqea aytib berishi tavsiya etiladi. Talabalar bilan muhokama: “Nega men bu kasbni tanladim?”')

bullets('Amaliy vaziyatlar (muhokama)', [
    '1 — Namuna belgisiz keldi. Nima qilasiz?',
    '2 — Kaliy 7,2 mmol/L chiqdi, namuna gemolizlangan. Natijani berasizmi?',
    '3 — Hamkasbingiz QC “chiqib ketdi”, lekin bemor natijalarini baribir yubormoqchi.',
    '4 — Qo‘lingizga igna sanchildi. Birinchi 3 ta harakatingiz?',
    '5 — Bemorning qarindoshi natijani telefon orqali so‘radi.',
], 'Kutilgan javoblar: 1) qabul qilinmaydi, qayta olish so‘raladi, hodisa qayd etiladi; '
   '2) gemoliz kaliyni soxta oshiradi — natija izoh bilan yoki namuna qayta olinadi, shifokorga xabar; '
   '3) QC talablariga javob bermaguncha bemor natijasi chiqarilmaydi — sabab topiladi, tuzatiladi; '
   '4) yuvish, rahbarga xabar, ekspozitsiyadan keyingi tartib; 5) vakolatsiz shaxsga natija berilmaydi.')

bullets('Nazorat savollari (toifa — og‘zaki)', [
    'kdl-o-006 — Laboratoriyada umumiy xavfsizlik tizimi, elektr va yong‘in xavfsizligi',
    'kdl-o-007 — Biologik xavfsizlik: xavfni baholash, BSL, SHHV, chiqindilar',
    'kdl-o-037 — Tibbiy etika va deontologiya, konfidensiallik',
    'Ilovada — O‘rganish → Toifa → Og‘zaki savollar: javob rejasi bilan',
], 'Savollar LabGuide toifa bankidan (rasmiy savollar). Javob rejalari ilovada mavjud.')

s = prs.slides.add_slide(blank); base(s)
text(s, Inches(0.6), Inches(1.05), Inches(12.1), Inches(0.9), 'Manbalar', 32, INK, True)
text(s, Inches(0.6), Inches(2.0), Inches(12.1), Inches(4.3), [
    'WHO. Laboratory Quality Management System: Handbook. Geneva: WHO; 2011.',
    'WHO. Laboratory Biosafety Manual, 4th edition. Geneva: WHO; 2020.',
    'ISO 15189:2022. Medical laboratories — Requirements for quality and competence.',
    'Plebani M. Errors in clinical laboratories or errors in laboratory medicine? Clin Chem Lab Med. 2006;44(6):750–759.',
    'O‘zR SSV, 2022-yil 24-mart, 88-son buyruq — tibbiyot xodimlari odob-axloq kodeksi (matni: lex.uz).',
    'LabGuide toifa banki: kdl-o-006, kdl-o-007, kdl-o-037 (javob rejalari).',
], 17, INK)
notes(s, 'Taqdimot qoralama: ustoz mazmunni tekshirib, mahalliy tartiblarni (muassasa SOP, ekspozitsiyadan keyingi protokol) qo‘shishi kerak.')

prs.save(sys.argv[1] if len(sys.argv) > 1 else 'LabGuide_1-mavzu.pptx')
print(len(prs.slides), 'slayd')
