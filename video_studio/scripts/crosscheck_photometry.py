#!/usr/bin/env python3
"""Independent re-computation of the photometry video numbers (no shared code
with src/lib/photometry.js). Usage: python3 -I crosscheck_photometry.py storyboard.json
Prints JSON."""
import json, math, sys

d = json.load(open(sys.argv[1]))["data"]
std_c, std_a = d["standard"]["conc"], d["standard"]["abs"]
k = std_a / std_c
L, S = d["linearity"]["limit"], d["linearity"]["bend"]

def resp(c):
    return k * c if c <= L else k * L + k * S * (1 - math.exp(-(c - L) / S))

smp = d["sample"]["abs"] / std_a * std_c
hi_c, f = d["high"]["trueConc"], d["high"]["dilutionFactor"]
hi_a = round(resp(hi_c), 3)
direct = hi_a / std_a * std_c
dil_a = round(resp(hi_c / f), 3)
dil_c = dil_a / std_a * std_c
print(json.dumps({
    "k": k,
    "sample_conc": round(smp, 6),
    "high_abs": hi_a,
    "high_direct": round(direct, 6),
    "dil_abs": dil_a,
    "dil_conc": round(dil_c, 6),
    "high_result": round(dil_c * f, 6),
    "ladder_T_percent": {str(a): round(100 * 10 ** (-a), 6) for a in d["ladder"]},
    "linear_abs_at_limit": round(k * L, 6),
}, indent=1))
