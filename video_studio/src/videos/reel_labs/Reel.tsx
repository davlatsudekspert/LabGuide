// LabGuide reel: ~39 s, 1080x1920, NO narration, NO music. Trilingual
// (uz / ru / en) burned-in captions stacked in the lower third, REAL app
// frames only (uz UI) in a neutral phone, tap/point highlights measured on
// those frames. Timeline, texts and highlight rectangles live in
// docs/video/reel_labs/reel.json (the same cues produce the SRT/VTT files).
import React from 'react';
import {AbsoluteFill, Img, staticFile, useCurrentFrame} from 'remotion';
import reel from '../../../../docs/video/reel_labs/reel.json';
import {ease, easeIO, pop} from '../../components/anim';
import {Background} from '../../components/Basics';
import {PhoneFrame} from '../../components/PhoneFrame';
import {color, font} from '../../design/theme';
import {useFonts} from '../../design/fonts';
import {Beaker, Flask, Icon3D, Phone3D, phoneHeight, Scope, TubeRack} from './hero3d';

const FPS = reel.fps;
export const REEL_FRAMES = Math.round(reel.totalSec * FPS);
const W = 1080;
const H = 1920;
const f = (s: number) => Math.round(s * FPS);

type Cue = (typeof reel.cues)[number] & {hook?: boolean; big?: boolean};
type Shot = (typeof reel.shots)[number] & {tap?: number[]; zoom?: number};
const cues = reel.cues as Cue[];
const shots = reel.shots as Shot[];
const sections = reel.sections;

const accentColor: Record<string, string> = {mint: color.mint, amber: color.amber, coral: color.coral, beam: color.beam};
const txt = (size: number, weight: number, c: string): React.CSSProperties => ({fontFamily: font.sans, fontSize: size, fontWeight: weight, color: c});
const rnd = (i: number, s: number) => {
  const x = Math.sin(i * 127.1 + s * 311.7) * 43758.5453;
  return x - Math.floor(x);
};

// ------------------------------------------------------------ captions
// Instagram safe zone: bottom ~330 px and right ~100 px stay free of text.
const PLATE = {left: 120, width: 840, bottom: 340};

const CaptionStack: React.FC<{frame: number}> = ({frame}) => {
  const cue = cues.find((c) => frame >= f(c.start) && frame < f(c.end)) ?? cues[cues.length - 1];
  const local = frame - f(cue.start);
  const sec = sections.find((s) => frame >= f(s.start) && frame < f(s.end));
  const accent = sec ? accentColor[sec.accent] : color.mint;
  const big = !!cue.big;
  const hook = !!cue.hook;
  const sizes = big ? [112, 72, 60] : hook ? [0, 52, 44] : [52, 42, 36];
  const colors = ['#FFFFFF', '#CFEFE1', '#B6D2C6'];
  const weights = [700, 600, 500];
  const langs = ['uz', 'ru', 'en'] as const;
  return (
    <div
      style={{
        position: 'absolute',
        left: PLATE.left,
        width: PLATE.width,
        bottom: PLATE.bottom,
        boxSizing: 'border-box',
        padding: big ? '30px 36px 34px' : '24px 34px 28px 40px',
        borderRadius: 38,
        background: 'linear-gradient(180deg, rgba(6,20,16,0.86), rgba(4,14,11,0.94))',
        border: `1.5px solid ${color.line}`,
        boxShadow: '0 24px 70px rgba(0,0,0,0.55)',
        display: 'flex',
        flexDirection: 'column',
        gap: big ? 8 : 10,
        textAlign: big ? 'center' : 'left',
      }}
    >
      {!big ? <div style={{position: 'absolute', left: 0, top: 26, bottom: 26, width: 8, borderRadius: 4, background: accent}} /> : null}
      {langs.map((lg, i) => {
        if (!sizes[i]) return null;
        const t = hook ? ease(local + 8, i * 3, 8) : ease(local, i * 3, 8);
        return (
          <div
            key={lg}
            lang={lg}
            style={{
              ...txt(sizes[i], weights[i], colors[i]),
              lineHeight: 1.12,
              letterSpacing: i === 0 ? -0.8 : -0.2,
              opacity: t,
              transform: `translateY(${(1 - t) * 18}px)`,
              textWrap: 'balance' as never,
            }}
          >
            {cue[lg]}
          </div>
        );
      })}
    </div>
  );
};

