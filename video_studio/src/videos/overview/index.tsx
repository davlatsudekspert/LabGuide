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
import {layers, RoleBadge} from './layers';
import {Beaker, Icon3D, Phone3D, Scope, TubeRack} from './hero3d';

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
  const src = `frames/${lang}/overview/home_lab.png`;
  const hero = (pw: number, rot: number) => (
    <Phone3D src={src} width={pw} rotY={rot} rotX={6} sweep={0.45} glow={0.45} />
  );
  return (
    <AbsoluteFill>
      <Background format={land ? 'horizontal' : 'vertical'} glow={land ? [0.75, 0.45] : [0.5, 0.7]} />
      {land ? (
        <>
          <div style={{position: 'absolute', left: 64, top: 70, width: 560, display: 'flex', flexDirection: 'column', gap: 26}}>
            {brand}
            <div style={{height: 6}} />
            {title}
            <div style={{height: 6}} />
            {roles}
          </div>
          <div style={{position: 'absolute', left: 560, top: 80, opacity: 0.5, filter: 'blur(3px)'}}><Scope w={460} /></div>
          <div style={{position: 'absolute', left: 840, top: 40}}>{hero(300, -24)}</div>
          <div style={{position: 'absolute', left: 650, top: 440}}><TubeRack h={190} /></div>
          <div style={{position: 'absolute', left: 1090, top: 470}}><Beaker w={150} /></div>
          <div style={{position: 'absolute', left: 940, top: 110}}><Icon3D size={110} rotX={-8} rotY={-18} glint={0.55} /></div>
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
          <div style={{position: 'absolute', left: 170, top: 520, opacity: 0.5, filter: 'blur(4px)'}}><Scope w={820} /></div>
          <div style={{position: 'absolute', left: 240, top: 520}}>{hero(600, -22)}</div>
          <div style={{position: 'absolute', left: 20, top: 1440}}><TubeRack h={300} /></div>
          <div style={{position: 'absolute', left: 790, top: 1520}}><Beaker w={220} /></div>
          <div style={{position: 'absolute', left: 450, top: 600}}><Icon3D size={200} rotX={-8} rotY={-18} glint={0.55} /></div>
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
