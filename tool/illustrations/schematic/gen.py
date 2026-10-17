#!/usr/bin/env python3
"""Apparat TURI bo'yicha sxematik chizmalar (D-36a: aniq model fotosi emas).

Har bir chizma — shu turdagi apparatning umumiy, original tasviri: namuna
rakasi, reagent joyi, zond/igna, displey, chiqindi. Hech bir ishlab chiqaruvchi
dizayniga, logotipiga yoki yozuviga o'xshatilmagan; rasmda matn yo'q.

    python3 tool/illustrations/schematic/gen.py            # SVG larni yozadi
    NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --schematic
                                                            # PNG (480 va 1200)

Katalogdagi `schematic` kaliti (tool/instrument_catalog_src.py) shu nomlarga
mos keladi.
"""
import math
import pathlib
import random

HERE = pathlib.Path(__file__).resolve().parent
W, H = 1200, 800
GROUND = 702

# Palitra: lib/design/tokens.dart va mavjud tool/illustrations/*.svg bilan bir xil.
LINE = "#B9C4BD"

DEFS = """
<defs>
  <linearGradient id="body" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#E1E7E3"/></linearGradient>
  <linearGradient id="bodyH" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#F4F7F5"/><stop offset="0.7" stop-color="#FFFFFF"/><stop offset="1" stop-color="#D9E1DC"/></linearGradient>
  <linearGradient id="topP" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#EEF2EF"/><stop offset="1" stop-color="#D7DFDA"/></linearGradient>
  <linearGradient id="deck" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#C9D4CE"/><stop offset="1" stop-color="#E4EAE6"/></linearGradient>
  <linearGradient id="screen" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#1F5A4C"/><stop offset="1" stop-color="#143C33"/></linearGradient>
  <linearGradient id="dark" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#34403B"/><stop offset="1" stop-color="#151A18"/></linearGradient>
  <linearGradient id="niche" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#26302C"/><stop offset="1" stop-color="#3B4843"/></linearGradient>
  <linearGradient id="metal" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E4E9E6"/><stop offset="1" stop-color="#A9B4AE"/></linearGradient>
  <linearGradient id="glass" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFFFFF" stop-opacity="0.55"/><stop offset="0.45" stop-color="#FFFFFF" stop-opacity="0.08"/><stop offset="1" stop-color="#CFE9D9" stop-opacity="0.25"/></linearGradient>
  <linearGradient id="liquid" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F0D36B"/><stop offset="1" stop-color="#E0B73A"/></linearGradient>
  <filter id="soft" filterUnits="userSpaceOnUse" x="0" y="0" width="1200" height="800"><feGaussianBlur stdDeviation="14"/></filter>
</defs>
"""


def svg(inner):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
        f'width="{W}" height="{H}">\n{DEFS}\n{inner}\n</svg>\n'
    )


# ----------------------------------------------------------------- primitives
def ground(cx, rx, cy=GROUND + 10, ry=20, op=0.5):
    return (
        f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#6F8479" '
        f'opacity="{op}" filter="url(#soft)"/>'
    )


def rect(x, y, w, h, rx=0, fill="url(#body)", stroke=LINE, sw=3, extra=""):
    st = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
    return f'<rect x="{x:g}" y="{y:g}" width="{w:g}" height="{h:g}" rx="{rx:g}" fill="{fill}"{st} {extra}/>'


def ell(cx, cy, rx, ry, fill, stroke=None, sw=2, extra=""):
    st = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
    return f'<ellipse cx="{cx:.1f}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{fill}"{st} {extra}/>'


def line(x1, y1, x2, y2, stroke=LINE, sw=3, cap="round", extra=""):
    return (
        f'<line x1="{x1:g}" y1="{y1:g}" x2="{x2:g}" y2="{y2:g}" stroke="{stroke}" '
        f'stroke-width="{sw}" stroke-linecap="{cap}" {extra}/>'
    )


def path(d, fill="none", stroke=LINE, sw=3, extra=""):
    return (
        f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" '
        f'stroke-linecap="round" stroke-linejoin="round" {extra}/>'
    )


def hose(d, color="#A9B5AE", sw=6):
    """Egiluvchan shlang (reagent/chiqindi liniyasi)."""
    return path(d, stroke=color, sw=sw)


def led(cx, cy, color="#6FCF7F", r=7):
    return ell(cx, cy, r, r, color, "#FFFFFF", 2)


def vents(x, y, w, n, gap=11, stroke="#CBD4CE"):
    return "".join(line(x, y + i * gap, x + w, y + i * gap, stroke, 4) for i in range(n))


# ------------------------------------------------------------ lab containers
TUBE_CAPS = ["#8E6CC4", "#B6403A", "#E3B93C", "#5B8FD0", "#6FB07F"]


