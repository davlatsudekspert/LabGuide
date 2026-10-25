// Visual layers of flagship 2 "Leukocyte differential count". Pure functions
// of (scene, ctx, frame); vertical 9:16 and horizontal 16:9 from the same
// component; language only changes text and the real app frames. Every
// number comes from ctx.math (src/lib/differential.js) — nothing typed in.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, lerp, pop, rise} from '../../components/anim';
import {Badge, Pill, SceneHeader} from '../../components/Basics';
import {CellPortrait, type CellKind} from '../../components/Cells';
import {isV, txt, useT} from '../../components/layerKit';
import {fieldItems, MicroscopeField, trackWorld, type WorldWbc} from '../../components/MicroscopeField';
import {PhoneFrame} from '../../components/PhoneFrame';
import {PhoneShotsLayer} from '../../components/PhoneShots';
import {color, font, tabular} from '../../design/theme';
import type {Layer, LaidScene, VideoCtx} from '../../framework/types';
import {fmtMax, tallyAt} from '../../lib/differential.js';
import {fill} from '../../lib/text.js';
import {CtaLayer} from '../calibration/layers';

/** Counting classes shown in tallies (the app's "Other" only when counted). */
const TALLY: CellKind[] = ['segmented', 'band', 'lymphocyte', 'monocyte', 'eosinophil', 'basophil'];
const GALLERY: CellKind[] = ['segmented', 'band', 'eosinophil', 'basophil', 'lymphocyte', 'monocyte'];

/** Stain-evocative accent per class (bars, rings, labels). */
export const classColor: Record<CellKind, string> = {
  segmented: '#D3A6E8',
  band: '#B98FE0',
  lymphocyte: '#7DB8F0',
  monocyte: '#AFC0D8',
  eosinophil: '#F39066',
  basophil: '#8C7BEA',
  other: '#C8D3E6',
};

const seqKinds = (ctx: VideoCtx) => ctx.math.sequence as CellKind[];

// ------------------------------------------------------------- paper tally
const TallyPaper: React.FC<{
  counts: Record<string, number>;
  ui: Record<string, string>;
  width: number;
  sum: React.ReactNode;
  wobble: number;
}> = ({counts, ui, width, sum, wobble}) => {
  const colW = width / TALLY.length;
  const g = Math.min(46, colW * 0.36);
  const strokeH = g * 0.78;
  const rowH = strokeH + 14;
  const rows = 6;
  const height = 86 + rows * rowH + 80;
  return (
    <div
      style={{
        width,
        height,
        borderRadius: 18,
        background: 'linear-gradient(180deg,#F7F1E3 0%,#EFE6D2 100%)',
        boxShadow: '0 30px 80px rgba(0,0,0,0.5)',
        position: 'relative',
        overflow: 'hidden',
        transform: `rotate(${-1.2 + wobble * 0.6}deg)`,
      }}
    >
      <svg width={width} height={height} style={{position: 'absolute', left: 0, top: 0}}>
        {Array.from({length: rows + 1}, (_, r) => (
          <line key={r} x1={0} x2={width} y1={86 + r * rowH} y2={86 + r * rowH} stroke="#B9C9DD" strokeWidth={1.5} />
        ))}
        {TALLY.map((_, i) =>
          i > 0 ? <line key={i} x1={i * colW} x2={i * colW} y1={20} y2={height - 20} stroke="#D7A9A2" strokeWidth={1.5} /> : null,
        )}
        {TALLY.map((c, i) => {
          const n = counts[c] ?? 0;
          const marks: React.ReactNode[] = [];
          for (let q = 0; q < n; q++) {
            const row = Math.floor(q / 10);
            if (row >= rows) break;
            const inRow = q % 10;
            const grp = Math.floor(inRow / 5);
            const pos = inRow % 5;
            const gx = i * colW + colW * 0.12 + grp * (g + 10);
            const y0 = 86 + row * rowH + 7;
            const jit = Math.sin(q * 12.9898 + i) * 1.6;
            if (pos < 4) {
              const x = gx + pos * (g / 4.4) + jit * 0.4;
              marks.push(<line key={q} x1={x} y1={y0 + jit * 0.3} x2={x + 2 + jit * 0.4} y2={y0 + strokeH} stroke="#33405A" strokeWidth={3.2} strokeLinecap="round" />);
            } else {
              marks.push(<line key={q} x1={gx - 4} y1={y0 + strokeH - 3} x2={gx + g * 0.82} y2={y0 + 3} stroke="#33405A" strokeWidth={3.2} strokeLinecap="round" />);
            }
          }
          return <g key={c}>{marks}</g>;
        })}
      </svg>
      {TALLY.map((c, i) => (
        <div
          key={c}
          style={{
            position: 'absolute',
            left: i * colW,
            width: colW,
            top: 26,
            textAlign: 'center',
            ...txt(Math.min(34, (colW * 1.5) / Math.max(5, [...(ui[`s_${c}`] ?? '')].length)), 700, '#33405A'),
            fontFamily: font.sans,
          }}
        >
          {ui[`s_${c}`]}
        </div>
      ))}
      <div style={{position: 'absolute', left: 30, bottom: 18, display: 'flex', alignItems: 'baseline', gap: 18}}>{sum}</div>
    </div>
  );
};

