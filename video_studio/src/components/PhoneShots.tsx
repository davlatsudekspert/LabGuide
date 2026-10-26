// Generic "real app screens" layer: a sequence of app frames (from a
// flutter_walk test) in a neutral phone, each with a measured highlight
// (`mark`), an optional tap ripple and a callout. Generalised from the
// calibration flagship's phone layer: the step number comes from
// scene.props.step; texts from ui[callout], ui.kickerApp, ui.realScreens
// (or ui[scene.props.badge], e.g. "Real app screens · illustrative values").
// Shots with `cue` follow the narration line of that index.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, rise} from './anim';
import {SceneHeader} from './Basics';
import {PhoneFrame, Rect} from './PhoneFrame';
import {color} from '../design/theme';
import type {LaidScene, Layer} from '../framework/types';
import {isV, txt, useT} from './layerKit';

export type Shot = {
  frame: string;
  w: number;
  cue?: number;
  mark?: string;
  tap?: boolean;
  callout: string;
  /** Logical rect kept bright (outside dimmed), or the name of a measured mark. */
  crop?: Rect | string;
  tone?: 'warn' | 'ok';
};

/** Shot windows (scene frames): shots with `cue` are spread over that line. */
export function shotWindows(shots: Shot[], scene: LaidScene, fps: number) {
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

export const PhoneShotsLayer: Layer = ({scene, ctx, prev}) => {
  const {frame, fps} = useT(scene);
  const {m, ui, lang, appFrames} = ctx;
  const vertical = isV(ctx);
  const shots = (scene.props?.shots as Shot[]) ?? [];
  const win = shotWindows(shots, scene, fps);
  let i = win.findIndex((w) => frame >= w.from && frame < w.to);
  if (i < 0) i = frame < 0 ? 0 : shots.length - 1;
  const shot = shots[i];
  const local = frame - win[i].from;
  const len = win[i].to - win[i].from;
  const src = (id: string) => `frames/${lang}/${ctx.videoId}/${id}.png`;
  const meta = appFrames[shot.frame];
  const prevShots = prev?.layer === scene.layer ? ((prev.props?.shots as Shot[]) ?? []) : [];
  const land = !!meta && meta.w > meta.h;
  const orient = (id: string | null) => {
    const f = id ? appFrames[id] : null;
    return f ? f.w > f.h : false;
  };
  let prevFrame = i > 0 ? shots[i - 1].frame : prevShots.length ? prevShots[prevShots.length - 1].frame : null;
  // A turn from portrait to landscape (e.g. a full-screen slide): no
  // cross-fade between differently shaped frames — the phone turns instead.
  const turned = prevFrame != null && orient(prevFrame) !== land;
  if (turned) prevFrame = null;
  const turnT = turned ? ease(local, 0, 14) : 1;
  const mix = prevFrame ? ease(local, 0, 9) : 1;
  const rect = shot.mark && meta?.marks?.[shot.mark] ? meta.marks[shot.mark] : null;
  const crop: Rect | null = typeof shot.crop === 'string' ? ((meta?.marks?.[shot.crop] as Rect | undefined) ?? null) : (shot.crop ?? null);
  const focus: [number, number] = crop
    ? [crop[0] + crop[2] / 2, crop[1] + crop[3] / 2]
    : rect
      ? [rect[0] + rect[2] / 2, rect[1] + rect[3] / 2]
      : [(meta?.w ?? 390) / 2, (meta?.h ?? 844) / 2];
  // A crop given by mark name (measured field) zooms only as far as its
  // width allows, and hides the outside almost completely.
  const namedCrop = typeof shot.crop === 'string';
  const cropZoom = namedCrop && crop ? Math.max(1, Math.min(1.5, (meta?.w ?? 390) / (crop[2] + 24))) : 1.5;
  const zoom = crop ? cropZoom + 0.06 * easeIO(local, 0, len) : 1.0 + 0.07 * easeIO(local, 0, len);
  const tone = shot.tone === 'warn' ? 'coral' : 'mint';
  const tapAt = shot.tap && meta?.tap ? meta.tap : null;
  const tapT = tapAt ? ease(local, 4, 16) : 0;
  const ct = ease(local, 2, 12);
  const step = (scene.props?.step as string) ?? '';
  const calloutColor = shot.tone === 'warn' ? color.coral : color.mint;
  const callout = (
    <div
      key={shot.frame}
      style={{
        ...rise(ct, 20),
        ...txt(vertical || land ? 54 : 64, 700, calloutColor),
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
        <div key={s.frame} style={{width: k === i ? 34 : 12, height: 12, borderRadius: 6, background: k === i ? calloutColor : color.line}} />
      ))}
    </div>
  );
  const phoneW = land ? (vertical ? 960 : 1060) : vertical ? 600 : 450;
  const phone = (
    <PhoneFrame
      appW={meta?.w ?? 390}
      appH={meta?.h ?? 844}
      src={src(shot.frame)}
      prevSrc={prevFrame ? src(prevFrame) : null}
      mix={mix}
      width={phoneW}
      zoom={zoom}
      focus={focus}
      mark={rect ? {rect, t: ease(local, 8, 12), tone} : null}
      tap={tapAt ? {at: tapAt, t: tapT} : null}
      crop={crop}
      cropShade={namedCrop ? 0.97 : 0.9}
      tilt={vertical || land ? 0 : -7}
      style={turned ? {transform: `rotate(${(1 - turnT) * -90}deg) scale(${0.7 + 0.3 * turnT})`, opacity: Math.min(1, turnT * 1.6)} : undefined}
    />
  );
  return (
    <AbsoluteFill>
      <SceneHeader format={ctx.format} step={step} kicker={ui.kickerApp} badge={{text: ui[(scene.props?.badge as string) ?? 'realScreens'] ?? ui.realScreens, tone: 'mint'}} badgeBelow />
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 290, display: 'flex', flexDirection: 'column', gap: 16}}>
            {callout}
            {dots}
          </div>
          <div
            style={
              land
                ? {position: 'absolute', left: (m.w - phoneW) / 2, top: 600}
                : {
                    position: 'absolute',
                    left: (m.w - 600) / 2,
                    top: 430,
                    maskImage: 'linear-gradient(to bottom, black 76%, transparent 96%)',
                    WebkitMaskImage: 'linear-gradient(to bottom, black 76%, transparent 96%)',
                  }
            }
          >
            {phone}
          </div>
          {land ? (
            <div style={{position: 'absolute', left: m.gutter + 40, right: m.gutter, top: 1150, display: 'flex', flexDirection: 'column', gap: 14}}>
              {shots.map((s, k) => (
                <div
                  key={s.frame}
                  style={{display: 'flex', alignItems: 'center', gap: 16, ...txt(m.body * 0.9, k === i ? 700 : 500, k === i ? color.ink : k < i ? color.inkDim : color.inkFaint)}}
                >
                  <span style={{width: 30, color: k < i ? color.mint : k === i ? calloutColor : color.inkFaint}}>{k < i ? '✓' : k === i ? '●' : '○'}</span>
                  {ui[s.callout] ?? s.callout}
                </div>
              ))}
            </div>
          ) : null}
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: m.gutter, width: land ? 560 : 1040, top: 300, display: 'flex', flexDirection: 'column', gap: 30}}>
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
                    ...txt(m.body * 0.92, k === i ? 700 : 500, k === i ? color.ink : k < i ? color.inkDim : color.inkFaint),
                  }}
                >
                  <span style={{width: 30, color: k < i ? color.mint : k === i ? calloutColor : color.inkFaint}}>{k < i ? '✓' : k === i ? '●' : '○'}</span>
                  {ui[s.callout] ?? s.callout}
                </div>
              ))}
            </div>
          </div>
          <div style={{position: 'absolute', left: land ? 740 : 1320, top: land ? 280 : 66}}>{phone}</div>
        </>
      )}
    </AbsoluteFill>
  );
};
