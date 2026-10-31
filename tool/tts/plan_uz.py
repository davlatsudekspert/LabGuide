#!/usr/bin/env python3
"""Build the scene-by-scene Uzbek voice plans (docs/video/<id>/voice_uz/{plan.json,plan.csv,pronunciation_uz.csv}).

    python3 tool/tts/plan_uz.py                # all 9 videos, writes the files
    python3 tool/tts/plan_uz.py --check        # no writes; print the fit table
    python3 tool/tts/plan_uz.py --rate 12.0    # re-evaluate with a measured speech rate (chars/s)

Inputs (all in the repo, nothing is downloaded, no TTS is called):
  video_studio/public/audio/en/<id>.timing.json   line start/end of the ENGLISH narration = the timeline
  docs/video/<id>/storyboard.json                 scenes, lead/tail/gap rules (layout re-implemented from
                                                  video_studio/src/lib/timing.js)
  docs/video/voice_uz/resolved_lines.json         lines.uz.json with {placeholders} resolved
                                                  (video_studio/scripts/dump_resolved_lines.mjs)
  docs/video/voice_uz/suggestions_uz.json         hand-written SHORTER wordings (used only for TOO_LONG lines)

ASSUMPTIONS (documented, NOT measured - nobody has synthesised Uzbek yet):
  * speech rate 13 characters/second of the TTS-ready text (spaces and punctuation included); the
    low/high band is 11 / 15 chars/s. The real number comes from `synth_uz.py --sample`.
  * the Uzbek clip starts where the English clip starts and may run until the next line starts minus a
    0.10 s guard (last line of a scene: until the scene ends minus 0.05 s; very last line: until the
    video end minus 0.10 s). ffmpeg atempo may speed a clip up by at most 12 %.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(HERE))
import uz_prep  # noqa: E402

VIDEOS = ["overview", "calibration", "qc", "photometry", "osmometry", "leukocyte", "calculators", "gcms", "qpcr"]
SCHEMA = "labguide.voice_uz.plan/1"
PRICE_SOM_PER_CHAR = 0.5  # UzbekVoice price relayed by the owner (unverified): 500 so'm per 1000 characters
RATE_CPS = 13.0
RATE_LOW, RATE_HIGH = 11.0, 15.0
MAX_TEMPO = 1.12
GUARD_LINE = 0.10
GUARD_SCENE = 0.05
GUARD_END = 0.10
SHORT_RATIO = 0.60  # TOO_SHORT when estimated speech < 60 % of the English clip

def read_json(p: Path):
    return json.loads(p.read_text(encoding="utf-8"))


def layout_scenes(storyboard: dict, lines: list[dict]) -> list[dict]:
    """Python port of layoutScenes() in video_studio/src/lib/timing.js (scene start/end seconds)."""
    cfg = storyboard["timing"]
    by_id = {l["id"]: l for l in lines}
    scenes = storyboard["scenes"]
    starts = []
    for k, sc in enumerate(scenes):
        if k == 0:
            starts.append(0.0)
            continue
        first = by_id[sc["lines"][0]]
        prev = scenes[k - 1]
        prev_end = by_id[prev["lines"][-1]]["end"]
        starts.append(max(prev_end + 0.05, first["start"] - cfg["leadSec"]))
    last = scenes[-1]
    last_end = by_id[last["lines"][-1]]["end"]
    total = max(last_end + cfg["tailSec"], starts[-1] + last["minSec"])
    out = []
    for k, sc in enumerate(scenes):
        end = starts[k + 1] if k + 1 < len(scenes) else total
        out.append({"id": sc["id"], "layer": sc.get("layer"), "start": starts[k], "end": end, "lines": sc["lines"]})
    return out


def estimate_s(chars: int, rate: float = RATE_CPS) -> float:
    return chars / rate


def judge(est: float, available: float, window: float) -> dict:
    """Fit verdict. OK = fits with at most +12 % tempo. See module docstring."""
    tempo = est / available if available > 0 else 99.0
    after = est / MAX_TEMPO - available
    if after > 1e-9:
        verdict = "TOO_LONG by %.2f s" % after
    elif est < SHORT_RATIO * window:
        verdict = "TOO_SHORT"
    else:
        verdict = "OK"
    return {"fit": verdict, "overrun_s": round(est - available, 2),
            "overrun_after_max_speedup_s": round(max(0.0, after), 2),
            "tempo_needed": round(max(1.0, tempo), 3)}


def check_banned(text: str) -> str:
    if uz_prep.BANNED.search(text):
        raise SystemExit("banned term in text: %r" % text)
    return text


def build_video(vid: str, resolved: dict, suggestions: dict, rate: float) -> dict:
    sb = read_json(REPO / "docs/video" / vid / "storyboard.json")
    timing = read_json(REPO / "video_studio/public/audio/en" / ("%s.timing.json" % vid))
    tl = timing["lines"]
    scenes = layout_scenes(sb, tl)
    scene_of = {lid: s for s in scenes for lid in s["lines"]}
    total = timing["totalSec"]
    uz = resolved["videos"][vid]["uz"]
    uz_tpl = resolved["videos"][vid]["uz_template"]
    en = resolved["videos"][vid]["en"]
    order = [lid for s in sb["scenes"] for lid in s["lines"]]
    by_id = {l["id"]: l for l in tl}
    rows = []
    for i, lid in enumerate(order):
        l = by_id[lid]
        sc = scene_of[lid]
        nxt = by_id[order[i + 1]] if i + 1 < len(order) else None
        last_in_scene = sc["lines"][-1] == lid
        if nxt is not None and not last_in_scene:
            slot_end = nxt["start"] - GUARD_LINE
        elif nxt is not None:
            slot_end = sc["end"] - GUARD_SCENE
        else:
            slot_end = total - GUARD_END
        hard_end = (nxt["start"] - 0.02) if nxt is not None else total - 0.02
        slot_end = max(slot_end, l["end"])
        available = slot_end - l["start"]
        window = l["end"] - l["start"]
        text = check_banned(uz[lid])
        notes = []
        if lid in resolved.get("source_term_replaced", {}).get(vid, []):
            notes.append("SOURCE_TERM_REPLACED: lines.uz.json holds a word from the owner's banned list; the voice "
                         "text uses the neutral loanword 'kategoriyasi' (fix the source subtitle/on-screen key too)")
        spoken, used, warns = uz_prep.prepare(text)
        c_written, c_spoken = len(text), len(spoken)
        est = estimate_s(c_spoken, rate)
        j = judge(est, available, window)
        row = {
            "id": lid, "scene": sc["id"], "layer": sc["layer"],
            "scene_start_s": round(sc["start"], 3), "scene_end_s": round(sc["end"], 3),
            "start_s": l["start"], "end_s": l["end"], "en_clip_s": round(window, 3),
            "slot_end_s": round(slot_end, 3), "hard_end_s": round(hard_end, 3),
            "available_s": round(available, 3),
            "text_uz": text,
            "text_uz_template": uz_tpl[lid] if uz_tpl[lid] != uz[lid] else None,
            "text_en_reference": en[lid],
            "chars_written": c_written, "text_tts": spoken, "chars_spoken": c_spoken,
            "est_speech_s": round(est, 2),
            "est_speech_s_range": [round(c_spoken / RATE_HIGH, 2), round(c_spoken / RATE_LOW, 2)],
            **j,
            "suggested": None,
            "pronunciation_terms": sorted({u["term"] for u in used if u["kind"] != "watch"}),
            "review": "NEEDS_NATIVE_REVIEW",
            "notes": notes + warns,
            "_used": used,
        }
        if warns:
            row["review"] = "NEEDS_MANUAL"
        if j["fit"].startswith("TOO_LONG"):
            sug = suggestions.get(lid)
            if isinstance(sug, dict) and sug.get("none"):
                row["suggested"] = {"status": "NO_SAFE_SHORTENING", "note": sug["none"]}
            elif sug:
                s_text = check_banned(sug)
                s_spoken, _, s_warns = uz_prep.prepare(s_text)
                s_est = estimate_s(len(s_spoken), rate)
                row["suggested"] = {
                    "text_uz": s_text, "text_tts": s_spoken, "chars_written": len(s_text),
                    "chars_spoken": len(s_spoken), "est_speech_s": round(s_est, 2),
                    **judge(s_est, available, window),
                    "status": "SUGGESTED", "review": "NEEDS_NATIVE_REVIEW",
                    "note": "shorter wording of the same statement; owner / native review required; "
                            "burned-in subtitles still show the long text unless lines.uz.json is changed too",
                    "warnings": s_warns,
                }
            else:
                row["suggested"] = {"status": "MISSING", "note": "no suggestion written yet"}
        rows.append(row)
    n_long = sum(1 for r in rows if r["fit"].startswith("TOO_LONG"))
    n_short = sum(1 for r in rows if r["fit"] == "TOO_SHORT")
    def _unresolved(r):
        sg = r["suggested"] or {}
        return r["fit"].startswith("TOO_LONG") and (not sg.get("fit") or sg["fit"].startswith("TOO_LONG"))

    after_long = sum(1 for r in rows if _unresolved(r))
    est_with = sum((r["suggested"] or {}).get("est_speech_s", r["est_speech_s"]) for r in rows)
    plan = {
        "schema": SCHEMA, "videoId": vid, "lang": "uz", "script": "Latin (o‘ g‘ = U+2018, tutuq = U+2019)",
        "status": "NEEDS_NATIVE_REVIEW",
        "timeline": {"source": "video_studio/public/audio/en/%s.timing.json" % vid, "total_s": total,
                     "note": "The English narration timing defines scene boundaries of the existing renders; the Uzbek "
                             "track must keep the same total length so it can be muxed with -c:v copy."},
        "assumptions": {"speech_rate_chars_per_s": rate, "rate_band": [RATE_LOW, RATE_HIGH],
                        "rate_basis": "assumed for Uzbek neural TTS, text = TTS-ready variant incl. spaces; NOT measured",
                        "max_tempo": MAX_TEMPO, "line_guard_s": GUARD_LINE, "scene_guard_s": GUARD_SCENE,
                        "too_short_below": "%.0f %% of the English clip" % (SHORT_RATIO * 100)},
        "summary": {
            "lines": len(rows),
            "available_s": round(sum(r["available_s"] for r in rows), 2),
            "en_clip_s": round(sum(r["en_clip_s"] for r in rows), 2),
            "est_speech_s": round(sum(r["est_speech_s"] for r in rows), 2),
            "too_long": n_long, "too_short": n_short,
            "too_long_after_suggestions": after_long,
            "est_speech_s_with_suggestions": round(est_with, 2),
            "chars_written": sum(r["chars_written"] for r in rows),
            "chars_spoken": sum(r["chars_spoken"] for r in rows),
            "chars_spoken_with_suggestions": sum((r["suggested"] or {}).get("chars_spoken", r["chars_spoken"])
                                                 for r in rows),
        },
        "lines": [{k: v for k, v in r.items() if k != "_used"} for r in rows],
    }
    plan["_rows_used"] = {r["id"]: r["_used"] for r in rows}
    return plan


CSV_COLS = ["id", "scene", "start_s", "end_s", "en_clip_s", "available_s", "chars_written", "chars_spoken",
            "est_speech_s", "tempo_needed", "fit", "text_uz", "text_tts", "suggested_text_uz (SUGGESTED)",
            "suggested_est_speech_s", "suggested_fit", "review"]


def write_plan_files(plan: dict, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    used = plan.pop("_rows_used")
    (out_dir / "plan.json").write_text(json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with (out_dir / "plan.csv").open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(CSV_COLS)
        for r in plan["lines"]:
            s = r["suggested"] or {}
            w.writerow([r["id"], r["scene"], r["start_s"], r["end_s"], r["en_clip_s"], r["available_s"],
                        r["chars_written"], r["chars_spoken"], r["est_speech_s"], r["tempo_needed"], r["fit"],
                        r["text_uz"], r["text_tts"], s.get("text_uz", ""), s.get("est_speech_s", ""),
                        s.get("fit", ""), r["review"]])
    # pronunciation glossary: unique rows, with the line ids that use them
    agg: dict[tuple, dict] = {}
    for lid, items in used.items():
        for u in items:
            k = (u["term"], u["written"], u["spoken"])
            e = agg.setdefault(k, dict(u, lines=[]))
            if lid not in e["lines"]:
                e["lines"].append(lid)
    order = {"HIGH": 0, "MEDIUM": 1, "LOW": 2}
    rows = sorted(agg.values(), key=lambda e: (order[e["risk"]], e["kind"], e["term"]))
    with (out_dir / "pronunciation_uz.csv").open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["term", "written", "spoken_respelling", "risk", "kind", "lines", "note", "review"])
        for e in rows:
            w.writerow([e["term"], e["written"], e["spoken"], e["risk"], e["kind"], " ".join(e["lines"]),
                        e["note"], "NEEDS_NATIVE_REVIEW"])


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="do not write files")
    ap.add_argument("--rate", type=float, default=RATE_CPS, help="chars per second (default %(default)s)")
    ap.add_argument("--only", help="comma separated video ids")
    ap.add_argument("--repo", default=str(REPO))
    a = ap.parse_args(argv)
    resolved = read_json(REPO / "docs/video/voice_uz/resolved_lines.json")
    sug_file = REPO / "docs/video/voice_uz/suggestions_uz.json"
    suggestions = read_json(sug_file) if sug_file.exists() else {}
    vids = a.only.split(",") if a.only else VIDEOS
    tot = {"lines": 0, "avail": 0.0, "est": 0.0, "en": 0.0, "long": 0, "long_after": 0}
    print("%-12s %5s %10s %8s %9s %8s %10s" % ("video", "lines", "avail_s", "en_s", "est_s", "TOO_LONG", "after_sugg"))
    summary = {}
    for vid in vids:
        plan = build_video(vid, resolved, suggestions.get(vid, {}), a.rate)
        s = plan["summary"]
        summary[vid] = dict(s, total_s=plan["timeline"]["total_s"])
        print("%-12s %5d %10.2f %8.2f %9.2f %8d %10d" % (vid, s["lines"], s["available_s"], s["en_clip_s"],
                                                       s["est_speech_s"], s["too_long"], s["too_long_after_suggestions"]))
        for k, v in (("lines", s["lines"]), ("avail", s["available_s"]), ("est", s["est_speech_s"]),
                     ("en", s["en_clip_s"]), ("long", s["too_long"]), ("long_after", s["too_long_after_suggestions"])):
            tot[k] += v
        if not a.check:
            write_plan_files(plan, REPO / "docs/video" / vid / "voice_uz")
    print("%-12s %5d %10.2f %8.2f %9.2f %8d %10d" % ("TOTAL", tot["lines"], tot["avail"], tot["en"], tot["est"],
                                                    tot["long"], tot["long_after"]))
    if not a.check:
        (REPO / "docs/video/voice_uz/FIT_SUMMARY.json").write_text(
            json.dumps({"rate_chars_per_s": a.rate, "videos": summary}, indent=2) + "\n", encoding="utf-8")
        tot_c = sum(summary[v]["chars_spoken"] for v in vids)
        tot_cs = sum(summary[v]["chars_spoken_with_suggestions"] for v in vids)
        longest = max(vids, key=lambda v: summary[v]["chars_spoken"])
        cost = ["", "## Characters and UzbekVoice cost (price 0.5 so'm per character - the owner's figure, not verified on the site)", "",
                "Characters = what is sent to the TTS (TTS-ready text, spaces and punctuation included). Cached lines are not charged again; "
                "a changed line is.", "",
                "| video | characters (original text) | so'm | characters (with suggestions) | so'm |", "|---|---|---|---|---|"]
        for v in vids:
            x = summary[v]
            cost.append("| %s | %d | %.0f | %d | %.0f |" % (v, x["chars_spoken"], x["chars_spoken"] * PRICE_SOM_PER_CHAR,
                                                            x["chars_spoken_with_suggestions"],
                                                            x["chars_spoken_with_suggestions"] * PRICE_SOM_PER_CHAR))
        cost.append("| **all 9, first pass** | %d | %.0f | %d | %.0f |" % (tot_c, tot_c * PRICE_SOM_PER_CHAR, tot_cs, tot_cs * PRICE_SOM_PER_CHAR))
        lc = summary[longest]["chars_spoken"]
        cost += ["", "Longest video: **%s** (%d characters): one full redo costs about %.0f so'm (original text; %.0f so'm with suggestions). "
                 "Balance 10 000 so'm = 20 000 characters, i.e. the first pass of all nine videos (%d characters) uses about %.0f %% of it; "
                 "the sample (219 characters) about %.0f so'm." % (
                     longest, lc, lc * PRICE_SOM_PER_CHAR, summary[longest]["chars_spoken_with_suggestions"] * PRICE_SOM_PER_CHAR,
                     tot_c, 100.0 * tot_c * PRICE_SOM_PER_CHAR / 10000, 219 * PRICE_SOM_PER_CHAR)]
        md = ["# Uzbek voice: fit summary (ESTIMATES, nothing synthesised)", "",
              "Generated by `python3 tool/tts/plan_uz.py` at an assumed **%g characters/second** (TTS-ready text, band %g-%g). "
              "NEEDS_NATIVE_REVIEW. `available` = sum of the line slots (start -> next start minus guard); `EN clip` = the English "
              "narration speech in the same lines; `est` = Uzbek speech estimate; a line is TOO_LONG when it does not fit its slot "
              "even at +12 %% tempo." % (a.rate, RATE_LOW, RATE_HIGH), "",
              "| video | lines | video length s | available s | EN clip s | est Uzbek s | est with suggestions s | TOO_LONG | still TOO_LONG with suggestions |",
              "|---|---|---|---|---|---|---|---|---|"]
        t = [0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0]
        for vid in vids:
            x = summary[vid]
            md.append("| %s | %d | %.1f | %.1f | %.1f | %.1f | %.1f | %d | %d |" % (
                vid, x["lines"], x["total_s"], x["available_s"], x["en_clip_s"], x["est_speech_s"],
                x["est_speech_s_with_suggestions"], x["too_long"], x["too_long_after_suggestions"]))
            for i, k in enumerate(("lines", "total_s", "available_s", "en_clip_s", "est_speech_s",
                                   "est_speech_s_with_suggestions", "too_long", "too_long_after_suggestions")):
                t[i] += x[k]
        md.append("| **total** | %d | %.1f | %.1f | %.1f | %.1f | %.1f | %d | %d |" % tuple(t))
        (REPO / "docs/video/voice_uz/FIT_SUMMARY.md").write_text("\n".join(md + cost) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
