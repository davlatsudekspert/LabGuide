// GC-MS video data (ILLUSTRATIVE SCHEMATIC PANELS only): a chromatogram of
// three made-up compounds (Gaussian peaks at illustrative retention times)
// and one made-up stick spectrum per peak. No compound, retention time, m/z
// value or intensity of a real substance is represented; the axes carry no
// numbers on screen (the lesson plan docs/video/lessons/01_gc_ms.md: "o‘qlarda
// raqam yo‘q"). Shared by Remotion and the Node scripts.

/** Detector signal at time t: baseline + Gaussian peaks. */
export function chromAt(t, peaks, baseline = 0.02) {
  let v = baseline * (1 + 0.25 * Math.sin(t * 7.3) * Math.sin(t * 1.9));
  for (const p of peaks) v += p.h * Math.exp(-0.5 * ((t - p.rt) / p.w) ** 2);
  return v;
}

export function gcmsMath(d) {
  const n = 360;
  const chrom = [];
  for (let k = 0; k <= n; k++) {
    const t = (d.tMax * k) / n;
    chrom.push([t, chromAt(t, d.peaks)]);
  }
  const spectra = d.peaks.map((p) => {
    const max = Math.max(...p.spectrum.map((s) => s[1]));
    return p.spectrum.map(([mz, i]) => ({x: mz, y: (100 * i) / max}));
  });
  const apex = d.peaks.map((p) => chromAt(p.rt, d.peaks));
  return {peaks: d.peaks, tMax: d.tMax, chrom, spectra, apex, mzMax: d.mzMax, selected: d.selected, paths: d.paths};
}

export function gcmsVars() {
  return {};
}
