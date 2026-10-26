// Visual layers of the overview video "LabGuide: the specialist, the teacher
// and the student". Original motion graphics for the hook (scattered files,
// chat bubbles, a calculator — no real documents, no third-party marks) and
// REAL app frames in a neutral phone for everything else (frames/<lang>/
// overview/, merged by scripts/overview_frames.py). No number is computed.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, easeIO, pop, rise} from '../../components/anim';
import {Badge, Pill} from '../../components/Basics';
import {isV, txt, useT} from '../../components/layerKit';
import {PhoneFrame, Rect} from '../../components/PhoneFrame';
import {shotWindows, Shot} from '../../components/PhoneShots';
import {color, font} from '../../design/theme';
import type {Layer, VideoCtx} from '../../framework/types';
import {CtaLayer} from '../calibration/layers';

export type Role = 'specialist' | 'teacher' | 'student';
export const accentOf: Record<Role, string> = {specialist: color.mint, teacher: color.amber, student: color.beam};

// ------------------------------------------------------------------ icons
/** Original line icons (24x24), one per role. */
export const RoleIcon: React.FC<{role: Role; size: number; stroke?: string}> = ({role, size, stroke = '#06130F'}) => {
  const p = {fill: 'none', stroke, strokeWidth: 1.9, strokeLinecap: 'round', strokeLinejoin: 'round'} as const;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24">
      {role === 'specialist' ? (
        <>
          <path {...p} d="M9.5 3h5M10.5 3v6.2L5 18.2A2 2 0 0 0 6.8 21h10.4a2 2 0 0 0 1.8-2.8l-5.5-9V3" />
          <path {...p} d="M7.6 15h8.8" />
        </>
      ) : role === 'teacher' ? (
        <>
          <rect {...p} x="3" y="4" width="18" height="12" rx="2" />
          <path {...p} d="M12 16v4M8 20h8M7 12.5l3-3 3 2 4-4" />
        </>
      ) : (
        <>
          <path {...p} d="M2 9l10-5 10 5-10 5-10-5z" />
          <path {...p} d="M6 11.2v4.6c0 1.5 2.7 3 6 3s6-1.5 6-3v-4.6M22 9v6" />
        </>
      )}
    </svg>
  );
};

export const RoleBadge: React.FC<{role: Role; size: number; label?: string}> = ({role, size, label}) => (
  <div style={{display: 'flex', alignItems: 'center', gap: size * 0.4}}>
    <div style={{width: size * 1.5, height: size * 1.5, borderRadius: size * 0.5, background: accentOf[role], display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: `0 0 ${size * 1.4}px ${accentOf[role]}66`}}>
      <RoleIcon role={role} size={size} />
    </div>
    {label ? <div style={{...txt(size * 0.95, 700, accentOf[role]), letterSpacing: size * 0.09, textTransform: 'uppercase'}}>{label}</div> : null}
  </div>
);

// ------------------------------------------------------------ hook objects
/** Deterministic pseudo-random in [0,1). */
const rnd = (i: number, s: number) => {
  const x = Math.sin(i * 127.1 + s * 311.7) * 43758.5453;
  return x - Math.floor(x);
};

