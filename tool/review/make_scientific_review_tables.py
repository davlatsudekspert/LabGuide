#!/usr/bin/env python3
"""LabGuide: sxema va apparat chizmalari uchun ILMIY TEKSHIRUV jadvali.

Egasi topshirig‘i (4-band, 2026-10-25): 18 ta sxema (6 mavzu × uz/ru/en) va
32 ta apparat sxematik chizmasidagi har bir da’vo — alohida jadvalda, manbasi,
holati, kerakli mutaxassis profili va xato bo‘lsa xavfi bilan. Manbasiz
ma’lumot hech qachon “tasdiqlangan” deb belgilanmaydi:
specialist_decision / reviewed_by / review_date ustunlari DOIM bo‘sh.

Faqat stdlib. Hamma narsa repodagi manba fayllardan deterministik yaratiladi:

    python3 tool/review/make_scientific_review_tables.py          # yozadi
    python3 tool/review/make_scientific_review_tables.py --check  # farq bo‘lsa 1

Kirish fayllari (o‘zgartirilmaydi):
  docs/DIAGRAMS_CONTENT_SOURCES.md, docs/DIAGRAMS_PROVENANCE.md,
  docs/SCHEMATIC_PARTS_SOURCES.md, docs/SCHEMATICS_PROVENANCE.md,
  docs/LAB_CARD_IMAGE_COVERAGE.md, docs/expert_signoff_registry.json,
  docs/DECISIONS.md, docs/L10N_TERMINOLOGY_DECISIONS.md,
  assets/instruments/schematic_parts.json, assets/instruments/catalog.json,
  assets/diagrams/*.png, assets/instruments/schematic/*.png,
  tool/diagrams/gen_diagrams.py (T lug‘ati, ast orqali),
  tool/illustrations/schematic/parts_src.py, tool/illustrations/schematic/gen.py,
  lib/l10n/app_{uz,ru,en}.arb, lib/features/instruments/lab_direction_{card,screens}.dart.

Chiqish:
  docs/SCIENTIFIC_REVIEW_TABLE.csv            (UTF-8 BOM; bitta qator — bitta da’vo)
  docs/SCIENTIFIC_REVIEW_TABLE.md             (o‘zbekcha, qaror uchun xulosa)
  docs/review_packets_tech/<profil>.csv       (har mutaxassis profiliga bitta paket)
"""

import ast
import csv
import hashlib
import importlib.util
import io
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
DOCS = ROOT / "docs"
OUT_CSV = DOCS / "SCIENTIFIC_REVIEW_TABLE.csv"
OUT_MD = DOCS / "SCIENTIFIC_REVIEW_TABLE.md"
OUT_PACKETS = DOCS / "review_packets_tech"
LANGS = ("uz", "ru", "en")
DATE = "2026-10-25"

COLUMNS = [
    "item_id", "kind", "artifact", "statement", "what_to_check", "source_evidence",
    "evidence_status", "reviewer_profile", "risk_if_wrong",
    "specialist_decision", "reviewed_by", "review_date",
]
STATUSES = ("SOURCED", "STANDARD_TEXTBOOK", "NEEDS_SOURCE", "NEEDS_EXPERT", "APP_RULE_AWAITING_EXPERT")
# Ehtiyotkorlik darajasi: ikki manba kelishmasa — kattarog‘i olinadi.
CAUTION = {"SOURCED": 0, "STANDARD_TEXTBOOK": 1, "NEEDS_EXPERT": 2, "APP_RULE_AWAITING_EXPERT": 2, "NEEDS_SOURCE": 3}
RISK_W = {"high": 3, "medium": 2, "low": 1}
STATUS_W = {"NEEDS_SOURCE": 4, "APP_RULE_AWAITING_EXPERT": 3, "NEEDS_EXPERT": 3, "STANDARD_TEXTBOOK": 2, "SOURCED": 1}

FINDINGS = []  # (kod, matn) — "Topilgan nomuvofiqliklar"


def finding(code, text):
    if (code, text) not in FINDINGS:
        FINDINGS.append((code, text))


def rel(p):
    return str(pathlib.Path(p).relative_to(ROOT))


def read(p):
    return (ROOT / p).read_text(encoding="utf-8")


def sha256(p):
    return hashlib.sha256((ROOT / p).read_bytes()).hexdigest()


def line_of(path, needle, start=1):
    """1-asosli qator raqami (start dan boshlab); topilmasa — xato (manba o‘zgargan)."""
    lines = read(path).splitlines()
    for i in range(start - 1, len(lines)):
        if needle in lines[i]:
            return i + 1
    raise SystemExit(f"{path}: '{needle}' topilmadi (manba o‘zgargan — skriptni yangilang)")


# ============================================================ mutaxassis profillari
P = {
    "bio": "klinik biokimyogar",
    "hem": "gematolog",
    "mic": "mikrobiolog",
    "tb": "sil (TB) laboratoriyasi mutaxassisi",
    "mol": "molekulyar diagnost",
    "imm": "immunolog",
    "tox": "toksikolog (analitik kimyogar)",
    "trf": "transfuziolog (immunogematolog)",
    "qm": "laboratoriya sifat menejeri / metrolog",
    "bs": "biologik xavfsizlik mutaxassisi",
    "rep": "reproduktiv laboratoriya mutaxassisi (androlog)",
    "clin": "klinik laboratoriya shifokori (umumiy klinik tahlillar)",
    "edu": "tibbiy pedagog",
    "ling_uz": "tibbiy tilshunos (uz)",
    "ling_ru": "tibbiy tilshunos (ru)",
}
SLUG = {
    P["bio"]: "klinik_biokimyogar", P["hem"]: "gematolog", P["mic"]: "mikrobiolog",
    P["tb"]: "sil_laboratoriyasi_mutaxassisi", P["mol"]: "molekulyar_diagnost", P["imm"]: "immunolog",
    P["tox"]: "toksikolog", P["trf"]: "transfuziolog", P["qm"]: "sifat_menejeri_metrolog",
    P["bs"]: "biologik_xavfsizlik_mutaxassisi", P["rep"]: "reproduktiv_laboratoriya_mutaxassisi",
    P["clin"]: "klinik_laboratoriya_shifokori", P["edu"]: "tibbiy_pedagog",
    P["ling_uz"]: "tibbiy_tilshunos_uz", P["ling_ru"]: "tibbiy_tilshunos_ru",
}
DIAG_PROFILE = {
    "qc_decision": P["bio"], "calibration_overview": P["qm"], "differential_count": P["hem"],
    "photometry": P["bio"], "preanalytics": P["clin"], "educational_feedback": P["edu"],
}
SCHEM_PROFILE = {
    "chemistry": P["bio"], "photometer": P["bio"], "hematology5": P["hem"], "hematology3": P["hem"],
    "immunoassay": P["bio"], "urine_strip": P["clin"], "urine_system": P["clin"],
    "mass_spec_gc": P["tox"], "mass_spec_lc": P["tox"], "maldi_tof": P["mic"],
    "microbial_id_ast": P["mic"], "blood_culture": P["mic"], "mycobacterial_culture": P["tb"],
    "flow_cytometer": P["imm"], "real_time_pcr": P["mol"], "cartridge_molecular": P["tb"],
    "coag_analyzer": P["hem"], "elisa_reader": P["imm"], "bsc_class2": P["bs"], "autoclave": P["bs"],
    "blood_gas_ise": P["bio"], "hba1c_analyzer": P["bio"], "lab_fridge": P["qm"],
    "fluorescence_microscope": P["tb"], "casa": P["rep"], "gel_card_system": P["trf"],
    "esr_analyzer": P["hem"], "aggregometer": P["hem"], "electrophoresis": P["bio"],
    "osmometer": P["bio"], "tlc": P["tox"], "analytical_balance": P["qm"],
}

# ============================================================ xavf (risk) qoidalari
R_PART_MED = "qism vazifasi xato bo‘lsa, talaba apparat ishlashini noto‘g‘ri tushunadi (bemor natijasiga bevosita ta’sir yo‘q)"
R_PART_LOW = "umumiy yordamchi qism; xato faqat o‘quv tafsilotiga ta’sir qiladi"
R_PRIN_MED = "ishlash prinsipi xato bo‘lsa, usul cheklovlari va xato manbalari noto‘g‘ri o‘rgatiladi"
R_RES_MED = "natija tavsifi xato bo‘lsa, talaba hisobotni noto‘g‘ri o‘qishi mumkin"
R_DRAW_LOW = "chizma soddalashtirilgan; matn panelida tushuntirilgan, chalg‘itish xavfi kichik"
R_TR_LOW = "atama/uslub; ma’noni o‘zgartirmasa ham o‘quvchini chalg‘itishi mumkin"
R_TR_MED = "qaror/harakat qatori; noto‘g‘ri tarjima noto‘g‘ri harakatga olib kelishi mumkin"
GENERIC_SLUGS = {"printer", "display", "waste", "computer", "software", "data", "panel", "bin", "solidwaste",
                 "liquids", "eyepieces", "focus", "lights", "enclosure", "pan", "buffer", "controller"}

HIGH = {
    # diagrammalar
    "DIAG-qc_decision-03": "rad qoidasi noto‘g‘ri bo‘lsa, nazoratdan chiqqan seriya natijalari bemorga beriladi",
    "DIAG-qc_decision-04": "1-2s ni noto‘g‘ri talqin qilish seriyani asossiz qabul/rad qilishga olib keladi",
    "DIAG-qc_decision-05": "rad qilingan seriyada bemor natijasi berilsa — noto‘g‘ri klinik qaror",
    "DIAG-calibration_overview-06": "kalibrlash noto‘g‘ri qabul qilinsa, keyingi barcha natijalar sistematik xato bo‘ladi",
    "DIAG-calibration_overview-07": "qabul qilinmagan kalibrlash bilan ishlash — sistematik xato",
    "DIAG-differential_count-06": "blast/aniqlanmagan hujayra yo‘llanmasa — o‘tkir leykozni kechiktirish xavfi",
    "DIAG-photometry-05": "hisob formulasi xato bo‘lsa — bemor natijasi xato",
    "DIAG-photometry-06": "suyultirish omili unutilsa — natija bir necha marta past chiqadi",
    "DIAG-preanalytics-06": "yaroqsiz namuna tahlilga ketsa — noto‘g‘ri natija bemorga beriladi",
    # sxemalar
    "SCHEM-autoclave-principle": "sterilizatsiya harorat/bosim/vaqt sharti noto‘g‘ri o‘rgatilsa — sterillanmagan material, infeksiya xavfi",
    "SCHEM-autoclave-result": "samaradorlik indikatorlari noto‘g‘ri tushunilsa — sterillanmagan yuk ishlatiladi",
    "SCHEM-bsc_class2-principle": "havo oqimi himoyasi noto‘g‘ri tushunilsa — operator infeksiyalanishi xavfi",
    "SCHEM-bsc_class2-result": "shkaf sinovi/sertifikati ahamiyati tushunilmasa — himoyasiz ishlash",
    "SCHEM-bsc_class2-part-02": "old panjarani to‘sish operator himoyasini buzadi",
    "SCHEM-mycobacterial_culture-result": "DST talqini (1/2-qator) xato bo‘lsa — sil davolash rejimi noto‘g‘ri",
    "SCHEM-microbial_id_ast-result": "MIK va S/R toifasi xato tushunilsa — noto‘g‘ri antibiotik tanlovi",
    "SCHEM-cartridge_molecular-result": "MTB/RIF natijasi noto‘g‘ri o‘qilsa — sil/rifampitsin chidamliligi bo‘yicha noto‘g‘ri qaror",
    "SCHEM-gel_card_system-result": "qon guruhi/DAT reaksiyasini noto‘g‘ri o‘qish — mos kelmaydigan transfuziya xavfi",
    "SCHEM-gel_card_system-part-06": "musbat reaksiya ko‘rinishi xato bo‘lsa — qon guruhi xato aniqlanadi",
    "SCHEM-gel_card_system-part-07": "manfiy reaksiya ko‘rinishi xato bo‘lsa — qon guruhi xato aniqlanadi",
    "SCHEM-coag_analyzer-result": "INR hisobi (ISI) xato tushunilsa — antikoagulyant dozasi bo‘yicha xato",
    "SCHEM-real_time_pcr-result": "Cq/virus yuki talqini xato bo‘lsa — OIV davolash monitoringida xato",
    "SCHEM-fluorescence_microscope-result": "KChT (AFB) darajalash xato bo‘lsa — sil tashxisi/kuzatuvida xato",
    "SCHEM-flow_cytometer-result": "mutlaq CD4 hisobi xato tushunilsa — OIV bosqichi bo‘yicha xato",
}
MED_DRAW = {}  # drawing qatorlari uchun alohida (pastda DRAW ichida)

