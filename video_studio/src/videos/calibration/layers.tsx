// Visual layers of the flagship "Calibration" video. Each layer is a pure
// function of (scene, ctx, frame): layouts for vertical 9:16 and horizontal
// 16:9 come from the same component; language only changes text and the
// real app frames.
import React from 'react';
import {AbsoluteFill, Img, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {ease, easeIO, pop, rise} from '../../components/anim';
import {Badge, Pill, SceneHeader} from '../../components/Basics';
import {CalibrationChart, ResidualPanel} from '../../components/Chart';
import {Cuvette, OpticalBench} from '../../components/OpticalBench';
import {PhoneFrame, Rect} from '../../components/PhoneFrame';
import {SchematicStage} from '../../components/SchematicStage';
import {color, font, tabular} from '../../design/theme';
import type {Layer, LayerProps, LaidScene, VideoCtx} from '../../framework/types';
import {fmt, fill} from '../../lib/text.js';

const useT = (scene: LaidScene) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const cue = (i: number) => Math.round((scene.cues[i]?.start ?? 0) * fps);
  const cueEnd = (i: number) => Math.round((scene.cues[i]?.end ?? 0) * fps);
  return {frame, fps, cue, cueEnd, dur: scene.durationInFrames};
};

const V = (ctx: VideoCtx) => ctx.format === 'vertical';

const text = (size: number, weight = 600, c: string = color.ink): React.CSSProperties => ({
  fontFamily: font.sans,
  fontWeight: weight,
  fontSize: size,
  color: c,
  lineHeight: 1.15,
});

// ------------------------------------------------------------------ hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui, lang, math} = ctx;
  const A = math.hook.abs as number;
  const roll = ease(frame, 0, 18);
  const shown = A * (0.6 + 0.4 * roll);
  const q = ease(frame, 10, 14);
  const p = pop(frame, fps, cue(1));
  const qPulse = 1 + 0.06 * Math.sin(frame / 4) * (1 - p);
  const beamT = 0.4 + 0.6 * ease(frame, 0, 16);
  const vertical = V(ctx);
  const number = (
    <div style={{...text(m.display, 700, color.white), ...tabular, letterSpacing: -6, lineHeight: 1}}>
      {fmt(shown, lang, 3)}
    </div>
  );
  const label = (
    <div style={{...text(m.kicker, 700, color.amber), letterSpacing: m.kicker * 0.16, textTransform: 'uppercase'}}>
      {ui.hookLabel} · A
    </div>
  );
  const question = (
    <div style={{...rise(q), ...text(m.h1, 700), letterSpacing: -1}}>
      {ui.hookQuestion.replace('?', '')}
      <span style={{color: color.amber, display: 'inline-block', transform: `scale(${qPulse})`}}>?</span>
    </div>
  );
  const punch = (
    <div
      style={{
        ...text(m.h2, 700, color.coral),
        opacity: p,
        transform: `scale(${0.9 + 0.1 * p})`,
        textWrap: 'balance' as never,
      }}
    >
      {ui.hookPunch}
    </div>
  );
  const badge = (
    <div style={{opacity: ease(frame, 18, 12)}}>
      <Badge text={ui.illustrative} tone="amber" size={m.small * 0.8} />
    </div>
  );
  if (vertical) {
    return (
      <AbsoluteFill>
        <div style={{position: 'absolute', left: 70, top: 250}}>
          <OpticalBench width={940} absorbance={A} beamT={beamT} lang={lang} showReadout={false} minimal />
        </div>
        <div
          style={{
            position: 'absolute',
            left: m.gutter,
            right: m.gutter,
            top: 640,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 26,
            textAlign: 'center',
          }}
        >
          {label}
          {number}
          {question}
          <div style={{height: 10}} />
          {punch}
          <div style={{height: 30}} />
          {badge}
        </div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 90, top: 330}}>
        <OpticalBench width={860} absorbance={A} beamT={beamT} lang={lang} showReadout={false} minimal />
      </div>
      <div
        style={{
          position: 'absolute',
          left: 1040,
          right: m.gutter,
          top: 210,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'flex-start',
          gap: 22,
        }}
      >
        {label}
        {number}
        {question}
        <div style={{height: 8}} />
        {punch}
        <div style={{height: 18}} />
        {badge}
      </div>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------ analyzer
