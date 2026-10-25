// Original SCHEMATIC illustrations of blood cells (drawn in code by LabGuide
// for the video — not micrographs, always labelled "schematic illustration").
// Textbook morphology, Romanowsky-type (May–Grünwald–Giemsa) colours, sizes
// from the app's own cell guide (lib/features/differential/differential_content.dart,
// WHO 2003 §9.10.4): every cell is drawn in micrometres and scaled by `k`
// (px per µm), so a 7.5 µm red cell next to it gives a true size comparison.
//
//   segmented   12–15 µm, 2–5 lobes joined by thin chromatin strands, pale pink cytoplasm, fine mauve granules
//   band        nucleus one curved band (C/S), not divided into lobes
//   lymphocyte  small 7–10 µm, round dense nucleus, scant thin blue rim
//   monocyte    15–25 µm, folded / kidney-shaped pale nucleus, grey-blue cytoplasm, vacuoles, fine dust granules
//   eosinophil  12–15 µm, usually 2 lobes, large round densely packed orange-red granules
//   basophil    11–13 µm, very large deep-purple granules that cover the nucleus
import React from 'react';

export type CellKind = 'segmented' | 'band' | 'lymphocyte' | 'monocyte' | 'eosinophil' | 'basophil' | 'other';

export const smearColor = {
  glass: '#F6EEE9',
  glassEdge: '#E9DCD6',
  rbc: '#E3A29C',
  rbcRim: '#D48C87',
  rbcPale: '#F2CFC9',
  platelet: '#8E5DA6',
  nucleus: '#4A2468',
  nucleusLight: '#6D4C92',
  neutroCyto: '#F2D9E1',
  neutroGranule: '#B583AE',
  eosGranule: '#EA6A3C',
  eosGranuleHi: '#F59A6A',
  basoGranule: '#2F1C62',
  lymphoCyto: '#93BFE6',
  monoCyto: '#B9C5D8',
};

/** Diameters (µm) used for drawing (mid-points of the app's ranges). */
export const cellDiameter: Record<CellKind, number> = {
  segmented: 13.5,
  band: 13.5,
  lymphocyte: 8.6,
  monocyte: 18.5,
  eosinophil: 13.5,
  basophil: 12,
  other: 16,
};

// ---------------------------------------------------------------- helpers
function rng(seed: number) {
  let s = seed >>> 0 || 1;
  return () => {
    s ^= s << 13;
    s ^= s >>> 17;
    s ^= s << 5;
    return ((s >>> 0) % 100000) / 100000;
  };
}

/** Smooth irregular closed outline around (cx, cy). */
export function blob(cx: number, cy: number, rx: number, ry: number, rot: number, seed: number, wobble = 0.08, n = 28): string {
  const r = rng(seed);
  const ph = [r() * 6.28, r() * 6.28, r() * 6.28];
  const am = [wobble, wobble * 0.6, wobble * 0.35];
  const pts: [number, number][] = [];
  for (let i = 0; i < n; i++) {
    const a = (i / n) * Math.PI * 2;
    const f = 1 + am[0] * Math.sin(2 * a + ph[0]) + am[1] * Math.sin(3 * a + ph[1]) + am[2] * Math.sin(5 * a + ph[2]);
    const x = Math.cos(a) * rx * f;
    const y = Math.sin(a) * ry * f;
    const c = Math.cos(rot);
    const s = Math.sin(rot);
    pts.push([cx + x * c - y * s, cy + x * s + y * c]);
  }
  // Catmull-Rom -> cubic Bézier.
  let d = `M${pts[0][0].toFixed(2)},${pts[0][1].toFixed(2)}`;
  for (let i = 0; i < n; i++) {
    const p0 = pts[(i - 1 + n) % n];
    const p1 = pts[i];
    const p2 = pts[(i + 1) % n];
    const p3 = pts[(i + 2) % n];
    const c1 = [p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6];
    const c2 = [p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6];
    d += `C${c1[0].toFixed(2)},${c1[1].toFixed(2)} ${c2[0].toFixed(2)},${c2[1].toFixed(2)} ${p2[0].toFixed(2)},${p2[1].toFixed(2)}`;
  }
  return d + 'Z';
}

/** Points scattered inside a circle of radius R (µm), min distance dmin. */
function scatter(seed: number, R: number, count: number, dmin: number, avoid?: (x: number, y: number) => boolean) {
  const r = rng(seed);
  const out: [number, number][] = [];
  let tries = 0;
  while (out.length < count && tries < count * 60) {
    tries++;
    const a = r() * Math.PI * 2;
    const rr = Math.sqrt(r()) * R;
    const x = Math.cos(a) * rr;
    const y = Math.sin(a) * rr;
    if (avoid && avoid(x, y)) continue;
    if (out.some(([px, py]) => (px - x) ** 2 + (py - y) ** 2 < dmin * dmin)) continue;
    out.push([x, y]);
  }
  return out;
}

