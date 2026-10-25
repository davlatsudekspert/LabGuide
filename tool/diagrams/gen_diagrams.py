#!/usr/bin/env python3
"""LabGuide jarayon sxemalari (6 mavzu x uz/ru/en) — ORIGINAL, repo ichida yaratilgan.

2026-10-25 da noldan chizilgan: eski (muallifi noma'lum) 18 ta rasmning maketi,
grafikasi va matni ishlatilmagan. Har bir da'vo manbasi:
docs/DIAGRAMS_CONTENT_SOURCES.md (manba yo'q joy — NEEDS_EXPERT).

    python3 tool/diagrams/gen_diagrams.py          # tool/diagrams/svg/<mavzu>.<til>.svg
    NODE_PATH=$(npm root -g) node tool/diagrams/render.cjs --quant
                                                    # assets/diagrams/<mavzu>.<til>.png (1920x1280)

Dizayn: 960x640 SVG (2x render = 1920x1280), shrift Inter (assets/fonts, OFL).
Eng kichik matn 28 birlik: 390 px telefonda (rasm 390 px kenglikka kichraysa)
~11.4 px. Har bir matn qatori Inter metrikalari bilan o'lchanadi; sig'masa,
skript xato beradi (jim kesilmaydi).
Palitra: lib/design/tokens.dart (LgPalette.light) va
tool/illustrations/schematic/gen.py bilan bir xil.
"""
import os
import pathlib
import sys
from xml.sax.saxutils import escape

from fontTools.ttLib import TTFont

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
OUT = HERE / "svg"
W, H = 960, 640
LANGS = ("uz", "ru", "en")

# ------------------------------------------------------------------ palitra
# LgPalette.light (lib/design/tokens.dart) + schematic gen.py ranglari.
PAPER = "#FFFEF9"
INK = "#183A36"
SUB = "#536C65"
LINE = "#E1E7DE"
BRAND = "#194C40"
SOFT = "#E9EFE1"
AMBER = "#7B4D0B"
AMBER_BG = "#FFF1DB"
DANGER = "#9A2B1F"
STEP_STROKE = "#B9C4BD"  # schematic LINE
ARROW = "#6F8479"
OK_BG = "#E2EEDC"
STOP_BG = "#FBE7E2"
DEC_STROKE = "#C08A2E"
SCREEN = "#1F5A4C"
LIQUID = "#F0D36B"

# ------------------------------------------------------------------ shrift
SIZE = 28  # asosiy matn (eng kichik)
LH = 32  # qator balandligi
TITLE = 36
DEBUG = bool(os.environ.get("DEBUG"))  # DEBUG=1 — har blok qatorlarini chiqaradi
FAMILY = "Inter, 'DejaVu Sans', Arial, sans-serif"


class Metrics:
    def __init__(self):
        self.fonts = {}
        for wt in (400, 500, 600, 700):
            f = TTFont(ROOT / "assets" / "fonts" / f"Inter-{wt}.ttf")
            self.fonts[wt] = (f.getBestCmap(), f["hmtx"].metrics, f["head"].unitsPerEm)

    def width(self, text, size=SIZE, weight=600):
        cmap, hmtx, upm = self.fonts[weight]
        total = 0
        for ch in text:
            g = cmap.get(ord(ch))
            if g is None:
                raise SystemExit(f"Inter-{weight} da glif yo'q: {ch!r} ({text!r})")
            total += hmtx[g][0]
        return total * size / upm


M = Metrics()


def wrap(text, maxw, size=SIZE, weight=600):
    """So'zlar bo'yicha qatorlarga bo'ladi; '\\n' — majburiy uzish."""
    lines = []
    for para in text.split("\n"):
        cur = ""
        for word in para.split(" "):
            cand = word if not cur else cur + " " + word
            if M.width(cand, size, weight) <= maxw:
                cur = cand
                continue
            if not cur:
                raise SystemExit(f"So'z sig'madi ({maxw:.0f}): {word!r} in {text!r}")
            lines.append(cur)
            cur = word
            if M.width(cur, size, weight) > maxw:
                raise SystemExit(f"So'z sig'madi ({maxw:.0f}): {word!r} in {text!r}")
        lines.append(cur)
    return lines


def text(x, y, s, size=SIZE, weight=600, fill=INK, anchor="start", extra=""):
    return (
        f'<text x="{x:.1f}" y="{y:.1f}" font-family="{FAMILY}" font-size="{size}" '
        f'font-weight="{weight}" fill="{fill}" text-anchor="{anchor}" {extra}>{escape(s)}</text>'
    )


def formula(x, y, parts, size=34, fill=INK, anchor="start"):
    """Formula: parts = [("A = log", False), ("10", True), ...]; True — pastki indeks."""
    sub = round(size * 0.72)  # indeks: 30-34 -> 22-24 birlik
    shift = round(size * 0.24)
    out, down = [], False
    for seg, is_sub in parts:
        if is_sub and not down:
            out.append(f'<tspan font-size="{sub}" dy="{shift}">{escape(seg)}</tspan>')
            down = True
        elif not is_sub and down:
            out.append(f'<tspan dy="{-shift}">{escape(seg)}</tspan>')
            down = False
        else:
            out.append(f"<tspan>{escape(seg)}</tspan>")
    return (
        f'<text x="{x:.1f}" y="{y:.1f}" font-family="{FAMILY}" font-size="{size}" font-weight="700" '
        f'fill="{fill}" text-anchor="{anchor}">{"".join(out)}</text>'
    )