# ============================================================ manba hujjatlari
REGISTRY = json.loads(read("docs/expert_signoff_registry.json"))
REG = {e["id"]: e for e in REGISTRY["entries"]}
ARB = {lang: json.loads(read(f"lib/l10n/app_{lang}.arb")) for lang in LANGS}
CATALOG = json.loads(read("assets/instruments/catalog.json"))
SPARTS = json.loads(read("assets/instruments/schematic_parts.json"))["schematics"]


def arb(key, lang):
    v = ARB[lang].get(key)
    if v is None:
        raise SystemExit(f"ARB {lang}: {key} yo‘q")
    return v


def arb_line(key, lang="en"):
    return line_of(f"lib/l10n/app_{lang}.arb", f'"{key}":')


def tri(get):
    return " || ".join(f"{lang}: {get(lang)}" for lang in LANGS)


# ------------------------------------------------------------ katalog korpusi
def strings(node):
    if isinstance(node, str):
        yield node
    elif isinstance(node, dict):
        for k, v in node.items():
            if k in ("id", "url", "accessed"):
                continue
            yield from strings(v)
    elif isinstance(node, list):
        for v in node:
            yield from strings(v)


def node_sources(node):
    sids = []
    if isinstance(node.get("sources"), list):
        sids += [s if isinstance(s, str) else s.get("id") for s in node["sources"]]
    if isinstance(node.get("source"), str):
        sids.append(node["source"])
    if isinstance(node.get("official_page"), str):
        sids.append(node["official_page"])
    return [s for s in sids if s]


SRC_CORPUS = {}


def walk(node):
    if isinstance(node, dict):
        txt = " ".join(strings(node))
        for sid in node_sources(node):
            SRC_CORPUS.setdefault(sid, []).append(txt)
        for v in node.values():
            walk(v)
    elif isinstance(node, list):
        for v in node:
            walk(v)


walk(CATALOG["models"])
walk(CATALOG["lab_cards"])
SOURCES = {s["id"]: s for s in CATALOG["sources"]}
DEFAULT_SCHEM = {"chemistry": "chemistry", "hematology": "hematology5", "immunoassay": "immunoassay",
                 "urinalysis": "urine_strip"}
SCHEM_USERS = {}  # kalit -> [(tur, id, node)]
for m in CATALOG["models"]:
    k = m.get("schematic") or DEFAULT_SCHEM[m["category"]]
    SCHEM_USERS.setdefault(k, []).append(("model", m["id"], m))
for c in CATALOG["lab_cards"]:
    if c.get("schematic"):
        SCHEM_USERS.setdefault(c["schematic"], []).append(("lab_card", c["id"], c))


def sids_in(node):
    out = set()
    if isinstance(node, dict):
        out |= set(node_sources(node))
        for v in node.values():
            out |= sids_in(v)
    elif isinstance(node, list):
        for v in node:
            out |= sids_in(v)
    return out


UNIT_RE = re.compile(r"(?<![\w.-])(\d+(?:[.,]\d+)?)\s?-?\s?(°C|°|nm|mm|minutes?|hours?|wells?|tubes?|part|histograms|motile|cells)\b|"
                     r"(?<![\w.-])(\d+(?:[.,]\d+)?)\s?(°C|°)")
CODE_RE = re.compile(r"\b(?:[A-Za-z]+\d+[A-Za-z0-9]*|\d+[A-Z][A-Za-z0-9]*)\b")


def num_tokens(text):
    """Tekshiriladigan raqamli tafsilotlar: (raqam, birlik) juftlari va CD4/7H9/GF254 kabi kodlar.
    Birliksiz yalang‘och raqamlar (alpha-1, HIV-1) — nom qismi, tekshirilmaydi."""
    seen, out = set(), []
    for m in UNIT_RE.finditer(text):
        num, unit = (m.group(1), m.group(2)) if m.group(1) else (m.group(3), m.group(4))
        t = (num, unit)
        if t not in seen:
            seen.add(t)
            out.append(t)
    for c in CODE_RE.findall(text):
        if c not in seen:
            seen.add(c)
            out.append(c)
    return out


def tok_str(t):
    return f"{t[0]} {t[1]}" if isinstance(t, tuple) else t


def found(token, texts):
    if isinstance(token, tuple):
        num, unit = token
        variants = {num, num.replace(".", ","), num.replace(",", ".")}
        u = "°" if unit.startswith("°") else re.escape(unit[:2])
        pat = re.compile(r"(?<![\d.,])(" + "|".join(re.escape(v) for v in variants) + r")\s?-?\s?" + u, re.I)
        return any(pat.search(t) for t in texts)
    low = token.lower()
    return any(low in t.lower() for t in texts)


# ============================================================ DIAGRAMMALAR
def load_T():
    tree = ast.parse(read("tool/diagrams/gen_diagrams.py"))
    out = {}
    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
            if node.targets[0].id in ("T", "YES", "NO"):
                out[node.targets[0].id] = ast.literal_eval(node.value)
    return out


TT = load_T()
T, YES, NO = TT["T"], TT["YES"], TT["NO"]
TOPICS = ["qc_decision", "calibration_overview", "differential_count", "photometry", "preanalytics",
          "educational_feedback"]
ALT_KEY = {"qc_decision": "imgDiagramQcDecisionAlt", "calibration_overview": "imgDiagramCalibrationOverviewAlt",
           "differential_count": "imgDiagramDifferentialCountAlt", "photometry": "imgDiagramPhotometryAlt",
           "preanalytics": "imgDiagramPreanalyticsAlt", "educational_feedback": "imgDiagramEducationalFeedbackAlt"}
DOC_PREFIX = {"qc_decision": "QC", "calibration_overview": "CAL", "differential_count": "DIF", "photometry": "PHO",
              "preanalytics": "PRE", "educational_feedback": "EDU"}
# da’vo ID -> gen_diagrams.py T kalitlari (qism indeksi: None — to‘liq, 0/1 — juftning qismi)
CLAIM_KEYS = {
    "QC-1": [("s1", None)], "QC-2": [("s2", None)], "QC-3": [("d", None)], "QC-4": [("ok", None)],
    "QC-5": [("r1", None)], "QC-6": [("r2", None)], "QC-7": [("r3", None)], "QC-8": [("r4", None)],
    "QC-9": [("footer", None)],
    "CAL-1": [("s1", None)], "CAL-2": [("s2", None)], "CAL-3": [("s3", None)], "CAL-4": [("s4", None)],
    "CAL-5": [("d", None)], "CAL-6": [("ok", None)], "CAL-7": [("no", None)], "CAL-8": [("footer", None)],
    "DIF-1": [("s1", None)], "DIF-2": [("s1", 1)], "DIF-3": [("s2", None)], "DIF-4": [("s3", None)],
    "DIF-5": [("s4", None)], "DIF-6": [("d2", None), ("refer", None)], "DIF-7": [("report", None)],
    "DIF-8": [("footer", None)],
    "PHO-1": [("bench", None)], "PHO-2": [("f1", None)], "PHO-3": [("f2", None)], "PHO-4": [("s1", 0)],
    "PHO-5": [("s1", 1)], "PHO-6": [("d", None)], "PHO-7": [("footer", None)],
    "PRE-1": [("s1", None)], "PRE-2": [("s2", None)], "PRE-3": [("s3", None)], "PRE-4": [("s4", None)],
    "PRE-5": [("s5", None)], "PRE-6": [("d", None), ("ok", None), ("no", None)], "PRE-7": [("footer", None)],
    "EDU-1": [("s1", None), ("s2", None)], "EDU-2": [("d", None), ("done", None)], "EDU-3": [("s3", None)],
    "EDU-4": [("s4", None)], "EDU-5": [("footer", None)],
}
# chizmada T dan tashqari chiziladigan matn (formulalar, optik yo‘l belgilari)
DRAWN_EXTRA = {
    "PHO-1": "chizmada: I₀ (kyuvetaga tushuvchi nur), I (o‘tgan nur), ℓ (kyuvetadagi optik yo‘l), natija ekranida A",
    "PHO-2": "formula: A = log₁₀(I₀ / I)",
    "PHO-3": "formula: A = ε · ℓ · c",
}
CHECK_DIAG = {
    "QC-1": "Ichki QC jarayonining birinchi qadami sifatida to‘g‘rimi (nazorat materiali bemor namunalari bilan bir seriyada).",
    "QC-2": "Maqsadli o‘rtacha va SD manbasi (laboratoriyaning o‘z ma’lumoti); Levey–Jennings grafigi atamasi uz/ru da.",
    "QC-3": "Rad qoidalari ro‘yxati (1-3s, 2-2s, R-4s, 4-1s, 10x) Westgard 1981 ga mosmi; ru/uz ‘Rad qoidasi’ atamasi.",
    "QC-4": "Ilova qarori D-20: 1-2s har seriyada faqat ogohlantirish, barcha rad qoidalari tekshiriladi (1981 dagi ‘1-2s eshik’ tartibidan qattiqroq) — klinik biokimyogar tasdiqlashi kerak.",
    "QC-5": "‘Rad: to‘xtating, bemor natijalarini bermang’ — WHO LQMS 7-6 ga mosmi (ru/uz ‘остановить/to‘xtating’ 2026-10-25 da qaytarildi).",
    "QC-6": "‘QC ni shunchaki takrorlamang’ — WHO LQMS 7-6 ga mosmi.",
    "QC-7": "‘QC va bemor namunalarini qayta tekshiring’ — WHO LQMS 7-6 ga mosmi (uz ‘bemor’ 2026-10-25 da qaytarildi).",
    "QC-8": "‘Nazorat tiklangach natija bering; choralarni yozing’ — ru ‘Выдача — после восстановления КК’ iborasi tushunarlimi.",
    "QC-9": "Iqtiboslar: Westgard 1981, WHO LQMS 2011; ‘SOP ustun’ izohi.",
    "CAL-1": "Kalibrlashdan oldin model, reagent va IFU versiyasini moslash talabi.",
    "CAL-2": "Kalibrator qiymatlari faqat shu lot qiymatlar varag‘idan — to‘g‘rimi.",
    "CAL-3": "‘Metodga mos tayyorlash’ — umumiy; IFU ga havola yetarlimi.",
    "CAL-4": "‘Yo‘riqnoma bo‘yicha kalibrlash’.",
    "CAL-5": "Kalibrlashdan keyin QC o‘tishi qabul sharti sifatida — ilova qoidasi (CALIB-ACCEPTANCE-RULES).",
    "CAL-6": "‘Vakolatli shaxs tomonidan qabul’ — ilova qoidasi (registry CALIB-ACCEPTANCE-RULES, AWAITING_EXPERT), ishlab chiqaruvchi chegarasi emas.",
    "CAL-7": "‘Qabul qilinmaydi — sabab IFU va SOP bo‘yicha’ — ilova qoidasi (CALIB-ACCEPTANCE-RULES).",
    "CAL-8": "‘Parametrlar faqat mos IFU dan’ izohi.",
    "DIF-1": "Surtma sifati mezonlari (tekis, chiziq va teshiksiz) — WHO 2003 §9.10.3.",
    "DIF-2": "‘Yomon surtma — yangisini tayyorlang’ — WHO 2003 dan amaliy xulosa (to‘g‘ridan-to‘g‘ri iqtibos emas).",
    "DIF-3": "Bir qavatli zona, ×100 immersion, bir yo‘nalish — WHO 2003 §9.10.4 ga mosmi (ru/uz ‘иммерсия/immersiya’ 2026-10-25 da qaytarildi).",
    "DIF-4": "‘Odatda 100 hujayra’ — WHO 2003 §9.13 (100) va Lyubina 1984 (200) farqi; SOP maqsadi.",
    "DIF-5": "Mutlaq son = ulush × WBC formulasi.",
    "DIF-6": "Blast/aniqlanmagan hujayrada yo‘llash matni — registry DIFF-REFER-BODY-WORDING (AWAITING_EXPERT).",
    "DIF-7": "Referens interval laboratoriya blankasidan — uz atamasi ‘referens interval’ (L10N_TERMINOLOGY_DECISIONS.md, NEEDS_NATIVE_REVIEW).",
    "DIF-8": "Pastki iqtibos ‘WHO 2003’ (ilova ARB `diffRangesWho` qisqa shakli); to‘liq nom: WHO ‘Manual of basic techniques for a health laboratory’, 2nd ed., 2003 (differential_sources.dart).",
    "PHO-1": "Optik yo‘l: manba → filtr → kyuveta → detektor; avtomatik analizatorlarda filtr o‘rniga monoxromator/panjara bo‘lishi mumkin (DIAGRAMS_PROVENANCE.md NEEDS_EXPERT 4-band).",
    "PHO-2": "A = log₁₀(I₀/I) ta’rifi; ‘Absorbance’ → ru ‘Поглощение (оптическая плотность)’, uz ‘Yutilish (optik zichlik)’ (ilova ARB iborasi; IUPAC farqi — atama qarori kerak).",
    "PHO-3": "Ber–Lambert qonuni A = ε·ℓ·c; ru/uz ‘Bugera–Lambert–Ber’ nomlanishi.",
    "PHO-4": "Blank → standart → namuna o‘lchash tartibi.",
    "PHO-5": "C = (A namuna ÷ A standart) × C standart — bir nuqtali kalibrlash formulasi.",
    "PHO-6": "Chiziqlilik chegarasidan oshsa: suyultirish, takrorlash, suyultirish omiliga ko‘paytirish.",
    "PHO-7": "To‘lqin uzunligi, blank va chegaralar reagent IFU sidan.",
    "PRE-1": "Bemor tayyorgarligi — WHO 2010.",
    "PRE-2": "Probirka tanlash va olish tartibi — WHO 2010 Table 2.3.",
    "PRE-3": "Identifikatsiya: to‘liq ism yo‘llanmaga mos (kamida ikki identifikator talab qilinadimi — SOP).",
    "PRE-4": "Ajratish va saqlash barqarorlik muddatida — WHO/DIL/LAB/99.1.",
    "PRE-5": "Tashish va qabulda yorliq va yo‘llanmani qayta tekshirish.",
    "PRE-6": "‘Namuna yaroqlimi?’ — yaroqlilik mezonlari ilovada sanalmagan, laboratoriya SOP’iga topshirilgan.",
    "PRE-7": "Iqtibos ‘WHO phlebotomy guidelines 2010’.",
    "EDU-1": "Ilova xatti-harakati (ilmiy da’vo emas): savollar → ball.",
    "EDU-2": "Ilova xatti-harakati: xato bo‘lmasa — qayta yoki boshqa mavzu.",
    "EDU-3": "Ilova xatti-harakati: xatolar tahlili (to‘g‘ri javob va izoh).",
    "EDU-4": "Ilova xatti-harakati: faqat xato savollarni qayta ishlash (halqa).",
    "EDU-5": "Izoh: ‘LabGuide mashqi tartibi — laboratoriya jarayoni emas’.",
}
# DIAGRAMS_CONTENT_SOURCES.md jadvalida yo‘q, lekin chizmada bor (o‘zimiz qo‘shgan qator)
EXTRA_CLAIMS = {"DIF-8": ("WHO 2003 · your lab SOP prevails", "—", "NEEDS_EXPERT")}
# Registr / qaror bog‘lanishlari (hujjat izohlaridan; skript mavjudligini tekshiradi)
REG_LINK = {"CAL-6": "CALIB-ACCEPTANCE-RULES", "CAL-7": "CALIB-ACCEPTANCE-RULES", "CAL-5": "CALIB-ACCEPTANCE-RULES",
            "DIF-6": "DIFF-REFER-BODY-WORDING"}
