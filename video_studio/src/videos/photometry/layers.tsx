// Visual layers of the topic video "Spectrophotometry". Pure functions of
// (scene, ctx, frame); vertical and horizontal from the same component;
// language only changes text and the real app frames. Every number comes
// from ctx.math (src/lib/photometry.js) — nothing typed in.
// Reused: OpticalBench + Cuvette (calibration flagship), Plot (generic),
// PhoneShotsLayer (generic real app screens), CtaLayer (calibration).
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, pop, rise} from '../../components/anim';
import {Badge, Pill, SceneHeader} from '../../components/Basics';
import {isV, txt, useT} from '../../components/layerKit';
import {Cuvette, OpticalBench} from '../../components/OpticalBench';
import {PhoneShotsLayer} from '../../components/PhoneShots';
import {Plot, type PlotSeries} from '../../components/Plot';
import {color, font, tabular} from '../../design/theme';
import type {Layer} from '../../framework/types';
import {fill, fmt} from '../../lib/text.js';
import {CtaLayer} from '../calibration/layers';

// ------------------------------------------------------------------ hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui, lang, math} = ctx;
  const vertical = isV(ctx);
  const A = math.high.abs as number;
  const A0 = math.standard.abs as number;
  // The reading climbs from the standard's absorbance to the sample's.
  const roll = easeIO(frame, 0, 20);
  const shown = A0 + (A - A0) * roll;
  const benchA = 0.4 + (A - 0.4) * roll;
  const std = ease(frame, 14, 12);
  const q = pop(frame, fps, cue(1));
  const qPulse = 1 + 0.07 * Math.sin(frame / 4) * q;
  const number = (
    <div style={{...txt(m.display, 700, color.white), ...tabular, letterSpacing: -6, lineHeight: 1}}>{fmt(shown, lang, 2)}</div>
  );
  const label = (
    <div style={{...txt(m.kicker, 700, color.amber), letterSpacing: m.kicker * 0.16, textTransform: 'uppercase'}}>{ui.hookLabel} · A</div>
  );
  const stdChip = (
    <div style={{opacity: std, transform: `translateY(${(1 - std) * 16}px)`}}>
      <Pill text={fill(ui.hookStd, ctx.vars)} size={m.small} tone="mint" />
    </div>
  );
  const question = (
    <div style={{...txt(m.h1, 700, color.coral), opacity: q, transform: `scale(${(0.9 + 0.1 * q) * qPulse})`, transformOrigin: vertical ? 'center' : 'left center', textWrap: 'balance' as never}}>
      {ui.hookQuestion}
    </div>
  );
  const badge = (
    <div style={{opacity: ease(frame, 16, 12)}}>
      <Badge text={ui.illustrative} tone="amber" size={m.small * 0.8} />
    </div>
  );
  const bench = <OpticalBench width={vertical ? 940 : 860} absorbance={benchA} beamT={0.5 + 0.5 * ease(frame, 0, 14)} lang={lang} showReadout={false} minimal />;
  if (vertical) {
    return (
      <AbsoluteFill>
        <div style={{position: 'absolute', left: 70, top: 250}}>{bench}</div>
        <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 660, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 28, textAlign: 'center'}}>
          {label}
          {number}
          {stdChip}
          <div style={{height: 8}} />
          {question}
          <div style={{height: 24}} />
          {badge}
        </div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 90, top: 330}}>{bench}</div>
      <div style={{position: 'absolute', left: 1040, right: m.gutter, top: 220, display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 24}}>
        {label}
        {number}
        {stdChip}
        <div style={{height: 6}} />
        {question}
        <div style={{height: 14}} />
        {badge}
      </div>
    </AbsoluteFill>
  );
};

