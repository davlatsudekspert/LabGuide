#!/usr/bin/env python3
"""Independent check of the calculators video numbers (no shared code with
src/lib/calculators.js or the app): CKD-EPI 2021 eGFR for the illustrative
inputs, the dilution V1 = C2*V2/C1, and the calculated osmolality behind the
unit-check frame. Usage: python3 -I crosscheck_calculators.py storyboard.json"""
import json, sys

d = json.load(open(sys.argv[1]))["data"]
e = d["egfr"]
scr = e["creatinine"] * 113.12 / 10000  # µmol/L -> mg/dL by molar mass (as the app)
female = e["sex"] == "female"
k, a = (0.7, -0.241) if female else (0.9, -0.302)
r = scr / k
egfr = 142 * min(r, 1) ** a * max(r, 1) ** -1.2 * 0.9938 ** e["age"] * (1.012 if female else 1)
dl = d["dilution"]
u = d["unitCheck"]
print(json.dumps({"scr_mg_dl": round(scr, 5), "egfr": round(egfr, 4), "egfr_shown": round(egfr),
                  "kdigo_category": "G1" if egfr >= 90 else "not G1",
                  "dilution_v1": dl["c2"] * dl["v2"] / dl["c1"],
                  "osmo_unitcheck_calculated": 2 * u["sodium"] + u["glucose"] + u["urea"]}, indent=1))
