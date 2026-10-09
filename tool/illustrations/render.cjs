// SVG chizmalarni PNG ga aylantiradi (Playwright Chromium).
//   NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs [nom ...]
//   NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs --cells [nom ...]
// --cells: leykoformula hujayra sxemalari (tool/illustrations/cells/*.svg,
// o'lcham SVG dan) → assets/differential/<nom>.png.
const { chromium } = require('playwright');
const { readFileSync, readdirSync } = require('node:fs');
const { join } = require('node:path');

const here = __dirname;
const args = process.argv.slice(2);
const cells = args[0] === '--cells';
const rest = cells ? args.slice(1) : args;
const srcDir = cells ? join(here, 'cells') : here;
const out = cells
  ? join(here, '../../assets/differential')
  : join(here, '../../assets/instruments/img');
const names = rest.length
  ? rest
  : cells
    ? readdirSync(srcDir).filter((f) => f.endsWith('.svg')).map((f) => f.slice(0, -4))
    : ['chemistry', 'hematology', 'immunoassay', 'urinalysis'];
(async () => {
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const page = await browser.newPage({ viewport: { width: 1200, height: 900 }, deviceScaleFactor: 1 });
const font = readFileSync(join(here, '../../assets/fonts/Inter-700.ttf')).toString('base64');
const font6 = readFileSync(join(here, '../../assets/fonts/Inter-600.ttf')).toString('base64');
for (const n of names) {
  const svg = readFileSync(join(srcDir, `${n}.svg`), 'utf8');
  // O'lcham SVG ning width/height atributidan (odatiy — 1200×900).
  const w = Number(/width="(\d+)"/.exec(svg)?.[1] ?? 1200);
  const h = Number(/height="(\d+)"/.exec(svg)?.[1] ?? 900);
  await page.setViewportSize({ width: w, height: h });
  await page.setContent(`<html><head><style>
    @font-face{font-family:Inter;font-weight:700;src:url(data:font/ttf;base64,${font})}
    @font-face{font-family:Inter;font-weight:600;src:url(data:font/ttf;base64,${font6})}
    html,body{margin:0;padding:0}</style></head><body>${svg}</body></html>`);
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({ path: join(out, `${n}.png`), clip: { x: 0, y: 0, width: w, height: h } });
  console.log('ok', n);
}
await browser.close();
})();
