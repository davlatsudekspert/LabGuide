#!/usr/bin/env python3
"""Build the two hand-over archives from video_studio/out/<id>/<lang>/ (stdlib + ffprobe).

    python3 tool/publish/package.py                  # every id that has files -> video_studio/out/packages/
    python3 tool/publish/package.py --ids calibration,leukocyte
    python3 tool/publish/package.py --dry-run        # validate and report, write nothing

Output (default video_studio/out/packages/, git-ignored, never committed):
    LABGUIDE_YOUTUBE_FINAL.zip    16:9 1920x1080 MP4 en/ru/uz + 1280x720 thumbnails + SRT/VTT + per-edition
                                  metadata (title, description, tags, chapters, pinned comment, credits, alt text)
                                  + SCHEDULE + README (index, sha256, licences, disclosures)
    LABGUIDE_INSTAGRAM_FINAL.zip  9:16 1080x1920 MP4 en/ru/uz + 1080x1920 covers + captions/hashtags + README
    LABGUIDE_MANIFEST.json        every file with size, sha256 and ffprobe facts; archive sizes and hashes

Rules enforced (a violation stops the run with a non-zero exit code and nothing is written):
  * a declared file that is missing (or empty) is an error;
  * a video whose docs/video/<id>/CLAIMS_AND_EVIDENCE.md has no claims table is refused;
  * dimensions / codec / audio are checked with ffprobe (the texts promise English narration: no audio = error);
  * an id with partial files that is not listed in READY.txt is skipped with a warning (still rendering);
    an id listed in READY.txt must be complete.

Nothing is uploaded or published. Re-running replaces the archives atomically (written as *.partial, then
renamed); when the disk cannot hold the old and the new archive at once, the old one is deleted first.
Videos and JPEGs are stored without compression (already compressed); text is deflated.
"""
import argparse
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys
import zipfile
from fractions import Fraction
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import chapters as chapters_mod  # noqa: E402
import kit  # noqa: E402
import schedule as schedule_mod  # noqa: E402
from common import (AUDIO_ROOT, CREDITS, DISCLOSURE_ORDER, DISCLOSURES, DOCS_VIDEO, GATES, INTERNAL_LICENCE_NOTES,  # noqa: E402
                    LANGS, LANG_NAMES, OUT_ROOT, PAID_GATE, PLACEHOLDERS)
from topics import ALIASES, BY_ID  # noqa: E402

YOUTUBE_ZIP = "LABGUIDE_YOUTUBE_FINAL.zip"
INSTAGRAM_ZIP = "LABGUIDE_INSTAGRAM_FINAL.zip"
MANIFEST = "LABGUIDE_MANIFEST.json"
YT_ROOT = "LABGUIDE_YOUTUBE_FINAL"
IG_ROOT = "LABGUIDE_INSTAGRAM_FINAL"
DIMENSIONS = {"yt_video": (1920, 1080), "ig_video": (1080, 1920), "thumb": (1280, 720), "cover": (1080, 1920)}
SKIP_DIRS = {"packages", "stills", "voice"}
SPACE_MARGIN = 64 * 1024 * 1024


class PackageError(Exception):
    pass


# ------------------------------------------------------------------------------------ helpers
def sha256_file(path, chunk=1 << 20):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while True:
            b = f.read(chunk)
            if not b:
                break
            h.update(b)
    return h.hexdigest()


def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest()


def probe(path, ffprobe="ffprobe"):
    """ffprobe facts for one file. Raises PackageError when ffprobe is missing or fails."""
    try:
        cp = subprocess.run([ffprobe, "-v", "error", "-print_format", "json", "-show_format", "-show_streams",
                             str(path)], capture_output=True, text=True, timeout=120)
    except FileNotFoundError:
        raise PackageError("ffprobe not found on PATH (needed to verify the videos)")
    except subprocess.TimeoutExpired:
        raise PackageError(f"ffprobe timed out on {path}")
    if cp.returncode != 0:
        raise PackageError(f"ffprobe failed on {path}: {cp.stderr.strip()[:300]}")
    j = json.loads(cp.stdout)
    streams = j.get("streams", [])
    v = next((s for s in streams if s.get("codec_type") == "video"), None)
    a = next((s for s in streams if s.get("codec_type") == "audio"), None)
    fmt = j.get("format", {})
    facts = {"format": fmt.get("format_name"), "size_bytes": int(fmt.get("size", 0))}
    if fmt.get("duration") not in (None, "N/A"):
        facts["duration_sec"] = round(float(fmt["duration"]), 3)
    if v:
        fps = None
        try:
            fps = float(Fraction(v.get("avg_frame_rate") or v.get("r_frame_rate") or "0/1"))
        except (ZeroDivisionError, ValueError):
            pass
        facts["video"] = {"codec": v.get("codec_name"), "profile": v.get("profile"), "width": v.get("width"),
                          "height": v.get("height"), "pix_fmt": v.get("pix_fmt"),
                          "fps": round(fps, 3) if fps else None}
    if a:
        facts["audio"] = {"codec": a.get("codec_name"), "sample_rate_hz": int(a.get("sample_rate") or 0),
                          "channels": a.get("channels")}
    else:
        facts["audio"] = None
    return facts


