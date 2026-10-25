// Background, SceneHeader, Badge, Pill — the shared visual vocabulary.
import React from 'react';
import {AbsoluteFill, useCurrentFrame} from 'remotion';
import {color, font, Format, metrics} from '../design/theme';
import {ease, rise} from './anim';

/** Deep ink background with a slow light bloom and a faint lab grid. */
export const Background: React.FC<{format: Format; glow?: [number, number]; tint?: string}> = ({
  format,
  glow = [0.5, 0.35],
  tint = color.brandBright,
}) => {
  const frame = useCurrentFrame();
  const m = metrics(format);
  const drift = Math.sin(frame / 90) * 0.03;
  const gx = (glow[0] + drift) * 100;
  const gy = (glow[1] - drift) * 100;
  const cell = format === 'vertical' ? 72 : 64;
  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(ellipse 70% 55% at ${gx}% ${gy}%, ${tint}33 0%, transparent 70%),
          radial-gradient(ellipse 90% 70% at 50% 110%, ${color.brand}55 0%, transparent 70%),
          linear-gradient(180deg, ${color.bg1} 0%, ${color.bg0} 100%)`,
      }}
    >
      <AbsoluteFill
        style={{
          backgroundImage: `linear-gradient(${color.grid} 1px, transparent 1px), linear-gradient(90deg, ${color.grid} 1px, transparent 1px)`,
          backgroundSize: `${cell}px ${cell}px`,
          backgroundPosition: `${(frame * 0.15) % cell}px ${(frame * 0.25) % cell}px`,
          maskImage: 'radial-gradient(ellipse 85% 75% at 50% 45%, black 30%, transparent 85%)',
          WebkitMaskImage: 'radial-gradient(ellipse 85% 75% at 50% 45%, black 30%, transparent 85%)',
          opacity: 0.9,
        }}
      />
      {/* vignette */}
      <AbsoluteFill
        style={{
          background: `radial-gradient(ellipse 120% 90% at 50% 50%, transparent 55%, rgba(0,0,0,0.55) 100%)`,
        }}
      />
      <div style={{position: 'absolute', width: m.w, height: m.h}} />
    </AbsoluteFill>
  );
};

export const Badge: React.FC<{text: string; tone?: 'neutral' | 'amber' | 'mint'; size: number; maxWidth?: number}> = ({
  text,
  tone = 'neutral',
  size,
  maxWidth,
}) => {
  const c = tone === 'amber' ? color.amber : tone === 'mint' ? color.mint : color.inkDim;
  const bg = tone === 'amber' ? color.amberSoft : tone === 'mint' ? color.mintSoft : color.panelStrong;
  return (
    <div
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: size * 0.45,
        padding: `${size * 0.32}px ${size * 0.7}px`,
        borderRadius: 999,
        background: bg,
        border: `1.5px solid ${c}55`,
        color: c,
        fontFamily: font.sans,
        fontWeight: 600,
        fontSize: size,
        letterSpacing: 0.2,
        lineHeight: 1.15,
        // A maxWidth lets long badges wrap (default: one line, as before).
        whiteSpace: maxWidth ? 'normal' : 'nowrap',
        maxWidth,
      }}
    >
      <span
        style={{
          width: size * 0.42,
          height: size * 0.42,
          borderRadius: 99,
          background: c,
          flex: 'none',
        }}
      />
      {text}
    </div>
  );
};

/**
 * Kicker ("02 · The analyzer") + optional title + optional badge, anchored at
 * the top safe line. Vertical: badge under the kicker; horizontal: right.
 */
export const SceneHeader: React.FC<{
  format: Format;
  step?: string;
  kicker: string;
  title?: string;
  badge?: {text: string; tone?: 'neutral' | 'amber' | 'mint'};
  delay?: number;
  align?: 'left' | 'center';
  /** Force the badge under the kicker (e.g. when the right side is occupied). */
  badgeBelow?: boolean;
}> = ({format, step, kicker, title, badge, delay = 0, align = 'left', badgeBelow = false}) => {
  const frame = useCurrentFrame();
  const m = metrics(format);
  const t1 = ease(frame, delay, 14);
  const t2 = ease(frame, delay + 4, 16);
  const t3 = ease(frame, delay + 8, 16);
  const vertical = format === 'vertical' || badgeBelow;
  return (
    <div
      style={{
        position: 'absolute',
        left: m.gutter,
        right: m.gutter,
        top: m.top,
        display: 'flex',
        flexDirection: 'column',
        alignItems: align === 'center' ? 'center' : 'flex-start',
        gap: vertical ? 18 : 14,
        textAlign: align,
      }}
    >
      <div
        style={{
          display: 'flex',
          width: '100%',
          justifyContent: align === 'center' ? 'center' : 'space-between',
          alignItems: 'center',
          gap: 24,
        }}
      >
        <div
          style={{
            ...rise(t1, 16),
            display: 'flex',
            alignItems: 'center',
            gap: 16,
            fontFamily: font.sans,
            fontWeight: 700,
            fontSize: m.kicker,
            letterSpacing: m.kicker * 0.14,
            textTransform: 'uppercase',
            color: color.mint,
          }}
        >
          {step ? (
            <span style={{color: color.inkFaint, letterSpacing: 2}}>{step}</span>
          ) : null}
          <span
            style={{width: 44, height: 3, borderRadius: 3, background: color.mint, flex: 'none'}}
          />
          <span>{kicker}</span>
        </div>
        {badge && !vertical ? (
          <div style={{opacity: t3}}>
            <Badge text={badge.text} tone={badge.tone} size={m.small * 0.82} />
          </div>
        ) : null}
      </div>
      {title ? (
        <div
          style={{
            ...rise(t2, 24),
            fontFamily: font.sans,
            fontWeight: 700,
            fontSize: m.h2,
            lineHeight: 1.08,
            letterSpacing: -0.8,
            color: color.ink,
            maxWidth: vertical ? '100%' : '62%',
            textWrap: 'balance' as never,
          }}
        >
          {title}
        </div>
      ) : null}
      {badge && vertical ? (
        <div style={{opacity: t3, marginTop: 4}}>
          <Badge text={badge.text} tone={badge.tone} size={m.small * 0.8} />
        </div>
      ) : null}
    </div>
  );
};

/** Rounded label used for on-screen callouts. */
export const Pill: React.FC<{
  text: string;
  size: number;
  tone?: 'mint' | 'amber' | 'coral' | 'ink';
  style?: React.CSSProperties;
}> = ({text, size, tone = 'ink', style}) => {
  const c =
    tone === 'mint' ? color.mint : tone === 'amber' ? color.amber : tone === 'coral' ? color.coral : color.ink;
  return (
    <div
      style={{
        display: 'inline-block',
        padding: `${size * 0.36}px ${size * 0.66}px`,
        borderRadius: size * 0.6,
        background: 'rgba(7,22,18,0.86)',
        border: `2px solid ${c}`,
        boxShadow: `0 10px 30px rgba(0,0,0,0.35), 0 0 0 6px ${c}14`,
        color: c,
        fontFamily: font.sans,
        fontWeight: 650 as never,
        fontSize: size,
        lineHeight: 1.2,
        ...style,
      }}
    >
      {text}
    </div>
  );
};