# ------------------------------------------------------------------ belgilar
def marker_defs():
    out = ["<defs>"]
    for name, color in (("grey", ARROW), ("ok", BRAND), ("stop", DANGER), ("amber", DEC_STROKE)):
        out.append(
            f'<marker id="ah-{name}" viewBox="0 0 12 12" refX="10" refY="6" markerUnits="userSpaceOnUse" '
            f'markerWidth="18" markerHeight="18" orient="auto-start-reverse"><path d="M1 1.5 L11 6 L1 10.5 Z" fill="{color}"/></marker>'
        )
    out.append(
        '<linearGradient id="beam" x1="0" y1="0" x2="1" y2="0">'
        '<stop offset="0" stop-color="#F4C84A" stop-opacity="0.95"/>'
        '<stop offset="1" stop-color="#F4C84A" stop-opacity="0.55"/></linearGradient>'
    )
    out.append("</defs>")
    return "".join(out)


ARROW_COLOR = {"grey": ARROW, "ok": BRAND, "stop": DANGER, "amber": DEC_STROKE}


def arrow(points, kind="grey", sw=3.5):
    d = "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in points)
    return (
        f'<path d="{d}" fill="none" stroke="{ARROW_COLOR[kind]}" stroke-width="{sw}" '
        f'stroke-linecap="round" stroke-linejoin="round" marker-end="url(#ah-{kind})"/>'
    )


def chip(cx, cy, label, kind, align="center"):
    """Shoxobcha yorlig'i (Ha / Yo'q); align: center | left (cx — chap chet) | right."""
    color = {"ok": BRAND, "stop": DANGER, "grey": ARROW}[kind]
    w = M.width(label, SIZE, 700) + 28
    x0 = {"center": cx - w / 2, "left": cx, "right": cx - w}[align]
    return (
        f'<rect x="{x0:.1f}" y="{cy - 19:.1f}" width="{w:.1f}" height="38" rx="19" fill="{PAPER}" '
        f'stroke="{color}" stroke-width="2.5"/>' + text(x0 + w / 2, cy + 10, label, 28, 700, color, "middle")
    )


def badge(kind, cx, cy, label=None):
    if kind == "num":
        return (
            f'<circle cx="{cx}" cy="{cy}" r="21" fill="{BRAND}"/>'
            + text(cx, cy + 10, label, 28, 700, "#FFFFFF", "middle")
        )
    if kind == "decision":
        r = 22
        return (
            f'<path d="M{cx} {cy - r} L{cx + r} {cy} L{cx} {cy + r} L{cx - r} {cy} Z" fill="{DEC_STROKE}"/>'
            + text(cx, cy + 10, "?", 28, 700, "#FFFFFF", "middle")
        )
    if kind == "ok":
        return (
            f'<circle cx="{cx}" cy="{cy}" r="21" fill="{BRAND}"/>'
            f'<path d="M{cx - 10} {cy + 1} L{cx - 3} {cy + 8} L{cx + 10} {cy - 7}" fill="none" stroke="#FFFFFF" '
            'stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>'
        )
    if kind == "stop":
        return (
            f'<circle cx="{cx}" cy="{cy}" r="21" fill="{DANGER}"/>'
            f'<rect x="{cx - 11}" y="{cy - 3}" width="22" height="6" rx="2" fill="#FFFFFF"/>'
        )
    if kind == "info":
        return (
            f'<circle cx="{cx}" cy="{cy}" r="21" fill="{SUB}"/>'
            f'<circle cx="{cx}" cy="{cy - 9}" r="3.2" fill="#FFFFFF"/>'
            f'<rect x="{cx - 2.6}" y="{cy - 3}" width="5.2" height="15" rx="2" fill="#FFFFFF"/>'
        )
    raise ValueError(kind)


STYLE = {
    # kind: (fill, stroke, title colour)
    "step": ("#FFFFFF", STEP_STROKE, INK),
    "decision": (AMBER_BG, DEC_STROKE, AMBER),
    "ok": (OK_BG, BRAND, BRAND),
    "stop": (STOP_BG, DANGER, DANGER),
    "info": (SOFT, None, INK),
}


class Node:
    """Bitta blok: sarlavha (600) + ixtiyoriy izoh (400, kulrang)."""

    PAD_Y = 10

    def __init__(self, kind, title, detail=None, num=None, w=420, center=False, compact=False):
        self.kind, self.title, self.detail, self.num, self.w = kind, title, detail, num, w
        self.center, self.compact = center, compact
        self.has_badge = num is not None or kind in ("decision", "ok", "stop")
        self.tx = (44 if compact else 58) if self.has_badge else 20
        maxw = w - self.tx - 10
        self.tl = wrap(title, maxw, SIZE, 600)
        self.dl = wrap(detail, maxw, SIZE, 400) if detail else []
        self.h = self.PAD_Y * 2 + (len(self.tl) + len(self.dl)) * LH
        if DEBUG:
            print(f"   [{kind}] h={self.h} {self.tl + self.dl}")
        self.x = self.y = 0

    @property
    def cx(self):
        return self.x + self.w / 2

    @property
    def bottom(self):
        return self.y + self.h

    def svg(self):
        fill, stroke, tcolor = STYLE[self.kind]
        st = f' stroke="{stroke}" stroke-width="2.5"' if stroke else ""
        s = f'<rect x="{self.x:.1f}" y="{self.y:.1f}" width="{self.w:.1f}" height="{self.h:.1f}" rx="16" fill="{fill}"{st}/>'
        if self.has_badge:
            by = self.y + self.h / 2 if len(self.tl) + len(self.dl) <= 2 else self.y + self.PAD_Y + LH / 2 + 4
            bk = "num" if self.num is not None else self.kind
            bs = badge(bk, self.x + (24 if self.compact else 30), by, str(self.num) if self.num is not None else None)
            if self.compact:  # kichik belgi: 0.72 masshtab
                cx, cy = self.x + 24, by
                bs = f'<g transform="translate({cx:.1f} {cy:.1f}) scale(0.72) translate({-cx:.1f} {-cy:.1f})">{bs}</g>'
            s += bs
        y = self.y + self.PAD_Y + 24
        if self.center:
            tx, anchor = self.x + self.tx + (self.w - self.tx - 14) / 2, "middle"
        else:
            tx, anchor = self.x + self.tx, "start"
        for ln in self.tl:
            s += text(tx, y, ln, SIZE, 600, tcolor, anchor)
            y += LH
        for ln in self.dl:
            s += text(tx, y, ln, SIZE, 400, SUB, anchor)
            y += LH
        return s


