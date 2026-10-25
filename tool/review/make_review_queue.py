#!/usr/bin/env python3
"""Ilmiy tekshiruv navbati: SCIENTIFIC_REVIEW_TABLE.csv dan mutaxassis ko‘rigini
kutayotgan qatorlar (NEEDS_EXPERT + APP_RULE_AWAITING_EXPERT) xavf va mavzu bo‘yicha
tartiblanadi; manbasi aniq (SOURCED) faktlar alohida hujjatlanadi.

    python3 tool/review/make_review_queue.py [--check]

Yozadi: docs/SCIENTIFIC_REVIEW_QUEUE.md, docs/SCIENTIFIC_REVIEW_QUEUE.csv,
docs/SCIENTIFIC_REVIEW_SOURCED.csv. Hech qanday tasdiq YOZILMAYDI:
specialist_decision / reviewed_by / review_date bo‘sh qoladi.
"""
import csv
import io
import pathlib
import re
import sys
from collections import Counter, defaultdict

ROOT = pathlib.Path(__file__).resolve().parents[2]
SRC = ROOT / "docs" / "SCIENTIFIC_REVIEW_TABLE.csv"
PENDING = ("APP_RULE_AWAITING_EXPERT", "NEEDS_EXPERT")
RISK = {"high": 0, "medium": 1, "low": 2}
KIND = {"schematic-result": 0, "schematic-principle": 1, "diagram": 2, "schematic-part": 3,
        "schematic-drawing": 4, "text-translation": 5}
TOPIC = {  # mavzu (uz) — diagramma mavzusi yoki sxema kaliti bo‘yicha
    "qc_decision": "Sifat nazorati (QC)", "calibration_overview": "Kalibrlash",
    "differential_count": "Leykoformula", "photometry": "Fotometriya",
    "preanalytics": "Preanalitika", "educational_feedback": "O‘quv natijalari oqimi",
    "mass_spec_gc": "Massa-spektrometriya", "mass_spec_lc": "Massa-spektrometriya",
    "maldi_tof": "Massa-spektrometriya",
    "real_time_pcr": "Molekulyar diagnostika", "cartridge_molecular": "Molekulyar diagnostika",
    "elisa_reader": "Immunoanaliz va ELISA", "immunoassay": "Immunoanaliz va ELISA",
    "chemistry": "Kimyo / fotometr analizatorlari", "photometer": "Kimyo / fotometr analizatorlari",
    "hba1c_analyzer": "Kimyo / fotometr analizatorlari", "blood_gas_ise": "Kimyo / fotometr analizatorlari",
    "osmometer": "Kimyo / fotometr analizatorlari", "electrophoresis": "Kimyo / fotometr analizatorlari",
    "tlc": "Kimyo / fotometr analizatorlari",
    "hematology5": "Gematologiya va gemostaz", "hematology3": "Gematologiya va gemostaz",
    "coag_analyzer": "Gematologiya va gemostaz", "aggregometer": "Gematologiya va gemostaz",
    "esr_analyzer": "Gematologiya va gemostaz", "flow_cytometer": "Gematologiya va gemostaz",
    "gel_card_system": "Gematologiya va gemostaz",
    "urine_strip": "Siydik tahlili", "urine_system": "Siydik tahlili",
    "microbial_id_ast": "Mikrobiologiya", "blood_culture": "Mikrobiologiya",
    "mycobacterial_culture": "Mikrobiologiya",
    "fluorescence_microscope": "Mikroskopiya", "casa": "Mikroskopiya",
    "bsc_class2": "Biologik xavfsizlik va sterilizatsiya", "autoclave": "Biologik xavfsizlik va sterilizatsiya",
    "lab_fridge": "Asosiy jihozlar", "analytical_balance": "Asosiy jihozlar",
}


def topic_of(item_id: str) -> str:
    m = re.match(r"DIAG-([a-z_]+)-", item_id)
    if m:
        return TOPIC.get(m.group(1), "Diagrammalar (boshqa)")
    m = re.match(r"SCHEM-([a-z0-9_]+)-", item_id)
    if m:
        return TOPIC.get(m.group(1), "Umumiy matnlar (sxemalar)")
    return "Boshqa"


def load():
    with SRC.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def risk_word(r):
    return r["risk_if_wrong"].split(" ")[0]


def key(r):
    return (RISK.get(risk_word(r), 3), 0 if r["evidence_status"] == "APP_RULE_AWAITING_EXPERT" else 1,
            KIND.get(r["kind"], 9), r["item_id"])


def csv_text(rows, cols):
    b = io.StringIO()
    w = csv.DictWriter(b, fieldnames=cols, extrasaction="ignore", lineterminator="\n")
    w.writeheader()
    w.writerows(rows)
    return "﻿" + b.getvalue()


