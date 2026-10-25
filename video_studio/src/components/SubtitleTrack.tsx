// Burned-in subtitles. Cues come from src/lib/subtitles.js (the same cues
// written to .srt/.vtt). Mobile-legible: >= 46 px on the 1080-wide vertical,
// dark plate, inside the platform-UI safe zone.
import React from 'react';
import {interpolate, useCurrentFrame, useVideoConfig} from 'remotion';
import {color, font, Format, metrics} from '../design/theme';

export type Cue = {start: number; end: number; text: string};

export type SubZone = {start: number; end: number; zone: 'center' | 'left'};

export const SubtitleTrack: React.FC<{cues: Cue[]; format: Format; zones?: SubZone[]}> = ({cues, format, zones = []}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const t = frame / fps;
  const m = metrics(format);
  const cue = cues.find((c) => t >= c.start && t < c.end);
  if (!cue) return null;
  const fade = 4 / fps;
  const opacity = interpolate(
    t,
    [cue.start, cue.start + fade, cue.end - fade, cue.end],
    [0, 1, 1, 0],
    {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'},
  );
  // Horizontal phone scenes: subtitles move left so they never cover the phone.
  const left = format === 'horizontal' && zones.find((z) => t >= z.start && t < z.end)?.zone === 'left';
  return (
    <div
      style={{
        position: 'absolute',
        left: left ? m.gutter : 0,
        right: left ? m.w - 1200 : 0,
        bottom: m.h - m.subBottom,
        display: 'flex',
        justifyContent: left ? 'flex-start' : 'center',
        pointerEvents: 'none',
      }}
    >
      <div
        style={{
          opacity,
          maxWidth: left ? 1080 : m.subMaxW,
          padding: format === 'vertical' ? '16px 30px 18px' : '12px 30px 14px',
          borderRadius: 22,
          background: 'rgba(3,12,10,0.80)',
          border: `1px solid ${color.line}`,
          color: color.white,
          fontFamily: font.sans,
          fontWeight: 600,
          fontSize: m.subSize,
          lineHeight: 1.24,
          textAlign: 'center',
          letterSpacing: -0.2,
          textWrap: 'balance' as never,
          boxShadow: '0 12px 40px rgba(0,0,0,0.45)',
        }}
      >
        {cue.text}
      </div>
    </div>
  );
};
