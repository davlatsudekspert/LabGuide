#!/usr/bin/env python3
"""Re-time the UZBEK edition of a LabGuide video to the length of the Uzbek voice-over.

The English/Russian editions keep the English narration timeline (scene lengths from
video_studio/public/audio/en/<id>.timing.json). The Uzbek voice is longer than the English clips, so the Uzbek
edition gets its own timeline: video_studio/public/audio/uz/<id>.timing.json (same schema as the English file) and,
after real synthesis, video_studio/public/audio/uz/<id>.wav. See docs/video/voice_uz/RETIME_DESIGN.md.

    # dry run, nothing written: old vs new length, per-scene stretch, lines that do not fit (estimated durations)
    python3 tool/tts/retime_uz.py --all --dry-run
    python3 tool/tts/retime_uz.py --all --dry-run --rate 11.6          # slow end of the +-10 % band
    # write ESTIMATED timing files (for a silent preview render, estimated=true; never muxed with a real WAV)
    python3 tool/tts/retime_uz.py --video calculators --write
    # REAL durations (from `synth_uz.py --natural`, voice_uz_lines.json) -> timing.json; + assemble the voice WAV
    python3 tool/tts/retime_uz.py --video qc --lines video_studio/out/qc/uz/voice_uz_lines.json --write \
        --assemble --clips video_studio/out/qc/uz/lines

Rule (scenes only ever get LONGER, and only when a line does not fit):
  * every scene keeps its English length (orig). Its lines start where the English lines start (never earlier) or,
    when the previous Uzbek line ran on, 0.2 s (storyboard gapSec) after it.
  * a line that is longer than its English slot (start -> next line start minus 0.10 s; last line of a scene: scene
    end minus 0.05 s, of the video: minus the 0.35 s tail) is sped up by just enough (atempo, at most +12 %).
  * if it still does not fit, it plays at +12 % and pushes the following lines; the scene then ends 0.35 s (storyboard
    tailSec) after the last line: new = max(orig, last line end + tail). The next scenes shift by the extra seconds.
Durations: REAL (voice_uz_lines.json: per-line natural clip length, silence trimmed) or, until it exists,
ESTIMATED = characters of the TTS-ready text / rate (default 12.9 chars/s, the owner's measurement on the final
spoken-Uzbek-only text; band +-10 %).
"""
from __future__ import annotations

import argparse
import json
import sys
import wave
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(HERE))

VIDEOS = ["overview", "calibration", "qc", "photometry", "osmometry", "leukocyte", "calculators", "gcms", "qpcr"]
RATE_CPS = 12.9
RATE_BAND = (11.6, 14.2)
MAX_TEMPO = 1.12
LINE_GUARD = 0.10
SCENE_GUARD = 0.05
STUDIO = REPO / "video_studio"
AUDIO_UZ = STUDIO / "public" / "audio" / "uz"
SCHEMA_LINES = "labguide.voice_uz.lines/1"


# --------------------------------------------------------------------------- inputs

def load_json(p: Path):
    return json.loads(Path(p).read_text(encoding="utf-8"))


def load_plan(video: str, repo: Path = REPO) -> dict:
    p = repo / "docs/video" / video / "voice_uz" / "plan.json"
    plan = load_json(p)
    if plan.get("schema") != "labguide.voice_uz.plan/1":
        raise SystemExit("%s: not a labguide.voice_uz.plan/1 file" % p)
    return plan


def load_storyboard(video: str, repo: Path = REPO) -> dict:
    return load_json(repo / "docs/video" / video / "storyboard.json")


def line_chars(line: dict, use_suggested: bool) -> int:
    s = line.get("suggested") or {}
    if use_suggested and s.get("status") == "SUGGESTED" and s.get("text_tts"):
        return len(s["text_tts"])
    return len(line["text_tts"])


def estimate_durations(plan: dict, rate: float, use_suggested: bool = False) -> dict[str, float]:
    return {l["id"]: line_chars(l, use_suggested) / rate for l in plan["lines"]}


