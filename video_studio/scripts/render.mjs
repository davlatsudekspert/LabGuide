#!/usr/bin/env node
// Render a storyboard video with Remotion (frames) piped into the SYSTEM ffmpeg
// (H.264 High, yuv420p, 30 fps, +faststart). No intermediate frames on disk.
//
//   npm run render -- --id calibration --lang en --format vertical
//   npm run render -- --id calibration --lang all --format all
//   npm run render -- --id calibration --lang uz --format horizontal --frames 0-89   (quick check)
//   options: --crf 19  --concurrency 3  --reuse-bundle  --no-subs  --no-thumbs
//
// Audio: if public/audio/en/<id>.wav + <id>.timing.json exist (English narration
// for ALL editions), the WAV is muxed as AAC 48 kHz; otherwise the MP4 is silent
// and the run says so. Outputs: out/<id>/<lang>/ (gitignored).
import {spawn} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {renderFrames, renderStill, selectComposition} from '@remotion/renderer';
import {
  BROWSER,
  FORMATS,
  LANGS,
  diskFreeMB,
  effectiveTiming,
  inputProps,
  makeBundle,
  parseArgs,
  runPrepare,
  studio,
  writeSubs,
} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id ?? 'calibration';
const langs = !args.lang || args.lang === 'all' ? LANGS : String(args.lang).split(',');
const formats = !args.format || args.format === 'all' ? FORMATS : String(args.format).split(',');
const crf = Number(args.crf ?? 19);
const concurrency = Number(args.concurrency ?? 3);
const range = args.frames ? String(args.frames).split('-').map(Number) : null;

if (diskFreeMB() < 400) {
  console.error(`only ${diskFreeMB()} MB free — refusing to render (need >= 400 MB)`);
  process.exit(2);
}

runPrepare();
const serveUrl = await makeBundle({reuse: !!args['reuse-bundle']});
const eff = effectiveTiming(id);
console.log(
  eff.voiced
    ? `audio: English narration ${path.relative(studio, eff.wav)} (timing from voice manifest)`
    : 'audio: NONE — no voice manifest in public/audio/en/; rendering SILENT with placeholder timing',
);

function ffmpegFor(out, durationSec, wav) {
  const a = ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', '30', '-c:v', 'mjpeg', '-i', 'pipe:0'];
  if (wav) a.push('-i', wav);
  a.push(
    '-map', '0:v:0',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', String(crf), '-profile:v', 'high', '-level', '4.1',
    '-pix_fmt', 'yuv420p', '-r', '30', '-g', '60', '-movflags', '+faststart',
    '-color_primaries', 'bt709', '-color_trc', 'bt709', '-colorspace', 'bt709',
  );
  if (wav) a.push('-map', '1:a:0', '-c:a', 'aac', '-b:a', '160k', '-ar', '48000', '-t', String(durationSec));
  a.push(out);
  return spawn('ffmpeg', a, {stdio: ['pipe', 'inherit', 'inherit']});
}

for (const lang of langs) {
  const outDir = path.join(studio, 'out', id, lang);
  fs.mkdirSync(outDir, {recursive: true});
  if (!args['no-subs']) {
    const s = writeSubs(id, lang, outDir);
    console.log(`[${lang}] subtitles: ${s.cues.length} cues -> ${path.relative(studio, s.srt)}, .vtt`);
  }
  const props = inputProps(id, lang, !args['no-subs']);
  for (const format of formats) {
    const composition = await selectComposition({serveUrl, id: `${id}-${format}`, inputProps: props, browserExecutable: BROWSER});
    const frameRange = range ?? [0, composition.durationInFrames - 1];
    const n = frameRange[1] - frameRange[0] + 1;
    const suffix = range ? `_f${frameRange[0]}-${frameRange[1]}` : '';
    const out = path.join(outDir, `${id}_${lang}_${format}${suffix}.mp4`);
    const durationSec = n / composition.fps;
    const wav = eff.wav && !range ? eff.wav : null;
    const ff = ffmpegFor(out, durationSec, wav);
    const done = new Promise((res, rej) => ff.on('close', (c) => (c === 0 ? res() : rej(new Error(`ffmpeg exit ${c}`)))));
    // Frames may finish out of order: write them strictly in sequence.
    const pending = new Map();
    let next = frameRange[0];
    const write = (buf) =>
      new Promise((res) => (ff.stdin.write(buf) ? res() : ff.stdin.once('drain', res)));
    const t0 = Date.now();
    let last = 0;
    await renderFrames({
      composition,
      serveUrl,
      inputProps: props,
      outputDir: null,
      imageFormat: 'jpeg',
      jpegQuality: 94,
      concurrency,
      frameRange,
      browserExecutable: BROWSER,
      onStart: () => console.log(`[${lang}/${format}] rendering ${n} frames (${durationSec.toFixed(2)} s)…`),
      onFrameUpdate: (count) => {
        if (count - last >= 300 || count === n) {
          last = count;
          const fps = count / ((Date.now() - t0) / 1000);
          console.log(`  ${count}/${n}  ${fps.toFixed(1)} fps`);
        }
      },
      onFrameBuffer: async (buf, frame) => {
        pending.set(frame, buf);
        while (pending.has(next)) {
          const b = pending.get(next);
          pending.delete(next);
          next++;
          await write(b);
        }
      },
    });
    ff.stdin.end();
    await done;
    const sec = (Date.now() - t0) / 1000;
    console.log(`[${lang}/${format}] -> ${path.relative(studio, out)} (${(fs.statSync(out).size / 1e6).toFixed(1)} MB, ${sec.toFixed(0)} s, ${wav ? 'AAC narration' : 'silent'})`);
  }
  if (!args['no-thumbs'] && !range) {
    for (const [cid, name] of [
      [`${id}-thumb`, `${id}_${lang}_thumb_1280x720.jpg`],
      [`${id}-cover`, `${id}_${lang}_cover_1080x1920.jpg`],
    ]) {
      const composition = await selectComposition({serveUrl, id: cid, inputProps: props, browserExecutable: BROWSER});
      const output = path.join(outDir, name);
      await renderStill({composition, serveUrl, inputProps: props, output, imageFormat: 'jpeg', jpegQuality: 92, browserExecutable: BROWSER});
      console.log(`[${lang}] thumbnail -> ${path.relative(studio, output)}`);
    }
  }
}
