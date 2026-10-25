#!/usr/bin/env node
// Small fix without a full Remotion re-render: re-renders ONLY a frame range
// (`npm run render -- --frames a-b`, near-lossless segment) and splices it
// into the existing MP4 (one ffmpeg pass: video re-encoded with the standard
// settings, narration WAV muxed again). The scene layout/timing must be
// unchanged — the script refuses if the MP4 length differs from the timing.
//   node scripts/splice.mjs --id photometry --lang all --format all --frames 630-1223
import {execFileSync, spawnSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {FORMATS, LANGS, effectiveTiming, parseArgs, studio} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id;
const langs = !args.lang || args.lang === 'all' ? LANGS : String(args.lang).split(',');
const formats = !args.format || args.format === 'all' ? FORMATS : String(args.format).split(',');
const [a, b] = String(args.frames).split('-').map(Number);
const {layout, wav} = effectiveTiming(id);
const total = layout.durationInFrames;
for (const lang of langs) {
  const r = spawnSync(process.execPath, [path.join(studio, 'scripts/render.mjs'), '--id', id, '--lang', lang, '--format', formats.join(','), '--frames', `${a}-${b}`, '--crf', '10', '--no-subs', '--bundle-name', 'bundle-splice'], {stdio: 'inherit'});
  if (r.status !== 0) process.exit(r.status ?? 1);
  for (const format of formats) {
    const dir = path.join(studio, 'out', id, lang);
    const full = path.join(dir, `${id}_${lang}_${format}.mp4`);
    const seg = path.join(dir, `${id}_${lang}_${format}_f${a}-${b}.mp4`);
    const n = Number(execFileSync('ffprobe', ['-v', 'error', '-count_packets', '-select_streams', 'v:0', '-show_entries', 'stream=nb_read_packets', '-of', 'csv=p=0', full]).toString());
    if (n !== total) throw new Error(`${full}: ${n} frames, timing says ${total} — re-render instead`);
    const tmp = full.replace(/\.mp4$/, '.splice.mp4');
    const fc = `[0:v]trim=end_frame=${a},setpts=PTS-STARTPTS[v0];[1:v]setpts=PTS-STARTPTS[v1];[0:v]trim=start_frame=${b + 1},setpts=PTS-STARTPTS[v2];[v0][v1][v2]concat=n=3:v=1:a=0[v]`;
    execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-i', full, '-i', seg, '-i', wav, '-filter_complex', fc, '-map', '[v]', '-c:v', 'libx264', '-preset', 'medium', '-crf', '19', '-profile:v', 'high', '-level', '4.1', '-pix_fmt', 'yuv420p', '-r', '30', '-g', '60', '-color_primaries', 'bt709', '-color_trc', 'bt709', '-colorspace', 'bt709', '-map', '2:a:0', '-c:a', 'aac', '-b:a', '160k', '-ar', '48000', '-t', String(total / 30), '-movflags', '+faststart', tmp]);
    const n2 = Number(execFileSync('ffprobe', ['-v', 'error', '-count_packets', '-select_streams', 'v:0', '-show_entries', 'stream=nb_read_packets', '-of', 'csv=p=0', tmp]).toString());
    if (n2 !== total) throw new Error(`splice produced ${n2} frames (want ${total})`);
    fs.renameSync(tmp, full);
    fs.rmSync(seg);
    console.log(`spliced frames ${a}-${b} into ${path.relative(studio, full)}`);
  }
}
