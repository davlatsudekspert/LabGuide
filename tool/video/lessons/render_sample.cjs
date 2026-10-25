#!/usr/bin/env node
/*
 * Video-dars NAMUNASI: ilovaning original sxemasi + animatsiya → ovozsiz,
 * subtitrli MP4 (docs/video/lessons/SAMPLES.md).
 *
 *   NODE_PATH=$(npm root -g) node tool/video/lessons/render_sample.cjs gc_ms [--lang uz] [--preview 5,20,40]
 *
 * Kirish: tool/video/lessons/sample_<id>.json (sahnalar, subtitrlar uz/ru/en,
 * kamera), tool/video/lessons/anim_<id>.js (animatsiya), player.html (pleyer),
 * tool/illustrations/schematic/<kalit>.svg (ORIGINAL sxema, o'zgartirilmaydi),
 * qism nomlari — parts_src.py (python orqali).
 * Chiqish (build/lesson_samples/, gitignore): <id>_<til>.mp4 (720x1280,
 * H.264, 24 fps, ovozsiz, subtitr kadrga yozilgan) + .srt + .vtt.
 * --preview: video o'rniga ko'rsatilgan soniyalardagi kadrlar (PNG) —
 * build/lesson_samples/preview/.
 * Har kadr window.renderAt(t) bilan deterministik chiziladi; kadrlar diskka
 * yozilmaydi — to'g'ridan-to'g'ri ffmpeg ga uzatiladi.
 */
const fs = require('fs');
const path = require('path');
const { spawn, execFileSync } = require('child_process');
const { chromium } = require('playwright');

const ROOT = path.resolve(__dirname, '..', '..', '..');
const HERE = __dirname;
const OUT = path.join(ROOT, 'build', 'lesson_samples');
const W = 720, H = 1280, FPS = 24;

function args() {
  const a = process.argv.slice(2);
  const o = { id: a[0], langs: [], preview: null };
  for (let i = 1; i < a.length; i++) {
    if (a[i] === '--lang') o.langs.push(a[++i]);
    else if (a[i] === '--preview') o.preview = a[++i].split(',').map(Number);
  }
  if (!o.langs.length) o.langs = ['uz', 'ru', 'en'];
  return o;
}

function partsOf(key) {
  const py = `
import json, sys
sys.path.insert(0, ${JSON.stringify(path.join(ROOT, 'tool', 'video', 'lessons'))})
from lessons import PARTS, TB, NEEDS_EXPERT_OVERRIDES, uz_norm
out = []
for n, p in enumerate(PARTS[${JSON.stringify(key)}]['parts'], 1):
    out.append({'name': {'uz': uz_norm(p['uz'][0]), 'ru': p['ru'][0], 'en': p['en'][0]},
                'sourced': TB not in p['src'] and (${JSON.stringify(key)}, f'C{n}') not in NEEDS_EXPERT_OVERRIDES})
print(json.dumps(out, ensure_ascii=False))
`;
  return JSON.parse(execFileSync('python3', ['-c', py], { encoding: 'utf-8' }));
}

function ts(sec, sep) {
  let ms = Math.round(sec * 1000);
  const h = Math.floor(ms / 3600000); ms -= h * 3600000;
  const m = Math.floor(ms / 60000); ms -= m * 60000;
  const s = Math.floor(ms / 1000); ms -= s * 1000;
  const p = (x, n = 2) => String(x).padStart(n, '0');
  return `${p(h)}:${p(m)}:${p(s)}${sep}${p(ms, 3)}`;
}

const SUB_LABEL = {
  uz: ['Sxematik animatsiya — aniq model emas', 'Ovozsiz namuna (diktorsiz)', 'Savol va takliflar: ilovada «Yordam va aloqa»'],
  ru: ['Схематическая анимация — не точная модель', 'Образец без звука (без диктора)', 'Вопросы и предложения: в приложении «Помощь и связь»'],
  en: ['Schematic animation — not an exact model', 'Silent sample (no narration)', 'Questions and ideas: “Help & contact” in the app'],
};

function cues(data, lang) {
  const out = [[0, data.intro, `${data.title[lang]} — ${SUB_LABEL[lang][0]}. ${SUB_LABEL[lang][1]}.`]];
  let t = data.intro;
  for (const s of data.scenes) {
    const caps = s.captions;
    caps.forEach((c, k) => {
      const a = t + (c.at || 0);
      const b = k + 1 < caps.length ? t + caps[k + 1].at : t + s.dur;
      out.push([a, b, c[lang]]);
    });
    t += s.dur;
  }
  out.push([t, t + data.outro, SUB_LABEL[lang][2]]);
  return out;
}

