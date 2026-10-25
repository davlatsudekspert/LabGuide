/*
 * GC-MS namunaviy animatsiyasi (docs/video/lessons/01_gc_ms.md, SAMPLES.md).
 * Faqat darslik darajasidagi tamoyil: tashuvchi gaz oqimi, injeksiya va
 * bug'lanish, kolonkada ajralish (ushlanish vaqti), ionlanish, kvadrupolda
 * m/z bo'yicha saralash, detektor signali, xromatogramma va spektr.
 * Raqamli qiymat (harorat, vaqt, m/z, kuchlanish) ko'rsatilmaydi; egri
 * chiziqlar — shartli rasm. Koordinatalar — gen.py `mass_spec_gc()` sahnasi
 * (overlay sxemaning o'z `transform`i ichida).
 */
window.LESSON = (() => {
  const COL = ['#E3B93C', '#D98BA6', '#7FB3C8'];
  const EXIT = [5.0, 7.6, 10.2];          // kolonkadan chiqish (4-sahna ichidagi soniya)
  const PEAK_H = [0.78, 0.52, 0.95], PEAK_W = [0.22, 0.3, 0.38];
  const rnd = (i) => { const x = Math.sin(i * 127.1 + 311.7) * 43758.5453; return x - Math.floor(x); };
  let S, L;

  function spiral(s) {
    const th = -2.3 + s * 6.2 * 2 * Math.PI;
    const rx = 82 - 18 * s, ry = 64 - 18 * s;
    return [345 + rx * Math.cos(th), 512 + ry * Math.sin(th)];
  }
  function along(pts, s) {           // siniq chiziq bo'ylab nuqta
    const seg = [];
    let tot = 0;
    for (let i = 1; i < pts.length; i++) {
      const d = Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]);
      seg.push(d); tot += d;
    }
    let r = Math.max(0, Math.min(1, s)) * tot;
    for (let i = 0; i < seg.length; i++) {
      if (r <= seg[i] || i === seg.length - 1) {
        const f = seg[i] ? Math.min(1, r / seg[i]) : 0;
        return [pts[i][0] + (pts[i + 1][0] - pts[i][0]) * f, pts[i][1] + (pts[i + 1][1] - pts[i][1]) * f];
      }
      r -= seg[i];
    }
    return pts[pts.length - 1];
  }
  const INLET = [[269, 364], [267, 438], [290, 470]];
  const OUTLET = [[409, 480], [424, 470], [458, 470], [482, 469], [600, 469]];
  const WIRE = [[908, 469], [948, 469], [960, 410], [1080, 410], [1080, 360]];

  function chromPath(X0, X1, upto) {
    const Y0 = 270, Y1 = 64, n = 220;
    let d = '';
    for (let k = 0; k <= n; k++) {
      const tt = 12.6 * k / n;
      if (tt > upto) break;
      let v = 0.015 * Math.sin(k * 1.7) * Math.sin(k * 0.31);
      for (let j = 0; j < 3; j++) v += PEAK_H[j] * Math.exp(-0.5 * Math.pow((tt - EXIT[j] - 0.4) / PEAK_W[j], 2));
      d += (k ? 'L' : 'M') + (X0 + (X1 - X0) * k / n).toFixed(1) + ' ' + (Y0 - (Y1 - Y0) * -v).toFixed(1) + ' ';
    }
    return d || 'M0 0';
  }

  return {
    setup(ctx) {
      const { el, overlay: o, inset, DATA, LANG } = ctx;
      L = (k) => DATA.inset[k][LANG];
      S = {};
      S.gas = el('path', { d: 'M142 300 H 204 V 357 H 254', fill: 'none', stroke: '#7FB3C8', 'stroke-width': 5,
        'stroke-dasharray': '8 14', 'stroke-linecap': 'round', opacity: 0 }, o);
      S.liq = el('rect', { x: 264, y: 250, width: 6, height: 60, rx: 2, fill: '#9CC3EC', opacity: 0 }, o);
      S.drop = el('circle', { r: 4.5, fill: '#9CC3EC', opacity: 0 }, o);
      S.cloud = el('g', { opacity: 0 }, o);
      for (let k = 0; k < 6; k++) el('circle', { cx: (rnd(k) - .5) * 22, cy: (rnd(k + 9) - .5) * 14, r: 6 + rnd(k + 3) * 5, fill: '#D9E4DE' }, S.cloud);
      S.bands = COL.map((c) => {
        const g = el('g', { opacity: 0 }, o);
        for (let k = 0; k < 7; k++) el('circle', { r: 8.5 - k * 0.7, fill: c, opacity: 1 - k * 0.12 }, g);
        return g;
      });
      // ion manbai: elektronlar, neytral molekulalar va bo'laklar
      S.elec = el('g', { opacity: 0 }, o);
      for (let k = 0; k < 6; k++) el('circle', { r: 2.6, fill: '#FFFFFF' }, S.elec);
      S.eLabel = el('text', { x: 606, y: 430, fill: '#FFFFFF', 'font-size': 13, 'font-weight': 700, opacity: 0 }, o);
      S.eLabel.textContent = 'e−';
      S.mol = [0, 1, 2].map((j) => el('circle', { r: 8, fill: 'none', stroke: COL[0], 'stroke-width': 3, opacity: 0 }, o));
      S.frag = [];
      for (let k = 0; k < 12; k++) {
        const g = el('g', { opacity: 0 }, o);
        el('circle', { r: 4.2, fill: COL[k % 3] }, g);
        const tx = el('text', { x: 3, y: -4, fill: '#FFFFFF', 'font-size': 9, 'font-weight': 700 }, g);
        tx.textContent = '+';
        S.frag.push(g);
      }
      // kvadrupol ionlari
      S.ions = [];
      for (let k = 0; k < 40; k++) S.ions.push(el('circle', { r: 5.4, fill: COL[k % 3], opacity: 0 }, o));
      S.leg = el('g', { opacity: 0 }, o);
      el('rect', { x: 724, y: 510, width: 130, height: 22, rx: 11, fill: '#0E2420', stroke: '#6E7B74', 'stroke-width': 1 }, S.leg);
      S.legDot = el('circle', { cx: 840, cy: 521, r: 6, fill: COL[0] }, S.leg);
      const lt = el('text', { x: 734, y: 526, fill: '#E4EAE6', 'font-size': 12, 'font-weight': 600 }, S.leg);
      lt.textContent = L('pass');
      S.flash = el('circle', { cx: 872, cy: 469, r: 10, fill: '#FFF2B0', opacity: 0 }, o);
      S.pulse = el('circle', { r: 6, fill: '#C5E8A1', opacity: 0 }, o);

      // pastki panel: xromatogramma -> spektr
      const g = inset;
      S.t1 = el('text', { x: 24, y: 34, fill: '#CFE7DA', 'font-size': 18, 'font-weight': 600 }, g);
      S.axes = el('path', { d: '', fill: 'none', stroke: '#6E8F84', 'stroke-width': 2 }, g);
      S.trace = el('path', { d: '', fill: 'none', stroke: '#C5E8A1', 'stroke-width': 3, 'stroke-linejoin': 'round' }, g);
      S.sel = el('rect', { y: 56, height: 216, fill: '#E88C30', opacity: 0 }, g);
      S.xl = el('text', { y: 300, fill: '#9FB8AE', 'font-size': 16, 'font-weight': 500, 'text-anchor': 'end' }, g);
      S.yl = el('text', { fill: '#9FB8AE', 'font-size': 16, 'font-weight': 500, 'text-anchor': 'middle' }, g);
      S.spec = el('g', { opacity: 0 }, g);
      S.t2 = el('text', { x: 372, y: 34, fill: '#CFE7DA', 'font-size': 16, 'font-weight': 600 }, S.spec);
      S.t2.textContent = L('spec');
      el('path', { d: 'M372 180 H 650 M372 62 V 278', fill: 'none', stroke: '#6E8F84', 'stroke-width': 2 }, S.spec);
      const mz = el('text', { x: 650, y: 200, fill: '#9FB8AE', 'font-size': 15, 'text-anchor': 'end' }, S.spec);
      mz.textContent = L('mz');
      const it = el('text', { x: 380, y: 58, fill: '#9FB8AE', 'font-size': 14 }, S.spec);
      it.textContent = L('int');
      S.libT = el('text', { x: 380, y: 300, fill: '#9FB8AE', 'font-size': 13, opacity: 0 }, S.spec);
      S.libT.textContent = L('lib');
      S.sticks = []; S.lib = [];
      const H = [0.35, 0.9, 0.25, 0.55, 1.0, 0.3, 0.62, 0.18, 0.45];
      for (let k = 0; k < H.length; k++) {
        const x = 392 + k * 30 + (rnd(k) - .5) * 10;
        S.sticks.push([el('line', { x1: x, x2: x, y1: 180, y2: 180, stroke: '#C5E8A1', 'stroke-width': 5 }, S.spec), H[k]]);
        S.lib.push([el('line', { x1: x, x2: x, y1: 180, y2: 180, stroke: '#7FB3C8', 'stroke-width': 5, opacity: 0.8 }, S.spec),
          Math.max(0.12, H[k] + (rnd(k + 20) - .5) * 0.12)]);
      }
    },

    frame(t, i, u, ctx) {
      const { DATA, clamp, ease } = ctx;
      const sc = DATA.scenes;
      const at = (k) => t - sc[k].t0;           // k-sahna boshidan o'tgan vaqt
      const show = (e, v) => e.setAttribute('opacity', v);
      const pos = (e, p) => { e.setAttribute('transform', `translate(${p[0].toFixed(1)},${p[1].toFixed(1)})`); };

      // 3-4: tashuvchi gaz oqimi
      const gasOn = i >= 3 && i <= 4;
      show(S.gas, gasOn ? 0.9 : 0);
      S.gas.setAttribute('stroke-dashoffset', (-t * 40).toFixed(1));

      // 3: injeksiya
      const u3 = at(3);
      const inj = i === 3;
      show(S.liq, inj ? 1 : 0);
      const lvl = 1 - 0.6 * ease((u3 - 0.8) / 2);
      S.liq.setAttribute('y', (250 + 60 * (1 - lvl)).toFixed(1));
      S.liq.setAttribute('height', (60 * lvl).toFixed(1));
      const dp = clamp((u3 - 2.2) / 1.4);
      show(S.drop, inj && dp > 0 && dp < 1 ? 1 : 0);
      S.drop.setAttribute('cx', 267 + 2 * dp);
      S.drop.setAttribute('cy', 314 + 43 * dp);
      const cp = clamp((u3 - 3.6) / 1.2), mv = clamp((u3 - 5.2) / 3.2);
      show(S.cloud, inj && cp > 0 ? Math.min(1, cp) * 0.95 : 0);
      const cpos = along(INLET, ease(mv));
      S.cloud.setAttribute('transform', `translate(${cpos[0].toFixed(1)},${cpos[1].toFixed(1)}) scale(${(0.4 + 0.6 * cp).toFixed(2)})`);

      // 4: kolonkada ajralish; 5: uzatish liniyasi
      const u4 = at(4);
      S.bands.forEach((g, j) => {
        let vis = 0;
        if (i === 4 || (i === 5 && j === 0)) {
          const p = u4 / EXIT[j];
          if (p >= 0 && p <= 1) {
            vis = 1;
            const spread = 0.004 + 0.012 * p;
            [...g.children].forEach((c, k) => {
              const q = spiral(Math.max(0, p - k * spread));
              c.setAttribute('cx', q[0].toFixed(1)); c.setAttribute('cy', q[1].toFixed(1));
            });
          } else if (p > 1) {
            const q = (u4 - EXIT[j]) / 2.6;
            vis = q < 1 ? 1 : 0;
            [...g.children].forEach((c, k) => {
              const pt = along(OUTLET, q - k * 0.02);
              c.setAttribute('cx', pt[0].toFixed(1)); c.setAttribute('cy', pt[1].toFixed(1));
            });
          }
        }
        show(g, vis);
      });

      // 5: ion manbai
      const u5 = at(5);
      const src = i === 5;
      show(S.elec, src && u5 > 1.5 ? 1 : 0);
      show(S.eLabel, src && u5 > 1.5 ? 1 : 0);
      [...S.elec.children].forEach((c, k) => {
        const y = 438 + ((u5 * 60 + k * 9) % 54);
        c.setAttribute('cx', 618 + k * 6); c.setAttribute('cy', y.toFixed(1));
      });
      S.mol.forEach((m, j) => {
        const t0 = 0.5 + j * 1.6, q = (u5 - t0) / 1.6;
        const p = along([[482, 469], [600, 469], [631, 466]], q);
        show(m, src && q > 0 && q < 1 ? 1 : 0);
        m.setAttribute('cx', p[0].toFixed(1)); m.setAttribute('cy', p[1].toFixed(1));
      });
      S.frag.forEach((f, k) => {
        const j = Math.floor(k / 4), t0 = 0.5 + j * 1.6 + 1.6, q = (u5 - t0) / 2.2;
        const ang = (k % 4 - 1.5) * 0.35;
        const x = 631 + q * 80, y = 466 + Math.sin(ang) * 22 * Math.min(1, q * 2) * (1 - q * 0.8);
        show(f, src && q > 0 && q < 1 ? 1 - Math.max(0, q - 0.8) * 5 : 0);
        pos(f, [x, y]);
      });

      // 6-7: kvadrupol va detektor
      const quad = i === 6 || i === 7;
      const u6 = t - sc[6].t0;
      const sel = Math.floor(Math.max(0, u6) / 3) % 3;
      show(S.leg, quad ? 1 : 0);
      S.legDot.setAttribute('fill', COL[sel]);
      let flash = 0;
      S.ions.forEach((e, k) => {
        const born = k * 0.48, age = u6 - born;
        const cyc = Math.floor(age / 19.2);
        const a = age - cyc * 19.2;
        if (!quad || age < 0 || a > 3.2) { show(e, 0); return; }
        const x = 664 + a * 70;
        const c = (k + cyc * 2 + (rnd(k) > 0.5 ? 1 : 0)) % 3;
        e.setAttribute('fill', COL[c]);
        const tin = born + cyc * 19.2 + (716 - 664) / 70;
        const passes = c === Math.floor(Math.max(0, tin) / 3) % 3;
        let y = 469 + 3 * Math.sin(a * 9 + k), op = 1;
        if (x > 716 && !passes) {
          const amp = (x - 716) * 0.42;
          y = 469 + amp * Math.sin((x - 716) / 9 + k);
          if (Math.abs(y - 469) > 22) op = Math.max(0, 1 - (Math.abs(y - 469) - 22) / 6);
          if (x > 800) op = 0;
        }
        if (passes && x >= 862) { op = 0; flash = Math.max(flash, 1 - (x - 862) / 30); }
        e.setAttribute('cx', Math.min(x, 870).toFixed(1)); e.setAttribute('cy', y.toFixed(1));
        show(e, op);
      });
      show(S.flash, quad ? clamp(flash) * 0.9 : 0);
      S.flash.setAttribute('r', (8 + 10 * clamp(flash)).toFixed(1));
      const u7 = at(7);
      const pp = (u7 % 1.2) / 1.2;
      show(S.pulse, i === 7 ? 1 - Math.max(0, pp - 0.85) * 6 : 0);
      const pw = along(WIRE, pp);
      S.pulse.setAttribute('cx', pw[0].toFixed(1)); S.pulse.setAttribute('cy', pw[1].toFixed(1));

      // pastki panel
      const u8 = at(8);
      const split = i === 8 ? ease(u8 / 1.2) : 0;
      const X0 = 56, X1 = 640 - (640 - 330) * split;
      S.axes.setAttribute('d', `M${X0} 62 V 270 H ${X1}`);
      const upto = i < 4 ? -1 : i === 4 ? u4 : 99;
      S.trace.setAttribute('d', chromPath(X0, X1, upto));
      S.t1.textContent = split > 0.5 ? L('chromShort') : L('chrom');
      S.t1.setAttribute('font-size', split > 0.5 ? 15 : 18);
      S.xl.textContent = L('time'); S.xl.setAttribute('x', X1);
      S.yl.textContent = L('signal');
      S.yl.setAttribute('transform', `translate(32,166) rotate(-90)`);
      const selOn = i === 8 && u8 > 1.2;
      const px = X0 + (X1 - X0) * (EXIT[2] + 0.4) / 12.6;
      S.sel.setAttribute('x', (px - 9).toFixed(1)); S.sel.setAttribute('width', 18);
      show(S.sel, selOn ? 0.28 : 0);
      show(S.spec, i === 8 ? clamp((u8 - 1.0) / 0.5) : 0);
      S.sticks.forEach(([e, h], k) => {
        const g = ease((u8 - 1.6 - k * 0.12) / 0.6);
        e.setAttribute('y2', (180 - 112 * h * g).toFixed(1));
      });
      show(S.libT, i === 8 && u8 > 6 ? 1 : 0);
      S.lib.forEach(([e, h], k) => {
        const g = ease((u8 - 6.4 - k * 0.12) / 0.6);
        e.setAttribute('y2', (180 + 88 * h * g).toFixed(1));
      });
    },
  };
})();
