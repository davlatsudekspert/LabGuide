#!/usr/bin/env node
// Exact subtitle row check (real font metrics via scripts/subrows.py) for
// every burned-in cue, both formats, all languages. Exit 1 if a cue needs
// more than 2 rows.   node scripts/subrows.mjs --id qc
import {execFileSync} from 'node:child_process';
import path from 'node:path';
import {buildCues} from '../src/lib/subtitles.js';
import {normalizeTiming} from '../src/lib/timing.js';
import {LANGS, effectiveTiming, parseArgs, studio, videoData} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id;
const {lines, storyboard} = videoData(id);
const {timing, layout} = effectiveTiming(id);
const zoneAt = (t) => layout.scenes.find((s) => t >= s.startSec && t < s.endSec)?.props?.subZone === 'left';
// Safety margin: the browser wrapped a cue that PIL measured at 879.6 of 880 px
// (RU qPCR L07) — subtract the 1 px borders and keep 1.5 % slack.
const W = (w) => Math.floor((w - 2) * 0.985);
const items = [];
for (const lang of LANGS) {
  for (const c of buildCues(normalizeTiming(timing), lines[lang], storyboard.timing.cueMax?.[lang])) {
    const k = storyboard.timing.cueFont?.[lang]?.[c.lineId] ?? 1;
    items.push({key: `${lang}|vertical|${c.lineId}#${c.index}|${c.text}`, text: c.text, size: Math.round(48 * k), width: W(940 - 60)});
    const left = zoneAt(c.start);
    items.push({key: `${lang}|horizontal|${c.lineId}#${c.index}|${c.text}`, text: c.text, size: Math.round(44 * k), width: W((left ? 1080 : 1480) - 60)});
  }
}
const res = JSON.parse(execFileSync('python3', ['-I', path.join(studio, 'scripts/subrows.py'), path.join(studio, 'public/fonts/Inter-600.ttf')], {input: JSON.stringify(items)}).toString());
let bad = 0;
for (const [k, rows] of Object.entries(res)) {
  if (rows > 2) {
    bad++;
    console.log(`${rows} rows: ${k}`);
  }
}
console.log(`${id}: ${items.length} cue renders checked, ${bad} with > 2 rows`);
process.exit(bad ? 1 : 0);