def claims_table_problem(docs_video, topic_id):
    """None when docs/video/<id>/CLAIMS_AND_EVIDENCE.md exists and contains a claims table, else a message."""
    p = Path(docs_video) / topic_id / "CLAIMS_AND_EVIDENCE.md"
    if not p.is_file():
        return f"{p} is missing"
    lines = p.read_text(encoding="utf-8").splitlines()
    for i, line in enumerate(lines[:-1]):
        head = line.lower()
        if line.lstrip().startswith("|") and "claim" in head and "evidence" in head:
            sep = lines[i + 1].replace(" ", "")
            if sep.startswith("|") and set(sep) <= set("|-:") and "-" in sep:
                rows = [l for l in lines[i + 2:] if l.lstrip().startswith("|")]
                if rows:
                    return None
    return f"{p} has no claims table (a table with 'Claim' and 'Evidence' columns and at least one row)"


def discover(out_root, ready_ids, explicit=None):
    """Return (ids_to_package, warnings). Raises PackageError on READY ids with incomplete files."""
    warnings = []
    out_root = Path(out_root)
    if explicit:
        return [ALIASES.get(i, i) for i in explicit], warnings
    present = []
    if out_root.is_dir():
        for d in sorted(out_root.iterdir()):
            if d.is_dir() and d.name not in SKIP_DIRS and any(d.rglob("*.mp4")):
                present.append(d.name)
    ids = []
    for tid in sorted(set(present) | set(ready_ids or ()), key=lambda i: (BY_ID[i]["order"] if i in BY_ID else 999, i)):
        complete = not _missing(tid, out_root)
        listed = ready_ids is not None and tid in ready_ids
        if complete or listed:
            ids.append(tid)
        else:
            warnings.append(f"{tid}: partial files and not listed in READY.txt: skipped (still rendering?)")
    return ids, warnings


def _missing(tid, out_root):
    base = Path(out_root) / tid
    miss = []
    for lang in LANGS:
        for kind in kit.FILE_PATTERNS:
            p = base / lang / kit.fname(kind, tid, lang)
            if not p.is_file() or p.stat().st_size == 0:
                miss.append(str(p))
    return miss


# ------------------------------------------------------------------------------------ validation
def collect_topic(tid, out_root, docs_video, audio_root, ffprobe="ffprobe"):
    """Validate one topic and return its record (files with sha256 + ffprobe facts). Raises PackageError."""
    if tid not in BY_ID:
        raise PackageError(f"{tid}: no publishing kit text for this id; add it to tool/publish/topics.py")
    problem = claims_table_problem(docs_video, tid)
    if problem:
        raise PackageError(f"{tid}: refused: {problem}")
    miss = _missing(tid, out_root)
    if miss:
        raise PackageError(f"{tid}: declared files missing or empty:\n    " + "\n    ".join(miss))
    base = Path(out_root) / tid
    rec = {"id": tid, "editions": {}, "warnings": []}
    for lang in LANGS:
        files = {}
        for kind in kit.FILE_PATTERNS:
            name = kit.fname(kind, tid, lang)
            path = base / lang / name
            entry = {"name": name, "path": path, "size_bytes": path.stat().st_size, "sha256": sha256_file(path)}
            if kind in DIMENSIONS:
                facts = probe(path, ffprobe)
                entry["ffprobe"] = facts
                _check_media(tid, lang, kind, name, facts)
            elif kind in ("srt", "vtt"):
                _check_subtitles(tid, lang, kind, name, path)
            files[kind] = entry
        dv = files["yt_video"]["ffprobe"].get("duration_sec")
        dh = files["ig_video"]["ffprobe"].get("duration_sec")
        if dv is None or dh is None or abs(dv - dh) > 0.25:
            raise PackageError(f"{tid}/{lang}: horizontal ({dv}s) and vertical ({dh}s) durations differ")
        rec["editions"][lang] = {"files": files, "duration_sec": dv}
    durs = [e["duration_sec"] for e in rec["editions"].values()]
    if max(durs) - min(durs) > 0.5:
        rec["warnings"].append(f"{tid}: durations differ between languages by more than 0.5 s: {durs}")
    topic = BY_ID[tid]
    ch = chapters_mod.compute(topic, docs_video, audio_root)
    if ch.get("chapters"):
        end = ch["chapters"][-1]["end"]
        if abs(end - durs[0]) > 0.6:
            rec["warnings"].append(f"{tid}: chapter timing ends at {end:.1f}s but the video is {durs[0]:.1f}s: "
                                   f"the timing manifest may be stale; check the timestamps")
        for p in ch["problems"]:
            rec["warnings"].append(f"{tid}: chapters: {p}")
    else:
        rec["warnings"].append(f"{tid}: no chapters in the metadata ({ch.get('reason')})")
    if not topic["verified"]:
        rec["warnings"].append(f"{tid}: kit text is a DRAFT written before the video: verify every sentence against "
                               f"lines.en.json / CLAIMS_AND_EVIDENCE.md, then set verified=True in topics.py")
    rec["chapters"] = ch
    rec["claims_table"] = f"docs/video/{tid}/CLAIMS_AND_EVIDENCE.md"
    rec["claims_sha256"] = sha256_file(Path(docs_video) / tid / "CLAIMS_AND_EVIDENCE.md")
    return rec


