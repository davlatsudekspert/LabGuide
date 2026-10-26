#!/usr/bin/env node
// Reel renderer (Remotion frames -> system ffmpeg, h264 + silent AAC).
//   node scripts/render_reel.mjs --stills 0,9,30,300     preview stills -> out/reel_labs/stills/
//   node scripts/render_reel.mjs --video                 ONE render -> out/reel_labs/trilingual/
// SRT/VTT per language are written from docs/video/reel_labs/reel.json (same cues as the burned captions).
import {spawn} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {renderFrames, renderStill, selectComposition} from '@remotion/renderer';
import {BROWSER, parseArgs, studio, repo} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const reel = JSON.parse(fs.readFileSync(path.join(repo, 'docs/video/reel_labs/reel.json'), 'utf8'));
const outRoot = path.join(studio, 'out/reel_labs');
const outDir = path.join(outRoot, 'trilingual');
fs.mkdirSync(outDir, {recursive: true});

const ts = (s, comma) => {
  const ms = Math.round(s * 1000);
  const p = (n, w = 2) => String(n).padStart(w, '0');
  return `${p(Math.floor(ms / 3600000))}:${p(Math.floor(ms / 60000) % 60)}:${p(Math.floor(ms / 1000) % 60)}${comma ? ',' : '.'}${p(ms % 1000, 3)}`;
};
for (const lang of ['uz', 'ru', 'en']) {
  const srt = reel.cues.map((c, i) => `${i + 1}\n${ts(c.start, true)} --> ${ts(c.end, true)}\n${c[lang]}\n`).join('\n');
  const vtt = `WEBVTT\nKind: captions\nLanguage: ${lang}\n\n` + reel.cues.map((c) => `${ts(c.start)} --> ${ts(c.end)}\n${c[lang]}\n`).join('\n');
  fs.writeFileSync(path.join(outDir, `reel_labs_${lang}.srt`), srt);
  fs.writeFileSync(path.join(outDir, `reel_labs_${lang}.vtt`), vtt);
}

const bundleDir = path.join(studio, 'out/reel_bundle');
let serveUrl = bundleDir;
if (!(args['reuse-bundle'] && fs.existsSync(path.join(bundleDir, 'index.html')))) {
  const {bundle} = await import('@remotion/bundler');
  console.log('bundling…');
  serveUrl = await bundle({entryPoint: path.join(studio, 'src/reel_entry.tsx'), outDir: bundleDir, publicDir: path.join(studio, 'public')});
}
const comp = await selectComposition({serveUrl, id: 'reel-labs', browserExecutable: BROWSER});

if (args.stills) {
  const dir = path.join(outRoot, 'stills');
  fs.mkdirSync(dir, {recursive: true});
  for (const fr of String(args.stills).split(',').map(Number)) {
    await renderStill({composition: comp, serveUrl, output: path.join(dir, `f${String(fr).padStart(4, '0')}.jpg`), frame: fr, imageFormat: 'jpeg', jpegQuality: 90, browserExecutable: BROWSER});
  }
  console.log('stills ->', dir);
}

if (args.video) {
  const out = path.join(outDir, 'reel_labs_uz-ru-en_vertical.mp4');
  const n = comp.durationInFrames;
  const ff = spawn('ffmpeg', [
    '-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', '30', '-c:v', 'mjpeg', '-i', 'pipe:0',
    '-f', 'lavfi', '-i', 'anullsrc=r=48000:cl=stereo',
    '-map', '0:v:0', '-map', '1:a:0',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-profile:v', 'high', '-level', '4.1', '-pix_fmt', 'yuv420p', '-r', '30', '-g', '60', '-movflags', '+faststart',
    '-color_primaries', 'bt709', '-color_trc', 'bt709', '-colorspace', 'bt709',
    '-c:a', 'aac', '-b:a', '96k', '-ar', '48000', '-t', String(n / 30), out,
  ], {stdio: ['pipe', 'inherit', 'inherit']});
  const done = new Promise((res, rej) => ff.on('close', (c) => (c === 0 ? res() : rej(new Error(`ffmpeg ${c}`)))));
  const pending = new Map();
  let next = 0;
  const write = (b) => new Promise((res) => (ff.stdin.write(b) ? res() : ff.stdin.once('drain', res)));
  const t0 = Date.now();
  await renderFrames({
    composition: comp, serveUrl, outputDir: null, frameRange: args.range ? String(args.range).split('-').map(Number) : null, imageFormat: 'jpeg', jpegQuality: 94, concurrency: Number(args.concurrency ?? 3), browserExecutable: BROWSER,
    onStart: () => console.log(`rendering ${n} frames`),
    onFrameUpdate: (c) => { if (c % 200 === 0) console.log(`  ${c}/${n} ${(c / ((Date.now() - t0) / 1000)).toFixed(1)} fps`); },
    onFrameBuffer: async (buf, frame) => {
      pending.set(frame, buf);
      while (pending.has(next)) { const b = pending.get(next); pending.delete(next); next++; await write(b); }
    },
  });
  ff.stdin.end();
  await done;
  console.log(`-> ${out} (${(fs.statSync(out).size / 1e6).toFixed(1)} MB, ${((Date.now() - t0) / 1000).toFixed(0)} s)`);
  const cover = path.join(outDir, 'reel_labs_uz-ru-en_cover_1080x1920.jpg');
  await renderStill({composition: comp, serveUrl, output: cover, frame: Number(args.cover ?? 56), imageFormat: 'jpeg', jpegQuality: 93, browserExecutable: BROWSER});
  console.log('cover ->', cover);
}