DECISION_LINK = {"QC-4": "D-20"}
DECK = "assets/lectures/decks/fotometriya-asoslari-biokimyo.{uz,ru,en}.json"
FOOTER_IDS = {"QC-9", "CAL-8", "DIF-8", "PHO-7", "PRE-7", "EDU-5"}
PROVENANCE_EXTRA = {"PHO-1": "monoxromator"}  # DIAGRAMS_PROVENANCE.md NEEDS_EXPERT ro‘yxati qamragan
DIAG_TR_MED = {"d", "d2", "ok", "no", "r1", "r2", "r3", "r4", "refer", "report"}
DIAG_TR_NOTE = {
    ("qc_decision", "r1", "ru"): "‘stop’ → ‘остановить’ (2026-10-25 da qaytarildi; ilova qc_guides_info.dart:76 dagi kabi).",
    ("qc_decision", "r1", "uz"): "‘stop’ → ‘to‘xtating’ (2026-10-25 da qaytarildi; ilova qc_guides_info.dart:76 dagi kabi).",
    ("qc_decision", "r3", "uz"): "‘patient samples’ → ‘bemor namunalarini’ (2026-10-25 da tuzatildi).",
    ("qc_decision", "r4", "ru"): "‘Выдача — после восстановления КК’ — qisqartirilgan ibora (DIAGRAMS_CONTENT_SOURCES ‘Til’ bo‘limi).",
    ("qc_decision", "r4", "uz"): "‘QC tiklangach natija bering’ — qisqartirilgan ibora (DIAGRAMS_CONTENT_SOURCES ‘Til’ bo‘limi).",
    ("differential_count", "s2", "ru"): "en ‘×100 oil’ → ‘иммерсия ×100’ (2026-10-25 da tuzatildi).",
    ("differential_count", "s2", "uz"): "en ‘×100 oil’ → ‘×100 immersiya’ (2026-10-25 da tuzatildi).",
    ("differential_count", "report", "uz"): "‘Referens interval’ — L10N_TERMINOLOGY_DECISIONS.md uz yagona atamasi (NEEDS_NATIVE_REVIEW); 2026-10-25 da ‘referens oraliq’ dan tuzatildi.",
    ("differential_count", "footer", "ru"): "‘ВОЗ 2003’ — ilova ARB `diffRangesWho` qisqa iqtibos shakli.",
    ("differential_count", "footer", "uz"): "‘JSST 2003’ — ilova ARB `diffRangesWho` qisqa iqtibos shakli.",
    ("photometry", "f1", "ru"): "‘Absorbance’ → ‘Поглощение (оптическая плотность)’ — ilova ARB iborasi (schemParts*); IUPAC: absorbance ≠ optical density — atama qarori kerak.",
    ("photometry", "f1", "uz"): "‘Absorbance’ → ‘Yutilish (optik zichlik)’ — ilova ARB iborasi (schemParts*); atama qarori kerak.",
    ("photometry", "f2", "ru"): "‘Beer–Lambert’ → ‘Бугера–Ламберта–Бера’ (rus an’anasi).",
    ("photometry", "f2", "uz"): "‘Beer–Lambert’ → ‘Buger–Lambert–Ber’.",
}


def tval(topic, key, lang, part=None):
    v = T[topic][key][lang]
    if part is not None:
        return v[part]
    if isinstance(v, tuple):
        return " — ".join(v)
    if isinstance(v, list):
        return " → ".join(v)
    return v


def parse_diag_doc():
    doc = read("docs/DIAGRAMS_CONTENT_SOURCES.md")
    rows, notes = {}, {}
    cur = None
    for i, ln in enumerate(doc.splitlines(), 1):
        m = re.match(r"^## (\w+) — ", ln)
        if m:
            cur = m.group(1)
            continue
        m = re.match(r"^\| ((?:QC|CAL|DIF|PHO|PRE|EDU)-\d+) \| (.+?) \| (.+) \| (.+?) \|$", ln)
        if m:
            rows[m.group(1)] = (m.group(2), m.group(3), m.group(4), i, cur)
            continue
        if ln.startswith("NEEDS_EXPERT:") and cur:
            for x in re.findall(r"\b((?:QC|CAL|DIF|PHO|PRE|EDU)-\d+)", ln):
                notes.setdefault(x, i)
    return rows, notes


def map_doc_status(s):
    s = s.strip()
    if s == "SOURCED":
        return "SOURCED"
    if s == "STANDARD_TEXTBOOK":
        return "STANDARD_TEXTBOOK"
    if s == "NEEDS_EXPERT":
        return "NEEDS_EXPERT"
    if "STANDARD_TEXTBOOK" in s and "NEEDS_EXPERT" in s:
        return "NEEDS_EXPERT"
    if s == "APP_UI":
        return "APP_RULE_AWAITING_EXPERT"
    raise SystemExit(f"noma’lum holat: {s}")


def risk(item_id, default_level, default_reason):
    if item_id in HIGH:
        return f"high — {HIGH[item_id]}"
    return f"{default_level} — {default_reason}"


ROWS = []


def add(**kw):
    row = {c: "" for c in COLUMNS}
    row.update(kw)
    for c in ("specialist_decision", "reviewed_by", "review_date"):
        row[c] = ""
    assert row["evidence_status"] in STATUSES, row
    ROWS.append(row)


