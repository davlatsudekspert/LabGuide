#!/usr/bin/env node
// Viewing check from the FINAL MP4: extracts one full-size frame per scene
// (at --at, default 0.6 of the scene) plus the hook moments t = 0, 0.5, 1.5 s,
// and writes them as PNGs + contact sheets (rows of --cols) for review.
//   node scripts/qa_frames.mjs --id photometry --lang en --format vertical [--at 0.6] [--out DIR]
import {execFileSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {effectiveTiming, parseArgs, studio} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id;
const lang = args.lang ?? 'en';
const format = args.format ?? 'vertical';
const at = Number(args.at ?? 0.6);
const out = args.out ?? path.join(studio, 'out/qa', id, `${lang}_${format}`);
const cols = Number(args.cols ?? (format === 'vertical' ? 5 : 3));
const mp4 = path.join(studio, 'out', id, lang, `${id}_${lang}_${format}.mp4`);
if (!fs.existsSync(mp4)) throw new Error(`missing ${mp4}`);
fs.mkdirSync(out, {recursive: true});
const {layout} = effectiveTiming(id);
const shots = [
  {name: 'hook_t0.0', t: 0.0},
  {name: 'hook_t0.5', t: 0.5},
  {name: 'hook_t1.5', t: 1.5},
  ...layout.scenes.map((s) => ({name: `${String(s.index + 1).padStart(2, '0')}_${s.id}`, t: s.startSec + (s.endSec - s.startSec) * at})),
];
const files = [];
for (const s of shots) {
  const f = path.join(out, `${s.name}.png`);
  execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-ss', s.t.toFixed(3), '-i', mp4, '-frames:v', '1', f]);
  files.push(f);
}
// Contact sheets at half size (review aid; the full-size PNGs are the check).
const sheetW = format === 'vertical' ? 540 : 960;
for (let i = 0, k = 0; i < files.length; i += cols, k++) {
  const group = files.slice(i, i + cols);
  const inputs = group.flatMap((f) => ['-i', f]);
  const filt = group.map((_, j) => `[${j}]scale=${sheetW}:-1[s${j}]`).join(';') + ';' + group.map((_, j) => `[s${j}]`).join('') + `hstack=inputs=${group.length}`;
  const sheet = path.join(out, `sheet_${k + 1}.png`);
  if (group.length === 1) execFileSync('ffmpeg', ['-y', '-loglevel', 'error', ...inputs, '-vf', `scale=${sheetW}:-1`, sheet]);
  else execFileSync('ffmpeg', ['-y', '-loglevel', 'error', ...inputs, '-filter_complex', filt, sheet]);
}
console.log(`${files.length} frames -> ${path.relative(studio, out)}`);
