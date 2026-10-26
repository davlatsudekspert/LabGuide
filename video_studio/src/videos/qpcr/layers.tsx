// Visual layers of the topic video "Real-time PCR". The instrument is the
// app's ORIGINAL schematic (real_time_pcr.svg), toured with the generic
// SchematicTourLayer; the optical path follows the corrected order
// excitation source → excitation filter → tube → emission filter → detector.
// Curves and Cq are ILLUSTRATIVE, computed in src/lib/qpcr.js.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, pop} from '../../components/anim';
import {Badge, Pill, SceneHeader} from '../../components/Basics';
import {isV, txt, useT} from '../../components/layerKit';
import {PhoneShotsLayer} from '../../components/PhoneShots';
import {Plot, type PlotSeries} from '../../components/Plot';
import {SchematicTourLayer} from '../../components/SchematicTour';
import {color, font, tabular} from '../../design/theme';
import type {Layer, VideoCtx} from '../../framework/types';
import {fill, fmt} from '../../lib/text.js';
import {CtaLayer} from '../calibration/layers';

type Sample = {id: string; color: string; flat?: boolean; pts: [number, number][]; cq: number | null; maxF: number};
const C: Record<string, string> = {mint: color.mint, amber: color.amber, inkDim: color.inkDim, beam: color.beam, coral: color.coral};

/** Amplification plot: curves revealed up to cycle `upto`, threshold, Cq marks. */
export const AmpPlot: React.FC<{ctx: VideoCtx; w: number; h: number; upto: number; tick: number; showCq: number; thrT: number; id: string; labels?: boolean}> = ({ctx, w, h, upto, tick, showCq, thrT, id, labels = true}) => {
  const m = ctx.math;
  const samples = m.samples as Sample[];
  const series: PlotSeries[] = [
    {kind: 'hline', y: m.threshold, color: color.coral, dash: '10 8', width: 3, t: thrT, label: labels ? ctx.ui.threshold : undefined},
  ];
  for (const s of samples) {
    const pts = s.pts.filter(([c]) => c <= upto);
    if (pts.length < 2) continue;
    series.push({kind: 'line', pts, color: C[s.color] ?? color.mint, width: s.flat ? 3 : 5, glow: !s.flat, dash: s.flat ? '6 6' : undefined});
  }
  samples.forEach((s) => {
    if (s.cq == null || showCq <= 0 || upto < s.cq) return;
    series.push({kind: 'vline', x: s.cq, color: C[s.color], dash: '6 6', width: 2.5, t: showCq, label: `Cq ${fmt(s.cq, ctx.lang, 1)}`, labelY: 1.12});
    series.push({kind: 'points', color: C[s.color], pts: [{x: s.cq, y: m.threshold, t: showCq, ring: true}]});
  });
  return (
    <Plot
      width={w}
      height={h}
      lang={ctx.lang}
      tick={tick}
      domain={{x: [0, m.cycles], y: [0, 1.2], xTicks: [0, 10, 20, 30, 40], yTicks: []}}
      hideYTicks
      showGrid={false}
      margins={[1.8, 3.4, 1.6, 4.6]}
      axisX={ctx.ui.axisCycle}
      axisY={ctx.ui.axisF}
      series={series}
      idPrefix={id}
      overlay={({sx, sy}) =>
        labels
          ? samples.map((s) => {
              const last = s.pts.filter(([c]) => c <= upto).pop();
              // Curve-end labels only once the curves have separated (at low
              // cycles the A / B / NTC heads sit on top of each other).
              const lt = Math.min(1, Math.max(0, (upto - 31) / 3));
              if (!last || lt <= 0) return null;
              return (
                <text key={s.id} x={sx(last[0]) + 10} y={sy(last[1]) + tick * 0.35} fill={C[s.color]} opacity={lt} fontFamily={font.sans} fontWeight={700} fontSize={tick * 0.95}>
                  {s.flat ? 'NTC' : s.id}
                </text>
              );
            })
          : null
      }
    />
  );
};

