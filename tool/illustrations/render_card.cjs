// Bitta SVG kartani PNG ga aylantiradi (Playwright Chromium), o'lcham SVG dan.
//   NODE_PATH=$(npm root -g) node tool/illustrations/render_card.cjs <in.svg> <out.png>
// Koagulogramma va koprologiya kartalari uchun (render.cjs ga tegmasdan).
const { chromium } = require('playwright');
const { readFileSync } = require('node:fs');

const [src, out] = process.argv.slice(2);
if (!src || !out) {
  console.error('usage: render_card.cjs <in.svg> <out.png>');
  process.exit(2);
}
(async () => {
  const svg = readFileSync(src, 'utf8');
  const w = Number(/width="(\d+)"/.exec(svg)?.[1] ?? 600);
  const h = Number(/height="(\d+)"/.exec(svg)?.[1] ?? 600);
  const browser = await chromium.launch({
    executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
  });
  const page = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  await page.setContent(`<html><body style="margin:0">${svg}</body></html>`);
  await page.screenshot({ path: out, clip: { x: 0, y: 0, width: w, height: h } });
  await browser.close();
  console.log('ok', out);
})();
