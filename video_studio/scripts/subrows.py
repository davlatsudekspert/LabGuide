#!/usr/bin/env python3
"""Exact row count of burned-in subtitle cues: measures each word with the
real font (Inter 600, as SubtitleTrack) and wraps greedily at the plate's
text width. stdin: JSON [{key, text, size, width}] -> stdout: rows per key."""
import json, sys
from PIL import ImageFont

FONT = sys.argv[1]
cues = json.load(sys.stdin)
fonts = {}
out = {}
for c in cues:
    f = fonts.setdefault(c["size"], ImageFont.truetype(FONT, c["size"]))
    ls = -0.2
    def w(s):
        return f.getlength(s) + ls * len(s)
    space = w(" ")
    rows, cur = 1, 0.0
    for word in c["text"].replace("‑", "-").split():
        ww = w(word)
        if cur and cur + space + ww > c["width"]:
            rows += 1
            cur = ww
        else:
            cur += (space if cur else 0) + ww
    out[c["key"]] = rows
print(json.dumps(out))
