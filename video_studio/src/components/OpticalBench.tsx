// Original cut-away of a photometric light path (textbook principle, not a
// specific instrument): lamp -> filter -> cuvette -> detector. The light
// leaving the cuvette is drawn with transmittance T = 10^-A, so the picture
// and the absorbance readout are always consistent (A = -log10 T).
import React from 'react';
import {useCurrentFrame} from 'remotion';
import {color, font} from '../design/theme';
import {fmt} from '../lib/text.js';

export const OpticalBench: React.FC<{
  width: number;
  absorbance: number;
  /** 0..1 how far the light has travelled. */
  beamT: number;
  labels?: {lamp: string; filter: string; cuvette: string; detector: string} | null;
  labelSize?: number;
  showReadout?: boolean;
  lang: string;
  minimal?: boolean;
}> = ({width, absorbance, beamT, labels, labelSize = 28, showReadout = true, lang, minimal = false}) => {
  const frame = useCurrentFrame();
  const W = 1000;
  const H = labels ? 470 : 360;
  const s = width / W;
  const T = Math.pow(10, -absorbance);
  const y = 170;
  const xLamp = 95;
  const xFilter = 330;
  const xCuv = 560;
  const xDet = 860;
  const reach = (x: number) => Math.max(0, Math.min(1, (beamT * 980 - (x - 140)) / 60));
  const seg = (x1: number, x2: number) => {
    const total = 980;
    const startT = (x1 - 140) / total;
    const endT = (x2 - 140) / total;
    const f = Math.max(0, Math.min(1, (beamT - startT) / (endT - startT)));
    return x1 + (x2 - x1) * f;
  };
  const tint = Math.min(0.92, 0.12 + absorbance * 1.05);
  const flicker = 0.85 + 0.15 * Math.sin(frame / 3.1);
  const photons = (x1: number, x2: number, op: number) => {
    const end = seg(x1, x2);
    if (end <= x1) return null;
    const out = [];
    for (let i = 0; i < 6; i++) {
      const px = x1 + (((frame * 7 + i * 47) % (x2 - x1)) as number);
      if (px > end) continue;
      out.push(<circle key={`${x1}-${i}`} cx={px} cy={y + ((i % 3) - 1) * 7} r={3.2} fill={color.white} opacity={0.65 * op} />);
    }
    return out;
  };
  const label = (x: number, text: string) => (
    <text
      x={x}
      y={y + 190}
      fill={color.inkDim}
      fontFamily={font.sans}
      fontWeight={600}
      fontSize={labelSize / s}
      textAnchor="middle"
    >
      {text}
    </text>
  );
  return (
    <svg width={width} height={H * s} viewBox={`0 0 ${W} ${H}`} style={{overflow: 'visible'}}>
      <defs>
        <radialGradient id="lampGlow">
          <stop offset="0" stopColor="#FFF6D6" stopOpacity="1" />
          <stop offset="0.35" stopColor="#FFD777" stopOpacity="0.7" />
          <stop offset="1" stopColor="#FFD777" stopOpacity="0" />
        </radialGradient>
        <linearGradient id="glassG" x1="0" x2="1">
          <stop offset="0" stopColor="#FFFFFF" stopOpacity="0.32" />
          <stop offset="0.5" stopColor="#FFFFFF" stopOpacity="0.06" />
          <stop offset="1" stopColor="#FFFFFF" stopOpacity="0.22" />
        </linearGradient>
        <linearGradient id="liquidG" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0" stopColor={color.amber} stopOpacity={tint * 0.85} />
          <stop offset="1" stopColor="#D9822B" stopOpacity={tint} />
        </linearGradient>
        <filter id="blur6" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="6" />
        </filter>
      </defs>
      {/* bench rail */}
      {!minimal ? <rect x={40} y={y + 92} width={920} height={10} rx={5} fill={color.panelStrong} /> : null}
      {/* incident beam: lamp -> filter (white), filter -> cuvette (selected wavelength) */}
      <line x1={140} y1={y} x2={seg(140, xFilter - 14)} y2={y} stroke="#FFF2C4" strokeWidth={22} opacity={0.18 * flicker} strokeLinecap="round" />
      <line x1={140} y1={y} x2={seg(140, xFilter - 14)} y2={y} stroke="#FFF2C4" strokeWidth={6} opacity={0.9} strokeLinecap="round" />
      <line x1={xFilter + 14} y1={y} x2={seg(xFilter + 14, xCuv - 52)} y2={y} stroke={color.beam} strokeWidth={22} opacity={0.22 * flicker} strokeLinecap="round" />
      <line x1={xFilter + 14} y1={y} x2={seg(xFilter + 14, xCuv - 52)} y2={y} stroke={color.beam} strokeWidth={6} opacity={0.95} strokeLinecap="round" />
      {/* inside the cuvette */}
      <line x1={xCuv - 50} y1={y} x2={seg(xCuv - 50, xCuv + 50)} y2={y} stroke={color.beam} strokeWidth={6} opacity={0.5 + 0.45 * T} />
      {/* transmitted beam, intensity = T */}
      <line x1={xCuv + 52} y1={y} x2={seg(xCuv + 52, xDet - 40)} y2={y} stroke={color.beam} strokeWidth={22} opacity={0.22 * T * flicker} strokeLinecap="round" />
      <line x1={xCuv + 52} y1={y} x2={seg(xCuv + 52, xDet - 40)} y2={y} stroke={color.beam} strokeWidth={6} opacity={0.12 + 0.85 * T} strokeLinecap="round" />
      {photons(140, xFilter - 14, 1)}
      {photons(xFilter + 14, xCuv - 52, 1)}
      {photons(xCuv + 52, xDet - 40, T)}
      {/* lamp */}
      <circle cx={xLamp} cy={y} r={92} fill="url(#lampGlow)" opacity={0.75 * flicker} />
      <rect x={xLamp - 62} y={y - 66} width={84} height={132} rx={20} fill="#1A2522" stroke={color.line} strokeWidth={3} />
      <circle cx={xLamp + 4} cy={y} r={30} fill="#FFF6D6" />
      <circle cx={xLamp + 4} cy={y} r={30} fill="none" stroke="#FFD777" strokeWidth={4} />
      {/* filter */}
      <rect x={xFilter - 14} y={y - 78} width={28} height={156} rx={6} fill={color.beam} opacity={0.35} />
      <rect x={xFilter - 14} y={y - 78} width={28} height={156} rx={6} fill="url(#glassG)" stroke={color.beam} strokeWidth={2.5} />
      {/* cuvette */}
      <rect x={xCuv - 54} y={y - 120} width={108} height={210} rx={10} fill="url(#glassG)" stroke="#CFE9DF" strokeWidth={3} />
      <rect x={xCuv - 46} y={y - 62} width={92} height={144} rx={6} fill="url(#liquidG)" />
      <rect x={xCuv - 46} y={y - 62} width={92} height={8} rx={4} fill="#FFFFFF" opacity={0.35} />
      {/* detector */}
      <rect x={xDet - 40} y={y - 70} width={100} height={140} rx={18} fill="#1A2522" stroke={color.line} strokeWidth={3} />
      <rect x={xDet - 40} y={y - 24} width={14} height={48} rx={4} fill={color.mint} opacity={0.35 + 0.65 * reach(xDet - 40) * T} />
      {showReadout ? (
        <g>
          <rect x={xDet - 92} y={y - 150} width={204} height={62} rx={14} fill={color.bg0} stroke={color.mint} strokeWidth={2.5} />
          <text
            x={xDet + 10}
            y={y - 108}
            fill={color.mint}
            fontFamily={font.sans}
            fontWeight={700}
            fontSize={34}
            textAnchor="middle"
            style={{fontVariantNumeric: 'tabular-nums'}}
          >
            {`A ${fmt(absorbance, lang, 3)}`}
          </text>
        </g>
      ) : null}
      {labels ? (
        <g>
          {label(xLamp - 20, labels.lamp)}
          {label(xFilter, labels.filter)}
          {label(xCuv, labels.cuvette)}
          {label(xDet + 10, labels.detector)}
        </g>
      ) : null}
      {/* soft halo on the cuvette */}
      <rect x={xCuv - 60} y={y - 30} width={120} height={60} rx={30} fill={color.beam} opacity={0.08} filter="url(#blur6)" />
    </svg>
  );
};