// ------------------------------------------------------------------ hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const math = ctx.math;
  const {wbcs, at} = React.useMemo(() => trackWorld(seqKinds(ctx), 42), [ctx]);
  const p = 0.55 + 0.45 * ease(frame, 0, Math.round(1.6 * fps));
  const nShown = Math.round(math.hook.a * p);
  const counts = tallyAt(math.sequence, nShown);
  const flip = frame >= cue(0) + Math.round(1.15 * fps);
  const shake = flip ? Math.sin(frame * 1.7) * Math.max(0, 1 - (frame - cue(0) - 1.15 * fps) / 14) * 8 : 0;
  const lost = pop(frame, fps, cue(1));
  const s = 30 + frame * 2.6;
  const fieldSize = vertical ? 700 : 740;
  const sumNode = (
    <>
      <span style={{...txt(44, 700, '#33405A')}}>{ui.hookSum}</span>
      <span style={{...txt(64, 800, flip ? '#C2412E' : '#33405A'), ...tabular, display: 'inline-block', transform: `translateX(${shake}px)`}}>
        {flip ? `${math.hook.b}?` : nShown}
      </span>
      {flip ? <span style={{...txt(40, 700, '#8A93A6'), textDecoration: 'line-through'}}>{math.hook.a}</span> : null}
    </>
  );
  const field = (
    <MicroscopeField size={fieldSize} viewUm={66} center={at(s)} wbcs={wbcs} id="hookf" blur={0.6} reticle />
  );
  const paper = <TallyPaper counts={counts} ui={ui} width={vertical ? 912 : 820} sum={sumNode} wobble={lost} />;
  const lostTag = (
    <div style={{opacity: lost, transform: `scale(${0.85 + 0.15 * lost})`, transformOrigin: 'left center'}}>
      <Pill text={ui.hookLost} size={vertical ? 52 : 46} tone="coral" />
    </div>
  );
  const badge = (
    <div style={{opacity: ease(frame, 10, 12)}}>
      <Badge text={ui.illustrative} tone="amber" size={m.small * 0.78} />
    </div>
  );
  if (vertical) {
    return (
      <AbsoluteFill>
        <div style={{position: 'absolute', left: (m.w - fieldSize) / 2, top: 130}}>{field}</div>
        <div style={{position: 'absolute', left: m.gutter, top: 880}}>{paper}</div>
        <div style={{position: 'absolute', right: m.gutter, top: 770}}>{lostTag}</div>
        <div style={{position: 'absolute', left: m.gutter, top: 1440}}>{badge}</div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 110, top: 150}}>{field}</div>
      <div style={{position: 'absolute', left: 960, top: 190}}>{paper}</div>
      <div style={{position: 'absolute', left: 1380, top: 86}}>{lostTag}</div>
      <div style={{position: 'absolute', left: 990, top: 840}}>{badge}</div>
    </AbsoluteFill>
  );
};

// -------------------------------------------------------------- smear strip
/** Side view of a slide with a pushed film: thick end → body → monolayer → feathered thin end. */
const SmearSlide: React.FC<{width: number; t: number; zoneT: number; ui: Record<string, string>; size: number}> = ({width, t, zoneT, ui, size}) => {
  const h = width * 0.16;
  const film = `M${width * 0.08},${h * 0.2} L${width * 0.62},${h * 0.18} C${width * 0.8},${h * 0.16} ${width * 0.9},${h * 0.32} ${width * 0.93},${h * 0.5} C${width * 0.9},${h * 0.68} ${width * 0.8},${h * 0.84} ${width * 0.62},${h * 0.82} L${width * 0.08},${h * 0.8} Z`;
  return (
    <div style={{width, position: 'relative', opacity: t}}>
      <svg width={width} height={h + 6} style={{display: 'block'}}>
        <defs>
          <linearGradient id="smear-g" x1="0" x2="1">
            <stop offset="0%" stopColor="#B04A66" />
            <stop offset="45%" stopColor="#D27E8E" />
            <stop offset="78%" stopColor="#E9B1B5" stopOpacity={0.9} />
            <stop offset="100%" stopColor="#F3D3D3" stopOpacity={0.5} />
          </linearGradient>
        </defs>
        <rect x={1} y={1} width={width - 2} height={h} rx={10} fill="rgba(220,240,235,0.10)" stroke="rgba(220,240,235,0.45)" strokeWidth={2} />
        <rect x={width * 0.012} y={h * 0.08} width={width * 0.05} height={h * 0.84} rx={4} fill="rgba(255,255,255,0.28)" />
        <path d={film} fill="url(#smear-g)" />
        <rect
          x={width * 0.7}
          y={h * 0.1}
          width={width * 0.14}
          height={h * 0.8}
          rx={8}
          fill="none"
          stroke={color.mint}
          strokeWidth={4}
          strokeDasharray="10 7"
          opacity={zoneT}
        />
      </svg>
      <div style={{position: 'relative', height: size * 1.4, marginTop: 10, ...txt(size, 600, color.inkDim)}}>
        <span style={{position: 'absolute', left: 0}}>{ui.smearThick}</span>
        <span style={{position: 'absolute', right: 0}}>{ui.smearThin}</span>
      </div>
      <div
        style={{
          position: 'absolute',
          left: width * 0.77 - 200,
          width: 400,
          top: -size * 1.5,
          textAlign: 'center',
          opacity: zoneT,
          ...txt(size, 700, color.mint),
        }}
      >
        {ui.smearZone}
      </div>
    </div>
  );
};