// ------------------------------------------------------------ section header
const StepPill: React.FC<{frame: number}> = ({frame}) => {
  const idx = sections.findIndex((s) => frame >= f(s.start) && frame < f(s.end));
  if (idx < 0) return null;
  const s = sections[idx];
  const local = frame - f(s.start);
  const t = pop(local, FPS, 0, 170);
  const a = accentColor[s.accent];
  return (
    <div style={{position: 'absolute', left: 0, right: 0, top: 196, display: 'flex', justifyContent: 'center', opacity: Math.min(1, t * 1.5), transform: `translateY(${(1 - t) * -50}px) scale(${0.92 + 0.08 * t})`}}>
      <div style={{display: 'flex', alignItems: 'center', gap: 20, padding: '12px 34px 12px 14px', borderRadius: 999, background: 'rgba(6,20,16,0.82)', border: `2px solid ${a}`, boxShadow: `0 0 50px ${a}55`}}>
        <div style={{width: 62, height: 62, borderRadius: 999, background: a, color: '#06130F', ...txt(40, 800, '#06130F'), display: 'flex', alignItems: 'center', justifyContent: 'center'}}>{s.n}</div>
        <div style={txt(48, 700, color.ink)}>{s.pill}</div>
        <div style={{display: 'flex', gap: 8, marginLeft: 6}}>
          {sections.map((x, k) => (
            <div key={x.id} style={{width: k === idx ? 34 : 12, height: 12, borderRadius: 6, background: k === idx ? a : 'rgba(255,255,255,0.28)'}} />
          ))}
        </div>
      </div>
    </div>
  );
};

// ------------------------------------------------------------ phone stage
const PH_W = 520;
const PH_TOP = 282;

const PhoneStage: React.FC<{frame: number}> = ({frame}) => {
  const si = shots.findIndex((s) => frame >= f(s.start) && frame < f(s.end));
  if (si < 0) return null;
  const shot = shots[si];
  const sec = sections.find((s) => frame >= f(s.start) && frame < f(s.end))!;
  const secStart = f(sec.start);
  const prev = si > 0 && f(shots[si - 1].end) > secStart ? shots[si - 1] : null;
  const local = frame - f(shot.start);
  const len = f(shot.end) - f(shot.start);
  const enter = pop(frame - secStart, FPS, 0, 120);
  const a = accentColor[sec.accent];
  const meta = (s: Shot) => `frames/uz/${s.set}/${s.frame}.png`;
  const mark = shot.mark ? {rect: shot.mark as [number, number, number, number], t: ease(local, 5, 10), tone: (sec.accent === 'amber' ? 'amber' : 'mint') as 'amber' | 'mint'} : null;
  const tap = shot.tap ? {at: shot.tap as [number, number], t: ease(local, 4, 12)} : null;
  const zoom = 1 + 0.07 * easeIO(local, 0, len);
  const focus: [number, number] = shot.mark ? [shot.mark[0] + shot.mark[2] / 2, shot.mark[1] + shot.mark[3] / 2] : [195, 422];
  const bob = Math.sin(frame / 40) * 5;
  return (
    <>
      <div style={{position: 'absolute', left: W / 2 - 520, top: PH_TOP + 60, width: 1040, height: 900, borderRadius: 999, background: `radial-gradient(closest-side, ${a}30, transparent 70%)`}} />
      {/* glossy lab objects behind the phone (depth) */}
      <div style={{position: 'absolute', left: -30, top: 880 + bob * 2, opacity: 0.85, transform: 'rotate(-6deg) scale(0.9)'}}><TubeRack h={230} /></div>
      <div style={{position: 'absolute', left: 835, top: 760 - bob * 2, opacity: 0.9, transform: 'rotate(5deg)'}}><Beaker w={190} /></div>
      <div
        style={{
          position: 'absolute',
          left: (W - PH_W) / 2,
          top: PH_TOP + bob,
          transform: `perspective(2000px) rotateY(${(1 - enter) * -38}deg) translateX(${(1 - enter) * 160}px) scale(${0.9 + 0.1 * enter})`,
          opacity: Math.min(1, 0.25 + enter * 1.2),
          WebkitMaskImage: 'linear-gradient(to bottom, black 88%, transparent 100%)',
          maskImage: 'linear-gradient(to bottom, black 88%, transparent 100%)',
        }}
      >
        <PhoneFrame appW={390} appH={844} src={meta(shot)} prevSrc={prev ? meta(prev) : null} mix={prev ? ease(local, 0, 7) : 1} width={PH_W} zoom={zoom} focus={focus} mark={mark} tap={tap} />
      </div>
    </>
  );
};

