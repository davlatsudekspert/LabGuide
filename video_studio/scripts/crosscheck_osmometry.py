#!/usr/bin/env python3
"""Independent check of the osmometry video numbers (no shared code with
src/lib/osmometry.js): the supercooled minimum (seed time) of each
illustrative freezing curve found by bisection on the cooling law, the
plateau temperature reached after seeding, the depression vs pure water,
and the calculator arithmetic for the filmed inputs.
Usage: python3 -I crosscheck_osmometry.py storyboard.json"""
import json, math, sys

d = json.load(open(sys.argv[1]))["data"]
p = d["curve"]

def cooling(t):
    return p["tb"] + (p["t0"] - p["tb"]) * math.exp(-t / p["tau"])

out = {"samples": {}}
for s in d["samples"]:
    lo, hi = 0.0, p["tMax"]
    for _ in range(200):
        mid = (lo + hi) / 2
        (lo, hi) = (mid, hi) if cooling(mid) > s["tsup"] else (lo, mid)
    ts = (lo + hi) / 2
    # temperature 2 s after seeding (well inside the plateau, before its end)
    t = ts + 2.0
    temp = s["tf"] - (s["tf"] - s["tsup"]) * math.exp(-(t - ts) / p["tauR"])
    out["samples"][s["id"]] = {
        "seed_time": round(ts, 6),
        "plateau_temp_2s_after_seed": round(temp, 6),
        "depression": round(p["water"] - s["tf"], 6),
    }
ids = [s["id"] for s in d["samples"]]
out["deeper"] = max(ids, key=lambda i: out["samples"][i]["depression"])
c = d["calc"]
calc = 2 * c["sodium"] + c["glucose"] + c["urea"]
out["calc"] = {"calculated": calc, "gap": c["measured"] - calc}
print(json.dumps(out, indent=1))