def _check_media(tid, lang, kind, name, facts):
    want_w, want_h = DIMENSIONS[kind]
    v = facts.get("video")
    if not v:
        raise PackageError(f"{tid}/{lang}: {name} has no video stream")
    if (v["width"], v["height"]) != (want_w, want_h):
        raise PackageError(f"{tid}/{lang}: {name} is {v['width']}x{v['height']}, expected {want_w}x{want_h}")
    if kind in ("yt_video", "ig_video"):
        if v["codec"] != "h264":
            raise PackageError(f"{tid}/{lang}: {name} codec is {v['codec']}, expected h264")
        if v.get("pix_fmt") != "yuv420p":
            raise PackageError(f"{tid}/{lang}: {name} pix_fmt is {v.get('pix_fmt')}, expected yuv420p")
        if not facts.get("audio"):
            raise PackageError(f"{tid}/{lang}: {name} has no audio stream (the texts promise English narration)")
        if not facts.get("duration_sec") or facts["duration_sec"] <= 0:
            raise PackageError(f"{tid}/{lang}: {name} has no duration")
    else:
        if v["codec"] not in ("mjpeg", "jpeg"):
            raise PackageError(f"{tid}/{lang}: {name} is {v['codec']}, expected a JPEG")


def _check_subtitles(tid, lang, kind, name, path):
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        raise PackageError(f"{tid}/{lang}: {name} is not valid UTF-8")
    if kind == "vtt" and not text.lstrip("﻿").startswith("WEBVTT"):
        raise PackageError(f"{tid}/{lang}: {name} does not start with WEBVTT")
    if kind == "srt" and "-->" not in text:
        raise PackageError(f"{tid}/{lang}: {name} has no cues")


# ------------------------------------------------------------------------------------ texts
def edition_texts(topic, lang, ch, ui):
    """The per-edition text files for the YouTube package."""
    meta_yt = kit.metadata(topic, ch, ("READY", ""), {lang: ui.get(lang, {})})["youtube"][lang]
    chapters_txt = ("\n".join(chapters_mod.chapter_lines(ch["chapters"], lang)) if ch.get("chapters")
                    else f"(no chapters available: {ch.get('reason')})")
    credits = list(CREDITS[lang]) + ([("Sources: " if lang == "en" else "Источники: " if lang == "ru"
                                       else "Manbalar: ") + " ".join(topic["sources"])] if topic.get("sources") else [])
    return {
        "title.txt": meta_yt["title"],
        "description.txt": meta_yt["description"],
        "tags.txt": ", ".join(meta_yt["tags"]),
        "hashtags.txt": " ".join(kit.hashtags(topic, lang)),
        "chapters.txt": chapters_txt,
        "pinned_comment.txt": meta_yt["pinned_comment"],
        "credits.txt": "\n".join(credits),
        "disclosures.txt": "\n".join(kit.disclosure_lines(lang)),
        "thumbnail_alt.txt": meta_yt["thumbnail_alt"],
    }