// ------------------------------------------------------------ hook
const Sheet: React.FC<{w: number; seed: number}> = ({w, seed}) => {
  const rows = 7;
  const h = w * 1.3;
  return (
    <div style={{width: w, height: h, borderRadius: w * 0.05, background: 'linear-gradient(160deg,#F1F2EC,#D9DDD3)', boxShadow: '0 24px 60px rgba(0,0,0,0.5)', padding: w * 0.09, boxSizing: 'border-box', position: 'relative'}}>
      <div style={{height: w * 0.05, width: '55%', borderRadius: 99, background: 'rgba(30,60,52,0.4)', marginBottom: w * 0.07}} />
      {Array.from({length: rows}).map((_, i) => {
        const groups = 1 + Math.floor(rnd(i, seed) * 4);
        return (
          <div key={i} style={{display: 'flex', alignItems: 'center', gap: w * 0.04, height: w * 0.1, borderBottom: '2px solid rgba(30,60,52,0.18)'}}>
            <div style={{width: w * 0.2, height: w * 0.035, borderRadius: 99, background: 'rgba(30,60,52,0.3)'}} />
            <svg width={w * 0.6} height={w * 0.09} viewBox="0 0 120 18">
              {Array.from({length: groups}).map((__, g) => (
                <g key={g} stroke="#243A33" strokeWidth="2" strokeLinecap="round">
                  {[0, 1, 2, 3].map((k) => (
                    <line key={k} x1={g * 28 + k * 5 + 2} y1="2" x2={g * 28 + k * 5 + 2} y2="16" />
                  ))}
                  <line x1={g * 28} y1="14" x2={g * 28 + 20} y2="4" />
                </g>
              ))}
            </svg>
          </div>
        );
      })}
    </div>
  );
};

const SHEETS = [
  {x: 0.15, y: 0.38, rot: -14, w: 310, seed: 1},
  {x: 0.86, y: 0.36, rot: 12, w: 290, seed: 2},
  {x: 0.1, y: 0.58, rot: 9, w: 260, seed: 3},
  {x: 0.9, y: 0.57, rot: -10, w: 270, seed: 4},
];