const PartRow: React.FC<{n: number; name: string; t: number; size: number}> = ({n, name, t, size}) => (
  <div style={{display: 'flex', alignItems: 'center', gap: size * 0.5, ...rise(t, 18)}}>
    <div
      style={{
        width: size * 1.35,
        height: size * 1.35,
        flex: 'none',
        borderRadius: 99,
        background: color.brand,
        border: '3px solid #fff',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        ...text(size * 0.8, 700, '#fff'),
      }}
    >
      {n}
    </div>
    <div style={{...text(size, 600)}}>{name}</div>
  </div>
);

export const SchematicLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const parts = (scene.props?.parts as number[]) ?? [4, 5];
  const e4 = ease(frame, cue(0) + 8, 14);
  const e5 = ease(frame, cue(0) + Math.round(1.3 * fps), 14);
  const e8 = ease(frame, cue(1), 14);
  const dim = ease(frame, 4, 18);
  const zoom = 1 + 0.12 * easeIO(frame, 10, 70) - 0.1 * easeIO(frame, cue(1) - 6, 30);
  const beamT = ease(frame, cue(0) + Math.round(1.5 * fps), 22);
  const vertical = V(ctx);
  const width = vertical ? 980 : 1040;
  const chip = ease(frame, cue(1) + 10, 14);
  const legend = (
    <div style={{display: 'flex', flexDirection: 'column', gap: vertical ? 22 : 26}}>
      {parts.includes(4) ? <PartRow n={4} name={ui.part4} t={e4} size={m.body} /> : null}
      {parts.includes(5) ? <PartRow n={5} name={ui.part5} t={e5} size={m.body} /> : null}
      <PartRow n={8} name={ui.part8} t={e8} size={m.body} />
      <div style={{opacity: chip, marginTop: 10}}>
        <Pill text={ui.concFromCal} size={m.small} tone="mint" />
      </div>
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="01" kicker={ui.kickerAnalyzer} badge={{text: ui.schematicNote}} />
      <div style={{position: 'absolute', left: vertical ? 14 : 50, top: vertical ? 400 : 200}}>
        <SchematicStage
          name="chemistry"
          width={width}
          emphasis={{4: e4, 5: e5, 8: e8}}
          dim={dim}
          zoom={zoom}
          focus={[800, 300]}
          beam={{from: [741, 252], to: [852, 252], t: beamT, pulse: Math.sin(frame / 5)}}
        />
      </div>
      <div
        style={{
          position: 'absolute',
          left: vertical ? m.gutter : 1170,
          right: m.gutter,
          top: vertical ? 1100 : 330,
        }}
      >
        {legend}
      </div>
    </AbsoluteFill>
  );
};

