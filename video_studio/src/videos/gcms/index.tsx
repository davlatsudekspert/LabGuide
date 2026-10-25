// Video definition: storyboard + language packs live in docs/video/gcms
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill} from 'remotion';
import storyboard from '../../../../docs/video/gcms/storyboard.json';
import en from '../../../../docs/video/gcms/lines.en.json';
import ru from '../../../../docs/video/gcms/lines.ru.json';
import uz from '../../../../docs/video/gcms/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {SchematicStage} from '../../components/SchematicStage';
import {color, font} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {gcmsMath, gcmsVars} from '../../lib/gcms.js';
import {Logo} from '../calibration/layers';
import {Chromatogram, layers} from './layers';

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui} = ctx;
  const land = kind === 'landscape';
  const title = <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 110 : 150, letterSpacing: -3, color: color.ink, lineHeight: 1}}>{ui.thumbHeadline}</div>;
  const sub = <div style={{fontFamily: font.serif, fontSize: land ? 50 : 72, color: color.mint, lineHeight: 1.08, textWrap: 'balance' as never}}>{ui.thumbSub}</div>;
  const brand = (
    <div style={{display: 'flex', alignItems: 'center', gap: 22}}>
      <Logo size={land ? 70 : 110} />
      <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 38 : 58, color: color.ink}}>LabGuide</div>
    </div>
  );
  const sch = (
    <div style={{borderRadius: 26, overflow: 'hidden', background: '#E9EEEA', width: land ? 600 : 920}}>
      <SchematicStage name="mass_spec_gc" width={land ? 600 : 920} emphasis={{}} dim={0} />
    </div>
  );
  const chrom = <Chromatogram ctx={ctx} w={land ? 600 : 920} h={land ? 230 : 330} upto={ctx.math.tMax} tick={land ? 16 : 24} marks={[0, 1, 2]} labels={(p) => p.id} id={`gcthumb-${kind}`} />;
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
          </div>
          <div style={{position: 'absolute', left: 640, top: 50}}>{sch}</div>
          <div style={{position: 'absolute', left: 640, top: 460}}>{chrom}</div>
          <div style={{position: 'absolute', left: 64, bottom: 40}}><Badge text={ui.illustrative} tone="amber" size={20} /></div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, right: 90, top: 170, display: 'flex', flexDirection: 'column', gap: 30}}>
            {brand}
            <div style={{height: 20}} />
            {title}
            {sub}
          </div>
          <div style={{position: 'absolute', left: 80, top: 820}}>{sch}</div>
          <div style={{position: 'absolute', left: 80, top: 1460}}>{chrom}</div>
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 60, display: 'flex', justifyContent: 'center'}}><Badge text={ui.illustrative} tone="amber" size={28} /></div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const gcmsVideo: VideoDef = {
  id: 'gcms',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['phone'],
  compute: (sb) => gcmsMath(sb.data as never),
  vars: () => gcmsVars(),
  Thumb,
};