const HookScene: React.FC<{frame: number}> = ({frame}) => {
  const pw = 400;
  const ph = phoneHeight(pw);
  const cx = W / 2;
  const cy = 1050;
  const pullStart = f(2.2);
  const pull = easeIO(frame, pullStart, 30);
  const landStart = pullStart + 22;
  const enterPhone = pop(frame, FPS, -6, 100);
  const rotY = (34 * Math.sin(frame / 20 + 0.5) - 8) * (1 - 0.75 * ease(frame, landStart, 20)) + (1 - enterPhone) * -50;
  const head = 1 - ease(frame, pullStart - 4, 10);
  const headPop = pop(frame, FPS, -4, 170);
  const wordmark = ease(frame, landStart + 10, 10);
  const iconS = pop(frame, FPS, landStart, 80);
  const glint = frame >= landStart + 14 ? Math.min(1, (frame - landStart - 14) / 20) : null;
  const iconSize = 170;
  const iconTy = cy - ph * 0.27;
  const ring = easeIO(frame, landStart + 10, 20);
  const par = rotY / 30;
  const props = [
    {el: <Scope w={760} />, x: 0.5, y: 0.56, z: 0.1, rot: 0, o: 0.5},
    {el: <TubeRack h={200} />, x: 0.13, y: 0.7, z: 0.85, rot: -5, o: 1},
    {el: <Beaker w={150} />, x: 0.9, y: 0.7, z: 0.8, rot: 4, o: 1},
    {el: <Flask w={110} />, x: 0.9, y: 0.19, z: 0.3, rot: 10, o: 0.8},
  ];
  return (
    <AbsoluteFill style={{perspective: 1600}}>
      <div style={{position: 'absolute', left: cx - 560, top: cy - 560, width: 1120, height: 1120, borderRadius: 999, background: `radial-gradient(closest-side, ${color.brandBright}66, transparent 70%)`}} />
      {props.map((p, i) => {
        const e = pop(frame, FPS, -4 + i * 3, 90);
        const x = p.x * W + par * (p.z - 0.4) * 90;
        const y = p.y * H + Math.sin(frame / (34 + i * 7) + i) * 8 + (1 - e) * 220;
        return (
          <div key={i} style={{position: 'absolute', left: x, top: y, transform: `translate(-50%,-50%) rotate(${p.rot}deg) scale(${0.75 + 0.25 * e + p.z * 0.1})`, opacity: p.o * (0.45 + 0.55 * p.z) * e, filter: `blur(${(1 - p.z) * 4}px)`}}>
            {p.el}
          </div>
        );
      })}
      {SHEETS.map((s, i) => {
        const enter = pop(frame, FPS, -9 + i * 2, 120);
        const fromX = s.x < 0.5 ? -W * 0.5 : W * 1.5;
        const px = s.x * W;
        const py = s.y * H;
        const bx = fromX + (px - fromX) * enter;
        const by = py + (1 - enter) * -500 + Math.sin(frame / 22 + i * 1.7) * 14;
        const x = bx + (cx - bx) * pull;
        const y = by + (cy - by) * pull;
        const scale = (0.6 + 0.4 * enter) * (1 - 0.82 * pull);
        const opacity = 1 - Math.max(0, (pull - 0.7) / 0.3);
        return (
          <div key={i} style={{position: 'absolute', left: x, top: y, opacity, transform: `translate(-50%,-50%) rotate(${s.rot + Math.sin(frame / 31 + i) * 2.4 + (1 - enter) * 40 + pull * 120}deg) rotateX(${22 * (1 - enter) + Math.sin(frame / 40 + i) * 7}deg) rotateY(${Math.cos(frame / 47 + i * 2) * 14 + par * 10}deg) scale(${scale})`}}>
            <Sheet w={s.w} seed={s.seed} />
          </div>
        );
      })}
      <div style={{position: 'absolute', left: cx - pw / 2, top: cy - ph / 2 + Math.sin(frame / 38) * 9, transform: `scale(${0.86 + 0.14 * enterPhone})`, opacity: Math.min(1, 0.3 + enterPhone)}}>
        <Phone3D src="frames/uz/overview/home_lab.png" width={pw} rotY={rotY} rotX={6 - 4 * ease(frame, landStart, 20)} sweep={((frame + 20) % 70) / 70} glow={0.28 + 0.3 * pull} />
      </div>
      {/* the uz question, large; ru + en live in the caption stack */}
      <div
        style={{
          position: 'absolute',
          left: 70,
          right: 70,
          top: 205,
          textAlign: 'center',
          opacity: head,
          transform: `scale(${0.88 + 0.12 * headPop})`,
          ...txt(104, 800, color.ink),
          letterSpacing: -3,
          lineHeight: 1.04,
          textWrap: 'balance' as never,
          textShadow: '0 6px 40px rgba(0,0,0,0.9), 0 0 24px rgba(0,0,0,0.7)',
        }}
      >
        {cues[0].uz}
      </div>
      <div style={{position: 'absolute', left: cx - iconSize / 2, top: iconTy - iconSize / 2 - (1 - Math.min(1, iconS)) * 620, opacity: ease(frame, landStart - 4, 6), transform: `scale(${1.5 - 0.5 * Math.min(1.1, iconS)})`}}>
        <Icon3D size={iconSize} rotX={(1 - iconS) * 70} rotY={(1 - iconS) * 220} glint={glint} />
      </div>
      <div style={{position: 'absolute', left: cx - iconSize * 1.1, top: iconTy - iconSize * 1.1, width: iconSize * 2.2, height: iconSize * 2.2, borderRadius: 999, border: `4px solid ${color.mint}`, opacity: (1 - ring) * (frame >= landStart + 10 ? 0.8 : 0), transform: `scale(${0.4 + ring * 1.3})`}} />
      <div style={{position: 'absolute', left: 0, right: 0, top: 215, textAlign: 'center', opacity: wordmark, transform: `translateY(${(1 - wordmark) * 20}px)`, ...txt(150, 800, color.ink), letterSpacing: -4, textShadow: '0 6px 40px rgba(0,0,0,0.9)'}}>LabGuide</div>
    </AbsoluteFill>
  );
};