def read_lines_file(path: Path, expect_ids: list[str]) -> dict[str, float]:
    """Real per-line durations. Accepts {"lines": [{"id","trimmed_s"|"duration_s"|"raw_s"|"seconds"}]},
    {"lines": {"L01": 5.2}}, {"L01": 5.2} or a bare list. Every plan line must be present."""
    raw = load_json(path)
    if isinstance(raw, dict) and raw.get("schema") not in (None, SCHEMA_LINES, "labguide.voice_uz.report/1"):
        raise SystemExit("%s: unknown schema %r" % (path, raw.get("schema")))
    rows = raw.get("lines", raw) if isinstance(raw, dict) else raw
    out: dict[str, float] = {}
    if isinstance(rows, dict):
        for k, v in rows.items():
            if isinstance(v, dict):
                v = next((v[f] for f in ("trimmed_s", "duration_s", "raw_s", "seconds") if f in v), None)
            if isinstance(v, (int, float)):
                out[str(k)] = float(v)
    else:
        for r in rows:
            v = next((r[f] for f in ("trimmed_s", "duration_s", "raw_s", "seconds") if f in r), None)
            if v is not None:
                out[str(r["id"])] = float(v)
    missing = [i for i in expect_ids if i not in out]
    if missing:
        raise SystemExit("%s: no duration for line(s) %s" % (path, ", ".join(missing)))
    bad = [i for i in expect_ids if not out[i] > 0.2]
    if bad:
        raise SystemExit("%s: implausible duration (<= 0.2 s) for %s" % (path, ", ".join(bad)))
    return {i: out[i] for i in expect_ids}


# --------------------------------------------------------------------------- core (pure)

def retime(plan: dict, storyboard: dict, durs: dict[str, float], *, max_tempo: float = MAX_TEMPO,
           line_guard: float = LINE_GUARD, scene_guard: float = SCENE_GUARD) -> dict:
    cfg = storyboard["timing"]
    gap, tail = float(cfg["gapSec"]), float(cfg["tailSec"])
    order = [s["id"] for s in storyboard["scenes"]]
    layer_of = {s["id"]: s["layer"] for s in storyboard["scenes"]}
    by_scene: dict[str, list[dict]] = {sid: [] for sid in order}
    for l in plan["lines"]:
        by_scene[l["scene"]].append(l)
    new_cursor = 0.0
    scenes, lines = [], []
    for si, sid in enumerate(order):
        L = by_scene[sid]
        if not L:
            raise SystemExit("scene %s has no lines in the plan" % sid)
        last_scene = si == len(order) - 1
        s0 = L[0]["scene_start_s"]
        orig = (plan["timeline"]["total_s"] if last_scene else L[0]["scene_end_s"]) - s0
        en_rel = [l["start_s"] - s0 for l in L]
        win_end_scene = orig - (tail if last_scene else scene_guard)
        rows, prev_end = [], None
        for i, l in enumerate(L):
            start = en_rel[i] if prev_end is None else max(en_rel[i], prev_end + gap)
            wend = (en_rel[i + 1] - line_guard) if i + 1 < len(L) else win_end_scene
            window = wend - start
            d = durs[l["id"]]
            if d <= window + 1e-9:
                tempo = 1.0
            elif window > 0 and d / window <= max_tempo:
                tempo = min(max_tempo, d / window * 1.003)  # tiny safety so rounding never leaves it 1 ms over
            else:
                tempo = max_tempo
            final = d / tempo
            end = start + final
            rows.append({"id": l["id"], "rel_start": start, "rel_end": end, "raw_s": d, "tempo": round(tempo, 5),
                         "en_start": en_rel[i], "window_s": window, "overflow_s": max(0.0, end - wend)})
            prev_end = end
        last_end = rows[-1]["rel_end"]
        new = orig if last_end <= win_end_scene + 1e-9 else last_end + tail
        for r in rows:
            lines.append({"id": r["id"], "start": round(new_cursor + r["rel_start"], 3),
                          "end": round(new_cursor + r["rel_end"], 3), "raw_s": round(r["raw_s"], 3), "tempo": r["tempo"]})
        scenes.append({"id": sid, "layer": layer_of[sid], "from_s": round(new_cursor, 3), "orig_s": round(orig, 3),
                       "new_s": round(new, 3), "extra_s": round(new - orig, 3), "stretch": round(new / orig, 3),
                       "lines": len(rows), "sped_up": sum(r["tempo"] > 1.0005 for r in rows),
                       "no_fit_at_max_tempo": [r["id"] for r in rows if r["overflow_s"] > 1e-6],
                       "last_line_end_rel": round(last_end, 3)})
        new_cursor += new
    return {"videoId": plan["videoId"], "lang": "uz", "totalSec": round(new_cursor, 3),
            "orig_total_s": round(plan["timeline"]["total_s"], 3), "lines": lines, "scenes": scenes}