const Gradients: React.FC<{id: string}> = ({id}) => (
  <defs>
    <radialGradient id={`${id}-nuc`} cx="40%" cy="35%" r="75%">
      <stop offset="0%" stopColor="#6A3E8C" />
      <stop offset="70%" stopColor={smearColor.nucleus} />
      <stop offset="100%" stopColor="#371a52" />
    </radialGradient>
    <radialGradient id={`${id}-nucl`} cx="40%" cy="35%" r="80%">
      <stop offset="0%" stopColor="#8A6BAE" />
      <stop offset="80%" stopColor={smearColor.nucleusLight} />
      <stop offset="100%" stopColor="#57397a" />
    </radialGradient>
    <radialGradient id={`${id}-rbc`} cx="50%" cy="50%" r="50%">
      <stop offset="0%" stopColor="#F7E0DB" />
      <stop offset="26%" stopColor={smearColor.rbcPale} />
      <stop offset="52%" stopColor="#E9B0AA" />
      <stop offset="82%" stopColor={smearColor.rbc} />
      <stop offset="100%" stopColor={smearColor.rbcRim} />
    </radialGradient>
  </defs>
);

/** Chromatin clumps (darker patches) inside a nucleus outline. */
const Chromatin: React.FC<{seed: number; spots: [number, number, number][]; color?: string; opacity?: number}> = ({spots, color = '#2a1240', opacity = 0.28}) => (
  <g opacity={opacity}>
    {spots.map(([x, y, r], i) => (
      <circle key={i} cx={x} cy={y} r={r} fill={color} />
    ))}
  </g>
);

// ---------------------------------------------------------------- cells
type Props = {kind: CellKind; k: number; seed?: number; id: string; showRim?: boolean};