def tube(x, y, cap="#8E6CC4", fill="#B6403A", h=96, w=26, level=0.5):
    """Probirka: (x, y) — qopqoqning chap-yuqori nuqtasi; cap=None — ochiq."""
    ly = y + 16 + h * (1 - level)
    s = rect(x, y + 16, w, h, 12, "#FFFFFFD9", "#C3CCC6", 3)
    s += rect(x + 3, ly, w - 6, y + 16 + h - ly - 4, 9, fill, None)
    if cap:
        s += rect(x - 3, y, w + 6, 24, 6, cap, None)
    return s


def rack(x, y, n, caps=None, fills=None, step=46, plate_w=None, h=96):
    """Probirka rakasi; (x, y) — tagidagi plastina yuqori-chap nuqtasi."""
    caps = caps or TUBE_CAPS
    fills = fills or ["#B6403A", "#B6403A", "#D14A42", "#B6403A", "#C2453E"]
    pw = plate_w or (n * step + 14)
    s = ""
    for i in range(n):
        s += tube(x + 14 + i * step, y - h - 14, caps[i % len(caps)], fills[i % len(fills)], h=h,
                  level=0.45 + 0.1 * (i % 3))
    s += rect(x, y, pw, 34, 9, "#DDE5DF", "#BFC9C2", 3)
    s += line(x + 12, y + 17, x + pw - 12, y + 17, "#C9D2CC", 3)
    return s


def bottle(x, y, w, h, cap, liquid, label=None):
    """Reagent / eritma idishi; (x, y) — yuqori-chap."""
    nw = w * 0.42
    s = rect(x, y + h * 0.14, w, h * 0.86, w * 0.16, "#F6F8F6", "#C3CCC6", 3)
    s += rect(x + w * 0.1, y + h * 0.42, w * 0.8, h * 0.5, w * 0.1, liquid, None, extra='opacity="0.9"')
    s += rect(x + (w - nw) / 2, y + h * 0.02, nw, h * 0.16, 5, cap, None)
    if label:
        s += rect(x + w * 0.2, y + h * 0.5, w * 0.6, h * 0.2, 4, label, None, extra='opacity="0.95"')
    return s


def jug(x, y, w, h, cap, liquid, level=0.7):
    """Katta kanistr (distillangan suv/eritma); (x, y) — yuqori-chap."""
    s = rect(x, y + 18, w, h - 18, 16, "#F2F5F3", "#C3CCC6", 3)
    ly = y + 18 + (h - 18) * (1 - level)
    s += rect(x + 8, ly, w - 16, y + h - ly - 8, 10, liquid, None, extra='opacity="0.85"')
    s += rect(x + w * 0.62, y + 2, w * 0.24, 22, 6, cap, None)
    s += path(f"M{x + w * 0.2:g} {y + 34:g} q{w * 0.12:g} -18 {w * 0.24:g} 0", stroke="#C3CCC6", sw=4)
    return s


def waste_can(x, y, w, h):
    s = rect(x, y + 16, w, h - 16, 14, "#E6EAE7", "#BFC9C2", 3)
    s += rect(x + 10, y + h * 0.45, w - 20, h * 0.18, 5, "#CBD3CE", None)
    s += rect(x + w * 0.58, y, w * 0.28, 22, 6, "#8C9791", None)
    return s


# --------------------------------------------------------------- big pieces
def ring_points(cx, cy, rx, ry, k, n, phase=0.0):
    return [
        (cx + rx * k * math.cos(phase + 2 * math.pi * i / n), cy + ry * k * math.sin(phase + 2 * math.pi * i / n))
        for i in range(n)
    ]


def drum(cx, cy, rx, ry, depth, top="#E4EAE6", side="#BAC6BF"):
    """Yuqoridan perspektivada disk/karusel (past silindr)."""
    s = f'<path d="M{cx - rx:.1f} {cy:.1f} V{cy + depth:.1f} A{rx:.1f} {ry:.1f} 0 0 0 {cx + rx:.1f} {cy + depth:.1f} V{cy:.1f} Z" fill="{side}" stroke="{LINE}" stroke-width="2" stroke-linejoin="round"/>'
    s += ell(cx, cy, rx, ry, top, LINE, 2)
    return s


def reagent_disk(cx, cy, rx, ry, depth=16, outer=18, inner=10, caps=None):
    """Reagent karuseli: tashqi va ichki halqada idish bo'g'izlari."""
    caps = caps or ["#7FB3C8", "#D98BA6", "#E3B93C", "#9FB3AA", "#8E6CC4"]
    s = drum(cx, cy, rx, ry, depth)
    s += ell(cx, cy, rx * 0.93, ry * 0.93, "#D3DCD6", None)
    pts = [(p, rx * 0.075, ry * 0.2) for p in ring_points(cx, cy, rx, ry, 0.74, outer, 0.2)]
    pts += [(p, rx * 0.062, ry * 0.17) for p in ring_points(cx, cy, rx, ry, 0.46, inner, 0.5)]
    pts.sort(key=lambda t: t[0][1])
    for i, ((px, py), a, b) in enumerate(pts):
        s += ell(px, py + 3, a, b, "#8E9B94")
        s += ell(px, py, a, b, caps[i % len(caps)], "#FFFFFF", 1.5)
    s += ell(cx, cy, rx * 0.2, ry * 0.2, "#BAC6BF", LINE, 2)
    return s


