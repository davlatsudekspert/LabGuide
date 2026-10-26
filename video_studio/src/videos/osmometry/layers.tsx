// Visual layers of the topic video "Osmometry". The instrument is the app's
// ORIGINAL schematic (osmometer.svg), toured with the generic
// SchematicTourLayer. Freezing curves are ILLUSTRATIVE (arbitrary
// temperature units, no numbers on the axes), computed in
// src/lib/osmometry.js. The calculator result is filmed from the app.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, pop} from '../../components/anim';
import {Badge, Pill, SceneHeader} from '../../components/Basics';
import {isV, txt, useT} from '../../components/layerKit';
import {PhoneShotsLayer} from '../../components/PhoneShots';
import {Plot, type PlotSeries} from '../../components/Plot';
import {SchematicTourLayer} from '../../components/SchematicTour';
import {color, font} from '../../design/theme';
import type {Layer, VideoCtx} from '../../framework/types';
import {CtaLayer} from '../calibration/layers';

type Sample = {id: string; color: string; tf: number; tsup: number; ts: number; tp: number; depression: number; pts: [number, number][]};
const C: Record<string, string> = {mint: color.mint, amber: color.amber, beam: color.beam, coral: color.coral};

/** Freezing-curve plot: samples revealed up to time `upto[i]`. */
export const FreezePlot: React.FC<{
  ctx: VideoCtx;
  w: number;
  h: number;
  tick: number;
  ids: string[];
  upto: number | number[];
  waterT?: number;
  plateauT?: number;
  labelsT?: number;
  depressionT?: number;
  marks?: {x: number; y: number; color: string; t: number; label?: string}[];
  id: string;
}> = ({ctx, w, h, tick, ids, upto, waterT = 1, plateauT = 0, labelsT = 1, depressionT = 0, marks = [], id}) => {
  const m = ctx.math;
  const all = m.samples as Sample[];
  const samples = ids.map((x) => all.find((s) => s.id === x)!);
  const tMax = m.curve.tMax as number;
  const series: PlotSeries[] = [{kind: 'hline', y: m.water, color: color.inkDim, dash: '10 8', width: 3, t: waterT, label: ctx.ui.water, labelColor: color.inkDim}];
  samples.forEach((s, i) => {
    const u = Array.isArray(upto) ? upto[i] : upto;
    const pts = s.pts.filter(([t]) => t <= u);
    if (pts.length >= 2) series.push({kind: 'line', pts, color: C[s.color], width: 5, glow: true});
    if (plateauT > 0) series.push({kind: 'hline', y: s.tf, color: C[s.color], dash: '4 8', width: 2, t: plateauT});
  });
  for (const k of marks) series.push({kind: 'points', color: k.color, pts: [{x: k.x, y: k.y, t: k.t, ring: true}]});
  return (
    <Plot
      width={w}
      height={h}
      lang={ctx.lang}
      tick={tick}
      domain={{x: [0, tMax], y: [-1.75, 1.2], xTicks: [], yTicks: []}}
      hideXTicks
      hideYTicks
      showGrid={false}
      margins={[1.8, 2.4, 0.8, 3.0]}
      axisX={ctx.ui.axisTime}
      axisY={ctx.ui.axisT}
      series={series}
      idPrefix={id}
      overlay={({sx, sy}) => (
        <g>
          {samples.map((s, i) => {
            // Sample letter just above its own plateau (once the plateau is drawn).
            const u = Array.isArray(upto) ? upto[i] : upto;
            const lx = s.ts + 1.2;
            if (labelsT <= 0 || u < lx) return null;
            return (
              <text key={s.id} x={sx(lx)} y={sy(s.tf) - tick * 0.55} fill={C[s.color]} opacity={labelsT} fontFamily={font.sans} fontWeight={700} fontSize={tick}>
                {ctx.ui[`sample${s.id}`] ?? s.id}
              </text>
            );
          })}
          {depressionT > 0
            ? samples.map((s, i) => {
                // A's arrow inside A's plateau, B's arrow further right inside B's.
                const x = sx(s.ts + 2.0 + i * 0.4);
                const y0 = sy(m.water);
                const y1 = y0 + (sy(s.tf) - y0) * depressionT;
                const ly = y0 + (y1 - y0) * (i === 0 ? 0.5 : 0.8);
                return (
                  <g key={`d${s.id}`} opacity={Math.min(1, depressionT * 2)}>
                    <line x1={x} y1={y0} x2={x} y2={y1} stroke={C[s.color]} strokeWidth={4} />
                    <path d={`M ${x - 9} ${y1 - 12} L ${x} ${y1} L ${x + 9} ${y1 - 12}`} stroke={C[s.color]} strokeWidth={4} fill="none" />
                    <text x={x + 14} y={ly + tick * 0.3} fill={C[s.color]} fontFamily={font.sans} fontWeight={700} fontSize={tick * 0.95} textAnchor="start">
                      ΔT
                    </text>
                  </g>
                );
              })
            : null}
          {marks
            .filter((k) => k.label && k.t > 0)
            .map((k) => (
              <text key={k.label} x={sx(k.x) + 16} y={sy(k.y) + tick * 1.5} fill={k.color} opacity={k.t} fontFamily={font.sans} fontWeight={700} fontSize={tick * 0.9}>
                {k.label}
              </text>
            ))}
        </g>
      )}
    />
  );
};

