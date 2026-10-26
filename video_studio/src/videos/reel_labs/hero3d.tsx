// Original 3D-look hero pieces for the overview hook, thumbnail and cover:
// a CSS-3D phone with a REAL app frame, glossy SVG laboratory objects (test
// tubes, beaker, flask, microscope silhouette) and an app icon with a glint.
// Everything is drawn here (SVG + CSS gradients); no third-party art, no
// logos besides the owner's own app icon.
import React from 'react';
import {Img, staticFile} from 'remotion';
import {PhoneFrame} from '../../components/PhoneFrame';
import {color} from '../../design/theme';

/** Phone outer height for a given outer width (same formula as PhoneFrame, 390x844 screen). */
export const phoneHeight = (w: number) => {
  const bezel = w * 0.035;
  return ((w - 2 * bezel) * 844) / 390 + 2 * bezel;
};

// ------------------------------------------------------------ glossy objects
const shadow = 'drop-shadow(0 26px 30px rgba(0,0,0,0.55))';

export const Tube: React.FC<{h?: number; hue?: number; fill?: number; id?: string}> = ({h = 260, hue = 150, fill = 0.55, id = 't'}) => {
  const w = h * 0.23;
  const lv = 12 + (1 - fill) * 200;
  return (
    <svg width={w} height={h} viewBox="0 0 60 260" style={{filter: shadow, overflow: 'visible'}}>
      <defs>
        <linearGradient id={`${id}g`} x1="0" x2="1">
          <stop offset="0" stopColor="#fff" stopOpacity="0.5" />
          <stop offset="0.35" stopColor="#cfe9e0" stopOpacity="0.10" />
          <stop offset="0.75" stopColor="#fff" stopOpacity="0.18" />
          <stop offset="1" stopColor="#fff" stopOpacity="0.45" />
        </linearGradient>
        <linearGradient id={`${id}l`} x1="0" x2="1">
          <stop offset="0" stopColor={`hsl(${hue},70%,62%)`} />
          <stop offset="0.5" stopColor={`hsl(${hue},75%,48%)`} />
          <stop offset="1" stopColor={`hsl(${hue},70%,34%)`} />
        </linearGradient>
        <linearGradient id={`${id}c`} x1="0" x2="1">
          <stop offset="0" stopColor="#e9b64e" />
          <stop offset="0.5" stopColor="#c98a24" />
          <stop offset="1" stopColor="#8a5a14" />
        </linearGradient>
      </defs>
      <path d={`M10 ${lv} H50 V226 A20 20 0 0 1 10 226 Z`} fill={`url(#${id}l)`} />
      <ellipse cx="30" cy={lv} rx="20" ry="5" fill={`hsl(${hue},80%,72%)`} opacity="0.9" />
      <circle cx="24" cy="190" r="3" fill="#fff" opacity="0.5" />
      <circle cx="36" cy="160" r="2" fill="#fff" opacity="0.5" />
      <circle cx="28" cy="214" r="2.4" fill="#fff" opacity="0.45" />
      <path d="M8 14 H52 V226 A22 22 0 0 1 8 226 Z" fill={`url(#${id}g)`} stroke="rgba(255,255,255,0.55)" strokeWidth="1.5" />
      <rect x="14" y="26" width="5" height="190" rx="2.5" fill="#fff" opacity="0.55" />
      <rect x="4" y="6" width="52" height="14" rx="5" fill={`url(#${id}c)`} />
      <rect x="4" y="6" width="52" height="4" rx="2" fill="#fff" opacity="0.35" />
    </svg>
  );
};

export const Beaker: React.FC<{w?: number; hue?: number; id?: string}> = ({w = 170, hue = 170, id = 'b'}) => (
  <svg width={w} height={w * 1.2} viewBox="0 0 170 204" style={{filter: shadow, overflow: 'visible'}}>
    <defs>
      <linearGradient id={`${id}g`} x1="0" x2="1">
        <stop offset="0" stopColor="#fff" stopOpacity="0.5" />
        <stop offset="0.4" stopColor="#cfe9e0" stopOpacity="0.08" />
        <stop offset="1" stopColor="#fff" stopOpacity="0.4" />
      </linearGradient>
      <linearGradient id={`${id}l`} x1="0" x2="1">
        <stop offset="0" stopColor={`hsl(${hue},65%,60%)`} />
        <stop offset="1" stopColor={`hsl(${hue},70%,32%)`} />
      </linearGradient>
    </defs>
    <path d="M22 70 H148 V186 Q148 198 136 198 H34 Q22 198 22 186 Z" fill={`url(#${id}l)`} opacity="0.95" />
    <ellipse cx="85" cy="70" rx="63" ry="9" fill={`hsl(${hue},80%,72%)`} opacity="0.9" />
    <path d="M14 10 H156 V186 Q156 202 140 202 H30 Q14 202 14 186 Z" fill={`url(#${id}g)`} stroke="rgba(255,255,255,0.55)" strokeWidth="2" />
    <ellipse cx="85" cy="10" rx="71" ry="7" fill="rgba(255,255,255,0.18)" stroke="rgba(255,255,255,0.5)" strokeWidth="1.5" />
    {[40, 62, 84, 106, 128].map((y, i) => (
      <line key={y} x1="126" x2={i % 2 ? 142 : 150} y1={y + 24} y2={y + 24} stroke="rgba(255,255,255,0.7)" strokeWidth="2" />
    ))}
    <rect x="26" y="22" width="9" height="150" rx="4.5" fill="#fff" opacity="0.45" />
    <circle cx="60" cy="150" r="5" fill="#fff" opacity="0.4" />
    <circle cx="96" cy="120" r="3.4" fill="#fff" opacity="0.4" />
  </svg>
);