// ------------------------------------------------------------------ hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  // First frame already shows curve A leaving the baseline (hook from t = 0).
  const upto = 24 + 16 * easeIO(frame, 0, Math.round(1.2 * fps));
  const q = pop(frame, fps, cue(1));
  const plot = <AmpPlot ctx={ctx} w={vertical ? 960 : 1040} h={vertical ? 700 : 640} upto={upto} tick={vertical ? 30 : 26} showCq={ease(frame, Math.round(1.2 * fps), 12)} thrT={ease(frame, 4, 12)} id={`qhook-${ctx.format}`} />;
  const title = <div style={{...txt(m.h1, 700, color.ink), opacity: q, transform: `scale(${0.92 + 0.08 * q})`, transformOrigin: vertical ? 'center' : 'left center', textWrap: 'balance' as never}}>{ui.hookQ}</div>;
  const badge = <div style={{opacity: ease(frame, 18, 12)}}><Badge text={ui.illustrative} tone="amber" size={m.small * 0.8} /></div>;
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

// ----------------------------------------------------------- one cycle
const Strand: React.FC<{x: number; y: number; w: number; c: string; t?: number}> = ({x, y, w, c, t = 1}) => (
  <g>
    <rect x={x} y={y - 6} width={w * t} height={12} rx={6} fill={c} />
    {Array.from({length: Math.floor((w * t) / 22)}, (_, i) => (
      <rect key={i} x={x + 8 + i * 22} y={y - 14} width={4} height={28} rx={2} fill={c} opacity={0.5} />
    ))}
  </g>
);

export const CycleLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const span = Math.max(fps * 2, cueEnd(0) - cue(0));
  const p1 = ease(frame, cue(0), Math.round(span * 0.3));
  const p2 = ease(frame, cue(0) + Math.round(span * 0.35), Math.round(span * 0.25));
  const p3 = ease(frame, cue(0) + Math.round(span * 0.62), Math.round(span * 0.35));
  const W = vertical ? 900 : 860;
  const L = W - 160;
  const gap = 40 + 70 * p1;
  const y0 = 120;
  const stepsList = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 14}}>
      {[
        {t: p1, s: ui.heat, c: color.coral},
        {t: p2, s: ui.cool, c: color.beam},
        {t: p3, s: ui.extend, c: color.amber},
      ].map((l, i) => (
        <div key={l.s} style={{display: 'flex', alignItems: 'center', gap: 16, opacity: 0.25 + 0.75 * l.t, ...txt(m.body, 600, color.ink)}}>
          <span style={{width: 34, height: 34, borderRadius: 99, background: l.c, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', ...txt(m.small * 0.8, 700, color.bg0)}}>{i + 1}</span>
          {l.s}
        </div>
      ))}
    </div>
  );
  const dna = (
    <svg width={W} height={220} style={{overflow: 'visible'}}>
      <Strand x={80} y={y0 - gap / 2} w={L} c={color.beam} />
      <Strand x={80} y={y0 + gap / 2} w={L} c={color.mint} />
      {p2 > 0 ? (
        <>
          <rect x={80 + L - 90} y={y0 - gap / 2 + 18} width={90 * p2} height={10} rx={5} fill={color.amber} />
          <rect x={80} y={y0 + gap / 2 - 28} width={90 * p2} height={10} rx={5} fill={color.amber} />
        </>
      ) : null}
      {p3 > 0 ? (
        <>
          <rect x={80 + L - 90 - (L - 90) * p3} y={y0 - gap / 2 + 18} width={(L - 90) * p3} height={10} rx={5} fill={color.amber} opacity={0.75} />
          <rect x={170} y={y0 + gap / 2 - 28} width={(L - 90) * p3} height={10} rx={5} fill={color.amber} opacity={0.75} />
        </>
      ) : null}
    </svg>
  );
  const steps = ctx.math.doubling as {n: number; copies: number}[];
  const bt = (i: number) => ease(frame, cue(1) + i * 5, 10);
  const max = steps[steps.length - 1].copies;
  const bw = vertical ? 120 : 110;
  const bars = (
    <div style={{display: 'flex', alignItems: 'flex-end', gap: vertical ? 24 : 26, height: 300}}>
      {steps.map((s, i) => (
        <div key={s.n} style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, opacity: bt(i)}}>
          <div style={{...txt(m.body, 700, color.amber), ...tabular}}>{s.copies}</div>
          <div style={{width: bw, height: 20 + (220 * s.copies * bt(i)) / max, borderRadius: 10, background: `linear-gradient(180deg, ${color.amber}, ${color.amber}66)`}} />
          <div style={{...txt(m.small * 0.85, 600, color.inkDim)}}>{fill(ui.cycleN, {n: s.n})}</div>
        </div>
      ))}
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerCycle} badge={{text: ui.principleNote}} />
      <div style={{position: 'absolute', left: vertical ? 90 : 90, top: vertical ? 360 : 220}}>{dna}</div>
      <div style={{position: 'absolute', left: vertical ? m.gutter + 40 : 150, top: vertical ? 600 : 470}}>{stepsList}</div>
      <div style={{position: 'absolute', left: vertical ? 0 : 1000, right: vertical ? 0 : m.gutter, top: vertical ? 900 : 260, display: 'flex', flexDirection: 'column', alignItems: vertical ? 'center' : 'flex-start', gap: 24}}>
        {bars}
        <div style={{opacity: ease(frame, cue(1) + 30, 12)}}>
          <Pill text={ui.doubling} size={m.small} tone="amber" />
        </div>
      </div>
    </AbsoluteFill>
  );
};