// ----------------------------------------------------------- light path
export const LightPathLayer: Layer = ({scene, ctx}) => {
  const {frame, dur} = useT(scene);
  const {m, ui, lang} = ctx;
  const vertical = V(ctx);
  const A = 0.05 + 0.6 * easeIO(frame, 18, Math.max(30, dur - 40));
  const T = Math.pow(10, -A);
  const beamT = ease(frame, 0, 26);
  const f = ease(frame, 20, 14);
  const barW = vertical ? 620 : 470;
  const bars = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 18, opacity: f}}>
      {[
        {k: 'I₀', w: 1, c: color.beam},
        {k: 'I', w: T, c: color.beam},
      ].map((b) => (
        <div key={b.k} style={{display: 'flex', alignItems: 'center', gap: 18}}>
          <div style={{width: 60, ...text(m.body, 700, color.inkDim)}}>{b.k}</div>
          <div style={{width: barW, height: 26, borderRadius: 13, background: color.panelStrong}}>
            <div style={{width: barW * b.w, height: 26, borderRadius: 13, background: b.c, opacity: 0.4 + 0.6 * b.w}} />
          </div>
        </div>
      ))}
      <div style={{display: 'flex', gap: 30, marginTop: 8, ...text(m.body, 600, color.ink), ...tabular}}>
        <span>{`T = I / I₀ = ${fmt(T, lang, 2)}`}</span>
        <span style={{color: color.mint}}>{`A = ${fmt(A, lang, 3)}`}</span>
      </div>
    </div>
  );
  const formula = (
    <div style={{opacity: f, ...text(vertical ? 64 : 56, 700, color.mint), letterSpacing: -0.5}}>
      A = −log₁₀(I / I₀)
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="02" kicker={ui.kickerLight} badge={{text: ui.principleNote}} />
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
      <div
        style={{
          position: 'absolute',
          left: vertical ? m.gutter : 1250,
          right: m.gutter,
          top: vertical ? 1020 : 330,
          display: 'flex',
          flexDirection: 'column',
          gap: vertical ? 40 : 44,
          alignItems: vertical ? 'center' : 'flex-start',
        }}
      >
        {formula}
        {bars}
      </div>
    </AbsoluteFill>
  );
};

// ---------------------------------------------------------- calibrators
export const CalibratorsLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, dur} = useT(scene);
  const {m, ui, lang, math} = ctx;
  const vertical = V(ctx);
  const cals = math.calibrators as {id: string; conc: number; abs: number}[];
  const n = cals.length;
  const t0 = Math.round(0.9 * fps);
  const dt = Math.max(10, Math.floor((dur - t0 - fps * 1.2) / n));
  const cw = vertical ? 160 : 140;
  const gap = vertical ? 30 : 90;
  const total = n * cw + (n - 1) * gap;
  const x0 = (m.w - total) / 2;
  const top = vertical ? 470 : 200;
  // Row y positions (absolute) so captions never overlap values.
  const yId = top;
  const yCuv = yId + 50;
  const yVal = yCuv + cw * 1.9 + 22;
  const yCap1 = yVal + (vertical ? 70 : 66);
  const yMeas = yCap1 + (vertical ? 58 : 58);
  const yCap2 = yMeas + (vertical ? 56 : 54);
  const notes = ease(frame, t0 + dt * n - 6, 14);
  const caption = (y: number, s: string, c: string, t: number) => (
    <div style={{position: 'absolute', left: 0, right: 0, top: y, textAlign: 'center', ...text(m.small * 0.85, 600, c), opacity: t}}>{s}</div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="03" kicker={ui.kickerCalibrators} badge={{text: ui.illustrative, tone: 'amber'}} />
      {cals.map((c, i) => {
        const appear = pop(frame, fps, i * 5);
        const start = t0 + i * dt;
        const lit = frame >= start && frame < start + dt ? Math.sin(((frame - start) / dt) * Math.PI) : 0;
        const read = ease(frame, start + dt * 0.6, 8);
        const x = x0 + i * (cw + gap);
        const col: React.CSSProperties = {position: 'absolute', left: x, width: cw, textAlign: 'center'};
        return (
          <React.Fragment key={c.id}>
            <div style={{...col, top: yId, ...text(m.small, 700, color.inkFaint), opacity: appear}}>{c.id}</div>
            <div style={{...col, top: yCuv, opacity: appear, transform: `translateY(${(1 - appear) * 30}px)`}}>
              <Cuvette width={cw} absorbance={c.abs} lit={lit} />
            </div>
            <div style={{...col, top: yVal, ...text(vertical ? 54 : 48, 700), ...tabular, opacity: appear}}>{fmt(c.conc, lang, 1)}</div>
            <div style={{...col, top: yMeas, ...text(vertical ? 42 : 38, 700, color.beam), ...tabular, opacity: read}}>{fmt(c.abs, lang, 3)}</div>
          </React.Fragment>
        );
      })}
      {caption(yCap1, `${ui.assigned}, ${ui.unit}`, color.inkDim, ease(frame, 8, 12))}
      {caption(yCap2, `${ui.signal}: A`, color.beam, ease(frame, t0 + 8, 12))}
      <div
        style={{
          position: 'absolute',
          left: m.gutter,
          right: m.gutter,
          top: yCap2 + (vertical ? 110 : 70),
          display: 'flex',
          flexDirection: vertical ? 'column' : 'row',
          justifyContent: 'center',
          alignItems: 'center',
          gap: vertical ? 16 : 28,
          opacity: notes,
        }}
      >
        <Badge text={ui.fromSheet} size={m.small * 0.8} tone="mint" />
        <Badge text={ui.pointsNote} size={m.small * 0.8} />
      </div>
    </AbsoluteFill>
  );
};