def stack(nodes, x, top, bottom, min_gap=28, max_gap=46, valign="center"):
    """Bloklarni ustun qilib joylaydi; sig'masa — xato.

    min_gap — son yoki har oraliq uchun ro'yxat (yorliq turadigan oraliq kattaroq).
    """
    k = len(nodes) - 1
    mins = list(min_gap) if isinstance(min_gap, (list, tuple)) else [min_gap] * k
    total = sum(n.h for n in nodes)
    room = bottom - top - total - sum(mins)
    if room < 0:
        raise SystemExit(f"Ustun sig'madi: {-room:.0f} birlik ortiqcha — {[n.title for n in nodes]}")
    extra = min(max_gap - min(mins), room / k) if k else 0
    extra = max(extra, 0)
    gaps = [m + extra for m in mins]
    used = total + sum(gaps)
    y = top + ((bottom - top - used) / 2 if valign == "center" else 0)
    for i, n in enumerate(nodes):
        n.x, n.y = x, y
        y += n.h + (gaps[i] if i < k else 0)
    return gaps


def link_down(a, b, kind="grey", label=None, x=None):
    """Pastga o'q; yorliq o'qning o'ng tomonida."""
    x = a.cx if x is None else x
    s = arrow([(x, a.bottom + 2), (x, b.y - 3)], kind)
    if label:
        s += chip(x + 14, (a.bottom + b.y) / 2, label, kind, align="left")
    return s


# ------------------------------------------------------------------ ramka
def header_icon(name, x, y):
    """52x52 plitka ichida oq chiziqli belgi (original)."""
    s = f'<rect x="{x}" y="{y}" width="52" height="52" rx="14" fill="{BRAND}"/>'
    c = 'fill="none" stroke="#FFFFFF" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"'
    ox, oy = x + 26, y + 26
    if name == "qc":
        s += f'<path d="M{ox - 15} {oy - 12} H{ox + 15} M{ox - 15} {oy + 12} H{ox + 15}" {c} stroke-dasharray="3 5" opacity="0.7"/>'
        s += f'<path d="M{ox - 16} {oy + 4} L{ox - 8} {oy - 6} L{ox} {oy + 3} L{ox + 8} {oy - 9} L{ox + 16} {oy}" {c}/>'
    elif name == "calibration":
        s += f'<circle cx="{ox}" cy="{oy}" r="14" {c}/><circle cx="{ox}" cy="{oy}" r="5" {c}/>'
        s += f'<path d="M{ox} {oy - 20} V{oy - 15} M{ox} {oy + 15} V{oy + 20} M{ox - 20} {oy} H{ox - 15} M{ox + 15} {oy} H{ox + 20}" {c}/>'
    elif name == "differential":
        s += f'<circle cx="{ox}" cy="{oy}" r="16" {c}/>'
        s += f'<path d="M{ox - 8} {oy - 3} q4 -8 8 -2 q4 -7 8 2 q-1 8 -8 6 q-7 3 -8 -6 Z" fill="#FFFFFF" opacity="0.9"/>'
    elif name == "photometry":
        s += f'<path d="M{ox - 18} {oy} H{ox - 7} M{ox + 7} {oy} H{ox + 18}" {c}/>'
        s += f'<rect x="{ox - 7}" y="{oy - 12}" width="14" height="24" rx="2" {c}/>'
        s += f'<path d="M{ox + 12} {oy - 5} L{ox + 18} {oy} L{ox + 12} {oy + 5}" {c}/>'
    elif name == "preanalytics":
        s += f'<path d="M{ox - 6} {oy - 17} V{oy + 11} a6 6 0 0 0 12 0 V{oy - 17}" {c}/>'
        s += f'<path d="M{ox - 10} {oy - 17} H{ox + 10}" {c}/><path d="M{ox - 6} {oy + 1} H{ox + 6}" {c}/>'
    elif name == "learn":
        s += f'<path d="M{ox + 13} {oy - 8} A15 15 0 1 0 {ox + 15} {oy + 4}" {c}/>'
        s += f'<path d="M{ox + 15} {oy - 16} L{ox + 14} {oy - 7} L{ox + 5} {oy - 8}" {c}/>'
        s += f'<path d="M{ox - 6} {oy} L{ox - 1} {oy + 5} L{ox + 7} {oy - 4}" {c}/>'
    return s


def frame(icon, title, footer, body):
    tl = wrap(title, W - 92 - 24, TITLE, 700)
    if len(tl) != 1:
        raise SystemExit(f"Sarlavha bir qatorga sig'madi: {title!r}")
    fl = wrap(footer, W - 70 - 16, SIZE, 500)
    if len(fl) != 1:
        raise SystemExit(f"Pastki yozuv bir qatorga sig'madi: {footer!r}")
    s = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">',
        marker_defs(),
        f'<rect width="{W}" height="{H}" fill="{PAPER}"/>',
        header_icon(icon, 24, 14),
        text(92, 52, title, TITLE, 700, INK),
        f'<rect x="0" y="80" width="{W}" height="2" fill="{LINE}"/>',
        body,
        f'<rect x="0" y="594" width="{W}" height="46" fill="{SOFT}"/>',
        badge("info", 44, 617).replace('r="21"', 'r="15"', 1).replace("cy - 9", "cy - 7"),
        text(70, 627, footer, SIZE, 500, SUB),
        "</svg>",
    ]
    return "\n".join(s) + "\n"


