import type React from 'react';
import type {Format, Lang, Metrics} from '../design/theme';

export type Rect = [number, number, number, number];

/** One real app frame (from flutter_walk/*.dart -> public/frames/<lang>/<video>/frames.json). */
export type FrameMeta = {
  id: string;
  file: string;
  w: number;
  h: number;
  tap: [number, number] | null;
  marks: Record<string, Rect>;
};

export type TimingLine = {id: string; start: number; end: number};
export type Timing = {
  videoId?: string;
  lang?: string;
  source?: string;
  totalSec?: number;
  voice?: string | null;
  lines: TimingLine[];
};

export type StoryScene = {
  id: string;
  layer: string;
  lines: string[];
  minSec: number;
  props?: Record<string, unknown>;
};

export type LaidScene = StoryScene & {
  index: number;
  startSec: number;
  endSec: number;
  from: number;
  durationInFrames: number;
  /** Line cues relative to the scene start (seconds). */
  cues: TimingLine[];
};

export type Storyboard = {
  id: string;
  fps: number;
  title: Record<Lang, string>;
  formats: Record<Format, {width: number; height: number}>;
  timing: {leadSec: number; tailSec: number; gapSec: number; minLineSec: number; cps: Record<string, number>};
  data: unknown;
  scenes: StoryScene[];
};

export type LangPack = {lang: Lang; lines: Record<string, string>; ui: Record<string, string>};

export type VideoCtx = {
  videoId: string;
  lang: Lang;
  format: Format;
  m: Metrics;
  ui: Record<string, string>;
  lines: Record<string, string>;
  vars: Record<string, string | number>;
  math: any;
  appFrames: Record<string, FrameMeta>;
  storyboard: Storyboard;
  /** Real voice present (else: silent placeholder timing). */
  voiced: boolean;
};

export type LayerProps = {scene: LaidScene; ctx: VideoCtx; prev?: LaidScene; next?: LaidScene};
export type Layer = React.FC<LayerProps>;

export type VideoDef = {
  id: string;
  storyboard: Storyboard;
  packs: Record<Lang, LangPack>;
  layers: Record<string, Layer>;
  /** Language whose narration drives the timing for ALL editions. */
  narrationLang: Lang;
  /** Layers that continue seamlessly across consecutive scenes (hard cut, no cross-fade). */
  continuous: string[];
  compute: (storyboard: Storyboard) => any;
  vars: (math: any, lang: Lang) => Record<string, string | number>;
  Thumb: React.FC<{ctx: VideoCtx; kind: 'landscape' | 'cover'}>;
};

export type VideoProps = {
  lang: Lang;
  timing: Timing | null;
  appFrames: Record<string, FrameMeta> | null;
  subtitles: boolean;
};
