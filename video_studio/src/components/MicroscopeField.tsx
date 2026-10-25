// A microscope field of view over a procedurally generated stained blood
// film (SCHEMATIC illustration, drawn in code). The film is a monolayer: red
// cells (7.5 µm) on a jittered hexagonal grid so they touch but do not
// overlap, a few platelets, and leukocytes placed by the caller. Moving the
// stage = moving `center` (µm, world coordinates); cells themselves never
// move (a fixed smear). Optional eyepiece reticle (crosshair + scale).
import React from 'react';
import {Leukocyte, Platelet, RedCell, SmearDefs, cellDiameter, smearColor, type CellKind} from './Cells';

export type WorldWbc = {id: string; x: number; y: number; kind: CellKind; seed: number};

const PITCH = 8.1; // µm between red-cell centres (touching, not overlapping)
const ROW = PITCH * 0.866;

function hash(i: number, j: number, s = 0) {
  let h = (i * 374761393 + j * 668265263 + s * 2147483647) | 0;
  h = Math.imul(h ^ (h >>> 13), 1274126177);
  h ^= h >>> 16;
  return (h >>> 0) / 4294967295;
}

/** Red cells and platelets inside the window around `center` (world µm). */
export function fieldItems(center: [number, number], viewUm: number, wbcs: WorldWbc[], density = 1) {
  const half = viewUm / 2 + 6;
  const [wx, wy] = center;
  const near = wbcs.filter((w) => Math.abs(w.x - wx) < half + 14 && Math.abs(w.y - wy) < half + 14);
  const rbcs: {x: number; y: number; d: number; i: number; j: number}[] = [];
  const platelets: {x: number; y: number; i: number; j: number}[] = [];
  const j0 = Math.floor((wy - half) / ROW);
  const j1 = Math.ceil((wy + half) / ROW);
  for (let j = j0; j <= j1; j++) {
    const off = (j & 1) * PITCH * 0.5;
    const i0 = Math.floor((wx - half - off) / PITCH);
    const i1 = Math.ceil((wx + half - off) / PITCH);
    for (let i = i0; i <= i1; i++) {
      if (hash(i, j, 3) > 0.93 * density) continue; // small gaps, as in a real monolayer
      const x = i * PITCH + off + (hash(i, j, 1) - 0.5) * 1.3;
      const y = j * ROW + (hash(i, j, 2) - 0.5) * 1.3;
      if (Math.abs(x - wx) > half || Math.abs(y - wy) > half) continue;
      if (near.some((w) => (w.x - x) ** 2 + (w.y - y) ** 2 < (cellDiameter[w.kind] / 2 + 3.4) ** 2)) continue;
      rbcs.push({x, y, d: 7.1 + hash(i, j, 4) * 0.8, i, j});
      // Platelets sit in the small gaps between red cells.
      if (hash(i, j, 5) > 0.955) platelets.push({x: x + PITCH * 0.5, y: y + ROW * 0.55, i, j});
    }
  }
  return {rbcs, platelets, near};
}

export type FieldProps = {
  /** Diameter of the circular field on canvas (px). */
  size: number;
  /** Width of the field of view in µm. */
  viewUm: number;
  /** World position (µm) at the centre of the field. */
  center: [number, number];
  wbcs: WorldWbc[];
  reticle?: boolean;
  /** Highlight rings on leukocytes: id -> {t 0..1, color}. */
  rings?: Record<string, {t: number; color: string}>;
  /** 0 = sharp; >0 px of blur (fast stage movement / focus). */
  blur?: number;
  id: string;
  /** Holes in the red-cell layer (cells removed), e.g. to declutter. */
  density?: number;
};