// ----------------------------------------------------------------- field
export const FieldLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const size = vertical ? 860 : 760;
  const viewUm = lerp(84, 62, easeIO(frame, 0, Math.round(1.6 * fps)));
  const wbcs: WorldWbc[] = React.useMemo(() => [{id: 'n1', x: 9, y: -6, kind: 'segmented', seed: 23}], []);
  const center: [number, number] = [-6 + frame * 0.05, 4];
  const k = size / viewUm;
  const toPx = (x: number, y: number): [number, number] => [size / 2 + (x - center[0]) * k, size / 2 + (y - center[1]) * k];
  const items = fieldItems(center, viewUm, wbcs);
  const nearest = <T extends {x: number; y: number}>(arr: T[], x: number, y: number) =>
    arr.reduce((b, a) => ((a.x - x) ** 2 + (a.y - y) ** 2 < (b.x - x) ** 2 + (b.y - y) ** 2 ? a : b), arr[0]);
  const rbc = vertical ? nearest(items.rbcs, -20, 22) : nearest(items.rbcs, 24, 6);
  const plt = items.platelets.length ? (vertical ? nearest(items.platelets, 16, 24) : nearest(items.platelets, 22, 22)) : null;
  // Labels belong to the first line; they give way to the smear diagram (second line).
  const out = 1 - ease(frame, cue(1) - 10, 10);
  const lab = [
    {key: 'wbc', text: ui.lblWbc, at: toPx(9, -6), t: ease(frame, 20, 14) * out, c: classColor.segmented},
    {key: 'rbc', text: ui.lblRbc, at: toPx(rbc.x, rbc.y), t: ease(frame, 34, 14) * out, c: '#F2A8A0'},
    ...(plt ? [{key: 'plt', text: ui.lblPlt, at: toPx(plt.x, plt.y), t: ease(frame, 48, 14) * out, c: '#C9A0E6'}] : []),
  ]
    .filter((l) => l.at[0] > 40 && l.at[0] < size - 40 && l.at[1] > 40 && l.at[1] < size - 40)
    .sort((p, q) => (vertical ? p.at[0] - q.at[0] : p.at[1] - q.at[1]));
  const fx = vertical ? (m.w - size) / 2 : 120;
  const fy = vertical ? 330 : 190;
  // Label positions (absolute canvas), leader from label to target.
  const labelPos = (i: number): [number, number] =>
    vertical ? [m.gutter + i * 300, fy + size + 34] : [fx + size + 80, fy + 120 + i * 120];
  const zoneT = ease(frame, cue(1), 16);
  const chipT = ease(frame, 6, 14);
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="01" kicker={ui.kickerField} badge={{text: ui.schematicNote}} />
      <div style={{position: 'absolute', left: fx, top: fy}}>
        <MicroscopeField size={size} viewUm={viewUm} center={center} wbcs={wbcs} id="fieldf" reticle />
      </div>
      <div style={{position: 'absolute', left: fx + (vertical ? size - 330 : size - 300), top: fy - (vertical ? 4 : 10), opacity: chipT}}>
        <Pill text={ui.oilChip} size={vertical ? 34 : 30} tone="mint" />
      </div>
      <svg width={m.w} height={m.h} style={{position: 'absolute', left: 0, top: 0, pointerEvents: 'none'}}>
        {lab.map((l, i) => {
          const [lx, ly] = labelPos(i);
          const tx = fx + l.at[0];
          const ty = fy + l.at[1];
          const sx = vertical ? lx + 20 : lx - 14;
          const sy = vertical ? ly - 8 : ly + 26;
          return (
            <g key={l.key} opacity={l.t}>
              <line x1={sx} y1={sy} x2={lerp(sx, tx, l.t)} y2={lerp(sy, ty, l.t)} stroke={l.c} strokeWidth={3} />
              <circle cx={tx} cy={ty} r={9 * l.t} fill="none" stroke={l.c} strokeWidth={3} />
            </g>
          );
        })}
      </svg>
      {lab.map((l, i) => {
        const [lx, ly] = labelPos(i);
        return (
          <div key={l.key} style={{position: 'absolute', left: lx, top: ly, ...rise(l.t, 12), ...txt(vertical ? 38 : 40, 700, l.c)}}>
            {l.text}
          </div>
        );
      })}
      <div
        style={{
          position: 'absolute',
          left: vertical ? m.gutter : fx + size + 80,
          top: vertical ? 1215 : 560,
          width: vertical ? m.w - 2 * m.gutter : 860,
          display: 'flex',
          flexDirection: 'column',
          gap: 22,
        }}
      >
        <SmearSlide width={vertical ? m.w - 2 * m.gutter : 860} t={ease(frame, cue(1) - 4, 14)} zoneT={zoneT} ui={ui} size={vertical ? 28 : 28} />
        <div style={{opacity: ease(frame, cue(1) + 12, 14)}}>
          <Badge text={ui.monolayer} tone="mint" size={m.small * 0.8} />
        </div>
      </div>
    </AbsoluteFill>
  );
};

