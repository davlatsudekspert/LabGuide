// Visual layers of the topic video "GC-MS". The apparatus is the app's
// ORIGINAL schematic (tool/illustrations/schematic/mass_spec_gc.svg) — toured
// with the generic SchematicTourLayer and zoomed with SchematicStage overlays
// (separation in the column, ions in the quadrupole; motion ideas from
// tool/video/lessons/anim_gc_ms.js). Chromatogram and spectrum are
// ILLUSTRATIVE schematic panels computed in src/lib/gcms.js (no numbers on
// the axes, no real compound).
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, pop} from '../../components/anim';
import {Badge, Pill, SceneHeader} from '../../components/Basics';
import {isV, txt, useT} from '../../components/layerKit';
import {PhoneShotsLayer} from '../../components/PhoneShots';
import {Plot, type PlotSeries} from '../../components/Plot';
import {SchematicStage} from '../../components/SchematicStage';
import {SchematicTourLayer} from '../../components/SchematicTour';
import {color, font} from '../../design/theme';
import type {Layer, VideoCtx} from '../../framework/types';
import {fill} from '../../lib/text.js';
import {CtaLayer} from '../calibration/layers';

type Peak = {id: string; rt: number; h: number; w: number; color: string};
const C: Record<string, string> = {amber: color.amber, coral: color.coral, beam: color.beam, mint: color.mint};
const peakColor = (p: Peak) => C[p.color] ?? color.mint;

/** Chromatogram panel (no tick numbers): reveal up to time `upto`. */
const Chromatogram: React.FC<{ctx: VideoCtx; w: number; h: number; upto: number; tick: number; marks?: number[]; labels?: (p: Peak, i: number) => string | null; highlight?: number; extra?: [number, number][]; id: string}> = ({ctx, w, h, upto, tick, marks = [], labels, highlight, extra, id}) => {
  const m = ctx.math;
  const pts = (m.chrom as [number, number][]).filter(([t]) => t <= upto);
  const ymax = 1.15;
  const series: PlotSeries[] = [];
  if (highlight != null) {
    const p = m.peaks[highlight] as Peak;
    series.push({kind: 'xband', x0: p.rt - 3 * p.w, x1: p.rt + 3 * p.w, color: `${peakColor(p)}33`});
  }
  series.push({kind: 'line', pts: pts.length > 1 ? pts : [[0, 0.02], [0.001, 0.02]], color: color.mint, width: 4, glow: true});
  if (extra) series.push({kind: 'line', pts: extra, color: color.coral, width: 4, dash: '8 6'});
  (m.peaks as Peak[]).forEach((p, i) => {
    if (!marks.includes(i) || upto < p.rt) return;
    series.push({kind: 'vline', x: p.rt, color: peakColor(p), dash: '6 6', width: 2.5, t: 1, label: labels ? labels(p, i) ?? undefined : undefined, labelY: (m.apex[i] as number) + 0.12});
  });
  return (
    <Plot
      width={w}
      height={h}
      lang={ctx.lang}
      tick={tick}
      margins={[1.6, 2.2, 1.6, 0.8]}
      domain={{x: [0, m.tMax], y: [0, ymax], xTicks: [], yTicks: []}}
      hideXTicks
      hideYTicks
      showGrid={false}
      axisX={ctx.ui.axisTime}
      axisY={ctx.ui.axisSignal}
      series={series}
      idPrefix={id}
    />
  );
};