def build():
    rows = load()
    pend = sorted((r for r in rows if r["evidence_status"] in PENDING), key=key)
    sourced = [r for r in rows if r["evidence_status"] == "SOURCED"]
    for i, r in enumerate(pend, 1):
        r["rank"] = i
        r["topic"] = topic_of(r["item_id"])
        r["priority_group"] = "TOP-30" if i <= 30 else "keyingi"
    for r in sourced:
        r["topic"] = topic_of(r["item_id"])
    cols = ["rank", "priority_group", "topic", "item_id", "kind", "risk_if_wrong", "evidence_status",
            "reviewer_profile", "statement", "what_to_check", "source_evidence",
            "specialist_decision", "reviewed_by", "review_date"]
    assert all(not r["specialist_decision"] and not r["reviewed_by"] and not r["review_date"] for r in rows)
    by_topic = defaultdict(list)
    for r in pend:
        by_topic[r["topic"]].append(r)
    cnt = Counter(risk_word(r) for r in pend)
    L = ["# Ilmiy tekshiruv navbati (mutaxassis ko‘rigini kutayotgan bandlar)", "",
         "LabGuide o‘quv kontenti uchun. Manba: `docs/SCIENTIFIC_REVIEW_TABLE.csv` (qayta yaratish: "
         "`python3 tool/review/make_review_queue.py`). **Hech kim nomidan tasdiq yozilmagan**: "
         "`specialist_decision`, `reviewed_by`, `review_date` ustunlari hamma qatorda bo‘sh. "
         "Bu ro‘yxat tibbiy yoki laboratoriya ko‘rsatmasi emas — faqat tekshirish navbati.", "",
         f"Jami kutayotgan: **{len(pend)}** (APP_RULE_AWAITING_EXPERT {sum(1 for r in pend if r['evidence_status']=='APP_RULE_AWAITING_EXPERT')}, "
         f"NEEDS_EXPERT {sum(1 for r in pend if r['evidence_status']=='NEEDS_EXPERT')}). "
         f"Xavf: yuqori {cnt['high']}, o‘rta {cnt['medium']}, past {cnt['low']}.", "",
         "Tartib qoidasi: avval xavf (yuqori → past), keyin ilova qoidasi (APP_RULE) → natija → prinsip → "
         "diagramma → qism → rasm elementi → tarjima; keyin `item_id`.", "",
         "## 1. Eng xavfli 30 band (birinchi navbat)", "",
         "| # | Mavzu | item_id | Nima tekshiriladi | Kim ko‘radi | Xavf | Holat |", "|---|---|---|---|---|---|---|"]
    for r in pend[:30]:
        L.append(f"| {r['rank']} | {r['topic']} | `{r['item_id']}` | {r['what_to_check'].replace('|','/')[:160]} | "
                 f"{r['reviewer_profile']} | {risk_word(r)} | {r['evidence_status']} |")
    L += ["", "## 2. Mavzu bo‘yicha (har mavzuda xavf bo‘yicha tartiblangan)", "",
          "| Mavzu | Jami | Yuqori | O‘rta | Past | Birinchi 30 ichida |", "|---|---|---|---|---|---|"]
    for t, rs in sorted(by_topic.items(), key=lambda kv: (min(key(x) for x in kv[1]), kv[0])):
        c = Counter(risk_word(x) for x in rs)
        L.append(f"| {t} | {len(rs)} | {c['high']} | {c['medium']} | {c['low']} | {sum(1 for x in rs if x['rank']<=30)} |")
    for t, rs in sorted(by_topic.items(), key=lambda kv: (min(key(x) for x in kv[1]), kv[0])):
        L += ["", f"### {t} ({len(rs)})", "", "| # | item_id | Xavf | Holat | Nima tekshiriladi |", "|---|---|---|---|---|"]
        for r in rs:
            L.append(f"| {r['rank']} | `{r['item_id']}` | {risk_word(r)} | {r['evidence_status']} | "
                     f"{r['what_to_check'].replace('|','/')[:140]} |")
    st = Counter(r["topic"] for r in sourced)
    L += ["", "## 3. Manbasi aniq faktlar (hujjatlashtirilgan, tasdiqlanmagan)", "",
          f"{len(sourced)} band katalog/ilova manbasiga bog‘langan (`docs/SCIENTIFIC_REVIEW_SOURCED.csv`: "
          "har qatorda manba identifikatori). **SOURCED = manba bor; bu mutaxassis tasdig‘i degani emas.** "
          "Manba bilan bog‘liq ilovadagi qisqa iqtiboslar asl manba bilan solishtirilishi kerak.", "",
          "| Mavzu | SOURCED qatorlar |", "|---|---|"]
    for t, n in sorted(st.items(), key=lambda kv: (-kv[1], kv[0])):
        L.append(f"| {t} | {n} |")
    return "\n".join(L) + "\n", csv_text(pend, cols), csv_text(
        sorted(sourced, key=lambda r: (r["topic"], r["item_id"])),
        ["topic", "item_id", "kind", "statement", "source_evidence", "evidence_status",
         "specialist_decision", "reviewed_by", "review_date"])


def main():
    md, q, s = build()
    outs = {ROOT / "docs/SCIENTIFIC_REVIEW_QUEUE.md": md, ROOT / "docs/SCIENTIFIC_REVIEW_QUEUE.csv": q,
            ROOT / "docs/SCIENTIFIC_REVIEW_SOURCED.csv": s}
    if "--check" in sys.argv:
        bad = [p.name for p, t in outs.items() if not p.exists() or p.read_text(encoding="utf-8") != t]
        print("ok" if not bad else f"eskirgan: {bad}")
        sys.exit(1 if bad else 0)
    for p, t in outs.items():
        p.write_text(t, encoding="utf-8")
    print(md.count("\n"), "satr; kutayotgan:", q.count("\n") - 1)


main()