# --------------------------------------------------------------------------- output files

def timing_document(res: dict, *, estimated: bool, rate: float | None, max_tempo: float, source: str) -> dict:
    doc = {"videoId": res["videoId"], "lang": "uz",
           "source": source,
           "estimated": estimated,
           "generatedBy": "tool/tts/retime_uz.py",
           "baseTiming": "public/audio/en/%s.timing.json" % res["videoId"],
           "maxTempo": max_tempo}
    if rate:
        doc["estimateRateCharsPerSec"] = rate
    doc.update({"totalSec": res["totalSec"], "origTotalSec": res["orig_total_s"],
                "review": "PENDING - nobody has listened to the Uzbek voice",
                "lines": res["lines"], "scenes": res["scenes"]})
    return doc


def write_timing(res: dict, out_dir: Path, **kw) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    p = out_dir / ("%s.timing.json" % res["videoId"])
    p.write_text(json.dumps(timing_document(res, **kw), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return p


def assemble_wav(res: dict, clips_dir: Path, out_wav: Path, *, loudnorm: bool = True, tempo_fn=None) -> dict:
    """Place the natural per-line clips (clips_dir/<id>.wav) on the NEW timeline (atempo where the retime asks for it),
    pad to totalSec, loudness-normalise to -16 LUFS like synth_uz.py. Returns a small report."""
    import synth
    import synth_uz
    tempo_fn = tempo_fn or synth_uz.ffmpeg_tempo
    placed, sr_seen, notes = [], None, []
    for l in res["lines"]:
        f = clips_dir / ("%s.wav" % l["id"])
        if not f.exists():
            raise SystemExit("missing clip %s" % f)
        pcm, sr = synth.wav_bytes_to_pcm(f.read_bytes())
        if sr_seen is None:
            sr_seen = sr
        elif sr != sr_seen:
            raise SystemExit("sample rate changed between clips (%d vs %d)" % (sr_seen, sr))
        dur = synth_uz.pcm_seconds(pcm, sr)
        if abs(dur - l["raw_s"]) > 0.05:
            raise SystemExit("clip %s is %.3f s but the timing was made for %.3f s: re-run retime_uz.py with the lines "
                             "file of THIS synthesis" % (l["id"], dur, l["raw_s"]))
        if l["tempo"] > 1.0005:
            pcm = tempo_fn(pcm, sr, l["tempo"])
        placed.append((l["start"], pcm))
        got = synth_uz.pcm_seconds(pcm, sr)
        if got > (l["end"] - l["start"]) + 0.03:
            notes.append("clip %s is %.3f s after tempo, slot %.3f s" % (l["id"], got, l["end"] - l["start"]))
    buf, warns = synth_uz.build_timeline(placed, res["totalSec"], sr_seen)
    out_wav.parent.mkdir(parents=True, exist_ok=True)
    raw = out_wav.with_suffix(".raw.wav")
    synth_uz.write_wav(raw, buf, sr_seen)
    rep: dict = {"warnings": warns + notes}
    if loudnorm:
        rep["loudness"] = synth_uz.loudnorm_two_pass(raw, out_wav)
        raw.unlink()
    else:
        raw.replace(out_wav)
        rep["loudness"] = None
        rep["warnings"].append("loudness normalisation skipped: not -16 LUFS")
    with wave.open(str(out_wav), "rb") as w:
        rep["seconds"] = round(w.getnframes() / w.getframerate(), 3)
        rep["sample_rate"] = w.getframerate()
    return rep


# --------------------------------------------------------------------------- reporting

def fmt_table(results: list[dict]) -> str:
    out = ["%-12s %8s %8s %7s %9s %7s %s" % ("video", "old s", "new s", "+s", "x total", "stretched", "biggest stretched scenes")]
    for r in results:
        st = sorted((s for s in r["scenes"] if s["extra_s"] > 0.0005), key=lambda s: -s["extra_s"])
        big = ", ".join("%s +%.1fs (x%.2f)" % (s["id"], s["extra_s"], s["stretch"]) for s in st[:3]) or "-"
        out.append("%-12s %8.1f %8.1f %7.1f %9.3f %4d/%-3d %s" % (
            r["videoId"], r["orig_total_s"], r["totalSec"], r["totalSec"] - r["orig_total_s"],
            r["totalSec"] / r["orig_total_s"], len(st), len(r["scenes"]), big))
    to, tn = sum(r["orig_total_s"] for r in results), sum(r["totalSec"] for r in results)
    out.append("%-12s %8.1f %8.1f %7.1f %9.3f" % ("TOTAL", to, tn, tn - to, tn / to))
    return "\n".join(out)


def fmt_scenes(r: dict) -> str:
    out = ["%s  %.1f s -> %.1f s" % (r["videoId"], r["orig_total_s"], r["totalSec"])]
    for s in r["scenes"]:
        nf = (" no-fit@+12%%: %s" % ",".join(s["no_fit_at_max_tempo"])) if s["no_fit_at_max_tempo"] else ""
        out.append("  %-12s %-10s %6.2f -> %6.2f  x%.3f  (+%.2f s)  sped_up %d/%d%s" % (
            s["id"], s["layer"], s["orig_s"], s["new_s"], s["stretch"], s["extra_s"], s["sped_up"], s["lines"], nf))
    return "\n".join(out)


def summary_row(r: dict) -> dict:
    st = [s for s in r["scenes"] if s["extra_s"] > 0.0005]
    return {"video": r["videoId"], "old_s": r["orig_total_s"], "new_s": r["totalSec"],
            "extra_s": round(r["totalSec"] - r["orig_total_s"], 3), "stretched_scenes": len(st), "scenes": len(r["scenes"]),
            "lines_no_fit_at_max_tempo": sum(len(s["no_fit_at_max_tempo"]) for s in r["scenes"]),
            "lines_sped_up": sum(s["sped_up"] for s in r["scenes"]),
            "max_scene_stretch": max(s["stretch"] for s in r["scenes"]),
            "biggest": [{"scene": s["id"], "extra_s": s["extra_s"], "stretch": s["stretch"]}
                        for s in sorted(st, key=lambda s: -s["extra_s"])[:3]]}


# --------------------------------------------------------------------------- CLI

def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--video", help="comma separated video ids")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--lines", help="voice_uz_lines.json with REAL per-line durations (single video). Default: "
                    "<out-root>/<id>/uz/voice_uz_lines.json if it exists, else ESTIMATES")
    ap.add_argument("--out-root", default=str(STUDIO / "out"))
    ap.add_argument("--require-real", action="store_true", help="fail when no real lines file exists (Phase 1)")
    ap.add_argument("--rate", type=float, default=RATE_CPS, help="estimate: chars per second (default %(default)s)")
    ap.add_argument("--use-suggested", action="store_true", help="estimate with the SUGGESTED shorter texts")
    ap.add_argument("--max-tempo", type=float, default=MAX_TEMPO)
    ap.add_argument("--dry-run", action="store_true", help="print only, write nothing")
    ap.add_argument("--write", action="store_true", help="write video_studio/public/audio/uz/<id>.timing.json")
    ap.add_argument("--audio-dir", default=str(AUDIO_UZ))
    ap.add_argument("--scenes", action="store_true", help="print the per-scene table of every video")
    ap.add_argument("--json", help="write the per-video summary (+ scenes) as JSON to this file")
    ap.add_argument("--assemble", action="store_true", help="also build <audio-dir>/<id>.wav from --clips (real durations only)")
    ap.add_argument("--clips", help="folder with the natural per-line clips <id>.wav (synth_uz.py --natural -> <out-root>/<id>/uz/lines)")
    ap.add_argument("--no-loudnorm", action="store_true")
    a = ap.parse_args(argv)

    ids = VIDEOS if a.all else (a.video.split(",") if a.video else [])
    if not ids:
        ap.error("give --video ID[,ID] or --all")
    if a.lines and len(ids) != 1:
        ap.error("--lines needs exactly one --video")
    if a.assemble and (len(ids) != 1 or not a.clips):
        ap.error("--assemble needs exactly one --video and --clips")
    if not (a.dry_run or a.write or a.assemble):
        ap.error("choose --dry-run, --write and/or --assemble")
    results, kinds = [], {}
    for vid in ids:
        plan, sb = load_plan(vid), load_storyboard(vid)
        lf = Path(a.lines) if a.lines else Path(a.out_root) / vid / "uz" / "voice_uz_lines.json"
        if lf.exists():
            durs, kind = read_lines_file(lf, [l["id"] for l in plan["lines"]]), "real"
        elif a.lines or a.require_real:
            raise SystemExit("no real durations file: %s" % lf)
        else:
            durs, kind = estimate_durations(plan, a.rate, a.use_suggested), "estimated"
        res = retime(plan, sb, durs, max_tempo=a.max_tempo)
        results.append(res)
        kinds[vid] = kind
        if a.write:
            src = ("real Uzbek voice durations (%s)" % lf.name) if kind == "real" else \
                  "ESTIMATE: characters of the TTS-ready text / %g chars/s - no audio" % a.rate
            p = write_timing(res, Path(a.audio_dir), estimated=(kind == "estimated"),
                             rate=a.rate if kind == "estimated" else None, max_tempo=a.max_tempo, source=src)
            print("wrote %s (%s)" % (p.relative_to(REPO) if p.is_relative_to(REPO) else p, kind))
        if a.assemble:
            if kind != "real":
                raise SystemExit("--assemble needs REAL durations (a lines file); refusing to build a WAV from estimates")
            wavp = Path(a.audio_dir) / ("%s.wav" % vid)
            rep = assemble_wav(res, Path(a.clips), wavp, loudnorm=not a.no_loudnorm)
            ld = rep.get("loudness")
            print("assembled %s  %.2f s%s%s" % (wavp, rep["seconds"],
                  ("  %.1f LUFS / %.1f dBTP" % (ld["after"]["I"], ld["after"]["TP"])) if ld else "",
                  ("  WARN: " + "; ".join(rep["warnings"])) if rep["warnings"] else ""))
        if a.scenes:
            print(fmt_scenes(res))
    print(fmt_table(results))
    print("durations: %s" % ", ".join("%s=%s" % (k, v) for k, v in kinds.items()))
    if a.json:
        Path(a.json).write_text(json.dumps({"rate": a.rate, "max_tempo": a.max_tempo,
                                            "videos": [dict(summary_row(r), kind=kinds[r["videoId"]], scene_table=r["scenes"])
                                                       for r in results]}, ensure_ascii=False, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
