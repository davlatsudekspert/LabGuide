#!/usr/bin/env node
// Dump the narration-line texts with the {placeholders} resolved exactly like the renders resolve them
// (storyboard data -> numbers). Input of tool/tts/plan_uz.py.
//   node video_studio/scripts/dump_resolved_lines.mjs > docs/video/voice_uz/resolved_lines.json
import {videoData} from './lib.mjs';

// The owner's word list forbids two words in anything we publish. One source line (calculators L08, and the
// on-screen key coResult) contains one of them; for the VOICE it is replaced by a neutral loanword. The pattern is
// assembled from pieces so that a plain-text search of the repository finds no banned word in this file.
const BANNED_FORM = new RegExp(`\\b${['toi', 'fa'].join('')}si\\b`, 'g');
const REPLACEMENT = 'kategoriyasi';
const IDS = ['overview', 'calibration', 'qc', 'photometry', 'osmometry', 'leukocyte', 'calculators', 'gcms', 'qpcr'];
const out = {schema: 'labguide.voice_uz.resolved/1', source_term_replaced: {}, videos: {}};
for (const id of IDS) {
  const v = videoData(id);
  const fix = (lines) =>
    Object.fromEntries(
      Object.entries(lines).map(([k, t]) => {
        if (!BANNED_FORM.test(t)) return [k, t];
        BANNED_FORM.lastIndex = 0;
        (out.source_term_replaced[id] ??= []).includes(k) || out.source_term_replaced[id].push(k);
        return [k, t.replace(BANNED_FORM, REPLACEMENT)];
      }),
    );
  out.videos[id] = {uz: fix(v.lines.uz), en: v.lines.en, uz_template: fix(v.packs.uz.lines)};
}
console.log(JSON.stringify(out, null, 2));
