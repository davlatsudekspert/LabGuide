#!/usr/bin/env python3
"""Merge the frames of the overview video into public/frames/<lang>/overview/ (stdlib only).

Sources, per language:
  * ov_a / ov_b                 written by flutter_walk/overview_walk_test.dart
  * storyboard data.reuse       [[video, frame id], ...] copied from earlier topic videos
Output: <id>.png for every frame + frames.json (same format as a walk: lang, video, source, device, frames[]).
Frame ids must be unique across all sources (the script fails otherwise).

    python3 video_studio/scripts/overview_frames.py
"""
import json
import shutil
import sys
from pathlib import Path

STUDIO = Path(__file__).resolve().parents[1]
REPO = STUDIO.parent
FR = STUDIO / "public" / "frames"
SB = json.loads((REPO / "docs/video/overview/storyboard.json").read_text(encoding="utf-8"))


def main():
    reuse = SB["data"]["reuse"]
    for lang in ("en", "ru", "uz"):
        out = FR / lang / "overview"
        out.mkdir(parents=True, exist_ok=True)
        frames, seen = [], {}

        def add(video, meta):
            fid = meta["id"]
            if fid in seen:
                sys.exit(f"duplicate frame id {fid}: {seen[fid]} and {video}")
            seen[fid] = video
            shutil.copyfile(FR / lang / video / meta["file"], out / meta["file"])
            frames.append({**meta, "from": video})

        for video in ("ov_a", "ov_b"):
            m = json.loads((FR / lang / video / "frames.json").read_text(encoding="utf-8"))
            for f in m["frames"]:
                add(video, f)
        for video, fid in reuse:
            m = json.loads((FR / lang / video / "frames.json").read_text(encoding="utf-8"))
            f = next(x for x in m["frames"] if x["id"] == fid)
            add(video, f)
        (out / "frames.json").write_text(json.dumps({
            "lang": lang, "video": "overview",
            "source": "video_studio/flutter_walk/overview_walk_test.dart + frames reused from earlier topic videos (storyboard data.reuse)",
            "device": "390x844 @2x, Classic light; class frames: the app's widget-test fake server, demo data",
            "frames": frames}, ensure_ascii=False, indent=2), encoding="utf-8")
        print(lang, len(frames), "frames")


if __name__ == "__main__":
    main()
