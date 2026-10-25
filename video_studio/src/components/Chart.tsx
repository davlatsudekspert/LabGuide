// Calibration chart: animated calibrator points, the least-squares line
// (passed in already COMPUTED by src/lib/regression.js), control read-off
// projections and a residual panel. Pure SVG, no chart library.
import React from 'react';
import {color, font} from '../design/theme';
import {fmt, fmtSigned} from '../lib/text.js';

export type ChartPoint = {x: number; y: number; id: string};
export type ChartControl = {id: string; y: number; x: number; target: number};

type Domain = {x: [number, number]; y: [number, number]; xTicks: number[]; yTicks: number[]};

export const CalibrationChart: React.FC<{
  width: number;
  height: number;
  lang: string;
  points: ChartPoint[];
  slope: number;
  intercept: number;
  domain: Domain;
  axisX: string;
  axisY: string;
  tick: number;
  axesT: number;
  pointT: number[];
  lineT: number;
  controls: ChartControl[];
  controlT: number[];
  controlLabel: (c: ChartControl) => string;
  hookId?: string;
  dimPoints?: number;
}> = (p) => {
  const ml = p.tick * 3.6;
  const mb = p.tick * 3.4;
  const mt = p.tick * 0.8;
  const mr = p.tick * 1.2;
  const iw = p.width - ml - mr;
  const ih = p.height - mt - mb;
  const sx = (x: number) => ml + ((x - p.domain.x[0]) / (p.domain.x[1] - p.domain.x[0])) * iw;
  const sy = (y: number) => mt + ih - ((y - p.domain.y[0]) / (p.domain.y[1] - p.domain.y[0])) * ih;
  const x0 = p.domain.x[0];
  const x1 = p.domain.x[1];
  const lineEnd = x0 + (x1 - x0) * p.lineT;
  const yAt = (x: number) => p.intercept + p.slope * x;
  return (
    <svg width={p.width} height={p.height} style={{overflow: 'visible'}}>
      <defs>
        <linearGradient id="fitGlow" x1="0" x2="1">
          <stop offset="0" stopColor={color.mint} stopOpacity="0.6" />
          <stop offset="1" stopColor={color.mint} stopOpacity="1" />
        </linearGradient>
        <radialGradient id="ptGlow">
          <stop offset="0" stopColor={color.beam} stopOpacity="0.55" />
          <stop offset="1" stopColor={color.beam} stopOpacity="0" />
        </radialGradient>
      </defs>
      {/* grid + ticks */}
      <g opacity={p.axesT}>
        {p.domain.yTicks.map((v) => (
          <g key={`y${v}`}>
            <line x1={ml} x2={ml + iw * p.axesT} y1={sy(v)} y2={sy(v)} stroke={color.grid} strokeWidth={2} />
            <text
              x={ml - p.tick * 0.6}
              y={sy(v) + p.tick * 0.35}
              fill={color.inkDim}
              fontFamily={font.sans}
              fontSize={p.tick}
              textAnchor="end"
              style={{fontVariantNumeric: 'tabular-nums'}}
            >
              {fmt(v, p.lang, 1)}
            </text>
          </g>
        ))}
        {p.domain.xTicks.map((v) => (
          <g key={`x${v}`}>
            <line x1={sx(v)} x2={sx(v)} y1={mt + ih} y2={mt + ih + 10} stroke={color.inkFaint} strokeWidth={2} />
            <text
              x={sx(v)}
              y={mt + ih + p.tick * 1.45}
              fill={color.inkDim}
              fontFamily={font.sans}
              fontSize={p.tick}
              textAnchor="middle"
              style={{fontVariantNumeric: 'tabular-nums'}}
            >
              {fmt(v, p.lang, Number.isInteger(v) ? 0 : 1)}
            </text>
          </g>
        ))}
        <line x1={ml} x2={ml} y1={mt + ih} y2={mt + ih - ih * p.axesT} stroke={color.inkDim} strokeWidth={3} />
        <line x1={ml} x2={ml + iw * p.axesT} y1={mt + ih} y2={mt + ih} stroke={color.inkDim} strokeWidth={3} />
        <text
          x={ml + iw / 2}
          y={mt + ih + p.tick * 2.9}
          fill={color.ink}
          fontFamily={font.sans}
          fontWeight={600}
          fontSize={p.tick * 1.05}
          textAnchor="middle"
        >
          {p.axisX}
        </text>
        <text
          transform={`translate(${p.tick * 0.9}, ${mt + ih / 2}) rotate(-90)`}
          fill={color.ink}
          fontFamily={font.sans}
          fontWeight={600}
          fontSize={p.tick * 1.05}
          textAnchor="middle"
        >
          {p.axisY}
        </text>
      </g>
      {/* fitted line (computed) */}
      {p.lineT > 0 ? (
        <g>
          <line
            x1={sx(x0)}
            y1={sy(yAt(x0))}
            x2={sx(lineEnd)}
            y2={sy(yAt(lineEnd))}
            stroke={color.mint}
            strokeOpacity={0.25}
            strokeWidth={16}
            strokeLinecap="round"
          />
          <line
            x1={sx(x0)}
            y1={sy(yAt(x0))}
            x2={sx(lineEnd)}
            y2={sy(yAt(lineEnd))}
            stroke="url(#fitGlow)"
            strokeWidth={5}
            strokeLinecap="round"
          />
        </g>
      ) : null}
      {/* calibrator points */}
      {p.points.map((pt, i) => {
        const t = p.pointT[i] ?? 0;
        if (t <= 0) return null;
        const cx = sx(pt.x);
        const cy = sy(pt.y);
        const r = p.tick * 0.42;
        return (
          <g key={pt.id} opacity={Math.min(1, t * 1.4) * (1 - (p.dimPoints ?? 0) * 0.45)}>
            <circle cx={cx} cy={cy} r={r * 3.2 * (1.6 - t * 0.6)} fill="url(#ptGlow)" opacity={1 - t * 0.5} />
            <circle cx={cx} cy={cy} r={r * Math.min(1, t * 1.25)} fill={color.beam} stroke={color.bg0} strokeWidth={4} />
            <text
              x={cx + r * 1.6}
              y={cy - r * 1.3}
              fill={color.ink}
              fontFamily={font.sans}
              fontSize={p.tick * 0.82}
              fontWeight={600}
              opacity={Math.min(1, t * 1.5)}
              style={{fontVariantNumeric: 'tabular-nums'}}
            >
              {fmt(pt.y, p.lang, 3)}
            </text>
          </g>
        );
      })}
      {/* control read-off: y axis -> line -> x axis */}
      {p.controls.map((c, i) => {
        const t = p.controlT[i] ?? 0;
        if (t <= 0) return null;
        const hook = c.id === p.hookId;
        const col = hook ? color.amber : color.coral;
        const a = Math.min(1, t * 2); // horizontal leg
        const b = Math.max(0, Math.min(1, t * 2 - 1)); // vertical leg
        const yx = sy(c.y);
        const xx = sx(c.x);
        const hx = ml + (xx - ml) * a;
        const s = p.tick * 0.5;
        return (
          <g key={c.id}>
            <path
              d={`M ${ml} ${yx - s} L ${ml + s} ${yx} L ${ml} ${yx + s} L ${ml - s} ${yx} Z`}
              fill={col}
            />
            <line x1={ml} y1={yx} x2={hx} y2={yx} stroke={col} strokeWidth={3} strokeDasharray="10 8" />
            {b > 0 ? (
              <>
                <line
                  x1={xx}
                  y1={yx}
                  x2={xx}
                  y2={yx + (mt + ih - yx) * b}
                  stroke={col}
                  strokeWidth={3}
                  strokeDasharray="10 8"
                />
                <circle cx={xx} cy={yx} r={p.tick * 0.38} fill={col} stroke={color.bg0} strokeWidth={3} />
              </>
            ) : null}
            {b >= 1 ? (
              <g>
                <rect
                  x={xx - p.tick * 2.3}
                  y={mt + ih - p.tick * 2.1}
                  width={p.tick * 4.6}
                  height={p.tick * 1.5}
                  rx={p.tick * 0.4}
                  fill={color.bg0}
                  stroke={col}
                  strokeWidth={2}
                />
                <text
                  x={xx}
                  y={mt + ih - p.tick * 1.03}
                  fill={col}
                  fontFamily={font.sans}
                  fontWeight={700}
                  fontSize={p.tick * 0.95}
                  textAnchor="middle"
                  style={{fontVariantNumeric: 'tabular-nums'}}
                >
                  {p.controlLabel(c)}
                </text>
              </g>
            ) : null}
          </g>
        );
      })}
    </svg>
  );
};