def diagram_rows():
    rows, notes = parse_diag_doc()
    prov = read("docs/DIAGRAMS_PROVENANCE.md")
    decisions = read("docs/DECISIONS.md")
    doc_path = "docs/DIAGRAMS_CONTENT_SOURCES.md"
    for cid, reg in REG_LINK.items():
        if REG[reg]["status"] != "AWAITING_EXPERT":
            raise SystemExit(f"{reg} holati o‘zgardi")
    for cid, d in DECISION_LINK.items():
        if f"## {d}." not in decisions:
            raise SystemExit(f"DECISIONS.md: {d} yo‘q")
    for lang in LANGS:
        if not (ROOT / DECK.replace("{uz,ru,en}", lang)).exists():
            raise SystemExit(f"{DECK}: {lang} yo‘q")
    for cid, needle in PROVENANCE_EXTRA.items():
        if needle not in prov:
            raise SystemExit(f"DIAGRAMS_PROVENANCE.md: {needle} yo‘q")
    # provenance sha256 tekshiruvi
    prov_sha = dict(re.findall(r"^\| `(\w+\.(?:uz|ru|en)\.png)` \| [^|]+\| [^|]+\| [^|]+\| `([0-9a-f]{64})`", prov, re.M))
    gen_path = "tool/diagrams/gen_diagrams.py"
    for topic in TOPICS:
        pngs = [f"assets/diagrams/{topic}.{lang}.png" for lang in LANGS]
        shas = []
        for p in pngs:
            h = sha256(p)
            shas.append(h[:12])
            name = pathlib.Path(p).name
            if prov_sha.get(name) != h:
                finding("PNG-SHA", f"`{p}`: sha256 DIAGRAMS_PROVENANCE.md dagi qiymatga mos emas (fayl hujjatlashtirilgandan keyin o‘zgargan).")
        art_png = f"assets/diagrams/{topic}.{{uz,ru,en}}.png (sha256 {', '.join(shas)})"
        prefix = DOC_PREFIX[topic]
        tline = line_of(gen_path, f'"{topic}": {{')
        ids = sorted([k for k in CLAIM_KEYS if k.startswith(prefix + "-")], key=lambda x: int(x.split("-")[1]))
        topic_statuses = []
        for cid in ids:
            n = int(cid.split("-")[1])
            item = f"DIAG-{topic}-{n:02d}"
            keys = CLAIM_KEYS[cid]
            klines = [line_of(gen_path, f'"{k}": {{', tline) for k, _ in keys]

            def stmt(lang):
                s = " / ".join(tval(topic, k, lang, part) for k, part in keys)
                return s

            statement = tri(stmt)
            if cid in DRAWN_EXTRA:
                statement += f" || {DRAWN_EXTRA[cid]}"
            if cid in rows:
                en_doc, src_doc, st_doc, dline, sect = rows[cid]
                if sect != topic:
                    raise SystemExit(f"{cid}: bo‘lim {sect} != {topic}")
                status = map_doc_status(st_doc)
                src_txt = src_doc.strip()
                if topic == "photometry" and src_txt != "—":
                    src_txt = f"{DECK} (Aripov A.N. va b., 2006) — {src_txt}"
                evid = (f"src: {src_txt}" if src_txt not in ("—", "") else "NONE") + f"; doc: {doc_path}:{dline} ({cid})"
                why = []
                if st_doc.strip() != status:
                    why.append(f"hujjatdagi holat ‘{st_doc.strip()}’ → ehtiyotkor talqin {status}")
                if cid in notes and status == "SOURCED":
                    status = "NEEDS_EXPERT"
                    why.append(f"jadvalda SOURCED, lekin {doc_path}:{notes[cid]} NEEDS_EXPERT izohida — ehtiyotkorrog‘i olindi")
                    finding("DOC-DISAGREE", f"{doc_path}: {cid} jadvalda `SOURCED`, lekin shu bo‘limning NEEDS_EXPERT izohida (qator {notes[cid]}) mutaxassis tasdig‘i talab qilingan — jadvalda ehtiyotkor holat olindi.")
                if cid in PROVENANCE_EXTRA and status == "SOURCED":
                    status = "NEEDS_EXPERT"
                    pl = line_of("docs/DIAGRAMS_PROVENANCE.md", PROVENANCE_EXTRA[cid])
                    why.append(f"docs/DIAGRAMS_PROVENANCE.md:{pl} NEEDS_EXPERT ro‘yxatida — ehtiyotkorrog‘i olindi")
                    finding("DOC-DISAGREE", f"{cid} (fotometriya optik yo‘li): DIAGRAMS_CONTENT_SOURCES.md da `SOURCED`, DIAGRAMS_PROVENANCE.md:{pl} da NEEDS_EXPERT (filtr o‘rniga monoxromator) — ehtiyotkorrog‘i olindi.")
                if cid in REG_LINK:
                    reg = REG_LINK[cid]
                    if status == "SOURCED":
                        why.append(f"jadvalda SOURCED, lekin registr {reg} bu qabul qoidasini ilova qoidasi (AWAITING_EXPERT) deydi — ehtiyotkorrog‘i olindi")
                        finding("DOC-DISAGREE", f"{cid}: DIAGRAMS_CONTENT_SOURCES.md da `SOURCED`, lekin registr `{reg}` (AWAITING_EXPERT) qabul shartini ilova qoidasi deb belgilaydi — ehtiyotkorrog‘i olindi.")
                    status = "APP_RULE_AWAITING_EXPERT"
                    evid += f"; registry {reg} ({REG[reg]['status']}, docs/expert_signoff_registry.json)"
                if cid in DECISION_LINK:
                    status = "APP_RULE_AWAITING_EXPERT"
                    evid += f"; docs/DECISIONS.md:{line_of('docs/DECISIONS.md', '## ' + DECISION_LINK[cid] + '.')} ({DECISION_LINK[cid]})"
                if st_doc.strip() == "APP_UI":
                    why.append("APP_UI — ilovaning o‘z ish tartibi, tashqi manba yo‘q")
            else:
                en_doc, src_doc, st_doc = EXTRA_CLAIMS[cid]
                status = st_doc
                evid = f"NONE — {doc_path} da ID yo‘q; chizma matni {gen_path}:{klines[0]}"
                why = ["hujjatda qayd etilmagan da’vo — NEEDS_EXPERT"]
                finding("DOC-GAP", f"`differential_count` sxemasining pastki iqtibosi (“{T[topic]['footer']['en']}”) {doc_path} jadvalida ID siz — jadvalga {item} sifatida qo‘shildi.")
            topic_statuses.append(status)
            check = CHECK_DIAG[cid]
            if why:
                check += " [Holat: " + "; ".join(why) + "]"
            add(item_id=item, kind="diagram",
                artifact=f"{art_png}; {gen_path}:{','.join(map(str, klines))} (T['{topic}'])",
                statement=statement, what_to_check=check, source_evidence=evid, evidence_status=status,
                reviewer_profile=DIAG_PROFILE[topic],
                risk_if_wrong=risk(item, *(("low", "ilova ish tartibi; ilmiy da’vo emas") if topic == "educational_feedback"
                                           else ("low", "iqtibos/izoh qatori; xato manba nomini chalkashtiradi") if cid in FOOTER_IDS
                                           else ("medium", "jarayon qadami xato bo‘lsa, talaba noto‘g‘ri tartibni o‘rganadi"))))
        # alt matnlar (uz/ru/en) — sxemadagi barcha da’volarni takrorlaydi
        worst = max(topic_statuses, key=lambda s: CAUTION[s])
        for lang in LANGS:
            k = ALT_KEY[topic]
            add(item_id=f"DIAG-{topic}-alt-{lang}", kind="text-translation",
                artifact=f"lib/l10n/app_{lang}.arb:{arb_line(k, lang)} ({k}); assets/diagrams/{topic}.{lang}.png",
                statement=f"{lang}: {arb(k, lang)}",
                what_to_check=("Alt-matn (ekran o‘quvchi) shu tildagi sxema matni bilan bir xil mazmunda va to‘liqmi; "
                               "sxemadagi da’volar yuqoridagi DIAG-" + topic + "-NN qatorlarida — alt-matn ularning eng ehtiyotkor holatini oladi."),
                source_evidence=f"ARB {k} ({lang}); da’volar manbasi — DIAG-{topic}-NN qatorlari",
                evidence_status=worst,
                reviewer_profile=DIAG_PROFILE[topic] if lang == "en" else P[f"ling_{lang}"],
                risk_if_wrong=f"low — {R_TR_LOW}")
        # tarjima / atama qatorlari (har PNG tili uchun)
        for lang in ("uz", "ru"):
            for key in T[topic]:
                kl = line_of(gen_path, f'"{key}": {{', tline)
                note = DIAG_TR_NOTE.get((topic, key, lang), "")
                add(item_id=f"DIAG-{topic}-l10n-{lang}-{key}", kind="text-translation",
                    artifact=f"assets/diagrams/{topic}.{lang}.png; {gen_path}:{kl} (T['{topic}']['{key}'])",
                    statement=f"{lang}: {tval(topic, key, lang)} || en: {tval(topic, key, 'en')}",
                    what_to_check=("Tarjima en matn bilan mazmunan teng, tibbiy atama to‘g‘ri va ilova ARB atamalariga mos. " + note).strip(),
                    source_evidence="NONE — tarjima; atamalar: docs/L10N_TERMINOLOGY_DECISIONS.md, DIAGRAMS_CONTENT_SOURCES.md ‘Til’ bo‘limi",
                    evidence_status="NEEDS_EXPERT", reviewer_profile=P[f"ling_{lang}"],
                    risk_if_wrong=(f"medium — {R_TR_MED}" if key in DIAG_TR_MED or note else f"low — {R_TR_LOW}"))
    # umumiy
    for lang in ("uz", "ru"):
        add(item_id=f"DIAG-common-l10n-{lang}-yesno", kind="text-translation",
            artifact=f"assets/diagrams/*.{lang}.png; {gen_path}:{line_of(gen_path, 'YES = {')}",
            statement=f"{lang}: {YES[lang]} / {NO[lang]} || en: Yes / No",
            what_to_check="Qaror tarmoqlari yorliqlari (Ha/Yo‘q) shu tilda to‘g‘ri.",
            source_evidence="NONE — tarjima", evidence_status="NEEDS_EXPERT",
            reviewer_profile=P[f"ling_{lang}"], risk_if_wrong=f"low — {R_TR_LOW}")
    k = "imgDiagramCaption"
    add(item_id="DIAG-common-caption", kind="text-translation",
        artifact=f"lib/l10n/app_en.arb:{arb_line(k)} ({k}); lib/app/widgets/diagram_figure.dart",
        statement=tri(lambda lang: arb(k, lang)),
        what_to_check="Sxema ostidagi izoh: ‘umumiy sxema — IFU va laboratoriya SOP’i ustun’ uch tilda bir xil ma’noda.",
        source_evidence="NONE — ilova siyosati matni (DIAGRAMS_CONTENT_SOURCES.md 17-qator)",
        evidence_status="NEEDS_EXPERT", reviewer_profile=P["ling_uz"], risk_if_wrong=f"low — {R_TR_LOW}")


