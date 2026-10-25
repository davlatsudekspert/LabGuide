// Ordinary least-squares straight line y = intercept + slope * x, plus the
// statistics the videos show. Plain ES module (no dependencies) so the same
// code runs inside the Remotion bundle (on-screen numbers) and in Node
// (scripts/math.mjs -> docs math appendix). Nothing shown on screen is typed
// in: every number comes from these functions.

/**
 * @param {number[]} xs
 * @param {number[]} ys
 */
export function linearFit(xs, ys) {
  if (xs.length !== ys.length || xs.length < 3) {
    throw new Error('linearFit: need >= 3 paired points');
  }
  const n = xs.length;
  const meanX = xs.reduce((a, b) => a + b, 0) / n;
  const meanY = ys.reduce((a, b) => a + b, 0) / n;
  let sxx = 0;
  let sxy = 0;
  let syy = 0;
  for (let i = 0; i < n; i++) {
    const dx = xs[i] - meanX;
    const dy = ys[i] - meanY;
    sxx += dx * dx;
    sxy += dx * dy;
    syy += dy * dy;
  }
  const slope = sxy / sxx;
  const intercept = meanY - slope * meanX;
  const fitted = xs.map((x) => intercept + slope * x);
  const residuals = ys.map((y, i) => y - fitted[i]);
  const ssRes = residuals.reduce((a, r) => a + r * r, 0);
  const ssTot = syy;
  const r2 = 1 - ssRes / ssTot;
  // Residual standard deviation s(y|x) with n - 2 degrees of freedom.
  const sYX = Math.sqrt(ssRes / (n - 2));
  return {
    n,
    meanX,
    meanY,
    sxx,
    sxy,
    syy,
    slope,
    intercept,
    fitted,
    residuals,
    ssRes,
    ssTot,
    r2,
    sYX,
  };
}

/** Concentration read off the line for a measured signal (inverse prediction). */
export function readOff(fit, y) {
  return (y - fit.intercept) / fit.slope;
}

/**
 * All numbers for a calibration storyboard `data` block.
 * @param {{calibrators: {id:string, conc:number, abs:number}[], controls: {id:string, target:number, abs:number}[], hookControl?: string}} data
 */
export function calibrationMath(data) {
  const xs = data.calibrators.map((c) => c.conc);
  const ys = data.calibrators.map((c) => c.abs);
  const fit = linearFit(xs, ys);
  const calibrators = data.calibrators.map((c, i) => ({
    ...c,
    fitted: fit.fitted[i],
    residual: fit.residuals[i],
  }));
  const controls = data.controls.map((q) => {
    const conc = readOff(fit, q.abs);
    return { ...q, conc, pctOfTarget: (conc / q.target) * 100 };
  });
  const hook =
    controls.find((q) => q.id === data.hookControl) ??
    controls[controls.length - 1];
  const maxAbsResidual = Math.max(...fit.residuals.map((r) => Math.abs(r)));
  const signs = fit.residuals.map((r) => (r > 0 ? '+' : r < 0 ? '-' : '0'));
  return { fit, calibrators, controls, hook, maxAbsResidual, signs };
}