/** Residuals (measured − fitted) as lollipops around zero. */
export const ResidualPanel: React.FC<{
  width: number;
  height: number;
  lang: string;
  xs: number[];
  residuals: number[];
  xDomain: [number, number];
  tick: number;
  t: number[];
  title: string;
}> = (p) => {
  const ml = p.tick * 3.6;
  const mr = p.tick * 1.2;
  const mt = p.tick * 1.9;
  const mb = p.tick * 0.8;
  const iw = p.width - ml - mr;
  const ih = p.height - mt - mb;
  const lim = Math.max(...p.residuals.map((r) => Math.abs(r))) * 1.7;
  const sx = (x: number) => ml + ((x - p.xDomain[0]) / (p.xDomain[1] - p.xDomain[0])) * iw;
  const sy = (r: number) => mt + ih / 2 - (r / lim) * (ih / 2);
  return (
    <svg width={p.width} height={p.height} style={{overflow: 'visible'}}>
      <rect x={0} y={0} width={p.width} height={p.height} rx={24} fill={color.panel} stroke={color.line} strokeWidth={2} />
      <text x={ml - p.tick * 2.6} y={mt - p.tick * 0.7} fill={color.ink} fontFamily={font.sans} fontWeight={600} fontSize={p.tick}>
        {p.title}
      </text>
      <line x1={ml} x2={ml + iw} y1={sy(0)} y2={sy(0)} stroke={color.inkDim} strokeWidth={2} />
      <text x={ml - p.tick * 0.5} y={sy(0) + p.tick * 0.35} fill={color.inkDim} fontFamily={font.sans} fontSize={p.tick * 0.85} textAnchor="end">
        0
      </text>
      {p.residuals.map((r, i) => {
        const t = p.t[i] ?? 0;
        if (t <= 0) return null;
        const x = sx(p.xs[i]);
        const y = sy(r * t);
        const c = r >= 0 ? color.mint : color.beam;
        return (
          <g key={i}>
            <line x1={x} x2={x} y1={sy(0)} y2={y} stroke={c} strokeWidth={4} />
            <circle cx={x} cy={y} r={p.tick * 0.34} fill={c} stroke={color.bg0} strokeWidth={3} />
            <text
              x={x}
              y={r >= 0 ? y - p.tick * 0.7 : y + p.tick * 1.25}
              fill={color.ink}
              fontFamily={font.sans}
              fontSize={p.tick * 0.86}
              fontWeight={600}
              textAnchor="middle"
              opacity={t}
              style={{fontVariantNumeric: 'tabular-nums'}}
            >
              {fmtSigned(r, p.lang, 4)}
            </text>
          </g>
        );
      })}
    </svg>
  );
};
