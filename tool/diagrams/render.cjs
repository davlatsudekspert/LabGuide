// LabGuide jarayon sxemalari: tool/diagrams/svg/<mavzu>.<til>.svg → assets/diagrams/<mavzu>.<til>.png
// (960x640 SVG, 2x = 1920x1280; Inter shrifti assets/fonts dan, OFL).
//   python3 tool/diagrams/gen_diagrams.py
//   NODE_PATH=$(npm root -g) node tool/diagrams/render.cjs [--quant] [--out DIR] [nom ...]
// --quant: pngquant bilan siqiladi (o'rnatilgan bo'lsa; har fayl <= 150 KB bo'lishi kerak).
// --out DIR: boshqa papkaga (masalan, ko'rib chiqish uchun vaqtinchalik).
const { chromium } = require('playwright');
const { readFileSync, readdirSync, statSync } = require('node:fs');
const { spawnSync } = require('node:child_process');
const { join, resolve } = require('node:path');

const here = __dirname;
const args = process.argv.slice(2);
const quant = args.includes('--quant');
const oi = args.indexOf('--out');
const out = oi >= 0 ? resolve(args[oi + 1]) : join(here, '../../assets/diagrams');
const rest = args.filter((a, i) => a !== '--quant' && a !== '--out' && (oi < 0 || i !== oi + 1));
const src = join(here, 'svg');
const names = rest.length
  ? rest
  : readdirSync(src).filter((f) => f.endsWith('.svg')).map((f) => f.slice(0, -4)).sort();
const fonts = [400, 500, 600, 700]
  .map((w) => {
    const b64 = readFileSync(join(here, `../../assets/fonts/Inter-${w}.ttf`)).toString('base64');
    return `@font-face{font-family:Inter;font-weight:${w};src:url(data:font/ttf;base64,${b64})}`;
  })
  .join('\n');

(async () => {
  const browser = await chromium.launch({
    executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
  });
  const page = await browser.newPage({ viewport: { width: 960, height: 640 }, deviceScaleFactor: 2 });
  for (const n of names) {
    const svg = readFileSync(join(src, `${n}.svg`), 'utf8');
    await page.setContent(
      `<html><head><style>${fonts}\nhtml,body{margin:0;padding:0}</style></head><body>${svg}</body></html>`,
    );
    await page.evaluate(() => document.fonts.ready);
    const file = join(out, `${n}.png`);
    await page.screenshot({ path: file, clip: { x: 0, y: 0, width: 960, height: 640 } });
    if (quant) {
      const r = spawnSync('pngquant', ['--quality=70-95', '--speed=1', '--strip', '--force', '--skip-if-larger', '--output', file, file]);
      if (r.error) throw r.error;
    }
    const kb = statSync(file).size / 1024;
    console.log('ok', n, `${kb.toFixed(1)} KB`);
    if (quant && kb > 150) {
      console.error(`ERROR ${n}: ${kb.toFixed(1)} KB > 150 KB`);
      process.exitCode = 1;
    }
  }
  await browser.close();
})();