// ----------------------------------------------------------------- cells
/** Index (in GALLERY order) of the cell being described at this frame. */
function activeCell(scene: LaidScene, frame: number, fps: number) {
  const focus = (scene.props?.focus as CellKind[]) ?? [];
  let k = 0;
  scene.cues.forEach((c, i) => {
    if (frame >= Math.round((c.start - 0.25) * fps)) k = i;
  });
  return GALLERY.indexOf(focus[Math.min(k, focus.length - 1)]);
}

export const CellsLayer: Layer = ({scene, ctx}) => {
  const {frame, fps} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const a = activeCell(scene, frame, fps);
  // Frame at which `a` became active (for the cross-fade).
  let since = 0;
  scene.cues.forEach((c, i) => {
    const f = Math.round((c.start - 0.25) * fps);
    const focus = (scene.props?.focus as CellKind[]) ?? [];
    if (GALLERY.indexOf(focus[i]) === a) since = Math.max(0, f);
  });
  const prevA = a > 0 ? a - 1 : -1;
  const local = frame - since;
  const mix = scene.index > 0 || a > 0 ? ease(local, 0, 12) : 1;
  const kind = GALLERY[a];
  const big = vertical ? 600 : 640;
  const viewUm = 30;
  const firstScene = scene.id === 'cells_gran';
  const intro = firstScene ? ease(frame, 0, 14) : 1;
  const thumb = vertical ? 138 : 104;
  const gallery = (
    <div style={{display: 'flex', gap: vertical ? 16 : 14, justifyContent: vertical ? 'center' : 'flex-start'}}>
      {GALLERY.map((g, i) => {
        const on = i === a;
        const t = firstScene ? pop(frame, fps, i * 3) : 1;
        return (
          <div key={g} style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, opacity: (on ? 1 : i < a ? 0.75 : 0.5) * t}}>
            <div
              style={{
                borderRadius: 999,
                boxShadow: on ? `0 0 0 5px ${color.mint}, 0 0 34px ${color.mint}66` : `0 0 0 2px ${color.line}`,
                transform: `scale(${on ? 1.06 : 1})`,
              }}
            >
              <CellPortrait kind={g} size={thumb} viewUm={22} seed={9 + i} id={`th-${g}`} withRbc={false} />
            </div>
            <div style={{...txt(vertical ? 25 : 22, on ? 700 : 500, on ? color.ink : color.inkDim)}}>{ui[`s_${g}`]}</div>
          </div>
        );
      })}
    </div>
  );
  const portrait = (g: number, o: number) => (
    <div style={{position: 'absolute', left: 0, top: 0, opacity: o}}>
      <div style={{borderRadius: 999, boxShadow: `0 40px 120px rgba(0,0,0,0.55), 0 0 0 3px rgba(255,255,255,0.08)`}}>
        <CellPortrait kind={GALLERY[g]} size={big} viewUm={viewUm} seed={5 + g * 7} id={`big-${GALLERY[g]}`} />
      </div>
    </div>
  );
  const ft = (i: number) => ease(local, 8 + i * 9, 14);
  const info = (
    <div style={{display: 'flex', flexDirection: 'column', gap: vertical ? 14 : 18}}>
      <div style={{...rise(ease(local, 2, 12), 16), ...txt(vertical ? 62 : 66, 700), letterSpacing: -1, textWrap: 'balance' as never}}>{ui[`n_${kind}`]}</div>
      <div style={{...rise(ease(local, 5, 12), 14), ...txt(vertical ? 38 : 40, 700, classColor[kind])}}>{ui[`z_${kind}`]}</div>
      {[1, 2].map((i) => (
        <div key={i} style={{display: 'flex', gap: 16, alignItems: 'flex-start', ...rise(ft(i), 12)}}>
          <span style={{width: 14, height: 14, marginTop: vertical ? 14 : 16, borderRadius: 99, background: classColor[kind], flex: 'none'}} />
          <span style={{...txt(vertical ? 38 : 40, 500, color.ink), lineHeight: 1.22}}>{ui[`f_${kind}_${i}`]}</span>
        </div>
      ))}
    </div>
  );
  const scale = <div style={{...txt(vertical ? 24 : 24, 500, color.inkFaint), opacity: intro}}>{ui.rbcScale}</div>;
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="02" kicker={ui.kickerCells} badge={{text: ui.schematicNote}} />
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: 0, right: 0, top: 300}}>{gallery}</div>
          <div style={{position: 'absolute', left: (m.w - big) / 2, top: 540, width: big, height: big, opacity: intro}}>
            {prevA >= 0 && mix < 1 ? portrait(prevA, 1) : null}
            {portrait(a, mix)}
          </div>
          <div style={{position: 'absolute', right: m.gutter, top: 540 + big - 20}}>{scale}</div>
          <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 1185}}>{info}</div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 150, top: 205, width: big, height: big, opacity: intro}}>
            {prevA >= 0 && mix < 1 ? portrait(prevA, 1) : null}
            {portrait(a, mix)}
          </div>
          <div style={{position: 'absolute', left: 150, top: 862, width: big, textAlign: 'center'}}>{scale}</div>
          <div style={{position: 'absolute', left: 900, right: m.gutter, top: 250}}>{info}</div>
          <div style={{position: 'absolute', left: 900, top: 690}}>{gallery}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