// ------------------------------------------------------------------ hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  // First frame already shows a peak with its '?' (hook from t = 0); the
  // rest of the trace is drawn within the first second.
  const upto = ctx.math.tMax * (0.42 + 0.58 * easeIO(frame, 0, Math.round(1.0 * fps)));
  const q = pop(frame, fps, cue(0) + Math.round(0.7 * fps));
  const chrom = (
    <Chromatogram
      ctx={ctx}
      w={vertical ? 960 : 1000}
      h={vertical ? 620 : 600}
      upto={upto}
      tick={vertical ? 30 : 26}
      marks={[0, 1, 2]}
      labels={() => '?'}
      id={`gchook-${ctx.format}`}
    />
  );
  const title = (
    <div style={{...txt(m.h1 * 1.1, 700, color.ink), opacity: q, transform: `scale(${0.92 + 0.08 * q})`, transformOrigin: vertical ? 'center' : 'left center', textWrap: 'balance' as never}}>{ui.hookQ}</div>
  );
  const sub = <div style={{...txt(m.h2 * 0.8, 700, color.mint), opacity: ease(frame, cue(1), 14), textWrap: 'balance' as never}}>GC → MS</div>;
  const badge = <div style={{opacity: ease(frame, 18, 12)}}><Badge text={ui.illustrative} tone="amber" size={m.small * 0.8} /></div>;
  if (vertical) {
    return (
      <AbsoluteFill>
        <div style={{position: 'absolute', left: 60, top: 260}}>{chrom}</div>
        <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 980, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 28, textAlign: 'center'}}>
          {title}
          {sub}
          <div style={{height: 20}} />
          {badge}
        </div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 90, top: 200}}>{chrom}</div>
      <div style={{position: 'absolute', left: 1180, right: m.gutter, top: 330, display: 'flex', flexDirection: 'column', gap: 26}}>
        {title}
        {sub}
        <div style={{height: 10}} />
        {badge}
      </div>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------ separation
// Column coil of the drawing (anim_gc_ms.js spiral, shifted by the drawing's
// translate(0,-54)).
function spiral(s: number): [number, number] {
  const th = -2.3 + s * 6.2 * 2 * Math.PI;
  const rx = 82 - 18 * s;
  const ry = 64 - 18 * s;
  return [345 + rx * Math.cos(th), 458 + ry * Math.sin(th)];
}
const OUTLET: [number, number][] = [[409, 426], [424, 416], [458, 416], [482, 415], [600, 415]];

export const SeparateLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const peaks = ctx.math.peaks as Peak[];
  const tMax = ctx.math.tMax as number;
  const span = Math.max(fps * 3, cueEnd(0) - cue(0) + Math.round(0.8 * fps));
  const tau = tMax * easeIO(frame, cue(0), span);
  const zones = peaks.map((p, i) => {
    const s = Math.min(1, tau / p.rt);
    let xy = spiral(s);
    let op = 1;
    if (tau > p.rt) {
      const f = Math.min(1, (tau - p.rt) / 1.2);
      const k = Math.min(OUTLET.length - 2, Math.floor(f * (OUTLET.length - 1)));
      const g = f * (OUTLET.length - 1) - k;
      xy = [OUTLET[k][0] + (OUTLET[k + 1][0] - OUTLET[k][0]) * g, OUTLET[k][1] + (OUTLET[k + 1][1] - OUTLET[k][1]) * g];
      op = 1 - f * 0.8;
    }
    return {p, xy, op, i};
  });
  const overlay = (
    <g>
      {zones.map((z) => (
        <g key={z.p.id} opacity={z.op}>
          <circle cx={z.xy[0]} cy={z.xy[1]} r={14} fill={peakColor(z.p)} opacity={0.35} />
          <circle cx={z.xy[0]} cy={z.xy[1]} r={7} fill={peakColor(z.p)} stroke="#fff" strokeWidth={2} />
        </g>
      ))}
    </g>
  );
  const W = vertical ? 940 : 820;
  const H = vertical ? 600 : 620;
  const stage = (
    <div style={{width: W, height: H, overflow: 'hidden', borderRadius: 28, border: `2px solid ${color.line}`, background: '#E9EEEA', position: 'relative'}}>
      <div style={{position: 'absolute', left: W / 2 - 360 * ((W * 1.9) / 1200), top: H / 2 - 450 * ((W * 1.9) / 1200)}}>
        <SchematicStage name="mass_spec_gc" width={W * 1.9} emphasis={{}} dim={1} overlay={overlay} />
      </div>
    </div>
  );
  const chrom = <Chromatogram ctx={ctx} w={vertical ? 960 : 900} h={vertical ? 420 : 420} upto={tau} tick={vertical ? 28 : 24} marks={[0, 1, 2]} labels={(p) => p.id} id={`gcsep-${ctx.format}`} />;
  const chip = (
    <div style={{opacity: ease(frame, cue(1), 14), transform: `translateY(${(1 - ease(frame, cue(1), 14)) * 14}px)`}}>
      <Pill text={ui.volatile} size={m.small} tone="mint" />
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerSep} badge={{text: ui.illustrative, tone: 'amber'}} />
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: 70, top: 330}}>{stage}</div>
          <div style={{position: 'absolute', left: 60, top: 950}}>{chrom}</div>
          <div style={{position: 'absolute', left: 0, right: 0, top: 1390, display: 'flex', justifyContent: 'center'}}>{chip}</div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 100, top: 200}}>{stage}</div>
          <div style={{position: 'absolute', left: 960, top: 230}}>{chrom}</div>
          <div style={{position: 'absolute', left: 990, top: 700}}>{chip}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

