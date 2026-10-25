"""Chapters / timestamps from a video's storyboard JSON and its narration timing manifest (stdlib).

This is a port of `video_studio/src/lib/timing.js -> layoutScenes` (scene k starts leadSec before its first
narration line, but never earlier than 0.05 s after the previous scene's last line). All language editions
share the English voice timing, so one set of timestamps serves en / ru / uz.

YouTube wants: the first chapter at 0:00, at least three chapters, each at least 10 s long.
Topics with an explicit chapter spec (topics.py) use it; any other topic gets automatic chapters
(neighbouring scenes merged to >= 10 s, title = the first narration line) flagged `auto` — edit before use.
"""
import json
import re
from pathlib import Path

from common import AUDIO_ROOT, DOCS_VIDEO, LANGS

MIN_CHAPTER_SEC = 10.0


class ChapterError(Exception):
    pass


def _load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def storyboard_path(topic_id, docs_video=DOCS_VIDEO):
    return Path(docs_video) / topic_id / "storyboard.json"


def timing_path(topic_id, audio_root=AUDIO_ROOT):
    return Path(audio_root) / "en" / f"{topic_id}.timing.json"


def layout_scenes(storyboard, timing):
    """Return [(scene_id, start_sec, end_sec)] and the total duration."""
    cfg = storyboard["timing"]
    lines = timing["lines"] if isinstance(timing, dict) else timing
    by_id = {str(l["id"]): l for l in lines}
    scenes = storyboard["scenes"]
    for sc in scenes:
        for lid in sc["lines"]:
            if lid not in by_id:
                raise ChapterError(f"timing manifest has no line {lid}")
    starts = []
    for k, sc in enumerate(scenes):
        if k == 0:
            starts.append(0.0)
            continue
        prev_end = by_id[scenes[k - 1]["lines"][-1]]["end"]
        first = by_id[sc["lines"][0]]["start"]
        starts.append(max(prev_end + 0.05, first - cfg["leadSec"]))
    last = scenes[-1]
    last_end = by_id[last["lines"][-1]]["end"]
    total = max(last_end + cfg["tailSec"], starts[-1] + last["minSec"],
                (timing.get("totalSec") if isinstance(timing, dict) else None) or 0)
    out = []
    for k, sc in enumerate(scenes):
        end = starts[k + 1] if k + 1 < len(scenes) else total
        out.append((sc["id"], starts[k], end))
    return out, total


def fmt_ts(sec, long=False):
    s = int(sec + 0.5)  # nearest second
    h, rem = divmod(s, 3600)
    m, s = divmod(rem, 60)
    if h or long:
        return f"{h}:{m:02d}:{s:02d}"
    return f"{m}:{s:02d}"


def _clean_title(text, fallback):
    if "{" in text:
        return fallback
    text = re.sub(r"\s+", " ", text).strip()
    if len(text) > 60:
        text = text[:60].rsplit(" ", 1)[0].rstrip(",;:—-") + "…"
    return text


def _humanize(scene_id):
    return scene_id.replace("_", " ").capitalize()


def _explicit(spec, scenes):
    ids = [sid for sid, _, _ in scenes]
    chosen = []
    for scene_id, titles in spec:
        if scene_id not in ids:
            raise ChapterError(f"chapter spec names unknown scene {scene_id!r}")
        i = ids.index(scene_id)
        chosen.append((i, titles))
    if chosen[0][0] != 0:
        raise ChapterError("first chapter must start at scene 0 (0:00)")
    out = []
    for n, (i, titles) in enumerate(chosen):
        start = scenes[i][1]
        end = scenes[chosen[n + 1][0]][1] if n + 1 < len(chosen) else scenes[-1][2]
        out.append({"start": start, "end": end, "titles": dict(titles), "auto": False})
    return out


def _auto(storyboard, scenes, lines_by_lang):
    groups, cur = [], []
    for k, sc in enumerate(scenes):
        cur.append(k)
        if scenes[cur[-1]][2] - scenes[cur[0]][1] >= MIN_CHAPTER_SEC:
            groups.append(cur)
            cur = []
    if cur:
        if groups:
            groups[-1].extend(cur)
        else:
            groups.append(cur)
    out = []
    for g in groups:
        first_scene = storyboard["scenes"][g[0]]
        titles = {}
        for lang in LANGS:
            lines = lines_by_lang.get(lang) or {}
            text = lines.get(first_scene["lines"][0], "")
            titles[lang] = _clean_title(text, _humanize(first_scene["id"]))
        out.append({"start": scenes[g[0]][1], "end": scenes[g[-1]][2], "titles": titles, "auto": True})
    return out


def compute(topic, docs_video=DOCS_VIDEO, audio_root=AUDIO_ROOT):
    """Chapters for a topic or None (with a reason) when the storyboard/timing is not there.

    Returns {"chapters": [...], "total": float, "problems": [...]} or {"chapters": None, "reason": str}.
    """
    sb_path = storyboard_path(topic["id"], docs_video)
    tm_path = timing_path(topic["id"], audio_root)
    if not sb_path.is_file():
        return {"chapters": None, "reason": f"no storyboard yet ({sb_path.name})"}
    if not tm_path.is_file():
        return {"chapters": None, "reason": f"no narration timing manifest ({tm_path.name})"}
    storyboard, timing = _load(sb_path), _load(tm_path)
    scenes, total = layout_scenes(storyboard, timing)
    if topic.get("chapters"):
        chapters = _explicit(topic["chapters"], scenes)
    else:
        lines_by_lang = {}
        for lang in LANGS:
            p = Path(docs_video) / topic["id"] / f"lines.{lang}.json"
            if p.is_file():
                lines_by_lang[lang] = _load(p).get("lines", {})
        chapters = _auto(storyboard, scenes, lines_by_lang)
    problems = []
    if len(chapters) < 3:
        problems.append(f"only {len(chapters)} chapters (YouTube needs at least 3)")
    for c in chapters:
        if c["end"] - c["start"] < MIN_CHAPTER_SEC:
            problems.append(f"chapter at {fmt_ts(c['start'])} is shorter than {MIN_CHAPTER_SEC:.0f} s")
    if any(c["auto"] for c in chapters):
        problems.append("automatic chapter titles: edit them before use")
    return {"chapters": chapters, "total": total, "problems": problems}


def chapter_lines(chapters, lang):
    long = chapters[-1]["end"] >= 3600
    return [f"{fmt_ts(c['start'], long)} {c['titles'][lang]}" for c in chapters]