# ============================================================ SXEMALAR
def load_parts_src():
    spec = importlib.util.spec_from_file_location("parts_src", ROOT / "tool/illustrations/schematic/parts_src.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


PSRC = load_parts_src()
_OG = re.compile(r"(?<=[oOgG])'(?=[A-Za-z])")
_TUTUQ = re.compile(r"(?<=[A-Za-z])'(?=[A-Za-z])")


def uz_norm(s):
    return _TUTUQ.sub("’", _OG.sub("‘", s))


MODEL_KEYS = ["chemistry", "photometer", "hematology5", "hematology3", "immunoassay", "urine_strip", "urine_system"]


def lab_alt_keys():
    card = read("lib/features/instruments/lab_direction_card.dart")
    scr = read("lib/features/instruments/lab_direction_screens.dart")
    enum = dict(re.findall(r"^\s+(\w+)\('([a-z0-9_]+)'\)[,;]", card, re.M))
    alt = dict(re.findall(r"LabSchematic\.(\w+) => l\.(labSchem\w+)", scr))
    return {enum[e]: alt[e] for e in enum if e in alt}


LAB_ALT = lab_alt_keys()


def parse_parts_doc():
    """SCHEMATIC_PARTS_SOURCES.md: {(kalit, '1'|'P'|'R'): (ids, tb, qator)}."""
    out, cur = {}, None
    for i, ln in enumerate(read("docs/SCHEMATIC_PARTS_SOURCES.md").splitlines(), 1):
        m = re.match(r"^## `(\w+)`", ln)
        if m:
            cur = m.group(1)
            continue
        m = re.match(r"^\| (\d+|P|R) \| .+ \| (.+) \|$", ln)
        if m and cur:
            cell = m.group(2)
            ids = set(re.findall(r"`([a-z0-9][a-z0-9-]+)`", cell))
            out[(cur, m.group(1))] = (ids, "STANDARD_TEXTBOOK" in cell, i)
    return out


# Chizmadagi texnik da’vo bildiruvchi elementlar (gen.py kodi va PNG ko‘zdan kechirildi).
# (gen.py dagi izoh/anker matni, element tavsifi (uz), nimani tekshirish, xavf, bog‘liq qism raqamlari)
DRAW = {
    "chemistry": [
        ("fotometr: halqa markazidagi lampa", "Fotometr: lampa reaksiya halqasi markazida, nur kyuvetalardan o‘tib tashqi detektor blokiga boradi (5-belgi).",
         "Lampa/detektor joylashuvi sinf uchun umumiy tamoyilmi (ko‘p analizatorlarda boshqacha); nur yo‘li to‘g‘ri ko‘rsatilganmi.", "low", [5]),
        ("namuna rakasi uyasi", "Namunalar old bo‘limdagi rakada; probirkalar turli rangli qopqoqli (binafsha, qizil, sariq, ko‘k, yashil) va to‘liq qon (qizil) bilan chizilgan; halqa yonida raqamsiz kichik disk.",
         "Biokimyoda odatda zardob/plazma ishlatiladi — to‘liq qon va EDTA/sitrat qopqoqlari chalg‘itmaydimi; raqamsiz disk (STAT/kalibrator?) tushunarlimi.", "medium", [1]),
        ("def chemistry", "ISE moduli chizilmagan, lekin prinsip matnida Na, K, Cl ISE bilan o‘lchanishi aytilgan.",
         "Matn va chizma mosligi: ISE moduli ko‘rsatilmasligi muammo emasmi.", "low", []),
    ],
    "photometer": [
        ("kyuveta kamerasi", "O‘lchash kamerasi (oqim kyuvetasi) korpus o‘ng tomonida, ko‘rinadigan oyna bilan (3-belgi).",
         "Yarim avtomatik fotometr uchun oqim kyuvetasi tasviri umumiy sinfga mosmi.", "low", [3]),
        ("yuqori qiya panel", "Displeyda egri chiziq tasviri (kinetik/kalibrlash egri chizig‘i).",
         "Displeyda egri chiziq ko‘rsatilishi (kinetik o‘lchov) sinfga xosmi.", "low", [1]),
    ],
    "hematology5": [
        ("o'lchash bloki kesigi", "Kesik: impedans kamerasi (teshikli to‘siq va ikki elektrod, eritrotsitlar) va lazer → oqim kyuvetasi → detektor.",
         "Impedans va lazerli oqim kanalining sxematik tuzilishi to‘g‘rimi (teshik, elektrodlar, nur yo‘li).", "medium", [3, 4]),
        ("displey (skatterogramma)", "Displeyda 5 klasterli skatterogramma va bitta gistogramma.",
         "5 klaster 5 qismli differensialni anglatadi — klasterlar joylashuvi o‘quv uchun maqbulmi.", "low", [5]),
        ("avtomatik yuklagich", "Avtoyuklagichdagi yopiq probirkalar turli rangli qopqoqli (binafsha, qizil, sariq, ko‘k, yashil).",
         "Umumiy qon tahlili uchun namuna — EDTA (binafsha qopqoq); boshqa rangdagi qopqoqlar noto‘g‘ri probirka tanlashni o‘rgatishi mumkin.", "medium", [1]),
    ],
    "hematology3": [
        ("impedans kamerasi kesigi", "Kesik: teshikli to‘siq va ikki elektrod (impedans kamerasi).",
         "Kulter tamoyili sxemasi to‘g‘rimi.", "low", [4]),
        ("displey (3 gistogramma)", "Displeyda bir xil shakldagi uchta bitta cho‘qqili gistogramma (WBC, RBC, PLT).",
         "Haqiqiy 3 qismli WBC gistogrammasida uchta subpopulyatsiya, PLT — o‘ngga cho‘zilgan shakl; bir xil Gauss egri chiziqlari chalg‘itmaydimi.", "low", [2]),
    ],
    "immunoassay": [
        ("detektor modul (yorug'lik belgisi)", "Luminometr quyosh-belgi (yorug‘lik chiqishi) bilan alohida modul sifatida (7-belgi).",
         "Hemilyuminessensiya detektori tasviri tushunarlimi.", "low", [7]),
        ("namuna rakasi uyasi", "Namunalar to‘liq qon (qizil) va turli rangli qopqoqli probirkalar bilan.",
         "Immunoanaliz odatda zardob/plazmada — to‘liq qon tasviri chalg‘itmaydimi.", "low", [1]),
    ],
    "urine_strip": [
        ("o'qish kallagi: LEDlar", "O‘qish kallagida uch xil rangli LED (uch to‘lqin uzunligi) va fotosensor, test-chiziqda 10 maydoncha.",
         "LED soni/rangi va maydonchalar soni umumiy tamoyil sifatida to‘g‘rimi (aniq model raqami emasligi).", "low", [3, 2]),
    ],
    "urine_system": [
        ("o'ng modul: cho'kma", "Cho‘kma moduli ekranida zarracha tasvirlari galereyasi (eritrotsit, leykotsit, silindr, kristall, epiteliy, bakteriya).",
         "Zarracha tasvirlari morfologik jihatdan to‘g‘ri tanilarlimi.", "low", [4, 5]),
    ],
    "mass_spec_gc": [
        ("ion manbai -> linzalar -> kvadrupol -> detektor", "MS kesigi: ion manbai (filament) → linzalar → kvadrupol (sterjenlar) → detektor; ion yo‘li nuqtalar bilan.",
         "GC-MS (EI) ion optikasi tartibi to‘g‘rimi.", "low", [6, 7, 8]),
        ("vakuum: turbo nasos (kesik) va forvakuum", "Vakuum: korpus ichida turbomolekulyar nasos kesigi, tashqarida forvakuum nasosi (raqamsiz).",
         "Ikki bosqichli vakuum tizimi tasviri to‘g‘rimi.", "low", [9]),
        ("termostat (pech) eshigi", "Termostat oynasida kapillyar kolonka o‘rami.", "Kolonka va termostat tasviri.", "low", [4]),
    ],
    "mass_spec_lc": [
        ("ESI manbai: kapillyar igna", "ESI manbai: kapillyar igna, purkash konusi (Teylor konusi), kirish teshigi.",
         "Elektropurkash manbai tasviri to‘g‘rimi.", "low", [5]),
        ("MS kesigi: ion optikasi", "MS kesigi: ion optikasi → kvadrupol → detektor (bitta kvadrupol).",
         "Klinik LC-MS/MS da odatda uchlik kvadrupol — bitta kvadrupol tasviri soddalashtirish sifatida qabul qilinadimi.", "medium", [6]),
    ],
    "maldi_tof": [
        ("yengil ionlar oldinda", "Uchish trubasida ionlar o‘lchami detektor tomon kichrayadi — yengil ionlar oldinda.",
         "‘Yengil ionlar avval yetadi’ tasviri to‘g‘rimi (SCHEMATICS_PROVENANCE.md da tuzatilgan deb qayd etilgan).", "low", [4]),
        ("nishon plastinasi yuklash eshigi", "Pastda dog‘lar qatorli nishon plastinasi yuklash eshigi (raqamsiz).",
         "Qo‘shimcha raqamsiz element chalg‘itmaydimi.", "low", [1]),
    ],
    "microbial_id_ast": [
        ("kasseta: suspenziya probirkalari", "Kassetada kartalar somon orqali suspenziya probirkalariga ulangan; kesik oynada kartalar va optik skaner.",
         "Karta–somon–probirka ulanishi va skaner tasviri to‘g‘rimi.", "low", [1, 2, 5]),
    ],
    "blood_culture": [
        ("korpus, ochiq eshik", "Inkubator ichida flakonlar: ko‘pchiligi qon (qizil), ayrimlari och (qonsiz?) rangda; har uyacha ostida holat chirog‘i, bittasi sariq.",
         "Och rangli flakonlar ma’nosi (qonsiz/manfiy?) tushunarlimi; musbat flakon chirog‘i rangi ko‘rsatilganmi.", "low", [3, 5]),
    ],
    "mycobacterial_culture": [
        ("stolda: suyuq muhitli probirkalar", "Birinchi probirka tubidagi sensor to‘q sariq (fluoressensiya — musbat) rangda.",
         "Musbat probirka sensori ko‘rinishi to‘g‘rimi (UB ostida to‘q sariq fluoressensiya).", "low", [2]),
        ("def mycobacterial_culture", "Monitorda ikki egri chiziq: o‘suvchi (nazorat) va tekis (dorili probirka) — GU egri chiziqlari.",
         "DST egri chiziqlari talqini to‘g‘ri ko‘rsatilganmi (qaysi biri nazorat).", "medium", [6]),
    ],
    "flow_cytometer": [
        ("tafsilot: gidrodinamik fokuslash", "Kesik: gidrodinamik fokuslash (konus ichida hujayralar bir qator); optika: lazer → kyuveta → FSC (to‘g‘ri chiziqda), 90° da SSC/fluoressensiya dixroik oynalar orqali 3 detektorga.",
         "Optik sxema to‘g‘rimi (FSC nur o‘qida, SSC/FL 90° da).", "low", [3, 4, 5, 6]),
    ],
    "real_time_pcr": [
        ("oldingi kesik: optik modul", "Optik modul kesigi: yorug‘lik manbai → to‘rt rangli filtr g‘ildiragi → detektor; monitorda chegara chizig‘i bilan amplifikatsiya egri chiziqlari.",
         "Optik yo‘l va Cq chegara chizig‘i tasviri to‘g‘rimi.", "low", [4, 5, 6, 7]),
    ],
    "cartridge_molecular": [
        ("korpus: to'rtta modul eshigi", "To‘rt moduldan biri ochiq, ichida kartrij, sariq chiroq (ish jarayonida).",
         "Modul/kartrij tasviri aniq ishlab chiqaruvchi dizayniga o‘xshab qolmaganmi (LAB_CARD_IMAGE_COVERAGE qoidasi).", "low", [4]),
    ],
    "coag_analyzer": [
        ("kyuveta optikasi", "Optik laxta aniqlash: manba → kyuveta → fotodetektor; displeyda pastga tushuvchi S-simon egri chiziqlar.",
         "Laxta hosil bo‘lganda o‘tgan nur kamayishi (egri chiziq yo‘nalishi) to‘g‘ri ko‘rsatilganmi.", "low", [5, 6, 7]),
    ],
    "elisa_reader": [
        ("optik yo'l (kesik)", "Kesik optik yo‘l: kod izohi ‘lampa → filtr → quduqcha → detektor’, lekin chizmada lampa (2) → quduqcha (3) → filtr (4) → detektor (5).",
         "Filtr quduqchadan oldin yoki keyin turishi; izoh va chizma kelishmovchiligi; prinsip matni ‘tanlangan to‘lqin uzunligidagi nur quduqchadan o‘tadi’ deydi.", "medium", [2, 3, 4, 5]),
    ],
    "bsc_class2": [
        ("havo oqimi: xona havosi", "Havo oqimi strelkalari: xona havosi (sariq) old ochiqlikdan panjaraga; HEPA dan pastga (ko‘k); stol ostidan orqa kanal orqali ventilyatorga; chiqish HEPA orqali tashqariga.",
         "Havo oqimi yo‘nalishlari II sinf shkafiga mosmi (pastga oqimning bir qismi orqa panjaraga ketishi ko‘rsatilmagan).", "medium", [1, 2, 3, 4, 5, 6, 7]),
    ],
    "autoclave": [
        ("boshqaruv paneli: bosim va harorat", "Bosim manometri va termometr shkalalari (strelkalar, raqamsiz).", "Manometr/termometr tasviri.", "low", [4, 5]),
        ("ochiq eshik (yon tomondan)", "Eshik zichlagichi bilan ochiq holatda; xavfsizlik klapani va suv idishi qopqog‘i tepada.",
         "Klapan va suv idishi joylashuvi umumiy sinfga mosmi.", "low", [2, 6, 7]),
    ],
    "blood_gas_ise": [
        ("sensor kassetasi (kesik)", "Kesik: o‘lchash kanali (qizil chiziq) bo‘ylab 5 ta rangli elektrod; shprits zondga vertikal ulangan.",
         "Sensor kassetasi tasviri to‘g‘rimi; shpritsni zondga ulash tasviri amaliyotga mosmi.", "low", [1, 2, 3, 4]),
    ],
    "hba1c_analyzer": [
        ("kesik oyna: ion almashinuv kolonkasi", "Kesik: ion almashinuv kolonkasi → fotometrik detektor (oqim kyuvetasi); displeyda kichik cho‘qqilar va katta HbA0 cho‘qqisi bilan xromatogramma.",
         "Chizma ion almashinuv HPLC usulini ko‘rsatadi, lekin LAB_CARD_IMAGE_COVERAGE.md ‘usul ataylab ko‘rsatilmagan’ deydi va kartada bir nechta usul bor; xromatogramma cho‘qqilari tartibi to‘g‘rimi.", "medium", [4, 5, 6]),
        ("namuna rakasi (binafsha qopqoq", "EDTA (binafsha qopqoq) to‘liq qon probirkalari.", "Probirka turi to‘g‘ri.", "low", [1]),
    ],
    "lab_fridge": [
        ("harorat datchigi: buferli flakon", "Buferli flakon (glikol) ichidagi zond, kabel eshik zichlagichi orqali tashqi DDL ga.",
         "Buferli zond va DDL joylashuvi CDC tavsiyasiga mosmi.", "low", [3, 4]),
    ],
    "fluorescence_microscope": [
        ("def afb_field", "Ko‘rish maydoni kiritmasi: qora fonda yorqin sariq-yashil egilgan tayoqchalar (auramin bilan bo‘yalgan batsillalar).",
         "Auramin bo‘yog‘idagi KChT ko‘rinishi va kattaligi to‘g‘rimi.", "medium", [7]),
        ("def microscope", "LED yoritgich mikroskop boshining orqasida (epi-yoritish), filtr bloki sirg‘alma.",
         "Epi-fluoressensiya tuzilishi to‘g‘rimi.", "low", [2, 3]),
    ],
    "casa": [
        ("def ui_tracks", "Monitorda harakatchan spermatozoidlar izlari (rangli chiziqlar, oq boshlar) va harakatsiz nuqtalar.",
         "Izlar tasviri CASA kinematikasiga mosmi.", "low", [5]),
    ],
    "gel_card_system": [
        ("def gel_card", "Gel kartada 6 mikroprobirka: 2 tasida qizil qatlam yuqorida (kuchli musbat), 1 tasida hujayralar gel bo‘ylab tarqalgan (o‘rtacha musbat), 3 tasida tubda tugma (manfiy).",
         "Reaksiya darajalari (4+ … 1+, manfiy) ko‘rinishi to‘g‘rimi; tarqalgan hujayralar aralash maydon (mixed field) deb noto‘g‘ri o‘qilmaydimi.", "medium", [5, 6, 7]),
    ],
    "esr_analyzer": [
        ("Westergren shtativi", "Westergren naychalari turli cho‘kish balandligi bilan (tiniq plazma ustida); avtomatik o‘quvchida qisqa yopiq probirkalar va optik o‘qish chizig‘i.",
         "Avtomatik o‘quvchi probirkalari Westergren uzunligida emas — usul farqi (modifikatsiyalangan usul) izohlanishi kerakmi.", "low", [1, 2, 3, 4, 5, 6]),
    ],
    "aggregometer": [
        ("bitta kanalning kesigi", "LTA kanali kesigi: LED → kyuveta (aralashtirgich) → fotodiod; ekranda o‘suvchi agregatsiya egri chiziqlari; viskoelastik iz ‘sigara’ shaklida.",
         "Agregatsiya va TEG/ROTEM iz shakllari to‘g‘rimi.", "low", [2, 3, 4, 5, 8]),
    ],
    "electrophoresis": [
        ("simlar: qizil", "Qizil sim — anod (+) o‘ng bufer bo‘limiga; eng to‘q (albumin) fraksiya anod tomonda; densitogrammada esa eng baland cho‘qqi chapda.",
         "Qutblar, fraksiyalar joylashuvi va densitogramma yo‘nalishi (an’anaviy ko‘rinish) chalg‘itmaydimi.", "medium", [2, 4, 6]),
    ],
    "osmometer": [
        ("kesik: sovutish bloki", "Kesik: sovutish blokidagi probirka, termistor va aralashtirgich sim; displeyda o‘ta sovish → sakrash → plato (muzlash nuqtasi) egri chizig‘i.",
         "Muzlash egri chizig‘i shakli to‘g‘rimi.", "low", [2, 3, 4, 5]),
    ],
    "tlc": [
        ("UB lampa (254 nm)", "UB ostidagi plastina: yashil fluoressent fonda qoramtir dog‘lar; kamerada erituvchi sathi start chizig‘idan pastda.",
         "Fluoressensiya so‘nishi tasviri va erituvchi sathi start chizig‘idan pastligi to‘g‘rimi.", "low", [2, 4, 8]),
    ],
    "analytical_balance": [
        ("pipetka (havo siljitishli)", "Pipetka shisha himoya qutisi ichidagi idishga suv tomizadi; suv idishidagi termometr alohida o‘lchagichga ulangan.",
         "Havo harorati/bosimi/namligi o‘lchagichlari chizilmagan, lekin prinsip matnida havo harorati yozilishi aytiladi — soddalashtirish maqbulmi.", "low", [1, 2, 6, 7]),
    ],
}


def schematic_rows():
    pdoc = parse_parts_doc()
    sprov = read("docs/SCHEMATICS_PROVENANCE.md")
    prov_sha = dict(re.findall(r"^\| `(\w+_(?:480|1200)\.png)` \| [^|]+\| [^|]+\| [^|]+\| `([0-9a-f]{64})`", sprov, re.M))
    src_path = "tool/illustrations/schematic/parts_src.py"
    gen_path = "tool/illustrations/schematic/gen.py"
    if set(PSRC.PARTS) != set(SPARTS):
        raise SystemExit("parts_src.py va schematic_parts.json kalitlari farq qiladi")
    tb_count = 0
    reg_by_card = {}
    for e in REGISTRY["entries"]:
        if e["id"].startswith("LABCARD-"):
            reg_by_card[e["id"][len("LABCARD-"):].lower()] = e
    for key in PSRC.PARTS:
        src = PSRC.PARTS[key]
        js = SPARTS[key]
        prof = SCHEM_PROFILE[key]
        users = SCHEM_USERS.get(key, [])
        user_sids = set()
        user_texts = []
        for _, _, node in users:
            user_sids |= sids_in(node)
            user_texts.append(" ".join(strings(node)))
        regs = []
        for kind, uid, _ in users:
            e = reg_by_card.get(uid)
            if e:
                regs.append(f"{e['id']} ({e['status']})")
        reg_note = ("; registry: " + ", ".join(regs)) if regs else ""
        shas = []
        for size in ("480", "1200"):
            p = f"assets/instruments/schematic/{key}_{size}.png"
            h = sha256(p)
            shas.append(h[:12])
            if prov_sha.get(pathlib.Path(p).name) != h:
                finding("PNG-SHA", f"`{p}`: sha256 SCHEMATICS_PROVENANCE.md dagi qiymatga mos emas.")
        png = f"assets/instruments/schematic/{key}_{{480,1200}}.png (sha256 {', '.join(shas)})"
        kline = line_of(src_path, f'PARTS["{key}"] = {{')
        cards = ", ".join(f"{k}:{u}" for k, u, _ in users) or "—"
        if len(src["parts"]) != len(js["parts"]):
            raise SystemExit(f"{key}: qismlar soni farq qiladi")

        def classify(item, sids_src, en_text, doc_key):
            ids = [s for s in sids_src if s != PSRC.TB]
            tb = PSRC.TB in sids_src
            notes = []
            for sid in ids:
                if sid not in SOURCES:
                    raise SystemExit(f"{item}: noma’lum manba {sid}")
            if not ids:
                status = "STANDARD_TEXTBOOK"
            elif tb:
                status = "NEEDS_EXPERT"
                notes.append("qisman manbali (STANDARD_TEXTBOOK qismi bor) — manba qamramagan qismi mutaxassis ko‘rigini talab qiladi")
            else:
                status = "SOURCED"
            # hujjat bilan solishtirish
            d = pdoc.get((key, doc_key))
            if d is None:
                raise SystemExit(f"SCHEMATIC_PARTS_SOURCES.md: {key} {doc_key} qatori yo‘q")
            dids, dtb, dline = d
            if dids != set(ids) or dtb != tb:
                finding("DOC-DISAGREE", f"{item}: SCHEMATIC_PARTS_SOURCES.md:{dline} manbalari parts_src.py dan farq qiladi — ehtiyotkorrog‘i olindi.")
                if dtb and status == "SOURCED":
                    status = "NEEDS_EXPERT"
            # manba shu chizmani ishlatadigan karta/modelga tegishlimi
            for sid in ids:
                if sid not in user_sids:
                    notes.append(f"manba {sid} bu chizmadagi kartalarda keltirilmagan")
                    if status == "SOURCED":
                        status = "NEEDS_EXPERT"
                    finding("SRC-SCOPE", f"{item}: manba `{sid}` shu chizmani ishlatuvchi karta/modellarda keltirilmagan.")
            # raqamli tafsilotlar tekshiruvi (katalog matni bo‘yicha)
            toks = num_tokens(en_text)
            missing = []
            for t in toks:
                if ids:
                    texts = [x for sid in ids for x in SRC_CORPUS.get(sid, [])]
                else:
                    texts = user_texts
                if not found(t, texts):
                    missing.append(tok_str(t))
            if missing:
                if status == "SOURCED":
                    status = "NEEDS_EXPERT"
                    notes.append("raqam(lar) " + ", ".join(missing) + " keltirilgan manbaga havola qilingan katalog matnida topilmadi — manbaning o‘zidan tekshirish kerak")
                    finding("NUM-UNVERIFIED", f"{item}: “{', '.join(missing)}” keltirilgan manba ({', '.join(ids)}) bo‘yicha katalog matnida yo‘q.")
                elif not ids:
                    status = "NEEDS_SOURCE"
                    notes.append("aniq raqam(lar) " + ", ".join(missing) + " manbasiz (darslik darajasi deb belgilangan) — manba kerak")
                    finding("NUM-NO-SOURCE", f"{item}: “{', '.join(missing)}” — manbasiz aniq raqam (STANDARD_TEXTBOOK).")
                else:
                    notes.append("raqam(lar) " + ", ".join(missing) + " keltirilgan manba matnida topilmadi")
            if ids:
                ev = "src: " + "; ".join(f"catalog:{sid} <{SOURCES[sid]['url']}>" for sid in ids)
                if tb:
                    ev += "; + STANDARD_TEXTBOOK"
            else:
                ev = "NONE (STANDARD_TEXTBOOK — darslik darajasi, manba ko‘rsatilmagan)"
            ev += f"; doc: docs/SCHEMATIC_PARTS_SOURCES.md:{dline}{reg_note}"
            return status, ev, notes

        nonlocal_tb = 0
        for i, (p, jp) in enumerate(zip(src["parts"], js["parts"]), 1):
            pid = jp["id"]
            if jp["n"] != i or not pid.lower().endswith(p["slug"].lower()):
                raise SystemExit(f"{key}: qism {i} mos emas ({pid} / {p['slug']})")
            for lang in LANGS:
                want = (uz_norm(p[lang][0]) if lang == "uz" else p[lang][0],
                        uz_norm(p[lang][1]) if lang == "uz" else p[lang][1])
                got = (arb(pid + "Name", lang), arb(pid + "Fn", lang))
                if want != got:
                    finding("ARB-SRC", f"{pid} ({lang}): ARB matni parts_src.py dan farq qiladi.")
            if PSRC.TB in p["src"]:
                nonlocal_tb += 1
            item = f"SCHEM-{key}-part-{i:02d}"
            en = f"{arb(pid + 'Name', 'en')} — {arb(pid + 'Fn', 'en')}"
            status, ev, notes = classify(item, p["src"], en, str(i))
            pl = line_of(src_path, f'P("{p["slug"]}",', kline)
            chk = f"{i}-belgi: qism nomi va vazifasi apparat sinfi uchun to‘g‘rimi; chizmadagi joyi to‘g‘ri ko‘rsatilganmi."
            if notes:
                chk += " [" + "; ".join(notes) + "]"
            lvl, why = ("low", R_PART_LOW) if p["slug"] in GENERIC_SLUGS else ("medium", R_PART_MED)
            add(item_id=item, kind="schematic-part",
                artifact=f"{png} #{i}; ARB {pid}Name/{pid}Fn; {src_path}:{pl}",
                statement=tri(lambda lang: f"{i}. {arb(pid + 'Name', lang)} — {arb(pid + 'Fn', lang)}"),
                what_to_check=chk, source_evidence=ev, evidence_status=status, reviewer_profile=prof,
                risk_if_wrong=risk(item, lvl, why))
        tb_count += nonlocal_tb
        for what, doc_key, kind, lvl, why in (("principle", "P", "schematic-principle", "medium", R_PRIN_MED),
                                              ("result", "R", "schematic-result", "medium", R_RES_MED)):
            tid = js[f"{what}_id"]
            for lang in LANGS:
                want = uz_norm(src[what][lang]) if lang == "uz" else src[what][lang]
                if arb(tid, lang) != want:
                    finding("ARB-SRC", f"{tid} ({lang}): ARB matni parts_src.py dan farq qiladi.")
            item = f"SCHEM-{key}-{what}"
            status, ev, notes = classify(item, src[what]["src"], arb(tid, "en"), doc_key)
            pl = line_of(src_path, f'"{what}": T(', kline)
            chk = ("Ishlash prinsipi matni (har jumla) apparat sinfi va kartadagi manbali matnga mosmi; aniq model xususiyati yoki ortiqcha umumlashtirish yo‘qmi."
                   if what == "principle" else
                   "Natija tavsifi (o‘lchanadigan ko‘rsatkichlar, birliklar, talqin chegarasi) to‘g‘rimi; klinik tashxis da’vosi yo‘qmi.")
            if notes:
                chk += " [" + "; ".join(notes) + "]"
            add(item_id=item, kind=kind,
                artifact=f"{png}; ARB {tid}; {src_path}:{pl}; kartalar: {cards}",
                statement=tri(lambda lang: arb(tid, lang)),
                what_to_check=chk, source_evidence=ev, evidence_status=status, reviewer_profile=prof,
                risk_if_wrong=risk(item, lvl, why))
        # chizma elementlari
        gtext = read(gen_path)
        fdef = line_of(gen_path, f"def {key}():")
        for j, (anchor, desc, chk, lvl, nums) in enumerate(DRAW[key], 1):
            try:
                gl = line_of(gen_path, anchor, fdef if not anchor.startswith("def ") else 1)
            except SystemExit:
                gl = line_of(gen_path, anchor)
            item = f"SCHEM-{key}-drawing-{j:02d}"
            rel_ids = [js["parts"][n - 1]["id"] for n in nums]
            add(item_id=item, kind="schematic-drawing",
                artifact=f"{png}; {gen_path}:{gl}" + (f"; belgilar #{','.join(map(str, nums))}" if nums else ""),
                statement=f"uz: {desc}",
                what_to_check=chk + " (Chizma geometriyasi hech bir manba bilan qoplanmagan — faqat qism mavjudligi manbali.)",
                source_evidence=("NONE (chizma — LabGuide original ishi; bog‘liq qismlar: " + ", ".join(rel_ids) + ")") if rel_ids
                else "NONE (chizma — LabGuide original ishi)",
                evidence_status="NEEDS_EXPERT", reviewer_profile=prof,
                risk_if_wrong=risk(item, lvl, R_DRAW_LOW if lvl == "low" else
                                   "chizma noto‘g‘ri usul/tartib/namuna turini ko‘rsatsa, talaba uni haqiqat deb o‘rganadi"))
        # alt-matn (faqat yo‘nalish kartasi sinflari; model turlarida alt = katalogdagi apparat turi)
        if key in LAB_ALT:
            k = LAB_ALT[key]
            add(item_id=f"SCHEM-{key}-drawing-alt", kind="schematic-drawing",
                artifact=f"{png}; ARB {k}; lib/l10n/app_en.arb:{arb_line(k)}",
                statement=tri(lambda lang: arb(k, lang)),
                what_to_check="Alt-matn (ekran o‘quvchi) hozirgi chizmani to‘g‘ri tasvirlaydimi (qismlar ro‘yxati va ko‘rinadigan holatlar); uz/ru tarjimasi.",
                source_evidence=f"NONE (chizma tavsifi; ARB {k})", evidence_status="NEEDS_EXPERT",
                reviewer_profile=prof, risk_if_wrong=f"low — {R_DRAW_LOW}")
        elif key not in MODEL_KEYS:
            raise SystemExit(f"{key}: alt-matn kaliti topilmadi")
        # tarjima (butun panel, til bo‘yicha)
        has_high = any(r["item_id"].startswith(f"SCHEM-{key}-") and r["risk_if_wrong"].startswith("high") for r in ROWS)
        for lang in ("uz", "ru"):
            names = "; ".join(f"{jp['n']}. {arb(jp['id'] + 'Name', lang)}" for jp in js["parts"])
            add(item_id=f"SCHEM-{key}-l10n-{lang}", kind="text-translation",
                artifact=f"ARB schemParts* ({key}) lib/l10n/app_{lang}.arb:{arb_line(js['parts'][0]['id'] + 'Name', lang)}–{arb_line(js['result_id'], lang)}",
                statement=f"{lang}: {names} || en: " + "; ".join(f"{jp['n']}. {arb(jp['id'] + 'Name', 'en')}" for jp in js["parts"]),
                what_to_check=f"{lang} atamalari (qism nomlari), vazifa, prinsip va natija matnlari en bilan mazmunan teng va {lang} tibbiy-laboratoriya atamashunosligiga mos.",
                source_evidence="NONE — tarjima; atamalar: docs/L10N_TERMINOLOGY_DECISIONS.md",
                evidence_status="NEEDS_EXPERT", reviewer_profile=P[f"ling_{lang}"],
                risk_if_wrong=(f"medium — {R_TR_MED}" if has_high else f"low — {R_TR_LOW}"))
    # hujjatdagi umumiy son
    m = re.search(r"Jami: (\d+) chizma, (\d+) qism; (\d+) tasida", read("docs/SCHEMATIC_PARTS_SOURCES.md"))
    total_parts = sum(len(v["parts"]) for v in SPARTS.values())
    if m and (int(m.group(1)) != len(SPARTS) or int(m.group(2)) != total_parts or int(m.group(3)) != tb_count):
        finding("DOC-COUNT", f"SCHEMATIC_PARTS_SOURCES.md ‘Jami’ qatori ({m.group(0)}) haqiqiy songa mos emas: {len(SPARTS)} chizma, {total_parts} qism, {tb_count} tasida STANDARD_TEXTBOOK.")
    # umumiy UI matnlari
    for k in ("instSchematicCaption", "instSchematicNotPhoto", "schemPartsClassNote"):
        add(item_id=f"SCHEM-common-{k}", kind="text-translation",
            artifact=f"lib/l10n/app_en.arb:{arb_line(k)} ({k})",
            statement=tri(lambda lang: arb(k, lang)),
            what_to_check="Sxematik chizma haqidagi umumiy izoh (aniq model emas / tamoyil darajasi) uch tilda bir xil ma’noda va to‘g‘ri.",
            source_evidence="NONE — ilova siyosati matni (docs/LAB_CARD_IMAGE_COVERAGE.md)",
            evidence_status="NEEDS_EXPERT", reviewer_profile=P["ling_uz"], risk_if_wrong=f"low — {R_TR_LOW}")


# Qo‘lda topilgan nomuvofiqliklar (PNG va kod ko‘zdan kechirilgan, 2026-10-25). Tuzatilmaydi — faqat ro‘yxat.
MANUAL_FINDINGS = [
    ("DRAW-ELISA", "`elisa_reader` chizmasi: `gen.py` izohi “lampa → filtr → quduqcha → detektor”, lekin chizilgan tartib lampa (2) → quduqcha (3) → filtr (4) → detektor (5). Prinsip matni “tanlangan to‘lqin uzunligidagi nur quduqchadan o‘tadi” deydi. Qaysi tartib ko‘zda tutilgani mutaxassis bilan aniqlansin (SCHEM-elisa_reader-drawing-01)."),
    ("DRAW-HBA1C", "`hba1c_analyzer`: docs/LAB_CARD_IMAGE_COVERAGE.md (a2-test-hba1c, a2-platform-hba1c-analyzer) “ichki usul ataylab ko‘rsatilmagan” deydi, lekin 2026-10-25 yangilangan chizma (SCHEMATICS_PROVENANCE.md) ion almashinuv kolonkasi, fotometrik detektor va xromatogrammani ko‘rsatadi; `labSchemHba1cAnalyzer` alt-matnida esa kolonka/detektor yo‘q. Karta bir nechta usulni (ion almashinish, borat affinligi, immunoanaliz, ferment) qamraydi (SCHEM-hba1c_analyzer-drawing-01)."),
    ("DRAW-TUBES", "`hematology5` avtoyuklagichi (`rack(..., caps=TUBE_CAPS)`), `chemistry` va `immunoassay` namuna rakalari turli rangli qopqoqli (binafsha, qizil, sariq, ko‘k, yashil) to‘liq qon probirkalari bilan chizilgan. Umumiy qon tahlili — EDTA (binafsha), biokimyo/immunoanaliz — zardob/plazma. `coag_analyzer` (havorang) va `hba1c_analyzer` (binafsha) to‘g‘ri chizilgani uchun bu nomuvofiqlik ko‘zga tashlanadi."),
    ("DRAW-HEM3", "`hematology3` displeyida uchta bir xil Gauss shaklidagi gistogramma; haqiqiy 3 qismli WBC gistogrammasida uchta subpopulyatsiya, PLT gistogrammasi o‘ngga cho‘zilgan — soddalashtirish o‘quvchini chalg‘itishi mumkin (SCHEM-hematology3-drawing-02)."),
    ("L10N-REFERENS", "ARB `diffInterpretIntro`/`diffRangesBody` (uz) “referens oraliq” deydi; docs/L10N_TERMINOLOGY_DECISIONS.md uz uchun yagona atama “referens interval” (NEEDS_NATIVE_REVIEW). `differential_count.uz.png` va uning alt-matni 2026-10-25 da “referens interval” ga o‘tkazildi; ARB qatorlari tuzatilmagan."),
    ("TERM-ABS", "`photometry`: en “Absorbance”; ilova ARB’ida absorbance — ru “поглощение”, uz “yutilish”, ma’ruzada — “оптическая плотность”/“optik zichlik”. 2026-10-25 da sxema ilovaning o‘z iborasiga (“Поглощение (оптическая плотность)”, “Yutilish (optik zichlik)”) moslandi; IUPAC farqi (absorbance ≠ optical density) bo‘yicha atama qarori hali mutaxassisniki."),
]


# ============================================================ chiqish
def priority_key(r):
    return (-(RISK_W[r["risk_if_wrong"].split(" ")[0]] * 10 + STATUS_W[r["evidence_status"]]), r["item_id"])


def csv_bytes(rows):
    buf = io.StringIO()
    w = csv.DictWriter(buf, fieldnames=COLUMNS, lineterminator="\n", quoting=csv.QUOTE_MINIMAL)
    w.writeheader()
    for r in rows:
        w.writerow(r)
    return ("﻿" + buf.getvalue()).encode("utf-8")


def md_table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "---|" * len(head)]
    for r in rows:
        out.append("| " + " | ".join(str(x).replace("|", "\\|") for x in r) + " |")
    return "\n".join(out)


