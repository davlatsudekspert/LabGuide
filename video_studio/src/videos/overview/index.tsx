// Video definition: storyboard + language packs live in docs/video/overview
// (single source of truth, reviewed there); visuals live in ./layers.
import React from 'react';
import {AbsoluteFill, Img, staticFile} from 'remotion';
import storyboard from '../../../../docs/video/overview/storyboard.json';
import en from '../../../../docs/video/overview/lines.en.json';
import ru from '../../../../docs/video/overview/lines.ru.json';
import uz from '../../../../docs/video/overview/lines.uz.json';
import {Background, Badge} from '../../components/Basics';
import {color, font} from '../../design/theme';
import type {LangPack, Storyboard, VideoCtx, VideoDef} from '../../framework/types';
import {Logo} from '../calibration/layers';
import {accentOf, layers, RoleBadge} from './layers';

const Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}> = ({ctx, kind}) => {
  const {ui, lang} = ctx;
  const land = kind === 'landscape';
  const n = [...ui.thumbHeadline].length;
  const size = land ? (n <= 18 ? 84 : 70) : n <= 18 ? 124 : 106;
  const shot = (id: string, w: number, rot: number, x: number, y: number, z: number) => (
    <div style={{position: 'absolute', left: x, top: y, zIndex: z, transform: `rotate(${rot}deg)`, width: w, borderRadius: w * 0.08, overflow: 'hidden', border: `3px solid ${color.line}`, boxShadow: '0 30px 70px rgba(0,0,0,0.55)'}}>
      <Img src={staticFile(`frames/${lang}/overview/${id}.png`)} style={{width: '100%', display: 'block'}} />
    </div>
  );
  const brand = (
    <div style={{display: 'flex', alignItems: 'center', gap: 22}}>
      <Logo size={land ? 70 : 110} />
      <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: land ? 38 : 58, color: color.ink}}>LabGuide</div>
    </div>
  );
  const title = <div style={{fontFamily: font.sans, fontWeight: 700, fontSize: size, letterSpacing: -2.5, color: color.ink, lineHeight: 1.02, textWrap: 'balance' as never}}>{ui.thumbHeadline}</div>;
  const roles = (
    <div style={{display: 'flex', flexDirection: land ? 'column' : 'row', gap: land ? 16 : 30, flexWrap: 'wrap'}}>
      <RoleBadge role="specialist" size={land ? 24 : 36} label={ui.roleSpecialist} />
      <RoleBadge role="teacher" size={land ? 24 : 36} label={ui.roleTeacher} />
      <RoleBadge role="student" size={land ? 24 : 36} label={ui.roleStudent} />
    </div>
  );
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.45] : [0.5, 0.65]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 64, top: 70, width: 560, display: 'flex', flexDirection: 'column', gap: 26}}>
            {brand}
            <div style={{height: 6}} />
            {title}
            <div style={{height: 6}} />
            {roles}
          </div>
          {shot('home_lab', 250, -6, 640, 150, 1)}
          {shot('home_teacher', 270, 0, 850, 100, 3)}
          {shot('home_student', 250, 6, 1070, 160, 2)}
          <div style={{position: 'absolute', left: 64, bottom: 30}}><Badge text={ui.thumbNote} tone="mint" size={18} /></div>
        </>
      ) : (
        <>
          <div style={{position: 'absolute', left: 90, right: 90, top: 150, display: 'flex', flexDirection: 'column', gap: 34}}>
            {brand}
            <div style={{height: 8}} />
            {title}
            {roles}
          </div>
          {shot('home_lab', 440, -6, -10, 760, 1)}
          {shot('home_teacher', 480, 0, 300, 640, 3)}
          {shot('home_student', 440, 6, 650, 770, 2)}
          <div style={{position: 'absolute', left: 0, right: 0, bottom: 50, display: 'flex', justifyContent: 'center', zIndex: 5}}><Badge text={ui.thumbNote} tone="mint" size={26} /></div>
        </>
      )}
    </AbsoluteFill>
  );
};

export const overviewVideo: VideoDef = {
  id: 'overview',
  storyboard: storyboard as unknown as Storyboard,
  packs: {en: en as LangPack, ru: ru as LangPack, uz: uz as LangPack},
  layers,
  narrationLang: 'en',
  continuous: ['role'],
  compute: () => ({}),
  vars: () => ({}),
  Thumb,
};
