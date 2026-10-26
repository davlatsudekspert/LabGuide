// Video definition: storyboard + language packs live in docs/video/calculators
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill, Img, staticFile} from 'remotion';
import storyboard from '../../../../docs/video/calculators/storyboard.json';
import en from '../../../../docs/video/calculators/lines.en.json';
import ru from '../../../../docs/video/calculators/lines.ru.json';
import uz from '../../../../docs/video/calculators/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {color, font} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {calcMath, calcVars} from '../../lib/calculators.js';
import {Logo} from '../calibration/layers';
import {FormulaCard, layers} from './layers';

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui, lang} = ctx;
  const land = kind === 'landscape';
  const n = [...ui.thumbHeadline].length;
  const size = land ? (n <= 10 ? 84 : n <= 15 ? 72 : 64) : n <= 15 ? 120 : 104;
  const title = <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: size, letterSpacing: -2.5, color: color.ink, lineHeight: 1.02, textWrap: 'balance' as never}}>{ui.thumbHeadline}</div>;
  const sub = <div style={{fontFamily: font.serif, fontSize: land ? 46 : 66, color: color.mint, lineHeight: 1.08, textWrap: 'balance' as never}}>{ui.thumbSub}</div>;
  const brand = (
    <div style={{display: 'flex', alignItems: 'center', gap: 22}}>
      <Logo size={land ? 70 : 110} />
      <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 38 : 58, color: color.ink}}>LabGuide</div>
    </div>
  );
  // A real app frame: the eGFR result (illustrative inputs), from the walk.
  const shot = (w: number) => (
    <div style={{width: w, borderRadius: w * 0.08, overflow: 'hidden', border: `3px solid ${color.line}`, boxShadow: '0 24px 60px rgba(0,0,0,0.45)'}}>
      <Img src={staticFile(`frames/${lang}/calculators/e_result.png`)} style={{width: '100%', display: 'block'}} />
    </div>
  );
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.4] : [0.5, 0.45]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 64, top: 70, width: 600, display: 'flex', flexDirection: 'column', gap: 22}}>
            {brand}
            <div style={{height: 10}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 64, top: 430}}>
            <FormulaCard ctx={ctx} width={640} size={24} />
          </div>
          <div style={{position: 'absolute', left: 860, top: -120, transform: 'rotate(-4deg)'}}>{shot(360)}</div>
          <div style={{position: 'absolute', left: 64, bottom: 30}}><Badge text={ui.illustrativeCalc} tone="mint" size={18} /></div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, right: 90, top: 160, display: 'flex', flexDirection: 'column', gap: 30}}>
            {brand}
            <div style={{height: 14}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 60, top: 760}}>
            <FormulaCard ctx={ctx} width={960} size={36} />
          </div>
          <div style={{position: 'absolute', left: 270, top: 1180, transform: 'rotate(-3deg)', height: 640, overflow: 'hidden'}}>{shot(540)}</div>
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 50, display: 'flex', justifyContent: 'center'}}><Badge text={ui.illustrativeCalc} tone="mint" size={26} /></div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const calculatorsVideo: VideoDef = {
  id: 'calculators',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['phone'],
  compute: (sb) => calcMath(sb.data as never),
  vars: () => calcVars(),
  Thumb,
};
