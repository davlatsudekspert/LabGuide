import json, sys, subprocess, base64, os, html
# python3 make_pdf.py video.mp4 timing.json lines.json title out.pdf
vid, timing, linesf, title, out = sys.argv[1:6]
T = json.load(open(timing)); L = json.load(open(linesf))
starts, dur, total = T['starts'], T['dur'], T['total']
names = [l[0] for l in L]
tmp = out + '_thumbs'; os.makedirs(tmp, exist_ok=True)
def mmss(x): return f"{int(x//60)}:{int(x%60):02d}"
rows = []
for i, (n, _, txt, lab) in enumerate(L):
    s = starts[n]; e = starts[names[i+1]] if i+1 < len(names) else total
    tt = min(s + 1.5, total - 0.3)
    th = f'{tmp}/{n}.jpg'
    subprocess.run(['ffmpeg','-v','error','-y','-ss',str(tt),'-i',vid,'-frames:v','1','-vf','scale=300:-2','-q:v','4',th], check=True)
    b64 = base64.b64encode(open(th,'rb').read()).decode()
    rows.append(f'''<div class="row"><img src="data:image/jpeg;base64,{b64}"><div class="body">
<div class="time"><b>{i+1}.</b> &nbsp;{mmss(s)} – {mmss(e)} <span class="max">(eng ko‘pi {max(1,round(e-s-0.4))} soniya)</span></div>
<div class="lab">Ekranda: {html.escape(lab or "Yakuniy sahna: logotip, “Tez kunda App Store va Google Play’da”")}</div>
<div class="txt">{html.escape(txt)}</div></div></div>''')
page = f'''<!doctype html><html><head><meta charset="utf-8"><style>
@font-face {{ font-family: Inter; src: url(file:///usr/share/fonts/opentype/inter/Inter-Regular.otf); }}
@font-face {{ font-family: Inter; font-weight: 700; src: url(file:///usr/share/fonts/opentype/inter/Inter-Bold.otf); }}
body {{ font-family: Inter, sans-serif; color:#1b2b26; margin: 0; }}
h1 {{ font-size: 26px; margin: 0 0 6px; color:#16443a }}
.note {{ font-size: 13px; color:#4b5a55; background:#eef3ec; border-radius:10px; padding:10px 14px; margin: 10px 0 18px; line-height:1.45 }}
.row {{ display:flex; gap:16px; padding:12px 0; border-bottom:1px solid #dfe5df; break-inside: avoid; }}
.row img {{ width:120px; border-radius:10px; border:1px solid #ccd5cf; align-self:flex-start }}
.time {{ font-size:15px; color:#16443a }}
.max {{ color:#7a857f; font-size:13px }}
.lab {{ font-size:12.5px; color:#6b7772; margin:3px 0 8px }}
.txt {{ font-size:22px; line-height:1.4; font-weight:700 }}
</style></head><body><h1>{html.escape(title)}</h1>
<div class="note">Video uzunligi: {mmss(total)}. Har bir gapni ko‘rsatilgan vaqtda boshlang, shoshilmasdan, yumshoq ohangda o‘qing.<br>
Yozish: telefonda, jim xonada, og‘izdan 15–20 sm. Har bir gapni alohida faylga (1, 2, 3 …) yoki bitta faylga gaplar orasida 2 soniya jim turib yozing. Fayllarni yuborsangiz, videoga aniq joylab beraman.</div>
{''.join(rows)}</body></html>'''
hp = out.replace('.pdf', '.html'); open(hp, 'w').write(page)
js = f"""const {{ chromium }} = require('playwright'); (async () => {{ const b = await chromium.launch(); const p = await b.newPage();
await p.goto('file://{hp}'); await p.waitForTimeout(500); await p.pdf({{ path: '{out}', format: 'A4', margin: {{ top: '16mm', bottom: '16mm', left: '14mm', right: '14mm' }}, printBackground: true }}); await b.close(); }})();"""
open(out + '.js', 'w').write(js)
subprocess.run(['node', out + '.js'], check=True, cwd=os.environ.get('NPM_DIR', '.'))
os.remove(out + '.js'); os.remove(hp); subprocess.run(['rm','-rf',tmp])
print('pdf', out)