def counts(rows):
    c = {s: 0 for s in STATUSES}
    for r in rows:
        c[r["evidence_status"]] += 1
    return c


def risk_counts(rows):
    c = {"high": 0, "medium": 0, "low": 0}
    for r in rows:
        c[r["risk_if_wrong"].split(" ")[0]] += 1
    return c


def build_md():
    rows = ROWS
    total = counts(rows)
    L = []
    L.append("# Sxema va apparat chizmalari — ilmiy tekshiruv jadvali (2026-10-25)")
    L.append("")
    L.append("Bu hujjat **LabGuide laboratoriya ta’limi ilovasi** kontentining ilmiy tekshiruvi uchun "
             "(boshqa hech qaysi ilovaga aloqasi yo‘q). Egasi topshirig‘i (4-band): 18 ta sxema "
             "(`assets/diagrams/`, 6 mavzu × uz/ru/en) va 32 ta apparat sxematik chizmasi "
             "(`assets/instruments/schematic/`) dagi **mutaxassis tekshiruvini talab qiladigan har bir da’vo** — "
             "alohida jadvalda.")
    L.append("")
    L.append("- To‘liq jadval: [`docs/SCIENTIFIC_REVIEW_TABLE.csv`](SCIENTIFIC_REVIEW_TABLE.csv) "
             f"(UTF-8 BOM, {len(rows)} qator, bitta qator — bitta tekshiriladigan da’vo).")
    L.append("- Mutaxassislarga paketlar: [`docs/review_packets_tech/`](review_packets_tech/) — har profilga bitta CSV, "
             "xavf bo‘yicha tartiblangan.")
    L.append("- Generator: `python3 tool/review/make_scientific_review_tables.py` (faqat stdlib, deterministik; "
             "`--check` — fayllar eskirgan bo‘lsa xato). Qorovul: `test/guards/scientific_review_table_guard_test.dart`.")
    L.append("")
    L.append("**Muhim:** `specialist_decision`, `reviewed_by`, `review_date` ustunlari **hamma qatorda bo‘sh** "
             "(PENDING). Hech bir qator mutaxassis tomonidan tasdiqlangan emas; bu jadvalda hech kimning nomidan "
             "tasdiq yozilmaydi. `SOURCED` — faqat “manbaga havola bor” degani, “tasdiqlangan” emas. "
             "Manbasiz ma’lumot hech qachon tasdiqlangan deb belgilanmaydi.")
    L.append("")
    L.append("## Holat kodlari (evidence_status)")
    L.append("")
    L.append(md_table(["kod", "ma’nosi", "qatorlar"], [
        ("`SOURCED`", "katalog manbasi (catalog.json `sources[].id`), ARB kaliti yoki ilovadagi aniq fayl:qator bor; mazmun mutaxassis tomonidan hali tekshirilmagan", total["SOURCED"]),
        ("`STANDARD_TEXTBOOK`", "darslik darajasidagi umumiy ma’lumot, repoda alohida iqtibos yo‘q (hujjatlarda “STANDARD_TEXTBOOK (NEEDS_EXPERT)”)", total["STANDARD_TEXTBOOK"]),
        ("`NEEDS_SOURCE`", "manbasiz aniq raqam/tafsilot (masalan, harorat, son, vaqt) — avval manba topilishi kerak", total["NEEDS_SOURCE"]),
        ("`NEEDS_EXPERT`", "manba to‘liq qamramaydi (qisman manbali), hujjatlar kelishmaydi, tarjima yoki chizma — mutaxassis ko‘rigi kerak", total["NEEDS_EXPERT"]),
        ("`APP_RULE_AWAITING_EXPERT`", "ilovaning o‘z qoidasi/ish tartibi (registr `AWAITING_EXPERT` yoki DECISIONS.md qarori) — tashqi manba emas", total["APP_RULE_AWAITING_EXPERT"]),
    ]))
    L.append("")
    L.append("Holat qanday aniqlandi (hech bir holat o‘z hisobimdan **ko‘tarilmadi**, faqat ehtiyotkor tomonga tushirildi):")
    L.append("")
    L.append("1. Sxemalar: `docs/DIAGRAMS_CONTENT_SOURCES.md` jadvali; shu bo‘limdagi NEEDS_EXPERT izohi yoki "
             "`docs/DIAGRAMS_PROVENANCE.md` NEEDS_EXPERT ro‘yxati boshqacha desa — ehtiyotkorrog‘i. `APP_UI` → "
             "`APP_RULE_AWAITING_EXPERT`; registr (`CALIB-ACCEPTANCE-RULES`, `DIFF-REFER-BODY-WORDING`) yoki "
             "`DECISIONS.md` D-20 ga bog‘langan qoida → `APP_RULE_AWAITING_EXPERT`.")
    L.append("2. Apparat chizmalari: `tool/illustrations/schematic/parts_src.py` `src` va `docs/SCHEMATIC_PARTS_SOURCES.md` "
             "(ikkalasi solishtirildi). Faqat katalog manbasi → `SOURCED`; manba + darslik → `NEEDS_EXPERT`; "
             "faqat darslik → `STANDARD_TEXTBOOK`.")
    L.append("3. O‘z tekshiruvim (katalog bo‘yicha): (a) keltirilgan manba shu chizmani ishlatuvchi karta/modelda bormi; "
             "(b) matndagi har bir raqam (°C, daqiqa, mm, son, nm …) shu manbaga havola qilingan `catalog.json` "
             "matnida bormi. Topilmasa: `SOURCED` → `NEEDS_EXPERT`; `STANDARD_TEXTBOOK` → `NEEDS_SOURCE`. "
             "Katalogda manbaning faqat qisqa iqtiboslari bor — demak “topilmadi” xato degani emas, "
             "manbaning o‘zidan tekshirish kerak degani.")
    L.append("4. Chizma elementlari (kesiklar, ekranlar, sensorlar, ranglar) va tarjimalar — doim `NEEDS_EXPERT`: "
             "chizma geometriyasi va tarjima hech bir manba bilan qoplanmagan.")
    L.append("5. Yo‘nalish kartalarining o‘zi ham tekshirilmagan: `catalog.json` dagi barcha kartalar "
             "`expert_reviewed: false` (registrdagi `LABCARD-*` yozuvlari `AWAITING_EXPERT`) — `source_evidence` "
             "ustunida ko‘rsatilgan.")
    L.append("")
    # umumiy jadval
    L.append("## Umumiy son")
    L.append("")
    kinds = ["diagram", "schematic-part", "schematic-principle", "schematic-result", "schematic-drawing", "text-translation"]
    trows = []
    for k in kinds:
        sub = [r for r in rows if r["kind"] == k]
        c, rc = counts(sub), risk_counts(sub)
        trows.append((f"`{k}`", len(sub), *[c[s] for s in STATUSES], rc["high"], rc["medium"], rc["low"]))
    c, rc = counts(rows), risk_counts(rows)
    trows.append(("**jami**", len(rows), *[c[s] for s in STATUSES], rc["high"], rc["medium"], rc["low"]))
    L.append(md_table(["kind", "qator", *STATUSES, "high", "medium", "low"], trows))
    L.append("")
    # top xavflar
    ranked = sorted(rows, key=priority_key)
    L.append("## Eng yuqori xavfli 30 qator (avval shular)")
    L.append("")
    L.append("Tartib: xavf (high > medium > low), so‘ng holat (NEEDS_SOURCE > APP_RULE/NEEDS_EXPERT > STANDARD_TEXTBOOK > SOURCED), so‘ng item_id.")
    L.append("")
    L.append(md_table(["#", "item_id", "holat", "mutaxassis", "xavf"],
                      [(i, f"`{r['item_id']}`", r["evidence_status"], r["reviewer_profile"], r["risk_if_wrong"])
                       for i, r in enumerate(ranked[:30], 1)]))
    L.append("")
    # sxema bo‘yicha
    L.append("## Har bir sxema (diagramma) bo‘yicha")
    L.append("")
    dr = []
    for t in TOPICS:
        sub = [r for r in rows if r["item_id"].startswith(f"DIAG-{t}-")]
        c, rc = counts(sub), risk_counts(sub)
        top = sorted(sub, key=priority_key)[0]
        dr.append((f"`{t}` (uz/ru/en)", len(sub), *[c[s] for s in STATUSES], rc["high"], DIAG_PROFILE[t], f"`{top['item_id']}`"))
    dr.sort(key=lambda x: (-x[7], -(x[4] + x[5] + x[6]), x[0]))
    L.append(md_table(["#", "sxema", "qator", *STATUSES, "high", "asosiy mutaxassis", "birinchi tekshiriladigan"],
                      [(i, *x) for i, x in enumerate(dr, 1)]))
    L.append("")
    # chizma bo‘yicha
    L.append("## Har bir apparat chizmasi bo‘yicha (ustuvorlik tartibida)")
    L.append("")
    sr = []
    for key in PSRC.PARTS:
        sub = [r for r in rows if r["item_id"].startswith(f"SCHEM-{key}-")]
        c, rc = counts(sub), risk_counts(sub)
        top = sorted(sub, key=priority_key)[0]
        sr.append([f"`{key}`", len(sub), *[c[s] for s in STATUSES], rc["high"], rc["medium"], SCHEM_PROFILE[key], f"`{top['item_id']}`"])
    sr.sort(key=lambda x: (-x[7], -x[8], -(x[4] + x[5] + x[6]), x[0]))
    L.append(md_table(["#", "chizma", "qator", *STATUSES, "high", "medium", "asosiy mutaxassis", "birinchi tekshiriladigan"],
                      [(i, *x) for i, x in enumerate(sr, 1)]))
    L.append("")
    # paketlar
    L.append("## Mutaxassis paketlari (har biriga bitta fayl)")
    L.append("")
    L.append("Egasi har bir mutaxassisga bitta CSV beradi; mutaxassis faqat `specialist_decision` "
             "(masalan: TO‘G‘RI / TUZATISH KERAK / MANBA KERAK + izoh), `reviewed_by` (ism, malaka) va "
             "`review_date` ni o‘zi to‘ldiradi. To‘ldirilgan paket bu jadvalga qo‘lda ko‘chiriladi "
             "(skript bu ustunlarni hech qachon to‘ldirmaydi).")
    L.append("")
    prow = []
    for prof in sorted({r["reviewer_profile"] for r in rows}, key=lambda p: (-sum(1 for r in rows if r["reviewer_profile"] == p and r["risk_if_wrong"].startswith("high")), SLUG[p])):
        sub = [r for r in rows if r["reviewer_profile"] == prof]
        c, rc = counts(sub), risk_counts(sub)
        prow.append((prof, f"[`{SLUG[prof]}.csv`](review_packets_tech/{SLUG[prof]}.csv)", len(sub), rc["high"], rc["medium"], rc["low"],
                     c["NEEDS_SOURCE"], c["NEEDS_EXPERT"] + c["APP_RULE_AWAITING_EXPERT"], c["STANDARD_TEXTBOOK"], c["SOURCED"]))
    L.append(md_table(["mutaxassis profili", "paket", "qator", "high", "medium", "low", "NEEDS_SOURCE",
                       "NEEDS_EXPERT + APP_RULE", "STANDARD_TEXTBOOK", "SOURCED"], prow))
    L.append("")
    # qaror
    L.append("## Egasi uchun qaror")
    L.append("")
    L.append("1. **Birinchi navbat (high xavf):** klinik biokimyogar (QC rad qoidalari, fotometriya hisobi), "
             "laboratoriya sifat menejeri (kalibrlashni qabul qilish qoidasi), gematolog (blast yo‘llanmasi, INR), "
             "biologik xavfsizlik mutaxassisi (avtoklav, BXSh), sil laboratoriyasi mutaxassisi (MGIT DST, Xpert, AFB), "
             "transfuziolog (gel karta), mikrobiolog (MIK), molekulyar diagnost va immunolog (virus yuki, CD4).")
    L.append("2. **`NEEDS_SOURCE` qatorlari** — mutaxassisdan oldin manba topilishi kerak (yoki raqam matndan olib tashlanadi).")
    L.append("3. **Tarjima paketlari** (uz/ru tibbiy tilshunos) — mazmun tasdiqlangandan keyin.")
    L.append("4. Mutaxassis javobisiz hech bir qator “tasdiqlangan” deb ko‘rsatilmaydi; ilovada "
             "“Sxematik tasvir — aniq model emas” va “IFU / SOP ustun” izohlari qoladi.")
    L.append("")
    # nomuvofiqliklar
    L.append("## Topilgan nomuvofiqliklar")
    L.append("")
    L.append("Tuzatilmadi (lib/, ARB, katalog, assets o‘zgartirilmaydi) — faqat ro‘yxat; har biri jadvalda tegishli qatorda ham bor.")
    L.append("")
    allf = MANUAL_FINDINGS + FINDINGS
    for i, (code, text) in enumerate(allf, 1):
        L.append(f"{i}. **{code}** — {text}")
    L.append("")
    L.append("## Qayta yaratish")
    L.append("")
    L.append("```")
    L.append("python3 tool/review/make_scientific_review_tables.py          # CSV + MD + paketlar")
    L.append("python3 tool/review/make_scientific_review_tables.py --check  # eskirgan bo‘lsa exit 1")
    L.append("flutter test test/guards/scientific_review_table_guard_test.dart")
    L.append("```")
    L.append("")
    L.append("Qorovul: CSV bor; 32 chizma kaliti va 6 mavzu (18 PNG) qamralgan; holat ruxsat etilgan to‘plamda; "
             "`specialist_decision`/`reviewed_by`/`review_date` bo‘sh; `SOURCED` qatorida manba id bor; "
             "`schematic_parts.json` dagi har bir `schemParts*` qism/prinsip/natija id jadvalda bor — yangi qism "
             "tekshiruv jadvalisiz chiqmaydi.")
    L.append("")
    return "\n".join(L)


