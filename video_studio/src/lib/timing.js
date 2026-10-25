// Timing = narration timing manifest (per language). Source of truth for
// scene boundaries and subtitles. Shared by Remotion and Node scripts.
//
// Manifest format (compatible with a TTS synth that writes one WAV per
// video+language): { "videoId", "lang", "source", "lines": [{id,start,end}] }
// seconds from the start of the WAV. A bare array of {id,start,end} and
// {startMs,endMs} are accepted too.

/** Estimated reading/speaking time for one line (silent placeholder). */
export function estimateLineSec(text, lang, cfg) {
  const cps = cfg.cps?.[lang] ?? 15;
  const chars = [...text].length;
  return Math.max(cfg.minLineSec ?? 1.5, chars / cps);
}

/**
 * Schedule lines scene by scene. Without `durations` the line lengths are
 * estimated (silent placeholder); with `durations` ({id: seconds}, e.g. from
 * the TTS manifest) the same layout rules place the REAL voice clips.
 */
export function placeholderTiming(storyboard, resolvedLines, lang, durations = null) {
  const cfg = storyboard.timing;
  const lines = [];
  let cursor = 0;
  for (const sc of storyboard.scenes) {
    const start = cursor;
    let t = start + cfg.leadSec;
    sc.lines.forEach((id, i) => {
      const text = resolvedLines[id];
      if (text == null) throw new Error(`missing line ${id} (${lang})`);
      if (i > 0) t += cfg.gapSec;
      const d = durations?.[id] ?? estimateLineSec(text, lang, cfg);
      lines.push({ id, start: round(t), end: round(t + d) });
      t += d;
    });
    cursor = Math.max(start + sc.minSec, t + cfg.tailSec);
  }
  return {
    videoId: storyboard.id,
    lang,
    source: durations ? 'scheduled-voice' : 'placeholder-estimate (no voice)',
    totalSec: round(cursor),
    lines,
  };
}

/** Accepts the manifest variants and returns [{id,start,end}] (seconds). */
export function normalizeTiming(raw) {
  const arr = Array.isArray(raw) ? raw : raw?.lines ?? raw?.segments;
  if (!Array.isArray(arr)) throw new Error('timing: no lines array');
  return arr.map((l) => ({
    id: String(l.id),
    start: l.start ?? l.startMs / 1000,
    end: l.end ?? l.endMs / 1000,
  }));
}

/**
 * Scene boundaries from line times. Scene k starts leadSec before its first
 * line (scene 0 starts at 0) and ends where scene k+1 starts; the last scene
 * ends tailSec after its last line, but never shorter than its minSec (from
 * the placeholder the same boundaries come back exactly).
 */
export function layoutScenes(storyboard, timing, fps) {
  const cfg = storyboard.timing;
  const lines = normalizeTiming(timing);
  const byId = new Map(lines.map((l) => [l.id, l]));
  for (const sc of storyboard.scenes) {
    for (const id of sc.lines) {
      if (!byId.has(id)) throw new Error(`timing: line ${id} missing`);
    }
  }
  const scenes = storyboard.scenes;
  const starts = scenes.map((sc, k) => {
    if (k === 0) return 0;
    const first = byId.get(sc.lines[0]);
    const prev = scenes[k - 1];
    const prevEnd = byId.get(prev.lines[prev.lines.length - 1]).end;
    return Math.max(prevEnd + 0.05, first.start - cfg.leadSec);
  });
  const last = scenes[scenes.length - 1];
  const lastEnd = byId.get(last.lines[last.lines.length - 1]).end;
  const totalSec = Math.max(
    lastEnd + cfg.tailSec,
    starts[starts.length - 1] + last.minSec,
    timing.totalSec ?? timing.total_duration ?? 0,
  );
  const out = scenes.map((sc, k) => {
    const startSec = starts[k];
    const endSec = k + 1 < scenes.length ? starts[k + 1] : totalSec;
    const from = Math.round(startSec * fps);
    const to = Math.round(endSec * fps);
    return {
      ...sc,
      index: k,
      startSec,
      endSec,
      from,
      durationInFrames: Math.max(1, to - from),
      cues: sc.lines.map((id) => {
        const l = byId.get(id);
        return { id, start: l.start - startSec, end: l.end - startSec };
      }),
    };
  });
  return {
    scenes: out,
    totalSec,
    durationInFrames: Math.round(totalSec * fps),
    lines,
  };
}

function round(v) {
  return Math.round(v * 1000) / 1000;
}
