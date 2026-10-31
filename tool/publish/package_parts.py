#!/usr/bin/env python3
"""Build the YouTube (16:9) and Instagram (9:16) hand-over archives as size-limited parts (stdlib + ffprobe).

Same content and structure as `package.py` (it reuses its validation, texts and zip writer), but the archives are
written directly as parts so that the disk never has to hold a full archive plus its split copy, and every
part stays below the owner's upload limit (500 MB; we keep each part < 450 MB).

    python3 tool/publish/package_parts.py --out-root video_studio/out --out-dir <dir> --suffix v2

Output: LABGUIDE_YOUTUBE_FINAL_<suffix>_PART1.zip / _PART2.zip and LABGUIDE_INSTAGRAM_FINAL_<suffix>_PART1/2.zip.
Every part contains the top-level files (README.md, SCHEDULE.*, SHA256SUMS.txt, MANIFEST.json) and a
PART_<n>_OF_2.txt that lists the topics inside; the topic folders are split between the parts.
The overview video and the reel are not part of these archives (delivered separately).
"""
import argparse
import datetime
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import kit  # noqa: E402
import package as pm  # noqa: E402
from common import AUDIO_ROOT, DOCS_VIDEO, OUT_ROOT  # noqa: E402
from topics import BY_ID  # noqa: E402

DEFAULT_IDS = ["calibration", "qc", "photometry", "osmometry", "leukocyte", "calculators", "gcms", "qpcr"]
PARTS = [["calibration", "leukocyte", "photometry", "qc"], ["calculators", "gcms", "osmometry", "qpcr"]]
MAX_PART = 450 * 1000 * 1000


def split(entries, root, stamp):
    """Return one entry list per part: top-level files in every part, topic folders by PARTS."""
    out = []
    for n, topics in enumerate(PARTS, 1):
        sel = []
        for e in entries:
            rel = e.arcname[len(root) + 1:].split("/")
            if len(rel) == 1 or rel[0] in topics:
                sel.append(e)
        note = (f"Part {n} of {len(PARTS)} of {root}.\nTopics in this part: {', '.join(topics)}\n"
                f"Extract all parts into the same folder. README.md, SCHEDULE.* and SHA256SUMS.txt list every part.\n")
        sel.append(pm.text_entry(f"{root}/PART_{n}_OF_{len(PARTS)}.txt", note, stamp))
        out.append(sel)
    return out


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out-root", default=str(OUT_ROOT))
    ap.add_argument("--out-dir", required=True)
    ap.add_argument("--suffix", default="v2")
    ap.add_argument("--ids", default=",".join(DEFAULT_IDS))
    ap.add_argument("--only", choices=("youtube", "instagram"))
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args(argv)
    out_root, out_dir = Path(args.out_root), Path(args.out_dir)
    ids = [i for i in args.ids.split(",") if i]
    ready = kit.read_ready_ids(out_root)
    records, warnings = [], []
    for tid in ids:
        rec = pm.collect_topic(tid, out_root, DOCS_VIDEO, AUDIO_ROOT)
        warnings += rec["warnings"]
        records.append(rec)
    statuses = {r["id"]: kit.topic_status(BY_ID[r["id"]], out_root, ready) for r in records}
    now = datetime.datetime.now()
    stamp, stamp_iso, date_label = now.timestamp(), now.astimezone().isoformat(timespec="seconds"), now.date().isoformat()
    yt, ig, placeholders = pm.build_entries(records, DOCS_VIDEO, statuses, stamp, stamp_iso, date_label, warnings, None)
    manifest = pm.manifest_dict(records, statuses, stamp_iso, warnings, placeholders)
    for entries, root in ((yt, pm.YT_ROOT), (ig, pm.IG_ROOT)):
        entries.append(pm.text_entry(f"{root}/MANIFEST.json", json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
                                     stamp))
    plan = []
    if args.only in (None, "youtube"):
        plan.append(("LABGUIDE_YOUTUBE_FINAL", yt, pm.YT_ROOT))
    if args.only in (None, "instagram"):
        plan.append(("LABGUIDE_INSTAGRAM_FINAL", ig, pm.IG_ROOT))
    for w in warnings:
        print("warning:", w)
    out_dir.mkdir(parents=True, exist_ok=True)
    summary = {}
    for base, entries, root in plan:  # one archive at a time
        for n, part in enumerate(split(entries, root, stamp), 1):
            name = f"{base}_{args.suffix}_PART{n}.zip"
            est = pm.estimate_bytes(part)
            print(f"{name}: {len(part)} entries, about {est / 1e6:.0f} MB")
            if est > MAX_PART:
                raise pm.PackageError(f"{name} would be {est / 1e6:.0f} MB (> {MAX_PART / 1e6:.0f} MB)")
            if args.dry_run:
                continue
            summary[name] = pm.write_zip(part, out_dir / name, verify=True)
            print("  wrote", summary[name]["size_bytes"], "bytes, sha256", summary[name]["sha256"])
    (out_dir / f"LABGUIDE_FINAL_{args.suffix}_MANIFEST.json").write_text(
        json.dumps({"archives": summary, "manifest": manifest}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except pm.PackageError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(2)