// ---------------------------------------------------------------- chart
const DOMAIN = {x: [0, 10.8] as [number, number], y: [0, 0.9] as [number, number], xTicks: [0, 2.5, 5, 7.5, 10], yTicks: [0, 0.2, 0.4, 0.6, 0.8]};

const Panel: React.FC<{children: React.ReactNode; style?: React.CSSProperties}> = ({children, style}) => (
  <div
    style={{
      padding: '22px 28px',
      borderRadius: 26,
      background: 'rgba(6,20,16,0.88)',
      border: `2px solid ${color.line}`,
      boxShadow: '0 20px 60px rgba(0,0,0,0.4)',
      display: 'flex',
      flexDirection: 'column',
      gap: 10,
      ...style,
    }}
  >
    {children}
  </div>
);

export const ChartLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, dur} = useT(scene);
  const {m, ui, lang, math} = ctx;
  const vertical = V(ctx);
  const phase = (scene.props?.phase as string) ?? 'points';
  const fit = math.fit;
  const cals = math.calibrators as {id: string; conc: number; abs: number; residual: number}[];
  const controls = math.controls as {id: string; target: number; abs: number; conc: number; pctOfTarget: number}[];
  const hook = math.hook;
  const isPts = phase === 'points';
  const axesT = isPts ? ease(frame, 0, 18) : 1;
  const step = isPts ? Math.max(8, Math.floor((dur * 0.7 - 14) / cals.length)) : 0;
  const pointT = cals.map((_, i) => (isPts ? pop(frame, fps, 14 + i * step) : 1));
  const lineT = isPts ? 0 : phase === 'fit' ? easeIO(frame, 6, 40) : 1;
  const ctlStarts = [8, Math.round(Math.max(1.6 * fps, dur * 0.35))];
  const controlT =
    phase === 'controls' ? controls.map((_, i) => ease(frame, ctlStarts[i] ?? 8, 34)) : controls.map(() => 0);
  const shrink = phase === 'residuals' ? easeIO(frame, 0, 22) : 0;
  const tick = vertical ? 30 : 24;
  const cw = vertical ? 960 : 1060;
  const chFull = vertical ? 900 : 700;
  const chSmall = vertical ? 540 : 700;
  const ch = chFull + (chSmall - chFull) * shrink;
  const cx = vertical ? 60 : 90;
  const cy = vertical ? 410 : 190;
  const header =
    phase === 'controls'
      ? {step: '05', kicker: ui.kickerControls}
      : phase === 'residuals'
        ? {step: '06', kicker: ui.kickerResiduals, title: ui.r2NotEnough}
        : {step: '04', kicker: ui.kickerCurve};
  const eqT = phase === 'fit' ? ease(frame, 26, 16) : phase === 'points' ? 0 : 1;
  const eqPulse = phase === 'fit' ? 1 + 0.04 * Math.max(0, Math.sin(((frame - cue(1)) / fps) * Math.PI * 1.5)) * (frame > cue(1) ? 1 : 0) : 1;
  const eqPanel = (
    <Panel style={{opacity: eqT, transform: `scale(${eqPulse})`, transformOrigin: 'left top'}}>
      <div style={{...text(vertical ? 32 : 36, 700), ...tabular, whiteSpace: 'nowrap'}}>
        {`A = ${fmt(fit.slope, lang, 4)} · c + ${fmt(fit.intercept, lang, 4)}`}
      </div>
      <div style={{...text(vertical ? 44 : 40, 700, color.mint), ...tabular}}>{`R² = ${fmt(fit.r2, lang, 4)}`}</div>
      <div style={{...text(m.small * 0.78, 600, color.inkDim)}}>
        {`${ui.slope} ${fmt(fit.slope, lang, 4)} · ${ui.intercept} ${fmt(fit.intercept, lang, 4)}`}
      </div>
      <div style={{...text(m.small * 0.74, 500, color.inkFaint)}}>
        {fill(ui.fitLabel, {n: fit.n})} · {ui.computed}
      </div>
    </Panel>
  );
  const hookT = phase === 'controls' ? ease(frame, (ctlStarts[1] ?? 8) + 34, 14) : 0;
  const hookPanel = (
    <Panel style={{opacity: hookT, borderColor: `${color.amber}88`}}>
      <div style={{...text(m.small * 0.85, 700, color.amber), textTransform: 'uppercase', letterSpacing: 2}}>
        {`${ui.control} · ${ui.readOff}`}
      </div>
      <div style={{...text(vertical ? 58 : 54, 700), ...tabular, whiteSpace: 'nowrap'}}>
        {`${fmt(hook.abs, lang, 3)} → ${fmt(hook.conc, lang, 2)}`}
      </div>
      <div style={{...text(m.small * 0.85, 600, color.inkDim), ...tabular}}>
        {`${ui.target} ${fmt(hook.target, lang, 1)} · ${fill(ui.ofTarget, {pct: fmt(hook.pctOfTarget, lang, 1)})}`}
      </div>
    </Panel>
  );
  const resT = cals.map((_, i) => (phase === 'residuals' ? ease(frame, 18 + i * 6, 14) : 0));
  const checks = [ui.check1, ui.check2, ui.check3];
  const checkT = checks.map((_, i) => ease(frame, cue(0) + Math.round(0.9 * fps) + i * 8, 12));
  const limitsT = ease(frame, cue(1), 14);
  const sideX = 1230;
  return (
    <AbsoluteFill>
      <SceneHeader
        format={ctx.format}
        step={header.step}
        kicker={header.kicker}
        title={header.title}
        badge={{text: ui.illustrative, tone: 'amber'}}
      />
      <div style={{position: 'absolute', left: cx, top: cy + (vertical && phase === 'residuals' ? 0 : 0)}}>
        <CalibrationChart
          width={cw}
          height={ch}
          lang={lang}
          points={cals.map((c) => ({x: c.conc, y: c.abs, id: c.id}))}
          slope={fit.slope}
          intercept={fit.intercept}
          domain={DOMAIN}
          axisX={ui.axisX}
          axisY={ui.axisY}
          tick={tick}
          axesT={axesT}
          pointT={pointT}
          lineT={lineT}
          controls={controls.map((q) => ({id: q.id, y: q.abs, x: q.conc, target: q.target}))}
          controlT={controlT}
          controlLabel={(q) => fmt(q.x, lang, 2)}
          hookId={hook.id}
          dimPoints={phase === 'controls' ? 0.6 : 0}
        />
      </div>
      {phase === 'fit' || phase === 'controls' ? (
        <div
          style={{
            position: 'absolute',
            // Vertical: the empty upper-left plot corner (the line rises to the right).
            left: vertical ? 185 : sideX,
            top: vertical ? 440 : 230,
            width: vertical ? 480 : 600,
            display: 'flex',
            flexDirection: 'column',
            gap: 24,
          }}
        >
          {phase === 'fit' ? eqPanel : null}
          {phase === 'controls' ? hookPanel : null}
          {phase === 'controls' && !vertical ? eqPanel : null}
        </div>
      ) : null}
      {phase === 'residuals' ? (
        <>
          <div
            style={{
              position: 'absolute',
              left: vertical ? 60 : sideX,
              top: vertical ? cy + chSmall + 30 : 230,
              opacity: ease(frame, 10, 14),
            }}
          >
            <ResidualPanel
              width={vertical ? 960 : 590}
              height={vertical ? 330 : 400}
              lang={lang}
              xs={cals.map((c) => c.conc)}
              residuals={cals.map((c) => c.residual)}
              xDomain={DOMAIN.x}
              tick={tick}
              t={resT}
              title={ui.residualsTitle}
            />
          </div>
          <div
            style={{
              position: 'absolute',
              left: vertical ? m.gutter : sideX,
              right: vertical ? m.gutter : m.gutter - 20,
              top: vertical ? cy + chSmall + 390 : 660,
              display: 'flex',
              flexWrap: 'wrap',
              justifyContent: vertical ? 'center' : 'flex-start',
              gap: 14,
            }}
          >
            {checks.map((c, i) => (
              <div key={c} style={{opacity: checkT[i], transform: `translateY(${(1 - checkT[i]) * 14}px)`}}>
                <Badge text={i === 0 ? `${ui.lookFor}: ${c}` : c} size={m.small * 0.82} tone="mint" />
              </div>
            ))}
            <div style={{opacity: limitsT, flexBasis: '100%', display: 'flex', justifyContent: vertical ? 'center' : 'flex-start'}}>
              <Badge text={ui.limitsNote} size={m.small * 0.82} tone="amber" />
            </div>
          </div>
        </>
      ) : null}
    </AbsoluteFill>
  );
};