const Doc: React.FC<{w: number; label?: string; hue: number; seed: number}> = ({w, label, hue, seed}) => {
  const h = w * 1.32;
  const bars = [0.86, 0.62, 0.78, 0.5, 0.7, 0.4];
  return (
    <div style={{width: w, height: h, borderRadius: w * 0.06, background: `linear-gradient(160deg, hsl(${hue},18%,92%), hsl(${hue},14%,80%))`, boxShadow: '0 24px 60px rgba(0,0,0,0.5)', padding: w * 0.1, position: 'relative', boxSizing: 'border-box'}}>
      <div style={{position: 'absolute', right: 0, top: 0, width: w * 0.2, height: w * 0.2, background: 'rgba(0,0,0,0.12)', borderBottomLeftRadius: w * 0.06}} />
      {label ? <div style={{...txt(w * 0.085, 700, '#294039'), marginBottom: w * 0.05, wordBreak: 'break-all'}}>{label}</div> : <div style={{height: w * 0.1}} />}
      {bars.map((b, i) => (
        <div key={i} style={{height: w * 0.035, width: `${b * (0.8 + 0.2 * rnd(i, seed)) * 100}%`, background: 'rgba(30,60,52,0.28)', borderRadius: 99, marginBottom: w * 0.05}} />
      ))}
      <div style={{display: 'flex', gap: w * 0.05, marginTop: w * 0.06}}>
        {[0, 1, 2].map((i) => (
          <div key={i} style={{flex: 1, height: w * 0.17, borderRadius: w * 0.025, background: 'rgba(30,60,52,0.16)'}} />
        ))}
      </div>
    </div>
  );
};

const Bubble: React.FC<{w: number; text: string; mine?: boolean}> = ({w, text, mine}) => (
  <div style={{width: w, padding: `${w * 0.07}px ${w * 0.09}px`, borderRadius: w * 0.14, borderBottomLeftRadius: mine ? w * 0.14 : w * 0.03, borderBottomRightRadius: mine ? w * 0.03 : w * 0.14, background: mine ? '#1F7A62' : '#E6EEEA', color: mine ? '#EAFBF4' : '#1A2B26', fontFamily: font.sans, fontWeight: 600, fontSize: w * 0.105, lineHeight: 1.2, boxShadow: '0 20px 50px rgba(0,0,0,0.45)', boxSizing: 'border-box'}}>
      {text}
    </div>
  );

const Calc: React.FC<{w: number; display: string}> = ({w, display}) => (
  <div style={{width: w, borderRadius: w * 0.12, padding: w * 0.1, background: 'linear-gradient(160deg,#2A3532,#161D1B)', boxShadow: '0 24px 60px rgba(0,0,0,0.55), inset 0 0 0 2px rgba(255,255,255,0.07)', boxSizing: 'border-box'}}>
    <div style={{height: w * 0.26, borderRadius: w * 0.05, background: '#B9D8C6', color: '#14352B', fontFamily: font.sans, fontWeight: 700, fontSize: w * 0.17, textAlign: 'right', padding: `0 ${w * 0.06}px`, display: 'flex', alignItems: 'center', justifyContent: 'flex-end'}}>{display}</div>
    <div style={{display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: w * 0.04, marginTop: w * 0.08}}>
      {Array.from({length: 16}).map((_, i) => (
        <div key={i} style={{height: w * 0.15, borderRadius: w * 0.04, background: i % 4 === 3 ? '#C9892B' : '#3B4743'}} />
      ))}
    </div>
  </div>
);

type HookItem = {kind: 'doc' | 'bubble' | 'calc'; label?: boolean; x: number; y: number; rot: number; w: number; text?: string; hue?: number; mine?: boolean};

// Positions are fractions of the canvas; the headline owns the middle band and
// the subtitle plate the bottom, so objects live around them.
const HOOK_H: HookItem[] = [
  {kind: 'doc', x: 0.1, y: 0.2, rot: -14, w: 250, hue: 150, label: true},
  {kind: 'doc', x: 0.86, y: 0.16, rot: 11, w: 250, hue: 40},
  {kind: 'doc', x: 0.92, y: 0.62, rot: -8, w: 210, hue: 200},
  {kind: 'doc', x: 0.06, y: 0.64, rot: 9, w: 220, hue: 20},
  {kind: 'bubble', x: 0.27, y: 0.78, rot: -6, w: 330, text: 'hkChat1'},
  {kind: 'bubble', x: 0.7, y: 0.8, rot: 5, w: 340, text: 'hkChat2', mine: true},
  {kind: 'calc', x: 0.5, y: 0.2, rot: -4, w: 190},
  {kind: 'doc', x: 0.26, y: 0.1, rot: 17, w: 170, hue: 260},
  {kind: 'doc', x: 0.72, y: 0.1, rot: -19, w: 180, hue: 100},
];
const HOOK_V: HookItem[] = [
  {kind: 'doc', x: 0.2, y: 0.11, rot: -13, w: 300, hue: 150},
  {kind: 'doc', x: 0.82, y: 0.12, rot: 12, w: 290, hue: 40},
  {kind: 'doc', x: 0.88, y: 0.43, rot: -9, w: 250, hue: 200},
  {kind: 'doc', x: 0.17, y: 0.45, rot: 10, w: 280, hue: 20, label: true},
  {kind: 'bubble', x: 0.31, y: 0.62, rot: -5, w: 430, text: 'hkChat1'},
  {kind: 'bubble', x: 0.64, y: 0.7, rot: 4, w: 440, text: 'hkChat2', mine: true},
  {kind: 'calc', x: 0.85, y: 0.56, rot: -3, w: 210},
];