// ----------------------------------------------------------- light path
export const LightPathLayer: Layer = ({scene, ctx}) => {
  const {frame, cue, dur} = useT(scene);
  const {m, ui, lang} = ctx;
  const vertical = isV(ctx);
  // Two consecutive scenes share this layer (continuous): "beam" (light
  // travels, L03) then "abs" (formula + absorbance rising, L04).
  const absPhase = scene.props?.phase === 'abs';
  const A = absPhase ? 0.1 + 0.7 * easeIO(frame, cue(0), Math.max(30, dur - cue(0) - 20)) : 0.1;
  const T = Math.pow(10, -A);
  const beamT = absPhase ? 1 : ease(frame, 0, 30);
  const f = absPhase ? ease(frame, cue(0), 14) : 0;
  const barW = vertical ? 600 : 380;
  const bars = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 18, opacity: f}}>
      {[
        {k: ui.incident, w: 1},
        {k: ui.transmitted, w: T},
      ].map((b) => (
        <div key={b.k} style={{display: 'flex', alignItems: 'center', gap: 18}}>
          <div style={{width: vertical ? 170 : 140, ...txt(m.body * 0.9, 700, color.inkDim)}}>{b.k}</div>
          <div style={{width: barW, height: 26, borderRadius: 13, background: color.panelStrong}}>
            <div style={{width: barW * b.w, height: 26, borderRadius: 13, background: color.beam, opacity: 0.4 + 0.6 * b.w}} />
          </div>
        </div>
      ))}
      <div style={{display: 'flex', gap: 30, marginTop: 8, ...txt(m.body, 600, color.ink), ...tabular, justifyContent: vertical ? 'center' : 'flex-start'}}>
        <span>{`I / I₀ = ${fmt(T, lang, 2)}`}</span>
        <span style={{color: color.mint}}>{`A = ${fmt(A, lang, 3)}`}</span>
      </div>
    </div>
  );
  const formula = <div style={{opacity: f, ...txt(vertical ? 66 : 58, 700, color.mint), letterSpacing: -0.5}}>A = log₁₀(I₀ / I)</div>;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerLight} badge={{text: ui.principleNote}} delay={absPhase ? -60 : 0} />
      <div style={{position: 'absolute', left: vertical ? 50 : 90, top: vertical ? 470 : 300}}>
        <OpticalBench
          width={vertical ? 980 : 1080}
          absorbance={A}
          beamT={beamT}
          lang={lang}
          labels={{lamp: ui.lamp, filter: ui.filter, cuvette: ui.cuvette, detector: ui.detector}}
          labelSize={vertical ? 34 : 30}
        />
      </div>
      <div style={{position: 'absolute', left: vertical ? m.gutter : 1250, right: m.gutter, top: vertical ? 1010 : 330, display: 'flex', flexDirection: 'column', gap: 40, alignItems: vertical ? 'center' : 'flex-start'}}>
        {formula}
        {bars}
      </div>
      {!absPhase ? (
        <div style={{position: 'absolute', left: vertical ? 0 : 1250, right: vertical ? 0 : m.gutter, top: vertical ? 1040 : 360, display: 'flex', justifyContent: vertical ? 'center' : 'flex-start', opacity: ease(frame, 20, 14)}}>
          <Pill text={ui.oneWl} size={vertical ? 46 : 40} tone="mint" />
        </div>
      ) : null}
    </AbsoluteFill>
  );
};