// ---------------------------------------------------------- quadrupole
export const QuadLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const peaks = ctx.math.peaks as Peak[];
  // The pass band cycles through the three ion colours (m/z scan, schematic).
  const period = Math.round(1.3 * fps);
  const sel = Math.floor(Math.max(0, frame - cue(1)) / period) % 3;
  const scanning = frame >= cue(1);
  const ions = [];
  for (let i = 0; i < 18; i++) {
    const p = peaks[i % 3];
    const ph = (((frame * 4.2 + i * 37) % 300) + 300) % 300;
    const x = 615 + ph;
    let y = 415 + Math.sin(i * 2.1 + frame / 9) * 4;
    let op = Math.min(1, ph / 20);
    const passes = !scanning || i % 3 === sel;
    if (scanning && !passes && x > 730) {
      const dv = (x - 730) * (i % 2 ? 0.55 : -0.55);
      y += dv;
      op *= Math.max(0, 1 - (x - 730) / 90);
    }
    if (x > 870) op *= passes ? Math.max(0, 1 - (x - 870) / 15) : 0;
    ions.push(<circle key={i} cx={x} cy={y} r={5.5} fill={peakColor(p)} stroke="#fff" strokeWidth={1.5} opacity={op} />);
  }
  const flash = scanning ? 0.5 + 0.5 * Math.sin(frame / 3) : 0.3;
  const overlay = (
    <g>
      {ions}
      <circle cx={885} cy={415} r={16} fill={scanning ? peakColor(peaks[sel]) : color.mint} opacity={0.35 * flash} />
    </g>
  );
  const W = vertical ? 940 : 1100;
  const H = vertical ? 560 : 560;
  const Z = vertical ? 3.3 : 3.0;
  const stage = (
    <div style={{width: W, height: H, overflow: 'hidden', borderRadius: 28, border: `2px solid ${color.line}`, background: '#E9EEEA', position: 'relative'}}>
      <div style={{position: 'absolute', left: W / 2 - 765 * ((W * Z) / 1200), top: H / 2 - 412 * ((W * Z) / 1200)}}>
        <SchematicStage name="mass_spec_gc" width={W * Z} emphasis={{}} dim={1} overlay={overlay} />
      </div>
    </div>
  );
  const notes = [
    {k: ui.fragments, t: ease(frame, cue(0) + 10, 12), c: color.ink},
    {k: ui.passes, t: ease(frame, cue(1) + 10, 12), c: color.mint},
    {k: ui.deflected, t: ease(frame, cue(1) + 30, 12), c: color.coral},
  ];
  const list = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 18}}>
      <div style={{...txt(vertical ? 64 : 58, 700, color.mint), opacity: ease(frame, cue(1), 12)}}>m/z</div>
      {notes.map((n) => (
        <div key={n.k} style={{...txt(m.body, 600, n.c), opacity: n.t}}>{`• ${n.k}`}</div>
      ))}
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerQuad} badge={{text: ui.schematicNote}} />
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: 70, top: 360}}>{stage}</div>
          <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 1000}}>{list}</div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 100, top: 200}}>{stage}</div>
          <div style={{position: 'absolute', left: 1300, right: m.gutter, top: 300}}>{list}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

