// Visual layers of the topic video "Quality control: Levey–Jennings and
// Westgard rules". Every verdict, z-score and point comes from ctx.math
// (src/lib/qc.js — a port of the app's own rule engine). Reused: Plot
// (generic), PhoneShotsLayer, CtaLayer; new here only the LJ composition.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, pop} from '../../components/anim';
import {Badge, Pill, SceneHeader} from '../../components/Basics';
import {isV, txt, useT} from '../../components/layerKit';
import {PhoneShotsLayer} from '../../components/PhoneShots';
import {Plot, type PlotDomain, type PlotSeries} from '../../components/Plot';
import {color, font, tabular} from '../../design/theme';
import type {Layer, VideoCtx} from '../../framework/types';
import {fmt} from '../../lib/text.js';
import {CtaLayer} from '../calibration/layers';

const LEVEL_COLOR: Record<string, string> = {L1: color.beam, L2: color.mint};
const VERDICT_COLOR = {accept: color.inkDim, warning: color.amber, reject: color.coral} as const;

const zLabel = (v: number) => (v === 0 ? 'x̄' : `${v > 0 ? '+' : '−'}${Math.abs(v)}s`);
const zDomain = (x: [number, number], xTicks: number[]): PlotDomain => ({
  x,
  y: [-3.8, 3.8],
  xTicks,
  yTicks: [-3, -2, -1, 0, 1, 2, 3],
  yLabel: zLabel,
});

/** ±1/2/3 SD reference lines (as in the app's chart, Westgard 1981 fig. 2). */
const sdLines = (t = 1): PlotSeries[] => [
  {kind: 'band', y0: -1, y1: 1, color: color.mintSoft, opacity: 0.35, t},
  {kind: 'hline', y: 0, color: color.inkDim, width: 3, t},
  {kind: 'hline', y: 1, color: color.inkFaint, dash: '6 8', t},
  {kind: 'hline', y: -1, color: color.inkFaint, dash: '6 8', t},
  {kind: 'hline', y: 2, color: color.amber, dash: '10 8', t},
  {kind: 'hline', y: -2, color: color.amber, dash: '10 8', t},
  {kind: 'hline', y: 3, color: color.coral, dash: '10 8', t},
  {kind: 'hline', y: -3, color: color.coral, dash: '10 8', t},
];

type Res = {index: number; z: Record<string, number>; violations: {rule: string; levels: string[]}[]; rules: string[]; verdict: 'accept' | 'warning' | 'reject'};

/** Point shape/colour like the app's markFor(): per level involvement. */
function mark(r: Res, level: string) {
  const inv = r.violations.filter((v) => v.levels.includes(level));
  if (inv.some((v) => v.rule !== '1-2s')) return {shape: 'square' as const, c: color.coral};
  if (inv.length) return {shape: 'triangle' as const, c: color.amber};
  return {shape: 'circle' as const, c: LEVEL_COLOR[level]};
}

function runSeries(ctx: VideoCtx, upto: number, tOf: (n: number) => number, ringRuns: number[] = []): PlotSeries[] {
  const res = ctx.math.res as Res[];
  return (ctx.math.levels as {id: string}[]).map((l) => ({
    kind: 'points' as const,
    color: LEVEL_COLOR[l.id],
    join: true,
    pts: res.slice(0, upto).map((r) => {
      const m = mark(r, l.id);
      return {x: r.index + 1, y: r.z[l.id], color: m.c, shape: m.shape, t: tOf(r.index + 1), ring: ringRuns.includes(r.index + 1) && m.shape !== 'circle'};
    }),
  }));
}

