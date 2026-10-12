// Flutter web build (localhost:8765) ni Playwright bilan telefon o‘lchamida haqiqiy ishlatib, CDP screencast bilan yozadi.
// Ishlatish: node record_web_session.js OUT_DIR 3   (toifa/atlas tasodifiyligi yozuv uchun Random(42) bilan qotirilgan build)
const { chromium } = require('playwright');
const fs = require('fs');
const OUT = process.argv[2]; const DPR = +(process.argv[3]||3);
fs.mkdirSync(OUT, {recursive:true});
(async () => {
  const b = await chromium.launch();
  const ctx = await b.newContext({ viewport:{width:390,height:844}, deviceScaleFactor:DPR, isMobile:true, hasTouch:true, locale:'uz-UZ' });
  const p = await ctx.newPage();
  await p.goto('http://localhost:8765/', {waitUntil:'networkidle'});
  await p.waitForTimeout(5000);
  await p.evaluate(() => { const e=document.querySelector('flt-semantics-placeholder'); if(e) e.click();
    const st=document.createElement('style'); st.textContent=`.tapdot{position:fixed;width:44px;height:44px;margin:-22px 0 0 -22px;border-radius:50%;background:rgba(255,255,255,.55);border:2px solid rgba(20,80,64,.55);pointer-events:none;z-index:99999;transition:transform .45s ease-out,opacity .45s ease-out}`; document.head.appendChild(st); });
  const cdp = await ctx.newCDPSession(p);
  const log = []; let n = 0; const t0 = Date.now();
  cdp.on('Page.screencastFrame', async f => {
    const name = `f${String(n++).padStart(5,'0')}.jpg`;
    fs.writeFileSync(`${OUT}/${name}`, Buffer.from(f.data,'base64'));
    log.push([name, f.metadata.timestamp]);
    try { await cdp.send('Page.screencastFrameAck', {sessionId: f.sessionId}); } catch(e){}
  });
  const marks = [];
  const mark = (label) => marks.push([label, Date.now()/1000]);
  const W = ms => p.waitForTimeout(ms);
  const dot = async (x,y) => p.evaluate(([x,y]) => { const d=document.createElement('div'); d.className='tapdot'; d.style.left=x+'px'; d.style.top=y+'px'; document.body.appendChild(d);
      requestAnimationFrame(()=>requestAnimationFrame(()=>{d.style.transform='scale(1.6)'; d.style.opacity='0';})); setTimeout(()=>d.remove(),600); }, [x,y]);
  const tap = async (x,y,after=900) => { await dot(x,y); await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x,y}]}); await W(80); await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]}); await W(after); };
  const bbox = (txt) => p.evaluate((txt) => { let best=null;
    for (const e of document.querySelectorAll('flt-semantics, flt-semantics *')) {
      const t=(e.getAttribute('aria-label')||'')+' '+(e.textContent||''); if (!t.includes(txt)) continue;
      let r=e.getBoundingClientRect(); if (r.width<2||r.height<2) continue; const a=r.width*r.height;
      if (!best || a<best.a) best={x:r.x,y:r.y,width:r.width,height:r.height,a,el:e}; }
    if (!best) return null;
    const tp = best.el.closest('[flt-tappable]'); if (tp) { const r=tp.getBoundingClientRect(); if (r.height<200 && r.height>2) return {x:r.x,y:r.y,width:r.width,height:r.height}; }
    delete best.el; return best; }, txt);
  const scroll = async (dy, steps=10, after=400) => { await cdp.send('Input.synthesizeScrollGesture', {x:340, y: dy>0?640:180, yDistance:-dy, speed: 700, gestureSourceType:'touch', preventFling: true}); await W(after); };
  const tapT = async (txt, after=900) => {
    for (let i=0;i<8;i++) { const bb = await bbox(txt);
      if (bb && bb.y + bb.height/2 > 90 && bb.y + bb.height/2 < 748) { await W(250); return tap(bb.x+bb.width/2, bb.y+bb.height/2, after); }
      const dy = bb ? Math.max(-400, Math.min(400, bb.y + bb.height/2 - 420)) : 400; await scroll(dy, 10, 900); }
    console.log(await p.evaluate(()=>[...document.querySelectorAll('flt-semantics')].map(e=>e.getAttribute('aria-label')||'').filter(Boolean).join(' || ')));
    await p.screenshot({path: OUT+'/fail.png'}); throw new Error('not visible: '+txt); };
  await cdp.send('Page.startScreencast', {format:'jpeg', quality:92, everyNthFrame:1});
  await W(1200);
  mark('lang'); await tapT('O‘zbekcha', 1100);
  mark('guest'); await tapT('Mehmon sifatida', 1100);
  mark('role'); await tapT('Talaba. Tushunish', 700); await tapT('Davom etish', 1500);
  mark('home'); await scroll(300, 10, 700); await scroll(-300, 8, 300);
  mark('analytes'); await tap(124,799, 1200);
  await tapT('Glikirlangan gemoglobin', 1300); await scroll(450, 12, 1200);
  mark('learn'); await tap(337,799, 900);
  mark('toifa'); await scroll(+(process.env.SY||520), 20, 1500); await p.screenshot({path: OUT+'/chk_toifa.png'}); if (process.env.STOP) { process.exit(0); }
  await tap(195, +(process.env.TY||477), 1300);
  await tap(156,249, 600); await tapT('Mavzu bo‘yicha mashq', 1100);
  await tapT('Qon yaratilishi', 1600);
  mark('answer'); await tapT('Suyak ko‘migida', 1400); await scroll(330, 12, 2400);
  mark('lab'); await tap(195,799, 900);
  mark('atlas'); await tapT('Mikroskopiya atlasi', 1400);
  await p.screenshot({path: OUT+'/chk_atlas.png'}); await tap(195,500, 1300); await p.screenshot({path: OUT+'/chk_setup.png'}); await tap(195,588, 2600); await p.screenshot({path: OUT+'/chk_q.png'});
  mark('cell'); await tap(195,637, 3000);
  mark('end');
  await cdp.send('Page.stopScreencast'); await W(300);
  fs.writeFileSync(`${OUT}/frames.json`, JSON.stringify({frames:log, marks}));
  console.log('frames', n, 'secs', (Date.now()-t0)/1000);
  await b.close();
})();