// ---------------------------------------------------------------- phone
type Shot = {
  frame: string;
  w: number;
  /** Narration line (index in the scene) this shot belongs to: shots follow the voice. */
  cue?: number;
  mark?: string;
  tap?: boolean;
  callout: string;
  crop?: Rect;
  tone?: 'warn' | 'ok';
};

/** Shot windows in scene frames. Shots with `cue` are spread over the time of
 * that narration line (from just before it starts until the next line), so
 * the picture always shows what the voice is saying. */
function shotWindows(shots: Shot[], scene: LaidScene, fps: number) {
  const dur = scene.durationInFrames;
  const groups = new Map<number, number[]>();
  shots.forEach((s, i) => {
    const g = s.cue ?? 0;
    groups.set(g, [...(groups.get(g) ?? []), i]);
  });
  const keys = [...groups.keys()].sort((a, b) => a - b);
  const startOf = (g: number) => (g === keys[0] ? 0 : Math.max(0, Math.round(((scene.cues[g]?.start ?? 0) - 0.15) * fps)));
  const out: {from: number; to: number}[] = new Array(shots.length);
  keys.forEach((g, gi) => {
    const from = startOf(g);
    const to = gi + 1 < keys.length ? startOf(keys[gi + 1]) : dur;
    const idx = groups.get(g)!;
    const W = idx.reduce((a, i) => a + shots[i].w, 0);
    let acc = 0;
    idx.forEach((i) => {
      const a = from + Math.round(((to - from) * acc) / W);
      acc += shots[i].w;
      const b = from + Math.round(((to - from) * acc) / W);
      out[i] = {from: a, to: b};
    });
  });
  return out;
}