// --------------------------------------------------------------- ladder
export const LadderLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd} = useT(scene);
  const {m, ui, lang, math} = ctx;
  const vertical = isV(ctx);
  const rows = math.ladder as {A: number; T: number; pct: number}[];
  const span = Math.max(fps * 2, cueEnd(0) - cue(0));
  const starts = rows.map((_, i) => cue(0) - 6 + Math.round((span * i) / rows.length));
  const cur = Math.max(0, starts.filter((s) => frame >= s).length - 1);
  const benchA = rows[cur].A + (cur > 0 ? 0 : 0);
  const barW = vertical ? 520 : 640;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerLadder} badge={{text: ui.principleNote}} />
      <div style={{position: 'absolute', left: vertical ? 70 : 120, top: vertical ? 330 : 260}}>
        <OpticalBench width={vertical ? 940 : 700} absorbance={benchA} beamT={1} lang={lang} showReadout minimal />
      </div>
      <div
        style={{
          position: 'absolute',
          left: vertical ? m.gutter : 930,
          right: m.gutter,
          top: vertical ? 760 : 250,
          display: 'flex',
          flexDirection: 'column',
          gap: vertical ? 34 : 30,
        }}
      >
        {rows.map((r, i) => {
          const t = ease(frame, starts[i], 12);
          const active = i === cur;
          return (
            <div key={r.A} style={{display: 'flex', alignItems: 'center', gap: 22, opacity: 0.15 + 0.85 * t * (active ? 1 : 0.7), transform: `translateY(${(1 - t) * 16}px)`}}>
              <div style={{width: vertical ? 190 : 170, ...txt(m.body * 1.05, 700, active ? color.mint : color.ink), ...tabular}}>{`A = ${fmt(r.A, lang, r.A === Math.round(r.A) ? 0 : 1)}`}</div>
              <div style={{width: barW, height: 30, borderRadius: 15, background: color.panelStrong, overflow: 'hidden'}}>
                <div style={{width: Math.max(4, barW * r.T * t), height: 30, background: color.beam, opacity: 0.45 + 0.55 * r.T}} />
              </div>
              <div style={{...txt(m.body, 700, active ? color.ink : color.inkDim), ...tabular, whiteSpace: 'nowrap'}}>{`${fmt(r.pct, lang, 0)} %`}</div>
            </div>
          );
        })}
        <div style={{...txt(m.small, 600, color.inkDim), marginTop: 6, opacity: ease(frame, starts[1] ?? 0, 12)}}>
          {'I / I₀ = 10'}
          <sup>−A</sup>
          {` · ${ui.passes}`}
        </div>
      </div>
    </AbsoluteFill>
  );
};

// ---------------------------------------------------------- Beer–Lambert
export const BeerLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui, lang, math} = ctx;
  const vertical = isV(ctx);
  const lim = math.limit as number;
  const curve = math.curve as [number, number][];
  const inside = curve.filter(([c]) => c <= lim + 1e-9);
  const beyond = curve.filter(([c]) => c >= lim - 1e-9);
  const k = math.k as number;
  const xMax = math.chart.xMax as number;
  const t1 = easeIO(frame, cue(0), Math.round(2.2 * fps));
  const t2 = easeIO(frame, cue(1), Math.round(1.6 * fps));
  const ideal = ease(frame, cue(1) - 4, 12);
  const hi = math.high;
  const gapT = ease(frame, cue(1) + Math.round(1.4 * fps), 14);
  const series: PlotSeries[] = [
    {kind: 'xband', x0: 0, x1: lim, color: color.mintSoft, label: ui.linearRange, t: ease(frame, 6, 14), opacity: 0.8},
    {kind: 'line', pts: [[0, 0], [xMax, k * xMax]], color: color.inkDim, width: 3, dash: '10 10', t: ideal, opacity: 0.9},
    {kind: 'line', pts: inside, color: color.mint, width: 6, glow: true, t: t1},
    {kind: 'line', pts: beyond, color: color.coral, width: 6, glow: true, t: t2},
    {kind: 'vline', x: lim, color: color.amber, dash: '8 8', t: ease(frame, cue(1), 12), label: ui.limitLabel, labelY: math.chart.yMax * 0.06, labelAnchor: 'start'},
    {kind: 'points', color: color.beam, pts: [{x: math.standard.conc, y: math.standard.abs, t: ease(frame, cue(0) + 20, 10)}]},
    {kind: 'points', color: color.coral, pts: [{x: hi.trueConc, y: hi.abs, t: gapT, ring: true}]},
  ];
  const W = vertical ? 960 : 1060;
  const H = vertical ? 820 : 700;
  const tick = vertical ? 30 : 24;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerBeer} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: vertical ? 60 : 90, top: vertical ? 420 : 190}}>
        <Plot
          width={W}
          height={H}
          lang={lang}
          tick={tick}
          domain={{x: [0, xMax], y: [0, math.chart.yMax], xTicks: [0, 10, 20, 30, 40, 50], yTicks: [0, 0.5, 1, 1.5, 2]}}
          axisX={ui.axisX}
          axisY={ui.axisY}
          axesT={ease(frame, 0, 16)}
          series={series}
          idPrefix={`beer-${ctx.format}`}
          overlay={({sx, sy}) =>
            gapT > 0 ? (
              <g opacity={gapT}>
                <line x1={sx(hi.trueConc)} x2={sx(hi.trueConc)} y1={sy(k * hi.trueConc)} y2={sy(hi.abs)} stroke={color.coral} strokeWidth={4} strokeDasharray="6 6" />
                <circle cx={sx(hi.trueConc)} cy={sy(k * hi.trueConc)} r={tick * 0.3} fill="none" stroke={color.inkDim} strokeWidth={3} />
                <text x={sx(hi.trueConc) - tick * 0.9} y={sy(k * hi.trueConc) - tick * 0.5} fill={color.coral} fontFamily={font.sans} fontWeight={700} fontSize={tick * 0.95} textAnchor="end" style={{fontVariantNumeric: 'tabular-nums'}}>
                  {`${ui.reading}: A ${fmt(hi.abs, lang, 2)}`}
                </text>
              </g>
            ) : null
          }
        />
      </div>
      <div style={{position: 'absolute', left: vertical ? 190 : 1230, top: vertical ? 520 : 300, opacity: ease(frame, cue(0) + 10, 14)}}>
        <Pill text={ui.beerFormula} size={vertical ? 46 : 46} tone="mint" />
      </div>
      <div style={{position: 'absolute', left: vertical ? m.gutter : 1230, right: m.gutter, top: vertical ? 1300 : 420, display: 'flex', flexDirection: 'column', gap: 18, alignItems: vertical ? 'center' : 'flex-start'}}>
        <div style={{opacity: ease(frame, cue(1) + 8, 12)}}>
          <Badge text={ui.limitNote} tone="amber" size={m.small * 0.85} />
        </div>
      </div>
    </AbsoluteFill>
  );
};

