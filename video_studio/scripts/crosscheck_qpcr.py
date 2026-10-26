#!/usr/bin/env python3
"""Independent check of the real-time PCR video numbers (no shared code with
src/lib/qpcr.js): Cq of each illustrative logistic curve found by bisection
on F(c) = threshold, and the 2^n doubling bars.
Usage: python3 -I crosscheck_qpcr.py storyboard.json"""
import json, math, sys

d = json.load(open(sys.argv[1]))["data"]
base, thr = d["base"], d["threshold"]

def F(c, s):
    if s.get("flat"):
        return base + s["drift"] * c
    return base + s["top"] / (1 + math.exp(-(c - s["mid"]) / s["slope"]))

out = {}
for s in d["samples"]:
    lo, hi = 0.0, float(d["cycles"])
    if F(hi, s) < thr:
        out[s["id"]] = None
        continue
    for _ in range(200):
        mid = (lo + hi) / 2
        (lo, hi) = (mid, hi) if F(mid, s) < thr else (lo, mid)
    out[s["id"]] = round((lo + hi) / 2, 6)
print(json.dumps({"cq": out, "doubling": [2 ** n for n in range(d["doublingSteps"] + 1)],
                  "ntc_max_signal": round(F(d["cycles"], next(x for x in d["samples"] if x.get("flat"))), 6)}, indent=1))