TOP, BOTTOM = 96, 580
YES = {"uz": "Ha", "ru": "Да", "en": "Yes"}
NO = {"uz": "Yo‘q", "ru": "Нет", "en": "No"}

# ================================================================== matnlar
# Har qator manbasi: docs/DIAGRAMS_CONTENT_SOURCES.md (QC-1 ... kabi ID lar).
T = {
    "qc_decision": {
        "title": {
            "en": "QC run: accept or reject",
            "ru": "Серия КК: принять или отклонить",
            "uz": "QC seriyasi: qabul yoki rad",
        },
        "s1": {  # QC-1
            "en": "Measure the control materials",
            "ru": "Измерьте контрольные материалы",
            "uz": "Nazorat materiallarini o‘lchang",
        },
        "s2": {  # QC-2
            "en": ("Levey–Jennings chart", "target mean ± SD"),
            "ru": ("Карта Леви–Дженнингса", "целевое среднее ± SD"),
            "uz": ("Levey–Jennings grafigi", "maqsadli o‘rtacha ± SD"),
        },
        "d": {  # QC-3
            "en": ("Rejection rule violated?", "1-3s, 2-2s, R-4s, 4-1s, 10x"),
            "ru": ("Нарушено правило отклонения?", "1-3s, 2-2s, R-4s, 4-1s, 10x"),
            "uz": ("Rad qoidasi buzildimi?", "1-3s, 2-2s, R-4s, 4-1s, 10x"),
        },
        "ok": {  # QC-4
            "en": ("Accept the run", "1-2s alone: warning only"),
            "ru": ("Принять серию", "1-2s — предупреждение"),
            "uz": ("Seriyani qabul qiling", "faqat 1-2s: ogohlantirish"),
        },
        "r1": {  # QC-5
            "en": "Reject: stop, do not report results",
            "ru": "Отклонить: результаты пациентов не выдавать",
            "uz": "Rad: bemor natijalarini bermang",
        },
        "r2": {  # QC-6
            "en": "Find the cause; do not just repeat QC",
            "ru": "Найдите причину; не повторяйте КК вслепую",
            "uz": "Sababni toping; QC ni shunchaki takrorlamang",
        },
        "r3": {  # QC-7
            "en": "Fix it; recheck QC and patient samples",
            "ru": "Устраните; повторите КК и пробы пациентов",
            "uz": "Tuzatib, QC va namunalarni qayta tekshiring",
        },
        "r4": {  # QC-8
            "en": "Report once in control; record the actions",
            "ru": "Выдача — после восстановления КК; запишите меры",
            "uz": "QC tiklangach natija bering; choralarni yozing",
        },
        "footer": {
            "en": "Westgard 1981 · WHO LQMS 2011 · your lab SOP prevails",
            "ru": "Westgard 1981 · ВОЗ LQMS 2011 · приоритет — СОП",
            "uz": "Westgard 1981 · WHO LQMS 2011 · laboratoriya SOP’i ustun",
        },
    },
    "calibration_overview": {
        "title": {
            "en": "Calibration workflow",
            "ru": "Порядок калибровки",
            "uz": "Kalibrlash tartibi",
        },
        "s1": {  # CAL-1
            "en": "Model, reagent and instruction revision",
            "ru": "Модель, реагент и версия инструкции",
            "uz": "Model, reagent va yo‘riqnoma versiyasi",
        },
        "s2": {  # CAL-2
            "en": ("Calibrator lot", "values from this lot’s value sheet"),
            "ru": ("Лот калибратора", "значения — из листа этого лота"),
            "uz": ("Kalibrator loti", "qiymatlar shu lot varag‘idan"),
        },
        "s3": {  # CAL-3
            "en": "Method-specific preparation",
            "ru": "Подготовка согласно методике",
            "uz": "Metodga mos tayyorlash",
        },
        "s4": {  # CAL-4
            "en": "Calibration according to the instructions",
            "ru": "Калибровка по инструкции",
            "uz": "Yo‘riqnoma bo‘yicha kalibrlash",
        },
        "d": {  # CAL-5
            "en": "Post-calibration QC passed?",
            "ru": "КК после калибровки пройден?",
            "uz": "Kalibrlashdan keyin QC o‘tdimi?",
        },
        "ok": {  # CAL-6
            "en": ("Accepted", "by an authorized person"),
            "ru": ("Принята", "уполномоченным лицом"),
            "uz": ("Qabul qilindi", "vakolatli shaxs tomonidan"),
        },
        "no": {  # CAL-7
            "en": ("Not accepted", "troubleshoot per IFU and SOP"),
            "ru": ("Не принята", "причина — по IFU и СОП"),
            "uz": ("Qabul qilinmaydi", "sabab — IFU va SOP bo‘yicha"),
        },
        "footer": {
            "en": "Parameters only from the matching IFU · lab SOP prevails",
            "ru": "Параметры — только из подходящей IFU · приоритет — СОП",
            "uz": "Parametrlar faqat mos IFU’dan · laboratoriya SOP’i ustun",
        },
    },
    "differential_count": {
        "title": {
            "en": "Manual leukocyte differential",
            "ru": "Лейкоцитарная формула вручную",
            "uz": "Leykoformulani qo‘lda sanash",
        },
        "s1": {  # DIF-1, DIF-2
            "en": ("Check the film", "even, no lines or holes; if poor, make a new one"),
            "ru": ("Оцените мазок", "ровный, без полос и «дыр»; плохой — переделать"),
            "uz": ("Surtmani baholang", "tekis, chiziq va teshiksiz; yomon bo‘lsa — yangisi"),
        },
        "s2": {  # DIF-3
            "en": ("Count in the monolayer", "×100 oil; one way, no repeats"),
            "ru": ("Счёт в монослое", "×100; в одну сторону, без повторов"),
            "uz": ("Bir qavatli zonada sanang", "×100; bir yo‘nalishda, takrorlamay"),
        },
        "s3": {  # DIF-4
            "en": ("Count to the SOP target", "usually 100 cells"),
            "ru": ("Считайте до цели СОП", "обычно 100 клеток"),
            "uz": ("SOP bo‘yicha sanang", "odatda 100 hujayra"),
        },
        "s4": {  # DIF-5
            "en": ("% of each cell type", "absolute = fraction × WBC"),
            "ru": ("% каждого вида клеток", "абсолютное = доля × WBC"),
            "uz": ("Har bir tur ulushi, %", "mutlaq son = ulush × WBC"),
        },
        "d2": {  # DIF-6
            "en": "Blasts or unidentified cells?",
            "ru": "Бласты или неопознанные клетки?",
            "uz": "Blast yoki aniqlanmagan hujayra?",
        },
        "refer": {  # DIF-6
            "en": ("Do not interpret yourself", "a hematologist or physician reviews the smear"),
            "ru": ("Не интерпретируйте сами", "мазок смотрит гематолог или врач"),
            "uz": ("O‘zingiz talqin qilmang", "surtmani gematolog yoki shifokor ko‘rsin"),
        },
        "report": {  # DIF-7
            "en": ("Compare with the reference interval", "from your lab’s report form"),
            "ru": ("Сравните с референтным интервалом", "с бланка лаборатории"),
            "uz": ("Referens oraliq bilan solishtiring", "laboratoriya blankasidan"),
        },
        "footer": {
            "en": "WHO basic laboratory manual 2003 · lab SOP prevails",
            "ru": "Руководство ВОЗ 2003 · приоритет — СОП лаборатории",
            "uz": "JSST qo‘llanmasi 2003 · laboratoriya SOP’i ustun",
        },
    },
    "photometry": {
        "title": {
            "en": "Absorbance photometry",
            "ru": "Абсорбционная фотометрия",
            "uz": "Absorbsion fotometriya",
        },
        "bench": {  # PHO-1
            "en": ["Light source", "Filter (λ)", "Cuvette", "Detector", "Result"],
            "ru": ["Источник", "Фильтр (λ)", "Кювета", "Детектор", "Результат"],
            "uz": ["Nur manbai", "Filtr (λ)", "Kyuveta", "Detektor", "Natija"],
        },
        "f1": {  # PHO-2
            "en": "Absorbance",
            "ru": "Оптическая плотность",
            "uz": "Optik zichlik",
        },
        "f2": {  # PHO-3
            "en": "Beer–Lambert law",
            "ru": "Закон Бугера–Ламберта–Бера",
            "uz": "Buger–Lambert–Ber qonuni",
        },
        "s1": {  # PHO-4, PHO-5
            "en": ("Measure blank → standard → sample", "C = (A sample ÷ A standard) × C standard"),
            "ru": ("Измерьте бланк → стандарт → пробу", "C = (A пробы ÷ A стандарта) × C стандарта"),
            "uz": ("Blank → standart → namunani o‘lchang", "C = (A namuna ÷ A standart) × C standart"),
        },
        "d": {  # PHO-6
            "en": ("Above the linearity limit?", "Yes: dilute, repeat, multiply by the dilution factor"),
            "ru": ("Выше границы линейности?", "Да: развести, повторить, × степень разведения"),
            "uz": ("Chiziqlilik chegarasidan oshdimi?", "Ha: suyultiring, takrorlang, × suyultirish darajasi"),
        },
        "footer": {
            "en": "Wavelength, blank and limits: per the reagent IFU",
            "ru": "Длина волны, бланк и границы — по IFU реагента",
            "uz": "To‘lqin uzunligi, blank va chegaralar — reagent IFU’si",
        },
    },
    "preanalytics": {
        "title": {
            "en": "Preanalytical phase",
            "ru": "Преаналитический этап",
            "uz": "Preanalitik bosqich",
        },
        "s1": {  # PRE-1
            "en": ("Prepare for testing", "patient preparation"),
            "ru": ("Подготовка к анализу", "подготовка пациента"),
            "uz": ("Tahlilga tayyorlash", "bemor tayyorgarligi"),
        },
        "s2": {  # PRE-2
            "en": ("Select specimen and additive", "tube for the test, order of draw"),
            "ru": ("Выбор образца и добавки", "пробирка по тесту, порядок взятия"),
            "uz": ("Namuna va qo‘shimchani tanlash", "mos probirka, olish tartibi"),
        },
        "s3": {  # PRE-3
            "en": ("Collect and identify", "full name matches the request form"),
            "ru": ("Взятие и идентификация", "ФИО совпадает с направлением"),
            "uz": ("Olish va identifikatsiya", "to‘liq ism yo‘llanmaga mos"),
        },
        "s4": {  # PRE-4
            "en": ("Separate and store", "within sample stability"),
            "ru": ("Разделение и хранение", "в пределах стабильности"),
            "uz": ("Ajratish va saqlash", "barqarorlik muddatida"),
        },
        "s5": {  # PRE-5
            "en": ("Transport and receive", "recheck labels and forms"),
            "ru": ("Доставка и приём", "сверьте этикетки и направления"),
            "uz": ("Tashish va qabul qilish", "yorliq va yo‘llanmani tekshiring"),
        },
        "d": {  # PRE-6
            "en": "Specimen acceptable?",
            "ru": "Образец пригоден?",
            "uz": "Namuna yaroqlimi?",
        },
        "ok": {
            "en": "Analysis",
            "ru": "Анализ",
            "uz": "Tahlil",
        },
        "no": {
            "en": "Lab SOP",
            "ru": "По СОП",
            "uz": "SOP’ga ko‘ra",
        },
        "footer": {
            "en": "WHO phlebotomy guidelines 2010 · lab SOP prevails",
            "ru": "Рекомендации ВОЗ 2010 · приоритет — СОП лаборатории",
            "uz": "JSST 2010 tavsiyalari · laboratoriya SOP’i ustun",
        },
    },
    "educational_feedback": {
        "title": {
            "en": "Learning from a practice quiz",
            "ru": "Как учиться на результатах теста",
            "uz": "Test natijasidan qanday o‘rganish",
        },
        "s1": {
            "en": "Answer the questions",
            "ru": "Ответьте на вопросы",
            "uz": "Savollarga javob bering",
        },
        "s2": {
            "en": ("See your score", "correct out of total"),
            "ru": ("Посмотрите результат", "верно из общего числа"),
            "uz": ("Natijani ko‘ring", "nechtadan nechtasi to‘g‘ri"),
        },
        "d": {
            "en": "Any mistakes?",
            "ru": "Есть ошибки?",
            "uz": "Xato bormi?",
        },
        "s3": {
            "en": ("Review your mistakes", "correct answer and explanation"),
            "ru": ("Разбор ошибок", "правильный ответ и объяснение"),
            "uz": ("Xatolar ustida ishlash", "to‘g‘ri javob va izoh"),
        },
        "s4": {
            "en": ("Practice mistakes", "only the questions you missed"),
            "ru": ("Работа над ошибками", "только вопросы с ошибкой"),
            "uz": ("Xatolarni qayta ishlash", "faqat xato javob berilganlar"),
        },
        "done": {
            "en": "Try again or another topic",
            "ru": "Повторить или другая тема",
            "uz": "Qayta boshlash yoki boshqa mavzu",
        },
        "footer": {
            "en": "How LabGuide practice works — not a lab procedure",
            "ru": "Практика в LabGuide — не лабораторная процедура",
            "uz": "LabGuide mashqi tartibi — laboratoriya jarayoni emas",
        },
    },
}