/** One leukocyte centred at (0,0) in a <g> scaled to px (k px per µm). */
export const Leukocyte: React.FC<Props> = ({kind, k, seed = 7, id}) => {
  const D = cellDiameter[kind];
  const R = D / 2;
  const r = rng(seed * 31 + 3);
  const lobeSpots = (cx: number, cy: number, rr: number, nn: number, s: number) => {
    const q = rng(s);
    return Array.from({length: nn}, () => {
      const a = q() * 6.28;
      const d = Math.sqrt(q()) * rr * 0.75;
      return [cx + Math.cos(a) * d, cy + Math.sin(a) * d, rr * (0.12 + q() * 0.18)] as [number, number, number];
    });
  };
  let body: React.ReactNode = null;
  if (kind === 'segmented' || kind === 'band') {
    const gran = scatter(seed + 11, R * 0.9, 150, 0.55);
    const cyto = (
      <>
        <path d={blob(0, 0, R, R * 0.97, r() * 3, seed + 1, 0.035)} fill={smearColor.neutroCyto} stroke="#D9B3C4" strokeWidth={0.18} />
        <g fill={smearColor.neutroGranule} opacity={0.55}>
          {gran.map(([x, y], i) => (
            <circle key={i} cx={x} cy={y} r={0.16} />
          ))}
        </g>
      </>
    );
    if (kind === 'segmented') {
      // Three lobes (2–5 in nature) joined by thin chromatin strands.
      const lobes: [number, number, number, number][] = [
        [-3.3, -1.9, 2.15, 1.75],
        [0.6, 1.6, 2.05, 1.7],
        [3.4, -1.4, 1.9, 1.65],
      ];
      body = (
        <>
          {cyto}
          <path d={`M${lobes[0][0] + 1.4},${lobes[0][1] + 0.9} Q-1.2,1.6 ${lobes[1][0] - 1.5},${lobes[1][1] - 0.3}`} stroke={smearColor.nucleus} strokeWidth={0.42} fill="none" strokeLinecap="round" />
          <path d={`M${lobes[1][0] + 1.5},${lobes[1][1] - 0.5} Q2.6,0.4 ${lobes[2][0] - 1.0},${lobes[2][1] + 1.0}`} stroke={smearColor.nucleus} strokeWidth={0.42} fill="none" strokeLinecap="round" />
          {lobes.map(([x, y, rx, ry], i) => (
            <g key={i}>
              <path d={blob(x, y, rx, ry, i * 1.1 + 0.4, seed + 20 + i, 0.09)} fill={`url(#${id}-nuc)`} />
              <Chromatin seed={i} spots={lobeSpots(x, y, Math.min(rx, ry), 7, seed + 40 + i)} />
            </g>
          ))}
        </>
      );
    } else {
      // Band: one curved, unsegmented band of roughly even width (C/U shape).
      const path = 'M-3.6,-2.6 C-5.2,1.2 -2.6,4.4 0.4,4.2 C3.4,4.0 5.0,1.4 3.9,-2.2';
      body = (
        <>
          {cyto}
          <path d={path} stroke="#371a52" strokeWidth={2.9} fill="none" strokeLinecap="round" />
          <path d={path} stroke={smearColor.nucleus} strokeWidth={2.5} fill="none" strokeLinecap="round" />
          <path d={path} stroke="#6A3E8C" strokeWidth={0.9} fill="none" strokeLinecap="round" opacity={0.45} transform="translate(-0.3,-0.3)" />
        </>
      );
    }
  } else if (kind === 'eosinophil') {
    const lobes: [number, number][] = [
      [-2.4, -0.6],
      [2.5, -0.2],
    ];
    const gran = scatter(seed + 13, R * 0.92, 210, 0.86);
    body = (
      <>
        <path d={blob(0, 0, R, R * 0.96, 0.5, seed + 1, 0.04)} fill="#F3D2C3" stroke="#E0A88F" strokeWidth={0.18} />
        <path d={`M-1.0,0.4 Q0,1.5 1.1,0.6`} stroke={smearColor.nucleus} strokeWidth={0.5} fill="none" />
        {lobes.map(([x, y], i) => (
          <path key={i} d={blob(x, y, 2.3, 1.9, i * 0.6, seed + 30 + i, 0.08)} fill={`url(#${id}-nuc)`} />
        ))}
        <g>
          {gran.map(([x, y], i) => {
            // Granules lie over the cytoplasm and partly over the nucleus edge.
            const onNuc = lobes.some(([lx, ly]) => (x - lx) ** 2 / 4.6 + (y - ly) ** 2 / 3.2 < 1);
            return (
              <g key={i} opacity={onNuc ? 0.35 : 0.95}>
                <circle cx={x} cy={y} r={0.43} fill={smearColor.eosGranule} />
                <circle cx={x - 0.12} cy={y - 0.12} r={0.17} fill={smearColor.eosGranuleHi} />
              </g>
            );
          })}
        </g>
      </>
    );
  } else if (kind === 'basophil') {
    const gran = scatter(seed + 17, R * 0.88, 70, 1.05);
    body = (
      <>
        <path d={blob(0, 0, R, R * 0.95, 1.2, seed + 1, 0.05)} fill="#D9CBE3" stroke="#B9A4CC" strokeWidth={0.18} />
        <path d={blob(-0.3, 0.2, R * 0.62, R * 0.5, 0.4, seed + 3, 0.12)} fill={`url(#${id}-nucl)`} opacity={0.75} />
        <g>
          {gran.map(([x, y], i) => {
            const q = 0.45 + ((i * 37) % 10) / 22;
            return <circle key={i} cx={x} cy={y} r={q} fill={smearColor.basoGranule} opacity={0.88} />;
          })}
        </g>
      </>
    );
  } else if (kind === 'lymphocyte') {
    body = (
      <>
        <path d={blob(0, 0, R, R * 0.97, 0.3, seed + 1, 0.04)} fill={smearColor.lymphoCyto} stroke="#78A7D3" strokeWidth={0.2} />
        <path d={blob(-0.35, 0.1, R * 0.82, R * 0.8, 0.9, seed + 2, 0.05)} fill={`url(#${id}-nuc)`} />
        <Chromatin seed={seed} spots={lobeSpots(-0.35, 0.1, R * 0.8, 14, seed + 5)} opacity={0.34} />
      </>
    );
  } else if (kind === 'monocyte') {
    const vac = scatter(seed + 19, R * 0.8, 6, 2.2, (x, y) => (x + 0.5) ** 2 / 34 + y ** 2 / 32 < 1);
    const dust = scatter(seed + 23, R * 0.9, 90, 0.7);
    // Kidney-shaped nucleus: an oval with a clear notch (hilum) on one side.
    const nuc = 'M-5.6,-1.0 C-5.9,-4.7 -1.4,-5.8 1.6,-4.6 C4.0,-3.6 4.9,-1.6 2.9,-0.3 C1.7,0.5 1.8,1.5 3.3,2.2 C5.0,3.1 3.8,5.4 0.8,5.2 C-2.9,5.0 -5.4,3.0 -5.6,-1.0Z';
    const inNuc = (x: number, y: number) => (x + 0.6) ** 2 / 20 + y ** 2 / 19 < 1 && !(x > 1.4 && y > -0.6 && y < 1.8);
    const lace = scatter(seed + 29, 5.4, 140, 0.42, (x, y) => !inNuc(x, y));
    body = (
      <>
        <path d={blob(0, 0, R, R * 0.9, 0.2, seed + 1, 0.07)} fill={smearColor.monoCyto} stroke="#93A3BC" strokeWidth={0.2} />
        <g fill="#C79AAE" opacity={0.45}>
          {dust.map(([x, y], i) => (
            <circle key={i} cx={x} cy={y} r={0.13} />
          ))}
        </g>
        <g fill="#E8EDF4" opacity={0.9}>
          {vac.map(([x, y], i) => (
            <circle key={i} cx={x} cy={y} r={0.5 + (i % 3) * 0.22} />
          ))}
        </g>
        <path d={nuc} fill={`url(#${id}-nucl)`} />
        {/* pale, lacy (strand-like) chromatin */}
        <g>
          {lace.map(([x, y], i) => (
            <circle key={i} cx={x} cy={y} r={0.2 + (i % 4) * 0.06} fill={i % 3 === 0 ? '#A991C9' : '#4f2f72'} opacity={i % 3 === 0 ? 0.5 : 0.32} />
          ))}
        </g>
      </>
    );
  } else {
    // "Other" (atypical / blast) — only a neutral placeholder, never shown as a specific cell.
    body = <path d={blob(0, 0, R, R, 0, seed, 0.05)} fill="#C8D3E6" stroke="#93A3BC" strokeWidth={0.2} />;
  }
  return (
    <g transform={`scale(${k})`}>
      <Gradients id={id} />
      {body}
    </g>
  );
};

