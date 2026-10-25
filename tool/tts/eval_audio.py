#!/usr/bin/env python3
"""Objective checks for synthesized narration (NOT a naturalness / pleasantness test).

    python3 tool/tts/eval_audio.py OUT_DIR [--asr tiny --asr-lang en] [--json report.json]

OUT_DIR is a directory written by synth.py (manifest.json + <id>.wav). Per line it reports:
duration, sample rate, peak dBFS, clipped-sample ratio, RMS dBFS, integrated LUFS (ffmpeg ebur128),
silence ratio (20 ms frames below -50 dBFS), longest internal pause, and - optionally - an ASR round
trip (faster-whisper) with WER and CER against the *spoken* text (numbers expanded by synth.py).

What this cannot tell you: whether the voice sounds natural, pleasant, correctly stressed or
correctly accented. A native listener must judge that. ASR errors partly reflect the ASR model.
"""
from __future__ import annotations

import argparse
import json
import math
import re
import shutil
import subprocess
import sys
import unicodedata
import wave
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import synth  # noqa: E402


def read_wav(path: Path):
    import numpy as np  # type: ignore
    with wave.open(str(path), "rb") as w:
        sr, n, ch = w.getframerate(), w.getnframes(), w.getnchannels()
        x = np.frombuffer(w.readframes(n), dtype="<i2").astype("float64") / 32768.0
    if ch > 1:
        x = x.reshape(-1, ch).mean(axis=1)
    return x, sr


def dbfs(v: float) -> float:
    return round(20 * math.log10(v), 2) if v > 1e-9 else -120.0


def lufs(path: Path):
    if not shutil.which("ffmpeg"):
        return None
    p = subprocess.run(["ffmpeg", "-nostats", "-i", str(path), "-af", "ebur128=peak=true", "-f", "null", "-"],
                       capture_output=True, text=True)
    tail = p.stderr.split("Summary:")[-1]
    m = re.search(r"I:\s+(-?[\d.]+) LUFS", tail)
    lra = re.search(r"LRA:\s+(-?[\d.]+) LU", tail)
    return (float(m.group(1)) if m else None, float(lra.group(1)) if lra else None)


def audio_metrics(path: Path) -> dict:
    import numpy as np  # type: ignore
    x, sr = read_wav(path)
    dur = len(x) / sr
    peak = float(np.max(np.abs(x))) if len(x) else 0.0
    rms = float(np.sqrt(np.mean(x ** 2))) if len(x) else 0.0
    clipped = float(np.mean(np.abs(x) >= 0.999)) if len(x) else 0.0
    hop = int(sr * 0.02)
    frames = len(x) // hop
    fr = x[: frames * hop].reshape(frames, hop) if frames else np.zeros((0, hop))
    frms = np.sqrt(np.mean(fr ** 2, axis=1)) if frames else np.zeros(0)
    silent = frms < 10 ** (-50 / 20)
    voiced = np.where(~silent)[0]
    lead = (voiced[0] * 0.02) if len(voiced) else dur
    trail = ((frames - 1 - voiced[-1]) * 0.02) if len(voiced) else dur
    longest, run = 0, 0
    if len(voiced):
        for s in silent[voiced[0]: voiced[-1] + 1]:
            run = run + 1 if s else 0
            longest = max(longest, run)
    lf = lufs(path)
    return {
        "duration_s": round(dur, 3), "sample_rate": sr,
        "peak_dbfs": dbfs(peak), "rms_dbfs": dbfs(rms), "clipped_ratio": round(clipped, 6),
        "lufs_integrated": lf[0] if lf else None, "lra": lf[1] if lf else None,
        "silence_ratio": round(float(np.mean(silent)), 4) if frames else 1.0,
        "lead_silence_s": round(float(lead), 2), "trail_silence_s": round(float(trail), 2),
        "longest_internal_pause_s": round(longest * 0.02, 2),
    }


# ---- WER / CER -------------------------------------------------------------------------------

def norm_for_asr(text: str, lang: str) -> str:
    t = unicodedata.normalize("NFC", text).lower()
    t = t.replace("‘", "'").replace("’", "'").replace("ʻ", "'").replace("ё", "е")
    t = re.sub(r"\d+", lambda m: " " + synth.int_to_words(int(m.group()), lang) + " ", t)
    t = t.replace("-", " ")
    t = re.sub(r"[^\w\s']", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def edit_distance(a, b) -> int:
    prev = list(range(len(b) + 1))
    for i, x in enumerate(a, 1):
        cur = [i]
        for j, y in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (x != y)))
        prev = cur
    return prev[-1]


def wer_cer(ref: str, hyp: str, lang: str) -> dict:
    r, h = norm_for_asr(ref, lang), norm_for_asr(hyp, lang)
    rw, hw = r.split(), h.split()
    return {"wer": round(edit_distance(rw, hw) / max(1, len(rw)), 3),
            "cer": round(edit_distance(r.replace(" ", ""), h.replace(" ", "")) / max(1, len(r.replace(" ", ""))), 3),
            "ref_norm": r, "hyp_norm": h}


def load_16k(path: Path):
    """float32 mono 16 kHz (linear resampling is fine for ASR) - lets us skip PyAV/ffmpeg decoding."""
    import numpy as np  # type: ignore
    x, sr = read_wav(path)
    if sr != 16000:
        n = int(len(x) * 16000 / sr)
        x = np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x)
    return x.astype("float32")


def asr_transcribe(model, path: Path, lang: str) -> str:
    segs, _ = model.transcribe(load_16k(path), language=lang, beam_size=5, vad_filter=False,
                               condition_on_previous_text=False)
    return " ".join(s.text.strip() for s in segs)


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("out_dir")
    ap.add_argument("--asr", help="faster-whisper model name or local dir (e.g. tiny); omit to skip ASR")
    ap.add_argument("--asr-download-root", help="where faster-whisper keeps models")
    ap.add_argument("--json", help="write report JSON here")
    a = ap.parse_args(argv)
    d = Path(a.out_dir)
    man = json.loads((d / "manifest.json").read_text(encoding="utf-8"))
    lang = man["lang"]
    model = None
    if a.asr:
        try:
            import av  # type: ignore  # noqa: F401
        except ImportError:  # PyAV (~130 MB) is only used for file decoding; we pass numpy arrays
            import types
            sys.modules["av"] = types.ModuleType("av")
        from faster_whisper import WhisperModel  # type: ignore
        model = WhisperModel(a.asr, device="cpu", compute_type="int8", download_root=a.asr_download_root)
    rows = []
    for ln in man["lines"]:
        m = audio_metrics(d / ln["file"])
        m["id"] = ln["id"]
        if model:
            hyp = asr_transcribe(model, d / ln["file"], lang)
            m["asr_text"] = hyp
            m.update(wer_cer(ln["spoken_text"], hyp, lang))
        rows.append(m)
    agg = {"lines": len(rows), "backend": man["backend"], "voice": man.get("voice"), "lang": lang,
           "asr_model": a.asr or "NOT RUN"}
    if model:
        agg["mean_wer"] = round(sum(r["wer"] for r in rows) / len(rows), 3)
        agg["mean_cer"] = round(sum(r["cer"] for r in rows) / len(rows), 3)
    rep = {"summary": agg, "per_line": rows,
           "caveat": "Objective signal checks only. Naturalness/pleasantness/accent NOT measured."}
    text = json.dumps(rep, ensure_ascii=False, indent=2)
    if a.json:
        Path(a.json).write_text(text + "\n", encoding="utf-8")
    print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
