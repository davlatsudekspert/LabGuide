// Calculators overview video: no video-side arithmetic. Every result on
// screen is computed by the app itself in the filmed walk
// (flutter_walk/calculators_walk_test.dart); the hook shows the app's own
// eGFR formula text (lib/features/tools/calc_info.dart) with "= ?".
// egfrCheck() repeats the CKD-EPI 2021 arithmetic for the appendix only.

export function egfrCheck({creatinine, age, sex}) {
  const scr = creatinine / 88.4; // µmol/L -> mg/dL (the app: molar mass 113.12 g/mol, ≈ ÷ 88.4)
  const female = sex === 'female';
  const k = female ? 0.7 : 0.9;
  const a = female ? -0.241 : -0.302;
  const r = scr / k;
  return 142 * Math.min(r, 1) ** a * Math.max(r, 1) ** -1.2 * 0.9938 ** age * (female ? 1.012 : 1);
}

export function calcMath(d) {
  return {egfr: d.egfr, unitCheck: d.unitCheck, egfrValue: egfrCheck(d.egfr), paths: d.paths};
}

export function calcVars() {
  return {};
}