def sample_disk(cx, cy, rx, ry, depth=12, n=16, caps=None):
    caps = caps or TUBE_CAPS
    s = drum(cx, cy, rx, ry, depth)
    s += ell(cx, cy, rx * 0.92, ry * 0.92, "#D3DCD6", None)
    pts = sorted(ring_points(cx, cy, rx, ry, 0.76, n, 0.1), key=lambda t: t[1])
    for i, (px, py) in enumerate(pts):
        s += ell(px, py + 2, rx * 0.075, ry * 0.22, "#7A8780")
        s += ell(px, py, rx * 0.075, ry * 0.22, caps[i % len(caps)], "#FFFFFF", 1.2)
    for px, py in sorted(ring_points(cx, cy, rx, ry, 0.46, n // 2, 0.4), key=lambda t: t[1]):
        s += ell(px, py, rx * 0.055, ry * 0.16, "#F6F8F6", "#9FB3AA", 1.2)
    s += ell(cx, cy, rx * 0.16, ry * 0.16, "#BAC6BF", LINE, 2)
    return s


def reaction_ring(cx, cy, rx, ry, depth=14, n=26):
    s = drum(cx, cy, rx, ry, depth, top="#DDE5E0")
    s += ell(cx, cy, rx * 0.64, ry * 0.64, "#EEF2EF", LINE, 2)
    pts = sorted(ring_points(cx, cy, rx, ry, 0.82, n, 0.05), key=lambda t: t[1])
    for i, (px, py) in enumerate(pts):
        s += rect(px - rx * 0.03, py - ry * 0.2, rx * 0.06, ry * 0.4, 2,
                  "#EAF6FA" if i % 3 else "#C9E6F0", "#8FAAB0", 1.2)
    return s


def probe_arm(px, py, pts, tip_len=20, color="#8E9B94", base="#C9D2CC"):
    """Zond qo'li: tayanch ustun (px, py) -> qo'l -> pastga igna."""
    d = f"M{px} {py} " + " ".join(f"L{x} {y}" for x, y in pts)
    tx, ty = pts[-1]
    s = ell(px, py + 4, 15, 7, "#8E9B94")
    s += ell(px, py, 15, 7, base, LINE, 2)
    s += path(d, stroke="#6E7B74", sw=12)
    s += path(d, stroke=color, sw=8)
    s += line(tx, ty, tx, ty + tip_len, "#4C5853", 3)
    s += ell(tx, ty + tip_len + 3, 3, 3, "#D7A96B", None)
    return s


def monitor(x, y, w, h, content="", arm=None):
    """Sensorli displey; arm — mahkamlovchi yo'l nuqtalari."""
    s = ""
    if arm:
        d = "M" + " L".join(f"{a} {b}" for a, b in arm)
        s += path(d, stroke="#A8B3AC", sw=14)
        s += path(d, stroke="#D5DCD8", sw=8)
    s += rect(x, y, w, h, 14, "url(#dark)", "#0F1412", 2)
    s += rect(x + 10, y + 10, w - 20, h - 20, 7, "url(#screen)", None)
    s += f'<g transform="translate({x + 10},{y + 10})">{content}</g>'
    s += ell(x + w - 18, y + h - 6, 2.5, 2.5, "#6FCF7F")
    return s


def ui_bars(w, h, n=5, accent="#C5E8A1"):
    s = rect(10, 10, w * 0.45, 9, 4, "#8FC9A0", None)
    s += rect(w * 0.62, 10, w * 0.28 - 4, 9, 4, "#5E8C7E", None)
    rh = (h - 44) / n
    for i in range(n):
        yy = 30 + i * rh
        s += rect(10, yy, w - 20, rh - 6, 4, "#FFFFFF", None, extra='opacity="0.10"')
        s += rect(16, yy + (rh - 6) / 2 - 3, w * (0.25 + 0.12 * ((i * 3) % 4)), 6, 3,
                  accent if i % 2 == 0 else "#8FC9A0", None)
        s += ell(w - 26, yy + (rh - 6) / 2, 4, 4, "#6FCF7F" if i != 2 else "#E3B93C")
    return s


def ui_curve(w, h):
    s = rect(10, 8, w * 0.4, 8, 4, "#8FC9A0", None)
    s += line(14, h - 14, w - 14, h - 14, "#5E8C7E", 2)
    s += line(14, 24, 14, h - 14, "#5E8C7E", 2)
    s += path(f"M18 {h - 20} C {w * .25:g} {h - 20} {w * .3:g} 30 {w * .45:g} 30 S {w * .65:g} {h - 24} {w - 20} {h - 24}",
              stroke="#C5E8A1", sw=3.5)
    s += path(f"M18 {h - 18} C {w * .3:g} {h - 18} {w * .4:g} {h * .5:g} {w * .6:g} {h * .5:g} S {w * .8:g} {h - 22} {w - 20} {h - 22}",
              stroke="#8FC9A0", sw=2.5)
    return s


def ui_scatter(w, h):
    """Skatterogramma (rangli nuqta bulutlari) + gistogramma."""
    rnd = random.Random(7)
    s = rect(10, 10, w * 0.4, 9, 4, "#8FC9A0", None)
    s += line(14, h - 18, w * 0.52, h - 18, "#5E8C7E", 2) + line(14, 28, 14, h - 18, "#5E8C7E", 2)
    clouds = [(0.17, 0.78, 0.07, "#8FC9A0"), (0.3, 0.55, 0.08, "#C5E8A1"), (0.38, 0.8, 0.06, "#E3B93C"),
              (0.2, 0.42, 0.07, "#D98BA6"), (0.44, 0.35, 0.05, "#7FB3C8")]
    for cx, cy, r, col in clouds:
        for _ in range(26):
            a, d = rnd.random() * 6.283, rnd.random() * r
            s += ell(w * cx + math.cos(a) * d * w, h * cy + math.sin(a) * d * w * 0.8, 2.2, 2.2, col)
    s += line(w * 0.58, h - 18, w - 14, h - 18, "#5E8C7E", 2)
    s += path(f"M{w * .58:g} {h - 20} C {w * .66:g} {h - 20} {w * .68:g} 40 {w * .75:g} 40 S {w * .84:g} {h - 22} {w - 14} {h - 22}",
              stroke="#C5E8A1", sw=3.5)
    s += path(f"M{w * .58:g} {h - 20} C {w * .6:g} {h - 20} {w * .62:g} {h * .5:g} {w * .66:g} {h * .5:g}",
              stroke="#8FC9A0", sw=2)
    return s


def ui_hist(w, h, n=3):
    s = rect(10, 10, w * 0.4, 9, 4, "#8FC9A0", None)
    colw = (w - 20) / n
    for i in range(n):
        x0 = 12 + i * colw
        s += line(x0 + 2, h - 18, x0 + colw - 8, h - 18, "#5E8C7E", 2)
        mid = x0 + colw * (0.35 + 0.1 * i)
        s += path(f"M{x0 + 2:g} {h - 20} C {x0 + colw * .2:g} {h - 20} {mid - 12:g} 38 {mid:g} 38 S {x0 + colw - 22:g} {h - 22} {x0 + colw - 8:g} {h - 22}",
                  stroke=["#C5E8A1", "#8FC9A0", "#7FB3C8"][i % 3], sw=3)
    return s


def strip_pads(x, y, n=10, step=26, w=20, h=22):
    cols = ["#F3E8A6", "#E7D58A", "#C9D68A", "#9FC27A", "#E7B27A", "#D98BA6", "#B79AD0", "#7FB3C8", "#F0DE90", "#E9C47F"]
    s = rect(x - 10, y - 8, n * step + 10, h + 16, 8, "#F6F8F6", "#BFC9C2", 2.5)
    for i in range(n):
        s += rect(x + i * step, y, w, h, 3, cols[i % len(cols)], "#FFFFFF", 1.2)
    return s


def pack_tray(cx, y_back, y_front, w_back, w_front, rows=3, cols=7):
    """Reagent paketlari tarnovi (to'rtburchak, perspektivada)."""
    s = path(f"M{cx - w_front / 2:g} {y_front} L{cx - w_back / 2:g} {y_back} H{cx + w_back / 2:g} L{cx + w_front / 2:g} {y_front} Z",
             "#E4EAE6", LINE, 2)
    caps = ["#8E6CC4", "#7FB3C8", "#D98BA6", "#E3B93C"]
    for j in range(rows):
        t = (j + 0.5) / rows
        yy = y_back + (y_front - y_back) * t
        sc = 0.62 + 0.5 * t
        span = w_back + (w_front - w_back) * t
        step = (span - 30) / (cols - 1)
        for i in range(cols):
            x = cx - (span - 30) / 2 + i * step
            pw, ph = 20 * sc, 30 * sc
            s += rect(x - pw / 2, yy - ph, pw, ph, 3 * sc, "#F6F8F6", "#A9B8AF", 1.4)
            s += rect(x - pw / 2 + 2 * sc, yy - ph + 3 * sc, pw - 4 * sc, 7 * sc, 2, caps[(i + j) % 4], None)
            s += rect(x - pw / 2 + 2 * sc, yy - ph + 13 * sc, pw - 4 * sc, 6 * sc, 2, caps[(i + 2 * j + 1) % 4], None, extra='opacity="0.7"')
    return s


def deck_clip(cid, pts):
    return f'<clipPath id="{cid}"><path d="{pts}"/></clipPath>'


# =========================================================================
# 1. Avtomatik biokimyoviy analizator (stol usti / pol usti)
# =========================================================================
def chemistry():
    s = ground(600, 480)
    # tashqi idishlar va shlanglar (korpus orqasida)
    s += hose("M118 540 V 470 H 320", "#7FB3C8")
    s += hose("M238 566 V 522 H 320", "#9AA6A0")
    s += jug(62, 530, 112, 172, "#7FB3C8", "#CFE3EC", 0.8)
    s += waste_can(190, 560, 96, 142)
    # korpus
    s += rect(300, 392, 600, 310, 22, "url(#bodyH)")
    # yuqori qism (shisha qopqoqli pallasi)
    s += path("M300 392 L338 232 Q342 220 354 220 H846 Q858 220 862 232 L900 392 Z", "url(#deck)", LINE, 3)
    s += deck_clip("dc", "M312 388 L346 238 H854 L888 388 Z") + '<g clip-path="url(#dc)">'
    s += rect(300, 230, 600, 160, 0, "#D4DDD7", None)
    s += reagent_disk(486, 336, 156, 36, 17)
    s += reaction_ring(744, 318, 104, 26, 13)
    s += sample_disk(690, 366, 70, 15, 8, 12)
    s += probe_arm(612, 270, [(560, 296), (508, 322)], 26)
    s += probe_arm(852, 262, [(790, 292), (730, 316)], 26)
    s += probe_arm(404, 262, [(440, 290)], 14, "#9FB3AA")
    s += ell(640, 366, 14, 5, "#8FA0A0", "#FFFFFF", 1.5)
    s += "</g>"
    s += '<path d="M312 388 L346 238 H700 L610 388 Z" fill="url(#glass)"/>'
    s += rect(296, 380, 608, 22, 9, "#DCE4DF", LINE, 3)
    # namuna rakasi uyasi
    s += rect(338, 436, 292, 226, 16, "url(#niche)", "#232B28", 2)
    s += rack(362, 640, 5, h=96)
    # o'ng eshik / panel
    s += rect(668, 436, 202, 226, 14, "#F4F7F5", LINE, 3)
    s += vents(698, 548, 142, 6)
    s += rect(842, 500, 12, 74, 5, "#5F6B65", None)
    s += led(696, 462)
    s += rect(722, 455, 70, 14, 7, "#DDE5DF", None)
    # monitor
    s += monitor(946, 238, 214, 158, ui_bars(194, 138), arm=[(900, 450), (1054, 450), (1054, 396)])
    return s


# =========================================================================
# 2. Yarim avtomatik fotometr
# =========================================================================
def photometer():
    s = ground(600, 420)
    s += hose("M200 560 V 520 Q200 470 270 470 H 345", "#9AA6A0")
    s += waste_can(150, 560, 100, 142)
    # asosiy korpus
    s += rect(330, 330, 540, 372, 24, "url(#bodyH)")
    # yuqori qiya panel (displey + tugmalar)
    s += path("M330 330 L370 190 Q374 178 386 178 H814 Q826 178 830 190 L870 330 Z", "url(#topP)", LINE, 3)
    s += rect(412, 204, 270, 100, 12, "url(#dark)", "#0F1412", 2)
    s += rect(424, 214, 246, 80, 7, "url(#screen)", None)
    s += f'<g transform="translate(424,214)">{ui_curve(246, 80)}</g>'
    for r in range(3):
        for c in range(4):
            s += rect(704 + c * 30, 206 + r * 30, 24, 22, 6, "#FFFFFF", "#C3CCC6", 2)
    s += led(798, 318, "#6FCF7F", 6)
    # kyuveta kamerasi
    s += rect(650, 345, 190, 120, 14, "#EEF2EF", LINE, 3)
    s += rect(676, 366, 138, 34, 10, "url(#dark)", None)
    s += rect(744, 372, 22, 22, 4, "#EAF6FA", "#9FB3AA", 2)
    s += line(678, 433, 812, 433, "#C9D2CC", 4)
    s += line(678, 447, 790, 447, "#C9D2CC", 4)
    # termoprinter
    s += rect(650, 480, 190, 62, 12, "#DDE5DF", LINE, 3)
    s += rect(676, 500, 138, 8, 4, "#4C5853", None)
    s += rect(704, 462, 84, 40, 3, "#FFFFFF", "#D2DAD5", 2, extra='transform="rotate(-2 746 482)"')
    s += line(716, 474, 776, 473, "#BFC9C2", 3) + line(716, 485, 760, 484, "#BFC9C2", 3)
    # aspiratsiya uyasi: igna + probirka
    s += rect(372, 380, 240, 250, 16, "url(#niche)", "#232B28", 2)
    s += rect(396, 604, 190, 34, 9, "#DDE5DF", "#BFC9C2", 3)
    s += tube(478, 506, None, "#E0B73A", h=96, level=0.6)
    s += rect(482, 388, 28, 76, 8, "url(#metal)", "#8E9B94", 2)
    s += rect(492, 464, 8, 90, 4, "#7B8781", None)
    s += hose("M496 410 H 372 Q 345 410 345 470", "#7FB3C8", 5)
    s += led(398, 404)
    # reagent shisha (yonida)
    s += bottle(900, 548, 74, 154, "#D98BA6", "#F5DCE5", "#FFFFFF")
    s += bottle(990, 580, 64, 122, "#7FB3C8", "#DCEBF2")
    s += hose("M936 552 Q936 470 870 470", "#D98BA6", 4)
    return s


# =========================================================================
# 3. Gematologik analizator — 5 qismli (avtomatik yuklagich)
# =========================================================================
def hematology5():
    s = ground(600, 440)
    s += hose("M980 560 V 430 H 860", "#7FB3C8")
    s += hose("M1086 590 V 470 H 860", "#D98BA6")
    s += hose("M236 640 V 560 H 340", "#9AA6A0")
    s += jug(924, 548, 112, 154, "#7FB3C8", "#DCEBF2", 0.75)
    s += bottle(1050, 590, 70, 112, "#D98BA6", "#F5DCE5", "#FFFFFF")
    s += waste_can(190, 610, 90, 92)
    # korpus
    s += rect(330, 250, 530, 452, 26, "url(#bodyH)")
    # avtomatik yuklagich
    s += path("M360 250 L384 168 Q388 156 400 156 H800 Q812 156 816 168 L840 250 Z", "url(#topP)", LINE, 3)
    s += rect(396, 172, 408, 62, 10, "url(#dark)", None)
    s += rack(416, 218, 6, caps=TUBE_CAPS, h=34, step=62, plate_w=372)
    # displey (skatterogramma)
    s += monitor(380, 288, 430, 220, ui_scatter(410, 200))
    # namuna zond joyi (ochiq rejim)
    s += rect(380, 540, 270, 130, 16, "url(#niche)", "#232B28", 2)
    s += tube(488, 604, None, "#B6403A", h=44, level=0.6)
    s += rect(492, 548, 22, 52, 7, "url(#metal)", "#8E9B94", 2)
    s += rect(500, 600, 6, 40, 3, "#7B8781", None)
    s += rect(566, 566, 62, 62, 12, "#F4F7F5", LINE, 3)
    s += ell(597, 597, 17, 17, "#6FCF7F", "#FFFFFF", 3)
    # o'ng panel
    s += rect(676, 540, 150, 130, 14, "#F4F7F5", LINE, 3)
    s += vents(700, 582, 102, 5)
    s += led(702, 560)
    s += rect(804, 580, 10, 58, 5, "#5F6B65", None)
    return s


# =========================================================================
# 4. Gematologik analizator — 3 qismli (ixcham)
# =========================================================================
def hematology3():
    s = ground(560, 360, ry=18)
    s += hose("M780 590 V 520 H 730", "#7FB3C8", 5)
    s += hose("M880 620 V 540 H 740", "#9AA6A0", 5)
    s += bottle(742, 560, 76, 142, "#7FB3C8", "#DCEBF2", "#FFFFFF")
    s += waste_can(838, 590, 82, 112)
    s += rect(300, 280, 440, 422, 24, "url(#bodyH)")
    # termoprinter yuqorida
    s += path("M324 280 L348 214 Q352 204 364 204 H676 Q688 204 692 214 L716 280 Z", "url(#topP)", LINE, 3)
    s += rect(400, 236, 240, 20, 7, "url(#dark)", None)
    s += rect(420, 200, 200, 48, 3, "#FFFFFF", "#D2DAD5", 2, extra='transform="rotate(-1.5 520 224)"')
    s += line(436, 212, 560, 211, "#BFC9C2", 3) + line(436, 224, 520, 223, "#BFC9C2", 3)
    s += rect(400, 250, 240, 12, 4, "url(#dark)", None)
    # displey (3 gistogramma)
    s += monitor(330, 302, 380, 196, ui_hist(360, 176, 3))
    # namuna zondi
    s += rect(350, 520, 250, 150, 16, "url(#niche)", "#232B28", 2)
    s += tube(450, 596, None, "#B6403A", h=44, level=0.6)
    s += rect(454, 530, 24, 62, 7, "url(#metal)", "#8E9B94", 2)
    s += rect(462, 592, 8, 40, 3, "#7B8781", None)
    s += rect(528, 546, 56, 56, 12, "#F4F7F5", LINE, 3)
    s += ell(556, 574, 15, 15, "#6FCF7F", "#FFFFFF", 3)
    s += rect(620, 540, 90, 110, 12, "#F4F7F5", LINE, 3)
    s += vents(638, 574, 54, 4)
    s += led(642, 556, "#6FCF7F", 6)
    return s


# =========================================================================
# 5. Xemilyuminessent / immunoanaliz analizatori
# =========================================================================
def immunoassay():
    s = ground(580, 500)
    s += hose("M114 520 V 462 H 280", "#7FB3C8")
    s += hose("M220 544 V 500 H 280", "#D98BA6")
    s += jug(62, 520, 104, 182, "#7FB3C8", "#DCEBF2", 0.75)
    s += jug(180, 544, 80, 158, "#D98BA6", "#F5DCE5", 0.6)
    # korpus
    s += rect(270, 384, 640, 318, 22, "url(#bodyH)")
    s += path("M270 384 L308 214 Q312 202 324 202 H856 Q868 202 872 214 L910 384 Z", "url(#deck)", LINE, 3)
    s += deck_clip("dc", "M282 380 L318 220 H862 L898 380 Z") + '<g clip-path="url(#dc)">'
    s += rect(270, 214, 640, 170, 0, "#D4DDD7", None)
    s += pack_tray(450, 262, 358, 232, 286)
    s += reaction_ring(676, 318, 96, 26, 13, n=24)
    # kyuveta bunkeri
    s += rect(792, 240, 78, 52, 6, "#F4F7F5", LINE, 2)
    for i in range(6):
        s += rect(802 + i * 11, 250, 7, 30, 2, "#EAF6FA", "#9FB3AA", 1)
    s += probe_arm(580, 252, [(540, 286), (470, 306)], 24)
    s += probe_arm(740, 250, [(702, 286), (672, 306)], 24)
    s += rect(574, 346, 42, 20, 4, "#9FB3AA", "#7C8C84", 1.5)
    s += rect(582, 351, 26, 9, 3, "#6F7F77", None)
    s += "</g>"
    s += '<path d="M282 380 L318 220 H640 L560 380 Z" fill="url(#glass)"/>'
    s += rect(266, 374, 648, 22, 9, "#DCE4DF", LINE, 3)
    # namuna rakasi uyasi
    s += rect(306, 428, 260, 236, 16, "url(#niche)", "#232B28", 2)
    s += rack(328, 640, 4, h=96)
    # detektor modul (yorug'lik belgisi)
    s += rect(600, 428, 118, 112, 14, "#F4F7F5", LINE, 3)
    s += '<g transform="translate(659,484)">' + "".join(
        line(math.cos(a) * 14, math.sin(a) * 14, math.cos(a) * 28, math.sin(a) * 28, "#E3B93C", 4)
        for a in [i * math.pi / 4 for i in range(8)]) + ell(0, 0, 9, 9, "#E3B93C", None) + "</g>"
    s += rect(740, 436, 156, 104, 14, "#F4F7F5", LINE, 3)
    s += vents(762, 462, 112, 5)
    s += led(752, 450)
    # chiqindi tortmasi
    s += rect(600, 560, 296, 104, 14, "#F4F7F5", LINE, 3)
    s += rect(622, 584, 254, 40, 8, "#E3E9E5", "#C3CCC6", 2)
    s += rect(748, 640, 100, 10, 5, "#CBD3CE", None)
    s += monitor(950, 232, 214, 156, ui_bars(194, 136, 4), arm=[(910, 450), (1056, 450), (1056, 388)])
    return s


# =========================================================================
# 6. Siydik test-chiziq o'quvchisi (yarim avtomatik)
# =========================================================================
def urine_strip():
    s = ground(560, 380, ry=18)
    s += rect(330, 300, 520, 402, 26, "url(#bodyH)")
    # tepa qopqoq
    s += path("M354 300 L384 214 Q388 202 400 202 H780 Q792 202 796 214 L826 300 Z", "url(#topP)", LINE, 3)
    s += rect(430, 226, 320, 50, 12, "url(#dark)", None)
    s += rect(446, 240, 288, 22, 5, "#EEF2EF", None)
    # displey
    s += monitor(372, 322, 270, 160, ui_bars(250, 140, 4))
    for r in range(2):
        for c in range(3):
            s += rect(666 + c * 54, 332 + r * 44, 44, 34, 9, "#FFFFFF", "#C3CCC6", 2)
    s += led(690, 440, "#6FCF7F", 7)
    s += rect(716, 434, 80, 12, 6, "#DDE5DF", None)
    # chiziq lotogi
    s += rect(372, 520, 440, 120, 16, "url(#niche)", "#232B28", 2)
    s += rect(396, 548, 392, 58, 8, "#CBD3CE", "#9FB3AA", 2)
    s += rect(404, 556, 376, 42, 6, "#E3E9E5", None)
    s += strip_pads(430, 566, 10, 30, 22, 22)
    s += rect(782, 556, 56, 42, 8, "#FFFFFF", "#C3CCC6", 2)
    # siydik idishi va chiziq
    s += rect(86, 600, 120, 102, 18, "#F2F5F3", "#C3CCC6", 3)
    s += rect(98, 640, 96, 52, 10, "url(#liquid)", None, extra='opacity="0.9"')
    s += rect(92, 582, 108, 30, 9, "#FFFFFF", "#C3CCC6", 3)
    s += rect(118, 520, 18, 100, 4, "#E7D58A", "#FFFFFF", 1.5, extra='transform="rotate(12 127 570)"')
    # ishlatilgan chiziqlar qutisi
    s += rect(878, 590, 180, 112, 14, "#E6EAE7", "#BFC9C2", 3)
    s += rect(896, 608, 144, 14, 6, "#CBD3CE", None)
    return s


# =========================================================================
# 7. Siydik tahlili tizimi (chiziq + cho'kma) — ikki modul + raka yo'li
# =========================================================================
def urine_system():
    s = ground(600, 520)
    # tashqi idishlar (modullar orqasida)
    s += hose("M1010 640 V 520 H 920", "#7FB3C8")
    s += hose("M1104 640 V 560 H 920", "#9AA6A0")
    s += bottle(970, 580, 76, 122, "#7FB3C8", "#DCEBF2", "#FFFFFF")
    s += waste_can(1060, 590, 90, 112)
    # chap modul: kimyoviy (chiziq)
    s += rect(110, 300, 380, 402, 22, "url(#bodyH)")
    s += path("M110 300 L134 238 Q138 228 150 228 H450 Q462 228 466 238 L490 300 Z", "url(#topP)", LINE, 3)
    s += rect(160, 246, 280, 34, 9, "url(#dark)", None)
    s += rect(176, 254, 248, 14, 4, "#EEF2EF", None)
    s += rect(142, 322, 316, 92, 14, "url(#niche)", "#232B28", 2)
    s += line(156, 338, 444, 338, "#5F6B65", 3) + line(156, 398, 444, 398, "#5F6B65", 3)
    s += strip_pads(178, 352, 8, 32, 22, 22)
    s += led(136, 438, "#6FCF7F", 6)
    s += rect(142, 456, 316, 70, 12, "#F4F7F5", LINE, 3) + vents(166, 474, 200, 4, 11)
    # o'ng modul: cho'kma (oqim sitometriya)
    s += rect(520, 210, 400, 492, 24, "url(#bodyH)")
    s += monitor(552, 236, 336, 200, ui_scatter(316, 180))
    s += rect(552, 460, 336, 66, 14, "#F4F7F5", LINE, 3)
    s += ell(610, 493, 22, 22, "url(#dark)", "#9FB3AA", 3) + ell(610, 493, 9, 9, "#EAF6FA")
    s += rect(660, 478, 200, 10, 5, "#DDE5DF", None) + rect(660, 498, 140, 10, 5, "#DDE5DF", None)
    # namuna yo'li (modullar oldida)
    s += rect(60, 560, 920, 76, 16, "url(#metal)", "#8E9B94", 3)
    s += rect(72, 574, 896, 48, 10, "url(#niche)", None)
    for i in range(12):
        s += line(90 + i * 75, 580, 90 + i * 75, 616, "#4E5A55", 2)
    # igna bloklari (yo'l ustida)
    for nx in (307, 711):
        s += rect(nx - 20, 500, 40, 42, 8, "url(#metal)", "#8E9B94", 2) + line(nx, 542, nx, 566, "#4C5853", 3)
    yel = ["#E3B93C"] * 5
    s += rack(236, 646, 5, caps=yel, fills=["#F0D36B", "#E8C64F", "#F0D36B", "#E0B73A", "#EBCB5A"], step=44, h=82)
    s += rack(640, 646, 4, caps=["#9AA6A0"] * 4, fills=["#F0D36B", "#E8C64F", "#F0D36B", "#E0B73A"], step=44, h=82)
    return s


# nom: (funksiya, tepa y, masshtab) — chizma tik markazlanadi va kartani to'ldiradi.
SCENES = {
    "chemistry": (chemistry, 220, 1.0),
    "photometer": (photometer, 178, 1.2),
    "hematology5": (hematology5, 156, 1.15),
    "hematology3": (hematology3, 188, 1.2),
    "immunoassay": (immunoassay, 202, 1.0),
    "urine_strip": (urine_strip, 202, 1.1),
    "urine_system": (urine_system, 210, 1.0),
}


def framed(fn, top, k):
    ty = 395 - k * (top + GROUND) / 2
    return f'<g transform="translate({600 * (1 - k):g},{ty:g}) scale({k:g})">{fn()}</g>'

if __name__ == "__main__":
    for name, (fn, top, k) in SCENES.items():
        (HERE / f"{name}.svg").write_text(svg(framed(fn, top, k)), encoding="utf-8")
        print("svg", name)