const LevelKey: React.FC<{ctx: VideoCtx; size: number}> = ({ctx, size}) => (
  <div style={{display: 'flex', gap: 28, alignItems: 'center', flexWrap: 'wrap'}}>
    {(ctx.math.levels as {id: string; mean: number; sd: number}[]).map((l) => (
      <div key={l.id} style={{display: 'flex', alignItems: 'center', gap: 10, ...txt(size, 600, color.inkDim), ...tabular}}>
        <span style={{width: size * 0.7, height: size * 0.7, borderRadius: 99, background: LEVEL_COLOR[l.id]}} />
        {`${ctx.ui[`lvl_${l.id}`]} · x̄ ${fmt(l.mean, ctx.lang, 1)} · SD ${fmt(l.sd, ctx.lang, 1)}`}
      </div>
    ))}
  </div>
);

const VerdictPill: React.FC<{ctx: VideoCtx; r: Res; size: number; t: number}> = ({ctx, r, size, t}) => {
  const c = VERDICT_COLOR[r.verdict];
  const rules = r.rules.filter((x) => r.verdict !== 'reject' || x !== '1-2s');
  return (
    <div style={{opacity: t, transform: `scale(${0.9 + 0.1 * t})`, transformOrigin: 'left center', display: 'inline-flex', flexDirection: 'column', gap: 6, padding: '16px 24px', borderRadius: 22, border: `2.5px solid ${c}`, background: 'rgba(6,20,16,0.9)'}}>
      <div style={{...txt(size * 0.72, 600, color.inkDim)}}>{`${ctx.ui.axisRun} ${r.index + 1}`}</div>
      <div style={{...txt(size * 1.2, 700, c)}}>{`${ctx.ui[r.verdict]}${rules.length ? ' · ' + rules.join(', ') : ''}`}</div>
    </div>
  );
};

// ------------------------------------------------------------------ hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui, vars} = ctx;
  const vertical = isV(ctx);
  const res = ctx.math.res as Res[];
  const hookRun = ctx.math.hookRun as number;
  const r = res[hookRun - 1];
  const pop6 = pop(frame, fps, 14);
  const series: PlotSeries[] = [
    ...sdLines(1),
    {
      kind: 'points',
      color: color.beam,
      join: true,
      pts: res.slice(0, hookRun).map((q) => ({x: q.index + 1, y: q.z.L1, t: q.index + 1 < hookRun ? 1 : pop6, color: q.index + 1 === hookRun ? color.amber : color.beam, shape: q.index + 1 === hookRun ? 'triangle' : 'circle', ring: q.index + 1 === hookRun, r: vertical ? 13 : 11})),
    },
  ];
  const big = (
    <div style={{...txt(m.display * 0.8, 700, color.amber), ...tabular, letterSpacing: -4, lineHeight: 1, opacity: ease(frame, 16, 10)}}>{`+${vars.hookZ} SD`}</div>
  );
  const q = pop(frame, fps, cue(1));
  const question = (
    <div style={{...txt(m.h1, 700, color.ink), opacity: q, transform: `scale(${0.92 + 0.08 * q})`, transformOrigin: vertical ? 'center' : 'left center', textWrap: 'balance' as never}}>{ui.hookQ}</div>
  );
  const plot = (
    <Plot
      width={vertical ? 940 : 900}
      height={vertical ? 640 : 620}
      lang={ctx.lang}
      tick={vertical ? 28 : 24}
      domain={zDomain([0.5, hookRun + 0.6], [1, 2, 3, 4, 5, 6])}
      axisX={ui.axisRun}
      series={series}
      idPrefix={`qchook-${ctx.format}`}
    />
  );
  const badge = <Badge text={ui.illustrative} tone="amber" size={m.small * 0.8} />;
  const level = <div style={{...txt(m.small, 600, color.inkDim), ...tabular}}>{`${ui.lvl_L1} · x̄ ${fmt(ctx.math.hook.mean, ctx.lang, 2)} → ${vars.hookX}`}</div>;
  void r;
  if (vertical) {
    return (
      <AbsoluteFill>
        <div style={{position: 'absolute', left: 70, top: 220}}>{plot}</div>
        <div style={{position: 'absolute', left: m.gutter, top: 150, opacity: ease(frame, 20, 12)}}>{badge}</div>
        <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 930, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 22, textAlign: 'center'}}>
          {big}
          {level}
          <div style={{height: 10}} />
          {question}
        </div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 90, top: 190}}>{plot}</div>
      <div style={{position: 'absolute', left: 1120, right: m.gutter, top: 300, display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 22}}>
        {big}
        {level}
        <div style={{height: 8}} />
        {question}
        <div style={{height: 18}} />
        <div style={{opacity: ease(frame, 20, 12)}}>{badge}</div>
      </div>
    </AbsoluteFill>
  );
};

