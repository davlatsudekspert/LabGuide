// Generic animated SVG plot (no chart library) for the topic videos: lines
// (computed curves), points, sticks (mass spectra), horizontal / vertical
// reference lines (mean ± SD, thresholds, Cq), shaded bands. Every number it
// draws is passed in already COMPUTED by the video's math module; the plot
// only maps data to pixels. Used by: photometry (Beer–Lambert), QC
// (Levey–Jennings), GC-MS (chromatogram, spectrum), real-time PCR
// (amplification curves), osmometry (cooling curve).
import React from 'react';
import {color, font} from '../design/theme';
import {fmt} from '../lib/text.js';

export type PlotDomain = {
  x: [number, number];
  y: [number, number];
  xTicks: number[];
  yTicks: number[];
  /** Digits for tick labels (default: 0 for integers, else 1). */
  xDigits?: number;
  yDigits?: number;
  /** Custom tick label text (e.g. "x̄ + 2SD"). */
  yLabel?: (v: number) => string;
  xLabel?: (v: number) => string;
};

type Base = {t?: number; opacity?: number};
export type PlotSeries =
  | (Base & {kind: 'line'; pts: [number, number][]; color: string; width?: number; dash?: string; glow?: boolean})
  | (Base & {
      kind: 'points';
      pts: {x: number; y: number; color?: string; r?: number; t?: number; ring?: boolean; label?: string; shape?: 'circle' | 'triangle' | 'square'}[];
      color: string;
      /** Connect consecutive points (Levey–Jennings style). */
      join?: boolean;
    })
  | (Base & {kind: 'sticks'; pts: {x: number; y: number; t?: number; label?: string}[]; color: string; width?: number})
  | (Base & {kind: 'hline'; y: number; color: string; dash?: string; width?: number; label?: string; labelColor?: string})
  | (Base & {kind: 'vline'; x: number; color: string; dash?: string; width?: number; label?: string; labelY?: number; labelAnchor?: 'start' | 'middle' | 'end'})
  | (Base & {kind: 'band'; y0: number; y1: number; color: string})
  | (Base & {kind: 'xband'; x0: number; x1: number; color: string; label?: string});

export type Scales = {sx: (x: number) => number; sy: (y: number) => number; ml: number; mt: number; iw: number; ih: number};