// -------------------------------------------------------------- curves
export const CurvesLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const upto = 40 * easeIO(frame, 4, Math.max(fps * 2, cue(1) - 4));
  const thrT = ease(frame, cue(1), 12);
  const cqT = ease(frame, cue(1) + Math.round(0.8 * fps), 14);
  const note = ease(frame, cue(1) + Math.round(1.8 * fps), 14);
  const plot = <AmpPlot ctx={ctx} w={vertical ? 960 : 1100} h={vertical ? 760 : 680} upto={upto} tick={vertical ? 30 : 26} showCq={cqT} thrT={thrT} id={`qcurves-${ctx.format}`} />;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerCurves} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: vertical ? 50 : 80, top: vertical ? 400 : 200}}>{plot}</div>
      <div style={{position: 'absolute', left: vertical ? m.gutter : 1300, right: m.gutter, top: vertical ? 1230 : 360, display: 'flex', justifyContent: vertical ? 'center' : 'flex-start', opacity: note}}>
        <Pill text={ui.lowerMore} size={vertical ? m.small * 1.05 : m.small} tone="mint" />
      </div>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------ cautions
export const CautionsLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const half = cue(0) + Math.round((cueEnd(0) - cue(0)) * 0.5);
  const a = ease(frame, cue(0), 14);
  const b = ease(frame, half, 14);
  const card = (t: number, text: string, icon: string) => (
    <div style={{opacity: t, transform: `translateY(${(1 - t) * 20}px)`, display: 'flex', alignItems: 'center', gap: 26, padding: '28px 34px', borderRadius: 26, background: 'rgba(6,20,16,0.9)', border: `2px solid ${color.coral}66`, width: vertical ? 900 : 760}}>
      <div style={{...txt(64, 700, color.coral)}}>{icon}</div>
      <div style={{...txt(vertical ? 44 : 40, 700, color.ink), textWrap: 'balance' as never}}>{text}</div>
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerCaution} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: 0, right: 0, top: vertical ? 520 : 300, display: 'flex', flexDirection: vertical ? 'column' : 'row', alignItems: 'center', justifyContent: 'center', gap: 40}}>
        {card(a, ui.c1, '!')}
        {card(b, ui.c2, '≠')}
      </div>
      <div style={{position: 'absolute', left: 0, right: 0, top: vertical ? 1200 : 720, display: 'flex', justifyContent: 'center', opacity: ease(frame, half + 20, 12)}}>
        <Badge text={ui.fromCard} size={m.small * 0.8} />
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  cycle: CycleLayer,
  tour: SchematicTourLayer,
  curves: CurvesLayer,
  cautions: CautionsLayer,
  phone: PhoneShotsLayer,
  cta: CtaLayer,
};