// ----------------------------------------------------------------- track
const TallyPanel: React.FC<{
  counts: Record<string, number>;
  total: number;
  target: number;
  ui: Record<string, string>;
  width: number;
  rowH: number;
  size: number;
  bump: Partial<Record<CellKind, number>>;
}> = ({counts, total, target, ui, width, rowH, size, bump}) => {
  const barW = width - size * 8.4;
  return (
    <div
      style={{
        width,
        padding: '22px 28px',
        boxSizing: 'border-box',
        borderRadius: 26,
        background: 'rgba(6,20,16,0.88)',
        border: `2px solid ${color.line}`,
        boxShadow: '0 20px 60px rgba(0,0,0,0.4)',
      }}
    >
      <div style={{display: 'flex', alignItems: 'baseline', gap: 14, marginBottom: 12}}>
        <span style={{...txt(size * 2.4, 800), ...tabular}}>{total}</span>
        <span style={{...txt(size * 1.2, 600, color.inkDim), ...tabular}}>/ {target}</span>
        <span style={{...txt(size * 0.9, 500, color.inkFaint), marginLeft: 8}}>{ui.counted}</span>
      </div>
      <div style={{height: 8, borderRadius: 4, background: color.panelStrong, marginBottom: 14}}>
        <div style={{width: `${(total / target) * 100}%`, height: 8, borderRadius: 4, background: color.mint}} />
      </div>
      {TALLY.map((c) => {
        const b = bump[c] ?? 0;
        return (
          <div key={c} style={{display: 'flex', alignItems: 'center', height: rowH, gap: 14}}>
            <span style={{width: size * 4.6, ...txt(size, 600, color.ink), whiteSpace: 'nowrap'}}>{ui[`s_${c}`]}</span>
            <span
              style={{
                width: size * 2,
                textAlign: 'right',
                ...txt(size * 1.05, 800, b > 0 ? classColor[c] : color.ink),
                ...tabular,
                transform: `scale(${1 + 0.35 * b})`,
                transformOrigin: 'right center',
              }}
            >
              {counts[c] ?? 0}
            </span>
            <div style={{width: barW, height: size * 0.5, borderRadius: 99, background: color.panel}}>
              <div style={{width: `${Math.min(1, (counts[c] ?? 0) / target) * 100}%`, height: '100%', borderRadius: 99, background: classColor[c]}} />
            </div>
          </div>
        );
      })}
    </div>
  );
};

/** Cell i is met at schedule[i] (scene frames): a few slowly, then fast-forward. */
function trackSchedule(n: number, dur: number, fps: number) {
  const slow = 5;
  const t0 = Math.round(0.55 * fps);
  const dtSlow = Math.round(0.58 * fps);
  const slowEnd = t0 + slow * dtSlow;
  const fastEnd = dur - Math.round(1.0 * fps);
  const out: number[] = [];
  for (let i = 0; i < n; i++) {
    if (i < slow) out.push(t0 + i * dtSlow);
    else out.push(slowEnd + ((fastEnd - slowEnd) * (i - slow + 1)) / (n - slow));
  }
  return {times: out, slowEnd};
}

const MiniMap: React.FC<{width: number; height: number; at: (s: number) => [number, number]; s: number; length: number; worldW: number; worldH: number}> = ({width, height, at, s, length, worldW, worldH}) => {
  const pad = 16;
  const sx = (width - 2 * pad) / worldW;
  const sy = (height - 2 * pad) / worldH;
  const pts: string[] = [];
  for (let q = 0; q <= s; q += 8) {
    const [x, y] = at(q);
    pts.push(`${pad + x * sx},${pad + y * sy}`);
  }
  const all: string[] = [];
  for (let q = 0; q <= length; q += 8) {
    const [x, y] = at(q);
    all.push(`${pad + x * sx},${pad + y * sy}`);
  }
  const [cx, cy] = at(s);
  return (
    <svg width={width} height={height} style={{display: 'block'}}>
      <rect x={1} y={1} width={width - 2} height={height - 2} rx={14} fill="rgba(233,177,181,0.16)" stroke="rgba(233,177,181,0.5)" strokeWidth={2} />
      <polyline points={all.join(' ')} fill="none" stroke="rgba(255,255,255,0.18)" strokeWidth={3} strokeDasharray="6 6" />
      <polyline points={pts.join(' ')} fill="none" stroke={color.mint} strokeWidth={4} strokeLinejoin="round" />
      <circle cx={pad + cx * sx} cy={pad + cy * sy} r={9} fill={color.mint} />
    </svg>
  );
};