// ------------------------------------------------ blank · standard · sample
const Reading: React.FC<{label: string; a: number | null; note: string; lang: string; size: number; t: number; tone: string}> = ({label, a, note, lang, size, t, tone}) => (
  <div style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, textAlign: 'center'}}>
    <div style={{...txt(size, 700, color.ink)}}>{label}</div>
    <div style={{...txt(size * 1.15, 700, color.beam), ...tabular, opacity: t}}>{a == null ? '—' : `A ${fmt(a, lang, 3)}`}</div>
    <div style={{...txt(size * 0.72, 600, tone), opacity: t, whiteSpace: 'nowrap'}}>{note}</div>
  </div>
);

export const BssLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd} = useT(scene);
  const {m, ui, lang, math, vars} = ctx;
  const vertical = isV(ctx);
  const span = Math.max(fps * 2, cueEnd(0) - cue(0));
  const cells = [
    {key: 'blank', label: ui.blank, a: 0, cuvA: 0.02, note: ui.zeroSet, tone: color.inkDim},
    {key: 'standard', label: ui.standard, a: math.standard.abs, cuvA: math.standard.abs, note: fill(ui.known, vars), tone: color.mint},
    {key: 'sample', label: ui.sample, a: math.sample.abs, cuvA: math.sample.abs, note: ui.unknown, tone: color.amber},
  ];
  const starts = cells.map((_, i) => cue(0) + Math.round((span * (i + 0.3)) / 3));
  const cw = vertical ? 170 : 116;
  const gap = vertical ? 110 : 150;
  const total = 3 * cw + 2 * gap;
  const x0 = (m.w - total) / 2 - (vertical ? 0 : 0);
  const top = vertical ? 430 : 170;
  const f = ease(frame, cue(1), 14);
  const res = ease(frame, cue(1) + Math.round(1.2 * fps), 14);
  const formula = (
    <div style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16, opacity: f}}>
      <div style={{...txt(m.small, 600, color.inkDim)}}>{ui.calcLabel}</div>
      <div style={{...txt(vertical ? 60 : 58, 700, color.ink), ...tabular, whiteSpace: 'nowrap'}}>
        {`C = ${fmt(math.standard.abs === 0 ? 0 : math.sample.abs, lang, 3)} ÷ ${fmt(math.standard.abs, lang, 3)} × ${fmt(math.standard.conc, lang, 1)}`}
      </div>
      <div style={{...txt(vertical ? 84 : 76, 700, color.mint), ...tabular, opacity: res, transform: `scale(${0.92 + 0.08 * res})`}}>{`= ${fmt(math.sample.conc, lang, 2)} ${ui.unit}`}</div>
      <div style={{...txt(m.small * 0.8, 500, color.inkFaint), opacity: res}}>{ui.computed}</div>
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerBss} badge={{text: ui.illustrative, tone: 'amber'}} />
      {cells.map((c, i) => {
        const appear = pop(frame, fps, i * 4);
        const lit = frame >= starts[i] && frame < starts[i] + 26 ? Math.sin(((frame - starts[i]) / 26) * Math.PI) : 0;
        const t = ease(frame, starts[i] + 10, 10);
        const x = x0 + i * (cw + gap);
        return (
          <div key={c.key} style={{position: 'absolute', left: x - 75, width: cw + 150, top, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 22, opacity: appear}}>
            <Cuvette width={cw} absorbance={c.cuvA} lit={lit} />
            <Reading label={c.label} a={c.a} note={c.note} lang={lang} size={m.body} t={t} tone={c.tone} />
          </div>
        );
      })}
      <div style={{position: 'absolute', left: 0, right: 0, top: vertical ? 1010 : 580, display: 'flex', justifyContent: 'center'}}>{formula}</div>
    </AbsoluteFill>
  );
};

