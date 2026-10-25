// Generic, data-driven video: ONE scene graph for every language. Language
// only changes the text pack, the timing manifest (subtitles/voice) and the
// app frames passed in as props — never the structure.
import React, {useMemo} from 'react';
import {AbsoluteFill, interpolate, Sequence, useCurrentFrame} from 'remotion';
import {Background} from '../components/Basics';
import {SubtitleTrack} from '../components/SubtitleTrack';
import {useFonts} from '../design/fonts';
import {Format, metrics} from '../design/theme';
import {buildCues} from '../lib/subtitles.js';
import {resolveLines} from '../lib/text.js';
import {layoutScenes, placeholderTiming} from '../lib/timing.js';
import type {LaidScene, VideoCtx, VideoDef, VideoProps} from './types';

const OVERLAP = 12; // frames of cross-fade between different layers

export function buildContext(def: VideoDef, props: VideoProps, format: Format) {
  const math = def.compute(def.storyboard);
  const vars = def.vars(math, props.lang);
  const pack = def.packs[props.lang];
  const lines = resolveLines(pack, vars) as Record<string, string>;
  // Owner decision 2026-10-25: every language edition uses the ENGLISH
  // narration timing (one English voice track); ru/uz differ only in
  // subtitles and on-screen text. Silent placeholder = English estimate.
  const enLines = resolveLines(def.packs[def.narrationLang], def.vars(math, def.narrationLang)) as Record<string, string>;
  const timing = props.timing ?? placeholderTiming(def.storyboard, enLines, def.narrationLang);
  const layout = layoutScenes(def.storyboard, timing, def.storyboard.fps);
  const ctx: VideoCtx = {
    videoId: def.id,
    lang: props.lang,
    format,
    m: metrics(format),
    ui: pack.ui,
    lines,
    vars,
    math,
    appFrames: props.appFrames ?? {},
    storyboard: def.storyboard,
    voiced: props.timing != null,
  };
  return {ctx, layout, timing};
}

const SceneShell: React.FC<{
  scene: LaidScene;
  fadeIn: boolean;
  fadeOut: boolean;
  children: React.ReactNode;
}> = ({scene, fadeIn, fadeOut, children}) => {
  const frame = useCurrentFrame();
  const d = scene.durationInFrames;
  const a = fadeIn ? interpolate(frame, [0, OVERLAP], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}) : 1;
  const b = fadeOut ? interpolate(frame, [d, d + OVERLAP], [1, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}) : 1;
  return <AbsoluteFill style={{opacity: Math.min(a, b)}}>{children}</AbsoluteFill>;
};

export const StoryboardVideo: React.FC<{def: VideoDef; format: Format} & VideoProps> = ({def, format, ...props}) => {
  useFonts();
  const {ctx, layout, timing} = useMemo(
    () => buildContext(def, props, format),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [def, format, props.lang, props.timing, props.appFrames],
  );
  const cues = useMemo(() => buildCues(timing.lines, ctx.lines), [timing, ctx.lines]);
  const scenes = layout.scenes as LaidScene[];
  return (
    <AbsoluteFill style={{backgroundColor: '#05110E'}}>
      <Background format={format} />
      {scenes.map((sc, k) => {
        const prev = scenes[k - 1];
        const next = scenes[k + 1];
        const Layer = def.layers[sc.layer];
        if (!Layer) throw new Error(`no layer "${sc.layer}"`);
        const contPrev = !!prev && prev.layer === sc.layer && def.continuous.includes(sc.layer);
        const contNext = !!next && next.layer === sc.layer && def.continuous.includes(sc.layer);
        const fadeIn = k > 0 && !contPrev;
        const fadeOut = !!next && !contNext;
        return (
          <Sequence
            key={sc.id}
            from={sc.from}
            durationInFrames={sc.durationInFrames + (fadeOut ? OVERLAP : 0)}
            name={`${k + 1}. ${sc.id} (${sc.layer})`}
          >
            <SceneShell scene={sc} fadeIn={fadeIn} fadeOut={fadeOut}>
              <Layer scene={sc} ctx={ctx} prev={prev} next={next} />
            </SceneShell>
          </Sequence>
        );
      })}
      {props.subtitles ? (
        <SubtitleTrack
          cues={cues}
          format={format}
          zones={scenes.map((sc) => ({
            start: sc.startSec,
            end: sc.endSec,
            zone: sc.props?.subZone === 'left' ? 'left' : 'center',
          }))}
        />
      ) : null}
    </AbsoluteFill>
  );
};