export const PhoneLayer: Layer = ({scene, ctx, prev}) => {
  const {frame, fps} = useT(scene);
  const {m, ui, lang, appFrames} = ctx;
  const vertical = V(ctx);
  const shots = (scene.props?.shots as Shot[]) ?? [];
  const win = shotWindows(shots, scene, fps);
  let i = win.findIndex((w) => frame >= w.from && frame < w.to);
  if (i < 0) i = frame < 0 ? 0 : shots.length - 1;
  const shot = shots[i];
  const local = frame - win[i].from;
  const len = win[i].to - win[i].from;
  const src = (id: string) => `frames/${lang}/${ctx.videoId}/${id}.png`;
  const meta = appFrames[shot.frame];
  const prevShots = prev?.layer === 'phone' ? ((prev.props?.shots as Shot[]) ?? []) : [];
  const prevFrame = i > 0 ? shots[i - 1].frame : prevShots.length ? prevShots[prevShots.length - 1].frame : null;
  const mix = prevFrame ? ease(local, 0, 9) : 1;
  const rect = shot.mark && meta?.marks?.[shot.mark] ? meta.marks[shot.mark] : null;
  const crop = shot.crop ?? null;
  const focus: [number, number] = crop
    ? [crop[0] + crop[2] / 2, crop[1] + crop[3] / 2]
    : rect
      ? [rect[0] + rect[2] / 2, rect[1] + rect[3] / 2]
      : [195, 422];
  const zoom = crop ? 1.5 + 0.06 * easeIO(local, 0, len) : 1.0 + 0.07 * easeIO(local, 0, len);
  const tone = shot.tone === 'warn' ? 'coral' : 'mint';
  const tapAt = shot.tap && meta?.tap ? meta.tap : null;
  const tapT = tapAt ? ease(local, len - 24, 16) : 0;
  const ct = ease(local, 2, 12);
  const step = scene.id === 'app_rules' ? '08' : scene.id === 'app_log' ? '09' : '07';
  const calloutColor = shot.tone === 'warn' ? color.coral : color.mint;
  const callout = (
    <div
      key={shot.frame}
      style={{
        ...rise(ct, 20),
        ...text(vertical ? 54 : 66, 700, calloutColor),
        letterSpacing: -0.6,
        textAlign: vertical ? 'center' : 'left',
        textWrap: 'balance' as never,
      }}
    >
      {ui[shot.callout] ?? shot.callout}
    </div>
  );
  const dots = (
    <div style={{display: 'flex', gap: 10, justifyContent: vertical ? 'center' : 'flex-start'}}>
      {shots.map((s, k) => (
        <div
          key={s.frame}
          style={{
            width: k === i ? 34 : 12,
            height: 12,
            borderRadius: 6,
            background: k === i ? calloutColor : color.line,
          }}
        />
      ))}
    </div>
  );
  const phone = (
    <PhoneFrame
      src={src(shot.frame)}
      prevSrc={prevFrame ? src(prevFrame) : null}
      mix={mix}
      width={vertical ? 600 : 450}
      zoom={zoom}
      focus={focus}
      mark={rect ? {rect, t: ease(local, 8, 12), tone} : null}
      tap={tapAt ? {at: tapAt, t: tapT} : null}
      crop={crop}
      tilt={vertical ? 0 : -7}
    />
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={step} kicker={ui.kickerApp} badge={{text: ui.realScreens, tone: 'mint'}} badgeBelow />
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 290, display: 'flex', flexDirection: 'column', gap: 16}}>
            {callout}
            {dots}
          </div>
          <div
            style={{
              position: 'absolute',
              left: (m.w - 600) / 2,
              top: 430,
              // Phone melts into the background where the subtitles sit.
              maskImage: 'linear-gradient(to bottom, black 76%, transparent 96%)',
              WebkitMaskImage: 'linear-gradient(to bottom, black 76%, transparent 96%)',
            }}
          >
            {phone}
          </div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: m.gutter, width: 1040, top: 300, display: 'flex', flexDirection: 'column', gap: 30}}>
            {callout}
            {dots}
            <div style={{display: 'flex', flexDirection: 'column', gap: 16, marginTop: 20}}>
              {shots.map((s, k) => (
                <div
                  key={s.frame}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 16,
                    ...text(m.body * 0.92, k === i ? 700 : 500, k === i ? color.ink : k < i ? color.inkDim : color.inkFaint),
                  }}
                >
                  <span style={{width: 30, color: k < i ? color.mint : k === i ? calloutColor : color.inkFaint}}>
                    {k < i ? '✓' : k === i ? '●' : '○'}
                  </span>
                  {ui[s.callout] ?? s.callout}
                </div>
              ))}
            </div>
          </div>
          <div style={{position: 'absolute', left: 1320, top: 66}}>{phone}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------------ CTA