export const TrackLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, dur} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const kinds = seqKinds(ctx);
  const spacing = 46;
  const {wbcs, at, length} = React.useMemo(() => trackWorld(kinds, spacing), [kinds]);
  const {times, slowEnd} = trackSchedule(kinds.length, dur, fps);
  // Arc-length position: cell i centred at times[i]; before the first, approach.
  const sAt = (f: number) => {
    const s0 = 20 - spacing * 0.6;
    if (f <= times[0]) return lerp(s0, 20, ease(f, times[0] - Math.round(0.7 * fps), Math.round(0.7 * fps)));
    for (let i = 0; i < times.length - 1; i++) {
      if (f < times[i + 1]) {
        const u = (f - times[i]) / (times[i + 1] - times[i]);
        const e = i < 4 ? easeIO(u * 100, 25, 60) : u; // slow phase: dwell on each cell
        return 20 + spacing * (i + e);
      }
    }
    return 20 + spacing * (times.length - 1);
  };
  const s = sAt(frame);
  const n = times.filter((t) => frame >= t).length;
  const counts = tallyAt(kinds, n);
  const fast = frame >= slowEnd;
  const speed = Math.abs(sAt(frame + 1) - sAt(frame));
  const blur = Math.min(2.6, Math.max(0, (speed - 6) * 0.12));
  const rings: Record<string, {t: number; color: string}> = {};
  const bump: Partial<Record<CellKind, number>> = {};
  times.forEach((t, i) => {
    const d = frame - t;
    if (d >= -6 && d < 16) {
      rings[`w${i}`] = {t: d < 0 ? ease(d + 6, 0, 6) : 1 - ease(d, 8, 8), color: classColor[kinds[i]]};
    }
    if (d >= 0 && d < 10) bump[kinds[i]] = Math.max(bump[kinds[i]] ?? 0, 1 - d / 10);
  });
  // Label for the latest cell met in the slow phase.
  const last = n - 1;
  const showLabel = last >= 0 && last < 5 && frame - times[last] < Math.round(0.6 * fps);
  const labT = showLabel ? ease(frame - times[last], 0, 6) : 0;
  const size = vertical ? 700 : 720;
  const fx = vertical ? (m.w - size) / 2 : 110;
  const fy = vertical ? 300 : 170;
  const worldW = 8 * spacing;
  const worldH = (Math.floor(length / (8 * spacing + 34)) + 1) * 34;
  const label = showLabel ? (
    <div style={{position: 'absolute', left: fx + size / 2 + 60, top: fy + size / 2 - 150, ...rise(labT, 14)}}>
      <Pill text={`${ui[`n_${kinds[last]}`]}  +1`} size={vertical ? 38 : 34} tone="mint" style={{borderColor: classColor[kinds[last]], color: classColor[kinds[last]]}} />
    </div>
  ) : null;
  const panel = (
    <TallyPanel counts={counts} total={n} target={ctx.math.target} ui={ui} width={vertical ? 600 : 760} rowH={vertical ? 46 : 52} size={vertical ? 30 : 32} bump={bump} />
  );
  const mini = <MiniMap width={vertical ? 280 : 380} height={vertical ? 170 : 150} at={at} s={s} length={length} worldW={worldW} worldH={worldH} />;
  const ff = (
    <div style={{opacity: fast ? ease(frame, slowEnd, 8) : 0}}>
      <Badge text={`▸▸ ${ui.fastForward}`} tone="amber" size={m.small * 0.78} />
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="03" kicker={ui.kickerTrack} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: fx, top: fy}}>
        <MicroscopeField size={size} viewUm={64} center={at(s)} wbcs={wbcs} rings={rings} blur={blur} id="trackf" reticle />
      </div>
      {label}
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: m.gutter, top: 1030, display: 'flex', flexDirection: 'column', gap: 14}}>
            {mini}
            <div style={{width: 280, ...txt(25, 600, color.inkDim)}}>{ui.trackRule}</div>
            {ff}
          </div>
          <div style={{position: 'absolute', right: m.gutter - 10, top: 1010}}>{panel}</div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 1000, top: 200}}>{panel}</div>
          <div style={{position: 'absolute', left: 1000, top: 740, display: 'flex', gap: 26, alignItems: 'center'}}>
            {mini}
            <div style={{display: 'flex', flexDirection: 'column', gap: 14}}>
              <div style={{width: 360, ...txt(28, 600, color.inkDim)}}>{ui.trackRule}</div>
              {ff}
            </div>
          </div>
        </>
      )}
    </AbsoluteFill>
  );
};

