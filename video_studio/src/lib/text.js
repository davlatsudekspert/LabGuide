// Locale-aware number formatting and {placeholder} templates, shared by the
// Remotion bundle and the Node scripts (subtitles, docs).

/** Decimal comma for ru/uz (as in the app), point for en; true minus sign. */
export function fmt(value, lang, digits) {
  const s = Math.abs(value).toFixed(digits);
  const local = lang === 'en' ? s : s.replace('.', ',');
  const isZero = Number(s) === 0;
  return value < 0 && !isZero ? `−${local}` : local;
}

/** Signed value with explicit + / − (residuals). */
export function fmtSigned(value, lang, digits) {
  const body = fmt(Math.abs(value), lang, digits);
  if (Number(Math.abs(value).toFixed(digits)) === 0) return body;
  return `${value < 0 ? '−' : '+'}${body}`;
}

/** Replaces {name} with vars[name]; unknown names are left visible. */
export function fill(template, vars) {
  return template.replace(/\{([A-Za-z0-9_]+)\}/g, (m, k) =>
    k in vars ? String(vars[k]) : m,
  );
}

/** Template variables for the calibration video, computed from the math. */
export function calibrationVars(math, lang) {
  const h = math.hook;
  return {
    n: math.fit.n,
    slope: fmt(math.fit.slope, lang, 4),
    intercept: fmt(math.fit.intercept, lang, 4),
    r2: fmt(math.fit.r2, lang, 4),
    qcHighA: fmt(h.abs, lang, 3),
    qcHighX: fmt(h.conc, lang, 2),
    qcHighT: fmt(h.target, lang, 1),
    qcHighPct: fmt(h.pctOfTarget, lang, 1),
  };
}

/** Resolved narration lines {id: text} for one language. */
export function resolveLines(pack, vars) {
  const out = {};
  for (const [id, t] of Object.entries(pack.lines)) out[id] = fill(t, vars);
  return out;
}
