// Video definition: storyboard + language packs live in docs/video/calibration
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import storyboard from '../../../../docs/video/calibration/storyboard.json';
import en from '../../../../docs/video/calibration/lines.en.json';
import ru from '../../../../docs/video/calibration/lines.ru.json';
import uz from '../../../../docs/video/calibration/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {CalibrationChart} from '../../components/Chart';
import {color, font} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {calibrationMath} from '../../lib/regression.js';
import {calibrationVars} from '../../lib/text.js';
import {layers, Logo} from './layers';

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui, lang, math} = ctx;
  const land = kind === 'landscape';
  const W = land ? 1280 : 1080;
  const fit = math.fit;
  const cals = math.calibrators as {id: string; conc: number; abs: number}[];
  const chart = (
    <CalibrationChart
      width={land ? 600 : 900}
      height={land ? 470 : 720}
      lang={lang}
      points={cals.map((c) => ({x: c.conc, y: c.abs, id: c.id}))}
      slope={fit.slope}
      intercept={fit.intercept}
      domain={{x: [0, 10.8], y: [0, 0.9], xTicks: [0, 2.5, 5, 7.5, 10], yTicks: [0, 0.2, 0.4, 0.6, 0.8]}}
      axisX={ui.axisX}
      axisY={ui.axisY}
      tick={land ? 18 : 26}
      axesT={1}
      pointT={cals.map(() => 1)}
      lineT={1}
      controls={[]}
      controlT={[]}
      controlLabel={() => ''}
    />
  );
  const title = (
    <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 104 : 140, letterSpacing: -3, color: color.ink, lineHeight: 1}}>
      {ui.thumbHeadline}
    </div>
  );
  const sub = (
    <div style={{fontFamily: font.serif, fontSize: land ? 50 : 72, color: color.mint, lineHeight: 1.08, textWrap: 'balance' as never}}>
      {ui.thumbSub}
    </div>
  );
  const brand = (
    <div style={{display: 'flex', alignItems: 'center', gap: 22}}>
      <Logo size={land ? 76 : 120} />
      <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 40 : 60, color: color.ink}}>LabGuide</div>
    </div>
  );
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.4] : [0.5, 0.5]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 70, top: 80, width: 560, display: 'flex', flexDirection: 'column', gap: 26}}>
            {brand}
            <div style={{height: 20}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 640, top: 110}}>{chart}</div>
          <div style={{position: 'absolute', left: 70, bottom: 56}}>
            <Badge text={ui.illustrative} tone="amber" size={22} />
          </div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, right: 90, top: 190, display: 'flex', flexDirection: 'column', gap: 34}}>
            {brand}
            <div style={{height: 30}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 70, top: 900}}>{chart}</div>
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 230, display: 'flex', justifyContent: 'center'}}>
            <Badge text={ui.illustrative} tone="amber" size={30} />
          </div>
        </>
      )}
      <div style={{position: 'absolute', width: W}} />
    </AbsoluteFill>
  );
};

export const calibrationVideo: VideoDef = {
  id: 'calibration',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['chart', 'phone'],
  compute: (sb) => calibrationMath(sb.data as never),
  vars: (math, lang) => calibrationVars(math, lang),
  Thumb,
};