// ---------------------------------------------------------------- hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const tMax = ctx.math.curve.tMax as number;
  // First frame already shows both curves through the freeze (hook from t = 0).
  const upto = 5 + (tMax - 5) * easeIO(frame, 0, Math.round(1.2 * fps));
  const q = pop(frame, fps, cue(0) + Math.round(0.7 * fps));
  const plot = (
    <FreezePlot ctx={ctx} w={vertical ? 960 : 1040} h={vertical ? 700 : 640} tick={vertical ? 30 : 26} ids={['A', 'B']} upto={upto} plateauT={ease(frame, Math.round(1.0 * fps), 12)} labelsT={ease(frame, Math.round(0.9 * fps), 10)} id={`ohook-${ctx.format}`} />
  );
  const title = <div style={{...txt(m.h1, 700, color.ink), opacity: q, transform: `scale(${0.92 + 0.08 * q})`, transformOrigin: vertical ? 'center' : 'left center', textWrap: 'balance' as never}}>{ui.hookQ}</div>;
  const badge = <div style={{opacity: ease(frame, 12, 12)}}><Badge text={ui.illustrative} tone="amber" size={m.small * 0.8} /></div>;
  if (vertical) {
    return (
      <AbsoluteFill>
        <div style={{position: 'absolute', left: 50, top: 240}}>{plot}</div>
        <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 1030, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 30, textAlign: 'center'}}>
          {title}
          {badge}
        </div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 80, top: 200}}>{plot}</div>
      <div style={{position: 'absolute', left: 1240, right: m.gutter, top: 380, display: 'flex', flexDirection: 'column', gap: 30}}>
        {title}
        {badge}
      </div>
    </AbsoluteFill>
  );
};

