// Small helpers shared by video layers (timing cues, text style, format).
import type React from 'react';
import {useCurrentFrame, useVideoConfig} from 'remotion';
import {color, font} from '../design/theme';
import type {LaidScene, VideoCtx} from '../framework/types';

/** Frame clock of a scene plus its narration cues (in scene frames). */
export const useT = (scene: LaidScene) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const cue = (i: number) => Math.round((scene.cues[i]?.start ?? 0) * fps);
  const cueEnd = (i: number) => Math.round((scene.cues[i]?.end ?? 0) * fps);
  return {frame, fps, cue, cueEnd, dur: scene.durationInFrames};
};

export const isV = (ctx: VideoCtx) => ctx.format === 'vertical';

export const txt = (size: number, weight = 600, c: string = color.ink): React.CSSProperties => ({
  fontFamily: font.sans,
  fontWeight: weight,
  fontSize: size,
  color: c,
  lineHeight: 1.15,
});
