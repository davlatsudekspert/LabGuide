#!/usr/bin/env python3
"""Swap the audio track of ALREADY RENDERED MP4s for the Uzbek voice, without re-rendering anything.

    python3 tool/tts/remux_uz.py --video overview                  # -> video_studio/out/overview/uz/uzvoice/*.mp4
    python3 tool/tts/remux_uz.py --video overview --dry-run        # print the ffmpeg commands only
    python3 tool/tts/remux_uz.py --video qc --lang uz --wav /path/voice_uz.wav --inplace

Why this is enough: the Remotion compositions contain NO audio. video_studio/scripts/render.mjs pipes the frames into
ffmpeg and muxes public/audio/en/<id>.wav (the English narration, AAC 160 kbit/s, 48 kHz) at render time;
video_studio/scripts/remux.mjs already replaces that track with `-c:v copy`. This script does the same with the Uzbek
WAV (out/<id>/uz/voice_uz.wav from synth_uz.py). The video stream - including the burned-in Uzbek subtitles - is copied
bit for bit. Refuses when the WAV length differs from the MP4 length by more than 0.06 s (the voice must stay on the
English timeline; synth_uz.py guarantees that length).
Default output goes to a sibling folder `uzvoice/`, originals stay untouched; --inplace replaces them.
Only the Uzbek edition (out/<id>/uz/) is meant to get the Uzbek voice; ru and en editions keep the English voice.
"""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
DEFAULT_ROOT = REPO / "video_studio" / "out"
TOLERANCE_S = 0.06


def probe_duration(path: Path) -> float:
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
                         capture_output=True, text=True, check=True).stdout.strip()
    return float(out)


def mux_command(mp4: Path, wav: Path, out: Path, duration: float) -> list[str]:
    return ["ffmpeg", "-y", "-loglevel", "error", "-i", str(mp4), "-i", str(wav), "-map", "0:v:0", "-c:v", "copy",
            "-map", "1:a:0", "-c:a", "aac", "-b:a", "160k", "-ar", "48000", "-t", "%.3f" % duration,
            "-movflags", "+faststart", str(out)]


def editions(root: Path, video: str, lang: str) -> list[Path]:
    d = root / video / lang
    return sorted(p for p in d.glob("%s_%s_*.mp4" % (video, lang))
                  if not re.search(r"_f\d+-\d+$|\.remux|\.splice|\.uzvoice", p.stem))


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--video", required=True)
    ap.add_argument("--lang", default="uz")
    ap.add_argument("--root", default=str(DEFAULT_ROOT), help="folder holding <id>/<lang>/*.mp4 (default video_studio/out)")
    ap.add_argument("--wav", help="default <root>/<id>/uz/voice_uz.wav")
    ap.add_argument("--inplace", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args(argv)
    root = Path(a.root)
    wav = Path(a.wav) if a.wav else root / a.video / "uz" / "voice_uz.wav"
    mp4s = editions(root, a.video, a.lang)
    if not mp4s:
        print("no rendered MP4s found in %s" % (root / a.video / a.lang), file=sys.stderr)
        return 2
    if not a.dry_run and (not wav.exists() or not shutil.which("ffmpeg")):
        print("need %s and ffmpeg" % wav, file=sys.stderr)
        return 2
    wav_s = probe_duration(wav) if (wav.exists() and shutil.which("ffprobe")) else None
    for mp4 in mp4s:
        try:
            dur = probe_duration(mp4)
        except (subprocess.CalledProcessError, FileNotFoundError):
            if not a.dry_run:
                raise
            dur = None
        out = mp4.with_suffix(".uzvoice.tmp.mp4") if a.inplace else mp4.parent / "uzvoice" / mp4.name
        cmd = mux_command(mp4, wav, out, dur if dur is not None else 0.0)
        if a.dry_run:
            print(" ".join(cmd))
            continue
        if abs(dur - wav_s) > TOLERANCE_S:
            print("%s: video %.3f s vs voice %.3f s - refusing (re-run synth_uz.py; the voice must match the English timeline)"
                  % (mp4.name, dur, wav_s), file=sys.stderr)
            return 3
        out.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(cmd, check=True)
        if a.inplace:
            out.replace(mp4)
            out = mp4
        print("remuxed %s -> %s" % (mp4.name, out))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