// ---------------------------------------------------------- LJ (3 phases)
export const LjLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd, dur} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const phase = (scene.props?.phase as string) ?? 'build';
  const upto = (scene.props?.upto as number) ?? 5;
  const res = ctx.math.res as Res[];
  const n = (ctx.math.runs as unknown[]).length;
  const first = phase === 'build' ? 1 : phase === 'warn' ? 6 : 7;
  const span = Math.max(fps * 1.5, (phase === 'build' ? cueEnd(0) : phase === 'warn' ? fps * 0.8 : cueEnd(0) * 0.6) - cue(0));
  const startOf = (k: number) => cue(0) + Math.round(((k - first) * span) / Math.max(1, upto - first + 1));
  const tOf = (k: number) => (k < first ? 1 : ease(frame, startOf(k), 10));
  const axesT = phase === 'build' ? ease(frame, 0, 16) : 1;
  const linesT = phase === 'build' ? ease(frame, 6, 18) : 1;
  const ring = phase === 'warn' ? [6] : phase === 'shift' ? [10] : [];
  const series: PlotSeries[] = [...sdLines(linesT)];
  if (phase === 'shift') {
    const t = ease(frame, startOf(10) + 6, 12);
    series.push({kind: 'xband', x0: 8.55, x1: 10.45, color: color.coralSoft, t, opacity: 0.9});
  }
  series.push(...runSeries(ctx, upto, tOf, ring));
  const latest = res[upto - 1];
  const vT = phase === 'build' ? 0 : ease(frame, startOf(upto) + 8, 12);
  const W = vertical ? 960 : 1060;
  const H = vertical ? 720 : 640;
  const header = phase === 'build' ? ui.kickerChart : phase === 'warn' ? ui.kickerWarn : ui.kickerShift;
  const note =
    phase === 'build'
      ? {text: ui.targetsNote, tone: 'mint' as const, t: ease(frame, cue(1), 14)}
      : phase === 'warn'
        ? {text: ui.warnNote, tone: 'amber' as const, t: ease(frame, cue(1), 14)}
        : {text: `${ui.rejectRun} · ${ui.findCause}`, tone: 'amber' as const, t: ease(frame, startOf(10) + 20, 12)};
  void dur;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={header} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: vertical ? 50 : 80, top: vertical ? 380 : 190}}>
        <Plot
          width={W}
          height={H}
          lang={ctx.lang}
          tick={vertical ? 28 : 24}
          domain={zDomain([0.5, n + 0.5], Array.from({length: n}, (_, i) => i + 1))}
          axisX={ui.axisRun}
          axesT={axesT}
          series={series}
          idPrefix={`lj-${scene.id}-${ctx.format}`}
        />
      </div>
      <div style={{position: 'absolute', left: vertical ? m.gutter : 1210, right: m.gutter, top: vertical ? 1130 : 230, display: 'flex', flexDirection: 'column', gap: 26, alignItems: vertical ? 'center' : 'flex-start'}}>
        <div style={{opacity: axesT}}>
          <LevelKey ctx={ctx} size={m.small * 0.9} />
        </div>
        {phase !== 'build' ? <VerdictPill ctx={ctx} r={latest} size={m.body} t={vT} /> : null}
        <div style={{opacity: note.t, transform: `translateY(${(1 - note.t) * 12}px)`}}>
          <Badge text={note.text} tone={note.tone} size={m.small * 0.82} maxWidth={vertical ? 900 : 580} />
        </div>
        <div style={{...txt(m.small * 0.78, 500, color.inkFaint), opacity: phase === 'build' ? 0 : 1}}>{ui.computedRules}</div>
      </div>
    </AbsoluteFill>
  );
};

