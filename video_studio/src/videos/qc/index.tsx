// Video definition: storyboard + language packs live in docs/video/qc
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import storyboard from '../../../../docs/video/qc/storyboard.json';
import en from '../../../../docs/video/qc/lines.en.json';
import ru from '../../../../docs/video/qc/lines.ru.json';
import uz from '../../../../docs/video/qc/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {Plot} from '../../components/Plot';
import {color, font} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {qcMath, qcVars} from '../../lib/qc.js';
import {Logo} from '../calibration/layers';
import {layers, runSeries, sdLines, zDomain} from './layers';

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui} = ctx;
  const land = kind === 'landscape';
  const n = (ctx.math.runs as unknown[]).length;
  const plot = (
    <Plot
      width={land ? 640 : 940}
      height={land ? 470 : 700}
      lang={ctx.lang}
      tick={land ? 18 : 26}
      domain={zDomain([0.5, n + 0.5], [])}
      hideXTicks
      series={[...sdLines(1), ...runSeries(ctx, n, () => 1, [6, 10, 12])]}
      idPrefix={`qcthumb-${kind}`}
    />
  );
  const title = <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 96 : 132, letterSpacing: -3, color: color.ink, lineHeight: 1}}>{ui.thumbHeadline}</div>;
  const sub = <div style={{fontFamily: font.serif, fontSize: land ? 50 : 72, color: color.mint, lineHeight: 1.08, textWrap: 'balance' as never}}>{ui.thumbSub}</div>;
  const brand = (
    <div style={{display: 'flex', alignItems: 'center', gap: 22}}>
      <Logo size={land ? 70 : 110} />
      <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 38 : 58, color: color.ink}}>LabGuide</div>
    </div>
  );
  const legend = <div style={{fontFamily: font.sans, fontWeight: 600, fontSize: land ? 22 : 32, color: color.inkDim}}>{ui.legend}</div>;
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.4] : [0.5, 0.45]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 64, top: 80, width: 520, display: 'flex', flexDirection: 'column', gap: 24}}>
            {brand}
            <div style={{height: 14}} />
            {title}
            {sub}
            {legend}
          </div>
          <div style={{position: 'absolute', left: 600, top: 120}}>{plot}</div>
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
          <div style={{position: 'absolute', left: 60, top: 860}}>{plot}</div>
          <div style={{position: 'absolute', left: 0, right: 0, top: 1600, display: 'flex', justifyContent: 'center'}}>{legend}</div>
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 80, display: 'flex', justifyContent: 'center'}}>
            <Badge text={ui.illustrative} tone="amber" size={28} />
          </div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const qcVideo: VideoDef = {
  id: 'qc',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['phone'],
  compute: (sb) => qcMath(sb.data as never),
  vars: (math, lang) => qcVars(math, lang),
  Thumb,
};
