#!/usr/bin/env node
// Checks public/audio/uz/<id>.timing.json (tool/tts/retime_uz.py) against the layout rules the renderer really uses
// (src/lib/timing.js layoutScenes): scene starts/lengths must match the file, no scene may be shorter than its
// English original, lines must lie inside their scene, and subtitle cues must be strictly ordered.
//   node scripts/uz_timing_check.mjs [--id calculators | --all]
import fs from 'node:fs';
import path from 'node:path';
import {layoutScenes, normalizeTiming} from '../src/lib/timing.js';
import {buildCues} from '../src/lib/subtitles.js';
import {parseArgs, readJson, studio, videoData} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const ALL = ['overview', 'calibration', 'qc', 'photometry', 'osmometry', 'leukocyte', 'calculators', 'gcms', 'qpcr'];
const ids = args.all ? ALL : String(args.id ?? 'calculators').split(',');
let bad = 0;
for (const id of ids) {
  const f = path.join(studio, 'public/audio/uz', `${id}.timing.json`);
  if (!fs.existsSync(f)) {
    console.log(`${id}: NOT RUN (no ${path.relative(studio, f)})`);
    continue;
  }
  const uz = readJson(f);
  const en = readJson(path.join(studio, 'public/audio/en', `${id}.timing.json`));
  const {storyboard, lines} = videoData(id);
  const fps = storyboard.fps;
  const L = layoutScenes(storyboard, uz, fps);
  const B = layoutScenes(storyboard, en, fps);
  const errs = [];
  L.scenes.forEach((s, k) => {
    const m = uz.scenes[k];
    if (Math.abs(s.from - Math.round(m.from_s * fps)) > 1) errs.push(`${s.id}: from ${s.from} != ${Math.round(m.from_s * fps)}`);
    if (Math.abs(s.durationInFrames - Math.round(m.new_s * fps)) > 1) errs.push(`${s.id}: dur ${s.durationInFrames} != ${Math.round(m.new_s * fps)}`);
    if (s.durationInFrames < B.scenes[k].durationInFrames - 1) errs.push(`${s.id}: SHORTER than English (${s.durationInFrames} < ${B.scenes[k].durationInFrames})`);
    s.cues.forEach((c) => {
      if (c.start < 0 || c.end > s.durationInFrames / fps + 1e-6) errs.push(`${s.id}/${c.id}: line outside its scene (${c.start.toFixed(2)}-${c.end.toFixed(2)} of ${(s.durationInFrames / fps).toFixed(2)})`);
    });
  });
  if (Math.abs(L.durationInFrames - Math.round(uz.totalSec * fps)) > 1) errs.push(`total ${L.durationInFrames} != ${Math.round(uz.totalSec * fps)}`);
  const cues = buildCues(normalizeTiming(uz), lines.uz, storyboard.timing.cueMax?.uz);
  cues.forEach((c, i) => {
    if (i && c.start < cues[i - 1].end - 1e-6) errs.push(`cue ${i} overlaps the previous one`);
  });
  const extra = L.durationInFrames - B.durationInFrames;
  console.log(`${id}: ${errs.length ? 'FAIL' : 'PASS'}  ${(B.durationInFrames / fps).toFixed(2)} s -> ${(L.durationInFrames / fps).toFixed(2)} s (+${(extra / fps).toFixed(2)} s), ${L.scenes.length} scenes, ${cues.length} cues${uz.estimated ? ' [estimated]' : ''}`);
  errs.forEach((e) => console.log('   ' + e));
  bad += errs.length;
}
process.exit(bad ? 1 : 0);
