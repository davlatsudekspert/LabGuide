// Visual layers of the topic video "Laboratory calculators". Everything after
// the hook is REAL app frames (flutter_walk/calculators_walk_test.dart): the
// app computes every result. The hook shows the app's own eGFR formula text
// (ui.formula / ui.kappa = lib/features/tools/calc_info.dart) with "= ?" —
// no result is computed or shown by the video itself.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import {ease, pop} from '../../components/anim';
import {Badge, Pill} from '../../components/Basics';
import {isV, txt, useT} from '../../components/layerKit';
import {PhoneShotsLayer} from '../../components/PhoneShots';
import {color, font} from '../../design/theme';
import type {Layer, VideoCtx} from '../../framework/types';
import {CtaLayer} from '../calibration/layers';

/** The app's formula string with "^x" rendered as a superscript. */
export const Formula: React.FC<{text: string; size: number; t?: number}> = ({text, size, t = 1}) => {
  // Each factor (split at " × ") stays on one line: no break inside "min(Scr/κ, 1)".
  const terms = text.split(' × ');
  const sup = (term: string) =>
    term.split(/(\^\S+)/).map((p, i) =>
      p.startsWith('^') ? (
        <sup key={i} style={{fontSize: size * 0.62, color: color.mint}}>
          {p.slice(1)}
        </sup>
      ) : (
        <span key={i}>{p}</span>
      ),
    );
  return (
    <div style={{fontFamily: font.sans, fontWeight: 600, fontSize: size, color: color.ink, lineHeight: 1.5, opacity: t, textWrap: 'balance' as never, fontVariantNumeric: 'tabular-nums'}}>
      {terms.map((term, i) => (
        <React.Fragment key={i}>
          <span style={{whiteSpace: 'nowrap'}}>
            {sup(term)}
            {i < terms.length - 1 ? ' ×' : ''}
          </span>
          {i < terms.length - 1 ? ' ' : ''}
        </React.Fragment>
      ))}
    </div>
  );
};

export const FormulaCard: React.FC<{ctx: VideoCtx; width: number; size: number; t?: number}> = ({ctx, width, size, t = 1}) => (
  <div style={{width, padding: '30px 36px', borderRadius: 28, background: 'rgba(6,20,16,0.92)', border: `2px solid ${color.line}`, boxShadow: '0 20px 60px rgba(0,0,0,0.35)', opacity: t}}>
    <Formula text={ctx.ui.formula} size={size} />
    <div style={{...txt(size * 0.66, 500, color.inkDim), marginTop: 14}}>{ctx.ui.kappa}</div>
    <div style={{...txt(size * 0.55, 500, color.inkFaint), marginTop: 18}}>{ctx.ui.formulaSrc}</div>
  </div>
);

// ---------------------------------------------------------------- hook
export const HookLayer: Layer = ({scene, ctx}) => {
  const {frame, fps, cue} = useT(scene);
  const {m, ui} = ctx;
  const vertical = isV(ctx);
  // The formula card is on screen from frame 0 (hook from t = 0).
  const chips = [ui.inCreat, ui.inAge, ui.inSex].map((c, i) => ({c, t: ease(frame, 4 + i * 6, 10)}));
  const q = pop(frame, fps, cue(0) + Math.round(1.6 * fps));
  const warn = ease(frame, cue(1) + Math.round(1.4 * fps), 12);
  const chipRow = (
    <div style={{display: 'flex', flexWrap: 'wrap', gap: 16, justifyContent: vertical ? 'center' : 'flex-start'}}>
      {chips.map(({c, t}) => (
        <div key={c} style={{opacity: t, transform: `translateY(${(1 - t) * 12}px)`}}>
          <Pill text={c} size={vertical ? m.small * 1.1 : m.small} tone="mint" />
        </div>
      ))}
    </div>
  );
  const question = <div style={{...txt(vertical ? m.h1 * 1.25 : m.h1 * 1.2, 700, color.ink), opacity: q, transform: `scale(${0.9 + 0.1 * q})`, transformOrigin: vertical ? 'center' : 'left center'}}>{ui.hookQ}</div>;
  const unit = (
    <div style={{opacity: warn}}>
      <Pill text={ui.unitNote} size={vertical ? m.small * 1.05 : m.small} tone="amber" />
    </div>
  );
  const badge = <div style={{opacity: ease(frame, 10, 12)}}><Badge text={ui.illustrative} tone="amber" size={m.small * 0.8} /></div>;
  if (vertical) {
    return (
      <AbsoluteFill>
        <div style={{position: 'absolute', left: m.gutter, right: m.gutter, top: 230, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 34, textAlign: 'center'}}>
          {chipRow}
          <FormulaCard ctx={ctx} width={m.w - 2 * m.gutter} size={44} />
          {question}
          {unit}
          {badge}
        </div>
      </AbsoluteFill>
    );
  }
  return (
    <AbsoluteFill>
      <div style={{position: 'absolute', left: 90, top: 210}}>
        <FormulaCard ctx={ctx} width={1000} size={40} />
      </div>
      <div style={{position: 'absolute', left: 1180, right: m.gutter, top: 230, display: 'flex', flexDirection: 'column', gap: 30}}>
        {chipRow}
        {question}
        {unit}
        {badge}
      </div>
    </AbsoluteFill>
  );
};

export const layers: Record<string, Layer> = {
  hook: HookLayer,
  phone: PhoneShotsLayer,
  cta: CtaLayer,
};