export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue, dur} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const items = vertical ? HOOK_V : HOOK_H;
  const dim = ease(frame, cue(1), 14);
  const gather = easeIO(frame, dur - 22, 20);
  const q = pop(frame, fps, 3, 170);
  const more = ease(frame, cue(1) + 4, 14);
  return (
    <AbsoluteFill>
      {items.map((it, i) => {
        // Fly in from the nearest edge, then drift; at the end they gather.
        const t0 = Math.floor(i * 2.2);
        const enter = pop(frame, fps, t0, 120);
        const fromX = it.x < 0.5 ? -m.w * 0.5 : m.w * 1.5;
        const fromY = it.y < 0.5 ? -m.h * 0.3 : m.h * 1.3;
        const px = it.x * m.w;
        const py = it.y * m.h;
        const bob = Math.sin(frame / 22 + i * 1.7) * 14;
        const sway = Math.sin(frame / 31 + i) * 2.2;
        const x = (fromX + (px - fromX) * enter) * (1 - gather) + (m.w / 2) * gather;
        const y = (fromY + (py - fromY) * enter + bob) * (1 - gather) + (m.h * 0.42) * gather;
        const scale = (0.6 + 0.4 * enter) * (1 - 0.8 * gather);
        const opacity = (1 - 0.55 * dim) * (1 - gather);
        return (
          <div key={i} style={{position: 'absolute', left: x, top: y, transform: `translate(-50%,-50%) rotate(${it.rot + sway + (1 - enter) * 40}deg) scale(${scale})`, opacity, filter: `blur(${dim * 1.5}px)`}}>
            {it.kind === 'doc' ? (
              <Doc w={it.w} hue={it.hue ?? 150} seed={i} label={it.label ? ui.hkFile : undefined} />
            ) : it.kind === 'bubble' ? (
              <Bubble w={it.w} text={ui[it.text ?? '']} mine={it.mine} />
            ) : (
              <Calc w={it.w} display={ui.hkCalc} />
            )}
          </div>
        );
      })}
      <div
        style={{
          position: 'absolute',
          left: m.gutter,
          right: m.gutter,
          top: vertical ? 430 : 330,
          textAlign: 'center',
          opacity: 1 - gather,
          transform: `scale(${0.85 + 0.15 * q})`,
          ...txt(vertical ? 118 : 108, 700, color.ink),
          letterSpacing: -3,
          lineHeight: 1.02,
          textWrap: 'balance' as never,
          textShadow: '0 6px 40px rgba(0,0,0,0.85), 0 0 20px rgba(0,0,0,0.7)',
        }}
      >
        {ui.hookQ}
      </div>
      <div style={{position: 'absolute', left: 0, right: 0, top: vertical ? 700 : 520, display: 'flex', justifyContent: 'center', opacity: more * (1 - gather)}}>
        <Pill text={ui.hkMore} size={vertical ? 40 : 34} tone="amber" />
      </div>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------ app frames
const src = (ctx: VideoCtx, lang: string, id: string) => `frames/${lang}/${ctx.videoId}/${id}.png`;

const Phone: React.FC<{ctx: VideoCtx; lang?: string; frame: string; width: number; tilt?: number; style?: React.CSSProperties; zoom?: number; focus?: [number, number]}> = ({ctx, lang, frame, width, tilt = 0, style, zoom, focus}) => {
  const meta = ctx.appFrames[frame];
  return <PhoneFrame appW={meta?.w ?? 390} appH={meta?.h ?? 844} src={src(ctx, lang ?? ctx.lang, frame)} width={width} tilt={tilt} style={style} zoom={zoom} focus={focus} />;
};

// -------------------------------------------------------------- what scene
export const WhatLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const langs = [
    {code: 'uz', label: ui.langUz},
    {code: 'ru', label: ui.langRu},
    {code: 'en', label: ui.langEn},
  ];
  const pills = [ui.pillOffline, ui.pillNoAccount, ui.pillNoAds];
  const title = <div style={{...txt(vertical ? m.h1 : m.h1 * 1.05, 700, color.ink), letterSpacing: -2, textWrap: 'balance' as never, ...rise(ease(frame, 2, 16))}}>{ui.whatTitle}</div>;
  const pillRow = (
    <div style={{display: 'flex', flexDirection: vertical ? 'row' : 'column', flexWrap: 'wrap', gap: 18, alignItems: 'flex-start', justifyContent: vertical ? 'center' : 'flex-start'}}>
      {pills.map((p, i) => {
        const t = pop(frame, fps, cue(1) + i * 6, 150);
        return (
          <div key={p} style={{opacity: t, transform: `translateX(${(1 - t) * -30}px) scale(${0.9 + 0.1 * t})`}}>
            <Pill text={p} size={vertical ? 36 : 36} tone="mint" />
          </div>
        );
      })}
    </div>
  );
  const phoneW = vertical ? 440 : 300;
  const xs = vertical ? [-300, 0, 300] : [0, 310, 620];
  const phones = langs.map((lg, i) => {
    const t = pop(frame, fps, 6 + i * 6, 110);
    const center = i === 1;
    const bob = Math.sin(frame / 40 + i) * 6;
    return (
      <div
        key={lg.code}
        style={{
          position: 'absolute',
          left: vertical ? m.w / 2 - phoneW / 2 + xs[i] : xs[i],
          top: vertical ? (center ? 70 : 130) : center ? 0 : 36,
          transform: `translateY(${(1 - t) * 260 + bob}px) rotate(${vertical ? (i - 1) * 6 : 0}deg) scale(${center && vertical ? 1.08 : 1})`,
          opacity: t,
          zIndex: center ? 2 : 1,
        }}
      >
        <div style={{display: 'flex', justifyContent: 'center', marginBottom: 14}}>
          <Badge text={lg.label} tone={center ? 'mint' : 'neutral'} size={vertical ? 30 : 26} />
        </div>
        <Phone ctx={ctx} lang={lg.code} frame="home_lab" width={phoneW} />
      </div>
    );
  });
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: m.top, ...txt(m.kicker, 700, color.mint), letterSpacing: m.kicker * 0.14, textTransform: 'uppercase', display: 'flex', alignItems: 'center', gap: 16, ...rise(ease(frame, 0, 14), 16)}}>
        <span style={{width: 44, height: 3, borderRadius: 3, background: color.mint}} />
        {ui.kickerWhat}
      </div>
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 240, textAlign: 'center'}}>{title}</div>
          <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 480}}>{pillRow}</div>
          <div style={{position: 'absolute', left: 0, top: 740, width: m.w, height: 860, WebkitMaskImage: 'linear-gradient(to bottom, black 72%, transparent 98%)', maskImage: 'linear-gradient(to bottom, black 72%, transparent 98%)'}}>{phones}</div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: m.gutter, top: 300, width: 640, display: 'flex', flexDirection: 'column', gap: 44}}>
            {title}
            {pillRow}
          </div>
          <div style={{position: 'absolute', left: 940, top: 180, width: 960, height: 800}}>{phones}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------- roles scene
