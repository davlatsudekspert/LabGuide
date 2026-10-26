// Video definition: storyboard + language packs live in docs/video/qpcr
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import storyboard from '../../../../docs/video/qpcr/storyboard.json';
import en from '../../../../docs/video/qpcr/lines.en.json';
import ru from '../../../../docs/video/qpcr/lines.ru.json';
import uz from '../../../../docs/video/qpcr/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {SchematicStage} from '../../components/SchematicStage';
import {color, font} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {qpcrMath, qpcrVars} from '../../lib/qpcr.js';
import {Logo} from '../calibration/layers';
import {AmpPlot, layers} from './layers';

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui} = ctx;
  const land = kind === 'landscape';
  // Headline size by length (EN "Real-time PCR", UZ "Real vaqt PCR", RU 22
  // chars): the landscape column is 540 px and must not reach the plot.
  const n = [...ui.thumbHeadline].length;
  const size = land ? (n <= 10 ? 84 : n <= 14 ? 72 : 64) : n <= 14 ? 120 : 104;
  const title = <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: size, letterSpacing: -2.5, color: color.ink, lineHeight: 1.02, textWrap: 'balance' as never}}>{ui.thumbHeadline.replace(/-/g, '\u2011')}</div>;
  const sub = <div style={{fontFamily: font.serif, fontSize: land ? 50 : 72, color: color.mint, lineHeight: 1.08, textWrap: 'balance' as never}}>{ui.thumbSub}</div>;
  const brand = (
    <div style={{display: 'flex', alignItems: 'center', gap: 22}}>
      <Logo size={land ? 70 : 110} />
      <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 38 : 58, color: color.ink}}>LabGuide</div>
    </div>
  );
  const plot = <AmpPlot ctx={ctx} w={land ? 620 : 940} h={land ? 420 : 640} upto={40} tick={land ? 18 : 26} showCq={1} thrT={1} id={`qthumb-${kind}`} />;
  const sch = (
    <div style={{borderRadius: 26, overflow: 'hidden', background: '#E9EEEA', width: land ? 340 : 560}}>
      <SchematicStage name="real_time_pcr" width={land ? 340 : 560} emphasis={{}} dim={0} />
    </div>
  );
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.4] : [0.5, 0.45]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 64, top: 70, width: 540, display: 'flex', flexDirection: 'column', gap: 22}}>
            {brand}
            <div style={{height: 10}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 64, top: 470}}>{sch}</div>
          <div style={{position: 'absolute', left: 620, top: 140}}>{plot}</div>
          <div style={{position: 'absolute', left: 640, bottom: 40}}><Badge text={ui.illustrative} tone="amber" size={18} /></div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, right: 90, top: 160, display: 'flex', flexDirection: 'column', gap: 30}}>
            {brand}
            <div style={{height: 14}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 60, top: 790}}>{plot}</div>
          <div style={{position: 'absolute', left: 260, top: 1460}}>{sch}</div>
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 50, display: 'flex', justifyContent: 'center'}}><Badge text={ui.illustrative} tone="amber" size={26} /></div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const qpcrVideo: VideoDef = {
  id: 'qpcr',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['phone'],
  compute: (sb) => qpcrMath(sb.data as never),
  vars: (math, lang) => qpcrVars(math, lang),
  Thumb,
};
