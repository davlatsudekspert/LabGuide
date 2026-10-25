#!/usr/bin/env node
// Quick visual checks without a video render: PNG stills at chosen moments.
//   npm run still -- --id calibration --lang en --format vertical --scenes all
//   npm run still -- --lang uz --format horizontal --scenes fit,app_rules --at 0.5
//   npm run still -- --frame 120
// --at: position inside each scene (0..1, default 0.7). Output: out/stills/.
import fs from 'node:fs';
import path from 'node:path';
import {renderStill, selectComposition} from '@remotion/renderer';
import {BROWSER, effectiveTiming, inputProps, makeBundle, parseArgs, runPrepare, studio} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id ?? 'calibration';
const lang = args.lang ?? 'en';
const format = args.format ?? 'vertical';
const at = String(args.at ?? '0.7').split(',').map(Number);
runPrepare();
const serveUrl = await makeBundle({reuse: !!args['reuse-bundle'], name: 'bundle-still'});
const props = inputProps(id, lang);
const {layout} = effectiveTiming(id);
const outDir = path.join(studio, 'out/stills');
fs.mkdirSync(outDir, {recursive: true});
let targets = [];
if (args.frame != null) {
  targets = String(args.frame).split(',').map((f) => ({name: `f${f}`, frame: Number(f)}));
} else {
  const want = !args.scenes || args.scenes === 'all' ? null : String(args.scenes).split(',');
  for (const sc of layout.scenes) {
    if (want && !want.includes(sc.id)) continue;
    for (const a of at) {
      targets.push({name: `${String(sc.index + 1).padStart(2, '0')}_${sc.id}_${a}`, frame: sc.from + Math.min(sc.durationInFrames - 1, Math.round(sc.durationInFrames * a))});
    }
  }
}
const composition = await selectComposition({serveUrl, id: `${id}-${format}`, inputProps: props, browserExecutable: BROWSER});
for (const t of targets) {
  const output = path.join(outDir, `${id}_${lang}_${format}_${t.name}.png`);
  await renderStill({composition, serveUrl, inputProps: props, frame: t.frame, output, browserExecutable: BROWSER});
  console.log(`${path.relative(studio, output)}  (frame ${t.frame})`);
}