/** Single glass cuvette with a tint for absorbance A (calibrator row). */
export const Cuvette: React.FC<{width: number; absorbance: number; lit: number}> = ({width, absorbance, lit}) => {
  const h = width * 1.9;
  const tint = Math.min(0.92, 0.1 + absorbance * 1.05);
  return (
    <svg width={width} height={h} viewBox="0 0 100 190" style={{overflow: 'visible'}}>
      <defs>
        <linearGradient id={`cg${Math.round(absorbance * 1000)}`} x1="0" x2="0" y1="0" y2="1">
          <stop offset="0" stopColor={color.amber} stopOpacity={tint * 0.8} />
          <stop offset="1" stopColor="#D9822B" stopOpacity={tint} />
        </linearGradient>
      </defs>
      <rect x={14} y={4} width={72} height={182} rx={9} fill="rgba(255,255,255,0.07)" stroke="#CFE9DF" strokeWidth={2.5} />
      <rect x={20} y={52} width={60} height={128} rx={6} fill={`url(#cg${Math.round(absorbance * 1000)})`} />
      <rect x={20} y={52} width={60} height={6} rx={3} fill="#FFFFFF" opacity={0.35} />
      <rect x={20} y={10} width={10} height={170} rx={5} fill="#FFFFFF" opacity={0.12} />
      {lit > 0 ? (
        <rect x={-18} y={110} width={136} height={10} rx={5} fill={color.beam} opacity={0.65 * lit} />
      ) : null}
    </svg>
  );
};