def ig_texts(topic, lang, ui):
    caption, tags = kit.instagram_caption(topic, lang)
    return {
        "caption.txt": caption,
        "hashtags.txt": tags,
        "caption_with_hashtags.txt": caption + "\n\n" + tags,
        "cover_alt.txt": kit.alt_text(topic, lang, ui.get(lang)),
    }


def load_ui(docs_video, tid):
    out = {}
    for lang in LANGS:
        p = Path(docs_video) / tid / f"lines.{lang}.json"
        if p.is_file():
            out[lang] = json.loads(p.read_text(encoding="utf-8")).get("ui", {})
    return out


def find_placeholders(texts):
    found = {}
    for name, text in texts.items():
        for ph in PLACEHOLDERS:
            if ph in text:
                found.setdefault(ph, []).append(name)
    return found


# ------------------------------------------------------------------------------------ entries
class Entry:
    """A zip entry: either a source file or in-memory bytes."""

    def __init__(self, arcname, path=None, data=None, compress=None, mtime=None):
        self.arcname, self.path, self.data = arcname, path, data
        media = str(arcname).lower().endswith((".mp4", ".jpg", ".jpeg"))
        self.compress = compress if compress is not None else (zipfile.ZIP_STORED if media else zipfile.ZIP_DEFLATED)
        self.mtime = mtime
        if data is not None:
            self.sha256 = sha256_bytes(data)
            self.size = len(data)
        else:
            self.sha256 = None
            self.size = Path(path).stat().st_size


def text_entry(arcname, text, stamp):
    return Entry(arcname, data=text.replace("\r\n", "\n").encode("utf-8"), mtime=stamp)


def file_entry(arcname, path, sha=None):
    e = Entry(arcname, path=path, mtime=path.stat().st_mtime)
    e.sha256 = sha or sha256_file(path)
    return e


def readme_youtube(records, stamp_iso, warnings):
    out = []
    ap = out.append
    ap("# LabGuide — YouTube package (16:9)")
    ap("")
    ap(f"Generated {stamp_iso} by `tool/publish/package.py`. **DRAFT hand-over: nothing here has been uploaded or "
       "published, and nothing is approved. The owner decides what to publish and when, after the expert review.**")
    ap("")
    ap("## What is inside")
    ap("")
    ap("One folder per topic, one sub-folder per language edition. Each edition is a separate video (English synthetic "
       "narration in all three; subtitles and on-screen text in the edition's language):")
    ap("")
    ap("```text")
    ap("<topic>/<lang>/<topic>_<lang>_horizontal.mp4     1920x1080 H.264, AAC")
    ap("<topic>/<lang>/<topic>_<lang>_thumb_1280x720.jpg  thumbnail")
    ap("<topic>/<lang>/<topic>_<lang>.srt / .vtt          subtitles (UTF-8)")
    ap("<topic>/<lang>/title.txt description.txt tags.txt hashtags.txt chapters.txt pinned_comment.txt")
    ap("                credits.txt disclosures.txt thumbnail_alt.txt")
    ap("<topic>/metadata.json                              all editions, machine-readable")
    ap("<topic>/PUBLISHING_KIT.md                          the full kit (titles, IG captions, gates, safe-content notes)")
    ap("SCHEDULE.md / SCHEDULE.csv                         6-week PROPOSAL (needs owner approval)")
    ap("MANIFEST.json / SHA256SUMS.txt                     ffprobe facts and checksums of every file")
    ap("```")
    ap("")
    ap("## Index")
    ap("")
    ap("| Topic | Tier | Copy | Duration | Editions |")
    ap("|---|---|---|---|---|")
    for r in records:
        t = BY_ID[r["id"]]
        dur = r["editions"]["en"]["duration_sec"]
        ap(f"| `{r['id']}` | {t['tier']} | {'verified' if t['verified'] else 'DRAFT: verify'} | "
           f"{int(dur // 60)}:{int(dur % 60):02d} | en, ru, uz |")
    ap("")
    ap("## SHA-256 of the media files")
    ap("")
    ap("```text")
    for r in records:
        for lang in LANGS:
            for kind in ("yt_video", "thumb", "srt", "vtt"):
                f = r["editions"][lang]["files"][kind]
                ap(f"{f['sha256']}  {r['id']}/{lang}/{f['name']}")
    ap("```")
    ap("")
    ap("## How to post (by hand; the studio never uploads)")
    ap("")
    ap("1. Check every gate below. Do not publish a topic with an open gate.")
    ap("2. YouTube Studio → Create → Upload the edition's MP4. Paste `title.txt`, `description.txt`, `tags.txt`. "
       "Replace the placeholders `[[LINK_APP_STORE]]`, `[[LINK_PLAY]]` (and `[[LINK_PLAYLIST]]`) with the real links; "
       "if a store link is not live yet, remove that line instead of guessing.")
    ap("3. Upload the thumbnail. Language: English audio; add the edition's SRT as a caption track "
       "(the same words are burned into the picture: leave captions off by default). Category Education. "
       "Not made for kids. Answer the platform's synthetic-voice question honestly (NEEDS_OWNER_CHECK).")
    ap("4. Chapters are already inside `description.txt` (first at 0:00). Pin `pinned_comment.txt` after publishing.")
    ap("5. Schedule as the owner approves; `SCHEDULE.md` is only a proposal.")
    ap("")
    ap("## Licences and credits")
    ap("")
    for c in CREDITS["en"]:
        ap(f"* {c}")
    ap("")
    for n in INTERNAL_LICENCE_NOTES:
        ap(f"* (internal) {n}")
    ap("")
    ap("## Mandatory disclosures (already inside every description and caption)")
    ap("")
    for key in DISCLOSURE_ORDER:
        ap(f"* {DISCLOSURES[key]['en']}")
    ap("")
    _gates_section(ap, records)
    _warnings_section(ap, warnings)
    return "\n".join(out) + "\n"