export const Flask: React.FC<{w?: number; hue?: number; id?: string}> = ({w = 150, hue = 40, id = 'f'}) => (
  <svg width={w} height={w * 1.3} viewBox="0 0 150 195" style={{filter: shadow, overflow: 'visible'}}>
    <defs>
      <linearGradient id={`${id}g`} x1="0" x2="1">
        <stop offset="0" stopColor="#fff" stopOpacity="0.5" />
        <stop offset="0.45" stopColor="#cfe9e0" stopOpacity="0.08" />
        <stop offset="1" stopColor="#fff" stopOpacity="0.4" />
      </linearGradient>
      <linearGradient id={`${id}l`} x1="0" x2="1">
        <stop offset="0" stopColor={`hsl(${hue},85%,62%)`} />
        <stop offset="1" stopColor={`hsl(${hue},80%,38%)`} />
      </linearGradient>
    </defs>
    <path d="M24 120 Q12 170 22 184 Q75 198 128 184 Q138 170 126 120 Z" fill={`url(#${id}l)`} opacity="0.95" />
    <ellipse cx="75" cy="121" rx="52" ry="7" fill={`hsl(${hue},90%,76%)`} opacity="0.9" />
    <path d="M56 8 H94 V70 L140 168 Q146 190 124 190 H26 Q4 190 10 168 L56 70 Z" fill={`url(#${id}g)`} stroke="rgba(255,255,255,0.55)" strokeWidth="2" />
    <ellipse cx="75" cy="8" rx="22" ry="5" fill="rgba(255,255,255,0.2)" stroke="rgba(255,255,255,0.5)" strokeWidth="1.5" />
    <path d="M62 24 V70 L22 160" stroke="#fff" strokeOpacity="0.5" strokeWidth="6" strokeLinecap="round" fill="none" />
  </svg>
);

/** Microscope silhouette (dark glass-metal look with a rim light). */
export const Scope: React.FC<{w?: number; id?: string}> = ({w = 360, id = 'm'}) => (
  <svg width={w} height={w * 1.15} viewBox="0 0 300 345" style={{filter: shadow, overflow: 'visible'}}>
    <defs>
      <linearGradient id={`${id}a`} x1="0" x2="1">
        <stop offset="0" stopColor="#5c7a70" />
        <stop offset="0.5" stopColor="#2a403a" />
        <stop offset="1" stopColor="#13211d" />
      </linearGradient>
      <linearGradient id={`${id}b`} x1="0" x2="0" y1="0" y2="1">
        <stop offset="0" stopColor="#3b524b" />
        <stop offset="1" stopColor="#0f1a17" />
      </linearGradient>
    </defs>
    <rect x="40" y="300" width="220" height="32" rx="14" fill={`url(#${id}b)`} />
    <rect x="46" y="304" width="208" height="5" rx="2.5" fill="#9fd8c4" opacity="0.35" />
    <path d="M190 300 C260 290 270 210 250 150 C240 120 215 110 200 120 L196 150 C222 160 228 220 190 252 Z" fill={`url(#${id}a)`} />
    <rect x="64" y="228" width="130" height="16" rx="6" fill={`url(#${id}b)`} />
    <rect x="70" y="231" width="118" height="3" rx="1.5" fill="#9fd8c4" opacity="0.35" />
    <g transform="rotate(-24 120 90)">
      <rect x="92" y="30" width="56" height="150" rx="14" fill={`url(#${id}a)`} />
      <rect x="100" y="14" width="40" height="26" rx="8" fill={`url(#${id}b)`} />
      <rect x="104" y="180" width="32" height="28" rx="6" fill={`url(#${id}b)`} />
      <rect x="98" y="36" width="6" height="130" rx="3" fill="#9fd8c4" opacity="0.4" />
    </g>
    <circle cx="214" cy="262" r="16" fill={`url(#${id}b)`} stroke="#9fd8c4" strokeOpacity="0.4" />
  </svg>
);