function writeSubs(data, lang, base) {
  const c = cues(data, lang);
  fs.writeFileSync(base + '.srt', c.map(([a, b, x], i) => `${i + 1}\n${ts(a, ',')} --> ${ts(b, ',')}\n${x}\n`).join('\n'));
  fs.writeFileSync(base + '.vtt', 'WEBVTT\n\n' + c.map(([a, b, x], i) => `${i + 1}\n${ts(a, '.')} --> ${ts(b, '.')}\n${x}\n`).join('\n'));
}

function html(data, lang) {
  const tpl = fs.readFileSync(path.join(HERE, 'player.html'), 'utf-8');
  const svg = fs.readFileSync(path.join(ROOT, 'tool', 'illustrations', 'schematic', `${data.key}.svg`), 'utf-8');
  const script = fs.readFileSync(path.join(HERE, `anim_${data.id}.js`), 'utf-8');
  return tpl
    .replace('{{SVG}}', () => svg)
    .replace('{{SCRIPT}}', () => script)
    .replace('{{DATA}}', () => JSON.stringify(data))
    .replace('{{LANG}}', lang)
    .replace(/\{\{FONTS\}\}/g, 'file://' + path.join(ROOT, 'assets', 'fonts'))
    .replace('{{LOGO}}', 'file://' + path.join(ROOT, 'assets', 'images', 'logo_mark_large.png'));
}

async function main() {
  const o = args();
  const data = JSON.parse(fs.readFileSync(path.join(HERE, `sample_${o.id}.json`), 'utf-8'));
  data.parts = partsOf(data.key);
  fs.mkdirSync(OUT, { recursive: true });
  const work = path.join(OUT, '_work');
  fs.mkdirSync(work, { recursive: true });
  const browser = await chromium.launch();
  try {
    for (const lang of o.langs) {
      const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
      const file = path.join(work, `${o.id}_${lang}.html`);
      fs.writeFileSync(file, html(data, lang));
      const errors = [];
      page.on('pageerror', (e) => errors.push(String(e)));
      page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
      await page.goto('file://' + file);
      await page.evaluate(() => window.READY);
      if (errors.length) throw new Error(errors.join('\n'));
      const total = await page.evaluate(() => window.TOTAL);
      const base = path.join(OUT, `${o.id}_${lang}`);
      if (o.preview) {
        const pdir = path.join(OUT, 'preview');
        fs.mkdirSync(pdir, { recursive: true });
        for (const t of o.preview) {
          await page.evaluate((x) => window.renderAt(x), t);
          await page.screenshot({ path: path.join(pdir, `${o.id}_${lang}_${String(t).padStart(5, '0')}.png`) });
        }
        console.log(`preview ${o.id} ${lang}: ${o.preview.length} kadr, jami ${total.toFixed(1)} s`);
      } else {
        writeSubs(data, lang, base);
        const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS),
          '-c:v', 'png', '-i', '-', '-c:v', 'libx264', '-preset', 'medium', '-crf', '26', '-pix_fmt', 'yuv420p',
          '-an', '-movflags', '+faststart', '-metadata', `title=LabGuide — ${data.title[lang]}`,
          '-metadata', `comment=${SUB_LABEL[lang][0]}; ${SUB_LABEL[lang][1]}`, base + '.mp4'],
          { stdio: ['pipe', 'inherit', 'inherit'] });
        const done = new Promise((res, rej) => ff.on('close', (c) => (c === 0 ? res() : rej(new Error('ffmpeg ' + c)))));
        const n = Math.round(total * FPS);
        for (let k = 0; k < n; k++) {
          await page.evaluate((x) => window.renderAt(x), k / FPS);
          const buf = await page.screenshot({ type: 'png' });
          if (!ff.stdin.write(buf)) await new Promise((r) => ff.stdin.once('drain', r));
        }
        ff.stdin.end();
        await done;
        if (errors.length) throw new Error(errors.join('\n'));
        console.log(`${base}.mp4  ${n} kadr, ${total.toFixed(2)} s`);
      }
      await page.close();
    }
  } finally {
    await browser.close();
    if (!process.env.KEEP_WORK) fs.rmSync(work, { recursive: true, force: true });
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