def readme_instagram(records, stamp_iso, warnings):
    out = []
    ap = out.append
    ap("# LabGuide — Instagram package (9:16)")
    ap("")
    ap(f"Generated {stamp_iso} by `tool/publish/package.py`. **DRAFT hand-over: nothing here has been uploaded or "
       "published, and nothing is approved. The owner decides what to publish and when, after the expert review.**")
    ap("")
    ap("## What is inside")
    ap("")
    ap("```text")
    ap("<topic>/<lang>/<topic>_<lang>_vertical.mp4          1080x1920 H.264, AAC (Reels)")
    ap("<topic>/<lang>/<topic>_<lang>_cover_1080x1920.jpg   cover")
    ap("<topic>/<lang>/caption.txt hashtags.txt caption_with_hashtags.txt cover_alt.txt")
    ap("SCHEDULE.md / SCHEDULE.csv                          6-week PROPOSAL (needs owner approval)")
    ap("MANIFEST.json / SHA256SUMS.txt                      ffprobe facts and checksums of every file")
    ap("```")
    ap("")
    ap("## Index")
    ap("")
    ap("| Topic | Tier | Copy | Duration | Editions |")
    ap("|---|---|---|---|---|")
    for r in records:
        t = BY_ID[r["id"]]
        dur = r["editions"]["en"]["duration_sec"]
        ap(f"| `{r['id']}` | {t['tier']} | {'verified' if t['verified'] else 'DRAFT: verify'} | "
           f"{int(dur // 60)}:{int(dur % 60):02d} | en, ru, uz |")
    ap("")
    ap("## SHA-256 of the media files")
    ap("")
    ap("```text")
    for r in records:
        for lang in LANGS:
            for kind in ("ig_video", "cover"):
                f = r["editions"][lang]["files"][kind]
                ap(f"{f['sha256']}  {r['id']}/{lang}/{f['name']}")
    ap("```")
    ap("")
    ap("## How to post (by hand; the studio never uploads)")
    ap("")
    ap("1. Check every gate below. Do not publish a topic with an open gate.")
    ap("2. Instagram → New Reel → pick the edition's MP4. Choose the cover from `…_cover_1080x1920.jpg` "
       "(or pick a frame; check the title stays inside the safe area).")
    ap("3. Paste `caption.txt`; paste `hashtags.txt` at its end or as the first comment (`caption_with_hashtags.txt` "
       "is both, ≤ 2200 characters). Replace `[[LINK_BIO]]` after you have put the real link in the profile; "
       "if there is no store link yet, delete the CTA line instead of guessing.")
    ap("4. Add `cover_alt.txt` as the alt text. Answer the platform's AI-content / synthetic-voice label question "
       "honestly (NEEDS_OWNER_CHECK for the current wording).")
    ap("5. Subtitles are burned into the picture; there is no separate caption file on Instagram.")
    ap("6. Do not add music, stickers with prices, or third-party logos.")
    ap("")
    ap("## Licences and credits")
    ap("")
    for c in CREDITS["en"]:
        ap(f"* {c}")
    ap("")
    ap("## Mandatory disclosures (already inside every caption)")
    ap("")
    for key in DISCLOSURE_ORDER:
        ap(f"* {DISCLOSURES[key]['en']}")
    ap("")
    _gates_section(ap, records)
    _warnings_section(ap, warnings)
    return "\n".join(out) + "\n"