def pair(v):
    return v if isinstance(v, tuple) else (v, None)


def texts(topic, lang):
    return {k: v[lang] for k, v in T[topic].items()}


# ================================================================== maketlar
COL_L, COL_R, COL_W = 24, 498, 438
XM = (COL_L + COL_W + COL_R) / 2  # ustunlar orasidagi yo'lak


def elbow(a, b, kind="grey"):
    """a (chap ustun) o'ng chetidan -> yo'lak -> b (o'ng ustun) chap chetiga."""
    ya, yb = a.y + a.h / 2, b.y + b.h / 2
    return arrow([(a.x + a.w + 2, ya), (XM, ya), (XM, yb), (b.x - 4, yb)], kind)


def qc_decision(lang):
    t = texts("qc_decision", lang)
    s1 = Node("step", t["s1"], num=1, w=COL_W)
    s2 = Node("step", *pair(t["s2"]), num=2, w=COL_W)
    d = Node("decision", *pair(t["d"]), w=COL_W)
    ok = Node("ok", *pair(t["ok"]), w=COL_W)
    stack([s1, s2, d, ok], COL_L, TOP, BOTTOM, min_gap=[28, 42, 44], max_gap=56)
    r1 = Node("stop", t["r1"], w=COL_W)
    r2 = Node("step", t["r2"], num=3, w=COL_W)
    r3 = Node("step", t["r3"], num=4, w=COL_W)
    r4 = Node("step", t["r4"], num=5, w=COL_W)
    stack([r1, r2, r3, r4], COL_R, TOP, BOTTOM, min_gap=26, max_gap=44)
    b = "".join(n.svg() for n in (s1, s2, d, ok, r1, r2, r3, r4))
    b += link_down(s1, s2) + link_down(s2, d)
    b += link_down(d, ok, "ok", NO[lang])
    b += link_down(r1, r2, "stop") + link_down(r2, r3) + link_down(r3, r4)
    b += elbow(d, r1, "stop")
    # "Ha" yorlig'i: qaror tepasidagi bo'sh oraliqda, yo'lakdagi o'q yonida
    b += chip(XM - 10, (s2.bottom + d.y) / 2, YES[lang], "stop", align="right")
    return frame("qc", t["title"], t["footer"], b)