/** Red cell (biconcave disc seen from above: paler centre), D ≈ 7.5 µm. */
export const RedCell: React.FC<{k: number; seed: number; id: string; d?: number}> = ({k, seed, id, d = 7.5}) => (
  <g transform={`scale(${k})`}>
    <path d={blob(0, 0, d / 2, (d / 2) * 0.97, seed, seed, 0.03, 18)} fill={`url(#${id}-rbc)`} />
  </g>
);

export const Platelet: React.FC<{k: number; seed: number}> = ({k, seed}) => (
  <g transform={`scale(${k})`}>
    <path d={blob(0, 0, 1.2, 0.9, seed, seed, 0.18, 14)} fill={smearColor.platelet} opacity={0.8} />
  </g>
);

/** Shared gradient defs for a field of red cells (one per SVG). */
export const SmearDefs: React.FC<{id: string}> = ({id}) => <Gradients id={id} />;

/** Standalone cell card (SVG) for galleries and thumbnails. */
export const CellPortrait: React.FC<{
  kind: CellKind;
  size: number;
  /** Diameter of the visible disc in µm (sets the scale). */
  viewUm?: number;
  seed?: number;
  withRbc?: boolean;
  id: string;
}> = ({kind, size, viewUm = 24, seed = 5, withRbc = true, id}) => {
  const k = size / viewUm;
  const c = size / 2;
  const D = cellDiameter[kind];
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{display: 'block'}}>
      <defs>
        <clipPath id={`${id}-clip`}>
          <circle cx={c} cy={c} r={c} />
        </clipPath>
        <radialGradient id={`${id}-glass`} cx="50%" cy="45%" r="60%">
          <stop offset="0%" stopColor="#FBF6F2" />
          <stop offset="100%" stopColor={smearColor.glassEdge} />
        </radialGradient>
      </defs>
      <g clipPath={`url(#${id}-clip)`}>
        <rect width={size} height={size} fill={`url(#${id}-glass)`} />
        <SmearDefs id={`${id}-f`} />
        {withRbc
          ? [205, 262, 318, 22, 150].map((deg, i) => {
              const dist = D / 2 + 4.15;
              const a = (deg * Math.PI) / 180;
              return (
                <g key={i} transform={`translate(${c + Math.cos(a) * dist * k},${c + Math.sin(a) * dist * k})`}>
                  <RedCell k={k} seed={seed + i * 3} id={`${id}-f`} />
                </g>
              );
            })
          : null}
        <g transform={`translate(${c},${c})`}>
          <Leukocyte kind={kind} k={k} seed={seed} id={`${id}-l`} />
        </g>
      </g>
    </svg>
  );
};
