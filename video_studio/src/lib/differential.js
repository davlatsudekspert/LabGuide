// Leukocyte differential arithmetic for the video (ILLUSTRATIVE tally only).
// Shared by the Remotion bundle and the Node scripts (docs, subtitles).
// Same definitions as the app (lib/features/differential/differential_controller.dart):
//   percent(c)  = count(c) * 100 / total
//   absolute(c) = count(c) / total * WBC            (×10⁹/L, only when WBC is given)
// Nothing here is a reference interval or an interpretation.

import {fmt} from './text.js';

export const CLASSES = ['segmented', 'band', 'lymphocyte', 'monocyte', 'eosinophil', 'basophil', 'other'];

/** Tally of the first n cells of the sequence. */
export function tallyAt(sequence, n) {
  const out = Object.fromEntries(CLASSES.map((c) => [c, 0]));
  for (let i = 0; i < Math.min(n, sequence.length); i++) out[sequence[i]] += 1;
  return out;
}

export function differentialMath(data) {
  const seq = data.sequence;
  for (const c of seq) if (!CLASSES.includes(c)) throw new Error(`unknown cell class ${c}`);
  const total = seq.length;
  if (total !== data.target) throw new Error(`sequence has ${total} cells, target is ${data.target}`);
  const counts = tallyAt(seq, total);
  for (const c of CLASSES) {
    if ((data.counts[c] ?? 0) !== counts[c]) {
      throw new Error(`declared count ${c}=${data.counts[c]} != sequence ${counts[c]}`);
    }
  }
  const wbc = data.wbc;
  const rows = CLASSES.map((c) => ({
    cell: c,
    count: counts[c],
    percent: (counts[c] * 100) / total,
    fraction: counts[c] / total,
    absolute: wbc == null ? null : (counts[c] / total) * wbc,
  }));
  const pctSum = rows.reduce((a, r) => a + r.percent, 0);
  const absSum = rows.reduce((a, r) => a + (r.absolute ?? 0), 0);
  const neutrophilsAbs = wbc == null ? null : ((counts.segmented + counts.band) / total) * wbc;
  return {
    total,
    target: data.target,
    wbc,
    counts,
    rows,
    pctSum,
    absSum,
    neutrophilsAbs,
    sequence: seq,
    firstTaps: data.firstTaps,
    midAt: data.midAt,
    mid: tallyAt(seq, data.midAt),
    hook: data.hook,
  };
}

/** Like the app's formatResult(maxDecimals): up to d decimals, trailing zeros dropped. */
export function fmtMax(value, lang, d) {
  let s = Math.abs(value).toFixed(d);
  if (s.includes('.')) s = s.replace(/0+$/, '').replace(/\.$/, '');
  if (lang !== 'en') s = s.replace('.', ',');
  return value < 0 && Number(s.replace(',', '.')) !== 0 ? `−${s}` : s;
}

/** Template variables for the lines (locale formatting as in the app). */
export function differentialVars(math, lang) {
  return {
    total: math.total,
    target: math.target,
    wbc: fmt(math.wbc, lang, 1),
    hookA: math.hook.a,
    hookB: math.hook.b,
  };
}
