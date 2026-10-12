// node record_role.js ROLE OUT_DIR dur.json — rol bo'yicha ilovani ishlatib yozadi; har gap uchun vaqt (dur+0.7 s).
const { chromium } = require('playwright');
const fs = require('fs');
const [,, ROLE, OUT, DURF] = process.argv; const DUR = JSON.parse(fs.readFileSync(DURF));
fs.mkdirSync(OUT, {recursive:true});
(async () => {
  const b = await chromium.launch();
  const ctx = await b.newContext({ viewport:{width:390,height:844}, deviceScaleFactor:3, isMobile:true, hasTouch:true, locale:'uz-UZ' });
  const p = await ctx.newPage();
  await p.goto('http://localhost:8765/', {waitUntil:'networkidle'}); await p.waitForTimeout(6000);
  await p.evaluate(() => { document.querySelector('flt-semantics-placeholder')?.click();
    const st=document.createElement('style'); st.textContent=`.tapdot{position:fixed;width:46px;height:46px;margin:-23px 0 0 -23px;border-radius:50%;background:rgba(255,255,255,.55);border:2px solid rgba(20,80,64,.6);pointer-events:none;z-index:99999;transition:transform .5s ease-out,opacity .5s ease-out}`; document.head.appendChild(st); });
  await p.waitForTimeout(800);
  const cdp = await ctx.newCDPSession(p);
  const log = []; let n = 0;
  cdp.on('Page.screencastFrame', async f => { const name=`f${String(n++).padStart(5,'0')}.jpg`; fs.writeFileSync(`${OUT}/${name}`, Buffer.from(f.data,'base64')); log.push([name, f.metadata.timestamp]); try { await cdp.send('Page.screencastFrameAck',{sessionId:f.sessionId}); } catch(e){} });
  const W = ms => p.waitForTimeout(ms);
  const dot = (x,y) => p.evaluate(([x,y]) => { const d=document.createElement('div'); d.className='tapdot'; d.style.left=x+'px'; d.style.top=y+'px'; document.body.appendChild(d); requestAnimationFrame(()=>requestAnimationFrame(()=>{d.style.transform='scale(1.6)'; d.style.opacity='0';})); setTimeout(()=>d.remove(),700); }, [x,y]);
  const tap = async (x,y,after=900) => { await dot(x,y); await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x,y}]}); await W(80); await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]}); await W(after); };
  const scroll = async (dy, after=700, speed=600) => { await cdp.send('Input.synthesizeScrollGesture', {x:340, y: dy>0?640:180, yDistance:-dy, speed, gestureSourceType:'touch', preventFling:true}); await W(after); };
  const bbox = (txt) => p.evaluate((txt) => { let best=null; for (const e of document.querySelectorAll('flt-semantics, flt-semantics *')) { const t=(e.getAttribute('aria-label')||'')+' '+(e.textContent||''); if (!t.includes(txt)) continue; const r=e.getBoundingClientRect(); if (r.width<2||r.height<2) continue; const a=r.width*r.height; if (!best||a<best.a) best={x:r.x,y:r.y,w:r.width,h:r.height,a}; } return best; }, txt);
  const fail = async (m) => { await p.screenshot({path:OUT+'/fail.png'}); throw new Error(m); };
  const tapT = async (txt, after=900) => { const bb = await bbox(txt); if (!bb) await fail('notfound '+txt); return tap(bb.x+bb.w/2, bb.y+bb.h/2, after); };
  // karta ichidagi pastki tugma (tugma yozuvi kartaga qo'shilib ketgan bo'lsa)
  const tapCardBtn = async (txt, after=1200) => { const bb = await bbox(txt); if (!bb) await fail('notfound '+txt); const y = bb.h > 120 ? bb.y + bb.h - 55 : bb.y + bb.h/2; console.log('cardbtn', txt, JSON.stringify(bb)); return tap(195, y, after); };
  const typeSlow = async (t) => { await p.keyboard.type(t, {delay:140}); await W(400); };
  const chk = (name) => p.screenshot({path:`${OUT}/chk_${name}.png`});
  const marks = [];
  const step = async (name, fn) => { const t0 = Date.now(); marks.push([name, t0/1000]); await fn(); const rest = (DUR[name]+0.7)*1000 - (Date.now()-t0); if (rest>0) await W(rest); };
  const intro = async (k1, k2, roleTxt) => {
    await step(k1, async () => { await W(Math.max(0,(DUR[k1]-1.4)*1000)); await tapT('O‘zbekcha', 600); });
    await step(k2, async () => { await W(600); await tapT('Mehmon sifatida', 900); await tapT(roleTxt, 800); await tapT('Davom etish', 800); });
  };
  await cdp.send('Page.startScreencast', {format:'jpeg', quality:92, everyNthFrame:1});
  await W(600);
  if (ROLE === 'doctor') {
    await intro('d01','d02','Shifokor. Natija');
    await step('d03', async () => { await W(1200); await chk('d03'); });
    await step('d04', async () => { await tapT('2-tip qandli diabet', 1400); await scroll(500, 900, 350); });
    await step('d05', async () => { await scroll(700, 600, 450); await scroll(550, 900, 400); await chk('d05'); });
    await step('d06', async () => { await tap(124,799, 1100); await tap(195,486, 1400); await scroll(450, 600, 400); await chk('d06'); });
    await step('d07', async () => { await tap(195,799, 1000); await tapT('Kalkulyatorlar', 1000); await tap(195,198, 1100); await tap(195,240, 500); await typeSlow('110'); await tap(195,387, 500); await typeSlow('58'); await tap(119,476, 600); await chk('d07'); });
    await step('d08', async () => { await tap(195,542, 1500); await scroll(350, 600, 350); await chk('d08'); });
    await step('d09', async () => { await tap(30,34, 800); await tap(30,34, 900); await tapT('Preanalitika', 1300); await scroll(500, 600, 350); await chk('d09'); });
  } else if (ROLE === 'lab') {
    await intro('l01','l02','Laboratoriya mutaxassisi. Metodika');
    await step('l03', async () => { await W(500); await tap(195,540, 1400); await scroll(600, 800, 400); await chk('l03'); });
    await step('l04', async () => { await tap(30,34, 900); await tapT('Leykoformula', 1300); await tap(195,570, 1200);
      for (const [x,y] of [[107,355],[107,355],[107,370],[107,370],[107,470],[282,470],[107,370],[107,470],[107,600],[107,370]]) await tap(x,y,330);
      await chk('l04'); });
    await step('l05', async () => { await tap(30,34, 800); await tap(30,34, 900); await scroll(500, 800); await tapT('Apparatlar va metodikalar', 1200); await tap(195,305, 1300); await chk('l05'); });
    await step('l06', async () => { await tap(195,330, 1200); await tap(195,180, 1500); await scroll(600, 800, 350); await chk('l06'); });
    await step('l07', async () => { for (let i=0;i<4;i++) await tap(30,34, 700); await tapT('Preanalitika', 1300); await scroll(500, 600, 350); await chk('l07'); });
    await step('l08', async () => { await tap(52,799, 1200); await scroll(1000, 1200, 500); await tapCardBtn('Tayyorgarlikni boshlash', 1400); await tap(156,249, 700); await chk('l08'); await tap(195,586, 1200); });
    await step('l09', async () => { await tap(195,502, 1600); await tap(195,333, 1500); await scroll(330, 600, 350); await chk('l09'); });
  } else if (ROLE === 'teacher') {
    await intro('t01','t02','Ustoz / tadqiqotchi');
    await step('t03', async () => { await W(900); await scroll(380, 900, 350); await scroll(-380, 400, 500); });
    marks.push(['gap', Date.now()/1000]);
    await step('t08', async () => { await tap(337,799, 1100); await scroll(1500, 900); await tapT('Ma’ruza rejimi', 1000); await tap(195,303, 2800); await tap(287,805, 1500); await tap(287,805, 1000); await chk('t08'); });
    await step('t09', async () => { await tap(30,27, 800); await tap(30,34, 900); await tapT('Dars rejasi', 1200); await tap(195,184, 600); await typeSlow('Glyukoza almashinuvi'); await chk('t09'); });
    await step('t10', async () => { await tap(30,34, 900); await tap(30,34, 400); await chk('t10a'); await tapT('Imtihon rejimi', 1200); await scroll(700, 600, 400); await chk('t10'); });
  }
  marks.push(['end', Date.now()/1000]);
  await W(400);
  await cdp.send('Page.stopScreencast'); await W(300);
  fs.writeFileSync(`${OUT}/frames.json`, JSON.stringify({frames:log, marks}));
  console.log('frames', n, JSON.stringify(marks.map(m=>[m[0], +(m[1]-marks[0][1]).toFixed(1)])));
  await b.close();
})();