def _gates_section(ap, records):
    ap("## Gates (all open until a person closes them)")
    ap("")
    for gid, text in GATES:
        ap(f"* **{gid}** — {text}")
    if any(BY_ID[r["id"]]["tier"] == "paid" for r in records):
        ap(f"* **{PAID_GATE[0]}** — {PAID_GATE[1]}")
    ap("")


def _warnings_section(ap, warnings):
    if warnings:
        ap("## Warnings at build time")
        ap("")
        for w in warnings:
            ap(f"* {w}")
        ap("")


# ------------------------------------------------------------------------------------ building
def build_entries(records, docs_video, statuses, stamp, stamp_iso, date_label, warnings, only):
    """Return (yt_entries, ig_entries, placeholders)."""
    yt, ig = [], []
    all_texts = {}
    sched_md = schedule_mod.render_md(statuses, date_label)
    sched_csv = schedule_mod.render_csv(statuses)
    for r in records:
        tid = r["id"]
        topic = BY_ID[tid]
        ui = load_ui(docs_video, tid)
        meta_full = kit.metadata(topic, r["chapters"], statuses[tid], ui)
        kit_md = kit.render_md(topic, r["chapters"], statuses[tid], ui)
        all_texts[f"{tid}/PUBLISHING_KIT.md"] = kit_md
        yt.append(text_entry(f"{YT_ROOT}/{tid}/PUBLISHING_KIT.md", kit_md, stamp))
        yt.append(text_entry(f"{YT_ROOT}/{tid}/metadata.json",
                             json.dumps(meta_full, ensure_ascii=False, indent=2) + "\n", stamp))
        ig_meta = {"id": tid, "tier": topic["tier"], "copy_verified_against_final_video": topic["verified"],
                   "instagram": meta_full["instagram"], "disclosures": meta_full["disclosures"],
                   "publish_blocked_until": meta_full["publish_blocked_until"]}
        ig.append(text_entry(f"{IG_ROOT}/{tid}/metadata.json", json.dumps(ig_meta, ensure_ascii=False, indent=2) + "\n",
                             stamp))
        for lang in LANGS:
            files = r["editions"][lang]["files"]
            for kind in ("yt_video", "thumb", "srt", "vtt"):
                f = files[kind]
                yt.append(file_entry(f"{YT_ROOT}/{tid}/{lang}/{f['name']}", f["path"], f["sha256"]))
            for name, text in edition_texts(topic, lang, r["chapters"], ui).items():
                all_texts[f"{tid}/{lang}/{name}"] = text
                yt.append(text_entry(f"{YT_ROOT}/{tid}/{lang}/{name}", text + "\n", stamp))
            for kind in ("ig_video", "cover"):
                f = files[kind]
                ig.append(file_entry(f"{IG_ROOT}/{tid}/{lang}/{f['name']}", f["path"], f["sha256"]))
            for name, text in ig_texts(topic, lang, ui).items():
                all_texts[f"{tid}/{lang}/ig_{name}"] = text
                ig.append(text_entry(f"{IG_ROOT}/{tid}/{lang}/{name}", text + "\n", stamp))
    placeholders = find_placeholders(all_texts)
    yt.append(text_entry(f"{YT_ROOT}/SCHEDULE.md", sched_md, stamp))
    yt.append(text_entry(f"{YT_ROOT}/SCHEDULE.csv", sched_csv, stamp))
    ig.append(text_entry(f"{IG_ROOT}/SCHEDULE.md", sched_md, stamp))
    ig.append(text_entry(f"{IG_ROOT}/SCHEDULE.csv", sched_csv, stamp))
    yt.append(text_entry(f"{YT_ROOT}/README.md", readme_youtube(records, stamp_iso, warnings), stamp))
    ig.append(text_entry(f"{IG_ROOT}/README.md", readme_instagram(records, stamp_iso, warnings), stamp))
    for entries, root in ((yt, YT_ROOT), (ig, IG_ROOT)):
        sums = "".join(f"{e.sha256}  {e.arcname[len(root) + 1:]}\n"
                       for e in sorted(entries, key=lambda e: e.arcname) if not e.arcname.endswith("README.md"))
        entries.append(text_entry(f"{root}/SHA256SUMS.txt", sums, stamp))
    return yt, ig, placeholders