// --------------------------------------------------------------- dilute
export const DiluteLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui, lang, math, vars} = ctx;
  const vertical = isV(ctx);
  const hi = math.high;
  const a = ease(frame, 4, 14);
  const bad = ease(frame, Math.round(0.9 * fps), 12);
  const b = ease(frame, cue(0) + Math.round(1.4 * fps), 14);
  const res = ease(frame, cue(0) + Math.round(2.6 * fps), 14);
  const cw = vertical ? 150 : 140;
  const col = (kind: 'direct' | 'diluted') => {
    const direct = kind === 'direct';
    const t = direct ? a : b;
    const verdict = direct ? bad : res;
    const c = direct ? color.coral : color.mint;
    return (
      <div style={{display: 'flex', alignItems: 'center', gap: 36, opacity: t, transform: `translateY(${(1 - t) * 20}px)`}}>
        <Cuvette width={cw} absorbance={direct ? hi.abs : hi.dilAbs} lit={0} />
        <div style={{display: 'flex', flexDirection: 'column', gap: 12}}>
          <div style={{...txt(m.body, 700, color.ink)}}>{direct ? ui.direct : fill(ui.diluted, vars)}</div>
          <div style={{...txt(vertical ? 52 : 50, 700, color.beam), ...tabular, whiteSpace: 'nowrap'}}>
            {direct
              ? `A ${fmt(hi.abs, lang, 3)} → ${fmt(hi.direct, lang, 1)}`
              : `A ${fmt(hi.dilAbs, lang, 3)} → ${fmt(hi.dilConc, lang, 2)} ${fill(ui.times, vars)}`}
          </div>
          {direct ? null : (
            <div style={{...txt(vertical ? 70 : 64, 700, color.mint), ...tabular, opacity: res}}>{`= ${fmt(hi.result, lang, 1)} ${ui.unit}`}</div>
          )}
          <div style={{display: 'flex', alignItems: 'center', gap: 12, opacity: verdict, ...txt(m.small, 700, c)}}>
            <span style={{fontSize: m.small * 1.3}}>{direct ? '✗' : '✓'}</span>
            {direct ? ui.outside : ui.inside}
          </div>
        </div>
      </div>
    );
  };
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerDilute} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div
        style={{
          position: 'absolute',
          left: vertical ? m.gutter : m.gutter,
          right: m.gutter,
          top: vertical ? 420 : 300,
          display: 'flex',
          flexDirection: vertical ? 'column' : 'row',
          gap: vertical ? 90 : 120,
          justifyContent: 'center',
        }}
      >
        {col('direct')}
        {col('diluted')}
      </div>
      <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: vertical ? 1320 : 800, display: 'flex', justifyContent: 'center', opacity: res}}>
        <Badge text={ui.limitNote} tone="amber" size={m.small * 0.85} />
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  lightpath: LightPathLayer,
  ladder: LadderLayer,
  beer: BeerLayer,
  bss: BssLayer,
  dilute: DiluteLayer,
  phone: PhoneShotsLayer,
  cta: CtaLayer,
};