// ---------------------------------------------------------------- z-score
export const ZLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui, lang} = ctx;
  const vertical = isV(ctx);
  const h = ctx.math.hook as {x: number; mean: number; sd: number; z: number};
  const slide = easeIO(frame, cue(0) + Math.round(0.6 * fps), Math.round(1.4 * fps));
  const zNow = h.z * slide;
  const W = vertical ? 900 : 1300;
  const x0 = 60;
  const sx = (z: number) => x0 + ((z + 3.5) / 7) * (W - 2 * x0);
  const ex = ease(frame, cue(0) + Math.round(1.6 * fps), 14);
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={ui.kickerZ} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: 0, right: 0, top: vertical ? 420 : 250, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: vertical ? 60 : 44}}>
        <div style={{...txt(vertical ? 76 : 70, 700, color.mint), opacity: ease(frame, 4, 14)}}>{ui.zFormula}</div>
        <svg width={W} height={190} style={{overflow: 'visible'}}>
          <rect x={sx(-1)} width={sx(1) - sx(-1)} y={40} height={70} fill={color.mintSoft} opacity={0.5} />
          <line x1={sx(-3.5)} x2={sx(3.5)} y1={110} y2={110} stroke={color.inkDim} strokeWidth={3} />
          {[-3, -2, -1, 0, 1, 2, 3].map((v) => (
            <g key={v}>
              <line x1={sx(v)} x2={sx(v)} y1={v === 0 ? 30 : 60} y2={118} stroke={Math.abs(v) === 3 ? color.coral : Math.abs(v) === 2 ? color.amber : color.inkFaint} strokeWidth={3} strokeDasharray={v === 0 ? undefined : '6 6'} />
              <text x={sx(v)} y={160} fill={color.inkDim} fontFamily={font.sans} fontSize={vertical ? 30 : 28} fontWeight={600} textAnchor="middle">
                {zLabel(v)}
              </text>
            </g>
          ))}
          <g transform={`translate(${sx(zNow)}, 110)`}>
            <path d="M 0 -48 L 22 -12 L -22 -12 Z" fill={color.amber} stroke={color.bg0} strokeWidth={3} />
            <text y={-62} fill={color.amber} fontFamily={font.sans} fontSize={vertical ? 38 : 34} fontWeight={700} textAnchor="middle" style={{fontVariantNumeric: 'tabular-nums'}}>
              {`z = ${zNow >= 0 ? '+' : '−'}${fmt(Math.abs(zNow), lang, 1)}`}
            </text>
          </g>
        </svg>
        <div style={{...txt(vertical ? 50 : 52, 700, color.ink), ...tabular, opacity: ex, whiteSpace: 'nowrap'}}>
          {`(${fmt(h.x, lang, 2)} − ${fmt(h.mean, lang, 2)}) ÷ ${fmt(h.sd, lang, 2)} = +${fmt(h.z, lang, 1)}`}
        </div>
        <div style={{...txt(m.small, 600, color.inkDim), opacity: ex}}>{`${ui.lvl_L1} · x̄ ${fmt(h.mean, lang, 1)} · SD ${fmt(h.sd, lang, 1)}`}</div>
      </div>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------ rule cards
type Card = {rule: string; levels: string[]; runs: number[][]; window: number; result: Res};