/** Three tubes in a small rack. */
export const TubeRack: React.FC<{h?: number}> = ({h = 220}) => (
  <div style={{position: 'relative', width: h * 0.95, height: h * 1.05}}>
    {[0, 1, 2].map((i) => (
      <div key={i} style={{position: 'absolute', left: i * h * 0.3, top: i === 1 ? -h * 0.06 : 0, transform: `rotate(${(i - 1) * 6}deg)`}}>
        <Tube h={h} hue={[150, 30, 200][i]} fill={[0.6, 0.45, 0.7][i]} id={`rk${i}`} />
      </div>
    ))}
    <div style={{position: 'absolute', left: -h * 0.06, right: -h * 0.06, bottom: h * 0.02, height: h * 0.1, borderRadius: h * 0.05, background: 'linear-gradient(180deg,#3f5a52,#17231f)', boxShadow: '0 18px 30px rgba(0,0,0,0.5)'}} />
  </div>
);

// ------------------------------------------------------------------ phone 3D
/** A phone in CSS 3D: real app frame, thickness, glass sweep and floor shadow. */
export const Phone3D: React.FC<{
  src: string;
  width: number;
  rotY: number;
  rotX?: number;
  /** 0..1 position of the light sweep across the glass; null = none. */
  sweep?: number | null;
  glow?: number;
}> = ({src, width, rotY, rotX = 6, sweep = null, glow = 0.35}) => {
  const h = phoneHeight(width);
  const radius = width * 0.13;
  return (
    <div style={{position: 'relative', width, height: h, perspective: 2200, perspectiveOrigin: '50% 45%'}}>
      {/* floor shadow + glow */}
      <div style={{position: 'absolute', left: -width * 0.3, right: -width * 0.3, bottom: -h * 0.07, height: h * 0.1, borderRadius: '50%', background: 'radial-gradient(closest-side, rgba(0,0,0,0.65), transparent)', transform: `scaleX(${0.75 + Math.abs(Math.sin((rotY * Math.PI) / 180)) * 0.5})`, filter: 'blur(10px)'}} />
      <div style={{position: 'absolute', left: -width * 0.5, top: h * 0.1, width: width * 2, height: h * 0.8, background: `radial-gradient(closest-side, ${color.mint}${Math.round(glow * 255).toString(16).padStart(2, '0')}, transparent)`}} />
      <div style={{position: 'absolute', inset: 0, transformStyle: 'preserve-3d', transform: `rotateY(${rotY}deg) rotateX(${rotX}deg)`}}>
        {[1, 2, 3, 4, 5, 6, 7].map((i) => (
          <div key={i} style={{position: 'absolute', inset: 0, borderRadius: radius, background: i < 4 ? '#0a100e' : '#1d2926', transform: `translateZ(${-i * 3}px)`}} />
        ))}
        <div style={{position: 'absolute', inset: 0}}>
          <PhoneFrame appW={390} appH={844} src={src} width={width} />
          {sweep !== null ? (
            <div
              style={{
                position: 'absolute',
                inset: 0,
                borderRadius: radius,
                overflow: 'hidden',
                mixBlendMode: 'screen',
                background: `linear-gradient(112deg, transparent ${sweep * 140 - 40}%, rgba(255,255,255,0.45) ${sweep * 140 - 20}%, transparent ${sweep * 140}%)`,
              }}
            />
          ) : null}
        </div>
      </div>
    </div>
  );
};

// ----------------------------------------------------------------- app icon
/** The owner's app icon in 3D with a moving glint. rot = [x, y] in degrees. */
export const Icon3D: React.FC<{size: number; rotX: number; rotY: number; glint?: number | null}> = ({size, rotX, rotY, glint = null}) => (
  <div style={{width: size, height: size, perspective: 900}}>
    <div style={{width: size, height: size, position: 'relative', transformStyle: 'preserve-3d', transform: `rotateX(${rotX}deg) rotateY(${rotY}deg)`}}>
      <Img
        src={staticFile('brand/logo_mark.png')}
        style={{width: size, height: size, borderRadius: size * 0.22, boxShadow: `0 30px 60px rgba(0,0,0,0.55), 0 0 0 2px rgba(255,255,255,0.12), 0 0 ${size * 0.7}px ${color.brandBright}88`}}
      />
      {glint !== null ? (
        <div
          style={{
            position: 'absolute',
            inset: 0,
            borderRadius: size * 0.22,
            overflow: 'hidden',
            mixBlendMode: 'screen',
            background: `linear-gradient(115deg, transparent ${glint * 150 - 50}%, rgba(255,255,255,0.8) ${glint * 150 - 25}%, transparent ${glint * 150}%)`,
          }}
        />
      ) : null}
    </div>
  </div>
);