export const RolesLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  const roles: {role: Role; frame: string; name: string; sub: string}[] = [
    {role: 'specialist', frame: 'home_lab', name: ui.roleSpecialist, sub: ui.roleSpecialistSub},
    {role: 'teacher', frame: 'home_teacher', name: ui.roleTeacher, sub: ui.roleTeacherSub},
    {role: 'student', frame: 'home_student', name: ui.roleStudent, sub: ui.roleStudentSub},
  ];
  const w = vertical ? 290 : 390;
  const gap = vertical ? 32 : 80;
  const total = 3 * w + 2 * gap;
  const x0 = (m.w - total) / 2;
  const top = vertical ? 520 : 150;
  const visH = vertical ? 520 : 560;
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: m.top, ...txt(m.kicker, 700, color.mint), letterSpacing: m.kicker * 0.14, textTransform: 'uppercase', display: 'flex', alignItems: 'center', gap: 16, ...rise(ease(frame, 0, 14), 16)}}>
        <span style={{width: 44, height: 3, borderRadius: 3, background: color.mint}} />
        {ui.kickerRoles}
      </div>
      {vertical ? <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 280, textAlign: 'center', ...txt(m.h1, 700, color.ink), letterSpacing: -2, ...rise(ease(frame, 2, 16))}}>{ui.kickerRoles}</div> : null}
      {roles.map((r, i) => {
        const t = pop(frame, fps, cue(0) - 6 + i * 8, 120);
        return (
          <div key={r.role} style={{position: 'absolute', left: x0 + i * (w + gap), top, width: w, opacity: t, transform: `translateY(${(1 - t) * 120}px)`}}>
            <div style={{height: visH, overflow: 'hidden', borderRadius: 40, WebkitMaskImage: 'linear-gradient(to bottom, black 78%, transparent 100%)', maskImage: 'linear-gradient(to bottom, black 78%, transparent 100%)'}}>
              <Phone ctx={ctx} frame={r.frame} width={w} />
            </div>
            <div style={{marginTop: 18, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, textAlign: 'center'}}>
              <RoleBadge role={r.role} size={vertical ? 26 : 30} />
              <div style={txt(vertical ? 38 : 44, 700, accentOf[r.role])}>{r.name}</div>
              <div style={{...txt(vertical ? 24 : 26, 500, color.inkDim), textWrap: 'balance' as never}}>{r.sub}</div>
            </div>
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

// -------------------------------------------------------------- role shots
type RoleShot = Shot & {chips?: string[]};

export const RoleLayer: Layer = ({scene, ctx, prev}) => {
  const {frame, fps} = useT(scene);
  const {m, ui, appFrames} = ctx;
  const vertical = isV(ctx);
  const role = ((scene.props?.role as Role) ?? 'specialist') as Role;
  const accent = accentOf[role];
  const shots = (scene.props?.shots as RoleShot[]) ?? [];
  const win = shotWindows(shots, scene, fps);
  let i = win.findIndex((w) => frame >= w.from && frame < w.to);
  if (i < 0) i = frame < 0 ? 0 : shots.length - 1;
  const shot = shots[i];
  const local = frame - win[i].from;
  const len = win[i].to - win[i].from;
  const meta = appFrames[shot.frame];
  const land = !!meta && meta.w > meta.h;
  const orient = (id: string | null) => {
    const f = id ? appFrames[id] : null;
    return f ? f.w > f.h : false;
  };
  const prevShots = prev?.layer === scene.layer ? ((prev.props?.shots as RoleShot[]) ?? []) : [];
  let prevFrame = i > 0 ? shots[i - 1].frame : prevShots.length ? prevShots[prevShots.length - 1].frame : null;
  const turned = prevFrame != null && orient(prevFrame) !== land;
  if (turned) prevFrame = null;
  const turnT = turned ? ease(local, 0, 14) : 1;
  const mix = prevFrame ? ease(local, 0, 9) : 1;
  const rect = shot.mark && meta?.marks?.[shot.mark] ? meta.marks[shot.mark] : null;
  const crop: Rect | null = typeof shot.crop === 'string' ? ((meta?.marks?.[shot.crop] as Rect | undefined) ?? null) : (shot.crop ?? null);
  const focus: [number, number] = crop ? [crop[0] + crop[2] / 2, crop[1] + crop[3] / 2] : rect ? [rect[0] + rect[2] / 2, rect[1] + rect[3] / 2] : [(meta?.w ?? 390) / 2, (meta?.h ?? 844) / 2];
  const namedCrop = typeof shot.crop === 'string';
  const cropZoom = namedCrop && crop ? Math.max(1, Math.min(1.5, (meta?.w ?? 390) / (crop[2] + 24))) : 1.5;
  const zoom = crop ? cropZoom + 0.06 * easeIO(local, 0, len) : 1.0 + 0.07 * easeIO(local, 0, len);
  const warn = shot.tone === 'warn';
  const tone = warn ? 'coral' : 'mint';
  const calloutColor = warn ? color.coral : accent;
  const enter = ease(local, 0, 16);
  const ct = ease(local, 2, 12);
  const step = (scene.props?.step as string) ?? '';
  const kicker = ui[role === 'specialist' ? 'kickSpecialist' : role === 'teacher' ? 'kickTeacher' : 'kickStudent'];
  const badgeKey = (scene.props?.badge as string) ?? 'realScreens';
  const chips = shot.chips ?? [];
  const phoneW = land ? (vertical ? 960 : 1060) : vertical ? 600 : 450;

  const header = (
    <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: m.top, display: 'flex', flexDirection: vertical ? 'column' : 'row', alignItems: vertical ? 'flex-start' : 'center', justifyContent: 'space-between', gap: 16, ...rise(ease(frame, 0, 14), 14)}}>
      <div style={{display: 'flex', alignItems: 'center', gap: 18}}>
        <span style={{...txt(m.kicker, 700, color.inkFaint), letterSpacing: 2}}>{step}</span>
        <RoleBadge role={role} size={m.kicker * 0.9} label={kicker} />
      </div>
      {vertical ? (
        <div style={{opacity: ease(frame, 8, 14)}}>
          <Badge text={ui[badgeKey] ?? ui.realScreens} tone="mint" size={m.small * 0.8} />
        </div>
      ) : null}
    </div>
  );
  const callout = (
    <div key={shot.frame} style={{...rise(ct, 20), ...txt(vertical || land ? 56 : 66, 700, calloutColor), letterSpacing: -0.8, textAlign: vertical ? 'center' : 'left', textWrap: 'balance' as never}}>
      {ui[shot.callout] ?? shot.callout}
    </div>
  );
  const chipRow = chips.length ? (
    <div style={{display: 'flex', flexWrap: 'wrap', gap: 14, justifyContent: vertical ? 'center' : 'flex-start'}}>
      {chips.map((c, k) => {
        const t = pop(local, fps, 8 + k * 5, 150);
        return (
          <div key={c} style={{opacity: t, transform: `scale(${0.85 + 0.15 * t})`}}>
            <Pill text={ui[c] ?? c} size={vertical ? 32 : 30} tone={c === 'chSignIn' || c === 'chUz' ? 'amber' : 'mint'} />
          </div>
        );
      })}
    </div>
  ) : null;
  const dots = (
    <div style={{display: 'flex', gap: 10, justifyContent: vertical ? 'center' : 'flex-start'}}>
      {shots.map((s, k) => (
        <div key={s.frame} style={{width: k === i ? 34 : 12, height: 12, borderRadius: 6, background: k === i ? calloutColor : color.line}} />
      ))}
    </div>
  );
  const list = (
    <div style={{display: 'flex', flexDirection: 'column', gap: 14, marginTop: 10}}>
      {shots.map((s, k) => (
        <div key={s.frame} style={{display: 'flex', alignItems: 'center', gap: 16, ...txt(m.body * 0.9, k === i ? 700 : 500, k === i ? color.ink : k < i ? color.inkDim : color.inkFaint)}}>
          <span style={{width: 30, color: k < i ? accent : k === i ? calloutColor : color.inkFaint}}>{k < i ? '✓' : k === i ? '●' : '○'}</span>
          {ui[s.callout] ?? s.callout}
        </div>
      ))}
    </div>
  );
  const phone = (
    <div style={{transform: `translateY(${(1 - enter) * 40}px) scale(${0.96 + 0.04 * enter})`, opacity: Math.min(1, 0.35 + enter), transformOrigin: 'center'}}>
      <PhoneFrame
        appW={meta?.w ?? 390}
        appH={meta?.h ?? 844}
        src={src(ctx, ctx.lang, shot.frame)}
        prevSrc={prevFrame ? src(ctx, ctx.lang, prevFrame) : null}
        mix={mix}
        width={phoneW}
        zoom={zoom}
        focus={focus}
        mark={rect ? {rect, t: ease(local, 8, 12), tone} : null}
        crop={crop}
        cropShade={namedCrop ? 0.97 : 0.9}
        tilt={vertical || land ? 0 : -7}
        style={turned ? {transform: `rotate(${(1 - turnT) * -90}deg) scale(${0.7 + 0.3 * turnT})`, opacity: Math.min(1, turnT * 1.6)} : undefined}
      />
    </div>
  );
  // A second, dimmed phone with the neighbouring shot sits behind the main
  // one (horizontal, portrait frames only): depth, and a hint of what is next.
  const ghostId = [shots[i + 1]?.frame, shots[i - 1]?.frame].find((f) => f && !orient(f));
  const ghost =
    !vertical && !land && ghostId ? (
      <div style={{position: 'absolute', left: 930, top: 170 + Math.sin(frame / 45) * 8, opacity: 0.42 * ease(frame, 6, 18), transform: 'rotate(-4deg)', filter: 'blur(0.6px)'}}>
        <PhoneFrame appW={appFrames[ghostId!]?.w ?? 390} appH={appFrames[ghostId!]?.h ?? 844} src={src(ctx, ctx.lang, ghostId!)} width={400} tilt={0} />
      </div>
    ) : null;
  const glow = (
    <div style={{position: 'absolute', left: vertical ? m.w / 2 - 420 : land ? 740 : 1180, top: vertical ? 520 : 120, width: 840, height: 840, borderRadius: 999, background: `radial-gradient(closest-side, ${accent}33, transparent 70%)`}} />
  );
  return (
    <AbsoluteFill>
      {glow}
      {ghost}
      {header}
      {vertical ? (
        <>
          <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 290, display: 'flex', flexDirection: 'column', gap: 18}}>
            {callout}
            {chipRow}
            {dots}
          </div>
          <div style={land ? {position: 'absolute', left: (m.w - phoneW) / 2, top: 640} : {position: 'absolute', left: (m.w - 600) / 2, top: 560, maskImage: 'linear-gradient(to bottom, black 72%, transparent 94%)', WebkitMaskImage: 'linear-gradient(to bottom, black 72%, transparent 94%)'}}>
            {phone}
          </div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: m.gutter, width: land ? 560 : ghost ? 770 : 1000, top: 250, display: 'flex', flexDirection: 'column', gap: 28}}>
            {callout}
            {chipRow}
            {dots}
            {list}
            <div style={{marginTop: 8, opacity: ease(frame, 8, 14)}}><Badge text={ui[badgeKey] ?? ui.realScreens} tone="mint" size={m.small * 0.8} maxWidth={land ? 520 : 600} /></div>
          </div>
          <div style={{position: 'absolute', left: land ? 740 : 1320, top: land ? 280 : 66}}>{phone}</div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  what: WhatLayer,
  roles: RolesLayer,
  role: RoleLayer,
  cta: CtaLayer,
};
