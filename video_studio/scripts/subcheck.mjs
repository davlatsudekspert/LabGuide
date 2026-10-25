#!/usr/bin/env node
// Subtitle readability check against the EFFECTIVE timing (voice manifest if
// present): characters per second of every burned-in cue (the same cues as
// the .srt/.vtt), cue length and estimated rows on the 1080-wide vertical.
//   node scripts/subcheck.mjs --id leukocyte [--max-cps 17]
import {buildCues, wrapRows} from '../src/lib/subtitles.js';
import {normalizeTiming} from '../src/lib/timing.js';
import {LANGS, effectiveTiming, parseArgs, videoData} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id ?? 'calibration';
const maxCps = Number(args['max-cps'] ?? 17);
// Realistic row capacity of the burned-in plate (Inter 600): vertical 48 px in
// 880 px; horizontal 44 px in 1420 px has ~1.6x the room (never the limit).
// Per language (Cyrillic glyphs are wider): calibrated on rendered vertical frames.
const ROW_CAP = {en: 38, ru: 32, uz: 33};
function greedyRows(text, cap) {
  let rows = 1, len = 0;
  for (const w of text.split(/\s+/)) {
    const n = [...w].length;
    if (len && len + 1 + n > cap) { rows++; len = n; } else len += (len ? 1 : 0) + n;
  }
  return rows;
}
const {lines, storyboard} = videoData(id);
const {timing, voiced} = effectiveTiming(id);
let bad = 0;
console.log(`${id}: timing from ${voiced ? 'voice manifest' : 'placeholder'}; limit ${maxCps} chars/s`);
for (const lang of LANGS) {
  const cues = buildCues(normalizeTiming(timing), lines[lang], storyboard.timing.cueMax?.[lang]);
  let worst = 0;
  for (const c of cues) {
    const n = [...c.text].length;
    const cps = n / (c.end - c.start);
    worst = Math.max(worst, cps);
    const rows = Math.max(wrapRows(c.text).length, greedyRows(c.text, Number(args['row-chars'] ?? ROW_CAP[lang] ?? 30)));
    if (cps > maxCps || rows > 2) {
      bad++;
      console.log(`  ${lang} ${c.lineId}#${c.index} ${cps.toFixed(1)} cps (${n} ch / ${(c.end - c.start).toFixed(2)} s, ${rows} rows): ${c.text}`);
    }
  }
  console.log(`  ${lang}: ${cues.length} cues, worst ${worst.toFixed(1)} chars/s`);
}
process.exit(bad ? 1 : 0);