def calibration_overview(lang):
    t = texts("calibration_overview", lang)
    left = [
        Node("step", t["s1"], num=1, w=COL_W),
        Node("step", *pair(t["s2"]), num=2, w=COL_W),
        Node("step", t["s3"], num=3, w=COL_W),
        Node("step", t["s4"], num=4, w=COL_W),
    ]
    stack(left, COL_L, TOP, BOTTOM, min_gap=28, max_gap=52)
    d = Node("decision", t["d"], w=COL_W)
    ok = Node("ok", *pair(t["ok"]), w=COL_W - 30)
    no = Node("stop", *pair(t["no"]), w=COL_W - 30)
    stack([d, ok, no], COL_R, TOP, BOTTOM, min_gap=[48, 28], max_gap=48)
    b = "".join(n.svg() for n in left + [d, ok, no])
    for a, c in zip(left, left[1:]):
        b += link_down(a, c)
    b += elbow(left[-1], d)
    b += link_down(d, ok, "ok", YES[lang], x=ok.cx)
    # Yo'q: qarordan o'ng chekka bo'ylab pastga (OK blokini aylanib)
    xr = COL_R + COL_W - 12
    b += arrow([(xr, d.bottom + 2), (xr, no.y + no.h / 2), (no.x + no.w + 4, no.y + no.h / 2)], "stop")
    b += chip(xr - 12, (d.bottom + ok.y) / 2, NO[lang], "stop", align="right")
    return frame("calibration", t["title"], t["footer"], b)


