// Spectrophotometry video arithmetic (ILLUSTRATIVE numbers only, arbitrary
// units). Shared by the Remotion bundle and the Node scripts (docs,
// subtitles). Definitions follow the app's own photometry diagram text
// (ARB imgDiagramPhotometryAlt) and the lecture protocol
// "fotometriya-asoslari-biokimyo":
//   A = log10(I0 / I)            T = I / I0 = 10^-A
//   C = (A sample / A standard) x C standard          (blank-corrected A)
//   above the linearity limit: dilute, repeat, multiply by the dilution factor
// The response curve beyond the linear range is an ILLUSTRATIVE textbook
// shape (negative deviation), not a property of any real method: the real
// linearity limit comes from the reagent IFU.
import {fmt} from './text.js';

/** Illustrative detector response: linear (k*c) up to `limit`, then bending. */
export function response(c, d) {
  const k = d.standard.abs / d.standard.conc;
  if (c <= d.linearity.limit) return k * c;
  const s = d.linearity.bend;
  return k * d.linearity.limit + k * s * (1 - Math.exp(-(c - d.linearity.limit) / s));
}

export function photometryMath(d) {
  const std = d.standard;
  const k = std.abs / std.conc;
  const sampleConc = (d.sample.abs / std.abs) * std.conc;
  // The "high" sample: its (hidden, illustrative) concentration gives the
  // reading through the bending response; read directly it comes out low.
  const highAbs = response(d.high.trueConc, d);
  const highDirect = (Number(highAbs.toFixed(3)) / std.abs) * std.conc;
  const f = d.high.dilutionFactor;
  const dilAbs = Number(response(d.high.trueConc / f, d).toFixed(3));
  const dilConc = (dilAbs / std.abs) * std.conc;
  const highResult = dilConc * f;
  const ladder = d.ladder.map((A) => ({A, T: Math.pow(10, -A), pct: 100 * Math.pow(10, -A)}));
  const curve = [];
  for (let c = 0; c <= d.chart.xMax + 1e-9; c += d.chart.xMax / 120) curve.push([c, response(c, d)]);
  const line = [
    [0, 0],
    [d.chart.xMax, k * d.chart.xMax],
  ];
  return {
    k,
    standard: std,
    sample: {...d.sample, conc: sampleConc},
    high: {
      trueConc: d.high.trueConc,
      abs: Number(highAbs.toFixed(3)),
      direct: highDirect,
      factor: f,
      dilAbs,
      dilConc,
      result: highResult,
    },
    limit: d.linearity.limit,
    limitAbs: k * d.linearity.limit,
    ladder,
    curve,
    line,
    chart: d.chart,
  };
}

/** Template variables for the lines (locale number format as in the app). */
export function photometryVars(math, lang) {
  return {
    hookA: fmt(math.high.abs, lang, 2),
    stdA: fmt(math.standard.abs, lang, 3),
    stdC: fmt(math.standard.conc, lang, 1),
    smpA: fmt(math.sample.abs, lang, 3),
    smpC: fmt(math.sample.conc, lang, 2),
    factor: math.high.factor,
  };
}