def manifest_dict(records, statuses, stamp_iso, warnings, placeholders):
    topics = []
    for r in records:
        t = BY_ID[r["id"]]
        eds = {}
        for lang, ed in r["editions"].items():
            eds[lang] = {"duration_sec": ed["duration_sec"],
                         "files": {k: {"name": f["name"], "size_bytes": f["size_bytes"], "sha256": f["sha256"],
                                       **({"ffprobe": f["ffprobe"]} if "ffprobe" in f else {})}
                                   for k, f in ed["files"].items()}}
        topics.append({"id": r["id"], "tier": t["tier"], "video_status": statuses[r["id"]][0],
                       "copy_verified_against_final_video": t["verified"], "claims_table": r["claims_table"],
                       "claims_sha256": r["claims_sha256"],
                       "chapters": ([{"timestamp": chapters_mod.fmt_ts(c["start"]), "start_sec": round(c["start"], 2),
                                      "titles": c["titles"], "auto_title": c["auto"]}
                                     for c in r["chapters"]["chapters"]] if r["chapters"].get("chapters") else None),
                       "editions": eds})
    return {"tool": "tool/publish/package.py", "generated_at": stamp_iso,
            "state": "DRAFT hand-over: nothing uploaded or published; owner approval required",
            "topic_ids": [r["id"] for r in records], "topics": topics, "warnings": warnings,
            "placeholders_to_fill": placeholders,
            "gates": {g: t for g, t in GATES} | ({PAID_GATE[0]: PAID_GATE[1]} if any(
                BY_ID[r["id"]]["tier"] == "paid" for r in records) else {})}


def estimate_bytes(entries):
    return sum(e.size for e in entries) + 512 * len(entries)


def free_bytes(path):
    p = Path(path)
    while not p.exists():
        p = p.parent
    return shutil.disk_usage(p).free


def write_zip(entries, dest, verify=True, log=print):
    """Write `entries` to `dest` atomically; verify every entry's sha256 by reading the archive back."""
    dest = Path(dest)
    partial = dest.with_name(dest.name + ".partial")
    if partial.exists():
        partial.unlink()
    try:
        with zipfile.ZipFile(partial, "w", allowZip64=True) as zf:
            for e in sorted(entries, key=lambda e: e.arcname):
                mt = datetime.datetime.fromtimestamp(e.mtime or datetime.datetime.now().timestamp())
                dt = (max(mt.year, 1980), mt.month, mt.day, mt.hour, mt.minute, mt.second)
                zi = zipfile.ZipInfo(e.arcname, date_time=dt)
                zi.compress_type = e.compress
                zi.external_attr = 0o644 << 16
                if e.data is not None:
                    zf.writestr(zi, e.data)
                else:
                    with open(e.path, "rb") as src, zf.open(zi, "w", force_zip64=True) as dst:
                        shutil.copyfileobj(src, dst, 1 << 20)
        if verify:
            with zipfile.ZipFile(partial) as zf:
                bad = zf.testzip()
                if bad:
                    raise PackageError(f"{dest.name}: CRC error in {bad}")
                want = {e.arcname: e.sha256 for e in entries}
                names = set(zf.namelist())
                if names != set(want):
                    raise PackageError(f"{dest.name}: entry list differs from the plan")
                for name in names:
                    h = hashlib.sha256()
                    with zf.open(name) as f:
                        for chunk in iter(lambda: f.read(1 << 20), b""):
                            h.update(chunk)
                    if h.hexdigest() != want[name]:
                        raise PackageError(f"{dest.name}: sha256 mismatch for {name}")
        os.replace(partial, dest)
    finally:
        if partial.exists():
            partial.unlink()
    return {"name": dest.name, "size_bytes": dest.stat().st_size, "sha256": sha256_file(dest),
            "entries": len(entries)}