// ------------------------------------------------------------ end card
const EndScene: React.FC<{frame: number}> = ({frame}) => {
  const local = frame - f(34.8);
  const t = pop(local, FPS, 0, 110);
  const word = ease(local, 8, 12);
  const chips = ease(local, 18, 12);
  const glint = local > 16 ? Math.min(1, (local - 16) / 30) : null;
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: W / 2 - 500, top: 180, width: 1000, height: 1000, borderRadius: 999, background: `radial-gradient(closest-side, ${color.brandBright}66, transparent 70%)`}} />
      <div style={{position: 'absolute', left: -20, top: 1020, transform: 'rotate(-6deg)'}}><TubeRack h={260} /></div>
      <div style={{position: 'absolute', left: 800, top: 940}}><Beaker w={230} /></div>
      <div style={{position: 'absolute', left: W / 2 - 160, top: 300, opacity: Math.min(1, t * 1.4), transform: `scale(${0.7 + 0.3 * t})`}}>
        <Icon3D size={320} rotX={-8 + Math.sin(local / 20) * 4} rotY={-16 + Math.sin(local / 26) * 10} glint={glint} />
      </div>
      <div style={{position: 'absolute', left: 0, right: 0, top: 700, textAlign: 'center', opacity: word, transform: `translateY(${(1 - word) * 24}px)`, ...txt(168, 800, color.ink), letterSpacing: -5}}>LabGuide</div>
      <div style={{position: 'absolute', left: 0, right: 0, top: 930, display: 'flex', justifyContent: 'center', opacity: chips, transform: `translateY(${(1 - chips) * 18}px)`}}>
        <div style={{padding: '14px 40px', borderRadius: 999, background: color.mintSoft, border: `2px solid ${color.mint}`, ...txt(54, 700, color.mint), letterSpacing: 4}}>uz · ru · en</div>
      </div>
    </AbsoluteFill>
  );
};

export const Reel: React.FC = () => {
  useFonts();
  const frame = useCurrentFrame();
  const sec = sections.find((s) => frame >= f(s.start) && frame < f(s.end));
  const tint = sec ? accentColor[sec.accent] : color.brandBright;
  const inHook = frame < f(3.8);
  const inEnd = frame >= f(34.8);
  const xfade = (at: number, len: number) => ease(frame, at, len);
  return (
    <AbsoluteFill style={{backgroundColor: '#05110E'}}>
      <Background format="vertical" glow={[0.5, 0.45]} tint={tint} />
      {inHook ? <AbsoluteFill style={{opacity: 1 - xfade(f(3.8) - 5, 5)}}><HookScene frame={frame} /></AbsoluteFill> : null}
      {!inHook && !inEnd ? (
        <AbsoluteFill style={{opacity: xfade(f(3.8), 6) * (1 - xfade(f(34.8) - 4, 4))}}>
          <PhoneStage frame={frame} />
          <StepPill frame={frame} />
        </AbsoluteFill>
      ) : null}
      {inEnd ? <AbsoluteFill style={{opacity: xfade(f(34.8), 6)}}><EndScene frame={frame} /></AbsoluteFill> : null}
      <CaptionStack frame={frame} />
    </AbsoluteFill>
  );
};