// -------------------------------------------------------------- freeze
export const FreezeLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const s = (ctx.math.samples as Sample[]).find((x) => x.id === 'A')!;
  const tMax = ctx.math.curve.tMax as number;
  // Line 0: cooling to the supercooled minimum; line 1: the jump; line 2: plateau.
  const a = easeIO(frame, 4, Math.max(fps, cueEnd(0) - 4));
  const b = easeIO(frame, cue(1), Math.round(0.8 * fps));
  const c = easeIO(frame, cue(2), Math.max(fps, cueEnd(2) - cue(2)));
  const upto = s.ts * a + 0.6 * b + (tMax - s.ts - 0.6) * c;
  const t1 = ease(frame, cue(0) + Math.round(1.2 * fps), 12);
  const t2 = ease(frame, cue(1) + 6, 12);
  const t3 = ease(frame, cue(2) + Math.round(0.8 * fps), 12);
  const plot = (
    <FreezePlot
      ctx={ctx}
      w={vertical ? 960 : 1060}
      h={vertical ? 700 : 660}
      tick={vertical ? 30 : 26}
      ids={['A']}
      upto={upto}
      plateauT={t3}
      labelsT={0}
      marks={[
        {x: s.ts, y: s.tsup, color: color.beam, t: t1},
        {x: s.ts + 0.5, y: s.tf, color: color.amber, t: t2},
      ]}
      id={`ofreeze-${ctx.format}`}
    />
  );
  const steps = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 18}}>
      {[
        {t: t1, s: ui.s1, c: color.beam},
        {t: t2, s: ui.s2, c: color.amber},
        {t: t3, s: ui.s3, c: color.mint},
      ].map((l, i) => (
        <div key={l.s} style={{display: 'flex', alignItems: 'center', gap: 16, opacity: 0.25 + 0.75 * l.t, ...txt(m.body, 600, color.ink)}}>
          <span style={{width: 40, height: 40, flex: 'none', borderRadius: 99, background: l.c, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', ...txt(m.small * 0.85, 700, color.bg0)}}>{i + 1}</span>
          {l.s}
        </div>
      ))}
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerFreeze} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: vertical ? 50 : 70, top: vertical ? 330 : 210}}>{plot}</div>
      <div style={{position: 'absolute', left: vertical ? m.gutter + 30 : 1210, right: m.gutter, top: vertical ? 1090 : 360}}>{steps}</div>
    </AbsoluteFill>
  );
};

// -------------------------------------------------------------- result
export const ResultLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const dT = easeIO(frame, cue(0) + 6, Math.round(1.2 * fps));
  const pill = ease(frame, cue(0) + Math.round(1.4 * fps), 12);
  const u1 = ease(frame, cue(1), 12);
  const u2 = ease(frame, cue(1) + Math.round(1.6 * fps), 12);
  const plot = <FreezePlot ctx={ctx} w={vertical ? 960 : 980} h={vertical ? 600 : 600} tick={vertical ? 28 : 24} ids={['A', 'B']} upto={ctx.math.curve.tMax} plateauT={1} depressionT={dT} id={`ores-${ctx.format}`} />;
  const unit = (t: number, title: string, sub: string, tone: string) => (
    <div style={{opacity: t, transform: `translateY(${(1 - t) * 16}px)`, padding: '22px 28px', borderRadius: 22, background: 'rgba(6,20,16,0.9)', border: `2px solid ${tone}88`, minWidth: vertical ? 0 : 520, flex: vertical ? 1 : undefined}}>
      <div style={{...txt(vertical ? 38 : 36, 700, tone)}}>{title}</div>
      <div style={{...txt(vertical ? 30 : 28, 500, color.inkDim), marginTop: 6}}>{sub}</div>
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerResult} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: vertical ? 50 : 70, top: vertical ? 320 : 200}}>{plot}</div>
      <div style={{position: 'absolute', left: vertical ? m.gutter : 1120, right: m.gutter, top: vertical ? 950 : 240, display: 'flex', flexDirection: 'column', alignItems: vertical ? 'center' : 'flex-start', gap: 26}}>
        <div style={{opacity: pill}}>
          <Pill text={ui.moreParticles} size={vertical ? m.small * 1.05 : m.small} tone="amber" />
        </div>
        <div style={{display: 'flex', flexDirection: 'column', gap: 18, width: vertical ? '100%' : undefined}}>
          {unit(u1, ui.unitKg, ui.unitKgSub, color.mint)}
          {unit(u2, ui.unitL, ui.unitLSub, color.inkDim)}
        </div>
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  tour: SchematicTourLayer,
  freeze: FreezeLayer,
  result: ResultLayer,
  phone: PhoneShotsLayer,
  cta: CtaLayer,
};