export const Plot: React.FC<{
  width: number;
  height: number;
  lang: string;
  domain: PlotDomain;
  axisX?: string;
  axisY?: string;
  /** Base font size for ticks / labels. */
  tick: number;
  axesT?: number;
  series: PlotSeries[];
  /** Margins in tick units (left, bottom, top, right). */
  margins?: [number, number, number, number];
  showGrid?: boolean;
  hideXTicks?: boolean;
  hideYTicks?: boolean;
  overlay?: (s: Scales) => React.ReactNode;
  idPrefix?: string;
}> = (p) => {
  const [mlU, mbU, mtU, mrU] = p.margins ?? [3.6, 3.4, 0.8, 1.2];
  const ml = p.tick * mlU;
  const mb = p.tick * mbU;
  const mt = p.tick * mtU;
  const mr = p.tick * mrU;
  const iw = p.width - ml - mr;
  const ih = p.height - mt - mb;
  const d = p.domain;
  const sx = (x: number) => ml + ((x - d.x[0]) / (d.x[1] - d.x[0])) * iw;
  const sy = (y: number) => mt + ih - ((y - d.y[0]) / (d.y[1] - d.y[0])) * ih;
  const axesT = p.axesT ?? 1;
  const id = p.idPrefix ?? 'plot';
  const dig = (v: number, n?: number) => n ?? (Number.isInteger(v) ? 0 : 1);
  const clip = (v: number) => Math.max(0, Math.min(1, v));
  const label = (x: number, y: number, s: string, c: string, anchor: 'start' | 'middle' | 'end', size = p.tick * 0.85, w = 600) => (
    <text x={x} y={y} fill={c} fontFamily={font.sans} fontWeight={w} fontSize={size} textAnchor={anchor} style={{fontVariantNumeric: 'tabular-nums'}}>
      {s}
    </text>
  );
  const parts = p.series.map((s, i) => {
    const t = clip(s.t ?? 1);
    const op = s.opacity ?? 1;
    if (t <= 0) return null;
    switch (s.kind) {
      case 'band':
        return <rect key={i} x={ml} width={iw} y={sy(s.y1)} height={sy(s.y0) - sy(s.y1)} fill={s.color} opacity={op * t} />;
      case 'xband':
        return (
          <g key={i} opacity={op * t}>
            <rect x={sx(s.x0)} width={sx(s.x1) - sx(s.x0)} y={mt} height={ih} fill={s.color} />
            {s.label ? label((sx(s.x0) + sx(s.x1)) / 2, mt + p.tick * 1.2, s.label, color.inkDim, 'middle', p.tick * 0.8) : null}
          </g>
        );
      case 'hline': {
        const y = sy(s.y);
        return (
          <g key={i} opacity={op}>
            <line x1={ml} x2={ml + iw * t} y1={y} y2={y} stroke={s.color} strokeWidth={s.width ?? 2.5} strokeDasharray={s.dash} />
            {s.label && t > 0.6 ? label(ml + iw + p.tick * 0.4, y + p.tick * 0.32, s.label, s.labelColor ?? s.color, 'start', p.tick * 0.8) : null}
          </g>
        );
      }
      case 'vline': {
        const x = sx(s.x);
        return (
          <g key={i} opacity={op}>
            <line x1={x} x2={x} y1={mt + ih} y2={mt + ih - ih * t} stroke={s.color} strokeWidth={s.width ?? 2.5} strokeDasharray={s.dash} />
            {s.label && t > 0.6 ? label(x + (s.labelAnchor === 'start' ? p.tick * 0.4 : s.labelAnchor === 'end' ? -p.tick * 0.4 : 0), s.labelY != null ? sy(s.labelY) : mt + p.tick * 0.2, s.label, s.color, s.labelAnchor ?? 'middle', p.tick * 0.85, 700) : null}
          </g>
        );
      }
      case 'line': {
        const n = s.pts.length;
        const upto = Math.max(1, Math.floor((n - 1) * t));
        const frac = (n - 1) * t - upto;
        const pts = s.pts.slice(0, upto + 1).map(([x, y]) => [sx(x), sy(y)]);
        if (upto + 1 < n && frac > 0) {
          const [x0, y0] = s.pts[upto];
          const [x1, y1] = s.pts[upto + 1];
          pts.push([sx(x0 + (x1 - x0) * frac), sy(y0 + (y1 - y0) * frac)]);
        }
        const dAttr = pts.map(([x, y], k) => `${k ? 'L' : 'M'} ${x.toFixed(1)} ${y.toFixed(1)}`).join(' ');
        return (
          <g key={i} opacity={op}>
            {s.glow ? <path d={dAttr} fill="none" stroke={s.color} strokeOpacity={0.22} strokeWidth={(s.width ?? 5) * 3.2} strokeLinecap="round" strokeLinejoin="round" /> : null}
            <path d={dAttr} fill="none" stroke={s.color} strokeWidth={s.width ?? 5} strokeDasharray={s.dash} strokeLinecap="round" strokeLinejoin="round" />
          </g>
        );
      }
      case 'sticks':
        return (
          <g key={i} opacity={op}>
            {s.pts.map((q, k) => {
              const tt = clip(q.t ?? t);
              if (tt <= 0) return null;
              const y = sy(d.y[0] + (q.y - d.y[0]) * tt);
              return (
                <g key={k}>
                  <line x1={sx(q.x)} x2={sx(q.x)} y1={sy(d.y[0])} y2={y} stroke={s.color} strokeWidth={s.width ?? 7} strokeLinecap="butt" />
                  {q.label && tt > 0.8 ? label(sx(q.x), y - p.tick * 0.45, q.label, color.ink, 'middle', p.tick * 0.78, 700) : null}
                </g>
              );
            })}
          </g>
        );
      case 'points': {
        const vis = s.pts.filter((q) => clip(q.t ?? t) > 0);
        return (
          <g key={i} opacity={op}>
            {s.join && vis.length > 1 ? (
              <path
                d={vis.map((q, k) => `${k ? 'L' : 'M'} ${sx(q.x).toFixed(1)} ${sy(q.y).toFixed(1)}`).join(' ')}
                fill="none"
                stroke={s.color}
                strokeOpacity={0.55}
                strokeWidth={3}
              />
            ) : null}
            {vis.map((q, k) => {
              const tt = clip(q.t ?? t);
              const r = (q.r ?? p.tick * 0.36) * Math.min(1, tt * 1.3);
              const c = q.color ?? s.color;
              return (
                <g key={k}>
                  {q.ring ? <circle cx={sx(q.x)} cy={sy(q.y)} r={r * 2.4} fill="none" stroke={c} strokeWidth={3} opacity={0.9 * tt} /> : null}
                  {q.shape === 'triangle' ? (
                    <path
                      d={`M ${sx(q.x)} ${sy(q.y) - r * 1.35} L ${sx(q.x) + r * 1.25} ${sy(q.y) + r * 0.85} L ${sx(q.x) - r * 1.25} ${sy(q.y) + r * 0.85} Z`}
                      fill={c}
                      stroke={color.bg0}
                      strokeWidth={3}
                    />
                  ) : q.shape === 'square' ? (
                    <rect x={sx(q.x) - r * 1.05} y={sy(q.y) - r * 1.05} width={r * 2.1} height={r * 2.1} rx={r * 0.2} fill={c} stroke={color.bg0} strokeWidth={3} />
                  ) : (
                    <circle cx={sx(q.x)} cy={sy(q.y)} r={r} fill={c} stroke={color.bg0} strokeWidth={3} />
                  )}
                  {q.label ? label(sx(q.x), sy(q.y) - r - p.tick * 0.4, q.label, c, 'middle', p.tick * 0.8, 700) : null}
                </g>
              );
            })}
          </g>
        );
      }
      default:
        return null;
    }
  });
  return (
    <svg width={p.width} height={p.height} style={{overflow: 'visible'}}>
      <defs>
        <clipPath id={`${id}-clip`}>
          <rect x={ml} y={mt - 4} width={iw + 4} height={ih + 8} />
        </clipPath>
      </defs>
      <g opacity={axesT}>
        {p.showGrid === false
          ? null
          : d.yTicks.map((v) => (
              <line key={`g${v}`} x1={ml} x2={ml + iw * axesT} y1={sy(v)} y2={sy(v)} stroke={color.grid} strokeWidth={2} />
            ))}
        {p.hideYTicks
          ? null
          : d.yTicks.map((v) => (
              <g key={`y${v}`}>{label(ml - p.tick * 0.6, sy(v) + p.tick * 0.35, d.yLabel ? d.yLabel(v) : fmt(v, p.lang, dig(v, d.yDigits)), color.inkDim, 'end', p.tick, 500)}</g>
            ))}
        {p.hideXTicks
          ? null
          : d.xTicks.map((v) => (
              <g key={`x${v}`}>
                <line x1={sx(v)} x2={sx(v)} y1={mt + ih} y2={mt + ih + 10} stroke={color.inkFaint} strokeWidth={2} />
                {label(sx(v), mt + ih + p.tick * 1.45, d.xLabel ? d.xLabel(v) : fmt(v, p.lang, dig(v, d.xDigits)), color.inkDim, 'middle', p.tick, 500)}
              </g>
            ))}
        <line x1={ml} x2={ml} y1={mt + ih} y2={mt + ih - ih * axesT} stroke={color.inkDim} strokeWidth={3} />
        <line x1={ml} x2={ml + iw * axesT} y1={mt + ih} y2={mt + ih} stroke={color.inkDim} strokeWidth={3} />
        {p.axisX ? label(ml + iw / 2, mt + ih + p.tick * (p.hideXTicks ? 1.6 : 2.9), p.axisX, color.ink, 'middle', p.tick * 1.05) : null}
        {p.axisY ? (
          <text
            transform={`translate(${ml - p.tick * (p.hideYTicks ? 0.9 : mlU - 0.9)}, ${mt + ih / 2}) rotate(-90)`}
            fill={color.ink}
            fontFamily={font.sans}
            fontWeight={600}
            fontSize={p.tick * 1.05}
            textAnchor="middle"
          >
            {p.axisY}
          </text>
        ) : null}
      </g>
      <g clipPath={`url(#${id}-clip)`}>{parts.filter((_, i) => ['line', 'band', 'xband'].includes(p.series[i].kind))}</g>
      {parts.filter((_, i) => !['line', 'band', 'xband'].includes(p.series[i].kind))}
      {p.overlay ? p.overlay({sx, sy, ml, mt, iw, ih}) : null}
    </svg>
  );
};
