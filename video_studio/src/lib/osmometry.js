// Osmometry video arithmetic (ILLUSTRATIVE freezing curves only). Shared by
// the Remotion bundle and the Node scripts. Temperature is in arbitrary units
// with the freezing point of pure water at 0; NO number is drawn on the
// axes (lesson plan docs/video/lessons/24_osmometer.md: "raqamsiz").
//   cooling (Newton):      T(t) = Tb + (T0 − Tb)·e^(−t/τ)            t < ts
//   supercooled minimum:   ts = −τ·ln((Tsup − Tb)/(T0 − Tb))   (T(ts) = Tsup)
//   seeding → plateau:     T(t) = Tf − (Tf − Tsup)·e^(−(t − ts)/τr) − k·max(0, t − tp)²
//                          tp = ts + plateau
//   depression:            ΔT = Twater − Tf   (more dissolved particles → larger ΔT)
// The app's schematic principle (schemPartsOsmometerPrinciple) describes the
// same sequence: supercooling in the cooling block, stirring-wire vibration
// starts freezing, latent heat raises the temperature to a plateau.
//
// Calculated osmolality is NOT computed here: the app's calculator computes
// it on the filmed screen (2·Na + glucose + urea in mmol/L; gap = measured −
// calculated); calcCheck() repeats that arithmetic only for the appendix.

export function seedTime(p, s) {
  return -p.tau * Math.log((s.tsup - p.tb) / (p.t0 - p.tb));
}

export function tempAt(t, p, s) {
  const ts = seedTime(p, s);
  if (t < ts) return p.tb + (p.t0 - p.tb) * Math.exp(-t / p.tau);
  const tp = ts + p.plateau;
  return s.tf - (s.tf - s.tsup) * Math.exp(-(t - ts) / p.tauR) - p.k * Math.max(0, t - tp) ** 2;
}

export function osmoMath(d) {
  const p = d.curve;
  const samples = d.samples.map((s) => {
    const pts = [];
    for (let t = 0; t <= p.tMax + 1e-9; t += p.tMax / 480) pts.push([t, tempAt(t, p, s)]);
    const ts = seedTime(p, s);
    return {...s, pts, ts, tp: ts + p.plateau, depression: p.water - s.tf};
  });
  return {samples, curve: p, water: p.water, calc: d.calc, paths: d.paths};
}

/** The calculator's arithmetic for the filmed inputs (appendix only). */
export function calcCheck(c) {
  const calculated = 2 * c.sodium + c.glucose + c.urea;
  return {calculated, gap: c.measured - calculated};
}

export function osmoVars() {
  return {};
}
