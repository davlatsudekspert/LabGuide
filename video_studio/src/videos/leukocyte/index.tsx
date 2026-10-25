// Video definition: storyboard + language packs live in docs/video/leukocyte
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import storyboard from '../../../../docs/video/leukocyte/storyboard.json';
import en from '../../../../docs/video/leukocyte/lines.en.json';
import ru from '../../../../docs/video/leukocyte/lines.ru.json';
import uz from '../../../../docs/video/leukocyte/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {CellPortrait, type CellKind} from '../../components/Cells';
import {MicroscopeField, trackWorld} from '../../components/MicroscopeField';
import {color, font, tabular} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {differentialMath, differentialVars} from '../../lib/differential.js';
import {Logo} from '../calibration/layers';
import {classColor, layers} from './layers';

const ROWS: CellKind[] = ['segmented', 'band', 'lymphocyte', 'monocyte', 'eosinophil', 'basophil'];

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui, math} = ctx;
  const land = kind === 'landscape';
  const {wbcs, at} = trackWorld(math.sequence as CellKind[], 46);
  const field = <MicroscopeField size={land ? 560 : 760} viewUm={58} center={at(20 + 46 * 4 + 6)} wbcs={wbcs} id={`thumb-${kind}`} reticle />;
  const title = (
    <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 84 : 124, letterSpacing: -2.5, color: color.ink, lineHeight: 1, textWrap: 'balance' as never}}>
      {ui.thumbHeadline}
    </div>
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
  const tally = (
    <div style={{display: 'flex', gap: land ? 12 : 18}}>
      {ROWS.map((c, i) => (
        <div key={c} style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6}}>
          <CellPortrait kind={c} size={land ? 74 : 118} viewUm={21} withRbc={false} seed={9 + i} id={`tt-${kind}-${c}`} />
          <div style={{fontFamily: font.sans, fontWeight: 800, fontSize: land ? 30 : 44, color: classColor[c], ...tabular}}>{math.counts[c]}</div>
          <div style={{fontFamily: font.sans, fontWeight: 600, fontSize: land ? 17 : 25, color: color.inkDim}}>{ui[`s_${c}`]}</div>
        </div>
      ))}
    </div>
  );
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.4] : [0.5, 0.45]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 64, top: 64, width: 600, display: 'flex', flexDirection: 'column', gap: 22}}>
            {brand}
            <div style={{height: 8}} />
            {title}
            {sub}
            <div style={{height: 10}} />
            {tally}
          </div>
          <div style={{position: 'absolute', left: 680, top: 80}}>{field}</div>
          <div style={{position: 'absolute', left: 64, bottom: 34, display: 'flex', gap: 12}}>
            <Badge text={ui.illustrative} tone="amber" size={18} />
            <Badge text={ui.schematicNote} size={18} />
          </div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, right: 90, top: 150, display: 'flex', flexDirection: 'column', gap: 30}}>
            {brand}
            <div style={{height: 14}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 160, top: 712}}>{field}</div>
          <div style={{position: 'absolute', left: 0, right: 0, top: 1508, display: 'flex', justifyContent: 'center'}}>{tally}</div>
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 40, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12}}>
            <Badge text={ui.illustrative} tone="amber" size={26} />
            <Badge text={ui.schematicNote} size={22} />
          </div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const leukocyteVideo: VideoDef = {
  id: 'leukocyte',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['cells', 'phone'],
  compute: (sb) => differentialMath(sb.data as never),
  vars: (math, lang) => differentialVars(math, lang),
  Thumb,
};
