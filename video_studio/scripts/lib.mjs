// Shared Node helpers for the studio scripts (bundle, props, timing, subs).
import {execFileSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {calibrationMath} from '../src/lib/regression.js';
import {differentialMath, differentialVars} from '../src/lib/differential.js';
import {photometryMath, photometryVars} from '../src/lib/photometry.js';
import {qcMath, qcVars} from '../src/lib/qc.js';
import {gcmsMath, gcmsVars} from '../src/lib/gcms.js';
import {buildCues, toSrt, toVtt} from '../src/lib/subtitles.js';
import {calibrationVars, resolveLines} from '../src/lib/text.js';
import {layoutScenes, normalizeTiming, placeholderTiming} from '../src/lib/timing.js';

export const studio = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
export const repo = path.resolve(studio, '..');
export const BROWSER =
  process.env.REMOTION_BROWSER ?? '/opt/pw-browsers/chromium_headless_shell-1194/chrome-linux/headless_shell';
export const LANGS = ['en', 'ru', 'uz'];
export const FORMATS = ['vertical', 'horizontal'];
/** Owner decision 2026-10-25: English narration for every edition. */
export const NARRATION_LANG = 'en';

/** Per-video adapters (math + template vars). Add new videos here. */
const VIDEO_MATH = {
  calibration: {compute: (sb) => calibrationMath(sb.data), vars: calibrationVars},
  leukocyte: {compute: (sb) => differentialMath(sb.data), vars: differentialVars},
  photometry: {compute: (sb) => photometryMath(sb.data), vars: photometryVars},
  qc: {compute: (sb) => qcMath(sb.data), vars: qcVars},
  gcms: {compute: (sb) => gcmsMath(sb.data), vars: gcmsVars},
};

export function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (!a.startsWith('--')) continue;
    const k = a.slice(2);
    const v = argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[++i] : true;
    out[k] = v;
  }
  return out;
}

export function readJson(p) {
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

export function videoData(id) {
  const dir = path.join(repo, 'docs/video', id);
  const storyboard = readJson(path.join(dir, 'storyboard.json'));
  const packs = Object.fromEntries(LANGS.map((l) => [l, readJson(path.join(dir, `lines.${l}.json`))]));
  const adapter = VIDEO_MATH[id];
  if (!adapter) throw new Error(`no math adapter for video ${id} (scripts/lib.mjs)`);
  const math = adapter.compute(storyboard);
  const lines = Object.fromEntries(LANGS.map((l) => [l, resolveLines(packs[l], adapter.vars(math, l))]));
  return {dir, storyboard, packs, math, lines};
}

/** Voice track (if any): public/audio/<narrationLang>/<id>.wav + .timing.json */
export function voice(id) {
  const base = path.join(studio, 'public/audio', NARRATION_LANG);
  const wav = path.join(base, `${id}.wav`);
  const timingFile = path.join(base, `${id}.timing.json`);
  if (fs.existsSync(timingFile)) {
    const timing = readJson(timingFile);
    return {timing, timingFile, wav: fs.existsSync(wav) ? wav : null};
  }
  return {timing: null, timingFile: null, wav: null};
}

export function effectiveTiming(id) {
  const {storyboard, lines} = videoData(id);
  const v = voice(id);
  const timing = v.timing ?? placeholderTiming(storyboard, lines[NARRATION_LANG], NARRATION_LANG);
  const layout = layoutScenes(storyboard, timing, storyboard.fps);
  return {timing, layout, voiced: !!v.timing, wav: v.wav};
}

export function appFrames(id, lang) {
  const f = path.join(studio, 'public/frames', lang, id, 'frames.json');
  if (!fs.existsSync(f)) return null;
  const meta = readJson(f);
  return Object.fromEntries(meta.frames.map((fr) => [fr.id, fr]));
}

export function writeSubs(id, lang, outDir) {
  const {lines, storyboard} = videoData(id);
  const {timing} = effectiveTiming(id);
  const cues = buildCues(normalizeTiming(timing), lines[lang], storyboard.timing.cueMax?.[lang]);
  fs.mkdirSync(outDir, {recursive: true});
  const srt = path.join(outDir, `${id}_${lang}.srt`);
  const vtt = path.join(outDir, `${id}_${lang}.vtt`);
  fs.writeFileSync(srt, toSrt(cues));
  fs.writeFileSync(vtt, toVtt(cues, lang));
  return {srt, vtt, cues};
}

export function runPrepare() {
  execFileSync(process.execPath, [path.join(studio, 'scripts/prepare.mjs')], {stdio: 'inherit'});
}

export async function makeBundle({reuse = false, name = 'bundle'} = {}) {
  // Stills use their own bundle dir so they never rewrite the bundle of a
  // render that is still running.
  const outDir = path.join(studio, 'out', name);
  if (reuse && fs.existsSync(path.join(outDir, 'index.html'))) return outDir;
  const {bundle} = await import('@remotion/bundler');
  console.log('bundling…');
  return bundle({entryPoint: path.join(studio, 'src/index.ts'), outDir, publicDir: path.join(studio, 'public')});
}

export function inputProps(id, lang, subtitles = true) {
  const {timing} = effectiveTiming(id);
  const v = voice(id);
  return {lang, timing: v.timing ? timing : null, appFrames: appFrames(id, lang), subtitles};
}

export function diskFreeMB() {
  const out = execFileSync('df', ['-Pm', studio]).toString().trim().split('\n').pop().split(/\s+/);
  return Number(out[3]);
}