// --------------------------------------------------------------- result
export const ResultLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const sel = ctx.math.selected as number;
  const p = (ctx.math.peaks as Peak[])[sel];
  const spec = (ctx.math.spectra as {x: number; y: number}[][])[sel];
  const st = ease(frame, cue(0) + Math.round(1.0 * fps), 10);
  const specSeries: PlotSeries[] = [
    {kind: 'sticks', color: peakColor(p), width: vertical ? 12 : 11, pts: spec.map((s, i) => ({x: s.x, y: s.y, t: Math.max(0, Math.min(1, st * 1.8 - i * 0.12))}))},
  ];
  const lib = pop(frame, fps, cue(1));
  const W = vertical ? 960 : 820;
  const chrom = <Chromatogram ctx={ctx} w={W} h={vertical ? 420 : 480} upto={ctx.math.tMax} tick={vertical ? 28 : 24} marks={[sel]} labels={(q) => q.id} highlight={sel} id={`gcres-${ctx.format}`} />;
  const spectrum = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 10}}>
      <div style={{...txt(m.small, 700, peakColor(p))}}>{fill(ui.spectrumOf, {id: p.id})}</div>
      <Plot
        width={W}
        height={vertical ? 420 : 430}
        lang={ctx.lang}
        tick={vertical ? 28 : 24}
        margins={[1.6, 2.2, 1.0, 0.8]}
        domain={{x: [0, ctx.math.mzMax], y: [0, 112], xTicks: [], yTicks: []}}
        hideXTicks
        hideYTicks
        showGrid={false}
        axisX={ui.axisMz}
        axisY={ui.axisRel}
        series={specSeries}
        idPrefix={`gcspec-${ctx.format}`}
      />
    </div>
  );
  const libPill = (
    <div style={{opacity: lib, transform: `scale(${0.9 + 0.1 * lib})`}}>
      <Pill text={ui.library} size={m.small} tone="mint" />
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerResult} badge={{text: ui.illustrative, tone: 'amber'}} />
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: 60, top: 330}}>{chrom}</div>
          <div style={{position: 'absolute', left: 60, top: 790}}>{spectrum}</div>
          <div style={{position: 'absolute', left: 0, right: 0, top: 1300, display: 'flex', justifyContent: 'center'}}>{libPill}</div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, top: 230}}>{chrom}</div>
          <div style={{position: 'absolute', left: 1000, top: 200}}>{spectrum}</div>
          <div style={{position: 'absolute', left: 1000, top: 760}}>{libPill}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

// --------------------------------------------------------------- QC note
export const QcNoteLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const tMax = ctx.math.tMax as number;
  // An extra (non-sample) peak, drawn dashed — illustrative.
  const ex: [number, number][] = [];
  for (let k = 0; k <= 60; k++) {
    const t = 4.6 + (1.6 * k) / 60;
    ex.push([t, 0.03 + 0.3 * Math.exp(-0.5 * ((t - 5.4) / 0.16) ** 2)]);
  }
  const t = ease(frame, cue(0) + Math.round(0.6 * fps), 14);
  const pulse = 1 + 0.06 * Math.sin(frame / 4) * t;
  const chrom = <Chromatogram ctx={ctx} w={vertical ? 960 : 1000} h={vertical ? 560 : 560} upto={tMax} tick={vertical ? 28 : 24} extra={t > 0 ? ex.slice(0, Math.max(2, Math.round(ex.length * t))) : undefined} id={`gcqc-${ctx.format}`} />;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerQc} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: vertical ? 60 : 90, top: vertical ? 380 : 220}}>{chrom}</div>
      <div style={{position: 'absolute', left: vertical ? m.gutter : 1180, right: m.gutter, top: vertical ? 1010 : 330, display: 'flex', flexDirection: 'column', gap: 24, alignItems: vertical ? 'center' : 'flex-start'}}>
        <div style={{...txt(m.h2, 700, color.coral), opacity: t, transform: `scale(${pulse})`, transformOrigin: vertical ? 'center' : 'left center', textAlign: vertical ? 'center' : 'left'}}>{ui.qcPeaks}</div>
        <div style={{opacity: ease(frame, cue(0) + Math.round(1.4 * fps), 12)}}>
          <Badge text={ui.qcSource} size={m.small * 0.8} />
        </div>
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  tour: SchematicTourLayer,
  separate: SeparateLayer,
  quad: QuadLayer,
  result: ResultLayer,
  qcnote: QcNoteLayer,
  phone: PhoneShotsLayer,
  cta: CtaLayer,
};

export {Chromatogram, peakColor, font};
