#!/usr/bin/env node
// English narration track for ALL language editions (owner decision
// 2026-10-25; ru/uz = subtitles + on-screen text only).
//
//   npm run voice -- --id calibration --python /path/venv/bin/python \
//       --model kokoro-v1.0.int8.onnx --voices voices-v1.0.bin [--voice af_heart]
//   npm run voice -- --id calibration --backend none      (silent, estimated)
//
// 1. tool/tts/synth.py (written by the TTS work, used unchanged) synthesises
//    one WAV per narration line (Kokoro-82M, Apache-2.0) -> durations.
// 2. The storyboard layout rules place each clip (scene lead/tail/min length),
//    so animation and voice share one timeline.
// 3. ffmpeg: clips mixed at their start times, padded to the video length,
//    two-pass loudnorm to -16 LUFS integrated, true peak -2 dBTP in the WAV
//    (AAC adds ~0.5 dB of inter-sample peak, so the MP4 stays <= -1.5 dBTP), 48 kHz.
// Output: public/audio/en/<id>.wav + <id>.timing.json (gitignored WAV; the
// timing JSON is small and is committed as the voice manifest of record).
import {execFileSync, spawnSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {layoutScenes, placeholderTiming} from '../src/lib/timing.js';
import {NARRATION_LANG, parseArgs, readJson, repo, studio, videoData} from './lib.mjs';

const args = parseArgs(process.argv.slice(2));
const id = args.id ?? 'calibration';
const backend = args.backend ?? 'kokoro';
const voiceName = args.voice ?? 'af_heart';
const py = args.python ?? 'python3';
// True-peak target of the WAV (dBTP). AAC adds inter-sample peaks, so a video
// whose MP4 measures above -2 dBTP can use e.g. --tp -2.4 (then npm run remux).
const tp = Number(args.tp ?? -2);
const {storyboard, packs, lines} = videoData(id);
const en = lines[NARRATION_LANG];
const spoken = packs[NARRATION_LANG].spoken ?? {};

const work = path.join(studio, 'out/voice', id);
fs.mkdirSync(work, {recursive: true});
const order = storyboard.scenes.flatMap((s) => s.lines);
const script = {
  lang: NARRATION_LANG,
  voice: voiceName,
  gap_s: 0,
  lines: order.map((lid) => ({id: lid, text: spoken[lid] ?? en[lid]})),
};
const scriptFile = path.join(work, 'script.en.json');
fs.writeFileSync(scriptFile, JSON.stringify(script, null, 2));

const synthArgs = [path.join(repo, 'tool/tts/synth.py'), scriptFile, '--out', path.join(work, 'clips'), '--backend', backend];
if (backend === 'kokoro') synthArgs.push('--voice-file', args.model, '--voices-file', args.voices, '--voice', voiceName);
if (backend === 'piper') synthArgs.push('--voice-file', args.model);
console.log(`synth: ${backend} ${backend === 'kokoro' ? voiceName : ''}`);
const r = spawnSync(py, synthArgs, {stdio: 'inherit'});
if (r.status !== 0) {
  console.error('synth failed — no voice track written');
  process.exit(1);
}
const manifest = readJson(path.join(work, 'clips/manifest.json'));
const durations = Object.fromEntries(manifest.lines.map((l) => [l.id, l.duration ?? l.end - l.start]));
const sched = placeholderTiming(storyboard, en, NARRATION_LANG, durations);
const layout = layoutScenes(storyboard, sched, storyboard.fps);
const total = layout.durationInFrames / storyboard.fps;

const outDir = path.join(studio, 'public/audio', NARRATION_LANG);
fs.mkdirSync(outDir, {recursive: true});
const wavOut = path.join(outDir, `${id}.wav`);
const timingOut = path.join(outDir, `${id}.timing.json`);

if (manifest.estimated) {
  console.log('backend is silent/estimated: writing timing only (no WAV)');
} else {
  const inputs = [];
  const filters = [];
  manifest.lines.forEach((l, i) => {
    const at = sched.lines.find((s) => s.id === l.id).start;
    inputs.push('-i', path.join(work, 'clips', l.file ?? `${l.id}.wav`));
    filters.push(`[${i}:a]aresample=48000,adelay=${Math.round(at * 1000)}:all=1[a${i}]`);
  });
  const mix = `${filters.join(';')};${manifest.lines.map((_, i) => `[a${i}]`).join('')}amix=inputs=${manifest.lines.length}:normalize=0:dropout_transition=0,apad=whole_dur=${total.toFixed(3)},atrim=0:${total.toFixed(3)}`;
  const raw = path.join(work, 'mix_raw.wav');
  execFileSync('ffmpeg', ['-y', '-loglevel', 'error', ...inputs, '-filter_complex', `${mix}[m]`, '-map', '[m]', '-ac', '1', '-ar', '48000', raw]);
  // Two-pass EBU R128 loudness normalisation.
  const p1 = spawnSync('ffmpeg', ['-hide_banner', '-i', raw, '-af', `loudnorm=I=-16:TP=${tp}:LRA=11:print_format=json`, '-f', 'null', '-'], {encoding: 'utf8'});
  const meas = JSON.parse(p1.stderr.slice(p1.stderr.lastIndexOf('{'), p1.stderr.lastIndexOf('}') + 1));
  const ln = `loudnorm=I=-16:TP=${tp}:LRA=11:measured_I=${meas.input_i}:measured_TP=${meas.input_tp}:measured_LRA=${meas.input_lra}:measured_thresh=${meas.input_thresh}:offset=${meas.target_offset}:linear=true:print_format=json`;
  const p2 = spawnSync('ffmpeg', ['-y', '-hide_banner', '-i', raw, '-af', ln, '-ar', '48000', '-ac', '1', '-c:a', 'pcm_s16le', wavOut], {encoding: 'utf8'});
  const after = JSON.parse(p2.stderr.slice(p2.stderr.lastIndexOf('{'), p2.stderr.lastIndexOf('}') + 1));
  fs.rmSync(raw);
  sched.loudness = {
    target: {I: -16, TP: tp, LRA: 11},
    before: {I: +meas.input_i, TP: +meas.input_tp, LRA: +meas.input_lra},
    after: {I: +after.output_i, TP: +after.output_tp, LRA: +after.output_lra},
  };
  console.log(`loudness: ${meas.input_i} LUFS / ${meas.input_tp} dBTP -> ${after.output_i} LUFS / ${after.output_tp} dBTP`);
}
sched.videoId = id;
sched.lang = NARRATION_LANG;
sched.source = manifest.estimated ? 'estimated (synth.py none)' : `synthetic narration: tool/tts/synth.py backend=${backend}`;
sched.voice = backend === 'kokoro' ? `Kokoro-82M v1.0 int8 ONNX, voice ${voiceName} (Apache-2.0)` : backend;
sched.listeningReview = 'PENDING — nobody has listened to this voice yet';
sched.totalSec = Math.round(total * 1000) / 1000;
fs.writeFileSync(timingOut, JSON.stringify(sched, null, 2) + '\n');
console.log(`timing -> ${path.relative(studio, timingOut)} (${sched.totalSec} s)${fs.existsSync(wavOut) ? `, wav -> ${path.relative(studio, wavOut)}` : ''}`);