// --------------------------------------------------------------- tap sync
export const TapSyncLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, dur} = useT(scene);
  const {m, ui, lang, appFrames} = ctx;
  const vertical = isV(ctx);
  const ids = (scene.props?.frames as string[]) ?? [];
  const kinds = seqKinds(ctx);
  const nTaps = ids.length - 1;
  const start = cue(1) - 4;
  const end = dur - Math.round(1.1 * fps);
  const tapAt = (k: number) => Math.round(start + ((k - 1) * (end - start)) / nTaps); // k = 1..nTaps
  let k = 0; // frames shown: ids[k]
  for (let q = 1; q <= nTaps; q++) if (frame >= tapAt(q) + 3) k = q;
  const src = (id: string) => `frames/${lang}/${ctx.videoId}/${id}.png`;
  const cur = appFrames[ids[k]];
  const prevId = k > 0 ? ids[k - 1] : null;
  const mix = k > 0 ? ease(frame - (tapAt(k) + 3), 0, 6) : 1;
  // Ripple: on the frame BEFORE the switch, at the button the next tap hits.
  const nextK = Math.min(nTaps, k + 1);
  const nextMeta = appFrames[ids[nextK]];
  const rippleT = frame >= tapAt(nextK) - 6 && frame < tapAt(nextK) + 10 && k < nextK ? ease(frame, tapAt(nextK) - 6, 14) : 0;
  const lastRipple = k > 0 && frame < tapAt(k) + 12 ? ease(frame, tapAt(k) - 6, 14) : 0;
  const tapMeta = rippleT > 0 ? nextMeta : lastRipple > 0 ? cur : null;
  const tap = tapMeta?.tap ? {at: tapMeta.tap, t: rippleT > 0 ? rippleT : lastRipple} : null;
  const base = appFrames[ids[0]];
  // Intro (line 0): all buttons light up one after another.
  const introMarks = TALLY.map((c) => base?.marks?.[`btn_${c}`]).filter(Boolean) as [number, number, number, number][];
  const introIdx = frame < start ? Math.floor((frame / Math.max(1, start)) * (introMarks.length + 1)) - 1 : -1;
  const mark =
    k === 0
      ? introIdx >= 0 && introIdx < introMarks.length
        ? {rect: introMarks[introIdx], t: 1, tone: 'mint' as const}
        : null
      : cur?.marks?.btn
        ? {rect: cur.marks.btn, t: ease(frame - tapAt(k), 2, 8), tone: 'mint' as const}
        : null;
  const zoom = 1.0;
  const phoneW = vertical ? 560 : 460;
  const phone = (
    <PhoneFrame
      src={src(ids[k])}
      prevSrc={prevId ? src(prevId) : null}
      mix={mix}
      width={phoneW}
      zoom={zoom}
      focus={[195, 422]}
      mark={mark}
      tap={tap}
      tilt={vertical ? 0 : -6}
    />
  );
  // Microscope: the cell that the NEXT tap classifies sits under the reticle.
  const {wbcs, at} = React.useMemo(() => trackWorld(kinds, 46), [kinds]);
  const target = frame < start ? 0 : Math.min(nTaps - 1, frame >= tapAt(nextK) + 3 ? nextK : nextK - 1);
  const sCell = (i: number) => 20 + 46 * i;
  const prevTarget = Math.max(0, target - 1);
  const moveT = target === 0 ? 1 : ease(frame, tapAt(target) + 3, 10);
  const s = lerp(sCell(prevTarget), sCell(target), moveT);
  const cellKind = kinds[target];
  const ringT = frame >= start - 10 ? ease(frame, start - 10, 8) : 0;
  const fieldSize = vertical ? 300 : 430;
  const field = (
    <MicroscopeField
      size={fieldSize}
      viewUm={40}
      center={at(s)}
      wbcs={wbcs}
      rings={{[`w${target}`]: {t: ringT, color: classColor[cellKind]}}}
      id="tapf"
      reticle
    />
  );
  // "+1" floater above the tapped button (phone-local coords → approximate canvas).
  const lineIdx = frame >= cue(2) - 6 ? 2 : frame >= cue(1) - 6 ? 1 : 0;
  const plusOne = k > 0 && frame - tapAt(k) < Math.round(0.8 * fps);
  const head =
    lineIdx === 0 ? ui.coButtons : fill(ui.coPlusOne, {cell: ui[`n_${kinds[Math.max(0, (plusOne ? k : nextK) - 1)]}`]});
  const sub = lineIdx === 1 ? ui.coLongPress : lineIdx === 2 ? ui.coLive : '';
  const headT = ease(frame, 4, 12);
  const headColor = lineIdx === 0 ? color.mint : classColor[kinds[Math.max(0, (plusOne ? k : nextK) - 1)]];
  const callout = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 14}}>
      <div key={head} style={{...rise(headT, 14), ...txt(vertical ? 42 : 56, 700, headColor), letterSpacing: -0.5, textWrap: 'balance' as never}}>
        {head}
      </div>
      {sub ? (
        <div key={sub} style={{...rise(ease(frame, lineIdx === 1 ? cue(1) : cue(2), 12), 12), ...txt(vertical ? 34 : 38, 600, color.inkDim)}}>{sub}</div>
      ) : null}
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="04" kicker={ui.kickerApp} badge={{text: ui.realScreens, tone: 'mint'}} badgeBelow />
      {vertical ? (
        <>
          <div
            style={{
              position: 'absolute',
              left: 64,
              top: 300,
              maskImage: 'linear-gradient(to bottom, black 80%, transparent 96%)',
              WebkitMaskImage: 'linear-gradient(to bottom, black 80%, transparent 96%)',
            }}
          >
            {phone}
          </div>
          <div style={{position: 'absolute', left: 676, top: 330}}>{field}</div>
          <div style={{position: 'absolute', left: 676, width: 340, top: 680}}>{callout}</div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 150, top: 290}}>{field}</div>
          <div style={{position: 'absolute', left: 640, width: 600, top: 330}}>{callout}</div>
          <div style={{position: 'absolute', left: 1320, top: 60}}>{phone}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

