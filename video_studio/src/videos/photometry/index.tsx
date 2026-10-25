// Video definition: storyboard + language packs live in docs/video/photometry
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import storyboard from '../../../../docs/video/photometry/storyboard.json';
import en from '../../../../docs/video/photometry/lines.en.json';
import ru from '../../../../docs/video/photometry/lines.ru.json';
import uz from '../../../../docs/video/photometry/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {Cuvette, OpticalBench} from '../../components/OpticalBench';
import {color, font, tabular} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {photometryMath, photometryVars} from '../../lib/photometry.js';
import {fmt} from '../../lib/text.js';
import {Logo} from '../calibration/layers';
import {layers} from './layers';

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui, lang, math} = ctx;
  const land = kind === 'landscape';
  const title = (
    <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 96 : 132, letterSpacing: -3, color: color.ink, lineHeight: 1}}>{ui.thumbHeadline}</div>
  );
  const sub = (
    <div style={{fontFamily: font.serif, fontSize: land ? 48 : 70, color: color.mint, lineHeight: 1.08, textWrap: 'balance' as never}}>{ui.thumbSub}</div>
  );
  const brand = (
    <div style={{display: 'flex', alignItems: 'center', gap: 22}}>
      <Logo size={land ? 70 : 110} />
      <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 38 : 58, color: color.ink}}>LabGuide</div>
    </div>
  );
  const trio = (
    <div style={{display: 'flex', gap: land ? 34 : 60, alignItems: 'flex-end'}}>
      {[
        {k: ui.blank, a: 0.02, v: 0},
        {k: ui.standard, a: math.standard.abs, v: math.standard.abs},
        {k: ui.sample, a: math.sample.abs, v: math.sample.abs},
      ].map((c) => (
        <div key={c.k} style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10}}>
          <Cuvette width={land ? 84 : 130} absorbance={c.a} lit={0} />
          <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 24 : 36, color: color.ink}}>{c.k}</div>
          <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 22 : 32, color: color.beam, ...tabular}}>{`A ${fmt(c.v, lang, 3)}`}</div>
        </div>
      ))}
    </div>
  );
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.4] : [0.5, 0.45]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 64, top: 70, width: 600, display: 'flex', flexDirection: 'column', gap: 24}}>
            {brand}
            <div style={{height: 14}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 660, top: 90}}>
            <OpticalBench width={580} absorbance={0.45} beamT={1} lang={lang} showReadout={false} minimal />
          </div>
          <div style={{position: 'absolute', left: 760, top: 330}}>{trio}</div>
          <div style={{position: 'absolute', left: 64, bottom: 40}}>
            <Badge text={ui.illustrative} tone="amber" size={20} />
          </div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, right: 90, top: 170, display: 'flex', flexDirection: 'column', gap: 30}}>
            {brand}
            <div style={{height: 20}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 70, top: 880}}>
            <OpticalBench width={940} absorbance={0.45} beamT={1} lang={lang} showReadout={false} minimal />
          </div>
          <div style={{position: 'absolute', left: 0, right: 0, top: 1250, display: 'flex', justifyContent: 'center'}}>{trio}</div>
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 70, display: 'flex', justifyContent: 'center'}}>
            <Badge text={ui.illustrative} tone="amber" size={28} />
          </div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const photometryVideo: VideoDef = {
  id: 'photometry',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['phone', 'lightpath'],
  compute: (sb) => photometryMath(sb.data as never),
  vars: (math, lang) => photometryVars(math, lang),
  Thumb,
};