def differential_count(lang):
    t = texts("differential_count", lang)
    s1 = Node("step", *pair(t["s1"]), num=1, w=COL_W)
    s2 = Node("step", *pair(t["s2"]), num=2, w=COL_W)
    report = Node("ok", *pair(t["report"]), w=COL_W)
    stack([s1, s2, report], COL_L, TOP, BOTTOM, min_gap=[28, 48], max_gap=60)
    s3 = Node("step", *pair(t["s3"]), num=3, w=COL_W)
    s4 = Node("step", *pair(t["s4"]), num=4, w=COL_W)
    d2 = Node("decision", t["d2"], w=COL_W)
    refer = Node("stop", *pair(t["refer"]), w=COL_W)
    stack([s3, s4, d2, refer], COL_R, TOP, BOTTOM, min_gap=[24, 24, 48], max_gap=52)
    b = "".join(n.svg() for n in (s1, s2, report, s3, s4, d2, refer))
    b += link_down(s1, s2)
    # 2 -> 3: yo'lak orqali yuqoriga; chiqish nuqtasi qarordan (Yo'q yo'li) yuqorida
    yb = d2.y + d2.h / 2
    ys2 = min(s2.y + s2.h / 2, yb - 30)
    if ys2 < s2.y + 16:
        raise SystemExit(f"differential {lang}: 2-qadam chiqishi qaror bilan to'qnashadi")
    b += arrow([(s2.x + s2.w + 2, ys2), (XM, ys2), (XM, s3.y + s3.h / 2), (s3.x - 4, s3.y + s3.h / 2)])
    b += link_down(s3, s4) + link_down(s4, d2)
    b += link_down(d2, refer, "stop", YES[lang])
    # Yo'q: qarordan yo'lak orqali chap pastki xulosaga
    yr = report.y + report.h / 2
    b += arrow([(d2.x - 2, yb), (XM, yb), (XM, yr), (report.x + report.w + 4, yr)], "ok")
    b += chip(XM - 10, (s2.bottom + report.y) / 2, NO[lang], "ok", align="right")
    return frame("differential", t["title"], t["footer"], b)


def photometry(lang):
    t = texts("photometry", lang)
    b = ""
    # ---------------- optik yo'l (tepada, gorizontal)
    cy = 140
    xs = [100, 288, 480, 672, 860]
    b += f'<rect x="{xs[0] + 30}" y="{cy - 9}" width="{xs[2] - xs[0] - 30}" height="18" fill="url(#beam)"/>'
    b += f'<rect x="{xs[2] + 32}" y="{cy - 6}" width="{xs[3] - xs[2] - 64}" height="12" fill="#F4C84A" opacity="0.5"/>'
    b += arrow([(xs[3] + 36, cy), (xs[4] - 52, cy)], "grey", 3.5)
    x = xs[0]  # lampa
    b += f'<circle cx="{x}" cy="{cy}" r="28" fill="#FFF4CF" stroke="{DEC_STROKE}" stroke-width="3"/>'
    b += f'<path d="M{x - 10} {cy + 7} q10 -22 20 0" fill="none" stroke="{DEC_STROKE}" stroke-width="3" stroke-linecap="round"/>'
    for dx, dy in ((-34, -30), (0, -44), (34, -30), (-46, 0)):
        b += (f'<path d="M{x + dx * 0.8:.1f} {cy + dy * 0.8:.1f} L{x + dx:.1f} {cy + dy:.1f}" '
              f'stroke="{DEC_STROKE}" stroke-width="3" stroke-linecap="round"/>')
    x = xs[1]  # filtr
    b += f'<rect x="{x - 9}" y="{cy - 42}" width="18" height="84" rx="4" fill="#7FB3C8" stroke="#4E8399" stroke-width="2.5"/>'
    x = xs[2]  # kyuveta
    b += f'<rect x="{x - 30}" y="{cy - 42}" width="60" height="84" rx="6" fill="#FFFFFF" stroke="{STEP_STROKE}" stroke-width="3"/>'
    b += f'<rect x="{x - 25}" y="{cy - 16}" width="50" height="53" rx="4" fill="{LIQUID}" opacity="0.9"/>'
    b += (f'<path d="M{x - 26} {cy + 56} H{x + 26}" stroke="{SUB}" stroke-width="2.5" '
          'marker-end="url(#ah-grey)" marker-start="url(#ah-grey)"/>')
    b += text(x + 48, cy + 66, "ℓ", 30, 600, SUB, "middle")
    x = xs[3]  # detektor
    b += f'<rect x="{x - 30}" y="{cy - 34}" width="60" height="68" rx="10" fill="#34403B"/>'
    b += f'<rect x="{x - 30}" y="{cy - 18}" width="10" height="36" rx="2" fill="#8FD0A9"/>'
    x = xs[4]  # natija (ekran)
    b += f'<rect x="{x - 46}" y="{cy - 32}" width="92" height="64" rx="10" fill="{SCREEN}"/>'
    b += text(x, cy + 12, "A", 34, 700, "#FFFFFF", "middle")
    b += formula((xs[1] + xs[2]) / 2 - 6, cy - 22, [("I", False), ("0", True)], 30)
    b += formula((xs[2] + xs[3]) / 2, cy - 22, [("I", False)], 30, anchor="middle")
    for x, lab in zip(xs, t["bench"]):
        if M.width(lab, SIZE, 600) > 182:
            raise SystemExit(f"photometry {lang}: yorliq keng: {lab}")
        b += text(x, cy + 92, lab, SIZE, 600, INK, "middle")
    # ---------------- formulalar (ikki karta)
    fy, fh = cy + 110, 92
    cards = (
        (t["f1"], [("A = log", False), ("10", True), ("(I", False), ("0", True), (" / I)", False)], 380),
        (t["f2"], [("A = ε · ℓ · c", False)], W - 48 - 24 - 380),
    )
    x0 = 24
    for cap, parts, cw in cards:
        if M.width(cap, SIZE, 600) > cw - 40:
            raise SystemExit(f"photometry {lang}: formula sarlavhasi keng: {cap}")
        b += f'<rect x="{x0:.1f}" y="{fy}" width="{cw:.1f}" height="{fh}" rx="16" fill="{SOFT}"/>'
        b += text(x0 + 20, fy + 34, cap, SIZE, 600, SUB)
        b += formula(x0 + 20, fy + 76, parts, 34)
        x0 += cw + 24
    # ---------------- tartib: 1 o'lchash va hisob -> qaror (chiziqlilik)
    n1 = Node("step", *pair(t["s1"]), w=W - 48)
    d = Node("decision", *pair(t["d"]), w=W - 48)
    stack([n1, d], 24, fy + fh + 20, BOTTOM, min_gap=30, max_gap=40)
    b += n1.svg() + d.svg() + link_down(n1, d)
    return frame("photometry", t["title"], t["footer"], b)


