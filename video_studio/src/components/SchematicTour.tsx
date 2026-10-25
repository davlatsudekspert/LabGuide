// Generic "tour of the app's original schematic" layer (data-driven from
// storyboard props): numbered callouts light up one after another in step
// with the narration, an optional light / flow path is drawn over the
// schematic, and a legend lists the part names (from the app's own
// schematic_parts.json wording, kept in the language packs).
//
// scene.props:
//   schematic  key in src/generated/schematics.js (scripts/prepare.mjs)
//   step, kicker, badge   header texts (ui keys)
//   parts      [{n, name, cue?, at?}] — name = ui key; cue = narration line
//              index; `at` seconds after that line starts (else spread evenly)
//   paths      [{pts:[[x,y]…], cue?, at?, dur?, color?}] — schematic coords
//   zoom, focus  camera push-in (schematic coords)
//   chip       {key, cue?, at?, tone?} — pill under the legend
//   cols       legend columns in vertical (default 1, 2 for long lists)
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO} from './anim';
import {Pill, SceneHeader} from './Basics';
import {SchematicStage} from './SchematicStage';
import {color} from '../design/theme';
import type {Layer} from '../framework/types';
import {isV, txt, useT} from './layerKit';

type TourPart = {n: number; name: string; cue?: number; at?: number};
type TourPath = {pts?: [number, number][]; ref?: string; cue?: number; at?: number; dur?: number; color?: string; width?: number};

const NumberDot: React.FC<{n: number; size: number; on: number}> = ({n, size, on}) => (
  <div
    style={{
      width: size * 1.35,
      height: size * 1.35,
      flex: 'none',
      borderRadius: 99,
      background: on > 0.5 ? color.brandBright : color.brand,
      border: `3px solid ${on > 0.5 ? color.mint : '#ffffff'}`,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      ...txt(size * 0.75, 700, '#fff'),
    }}
  >
    {n}
  </div>
);

export const SchematicTourLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, cueEnd, dur} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const pr = (scene.props ?? {}) as Record<string, any>;
  const parts = (pr.parts as TourPart[]) ?? [];
  // Schedule: explicit `at`, else spread the parts of one cue over that line.
  const byCue = new Map<number, TourPart[]>();
  parts.forEach((p) => byCue.set(p.cue ?? 0, [...(byCue.get(p.cue ?? 0) ?? []), p]));
  const startOf = (p: TourPart) => {
    const c = p.cue ?? 0;
    if (p.at != null) return cue(c) + Math.round(p.at * fps);
    const group = byCue.get(c)!;
    const k = group.indexOf(p);
    const span = Math.max(fps, cueEnd(c) - cue(c));
    return cue(c) + Math.round((span * k) / group.length) + 4;
  };
  const starts = parts.map(startOf);
  const order = parts.map((_, i) => i).sort((a, b) => starts[a] - starts[b]);
  const activeIdx = order.filter((i) => frame >= starts[i]).pop() ?? -1;
  const emphasis: Record<number, number> = {};
  parts.forEach((p, i) => {
    const on = ease(frame, starts[i], 12);
    emphasis[p.n] = i === activeIdx ? on : on * 0.55;
  });
  const dim = ease(frame, 2, 16);
  const z = (pr.zoom as number) ?? 1.0;
  const zoom = 1 + (z - 1) * easeIO(frame, 6, Math.max(30, dur - 20));
  const paths = ((pr.paths as TourPath[]) ?? []).map((pa) => {
    const s = cue(pa.cue ?? 0) + Math.round((pa.at ?? 0.3) * fps);
    return {
      // `ref` = a named path from the video's math (storyboard data.paths).
      pts: (pa.pts ?? ctx.math?.paths?.[pa.ref as string] ?? []) as [number, number][],
      t: easeIO(frame, s, Math.round((pa.dur ?? 1.4) * fps)),
      pulse: Math.sin(frame / 5),
      color: pa.color === 'amber' ? color.amber : pa.color === 'mint' ? color.mint : pa.color === 'coral' ? color.coral : color.beam,
      width: pa.width,
    };
  });
  const chip = pr.chip as {key: string; cue?: number; at?: number; tone?: 'mint' | 'amber'} | undefined;
  const chipT = chip ? ease(frame, cue(chip.cue ?? 0) + Math.round((chip.at ?? 0.6) * fps), 14) : 0;
  const cols = vertical ? ((pr.cols as number) ?? (parts.length > 5 ? 2 : 1)) : 1;
  const size = vertical ? (cols > 1 ? m.body * 0.92 : m.body) : parts.length > 6 ? m.body * 0.86 : m.body;
  const legend = (
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${cols}, minmax(0, 1fr))`,
        columnGap: 30,
        rowGap: vertical ? 18 : parts.length > 6 ? 14 : 22,
      }}
    >
      {[...parts]
        .map((p, i) => ({p, i}))
        .sort((a, b) => a.p.n - b.p.n)
        .map(({p, i}) => {
          const seen = frame >= starts[i];
          const t = ease(frame, starts[i], 10);
          const active = i === activeIdx;
          return (
            <div
              key={p.n}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: size * 0.45,
                opacity: seen ? 0.45 + 0.55 * (active ? t : 0.5) : 0.22,
                transform: `translateX(${active ? 6 * t : 0}px)`,
              }}
            >
              <NumberDot n={p.n} size={size} on={active ? t : 0} />
              <div style={{...txt(size, active ? 700 : 600, active ? color.ink : color.inkDim), textWrap: 'balance' as never}}>{ui[p.name] ?? p.name}</div>
            </div>
          );
        })}
      {chip ? (
        <div style={{gridColumn: `1 / span ${cols}`, opacity: chipT, marginTop: 8, transform: `translateY(${(1 - chipT) * 12}px)`}}>
          <Pill text={ui[chip.key] ?? chip.key} size={m.small} tone={chip.tone ?? 'mint'} />
        </div>
      ) : null}
    </div>
  );
  const width = vertical ? ((pr.vWidth as number) ?? 980) : ((pr.hWidth as number) ?? 1040);
  return (
    <AbsoluteFill>
      <SceneHeader
        format={ctx.format}
        step={pr.step as string}
        kicker={ui[pr.kicker as string] ?? ''}
        badge={{text: ui[(pr.badge as string) ?? 'schematicNote'] ?? ''}}
      />
      <div style={{position: 'absolute', left: vertical ? (m.w - width) / 2 : 50, top: vertical ? ((pr.vTop as number) ?? 380) : ((pr.hTop as number) ?? 210)}}>
        <SchematicStage
          name={pr.schematic as string}
          width={width}
          emphasis={emphasis}
          dim={dim}
          zoom={zoom}
          focus={pr.focus as [number, number] | undefined}
          paths={paths}
        />
      </div>
      <div
        style={{
          position: 'absolute',
          left: vertical ? m.gutter : 1150,
          right: m.gutter,
          top: vertical ? ((pr.legendTop as number) ?? 1060) : ((pr.hLegendTop as number) ?? 300),
        }}
      >
        {legend}
      </div>
    </AbsoluteFill>
  );
};