def run(out_root=OUT_ROOT, docs_video=DOCS_VIDEO, audio_root=AUDIO_ROOT, out_dir=None, ids=None, only=None,
        dry_run=False, skip_unclaimed=False, verify=True, ffprobe="ffprobe", log=print):
    out_root, docs_video = Path(out_root), Path(docs_video)
    out_dir = Path(out_dir) if out_dir else out_root / "packages"
    ready_ids = kit.read_ready_ids(out_root)
    todo, warnings = discover(out_root, ready_ids, ids)
    if not todo:
        raise PackageError(f"nothing to package: no id with rendered files under {out_root}")
    records, excluded = [], []
    for tid in todo:
        try:
            rec = collect_topic(tid, out_root, docs_video, audio_root, ffprobe)
        except PackageError as e:
            if skip_unclaimed and "refused:" in str(e):
                excluded.append(str(e))
                warnings.append(str(e) + " (excluded by --skip-unclaimed)")
                continue
            raise
        warnings += rec["warnings"]
        records.append(rec)
    if not records:
        raise PackageError("nothing left to package after exclusions")
    statuses = {r["id"]: kit.topic_status(BY_ID[r["id"]], out_root, ready_ids) for r in records}
    stamp = datetime.datetime.now().timestamp()
    stamp_iso = datetime.datetime.now().astimezone().isoformat(timespec="seconds")
    date_label = datetime.date.today().isoformat()
    yt, ig, placeholders = build_entries(records, docs_video, statuses, stamp, stamp_iso, date_label, warnings, only)
    manifest = manifest_dict(records, statuses, stamp_iso, warnings, placeholders)
    for entries, root in ((yt, YT_ROOT), (ig, IG_ROOT)):
        entries.append(text_entry(f"{root}/MANIFEST.json", json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
                                  stamp))
    plan = []
    if only in (None, "youtube"):
        plan.append((YOUTUBE_ZIP, yt))
    if only in (None, "instagram"):
        plan.append((INSTAGRAM_ZIP, ig))
    result = {"ids": [r["id"] for r in records], "warnings": warnings, "excluded": excluded,
              "planned": {name: estimate_bytes(es) for name, es in plan}, "archives": {}}
    if dry_run:
        return result
    out_dir.mkdir(parents=True, exist_ok=True)
    need = sum(result["planned"].values()) + SPACE_MARGIN
    free = free_bytes(out_dir)
    old = [out_dir / name for name, _ in plan if (out_dir / name).exists()]
    old_size = sum(p.stat().st_size for p in old)
    if free < need:
        if free + old_size >= need and old:
            for p in old:
                log(f"disk: {free / 1e6:.0f} MB free, {need / 1e6:.0f} MB needed: deleting the old {p.name} first")
                p.unlink()
        else:
            raise PackageError(f"not enough disk space in {out_dir}: {free / 1e6:.0f} MB free, about "
                               f"{need / 1e6:.0f} MB needed (free space or pass --out-dir on another disk)")
    for name, entries in plan:
        log(f"writing {name} ({len(entries)} entries, about {estimate_bytes(entries) / 1e6:.0f} MB) ...")
        result["archives"][name] = write_zip(entries, out_dir / name, verify=verify, log=log)
    full = dict(manifest)
    full["archives"] = result["archives"]
    full["excluded"] = excluded
    (out_dir / MANIFEST).write_text(json.dumps(full, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    result["manifest"] = str(out_dir / MANIFEST)
    return result


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--ids", help="comma-separated topic ids (default: every id that has files)")
    ap.add_argument("--out-root", default=str(OUT_ROOT), help="render output root (default video_studio/out)")
    ap.add_argument("--docs-video", default=str(DOCS_VIDEO), help="docs/video directory")
    ap.add_argument("--audio-root", default=str(AUDIO_ROOT), help="narration timing manifests (public/audio)")
    ap.add_argument("--out-dir", help="where to write the archives (default <out-root>/packages)")
    ap.add_argument("--only", choices=("youtube", "instagram"), help="build just one archive")
    ap.add_argument("--dry-run", action="store_true", help="validate and report; write nothing")
    ap.add_argument("--skip-unclaimed", action="store_true",
                    help="exclude (with a warning) ids lacking a claims table instead of failing")
    ap.add_argument("--no-verify", action="store_true", help="skip reading the archives back to verify sha256")
    args = ap.parse_args(argv)
    try:
        res = run(out_root=args.out_root, docs_video=args.docs_video, audio_root=args.audio_root,
                  out_dir=args.out_dir, ids=[i for i in (args.ids or "").split(",") if i] or None,
                  only=args.only, dry_run=args.dry_run, skip_unclaimed=args.skip_unclaimed,
                  verify=not args.no_verify)
    except PackageError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2
    print("topics:", ", ".join(res["ids"]))
    for w in res["warnings"]:
        print("warning:", w)
    if args.dry_run:
        for name, size in res["planned"].items():
            print(f"would write {name}: about {size / 1e6:.0f} MB")
        return 0
    for name, a in res["archives"].items():
        print(f"{name}: {a['size_bytes'] / 1e6:.1f} MB, {a['entries']} entries, sha256 {a['sha256']}")
    print("manifest:", res["manifest"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