const RuleCard: React.FC<{ctx: VideoCtx; card: Card; t: number; w: number; h: number; tone: 'coral' | 'amber'}> = ({ctx, card, t, w, h, tone}) => {
  const vertical = isV(ctx);
  const n = card.runs.length;
  const c = tone === 'coral' ? color.coral : color.amber;
  const plotW = vertical ? 400 : w - 40;
  const plotH = vertical ? h - 40 : h * 0.55;
  const series: PlotSeries[] = [
    ...sdLines(1),
    ...card.levels.map((id, k) => ({
      kind: 'points' as const,
      color: LEVEL_COLOR[id],
      join: true,
      pts: card.runs.map((zs, i) => {
        const hot = i >= n - card.window;
        const viol = hot && (card.rule === '10x' || card.rule === '4-1s' || card.rule === '2-2s' ? true : Math.abs(zs[k]) > 2);
        return {x: i + 1, y: zs[k], color: viol ? c : LEVEL_COLOR[id], shape: viol ? ('square' as const) : ('circle' as const), r: 8, t: Math.min(1, t * 1.6 - (i / n) * 0.5)};
      }),
    })),
  ];
  const plot = (
    <Plot
      width={plotW}
      height={plotH}
      lang={ctx.lang}
      tick={18}
      margins={[2.6, 0.8, 0.6, 0.6]}
      domain={zDomain([0.4, n + 0.6], [])}
      hideXTicks
      series={series}
      idPrefix={`card-${card.rule}-${ctx.format}`}
    />
  );
  const text = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 10, minWidth: 0}}>
      <div style={{...txt(vertical ? 60 : 56, 700, c), letterSpacing: -1}}>{card.rule}</div>
      <div style={{...txt(vertical ? 32 : 28, 600, color.ink), textWrap: 'balance' as never}}>{ctx.ui[`d_${card.rule}`]}</div>
      <div style={{...txt(vertical ? 26 : 24, 600, color.inkDim)}}>{`→ ${ctx.ui.rejectRun}`}</div>
    </div>
  );
  return (
    <div
      style={{
        width: w,
        height: h,
        boxSizing: 'border-box',
        padding: vertical ? '18px 24px' : '22px 24px',
        borderRadius: 26,
        background: 'rgba(6,20,16,0.88)',
        border: `2px solid ${c}55`,
        display: 'flex',
        flexDirection: vertical ? 'row' : 'column',
        gap: vertical ? 26 : 14,
        alignItems: vertical ? 'center' : 'stretch',
        opacity: Math.min(1, t * 1.5),
        transform: `translateY(${(1 - t) * 24}px)`,
      }}
    >
      {vertical ? (
        <>
          {plot}
          {text}
        </>
      ) : (
        <>
          {text}
          {plot}
        </>
      )}
    </div>
  );
};

export const RulesLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const ids = (scene.props?.cards as string[]) ?? [];
  const kind = scene.props?.kind as string;
  const all = ctx.math.cards as Card[];
  const cards = ids.map((id) => all.find((c) => c.rule === id)!);
  const span = Math.max(fps, cueEnd(0) - cue(0));
  const tone = kind === 'random' ? ('coral' as const) : ('amber' as const);
  const w = vertical ? m.w - 2 * 70 : cards.length === 3 ? 520 : 760;
  const h = vertical ? 300 : 560;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={scene.props?.step as string} kicker={kind === 'random' ? ui.kickerRandom : ui.kickerSys} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div
        style={{
          position: 'absolute',
          left: vertical ? 70 : 0,
          right: vertical ? 70 : 0,
          top: vertical ? 380 : 250,
          display: 'flex',
          flexDirection: vertical ? 'column' : 'row',
          justifyContent: 'center',
          gap: vertical ? 30 : 40,
        }}
      >
        {cards.map((c, i) => (
          <RuleCard key={c.rule} ctx={ctx} card={c} w={w} h={h} tone={tone} t={ease(frame, cue(0) + Math.round((span * i) / cards.length), 18)} />
        ))}
      </div>
      <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: vertical ? 380 + cards.length * 330 + 10 : 850, display: 'flex', justifyContent: 'center', opacity: ease(frame, cueEnd(0) - 10, 12)}}>
        <Pill text={ui.computedRules} size={m.small * 0.85} tone="mint" />
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  lj: LjLayer,
  zscore: ZLayer,
  rules: RulesLayer,
  phone: PhoneShotsLayer,
  cta: CtaLayer,
};

export {LEVEL_COLOR, sdLines, zDomain, runSeries};
