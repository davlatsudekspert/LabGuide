// Subtitle cues from the timing manifest. The SAME cues are burned into the
// video (SubtitleTrack) and written to .srt/.vtt (scripts/subs.mjs), so the
// files and the picture never disagree.

const MAX_CUE_CHARS = 74; // <= 2 rows of ~37 chars in the 1080-wide vertical
const MAX_ROW_CHARS = 40;

/** Splits a narration line into cue-sized chunks at natural breaks. */
export function splitLine(text, maxChars = MAX_CUE_CHARS) {
  const t = text.trim();
  if ([...t].length <= maxChars) return [t];
  // Prefer sentence / clause breaks closest to the middle.
  const breaks = [];
  const re = /([.!?…:;]|\s[—–]|,)\s+/g;
  let m;
  while ((m = re.exec(t))) breaks.push(m.index + m[0].trimEnd().length);
  const mid = t.length / 2;
  let best = -1;
  for (const b of breaks) {
    if (b < 12 || t.length - b < 12) continue;
    if (best < 0 || Math.abs(b - mid) < Math.abs(best - mid)) best = b;
  }
  if (best < 0) {
    // Word break nearest the middle.
    for (let i = 0; i < t.length; i++) {
      if (t[i] === ' ' && (best < 0 || Math.abs(i - mid) < Math.abs(best - mid))) {
        best = i;
      }
    }
  }
  if (best < 0) return [t];
  const a = t.slice(0, best).trim();
  const b = t.slice(best).trim();
  return [...splitLine(a, maxChars), ...splitLine(b, maxChars)];
}

/** Balanced wrap into at most two rows (for .srt/.vtt line breaks). */
export function wrapRows(text, maxRow = MAX_ROW_CHARS) {
  if ([...text].length <= maxRow) return [text];
  const mid = text.length / 2;
  let best = -1;
  for (let i = 0; i < text.length; i++) {
    if (text[i] === ' ' && (best < 0 || Math.abs(i - mid) < Math.abs(best - mid))) {
      best = i;
    }
  }
  return best < 0 ? [text] : [text.slice(0, best), text.slice(best + 1)];
}

/**
 * @param {{id:string,start:number,end:number}[]} timingLines
 * @param {Record<string,string>} resolvedLines
 */
export function buildCues(timingLines, resolvedLines) {
  const cues = [];
  for (const l of timingLines) {
    const text = resolvedLines[l.id];
    if (text == null) continue;
    const parts = splitLine(text);
    const total = parts.reduce((a, p) => a + [...p].length, 0);
    let t = l.start;
    parts.forEach((p, i) => {
      const d = ((l.end - l.start) * [...p].length) / total;
      cues.push({
        lineId: l.id,
        index: i,
        start: t,
        end: i === parts.length - 1 ? l.end : t + d,
        text: p,
      });
      t += d;
    });
  }
  // Hold each cue on screen a little after the voice ends (up to HOLD s, never
  // into the next cue) so translated subtitles get more reading time.
  const HOLD = 0.9;
  for (let i = 0; i < cues.length; i++) {
    const next = cues[i + 1];
    const limit = next ? next.start - 0.04 : cues[i].end + HOLD;
    cues[i].end = Math.max(cues[i].end, Math.min(cues[i].end + HOLD, limit));
  }
  return cues;
}

function stamp(sec, sep) {
  const ms = Math.max(0, Math.round(sec * 1000));
  const h = Math.floor(ms / 3600000);
  const m = Math.floor((ms % 3600000) / 60000);
  const s = Math.floor((ms % 60000) / 1000);
  const r = ms % 1000;
  const p = (v, n = 2) => String(v).padStart(n, '0');
  return `${p(h)}:${p(m)}:${p(s)}${sep}${p(r, 3)}`;
}

export function toSrt(cues) {
  return (
    cues
      .map(
        (c, i) =>
          `${i + 1}\n${stamp(c.start, ',')} --> ${stamp(c.end, ',')}\n${wrapRows(c.text).join('\n')}\n`,
      )
      .join('\n') + '\n'
  );
}

export function toVtt(cues, lang) {
  return (
    `WEBVTT\nLanguage: ${lang}\n\n` +
    cues
      .map(
        (c) =>
          `${stamp(c.start, '.')} --> ${stamp(c.end, '.')}\n${wrapRows(c.text).join('\n')}\n`,
      )
      .join('\n')
  );
}