def main(argv):
    diagram_rows()
    schematic_rows()
    ids = [r["item_id"] for r in ROWS]
    if len(ids) != len(set(ids)):
        dup = sorted({i for i in ids if ids.count(i) > 1})
        raise SystemExit(f"takroriy item_id: {dup}")
    outputs = {OUT_CSV: csv_bytes(ROWS), OUT_MD: build_md().encode("utf-8")}
    profiles = sorted({r["reviewer_profile"] for r in ROWS})
    for prof in profiles:
        sub = sorted([r for r in ROWS if r["reviewer_profile"] == prof], key=priority_key)
        outputs[OUT_PACKETS / f"{SLUG[prof]}.csv"] = csv_bytes(sub)
    if "--check" in argv:
        stale = [rel(p) for p, b in outputs.items() if not p.exists() or p.read_bytes() != b]
        extra = [rel(p) for p in OUT_PACKETS.glob("*.csv") if p not in outputs] if OUT_PACKETS.exists() else []
        if stale or extra:
            print("eskirgan:", *stale, *extra, sep="\n  ")
            return 1
        print("ok")
        return 0
    OUT_PACKETS.mkdir(parents=True, exist_ok=True)
    for p in OUT_PACKETS.glob("*.csv"):
        if p not in outputs:
            p.unlink()
    for p, b in outputs.items():
        p.write_bytes(b)
    c = counts(ROWS)
    print(f"{len(ROWS)} qator:", ", ".join(f"{k}={v}" for k, v in c.items()))
    print(f"paketlar: {len(profiles)}; nomuvofiqliklar: {len(MANUAL_FINDINGS) + len(FINDINGS)}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
