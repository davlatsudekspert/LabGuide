#!/usr/bin/env node
// Render a storyboard video with Remotion (frames) piped into the SYSTEM ffmpeg
// (H.264 High, yuv420p, 30 fps, +faststart). No intermediate frames on disk.
//
//   npm run render -- --id calibration --lang en --format vertical
//   npm run render -- --id calibration --lang all --format all
//   npm run render -- --id calibration --lang uz --format horizontal --frames 0-89   (quick check)
//   options: --crf 19  --concurrency 3  --reuse-bundle  --no-subs  --no-thumbs  --thumbs-only
//            --uz-strict (uz must have its re-timed public/audio/uz/<id>.timing.json)  --allow-silent
//
// Audio: if public/audio/en/<id>.wav + <id>.timing.json exist (English narration
// for en/ru), the WAV is muxed as AAC 48 kHz; otherwise the MP4 is silent
// and the run says so. Outputs: out/<id>/<lang>/ (gitignored).
//
// UZBEK edition (re-timed, tool/tts/retime_uz.py): when public/audio/uz/<id>.timing.json exists, lang uz uses ITS
// timeline (scenes longer than the English ones where the Uzbek voice needs it) and muxes public/audio/uz/<id>.wav
// (must be as long as the video). Without the WAV, or with an ESTIMATED timing file, nothing is rendered unless
// --allow-silent is given; the result is then a clearly named preview, never a final:
//   out/<id>/uz_preview/<id>_uz_<format>_SILENT_PREVIEW.mp4 (no thumbnails).
// ru/en are rendered exactly as before.
import {execFileSync, spawn} from 'node:child_process';
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
  uzVoice,
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

const t0All = Date.now();
function probeSec(file) {
  return Number(execFileSync('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', file]).toString());
}
/** Plan the audio of one language edition. Returns {eff, wav, preview, label} or exits. */
function planAudio(lang) {
  const eff = effectiveTiming(id, lang);
  if (lang === 'uz' && eff.track !== 'uz') {
    if (args['uz-strict']) {
      console.error('uz: no public/audio/uz/<id>.timing.json (run tool/tts/retime_uz.py first) — refusing (--uz-strict)');
      process.exit(2);
    }
    console.warn('WARNING [uz]: no re-timed Uzbek timeline found — rendering on the ENGLISH timeline (legacy).');
  }
  if (eff.track === 'uz') {
    const total = eff.layout.durationInFrames / 30;
    const u = uzVoice(id);
    const needSilent = u.estimated || !u.wav;
    if (needSilent && !args['allow-silent']) {
      console.error(
        u.estimated
          ? `uz: public/audio/uz/${id}.timing.json is an ESTIMATE (no real voice yet). Re-run retime_uz.py with real durations, or pass --allow-silent for a SILENT PREVIEW.`
          : `uz: public/audio/uz/${id}.wav is missing. Build it (tool/tts/retime_uz.py --assemble) or pass --allow-silent for a SILENT PREVIEW.`,
      );
      process.exit(2);
    }
    if (needSilent) {
      console.log(`[uz] SILENT PREVIEW (${u.estimated ? 'estimated timing' : 'no WAV'}), ${total.toFixed(1)} s — not a final`);
      return {eff, wav: null, preview: true, label: 'silent PREVIEW'};
    }
    const wd = probeSec(u.wav);
    if (Math.abs(wd - total) > 0.06) {
      console.error(`uz: WAV is ${wd.toFixed(3)} s but the re-timed video is ${total.toFixed(3)} s — WAV and timing do not belong together`);
      process.exit(2);
    }
    console.log(`audio [uz]: Uzbek narration ${path.relative(studio, u.wav)} (re-timed, ${total.toFixed(1)} s)`);
    return {eff, wav: u.wav, preview: false, label: 'AAC Uzbek narration'};
  }
  console.log(
    eff.voiced
      ? `audio [${lang}]: English narration ${path.relative(studio, eff.wav)} (timing from voice manifest)`
      : `audio [${lang}]: NONE — no voice manifest in public/audio/en/; rendering SILENT with placeholder timing`,
  );
  return {eff, wav: eff.wav, preview: false, label: eff.wav ? 'AAC narration' : 'silent'};
}
// Fail early (before bundling) when an uz edition cannot be rendered as requested.
for (const lang of langs) planAudio(lang);

runPrepare();
const serveUrl = await makeBundle({reuse: !!args['reuse-bundle'], name: args['bundle-name'] ?? 'bundle'});

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
  const plan = planAudio(lang);
  const eff = plan.eff;
  const outDir = path.join(studio, 'out', id, plan.preview ? 'uz_preview' : lang);
  fs.mkdirSync(outDir, {recursive: true});
  if (!args['no-subs']) {
    const s = writeSubs(id, lang, outDir);
    console.log(`[${lang}] subtitles: ${s.cues.length} cues -> ${path.relative(studio, s.srt)}, .vtt`);
  }
  const props = inputProps(id, lang, !args['no-subs']);
  for (const format of args['thumbs-only'] ? [] : formats) {
    const composition = await selectComposition({serveUrl, id: `${id}-${format}`, inputProps: props, browserExecutable: BROWSER});
    const frameRange = range ?? [0, composition.durationInFrames - 1];
    const n = frameRange[1] - frameRange[0] + 1;
    const suffix = range ? `_f${frameRange[0]}-${frameRange[1]}` : '';
    const out = path.join(outDir, `${id}_${lang}_${format}${suffix}${plan.preview ? '_SILENT_PREVIEW' : ''}.mp4`);
    const durationSec = n / composition.fps;
    const wav = plan.wav && !range ? plan.wav : null;
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
    console.log(`[${lang}/${format}] -> ${path.relative(studio, out)} (${(fs.statSync(out).size / 1e6).toFixed(1)} MB, ${sec.toFixed(0)} s, ${wav ? plan.label : plan.preview ? plan.label : 'silent'})`);
  }
  if (!args['no-thumbs'] && !range && !plan.preview) {
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
console.log(`total render time ${((Date.now() - t0All) / 60000).toFixed(1)} min`);
