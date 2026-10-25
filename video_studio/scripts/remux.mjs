#!/usr/bin/env node
// Replace the audio of already rendered MP4s with the current narration WAV
// (video stream copied, no re-render). Only valid when the voice TIMING is
// unchanged (scene layout depends on it); the script refuses when the MP4
// duration differs from the timing manifest.
//   npm run remux -- --id calibration [--lang all]
import {execFileSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {LANGS, effectiveTiming, parseArgs, studio} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id ?? 'calibration';
const langs = !args.lang || args.lang === 'all' ? LANGS : String(args.lang).split(',');
const {wav, layout} = effectiveTiming(id);
if (!wav) {
  console.error('no narration WAV — nothing to mux');
  process.exit(1);
}
for (const lang of langs) {
  const dir = path.join(studio, 'out', id, lang);
  for (const name of fs.readdirSync(dir).filter((n) => n.endsWith('.mp4'))) {
    const mp4 = path.join(dir, name);
    const dur = Number(execFileSync('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', mp4]).toString());
    if (Math.abs(dur - layout.totalSec) > 0.05) {
      console.error(`${name}: duration ${dur} != timing ${layout.totalSec} — re-render instead`);
      process.exit(2);
    }
    const tmp = mp4.replace(/\.mp4$/, '.remux.mp4');
    execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-i', mp4, '-i', wav, '-map', '0:v:0', '-c:v', 'copy', '-map', '1:a:0', '-c:a', 'aac', '-b:a', '160k', '-ar', '48000', '-t', String(dur), '-movflags', '+faststart', tmp]);
    fs.renameSync(tmp, mp4);
    console.log(`remuxed ${path.relative(studio, mp4)}`);
  }
}
