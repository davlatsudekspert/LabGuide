/*
 * Real vaqt PCR namunaviy animatsiyasi (docs/video/lessons/04_real_time_pcr.md,
 * SAMPLES.md). Faqat darslik/manba darajasidagi tamoyil: probirkalarni
 * termoblokka qo'yish, sikl bosqichlari (qizdirish — ajralish, sovutish —
 * praymer birikishi, sintez), har siklda ~2 barobar ko'payish, har siklda
 * fluoressensiyani o'lchash, kuchayish egri chiziqlari, chegara va Cq.
 * Harorat, vaqt, sikl soni va Cq qiymatlari KO'RSATILMAYDI; egri chiziqlar —
 * shartli rasm. Koordinatalar — gen.py `real_time_pcr()` sahnasi.
 * Signal yo'li (ilmiy ko'rik F2, 2026-10-25): manba -> qo'zg'atish filtri ->
 * termoblokdagi probirka -> nurlanish filtri -> detektor; manba turi, filtr
 * tuzilishi va o'qish yo'nalishi ko'rsatilmaydi (sxematik).
 */
window.LESSON = (() => {
  const CYC = 3.2, PH = [1.0, 1.0, 1.2];            // bitta sikl va bosqichlari (animatsiya vaqti, s)
  const PHC = ['#D9604F', '#5B8FD0', '#E3B93C'];     // qizdirish, sovutish, sintez
  const CH = ['#5B8FD0', '#6FCF7F', '#E3B93C', '#D9604F'];
  const CURVES = [[0.42, '#C5E8A1'], [0.52, '#7FB3C8'], [0.62, '#E3B93C'], [0.74, '#D98BA6']];
  let S, L;
  const ease = (x) => { x = Math.max(0, Math.min(1, x)); return x < .5 ? 2 * x * x : 1 - Math.pow(-2 * x + 2, 2) / 2; };

  function phaseAt(c) {          // c — siklning ichidagi vaqt
    if (c < PH[0]) return [0, c / PH[0]];
    if (c < PH[0] + PH[1]) return [1, (c - PH[0]) / PH[1]];
    return [2, (c - PH[0] - PH[1]) / PH[2]];
  }
  function sig(x, c) { return 1 / (1 + Math.exp(-(x - c) / 0.035)); }

  return {
    setup(ctx) {
      const { el, overlay: o, inset: g, DATA, LANG } = ctx;
      L = (k) => DATA.inset[k][LANG];
      S = {};
      // probirkalar qatorining "arvohi" (stoldan termoblokka)
      S.ghost = el('g', { opacity: 0 }, o);
      for (let i = 0; i < 8; i++) {
        const x = i * 26;
        el('path', { d: `M${x} -54 H${x + 20} V -24 L${x + 13} 0 H${x + 7} L${x} -24 Z`, fill: '#F6F8F6', stroke: '#AFC3B8', 'stroke-width': 1.5 }, S.ghost);
        el('path', { d: `M${x + 3} -28 H${x + 17} L${x + 12} -6 H${x + 8} Z`, fill: ['#F3D9E1', '#E4EEF4'][i % 2] }, S.ghost);
        el('rect', { x: x - 1, y: -64, width: 22, height: 12, rx: 4, fill: '#E8EDEA', stroke: '#AFC3B8', 'stroke-width': 1.5 }, S.ghost);
      }
      S.wells = [];
      const t = 1.5 / 4, yy = 372 + 44 * t, x0 = 438 - 18 * t, x1 = 772 + 18 * t;
      for (let c = 2; c < 10; c++) {
        const x = x0 + 10 + (x1 - x0 - 20) * c / 11;
        S.wells.push(el('ellipse', { cx: x, cy: yy, rx: 9, ry: 4.5, fill: ['#F3D9E1', '#E4EEF4'][c % 2], opacity: 0 }, o));
      }
      S.wellX0 = x0 + 10 + (x1 - x0 - 20) * 2 / 11; S.wellY = yy;
      S.tint = el('path', { d: 'M418 420 L436 368 H774 L792 420 Z', fill: PHC[0], opacity: 0 }, o);
      // optika: manba -> qo'zg'atish filtri -> probirka -> nurlanish filtri -> detektor
      S.glow = el('circle', { cx: 446, cy: 600, r: 18, fill: '#9CC3EC', opacity: 0 }, o);
      S.beam = el('line', { x1: 452, y1: 600, x2: 525, y2: 602, 'stroke-width': 5, 'stroke-dasharray': '6 6', opacity: 0 }, o);
      S.exf = el('rect', { x: 461, y: 582, width: 9, height: 36, rx: 2, opacity: 0 }, o);
      S.tube = el('circle', { cx: 532, cy: 604, r: 11, opacity: 0 }, o);
      S.emit = el('path', { d: 'M540 588 L 610 520', fill: 'none', 'stroke-width': 5, 'stroke-dasharray': '6 6', opacity: 0 }, o);
      S.emf = el('rect', { x: 565, y: 544, width: 9, height: 34, rx: 2, transform: 'rotate(45 569.5 561)', opacity: 0 }, o);
      S.flash = el('circle', { cx: 612, cy: 503, r: 12, fill: '#FFF2B0', opacity: 0 }, o);

      // pastki panel: (a) sikl profili va nusxalar, (b) kuchayish egri chiziqlari
      S.prof = el('g', {}, g);
      const tt = el('text', { x: 24, y: 34, fill: '#CFE7DA', 'font-size': 18, 'font-weight': 600 }, S.prof);
      tt.textContent = L('profile');
      S.steps = [];
      const lv = [76, 142, 112];
      let d = '';
      for (let k = 0; k < 3; k++) {
        for (let p = 0; p < 3; p++) {
          const xa = 40 + k * 200 + [0, 60, 120][p], xb = xa + [60, 60, 80][p];
          d += `${k || p ? 'L' : 'M'}${xa} ${lv[p]} H${xb} `;
          S.steps.push(el('line', { x1: xa, x2: xb, y1: lv[p], y2: lv[p], stroke: PHC[p], 'stroke-width': 7, 'stroke-linecap': 'round', opacity: 0.35 }, S.prof));
        }
      }
      el('path', { d, fill: 'none', stroke: '#6E8F84', 'stroke-width': 1.5 }, S.prof);
      S.cursor = el('circle', { r: 8, fill: '#FFFFFF' }, S.prof);
      S.plab = ['den', 'ann', 'ext'].map((k, p) => {
        const e = el('text', { x: 240 + [30, 90, 160][p], y: [64, 166, 100][p], fill: PHC[p], 'font-size': 15, 'font-weight': 700, 'text-anchor': 'middle' }, S.prof);
        e.textContent = L(k);
        return e;
      });
      S.copyT = el('text', { x: 24, y: 300, fill: '#9FB8AE', 'font-size': 15 }, S.prof);
      S.copyT.textContent = L('copies');
      S.dna = [];
      for (let k = 0; k < 16; k++) {
        const x = 40 + (k % 8) * 78, y = 204 + Math.floor(k / 8) * 44;
        const grp = el('g', { transform: `translate(${x},${y})`, opacity: 0 }, S.prof);
        const a = el('line', { x1: 0, x2: 56, y1: 0, y2: 0, stroke: '#7FB3C8', 'stroke-width': 4, 'stroke-linecap': 'round' }, grp);
        const b = el('line', { x1: 0, x2: 56, y1: 6, y2: 6, stroke: '#7FB3C8', 'stroke-width': 4, 'stroke-linecap': 'round' }, grp);
        const pa = el('line', { x1: 0, x2: 0, y1: 0, y2: 0, stroke: '#E3B93C', 'stroke-width': 4, 'stroke-linecap': 'round' }, grp);
        const pb = el('line', { x1: 56, x2: 56, y1: 6, y2: 6, stroke: '#E3B93C', 'stroke-width': 4, 'stroke-linecap': 'round' }, grp);
        S.dna.push({ grp, a, b, pa, pb });
      }
      S.amp = el('g', { opacity: 0 }, g);
      const at = el('text', { x: 24, y: 34, fill: '#CFE7DA', 'font-size': 17, 'font-weight': 600 }, S.amp);
      at.textContent = L('amp');
      el('path', { d: 'M56 62 V 270 H 640', fill: 'none', stroke: '#6E8F84', 'stroke-width': 2 }, S.amp);
      const xl = el('text', { x: 640, y: 300, fill: '#9FB8AE', 'font-size': 16, 'text-anchor': 'end' }, S.amp);
      xl.textContent = L('cycle');
      const yl = el('text', { fill: '#9FB8AE', 'font-size': 16, 'text-anchor': 'middle', transform: 'translate(32,166) rotate(-90)' }, S.amp);
      yl.textContent = L('fluo');
      S.thr = el('g', { opacity: 0 }, S.amp);
      el('line', { x1: 56, x2: 640, y1: 228, y2: 228, stroke: '#E3B93C', 'stroke-width': 2, 'stroke-dasharray': '8 6' }, S.thr);
      const tl = el('text', { x: 636, y: 220, fill: '#E3B93C', 'font-size': 14, 'text-anchor': 'end' }, S.thr);
      tl.textContent = L('thr');
      S.neg = el('path', { fill: 'none', stroke: '#8FA39B', 'stroke-width': 2.5 }, S.amp);
      S.curves = CURVES.map(([, c]) => el('path', { fill: 'none', stroke: c, 'stroke-width': 3.5 }, S.amp));
      S.cq = CURVES.map(([cx, c], k) => {
        const grp = el('g', { opacity: 0 }, S.amp);
        // chegara (y=228) kesishgan nuqta: 270-200*sig = 228 → sig = 0.21
        const x = 56 + 584 * (cx + 0.035 * Math.log(0.21 / 0.79));
        el('line', { x1: x, x2: x, y1: 228, y2: 270, stroke: c, 'stroke-width': 2, 'stroke-dasharray': '3 4' }, grp);
        el('circle', { cx: x, cy: 228, r: 5, fill: c }, grp);
        if (k === 0) {
          const e = el('text', { x: x, y: 290, fill: c, 'font-size': 15, 'font-weight': 700, 'text-anchor': 'middle' }, grp);
          e.textContent = 'Cq';
        }
        return grp;
      });
    },

    frame(t, i, u, ctx) {
      const { DATA, clamp } = ctx;
      const sc = DATA.scenes;
      const at = (k) => t - sc[k].t0;
      const show = (e, v) => e.setAttribute('opacity', v);

      // 3: probirkalar termoblokka
      const u2 = at(2);
      const mp = ease((u2 - 3.2) / 2.6);
      const dx = S.wellX0 - 10 - 124, dy = S.wellY + 6 - 640;
      const lift = -110 * Math.sin(Math.PI * mp);
      const sx = 1 + 0.145 * mp;
      S.ghost.setAttribute('transform', `translate(${(124 + dx * mp).toFixed(1)},${(640 + dy * mp + lift).toFixed(1)}) scale(${sx.toFixed(3)},${(1 - 0.35 * mp).toFixed(3)})`);
      show(S.ghost, i === 2 && u2 > 3.0 ? clamp((u2 - 3.0) / 0.3) * (1 - clamp((u2 - 6.2) / 0.6)) : 0);
      const wl = i >= 2 ? (i > 2 ? 1 : clamp((u2 - 5.9) / 0.5)) : 0;
      S.wells.forEach((w) => show(w, wl * 0.95));

      // 4-5: termik sikllar (blok rangi)
      const cyc0 = sc[3].t0;
      const tc = t - cyc0;
      const ncyc = Math.floor(Math.max(0, tc) / CYC);
      const [ph, pf] = phaseAt(((tc % CYC) + CYC) % CYC);
      show(S.tint, i === 3 || i === 4 ? 0.42 : 0);
      S.tint.setAttribute('fill', PHC[ph]);

      // 5: optika — har sikl oxirida o'qish (sintez bosqichi oxiri)
      const opt = i === 4;
      const read = ph === 2 && pf > 0.55 ? Math.sin(Math.PI * (pf - 0.55) / 0.45) : 0;
      const ch = ncyc % 4;
      // qo'zg'atish filtri har siklda keyingi rang kanaliga o'tadi (tuzilishi ko'rsatilmaydi)
      show(S.exf, opt ? 0.45 + 0.55 * read : 0);
      S.exf.setAttribute('fill', CH[ch]);
      show(S.tube, opt ? read * 0.85 : 0);
      S.tube.setAttribute('fill', CH[ch]);
      show(S.emf, opt ? 0.35 + 0.65 * read : 0);
      S.emf.setAttribute('fill', CH[ch]);
      show(S.glow, opt ? 0.25 + 0.6 * read : 0);
      S.glow.setAttribute('r', (16 + 8 * read).toFixed(1));
      show(S.beam, opt ? read : 0);
      S.beam.setAttribute('stroke', '#9CC3EC');
      S.beam.setAttribute('stroke-dashoffset', (-t * 50).toFixed(1));
      show(S.emit, opt ? read : 0);
      S.emit.setAttribute('stroke', CH[ch]);
      S.emit.setAttribute('stroke-dashoffset', (-t * 50).toFixed(1));
      show(S.flash, opt ? read * 0.9 : 0);

      // pastki panel
      const profOn = i === 3;
      show(S.prof, profOn ? 1 : 0);
      const ampOn = i !== 3 ? 1 : 0;
      show(S.amp, ampOn);
      if (profOn) {
        const live = i === 3;
        const k = 3 + ph;                                  // o'rta sikl bosqichlari
        S.steps.forEach((s, j) => s.setAttribute('opacity', live && j === k ? 1 : 0.35));
        S.plab.forEach((e, p) => e.setAttribute('opacity', !live || p === ph ? 1 : 0.35));
        const xs = [0, 60, 120][ph], w = [60, 60, 80][ph];
        S.cursor.setAttribute('cx', (240 + xs + w * pf).toFixed(1));
        S.cursor.setAttribute('cy', [76, 142, 112][ph]);
        show(S.cursor, live ? 1 : 0);
        const n = live ? Math.min(16, Math.pow(2, ncyc)) : 1;
        const newN = Math.min(16, n * 2);
        S.dna.forEach((d, j) => {
          const exist = j < n, born = j >= n && j < newN;
          let op = exist ? 1 : 0, gap = 6, pa = 0, pb = 0;
          if (live && exist) {
            if (ph === 0) gap = 6 + 14 * ease(pf);
            else gap = 20;
            if (ph === 1) { pa = 14 * ease(pf); pb = pa; }
            if (ph === 2) { pa = 14 + 42 * ease(pf); pb = pa; }
          }
          if (live && born && ph === 2 && pf > 0.85) op = (pf - 0.85) / 0.15;
          show(d.grp, op);
          d.b.setAttribute('y1', gap); d.b.setAttribute('y2', gap);
          d.pa.setAttribute('x2', pa.toFixed(1));
          d.pb.setAttribute('y1', gap); d.pb.setAttribute('y2', gap);
          d.pb.setAttribute('x1', 56); d.pb.setAttribute('x2', (56 - pb).toFixed(1));
          d.pa.setAttribute('y1', gap / 2 - 3); d.pa.setAttribute('y2', gap / 2 - 3);
          d.pb.setAttribute('y1', gap / 2 + 3); d.pb.setAttribute('y2', gap / 2 + 3);
          show(d.pa, live && exist && ph >= 1 ? 1 : 0);
          show(d.pb, live && exist && ph >= 1 ? 1 : 0);
        });
      }
      if (ampOn) {
        const u4 = at(4), u5 = at(5);
        const P = i < 3 ? 0 : i === 4 ? 0.35 + 0.43 * (u4 / sc[4].dur) : 0.78 + 0.22 * clamp(u5 / 4);
        const path = (fn) => {
          let d = '';
          for (let k = 0; k <= 160; k++) {
            const x = k / 160;
            if (x > P) break;
            d += (k ? 'L' : 'M') + (56 + 584 * x).toFixed(1) + ' ' + (270 - 200 * fn(x)).toFixed(1) + ' ';
          }
          return d || 'M56 270';
        };
        S.curves.forEach((e, k) => e.setAttribute('d', path((x) => 0.01 + 0.96 * sig(x, CURVES[k][0]))));
        S.neg.setAttribute('d', path((x) => 0.012 + 0.006 * Math.sin(x * 40)));
        show(S.thr, i === 5 ? clamp((u5 - 2.5) / 0.6) : 0);
        S.cq.forEach((e, k) => show(e, i === 5 ? clamp((u5 - 4.5 - k * 0.5) / 0.4) : 0));
      }
    },
  };
})();