// --------------------------------------------------------------- percent
export const PercentLayer: Layer = ({scene, ctx}) => {
  const {frame, cue, cueEnd} = useT(scene);
  const {m, ui, lang, math} = ctx;
  const vertical = isV(ctx);
  const rows = (math.rows as {cell: CellKind; count: number; percent: number; absolute: number | null}[]).filter((r) => r.cell !== 'other' || r.count > 0);
  const absStart = Math.round(lerp(cue(0), cueEnd(0), 0.45));
  const absT = ease(frame, absStart, 14);
  const W = vertical ? m.w - 2 * m.gutter : 1380;
  const size = vertical ? 36 : 32;
  const rowH = vertical ? 78 : 54;
  const cols = vertical ? {name: 230, n: 90, bar: W - 230 - 90 - 140 - 150 - 40, pct: 140, abs: 150} : {name: 470, n: 120, bar: 420, pct: 160, abs: 200};
  const nameKey = vertical ? 's_' : 'n_';
  const head = (
    <div style={{display: 'flex', alignItems: 'center', height: rowH * 0.8, gap: 10, ...txt(size * 0.8, 700, color.mint), textTransform: 'uppercase', letterSpacing: 1.5}}>
      <span style={{width: cols.name}}>{ui.colCell}</span>
      <span style={{width: cols.n, textAlign: 'right'}}>{ui.colN}</span>
      <span style={{width: cols.bar}} />
      <span style={{width: cols.pct, textAlign: 'right'}}>{ui.colPct}</span>
      <span style={{width: cols.abs, textAlign: 'right', opacity: absT}}>{ui.colAbs}</span>
    </div>
  );
  const body = rows.map((r, i) => {
    const t = ease(frame, 6 + i * 5, 12);
    const bar = ease(frame, 10 + i * 5, 22);
    return (
      <div key={r.cell} style={{display: 'flex', alignItems: 'center', height: rowH, gap: 10, borderTop: `1px solid ${color.line}`, opacity: t}}>
        <span style={{width: cols.name, ...txt(size, 600)}}>{ui[`${nameKey}${r.cell}`]}</span>
        <span style={{width: cols.n, textAlign: 'right', ...txt(size, 800), ...tabular}}>{r.count}</span>
        <span style={{width: cols.bar, paddingLeft: 18, boxSizing: 'border-box'}}>
          <div style={{height: size * 0.5, borderRadius: 99, background: color.panel}}>
            <div style={{width: `${r.percent * bar}%`, height: '100%', borderRadius: 99, background: classColor[r.cell]}} />
          </div>
        </span>
        <span style={{width: cols.pct, textAlign: 'right', ...txt(size, 700, color.ink), ...tabular}}>{fmtMax(r.percent, lang, 1)}</span>
        <span style={{width: cols.abs, textAlign: 'right', ...txt(size, 700, color.beam), ...tabular, opacity: absT}}>{r.absolute == null ? '—' : fmtMax(r.absolute, lang, 2)}</span>
      </div>
    );
  });
  const sumT = ease(frame, 6 + rows.length * 5 + 6, 12);
  const sum = (
    <div style={{display: 'flex', alignItems: 'center', height: rowH, gap: 10, borderTop: `2px solid ${color.inkFaint}`, opacity: sumT}}>
      <span style={{width: cols.name, ...txt(size, 800)}}>Σ</span>
      <span style={{width: cols.n, textAlign: 'right', ...txt(size, 800), ...tabular}}>{math.total}</span>
      <span style={{width: cols.bar}} />
      <span style={{width: cols.pct, textAlign: 'right', ...txt(size, 800), ...tabular}}>{fmtMax(math.pctSum, lang, 1)}</span>
      <span style={{width: cols.abs, textAlign: 'right', ...txt(size, 800, color.beam), ...tabular, opacity: absT}}>{fmtMax(math.absSum, lang, 2)}</span>
    </div>
  );
  const neutPct = rows.filter((r) => r.cell === 'segmented' || r.cell === 'band').reduce((a, r) => a + r.percent, 0);
  const foot = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 8, marginTop: vertical ? 18 : 12, opacity: absT}}>
      <div style={{...txt(size * 0.85, 600, color.inkDim), ...tabular}}>
        {`${ui.neutTotal}: ${fmtMax(neutPct, lang, 1)} % · ${fmtMax(math.neutrophilsAbs, lang, 2)} ${ui.colAbs}`}
      </div>
      <div style={{...txt(size * 0.7, 500, color.inkFaint)}}>{ui.computed}</div>
    </div>
  );
  const formula = (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: 10,
        padding: '18px 28px',
        borderRadius: 24,
        background: 'rgba(6,20,16,0.88)',
        border: `2px solid ${color.line}`,
      }}
    >
      <div style={{display: 'flex', flexDirection: vertical ? 'column' : 'row', gap: vertical ? 10 : 56, whiteSpace: 'nowrap'}}>
        <span style={{...txt(vertical ? 40 : 40, 700, color.ink), opacity: ease(frame, 4, 12)}}>{ui.formulaPct}</span>
        <span style={{...txt(vertical ? 40 : 40, 700, color.beam), opacity: absT}}>{ui.formulaAbs}</span>
      </div>
      <span style={{...txt(28, 600, color.amber), opacity: absT}}>{fill(ui.wbcGiven, {wbc: ctx.vars.wbc})}</span>
    </div>
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step="07" kicker={ui.kickerMath} badge={{text: ui.illustrative, tone: 'amber'}} />
      <div style={{position: 'absolute', left: vertical ? m.gutter : (m.w - W) / 2, top: vertical ? 380 : 210, width: W}}>
        {formula}
        <div style={{height: vertical ? 34 : 18}} />
        {head}
        {body}
        {sum}
        {foot}
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  field: FieldLayer,
  cells: CellsLayer,
  track: TrackLayer,
  tapsync: TapSyncLayer,
  phone: PhoneShotsLayer,
  percent: PercentLayer,
  cta: CtaLayer,
};

