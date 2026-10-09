// SVG chizmalarni PNG ga aylantiradi (Playwright Chromium).
//   NODE_PATH=$(npm root -g) node tool/illustrations/render.cjs [nom ...]
const { chromium } = require('playwright');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');

const here = __dirname;
const out = join(here, '../../assets/instruments/img');
const names = process.argv.slice(2).length
  ? process.argv.slice(2)
  : ['chemistry', 'hematology', 'immunoassay', 'urinalysis'];
(async () => {
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
const page = await browser.newPage({ viewport: { width: 1200, height: 900 }, deviceScaleFactor: 1 });
const font = readFileSync(join(here, '../../assets/fonts/Inter-700.ttf')).toString('base64');
const font6 = readFileSync(join(here, '../../assets/fonts/Inter-600.ttf')).toString('base64');
for (const n of names) {
  const svg = readFileSync(join(here, `${n}.svg`), 'utf8');
  await page.setContent(`<html><head><style>
    @font-face{font-family:Inter;font-weight:700;src:url(data:font/ttf;base64,${font})}
    @font-face{font-family:Inter;font-weight:600;src:url(data:font/ttf;base64,${font6})}
    html,body{margin:0;padding:0}</style></head><body>${svg}</body></html>`);
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({ path: join(out, `${n}.png`), clip: { x: 0, y: 0, width: 1200, height: 900 } });
  console.log('ok', n);
}
await browser.close();
})();