def preanalytics(lang):
    t = texts("preanalytics", lang)
    left = [Node("step", *pair(t[f"s{i}"]), num=i, w=COL_W) for i in (1, 2, 3)]
    stack(left, COL_L, TOP, BOTTOM, min_gap=36, max_gap=64)
    s4, s5 = (Node("step", *pair(t[f"s{i}"]), num=i, w=COL_W) for i in (4, 5))
    d = Node("decision", t["d"], w=COL_W)
    ok = Node("ok", t["ok"], w=180, center=True, compact=True)
    no = Node("stop", t["no"], w=COL_W - 24 - 180, center=True, compact=True)
    if ok.h != no.h:
        raise SystemExit(f"preanalytics {lang}: natija bloklari balandligi har xil")
    stack([s4, s5, d, ok], COL_R, TOP, BOTTOM, min_gap=[28, 28, 48], max_gap=44)
    no.x, no.y = COL_R + ok.w + 24, ok.y
    b = "".join(n.svg() for n in left + [s4, s5, d, ok, no])
    for a, c in zip(left, left[1:]):
        b += link_down(a, c)
    b += elbow(left[-1], s4)
    b += link_down(s4, s5) + link_down(s5, d)
    b += link_down(d, ok, "ok", YES[lang], x=ok.cx)
    b += link_down(d, no, "stop", NO[lang], x=no.cx)
    return frame("preanalytics", t["title"], t["footer"], b)


def educational_feedback(lang):
    t = texts("educational_feedback", lang)
    gx = 30  # chap qaytish o'qi uchun joy
    lw = COL_W - gx
    s1 = Node("step", t["s1"], num=1, w=lw)
    s2 = Node("step", *pair(t["s2"]), num=2, w=COL_W)
    d = Node("decision", t["d"], w=COL_W)
    s3 = Node("step", *pair(t["s3"]), num=3, w=COL_W)
    s4 = Node("step", *pair(t["s4"]), num=4, w=lw)
    done = Node("ok", t["done"], w=lw - 90)
    stack([s2, d, s3], COL_R, TOP, BOTTOM, min_gap=[40, 48], max_gap=90)
    for n, ref in ((s1, s2), (done, d), (s4, s3)):
        n.x = COL_L + gx
        n.y = ref.y + (ref.h - n.h) / 2
    if done.y < s1.bottom + 24 or done.bottom > s4.y - 24:
        raise SystemExit(f"educational {lang}: chap ustun sig'madi")
    b = "".join(n.svg() for n in (s1, s2, d, s3, s4, done))
    y1 = s1.y + s1.h / 2
    b += arrow([(s1.x + s1.w + 2, y1), (COL_R - 4, y1)])
    b += link_down(s2, d)
    b += link_down(d, s3, "stop", YES[lang])
    y4 = s4.y + s4.h / 2
    b += arrow([(COL_R - 2, y4), (s4.x + s4.w + 4, y4)])
    yd = d.y + d.h / 2
    b += arrow([(d.x - 2, yd), (done.x + done.w + 4, yd)], "ok")
    b += chip((done.x + done.w + COL_R) / 2, yd - 30, NO[lang], "ok")
    xl = COL_L + 8  # 4 -> 1: chap chekkadagi halqa
    b += arrow([(s4.x - 2, y4), (xl, y4), (xl, y1), (s1.x - 4, y1)], "grey", 3.5)
    return frame("learn", t["title"], t["footer"], b)


TOPICS = {
    "calibration_overview": calibration_overview,
    "differential_count": differential_count,
    "educational_feedback": educational_feedback,
    "photometry": photometry,
    "preanalytics": preanalytics,
    "qc_decision": qc_decision,
}


def main(argv):
    OUT.mkdir(parents=True, exist_ok=True)
    only = set(argv)
    for topic, fn in TOPICS.items():
        if only and topic not in only:
            continue
        for lang in LANGS:
            svg = fn(lang)
            (OUT / f"{topic}.{lang}.svg").write_text(svg, encoding="utf-8")
            print("ok", topic, lang)


if __name__ == "__main__":
    main(sys.argv[1:])
