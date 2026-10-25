#!/usr/bin/env python3
"""Independent re-implementation of the Westgard multirule check used by the
QC video (written from the rule definitions in the app's qc_rules.dart doc
comments / Westgard 1981, no shared code with src/lib/qc.js).
Usage: python3 -I crosscheck_qc.py storyboard.json [frames.json]"""
import json, sys
from fractions import Fraction as F

sb = json.load(open(sys.argv[1]))
d = sb["data"]
levels = d["levels"]

def value(lv, z):
    v = F(str(lv["mean"])) + F(str(z)) * F(str(lv["sd"]))
    return float(round(v, lv["decimals"]))

def zscore(lv, x):
    return (F(str(x)) - F(str(lv["mean"]))) / F(str(lv["sd"]))

def beyond(z, k):  # strictly outside k SD (exact fractions: no epsilon needed)
    return z > k

def evaluate(lvls, runs):
    out, stream = [], []   # stream of accepted observations (run, level, z)
    for i, vals in enumerate(runs):
        z = {lv["id"]: zscore(lv, vals[lv["id"]]) for lv in lvls if lv["id"] in vals}
        rules = set()
        if any(beyond(abs(v), 3) for v in z.values()): rules.add("1-3s")
        if any(beyond(abs(v), 2) for v in z.values()): rules.add("1-2s")
        for s in (1, -1):
            if sum(1 for v in z.values() if beyond(v * s, 2)) >= 2: rules.add("2-2s")
            for lid, v in z.items():
                prev = [o for o in stream if o[1] == lid]
                if beyond(v * s, 2) and prev and beyond(prev[-1][2] * s, 2): rules.add("2-2s")
        if any(beyond(v, 2) for v in z.values()) and any(beyond(-v, 2) for v in z.values()): rules.add("R-4s")
        cand = stream + [(i, lid, z[lid]) for lid in [l["id"] for l in lvls] if lid in z]
        for rule, n, k in (("4-1s", 4, 1), ("10x", 10, 0)):
            seqs = [[o for o in cand if o[1] == l["id"]] for l in lvls]
            if len({o[1] for o in cand[-n:]}) >= 2: seqs.append(cand[-n:])
            for seq in seqs:
                if len(seq) >= n and seq[-1][0] == i:
                    w = seq[-n:]
                    if all(beyond(o[2], k) for o in w) or all(beyond(-o[2], k) for o in w): rules.add(rule)
        verdict = "reject" if rules - {"1-2s"} else ("warning" if rules else "accept")
        if verdict != "reject": stream = cand
        out.append({"verdict": verdict, "rules": sorted(rules)})
    return out

runs = [{lv["id"]: value(lv, r["z"][k]) for k, lv in enumerate(levels)} for r in d["runs"]]
res = evaluate(levels, runs)
expect_ok = all(res[int(i) - 1]["verdict"] == e["verdict"] and res[int(i) - 1]["rules"] == sorted(e["rules"]) for i, e in d["expect"].items())
cards = {}
for c in d["cards"]:
    lv = [next(l for l in levels if l["id"] == i) for i in c["levels"]]
    rr = [{l["id"]: float(F(str(l["mean"])) + F(str(zs[k])) * F(str(l["sd"]))) for k, l in enumerate(lv)} for zs in c["runs"]]
    cards[c["rule"]] = evaluate(lv, rr)[-1]["rules"]
stats = {}
for lv in levels:
    xs = [F(str(r[lv["id"]])) for r, v in zip(runs, res) if v["verdict"] != "reject"]
    n = len(xs); m = sum(xs) / n
    var = sum((x - m) ** 2 for x in xs) / (n - 1)
    sd = float(var) ** 0.5
    stats[lv["id"]] = {"n": n, "mean": float(m), "sd": sd, "cv": 100 * sd / float(m)}
app = None
if len(sys.argv) > 2:
    rec = json.load(open(sys.argv[2])).get("record", {})
    app = [{"verdict": v["verdict"], "rules": sorted(v["rules"])} for v in rec.get("verdicts", [])]
print(json.dumps({"values": runs, "verdicts": res, "expect_match": expect_ok, "cards": cards, "stats": stats,
                  "app_match": (app == res) if app is not None else None}, indent=1))
