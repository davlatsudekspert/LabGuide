#!/usr/bin/env python3
"""Independent Python cross-check of the leukocyte video's arithmetic.

Reads docs/video/leukocyte/storyboard.json (data.sequence, data.wbc) and
recomputes counts, percentages and absolute counts with exact fractions —
no shared code with video_studio/src/lib/differential.js. Prints JSON; the
docs script (scripts/docs.mjs) compares it with the JS values and writes
both into MATH_APPENDIX.md. Optional 2nd arg: a frames.json from the app walk
(its `record` block = numbers computed by the app itself) — compared too.

    python3 -I video_studio/scripts/crosscheck_leukocyte.py docs/video/leukocyte/storyboard.json [frames.json]
"""
import json
import sys
from collections import Counter
from fractions import Fraction

CLASSES = ["segmented", "band", "lymphocyte", "monocyte", "eosinophil", "basophil", "other"]


def main() -> int:
    sb = json.load(open(sys.argv[1], encoding="utf-8"))
    data = sb["data"]
    seq = data["sequence"]
    n = len(seq)
    cnt = Counter(seq)
    wbc = Fraction(str(data["wbc"]))
    rows = {}
    for c in CLASSES:
        k = cnt.get(c, 0)
        pct = Fraction(k * 100, n)
        absol = Fraction(k, n) * wbc
        rows[c] = {
            "count": k,
            "percent": float(pct),
            "absolute": float(absol),
            "absolute_2dp": f"{float(absol):.2f}",
        }
    out = {
        "n": n,
        "wbc": float(wbc),
        "rows": rows,
        "percent_sum": float(sum(Fraction(cnt.get(c, 0) * 100, n) for c in CLASSES)),
        "absolute_sum": float(sum(Fraction(cnt.get(c, 0), n) * wbc for c in CLASSES)),
        "neutrophils_total_abs": float(Fraction(cnt["segmented"] + cnt["band"], n) * wbc),
        "declared_counts_match": all(cnt.get(c, 0) == data["counts"].get(c, 0) for c in CLASSES),
        "mid_tally": dict(Counter(seq[: data["midAt"]])),
    }
    if len(sys.argv) > 2:
        app = json.load(open(sys.argv[2], encoding="utf-8")).get("record")
        if app:
            out["app_match"] = all(
                app["counts"][c] == rows[c]["count"]
                and abs(app["percent"][c] - rows[c]["percent"]) < 1e-9
                and abs((app["absolute"][c] or 0) - rows[c]["absolute"]) < 1e-9
                for c in CLASSES
            )
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0 if out["declared_counts_match"] and out.get("app_match", True) else 1


if __name__ == "__main__":
    sys.exit(main())
