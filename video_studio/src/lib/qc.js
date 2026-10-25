// Quality-control video arithmetic (ILLUSTRATIVE control data only).
// Shared by the Remotion bundle and the Node scripts. The rule engine is a
// line-by-line port of the app's own lib/features/qc/qc_rules.dart
// (evaluateRuns / _check / _consecutive; Westgard JO et al., Clin Chem
// 1981;27:493–501; app decisions D-20, D-27):
//   z = (x − mean) / SD
//   1-2s warning; 1-3s, 2-2s (within run across levels, or one level across
//   two runs), R-4s (within run), 4-1s and 10x (one level, or across levels)
//   reject. A limit exactly at ±k SD is not a violation (z > k + 1e-9).
//   A rejected run's values are not used by later runs' rules (D-27).
// The walk test enters the SAME runs into the app and records the app's own
// verdicts; MATH_APPENDIX.md compares them.

import {fmt} from './text.js';

const EPS = 1e-9;
const over = (z, k) => z > k + EPS;
export const RULES = ['1-2s', '1-3s', '2-2s', 'R-4s', '4-1s', '10x'];
export const rejects = (r) => r !== '1-2s';

function consecutive(rule, count, limit, stream, runIndex, levels) {
  const out = [];
  const sameSide = (xs, sign) => xs.every((o) => over(o.z * sign, limit));
  for (const id of levels) {
    const mine = stream.filter((o) => o.level === id);
    if (mine.length < count || mine[mine.length - 1].run !== runIndex) continue;
    const win = mine.slice(mine.length - count);
    for (const sign of [1, -1]) if (sameSide(win, sign)) out.push({rule, levels: [id], across: true});
  }
  if (stream.length >= count && stream[stream.length - 1].run === runIndex) {
    const win = stream.slice(stream.length - count);
    const ids = [...new Set(win.map((o) => o.level))];
    if (ids.length >= 2) for (const sign of [1, -1]) if (sameSide(win, sign)) out.push({rule, levels: ids, across: true});
  }
  return out;
}

function check(runIndex, z, stream, levels) {
  const out = [];
  const ids = Object.keys(z);
  const b3 = ids.filter((id) => over(Math.abs(z[id]), 3));
  if (b3.length) out.push({rule: '1-3s', levels: b3});
  const b2 = ids.filter((id) => over(Math.abs(z[id]), 2));
  if (b2.length) out.push({rule: '1-2s', levels: b2});
  for (const sign of [1, -1]) {
    const within = ids.filter((id) => over(z[id] * sign, 2));
    if (within.length >= 2) out.push({rule: '2-2s', levels: within});
    for (const id of ids) {
      if (!over(z[id] * sign, 2)) continue;
      let prev = null;
      for (let i = stream.length - 1; i >= 0; i--) {
        if (stream[i].level === id && stream[i].run < runIndex) {
          prev = stream[i];
          break;
        }
      }
      if (prev && over(prev.z * sign, 2)) out.push({rule: '2-2s', levels: [id], across: true});
    }
  }
  const high = ids.filter((id) => over(z[id], 2));
  const low = ids.filter((id) => over(-z[id], 2));
  if (high.length && low.length) out.push({rule: 'R-4s', levels: [...high, ...low]});
  out.push(...consecutive('4-1s', 4, 1, stream, runIndex, levels));
  out.push(...consecutive('10x', 10, 0, stream, runIndex, levels));
  const merged = new Map();
  for (const v of out) {
    const m = merged.get(v.rule);
    merged.set(v.rule, m ? {rule: v.rule, levels: [...new Set([...m.levels, ...v.levels])], across: !!(m.across || v.across)} : v);
  }
  return RULES.filter((r) => merged.has(r)).map((r) => merged.get(r));
}

/** Same contract as the app's evaluateRuns: runs in time order. */
export function evaluateRuns(levels, runs) {
  const order = levels.map((l) => l.id);
  const stream = [];
  return runs.map((run, i) => {
    const z = {};
    for (const l of levels) if (run.values[l.id] != null) z[l.id] = (run.values[l.id] - l.mean) / l.sd;
    const before = stream.length;
    for (const id of order) if (z[id] != null) stream.push({run: i, level: id, z: z[id]});
    const violations = check(i, z, stream, order);
    const verdict = violations.some((v) => rejects(v.rule)) ? 'reject' : violations.length ? 'warning' : 'accept';
    if (verdict === 'reject') stream.splice(before, stream.length - before);
    return {index: i, z, violations, rules: violations.map((v) => v.rule), verdict};
  });
}

const round = (v, d) => Math.round(v * 10 ** d) / 10 ** d;

export function qcMath(d) {
  const levels = d.levels;
  // Runs are defined by their z-scores (readable design); values are what
  // the user would type: mean + z·SD, rounded to the level's decimals.
  const runs = d.runs.map((r, i) => ({
    n: i + 1,
    values: Object.fromEntries(levels.map((l, k) => [l.id, round(l.mean + r.z[k] * l.sd, l.decimals)])),
  }));
  const res = evaluateRuns(levels, runs);
  for (const [i, exp] of Object.entries(d.expect)) {
    const got = res[Number(i) - 1];
    const want = [...exp.rules].sort().join(',');
    if (got.verdict !== exp.verdict || [...got.rules].sort().join(',') !== want) {
      throw new Error(`qc: run ${i} gives ${got.verdict} [${got.rules}] but storyboard expects ${exp.verdict} [${exp.rules}]`);
    }
  }
  // Rule cards: each pattern must trigger exactly its rule (checked here).
  const cards = d.cards.map((c) => {
    const lv = c.levels.map((id) => levels.find((l) => l.id === id));
    const rr = c.runs.map((zs) => ({values: Object.fromEntries(lv.map((l, k) => [l.id, l.mean + zs[k] * l.sd]))}));
    const ev = evaluateRuns(lv, rr);
    const last = ev[ev.length - 1];
    if (!last.rules.includes(c.rule)) throw new Error(`qc: card ${c.rule} pattern does not trigger ${c.rule} (${last.rules})`);
    return {...c, result: last};
  });
  const hook = runs[d.hookRun - 1];
  const hookL = levels[0];
  // Observed statistics (accepted + warning runs only, as in the app: D-27).
  const stats = levels.map((l) => {
    const xs = runs.filter((_, i) => res[i].verdict !== 'reject').map((r) => r.values[l.id]);
    const n = xs.length;
    const mean = xs.reduce((a, b) => a + b, 0) / n;
    const sd = Math.sqrt(xs.reduce((a, b) => a + (b - mean) ** 2, 0) / (n - 1));
    return {id: l.id, n, mean, sd, cv: (100 * sd) / mean};
  });
  return {levels, runs, res, cards, hookRun: d.hookRun, hook: {x: hook.values[hookL.id], mean: hookL.mean, sd: hookL.sd, z: (hook.values[hookL.id] - hookL.mean) / hookL.sd}, shiftRun: d.shiftRun, stats};
}

export function qcVars(math, lang) {
  return {
    hookZ: fmt(math.hook.z, lang, 1),
    hookX: fmt(math.hook.x, lang, 2),
  };
}
