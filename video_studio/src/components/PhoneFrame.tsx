// A neutral (brand-free) phone with a REAL app frame inside. Frames come from
// video_studio/flutter_walk (widget-test renders of the app: 390x844 @2x).
// Supports a focus zoom, measured highlight rectangles, a tap ripple and a
// cross-fade from the previous frame. Never paints over app content except
// the highlight ring and the optional "outside crop" dimmer.
import React from 'react';
import {Img, staticFile} from 'remotion';
import {color} from '../design/theme';

export type Rect = [number, number, number, number];

export const APP_W = 390;
export const APP_H = 844;

export type PhoneProps = {
  src: string;
  prevSrc?: string | null;
  /** 0..1 — opacity of `src` over `prevSrc`. */
  mix?: number;
  /** Outer phone width on canvas. */
  width: number;
  zoom?: number;
  /** Logical point (app px) to keep centred when zoomed. */
  focus?: [number, number];
  mark?: {rect: Rect; t: number; tone: 'mint' | 'amber' | 'coral'} | null;
  tap?: {at: [number, number]; t: number} | null;
  /** Logical rect that stays bright; outside is dimmed (e.g. hides text). */
  crop?: Rect | null;
  /** Opacity of the dimmer outside `crop` (default 0.9). */
  cropShade?: number;
  tilt?: number;
  style?: React.CSSProperties;
  /** Logical app size of the frame (portrait 390x844 default; landscape 844x390). */
  appW?: number;
  appH?: number;
};

const toneColor = {mint: color.mint, amber: color.amber, coral: color.coral};

export const PhoneFrame: React.FC<PhoneProps> = ({
  src,
  prevSrc,
  mix = 1,
  width,
  zoom = 1,
  focus = [APP_W / 2, APP_H / 2],
  mark,
  tap,
  crop,
  cropShade = 0.9,
  tilt = 0,
  style,
  appW = APP_W,
  appH = APP_H,
}) => {
  const APP_W_ = appW;
  const APP_H_ = appH;
  const bezel = width * 0.035;
  const sw = width - bezel * 2;
  const sh = (sw * APP_H_) / APP_W_;
  const height = sh + bezel * 2;
  const k = (sw / APP_W_) * zoom;
  // Translate so `focus` sits in the centre, clamped to the frame edges.
  const tx = Math.min(0, Math.max(sw - APP_W_ * k, sw / 2 - focus[0] * k));
  const ty = Math.min(0, Math.max(sh - APP_H_ * k, sh / 2 - focus[1] * k));
  const radius = Math.min(width, height) * 0.13 * (appW > appH ? 0.6 : 1);
  const content = (s: string, opacity: number) => (
    <Img
      src={staticFile(s)}
      style={{
        position: 'absolute',
        left: 0,
        top: 0,
        width: APP_W_ * k,
        height: APP_H_ * k,
        opacity,
      }}
    />
  );
  const ring = mark
    ? (() => {
        const [x, y, w, h] = mark.rect;
        const pad = 8;
        const c = toneColor[mark.tone];
        const t = mark.t;
        return (
          <div
            style={{
              position: 'absolute',
              left: (x - pad) * k,
              top: (y - pad) * k,
              width: (w + pad * 2) * k,
              height: (h + pad * 2) * k,
              borderRadius: 14 * k,
              border: `${3 * Math.max(1, k * 0.6)}px solid ${c}`,
              boxShadow: `0 0 0 ${10 * t}px ${c}22, 0 0 ${30 * t}px ${c}66`,
              opacity: t,
              transform: `scale(${1.08 - 0.08 * t})`,
            }}
          />
        );
      })()
    : null;
  const ripple = tap
    ? (() => {
        const r = 18 + 26 * tap.t;
        return (
          <div
            style={{
              position: 'absolute',
              left: tap.at[0] * k - r * k * 0.5,
              top: tap.at[1] * k - r * k * 0.5,
              width: r * k,
              height: r * k,
              borderRadius: 999,
              border: `${3 * k * 0.7}px solid ${color.amber}`,
              background: `${color.amber}33`,
              opacity: tap.t <= 0 ? 0 : 1 - tap.t * 0.7,
            }}
          />
        );
      })()
    : null;
  const dim = crop
    ? (() => {
        const [x, y, w, h] = crop;
        const shade = `rgba(4,14,11,${cropShade})`;
        return (
          <>
            <div style={{position: 'absolute', left: 0, top: 0, width: APP_W_ * k, height: y * k, background: shade}} />
            <div
              style={{position: 'absolute', left: 0, top: (y + h) * k, width: APP_W_ * k, height: (APP_H_ - y - h) * k, background: shade}}
            />
            <div style={{position: 'absolute', left: 0, top: y * k, width: x * k, height: h * k, background: shade}} />
            <div
              style={{position: 'absolute', left: (x + w) * k, top: y * k, width: (APP_W_ - x - w) * k, height: h * k, background: shade}}
            />
          </>
        );
      })()
    : null;
  return (
    <div
      style={{
        width,
        height,
        borderRadius: radius,
        padding: bezel,
        boxSizing: 'border-box',
        background: 'linear-gradient(150deg, #3A4743 0%, #141C19 38%, #0B110F 70%, #2C3834 100%)',
        boxShadow: `0 40px 120px rgba(0,0,0,0.6), 0 0 0 2px rgba(255,255,255,0.06), inset 0 0 0 2px rgba(255,255,255,0.08), 0 0 160px ${color.brandBright}22`,
        transform: tilt ? `perspective(2400px) rotateY(${tilt}deg)` : undefined,
        position: 'relative',
        ...style,
      }}
    >
      <div
        style={{
          position: 'relative',
          width: sw,
          height: sh,
          borderRadius: radius - bezel,
          overflow: 'hidden',
          background: '#F3F2EC',
        }}
      >
        <div style={{position: 'absolute', left: tx, top: ty, width: APP_W_ * k, height: APP_H_ * k}}>
          {prevSrc && mix < 1 ? content(prevSrc, 1) : null}
          {content(src, prevSrc ? mix : 1)}
          {dim}
          {ring}
          {ripple}
        </div>
        {/* neutral punch-hole camera */}
        <div
          style={{
            position: 'absolute',
            left: appW > appH ? sh * 0.03 : sw / 2 - sw * 0.022,
            top: appW > appH ? sh / 2 - sh * 0.022 : sw * 0.03,
            width: Math.min(sw, sh) * 0.044,
            height: Math.min(sw, sh) * 0.044,
            borderRadius: 99,
            background: '#0B0F0E',
            boxShadow: 'inset 0 0 0 2px #1d2523',
          }}
        />
        {/* glass reflection */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            background: 'linear-gradient(115deg, rgba(255,255,255,0.10) 0%, rgba(255,255,255,0) 28%)',
            pointerEvents: 'none',
          }}
        />
      </div>
    </div>
  );
};
