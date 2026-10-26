// Real-time PCR video arithmetic (ILLUSTRATIVE curves only). Shared by the
// Remotion bundle and the Node scripts.
//   amplification curve (illustrative logistic):
//     F(c) = base + top / (1 + exp(−(c − mid) / slope))
//   Cq = the cycle at which F crosses the threshold (solved exactly):
//     c = mid − slope · ln(top / (T − base) − 1)
//   doubling per cycle (idealised): copies(n) = copies(0) · 2^n
// The app's card text: "the key readout is the quantification cycle (Cq) at
// which fluorescence crosses a threshold; a lower Cq means more starting
// target". No real assay, threshold setting or efficiency is implied.
import {fmt} from './text.js';

export function curveAt(c, s, base) {
  if (s.flat) return base + s.drift * c;
  return base + s.top / (1 + Math.exp(-(c - s.mid) / s.slope));
}

export function cqOf(s, base, threshold) {
  if (s.flat) return null;
  if (threshold <= base || threshold >= base + s.top) return null;
  return s.mid - s.slope * Math.log(s.top / (threshold - base) - 1);
}

export function qpcrMath(d) {
  const samples = d.samples.map((s) => {
    const pts = [];
    for (let c = 0; c <= d.cycles; c += 0.25) pts.push([c, curveAt(c, s, d.base)]);
    const cq = cqOf(s, d.base, d.threshold);
    return {...s, pts, cq, maxF: curveAt(d.cycles, s, d.base)};
  });
  const doubling = Array.from({length: d.doublingSteps + 1}, (_, n) => ({n, copies: 2 ** n}));
  return {samples, threshold: d.threshold, base: d.base, cycles: d.cycles, doubling, paths: d.paths};
}

export function qpcrVars(math, lang) {
  const [a, b] = math.samples;
  return {cqA: fmt(a.cq, lang, 1), cqB: fmt(b.cq, lang, 1), cqA0: fmt(a.cq, lang, 0), cqB0: fmt(b.cq, lang, 0)};
}