export const Logo: React.FC<{size: number}> = ({size}) => (
  <Img
    src={staticFile('brand/logo_mark.png')}
    style={{
      width: size,
      height: size,
      borderRadius: size * 0.22,
      boxShadow: `0 30px 80px rgba(0,0,0,0.5), 0 0 0 2px rgba(255,255,255,0.08), 0 0 120px ${color.brandBright}44`,
    }}
  />
);

export const CtaLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = V(ctx);
  const lg = pop(frame, fps, 0);
  const wm = ease(frame, 6, 14);
  const t1 = ease(frame, cue(0), 16);
  const t2 = ease(frame, cue(0) + Math.round(1.4 * fps), 16);
  const c = pop(frame, fps, cue(1));
  const note = ease(frame, cue(1) + 10, 14);
  const serif = vertical ? 92 : 84;
  const block = (
    <>
      <div style={{...text(vertical ? 76 : 64, 700), letterSpacing: -1.5, opacity: wm}}>LabGuide</div>
      <div style={{height: vertical ? 30 : 18}} />
      <div style={{fontFamily: font.serif, fontSize: serif, lineHeight: 1.05, color: color.ink, ...rise(t1), textWrap: 'balance' as never}}>
        {ui.tagline1}
      </div>
      <div style={{fontFamily: font.serif, fontSize: serif, lineHeight: 1.05, color: color.mint, ...rise(t2), textWrap: 'balance' as never}}>
        {ui.tagline2}
      </div>
      <div style={{height: vertical ? 46 : 34}} />
      <div style={{opacity: c, transform: `scale(${0.92 + 0.08 * c})`, transformOrigin: vertical ? 'center' : 'left center'}}>
        <Pill text={ui.ctaPath} size={(vertical ? 46 : 40) * ([...ui.ctaPath].length > 28 ? (vertical ? 0.72 : 0.85) : 1)} tone="mint" />
      </div>
      <div style={{height: 22}} />
      <div style={{...text(m.small * 0.9, 500, color.inkDim), opacity: note, textWrap: 'balance' as never}}>{ui.ctaNote}</div>
    </>
  );
  if (vertical) {
    return (
      <AbsoluteFill>
        <div
          style={{
            position: 'absolute',
            left: m.gutter,
            right: m.gutter,
            top: 250,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            textAlign: 'center',
          }}
        >
          <div style={{transform: `scale(${0.8 + 0.2 * lg})`, opacity: lg}}>
            <Logo size={240} />
          </div>
          <div style={{height: 40}} />
          {block}
        </div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 190, top: 330, transform: `scale(${0.8 + 0.2 * lg})`, opacity: lg}}>
        <Logo size={300} />
      </div>
      <div style={{position: 'absolute', left: 620, right: m.gutter, top: 190, display: 'flex', flexDirection: 'column', alignItems: 'flex-start'}}>
        {block}
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  schematic: SchematicLayer,
  lightpath: LightPathLayer,
  calibrators: CalibratorsLayer,
  chart: ChartLayer,
  phone: PhoneLayer,
  cta: CtaLayer,
};

export type {LayerProps};