export const MicroscopeField: React.FC<FieldProps> = ({size, viewUm, center, wbcs, reticle = true, rings = {}, blur = 0, id, density = 1}) => {
  const k = size / viewUm;
  const c = size / 2;
  const half = viewUm / 2 + 6;
  const [wx, wy] = center;
  const near = wbcs.filter((w) => Math.abs(w.x - wx) < half + 14 && Math.abs(w.y - wy) < half + 14);
  const items = fieldItems(center, viewUm, wbcs, density);
  const rbcs = items.rbcs.map((r) => (
    <g key={`r${r.i}_${r.j}`} transform={`translate(${c + (r.x - wx) * k},${c + (r.y - wy) * k})`}>
      <RedCell k={k} seed={(r.i * 7 + r.j * 13) & 1023} id={`${id}-d`} d={r.d} />
    </g>
  ));
  const plts = items.platelets.map((p) => (
    <g key={`p${p.i}_${p.j}`} transform={`translate(${c + (p.x - wx) * k},${c + (p.y - wy) * k})`}>
      <Platelet k={k} seed={p.i * 3 + p.j} />
    </g>
  ));
  const tick = (n: number) => {
    const out: React.ReactNode[] = [];
    const len = size * 0.42;
    for (let q = -n; q <= n; q++) {
      const x = c + (q / n) * len;
      const h = q % 5 === 0 ? size * 0.028 : size * 0.016;
      out.push(<line key={q} x1={x} y1={c - h} x2={x} y2={c + h} />);
    }
    return out;
  };
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{display: 'block', overflow: 'visible'}}>
      <defs>
        <clipPath id={`${id}-clip`}>
          <circle cx={c} cy={c} r={c} />
        </clipPath>
        <radialGradient id={`${id}-light`} cx="48%" cy="44%" r="58%">
          <stop offset="0%" stopColor="#FFFAF5" />
          <stop offset="70%" stopColor={smearColor.glass} />
          <stop offset="100%" stopColor="#E2D2CB" />
        </radialGradient>
        <radialGradient id={`${id}-vig`} cx="50%" cy="50%" r="50%">
          <stop offset="78%" stopColor="#000" stopOpacity={0} />
          <stop offset="96%" stopColor="#000" stopOpacity={0.35} />
          <stop offset="100%" stopColor="#000" stopOpacity={0.75} />
        </radialGradient>
        <filter id={`${id}-blur`} x="-5%" y="-5%" width="110%" height="110%">
          <feGaussianBlur stdDeviation={blur} />
        </filter>
      </defs>
      <circle cx={c} cy={c} r={c + size * 0.035} fill="#060C0A" />
      <g clipPath={`url(#${id}-clip)`}>
        <rect width={size} height={size} fill={`url(#${id}-light)`} />
        <SmearDefs id={`${id}-d`} />
        <g filter={blur > 0.05 ? `url(#${id}-blur)` : undefined}>
          {rbcs}
          {plts}
          {near.map((w) => (
            <g key={w.id} transform={`translate(${c + (w.x - wx) * k},${c + (w.y - wy) * k})`}>
              <Leukocyte kind={w.kind} k={k} seed={w.seed} id={`${id}-${w.id}`} />
            </g>
          ))}
        </g>
        {near.map((w) => {
          const ring = rings[w.id];
          if (!ring || ring.t <= 0) return null;
          const rr = (cellDiameter[w.kind] / 2 + 1.6) * k * (1.25 - 0.25 * ring.t);
          return (
            <circle
              key={`ring-${w.id}`}
              cx={c + (w.x - wx) * k}
              cy={c + (w.y - wy) * k}
              r={rr}
              fill="none"
              stroke={ring.color}
              strokeWidth={Math.max(3, size * 0.007)}
              opacity={ring.t}
              strokeDasharray={`${rr * 0.5} ${rr * 0.18}`}
            />
          );
        })}
        {reticle ? (
          <g stroke="#1B2A26" strokeOpacity={0.55} strokeWidth={Math.max(1.5, size * 0.0022)} fill="none">
            <line x1={c} y1={size * 0.06} x2={c} y2={size * 0.94} />
            <line x1={size * 0.06} y1={c} x2={size * 0.94} y2={c} />
            <circle cx={c} cy={c} r={size * 0.16} strokeDasharray="6 8" />
            {tick(20)}
          </g>
        ) : null}
        <rect width={size} height={size} fill={`url(#${id}-vig)`} />
      </g>
      <circle cx={c} cy={c} r={c} fill="none" stroke="rgba(255,255,255,0.10)" strokeWidth={2} />
    </svg>
  );
};

/** Leukocytes along a battlement track: long passes along x, short steps in y. */
export function trackWorld(kinds: CellKind[], spacing = 46, pass = 8, step = 34): {wbcs: WorldWbc[]; at: (s: number) => [number, number]; length: number} {
  // Path: pass `pass*spacing` µm to the right, step down `step`, pass left… (battlement / meander)
  const passLen = pass * spacing;
  const at = (s: number): [number, number] => {
    const seg = passLen + step;
    const n = Math.floor(s / seg);
    const r = s - n * seg;
    const dir = n % 2 === 0 ? 1 : -1;
    const x0 = n % 2 === 0 ? 0 : passLen;
    if (r <= passLen) return [x0 + dir * r, n * step];
    return [n % 2 === 0 ? passLen : 0, n * step + (r - passLen)];
  };
  const wbcs = kinds.map((kind, i) => {
    const s = 20 + i * spacing;
    const [x, y] = at(s);
    const jy = (hash(i, 7, 9) - 0.5) * 6;
    return {id: `w${i}`, x, y: y + jy, kind, seed: 11 + i * 17};
  });
  return {wbcs, at, length: 20 + kinds.length * spacing};
}
